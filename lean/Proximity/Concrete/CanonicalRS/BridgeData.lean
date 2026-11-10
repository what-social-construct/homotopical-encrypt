module

public import Proximity.Concrete.CanonicalRS.Encoding
public import Proximity.Concrete.CanonicalRS.Metric
public import Proximity.Application.Calibration

@[expose] public section

/-
  Canonical RS bridge data.

  Paper correspondence:
  - Paper 3: canonical endpoint data, normalized metrics and explicit
    coding-bound inputs for the quantitative comparison.
  - Paper 2 reuses this same endpoint when constructing its protocol profile.

  This module packages the concrete canonical RS endpoint for the application
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

/-- The canonical plane encoding evaluated at an arbitrary public challenge. -/
def planeEncodingAt
    (_β : BridgeData)
    (gamma : RSField) :
    CochainReedSolomon.PlaneEncoding ℤ RSField :=
  integerPlaneEncodingAt gamma

/-- The chain's fixed encoding is the canonical-challenge specialization. -/
theorem planeEncoding_eq_planeEncodingAt_canonicalMix (β : BridgeData) :
    β.planeEncoding = β.planeEncodingAt canonicalMix :=
  rfl

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
    ReedSolomonTarget.Target.RadiusNormalization.relativeHammingRadius,
    Hcrypt.Proximity.BlockCode.relativeRadius]
    using β.bounds.listDecodingBoundAt

/-- The canonical RS endpoint carries the fractional MCA error bound. -/
theorem mutualCorrelatedAgreementErrorBound (β : BridgeData) :
    β.rsTarget.parameters.MutualCorrelatedAgreementErrorBound
      β.johnsonRadiusReal
      β.johnsonRadiusReal
      ((β.rsTarget.threshold : ℝ) / (Fintype.card RSField : ℝ)) := by
  simpa [rsTarget, target, johnsonRadiusReal,
    ReedSolomonTarget.Target.RadiusNormalization.relativeHammingRadius,
    Hcrypt.Proximity.BlockCode.relativeRadius]
    using β.bounds.mutualCorrelatedAgreementErrorBound

/-- The canonical RS endpoint carries the cited Definition 4.3 MCA bound. -/
theorem paperMutualCorrelatedAgreementErrorBound (β : BridgeData) :
    β.rsTarget.parameters.PaperMutualCorrelatedAgreementErrorBound
      β.johnsonRadiusReal
      ((β.rsTarget.threshold : ℝ) / (Fintype.card RSField : ℝ)) := by
  simpa [rsTarget, target, johnsonRadiusReal,
    ReedSolomonTarget.Target.RadiusNormalization.relativeHammingRadius,
    Hcrypt.Proximity.BlockCode.relativeRadius]
    using β.bounds.paperMutualCorrelatedAgreementErrorBound

/-!
### Concrete admissible-plane to paper-pair metric bridge

The source alphabet below is the canonical integer region
`A = [0, q)^2`.  Coordinatewise reduction is an equivalence from `A` to the
paper pair alphabet `F^2`.  We transport the interleaved RS code along that
equivalence, but define the two distances independently on their respective
alphabets.  Equality follows from preservation of relative Hamming distance.
-/

namespace PlanePair

/-- Admissible integer-plane words at the canonical block length. -/
abbrev AdmissibleWord :=
  AdmissiblePlaneWord (Fin length)

/-- Field-valued two-coordinate words, definitionally the paper pair alphabet. -/
abbrev PairWord :=
  CochainPlane.PlaneShadow RSField (Fin length)

/-- Encode an admissible integer plane as the full field-valued pair. -/
def encode (p : AdmissibleWord) : PairWord :=
  canonicalPlaneWordEquiv (Fin length) p

/-- Recover canonical integer representatives from a field-valued pair. -/
def decode (p : PairWord) : AdmissibleWord :=
  (canonicalPlaneWordEquiv (Fin length)).symm p

/-- Pair encoding followed by decoding is identity. -/
@[simp]
theorem decode_encode (p : AdmissibleWord) :
    decode (encode p) = p :=
  (canonicalPlaneWordEquiv (Fin length)).left_inv p

/-- Pair decoding followed by encoding is identity. -/
@[simp]
theorem encode_decode (p : PairWord) :
    encode (decode p) = p :=
  (canonicalPlaneWordEquiv (Fin length)).right_inv p

/-- Bundle a raw integer plane together with its explicit canonical-region proof. -/
def bundle
    (p : AdmissiblePlane (Fin length)) :
    AdmissibleWord :=
  fun i => ⟨p.1 i, p.2 i⟩

/-- Encoding a bundled admissible plane is ordinary coordinatewise reduction. -/
@[simp]
theorem encode_bundle
    (p : AdmissiblePlane (Fin length)) :
    encode (bundle p) = reduceIntegerPlane p.1 := by
  rfl

/-- The paper's two-fold interleaving of the canonical scalar RS code. -/
def pairCode (β : BridgeData) :
    BlockCode (Fin length) (Fin 2 → RSField) :=
  β.rsTarget.parameters.toBlockCode.interleaved (Fin 2)

/-- Pull the paper pair code back to the admissible integer-plane alphabet. -/
def admissibleCode (β : BridgeData) :
    BlockCode (Fin length) AdmissiblePoint where
  Codeword p := (pairCode β).Codeword (encode p)

/-- Relative-Hamming distance values from a word to a selected block code. -/
def relativeDistanceSet
    {alpha : Type}
    [DecidableEq alpha]
    (C : BlockCode (Fin length) alpha)
    (w : Word (Fin length) alpha) :
    Set ℝ :=
  {d | ∃ c : Word (Fin length) alpha,
    C.Codeword c ∧ d = BlockCode.relativeHammingDistance c w}

/-- Relative-Hamming distance to a selected block code. -/
def relativeDistanceToCode
    {alpha : Type}
    [DecidableEq alpha]
    (C : BlockCode (Fin length) alpha)
    (w : Word (Fin length) alpha) :
    ℝ :=
  sInf (relativeDistanceSet C w)

/-- Every relative codeword-distance set is bounded below by zero. -/
theorem relativeDistanceSet_bddBelow
    {alpha : Type}
    [DecidableEq alpha]
    (C : BlockCode (Fin length) alpha)
    (w : Word (Fin length) alpha) :
    BddBelow (relativeDistanceSet C w) := by
  refine ⟨0, ?_⟩
  intro d hd
  rcases hd with ⟨c, _hc, rfl⟩
  unfold BlockCode.relativeHammingDistance
  unfold ProximityPrize.BlockCode.relativeHammingDistance
  positivity

/-- Distance to a code is bounded by distance to any concrete codeword. -/
theorem relativeDistanceToCode_le_of_codeword
    {alpha : Type}
    [DecidableEq alpha]
    (C : BlockCode (Fin length) alpha)
    {w c : Word (Fin length) alpha}
    (hc : C.Codeword c) :
    relativeDistanceToCode C w ≤
      BlockCode.relativeHammingDistance c w := by
  unfold relativeDistanceToCode
  exact csInf_le
    (relativeDistanceSet_bddBelow C w)
    ⟨c, hc, rfl⟩

/-- Relative distance to a selected code is nonnegative. -/
theorem relativeDistanceToCode_nonneg
    {alpha : Type}
    [DecidableEq alpha]
    (C : BlockCode (Fin length) alpha)
    (w : Word (Fin length) alpha) :
    0 ≤ relativeDistanceToCode C w := by
  unfold relativeDistanceToCode
  exact Real.sInf_nonneg (by
    intro d hd
    rcases hd with ⟨c, _hc, rfl⟩
    unfold BlockCode.relativeHammingDistance
    unfold ProximityPrize.BlockCode.relativeHammingDistance
    positivity)

/-- A selected codeword has zero relative distance to its code. -/
theorem relativeDistanceToCode_eq_zero_of_codeword
    {alpha : Type}
    [DecidableEq alpha]
    (C : BlockCode (Fin length) alpha)
    {w : Word (Fin length) alpha}
    (hw : C.Codeword w) :
    relativeDistanceToCode C w = 0 := by
  apply le_antisymm
  · calc
      relativeDistanceToCode C w ≤
          BlockCode.relativeHammingDistance w w :=
        relativeDistanceToCode_le_of_codeword C hw
      _ = 0 := by
        unfold BlockCode.relativeHammingDistance
        unfold ProximityPrize.BlockCode.relativeHammingDistance
        unfold ProximityPrize.BlockCode.hammingDistance
        simp
  · exact relativeDistanceToCode_nonneg C w

/-- The paper-pair distance `D_pair`. -/
def pairDistance
    (β : BridgeData)
    (p : PairWord) : ℝ :=
  relativeDistanceToCode (pairCode β) p

/-- The admissible-plane distance `d_A`. -/
def admissibleDistance
    (β : BridgeData)
    (p : AdmissibleWord) : ℝ :=
  relativeDistanceToCode (admissibleCode β) p

/-- Encoding preserves relative Hamming distance between admissible plane words. -/
theorem encode_relativeHammingDistance
    (p q : AdmissibleWord) :
    BlockCode.relativeHammingDistance (encode p) (encode q) =
      BlockCode.relativeHammingDistance p q := by
  exact canonicalPlaneWordEquiv_relativeHammingDistance p q

/-- The target and source codeword-distance sets agree under pair encoding. -/
theorem pairRelativeDistanceSet_encode_eq
    (β : BridgeData)
    (p : AdmissibleWord) :
    relativeDistanceSet (pairCode β) (encode p) =
      relativeDistanceSet (admissibleCode β) p := by
  ext d
  constructor
  · rintro ⟨c, hc, hd⟩
    refine ⟨decode c, ?_, ?_⟩
    · change (pairCode β).Codeword (encode (decode c))
      simpa using hc
    · calc
        d = BlockCode.relativeHammingDistance c (encode p) := hd
        _ = BlockCode.relativeHammingDistance
              (encode (decode c)) (encode p) := by simp
        _ = BlockCode.relativeHammingDistance (decode c) p :=
          encode_relativeHammingDistance (decode c) p
  · rintro ⟨c, hc, hd⟩
    refine ⟨encode c, hc, ?_⟩
    calc
      d = BlockCode.relativeHammingDistance c p := hd
      _ = BlockCode.relativeHammingDistance (encode c) (encode p) :=
        (encode_relativeHammingDistance c p).symm

/-- First comparison: `D_pair (encode p) ≤ d_A p`. -/
theorem pairDistance_encode_le_admissibleDistance
    (β : BridgeData)
    (p : AdmissibleWord) :
    pairDistance β (encode p) ≤ admissibleDistance β p := by
  unfold pairDistance admissibleDistance relativeDistanceToCode
  rw [pairRelativeDistanceSet_encode_eq β p]

/-- Second comparison: `d_A p ≤ D_pair (encode p)`. -/
theorem admissibleDistance_le_pairDistance_encode
    (β : BridgeData)
    (p : AdmissibleWord) :
    admissibleDistance β p ≤ pairDistance β (encode p) := by
  unfold pairDistance admissibleDistance relativeDistanceToCode
  rw [pairRelativeDistanceSet_encode_eq β p]

/-- The two comparison inequalities identify the admissible and paper-pair metrics. -/
theorem pairDistance_encode_eq_admissibleDistance
    (β : BridgeData)
    (p : AdmissibleWord) :
    pairDistance β (encode p) = admissibleDistance β p :=
  le_antisymm
    (pairDistance_encode_le_admissibleDistance β p)
    (admissibleDistance_le_pairDistance_encode β p)

/-!
### Source-to-pair calibration

The source carrier here is the full canonical-region integer-plane word space,
not a subtype of exact codewords.  Its valid locus is the pullback of the paper
pair code, and its source distance is relative Hamming distance to that locus.
Thus arbitrary invalid/noisy observations remain in scope.
-/

/-- Canonical-region plane observations with their pulled-back valid locus. -/
def sourceValidityModel (β : BridgeData) :
    ProximityPrize.Application.SourceValidityModel where
  Observation := AdmissibleWord
  Valid := (admissibleCode β).Codeword
  distanceToValid := admissibleDistance β
  distance_nonneg := fun p =>
    relativeDistanceToCode_nonneg (admissibleCode β) p
  valid_zero_distance := fun _p hp =>
    relativeDistanceToCode_eq_zero_of_codeword (admissibleCode β) hp

/-- The paper pair code equipped with its relative-Hamming distance. -/
def pairCodeShadow (β : BridgeData) :
    ProximityPrize.Application.CodeDistanceModel where
  Word := PairWord
  Codeword := (pairCode β).Codeword
  distanceToCode := pairDistance β

/--
The canonical pair encoding is a source-to-code non-collapse calibration.

The quantitative field is the proved direction
`d_source ≤ D_pair`; in fact the preceding theorem proves equality.
-/
def sourceToPairCalibration (β : BridgeData) :
    ProximityPrize.Application.SourceToCodeCalibration
      (sourceValidityModel β)
      (pairCodeShadow β) where
  extract := encode
  mapsValid := fun _p hp => hp
  noncollapse := fun p =>
    admissibleDistance_le_pairDistance_encode β p

/--
The paper-facing quantitative calibration theorem:

`d_source(p, valid) ≥ δ → Δ(encode p, C≡2) ≥ δ`.
-/
theorem admissibleSourceFar_implies_pairFar
    (β : BridgeData)
    (p : AdmissibleWord)
    (δ : ℝ)
    (hSourceFar : δ ≤ admissibleDistance β p) :
    δ ≤ pairDistance β (encode p) :=
  ProximityPrize.Application.SourceToCodeCalibration.sourceFar_implies_targetFar
    (sourceToPairCalibration β) p δ hSourceFar

end PlanePair

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
facts that must be proved by the composed source-to-RS bridge.
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
