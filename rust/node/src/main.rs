// Homotopical-Encrypt Node
// Layer 1 blockchain with Proof of Value consensus

use anyhow::Result;
use clap::Parser;
use std::path::Path;
use std::sync::Arc;
use tracing::{debug, info, warn, error};

mod consensus;
mod network;
mod storage;
mod rpc;
mod types;

use network::P2PTransport;
use storage::{BlockStore, KeyImageStore, StateStore, SheafStore, init_sheaf_db};

#[derive(Parser, Debug)]
#[command(name = "hcrypt-node")]
#[command(about = "Homotopical-Encrypt Layer 1 Node", long_about = None)]
struct Args {
    /// RPC port
    #[arg(long, default_value = "9933")]
    rpc_port: u16,

    /// P2P port
    #[arg(long, default_value = "30333")]
    p2p_port: u16,

    /// Data directory
    #[arg(long, default_value = "./data")]
    data_dir: String,

    /// Run as validator
    #[arg(long, default_value = "false")]
    validator: bool,
    
    /// Bootstrap peers (multiaddr format)
    #[arg(long)]
    bootnodes: Vec<String>,
}

/// Node state container
struct Node {
    /// P2P transport
    transport: P2PTransport,
    /// Block storage (Arc-wrapped for RPC sharing)
    block_store: Arc<BlockStore>,
    /// Key image store (double-spend prevention)
    key_image_store: Arc<KeyImageStore>,
    /// State store (account balances)
    state_store: Arc<StateStore>,
    /// Sheaf store (geometric data)
    sheaf_store: Arc<SheafStore>,
    /// Is this a validator?
    is_validator: bool,
    /// RPC port
    rpc_port: u16,
}

impl Node {
    async fn new(args: &Args) -> Result<Self> {
        // Initialize storage
        info!("📦 Initializing storage at {}", args.data_dir);
        let data_path = Path::new(&args.data_dir);
        std::fs::create_dir_all(data_path)?;
        
        let db = init_sheaf_db(data_path)?;
        let db = Arc::new(db);
        
        // Wrap stores in Arc for RPC sharing
        let block_store = Arc::new(BlockStore::new(db.clone()));
        let key_image_store = Arc::new(KeyImageStore::new(db.clone()));
        let state_store = Arc::new(StateStore::new(db.clone()));
        let sheaf_store = Arc::new(SheafStore::new(db.clone()));
        
        // Check chain tip
        if let Some((height, hash)) = block_store.get_chain_tip()? {
            info!("📊 Chain tip: height={} hash={}", height, hash);
        } else {
            info!("📊 Empty chain - genesis needed");
        }
        
        // Initialize P2P transport
        info!("🌐 Starting P2P network on port {}", args.p2p_port);
        let transport = P2PTransport::new(args.p2p_port).await?;
        info!("   Peer ID: {}", transport.peer_id());
        
        // Bootstrap from known peers
        if !args.bootnodes.is_empty() {
            info!("🔗 Bootstrapping from {} peers", args.bootnodes.len());
            let addrs: Vec<_> = args.bootnodes
                .iter()
                .filter_map(|s| s.parse().ok())
                .collect();
            transport.bootstrap(addrs).await?;
        }
        
        Ok(Self {
            transport,
            block_store,
            key_image_store,
            state_store,
            sheaf_store,
            is_validator: args.validator,
            rpc_port: args.rpc_port,
        })
    }
    
    /// Start the RPC server in a background task
    fn start_rpc_server(&self) {
        let block_store = self.block_store.clone();
        let state_store = self.state_store.clone();
        let key_image_store = self.key_image_store.clone();
        let sheaf_store = self.sheaf_store.clone();
        let is_validator = self.is_validator;
        let rpc_addr = format!("127.0.0.1:{}", self.rpc_port);
        
        tokio::spawn(async move {
            if let Err(e) = rpc::run_rpc_server(
                &rpc_addr,
                block_store,
                state_store,
                key_image_store,
                sheaf_store,
                is_validator,
            ).await {
                error!("RPC server error: {}", e);
            }
        });
    }
    
    /// Main event loop
    async fn run(&self) -> Result<()> {
        info!("🎯 Node running...");
        
        if self.is_validator {
            info!("⚡ Running as VALIDATOR - will produce blocks");
        } else {
            info!("📡 Running as FULL NODE - sync and relay only");
        }
        
        // Start RPC server
        self.start_rpc_server();
        
        loop {
            tokio::select! {
                // Handle P2P events
                event = self.transport.recv_event() => {
                    if let Some(evt) = event {
                        self.handle_network_event(evt).await;
                    }
                }
                
                // Handle shutdown signal
                _ = tokio::signal::ctrl_c() => {
                    info!("👋 Shutdown signal received");
                    break;
                }
            }
        }
        
        // Graceful shutdown
        self.transport.shutdown().await?;
        info!("✅ Node shut down cleanly");
        
        Ok(())
    }
    
    /// Handle network events
    async fn handle_network_event(&self, event: network::transport::TransportEvent) {
        use network::transport::{TransportEvent, NetworkMessage};
        
        match event {
            TransportEvent::GossipMessage { topic, data, source: _ } => {
                debug!("Received gossip on {} ({} bytes)", topic, data.len());
                
                // Parse message
                if let Ok(msg) = bincode::deserialize::<NetworkMessage>(&data) {
                    match msg {
                        NetworkMessage::Transaction { onion_packet, fingerprint_hint } => {
                            self.handle_transaction(onion_packet, fingerprint_hint).await;
                        }
                        NetworkMessage::Block { height, hash, block_data } => {
                            self.handle_block(height, hash, block_data).await;
                        }
                        NetworkMessage::OracleProof { vertex_id, commitment, spectral_gap_scaled } => {
                            self.handle_oracle_proof(vertex_id, commitment, spectral_gap_scaled).await;
                        }
                    }
                } else {
                    warn!("Failed to parse network message");
                }
            }
            
            TransportEvent::PeerConnected(peer) => {
                info!("🤝 New peer connected: {}", peer);
            }
            
            TransportEvent::PeerDisconnected(peer) => {
                info!("👋 Peer disconnected: {}", peer);
            }
        }
    }
    
    /// Handle incoming transaction
    async fn handle_transaction(&self, onion_packet: Vec<u8>, fingerprint_hint: Vec<u8>) {
        debug!("📩 Received transaction ({} bytes, hint: {} bytes)", 
               onion_packet.len(), fingerprint_hint.len());
        
        // TODO: 
        // 1. Peel onion layer (if we're a relay)
        // 2. Validate transaction
        // 3. Check key image (double-spend)
        // 4. Add to mempool
        // 5. If validator, include in next block
    }
    
    /// Handle incoming block
    async fn handle_block(&self, height: u64, hash: Vec<u8>, block_data: Vec<u8>) {
        debug!("📦 Received block at height {} ({} bytes)", height, block_data.len());
        
        // TODO:
        // 1. Validate spectral proof (call oracle)
        // 2. Verify parent hash
        // 3. Apply transactions
        // 4. Store block
        // 5. Update chain tip
    }
    
    /// Handle incoming oracle proof
    async fn handle_oracle_proof(&self, vertex_id: u64, commitment: Vec<u8>, spectral_gap_scaled: u64) {
        let spectral_gap = spectral_gap_scaled as f64 / 1_000_000.0;
        debug!("🔮 Received oracle proof for vertex {} (gap: {:.6})", vertex_id, spectral_gap);
        
        // TODO:
        // 1. Validate proof structure
        // 2. Store in sheaf store
        // 3. If validator, use for block production
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    // Initialize logging
    tracing_subscriber::fmt()
        .with_env_filter("info,hcrypt_node=debug,libp2p_gossipsub=warn,libp2p_kad=warn")
        .init();

    let args = Args::parse();

    info!("🚀 Starting Homotopical-Encrypt Node");
    info!("   RPC port: {}", args.rpc_port);
    info!("   P2P port: {}", args.p2p_port);
    info!("   Data dir: {}", args.data_dir);
    info!("   Validator: {}", args.validator);

    // Initialize node
    let node = Node::new(&args).await?;
    
    // Run main event loop (includes RPC server)
    node.run().await?;

    Ok(())
}
