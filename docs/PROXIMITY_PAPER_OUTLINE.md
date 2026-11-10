# Proximity Section Design Outline

This is a preserved projection-design and implementation checklist. Its older
chapter numbering describes the former broad Paper 1 draft; it is not the
current manuscript outline. The [ownership table](../SEMANTIC-PARITY.md#manuscript-ownership-and-dependency-table)
is authoritative for the current three-paper split.

Paper 1 now keeps HCP/Hodge/CVP foundations, observation limits and full
projective recovery. Paper 2 owns the concrete cochain/commitment, codec,
stage/evidence and storage profile. Paper 3 owns coding, radii and quantitative
projection comparisons. Their current sources are `papers/paper1/main.tex`,
`papers/paper2/DRAFT.md` and `papers/proximity-prize/main.tex`.

## Former Section 6 Material: Current Disposition

| Former material | Current manuscript owner |
|---|---|
| Source observation and full Plucker subspace/projector recovery | Paper 1 §5; full-point recovery in §5.5 |
| Cochain realization, payload, local syndrome and extraction/codec | Paper 2 §§2--3 |
| Protocol stage certificates, gates, evidence and persistence | Paper 2 §6 |
| Generic calibrated metric comparisons and near/far directions | Paper 3 §7; explicit contracts consumed by Paper 2 |
| Finite words, RS/list/MCA, canonical numerical constraints and radii | Paper 3 §§2--7 |

The older design details below remain useful for tracing implementation
obligations. They do not enlarge any manuscript's selected proved claims or
reassign the protocol/coding material to Paper 1.

## Provenance And Scope

This outline separates three kinds of Lean content:

- **Original hcrypt formalization:** projection-chain orchestration, Plucker to
  cochain to plane to RS bridge interfaces, gates, certificates, and final
  calibrated bridge plumbing.
- **Formalized external-paper vocabulary:** list decoding, correlated
  agreement, mutual correlated agreement, and paper-style Reed-Solomon endpoint
  definitions from the Proximity Prize survey/paper, especially Definition 4.3
  of *Open Problems in List Decoding and Correlated Agreement*.
- **Trusted literature imports:** cited Johnson/list-decoding and BCHKS MCA
  bounds are isolated in `Proximity.CanonicalRS.CitedBounds` as named theorem
  constants with citation docstrings. This is a trusted boundary, not an
  internal reproof of those coding-theory papers.

Related repo provenance:

- `Axioms/HelferFOL.lean` is a Helfer-style first-order homotopical-logic
  interface/formalization layer, not a new claim about that paper.
- `CVP.lean` is an explicit closest-vector-problem formalization and hardness
  assumption schema, not an internal proof of CVP hardness.
- `Proximity/RS/*` formalizes paper-facing coding-theory vocabulary.
- `Proximity/CanonicalRS/CitedBounds.lean` imports external RS bounds through a
  single cited assumption boundary.

## Historical Section 6 Title Ideas

Candidate titles:

- Quotient-Aware Projection Chains from Hodge Proximity to Reed-Solomon Words
- A Formal Plucker-Cochain-Reed-Solomon Projection for Homotopical Encryption
- Traceable Proximity Projections for Sheaf/Hodge Cryptographic State
- Certified Projection Chains to a Paper-Style Reed-Solomon MCA Endpoint

## Reusable Section 6 Summary Draft

We formalize a quotient-aware projection chain from the hcrypt sheaf/Hodge
proximity problem to a finite Reed-Solomon received-word target. The construction
passes through Plucker shadows, committed cochains with local syndrome tests, a
field-agnostic two-coordinate plane shadow, and an explicit finite-field
encoding boundary. The paper-facing coding endpoint supports words in
`(F^s)^n`; the canonical hcrypt endpoint evaluates this at `s = 1` and proves
the scalar RS bad-challenge set agrees with the width-one paper MCA endpoint.
The projection is intentionally lossy along private representative directions;
the verifier-facing claim is instead a calibrated far-region separation theorem
after the RS metric and radius regime are fixed. The Lean development verifies
stage-local invariants, canonical RS parameters over `ZMod 12289`, fractional
MCA/list-decoding surfaces, metric/radius normalization, and a certificate
structure for hard gates and traceable runtime evidence. External
Johnson/list-decoding and BCHKS MCA bounds are isolated in a cited trusted
boundary. The remaining project-specific obligation is a concrete
source-to-RS far-separation witness. In the current ownership split, Paper 3
states quantitative comparisons for its declared source profiles, while
Paper 2 retains the construction and gate/evidence contracts. An additional
source model still needs its own far-separation theorem.

## Claims And Nonclaims

Section 6 can claim:

- A formal projection-chain interface from hcrypt proximity data to an RS target.
- A quotient-aware invariant discipline: private representative collapse is
  allowed, but public proximity collapse is isolated as the final theorem
  obligation.
- A canonical RS endpoint with fixed parameter regime, smooth power domain,
  relative/paper-facing Hamming notation, an absolute metric implementation,
  and radius normalization.
- A paper-style Reed-Solomon endpoint `C ⊆ (F^s)^n`, with the canonical
  projection evaluated at the verified `s = 1` slice.
- A formal MCA endpoint matching Definition 4.3: bad challenges are measured by
  fractional challenge density and agreement on a shared coordinate set `S`.
- A cited-bound boundary for Johnson/list-decoding and BCHKS MCA inputs.
- A certificate architecture separating hard gates, quantitative far-separation
  gates, and runtime trace evidence.
- A precise inventory of the remaining mathematical and runtime obligations.

Section 6 should not claim yet:

- A completed Proximity Prize solution.
- A new proof of Johnson, BCHKS, GG, or other cited coding-theory theorems.
- That hashes or SNARKs are the mathematical source of the proximity theorem.
- That the cochain commitment modulus chooses the semantic Lean field.
- That all source data is preserved by projection.
- That Rust/runtime byte-level behavior is verified by Lean.

## Main Pipeline

```text
hidden Hodge / harmonic subspace
  -> Plucker frame witness
  -> accepted committed cocycle / local syndrome
  -> PlaneShadow R i
  -> finite-field received word over F
  -> canonical RS proximity target
```

The midpoint `PlaneShadow R i := i -> Fin 2 -> R` is semantic and
field-agnostic. The RS field appears only at the encoding boundary.

## Fine-Grained Design Decomposition

### 1. Introduction

Purpose:

- Explain why proximity matters for hcrypt: verifier-facing state, routing,
  latency, load, and proof-carrying execution.
- State the analogy to known proximity/list-decoding problems carefully.
- Emphasize that the work builds a precise reduction-style target rather than
  claiming an immediate prize solution.

Core message:

```text
The chain can forget private representatives, but must not make source-far
public observables look RS-near after calibration.
```

### 2. Background

Include only the background needed for the theorem statement:

- Sheaf/Hodge state and harmonic public observables.
- Grassmannian witnesses and Plucker coordinates.
- Projective quotienting and why some pairs are supposed to collapse.
- Cochains, local syndrome tests, and sheaf-relative accepted committed
  cocycles.
- Reed-Solomon received words, Hamming distance, Johnson radius, and
  list-decoding/correlated-agreement/MCA slots.
- Paper Definition 4.3: F-additive codes `C ⊆ (F^s)^n`, affine lines
  `f₁ + γ · f₂`, shared agreement sets `S`, and the bad-challenge fraction
  `εmca(C, δ)`.
- Proof-carrying runtime evidence, hashes, and SNARK/verifier boundaries.

### 3. Source Proximity Problem

Lean surfaces:

- `Proximity.Projection.SheafProximityInstance`
- `Proximity.Problem.GapProximityProblem`
- `Proximity.GrassmannianPlucker.FrameWitness`
- `Proximity.Gates.SourceMetricGate`

What to state:

- The source object is a sheaf/Hodge or harmonic-subspace proximity instance.
- `pluckerDisagreement` is the source-facing score used by the projection chain.
- `SourceMetricGate` requires nonnegativity and public-quotient invariance.
- This is a hard gate, but it is not the final metric theorem.

### 4. Plucker Shadow And Projective Quotient

Lean surfaces:

- `Proximity.GrassmannianPlucker`
- `Proximity.GrassmannianPlucker.Concrete`
- `Proximity.PluckerCochain`

What to state:

- A `FrameWitness` presents a harmonic subspace.
- The exterior product gives the Plucker coordinate.
- The concrete projective shadow quotients by nonzero scalar/unit rescaling.
- Decomposability is already tied to the exterior-product construction.
- Remaining algebraic facts are exactly the nonzero exterior product and
  same-point projective equivalence obligations.

Important invariant:

```text
The Plucker public shadow is the quotient object; downstream projection maps
respect equality of public-shadow representatives.
```

### 5. Cochain And Local Syndrome Layer

Lean surfaces:

- `Proximity.PluckerCochain.LocalSyndromeTarget`
- `Proximity.PluckerCochain.Projection`
- `Proximity.PluckerCochain.PublicBinding.HashedPluckerShadow`
- `Proximity.PluckerCochain.PublicBinding.PayloadRealization`
- `Proximity.PluckerCochain.PublicBinding.ObservedFrameBinding`
- `Proximity.PluckerCochain.Concrete.PayloadEncoder`
- `Proximity.PluckerCochain.Concrete.ProjectionInputs`
- `Proximity.Gates.SyndromeAdequacyGate`

What to state:

- Plucker data maps into the existing committed cochain/local-test surface.
- The Plucker shadow may be hash-bound as a public artifact, but the hash is
  only a storage/proof-transcript handle.
- The committed cochain carrier is the actual chain payload,
  `Axioms.CochainCommitmentData`, via `CochainBridge.CommittedCochain`.
- The storage-native path is relational: an observed proof-carrying chain
  commitment realizes the hash-bound Plucker shadow.
- `PayloadEncoder` is the concrete Plucker-shadow-to-chain-commitment boundary.
- Sheaf-relative accepted committed cocycles imply accepted local syndrome.
- The verifier may use zero/well-formed syndrome as evidence only through an
  explicit `SyndromeAdequacyGate`.
- This keeps storage/runtime commitments separate from semantic proof objects.

### 6. Plane Shadow Layer

Lean surfaces:

- `Proximity.CochainPlane.PlaneShadow`
- `Proximity.CochainPlane.PlaneExtractionContext`
- `Proximity.CochainPlane.Projection`

What to state:

- The plane shadow is a two-coordinate semantic evaluation layer.
- Extraction selects two edge coordinates per evaluation point under an aligned
  context.
- Alignment requires well-formed payload shape, expected edge count, and
  in-bounds selected indices.
- No field or `ZMod` assumption belongs here.

### 7. RS Encoding Boundary

Lean surfaces:

- `Proximity.CochainReedSolomon.PlaneEncoding`
- `Proximity.CochainReedSolomon.Interpretation`
- `Proximity.CanonicalRS.Parameters`
- `Proximity.CanonicalRS.PowerDomain`
- `Proximity.CanonicalRS.Encoding`

What to state:

- The only semantic-to-finite-field boundary is `encodePoint`.
- The canonical target uses `ZMod 12289`, length `4096`, degree bound `1024`,
  and Johnson-below radius `2047`.
- The power domain is algebraic/certified, not a brute-force extraction path.
- The received word is derived from the plane shadow, not directly from
  cochain `edge_values`.

### 8. Paper-Style RS And MCA Endpoint

Lean surfaces:

- `Proximity.RS.ListDecoding`
- `Proximity.RS.CorrelatedAgreement`
- `Proximity.RS.ReedSolomon`
- `Proximity.CanonicalRS.MCA.Line`
- `Proximity.CanonicalRS.MCA`
- `Proximity.CanonicalRS.MCA.Concrete`
- `Proximity.CanonicalRS.CitedBounds`

What to state:

- The generic `BlockCode ι α` layer keeps the alphabet abstract.
- Reed-Solomon parameters remain scalar as the source of truth:
  `P.Codeword : Word ι F -> Prop`.
- The paper alphabet is derived, not duplicated:
  `P.vectorBlockCode σ : BlockCode ι (σ -> F)`, representing `C ⊆ (F^s)^n`.
- The canonical endpoint evaluates the paper alphabet at `σ := Fin 1`.
- `widthOneCodeword_iff`, `widthOneCloseOnSet_iff`, and
  `widthOneInterleavedCloseOnSet_iff` show that the scalar endpoint and the
  width-one paper endpoint agree.
- `widthOneBadChallengeSet_eq` proves equality of the actual Definition 4.3
  MCA bad-challenge set at the endpoint.
- `paperMCAStatement_iff_widthOneTarget` proves theorem-level equivalence
  between the scalar canonical MCA statement and the vector-paper `s = 1`
  statement.
- `CitedBounds.bounds` packages the cited Johnson/list-decoding and BCHKS MCA
  inputs for the canonical below-Johnson setting.

Important invariant:

```text
Scalar RS remains the implementation endpoint.
The paper endpoint is `(F^s)^n`.
The canonical bridge evaluates the paper endpoint at `s = 1`, with a proved
bad-challenge-set equivalence.
```

### 9. Metric And Radius Calibration

Lean surfaces:

- `Proximity.CanonicalRS.Metric`
- `Proximity.ProjectionChain.RadiusCalibration`
- `Proximity.CanonicalRS.BridgeData`

What to state:

- The canonical RS metric is absolute Hamming distance to the code.
- The paper-facing list-decoding/MCA surface is fractional/relative Hamming
  notation.
- Radius normalization connects the finite count radius `2047` to the real
  radius `2047 / 4096`.
- Near compatibility is calibration data.
- Concrete far separation is a supplied theorem/witness obligation, not a
  stage-local invariant.

Important distinction:

```text
Stage gates check well-formedness and local fidelity.
The final proximity gap is checked only after composing the projection chain and
fixing the RS metric/radius regime.
```

### 10. Hard Gates, Far Gates, And Certificates

Lean surfaces:

- `Proximity.Gates`
- `Proximity.ProjectionChain`
- `Proximity.CanonicalRS.FarSeparation`

Hard gates:

- `SourceMetricGate`
- `PluckerMetricGate`
- `PublicShadowRespectGate`
- `SemanticAlignmentGate`
- `SyndromeAdequacyGate`

Quantitative far gates:

- `PluckerToCochainNonCollapseGate`
- `CochainToRSFarGate`
- `FarGatePipeline`

Final certificate path:

```text
ProjectionStageGateCertificate
  -> HardGateCertificate
  -> RSMetricCertificate
  -> CalibratedFinalGateCertificate
  -> CalibratedHcryptToRSBridge
```

### 11. Traceability And Runtime Boundary

Lean surfaces:

- `Proximity.GateEvidence`
- `TCB.ProofCarrying`
- `TCB.RuntimeBoundary`

What to state:

- Lean owns the mathematical certificate types.
- Rust/runtime owns canonical bytes, hashes, inclusion proofs, proof verifier
  calls, and resource bounds.
- `EvidenceSlot` gives a fixed positional schema for traceable hard-gate
  evidence plus the final far-region witness.
- `HardGateSlot` names the hard-gate prefix of that schema.
- `EvidenceDatabase` is verified-database-shaped evidence, but not the source
  of mathematical truth.

### 12. Main Theorem Shape

Prose theorem:

```text
Given a well-formed hcrypt proximity instance, a valid Plucker/cochain/plane/RS
projection chain, hard-gate evidence, cited canonical RS/list-decoding/MCA
bounds, radius calibration, and the canonical source-to-RS far-separation
theorem, the composed projection is a calibrated end-to-end gap projection from
the hcrypt source problem to the canonical Reed-Solomon received-word target.
```

Lean theorem dependency sketch:

```text
ProjectiveSoundInputs
  -> projectiveFramedSystem.Sound
  -> PluckerCochain.Projection
  -> CochainPlane.Projection
  -> CochainReedSolomon.Interpretation
  -> Gates.Projection.ProjectionStageGateCertificate
  -> Gates.Projection.HardGateCertificate
  -> CanonicalRS.CitedBounds.bounds
  -> CanonicalRS.BridgeData.RSMetricCertificate
  -> RS.Target.CalibratedHcryptToRSBridge
```

### 13. Relationship To The Proximity Prize

Careful wording:

- The canonical endpoint is RS-specific and prize-relevant.
- The formalized endpoint uses the paper alphabet `C ⊆ (F^s)^n`; the concrete
  hcrypt instance is the verified `s = 1` ordinary RS slice.
- The current contribution is a formal projection path into that endpoint plus
  a verified paper-MCA comparison layer.
- A prize-level claim requires completing the final source-to-RS far-separation
  theorem and choosing the prize parameter regime. The conservative canonical
  endpoint is below Johnson; the grand challenge is about sharper behavior
  near/beyond Johnson/capacity.
- The architecture is designed so the final comparison is a precise theorem
  slot, not an informal analogy.

## Historical Minimum Viable Section Version

The current Section 6 now exceeds this early repo/preprint checklist, which
remains useful when deciding what must survive any future compression:

- The projection-chain definitions and diagrams.
- The canonical RS parameter regime.
- The paper-style RS/MCA endpoint and the `s = 1` equivalence.
- The cited-bound boundary and its provenance labels.
- The hard-gate and far-gate split.
- The assumption inventory.
- The exact final theorem statement as a theorem slot.
- A Lean status table with build commands.

Do not include:

- Broad claims about solving the prize problem.
- Runtime performance claims before Rust verifier integration.
- SNARK claims beyond the TCB/verifier boundary.

## Current Lean Obligation Ledger

1. **Open:** complete the concrete Plucker exterior-algebra facts, including
   nonzero exterior product from independence and same-point projective
   equivalence.
2. **Partially resolved:** the cochain layer now uses the existing commitment
   payload and sheaf-relative exact/cocycle semantics; the concrete
   Plucker-payload encoder and syndrome map remain explicit inputs.
3. **Open:** prove the Plucker-to-cochain distance-control statement.
4. **Partially resolved:** the plane-extraction interface and alignment gates
   are present, but the concrete alignment/distance-control realization remains
   an obligation.
5. **Partially resolved:** stage-typed equations exist; some naturality
   obligations still live in coarse `ProjectionStageGateCertificate` fields
   rather than dedicated commuting-square structures.
6. **Resolved policy:** `CitedBounds` remains a named, documented trusted
   literature boundary for Paper 1.
7. **Open:** supply a concrete `JohnsonRSFarSeparation` witness proving final
   source-to-RS far non-collapse.
8. **Resolved plumbing:** once that witness is supplied, the certificate-to-
   calibrated-bridge path is implemented.
9. **Resolved placement:** provenance for `HelferFOL`, `CVP`,
   `Proximity.RS`, and `CitedBounds` belongs in the Paper--Lean appendices.

## Build Status To Report

The current isolated audit passed:

```text
lake build Axioms TCB Chain Gates Proximity
```

This is an audit record, not a permanent status badge. Rerun the aggregate and
then a full `lake build` against the submission checkpoint.
