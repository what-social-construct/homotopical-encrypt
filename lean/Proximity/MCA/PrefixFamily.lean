module

public import Proximity.ListDecoding.Capacity
public import Mathlib.Combinatorics.Pigeonhole

@[expose] public section

/-!
# Subfield families with a common locator prefix

Subsets with the same sum of evaluation points have vanishing polynomials
with the same two highest coefficients.  Subtracting their vanishing
polynomials from a reference one gives a family of distinct low-degree
polynomials agreeing with a single received word on their respective subsets.
-/

set_option autoImplicit false

namespace ProximityCoding.ReedSolomon.Parameters

variable {K F ι : Type*} [Field K] [Fintype K] [Field F] [Algebra K F] [Fintype ι]

/-- A large enough sum class of evaluation subsets gives a family sharing the
same received word and with the top two locator terms cancelled. -/
theorem exists_prefixFamily
    (P : Parameters F ι) (x : ι → K)
    (hpoints : ∀ i, P.domain.point i = algebraMap K F (x i))
    {a t : ℕ} (ha : 2 ≤ a)
    (hcount : Fintype.card K * (t - 1) < (Fintype.card ι).choose a) :
    ∃ (received : Word ι F) (f : Fin t → Polynomial F) (S : Fin t → Finset ι),
      Function.Injective f ∧ ∀ j, (S j).card = a ∧ (f j).natDegree ≤ a - 2 ∧
        ∀ i ∈ S j, received i = (f j).eval (P.domain.point i) := by
  classical
  let sets := (Finset.univ : Finset ι).powersetCard a
  let sumSites (A : Finset ι) := ∑ i ∈ A, x i
  have more : (Finset.univ : Finset K).card * (t - 1) < sets.card := by
    simpa only [sets, Finset.card_powersetCard, Finset.card_univ] using hcount
  obtain ⟨sum, _, many⟩ := Finset.exists_lt_card_fiber_of_mul_lt_card_of_maps_to
    (f := sumSites) (fun _ _ => Finset.mem_univ _) more
  let family := sets.filter (fun A => sumSites A = sum)
  have enough : t - 1 < family.card := many
  obtain ⟨reference, inFamily⟩ := Finset.card_pos.mp (by omega : 0 < family.card)
  have embeddingBound : Fintype.card (Fin t) ≤ Fintype.card ↥family := by
    rw [Fintype.card_fin, Fintype.card_coe]
    omega
  obtain ⟨select⟩ := Function.Embedding.nonempty_of_card_le embeddingBound
  let S (j : Fin t) : Finset ι := (select j).val
  let U := P.capacityVanishingPolynomial reference
  let f (j : Fin t) := U - P.capacityVanishingPolynomial (S j)
  have properties {A : Finset ι} (hA : A ∈ family) : A.card = a ∧ sumSites A = sum := by
    obtain ⟨hset, hsum⟩ := Finset.mem_filter.mp hA
    exact ⟨(Finset.mem_powersetCard.mp hset).2, hsum⟩
  have degree {A : Finset ι} (hA : A ∈ family) :
      (P.capacityVanishingPolynomial A).natDegree = a :=
    (P.capacityVanishingPolynomial_natDegree A).trans (properties hA).1
  have firstCoeff {A : Finset ι} (hA : A ∈ family) :
      (P.capacityVanishingPolynomial A).coeff a = 1 := by
    rw [← degree hA]
    exact (Polynomial.monic_prod_X_sub_C P.domain.point A).coeff_natDegree
  have nextCoeff {A : Finset ι} (hA : A ∈ family) :
      (P.capacityVanishingPolynomial A).coeff (a - 1) = -(algebraMap K F sum) := by
    have hsize := (properties hA).1
    have hsum := (properties hA).2
    have nonempty : 0 < A.card := by omega
    rw [← hsize, capacityVanishingPolynomial, Polynomial.prod_X_sub_C_coeff_card_pred _ _ nonempty]
    congr 1
    simp only [hpoints, ← map_sum]
    rw [← hsum]
  refine ⟨fun i => U.eval (P.domain.point i), f, S, ?_, ?_⟩
  · intro j l equal
    have locators : P.capacityVanishingPolynomial (S j) =
        P.capacityVanishingPolynomial (S l) := sub_right_inj.mp equal
    apply select.injective
    apply Subtype.ext
    ext i
    change i ∈ S j ↔ i ∈ S l
    rw [← P.eval_capacityVanishingPolynomial_eq_zero_iff (S j),
      ← P.eval_capacityVanishingPolynomial_eq_zero_iff (S l), locators]
  · intro j
    have hS : S j ∈ family := (select j).property
    refine ⟨(properties hS).1, ?_, ?_⟩
    · apply Polynomial.natDegree_le_iff_coeff_eq_zero.mpr
      intro d hd
      change (U - P.capacityVanishingPolynomial (S j)).coeff d = 0
      rw [Polynomial.coeff_sub]
      change (P.capacityVanishingPolynomial reference).coeff d -
        (P.capacityVanishingPolynomial (S j)).coeff d = 0
      rcases eq_or_lt_of_le (show a - 1 ≤ d by omega) with rfl | hlt
      · rw [nextCoeff inFamily, nextCoeff hS, sub_self]
      · rcases eq_or_lt_of_le (show a ≤ d by omega) with rfl | hgt
        · rw [firstCoeff inFamily, firstCoeff hS, sub_self]
        · rw [Polynomial.coeff_eq_zero_of_natDegree_lt ((degree inFamily).trans_lt hgt),
            Polynomial.coeff_eq_zero_of_natDegree_lt ((degree hS).trans_lt hgt), sub_self]
    · intro i hi
      change U.eval (P.domain.point i) = (U - P.capacityVanishingPolynomial (S j)).eval (P.domain.point i)
      rw [Polynomial.eval_sub, (P.eval_capacityVanishingPolynomial_eq_zero_iff (S j) i).mpr hi,
        sub_zero]

end ProximityCoding.ReedSolomon.Parameters
