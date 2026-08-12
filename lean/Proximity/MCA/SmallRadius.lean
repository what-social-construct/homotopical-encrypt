import Proximity.MCA.Pair
import Proximity.MCA.SpectrumCertificate

/-!
# Exact small-radius MCA certificates for Reed--Solomon codes

At count radius zero every bad challenge has the same witness set, so there is
at most one.  A unit-spike line realizes one bad challenge.  With two clean
coordinates, a two-spike line realizes the distinct bad challenges `0` and
`1` at radius one.  These are the upper and lower certificates needed to pin
the first nontrivial exact MCA threshold for small fields.
-/

namespace ProximityPrize
namespace ReedSolomon.Parameters

open BlockCode

variable {F ι : Type*}
variable [Field F] [Fintype F] [DecidableEq F]
variable [Fintype ι] [DecidableEq ι]

/-- A word supported at one coordinate. -/
def unitSpikeWord (i : ι) (a : F) : Word ι F :=
  fun j => if j = i then a else 0

omit [Fintype F] [DecidableEq F] [Fintype ι] in
@[simp]
theorem unitSpikeWord_same (i : ι) (a : F) :
    unitSpikeWord i a i = a := by
  simp [unitSpikeWord]

omit [Fintype F] [DecidableEq F] [Fintype ι] in
@[simp]
theorem unitSpikeWord_of_ne {i j : ι} (hji : j ≠ i) (a : F) :
    unitSpikeWord i a j = 0 := by
  simp [unitSpikeWord, hji]

/-- Zero base and one unit-spike direction. -/
def zeroSpikeLine (i : ι) : AffineLine ι F where
  base := fun _ => 0
  direction := unitSpikeWord i 1

/-- The affine line through the two unit-spike words at `i₀` and `i₁`. -/
def twoSpikeLine (i₀ i₁ : ι) : AffineLine ι F where
  base := unitSpikeWord i₀ 1
  direction := fun j => unitSpikeWord i₁ 1 j - unitSpikeWord i₀ 1 j

omit [DecidableEq ι] in
/-- A radius-zero large agreement set is the whole coordinate set. -/
theorem eq_univ_of_largeAgreementSet_zero
    {S : Finset ι}
    (hS : LargeAgreementSet 0 S) :
    S = Finset.univ := by
  have hlower : Fintype.card ι ≤ S.card := by
    simpa [LargeAgreementSet] using hS
  have hupper : S.card ≤ Fintype.card ι := by
    simpa using Finset.card_le_univ S
  exact S.card_eq_iff_eq_univ.mp (Nat.le_antisymm hupper hlower)

omit [DecidableEq ι] in
/-- Every affine line has at most one radius-zero bad challenge. -/
theorem badChallengeSet_zero_card_le_one
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (L : AffineLine ι F) :
    (P.toBlockCode.badChallengeSet 0 L).card ≤ 1 := by
  classical
  apply Finset.card_le_one_iff.mpr
  intro γ η hγ hη
  rw [P.toBlockCode.mem_badChallengeSet 0 L γ] at hγ
  rw [P.toBlockCode.mem_badChallengeSet 0 L η] at hη
  rcases hγ with ⟨Sγ, hlargeγ, hbadγ⟩
  rcases hη with ⟨Sη, hlargeη, hbadη⟩
  rw [eq_univ_of_largeAgreementSet_zero hlargeγ] at hbadγ
  rw [eq_univ_of_largeAgreementSet_zero hlargeη] at hbadη
  exact P.eq_of_badOnSet hDegree L Finset.univ hbadγ hbadη

omit [DecidableEq ι] in
/-- The whole coordinate set is large at radius zero. -/
theorem largeAgreementSet_zero_univ :
    LargeAgreementSet 0 (Finset.univ : Finset ι) := by
  simp [LargeAgreementSet]

/-- Removing one coordinate gives a radius-one large agreement set. -/
theorem largeAgreementSet_one_erase (i : ι) :
    LargeAgreementSet 1 ((Finset.univ : Finset ι).erase i) := by
  have hcard : 0 < Fintype.card ι := Fintype.card_pos_iff.mpr ⟨i⟩
  unfold LargeAgreementSet
  rw [Finset.card_erase_of_mem (Finset.mem_univ i)]
  simp only [Finset.card_univ]
  omega

omit [Fintype F] [DecidableEq F] in
/--
The unit-spike pair is not pair-close on all coordinates when `T` is a clean
`k`-set avoiding the spike coordinate.
-/
theorem zeroSpikeLine_not_pairCloseOnSet_univ
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (T : Finset ι)
    (hTcard : T.card = P.degreeBound)
    (i : ι)
    (hiT : i ∉ T) :
    ¬ P.PairCloseOnSet (zeroSpikeLine i) Finset.univ := by
  intro hclose
  rcases hclose with ⟨c, hc, hagree⟩
  have hzero : P.Codeword (fun _ => 0) :=
    (P.fAdditive_of_degreeBound_pos hDegree).zero_mem
  have hcDirection : P.Codeword (fun a => c a 1) := hc 1
  have hdirectionZero : (fun a => c a 1) = (fun _ => 0) := by
    apply P.determinedBy_degreeBound hcDirection hzero T hTcard
    intro a ha
    have hai : a ≠ i := by
      intro hai
      exact hiT (hai ▸ ha)
    calc
      c a 1 = pairWord (zeroSpikeLine i) a 1 :=
        (congrFun (hagree a (Finset.mem_univ a)) 1).symm
      _ = 0 := by simp [zeroSpikeLine, unitSpikeWord, hai]
  have hone : (1 : F) = c i 1 := by
    simpa [zeroSpikeLine, unitSpikeWord] using
      congrFun (hagree i (Finset.mem_univ i)) 1
  have hzeroAt : c i 1 = 0 := congrFun hdirectionZero i
  exact one_ne_zero (hone.trans hzeroAt)

omit [DecidableEq F] in
/-- Challenge zero is bad for the radius-zero unit-spike line. -/
theorem zero_mem_badChallengeSet_zeroSpikeLine
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (T : Finset ι)
    (hTcard : T.card = P.degreeBound)
    (i : ι)
    (hiT : i ∉ T) :
    (0 : F) ∈ P.toBlockCode.badChallengeSet 0 (zeroSpikeLine i) := by
  rw [P.toBlockCode.mem_badChallengeSet]
  refine ⟨Finset.univ, largeAgreementSet_zero_univ, ?_,
    P.zeroSpikeLine_not_pairCloseOnSet_univ hDegree T hTcard i hiT⟩
  refine ⟨fun _ => 0,
    (P.fAdditive_of_degreeBound_pos hDegree).zero_mem, ?_⟩
  intro a _ha
  simp [zeroSpikeLine]

omit [DecidableEq F] in
/-- The explicit radius-zero line has at least one bad challenge. -/
theorem one_le_badChallengeSet_zeroSpikeLine_card
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (T : Finset ι)
    (hTcard : T.card = P.degreeBound)
    (i : ι)
    (hiT : i ∉ T) :
    1 ≤ (P.toBlockCode.badChallengeSet 0 (zeroSpikeLine i)).card :=
  Finset.one_le_card.mpr
    ⟨0, P.zero_mem_badChallengeSet_zeroSpikeLine hDegree T hTcard i hiT⟩

omit [Fintype F] [DecidableEq F] in
/-- The two-spike line is not pair-close off its first spike coordinate. -/
theorem twoSpikeLine_not_pairCloseOnSet_erase_left
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (T : Finset ι)
    (hTcard : T.card = P.degreeBound)
    (i₀ i₁ : ι)
    (hi₀T : i₀ ∉ T)
    (hi₁T : i₁ ∉ T)
    (hne : i₀ ≠ i₁) :
    ¬ P.PairCloseOnSet (twoSpikeLine i₀ i₁) (Finset.univ.erase i₀) := by
  intro hclose
  rcases hclose with ⟨c, hc, hagree⟩
  have hzero : P.Codeword (fun _ => 0) :=
    (P.fAdditive_of_degreeBound_pos hDegree).zero_mem
  have hcDirection : P.Codeword (fun a => c a 1) := hc 1
  have hdirectionZero : (fun a => c a 1) = (fun _ => 0) := by
    apply P.determinedBy_degreeBound hcDirection hzero T hTcard
    intro a ha
    have ha₀ : a ≠ i₀ := by
      intro hai
      exact hi₀T (hai ▸ ha)
    have ha₁ : a ≠ i₁ := by
      intro hai
      exact hi₁T (hai ▸ ha)
    calc
      c a 1 = pairWord (twoSpikeLine i₀ i₁) a 1 := by
        symm
        apply congrFun (hagree a ?_) 1
        exact Finset.mem_erase.mpr ⟨ha₀, Finset.mem_univ a⟩
      _ = 0 := by simp [twoSpikeLine, unitSpikeWord, ha₀, ha₁]
  have hi₁S : i₁ ∈ (Finset.univ : Finset ι).erase i₀ :=
    Finset.mem_erase.mpr ⟨hne.symm, Finset.mem_univ i₁⟩
  have hone : (1 : F) = c i₁ 1 := by
    simpa [twoSpikeLine, unitSpikeWord, hne, hne.symm] using
      congrFun (hagree i₁ hi₁S) 1
  have hzeroAt : c i₁ 1 = 0 := congrFun hdirectionZero i₁
  exact one_ne_zero (hone.trans hzeroAt)

omit [Fintype F] [DecidableEq F] in
/-- The two-spike line is not pair-close off its second spike coordinate. -/
theorem twoSpikeLine_not_pairCloseOnSet_erase_right
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (T : Finset ι)
    (hTcard : T.card = P.degreeBound)
    (i₀ i₁ : ι)
    (hi₀T : i₀ ∉ T)
    (hi₁T : i₁ ∉ T)
    (hne : i₀ ≠ i₁) :
    ¬ P.PairCloseOnSet (twoSpikeLine i₀ i₁) (Finset.univ.erase i₁) := by
  intro hclose
  rcases hclose with ⟨c, hc, hagree⟩
  have hzero : P.Codeword (fun _ => 0) :=
    (P.fAdditive_of_degreeBound_pos hDegree).zero_mem
  have hcBase : P.Codeword (fun a => c a 0) := hc 0
  have hbaseZero : (fun a => c a 0) = (fun _ => 0) := by
    apply P.determinedBy_degreeBound hcBase hzero T hTcard
    intro a ha
    have ha₀ : a ≠ i₀ := by
      intro hai
      exact hi₀T (hai ▸ ha)
    have ha₁ : a ≠ i₁ := by
      intro hai
      exact hi₁T (hai ▸ ha)
    calc
      c a 0 = pairWord (twoSpikeLine i₀ i₁) a 0 := by
        symm
        apply congrFun (hagree a ?_) 0
        exact Finset.mem_erase.mpr ⟨ha₁, Finset.mem_univ a⟩
      _ = 0 := by simp [twoSpikeLine, unitSpikeWord, ha₀]
  have hi₀S : i₀ ∈ (Finset.univ : Finset ι).erase i₁ :=
    Finset.mem_erase.mpr ⟨hne, Finset.mem_univ i₀⟩
  have hone : (1 : F) = c i₀ 0 := by
    simpa [twoSpikeLine, unitSpikeWord] using
      congrFun (hagree i₀ hi₀S) 0
  have hzeroAt : c i₀ 0 = 0 := congrFun hbaseZero i₀
  exact one_ne_zero (hone.trans hzeroAt)

omit [DecidableEq F] in
/-- Challenge zero is bad for the radius-one two-spike line. -/
theorem zero_mem_badChallengeSet_twoSpikeLine
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (T : Finset ι)
    (hTcard : T.card = P.degreeBound)
    (i₀ i₁ : ι)
    (hi₀T : i₀ ∉ T)
    (hi₁T : i₁ ∉ T)
    (hne : i₀ ≠ i₁) :
    (0 : F) ∈ P.toBlockCode.badChallengeSet 1 (twoSpikeLine i₀ i₁) := by
  rw [P.toBlockCode.mem_badChallengeSet]
  refine ⟨Finset.univ.erase i₀, largeAgreementSet_one_erase i₀, ?_,
    P.twoSpikeLine_not_pairCloseOnSet_erase_left
      hDegree T hTcard i₀ i₁ hi₀T hi₁T hne⟩
  refine ⟨fun _ => 0,
    (P.fAdditive_of_degreeBound_pos hDegree).zero_mem, ?_⟩
  intro a ha
  have ha₀ : a ≠ i₀ := (Finset.mem_erase.mp ha).1
  simp [twoSpikeLine, unitSpikeWord, ha₀]

omit [DecidableEq F] in
/-- Challenge one is bad for the radius-one two-spike line. -/
theorem one_mem_badChallengeSet_twoSpikeLine
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (T : Finset ι)
    (hTcard : T.card = P.degreeBound)
    (i₀ i₁ : ι)
    (hi₀T : i₀ ∉ T)
    (hi₁T : i₁ ∉ T)
    (hne : i₀ ≠ i₁) :
    (1 : F) ∈ P.toBlockCode.badChallengeSet 1 (twoSpikeLine i₀ i₁) := by
  rw [P.toBlockCode.mem_badChallengeSet]
  refine ⟨Finset.univ.erase i₁, largeAgreementSet_one_erase i₁, ?_,
    P.twoSpikeLine_not_pairCloseOnSet_erase_right
      hDegree T hTcard i₀ i₁ hi₀T hi₁T hne⟩
  refine ⟨fun _ => 0,
    (P.fAdditive_of_degreeBound_pos hDegree).zero_mem, ?_⟩
  intro a ha
  have ha₁ : a ≠ i₁ := (Finset.mem_erase.mp ha).1
  simp [twoSpikeLine, unitSpikeWord, ha₁]

/-- The explicit radius-one line has at least two bad challenges. -/
theorem two_le_badChallengeSet_twoSpikeLine_card
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (T : Finset ι)
    (hTcard : T.card = P.degreeBound)
    (i₀ i₁ : ι)
    (hi₀T : i₀ ∉ T)
    (hi₁T : i₁ ∉ T)
    (hne : i₀ ≠ i₁) :
    2 ≤ (P.toBlockCode.badChallengeSet 1 (twoSpikeLine i₀ i₁)).card := by
  have hzero := P.zero_mem_badChallengeSet_twoSpikeLine
    hDegree T hTcard i₀ i₁ hi₀T hi₁T hne
  have hone := P.one_mem_badChallengeSet_twoSpikeLine
    hDegree T hTcard i₀ i₁ hi₀T hi₁T hne
  have hsubset :
      ({0, 1} : Finset F) ⊆
        P.toBlockCode.badChallengeSet 1 (twoSpikeLine i₀ i₁) := by
    intro γ hγ
    simp only [Finset.mem_insert, Finset.mem_singleton] at hγ
    rcases hγ with rfl | rfl
    · exact hzero
    · exact hone
  have hcard := Finset.card_le_card hsubset
  simpa using hcard

omit [DecidableEq F] in
/-- A clean radius-zero spike certificate exists whenever `k + 1 ≤ n`. -/
theorem exists_zeroSpikeLine_bad_of_degreeBound_succ_le
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound + 1 ≤ Fintype.card ι) :
    ∃ i : ι,
      (0 : F) ∈ P.toBlockCode.badChallengeSet 0 (zeroSpikeLine i) ∧
        1 ≤ (P.toBlockCode.badChallengeSet 0 (zeroSpikeLine i)).card := by
  classical
  have hk' : P.degreeBound ≤ (Finset.univ : Finset ι).card := by
    simp only [Finset.card_univ]
    omega
  obtain ⟨T, _hTuniv, hTcard⟩ := Finset.exists_subset_card_eq hk'
  have hTlt : T.card < (Finset.univ : Finset ι).card := by
    simpa [hTcard] using hk
  obtain ⟨i, _hiuniv, hiT⟩ :=
    Finset.exists_mem_notMem_of_card_lt_card hTlt
  exact ⟨i,
    P.zero_mem_badChallengeSet_zeroSpikeLine hDegree T hTcard i hiT,
    P.one_le_badChallengeSet_zeroSpikeLine_card hDegree T hTcard i hiT⟩

/-- A clean two-spike certificate exists whenever `k + 2 ≤ n`. -/
theorem exists_twoSpikeLine_bad_of_degreeBound_add_two_le
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound + 2 ≤ Fintype.card ι) :
    ∃ i₀ i₁ : ι,
      i₀ ≠ i₁ ∧
        2 ≤
          (P.toBlockCode.badChallengeSet 1 (twoSpikeLine i₀ i₁)).card := by
  classical
  have hk' : P.degreeBound ≤ (Finset.univ : Finset ι).card := by
    simp only [Finset.card_univ]
    omega
  obtain ⟨T, hTuniv, hTcard⟩ := Finset.exists_subset_card_eq hk'
  let U : Finset ι := Finset.univ \ T
  have hUcard : U.card = Fintype.card ι - P.degreeBound := by
    dsimp [U]
    rw [Finset.card_sdiff, Finset.inter_eq_left.mpr hTuniv,
      Finset.card_univ, hTcard]
  have hUtwo : 1 < U.card := by
    omega
  obtain ⟨i₀, hi₀U, i₁, hi₁U, hne⟩ := Finset.one_lt_card.mp hUtwo
  have hi₀T : i₀ ∉ T := (Finset.mem_sdiff.mp hi₀U).2
  have hi₁T : i₁ ∉ T := (Finset.mem_sdiff.mp hi₁U).2
  exact ⟨i₀, i₁, hne,
    P.two_le_badChallengeSet_twoSpikeLine_card
      hDegree T hTcard i₀ i₁ hi₀T hi₁T hne⟩

/-- The exact worst bad count at radius zero is one for every proper RS code. -/
theorem worstBadCount_zero_eq_one
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound + 1 ≤ Fintype.card ι) :
    P.toBlockCode.worstBadCount 0 = 1 := by
  apply Nat.le_antisymm
  · apply (P.toBlockCode.worstBadCount_le_iff 0 1).mpr
    intro L
    exact P.badChallengeSet_zero_card_le_one hDegree L
  · obtain ⟨i, _hzero, hcard⟩ :=
      P.exists_zeroSpikeLine_bad_of_degreeBound_succ_le hDegree hk
    exact hcard.trans
      (P.toBlockCode.badChallengeSet_card_le_worstBadCount
        0 (zeroSpikeLine i))

/--
If one bad challenge fits the field budget but two do not, radius zero is the
exact greatest safe grid radius.
-/
theorem pairMCAThreshold_zero_of_one_two_field_window
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound + 2 ≤ Fintype.card ι)
    (securityBits : ℕ)
    (hone : 2 ^ securityBits ≤ Fintype.card F)
    (htwo : Fintype.card F < 2 ^ securityBits * 2) :
    P.toBlockCode.pairMCAGreatestSafe securityBits = (0 : WithBot ℕ) ∧
      P.toBlockCode.pairMCAFirstUnsafe securityBits =
        ((1 : ℕ) : WithTop ℕ) := by
  obtain ⟨i₀, i₁, _hne, hcard⟩ :=
    P.exists_twoSpikeLine_bad_of_degreeBound_add_two_le hDegree hk
  apply P.toBlockCode.pairMCAThreshold_eq_of_countBound_and_badLine
      (securityBits := securityBits) (radius := 0) (upperBound := 1)
      (Lnext := twoSpikeLine (F := F) i₀ i₁)
  · omega
  · intro L
    exact P.badChallengeSet_zero_card_le_one hDegree L
  · simpa using hone
  · exact htwo.trans_le (Nat.mul_le_mul_left (2 ^ securityBits) hcard)

omit [DecidableEq F] in
/--
If even one bad challenge exceeds the field budget, no Hamming-grid radius is
secure and zero is the first unsafe radius.
-/
theorem pairMCABottomThreshold_of_field_lt_one_challenge_budget
    (P : ReedSolomon.Parameters F ι)
    (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound + 1 ≤ Fintype.card ι)
    (securityBits : ℕ)
    (hfield : Fintype.card F < 2 ^ securityBits) :
    P.toBlockCode.pairMCAGreatestSafe securityBits = ⊥ ∧
      P.toBlockCode.pairMCAFirstUnsafe securityBits =
        ((0 : ℕ) : WithTop ℕ) := by
  obtain ⟨i, _hzero, hcard⟩ :=
    P.exists_zeroSpikeLine_bad_of_degreeBound_succ_le hDegree hk
  apply P.toBlockCode.pairMCABottomThreshold_of_badLine
      securityBits (zeroSpikeLine i)
  exact hfield.trans_le (by
    simpa using Nat.mul_le_mul_left (2 ^ securityBits) hcard)

end ReedSolomon.Parameters
end ProximityPrize
