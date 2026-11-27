module

public import Proximity.MCA.Definitions
public import Mathlib.LinearAlgebra.Pi

@[expose] public section

/-!
# Same-set agreement in syndrome coordinates

A word agrees with a codeword outside `E` exactly when its syndrome can
be produced by an error supported in `E`. The same support must work for
both components of an interleaved word.
-/

namespace ProximityCoding.BlockCode.Syndrome

variable {ι F V : Type*} [Field F] [AddCommGroup V] [Module F V]

/-- Words vanishing outside the specified set of coordinates. -/
def supportedWords (E : Finset ι) : Submodule F (ι → F) where
  carrier := {w | ∀ i, i ∉ E → w i = 0}
  zero_mem' := by simp
  add_mem' := by
    intro a b ha hb i hi
    simp [Pi.add_apply, ha i hi, hb i hi]
  smul_mem' := by
    intro a w hw i hi
    simp [Pi.smul_apply, hw i hi]

/-- Syndromes attained by errors supported in `E`. -/
def errorSyndromes (H : (ι → F) →ₗ[F] V) (E : Finset ι) : Submodule F V :=
  (supportedWords E).map H

theorem mem_errorSyndromes (H : (ι → F) →ₗ[F] V) (E : Finset ι) (y : V) :
    y ∈ errorSyndromes H E ↔
      ∃ e : ι → F, (∀ i, i ∉ E → e i = 0) ∧ H e = y :=
  Iff.rfl

variable [Fintype ι] [DecidableEq ι]

/-- The supported error syndromes are the span of the parity-check columns in `E`. -/
theorem errorSyndromes_eq_span (H : (ι → F) →ₗ[F] V) (E : Finset ι) :
    errorSyndromes H E =
      Submodule.span F (Set.range fun i : {i // i ∈ E} => H (Pi.single i.val 1)) := by
  apply le_antisymm
  · intro y hy
    obtain ⟨e, he, rfl⟩ := (mem_errorSyndromes H E y).mp hy
    rw [← LinearMap.sum_single_apply (fun _ : ι => F) e, map_sum]
    apply Submodule.sum_mem
    intro i _
    by_cases hi : i ∈ E
    · have column : H (Pi.single i 1) ∈
          Submodule.span F
            (Set.range fun j : {j // j ∈ E} => H (Pi.single j.val 1)) :=
        Submodule.subset_span ⟨⟨i, hi⟩, rfl⟩
      have scaled : Pi.single i (e i) = e i • (Pi.single i 1 : ι → F) := by
        simpa only [smul_eq_mul, mul_one] using Pi.single_smul' i (e i) (1 : F)
      rw [scaled, map_smul]
      exact Submodule.smul_mem _ _ column
    · simp [he i hi]
  · apply Submodule.span_le.mpr
    rintro _ ⟨i, rfl⟩
    refine (mem_errorSyndromes H E _).mpr ⟨Pi.single i.val 1, ?_, rfl⟩
    intro j hj
    have different : j ≠ i.val := fun h => hj (h.symm ▸ i.property)
    exact Pi.single_eq_of_ne different 1

/-- Agreement outside `E` is equivalent to its syndrome lying in the error space for `E`. -/
theorem closeOnSet_iff
    (C : BlockCode ι F) (H : (ι → F) →ₗ[F] V)
    (hker : ∀ w : Word ι F, H w = 0 ↔ C.Codeword w)
    (w : Word ι F) (E : Finset ι) :
    C.CloseOnSet w (Finset.univ \ E) ↔ H w ∈ errorSyndromes H E := by
  rw [mem_errorSyndromes]
  constructor
  · rintro ⟨c, hc, agrees⟩
    refine ⟨w - c, ?_, ?_⟩
    · intro i hi
      have same := agrees i (Finset.mem_sdiff.mpr ⟨Finset.mem_univ i, hi⟩)
      simp [Pi.sub_apply, same]
    · rw [map_sub, (hker c).mpr hc, sub_zero]
  · rintro ⟨e, supported, syndrome⟩
    refine ⟨w - e, (hker (w - e)).mp ?_, ?_⟩
    · rw [map_sub, syndrome, sub_self]
    · intro i hi
      rw [Pi.sub_apply, supported i (Finset.mem_sdiff.mp hi).2, sub_zero]

/-- Base and direction must both lie in the error syndrome space for the same `E`. -/
theorem pairCloseOnSet_iff
    (C : BlockCode ι F) (H : (ι → F) →ₗ[F] V)
    (hker : ∀ w : Word ι F, H w = 0 ↔ C.Codeword w)
    (L : AffineLine ι F) (E : Finset ι) :
    C.PairCloseOnSet L (Finset.univ \ E) ↔
      H L.base ∈ errorSyndromes H E ∧ H L.direction ∈ errorSyndromes H E := by
  rw [BlockCode.pairCloseOnSet_iff, ← closeOnSet_iff C H hker L.base E,
    ← closeOnSet_iff C H hker L.direction E]
  constructor
  · rintro ⟨c, hc, agrees⟩
    refine ⟨⟨fun i => c i 0, hc 0, ?_⟩, ⟨fun i => c i 1, hc 1, ?_⟩⟩
    · intro i hi
      simpa only [pairWord_zero] using congrFun (agrees i hi) 0
    · intro i hi
      simpa only [pairWord_one] using congrFun (agrees i hi) 1
  · rintro ⟨⟨cb, hcb, hb⟩, ⟨cd, hcd, hd⟩⟩
    let c : PlaneWord ι F := fun i j => if j = 0 then cb i else cd i
    refine ⟨c, ?_, ?_⟩
    · intro j
      fin_cases j
      · simpa [c] using hcb
      · simpa [c] using hcd
    · intro i hi
      funext j
      fin_cases j
      · simpa [c] using hb i hi
      · simpa [c] using hd i hi

/-- A same-set failure is an affine syndrome in the error space with a component outside it. -/
theorem badOnSet_iff
    (C : BlockCode ι F) (H : (ι → F) →ₗ[F] V)
    (hker : ∀ w : Word ι F, H w = 0 ↔ C.Codeword w)
    (L : AffineLine ι F) (γ : F) (E : Finset ι) :
    C.BadOnSet L γ (Finset.univ \ E) ↔
      H L.base + γ • H L.direction ∈ errorSyndromes H E ∧
        ¬ (H L.base ∈ errorSyndromes H E ∧ H L.direction ∈ errorSyndromes H E) := by
  have point : L.point γ = L.base + γ • L.direction := rfl
  rw [BlockCode.BadOnSet, pairCloseOnSet_iff C H hker, closeOnSet_iff C H hker,
    point, map_add, map_smul]

/-- The bad challenge set is exactly the union over error supports of count at most `r`. -/
theorem mem_badChallengeSet_iff [Fintype F]
    (C : BlockCode ι F) (H : (ι → F) →ₗ[F] V)
    (hker : ∀ w : Word ι F, H w = 0 ↔ C.Codeword w)
    (r : ℕ) (L : AffineLine ι F) (γ : F) :
    γ ∈ C.badChallengeSet r L ↔
      ∃ E : Finset ι, E.card ≤ r ∧
        H L.base + γ • H L.direction ∈ errorSyndromes H E ∧
          ¬ (H L.base ∈ errorSyndromes H E ∧ H L.direction ∈ errorSyndromes H E) := by
  have card_complement (S : Finset ι) :
      (Finset.univ \ S).card + S.card = Fintype.card ι :=
    (Finset.card_sdiff_add_card_eq_card (Finset.subset_univ S)).trans Finset.card_univ
  rw [BlockCode.mem_badChallengeSet]
  constructor
  · rintro ⟨S, large, bad⟩
    refine ⟨Finset.univ \ S, ?_, ?_⟩
    · have hcard := card_complement S
      unfold LargeAgreementSet at large
      omega
    · apply (badOnSet_iff C H hker L γ (Finset.univ \ S)).mp
      have complement : Finset.univ \ (Finset.univ \ S) = S := by
        ext i
        simp
      rwa [complement]
  · rintro ⟨E, small, bad⟩
    refine ⟨Finset.univ \ E, ?_, (badOnSet_iff C H hker L γ E).mpr bad⟩
    have hcard := card_complement E
    unfold LargeAgreementSet
    omega

end ProximityCoding.BlockCode.Syndrome
