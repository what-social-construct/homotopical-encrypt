module

public import Proximity.Capacity.Realization
public import Proximity.ListDecoding.PhaseSplit

@[expose] public section

/-!
# Full list thresholds for the realized smooth family

These corollaries instantiate the generic phase theorem using the constructed
Galois fields and power domains. No field/domain realization or numerical
budget is left as a supplied hypothesis.
-/

namespace ProximityPrize
namespace Capacity.SmoothQuarterFamily

open BlockCode CapacityList

noncomputable section

private theorem realized_listBudget (u : ℕ) :
    (Nat.choose (Fintype.card (Fin (length u))) (parameters u).degreeBound : ℝ) ≤
      ((1 : ℝ) / 2 ^ 128) * Fintype.card (RSField u) := by
  classical
  apply ((parameters u).vectorFractionalListSizeBoundAt_capacityGrid_iff
    (σ := Unit) () ((1 : ℝ) / 2 ^ 128)
    (by simpa using degreeBound_pos u)
    (by simpa using length_pos u)
    (by simpa using degreeBound_le_length u)).mp
  simpa only [Fintype.card_fin, parameters_degreeBound, card_RSField] using
    realized_fractionalListSizeBoundAt_capacity u Unit ()

/-- The family's normalized capacity grid point is exactly `3/4`. -/
theorem realized_capacityRadius_eq_threeQuarters (u : ℕ) :
    BlockCode.relativeRadius (ι := Fin (length u)) (length u - degreeBound u) = (3 : ℝ) / 4 := by
  have hn : (length u : ℝ) ≠ 0 := by exact_mod_cast (length_pos u).ne'
  have hrate : (4 : ℝ) * degreeBound u = length u := by
    exact_mod_cast four_mul_degreeBound u
  unfold BlockCode.relativeRadius
  rw [Fintype.card_fin, Nat.cast_sub (degreeBound_le_length u)]
  field_simp [hn]
  nlinarith

/-- The real cut is one Hamming shell past `3/4`. -/
theorem realized_nextShellRadius_eq (u : ℕ) :
    BlockCode.relativeRadius (ι := Fin (length u)) (length u - degreeBound u + 1) =
      (3 : ℝ) / 4 + 1 / length u := by
  have hn : (length u : ℝ) ≠ 0 := by exact_mod_cast (length_pos u).ne'
  have hrate : (4 : ℝ) * degreeBound u = length u := by
    exact_mod_cast four_mul_degreeBound u
  unfold BlockCode.relativeRadius
  rw [Fintype.card_fin, Nat.cast_add, Nat.cast_one, Nat.cast_sub (degreeBound_le_length u)]
  field_simp [hn]
  nlinarith

/-- Exact nonnegative real safe radii for every realized family member and width. -/
theorem realized_listSafeRelativeRadii_eq_Ico
    (u : ℕ) (σ : Type*) [Fintype σ] [Nonempty σ] :
    safeRelativeRadii ((parameters u).vectorBlockCode σ)
        ((1 : ℝ) / 2 ^ 128) (fieldCard u) =
      Set.Ico 0 (BlockCode.relativeRadius (ι := Fin (length u))
        (length u - degreeBound u + 1)) := by
  have h := (parameters u).vectorFractionalListSafeRelativeRadii_eq_Ico
    (σ := σ) (ε := ((1 : ℝ) / 2 ^ 128))
    (by norm_num) (by simpa using degreeBound_pos u)
    (by simpa using length_pos u) (by simpa using degreeBound_le_length u)
    (realized_listBudget u)
  simpa only [Fintype.card_fin, parameters_degreeBound, card_RSField] using h

/-- Both integer-grid endpoints, without a supplied realization or budget. -/
theorem realized_listGridThreshold
    (u : ℕ) (σ : Type*) [Fintype σ] [Nonempty σ] :
    FiniteThreshold.greatestSafe (length u)
        (fun r => FractionalListSizeBoundAt ((parameters u).vectorBlockCode σ)
          (BlockCode.relativeRadius (ι := Fin (length u)) r)
          ((1 : ℝ) / 2 ^ 128) (fieldCard u)) =
      ((length u - degreeBound u : ℕ) : WithBot ℕ) ∧
    FiniteThreshold.firstUnsafe (length u)
        (fun r => FractionalListSizeBoundAt ((parameters u).vectorBlockCode σ)
          (BlockCode.relativeRadius (ι := Fin (length u)) r)
          ((1 : ℝ) / 2 ^ 128) (fieldCard u)) =
      ((length u - degreeBound u + 1 : ℕ) : WithTop ℕ) := by
  have h := (parameters u).vectorFractionalListGridThreshold
    (σ := σ) (ε := ((1 : ℝ) / 2 ^ 128))
    (by norm_num) (by simpa using degreeBound_pos u)
    (by simpa using length_pos u) (by simpa using degreeBound_le_length u)
    (realized_listBudget u)
  simpa only [Fintype.card_fin, parameters_degreeBound, card_RSField] using h

/-- The family's real safe supremum is excluded, and no greatest real radius exists. -/
theorem realized_listRealThreshold
    (u : ℕ) (σ : Type*) [Fintype σ] [Nonempty σ] :
    sSup (safeRelativeRadii ((parameters u).vectorBlockCode σ)
        ((1 : ℝ) / 2 ^ 128) (fieldCard u)) =
        BlockCode.relativeRadius (ι := Fin (length u)) (length u - degreeBound u + 1) ∧
      BlockCode.relativeRadius (ι := Fin (length u)) (length u - degreeBound u + 1) ∉
        safeRelativeRadii ((parameters u).vectorBlockCode σ)
          ((1 : ℝ) / 2 ^ 128) (fieldCard u) ∧
      ¬ ∃ δ, IsGreatest (safeRelativeRadii ((parameters u).vectorBlockCode σ)
        ((1 : ℝ) / 2 ^ 128) (fieldCard u)) δ := by
  have h := (parameters u).vectorFractionalListRealThreshold
    (σ := σ) (ε := ((1 : ℝ) / 2 ^ 128))
    (by norm_num) (by simpa using degreeBound_pos u)
    (by simpa using length_pos u) (by simpa using degreeBound_le_length u)
    (realized_listBudget u)
  simpa only [Fintype.card_fin, parameters_degreeBound, card_RSField] using h

end
end Capacity.SmoothQuarterFamily
end ProximityPrize
