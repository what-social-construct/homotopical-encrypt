// Wallet Store - Encrypted credential management
//
// Rust translation of Python wallet_store.py
// Uses geometric encryption (Hodge projection)

use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::path::PathBuf;

/// Encrypted credential in wallet
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EncryptedCredential {
    /// Hodge-encrypted credential bytes
    pub ciphertext: Vec<u8>,
    
    /// Public fingerprint (can verify without decrypt)
    pub fingerprint: [u8; 32],
    
    /// Topology hash
    pub topology_hash: [u8; 32],
    
    /// Expected invariants
    pub spectral_gap: f64,
    pub betti_numbers: (i32, i32, i32),
    
    /// Timestamp
    pub encrypted_at: u64,
}

/// Wallet storage
pub struct WalletStore {
    path: PathBuf,
    credentials: HashMap<String, EncryptedCredential>,
}

impl WalletStore {
    pub fn new(path: PathBuf) -> Self {
        Self {
            path,
            credentials: HashMap::new(),
        }
    }
    
    pub fn save_credential(&mut self, label: &str, cred: EncryptedCredential) -> Result<()> {
        self.credentials.insert(label.to_string(), cred);
        // TODO: Persist to disk
        Ok(())
    }
    
    pub fn load_credential(&self, label: &str) -> Option<&EncryptedCredential> {
        self.credentials.get(label)
    }
    
    pub fn list_credentials(&self) -> Vec<&str> {
        self.credentials.keys().map(|s| s.as_str()).collect()
    }
    
    pub fn remove_credential(&mut self, label: &str) -> bool {
        self.credentials.remove(label).is_some()
    }
    
    pub fn has_credential(&self, label: &str) -> bool {
        self.credentials.contains_key(label)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::PathBuf;
    
    fn test_credential(gap: f64) -> EncryptedCredential {
        EncryptedCredential {
            ciphertext: vec![0u8; 64],
            fingerprint: [42u8; 32],
            topology_hash: [1u8; 32],
            spectral_gap: gap,
            betti_numbers: (1, 0, 0),
            encrypted_at: 1234567890,
        }
    }
    
    #[test]
    fn test_save_and_load() {
        let mut store = WalletStore::new(PathBuf::from("/tmp/test_wallet"));
        
        let cred = test_credential(1.5);
        store.save_credential("alice", cred).unwrap();
        
        let loaded = store.load_credential("alice").unwrap();
        assert_eq!(loaded.spectral_gap, 1.5);
        assert_eq!(loaded.betti_numbers, (1, 0, 0));
        assert_eq!(loaded.fingerprint, [42u8; 32]);
    }
    
    #[test]
    fn test_list_and_remove() {
        let mut store = WalletStore::new(PathBuf::from("/tmp/test_wallet"));
        
        store.save_credential("alice", test_credential(1.5)).unwrap();
        store.save_credential("bob", test_credential(1.8)).unwrap();
        
        assert_eq!(store.list_credentials().len(), 2);
        assert!(store.has_credential("alice"));
        assert!(store.has_credential("bob"));
        assert!(!store.has_credential("charlie"));
        
        assert!(store.remove_credential("alice"));
        assert!(!store.has_credential("alice"));
        assert_eq!(store.list_credentials().len(), 1);
    }
    
    #[test]
    fn test_overwrite_credential() {
        let mut store = WalletStore::new(PathBuf::from("/tmp/test_wallet"));
        
        store.save_credential("alice", test_credential(1.5)).unwrap();
        assert_eq!(store.load_credential("alice").unwrap().spectral_gap, 1.5);
        
        // Overwrite with new gap (key rotation within homotopy class)
        store.save_credential("alice", test_credential(1.8)).unwrap();
        assert_eq!(store.load_credential("alice").unwrap().spectral_gap, 1.8);
        assert_eq!(store.list_credentials().len(), 1);
    }
    
    #[test]
    fn test_missing_credential() {
        let store = WalletStore::new(PathBuf::from("/tmp/test_wallet"));
        assert!(store.load_credential("nonexistent").is_none());
    }
}
