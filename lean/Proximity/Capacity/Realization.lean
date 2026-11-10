module

public import Proximity.Capacity.Parameters
public import Proximity.Core.ReedSolomon
public import Proximity.ListDecoding.Capacity
public import Proximity.MCA.Pair
public import Mathlib.FieldTheory.Finite.GaloisField

@[expose] public section

/-!
# The smooth quarter-rate family, with its field and power domain

This module constructs the previously numerical family over
`GaloisField 3 (length u)`. The selected root has exact order `length u`,
so its first `length u` powers form an injectively indexed multiplicative
subgroup domain. The list and pair-MCA corollaries no longer require a
field/domain realization as an input.
-/

namespace ProximityCoding
namespace Capacity.SmoothQuarterFamily

noncomputable section

theorem length_pos (u : ℕ) : 0 < length u := by
  exact Nat.mul_pos (by norm_num) (pow_pos (by norm_num) u)

theorem degreeBound_pos (u : ℕ) : 0 < degreeBound u := by
  exact Nat.mul_pos (by norm_num) (pow_pos (by norm_num) u)

theorem degreeBound_le_length (u : ℕ) : degreeBound u ≤ length u := by
  exact Nat.mul_le_mul_right (2 ^ u) (by norm_num)

/-- Every selected length is a power of two. -/
theorem length_eq_two_pow (u : ℕ) : length u = 2 ^ (u + 8) := by
  simp [length, pow_add]
  ring

/-- Every selected dimension bound is a power of two. -/
theorem degreeBound_eq_two_pow (u : ℕ) : degreeBound u = 2 ^ (u + 6) := by
  simp [degreeBound, pow_add]
  ring

/-- Doubling the extension degree squares its field cardinality. -/
theorem fieldCard_succ (u : ℕ) : fieldCard (u + 1) = fieldCard u ^ 2 := by
  simp only [fieldCard, length_succ, mul_comm 2 (length u), pow_mul]

/-- The subgroup-order divisibility holds for every member of the family. -/
theorem length_dvd_fieldCard_sub_one : ∀ u : ℕ, length u ∣ fieldCard u - 1
  | 0 => base_length_dvd_fieldCard_sub_one
  | u + 1 => by
      have ih := length_dvd_fieldCard_sub_one u
      have htwo : 2 ∣ fieldCard u + 1 := by
        exact ((show Odd (3 : ℕ) by norm_num).pow).add_one.two_dvd
      rw [length_succ, fieldCard_succ]
      have hfactor : fieldCard u ^ 2 - 1 =
          (fieldCard u + 1) * (fieldCard u - 1) := by
        simpa using Nat.pow_two_sub_pow_two (fieldCard u) 1
      rw [hfactor]
      exact Nat.mul_dvd_mul htwo ih

instance prime_three_fact : Fact (Nat.Prime 3) := ⟨Nat.prime_three⟩

/-- The actual finite field of cardinality `3 ^ length u`. -/
abbrev RSField (u : ℕ) := GaloisField 3 (length u)

instance fieldFintype (u : ℕ) : Fintype (RSField u) := Fintype.ofFinite _

instance fieldDecidableEq (u : ℕ) : DecidableEq (RSField u) := Classical.decEq _

@[simp]
theorem card_RSField (u : ℕ) : Fintype.card (RSField u) = fieldCard u := by
  rw [← Nat.card_eq_fintype_card]
  exact GaloisField.card 3 (length u) (Nat.ne_of_gt (length_pos u))

/-- A generator of the finite field's full multiplicative group. -/
def generator (u : ℕ) : (RSField u)ˣ :=
  Classical.choose (IsCyclic.exists_ofOrder_eq_natCard (α := (RSField u)ˣ))

theorem generator_order (u : ℕ) : orderOf (generator u) = fieldCard u - 1 := by
  have h := Classical.choose_spec
    (IsCyclic.exists_ofOrder_eq_natCard (α := (RSField u)ˣ))
  simpa only [generator, Nat.card_eq_fintype_card, Fintype.card_units,
    card_RSField] using h

/-- Descend the full generator to the required subgroup order. -/
def rootUnit (u : ℕ) : (RSField u)ˣ :=
  generator u ^ ((fieldCard u - 1) / length u)

theorem rootUnit_order (u : ℕ) : orderOf (rootUnit u) = length u := by
  have hdiv : length u ∣ orderOf (generator u) := by
    rw [generator_order]
    exact length_dvd_fieldCard_sub_one u
  have hne : orderOf (generator u) ≠ 0 := by
    exact Nat.ne_of_gt (orderOf_pos (generator u))
  simpa only [rootUnit, generator_order] using
    (orderOf_pow_orderOf_div hne hdiv)

/-- The multiplicative subgroup used by the paper. -/
def evaluationSubgroup (u : ℕ) : Subgroup (RSField u)ˣ :=
  Subgroup.zpowers (rootUnit u)

theorem card_evaluationSubgroup (u : ℕ) :
    Nat.card (evaluationSubgroup u) = length u := by
  rw [evaluationSubgroup, Nat.card_zpowers, rootUnit_order]

/-- The indexed unit powers exhaust exactly the selected multiplicative subgroup. -/
theorem mem_evaluationSubgroup_iff (u : ℕ) (x : (RSField u)ˣ) :
    x ∈ evaluationSubgroup u ↔
      ∃ i : Fin (length u), rootUnit u ^ (i : ℕ) = x := by
  classical
  rw [evaluationSubgroup, mem_zpowers_iff_mem_range_orderOf, rootUnit_order]
  simp only [Finset.mem_image, Finset.mem_range]
  constructor
  · rintro ⟨i, hi, rfl⟩
    exact ⟨⟨i, hi⟩, rfl⟩
  · rintro ⟨i, hi⟩
    exact ⟨i, i.isLt, hi⟩

/-- The indexed evaluation points enumerate powers of the order-`length u` root. -/
def point (u : ℕ) (i : Fin (length u)) : RSField u :=
  (rootUnit u ^ (i : ℕ) : RSField u)

theorem injective_point (u : ℕ) : Function.Injective (point u) := by
  intro i j hij
  have hij_units : rootUnit u ^ (i : ℕ) = rootUnit u ^ (j : ℕ) := by
    ext
    exact hij
  have hmod : (i : ℕ) ≡ (j : ℕ) [MOD length u] := by
    have hmod_order := (pow_eq_pow_iff_modEq).mp hij_units
    simpa only [rootUnit_order] using hmod_order
  apply Fin.ext
  unfold Nat.ModEq at hmod
  simpa only [Nat.mod_eq_of_lt i.isLt, Nat.mod_eq_of_lt j.isLt] using hmod

/-- The constructed injective power domain. -/
def evaluationDomain (u : ℕ) :
    ReedSolomon.EvaluationDomain (RSField u) (Fin (length u)) where
  point := point u
  injective_point := injective_point u

/-- The actual smooth-domain object, with a proved power-of-two length and root order. -/
def smoothEvaluationDomain (u : ℕ) :
    ReedSolomon.SmoothEvaluationDomain (RSField u) (Fin (length u)) where
  toEvaluationDomain := evaluationDomain u
  smooth := length u = 2 ^ (u + 8) ∧ orderOf (rootUnit u) = length u

theorem smoothEvaluationDomain_smooth (u : ℕ) :
    (smoothEvaluationDomain u).smooth :=
  ⟨length_eq_two_pow u, rootUnit_order u⟩

/-- The selected Reed--Solomon family, with no realization hypothesis. -/
def parameters (u : ℕ) : ReedSolomon.Parameters (RSField u) (Fin (length u)) where
  domain := evaluationDomain u
  degreeBound := degreeBound u

@[simp]
theorem parameters_degreeBound (u : ℕ) :
    (parameters u).degreeBound = degreeBound u := rfl

@[simp]
theorem parameters_length (u : ℕ) : (parameters u).length = length u := by
  simp [ReedSolomon.Parameters.length]

/-- The instantiated family meets the capacity-grid fractional list target. -/
theorem realized_fractionalListSizeBoundAt_capacity
    (u : ℕ) (σ : Type*) [Fintype σ] [DecidableEq σ] (j₀ : σ) :
    CapacityList.FractionalListSizeBoundAt
      ((parameters u).vectorBlockCode σ)
      (BlockCode.relativeRadius (ι := Fin (length u))
        (length u - degreeBound u))
      ((1 : ℝ) / 2 ^ 128) (fieldCard u) := by
  have hDegree : 0 < (parameters u).degreeBound := degreeBound_pos u
  have hLength : 0 < Fintype.card (Fin (length u)) := by
    simpa using length_pos u
  have hk : (parameters u).degreeBound ≤ Fintype.card (Fin (length u)) := by
    simpa using degreeBound_le_length u
  have hbudget : (Nat.choose (length u) (degreeBound u) : ℝ) ≤
      ((1 : ℝ) / 2 ^ 128) * fieldCard u := by
    have hcast : (2 : ℝ) ^ 128 *
        (Nat.choose (length u) (degreeBound u) : ℝ) ≤ fieldCard u := by
      exact_mod_cast choose_target u
    have hpow : (0 : ℝ) < 2 ^ 128 := by positivity
    rw [show ((1 : ℝ) / 2 ^ 128) * fieldCard u =
      (fieldCard u : ℝ) / 2 ^ 128 by ring]
    exact (le_div_iff₀ hpow).2 (by simpa [mul_comm] using hcast)
  have h := ((parameters u).vectorFractionalListSizeBoundAt_capacityGrid_iff
    j₀ ((1 : ℝ) / 2 ^ 128) hDegree hLength hk).2 (by simpa using hbudget)
  simpa only [Fintype.card_fin, parameters_degreeBound, card_RSField] using h

/-- The instantiated family meets the all-radius pair-MCA error target. -/
theorem realized_pairMCAErrorBoundAt (u : ℕ) (δ : ℝ) :
    (parameters u).PairMCAErrorBoundAt δ ((1 : ℝ) / 2 ^ 128) := by
  exact pairMCAErrorBoundAt u (parameters u) (Fintype.card_fin _)
    (card_RSField u) (parameters_degreeBound u) δ

/-- The constructed family has full-length greatest safe count radius. -/
theorem realized_pairMCAGreatestSafe_eq_length (u : ℕ) :
    (parameters u).toBlockCode.pairMCAGreatestSafe 128 = (length u : WithBot ℕ) := by
  exact pairMCAGreatestSafe_eq_length u (parameters u) (Fintype.card_fin _)
    (card_RSField u) (parameters_degreeBound u)

end
end Capacity.SmoothQuarterFamily
end ProximityCoding
