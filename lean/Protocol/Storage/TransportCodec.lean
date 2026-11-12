module

public import Protocol.Storage.CoupledCodec
public import Mathlib.Data.Rat.Defs

@[expose] public section

/-!
# Canonical rational transport-matrix bytes

A dimensioned rational matrix has a versioned domain, row and column counts,
and row-major reduced fractions. Each fraction encodes its signed numerator
and positive denominator using the existing binary integer/natural codec.
The executable parser rejects zero denominators and unreduced fractions;
exact final re-encoding rejects every noncanonical byte representation.
Its payload fields contain the derived map without separate source/target
presentation fields. This supplies no key-hiding guarantee: the map may itself
reveal presentation information. The codec establishes no confidentiality or
authorization contract.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.TransportCodec

open CoupledCodec

abbrev Bytes := List UInt8

/-- ASCII `HODGE_TRANSPORT_MATRIX_V1`. -/
def domain : Bytes := [72, 79, 68, 71, 69, 95, 84, 82, 65, 78, 83, 80, 79, 82, 84, 95, 77, 65, 84, 82, 73, 88, 95, 86, 49]

/-- A finite matrix packet with dimensions retained as data. -/
structure Packet where
  rows : ℕ
  cols : ℕ
  entries : List ℚ
  length_entries : entries.length = rows * cols
  deriving DecidableEq

@[ext] theorem Packet.ext {p q : Packet}
    (rows : p.rows = q.rows) (cols : p.cols = q.cols)
    (entries : p.entries = q.entries) : p = q := by
  cases p
  cases q
  simp_all

/-- Recover the matrix using row-major index `i * cols + j`. -/
def Packet.matrix (p : Packet) : Matrix (Fin p.rows) (Fin p.cols) ℚ :=
  fun i j => p.entries.get (Fin.cast p.length_entries.symm (finProdFinEquiv (i, j)))

/-- Every rational matrix has one explicitly ordered packet. -/
def ofMatrix {rows cols : ℕ} (B : Matrix (Fin rows) (Fin cols) ℚ) : Packet where
  rows := rows
  cols := cols
  entries := List.ofFn fun k : Fin (rows * cols) =>
    B (finProdFinEquiv.symm k).1 (finProdFinEquiv.symm k).2
  length_entries := List.length_ofFn

@[simp] theorem matrix_ofMatrix {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℚ) : (ofMatrix B).matrix = B := by
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
    (B : Matrix (Fin rows) (Fin cols) ℚ) : (ofMatrix B).rows = rows := rfl

@[simp] theorem ofMatrix_cols {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℚ) : (ofMatrix B).cols = cols := rfl

/-- Namespace spelling for the dimensioned matrix constructor. -/
abbrev Packet.ofMatrix {rows cols : ℕ} (B : Matrix (Fin rows) (Fin cols) ℚ) : Packet :=
  _root_.HomotopicalEncryption.Protocol.Storage.TransportCodec.ofMatrix B

/-- Namespace spelling for reconstruction of the actual rational matrix. -/
abbrev Packet.toMatrix (p : Packet) : Matrix (Fin p.rows) (Fin p.cols) ℚ := p.matrix

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

/-- A rational uses its unique reduced numerator and positive denominator. -/
def encodeRat (q : ℚ) (rest : Bytes) : Bytes :=
  encodeInt q.num (encodeNat q.den rest)

/-- Decode and require the parsed fraction to be in reduced canonical form. -/
def parseRat (bytes : Bytes) : Option (ℚ × Bytes) := do
  let (num, rest) ← parseInt bytes
  let (den, tail) ← parseNat rest
  if den = 0 then none
  else
    let q := mkRat num den
    if num = q.num ∧ den = q.den then some (q, tail) else none

@[simp] theorem parseRat_encodeRat (q : ℚ) (rest : Bytes) :
    parseRat (encodeRat q rest) = some (q, rest) := by
  simp [parseRat, encodeRat, Rat.mkRat_self]

/-- A zero denominator is rejected, including for a zero numerator. -/
theorem parseRat_rejects_zero_denominator (num : ℤ) (rest : Bytes) :
    parseRat (encodeInt num (encodeNat 0 rest)) = none := by
  simp [parseRat]

/-- An unreduced or otherwise noncanonical numerator/denominator pair rejects. -/
theorem parseRat_rejects_noncanonical (num : ℤ) (den : ℕ) (rest : Bytes)
    (bad : num ≠ (mkRat num den).num ∨ den ≠ (mkRat num den).den) :
    parseRat (encodeInt num (encodeNat den rest)) = none := by
  have hn : ¬ (num = (mkRat num den).num ∧ den = (mkRat num den).den) := by tauto
  by_cases hz : den = 0 <;> simp [parseRat, hz, hn]

def encodeEntries : List ℚ → Bytes → Bytes
  | [], rest => rest
  | z :: zs, rest => encodeRat z (encodeEntries zs rest)

def parseEntries : ℕ → Bytes → Option (List ℚ × Bytes)
  | 0, bytes => some ([], bytes)
  | n + 1, bytes => do
    let (z, rest) ← parseRat bytes
    let (zs, tail) ← parseEntries n rest
    some (z :: zs, tail)

@[simp] theorem parseEntries_encodeEntries (zs : List ℚ) (rest : Bytes) :
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

/-- Accepted bytes are exactly an encoding of a dimensioned rational matrix packet. -/
theorem accepted_iff_canonical (bytes : Bytes) :
    (∃ p, decode bytes = some p) ↔ ∃ p, bytes = encode p := by
  simp only [decode_eq_some_iff]

/-- Fixed-dimension matrix decoding also checks the dimensions from the bytes. -/
def decodeMatrix (rows cols : ℕ) (bytes : Bytes) :
    Option (Matrix (Fin rows) (Fin cols) ℚ) := do
  let p ← decode bytes
  if h : p.rows = rows ∧ p.cols = cols then
    some (fun i j => p.matrix (Fin.cast h.1.symm i) (Fin.cast h.2.symm j))
  else none

@[simp] theorem decodeMatrix_encode {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℚ) :
    decodeMatrix rows cols (encode (ofMatrix B)) = some B := by
  simp [decodeMatrix]

theorem decodeMatrix_rejects_dimensions (p : Packet) (rows cols : ℕ)
    (wrong : p.rows ≠ rows ∨ p.cols ≠ cols) :
    decodeMatrix rows cols (encode p) = none := by
  have bad : ¬ (p.rows = rows ∧ p.cols = cols) := by tauto
  simp [decodeMatrix, bad]

theorem encode_matrix_injective {rows cols : ℕ} :
    Function.Injective (fun B : Matrix (Fin rows) (Fin cols) ℚ => encode (ofMatrix B)) := by
  intro B C same
  have decoded := congrArg (decodeMatrix rows cols) same
  simpa only [decodeMatrix_encode, Option.some.injEq] using decoded

theorem encodeRat_append (q : ℚ) (rest suffix : Bytes) :
    encodeRat q rest ++ suffix = encodeRat q (rest ++ suffix) := by
  simp [encodeRat, CoupledCodec.encodeInt_append, CoupledCodec.encodeNat_append]

theorem encodeEntries_append (qs : List ℚ) (rest suffix : Bytes) :
    encodeEntries qs rest ++ suffix = encodeEntries qs (rest ++ suffix) := by
  induction qs with
  | nil => rfl
  | cons q qs ih => simp [encodeEntries, encodeRat_append, ih]

theorem encodeBody_append (p : Packet) (rest suffix : Bytes) :
    encodeBody p rest ++ suffix = encodeBody p (rest ++ suffix) := by
  simp [encodeBody, CoupledCodec.encodeNat_append, encodeEntries_append]

/-- Parsing consumes exactly one complete packet and retains its suffix. -/
theorem parseBody_encode_append (p : Packet) (suffix : Bytes) :
    parseBody ((encode p ++ suffix).drop domain.length) = some (p, suffix) := by
  rw [encode, List.append_assoc, List.drop_left, encodeBody_append]
  simp

/-- Nonempty bytes following a complete matrix are rejected. -/
theorem decode_rejects_trailing (p : Packet) (suffix : Bytes) (nonempty : suffix ≠ []) :
    decode (encode p ++ suffix) = none := by
  simp [decode, parseBody_encode_append, nonempty]

/-- A changed version/domain rejects independently of the encoded body. -/
theorem decode_rejects_wrong_domain (bytes : Bytes)
    (wrong : bytes.take domain.length ≠ domain) : decode bytes = none := by
  cases decoded : decode bytes with
  | none => rfl
  | some p =>
    have canonical := (decode_eq_some_iff bytes p).mp decoded
    apply False.elim
    apply wrong
    rw [canonical, encode, List.take_left]

/-- No complete canonical matrix is a proper prefix of another. -/
theorem encode_prefix_free (p q : Packet) (suffix : Bytes)
    (same : encode p ++ suffix = encode q) : suffix = [] := by
  have decoded := congrArg decode same
  by_contra nonempty
  rw [decode_rejects_trailing p suffix nonempty, decode_encode] at decoded
  contradiction

/-- Every proper truncation of a complete canonical matrix is rejected. -/
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

/-- Each reduced fraction uses the binary magnitudes of its numerator and denominator. -/
theorem encodeRat_length (q : ℚ) (rest : Bytes) :
    (encodeRat q rest).length =
      2 * (Nat.digits 256 q.num.natAbs).length +
      2 * (Nat.digits 256 q.den).length + 3 + rest.length := by
  simp only [encodeRat, CoupledCodec.encodeInt_length, CoupledCodec.encodeNat_length]
  omega

theorem encodeEntries_length (qs : List ℚ) (rest : Bytes) :
    (encodeEntries qs rest).length =
      (qs.map (fun q => 2 * (Nat.digits 256 q.num.natAbs).length +
        2 * (Nat.digits 256 q.den).length + 3)).sum + rest.length := by
  induction qs with
  | nil => simp [encodeEntries]
  | cons q qs ih => simp [encodeEntries, encodeRat_length, ih, Nat.add_assoc]

/-- Matrix byte size is linear in its entry count and binary magnitude lengths. -/
theorem encode_length (p : Packet) :
    (encode p).length = 25 +
      (2 * (Nat.digits 256 p.rows).length + 1) +
      (2 * (Nat.digits 256 p.cols).length + 1) +
      (p.entries.map (fun q => 2 * (Nat.digits 256 q.num.natAbs).length +
        2 * (Nat.digits 256 q.den).length + 3)).sum := by
  simp only [encode, List.length_append, encodeBody, CoupledCodec.encodeNat_length,
    encodeEntries_length, List.length_nil]
  have domain_length : domain.length = 25 := rfl
  rw [domain_length]
  omega

end HomotopicalEncryption.Protocol.Storage.TransportCodec
