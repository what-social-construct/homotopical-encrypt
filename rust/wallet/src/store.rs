// Wallet Store - Encrypted credential management
//
// Rust translation of Python wallet_store.py
// Persists credentials as JSON to disk.
//
// Architecture (from STORAGE.md):
// - Master key = spectral fingerprint of master fibration
// - Identity IS encryption key (no separate key management)
// - Python does heavy geometry (encrypt/decrypt/invariants)
// - Rust wallet stores encrypted credentials locally
// - Oracle bridges Python geometry to Rust chain

use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::path::PathBuf;
use tracing::{debug, info, warn};

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

/// On-disk wallet format
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
struct WalletFile {
    version: String,
    credentials: HashMap<String, EncryptedCredential>,
}

/// Wallet storage with JSON disk persistence
pub struct WalletStore {
    path: PathBuf,
    data: WalletFile,
}

impl WalletStore {
    /// Create or open wallet at path
    pub fn new(path: PathBuf) -> Self {
        let data = Self::load_file(&path).unwrap_or_else(|_| WalletFile {
            version: "1.0".to_string(),
            credentials: HashMap::new(),
        });
        Self { path, data }
    }
    
    /// Save credential to wallet (persists to disk)
    pub fn save_credential(&mut self, label: &str, cred: EncryptedCredential) -> Result<()> {
        info!("Saving credential '{}' to wallet", label);
        self.data.credentials.insert(label.to_string(), cred);
        self.flush()?;
        Ok(())
    }
    
    /// Load credential by label
    pub fn load_credential(&self, label: &str) -> Option<&EncryptedCredential> {
        self.data.credentials.get(label)
    }
    
    /// List all credential labels
    pub fn list_credentials(&self) -> Vec<&str> {
        self.data.credentials.keys().map(|s| s.as_str()).collect()
    }
    
    /// Remove credential by label
    pub fn remove_credential(&mut self, label: &str) -> Result<bool> {
        let removed = self.data.credentials.remove(label).is_some();
        if removed {
            self.flush()?;
            info!("Removed credential '{}'", label);
        }
        Ok(removed)
    }
    
    /// Check if credential exists
    pub fn has_credential(&self, label: &str) -> bool {
        self.data.credentials.contains_key(label)
    }
    
    /// Flush in-memory state to disk
    fn flush(&self) -> Result<()> {
        if let Some(parent) = self.path.parent() {
            std::fs::create_dir_all(parent)?;
        }
        let json = serde_json::to_string_pretty(&self.data)?;
        std::fs::write(&self.path, json)?;
        debug!("Wallet flushed to {:?}", self.path);
        Ok(())
    }
    
    /// Load wallet file from disk
    fn load_file(path: &PathBuf) -> Result<WalletFile> {
        let json = std::fs::read_to_string(path)?;
        let data: WalletFile = serde_json::from_str(&json)?;
        Ok(data)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;
    
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
        let dir = tempdir().unwrap();
        let path = dir.path().join("wallet.json");
        let mut store = WalletStore::new(path);
        
        let cred = test_credential(1.5);
        store.save_credential("alice", cred).unwrap();
        
        let loaded = store.load_credential("alice").unwrap();
        assert_eq!(loaded.spectral_gap, 1.5);
        assert_eq!(loaded.betti_numbers, (1, 0, 0));
        assert_eq!(loaded.fingerprint, [42u8; 32]);
    }
    
    #[test]
    fn test_disk_persistence() {
        let dir = tempdir().unwrap();
        let path = dir.path().join("wallet.json");
        
        // Save with one instance
        {
            let mut store = WalletStore::new(path.clone());
            store.save_credential("alice", test_credential(1.5)).unwrap();
            store.save_credential("bob", test_credential(1.8)).unwrap();
        }
        
        // Load with fresh instance — must survive restart
        {
            let store = WalletStore::new(path);
            assert!(store.has_credential("alice"));
            assert!(store.has_credential("bob"));
            assert_eq!(store.load_credential("alice").unwrap().spectral_gap, 1.5);
            assert_eq!(store.load_credential("bob").unwrap().spectral_gap, 1.8);
            assert_eq!(store.list_credentials().len(), 2);
        }
    }
    
    #[test]
    fn test_list_and_remove() {
        let dir = tempdir().unwrap();
        let path = dir.path().join("wallet.json");
        let mut store = WalletStore::new(path);
        
        store.save_credential("alice", test_credential(1.5)).unwrap();
        store.save_credential("bob", test_credential(1.8)).unwrap();
        
        assert_eq!(store.list_credentials().len(), 2);
        assert!(store.has_credential("alice"));
        assert!(!store.has_credential("charlie"));
        
        assert!(store.remove_credential("alice").unwrap());
        assert!(!store.has_credential("alice"));
        assert_eq!(store.list_credentials().len(), 1);
    }
    
    #[test]
    fn test_overwrite_credential() {
        let dir = tempdir().unwrap();
        let path = dir.path().join("wallet.json");
        let mut store = WalletStore::new(path);
        
        store.save_credential("alice", test_credential(1.5)).unwrap();
        assert_eq!(store.load_credential("alice").unwrap().spectral_gap, 1.5);
        
        // Key rotation: overwrite with new fibration (same homotopy class)
        store.save_credential("alice", test_credential(1.8)).unwrap();
        assert_eq!(store.load_credential("alice").unwrap().spectral_gap, 1.8);
        assert_eq!(store.list_credentials().len(), 1);
    }
    
    #[test]
    fn test_missing_credential() {
        let dir = tempdir().unwrap();
        let path = dir.path().join("wallet.json");
        let store = WalletStore::new(path);
        assert!(store.load_credential("nonexistent").is_none());
    }
    
    #[test]
    fn test_remove_persists() {
        let dir = tempdir().unwrap();
        let path = dir.path().join("wallet.json");
        
        // Save then remove
        {
            let mut store = WalletStore::new(path.clone());
            store.save_credential("alice", test_credential(1.5)).unwrap();
            store.save_credential("bob", test_credential(1.8)).unwrap();
            store.remove_credential("alice").unwrap();
        }
        
        // Fresh instance should see removal
        {
            let store = WalletStore::new(path);
            assert!(!store.has_credential("alice"));
            assert!(store.has_credential("bob"));
        }
    }
}
