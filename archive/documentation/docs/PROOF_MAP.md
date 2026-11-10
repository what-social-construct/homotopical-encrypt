# Lean Proof ↔ Historical Python Map

Lean owns the current mathematical claims. The Python geometry and crypto
folders are suspended legacy prototypes, not verified refinements or a working
runtime. The file-by-file G0/C0 audit is canonical for their status; see
[`SEMANTIC_PARITY_QUEUE.md`](SEMANTIC_PARITY_QUEUE.md). This document retains
the intended correspondences so future implementations can recover useful test
lineage, but no Python row below establishes a theorem or security claim.

## Core Structures

| Lean | Python | Status |
|------|--------|--------|
| `CellularSheaf.degreeOneLaplacian` | `src/geometry/sheaf_laplacian.py::SheafLaplacian` | ❌ Historical only: the Python degree-one path discards restriction maps/stalk dimensions, while the live cipher uses degree zero |
| `SpectralFingerprint L` (multiset of eigenvalues) | `src/crypto/credential.py::SpectralFingerprint` | ⚠️ Numerical array container only; raw-float encoding and credential semantics are noncanonical |
| `SpectrallyEquivalent L1 L2` | `SpectralFingerprint.matches()` | ⚠️ Approximate spectrum comparison only; it is not homotopy equivalence or a classifier proof |
| `MatrixIsHarmonic Δ h := Δ·h = 0` (`lean/HCP.lean`) | Historical prototype: `docs/archive/python/src/invariants/harmonic.py::is_harmonic()` | ✅ Lean owns abstract hidden-operator harmonicity; the archived tolerance check is not a current runtime refinement |
| `HomotopicalEncryption.Laplacian.IsHarmonic W h` (`lean/Laplacian/Hodge.lean`) | `src/geometry/hodge.py` / archived invariant helpers | ⚠️ Historical numerical lineage; no current runtime refinement |
| `CVP.Instance` / `ExplicitLattice` / `CVPOracleCorrect` (`lean/CVP.lean`) | `src/crypto/hardness.py::LatticeInstance` | ❌ Different object: the Python class is an LWE-looking floating experiment, not the Lean CVP instance |
| HCP hidden-operator instance (`lean/HCP.lean`) | `src/crypto/hardness.py` | ❌ Narrative analogy only; it does not implement the Lean realization or reduction hypotheses |
| `GrothendieckFibration p` | `src/geometry/fiber_bundle.py::FiberBundle` | ❌ A graph of orthogonal matrices is not a Cartesian-lift witness |
| `Axioms.FiberSystem` / hidden representative | `src/crypto/credential.py::QuantumSheafFibration` | ❌ Legacy degree-zero container; arbitrary real maps are not the claimed quantum channels or a path-space realization |
| `EphemeralFiberSpec` | `src/crypto/credential.py::rotate_credential()` | ❌ Resampling supplies no path or transport witness |
| `Helfer.HomotopyEquivalent` | `src/proofs/homotopy.py::prove_homotopy_equivalence()` | ❌ Historical verifier; supplied numerical invariants do not construct the categorical equivalence |
| Kernel-dimension equality | Python Betti/spectrum comparisons | ⚠️ A coarse numerical predicate only; never identify it with homotopy equivalence |

## Proximity Projection Proof

The proximity proof path is documented in the canonical
[`PROXIMITY.md`](PROXIMITY.md), with the paper-facing outline in
[`PROXIMITY_PAPER_OUTLINE.md`](PROXIMITY_PAPER_OUTLINE.md). The current Lean
shape is:

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
| `Proximity/Public.lean` | Public/storage boundary aggregate | Owns storage-root-linked `CochainPlane.PublicBinding.PlaneView` and re-exports public Plücker/cochain bindings and gate evidence records |
| `Proximity/CochainReedSolomon.lean` | Plane shadow to RS received word | Canonical `ZMod 12289` boundary, integer plane encoding, and RS codeword compatibility named |
| `Proximity/ProjectionChain.lean` | Projection-chain import surface | Re-exports the map orchestration surface |
| `Proximity/ProjectionChain/Core.lean` | Orchestrates the composed projection chain | Defines only `Chain`, composed stage maps, and the induced evaluation projection |
| `Proximity/Gates/Stage.lean` | Stage-gate certificate accumulation | Defines stage checklists and accumulated stage certificates without recomputation |
| `Proximity/Gates/Final.lean` | Final radius/metric checks for an orchestrated chain | Calibrated readiness, far/non-collapse, final gap and RS bridge handoff |
| `Proximity/Gates.lean` | Cross-cutting proximity invariant gates | Names Plücker metric/chart, public-shadow respect, semantic alignment, syndrome adequacy, hard-gate certificates, the Plücker/cochain/RS far-gate pipeline, and the calibrated final certificate |
| `Proximity/CanonicalRS/Parameters.lean` | Concrete RS parameter regime | Fixes `ZMod 12289`, length `4096`, degree bound `1024`, rate `1/4`, Johnson-below radius `2047` |
| `Proximity/CanonicalRS/PowerDomain.lean` | Smooth power-domain construction | Defines `FullGenerator`, `PowerRoot`, the algebraic `FullGenerator.toPowerRoot` path, and the root candidate |
| `Proximity/CanonicalRS/Encoding.lean` | Canonical plane encoding | Defines `canonicalMix` and `integerPlaneEncoding` |
| `Proximity/CanonicalRS/Target.lean` | Canonical RS target wrapper | Packages list-decoding/MCA theorem slots around the fixed parameter regime |
| `Proximity/CanonicalRS/Metric.lean` | Canonical received-word metric | Defines geometric Hamming distance-to-code, absolute Hamming metric, and radius normalization |
| `Proximity/CanonicalRS/BridgeData.lean` | Canonical bridge endpoint and RS metric certificate | Bundles canonical domain, target, metric, normalization, encoding, code shadow, theorem slots, terminal bridge certificate, and ordered `RSMetricCertificate` |
| `Proximity/CanonicalRS/FarSeparation.lean` | Canonical Johnson RS far-separation proof | Names `JohnsonRSFarSeparation` and packages it with hard gates into the final gate and bridge |
| `Proximity/Problem.lean` / `Proximity/RS/Target.lean` | Final promised gap comparison | Uses `CalibratedEndToEndGapProjection`, `RadiusNormalization`, and calibrated RS bridge |

The remaining paper-level theorem is the calibrated end-to-end far-separation
statement. The stage files account for concrete local invariants; the final gap
is checked only after the composed projection chain and RS metric/radius regime
are fixed. `Proximity/Gates.lean` separates hard invariant evidence from the
metric proof route: public-shadow respect is an early post-Plücker gate,
Plücker-to-cochain non-collapse is the local fidelity gate, and the
cochain-to-RS gate proves far separation over the RS received-word metric.

Canonical RS now uses a certificate-driven smooth domain. Lean proves
`candidateGeneratorUnit_order : orderOf candidateGeneratorUnit = 12288`; cubing
that certified generator gives `canonicalPowerRoot : PowerRoot` with order
`4096`, and the domain evaluates at `root^i`. The chosen field candidate is
algebraic: `candidateGenerator := 11` and
`candidateRoot := candidateGenerator^3`. This is not a brute-force
cochain-to-RS extraction path.

The canonical RS received-word metric is also geometric: `hammingDistanceToCode`
is the infimum of Hamming distances to RS codewords, and
`absoluteRadiusNormalization` proves the absolute Hamming radius compatibility.
`CanonicalRS.BridgeData` packages the resulting endpoint while keeping external
RS bounds explicit. The remaining projection-chain/far-gap facts are routed
through an ordered certificate chain: `HardGateCertificate` carries stage and
structural gates, while `RSMetricCertificate` extends it with
`RadiusCalibration` and `rsFarSeparation`. The first concrete calibration is
`BridgeData.johnsonRadiusCalibration`, using the absolute Hamming radius for
`johnsonBelowRadius = 2047`; the remaining theorem is
`JohnsonRSFarSeparation`, packaged in `CanonicalRS.FarSeparation`. This theorem
is quotient-aware: intended pair collapse may occur, but far source instances
must not collapse into target-near RS words.

## Core Theorems

### 1. Hodge Decomposition (`Hodge_Decomposition_Theorem`, line 228)

**Lean**: For any cochain b, ∃ h, e1, e2 such that:
- `b = h + e1 + e2`
- `MatrixIsHarmonic Δ h` (h ∈ ker(Δ)) at the hidden-operator abstraction level
- `e1 ∈ im(d_prev)` (exact)
- `e2 ∈ im(d_next*)` (coexact)
- `⟨h, e1⟩ = 0`, `⟨h, e2⟩ = 0`, `⟨e1, e2⟩ = 0` (pairwise orthogonal)

At the structured projection level, `lean/Laplacian/Hodge.lean` uses
`HomotopicalEncryption.Laplacian.IsHarmonic W h` for the canonical Grassmannian/subspace model
with `Delta_W = I - P_W`. `lean/Hardness.lean` links the two by
`matrix_harmonic_iff_projection_isHarmonic` when the abstract hidden operator is
the projection Laplacian.

**Python**:
- `src/geometry/hodge.py::hodge_decomposition()` — full decomposition
- Archived `docs/archive/python/src/invariants/harmonic.py::hodge_decompose()` — historical alternative via projections
- Archived `docs/archive/python/src/invariants/harmonic.py::validate_hodge_orthogonality()` — historical pairwise-orthogonality diagnostic
- Archived `docs/archive/python/src/invariants/harmonic.py::validate_laplacian_construction()` — historical degree-\(k\) Laplacian diagnostic

**Key precondition**: `d_next * d_prev = 0` (cochain complex). It is proved for
the concrete restriction-aware cellular sheaf in `lean/Sheaf/Cellular.lean`.
`src/geometry/hodge.py::build_coboundary_operator()` is only a historical
constant-coefficient incidence fixture; it is not the Python sheaf operator.

### 2. Hodge Hardness Reduction (`Hodge_Hardness_Reduction_Proof`, line 208)

**Lean**: If a solver can find harmonic projections for any Δ, then it can solve CVP.
Specifically: for any basis B and target t, construct Δ with ker(Δ) = im(B),
then solver(t) gives a lattice vector.

**Historical Python intent**:
- `src/crypto/hardness.py::LatticeInstance` does **not** wrap the Lean CVP
  object;
- `src/crypto/encrypt.py` and `decrypt.py` use a degree-zero, floating,
  basis-dependent prototype; and
- no cryptographic reduction from that runtime to CVP or HCP is established.

### 3. Hodge Ambiguity (`Hodge_Ambiguity_Proof`)

**Lean**: ∃ Δ₁, Δ₂, b such that b ∈ ker(Δ₁) but b ∉ ker(Δ₂).
Same ciphertext, different Laplacians → different meanings.

**Historical Python intent**: the old anonymity verifier and
`rotate_credential()` do not provide a ZK proof, supplied homotopy path, or
classifier-fiber witness. They must not be cited as realizations of this Lean
statement.

### 4. Hidden-Operator Strictness (`PublicCompatibleHodgeAmbiguity`, `KernelAmbiguous`, `CVP_Oracle_Insufficient_For_Public_Hodge_Solving`)

**Lean**: A public fingerprint/class can contain multiple hidden Laplacians with
different harmonic kernels. A CVP oracle solves only CVP on a fixed, presented
lattice; it does not identify which hidden representative determines ker(Δ).

**Runtime status**: this is a conditional Lean hidden-operator statement, not a
security theorem for the Python ciphertext format. A future scheme must define
the adversary view and prove that its public bytes do not reveal or determine
the operative presentation.

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
- Archived `docs/archive/python/src/invariants/harmonic.py::project_to_harmonic()` — historical numerical orthogonal projection
  onto ker(Δ), which IS the closest point (by Hilbert space theory)
- `src/crypto/decrypt.py::projective_measurement()` — historical and explicitly
  **not** ZK-compatible: it returns the harmonic component.

### 6. Spectrum Not Homotopy Invariant (`Spectrum_Not_Homotopy_Invariant`)

**Lean**: ∃ L1, L2 with same kernel dimension but different spectral fingerprints.
(ScalarLaplacian(1) and ScalarLaplacian(2): both have ker dim 0, but spectra {1} ≠ {2}.)

**Python**:
- `src/crypto/credential.py` docstring: "eigenvalues are a FINER invariant than
  the homotopy class" — the spectral fingerprint identifies a specific fibration,
  not just its homotopy class
- This does not prove that a protocol-relevant classifier fiber is infinite,
  uniform, or anonymously sampled. Those require separate witnesses.

### 7. Copy Equivalence (`copy_equivalent_thm`, line 577)

**Lean**: FibrationCopy(F, n) is homotopy equivalent to F for all n.

**Historical Python status**: neither resampling on the same topology nor the
old invariant matcher proves the Lean copy/path-equivalence statement.

### 8. Transaction/Block Validation Boundary (`lean/Chain.lean`)

**Lean**: `TransactionWellFormed`, `TransactionAccepted`,
`BlockCochainPayloadsCompatible`, `BlockAccepted`, and `LedgerState` specify the
abstract consensus-state facts used by cochain-root aggregation,
no-double-spend, and block-acceptance reasoning. `BlockCochainPayloadsCompatible`
bundles the current Lean-side requirements that every block cochain payload is
well-formed and that all payloads share one topology hash and one edge-vector
length. This is a legacy batch-compatibility boundary, not yet the stronger
requirement that every artifact bind the same canonical `SheafStateSnapshot`
root. The preservation lemmas `acceptedTransaction_key_image_fresh`,
`blockAccepted_cochainPayloadsCompatible`,
`blockAccepted_tx_not_previously_spent`, `applyTransaction_marks_key_image`, and
`applyBlock_marks_tx_key_image` make the cochain-batch and key-image boundaries
explicit.

**Rust**:
- `rust/node/src/types.rs` — runtime transaction/block structures and cochain
  root computation
- `rust/node/src/consensus/pov.rs` — production block verification path
- `rust/node/src/storage/keyimages.rs` — key-image persistence boundary
- `rust/node/src/storage/state.rs` — block application and state transition

Lean does not own byte parsing, canonical encodings, allocation bounds, storage,
or endpoint behavior. Those remain Rust runtime concerns; see
`docs/TRUST_BOUNDARIES.md`.

## Target Encryption/Decryption Shape

The diagram below is the intended degree-one target, not the behavior of the
current Python v3 files. Those files build \(\Delta_0\), split vertex blocks,
and encode bits in a recomputed floating eigenbasis. They therefore do not
match this Lean path and are suspended pending redesign.

```
ENCRYPT (v3 — Hodge path):
  1. Build degree-one Δ₁ from adjacent coboundaries        [degreeOneLaplacian]
  2. Find ker(Δ₁) via eigendecomposition                    [MatrixIsHarmonic / IsHarmonic]
  3. Encode message as coefficients in harmonic basis       [embed_in_harmonic]
  4. Embedding is a harmonic degree-one cochain in ker(Δ₁) [Hodge_Decomposition_Theorem]
     (Only degree-zero elements of ker(δ₀)=ker(Δ₀) are global sections.)
  5. Add noise in im(δ₀)⊕im(δ₁*)                          [Hodge_Decomposition_Theorem]
  6. ciphertext = harmonic_message + orthogonal_noise

DECRYPT (v3 — Hodge path):
  7. Assemble full cochain from vertex blocks
  8. Project onto ker(Δ₁) via π_H                           [Hodge_Projection_Is_CVP / harmonicProjection_Is_ProjectionHodgeCVPSolution]
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

## Historical Python Version Names

- **v1** (deprecated): Discrete Gaussian noise — no formal backing in Lean proof
- **v2**: Lattice path (fallback when dim(ker(Δ)) < message bits)
- **v3**: Claimed Hodge path; the G0/C0 audit found it degree-zero and not
  aligned with the current Lean degree-one workspace

## Key Implementation Notes

### Relative Thresholds for ker(Δ) Detection

Sheaf eigenvalues can be ~10¹² (due to lattice-scale restriction maps with entries ~10⁴).
Absolute thresholds like `1e-10` fail catastrophically. All kernel detection now uses:

```python
max_eig = np.max(np.abs(eigenvalues))
effective_threshold = max(max_eig * 1e-10, zero_threshold)
```

This matches the Lean proof's abstract `MatrixIsHarmonic Δ h := Δ·h = 0`; in the
projection model this is linked to `HomotopicalEncryption.Laplacian.IsHarmonic W h`. The runtime
threshold is only accounting for floating-point arithmetic on large-scale
matrices.

Files with relative threshold:
- `src/crypto/encrypt.py` (encrypt kernel detection)
- `src/crypto/decrypt.py` (decrypt kernel detection)
- Archived `docs/archive/python/src/invariants/harmonic.py` (`project_to_harmonic`, `embed_in_harmonic`, `extract_from_harmonic`, `validate_harmonic_embedding`); no current Python refinement is claimed
