module

public import Proximity.Concrete.CanonicalRS.MCA.Concrete

@[expose] public section

/-
  Literature-imported bounds for the canonical RS endpoint.

  Paper correspondence:
  - Paper 3 comparison context: the explicit external
    Johnson/list-decoding/MCA theorem boundary.
  - These cited constants are separate from the standalone coding proofs.
    SEMANTIC-PARITY.md records their assumptions and provenance.

  This module is the trusted boundary where externally cited RS/list-decoding
  and MCA theorems enter the Lean development. The surrounding modules prove
  the endpoint alignment and projection plumbing; the deep coding-theory bounds
  are recorded here as named theorem constants with citations.
-/

namespace Hcrypt
namespace Proximity
namespace CanonicalRS
namespace CitedBounds

noncomputable section

/--
Canonical list-size witness imported from the Johnson/list-decoding literature.

Citation: Open Problems in List Decoding and Correlated Agreement,
ePrint 2026/680, Section 3, Theorem 3.2 ([Joh62]) and Corollary 3.3.
For Reed-Solomon/MDS codes below the Johnson radius, these give a finite
polynomial list-size bound. The concrete numeric witness is kept abstract here
so the repo does not rederive the closed-form rounding arithmetic.
-/
axiom citedListSize : ℕ

/--
Canonical MCA bad-challenge threshold imported from the RS MCA literature.

Citation: Open Problems in List Decoding and Correlated Agreement,
ePrint 2026/680, Section 4.2, Theorem 4.12 ([BCHKS25], Theorem 4.6),
with the canonical endpoint evaluated at rate `1/4` and radius
`2047 / 4096`, strictly below the Johnson radius.
-/
axiom citedMCAThreshold : ℕ

/--
Count-radius list-decoding bound for the canonical RS endpoint.

Citation: ePrint 2026/680, Theorem 3.2 ([Joh62]) and Corollary 3.3, specialized
to the canonical smooth RS domain, rate `1/4`, and `johnsonBelowRadius`.
-/
axiom johnsonListDecodingBound :
    (canonicalSmoothDomain.parameters).ListDecodingBound
      johnsonBelowRadius
      citedListSize

/--
Relative-radius list-decoding bound for the canonical RS endpoint.

Citation: ePrint 2026/680, Theorem 3.2 ([Joh62]) and Corollary 3.3, in the
paper's fractional-distance notation.
-/
axiom johnsonListDecodingBoundAt :
    (canonicalSmoothDomain.parameters).ListDecodingBoundAt
      (BlockCode.relativeRadius (ι := Fin length) johnsonBelowRadius)
      citedListSize

/--
Count-radius MCA bound for the canonical RS endpoint.

Citation: ePrint 2026/680, Section 4.2, Theorem 4.12
([BCHKS25], Theorem 4.6), specialized to the canonical smooth RS domain and
the finite radius `johnsonBelowRadius`.
-/
axiom bchksMutualCorrelatedAgreementBound :
    (canonicalSmoothDomain.parameters).MutualCorrelatedAgreementBound
      johnsonBelowRadius
      johnsonBelowRadius
      citedMCAThreshold

/--
Fractional MCA bound for the canonical RS endpoint.

Citation: ePrint 2026/680, Section 4.2, Theorem 4.12
([BCHKS25], Theorem 4.6), specialized to rate `1/4` and
`δ = 2047 / 4096`.
-/
axiom bchksMutualCorrelatedAgreementErrorBound :
    (canonicalSmoothDomain.parameters).MutualCorrelatedAgreementErrorBound
      (BlockCode.relativeRadius (ι := Fin length) johnsonBelowRadius)
      (BlockCode.relativeRadius (ι := Fin length) johnsonBelowRadius)
      ((citedMCAThreshold : ℝ) / (Fintype.card RSField : ℝ))

/--
Cited Definition 4.3 MCA bound at the canonical endpoint, evaluated at `s = 1`.

Citation: ePrint 2026/680, Definition 4.3 and Theorem 4.12
([BCHKS25], Theorem 4.6). The theorem is stated for F-additive codes
`C ⊆ (F^s)^n`; here the canonical scalar RS endpoint is included through the
verified width-one presentation `s = 1`.
-/
axiom bchksWidthOnePaperMutualCorrelatedAgreementErrorBound :
    MCA.Concrete.WidthOneTargetPaperMCAStatement citedMCAThreshold

/--
Scalar paper-MCA bound obtained from the cited `s = 1` paper-alphabet theorem.

The conversion uses the verified endpoint equivalence in
`CanonicalRS.MCA.Concrete`, in particular `widthOneBadChallengeSet_eq` and
`paperMCAStatement_iff_widthOneTarget`.
-/
theorem bchksPaperMutualCorrelatedAgreementErrorBound :
    (canonicalSmoothDomain.parameters).PaperMutualCorrelatedAgreementErrorBound
      (BlockCode.relativeRadius (ι := Fin length) johnsonBelowRadius)
      ((citedMCAThreshold : ℝ) / (Fintype.card RSField : ℝ)) := by
  have hConcrete :
      MCA.Concrete.PaperMCAStatement citedMCAThreshold :=
    MCA.Concrete.widthOneTargetPaperMCA_implies_concreteLines
      bchksWidthOnePaperMutualCorrelatedAgreementErrorBound
  exact MCA.Concrete.concreteLines_imply_targetPaperMCA hConcrete

/--
Canonical RS bounds package supplied by cited list-decoding and MCA theorems.

This is the concrete `Bounds canonicalSmoothDomain` value used when the repo
wants to instantiate the canonical RS endpoint with the literature-backed
below-Johnson theorem inputs.
-/
def bounds : Bounds canonicalSmoothDomain where
  listSize := citedListSize
  threshold := citedMCAThreshold
  listDecodingBound := johnsonListDecodingBound
  listDecodingBoundAt := johnsonListDecodingBoundAt
  mutualCorrelatedAgreementBound := bchksMutualCorrelatedAgreementBound
  mutualCorrelatedAgreementErrorBound :=
    bchksMutualCorrelatedAgreementErrorBound
  paperMutualCorrelatedAgreementErrorBound :=
    bchksPaperMutualCorrelatedAgreementErrorBound

end

end CitedBounds
end CanonicalRS
end Proximity
end Hcrypt
