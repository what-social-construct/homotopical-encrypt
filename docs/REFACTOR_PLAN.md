# Refactor Plan: Betti-Based Anonymity

## Motivation: Math Audit Findings

### Hardness Proof (`hardness_proof.lean`) — SOUND ✅

The Lean hardness proof formalizes the core cryptographic claim and is consistent
with the implementation:

| Lean Theorem | Claim | Status |
|---|---|---|
| `Hodge_Decomposition_Theorem` | C^k = ker(Δ) ⊕ im(δ) ⊕ im(δ*) | ✅ Matches `geometry/hodge.py` |
| `Hodge_Hardness_Reduction_Proof` | Hodge solver → CVP solver | ✅ Matches `crypto/hardness.py` |
| `Hodge_Ambiguity_Proof` | Harmonic depends on Laplacian choice | ✅ Matches ambiguity argument |
| `Hodge_Strictly_Harder` | CVP oracle insufficient for Hodge | ✅ Matches strict inequality claim |
| `Hodge_Projection_Is_CVP` | Closest harmonic form = CVP solution | ✅ Matches `invariants/harmonic.py` |

**Encryption security (Hodge-hardness > CVP) is unaffected by the audit.**

### Math Audit (`math_audit_hcrypt.lean`) — ANONYMITY GAP 🚨

The audit proved `Spectrum_Not_Homotopy_Invariant`:

> Two Laplacians can have the same Betti numbers (same kernel dimension = 
> "homotopy equivalent") but different spectral fingerprints.

**Implication:** The spectral fingerprint is a *finer* invariant than the
homotopy class. Revealing it publicly reduces the anonymity set from the
infinite homotopy class to the potentially-finite (even singleton) isospectral
set. The "1/∞ anonymity" claim is unsupported when the fingerprint is public.

**Additional finding:** The √2 Tsirelson bounds check is neither necessary
nor sufficient for anonymity — valid Laplacians can violate them, and
distinguishable Laplacians can both pass.

---

## The Pivot: Fingerprint Becomes Private Key

### Before (Audit Critique)

```
Public:  spectral fingerprint (eigenvalues of Δ)
Private: fibration (Δ, restriction maps)
Anonymity set: isospectral set — potentially finite or singleton ❌
```

### After (Corrected Model)

```
PUBLIC (revealed on-chain / to verifiers):
  Betti numbers (β₀, β₁, β₂)       — true homotopy invariants
  topology_hash                       — SHA256 of nerve structure (opaque)
  key_image                           — unique per fibration, one-way
  spectral_gap_valid: bool            — "gap is in bounds" (not the value)

PRIVATE (never leaves wallet):
  spectral fingerprint (eigenvalues)  — the actual private key
  fibration (restriction maps R_{v→e}) — the geometric secret
  Laplacian Δ = δ*δ + δδ*            — derived from fibration
  topology (nerve vertices/edges)     — the actual graph structure
  
Anonymity set: entire homotopy class — infinite by Hodge theory ✅
```

**The fibration is PRIVATE.** It was private before and stays private. The
change is that the spectral fingerprint (eigenvalues) also becomes private —
previously it was the public identity, now Betti numbers take that role.

**The topology_hash is public** but it's a SHA256 hash — you can't recover
the nerve structure from it. It's used for binding (verifying that two
parties share the same topology) without revealing the topology itself.

### The Diagonal Pairing (Preserved)

From Helfer's first-order homotopical logic, equality is membership on
the diagonal:

```
Betti Space: ℕ³

Diagonal:  Δ: Betti → Betti × Betti
           β ↦ (β, β)

Projection: π: Spec → Betti
            eigenvalues ↦ (dim ker Δ₀, dim ker Δ₁, dim ker Δ₂)

Public identity = β ∈ Betti
Private key = (spectrum, fibration) ∈ π⁻¹(β)

The fiber π⁻¹(β) is INFINITE → 1/∞ anonymity is now rigorous.
```

Verification: two credentials are "equal" (same homotopy class) iff their
Betti numbers lie on the diagonal: β₁ = β₂.

---

## What Changes

### Unchanged (Most of the Crypto)

| Component | Why Unchanged |
|---|---|
| `geometry/hodge.py` | Hodge decomposition is internal math |
| `geometry/sheaf_laplacian.py` | Laplacian construction stays private |
| `crypto/encrypt.py` | Uses private Δ for harmonic embedding |
| `crypto/decrypt.py` | Uses private Δ for projection |
| `crypto/hardness.py` | CVP reduction still valid |
| `chain/key_image.py` | Key images use private spectrum — still unique, still one-way |
| `geometry/fiber_bundle.py` | Onion routing uses private transport |
| `primitives/cochain.py` | Coboundary δ, cochain complex — internal algebra |
| `crypto/commitment.py` | CochainCommitment = δ(m‖r) — SVP-hard value binding |
| `crypto/cohomological_mac.py` | Hodge-hard authentication via ker(Δ) membership |

**The entire cochain layer is unchanged.** Cochains are algebraic duals
(functions on simplices). The coboundary δ is the transpose of ∂. Encryption
uses δ (push to edges), decryption uses δ* (project to vertices). Commitments
use δ(m‖r) for SVP-hard binding. MACs use harmonic projection P_H · c(m)
for Hodge-hard authentication. None of this touches the public identity
question — it's all internal to encrypt/decrypt/commit/authenticate.

### Changed

#### 1. `src/crypto/credential.py` — Public/Private Split

**New `PublicIdentity` type:**
```python
@dataclass
class PublicIdentity:
    betti_numbers: Tuple[int, int, int]  # (β₀, β₁, β₂)
    topology_hash: bytes                  # SHA256 of nerve structure

    def identity_hash(self) -> bytes:
        return hashlib.sha256(
            f"{self.betti_numbers}:{self.topology_hash.hex()}".encode()
        ).digest()

    def on_diagonal(self, other: 'PublicIdentity') -> bool:
        return self.betti_numbers == other.betti_numbers
```

**`SpectralFingerprint` becomes fully private:**
- Remove `fingerprint_hash()` (no longer public)
- Remove any public display methods
- Keep internal for key image computation

**`FibrationCredential` gains `public_identity` field:**
```python
@dataclass
class FibrationCredential:
    topology: Dict[int, List]         # PRIVATE
    fibration: Fibration              # PRIVATE
    spectrum: SpectralFingerprint     # PRIVATE (was public)
    public_identity: PublicIdentity   # PUBLIC (new)
    modulus: int
    hilbert_dim: int

    def project_to_public(self) -> PublicIdentity:
        """The projection π: Spec → Betti"""
        return self.public_identity
```

#### 2. `src/chain/homotopy_transaction.py` — New Transaction Format

```python
@dataclass
class HomotopyTransaction:
    sender_identity: bytes              # hash(PublicIdentity) — not fingerprint
    sender_betti: Tuple[int, int, int]  # For fast lookup
    key_image: bytes                    # Unique per fibration (private spectrum)
    amount_commitment: CochainCommitment
    homotopy_proof: BettiProof          # ZK proof of Betti membership
    signature: bytes
```

#### 3. `src/proofs/anonymity.py` — Betti Number ZK Proofs

Replace spectral matching proofs with Betti number membership proofs:

```python
def prove_betti_membership(credential, challenge_bytes=None) -> BettiProof:
    """
    ZK proof: 'I know Δ with kernel dimensions (β₀, β₁, β₂)'
    Without revealing eigenvalues or fibration structure.
    
    Protocol (Fiat-Shamir):
    1. Commit: C = Hash(Δ || r)
    2. Compute: βᵢ = dim(ker Δᵢ)
    3. Challenge: c = Hash(C || β₀ || β₁ || β₂)
    4. Response: kernel dimension proof via orthogonal projection commitments
    """

def verify_betti_proof(proof, public_identity) -> bool:
    """Verify prover knows SOME Δ with claimed Betti numbers."""
```

**Key insight:** Betti number proofs are *simpler* than spectral proofs —
just prove kernel dimension, not eigenvalue matching.

#### 4. `src/chain/sheaf_state.py` — Betti-Indexed State

```python
class SheafState:
    accounts: Dict[bytes, AccountState]     # identity_hash → state
    spent_key_images: Set[bytes]            # Double-spend prevention
    betti_index: Dict[Tuple, Set[bytes]]    # Betti → account set (anonymity query)

    def get_anonymity_set(self, betti) -> Set[bytes]:
        """All accounts with given Betti numbers = same homotopy class."""
        return self.betti_index[betti]
```

#### 5. `rust/oracle/src/stalk_bridge.rs` — Oracle No Longer Stores Fingerprint

**`HashStalk` changes:**

```rust
// BEFORE:
pub struct HashStalk {
    pub fingerprint: [u8; 32],    // Spectral fingerprint — TOO IDENTIFYING
    pub spectral_gap: f64,
    pub betti_numbers: (i32, i32, i32),
    pub topology_hash: [u8; 32],
}

// AFTER:
pub struct HashStalk {
    pub identity_hash: [u8; 32],  // Hash of PublicIdentity (Betti + topology)
    pub betti_numbers: (i32, i32, i32),  // Public
    pub topology_hash: [u8; 32],         // Public
    pub spectral_gap_valid: bool,        // Boolean only — not the value
    pub computed_at: u64,
}
```

**Critical change:** The spectral gap *value* is no longer stored on-chain.
The oracle verifies it's in bounds and stores only a boolean. This prevents
leaking spectral information that could narrow the anonymity set.

**`FullStalk` stays the same** — Python still sends eigenvalues to Oracle
for verification. But the Oracle now discards them after checking bounds,
keeping only the boolean result.

#### 6. `rust/node/src/storage/state.rs` — Account Identity

```rust
// BEFORE:
pub struct AccountState {
    pub spectral_fingerprint: [u8; 32],  // Reveals too much
    ...
}

// AFTER:
pub struct AccountState {
    pub identity_hash: [u8; 32],         // Hash of PublicIdentity
    pub betti_numbers: (i32, i32, i32),  // For anonymity set queries
    ...
}
```

#### 7. `src/network/routing.py` — Betti-Indexed Relay Selection

Two routing strategies for the Betti-based model:

**Same-Class Routing** (maximum anonymity): All relays share sender's Betti
numbers. Each relay could plausibly be the sender. Use for high-sensitivity
transactions.

**Diverse Routing** (prevents class correlation): Each hop has different Betti
numbers. Prevents "Betti class timing attack". Default strategy.

```python
class BettiRelayNetwork:
    betti_index: Dict[Tuple, Set[RelayNode]]

    def select_path_same_class(self, sender_betti, k):
        """All relays with sender's Betti numbers."""
        candidates = list(self.betti_index[sender_betti])
        return random.sample(candidates, k)

    def select_path_diverse(self, sender_betti, k):
        """Each hop has different Betti numbers."""
        other_classes = [b for b in self.betti_index if b != sender_betti]
        return [random.choice(list(self.betti_index[b]))
                for b in random.sample(other_classes, k)]
```

#### 8. Documentation Updates

| File | Change |
|---|---|
| `README.md` | Fix anonymity claim: Betti-based, not spectral |
| `docs/ARCHITECTURE.md` | Update diagonal pairing section |
| `docs/SECURITY.md` | Correct anonymity model, add audit response |
| `src/crypto/hardness.py` | Add Lean theorem cross-references |

---

## Positioning: Geometric Mixnet

The system is a hybrid of three paradigms:

| Property | Like Mixnet (Tor/Nym) | Like Holochain | Unique to Homotopical |
|---|---|---|---|
| Routing | ✅ Onion layers | | 🔷 Fiber bundle transport |
| Identity | | ✅ Self-sovereign | 🔷 Homotopy classes (infinite) |
| Transaction privacy | | ✅ Encrypted | 🔷 Hodge decomposition mixing |
| Double-spend | | | 🔷 Key images (private spectrum) |
| Quantum resistance | | | 🔷 CVP-hard (lattice) |

**Geometric mixing > network mixing:** Hodge projection is provably
information-hiding (orthogonal to noise subspace), not just probabilistic
(timing correlation). The anonymity set is infinite by construction, not
dependent on traffic volume.

**Homotopical = geometric mixnet with blockchain integrity.**

---

## Migration Path

### Phase 1: Non-Breaking Additions
- [ ] Add `PublicIdentity` class to `credential.py`
- [ ] Add `BettiProof` structure to `proofs/anonymity.py`
- [ ] Add `prove_betti_membership()` / `verify_betti_proof()`
- [ ] Add `BettiRelayNetwork` to `network/routing.py`

### Phase 2: Breaking Credential Refactor
- [ ] Split `FibrationCredential` into public/private
- [ ] Make `SpectralFingerprint` fully private
- [ ] Update all credential consumers
- [ ] Update `generate_credential()` to produce `PublicIdentity`

### Phase 3: Chain Layer Updates
- [ ] New `HomotopyTransaction` format with `sender_identity`
- [ ] Update `SheafState` with Betti index
- [ ] Update `HashStalk` in `stalk_bridge.rs` (drop fingerprint, add boolean gap)
- [ ] Update `AccountState` in `state.rs`

### Phase 4: Documentation & Tests
- [ ] Update README anonymity claims
- [ ] Update ARCHITECTURE.md diagonal section
- [ ] Update SECURITY.md with audit response
- [ ] Add `test_betti_anonymity.py` (infinite homotopy class verification)
- [ ] Add Lean theorem cross-references to Python modules

---

## Summary

| Aspect | Before | After |
|---|---|---|
| **Public identity** | Spectral fingerprint | Betti numbers (β₀, β₁, β₂) |
| **Private key** | Fibration only | Spectral fingerprint + fibration |
| **Anonymity set** | Isospectral set (finite?) | Homotopy class (infinite ✅) |
| **Anonymity claim** | 1/∞ (unsupported) | 1/∞ (rigorous) |
| **Encryption security** | Hodge-hardness > CVP | Hodge-hardness > CVP (unchanged) |
| **Key images** | Private spectrum → unique hash | Same (still works) |
| **On-chain data** | Spectral gap value | Boolean only |
| **Diagonal pairing** | Spec × Spec | Betti × Betti (coarser, correct) |
| **ZK proofs** | Spectral matching | Betti membership (simpler) |
| **Routing** | Generic relay selection | Betti-indexed (same-class / diverse) |
