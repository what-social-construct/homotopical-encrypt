module

public import Proximity.MCA.Threshold
public import Proximity.MCA.BoundaryField
public import Proximity.Core.RadiusShell

@[expose] public section

/-!
# Real pair-MCA thresholds and the boundary-field safe interval

The same-set experiment changes only at integral Hamming shells. A secure
count-zero radius followed by an insecure count-one radius therefore gives
the exact real interval `[0,1/n)`, including its nonattained supremum.
-/

namespace ProximityCoding
namespace BlockCode

variable {ι F : Type*} [Fintype ι] [Fintype F] [Add F] [Mul F]

theorem largeAgreementSetAt_iff_count_of_mem_shell
    {r : ℕ} {δ : ℝ} {S : Finset ι}
    (hn : 0 < Fintype.card ι)
    (hlo : relativeRadius (ι := ι) r ≤ δ)
    (hhi : δ < relativeRadius (ι := ι) (r + 1)) :
    LargeAgreementSetAt δ S ↔ LargeAgreementSet r S := by
  have hnR : (0 : ℝ) < Fintype.card ι := by exact_mod_cast hn
  have hS : S.card ≤ Fintype.card ι := Finset.card_le_univ S
  have hcomplement : LargeAgreementSetAt δ S ↔
      ((Fintype.card ι - S.card : ℕ) : ℝ) / Fintype.card ι ≤ δ := by
    unfold LargeAgreementSetAt coordinateFraction
    rw [le_div_iff₀ hnR, div_le_iff₀ hnR, Nat.cast_sub hS]
    constructor <;> intro h <;> nlinarith
  rw [hcomplement, RadiusShell.div_le_iff_count_le_of_mem_shell hn hlo hhi]
  unfold LargeAgreementSet
  omega

theorem badChallengeSetAt_eq_badChallengeSet_of_mem_shell
    (C : BlockCode ι F) {r : ℕ} {δ : ℝ}
    (hn : 0 < Fintype.card ι)
    (hlo : relativeRadius (ι := ι) r ≤ δ)
    (hhi : δ < relativeRadius (ι := ι) (r + 1))
    (L : AffineLine ι F) : C.badChallengeSetAt δ L = C.badChallengeSet r L := by
  classical
  ext γ
  simp only [C.mem_badChallengeSetAt, C.mem_badChallengeSet]
  constructor
  · rintro ⟨S, hlarge, hbad⟩
    exact ⟨S, (largeAgreementSetAt_iff_count_of_mem_shell hn hlo hhi).mp hlarge, hbad⟩
  · rintro ⟨S, hlarge, hbad⟩
    exact ⟨S, (largeAgreementSetAt_iff_count_of_mem_shell hn hlo hhi).mpr hlarge, hbad⟩

theorem badChallengeSetAt_mono_radius
    (C : BlockCode ι F) (L : AffineLine ι F) {δ η : ℝ} (h : δ ≤ η) :
    C.badChallengeSetAt δ L ⊆ C.badChallengeSetAt η L := by
  classical
  intro γ hγ
  rcases (C.mem_badChallengeSetAt δ L γ).mp hγ with ⟨S, hlarge, hbad⟩
  apply (C.mem_badChallengeSetAt η L γ).mpr
  refine ⟨S, ?_, hbad⟩
  unfold LargeAgreementSetAt at hlarge ⊢
  linarith

theorem pairMCAErrorBoundAt_antitone
    (C : BlockCode ι F) (ε : ℝ) : Antitone (fun δ => C.PairMCAErrorBoundAt δ ε) := by
  intro δ η hδη hη L
  calc
    challengeFraction (C.badChallengeSetAt δ L) ≤
        challengeFraction (C.badChallengeSetAt η L) := by
      unfold challengeFraction
      exact div_le_div_of_nonneg_right
        (by exact_mod_cast Finset.card_le_card (C.badChallengeSetAt_mono_radius L hδη))
        (Nat.cast_nonneg _)
    _ ≤ ε := hη L

theorem pairMCAErrorBoundAt_invPow_iff_secureAtBits_of_mem_shell
    [Nonempty F] (C : BlockCode ι F) {r bits : ℕ} {δ : ℝ}
    (hn : 0 < Fintype.card ι)
    (hlo : relativeRadius (ι := ι) r ≤ δ)
    (hhi : δ < relativeRadius (ι := ι) (r + 1)) :
    C.PairMCAErrorBoundAt δ ((1 : ℝ) / 2 ^ bits) ↔ C.PairMCASecureAtBits bits r := by
  have heq : C.PairMCAErrorBoundAt δ ((1 : ℝ) / 2 ^ bits) ↔
      C.PairMCAErrorBoundAt (relativeRadius (ι := ι) r) ((1 : ℝ) / 2 ^ bits) := by
    unfold PairMCAErrorBoundAt
    simp_rw [C.badChallengeSetAt_eq_badChallengeSet_of_mem_shell hn hlo hhi,
      C.badChallengeSetAt_relativeRadius_eq hn]
  exact heq.trans (C.pairMCAErrorBoundAt_relativeRadius_invPow_iff_secureAtBits hn)

/-- The exact nonnegative real safe set, without assuming any radius is safe. -/
def pairMCASafeRelativeRadii (C : BlockCode ι F) (bits : ℕ) : Set ℝ :=
  {δ | 0 ≤ δ ∧ C.PairMCAErrorBoundAt δ ((1 : ℝ) / 2 ^ bits)}

/-- Adjacent count-zero/one certificates determine the entire real safe set. -/
theorem pairMCASafeRelativeRadii_eq_Ico_of_zero_one
    [Nonempty F] (C : BlockCode ι F) {bits : ℕ}
    (hn : 0 < Fintype.card ι)
    (hzero : C.PairMCASecureAtBits bits 0)
    (hone : ¬ C.PairMCASecureAtBits bits 1) :
    C.pairMCASafeRelativeRadii bits = Set.Ico 0 (relativeRadius (ι := ι) 1) := by
  ext δ
  constructor
  · rintro ⟨hδ, hsafe⟩
    refine ⟨hδ, ?_⟩
    by_contra hnext
    apply hone
    apply (C.pairMCAErrorBoundAt_relativeRadius_invPow_iff_secureAtBits hn).mp
    exact C.pairMCAErrorBoundAt_antitone _ (le_of_not_gt hnext) hsafe
  · rintro ⟨hδ, hnext⟩
    refine ⟨hδ, ?_⟩
    exact (C.pairMCAErrorBoundAt_invPow_iff_secureAtBits_of_mem_shell
      (r := 0) hn (by simpa using hδ) (by simpa using hnext)).mpr hzero

end BlockCode

namespace MCA.BoundaryField

open BlockCode

theorem pairMCA_secure_128_zero : parameters.toBlockCode.PairMCASecureAtBits 128 0 := by
  apply parameters.toBlockCode.pairMCASecureAtBits_of_countBound
    (threshold := 1) radiusZero_uniform_count_certificate
  simpa using one_challenge_128_bit_budget

theorem not_pairMCA_secure_128_one : ¬ parameters.toBlockCode.PairMCASecureAtBits 128 1 := by
  intro hsecure
  unfold PairMCASecureAtBits at hsecure
  have hlower : 2 ≤ parameters.toBlockCode.worstBadCount 1 :=
    two_le_paperMCABadSpectrum_one
  have hscaled : 2 ^ 128 * 2 ≤ 2 ^ 128 * parameters.toBlockCode.worstBadCount 1 :=
    Nat.mul_le_mul_left (2 ^ 128) hlower
  have htwo : 2 ^ 128 * 2 ≤ Fintype.card RSField :=
    hscaled.trans hsecure
  exact (not_le_of_gt two_challenges_exceed_128_bit_budget) htwo

/-- The boundary-field theorem's exact real safe interval. -/
theorem pairMCA_safeRelativeRadii_128_eq_Ico :
    parameters.toBlockCode.pairMCASafeRelativeRadii 128 =
      Set.Ico 0 ((1 : ℝ) / 4096) := by
  have hn : 0 < Fintype.card (Fin length) := by
    rw [Fintype.card_fin]
    decide
  have hr : relativeRadius (ι := Fin length) 1 = (1 : ℝ) / 4096 := by
    norm_num [relativeRadius, Fintype.card_fin, length]
  rw [← hr]
  exact parameters.toBlockCode.pairMCASafeRelativeRadii_eq_Ico_of_zero_one
    hn pairMCA_secure_128_zero not_pairMCA_secure_128_one

/-- The real supremum is `1/4096`, excluded from the safe set; no maximum exists. -/
theorem pairMCA_real_128_threshold :
    sSup (parameters.toBlockCode.pairMCASafeRelativeRadii 128) = (1 : ℝ) / 4096 ∧
      (1 : ℝ) / 4096 ∉ parameters.toBlockCode.pairMCASafeRelativeRadii 128 ∧
      ¬ ∃ δ, IsGreatest (parameters.toBlockCode.pairMCASafeRelativeRadii 128) δ := by
  rw [pairMCA_safeRelativeRadii_128_eq_Ico]
  exact RadiusShell.halfOpen_interval_summary (by norm_num)

end MCA.BoundaryField
end ProximityCoding
