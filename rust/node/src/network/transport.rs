// P2P Transport Layer (libp2p)
//
// Handles actual network I/O:
// - TCP transport with Noise encryption
// - GossipSub for transaction/block propagation
// - Kademlia DHT for peer discovery
//
//PARALLEL TRANSPORT (from the Grothendieck fibration):
//
//    The restriction maps R_{v→e}: F_v → F_e in the sheaf are parallel
//    transport in the fiber bundle (see geometry/fiber_bundle.py). These
//    are orthogonal matrices — they preserve norms and inner products.
//    The Laplacian Δ = δ*δ is built from these transport maps.

//    Knowing Δ = knowing the parallel transport structure = knowing the
//    fibration secret. This is why the lattice problem (which requires
//    knowing Δ) is only the shadow: the actual secret is the connection
//    on the Grothendieck fibration.
//

// The onion routing logic is separate (onion.rs / Python)

use anyhow::{Context, Result};
use futures::StreamExt;
use libp2p::{
    gossipsub::{self, IdentTopic, MessageAuthenticity, MessageId, ValidationMode},
    identity::Keypair,
    kad::{self, store::MemoryStore},
    noise,
    swarm::{NetworkBehaviour, SwarmEvent},
    tcp, yamux, Multiaddr, PeerId, Swarm,
};
use serde::{Deserialize, Serialize};
use std::{
    collections::hash_map::DefaultHasher,
    hash::{Hash, Hasher},
    sync::Arc,
    time::Duration,
};
use tokio::sync::{mpsc, RwLock};
use tracing::{debug, error, info, warn};

// =============================================================================
// MESSAGE TYPES
// =============================================================================

/// Topics for gossipsub
pub const TOPIC_TRANSACTIONS: &str = "hcrypt/tx/1.0.0";
pub const TOPIC_BLOCKS: &str = "hcrypt/block/1.0.0";
pub const TOPIC_ORACLE: &str = "hcrypt/oracle/1.0.0";

/// Network message types
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum NetworkMessage {
    /// New transaction (onion-wrapped)
    Transaction {
        /// Onion packet (opaque to network layer)
        onion_packet: Vec<u8>,
        /// Spectral fingerprint hint (for routing)
        fingerprint_hint: Vec<u8>,
    },
    
    /// New block announcement
    Block {
        /// Block height
        height: u64,
        /// Block hash
        hash: Vec<u8>,
        /// Full block data
        block_data: Vec<u8>,
    },
    
    /// Oracle submission (spectral proof)
    OracleProof {
        /// Vertex ID
        vertex_id: u64,
        /// Commitment hash
        commitment: Vec<u8>,
        /// Spectral gap (scaled to u64)
        spectral_gap_scaled: u64,
    },
}

// =============================================================================
// NETWORK BEHAVIOUR
// =============================================================================

/// Custom network behaviour combining:
/// - GossipSub: for broadcast
/// - Kademlia: for peer discovery
#[derive(NetworkBehaviour)]
pub struct HcryptBehaviour {
    /// Gossip for tx/block propagation
    pub gossipsub: gossipsub::Behaviour,
    /// DHT for peer discovery
    pub kademlia: kad::Behaviour<MemoryStore>,
}

// =============================================================================
// P2P TRANSPORT
// =============================================================================

/// P2P transport layer using libp2p
pub struct P2PTransport {
    /// Our peer ID
    peer_id: PeerId,
    /// Channel to send commands to swarm task
    cmd_tx: mpsc::Sender<SwarmCommand>,
    /// Channel to receive events from swarm
    event_rx: Arc<RwLock<mpsc::Receiver<TransportEvent>>>,
    /// Known peers
    peers: Arc<RwLock<Vec<PeerId>>>,
}

/// Commands to send to the swarm task
#[derive(Debug)]
enum SwarmCommand {
    /// Publish to gossip topic
    Publish { topic: String, data: Vec<u8> },
    /// Bootstrap from known peers
    Bootstrap { addrs: Vec<Multiaddr> },
    /// Shutdown
    Shutdown,
}

/// Events from the transport
#[derive(Debug, Clone)]
pub enum TransportEvent {
    /// Received gossip message
    GossipMessage {
        topic: String,
        data: Vec<u8>,
        source: Option<PeerId>,
    },
    /// New peer connected
    PeerConnected(PeerId),
    /// Peer disconnected
    PeerDisconnected(PeerId),
}

impl P2PTransport {
    /// Create new P2P transport and start background task
    pub async fn new(port: u16) -> Result<Self> {
        let keypair = Keypair::generate_ed25519();
        let peer_id = PeerId::from(keypair.public());
        
        info!("🌐 Initializing P2P transport");
        info!("   Peer ID: {}", peer_id);
        info!("   Port: {}", port);
        
        // Create channels
        let (cmd_tx, cmd_rx) = mpsc::channel(256);
        let (event_tx, event_rx) = mpsc::channel(256);
        
        // Build the swarm
        let swarm = Self::build_swarm(keypair, port)?;
        
        let peers = Arc::new(RwLock::new(Vec::new()));
        let peers_clone = peers.clone();
        
        // Spawn swarm task
        tokio::spawn(async move {
            Self::swarm_task(swarm, cmd_rx, event_tx, peers_clone).await;
        });
        
        Ok(Self {
            peer_id,
            cmd_tx,
            event_rx: Arc::new(RwLock::new(event_rx)),
            peers,
        })
    }
    
    /// Build libp2p swarm with all protocols
    fn build_swarm(keypair: Keypair, _port: u16) -> Result<Swarm<HcryptBehaviour>> {
        // GossipSub config
        let gossip_config = gossipsub::ConfigBuilder::default()
            .heartbeat_interval(Duration::from_secs(1))
            .validation_mode(ValidationMode::Strict)
            .message_id_fn(|msg| {
                let mut hasher = DefaultHasher::new();
                msg.data.hash(&mut hasher);
                MessageId::from(hasher.finish().to_be_bytes().to_vec())
            })
            .build()
            .map_err(|e| anyhow::anyhow!("GossipSub config error: {}", e))?;
        
        let gossipsub = gossipsub::Behaviour::new(
            MessageAuthenticity::Signed(keypair.clone()),
            gossip_config,
        )
        .map_err(|e| anyhow::anyhow!("GossipSub error: {}", e))?;
        
        // Kademlia
        let store = MemoryStore::new(PeerId::from(keypair.public()));
        let kademlia = kad::Behaviour::new(
            PeerId::from(keypair.public()),
            store,
        );
        
        let behaviour = HcryptBehaviour {
            gossipsub,
            kademlia,
        };
        
        // Build swarm using the new builder API
        let swarm = libp2p::SwarmBuilder::with_existing_identity(keypair)
            .with_tokio()
            .with_tcp(
                tcp::Config::default(),
                noise::Config::new,
                yamux::Config::default,
            )?
            .with_behaviour(|_key| Ok(behaviour))?
            .with_swarm_config(|cfg| {
                cfg.with_idle_connection_timeout(Duration::from_secs(60))
            })
            .build();
        
        Ok(swarm)
    }
    
    /// Background task running the swarm
    async fn swarm_task(
        mut swarm: Swarm<HcryptBehaviour>,
        mut cmd_rx: mpsc::Receiver<SwarmCommand>,
        event_tx: mpsc::Sender<TransportEvent>,
        peers: Arc<RwLock<Vec<PeerId>>>,
    ) {
        // Subscribe to topics
        let topics = [
            IdentTopic::new(TOPIC_TRANSACTIONS),
            IdentTopic::new(TOPIC_BLOCKS),
            IdentTopic::new(TOPIC_ORACLE),
        ];
        
        for topic in &topics {
            if let Err(e) = swarm.behaviour_mut().gossipsub.subscribe(topic) {
                error!("Failed to subscribe to {}: {:?}", topic, e);
            }
        }
        
        // Listen on all interfaces
        let listen_addr: Multiaddr = "/ip4/0.0.0.0/tcp/0".parse().unwrap();
        if let Err(e) = swarm.listen_on(listen_addr) {
            error!("Failed to listen: {:?}", e);
        }
        
        loop {
            tokio::select! {
                // Handle commands
                Some(cmd) = cmd_rx.recv() => {
                    match cmd {
                        SwarmCommand::Publish { topic, data } => {
                            let topic = IdentTopic::new(&topic);
                            if let Err(e) = swarm.behaviour_mut().gossipsub.publish(topic, data) {
                                warn!("Failed to publish: {:?}", e);
                            }
                        }
                        SwarmCommand::Bootstrap { addrs } => {
                            for addr in addrs {
                                if let Err(e) = swarm.dial(addr.clone()) {
                                    warn!("Failed to dial {}: {:?}", addr, e);
                                }
                            }
                        }
                        SwarmCommand::Shutdown => {
                            info!("Swarm shutdown requested");
                            break;
                        }
                    }
                }
                
                // Handle swarm events
                event = swarm.select_next_some() => {
                    match event {
                        SwarmEvent::Behaviour(HcryptBehaviourEvent::Gossipsub(gossipsub::Event::Message {
                            propagation_source,
                            message,
                            ..
                        })) => {
                            let topic = message.topic.to_string();
                            debug!("Received gossip on {}: {} bytes", topic, message.data.len());
                            
                            let _ = event_tx.send(TransportEvent::GossipMessage {
                                topic,
                                data: message.data,
                                source: Some(propagation_source),
                            }).await;
                        }
                        
                        SwarmEvent::ConnectionEstablished { peer_id, .. } => {
                            info!("Connected to peer: {}", peer_id);
                            peers.write().await.push(peer_id);
                            let _ = event_tx.send(TransportEvent::PeerConnected(peer_id)).await;
                        }
                        
                        SwarmEvent::ConnectionClosed { peer_id, .. } => {
                            info!("Disconnected from peer: {}", peer_id);
                            peers.write().await.retain(|p| p != &peer_id);
                            let _ = event_tx.send(TransportEvent::PeerDisconnected(peer_id)).await;
                        }
                        
                        SwarmEvent::NewListenAddr { address, .. } => {
                            info!("Listening on: {}", address);
                        }
                        
                        _ => {}
                    }
                }
            }
        }
    }
    
    // =========================================================================
    // PUBLIC API
    // =========================================================================
    
    /// Get our peer ID
    pub fn peer_id(&self) -> &PeerId {
        &self.peer_id
    }
    
    /// Get connected peers
    pub async fn peers(&self) -> Vec<PeerId> {
        self.peers.read().await.clone()
    }
    
    /// Bootstrap from known peers
    pub async fn bootstrap(&self, addrs: Vec<Multiaddr>) -> Result<()> {
        self.cmd_tx
            .send(SwarmCommand::Bootstrap { addrs })
            .await
            .context("Failed to send bootstrap command")?;
        Ok(())
    }
    
    /// Broadcast transaction to network
    pub async fn broadcast_transaction(&self, onion_packet: Vec<u8>, fingerprint_hint: Vec<u8>) -> Result<()> {
        let msg = NetworkMessage::Transaction {
            onion_packet,
            fingerprint_hint,
        };
        let data = bincode::serialize(&msg)?;
        
        self.cmd_tx
            .send(SwarmCommand::Publish {
                topic: TOPIC_TRANSACTIONS.to_string(),
                data,
            })
            .await
            .context("Failed to send publish command")?;
        
        Ok(())
    }
    
    /// Broadcast block to network
    pub async fn broadcast_block(&self, height: u64, hash: Vec<u8>, block_data: Vec<u8>) -> Result<()> {
        let msg = NetworkMessage::Block {
            height,
            hash,
            block_data,
        };
        let data = bincode::serialize(&msg)?;
        
        self.cmd_tx
            .send(SwarmCommand::Publish {
                topic: TOPIC_BLOCKS.to_string(),
                data,
            })
            .await
            .context("Failed to send publish command")?;
        
        Ok(())
    }
    
    /// Broadcast oracle proof
    pub async fn broadcast_oracle_proof(&self, vertex_id: u64, commitment: Vec<u8>, spectral_gap: f64) -> Result<()> {
        let msg = NetworkMessage::OracleProof {
            vertex_id,
            commitment,
            spectral_gap_scaled: (spectral_gap * 1_000_000.0) as u64,
        };
        let data = bincode::serialize(&msg)?;
        
        self.cmd_tx
            .send(SwarmCommand::Publish {
                topic: TOPIC_ORACLE.to_string(),
                data,
            })
            .await
            .context("Failed to send publish command")?;
        
        Ok(())
    }
    
    /// Receive next event
    pub async fn recv_event(&self) -> Option<TransportEvent> {
        self.event_rx.write().await.recv().await
    }
    
    /// Shutdown the transport
    pub async fn shutdown(&self) -> Result<()> {
        self.cmd_tx
            .send(SwarmCommand::Shutdown)
            .await
            .context("Failed to send shutdown command")?;
        Ok(())
    }
}

// =============================================================================
// TESTS
// =============================================================================

#[cfg(test)]
mod tests {
    use super::*;
    
    #[tokio::test]
    async fn test_transport_creation() {
        let transport = P2PTransport::new(0).await.unwrap();
        println!("Created transport with peer ID: {}", transport.peer_id());
    }
}
