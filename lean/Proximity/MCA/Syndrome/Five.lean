module

public import Proximity.MCA.SmallRadius
public import Mathlib.Algebra.Field.ZMod
public import Mathlib.Data.Fin.VecNotation

@[expose] public section

/-!
# Exact radius-one MCA count for four Reed–Solomon sites over `𝔽₅`

The evaluation domain is the entire multiplicative group. The line through
the base `(2, 2, 0, 0)` with direction `(4, 3, 0, 0)` has a bad challenge
at each nonzero field value, witnessed by erasing the site with that value.
-/

set_option autoImplicit false

namespace ProximityCoding.MCA.Syndrome.Five

open BlockCode

local instance : Fact (Nat.Prime 5) := ⟨by decide⟩

/-- The nonzero elements of the field in increasing representative order. -/
def site (i : Fin 4) : ZMod 5 := (i.val + 1 : ℕ)

theorem site_injective : Function.Injective site := by
  have checked : ∀ i j : Fin 4, site i = site j → i = j := by decide
  intro i j h
  exact checked i j h

theorem mem_range_site_iff (γ : ZMod 5) : γ ∈ Set.range site ↔ γ ≠ 0 := by
  change (∃ i : Fin 4, site i = γ) ↔ γ ≠ 0
  revert γ
  decide

def domain : ReedSolomon.SmoothEvaluationDomain (ZMod 5) (Fin 4) where
  point := site
  injective_point := site_injective
  smooth := 4 ∣ Fintype.card (ZMod 5) - 1

theorem domain_smooth : domain.smooth := by
  change 4 ∣ Fintype.card (ZMod 5) - 1
  decide

def parameters : ReedSolomon.Parameters (ZMod 5) (Fin 4) where
  domain := domain.toEvaluationDomain
  degreeBound := 2

def witnessLine : AffineLine (Fin 4) (ZMod 5) where
  base := ![2, 2, 0, 0]
  direction := ![4, 3, 0, 0]

private def linearWord (constant slope : ZMod 5) : Word (Fin 4) (ZMod 5) :=
  fun i => constant + slope * site i

private theorem linearWord_codeword (constant slope : ZMod 5) :
    parameters.Codeword (linearWord constant slope) := by
  refine ⟨Polynomial.C constant + Polynomial.C slope * Polynomial.X, ?_, ?_⟩
  · have linearDegree : (Polynomial.C slope * Polynomial.X).natDegree ≤ 1 := by
      calc
        _ ≤ (Polynomial.C slope).natDegree +
            (Polynomial.X : Polynomial (ZMod 5)).natDegree := Polynomial.natDegree_mul_le
        _ = 1 := by simp
    exact ((Polynomial.natDegree_add_le _ _).trans
      (max_le (by simp) linearDegree)).trans_lt (by decide)
  · intro i
    simp [linearWord, parameters, domain]

private theorem scalar_close (e : Fin 4) :
    parameters.toBlockCode.CloseOnSet (witnessLine.point (site e)) (Finset.univ.erase e) := by
  let constant : Fin 4 → ZMod 5 := ![0, 0, 2, 2]
  let slope : Fin 4 → ZMod 5 := ![0, 0, 2, 1]
  have agrees : ∀ er i : Fin 4, i ≠ er →
      witnessLine.point (site er) i = linearWord (constant er) (slope er) i := by
    decide +revert
  exact ⟨linearWord (constant e) (slope e), linearWord_codeword _ _,
    fun i hi => agrees e i (Finset.mem_erase.mp hi).1⟩

private theorem base_conflict (er : Fin 4) :
    ∃ v : ZMod 5, ∃ a b c : Fin 4,
      a ≠ b ∧ a ≠ er ∧ b ≠ er ∧ c ≠ er ∧
      witnessLine.base a = v ∧ witnessLine.base b = v ∧ witnessLine.base c ≠ v := by
  fin_cases er
  · refine ⟨0, 2, 3, 1, ?_⟩; decide
  · refine ⟨0, 2, 3, 0, ?_⟩; decide
  · refine ⟨2, 0, 1, 3, ?_⟩; decide
  · refine ⟨2, 0, 1, 2, ?_⟩; decide

private theorem pair_not_close (e : Fin 4) :
    ¬ parameters.toBlockCode.PairCloseOnSet witnessLine (Finset.univ.erase e) := by
  rintro ⟨c, valid, agrees⟩
  obtain ⟨v, a, b, d, hab, hae, hbe, hde, hav, hbv, hdv⟩ := base_conflict e
  have agreeBase (i : Fin 4) (hi : i ≠ e) : witnessLine.base i = c i 0 := by
    simpa using congrFun (agrees i (Finset.mem_erase.mpr ⟨hi, Finset.mem_univ i⟩)) (0 : Fin 2)
  have forced : (fun i => c i 0) = linearWord v 0 := by
    apply parameters.determinedBy_degreeBound (valid 0) (linearWord_codeword v 0) {a, b}
    · simp [hab, parameters]
    · intro i hi
      simp only [Finset.mem_insert, Finset.mem_singleton] at hi
      rcases hi with hia | hib
      · rw [hia]
        simpa [linearWord] using (agreeBase a hae).symm.trans hav
      · rw [hib]
        simpa [linearWord] using (agreeBase b hbe).symm.trans hbv
  exact hdv ((agreeBase d hde).trans (by simpa [linearWord] using congrFun forced d))

/-- Every nonzero challenge is bad on the complement of its own site. -/
theorem site_mem_badChallengeSet (e : Fin 4) :
    site e ∈ parameters.toBlockCode.badChallengeSet 1 witnessLine :=
  (parameters.toBlockCode.mem_badChallengeSet 1 witnessLine (site e)).mpr
    ⟨Finset.univ.erase e, ReedSolomon.Parameters.largeAgreementSet_one_erase e,
      scalar_close e, pair_not_close e⟩

private theorem upper_bound (L : AffineLine (Fin 4) (ZMod 5)) :
    (parameters.toBlockCode.badChallengeSet 1 L).card ≤ 4 := by
  have upper := parameters.badChallengeSet_card_le_choose_succ (by decide) (by decide) 1 L
  simpa [parameters] using upper

/-- The witness line has exactly the four challenges labeled by the sites. -/
theorem witnessLine_badChallengeSet :
    parameters.toBlockCode.badChallengeSet 1 witnessLine = Finset.univ.image site := by
  symm
  apply Finset.eq_of_subset_of_card_le
  · intro γ hγ
    obtain ⟨e, _, rfl⟩ := Finset.mem_image.mp hγ
    exact site_mem_badChallengeSet e
  · rw [Finset.card_image_of_injective _ site_injective, Finset.card_univ, Fintype.card_fin]
    exact upper_bound witnessLine

/-- The compressed-certificate bound is attained at count radius one. -/
theorem worstBadCount_one_eq_four : parameters.toBlockCode.worstBadCount 1 = 4 := by
  apply le_antisymm
  · exact (parameters.toBlockCode.worstBadCount_le_iff 1 4).mpr upper_bound
  · have lower := parameters.toBlockCode.badChallengeSet_card_le_worstBadCount 1 witnessLine
    rwa [witnessLine_badChallengeSet, Finset.card_image_of_injective _ site_injective,
      Finset.card_univ, Fintype.card_fin] at lower

end ProximityCoding.MCA.Syndrome.Five
