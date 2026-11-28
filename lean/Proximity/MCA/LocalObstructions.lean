module

public import Proximity.MCA.Pair

@[expose] public section

/-!
# Local obstruction multiplicity for pair MCA

A failed pair-agreement test on `s` sites contains at least `choose (s - 1) k`
failed tests of size `k + 1`. Scalar agreement persists upon restriction, so
these tests can all be charged to the original bad challenge.
-/

set_option autoImplicit false

namespace ProximityCoding.ReedSolomon.Parameters

open BlockCode
open scoped BigOperators

private theorem sum_card_filter_powersetCard_erase {ι : Type*} [DecidableEq ι]
    (S : Finset ι) (m : ℕ) (fails : Finset ι → Prop) [DecidablePred fails] :
    (∑ i ∈ S, (((S.erase i).powersetCard m).filter fails).card) =
      ((S.powersetCard m).filter fails).card * (S.card - m) := by
  let obstructions := (S.powersetCard m).filter fails
  have restrict (i : ι) : ((S.erase i).powersetCard m).filter fails =
      obstructions.filter (fun T => i ∉ T) := by
    ext T
    simp only [obstructions, Finset.mem_filter, Finset.mem_powersetCard]
    constructor
    · rintro ⟨⟨hT, hm⟩, hfail⟩
      exact ⟨⟨⟨hT.trans (Finset.erase_subset _ _), hm⟩, hfail⟩,
        fun hi => (Finset.mem_erase.mp (hT hi)).1 rfl⟩
    · rintro ⟨⟨⟨hT, hm⟩, hfail⟩, hni⟩
      exact ⟨⟨fun j hj => Finset.mem_erase.mpr ⟨fun h => hni (h ▸ hj), hT hj⟩, hm⟩, hfail⟩
  calc
    (∑ i ∈ S, (((S.erase i).powersetCard m).filter fails).card) =
        ∑ i ∈ S, ∑ T ∈ obstructions, if i ∉ T then 1 else 0 := by
      simp only [restrict, Finset.card_eq_sum_ones, Finset.sum_filter]
    _ = ∑ T ∈ obstructions, ∑ i ∈ S, if i ∉ T then 1 else 0 := Finset.sum_comm
    _ = ∑ _T ∈ obstructions, (S.card - m) := by
      apply Finset.sum_congr rfl
      intro T hT
      obtain ⟨hsub, hcard⟩ := Finset.mem_powersetCard.mp (Finset.mem_filter.mp hT).1
      rw [← Finset.sum_filter, ← Finset.card_eq_sum_ones, Finset.filter_notMem_eq_sdiff,
        Finset.card_sdiff_of_subset hsub, hcard]
    _ = obstructions.card * (S.card - m) := by simp

variable {F ι : Type*} [Field F] [Fintype ι] [DecidableEq ι]

/-- The local tests of size `k + 1` on which the pair fails agreement. -/
noncomputable def pairObstructions (P : ReedSolomon.Parameters F ι)
    (L : AffineLine ι F) (S : Finset ι) : Finset (Finset ι) := by
  classical
  exact (S.powersetCard (P.degreeBound + 1)).filter (fun T => ¬ P.PairCloseOnSet L T)

omit [DecidableEq ι] in
theorem mem_pairObstructions (P : ReedSolomon.Parameters F ι)
    (L : AffineLine ι F) {S T : Finset ι} :
    T ∈ P.pairObstructions L S ↔
      T ⊆ S ∧ T.card = P.degreeBound + 1 ∧ ¬ P.PairCloseOnSet L T := by
  classical
  simp [pairObstructions, Finset.mem_powersetCard, and_assoc]

/-- Failed pair agreement on `S` forces many failed local tests. -/
theorem choose_le_card_pairObstructions (P : ReedSolomon.Parameters F ι)
    (L : AffineLine ι F) (S : Finset ι) (hsize : P.degreeBound < S.card)
    (hfails : ¬ P.PairCloseOnSet L S) :
    (S.card - 1).choose P.degreeBound ≤ (P.pairObstructions L S).card := by
  classical
  revert hsize hfails
  refine Finset.strongInductionOn S ?_
  intro S ih hsize hfails
  ·
    let k := P.degreeBound
    let fails := fun T => ¬ P.PairCloseOnSet L T
    change (S.card - 1).choose k ≤ ((S.powersetCard (k + 1)).filter fails).card
    have hs : k < S.card := hsize
    by_cases tight : S.card = k + 1
    · rw [tight, Nat.add_sub_cancel, Nat.choose_self]
      apply Finset.one_le_card.mpr
      exact ⟨S, Finset.mem_filter.mpr ⟨Finset.mem_powersetCard.mpr ⟨Finset.Subset.refl _, tight⟩,
        hfails⟩⟩
    by_cases coherent : ∃ i ∈ S, P.PairCloseOnSet L (S.erase i)
    · obtain ⟨i, hi, c, hc, agrees⟩ := coherent
      rw [← Finset.card_erase_of_mem hi, ← Finset.card_powersetCard]
      apply Finset.card_le_card_of_injOn (insert i)
      · intro T hT
        obtain ⟨hsub, hcard⟩ := Finset.mem_powersetCard.mp hT
        have absent : i ∉ T := fun h => (Finset.mem_erase.mp (hsub h)).1 rfl
        refine Finset.mem_filter.mpr ⟨Finset.mem_powersetCard.mpr ⟨?_, ?_⟩, ?_⟩
        · exact Finset.insert_subset hi (hsub.trans (Finset.erase_subset _ _))
        · rw [Finset.card_insert_of_notMem absent, hcard]
        · rintro ⟨d, hd, agrees'⟩
          have same : c = d := P.vectorDeterminedBy_degreeBound (Fin 2) hc hd T hcard
            (fun j hj => (agrees j (hsub hj)).symm.trans (agrees' j (Finset.mem_insert_of_mem hj)))
          apply hfails
          refine ⟨c, hc, fun j hj => ?_⟩
          by_cases equal : j = i
          · subst j
            rw [same]
            exact agrees' i (Finset.mem_insert_self _ _)
          · exact agrees j (Finset.mem_erase.mpr ⟨equal, hj⟩)
      · intro T hT T' hT' equal
        have absent (U : Finset ι) (hU : U ∈ (S.erase i).powersetCard k) : i ∉ U :=
          fun h => (Finset.mem_erase.mp ((Finset.mem_powersetCard.mp hU).1 h)).1 rfl
        simpa only [Finset.erase_insert (absent T hT), Finset.erase_insert (absent T' hT')]
          using congrArg (fun U : Finset ι => U.erase i) equal
    · have lower (i : ι) (hi : i ∈ S) :
          (S.card - 2).choose k ≤ (((S.erase i).powersetCard (k + 1)).filter fails).card := by
        have size := Finset.card_erase_of_mem hi
        have larger : k < (S.erase i).card := by omega
        have counted := ih (S.erase i) (Finset.erase_ssubset hi) larger (fun h => coherent ⟨i, hi, h⟩)
        have minus : (S.erase i).card - 1 = S.card - 2 := by omega
        simpa only [pairObstructions, k, fails, minus] using counted
      have identity : (S.card - 2).choose k * (S.card - 1) =
          (S.card - 1).choose k * (S.card - (k + 1)) := by
        have pred : S.card - 2 + 1 = S.card - 1 := by omega
        have diff : S.card - 1 - k = S.card - (k + 1) := by omega
        simpa only [pred, diff] using Nat.choose_mul_succ_eq (S.card - 2) k
      have positive : 0 < S.card - (k + 1) := by omega
      refine Nat.le_of_mul_le_mul_right ?_ positive
      calc
        (S.card - 1).choose k * (S.card - (k + 1)) =
            (S.card - 2).choose k * (S.card - 1) := identity.symm
        _ ≤ (S.card - 2).choose k * S.card := Nat.mul_le_mul_left _ (Nat.sub_le _ _)
        _ = ∑ i ∈ S, (S.card - 2).choose k := by rw [Finset.sum_const, Nat.nsmul_eq_mul, Nat.mul_comm]
        _ ≤ ∑ i ∈ S, (((S.erase i).powersetCard (k + 1)).filter fails).card := Finset.sum_le_sum lower
        _ = ((S.powersetCard (k + 1)).filter fails).card * (S.card - (k + 1)) :=
          sum_card_filter_powersetCard_erase S (k + 1) fails

variable [Fintype F]

/-- Distinct bad challenges consume disjoint families of failed local tests. -/
theorem badChallengeSet_card_mul_choose_le (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound) (hk : P.degreeBound ≤ Fintype.card ι)
    (r : ℕ) (L : AffineLine ι F) :
    (P.toBlockCode.badChallengeSet r L).card * (Fintype.card ι - r - 1).choose P.degreeBound ≤
      (Fintype.card ι).choose (P.degreeBound + 1) := by
  classical
  let bad := P.toBlockCode.badChallengeSet r L
  let witness (γ : ↑bad) := ((P.toBlockCode.mem_badChallengeSet r L γ.val).mp γ.property).choose
  have witnessSpec (γ : ↑bad) : LargeAgreementSet r (witness γ) ∧ P.BadOnSet L γ.val (witness γ) :=
    ((P.toBlockCode.mem_badChallengeSet r L γ.val).mp γ.property).choose_spec
  let family (γ : ↑bad) := P.pairObstructions L (witness γ)
  have badOnLocal (γ : ↑bad) {T : Finset ι} (member : T ∈ family γ) : P.BadOnSet L γ.val T := by
    obtain ⟨contained, _, fails⟩ := (P.mem_pairObstructions L).mp member
    obtain ⟨c, codeword, agrees⟩ := (witnessSpec γ).2.1
    exact ⟨⟨c, codeword, fun i hi => agrees i (contained hi)⟩, fails⟩
  have disjoint : ((Finset.univ : Finset ↑bad) : Set ↑bad).PairwiseDisjoint family := by
    intro γ _ η _ different
    apply Finset.disjoint_left.mpr
    intro T hγ hη
    exact different (Subtype.ext (P.eq_of_badOnSet hDegree L T (badOnLocal γ hγ) (badOnLocal η hη)))
  have each (γ : ↑bad) : (Fintype.card ι - r - 1).choose P.degreeBound ≤ (family γ).card := by
    have large := (witnessSpec γ).1
    unfold LargeAgreementSet at large
    exact (Nat.choose_le_choose _ (by omega)).trans (P.choose_le_card_pairObstructions L (witness γ)
      (P.degreeBound_lt_card_of_badOnSet hDegree hk L γ.val (witnessSpec γ).2) (witnessSpec γ).2.2)
  calc
    bad.card * (Fintype.card ι - r - 1).choose P.degreeBound =
        ∑ _γ : ↑bad, (Fintype.card ι - r - 1).choose P.degreeBound := by
      simp only [Finset.sum_const, Finset.card_univ, Nat.nsmul_eq_mul, Fintype.card_coe]
    _ ≤ ∑ γ : ↑bad, (family γ).card := Finset.sum_le_sum fun γ _ => each γ
    _ = ((Finset.univ : Finset ↑bad).biUnion family).card := (Finset.card_biUnion disjoint).symm
    _ ≤ ((Finset.univ : Finset ι).powersetCard (P.degreeBound + 1)).card := by
      apply Finset.card_le_card
      intro T hT
      obtain ⟨γ, _, member⟩ := Finset.mem_biUnion.mp hT
      exact Finset.mem_powersetCard.mpr ⟨Finset.subset_univ _, ((P.mem_pairObstructions L).mp member).2.1⟩
    _ = (Fintype.card ι).choose (P.degreeBound + 1) := by
      rw [Finset.card_powersetCard, Finset.card_univ]

/-- The local-test bound at a radius with more than `k` required agreements. -/
theorem badChallengeSet_card_le_choose_div (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound) (r : ℕ) (hr : P.degreeBound < Fintype.card ι - r)
    (L : AffineLine ι F) :
    (P.toBlockCode.badChallengeSet r L).card ≤
      (Fintype.card ι).choose (P.degreeBound + 1) /
        (Fintype.card ι - r - 1).choose P.degreeBound := by
  have positive : 0 < (Fintype.card ι - r - 1).choose P.degreeBound := Nat.choose_pos (by omega)
  exact (Nat.le_div_iff_mul_le positive).mpr
    (P.badChallengeSet_card_mul_choose_le hDegree (by omega) r L)

end ProximityCoding.ReedSolomon.Parameters
