// Homotopical-Encrypt Node — Library
//
// Public API for consensus, crypto, network, storage, and types.
// The binary (main.rs) wires these together; other crates (oracle, wallet,
// integration tests) can import individual modules.

pub mod consensus;
pub mod crypto;
pub mod network;
pub mod rpc;
pub mod storage;
pub mod types;
