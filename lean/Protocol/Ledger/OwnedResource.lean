module

public import Protocol.Ledger.Transition
public import Mathlib.Data.Finsupp.Weight

@[expose] public section

/-!
# One conservative transfer of an owned resource

This bounded profile gives public natural-number resource identifiers an
immutable owner, asset and positive amount. One action consumes one identifier
and produces one different, absent and unspent identifier of the same value.
Its nullifier is the consumed identifier itself. This is a declared public-ID
profile, not an anonymous nullifier scheme or a global ledger architecture.

The original finite-marking flow and candidate update remain unchanged. The
profile derives availability, conservation, exact coordinates and preservation
of unit multiplicities/disjoint spent resources. Caller authentication, wire
encoding and cryptographic verification remain separate indexed contracts.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt.Protocol.Ledger.OwnedResource

/-- Fixed interpretation of each public resource identifier. -/
structure Catalog (Owner Asset : Type) where
  owner : ℕ → Owner
  asset : ℕ → Asset
  amount : ℕ → ℕ
  positive : ∀ id, 0 < amount id

/-- The declared owner moves one resource to a new resource identifier. -/
structure Transfer (Owner : Type) where
  input : ℕ
  output : ℕ
  signer : Owner

variable {Owner Asset : Type}

/-- Actual additive asset value of the finite resource inventory. -/
def values [DecidableEq Asset] (catalog : Catalog Owner Asset) : ValueModel ℕ Asset where
  value := Finsupp.weight fun id asset =>
    if catalog.asset id = asset then catalog.amount id else 0

theorem value_single [DecidableEq Asset] (catalog : Catalog Owner Asset)
    (id count : ℕ) (asset : Asset) :
    (values catalog).value (Finsupp.single id count) asset =
      count * if catalog.asset id = asset then catalog.amount id else 0 := by
  simp [values, Finsupp.weight_single]

namespace Transfer

def flow (transfer : Transfer Owner) : ResourceFlow ℕ where
  consumed := Finsupp.single transfer.input 1
  produced := Finsupp.single transfer.output 1

/-- The nullifier list is determined by the consumed resource, not supplied anew. -/
def action (transfer : Transfer Owner) (cochain : Axioms.CochainCommitmentData) :
    Action ℕ ℕ where
  flow := transfer.flow
  nullifiers := [transfer.input]
  cochain := cochain

theorem nullifiers_nonempty (transfer : Transfer Owner)
    (cochain : Axioms.CochainCommitmentData) :
    (transfer.action cochain).nullifiers ≠ [] := by simp [action]

theorem nullifiers_nodup (transfer : Transfer Owner)
    (cochain : Axioms.CochainCommitmentData) :
    (transfer.action cochain).nullifiers.Nodup := by simp [action]

end Transfer

/-- Concrete structural and ownership-label checks for this bounded transfer.
The signer/owner equality is not itself a signature-verification theorem. -/
structure Checks (catalog : Catalog Owner Asset) (transfer : Transfer Owner)
    (before : State ℕ ℕ) : Prop where
  signerOwner : transfer.signer = catalog.owner transfer.input
  input_ne_output : transfer.input ≠ transfer.output
  input_present : before.marking transfer.input = 1
  output_absent : before.marking transfer.output = 0
  input_fresh : transfer.input ∉ before.spent
  output_fresh : transfer.output ∉ before.spent
  same_asset : catalog.asset transfer.input = catalog.asset transfer.output
  same_amount : catalog.amount transfer.input = catalog.amount transfer.output

/-- Each identifier is present at most once, and no spent identifier is active. -/
structure InventoryInvariant (state : State ℕ ℕ) : Prop where
  atMostOne : ∀ id, state.marking id ≤ 1
  spentAbsent : ∀ id ∈ state.spent, state.marking id = 0

namespace Checks

variable {catalog : Catalog Owner Asset} {transfer : Transfer Owner}
  {before : State ℕ ℕ}

theorem enabled (checks : Checks catalog transfer before) :
    transfer.flow.Enabled before.marking := by
  intro id
  by_cases h : id = transfer.input
  · subst id
    simp [Transfer.flow, checks.input_present]
  · simp [Transfer.flow, h]

theorem conserves [DecidableEq Asset] (checks : Checks catalog transfer before) :
    transfer.flow.Conserves (values catalog) := by
  funext asset
  simp [Transfer.flow, value_single, checks.same_asset, checks.same_amount]

theorem fresh (checks : Checks catalog transfer before)
    (cochain : Axioms.CochainCommitmentData) :
    Nullifiers.Fresh before.spent (transfer.action cochain).nullifiers := by
  intro id h
  have hid : id = transfer.input := by simpa [Transfer.action] using h
  subst id
  exact checks.input_fresh

/-- Consumption removes the actual input, using its checked multiplicity one. -/
theorem flow_input (checks : Checks catalog transfer before) :
    transfer.flow.apply before.marking transfer.input = 0 := by
  simp [ResourceFlow.apply, Transfer.flow,
    checks.input_present, checks.input_ne_output]

/-- Production creates exactly one copy of the checked fresh output. -/
theorem flow_output (checks : Checks catalog transfer before) :
    transfer.flow.apply before.marking transfer.output = 1 := by
  simp [ResourceFlow.apply, Transfer.flow,
    checks.output_absent, Ne.symm checks.input_ne_output]

theorem flow_other (_checks : Checks catalog transfer before) (id : ℕ)
    (input_ne : id ≠ transfer.input) (output_ne : id ≠ transfer.output) :
    transfer.flow.apply before.marking id = before.marking id := by
  simp [ResourceFlow.apply, Transfer.flow, input_ne, output_ne]

variable {Snapshot : Type*} {candidate : Candidate ℕ ℕ Snapshot}
  {cochain : Axioms.CochainCommitmentData}

theorem after_input (checks : Checks catalog transfer candidate.before)
    (action_eq : candidate.action = transfer.action cochain) :
    candidate.after.marking transfer.input = 0 := by
  simpa only [Candidate.after, action_eq, Transfer.action] using checks.flow_input

theorem after_output (checks : Checks catalog transfer candidate.before)
    (action_eq : candidate.action = transfer.action cochain) :
    candidate.after.marking transfer.output = 1 := by
  simpa only [Candidate.after, action_eq, Transfer.action] using checks.flow_output

theorem after_other (checks : Checks catalog transfer candidate.before)
    (action_eq : candidate.action = transfer.action cochain) (id : ℕ)
    (input_ne : id ≠ transfer.input) (output_ne : id ≠ transfer.output) :
    candidate.after.marking id = candidate.before.marking id := by
  simpa only [Candidate.after, action_eq, Transfer.action] using
    checks.flow_other id input_ne output_ne

/-- The actual kernel update preserves the unit-resource and spent-disjointness laws. -/
theorem preserves_inventory (checks : Checks catalog transfer candidate.before)
    (action_eq : candidate.action = transfer.action cochain)
    (prior : InventoryInvariant candidate.before) : InventoryInvariant candidate.after := by
  constructor
  · intro id
    by_cases hi : id = transfer.input
    · subst id
      rw [checks.after_input action_eq]
      omega
    · by_cases ho : id = transfer.output
      · subst id
        rw [checks.after_output action_eq]
      · rw [checks.after_other action_eq id hi ho]
        exact prior.atMostOne id
  · intro id hspent
    have cases : id ∈ candidate.before.spent ∨ id = transfer.input := by
      change id ∈ Nullifiers.consume candidate.before.spent candidate.action.nullifiers at hspent
      simpa [action_eq, Transfer.action, Nullifiers.consume, or_comm] using hspent
    rcases cases with hprior | rfl
    · have hi : id ≠ transfer.input := by
        intro heq
        exact checks.input_fresh (heq ▸ hprior)
      have ho : id ≠ transfer.output := by
        intro heq
        exact checks.output_fresh (heq ▸ hprior)
      rw [checks.after_other action_eq id hi ho]
      exact prior.spentAbsent id hprior
    · exact checks.after_input action_eq

/-- The source ID is recorded as spent by the actual action-derived update. -/
theorem input_spent_after (_checks : Checks catalog transfer candidate.before)
    (action_eq : candidate.action = transfer.action cochain) :
    transfer.input ∈ candidate.after.spent := by
  apply candidate.nullifier_mem_after
  simp [action_eq, Transfer.action]

/-- Another request cannot spend the same input under a new proposal or signer. -/
theorem reused_input_rejected (checks : Checks catalog transfer candidate.before)
    (action_eq : candidate.action = transfer.action cochain) (next : Transfer Owner)
    (same_input : next.input = transfer.input) :
    ¬ Checks catalog next candidate.after := by
  intro nextChecks
  apply nextChecks.input_fresh
  rw [same_input]
  exact checks.input_spent_after action_eq

/-- A consumed identifier cannot be resurrected as a later output. -/
theorem reused_output_rejected (checks : Checks catalog transfer candidate.before)
    (action_eq : candidate.action = transfer.action cochain) (next : Transfer Owner)
    (same_output : next.output = transfer.input) :
    ¬ Checks catalog next candidate.after := by
  intro nextChecks
  apply nextChecks.output_fresh
  rw [same_output]
  exact checks.input_spent_after action_eq

end Checks

namespace Fixture

/-- Positive asset amounts and distinct owners, without any runtime/authentication fixture. -/
def catalog : Catalog (Fin 2) Unit where
  owner id := if id = 0 then 0 else 1
  asset _ := ()
  amount _ := 7
  positive _ := by omega

def transfer : Transfer (Fin 2) where
  input := 0
  output := 1
  signer := 0

/-- Preserve every supplied header coordinate; choose only the arithmetic inventory. -/
def before (header : State ℕ ℕ) : State ℕ ℕ :=
  { header with marking := Finsupp.single 0 1, spent := ∅ }

theorem checks (header : State ℕ ℕ) : Checks catalog transfer (before header) := by
  constructor <;> simp [catalog, transfer, before]

theorem inventory (header : State ℕ ℕ) : InventoryInvariant (before header) := by
  constructor
  · intro id
    by_cases h : id = 0
    · subst id
      simp [before]
    · simp [before, h]
  · intro id h
    simp [before] at h

def candidate {Snapshot : Type*} (header : State ℕ ℕ)
    (cochain : Axioms.CochainCommitmentData) (snapshot : Snapshot)
    (proposal : Consensus.ProposalRef) : Candidate ℕ ℕ Snapshot where
  before := before header
  action := transfer.action cochain
  snapshot := snapshot
  proposal := proposal

theorem after_marking {Snapshot : Type*} (header : State ℕ ℕ)
    (cochain : Axioms.CochainCommitmentData) (snapshot : Snapshot)
    (proposal : Consensus.ProposalRef) :
    (candidate header cochain snapshot proposal).after.marking = Finsupp.single 1 1 := by
  simp [candidate, Candidate.after, Transfer.action, Transfer.flow, before, transfer,
    ResourceFlow.apply]

theorem before_value (header : State ℕ ℕ) :
    (values catalog).value (before header).marking () = 7 := by
  simp [before, value_single, catalog]

theorem after_value {Snapshot : Type*} (header : State ℕ ℕ)
    (cochain : Axioms.CochainCommitmentData) (snapshot : Snapshot)
    (proposal : Consensus.ProposalRef) :
    (values catalog).value (candidate header cochain snapshot proposal).after.marking () = 7 := by
  rw [after_marking]
  simp [value_single, catalog]

end Fixture

end Hcrypt.Protocol.Ledger.OwnedResource
