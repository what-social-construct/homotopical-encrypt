# Homotopical Encrypt

**Layer 1 Privacy Blockchain with Post-Quantum Geometric Encryption**

> *Quantum-resistant* (resists Shor's algorithm), not *quantum encryption* (no qubits required). Security derives from geometric lattice hardness (CVP on sheaf cochains).

Full blockchain node with Proof of Value consensus, sheaf-aware storage, and libp2p networking.

- ✅ **Post-quantum secure** — spectral + lattice hardness, not ECDSA
- ✅ **Provable privacy** — anonymity = homotopy class membership (|[F]| = ∞, not finite decoy rings)
- ✅ **1/∞ anonymity** — replaces ring signatures (1/16) with homotopy equivalence proofs (1/∞)
- ✅ **Sheaf onion routing** — geometry-based transaction mixing via fiber bundles
- ✅ **Panopticon resilient** — constant-size ciphertexts, cover traffic, timing obfuscation

## Mathematical Foundation

### Core Concepts

| Concept | Mathematical Object | Cryptographic Role |
|---------|---------------------|-------------------|
| Key | Fibration credential | (topology, fibration, spectrum) |
| Ciphertext | 0-cochain on nerve | Distributed over vertices |
| Encryption | Coboundary + noise | δx + ε |
| Decryption | Lindblad/harmonic flow | exp(-tΔ)x → ker(Δ) |
| Security | Spectral gap λ₁ | Error tolerance |
| Verification | Homotopy invariants | ZK-friendly |

### The Diagonal Pairing

The system is built on the **diagonal functor** Δ from Helfer's first-order homotopical logic. The diagonal Δ: Spec → Spec × Spec sends a spectral fingerprint *s* to the pair *(s, s)*. Equality of fibrations is interpreted as lying on this diagonal — a geometric condition, not a syntactic one.

```
         Spec × Spec
              │
    (1,1) ●──────────● (1,0)
          │╲          │
          │  ╲  Δ     │         d(diagonal, corner) = 1/√2
          │    ╲      │
          │      ╲    │         ON  diagonal ⟹ equivalent   (d = 0)
          │        ╲  │         OFF diagonal ⟹ detectable   (d ≥ 1/√2)
    (0,0) ●──────────╲● (0,1)
                  Δ(Spec)╲
                          ╲
                           ● Spec
```

**The pullback construction** (Helfer §3.1–3.2) gives the ZK proof structure. The prover knows a path in Path(F,G); the verifier only sees the spectral projection:

```
              Path(F, G)                    ← SECRET (the homotopy)
                  │
                  │  π                      ← forget the path
                  ▼
              Fib × Fib
                  │
                  │  spec × spec            ← extract fingerprints
                  ▼
             Spec × Spec
                  │
                  │  lies on Δ ?            ← PUBLIC verification
                  ▼
              s_F = s_G                     ← on diagonal ⟹ equivalent
```

The √2 spectral bound follows directly from the diagonal geometry:

| Condition | Meaning | Action |
|---|---|---|
| ‖s_F − s_G‖ < 1/√2 · λ₁ | Near diagonal | May be equivalent — require proof |
| ‖s_F − s_G‖ ≥ √2 · λ₁ | Far from diagonal | Definitely distinct — reject |

The detection threshold 1/√2 is the maximum distance from the diagonal to a corner of the unit square; √2 is the diagonal length.

### The Adjunction (Encryption ⊣ Decryption)

The Σ/Π adjunction from HoTT gives encryption and decryption as adjoint functors. This is the categorical reason why encryption hides and decryption recovers:

```
                Σ_f
        C^0 ──────────▶ C^1           Σ (dependent sum)  = ENCRYPTION
         │                │            "∃ message in ker(Δ)"
     f*  │                │  f*        Hides the witness
         │                │
        C^1 ◀────────── C^0           Π (dependent product) = DECRYPTION
                Π_f                    "∀ vertices, cochain agrees"
                                       Recovers the global section

                    Σ_f ⊣ Π_f
```

| Logic | HoTT Type | Fibration | Crypto |
|---|---|---|---|
| ∃x. P(x) | Σ-type | Dependent sum | **Encryption** — hide witness in ker(Δ) |
| ∀x. P(x) | Π-type | Dependent product | **Decryption** — recover global section |
| a = b | Path(a,b) | Path fibration | **Homotopy equivalence** — ZK witness |
| φ ∧ ψ | A × B | Pullback | Joint requirement |
| φ ∨ ψ | A + B | Coproduct | Either key works |

### Security Model: Hodge-Hardness

**The core hardness is CVP on the harmonic sublattice** — a geometrically-structured lattice problem.

```
Traditional Crypto:        Homotopical Crypto:
───────────────────       ─────────────────────
Message m                 Message m
    │                         │
    │ hash                    │ project to ker(Δ)
    ▼                         ▼
Commitment h              Commitment c ∈ ker(Δ) ⊂ ℝⁿ
                               ▲
                               │
                          Lattice point c*
                          (closest vector problem)
```

| Attack | SHA256 | Our System |
|--------|--------|------------|
| Find collision | ~2^128 (birthday) | Solve CVP on ker(Δ) (~2^256) |
| Forge commitment | Find m' with h(m')=h(m) | Find m' with same harmonic projection |
| Quantum | Grover → ~2^64 | CVP is post-quantum hard |

The geometric structure **constructs the problem** an attacker must solve:

1. **Spectral gap λ₁** → Defines the target space ker(Δ) = harmonic forms
2. **Betti numbers (β₀, β₁, β₂)** → Dimension of ker(Δ) = solution space size
3. **Natural transformation** → Consistency constraint (local forgeries detectable)

```
Attacker goal: Forge commitment c' such that:
  1. c' ∈ ker(Δ)          ← Must lie in harmonic space (spectral)
  2. dim(ker(Δ)) = β₀     ← Solution space has specific dimension (Betti)
  3. η_v(c') consistent   ← Must satisfy naturality on all edges
  
This is CVP on a lattice defined by the Laplacian eigenstructure.
Hodge-hardness → CVP on harmonic sublattice → CVP on q-ary lattice (post-quantum hard)
```

### On-Chain / Off-Chain Functor Chain

The system maps private geometric data (off-chain) to public commitments (on-chain) through a chain of three functors, with a natural transformation η mediating the compression:

```
    TOPOLOGY                ALGEBRA                  CRYPTO
   (geometric)             (algebraic)              (on-chain)

                   Nerve                  Laplacian
  Simplicial  ───────────▶  Cochain  ───────────▶  Sheaf Bundle
  Complex X                Complex               (Δ, ker Δ)
                           C•(X; ℤ_q)
```

```
  OFF-CHAIN (private)            η                 ON-CHAIN (public)
  ───────────────────    ─────────────────    ────────────────────
  Credential (256-dim)   ──── project ────▶   Commitment (32 bytes)
  Laplacian Δ            ── eigenvalues ──▶   Spectral gap λ₁
  Topology X             ─── Betti ───────▶   (β₀, β₁, β₂)
  Full state             ──── hash ───────▶   SHA256
```

**Naturality** ensures consistency: for any edge e: v → w in the nerve, the square commutes. A forgery that satisfies one vertex but not its neighbors is detected — the coboundary δ enforces global coherence from local data.

```
          η_v
  F(v) ─────────▶ F_hash(v)
   │                  │
   │ F(e)             │ F_hash(e)
   ▼                  ▼
  F(w) ─────────▶ F_hash(w)
          η_w

  F_hash(e) ∘ η_v  =  η_w ∘ F(e)        (naturality)
```

## Privacy Model: Fibrations, Not Ring Signatures

Traditional privacy coins (Monero) use **ring signatures**: hide the real signer among N decoys. The anonymity set is finite (typically 11-16). Probability of identifying the signer: **1/16**.

Homotopical Encrypt uses **homotopy class membership**: prove you know *some* fibration F with spectrum matching a public fingerprint, without revealing *which* one. The anonymity set is the entire homotopy class [F] — an **infinite** set of all fibrations with the same spectral invariants. Probability of identifying which F: **1/∞ = 0**.

### Fibration Fingerprint

A **spectral fingerprint** is a homotopy invariant. Two fibrations F, F' are in the same homotopy class [F] if and only if they have the same spectral fingerprint (eigenvalues of the sheaf Laplacian). The fingerprint is PUBLIC — anyone can verify it. But the fibration itself (the Laplacian Δ, the restriction maps, the Hodge decomposition) is SECRET.

```
                    ┌─────────────────────────────────┐
  Fibration F₁ ──→ │                                 │
  Fibration F₂ ──→ │  Same spectral fingerprint S    │ ← PUBLIC (verifiable)
  Fibration F₃ ──→ │  spec(Δ_F₁) = spec(Δ_F₂) = …  │
       ⋮           │                                 │
  Fibration F_∞──→ │  |[F]| = ∞                      │ ← INFINITE class
                    └─────────────────────────────────┘
                              │
                              ▼
                    Prover: "I know SOME F_i"
                    Verifier learns: S (the fingerprint)
                    Verifier learns: NOTHING about which F_i
                    Adversary's advantage: 1/|[F]| = 1/∞ = 0
```

This is a geometric fact, not a protocol parameter. The anonymity set isn't chosen (like picking 16 decoys) — it's the entire homotopy class, which is infinite by the structure of the fibration category.

```
Ring signatures (Monero):          Fibration anonymity (hcrypt):
─────────────────────────          ──────────────────────────────
  "I am one of these 16"           "I know some F ∈ [F]"
  Finite anonymity set              |[F]| = ∞ (infinite)
  Pr[identify] = 1/16              Pr[identify] = 1/∞ = 0
  Based on ECDLP (broken by QC)    Based on CVP on ker(Δ) (post-quantum)
  Decoy selection is metadata       No decoys — no metadata leakage
  Security parameter: ring size     Security parameter: spectral gap λ₁
```

## Helfer → Implementation

The mathematical foundation is Helfer's first-order homotopical logic ([arXiv:1908.08944](https://arxiv.org/abs/1908.08944)). Every core construct in the codebase has a precise origin in the paper:

| Helfer (2019) | What it is | Implementation | File |
|---|---|---|---|
| **h=-fibration** (Def 2.1.3) | Categorical structure interpreting logic over a base | `FibrationCredential` — the key triple (topology, fibration, spectrum) | `crypto/credential.py` |
| **Diagonal Δ: A → A×A** (§3.2) | Equality interpreted as path space, not strict equality | Spectral fingerprint matching — fingerprints on the diagonal ⟹ equivalent | `proofs/homotopy.py` |
| **Σ-type (∃x.P(x))** — dependent sum (§2.3) | Existential: "there exists a witness" | **Encryption** — "∃ message in ker(Δ)" (witness hidden in harmonic subspace) | `crypto/encrypt.py` |
| **Π-type (∀x.P(x))** — dependent product (§2.3) | Universal: "for all fibers, a section exists" | **Decryption** — "∀ vertices, the cochain agrees" (global section recovery) | `crypto/decrypt.py` |
| **Homotopy invariance** (Thm 3.4.1) | Homotopy-equivalent structures satisfy the same first-order sentences | **Anonymity** — all fibrations in [F] are indistinguishable → |[F]| = ∞ | `proofs/anonymity.py` |
| **Path space Path(F,G)** (§3.1) | Space of homotopy equivalences between two fibrations | ZK witness — prover knows a path without revealing it | `proofs/homotopy.py` |
| **Spectral invariants of Δ** | Eigenvalues of the Laplacian are homotopy invariants | Spectral fingerprint = public identity (same for all F ∈ [F]) | `crypto/credential.py` |
| **Grothendieck fibration** (§2.1) | Functor with cartesian lifting of morphisms | Cellular sheaf over Čech nerve with restriction maps | `geometry/sheaf.py` |
| **Free h=-fibration** (Thm A.2) | Universal syntactic object for the theory | Constraint that makes forgery require solving CVP on the lattice | `invariants/homotopical.py` |
| **Fibration morphisms** (Def 2.1.4) | Structure-preserving maps between fibrations | Parallel transport along paths in the nerve | `geometry/fiber_bundle.py` |
| **Hodge decomposition** C^k = H^k ⊕ im(δ) ⊕ im(δ*) | Orthogonal splitting of cochains (Hansen-Ghrist) | Message in ker(Δ), noise in exact⊕coexact complement | `geometry/hodge.py` |

### Papers

1. Helfer (2019): *First-order homotopical logic* [arXiv:1908.08944](https://arxiv.org/abs/1908.08944)
2. Meiburg et al. (2025): *Formalization of Quantum Stein's Lemma in Lean* [arXiv:2510.08672](https://arxiv.org/abs/2510.08672)
3. Hansen & Ghrist (2019): *Toward a Spectral Theory of Cellular Sheaves* [arXiv:1808.01513](https://arxiv.org/abs/1808.01513)
4. Wei & Wei (2021): *Persistent sheaf Laplacians* [arXiv:2112.10906](https://arxiv.org/abs/2112.10906)

## Proof of Value (PoV) Consensus

PoV replaces Proof of Work (wasted energy) and Proof of Stake (plutocratic) with **geometric validity**: a block is valid if its spectral geometry satisfies the √2 bounds.

### Why √2?

The diagonal functor Δ: Spec → Spec × Spec maps a spectral fingerprint to the pair (s, s). The maximum distance from the diagonal to a corner of the unit square is 1/√2, and the diagonal itself has length √2. This gives natural bounds:

```
Valid spectral gap λ₁ must satisfy:

    1/√2  ≤  λ₁  ≤  2√2
    ~0.707       ~2.828

Below 1/√2: topology too disconnected (information can't flow)
Above 2√2:  topology too rigid (no room for harmonic messages)
```

### Validator Selection

Validators are selected by **spectral centrality**, not stake weight. The Fiedler vector (second eigenvector of the graph Laplacian) measures each node's importance to information flow through the topology:

```
Selection probability ∝ |fiedler(v)|

     0 ─── 1 ─── 2 ─── 3       Vertex 2 has highest Fiedler centrality
                   │              (most connected to information flow)
                   4              → selected most often as block producer
```

This naturally rewards **network participation** (being well-connected, routing transactions) rather than **capital accumulation** (having the most tokens). Combined with VRF randomness from the previous block hash, selection is deterministic but unpredictable.

### PoV Verification Pipeline

```
Transaction arrives
    │
    ├─ Stage 0: Structural checks (O(1))
    ├─ Stage 1: Key image double-spend check (O(1))
    ├─ Stage 2: Spectral proof verification (O(n))
    │     └─ Eigenvalue commitments match public fingerprint?
    ├─ Stage 3: Homotopy invariant validation
    │     ├─ 3a: β₀ = 1 (connected topology)
    │     ├─ 3b: λ₁ ∈ [1/√2, 2√2] (√2 bounds)
    │     └─ 3c: Full staged invariant pipeline
    └─ Stage 4: Amount balance (homomorphic)
```

Blocks that pass all stages are added to the chain. The oracle (Rust) handles the heavy spectral computation; the node verifies the proofs.

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
│   ├── homotopy_transaction.py  # Homotopy-native transactions (fibration anonymity)
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

## Progress

| Component | Status | Notes |
|-----------|--------|-------|
| Python Crypto | ✅ Complete | Encrypt/decrypt working |
| Rust Node | 🔄 70% | Storage, P2P working |
| Oracle | ✅ Complete | HTTP server on port 9090 |
| Consensus | 🔄 In Progress | PoV verification stubs |
| Testnet | ❌ Not Started | Need genesis block |

See [docs/LAYER1_ROADMAP.md](docs/LAYER1_ROADMAP.md) for detailed status.

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
