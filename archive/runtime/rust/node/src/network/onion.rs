#![allow(dead_code, unused_imports)]
// Sheaf Onion Routing - Python Bridge
//
// Calls Python onion service at localhost:9934 for:
// - Wrapping transactions in onion layers
// - Peeling layers at relay nodes
//
// This is temporary until onion logic is ported to Rust.

use anyhow::{anyhow, Result};
use serde::{Deserialize, Serialize};
use tracing::{debug, info, warn};

/// Default Python onion service address
const ONION_SERVICE_URL: &str = "http://127.0.0.1:9934";

/// Onion router that bridges to Python service
pub struct OnionRouter {
    service_url: String,
    client: reqwest::Client,
}

/// Serialized onion packet (for network transmission)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OnionPacket {
    /// Base64-encoded encrypted layers
    pub layers: Vec<String>,
    /// Path hints for each layer (relay navigation)
    pub path_hints: Vec<Vec<i64>>,
    /// Current layer index (relays increment this)
    pub current_layer: u64,
}

impl OnionPacket {
    /// Serialize to bytes for network transmission
    pub fn to_bytes(&self) -> Result<Vec<u8>> {
        bincode::serialize(self).map_err(|e| anyhow!("Serialize error: {}", e))
    }
    
    /// Deserialize from network bytes
    pub fn from_bytes(bytes: &[u8]) -> Result<Self> {
        bincode::deserialize(bytes).map_err(|e| anyhow!("Deserialize error: {}", e))
    }
}

/// Response from wrap endpoint
#[derive(Deserialize)]
struct WrapResponse {
    packet: Option<OnionPacket>,
    entry_relay: Option<String>,
    error: Option<String>,
}

/// Response from peel endpoint
#[derive(Deserialize)]
struct PeelResponse {
    data: Option<String>,
    is_final: Option<bool>,
    packet: Option<OnionPacket>,
    error: Option<String>,
}

impl OnionRouter {
    /// Create new onion router connecting to Python service
    pub fn new() -> Self {
        Self::with_url(ONION_SERVICE_URL)
    }
    
    /// Create with custom service URL
    pub fn with_url(url: &str) -> Self {
        Self {
            service_url: url.to_string(),
            client: reqwest::Client::new(),
        }
    }
    
    /// Check if Python onion service is available
    pub async fn is_available(&self) -> bool {
        match self.client
            .get(format!("{}/health", self.service_url))
            .send()
            .await
        {
            Ok(resp) => resp.status().is_success(),
            Err(_) => false,
        }
    }
    
    /// Wrap transaction in onion layers
    ///
    /// Calls Python: POST /onion/wrap
    pub async fn wrap_transaction(&self, tx_bytes: Vec<u8>, hop_count: u8) -> Result<(OnionPacket, String)> {
        use base64::{Engine, engine::general_purpose::STANDARD};
        
        let message_b64 = STANDARD.encode(&tx_bytes);
        
        let request = serde_json::json!({
            "message": message_b64,
            "hop_count": hop_count
        });
        
        debug!("Wrapping transaction ({} bytes) in {} hops", tx_bytes.len(), hop_count);
        
        let response = self.client
            .post(format!("{}/onion/wrap", self.service_url))
            .json(&request)
            .send()
            .await
            .map_err(|e| anyhow!("Failed to contact onion service: {}", e))?;
        
        let wrap_response: WrapResponse = response.json().await
            .map_err(|e| anyhow!("Invalid response from onion service: {}", e))?;
        
        if let Some(error) = wrap_response.error {
            return Err(anyhow!("Onion wrap failed: {}", error));
        }
        
        let packet = wrap_response.packet
            .ok_or_else(|| anyhow!("No packet in response"))?;
        let entry_relay = wrap_response.entry_relay
            .ok_or_else(|| anyhow!("No entry relay in response"))?;
        
        info!("✅ Transaction wrapped in {} layers, entry: {}...", 
              packet.layers.len(),
              &entry_relay[..16.min(entry_relay.len())]);
        
        Ok((packet, entry_relay))
    }
    
    /// Peel one onion layer (relay processing)
    ///
    /// Calls Python: POST /onion/peel
    pub async fn peel_layer(
        &self,
        packet: OnionPacket,
        relay_fingerprint: &[u8],
    ) -> Result<(Vec<u8>, bool, OnionPacket)> {
        use base64::{Engine, engine::general_purpose::STANDARD};
        
        let fingerprint_b64 = STANDARD.encode(relay_fingerprint);
        
        let request = serde_json::json!({
            "packet": packet,
            "relay_fingerprint": fingerprint_b64
        });
        
        debug!("Peeling layer {} for relay {}...", 
               packet.current_layer,
               &fingerprint_b64[..16.min(fingerprint_b64.len())]);
        
        let response = self.client
            .post(format!("{}/onion/peel", self.service_url))
            .json(&request)
            .send()
            .await
            .map_err(|e| anyhow!("Failed to contact onion service: {}", e))?;
        
        let peel_response: PeelResponse = response.json().await
            .map_err(|e| anyhow!("Invalid response from onion service: {}", e))?;
        
        if let Some(error) = peel_response.error {
            return Err(anyhow!("Onion peel failed: {}", error));
        }
        
        let data_b64 = peel_response.data
            .ok_or_else(|| anyhow!("No data in response"))?;
        let data = STANDARD.decode(&data_b64)
            .map_err(|e| anyhow!("Invalid base64 data: {}", e))?;
        
        let is_final = peel_response.is_final.unwrap_or(false);
        let updated_packet = peel_response.packet
            .ok_or_else(|| anyhow!("No updated packet in response"))?;
        
        if is_final {
            info!("🎯 Final destination reached, {} bytes decrypted", data.len());
        } else {
            debug!("Layer peeled, forwarding to next hop");
        }
        
        Ok((data, is_final, updated_packet))
    }
    
    /// Register this node as a relay (for testing)
    pub async fn register_as_relay(&self, address: &str) -> Result<String> {
        let request = serde_json::json!({
            "address": address
        });
        
        let response = self.client
            .post(format!("{}/relay/register", self.service_url))
            .json(&request)
            .send()
            .await
            .map_err(|e| anyhow!("Failed to register relay: {}", e))?;
        
        #[derive(Deserialize)]
        struct RegisterResponse {
            success: Option<bool>,
            fingerprint: Option<String>,
            error: Option<String>,
        }
        
        let reg_response: RegisterResponse = response.json().await
            .map_err(|e| anyhow!("Invalid register response: {}", e))?;
        
        if let Some(error) = reg_response.error {
            return Err(anyhow!("Registration failed: {}", error));
        }
        
        let fingerprint = reg_response.fingerprint
            .ok_or_else(|| anyhow!("No fingerprint in response"))?;
        
        info!("📡 Registered as relay: {}...", &fingerprint[..16.min(fingerprint.len())]);
        
        Ok(fingerprint)
    }
    
    /// Fallback: Pass through without onion (when Python service unavailable)
    pub fn passthrough(&self, tx_bytes: Vec<u8>) -> OnionPacket {
        use base64::{Engine, engine::general_purpose::STANDARD};
        
        warn!("⚠️  Onion service unavailable - using passthrough (NO PRIVACY)");
        
        OnionPacket {
            layers: vec![STANDARD.encode(&tx_bytes)],
            path_hints: vec![vec![]],
            current_layer: 0,
        }
    }
}

impl Default for OnionRouter {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_onion_packet_serialization() {
        let packet = OnionPacket {
            layers: vec!["AAAA".to_string(), "BBBB".to_string()],
            path_hints: vec![vec![1, 2, 3], vec![4, 5]],
            current_layer: 0,
        };
        
        let bytes = packet.to_bytes().unwrap();
        let restored = OnionPacket::from_bytes(&bytes).unwrap();
        
        assert_eq!(packet.layers, restored.layers);
        assert_eq!(packet.path_hints, restored.path_hints);
        assert_eq!(packet.current_layer, restored.current_layer);
    }
}
