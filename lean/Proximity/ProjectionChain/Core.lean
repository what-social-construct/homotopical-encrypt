import Proximity.CochainPlane.ReedSolomon

/-
  Core projection-chain orchestrator.

  Paper correspondence:
  - Paper 1 Section 6: composed Plucker/cochain/plane/RS projection chain.
  - Paper 1 appendix ledger: projection-chain theorem-surface row.

  This file only composes the already-defined local stages:

    Plucker frame witness -> committed cochain -> plane shadow -> RS word

  Stage gate certificates, final metric checks, and runtime evidence records
  live in separate files.
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
`planeToRS` owns an explicit semantic plane target, the committed-cochain to
plane projection, and the later finite-field RS interpretation.
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
  Φ.receivedWord (Γ.planeShadow W)

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
    have hPlane :
        Γ.planeToRS.planeTarget.Codeword (Γ.planeShadow W) :=
      Γ.planeToRS.projection.mapsCodewordsToTarget
        (Γ.committedCochain W) hLocal
    exact Γ.planeToRS.mapsPlaneCodewordsToRS (Γ.planeShadow W) hPlane
  distanceControlled := by
    intro W
    have hRSPlane :
        D.distanceToRS (Γ.receivedWord W) ≤
          Γ.planeToRS.planeTarget.distanceToCode (Γ.planeShadow W) :=
      Γ.planeToRS.distanceControlled (Γ.planeShadow W)
    have hPlaneLocal :
        Γ.planeToRS.planeTarget.distanceToCode (Γ.planeShadow W) ≤
          L.distanceToCode (Γ.committedCochain W) :=
      Γ.planeToRS.projection.distanceControlled (Γ.committedCochain W)
    have hRSLocal :
        D.distanceToRS (Γ.receivedWord W) ≤
          L.distanceToCode (Γ.committedCochain W) :=
      le_trans hRSPlane hPlaneLocal
    have hLocal :
        L.distanceToCode (Γ.committedCochain W) ≤ pluckerDisagreement W :=
      Γ.pluckerToCochain.distanceControlled W
    exact le_trans hRSLocal hLocal

end Chain

end

end ProjectionChain
end Proximity
end Hcrypt
