import ProximityPrize.BlockCode
import Mathlib.Data.Nat.Choose.Bounds

/-!
# Capacity-radius bookkeeping

This module records normalization and the finite arithmetic used by the
capacity-grid list theorem. It does not assert a capacity-radius MCA bound.
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

namespace SmoothQuarterFamily

/--
The block lengths in the explicit rate-`1/4` family.  The first member has
length `256`; each subsequent member doubles the length.
-/
def length (u : ℕ) : ℕ :=
  256 * 2 ^ u

/-- The degree bounds in the explicit rate-`1/4` family. -/
def degreeBound (u : ℕ) : ℕ :=
  64 * 2 ^ u

/--
Cardinality of the selected finite field.  The paper takes the actual field to
be `𝔽_(3 ^ length u)`.
-/
def fieldCard (u : ℕ) : ℕ :=
  3 ^ length u

@[simp]
theorem length_zero : length 0 = 256 := by
  norm_num [length]

@[simp]
theorem degreeBound_zero : degreeBound 0 = 64 := by
  norm_num [degreeBound]

@[simp]
theorem length_succ (u : ℕ) :
    length (u + 1) = 2 * length u := by
  simp [length, pow_succ]
  ring

@[simp]
theorem degreeBound_succ (u : ℕ) :
    degreeBound (u + 1) = 2 * degreeBound u := by
  simp [degreeBound, pow_succ]
  ring

/-- Every member has exact designed rate `1/4` at the integer level. -/
theorem four_mul_degreeBound (u : ℕ) :
    4 * degreeBound u = length u := by
  simp [degreeBound, length]
  ring

/--
The raw exponential field inequality.  The proof starts at length `256` and
uses the fact that doubling the length squares both exponential terms.
-/
theorem two_pow_security_mul_two_pow_length_le_fieldCard :
    ∀ u : ℕ, 2 ^ 128 * 2 ^ length u ≤ fieldCard u
  | 0 => by
      norm_num [length, fieldCard]
  | u + 1 => by
      have ih :=
        two_pow_security_mul_two_pow_length_le_fieldCard u
      have hsecurity : 2 ^ 128 ≤ (2 ^ 128) * (2 ^ 128) := by
        nlinarith [show 1 ≤ 2 ^ 128 by norm_num]
      calc
        2 ^ 128 * 2 ^ length (u + 1)
            = 2 ^ 128 * (2 ^ length u * 2 ^ length u) := by
                rw [length_succ, two_mul, pow_add]
        _ ≤ ((2 ^ 128) * (2 ^ 128)) *
              (2 ^ length u * 2 ^ length u) :=
                Nat.mul_le_mul_right _ hsecurity
        _ = (2 ^ 128 * 2 ^ length u) *
              (2 ^ 128 * 2 ^ length u) := by ring
        _ ≤ fieldCard u * fieldCard u :=
              Nat.mul_le_mul ih ih
        _ = fieldCard (u + 1) := by
              simp [fieldCard, length_succ, two_mul, pow_add]

/--
Explicit `2^-128` field-size inequality for the binomial capacity-grid list
bound.
-/
theorem choose_target (u : ℕ) :
    2 ^ 128 * Nat.choose (length u) (degreeBound u) ≤ fieldCard u := by
  exact (Nat.mul_le_mul_left (2 ^ 128)
    (Nat.choose_le_two_pow (length u) (degreeBound u))).trans
      (two_pow_security_mul_two_pow_length_le_fieldCard u)

/-- The first family member satisfies the subgroup-order divisibility check. -/
theorem base_length_dvd_fieldCard_sub_one :
    length 0 ∣ fieldCard 0 - 1 := by
  norm_num [length, fieldCard]

end SmoothQuarterFamily

end Capacity
end ProximityPrize
