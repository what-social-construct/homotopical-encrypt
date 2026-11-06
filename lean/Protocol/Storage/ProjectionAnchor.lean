module

public import Protocol.Storage.Anchor
public import Protocol.Storage.Projection

@[expose] public section

/-!
# A stored projection manifest anchored to its actual ledger candidate

The generic transition anchor joins the original snapshot and public artifact
to the accepted candidate. This adapter uses the existing `SealedProjection`,
whose exact manifest list is one final typed prefix, and adds an explicit
inclusion relation for its actual gate database under the candidate's evidence
root. Inclusion does not identify the gate, manifest, cochain or snapshot roots.

The relations remain authentication-profile inputs. This file defines no hash
algorithm, persistent backend, geometry update, radius profile or security game.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt.Protocol.Storage

open Sheaf CellularSheaf
open Hcrypt.Proximity
open Hcrypt.Proximity.GrassmannianPlucker
open Hcrypt.Proximity.Gates.Projection
open Hcrypt.Proximity.GateEvidence.Projection

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {Fsheaf : CellularSheaf X}
  {Resource Nullifier Asset : Type} [DecidableEq Nullifier]
  {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
  {R K ι : Type} [Field K] [Fintype K] [Fintype ι] [DecidableEq K]
  {P : FramedSystem n r} {S : Axioms.SheafCoherence}
  {L : PluckerCochain.LocalSyndromeTarget S}
  {T : ReedSolomonTarget.Target K ι}
  {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
  {E : CochainPlane.PlaneExtractionContext R ι}
  {Φ : CochainReedSolomon.PlaneEncoding R K}
  {sourceDisagreement : FrameWitness n r → ℝ}
  {Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement}
  {W : FrameWitness n r}
  {C : Context Fsheaf} {input : Projection.Input C Γ W}
  {runtime : TCB.RuntimeBoundary} {κ : RadiusCalibration}
  {Receipt : Type*}
  {scheme : CheckpointScheme Fsheaf Projection.Stage
    (Projection.Payload runtime Γ κ W) Receipt}
  {policy : Ledger.Policy Resource Nullifier Asset (CochainPayloadInterpretation Fsheaf)}
  {bindings : Evidence.RootBindings Resource Nullifier (CochainPayloadInterpretation Fsheaf)}
  {candidate : Ledger.Candidate Resource Nullifier (CochainPayloadInterpretation Fsheaf)}

/-- The actual stored projection and its gate database refer to the same candidate.
The inclusion relation is indexed by the database object, not just its digest. -/
structure ProjectionAnchor
    (topologyBinds : SheafStateSnapshot Fsheaf → TCB.Hash32 → Prop)
    (history : HistoryBindings Fsheaf Resource Nullifier Projection.Stage
      (Projection.Payload runtime Γ κ W))
    (gateEvidenceIncluded :
      Ledger.Candidate Resource Nullifier (CochainPayloadInterpretation Fsheaf) →
        EvidenceDatabase runtime → TCB.Hash32 → Prop)
    (evidence : Evidence.Transition runtime policy bindings candidate)
    (block : Projection.SealedProjection input runtime κ scheme) where
  anchor : TransitionAnchor topologyBinds history evidence C block.sealed
  gateIncluded : gateEvidenceIncluded candidate
    block.evidence.naturalityGateRecord.hardGateRecord.database
    candidate.proposal.evidenceRoot

namespace ProjectionAnchor

variable
  {topologyBinds : SheafStateSnapshot Fsheaf → TCB.Hash32 → Prop}
  {history : HistoryBindings Fsheaf Resource Nullifier Projection.Stage
    (Projection.Payload runtime Γ κ W)}
  {gateEvidenceIncluded :
    Ledger.Candidate Resource Nullifier (CochainPayloadInterpretation Fsheaf) →
      EvidenceDatabase runtime → TCB.Hash32 → Prop}
  {evidence : Evidence.Transition runtime policy bindings candidate}
  {block : Projection.SealedProjection input runtime κ scheme}

/-- Exactness follows from the existing accepted transition and its original artifact. -/
theorem accepted
    (a : ProjectionAnchor topologyBinds history gateEvidenceIncluded evidence block) :
    C.Accepted :=
  a.anchor.accepted

/-- The stored RS state carries the original context's exact same payload. -/
theorem cochain_matches
    (_a : ProjectionAnchor topologyBinds history gateEvidenceIncluded evidence block) :
    block.state.committedCochain = C.cochain :=
  block.cochain_matches

/-- The accepted ledger action uses that very stored projection payload. -/
theorem candidate_cochain_matches
    (a : ProjectionAnchor topologyBinds history gateEvidenceIncluded evidence block) :
    candidate.action.cochain = block.state.committedCochain :=
  a.anchor.cochain_matches.trans block.cochain_matches.symm

/-- The stored RS word is the existing encoding extracted from that original payload. -/
theorem word_matches
    (_a : ProjectionAnchor topologyBinds history gateEvidenceIncluded evidence block) :
    block.state.receivedWord = Φ.receivedWord (E.projectedPlane C.cochain) :=
  block.word_matches

/-- The stored RS word also comes from the exact same accepted ledger action. -/
theorem word_matches_candidate
    (a : ProjectionAnchor topologyBinds history gateEvidenceIncluded evidence block) :
    block.state.receivedWord =
      Φ.receivedWord (E.projectedPlane candidate.action.cochain) := by
  rw [a.anchor.cochain_matches]
  exact block.word_matches

/-- History authenticates the exact leaves of the final typed prefix, rather than
an unrelated list whose stage names are merely all present. -/
theorem exact_prefix_anchored
    (a : ProjectionAnchor topologyBinds history gateEvidenceIncluded evidence block) :
    history.manifestIncluded candidate C
      ((Projection.Prefix.final block.state block.evidence :
        Projection.Prefix input runtime κ).items block.digests)
      block.sealed.root candidate.proposal.blockDigest := by
  rw [← block.itemsMatch]
  exact a.anchor.manifestIncluded

/-- The manifest root binds the exact same final prefix included in history. -/
theorem exact_prefix_bound
    (_a : ProjectionAnchor topologyBinds history gateEvidenceIncluded evidence block) :
    scheme.manifestBound C
      ((Projection.Prefix.final block.state block.evidence :
        Projection.Prefix input runtime κ).items block.digests)
      block.sealed.root := by
  rw [← block.itemsMatch]
  exact block.sealed.rootBound

/-- The actual gate database is included under the candidate's evidence root.
The root may surround this database together with other authenticated evidence. -/
theorem gate_database_included
    (a : ProjectionAnchor topologyBinds history gateEvidenceIncluded evidence block) :
    gateEvidenceIncluded candidate
      block.evidence.naturalityGateRecord.hardGateRecord.database
      candidate.proposal.evidenceRoot :=
  a.gateIncluded

/-- The existing accumulated state/certificate object is retained without rebuilding it. -/
def certifiedStateBus
    (_a : ProjectionAnchor topologyBinds history gateEvidenceIncluded evidence block) :
    CertifiedStateBus Γ κ W :=
  block.certifiedStateBus

@[simp]
theorem certifiedStateBus_state
    (a : ProjectionAnchor topologyBinds history gateEvidenceIncluded evidence block) :
    a.certifiedStateBus.state = block.state :=
  rfl

/-- The original far-region theorem still requires its original source-farness premise.
Storage anchoring supplies neither a new source metric nor a nonempty far family. -/
theorem target_far
    (_a : ProjectionAnchor topologyBinds history gateEvidenceIncluded evidence block)
    (hfar : κ.sourceFarRadius ≤ sourceDisagreement W) :
    κ.targetFarRadius ≤ D.distanceToRS block.state.receivedWord :=
  block.target_far hfar

end ProjectionAnchor

end Hcrypt.Protocol.Storage
