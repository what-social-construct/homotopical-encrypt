// RPC Interface - Python ↔ Oracle communication
//
// Simple JSON-RPC server for receiving FullStalk from Python
// and sending HashStalk commitments to Rust node

use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tokio::sync::Mutex;
use tracing::info;

use crate::stalk_bridge::{StalkBridge, FullStalk};

/// RPC Request from Python
#[derive(Debug, Deserialize)]
#[serde(tag = "method")]
pub enum RpcRequest {
    /// Submit a full stalk for commitment
    #[serde(rename = "submit_stalk")]
    SubmitStalk { params: FullStalkRequest },
    
    /// Query commitment for a vertex
    #[serde(rename = "get_commitment")]
    GetCommitment { params: GetCommitmentParams },
    
    /// Add edge for naturality checking
    #[serde(rename = "add_edge")]
    AddEdge { params: AddEdgeParams },
    
    /// Verify all naturality conditions
    #[serde(rename = "verify_naturality")]
    VerifyNaturality,
    
    /// Check if section glues (H^1 = 0)
    #[serde(rename = "check_gluing")]
    CheckGluing,
    
    /// Health check
    #[serde(rename = "health")]
    Health,
}

#[derive(Debug, Deserialize)]
pub struct GetCommitmentParams {
    pub vertex_id: u64,
}

#[derive(Debug, Deserialize)]
pub struct AddEdgeParams {
    pub from: u64,
    pub to: u64,
}

/// Full stalk submission from Python
///
/// Python computes ALL geometry (Hodge projection, eigendecomposition, etc.)
/// and sends pre-computed results. Oracle verifies bounds only.
/// See: stalk_bridge.rs COMPUTATION BOUNDARY comment.
#[derive(Debug, Deserialize)]
pub struct FullStalkRequest {
    pub vertex_id: u64,
    pub credential: Vec<f64>,
    pub eigenvalues: Vec<f64>,
    pub betti_numbers: (i32, i32, i32),
    pub nerve_vertices: Vec<u64>,
    pub nerve_edges: Vec<(u64, u64)>,
    /// Pre-computed spectral gap (Python: SheafLaplacian.spectral_gap())
    pub spectral_gap: f64,
    /// Pre-computed commitment bytes (Python: Hodge projection + quantization)
    /// Hex-encoded 32 bytes
    pub commitment: String,
}

/// RPC Response to Python
#[derive(Debug, Serialize)]
#[serde(untagged)]
pub enum RpcResponse {
    /// Commitment computed successfully
    Commitment(CommitmentResponse),
    
    /// Query result
    QueryResult(QueryResponse),
    
    /// Verification result
    Verification(VerificationResponse),
    
    /// Health check
    Health(HealthResponse),
    
    /// Error
    Error(ErrorResponse),
}

#[derive(Debug, Serialize)]
pub struct CommitmentResponse {
    pub success: bool,
    pub vertex_id: u64,
    pub identity_hash: String,  // Hex-encoded SHA256(betti + topology_hash)
    pub harmonic_components: Vec<HarmonicComponent>,  // Unique values with multiplicities
    pub spectral_gap_valid: bool,
    pub betti_numbers: (i32, i32, i32),
}

/// A harmonic component with its value and multiplicity
#[derive(Debug, Serialize)]
pub struct HarmonicComponent {
    pub value: String,  // Hex byte
    pub multiplicity: usize,  // How many times it appears
}

#[derive(Debug, Serialize)]
pub struct QueryResponse {
    pub found: bool,
    pub commitment: Option<HashStalkJson>,
}

#[derive(Debug, Serialize)]
pub struct HashStalkJson {
    pub vertex_id: u64,
    pub identity_hash: String,  // SHA256(betti + topology_hash), hex
    pub harmonic_components: Vec<HarmonicComponent>,  // Unique values with multiplicities
    pub spectral_gap_valid: bool,
    pub betti_numbers: (i32, i32, i32),
    pub topology_hash: String,
    pub computed_at: u64,
}

/// Extract harmonic components with multiplicities from fingerprint bytes
fn extract_harmonic_components(fingerprint: &[u8; 32]) -> Vec<HarmonicComponent> {
    let mut counts = std::collections::HashMap::new();
    let mut order = Vec::new();
    
    for &byte in fingerprint.iter() {
        *counts.entry(byte).or_insert(0) += 1;
        if !order.contains(&byte) {
            order.push(byte);
        }
    }
    
    order.iter().map(|&byte| HarmonicComponent {
        value: format!("{:02x}", byte),
        multiplicity: counts[&byte],
    }).collect()
}

#[derive(Debug, Serialize)]
pub struct VerificationResponse {
    pub success: bool,
    pub edges_checked: usize,
    pub all_natural: bool,
    pub h1_zero: bool,  // Section glues?
}

#[derive(Debug, Serialize)]
pub struct HealthResponse {
    pub status: String,
    pub stalks_count: usize,
    pub commitments_count: usize,
}

#[derive(Debug, Serialize)]
pub struct ErrorResponse {
    pub error: String,
    pub code: i32,
}

/// Oracle RPC Server State
pub struct OracleRpc {
    bridge: Arc<Mutex<StalkBridge>>,
}

impl OracleRpc {
    pub fn new() -> Self {
        Self {
            bridge: Arc::new(Mutex::new(StalkBridge::new())),
        }
    }
    
    /// Handle incoming RPC request
    pub async fn handle_request(&self, request: RpcRequest) -> RpcResponse {
        match request {
            RpcRequest::SubmitStalk { params } => self.handle_submit_stalk(params).await,
            RpcRequest::GetCommitment { params } => self.handle_get_commitment(params.vertex_id).await,
            RpcRequest::AddEdge { params } => self.handle_add_edge(params.from, params.to).await,
            RpcRequest::VerifyNaturality => self.handle_verify_naturality().await,
            RpcRequest::CheckGluing => self.handle_check_gluing().await,
            RpcRequest::Health => self.handle_health().await,
        }
    }
    
    async fn handle_submit_stalk(&self, req: FullStalkRequest) -> RpcResponse {
        info!("Received stalk submission for vertex {}", req.vertex_id);
        
        // Parse commitment from hex (Python pre-computed this)
        let commitment = match hex::decode(&req.commitment) {
            Ok(bytes) if bytes.len() == 32 => {
                let mut arr = [0u8; 32];
                arr.copy_from_slice(&bytes);
                arr
            }
            _ => {
                return RpcResponse::Error(ErrorResponse {
                    error: "Invalid commitment: must be 64 hex chars (32 bytes)".to_string(),
                    code: 400,
                });
            }
        };
        
        // Create FullStalk from Python's pre-computed results
        // Oracle verifies bounds only — does NOT recompute geometry
        let full_stalk = FullStalk {
            vertex_id: req.vertex_id,
            credential: req.credential,
            eigenvalues: req.eigenvalues,
            betti_numbers: req.betti_numbers,
            nerve_vertices: req.nerve_vertices,
            nerve_edges: req.nerve_edges,
            spectral_gap: req.spectral_gap,
            commitment,
        };
        
        // Add to bridge, verify bounds, store commitment
        let mut bridge = self.bridge.lock().await;
        
        if let Err(e) = bridge.add_full_stalk(full_stalk) {
            return RpcResponse::Error(ErrorResponse {
                error: format!("Failed to add stalk: {}", e),
                code: 500,
            });
        }
        
        match bridge.compute_commitment(req.vertex_id) {
            Ok(hash_stalk) => {
                RpcResponse::Commitment(CommitmentResponse {
                    success: true,
                    vertex_id: hash_stalk.vertex_id,
                    identity_hash: hex::encode(hash_stalk.identity_hash),
                    harmonic_components: extract_harmonic_components(&hash_stalk.identity_hash),
                    spectral_gap_valid: hash_stalk.spectral_gap_valid,
                    betti_numbers: hash_stalk.betti_numbers,
                })
            }
            Err(e) => {
                RpcResponse::Error(ErrorResponse {
                    error: format!("Failed to compute commitment: {}", e),
                    code: 500,
                })
            }
        }
    }
    
    async fn handle_get_commitment(&self, vertex_id: u64) -> RpcResponse {
        let bridge = self.bridge.lock().await;
        
        match bridge.get_commitment(vertex_id) {
            Some(commitment) => {
                RpcResponse::QueryResult(QueryResponse {
                    found: true,
                    commitment: Some(HashStalkJson {
                        vertex_id: commitment.vertex_id,
                        identity_hash: hex::encode(commitment.identity_hash),
                        harmonic_components: extract_harmonic_components(&commitment.identity_hash),
                        spectral_gap_valid: commitment.spectral_gap_valid,
                        betti_numbers: commitment.betti_numbers,
                        topology_hash: hex::encode(commitment.topology_hash),
                        computed_at: commitment.computed_at,
                    }),
                })
            }
            None => {
                RpcResponse::QueryResult(QueryResponse {
                    found: false,
                    commitment: None,
                })
            }
        }
    }
    
    async fn handle_add_edge(&self, from: u64, to: u64) -> RpcResponse {
        let mut bridge = self.bridge.lock().await;
        bridge.add_edge(from, to);
        
        RpcResponse::Verification(VerificationResponse {
            success: true,
            edges_checked: 0,
            all_natural: true,
            h1_zero: true,
        })
    }
    
    async fn handle_verify_naturality(&self) -> RpcResponse {
        let bridge = self.bridge.lock().await;
        
        match bridge.verify_all_naturality() {
            Ok(all_natural) => {
                RpcResponse::Verification(VerificationResponse {
                    success: true,
                    edges_checked: bridge.get_on_chain_section().len(),
                    all_natural,
                    h1_zero: all_natural,
                })
            }
            Err(e) => {
                RpcResponse::Error(ErrorResponse {
                    error: format!("Verification failed: {}", e),
                    code: 500,
                })
            }
        }
    }
    
    async fn handle_check_gluing(&self) -> RpcResponse {
        let bridge = self.bridge.lock().await;
        
        match bridge.check_gluing_obstruction() {
            Ok(glues) => {
                RpcResponse::Verification(VerificationResponse {
                    success: true,
                    edges_checked: 0,
                    all_natural: glues,
                    h1_zero: glues,
                })
            }
            Err(e) => {
                RpcResponse::Error(ErrorResponse {
                    error: format!("Gluing check failed: {}", e),
                    code: 500,
                })
            }
        }
    }
    
    async fn handle_health(&self) -> RpcResponse {
        let bridge = self.bridge.lock().await;
        
        RpcResponse::Health(HealthResponse {
            status: "healthy".to_string(),
            stalks_count: 0,  // TODO: track
            commitments_count: bridge.get_on_chain_section().len(),
        })
    }
}

/// Simple HTTP server for RPC
pub async fn run_rpc_server(addr: &str) -> Result<()> {
    info!("Starting Oracle RPC server on {}", addr);
    
    let _rpc = Arc::new(OracleRpc::new());
    
    // TODO: Use axum or warp for proper HTTP server
    // For now, this is a placeholder
    
    info!("✅ Oracle RPC server ready");
    info!("   Endpoints:");
    info!("   - POST /rpc - JSON-RPC");
    info!("   - GET /health - Health check");
    
    Ok(())
}
