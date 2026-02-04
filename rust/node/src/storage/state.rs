// SheafState Storage
//
// Stores the global state as a section of the PUBLIC_STALK bundle
// State = Γ(X, PUBLIC_STALK) where X is the nerve of accounts

use anyhow::Result;
use rocksdb::DB;
use std::sync::Arc;
use serde::{Deserialize, Serialize};
use tracing::{debug, info};

use super::sheaf_store::{SheafStore, Stalk, StalkContext};

/// Account state (balance at a vertex)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AccountState {
    pub account_id: u64,
    pub balance: f64,
    pub nonce: u64,
    pub last_update: u64,  // Block height
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
}

/// State storage manager
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
        
        // Store individual account metadata (nonce, last_update)
        for account in &state.accounts {
            let key = format!("account:{}:meta", account.account_id);
            let meta = AccountMetadata {
                nonce: account.nonce,
                last_update: account.last_update,
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
                    nonce: 0,
                    last_update: 0,
                },
            };
            
            accounts.push(AccountState {
                account_id,
                balance,
                nonce: meta.nonce,
                last_update: meta.last_update,
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
    nonce: u64,
    last_update: u64,
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
        state.accounts.push(AccountState {
            account_id: 0,
            balance: 1000.0,
            nonce: 1,
            last_update: 0,
        });
        state.accounts.push(AccountState {
            account_id: 1,
            balance: 500.0,
            nonce: 2,
            last_update: 0,
        });
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
