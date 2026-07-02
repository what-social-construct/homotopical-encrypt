# Proximity Paper Outline

This is a working outline for the hcrypt proximity proof path. It is meant to
guide the Lean implementation and eventual writeup, not to claim that the
Proximity Prize target is already solved.

The current paper should be framed as a formal projection architecture with a
canonical Reed-Solomon endpoint and an explicit theorem-slot inventory. The
stronger version becomes a full proximity-result paper only after the final
far-separation theorem and external RS bounds are discharged.

## Working Title

Candidate titles:

- Quotient-Aware Projection Chains from Hodge Proximity to Reed-Solomon Words
- A Formal Plucker-Cochain-Reed-Solomon Projection for Homotopical Encryption
- Traceable Proximity Projections for Sheaf/Hodge Cryptographic State

## One-Paragraph Abstract Draft

We formalize a quotient-aware projection chain from the hcrypt sheaf/Hodge
proximity problem to a finite Reed-Solomon received-word target. The construction
passes through Plucker shadows, committed cochains with local syndrome tests, a
field-agnostic two-coordinate plane shadow, and an explicit finite-field
encoding boundary. The projection is intentionally lossy along private
representative directions; the verifier-facing claim is instead a calibrated
far-region separation theorem after the RS metric and radius regime are fixed.
The Lean development verifies stage-local invariants, the canonical RS parameter
regime over `ZMod 12289`, the metric/radius normalization surface, and a
certificate structure for hard gates and traceable runtime evidence. Remaining
theorem slots are named explicitly, including concrete Plucker/cochain
instantiation facts and the final Johnson-radius RS far-separation statement.

## Claims And Nonclaims

This paper can claim:

- A formal projection-chain interface from hcrypt proximity data to an RS target.
- A quotient-aware invariant discipline: private representative collapse is
  allowed, but public proximity collapse is isolated as the final theorem.
- A canonical RS endpoint with fixed parameter regime, smooth power domain,
  absolute Hamming metric, and radius normalization.
- A certificate architecture separating hard gates, quantitative far-separation
  gates, and runtime trace evidence.
- A precise inventory of the remaining mathematical and runtime obligations.

This paper should not claim yet:

- A completed Proximity Prize solution.
- That hashes or SNARKs are the mathematical source of the proximity theorem.
- That the cochain commitment modulus chooses the semantic Lean field.
- That all source data is preserved by projection.
- That Rust/runtime byte-level behavior is verified by Lean.

## Main Pipeline

```text
hidden Hodge / harmonic subspace
  -> Plucker frame witness
  -> committed cochain / local syndrome
  -> PlaneShadow R i
  -> finite-field received word over F
  -> canonical RS proximity target
```

The midpoint `PlaneShadow R i := i -> Fin 2 -> R` is semantic and
field-agnostic. The RS field appears only at the encoding boundary.

## Section Outline

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
- Cochains, local syndrome tests, and global-section candidates.
- Reed-Solomon received words, Hamming distance, Johnson radius, and
  list-decoding/correlated-agreement slots.
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

/What to state:

- Plucker data maps into the existing committed cochain/local-test surface.
- The Plucker shadow may be hash-bound as a public artifact, but the hash is
  only a storage/proof-transcript handle.
- The committed cochain carrier is the actual chain payload,
  `Axioms.CochainCommitmentData`, via `CochainBridge.CommittedCochain`.
- The storage-native path is relational: an observed proof-carrying chain
  commitment realizes the hash-bound Plucker shadow.
- `PayloadEncoder` is the concrete Plucker-shadow-to-chain-commitment boundary.
- Global-section candidates imply accepted local syndrome.
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

### 8. Metric And Radius Calibration

Lean surfaces:

- `Proximity.CanonicalRS.Metric`
- `Proximity.ProjectionChain.RadiusCalibration`
- `Proximity.CanonicalRS.BridgeData`

What to state:

- The canonical RS metric is absolute Hamming distance to the code.
- Radius normalization is explicit and proved for the canonical metric.
- Near compatibility is calibration data.
- Far separation is the remaining theorem, not a stage-local invariant.

Important distinction:

```text
Stage gates check well-formedness and local fidelity.
The final proximity gap is checked only after composing the projection chain and
fixing the RS metric/radius regime.
```

### 9. Hard Gates, Far Gates, And Certificates

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

### 10. Traceability And Runtime Boundary

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

### 11. Main Theorem Shape

Prose theorem:

```text
Given a well-formed hcrypt proximity instance, a valid Plucker/cochain/plane/RS
projection chain, hard-gate evidence, radius calibration, and the canonical
Johnson RS far-separation theorem, the composed projection is a calibrated
end-to-end gap projection from the hcrypt source problem to the canonical
Reed-Solomon received-word target.
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
  -> CanonicalRS.BridgeData.RSMetricCertificate
  -> RS.Target.CalibratedHcryptToRSBridge
```

### 12. Relationship To The Proximity Prize

Careful wording:

- The canonical endpoint is RS-specific and prize-relevant.
- The current contribution is a formal projection path into that endpoint.
- A prize-level claim requires completing the final far-separation theorem and
  importing or proving the needed RS/list-decoding bounds.
- The architecture is designed so the final comparison is a precise theorem
  slot, not an informal analogy.

## Minimum Viable Paper Version

For an early repo/preprint draft, include:

- The projection-chain definitions and diagrams.
- The canonical RS parameter regime.
- The hard-gate and far-gate split.
- The assumption inventory.
- The exact final theorem statement as a theorem slot.
- A Lean status table with build commands.

Do not include:

- Broad claims about solving the prize problem.
- Runtime performance claims before Rust verifier integration.
- SNARK claims beyond the TCB/verifier boundary.

## Lean Burn-Down Before Stronger Draft

1. Complete the concrete Plucker exterior algebra facts:
   nonzero exterior product from independence and same-point projective
   equivalence.
2. Instantiate the concrete cochain/local-syndrome target from the existing
   cochain machinery.
3. Prove the Plucker-to-cochain distance-control statement.
4. Prove the concrete plane extraction alignment and distance-control facts.
5. Refine naturality obligations from coarse `ProjectionStageGateCertificate` fields into
   stage-specific commuting-square statements.
6. Supply or cite the canonical RS list-decoding and MCA bounds.
7. Prove `JohnsonRSFarSeparation`.
8. Convert the completed certificate into the final calibrated bridge theorem.

## Build Status To Report

Current targeted builds that have passed during this phase:

```text
lake build Proximity.RS Proximity.RS.Target Proximity.CochainReedSolomon Proximity.CanonicalRS Proximity
lake build Proximity.GrassmannianPlucker.Concrete Proximity
lake build Proximity.Gates Proximity.CanonicalRS.BridgeData Proximity
lake build Proximity.GateEvidence Proximity
```

Run a final `lake build` before treating the outline as synchronized with the
whole Lean workspace.
