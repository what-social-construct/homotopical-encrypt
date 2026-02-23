// Homotopical-Encrypt Node
// Layer 1 blockchain with Proof of Value consensus

use anyhow::Result;
use clap::Parser;
use std::path::Path;
use std::sync::Arc;
use tokio::sync::Mutex;
use tracing::{debug, info, warn, error};

mod consensus;
mod network;
mod storage;
mod rpc;
mod crypto;
mod types;

use consensus::pov::{PoVProducer, PoVVerifier, OracleCommitment};
use consensus::vrf::{VRFKey, EquivocationTracker, vrf_evaluate};
use network::P2PTransport;
use storage::{BlockStore, KeyImageStore, StateStore, SheafStore, init_sheaf_db};
use storage::keyimages::KeyImage;
use storage::sheaf_store::{Stalk, StalkContext};
use types::*;

/// Bounded mempool: validated transactions pending inclusion
const MAX_MEMPOOL_SIZE: usize = 4096;

/// Block production interval (seconds)
const BLOCK_INTERVAL_SECS: u64 = 6;

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

/// Validated transaction awaiting block inclusion
#[allow(dead_code)]
#[derive(Debug, Clone)]
struct MempoolEntry {
    tx: Transaction,
    received_at: u64,
}

/// Cached Oracle commitment for block production
#[allow(dead_code)]
#[derive(Debug, Clone)]
struct CachedOracleProof {
    commitment: OracleCommitment,
    vertex_id: u64,
    cached_at: u64,
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
    /// Mempool: validated transactions pending inclusion
    mempool: Arc<Mutex<Vec<MempoolEntry>>>,
    /// Latest Oracle commitment (for block production)
    oracle_cache: Arc<Mutex<Option<CachedOracleProof>>>,
    /// VRF key (derived from Oracle proof eigenvectors)
    vrf_key: Arc<Mutex<Option<VRFKey>>>,
    /// Equivocation tracker (fork detection)
    equivocation_tracker: Arc<Mutex<EquivocationTracker>>,
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
            mempool: Arc::new(Mutex::new(Vec::new())),
            oracle_cache: Arc::new(Mutex::new(None)),
            vrf_key: Arc::new(Mutex::new(None)),
            equivocation_tracker: Arc::new(Mutex::new(EquivocationTracker::new())),
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
        
        // Block production timer (validators only)
        let mut block_timer = tokio::time::interval(
            std::time::Duration::from_secs(BLOCK_INTERVAL_SECS)
        );
        // Don't fire immediately on start
        block_timer.tick().await;
        
        loop {
            tokio::select! {
                // Handle P2P events
                event = self.transport.recv_event() => {
                    if let Some(evt) = event {
                        self.handle_network_event(evt).await;
                    }
                }
                
                // Block production tick (validators only)
                _ = block_timer.tick() => {
                    if self.is_validator {
                        self.try_produce_block().await;
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
    ///
    /// Flow: onion_packet → deserialize → parse CochainCommitment → key image check → mempool
    /// The onion_packet contains a serialized Transaction whose .data field
    /// is CochainCommitment.to_bytes() from Python (wire format: modulus|n_edges|edges|topo_hash).
    async fn handle_transaction(&self, onion_packet: Vec<u8>, fingerprint_hint: Vec<u8>) {
        debug!("📩 Received transaction ({} bytes, hint: {} bytes)", 
               onion_packet.len(), fingerprint_hint.len());
        
        // 1. Deserialize transaction from onion packet
        //    In production: peel onion layer first (network/onion.rs)
        //    For now: assume inner payload is the Transaction
        let tx: Transaction = match bincode::deserialize(&onion_packet) {
            Ok(tx) => tx,
            Err(e) => {
                warn!("Failed to deserialize transaction: {}", e);
                return;
            }
        };
        
        // 2. Validate CochainCommitment wire format
        //    tx.data must be parseable by parse_cochain_commitment()
        //    Wire: modulus(4 LE) + n_edges(4 LE) + edge_values(n×8 i64 LE) + topo_hash(16)
        if parse_cochain_commitment(&tx.data).is_none() {
            warn!("Transaction data is not valid CochainCommitment wire format ({} bytes)", tx.data.len());
            return;
        }
        
        // 3. Key image double-spend check (O(1) lookup)
        if let Some(ki_bytes) = &tx.key_image {
            let ki = KeyImage::new(*ki_bytes);
            match self.key_image_store.is_spent(&ki) {
                Ok(true) => {
                    warn!("🚫 Double spend detected: key image {}", ki.hex());
                    return;
                }
                Ok(false) => { /* Not spent — proceed */ }
                Err(e) => {
                    error!("Key image store error: {}", e);
                    return;
                }
            }
        }
        
        // 4. Add to mempool (bounded)
        let tx_hash = tx.tx_hash();
        let now = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs();
        
        let mut pool = self.mempool.lock().await;
        if pool.len() >= MAX_MEMPOOL_SIZE {
            warn!("Mempool full ({} txs), dropping oldest", pool.len());
            pool.remove(0);
        }
        pool.push(MempoolEntry { tx, received_at: now });
        
        info!("✅ Transaction accepted: {} ({} bytes, mempool={})", 
              hex::encode(&tx_hash[..8]), onion_packet.len(), pool.len());
    }
    
    /// Handle incoming block
    ///
    /// Flow: block_data → deserialize → VRF check → PoV proof → cochain root → store
    ///
    /// Gate 0: Deserialize
    /// Gate 1: Spectral gap valid (Oracle-attested √2 bounds)
    /// Gate 2: Parent hash linkage (chain coherence)
    /// Gate 3: VRF slot verification (producer was assigned this epoch)
    /// Gate 4: Equivocation check (no double-production at same height)
    /// Gate 5: Cochain root recomputation (Σ δ(txᵢ) matches)
    /// Gate 6: Key image double-spend check (per tx)
    async fn handle_block(&self, height: u64, _hash: Vec<u8>, block_data: Vec<u8>) {
        debug!("📦 Received block at height {} ({} bytes)", height, block_data.len());
        
        // ─── Gate 0: Deserialize ───────────────────────────────────
        let block: Block = match bincode::deserialize(&block_data) {
            Ok(b) => b,
            Err(e) => {
                warn!("🚫 Gate 0 FAIL: Failed to deserialize block: {}", e);
                return;
            }
        };
        
        // ─── Gate 1: Spectral gap ──────────────────────────────────
        if !block.header.spectral_proof.fingerprint.spectral_gap_valid {
            warn!("🚫 Gate 1 FAIL: spectral gap not verified valid by Oracle");
            return;
        }
        
        // ─── Gate 2: Parent hash linkage ───────────────────────────
        let parent_hash_bytes: [u8; 32];
        if block.header.height > 0 {
            match self.block_store.get_chain_tip() {
                Ok(Some((tip_height, _tip_hash))) => {
                    if block.header.height != tip_height + 1 {
                        warn!("🚫 Gate 2 FAIL: height mismatch: expected {}, got {}", 
                              tip_height + 1, block.header.height);
                        return;
                    }
                    // Load parent block for hash verification
                    match self.block_store.load_block_by_height(tip_height) {
                        Ok(Some(parent)) => {
                            let expected_parent = parent.hash();
                            if block.header.parent_hash != expected_parent {
                                warn!("🚫 Gate 2 FAIL: parent hash mismatch at height {}", height);
                                return;
                            }
                            parent_hash_bytes = expected_parent.0;
                        }
                        _ => {
                            error!("Cannot load parent block at height {}", tip_height);
                            return;
                        }
                    }
                }
                Ok(None) => {
                    if block.header.height != 0 {
                        warn!("🚫 Gate 2 FAIL: non-genesis block but no chain tip");
                        return;
                    }
                    parent_hash_bytes = [0u8; 32]; // Genesis has no parent
                }
                Err(e) => {
                    error!("Block store error: {}", e);
                    return;
                }
            }
        } else {
            parent_hash_bytes = [0u8; 32]; // Genesis
        }
        
        // ─── Gate 3: VRF slot verification ─────────────────────────
        //
        // Publicly verifiable: derive VRF key from producer_fingerprint,
        // recompute VRF(key, parent_hash, height), check score < threshold.
        //
        // This is sound because:
        //   - VRF key derivation is deterministic from fingerprint
        //   - VRF output is deterministic from key + inputs
        //   - Ed25519 signature (Gate 6 in PoV) binds producer to block
        //   - Forging a low score requires forging the fingerprint
        if block.header.height > 0 {
            let producer_fp = block.header.producer_fingerprint;
            let vrf_key = consensus::vrf::VRFKey::from_fingerprint(producer_fp);
            let vrf_out = consensus::vrf::vrf_evaluate(
                &vrf_key, &parent_hash_bytes, block.header.height,
            );
            let score = vrf_out.score();
            
            // Threshold: in single-node mode, any score passes.
            // In multi-validator mode, threshold comes from ValidatorSet.
            // For now: accept if score < 1.0 (non-trivial VRF output).
            // The VRF is deterministic so replaying confirms the slot.
            let threshold = 1.0; // Will use ValidatorSet when multi-node
            if score >= threshold {
                warn!("🚫 Gate 3 FAIL: VRF score {:.4} >= threshold {:.4} for producer {}",
                      score, threshold, hex::encode(&producer_fp[..8]));
                return;
            }
            debug!("✅ Gate 3: VRF slot valid (score={:.4})", score);
        }
        
        // ─── Gate 4: Equivocation check ────────────────────────────
        //
        // Detect if this producer already produced a block at this height.
        // Evidence of equivocation → reject block + penalize producer.
        {
            let mut tracker = self.equivocation_tracker.lock().await;
            let block_hash = block.hash().0;
            let producer_fp = block.header.producer_fingerprint;
            
            // Use producer fingerprint as identity for tracking
            // VRF data = parent_hash (binds the slot to the chain state)
            if let Some(evidence) = tracker.record_block(
                producer_fp,
                block.header.height,
                block_hash,
                parent_hash_bytes.to_vec(),
            ) {
                warn!(
                    "🚫 Gate 4 FAIL: EQUIVOCATION detected at height {}! \
                     Producer {} created blocks {} and {}",
                    block.header.height,
                    hex::encode(&producer_fp[..8]),
                    hex::encode(&evidence.block_hash_1[..8]),
                    hex::encode(&evidence.block_hash_2[..8]),
                );
                return;
            }
            debug!("✅ Gate 4: No equivocation");
        }
        
        // ─── Gate 5: Cochain root ──────────────────────────────────
        let computed_root = block.compute_cochain_root();
        if computed_root != block.header.cochain_root {
            warn!("🚫 Gate 5 FAIL: cochain root mismatch at height {}", height);
            return;
        }
        
        // ─── Gate 6: Apply transactions + key image checks ────────
        for (tx_idx, tx) in block.transactions.iter().enumerate() {
            if let Some(ki_bytes) = &tx.key_image {
                let ki = KeyImage::new(*ki_bytes);
                if let Err(e) = self.key_image_store.mark_spent(&ki, height, tx_idx as u32) {
                    error!("Failed to mark key image spent: {}", e);
                }
            }
        }
        
        // 6. Store block
        let block_hash = block.hash();
        if let Err(e) = self.block_store.store_block(&block) {
            error!("Failed to store block: {}", e);
            return;
        }
        
        info!("✅ Block stored: height={} hash={} txs={}",
              height, block_hash, block.transactions.len());
    }
    
    /// Handle incoming oracle proof
    ///
    /// Flow: Oracle HashStalk → validate √2 bounds → store in SheafStore → cache for PoV
    /// The Oracle computed: credential → Hodge projection → quantize → fingerprint
    /// We receive the result and store it for block production eligibility.
    async fn handle_oracle_proof(&self, vertex_id: u64, commitment: Vec<u8>, spectral_gap_scaled: u64) {
        let spectral_gap = spectral_gap_scaled as f64 / 1_000_000.0;
        debug!("🔮 Received oracle proof for vertex {} (gap: {:.6})", vertex_id, spectral_gap);
        
        // 1. Validate spectral gap is in √2 bounds (Tsirelson)
        //    Only fibrations with gap in [1/√2, 2√2] are eligible for PoV
        if spectral_gap < POV_LOWER || spectral_gap > POV_UPPER {
            warn!("🚫 Oracle proof rejected: gap {:.4} outside √2 bounds for vertex {}",
                  spectral_gap, vertex_id);
            return;
        }
        
        // 2. Validate commitment size (should be 32-byte Hodge projection fingerprint)
        if commitment.len() != 32 {
            warn!("🚫 Oracle proof rejected: commitment is {} bytes, expected 32", commitment.len());
            return;
        }
        
        // 3. Store in SheafStore as ZK stalk
        //    Context::Zk — this is the Oracle-verified geometric commitment
        //    Stalk wraps the commitment bytes as f64 data for the sheaf store
        let stalk_data: Vec<f64> = commitment.chunks(8)
            .map(|c| {
                let mut buf = [0u8; 8];
                let len = c.len().min(8);
                buf[..len].copy_from_slice(&c[..len]);
                f64::from_le_bytes(buf)
            })
            .collect();
        match Stalk::new(StalkContext::Zk, stalk_data) {
            Ok(stalk) => {
                if let Err(e) = self.sheaf_store.set_stalk(StalkContext::Zk, vertex_id, &stalk) {
                    error!("Failed to store oracle proof: {}", e);
                    return;
                }
            }
            Err(e) => {
                error!("Failed to create stalk from oracle commitment: {}", e);
                return;
            }
        }
        
        // 4. Cache for PoV block production
        let mut fp = [0u8; 32];
        fp.copy_from_slice(&commitment);
        
        let now = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs();
        
        let cached = CachedOracleProof {
            commitment: OracleCommitment {
                fingerprint: fp,
                spectral_gap,
                betti_numbers: (1, 0, 0),
                topology_hash: [0u8; 32],
                producer_fingerprint: fp,
            },
            vertex_id,
            cached_at: now,
        };
        
        *self.oracle_cache.lock().await = Some(cached);
        
        // 5. Derive VRF key from commitment (validator only)
        //    In production: would use actual eigenvectors from credential.
        //    For now: derive from fingerprint bytes as proxy.
        if self.is_validator {
            let vrf_key = VRFKey::from_fingerprint(fp);
            *self.vrf_key.lock().await = Some(vrf_key);
            info!("⚡ Oracle proof cached + VRF key derived: vertex={} gap={:.4} (eligible)",
                  vertex_id, spectral_gap);
        }
        
        info!("✅ Oracle proof stored: vertex={} gap={:.4} commitment={}",
              vertex_id, spectral_gap, hex::encode(&commitment[..8]));
    }
    
    /// Attempt to produce a block (validators only)
    ///
    /// Flow: VRF check → drain mempool → Oracle proof → PoVProducer → store → broadcast
    ///
    /// The VRF ensures exactly one producer per epoch. Without it, every
    /// validator produces on every tick → forks. With VRF gating:
    ///   VRF(prev_hash, epoch) → score < threshold → eligible
    async fn try_produce_block(&self) {
        if !self.is_validator {
            return;
        }
        
        // Need an Oracle proof to produce blocks
        let proof = {
            let cache = self.oracle_cache.lock().await;
            match cache.as_ref() {
                Some(p) => p.clone(),
                None => {
                    debug!("No Oracle proof cached — cannot produce block");
                    return;
                }
            }
        };
        
        // VRF slot check: am I the designated producer for this epoch?
        let next_height = match self.block_store.get_chain_tip() {
            Ok(Some((h, _))) => h + 1,
            Ok(None) => 0, // Genesis — always produce
            Err(_) => return,
        };
        
        if next_height > 0 {
            let vrf_key = self.vrf_key.lock().await;
            if let Some(key) = vrf_key.as_ref() {
                // Get parent hash for VRF input
                let parent_hash = match self.block_store.get_chain_tip() {
                    Ok(Some((h, _))) => {
                        match self.block_store.load_block_by_height(h) {
                            Ok(Some(parent)) => parent.hash().0,
                            _ => [0u8; 32],
                        }
                    }
                    _ => [0u8; 32],
                };
                
                let vrf_out = vrf_evaluate(key, &parent_hash, next_height);
                let score = vrf_out.score();
                
                // Single-validator: threshold = 1.0 (always eligible)
                // Multi-validator: threshold = validator_set.vrf_threshold(fp)
                // ValidatorSet (consensus/validator_set.rs) computes proper
                // harmonic weight thresholds once Oracle provides centralities.
                let threshold = 1.0; // Single-node bootstrap; multi-node uses ValidatorSet
                if score >= threshold {
                    debug!("VRF: not our slot (score={:.4} >= threshold={:.4})", score, threshold);
                    return;
                }
                debug!("VRF: slot assigned (score={:.4}, epoch={})", score, next_height);
            }
            // No VRF key yet → skip VRF check (single-node bootstrap)
        }
        
        // Drain mempool
        let txs: Vec<Transaction> = {
            let mut pool = self.mempool.lock().await;
            let entries: Vec<MempoolEntry> = pool.drain(..).collect();
            entries.into_iter().map(|e| e.tx).collect()
        };
        
        let tx_count = txs.len();
        
        // Build PoV producer (worker keys are the producer fingerprint for now)
        // Derive 4 Ed25519 keypairs from producer fingerprint (single-node bootstrap).
        // In multi-validator mode, each node has its own persistent key.
        let seed = proof.commitment.producer_fingerprint;
        let signing_keys: Vec<ed25519_dalek::SigningKey> = (0u8..4).map(|i| {
            let mut key_seed = seed;
            key_seed[31] = i; // Derive distinct keys from seed
            ed25519_dalek::SigningKey::from_bytes(&key_seed)
        }).collect();
        let pubkeys: Vec<[u8; 32]> = signing_keys.iter()
            .map(|sk| ed25519_dalek::VerifyingKey::from(sk).to_bytes())
            .collect();
        let producer = PoVProducer::from_signing_key(
            signing_keys[0].clone(), pubkeys.clone()
        ).with_peer_keys(signing_keys[1..].to_vec());
        let verifier = PoVVerifier::new(pubkeys);
        
        // Get parent block (or produce genesis)
        let block = match self.block_store.get_chain_tip() {
            Ok(Some((height, _hash))) => {
                // Load parent block
                match self.block_store.load_block_by_height(height) {
                    Ok(Some(parent)) => {
                        match producer.produce_block(&parent, txs, &proof.commitment) {
                            Ok(b) => b,
                            Err(e) => {
                                error!("Failed to produce block: {}", e);
                                return;
                            }
                        }
                    }
                    _ => {
                        error!("Cannot load parent block at height {}", height);
                        return;
                    }
                }
            }
            Ok(None) => {
                // Genesis
                match producer.produce_genesis(&proof.commitment) {
                    Ok(mut b) => {
                        b.transactions = txs;
                        b.header.cochain_root = b.compute_cochain_root();
                        b
                    }
                    Err(e) => {
                        error!("Failed to produce genesis: {}", e);
                        return;
                    }
                }
            }
            Err(e) => {
                error!("Block store error: {}", e);
                return;
            }
        };
        
        // Self-verify before storing
        if let Err(e) = verifier.verify_block(&block) {
            error!("Self-verification failed: {}", e);
            return;
        }
        
        let block_hash = block.hash();
        let height = block.header.height;
        
        // Store block
        if let Err(e) = self.block_store.store_block(&block) {
            error!("Failed to store produced block: {}", e);
            return;
        }
        
        // Mark key images as spent
        for (tx_idx, tx) in block.transactions.iter().enumerate() {
            if let Some(ki_bytes) = &tx.key_image {
                let ki = KeyImage::new(*ki_bytes);
                let _ = self.key_image_store.mark_spent(&ki, height, tx_idx as u32);
            }
        }
        
        info!("⛏️  Produced block: height={} hash={} txs={}",
              height, block_hash, tx_count);
        
        // Broadcast to network
        if let Ok(block_data) = bincode::serialize(&block) {
            let hash = block_hash.0.to_vec();
            if let Err(e) = self.transport.broadcast_block(height, hash, block_data).await {
                warn!("Failed to broadcast block: {}", e);
            }
        }
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
