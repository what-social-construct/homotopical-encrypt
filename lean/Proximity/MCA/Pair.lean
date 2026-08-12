import Proximity.Core.ReedSolomon
import Proximity.Capacity.Parameters
import Proximity.MCA.Threshold
import Mathlib.Data.Fintype.Sigma
import Mathlib.LinearAlgebra.Lagrange

/-!
# Pair mutual correlated agreement

This module proves a uniform bad-challenge bound for the two-coordinate
affine-line formulation of mutual correlated agreement.  Every bad challenge
is assigned a certificate consisting of `k` interpolation coordinates and one
outside coordinate. Compressing this ordered data to its underlying
`(k+1)`-coordinate obstruction gives the sharp certificate count

`Nat.choose n (k + 1)`.

The theorem is independent of the radius: sets of at most `k` coordinates
always admit a pair of degree-`<k` interpolants and hence cannot witness an MCA
failure.
-/

namespace ProximityPrize
namespace ReedSolomon.Parameters

open BlockCode

variable {F ι : Type*}
variable [Field F] [Fintype F] [DecidableEq F]
variable [Fintype ι] [DecidableEq ι]

omit [Field F] [Fintype F] [DecidableEq F]
    [Fintype ι] [DecidableEq ι] in
@[simp]
theorem pairWord_zero (L : AffineLine ι F) (i : ι) :
    pairWord L i 0 = L.base i := by
  simp [pairWord]

omit [Field F] [Fintype F] [DecidableEq F]
    [Fintype ι] [DecidableEq ι] in
@[simp]
theorem pairWord_one (L : AffineLine ι F) (i : ι) :
    pairWord L i 1 = L.direction i := by
  simp [pairWord]

/-- RS compatibility name for generic pair-word agreement on a fixed set. -/
abbrev PairCloseOnSet
    (P : ReedSolomon.Parameters F ι)
    (L : AffineLine ι F)
    (S : Finset ι) : Prop :=
  P.toBlockCode.PairCloseOnSet L S

/-- RS compatibility name for a generic same-set MCA failure. -/
abbrev BadOnSet
    (P : ReedSolomon.Parameters F ι)
    (L : AffineLine ι F)
    (γ : F)
    (S : Finset ι) : Prop :=
  P.toBlockCode.BadOnSet L γ S

/-- RS compatibility name for the generic bad-challenge set. -/
noncomputable abbrev badChallengeSetAt
    (P : ReedSolomon.Parameters F ι)
    (δ : ℝ)
    (L : AffineLine ι F) : Finset F :=
  P.toBlockCode.badChallengeSetAt δ L

omit [DecidableEq F] [DecidableEq ι] in
theorem mem_badChallengeSetAt
    (P : ReedSolomon.Parameters F ι)
    (δ : ℝ)
    (L : AffineLine ι F)
    (γ : F) :
    γ ∈ P.badChallengeSetAt δ L ↔
      ∃ S : Finset ι,
        LargeAgreementSetAt δ S ∧ P.BadOnSet L γ S := by
  exact P.toBlockCode.mem_badChallengeSetAt δ L γ

/-- The Lagrange polynomial interpolating `w` on `S`. -/
noncomputable def interpolatePolynomial
    (P : ReedSolomon.Parameters F ι)
    (S : Finset ι)
    (w : Word ι F) : Polynomial F :=
  Lagrange.interpolate S P.domain.point w

/-- The evaluation word of the Lagrange interpolant. -/
noncomputable def interpolateWord
    (P : ReedSolomon.Parameters F ι)
    (S : Finset ι)
    (w : Word ι F) : Word ι F :=
  fun i => Polynomial.eval (P.domain.point i)
    (P.interpolatePolynomial S w)

omit [Fintype F] in
theorem interpolatePolynomial_natDegree_lt
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    {S : Finset ι}
    (hS : S.card = P.degreeBound)
    (w : Word ι F) :
    (P.interpolatePolynomial S w).natDegree < P.degreeBound := by
  have hdegree :
      (P.interpolatePolynomial S w).degree < (S.card : WithBot ℕ) :=
    Lagrange.degree_interpolate_lt w P.domain.injective_point.injOn
  by_cases hp : P.interpolatePolynomial S w = 0
  · simp [hp, hDegree]
  · apply (Polynomial.natDegree_lt_iff_degree_lt hp).2
    simpa [hS] using hdegree

omit [Fintype F] in
theorem interpolateWord_codeword
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    {S : Finset ι}
    (hS : S.card = P.degreeBound)
    (w : Word ι F) :
    P.Codeword (P.interpolateWord S w) := by
  exact ⟨P.interpolatePolynomial S w,
    P.interpolatePolynomial_natDegree_lt hDegree hS w, fun _ => rfl⟩

omit [Fintype F] [DecidableEq F] in
theorem interpolateWord_eq_on
    (P : ReedSolomon.Parameters F ι)
    (S : Finset ι)
    (w : Word ι F)
    {i : ι}
    (hi : i ∈ S) :
    P.interpolateWord S w i = w i := by
  exact Lagrange.eval_interpolate_at_node w
    P.domain.injective_point.injOn hi

/-- Interpolate both components of an affine-line presentation on `S`. -/
noncomputable def interpolatePair
    (P : ReedSolomon.Parameters F ι)
    (S : Finset ι)
    (L : AffineLine ι F) : PlaneWord ι F :=
  fun i j => P.interpolateWord S (fun a => pairWord L a j) i

omit [Fintype F] in
theorem interpolatePair_codeword
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    {S : Finset ι}
    (hS : S.card = P.degreeBound)
    (L : AffineLine ι F) :
    (P.vectorBlockCode (Fin 2)).Codeword
      (P.interpolatePair S L) := by
  intro j
  exact P.interpolateWord_codeword hDegree hS
    (fun a => pairWord L a j)

omit [Fintype F] [DecidableEq F] in
theorem pairWord_eq_interpolatePair_on
    (P : ReedSolomon.Parameters F ι)
    (S : Finset ι)
    (L : AffineLine ι F)
    {i : ι}
    (hi : i ∈ S) :
    pairWord L i = P.interpolatePair S L i := by
  funext j
  exact (P.interpolateWord_eq_on S (fun a => pairWord L a j) hi).symm

omit [Fintype F] in
/-- Every set of at most `k` coordinates admits a pair-codeword extension. -/
theorem pairCloseOnSet_of_card_le
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (L : AffineLine ι F)
    {S : Finset ι}
    (hS : S.card ≤ P.degreeBound) :
    P.PairCloseOnSet L S := by
  have hcardUniv :
      P.degreeBound ≤ (Finset.univ : Finset ι).card := by
    simpa using hk
  obtain ⟨T, hST, _hTuniv, hT⟩ :=
    Finset.exists_subsuperset_card_eq S.subset_univ hS hcardUniv
  exact ⟨P.interpolatePair T L,
    P.interpolatePair_codeword hDegree hT L, fun i hi =>
      P.pairWord_eq_interpolatePair_on T L (hST hi)⟩

omit [Fintype F] in
/-- A same-set MCA failure requires more than `k` agreement coordinates. -/
theorem degreeBound_lt_card_of_badOnSet
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (L : AffineLine ι F)
    (γ : F)
    {S : Finset ι}
    (hbad : P.BadOnSet L γ S) :
    P.degreeBound < S.card := by
  by_contra h
  exact hbad.2 (P.pairCloseOnSet_of_card_le hDegree hk L
    (Nat.le_of_not_gt h))

omit [Fintype F] [DecidableEq F] [DecidableEq ι] in
/--
Two distinct scalar challenges that are close on the same coordinate set
force the affine-line base and direction to be pair-close on that set.

This is the linear-algebra step that lets the certificate proof forget which
`k` coordinates inside a `(k+1)`-coordinate obstruction were used for
interpolation.
-/
theorem pairCloseOnSet_of_closeOnSet_two_challenges
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (L : AffineLine ι F)
    {γ η : F}
    (hγη : γ ≠ η)
    (S : Finset ι)
    (hγ : CloseOnSet P.toBlockCode (L.point γ) S)
    (hη : CloseOnSet P.toBlockCode (L.point η) S) :
    P.PairCloseOnSet L S := by
  rcases hγ with ⟨cγ, hcγ, hagreeγ⟩
  rcases hη with ⟨cη, hcη, hagreeη⟩
  let directionWord : Word ι F :=
    fun i => (γ - η)⁻¹ * (cγ i - cη i)
  let baseWord : Word ι F :=
    fun i => cγ i - γ * directionWord i
  have hlinear := P.fAdditive_of_degreeBound_pos hDegree
  have hdiff : P.Codeword (fun i => cγ i - cη i) := by
    have hneg :=
      hlinear.smul_mem (-1 : F) hcη
    simpa [sub_eq_add_neg, smul_eq_mul] using
      hlinear.add_mem hcγ hneg
  have hdirection : P.Codeword directionWord := by
    simpa [directionWord, smul_eq_mul] using
      hlinear.smul_mem (γ - η)⁻¹ hdiff
  have hbase : P.Codeword baseWord := by
    have hscaled :=
      hlinear.smul_mem (-γ) hdirection
    simpa [baseWord, sub_eq_add_neg, smul_eq_mul] using
      hlinear.add_mem hcγ hscaled
  have hdirectionOn :
      ∀ i : ι, i ∈ S → directionWord i = L.direction i := by
    intro i hi
    have hsub : γ - η ≠ 0 := sub_ne_zero.mpr hγη
    dsimp [directionWord]
    rw [← hagreeγ i hi, ← hagreeη i hi]
    simp only [AffineLine.point_apply]
    calc
      (γ - η)⁻¹ *
          ((L.base i + γ * L.direction i) -
            (L.base i + η * L.direction i)) =
          (γ - η)⁻¹ * ((γ - η) * L.direction i) := by ring
      _ = L.direction i := by
        rw [← mul_assoc, inv_mul_cancel₀ hsub, one_mul]
  have hbaseOn :
      ∀ i : ι, i ∈ S → baseWord i = L.base i := by
    intro i hi
    dsimp [baseWord]
    rw [← hagreeγ i hi, hdirectionOn i hi]
    simp only [AffineLine.point_apply]
    ring
  refine ⟨fun i j => if j = 0 then baseWord i else directionWord i, ?_, ?_⟩
  · intro j
    fin_cases j
    · simpa using hbase
    · simpa using hdirection
  · intro i hi
    funext j
    fin_cases j
    · simpa [pairWord] using (hbaseOn i hi).symm
    · simpa [pairWord] using (hdirectionOn i hi).symm

omit [Fintype F] [DecidableEq ι] in
/-- A fixed same-set failure can be witnessed by at most one challenge. -/
theorem eq_of_badOnSet
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (L : AffineLine ι F)
    {γ η : F}
    (S : Finset ι)
    (hγ : P.BadOnSet L γ S)
    (hη : P.BadOnSet L η S) :
    γ = η := by
  by_contra hγη
  exact hγ.2
    (P.pairCloseOnSet_of_closeOnSet_two_challenges
      hDegree L hγη S hγ.1 hη.1)

/-- Certificates are a `k`-subset and one coordinate outside it. -/
abbrev Certificate (ι : Type*) [Fintype ι] (k : ℕ) :=
  Σ T : {T : Finset ι // T.card = k}, {i : ι // i ∉ T.1}

/-- Compressed certificates remember only the resulting `(k+1)`-subset. -/
abbrev CompressedCertificate (ι : Type*) (k : ℕ) :=
  {U : Finset ι // U.card = k + 1}

section CertificateSelection

variable
    (P : ReedSolomon.Parameters F ι)
    (δ : ℝ)
    (L : AffineLine ι F)

abbrev BadChallenge :=
  {γ : F // γ ∈ P.badChallengeSetAt δ L}

/-- Select one same-set witness for a bad challenge. -/
noncomputable def witnessSet (γ : P.BadChallenge δ L) : Finset ι :=
  (P.mem_badChallengeSetAt δ L γ.1).1 γ.2 |>.choose

omit [DecidableEq F] [DecidableEq ι] in
theorem witnessSet_spec (γ : P.BadChallenge δ L) :
    LargeAgreementSetAt δ (P.witnessSet δ L γ) ∧
      P.BadOnSet L γ.1 (P.witnessSet δ L γ) :=
  (P.mem_badChallengeSetAt δ L γ.1).1 γ.2 |>.choose_spec

theorem degreeBound_lt_witnessSet_card
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (γ : P.BadChallenge δ L) :
    P.degreeBound < (P.witnessSet δ L γ).card :=
  P.degreeBound_lt_card_of_badOnSet hDegree hk L γ.1
    (P.witnessSet_spec δ L γ).2

/-- Select `k` interpolation coordinates inside the bad witness set. -/
noncomputable def certificateSubset
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (γ : P.BadChallenge δ L) : Finset ι :=
  (Finset.exists_subset_card_eq
    (Nat.le_of_lt
      (P.degreeBound_lt_witnessSet_card δ L hDegree hk γ))).choose

theorem certificateSubset_subset
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (γ : P.BadChallenge δ L) :
    P.certificateSubset δ L hDegree hk γ ⊆ P.witnessSet δ L γ :=
  (Finset.exists_subset_card_eq
    (Nat.le_of_lt
      (P.degreeBound_lt_witnessSet_card δ L hDegree hk γ))).choose_spec.1

theorem certificateSubset_card
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (γ : P.BadChallenge δ L) :
    (P.certificateSubset δ L hDegree hk γ).card = P.degreeBound :=
  (Finset.exists_subset_card_eq
    (Nat.le_of_lt
      (P.degreeBound_lt_witnessSet_card δ L hDegree hk γ))).choose_spec.2

theorem exists_mismatch_outside_certificate
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (γ : P.BadChallenge δ L) :
    ∃ i : ι,
      i ∈ P.witnessSet δ L γ ∧
      pairWord L i ≠
        P.interpolatePair
          (P.certificateSubset δ L hDegree hk γ) L i := by
  by_contra h
  push_neg at h
  exact (P.witnessSet_spec δ L γ).2.2
    ⟨P.interpolatePair (P.certificateSubset δ L hDegree hk γ) L,
      P.interpolatePair_codeword hDegree
        (P.certificateSubset_card δ L hDegree hk γ) L,
      fun i hi => h i hi⟩

/-- Select one coordinate where the pair interpolation fails. -/
noncomputable def certificatePoint
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (γ : P.BadChallenge δ L) : ι :=
  (P.exists_mismatch_outside_certificate δ L hDegree hk γ).choose

theorem certificatePoint_mem_witnessSet
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (γ : P.BadChallenge δ L) :
    P.certificatePoint δ L hDegree hk γ ∈ P.witnessSet δ L γ :=
  (P.exists_mismatch_outside_certificate δ L hDegree hk γ).choose_spec.1

theorem pairWord_ne_interpolatePair_at_certificatePoint
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (γ : P.BadChallenge δ L) :
    pairWord L (P.certificatePoint δ L hDegree hk γ) ≠
      P.interpolatePair (P.certificateSubset δ L hDegree hk γ) L
        (P.certificatePoint δ L hDegree hk γ) :=
  (P.exists_mismatch_outside_certificate δ L hDegree hk γ).choose_spec.2

theorem certificatePoint_not_mem_subset
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (γ : P.BadChallenge δ L) :
    P.certificatePoint δ L hDegree hk γ ∉
      P.certificateSubset δ L hDegree hk γ := by
  intro hi
  exact P.pairWord_ne_interpolatePair_at_certificatePoint
    δ L hDegree hk γ
    (P.pairWord_eq_interpolatePair_on
      (P.certificateSubset δ L hDegree hk γ) L hi)

/-- The finite certificate attached to a bad challenge. -/
noncomputable def certificate
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (γ : P.BadChallenge δ L) :
    Certificate ι P.degreeBound :=
  ⟨⟨P.certificateSubset δ L hDegree hk γ,
      P.certificateSubset_card δ L hDegree hk γ⟩,
    ⟨P.certificatePoint δ L hDegree hk γ,
      P.certificatePoint_not_mem_subset δ L hDegree hk γ⟩⟩

/--
Forget the ordering of the interpolation subset and mismatch point.  The
resulting `(k+1)`-subset is the actual local MCA obstruction.
-/
noncomputable def compressedCertificate
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (γ : P.BadChallenge δ L) :
    CompressedCertificate ι P.degreeBound :=
  ⟨insert
      (P.certificatePoint δ L hDegree hk γ)
      (P.certificateSubset δ L hDegree hk γ), by
    rw [Finset.card_insert_of_notMem
      (P.certificatePoint_not_mem_subset δ L hDegree hk γ)]
    exact congrArg (· + 1)
      (P.certificateSubset_card δ L hDegree hk γ)⟩

theorem compressedCertificate_subset_witnessSet
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (γ : P.BadChallenge δ L) :
    (P.compressedCertificate δ L hDegree hk γ).1 ⊆
      P.witnessSet δ L γ := by
  intro i hi
  change i ∈ insert
    (P.certificatePoint δ L hDegree hk γ)
    (P.certificateSubset δ L hDegree hk γ) at hi
  rcases Finset.mem_insert.1 hi with rfl | hi
  · exact P.certificatePoint_mem_witnessSet δ L hDegree hk γ
  · exact P.certificateSubset_subset δ L hDegree hk γ hi

/-- The compressed `(k+1)`-subset still witnesses the same bad challenge. -/
theorem badOnSet_compressedCertificate
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (γ : P.BadChallenge δ L) :
    P.BadOnSet L γ.1
      (P.compressedCertificate δ L hDegree hk γ).1 := by
  let T := P.certificateSubset δ L hDegree hk γ
  let i := P.certificatePoint δ L hDegree hk γ
  constructor
  · rcases (P.witnessSet_spec δ L γ).2.1 with
      ⟨c, hc, hagree⟩
    exact ⟨c, hc, fun a ha =>
      hagree a
        (P.compressedCertificate_subset_witnessSet
          δ L hDegree hk γ ha)⟩
  · rintro ⟨c, hc, hagree⟩
    have hinterpolate :
        (P.vectorBlockCode (Fin 2)).Codeword
          (P.interpolatePair T L) :=
      P.interpolatePair_codeword hDegree
        (P.certificateSubset_card δ L hDegree hk γ) L
    have hc_eq :
        c = P.interpolatePair T L := by
      apply P.vectorDeterminedBy_degreeBound (Fin 2)
        hc hinterpolate T
        (P.certificateSubset_card δ L hDegree hk γ)
      intro a ha
      have haCompressed :
          a ∈ (P.compressedCertificate δ L hDegree hk γ).1 := by
        exact Finset.mem_insert_of_mem ha
      exact (hagree a haCompressed).symm.trans
        (P.pairWord_eq_interpolatePair_on T L ha)
    apply P.pairWord_ne_interpolatePair_at_certificatePoint
      δ L hDegree hk γ
    calc
      pairWord L i = c i := by
        apply hagree
        exact Finset.mem_insert_self i T
      _ = P.interpolatePair T L i := congrFun hc_eq i

/-- The compressed certificate is injective on bad challenges. -/
theorem compressedCertificate_injective
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) :
    Function.Injective (P.compressedCertificate δ L hDegree hk) := by
  intro γ η hcertificate
  apply Subtype.ext
  have hsets :
      (P.compressedCertificate δ L hDegree hk γ).1 =
        (P.compressedCertificate δ L hDegree hk η).1 :=
    congrArg Subtype.val hcertificate
  apply P.eq_of_badOnSet hDegree L
    (P.compressedCertificate δ L hDegree hk γ).1
    (P.badOnSet_compressedCertificate δ L hDegree hk γ)
  rw [hsets]
  exact P.badOnSet_compressedCertificate δ L hDegree hk η

theorem challengeEquation
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (γ : P.BadChallenge δ L) :
    let T := P.certificateSubset δ L hDegree hk γ
    let i := P.certificatePoint δ L hDegree hk γ
    (L.base i - P.interpolateWord T L.base i) +
        γ.1 * (L.direction i - P.interpolateWord T L.direction i) = 0 := by
  dsimp only
  let T := P.certificateSubset δ L hDegree hk γ
  let i := P.certificatePoint δ L hDegree hk γ
  rcases (P.witnessSet_spec δ L γ).2.1 with
    ⟨c, hc, hagree⟩
  have hbase :
      P.Codeword (P.interpolateWord T L.base) :=
    P.interpolateWord_codeword hDegree
      (P.certificateSubset_card δ L hDegree hk γ) L.base
  have hdirection :
      P.Codeword (P.interpolateWord T L.direction) :=
    P.interpolateWord_codeword hDegree
      (P.certificateSubset_card δ L hDegree hk γ) L.direction
  have hlinear := P.fAdditive_of_degreeBound_pos hDegree
  have hcombo :
      P.Codeword (fun a =>
        P.interpolateWord T L.base a +
          γ.1 * P.interpolateWord T L.direction a) := by
    have hsmul :=
      hlinear.smul_mem γ.1 hdirection
    simpa [smul_eq_mul] using hlinear.add_mem hbase hsmul
  have hc_eq :
      c = fun a =>
        P.interpolateWord T L.base a +
          γ.1 * P.interpolateWord T L.direction a := by
    apply P.determinedBy_degreeBound hc hcombo T
      (P.certificateSubset_card δ L hDegree hk γ)
    intro a ha
    calc
      c a = L.point γ.1 a :=
        (hagree a
          (P.certificateSubset_subset δ L hDegree hk γ ha)).symm
      _ = L.base a + γ.1 * L.direction a := rfl
      _ = P.interpolateWord T L.base a +
          γ.1 * P.interpolateWord T L.direction a := by
            rw [P.interpolateWord_eq_on T L.base ha,
              P.interpolateWord_eq_on T L.direction ha]
  have hpoint :
      L.point γ.1 i =
        P.interpolateWord T L.base i +
          γ.1 * P.interpolateWord T L.direction i := by
    exact (hagree i
      (P.certificatePoint_mem_witnessSet δ L hDegree hk γ)).trans
        (congrFun hc_eq i)
  calc
    (L.base i - P.interpolateWord T L.base i) +
          γ.1 * (L.direction i - P.interpolateWord T L.direction i) =
        L.point γ.1 i -
          (P.interpolateWord T L.base i +
            γ.1 * P.interpolateWord T L.direction i) := by
              simp only [AffineLine.point_apply]
              ring
    _ = 0 := sub_eq_zero.mpr hpoint

theorem directionError_ne_zero
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (γ : P.BadChallenge δ L) :
    let T := P.certificateSubset δ L hDegree hk γ
    let i := P.certificatePoint δ L hDegree hk γ
    L.direction i - P.interpolateWord T L.direction i ≠ 0 := by
  dsimp only
  let T := P.certificateSubset δ L hDegree hk γ
  let i := P.certificatePoint δ L hDegree hk γ
  intro hdirection
  have hequation := P.challengeEquation δ L hDegree hk γ
  have hbase :
      L.base i - P.interpolateWord T L.base i = 0 := by
    simpa [T, i, hdirection] using hequation
  have hbase_eq :
      L.base i = P.interpolateWord T L.base i :=
    sub_eq_zero.mp hbase
  have hdirection_eq :
      L.direction i = P.interpolateWord T L.direction i :=
    sub_eq_zero.mp hdirection
  apply P.pairWord_ne_interpolatePair_at_certificatePoint
    δ L hDegree hk γ
  funext j
  fin_cases j
  · simpa [pairWord, interpolatePair, T, i] using hbase_eq
  · simpa [pairWord, interpolatePair, T, i] using hdirection_eq

theorem certificate_injective
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) :
    Function.Injective (P.certificate δ L hDegree hk) := by
  intro γ η hcertificate
  apply Subtype.ext
  have hT :
      P.certificateSubset δ L hDegree hk γ =
        P.certificateSubset δ L hDegree hk η :=
    congrArg (fun c : Certificate ι P.degreeBound => c.1.1)
      hcertificate
  have hi :
      P.certificatePoint δ L hDegree hk γ =
        P.certificatePoint δ L hDegree hk η :=
    congrArg (fun c : Certificate ι P.degreeBound => c.2.1)
      hcertificate
  let T := P.certificateSubset δ L hDegree hk γ
  let i := P.certificatePoint δ L hDegree hk γ
  let baseError :=
    L.base i - P.interpolateWord T L.base i
  let directionError :=
    L.direction i - P.interpolateWord T L.direction i
  have hγ := P.challengeEquation δ L hDegree hk γ
  have hη := P.challengeEquation δ L hDegree hk η
  change baseError + γ.1 * directionError = 0 at hγ
  rw [← hT, ← hi] at hη
  change baseError + η.1 * directionError = 0 at hη
  have hdirection :
      directionError ≠ 0 := by
    exact P.directionError_ne_zero δ L hDegree hk γ
  apply mul_right_cancel₀ hdirection
  calc
    γ.1 * directionError = -baseError := by
      calc
        γ.1 * directionError =
            (baseError + γ.1 * directionError) - baseError := by ring
        _ = -baseError := by rw [hγ]; simp
    _ = η.1 * directionError := by
      symm
      calc
        η.1 * directionError =
            (baseError + η.1 * directionError) - baseError := by ring
        _ = -baseError := by rw [hη]; simp

end CertificateSelection

theorem card_certificate
    (k : ℕ) :
    Fintype.card (Certificate ι k) =
      Nat.choose (Fintype.card ι) k * (Fintype.card ι - k) := by
  classical
  rw [Fintype.card_sigma]
  calc
    (∑ T : {T : Finset ι // T.card = k},
        Fintype.card {i : ι // i ∉ T.1}) =
        ∑ _T : {T : Finset ι // T.card = k},
          (Fintype.card ι - k) := by
            apply Finset.sum_congr rfl
            intro T _hT
            rw [Fintype.card_subtype_compl]
            change Fintype.card ι - Fintype.card T.1 =
              Fintype.card ι - k
            rw [Fintype.card_coe, T.2]
    _ = Fintype.card {T : Finset ι // T.card = k} *
          (Fintype.card ι - k) := by simp
    _ = Nat.choose (Fintype.card ι) k *
          (Fintype.card ι - k) := by
            rw [Fintype.card_finset_len]

omit [DecidableEq ι] in
/-- There are exactly `choose n (k+1)` compressed certificates. -/
theorem card_compressedCertificate
    (k : ℕ) :
    Fintype.card (CompressedCertificate ι k) =
      Nat.choose (Fintype.card ι) (k + 1) := by
  classical
  exact Fintype.card_finset_len (α := ι) (k + 1)

/--
Uniform pair-MCA bound.  It holds at every radius because the proof ignores
the large-set inequality after extracting a same-set failure witness.
-/
theorem badChallengeSetAt_card_le
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (δ : ℝ)
    (L : AffineLine ι F) :
    (P.badChallengeSetAt δ L).card ≤
      Nat.choose (Fintype.card ι) P.degreeBound *
        (Fintype.card ι - P.degreeBound) := by
  classical
  calc
    (P.badChallengeSetAt δ L).card =
        Fintype.card (P.BadChallenge δ L) := by
          rw [Fintype.card_coe]
    _ ≤ Fintype.card (Certificate ι P.degreeBound) :=
      Fintype.card_le_of_injective
        (P.certificate δ L hDegree hk)
        (P.certificate_injective δ L hDegree hk)
    _ = Nat.choose (Fintype.card ι) P.degreeBound *
          (Fintype.card ι - P.degreeBound) :=
      card_certificate P.degreeBound

/--
Sharper uniform pair-MCA bound.  A certificate is intrinsically an unordered
`(k+1)`-subset, so the ordered `(T,i)` count above overcounts by `k+1`.
-/
theorem badChallengeSetAt_card_le_choose_succ
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (δ : ℝ)
    (L : AffineLine ι F) :
    (P.badChallengeSetAt δ L).card ≤
      Nat.choose (Fintype.card ι) (P.degreeBound + 1) := by
  classical
  calc
    (P.badChallengeSetAt δ L).card =
        Fintype.card (P.BadChallenge δ L) := by
          rw [Fintype.card_coe]
    _ ≤ Fintype.card (CompressedCertificate ι P.degreeBound) :=
      Fintype.card_le_of_injective
        (P.compressedCertificate δ L hDegree hk)
        (P.compressedCertificate_injective δ L hDegree hk)
    _ = Nat.choose (Fintype.card ι) (P.degreeBound + 1) :=
      card_compressedCertificate P.degreeBound

/-- Count-radius form of the compressed-certificate bound. -/
theorem badChallengeSet_card_le_choose_succ
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (r : ℕ)
    (L : AffineLine ι F) :
    (P.toBlockCode.badChallengeSet r L).card ≤
      Nat.choose (Fintype.card ι) (P.degreeBound + 1) := by
  have hlength : 0 < Fintype.card ι :=
    hDegree.trans_le hk
  rw [← P.toBlockCode.badChallengeSetAt_relativeRadius_eq hlength L]
  exact P.badChallengeSetAt_card_le_choose_succ
    hDegree hk (BlockCode.relativeRadius (ι := ι) r) L

/-- Uniform count-bound predicate supplied by the compressed certificates. -/
theorem pairMCACountBound_choose_succ
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (r : ℕ) :
    P.toBlockCode.PairMCACountBound r
      (Nat.choose (Fintype.card ι) (P.degreeBound + 1)) := by
  intro L
  exact P.badChallengeSet_card_le_choose_succ hDegree hk r L

/-- Exact integer security from the compressed-certificate field budget. -/
theorem pairMCASecureAtBits_of_choose_succ_budget
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (securityBits r : ℕ)
    (hbudget :
      2 ^ securityBits *
          Nat.choose (Fintype.card ι) (P.degreeBound + 1) ≤
        Fintype.card F) :
    P.toBlockCode.PairMCASecureAtBits securityBits r := by
  exact P.toBlockCode.pairMCASecureAtBits_of_countBound
    (P.pairMCACountBound_choose_succ hDegree hk r) hbudget

/--
If the compressed-certificate budget holds, the greatest secure Hamming-grid
radius is the full block length.
-/
theorem pairMCAGreatestSafe_eq_length_of_choose_succ_budget
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (securityBits : ℕ)
    (hbudget :
      2 ^ securityBits *
          Nat.choose (Fintype.card ι) (P.degreeBound + 1) ≤
        Fintype.card F) :
    P.toBlockCode.pairMCAGreatestSafe securityBits =
      (Fintype.card ι : WithBot ℕ) := by
  apply FiniteThreshold.greatestSafe_eq_coe_iff.mpr
  refine ⟨le_rfl,
    P.pairMCASecureAtBits_of_choose_succ_budget
      hDegree hk securityBits (Fintype.card ι) hbudget, ?_⟩
  intro s hs _hsafe
  exact hs

/-- RS compatibility name for the generic challenge fraction. -/
noncomputable abbrev challengeFraction (S : Finset F) : ℝ :=
  BlockCode.challengeFraction S

/-- RS compatibility name for the generic pair-MCA error predicate. -/
abbrev PairMCAErrorBoundAt
    (P : ReedSolomon.Parameters F ι)
    (δ ε : ℝ) : Prop :=
  P.toBlockCode.PairMCAErrorBoundAt δ ε

theorem pairMCAErrorBoundAt_of_budget
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (δ ε : ℝ)
    (hbudget :
      (Nat.choose (Fintype.card ι) P.degreeBound *
          (Fintype.card ι - P.degreeBound) : ℝ) ≤
        ε * Fintype.card F) :
    P.PairMCAErrorBoundAt δ ε := by
  intro L
  have hfield : (0 : ℝ) < Fintype.card F := by
    exact_mod_cast Fintype.card_pos
  unfold BlockCode.challengeFraction
  apply (div_le_iff₀ hfield).2
  have hcast :
      ((P.badChallengeSetAt δ L).card : ℝ) ≤
        Nat.choose (Fintype.card ι) P.degreeBound *
          (Fintype.card ι - P.degreeBound) := by
    exact_mod_cast P.badChallengeSetAt_card_le hDegree hk δ L
  exact hcast.trans hbudget

/-- Pair-MCA error bound from the sharper compressed-certificate budget. -/
theorem pairMCAErrorBoundAt_of_compressed_budget
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (δ ε : ℝ)
    (hbudget :
      (Nat.choose (Fintype.card ι) (P.degreeBound + 1) : ℝ) ≤
        ε * Fintype.card F) :
    P.PairMCAErrorBoundAt δ ε := by
  intro L
  have hfield : (0 : ℝ) < Fintype.card F := by
    exact_mod_cast Fintype.card_pos
  unfold BlockCode.challengeFraction
  apply (div_le_iff₀ hfield).2
  have hcast :
      ((P.badChallengeSetAt δ L).card : ℝ) ≤
        Nat.choose (Fintype.card ι) (P.degreeBound + 1) := by
    exact_mod_cast
      P.badChallengeSetAt_card_le_choose_succ hDegree hk δ L
  exact hcast.trans hbudget

end ReedSolomon.Parameters

namespace Capacity.SmoothQuarterFamily

/--
Every Reed--Solomon realization of the explicit smooth quarter-rate numerical
family has pair-MCA error at most `2⁻¹²⁸`, at every radius.  The realization
hypotheses identify the abstract coordinate and field cardinalities with the
family's numerical parameters.
-/
theorem pairMCAErrorBoundAt
    {F ι : Type*}
    [Field F] [Fintype F] [DecidableEq F]
    [Fintype ι] [DecidableEq ι]
    (u : ℕ)
    (P : ReedSolomon.Parameters F ι)
    (hLength : Fintype.card ι = length u)
    (hField : Fintype.card F = fieldCard u)
    (hDegree : P.degreeBound = degreeBound u)
    (δ : ℝ) :
    P.PairMCAErrorBoundAt δ ((1 : ℝ) / 2 ^ 128) := by
  have hDegreePos : 0 < P.degreeBound := by
    rw [hDegree]
    unfold degreeBound
    exact Nat.mul_pos (by norm_num) (pow_pos (by norm_num) u)
  have hDegreeLe : P.degreeBound ≤ Fintype.card ι := by
    rw [hDegree, hLength]
    unfold degreeBound length
    exact Nat.mul_le_mul_right (2 ^ u) (by norm_num)
  apply P.pairMCAErrorBoundAt_of_compressed_budget hDegreePos hDegreeLe
  rw [hLength, hDegree, hField]
  have hnat := compressed_pair_mca_certificate_target u
  have hcast :
      (2 : ℝ) ^ 128 *
          (Nat.choose (length u) (degreeBound u + 1) : ℕ) ≤
        fieldCard u := by
    exact_mod_cast hnat
  have hpow : (0 : ℝ) < 2 ^ 128 := by positivity
  rw [show
      ((1 : ℝ) / 2 ^ 128) * fieldCard u =
        (fieldCard u : ℝ) / 2 ^ 128 by ring]
  apply (le_div_iff₀ hpow).2
  simpa [mul_comm] using hcast

/--
The explicit smooth quarter-rate family has full-length greatest safe grid
radius at 128-bit MCA security.
-/
theorem pairMCAGreatestSafe_eq_length
    {F ι : Type*}
    [Field F] [Fintype F] [DecidableEq F]
    [Fintype ι] [DecidableEq ι]
    (u : ℕ)
    (P : ReedSolomon.Parameters F ι)
    (hLength : Fintype.card ι = length u)
    (hField : Fintype.card F = fieldCard u)
    (hDegree : P.degreeBound = degreeBound u) :
    P.toBlockCode.pairMCAGreatestSafe 128 =
      (length u : WithBot ℕ) := by
  have hDegreePos : 0 < P.degreeBound := by
    rw [hDegree]
    unfold degreeBound
    exact Nat.mul_pos (by norm_num) (pow_pos (by norm_num) u)
  have hDegreeLe : P.degreeBound ≤ Fintype.card ι := by
    rw [hDegree, hLength]
    unfold degreeBound length
    exact Nat.mul_le_mul_right (2 ^ u) (by norm_num)
  rw [← hLength]
  apply P.pairMCAGreatestSafe_eq_length_of_choose_succ_budget
    hDegreePos hDegreeLe 128
  rw [hLength, hDegree, hField]
  exact compressed_pair_mca_certificate_target u

end Capacity.SmoothQuarterFamily
end ProximityPrize
