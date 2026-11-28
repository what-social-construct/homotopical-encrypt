module

public import Proximity.MCA.CancellationWitness
public import Proximity.MCA.SpectrumCertificate

public import Proximity.MCA.Pair
public import Proximity.MCA.Threshold

@[expose] public section

/-!
# Common agreement pencils at small count radii

If three allowed error sets cannot cover the support of a nonzero codeword,
scalar agreement witnesses interpolate along one affine line of codewords.
Each bad challenge then has a marked coordinate where the residual scalar
word vanishes but its two components do not both vanish.
-/

set_option autoImplicit false

namespace ProximityCoding.ReedSolomon.Parameters

open BlockCode

variable {F ι : Type*} [Field F] [Fintype F] [Fintype ι]

private theorem card_complement_le_of_large {r : ℕ} {S : Finset ι}
    (large : LargeAgreementSet r S) [DecidableEq ι] :
    (Finset.univ \ S).card ≤ r := by
  have partition := Finset.card_sdiff_add_card_eq_card S.subset_univ
  rw [Finset.card_univ] at partition
  unfold LargeAgreementSet at large
  omega

omit [Fintype F] in
private theorem card_le_card_inter_add_radius [DecidableEq ι]
    {r : ℕ} (S T : Finset ι) (hT : LargeAgreementSet r T) :
    S.card ≤ (S ∩ T).card + r := by
  have bound := (Finset.card_le_card (Finset.sdiff_subset_sdiff_left T S.subset_univ)).trans
    (card_complement_le_of_large hT)
  have partition := Finset.card_sdiff_add_card_inter S T
  omega

omit [Fintype F] [Fintype ι] in
private theorem pairWord_eq_of_point_eq_at_two
    (A L : AffineLine ι F) {γ η : F} (distinct : γ ≠ η) (i : ι)
    (atγ : (A.point γ) i = (L.point γ) i)
    (atη : (A.point η) i = (L.point η) i) : pairWord A i = pairWord L i := by
  simp only [AffineLine.point_apply] at atγ atη
  have product : (γ - η) * (A.direction i - L.direction i) = 0 := by
    linear_combination atγ - atη
  have direction : A.direction i = L.direction i :=
    sub_eq_zero.mp ((mul_eq_zero.mp product).resolve_left (sub_ne_zero.mpr distinct))
  rw [direction] at atγ
  have base : A.base i = L.base i := add_right_cancel atγ
  funext j
  change (if j = 0 then A.base i else A.direction i) =
    (if j = 0 then L.base i else L.direction i)
  rw [base, direction]

omit [Fintype F] in
/-- Two scalar agreement witnesses whose common agreement set has at least
`k+r` sites determine one codeword pencil for all count-`r` scalar witnesses. -/
theorem exists_agreementPencil_of_overlap [DecidableEq ι]
    (P : Parameters F ι) (degreePositive : 0 < P.degreeBound) {r : ℕ}
    (L : AffineLine ι F) {γ η : F} (distinct : γ ≠ η) {Sγ Sη : Finset ι}
    (overlap : P.degreeBound + r ≤ (Sγ ∩ Sη).card)
    (closeγ : P.toBlockCode.CloseOnSet (L.point γ) Sγ)
    (closeη : P.toBlockCode.CloseOnSet (L.point η) Sη) :
    ∃ A : AffineLine ι F, P.Codeword A.base ∧ P.Codeword A.direction ∧
      ∀ (τ : F) (S : Finset ι) (c : Word ι F),
        LargeAgreementSet r S → P.Codeword c → AgreesOn (L.point τ) c S → A.point τ = c := by
  classical
  obtain ⟨cγ, validγ, agreeγ⟩ := closeγ
  obtain ⟨cη, validη, agreeη⟩ := closeη
  let direction : Word ι F := fun i => (γ - η)⁻¹ * (cγ i - cη i)
  let A : AffineLine ι F := ⟨fun i => cγ i - γ * direction i, direction⟩
  have additive := P.fAdditive_of_degreeBound_pos degreePositive
  have validDiff : P.Codeword (fun i => cγ i - cη i) := by
    simpa [sub_eq_add_neg, smul_eq_mul] using
      additive.add_mem validγ (additive.smul_mem (-1 : F) validη)
  have validDirection : P.Codeword A.direction := by
    simpa [A, direction, smul_eq_mul] using additive.smul_mem (γ - η)⁻¹ validDiff
  have validBase : P.Codeword A.base := by
    simpa [A, sub_eq_add_neg, smul_eq_mul] using
      additive.add_mem validγ (additive.smul_mem (-γ) validDirection)
  have fitγ (i : ι) : (A.point γ) i = cγ i := by
    simp [AffineLine.point_apply, A]
  have fitη (i : ι) : (A.point η) i = cη i := by
    have cancel : (γ - η) * direction i = cγ i - cη i := by
      rw [show direction i = (γ - η)⁻¹ * (cγ i - cη i) by rfl,
        ← mul_assoc, mul_inv_cancel₀ (sub_ne_zero.mpr distinct), one_mul]
    change cγ i - γ * direction i + η * direction i = cη i
    linear_combination -cancel
  refine ⟨A, validBase, validDirection, ?_⟩
  intro τ S c large valid agrees
  have remaining := card_le_card_inter_add_radius (Sγ ∩ Sη) S large
  have enough : P.degreeBound ≤ (Sγ ∩ Sη ∩ S).card := by omega
  obtain ⟨T, contain, size⟩ := Finset.exists_subset_card_eq enough
  have validPoint : P.Codeword (A.point τ) := by
    change P.Codeword (fun i => A.base i + τ * A.direction i)
    simpa only [smul_eq_mul] using
      additive.add_mem validBase (additive.smul_mem τ validDirection)
  apply P.determinedBy_degreeBound validPoint valid T size
  intro i hi
  obtain ⟨inBoth, hS⟩ := Finset.mem_inter.mp (contain hi)
  obtain ⟨hγ, hη⟩ := Finset.mem_inter.mp inBoth
  have pairEq := pairWord_eq_of_point_eq_at_two A L distinct i
    ((fitγ i).trans (agreeγ i hγ).symm) ((fitη i).trans (agreeη i hη).symm)
  have base := congrFun pairEq 0
  have directionEq := congrFun pairEq 1
  simp only [pairWord_zero, pairWord_one] at base directionEq
  exact (by simp only [AffineLine.point_apply, base, directionEq] :
    (A.point τ) i = (L.point τ) i).trans (agrees i hS)

omit [Fintype F] in
/-- If `k+3r≤n`, every pair of count-`r` scalar agreement witnesses
has the overlap needed for a common codeword pencil. -/
theorem exists_agreementPencil_of_three_mul_le
    (P : Parameters F ι) (degreePositive : 0 < P.degreeBound) {r : ℕ}
    (room : P.degreeBound + 3 * r ≤ Fintype.card ι) (L : AffineLine ι F)
    {γ η : F} (distinct : γ ≠ η)
    (closeγ : P.toBlockCode.CloseOnLargeSet r (L.point γ))
    (closeη : P.toBlockCode.CloseOnLargeSet r (L.point η)) :
    ∃ A : AffineLine ι F, P.Codeword A.base ∧ P.Codeword A.direction ∧
      ∀ (τ : F) (S : Finset ι) (c : Word ι F),
        LargeAgreementSet r S → P.Codeword c → AgreesOn (L.point τ) c S → A.point τ = c := by
  classical
  obtain ⟨Sγ, largeγ, agreeγ⟩ := closeγ
  obtain ⟨Sη, largeη, agreeη⟩ := closeη
  have remaining := card_le_card_inter_add_radius Sγ Sη largeη
  unfold LargeAgreementSet at largeγ
  exact P.exists_agreementPencil_of_overlap degreePositive L distinct (by omega) agreeγ agreeη

private theorem badChallengeSet_card_le_succ_of_agreementPencil
    (P : Parameters F ι) {r : ℕ} (L A : AffineLine ι F)
    (validBase : P.Codeword A.base) (validDirection : P.Codeword A.direction)
    (through : ∀ (τ : F) (S : Finset ι) (c : Word ι F),
      LargeAgreementSet r S → P.Codeword c → AgreesOn (L.point τ) c S → A.point τ = c) :
    (P.toBlockCode.badChallengeSet r L).card ≤ r + 1 := by
  classical
  let B := P.toBlockCode.badChallengeSet r L
  change B.card ≤ r + 1
  by_cases empty : B = ∅
  · simp [empty]
  obtain ⟨γ, inγ⟩ := Finset.nonempty_iff_ne_empty.mpr empty
  have bad (τ : F) (inB : τ ∈ B) : ∃ S, LargeAgreementSet r S ∧ P.BadOnSet L τ S :=
    (P.toBlockCode.mem_badChallengeSet r L τ).mp inB
  have validPair : (P.toBlockCode.interleaved (Fin 2)).Codeword (pairWord A) := by
    intro j
    change P.Codeword (fun i => if j = 0 then A.base i else A.direction i)
    by_cases zero : j = 0
    · simpa only [ite_eq_left zero] using validBase
    · simpa only [ite_eq_right zero] using validDirection
  have witness (τ : F) (inB : τ ∈ B) :
      ∃ S : Finset ι, LargeAgreementSet r S ∧
        AgreesOn (L.point τ) (A.point τ) S ∧
        ∃ i ∈ S, pairWord A i ≠ pairWord L i := by
    obtain ⟨S, large, ⟨c, valid, agrees⟩, notPair⟩ := bad τ inB
    refine ⟨S, large, ?_, ?_⟩
    · rw [through τ S c large valid agrees]
      exact agrees
    · by_contra! all
      exact notPair ⟨pairWord A, validPair, fun i hi => (all i hi).symm⟩
  obtain ⟨S, large, agrees, _⟩ := witness γ inγ
  have pick (τ : ↥(B.erase γ)) : ∃ j : ↥(Finset.univ \ S),
      (A.point τ.val) j.val = (L.point τ.val) j.val ∧ pairWord A j.val ≠ pairWord L j.val := by
    obtain ⟨T, _, same, i, inT, mismatch⟩ := witness τ.val (Finset.mem_erase.mp τ.property).2
    have outside : i ∉ S := by
      intro inS
      exact mismatch (pairWord_eq_of_point_eq_at_two A L
        (Finset.mem_erase.mp τ.property).1 i (same i inT).symm (agrees i inS).symm)
    exact ⟨⟨i, Finset.mem_sdiff.mpr ⟨Finset.mem_univ _, outside⟩⟩, (same i inT).symm, mismatch⟩
  choose marker marked using pick
  have injective : Function.Injective marker := by
    intro τ υ eq
    apply Subtype.ext
    by_contra distinct'
    have agreeτ := (marked τ).1
    have agreeυ := (marked υ).1
    rw [← eq] at agreeυ
    exact (marked τ).2 (pairWord_eq_of_point_eq_at_two A L distinct' (marker τ).val agreeτ agreeυ)
  have count := Fintype.card_le_of_injective marker injective
  simp only [Fintype.card_coe, Finset.card_erase_of_mem inγ] at count
  have bound := card_complement_le_of_large large
  omega

/-- Once two scalar witnesses have at least `k+r` common agreement sites,
every other bad challenge marks a different site outside a chosen bad set. -/
theorem badChallengeSet_card_le_succ_of_overlap [DecidableEq ι]
    (P : Parameters F ι) (degreePositive : 0 < P.degreeBound) {r : ℕ}
    (L : AffineLine ι F) {γ η : F} (distinct : γ ≠ η) {Sγ Sη : Finset ι}
    (overlap : P.degreeBound + r ≤ (Sγ ∩ Sη).card)
    (closeγ : P.toBlockCode.CloseOnSet (L.point γ) Sγ)
    (closeη : P.toBlockCode.CloseOnSet (L.point η) Sη) :
    (P.toBlockCode.badChallengeSet r L).card ≤ r + 1 := by
  obtain ⟨A, validBase, validDirection, through⟩ :=
    P.exists_agreementPencil_of_overlap degreePositive L distinct overlap closeγ closeη
  exact P.badChallengeSet_card_le_succ_of_agreementPencil L A validBase validDirection through

/-- The uniform radius bound follows by applying the overlap criterion to
any two distinct bad challenges. -/
theorem badChallengeSet_card_le_succ_of_three_mul_le
    (P : Parameters F ι) (degreePositive : 0 < P.degreeBound) {r : ℕ}
    (room : P.degreeBound + 3 * r ≤ Fintype.card ι) (L : AffineLine ι F) :
    (P.toBlockCode.badChallengeSet r L).card ≤ r + 1 := by
  classical
  let B := P.toBlockCode.badChallengeSet r L
  change B.card ≤ r + 1
  by_cases small : B.card ≤ 1
  · omega
  obtain ⟨γ, inγ, η, inη, distinct⟩ := Finset.one_lt_card.mp (lt_of_not_ge small)
  have close (τ : F) (inB : τ ∈ B) : P.toBlockCode.CloseOnLargeSet r (L.point τ) := by
    obtain ⟨S, large, scalar, _⟩ := (P.toBlockCode.mem_badChallengeSet r L τ).mp inB
    exact ⟨S, large, scalar⟩
  obtain ⟨A, validBase, validDirection, through⟩ :=
    P.exists_agreementPencil_of_three_mul_le degreePositive room L distinct (close γ inγ) (close η inη)
  exact P.badChallengeSet_card_le_succ_of_agreementPencil L A validBase validDirection through

/-- The shared-pencil bound holds uniformly over all received lines. -/
theorem worstBadCount_le_succ_of_three_mul_le
    (P : Parameters F ι) (degreePositive : 0 < P.degreeBound) {r : ℕ}
    (room : P.degreeBound + 3 * r ≤ Fintype.card ι) :
    P.toBlockCode.worstBadCount r ≤ r + 1 :=
  (P.toBlockCode.worstBadCount_le_iff r (r + 1)).mpr
    (P.badChallengeSet_card_le_succ_of_three_mul_le degreePositive room)

/-- The overlap upper bound is attained by cancelling one coordinate at a time. -/
theorem worstBadCount_eq_succ_of_three_mul_le
    (P : Parameters F ι) (degreePositive : 0 < P.degreeBound) {r : ℕ}
    (proper : P.degreeBound < Fintype.card ι)
    (room : P.degreeBound + 3 * r ≤ Fintype.card ι) :
    P.toBlockCode.worstBadCount r = r + 1 := by
  apply le_antisymm (P.worstBadCount_le_succ_of_three_mul_le degreePositive room)
  have enough : P.degreeBound + (r + 1) ≤ Fintype.card ι := by omega
  have sites := Fintype.card_le_of_injective P.domain.point P.domain.injective_point
  obtain ⟨L, realizes⟩ := P.exists_badChallengeSet_card_ge_of_le_succ degreePositive
    (r := r) le_rfl enough (by omega)
  exact realizes.trans (P.toBlockCode.badChallengeSet_card_le_worstBadCount r L)

/-- Adjacent exact threshold when the last safe radius lies in the shared-pencil regime. -/
theorem pairMCAThreshold_of_sparse_budget
    (P : Parameters F ι) (degreePositive : 0 < P.degreeBound) {r bits : ℕ}
    (roomSafe : P.degreeBound + 3 * r ≤ Fintype.card ι)
    (roomNext : P.degreeBound + (r + 2) ≤ Fintype.card ι)
    (allowed : 2 ^ bits * (r + 1) ≤ Fintype.card F)
    (denied : Fintype.card F < 2 ^ bits * (r + 2)) :
    P.toBlockCode.pairMCAGreatestSafe bits = (r : WithBot ℕ) ∧
      P.toBlockCode.pairMCAFirstUnsafe bits = ((r + 1 : ℕ) : WithTop ℕ) := by
  have sites := Fintype.card_le_of_injective P.domain.point P.domain.injective_point
  obtain ⟨L, overBudget⟩ := P.exists_badChallengeSet_card_ge_of_le_succ degreePositive
    (r := r + 1) le_rfl roomNext (by omega)
  exact P.toBlockCode.pairMCAThreshold_eq_of_countBound_and_badLine (by omega)
    (P.badChallengeSet_card_le_succ_of_three_mul_le degreePositive roomSafe) allowed L
    (denied.trans_le (Nat.mul_le_mul_left _ overBudget))

end ProximityCoding.ReedSolomon.Parameters
