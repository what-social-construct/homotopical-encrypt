module

public import Proximity.Concrete.Gates.Stage

@[expose] public section

/-
  Final proximity checks for an already-orchestrated projection chain.

  Paper correspondence:
  - Paper 3: final radius calibration and the explicit mathematical
    far/non-collapse hypothesis.
  - Paper 2: named final-certificate and gate-readiness consequences under the
    original context/evidence contracts.

  `ProjectionChain.Core` owns only the stage composition. This file owns the
  radius calibration, final far/non-collapse witness, and handoff to the
  generic gap/RS bridge surfaces.
-/

namespace HomotopicalEncryption
namespace Proximity
namespace Gates
namespace Projection

open GrassmannianPlucker

noncomputable section

variable {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
variable {R F ι : Type}
variable [Field F] [Fintype F] [Fintype ι] [DecidableEq F]

variable
    {P : FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {T : ReedSolomonTarget.Target F ι}
    {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
    {E : CochainPlane.PlaneExtractionContext R ι}
    {Φ : CochainReedSolomon.PlaneEncoding R F}
    {pluckerDisagreement : FrameWitness n r → ℝ}

/--
Chosen source/target radii for a calibrated proximity comparison.

This object owns the numeric regime for the last check. It records the source
and target gaps, plus the near-radius compatibility needed because the
projection chain may be lossy.
-/
structure RadiusCalibration where
  sourceNearRadius : ℝ
  sourceFarRadius : ℝ
  targetNearRadius : ℝ
  targetFarRadius : ℝ
  sourceGap : sourceNearRadius ≤ sourceFarRadius
  targetGap : targetNearRadius ≤ targetFarRadius
  nearCompatible : sourceNearRadius ≤ targetNearRadius

namespace RadiusCalibration

/-- Calibration constructor for regimes whose source and target radii agree. -/
def sameRadius
    (nearRadius farRadius : ℝ)
    (hgap : nearRadius ≤ farRadius) :
    RadiusCalibration where
  sourceNearRadius := nearRadius
  sourceFarRadius := farRadius
  targetNearRadius := nearRadius
  targetFarRadius := farRadius
  sourceGap := hgap
  targetGap := hgap
  nearCompatible := le_rfl

end RadiusCalibration

/--
The actual final far-side theorem for a calibrated chain.

This is the theorem that cannot be supplied by local gate certificates: after
all projection/encoding/metric choices are fixed, far source instances must not
collapse to near RS received words.

This is not a global injectivity or distance-preservation claim. Intended
quotient/kernel directions may collapse; the theorem only separates the chosen
far region from the target near region.
-/
structure FarNonCollapseWitness
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement)
    (sourceFarRadius targetFarRadius : ℝ) : Prop where
  noncollapse :
    ∀ W : FrameWitness n r,
      sourceFarRadius ≤ pluckerDisagreement W →
        targetFarRadius ≤ D.distanceToRS (Γ.receivedWord W)

namespace FarNonCollapseWitness

/-- Direct constructor for the final non-collapse theorem. -/
def of_noncollapse
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {sourceFarRadius targetFarRadius : ℝ}
    (h :
      ∀ W : FrameWitness n r,
        sourceFarRadius ≤ pluckerDisagreement W →
          targetFarRadius ≤ D.distanceToRS (Γ.receivedWord W)) :
    FarNonCollapseWitness Γ sourceFarRadius targetFarRadius where
  noncollapse := h

/--
Build non-collapse from a pointwise lower bound on projected distance.

This is a stronger theorem shape than needed, but often easier to aim for:
the final RS distance lower-bounds the source disagreement, up to the chosen
source/target far-radius comparison.
-/
def of_distanceLowerBound
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {sourceFarRadius targetFarRadius : ℝ}
    (hRadius : targetFarRadius ≤ sourceFarRadius)
    (hLower :
      ∀ W : FrameWitness n r,
        pluckerDisagreement W ≤ D.distanceToRS (Γ.receivedWord W)) :
    FarNonCollapseWitness Γ sourceFarRadius targetFarRadius :=
  of_noncollapse fun W hFar =>
    le_trans (le_trans hRadius hFar) (hLower W)

/--
Build non-collapse from exact distance preservation at the final metric.

This is the cleanest theorem shape when the composed projection is calibrated
to make the RS distance equal to the source disagreement.
-/
def of_distanceEquality
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {sourceFarRadius targetFarRadius : ℝ}
    (hRadius : targetFarRadius ≤ sourceFarRadius)
    (hEq :
      ∀ W : FrameWitness n r,
        D.distanceToRS (Γ.receivedWord W) = pluckerDisagreement W) :
    FarNonCollapseWitness Γ sourceFarRadius targetFarRadius :=
  of_noncollapse fun W hFar => by
    have hTarget : targetFarRadius ≤ pluckerDisagreement W :=
      le_trans hRadius hFar
    simpa [hEq W] using hTarget

end FarNonCollapseWitness

/--
Quotient-aware reading of the final theorem.

This alias emphasizes that the final gate separates the selected far region,
while allowing collapse along intended quotient directions.
-/
abbrev FarRegionSeparation
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement)
    (sourceFarRadius targetFarRadius : ℝ) :=
  FarNonCollapseWitness Γ sourceFarRadius targetFarRadius

namespace FarRegionSeparation

/--
Collapsed pairs are compatible with the final theorem.

If a far source witness collapses to the same received word as another witness,
the shared received word is still far on the RS side. The theorem rules out
far-to-near collapse, not all pair collapse.
-/
theorem collapsed_pair_target_far
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {sourceFarRadius targetFarRadius : ℝ}
    (ω : FarRegionSeparation Γ sourceFarRadius targetFarRadius)
    {W V : FrameWitness n r}
    (hCollapse : Γ.receivedWord W = Γ.receivedWord V)
    (hFar : sourceFarRadius ≤ pluckerDisagreement W) :
    targetFarRadius ≤ D.distanceToRS (Γ.receivedWord V) := by
  simpa [hCollapse] using ω.noncollapse W hFar

end FarRegionSeparation

/--
Calibrated final gate certificate.

This is the final gate in the calibrated proximity pipeline. It consumes the
accumulated gate certificate, records the chosen radius calibration, and appends
only the final far non-collapse witness.
-/
structure CalibratedFinalGateCertificate
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement)
    (κ : RadiusCalibration) : Prop where
  previous : ProjectionStageGateCertificate Γ
  finalWitness :
    FarNonCollapseWitness Γ κ.sourceFarRadius κ.targetFarRadius

namespace CalibratedFinalGateCertificate

/-- Extend the accumulated gate certificate through the calibrated final gate. -/
def extend
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (χ : ProjectionStageGateCertificate Γ)
    (κ : RadiusCalibration)
    (ω : FarNonCollapseWitness Γ κ.sourceFarRadius κ.targetFarRadius) :
    CalibratedFinalGateCertificate Γ κ where
  previous := χ
  finalWitness := ω

end CalibratedFinalGateCertificate

/--
Final calibrated check after all gate certificates have already been built.

This is the publication-facing last check: it records radius compatibility and
far non-collapse for the composed map, without repeating each gate certificate.
-/
structure CalibratedFinalCheck
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement)
    (sourceNearRadius sourceFarRadius targetNearRadius targetFarRadius : ℝ) : Prop where
  nearRadiusCompatible : sourceNearRadius ≤ targetNearRadius
  farNonCollapse :
    ∀ W : FrameWitness n r,
      sourceFarRadius ≤ pluckerDisagreement W →
        targetFarRadius ≤ D.distanceToRS (Γ.receivedWord W)

/--
Calibrated end-to-end readiness for the final proximity comparison.

This is the preferred final theorem shape for the proximity proof. The source
and target radii may differ, while the accumulated gate certificate has already
been built gate-by-gate.
-/
structure CalibratedEndToEndReady
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement)
    (sourceNearRadius sourceFarRadius targetNearRadius targetFarRadius : ℝ) : Prop where
  gateCertificate : ProjectionStageGateCertificate Γ
  nearRadiusCompatible : sourceNearRadius ≤ targetNearRadius
  farNonCollapse :
    ∀ W : FrameWitness n r,
      sourceFarRadius ≤ pluckerDisagreement W →
        targetFarRadius ≤ D.distanceToRS (Γ.receivedWord W)

namespace CalibratedFinalCheck

/-- Build the calibrated final check from chosen radii and non-collapse. -/
def of_witness
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (κ : RadiusCalibration)
    (ω : FarNonCollapseWitness Γ κ.sourceFarRadius κ.targetFarRadius) :
    CalibratedFinalCheck
      Γ
      κ.sourceNearRadius
      κ.sourceFarRadius
      κ.targetNearRadius
      κ.targetFarRadius where
  nearRadiusCompatible := κ.nearCompatible
  farNonCollapse := ω.noncollapse

/-- Extract the calibrated final check from a final gate certificate. -/
def of_gateCertificate
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {κ : RadiusCalibration}
    (χ : CalibratedFinalGateCertificate Γ κ) :
    CalibratedFinalCheck
      Γ
      κ.sourceNearRadius
      κ.sourceFarRadius
      κ.targetNearRadius
      κ.targetFarRadius :=
  of_witness κ χ.finalWitness

/-- Combine the accumulated gate certificate with the final calibrated check. -/
def toCalibratedEndToEndReady
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {sourceNearRadius sourceFarRadius targetNearRadius targetFarRadius : ℝ}
    (hΓ :
      CalibratedFinalCheck
        Γ sourceNearRadius sourceFarRadius targetNearRadius targetFarRadius)
    (χ : ProjectionStageGateCertificate Γ) :
    CalibratedEndToEndReady
      Γ sourceNearRadius sourceFarRadius targetNearRadius targetFarRadius where
  gateCertificate := χ
  nearRadiusCompatible := hΓ.nearRadiusCompatible
  farNonCollapse := hΓ.farNonCollapse

/-- A calibrated final gate certificate directly gives end-to-end readiness. -/
def ready_of_gateCertificate
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {κ : RadiusCalibration}
    (χ : CalibratedFinalGateCertificate Γ κ) :
    CalibratedEndToEndReady
      Γ
      κ.sourceNearRadius
      κ.sourceFarRadius
      κ.targetNearRadius
      κ.targetFarRadius :=
  (of_gateCertificate χ).toCalibratedEndToEndReady χ.previous

end CalibratedFinalCheck

namespace CalibratedEndToEndReady

/-- A calibrated ready chain gives the calibrated final gap projection. -/
def toCalibratedEndToEndGapProjection
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {sourceNearRadius sourceFarRadius targetNearRadius targetFarRadius : ℝ}
    (hΓ :
      CalibratedEndToEndReady
        Γ sourceNearRadius sourceFarRadius targetNearRadius targetFarRadius) :
    CalibratedEndToEndGapProjection
      (PluckerCochain.pluckerInstance P pluckerDisagreement)
      D.codeShadow
      sourceNearRadius
      sourceFarRadius
      targetNearRadius
      targetFarRadius where
  projection := Γ.toEvaluationProjection
  nearRadiusCompatible := hΓ.nearRadiusCompatible
  preservesFar := hΓ.farNonCollapse

/-- Package a calibrated ready chain as the completed calibrated RS bridge surface. -/
def toCalibratedHomotopicalEncryptionToRSBridge
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {sourceNearRadius sourceFarRadius targetNearRadius targetFarRadius : ℝ}
    (hΓ :
      CalibratedEndToEndReady
        Γ sourceNearRadius sourceFarRadius targetNearRadius targetFarRadius)
    (hsource : sourceNearRadius ≤ sourceFarRadius)
    (htarget : targetNearRadius ≤ targetFarRadius)
    (obligations : ReedSolomonTarget.Target.BridgeObligations T)
    (hobligations : obligations.Complete) :
    ReedSolomonTarget.Target.CalibratedHomotopicalEncryptionToRSBridge
      (PluckerCochain.pluckerInstance P pluckerDisagreement)
      T
      D where
  sourceNearRadius := sourceNearRadius
  sourceFarRadius := sourceFarRadius
  targetNearRadius := targetNearRadius
  targetFarRadius := targetFarRadius
  sourceGap := hsource
  targetGap := htarget
  obligations := obligations
  obligationsComplete := hobligations
  projection := hΓ.toCalibratedEndToEndGapProjection

end CalibratedEndToEndReady

end

end Projection
end Gates
end Proximity
end HomotopicalEncryption
