module

public import Proximity.Capacity.AgreementPacking
public import Mathlib.FieldTheory.Finite.GaloisField
public import Mathlib.GroupTheory.OrderOfElement

@[expose] public section

/-!
# Field and arithmetic certificates for a length-128 smooth code

The evaluation domain is the order-128 subgroup of the prime field
`ZMod 641`, embedded in `GaloisField 641 26`. The arithmetic certificates
compare the integer budget at target `2^-128` with the list-packing,
locator-prefix, and MCA circuit counts used in the manuscript.
-/

set_option autoImplicit false

namespace ProximityCoding.Capacity.SubfieldThreshold

noncomputable section

/-- The prime field containing all the evaluation points. -/
abbrev BaseField := ZMod 641

theorem base_prime : Nat.Prime 641 := by norm_num

instance basePrimeFact : Fact (Nat.Prime 641) := ⟨base_prime⟩

/-- The field used for codewords and challenges. -/
abbrev RSField := GaloisField 641 26

instance fieldFintype : Fintype RSField := Fintype.ofFinite _

instance fieldDecidableEq : DecidableEq RSField := Classical.decEq _

/-- The cardinality of the codeword and challenge field. -/
def fieldCard : ℕ := 641 ^ 26

@[simp]
theorem card_RSField : Fintype.card RSField = fieldCard := by
  rw [← Nat.card_eq_fintype_card]
  exact GaloisField.card 641 26 (by decide)

theorem fieldCard_lt_two_pow_256 : fieldCard < 2 ^ 256 := by decide

/-- A generator of the base field's subgroup of order 128. -/
def rootUnit : BaseFieldˣ := Units.mk0 21 (by decide)

theorem rootUnit_order : orderOf rootUnit = 128 := by
  rw [← orderOf_units]
  let _ : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  apply orderOf_eq_prime_pow (p := 2) (n := 6)
  · change (21 : BaseField) ^ 64 ≠ 1
    decide
  · change (21 : BaseField) ^ 128 = 1
    decide

/-- The evaluation domain lies in the image of the prime field. -/
def evaluationDomain : ReedSolomon.EvaluationDomain RSField (Fin 128) where
  point i := algebraMap BaseField RSField (↑(rootUnit ^ (i : ℕ)) : BaseField)
  injective_point := by
    intro i j hij
    have hunits : rootUnit ^ (i : ℕ) = rootUnit ^ (j : ℕ) :=
      Units.ext ((algebraMap BaseField RSField).injective hij)
    have hmod := pow_eq_pow_iff_modEq.mp hunits
    rw [rootUnit_order] at hmod
    exact Fin.ext (by
      unfold Nat.ModEq at hmod
      simpa [Nat.mod_eq_of_lt i.isLt, Nat.mod_eq_of_lt j.isLt] using hmod)

/-- The same subgroup domain with its base-field root-order certificate. -/
def smoothEvaluationDomain : ReedSolomon.SmoothEvaluationDomain RSField (Fin 128) where
  toEvaluationDomain := evaluationDomain
  smooth := orderOf rootUnit = 128

theorem smoothEvaluationDomain_smooth : smoothEvaluationDomain.smooth := rootUnit_order

/-- The length-128 half-rate code over the extension field. -/
def parameters : ReedSolomon.Parameters RSField (Fin 128) where
  domain := evaluationDomain
  degreeBound := 64

/-- The largest integer count allowed by the fractional target. -/
def budget : ℕ := fieldCard / 2 ^ 128

theorem budget_eq : budget = 27955632488535336577577692993784094 := by decide

/-- The list agreement-packing bound at 66 agreements fits the budget. -/
theorem list_packing_le_budget : Nat.choose 128 64 / Nat.choose 66 64 ≤ budget := by
  simp only [Nat.choose_eq_descFactorial_div_factorial]
  decide

/-- Every list at count radius 62 is within the fractional target. -/
theorem vectorFractionalListSizeBoundAt_sixtytwo (σ : Type*) [Fintype σ] :
    CapacityList.FractionalListSizeBoundAt (parameters.vectorBlockCode σ)
      (BlockCode.relativeRadius (ι := Fin 128) 62) ((1 : ℝ) / 2 ^ 128)
      (Fintype.card RSField) := by
  intro w
  have hDegree : parameters.degreeBound = 64 := rfl
  have hAgreement : parameters.degreeBound ≤ Fintype.card (Fin 128) - 62 := by
    rw [hDegree, Fintype.card_fin]
    decide
  have hPacking : (parameters.vectorBlockCode σ).ballCard 62 w ≤
      Nat.choose 128 64 / Nat.choose 66 64 := by
    simpa only [hDegree, Fintype.card_fin, show (128 : ℕ) - 62 = 66 by decide] using
      parameters.vectorListSizeBound_packing σ 62 hAgreement w
  have hBudget : (budget : ℝ) ≤ ((1 : ℝ) / 2 ^ 128) * Fintype.card RSField := by
    rw [card_RSField, div_mul_eq_mul_div, one_mul]
    apply (le_div_iff₀ (by positivity : (0 : ℝ) < 2 ^ 128)).mpr
    exact_mod_cast Nat.div_mul_le_self fieldCard (2 ^ 128)
  rw [(parameters.vectorBlockCode σ).ballCardAt_relativeRadius_eq_ballCard (by norm_num) w]
  exact (by exact_mod_cast hPacking.trans list_packing_le_budget :
    ((parameters.vectorBlockCode σ).ballCard 62 w : ℝ) ≤ budget).trans hBudget

/-- Some sum fibre of 65-subsets exceeds the list budget. -/
theorem budget_lt_list_fibre : budget < (Nat.choose 128 65 + 640) / 641 := by
  simp only [Nat.choose_eq_descFactorial_div_factorial]
  decide

/-- The MCA circuit-incidence bound at 67 agreements fits the budget. -/
theorem mca_circuit_le_budget : Nat.choose 128 65 / Nat.choose 66 64 ≤ budget := by
  simp only [Nat.choose_eq_descFactorial_div_factorial]
  decide

/-- Some sum fibre of 66-subsets gives enough distinct polynomial witnesses. -/
theorem budget_lt_mca_fibre : budget < (Nat.choose 128 66 + 640) / 641 := by
  simp only [Nat.choose_eq_descFactorial_div_factorial]
  decide

/-- A pole outside the 128 evaluation sites separates `budget + 1`
polynomials of degree at most 64 by the root-count union bound. -/
theorem pole_root_budget : 128 + 64 * Nat.choose (budget + 1) 2 < fieldCard := by
  simp only [Nat.choose_eq_descFactorial_div_factorial]
  decide

end
end ProximityCoding.Capacity.SubfieldThreshold
