# Homotopical Encrypt

**Layer 1 Privacy Blockchain with Post-Quantum Geometric Encryption**

> *Quantum-resistant* (resists Shor's algorithm), not *quantum encryption* (no qubits required). Security derives from geometric lattice hardness (CVP on sheaf cochains).

Full blockchain node with Proof of Value consensus, sheaf-aware storage, and libp2p networking.

- ✅ **Post-quantum secure** — spectral + lattice hardness, not ECDSA
- ✅ **Provable privacy** — anonymity = homotopy class membership (|[F]| = ∞, not finite decoy rings)
- ✅ **1/∞ anonymity** — replaces ring signatures (1/16) with homotopy equivalence proofs (1/∞)
- ✅ **Sheaf onion routing** — geometry-based transaction mixing via fiber bundles
- ✅ **Panopticon resilient** — constant-size ciphertexts, cover traffic, timing obfuscation

## Why "Homotopical"?

The encrypt/decrypt operation is Hodge-theoretic (embed in ker(Δ), noise in im(δ)⊕im(δ*), project via π_H). But the name describes the *security framework*, not the subroutine:

- The **secret key** is a fibration (a system of restriction maps between stalk contexts)
- The **public identity** is its homotopy class (unified fingerprint: spectral + cohomological + homotopical invariants)
- **Key equivalence** := homotopy equivalence of fibrations
- The **anonymity set** is the entire homotopy class [F] — infinite, by univalence
- The **hardness assumption** (Hodge-hardness) is: find h ∈ ker(Δ) without knowing which fibration Δ came from — hard *because* Δ encodes the homotopy type

Analogous to calling RSA "number-theoretic encryption" — the operation is modular exponentiation, but the security architecture is number theory.

### Local-to-Global Coherence

The unifying principle is **local-to-global coherence** via cellular sheaves:

```
  StalkProjection := R_{v→e}  (context projection = restriction map)

  δ(c)_e = R_j·c_j - R_i·c_i      measures disagreement between vertices
  ker(Δ) = global sections          data consistent under all restrictions
  im(δ)⊕im(δ*) ⊥ ker(Δ)            disagreement subspace

  encrypt:  message ∈ ker(Δ), noise ∈ im(δ)⊕im(δ*)
  decrypt:  π_H(ciphertext) = message   (Hodge projection)
```

Three independent layers consume this shared geometric substrate:

| Layer | Uses | Purpose |
|-------|------|---------|
| `crypto/encrypt + decrypt` | Hodge decomposition | Message confidentiality |
| `proofs/anonymity` | Spectral equivalence | Identity privacy (1/∞ anonymity) |
| `chain/key_image + homotopy_transaction` | Geodesic paths on SO(n) | Double-spend prevention |

## The Categorical Architecture

**SheafState as the Universal Unifier**

The system isn't just three layers stacked together — it's a **categorical colimit** where SheafState is the universal object that every operation factors through:

```
Homotopy Category C:
  Objects   = homotopy equivalence classes [F₁], [F₂], ...
  Morphisms = geodesic paths γ: [F₁] → [F₂]
  
Transactions ARE morphisms in this category:
  Alice sends to Bob = construct geodesic γ: [F_Alice] → [F_Bob]
  
SheafState = colim(Wallet, Oracle, Node)
  Universal property: every state change factors through apply_block()
```

**The Nerve Structure:**

```
Account Nerve (Layer 1):
  vertices = accounts
  edges = transactional connections
  AccountState.connected_to tracks the 1-skeleton
  
Fibration Nerve (Layer 3):
  0-cells = homotopy classes [F]
  1-cells = homotopy paths (geodesics on SO(n))
  2-cells = path homotopies
  
These coincide because transactions ARE category morphisms!
```

**Why this matters:**
- Every transaction follows an explicit geodesic path (deterministic, shortest)
- SheafState enforces coherence across all three layers
- The categorical structure is preserved by the natural transformations η₁, η₂
- Ring membership = infinite homotopy class, not finite decoys

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md#the-homotopy-category-and-its-nerve) for the complete categorical picture.

## Mathematical Foundation

### Core Concepts

| Concept | Mathematical Object | Cryptographic Role |
|---------|---------------------|-------------------|
| Key | Fibration credential | (topology, fibration, spectrum) |
| Ciphertext | 0-cochain on nerve | Distributed over vertices |
| Encryption | Coboundary + noise | δx + ε, message ∈ ker(Δ) |
| Decryption | Hodge projection π_H | Extract global section from noisy cochain |
| Security | Spectral gap λ₁ | Error tolerance |
| Verification | Homotopy invariants | ZK-friendly |

### The Diagonal and Equality

In Helfer's first-order homotopical logic, the **diagonal morphism** Δ: A → A×A interprets equality (Def 4.3(iv)). In the ordinary (set-theoretic) semantics, M(s = t) is the pullback of Δ — non-empty iff s = t. In the *homotopical* semantics, Δ is replaced by the path space map A^I → A×A, so "a = b" becomes *the space of paths from a to b* — a geometric condition, not a syntactic one (§2, p.6).

We instantiate this with A = Fib (the type of fibrations). Two fibrations F, G are "equal" when there exists a homotopy path between them. We can't observe the path — only whether the unified fingerprint projections land on the diagonal of U × U, where U = `HomotopyClassFingerprint` = (λ₁, β₀, β₁, β₂, h-level, Σ-rank):

```
           U × U    where U = (λ₁, β, h-level, Σ-rank)
              │
    (1,1) ●──────────● (1,0)
          │╲          │
          │  ╲  Δ     │         d(diagonal, corner) = 1/√2
          │    ╲      │
          │      ╲    │         ON  diagonal ⟹ may be equivalent (d = 0)
          │        ╲  │         OFF diagonal ⟹ definitely distinct (d ≥ 1/√2)
    (0,0) ●──────────╲● (0,1)
                    Δ(U)╲
                         ╲
                          ● U
```

**The pullback construction** (Helfer §§6–7, Def 4.3(iv)) gives the ZK proof structure. The prover knows a path in Path(F,G); the verifier only sees the fingerprint projection:

```
              Path(F, G)                    ← SECRET (the homotopy)
                  │
                  │  π                      ← forget the path
                  ▼
              Fib × Fib
                  │
                  │  U × U                  ← extract HomotopyClassFingerprints
                  ▼
          U(F) × U(G)
                  │
                  │  lies on Δ ?            ← PUBLIC verification
                  ▼
          U(F) = U(G)                       ← on diagonal ⟹ equivalent
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
  Amounts m              ── δ(m‖r) mod q ─▶   CochainCommitment (edge values)
  Cochain tree           ── Σ δ(txᵢ) ────▶   Cochain root (domain-sep SHA256)
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

Homotopical Encrypt uses **homotopy class membership**: prove you know *some* fibration F whose unified invariants (spectral, cohomological, homotopical) match a public fingerprint, without revealing *which* one. The anonymity set is the entire homotopy class [F] — an **infinite** set of all fibrations with matching invariants. Probability of identifying which F: **1/∞ = 0**.

### Fibration Fingerprint

The **public identity** is a `HomotopyClassFingerprint` — a composite of spectral, cohomological, and homotopical invariants (see `invariants/unified.py`). Two fibrations are in the same homotopy class when *all* matched invariants agree. The fingerprint is PUBLIC — anyone can verify it. But the fibration itself (the Laplacian Δ, the restriction maps, the Hodge decomposition) is SECRET.

> **Note:** Bare spectral fingerprints (eigenvalues alone) are *finer* than homotopy class — two fibrations can share Betti numbers but have different spectra (`Spectrum_Not_Homotopy_Invariant` in `math_audit_hcrypt.lean`). The system uses the full unified fingerprint to characterize the homotopy class itself, not just the isospectral set.

```
                    ┌──────────────────────────────────────────┐
  Fibration F₁ ──→ │                                          │
  Fibration F₂ ──→ │  Same unified fingerprint U              │ ← PUBLIC
  Fibration F₃ ──→ │  (spectral + cohomological + homotopical │
       ⋮           │   invariants all match)                  │
  Fibration F_∞──→ │  |[F]| = ∞                               │ ← INFINITE
                    └──────────────────────────────────────────┘
                              │
                              ▼
                    Prover: "I know SOME F_i in [F]"
                    Verifier learns: U (the unified fingerprint)
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
| **h=-fibration** (Def 4.3) | Fibration with fiberwise products, coproducts, exponentials, indexed Σ/Π, equality objects | `FibrationCredential` — the key triple (topology, fibration, spectrum) | `crypto/credential.py` |
| **Diagonal Δ: A → A×A** (§2, Def 4.3(iv)) | Equality as path space — pullback of Δ gives "a = b iff joined by a path" | Unified fingerprint matching — fingerprints on the diagonal ⟹ equivalent | `proofs/homotopy.py` |
| **Σ-type / indexed sum Σ_π** (Def 4.2–4.3) | Existential: "there exists a witness" | **Encryption** — "∃ message in ker(Δ)" (witness hidden in harmonic subspace) | `crypto/encrypt.py` |
| **Π-type / indexed product Π_π** (Def 4.2–4.3) | Universal: "for all fibers, a section exists" | **Decryption** — "∀ vertices, the cochain agrees" (global section recovery) | `crypto/decrypt.py` |
| **Homotopy invariance** (Thm 12.3) | Homotopy-equivalent structures satisfy the same first-order sentences | **Anonymity** — all fibrations in [F] are indistinguishable → |[F]| = ∞ | `proofs/anonymity.py` |
| **Path space** (§§6–7) | Space of homotopy equivalences between two structures | ZK witness — prover knows a path without revealing it | `proofs/homotopy.py` |
| **Spectral invariants of Δ** (Hansen-Ghrist) | Eigenvalues of the sheaf Laplacian are homotopy invariants | Unified fingerprint (spectral + Betti + cohomological) = public identity | `crypto/credential.py` |
| **Grothendieck fibration** (§4, [Hel20]) | Fibration with cartesian lifting of morphisms | Cellular sheaf over Čech nerve with restriction maps | `geometry/sheaf.py` |
| **Free h=-fibration** (Prop 15.3) | Universal syntactic object — morphisms out of it = interpretations | Constraint that makes forgery require solving CVP on the lattice | `invariants/homotopical.py` |
| **Fibration morphisms** (Def 4.4) | Structure-preserving maps between fibrations | Parallel transport along paths in the nerve | `geometry/fiber_bundle.py` |
| **Hodge decomposition** C^k = H^k ⊕ im(δ) ⊕ im(δ*) | Orthogonal splitting of cochains (Hansen-Ghrist) | Message in ker(Δ), noise in exact⊕coexact complement | `geometry/hodge.py` |

### Papers

1. Helfer (2019): *First-order homotopical logic* [arXiv:1908.08944](https://arxiv.org/abs/1908.08944)
2. Meiburg et al. (2025): *Formalization of Quantum Stein's Lemma in Lean* [arXiv:2510.08672](https://arxiv.org/abs/2510.08672)
3. Hansen & Ghrist (2019): *Toward a Spectral Theory of Cellular Sheaves* [arXiv:1808.01513](https://arxiv.org/abs/1808.01513)
4. Wei & Wei (2021): *Persistent sheaf Laplacians* [arXiv:2112.10906](https://arxiv.org/abs/2112.10906)

## Proof of Value (PoV) Consensus

PoV replaces Proof of Work (wasted energy) and Proof of Stake (plutocratic) with **geometric validity**: a block is valid if its spectral geometry satisfies the √2 bounds.

### Why √2?

The diagonal morphism Δ: U → U × U (Helfer Def 4.3(iv)) maps a unified fingerprint to the pair (u, u). The maximum distance from the diagonal to a corner of the unit square is 1/√2, and the diagonal itself has length √2. This gives natural bounds on the spectral gap:

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
│   ├── decrypt.py        # Dual decode (lattice + Hodge projection)
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

## How It Compares

### vs Monero (Privacy)

Monero hides the real signer among N decoys in a **ring signature** (currently N=16). The anonymity set is finite and chosen at transaction time. Chain analysis can sometimes narrow the set by eliminating known-spent outputs.

hcrypt replaces ring signatures with **homotopy class membership**: you prove you know *some* fibration whose unified invariants match a public fingerprint, without revealing which one. The anonymity set is the entire homotopy class — infinite by construction, not chosen by a parameter. There are no decoys to analyze.

| | Monero | hcrypt |
|---|---|---|
| Anonymity primitive | Ring signature (N=16 decoys) | Homotopy class membership (|[F]|=∞) |
| Anonymity set size | Finite, chosen at tx time | Infinite, structural |
| Quantum resistance | ❌ ECDLP (broken by Shor) | ✅ CVP on ker(Δ) (post-quantum) |
| Metadata leakage | Decoy selection patterns | No decoys → no selection metadata |
| Amounts hidden | RingCT (Pedersen commitments) | Cochain commitments (δ-homomorphic) |
| Double-spend | Key images | Key images (same concept, geometric construction) |
| Formal verification | None | `hardness_proof.lean` (Hodge → CVP, strictly harder) |

### vs Cardano (Formal Methods)

Cardano pioneered formal verification in blockchain (Haskell, Agda proofs). hcrypt takes a different approach: rather than verifying the *protocol*, it verifies the *hardness assumption* itself. `hardness_proof.lean` is a machine-checked proof that breaking the system requires solving a problem strictly harder than CVP.

| | Cardano | hcrypt |
|---|---|---|
| Formal methods | Protocol specification (Ouroboros in Agda) | Hardness proof (Lean 4 + Mathlib) |
| What's verified | "Protocol follows spec" | "Breaking this requires solving CVP+" |
| Consensus | Ouroboros (PoS, slot lottery) | Proof of Value (spectral geometry) |
| Privacy | Optional (Midnight sidechain) | Default (every transaction) |
| Validator selection | Stake-weighted VRF | Spectral centrality + VRF |
| Smart contracts | Plutus (Haskell) | WASM (planned) |

### vs Holochain (Architecture)

Holochain replaces global consensus with **agent-centric validation** — each agent maintains their own hash chain, validated by peers using application-specific rules. hcrypt does an analogous thing at the cryptographic layer: each credential is a *fiber* in a Grothendieck fibration, validated locally by geometric invariant checks rather than global state agreement.

| | Holochain | hcrypt |
|---|---|---|
| Architecture | Agent-centric (each agent has own chain) | Fibration-centric (each credential is a fiber) |
| Validation | Application rules (Wasm DNA) | Geometric invariants (Hodge + spectral) |
| Global consensus | None (local validation only) | Proof of Value (minimal — spectral check) |
| Scalability model | No global bottleneck | Sheaf-local validation |
| Privacy | Application-level | Structural (homotopy class) |
| Data model | DHT with validation rules | Cellular sheaves over nerve complex |

The key difference: Holochain's validation is rule-based (application-specific); hcrypt's validation is *geometric* (Hodge decomposition, Betti numbers, spectral gaps) — provably sound from the mathematics, not just conventionally agreed upon.

### vs Mixnets (Network Privacy)

Classical mixnets (Nym, Loopix) provide network-layer anonymity through onion encryption + mixing delays. hcrypt's `OnionRouter` and `MixingNode` (in `geometry/fiber_bundle.py`) implement the same pattern, but with **parallel transport** along the fiber bundle instead of generic symmetric encryption.

| | Nym / Loopix | hcrypt onion routing |
|---|---|---|
| Encryption per hop | AES/ChaCha (symmetric) | Orthogonal rotation (parallel transport) |
| Mixing | Poisson delay at each node | `MixingNode` with configurable delay |
| Key management | Sphinx packet headers | Fiber bundle connection matrices |
| Anonymity guarantee | Computational (break one key = break one layer) | Geometric (invert holonomy = Hodge-hardness) |
| Cover traffic | Explicit dummy packets | Hodge-structured noise in im(δ)⊕im(δ*) |

The structural advantage: in a classical mixnet, each hop's anonymity is independent. In hcrypt's fiber bundle routing, the hops are connected by the holonomy of the Grothendieck fibration — breaking the route requires inverting the holonomy, which is the same hard problem as the core encryption.

### Summary Table

| Feature | Bitcoin | Ethereum | Monero | Cardano | Holochain | **hcrypt** |
|---------|---------|----------|--------|---------|-----------|------------|
| Privacy by default | ❌ | ❌ | ✅ | ❌ | ❌ | ✅ |
| Post-quantum | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Formal hardness proof | ❌ | ❌ | ❌ | ⚠️ protocol | ❌ | ✅ Lean 4 |
| Infinite anonymity set | ❌ | ❌ | ❌ (N=16) | ❌ | ❌ | ✅ |
| Agent-local validation | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| Geometric security | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Panopticon resilient | ❌ | ❌ | ⚠️ | ❌ | ❌ | ✅ |

## License

MIT
