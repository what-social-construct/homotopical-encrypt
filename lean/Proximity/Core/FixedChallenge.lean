module

public import Proximity.Core.DeepHole

@[expose] public section

/-!
# A fixed challenge can collapse genuinely far Reed--Solomon pairs

For any nonzero fixed challenge, both columns can be nonzero multiples of
the actual degree-`k` deep hole while their selected affine combination is
zero. Both native source-coordinate and whole-pair distances remain exactly
the capacity radius. A global compression theorem therefore needs a genuine
challenge contract; the fixed mix alone supplies no positive far guarantee.
-/

set_option autoImplicit false

noncomputable section

namespace ProximityCoding.ReedSolomon.Parameters

open BlockCode

variable {F ι : Type*} [Field F] [Fintype F] [DecidableEq F]
  [Fintype ι] [DecidableEq ι]

def rankOnePowerLine (P : Parameters F ι) (a b : F) : AffineLine ι F where
  base := P.scaledPowerWord a
  direction := P.scaledPowerWord b

def rankOnePowerPair (P : Parameters F ι) (a b : F) : Word ι (Fin 2 → F) :=
  pairWord (P.rankOnePowerLine a b)

@[simp]
theorem rankOnePowerPair_zero (P : Parameters F ι) (a b : F) (i : ι) :
    P.rankOnePowerPair a b i 0 = P.scaledPowerWord a i := rfl

@[simp]
theorem rankOnePowerPair_one (P : Parameters F ι) (a b : F) (i : ι) :
    P.rankOnePowerPair a b i 1 = P.scaledPowerWord b i := rfl

private theorem column_hamming_le_pair
    (u v : Word ι (Fin 2 → F)) (j : Fin 2) :
    hammingDistance (fun i => u i j) (fun i => v i j) ≤ hammingDistance u v := by
  classical
  apply Finset.card_le_card
  intro i hi
  have hne := (Finset.mem_filter.mp hi).2
  apply Finset.mem_filter.mpr
  refine ⟨Finset.mem_univ _, ?_⟩
  intro heq
  exact hne (congrFun heq j)

theorem rankOnePowerPair_hammingDistanceToCode_eq_capacity
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) (a b : F) (ha : a ≠ 0) :
    (P.vectorBlockCode (Fin 2)).hammingDistanceToCode (P.rankOnePowerPair a b) =
      Fintype.card ι - P.degreeBound := by
  have hC := interleavedPair_nonempty P.toBlockCode (P.code_nonempty hDegree)
  apply le_antisymm
  · exact ((P.vectorBlockCode (Fin 2)).close_iff_hammingDistanceToCode_le hC _ _).mp
      (P.vector_close_capacity hDegree hk (Fin 2) (P.rankOnePowerPair a b))
  · obtain ⟨c, hc, hnearest⟩ := (P.vectorBlockCode (Fin 2)).exists_nearest_codeword
      hC (P.rankOnePowerPair a b)
    have hscalar := P.scaledPowerWord_hamming_ge_capacity a ha (fun i => c i 0) (hc 0)
    have hcol := column_hamming_le_pair c (P.rankOnePowerPair a b) 0
    change hammingDistance (fun i => c i 0) (P.scaledPowerWord a) ≤ _ at hcol
    rw [hnearest]
    exact hscalar.trans hcol

theorem rankOnePowerPair_relativeDistanceToCode_eq_capacity
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) (a b : F) (ha : a ≠ 0) :
    (P.vectorBlockCode (Fin 2)).relativeDistanceToCode (P.rankOnePowerPair a b) =
      relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound) := by
  unfold relativeDistanceToCode relativeRadius
  rw [P.rankOnePowerPair_hammingDistanceToCode_eq_capacity hDegree hk a b ha]

theorem flat_rankOnePowerPair_hammingDistanceToCode_eq_twice_capacity
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) (a b : F) (ha : a ≠ 0) (hb : b ≠ 0) :
    (flattenedPairCode P.toBlockCode).hammingDistanceToCode
        (flattenPair (P.rankOnePowerPair a b)) =
      2 * (Fintype.card ι - P.degreeBound) := by
  apply le_antisymm
  · obtain ⟨c₀, hc₀, hnearest₀⟩ := P.toBlockCode.exists_nearest_codeword
      (P.code_nonempty hDegree) (P.scaledPowerWord a)
    obtain ⟨c₁, hc₁, hnearest₁⟩ := P.toBlockCode.exists_nearest_codeword
      (P.code_nonempty hDegree) (P.scaledPowerWord b)
    have hdist₀ : hammingDistance c₀ (P.scaledPowerWord a) =
        Fintype.card ι - P.degreeBound := by
      rw [← hnearest₀, P.scaledPowerWord_hammingDistanceToCode_eq_capacity hDegree hk a ha]
    have hdist₁ : hammingDistance c₁ (P.scaledPowerWord b) =
        Fintype.card ι - P.degreeBound := by
      rw [← hnearest₁, P.scaledPowerWord_hammingDistanceToCode_eq_capacity hDegree hk b hb]
    let L : AffineLine ι F := ⟨c₀, c₁⟩
    have hcode : (flattenedPairCode P.toBlockCode).Codeword (flattenPair (pairWord L)) := by
      intro j
      fin_cases j
      · change P.Codeword c₀
        exact hc₀
      · change P.Codeword c₁
        exact hc₁
    calc
      _ ≤ hammingDistance (flattenPair (pairWord L))
          (flattenPair (P.rankOnePowerPair a b)) :=
        (flattenedPairCode P.toBlockCode).hammingDistanceToCode_le_of_codeword hcode
      _ = 2 * (Fintype.card ι - P.degreeBound) := by
        rw [flat_hamming_eq_column_sum]
        change hammingDistance c₀ (P.scaledPowerWord a) +
          hammingDistance c₁ (P.scaledPowerWord b) = _
        rw [hdist₀, hdist₁]
        omega
  · obtain ⟨c, hc, hnearest⟩ := (flattenedPairCode P.toBlockCode).exists_nearest_codeword
      (flattenedPairCode_nonempty P.toBlockCode (P.code_nonempty hDegree))
        (flattenPair (P.rankOnePowerPair a b))
    have hzero := P.scaledPowerWord_hamming_ge_capacity a ha (fun i => c (i, 0)) (hc 0)
    have hone := P.scaledPowerWord_hamming_ge_capacity b hb (fun i => c (i, 1)) (hc 1)
    have hsum := flat_hamming_eq_column_sum (unflattenPair c) (P.rankOnePowerPair a b)
    simp only [flattenPair_unflattenPair] at hsum
    change hammingDistance c (flattenPair (P.rankOnePowerPair a b)) =
      hammingDistance (fun i => c (i, 0)) (P.scaledPowerWord a) +
        hammingDistance (fun i => c (i, 1)) (P.scaledPowerWord b) at hsum
    rw [hnearest, hsum]
    omega

theorem flat_rankOnePowerPair_relativeDistanceToCode_eq_capacity
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) (a b : F) (ha : a ≠ 0) (hb : b ≠ 0) :
    (flattenedPairCode P.toBlockCode).relativeDistanceToCode
        (flattenPair (P.rankOnePowerPair a b)) =
      relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound) := by
  have hn : (0 : ℝ) < Fintype.card ι := by exact_mod_cast hDegree.trans_le hk
  unfold relativeDistanceToCode relativeRadius
  rw [P.flat_rankOnePowerPair_hammingDistanceToCode_eq_twice_capacity hDegree hk a b ha hb]
  simp only [Fintype.card_prod, Fintype.card_fin, Nat.cast_mul, Nat.cast_ofNat]
  field_simp [hn.ne']

/-- The actual affine-line input chosen against a nonzero fixed challenge. -/
def fixedCancellingLine (P : Parameters F ι) (γ₀ : F) : AffineLine ι F :=
  P.rankOnePowerLine 1 (-γ₀⁻¹)

theorem fixedCancellingLine_point (P : Parameters F ι) (γ₀ : F) (hγ : γ₀ ≠ 0) :
    (P.fixedCancellingLine γ₀).point γ₀ = 0 := by
  have hcoef : γ₀ * (-γ₀⁻¹) = -1 := by
    rw [mul_neg, mul_inv_cancel₀ hγ]
  funext i
  change (1 : F) * P.domain.point i ^ P.degreeBound +
    γ₀ * ((-γ₀⁻¹) * P.domain.point i ^ P.degreeBound) = 0
  rw [← mul_assoc, hcoef]
  ring

theorem fixedCancellingLine_pairDistance_eq_capacity
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) (γ₀ : F) :
    (P.vectorBlockCode (Fin 2)).relativeDistanceToCode
        (pairWord (P.fixedCancellingLine γ₀)) =
      relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound) :=
  P.rankOnePowerPair_relativeDistanceToCode_eq_capacity hDegree hk 1 (-γ₀⁻¹) one_ne_zero

theorem fixedCancellingLine_flatDistance_eq_capacity
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) (γ₀ : F) (hγ : γ₀ ≠ 0) :
    (flattenedPairCode P.toBlockCode).relativeDistanceToCode
        (flattenPair (pairWord (P.fixedCancellingLine γ₀))) =
      relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound) :=
  P.flat_rankOnePowerPair_relativeDistanceToCode_eq_capacity hDegree hk
    1 (-γ₀⁻¹) one_ne_zero (neg_ne_zero.mpr (inv_ne_zero hγ))

theorem fixedCancellingLine_scalarDistance_eq_zero
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound) (γ₀ : F) (hγ : γ₀ ≠ 0) :
    P.toBlockCode.relativeDistanceToCode ((P.fixedCancellingLine γ₀).point γ₀) = 0 := by
  rw [P.fixedCancellingLine_point γ₀ hγ]
  exact P.toBlockCode.relativeDistanceToCode_eq_zero_of_codeword
    (P.fAdditive_of_degreeBound_pos hDegree).zero_mem

/-- Even capacity-far whole pairs need not remain positively far at an
arbitrary fixed nonzero challenge. -/
theorem no_fixedChallenge_pair_far_preservation
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) (γ₀ : F) (hγ : γ₀ ≠ 0)
    (sourceRadius targetRadius : ℝ)
    (hsource : sourceRadius ≤ relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound))
    (htarget : 0 < targetRadius) :
    ¬ (∀ L : AffineLine ι F,
      sourceRadius ≤ (P.vectorBlockCode (Fin 2)).relativeDistanceToCode (pairWord L) →
      targetRadius ≤ P.toBlockCode.relativeDistanceToCode (L.point γ₀)) := by
  intro h
  have hfar : sourceRadius ≤ (P.vectorBlockCode (Fin 2)).relativeDistanceToCode
      (pairWord (P.fixedCancellingLine γ₀)) := by
    rw [P.fixedCancellingLine_pairDistance_eq_capacity hDegree hk]
    exact hsource
  have hcollapsed := h (P.fixedCancellingLine γ₀) hfar
  rw [P.fixedCancellingLine_scalarDistance_eq_zero hDegree γ₀ hγ] at hcollapsed
  exact (not_le_of_gt htarget) hcollapsed

/-- The same counterexample is capacity-far in native scalar-coordinate
distance before pairing. -/
theorem no_fixedChallenge_flat_far_preservation
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) (γ₀ : F) (hγ : γ₀ ≠ 0)
    (sourceRadius targetRadius : ℝ)
    (hsource : sourceRadius ≤ relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound))
    (htarget : 0 < targetRadius) :
    ¬ (∀ L : AffineLine ι F,
      sourceRadius ≤ (flattenedPairCode P.toBlockCode).relativeDistanceToCode
        (flattenPair (pairWord L)) →
      targetRadius ≤ P.toBlockCode.relativeDistanceToCode (L.point γ₀)) := by
  intro h
  have hfar : sourceRadius ≤ (flattenedPairCode P.toBlockCode).relativeDistanceToCode
      (flattenPair (pairWord (P.fixedCancellingLine γ₀))) := by
    rw [P.fixedCancellingLine_flatDistance_eq_capacity hDegree hk γ₀ hγ]
    exact hsource
  have hcollapsed := h (P.fixedCancellingLine γ₀) hfar
  rw [P.fixedCancellingLine_scalarDistance_eq_zero hDegree γ₀ hγ] at hcollapsed
  exact (not_le_of_gt htarget) hcollapsed

end ProximityCoding.ReedSolomon.Parameters
