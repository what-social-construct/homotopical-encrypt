import ProximityPrize.ReedSolomon
import Mathlib.Data.Fintype.Powerset
import Mathlib.Algebra.Polynomial.Degree.IsMonicOfDegree
import Mathlib.Algebra.Polynomial.Roots
import Mathlib.LinearAlgebra.Lagrange

/-!
# The capacity-grid list bound

This module proves the elementary counting theorem used by the standalone
paper.  A code that is determined by its values on any `k` coordinates has at
most `Nat.choose n k` codewords in every Hamming ball of radius `n - k`.
For Reed--Solomon codes this bound is attained by the received word whose
distinguished component is the evaluation of `X ^ k`.  Hence the endpoint
worst-case list size is exactly `Nat.choose n k`, independently of the
interleaving width.
-/

namespace ProximityPrize
namespace CapacityList

open BlockCode

variable {ι α : Type*} [Fintype ι] [DecidableEq α]

/-- The coordinates on which two words agree. -/
def agreementSet (u v : Word ι α) : Finset ι :=
  Finset.univ.filter fun i => u i = v i

/-- Agreement and disagreement coordinates partition the coordinate set. -/
theorem agreement_card_add_hammingDistance (u v : Word ι α) :
    (agreementSet u v).card + hammingDistance u v = Fintype.card ι := by
  classical
  simpa only [agreementSet, hammingDistance] using
    Finset.filter_card_add_filter_neg_card_eq_card
      (s := (Finset.univ : Finset ι)) (p := fun i => u i = v i)

/-- Any two codewords agreeing on `k` coordinates are equal. -/
def DeterminedBy (C : BlockCode ι α) (k : ℕ) : Prop :=
  ∀ ⦃c d : Word ι α⦄,
    C.Codeword c →
    C.Codeword d →
    ∀ S : Finset ι,
      S.card = k →
      (∀ i ∈ S, c i = d i) →
      c = d

/--
The paper's fractional list target: every relative ball contains at most
`ε q` codewords, where `q` is the field-cardinality benchmark supplied by the
caller.
-/
noncomputable def FractionalListSizeBoundAt
    (C : BlockCode ι α) (δ ε : ℝ) (q : ℕ) : Prop :=
  ∀ w : Word ι α, (C.ballCardAt δ w : ℝ) ≤ ε * q

section Counting

/--
A word in the radius-`n-k` ball agrees with the center on at least `k`
coordinates.
-/
theorem degreeBound_le_agreement_card
    (C : BlockCode ι α)
    {k : ℕ}
    (hk : k ≤ Fintype.card ι)
    (w : Word ι α)
    (c : {c : Word ι α // c ∈ C.Ball (Fintype.card ι - k) w}) :
    k ≤ (agreementSet c.1 w).card := by
  have hpartition := agreement_card_add_hammingDistance c.1 w
  have hdistance := c.2.2
  omega

/-- A canonical `k`-subset of the agreement coordinates of a ball member. -/
noncomputable def chosenAgreement
    (C : BlockCode ι α)
    {k : ℕ}
    (hk : k ≤ Fintype.card ι)
    (w : Word ι α)
    (c : {c : Word ι α // c ∈ C.Ball (Fintype.card ι - k) w}) :
    Finset ι :=
  (Finset.exists_subset_card_eq
    (degreeBound_le_agreement_card C hk w c)).choose

theorem chosenAgreement_subset
    (C : BlockCode ι α)
    {k : ℕ}
    (hk : k ≤ Fintype.card ι)
    (w : Word ι α)
    (c : {c : Word ι α // c ∈ C.Ball (Fintype.card ι - k) w}) :
    chosenAgreement C hk w c ⊆ agreementSet c.1 w :=
  (Finset.exists_subset_card_eq
    (degreeBound_le_agreement_card C hk w c)).choose_spec.1

theorem chosenAgreement_card
    (C : BlockCode ι α)
    {k : ℕ}
    (hk : k ≤ Fintype.card ι)
    (w : Word ι α)
    (c : {c : Word ι α // c ∈ C.Ball (Fintype.card ι - k) w}) :
    (chosenAgreement C hk w c).card = k :=
  (Finset.exists_subset_card_eq
    (degreeBound_le_agreement_card C hk w c)).choose_spec.2

/-- Record a ball member by `k` coordinates on which it agrees with the center. -/
noncomputable def agreementSignature
    (C : BlockCode ι α)
    {k : ℕ}
    (hk : k ≤ Fintype.card ι)
    (w : Word ι α) :
    {c : Word ι α // c ∈ C.Ball (Fintype.card ι - k) w} →
      {S : Finset ι // S.card = k} :=
  fun c => ⟨chosenAgreement C hk w c, chosenAgreement_card C hk w c⟩

theorem agreementSignature_injective
    (C : BlockCode ι α)
    {k : ℕ}
    (hk : k ≤ Fintype.card ι)
    (hdet : DeterminedBy C k)
    (w : Word ι α) :
    Function.Injective (agreementSignature C hk w) := by
  intro c d hsignature
  apply Subtype.ext
  exact hdet c.2.1 d.2.1 (chosenAgreement C hk w c)
    (chosenAgreement_card C hk w c) (by
      intro i hi
      have hc_mem : i ∈ agreementSet c.1 w :=
        chosenAgreement_subset C hk w c hi
      have hsets :
          chosenAgreement C hk w c = chosenAgreement C hk w d :=
        congrArg Subtype.val hsignature
      have hd_mem : i ∈ agreementSet d.1 w := by
        apply chosenAgreement_subset C hk w d
        rw [← hsets]
        exact hi
      exact (Finset.mem_filter.1 hc_mem).2.trans
        (Finset.mem_filter.1 hd_mem).2.symm)

/--
The capacity-grid counting theorem: determination by any `k` coordinates
implies a worst-case list bound of `choose n k` at radius `n-k`.
-/
theorem listSizeBound_capacityGrid
    (C : BlockCode ι α)
    {k : ℕ}
    [Fintype α]
    (hk : k ≤ Fintype.card ι)
    (hdet : DeterminedBy C k) :
    C.ListSizeBound (Fintype.card ι - k)
      (Nat.choose (Fintype.card ι) k) := by
  intro w
  classical
  letI : Fintype
      {c : Word ι α // c ∈ C.Ball (Fintype.card ι - k) w} :=
    Fintype.ofFinite _
  unfold BlockCode.ballCard
  rw [Nat.card_eq_fintype_card, ← Fintype.card_finset_len]
  exact Fintype.card_le_of_injective
    (agreementSignature C hk w)
    (agreementSignature_injective C hk hdet w)

/-- Normalized form of `listSizeBound_capacityGrid`. -/
theorem listSizeBoundAt_capacityGrid
    (C : BlockCode ι α)
    {k : ℕ}
    [Fintype α]
    (hlength : 0 < Fintype.card ι)
    (hk : k ≤ Fintype.card ι)
    (hdet : DeterminedBy C k) :
    C.ListSizeBoundAt
      (BlockCode.relativeRadius (ι := ι) (Fintype.card ι - k))
      (Nat.choose (Fintype.card ι) k) := by
  intro w
  rw [C.ballCardAt_relativeRadius_eq_ballCard hlength w]
  exact listSizeBound_capacityGrid C hk hdet w

end Counting

end CapacityList

namespace ReedSolomon.Parameters

open CapacityList
open scoped BigOperators

variable {F ι : Type*} [Field F] [Fintype ι]

/-- Scalar Reed--Solomon words are determined by any `k` evaluations. -/
theorem determinedBy_degreeBound
    (P : ReedSolomon.Parameters F ι) :
    DeterminedBy P.toBlockCode P.degreeBound := by
  intro c d hc hd S hS hagree
  rcases hc with ⟨p, hp, hp_eval⟩
  rcases hd with ⟨q, hq, hq_eval⟩
  have hp_degree : p.degree < (S.card : WithBot ℕ) := by
    rw [hS]
    exact lt_of_le_of_lt Polynomial.degree_le_natDegree
      (WithBot.coe_lt_coe.2 hp)
  have hq_degree : q.degree < (S.card : WithBot ℕ) := by
    rw [hS]
    exact lt_of_le_of_lt Polynomial.degree_le_natDegree
      (WithBot.coe_lt_coe.2 hq)
  have hpq : p = q := by
    apply Polynomial.eq_of_degrees_lt_of_eval_index_eq S
      P.domain.injective_point.injOn hp_degree hq_degree
    intro i hi
    rw [← hp_eval i, ← hq_eval i]
    exact hagree i hi
  funext i
  rw [hp_eval i, hq_eval i, hpq]

/-- Every interleaving width retains the same `k`-point determination bound. -/
theorem vectorDeterminedBy_degreeBound
    (P : ReedSolomon.Parameters F ι)
    (σ : Type*) :
    DeterminedBy (P.vectorBlockCode σ) P.degreeBound := by
  intro c d hc hd S hS hagree
  funext i j
  have hcomponent :
      (fun i => c i j) = (fun i => d i j) := by
    apply P.determinedBy_degreeBound (hc j) (hd j) S hS
    intro a ha
    exact congrFun (hagree a ha) j
  exact congrFun hcomponent i

/-- The monic polynomial vanishing on the evaluation points indexed by `S`. -/
noncomputable def capacityVanishingPolynomial
    (P : ReedSolomon.Parameters F ι)
    (S : Finset ι) : Polynomial F :=
  ∏ i ∈ S, (Polynomial.X - Polynomial.C (P.domain.point i))

/--
The degree-`<k` polynomial obtained by cancelling the leading term of `X^k`
with the monic polynomial vanishing on `S`.
-/
noncomputable def capacityInterpolationPolynomial
    (P : ReedSolomon.Parameters F ι)
    (S : Finset ι) : Polynomial F :=
  Polynomial.X ^ P.degreeBound - P.capacityVanishingPolynomial S

theorem capacityVanishingPolynomial_isMonicOfDegree
    (P : ReedSolomon.Parameters F ι)
    {S : Finset ι}
    (hS : S.card = P.degreeBound) :
  Polynomial.IsMonicOfDegree
      (P.capacityVanishingPolynomial S) P.degreeBound := by
  constructor
  · simp [capacityVanishingPolynomial, hS]
  · exact Polynomial.monic_prod_X_sub_C P.domain.point S

theorem capacityInterpolationPolynomial_natDegree_lt
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    {S : Finset ι}
    (hS : S.card = P.degreeBound) :
    (P.capacityInterpolationPolynomial S).natDegree < P.degreeBound := by
  apply (Polynomial.isMonicOfDegree_X_pow F P.degreeBound).natDegree_sub_lt
    hDegree.ne'
  exact P.capacityVanishingPolynomial_isMonicOfDegree hS

theorem eval_capacityVanishingPolynomial_eq_zero_iff
    (P : ReedSolomon.Parameters F ι)
    (S : Finset ι)
  (i : ι) :
    Polynomial.eval (P.domain.point i)
      (P.capacityVanishingPolynomial S) = 0 ↔ i ∈ S := by
  classical
  simp only [capacityVanishingPolynomial, Polynomial.eval_prod,
    Polynomial.eval_sub, Polynomial.eval_X, Polynomial.eval_C,
    Finset.prod_eq_zero_iff, sub_eq_zero]
  constructor
  · rintro ⟨a, ha, hia⟩
    exact (P.domain.injective_point hia) ▸ ha
  · intro hi
    exact ⟨i, hi, rfl⟩

theorem eval_capacityInterpolationPolynomial_eq_power_iff
    (P : ReedSolomon.Parameters F ι)
    (S : Finset ι)
    (i : ι) :
    Polynomial.eval (P.domain.point i)
        (P.capacityInterpolationPolynomial S) =
      P.domain.point i ^ P.degreeBound ↔
    i ∈ S := by
  simpa [capacityInterpolationPolynomial] using
    P.eval_capacityVanishingPolynomial_eq_zero_iff S i

/-- The endpoint received word: `X^k` in one component and zero elsewhere. -/
def capacityReceivedWord
    (P : ReedSolomon.Parameters F ι)
    {σ : Type*}
    [DecidableEq σ]
    (j₀ : σ) :
    ReedSolomon.VectorWord ι F σ :=
  fun i j => if j = j₀ then P.domain.point i ^ P.degreeBound else 0

/--
The interleaved codeword indexed by a `k`-subset of evaluation coordinates.
-/
noncomputable def capacitySubsetWord
    (P : ReedSolomon.Parameters F ι)
    {σ : Type*}
    [DecidableEq σ]
    (j₀ : σ)
    (S : Finset ι) :
    ReedSolomon.VectorWord ι F σ :=
  fun i j =>
    if j = j₀ then
      Polynomial.eval (P.domain.point i)
        (P.capacityInterpolationPolynomial S)
    else 0

theorem capacitySubsetWord_codeword
    (P : ReedSolomon.Parameters F ι)
    {σ : Type*}
    [DecidableEq σ]
    (j₀ : σ)
    (hDegree : 0 < P.degreeBound)
    {S : Finset ι}
    (hS : S.card = P.degreeBound) :
    (P.vectorBlockCode σ).Codeword (P.capacitySubsetWord j₀ S) := by
  intro j
  by_cases hj : j = j₀
  · subst j
    refine ⟨P.capacityInterpolationPolynomial S,
      P.capacityInterpolationPolynomial_natDegree_lt hDegree hS, ?_⟩
    intro i
    simp [capacitySubsetWord]
  · refine ⟨0, by simpa using hDegree, ?_⟩
    intro i
    simp [capacitySubsetWord, hj]

theorem capacitySubsetWord_eq_received_iff
    (P : ReedSolomon.Parameters F ι)
    {σ : Type*}
    [DecidableEq σ]
    (j₀ : σ)
    (S : Finset ι)
    (i : ι) :
    P.capacitySubsetWord j₀ S i = P.capacityReceivedWord j₀ i ↔
      i ∈ S := by
  constructor
  · intro h
    apply (P.eval_capacityInterpolationPolynomial_eq_power_iff S i).1
    simpa [capacitySubsetWord, capacityReceivedWord] using congrFun h j₀
  · intro hi
    funext j
    by_cases hj : j = j₀
    · subst j
      simp only [capacitySubsetWord, capacityReceivedWord, if_pos]
      exact (P.eval_capacityInterpolationPolynomial_eq_power_iff S i).2 hi
    · simp [capacitySubsetWord, capacityReceivedWord, hj]

theorem agreementSet_capacitySubsetWord
    (P : ReedSolomon.Parameters F ι)
    {σ : Type*}
    [Fintype σ]
    [DecidableEq F]
    [DecidableEq σ]
    (j₀ : σ)
    (S : Finset ι) :
    agreementSet (P.capacitySubsetWord j₀ S)
      (P.capacityReceivedWord j₀) = S := by
  classical
  ext i
  simp only [agreementSet, Finset.mem_filter, Finset.mem_univ, true_and]
  exact P.capacitySubsetWord_eq_received_iff j₀ S i

theorem capacitySubsetWord_mem_capacityBall
    (P : ReedSolomon.Parameters F ι)
    {σ : Type*}
    [Fintype σ]
    [DecidableEq F]
    [DecidableEq σ]
    (j₀ : σ)
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (S : {S : Finset ι // S.card = P.degreeBound}) :
    P.capacitySubsetWord j₀ S.1 ∈
      (P.vectorBlockCode σ).Ball
        (Fintype.card ι - P.degreeBound)
        (P.capacityReceivedWord j₀) := by
  constructor
  · exact P.capacitySubsetWord_codeword j₀ hDegree S.2
  · have hpartition :=
      agreement_card_add_hammingDistance
        (P.capacitySubsetWord j₀ S.1) (P.capacityReceivedWord j₀)
    rw [P.agreementSet_capacitySubsetWord j₀ S.1, S.2] at hpartition
    omega

/-- A `k`-subset as an element of the endpoint list ball. -/
noncomputable def capacityBallElement
    (P : ReedSolomon.Parameters F ι)
    {σ : Type*}
    [Fintype σ]
    [DecidableEq F]
    [DecidableEq σ]
    (j₀ : σ)
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) :
    {S : Finset ι // S.card = P.degreeBound} →
      {c : ReedSolomon.VectorWord ι F σ //
        c ∈ (P.vectorBlockCode σ).Ball
          (Fintype.card ι - P.degreeBound)
          (P.capacityReceivedWord j₀)} :=
  fun S => ⟨P.capacitySubsetWord j₀ S.1,
    P.capacitySubsetWord_mem_capacityBall j₀ hDegree hk S⟩

theorem capacityBallElement_injective
    (P : ReedSolomon.Parameters F ι)
    {σ : Type*}
    [Fintype σ]
    [DecidableEq F]
    [DecidableEq σ]
    (j₀ : σ)
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) :
    Function.Injective (P.capacityBallElement j₀ hDegree hk) := by
  intro S T hST
  apply Subtype.ext
  have hwords := congrArg Subtype.val hST
  have hagreements := congrArg
    (fun c => agreementSet c (P.capacityReceivedWord j₀)) hwords
  change
    agreementSet (P.capacitySubsetWord j₀ S.1)
        (P.capacityReceivedWord j₀) =
      agreementSet (P.capacitySubsetWord j₀ T.1)
        (P.capacityReceivedWord j₀) at hagreements
  rw [P.agreementSet_capacitySubsetWord j₀ S.1,
    P.agreementSet_capacitySubsetWord j₀ T.1] at hagreements
  exact hagreements

/--
The endpoint received word contains at least `choose n k` interleaved
Reed--Solomon codewords in its radius-`n-k` ball.
-/
theorem choose_le_capacityReceived_ballCard
    (P : ReedSolomon.Parameters F ι)
    {σ : Type*}
    [Fintype F]
    [DecidableEq F]
    [Fintype σ]
    [DecidableEq σ]
    (j₀ : σ)
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) :
    Nat.choose (Fintype.card ι) P.degreeBound ≤
      (P.vectorBlockCode σ).ballCard
        (Fintype.card ι - P.degreeBound)
        (P.capacityReceivedWord j₀) := by
  classical
  letI : Fintype
      {c : ReedSolomon.VectorWord ι F σ //
        c ∈ (P.vectorBlockCode σ).Ball
          (Fintype.card ι - P.degreeBound)
          (P.capacityReceivedWord j₀)} :=
    Fintype.ofFinite _
  unfold BlockCode.ballCard
  rw [Nat.card_eq_fintype_card, ← Fintype.card_finset_len]
  exact Fintype.card_le_of_injective
    (P.capacityBallElement j₀ hDegree hk)
    (P.capacityBallElement_injective j₀ hDegree hk)

/--
Universal interleaved Reed--Solomon list bound at the capacity-grid radius.
The bound is independent of the interleaving width.
-/
theorem vectorListSizeBound_capacityGrid
    (P : ReedSolomon.Parameters F ι)
    (σ : Type*)
    [Fintype F]
    [DecidableEq F]
    [Fintype σ]
    (hk : P.degreeBound ≤ Fintype.card ι) :
    (P.vectorBlockCode σ).ListSizeBound
      (Fintype.card ι - P.degreeBound)
      (Nat.choose (Fintype.card ι) P.degreeBound) := by
  classical
  exact CapacityList.listSizeBound_capacityGrid
    (P.vectorBlockCode σ) hk (P.vectorDeterminedBy_degreeBound σ)

/-- Paper-facing normalized form of the universal capacity-grid list bound. -/
theorem vectorListSizeBoundAt_capacityGrid
    (P : ReedSolomon.Parameters F ι)
    (σ : Type*)
    [Fintype F]
    [DecidableEq F]
    [Fintype σ]
    (hlength : 0 < Fintype.card ι)
    (hk : P.degreeBound ≤ Fintype.card ι) :
    (P.vectorBlockCode σ).ListSizeBoundAt
      (BlockCode.relativeRadius (ι := ι)
        (Fintype.card ι - P.degreeBound))
      (Nat.choose (Fintype.card ι) P.degreeBound) := by
  classical
  exact CapacityList.listSizeBoundAt_capacityGrid
    (P.vectorBlockCode σ) hlength hk
      (P.vectorDeterminedBy_degreeBound σ)

/--
The capacity witness attains the universal upper bound: its radius-`n-k`
ball has exactly `choose n k` codewords.
-/
theorem capacityReceived_ballCard_eq_choose
    (P : ReedSolomon.Parameters F ι)
    {σ : Type*}
    [Fintype F]
    [DecidableEq F]
    [Fintype σ]
    [DecidableEq σ]
    (j₀ : σ)
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) :
    (P.vectorBlockCode σ).ballCard
        (Fintype.card ι - P.degreeBound)
        (P.capacityReceivedWord j₀) =
      Nat.choose (Fintype.card ι) P.degreeBound := by
  apply le_antisymm
  · exact P.vectorListSizeBound_capacityGrid σ hk
      (P.capacityReceivedWord j₀)
  · exact P.choose_le_capacityReceived_ballCard j₀ hDegree hk

/-- Normalized form of the exact capacity-witness list size. -/
theorem capacityReceived_ballCardAt_eq_choose
    (P : ReedSolomon.Parameters F ι)
    {σ : Type*}
    [Fintype F]
    [DecidableEq F]
    [Fintype σ]
    [DecidableEq σ]
    (j₀ : σ)
    (hDegree : 0 < P.degreeBound)
    (hlength : 0 < Fintype.card ι)
    (hk : P.degreeBound ≤ Fintype.card ι) :
    (P.vectorBlockCode σ).ballCardAt
        (BlockCode.relativeRadius (ι := ι)
          (Fintype.card ι - P.degreeBound))
        (P.capacityReceivedWord j₀) =
      Nat.choose (Fintype.card ι) P.degreeBound := by
  rw [(P.vectorBlockCode σ).ballCardAt_relativeRadius_eq_ballCard
    hlength (P.capacityReceivedWord j₀)]
  exact P.capacityReceived_ballCard_eq_choose j₀ hDegree hk

/--
Exact endpoint criterion.  The fractional target at the capacity grid holds
if and only if the field-size budget dominates `choose n k`.
-/
theorem vectorFractionalListSizeBoundAt_capacityGrid_iff
    (P : ReedSolomon.Parameters F ι)
    {σ : Type*}
    [Fintype F]
    [DecidableEq F]
    [Fintype σ]
    [DecidableEq σ]
    (j₀ : σ)
    (ε : ℝ)
    (hDegree : 0 < P.degreeBound)
    (hlength : 0 < Fintype.card ι)
    (hk : P.degreeBound ≤ Fintype.card ι) :
    CapacityList.FractionalListSizeBoundAt
        (P.vectorBlockCode σ)
        (BlockCode.relativeRadius (ι := ι)
          (Fintype.card ι - P.degreeBound))
        ε (Fintype.card F) ↔
      (Nat.choose (Fintype.card ι) P.degreeBound : ℝ) ≤
        ε * Fintype.card F := by
  constructor
  · intro htarget
    simpa [CapacityList.FractionalListSizeBoundAt,
      P.capacityReceived_ballCardAt_eq_choose j₀ hDegree hlength hk] using
      htarget (P.capacityReceivedWord j₀)
  · intro hfield w
    calc
      ((P.vectorBlockCode σ).ballCardAt
          (BlockCode.relativeRadius (ι := ι)
            (Fintype.card ι - P.degreeBound)) w : ℝ) ≤
          Nat.choose (Fintype.card ι) P.degreeBound := by
            exact_mod_cast
              P.vectorListSizeBoundAt_capacityGrid σ hlength hk w
      _ ≤ ε * Fintype.card F := hfield

end ReedSolomon.Parameters
end ProximityPrize
