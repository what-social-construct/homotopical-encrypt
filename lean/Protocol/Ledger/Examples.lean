module

public import Protocol.Ledger.Transition

@[expose] public section

/-!
Small positive and adversarial examples for the conservative transition kernel.

The fixture uses an explicit payload-only authorization policy and an explicit
snapshot relation. It exercises the mathematical kernel without asserting
production ownership, runtime verification, hash security, or quorum finality.
-/

namespace HomotopicalEncryption.Protocol.Ledger.Examples

noncomputable section

/-- Distinct concrete hash values for the fixture's public coordinates. -/
def hash (n : UInt8) : TCB.Hash32 := fun _ => n

/-- One unit of the same asset is assigned to either resource position. -/
def values : ValueModel (Fin 2) Unit where
  value :=
    { toFun := fun marking _ => marking 0 + marking 1
      map_zero' := by
        funext asset
        simp
      map_add' := by
        intro marking₁ marking₂
        funext asset
        change (marking₁ 0 + marking₂ 0) + (marking₁ 1 + marking₂ 1) =
          (marking₁ 0 + marking₁ 1) + (marking₂ 0 + marking₂ 1)
        omega }

/-- Reuse the existing one-edge zero cochain payload, whose edge list is `[0]`. -/
def payload : Axioms.CochainCommitmentData :=
  Axioms.CochainCommitmentData.zero 1

theorem payload_wellFormed : payload.WellFormed :=
  Axioms.CochainCommitmentData.zero_wellFormed (by decide)

def initialMarking : Marking (Fin 2) := Finsupp.single 0 1

def transfer : ResourceFlow (Fin 2) where
  consumed := Finsupp.single 0 1
  produced := Finsupp.single 1 1

theorem transfer_enabled : transfer.Enabled initialMarking :=
  le_refl _

theorem transfer_conserves : transfer.Conserves values := by
  funext asset
  simp [values, transfer]

def before : State (Fin 2) ℕ where
  marking := initialMarking
  spent := ∅
  tipHash := hash 3
  height := 0
  epoch := 0
  snapshotRoot := hash 1
  topologyRoot := hash 2
  cochainRoot := hash 4
  evidenceRoot := hash 5

def action : Action (Fin 2) ℕ where
  flow := transfer
  nullifiers := [7]
  cochain := payload

def proposal : Consensus.ProposalRef where
  committeeDigest := hash 6
  epoch := 0
  height := 1
  round := 0
  phase := 0
  blockDigest := hash 7
  parentDigest := hash 3
  beforeStateRoot := hash 8
  afterStateRoot := hash 9
  snapshotRoot := hash 1
  topologyRoot := hash 2
  cochainRoot := hash 10
  evidenceRoot := hash 11

def candidate : Candidate (Fin 2) ℕ Unit where
  before := before
  action := action
  snapshot := ()
  proposal := proposal

/-- Fixture relations are indexed by the payload and topology actually named. -/
def policy : Policy (Fin 2) ℕ Unit Unit where
  values := values
  snapshots :=
    { root := fun _ => hash 1
      accepts := fun _ cochain => cochain = payload
      topologyBound := fun _ root => root = hash 2 }
  authorized := fun c => c.action.cochain = payload

theorem candidate_valid : candidate.Valid policy := by
  refine
    { authorized := rfl
      nullifiersNonempty := by decide
      nullifiersNodup := by decide
      fresh := ?_
      enabled := transfer_enabled
      conserves := transfer_conserves
      cochainWellFormed := payload_wellFormed
      snapshotAccepted := rfl
      epochMatches := rfl
      heightMatches := rfl
      parentMatches := rfl
      snapshotMatches := rfl
      beforeSnapshotMatches := rfl
      topologyMatches := rfl
      topologyBound := rfl }
  intro n _
  simp [candidate, before]

/-- The computed update moves the token to resource position one. -/
theorem after_marking : candidate.after.marking = Finsupp.single 1 1 := by
  simp [Candidate.after, candidate, before, action, ResourceFlow.apply,
    initialMarking, transfer]

/-- The fixture has genuinely positive value, rather than a zero valuation. -/
theorem initial_value : values.value candidate.before.marking () = 1 := by
  simp [values, candidate, before, initialMarking]

/-- Conservation uses the general theorem about the actual update. -/
theorem value_preserved :
    values.value candidate.after.marking = values.value candidate.before.marking :=
  candidate.value_after policy candidate_valid

theorem nullifier_consumed : 7 ∈ candidate.after.spent :=
  candidate.nullifier_mem_after (by simp [candidate, action])

/-- Replacing proposal metadata cannot make the same consumed action valid again. -/
theorem replay_rejected (nextProposal : Consensus.ProposalRef) :
    ¬ ({ candidate with before := candidate.after, proposal := nextProposal }).Valid policy :=
  candidate.not_valid_replay policy candidate_valid nextProposal

def overspend : Candidate (Fin 2) ℕ Unit :=
  { candidate with
    action := { action with
      flow := { consumed := Finsupp.single 0 2, produced := Finsupp.single 1 2 } } }

/-- Balanced value totals do not permit consuming more resources than are held. -/
theorem overspend_rejected : ¬ overspend.Valid policy := by
  intro h
  have hAvailable := h.enabled (0 : Fin 2)
  norm_num [overspend, candidate, before, initialMarking] at hAvailable

def unbalanced : Candidate (Fin 2) ℕ Unit :=
  { candidate with
    action := { action with
      flow := { consumed := Finsupp.single 0 1, produced := Finsupp.single 1 2 } } }

theorem unbalanced_rejected : ¬ unbalanced.Valid policy := by
  intro h
  have hValue := congrFun h.conserves ()
  norm_num [unbalanced, policy, values] at hValue

def duplicateUses : Candidate (Fin 2) ℕ Unit :=
  { candidate with action := { action with nullifiers := [7, 7] } }

theorem duplicate_uses_rejected : ¬ duplicateUses.Valid policy := by
  intro h
  have hNodup := h.nullifiersNodup
  simp [duplicateUses] at hNodup

def emptyUses : Candidate (Fin 2) ℕ Unit :=
  { candidate with action := { action with nullifiers := [] } }

theorem empty_uses_rejected : ¬ emptyUses.Valid policy := by
  intro h
  exact h.nullifiersNonempty rfl

def wrongParent : Candidate (Fin 2) ℕ Unit :=
  { candidate with proposal := { proposal with parentDigest := hash 99 } }

theorem wrong_parent_rejected : ¬ wrongParent.Valid policy := by
  intro h
  have hRoot : (99 : UInt8) = 3 := congrFun h.parentMatches 0
  exact (by decide : (99 : UInt8) ≠ 3) hRoot

def wrongSnapshot : Candidate (Fin 2) ℕ Unit :=
  { candidate with proposal := { proposal with snapshotRoot := hash 99 } }

theorem wrong_snapshot_rejected : ¬ wrongSnapshot.Valid policy := by
  intro h
  have hRoot : (99 : UInt8) = 1 := congrFun h.snapshotMatches 0
  exact (by decide : (99 : UInt8) ≠ 1) hRoot

end

end HomotopicalEncryption.Protocol.Ledger.Examples
