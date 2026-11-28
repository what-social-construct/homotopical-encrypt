module

public import Proximity.Capacity.SubfieldThresholdArithmetic
public import Proximity.MCA.LocalObstructions
public import Proximity.MCA.PoleWitness
public import Proximity.MCA.PrefixFamily
public import Proximity.MCA.RealThreshold

@[expose] public section

/-! # Exact 128-bit MCA crossing for the smooth length-128 subgroup -/

namespace ProximityCoding.Capacity.SubfieldThreshold

open BlockCode

private theorem countBound_of_arithmetic {F ι : Type*} [Field F] [Fintype F] [Fintype ι]
    (P : ReedSolomon.Parameters F ι) {n k r B circuitSize localSize : ℕ}
    (length : Fintype.card ι = n) (dimension : P.degreeBound = k)
    (circuit : k + 1 = circuitSize) (localCount : n - r - 1 = localSize)
    (positive : 0 < k) (room : k < n - r)
    (arithmetic : n.choose circuitSize / localSize.choose k ≤ B) :
    P.toBlockCode.PairMCACountBound r B := by
  classical
  subst n
  subst k
  subst circuitSize
  subst localSize
  intro L
  exact (P.badChallengeSet_card_le_choose_div positive r room L).trans arithmetic

theorem pairMCA_countBound_sixtyone : parameters.toBlockCode.PairMCACountBound 61 budget :=
  countBound_of_arithmetic parameters (r := 61) (Fintype.card_fin 128)
    (show parameters.degreeBound = 64 from rfl)
    (by decide) (by decide) (by decide) (by decide) mca_circuit_le_budget

theorem pairMCA_secure_128_sixtyone : parameters.toBlockCode.PairMCASecureAtBits 128 61 := by
  apply parameters.toBlockCode.pairMCASecureAtBits_of_countBound pairMCA_countBound_sixtyone
  rw [card_RSField]
  simpa only [budget, Nat.mul_comm] using Nat.div_mul_le_self fieldCard (2 ^ 128)

private theorem mul_lt_of_lt_ceil (b count : ℕ) (fibre : b < (count + 640) / 641) :
    641 * b < count := by
  have next := (Nat.le_div_iff_mul_le (by decide : 0 < 641)).mp (Nat.succ_le_of_lt fibre)
  omega

private theorem exists_line_of_fibre (t : ℕ)
    (fibre : 641 * (t - 1) < (128 : ℕ).choose 66)
    (poles : 128 + 64 * t.choose 2 < fieldCard) :
    ∃ L : AffineLine (Fin 128) RSField, t ≤ (parameters.toBlockCode.badChallengeSet 62 L).card := by
  classical
  have enough : Fintype.card BaseField * (t - 1) < (Fintype.card (Fin 128)).choose 66 := by
    rwa [ZMod.card, Fintype.card_fin]
  obtain ⟨received, polys, sets, distinct, witnesses⟩ := parameters.exists_prefixFamily
    (fun i => (↑(rootUnit ^ (i : ℕ)) : BaseField)) (fun _ => rfl) (a := 66) (t := t)
    (by decide) enough
  have degree (a : Fin t) : (polys a).natDegree ≤ parameters.degreeBound :=
    (witnesses a).2.1
  have large (a : Fin t) : LargeAgreementSet 62 (sets a) := by
    simp [LargeAgreementSet, (witnesses a).1]
  have more (a : Fin t) : parameters.degreeBound < (sets a).card := by
    rw [(witnesses a).1]
    decide
  have few : Fintype.card (Fin 128) + parameters.degreeBound *
      (Fintype.card (Fin t)).choose 2 < Fintype.card RSField := by
    simpa only [Fintype.card_fin, card_RSField, parameters] using poles
  simpa only [Fintype.card_fin] using parameters.exists_badChallengeSet_card_ge_of_pole_family
    (by decide) 62 received polys distinct degree sets large more (fun a => (witnesses a).2.2) few

/-- The prefix fibre in the base field transfers to one over-budget line. -/
theorem exists_over_budget_line_sixtytwo :
    ∃ L : AffineLine (Fin 128) RSField,
      budget + 1 ≤ (parameters.toBlockCode.badChallengeSet 62 L).card := by
  apply exists_line_of_fibre _ _ pole_root_budget
  rw [Nat.add_sub_cancel]
  exact mul_lt_of_lt_ceil budget _ budget_lt_mca_fibre

theorem not_pairMCA_secure_128_sixtytwo : ¬ parameters.toBlockCode.PairMCASecureAtBits 128 62 := by
  obtain ⟨L, lower⟩ := exists_over_budget_line_sixtytwo
  intro safe
  have upper := parameters.toBlockCode.scaled_badChallengeSet_card_le_of_pairMCASecureAtBits safe L
  have exceeds := (Nat.mul_le_mul_left (2 ^ 128) lower).trans upper
  rw [card_RSField, Nat.mul_comm] at exceeds
  have impossible := (Nat.le_div_iff_mul_le (by decide : 0 < (2 : ℕ) ^ 128)).mpr exceeds
  exact (Nat.not_succ_le_self budget) impossible

/-- Exact adjacent grid counts on the prescribed smooth domain. -/
theorem pairMCA_exact_128_bit_threshold :
    parameters.toBlockCode.pairMCAGreatestSafe 128 = (61 : WithBot ℕ) ∧
      parameters.toBlockCode.pairMCAFirstUnsafe 128 = (62 : WithTop ℕ) :=
  parameters.toBlockCode.pairMCAThreshold_eq_of_safe_next_unsafe
    (by simp) pairMCA_secure_128_sixtyone not_pairMCA_secure_128_sixtytwo

/-- Real safe radii form the half-open interval ending at `62 / 128`. -/
theorem pairMCA_safeRelativeRadii_128_eq_Ico :
    parameters.toBlockCode.pairMCASafeRelativeRadii 128 = Set.Ico 0 ((62 : ℝ) / 128) := by
  simpa only [relativeRadius, Fintype.card_fin, show (61 : ℕ) + 1 = 62 by decide,
    Nat.cast_ofNat] using
    parameters.toBlockCode.pairMCASafeRelativeRadii_eq_Ico_of_safe_next_unsafe
      (by simp) pairMCA_secure_128_sixtyone not_pairMCA_secure_128_sixtytwo

end ProximityCoding.Capacity.SubfieldThreshold
