module

public import Mathlib.Data.Nat.Digits.Lemmas
public import Mathlib.Data.Matrix.Basic
public import Mathlib.Data.List.OfFn
public import Mathlib.Logic.Equiv.Fin.Basic

@[expose] public section

/-!
# Canonical bytes for an integer coupling matrix

The domain includes version 1. Rows and columns precede the row-major integer
entries. Natural numbers use little-endian base-256 digits, with each byte
prefixed by 1 and the digit string terminated by 0. An integer has a sign byte
(0 for nonnegative, 1 for negative) and the natural magnitude; negative zero
is rejected. The decoder consumes exactly rows times columns entries and
requires both empty remainder and exact canonical re-encoding.

This executable codec supplies no hash or hiding assumption.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.CoupledCodec

abbrev Bytes := List UInt8

/-- The exact ASCII domain `HODGE_COUPLING_V1`. -/
def domain : Bytes := [72, 79, 68, 71, 69, 95, 67, 79, 85, 80, 76, 73, 78, 71, 95, 86, 49]

/-- A finite matrix packet with dimensions retained as data. -/
structure Packet where
  rows : ℕ
  cols : ℕ
  entries : List ℤ
  length_entries : entries.length = rows * cols
  deriving DecidableEq

@[ext] theorem Packet.ext {p q : Packet}
    (rows : p.rows = q.rows) (cols : p.cols = q.cols)
    (entries : p.entries = q.entries) : p = q := by
  cases p
  cases q
  simp_all

/-- Recover the matrix using row-major index `i * cols + j`. -/
def Packet.matrix (p : Packet) : Matrix (Fin p.rows) (Fin p.cols) ℤ :=
  fun i j => p.entries.get (Fin.cast p.length_entries.symm (finProdFinEquiv (i, j)))

/-- Every integer matrix has one explicitly ordered packet. -/
def ofMatrix {rows cols : ℕ} (B : Matrix (Fin rows) (Fin cols) ℤ) : Packet where
  rows := rows
  cols := cols
  entries := List.ofFn fun k : Fin (rows * cols) =>
    B (finProdFinEquiv.symm k).1 (finProdFinEquiv.symm k).2
  length_entries := List.length_ofFn

@[simp] theorem matrix_ofMatrix {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℤ) : (ofMatrix B).matrix = B := by
  funext i j
  change Fin rows at i
  change Fin cols at j
  change (List.ofFn (fun k : Fin (rows * cols) =>
    B (finProdFinEquiv.symm k).1 (finProdFinEquiv.symm k).2))[
      (finProdFinEquiv (i, j)).val]'(by simpa using (finProdFinEquiv (i, j)).isLt) = B i j
  rw [List.getElem_ofFn]
  change B (finProdFinEquiv.symm (finProdFinEquiv (i, j))).1
    (finProdFinEquiv.symm (finProdFinEquiv (i, j))).2 = B i j
  rw [Equiv.symm_apply_apply]

@[simp] theorem ofMatrix_rows {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℤ) : (ofMatrix B).rows = rows := rfl

@[simp] theorem ofMatrix_cols {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℤ) : (ofMatrix B).cols = cols := rfl

/-- Namespace spelling for the dimensioned matrix constructor. -/
abbrev Packet.ofMatrix {rows cols : ℕ} (B : Matrix (Fin rows) (Fin cols) ℤ) : Packet :=
  _root_.HomotopicalEncryption.Protocol.Storage.CoupledCodec.ofMatrix B

/-- Namespace spelling for reconstruction of the actual integer matrix. -/
abbrev Packet.toMatrix (p : Packet) : Matrix (Fin p.rows) (Fin p.cols) ℤ := p.matrix

/-- Reconstructing and then flattening retains every packet entry. -/
@[simp] theorem ofMatrix_matrix (p : Packet) : ofMatrix p.matrix = p := by
  apply Packet.ext (p := ofMatrix p.matrix) (q := p) rfl rfl
  change List.ofFn (fun k : Fin (p.rows * p.cols) =>
    p.matrix (finProdFinEquiv.symm k).1 (finProdFinEquiv.symm k).2) = p.entries
  apply List.ext_getElem (by simp [p.length_entries])
  intro i hi hj
  have ibound : i < p.rows * p.cols := by simpa using hi
  rw [List.getElem_ofFn]
  change p.entries.get (Fin.cast p.length_entries.symm
    (finProdFinEquiv (finProdFinEquiv.symm ⟨i, ibound⟩))) = p.entries[i]'hj
  rw [Equiv.apply_symm_apply]
  rfl

/-- Tag arbitrary digits so the terminator cannot occur inside a digit. -/
def frame : Bytes → Bytes → Bytes
  | [], rest => 0 :: rest
  | byte :: digits, rest => 1 :: byte :: frame digits rest

def parseFrame : Bytes → Option (Bytes × Bytes)
  | [] => none
  | tag :: rest =>
    if tag = 0 then some ([], rest)
    else match rest with
      | [] => none
      | byte :: tail =>
        if tag = 1 then
          (parseFrame tail).map (fun value => (byte :: value.1, value.2))
        else none

theorem parseFrame_frame (digits rest : Bytes) :
    parseFrame (frame digits rest) = some (digits, rest) := by
  induction digits with
  | nil => cases rest <;> rfl
  | cons byte digits ih => simp [frame, parseFrame, ih]

theorem frame_append (digits rest suffix : Bytes) :
    frame digits rest ++ suffix = frame digits (rest ++ suffix) := by
  induction digits with
  | nil => rfl
  | cons byte digits ih => simp [frame, ih]

def natDigits (n : ℕ) : Bytes := (Nat.digits 256 n).map UInt8.ofNat

def natValue (digits : Bytes) : ℕ := Nat.ofDigits 256 (digits.map UInt8.toNat)

theorem natValue_natDigits (n : ℕ) : natValue (natDigits n) = n := by
  unfold natValue natDigits
  rw [List.map_map]
  have hmap : (Nat.digits 256 n).map (UInt8.toNat ∘ UInt8.ofNat) = Nat.digits 256 n := by
    calc
      _ = (Nat.digits 256 n).map id := List.map_congr_left (by
        intro digit hdigit
        exact UInt8.toNat_ofNat_of_lt' (Nat.digits_lt_base (by decide) hdigit))
      _ = _ := List.map_id _
  rw [hmap, Nat.ofDigits_digits]

def encodeNat (n : ℕ) (rest : Bytes) : Bytes := frame (natDigits n) rest

def parseNat (bytes : Bytes) : Option (ℕ × Bytes) :=
  (parseFrame bytes).map fun value => (natValue value.1, value.2)

@[simp] theorem parseNat_encodeNat (n : ℕ) (rest : Bytes) :
    parseNat (encodeNat n rest) = some (n, rest) := by
  simp [parseNat, encodeNat, parseFrame_frame, natValue_natDigits]

def encodeInt : ℤ → Bytes → Bytes
  | .ofNat n, rest => 0 :: encodeNat n rest
  | .negSucc n, rest => 1 :: encodeNat (n + 1) rest

def parseInt : Bytes → Option (ℤ × Bytes)
  | [] => none
  | sign :: rest => do
    let (magnitude, tail) ← parseNat rest
    if sign = 0 then some (Int.ofNat magnitude, tail)
    else if sign = 1 ∧ magnitude ≠ 0 then some (-Int.ofNat magnitude, tail)
    else none

@[simp] theorem parseInt_encodeInt (z : ℤ) (rest : Bytes) :
    parseInt (encodeInt z rest) = some (z, rest) := by
  cases z <;> simp [encodeInt, parseInt, Int.negSucc_eq]

def encodeEntries : List ℤ → Bytes → Bytes
  | [], rest => rest
  | z :: zs, rest => encodeInt z (encodeEntries zs rest)

def parseEntries : ℕ → Bytes → Option (List ℤ × Bytes)
  | 0, bytes => some ([], bytes)
  | n + 1, bytes => do
    let (z, rest) ← parseInt bytes
    let (zs, tail) ← parseEntries n rest
    some (z :: zs, tail)

@[simp] theorem parseEntries_encodeEntries (zs : List ℤ) (rest : Bytes) :
    parseEntries zs.length (encodeEntries zs rest) = some (zs, rest) := by
  induction zs with
  | nil => rfl
  | cons z zs ih => simp [encodeEntries, parseEntries, ih]

def encodeBody (p : Packet) (rest : Bytes) : Bytes :=
  encodeNat p.rows (encodeNat p.cols (encodeEntries p.entries rest))

def encode (p : Packet) : Bytes := domain ++ encodeBody p []

def parseBody (bytes : Bytes) : Option (Packet × Bytes) := do
  let (rows, rest) ← parseNat bytes
  let (cols, rest) ← parseNat rest
  let (entries, tail) ← parseEntries (rows * cols) rest
  if h : entries.length = rows * cols then some (⟨rows, cols, entries, h⟩, tail)
  else none

@[simp] theorem parseBody_encodeBody (p : Packet) (rest : Bytes) :
    parseBody (encodeBody p rest) = some (p, rest) := by
  cases p with
  | mk rows cols entries length_entries =>
    simp [parseBody, encodeBody, ← length_entries, parseEntries_encodeEntries]

def decode (bytes : Bytes) : Option Packet :=
  match parseBody (bytes.drop domain.length) with
  | none => none
  | some (p, rest) =>
    if rest = [] ∧ bytes = encode p then some p else none

@[simp] theorem decode_encode (p : Packet) : decode (encode p) = some p := by
  simp [decode, encode, parseBody_encodeBody]

theorem decode_eq_some_iff (bytes : Bytes) (p : Packet) :
    decode bytes = some p ↔ bytes = encode p := by
  constructor
  · intro decoded
    unfold decode at decoded
    cases parsed : parseBody (bytes.drop domain.length) with
    | none => simp [parsed] at decoded
    | some value =>
      rcases value with ⟨q, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next same =>
        have hp : q = p := Option.some.inj decoded
        subst q
        exact same.2
      next => contradiction
  · rintro rfl
    exact decode_encode p

theorem encode_injective : Function.Injective encode := by
  intro p q h
  have decoded := congrArg decode h
  simpa only [decode_encode, Option.some.injEq] using decoded

/-- Accepted bytes are exactly an encoding of a dimensioned integer matrix packet. -/
theorem accepted_iff_canonical (bytes : Bytes) :
    (∃ p, decode bytes = some p) ↔ ∃ p, bytes = encode p := by
  simp only [decode_eq_some_iff]

/-- Fixed-dimension matrix decoding also checks the dimensions from the bytes. -/
def decodeMatrix (rows cols : ℕ) (bytes : Bytes) :
    Option (Matrix (Fin rows) (Fin cols) ℤ) := do
  let p ← decode bytes
  if h : p.rows = rows ∧ p.cols = cols then
    some (fun i j => p.matrix (Fin.cast h.1.symm i) (Fin.cast h.2.symm j))
  else none

@[simp] theorem decodeMatrix_encode {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℤ) :
    decodeMatrix rows cols (encode (ofMatrix B)) = some B := by
  simp [decodeMatrix]

theorem decodeMatrix_rejects_dimensions (p : Packet) (rows cols : ℕ)
    (wrong : p.rows ≠ rows ∨ p.cols ≠ cols) :
    decodeMatrix rows cols (encode p) = none := by
  have bad : ¬ (p.rows = rows ∧ p.cols = cols) := by tauto
  simp [decodeMatrix, bad]

theorem encode_matrix_injective {rows cols : ℕ} :
    Function.Injective (fun B : Matrix (Fin rows) (Fin cols) ℤ => encode (ofMatrix B)) := by
  intro B C same
  have decoded := congrArg (decodeMatrix rows cols) same
  simpa only [decodeMatrix_encode, Option.some.injEq] using decoded

theorem encodeNat_append (n : ℕ) (rest suffix : Bytes) :
    encodeNat n rest ++ suffix = encodeNat n (rest ++ suffix) :=
  frame_append _ _ _

theorem encodeInt_append (z : ℤ) (rest suffix : Bytes) :
    encodeInt z rest ++ suffix = encodeInt z (rest ++ suffix) := by
  cases z <;> simp [encodeInt, encodeNat_append]

theorem encodeEntries_append (zs : List ℤ) (rest suffix : Bytes) :
    encodeEntries zs rest ++ suffix = encodeEntries zs (rest ++ suffix) := by
  induction zs with
  | nil => rfl
  | cons z zs ih => simp [encodeEntries, encodeInt_append, ih]

theorem encodeBody_append (p : Packet) (rest suffix : Bytes) :
    encodeBody p rest ++ suffix = encodeBody p (rest ++ suffix) := by
  simp [encodeBody, encodeNat_append, encodeEntries_append]

/-- The body parser consumes exactly the encoded packet and retains the suffix. -/
theorem parseBody_encode_append (p : Packet) (suffix : Bytes) :
    parseBody ((encode p ++ suffix).drop domain.length) = some (p, suffix) := by
  rw [encode, List.append_assoc, List.drop_left, encodeBody_append]
  simp

/-- Any nonempty suffix after the complete packet is rejected. -/
theorem decode_rejects_trailing (p : Packet) (suffix : Bytes) (nonempty : suffix ≠ []) :
    decode (encode p ++ suffix) = none := by
  simp [decode, parseBody_encode_append, nonempty]

/-- A changed version/domain is rejected independently of the rest of the body. -/
theorem decode_rejects_wrong_domain (bytes : Bytes)
    (wrong : bytes.take domain.length ≠ domain) : decode bytes = none := by
  cases decoded : decode bytes with
  | none => rfl
  | some p =>
    have canonical := (decode_eq_some_iff bytes p).mp decoded
    apply False.elim
    apply wrong
    rw [canonical, encode, List.take_left]

/-- A complete packet is never a proper prefix of another complete packet. -/
theorem encode_prefix_free (p q : Packet) (suffix : Bytes)
    (same : encode p ++ suffix = encode q) : suffix = [] := by
  have decoded := congrArg decode same
  by_contra nonempty
  rw [decode_rejects_trailing p suffix nonempty, decode_encode] at decoded
  contradiction

/-- Every proper byte truncation is rejected. -/
theorem decode_rejects_truncation (p : Packet) (cut : ℕ)
    (short : cut < (encode p).length) : decode ((encode p).take cut) = none := by
  cases decoded : decode ((encode p).take cut) with
  | none => rfl
  | some q =>
    have canonical := (decode_eq_some_iff _ q).mp decoded
    have prefix_eq : encode q ++ (encode p).drop cut = encode p := by
      rw [← canonical, List.take_append_drop]
    have empty := encode_prefix_free q p _ prefix_eq
    have hlen := congrArg List.length empty
    simp only [List.length_drop, List.length_nil] at hlen
    omega

theorem frame_length (digits rest : Bytes) :
    (frame digits rest).length = 2 * digits.length + 1 + rest.length := by
  induction digits with
  | nil => simp [frame, Nat.add_comm]
  | cons byte digits ih => simp only [frame, List.length_cons, ih]; omega

/-- Natural magnitudes have logarithmic base-256 digit length. -/
theorem encodeNat_length (n : ℕ) (rest : Bytes) :
    (encodeNat n rest).length = 2 * (Nat.digits 256 n).length + 1 + rest.length := by
  simp [encodeNat, frame_length, natDigits]

theorem encodeInt_length (z : ℤ) (rest : Bytes) :
    (encodeInt z rest).length = 2 * (Nat.digits 256 z.natAbs).length + 2 + rest.length := by
  cases z <;> simp [encodeInt, encodeNat_length, Nat.succ_eq_add_one] <;> omega

theorem nat_digit_length (n : ℕ) (positive : 0 < n) :
    (Nat.digits 256 n).length = Nat.log 256 n + 1 :=
  Nat.length_digits 256 n (by decide) (Nat.ne_of_gt positive)

theorem encodeEntries_length (zs : List ℤ) (rest : Bytes) :
    (encodeEntries zs rest).length =
      (zs.map (fun z => 2 * (Nat.digits 256 z.natAbs).length + 2)).sum + rest.length := by
  induction zs with
  | nil => simp [encodeEntries]
  | cons z zs ih =>
    simp [encodeEntries, encodeInt_length, ih, Nat.add_assoc]

/-- The complete byte length is linear in the number of matrix entries and
their base-256 digit lengths, with logarithmic dimension headers. -/
theorem encode_length (p : Packet) :
    (encode p).length = 17 +
      (2 * (Nat.digits 256 p.rows).length + 1) +
      (2 * (Nat.digits 256 p.cols).length + 1) +
      (p.entries.map (fun z => 2 * (Nat.digits 256 z.natAbs).length + 2)).sum := by
  simp only [encode, List.length_append, encodeBody, encodeNat_length,
    encodeEntries_length, List.length_nil]
  have domain_length : domain.length = 17 := rfl
  rw [domain_length]
  omega

end HomotopicalEncryption.Protocol.Storage.CoupledCodec
