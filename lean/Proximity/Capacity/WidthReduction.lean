module

public import Proximity.Core.BlockCode
public import Mathlib.Data.Fintype.Powerset
public import Mathlib.Data.Matrix.Mul
public import Mathlib.GroupTheory.Index

@[expose] public section

/-!
# Exact reduction from interleaved to scalar list bounds

One linear projection preserves all the distinctions in a finite list
provided the number of candidate pairs is smaller than the field size.
The scalar Hamming distance to the projected center cannot increase.
-/

set_option autoImplicit false

namespace ProximityCoding

open BlockCode
open scoped BigOperators

variable {F ι σ : Type*} [Field F] [Fintype F] [DecidableEq F]
variable [Fintype ι] [Fintype σ] [Nonempty σ]

omit [Nonempty σ] in
private theorem dotProduct_zero_card [DecidableEq σ]
    (v : σ → F) (nonzero : ∃ j, v j ≠ 0) :
    (Finset.univ.filter (fun a : σ → F => dotProduct a v = 0)).card *
      Fintype.card F = Fintype.card (σ → F) := by
  classical
  let evaluate : (σ → F) →+ F :=
    { toFun := fun a => dotProduct a v
      map_zero' := zero_dotProduct v
      map_add' := fun a b => add_dotProduct a b v }
  obtain ⟨j, hj⟩ := nonzero
  have surjective : Function.Surjective evaluate := by
    intro y
    refine ⟨Pi.single j (y / v j), ?_⟩
    change dotProduct (Pi.single j (y / v j)) v = y
    rw [single_dotProduct, div_mul_cancel₀ _ hj]
  let kernel : ↑(Finset.univ.filter (fun a : σ → F => dotProduct a v = 0)) ≃
      evaluate.ker :=
    Equiv.subtypeEquiv (Equiv.refl _)
      (fun a => by simp [evaluate, AddMonoidHom.mem_ker])
  let : Fintype evaluate.ker := Fintype.ofFinite _
  have card := Nat.card_congr kernel
  rw [Nat.card_eq_fintype_card, Fintype.card_coe] at card
  rw [card]
  simpa only [Nat.card_eq_fintype_card] using
    AddSubgroup.card_ker_mul_card_of_surjective (f := evaluate) surjective

private theorem exists_projection_avoiding
    {β : Type*} [Fintype β] (normal : β → σ → F)
    (nonzero : ∀ p, ∃ j, normal p j ≠ 0)
    (few : Fintype.card β < Fintype.card F) :
    ∃ a : σ → F, ∀ p, dotProduct a (normal p) ≠ 0 := by
  classical
  let bad (p : β) := Finset.univ.filter
    (fun a : σ → F => dotProduct a (normal p) = 0)
  let fiberBound := Fintype.card (σ → F) / Fintype.card F
  have qPositive : 0 < Fintype.card F := Fintype.card_pos
  have dimEnough : Fintype.card F ≤ Fintype.card (σ → F) := by
    obtain ⟨j⟩ := ‹Nonempty σ›
    exact Fintype.card_le_of_injective (fun x : F => fun _ : σ => x)
      (fun _ _ h => congrFun h j)
  have boundPositive : 0 < fiberBound := Nat.div_pos dimEnough qPositive
  have fiberCard (p : β) : (bad p).card ≤ fiberBound :=
    (Nat.le_div_iff_mul_le qPositive).mpr (dotProduct_zero_card (normal p) (nonzero p)).le
  have unionCount := Finset.card_biUnion_le_card_mul Finset.univ bad fiberBound
    (fun p _ => fiberCard p)
  rw [Finset.card_univ] at unionCount
  have productBound : Fintype.card F * fiberBound ≤ Fintype.card (σ → F) := by
    simpa only [fiberBound, Nat.mul_comm] using
      (Nat.div_mul_le_self (Fintype.card (σ → F)) (Fintype.card F))
  have unionSmall := unionCount.trans_lt
    ((Nat.mul_lt_mul_of_pos_right few boundPositive).trans_le productBound)
  have notAll : (Finset.univ : Finset β).biUnion bad ≠ Finset.univ := by
    intro all
    rw [all, Finset.card_univ] at unionSmall
    exact (lt_irrefl _ unionSmall)
  have existsOutside : ∃ a, a ∉ (Finset.univ : Finset β).biUnion bad := by
    by_contra! all
    exact notAll (Finset.eq_univ_of_forall all)
  obtain ⟨a, outside⟩ := existsOutside
  refine ⟨a, fun p zero => outside ?_⟩
  exact Finset.mem_biUnion.mpr ⟨p, Finset.mem_univ _, by simp [bad, zero]⟩

private theorem exists_injective_projection
    {β : Type*} [Fintype β] (words : β → Word ι (σ → F))
    (distinct : Function.Injective words) (few : (Fintype.card β).choose 2 < Fintype.card F) :
    ∃ a : σ → F, Function.Injective (fun b i => dotProduct a (words b i)) := by
  classical
  let pairs := (Finset.univ : Finset β).powersetCard 2
  have endpoints (p : ↥pairs) :
      ∃ left right i, p.val = {left, right} ∧ words left i ≠ words right i := by
    obtain ⟨left, right, unequal, shape⟩ :=
      Finset.card_eq_two.mp (Finset.mem_powersetCard.mp p.property).2
    have mismatch : ∃ i, words left i ≠ words right i := by
      by_contra! all
      exact unequal (distinct (funext all))
    obtain ⟨i, differs⟩ := mismatch
    exact ⟨left, right, i, shape, differs⟩
  choose left right site shape differs using endpoints
  let normal (p : ↥pairs) := words (left p) (site p) - words (right p) (site p)
  have nonzero (p : ↥pairs) : ∃ j, normal p j ≠ 0 := by
    by_contra! all
    apply differs p
    funext j
    exact sub_eq_zero.mp (all j)
  have pairCount : Fintype.card (↥pairs) < Fintype.card F := by
    simpa only [Fintype.card_coe, pairs, Finset.card_powersetCard, Finset.card_univ] using few
  obtain ⟨a, avoid⟩ := exists_projection_avoiding normal nonzero pairCount
  refine ⟨a, fun b c equal => ?_⟩
  by_contra unequal
  let p : ↥pairs :=
    ⟨{b, c}, Finset.mem_powersetCard.mpr ⟨Finset.subset_univ _, by simp [unequal]⟩⟩
  have same (z : β) (member : z ∈ p.val) :
      dotProduct a (words z (site p)) = dotProduct a (words b (site p)) := by
    have either : z = b ∨ z = c := by simpa [p] using member
    rcases either with rfl | rfl
    · rfl
    · exact (congrFun equal (site p)).symm
  have leftMember : left p ∈ p.val := by rw [shape p]; simp
  have rightMember : right p ∈ p.val := by rw [shape p]; simp
  apply avoid p
  rw [show normal p = words (left p) (site p) - words (right p) (site p) from rfl,
    dotProduct_sub, sub_eq_zero]
  exact (same _ leftMember).trans (same _ rightMember).symm

omit [Field F] [Fintype F] [Nonempty σ] in
private theorem hammingDistance_map_le
    (f : (σ → F) → F) (u v : Word ι (σ → F)) :
    hammingDistance (fun i => f (u i)) (fun i => f (v i)) ≤ hammingDistance u v := by
  apply Finset.card_le_card
  intro i member
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at member ⊢
  exact fun eq => member (congrArg f eq)

namespace FAdditiveCode

omit [Fintype F] [DecidableEq F] [Fintype ι] [Nonempty σ] in
private theorem projection_codeword (C : FAdditiveCode F ι F)
    (a : σ → F) {v : Word ι (σ → F)} (valid : (C.asBlockCode.interleaved σ).Codeword v) :
    C.Codeword (fun i => dotProduct a (v i)) := by
  classical
  have validSum (components : Finset σ) :
      C.Codeword (fun i => ∑ j ∈ components, a j * v i j) := by
    induction components using Finset.induction_on with
    | empty => simpa using C.zero_mem
    | insert j components fresh inductionHypothesis =>
        simp only [Finset.sum_insert fresh]
        exact C.add_mem (C.smul_mem (a j) (valid j)) inductionHypothesis
  exact validSum Finset.univ

/-- The scalar list target is equivalent to its positive-width interleaving
whenever the number of pairs in a violating list is less than the field size. -/
theorem interleaved_listSizeBound_iff (C : FAdditiveCode F ι F)
    (r B : ℕ) (pairBudget : (B + 1).choose 2 < Fintype.card F) :
    (C.asBlockCode.interleaved σ).ListSizeBound r B ↔ C.asBlockCode.ListSizeBound r B := by
  classical
  constructor
  · intro bounded w
    obtain ⟨j⟩ := ‹Nonempty σ›
    let liftWord (u : Word ι F) : Word ι (σ → F) := fun i _ => u i
    have distance (u : Word ι F) :
        hammingDistance (liftWord u) (liftWord w) ≤ hammingDistance u w := by
      apply Finset.card_le_card
      intro i member
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at member ⊢
      exact fun eq => member (by simp [liftWord, eq])
    let liftBall (u : {c // c ∈ C.asBlockCode.Ball r w}) :
        {c // c ∈ (C.asBlockCode.interleaved σ).Ball r (liftWord w)} :=
      ⟨liftWord u.val, fun _ => u.property.1, (distance u.val).trans u.property.2⟩
    have injective : Function.Injective liftBall := by
      intro u v same
      apply Subtype.ext
      funext i
      exact congrFun (congrFun (congrArg Subtype.val same) i) j
    exact (Nat.card_le_card_of_injective liftBall injective).trans (bounded (liftWord w))
  · intro bounded w
    by_contra tooMany
    let ball := {c // c ∈ (C.asBlockCode.interleaved σ).Ball r w}
    let : Fintype ball := Fintype.ofFinite _
    have enough : Fintype.card (Fin (B + 1)) ≤ Fintype.card ball := by
      rw [Fintype.card_fin, ← Nat.card_eq_fintype_card]
      exact Nat.succ_le_of_lt (lt_of_not_ge tooMany)
    obtain ⟨select⟩ := Function.Embedding.nonempty_of_card_le enough
    let words (i : Fin (B + 1)) : Word ι (σ → F) := (select i).val
    have distinct : Function.Injective words := fun _ _ h =>
      select.injective (Subtype.ext h)
    obtain ⟨a, separate⟩ := exists_injective_projection words distinct
      (by simpa only [Fintype.card_fin] using pairBudget)
    let project (u : Word ι (σ → F)) : Word ι F := fun i => dotProduct a (u i)
    let projected (i : Fin (B + 1)) :
        {c // c ∈ C.asBlockCode.Ball r (project w)} :=
      ⟨project (words i), C.projection_codeword a (select i).property.1,
        (hammingDistance_map_le (dotProduct a) (words i) w).trans (select i).property.2⟩
    have injective : Function.Injective projected := fun _ _ h =>
      separate (congrArg Subtype.val h)
    have exceeds := (Nat.card_le_card_of_injective projected injective).trans
      (bounded (project w))
    rw [Nat.card_fin] at exceeds
    omega

/-- Below field size `2^256`, the integral `2^-128` list budget is invariant
under every positive interleaving width. -/
theorem interleaved_listSizeBound_128_iff (C : FAdditiveCode F ι F)
    (r : ℕ) (fieldBound : Fintype.card F < 2 ^ 256) :
    (C.asBlockCode.interleaved σ).ListSizeBound r (Fintype.card F / 2 ^ 128) ↔
      C.asBlockCode.ListSizeBound r (Fintype.card F / 2 ^ 128) := by
  apply C.interleaved_listSizeBound_iff
  let q := Fintype.card F
  let B := q / 2 ^ 128
  change (B + 1).choose 2 < q
  have Bbound : B < 2 ^ 128 := by
    apply (Nat.div_lt_iff_lt_mul (by decide : 0 < (2 : ℕ) ^ 128)).mpr
    rw [← pow_add]
    exact fieldBound
  have productBound : (B + 1) * B ≤ q := by
    calc
      (B + 1) * B ≤ (2 ^ 128) * B := Nat.mul_le_mul_right B Bbound
      _ = B * 2 ^ 128 := Nat.mul_comm _ _
      _ ≤ q := Nat.div_mul_le_self q _
  rw [Nat.choose_two_right, Nat.add_sub_cancel]
  exact (Nat.div_le_div_right productBound).trans_lt
    (Nat.div_lt_self Fintype.card_pos (by decide))

end FAdditiveCode

end ProximityCoding
