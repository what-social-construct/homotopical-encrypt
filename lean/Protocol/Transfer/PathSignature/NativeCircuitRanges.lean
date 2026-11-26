module

public import Protocol.Transfer.PathSignature.NativeCircuitBounds
public import Mathlib.Algebra.BigOperators.Fin
public import Mathlib.Algebra.Field.ZMod

@[expose] public section

/-!
# Binary range gates for the native ciphertext circuit

For a wire bounded by `K`, two binary decompositions encode `x + K` and
`K - x`. Their field values sum to `2K`. With a large enough prime modulus,
the sum is an integer equality, and the original field wire has a unique
signed lift in `[-K, K]`. Applying this to every existing wire gives the
integer ranges consumed by the native circuit's no-wrap theorem.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCircuitRanges

open NativeCircuit NativeCircuitBounds
open scoped BigOperators

/-- The number of bits needed to represent every shift or slack up to `2K`. -/
def width (bound : ℕ) : ℕ := (2 * bound).log2 + 1

/-- A modulus at least this large cannot wrap the sum of the two digit vectors. -/
def modulusBound (bound : ℕ) : ℕ := 2 ^ (width bound + 1)

private theorem twice_bound_lt_width (bound : ℕ) : 2 * bound < 2 ^ width bound :=
  Nat.lt_log2_self

/-- The two auxiliary binary representations associated with one native wire. -/
inductive Side where
  | shifted
  | slack
  deriving DecidableEq

/-- The added rank-one gates on a single wire. -/
inductive Gate (bound : ℕ) where
  | bit (side : Side) (index : Fin (width bound))
  | shifted
  | sum
  deriving DecidableEq

/-- The affine forms used in the range gates. -/
inductive Form (bound : ℕ) where
  | one
  | zero
  | bit (side : Side) (index : Fin (width bound))
  | bitMinusOne (side : Side) (index : Fin (width bound))
  | shiftedWire
  | recomposition (side : Side)
  | weightedSum
  | twiceBound

variable {bound : ℕ}

/-- Binary recomposition in the coefficient ring. -/
def weighted {R : Type*} [CommRing R] {bits : ℕ} (values : Fin bits → R) : R :=
  ∑ i, values i * ((2 ^ i.val : ℕ) : R)

def Form.eval {R : Type*} [CommRing R] (value : R) (digits : Side → Fin (width bound) → R) :
    Form bound → R
  | .one => 1
  | .zero => 0
  | .bit side i => digits side i
  | .bitMinusOne side i => digits side i - 1
  | .shiftedWire => value + (bound : R)
  | .recomposition side => weighted (digits side)
  | .weightedSum => weighted (digits .shifted) + weighted (digits .slack)
  | .twiceBound => (2 * bound : ℕ)

structure Constraint (bound : ℕ) where
  left : Form bound
  right : Form bound
  output : Form bound

def compile : Gate bound → Constraint bound
  | .bit side i => ⟨.bit side i, .bitMinusOne side i, .zero⟩
  | .shifted => ⟨.shiftedWire, .one, .recomposition .shifted⟩
  | .sum => ⟨.weightedSum, .one, .twiceBound⟩

def Constraint.Satisfied {R : Type*} [CommRing R] (constraint : Constraint bound)
    (value : R) (digits : Side → Fin (width bound) → R) : Prop :=
  constraint.left.eval value digits * constraint.right.eval value digits =
    constraint.output.eval value digits

def gates (bound : ℕ) : List (Gate bound) :=
  (List.finRange (width bound)).map (Gate.bit .shifted) ++
  (List.finRange (width bound)).map (Gate.bit .slack) ++ [.shifted, .sum]

theorem mem_gates (gate : Gate bound) : gate ∈ gates bound := by
  cases gate with
  | bit side i => cases side <;> simp [gates]
  | shifted => simp [gates]
  | sum => simp [gates]

/-- Each wire adds two affine gates and two Boolean gates per bit position. -/
theorem gates_length (bound : ℕ) : (gates bound).length = 2 * width bound + 2 := by
  simp [gates, two_mul, Nat.add_assoc]

def Satisfied {R : Type*} [CommRing R] (value : R)
    (digits : Side → Fin (width bound) → R) : Prop :=
  ∀ gate, (compile gate).Satisfied value digits

theorem satisfied_iff_list {R : Type*} [CommRing R] (value : R)
    (digits : Side → Fin (width bound) → R) :
    Satisfied value digits ↔ ∀ gate ∈ gates bound, (compile gate).Satisfied value digits :=
  ⟨fun h gate _ => h gate, fun h gate => h gate (mem_gates gate)⟩

private theorem bit_zero_or_one {R : Type*} [CommRing R] [IsDomain R] {b : R}
    (h : b * (b - 1) = 0) : b = 0 ∨ b = 1 := by
  rcases mul_eq_zero.mp h with h | h
  · exact Or.inl h
  · exact Or.inr (sub_eq_zero.mp h)

/-- Natural recomposition of a vector of binary digits. -/
def digitValue {bits : ℕ} (digits : Fin bits → Fin 2) : Fin (2 ^ bits) :=
  finFunctionFinEquiv digits

private theorem weighted_digitValue {R : Type*} [CommRing R] {bits : ℕ}
    (digits : Fin bits → Fin 2) :
    weighted (fun i => ((digits i).val : R)) = ((digitValue digits).val : R) := by
  simp [weighted, digitValue, Nat.cast_sum]

private theorem exists_digitValue {R : Type*} [CommRing R] [IsDomain R] {bits : ℕ}
    (digits : Fin bits → R) (checked : ∀ i, digits i * (digits i - 1) = 0) :
    ∃ n : Fin (2 ^ bits), weighted digits = (n.val : R) := by
  classical
  let binary : Fin bits → Fin 2 := fun i => if digits i = 0 then 0 else 1
  refine ⟨digitValue binary, ?_⟩
  rw [← weighted_digitValue]
  congr 1
  funext i
  rcases bit_zero_or_one (checked i) with h | h
  · simp [binary, h]
  · simp [binary, h]

/-- The auxiliary digit values for a supplied bounded integer. -/
def honestDigits {R : Type*} [CommRing R] (bound : ℕ) (value : ℤ)
    (within : |value| ≤ (bound : ℤ)) : Side → Fin (width bound) → R :=
  fun side index =>
    let shift : ℤ := match side with
      | .shifted => value + bound
      | .slack => (bound : ℤ) - value
    have fits : shift.toNat < 2 ^ width bound := by
      have cap := twice_bound_lt_width bound
      cases side <;> dsimp [shift] <;> have h := abs_le.mp within <;> omega
    ((finFunctionFinEquiv.symm (⟨shift.toNat, fits⟩ : Fin (2 ^ width bound)) index).val : R)

private theorem weighted_honestDigits {R : Type*} [CommRing R] (bound : ℕ) (value : ℤ)
    (within : |value| ≤ (bound : ℤ)) (side : Side) :
    weighted (honestDigits (R := R) bound value within side) =
      (match side with | .shifted => ((value + (bound : ℤ) : ℤ) : R)
                       | .slack => (((bound : ℤ) - value : ℤ) : R)) := by
  cases side <;> unfold honestDigits <;> rw [weighted_digitValue] <;>
    simp only [digitValue, Equiv.apply_symm_apply] <;>
    rw [← Int.cast_natCast, Int.toNat_of_nonneg] <;>
    have h := abs_le.mp within <;> omega

private theorem cast_fin_bit {R : Type*} [CommRing R] (bit : Fin 2) :
    (bit.val : R) * ((bit.val : R) - 1) = 0 := by
  fin_cases bit <;> simp

/-- Every integer in the original range has a satisfying digit assignment. -/
theorem honestDigits_satisfied {R : Type*} [CommRing R] (bound : ℕ) (value : ℤ)
    (within : |value| ≤ (bound : ℤ)) :
    Satisfied (value : R) (honestDigits bound value within) := by
  intro gate
  cases gate with
  | bit side i =>
    change honestDigits bound value within side i *
      (honestDigits bound value within side i - 1 : R) = 0
    unfold honestDigits
    exact cast_fin_bit _
  | shifted =>
    simp [compile, Constraint.Satisfied, Form.eval, weighted_honestDigits]
  | sum =>
    simp [compile, Constraint.Satisfied, Form.eval, weighted_honestDigits]
    ring

private theorem nat_eq_of_cast_eq {p a b : ℕ} (ha : a < p) (hb : b < p)
    (eq : (a : ZMod p) = (b : ZMod p)) : a = b := by
  have eqVal := congrArg ZMod.val eq
  simpa only [ZMod.val_natCast, Nat.mod_eq_of_lt ha, Nat.mod_eq_of_lt hb] using eqVal

/-- Satisfied field constraints recover a signed lift with the promised integer range. -/
theorem exists_lift {p : ℕ} [Fact p.Prime] (value : ZMod p)
    (digits : Side → Fin (width bound) → ZMod p)
    (large : modulusBound bound ≤ p) (checked : Satisfied value digits) :
    ∃ lifted : ℤ, |lifted| ≤ (bound : ℤ) ∧ (lifted : ZMod p) = value := by
  have bits (side : Side) (i : Fin (width bound)) :
      digits side i * (digits side i - 1) = 0 := checked (.bit side i)
  obtain ⟨shifted, shifted_eq⟩ := exists_digitValue (digits .shifted) (bits .shifted)
  obtain ⟨slack, slack_eq⟩ := exists_digitValue (digits .slack) (bits .slack)
  have shifted_gate : (value + (bound : ZMod p)) * 1 = weighted (digits .shifted) :=
    checked .shifted
  have sum_gate :
      (weighted (digits .shifted) + weighted (digits .slack)) * 1 =
        ((2 * bound : ℕ) : ZMod p) := checked .sum
  have shifted_lt := shifted.isLt
  have slack_lt := slack.isLt
  have cap := twice_bound_lt_width bound
  rw [modulusBound, pow_succ] at large
  have exact_sum : shifted.val + slack.val = 2 * bound :=
    nat_eq_of_cast_eq (p := p) (a := shifted.val + slack.val) (b := 2 * bound)
      (by omega) (by omega) (by
      simpa only [mul_one, shifted_eq, slack_eq, Nat.cast_add] using sum_gate)
  refine ⟨(shifted.val : ℤ) - bound, abs_le.mpr ⟨by omega, by omega⟩, ?_⟩
  simp only [mul_one, shifted_eq] at shifted_gate
  rw [Int.cast_sub, Int.cast_natCast, Int.cast_natCast, ← shifted_gate, add_sub_cancel_right]

/-- A second bounded lift of the same residue must equal the first. -/
theorem lift_unique {p : ℕ} {left right : ℤ} (large : modulusBound bound ≤ p)
    (hl : |left| ≤ (bound : ℤ)) (hr : |right| ≤ (bound : ℤ))
    (same : (left : ZMod p) = (right : ZMod p)) : left = right := by
  have cap := twice_bound_lt_width bound
  rw [modulusBound, pow_succ] at large
  have bounded : |right - left| < (p : ℤ) := by
    rw [abs_lt]
    obtain ⟨hl₁, hl₂⟩ := abs_le.mp hl
    obtain ⟨hr₁, hr₂⟩ := abs_le.mp hr
    omega
  exact sub_eq_zero.mp (Int.eq_zero_of_abs_lt_dvd
    ((ZMod.intCast_eq_intCast_iff_dvd_sub _ _ _).mp same) bounded) |>.symm

section Native

variable {rows cols : ℕ}

/-- Extend each existing native wire with the digits sized by its own range. -/
abbrev Digits (profile : NativeRelation.Profile) (R : Type*) :=
  (wire : Wire rows cols) → Side → Fin (width (wireBound profile wire)) → R

/-- The native arithmetic system and the added binary gates share the same field wires. -/
def Checked {R : Type*} [CommRing R] (profile : NativeRelation.Profile)
    (values : Wire rows cols → R) (digits : Digits (rows := rows) (cols := cols) profile R) : Prop :=
  NativeCircuit.Satisfied values ∧ ∀ wire, Satisfied (values wire) (digits wire)

/-! The compiler can append these gates to the existing native gate list. Each
entry keeps the wire index needed to resolve its position-specific bit count. -/
def nativeRangeGates (rows cols : ℕ) (profile : NativeRelation.Profile) :
    List (Σ wire : Wire rows cols, Gate (wireBound profile wire)) :=
  (wires rows cols).flatMap fun wire => (gates (wireBound profile wire)).map (Sigma.mk wire)

theorem mem_nativeRangeGates (profile : NativeRelation.Profile)
    (wire : Wire rows cols) (gate : Gate (wireBound profile wire)) :
    Sigma.mk wire gate ∈ nativeRangeGates rows cols profile := by
  apply List.mem_flatMap.mpr
  exact ⟨wire, mem_wires wire, List.mem_map.mpr ⟨gate, mem_gates gate, rfl⟩⟩

/-- Checking the emitted list enforces the range constraints on every native wire. -/
theorem checked_iff_lists {R : Type*} [CommRing R] (profile : NativeRelation.Profile)
    (values : Wire rows cols → R) (digits : Digits (rows := rows) (cols := cols) profile R) :
    Checked profile values digits ↔
      (∀ gate ∈ NativeCircuit.gates rows cols, (NativeCircuit.compile gate).Satisfied values) ∧
      (∀ entry ∈ nativeRangeGates rows cols profile,
        (compile entry.2).Satisfied (values entry.1) (digits entry.1)) := by
  constructor
  · intro checked
    exact ⟨fun gate _ => checked.1 gate, fun entry _ => checked.2 entry.1 entry.2⟩
  · rintro ⟨core, ranges⟩
    exact ⟨fun gate => core gate (NativeCircuit.mem_gates gate),
      fun wire gate => ranges ⟨wire, gate⟩ (mem_nativeRangeGates profile wire gate)⟩

/-- The original bounded witness has an explicit assignment for the combined system. -/
theorem nativeWitness_checked (profile : NativeRelation.Profile) (p : ℕ)
    (witness : NativeRelation.Witness rows cols) (bounded : NativeRelation.Bounded profile witness) :
    Checked profile
      (fun wire => (nativeAssignment witness.target witness.z witness.a witness.u wire : ZMod p))
      (fun wire => honestDigits (wireBound profile wire)
        (nativeAssignment witness.target witness.z witness.a witness.u wire)
        (nativeWitness_ranges profile witness bounded wire)) :=
  ⟨nativeAssignment_modular_satisfied p witness.target witness.z witness.a witness.u,
    fun wire => honestDigits_satisfied _ _ (nativeWitness_ranges profile witness bounded wire)⟩

/-- Recover the unique bounded integer assignment, and apply the existing no-wrap theorem
to the very same native arithmetic wires. -/
theorem existsUnique_integer_assignment (profile : NativeRelation.Profile) {p : ℕ} [Fact p.Prime]
    (values : Wire rows cols → ZMod p) (digits : Digits (rows := rows) (cols := cols) profile (ZMod p))
    (rangeModulus : ∀ wire : Wire rows cols, modulusBound (wireBound profile wire) ≤ p)
    (coreModulus : maxResidualBound rows cols profile < p)
    (checked : Checked profile values digits) :
    ∃! lifts : Wire rows cols → ℤ, Ranges profile lifts ∧
      (∀ wire, (lifts wire : ZMod p) = values wire) ∧ NativeCircuit.Satisfied lifts := by
  choose lifts ranges residues using fun wire =>
    exists_lift (values wire) (digits wire) (rangeModulus wire) (checked.2 wire)
  have core : NativeCircuit.Satisfied (fun wire => (lifts wire : ZMod p)) := by
    simpa only [residues] using checked.1
  refine ⟨lifts, ⟨ranges, residues, ?_⟩, ?_⟩
  · exact satisfied_integer_of_modular p lifts core
      (noWrap_of_ranges profile p lifts ranges coreModulus)
  · intro other h
    funext wire
    exact lift_unique (rangeModulus wire) (h.1 wire) (ranges wire)
      ((h.2.1 wire).trans (residues wire).symm)

/-- The checked field wires lift to the original native integer observation. -/
theorem exists_integer_observed (profile : NativeRelation.Profile) {p : ℕ} [Fact p.Prime]
    (values : Wire rows cols → ZMod p) (digits : Digits (rows := rows) (cols := cols) profile (ZMod p))
    (rangeModulus : ∀ wire : Wire rows cols, modulusBound (wireBound profile wire) ≤ p)
    (coreModulus : maxResidualBound rows cols profile < p)
    (checked : Checked profile values digits) :
    ∃ lifts : Wire rows cols → ℤ, Ranges profile lifts ∧
      (∀ wire, (lifts wire : ZMod p) = values wire) ∧
      observedOf lifts = Sheaf.HCPCoupledEncoding.integerObserved
        (matrixOf lifts) (messageOf lifts) (lifts .exactOpening) (noiseOf lifts) := by
  obtain ⟨lifts, ⟨ranges, residues, core⟩, _⟩ :=
    existsUnique_integer_assignment profile values digits rangeModulus coreModulus checked
  exact ⟨lifts, ranges, residues, satisfied_integer_observed lifts core⟩

end Native
end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCircuitRanges
