// Wallet - Encrypted credential storage
//
// Uses Hodge-based encryption (our system!)
// Master key = spectral fingerprint

pub mod store;

pub use store::WalletStore;
