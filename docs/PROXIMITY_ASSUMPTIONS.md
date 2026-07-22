# Proximity Assumption Inventory

This inventory records the current assumption surface for the hcrypt proximity
projection stack:

```text
Plucker frame witness
  -> committed cochain / local syndrome
  -> PlaneShadow R i
  -> finite-field RS received word
  -> canonical RS proximity target
```

The goal is not to eliminate every assumption immediately. The goal is to keep
each assumption named, typed, owned, and visible while the proof is burned down.

## Status Legend

| Status | Meaning |
|--------|---------|
| Lean-proved | The fact is already constructed by definitions/theorems in Lean. |
| Explicit input | A concrete instantiation must supply this field/certificate. |
| External theorem slot | A mathematical theorem from RS/code theory or future Lean work must fill this. |
| Runtime/TCB | Rust/proof-verifier/runtime must enforce this; Lean names the contract. |
| Needs refinement | The obligation is formalized, but currently too coarse for the final paper-level statement. |

Current audit facts:

- No `sorry` or `admit` declarations are expected in the proximity surface.
- `Proximity.CanonicalRS.CitedBounds` intentionally contains Lean `axiom`
  declarations for externally cited Johnson/list-decoding and BCHKS MCA theorem
  inputs. These are trusted literature imports, not hidden proof gaps.
- The proximity build passed after the paper-MCA endpoint and cited-bound pass:
  `lake build Proximity.CanonicalRS.CitedBounds`,
  `lake build Proximity.CanonicalRS`, and `lake build Proximity`.
- The first concrete Plucker instantiation now builds:
  `lake build Proximity.GrassmannianPlucker.Concrete Proximity`.
- The remaining assumptions are carried as structure fields, theorem slots, or
  TCB/runtime contracts.

## Already Discharged In Lean

| Area | Lean surface | Status | Notes |
|------|--------------|--------|-------|
| Generic projection near-side preservation | `Proximity/Projection.lean` | Lean-proved | `EvaluationProjection.distanceControlled` gives `projected_near_code_of_disagreement_le`. |
| Gap-reduction plumbing | `Proximity/Problem.lean` | Lean-proved | `GapReduction.pullbackSolverCorrect` and calibrated pullback theorems are proved once near/far fields are supplied. |
| Stage certificate accumulation | `Proximity/Gates/Stage.lean` | Lean-proved | `PluckerCochainGateCertificate`, `CochainPlaneGateCertificate`, `PlaneRSGateCertificate`, and `ProjectionStageGateCertificate` accumulate stage checks without recomputation. |
| Plucker decomposability from frame | `Proximity/GrassmannianPlucker.lean` | Lean-proved | `FrameWitness.toExterior_decomposable` follows from the exterior-product construction. |
| Frame membership/span facts | `Proximity/GrassmannianPlucker.lean` | Lean-proved from witness fields | `frame_mem_hodgeSubmodule` and `span_eq_hodgeSubmodule` expose the witness data. |
| Projective Plucker quotient | `Proximity/GrassmannianPlucker/Concrete.lean` | Lean-proved | `ProjectivelyEquivalent` is a setoid for nonzero scalar/unit rescaling; `ProjectiveShadow` is the quotient. |
| Projective normalization invariance | `Proximity/GrassmannianPlucker/Concrete.lean` | Lean-proved | Projectively equivalent exterior coordinates have the same public projective shadow. |
| Canonical modulus/length/rate arithmetic | `Proximity/CanonicalRS/Parameters.lean` | Lean-proved by computation | Prime field fact, `length = 4096`, `degreeBound = 1024`, rate `1/4`, and Johnson/capacity-below integer inequalities are proved. |
| Certified power domain | `Proximity/CanonicalRS/PowerDomain.lean` | Lean-proved | `candidateGenerator = 11` has order `12288`; cubing gives an order-`4096` root; evaluation points are injective. |
| Canonical smoothness | `Proximity/CanonicalRS/PowerDomain.lean` | Lean-proved | `canonicalSmoothDomain.smooth` follows from `4096 | 12289 - 1`. |
| Canonical integer plane encoding object | `Proximity/CanonicalRS/Encoding.lean` | Constructed | `canonicalMix = candidateRoot`; distance/non-collapse properties are intentionally downstream obligations. |
| Canonical RS distance-to-code metric | `Proximity/CanonicalRS/Metric.lean` | Lean-proved | Defines distance as `sInf` over Hamming distances to RS codewords; proves nonnegativity, zero on codewords, and close-implies-bounded-distance. |
| Absolute radius normalization | `Proximity/CanonicalRS/Metric.lean` | Lean-proved | `absoluteRadiusNormalization` discharges radius conversion for the canonical absolute-Hamming metric. |
| Canonical bridge endpoint facts | `Proximity/CanonicalRS/BridgeData.lean` | Lean-proved | Domain cardinality, smoothness, evaluation-point compatibility, metric normalization, and radius parameter agreement are proved for `BridgeData`. |
| Certificate plumbing to final bridge | `Proximity/CanonicalRS/BridgeData.lean` | Lean-proved | `RSMetricCertificate` converts hard gates plus far separation into a completed calibrated RS bridge. |
| Paper-style RS endpoint | `Proximity/RS/ReedSolomon.lean` | Lean-defined | `vectorBlockCode P σ` represents `C ⊆ (F^s)^n` as an interleaving of scalar RS codewords. |
| Definition 4.3 MCA surface | `Proximity/RS/CorrelatedAgreement.lean` | Lean-defined | Fractional MCA bad-challenge sets use shared agreement sets `S` and challenge fractions. |
| Canonical `s = 1` MCA endpoint | `Proximity/CanonicalRS/MCA/Concrete.lean` | Lean-proved | Width-one scalar/vector equivalences culminate in `widthOneBadChallengeSet_eq` and `paperMCAStatement_iff_widthOneTarget`. |
| Cited RS bounds package | `Proximity/CanonicalRS/CitedBounds.lean` | External theorem boundary packaged in Lean | `CitedBounds.bounds` supplies named/cited Johnson list-decoding and BCHKS MCA inputs for the canonical endpoint. |

## Construction Interfaces Still To Instantiate

These are not necessarily external assumptions; they are typed construction
interfaces. A concrete hcrypt instantiation must provide them.

| Object | Required fields | Owner | Status |
|--------|-----------------|-------|--------|
| `FrameWitness` | frame vectors, membership in harmonic carrier, linear independence, span equality | Geometric witness construction | Explicit input per witness |
| `Concrete.ProjectiveSoundInputs` | nonzero exterior product from independent frame; same Grassmannian point gives projectively equivalent exterior coordinates | Plucker/exterior algebra proof | Explicit input |
| `FramedSystem.Sound` for `projectiveFramedSystem` | Plucker relations, valid normalized shadow, and projective normalization are discharged from `ProjectiveSoundInputs` | Concrete Plucker instantiation | Partly discharged |
| `LocalSyndromeTarget` | syndrome type, zero predicate, `distanceToCode`, global-candidate implies zero syndrome | Concrete cochain/local-test construction | Explicit input |
| `PluckerCochain.PublicBinding.HashedPluckerShadow` | public Plucker shadow, digest, runtime-owned digest binding | Public/storage layer | Lean interface added; hash function/bytes are TCB-owned |
| `PluckerCochain.PublicBinding.PayloadRealization` | relation saying an accepted `CochainCommitmentData` realizes a public Plucker shadow | Public Plucker-to-chain-payload binding | Lean interface added; concrete proof statement still explicit input |
| `PluckerCochain.PublicBinding.ObservedFrameBinding` | observed proof-carrying cochain plus hash-bound Plucker shadow and realization statement | Runtime observation boundary | Lean interface added; observation/proof accepted by TCB |
| `PluckerCochain.Concrete.PayloadEncoder` | public Plucker shadow to `Axioms.CochainCommitmentData`, expected edge count, well-formed payload for valid frames | Plucker-to-chain-payload boundary | Lean interface added; concrete encoder still explicit input |
| `PluckerCochain.Concrete.CommitmentSumSyndromeInputs` | global candidates have zero commitment-sum syndrome for the chain-facing summary test | Concrete cochain/local-test construction | Lean interface added; proof still explicit input |
| `PluckerCochain.Concrete.ProjectionInputs` | payload encoder, sheaf well-formedness, cochain distance controlled by Plucker disagreement | Plucker-to-cochain bridge | Lean constructor added; distance theorem still explicit input |
| `PlaneExtractionContext` | expected edge count, two selected edge indices per evaluation point, coefficient map `Z -> R` | Storage/cochain-to-plane design | Explicit input |
| `PlaneExtractionContext.Aligned` | well-formed payload, expected edge count, selected indices in bounds | Runtime payload plus Lean shape check | Explicit predicate |
| `CochainPlane.Projection` | accepted local codewords align, map to plane target codewords, plane distance controlled by local syndrome distance | Cochain-to-plane bridge | Explicit input |
| `PlaneEncoding` | `encodePoint : (Fin 2 -> R) -> F` | Finite-field encoding boundary | Explicit input |
| `CochainReedSolomon.Interpretation` | a cochain-plane projection into the RS-induced plane target | Plane-to-RS bridge | Explicit input |
| `ReceivedWordMetric` | RS received-word distance and zero distance for exact RS codewords | RS metric choice | Canonical absolute metric discharged; other metrics explicit |
| `RadiusNormalization` | conversion from Hamming radii to real score radii and close-implies-metric bound | RS metric/radius choice | Canonical absolute normalization discharged; other normalizations explicit |

## External RS And Code-Theory Slots

| Slot | Lean surface | Status | Notes |
|------|--------------|--------|-------|
| List-size/list-decoding bound | `CanonicalRS.Bounds.listDecodingBound` | Trusted cited theorem boundary | Supplied by `CanonicalRS.CitedBounds.johnsonListDecodingBound`, citing ePrint 2026/680 Theorem 3.2 / Corollary 3.3. |
| Fractional list-decoding bound | `CanonicalRS.Bounds.listDecodingBoundAt` | Trusted cited theorem boundary | Supplied by `CanonicalRS.CitedBounds.johnsonListDecodingBoundAt` in paper fractional notation. |
| Mutual correlated-agreement bound | `CanonicalRS.Bounds.mutualCorrelatedAgreementBound` | Trusted cited theorem boundary | Supplied by `CanonicalRS.CitedBounds.bchksMutualCorrelatedAgreementBound`, citing ePrint 2026/680 Theorem 4.12 / BCHKS25 Theorem 4.6. |
| Paper Definition 4.3 MCA bound | `CanonicalRS.Bounds.paperMutualCorrelatedAgreementErrorBound` | Trusted cited theorem boundary plus Lean endpoint adapter | The cited theorem is stated over `(F^s)^n`; `bchksWidthOnePaperMutualCorrelatedAgreementErrorBound` enters at `s = 1`, then Lean derives the scalar endpoint bound using `paperMCAStatement_iff_widthOneTarget`. |
| Correlated agreement consequence | `ReedSolomon.Parameters.correlatedAgreement_of_mutualCorrelatedAgreement` | Lean-proved from generic theorem | Not an extra assumption once MCA is supplied. |
| Smooth evaluation domain, generic case | `ReedSolomon.SmoothEvaluationDomain.smooth` | Explicit input | Canonical power-domain case is discharged separately. |
| Canonical Johnson RS far separation | `CanonicalRS.BridgeData.JohnsonRSFarSeparation` | Main theorem slot | Says canonical-source far instances remain far in the canonical RS metric after the full projection chain. |
| Stronger far-separation proof routes | `of_distanceLowerBound`, `of_distanceEquality` | Optional theorem routes | A pointwise lower bound or exact distance equality implies Johnson far separation. |

## Bridge Obligations

`Proximity/RS/Target.lean` names the generic bridge obligations. For the
canonical bridge, `Proximity/CanonicalRS/BridgeData.lean` fills the concrete
endpoint facts and leaves only the projection-chain facts to the ordered
certificate.

| Obligation | Canonical status | Source of evidence |
|------------|------------------|--------------------|
| `DomainCardinalityMatches` | Lean-proved | `BridgeData.domainCardinalityMatches` |
| `SmoothDomainWitness` | Lean-proved | `BridgeData.smoothDomain_smooth` |
| `EvaluationPointCompatible` | Lean-proved | `BridgeData.evaluationPointCompatible` |
| `RestrictionNaturality` | Needs refinement | Currently represented by `Gates.Projection.ProjectionStageGateCertificate Γ` in `BridgeTheoremSlots`. Should eventually be a granular commuting-square statement. |
| `CoboundaryNaturality` | Needs refinement | Also currently represented by `ProjectionStageGateCertificate Γ`; should eventually reference the local syndrome/coboundary square directly. |
| `GlobalSectionsMapToRSCodewords` | Lean-proved from chain projection | `Γ.toEvaluationProjection.preservesGlobalSections` |
| `ProjectionMatchesReceivedWord` | Lean-proved by definitional equality | `rfl` in `RSMetricCertificate.toBridgeCertificate` |
| `MetricNormalization` | Lean-proved | `BridgeData.metricNormalization_absolute` |
| `NearDistanceCompatible` | Lean-proved from calibration | `RadiusCalibration.nearCompatible` |
| `FarNonCollapse` | Explicit theorem slot | Supplied by `RSMetricCertificate.rsFarSeparation` |
| `RadiusParametersMatch` | Lean-proved | `BridgeData.radiusParametersMatch` |

## Gate Obligations

Hard gates and quantitative far gates are deliberately separated.

| Gate | Status | Meaning |
|------|--------|---------|
| `SourceMetricGate` | Explicit input | The source score `pluckerDisagreement` is nonnegative and invariant under the public Plucker quotient. |
| `PluckerMetricGate` | Explicit input | Valid Plucker witnesses land in the chart where projective distance/normalization are meaningful. |
| `PublicShadowRespectGate` | Explicit input | The public Plucker shadow is already the quotient object; the gate records that downstream maps respect public-shadow equality. |
| `SemanticAlignmentGate` | Lean-derived from a well-typed chain | Valid frames produce aligned cochains, extracted planes match, and received words encode the plane shadow. |
| `SyndromeAdequacyGate` | Explicit input | The verifier may treat well-formed zero syndrome as global/sheaf evidence. |
| `HardGateCertificate` | Explicit certificate | Accumulates the stage certificate plus the structural gates. |
| `PluckerToCochainNonCollapseGate` | Explicit theorem slot | Plucker far-ness remains visible at the local cochain/syndrome radius. |
| `CochainToRSFarGate` | Explicit theorem slot | Local cochain far-ness remains far after plane projection, field encoding, and RS metric evaluation. |
| `FarGatePipeline` | Lean-proved composition | The two far gates compose to `FarRegionSeparation`. |
| `RSMetricCertificate` | Explicit final certificate | Extends hard gates with `RadiusCalibration` and final RS far separation. |

Hard-gate traceability is separate from the mathematical gate proof. The Lean
surface is `Proximity/GateEvidence.lean`:

| Trace object | Status | Meaning |
|--------------|--------|---------|
| `EvidenceSlot` | Lean-defined | Fixed positional schema: six hard-gate slots plus the final far-region witness slot. |
| `HardGateSlot` | Lean-defined | The hard-gate prefix: stage certificate, source metric, Plucker metric, public-shadow respect, semantic alignment, syndrome adequacy. |
| `EvidenceDatabase` | Runtime/TCB | Stores slot digests, a root digest, slot binding facts, slot-in-root facts, and root binding facts. |
| `HardGateEvidenceRecord` | Runtime/TCB plus Lean certificate | Combines a `HardGateCertificate` with the verified hard-gate prefix of the evidence database. |
| `CalibratedFinalEvidenceRecord` | Runtime/TCB plus Lean certificate | Adds the final far-region witness and requires the final witness slot to bind and sit under the same evidence root. |

## Runtime And TCB Obligations

These are not Lean mathematical proofs. They are production validation
contracts named by Lean and owned by Rust/proof-verifier/runtime.

| Boundary | Lean surface | Runtime-owned facts |
|----------|--------------|---------------------|
| Cochain payload shape | `Axioms.CochainCommitmentData.WellFormed` | supported modulus, declared edge count equals actual edge vector length, nonempty edge vector |
| Byte parsing and allocation | `TCB.RuntimeBoundary` | canonical encoding, bounded allocation, domain separation |
| Hash/proof public artifact | `TCB.RuntimeBoundary`, `Gates.RuntimeBindingGate` | hash binding verified, proof verification sound |
| Plucker shadow hash binding | `PluckerCochain.PublicBinding.HashedPluckerShadow` | canonical public-shadow bytes, digest binding, transcript/domain separation |
| Proximity evidence database | `Proximity/GateEvidence.lean` | fixed-position evidence digest array, root digest, slot/root binding, inclusion proofs, canonical encoding |
| Oracle/public attestations | `TCB.RuntimeBoundary` | oracle attestation verified |
| Consensus state update | `TCB.RuntimeBoundary` | atomic state transition, no Python consensus authority |
| Commitment security | `Axioms.CochainCommitmentAxioms` | authentication of the exact C¹ bytes and snapshot/topology context, any separately claimed hiding, homomorphic addition/scalar multiplication, and partial-opening soundness; not injectivity of δ₀ or uniqueness of a C⁰ opening |
| Sheaf coherence | `Axioms.SheafCoherenceWellFormed` | restriction shape compatibility, edge/triangle naturality, adjacent coboundary composites vanish, Laplacian from coboundary, orthogonality, finite/simplicial/connected nerve |
| Foundation/Hodge assumptions | `Axioms.FoundationWellFormed` | cochain complex, coboundary linearity, Hodge decomposition/orthogonality, commitment binding/hiding/homomorphism |

## What Is Not An Assumption

- The runtime cochain modulus does not choose the semantic plane field.
- RS received words are not extracted directly from `edge_values`; they pass
  through `PlaneShadow`.
- The projection chain is allowed to lose information along intended quotient
  directions.
- Final far separation is not global injectivity. It only rules out collapse of
  the chosen source-far region into the target-near region.
- SNARKs and hashes can compress or bind witnesses, but they are not the source
  of the mathematical proximity theorem.

## Burn-Down Queue

1. Prove or instantiate `FramedSystem.Sound` for the concrete exterior/Plucker
   system. Current status: `projectiveFramedSystem` constructs the projective
   quotient and discharges decomposability-as-Plucker-image, normalization, and
   quotient invariance from `ProjectiveSoundInputs`. Remaining algebraic facts:
   nonzero exterior product from independence, and same-point frame witnesses
   are projectively equivalent.
2. Instantiate the public Plucker/cochain binding against the storage layer.
   Current status: `HashedPluckerShadow`, `PayloadRealization`, and
   `ObservedFrameBinding` model the storage-native path where an observed
   proof-carrying `CochainCommitmentData` realizes a hash-bound Plucker shadow.
3. Optionally instantiate a deterministic payload encoder against the actual
   chain commitment path. Current status:
   `PluckerCochain.Concrete.PayloadEncoder` targets
   `Axioms.CochainCommitmentData` directly and packages well-formedness/edge
   count obligations for valid Plucker frames.
4. Instantiate the concrete `LocalSyndromeTarget` from the existing cochain
   machinery. Current status: `commitmentSumLocalSyndromeTarget` packages the
   chain-facing commitment-sum residual; the zero-sum proof and the converse
   verifier direction through `SyndromeAdequacyGate` remain construction inputs.
5. Build the concrete `PluckerCochain.Projection` through
   `ProjectionInputs.toProjection` and prove the real `distanceControlled`
   theorem for the selected local syndrome.
6. Build the concrete `PlaneExtractionContext` and prove alignment, target
   codeword mapping, and plane-distance control.
7. Refine `RestrictionNaturality` and `CoboundaryNaturality` from the current
   coarse `ProjectionStageGateCertificate` token into explicit commuting-square statements.
8. Keep `CanonicalRS.CitedBounds` as the named trusted boundary for the first
   preprint, or replace individual cited axioms with imported theorem constants
   if a more granular literature formalization is added.
9. Prove the final far-separation theorem, either directly as
   `JohnsonRSFarSeparation`, by a pointwise projected-distance lower bound, or
   by exact calibrated distance equality.
10. Wire runtime evidence: canonical bytes, domain separation, hash/proof
   verification, and witness/verifier artifacts at the Rust/TCB boundary.

## Honest Current Claim

The assumption surface is formalized and mostly well factored. The canonical
RS parameter, metric, paper-MCA endpoint, and cited-bound package are
substantially discharged or explicitly labeled. The remaining proof work is
concentrated in concrete Plucker/cochain instantiation, source metric discharge,
granular naturality, and the calibrated final far-separation theorem.
