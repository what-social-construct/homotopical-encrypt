#![allow(dead_code, unused_imports)]
// RPC Server - Axum-based JSON-RPC interface for the node
//
// Endpoints:
//   GET  /health       - Node health check
//   POST /rpc          - JSON-RPC methods
//
// Methods:
//   get_tip            - Get chain tip (height, hash)
//   get_block          - Get block by height
//   get_block_by_hash  - Get block by hash
//   get_balance        - Get account balance
//   get_state          - Get full chain state
//   submit_transaction - Submit new transaction

use anyhow::Result;
use axum::{
    extract::State,
    http::StatusCode,
    response::Json,
    routing::{get, post},
    Router,
};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tokio::sync::RwLock;
use tracing::{debug, error, info};

use crate::storage::{BlockStore, StateStore, KeyImageStore, SheafStore};
use crate::types::{Block, BlockHash};

// =============================================================================
// APPLICATION STATE
// =============================================================================

/// Shared RPC state (references to storage layers)
pub struct RpcState {
    pub block_store: Arc<BlockStore>,
    pub state_store: Arc<StateStore>,
    pub key_image_store: Arc<KeyImageStore>,
    pub sheaf_store: Arc<SheafStore>,
    pub is_validator: bool,
}

impl RpcState {
    pub fn new(
        block_store: Arc<BlockStore>,
        state_store: Arc<StateStore>,
        key_image_store: Arc<KeyImageStore>,
        sheaf_store: Arc<SheafStore>,
        is_validator: bool,
    ) -> Self {
        Self {
            block_store,
            state_store,
            key_image_store,
            sheaf_store,
            is_validator,
        }
    }
}

// =============================================================================
// REQUEST/RESPONSE TYPES
// =============================================================================

/// Health check response
#[derive(Serialize)]
pub struct HealthResponse {
    pub status: String,
    pub version: String,
    pub service: String,
    pub is_validator: bool,
    pub chain_tip: Option<ChainTipInfo>,
}

#[derive(Serialize)]
pub struct ChainTipInfo {
    pub height: u64,
    pub hash: String,
}

/// JSON-RPC request
#[derive(Debug, Deserialize)]
pub struct JsonRpcRequest {
    pub jsonrpc: String,
    pub id: u64,
    pub method: String,
    #[serde(default)]
    pub params: serde_json::Value,
}

/// JSON-RPC response
#[derive(Serialize)]
pub struct JsonRpcResponse {
    pub jsonrpc: String,
    pub id: u64,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub result: Option<serde_json::Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub error: Option<RpcError>,
}

#[derive(Serialize)]
pub struct RpcError {
    pub code: i32,
    pub message: String,
}

// Result types
#[derive(Serialize)]
pub struct TipResponse {
    pub height: u64,
    pub hash: String,
}

#[derive(Serialize)]
pub struct BlockResponse {
    pub height: u64,
    pub hash: String,
    pub parent_hash: String,
    pub timestamp: u64,
    pub spectral_gap_valid: bool,
    pub betti_numbers: (i32, i32, i32),
    pub transaction_count: usize,
}

#[derive(Serialize)]
pub struct BalanceResponse {
    pub account_id: u64,
    pub balance: f64,
}

#[derive(Serialize)]
pub struct StateResponse {
    pub block_height: u64,
    pub total_supply: f64,
    pub account_count: usize,
}

#[derive(Serialize)]
pub struct SubmitTxResponse {
    pub success: bool,
    pub message: String,
}

// =============================================================================
// HANDLERS
// =============================================================================

/// Health check endpoint
async fn health(
    State(state): State<Arc<RwLock<RpcState>>>,
) -> Json<HealthResponse> {
    let state = state.read().await;
    
    let chain_tip = state.block_store.get_chain_tip()
        .ok()
        .flatten()
        .map(|(height, hash)| ChainTipInfo {
            height,
            hash: hash.to_string(),
        });
    
    Json(HealthResponse {
        status: "healthy".to_string(),
        version: env!("CARGO_PKG_VERSION").to_string(),
        service: "hcrypt-node".to_string(),
        is_validator: state.is_validator,
        chain_tip,
    })
}

/// JSON-RPC endpoint
async fn rpc_handler(
    State(state): State<Arc<RwLock<RpcState>>>,
    Json(request): Json<JsonRpcRequest>,
) -> Json<JsonRpcResponse> {
    debug!("RPC request: {} (id={})", request.method, request.id);
    
    let state = state.read().await;
    
    let result = match request.method.as_str() {
        "get_tip" => handle_get_tip(&state).await,
        "get_block" => handle_get_block(&state, &request.params).await,
        "get_block_by_hash" => handle_get_block_by_hash(&state, &request.params).await,
        "get_balance" => handle_get_balance(&state, &request.params).await,
        "get_state" => handle_get_state(&state).await,
        "submit_transaction" => handle_submit_transaction(&state, &request.params).await,
        _ => Err(RpcError {
            code: -32601,
            message: format!("Method not found: {}", request.method),
        }),
    };
    
    match result {
        Ok(value) => Json(JsonRpcResponse {
            jsonrpc: "2.0".to_string(),
            id: request.id,
            result: Some(value),
            error: None,
        }),
        Err(error) => Json(JsonRpcResponse {
            jsonrpc: "2.0".to_string(),
            id: request.id,
            result: None,
            error: Some(error),
        }),
    }
}

// =============================================================================
// RPC METHOD HANDLERS
// =============================================================================

async fn handle_get_tip(state: &RpcState) -> Result<serde_json::Value, RpcError> {
    match state.block_store.get_chain_tip() {
        Ok(Some((height, hash))) => {
            Ok(serde_json::to_value(TipResponse {
                height,
                hash: hash.to_string(),
            }).unwrap())
        }
        Ok(None) => {
            Ok(serde_json::json!({
                "height": 0,
                "hash": null,
                "message": "No blocks yet - genesis needed"
            }))
        }
        Err(e) => Err(RpcError {
            code: -32000,
            message: format!("Failed to get chain tip: {}", e),
        }),
    }
}

async fn handle_get_block(
    state: &RpcState,
    params: &serde_json::Value,
) -> Result<serde_json::Value, RpcError> {
    let height = params.get("height")
        .and_then(|v| v.as_u64())
        .ok_or_else(|| RpcError {
            code: -32602,
            message: "Missing or invalid 'height' parameter".to_string(),
        })?;
    
    match state.block_store.load_block_by_height(height) {
        Ok(Some(block)) => Ok(block_to_json(&block)),
        Ok(None) => Err(RpcError {
            code: -32001,
            message: format!("Block not found at height {}", height),
        }),
        Err(e) => Err(RpcError {
            code: -32000,
            message: format!("Failed to load block: {}", e),
        }),
    }
}

async fn handle_get_block_by_hash(
    state: &RpcState,
    params: &serde_json::Value,
) -> Result<serde_json::Value, RpcError> {
    let hash_str = params.get("hash")
        .and_then(|v| v.as_str())
        .ok_or_else(|| RpcError {
            code: -32602,
            message: "Missing or invalid 'hash' parameter".to_string(),
        })?;
    
    // Parse hex hash
    let hash_bytes = hex::decode(hash_str).map_err(|_| RpcError {
        code: -32602,
        message: "Invalid hash format (expected hex)".to_string(),
    })?;
    
    if hash_bytes.len() != 32 {
        return Err(RpcError {
            code: -32602,
            message: "Hash must be 32 bytes".to_string(),
        });
    }
    
    let mut hash_arr = [0u8; 32];
    hash_arr.copy_from_slice(&hash_bytes);
    let hash = BlockHash(hash_arr);
    
    match state.block_store.load_block_by_hash(&hash) {
        Ok(Some(block)) => Ok(block_to_json(&block)),
        Ok(None) => Err(RpcError {
            code: -32001,
            message: format!("Block not found with hash {}", hash_str),
        }),
        Err(e) => Err(RpcError {
            code: -32000,
            message: format!("Failed to load block: {}", e),
        }),
    }
}

async fn handle_get_balance(
    state: &RpcState,
    params: &serde_json::Value,
) -> Result<serde_json::Value, RpcError> {
    let account_id = params.get("account_id")
        .and_then(|v| v.as_u64())
        .ok_or_else(|| RpcError {
            code: -32602,
            message: "Missing or invalid 'account_id' parameter".to_string(),
        })?;
    
    match state.state_store.get_balance(account_id) {
        Ok(balance) => Ok(serde_json::to_value(BalanceResponse {
            account_id,
            balance,
        }).unwrap()),
        Err(e) => Err(RpcError {
            code: -32000,
            message: format!("Failed to get balance: {}", e),
        }),
    }
}

async fn handle_get_state(state: &RpcState) -> Result<serde_json::Value, RpcError> {
    match state.state_store.load_state() {
        Ok(global_state) => Ok(serde_json::to_value(StateResponse {
            block_height: global_state.block_height,
            total_supply: global_state.total_supply,
            account_count: global_state.accounts.len(),
        }).unwrap()),
        Err(e) => Err(RpcError {
            code: -32000,
            message: format!("Failed to load state: {}", e),
        }),
    }
}

async fn handle_submit_transaction(
    _state: &RpcState,
    params: &serde_json::Value,
) -> Result<serde_json::Value, RpcError> {
    // For now, just accept the transaction and return a stub response
    // Full implementation requires mempool, validation, etc.
    
    let tx_data = params.get("data")
        .and_then(|v| v.as_str())
        .ok_or_else(|| RpcError {
            code: -32602,
            message: "Missing or invalid 'data' parameter".to_string(),
        })?;
    
    // Decode hex transaction data
    let _tx_bytes = hex::decode(tx_data).map_err(|_| RpcError {
        code: -32602,
        message: "Invalid transaction data (expected hex)".to_string(),
    })?;
    
    // TODO: Add to mempool, validate, etc.
    info!("Received transaction submission ({} bytes)", tx_data.len() / 2);
    
    Ok(serde_json::to_value(SubmitTxResponse {
        success: true,
        message: "Transaction accepted (mempool pending implementation)".to_string(),
    }).unwrap())
}

// =============================================================================
// HELPERS
// =============================================================================

fn block_to_json(block: &Block) -> serde_json::Value {
    serde_json::to_value(BlockResponse {
        height: block.header.height,
        hash: block.hash().to_string(),
        parent_hash: block.header.parent_hash.to_string(),
        timestamp: block.header.timestamp,
        spectral_gap_valid: block.header.spectral_proof.fingerprint.spectral_gap_valid,
        betti_numbers: block.header.spectral_proof.fingerprint.betti_numbers,
        transaction_count: block.transactions.len(),
    }).unwrap()
}

// =============================================================================
// SERVER
// =============================================================================

/// Build the RPC router
pub fn build_router(state: Arc<RwLock<RpcState>>) -> Router {
    Router::new()
        .route("/health", get(health))
        .route("/rpc", post(rpc_handler))
        .with_state(state)
}

/// Run the RPC server
pub async fn run_rpc_server(
    addr: &str,
    block_store: Arc<BlockStore>,
    state_store: Arc<StateStore>,
    key_image_store: Arc<KeyImageStore>,
    sheaf_store: Arc<SheafStore>,
    is_validator: bool,
) -> Result<()> {
    let rpc_state = Arc::new(RwLock::new(RpcState::new(
        block_store,
        state_store,
        key_image_store,
        sheaf_store,
        is_validator,
    )));
    
    let app = build_router(rpc_state);
    
    let listener = tokio::net::TcpListener::bind(addr).await?;
    
    info!("🌐 RPC server listening on http://{}", addr);
    info!("   Endpoints:");
    info!("   - GET  /health  - Node health");
    info!("   - POST /rpc     - JSON-RPC");
    info!("   Methods: get_tip, get_block, get_block_by_hash, get_balance, get_state, submit_transaction");
    
    axum::serve(listener, app).await?;
    
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_json_rpc_request_parse() {
        let json = r#"{
            "jsonrpc": "2.0",
            "id": 1,
            "method": "get_tip",
            "params": {}
        }"#;
        
        let request: JsonRpcRequest = serde_json::from_str(json).unwrap();
        assert_eq!(request.method, "get_tip");
        assert_eq!(request.id, 1);
    }
}
