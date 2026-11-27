module

public import Proximity.Core.Distance
public import Proximity.ListDecoding.PhaseSplit

@[expose] public section

/-!
# Exact list radius when the budget is one codeword

Below half the minimum distance, a received word has at most one nearby
codeword. Splitting the disagreement sites of two codewords at minimum
distance provides a center whose list contains both at the next radius.
-/

set_option autoImplicit false

namespace ProximityCoding.ReedSolomon.Parameters

open BlockCode CapacityList

private theorem exists_center_of_hammingDistance_le_twice
    {ι α : Type*} [Fintype ι] [DecidableEq α] {u v : Word ι α} {r : ℕ}
    (hDistance : hammingDistance u v ≤ 2 * r) :
    ∃ w, hammingDistance u w ≤ r ∧ hammingDistance v w ≤ r := by
  classical
  let disagreements := Finset.univ.filter fun i => u i ≠ v i
  obtain ⟨part, subset, count⟩ :=
    Finset.exists_subset_card_eq (min_le_right r disagreements.card)
  let w : Word ι α := fun i => if i ∈ part then u i else v i
  have left : (Finset.univ.filter fun i => u i ≠ w i) = disagreements \ part := by
    ext i
    by_cases member : i ∈ part <;> simp [disagreements, w, member]
  have right : (Finset.univ.filter fun i => v i ≠ w i) = part := by
    ext i
    by_cases member : i ∈ part
    · have unequal := (Finset.mem_filter.mp (subset member)).2
      simp [w, member, Ne.symm unequal]
    · simp [w, member]
  change disagreements.card ≤ 2 * r at hDistance
  refine ⟨w, ?_, ?_⟩
  · rw [hammingDistance, left, Finset.card_sdiff_of_subset subset, count]
    omega
  · rw [hammingDistance, right, count]
    exact min_le_left _ _

variable {F ι : Type*} [Field F] [Fintype F] [DecidableEq F] [Fintype ι]

/-- Every positive-width interleaved RS ball has at most one codeword
exactly when twice the count radius is below the code's minimum distance. -/
theorem vectorListSizeBound_one_iff
    (P : Parameters F ι) {σ : Type*} [Fintype σ] [Nonempty σ]
    (hDegree : 0 < P.degreeBound) (hLe : P.degreeBound ≤ Fintype.card ι) (r : ℕ) :
    (P.vectorBlockCode σ).ListSizeBound r 1 ↔
      2 * r < Fintype.card ι - P.degreeBound + 1 := by
  classical
  let C := P.vectorBlockCode σ
  have determined : DeterminedBy C P.degreeBound := P.vectorDeterminedBy_degreeBound σ
  constructor
  · intro bounded
    by_contra notBelow
    have hsubset : P.degreeBound - 1 ≤ (Finset.univ : Finset ι).card := by
      simpa using (Nat.sub_le P.degreeBound 1).trans hLe
    obtain ⟨sites, _, count⟩ := Finset.exists_subset_card_eq hsubset
    let u : VectorWord ι F σ := P.nextShellWord sites (fun _ => 1)
    let v : VectorWord ι F σ := 0
    have hu := P.nextShellWord_mem_ball (σ := σ) hDegree hLe count (fun _ => 1)
    have hv : C.Codeword v := by
      exact fun _ => (P.fAdditive_of_degreeBound_pos hDegree).zero_mem
    have distinct : u ≠ v := by
      intro same
      have zeroWord : P.nextShellWord (σ := σ) sites (fun _ => 0) = v := by
        funext i j
        simp [nextShellWord, v]
      have coefficients := P.nextShellWord_injective (σ := σ) hDegree hLe count
        (same.trans zeroWord.symm)
      obtain ⟨j⟩ := ‹Nonempty σ›
      exact one_ne_zero (congrFun coefficients j)
    have distance : hammingDistance u v ≤ 2 * r :=
      hu.2.trans (le_of_not_gt notBelow)
    obtain ⟨w, left, right⟩ := exists_center_of_hammingDistance_le_twice distance
    have subsingleton : Subsingleton {c : VectorWord ι F σ // c ∈ C.Ball r w} :=
      Finite.card_le_one_iff_subsingleton.mp (bounded w)
    exact distinct (congrArg Subtype.val
      (subsingleton.elim ⟨u, hu.1, left⟩ ⟨v, hv, right⟩))
  · intro below w
    refine Finite.card_le_one_iff_subsingleton.mpr ⟨?_⟩
    intro c d
    apply Subtype.ext
    rcases le_total (hammingDistance c.1 w) (hammingDistance d.1 w) with hd | hc
    · have twice : 2 * hammingDistance d.1 w < Fintype.card ι - P.degreeBound + 1 := by
        have bound := d.2.2
        omega
      exact (C.hammingDistanceToCode_eq_and_unique_of_twice_lt
        determined hLe d.2.1 twice).2 c.2.1 hd
    · have twice : 2 * hammingDistance c.1 w < Fintype.card ι - P.degreeBound + 1 := by
        have bound := c.2.2
        omega
      exact ((C.hammingDistanceToCode_eq_and_unique_of_twice_lt
        determined hLe c.2.1 twice).2 d.2.1 hc).symm

/-- A fractional budget in `[1, 2)` has the exact unique-decoding threshold. -/
theorem vectorFractionalListSizeBoundAt_relativeRadius_iff_of_budget_one_two
    (P : Parameters F ι) {σ : Type*} [Fintype σ] [Nonempty σ]
    (hDegree : 0 < P.degreeBound) (hLe : P.degreeBound ≤ Fintype.card ι) (r : ℕ)
    {ε : ℝ} (one_le : 1 ≤ ε * (Fintype.card F : ℝ))
    (lt_two : ε * (Fintype.card F : ℝ) < 2) :
    FractionalListSizeBoundAt (P.vectorBlockCode σ) (relativeRadius (ι := ι) r)
      ε (Fintype.card F) ↔ 2 * r < Fintype.card ι - P.degreeBound + 1 := by
  classical
  have hLength : 0 < Fintype.card ι := hDegree.trans_le hLe
  rw [← P.vectorListSizeBound_one_iff (σ := σ) hDegree hLe r]
  constructor
  · intro bounded w
    have bound := bounded w
    rw [(P.vectorBlockCode σ).ballCardAt_relativeRadius_eq_ballCard hLength w] at bound
    have ltTwo : ((P.vectorBlockCode σ).ballCard r w : ℝ) < 2 :=
      bound.trans_lt lt_two
    exact Nat.lt_succ_iff.mp (by exact_mod_cast ltTwo)
  · intro bounded w
    rw [(P.vectorBlockCode σ).ballCardAt_relativeRadius_eq_ballCard hLength w]
    have bound : ((P.vectorBlockCode σ).ballCard r w : ℝ) ≤ 1 := by
      exact_mod_cast bounded w
    exact bound.trans one_le

/-- The real safe interval ends at the first count radius with a two-codeword
list, excluding that endpoint. -/
theorem vectorFractionalListSafeRelativeRadii_eq_Ico_of_budget_one_two
    (P : Parameters F ι) {σ : Type*} [Fintype σ] [Nonempty σ]
    (hDegree : 0 < P.degreeBound) (hLe : P.degreeBound ≤ Fintype.card ι)
    {ε : ℝ} (one_le : 1 ≤ ε * (Fintype.card F : ℝ))
    (lt_two : ε * (Fintype.card F : ℝ) < 2) :
    safeRelativeRadii (P.vectorBlockCode σ) ε (Fintype.card F) =
      Set.Ico 0 (relativeRadius (ι := ι) ((Fintype.card ι - P.degreeBound) / 2 + 1)) := by
  classical
  let C := P.vectorBlockCode σ
  let lastSafe := (Fintype.card ι - P.degreeBound) / 2
  have hLength : 0 < Fintype.card ι := hDegree.trans_le hLe
  have safe : FractionalListSizeBoundAt C (relativeRadius (ι := ι) lastSafe)
      ε (Fintype.card F) :=
    (P.vectorFractionalListSizeBoundAt_relativeRadius_iff_of_budget_one_two
      (σ := σ) hDegree hLe lastSafe one_le lt_two).mpr (by
        dsimp [lastSafe]
        omega)
  have notSafe : ¬ FractionalListSizeBoundAt C
      (relativeRadius (ι := ι) (lastSafe + 1)) ε (Fintype.card F) := by
    rw [P.vectorFractionalListSizeBoundAt_relativeRadius_iff_of_budget_one_two
      (σ := σ) hDegree hLe (lastSafe + 1) one_le lt_two]
    dsimp [lastSafe]
    omega
  ext δ
  constructor
  · rintro ⟨hδ, bound⟩
    refine ⟨hδ, ?_⟩
    by_contra atOrAbove
    exact notSafe (fractionalListSizeBoundAt_antitone C ε _ (le_of_not_gt atOrAbove) bound)
  · rintro ⟨hδ, below⟩
    refine ⟨hδ, fun w => ?_⟩
    have bound := safe w
    rw [C.ballCardAt_relativeRadius_eq_ballCard hLength w] at bound
    calc
      (C.ballCardAt δ w : ℝ) ≤ C.ballCard lastSafe w := by
        exact_mod_cast C.ballCardAt_le_ballCard_of_lt_succ hLength below w
      _ ≤ ε * Fintype.card F := bound

end ProximityCoding.ReedSolomon.Parameters
