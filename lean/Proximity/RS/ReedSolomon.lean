import Proximity.RS.CorrelatedAgreement
import ProximityPrize.ReedSolomon

/-!
# Compatibility and application predicates for Reed--Solomon codes

`ProximityPrize.ReedSolomon` owns evaluation domains, scalar/vector codewords,
and F-additivity. This module preserves their historical `Hcrypt.Proximity`
names and retains the Paper 1 list/CA/MCA predicate adapters.
-/

namespace Hcrypt
namespace Proximity
namespace ReedSolomon

/-- Compatibility alias for paper-style vector symbols. -/
abbrev VectorSymbol (F σ : Type*) :=
  ProximityPrize.ReedSolomon.VectorSymbol F σ

/-- Compatibility alias for vector received words. -/
abbrev VectorWord (ι F σ : Type*) :=
  ProximityPrize.ReedSolomon.VectorWord ι F σ

/-- Compatibility alias for injectively indexed evaluation domains. -/
abbrev EvaluationDomain (F ι : Type*) :=
  ProximityPrize.ReedSolomon.EvaluationDomain F ι

/-- Compatibility alias for smooth evaluation domains. -/
abbrev SmoothEvaluationDomain (F ι : Type*) :=
  ProximityPrize.ReedSolomon.SmoothEvaluationDomain F ι

/-- Compatibility alias for standalone RS parameters. -/
abbrev Parameters (F ι : Type*) [Field F] [Fintype ι] :=
  ProximityPrize.ReedSolomon.Parameters F ι

namespace Parameters

variable {F ι : Type*} [Field F] [Fintype ι]

abbrev length (P : Parameters F ι) : ℕ :=
  ProximityPrize.ReedSolomon.Parameters.length P

abbrev dimensionBound (P : Parameters F ι) : ℕ :=
  ProximityPrize.ReedSolomon.Parameters.dimensionBound P

abbrev Codeword (P : Parameters F ι) (w : Word ι F) : Prop :=
  ProximityPrize.ReedSolomon.Parameters.Codeword P w

abbrev toBlockCode (P : Parameters F ι) : BlockCode ι F :=
  ProximityPrize.ReedSolomon.Parameters.toBlockCode P

abbrev vectorBlockCode (P : Parameters F ι) (σ : Type*) :
    BlockCode ι (VectorSymbol F σ) :=
  ProximityPrize.ReedSolomon.Parameters.vectorBlockCode P σ

abbrev VectorCodeword
    (P : Parameters F ι)
    (σ : Type*)
    (w : VectorWord ι F σ) : Prop :=
  ProximityPrize.ReedSolomon.Parameters.VectorCodeword P σ w

/-- Compatibility alias for RS F-additivity certificates. -/
abbrev FAdditive (P : Parameters F ι) :=
  ProximityPrize.ReedSolomon.Parameters.FAdditive P

namespace FAdditive

abbrev toFAdditiveCode
    {P : Parameters F ι}
    (hP : P.FAdditive) :
    FAdditiveCode F ι F :=
  ProximityPrize.ReedSolomon.Parameters.FAdditive.toFAdditiveCode hP

abbrev toVectorFAdditiveCode
    {P : Parameters F ι}
    (hP : P.FAdditive)
    (σ : Type*) :
    FAdditiveCode F ι (VectorSymbol F σ) :=
  ProximityPrize.ReedSolomon.Parameters.FAdditive.toVectorFAdditiveCode hP σ

end FAdditive

abbrev fAdditive_of_degreeBound_pos
    (P : Parameters F ι)
    (hDegree : 0 < P.degreeBound) :
    P.FAdditive :=
  ProximityPrize.ReedSolomon.Parameters.fAdditive_of_degreeBound_pos P hDegree

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
