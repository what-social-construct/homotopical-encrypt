module

public import Sheaf.HCPCoupledEncoding
public import Mathlib.Data.ZMod.Basic
public import Mathlib.Algebra.Order.Group.Unbundled.Int

@[expose] public section

/-!
# Rank-one constraints for the native coupled ciphertext

The fixed-dimensional arithmetic core has two multiplication constraints per
matrix entry, one affine constraint per information/parity coordinate and one
exact-coordinate constraint. Its linear forms are finite, explicitly generated
from the native coordinate layout. It uses the original integer sample rather
than a replacement encryption object.

Reduction modulo a field is sound for integer lifts only under the stated
gate-residual no-wrap bounds. The bounded byte witness checker supplies exact
integer arithmetic independently. Compiling its range checks, canonical bytes,
credential hash and snapshot/ciphertext hashes into a selected proof engine
requires additional gates; this arithmetic core does not infer those checks
from a hash identifier or a field equality.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCircuit

open Sheaf CellularSheaf HCPCoupledFamily
open scoped BigOperators

/-- Finite native variable positions, including both multiplication auxiliaries. -/
inductive Wire (rows cols : ℕ) where
  | matrix : Fin rows → Fin cols → Wire rows cols
  | message : Fin cols → Wire rows cols
  | noise : Fin rows → Wire rows cols
  | exactOpening : Wire rows cols
  | information : Fin cols → Wire rows cols
  | parity : Fin rows → Wire rows cols
  | exactObserved : Wire rows cols
  | informationProduct : Fin rows → Fin cols → Wire rows cols
  | parityProduct : Fin rows → Fin cols → Wire rows cols
  deriving DecidableEq

/-- The finite linear forms needed by this generated constraint system. -/
inductive Form (rows cols : ℕ) where
  | one
  | wire : Wire rows cols → Form rows cols
  | informationRhs : Fin cols → Form rows cols
  | parityRhs : Fin rows → Form rows cols

variable {rows cols : ℕ}

def Form.eval {F : Type*} [CommRing F] (values : Wire rows cols → F) :
    Form rows cols → F
  | .one => 1
  | .wire index => values index
  | .informationRhs col => values (.message col) -
      ∑ row, values (.informationProduct row col)
  | .parityRhs row => (∑ col, values (.parityProduct row col)) + values (.noise row)

/-- Each gate is a rank-one equation between three explicitly linear forms. -/
structure Constraint (rows cols : ℕ) where
  left : Form rows cols
  right : Form rows cols
  output : Form rows cols

def Constraint.Satisfied {F : Type*} [CommRing F]
    (constraint : Constraint rows cols) (values : Wire rows cols → F) : Prop :=
  constraint.left.eval values * constraint.right.eval values = constraint.output.eval values

/-- Exactly the native multiplication and output-coordinate gates. -/
inductive Gate (rows cols : ℕ) where
  | informationProduct : Fin rows → Fin cols → Gate rows cols
  | parityProduct : Fin rows → Fin cols → Gate rows cols
  | information : Fin cols → Gate rows cols
  | parity : Fin rows → Gate rows cols
  | exact : Gate rows cols
  deriving DecidableEq

def compile : Gate rows cols → Constraint rows cols
  | .informationProduct row col =>
    ⟨.wire (.matrix row col), .wire (.noise row), .wire (.informationProduct row col)⟩
  | .parityProduct row col =>
    ⟨.wire (.matrix row col), .wire (.message col), .wire (.parityProduct row col)⟩
  | .information col => ⟨.informationRhs col, .one, .wire (.information col)⟩
  | .parity row => ⟨.parityRhs row, .one, .wire (.parity row)⟩
  | .exact => ⟨.wire .exactOpening, .one, .wire .exactObserved⟩

def Satisfied {F : Type*} [CommRing F] (values : Wire rows cols → F) : Prop :=
  ∀ gate, (compile gate).Satisfied values

def gates (rows cols : ℕ) : List (Gate rows cols) :=
  ((List.finRange rows).flatMap fun row =>
    (List.finRange cols).map (Gate.informationProduct row)) ++
  ((List.finRange rows).flatMap fun row =>
    (List.finRange cols).map (Gate.parityProduct row)) ++
  (List.finRange cols).map Gate.information ++
  (List.finRange rows).map Gate.parity ++ [.exact]

theorem mem_gates (gate : Gate rows cols) : gate ∈ gates rows cols := by
  cases gate <;> simp [gates, List.mem_flatMap]

/-- The generated core has precisely 2mn nonlinear gates and n+m+1 affine gates. -/
theorem gates_length (rows cols : ℕ) :
    (gates rows cols).length = 2 * rows * cols + cols + rows + 1 := by
  simp [gates, List.length_flatMap]
  ring

/-- An honest assignment uses the actual native matrix, coordinates and
products. This supplies every auxiliary variable of the generated system. -/
def nativeAssignment (matrix : Matrix (Fin rows) (Fin cols) ℤ)
    (message : Fin cols → ℤ) (opening : ℤ) (noise : Fin rows → ℤ) : Wire rows cols → ℤ
  | .matrix row col => matrix row col
  | .message col => message col
  | .noise row => noise row
  | .exactOpening => opening
  | .information col => message col - ∑ row, matrix row col * noise row
  | .parity row => (∑ col, matrix row col * message col) + noise row
  | .exactObserved => opening
  | .informationProduct row col => matrix row col * noise row
  | .parityProduct row col => matrix row col * message col

/-- Every native sample yields a satisfying assignment, in every dimension
and for arbitrary integral messages and Hodge openings. -/
theorem nativeAssignment_satisfied (matrix : Matrix (Fin rows) (Fin cols) ℤ)
    (message : Fin cols → ℤ) (opening : ℤ) (noise : Fin rows → ℤ) :
    Satisfied (nativeAssignment matrix message opening noise) := by
  intro gate
  cases gate <;> simp [compile, Constraint.Satisfied, Form.eval, nativeAssignment]

def matrixOf {F : Type*} (values : Wire rows cols → F) : Matrix (Fin rows) (Fin cols) F :=
  fun row col => values (.matrix row col)

def messageOf {F : Type*} (values : Wire rows cols → F) : Fin cols → F :=
  fun col => values (.message col)

def noiseOf {F : Type*} (values : Wire rows cols → F) : Fin rows → F :=
  fun row => values (.noise row)

def observedOf {F : Type*} (values : Wire rows cols → F) :
    Index (Fin rows) (Fin cols) → F :=
  fun edge => match edge.1 with
    | none => values .exactObserved
    | some (.inl col) => values (.information col)
    | some (.inr row) => values (.parity row)

/-- Every satisfying integer assignment gives the original exact native
observation with its very same matrix/message/noise coordinates. -/
theorem satisfied_integer_observed
    (values : Wire rows cols → ℤ) (checked : Satisfied values) :
    observedOf values = HCPCoupledEncoding.integerObserved
      (matrixOf values) (messageOf values) (values .exactOpening) (noiseOf values) := by
  have productsInfo (row : Fin rows) (col : Fin cols) :
      values (.informationProduct row col) = values (.matrix row col) * values (.noise row) :=
    (checked (.informationProduct row col)).symm
  have productsParity (row : Fin rows) (col : Fin cols) :
      values (.parityProduct row col) = values (.matrix row col) * values (.message col) :=
    (checked (.parityProduct row col)).symm
  funext edge
  rcases edge with ⟨position, component⟩
  have componentZero : component = 0 := Subsingleton.elim _ _
  subst component
  cases position with
  | none =>
    simpa [observedOf, HCPCoupledEncoding.integerObserved, compile,
      Constraint.Satisfied, Form.eval] using (checked .exact).symm
  | some position =>
    cases position with
    | inl col =>
      have output := (checked (.information col)).symm
      simpa [observedOf, HCPCoupledEncoding.integerObserved, matrixOf, messageOf,
        noiseOf, compile, Constraint.Satisfied, Form.eval, productsInfo] using output
    | inr row =>
      have output := (checked (.parity row)).symm
      simpa [observedOf, HCPCoupledEncoding.integerObserved, matrixOf, messageOf,
        noiseOf, compile, Constraint.Satisfied, Form.eval, productsParity] using output

/-- The integer residual of a rank-one gate, before modular reduction. -/
def residual (values : Wire rows cols → ℤ) (gate : Gate rows cols) : ℤ :=
  (compile gate).left.eval values * (compile gate).right.eval values -
    (compile gate).output.eval values

def NoWrap (modulus : ℕ) (values : Wire rows cols → ℤ) : Prop :=
  ∀ gate, |residual values gate| < (modulus : ℤ)

theorem Form.eval_intCast (modulus : ℕ) (values : Wire rows cols → ℤ)
    (form : Form rows cols) :
    form.eval (fun wire => (values wire : ZMod modulus)) = ((form.eval (F := ℤ) values : ℤ) : ZMod modulus) := by
  cases form <;> simp [Form.eval, Int.cast_sum]

theorem satisfied_modular_of_integer (modulus : ℕ) (values : Wire rows cols → ℤ)
    (checked : Satisfied values) :
    Satisfied (fun wire => (values wire : ZMod modulus)) := by
  intro gate
  unfold Constraint.Satisfied
  rw [Form.eval_intCast, Form.eval_intCast, Form.eval_intCast]
  have equation := congrArg (fun value : ℤ => (value : ZMod modulus)) (checked gate)
  simpa only [Int.cast_mul] using equation

theorem nativeAssignment_modular_satisfied (modulus : ℕ)
    (matrix : Matrix (Fin rows) (Fin cols) ℤ) (message : Fin cols → ℤ)
    (opening : ℤ) (noise : Fin rows → ℤ) :
    Satisfied (fun wire => (nativeAssignment matrix message opening noise wire : ZMod modulus)) :=
  satisfied_modular_of_integer modulus _ (nativeAssignment_satisfied matrix message opening noise)

/-- Field congruences recover integer equations only with the explicit
no-wrap bounds; the result does not drop range/carry validation. -/
theorem satisfied_integer_of_modular
    (modulus : ℕ) (values : Wire rows cols → ℤ)
    (checked : Satisfied (fun wire => (values wire : ZMod modulus)))
    (bounded : NoWrap modulus values) : Satisfied values := by
  intro gate
  have modular := checked gate
  unfold Constraint.Satisfied at modular
  rw [Form.eval_intCast, Form.eval_intCast, Form.eval_intCast] at modular
  have zero : (residual values gate : ZMod modulus) = 0 := by
    simpa only [residual, Int.cast_sub, Int.cast_mul] using sub_eq_zero.mpr modular
  have exactZero := Int.eq_zero_of_abs_lt_dvd
    ((ZMod.intCast_zmod_eq_zero_iff_dvd _ _).1 zero) (bounded gate)
  exact sub_eq_zero.mp exactZero

theorem modular_checked_observed
    (modulus : ℕ) (values : Wire rows cols → ℤ)
    (checked : Satisfied (fun wire => (values wire : ZMod modulus)))
    (bounded : NoWrap modulus values) :
    observedOf values = HCPCoupledEncoding.integerObserved
      (matrixOf values) (messageOf values) (values .exactOpening) (noiseOf values) :=
  satisfied_integer_observed values (satisfied_integer_of_modular modulus values checked bounded)

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCircuit
