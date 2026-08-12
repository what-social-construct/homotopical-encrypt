import Proximity.Core.BlockCode
import Mathlib.Algebra.Polynomial.Basic
import Mathlib.LinearAlgebra.Lagrange

/-!
# Generic Reed--Solomon foundations

This module defines evaluation domains, scalar RS codewords, and interleaved
RS codewords. It contains no list-decoding-capacity or MCA theorem assumption.
-/

namespace ProximityPrize
namespace ReedSolomon

/-- Paper-style vector symbols `F^s`. -/
abbrev VectorSymbol (F σ : Type*) := σ → F

/-- Paper-style vector received words `(F^s)^n`. -/
abbrev VectorWord (ι F σ : Type*) := Word ι (VectorSymbol F σ)

/-- A finite injectively indexed evaluation domain. -/
structure EvaluationDomain (F ι : Type*) where
  point : ι → F
  injective_point : Function.Injective point

/-- An evaluation domain carrying the smoothness obligation used by the paper. -/
structure SmoothEvaluationDomain (F ι : Type*)
    extends EvaluationDomain F ι where
  smooth : Prop

/-- Reed--Solomon evaluation parameters and degree bound. -/
structure Parameters (F ι : Type*) [Field F] [Fintype ι] where
  domain : EvaluationDomain F ι
  degreeBound : ℕ

namespace Parameters

variable {F ι : Type*} [Field F] [Fintype ι]

open CapacityList

/-- Block length. -/
def length (_P : Parameters F ι) : ℕ :=
  Fintype.card ι

/-- Designed dimension bound. -/
def dimensionBound (P : Parameters F ι) : ℕ :=
  P.degreeBound

/-- Evaluation of a polynomial of degree strictly below the degree bound. -/
def Codeword (P : Parameters F ι) (w : Word ι F) : Prop :=
  ∃ p : Polynomial F,
    p.natDegree < P.degreeBound ∧
      ∀ i : ι, w i = Polynomial.eval (P.domain.point i) p

/-- The scalar RS code as a generic block code. -/
def toBlockCode (P : Parameters F ι) : BlockCode ι F where
  Codeword := P.Codeword

/-- The paper alphabet `C^{≡s} ⊆ (F^s)^n`. -/
def vectorBlockCode (P : Parameters F ι) (σ : Type*) :
    BlockCode ι (VectorSymbol F σ) :=
  P.toBlockCode.interleaved σ

/-- Codeword predicate for the vector-symbol RS code. -/
def VectorCodeword
    (P : Parameters F ι)
    (σ : Type*)
    (w : VectorWord ι F σ) : Prop :=
  (P.vectorBlockCode σ).Codeword w

/-- Scalar Reed--Solomon words are determined by any `k` evaluations. -/
theorem determinedBy_degreeBound
    (P : ReedSolomon.Parameters F ι) :
    DeterminedBy P.toBlockCode P.degreeBound := by
  intro c d hc hd S hS hagree
  rcases hc with ⟨p, hp, hp_eval⟩
  rcases hd with ⟨q, hq, hq_eval⟩
  have hp_degree : p.degree < (S.card : WithBot ℕ) := by
    rw [hS]
    exact lt_of_le_of_lt Polynomial.degree_le_natDegree
      (WithBot.coe_lt_coe.2 hp)
  have hq_degree : q.degree < (S.card : WithBot ℕ) := by
    rw [hS]
    exact lt_of_le_of_lt Polynomial.degree_le_natDegree
      (WithBot.coe_lt_coe.2 hq)
  have hpq : p = q := by
    apply Polynomial.eq_of_degrees_lt_of_eval_index_eq S
      P.domain.injective_point.injOn hp_degree hq_degree
    intro i hi
    rw [← hp_eval i, ← hq_eval i]
    exact hagree i hi
  funext i
  rw [hp_eval i, hq_eval i, hpq]

/-- Every interleaving width retains the same `k`-point determination bound. -/
theorem vectorDeterminedBy_degreeBound
    (P : ReedSolomon.Parameters F ι)
    (σ : Type*) :
    DeterminedBy (P.vectorBlockCode σ) P.degreeBound := by
  intro c d hc hd S hS hagree
  funext i j
  have hcomponent :
      (fun i => c i j) = (fun i => d i j) := by
    apply P.determinedBy_degreeBound (hc j) (hd j) S hS
    intro a ha
    exact congrFun (hagree a ha) j
  exact congrFun hcomponent i

/-- F-additivity certificate for an RS parameter choice. -/
structure FAdditive (P : Parameters F ι) : Prop where
  zero_mem : P.Codeword fun _ => 0
  add_mem :
    ∀ {u v : Word ι F},
      P.Codeword u → P.Codeword v →
        P.Codeword fun i => u i + v i
  smul_mem :
    ∀ (a : F) {u : Word ι F},
      P.Codeword u → P.Codeword fun i => a • u i

namespace FAdditive

/-- View an additive RS code through the generic additive-code interface. -/
def toFAdditiveCode
    {P : Parameters F ι}
    (hP : P.FAdditive) :
    FAdditiveCode F ι F where
  Codeword := P.Codeword
  zero_mem := hP.zero_mem
  add_mem := hP.add_mem
  smul_mem := hP.smul_mem

/-- View an additive RS code over a vector-symbol alphabet. -/
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

/-- Positive-degree-bound RS codes are closed under field-linear operations. -/
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

end Parameters
end ReedSolomon
end ProximityPrize
