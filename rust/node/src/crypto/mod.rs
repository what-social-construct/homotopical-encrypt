// Cryptographic primitives for homotopical-encrypt
//
// Ports the Python commitment scheme (src/crypto/commitment.py)
// to Rust for use in the node's transaction processing pipeline.

pub mod commitment;
pub mod geodesic_zkp;

pub use commitment::{CochainCommitment, CochainComplex};
pub use geodesic_zkp::{GeodesicZKProof, ZKPVerification, verify_geodesic_proof};
