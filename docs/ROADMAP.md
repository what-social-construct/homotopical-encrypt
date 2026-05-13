# Layer 1 Shipping Roadmap

**Last Updated**: February 2026

## What is Layer 1?

**Layer 1 (L1)** = Independent blockchain with own consensus, network, and native token

**Examples**:
- Bitcoin (L1) - PoW consensus
- Ethereum (L1) - PoS consensus
- Monero (L1) - PoW + RingCT privacy
- Solana (L1) - PoH + PoS consensus
- **Homotopical-Encrypt (L1)** - PoV + homotopy privacy

**NOT Layer 1**:
- Uniswap (app on Ethereum)
- Lightning Network (L2 on Bitcoin)
- Arbitrum (L2 rollup on Ethereum)
- Solana programs (apps on Solana)

---

## Current Progress Summary

| Phase | Status | Progress |
|-------|--------|----------|
| Phase 1: Core Infrastructure | 🔄 In Progress | ~70% |
| Phase 2: Wallet & UX | 🔄 In Progress | ~50% |
| Phase 3: Smart Contracts | ❌ Not Started | 0% |
| Phase 4: Testnet | ❌ Not Started | 0% |

---

## Architecture: Layer 1 Stack

```
┌──────────────────────────────────────────────────────┐
│              APPLICATION LAYER (L2/Apps)             │
│  Future: DEX, Lending, DAOs built on our L1         │
└──────────────────────────────────────────────────────┘
                         ↑
┌──────────────────────────────────────────────────────┐
│           SMART CONTRACT LAYER (WASM VM)             │
│  • Contract deployment                               │
│  • Homotopy-aware precompiles                        │
│  • Spectral-complexity gas model                     │
└──────────────────────────────────────────────────────┘
                         ↑
┌──────────────────────────────────────────────────────┐
│            CONSENSUS LAYER (PoV)                     │
│  • Block validation (spectral proofs)                │
│  • Validator set (staked nodes)                      │
│  • Finality (Byzantine fault tolerance)             │
└──────────────────────────────────────────────────────┘
                         ↑
┌──────────────────────────────────────────────────────┐
│            NETWORK LAYER (P2P)                       │
│  • libp2p networking                                 │
│  • Block propagation                                 │
│  • Transaction gossip                                │
│  • Oracle communication                              │
└──────────────────────────────────────────────────────┘
                         ↑
┌──────────────────────────────────────────────────────┐
│            STORAGE LAYER                             │
│  • Block storage (chain_store)                       │
│  • State storage (SheafState)                        │
│  • Key image tracking                                │
└──────────────────────────────────────────────────────┘

        OFF-CHAIN (Oracle Workers)
┌──────────────────────────────────────────────────────┐
│            COMPUTATION WORKERS (Python)              │
│  • Eigenvalue decomposition                          │
│  • Hodge projections                                 │
│  • Reference/test-vector generation                  │
│  • Submit raw values to Rust oracle                  │
└──────────────────────────────────────────────────────┘
```

Consensus-path transaction/block validation is a Rust runtime boundary, with
Lean specifying the invariants and Python acting as research/reference code.
See [TRUST_BOUNDARIES.md](TRUST_BOUNDARIES.md).

---

## Phase 1: Core L1 Infrastructure

**Status**: 🔄 ~70% Complete

### 1.1 Rust Node Foundation ✅

```
rust/node/
├── consensus/
│   ├── mod.rs              ✅ Module structure
│   └── pov.rs              ✅ Proof of Value validation
├── network/
│   ├── mod.rs              ✅ Module structure
│   ├── onion.rs            ✅ Onion routing types
│   ├── relay.rs            ✅ Relay node types
│   └── transport.rs        ✅ Transport stubs (needs libp2p)
├── storage/
│   ├── mod.rs              ✅ Module structure
│   ├── blocks.rs           ✅ Block persistence
│   ├── state.rs            ✅ State machine
│   ├── sheaf_store.rs      ✅ Sheaf-structured storage
│   └── keyimages.rs        ✅ Double-spend prevention
└── rpc/
    └── mod.rs              ✅ JSON-RPC server
```

**Completed**:
- ✅ Block structures with spectral proofs
- ✅ State storage with harmonic indexing
- ✅ Key image tracking for double-spend
- ✅ RPC server interface
- ✅ Network types (onion, relay)

**Remaining**:
- ⏳ libp2p actual transport implementation
- ⏳ Block/transaction gossip
- ⏳ Peer discovery

### 1.2 Oracle Interface ✅

```
rust/oracle/
├── main.rs              ✅ Entry point
├── http.rs              ✅ HTTP server (port 9090)
├── rpc.rs               ✅ RPC methods
├── geometry.rs          ✅ Geometric verification
└── stalk_bridge.rs      ✅ Full → Hash stalk transformation
```

**Completed**:
- ✅ HTTP server running on 127.0.0.1:9090
- ✅ `submit_stalk` RPC method
- ✅ `get_commitment` RPC method
- ✅ Geometric commitment computation
- ✅ Python → Oracle communication tested

### 1.3 Python Workers ✅

```
src/
├── geometry/            ✅ Sheaf math
│   ├── sheaf.py
│   ├── sheaf_laplacian.py
│   ├── hodge.py
│   ├── fiber_bundle.py
│   └── noise.py
├── invariants/          ✅ Invariant computation
│   ├── spectral.py
│   ├── harmonic.py
│   └── unified.py
├── crypto/              ✅ Encryption
│   ├── encrypt.py
│   ├── decrypt.py
│   ├── credential.py
│   └── validation.py   (renamed from checkpoints)
└── oracle/
    └── client.py        ✅ Python → Oracle client
```

**Completed**:
- ✅ Spectral proof computation
- ✅ Hodge projection
- ✅ Oracle client working
- ✅ End-to-end test passing (test_wallet_oracle_flow.py)

---

## Phase 1.5: Clean Architecture (NEW) ✅

**Status**: ✅ Complete

Reorganization for clean separation of concerns:

### Python Module Structure

```
src/
├── chain/               # Blockchain data + storage
│   ├── block.py                 ✅ Block structures (CANONICAL)
│   ├── block_producer.py        ✅ Block production
│   ├── homotopy_transaction.py  ✅ Transaction types
│   ├── sheaf_state.py           ✅ Harmonic state
│   ├── account.py               ✅ Sovereign accounts
│   ├── chain_store.py           ✅ Block persistence
│   ├── wallet_store.py          ✅ Encrypted wallet
│   └── key_image.py             ✅ Double-spend prevention
│
├── consensus/           # Block production + validation
│   ├── invariant_validator.py   ✅ PoV invariant checking
│   ├── validator_selection.py   ✅ Spectral centrality selection
│   └── __init__.py              ✅ Clean exports
│
├── network/             # Transaction routing (NEW)
│   ├── routing.py               ✅ TransactionRouter, RelayNode
│   └── __init__.py              ✅ Module exports
│
├── proofs/              # Cryptographic proofs
│   ├── consensus.py             ✅ ProofOfValue mechanics
│   ├── anonymity.py             ✅ Homotopy class proofs
│   └── spectral.py              ✅ Spectral proofs
│
├── crypto/              # Encryption primitives
│   ├── validation.py            ✅ Encryption validation (renamed)
│   └── ... (encrypt, decrypt, etc.)
│
├── geometry/            # Sheaf math
├── invariants/          # Invariant computation
└── primitives/          # Low-level math
```

### Clear Terminology

| Term | Meaning | Location |
|------|---------|----------|
| **Validator** (noun) | Network node that produces blocks | `validator_selection.py` |
| **InvariantValidator** | Checks PoV invariants hold | `invariant_validator.py` |
| **validation.py** | Encryption input/output checks | `crypto/validation.py` |
| **ProofOfValue** | Consensus mechanism | `proofs/consensus.py` |

---

## Phase 2: Wallet & User Experience

**Status**: 🔄 ~50% Complete

### 2.1 Python Wallet ✅

```
src/chain/
├── wallet_store.py      ✅ Encrypted credential storage
└── ...
```

**Completed**:
- ✅ Hodge-structured encryption
- ✅ Wallet → Routing → Oracle flow
- ✅ Serialization/deserialization
- ✅ Full integration test passing

### 2.2 Rust CLI Wallet ⏳

```
rust/wallet/
├── lib.rs               ✅ Library structure
├── store.rs             ✅ Storage stubs
└── ...
```

**Remaining**:
- ⏳ Key generation (secure memory)
- ⏳ Transaction building
- ⏳ RPC to node
- ⏳ CLI interface

---

## Phase 3: Smart Contracts

**Status**: ❌ Not Started

### 3.1 WASM Runtime
```
rust/contracts/
├── runtime/
│   ├── vm.rs              # wasmtime integration
│   ├── gas.rs             # Spectral complexity metering
│   └── state.rs           # Contract state
└── precompiles/
    ├── verify_spectral.rs # Verify spectral proofs
    ├── hodge.rs           # Harmonic projection
    └── fingerprint.rs     # Check homotopy equivalence
```

---

## Phase 4: Testnet Launch

**Status**: ❌ Not Started

**Requirements**:
- Genesis block
- Faucet (free testnet tokens)
- Block explorer
- 10-20 initial validators
- 5-10 oracle workers

---

## Immediate Next Steps

### 🔥 Priority 1: Complete Core Infrastructure

1. **libp2p Transport (Rust)**
   - File: `rust/node/src/network/transport.rs`
   - Add actual libp2p networking
   - Block/transaction gossip
   - Peer discovery

2. **Block Producer Integration (Rust)**
   - Connect Python block_producer.py logic to Rust
   - Or reimplement in Rust with oracle verification

### 🎯 Priority 2: Rust CLI Wallet

3. **Wallet CLI**
   - File: `rust/wallet/`
   - Generate credentials (call Python or reimplement)
   - Build transactions
   - Send via RPC
   - Check balance

### 🌟 Priority 3: Testnet Preparation

4. **Genesis Block**
   - Initial state
   - Validator set
   - Token distribution

5. **Block Explorer**
   - Web UI for viewing chain
   - Transaction search
   - Account balances

---

## Key Differentiators vs Other L1s

### vs Bitcoin
- ✅ Privacy by default (Bitcoin is transparent)
- ✅ Smart contracts (Bitcoin script is limited)
- ✅ Post-quantum secure (Bitcoin uses ECDSA)

### vs Ethereum
- ✅ Privacy by default (Ethereum is transparent)
- ✅ Homotopy-based (vs account model)
- ✅ Spectral gas (more accurate than EVM gas)

### vs Monero
- ✅ Post-quantum secure (Monero uses ECDSA)
- ✅ Smart contracts (Monero has none)
- ✅ Provable security (homotopy equivalence)
- ✅ Better anonymity set (infinite via homotopy)

### vs Solana
- ✅ Privacy built-in (Solana is transparent)
- ✅ Provable correctness (homotopy invariants)
- ✅ Panopticon resilient by design

---

## Native Token: HCRYPT

### Use Cases

**Transaction Fees**:
- Pay for transaction inclusion
- Oracle computation rewards

**Validator Staking**:
- Stake HCRYPT to become validator
- Earn block rewards
- Get slashed for misbehavior

**Oracle Worker Staking**:
- Stake HCRYPT to become worker
- Earn computation rewards
- Get slashed for invalid results

**Governance**:
- Vote on protocol upgrades
- Adjust parameters

---

## Success Metrics

### Testnet Goals
- 1000+ transactions per day
- 10+ validators
- 5+ oracle workers
- 99.9% uptime
- <5s transaction confirmation

### Mainnet Goals (Year 1)
- 10,000+ daily active addresses
- 100+ validators
- 50+ oracle workers
- 1M+ transactions per month
- $10M+ TVL (if DeFi contracts)

---

## Conclusion

**Homotopical-Encrypt = Layer 1 Privacy Chain**

Like Monero, but:
- ✅ Post-quantum secure
- ✅ Provably correct (homotopy)
- ✅ Smart contracts
- ✅ Better anonymity

**Current Status**: Phase 1 ~70% complete

**Next milestone**: libp2p transport → testnet genesis

Let's ship a Layer 1! 🚀
