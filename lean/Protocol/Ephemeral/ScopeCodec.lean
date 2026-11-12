module

public import Protocol.Ephemeral.Delivery
public import Protocol.Storage.CoupledCodec

@[expose] public section

/-!
# Canonical bytes of the existing delivery scope

This finite profile uses a 32-byte recipient handle and the original
`DeliveryScope` and `ContextKey` fields. The handle is a public identifier;
the codec does not turn it into a recovery secret or authenticate its caller.
Fixed byte arrays use the existing tagged byte framing, and epochs/schema
versions use its base-256 natural encoding. Field order is fixed below.

Canonical parsing and exact scope checks do not construct authorization,
confidential delivery, replay prevention or epoch freshness. The original
scoped delivery contract retains those separate application obligations.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Ephemeral.ScopeCodec

open Storage.CoupledCodec

/-- Versioned ASCII domain `HODGE_TRANSPORT_SCOPE_V1`. -/
def domain : Bytes :=
  [72, 79, 68, 71, 69, 95, 84, 82, 65, 78, 83, 80, 79, 82, 84, 95,
    83, 67, 79, 80, 69, 95, 86, 49]

/-- Framed fixed-width byte vector; embedded tag bytes remain data. -/
def encodeFixed {n : ℕ} (value : Fin n → UInt8) (rest : Bytes) : Bytes :=
  frame (List.ofFn value) rest

/-- Parse the original fixed-width byte vector and retain the suffix. -/
def parseFixed (n : ℕ) (bytes : Bytes) : Option ((Fin n → UInt8) × Bytes) := do
  let (values, rest) ← parseFrame bytes
  if h : values.length = n then
    some (fun i => values.get ⟨i.val, by rw [h]; exact i.isLt⟩, rest)
  else none

@[simp] theorem parseFixed_encodeFixed {n : ℕ} (value : Fin n → UInt8)
    (rest : Bytes) : parseFixed n (encodeFixed value rest) = some (value, rest) := by
  simp [parseFixed, encodeFixed, parseFrame_frame]

theorem encodeFixed_append {n : ℕ} (value : Fin n → UInt8) (rest suffix : Bytes) :
    encodeFixed value rest ++ suffix = encodeFixed value (rest ++ suffix) :=
  frame_append _ _ _

theorem encodeFixed_length {n : ℕ} (value : Fin n → UInt8) (rest : Bytes) :
    (encodeFixed value rest).length = 2 * n + 1 + rest.length := by
  simp [encodeFixed, frame_length]

/-- Exact original ContextKey order: run, schema, snapshot, cochain, topology,
parameter profile. No names are replaced or identified by the encoding. -/
def encodeKey (key : Storage.ContextKey) (rest : Bytes) : Bytes :=
  encodeFixed key.runId
    (encodeNat key.schemaVersion
      (encodeFixed key.snapshotRoot
        (encodeFixed key.cochainDigest
          (encodeFixed key.topologyTag (encodeFixed key.parameterSet rest)))))

def parseKey (bytes : Bytes) : Option (Storage.ContextKey × Bytes) := do
  let (runId, rest) ← parseFixed 32 bytes
  let (schemaVersion, rest) ← parseNat rest
  let (snapshotRoot, rest) ← parseFixed 32 rest
  let (cochainDigest, rest) ← parseFixed 32 rest
  let (topologyTag, rest) ← parseFixed 16 rest
  let (parameterSet, rest) ← parseFixed 32 rest
  some (⟨runId, schemaVersion, snapshotRoot, cochainDigest, topologyTag, parameterSet⟩, rest)

@[simp] theorem parseKey_encodeKey (key : Storage.ContextKey) (rest : Bytes) :
    parseKey (encodeKey key rest) = some (key, rest) := by
  cases key
  simp [parseKey, encodeKey]

theorem encodeKey_append (key : Storage.ContextKey) (rest suffix : Bytes) :
    encodeKey key rest ++ suffix = encodeKey key (rest ++ suffix) := by
  simp [encodeKey, encodeFixed_append, encodeNat_append]

theorem encodeKey_length (key : Storage.ContextKey) (rest : Bytes) :
    (encodeKey key rest).length =
      294 + 2 * (Nat.digits 256 key.schemaVersion).length + rest.length := by
  simp only [encodeKey, encodeFixed_length, encodeNat_length]
  omega

/-- The original scope, with only its recipient type fixed to a byte handle. -/
abbrev Scope := DeliveryScope TCB.Hash32

def encodeBody (scope : Scope) (rest : Bytes) : Bytes :=
  encodeFixed scope.recipient
    (encodeNat scope.sourceEpoch
      (encodeNat scope.targetEpoch (encodeKey scope.source (encodeKey scope.target rest))))

def parseBody (bytes : Bytes) : Option (Scope × Bytes) := do
  let (recipient, rest) ← parseFixed 32 bytes
  let (sourceEpoch, rest) ← parseNat rest
  let (targetEpoch, rest) ← parseNat rest
  let (source, rest) ← parseKey rest
  let (target, rest) ← parseKey rest
  some (⟨recipient, sourceEpoch, targetEpoch, source, target⟩, rest)

@[simp] theorem parseBody_encodeBody (scope : Scope) (rest : Bytes) :
    parseBody (encodeBody scope rest) = some (scope, rest) := by
  cases scope
  simp [parseBody, encodeBody]

def encode (scope : Scope) : Bytes := domain ++ encodeBody scope []

/-- Fixed byte identifiers contribute constant overhead; all four natural
scope coordinates use logarithmic base-256 digit lengths. -/
theorem encode_length (scope : Scope) :
    (encode scope).length = 679 + 2 *
      ((Nat.digits 256 scope.sourceEpoch).length +
       (Nat.digits 256 scope.targetEpoch).length +
       (Nat.digits 256 scope.source.schemaVersion).length +
       (Nat.digits 256 scope.target.schemaVersion).length) := by
  simp only [encode, List.length_append, encodeBody, encodeFixed_length,
    encodeNat_length, encodeKey_length, List.length_nil]
  have hdomain : domain.length = 24 := rfl
  rw [hdomain]
  omega

/-- Actual parser with exact re-encoding, including domain and empty suffix. -/
def decode (bytes : Bytes) : Option Scope :=
  match parseBody (bytes.drop domain.length) with
  | none => none
  | some (scope, rest) =>
    if rest = [] ∧ bytes = encode scope then some scope else none

@[simp] theorem decode_encode (scope : Scope) : decode (encode scope) = some scope := by
  simp [decode, encode]

theorem decode_eq_some_iff (bytes : Bytes) (scope : Scope) :
    decode bytes = some scope ↔ bytes = encode scope := by
  constructor
  · intro decoded
    unfold decode at decoded
    cases parsed : parseBody (bytes.drop domain.length) with
    | none => simp [parsed] at decoded
    | some value =>
      rcases value with ⟨other, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next same =>
        have hs : other = scope := Option.some.inj decoded
        subst other
        exact same.2
      next => contradiction
  · rintro rfl
    exact decode_encode scope

theorem encode_injective : Function.Injective encode := by
  intro scope other same
  have parsed := congrArg decode same
  simpa only [decode_encode, Option.some.injEq] using parsed

theorem accepted_iff_canonical (bytes : Bytes) :
    (∃ scope, decode bytes = some scope) ↔ ∃ scope, bytes = encode scope := by
  simp only [decode_eq_some_iff]

theorem encodeBody_append (scope : Scope) (rest suffix : Bytes) :
    encodeBody scope rest ++ suffix = encodeBody scope (rest ++ suffix) := by
  simp [encodeBody, encodeFixed_append, encodeNat_append, encodeKey_append]

theorem parseBody_encode_append (scope : Scope) (suffix : Bytes) :
    parseBody ((encode scope ++ suffix).drop domain.length) = some (scope, suffix) := by
  rw [encode, List.append_assoc, List.drop_left, encodeBody_append]
  simp

theorem decode_rejects_trailing (scope : Scope) (suffix : Bytes) (nonempty : suffix ≠ []) :
    decode (encode scope ++ suffix) = none := by
  simp [decode, parseBody_encode_append, nonempty]

theorem decode_rejects_wrong_domain (bytes : Bytes)
    (wrong : bytes.take domain.length ≠ domain) : decode bytes = none := by
  cases parsed : decode bytes with
  | none => rfl
  | some scope =>
    have canonical := (decode_eq_some_iff bytes scope).mp parsed
    apply False.elim
    apply wrong
    rw [canonical, encode, List.take_left]

theorem encode_prefix_free (scope other : Scope) (suffix : Bytes)
    (same : encode scope ++ suffix = encode other) : suffix = [] := by
  have parsed := congrArg decode same
  by_contra nonempty
  rw [decode_rejects_trailing scope suffix nonempty, decode_encode] at parsed
  contradiction

theorem decode_rejects_truncation (scope : Scope) (cut : ℕ)
    (short : cut < (encode scope).length) : decode ((encode scope).take cut) = none := by
  cases parsed : decode ((encode scope).take cut) with
  | none => rfl
  | some other =>
    have canonical := (decode_eq_some_iff _ other).mp parsed
    have hprefix : encode other ++ (encode scope).drop cut = encode scope := by
      rw [← canonical, List.take_append_drop]
    have empty := encode_prefix_free other scope _ hprefix
    have hlen := congrArg List.length empty
    simp only [List.length_drop, List.length_nil] at hlen
    omega

/-- Check every original scope field after canonical parsing. Matching fields
are not caller authentication, and the operation supplies no delivery proof. -/
def check (expected : Scope) (bytes : Bytes) : Option Scope := do
  let scope ← decode bytes
  if scope = expected then some scope else none

theorem check_eq_some_iff (expected : Scope) (bytes : Bytes) (scope : Scope) :
    check expected bytes = some scope ↔ bytes = encode scope ∧ scope = expected := by
  cases parsed : decode bytes with
  | none => simp [check, parsed, ← decode_eq_some_iff]
  | some other =>
    have canonical := (decode_eq_some_iff bytes other).mp parsed
    have hs : bytes = encode scope ↔ other = scope := by
      constructor
      · intro same
        exact encode_injective (canonical.symm.trans same)
      · rintro rfl
        exact canonical
    by_cases same : other = expected <;> simp [check, parsed, same, hs] <;> aesop

@[simp] theorem check_encode (scope : Scope) : check scope (encode scope) = some scope :=
  (check_eq_some_iff _ _ _).mpr ⟨rfl, rfl⟩

theorem check_none_of_scope_ne (expected actual : Scope) (wrong : actual ≠ expected) :
    check expected (encode actual) = none := by
  simp [check, wrong]

end HomotopicalEncryption.Protocol.Ephemeral.ScopeCodec
