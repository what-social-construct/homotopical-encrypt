import Proximity.RS.ReedSolomon
import Proximity.Problem

/- Paper correspondence: Paper 1 Section 6, RS target interface for proximity. -/

/- Reed-Solomon target layer for the hcrypt proximity pipeline. -/

namespace Hcrypt
namespace Proximity
namespace ReedSolomonTarget

/--
RS target data for a concrete parameter choice.

The ordinary correlated-agreement bound follows from MCA by the generic theorem,
so the target stores the stronger MCA input.
-/
structure Target
    (F ι : Type) [Field F] [Fintype F] [Fintype ι] [DecidableEq F] where
  parameters : Hcrypt.Proximity.ReedSolomon.Parameters F ι
  fAdditive :
    parameters.FAdditive
  smoothRegime : Prop
  listRadius : ℕ
  listSize : ℕ
  pointRadius : ℕ
  lineRadius : ℕ
  threshold : ℕ
  listDecodingBound :
    parameters.ListDecodingBound listRadius listSize
  listDecodingBoundAt :
    parameters.ListDecodingBoundAt
      (Hcrypt.Proximity.BlockCode.relativeRadius (ι := ι) listRadius)
      listSize
  mutualCorrelatedAgreementBound :
    parameters.MutualCorrelatedAgreementBound pointRadius lineRadius threshold
  mutualCorrelatedAgreementErrorBound :
    parameters.MutualCorrelatedAgreementErrorBound
      (Hcrypt.Proximity.BlockCode.relativeRadius (ι := ι) pointRadius)
      (Hcrypt.Proximity.BlockCode.relativeRadius (ι := ι) lineRadius)
      ((threshold : ℝ) / (Fintype.card F : ℝ))
  paperMutualCorrelatedAgreementErrorBound :
    parameters.PaperMutualCorrelatedAgreementErrorBound
      (Hcrypt.Proximity.BlockCode.relativeRadius (ι := ι) pointRadius)
      ((threshold : ℝ) / (Fintype.card F : ℝ))

namespace Target

variable {F ι : Type} [Field F] [Fintype F] [Fintype ι] [DecidableEq F]

/-- The underlying RS block code named by the target. -/
def blockCode (T : Target F ι) :
    Hcrypt.Proximity.BlockCode ι F :=
  T.parameters.toBlockCode

/-- The target explicitly carries the F-additivity required by paper CA/MCA. -/
theorem fAdditiveHolds (T : Target F ι) :
    T.parameters.FAdditive :=
  T.fAdditive

/-- The target as the generic additive-code interface used by paper line arguments. -/
def toFAdditiveCode (T : Target F ι) :
    Hcrypt.Proximity.FAdditiveCode F ι F :=
  T.fAdditive.toFAdditiveCode

/-- The list-decoding bound explicitly carried by the target. -/
theorem listDecodingBoundHolds (T : Target F ι) :
    T.parameters.ListDecodingBound T.listRadius T.listSize :=
  T.listDecodingBound

/-- The fractional list-decoding bound explicitly carried by the target. -/
theorem listDecodingBoundAtHolds (T : Target F ι) :
    T.parameters.ListDecodingBoundAt
      (Hcrypt.Proximity.BlockCode.relativeRadius (ι := ι) T.listRadius)
      T.listSize :=
  T.listDecodingBoundAt

/--
The CA consequence available from the stored MCA input.
-/
theorem correlatedAgreementBound (T : Target F ι) :
    T.parameters.CorrelatedAgreementBound
      T.pointRadius T.lineRadius T.threshold :=
  Hcrypt.Proximity.ReedSolomon.Parameters.correlatedAgreement_of_mutualCorrelatedAgreement
    T.parameters T.mutualCorrelatedAgreementBound

/-- The fractional MCA error bound explicitly carried by the target. -/
theorem mutualCorrelatedAgreementErrorBoundHolds (T : Target F ι) :
    T.parameters.MutualCorrelatedAgreementErrorBound
      (Hcrypt.Proximity.BlockCode.relativeRadius (ι := ι) T.pointRadius)
      (Hcrypt.Proximity.BlockCode.relativeRadius (ι := ι) T.lineRadius)
      ((T.threshold : ℝ) / (Fintype.card F : ℝ)) :=
  T.mutualCorrelatedAgreementErrorBound

/-- The paper Definition 4.3 MCA error bound explicitly carried by the target. -/
theorem paperMutualCorrelatedAgreementErrorBoundHolds (T : Target F ι) :
    T.parameters.PaperMutualCorrelatedAgreementErrorBound
      (Hcrypt.Proximity.BlockCode.relativeRadius (ι := ι) T.pointRadius)
      ((T.threshold : ℝ) / (Fintype.card F : ℝ)) :=
  T.paperMutualCorrelatedAgreementErrorBound

/--
Metric data turning the RS code into a `CodeShadow`.

Different RS regimes may use Hamming, relative Hamming, folded, interleaved, or
normalized distances. The shared requirement is that exact RS codewords have
zero distance.
-/
structure ReceivedWordMetric (T : Target F ι) where
  distanceToRS : Hcrypt.Proximity.Word ι F → ℝ
  codeword_zero_distance :
    ∀ w : Hcrypt.Proximity.Word ι F,
      T.parameters.Codeword w → distanceToRS w = 0

namespace ReceivedWordMetric

/-- The RS received-word view as a generic hcrypt code shadow. -/
def codeShadow {T : Target F ι} (D : ReceivedWordMetric T) :
    Hcrypt.Proximity.CodeShadow where
  Word := Hcrypt.Proximity.Word ι F
  Codeword := T.parameters.Codeword
  distanceToCode := D.distanceToRS

/-- Exact RS codewords have zero target distance. -/
theorem distance_eq_zero_of_codeword
    {T : Target F ι} (D : ReceivedWordMetric T)
    {w : Hcrypt.Proximity.Word ι F}
    (hw : T.parameters.Codeword w) :
    D.codeShadow.distanceToCode w = 0 :=
  D.codeword_zero_distance w hw

end ReceivedWordMetric

/--
Radius normalization for an RS received-word metric.

RS/list-decoding bounds are usually stated with natural-number Hamming radii,
while the generic hcrypt proximity interface uses real-valued scores. This
structure fixes the conversion and records the compatibility fact needed for
the near side: Hamming-close words are close in the selected real metric.
-/
structure RadiusNormalization
    {T : Target F ι}
    (D : ReceivedWordMetric T) where
  hammingRadiusToReal : ℕ → ℝ
  radius_zero : hammingRadiusToReal 0 = 0
  radius_mono :
    ∀ {r s : ℕ}, r ≤ s → hammingRadiusToReal r ≤ hammingRadiusToReal s
  close_le_radius :
    ∀ {r : ℕ} {w : Hcrypt.Proximity.Word ι F},
      T.parameters.toBlockCode.Close r w →
        D.distanceToRS w ≤ hammingRadiusToReal r
  listRadiusReal : ℝ
  pointRadiusReal : ℝ
  lineRadiusReal : ℝ
  listRadius_eq : listRadiusReal = hammingRadiusToReal T.listRadius
  pointRadius_eq : pointRadiusReal = hammingRadiusToReal T.pointRadius
  lineRadius_eq : lineRadiusReal = hammingRadiusToReal T.lineRadius

namespace RadiusNormalization

/--
The relative Hamming convention for this target's coordinate domain.
-/
noncomputable def relativeHammingRadius (r : ℕ) : ℝ :=
  Hcrypt.Proximity.BlockCode.relativeRadius (ι := ι) r

/-- Relative Hamming radius sends zero to zero. -/
theorem relativeHammingRadius_zero :
    relativeHammingRadius (ι := ι) 0 = 0 :=
  Hcrypt.Proximity.BlockCode.relativeRadius_zero

/-- Relative Hamming radius is monotone in the Hamming-count radius. -/
theorem relativeHammingRadius_mono {r s : ℕ} (hrs : r ≤ s) :
    relativeHammingRadius (ι := ι) r ≤ relativeHammingRadius (ι := ι) s :=
  Hcrypt.Proximity.BlockCode.relativeRadius_mono (ι := ι) hrs

/--
Build a radius-normalization witness for a relative Hamming-compatible metric.

The metric remains real-valued and paper-facing; the natural-number radius is
only the finite combinatorial representation of the same threshold.
-/
noncomputable def relative
    {T : Target F ι}
    (D : ReceivedWordMetric T)
    (hclose :
      ∀ {r : ℕ} {w : Hcrypt.Proximity.Word ι F},
        T.parameters.toBlockCode.Close r w →
          D.distanceToRS w ≤ relativeHammingRadius (ι := ι) r) :
    RadiusNormalization D where
  hammingRadiusToReal := relativeHammingRadius (ι := ι)
  radius_zero := relativeHammingRadius_zero (ι := ι)
  radius_mono := by
    intro r s hrs
    exact relativeHammingRadius_mono (ι := ι) hrs
  close_le_radius := by
    intro r w hw
    exact hclose hw
  listRadiusReal := relativeHammingRadius (ι := ι) T.listRadius
  pointRadiusReal := relativeHammingRadius (ι := ι) T.pointRadius
  lineRadiusReal := relativeHammingRadius (ι := ι) T.lineRadius
  listRadius_eq := rfl
  pointRadius_eq := rfl
  lineRadius_eq := rfl

end RadiusNormalization

/--
What remains to connect an hcrypt projection to this RS target.

The naturality obligations are categorical squares:
- `RestrictionNaturality`: projection commutes with hcrypt restriction/transport
  and the corresponding RS/evaluation-side restriction;
- `CoboundaryNaturality`: projection commutes with the cochain coboundary or
  syndrome operator used to measure local inconsistency.

The metric obligations are separate:
- `MetricNormalization`: the selected RS distance/radius convention is fixed;
- `NearDistanceCompatible`: near hcrypt objects project to near RS words;
- `FarNonCollapse`: far hcrypt objects do not collapse to near RS words.
-/
structure BridgeObligations (T : Target F ι) where
  DomainCardinalityMatches : Prop
  SmoothDomainWitness : Prop
  EvaluationPointCompatible : Prop
  RestrictionNaturality : Prop
  CoboundaryNaturality : Prop
  GlobalSectionsMapToRSCodewords : Prop
  ProjectionMatchesReceivedWord : Prop
  MetricNormalization : Prop
  NearDistanceCompatible : Prop
  FarNonCollapse : Prop
  RadiusParametersMatch : Prop

/-- Named completion witness for all RS bridge invariants. -/
structure BridgeObligations.Complete {T : Target F ι}
    (B : BridgeObligations T) : Prop where
  domainCardinalityMatches : B.DomainCardinalityMatches
  smoothDomainWitness : B.SmoothDomainWitness
  evaluationPointCompatible : B.EvaluationPointCompatible
  restrictionNaturality : B.RestrictionNaturality
  coboundaryNaturality : B.CoboundaryNaturality
  globalSectionsMapToRSCodewords : B.GlobalSectionsMapToRSCodewords
  projectionMatchesReceivedWord : B.ProjectionMatchesReceivedWord
  metricNormalization : B.MetricNormalization
  nearDistanceCompatible : B.NearDistanceCompatible
  farNonCollapse : B.FarNonCollapse
  radiusParametersMatch : B.RadiusParametersMatch

namespace BridgeObligations

variable {T : Target F ι}

/-- Completed bridge obligations include restriction naturality. -/
theorem restrictionNaturality_of_complete
    {B : BridgeObligations T}
    (hB : B.Complete) :
    B.RestrictionNaturality :=
  hB.restrictionNaturality

/-- Completed bridge obligations include coboundary/syndrome naturality. -/
theorem coboundaryNaturality_of_complete
    {B : BridgeObligations T}
    (hB : B.Complete) :
    B.CoboundaryNaturality :=
  hB.coboundaryNaturality

/-- Completed bridge obligations include global-section/codeword compatibility. -/
theorem globalSectionsMapToRSCodewords_of_complete
    {B : BridgeObligations T}
    (hB : B.Complete) :
    B.GlobalSectionsMapToRSCodewords :=
  hB.globalSectionsMapToRSCodewords

/-- Completed bridge obligations include metric normalization. -/
theorem metricNormalization_of_complete
    {B : BridgeObligations T}
    (hB : B.Complete) :
    B.MetricNormalization :=
  hB.metricNormalization

/-- Completed bridge obligations include near-distance compatibility. -/
theorem nearDistanceCompatible_of_complete
    {B : BridgeObligations T}
    (hB : B.Complete) :
    B.NearDistanceCompatible :=
  hB.nearDistanceCompatible

/-- Completed bridge obligations include far non-collapse. -/
theorem farNonCollapse_of_complete
    {B : BridgeObligations T}
    (hB : B.Complete) :
    B.FarNonCollapse :=
  hB.farNonCollapse

end BridgeObligations

/--
A completed calibrated bridge from a hcrypt proximity instance to the RS target.

The source and target radii may differ. This is the publication-facing bridge
shape for lossy projection chains where metric normalization changes across the
projection boundary.
-/
structure CalibratedHcryptToRSBridge
    (S : Hcrypt.Proximity.SheafProximityInstance)
    (T : Target F ι)
    (D : ReceivedWordMetric T) where
  sourceNearRadius : ℝ
  sourceFarRadius : ℝ
  targetNearRadius : ℝ
  targetFarRadius : ℝ
  sourceGap : sourceNearRadius ≤ sourceFarRadius
  targetGap : targetNearRadius ≤ targetFarRadius
  obligations : BridgeObligations T
  obligationsComplete : obligations.Complete
  projection :
    Hcrypt.Proximity.CalibratedEndToEndGapProjection
      S D.codeShadow sourceNearRadius sourceFarRadius targetNearRadius targetFarRadius

namespace CalibratedHcryptToRSBridge

variable {S : Hcrypt.Proximity.SheafProximityInstance}
variable {T : Target F ι} {D : ReceivedWordMetric T}

/-- The hcrypt gap problem induced by a completed calibrated RS bridge. -/
def sourceProblem (B : CalibratedHcryptToRSBridge S T D) :
    Hcrypt.Proximity.GapProximityProblem :=
  Hcrypt.Proximity.sheafGapProblem
    S B.sourceNearRadius B.sourceFarRadius B.sourceGap

/-- The RS gap problem induced by a completed calibrated bridge. -/
def targetProblem (B : CalibratedHcryptToRSBridge S T D) :
    Hcrypt.Proximity.GapProximityProblem :=
  Hcrypt.Proximity.codeGapProblem
    D.codeShadow B.targetNearRadius B.targetFarRadius B.targetGap

/--
A correct RS-shadow solver pulls back to a correct hcrypt solver along a
completed calibrated end-to-end bridge.
-/
theorem pullback_solver_correct
    (B : CalibratedHcryptToRSBridge S T D)
    (solver : B.targetProblem.Solver)
    (hsolver : B.targetProblem.SolverCorrect solver) :
    B.sourceProblem.SolverCorrect
      ((B.projection.toGapReduction B.sourceGap B.targetGap).pullbackSolver solver) :=
  Hcrypt.Proximity.CalibratedEndToEndGapProjection.pullback_code_solver_correct
    B.projection B.sourceGap B.targetGap solver hsolver

end CalibratedHcryptToRSBridge

/--
A completed end-to-end bridge from a hcrypt proximity instance to the RS target.

The bridge provides the composed projection into RS received words and records
preservation of the selected near/far radii after all projection, encoding, and
metric-normalization choices have been fixed.
-/
structure HcryptToRSBridge
    (S : Hcrypt.Proximity.SheafProximityInstance)
    (T : Target F ι)
    (D : ReceivedWordMetric T) where
  nearRadius : ℝ
  farRadius : ℝ
  gap : nearRadius ≤ farRadius
  obligations : BridgeObligations T
  obligationsComplete : obligations.Complete
  projection :
    Hcrypt.Proximity.EndToEndGapProjection
      S D.codeShadow nearRadius farRadius

namespace HcryptToRSBridge

variable {S : Hcrypt.Proximity.SheafProximityInstance}
variable {T : Target F ι} {D : ReceivedWordMetric T}

/-- The hcrypt gap problem induced by a completed RS bridge. -/
def sourceProblem (B : HcryptToRSBridge S T D) :
    Hcrypt.Proximity.GapProximityProblem :=
  Hcrypt.Proximity.sheafGapProblem S B.nearRadius B.farRadius B.gap

/-- The RS gap problem induced by a completed bridge. -/
def targetProblem (B : HcryptToRSBridge S T D) :
    Hcrypt.Proximity.GapProximityProblem :=
  Hcrypt.Proximity.codeGapProblem D.codeShadow B.nearRadius B.farRadius B.gap

/--
A correct RS-shadow solver pulls back to a correct hcrypt solver along a
completed end-to-end gap bridge.

This is the reduction plumbing from an RS-shadow solver back to hcrypt.
-/
theorem pullback_solver_correct
    (B : HcryptToRSBridge S T D)
    (solver : B.targetProblem.Solver)
    (hsolver : B.targetProblem.SolverCorrect solver) :
    B.sourceProblem.SolverCorrect
      ((B.projection.toGapReduction B.gap).pullbackSolver solver) :=
  Hcrypt.Proximity.EndToEndGapProjection.pullback_code_solver_correct
    B.projection B.gap solver hsolver

end HcryptToRSBridge

/-- Checklist for a concrete RS target instantiation. -/
structure InstantiationChecklist
    (S : Hcrypt.Proximity.SheafProximityInstance)
    (T : Target F ι)
    (D : ReceivedWordMetric T) where
  bridge : HcryptToRSBridge S T D
  rsBoundsNamed :
    T.parameters.ListDecodingBound T.listRadius T.listSize ∧
      T.parameters.ListDecodingBoundAt
        (Hcrypt.Proximity.BlockCode.relativeRadius (ι := ι) T.listRadius)
        T.listSize ∧
      T.parameters.MutualCorrelatedAgreementBound
        T.pointRadius T.lineRadius T.threshold ∧
      T.parameters.MutualCorrelatedAgreementErrorBound
        (Hcrypt.Proximity.BlockCode.relativeRadius (ι := ι) T.pointRadius)
        (Hcrypt.Proximity.BlockCode.relativeRadius (ι := ι) T.lineRadius)
        ((T.threshold : ℝ) / (Fintype.card F : ℝ)) ∧
      T.parameters.PaperMutualCorrelatedAgreementErrorBound
        (Hcrypt.Proximity.BlockCode.relativeRadius (ι := ι) T.pointRadius)
        ((T.threshold : ℝ) / (Fintype.card F : ℝ))
  bridgeComplete : bridge.obligations.Complete
  noProtocolImport : Prop

namespace InstantiationChecklist

variable {S : Hcrypt.Proximity.SheafProximityInstance}
variable {T : Target F ι} {D : ReceivedWordMetric T}

/-- A checklist exposes the completed bridge obligations. -/
theorem obligations_complete (C : InstantiationChecklist S T D) :
    C.bridge.obligations.Complete :=
  C.bridgeComplete

/-- A checklist exposes the list-decoding and MCA bounds. -/
theorem bounds_named (C : InstantiationChecklist S T D) :
    T.parameters.ListDecodingBound T.listRadius T.listSize ∧
      T.parameters.ListDecodingBoundAt
        (Hcrypt.Proximity.BlockCode.relativeRadius (ι := ι) T.listRadius)
        T.listSize ∧
      T.parameters.MutualCorrelatedAgreementBound
        T.pointRadius T.lineRadius T.threshold ∧
      T.parameters.MutualCorrelatedAgreementErrorBound
        (Hcrypt.Proximity.BlockCode.relativeRadius (ι := ι) T.pointRadius)
        (Hcrypt.Proximity.BlockCode.relativeRadius (ι := ι) T.lineRadius)
        ((T.threshold : ℝ) / (Fintype.card F : ℝ)) ∧
      T.parameters.PaperMutualCorrelatedAgreementErrorBound
        (Hcrypt.Proximity.BlockCode.relativeRadius (ι := ι) T.pointRadius)
        ((T.threshold : ℝ) / (Fintype.card F : ℝ)) :=
  C.rsBoundsNamed

end InstantiationChecklist

end Target

end ReedSolomonTarget
end Proximity
end Hcrypt
