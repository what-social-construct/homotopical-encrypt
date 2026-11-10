module

public import Protocol.Ledger.State
public import Protocol.Consensus.Vote

@[expose] public section

/-!
# Conservative candidate transitions

One action carries its resource flow, its actual nullifier list, and the
existing cochain payload. The after-state is computed from those data.
Validity checks resource availability, exact value conservation, fresh
duplicate-free consumption, snapshot/payload acceptance and proposal context.
Authorization remains an explicit predicate indexed by this entire candidate.

The first endpoint is conservative: any fees are among produced resources.
Mint/burn rules, concrete resource ownership, and cryptographic nullifier
derivation need their own application profile. They are not inferred from
cochain linearity or the raw edge-value sum.
-/

namespace HomotopicalEncryption.Protocol.Ledger

/-- The body whose flow, replay identifiers and cochain are authenticated. -/
structure Action (Resource Nullifier : Type) where
  flow : ResourceFlow Resource
  nullifiers : List Nullifier
  cochain : Axioms.CochainCommitmentData

/-- One proposed state transition and its existing consensus reference. -/
structure Candidate (Resource Nullifier : Type) (Snapshot : Type*) where
  before : State Resource Nullifier
  action : Action Resource Nullifier
  snapshot : Snapshot
  proposal : Consensus.ProposalRef

/-- Application interpretation and authorization for this bounded kernel. -/
structure Policy (Resource Nullifier Asset : Type) (Snapshot : Type*) where
  values : ValueModel Resource Asset
  snapshots : SnapshotModel Snapshot
  authorized : Candidate Resource Nullifier Snapshot → Prop

namespace Candidate

variable {Resource Nullifier Asset : Type} {Snapshot : Type*}
variable [DecidableEq Nullifier]

/-- Actual update. No independently supplied after-state can be substituted. -/
noncomputable def after (c : Candidate Resource Nullifier Snapshot) :
    State Resource Nullifier where
  marking := c.action.flow.apply c.before.marking
  spent := Nullifiers.consume c.before.spent c.action.nullifiers
  tipHash := c.proposal.blockDigest
  height := c.before.height + 1
  epoch := c.before.epoch
  snapshotRoot := c.before.snapshotRoot
  topologyRoot := c.before.topologyRoot
  cochainRoot := c.proposal.cochainRoot
  evidenceRoot := c.proposal.evidenceRoot

/-- Concrete validity of this action and context, not an arbitrary statement.
The evidence layer derives this proposition from the accepted TCB observation.
-/
structure Valid (c : Candidate Resource Nullifier Snapshot)
    (P : Policy Resource Nullifier Asset Snapshot) : Prop where
  authorized : P.authorized c
  nullifiersNonempty : c.action.nullifiers ≠ []
  nullifiersNodup : c.action.nullifiers.Nodup
  fresh : Nullifiers.Fresh c.before.spent c.action.nullifiers
  enabled : c.action.flow.Enabled c.before.marking
  conserves : c.action.flow.Conserves P.values
  cochainWellFormed : c.action.cochain.WellFormed
  snapshotAccepted : P.snapshots.accepts c.snapshot c.action.cochain
  epochMatches : c.proposal.epoch = c.before.epoch
  heightMatches : c.proposal.height = c.before.height + 1
  parentMatches : c.proposal.parentDigest = c.before.tipHash
  snapshotMatches : c.proposal.snapshotRoot = P.snapshots.root c.snapshot
  beforeSnapshotMatches : P.snapshots.root c.snapshot = c.before.snapshotRoot
  topologyMatches : c.proposal.topologyRoot = c.before.topologyRoot
  topologyBound : P.snapshots.topologyBound c.snapshot c.proposal.topologyRoot

/-- Conservation is derived from the actual finite-resource update. -/
theorem value_after (c : Candidate Resource Nullifier Snapshot)
    (P : Policy Resource Nullifier Asset Snapshot) (h : c.Valid P) :
    P.values.value c.after.marking = P.values.value c.before.marking :=
  c.action.flow.value_apply P.values c.before.marking h.enabled h.conserves

/-- Previously consumed identifiers remain consumed. -/
theorem spent_subset_after (c : Candidate Resource Nullifier Snapshot) :
    c.before.spent ⊆ c.after.spent :=
  Nullifiers.spent_subset_consume c.before.spent c.action.nullifiers

/-- Every identifier named by the actual action is consumed by its update. -/
theorem nullifier_mem_after (c : Candidate Resource Nullifier Snapshot)
    {n : Nullifier} (hn : n ∈ c.action.nullifiers) : n ∈ c.after.spent :=
  Nullifiers.mem_consume_of_mem c.before.spent hn

/-- A fresh proposal cannot make the same nonempty action replayable. -/
theorem not_valid_replay (c : Candidate Resource Nullifier Snapshot)
    (P : Policy Resource Nullifier Asset Snapshot) (h : c.Valid P)
    (proposal : Consensus.ProposalRef) :
    ¬ ({ c with before := c.after, proposal := proposal }).Valid P := by
  intro hReplay
  exact Nullifiers.not_fresh_consume c.before.spent c.action.nullifiers
    h.nullifiersNonempty hReplay.fresh

/-- Proposal coordinates identify the resulting public context. -/
theorem after_matches_proposal (c : Candidate Resource Nullifier Snapshot)
    (P : Policy Resource Nullifier Asset Snapshot) (h : c.Valid P) :
    c.after.height = c.proposal.height ∧
    c.after.epoch = c.proposal.epoch ∧
    c.after.snapshotRoot = c.proposal.snapshotRoot ∧
    c.after.topologyRoot = c.proposal.topologyRoot ∧
    c.after.cochainRoot = c.proposal.cochainRoot ∧
    c.after.evidenceRoot = c.proposal.evidenceRoot := by
  exact ⟨h.heightMatches.symm, h.epochMatches.symm,
    (h.snapshotMatches.trans h.beforeSnapshotMatches).symm,
    h.topologyMatches.symm, rfl, rfl⟩

end Candidate

variable {Resource Nullifier Asset : Type} {Snapshot : Type*}
variable [DecidableEq Nullifier]

/-- Accepted application relates the stated source and the computed result. -/
def AcceptedUpdate (P : Policy Resource Nullifier Asset Snapshot)
    (before : State Resource Nullifier)
    (c : Candidate Resource Nullifier Snapshot)
    (after : State Resource Nullifier) : Prop :=
  c.before = before ∧ c.Valid P ∧ after = c.after

namespace AcceptedUpdate

theorem deterministic {P : Policy Resource Nullifier Asset Snapshot}
    {before : State Resource Nullifier} {c : Candidate Resource Nullifier Snapshot}
    {after₁ after₂ : State Resource Nullifier}
    (h₁ : AcceptedUpdate P before c after₁)
    (h₂ : AcceptedUpdate P before c after₂) : after₁ = after₂ :=
  h₁.2.2.trans h₂.2.2.symm

theorem value_preserved {P : Policy Resource Nullifier Asset Snapshot}
    {before after : State Resource Nullifier} {c : Candidate Resource Nullifier Snapshot}
    (h : AcceptedUpdate P before c after) :
    P.values.value after.marking = P.values.value before.marking := by
  rcases h with ⟨rfl, hValid, rfl⟩
  exact c.value_after P hValid

theorem spent_monotone {P : Policy Resource Nullifier Asset Snapshot}
    {before after : State Resource Nullifier} {c : Candidate Resource Nullifier Snapshot}
    (h : AcceptedUpdate P before c after) : before.spent ⊆ after.spent := by
  rcases h with ⟨rfl, _, rfl⟩
  exact c.spent_subset_after

end AcceptedUpdate

/-- A connected sequence of valid computed updates. This does not assert finality. -/
inductive Execution (P : Policy Resource Nullifier Asset Snapshot) :
    State Resource Nullifier → State Resource Nullifier → Prop where
  | refl (s) : Execution P s s
  | step {start current} (prior : Execution P start current)
      (c : Candidate Resource Nullifier Snapshot)
      (sourceMatches : c.before = current) (valid : c.Valid P) :
      Execution P start c.after

namespace Execution

theorem value_preserved {P : Policy Resource Nullifier Asset Snapshot}
    {start finish : State Resource Nullifier} (h : Execution P start finish) :
    P.values.value finish.marking = P.values.value start.marking := by
  induction h with
  | refl => rfl
  | step prior c hSource hValid ih =>
    exact (c.value_after P hValid).trans (by simpa only [hSource] using ih)

theorem spent_monotone {P : Policy Resource Nullifier Asset Snapshot}
    {start finish : State Resource Nullifier} (h : Execution P start finish) :
    start.spent ⊆ finish.spent := by
  induction h with
  | refl => exact Finset.Subset.refl _
  | step prior c hSource hValid ih =>
    exact Finset.Subset.trans (by simpa only [hSource] using ih) c.spent_subset_after

end Execution

end HomotopicalEncryption.Protocol.Ledger
