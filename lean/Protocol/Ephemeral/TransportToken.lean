module

public import Protocol.Ephemeral.ScopeCodec
public import Protocol.Storage.TransportCodec

@[expose] public section

/-!
# Canonical scoped native transport tokens

A token contains the existing recipient/epoch/context delivery scope and a
derived rational operator in the exact/information/parity coordinate order.
The source and target coupling matrices are not separate serialized fields;
this is not a key-hiding guarantee for the derived operator, which may reveal
information about either presentation. No safe public-token release is proved.
The versioned byte
format also retains both physical dimensions, so partitions with the same
total cochain dimension do not share a decoding profile.

Canonical parsing and an actual scope/digest check identify the exact token
or exhibit a byte-hash collision. These checks do not establish authorization,
confidential envelope delivery, freshness, or correctness of an arbitrary
decoded operator. The native construction supplies the operator relation;
the original delivery contracts retain authentication and secrecy obligations.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Ephemeral.TransportToken

open Storage.CoupledCodec

abbrev Bytes := List UInt8

/-- Number of original coupled cochain scalar coordinates. -/
abbrev dimension (rows cols : ℕ) := 1 + cols + rows

/-- The existing scope with a finite recipient handle. -/
abbrev Scope := DeliveryScope TCB.Hash32

/-- Private transport material records only its derived map and actual scope. -/
structure Token (rows cols : ℕ) where
  scope : Scope
  operator : Matrix (Fin (dimension rows cols)) (Fin (dimension rows cols)) ℚ
  deriving DecidableEq

@[ext] theorem Token.ext {rows cols : ℕ} {t s : Token rows cols}
    (scope : t.scope = s.scope) (operator : t.operator = s.operator) : t = s := by
  cases t
  cases s
  simp_all

/-- Exact ASCII domain `HODGE_SCOPED_TRANSPORT_V1`. -/
def domain : Bytes :=
  [72, 79, 68, 71, 69, 95, 83, 67, 79, 80, 69, 68, 95, 84, 82, 65, 78, 83, 80,
    79, 82, 84, 95, 86, 49]

/-- Fixed field order: framed scope, physical dimensions, framed derived matrix. -/
def encodeBody {rows cols : ℕ} (token : Token rows cols) (rest : Bytes) : Bytes :=
  frame (ScopeCodec.encode token.scope)
    (encodeNat rows (encodeNat cols
      (frame (Storage.TransportCodec.encode (Storage.TransportCodec.ofMatrix token.operator)) rest)))

def encode {rows cols : ℕ} (token : Token rows cols) : Bytes :=
  domain ++ encodeBody token []

/-- Parse the original scope and require the physical and matrix dimensions. -/
def parseBody (rows cols : ℕ) (bytes : Bytes) : Option (Token rows cols × Bytes) := do
  let (scopeBytes, rest) ← parseFrame bytes
  let scope ← ScopeCodec.decode scopeBytes
  let (encodedRows, rest) ← parseNat rest
  let (encodedCols, rest) ← parseNat rest
  if encodedRows = rows ∧ encodedCols = cols then
    let (operatorBytes, tail) ← parseFrame rest
    let operator ← Storage.TransportCodec.decodeMatrix
      (dimension rows cols) (dimension rows cols) operatorBytes
    some (⟨scope, operator⟩, tail)
  else none

@[simp] theorem parseBody_encodeBody {rows cols : ℕ} (token : Token rows cols)
    (rest : Bytes) : parseBody rows cols (encodeBody token rest) = some (token, rest) := by
  cases token
  simp [parseBody, encodeBody, parseFrame_frame]

/-- A matrix with the wrong physical operator shape rejects inside an otherwise
well-framed scope/dimension body. -/
theorem parseBody_rejects_operator_dimensions (rows cols : ℕ) (scope : Scope)
    (operator : Storage.TransportCodec.Packet) (rest : Bytes)
    (wrong : operator.rows ≠ dimension rows cols ∨ operator.cols ≠ dimension rows cols) :
    parseBody rows cols
      (frame (ScopeCodec.encode scope) (encodeNat rows (encodeNat cols
        (frame (Storage.TransportCodec.encode operator) rest)))) = none := by
  simp [parseBody, parseFrame_frame,
    Storage.TransportCodec.decodeMatrix_rejects_dimensions operator _ _ wrong]

/-- Decode exactly canonical bytes under the selected coupled dimensions. -/
def decode (rows cols : ℕ) (bytes : Bytes) : Option (Token rows cols) :=
  match parseBody rows cols (bytes.drop domain.length) with
  | none => none
  | some (token, rest) =>
    if rest = [] ∧ bytes = encode token then some token else none

@[simp] theorem decode_encode {rows cols : ℕ} (token : Token rows cols) :
    decode rows cols (encode token) = some token := by
  simp [decode, encode]

theorem decode_eq_some_iff {rows cols : ℕ} (bytes : Bytes) (token : Token rows cols) :
    decode rows cols bytes = some token ↔ bytes = encode token := by
  constructor
  · intro decoded
    unfold decode at decoded
    cases parsed : parseBody rows cols (bytes.drop domain.length) with
    | none => simp [parsed] at decoded
    | some value =>
      rcases value with ⟨other, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next same =>
        have ht : other = token := Option.some.inj decoded
        subst other
        exact same.2
      next => contradiction
  · rintro rfl
    exact decode_encode token

theorem encode_injective {rows cols : ℕ} :
    Function.Injective (encode (rows := rows) (cols := cols)) := by
  intro token other same
  have parsed := congrArg (decode rows cols) same
  simpa only [decode_encode, Option.some.injEq] using parsed

theorem accepted_iff_canonical (rows cols : ℕ) (bytes : Bytes) :
    (∃ token, decode rows cols bytes = some token) ↔
      ∃ token : Token rows cols, bytes = encode token := by
  simp only [decode_eq_some_iff]

theorem encodeBody_append {rows cols : ℕ} (token : Token rows cols)
    (rest suffix : Bytes) :
    encodeBody token rest ++ suffix = encodeBody token (rest ++ suffix) := by
  simp [encodeBody, frame_append, encodeNat_append]

theorem parseBody_encode_append {rows cols : ℕ} (token : Token rows cols)
    (suffix : Bytes) :
    parseBody rows cols ((encode token ++ suffix).drop domain.length) =
      some (token, suffix) := by
  rw [encode, List.append_assoc, List.drop_left, encodeBody_append]
  simp

/-- A different physical partition rejects even when total dimensions agree. -/
theorem decode_rejects_dimensions {rows cols : ℕ} (token : Token rows cols)
    (otherRows otherCols : ℕ) (wrong : rows ≠ otherRows ∨ cols ≠ otherCols) :
    decode otherRows otherCols (encode token) = none := by
  have bad : ¬ (rows = otherRows ∧ cols = otherCols) := by tauto
  simp [decode, encode, parseBody, encodeBody, parseFrame_frame, bad]

theorem decode_rejects_trailing {rows cols : ℕ} (token : Token rows cols)
    (suffix : Bytes) (nonempty : suffix ≠ []) :
    decode rows cols (encode token ++ suffix) = none := by
  simp [decode, parseBody_encode_append, nonempty]

theorem decode_rejects_wrong_domain (rows cols : ℕ) (bytes : Bytes)
    (wrong : bytes.take domain.length ≠ domain) : decode rows cols bytes = none := by
  cases parsed : decode rows cols bytes with
  | none => rfl
  | some token =>
    have canonical := (decode_eq_some_iff bytes token).mp parsed
    apply False.elim
    apply wrong
    rw [canonical, encode, List.take_left]

theorem encode_prefix_free {rows cols : ℕ} (token other : Token rows cols)
    (suffix : Bytes) (same : encode token ++ suffix = encode other) : suffix = [] := by
  have parsed := congrArg (decode rows cols) same
  by_contra nonempty
  rw [decode_rejects_trailing token suffix nonempty, decode_encode] at parsed
  contradiction

theorem decode_rejects_truncation {rows cols : ℕ} (token : Token rows cols) (cut : ℕ)
    (short : cut < (encode token).length) : decode rows cols ((encode token).take cut) = none := by
  cases parsed : decode rows cols ((encode token).take cut) with
  | none => rfl
  | some other =>
    have canonical := (decode_eq_some_iff _ other).mp parsed
    have prefix_eq : encode other ++ (encode token).drop cut = encode token := by
      rw [← canonical, List.take_append_drop]
    have empty := encode_prefix_free other token _ prefix_eq
    have hlen := congrArg List.length empty
    simp only [List.length_drop, List.length_nil] at hlen
    omega

/-- Check canonical bytes, every scope field, and the actual selected byte hash. -/
def check (rows cols : ℕ) (hash : Bytes → TCB.Hash32)
    (expectedScope : Scope) (expectedDigest : TCB.Hash32) (bytes : Bytes) :
    Option (Token rows cols) :=
  match decode rows cols bytes with
  | none => none
  | some token =>
    if token.scope = expectedScope ∧ hash bytes = expectedDigest then some token else none

theorem check_eq_some_iff {rows cols : ℕ} (hash : Bytes → TCB.Hash32)
    (expectedScope : Scope) (expectedDigest : TCB.Hash32) (bytes : Bytes)
    (token : Token rows cols) :
    check rows cols hash expectedScope expectedDigest bytes = some token ↔
      bytes = encode token ∧ token.scope = expectedScope ∧ hash bytes = expectedDigest := by
  constructor
  · intro accepted
    cases parsed : decode rows cols bytes with
    | none => simp [check, parsed] at accepted
    | some other =>
      rw [check, parsed] at accepted
      change (if other.scope = expectedScope ∧ hash bytes = expectedDigest
        then some other else none) = some token at accepted
      by_cases checked : other.scope = expectedScope ∧ hash bytes = expectedDigest
      · rw [ite_eq_left checked] at accepted
        have same : other = token := Option.some.inj accepted
        subst other
        exact ⟨(decode_eq_some_iff bytes token).mp parsed, checked.1, checked.2⟩
      · rw [ite_eq_right checked] at accepted
        contradiction
  · rintro ⟨rfl, sameScope, sameDigest⟩
    simp [check, sameScope, sameDigest]

@[simp] theorem check_encode {rows cols : ℕ} (hash : Bytes → TCB.Hash32)
    (token : Token rows cols) :
    check rows cols hash token.scope (hash (encode token)) (encode token) = some token :=
  (check_eq_some_iff _ _ _ _ _).mpr ⟨rfl, rfl, rfl⟩

/-- A scope mismatch rejects even when the supplied digest matches the bytes. -/
theorem check_none_of_scope_ne {rows cols : ℕ} (hash : Bytes → TCB.Hash32)
    (expectedScope : Scope) (token : Token rows cols) (wrong : token.scope ≠ expectedScope)
    (expectedDigest : TCB.Hash32) :
    check rows cols hash expectedScope expectedDigest (encode token) = none := by
  simp [check, wrong]

/-- An actual hash mismatch rejects after canonical parsing. -/
theorem check_none_of_digest_ne {rows cols : ℕ} (hash : Bytes → TCB.Hash32)
    (expectedScope : Scope) (expectedDigest : TCB.Hash32) (bytes : Bytes)
    (wrong : hash bytes ≠ expectedDigest) :
    check rows cols hash expectedScope expectedDigest bytes = none := by
  cases parsed : decode rows cols bytes <;> simp [check, parsed, wrong]

/-- Accepted material for a named original is that exact token or exhibits an
actual collision of distinct canonical bytes. No global hash injectivity is assumed. -/
theorem check_original_or_collision {rows cols : ℕ} (hash : Bytes → TCB.Hash32)
    (expectedScope : Scope) (original returned : Token rows cols) (bytes : Bytes)
    (accepted : check rows cols hash expectedScope (hash (encode original)) bytes = some returned) :
    returned = original ∨
      (bytes ≠ encode original ∧ hash bytes = hash (encode original)) := by
  obtain ⟨canonical, _scope, checked⟩ :=
    (check_eq_some_iff hash _ _ bytes returned).mp accepted
  by_cases same : returned = original
  · exact Or.inl same
  · refine Or.inr ⟨?_, checked⟩
    intro hbytes
    exact same (encode_injective (canonical.symm.trans hbytes))

/-- The outer token adds framed scope/map bytes and logarithmic dimension headers. -/
theorem encode_length {rows cols : ℕ} (token : Token rows cols) :
    (encode token).length = 25 +
      (2 * (ScopeCodec.encode token.scope).length + 1) +
      (2 * (Nat.digits 256 rows).length + 1) +
      (2 * (Nat.digits 256 cols).length + 1) +
      (2 * (Storage.TransportCodec.encode
        (Storage.TransportCodec.ofMatrix token.operator)).length + 1) := by
  simp only [encode, List.length_append, encodeBody, frame_length, encodeNat_length,
    List.length_nil]
  have hd : domain.length = 25 := rfl
  rw [hd]
  omega

end HomotopicalEncryption.Protocol.Ephemeral.TransportToken
