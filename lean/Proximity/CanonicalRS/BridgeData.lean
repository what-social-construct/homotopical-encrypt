import Proximity.CanonicalRS.Encoding
import Proximity.CanonicalRS.Metric

/-
  Canonical RS bridge data.

  Paper correspondence:
  - Paper 1 Section 6: canonical Reed--Solomon endpoint data.
  - Paper 1 appendix ledger: endpoint theorem-surface row.

  This module packages the concrete canonical RS endpoint for the hcrypt
  proximity bridge. Reed-Solomon list-decoding and MCA bounds remain explicit
  inputs through `Bounds canonicalSmoothDomain`; the projection-chain/far-gap
  obligations remain explicit theorem slots.
-/

namespace Hcrypt
namespace Proximity
namespace CanonicalRS

noncomputable section

/--
Concrete canonical RS endpoint, parameterized by the external RS theorem slots.

The bounds field is the only non-constructed RS input here. Everything else is
fixed by the canonical field/domain/metric/encoding choices.
-/
structure BridgeData where
  bounds : Bounds canonicalSmoothDomain

namespace BridgeData

/-- The canonical smooth RS domain. -/
def smoothDomain (_β : BridgeData) : SmoothDomain :=
  canonicalSmoothDomain

/-- The canonical RS target determined by the supplied RS bounds. -/
def rsTarget (β : BridgeData) :
    ReedSolomonTarget.Target RSField (Fin length) :=
  target canonicalSmoothDomain β.bounds

/-- The canonical relative-Hamming received-word metric. -/
def metric (β : BridgeData) :
    ReedSolomonTarget.Target.ReceivedWordMetric β.rsTarget :=
  relativeHammingMetric canonicalSmoothDomain β.bounds

/-- Relative-Hamming radius normalization for the canonical metric. -/
def radiusNormalization (β : BridgeData) :
    ReedSolomonTarget.Target.RadiusNormalization β.metric :=
  relativeRadiusNormalization canonicalSmoothDomain β.bounds

/-- The canonical integer-plane-to-RS-field encoding. -/
def planeEncoding (_β : BridgeData) :
    CochainReedSolomon.PlaneEncoding ℤ RSField :=
  integerPlaneEncoding

/-- The generic code-shadow view induced by the canonical metric. -/
def codeShadow (β : BridgeData) :
    CodeShadow :=
  β.metric.codeShadow

/-- Canonical real radius for the Johnson-below RS regime. -/
def johnsonRadiusReal (_β : BridgeData) : ℝ :=
  ReedSolomonTarget.Target.RadiusNormalization.relativeHammingRadius
    (ι := Fin length) johnsonBelowRadius

/-- The canonical Johnson radius agrees with the target list radius. -/
theorem johnsonRadiusReal_eq_listRadiusReal (β : BridgeData) :
    β.johnsonRadiusReal = β.radiusNormalization.listRadiusReal := by
  rfl

/-- The canonical Johnson radius agrees with the target point radius. -/
theorem johnsonRadiusReal_eq_pointRadiusReal (β : BridgeData) :
    β.johnsonRadiusReal = β.radiusNormalization.pointRadiusReal := by
  rfl

/-- The canonical Johnson radius agrees with the target line radius. -/
theorem johnsonRadiusReal_eq_lineRadiusReal (β : BridgeData) :
    β.johnsonRadiusReal = β.radiusNormalization.lineRadiusReal := by
  rfl

/-- The canonical RS endpoint carries the fractional list-decoding bound. -/
theorem listDecodingBoundAt (β : BridgeData) :
    β.rsTarget.parameters.ListDecodingBoundAt
      β.johnsonRadiusReal
      β.rsTarget.listSize := by
  simpa [rsTarget, target, johnsonRadiusReal,
    ReedSolomonTarget.Target.RadiusNormalization.relativeHammingRadius]
    using β.bounds.listDecodingBoundAt

/-- The canonical RS endpoint carries the fractional MCA error bound. -/
theorem mutualCorrelatedAgreementErrorBound (β : BridgeData) :
    β.rsTarget.parameters.MutualCorrelatedAgreementErrorBound
      β.johnsonRadiusReal
      β.johnsonRadiusReal
      ((β.rsTarget.threshold : ℝ) / (Fintype.card RSField : ℝ)) := by
  simpa [rsTarget, target, johnsonRadiusReal,
    ReedSolomonTarget.Target.RadiusNormalization.relativeHammingRadius]
    using β.bounds.mutualCorrelatedAgreementErrorBound

/-- The canonical RS endpoint carries the paper Definition 4.3 MCA bound. -/
theorem paperMutualCorrelatedAgreementErrorBound (β : BridgeData) :
    β.rsTarget.parameters.PaperMutualCorrelatedAgreementErrorBound
      β.johnsonRadiusReal
      ((β.rsTarget.threshold : ℝ) / (Fintype.card RSField : ℝ)) := by
  simpa [rsTarget, target, johnsonRadiusReal,
    ReedSolomonTarget.Target.RadiusNormalization.relativeHammingRadius]
    using β.bounds.paperMutualCorrelatedAgreementErrorBound

/-- The canonical domain's smoothness witness. -/
theorem smoothDomain_smooth (β : BridgeData) :
    β.smoothDomain.smooth := by
  change canonicalSmoothDomain.smooth
  unfold canonicalSmoothDomain
  exact PowerRoot.smoothDomain_smooth canonicalPowerRoot

/-- The canonical coordinate type has the selected block length. -/
theorem domainCardinalityMatches (_β : BridgeData) :
    Fintype.card (Fin length) = length := by
  simp

/-- Canonical evaluation points are powers of the certified root. -/
theorem evaluationPointCompatible (β : BridgeData) :
    ∀ i : Fin length,
      β.smoothDomain.domain.point i =
        (canonicalPowerRoot.root ^ (i : ℕ) : RSField) := by
  intro i
  rfl

/-- The metric uses the canonical relative Hamming radius convention. -/
theorem metricNormalization_relative (β : BridgeData) :
    β.radiusNormalization.hammingRadiusToReal =
      ReedSolomonTarget.Target.RadiusNormalization.relativeHammingRadius
        (ι := Fin length) :=
  rfl

/-- The canonical radius parameters are the relative-Hamming target radii. -/
theorem radiusParametersMatch (β : BridgeData) :
    β.radiusNormalization.listRadiusReal =
        ReedSolomonTarget.Target.RadiusNormalization.relativeHammingRadius
          (ι := Fin length)
          β.rsTarget.listRadius ∧
      β.radiusNormalization.pointRadiusReal =
        ReedSolomonTarget.Target.RadiusNormalization.relativeHammingRadius
          (ι := Fin length)
          β.rsTarget.pointRadius ∧
      β.radiusNormalization.lineRadiusReal =
        ReedSolomonTarget.Target.RadiusNormalization.relativeHammingRadius
          (ι := Fin length)
          β.rsTarget.lineRadius := by
  exact ⟨β.radiusNormalization.listRadius_eq,
    β.radiusNormalization.pointRadius_eq,
    β.radiusNormalization.lineRadius_eq⟩

/--
Canonical bridge-obligation record builder.

The domain, evaluation-point, metric, and radius facts are now concrete. The
remaining arguments are the projection-chain naturality and final proximity
facts that must be proved by the composed hcrypt-to-RS bridge.
-/
def bridgeObligations
    (β : BridgeData)
    (RestrictionNaturality
      CoboundaryNaturality
      GlobalSectionsMapToRSCodewords
      ProjectionMatchesReceivedWord
      NearDistanceCompatible
      FarNonCollapse : Prop) :
    ReedSolomonTarget.Target.BridgeObligations β.rsTarget where
  DomainCardinalityMatches :=
    Fintype.card (Fin length) = length
  SmoothDomainWitness :=
    β.smoothDomain.smooth
  EvaluationPointCompatible :=
    ∀ i : Fin length,
      β.smoothDomain.domain.point i =
        (canonicalPowerRoot.root ^ (i : ℕ) : RSField)
  RestrictionNaturality := RestrictionNaturality
  CoboundaryNaturality := CoboundaryNaturality
  GlobalSectionsMapToRSCodewords := GlobalSectionsMapToRSCodewords
  ProjectionMatchesReceivedWord := ProjectionMatchesReceivedWord
  MetricNormalization :=
    β.radiusNormalization.hammingRadiusToReal =
      ReedSolomonTarget.Target.RadiusNormalization.relativeHammingRadius
        (ι := Fin length)
  NearDistanceCompatible := NearDistanceCompatible
  FarNonCollapse := FarNonCollapse
  RadiusParametersMatch :=
    β.radiusNormalization.listRadiusReal =
        ReedSolomonTarget.Target.RadiusNormalization.relativeHammingRadius
          (ι := Fin length)
          β.rsTarget.listRadius ∧
      β.radiusNormalization.pointRadiusReal =
        ReedSolomonTarget.Target.RadiusNormalization.relativeHammingRadius
          (ι := Fin length)
          β.rsTarget.pointRadius ∧
      β.radiusNormalization.lineRadiusReal =
        ReedSolomonTarget.Target.RadiusNormalization.relativeHammingRadius
          (ι := Fin length)
          β.rsTarget.lineRadius

/--
The semantic theorem slots left after the canonical RS endpoint has been fixed.

These are intentionally not proved by `BridgeData`: they belong to the composed
Plucker/cochain/plane/RS projection chain.
-/
structure BridgeTheoremSlots where
  RestrictionNaturality : Prop
  CoboundaryNaturality : Prop
  GlobalSectionsMapToRSCodewords : Prop
  ProjectionMatchesReceivedWord : Prop
  NearDistanceCompatible : Prop
  FarNonCollapse : Prop

namespace BridgeTheoremSlots

/-- Interpret named semantic slots as the generic RS bridge obligations. -/
def toObligations (σ : BridgeTheoremSlots) (β : BridgeData) :
    ReedSolomonTarget.Target.BridgeObligations β.rsTarget :=
  β.bridgeObligations
    σ.RestrictionNaturality
    σ.CoboundaryNaturality
    σ.GlobalSectionsMapToRSCodewords
    σ.ProjectionMatchesReceivedWord
    σ.NearDistanceCompatible
    σ.FarNonCollapse

end BridgeTheoremSlots

/--
Proof certificate for the semantic bridge slots.

Applying this certificate to a concrete `BridgeData` value fills the remaining
`BridgeObligations.Complete` fields; the domain, evaluation, metric, and radius
fields are supplied by the canonical endpoint lemmas above.
-/
structure BridgeCertificate (σ : BridgeTheoremSlots) : Prop where
  restrictionNaturality : σ.RestrictionNaturality
  coboundaryNaturality : σ.CoboundaryNaturality
  globalSectionsMapToRSCodewords : σ.GlobalSectionsMapToRSCodewords
  projectionMatchesReceivedWord : σ.ProjectionMatchesReceivedWord
  nearDistanceCompatible : σ.NearDistanceCompatible
  farNonCollapse : σ.FarNonCollapse

namespace BridgeCertificate

/-- Complete the generic RS bridge obligations using canonical endpoint facts. -/
def complete
    {σ : BridgeTheoremSlots}
    (χ : BridgeCertificate σ)
    (β : BridgeData) :
    (σ.toObligations β).Complete where
  domainCardinalityMatches := β.domainCardinalityMatches
  smoothDomainWitness := β.smoothDomain_smooth
  evaluationPointCompatible := β.evaluationPointCompatible
  restrictionNaturality := χ.restrictionNaturality
  coboundaryNaturality := χ.coboundaryNaturality
  globalSectionsMapToRSCodewords := χ.globalSectionsMapToRSCodewords
  projectionMatchesReceivedWord := χ.projectionMatchesReceivedWord
  metricNormalization := β.metricNormalization_relative
  nearDistanceCompatible := χ.nearDistanceCompatible
  farNonCollapse := χ.farNonCollapse
  radiusParametersMatch := β.radiusParametersMatch

/-- A certificate exposes the completed generic obligation record. -/
theorem obligations_complete
    {σ : BridgeTheoremSlots}
    (χ : BridgeCertificate σ)
    (β : BridgeData) :
    (σ.toObligations β).Complete :=
  χ.complete β

end BridgeCertificate

end BridgeData

end

end CanonicalRS
end Proximity
end Hcrypt
