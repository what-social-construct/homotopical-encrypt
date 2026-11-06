module

public import Proximity.MCA.Threshold

@[expose] public section

/-!
# Code-specific MCA spectrum certificates

This module turns two concrete pieces of counting information into an exact
finite-grid threshold:

* a uniform upper bound on all affine lines at radius `r`, within the field
  budget; and
* one affine line at radius `r + 1` whose scaled bad count exceeds the field
  size.

No Reed--Solomon structure is required.  Code families can import this adapter
after proving their own upper bound and explicit bad-line witness.
-/

namespace ProximityPrize
namespace BlockCode

variable {ι F : Type*}
variable [Fintype ι] [Fintype F]
variable [Add F] [Mul F]

/-- A single over-budget affine line certifies failure of integer MCA security. -/
theorem not_pairMCASecureAtBits_of_badLine
    (C : BlockCode ι F)
    {securityBits radius : ℕ}
    (L : AffineLine ι F)
    (hexceeds :
      Fintype.card F <
        2 ^ securityBits * (C.badChallengeSet radius L).card) :
    ¬ C.PairMCASecureAtBits securityBits radius := by
  intro hsecure
  exact (Nat.not_le_of_lt hexceeds)
    (C.scaled_badChallengeSet_card_le_of_pairMCASecureAtBits hsecure L)

/--
A uniform in-budget upper bound at `radius` and one over-budget line at the
next radius give the generic exact-grid certificate.
-/
theorem pairMCAExactGridCertificate_of_countBound_and_badLine
    (C : BlockCode ι F)
    {securityBits radius upperBound : ℕ}
    (hradius : radius < Fintype.card ι)
    (hcount : ∀ L : AffineLine ι F,
      (C.badChallengeSet radius L).card ≤ upperBound)
    (hbudget :
      2 ^ securityBits * upperBound ≤ Fintype.card F)
    (Lnext : AffineLine ι F)
    (hnext :
      Fintype.card F <
        2 ^ securityBits *
          (C.badChallengeSet (radius + 1) Lnext).card) :
    FiniteThreshold.ExactGridCertificate
      (Fintype.card ι)
      (C.PairMCASecureAtBits securityBits)
      radius := by
  apply C.pairMCAExactGridCertificate hradius
  · exact C.pairMCASecureAtBits_of_countBound hcount hbudget
  · exact C.not_pairMCASecureAtBits_of_badLine Lnext hnext

/--
The upper-bound/bad-line certificate pins both endpoints of the MCA security
spectrum on the Hamming-count grid.
-/
theorem pairMCAThreshold_eq_of_countBound_and_badLine
    (C : BlockCode ι F)
    {securityBits radius upperBound : ℕ}
    (hradius : radius < Fintype.card ι)
    (hcount : ∀ L : AffineLine ι F,
      (C.badChallengeSet radius L).card ≤ upperBound)
    (hbudget :
      2 ^ securityBits * upperBound ≤ Fintype.card F)
    (Lnext : AffineLine ι F)
    (hnext :
      Fintype.card F <
        2 ^ securityBits *
          (C.badChallengeSet (radius + 1) Lnext).card) :
    C.pairMCAGreatestSafe securityBits = (radius : WithBot ℕ) ∧
      C.pairMCAFirstUnsafe securityBits =
        ((radius + 1 : ℕ) : WithTop ℕ) := by
  let hcertificate :=
    C.pairMCAExactGridCertificate_of_countBound_and_badLine
      hradius hcount hbudget Lnext hnext
  exact ⟨hcertificate.greatestSafe_eq, hcertificate.firstUnsafe_eq⟩

/--
An over-budget line at radius zero leaves no secure point on the radius grid;
zero itself is the first insecure radius.
-/
theorem pairMCABottomThreshold_of_badLine
    (C : BlockCode ι F)
    (securityBits : ℕ)
    (L : AffineLine ι F)
    (hexceeds :
      Fintype.card F <
        2 ^ securityBits * (C.badChallengeSet 0 L).card) :
    C.pairMCAGreatestSafe securityBits = ⊥ ∧
      C.pairMCAFirstUnsafe securityBits = ((0 : ℕ) : WithTop ℕ) := by
  have hzero : ¬ C.PairMCASecureAtBits securityBits 0 :=
    C.not_pairMCASecureAtBits_of_badLine L hexceeds
  exact ⟨
    FiniteThreshold.greatestSafe_eq_bot_of_antitone_not_zero
      (C.pairMCASecureAtBits_antitone securityBits) hzero,
    FiniteThreshold.firstUnsafe_eq_zero_of_not_good hzero⟩

end BlockCode
end ProximityPrize
