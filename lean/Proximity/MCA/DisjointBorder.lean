module

public import Proximity.MCA.SparsePencil

@[expose] public section

/-! # Disjoint error supports at the first overlap boundary -/

set_option autoImplicit false

namespace ProximityCoding.ReedSolomon.Parameters

open BlockCode

variable {F ι : Type*} [Field F] [Fintype F] [Fintype ι] [DecidableEq ι]

/-- At `k+3r=n+1`, two distinct scalar witnesses on a line with more
than `r+1` bad challenges have disjoint complements of size `r`. -/
theorem badSupports_card_eq_and_disjoint_of_border
    (P : Parameters F ι) (degreePositive : 0 < P.degreeBound) {r : ℕ}
    (border : P.degreeBound + 3 * r = Fintype.card ι + 1) (L : AffineLine ι F)
    (overBudget : r + 1 < (P.toBlockCode.badChallengeSet r L).card)
    {γ η : F} (distinct : γ ≠ η) {S T : Finset ι}
    (largeS : LargeAgreementSet r S) (largeT : LargeAgreementSet r T)
    (closeS : P.toBlockCode.CloseOnSet (L.point γ) S)
    (closeT : P.toBlockCode.CloseOnSet (L.point η) T) :
    (Finset.univ \ S).card = r ∧ (Finset.univ \ T).card = r ∧
      Disjoint (Finset.univ \ S) (Finset.univ \ T) := by
  have smallOverlap : (S ∩ T).card < P.degreeBound + r := by
    by_contra! overlap
    exact (not_le_of_gt overBudget)
      (P.badChallengeSet_card_le_succ_of_overlap degreePositive L distinct overlap closeS closeT)
  let E := Finset.univ \ S
  let G := Finset.univ \ T
  have cover : E ∪ G = Finset.univ \ (S ∩ T) := by
    ext i
    simp only [E, G, Finset.mem_union, Finset.mem_sdiff, Finset.mem_univ, true_and, Finset.mem_inter]
    tauto
  have partsS : E.card + S.card = Fintype.card ι :=
    (Finset.card_sdiff_add_card_eq_card S.subset_univ).trans Finset.card_univ
  have partsT : G.card + T.card = Fintype.card ι :=
    (Finset.card_sdiff_add_card_eq_card T.subset_univ).trans Finset.card_univ
  have unionParts : (E ∪ G).card + (S ∩ T).card = Fintype.card ι := by
    rw [cover]
    exact (Finset.card_sdiff_add_card_eq_card (S ∩ T).subset_univ).trans Finset.card_univ
  have count := Finset.card_union_add_card_inter E G
  unfold LargeAgreementSet at largeS largeT
  have empty : E ∩ G = ∅ := Finset.card_eq_zero.mp (by omega)
  change E.card = r ∧ G.card = r ∧ Disjoint E G
  exact ⟨by omega, by omega, Finset.disjoint_iff_inter_eq_empty.mpr empty⟩

/-- Extract a prescribed number of distinct bad challenges with disjoint
size-`r` witness supports at the first overlap boundary. -/
theorem exists_disjoint_badSupports_of_border
    (P : Parameters F ι) (degreePositive : 0 < P.degreeBound) {r m : ℕ}
    (border : P.degreeBound + 3 * r = Fintype.card ι + 1) (L : AffineLine ι F)
    (overBudget : r + 1 < (P.toBlockCode.badChallengeSet r L).card)
    (enough : m ≤ (P.toBlockCode.badChallengeSet r L).card) (two : 2 ≤ m) :
    ∃ (γ : Fin m → F) (E : Fin m → Finset ι),
      Function.Injective γ ∧ Pairwise (fun i j => Disjoint (E i) (E j)) ∧
        ∀ i, (E i).card = r ∧ P.toBlockCode.BadOnSet L (γ i) (Finset.univ \ E i) := by
  classical
  let B := P.toBlockCode.badChallengeSet r L
  have enoughLabels : Fintype.card (Fin m) ≤ Fintype.card ↥B := by
    simpa only [Fintype.card_fin, Fintype.card_coe] using enough
  obtain ⟨labels⟩ := Function.Embedding.nonempty_of_card_le enoughLabels
  let γ (i : Fin m) : F := (labels i).val
  have injective : Function.Injective γ := Subtype.val_injective.comp labels.injective
  have witnesses (i : Fin m) : ∃ S, LargeAgreementSet r S ∧ P.toBlockCode.BadOnSet L (γ i) S :=
    (P.toBlockCode.mem_badChallengeSet r L (γ i)).mp (labels i).property
  choose S large bad using witnesses
  let E (i : Fin m) : Finset ι := Finset.univ \ S i
  have sizeAndDisjoint {i j : Fin m} (distinct : i ≠ j) :
      (E i).card = r ∧ (E j).card = r ∧ Disjoint (E i) (E j) :=
    P.badSupports_card_eq_and_disjoint_of_border degreePositive border L overBudget
      (injective.ne distinct) (large i) (large j) (bad i).1 (bad j).1
  have nontrivial : Nontrivial (Fin m) := Fintype.one_lt_card_iff_nontrivial.mp (by
    rw [Fintype.card_fin]
    omega)
  refine ⟨γ, E, injective, fun _ _ distinct => (sizeAndDisjoint distinct).2.2, ?_⟩
  intro i
  obtain ⟨j, distinct⟩ := @exists_ne (Fin m) nontrivial i
  have complement : Finset.univ \ E i = S i := by
    ext x
    simp [E]
  exact ⟨(sizeAndDisjoint distinct.symm).1, complement.symm ▸ bad i⟩

end ProximityCoding.ReedSolomon.Parameters
