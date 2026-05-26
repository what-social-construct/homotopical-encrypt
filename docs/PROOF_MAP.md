# Lean Proof ↔ Python Implementation Map

This document maps the Lean proof workspace to the current Python implementation.
It is a parity guide, not a verified extraction pipeline: Lean owns the
mathematical claims, while Python currently provides runtime checks and tests.

## Core Structures

| Lean | Python | Status |
|------|--------|--------|
| `SheafLaplacian V` (self-adjoint + PSD) | `src/geometry/sheaf_laplacian.py::SheafLaplacian` | ✅ Self-adjoint via `(L+L.T)/2`; PSD via `Δ = δ*δ` construction |
| `SpectralFingerprint L` (multiset of eigenvalues) | `src/crypto/credential.py::SpectralFingerprint` | ✅ `.eigenvalues` field = Laplacian spectrum |
| `SpectrallyEquivalent L1 L2` | `SpectralFingerprint.matches()` | ✅ Compares eigenvalue arrays |
| `MatrixIsHarmonic Δ h := Δ·h = 0` (`lean/Hardness.lean`) | `src/invariants/harmonic.py::is_harmonic()` | ✅ Abstract hidden-operator harmonicity; runtime checks `‖Δc‖ < tol` |
| `Hcrypt.Laplacian.IsHarmonic W h` (`lean/Laplacian/Hodge.lean`) | `src/geometry/hodge.py::project_to_harmonic()` / `src/invariants/harmonic.py` | ✅ Structured projection-model harmonicity for `Delta_W = I - P_W`; bridged to `MatrixIsHarmonic (_root_.laplacian W) h` |
| `CVP_Instance` / `ExplicitLattice` / `CVPOracleCorrect` (`lean/CVP.lean`) | `src/crypto/hardness.py::LatticeInstance` | ✅ Encodes known-lattice problem objects; hardness remains an external assumption |
| `Hodge_Instance` (`lean/Hardness.lean`) | `src/crypto/hardness.py` Hodge-facing helpers | ✅ Encodes hidden-operator Hodge side |
| `GrothendieckFibration p` | `src/geometry/fiber_bundle.py::FiberBundle` | ✅ Parallel transport = Cartesian lift |
| `Fibration B` (bundled fibration) | `src/crypto/credential.py::QuantumSheafFibration` | ✅ Contains sheaf + edge_keys + nerve |
| `FibrationCopy F n` | `src/crypto/credential.py::rotate_credential()` | ✅ Creates homotopy-equivalent copy |
| `HomotopyEquivalent p q` | `src/proofs/homotopy.py::prove_homotopy_equivalence()` | ✅ F∘G ≅ id, G∘F ≅ id |
| `HomotopyEquivalentLaplacians L1 L2` | Same kernel dimension (Betti numbers match) | ✅ Checked via `betti_numbers` comparison |

## Proximity Projection Proof

The proximity proof path is documented in the canonical
[`PROXIMITY.md`](PROXIMITY.md). The current Lean shape is:

```text
Plucker frame witness
  -> committed cochain / local syndrome
  -> PlaneShadow R ι
  -> finite-field RS received word
  -> final RS proximity target
```

Key Lean entry points:

| Lean | Role | Status |
|------|------|--------|
| `Proximity/PluckerCochain.lean` | Plucker shadow to committed cochain/local syndrome | Stage-local invariants named |
| `Proximity/CochainPlane.lean` | Committed cochain to semantic plane shadow | Stage-local alignment and extraction invariants named |
| `Proximity/CochainReedSolomon.lean` | Plane shadow to RS received word | Field boundary and RS codeword compatibility named |
| `Proximity/ProjectionChain.lean` | Orchestrates the composed projection chain | Built and imported by `Proximity.lean` |
| `Proximity/Problem.lean` | Final promised gap comparison | Uses `EndToEndGapProjection` |

The remaining paper-level theorem is the calibrated end-to-end far/non-collapse
statement. The stage files account for concrete local invariants; the final gap
is checked only after the composed projection chain and RS metric/radius regime
are fixed.

## Core Theorems

### 1. Hodge Decomposition (`Hodge_Decomposition_Theorem`, line 228)

**Lean**: For any cochain b, ∃ h, e1, e2 such that:
- `b = h + e1 + e2`
- `MatrixIsHarmonic Δ h` (h ∈ ker(Δ)) at the hidden-operator abstraction level
- `e1 ∈ im(d_prev)` (exact)
- `e2 ∈ im(d_next*)` (coexact)
- `⟨h, e1⟩ = 0`, `⟨h, e2⟩ = 0`, `⟨e1, e2⟩ = 0` (pairwise orthogonal)

At the structured projection level, `lean/Laplacian/Hodge.lean` uses
`Hcrypt.Laplacian.IsHarmonic W h` for the canonical Grassmannian/subspace model
with `Delta_W = I - P_W`. `lean/Hardness.lean` links the two by
`matrix_harmonic_iff_projection_isHarmonic` when the abstract hidden operator is
the projection Laplacian.

**Python**:
- `src/geometry/hodge.py::hodge_decomposition()` — full decomposition
- `src/invariants/harmonic.py::hodge_decompose()` — alternative via projections
- `src/invariants/harmonic.py::validate_hodge_orthogonality()` — checks pairwise ⊥
- `src/invariants/harmonic.py::validate_laplacian_construction()` — checks Δ = δ*δ + δδ*

**Key precondition**: `d_next * d_prev = 0` (chain complex). Enforced by
`src/geometry/hodge.py::build_coboundary_operator()` which constructs δ₀, δ₁
from the nerve such that δ₁∘δ₀ = 0.

### 2. Hodge Hardness Reduction (`Hodge_Hardness_Reduction_Proof`, line 208)

**Lean**: If a solver can find harmonic projections for any Δ, then it can solve CVP.
Specifically: for any basis B and target t, construct Δ with ker(Δ) = im(B),
then solver(t) gives a lattice vector.

**Python**:
- `src/crypto/hardness.py::LatticeInstance` — wraps the CVP instance
- `src/crypto/encrypt.py::encrypt()` — Hodge path embeds message in ker(Δ)
- `src/crypto/decrypt.py::decrypt()` — Hodge path recovers via π_H projection
- Security claim: without the fibration (restriction maps), recovering the
  message requires solving CVP on ker(Δ_sheaf).

### 3. Hodge Ambiguity (`Hodge_Ambiguity_Proof`)

**Lean**: ∃ Δ₁, Δ₂, b such that b ∈ ker(Δ₁) but b ∉ ker(Δ₂).
Same ciphertext, different Laplacians → different meanings.

**Python**:
- `src/proofs/anonymity.py::prove_class_membership()` — ZK proof that credential
  is in a homotopy class without revealing which specific fibration
- `src/crypto/credential.py::rotate_credential()` — creates distinct fibrations
  in the same public class (each may have different Δ)

### 4. Hidden-Operator Strictness (`PublicCompatibleHodgeAmbiguity`, `KernelAmbiguous`, `CVP_Oracle_Insufficient_For_Public_Hodge_Solving`)

**Lean**: A public fingerprint/class can contain multiple hidden Laplacians with
different harmonic kernels. A CVP oracle solves only CVP on a fixed, presented
lattice; it does not identify which hidden representative determines ker(Δ).

**Python**: This is the core security argument — the adversary sees the ciphertext
but doesn't know the fibration (restriction maps). Without the fibration, they
can't construct Δ_sheaf, so they can't do harmonic projection.

### 5. Hodge Projection = CVP (`Hodge_Projection_Is_CVP`)

**Lean**: The closest harmonic vector to b is the CVP solution. At the
hidden-operator abstraction level, `Hodge_Projection_Is_CVP` packages the claim
as `HodgeCVPSolution`: h is harmonic for Δ and is no farther from b than any
other harmonic vector.

At the structured projection level, `harmonicProjection_Is_ProjectionHodgeCVPSolution`
uses `lean/Laplacian/Hodge.lean`'s canonical `harmonicProjection W b`. The bridge
lemma `matrix_harmonic_iff_projection_isHarmonic` keeps both levels tied to the
same object when `Δ = Delta_W`.

**Python**:
- `src/invariants/harmonic.py::project_to_harmonic()` — orthogonal projection
  onto ker(Δ), which IS the closest point (by Hilbert space theory)
- `src/crypto/decrypt.py::projective_measurement()` — the ZK-compatible version

### 6. Spectrum Not Homotopy Invariant (`Spectrum_Not_Homotopy_Invariant`)

**Lean**: ∃ L1, L2 with same kernel dimension but different spectral fingerprints.
(ScalarLaplacian(1) and ScalarLaplacian(2): both have ker dim 0, but spectra {1} ≠ {2}.)

**Python**:
- `src/crypto/credential.py` docstring: "eigenvalues are a FINER invariant than
  the homotopy class" — the spectral fingerprint identifies a specific fibration,
  not just its homotopy class
- This is the anonymity foundation: `|[F]| = ∞` means infinitely many fibrations
  share the same Betti numbers but have distinct spectra

### 7. Copy Equivalence (`copy_equivalent_thm`, line 577)

**Lean**: FibrationCopy(F, n) is homotopy equivalent to F for all n.

**Python**:
- `src/crypto/credential.py::rotate_credential()` — creates a new credential
  that is homotopy equivalent (same topology, different restriction maps)
- `src/proofs/homotopy.py::prove_homotopy_equivalence()` — proves two credentials
  are in the same homotopy class

### 8. Transaction/Block Validation Boundary (`lean/Chain.lean`)

**Lean**: `TransactionWellFormed`, `TransactionAccepted`, `BlockAccepted`, and
`LedgerState` specify the abstract consensus-state facts used by no-double-spend
and block-acceptance reasoning. The preservation lemmas
`acceptedTransaction_key_image_fresh`, `blockAccepted_tx_not_previously_spent`,
`applyTransaction_marks_key_image`, and `applyBlock_marks_tx_key_image` make the
key-image state boundary explicit.

**Rust**:
- `rust/node/src/types.rs` — runtime transaction/block structures and cochain
  root computation
- `rust/node/src/consensus/pov.rs` — production block verification path
- `rust/node/src/storage/keyimages.rs` — key-image persistence boundary
- `rust/node/src/storage/state.rs` — block application and state transition

Lean does not own byte parsing, canonical encodings, allocation bounds, storage,
or endpoint behavior. Those remain Rust runtime concerns; see
`docs/TRUST_BOUNDARIES.md`.

## Encryption/Decryption Pipeline (matches Lean Hodge path)

```
ENCRYPT (v3 — Hodge path):
  1. Build Δ_sheaf from credential's restriction maps     [SheafLaplacian]
  2. Find ker(Δ_sheaf) via eigendecomposition              [MatrixIsHarmonic / IsHarmonic]
  3. Encode message as coefficients in harmonic basis       [embed_in_harmonic]
  4. Message embedding IS a global section ∈ ker(Δ)        [Hodge_Decomposition_Theorem]
  5. Add noise in im(δ)⊕im(δ*) (orthogonal to message)   [Hodge_Decomposition_Theorem]
  6. ciphertext = harmonic_message + orthogonal_noise

DECRYPT (v3 — Hodge path):
  7. Assemble full cochain from vertex blocks
  8. Project onto ker(Δ_sheaf) via π_H                     [Hodge_Projection_Is_CVP / harmonicProjection_Is_ProjectionHodgeCVPSolution]
  9. Extract coefficients from harmonic basis               [extract_from_harmonic]
  10. Decode coefficients → message bytes                   [_decode_harmonic]

SECURITY:
  Without the fibration, recovering the message requires
  solving CVP on ker(Δ_sheaf)                               [Hodge_Hardness_Reduction]
  Public data does not determine a unique hidden kernel       [KernelAmbiguous]
  A known-lattice CVP oracle is insufficient by itself        [CVP_Oracle_Insufficient_For_Public_Hodge_Solving]
  Same public cochain could mean different things under
  different hidden Laplacians                                [Hodge_Ambiguity]
```

## Version History

- **v1** (deprecated): Discrete Gaussian noise — no formal backing in Lean proof
- **v2**: Lattice path (fallback when dim(ker(Δ)) < message bits)
- **v3**: Hodge path (message ∈ ker(Δ), aligned with the Lean proof workspace)

## Key Implementation Notes

### Relative Thresholds for ker(Δ) Detection

Sheaf eigenvalues can be ~10¹² (due to lattice-scale restriction maps with entries ~10⁴).
Absolute thresholds like `1e-10` fail catastrophically. All kernel detection now uses:

```python
max_eig = np.max(np.abs(eigenvalues))
effective_threshold = max(max_eig * 1e-10, zero_threshold)
```

This matches the Lean proof's abstract `MatrixIsHarmonic Δ h := Δ·h = 0`; in the
projection model this is linked to `Hcrypt.Laplacian.IsHarmonic W h`. The runtime
threshold is only accounting for floating-point arithmetic on large-scale
matrices.

Files with relative threshold:
- `src/crypto/encrypt.py` (encrypt kernel detection)
- `src/crypto/decrypt.py` (decrypt kernel detection)
- `src/invariants/harmonic.py` (project_to_harmonic, embed_in_harmonic, extract_from_harmonic, validate_harmonic_embedding)
