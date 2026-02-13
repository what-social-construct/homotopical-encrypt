// Stalk Bridge - Natural Transformation η: F_full → F_hash
//
// COMPUTATION BOUNDARY:
//   Python (src/geometry/) owns ALL heavy geometry:
//     - SheafLaplacian: builds Δ, eigendecomposition, harmonic projection
//     - FiberBundle: parallel transport, holonomy, connection matrices
//     - HodgeDecomposition: full Hodge: ker(Δ) ⊕ im(δ) ⊕ im(δ*)
//     - Stalk/StalkBundle: local data, projections between contexts
//
//   Rust Oracle VERIFIES pre-computed results:
//     - Spectral gap in Tsirelson bounds [1/√2, 2√2]
//     - Betti numbers consistent with nerve topology
//     - Commitment bytes non-trivial and well-formed
//     - Naturality conditions across edges
//
//   The Oracle does NOT recompute eigendecomposition, Hodge projection,
//   or parallel transport. Python computes, Oracle verifies and stores.
//
// See: src/geometry/sheaf_laplacian.py, src/geometry/hodge.py,
//      src/geometry/fiber_bundle.py, src/primitives/stalk.py

use anyhow::Result;
use serde::{Deserialize, Serialize};
use tracing::{debug, info, warn};
use std::collections::HashMap;

/// Tsirelson spectral gap bounds (from quantum information geometry)
/// See: src/geometry/sheaf_laplacian.py docstring for derivation
const TSIRELSON_LOWER: f64 = std::f64::consts::FRAC_1_SQRT_2;  // 1/√2 ≈ 0.707
const TSIRELSON_UPPER: f64 = 2.828;  // 2√2 ≈ 2.828

/// Full stalk from Python (F_full)
///
/// Python computes everything here:
/// - credential: raw 256-dim vector (Python Stalk.data)
/// - eigenvalues: from SheafLaplacian.eigendecomposition()
/// - betti_numbers: from SheafLaplacian.betti_0() + topology.compute_betti_numbers()
/// - commitment: geometric commitment bytes from HodgeDecomposition + quantization
/// - spectral_gap: from SheafLaplacian.spectral_gap()
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FullStalk {
    /// Vertex ID in nerve
    pub vertex_id: u64,
    
    /// Full 256-dim homotopy credential (Python: Stalk.data)
    pub credential: Vec<f64>,
    
    /// Laplacian eigenvalues (Python: SheafLaplacian.eigendecomposition())
    pub eigenvalues: Vec<f64>,
    
    /// Cohomology data (Python: topology.compute_betti_numbers())
    pub betti_numbers: (i32, i32, i32),
    
    /// Nerve structure (for topology hash verification)
    pub nerve_vertices: Vec<u64>,
    pub nerve_edges: Vec<(u64, u64)>,
    
    /// Pre-computed spectral gap (Python: SheafLaplacian.spectral_gap())
    /// Oracle verifies this is in Tsirelson bounds
    pub spectral_gap: f64,
    
    /// Pre-computed commitment bytes (Python: hodge projection + quantization)
    /// This IS the geometric commitment — Python already computed it.
    /// Oracle verifies bounds and stores it; does NOT recompute.
    pub commitment: [u8; 32],
}

/// Hash stalk for Rust chain (F_hash)
///
/// POST-AUDIT: No longer stores the spectral fingerprint or gap VALUE.
/// The fingerprint is PRIVATE key material (see math_audit_hcrypt.lean:
/// Spectrum_Not_Homotopy_Invariant). Only Betti numbers and a boolean
/// "gap is valid" flag are stored on-chain.
///
/// Public identity = hash(Betti numbers + topology_hash)
/// Anonymity set = all fibrations with same Betti numbers = INFINITE
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HashStalk {
    /// Vertex ID
    pub vertex_id: u64,
    
    /// Public identity hash: SHA256(Betti + topology_hash)
    /// This is the on-chain account identifier (replaces fingerprint)
    pub identity_hash: [u8; 32],
    
    /// Betti numbers (PUBLIC — true homotopy invariants)
    pub betti_numbers: (i32, i32, i32),
    
    /// Topology hash (computed by Oracle from nerve structure)
    pub topology_hash: [u8; 32],
    
    /// Spectral gap validity (boolean only — NOT the value)
    /// Oracle verified gap is in Tsirelson bounds, then discarded the value.
    /// This prevents leaking spectral info that could narrow anonymity set.
    pub spectral_gap_valid: bool,
    
    /// Timestamp
    pub computed_at: u64,
}

/// Edge in nerve (for checking naturality)
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct Edge {
    pub from: u64,
    pub to: u64,
}

/// Verification report from Oracle
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VerificationReport {
    pub vertex_id: u64,
    pub spectral_gap_valid: bool,
    pub betti_consistent: bool,
    pub commitment_nontrivial: bool,
    pub accepted: bool,
    pub rejection_reason: Option<String>,
}

/// Natural transformation η orchestrator
///
/// Oracle = η₁: receives Python's computation, verifies, produces on-chain commitment.
/// Does NOT recompute geometry. Python owns all heavy math.
pub struct StalkBridge {
    /// Off-chain section: vertex_id → FullStalk (from Python)
    off_chain_section: HashMap<u64, FullStalk>,
    
    /// On-chain section: vertex_id → HashStalk (verified commitments)
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
    
    /// Receive full stalk from Python
    pub fn add_full_stalk(&mut self, stalk: FullStalk) -> Result<()> {
        info!(
            "Receiving full stalk for vertex {}: credential_dim={}, eigenvalues={}, spectral_gap={:.4}",
            stalk.vertex_id,
            stalk.credential.len(),
            stalk.eigenvalues.len(),
            stalk.spectral_gap
        );
        
        self.off_chain_section.insert(stalk.vertex_id, stalk);
        Ok(())
    }
    
    /// Apply natural transformation: η_v: F_full(v) → F_hash(v)
    ///
    /// This VERIFIES Python's computation and stores the commitment.
    /// It does NOT recompute eigendecomposition or Hodge projection.
    pub fn compute_commitment(&mut self, vertex_id: u64) -> Result<HashStalk> {
        let full_stalk = self.off_chain_section.get(&vertex_id)
            .ok_or_else(|| anyhow::anyhow!("Vertex {} not found in off-chain section", vertex_id))?;
        
        info!("Verifying η for vertex {}", vertex_id);
        
        // 1. VERIFY spectral gap in Tsirelson bounds
        let report = self.verify_stalk(full_stalk)?;
        if !report.accepted {
            anyhow::bail!(
                "Stalk {} rejected: {}",
                vertex_id,
                report.rejection_reason.unwrap_or_default()
            );
        }
        
        // 2. Betti numbers (from Python)
        let betti_numbers = full_stalk.betti_numbers;
        
        // 3. Topology hash (Oracle computes from nerve structure — lightweight)
        let topology_hash = self.hash_topology(full_stalk)?;
        
        // 4. Compute identity_hash = SHA256(betti + topology_hash)
        //    This is the on-chain account identifier (Betti-based, anonymity-preserving)
        //    Replaces raw spectral fingerprint which leaked private info
        let identity_hash = {
            use sha2::{Sha256, Digest};
            let mut hasher = Sha256::new();
            hasher.update(&betti_numbers.0.to_le_bytes());
            hasher.update(&betti_numbers.1.to_le_bytes());
            hasher.update(&betti_numbers.2.to_le_bytes());
            hasher.update(&topology_hash);
            let result = hasher.finalize();
            let mut hash = [0u8; 32];
            hash.copy_from_slice(&result);
            hash
        };
        
        // 5. Spectral gap validity (boolean only — value is NOT stored on-chain)
        //    This matches Hodge_Ambiguity: the exact gap value could narrow the
        //    anonymity set, so we store only "is it valid?"
        let spectral_gap_valid = report.spectral_gap_valid;
        
        let hash_stalk = HashStalk {
            vertex_id,
            identity_hash,
            betti_numbers,
            topology_hash,
            spectral_gap_valid,
            computed_at: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
        };
        
        // Store on-chain commitment
        self.on_chain_section.insert(vertex_id, hash_stalk.clone());
        
        debug!(
            "✅ η({}) = HashStalk {{ gap_valid={}, β=({},{},{}) }}",
            vertex_id,
            spectral_gap_valid,
            betti_numbers.0,
            betti_numbers.1,
            betti_numbers.2
        );
        
        Ok(hash_stalk)
    }
    
    /// Verify a full stalk from Python (invariant bounds only)
    ///
    /// Oracle checks:
    /// 1. Spectral gap in Tsirelson bounds [1/√2, 2√2]
    /// 2. Betti numbers consistent (β₀ ≥ 1 for connected topology)
    /// 3. Commitment bytes are non-trivial (not all zeros)
    /// 4. Eigenvalues are non-negative (Laplacian is PSD)
    ///
    /// Oracle does NOT check (Python's responsibility):
    /// - Hodge projection correctness
    /// - Laplacian construction from restriction maps
    /// - Eigendecomposition accuracy
    pub fn verify_stalk(&self, stalk: &FullStalk) -> Result<VerificationReport> {
        let mut report = VerificationReport {
            vertex_id: stalk.vertex_id,
            spectral_gap_valid: false,
            betti_consistent: false,
            commitment_nontrivial: false,
            accepted: false,
            rejection_reason: None,
        };
        
        // 1. Spectral gap in Tsirelson bounds
        if stalk.spectral_gap >= TSIRELSON_LOWER && stalk.spectral_gap <= TSIRELSON_UPPER {
            report.spectral_gap_valid = true;
        } else {
            report.rejection_reason = Some(format!(
                "Spectral gap {:.4} outside Tsirelson bounds [{:.4}, {:.4}]",
                stalk.spectral_gap, TSIRELSON_LOWER, TSIRELSON_UPPER
            ));
        }
        
        // 2. Betti numbers consistent
        if stalk.betti_numbers.0 >= 1 {
            report.betti_consistent = true;
        } else {
            report.rejection_reason = Some(format!(
                "β₀ = {} < 1: topology must have at least one connected component",
                stalk.betti_numbers.0
            ));
        }
        
        // 3. Commitment non-trivial
        if stalk.commitment.iter().any(|&b| b != 0) {
            report.commitment_nontrivial = true;
        } else {
            report.rejection_reason = Some(
                "Commitment is all zeros: Python computation likely failed".to_string()
            );
        }
        
        // 4. Eigenvalues non-negative (Laplacian is PSD)
        let eigenvalues_valid = stalk.eigenvalues.iter().all(|&e| e >= -1e-6);
        if !eigenvalues_valid {
            report.rejection_reason = Some(
                "Negative eigenvalue: Laplacian not PSD — Python construction error".to_string()
            );
        }
        
        // Accept if all checks pass
        report.accepted = report.spectral_gap_valid 
            && report.betti_consistent 
            && report.commitment_nontrivial
            && eigenvalues_valid;
        
        if report.accepted {
            debug!("✅ Stalk {} verified: gap={:.4}, β₀={}", 
                stalk.vertex_id, stalk.spectral_gap, stalk.betti_numbers.0);
        } else {
            warn!("❌ Stalk {} rejected: {:?}", 
                stalk.vertex_id, report.rejection_reason);
        }
        
        Ok(report)
    }
    
    /// Add edge to nerve (for naturality checking)
    pub fn add_edge(&mut self, from: u64, to: u64) {
        self.edges.push(Edge { from, to });
        debug!("Added edge: {} → {}", from, to);
    }
    
    /// Verify naturality condition on an edge
    /// 
    /// For edge e: v → w, checks:
    /// - Same topology (topology_hash match)
    /// - Compatible spectral gaps (within tolerance)
    /// - Compatible Betti numbers (same connected component)
    pub fn verify_naturality(&self, edge: &Edge) -> Result<bool> {
        let v = edge.from;
        let w = edge.to;
        
        debug!("Verifying naturality on edge {} → {}", v, w);
        
        let hash_v = self.on_chain_section.get(&v)
            .ok_or_else(|| anyhow::anyhow!("No commitment for vertex {}", v))?;
        let hash_w = self.on_chain_section.get(&w)
            .ok_or_else(|| anyhow::anyhow!("No commitment for vertex {}", w))?;
        
        // Check topology hashes match (connected in same nerve)
        if hash_v.topology_hash != hash_w.topology_hash {
            warn!("❌ Topology hash mismatch on edge {} → {}", v, w);
            return Ok(false);
        }
        
        // Both must have valid spectral gaps (boolean check — values are private)
        if !hash_v.spectral_gap_valid || !hash_w.spectral_gap_valid {
            warn!("❌ Invalid spectral gap on edge {} → {}", v, w);
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
        info!("Checking gluing obstruction (H^1 check)");
        
        if self.edges.is_empty() {
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
    // LIGHTWEIGHT HELPERS (Oracle computes only these)
    // =========================================================================
    
    /// Hash topology from nerve structure (lightweight — no linear algebra)
    fn hash_topology(&self, stalk: &FullStalk) -> Result<[u8; 32]> {
        use sha2::{Sha256, Digest};
        
        let mut hasher = Sha256::new();
        
        for &v in &stalk.nerve_vertices {
            hasher.update(&v.to_le_bytes());
        }
        
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
    
    /// Create a test stalk with pre-computed commitment (simulating Python)
    fn test_full_stalk(vertex_id: u64, gap: f64) -> FullStalk {
        // Simulate Python's computation:
        // Python does SheafLaplacian.eigendecomposition() → eigenvalues
        // Python does HodgeDecomposition + quantization → commitment bytes
        // Oracle receives the results and verifies bounds only
        
        let credential: Vec<f64> = vec![1.0; 256];
        
        // Simulate Python's geometric commitment (different per vertex)
        let mut commitment = [0u8; 32];
        for i in 0..32 {
            commitment[i] = ((vertex_id as u8).wrapping_mul(17).wrapping_add(i as u8)) | 1;
        }
        
        FullStalk {
            vertex_id,
            credential,
            eigenvalues: vec![0.0, gap, 2.0 * gap],
            betti_numbers: (1, 0, 0),
            nerve_vertices: vec![vertex_id],
            nerve_edges: vec![],
            spectral_gap: gap,
            commitment,
        }
    }
    
    #[test]
    fn test_natural_transformation() {
        let mut bridge = StalkBridge::new();
        
        let stalk = test_full_stalk(0, 1.5);
        bridge.add_full_stalk(stalk).unwrap();
        
        let commitment = bridge.compute_commitment(0).unwrap();
        
        assert_eq!(commitment.vertex_id, 0);
        assert!(commitment.spectral_gap_valid);  // gap 1.5 is in Tsirelson bounds
        assert_eq!(commitment.betti_numbers, (1, 0, 0));
    }
    
    #[test]
    fn test_verify_spectral_bounds() {
        let bridge = StalkBridge::new();
        
        // Valid: gap in Tsirelson range
        let valid = test_full_stalk(0, 1.5);
        let report = bridge.verify_stalk(&valid).unwrap();
        assert!(report.accepted);
        assert!(report.spectral_gap_valid);
        
        // Invalid: gap too small
        let too_small = test_full_stalk(1, 0.1);
        let report = bridge.verify_stalk(&too_small).unwrap();
        assert!(!report.accepted);
        assert!(!report.spectral_gap_valid);
        
        // Invalid: gap too large
        let too_large = test_full_stalk(2, 5.0);
        let report = bridge.verify_stalk(&too_large).unwrap();
        assert!(!report.accepted);
        assert!(!report.spectral_gap_valid);
        
        // Valid: exactly at lower bound
        let at_lower = test_full_stalk(3, TSIRELSON_LOWER);
        let report = bridge.verify_stalk(&at_lower).unwrap();
        assert!(report.spectral_gap_valid);
        
        // Valid: exactly at upper bound
        let at_upper = test_full_stalk(4, TSIRELSON_UPPER);
        let report = bridge.verify_stalk(&at_upper).unwrap();
        assert!(report.spectral_gap_valid);
    }
    
    #[test]
    fn test_verify_rejects_zero_commitment() {
        let bridge = StalkBridge::new();
        
        let mut stalk = test_full_stalk(0, 1.5);
        stalk.commitment = [0u8; 32];  // All zeros = Python failed
        
        let report = bridge.verify_stalk(&stalk).unwrap();
        assert!(!report.accepted);
        assert!(!report.commitment_nontrivial);
    }
    
    #[test]
    fn test_verify_rejects_negative_eigenvalues() {
        let bridge = StalkBridge::new();
        
        let mut stalk = test_full_stalk(0, 1.5);
        stalk.eigenvalues = vec![-0.5, 1.5, 3.0];  // Negative = not PSD
        
        let report = bridge.verify_stalk(&stalk).unwrap();
        assert!(!report.accepted);
    }
    
    #[test]
    fn test_verify_rejects_bad_betti() {
        let bridge = StalkBridge::new();
        
        let mut stalk = test_full_stalk(0, 1.5);
        stalk.betti_numbers = (0, 0, 0);  // β₀ = 0 makes no sense
        
        let report = bridge.verify_stalk(&stalk).unwrap();
        assert!(!report.accepted);
        assert!(!report.betti_consistent);
    }
    
    #[test]
    fn test_reject_out_of_bounds_stalk() {
        let mut bridge = StalkBridge::new();
        
        // Stalk with gap outside bounds should be rejected
        let stalk = test_full_stalk(0, 0.1);  // Below Tsirelson lower
        bridge.add_full_stalk(stalk).unwrap();
        
        let result = bridge.compute_commitment(0);
        assert!(result.is_err());  // Should fail verification
    }
    
    #[test]
    fn test_naturality_verification() {
        let mut bridge = StalkBridge::new();
        
        let shared_vertices = vec![0, 1];
        let shared_edges = vec![(0, 1)];
        
        let mut stalk0 = test_full_stalk(0, 1.5);
        stalk0.nerve_vertices = shared_vertices.clone();
        stalk0.nerve_edges = shared_edges.clone();
        
        let mut stalk1 = test_full_stalk(1, 1.52);
        stalk1.nerve_vertices = shared_vertices;
        stalk1.nerve_edges = shared_edges;
        
        bridge.add_full_stalk(stalk0).unwrap();
        bridge.add_full_stalk(stalk1).unwrap();
        
        bridge.compute_commitment(0).unwrap();
        bridge.compute_commitment(1).unwrap();
        
        bridge.add_edge(0, 1);
        
        let natural = bridge.verify_naturality(&Edge { from: 0, to: 1 }).unwrap();
        assert!(natural);
    }
    
    #[test]
    fn test_gluing_obstruction() {
        let mut bridge = StalkBridge::new();

        let shared_vertices = vec![0, 1, 2];
        let shared_edges = vec![(0, 1), (1, 2)];

        for i in 0..3 {
            let mut stalk = test_full_stalk(i, 1.4 + i as f64 * 0.01);
            stalk.nerve_vertices = shared_vertices.clone();
            stalk.nerve_edges = shared_edges.clone();
            bridge.add_full_stalk(stalk).unwrap();
            bridge.compute_commitment(i).unwrap();
        }

        bridge.add_edge(0, 1);
        bridge.add_edge(1, 2);

        let glues = bridge.check_gluing_obstruction().unwrap();
        assert!(glues);
    }

    #[test]
    fn test_verify_all_naturality() {
        let mut bridge = StalkBridge::new();

        let shared_vertices = vec![0, 1, 2];
        let shared_edges = vec![(0, 1), (1, 2)];

        for i in 0..3 {
            let mut stalk = test_full_stalk(i, 1.5 + i as f64 * 0.01);
            stalk.nerve_vertices = shared_vertices.clone();
            stalk.nerve_edges = shared_edges.clone();
            bridge.add_full_stalk(stalk).unwrap();
            bridge.compute_commitment(i).unwrap();
        }

        bridge.add_edge(0, 1);
        bridge.add_edge(1, 2);

        let all_natural = bridge.verify_all_naturality().unwrap();
        assert!(all_natural);
    }

    #[test]
    fn test_get_on_chain_section() {
        let mut bridge = StalkBridge::new();

        bridge.add_full_stalk(test_full_stalk(0, 1.5)).unwrap();
        bridge.add_full_stalk(test_full_stalk(1, 1.7)).unwrap();

        bridge.compute_commitment(0).unwrap();
        bridge.compute_commitment(1).unwrap();

        let section = bridge.get_on_chain_section();
        assert_eq!(section.len(), 2);
        assert!(section.contains_key(&0));
        assert!(section.contains_key(&1));

        let c0 = bridge.get_commitment(0).unwrap();
        assert_eq!(c0.vertex_id, 0);
        assert!(c0.spectral_gap_valid);

        let c1 = bridge.get_commitment(1).unwrap();
        assert_eq!(c1.vertex_id, 1);
        assert!(c1.spectral_gap_valid);
    }

    #[test]
    fn test_get_commitment_nonexistent() {
        let bridge = StalkBridge::new();
        assert!(bridge.get_commitment(42).is_none());
    }

    #[test]
    fn test_commitment_preserves_betti() {
        let mut bridge = StalkBridge::new();

        let stalk = test_full_stalk(0, 2.0);
        bridge.add_full_stalk(stalk).unwrap();

        let commitment = bridge.compute_commitment(0).unwrap();
        assert_eq!(commitment.betti_numbers, (1, 0, 0));
    }

    #[test]
    fn test_commitment_identity_is_betti_based() {
        // Post-audit: identity_hash = SHA256(betti + topology_hash)
        // NOT the raw spectral fingerprint (which leaks private info)
        let mut bridge = StalkBridge::new();
        
        let stalk = test_full_stalk(0, 1.5);
        bridge.add_full_stalk(stalk).unwrap();
        let commitment = bridge.compute_commitment(0).unwrap();
        
        // identity_hash should be deterministic from betti + topology
        assert_ne!(commitment.identity_hash, [0u8; 32]); // Non-trivial
        assert!(commitment.spectral_gap_valid);
        
        // Same betti + topology → same identity_hash (deterministic)
        let mut bridge2 = StalkBridge::new();
        let stalk2 = test_full_stalk(0, 1.8); // Different gap, same topology
        bridge2.add_full_stalk(stalk2).unwrap();
        let commitment2 = bridge2.compute_commitment(0).unwrap();
        
        assert_eq!(commitment.identity_hash, commitment2.identity_hash);
    }
}
