module

public import Proximity.ListDecoding.Capacity
public import Proximity.MCA.Pair

@[expose] public section

/-!
# Locator identities at the first support-packing boundary

Equal-size monic locators have differences of lower degree. Proportionality
on the sites of a third locator therefore determines a polynomial identity.
At the minimum distance, a codeword polynomial is a scalar multiple of the
locator of its clean sites.
Four or more disjoint bad supports at the first packing boundary give
collinear locator polynomials by comparing overlapping triples of hits.
-/

set_option autoImplicit false

namespace ProximityCoding.ReedSolomon.Parameters

open BlockCode Polynomial

variable {F ι : Type*} [Field F] [Fintype ι]

/-- Proportional evaluations on an equal-size support determine proportional
locator differences by cancellation of their leading monic terms. -/
theorem locator_sub_eq_smul_sub_of_proportional_evals
    (P : Parameters F ι) {A B E : Finset ι} (nonempty : E.Nonempty)
    (cardA : A.card = E.card) (cardB : B.card = E.card) (c : F)
    (proportional : ∀ i ∈ E,
      (P.capacityVanishingPolynomial A).eval (P.domain.point i) =
        c * (P.capacityVanishingPolynomial B).eval (P.domain.point i)) :
    P.capacityVanishingPolynomial A - P.capacityVanishingPolynomial E =
      c • (P.capacityVanishingPolynomial B - P.capacityVanishingPolynomial E) := by
  let g := P.capacityVanishingPolynomial
  have monic (S : Finset ι) (sameSize : S.card = E.card) :
      IsMonicOfDegree (g S) E.card :=
    ⟨(P.capacityVanishingPolynomial_natDegree S).trans sameSize,
      monic_prod_X_sub_C P.domain.point S⟩
  have sizePositive := (Finset.card_pos.mpr nonempty).ne'
  have leftDegree := (monic A cardA).natDegree_sub_lt sizePositive (monic E rfl)
  have rightDegree := (natDegree_smul_le c (g B - g E)).trans_lt
    ((monic B cardB).natDegree_sub_lt sizePositive (monic E rfl))
  apply eq_of_degrees_lt_of_eval_index_eq E P.domain.injective_point.injOn
  · exact degree_le_natDegree.trans_lt (WithBot.coe_lt_coe.mpr leftDegree)
  · exact degree_le_natDegree.trans_lt (WithBot.coe_lt_coe.mpr rightDegree)
  · intro i hi
    have vanishes : (P.capacityVanishingPolynomial E).eval (P.domain.point i) = 0 :=
      (P.eval_capacityVanishingPolynomial_eq_zero_iff E i).mpr hi
    simp only [eval_sub, eval_smul, vanishes, sub_zero, smul_eq_mul]
    exact proportional i hi

/-- A polynomial vanishing on as many designated sites as its degree bound
is its leading coefficient times the locator of those sites. -/
theorem eq_C_mul_locator_of_vanishes (P : Parameters F ι) (S : Finset ι) (f : Polynomial F)
    (degreeBound : f.natDegree ≤ S.card)
    (vanishes : ∀ i ∈ S, f.eval (P.domain.point i) = 0) :
    f = C f.leadingCoeff * P.capacityVanishingPolynomial S := by
  by_cases hf : f = 0
  · simp [hf]
  let g := P.capacityVanishingPolynomial S
  have gMonic : g.Monic := monic_prod_X_sub_C P.domain.point S
  have degree : f.natDegree = S.card := by
    refine le_antisymm degreeBound ?_
    by_contra! tooSmall
    apply hf
    apply eq_of_degrees_lt_of_eval_index_eq S P.domain.injective_point.injOn
    · exact f.degree_le_natDegree.trans_lt (WithBot.coe_lt_coe.mpr tooSmall)
    · simp
    · intro i hi
      simpa using vanishes i hi
  let multiple := C f.leadingCoeff * g
  have leadingNonzero : f.leadingCoeff ≠ 0 := leadingCoeff_ne_zero.mpr hf
  have multipleNonzero : multiple ≠ 0 := mul_ne_zero (C_ne_zero.mpr leadingNonzero) gMonic.ne_zero
  have degreesEqual : f.degree = multiple.degree := by
    rw [degree_eq_natDegree hf, degree_eq_natDegree multipleNonzero]
    change (f.natDegree : WithBot ℕ) = ((C f.leadingCoeff * g).natDegree : WithBot ℕ)
    rw [natDegree_C_mul leadingNonzero, degree, P.capacityVanishingPolynomial_natDegree]
  have leadingEqual : f.leadingCoeff = multiple.leadingCoeff := by
    change f.leadingCoeff = (C f.leadingCoeff * g).leadingCoeff
    rw [leadingCoeff_C_mul_of_isUnit (isUnit_iff_ne_zero.mpr leadingNonzero), gMonic.leadingCoeff, mul_one]
  apply sub_eq_zero.mp
  apply eq_of_degrees_lt_of_eval_index_eq S P.domain.injective_point.injOn
  · exact (degree_sub_lt_left degreesEqual hf leadingEqual).trans_le
      (f.degree_le_natDegree.trans (WithBot.coe_le_coe.mpr degreeBound))
  · simp
  · intro i hi
    have locatorZero := (P.eval_capacityVanishingPolynomial_eq_zero_iff S i).mpr hi
    simp only [eval_sub, eval_mul, eval_C, eval_zero, vanishes i hi, locatorZero, mul_zero, sub_zero]

variable [DecidableEq ι]

private theorem locator_sdiff_factor (P : Parameters F ι) {U V : Finset ι}
    (disjoint : Disjoint U V) :
    P.capacityVanishingPolynomial (Finset.univ \ U) =
      P.capacityVanishingPolynomial (Finset.univ \ (U ∪ V)) * P.capacityVanishingPolynomial V := by
  have split : Finset.univ \ U = Finset.univ \ (U ∪ V) ∪ V := by
    rw [← Finset.sdiff_sdiff_eq_sdiff_union (Finset.subset_univ V),
      Finset.union_sdiff_cancel_right disjoint]
  have outside : Disjoint (Finset.univ \ (U ∪ V)) V := by
    exact Finset.disjoint_left.mpr fun i hi hv =>
      (Finset.mem_sdiff.mp hi).2 (Finset.mem_union_right _ hv)
  calc
    _ = P.capacityVanishingPolynomial (Finset.univ \ (U ∪ V) ∪ V) :=
      congrArg P.capacityVanishingPolynomial split
    _ = _ := by simp only [capacityVanishingPolynomial, Finset.prod_union outside]

/-- Two bounded-degree relations on overlapping support triples determine
proportional locator differences on an anchor in their common support.
The first relation uses the support `S ∪ A` and the second uses `S ∪ B`. -/
theorem locator_sub_eq_smul_sub_of_overlapping_relations
    (P : Parameters F ι) {S A B E : Finset ι}
    (nonempty : E.Nonempty) (anchor : E ⊆ S)
    (disjointSA : Disjoint S A) (disjointSB : Disjoint S B) (disjointAB : Disjoint A B)
    (cardA : A.card = E.card) (cardB : B.card = E.card)
    (fA fB : Polynomial F) (nonzeroB : fB ≠ 0) (c : F)
    (degreeA : fA.natDegree ≤ (Finset.univ \ (S ∪ A)).card)
    (degreeB : fB.natDegree ≤ (Finset.univ \ (S ∪ B)).card)
    (outsideA : ∀ i ∉ S ∪ A, fA.eval (P.domain.point i) = 0)
    (outsideB : ∀ i ∉ S ∪ B, fB.eval (P.domain.point i) = 0)
    (proportional : ∀ i ∈ E, fB.eval (P.domain.point i) = c * fA.eval (P.domain.point i)) :
    P.capacityVanishingPolynomial A - P.capacityVanishingPolynomial E =
      (c * fA.leadingCoeff / fB.leadingCoeff) •
        (P.capacityVanishingPolynomial B - P.capacityVanishingPolynomial E) := by
  let clean := Finset.univ \ (S ∪ A ∪ B)
  let g := P.capacityVanishingPolynomial
  have factorA : fA = C fA.leadingCoeff * (g clean * g B) := by
    exact (P.eq_C_mul_locator_of_vanishes _ fA degreeA
      (fun i hi => outsideA i (Finset.mem_sdiff.mp hi).2)).trans
      (congrArg (C fA.leadingCoeff * ·) (P.locator_sdiff_factor
        (Finset.disjoint_union_left.mpr ⟨disjointSB, disjointAB⟩)))
  have factorB : fB = C fB.leadingCoeff * (g clean * g A) := by
    have splitB := P.locator_sdiff_factor (Finset.disjoint_union_left.mpr ⟨disjointSA, disjointAB.symm⟩)
    rw [Finset.union_right_comm S B A] at splitB
    exact (P.eq_C_mul_locator_of_vanishes _ fB degreeB
      (fun i hi => outsideB i (Finset.mem_sdiff.mp hi).2)).trans (congrArg (C fB.leadingCoeff * ·) splitB)
  apply P.locator_sub_eq_smul_sub_of_proportional_evals nonempty cardA cardB
  intro i hi
  let x := P.domain.point i
  have cleanValue : (g clean).eval x ≠ 0 := by
    intro zero
    have member := (P.eval_capacityVanishingPolynomial_eq_zero_iff clean i).mp zero
    exact (Finset.mem_sdiff.mp member).2 (Finset.mem_union_left _ (Finset.mem_union_left _ (anchor hi)))
  have evalA := congrArg (eval x) factorA
  have evalB := congrArg (eval x) factorB
  simp only [eval_mul, eval_C] at evalA evalB
  have key : fB.leadingCoeff * (g A).eval x = c * fA.leadingCoeff * (g B).eval x := by
    apply mul_right_cancel₀ cleanValue
    calc
      _ = fB.eval x := by rw [evalB]; ring
      _ = c * fA.eval x := proportional i hi
      _ = _ := by rw [evalA]; ring
  change (g A).eval x = (c * fA.leadingCoeff / fB.leadingCoeff) * (g B).eval x
  rw [div_mul_eq_mul_div]
  exact (eq_div_iff (leadingCoeff_ne_zero.mpr nonzeroB)).2 ((mul_comm _ _).trans key)

/-- At the first packing boundary, four disjoint bad supports force the
exchanged locators to be proportional relative to the first anchor locator. -/
theorem exists_locator_difference_relation_of_four_badSupports
    (P : Parameters F ι) (degreePositive : 0 < P.degreeBound) {r : ℕ} (positive : 0 < r)
    (border : P.degreeBound + 3 * r = Fintype.card ι + 1) (L : AffineLine ι F)
    (γ : Fin 4 → F) (E : Fin 4 → Finset ι) (injective : Function.Injective γ)
    (disjoint : Pairwise (fun i j => Disjoint (E i) (E j)))
    (size : ∀ a, (E a).card = r)
    (bad : ∀ a, P.toBlockCode.BadOnSet L (γ a) (Finset.univ \ E a)) :
    ∃ c : F, P.capacityVanishingPolynomial (E 2) - P.capacityVanishingPolynomial (E 0) =
      c • (P.capacityVanishingPolynomial (E 3) - P.capacityVanishingPolynomial (E 0)) := by
  classical
  have witnesses (a : Fin 4) : ∃ p : Polynomial F, p.natDegree < P.degreeBound ∧
      ∀ i ∉ E a, p.eval (P.domain.point i) = (L.point (γ a)) i := by
    obtain ⟨w, ⟨p, hp, evaluation⟩, agrees⟩ := (bad a).1
    exact ⟨p, hp, fun i hi => (evaluation i).symm.trans
      (agrees i (Finset.mem_sdiff.mpr ⟨Finset.mem_univ i, hi⟩)).symm⟩
  choose f bound fit using witnesses
  let relation (a : Fin 4) :=
    (γ 1 - γ a) • f 0 + (γ a - γ 0) • f 1 - (γ 1 - γ 0) • f a
  have degree (a : Fin 4) : (relation a).natDegree < P.degreeBound := by
    exact (natDegree_sub_le _ _).trans_lt (max_lt
      ((natDegree_add_le _ _).trans_lt (max_lt
        ((natDegree_smul_le _ _).trans_lt (bound 0)) ((natDegree_smul_le _ _).trans_lt (bound 1))))
      ((natDegree_smul_le _ _).trans_lt (bound a)))
  have evalRelation (a : Fin 4) (i : ι) : (relation a).eval (P.domain.point i) =
      (γ 1 - γ a) * ((f 0).eval (P.domain.point i) - (L.point (γ 0)) i) +
      (γ a - γ 0) * ((f 1).eval (P.domain.point i) - (L.point (γ 1)) i) -
      (γ 1 - γ 0) * ((f a).eval (P.domain.point i) - (L.point (γ a)) i) := by
    simp only [relation, eval_sub, eval_add, eval_smul, smul_eq_mul, AffineLine.point_apply]
    ring
  have zeroOutside (a : Fin 4) (i : ι)
      (hi : i ∉ (E 0 ∪ E 1) ∪ E a) : (relation a).eval (P.domain.point i) = 0 := by
    simp only [Finset.mem_union, not_or] at hi
    simp only [evalRelation, fit 0 i hi.1.1, fit 1 i hi.1.2, fit a i hi.2, sub_self,
      mul_zero, add_zero]
  have out {a b : Fin 4} (distinct : a ≠ b) {i : ι} (member : i ∈ E a) : i ∉ E b :=
    fun other => Finset.disjoint_left.mp (disjoint distinct) member other
  have onAnchor (a : Fin 4) (a0 : 0 ≠ a) (i : ι) (hi : i ∈ E 0) :
      (relation a).eval (P.domain.point i) =
        (γ 1 - γ a) * ((f 0).eval (P.domain.point i) - (L.point (γ 0)) i) := by
    simp only [evalRelation, fit 1 i (out (by decide : (0 : Fin 4) ≠ 1) hi),
      fit a i (out a0 hi), sub_self, mul_zero, add_zero, sub_zero]
  have nonzero : relation 3 ≠ 0 := by
    intro hzero
    have agreesEverywhere (i : ι) : (f 1).eval (P.domain.point i) = (L.point (γ 1)) i := by
      by_cases hi : i ∈ E 1
      · have evaluation := evalRelation 3 i
        simp only [hzero, eval_zero, fit 0 i (out (by decide : (1 : Fin 4) ≠ 0) hi),
          fit 3 i (out (by decide : (1 : Fin 4) ≠ 3) hi), sub_self, mul_zero, zero_add,
          sub_zero] at evaluation
        exact sub_eq_zero.mp ((mul_eq_zero.mp evaluation.symm).resolve_left
          (sub_ne_zero.mpr (injective.ne (by decide : (3 : Fin 4) ≠ 0))))
      · exact fit 1 i hi
    have close : P.toBlockCode.CloseOnSet (L.point (γ 1)) (Finset.univ \ E 0) :=
      ⟨fun i => (f 1).eval (P.domain.point i), ⟨f 1, bound 1, fun _ => rfl⟩,
        fun i _ => (agreesEverywhere i).symm⟩
    exact (bad 0).2 (P.pairCloseOnSet_of_closeOnSet_two_challenges degreePositive L
      (injective.ne (by decide : (0 : Fin 4) ≠ 1)) _ (bad 0).1 close)
  let S := E 0 ∪ E 1
  have separated (a : Fin 4) (a0 : 0 ≠ a) (a1 : 1 ≠ a) : Disjoint S (E a) :=
    Finset.disjoint_union_left.mpr ⟨disjoint a0, disjoint a1⟩
  have degreeFits (a : Fin 4) (a0 : 0 ≠ a) (a1 : 1 ≠ a) :
      (relation a).natDegree ≤ (Finset.univ \ (S ∪ E a)).card := by
    have rootCount : (S ∪ E a).card = 3 * r := by
      rw [Finset.card_union_of_disjoint (separated a a0 a1),
        show S.card = (E 0).card + (E 1).card from
          Finset.card_union_of_disjoint (disjoint (by decide : (0 : Fin 4) ≠ 1)),
        size, size, size]
      omega
    rw [Finset.card_sdiff_of_subset (Finset.subset_univ _), Finset.card_univ, rootCount]
    have relationDegree := degree a
    omega
  let c := (γ 1 - γ 3) / (γ 1 - γ 2)
  have proportional (i : ι) (hi : i ∈ E 0) :
      (relation 3).eval (P.domain.point i) = c * (relation 2).eval (P.domain.point i) := by
    rw [onAnchor 3 (by decide) i hi, onAnchor 2 (by decide) i hi]
    have denominator : γ 1 - γ 2 ≠ 0 := sub_ne_zero.mpr
      (injective.ne (by decide : (1 : Fin 4) ≠ 2))
    dsimp only [c]
    field_simp
  refine ⟨c * (relation 2).leadingCoeff / (relation 3).leadingCoeff, ?_⟩
  exact P.locator_sub_eq_smul_sub_of_overlapping_relations
    (Finset.card_pos.mp (by rw [size]; exact positive)) Finset.subset_union_left
    (separated 2 (by decide) (by decide)) (separated 3 (by decide) (by decide))
    (disjoint (by decide : (2 : Fin 4) ≠ 3)) (by rw [size, size]) (by rw [size, size])
    (relation 2) (relation 3) nonzero c (degreeFits 2 (by decide) (by decide))
    (degreeFits 3 (by decide) (by decide)) (zeroOutside 2) (zeroOutside 3) proportional


/-- Four or more disjoint bad supports at the first packing boundary
force their monic locators to lie in one affine line. -/
theorem exists_locator_collinearity_of_disjoint_badSupports
    {α : Type*} [Fintype α] (P : Parameters F ι)
    (degreePositive : 0 < P.degreeBound) {r : ℕ} (positive : 0 < r)
    (border : P.degreeBound + 3 * r = Fintype.card ι + 1)
    (many : 4 ≤ Fintype.card α) (L : AffineLine ι F)
    (γ : α → F) (E : α → Finset ι) (injective : Function.Injective γ)
    (disjoint : Pairwise (fun i j => Disjoint (E i) (E j)))
    (size : ∀ i, (E i).card = r)
    (bad : ∀ i, P.toBlockCode.BadOnSet L (γ i) (Finset.univ \ E i))
    {a b : α} (ab : a ≠ b) :
    ∃ c : α → F, ∀ i, P.capacityVanishingPolynomial (E i) - P.capacityVanishingPolynomial (E a) =
      c i • (P.capacityVanishingPolynomial (E b) - P.capacityVanishingPolynomial (E a)) := by
  classical
  have fromAnchor (i : α) : ∃ c : F,
      P.capacityVanishingPolynomial (E i) - P.capacityVanishingPolynomial (E a) =
        c • (P.capacityVanishingPolynomial (E b) - P.capacityVanishingPolynomial (E a)) := by
    by_cases ai : i = a
    · subst i
      exact ⟨0, by simp⟩
    by_cases bi : i = b
    · subst i
      exact ⟨1, by simp⟩
    let used : Finset α := {i, a, b}
    have usedCard : used.card = 3 := by
      simp [used, ai, bi, ab]
    have remains : (Finset.univ \ used).Nonempty := by
      apply Finset.card_pos.mp
      rw [Finset.card_sdiff_of_subset (Finset.subset_univ _), Finset.card_univ, usedCard]
      omega
    obtain ⟨j, jmem⟩ := remains
    have outside : j ≠ i ∧ j ≠ a ∧ j ≠ b := by
      simpa [used] using (Finset.mem_sdiff.mp jmem).2
    let select : Fin 4 → α := ![a, j, i, b]
    have injectiveSelect : Function.Injective select := by
      intro x y same
      fin_cases x <;> fin_cases y <;> simp_all [select, ne_comm]
    obtain ⟨c, relation⟩ := P.exists_locator_difference_relation_of_four_badSupports
      degreePositive positive border L (γ ∘ select) (E ∘ select) (injective.comp injectiveSelect)
      (fun _ _ ne => disjoint (injectiveSelect.ne ne)) (fun x => size (select x))
      (fun x => bad (select x))
    exact ⟨c, by simpa [select] using relation⟩
  choose c relation using fromAnchor
  exact ⟨c, relation⟩

end ProximityCoding.ReedSolomon.Parameters
