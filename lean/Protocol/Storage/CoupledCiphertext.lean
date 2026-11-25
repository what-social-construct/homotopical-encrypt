module

public import Protocol.Storage.CoupledCodec
public import Sheaf.HCPCoupledEncoding
public import TCB.HCPObservation

@[expose] public section

/-!
# Canonical bytes of the full coupled Hodge cochain

The domain `HODGE_CIPHERTEXT_V1` is followed by the authenticated row and
column dimensions and one integer column packet. Coordinate order is the
separate exact edge, the information edges in increasing column order, and
the parity edges in increasing row order. The integers encode the entire
observed cochain, including its harmonic and coexact components.

The decoder checks both dimensions, the exact column shape, empty remainder
and canonical re-encoding. The public exact-component artifact remains the
original object; this optional full ciphertext is a separately named release.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.CoupledCiphertext

open Sheaf CellularSheaf
open CoupledCodec

abbrev IntegerCochain (rows cols : ℕ) :=
  HCPCoupledFamily.Index (Fin rows) (Fin cols) → ℤ

/-- Exact rational coordinates of the same decoded integer cochain.
This conversion is shared by direct recovery and held-token execution. -/
def rationalize {rows cols : ℕ} (v : IntegerCochain rows cols) :
    HCPCoupledFamily.Index (Fin rows) (Fin cols) → ℚ := fun p => (v p : ℚ)

/-- Exact ASCII bytes of the versioned full-cochain ciphertext domain. -/
def domain : Bytes :=
  [72, 79, 68, 71, 69, 95, 67, 73, 80, 72, 69, 82, 84, 69, 88, 84, 95, 86, 49]

/-- Explicit exact, information, parity ordering of all scalar edge values. -/
def entries {rows cols : ℕ} (v : IntegerCochain rows cols) : List ℤ :=
  v ⟨none, 0⟩ ::
    (List.ofFn (fun c : Fin cols => v ⟨some (.inl c), 0⟩) ++
      List.ofFn (fun r : Fin rows => v ⟨some (.inr r), 0⟩))

def packet {rows cols : ℕ} (v : IntegerCochain rows cols) : Packet where
  rows := 1 + cols + rows
  cols := 1
  entries := entries v
  length_entries := by simp [entries]; omega

@[simp] theorem packet_rows {rows cols : ℕ} (v : IntegerCochain rows cols) :
    (packet v).rows = 1 + cols + rows := rfl

@[simp] theorem packet_cols {rows cols : ℕ} (v : IntegerCochain rows cols) :
    (packet v).cols = 1 := rfl

/-- Position of an edge in the explicit scalar layout. -/
def position {rows cols : ℕ}
    (p : HCPCoupledFamily.Index (Fin rows) (Fin cols)) : ℕ :=
  match p.1 with
  | none => 0
  | some (.inl c) => 1 + c.val
  | some (.inr r) => 1 + cols + r.val

theorem position_lt {rows cols : ℕ}
    (p : HCPCoupledFamily.Index (Fin rows) (Fin cols)) :
    position p < 1 + cols + rows := by
  rcases p with ⟨e, j⟩
  cases e with
  | none => simp [position]
  | some e =>
    cases e with
    | inl c => simp only [position]; omega
    | inr r => simp only [position]; omega

def unpack {rows cols : ℕ} (p : Packet)
    (shape : p.rows = 1 + cols + rows ∧ p.cols = 1) : IntegerCochain rows cols :=
  fun edge => p.entries.get ⟨position edge, by
    rw [p.length_entries, shape.1, shape.2, Nat.mul_one]
    exact position_lt edge⟩

@[simp] theorem unpack_packet {rows cols : ℕ} (v : IntegerCochain rows cols) :
    unpack (packet v) ⟨rfl, rfl⟩ = v := by
  funext p
  rcases p with ⟨e, j⟩
  have hj : j = 0 := Subsingleton.elim _ _
  subst j
  cases e with
  | none => simp [unpack, packet, entries, position, List.get_eq_getElem]
  | some e =>
    cases e with
    | inl c =>
      have hc : 1 + c.val = c.val + 1 := by omega
      simp [unpack, packet, entries, position, List.get_eq_getElem,
        hc, c.isLt]
    | inr r =>
      have hr : 1 + cols + r.val = (cols + r.val) + 1 := by omega
      simp [unpack, packet, entries, position, List.get_eq_getElem,
        hr]

def encodeBody {rows cols : ℕ} (v : IntegerCochain rows cols) (rest : Bytes) : Bytes :=
  encodeNat rows (encodeNat cols (CoupledCodec.encodeBody (packet v) rest))

def encode {rows cols : ℕ} (v : IntegerCochain rows cols) : Bytes :=
  domain ++ encodeBody v []

def parseBody (bytes : Bytes) : Option (ℕ × ℕ × Packet × Bytes) := do
  let (rows, rest) ← parseNat bytes
  let (cols, rest) ← parseNat rest
  let (p, tail) ← CoupledCodec.parseBody rest
  some (rows, cols, p, tail)

@[simp] theorem parseBody_encodeBody {rows cols : ℕ}
    (v : IntegerCochain rows cols) (rest : Bytes) :
    parseBody (encodeBody v rest) = some (rows, cols, packet v, rest) := by
  simp [parseBody, encodeBody]

def decode (rows cols : ℕ) (bytes : Bytes) : Option (IntegerCochain rows cols) :=
  match parseBody (bytes.drop domain.length) with
  | none => none
  | some (encodedRows, encodedCols, p, rest) =>
    if _dimensions : encodedRows = rows ∧ encodedCols = cols then
      if shape : p.rows = 1 + cols + rows ∧ p.cols = 1 then
        let v := unpack p shape
        if rest = [] ∧ bytes = encode v then some v else none
      else none
    else none

@[simp] theorem decode_encode {rows cols : ℕ} (v : IntegerCochain rows cols) :
    decode rows cols (encode v) = some v := by
  simp [decode, encode]

theorem decode_eq_some_iff {rows cols : ℕ} (bytes : Bytes)
    (v : IntegerCochain rows cols) :
    decode rows cols bytes = some v ↔ bytes = encode v := by
  constructor
  · intro decoded
    unfold decode at decoded
    cases parsed : parseBody (bytes.drop domain.length) with
    | none => simp [parsed] at decoded
    | some value =>
      rcases value with ⟨encodedRows, encodedCols, p, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next dimensions =>
        split at decoded
        next shape =>
          split at decoded
          next canonical =>
            have same := Option.some.inj decoded
            exact canonical.2.trans (congrArg encode same)
          next => contradiction
        next => contradiction
      next => contradiction
  · rintro rfl
    exact decode_encode v

theorem encode_injective {rows cols : ℕ} :
    Function.Injective (@encode rows cols) := by
  intro v w same
  have decoded := congrArg (decode rows cols) same
  simpa only [decode_encode, Option.some.injEq] using decoded

theorem accepted_iff_canonical (rows cols : ℕ) (bytes : Bytes) :
    (∃ v, decode rows cols bytes = some v) ↔
      ∃ v : IntegerCochain rows cols, bytes = encode v := by
  simp only [decode_eq_some_iff]

/-- Parse full ciphertext bytes and check the separately named content digest. -/
def check (rows cols : ℕ) (hash : Bytes → TCB.Hash32)
    (ciphertextDigest : TCB.Hash32) (bytes : Bytes) : Option (IntegerCochain rows cols) := do
  let v ← decode rows cols bytes
  if hash bytes = ciphertextDigest then some v else none

theorem check_eq_some_iff {rows cols : ℕ} (hash : Bytes → TCB.Hash32)
    (ciphertextDigest : TCB.Hash32) (bytes : Bytes) (v : IntegerCochain rows cols) :
    check rows cols hash ciphertextDigest bytes = some v ↔
      bytes = encode v ∧ hash bytes = ciphertextDigest := by
  cases parsed : decode rows cols bytes with
  | none => simp [check, parsed, ← decode_eq_some_iff]
  | some w =>
    have canonical := (decode_eq_some_iff bytes w).mp parsed
    have hv : bytes = encode v ↔ w = v := by
      constructor
      · intro same
        exact encode_injective (canonical.symm.trans same)
      · rintro rfl
        exact canonical
    by_cases hhash : hash bytes = ciphertextDigest <;>
      simp [check, parsed, hhash, hv]

theorem check_encode {rows cols : ℕ} (hash : Bytes → TCB.Hash32)
    (v : IntegerCochain rows cols) :
    check rows cols hash (hash (encode v)) (encode v) = some v :=
  (check_eq_some_iff hash _ _ v).mpr ⟨rfl, rfl⟩

theorem encodeBody_append {rows cols : ℕ} (v : IntegerCochain rows cols)
    (rest suffix : Bytes) : encodeBody v rest ++ suffix = encodeBody v (rest ++ suffix) := by
  simp [encodeBody, encodeNat_append, CoupledCodec.encodeBody_append]

theorem parseBody_encode_append {rows cols : ℕ} (v : IntegerCochain rows cols)
    (suffix : Bytes) :
    parseBody ((encode v ++ suffix).drop domain.length) =
      some (rows, cols, packet v, suffix) := by
  rw [encode, List.append_assoc, List.drop_left, encodeBody_append]
  simp

theorem decode_rejects_trailing {rows cols : ℕ} (v : IntegerCochain rows cols)
    (suffix : Bytes) (nonempty : suffix ≠ []) :
    decode rows cols (encode v ++ suffix) = none := by
  simp [decode, parseBody_encode_append, nonempty]

theorem decode_rejects_dimensions {rows cols : ℕ} (v : IntegerCochain rows cols)
    (otherRows otherCols : ℕ) (wrong : rows ≠ otherRows ∨ cols ≠ otherCols) :
    decode otherRows otherCols (encode v) = none := by
  have bad : ¬ (rows = otherRows ∧ cols = otherCols) := by tauto
  simp [decode, encode, bad]

theorem decode_rejects_wrong_domain (rows cols : ℕ) (bytes : Bytes)
    (wrong : bytes.take domain.length ≠ domain) : decode rows cols bytes = none := by
  cases decoded : decode rows cols bytes with
  | none => rfl
  | some v =>
    have canonical := (decode_eq_some_iff bytes v).mp decoded
    apply False.elim
    apply wrong
    rw [canonical, encode, List.take_left]

theorem encode_prefix_free {rows cols : ℕ} (v w : IntegerCochain rows cols)
    (suffix : Bytes) (same : encode v ++ suffix = encode w) : suffix = [] := by
  have decoded := congrArg (decode rows cols) same
  by_contra nonempty
  rw [decode_rejects_trailing v suffix nonempty, decode_encode] at decoded
  contradiction

theorem decode_rejects_truncation {rows cols : ℕ} (v : IntegerCochain rows cols)
    (cut : ℕ) (short : cut < (encode v).length) :
    decode rows cols ((encode v).take cut) = none := by
  cases decoded : decode rows cols ((encode v).take cut) with
  | none => rfl
  | some w =>
    have canonical := (decode_eq_some_iff _ w).mp decoded
    have prefix_eq : encode w ++ (encode v).drop cut = encode v := by
      rw [← canonical, List.take_append_drop]
    have empty := encode_prefix_free w v _ prefix_eq
    have hlen := congrArg List.length empty
    simp only [List.length_drop, List.length_nil] at hlen
    omega

/-- Byte length grows with the number of coordinates and logarithms of their
integer magnitudes; the three dimension fields are also logarithmic. -/
theorem encode_length {rows cols : ℕ} (v : IntegerCochain rows cols) :
    (encode v).length = 19 +
      (2 * (Nat.digits 256 rows).length + 1) +
      (2 * (Nat.digits 256 cols).length + 1) +
      (2 * (Nat.digits 256 (1 + cols + rows)).length + 1) + 3 +
      ((entries v).map (fun z => 2 * (Nat.digits 256 z.natAbs).length + 2)).sum := by
  simp only [encode, List.length_append, encodeBody, CoupledCodec.encodeBody,
    encodeNat_length, encodeEntries_length, List.length_nil]
  have domain_length : domain.length = 19 := rfl
  have one_length : (Nat.digits 256 1).length = 1 := by decide
  simp only [packet, domain_length, one_length]
  omega

/-- Embed the decoded integer vector into the original real cochain carrier. -/
noncomputable def realize {rows cols : ℕ} (v : IntegerCochain rows cols) :
    HCPCoupledFamily.C1 (Fin rows) (Fin cols) :=
  WithLp.toLp 2 (fun p => (v p : ℝ))

/-- The executable integer decoder followed by its mathematical real embedding. -/
noncomputable def decodeReal (rows cols : ℕ) (bytes : Bytes) :
    Option (HCPCoupledFamily.C1 (Fin rows) (Fin cols)) :=
  (decode rows cols bytes).map realize

@[simp] theorem decodeReal_encode {rows cols : ℕ} (v : IntegerCochain rows cols) :
    decodeReal rows cols (encode v) = some (realize v) := by
  simp [decodeReal]

/-- Concrete bytes of the full observation of the original integral Hodge sample. -/
def sampleBytes {rows cols : ℕ} (B : Matrix (Fin rows) (Fin cols) ℤ)
    (z : Fin cols → ℤ) (a : ℤ) (u : Fin rows → ℤ) : Bytes :=
  encode (HCPCoupledEncoding.integerObserved B z a u)

@[simp] theorem decode_sampleBytes {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℤ)
    (z : Fin cols → ℤ) (a : ℤ) (u : Fin rows → ℤ) :
    decode rows cols (sampleBytes B z a u) =
      some (HCPCoupledEncoding.integerObserved B z a u) :=
  decode_encode _

/-- The full ciphertext decodes to the same original Hodge sample's observation. -/
theorem decodeReal_sampleBytes {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℤ)
    (z : Fin cols → ℤ) (a : ℤ) (u : Fin rows → ℤ) :
    decodeReal rows cols (sampleBytes B z a u) =
      some (HCPCoupledEncoding.sample B z a u).observed := by
  rw [sampleBytes, decodeReal_encode]
  exact congrArg some (HCPCoupledEncoding.integerObserved_cast_eq_observed B z a u)

/-- Private harmonic projection recovers the message from those decoded bytes. -/
theorem decoded_sample_recovers {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℤ)
    (z : Fin cols → ℤ) (a : ℤ) (u : Fin rows → ℤ) :
    (decodeReal rows cols (sampleBytes B z a u)).map
        (HCPCoupledFamily.sheaf B).harmonicOneProjection =
      some (HCPCoupledEncoding.sample B z a u).message.1 := by
  rw [decodeReal_sampleBytes]
  simp only [Option.map_some]
  rw [(HCPCoupledEncoding.sample B z a u).harmonicOneProjection_observed]

section OriginalObservation

variable {rows cols : ℕ} {B : Matrix (Fin rows) (Fin cols) ℤ}
  {payload : CochainPayloadInterpretation (HCPCoupledFamily.sheaf B)}
  {PublicClass Lifecycle : Type*}
  {classify : SheafStateSnapshot (HCPCoupledFamily.sheaf B) → PublicClass}
  {Binds : TCB.HCPStackBinding Lifecycle PublicClass
    (HCPCoupledFamily.C1 (Fin rows) (Fin cols))}

/-- A full ciphertext and its distinct content digest refer to the existing
bound observation. Its original exact artifact, snapshot and lifecycle remain
those retained by `O`; the ciphertext digest does not replace its artifact digest. -/
def BindsObservation (hash : Bytes → TCB.Hash32)
    (O : TCB.BoundHCPObservation (HCPCoupledFamily.integralStructure B)
      payload PublicClass Lifecycle classify Binds)
    (bytes : Bytes) (ciphertextDigest : TCB.Hash32) : Prop :=
  decodeReal rows cols bytes = some O.cochainObject ∧ hash bytes = ciphertextDigest

/-- The actual digest-checking parser supplies the same original-observation binding. -/
theorem bindsObservation_of_check (hash : Bytes → TCB.Hash32)
    (O : TCB.BoundHCPObservation (HCPCoupledFamily.integralStructure B)
      payload PublicClass Lifecycle classify Binds)
    (bytes : Bytes) (ciphertextDigest : TCB.Hash32) (v : IntegerCochain rows cols)
    (checked : check rows cols hash ciphertextDigest bytes = some v)
    (sameObserved : realize v = O.cochainObject) :
    BindsObservation hash O bytes ciphertextDigest := by
  obtain ⟨canonical, namedDigest⟩ := (check_eq_some_iff hash _ _ v).mp checked
  refine ⟨?_, namedDigest⟩
  rw [canonical, decodeReal_encode, sameObserved]

theorem sampleBytes_binds_original (hash : Bytes → TCB.Hash32)
    (O : TCB.BoundHCPObservation (HCPCoupledFamily.integralStructure B)
      payload PublicClass Lifecycle classify Binds)
    (z : Fin cols → ℤ) (a : ℤ) (u : Fin rows → ℤ)
    (sameSample : O.encrypted = HCPCoupledEncoding.sample B z a u) :
    BindsObservation hash O (sampleBytes B z a u) (hash (sampleBytes B z a u)) := by
  refine ⟨?_, rfl⟩
  rw [decodeReal_sampleBytes]
  change some (HCPCoupledEncoding.sample B z a u).observed = some O.encrypted.observed
  rw [sameSample]

end OriginalObservation

end HomotopicalEncryption.Protocol.Storage.CoupledCiphertext
