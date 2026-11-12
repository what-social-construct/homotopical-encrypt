module

public import HCP.CoupledTransport
public import Mathlib.LinearAlgebra.Matrix.NonsingularInverse

@[expose] public section

/-!
# Exact rational execution of native coupled transport

The native matrix and its adjugate/determinant inverse use executable rational
arithmetic. The inverse is derived from the actual integer presentation, with
nonvanishing determinant proved through its original real coordinate action.
No inverse matrix or correctness law is supplied as an input.

Realizing the rational result in the original Euclidean cochain carrier gives
exactly `CoupledTransport.transport`. This is a finite reference algorithm;
the determinant implementation carries no polynomial complexity claim.
Possession, authorization and confidentiality of transport material remain
protocol obligations.
-/

set_option autoImplicit false

open scoped BigOperators

namespace HomotopicalEncryption.HCP.CoupledRational

open Sheaf CellularSheaf HCPCoupledFamily

variable {Row Col : Type*} [Fintype Row] [Fintype Col]
  [DecidableEq Row] [DecidableEq Col]

/-- Exact rational values on the original degree-one coordinate index. -/
abbrev RationalCochain (Row Col : Type*) := Index Row Col → ℚ

/-- Mathematical embedding into the original Euclidean cochain carrier. -/
noncomputable def realize (v : RationalCochain Row Col) : C1 Row Col :=
  WithLp.toLp 2 fun p => (v p : ℝ)

omit [DecidableEq Row] [DecidableEq Col] in
theorem realize_injective : Function.Injective (realize (Row := Row) (Col := Col)) := by
  intro v w h
  funext p
  have hp := congrArg (fun b : C1 Row Col => b p) h
  change (v p : ℝ) = (w p : ℝ) at hp
  exact_mod_cast hp

/-- Rational matrix of the same full observation map `M_B`. -/
def nativeMatrix (B : Matrix Row Col ℤ) : Matrix (Index Row Col) (Index Row Col) ℚ :=
  fun p q => match p.1, q.1 with
    | none, none => 1
    | some (.inl c), some (.inl d) => if c = d then 1 else 0
    | some (.inl c), some (.inr r) => -(B r c : ℚ)
    | some (.inr r), some (.inl c) => (B r c : ℚ)
    | some (.inr r), some (.inr s) => if r = s then 1 else 0
    | _, _ => 0

/-- The rational matrix acts as the original native real coordinate map. -/
theorem realize_nativeMatrix_mulVec (B : Matrix Row Col ℤ) (v : RationalCochain Row Col) :
    realize ((nativeMatrix B).mulVec v) = CoupledTransport.nativeLinear B (realize v) := by
  apply PiLp.ext
  rintro ⟨e, j⟩
  have hj : j = 0 := Subsingleton.elim _ _
  subst j
  cases e with
  | none =>
    simp [realize, nativeMatrix, Matrix.mulVec, dotProduct, Fintype.sum_sigma,
      Fintype.sum_option, Fintype.sum_sum_type, CoupledTransport.nativeLinear,
      CoupledTransport.coordinates, exactCoord]
  | some e =>
    cases e with
    | inl c =>
      simp [realize, nativeMatrix, Matrix.mulVec, dotProduct, Fintype.sum_sigma,
        Fintype.sum_option, Fintype.sum_sum_type, CoupledTransport.nativeLinear,
        CoupledTransport.coordinates, information, parity, Finset.sum_neg_distrib,
        sub_eq_add_neg, apply_ite, ite_mul, eq_comm]
    | inr r =>
      simp [realize, nativeMatrix, Matrix.mulVec, dotProduct, Fintype.sum_sigma,
        Fintype.sum_option, Fintype.sum_sum_type, CoupledTransport.nativeLinear,
        CoupledTransport.coordinates, information, parity, apply_ite, ite_mul, eq_comm]

/-- Full rank follows from the already-proved native real map, not an assumption. -/
theorem nativeMatrix_mulVec_injective (B : Matrix Row Col ℤ) :
    Function.Injective (nativeMatrix B).mulVec := by
  intro v w h
  apply realize_injective
  apply CoupledTransport.nativeLinear_injective B
  rw [← realize_nativeMatrix_mulVec, ← realize_nativeMatrix_mulVec, h]

theorem nativeMatrix_det_ne_zero (B : Matrix Row Col ℤ) : (nativeMatrix B).det ≠ 0 :=
  ((Matrix.isUnit_iff_isUnit_det _).mp
    (Matrix.mulVec_injective_iff_isUnit.mp (nativeMatrix_mulVec_injective B))).ne_zero

/-- Executable adjugate/determinant inverse over the field of rationals.
It is zero on singular matrices, matching the proof-only Mathlib inverse. -/
def exactInverse {ι : Type*} [Fintype ι] [DecidableEq ι] (A : Matrix ι ι ℚ) :
    Matrix ι ι ℚ :=
  A.det⁻¹ • A.adjugate

theorem exactInverse_eq_inv {ι : Type*} [Fintype ι] [DecidableEq ι]
    (A : Matrix ι ι ℚ) :
    exactInverse A = A⁻¹ := by
  rw [Matrix.inv_def, Ring.inverse_eq_inv]
  rfl

/-- The derived inverse of the original native matrix. -/
def inverseMatrix (B : Matrix Row Col ℤ) : Matrix (Index Row Col) (Index Row Col) ℚ :=
  exactInverse (nativeMatrix B)

theorem inverseMatrix_eq_inv (B : Matrix Row Col ℤ) :
    inverseMatrix B = (nativeMatrix B)⁻¹ := by
  exact exactInverse_eq_inv _

theorem inverseMatrix_mul_nativeMatrix (B : Matrix Row Col ℤ) :
    inverseMatrix B * nativeMatrix B = 1 := by
  rw [inverseMatrix_eq_inv]
  exact Matrix.nonsing_inv_mul _ (isUnit_iff_ne_zero.mpr (nativeMatrix_det_ne_zero B))

theorem nativeMatrix_mul_inverseMatrix (B : Matrix Row Col ℤ) :
    nativeMatrix B * inverseMatrix B = 1 := by
  rw [inverseMatrix_eq_inv]
  exact Matrix.mul_nonsing_inv _ (isUnit_iff_ne_zero.mpr (nativeMatrix_det_ne_zero B))

/-- A derived rational transport token, with no private presentations in its data. -/
def transportMatrix (B C : Matrix Row Col ℤ) : Matrix (Index Row Col) (Index Row Col) ℚ :=
  nativeMatrix C * inverseMatrix B

/-- Apply the exact derived matrix to a rational ciphertext. -/
def applyTransport (B C : Matrix Row Col ℤ) (v : RationalCochain Row Col) :
    RationalCochain Row Col :=
  (transportMatrix B C).mulVec v

/-- The exact rational inverse realizes the original native-coordinate inverse. -/
theorem realize_inverseMatrix_mulVec (B : Matrix Row Col ℤ) (v : RationalCochain Row Col) :
    realize ((inverseMatrix B).mulVec v) = (CoupledTransport.nativeEquiv B).symm (realize v) := by
  apply (CoupledTransport.nativeEquiv B).injective
  rw [CoupledTransport.nativeEquiv_apply, ← realize_nativeMatrix_mulVec,
    Matrix.mulVec_mulVec, nativeMatrix_mul_inverseMatrix, Matrix.one_mulVec]
  exact ((CoupledTransport.nativeEquiv B).apply_symm_apply (realize v)).symm

/-- Executing the derived rational matrix refines the original full real transport. -/
theorem realize_applyTransport (B C : Matrix Row Col ℤ) (v : RationalCochain Row Col) :
    realize (applyTransport B C v) = CoupledTransport.transport B C (realize v) := by
  unfold applyTransport transportMatrix
  rw [← Matrix.mulVec_mulVec, realize_nativeMatrix_mulVec, realize_inverseMatrix_mulVec]
  rfl

/-- Canonical rational coordinates of the original generated integer observation. -/
def sampleVector (B : Matrix Row Col ℤ) (z : Col → ℤ) (a : ℤ) (u : Row → ℤ) :
    RationalCochain Row Col :=
  fun p => (HCPCoupledEncoding.integerObserved B z a u p : ℚ)

theorem realize_sampleVector (B : Matrix Row Col ℤ) (z : Col → ℤ)
    (a : ℤ) (u : Row → ℤ) :
    realize (sampleVector B z a u) = (HCPCoupledEncoding.sample B z a u).observed := by
  convert HCPCoupledEncoding.integerObserved_cast_eq_observed B z a u using 1
  apply PiLp.ext
  intro p
  simp [realize, sampleVector]

/-- Finite rational execution carries the same original integral sample to the
target. In particular every output coordinate is integral on generated inputs. -/
theorem applyTransport_sampleVector (B C : Matrix Row Col ℤ) (z : Col → ℤ)
    (a : ℤ) (u : Row → ℤ) :
    applyTransport B C (sampleVector B z a u) = sampleVector C z a u := by
  apply realize_injective
  rw [realize_applyTransport, realize_sampleVector, realize_sampleVector,
    CoupledTransport.transport_observed]

/-- Read source Hodge coordinates by the exact rational inverse. -/
def recoverCoordinates (B : Matrix Row Col ℤ) (v : RationalCochain Row Col) :
    RationalCochain Row Col :=
  (inverseMatrix B).mulVec v

/-- Private message recovery is a finite rational matrix computation. -/
def recoverMessage (B : Matrix Row Col ℤ) (v : RationalCochain Row Col) (c : Col) : ℚ :=
  recoverCoordinates B v ⟨some (.inl c), 0⟩

/-- The exact inverse recovers the original message coefficient without a
classical search over integers or an independently supplied decoder equation. -/
theorem recoverMessage_sampleVector (B : Matrix Row Col ℤ) (z : Col → ℤ)
    (a : ℤ) (u : Row → ℤ) (c : Col) :
    recoverMessage B (sampleVector B z a u) c = (z c : ℚ) := by
  have hreal := realize_inverseMatrix_mulVec B (sampleVector B z a u)
  rw [realize_sampleVector, ← CoupledTransport.nativeEquiv_coordinates_eq_observed B,
    LinearEquiv.symm_apply_apply] at hreal
  have hp := congrArg (fun b : C1 Row Col => information b c) hreal
  change ((recoverMessage B (sampleVector B z a u) c : ℚ) : ℝ) = (z c : ℝ) at hp
  exact_mod_cast hp

/-- Finite private coefficient decoding: every recovered information coordinate
must be an integer rational before its numerator is returned. -/
def decodeCoefficients (B : Matrix Row Col ℤ) (v : RationalCochain Row Col) :
    Option (Col → ℤ) :=
  if ∀ c, (recoverMessage B v c).den = 1 then
    some (fun c => (recoverMessage B v c).num)
  else none

/-- The exact rational algorithm recovers the same original integer message. -/
theorem decodeCoefficients_sampleVector (B : Matrix Row Col ℤ) (z : Col → ℤ)
    (a : ℤ) (u : Row → ℤ) :
    decodeCoefficients B (sampleVector B z a u) = some z := by
  simp [decodeCoefficients, recoverMessage_sampleVector]

theorem transportMatrix_refl (B : Matrix Row Col ℤ) :
    transportMatrix B B = 1 := nativeMatrix_mul_inverseMatrix B

/-- Derived token matrices compose in the same order as ciphertext transports. -/
theorem transportMatrix_comp (B C D : Matrix Row Col ℤ) :
    transportMatrix C D * transportMatrix B C = transportMatrix B D := by
  unfold transportMatrix
  rw [Matrix.mul_assoc, ← Matrix.mul_assoc (inverseMatrix C) (nativeMatrix C),
    inverseMatrix_mul_nativeMatrix, Matrix.one_mul]

/-- The derived reverse token is the exact left inverse of the forward token. -/
theorem transportMatrix_reverse (B C : Matrix Row Col ℤ) :
    transportMatrix C B * transportMatrix B C = 1 := by
  rw [transportMatrix_comp, transportMatrix_refl]

theorem transportMatrix_det_ne_zero (B C : Matrix Row Col ℤ) :
    (transportMatrix B C).det ≠ 0 :=
  Matrix.det_ne_zero_of_left_inverse (transportMatrix_reverse B C)

/-- A holder of the derived matrix alone can compute its reverse exactly.
This does not require the source or target private presentations as data. -/
theorem exactInverse_transportMatrix (B C : Matrix Row Col ℤ) :
    exactInverse (transportMatrix B C) = transportMatrix C B := by
  rw [exactInverse_eq_inv]
  apply Matrix.inv_eq_left_inv
  exact transportMatrix_reverse B C

/-- Rational runtime transport obeys the same ordered composition as the real map. -/
theorem applyTransport_comp (B C D : Matrix Row Col ℤ) (v : RationalCochain Row Col) :
    applyTransport C D (applyTransport B C v) = applyTransport B D v := by
  apply realize_injective
  rw [realize_applyTransport, realize_applyTransport, realize_applyTransport,
    CoupledTransport.transport_comp]

/-- Reversing the exact rational transport restores every rational ciphertext. -/
theorem applyTransport_reverse (B C : Matrix Row Col ℤ) (v : RationalCochain Row Col) :
    applyTransport C B (applyTransport B C v) = v := by
  apply realize_injective
  rw [realize_applyTransport, realize_applyTransport, CoupledTransport.transport_reverse]

end HomotopicalEncryption.HCP.CoupledRational
