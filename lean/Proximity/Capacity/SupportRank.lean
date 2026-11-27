module

public import Proximity.Capacity.ListSyndrome
public import Proximity.Capacity.SubspaceAvoidance
public import Proximity.ListDecoding.PhaseSplit

@[expose] public section

/-!
# List bounds from support intersections

An oversized list selects distinct exact supports. The common syndrome
intersection must escape every one-site deletion. When there are fewer
deletions than field elements, a single scalar syndrome realizes all of
these support conditions simultaneously.
-/

set_option autoImplicit false

namespace ProximityCoding.BlockCode.Syndrome

variable {F ι V : Type*} [Field F] [Fintype F] [Fintype ι] [DecidableEq ι]
variable [AddCommGroup V] [Module F V]

/-- A family of supports can be realized simultaneously by an exact error
on each support if its intersection escapes every one-site deletion. -/
def escapesDeletions {α : Type*} (H : (ι → F) →ₗ[F] V) (E : α → Finset ι) : Prop :=
  ∀ a i, i ∈ E a → ¬ (⨅ b, errorSyndromes H (E b)) ≤ errorSyndromes H ((E a).erase i)

theorem not_listSizeBound_iff_supportIntersection {σ : Type*}
    [Fintype σ] [Nonempty σ] [DecidableEq F]
    (C : BlockCode ι F) (H : (ι → F) →ₗ[F] V)
    (hker : ∀ w : Word ι F, H w = 0 ↔ C.Codeword w)
    (onto : Function.Surjective H) (r B : ℕ)
    (unique : ∀ E : Finset ι, E.card ≤ r → Set.InjOn H (supportedWords (F := F) E))
    (few : (B + 1) * r < Fintype.card F) :
    ¬ (C.interleaved σ).ListSizeBound r B ↔
      ∃ E : Fin (B + 1) → Finset ι,
        Function.Injective E ∧ (∀ a, (E a).card ≤ r) ∧ escapesDeletions H E := by
  classical
  rw [exists_list_violation_iff_exactSupports C H hker onto r B unique]
  constructor
  · rintro ⟨s, E, injective, exactSupports⟩
    refine ⟨E, injective, fun a => (exactSupports a).1, ?_⟩
    intro a i member contained
    obtain ⟨j, absent⟩ := (exactSupports a).2.2 i member
    apply absent (contained ?_)
    exact (Submodule.mem_iInf _).mpr (fun b => (exactSupports b).2.1 j)
  · rintro ⟨E, injective, small, escapes⟩
    let X := ⨅ b, errorSyndromes H (E b)
    let Deletion := Σ a : Fin (B + 1), ↥(E a)
    let forbidden (d : Deletion) : Submodule F X :=
      (errorSyndromes H ((E d.1).erase d.2.val)).comap X.subtype
    have proper (d : Deletion) : forbidden d ≠ ⊤ := by
      intro all
      apply escapes d.1 d.2.val d.2.property
      intro y hy
      have inside : (⟨y, hy⟩ : X) ∈ forbidden d := by rw [all]; trivial
      exact inside
    have deletionCount : Fintype.card Deletion ≤ (B + 1) * r := by
      calc
        Fintype.card Deletion = ∑ a : Fin (B + 1), (E a).card := by
          simp [Deletion]
        _ ≤ ∑ _a : Fin (B + 1), r := Finset.sum_le_sum (fun a _ => small a)
        _ = (B + 1) * r := by simp
    obtain ⟨y, avoids⟩ := exists_outside_subspaces forbidden proper (deletionCount.trans_lt few)
    obtain ⟨j⟩ := ‹Nonempty σ›
    refine ⟨fun _ : σ => y.val, E, injective, fun a => ⟨small a, ?_, ?_⟩⟩
    · intro _
      exact (Submodule.mem_iInf _).mp y.property a
    · intro i member
      exact ⟨j, avoids ⟨a, i, member⟩⟩

end ProximityCoding.BlockCode.Syndrome

namespace ProximityCoding.ReedSolomon.Parameters

open BlockCode BlockCode.Syndrome

variable {F ι σ : Type*} [Field F] [Fintype F] [DecidableEq F]
variable [Fintype ι] [DecidableEq ι] [Fintype σ] [Nonempty σ]

/-- The canonical quotient syndrome. In coordinates, its support spaces are
spans of the columns of any full-rank parity-check matrix. -/
abbrev quotientSyndrome (P : Parameters F ι) (hk : 0 < P.degreeBound) :=
  (codeSubmodule (P.fAdditive_of_degreeBound_pos hk).toFAdditiveCode).mkQ

omit [Fintype F] [DecidableEq F] [DecidableEq ι] in
private theorem quotientSyndrome_injOn (P : Parameters F ι) (hk : 0 < P.degreeBound)
    (hn : P.degreeBound ≤ P.length) (E : Finset ι) (small : E.card ≤ P.length - P.degreeBound) :
    Set.InjOn (P.quotientSyndrome hk) (supportedWords (F := F) E) := by
  classical
  intro u hu v hv same
  let additive := (P.fAdditive_of_degreeBound_pos hk).toFAdditiveCode
  have zeroSyndrome : P.quotientSyndrome hk (u - v) = 0 := by rw [map_sub, same, sub_self]
  have enough : P.degreeBound ≤ (Finset.univ \ E).card := by
    rw [Finset.card_sdiff_of_subset (Finset.subset_univ E), Finset.card_univ]
    unfold length at hn small
    omega
  obtain ⟨S, outside, size⟩ := Finset.exists_subset_card_eq enough
  have agreement i (member : i ∈ S) : (u - v) i = (0 : ι → F) i := by
    have notIn := (Finset.mem_sdiff.mp (outside member)).2
    change u i - v i = 0
    rw [hu i notIn, hv i notIn, sub_zero]
  exact sub_eq_zero.mp (P.determinedBy_degreeBound ((quotient_zero_iff additive _).mp zeroSyndrome)
    additive.zero_mem S size agreement)

/-- For every RS domain, an oversized list below or at capacity is
equivalent to a support-intersection certificate when the deletion count
is smaller than the field size. This holds at every positive width. -/
theorem not_vectorListSizeBound_iff_supportIntersection (P : Parameters F ι)
    (hk : 0 < P.degreeBound) (hn : P.degreeBound ≤ P.length) (r B : ℕ)
    (radius : r ≤ P.length - P.degreeBound) (few : (B + 1) * r < Fintype.card F) :
    ¬ (P.vectorBlockCode σ).ListSizeBound r B ↔
      ∃ E : Fin (B + 1) → Finset ι,
        Function.Injective E ∧ (∀ a, (E a).card ≤ r) ∧ escapesDeletions (P.quotientSyndrome hk) E := by
  let additive := (P.fAdditive_of_degreeBound_pos hk).toFAdditiveCode
  exact not_listSizeBound_iff_supportIntersection P.toBlockCode (P.quotientSyndrome hk)
    (quotient_zero_iff additive) (codeSubmodule additive).mkQ_surjective r B
    (fun E small => P.quotientSyndrome_injOn hk hn E (small.trans radius)) few

open CapacityList in
/-- The 128-bit fractional target at every count radius, for any supplied
RS code of length less than `2^127` and any positive interleaving width. -/
theorem fractionalListSizeBoundAt_128_iff_supportIntersection (P : Parameters F ι)
    (hk : 0 < P.degreeBound) (hn : P.degreeBound ≤ P.length) (lengthBound : P.length < 2 ^ 127)
    (fieldBound : 2 ^ 128 ≤ Fintype.card F) (r : ℕ) :
    FractionalListSizeBoundAt (P.vectorBlockCode σ) (relativeRadius (ι := ι) r)
        (1 / 2 ^ 128) (Fintype.card F) ↔
      r ≤ P.length - P.degreeBound ∧
        ¬ ∃ E : Fin (Fintype.card F / 2 ^ 128 + 1) → Finset ι,
          Function.Injective E ∧ (∀ a, (E a).card ≤ r) ∧ escapesDeletions (P.quotientSyndrome hk) E := by
  classical
  let q := Fintype.card F
  let B := q / 2 ^ 128
  have positiveLength : 0 < Fintype.card ι := hk.trans_le hn
  by_cases radius : r ≤ P.length - P.degreeBound
  · have budgetPositive : 0 < B := Nat.div_pos fieldBound (by decide)
    have few : (B + 1) * r < q := by
      calc
        (B + 1) * r ≤ (2 * B) * r := Nat.mul_le_mul_right _ (by omega)
        _ < (2 * B) * 2 ^ 127 := Nat.mul_lt_mul_of_pos_left
          ((radius.trans (Nat.sub_le _ _)).trans_lt lengthBound) (by omega)
        _ = B * 2 ^ 128 := by rw [show (2 : ℕ) ^ 128 = 2 * 2 ^ 127 by decide]; ac_rfl
        _ ≤ q := Nat.div_mul_le_self _ _
    have integerBudget (c : ℕ) : (c : ℝ) ≤ (1 / 2 ^ 128) * q ↔ c ≤ B := by
      rw [one_div, inv_mul_eq_div, le_div_iff₀ (by positivity : (0 : ℝ) < 2 ^ 128)]
      rw [Nat.le_div_iff_mul_le (by decide : 0 < (2 : ℕ) ^ 128)]
      exact_mod_cast (Iff.rfl : c * 2 ^ 128 ≤ q ↔ c * 2 ^ 128 ≤ q)
    have floorIff : FractionalListSizeBoundAt (P.vectorBlockCode σ) (relativeRadius (ι := ι) r)
        (1 / 2 ^ 128) q ↔ (P.vectorBlockCode σ).ListSizeBound r B := by
      unfold FractionalListSizeBoundAt ListSizeBound
      simp only [ballCardAt_relativeRadius_eq_ballCard _ positiveLength, integerBudget]
    rw [floorIff]
    have exactTest := P.not_vectorListSizeBound_iff_supportIntersection (σ := σ) hk hn r B radius few
    simpa only [radius, true_and, not_not] using not_congr exactTest
  · simp only [radius, false_and, iff_false]
    intro safe
    apply P.not_vectorFractionalListSizeBoundAt_nextShell (σ := σ) (ε := 1 / 2 ^ 128)
      (by norm_num) hk positiveLength hn
    exact fractionalListSizeBoundAt_antitone _ _ _ (relativeRadius_mono (by
      change ¬ r ≤ Fintype.card ι - P.degreeBound at radius
      omega)) safe

end ProximityCoding.ReedSolomon.Parameters
