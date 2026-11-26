module

public import Protocol.Ephemeral.ScopeCodec

@[expose] public section

/-!
# Canonical cell directory bytes

The directory encoding retains the complete context key and the exact
ordered list of cell IDs and ciphertext digests. Parsing checks the domain,
the empty suffix, and exact re-encoding. The directory verifier checks cell
ID uniqueness and the trusted digest.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.CellDirectory.Codec

open CoupledCodec (Bytes encodeNat parseNat)
open Protocol.Ephemeral.ScopeCodec (encodeKey parseKey encodeFixed parseFixed)

abbrev Entries := List (ℕ × TCB.Hash32)

/-- Versioned ASCII domain for the ordered cell directory. -/
def domain : Bytes := "HODGE_CELL_DIRECTORY_V1".toUTF8.data.toList

def encodeRows : Entries → Bytes → Bytes
  | [], rest => rest
  | (cell, digest) :: rows, rest => encodeNat cell (encodeFixed digest (encodeRows rows rest))

def parseRows : ℕ → Bytes → Option (Entries × Bytes)
  | 0, bytes => some ([], bytes)
  | count + 1, bytes => do
    let (cell, rest) ← parseNat bytes
    let (digest, rest) ← parseFixed 32 rest
    let (rows, rest) ← parseRows count rest
    some ((cell, digest) :: rows, rest)

@[simp] theorem parseRows_encodeRows (entries : Entries) (rest : Bytes) :
    parseRows entries.length (encodeRows entries rest) = some (entries, rest) := by
  induction entries with
  | nil => rfl
  | cons row rows ih =>
    rcases row with ⟨cell, digest⟩
    simp [encodeRows, parseRows, ih]

def encodeBody (context : ContextKey) (entries : Entries) (rest : Bytes) : Bytes :=
  encodeKey context (encodeNat entries.length (encodeRows entries rest))

def parseBody (bytes : Bytes) : Option ((ContextKey × Entries) × Bytes) := do
  let (context, rest) ← parseKey bytes
  let (count, rest) ← parseNat rest
  let (entries, rest) ← parseRows count rest
  some ((context, entries), rest)

@[simp] theorem parseBody_encodeBody (context : ContextKey) (entries : Entries) (rest : Bytes) :
    parseBody (encodeBody context entries rest) = some ((context, entries), rest) := by
  simp [parseBody, encodeBody]

def encode (context : ContextKey) (entries : Entries) : Bytes :=
  domain ++ encodeBody context entries []

def decode (bytes : Bytes) : Option (ContextKey × Entries) :=
  match parseBody (bytes.drop domain.length) with
  | none => none
  | some ((context, entries), rest) =>
    if rest = [] ∧ bytes = encode context entries then some (context, entries) else none

@[simp] theorem decode_encode (context : ContextKey) (entries : Entries) :
    decode (encode context entries) = some (context, entries) := by
  simp [decode, encode]

theorem decode_eq_some_iff (bytes : Bytes) (context : ContextKey) (entries : Entries) :
    decode bytes = some (context, entries) ↔ bytes = encode context entries := by
  constructor
  · intro decoded
    unfold decode at decoded
    cases parsed : parseBody (bytes.drop domain.length) with
    | none => simp [parsed] at decoded
    | some value =>
      rcases value with ⟨⟨otherContext, otherEntries⟩, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next canonical =>
        have same := Option.some.inj decoded
        cases same
        exact canonical.2
      next => contradiction
  · rintro rfl
    exact decode_encode context entries

theorem encode_injective : Function.Injective (fun input : ContextKey × Entries =>
    encode input.1 input.2) := by
  rintro ⟨context, entries⟩ ⟨otherContext, otherEntries⟩ same
  have decoded := congrArg decode same
  simpa only [decode_encode, Option.some.injEq] using decoded

end HomotopicalEncryption.Protocol.Storage.CellDirectory.Codec
