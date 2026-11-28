module

public import Proximity.MCA.Definitions
public import Proximity.Core.ReedSolomon

@[expose] public section

/-!
# Affine cancellation witnesses for same-set MCA

Assign distinct roots to selected coordinates of an affine word.  At each
root the scalar word agrees with zero at the clean coordinates and at the
selected root coordinate.  Its direction cannot agree with a codeword on
that set, by Reed--Solomon interpolation on the clean coordinates.
-/

set_option autoImplicit false

namespace ProximityCoding.ReedSolomon.Parameters

open BlockCode

variable {F ι : Type*} [Field F] [Fintype F] [Fintype ι]

/-- At least `t` challenges can be made bad at count radius `r` by assigning
distinct roots to `t` sites outside a clean interpolation set. -/
theorem exists_badChallengeSet_card_ge_of_le_succ
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound) {r t : ℕ}
    (hr : t ≤ r + 1) (hsites : P.degreeBound + t ≤ Fintype.card ι)
    (hfield : t ≤ Fintype.card F) :
    ∃ L : AffineLine ι F, t ≤ (P.toBlockCode.badChallengeSet r L).card := by
  classical
  obtain ⟨E, _, hE⟩ := Finset.exists_subset_card_eq
    (s := (Finset.univ : Finset ι)) (by simpa using (show t ≤ Fintype.card ι by omega))
  let clean : Finset ι := Finset.univ \ E
  have cleanSize : clean.card = Fintype.card ι - t := by
    dsimp only [clean]
    rw [Finset.card_sdiff_of_subset (Finset.subset_univ E), Finset.card_univ, hE]
  obtain ⟨T, hT, hTcard⟩ := Finset.exists_subset_card_eq
    (s := clean) (show P.degreeBound ≤ clean.card by omega)
  have enoughLabels : Fintype.card ↥E ≤ Fintype.card F := by
    simpa only [Fintype.card_coe, hE] using hfield
  obtain ⟨label⟩ := Function.Embedding.nonempty_of_card_le enoughLabels
  let L : AffineLine ι F :=
    { base := fun i => if hi : i ∈ E then -label ⟨i, hi⟩ else 0
      direction := fun i => if i ∈ E then 1 else 0 }
  have cancelled (a : ↥E) : label a ∈ P.toBlockCode.badChallengeSet r L := by
    rw [P.toBlockCode.mem_badChallengeSet]
    let S := insert a.val clean
    have notClean : a.val ∉ clean := fun hi => (Finset.mem_sdiff.mp hi).2 a.property
    refine ⟨S, ?_, ?_, ?_⟩
    · unfold LargeAgreementSet
      dsimp only [S]
      rw [Finset.card_insert_of_notMem notClean, cleanSize]
      omega
    · refine ⟨fun _ => 0, (P.fAdditive_of_degreeBound_pos hDegree).zero_mem, ?_⟩
      intro i hi
      rcases Finset.mem_insert.mp hi with rfl | hi
      · simp [L, AffineLine.point_apply, a.property]
      · simp [L, AffineLine.point_apply, (Finset.mem_sdiff.mp hi).2]
    · rintro ⟨c, hc, agrees⟩
      have directionZero : (fun i => c i 1) = (fun _ => (0 : F)) := by
        apply P.determinedBy_degreeBound (hc 1) (P.fAdditive_of_degreeBound_pos hDegree).zero_mem
          T hTcard
        intro i hi
        have hiClean := hT hi
        have hiS : i ∈ S := Finset.mem_insert_of_mem hiClean
        have atDirection := congrFun (agrees i hiS) (1 : Fin 2)
        simpa [L, (Finset.mem_sdiff.mp hiClean).2] using atDirection.symm
      have atRoot := congrFun (agrees a.val (Finset.mem_insert_self _ _)) (1 : Fin 2)
      have oneAtRoot : (1 : F) = c a.val 1 := by
        simpa [L, a.property] using atRoot
      exact one_ne_zero (oneAtRoot.trans (congrFun directionZero a.val))
  have subset : E.attach.image label ⊆ P.toBlockCode.badChallengeSet r L := by
    intro γ hγ
    obtain ⟨a, _, rfl⟩ := Finset.mem_image.mp hγ
    exact cancelled a
  refine ⟨L, ?_⟩
  have count := Finset.card_le_card subset
  rwa [Finset.card_image_of_injective _ label.injective, Finset.card_attach, hE] at count

end ProximityCoding.ReedSolomon.Parameters
