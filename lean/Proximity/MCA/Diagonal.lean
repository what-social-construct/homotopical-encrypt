module

public import Proximity.MCA.Definitions

@[expose] public section

/-!
# The cancelling challenge for a genuine diagonal pair

For a line whose base and direction are the same word, the scalar challenge
is multiplication by `1 + gamma`. Every noncancelling challenge is MCA-good
on every agreement set: divide a scalar codeword witness by that multiplier
and use the resulting codeword in both columns. If the common word is not a
codeword, the cancelling challenge `-1` is bad on the full coordinate set.

Thus at any nonnegative relative radius the bad set is exactly `{-1}` and its
uniform challenge fraction is `1 / |F|`. These are results for this actual
diagonal line, not a uniform MCA bound for all affine lines or a security game.
No distance identity or cited bound is used here.
-/

set_option autoImplicit false

noncomputable section

namespace ProximityCoding

namespace AffineLine

variable {ι F : Type*} [Field F]

/-- The actual scalar point of a diagonal line. -/
theorem point_eq_scale_of_diagonal
    (L : AffineLine ι F) (hdiag : L.direction = L.base) (γ : F) :
    L.point γ = fun i => (1 + γ) * L.base i := by
  funext i
  simp only [point, hdiag, add_mul, one_mul]

theorem point_neg_one_eq_zero_of_diagonal
    (L : AffineLine ι F) (hdiag : L.direction = L.base) :
    L.point (-1) = 0 := by
  rw [L.point_eq_scale_of_diagonal hdiag]
  funext i
  simp

end AffineLine

namespace FAdditiveCode

open BlockCode

variable {ι F : Type*} [Field F]

private theorem one_add_ne_zero_of_ne_neg_one (γ : F) (hne : γ ≠ -1) :
    1 + γ ≠ 0 := by
  intro hzero
  apply hne
  calc
    γ = (1 + γ) - 1 := by ring
    _ = -1 := by rw [hzero]; simp

/-- Extend an actual scalar witness to the same coordinate set by dividing
it by the nonzero challenge multiplier and repeating the codeword. -/
theorem pairCloseOnSet_of_diagonal_of_noncancelling
    (C : FAdditiveCode F ι F) (L : AffineLine ι F)
    (hdiag : L.direction = L.base) (γ : F) (hγ : 1 + γ ≠ 0)
    (S : Finset ι) (hclose : C.asBlockCode.CloseOnSet (L.point γ) S) :
    C.asBlockCode.PairCloseOnSet L S := by
  rcases hclose with ⟨c, hc, hagree⟩
  let d : Word ι F := fun i => (1 + γ)⁻¹ * c i
  have hd : C.Codeword d := by
    simpa only [smul_eq_mul] using C.smul_mem (1 + γ)⁻¹ hc
  refine ⟨fun i _ => d i, fun _ => hd, ?_⟩
  intro i hi
  have hscalar : (1 + γ) * L.base i = c i := by
    have h := hagree i hi
    rw [L.point_eq_scale_of_diagonal hdiag γ] at h
    exact h
  have hbase : L.base i = d i := by
    change L.base i = (1 + γ)⁻¹ * c i
    rw [← hscalar, ← mul_assoc, inv_mul_cancel₀ hγ, one_mul]
  funext j
  simpa only [pairWord, hdiag, ite_self] using hbase

theorem not_badOnSet_of_diagonal_of_noncancelling
    (C : FAdditiveCode F ι F) (L : AffineLine ι F)
    (hdiag : L.direction = L.base) (γ : F) (hγ : 1 + γ ≠ 0) (S : Finset ι) :
    ¬ C.asBlockCode.BadOnSet L γ S := by
  rintro ⟨hclose, hnot⟩
  exact hnot (C.pairCloseOnSet_of_diagonal_of_noncancelling L hdiag γ hγ S hclose)

section FiniteCoordinates

variable [Fintype ι]

/-- Cancellation makes the scalar word zero on the full set, whereas a
pair fit there would force the original common word to be a codeword. -/
theorem badOnSet_neg_one_univ_of_diagonal
    (C : FAdditiveCode F ι F) (L : AffineLine ι F)
    (hdiag : L.direction = L.base) (hword : ¬ C.Codeword L.base) :
    C.asBlockCode.BadOnSet L (-1) Finset.univ := by
  constructor
  · refine ⟨fun _ => 0, C.zero_mem, ?_⟩
    intro i _
    have hzero := congrFun (L.point_neg_one_eq_zero_of_diagonal hdiag) i
    exact hzero
  · rintro ⟨p, hp, hagree⟩
    apply hword
    have hbase : L.base = fun i => p i 0 := by
      funext i
      exact by simpa only [pairWord_zero] using congrFun (hagree i (Finset.mem_univ i)) 0
    rw [hbase]
    exact hp 0

end FiniteCoordinates

section FiniteChallenges

variable [Fintype ι] [Fintype F]

/-- Every noncancelling public challenge is good, at every real radius. -/
theorem not_mem_badChallengeSetAt_of_diagonal_of_noncancelling
    (C : FAdditiveCode F ι F) (L : AffineLine ι F)
    (hdiag : L.direction = L.base) (δ : ℝ) (γ : F) (hγ : 1 + γ ≠ 0) :
    γ ∉ C.asBlockCode.badChallengeSetAt δ L := by
  intro hbad
  obtain ⟨S, _, hS⟩ := (C.asBlockCode.mem_badChallengeSetAt δ L γ).mp hbad
  exact C.not_badOnSet_of_diagonal_of_noncancelling L hdiag γ hγ S hS

theorem not_mem_badChallengeSetAt_of_diagonal_of_ne_neg_one
    (C : FAdditiveCode F ι F) (L : AffineLine ι F)
    (hdiag : L.direction = L.base) (δ : ℝ) (γ : F) (hγ : γ ≠ -1) :
    γ ∉ C.asBlockCode.badChallengeSetAt δ L :=
  C.not_mem_badChallengeSetAt_of_diagonal_of_noncancelling L hdiag δ γ
    (one_add_ne_zero_of_ne_neg_one γ hγ)

theorem not_mem_badChallengeSet_of_diagonal_of_noncancelling
    (C : FAdditiveCode F ι F) (L : AffineLine ι F)
    (hdiag : L.direction = L.base) (r : ℕ) (γ : F) (hγ : 1 + γ ≠ 0) :
    γ ∉ C.asBlockCode.badChallengeSet r L := by
  intro hbad
  obtain ⟨S, _, hS⟩ := (C.asBlockCode.mem_badChallengeSet r L γ).mp hbad
  exact C.not_badOnSet_of_diagonal_of_noncancelling L hdiag γ hγ S hS

/-- The cancelling challenge is the unique bad challenge at every count radius. -/
theorem badChallengeSet_eq_singleton_of_diagonal
    (C : FAdditiveCode F ι F) (L : AffineLine ι F)
    (hdiag : L.direction = L.base) (hword : ¬ C.Codeword L.base) (r : ℕ) :
    C.asBlockCode.badChallengeSet r L = {-1} := by
  classical
  ext γ
  constructor
  · intro hbad
    apply Finset.mem_singleton.mpr
    by_contra hne
    exact C.not_mem_badChallengeSet_of_diagonal_of_noncancelling L hdiag r γ
      (one_add_ne_zero_of_ne_neg_one γ hne) hbad
  · intro hmem
    obtain rfl := Finset.mem_singleton.mp hmem
    apply (C.asBlockCode.mem_badChallengeSet r L (-1)).mpr
    refine ⟨Finset.univ, ?_, C.badOnSet_neg_one_univ_of_diagonal L hdiag hword⟩
    unfold LargeAgreementSet
    simp

/-- At nonnegative paper radii and positive length, the exact bad set is
the singleton cancelling challenge. -/
theorem badChallengeSetAt_eq_singleton_of_diagonal
    (C : FAdditiveCode F ι F) (L : AffineLine ι F)
    (hdiag : L.direction = L.base) (hword : ¬ C.Codeword L.base)
    (hn : 0 < Fintype.card ι) (δ : ℝ) (hδ : 0 ≤ δ) :
    C.asBlockCode.badChallengeSetAt δ L = {-1} := by
  classical
  ext γ
  constructor
  · intro hbad
    apply Finset.mem_singleton.mpr
    by_contra hne
    exact C.not_mem_badChallengeSetAt_of_diagonal_of_ne_neg_one L hdiag δ γ hne hbad
  · intro hmem
    obtain rfl := Finset.mem_singleton.mp hmem
    apply (C.asBlockCode.mem_badChallengeSetAt δ L (-1)).mpr
    refine ⟨Finset.univ, ?_, C.badOnSet_neg_one_univ_of_diagonal L hdiag hword⟩
    have hnR : (Fintype.card ι : ℝ) ≠ 0 := by exact_mod_cast Nat.ne_of_gt hn
    unfold LargeAgreementSetAt coordinateFraction
    rw [Finset.card_univ, div_self hnR]
    linarith

/-- Exact uniform challenge fraction for this diagonal non-codeword pair. -/
theorem challengeFraction_badChallengeSetAt_eq_of_diagonal
    (C : FAdditiveCode F ι F) (L : AffineLine ι F)
    (hdiag : L.direction = L.base) (hword : ¬ C.Codeword L.base)
    (hn : 0 < Fintype.card ι) (δ : ℝ) (hδ : 0 ≤ δ) :
    challengeFraction (C.asBlockCode.badChallengeSetAt δ L) =
      (1 : ℝ) / Fintype.card F := by
  rw [C.badChallengeSetAt_eq_singleton_of_diagonal L hdiag hword hn δ hδ]
  simp [challengeFraction]

end FiniteChallenges

end FAdditiveCode
end ProximityCoding
