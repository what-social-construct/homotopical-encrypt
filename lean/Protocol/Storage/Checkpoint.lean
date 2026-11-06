module

public import Protocol.Storage.Context
public import Mathlib.Data.List.Nodup

@[expose] public section

/-!
# Context-indexed append-once manifests and checkpoint lifecycle

Every entry carries its actual typed payload and digest. Authentication and
backend persistence relations are indexed by the original `Context`, exact
entry list and root. Sealing fixes a complete manifest but does not claim
durability. Consumption requires a receipt for that very sealed object.

The generic engine proves slot uniqueness and lifecycle properties only.
Concrete projection adapters supply the dependent slot payloads and their
mathematical prerequisite certificates. Canonical bytes, hash security and
disk/crash guarantees remain explicit profile/runtime obligations. `Payload`
is a semantic carrier; a profile chooses its public encoding rather than
serializing private witness fields merely because a Lean record retains them.
-/

set_option autoImplicit false

namespace Hcrypt.Protocol.Storage

open Sheaf CellularSheaf

universe u v w

/-- One typed manifest leaf, retaining its actual payload and digest. -/
structure ManifestItem (Slot : Type u) (Payload : Slot → Type v) where
  slot : Slot
  payload : Payload slot
  digest : TCB.Hash32

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}

/-- Object-indexed authentication and backend contracts for one storage profile. -/
structure CheckpointScheme
    (F : CellularSheaf X)
    (Slot : Type u) (Payload : Slot → Type v) (Receipt : Type w) where
  requiredSlots : Finset Slot
  entryBound : (C : Context F) → (slot : Slot) → Payload slot → TCB.Hash32 → Prop
  manifestBound : Context F → List (ManifestItem Slot Payload) → TCB.Hash32 → Prop
  persisted : Context F → List (ManifestItem Slot Payload) → TCB.Hash32 → Receipt → Prop

variable {F : CellularSheaf X}
  {Slot : Type u} {Payload : Slot → Type v} {Receipt : Type w}

/-- A leaf authenticated for this exact original sheaf context. -/
structure ManifestEntry
    (S : CheckpointScheme F Slot Payload Receipt) (C : Context F) where
  item : ManifestItem Slot Payload
  bound : S.entryBound C item.slot item.payload item.digest

/-- An ordered manifest whose slots have each been written at most once. -/
structure OpenManifest
    (S : CheckpointScheme F Slot Payload Receipt) (C : Context F) where
  entries : List (ManifestEntry S C)
  slotsNodup : (entries.map fun e => e.item.slot).Nodup

namespace OpenManifest

variable {S : CheckpointScheme F Slot Payload Receipt} {C : Context F}

/-- The exact semantic payload/digest leaves, in insertion order. -/
def items (M : OpenManifest S C) : List (ManifestItem Slot Payload) :=
  M.entries.map ManifestEntry.item

def slots (M : OpenManifest S C) : List Slot :=
  M.entries.map fun e => e.item.slot

/-- A slot identifies at most one whole authenticated payload/digest entry. -/
theorem entry_eq_of_slot_eq (M : OpenManifest S C)
    {first second : ManifestEntry S C}
    (hfirst : first ∈ M.entries) (hsecond : second ∈ M.entries)
    (hslot : first.item.slot = second.item.slot) : first = second :=
  List.inj_on_of_nodup_map M.slotsNodup hfirst hsecond hslot

/-- Fresh initialization reuses one fixed original context. -/
def empty (S : CheckpointScheme F Slot Payload Receipt) (C : Context F) :
    OpenManifest S C where
  entries := []
  slotsNodup := by simp

/-- Append the actual authenticated leaf, only when its slot is still unused. -/
def append (M : OpenManifest S C) (entry : ManifestEntry S C)
    (fresh : entry.item.slot ∉ M.slots) : OpenManifest S C where
  entries := M.entries ++ [entry]
  slotsNodup := by
    simpa only [slots, List.map_append, List.map_singleton, List.concat_eq_append] using
      (List.nodup_concat M.slots entry.item.slot).mpr ⟨fresh, M.slotsNodup⟩

@[simp]
theorem items_empty (S : CheckpointScheme F Slot Payload Receipt) (C : Context F) :
    (empty S C).items = [] := rfl

@[simp]
theorem slots_empty (S : CheckpointScheme F Slot Payload Receipt) (C : Context F) :
    (empty S C).slots = [] := rfl

@[simp]
theorem items_append (M : OpenManifest S C) (entry : ManifestEntry S C)
    (fresh : entry.item.slot ∉ M.slots) :
    (M.append entry fresh).items = M.items ++ [entry.item] := by
  simp [items, append]

@[simp]
theorem slots_append (M : OpenManifest S C) (entry : ManifestEntry S C)
    (fresh : entry.item.slot ∉ M.slots) :
    (M.append entry fresh).slots = M.slots ++ [entry.item.slot] := by
  simp [slots, append]

theorem append_preserves_entry (M : OpenManifest S C) (entry : ManifestEntry S C)
    (fresh : entry.item.slot ∉ M.slots) {prior : ManifestEntry S C}
    (hprior : prior ∈ M.entries) : prior ∈ (M.append entry fresh).entries := by
  simp [append, hprior]

/-- Another digest or payload cannot make the just-written slot fresh again. -/
theorem not_fresh_after_append (M : OpenManifest S C) (entry : ManifestEntry S C)
    (fresh : entry.item.slot ∉ M.slots) :
    ¬ entry.item.slot ∉ (M.append entry fresh).slots := by
  simp

end OpenManifest

/-- Sealing commits one exact manifest after every required slot is present. -/
structure SealedManifest
    (S : CheckpointScheme F Slot Payload Receipt) (C : Context F) where
  manifest : OpenManifest S C
  root : TCB.Hash32
  complete : ∀ slot ∈ S.requiredSlots, slot ∈ manifest.slots
  rootBound : S.manifestBound C manifest.items root

variable {S : CheckpointScheme F Slot Payload Receipt} {C : Context F}

/-- Completeness yields an actual authenticated entry for every required slot. -/
theorem SealedManifest.required_entry_exists
    (M : SealedManifest S C) (slot : Slot) (hslot : slot ∈ S.requiredSlots) :
    ∃ entry ∈ M.manifest.entries, entry.item.slot = slot :=
  List.mem_map.mp (M.complete slot hslot)

/-- A backend receipt tied to the exact sealed context, ordered leaves and root. -/
structure PersistenceReceipt (M : SealedManifest S C) where
  receipt : Receipt
  persisted : S.persisted C M.manifest.items M.root receipt

/--
Phase constructors retain the exact objects. Consumed checkpoints retain
semantic audit evidence; physical erasure remains a runtime refinement.
-/
inductive Checkpoint
    (S : CheckpointScheme F Slot Payload Receipt) (C : Context F) where
  | collecting (manifest : OpenManifest S C)
  | sealed (manifest : SealedManifest S C)
  | consumed (manifest : SealedManifest S C) (receipt : PersistenceReceipt manifest)

namespace Checkpoint

/-- Local lifecycle: append while open, seal, then consume with a matching receipt. -/
inductive Step : Checkpoint S C → Checkpoint S C → Prop where
  | append (M : OpenManifest S C) (entry : ManifestEntry S C)
      (fresh : entry.item.slot ∉ M.slots) :
      Step (.collecting M) (.collecting (M.append entry fresh))
  | seal (M : SealedManifest S C) :
      Step (.collecting M.manifest) (.sealed M)
  | consume (M : SealedManifest S C) (receipt : PersistenceReceipt M) :
      Step (.sealed M) (.consumed M receipt)

/-- Connected lifecycle execution; it does not assert consensus finality. -/
inductive Execution : Checkpoint S C → Checkpoint S C → Prop where
  | refl (state : Checkpoint S C) : Execution state state
  | next {before middle after : Checkpoint S C}
      (first : Step before middle) (rest : Execution middle after) :
      Execution before after

/-- A sealed manifest has no transition back to an open, appendable manifest. -/
theorem not_step_sealed_to_open (M : SealedManifest S C) (N : OpenManifest S C) :
    ¬ Step (.sealed M) (.collecting N) := by
  intro h
  cases h

/-- Every consumption retains the exact sealed object and supplies its receipt. -/
theorem receipt_of_step_from_sealed
    (M : SealedManifest S C) {after : Checkpoint S C}
    (h : Step (.sealed M) after) :
    ∃ receipt : PersistenceReceipt M, after = .consumed M receipt := by
  cases h with
  | consume _ receipt => exact ⟨receipt, rfl⟩

/-- The receipt is evidence for this context/list/root, not another checkpoint. -/
theorem persisted_of_step_from_sealed
    (M : SealedManifest S C) {after : Checkpoint S C}
    (h : Step (.sealed M) after) :
    ∃ receipt : Receipt, S.persisted C M.manifest.items M.root receipt := by
  obtain ⟨receipt, _⟩ := receipt_of_step_from_sealed M h
  exact ⟨receipt.receipt, receipt.persisted⟩

/-- No local operation can follow consumption. -/
theorem no_step_from_consumed (M : SealedManifest S C) (receipt : PersistenceReceipt M)
    {after : Checkpoint S C} : ¬ Step (.consumed M receipt) after := by
  intro h
  cases h

/-- A consumed checkpoint stays fixed throughout every connected execution. -/
theorem consumed_terminal (M : SealedManifest S C) (receipt : PersistenceReceipt M)
    {after : Checkpoint S C} (h : Execution (.consumed M receipt) after) :
    after = .consumed M receipt := by
  cases h with
  | refl => rfl
  | next first _ => exact False.elim (no_step_from_consumed M receipt first)

/-- Returning to a consumable sealed state requires a different lifecycle. -/
theorem not_execution_consumed_to_sealed
    (M : SealedManifest S C) (receipt : PersistenceReceipt M) (N : SealedManifest S C) :
    ¬ Execution (.consumed M receipt) (.sealed N) := by
  intro h
  have hterminal := consumed_terminal M receipt h
  cases hterminal

end Checkpoint
end Hcrypt.Protocol.Storage
