module

public import Proximity.Capacity.UniqueRadius
public import Proximity.MCA.BoundaryField

@[expose] public section

/-!
# The 128-bit list threshold on the smooth boundary field

The same prime field and domain as the exact pair-MCA example have a list
budget in `[1, 2)`. The interleaved minimum distance is `3073`, so the list
transition is from count `1536` to `1537` at every positive width.
-/

set_option autoImplicit false

namespace ProximityCoding.MCA.BoundaryField

open BlockCode CapacityList

private theorem listBudget_128 :
    1 ≤ ((1 : ℝ) / 2 ^ 128) * Fintype.card RSField ∧
      ((1 : ℝ) / 2 ^ 128) * Fintype.card RSField < 2 := by
  have hlow : (2 : ℝ) ^ 128 ≤ (Fintype.card RSField : ℝ) := by
    exact_mod_cast one_challenge_128_bit_budget
  have hhigh : (Fintype.card RSField : ℝ) < (2 : ℝ) ^ 128 * 2 := by
    exact_mod_cast two_challenges_exceed_128_bit_budget
  have hpos : (0 : ℝ) < 2 ^ 128 := by positivity
  rw [div_mul_eq_mul_div, one_mul]
  exact ⟨(le_div_iff₀ hpos).mpr (by simpa using hlow),
    (div_lt_iff₀ hpos).mpr (by simpa [mul_comm] using hhigh)⟩

variable {σ : Type*} [Fintype σ] [Nonempty σ]

/-- Exactly the counts up to `1536` meet the 128-bit fractional list budget. -/
theorem listSafeCount_128_iff (r : ℕ) :
    FractionalListSizeBoundAt (parameters.vectorBlockCode σ)
        (relativeRadius (ι := Fin length) r) ((1 : ℝ) / 2 ^ 128)
        (Fintype.card RSField) ↔ r ≤ 1536 := by
  have hDistance : Fintype.card (Fin length) - parameters.degreeBound + 1 = 3073 := by
    norm_num [parameters_degreeBound, length]
  rw [parameters.vectorFractionalListSizeBoundAt_relativeRadius_iff_of_budget_one_two
    (by norm_num [parameters_degreeBound])
    (by norm_num [parameters_degreeBound, length]) r listBudget_128.1 listBudget_128.2,
    hDistance]
  omega

/-- The exact count-grid endpoints at 128 bits, for every positive width. -/
theorem list_exact_128_bit_threshold :
    FiniteThreshold.greatestSafe length
        (fun r => FractionalListSizeBoundAt (parameters.vectorBlockCode σ)
          (relativeRadius (ι := Fin length) r) ((1 : ℝ) / 2 ^ 128)
          (Fintype.card RSField)) = ((1536 : ℕ) : WithBot ℕ) ∧
    FiniteThreshold.firstUnsafe length
        (fun r => FractionalListSizeBoundAt (parameters.vectorBlockCode σ)
          (relativeRadius (ι := Fin length) r) ((1 : ℝ) / 2 ^ 128)
          (Fintype.card RSField)) = ((1537 : ℕ) : WithTop ℕ) := by
  apply And.intro
  · apply FiniteThreshold.greatestSafe_eq_coe_iff.mpr
    exact ⟨by decide, (listSafeCount_128_iff 1536).mpr le_rfl,
      fun r _ hr => (listSafeCount_128_iff r).mp hr⟩
  · apply FiniteThreshold.firstUnsafe_eq_coe_iff.mpr
    refine ⟨by decide, fun h => by simpa using (listSafeCount_128_iff 1537).mp h, ?_⟩
    intro r _ hr
    by_contra h
    exact hr ((listSafeCount_128_iff r).mpr (by omega))

/-- The first unsafe grid point is excluded from the real safe interval. -/
theorem list_safeRelativeRadii_128_eq_Ico :
    safeRelativeRadii (parameters.vectorBlockCode σ) ((1 : ℝ) / 2 ^ 128)
        (Fintype.card RSField) = Set.Ico 0 ((1537 : ℝ) / 4096) := by
  have h := parameters.vectorFractionalListSafeRelativeRadii_eq_Ico_of_budget_one_two
    (σ := σ) (by norm_num [parameters_degreeBound])
    (by norm_num [parameters_degreeBound, length]) listBudget_128.1 listBudget_128.2
  simpa only [Fintype.card_fin, parameters_degreeBound,
    show (length - 1024) / 2 + 1 = 1537 by decide,
    show relativeRadius (ι := Fin length) 1537 = (1537 : ℝ) / 4096 by
      norm_num [relativeRadius, length]] using h

end ProximityCoding.MCA.BoundaryField
