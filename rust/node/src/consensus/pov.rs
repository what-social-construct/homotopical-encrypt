// Proof of Value: Spectral Gap Validation

use crate::types::{Block, SpectralProof};
use anyhow::{Result, bail};
use tracing::{debug, warn};

pub struct PoVVerifier {
    // Oracle public keys (trusted workers)
    trusted_workers: Vec<[u8; 32]>,
}

impl PoVVerifier {
    pub fn new(trusted_workers: Vec<[u8; 32]>) -> Self {
        Self { trusted_workers }
    }

    /// Verify a block's spectral proof
    pub fn verify_block(&self, block: &Block) -> Result<()> {
        let proof = &block.header.spectral_proof;
        
        debug!("Verifying block at height {}", block.header.height);
        
        // 1. Verify √2 bounds (SIMPLE!)
        if !proof.fingerprint.verify_bounds() {
            bail!("Spectral gap out of bounds: {}", proof.fingerprint.spectral_gap);
        }
        
        // 2. Verify computation trace
        if !self.verify_computation_trace(proof) {
            bail!("Invalid computation trace");
        }
        
        // 3. Verify worker consensus (2/3 required)
        if !self.verify_worker_consensus(proof) {
            bail!("Insufficient worker consensus");
        }
        
        debug!("✅ Block verified!");
        Ok(())
    }

    fn verify_computation_trace(&self, proof: &SpectralProof) -> bool {
        // Verify hash chain is valid
        let mut current_hash = proof.computation_trace[0].input_hash;
        
        for step in &proof.computation_trace {
            if step.input_hash != current_hash {
                warn!("Computation trace broken at step: {}", step.operation);
                return false;
            }
            current_hash = step.output_hash;
        }
        
        // Final hash should match fingerprint hash
        current_hash == proof.fingerprint.hash
    }

    fn verify_worker_consensus(&self, proof: &SpectralProof) -> bool {
        // Need at least 3 workers
        if proof.worker_signatures.len() < 3 {
            return false;
        }
        
        // At least 2/3 must be from trusted workers
        let threshold = (proof.worker_signatures.len() * 2) / 3;
        let mut valid_count = 0;
        
        for sig in &proof.worker_signatures {
            if self.trusted_workers.contains(&sig.worker_pubkey) {
                // TODO: Actually verify signature
                valid_count += 1;
            }
        }
        
        valid_count >= threshold
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::types::*;

    #[test]
    fn test_spectral_bounds() {
        let fp = SpectralFingerprint {
            spectral_gap: 1.5,
            betti_numbers: [1, 0, 0],
            hash: [0; 32],
        };
        assert!(fp.verify_bounds());

        let fp_invalid = SpectralFingerprint {
            spectral_gap: 5.0,  // Too high!
            betti_numbers: [1, 0, 0],
            hash: [0; 32],
        };
        assert!(!fp_invalid.verify_bounds());
    }
}
