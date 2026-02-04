# Implementation Roadmap - Step by Step

## Status: Ready to Build! 🚀

### ✅ COMPLETED
- [x] Python prototype (wallet, routing, geometry)
- [x] Architecture documented
- [x] Rust workspace initialized
- [x] Core types defined
- [x] PoV consensus logic outlined
- [x] Network architecture (sheaf onion)

---

## 🎯 PHASE 1: Storage Layer (Week 1)

### Step 1.1: Block Storage
**File**: `rust/node/src/storage/blocks.rs`

**Tasks**:
- [ ] RocksDB initialization
- [ ] Store block by height
- [ ] Load block by height
- [ ] Store block by hash
- [ ] Load block by hash
- [ ] Get chain tip (latest block)

**Test**: Can store and retrieve blocks

### Step 1.2: State Storage  
**File**: `rust/node/src/storage/state.rs`

**Tasks**:
- [ ] Store SheafState (harmonic balances)
- [ ] Load SheafState
- [ ] Update state atomically
- [ ] Serialize/deserialize state

**Test**: Can persist and load state

### Step 1.3: Key Image Tracking
**File**: `rust/node/src/storage/keyimages.rs`

**Tasks**:
- [ ] Store spent key images
- [ ] Check if key image spent
- [ ] Batch operations for block processing

**Test**: Can track spent key images

---

## 🎯 PHASE 2: RPC Layer (Week 1-2)

### Step 2.1: JSON-RPC Server
**File**: `rust/node/src/rpc/server.rs`

**Tasks**:
- [ ] HTTP server setup (axum or jsonrpsee)
- [ ] Request routing
- [ ] Error handling
- [ ] CORS for web clients

### Step 2.2: RPC Endpoints
**File**: `rust/node/src/rpc/endpoints.rs`

**Tasks**:
- [ ] `get_block(height)` - Get block by height
- [ ] `get_block_by_hash(hash)` - Get block by hash  
- [ ] `get_tip()` - Get chain tip
- [ ] `get_balance(fingerprint)` - Get account balance
- [ ] `submit_transaction(tx)` - Submit new transaction
- [ ] `get_state()` - Get current chain state

**Test**: Can query chain via RPC

---

## 🎯 PHASE 3: P2P Network (Week 2-3)

### Step 3.1: libp2p Setup
**File**: `rust/node/src/network/transport.rs`

**Tasks**:
- [ ] Initialize libp2p Swarm
- [ ] TCP transport
- [ ] Noise encryption
- [ ] Yamux multiplexing
- [ ] mDNS for local discovery
- [ ] Kad-DHT for remote discovery

### Step 3.2: Message Handling
**File**: `rust/node/src/network/messages.rs`

**Tasks**:
- [ ] Define message types (block, tx, request)
- [ ] Serialize/deserialize messages
- [ ] Handle incoming messages
- [ ] Broadcast outgoing messages

### Step 3.3: Sheaf Onion Integration
**File**: `rust/node/src/network/onion.rs`

**Tasks**:
- [ ] RPC bridge to Python onion router
- [ ] Send onion-wrapped transactions
- [ ] Receive and unwrap packets
- [ ] Forward to next hop

**Test**: Nodes can communicate

---

## 🎯 PHASE 4: Oracle Interface (Week 3-4)

### Step 4.1: Worker Submission Endpoint
**File**: `rust/oracle/src/receiver.rs`

**Tasks**:
- [ ] HTTP server for worker submissions
- [ ] Accept signed computation results
- [ ] Validate submission format
- [ ] Queue for processing

### Step 4.2: Verification
**File**: `rust/oracle/src/verifier.rs`

**Tasks**:
- [ ] Verify worker signatures (ed25519)
- [ ] Verify computation hash traces
- [ ] Check trace continuity
- [ ] Validate result format

### Step 4.3: Consensus Aggregation
**File**: `rust/oracle/src/aggregator.rs`

**Tasks**:
- [ ] Collect multiple worker submissions
- [ ] Find majority result (2/3 consensus)
- [ ] Reject outliers
- [ ] Generate consensus proof

### Step 4.4: Chain Submission
**File**: `rust/oracle/src/submitter.rs`

**Tasks**:
- [ ] Connect to node RPC
- [ ] Submit spectral proofs
- [ ] Track submission status
- [ ] Retry on failure

**Test**: Python worker → Oracle → Chain works

---

## 🎯 PHASE 5: Python Worker Integration (Week 4)

### Step 5.1: Worker RPC Client
**File**: `src/oracle_worker/client.py`

**Tasks**:
- [ ] HTTP client to oracle
- [ ] Submit computation results
- [ ] Sign submissions
- [ ] Handle responses

### Step 5.2: Computation Service
**File**: `src/oracle_worker/service.py`

**Tasks**:
- [ ] Poll for computation requests
- [ ] Compute spectral proofs
- [ ] Generate hash traces
- [ ] Sign and submit

**Test**: Full flow: Request → Worker computes → Oracle verifies → Chain accepts

---

## 🎯 PHASE 6: Block Production (Week 4-5)

### Step 6.1: Validator Logic
**File**: `rust/node/src/consensus/validator.rs`

**Tasks**:
- [ ] Load validator key
- [ ] Validator set management
- [ ] Rotation logic
- [ ] Staking (simple version)

### Step 6.2: Block Builder
**File**: `rust/node/src/consensus/builder.rs`

**Tasks**:
- [ ] Select transactions from mempool
- [ ] Wait for oracle proof
- [ ] Build block header
- [ ] Sign block
- [ ] Broadcast to network

### Step 6.3: Block Validator
**File**: `rust/node/src/consensus/validator.rs`

**Tasks**:
- [ ] Verify block structure
- [ ] Verify spectral proof (PoV)
- [ ] Verify transactions
- [ ] Check parent hash
- [ ] Apply to state

**Test**: Can produce and validate blocks

---

## 🎯 PHASE 7: Local Testnet (Week 5-6)

### Step 7.1: Genesis Block
**File**: `rust/node/src/genesis.rs`

**Tasks**:
- [ ] Define genesis parameters
- [ ] Initial validator set
- [ ] Initial token distribution
- [ ] Genesis block creation

### Step 7.2: Multi-Node Setup
**Scripts**: `scripts/testnet/`

**Tasks**:
- [ ] Start 3-5 local nodes
- [ ] Bootstrap connections
- [ ] Verify block production
- [ ] Test transaction flow

### Step 7.3: Monitoring
**File**: `scripts/monitor.py`

**Tasks**:
- [ ] Node health checks
- [ ] Block production rate
- [ ] Transaction throughput
- [ ] Network connectivity

**Test**: 3+ nodes producing blocks, processing transactions

---

## 🎯 PHASE 8: Polish & Launch (Week 6-8)

### Step 8.1: CLI Wallet
**File**: `rust/wallet/src/main.rs`

**Tasks**:
- [ ] Generate credentials
- [ ] Store encrypted
- [ ] Send transactions
- [ ] Check balance
- [ ] Query transactions

### Step 8.2: Documentation
**Files**: `docs/TESTNET.md`, `docs/VALIDATOR.md`

**Tasks**:
- [ ] Setup instructions
- [ ] Validator guide
- [ ] RPC documentation
- [ ] Troubleshooting guide

### Step 8.3: Public Testnet
**Tasks**:
- [ ] Deploy 5+ validator nodes
- [ ] Public RPC endpoints
- [ ] Block explorer (simple)
- [ ] Faucet for test tokens
- [ ] Announce on social media

**Test**: Public testnet running 24/7

---

## 📊 Success Metrics

### Week 4 (Local Testnet)
- ✅ 3 nodes running locally
- ✅ Blocks produced every ~6 seconds
- ✅ Transactions processed
- ✅ Oracle proofs verified

### Week 8 (Public Testnet)
- ✅ 10+ public validators
- ✅ 100+ test transactions/day
- ✅ Block explorer working
- ✅ 99% uptime

### Month 3 (Mainnet Prep)
- ✅ Security audit complete
- ✅ Economic model finalized
- ✅ Governance deployed
- ✅ Ready for mainnet!

---

## 🚀 Let's Start!

**NEXT IMMEDIATE STEP**: Implement storage layer (Phase 1)

Start with: `rust/node/src/storage/blocks.rs`
- RocksDB setup
- Store/load blocks
- Simple but foundational

Once storage works, everything else builds on top!
