import Proximity.Concrete.RS.ReedSolomon
import Axioms.CochainCommitment.Payload
import Mathlib.Data.ZMod.Basic

/-
  Lightweight canonical Reed-Solomon parameters for the concrete proximity bridge.

  Paper correspondence:
  - Paper 1 Section 6: canonical RS field, length, rate, and radius constants.

  This file fixes the field, length, rate, and radius constants. It deliberately
  avoids the multiplicative-generator/order proof so downstream files can import
  the parameter regime without paying for the power-domain construction.
-/

namespace Hcrypt
namespace Proximity
namespace CanonicalRS

noncomputable section

/-- Canonical RS field matching the current cochain commitment modulus. -/
abbrev RSField :=
  ZMod Axioms.canonicalCochainModulus

/-- The current canonical cochain modulus is prime. -/
instance canonicalCochainModulus_prime :
    Fact (Nat.Prime Axioms.canonicalCochainModulus) :=
  ⟨by native_decide⟩

/--
Smooth power-of-two evaluation length.

The current modulus is `12289 = 3 * 4096 + 1`, so this is the natural first
smooth-domain size for an NTT/subgroup-style RS domain.
-/
def length : ℕ := 4096

/-- Order of the full multiplicative group of the canonical field. -/
def fullGeneratorOrder : ℕ :=
  Axioms.canonicalCochainModulus - 1

/-- Exponent used to descend from a full generator to the `4096`-order root. -/
def rootExponent : ℕ :=
  3

/--
The full multiplicative-group order factors as `3 * 4096`.

This is the arithmetic reason that cubing a full generator produces the
power-of-two RS evaluation root.
-/
theorem fullGeneratorOrder_eq_rootExponent_mul_length :
    fullGeneratorOrder = rootExponent * length := by
  native_decide

/-- Dividing the full generator order by the cubing exponent gives the RS length. -/
theorem fullGeneratorOrder_div_rootExponent_eq_length :
    fullGeneratorOrder / rootExponent = length := by
  native_decide

/-- The cubing exponent is nonzero. -/
theorem rootExponent_ne_zero : rootExponent ≠ 0 := by
  native_decide

/-- The cubing exponent divides the full multiplicative-group order. -/
theorem rootExponent_dvd_fullGeneratorOrder :
    rootExponent ∣ fullGeneratorOrder := by
  native_decide

/-- Constant-rate degree bound for the first concrete target: rate `1/4`. -/
def degreeBound : ℕ := 1024

/-- The selected constant-rate denominator. -/
def rateDenominator : ℕ := 4

/-- The selected rate is exactly `degreeBound / length = 1/4`. -/
theorem degreeBound_mul_rateDenominator_eq_length :
    degreeBound * rateDenominator = length := by
  native_decide

/-- The chosen length divides the multiplicative-group order of the canonical field. -/
theorem length_dvd_canonical_modulus_minus_one :
    length ∣ Axioms.canonicalCochainModulus - 1 := by
  native_decide

/--
Conservative Johnson-below Hamming radius for rate `1/4`.

The Johnson radius fraction is `1 - sqrt(1/4) = 1/2`. We choose `2047`, strictly
below `4096 / 2`, so later statements can avoid endpoint ambiguity.
-/
def johnsonBelowRadius : ℕ := 2047

/-- The Johnson-below radius is strictly below half the block length. -/
theorem two_mul_johnsonBelowRadius_lt_length :
    2 * johnsonBelowRadius < length := by
  native_decide

/--
Capacity-below radius for rate `1/4`.

The information-theoretic limit is `1 - R = 3/4`. We name the strict integer
radius below that limit separately from the conservative Johnson-below radius.
-/
def capacityBelowRadius : ℕ := 3071

/-- The capacity-below radius is strictly below `3/4` of the block length. -/
theorem four_mul_capacityBelowRadius_lt_three_mul_length :
    4 * capacityBelowRadius < 3 * length := by
  native_decide

/--
A concrete smooth evaluation-domain choice.

The actual evaluation points are kept as a field so callers can instantiate a
subgroup/coset/power-of-two domain. The arithmetic facts above record why this
is the intended canonical size for `ZMod 12289`.
-/
structure SmoothDomain where
  domain : ReedSolomon.EvaluationDomain RSField (Fin length)
  smooth : Prop

namespace SmoothDomain

/-- RS parameters induced by a chosen canonical smooth domain. -/
def parameters (D : SmoothDomain) :
    ReedSolomon.Parameters RSField (Fin length) where
  domain := D.domain
  degreeBound := degreeBound

end SmoothDomain

end

end CanonicalRS
end Proximity
end Hcrypt
