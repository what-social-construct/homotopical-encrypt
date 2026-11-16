module

public import Protocol.Transfer.PathSignature.NativeCircuit
public import Protocol.Transfer.PathSignature.NativeRelation
public import Mathlib.Algebra.Order.BigOperators.Group.Finset

@[expose] public section

/-!
# Explicit ranges and a modulus bound for the native arithmetic core

The existing core wires are checked in their integer lifts. For a profile
bound `K`, the original matrix/message/opening/noise coordinates have size at
most `K`, multiplication auxiliaries at most `K²`, and information/parity
outputs at most `K + rows*K²` and `K + cols*K²`. Honest bounded native
witnesses satisfy the executable range check.

These ranges bound every existing gate residual by an explicit maximum.
A modulus larger than that maximum supplies the original `NoWrap` premise,
so modular satisfaction and the range check imply the original integer
ciphertext equations. This checks integer lifts; it does not compile the
range check, canonical byte parser or hashes into field constraints.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCircuitBounds

open Sheaf CellularSheaf HCPCoupledFamily
open NativeCircuit
open scoped BigOperators

variable {rows cols : ℕ}

/-- Profile-derived bounds on the existing core's integer wires. -/
def wireBound (profile : NativeRelation.Profile) : Wire rows cols → ℕ
  | .matrix _ _ => profile.bound
  | .message _ => profile.bound
  | .noise _ => profile.bound
  | .exactOpening => profile.bound
  | .information _ => profile.bound + rows * (profile.bound * profile.bound)
  | .parity _ => profile.bound + cols * (profile.bound * profile.bound)
  | .exactObserved => profile.bound
  | .informationProduct _ _ => profile.bound * profile.bound
  | .parityProduct _ _ => profile.bound * profile.bound

/-- Every integer lift is checked, including both multiplication auxiliaries
and all three kinds of observed coordinates. -/
def Ranges (profile : NativeRelation.Profile) (values : Wire rows cols → ℤ) : Prop :=
  ∀ wire, |values wire| ≤ (wireBound profile wire : ℤ)

/-- A finite enumeration for checking ranges of the original wire carrier. -/
def wires (rows cols : ℕ) : List (Wire rows cols) :=
  ((List.finRange rows).flatMap fun row =>
    (List.finRange cols).map (Wire.matrix row)) ++
  (List.finRange cols).map Wire.message ++
  (List.finRange rows).map Wire.noise ++ [.exactOpening] ++
  (List.finRange cols).map Wire.information ++
  (List.finRange rows).map Wire.parity ++ [.exactObserved] ++
  ((List.finRange rows).flatMap fun row =>
    (List.finRange cols).map (Wire.informationProduct row)) ++
  ((List.finRange rows).flatMap fun row =>
    (List.finRange cols).map (Wire.parityProduct row))

theorem mem_wires (wire : Wire rows cols) : wire ∈ wires rows cols := by
  cases wire <;> simp [wires, List.mem_flatMap]

/-- An actual finite Boolean range check on arbitrary integer assignments. -/
def rangeCheck (profile : NativeRelation.Profile) (values : Wire rows cols → ℤ) : Bool :=
  (wires rows cols).all fun wire => decide (|values wire| ≤ (wireBound profile wire : ℤ))

theorem rangeCheck_eq_true_iff (profile : NativeRelation.Profile)
    (values : Wire rows cols → ℤ) : rangeCheck profile values = true ↔ Ranges profile values := by
  simp only [rangeCheck, List.all_eq_true, decide_eq_true_eq]
  constructor
  · intro checked wire
    exact checked wire (mem_wires wire)
  · intro checked wire _member
    exact checked wire

private theorem abs_sub_bound (left right : ℤ) : |left - right| ≤ |left| + |right| := by
  simpa only [sub_eq_add_neg, abs_neg] using abs_add_le left (-right)

private theorem abs_of_natAbs_le {value : ℤ} {bound : ℕ}
    (bounded : value.natAbs ≤ bound) : |value| ≤ (bound : ℤ) := by
  have castBound : (value.natAbs : ℤ) ≤ (bound : ℤ) := Int.ofNat_le.mpr bounded
  simpa only [Int.natCast_natAbs] using castBound

private theorem abs_mul_bound {left right : ℤ} {bound : ℕ}
    (leftBound : |left| ≤ (bound : ℤ)) (rightBound : |right| ≤ (bound : ℤ)) :
    |left * right| ≤ ((bound * bound : ℕ) : ℤ) := by
  rw [abs_mul, Nat.cast_mul]
  exact mul_le_mul leftBound rightBound (abs_nonneg right) (Nat.cast_nonneg bound)

private theorem abs_sum_bound {count : ℕ} (values : Fin count → ℤ) (bound : ℕ)
    (bounded : ∀ index, |values index| ≤ (bound : ℤ)) :
    |∑ index, values index| ≤ ((count * bound : ℕ) : ℤ) := by
  calc
    |∑ index, values index| ≤ ∑ index, |values index| :=
      Finset.abs_sum_le_sum_abs values Finset.univ
    _ ≤ ∑ _index : Fin count, (bound : ℤ) :=
      Finset.sum_le_sum fun index _member => bounded index
    _ = ((count * bound : ℕ) : ℤ) := by simp [Nat.cast_mul]

/-- The actual core assignment obeys the profile ranges whenever its native
integer inputs obey the corresponding magnitude bound. -/
theorem nativeAssignment_ranges (profile : NativeRelation.Profile)
    (matrix : Matrix (Fin rows) (Fin cols) ℤ) (message : Fin cols → ℤ)
    (opening : ℤ) (noise : Fin rows → ℤ)
    (matrixBound : ∀ row col, (matrix row col).natAbs ≤ profile.bound)
    (messageBound : ∀ col, (message col).natAbs ≤ profile.bound)
    (openingBound : opening.natAbs ≤ profile.bound)
    (noiseBound : ∀ row, (noise row).natAbs ≤ profile.bound) :
    Ranges profile (nativeAssignment matrix message opening noise) := by
  have matrixAbs (row : Fin rows) (col : Fin cols) :
      |matrix row col| ≤ (profile.bound : ℤ) := abs_of_natAbs_le (matrixBound row col)
  have messageAbs (col : Fin cols) : |message col| ≤ (profile.bound : ℤ) :=
    abs_of_natAbs_le (messageBound col)
  have noiseAbs (row : Fin rows) : |noise row| ≤ (profile.bound : ℤ) :=
    abs_of_natAbs_le (noiseBound row)
  have openingAbs : |opening| ≤ (profile.bound : ℤ) := abs_of_natAbs_le openingBound
  intro wire
  cases wire with
  | matrix row col => exact matrixAbs row col
  | message col => exact messageAbs col
  | noise row => exact noiseAbs row
  | exactOpening => exact openingAbs
  | exactObserved => exact openingAbs
  | informationProduct row col => exact abs_mul_bound (matrixAbs row col) (noiseAbs row)
  | parityProduct row col => exact abs_mul_bound (matrixAbs row col) (messageAbs col)
  | information col =>
    have sumBound := abs_sum_bound (fun row => matrix row col * noise row)
      (profile.bound * profile.bound) (fun row => abs_mul_bound (matrixAbs row col) (noiseAbs row))
    change |message col - ∑ row, matrix row col * noise row| ≤ _
    calc
      _ ≤ |message col| + |∑ row, matrix row col * noise row| := abs_sub_bound _ _
      _ ≤ (profile.bound : ℤ) + ((rows * (profile.bound * profile.bound) : ℕ) : ℤ) :=
        add_le_add (messageAbs col) sumBound
      _ = (wireBound profile (.information col) : ℤ) := by simp [wireBound]
  | parity row =>
    have sumBound := abs_sum_bound (fun col => matrix row col * message col)
      (profile.bound * profile.bound) (fun col => abs_mul_bound (matrixAbs row col) (messageAbs col))
    change |(∑ col, matrix row col * message col) + noise row| ≤ _
    calc
      _ ≤ |∑ col, matrix row col * message col| + |noise row| := abs_add_le _ _
      _ ≤ ((cols * (profile.bound * profile.bound) : ℕ) : ℤ) + (profile.bound : ℤ) :=
        add_le_add sumBound (noiseAbs row)
      _ = (wireBound profile (.parity row) : ℤ) := by simp [wireBound, add_comm]

/-- The original bounded private witness supplies all arithmetic ranges.
The source presentation and salt do not enter this target-ciphertext core. -/
theorem nativeWitness_ranges (profile : NativeRelation.Profile)
    (witness : NativeRelation.Witness rows cols) (bounded : NativeRelation.Bounded profile witness) :
    Ranges profile (nativeAssignment witness.target witness.z witness.a witness.u) :=
  nativeAssignment_ranges profile witness.target witness.z witness.a witness.u
    bounded.2.1 bounded.2.2.1 bounded.2.2.2.1 bounded.2.2.2.2.1

theorem nativeWitness_rangeCheck (profile : NativeRelation.Profile)
    (witness : NativeRelation.Witness rows cols) (bounded : NativeRelation.Bounded profile witness) :
    rangeCheck profile (nativeAssignment witness.target witness.z witness.a witness.u) = true :=
  (rangeCheck_eq_true_iff profile _).mpr (nativeWitness_ranges profile witness bounded)

/-- Individual residual bounds derived from the range-checked wire sizes. -/
def gateResidualBound (profile : NativeRelation.Profile) : Gate rows cols → ℕ
  | .informationProduct _ _ => 2 * (profile.bound * profile.bound)
  | .parityProduct _ _ => 2 * (profile.bound * profile.bound)
  | .information _ => 2 * (profile.bound + rows * (profile.bound * profile.bound))
  | .parity _ => 2 * (profile.bound + cols * (profile.bound * profile.bound))
  | .exact => 2 * profile.bound

/-- An explicit safe residual bound for every gate in these dimensions. -/
def maxResidualBound (rows cols : ℕ) (profile : NativeRelation.Profile) : ℕ :=
  max (2 * (profile.bound * profile.bound))
    (max (2 * (profile.bound + rows * (profile.bound * profile.bound)))
      (max (2 * (profile.bound + cols * (profile.bound * profile.bound))) (2 * profile.bound)))

theorem gateResidualBound_le_max (profile : NativeRelation.Profile) (gate : Gate rows cols) :
    gateResidualBound profile gate ≤ maxResidualBound rows cols profile := by
  cases gate <;> simp only [gateResidualBound, maxResidualBound] <;> omega

private theorem product_residual_bound (bound : ℕ) (left right output : ℤ)
    (leftBound : |left| ≤ (bound : ℤ)) (rightBound : |right| ≤ (bound : ℤ))
    (outputBound : |output| ≤ ((bound * bound : ℕ) : ℤ)) :
    |left * right - output| ≤ ((2 * (bound * bound) : ℕ) : ℤ) := by
  calc
    _ ≤ |left * right| + |output| := abs_sub_bound _ _
    _ ≤ ((bound * bound : ℕ) : ℤ) + ((bound * bound : ℕ) : ℤ) :=
      add_le_add (abs_mul_bound leftBound rightBound) outputBound
    _ = ((2 * (bound * bound) : ℕ) : ℤ) := by simp [two_mul]

private theorem information_residual_bound {count : ℕ} (bound : ℕ)
    (message output : ℤ) (products : Fin count → ℤ)
    (messageBound : |message| ≤ (bound : ℤ))
    (productsBound : ∀ index, |products index| ≤ ((bound * bound : ℕ) : ℤ))
    (outputBound : |output| ≤ ((bound + count * (bound * bound) : ℕ) : ℤ)) :
    |(message - ∑ index, products index) * 1 - output| ≤
      ((2 * (bound + count * (bound * bound)) : ℕ) : ℤ) := by
  have sumBound := abs_sum_bound products (bound * bound) productsBound
  rw [mul_one]
  calc
    _ ≤ |message - ∑ index, products index| + |output| := abs_sub_bound _ _
    _ ≤ (|message| + |∑ index, products index|) + |output| :=
      add_le_add (abs_sub_bound message (∑ index, products index)) le_rfl
    _ ≤ ((bound : ℤ) + ((count * (bound * bound) : ℕ) : ℤ)) +
        ((bound + count * (bound * bound) : ℕ) : ℤ) :=
      add_le_add (add_le_add messageBound sumBound) outputBound
    _ = ((2 * (bound + count * (bound * bound)) : ℕ) : ℤ) := by simp [two_mul]

private theorem parity_residual_bound {count : ℕ} (bound : ℕ)
    (noise output : ℤ) (products : Fin count → ℤ)
    (noiseBound : |noise| ≤ (bound : ℤ))
    (productsBound : ∀ index, |products index| ≤ ((bound * bound : ℕ) : ℤ))
    (outputBound : |output| ≤ ((bound + count * (bound * bound) : ℕ) : ℤ)) :
    |((∑ index, products index) + noise) * 1 - output| ≤
      ((2 * (bound + count * (bound * bound)) : ℕ) : ℤ) := by
  have sumBound := abs_sum_bound products (bound * bound) productsBound
  rw [mul_one]
  calc
    _ ≤ |(∑ index, products index) + noise| + |output| := abs_sub_bound _ _
    _ ≤ (|∑ index, products index| + |noise|) + |output| :=
      add_le_add (abs_add_le (∑ index, products index) noise) le_rfl
    _ ≤ (((count * (bound * bound) : ℕ) : ℤ) + (bound : ℤ)) +
        ((bound + count * (bound * bound) : ℕ) : ℤ) :=
      add_le_add (add_le_add sumBound noiseBound) outputBound
    _ = ((2 * (bound + count * (bound * bound)) : ℕ) : ℤ) := by simp [two_mul, add_comm]

private theorem exact_residual_bound (bound : ℕ) (opening output : ℤ)
    (openingBound : |opening| ≤ (bound : ℤ)) (outputBound : |output| ≤ (bound : ℤ)) :
    |opening * 1 - output| ≤ ((2 * bound : ℕ) : ℤ) := by
  rw [mul_one]
  calc
    _ ≤ |opening| + |output| := abs_sub_bound _ _
    _ ≤ (bound : ℤ) + (bound : ℤ) := add_le_add openingBound outputBound
    _ = ((2 * bound : ℕ) : ℤ) := by simp [two_mul]

/-- Every generated gate residual has a checked explicit integer bound. -/
theorem residual_abs_le (profile : NativeRelation.Profile) (values : Wire rows cols → ℤ)
    (bounded : Ranges profile values) (gate : Gate rows cols) :
    |residual values gate| ≤ (gateResidualBound profile gate : ℤ) := by
  cases gate with
  | informationProduct row col =>
    exact product_residual_bound profile.bound _ _ _
      (bounded (.matrix row col)) (bounded (.noise row)) (bounded (.informationProduct row col))
  | parityProduct row col =>
    exact product_residual_bound profile.bound _ _ _
      (bounded (.matrix row col)) (bounded (.message col)) (bounded (.parityProduct row col))
  | information col =>
    exact information_residual_bound profile.bound _ _
      (fun row => values (.informationProduct row col))
      (bounded (.message col)) (fun row => bounded (.informationProduct row col))
      (bounded (.information col))
  | parity row =>
    exact parity_residual_bound profile.bound _ _
      (fun col => values (.parityProduct row col))
      (bounded (.noise row)) (fun col => bounded (.parityProduct row col))
      (bounded (.parity row))
  | exact =>
    exact exact_residual_bound profile.bound _ _ (bounded .exactOpening) (bounded .exactObserved)

/-- A modulus larger than the explicit worst-case residual excludes wrap at
every gate; no primality hypothesis is needed for this integer-lift argument. -/
theorem noWrap_of_ranges (profile : NativeRelation.Profile) (modulus : ℕ)
    (values : Wire rows cols → ℤ) (bounded : Ranges profile values)
    (large : maxResidualBound rows cols profile < modulus) : NoWrap modulus values := by
  intro gate
  have gateBound : (gateResidualBound profile gate : ℤ) ≤
      (maxResidualBound rows cols profile : ℤ) :=
    Int.ofNat_le.mpr (gateResidualBound_le_max profile gate)
  exact ((residual_abs_le profile values bounded gate).trans gateBound).trans_lt
    (Int.ofNat_lt.mpr large)

/-- Checked integer ranges discharge the original arithmetic core's no-wrap
premise and turn modular gate equations into their integer equations. -/
theorem satisfied_integer_of_checked_ranges (profile : NativeRelation.Profile) (modulus : ℕ)
    (values : Wire rows cols → ℤ)
    (checked : Satisfied (fun wire => (values wire : ZMod modulus)))
    (ranges : rangeCheck profile values = true)
    (large : maxResidualBound rows cols profile < modulus) : Satisfied values :=
  NativeCircuit.satisfied_integer_of_modular modulus values checked
    (noWrap_of_ranges profile modulus values ((rangeCheck_eq_true_iff profile values).mp ranges) large)

/-- Modular core checks, the concrete range check and the selected modulus
bound recover the original native integer ciphertext on the same assignment. -/
theorem modular_checked_observed (profile : NativeRelation.Profile) (modulus : ℕ)
    (values : Wire rows cols → ℤ)
    (checked : Satisfied (fun wire => (values wire : ZMod modulus)))
    (ranges : rangeCheck profile values = true)
    (large : maxResidualBound rows cols profile < modulus) :
    observedOf values = HCPCoupledEncoding.integerObserved
      (matrixOf values) (messageOf values) (values .exactOpening) (noiseOf values) :=
  NativeCircuit.satisfied_integer_observed values
    (satisfied_integer_of_checked_ranges profile modulus values checked ranges large)

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCircuitBounds
