module

public import Protocol.Ephemeral.ScopeCodec
public import Protocol.Storage.Sha256

@[expose] public section

/-!
# Ordered public stack history index

One canonical record names the stack roots in replay order. Its SHA-256
digest commits the exact list, including the empty history. The reader
supplies the expected index root from independent trusted input.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.PublicStack.HistoryIndex

open CoupledCodec (Bytes encodeNat parseNat)
open Protocol.Ephemeral.ScopeCodec (encodeFixed parseFixed)

abbrev Roots := List TCB.Hash32

/-- Return the remaining roots after matching the prior history in order. -/
def continuation : Roots → Roots → Option Roots
  | [], remaining => some remaining
  | _ :: _, [] => none
  | oldRoot :: prior, newRoot :: remaining =>
    if List.ofFn oldRoot = List.ofFn newRoot then continuation prior remaining else none

theorem continuation_eq_some_iff (prior extended suffix : Roots) :
    continuation prior extended = some suffix ↔ extended = prior ++ suffix := by
  induction prior generalizing extended with
  | nil => simp [continuation]
  | cons oldRoot prior ih =>
    cases extended with
    | nil => simp [continuation]
    | cons newRoot remaining =>
      by_cases same : oldRoot = newRoot
      · subst newRoot
        simp [continuation, ih]
      · have differentBytes : List.ofFn oldRoot ≠ List.ofFn newRoot :=
          fun equal => same (List.ofFn_injective equal)
        rw [continuation, ite_eq_right differentBytes]
        constructor
        · intro impossible
          cases impossible
        · intro extendedEq
          exact (same (List.cons.inj extendedEq).1.symm).elim

def domain : Bytes := "HODGE_PUBLIC_STACK_HISTORY_V1".toUTF8.data.toList

def encodeRoots : Roots → Bytes → Bytes
  | [], rest => rest
  | root :: roots, rest => encodeFixed root (encodeRoots roots rest)

def parseRoots : Nat → Bytes → Option (Roots × Bytes)
  | 0, bytes => some ([], bytes)
  | count + 1, bytes => do
    let (root, rest) ← parseFixed 32 bytes
    let (roots, rest) ← parseRoots count rest
    some (root :: roots, rest)

@[simp] theorem parseRoots_encodeRoots (roots : Roots) (rest : Bytes) :
    parseRoots roots.length (encodeRoots roots rest) = some (roots, rest) := by
  induction roots with
  | nil => rfl
  | cons root roots ih => simp [encodeRoots, parseRoots, ih]

def parseBody (bytes : Bytes) : Option (Roots × Bytes) := do
  let (count, rest) ← parseNat bytes
  parseRoots count rest

def encode (roots : Roots) : Bytes := domain ++ encodeNat roots.length (encodeRoots roots [])

def decode (bytes : Bytes) : Option Roots :=
  match parseBody (bytes.drop domain.length) with
  | none => none
  | some (roots, rest) =>
    if rest = [] ∧ bytes = encode roots then some roots else none

@[simp] theorem decode_encode (roots : Roots) : decode (encode roots) = some roots := by
  simp [decode, encode, parseBody]

theorem decode_eq_some_iff (bytes : Bytes) (roots : Roots) :
    decode bytes = some roots ↔ bytes = encode roots := by
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
    exact decode_encode roots

theorem encode_injective : Function.Injective encode := by
  intro left right same
  have decoded := congrArg decode same
  simpa only [decode_encode, Option.some.injEq] using decoded

/-- The ordered history checked at its independently trusted root. -/
structure Verified (root : TCB.Hash32) where
  roots : Roots
  committed : Sha256.digest (encode roots) = root

def verify (root : TCB.Hash32) (bytes : Bytes) : Option (Verified root) :=
  (decode bytes).bind fun roots =>
    let computed := Sha256.digestBytes (encode roots)
    if bound : Sha256.key computed = List.ofFn root then
      some ⟨roots, List.ofFn_injective bound⟩
    else none

theorem verify_eq_some_iff (root : TCB.Hash32) (bytes : Bytes) (checked : Verified root) :
    verify root bytes = some checked ↔ bytes = encode checked.roots := by
  constructor
  · intro accepted
    unfold verify at accepted
    cases parsed : decode bytes with
    | none => simp [parsed] at accepted
    | some roots =>
      simp only [parsed, Option.bind_some] at accepted
      split at accepted
      next bound =>
        exact ((decode_eq_some_iff _ _).mp parsed).trans
          (congrArg encode (congrArg Verified.roots (Option.some.inj accepted)))
      next => exact (Option.some_ne_none checked accepted.symm).elim
  · rintro rfl
    have bound : Sha256.key (Sha256.digestBytes (encode checked.roots)) = List.ofFn root :=
      congrArg (fun hash : TCB.Hash32 => List.ofFn hash) checked.committed
    simp only [verify, decode_encode, Option.bind_some, dite_eq_left bound]

namespace Verified

/-- Checked histories at the same root have the exact same order or exhibit a collision. -/
theorem roots_eq_or_collision {root : TCB.Hash32} (left right : Verified root) :
    left.roots = right.roots ∨
      (encode left.roots ≠ encode right.roots ∧
        Sha256.digest (encode left.roots) = Sha256.digest (encode right.roots)) := by
  by_cases same : left.roots = right.roots
  · exact Or.inl same
  · exact Or.inr ⟨fun equal => same (encode_injective equal),
      left.committed.trans right.committed.symm⟩

end Verified

end HomotopicalEncryption.Protocol.Storage.PublicStack.HistoryIndex
