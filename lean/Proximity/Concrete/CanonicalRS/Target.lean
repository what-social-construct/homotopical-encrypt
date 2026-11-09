module

public import Proximity.Concrete.CanonicalRS.Parameters
public meta import Proximity.Concrete.CanonicalRS.Parameters
public import Proximity.Concrete.RS.Target

@[expose] public section

/-
  Target packaging for the canonical RS regime.

  Paper correspondence:
  - Paper 1 Section 6: canonical RS target and explicit theorem slots.

  The parameter regime is fixed here, while list-decoding and MCA bounds remain
  explicit theorem slots.
-/

namespace Hcrypt
namespace Proximity
namespace CanonicalRS

noncomputable section

/--
External theorem/bound slots for the canonical RS target.

This is where a concrete paper theorem, cited bound, or later Lean proof enters.
The target fixes rate, length, degree, and the conservative Johnson-below
radius; it does not assert the list-decoding or MCA theorem without evidence.
-/
structure Bounds (D : SmoothDomain) where
  listSize : ℕ
  threshold : ℕ
  listDecodingBound :
    (D.parameters).ListDecodingBound johnsonBelowRadius listSize
  listDecodingBoundAt :
    (D.parameters).ListDecodingBoundAt
      (BlockCode.relativeRadius (ι := Fin length) johnsonBelowRadius)
      listSize
  mutualCorrelatedAgreementBound :
    (D.parameters).MutualCorrelatedAgreementBound
      johnsonBelowRadius johnsonBelowRadius threshold
  mutualCorrelatedAgreementErrorBound :
    (D.parameters).MutualCorrelatedAgreementErrorBound
      (BlockCode.relativeRadius (ι := Fin length) johnsonBelowRadius)
      (BlockCode.relativeRadius (ι := Fin length) johnsonBelowRadius)
      ((threshold : ℝ) / (Fintype.card RSField : ℝ))
  paperMutualCorrelatedAgreementErrorBound :
    (D.parameters).PaperMutualCorrelatedAgreementErrorBound
      (BlockCode.relativeRadius (ι := Fin length) johnsonBelowRadius)
      ((threshold : ℝ) / (Fintype.card RSField : ℝ))

namespace Bounds

variable {D : SmoothDomain}

/-- The canonical RS parameter object is F-additive by polynomial closure. -/
theorem fAdditive (D : SmoothDomain) :
    D.parameters.FAdditive :=
  ReedSolomon.Parameters.fAdditive_of_degreeBound_pos
    D.parameters
    (by
      change 0 < degreeBound
      decide)

end Bounds

/-- The canonical RS target at rate `1/4` and Johnson-below radius. -/
def target (D : SmoothDomain) (B : Bounds D) :
    ReedSolomonTarget.Target RSField (Fin length) where
  parameters := D.parameters
  fAdditive := Bounds.fAdditive D
  smoothRegime := D.smooth
  listRadius := johnsonBelowRadius
  listSize := B.listSize
  pointRadius := johnsonBelowRadius
  lineRadius := johnsonBelowRadius
  threshold := B.threshold
  listDecodingBound := B.listDecodingBound
  listDecodingBoundAt := B.listDecodingBoundAt
  mutualCorrelatedAgreementBound := B.mutualCorrelatedAgreementBound
  mutualCorrelatedAgreementErrorBound := B.mutualCorrelatedAgreementErrorBound
  paperMutualCorrelatedAgreementErrorBound :=
    B.paperMutualCorrelatedAgreementErrorBound

end

end CanonicalRS
end Proximity
end Hcrypt
