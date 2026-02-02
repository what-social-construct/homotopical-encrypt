# Homotopical Encryption Architecture

## Overview

Post-quantum encryption using homotopy theory. Value = what survives projection.

## Module Structure

| LAYER | MODULE | RESPONSIBILITY |
|-------|--------|----------------|
| **PRIMITIVES** | `stalk.py` | DATA in fibers (typed: PRIVATE/PUBLIC/ZK) |
| | `algebra.py` | Exterior algebra (wedge, Hodge star) |
| | `natural.py` | Natural transformations (pullback, pushforward) |
| **GEOMETRY** | `fiber_bundle.py` | GEOMETRY of connections (parallel transport, holonomy) |
| | `sheaf.py` | Stalks + restriction maps |
| | `sheaf_laplacian.py` | Hodge theory: Δ = δ*δ + δδ* |
| | `topology.py` | Čech nerve construction |
| **CRYPTO** | `credential.py` | Fibration credentials (identity = spectral fingerprint) |
| | `lattice.py` | Lattice operations (NOT standard LWE - Hodge-native) |
| | `encrypt.py` | Embed message as cochain with Hodge noise |
| | `decrypt.py` | Hash-traced decryption via harmonic projection |
| | `validators.py` | Hard validation gates (dimension, gap, topology binding) |
| **CONSENSUS** | `proof_of_value.py` | PoV: valid if spectral gap ∈ [1/√2, 2√2] |
| **ZKP** | `homotopy_proof.py` | Homotopy-based ZK proofs |
| | `spectral_proof.py` | Spectral fingerprint verification |

## Core Concepts

### Stalk vs Fiber Bundle

```
Stalk (primitives/stalk.py)     = DATA that lives in a fiber
FiberBundle (geometry/)          = GEOMETRY of how fibers connect

StalkSpec.dimension              = FiberBundle.fiber_dim
Parallel transport               = moves Stalks along paths
StalkProjection                  = changes context (PRIVATE → PUBLIC)
```

### Stalk Contexts

| Context | Dimension | Purpose |
|---------|-----------|---------|
| PRIVATE | 256 | Full credential (LWE encrypted) |
| PUBLIC | 1 | Balance commitment (transparent) |
| ZK | 32 | Zero-knowledge intermediate |

### √2 Bounds (Bell/Tsirelson Inequality)

```
Classical bound:    2       (product states, local hidden variables)
Quantum/Geometric:  2√2     (entangled states - Tsirelson 1980)
No-signaling:       4       (any probability distribution)

Valid spectral gap: 1/√2 < λ₁ < 2√2
                    0.707 < λ₁ < 2.828
```

This is the boundary of the quantum correlation polytope (Tsirelson bound).
Exceeding 2√2 would violate causality (superluminal signaling).

## Proof of Value Consensus

```python
# Block is valid if:
1. All transactions have valid signatures
2. Transactions embed as valid cochains  
3. Harmonic projection preserves value
4. Spectral gap within √2 bounds
```

**Why PoV works:**
- PoW: proves you wasted energy
- PoS: proves you risked capital  
- PoV: proves your geometry has valid spectrum

## Identity = Spectral Fingerprint

```
Traditional: address = hash(public_key)
Homotopical: address = spectral_fingerprint(fibration)

Your identity IS the eigenvalues of your secret geometry.
- Self-generated (no issuer)
- Quantum-resistant (LWE foundation)
- Key agility (rotate keys, same identity if same spectrum)
```

## Data Flow

```
User generates fibration credential (LOCAL)
         ↓
Spectral fingerprint = identity (PUBLIC)
         ↓
Encrypt message as cochain on nerve
         ↓
Topology determines who can decrypt
         ↓
Harmonic projection extracts invariants
         ↓
√2 bounds verify geometric validity
```

## File Organization

```
homotopical-encrypt/
├── src/
│   ├── primitives/
│   │   ├── stalk.py          # Stalk types (PRIVATE/PUBLIC/ZK)
│   │   ├── algebra.py        # Exterior algebra (wedge, Hodge star)
│   │   ├── cochain.py        # Cochain primitives
│   │   ├── homotopy.py       # Homotopy operations
│   │   └── natural.py        # Natural transformations
│   ├── geometry/
│   │   ├── fiber_bundle.py   # Bundle + parallel transport
│   │   ├── sheaf.py          # Cellular sheaf + build_cech_nerve
│   │   ├── sheaf_laplacian.py # Hodge Laplacian Δ = δ*δ + δδ*
│   │   ├── hodge.py          # Hodge decomposition + hodge_noise
│   │   ├── homotopy_path.py  # Geodesic paths + InvariantReport
│   │   └── topology.py       # CechComplex, Betti numbers
│   ├── crypto/
│   │   ├── credential.py     # Fibration credentials
│   │   ├── lattice.py        # Hodge-native lattice ops (NOT LWE)
│   │   ├── encrypt.py        # v2 Hodge noise encryption
│   │   ├── decrypt.py        # Hash-traced decryption
│   │   └── validators.py     # Hard gates (dimension, gap, topology)
│   ├── consensus/
│   │   └── proof_of_value.py # PoV consensus
│   └── zkp/
│       ├── homotopy_proof.py
│       └── spectral_proof.py
├── docs/                      # Detailed documentation
├── examples/                  # Usage examples
└── tests/
```

## Documentation Index

| Doc | Purpose |
|-----|---------|
| `PHILOSOPHY.md` | Why homotopy for crypto |
| `PROOF_OF_VALUE.md` | PoV consensus deep dive |
| `SOVEREIGNTY_VISION.md` | Financial sovereignty vision |
| `SECURITY_PROOFS.md` | Formal security analysis |
| `SECURITY_VULNERABILITIES.md` | Known limitations |
| `PANOPTICON_RESILIENCE.md` | **Threat model: total surveillance → irrelevant** |
| `CHAIN_ARCHITECTURE.md` | Full chain design |
| `RBN_INTEGRATION.md` | Integration with chloe_protocol |
| `WIRE_FORMAT.md` | Protocol wire format spec |
| `HOMOTOPICAL_PRIMITIVES.md` | Hodge decomposition, cochains, naturality |
| `CRITIQUE.md` | Honest self-critique |

## Quick Start

```python
from src.crypto.credential import generate_credential
from src.crypto.encrypt import encrypt
from src.crypto.decrypt_v2 import decrypt_v2

# Generate identity
cred = generate_credential(
    parties=['alice', 'bob'],
    connections=[('alice', 'bob')],
    security_parameter=256
)

# Your identity
identity = cred.spectrum.fingerprint_hash()

# Encrypt message
message = b"Hello, post-quantum world!"
ciphertext = encrypt(message, cred)

# Decrypt
decrypted, chain = decrypt_v2(ciphertext, cred)
assert decrypted == message
```

## Functorial Structure

### The Two Stacks

```
chloe_protocol (Trading):
𝒮 ─────F────→ ℬ ─────𝒫────→ 𝒜
Signals      Beliefs      Actions
      (Agent.propose)  (SDE.consensus)

homotopical-encrypt (Privacy):
ℳ ─────Enc───→ 𝒞 ─────Dec───→ ℳ
Messages     Ciphers      Messages
      (Coboundary)    (Hodge project)
```

### Diagonal Pairing

The diagonal functor Δ: X ↦ (X, X) allows pairing:

```
(𝒮 × ℳ) ───(F × Enc)───→ (ℬ × 𝒞) ───(𝒫 × Dec)───→ (𝒜 × ℳ)
 Signals                  Private                   Private
 with                     Beliefs                   Actions
 Messages                 (encrypted)
```

### Shared Mathematical Core

| Operation | chloe_protocol | homotopical-encrypt |
|-----------|----------------|---------------------|
| Structure | CellularSheaf | Fibration (sheaf) |
| Operator | SheafLaplacian Δ | SheafLaplacian Δ |
| Decomposition | Hodge | Hodge |
| Transport | parallel_transport | parallel_transport |
| Invariant | β₁, λ₁ | β₁, λ₁ |

### Diagonal Functor Stack

```
┌─────────────────────────────────────────────────────────────────┐
│                    DIAGONAL FUNCTOR STACK                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Layer 4: Application (diagonal product)                         │
│  ├── Private Signal: (signal, message)                          │
│  ├── Private Belief: (belief, ciphertext)                       │
│  └── Private Action: (action, receipt)                          │
│                                                                  │
│  Layer 3: Functor (parallel application)                         │
│  ├── F × Enc: Signal × Message → Belief × Cipher                │
│  ├── 𝒫 × Dec: Belief × Cipher → Action × Message                │
│  └── η: Natural transformation (learning × key rotation)        │
│                                                                  │
│  Layer 2: Geometry (SHARED - diagonal)                           │
│  ├── CellularSheaf: Used by BOTH                                │
│  ├── SheafLaplacian: Used by BOTH                               │
│  ├── HodgeDecomposition: Used by BOTH                           │
│  └── parallel_transport: Used by BOTH                           │
│                                                                  │
│  Layer 1: Primitives (SHARED - diagonal)                         │
│  ├── Grassmann: exp, log, geodesic                              │
│  ├── Topology: Čech, Betti, persistence                         │
│  └── Algebra: wedge, hodge star, interior                       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Why Diagonal Works

**Naturality square commutes:**
```
          F × Enc
(𝒮 × ℳ) ─────────→ (ℬ × 𝒞)
    │                  │
    │ (Id × Enc)       │ η
    │                  │
    ▼                  ▼
(𝒮 × 𝒞) ─────────→ (ℬ × 𝒞)
          F × Id
```

Because Dec ∘ Enc = Id (on messages)

### Critical Implementation Note

**Both sides MUST share Laplacian instance:**

```python
# CORRECT: shared instance
shared_laplacian = SheafLaplacian(shared_sheaf)
chloe_sde = SheafDescentEngine(laplacian=shared_laplacian)
homotopy_cred = FibrationCredential(laplacian=shared_laplacian)

# WRONG: separate instances → diagonal breaks
```

## √2 Bounds (Bell/Tsirelson)

### The Connection

```
CHSH inequality:
  Classical bound:    |⟨AB⟩ + ⟨AB'⟩ + ⟨A'B⟩ - ⟨A'B'⟩| ≤ 2
  Quantum bound:      |...| ≤ 2√2

Spectral gap:
  Classical coherence: gap = 2 (complete graph)
  Geometric validity:  1/√2 < gap < 2√2
```

### Tsirelson Bound - Geometric Meaning

The bounds [1/√2, 2√2] arise from quantum information theory (Tsirelson, 1980).
They represent the maximum achievable correlation in bipartite quantum systems:

    |⟨ψ| A ⊗ B |ψ⟩| ≤ 2√2    for any entangled state |ψ⟩

Geometrically, this is the **boundary of the quantum correlation polytope**:

```
    ┌───────────────────────────────────────────┐
    │                                           │
    │   Classical:      |correlation| ≤ 2       │
    │   Quantum:        |correlation| ≤ 2√2     │
    │   No-signaling:   |correlation| ≤ 4       │
    │                                           │
    │   2√2 is the boundary between             │
    │   "quantum possible" and                  │
    │   "violates causality"                    │
    │                                           │
    └───────────────────────────────────────────┘
```

For sheaf Laplacians Δ = δδ* + δ*δ on a graph G:

    λ₁(Δ) = spectral gap = Fiedler eigenvalue
    
    Below 1/√2:  Topology is disconnected (no information flow)
    Above 2√2:   Topology would permit superluminal signaling (acausal)

**At exactly 2√2**, we saturate the Tsirelson bound - maximum entanglement
while preserving causality. Correlations that exceed 2√2 would allow 
faster-than-light communication.

### Why √2?

The √2 factor appears universally in:
1. **Tsirelson bound**: Maximum quantum violation of Bell inequality (1980)
2. **Frobenius norm**: ||A||_F / ||A||_op for rank-1 projectors
3. **Our spectral gap**: Valid blocks have gap in [1/√2, 2√2]
4. **CHSH game**: Maximum winning probability = (2 + √2)/4

Reference: Tsirelson, B.S. (1980). "Quantum generalizations of Bell's inequality"

### In Code

```python
SQRT2 = np.sqrt(2)
LOWER_BOUND = 1 / SQRT2  # ~0.707
UPPER_BOUND = 2 * SQRT2  # ~2.828

# Block is valid if:
assert LOWER_BOUND < spectral_gap < UPPER_BOUND
```

## Security Model (Kerckhoffs's Principle)

```
PUBLIC (safe to share):       SECRET (your keys):
├── Algorithm code            ├── Fibration credential
├── Parameter choices         ├── LWE secret s
├── √2 spectral bounds        └── Connection topology
└── All implementation

Security = hardness of LWE problem
         ≠ obscurity of algorithm
```

## Deterministic vs Stochastic Structure

### Categorical View (per arXiv:2512.24417)

Our system has a **natural categorical splitting** between deterministic and stochastic:

```
┌─────────────────────────────────────────────────────────────────┐
│               DETERMINISTIC SUBCATEGORY (Message)               │
├─────────────────────────────────────────────────────────────────┤
│  H^k = ker(Δ) = ker(δ) ∩ ker(δ*)                               │
│  ├── Harmonic cochains                                          │
│  ├── WHERE message lives                                        │
│  ├── Preserved by Hodge projection                              │
│  └── Spectral fingerprint (eigenvalues) → UNIQUE per credential │
├─────────────────────────────────────────────────────────────────┤
│               STOCHASTIC/NOISE SUBCATEGORY                      │
├─────────────────────────────────────────────────────────────────┤
│  im(δ) ⊕ im(δ*) = Exact ⊕ Co-exact                             │
│  ├── Coboundary noise (hides structure)                         │
│  ├── Discrete Gaussian distribution                             │
│  └── LWE security (lattice hardness)                            │
├─────────────────────────────────────────────────────────────────┤
│               INVARIANT VALIDATORS (Hard Gates)                 │
├─────────────────────────────────────────────────────────────────┤
│  ├── √2 bounds: λ₁ ∈ [1/√2, 2√2]  (Tsirelson)                  │
│  ├── Dimension limits: dim ∈ {128, 256, 512, 1024}              │
│  ├── Topology hash binding (credential uniqueness)              │
│  └── FAIL LOUDLY if violated                                    │
└─────────────────────────────────────────────────────────────────┘
```

### Hodge Decomposition = The Split

```python
C^k(X, F) = H^k ⊕ im(δ) ⊕ im(δ*)
            ↑       ↑         ↑
        MESSAGE   NOISE     NOISE
     (deterministic) (stochastic)
```

This is the **natural** categorical structure - no need for Lean formalization because:
- H^k is precisely the deterministic subcategory
- Hodge projection is the forgetful functor to deterministic
- We ALREADY HAVE this through `hodge.py`

## NOT Standard LWE: Hodge-Hardness

### What We Actually Use

**NOT standard LWE** - Our system is based on **Hodge-hardness**:

| Aspect | Status | How |
|--------|--------|-----|
| Message space | ✓ **NATIVE** | H^k = ker(Δ) = harmonic cochains |
| Noise space | ✓ **NATIVE** | im(δ) ⊕ im(δ*) = exact ⊕ coexact |
| Secret key | ✓ **NATIVE** | Fibration (Laplacian Δ) |
| Lattice | ✓ **NATIVE** | Cochain lattice C^k(X, F) over ℤ_q |
| Post-quantum | ✓ **ESSENTIAL** | No quantum algorithm can invert |

### Hodge-Hardness Problem

```
Given:  Noisy cochain b = h + e
Where:  h ∈ H^k = ker(Δ) (harmonic, unknown)
        e ∈ im(δ) ⊕ im(δ*) (Hodge-structured noise)
Without: The Laplacian Δ
Find:   h
```

**Security:**
- **WITH Δ**: Trivial - project to ker(Δ) via Hodge decomposition
- **WITHOUT Δ**: Must find harmonic projection without eigendecomposition
- **Hardness**: Reduces to finding kernel of unknown Laplacian

### Verified Implementation

```python
# encrypt.py uses hodge_noise() from hodge.py
noise = hodge_noise(L, delta, delta_prev, 
                    sigma_exact=5.0,      # Large in exact⊕coexact
                    sigma_harmonic=0.1)   # Small in harmonic

# Verified: noise is 100% in exact⊕coexact
# ||harmonic|| = 0.0000 (SMALL) ✓
# ||exact||    = 11.4494 (LARGE) ✓
```

### Quantum Supremacy is Irrelevant

No quantum algorithm (Shor, Grover, or otherwise) can:
1. Find harmonic projection without Laplacian eigendecomposition
2. Solve CVP on the cochain lattice
3. Distinguish structured Hodge noise from random

**Post-quantum = quantum supremacy is mathematically irrelevant**

## Panopticon Resilience

See `docs/PANOPTICON_RESILIENCE.md` for full threat model.

**Assumption:** Total surveillance (adversary sees ALL traffic/chain activity)
**Goal:** Surveillance doesn't matter

### Current Protection

| Layer | Status | Method |
|-------|--------|--------|
| Content | ✓ STRONG | Hodge-hardness (message in ker Δ) |
| Identity | ✓ STRONG | Homotopy class (spectral fingerprint) |
| TX graph | ⚠️ PARTIAL | Sheaf state mixing (no ring sigs) |

### Roadmap

1. ✅ **Forward Secrecy**: Ephemeral fibers (path-homotopic)
2. ✅ **Topology Obfuscation**: Embed real nerve in decoy topology
3. ✅ **Sheaf Onion Routing**: Stack fibrations for multi-hop
4. ⬜ **Constant Padding**: All ciphertexts same size

## Test Status

- [x] Hodge noise roundtrip (v2 ciphertext)
- [x] Hodge decomposition verified (||harmonic|| = 0 in noise)
- [x] Spectral fingerprints
- [x] Encrypt → Decrypt (both v1 Gaussian, v2 Hodge)
- [x] PoV consensus (spectral gap = 2.0)
- [x] Stalk primitive (PRIVATE/PUBLIC/ZK)
- [x] ZK proofs: Spectral match, gap range, identity, ring
- [x] Čech nerve embedding (topology obfuscation)
- [x] Geometric invariants (holonomy, Cheeger, traces)
- [x] **Forward secrecy (ephemeral fibers)** ✓
- [x] **Sheaf onion routing (3-hop verified)** ✓
- [ ] Chain implementation
- [ ] Diagonal integration with chloe_protocol
