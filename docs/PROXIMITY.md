# Proximity

This is the canonical proximity note for hcrypt. It consolidates the proof
outline, combinatorial-Hodge shadow discussion, and Reed-Solomon target status
into one document.

The current Lean tree has the projection stages and orchestration surface needed
to state the final proximity comparison cleanly. The remaining mathematical work
is the calibrated end-to-end far/non-collapse theorem.

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
| Promised gap problem | `lean/Proximity/Problem.lean` | `GapProximityProblem`, `GapReduction`, `EndToEndGapProjection` |
| Plucker coordinate shadow | `lean/Proximity/PluckerShadow.lean` | `CoordinateSystem`, `InvariantChecklist` |
| Grassmannian/Plucker witness | `lean/Proximity/GrassmannianPlucker.lean` | `FrameWitness`, `ExteriorCoordinate`, `FramedSystem` |
| Plucker to cochain | `lean/Proximity/PluckerCochain.lean` | `LocalSyndromeTarget`, `Projection`, `InvariantChecklist` |
| Cochain to plane | `lean/Proximity/CochainPlane.lean` | `PlaneShadow`, `PlaneExtractionContext`, `Projection`, `InvariantChecklist` |
| Plane to RS | `lean/Proximity/CochainReedSolomon.lean` | `PlaneEncoding`, `Interpretation`, `InvariantChecklist` |
| Projection orchestrator | `lean/Proximity/ProjectionChain.lean` | `Chain`, `StageChecklists`, `EndToEndReady` |
| RS target | `lean/Proximity/ReedSolomonTarget.lean` | `Target`, `ReceivedWordMetric`, `BridgeObligations`, `HcryptToRSBridge` |

The formal split is:

```text
stage-local invariants
  checked in the concrete stage files

projection-chain orchestration
  checked in ProjectionChain.lean

final promised proximity comparison
  expressed by EndToEndGapProjection / HcryptToRSBridge
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

### 2. Plucker to Committed Cochain

The Plucker public shadow is encoded as the committed cochain object already
used by storage and transaction layers.

Lean surface:

```text
PluckerCochain.Projection
PluckerCochain.InvariantChecklist
```

Local invariants:

- valid Plucker frames map to global-section candidates;
- global-section candidates are accepted by the local syndrome test;
- local syndrome distance is bounded by the Plucker-stage disagreement.

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
in the semantic cochain/plane layers.

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

The local invariant packages are collected by:

```text
Chain.StageChecklists
```

The orchestrator does not invent new mathematical invariants. It only composes
checked stage-local objects.

## Final Gap Comparison

The final comparison is expressed by:

```text
ProjectionChain.Chain.EndToEndReady
```

It contains:

- `stageChecklists`: all local invariants have been accounted for;
- `farNonCollapse`: the composed map preserves the far side of the selected
  proximity promise.

From this, Lean constructs:

```text
EndToEndReady.toEndToEndGapProjection
EndToEndReady.toHcryptToRSBridge
```

This is the formal entry point for the paper's final theorem.

The mathematical theorem still to prove is the calibrated far/non-collapse
statement:

```text
farRadius <= pluckerDisagreement W
  ->
farRadius <= D.distanceToRS (Gamma.receivedWord W)
```

The more flexible publication-level version is likely:

```text
sourceFarRadius <= sourceDisagreement W
  ->
targetFarRadius <= targetDistance (Gamma.receivedWord W)
```

The calibrated version is probably the right final statement, because the
projection chain is not expected to be isometric.

## RS Target Obligations

The RS target layer records the remaining parameter and metric work:

- choose the exact RS parameter regime and smooth evaluation domain;
- supply or cite the RS list-decoding bound;
- supply or cite the RS mutual-correlated-agreement bound;
- choose the received-word distance/normalization;
- prove domain cardinality, smooth-domain, and evaluation-point compatibility;
- prove restriction/transport and coboundary/syndrome naturality;
- prove global-section compatibility;
- prove the composed projection matches the RS received-word view;
- prove near-distance compatibility;
- prove far instances do not collapse under the composed projection chain.

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

1. Decide whether the final theorem uses same-radius or calibrated-radius
   far/non-collapse.
2. Fix the RS received-word metric and radius normalization.
3. Instantiate the intended finite field at the plane-to-RS boundary.
4. Strengthen `EndToEndReady` if calibrated radii require separate source and
   target radii.
5. Prove or cite the concrete RS list-decoding/MCA bounds used by the target.
6. Prove the composed far/non-collapse theorem for the selected parameter
   regime.

## Build Check

Current targeted check for the orchestrator:

```text
lake build Proximity.ProjectionChain Proximity
Build completed successfully (7372 jobs).
```
