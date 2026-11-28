module

public import Proximity.MCA.SparsePencil
public import Proximity.MCA.DisjointBorder
public import Proximity.MCA.LocatorPencil
public import Proximity.MCA.RealThreshold
public import Proximity.MCA.Syndrome.Sixteen.LocatorCensus
public import Mathlib.FieldTheory.Finite.GaloisField

@[expose] public section

/-! # Field and threshold endpoints for the length-sixteen locator example -/

set_option autoImplicit false

namespace ProximityCoding.MCA.Syndrome.Sixteen

open BlockCode LocatorCensus

noncomputable section

/-- This field gives an integer budget of four at the 128-bit target. -/
abbrev RSField := GaloisField 3617 11

instance fieldFintype : Fintype RSField := Fintype.ofFinite _

theorem card_RSField : Fintype.card RSField = 3617 ^ 11 := by
  rw [← Nat.card_eq_fintype_card]
  exact GaloisField.card 3617 11 (by decide)

theorem budget_eq_four : Fintype.card RSField / 2 ^ 128 = 4 := by
  rw [card_RSField]
  decide

/-- An extension-field proportionality of nonzero coefficient directions
has a base-field scalar, obtained from any nonzero coordinate. -/
theorem direction_descends {ι : Type*} (u v : ι → BaseField) (j : ι) (nonzero : v j ≠ 0)
    (c : RSField) (proportional : ∀ i, algebraMap BaseField RSField (u i) =
      c * algebraMap BaseField RSField (v i)) :
    ∀ i, u i = (u j / v j) * v i := by
  have scalar : c = algebraMap BaseField RSField (u j / v j) := by
    rw [map_div₀]
    exact (eq_div_iff ((map_ne_zero_iff _ (algebraMap BaseField RSField).injective).mpr nonzero)).mpr
      (proportional j).symm
  intro i
  apply (algebraMap BaseField RSField).injective
  rw [map_mul, ← scalar]
  exact proportional i

/-- The order-sixteen base-field sites included into the challenge field. -/
def evaluationDomain : ReedSolomon.EvaluationDomain RSField (Fin 16) where
  point i := algebraMap BaseField RSField (site i)
  injective_point := (algebraMap BaseField RSField).injective.comp site_injective

def parameters : ReedSolomon.Parameters RSField (Fin 16) where
  domain := evaluationDomain
  degreeBound := 8

/-- The count before the disjoint-support shell has exactly three bad challenges. -/
theorem worstBadCount_two : parameters.toBlockCode.worstBadCount 2 = 3 := by
  exact parameters.worstBadCount_eq_succ_of_three_mul_le (by decide) (by decide) (by decide)

/-- The only upper-bound obligation at radius three is the exclusion of
five disjoint triple locators on a single affine line. -/
theorem worstBadCount_three_le_of_no_five_locators
    (noFive : ∀ (E : Fin 5 → Finset (Fin 16)),
      Pairwise (fun i j => Disjoint (E i) (E j)) → (∀ i, (E i).card = 3) →
      ∀ c : Fin 5 → RSField, (∀ i, parameters.capacityVanishingPolynomial (E i) -
        parameters.capacityVanishingPolynomial (E 0) = c i •
          (parameters.capacityVanishingPolynomial (E 1) - parameters.capacityVanishingPolynomial (E 0))) →
      False) : parameters.toBlockCode.worstBadCount 3 ≤ 4 := by
  classical
  apply (parameters.toBlockCode.worstBadCount_le_iff 3 4).mpr
  intro L
  by_contra! exceeds
  obtain ⟨γ, E, injective, disjoint, tests⟩ := parameters.exists_disjoint_badSupports_of_border
    (r := 3) (m := 5) (by decide) (by decide) L exceeds (by omega) (by decide)
  have size (i : Fin 5) : (E i).card = 3 := (tests i).1
  obtain ⟨c, line⟩ := parameters.exists_locator_collinearity_of_disjoint_badSupports
    (by decide) (by decide) (by decide) (by decide) L γ E injective disjoint size
    (fun i => (tests i).2) (a := 0) (b := 1) (by decide)
  exact noFive E disjoint size c line

/-- Five coordinated cancellations already exceed the budget at count four. -/
theorem not_pairMCA_secure_128_four : ¬ parameters.toBlockCode.PairMCASecureAtBits 128 4 := by
  obtain ⟨L, witness⟩ := parameters.exists_badChallengeSet_card_ge_of_le_succ
    (r := 4) (t := 5) (by decide) (by decide) (by decide) (by rw [card_RSField]; decide)
  apply parameters.toBlockCode.not_pairMCASecureAtBits_of_badLine L
  have exceeds : Fintype.card RSField < 2 ^ 128 * 5 := by rw [card_RSField]; decide
  exact exceeds.trans_le (Nat.mul_le_mul_left _ witness)

private theorem secure_three_of_no_fifth (upper : parameters.toBlockCode.worstBadCount 3 ≤ 4) :
    parameters.toBlockCode.PairMCASecureAtBits 128 3 := by
  have budget := (Nat.le_div_iff_mul_le (by decide : 0 < (2 : ℕ) ^ 128)).mp budget_eq_four.ge
  exact parameters.toBlockCode.pairMCASecureAtBits_of_countBound
    ((parameters.toBlockCode.pairMCACountBound_iff_worstBadCount_le 3 4).mpr upper)
    (by simpa only [Nat.mul_comm] using budget)

/-- The grid conclusion from the upper bound at the disjoint-support shell. -/
theorem pairMCA_threshold_of_no_fifth (upper : parameters.toBlockCode.worstBadCount 3 ≤ 4) :
    parameters.toBlockCode.pairMCAGreatestSafe 128 = (3 : WithBot ℕ) ∧
      parameters.toBlockCode.pairMCAFirstUnsafe 128 = (4 : WithTop ℕ) :=
  parameters.toBlockCode.pairMCAThreshold_eq_of_safe_next_unsafe (by decide)
    (secure_three_of_no_fifth upper) not_pairMCA_secure_128_four

/-- The real safe interval from the same radius-three upper bound. -/
theorem pairMCA_safeRelativeRadii_of_no_fifth (upper : parameters.toBlockCode.worstBadCount 3 ≤ 4) :
    parameters.toBlockCode.pairMCASafeRelativeRadii 128 = Set.Ico 0 ((4 : ℝ) / 16) := by
  simpa only [relativeRadius, Fintype.card_fin, show (3 : ℕ) + 1 = 4 by decide, Nat.cast_ofNat] using
    parameters.toBlockCode.pairMCASafeRelativeRadii_eq_Ico_of_safe_next_unsafe
      (by decide) (secure_three_of_no_fifth upper) not_pairMCA_secure_128_four

end
end ProximityCoding.MCA.Syndrome.Sixteen
