module

public import Protocol.Ledger.State
public import Protocol.Ephemeral.ScopeCodec
public import Mathlib.Data.Finset.Sort
public import Mathlib.Data.List.Basic

public section

/-!
# Canonical bytes of the complete natural-ID ledger state

Marking entries use increasing resource IDs and nonzero natural quantities.
Spent IDs use increasing order. The encoding retains every state field,
including the tip and evidence roots. These bytes serve as a checkpoint
preimage independently of the transfer hash suite's proposal state roots.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Ledger.StateCodec

open Storage.CoupledCodec (Bytes encodeNat parseNat)
open Protocol.Ephemeral.ScopeCodec (encodeFixed parseFixed)

private abbrev Rows := List (Nat × Nat)

private def quantity (rows : Rows) (id : Nat) : Nat := (rows.lookup id).getD 0

private theorem quantity_ne_zero_mem (rows : Rows) (id : Nat)
    (active : quantity rows id ≠ 0) : id ∈ (rows.map Prod.fst).toFinset := by
  cases found : rows.lookup id with
  | none => simp [quantity, found] at active
  | some value =>
    obtain ⟨_, _, same, _⟩ := List.lookup_eq_some_iff.mp found
    simp [same]

private def markingOfRows (rows : Rows) : Marking Nat where
  toFun := quantity rows
  support := (rows.map Prod.fst).toFinset.filter (fun id => quantity rows id ≠ 0)
  mem_support_toFun id := by
    rw [Finset.mem_filter]
    exact ⟨And.right, fun active => ⟨quantity_ne_zero_mem rows id active, active⟩⟩

private def markingRows (marking : Marking Nat) : Rows :=
  marking.support.sort.map fun id => (id, marking id)

private theorem markingOfRows_markingRows (marking : Marking Nat) :
    markingOfRows (markingRows marking) = marking := by
  ext id
  change quantity (markingRows marking) id = marking id
  by_cases present : id ∈ marking.support
  · have inOrder : id ∈ marking.support.sort := by
      simpa only [Finset.mem_sort] using present
    have found : (markingRows marking).lookup id = some (marking id) :=
      List.lookup_graph (fun key => marking key) inOrder
    simp [quantity, found]
  · have zero : marking id = 0 := by
      simpa only [Finsupp.mem_support_iff, not_ne_iff] using present
    have absent : (markingRows marking).lookup id = none := by
      apply List.lookup_eq_none_iff.mpr
      intro row member
      obtain ⟨key, inOrder, rfl⟩ := List.mem_map.mp member
      have distinct : id ≠ key := by
        rintro rfl
        exact present (by simpa only [Finset.mem_sort] using inOrder)
      simpa using distinct
    simp [quantity, absent, zero]

private def encodeRows : Rows → Bytes → Bytes
  | [], rest => rest
  | (id, count) :: rows, rest => encodeNat id (encodeNat count (encodeRows rows rest))

private def parseRows : Nat → Bytes → Option (Rows × Bytes)
  | 0, bytes => some ([], bytes)
  | length + 1, bytes => do
    let (id, rest) ← parseNat bytes
    let (count, rest) ← parseNat rest
    let (rows, rest) ← parseRows length rest
    some ((id, count) :: rows, rest)

@[simp] private theorem parseRows_encodeRows (rows : Rows) (rest : Bytes) :
    parseRows rows.length (encodeRows rows rest) = some (rows, rest) := by
  induction rows with
  | nil => rfl
  | cons row rows ih =>
    rcases row with ⟨id, count⟩
    simp [encodeRows, parseRows, ih]

private def encodeIds : List Nat → Bytes → Bytes
  | [], rest => rest
  | id :: ids, rest => encodeNat id (encodeIds ids rest)

private def parseIds : Nat → Bytes → Option (List Nat × Bytes)
  | 0, bytes => some ([], bytes)
  | length + 1, bytes => do
    let (id, rest) ← parseNat bytes
    let (ids, rest) ← parseIds length rest
    some (id :: ids, rest)

@[simp] private theorem parseIds_encodeIds (ids : List Nat) (rest : Bytes) :
    parseIds ids.length (encodeIds ids rest) = some (ids, rest) := by
  induction ids with
  | nil => rfl
  | cons id ids ih => simp [encodeIds, parseIds, ih]

private def encodeBody (state : State Nat Nat) (rest : Bytes) : Bytes :=
  let marking := markingRows state.marking
  let spent := state.spent.sort
  let header := encodeFixed state.tipHash
    (encodeNat state.height (encodeNat state.epoch (encodeFixed state.snapshotRoot
      (encodeFixed state.topologyRoot (encodeFixed state.cochainRoot
        (encodeFixed state.evidenceRoot rest))))))
  encodeNat marking.length (encodeRows marking (encodeNat spent.length (encodeIds spent header)))

private def parseBody (bytes : Bytes) : Option (State Nat Nat × Bytes) := do
  let (markingLength, rest) ← parseNat bytes
  let (marking, rest) ← parseRows markingLength rest
  let (spentLength, rest) ← parseNat rest
  let (spent, rest) ← parseIds spentLength rest
  let (tipHash, rest) ← parseFixed 32 rest
  let (height, rest) ← parseNat rest
  let (epoch, rest) ← parseNat rest
  let (snapshotRoot, rest) ← parseFixed 32 rest
  let (topologyRoot, rest) ← parseFixed 32 rest
  let (cochainRoot, rest) ← parseFixed 32 rest
  let (evidenceRoot, rest) ← parseFixed 32 rest
  some (⟨markingOfRows marking, spent.toFinset, tipHash, height, epoch,
    snapshotRoot, topologyRoot, cochainRoot, evidenceRoot⟩, rest)

@[simp] private theorem parseBody_encodeBody (state : State Nat Nat) (rest : Bytes) :
    parseBody (encodeBody state rest) = some (state, rest) := by
  cases state
  simp [parseBody, encodeBody, markingOfRows_markingRows, -Finset.length_sort]

private def domain : Bytes := "HODGE_LEDGER_STATE_V1".toUTF8.data.toList

def encode (state : State Nat Nat) : Bytes := domain ++ encodeBody state []

def decode (bytes : Bytes) : Option (State Nat Nat) :=
  match parseBody (bytes.drop domain.length) with
  | none => none
  | some (state, rest) =>
    if rest = [] ∧ bytes = encode state then some state else none

@[simp] theorem decode_encode (state : State Nat Nat) : decode (encode state) = some state := by
  simp [decode, encode]

theorem decode_eq_some_iff (bytes : Bytes) (state : State Nat Nat) :
    decode bytes = some state ↔ bytes = encode state := by
  constructor
  · intro decoded
    unfold decode at decoded
    cases parsed : parseBody (bytes.drop domain.length) with
    | none => simp [parsed] at decoded
    | some value =>
      rcases value with ⟨other, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next canonical =>
        exact canonical.2.trans (congrArg encode (Option.some.inj decoded))
      next => contradiction
  · rintro rfl
    exact decode_encode state

theorem encode_injective : Function.Injective encode := by
  intro left right same
  have decoded := congrArg decode same
  simpa only [decode_encode, Option.some.injEq] using decoded

end HomotopicalEncryption.Protocol.Ledger.StateCodec
