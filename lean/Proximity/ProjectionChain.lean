import Proximity.CochainReedSolomon

/-
  Concrete proximity projection-chain orchestrator.

  The stage-specific files own their local invariants. This file only composes
  the already-checked stages:

    Plucker frame witness -> committed cochain -> plane shadow -> RS word

  The final near/far proximity gap is not checked at each stage. It appears here
  only as an end-to-end far-non-collapse obligation after the composed map and
  verifier-facing metric/radii have been fixed.
-/

namespace Hcrypt
namespace Proximity
namespace ProjectionChain

open GrassmannianPlucker

noncomputable section

variable {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
variable {R F ι : Type}
variable [Field F] [Fintype F] [Fintype ι] [DecidableEq F]

/--
The concrete projection chain from a Plucker frame witness to an RS received
word.

`pluckerToCochain` owns the algebraic-to-committed-cochain step.
`planeToRS` owns the committed-cochain -> plane -> finite-field RS step.
-/
structure Chain
    (P : FramedSystem n r)
    (S : Axioms.SheafCoherence)
    (L : PluckerCochain.LocalSyndromeTarget S)
    (T : ReedSolomonTarget.Target F ι)
    (D : ReedSolomonTarget.Target.ReceivedWordMetric T)
    (E : CochainPlane.PlaneExtractionContext R ι)
    (Φ : CochainReedSolomon.PlaneEncoding R F)
    (pluckerDisagreement : FrameWitness n r → ℝ) where
  pluckerToCochain : PluckerCochain.Projection P S L pluckerDisagreement
  planeToRS : CochainReedSolomon.Interpretation L T D E Φ

namespace Chain

variable
    {P : FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {T : ReedSolomonTarget.Target F ι}
    {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
    {E : CochainPlane.PlaneExtractionContext R ι}
    {Φ : CochainReedSolomon.PlaneEncoding R F}
    {pluckerDisagreement : FrameWitness n r → ℝ}

/-- The committed cochain produced by the Plucker-to-cochain stage. -/
def committedCochain
    (Γ : Chain P S L T D E Φ pluckerDisagreement)
    (W : FrameWitness n r) :
    CochainBridge.CommittedCochain :=
  Γ.pluckerToCochain.encode (P.publicShadow W)

/-- The semantic plane shadow produced by the composed chain. -/
def planeShadow
    (Γ : Chain P S L T D E Φ pluckerDisagreement)
    (W : FrameWitness n r) :
    CochainPlane.PlaneShadow R ι :=
  E.projectedPlane (Γ.committedCochain W)

/-- The RS received word produced by the composed chain. -/
def receivedWord
    (Γ : Chain P S L T D E Φ pluckerDisagreement)
    (W : FrameWitness n r) :
    Word ι F :=
  Γ.planeToRS.receivedWord (Γ.committedCochain W)

/-- The orchestrated chain exposes a single evaluation projection into RS. -/
def toEvaluationProjection
    (Γ : Chain P S L T D E Φ pluckerDisagreement) :
    EvaluationProjection
      (PluckerCochain.pluckerInstance P pluckerDisagreement)
      D.codeShadow where
  map := Γ.receivedWord
  preservesGlobalSections := by
    intro W hW
    have hCandidate :
        CochainBridge.CommittedCochain.GlobalSectionCandidate S
          (Γ.committedCochain W) :=
      Γ.pluckerToCochain.preservesValidFrame W hW
    have hLocal : L.Codeword (Γ.committedCochain W) :=
      L.codeword_of_globalCandidate hCandidate
    exact Γ.planeToRS.projection.mapsCodewordsToTarget (Γ.committedCochain W) hLocal
  distanceControlled := by
    intro W
    have hRS :
        D.distanceToRS (Γ.receivedWord W) ≤
          L.distanceToCode (Γ.committedCochain W) :=
      Γ.planeToRS.projection.distanceControlled (Γ.committedCochain W)
    have hLocal :
        L.distanceToCode (Γ.committedCochain W) ≤ pluckerDisagreement W :=
      Γ.pluckerToCochain.distanceControlled W
    exact le_trans hRS hLocal

/--
The local invariant checklists available from the three concrete stages of the
chain.
-/
structure StageChecklists
    (Γ : Chain P S L T D E Φ pluckerDisagreement) : Prop where
  pluckerCochain :
    PluckerCochain.InvariantChecklist Γ.pluckerToCochain
  cochainPlane :
    CochainPlane.InvariantChecklist Γ.planeToRS.projection
  planeRS :
    CochainReedSolomon.InvariantChecklist Γ.planeToRS

namespace StageChecklists

/-- Every well-typed concrete chain carries the stage-local checklists. -/
def of_chain
    (Γ : Chain P S L T D E Φ pluckerDisagreement) :
    StageChecklists Γ where
  pluckerCochain :=
    PluckerCochain.InvariantChecklist.of_projection Γ.pluckerToCochain
  cochainPlane :=
    CochainPlane.InvariantChecklist.of_projection Γ.planeToRS.projection
  planeRS :=
    CochainReedSolomon.InvariantChecklist.of_interpretation Γ.planeToRS

end StageChecklists

/--
End-to-end readiness for the final proximity comparison.

The local stage invariants are separated from the final far-side promise:
projection stages may quotient intended directions, but the composed received
word must still preserve the calibrated far side chosen for the RS comparison.
-/
structure EndToEndReady
    (Γ : Chain P S L T D E Φ pluckerDisagreement)
    (nearRadius farRadius : ℝ) : Prop where
  stageChecklists : StageChecklists Γ
  farNonCollapse :
    ∀ W : FrameWitness n r,
      farRadius ≤ pluckerDisagreement W →
        farRadius ≤ D.distanceToRS (Γ.receivedWord W)

namespace EndToEndReady

/-- An end-to-end ready chain gives the final gap projection. -/
def toEndToEndGapProjection
    {Γ : Chain P S L T D E Φ pluckerDisagreement}
    {nearRadius farRadius : ℝ}
    (hΓ : EndToEndReady Γ nearRadius farRadius) :
    EndToEndGapProjection
      (PluckerCochain.pluckerInstance P pluckerDisagreement)
      D.codeShadow
      nearRadius
      farRadius where
  projection := Γ.toEvaluationProjection
  preservesFar := hΓ.farNonCollapse

/-- Package an end-to-end ready chain as the completed RS bridge surface. -/
def toHcryptToRSBridge
    {Γ : Chain P S L T D E Φ pluckerDisagreement}
    {nearRadius farRadius : ℝ}
    (hΓ : EndToEndReady Γ nearRadius farRadius)
    (hgap : nearRadius ≤ farRadius)
    (obligations : ReedSolomonTarget.Target.BridgeObligations T)
    (hobligations : obligations.Complete) :
    ReedSolomonTarget.Target.HcryptToRSBridge
      (PluckerCochain.pluckerInstance P pluckerDisagreement)
      T
      D where
  nearRadius := nearRadius
  farRadius := farRadius
  gap := hgap
  obligations := obligations
  obligationsComplete := hobligations
  projection := hΓ.toEndToEndGapProjection

end EndToEndReady

/--
Calibrated end-to-end readiness for the final proximity comparison.

This is the preferred final theorem shape for the proximity proof. The source
and target radii may differ, while the local stage invariants remain unchanged.
-/
structure CalibratedEndToEndReady
    (Γ : Chain P S L T D E Φ pluckerDisagreement)
    (sourceNearRadius sourceFarRadius targetNearRadius targetFarRadius : ℝ) : Prop where
  stageChecklists : StageChecklists Γ
  nearRadiusCompatible : sourceNearRadius ≤ targetNearRadius
  farNonCollapse :
    ∀ W : FrameWitness n r,
      sourceFarRadius ≤ pluckerDisagreement W →
        targetFarRadius ≤ D.distanceToRS (Γ.receivedWord W)

namespace CalibratedEndToEndReady

/-- A same-radius ready chain is also calibrated with identical source/target radii. -/
def ofEndToEndReady
    {Γ : Chain P S L T D E Φ pluckerDisagreement}
    {nearRadius farRadius : ℝ}
    (hΓ : EndToEndReady Γ nearRadius farRadius) :
    CalibratedEndToEndReady Γ nearRadius farRadius nearRadius farRadius where
  stageChecklists := hΓ.stageChecklists
  nearRadiusCompatible := le_rfl
  farNonCollapse := hΓ.farNonCollapse

/-- A calibrated ready chain gives the calibrated final gap projection. -/
def toCalibratedEndToEndGapProjection
    {Γ : Chain P S L T D E Φ pluckerDisagreement}
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
def toCalibratedHcryptToRSBridge
    {Γ : Chain P S L T D E Φ pluckerDisagreement}
    {sourceNearRadius sourceFarRadius targetNearRadius targetFarRadius : ℝ}
    (hΓ :
      CalibratedEndToEndReady
        Γ sourceNearRadius sourceFarRadius targetNearRadius targetFarRadius)
    (hsource : sourceNearRadius ≤ sourceFarRadius)
    (htarget : targetNearRadius ≤ targetFarRadius)
    (obligations : ReedSolomonTarget.Target.BridgeObligations T)
    (hobligations : obligations.Complete) :
    ReedSolomonTarget.Target.CalibratedHcryptToRSBridge
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

end Chain

end

end ProjectionChain
end Proximity
end Hcrypt
