# Proximity

This is the canonical proximity note for hcrypt. It consolidates the proof
outline, combinatorial-Hodge shadow discussion, and Reed-Solomon target status
into one document.

The current Lean tree has the projection stages and orchestration surface needed
to state the final proximity comparison cleanly. The remaining mathematical work
is the calibrated end-to-end far/non-collapse theorem.

For a careful status table of what is proved, what is an explicit construction
input, and what remains a theorem/runtime slot, see
[`PROXIMITY_ASSUMPTIONS.md`](PROXIMITY_ASSUMPTIONS.md).

For the submission-oriented proof outline that this implementation is being
checked against, see
[`PROXIMITY_PAPER_OUTLINE.md`](PROXIMITY_PAPER_OUTLINE.md).

## Thesis

The hcrypt sheaf/Hodge proximity problem is projected into a finite
Reed-Solomon-style target through a chain of public shadows:

```text
hidden Hodge / harmonic subspace
  -> Plucker frame witness
  -> committed cochain / local syndrome
  -> PlaneShadow R i
  -> finite-field received word
  -> RS proximity target
```

The projection is intentionally lossy. It may quotient private representative
data, frame choices, projective scaling, and storage-normalization details. The
proof goal is not to preserve all source information. The goal is to prove that
the composed map preserves the verifier-facing proximity promise after the
metric and radii are fixed.

The guiding invariant is:

```text
projection may forget private directions,
but final public proximity must remain faithful to the accepted observable.
```

## Nonclaims

This document does not claim that the Proximity Prize problem is solved. The
current formal work establishes the projection architecture and stage-local
invariants. The final far/non-collapse theorem is still the main proof target.

Also:

- Hodge-hardness remains the private recovery assumption.
- Plucker coordinates do not determine the private Laplacian.
- The runtime cochain modulus does not define the semantic field.
- RS proximity is not obtained directly from committed `edge_values`.
- SNARKs or hashes may compress/check artifacts, but they are not the
  mathematical source of the proximity theorem.

## Lean Entry Points

| Role | Lean file | Main objects |
|------|-----------|--------------|
| Generic projection vocabulary | `lean/Proximity/Projection.lean` | `SheafProximityInstance`, `CodeShadow`, `EvaluationProjection` |
| Promised gap problem | `lean/Proximity/Problem.lean` | `GapProximityProblem`, `GapReduction`, `EndToEndGapProjection`, `CalibratedEndToEndGapProjection` |
| Plucker coordinate shadow | `lean/Proximity/PluckerShadow.lean` | `CoordinateSystem`, `InvariantChecklist` |
| Grassmannian/Plucker witness | `lean/Proximity/GrassmannianPlucker.lean` | `FrameWitness`, `ExteriorCoordinate`, `FramedSystem` |
| Plucker to cochain | `lean/Proximity/PluckerCochain.lean` | `LocalSyndromeTarget`, `Projection`, `InvariantChecklist` |
| Concrete Plucker payload bridge | `lean/Proximity/PluckerCochain/Concrete.lean` | `PayloadEncoder`, `CommitmentSumSyndromeInputs`, `commitmentSumLocalSyndromeTarget`, `ProjectionInputs` |
| Public Plucker/cochain binding | `lean/Proximity/PluckerCochain/PublicBinding.lean` | `HashedPluckerShadow`, `PayloadRealization`, `ObservedFrameBinding` |
| Cochain to plane | `lean/Proximity/CochainPlane.lean` | `PlaneShadow`, `PlaneExtractionContext`, `Projection`, `InvariantChecklist` |
| Plane to RS | `lean/Proximity/CochainReedSolomon.lean` | `PlaneEncoding`, `CanonicalField`, `Interpretation`, `InvariantChecklist` |
| Projection-chain aggregate | `lean/Proximity/ProjectionChain.lean` | Re-exports the map orchestration surface |
| Projection core orchestrator | `lean/Proximity/ProjectionChain/Core.lean` | `Chain`, `committedCochain`, `planeShadow`, `receivedWord`, `toEvaluationProjection` |
| Projection stage gates | `lean/Proximity/Gates/Stage.lean` | `StageChecklists`, `PluckerCochainGateCertificate`, `CochainPlaneGateCertificate`, `PlaneRSGateCertificate`, `ProjectionStageGateCertificate`, `ProjectionStageCertificate` |
| Projection final checks | `lean/Proximity/Gates/Final.lean` | `RadiusCalibration`, `FarNonCollapseWitness`, `CalibratedFinalGateCertificate`, `CalibratedFinalCheck`, `CalibratedEndToEndReady` |
| Proximity invariant gates | `lean/Proximity/Gates.lean` | `SourceMetricGate`, `PluckerMetricGate`, `PublicShadowRespectGate`, `SemanticAlignmentGate`, `SyndromeAdequacyGate`, `PluckerToCochainNonCollapseGate`, `CochainToRSFarGate`, `FarGatePipeline`, `StructuralBundle`, `Bundle`, `HardGateCertificate`, `CalibratedFinalCertificate` |
| Proximity gate evidence | `lean/Proximity/GateEvidence.lean` | `EvidenceSlot`, `HardGateSlot`, `EvidenceDatabase`, `HardGateEvidenceRecord`, `CalibratedFinalEvidenceRecord` |
| Public/storage aggregate | `lean/Proximity/Public.lean` | `CochainPlane.PublicBinding.PlaneView`, public bindings, and evidence records |
| Canonical RS parameters | `lean/Proximity/CanonicalRS/Parameters.lean` | `RSField`, `length`, `degreeBound`, `johnsonBelowRadius` |
| Canonical RS power domain | `lean/Proximity/CanonicalRS/PowerDomain.lean` | `FullGenerator`, `PowerRoot`, `PowerRoot.domain`, `candidateGenerator`, `candidateRoot` |
| Canonical RS encoding | `lean/Proximity/CanonicalRS/Encoding.lean` | `canonicalMix`, `integerPlaneEncoding` |
| Canonical RS target | `lean/Proximity/CanonicalRS/Target.lean` | `Bounds`, `target` |
| Canonical RS metric | `lean/Proximity/CanonicalRS/Metric.lean` | `hammingDistanceToCode`, `absoluteHammingMetric`, `absoluteRadiusNormalization` |
| Canonical RS bridge data | `lean/Proximity/CanonicalRS/BridgeData.lean` | `BridgeData`, `BridgeTheoremSlots`, `BridgeCertificate`, `RSMetricCertificate`, `RSMetricCertificate.calibratedFinalGateCertificate`, `RSMetricCertificate.toCalibratedHcryptToRSBridge` |
| Canonical RS far separation | `lean/Proximity/CanonicalRS/FarSeparation.lean` | `JohnsonRSFarSeparation`, `JohnsonRSFarSeparation.toRSMetricCertificate`, `JohnsonRSFarSeparation.finalGate`, `JohnsonRSFarSeparation.toBridge` |
| Canonical RS aggregate | `lean/Proximity/CanonicalRS.lean` | Re-exports the canonical RS modules |
| RS/code aggregate | `lean/Proximity/RS.lean` | Re-exports list-decoding, correlated-agreement, and RS core modules |
| RS target | `lean/Proximity/RS/Target.lean` | `Target`, `ReceivedWordMetric`, `RadiusNormalization`, `BridgeObligations`, `HcryptToRSBridge`, `CalibratedHcryptToRSBridge` |

The formal split is:

```text
stage-local invariants
  checked in the concrete stage files

projection-chain orchestration
  checked in ProjectionChain/Core.lean

projection-chain stage gates
  checked in Gates/Stage.lean

final metric/radius comparison
  checked in Gates/Final.lean

final promised proximity comparison
  expressed by CalibratedEndToEndGapProjection / CalibratedHcryptToRSBridge
```

## Projection Stages

### 1. Grassmannian to Plucker

An explicit frame witness presents the operative harmonic subspace. Its public
Plucker coordinate is the exterior product:

```text
toExterior(W) := exteriorPower.ιMulti R r W.frame
```

Local invariants:

- frame vectors lie in the harmonic subspace;
- the frame spans the same submodule used by the Hodge layer;
- the exterior coordinate is decomposable;
- the coordinate is nonzero;
- the Plucker relations hold;
- normalization and support are admissible;
- changing private frame for the same point does not change the public shadow.

This stage explains which private directions are allowed to collapse: frame
choice and projective representative are not verifier-facing information.

When the Plucker shadow crosses into the public/storage layer, it may be
hash-bound as a public artifact. The hash is a handle for canonical bytes,
proof transcripts, and authenticated storage; it does not replace the
mathematical shadow.

### 2. Plucker to Committed Cochain

The Plucker public shadow is encoded as the committed cochain object already
used by storage and transaction layers. The carrier is not a new proof-only
cochain type: it is
`CochainBridge.CommittedCochain := Axioms.CochainCommitmentData`, the same
payload shape used by chain/runtime commitment logic.

There are two valid readings of this boundary:

- deterministic construction, where a `PayloadEncoder` maps a public Plucker
  shadow to a payload;
- public-layer realization, where an observed proof-carrying chain commitment
  realizes a hash-bound Plucker shadow.

The second reading is the storage-native one: the chain already constructs and
accepts `CochainCommitmentData`, and proximity supplies the proof relation
between the accepted payload and the Plucker public shadow.

Lean surface:

```text
PluckerCochain.Projection
PluckerCochain.InvariantChecklist
PluckerCochain.Concrete.PayloadEncoder
PluckerCochain.Concrete.ProjectionInputs
PluckerCochain.PublicBinding.HashedPluckerShadow
PluckerCochain.PublicBinding.PayloadRealization
PluckerCochain.PublicBinding.ObservedFrameBinding
```

Local invariants:

- valid Plucker frames map to global-section candidates;
- global-section candidates are accepted by the local syndrome test;
- local syndrome distance is bounded by the Plucker-stage disagreement.

The concrete bridge now records the actual payload boundary:

- `PayloadEncoder` maps public Plucker shadows into `CochainCommitmentData`;
- valid frames must encode to well-formed chain commitments with the expected
  edge count;
- the encoder is quotient-respecting because it consumes the public Plucker
  shadow rather than a private frame witness;
- `ProjectionInputs.toProjection` turns the concrete payload encoder into the
  generic `PluckerCochain.Projection`.

This stage does not prove the final gap. It only proves local compatibility with
the cochain/syndrome surface.

### 3. Committed Cochain to Plane Shadow

The cochain is projected into a field-agnostic two-coordinate plane shadow:

```text
PlaneShadow R i := i -> Fin 2 -> R
```

The runtime commitment modulus is not the semantic field. The payload modulus
belongs to wire/runtime validation; the semantic plane layer stays generic in
`R`.

Lean surface:

```text
CochainPlane.PlaneExtractionContext
CochainPlane.Projection
CochainPlane.InvariantChecklist
```

Local invariants:

- accepted local cochains are aligned with the extraction context;
- cochains are well formed;
- expected edge count matches;
- selected two edge coordinates per evaluation point are in bounds;
- accepted local cochains map to plane-target codewords;
- plane-target distance is bounded by local syndrome distance.

This is the main fidelity checkpoint before RS. It states exactly what the
plane projection reads and avoids treating `c.modulus` as semantic ownership.

### 4. Plane Shadow to RS Word

Only after the semantic plane shadow exists do we enter a finite field:

```text
encodePoint : (Fin 2 -> R) -> F
receivedWord i := encodePoint (plane i)
```

Lean surface:

```text
CochainReedSolomon.PlaneEncoding
CochainReedSolomon.Interpretation
CochainReedSolomon.InvariantChecklist
```

Local invariants:

- the RS received word is obtained only by encoding the projected plane shadow;
- accepted local cochains encode to RS codewords;
- RS distance is bounded by local syndrome distance.

Concrete fields such as `ZMod 12289` should be instantiated here, not upstream
in the semantic cochain/plane layers. The current Lean boundary names:

```text
CochainReedSolomon.CanonicalField := ZMod 12289
PlaneEncoding.integerCanonical
```

`integerCanonical mix` folds two integer plane coordinates into one canonical
field symbol. The choice of `mix` is still part of the concrete parameter
regime; the definition is the encoding boundary, not the final non-collapse
theorem.

## Projection-Chain Orchestration

The composed projection is named by:

```text
ProjectionChain.Chain
```

It composes:

```text
PluckerCochain.Projection
  with
CochainReedSolomon.Interpretation
```

and exposes:

```text
Chain.toEvaluationProjection
```

which maps the Plucker-stage source instance directly to the RS code shadow.

The gate certificates are accumulated by:

```text
Chain.PluckerCochainGateCertificate
Chain.CochainPlaneGateCertificate
Chain.PlaneRSGateCertificate
Chain.ProjectionStageGateCertificate
Chain.CalibratedFinalGateCertificate
```

Each gate consumes the certificate from the previous gate and appends only its
own local certificate. The calibrated final gate consumes `ProjectionStageGateCertificate`,
records the selected `RadiusCalibration`, and appends only the
`FarNonCollapseWitness`. `StageChecklists` remains available as an explicit view
of the accumulated pre-final certificate, but downstream bridge code should
consume the gate certificates.

The cross-cutting proximity gates are named separately:

```text
Proximity.Gates.Projection.PluckerMetricGate
Proximity.Gates.Projection.SourceMetricGate
Proximity.Gates.Projection.PublicShadowRespectGate
Proximity.Gates.Projection.SemanticAlignmentGate
Proximity.Gates.Projection.SyndromeAdequacyGate
Proximity.Gates.Projection.PluckerToCochainNonCollapseGate
Proximity.Gates.Projection.CochainToRSFarGate
Proximity.Gates.Projection.FarGatePipeline
Proximity.Gates.Projection.StructuralBundle
Proximity.Gates.Projection.Bundle
Proximity.Gates.Projection.HardGateCertificate
Proximity.GateEvidence.Projection.HardGateEvidenceRecord
```

The gate layer is split by role.

Hard invariant gates:

```text
SourceMetricGate
PluckerMetricGate
PublicShadowRespectGate
SemanticAlignmentGate
SyndromeAdequacyGate
StructuralBundle
HardGateCertificate
```

Metric/proof gates:

```text
PluckerToCochainNonCollapseGate
CochainToRSFarGate
FarGatePipeline
Bundle
```

The quotient gate is placed after the Plucker shadow: it identifies allowed
public-shadow collapse before the cochain/plane/RS projection is interpreted.
The local non-collapse gate is the Plucker-to-cochain fidelity check. The RS
side is metric: `CochainToRSFarGate` and `FarGatePipeline` prove that the
received-word distance reaches the calibrated radius.

## Final Gap Comparison

The final comparison is expressed by the calibrated surface:

```text
Gates.Projection.CalibratedEndToEndReady
```

It contains:

- `gateCertificate`: the accumulated certificate already built gate-by-gate;
- `nearRadiusCompatible`: the source near radius fits inside the target near
  radius after metric normalization;
- `farNonCollapse`: the composed map preserves the far side of the selected
  proximity promise.

When the gate certificate is already carried by a state bus, the final proof
surface is the final gate:

```text
Gates.Projection.RadiusCalibration
Gates.Projection.FarNonCollapseWitness
Gates.Projection.CalibratedFinalGateCertificate
Gates.Projection.CalibratedFinalCheck
```

`RadiusCalibration` owns the source/target radii and gap inequalities.
`FarNonCollapseWitness` is the actual last theorem. The final gate combines
those with the accumulated `ProjectionStageGateCertificate`; `CalibratedFinalCheck` is the
compact view consumed by the reduction surface.

This is quotient-aware. The theorem is not global injectivity and not full
distance preservation: some pairs should collapse along intended quotient/kernel
directions. The final gate only rules out far-region collapse into the target
near region. Lean exposes that reading as:

```text
Gates.Projection.FarRegionSeparation
FarRegionSeparation.collapsed_pair_target_far
```

For the first concrete RS regime, Lean now names the canonical same-radius
Johnson calibration:

```text
CanonicalRS.BridgeData.johnsonRadiusReal
CanonicalRS.BridgeData.johnsonRadiusCalibration
```

This sets source and target near/far radii to the absolute Hamming radius
associated to `johnsonBelowRadius = 2047`. The remaining theorem at that
calibration is:

```text
Gates.Projection.FarNonCollapseWitness
  Gamma beta.johnsonRadiusReal beta.johnsonRadiusReal
```

From this, Lean constructs:

```text
CalibratedEndToEndReady.toCalibratedEndToEndGapProjection
CalibratedEndToEndReady.toCalibratedHcryptToRSBridge
```

The mathematical theorem still to prove is the concrete calibrated
far/non-collapse statement:

```text
sourceFarRadius <= sourceDisagreement W
  ->
targetFarRadius <= targetDistance (Gamma.receivedWord W)
```

The calibrated version is probably the right final statement, because the
projection chain is not expected to be isometric.

## RS Target Obligations

The first concrete parameter regime is now fixed in Lean:

```text
field        := ZMod 12289
length       := 4096
degreeBound  := 1024
rate         := 1/4
listRadius   := 2047
pointRadius  := 2047
lineRadius   := 2047
```

The length is chosen because `4096 | 12289 - 1`, matching the intended
smooth-domain/subgroup shape. The radius `2047` is strictly below the
Johnson-style `1/2` radius for rate `1/4`. The stricter capacity-below radius
`3071` is also named in Lean, but it is not used as the initial proved target.

The smooth evaluation-domain API is now concrete and certificate-driven:

```text
CanonicalRS.FullGenerator.generator : RSField*
CanonicalRS.FullGenerator.order_eq_fullGeneratorOrder : orderOf generator = 12288
CanonicalRS.FullGenerator.toPowerRoot

CanonicalRS.PowerRoot.root : RSField*
CanonicalRS.PowerRoot.order_eq_length : orderOf root = 4096
CanonicalRS.PowerRoot.point i := root^i
CanonicalRS.PowerRoot.domain

CanonicalRS.candidateGeneratorUnit_order :
  orderOf candidateGeneratorUnit = 12288
CanonicalRS.candidateFullGenerator : FullGenerator
CanonicalRS.canonicalPowerRoot : PowerRoot
CanonicalRS.canonicalSmoothDomain : SmoothDomain
```

This means the RS evaluation points are genuine subgroup/power-domain points
for the concrete canonical candidate. The current concrete candidate is
algebraic:

```text
CanonicalRS.candidateGenerator := 11 : ZMod 12289
CanonicalRS.candidateGeneratorUnit : (ZMod 12289)*
CanonicalRS.candidateRoot := candidateGenerator^3
CanonicalRS.canonicalMix := candidateRoot
CanonicalRS.integerPlaneEncoding :=
  PlaneEncoding.integerCanonical canonicalMix
```

The full-generator certificate is algebraic: Lean proves
`orderOf candidateGeneratorUnit = 12288` using
`orderOf_eq_of_pow_and_pow_div_prime`, then `FullGenerator.toPowerRoot` gives
the order-`4096` root by the `orderOf (g^3)` theorem. No exhaustive
point-injectivity check belongs in the library.

The canonical RS metric is now the geometric distance to the RS code: the
infimum of absolute Hamming distances from the received word to RS codewords.
Lean exposes it as:

```text
CanonicalRS.hammingDistanceToCode
CanonicalRS.absoluteHammingMetric
CanonicalRS.absoluteRadiusNormalization
```

The metric proves exact codewords have zero distance and Hamming-close words are
bounded by the corresponding absolute real radius. The real-valued radius
interface is named by:

```text
ReedSolomonTarget.Target.RadiusNormalization
```

It converts natural-number Hamming radii into the real-valued proximity score
used by `GapProximityProblem`, and records that Hamming-close words are close in
the selected received-word metric.

The canonical bridge-data layer now bundles the constructed endpoint:

```text
CanonicalRS.BridgeData
  bounds : Bounds canonicalSmoothDomain

BridgeData.rsTarget
BridgeData.metric
BridgeData.radiusNormalization
BridgeData.planeEncoding
BridgeData.codeShadow
BridgeData.bridgeObligations
BridgeData.johnsonRadiusReal
BridgeData.johnsonRadiusCalibration
BridgeTheoremSlots
BridgeCertificate.complete
RSMetricCertificate
RSMetricCertificate.of_rsFarSeparation
RSMetricCertificate.of_johnsonRSFarSeparation
RSMetricCertificate.toBridgeCertificate
RSMetricCertificate.calibratedFinalGateCertificate
RSMetricCertificate.toCalibratedHcryptToRSBridge
JohnsonRSFarSeparation.of_farSeparation
JohnsonRSFarSeparation.of_distanceLowerBound
JohnsonRSFarSeparation.of_distanceEquality
JohnsonRSFarSeparation.toRSMetricCertificate
JohnsonRSFarSeparation.finalGate
JohnsonRSFarSeparation.toBridge
```

`BridgeData` keeps the external RS bounds explicit, while the domain,
evaluation-point, metric, radius, and encoding choices are fixed. The remaining
projection-chain obligations are named by `BridgeTheoremSlots`, proved by
`BridgeCertificate`, and assembled as an ordered certificate chain:

- hard invariant evidence: `Gates.Projection.HardGateCertificate`;
- quantitative RS proof state: `RSMetricCertificate`.

`RSMetricCertificate` extends the hard-gate certificate. It carries:

- `previous : Gates.Projection.HardGateCertificate`;
- `Gates.Projection.RadiusCalibration` for selected source/target radii
  and gap inequalities;
- `Gates.Projection.FarRegionSeparation` as `rsFarSeparation`, a theorem
  over the canonical RS received-word metric;
- the composed projection facts exposed by `ProjectionChain.Chain`.

`CanonicalRS.FarSeparation` then names the canonical Johnson RS theorem object:

```text
JohnsonRSFarSeparation
```

It can be built directly from the threshold far-separation theorem, or from
stronger distance-lower-bound/equality statements. Together with a
`HardGateCertificate`, it determines the ordered `RSMetricCertificate` consumed
by bridge completion.

Remaining obligations:

- supply or cite the RS list-decoding bound;
- supply or cite the RS mutual-correlated-agreement bound;
- instantiate the production hard-gate certificate;
- prove `JohnsonRSFarSeparation` for that production projection chain.

## Paper Section Outline

1. **Motivation**

   Explain why hcrypt needs a finite public proximity shadow: validators should
   verify local/global coherence without learning the hidden fibration or
   harmonic representative.

2. **Source Geometry**

   Define the hidden Hodge/Grassmannian source: harmonic subspaces, Laplacian
   residuals, Plucker frame witnesses, and public projective shadows.

3. **Projection Philosophy**

   State the central principle:

   ```text
   projections may collapse private representative data,
   but must preserve the verifier-facing proximity predicate
   after final calibration.
   ```

4. **Stage 1: Plucker Shadow**

   Present the exterior-power coordinate and the Plucker invariants.

5. **Stage 2: Cochain/Syndrome Local Test**

   Show how Plucker shadows enter the committed cochain object. State the local
   syndrome acceptance condition and the distance-control lemma.

6. **Stage 3: Plane Shadow**

   Introduce `PlaneShadow R i` as the semantic midpoint. Emphasize that this is
   field-agnostic and not determined by the runtime payload modulus.

7. **Stage 4: RS Encoding Boundary**

   Define the finite-field encoding from plane points to RS received words.
   State the RS target parameters, metric normalization, list-decoding bound,
   and MCA/CA bound as target obligations.

8. **Composition Theorem**

   Prove that the composed chain is an `EvaluationProjection`: exact/accepted
   source objects map to RS codewords and projected RS distance is bounded by
   source disagreement.

9. **Final Proximity Gap**

   State the remaining far/non-collapse theorem. This is the critical theorem
   for any proximity-prize-facing comparison.

10. **Verifier Boundary**

   Explain how the final `HcryptToRSBridge` becomes a verifier-facing artifact:
   Lean owns the mathematical bridge, Rust owns runtime validation and canonical
   encodings, and SNARK/hash commitments can compress proof objects without
   becoming the source of the mathematical claim.

11. **Limitations and Nonclaims**

   State explicitly that the current Lean tree formalizes the projection
   architecture and stage invariants, while the final far/non-collapse theorem
   remains the main proof target.

## Immediate Next Proof Tasks

1. Prove or cite the concrete RS list-decoding/MCA bounds used by the target.
2. Prove the composed far/non-collapse theorem for the selected parameter
   regime.

## Build Check

Current targeted check for the orchestrator:

```text
lake build Proximity.CanonicalRS Proximity
Build completed successfully (7379 jobs).
```
