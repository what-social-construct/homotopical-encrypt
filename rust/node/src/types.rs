// Core types for Homotopical-Encrypt chain

use serde::{Deserialize, Serialize};
use std::fmt;

/// Block hash (Blake3)
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct BlockHash(pub [u8; 32]);

impl fmt::Display for BlockHash {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", hex::encode(self.0))
    }
}

/// Spectral fingerprint (from off-chain computation)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SpectralFingerprint {
    pub spectral_gap: f64,
    pub betti_numbers: [u32; 3],
    pub hash: [u8; 32],
}

impl SpectralFingerprint {
    /// Verify √2 bounds
    pub fn verify_bounds(&self) -> bool {
        const SQRT2: f64 = 1.41421356237;
        let lower = 1.0 / SQRT2;
        let upper = 2.0 * SQRT2;
        
        self.spectral_gap >= lower && self.spectral_gap <= upper
    }
}

/// Block header
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BlockHeader {
    pub height: u64,
    pub parent_hash: BlockHash,
    pub timestamp: u64,
    pub spectral_proof: SpectralProof,
}

/// Spectral proof (from oracle)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SpectralProof {
    pub fingerprint: SpectralFingerprint,
    pub computation_trace: Vec<ComputationStep>,
    pub worker_signatures: Vec<WorkerSignature>,
}

/// Computation step in trace
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ComputationStep {
    pub operation: String,
    pub input_hash: [u8; 32],
    pub output_hash: [u8; 32],
}

/// Worker signature
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WorkerSignature {
    pub worker_pubkey: [u8; 32],
    pub signature: [u8; 64],
}

/// Transaction
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Transaction {
    // TODO: Implement homotopy transaction structure
    pub data: Vec<u8>,
}

/// Block
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Block {
    pub header: BlockHeader,
    pub transactions: Vec<Transaction>,
}

impl Block {
    pub fn hash(&self) -> BlockHash {
        use blake3::Hasher;
        let mut hasher = Hasher::new();
        hasher.update(&bincode::serialize(&self.header).unwrap());
        BlockHash(*hasher.finalize().as_bytes())
    }
}
