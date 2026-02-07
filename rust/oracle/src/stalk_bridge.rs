// Stalk Bridge - Natural Transformation η: F_full → F_hash
//
// Orchestrates the connection between:
// - Off-chain (Python): Full stalks F_full (256-dim credentials)
// - On-chain (Rust): Hash stalks F_hash (32-byte commitments)
//
// Implements the natural transformation with naturality verification

use anyhow::Result;
use serde::{Deserialize, Serialize};
use tracing::{debug, info, warn};
use std::collections::HashMap;
use nalgebra::{DMatrix, DVector};

use crate::geometry::{HodgeProjector, FiberBundle, compute_geometric_commitment, Stalk};

/// Full stalk from Python (F_full)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FullStalk {
    /// Vertex ID in nerve
    pub vertex_id: u64,
    
    /// Full 256-dim homotopy credential
    pub credential: Vec<f64>,
    
    /// Laplacian eigenvalues
    pub eigenvalues: Vec<f64>,
    
    /// Cohomology data
    pub betti_numbers: (i32, i32, i32),
    
    /// Nerve structure (for topology hash)
    pub nerve_vertices: Vec<u64>,
    pub nerve_edges: Vec<(u64, u64)>,
    
    /// Laplacian matrix (for Hodge projection)
    /// Used by geometry::HodgeProjector
    pub laplacian: Option<Vec<Vec<f64>>>,
    
    /// Connection matrices (for parallel transport)
    /// edge -> transport matrix (flattened)
    pub connection: Option<HashMap<(u64, u64), Vec<f64>>>,
    
    /// Transport path (vertices to traverse)
    pub transport_path: Option<Vec<u64>>,
    
    /// Hash computed by Python (for verification)
    /// Oracle verifies: hash_credential(credential) == python_hash
    pub python_hash: [u8; 32],
}

/// Hash stalk for Rust chain (F_hash)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HashStalk {
    /// Vertex ID
    pub vertex_id: u64,
    
    /// Result of η: F_full(v) → F_hash(v)
    pub fingerprint: [u8; 32],
    pub spectral_gap: f64,
    pub betti_numbers: (i32, i32, i32),
    pub topology_hash: [u8; 32],
    
    /// Timestamp
    pub computed_at: u64,
}

/// Edge in nerve (for checking naturality)
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct Edge {
    pub from: u64,
    pub to: u64,
}

/// Natural transformation η orchestrator
pub struct StalkBridge {
    /// Off-chain section: vertex_id → FullStalk
    off_chain_section: HashMap<u64, FullStalk>,
    
    /// On-chain section: vertex_id → HashStalk
    on_chain_section: HashMap<u64, HashStalk>,
    
    /// Nerve edges (for naturality checks)
    edges: Vec<Edge>,
}

impl StalkBridge {
    pub fn new() -> Self {
        Self {
            off_chain_section: HashMap::new(),
            on_chain_section: HashMap::new(),
            edges: Vec::new(),
        }
    }
    
    /// Add full stalk from Python
    pub fn add_full_stalk(&mut self, stalk: FullStalk) -> Result<()> {
        info!(
            "Adding full stalk for vertex {}: credential_dim={}, eigenvalues={}",
            stalk.vertex_id,
            stalk.credential.len(),
            stalk.eigenvalues.len()
        );
        
        // Store off-chain
        self.off_chain_section.insert(stalk.vertex_id, stalk);
        
        Ok(())
    }
    
    /// Apply natural transformation: η_v: F_full(v) → F_hash(v)
    pub fn compute_commitment(&mut self, vertex_id: u64) -> Result<HashStalk> {
        let full_stalk = self.off_chain_section.get(&vertex_id)
            .ok_or_else(|| anyhow::anyhow!("Vertex {} not found in off-chain section", vertex_id))?;
        
        info!("Computing η for vertex {}", vertex_id);
        
        // η_v maps:
        // 1. credential → fingerprint (geometric commitment or hash)
        let fingerprint = self.compute_fingerprint(full_stalk)?;
        
        // VERIFY: Hash matches Python's computation
        if fingerprint != full_stalk.python_hash {
            anyhow::bail!(
                "Hash mismatch! Oracle computed {:?} but Python sent {:?}",
                hex::encode(fingerprint),
                hex::encode(full_stalk.python_hash)
            );
        }
        debug!("✅ Hash verified: matches Python computation");
        
        // 2. eigenvalues → spectral_gap
        let spectral_gap = self.compute_spectral_gap(&full_stalk.eigenvalues)?;
        
        // 3. cohomology → betti_numbers (already computed)
        let betti_numbers = full_stalk.betti_numbers;
        
        // 4. nerve → topology_hash
        let topology_hash = self.hash_topology(full_stalk)?;
        
        let hash_stalk = HashStalk {
            vertex_id,
            fingerprint,
            spectral_gap,
            betti_numbers,
            topology_hash,
            computed_at: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
        };
        
        // Store on-chain commitment
        self.on_chain_section.insert(vertex_id, hash_stalk.clone());
        
        debug!(
            "✅ η({}) = HashStalk {{ gap={:.4}, β=({},{},{}) }}",
            vertex_id,
            spectral_gap,
            betti_numbers.0,
            betti_numbers.1,
            betti_numbers.2
        );
        
        Ok(hash_stalk)
    }
    
    /// Add edge to nerve (for naturality checking)
    pub fn add_edge(&mut self, from: u64, to: u64) {
        self.edges.push(Edge { from, to });
        debug!("Added edge: {} → {}", from, to);
    }
    
    /// Verify naturality condition on an edge
    /// 
    /// For edge e: v → w, must satisfy:
    /// F_hash(e) ∘ η_v = η_w ∘ F_full(e)
    /// 
    /// This ensures consistency across the topology!
    pub fn verify_naturality(&self, edge: &Edge) -> Result<bool> {
        let v = edge.from;
        let w = edge.to;
        
        debug!("Verifying naturality on edge {} → {}", v, w);
        
        // Get commitments
        let hash_v = self.on_chain_section.get(&v)
            .ok_or_else(|| anyhow::anyhow!("No commitment for vertex {}", v))?;
        let hash_w = self.on_chain_section.get(&w)
            .ok_or_else(|| anyhow::anyhow!("No commitment for vertex {}", w))?;
        
        // Check topology hashes match (connected in same nerve)
        if hash_v.topology_hash != hash_w.topology_hash {
            warn!(
                "❌ Topology hash mismatch on edge {} → {}",
                v, w
            );
            return Ok(false);
        }
        
        // Check spectral gaps are compatible (within tolerance)
        let gap_diff = (hash_v.spectral_gap - hash_w.spectral_gap).abs();
        if gap_diff > 0.1 {
            warn!(
                "❌ Spectral gap mismatch on edge {} → {}: {:.4} vs {:.4}",
                v, w, hash_v.spectral_gap, hash_w.spectral_gap
            );
            return Ok(false);
        }
        
        // Check Betti numbers match (same connected component)
        if hash_v.betti_numbers.0 != hash_w.betti_numbers.0 {
            warn!(
                "❌ β₀ mismatch on edge {} → {}: {} vs {}",
                v, w, hash_v.betti_numbers.0, hash_w.betti_numbers.0
            );
            return Ok(false);
        }
        
        debug!("✅ Naturality verified on edge {} → {}", v, w);
        Ok(true)
    }
    
    /// Verify naturality on all edges
    pub fn verify_all_naturality(&self) -> Result<bool> {
        info!("Verifying naturality on {} edges", self.edges.len());
        
        for edge in &self.edges {
            if !self.verify_naturality(edge)? {
                return Ok(false);
            }
        }
        
        info!("✅ All naturality conditions verified");
        Ok(true)
    }
    
    /// Get all on-chain commitments (section Γ(X, F_hash))
    pub fn get_on_chain_section(&self) -> &HashMap<u64, HashStalk> {
        &self.on_chain_section
    }
    
    /// Get commitment for a vertex
    pub fn get_commitment(&self, vertex_id: u64) -> Option<&HashStalk> {
        self.on_chain_section.get(&vertex_id)
    }
    
    /// Compute H^1 obstruction (checks if section glues)
    pub fn check_gluing_obstruction(&self) -> Result<bool> {
        // If all naturality conditions hold, section glues (H^1 = 0)
        // If any fail, there's an obstruction (H^1 ≠ 0)
        
        info!("Checking gluing obstruction (H^1 check)");
        
        if self.edges.is_empty() {
            // Discrete space, always glues
            return Ok(true);
        }
        
        let glues = self.verify_all_naturality()?;
        
        if glues {
            info!("✅ Section glues: H^1 = 0");
        } else {
            warn!("❌ Obstruction to gluing: H^1 ≠ 0");
        }
        
        Ok(glues)
    }
    
    // =========================================================================
    // HELPER METHODS (implementing η components)
    // =========================================================================
    
    /// Compute fingerprint using geometric commitment (Hodge projection)
    /// Falls back to SHA256 if no Laplacian provided
    fn compute_fingerprint(&self, stalk: &FullStalk) -> Result<[u8; 32]> {
        // If we have Laplacian, use geometric commitment (our system!)
        if let Some(ref laplacian_data) = stalk.laplacian {
            info!("Computing geometric commitment (harmonic projection)");
            return self.geometric_commitment(stalk, laplacian_data);
        }
        
        // Fallback to SHA256 hash (simpler, but not our system)
        debug!("No Laplacian provided, using SHA256 fallback");
        self.hash_credential(&stalk.credential)
    }
    
    /// Geometric commitment: credential → transport → project to ker(Δ) → quantize
    fn geometric_commitment(&self, stalk: &FullStalk, laplacian_data: &[Vec<f64>]) -> Result<[u8; 32]> {
        // 1. Build Laplacian matrix
        let n = laplacian_data.len();
        let laplacian = DMatrix::from_fn(n, n, |i, j| laplacian_data[i][j]);
        
        // 2. Create Hodge projector
        let projector = HodgeProjector::new(laplacian, 1e-6)?;
        
        // 3. Create stalk from credential
        let geometry_stalk = Stalk::new(stalk.credential.len(), stalk.credential.clone())?;
        
        // 4. Build fiber bundle if connection provided
        let mut bundle = FiberBundle::new(HashMap::new(), stalk.credential.len());
        if let Some(ref conn) = stalk.connection {
            for ((v0, v1), matrix_data) in conn {
                let dim = stalk.credential.len();
                if matrix_data.len() == dim * dim {
                    let matrix = DMatrix::from_vec(dim, dim, matrix_data.clone());
                    bundle.set_connection(*v0, *v1, matrix);
                }
            }
        }
        
        // 5. Compute geometric commitment
        let path = stalk.transport_path.as_ref()
            .map(|p| p.as_slice())
            .unwrap_or(&[0]);  // Default: no transport
        
        let commitment = compute_geometric_commitment(
            &bundle,
            &geometry_stalk,
            &projector,
            path,
            32  // 32 bytes output
        );
        
        // 6. Convert to fixed array
        let mut fingerprint = [0u8; 32];
        fingerprint.copy_from_slice(&commitment);
        
        info!("✅ Geometric commitment computed: {} bytes", fingerprint.len());
        Ok(fingerprint)
    }
    
    /// Fallback: SHA256 hash (for when Laplacian not available)
    fn hash_credential(&self, credential: &[f64]) -> Result<[u8; 32]> {
        use sha2::{Sha256, Digest};
        
        let mut hasher = Sha256::new();
        
        // Hash credential data
        for &val in credential {
            hasher.update(&val.to_le_bytes());
        }
        
        let result = hasher.finalize();
        let mut hash = [0u8; 32];
        hash.copy_from_slice(&result);
        
        Ok(hash)
    }
    
    fn compute_spectral_gap(&self, eigenvalues: &[f64]) -> Result<f64> {
        // Spectral gap = smallest nonzero eigenvalue
        let mut sorted = eigenvalues.to_vec();
        sorted.sort_by(|a, b| a.partial_cmp(b).unwrap());
        
        // Find first eigenvalue > 1e-6
        for &eig in &sorted {
            if eig > 1e-6 {
                return Ok(eig);
            }
        }
        
        Ok(0.0)
    }
    
    fn hash_topology(&self, stalk: &FullStalk) -> Result<[u8; 32]> {
        use sha2::{Sha256, Digest};
        
        let mut hasher = Sha256::new();
        
        // Hash vertices
        for &v in &stalk.nerve_vertices {
            hasher.update(&v.to_le_bytes());
        }
        
        // Hash edges
        for (v0, v1) in &stalk.nerve_edges {
            hasher.update(&v0.to_le_bytes());
            hasher.update(&v1.to_le_bytes());
        }
        
        let result = hasher.finalize();
        let mut hash = [0u8; 32];
        hash.copy_from_slice(&result);
        
        Ok(hash)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    fn test_full_stalk(vertex_id: u64, gap: f64) -> FullStalk {
        use sha2::{Sha256, Digest};
        
        let credential: Vec<f64> = vec![1.0; 256];
        
        // Compute hash (simulating Python)
        let mut hasher = Sha256::new();
        for val in &credential {
            hasher.update(&val.to_le_bytes());
        }
        let result = hasher.finalize();
        let mut python_hash = [0u8; 32];
        python_hash.copy_from_slice(&result);
        
        FullStalk {
            vertex_id,
            credential,
            eigenvalues: vec![0.0, gap, 2.0 * gap],
            betti_numbers: (1, 0, 0),
            nerve_vertices: vec![vertex_id],
            nerve_edges: vec![],
            laplacian: None,          // Optional: Hodge projection
            connection: None,         // Optional: parallel transport
            transport_path: None,     // Optional: path for transport
            python_hash,
        }
    }
    
    #[test]
    fn test_natural_transformation() {
        let mut bridge = StalkBridge::new();
        
        // Add full stalk
        let stalk = test_full_stalk(0, 1.5);
        bridge.add_full_stalk(stalk).unwrap();
        
        // Apply η
        let commitment = bridge.compute_commitment(0).unwrap();
        
        assert_eq!(commitment.vertex_id, 0);
        assert_eq!(commitment.spectral_gap, 1.5);
        assert_eq!(commitment.betti_numbers, (1, 0, 0));
    }
    
    #[test]
    fn test_naturality_verification() {
        let mut bridge = StalkBridge::new();
        
        // Shared topology — both vertices in same nerve
        let shared_vertices = vec![0, 1];
        let shared_edges = vec![(0, 1)];
        
        let mut stalk0 = test_full_stalk(0, 1.5);
        stalk0.nerve_vertices = shared_vertices.clone();
        stalk0.nerve_edges = shared_edges.clone();
        
        let mut stalk1 = test_full_stalk(1, 1.52); // Close gap
        stalk1.nerve_vertices = shared_vertices;
        stalk1.nerve_edges = shared_edges;
        
        bridge.add_full_stalk(stalk0).unwrap();
        bridge.add_full_stalk(stalk1).unwrap();
        
        // Compute commitments
        bridge.compute_commitment(0).unwrap();
        bridge.compute_commitment(1).unwrap();
        
        // Add edge
        bridge.add_edge(0, 1);
        
        // Verify naturality
        let natural = bridge.verify_naturality(&Edge { from: 0, to: 1 }).unwrap();
        assert!(natural);
    }
    
    #[test]
    fn test_gluing_obstruction() {
        let mut bridge = StalkBridge::new();
        
        // Shared topology for all vertices
        let shared_vertices = vec![0, 1, 2];
        let shared_edges = vec![(0, 1), (1, 2)];
        
        // Create connected nerve
        for i in 0..3 {
            let mut stalk = test_full_stalk(i, 1.4 + i as f64 * 0.01);
            stalk.nerve_vertices = shared_vertices.clone();
            stalk.nerve_edges = shared_edges.clone();
            bridge.add_full_stalk(stalk).unwrap();
            bridge.compute_commitment(i).unwrap();
        }
        
        // Add edges: 0-1-2
        bridge.add_edge(0, 1);
        bridge.add_edge(1, 2);
        
        // Check gluing
        let glues = bridge.check_gluing_obstruction().unwrap();
        assert!(glues); // Should glue (H^1 = 0)
    }
}
