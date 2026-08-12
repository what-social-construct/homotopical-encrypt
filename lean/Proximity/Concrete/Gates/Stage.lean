import Proximity.Concrete.ProjectionChain.Core

/-
  Stage-gate certificates for a projection chain.

  Paper correspondence:
  - Paper 1 Section 6: projection-stage certificates.

  `ProjectionChain.Core` owns the composed maps. This file owns the accumulated
  stage certificates for those maps:

    Plucker/cochain gate -> cochain/plane gate -> plane/RS gate
-/

namespace Hcrypt
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

/-- Witness-local state after the Plucker-to-cochain gate. -/
structure PluckerCochainState
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement)
    (W : FrameWitness n r) where
  committedCochain : CochainBridge.CommittedCochain
  committedCochain_matches :
    committedCochain = Γ.committedCochain W
  localDistance_le_source :
    L.distanceToCode committedCochain ≤ pluckerDisagreement W

/-- Witness-local state after the cochain-to-plane gate. -/
structure CochainPlaneState
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement)
    (W : FrameWitness n r) where
  previous : PluckerCochainState Γ W
  planeShadow : CochainPlane.PlaneShadow R ι
  planeShadow_matches :
    planeShadow = E.projectedPlane previous.committedCochain
  planeDistance_le_local :
    Γ.planeToRS.planeTarget.distanceToCode planeShadow ≤
      L.distanceToCode previous.committedCochain

/--
Final witness-local state bus after the plane-to-RS gate.

Each layer stores the previous state and appends only its own output and metric
handoff. Thus the RS layer is constructed only after the cochain and plane
layers have already passed for this witness.
-/
structure StateBus
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement)
    (W : FrameWitness n r) where
  previous : CochainPlaneState Γ W
  receivedWord : Word ι F
  receivedWord_matches :
    receivedWord = Φ.receivedWord previous.planeShadow
  rsDistance_le_plane :
    D.distanceToRS receivedWord ≤
      Γ.planeToRS.planeTarget.distanceToCode previous.planeShadow

namespace StateBus

/-- The committed cochain already carried by the previous stage. -/
def committedCochain
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {W : FrameWitness n r}
    (σ : StateBus Γ W) :
    CochainBridge.CommittedCochain :=
  σ.previous.previous.committedCochain

/-- The plane shadow already carried by the previous stage. -/
def planeShadow
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {W : FrameWitness n r}
    (σ : StateBus Γ W) :
    CochainPlane.PlaneShadow R ι :=
  σ.previous.planeShadow

/-- The state bus composes the plane and RS metric handoffs. -/
theorem rsDistance_le_local
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {W : FrameWitness n r}
    (σ : StateBus Γ W) :
    D.distanceToRS σ.receivedWord ≤ L.distanceToCode σ.committedCochain :=
  le_trans σ.rsDistance_le_plane σ.previous.planeDistance_le_local

/--
The state bus composes the local metric handoffs: the selected RS target metric
is bounded by the source Plucker disagreement.
-/
theorem rsDistance_le_source
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {W : FrameWitness n r}
    (σ : StateBus Γ W) :
    D.distanceToRS σ.receivedWord ≤ pluckerDisagreement W :=
  le_trans σ.rsDistance_le_local σ.previous.previous.localDistance_le_source

end StateBus

/--
The local invariant checklists available from the three concrete stages of the
chain.
-/
structure StageChecklists
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement) : Prop where
  pluckerCochain :
    PluckerCochain.InvariantChecklist Γ.pluckerToCochain
  cochainPlane :
    CochainPlane.InvariantChecklist Γ.planeToRS.projection
  planeRS :
    CochainReedSolomon.InvariantChecklist Γ.planeToRS

namespace StageChecklists

/-- Every well-typed concrete chain carries the stage-local checklists. -/
def of_chain
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement) :
    StageChecklists Γ where
  pluckerCochain :=
    PluckerCochain.InvariantChecklist.of_projection Γ.pluckerToCochain
  cochainPlane :=
    CochainPlane.InvariantChecklist.of_projection Γ.planeToRS.projection
  planeRS :=
    CochainReedSolomon.InvariantChecklist.of_interpretation Γ.planeToRS

end StageChecklists

/--
Certificate after the Plucker-to-cochain gate.

This is the first accumulated certificate in the projection pipeline.
-/
structure PluckerCochainGateCertificate
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement) : Prop where
  pluckerCochain :
    PluckerCochain.InvariantChecklist Γ.pluckerToCochain

namespace PluckerCochainGateCertificate

/-- The Plucker-to-cochain gate emits the first accumulated certificate. -/
def of_chain
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement) :
    PluckerCochainGateCertificate Γ where
  pluckerCochain :=
    PluckerCochain.InvariantChecklist.of_projection Γ.pluckerToCochain

end PluckerCochainGateCertificate

/--
Certificate after the committed-cochain-to-plane gate.

It consumes the previous gate certificate and appends only the new plane
extraction certificate.
-/
structure CochainPlaneGateCertificate
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement) : Prop where
  previous : PluckerCochainGateCertificate Γ
  cochainPlane :
    CochainPlane.InvariantChecklist Γ.planeToRS.projection

namespace CochainPlaneGateCertificate

/-- Extend the accumulated certificate through the cochain-to-plane gate. -/
def extend
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (χ : PluckerCochainGateCertificate Γ) :
    CochainPlaneGateCertificate Γ where
  previous := χ
  cochainPlane :=
    CochainPlane.InvariantChecklist.of_projection Γ.planeToRS.projection

/-- Build the accumulated certificate through the cochain-to-plane gate. -/
def of_chain
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement) :
    CochainPlaneGateCertificate Γ :=
  CochainPlaneGateCertificate.extend (PluckerCochainGateCertificate.of_chain Γ)

end CochainPlaneGateCertificate

/--
Certificate after the plane-to-RS gate.

It consumes the cochain/plane certificate and appends only the RS interpretation
certificate.
-/
structure PlaneRSGateCertificate
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement) : Prop where
  previous : CochainPlaneGateCertificate Γ
  planeRS :
    CochainReedSolomon.InvariantChecklist Γ.planeToRS

namespace PlaneRSGateCertificate

/-- Extend the accumulated certificate through the plane-to-RS gate. -/
def extend
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (χ : CochainPlaneGateCertificate Γ) :
    PlaneRSGateCertificate Γ where
  previous := χ
  planeRS :=
    CochainReedSolomon.InvariantChecklist.of_interpretation Γ.planeToRS

/-- Build the accumulated certificate through the plane-to-RS gate. -/
def of_chain
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement) :
    PlaneRSGateCertificate Γ :=
  PlaneRSGateCertificate.extend (CochainPlaneGateCertificate.of_chain Γ)

/-- Recover the full stage checklist view from the accumulated gate certificate. -/
def toStageChecklists
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (χ : PlaneRSGateCertificate Γ) :
    StageChecklists Γ where
  pluckerCochain := χ.previous.previous.pluckerCochain
  cochainPlane := χ.previous.cochainPlane
  planeRS := χ.planeRS

end PlaneRSGateCertificate

/--
Final accumulated stage-gate certificate for the whole projection pipeline.

This is the stage-level certificate consumed by the proximity hard-gate layer.
Structural gates, final metric separation, and runtime evidence live outside
this module.
-/
structure ProjectionStageGateCertificate
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement) : Prop where
  final : PlaneRSGateCertificate Γ

namespace ProjectionStageGateCertificate

/-- Every well-typed concrete chain can expose the accumulated stage certificate. -/
def of_chain
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement) :
    ProjectionStageGateCertificate Γ where
  final := PlaneRSGateCertificate.of_chain Γ

/-- The accumulated certificate can still be viewed as explicit stage checklists. -/
def toStageChecklists
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (χ : ProjectionStageGateCertificate Γ) :
    StageChecklists Γ :=
  χ.final.toStageChecklists

end ProjectionStageGateCertificate

namespace PluckerCochainState

/-- Specialize the first uniform gate certificate to one witness. -/
def of_gateCertificate
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (χ : PluckerCochainGateCertificate Γ)
    (W : FrameWitness n r) :
    PluckerCochainState Γ W where
  committedCochain := Γ.committedCochain W
  committedCochain_matches := rfl
  localDistance_le_source := χ.pluckerCochain.distanceControlled W

end PluckerCochainState

namespace CochainPlaneState

/-- Append only the cochain-to-plane output and metric invariant. -/
def extend
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {W : FrameWitness n r}
    (σ : PluckerCochainState Γ W)
    (χ : CochainPlaneGateCertificate Γ) :
    CochainPlaneState Γ W where
  previous := σ
  planeShadow := E.projectedPlane σ.committedCochain
  planeShadow_matches := rfl
  planeDistance_le_local := by
    simpa [σ.committedCochain_matches] using
      χ.cochainPlane.distanceControlled (Γ.committedCochain W)

end CochainPlaneState

namespace StateBus

/--
Specialize an already-checked uniform stage certificate to one witness-local
state bus. No stage invariant is rechecked here.
-/
def of_stageCertificate
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (χ : ProjectionStageGateCertificate Γ)
    (W : FrameWitness n r) :
    StateBus Γ W := by
  let cochainState :=
    PluckerCochainState.of_gateCertificate χ.final.previous.previous W
  let planeState := CochainPlaneState.extend cochainState χ.final.previous
  exact
    { previous := planeState
      receivedWord := Φ.receivedWord planeState.planeShadow
      receivedWord_matches := rfl
      rsDistance_le_plane :=
        χ.final.planeRS.planeDistanceControlled planeState.planeShadow }

/-- Convenience constructor using the canonical accumulated stage certificate. -/
def of_chain
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement)
    (W : FrameWitness n r) :
    StateBus Γ W :=
  of_stageCertificate (ProjectionStageGateCertificate.of_chain Γ) W

end StateBus

end

end Projection
end Gates
end Proximity
end Hcrypt
