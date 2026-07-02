import Proximity.ProjectionChain.Core

/-
  Stage-gate certificates for a projection chain.

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

/--
Internal projection-chain state bus for one source witness.

The committed cochain is the inherited hcrypt commitment payload
`Axioms.CochainCommitmentData` through `CochainBridge.CommittedCochain`. The
gate layer carries that payload forward into the plane shadow and RS received
word, together with the local metric handoff facts between the native metrics
at each gate.
-/
structure StateBus
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement)
    (W : FrameWitness n r) where
  committedCochain : CochainBridge.CommittedCochain
  planeShadow : CochainPlane.PlaneShadow R ι
  receivedWord : Word ι F
  committedCochain_matches :
    committedCochain = Γ.committedCochain W
  planeShadow_matches :
    planeShadow = E.projectedPlane committedCochain
  receivedWord_matches :
    receivedWord = Φ.receivedWord planeShadow
  localDistance_le_source :
    L.distanceToCode committedCochain ≤ pluckerDisagreement W
  rsDistance_le_local :
    D.distanceToRS receivedWord ≤ L.distanceToCode committedCochain

namespace StateBus

/-- The canonical state bus produced by a projection chain at a witness. -/
def of_chain
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement)
    (W : FrameWitness n r) :
    StateBus Γ W where
  committedCochain := Γ.committedCochain W
  planeShadow := Γ.planeShadow W
  receivedWord := Γ.receivedWord W
  committedCochain_matches := rfl
  planeShadow_matches := rfl
  receivedWord_matches := rfl
  localDistance_le_source := Γ.pluckerToCochain.distanceControlled W
  rsDistance_le_local := Γ.planeToRS.projection.distanceControlled (Γ.committedCochain W)

/--
The state bus composes the local metric handoffs: the selected RS target metric
is bounded by the source Plucker disagreement.
-/
theorem rsDistance_le_source
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {W : FrameWitness n r}
    (σ : StateBus Γ W) :
    D.distanceToRS σ.receivedWord ≤ pluckerDisagreement W :=
  le_trans σ.rsDistance_le_local σ.localDistance_le_source

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

end

end Projection
end Gates
end Proximity
end Hcrypt
