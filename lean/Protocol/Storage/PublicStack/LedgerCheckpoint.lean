module

public import Protocol.Ephemeral.ScopeCodec
public import Protocol.Ledger.StateCodec
public import Protocol.Storage.Sha256

@[expose] public section

/-!
# Canonical ledger checkpoint records

The checkpoint commits the ordered history's root, the public context, and
the complete final ledger state. Verification checks the expected SHA-256
digest before parsing the record. Authentication of that expected digest
remains the caller's responsibility.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.PublicStack.LedgerCheckpoint

open CoupledCodec (Bytes frame parseFrame parseFrame_frame)
open Protocol.Ephemeral.ScopeCodec (encodeFixed encodeKey parseFixed parseKey)

structure Record where
  historyRoot : TCB.Hash32
  context : ContextKey
  state : Ledger.State ℕ ℕ

def domain : Bytes := "HODGE_LEDGER_CHECKPOINT_V1".toUTF8.data.toList

def encodeBody (record : Record) (rest : Bytes) : Bytes :=
  encodeFixed record.historyRoot
    (encodeKey record.context (frame (Ledger.StateCodec.encode record.state) rest))

def parseBody (bytes : Bytes) : Option (Record × Bytes) := do
  let (historyRoot, rest) ← parseFixed 32 bytes
  let (context, rest) ← parseKey rest
  let (stateBytes, rest) ← parseFrame rest
  let state ← Ledger.StateCodec.decode stateBytes
  some (⟨historyRoot, context, state⟩, rest)

@[simp] theorem parseBody_encodeBody (record : Record) (rest : Bytes) :
    parseBody (encodeBody record rest) = some (record, rest) := by
  simp [parseBody, encodeBody, parseFrame_frame]

def encode (record : Record) : Bytes := domain ++ encodeBody record []

def decode (bytes : Bytes) : Option Record :=
  match parseBody (bytes.drop domain.length) with
  | none => none
  | some (record, rest) =>
    if rest = [] ∧ bytes = encode record then some record else none

@[simp] theorem decode_encode (record : Record) : decode (encode record) = some record := by
  simp [decode, encode]

theorem decode_eq_some_iff (bytes : Bytes) (record : Record) :
    decode bytes = some record ↔ bytes = encode record := by
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
    exact decode_encode record

theorem encode_injective : Function.Injective encode := by
  intro left right same
  have decoded := congrArg decode same
  simpa only [decode_encode, Option.some.injEq] using decoded

/-- A canonical checkpoint checked against an independently supplied digest. -/
structure Verified (root : TCB.Hash32) where
  record : Record
  committed : Sha256.digest (encode record) = root

theorem Verified.eq_of_record_eq {root : TCB.Hash32} {left right : Verified root}
    (same : left.record = right.record) : left = right := by
  cases left
  cases right
  cases same
  rfl

def verify (root : TCB.Hash32) (bytes : Bytes) : Option (Verified root) :=
  let digest := Sha256.digestBytes bytes
  if bound : Sha256.key digest = List.ofFn root then
    match parsed : decode bytes with
    | none => none
    | some record =>
      let canonical := (decode_eq_some_iff _ _).mp parsed
      let committed := (congrArg Sha256.digest canonical).symm.trans (List.ofFn_injective bound)
      some ⟨record, committed⟩
  else none

theorem verify_eq_some_iff (root : TCB.Hash32) (bytes : Bytes) (checked : Verified root) :
    verify root bytes = some checked ↔ bytes = encode checked.record := by
  constructor
  · intro accepted
    simp only [verify] at accepted
    split at accepted
    next bound =>
      split at accepted
      next => exact (Option.some_ne_none checked accepted.symm).elim
      next record parsed =>
        exact ((decode_eq_some_iff _ _).mp parsed).trans
          (congrArg encode (congrArg Verified.record (Option.some.inj accepted)))
    next => exact (Option.some_ne_none checked accepted.symm).elim
  · rintro rfl
    have bound : Sha256.key (Sha256.digestBytes (encode checked.record)) = List.ofFn root :=
      congrArg (fun hash : TCB.Hash32 => List.ofFn hash) checked.committed
    simp only [verify, dite_eq_left bound]
    split
    next absent =>
      exact (Option.some_ne_none _ ((decode_encode checked.record).symm.trans absent)).elim
    next record parsed =>
      have same : record = checked.record :=
        Option.some.inj (parsed.symm.trans (decode_encode checked.record))
      apply congrArg (some : Verified root → Option (Verified root))
      exact Verified.eq_of_record_eq same

namespace Verified

/-- Distinct records accepted at one digest exhibit an explicit SHA-256 collision. -/
theorem record_eq_or_collision {root : TCB.Hash32} (left right : Verified root) :
    left.record = right.record ∨
      (encode left.record ≠ encode right.record ∧
        Sha256.digest (encode left.record) = Sha256.digest (encode right.record)) := by
  by_cases same : left.record = right.record
  · exact Or.inl same
  · exact Or.inr ⟨fun equal => same (encode_injective equal),
      left.committed.trans right.committed.symm⟩

end Verified

end HomotopicalEncryption.Protocol.Storage.PublicStack.LedgerCheckpoint
