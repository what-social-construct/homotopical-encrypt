module

public import Proximity.MCA.Syndrome
public import Mathlib.Data.Fintype.EquivFin

@[expose] public section

/-!
# Exact error supports and list bounds

Below the minimum distance, the syndrome determines the error on each
given support. An interleaved list can therefore be counted by the exact
supports realizing one tuple of component syndromes.
-/

set_option autoImplicit false

namespace ProximityCoding.BlockCode.Syndrome

variable {ι F V σ : Type*} [Field F] [AddCommGroup V] [Module F V]
variable [Fintype ι] [DecidableEq ι]

/-- The component syndromes are supported in `E`, and deleting any site
would exclude at least one component. -/
def exactErrorSupport (H : (ι → F) →ₗ[F] V) (E : Finset ι) (s : σ → V) : Prop :=
  (∀ j, s j ∈ errorSyndromes H E) ∧
    ∀ i ∈ E, ∃ j, s j ∉ errorSyndromes H (E.erase i)

private noncomputable def errorSupport (e : σ → ι → F) : Finset ι := by
  classical
  exact Finset.univ.filter fun i => ∃ j, e j i ≠ 0

omit [DecidableEq ι] in
private theorem mem_errorSupport (e : σ → ι → F) (i : ι) :
    i ∈ errorSupport e ↔ ∃ j, e j i ≠ 0 := by
  classical
  simp [errorSupport]

private theorem exactErrorSupport_iff_exists
    (H : (ι → F) →ₗ[F] V) (E : Finset ι) (s : σ → V)
    (unique : Set.InjOn H ↑(supportedWords (F := F) E)) :
    exactErrorSupport H E s ↔
      ∃ e : σ → ι → F, errorSupport e = E ∧ ∀ j, H (e j) = s j := by
  classical
  constructor
  · rintro ⟨available, exactness⟩
    choose e he using fun j => (mem_errorSyndromes H E (s j)).mp (available j)
    refine ⟨e, Finset.Subset.antisymm ?_ ?_, fun j => (he j).2⟩
    · intro i member
      obtain ⟨j, hj⟩ := (mem_errorSupport e i).mp member
      exact by_contra fun missing => hj ((he j).1 i missing)
    · intro i member
      obtain ⟨j, hj⟩ := exactness i member
      apply (mem_errorSupport e i).mpr
      refine ⟨j, fun zero => hj ((mem_errorSyndromes H _ _).mpr ⟨e j, ?_, (he j).2⟩)⟩
      intro z missing
      by_cases equal : z = i
      · simpa [equal] using zero
      · exact (he j).1 z fun hz => missing (Finset.mem_erase.mpr ⟨equal, hz⟩)
  · rintro ⟨e, support, syndrome⟩
    have supported (j : σ) : e j ∈ supportedWords E := by
      intro i missing
      by_contra nonzero
      apply missing
      rw [← support]
      exact (mem_errorSupport e i).mpr ⟨j, nonzero⟩
    refine ⟨fun j => (mem_errorSyndromes H E _).mpr ⟨e j, supported j, syndrome j⟩, ?_⟩
    intro i member
    rw [← support] at member
    obtain ⟨j, nonzero⟩ := (mem_errorSupport e i).mp member
    refine ⟨j, ?_⟩
    intro smaller
    obtain ⟨d, hd, image⟩ := (mem_errorSyndromes H (E.erase i) _).mp smaller
    have dSupported : d ∈ supportedWords E := by
      intro z missing
      exact hd z fun hz => missing (Finset.mem_erase.mp hz).2
    have same := unique (supported j) dSupported ((syndrome j).trans image.symm)
    exact nonzero (congrFun same i |>.trans (hd i (Finset.notMem_erase i E)))

omit [DecidableEq ι] in
private theorem errorSupport_card_sub [DecidableEq F] [Fintype σ]
    (w c : Word ι (σ → F)) :
    (errorSupport (fun j i => w i j - c i j)).card = hammingDistance c w := by
  classical
  unfold hammingDistance
  congr 1
  ext i
  rw [mem_errorSupport]
  simp only [Finset.mem_filter, Finset.mem_univ, true_and]
  simp [sub_ne_zero, funext_iff, ne_comm]

/-- An oversized interleaved ball is equivalent to a tuple of component
syndromes with more exact low-weight supports than the list budget. -/
theorem exists_list_violation_iff_exactSupports
    [Fintype F] [DecidableEq F] [Fintype σ]
    (C : BlockCode ι F) (H : (ι → F) →ₗ[F] V)
    (hker : ∀ w : Word ι F, H w = 0 ↔ C.Codeword w)
    (onto : Function.Surjective H) (r B : ℕ)
    (unique : ∀ E : Finset ι, E.card ≤ r → Set.InjOn H ↑(supportedWords (F := F) E)) :
    ¬ (C.interleaved σ).ListSizeBound r B ↔
      ∃ (s : σ → V) (E : Fin (B + 1) → Finset ι), Function.Injective E ∧
        ∀ a, (E a).card ≤ r ∧ exactErrorSupport H (E a) s := by
  classical
  constructor
  · intro notBounded
    obtain ⟨w, hw⟩ := not_forall.mp notBounded
    let ball := {c // c ∈ (C.interleaved σ).Ball r w}
    let : Fintype ball := Fintype.ofFinite _
    have enough : Fintype.card (Fin (B + 1)) ≤ Fintype.card ball := by
      rw [Fintype.card_fin, ← Nat.card_eq_fintype_card]
      exact Nat.succ_le_of_lt (lt_of_not_ge hw)
    obtain ⟨select⟩ := Function.Embedding.nonempty_of_card_le enough
    let e (a : Fin (B + 1)) (j : σ) (i : ι) : F := w i j - (select a).val i j
    let E (a : Fin (B + 1)) := errorSupport (e a)
    have small (a : Fin (B + 1)) : (E a).card ≤ r :=
      (errorSupport_card_sub w (select a).val).trans_le (select a).property.2
    have syndrome (a : Fin (B + 1)) (j : σ) : H (e a j) = H (fun i => w i j) := by
      change H ((fun i => w i j) - (fun i => (select a).val i j)) = _
      rw [map_sub, (hker _).mpr ((select a).property.1 j), sub_zero]
    have supported (a : Fin (B + 1)) (j : σ) : e a j ∈ supportedWords (E a) := by
      intro i missing
      by_contra nonzero
      exact missing ((mem_errorSupport (e a) i).mpr ⟨j, nonzero⟩)
    refine ⟨fun j => H (fun i => w i j), E, ?_, fun a => ⟨small a, ?_⟩⟩
    · intro a b same
      apply select.injective
      apply Subtype.ext
      funext i j
      have bSupported : e b j ∈ supportedWords (E a) := same.symm ▸ supported b j
      have equal := unique (E a) (small a) (supported a j) bSupported
        ((syndrome a j).trans (syndrome b j).symm)
      exact sub_right_injective (congrFun equal i)
    · exact (exactErrorSupport_iff_exists H _ _ (unique _ (small a))).mpr
        ⟨e a, rfl, syndrome a⟩
  · rintro ⟨s, E, distinct, valid⟩ bounded
    choose w hw using fun j => onto (s j)
    have realizations (a : Fin (B + 1)) :=
      (exactErrorSupport_iff_exists H (E a) s (unique (E a) (valid a).1)).mp (valid a).2
    choose e supports syndromes using realizations
    let center : Word ι (σ → F) := fun i j => w j i
    let c (a : Fin (B + 1)) : Word ι (σ → F) := fun i j => w j i - e a j i
    have errors (a : Fin (B + 1)) : (fun j i => center i j - c a i j) = e a := by
      funext j i
      simp [center, c]
    let candidate (a : Fin (B + 1)) : {d // d ∈ (C.interleaved σ).Ball r center} := by
      refine ⟨c a, ?_, ?_⟩
      · intro j
        apply (hker _).mp
        change H (w j - e a j) = 0
        rw [map_sub, hw j, syndromes a j, sub_self]
      · rw [← errorSupport_card_sub, errors, supports]
        exact (valid a).1
    have hinjective : Function.Injective candidate := by
      intro a b same
      have words : c a = c b := congrArg Subtype.val same
      apply distinct
      rw [← supports a, ← supports b, ← errors a, ← errors b, words]
    have exceeds := (Nat.card_le_card_of_injective candidate hinjective).trans (bounded center)
    rw [Nat.card_fin] at exceeds
    omega

end ProximityCoding.BlockCode.Syndrome
