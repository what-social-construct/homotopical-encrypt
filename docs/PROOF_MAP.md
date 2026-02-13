# Lean Proof ↔ Python Implementation Map

This document maps every definition and theorem in `framework_consolidation.lean`
to its Python implementation, confirming the codebase is consistent with the
formally verified mathematical claims.

## Core Structures

| Lean | Python | Status |
|------|--------|--------|
| `SheafLaplacian V` (self-adjoint + PSD) | `src/geometry/sheaf_laplacian.py::SheafLaplacian` | ✅ Self-adjoint via `(L+L.T)/2`; PSD via `Δ = δ*δ` construction |
| `SpectralFingerprint L` (multiset of eigenvalues) | `src/crypto/credential.py::SpectralFingerprint` | ✅ `.eigenvalues` field = Laplacian spectrum |
| `SpectrallyEquivalent L1 L2` | `SpectralFingerprint.matches()` | ✅ Compares eigenvalue arrays |
| `is_harmonic Δ h := Δ·h = 0` | `src/invariants/harmonic.py::is_harmonic()` | ✅ Checks `‖Δc‖ < tol` |
| `CVP_Instance` / `Hodge_Instance` | `src/crypto/hardness.py::LatticeInstance` | ✅ Encodes lattice+target |
| `GrothendieckFibration p` | `src/geometry/fiber_bundle.py::FiberBundle` | ✅ Parallel transport = Cartesian lift |
| `Fibration B` (bundled fibration) | `src/crypto/credential.py::QuantumSheafFibration` | ✅ Contains sheaf + edge_keys + nerve |
| `FibrationCopy F n` | `src/crypto/credential.py::rotate_credential()` | ✅ Creates homotopy-equivalent copy |
| `HomotopyEquivalent p q` | `src/proofs/homotopy.py::prove_homotopy_equivalence()` | ✅ F∘G ≅ id, G∘F ≅ id |
| `HomotopyEquivalentLaplacians L1 L2` | Same kernel dimension (Betti numbers match) | ✅ Checked via `betti_numbers` comparison |

## Core Theorems

### 1. Hodge Decomposition (`Hodge_Decomposition_Theorem`, line 228)

**Lean**: For any cochain b, ∃ h, e1, e2 such that:
- `b = h + e1 + e2`
- `is_harmonic Δ h` (h ∈ ker(Δ))
- `e1 ∈ im(d_prev)` (exact)
- `e2 ∈ im(d_next*)` (coexact)
- `⟨h, e1⟩ = 0`, `⟨h, e2⟩ = 0`, `⟨e1, e2⟩ = 0` (pairwise orthogonal)

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

### 3. Hodge Ambiguity (`Hodge_Ambiguity_Proof`, line 150)

**Lean**: ∃ Δ₁, Δ₂, b such that b ∈ ker(Δ₁) but b ∉ ker(Δ₂).
Same ciphertext, different Laplacians → different meanings.

**Python**:
- `src/proofs/anonymity.py::prove_class_membership()` — ZK proof that credential
  is in a homotopy class without revealing which specific fibration
- `src/crypto/credential.py::rotate_credential()` — creates distinct fibrations
  in the same class (each has different Δ)

### 4. Hodge Strictly Harder (`Hodge_Strictly_Harder`, line 316)

**Lean**: No universal solver can find harmonic projections for ALL Laplacians
given only a CVP oracle. (Because ambiguity: the oracle doesn't know which Δ.)

**Python**: This is the core security argument — the adversary sees the ciphertext
but doesn't know the fibration (restriction maps). Without the fibration, they
can't construct Δ_sheaf, so they can't do harmonic projection.

### 5. Hodge Projection = CVP (`Hodge_Projection_Is_CVP`, line 341)

**Lean**: The closest harmonic vector to b is the CVP solution.
If h is the closest vector in ker(Δ) to b, then for any other h' ∈ ker(Δ),
dist(b, h) ≤ dist(b, h').

**Python**:
- `src/invariants/harmonic.py::project_to_harmonic()` — orthogonal projection
  onto ker(Δ), which IS the closest point (by Hilbert space theory)
- `src/crypto/decrypt.py::projective_measurement()` — the ZK-compatible version

### 6. Spectrum Not Homotopy Invariant (`Spectrum_Not_Homotopy_Invariant`, line 548)

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

## Encryption/Decryption Pipeline (matches Lean Hodge path)

```
ENCRYPT (v3 — Hodge path):
  1. Build Δ_sheaf from credential's restriction maps     [SheafLaplacian]
  2. Find ker(Δ_sheaf) via eigendecomposition              [is_harmonic]
  3. Encode message as coefficients in harmonic basis       [embed_in_harmonic]
  4. Message embedding IS a global section ∈ ker(Δ)        [Hodge_Decomposition_Theorem]
  5. Add noise in im(δ)⊕im(δ*) (orthogonal to message)   [Hodge_Decomposition_Theorem]
  6. ciphertext = harmonic_message + orthogonal_noise

DECRYPT (v3 — Hodge path):
  7. Assemble full cochain from vertex blocks
  8. Project onto ker(Δ_sheaf) via π_H                     [Hodge_Projection_Is_CVP]
  9. Extract coefficients from harmonic basis               [extract_from_harmonic]
  10. Decode coefficients → message bytes                   [_decode_harmonic]

SECURITY:
  Without the fibration, recovering the message requires
  solving CVP on ker(Δ_sheaf)                               [Hodge_Hardness_Reduction]
  No universal solver exists                                 [Hodge_Strictly_Harder]
  Same ciphertext could mean different things under
  different Laplacians                                       [Hodge_Ambiguity]
```

## Version History

- **v1** (deprecated): Discrete Gaussian noise — no formal backing in Lean proof
- **v2**: Lattice path (fallback when dim(ker(Δ)) < message bits)
- **v3**: Hodge path (message ∈ ker(Δ), matches framework_consolidation.lean)

## Key Implementation Notes

### Relative Thresholds for ker(Δ) Detection

Sheaf eigenvalues can be ~10¹² (due to lattice-scale restriction maps with entries ~10⁴).
Absolute thresholds like `1e-10` fail catastrophically. All kernel detection now uses:

```python
max_eig = np.max(np.abs(eigenvalues))
effective_threshold = max(max_eig * 1e-10, zero_threshold)
```

This matches the Lean proof's abstract `is_harmonic Δ h := Δ·h = 0` — we're just
accounting for floating-point arithmetic on large-scale matrices.

Files with relative threshold:
- `src/crypto/encrypt.py` (encrypt kernel detection)
- `src/crypto/decrypt.py` (decrypt kernel detection)
- `src/invariants/harmonic.py` (project_to_harmonic, embed_in_harmonic, extract_from_harmonic, validate_harmonic_embedding)
