import ProximityPrize.BlockCode

/-!
# Capacity-radius bookkeeping

This module records only normalization and finite arithmetic. It does not
assert that any code satisfies a capacity-radius list-decoding or MCA bound.
-/

namespace ProximityPrize
namespace Capacity

/-- The list-decoding capacity benchmark at rate `ρ`. -/
def capacityRadius (ρ : ℝ) : ℝ :=
  1 - ρ

/-- Finite parameters with a radius strictly below `n - k`. -/
structure Regime where
  length : ℕ
  degreeBound : ℕ
  radius : ℕ
  length_pos : 0 < length
  degreeBound_le : degreeBound ≤ length
  radius_lt : radius < length - degreeBound

namespace Regime

/-- Designed rate `k/n`. -/
noncomputable def rate (P : Regime) : ℝ :=
  (P.degreeBound : ℝ) / (P.length : ℝ)

/-- Finite relative radius `r/n`. -/
noncomputable def relativeRadius (P : Regime) : ℝ :=
  (P.radius : ℝ) / (P.length : ℝ)

/-- The strict integer inequality implies strict inequality below capacity. -/
theorem relativeRadius_lt_capacity (P : Regime) :
    P.relativeRadius < capacityRadius P.rate := by
  have hn : (0 : ℝ) < P.length := by
    exact_mod_cast P.length_pos
  have hr :
      (P.radius : ℝ) < (P.length : ℝ) - (P.degreeBound : ℝ) := by
    rw [← Nat.cast_sub P.degreeBound_le]
    exact_mod_cast P.radius_lt
  apply (div_lt_iff₀ hn).2
  calc
    (P.radius : ℝ) <
        (P.length : ℝ) - (P.degreeBound : ℝ) := hr
    _ = capacityRadius P.rate * (P.length : ℝ) := by
      simp only [capacityRadius, rate]
      field_simp

end Regime

/-- A quantitative bound meets an `ε` fraction of a finite field. -/
def MeetsFractionTarget (bound fieldCard : ℕ) (ε : ℝ) : Prop :=
  (bound : ℝ) ≤ ε * (fieldCard : ℝ)

/--
A nonempty integer-valued bound meeting the fraction target forces the field
cardinality to be at least `1 / ε`.
-/
theorem fieldCard_ge_inv
    {bound fieldCard : ℕ} {ε : ℝ}
    (hε : 0 < ε)
    (hbound : 1 ≤ bound)
    (hmeets : MeetsFractionTarget bound fieldCard ε) :
    1 / ε ≤ (fieldCard : ℝ) := by
  apply (div_le_iff₀ hε).2
  have hone : (1 : ℝ) ≤ (bound : ℝ) := by
    exact_mod_cast hbound
  exact hone.trans hmeets |>.trans_eq (mul_comm ε (fieldCard : ℝ))

/-- The running rate-`1/4`, length-`4096` strict-capacity checkpoint. -/
def rateQuarterCheckpoint : Regime where
  length := 4096
  degreeBound := 1024
  radius := 3071
  length_pos := by norm_num
  degreeBound_le := by norm_num
  radius_lt := by norm_num

/-- The running checkpoint lies strictly below the `3/4` capacity radius. -/
theorem rateQuarterCheckpoint_lt_threeQuarters :
    rateQuarterCheckpoint.relativeRadius < (3 : ℝ) / 4 := by
  norm_num [Regime.relativeRadius, rateQuarterCheckpoint]

end Capacity
end ProximityPrize
