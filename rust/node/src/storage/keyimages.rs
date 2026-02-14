#![allow(dead_code)]
// Key Image Storage
//
// Key images prevent double-spending in the homotopical encryption system
// A key image is derived from a spent output and tracked globally

use anyhow::Result;
use rocksdb::DB;
use std::sync::Arc;
use serde::{Deserialize, Serialize};
use tracing::{debug, info};

/// Key image (32 bytes, derived from credential)
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct KeyImage(pub [u8; 32]);

impl KeyImage {
    pub fn new(bytes: [u8; 32]) -> Self {
        Self(bytes)
    }
    
    pub fn from_slice(slice: &[u8]) -> Result<Self> {
        if slice.len() != 32 {
            anyhow::bail!("Key image must be 32 bytes, got {}", slice.len());
        }
        let mut bytes = [0u8; 32];
        bytes.copy_from_slice(slice);
        Ok(Self(bytes))
    }
    
    pub fn as_bytes(&self) -> &[u8; 32] {
        &self.0
    }
    
    pub fn hex(&self) -> String {
        hex::encode(self.0)
    }
}

/// Metadata about when a key image was spent
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KeyImageRecord {
    pub key_image: KeyImage,
    pub block_height: u64,
    pub tx_index: u32,
    pub timestamp: u64,
}

/// Key image storage manager
pub struct KeyImageStore {
    db: Arc<DB>,
}

impl KeyImageStore {
    pub fn new(db: Arc<DB>) -> Self {
        Self { db }
    }
    
    /// Check if a key image has been spent
    pub fn is_spent(&self, key_image: &KeyImage) -> Result<bool> {
        let cf = self.db.cf_handle("keyimages")
            .ok_or_else(|| anyhow::anyhow!("keyimages CF not found"))?;
        
        let key = Self::make_key(key_image);
        Ok(self.db.get_cf(cf, key)?.is_some())
    }
    
    /// Mark a key image as spent
    pub fn mark_spent(
        &self,
        key_image: &KeyImage,
        block_height: u64,
        tx_index: u32,
    ) -> Result<()> {
        let cf = self.db.cf_handle("keyimages")
            .ok_or_else(|| anyhow::anyhow!("keyimages CF not found"))?;
        
        // Check if already spent
        if self.is_spent(key_image)? {
            anyhow::bail!("Key image already spent: {}", key_image.hex());
        }
        
        // Create record
        let record = KeyImageRecord {
            key_image: *key_image,
            block_height,
            tx_index,
            timestamp: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
        };
        
        // Store
        let key = Self::make_key(key_image);
        let value = bincode::serialize(&record)?;
        self.db.put_cf(cf, key, value)?;
        
        debug!(
            "Marked key image as spent: {} at height {}",
            key_image.hex(),
            block_height
        );
        
        Ok(())
    }
    
    /// Get the record for a spent key image
    pub fn get_record(&self, key_image: &KeyImage) -> Result<Option<KeyImageRecord>> {
        let cf = self.db.cf_handle("keyimages")
            .ok_or_else(|| anyhow::anyhow!("keyimages CF not found"))?;
        
        let key = Self::make_key(key_image);
        match self.db.get_cf(cf, key)? {
            Some(bytes) => {
                let record: KeyImageRecord = bincode::deserialize(&bytes)?;
                Ok(Some(record))
            }
            None => Ok(None),
        }
    }
    
    /// Batch check: are any of these key images already spent?
    pub fn check_batch(&self, key_images: &[KeyImage]) -> Result<Vec<KeyImage>> {
        let mut spent = Vec::new();
        
        for ki in key_images {
            if self.is_spent(ki)? {
                spent.push(*ki);
            }
        }
        
        Ok(spent)
    }
    
    /// Batch mark: mark multiple key images as spent
    pub fn mark_batch(
        &self,
        key_images: &[KeyImage],
        block_height: u64,
        tx_index: u32,
    ) -> Result<()> {
        for ki in key_images {
            self.mark_spent(ki, block_height, tx_index)?;
        }
        
        info!("Marked {} key images as spent at height {}", key_images.len(), block_height);
        Ok(())
    }
    
    /// Get all spent key images at a specific height
    pub fn get_spent_at_height(&self, block_height: u64) -> Result<Vec<KeyImageRecord>> {
        let cf = self.db.cf_handle("keyimages")
            .ok_or_else(|| anyhow::anyhow!("keyimages CF not found"))?;
        
        let mut records = Vec::new();
        
        let iter = self.db.iterator_cf(cf, rocksdb::IteratorMode::Start);
        for item in iter {
            let (_key, value) = item?;
            let record: KeyImageRecord = bincode::deserialize(&value)?;
            
            if record.block_height == block_height {
                records.push(record);
            }
        }
        
        Ok(records)
    }
    
    /// Count total spent key images
    pub fn count_spent(&self) -> Result<u64> {
        let cf = self.db.cf_handle("keyimages")
            .ok_or_else(|| anyhow::anyhow!("keyimages CF not found"))?;
        
        let mut count = 0u64;
        let iter = self.db.iterator_cf(cf, rocksdb::IteratorMode::Start);
        for _ in iter {
            count += 1;
        }
        
        Ok(count)
    }
    
    /// Delete key images (for reorg)
    pub fn delete_above_height(&self, block_height: u64) -> Result<u64> {
        let cf = self.db.cf_handle("keyimages")
            .ok_or_else(|| anyhow::anyhow!("keyimages CF not found"))?;
        
        // Find keys to delete
        let mut to_delete = Vec::new();
        let iter = self.db.iterator_cf(cf, rocksdb::IteratorMode::Start);
        
        for item in iter {
            let (key, value) = item?;
            let record: KeyImageRecord = bincode::deserialize(&value)?;
            
            if record.block_height > block_height {
                to_delete.push(key.to_vec());
            }
        }
        
        // Delete them
        let count = to_delete.len() as u64;
        for key in to_delete {
            self.db.delete_cf(cf, key)?;
        }
        
        if count > 0 {
            info!("Deleted {} key images above height {}", count, block_height);
        }
        
        Ok(count)
    }
    
    fn make_key(key_image: &KeyImage) -> Vec<u8> {
        let mut key = Vec::with_capacity(40);
        key.extend_from_slice(b"ki:");
        key.extend_from_slice(&key_image.0);
        key
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;
    
    fn test_key_image(value: u8) -> KeyImage {
        KeyImage([value; 32])
    }
    
    #[test]
    fn test_key_image_tracking() {
        let dir = tempdir().unwrap();
        let db = super::super::sheaf_store::init_sheaf_db(dir.path()).unwrap();
        let store = KeyImageStore::new(Arc::new(db));
        
        let ki = test_key_image(42);
        
        // Not spent initially
        assert!(!store.is_spent(&ki).unwrap());
        
        // Mark as spent
        store.mark_spent(&ki, 100, 0).unwrap();
        
        // Now it's spent
        assert!(store.is_spent(&ki).unwrap());
        
        // Can't spend again
        let result = store.mark_spent(&ki, 101, 0);
        assert!(result.is_err());
    }
    
    #[test]
    fn test_key_image_record() {
        let dir = tempdir().unwrap();
        let db = super::super::sheaf_store::init_sheaf_db(dir.path()).unwrap();
        let store = KeyImageStore::new(Arc::new(db));
        
        let ki = test_key_image(99);
        
        store.mark_spent(&ki, 123, 5).unwrap();
        
        let record = store.get_record(&ki).unwrap().unwrap();
        assert_eq!(record.block_height, 123);
        assert_eq!(record.tx_index, 5);
    }
    
    #[test]
    fn test_batch_operations() {
        let dir = tempdir().unwrap();
        let db = super::super::sheaf_store::init_sheaf_db(dir.path()).unwrap();
        let store = KeyImageStore::new(Arc::new(db));
        
        let kis = vec![
            test_key_image(1),
            test_key_image(2),
            test_key_image(3),
        ];
        
        // Mark batch as spent
        store.mark_batch(&kis, 50, 0).unwrap();
        
        // Check batch
        let spent = store.check_batch(&kis).unwrap();
        assert_eq!(spent.len(), 3);
        
        // Count
        assert_eq!(store.count_spent().unwrap(), 3);
    }
    
    #[test]
    fn test_reorg_deletion() {
        let dir = tempdir().unwrap();
        let db = super::super::sheaf_store::init_sheaf_db(dir.path()).unwrap();
        let store = KeyImageStore::new(Arc::new(db));
        
        // Spend at different heights
        store.mark_spent(&test_key_image(1), 10, 0).unwrap();
        store.mark_spent(&test_key_image(2), 20, 0).unwrap();
        store.mark_spent(&test_key_image(3), 30, 0).unwrap();
        
        assert_eq!(store.count_spent().unwrap(), 3);
        
        // Delete above height 15
        let deleted = store.delete_above_height(15).unwrap();
        assert_eq!(deleted, 2);
        assert_eq!(store.count_spent().unwrap(), 1);
        
        // Only the first one remains
        assert!(store.is_spent(&test_key_image(1)).unwrap());
        assert!(!store.is_spent(&test_key_image(2)).unwrap());
        assert!(!store.is_spent(&test_key_image(3)).unwrap());
    }
}
