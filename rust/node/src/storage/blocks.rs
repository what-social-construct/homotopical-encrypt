// Block Storage - RocksDB persistence for blocks

use crate::types::{Block, BlockHash};
use anyhow::Result;
use rocksdb::DB;
use std::sync::Arc;
use tracing::{debug, info};

/// Block storage manager
pub struct BlockStore {
    db: Arc<DB>,
}

impl BlockStore {
    pub fn new(db: Arc<DB>) -> Self {
        Self { db }
    }
    
    /// Store a block by height
    pub fn store_block(&self, block: &Block) -> Result<()> {
        let height = block.header.height;
        let hash = block.hash();
        
        debug!("Storing block at height {} with hash {}", height, hash);
        
        // Serialize block
        let block_bytes = bincode::serialize(block)?;
        
        // Store block data with height as key
        let height_key = format!("block:height:{}", height);
        self.db.put(height_key.as_bytes(), &block_bytes)?;
        
        // Store block data with hash as key
        let hash_key = format!("block:hash:{}", hash);
        self.db.put(hash_key.as_bytes(), &block_bytes)?;
        
        // Update height->hash index
        let index_key = format!("index:height:{}", height);
        self.db.put(index_key.as_bytes(), hash.0)?;
        
        // Update hash->height index
        let index_key = format!("index:hash:{}", hash);
        self.db.put(index_key.as_bytes(), &height.to_be_bytes())?;
        
        // Update chain tip if this is the highest block
        if let Ok(Some(tip)) = self.get_tip_height() {
            if height > tip {
                self.set_tip(height, hash)?;
            }
        } else {
            // First block
            self.set_tip(height, hash)?;
        }
        
        info!("✅ Stored block {} at height {}", hash, height);
        Ok(())
    }
    
    /// Load block by height
    pub fn load_block_by_height(&self, height: u64) -> Result<Option<Block>> {
        let key = format!("block:height:{}", height);
        
        match self.db.get(key.as_bytes())? {
            Some(bytes) => {
                let block: Block = bincode::deserialize(&bytes)?;
                Ok(Some(block))
            }
            None => Ok(None),
        }
    }
    
    /// Load block by hash
    pub fn load_block_by_hash(&self, hash: &BlockHash) -> Result<Option<Block>> {
        let key = format!("block:hash:{}", hash);
        
        match self.db.get(key.as_bytes())? {
            Some(bytes) => {
                let block: Block = bincode::deserialize(&bytes)?;
                Ok(Some(block))
            }
            None => Ok(None),
        }
    }
    
    /// Get the current chain tip (latest block)
    pub fn get_chain_tip(&self) -> Result<Option<(u64, BlockHash)>> {
        let height_key = b"tip:height";
        let hash_key = b"tip:hash";
        
        match (self.db.get(height_key)?, self.db.get(hash_key)?) {
            (Some(height_bytes), Some(hash_bytes)) => {
                let height_slice: &[u8] = height_bytes.as_ref();
                let height = u64::from_be_bytes(height_slice.try_into()?);
                let hash_slice: &[u8] = hash_bytes.as_ref();
                let hash_array: [u8; 32] = hash_slice.try_into()?;
                let hash = BlockHash(hash_array);
                Ok(Some((height, hash)))
            }
            _ => Ok(None),
        }
    }
    
    /// Get just the tip height
    pub fn get_tip_height(&self) -> Result<Option<u64>> {
        match self.db.get(b"tip:height")? {
            Some(bytes) => {
                let slice: &[u8] = bytes.as_ref();
                let height = u64::from_be_bytes(slice.try_into()?);
                Ok(Some(height))
            }
            None => Ok(None),
        }
    }
    
    /// Set the chain tip
    fn set_tip(&self, height: u64, hash: BlockHash) -> Result<()> {
        self.db.put(b"tip:height", &height.to_be_bytes())?;
        self.db.put(b"tip:hash", hash.0)?;
        Ok(())
    }
    
    /// Get block hash by height
    pub fn get_hash_by_height(&self, height: u64) -> Result<Option<BlockHash>> {
        let key = format!("index:height:{}", height);
        
        match self.db.get(key.as_bytes())? {
            Some(bytes) => {
                let slice: &[u8] = bytes.as_ref();
                let hash_array: [u8; 32] = slice.try_into()?;
                Ok(Some(BlockHash(hash_array)))
            }
            None => Ok(None),
        }
    }
    
    /// Get block height by hash
    pub fn get_height_by_hash(&self, hash: &BlockHash) -> Result<Option<u64>> {
        let key = format!("index:hash:{}", hash);
        
        match self.db.get(key.as_bytes())? {
            Some(bytes) => {
                let slice: &[u8] = bytes.as_ref();
                let height = u64::from_be_bytes(slice.try_into()?);
                Ok(Some(height))
            }
            None => Ok(None),
        }
    }
    
    /// Delete a block (for reorgs)
    pub fn delete_block(&self, height: u64) -> Result<()> {
        // Get hash first
        if let Some(hash) = self.get_hash_by_height(height)? {
            // Delete by height
            let height_key = format!("block:height:{}", height);
            self.db.delete(height_key.as_bytes())?;
            
            // Delete by hash
            let hash_key = format!("block:hash:{}", hash);
            self.db.delete(hash_key.as_bytes())?;
            
            // Delete index entries
            let index_height_key = format!("index:height:{}", height);
            self.db.delete(index_height_key.as_bytes())?;
            
            let index_hash_key = format!("index:hash:{}", hash);
            self.db.delete(index_hash_key.as_bytes())?;
            
            info!("Deleted block {} at height {}", hash, height);
        }
        
        Ok(())
    }
    
    /// Check if block exists
    pub fn has_block(&self, hash: &BlockHash) -> Result<bool> {
        let key = format!("block:hash:{}", hash);
        Ok(self.db.get(key.as_bytes())?.is_some())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::types::*;
    use tempfile::tempdir;
    
    fn create_test_block(height: u64) -> Block {
        Block {
            header: BlockHeader {
                version: 1,
                height,
                parent_hash: BlockHash([0; 32]),
                cochain_root: [0; 32],
                timestamp: 1234567890,
                spectral_proof: SpectralProof {
                    fingerprint: SpectralFingerprint {
                        spectral_gap: 1.5,
                        betti_numbers: (1, 0, 0),
                        hash: [0; 32],
                    },
                    computation_trace: vec![],
                    worker_signatures: vec![],
                },
                producer_fingerprint: [0; 32],
                topology_hash: [0; 32],
            },
            transactions: vec![],
        }
    }
    
    #[test]
    fn test_store_and_load_block() {
        let dir = tempdir().unwrap();
        let db = crate::storage::init_db(dir.path()).unwrap();
        let store = BlockStore::new(Arc::new(db));
        
        let block = create_test_block(1);
        let hash = block.hash();
        
        // Store
        store.store_block(&block).unwrap();
        
        // Load by height
        let loaded = store.load_block_by_height(1).unwrap().unwrap();
        assert_eq!(loaded.header.height, 1);
        
        // Load by hash
        let loaded = store.load_block_by_hash(&hash).unwrap().unwrap();
        assert_eq!(loaded.header.height, 1);
    }
    
    #[test]
    fn test_chain_tip() {
        let dir = tempdir().unwrap();
        let db = crate::storage::init_db(dir.path()).unwrap();
        let store = BlockStore::new(Arc::new(db));
        
        // No tip initially
        assert!(store.get_chain_tip().unwrap().is_none());
        
        // Store block
        let block = create_test_block(1);
        let hash = block.hash();
        store.store_block(&block).unwrap();
        
        // Check tip
        let (height, tip_hash) = store.get_chain_tip().unwrap().unwrap();
        assert_eq!(height, 1);
        assert_eq!(tip_hash, hash);
        
        // Store higher block
        let block2 = create_test_block(2);
        let hash2 = block2.hash();
        store.store_block(&block2).unwrap();
        
        // Tip should update
        let (height, tip_hash) = store.get_chain_tip().unwrap().unwrap();
        assert_eq!(height, 2);
        assert_eq!(tip_hash, hash2);
    }
}
