module

public import Proximity.Core.ReedSolomon
public import Mathlib.Algebra.Field.ZMod
public import Mathlib.Data.Fin.VecNotation
public import Mathlib.LinearAlgebra.Matrix.ToLin
import Mathlib.Algebra.Polynomial.BigOperators
import Mathlib.Algebra.Polynomial.Eval.Degree

@[expose] public section

/-!
# The smooth length-eight Reed–Solomon code over `𝔽₁₇`

Its evaluation sites are consecutive powers of `9` and its parity-check
column at `a` is `(a, a², a³, a⁴)`. The kernel proof checks the two finite
Fourier matrix identities for the code and then applies them to arbitrary
words. The four designated erasure supports pair consecutive sites.
-/

set_option autoImplicit false

namespace ProximityCoding.MCA.Syndrome.Seventeen

open scoped BigOperators Matrix

theorem prime17 : Nat.Prime 17 := by decide

local instance : Fact (Nat.Prime 17) := ⟨prime17⟩

def site : Fin 8 → ZMod 17 := ![1, 9, 13, 15, 16, 8, 4, 2]

theorem site_eq_pow (i : Fin 8) : site i = (9 : ZMod 17) ^ i.val := by
  revert i
  decide

theorem root_pow_eight : (9 : ZMod 17) ^ 8 = 1 := by decide

theorem site_injective : Function.Injective site := by
  have checked : ∀ i j : Fin 8, site i = site j → i = j := by decide
  intro i j h
  exact checked i j h

def domain : ReedSolomon.SmoothEvaluationDomain (ZMod 17) (Fin 8) where
  point := site
  injective_point := site_injective
  smooth := 8 ∣ Fintype.card (ZMod 17) - 1

theorem domain_smooth : domain.smooth := by
  change 8 ∣ Fintype.card (ZMod 17) - 1
  decide

def parameters : ReedSolomon.Parameters (ZMod 17) (Fin 8) where
  domain := domain.toEvaluationDomain
  degreeBound := 4

/-- Syndrome columns in their original site order. -/
def column (i : Fin 8) (j : Fin 4) : ZMod 17 := site i ^ (j.val + 1)

def parityMatrix : Matrix (Fin 4) (Fin 8) (ZMod 17) := fun j i => column i j

def parityCheck : (Fin 8 → ZMod 17) →ₗ[ZMod 17] (Fin 4 → ZMod 17) :=
  parityMatrix.mulVecLin

theorem parityCheck_apply (w : Fin 8 → ZMod 17) (j : Fin 4) :
    parityCheck w j = ∑ i : Fin 8, column i j * w i := rfl

@[simp]
theorem parityCheck_single (i : Fin 8) (a : ZMod 17) :
    parityCheck (Pi.single i a) = a • column i := by
  funext j
  rw [parityCheck_apply, Finset.sum_eq_single i]
  · simp [Pi.smul_apply, smul_eq_mul, mul_comm]
  · intro k _ h
    simp [Pi.single_eq_of_ne h]
  · simp

private def evaluationMatrix : Matrix (Fin 8) (Fin 4) (ZMod 17) :=
  fun i d => site i ^ d.val

-- `15` is `8⁻¹`. The first matrix reads the four low-degree coefficients.
-- The second matrix reconstructs the four high-degree terms from the syndrome.
private def coefficients : Matrix (Fin 4) (Fin 8) (ZMod 17) :=
  fun d i => 15 * site i ^ (8 - d.val)

private def correction : Matrix (Fin 8) (Fin 4) (ZMod 17) :=
  fun i j => 15 * site i ^ (7 - j.val)

private theorem parity_mul_evaluation : parityMatrix * evaluationMatrix = 0 := by
  have checked : ∀ j : Fin 4, ∀ d : Fin 4, (parityMatrix * evaluationMatrix) j d = 0 :=
    by decide
  exact Matrix.ext checked

private theorem reconstruction : evaluationMatrix * coefficients + correction * parityMatrix = 1 := by
  apply Matrix.ext
  intro i j
  simp only [Matrix.add_apply, Matrix.mul_apply, Matrix.one_apply,
    evaluationMatrix, coefficients, correction, parityMatrix, column]
  revert i j
  decide

private theorem codeword_iff_evaluation (w : Fin 8 → ZMod 17) :
    parameters.Codeword w ↔ ∃ c : Fin 4 → ZMod 17, evaluationMatrix *ᵥ c = w := by
  constructor
  · rintro ⟨p, small, eval⟩
    refine ⟨fun d => p.coeff d.val, ?_⟩
    funext i
    change (∑ d : Fin 4, site i ^ d.val * p.coeff d.val) = w i
    rw [eval i]
    change _ = p.eval (site i)
    rw [Polynomial.eval_eq_sum_range' (n := 4) small, ← Fin.sum_univ_eq_sum_range]
    exact Finset.sum_congr rfl (fun _ _ => mul_comm _ _)
  · rintro ⟨c, rfl⟩
    refine ⟨∑ d : Fin 4, Polynomial.C (c d) * Polynomial.X ^ d.val, ?_, ?_⟩
    · have bounded : (∑ d : Fin 4, Polynomial.C (c d) * Polynomial.X ^ d.val).natDegree ≤ 3 := by
        apply Polynomial.natDegree_sum_le_of_forall_le
        intro d _
        exact (Polynomial.natDegree_C_mul_X_pow_le (c d) d.val).trans (Nat.le_of_lt_succ d.isLt)
      exact Nat.lt_succ_of_le bounded
    · intro i
      change (∑ d : Fin 4, site i ^ d.val * c d) =
        (∑ d : Fin 4, Polynomial.C (c d) * Polynomial.X ^ d.val).eval (site i)
      simp only [Polynomial.eval_finsetSum, Polynomial.eval_mul, Polynomial.eval_C,
        Polynomial.eval_pow, Polynomial.eval_X]
      exact Finset.sum_congr rfl (fun _ _ => mul_comm _ _)

/-- The specified matrix detects exactly the codewords of the actual RS domain. -/
theorem parityCheck_zero_iff (w : Fin 8 → ZMod 17) :
    parityCheck w = 0 ↔ parameters.toBlockCode.Codeword w := by
  change parityMatrix *ᵥ w = 0 ↔ parameters.Codeword w
  rw [codeword_iff_evaluation]
  constructor
  · intro zero
    refine ⟨coefficients *ᵥ w, ?_⟩
    have assembled := congrArg (fun M : Matrix (Fin 8) (Fin 8) (ZMod 17) => M *ᵥ w) reconstruction
    simpa only [Matrix.add_mulVec, ← Matrix.mulVec_mulVec, zero, Matrix.mulVec_zero,
      add_zero, Matrix.one_mulVec] using assembled
  · rintro ⟨c, rfl⟩
    rw [Matrix.mulVec_mulVec, parity_mul_evaluation, Matrix.zero_mulVec]

def supportLeft (i : Fin 4) : Fin 8 := ⟨2 * i.val, by omega⟩

def supportRight (i : Fin 4) : Fin 8 := ⟨2 * i.val + 1, by omega⟩

/-- The `i`th erasure support consists of the sites at positions `2i` and `2i+1`. -/
def support (i : Fin 4) : Finset (Fin 8) := {supportLeft i, supportRight i}

theorem support_card (i : Fin 4) : (support i).card = 2 := by
  revert i
  decide

end ProximityCoding.MCA.Syndrome.Seventeen
