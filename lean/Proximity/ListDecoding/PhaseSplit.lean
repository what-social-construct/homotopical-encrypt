module

public import Proximity.ListDecoding.Capacity
public import Proximity.Core.RadiusShell
public import Proximity.Core.FiniteThreshold

@[expose] public section

/-!
# The complete fractional-list phase split

The endpoint equality and next-shell witness already determine the entire
real safe interval whenever the binomial budget holds. This module packages
that interval, its excluded supremum, and the other two field-size regimes.
The intermediate regime is deliberately not assigned an unknown optimum.
-/

namespace ProximityPrize

namespace CapacityList

open BlockCode

variable {ι α : Type*} [Fintype ι] [Fintype α] [DecidableEq α]

/-- Nonnegative real radii meeting the paper's fractional list-size target. -/
def safeRelativeRadii (C : BlockCode ι α) (ε : ℝ) (q : ℕ) : Set ℝ :=
  {δ | 0 ≤ δ ∧ FractionalListSizeBoundAt C δ ε q}

theorem fractionalListSizeBoundAt_antitone
    (C : BlockCode ι α) (ε : ℝ) (q : ℕ) :
    Antitone (fun δ => FractionalListSizeBoundAt C δ ε q) := by
  intro δ η hδη hη w
  calc
    (C.ballCardAt δ w : ℝ) ≤ C.ballCardAt η w := by
      exact_mod_cast C.ballCardAt_mono_radius w hδη
    _ ≤ ε * q := hη w

theorem fractionalListSizeBoundAt_zero
    (C : BlockCode ι α) (hn : 0 < Fintype.card ι)
    {ε : ℝ} {q : ℕ} (hbudget : 1 ≤ ε * q) :
    FractionalListSizeBoundAt C 0 ε q := by
  intro w
  calc
    (C.ballCardAt 0 w : ℝ) ≤ 1 := by
      exact_mod_cast C.ballCardAt_zero_le_one hn w
    _ ≤ ε * q := hbudget

theorem not_fractionalListSizeBoundAt_of_budget_lt_one
    (C : BlockCode ι α) {w : Word ι α} (hw : C.Codeword w)
    {δ ε : ℝ} {q : ℕ} (hδ : 0 ≤ δ) (hbudget : ε * q < 1) :
    ¬ FractionalListSizeBoundAt C δ ε q := by
  intro hsafe
  have hone : (1 : ℝ) ≤ C.ballCardAt δ w := by
    exact_mod_cast C.one_le_ballCardAt_self hw hδ
  have h := hsafe w
  linarith

end CapacityList

namespace ReedSolomon.Parameters

open BlockCode CapacityList

variable {F ι σ : Type*} [Field F] [Fintype F] [DecidableEq F]
variable [Fintype ι] [Fintype σ] [Nonempty σ]

/-- Positive-width next-shell lists exceed every proper fractional target. -/
theorem not_vectorFractionalListSizeBoundAt_nextShell
    (P : ReedSolomon.Parameters F ι) {ε : ℝ}
    (hε : ε < 1) (hDegree : 0 < P.degreeBound)
    (hn : 0 < Fintype.card ι) (hk : P.degreeBound ≤ Fintype.card ι) :
    ¬ FractionalListSizeBoundAt (P.vectorBlockCode σ)
      (relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound + 1))
      ε (Fintype.card F) := by
  classical
  intro hsafe
  have hq : (0 : ℝ) < Fintype.card F := by exact_mod_cast Fintype.card_pos
  have hpow : Fintype.card F ≤ Fintype.card F ^ Fintype.card σ :=
    le_self_pow₀ (Nat.succ_le_iff.mpr Fintype.card_pos) Fintype.card_pos.ne'
  have hlist : (Fintype.card F : ℝ) ≤
      (P.vectorBlockCode σ).ballCardAt
        (relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound + 1)) 0 := by
    exact_mod_cast hpow.trans
      (P.fieldCard_pow_le_nextShell_ballCardAt σ hDegree hn hk)
  have hproper : ε * Fintype.card F < (Fintype.card F : ℝ) := by
    simpa using mul_lt_mul_of_pos_right hε hq
  have h := hsafe 0
  linarith

/-- In the endpoint-safe regime the next integer shell is the excluded cut. -/
theorem vectorFractionalListSafeRelativeRadii_eq_Ico
    (P : ReedSolomon.Parameters F ι) {ε : ℝ}
    (hε : ε < 1) (hDegree : 0 < P.degreeBound)
    (hn : 0 < Fintype.card ι) (hk : P.degreeBound ≤ Fintype.card ι)
    (hbudget : (Nat.choose (Fintype.card ι) P.degreeBound : ℝ) ≤
      ε * Fintype.card F) :
    safeRelativeRadii (P.vectorBlockCode σ) ε (Fintype.card F) =
      Set.Ico 0 (relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound + 1)) := by
  classical
  ext δ
  constructor
  · rintro ⟨hδ, hsafe⟩
    refine ⟨hδ, ?_⟩
    by_contra hnext
    exact P.not_vectorFractionalListSizeBoundAt_nextShell (σ := σ)
      hε hDegree hn hk
      (fractionalListSizeBoundAt_antitone _ ε _ (le_of_not_gt hnext) hsafe)
  · rintro ⟨hδ, hnext⟩
    refine ⟨hδ, fun w => ?_⟩
    calc
      ((P.vectorBlockCode σ).ballCardAt δ w : ℝ) ≤
          (P.vectorBlockCode σ).ballCard
            (Fintype.card ι - P.degreeBound) w := by
        exact_mod_cast (P.vectorBlockCode σ).ballCardAt_le_ballCard_of_lt_succ hn hnext w
      _ ≤ Nat.choose (Fintype.card ι) P.degreeBound := by
        exact_mod_cast P.vectorListSizeBound_capacityGrid σ hk w
      _ ≤ ε * Fintype.card F := hbudget

/-- The largest safe grid count is exactly `n-k`; its successor is unsafe. -/
theorem vectorFractionalListGridThreshold
    (P : ReedSolomon.Parameters F ι) {ε : ℝ}
    (hε : ε < 1) (hDegree : 0 < P.degreeBound)
    (hn : 0 < Fintype.card ι) (hk : P.degreeBound ≤ Fintype.card ι)
    (hbudget : (Nat.choose (Fintype.card ι) P.degreeBound : ℝ) ≤
      ε * Fintype.card F) :
    FiniteThreshold.greatestSafe (Fintype.card ι)
        (fun r => FractionalListSizeBoundAt (P.vectorBlockCode σ)
          (relativeRadius (ι := ι) r) ε (Fintype.card F)) =
      ((Fintype.card ι - P.degreeBound : ℕ) : WithBot ℕ) ∧
    FiniteThreshold.firstUnsafe (Fintype.card ι)
        (fun r => FractionalListSizeBoundAt (P.vectorBlockCode σ)
          (relativeRadius (ι := ι) r) ε (Fintype.card F)) =
      ((Fintype.card ι - P.degreeBound + 1 : ℕ) : WithTop ℕ) := by
  classical
  have hanti : Antitone (fun r =>
      FractionalListSizeBoundAt (P.vectorBlockCode σ)
        (relativeRadius (ι := ι) r) ε (Fintype.card F)) := by
    intro r s hrs
    exact fractionalListSizeBoundAt_antitone _ ε _ (relativeRadius_mono hrs)
  have hsafe : FractionalListSizeBoundAt (P.vectorBlockCode σ)
      (relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound)) ε (Fintype.card F) :=
    (P.vectorFractionalListSizeBoundAt_capacityGrid_iff (Classical.arbitrary σ)
      ε hDegree hn hk).mpr hbudget
  have hnext := P.not_vectorFractionalListSizeBoundAt_nextShell (σ := σ) hε hDegree hn hk
  have hlt : Fintype.card ι - P.degreeBound < Fintype.card ι := by omega
  exact ⟨FiniteThreshold.greatestSafe_eq_of_antitone hlt.le hanti hsafe hnext,
    FiniteThreshold.firstUnsafe_eq_of_antitone hlt hanti hsafe hnext⟩

/-- The next-shell point is the supremum of safe real radii and is not attained. -/
theorem vectorFractionalListRealThreshold
    (P : ReedSolomon.Parameters F ι) {ε : ℝ}
    (hε : ε < 1) (hDegree : 0 < P.degreeBound)
    (hn : 0 < Fintype.card ι) (hk : P.degreeBound ≤ Fintype.card ι)
    (hbudget : (Nat.choose (Fintype.card ι) P.degreeBound : ℝ) ≤
      ε * Fintype.card F) :
    sSup (safeRelativeRadii (P.vectorBlockCode σ) ε (Fintype.card F)) =
        relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound + 1) ∧
      relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound + 1) ∉
        safeRelativeRadii (P.vectorBlockCode σ) ε (Fintype.card F) ∧
      ¬ ∃ δ, IsGreatest (safeRelativeRadii (P.vectorBlockCode σ) ε (Fintype.card F)) δ := by
  rw [P.vectorFractionalListSafeRelativeRadii_eq_Ico (σ := σ) hε hDegree hn hk hbudget]
  apply RadiusShell.halfOpen_interval_summary
  unfold relativeRadius
  positivity

/--
All three manuscript regimes. The middle clause determines endpoint failure
but leaves the optimal smaller radius unspecified.
-/
theorem vectorFractionalListPhaseSplit
    (P : ReedSolomon.Parameters F ι) {ε : ℝ}
    (hε : ε < 1) (hDegree : 0 < P.degreeBound)
    (hn : 0 < Fintype.card ι) (hk : P.degreeBound ≤ Fintype.card ι) :
    (ε * Fintype.card F < 1 →
      ∀ δ : ℝ, 0 ≤ δ →
        ¬ FractionalListSizeBoundAt (P.vectorBlockCode σ) δ ε (Fintype.card F)) ∧
    ((1 ≤ ε * Fintype.card F ∧
        ε * Fintype.card F < (Nat.choose (Fintype.card ι) P.degreeBound : ℝ)) →
      FractionalListSizeBoundAt (P.vectorBlockCode σ) 0 ε (Fintype.card F) ∧
      ∀ δ : ℝ, relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound) ≤ δ →
        ¬ FractionalListSizeBoundAt (P.vectorBlockCode σ) δ ε (Fintype.card F)) ∧
    ((Nat.choose (Fintype.card ι) P.degreeBound : ℝ) ≤ ε * Fintype.card F →
      safeRelativeRadii (P.vectorBlockCode σ) ε (Fintype.card F) =
        Set.Ico 0 (relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound + 1))) := by
  classical
  refine ⟨?_, ?_, ?_⟩
  · intro hbudget δ hδ
    apply not_fractionalListSizeBoundAt_of_budget_lt_one
      (P.vectorBlockCode σ) (w := 0) ?_ hδ hbudget
    intro j
    exact (P.fAdditive_of_degreeBound_pos hDegree).zero_mem
  · rintro ⟨hlower, hupper⟩
    refine ⟨fractionalListSizeBoundAt_zero _ hn hlower, ?_⟩
    intro δ hδ hsafe
    have hendpoint := fractionalListSizeBoundAt_antitone _ ε _ hδ hsafe
    have hbudget :=
      (P.vectorFractionalListSizeBoundAt_capacityGrid_iff (Classical.arbitrary σ)
        ε hDegree hn hk).mp hendpoint
    linarith
  · exact P.vectorFractionalListSafeRelativeRadii_eq_Ico hε hDegree hn hk

end ReedSolomon.Parameters
end ProximityPrize
