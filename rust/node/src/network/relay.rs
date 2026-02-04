// Relay Node Management
//
// Corresponds to Python:
// - src/chain/routing.py: RelayNode, RelayNetwork

use std::collections::HashMap;

pub struct RelayNode {
    pub address: String,
    pub fingerprint: [u8; 32],
    // TODO: FiberBundle will be passed from Python
}

impl RelayNode {
    pub fn new(address: String, fingerprint: [u8; 32]) -> Self {
        Self { address, fingerprint }
    }
}

pub struct RelayNetwork {
    relays: HashMap<[u8; 32], RelayNode>,
}

impl RelayNetwork {
    pub fn new() -> Self {
        Self {
            relays: HashMap::new(),
        }
    }
    
    pub fn register_relay(&mut self, relay: RelayNode) {
        self.relays.insert(relay.fingerprint, relay);
    }
    
    pub fn get_relay(&self, fingerprint: &[u8; 32]) -> Option<&RelayNode> {
        self.relays.get(fingerprint)
    }
    
    pub fn relay_count(&self) -> usize {
        self.relays.len()
    }
}
