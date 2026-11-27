module

public import Mathlib.Algebra.Polynomial.Eval.Defs
public import Mathlib.FieldTheory.Finite.Basic

import Mathlib.Algebra.Ring.GeomSum
import Mathlib.Tactic.Ring

public section

/-!
# Polynomial identity certificate for the reduced chart over 𝔽₁₇
-/

set_option autoImplicit false

namespace ProximityCoding.MCA.Syndrome

open Polynomial
open scoped BigOperators

/-- Evaluating a unit-ideal identity at a common root gives a contradiction. -/
theorem no_common_root_of_unit_identity {R I : Type*} [CommSemiring R] [Nontrivial R] [Fintype I]
    (generators multipliers : I → Polynomial R)
    (identity : ∑ i, multipliers i * generators i = 1)
    {u : R} (vanishes : ∀ i, (generators i).eval u = 0) : False := by
  have evaluated := congrArg (Polynomial.eval u) identity
  rw [Polynomial.eval_finsetSum] at evaluated
  simp [vanishes] at evaluated

namespace Seventeen

local instance : Fact (Nat.Prime 17) := ⟨by decide⟩

/-- The geometric sum appearing in the multiplier for `X² - 11`. -/
noncomputable def certificateSum : Polynomial (ZMod 17) :=
  ∑ j ∈ Finset.range 8, C ((11 : ZMod 17) ^ j) * X ^ (14 - 2 * j)

private theorem certificateSum_mul :
    certificateSum * (X ^ 2 - 11) = X ^ 16 - 16 := by
  have constantEleven : C (11 : ZMod 17) = (11 : Polynomial (ZMod 17)) := C_eq_natCast 11
  have sumForm : certificateSum =
      ∑ j ∈ Finset.range 8, (11 : Polynomial (ZMod 17)) ^ j * (X ^ 2) ^ (7 - j) := by
    apply Finset.sum_congr rfl
    intro j _
    rw [map_pow, constantEleven, ← pow_mul, Nat.mul_sub]
  have product := geom_sum₂_mul (11 : Polynomial (ZMod 17)) (X ^ 2) 8
  rw [← sumForm] at product
  have constantPower : (11 : Polynomial (ZMod 17)) ^ 8 = 16 := by
    calc
      (11 : Polynomial (ZMod 17)) ^ 8 = C ((11 : ZMod 17) ^ 8) := by
        rw [map_pow, constantEleven]
      _ = C (16 : ZMod 17) := congrArg C (by decide)
      _ = 16 := C_eq_natCast 16
  calc
    certificateSum * (X ^ 2 - 11) = -(certificateSum * (11 - X ^ 2)) := by ring
    _ = -((11 : Polynomial (ZMod 17)) ^ 8 - (X ^ 2) ^ 8) := congrArg Neg.neg product
    _ = X ^ 16 - 16 := by rw [neg_sub, ← pow_mul, constantPower]

/-- The explicit unit-ideal identity for the two reduced chart equations. -/
theorem reducedChart_unit_identity :
    (1 : Polynomial (ZMod 17)) =
      (7 * X ^ 2 * certificateSum + 3) * (X ^ 2 - 11) + 10 * X * (X ^ 17 - X) := by
  symm
  have characteristic : (17 : Polynomial (ZMod 17)) = 0 := by
    have fieldCharacteristic : (17 : ZMod 17) = 0 := ZMod.natCast_self 17
    calc
      (17 : Polynomial (ZMod 17)) = C (17 : ZMod 17) := (C_eq_natCast 17).symm
      _ = 0 := by rw [fieldCharacteristic, map_zero]
  calc
    _ = (7 * X ^ 2) * (certificateSum * (X ^ 2 - 11)) +
          3 * (X ^ 2 - 11) + 10 * X * (X ^ 17 - X) := by ring
    _ = 1 + 17 * (X ^ 18 - 7 * X ^ 2 - 2) := by rw [certificateSum_mul]; ring
    _ = 1 := by rw [characteristic, zero_mul, add_zero]

/-- The reduced chart has no point over the stated finite field. -/
theorem sq_ne_eleven (u : ZMod 17) : u ^ 2 ≠ 11 := by
  intro square
  let generators : Fin 2 → Polynomial (ZMod 17) := ![X ^ 2 - 11, X ^ 17 - X]
  let multipliers : Fin 2 → Polynomial (ZMod 17) := ![7 * X ^ 2 * certificateSum + 3, 10 * X]
  have identity : ∑ i, multipliers i * generators i = 1 := by
    simpa [generators, multipliers, Fin.sum_univ_two] using reducedChart_unit_identity.symm
  apply no_common_root_of_unit_identity generators multipliers identity (u := u)
  rw [Fin.forall_fin_two]
  exact ⟨by simp [generators, square], by simp [generators, ZMod.pow_card u]⟩

end Seventeen
end ProximityCoding.MCA.Syndrome
