import Proximity.RS.CorrelatedAgreement
import Mathlib.Algebra.Polynomial.Basic

/-
  Reed-Solomon-specific proximity vocabulary.

  The generic CA/MCA/list-decoding layer lives in `ListDecoding.lean` and
  `CorrelatedAgreement.lean`. This file only instantiates the target shape for
  polynomial-evaluation codes. Bounds such as Johnson, list-decoding capacity,
  or RS mutual correlated agreement remain explicit assumptions/theorem slots.
-/

namespace Hcrypt
namespace Proximity
namespace ReedSolomon

/-- A finite evaluation domain for a Reed-Solomon code. -/
structure EvaluationDomain (F ι : Type*) where
  point : ι → F
  injective_point : Function.Injective point

/--
A smooth evaluation domain, in the sense needed by prize-style RS statements.

The concrete witness may later be a subgroup/coset/power-of-two certificate.
For now it is kept as a proposition so the RS file names the obligation without
committing to one field-family implementation.
-/
structure SmoothEvaluationDomain (F ι : Type*) extends EvaluationDomain F ι where
  smooth : Prop

/-- Reed-Solomon parameters: evaluation domain plus degree bound. -/
structure Parameters (F ι : Type*) [Field F] [Fintype ι] where
  domain : EvaluationDomain F ι
  degreeBound : ℕ

namespace Parameters

variable {F ι : Type*} [Field F] [Fintype ι]

/-- The block length of the RS instance. -/
def length (_P : Parameters F ι) : ℕ :=
  Fintype.card ι

/-- The designed dimension bound of the RS instance. -/
def dimensionBound (P : Parameters F ι) : ℕ :=
  P.degreeBound

/-- A word is an RS codeword when it is the evaluation of a low-degree polynomial. -/
def Codeword (P : Parameters F ι) (w : Word ι F) : Prop :=
  ∃ p : Polynomial F,
    p.natDegree < P.degreeBound ∧
      ∀ i : ι, w i = Polynomial.eval (P.domain.point i) p

/-- The RS instance as a generic block code. -/
def toBlockCode (P : Parameters F ι) : BlockCode ι F where
  Codeword := P.Codeword

section ListDecoding

variable [DecidableEq F]

/-- RS list-decoding bound slot at Hamming radius `r` and list size `L`. -/
def ListDecodingBound (P : Parameters F ι) (r L : ℕ) : Prop :=
  P.toBlockCode.ListSizeBound r L

/-- RS list-decoding bound slot at relative Hamming radius `δ`. -/
def ListDecodingBoundAt (P : Parameters F ι) (δ : ℝ) (L : ℕ) : Prop :=
  P.toBlockCode.ListSizeBoundAt δ L

end ListDecoding

section CorrelatedAgreement

variable [Fintype F]

/-- RS correlated-agreement bound slot. -/
def CorrelatedAgreementBound
    (P : Parameters F ι)
    (pointRadius lineRadius threshold : ℕ) : Prop :=
  P.toBlockCode.CorrelatedAgreementBound
    (F := F) pointRadius lineRadius threshold

/-- RS correlated-agreement error bound slot in fractional paper notation. -/
def CorrelatedAgreementErrorBound
    (P : Parameters F ι)
    (δpoint δline ε : ℝ) : Prop :=
  P.toBlockCode.CorrelatedAgreementErrorBound
    (F := F) δpoint δline ε

/-- RS mutual-correlated-agreement bound slot. -/
def MutualCorrelatedAgreementBound
    (P : Parameters F ι)
    (pointRadius lineRadius threshold : ℕ) : Prop :=
  P.toBlockCode.MutualCorrelatedAgreementBound
    (F := F) pointRadius lineRadius threshold

/-- RS mutual-correlated-agreement error bound slot in fractional paper notation. -/
def MutualCorrelatedAgreementErrorBound
    (P : Parameters F ι)
    (δpoint δline ε : ℝ) : Prop :=
  P.toBlockCode.MutualCorrelatedAgreementErrorBound
    (F := F) δpoint δline ε

section PaperErrorBounds

variable [DecidableEq F]

/-- RS Definition 4.1 CA error slot, including proximity loss. -/
def PaperCorrelatedAgreementErrorBound
    (P : Parameters F ι)
    (δfld δint ε : ℝ) : Prop :=
  P.toBlockCode.PaperCorrelatedAgreementErrorBound
    (F := F) δfld δint ε

/-- RS Definition 4.3 MCA error slot. -/
def PaperMutualCorrelatedAgreementErrorBound
    (P : Parameters F ι)
    (δ ε : ℝ) : Prop :=
  P.toBlockCode.PaperMutualCorrelatedAgreementErrorBound
    (F := F) δ ε

end PaperErrorBounds

/-- MCA bounds imply CA bounds for RS because the implication is code-generic. -/
theorem correlatedAgreement_of_mutualCorrelatedAgreement
    (P : Parameters F ι)
    {pointRadius lineRadius threshold : ℕ}
    (hmca :
      P.MutualCorrelatedAgreementBound pointRadius lineRadius threshold) :
    P.CorrelatedAgreementBound pointRadius lineRadius threshold :=
  BlockCode.correlatedAgreement_of_mutualCorrelatedAgreement
    (F := F) P.toBlockCode hmca

end CorrelatedAgreement

end Parameters

end ReedSolomon
end Proximity
end Hcrypt
