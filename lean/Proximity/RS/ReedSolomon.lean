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

/-- Paper-style vector symbols `F^s`, represented by coordinates `σ → F`. -/
abbrev VectorSymbol (F σ : Type*) :=
  σ → F

/-- Paper-style vector received words `(F^s)^n`. -/
abbrev VectorWord (ι F σ : Type*) :=
  Word ι (VectorSymbol F σ)

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

/--
The paper-alphabet RS endpoint `C ⊆ (F^s)^n`.

This is the `σ`-fold interleaving of the scalar RS code: a vector word is a
codeword exactly when every symbol coordinate is a scalar RS codeword.
-/
def vectorBlockCode (P : Parameters F ι) (σ : Type*) :
    BlockCode ι (VectorSymbol F σ) :=
  P.toBlockCode.interleaved σ

/-- Codeword predicate for the paper-alphabet endpoint `(F^s)^n`. -/
def VectorCodeword
    (P : Parameters F ι)
    (σ : Type*)
    (w : VectorWord ι F σ) : Prop :=
  (P.vectorBlockCode σ).Codeword w

/-- F-additivity/linearity certificate for an RS parameter choice. -/
structure FAdditive (P : Parameters F ι) : Prop where
  zero_mem :
    P.Codeword fun _ => 0
  add_mem :
    ∀ {u v : Word ι F},
      P.Codeword u →
        P.Codeword v →
          P.Codeword fun i => u i + v i
  smul_mem :
    ∀ (a : F) {u : Word ι F},
      P.Codeword u →
        P.Codeword fun i => a • u i

namespace FAdditive

/-- View an additive RS parameter choice as the generic additive-code interface. -/
def toFAdditiveCode
    {P : Parameters F ι}
    (hP : P.FAdditive) :
    FAdditiveCode F ι F where
  Codeword := P.Codeword
  zero_mem := hP.zero_mem
  add_mem := by
    intro u v hu hv
    exact hP.add_mem hu hv
  smul_mem := by
    intro a u hu
    exact hP.smul_mem a hu

/-- View an additive RS parameter choice as a paper-alphabet additive code. -/
def toVectorFAdditiveCode
    {P : Parameters F ι}
    (hP : P.FAdditive)
    (σ : Type*) :
    FAdditiveCode F ι (VectorSymbol F σ) where
  Codeword := (P.vectorBlockCode σ).Codeword
  zero_mem := by
    intro j
    simpa using hP.zero_mem
  add_mem := by
    intro u v hu hv j
    exact hP.add_mem (hu j) (hv j)
  smul_mem := by
    intro a u hu j
    exact hP.smul_mem a (hu j)

end FAdditive

/-- RS codewords are closed under the F-additive operations when the degree bound is positive. -/
def fAdditive_of_degreeBound_pos
    (P : Parameters F ι)
    (hDegree : 0 < P.degreeBound) :
    P.FAdditive where
  zero_mem := by
    refine ⟨0, ?_, ?_⟩
    · simpa using hDegree
    · intro i
      simp
  add_mem := by
    intro u v hu hv
    rcases hu with ⟨p, hpdeg, hpu⟩
    rcases hv with ⟨q, hqdeg, hqv⟩
    refine ⟨p + q, ?_, ?_⟩
    · exact (Polynomial.natDegree_add_le p q).trans_lt (max_lt hpdeg hqdeg)
    · intro i
      simp [hpu i, hqv i, Polynomial.eval_add]
  smul_mem := by
    intro a u hu
    rcases hu with ⟨p, hpdeg, hpu⟩
    refine ⟨a • p, ?_, ?_⟩
    · exact (Polynomial.natDegree_smul_le a p).trans_lt hpdeg
    · intro i
      simp [hpu i, Polynomial.eval_smul]

section ListDecoding

variable [DecidableEq F]

/-- RS list-decoding bound slot at Hamming radius `r` and list size `L`. -/
def ListDecodingBound (P : Parameters F ι) (r L : ℕ) : Prop :=
  P.toBlockCode.ListSizeBound r L

/-- RS list-decoding bound slot at relative Hamming radius `δ`. -/
def ListDecodingBoundAt (P : Parameters F ι) (δ : ℝ) (L : ℕ) : Prop :=
  P.toBlockCode.ListSizeBoundAt δ L

/-- Vector-valued RS list-decoding bound slot at Hamming radius `r`. -/
def VectorListDecodingBound
    (P : Parameters F ι)
    (σ : Type*)
    [DecidableEq (VectorSymbol F σ)]
    (r L : ℕ) : Prop :=
  (P.vectorBlockCode σ).ListSizeBound r L

/-- Vector-valued RS list-decoding bound slot at relative Hamming radius `δ`. -/
def VectorListDecodingBoundAt
    (P : Parameters F ι)
    (σ : Type*)
    [DecidableEq (VectorSymbol F σ)]
    (δ : ℝ) (L : ℕ) : Prop :=
  (P.vectorBlockCode σ).ListSizeBoundAt δ L

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

/-- Vector-valued RS mutual-correlated-agreement bound slot. -/
def VectorMutualCorrelatedAgreementBound
    (P : Parameters F ι)
    (σ : Type*)
    (pointRadius lineRadius threshold : ℕ) : Prop :=
  (P.vectorBlockCode σ).MutualCorrelatedAgreementBound
    (F := F) pointRadius lineRadius threshold

/-- Vector-valued RS MCA error bound slot in fractional paper notation. -/
def VectorMutualCorrelatedAgreementErrorBound
    (P : Parameters F ι)
    (σ : Type*)
    (δpoint δline ε : ℝ) : Prop :=
  (P.vectorBlockCode σ).MutualCorrelatedAgreementErrorBound
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

/-- Vector-valued RS Definition 4.1 CA error slot over `(F^s)^n`. -/
def VectorPaperCorrelatedAgreementErrorBound
    (P : Parameters F ι)
    (σ : Type*)
    [DecidableEq (VectorSymbol F σ)]
    (δfld δint ε : ℝ) : Prop :=
  (P.vectorBlockCode σ).PaperCorrelatedAgreementErrorBound
    (F := F) δfld δint ε

/-- Vector-valued RS Definition 4.3 MCA error slot over `(F^s)^n`. -/
def VectorPaperMutualCorrelatedAgreementErrorBound
    (P : Parameters F ι)
    (σ : Type*)
    [DecidableEq (VectorSymbol F σ)]
    (δ ε : ℝ) : Prop :=
  (P.vectorBlockCode σ).PaperMutualCorrelatedAgreementErrorBound
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
