# Homotopical Encrypt

**Layer 1 Privacy Blockchain with Post-Quantum Geometric Encryption**

<<<<<<< HEAD
This is *quantum-resistant* (resists Shor's algorithm), not *quantum encryption* (no qubits required).
=======
> ⚠️ **Precise Terminology**: This is *quantum-resistant* (resists Shor's algorithm), not *quantum encryption* (no qubits required). Security derives from geometric hardness
>>>>>>> 2e43f9ac6492cc79a83c09ea18fd506fa9a14e60

> 🚀 **Layer 1 Chain**: Full blockchain node with Proof of Value consensus, sheaf-aware storage, and libp2p networking.

Like Monero, but with:
- ✅ **Post-quantum secure** (spectral + lattice hardness, not ECDSA)
- ✅ **Provable privacy** (homotopy equivalence classes, spectral fingerprints, anonymity sets)
- ✅ **Sheaf onion routing** (geometry-based transaction mixing via fiber bundles)
- ✅ **Smart contracts** (WASM runtime, coming soon)
- ✅ **Panopticon resilient** (designed for adversarial surveillance)

## Quick Start

### Run the Node

```bash
# Build and run
cargo run -p hcrypt-node -- \
  --data-dir ./data \
  --p2p-port 30333 \
  --rpc-port 9933

# Run as validator
cargo run -p hcrypt-node -- --validator

# Bootstrap from peers
cargo run -p hcrypt-node -- \
  --bootnodes /ip4/1.2.3.4/tcp/30333/p2p/12D3KooW...
```

### Python Crypto Library

```bash
pip install -e .
```

```python
from homotopical_encrypt import generate_credential, encrypt, decrypt

# Generate credential for multi-party setup
cred = generate_credential(
    parties=['alice', 'bob'],
    connections=[('alice', 'bob')],
    security_parameter=256
)

# Encrypt
ciphertext = encrypt(b"Hello Bob", cred)

# Decrypt
plaintext = decrypt(ciphertext, cred)
```

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    RUST NODE (hcrypt-node)                   │
├──────────────────────────────────────────────────────────────┤
│  Network        │  Consensus      │  Storage                 │
│  ────────────── │  ───────────── │  ──────────────────────  │
│  libp2p P2P     │  Proof of Value │  RocksDB (sheaf-aware)  │
│  GossipSub      │  Spectral Proofs│  Block/State/KeyImages  │
│  Kademlia DHT   │  Oracle Workers │  Column Families:       │
│  TCP+Noise      │                 │   - stalks_private(256) │
│                 │                 │   - stalks_public(1)    │
│                 │                 │   - stalks_zk(32)       │
├──────────────────────────────────────────────────────────────┤
│                    PYTHON (Computation)                      │
├──────────────────────────────────────────────────────────────┤
│  Geometry       │  Crypto          │  Consensus              │
│  ────────────── │  ──────────────  │  ──────────────────     │
│  Sheaves        │  Encrypt/Decrypt │  InvariantValidator     │
│  Hodge Theory   │  Credentials     │  ValidatorSelection     │
│  Fiber Bundles  │  Secure Memory   │  Block Production       │
│  Spectral       │  Padding         │  Oracle Client          │
└──────────────────────────────────────────────────────────────┘
```

### Module Structure

```
rust/
├── node/             # Full L1 node
│   ├── network/
│   │   ├── transport.rs  # libp2p P2P (GossipSub, Kademlia)
│   │   ├── onion.rs      # Sheaf onion routing
│   │   └── relay.rs      # Relay network
│   ├── storage/
│   │   ├── sheaf_store.rs  # Sheaf-aware persistence
│   │   ├── blocks.rs       # Block storage
│   │   ├── state.rs        # Account state
│   │   └── keyimages.rs    # Double-spend prevention
│   ├── consensus/
│   │   └── pov.rs          # Proof of Value verification
│   ├── rpc/              # JSON-RPC server
│   └── types.rs          # Core types
├── oracle/           # Spectral computation oracle
│   ├── geometry.rs       # Spectral gap computation
│   ├── stalk_bridge.rs   # Python↔Rust stalk FFI
│   ├── http.rs           # HTTP server
│   └── rpc.rs            # RPC handlers
└── wallet/           # CLI wallet
    ├── lib.rs            # Wallet core
    └── store.rs          # Encrypted storage

src/
├── chain/          # Blockchain logic
│   ├── block.py          # Block structures
│   ├── account.py        # Sovereign accounts
│   ├── wallet_store.py   # Encrypted credential storage
│   ├── chain_store.py    # Python-side persistence
│   ├── block_producer.py # Block production
│   ├── homotopy_transaction.py  # Ring tx types
│   ├── sheaf_state.py    # Harmonic state
│   └── key_image.py      # Double-spend prevention
├── geometry/       # Sheaf mathematics
│   ├── sheaf.py          # Cellular sheaves
│   ├── sheaf_laplacian.py  # Block Laplacian Δ
│   ├── hodge.py          # Hodge decomposition
│   ├── fiber_bundle.py   # Parallel transport
│   ├── homotopy_path.py  # Path tracking
│   ├── topology.py       # Čech nerve, Betti numbers
│   ├── lattice.py        # Geometric lattice structures
│   └── noise.py          # Spectral noise generation
├── crypto/         # Encryption primitives
│   ├── encrypt.py        # Hodge-structured encryption
│   ├── decrypt.py        # Lindblad flow decryption
│   ├── credential.py     # Fibration credentials
│   ├── commitment.py     # Pedersen-style commitments
│   ├── secure_memory.py  # Memory protection
│   ├── padding.py        # Constant-size packets
│   ├── lattice.py        # Spectral hardness (LWE-analog)
│   ├── hardness.py       # Security assumptions
│   ├── random.py         # Secure randomness
│   └── validation.py     # Input/output validation
├── invariants/     # Geometric invariants
│   ├── spectral.py       # Spectral gaps
│   ├── cohomology.py     # Cohomology groups
│   ├── harmonic.py       # Harmonic analysis
│   ├── algebraic.py      # Algebraic topology invariants
│   ├── homotopical.py    # Homotopy type invariants
│   ├── fibration.py      # Fibration invariants
│   └── unified.py        # Combined invariant
├── primitives/     # Low-level math
│   ├── algebra.py        # Algebraic operations
│   ├── cochain.py        # Cochain complex
│   ├── homotopy.py       # Homotopy primitives
│   ├── natural.py        # Natural transformations
│   └── stalk.py          # Stalk operations
├── proofs/         # Cryptographic proofs
│   ├── anonymity.py      # Homotopy class proofs
│   ├── consensus.py      # ProofOfValue mechanics
│   ├── spectral.py       # Spectral proofs
│   └── homotopy.py       # Equivalence proofs
├── consensus/      # PoV consensus
│   ├── invariant_validator.py
│   └── validator_selection.py
├── network/        # Python routing
│   └── routing.py        # TransactionRouter, RelayNode
└── oracle/         # Oracle client
    └── client.py         # Python → Oracle RPC
```

## Mathematical Foundation

### Papers

1. Helfer (2019): *First-order homotopical logic* [arXiv:1908.08944](https://arxiv.org/abs/1908.08944)
2. Meiburg et al. (2025): *Formalization of Quantum Stein's Lemma in Lean* [arXiv:2510.08672](https://arxiv.org/abs/2510.08672)
3. Hansen & Ghrist (2019): *Toward a Spectral Theory of Cellular Sheaves* [arXiv:1808.01513](https://arxiv.org/abs/1808.01513)
4. Wei & Wei (2021): *Persistent sheaf Laplacians* [arXiv:2112.10906](https://arxiv.org/abs/2112.10906)

### Core Concepts

| Concept | Mathematical Object | Cryptographic Role |
|---------|---------------------|-------------------|
| Key | Fibration credential | (topology, fibration, spectrum) |
| Ciphertext | 0-cochain on nerve | Distributed over vertices |
| Encryption | Coboundary + noise | δx + ε |
| Decryption | Lindblad/harmonic flow | exp(-tΔ)x → ker(Δ) |
| Security | Spectral gap λ₁ | Error tolerance |
| Verification | Homotopy invariants | ZK-friendly |

### Logic Table (Helfer)

| Logic | Fibration Operation | Crypto Meaning |
|-------|---------------------|----------------|
| ∀x.φ(x) | Π (dependent product) | Valid decryptions = ker(Δ) |
| ∃x.φ(x) | Σ (dependent sum) | Some decryption exists |
| a = b | Path space Path(a,b) | Keys equal iff homotopy equivalent |
| φ ∧ ψ | Pullback | Joint decryption required |
| φ ∨ ψ | Coproduct | Either key works |

## Progress

| Component | Status | Notes |
|-----------|--------|-------|
| Python Crypto | ✅ Complete | Encrypt/decrypt working |
| Rust Node | 🔄 70% | Storage, P2P working |
| Oracle | ✅ Complete | HTTP server on port 9090 |
| Consensus | 🔄 In Progress | PoV verification stubs |
| Testnet | ❌ Not Started | Need genesis block |

See [docs/LAYER1_ROADMAP.md](docs/LAYER1_ROADMAP.md) for detailed status.

## Development

```bash
# Run tests
pytest tests/

# Run Rust node
cargo run -p hcrypt-node

# Start oracle
cargo run -p hcrypt-oracle

# Python + Oracle flow test
python tests/test_wallet_oracle_flow.py
```

## vs Other L1s

| Feature | Homotopical | Bitcoin | Ethereum | Monero |
|---------|-------------|---------|----------|--------|
| Privacy by default | ✅ | ❌ | ❌ | ✅ |
| Post-quantum | ✅ | ❌ | ❌ | ❌ |
| Smart contracts | ✅ (WASM) | ❌ | ✅ | ❌ |
| Provable security | ✅ | ❌ | ❌ | ❌ |
| Panopticon resilient | ✅ | ❌ | ❌ | ⚠️ |

## License

MIT
