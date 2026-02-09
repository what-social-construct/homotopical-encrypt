// SheafState Storage - Three-Layer State Bus

// Stores the global state as a section of the PUBLIC_STALK bundle
// State = Γ(X, PUBLIC_STALK) where X is the nerve of accounts

// Implements the three-layer hardness hierarchy (see docs/ARCHITECTURE.md):
// - Layer 3 (homotopy/wallet): accounts, homotopy class, key rotation
// - Layer 2 (lattice-CVP/oracle): cochain commitments, spectral cache
// - Layer 1 (hash projection/node): block headers, key images, SHA256 audit trail
//
// This matches Python's src/chain/sheaf_state.py implementation.
// SheafState is the bus connecting all three layers.

use anyhow::Result;
use rocksdb::DB;
use std::sync::Arc;
use std::collections::HashSet;
use serde::{Deserialize, Serialize};
use tracing::{debug, info, warn};

use super::sheaf_store::{SheafStore, Stalk, StalkContext};
use super::keyimages::{KeyImageStore, KeyImage};
use super::blocks::BlockStore;
use crate::types::{Block, BlockHash};

/// Account state (balance at a vertex)
/// Matches Python: src/chain/sheaf_state.py AccountState
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AccountState {
    pub account_id: u64,
    pub fingerprint: [u8; 32],
    pub homotopy_class_id: [u8; 32],
    pub balance: f64,
    pub nonce: u64,
    pub last_update: u64,  // Block height
    pub connected_to: HashSet<u64>,  // Connected account IDs
    pub rotation_count: u32,
}

impl AccountState {
    pub fn new(account_id: u64, fingerprint: [u8; 32], homotopy_class_id: [u8; 32], initial_balance: f64) -> Self {
        Self {
            account_id,
            fingerprint,
            homotopy_class_id,
            balance: initial_balance,
            nonce: 0,
            last_update: 0,
            connected_to: HashSet::new(),
            rotation_count: 0,
        }
    }
}

/// Global state as a section
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GlobalState {
    pub accounts: Vec<AccountState>,
    pub total_supply: f64,
    pub block_height: u64,
}

impl GlobalState {
    pub fn new() -> Self {
        Self {
            accounts: Vec::new(),
            total_supply: 0.0,
            block_height: 0,
        }
    }
    
    pub fn get_account(&self, account_id: u64) -> Option<&AccountState> {
        self.accounts.iter().find(|a| a.account_id == account_id)
    }
    
    pub fn get_balance(&self, account_id: u64) -> f64 {
        self.get_account(account_id)
            .map(|a| a.balance)
            .unwrap_or(0.0)
    }
    
    pub fn get_account_mut(&mut self, account_id: u64) -> Option<&mut AccountState> {
        self.accounts.iter_mut().find(|a| a.account_id == account_id)
    }
}

/// Three-Layer State Manager
///
/// Integrates all three layers of the hardness hierarchy:
/// - Layer 1 (hash projection): BlockStore, KeyImageStore, block headers
/// - Layer 2 (lattice-CVP): commitment tracking (via sheaf_store)
/// - Layer 3 (homotopy): account balances, nonces, connections
///
/// Matches Python's SheafState.apply_block() functionality.
pub struct StateManager {
    state_store: Arc<StateStore>,
    block_store: Arc<BlockStore>,
    key_image_store: Arc<KeyImageStore>,
    db: Arc<DB>,
}

impl StateManager {
    pub fn new(db: Arc<DB>) -> Self {
        Self {
            state_store: Arc::new(StateStore::new(db.clone())),
            block_store: Arc::new(BlockStore::new(db.clone())),
            key_image_store: Arc::new(KeyImageStore::new(db.clone())),
            db,
        }
    }
    
    /// Apply a verified block to state (matches Python SheafState.apply_block)
    ///
    /// Updates all three layers:
    /// - Layer 1: mark key images spent, store block header, update tip
    /// - Layer 2: track commitments (implicit in sheaf_store)
    /// - Layer 3: debit fees from senders, credit fees to producer
    ///
    /// Returns: (success, reason)
    pub fn apply_block(&self, block: &Block) -> Result<String> {
        let block_hash = block.hash();
        let height = block.header.height;
        
        info!("Applying block {} at height {}", block_hash, height);
        
        // =====================================================================
        // LAYER 1: Key images (accountability, double-spend prevention)
        // =====================================================================
        
        // Extract key images from transactions (Transaction.key_image field)
        let mut key_images = Vec::new();
        for (tx_idx, tx) in block.transactions.iter().enumerate() {
            if let Some(ki_bytes) = tx.key_image {
                let ki = KeyImage::new(ki_bytes);
                
                // Check for double-spend BEFORE adding to list
                if self.key_image_store.is_spent(&ki)? {
                    anyhow::bail!(
                        "Double-spend detected: key image {} in tx {} at height {}",
                        ki.hex(),
                        tx_idx,
                        height
                    );
                }
                
                key_images.push((tx_idx, ki));
            } else {
                debug!("Transaction {} has no key image (possibly genesis/coinbase)", tx_idx);
            }
        }
        
        // Mark all key images as spent (after all double-spend checks pass)
        for (tx_idx, ki) in &key_images {
            self.key_image_store.mark_spent(ki, height, *tx_idx as u32)?;
        }
        
        // =====================================================================
        // LAYER 3: Account balance updates (fees)
        // =====================================================================
        
        // Load current state
        let mut state = self.state_store.load_state()?;
        
        // Build fingerprint → account_id index
        let mut fp_to_id: std::collections::HashMap<[u8; 32], u64> = std::collections::HashMap::new();
        for account in &state.accounts {
            fp_to_id.insert(account.fingerprint, account.account_id);
        }
        
        // Calculate total fees from all transactions
        let mut total_fees = 0.0;
        
        for tx in &block.transactions {
            if let Some(sender_fp) = tx.sender_fingerprint {
                let fee_amount = tx.fee_amount as f64;
                
                // Debit fee from sender
                if let Some(&sender_id) = fp_to_id.get(&sender_fp) {
                    if let Some(account) = state.get_account_mut(sender_id) {
                        if account.balance >= fee_amount {
                            account.balance -= fee_amount;
                            account.nonce += 1;
                            total_fees += fee_amount;
                        } else {
                            warn!(
                                "Sender {} has insufficient balance for fee: {} < {}",
                                sender_id, account.balance, fee_amount
                            );
                        }
                    }
                }
            }
        }
        
        // Credit fees to block producer
        let producer_fp = block.header.producer_fingerprint;
        if let Some(&producer_id) = fp_to_id.get(&producer_fp) {
            if let Some(producer) = state.get_account_mut(producer_id) {
                producer.balance += total_fees;
            }
        }
        
        // Update block height in state
        state.block_height = height;
        
        // Persist updated state
        self.state_store.store_state(&state)?;
        
        // =====================================================================
        // LAYER 1: Store block header
        // =====================================================================
        
        self.block_store.store_block(block)?;
        
        // =====================================================================
        // SUCCESS
        // =====================================================================
        
        let msg = format!(
            "Block {} applied ({} txs, {} key images, fees={})",
            height,
            block.transactions.len(),
            key_images.len(),
            total_fees
        );
        
        info!("✅ {}", msg);
        Ok(msg)
    }
    
    /// Get account balance
    pub fn get_balance(&self, account_id: u64) -> Result<f64> {
        self.state_store.get_balance(account_id)
    }
    
    /// Get current chain tip
    pub fn get_chain_tip(&self) -> Result<Option<(u64, BlockHash)>> {
        self.block_store.get_chain_tip()
    }
    
    /// Check if key image is spent
    pub fn is_key_image_spent(&self, key_image: &KeyImage) -> Result<bool> {
        self.key_image_store.is_spent(key_image)
    }
    
    /// Load current state
    pub fn load_state(&self) -> Result<GlobalState> {
        self.state_store.load_state()
    }
}

/// State storage manager (lower-level, used by StateManager)
pub struct StateStore {
    sheaf_store: Arc<SheafStore>,
    db: Arc<DB>,
}

impl StateStore {
    pub fn new(db: Arc<DB>) -> Self {
        let sheaf_store = Arc::new(SheafStore::new(db.clone()));
        Self { sheaf_store, db }
    }
    
    /// Store global state as a section
    pub fn store_state(&self, state: &GlobalState) -> Result<()> {
        info!(
            "Storing global state: {} accounts, height {}",
            state.accounts.len(),
            state.block_height
        );
        
        // Convert accounts to stalks (balances)
        let mut stalks = Vec::new();
        for account in &state.accounts {
            let stalk = Stalk::from_value(account.balance);
            stalks.push((account.account_id, stalk));
        }
        
        // Store section (harmonic projection)
        self.sheaf_store.set_section(StalkContext::Public, &stalks)?;
        
        // Store metadata separately
        let metadata_key = b"state:metadata";
        let metadata = StateMetadata {
            total_supply: state.total_supply,
            block_height: state.block_height,
            account_count: state.accounts.len() as u64,
        };
        self.db.put(metadata_key, bincode::serialize(&metadata)?)?;
        
        // Store individual account metadata (all fields)
        for account in &state.accounts {
            let key = format!("account:{}:meta", account.account_id);
            let meta = AccountMetadata {
                fingerprint: account.fingerprint,
                homotopy_class_id: account.homotopy_class_id,
                nonce: account.nonce,
                last_update: account.last_update,
                connected_to: account.connected_to.iter().copied().collect(),
                rotation_count: account.rotation_count,
            };
            self.db.put(key.as_bytes(), bincode::serialize(&meta)?)?;
        }
        
        debug!("✅ Global state stored");
        Ok(())
    }
    
    /// Load global state from storage
    pub fn load_state(&self) -> Result<GlobalState> {
        // Load metadata
        let metadata_key = b"state:metadata";
        let metadata: StateMetadata = match self.db.get(metadata_key)? {
            Some(bytes) => bincode::deserialize(&bytes)?,
            None => return Ok(GlobalState::new()),  // No state yet
        };
        
        // Load section (all balances)
        let section = self.sheaf_store.get_section(StalkContext::Public)?;
        
        // Reconstruct accounts
        let mut accounts = Vec::new();
        for (account_id, stalk) in section {
            let balance = stalk.data[0];
            
            // Load account metadata
            let key = format!("account:{}:meta", account_id);
            let meta: AccountMetadata = match self.db.get(key.as_bytes())? {
                Some(bytes) => bincode::deserialize(&bytes)?,
                None => AccountMetadata {
                    fingerprint: [0; 32],
                    homotopy_class_id: [0; 32],
                    nonce: 0,
                    last_update: 0,
                    connected_to: vec![],
                    rotation_count: 0,
                },
            };
            
            accounts.push(AccountState {
                account_id,
                fingerprint: meta.fingerprint,
                homotopy_class_id: meta.homotopy_class_id,
                balance,
                nonce: meta.nonce,
                last_update: meta.last_update,
                connected_to: meta.connected_to.into_iter().collect(),
                rotation_count: meta.rotation_count,
            });
        }
        
        Ok(GlobalState {
            accounts,
            total_supply: metadata.total_supply,
            block_height: metadata.block_height,
        })
    }
    
    /// Get balance for a specific account
    pub fn get_balance(&self, account_id: u64) -> Result<f64> {
        match self.sheaf_store.get_stalk(StalkContext::Public, account_id)? {
            Some(stalk) => Ok(stalk.data[0]),
            None => Ok(0.0),
        }
    }
    
    /// Update balance for an account
    pub fn update_balance(&self, account_id: u64, new_balance: f64) -> Result<()> {
        let stalk = Stalk::from_value(new_balance);
        self.sheaf_store.set_stalk(StalkContext::Public, account_id, &stalk)?;
        
        debug!("Updated balance for account {}: {}", account_id, new_balance);
        Ok(())
    }
    
    /// Apply state transition (from block)
    pub fn apply_transition(
        &self,
        transfers: &[(u64, u64, f64)],  // (from, to, amount)
        block_height: u64,
    ) -> Result<()> {
        info!("Applying state transition: {} transfers", transfers.len());
        
        for (from, to, amount) in transfers {
            // Get current balances
            let from_balance = self.get_balance(*from)?;
            let to_balance = self.get_balance(*to)?;
            
            // Check sufficient funds
            if from_balance < *amount {
                anyhow::bail!(
                    "Insufficient balance: account {} has {}, needs {}",
                    from,
                    from_balance,
                    amount
                );
            }
            
            // Update balances
            self.update_balance(*from, from_balance - amount)?;
            self.update_balance(*to, to_balance + amount)?;
            
            debug!("Transfer: {} → {} ({})", from, to, amount);
        }
        
        // Update block height metadata
        let metadata_key = b"state:metadata";
        if let Some(bytes) = self.db.get(metadata_key)? {
            let mut metadata: StateMetadata = bincode::deserialize(&bytes)?;
            metadata.block_height = block_height;
            self.db.put(metadata_key, bincode::serialize(&metadata)?)?;
        }
        
        Ok(())
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct StateMetadata {
    total_supply: f64,
    block_height: u64,
    account_count: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct AccountMetadata {
    fingerprint: [u8; 32],
    homotopy_class_id: [u8; 32],
    nonce: u64,
    last_update: u64,
    connected_to: Vec<u64>,  // Serialized HashSet
    rotation_count: u32,
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;
    
    #[test]
    fn test_state_storage() {
        let dir = tempdir().unwrap();
        let db = super::super::sheaf_store::init_sheaf_db(dir.path()).unwrap();
        let store = StateStore::new(Arc::new(db));
        
        // Create state
        let mut state = GlobalState::new();
        let mut acc0 = AccountState::new(0, [0; 32], [1; 32], 1000.0);
        acc0.nonce = 1;
        state.accounts.push(acc0);
        
        let mut acc1 = AccountState::new(1, [2; 32], [1; 32], 500.0);
        acc1.nonce = 2;
        state.accounts.push(acc1);
        
        state.total_supply = 1500.0;
        state.block_height = 10;
        
        // Store
        store.store_state(&state).unwrap();
        
        // Load
        let loaded = store.load_state().unwrap();
        assert_eq!(loaded.accounts.len(), 2);
        assert_eq!(loaded.get_balance(0), 1000.0);
        assert_eq!(loaded.get_balance(1), 500.0);
        assert_eq!(loaded.total_supply, 1500.0);
        assert_eq!(loaded.block_height, 10);
    }
    
    #[test]
    fn test_state_transition() {
        let dir = tempdir().unwrap();
        let db = super::super::sheaf_store::init_sheaf_db(dir.path()).unwrap();
        let store = StateStore::new(Arc::new(db));
        
        // Initialize accounts
        store.update_balance(0, 1000.0).unwrap();
        store.update_balance(1, 500.0).unwrap();
        
        // Apply transfer
        let transfers = vec![(0, 1, 200.0)];
        store.apply_transition(&transfers, 1).unwrap();
        
        // Check balances
        assert_eq!(store.get_balance(0).unwrap(), 800.0);
        assert_eq!(store.get_balance(1).unwrap(), 700.0);
    }
    
    #[test]
    fn test_insufficient_balance() {
        let dir = tempdir().unwrap();
        let db = super::super::sheaf_store::init_sheaf_db(dir.path()).unwrap();
        let store = StateStore::new(Arc::new(db));
        
        store.update_balance(0, 100.0).unwrap();
        store.update_balance(1, 0.0).unwrap();
        
        // Try to transfer more than available
        let transfers = vec![(0, 1, 200.0)];
        let result = store.apply_transition(&transfers, 1);
        
        assert!(result.is_err());
    }
}
