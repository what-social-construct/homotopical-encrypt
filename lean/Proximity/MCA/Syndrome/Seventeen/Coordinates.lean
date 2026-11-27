module

public import Mathlib.Algebra.BigOperators.Fin
public import Mathlib.Algebra.Field.ZMod
public import Mathlib.Data.Fin.VecNotation
public import Mathlib.LinearAlgebra.Pi

import Mathlib.Tactic.FinCases
import Mathlib.Tactic.Ring

@[expose] public section

/-!
# The matching equations over `𝔽₁₇`

The two annihilating rows for each support give a linear condition on
the six Plücker coordinates. A finite matrix identity eliminates four
coordinates simultaneously for the specified matching.
-/

set_option autoImplicit false

namespace ProximityCoding.MCA.Syndrome.Seventeen

local instance : Fact (Nat.Prime 17) := ⟨by decide⟩

/-- First endpoint of each of the four support pairs. -/
def firstEndpoint : Fin 4 → ZMod 17 := ![1, 13, 16, 4]

/-- Second endpoint of each of the four support pairs. -/
def secondEndpoint : Fin 4 → ZMod 17 := ![9, 15, 8, 2]

/-- The parity-check column at a multiplicative evaluation site. -/
def powerColumn (a : ZMod 17) : Fin 4 → ZMod 17 := ![a, a^2, a^3, a^4]

/-- The coefficients of `(X - a) * (X - b)` on the first three coordinates. -/
def row0 (a b : ZMod 17) : (Fin 4 → ZMod 17) →ₗ[ZMod 17] ZMod 17 :=
  (a * b) • LinearMap.proj 0 - (a + b) • LinearMap.proj 1 + LinearMap.proj 2

/-- The same coefficients shifted one coordinate. -/
def row1 (a b : ZMod 17) : (Fin 4 → ZMod 17) →ₗ[ZMod 17] ZMod 17 :=
  (a * b) • LinearMap.proj 1 - (a + b) • LinearMap.proj 2 + LinearMap.proj 3

@[simp]
theorem row0_apply (a b : ZMod 17) (s : Fin 4 → ZMod 17) :
    row0 a b s = a * b * s 0 - (a + b) * s 1 + s 2 := rfl

@[simp]
theorem row1_apply (a b : ZMod 17) (s : Fin 4 → ZMod 17) :
    row1 a b s = a * b * s 1 - (a + b) * s 2 + s 3 := rfl

/-- Both rows vanish on both endpoint columns of their support. -/
theorem rows_annihilate_endpoints (a b : ZMod 17) :
    row0 a b (powerColumn a) = 0 ∧ row1 a b (powerColumn a) = 0 ∧
    row0 a b (powerColumn b) = 0 ∧ row1 a b (powerColumn b) = 0 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> simp [powerColumn] <;> ring

/-- The determinant after applying the annihilating rows to the two generators. -/
def det2 (a b : ZMod 17) (s t : Fin 4 → ZMod 17) : ZMod 17 :=
  row0 a b s * row1 a b t - row0 a b t * row1 a b s

/-- An oriented two-row minor of the matrix with columns `s` and `t`. -/
def minor (s t : Fin 4 → ZMod 17) (i j : Fin 4) : ZMod 17 :=
  s i * t j - s j * t i

/-- The minors in the order `01, 02, 03, 12, 13, 23`. -/
def plucker (s t : Fin 4 → ZMod 17) : Fin 6 → ZMod 17 :=
  ![minor s t 0 1, minor s t 0 2, minor s t 0 3,
    minor s t 1 2, minor s t 1 3, minor s t 2 3]

/-- The Grassmann quadratic for the six signed minors. -/
theorem plucker_quad (s t : Fin 4 → ZMod 17) :
    plucker s t 0 * plucker s t 5 - plucker s t 1 * plucker s t 4 +
      plucker s t 2 * plucker s t 3 = 0 := by
  simp [plucker, minor]
  ring

/-- An injective two-generator pencil has a nonzero Plücker vector. -/
theorem plucker_ne_zero (s t : Fin 4 → ZMod 17)
    (injective : Function.Injective (fun v : ZMod 17 × ZMod 17 => v.1 • s + v.2 • t)) :
    plucker s t ≠ 0 := by
  intro zero
  have ordered {i j : Fin 4} (less : i < j) : minor s t i j = 0 := by
    fin_cases i <;> fin_cases j <;> simp [Fin.lt_def] at less <;>
      first
      | exact congrFun zero (0 : Fin 6)
      | exact congrFun zero (1 : Fin 6)
      | exact congrFun zero (2 : Fin 6)
      | exact congrFun zero (3 : Fin 6)
      | exact congrFun zero (4 : Fin 6)
      | exact congrFun zero (5 : Fin 6)
  have every (i j : Fin 4) : minor s t i j = 0 := by
    rcases lt_trichotomy i j with less | rfl | greater
    · exact ordered less
    · simp [minor]
    · calc
        minor s t i j = -minor s t j i := by unfold minor; ring
        _ = 0 := by rw [ordered greater, neg_zero]
  have nonzero : s ≠ 0 := by
    intro hs
    have equal : ((1, 0) : ZMod 17 × ZMod 17) = (0, 0) := injective (by simp [hs])
    exact one_ne_zero (congrArg Prod.fst equal)
  obtain ⟨i, hi⟩ : ∃ i : Fin 4, s i ≠ 0 := by
    by_contra h
    apply nonzero
    funext i
    by_contra hi
    exact h ⟨i, hi⟩
  have proportion : t = (t i / s i) • s := by
    funext j
    simp only [Pi.smul_apply, smul_eq_mul]
    rw [div_mul_eq_mul_div, eq_div_iff hi]
    simpa only [mul_comm (t j) (s i), mul_comm (t i) (s j)] using
      sub_eq_zero.mp (every i j)
  have equal : ((t i / s i, 0) : ZMod 17 × ZMod 17) = (0, 1) :=
    injective (by simpa using proportion.symm)
  exact zero_ne_one (congrArg Prod.snd equal)

/-- The six signed minors of the two annihilating rows. -/
def quotientMinors (a b : ZMod 17) : Fin 6 → ZMod 17 :=
  ![(a * b)^2, -(a * b) * (a + b), a * b, (a + b)^2 - a * b, -(a + b), 1]

/-- The determinant condition is a linear equation in Plücker coordinates. -/
theorem det2_eq_plucker (a b : ZMod 17) (s t : Fin 4 → ZMod 17) :
    det2 a b s t = ∑ j, quotientMinors a b j * plucker s t j := by
  simp [det2, quotientMinors, plucker, minor, Fin.sum_univ_succ]
  ring

private def combinations : Fin 4 → Fin 4 → ZMod 17 :=
  ![![1, 1, 1, 1], ![11, 7, 6, 10], ![9, 8, 9, 8], ![14, 5, 3, 12]]

private def reducedRows : Fin 4 → Fin 6 → ZMod 17 :=
  ![![1, 0, 0, 0, 0, 4], ![0, 1, 0, 0, 0, 0],
    ![0, 0, 1, 12, 0, 0], ![0, 0, 0, 0, 1, 0]]

private theorem checked_elimination : ∀ i : Fin 4, ∀ j : Fin 6,
    (∑ k, combinations i k * quotientMinors (firstEndpoint k) (secondEndpoint k) j) =
      reducedRows i j := by decide

/-- All four matching constraints leave only the two displayed free coordinates. -/
theorem matching_elimination (s t : Fin 4 → ZMod 17)
    (hits : ∀ i : Fin 4, det2 (firstEndpoint i) (secondEndpoint i) s t = 0) :
    plucker s t = ![13 * plucker s t 5, 0, 5 * plucker s t 3,
      plucker s t 3, 0, plucker s t 5] := by
  let p := plucker s t
  have original (i : Fin 4) :
      (∑ j, quotientMinors (firstEndpoint i) (secondEndpoint i) j * p j) = 0 :=
    (det2_eq_plucker (firstEndpoint i) (secondEndpoint i) s t).symm.trans (hits i)
  have reduced (i : Fin 4) : (∑ j, reducedRows i j * p j) = 0 := by
    calc
      _ = ∑ j, (∑ k, combinations i k *
          quotientMinors (firstEndpoint k) (secondEndpoint k) j) * p j := by
        simp only [checked_elimination]
      _ = ∑ k, combinations i k *
          (∑ j, quotientMinors (firstEndpoint k) (secondEndpoint k) j * p j) := by
        simp_rw [Finset.sum_mul, Finset.mul_sum, mul_assoc]
        exact Finset.sum_comm
      _ = 0 := by simp [original]
  have first := reduced 0
  have second := reduced 1
  have third := reduced 2
  have fifth := reduced 3
  simp [reducedRows, Fin.sum_univ_succ] at first second third fifth
  have neg_four : -(4 : ZMod 17) = 13 := by decide
  have neg_twelve : -(12 : ZMod 17) = 5 := by decide
  have first' : p 0 = 13 * p 5 := by
    calc
      p 0 = -(4 * p 5) := eq_neg_of_add_eq_zero_left first
      _ = 13 * p 5 := by rw [← neg_mul, neg_four]
  have third' : p 2 = 5 * p 3 := by
    calc
      p 2 = -(12 * p 3) := eq_neg_of_add_eq_zero_left third
      _ = 5 * p 3 := by rw [← neg_mul, neg_twelve]
  funext j
  fin_cases j
  · exact first'
  · exact second
  · exact third'
  · rfl
  · exact fifth
  · rfl

end ProximityCoding.MCA.Syndrome.Seventeen
