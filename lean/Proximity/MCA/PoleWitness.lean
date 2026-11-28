module

public import Proximity.Core.ReedSolomon
public import Proximity.MCA.Threshold
public import Mathlib.Algebra.Polynomial.FieldDivision
public import Mathlib.Data.Fintype.Powerset

@[expose] public section

/-! # Transferring polynomial witnesses to a common bad-challenge line -/

set_option autoImplicit false

namespace ProximityCoding.ReedSolomon.Parameters

open BlockCode Polynomial

variable {F ι : Type*} [Field F] [Fintype F] [Fintype ι]

/-- Divide the value difference by the distance to a pole outside the domain. -/
def poleLine (P : Parameters F ι) (received : Word ι F) (α : F) : AffineLine ι F where
  base i := received i / (P.domain.point i - α)
  direction i := -1 / (P.domain.point i - α)

omit [Fintype F] in
/-- A polynomial of degree at most `k` agreeing with the received values on
more than `k` sites contributes its value at the pole as a bad challenge. -/
theorem badOnSet_poleLine (P : Parameters F ι) (hk : 0 < P.degreeBound)
    (received : Word ι F) (α : F) (outside : ∀ i, P.domain.point i ≠ α)
    (f : F[X]) (degree : f.natDegree ≤ P.degreeBound) (S : Finset ι)
    (large : P.degreeBound < S.card) (agrees : ∀ i ∈ S, received i = f.eval (P.domain.point i)) :
    P.toBlockCode.BadOnSet (P.poleLine received α) (f.eval α) S := by
  classical
  constructor
  · let g := f /ₘ (X - C α)
    refine ⟨fun i => g.eval (P.domain.point i), ⟨g, ?_, fun _ => rfl⟩, ?_⟩
    · dsimp only [g]
      rw [natDegree_divByMonic f (monic_X_sub_C α), natDegree_X_sub_C]
      omega
    · intro i hi
      have ev := congrArg (eval (P.domain.point i)) (X_sub_C_mul_divByMonic_eq_sub_modByMonic f α)
      rw [modByMonic_X_sub_C_eq_C_eval, eval_mul, eval_sub, eval_sub, eval_X, eval_C, eval_C] at ev
      change received i / (P.domain.point i - α) + f.eval α * (-1 / (P.domain.point i - α)) =
        g.eval (P.domain.point i)
      rw [agrees i hi, ← mul_div_assoc, mul_neg_one, ← add_div, ← sub_eq_add_neg, div_eq_iff]
      · exact ev.symm.trans (mul_comm _ _)
      · exact sub_ne_zero.mpr (outside i)
  · rintro ⟨word, valid, equal⟩
    obtain ⟨p, pdegree, evaluates⟩ := valid (1 : Fin 2)
    let h : F[X] := (X - C α) * p + 1
    have degreeBound : h.natDegree ≤ P.degreeBound := by
      refine (natDegree_add_le _ _).trans (max_le ?_ (by simp))
      exact natDegree_mul_le.trans (by rw [natDegree_X_sub_C]; omega)
    have vanishes i (hi : i ∈ S) : h.eval (P.domain.point i) = 0 := by
      have same : -1 / (P.domain.point i - α) = p.eval (P.domain.point i) :=
        (congrFun (equal i hi) (1 : Fin 2)).trans (evaluates i)
      have equation := (div_eq_iff (sub_ne_zero.mpr (outside i))).mp same
      change ((X - C α) * p + 1).eval (P.domain.point i) = 0
      simp only [eval_add, eval_mul, eval_sub, eval_X, eval_C, eval_one]
      rw [mul_comm, ← equation, neg_add_cancel]
    have zero : h = 0 := by
      apply Polynomial.eq_of_degrees_lt_of_eval_index_eq S P.domain.injective_point.injOn
      · exact h.degree_le_natDegree.trans_lt (WithBot.coe_lt_coe.mpr (degreeBound.trans_lt large))
      · simp
      · intro i hi
        simpa using vanishes i hi
    have atPole := congrArg (eval α) zero
    simp [h] at atPole

/-- A pole can be chosen outside the domain and every pairwise collision
set when their total root-count bound is less than the field size. -/
theorem exists_separating_pole {β : Type*} [Fintype β] (P : Parameters F ι)
    (f : β → F[X]) (distinct : Function.Injective f) (degree : ∀ a, (f a).natDegree ≤ P.degreeBound)
    (few : Fintype.card ι + P.degreeBound * (Fintype.card β).choose 2 < Fintype.card F) :
    ∃ α : F, (∀ i, P.domain.point i ≠ α) ∧ Function.Injective (fun a => (f a).eval α) := by
  classical
  let sites := Finset.univ.image P.domain.point
  let pairs := (Finset.univ : Finset β).powersetCard 2
  have shape (pair : ↥pairs) : ∃ a b, a ≠ b ∧ pair.val = {a, b} :=
    Finset.card_eq_two.mp (Finset.mem_powersetCard.mp pair.property).2
  choose left right distinctSites endpoints using shape
  let difference (pair : ↥pairs) := f (left pair) - f (right pair)
  let roots (pair : ↥pairs) := (difference pair).roots.toFinset
  have nonzero (pair : ↥pairs) : difference pair ≠ 0 :=
    fun zero => distinctSites pair (distinct (sub_eq_zero.mp zero))
  have rootCount (pair : ↥pairs) : (roots pair).card ≤ P.degreeBound :=
    (Multiset.toFinset_card_le _).trans ((Polynomial.card_roots' _).trans
      ((natDegree_sub_le _ _).trans (max_le (degree _) (degree _))))
  let collisions := Finset.univ.biUnion roots
  have collisionCount : collisions.card ≤ (Fintype.card β).choose 2 * P.degreeBound := by
    simpa only [collisions, Finset.card_univ, Fintype.card_coe, pairs, Finset.card_powersetCard] using
      Finset.card_biUnion_le_card_mul Finset.univ roots P.degreeBound (fun p _ => rootCount p)
  let excluded := sites ∪ collisions
  have siteCount : sites.card ≤ Fintype.card ι := Finset.card_image_le.trans_eq Finset.card_univ
  have excludedSmall : excluded.card < Fintype.card F := by
    apply (Finset.card_union_le _ _).trans_lt
    exact (Nat.add_le_add siteCount collisionCount).trans_lt (by simpa only [Nat.mul_comm] using few)
  obtain ⟨α, available⟩ : ∃ α, α ∉ excluded := by
    by_contra! all
    rw [Finset.eq_univ_of_forall all, Finset.card_univ] at excludedSmall
    exact (lt_irrefl _ excludedSmall)
  have outsideSites : α ∉ sites := fun member => available (Finset.mem_union_left _ member)
  have outsideCollisions : α ∉ collisions := fun member => available (Finset.mem_union_right _ member)
  refine ⟨α, fun i equal => outsideSites (Finset.mem_image.mpr ⟨i, Finset.mem_univ _, equal⟩), ?_⟩
  intro a b collide
  by_contra unequal
  let pair : ↥pairs :=
    ⟨{a, b}, Finset.mem_powersetCard.mpr ⟨Finset.subset_univ _, by simp [unequal]⟩⟩
  have allEqual (z : β) (member : z ∈ pair.val) : (f z).eval α = (f a).eval α := by
    have selected : z = a ∨ z = b := by simpa [pair] using member
    rcases selected with rfl | rfl
    · rfl
    · exact collide.symm
  have leftMember : left pair ∈ pair.val := by rw [endpoints pair]; simp
  have rightMember : right pair ∈ pair.val := by rw [endpoints pair]; simp
  apply outsideCollisions
  refine Finset.mem_biUnion.mpr ⟨pair, Finset.mem_univ _, Multiset.mem_toFinset.mpr ?_⟩
  apply (mem_roots (nonzero pair)).mpr
  change (f (left pair) - f (right pair)).eval α = 0
  rw [eval_sub, (allEqual _ leftMember).trans (allEqual _ rightMember).symm, sub_self]

/-- The pole construction transfers an injective family of degree-`≤ k`
agreement polynomials into distinct bad challenges on one line. -/
theorem exists_badChallengeSet_card_ge_of_pole_family {β : Type*} [Fintype β]
    (P : Parameters F ι) (hk : 0 < P.degreeBound) (r : ℕ) (received : Word ι F)
    (f : β → F[X]) (distinct : Function.Injective f) (degree : ∀ a, (f a).natDegree ≤ P.degreeBound)
    (S : β → Finset ι) (large : ∀ a, LargeAgreementSet r (S a))
    (more : ∀ a, P.degreeBound < (S a).card)
    (agrees : ∀ a i, i ∈ S a → received i = (f a).eval (P.domain.point i))
    (few : Fintype.card ι + P.degreeBound * (Fintype.card β).choose 2 < Fintype.card F) :
    ∃ L : AffineLine ι F, Fintype.card β ≤ (P.toBlockCode.badChallengeSet r L).card := by
  classical
  obtain ⟨α, outside, separated⟩ := P.exists_separating_pole f distinct degree few
  let L := P.poleLine received α
  refine ⟨L, ?_⟩
  let challenge (a : β) : ↥(P.toBlockCode.badChallengeSet r L) :=
    ⟨(f a).eval α, (P.toBlockCode.mem_badChallengeSet r L _).mpr
      ⟨S a, large a, P.badOnSet_poleLine hk received α outside (f a) (degree a)
        (S a) (more a) (agrees a)⟩⟩
  simpa only [Fintype.card_coe] using
    Fintype.card_le_of_injective challenge (fun _ _ equal => separated (congrArg Subtype.val equal))

end ProximityCoding.ReedSolomon.Parameters
