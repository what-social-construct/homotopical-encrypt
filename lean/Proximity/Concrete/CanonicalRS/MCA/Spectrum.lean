module

public import Proximity.Concrete.CanonicalRS.PowerDomain
public meta import Proximity.Concrete.CanonicalRS.PowerDomain
public import Proximity.MCA.SmallRadius

@[expose] public section

/-!
# Exact small-radius MCA spectrum for the canonical Reed--Solomon code

The canonical code has parameters `[n,k,q] = [4096,1024,12289]`.  A
unit-spike affine line has a bad challenge already at count radius zero.  Since
the target security budget is `2^-128` while `q < 2^128`, radius zero is
insecure.  Monotonicity therefore leaves no secure point on the Hamming-count
grid: the greatest safe radius is bottom and the first unsafe radius is zero.
-/

namespace Hcrypt
namespace Proximity
namespace CanonicalRS
namespace MCA
namespace Spectrum

noncomputable section

open ProximityPrize
open ProximityPrize.BlockCode
open ProximityPrize.ReedSolomon.Parameters

/-- The canonical RS dimension is positive. -/
theorem canonical_degreeBound_pos :
    0 < (canonicalSmoothDomain.parameters).degreeBound := by
  native_decide

/-- There is at least one coordinate outside a canonical interpolation set. -/
theorem canonical_degreeBound_succ_le_length :
    (canonicalSmoothDomain.parameters).degreeBound + 1 ≤
      Fintype.card (Fin length) := by
  native_decide

/-- There are two coordinates outside a canonical interpolation set. -/
theorem canonical_degreeBound_add_two_le_length :
    (canonicalSmoothDomain.parameters).degreeBound + 2 ≤
      Fintype.card (Fin length) := by
  native_decide

/-- The canonical field is smaller than the `128`-bit MCA denominator. -/
theorem canonical_fieldCard_lt_two_pow_128 :
    Fintype.card RSField < 2 ^ (128 : ℕ) := by
  native_decide

/-- One bad challenge fits the `13`-bit budget in the canonical field. -/
theorem two_pow_13_le_canonical_fieldCard :
    2 ^ (13 : ℕ) ≤ Fintype.card RSField := by
  native_decide

/-- Two bad challenges exceed the `13`-bit budget in the canonical field. -/
theorem canonical_fieldCard_lt_two_pow_13_mul_two :
    Fintype.card RSField < 2 ^ (13 : ℕ) * 2 := by
  native_decide

/--
At count radius zero, a concrete unit-spike line already exceeds the canonical
`128`-bit challenge budget.
-/
theorem exists_radius_zero_line_exceeding_128_bit_budget :
    ∃ L : ProximityPrize.AffineLine (Fin length) RSField,
      Fintype.card RSField <
        2 ^ (128 : ℕ) *
          ((canonicalSmoothDomain.parameters).toBlockCode.badChallengeSet 0 L).card := by
  obtain ⟨i, _hzero, hone⟩ :=
    (canonicalSmoothDomain.parameters).exists_zeroSpikeLine_bad_of_degreeBound_succ_le
      canonical_degreeBound_pos canonical_degreeBound_succ_le_length
  refine ⟨zeroSpikeLine i, ?_⟩
  have hscaled :
      2 ^ (128 : ℕ) ≤
        2 ^ (128 : ℕ) *
          ((canonicalSmoothDomain.parameters).toBlockCode.badChallengeSet 0
            (zeroSpikeLine i)).card := by
    simpa using Nat.mul_le_mul_left (2 ^ (128 : ℕ)) hone
  exact canonical_fieldCard_lt_two_pow_128.trans_le hscaled

/--
Exact `128`-bit spectrum endpoints for the canonical RS code: no count radius
is secure, and radius zero is the first unsafe radius.
-/
theorem canonical_pairMCA_threshold_128 :
    (canonicalSmoothDomain.parameters).toBlockCode.pairMCAGreatestSafe 128 = ⊥ ∧
      (canonicalSmoothDomain.parameters).toBlockCode.pairMCAFirstUnsafe 128 =
        ((0 : ℕ) : WithTop ℕ) := by
  exact
    (canonicalSmoothDomain.parameters).pairMCABottomThreshold_of_field_lt_one_challenge_budget
      canonical_degreeBound_pos canonical_degreeBound_succ_le_length 128
      canonical_fieldCard_lt_two_pow_128

/--
At `13` security bits, the exact first transition is nontrivial: radius zero
is secure, while the explicit two-spike certificate makes radius one unsafe.
-/
theorem canonical_pairMCA_threshold_13 :
    (canonicalSmoothDomain.parameters).toBlockCode.pairMCAGreatestSafe 13 =
        (0 : WithBot ℕ) ∧
      (canonicalSmoothDomain.parameters).toBlockCode.pairMCAFirstUnsafe 13 =
        ((1 : ℕ) : WithTop ℕ) := by
  exact
    (canonicalSmoothDomain.parameters).pairMCAThreshold_zero_of_one_two_field_window
      canonical_degreeBound_pos canonical_degreeBound_add_two_le_length 13
      two_pow_13_le_canonical_fieldCard
      canonical_fieldCard_lt_two_pow_13_mul_two

end

end Spectrum
end MCA
end CanonicalRS
end Proximity
end Hcrypt
