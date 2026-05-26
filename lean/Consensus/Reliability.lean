import Mathlib.Data.Real.Basic
import Mathlib.Tactic

/-
  Reliability evidence and discount scores.

  Validators are automated, so reliability is not human effort. It is protocol
  behavior: assigned duties fulfilled correctly and on time, with no
  equivocation or invalid-block evidence. Reliability is a discount only.
-/

namespace Hcrypt
namespace Consensus

/-- Runtime evidence summary for validator reliability. -/
structure ReliabilityEvidence where
  assignedDuties : ℕ
  fulfilledDuties : ℕ
  fulfilled_le_assigned : fulfilledDuties ≤ assignedDuties
  noEquivocation : Prop
  noInvalidBlocks : Prop

/-- A bounded reliability score supplied by runtime evidence. -/
structure ReliabilityScore where
  score : ℝ
  bounded : 0 ≤ score ∧ score ≤ 1
  SupportedByEvidence : Prop

namespace ReliabilityScore

/-- Reliability scores are non-negative. -/
theorem nonneg (R : ReliabilityScore) : 0 ≤ R.score :=
  R.bounded.1

/-- Reliability cannot exceed one, so it cannot boost value. -/
theorem le_one (R : ReliabilityScore) : R.score ≤ 1 :=
  R.bounded.2

end ReliabilityScore

/--
Smoothed reliability estimate.

`alpha` and `beta` are protocol constants. With `beta > 0`, the score remains
strictly discount-shaped even when a validator has no assigned duties yet.
-/
noncomputable def smoothedReliability
    (alpha beta : ℝ) (fulfilled assigned : ℕ) : ℝ :=
  (alpha + (fulfilled : ℝ)) / (alpha + beta + (assigned : ℝ))

/-- The smoothed reliability estimate is bounded by `[0,1]`. -/
theorem smoothedReliability_bounded
    {alpha beta : ℝ} {fulfilled assigned : ℕ}
    (hAlpha : 0 ≤ alpha)
    (hBeta : 0 < beta)
    (hFulfilled : fulfilled ≤ assigned) :
    0 ≤ smoothedReliability alpha beta fulfilled assigned
      ∧ smoothedReliability alpha beta fulfilled assigned ≤ 1 := by
  have hFulfilledNonneg : 0 ≤ (fulfilled : ℝ) := Nat.cast_nonneg fulfilled
  have hAssignedNonneg : 0 ≤ (assigned : ℝ) := Nat.cast_nonneg assigned
  have hFulfilledLeAssigned : (fulfilled : ℝ) ≤ (assigned : ℝ) :=
    Nat.cast_le.mpr hFulfilled
  have hNumNonneg : 0 ≤ alpha + (fulfilled : ℝ) := by nlinarith
  have hDenPos : 0 < alpha + beta + (assigned : ℝ) := by nlinarith
  constructor
  · exact div_nonneg hNumNonneg (le_of_lt hDenPos)
  · unfold smoothedReliability
    rw [div_le_iff₀ hDenPos]
    nlinarith

end Consensus
end Hcrypt
