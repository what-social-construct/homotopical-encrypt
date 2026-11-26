module

public import Proximity.Application.DistanceCalibration

@[expose] public section

/-!
# Polynomial certificates for Reed–Solomon pair agreement

A polynomial combination of the received columns can cap the number of
matching coordinates with any valid pair. The certificate checks evaluation
on the original domain and bounds the degrees of both multipliers. It does
not require a nearest codeword as input.
-/

set_option autoImplicit false

namespace ProximityCoding.ReedSolomon.Parameters

open BlockCode CapacityList

variable {F ι : Type*} [Field F] [Fintype ι]

/-- A polynomial representation of the weighted received pair on its actual domain. -/
structure PairAgreementCertificate (P : Parameters F ι) (w : VectorWord ι F (Fin 2)) where
  multipliers : Fin 2 → Polynomial F
  degreeBudget : ℕ
  response : Polynomial F
  multiplier_degree_le : ∀ j, (multipliers j).natDegree ≤ degreeBudget
  degree_separates : P.degreeBound + degreeBudget ≤ response.natDegree
  response_eval : ∀ i,
    response.eval (P.domain.point i) =
      (multipliers 0).eval (P.domain.point i) * w i 0 +
      (multipliers 1).eval (P.domain.point i) * w i 1

namespace PairAgreementCertificate

variable [DecidableEq F] {P : Parameters F ι} {w : VectorWord ι F (Fin 2)}

/-- Every full-pair agreement is an equality between the received response
and the lower-degree combination of the two valid polynomials. -/
theorem agreement_card_le (cert : P.PairAgreementCertificate w)
    {c : VectorWord ι F (Fin 2)} (valid : P.VectorCodeword (Fin 2) c) :
    (agreementSet c w).card ≤ cert.response.natDegree := by
  obtain ⟨p₀, degree₀, eval₀⟩ := valid 0
  obtain ⟨p₁, degree₁, eval₁⟩ := valid 1
  let candidate := cert.multipliers 0 * p₀ + cert.multipliers 1 * p₁
  have product_degree_lt (j : Fin 2) (p : Polynomial F)
      (small : p.natDegree < P.degreeBound) :
      (cert.multipliers j * p).natDegree < cert.response.natDegree := by
    have productBound := Polynomial.natDegree_mul_le (p := cert.multipliers j) (q := p)
    have multiplierBound := cert.multiplier_degree_le j
    have responseBound := cert.degree_separates
    omega
  have candidateDegree : candidate.natDegree < cert.response.natDegree :=
    (Polynomial.natDegree_add_le _ _).trans_lt
      (max_lt (product_degree_lt 0 p₀ degree₀) (product_degree_lt 1 p₁ degree₁))
  by_contra bound
  have responseDegree := Nat.lt_of_not_ge bound
  have equal : candidate = cert.response := by
    apply Polynomial.eq_of_degrees_lt_of_eval_index_eq (agreementSet c w)
      P.domain.injective_point.injOn
    · exact Polynomial.degree_le_natDegree.trans_lt
        (WithBot.coe_lt_coe.mpr (candidateDegree.trans responseDegree))
    · exact Polynomial.degree_le_natDegree.trans_lt (WithBot.coe_lt_coe.mpr responseDegree)
    · intro i hi
      have matchAt : c i = w i := (Finset.mem_filter.mp hi).2
      have first := (eval₀ i).symm.trans (congrFun matchAt 0)
      have second := (eval₁ i).symm.trans (congrFun matchAt 1)
      simp only [candidate, Polynomial.eval_add, Polynomial.eval_mul]
      rw [first, second]
      exact (cert.response_eval i).symm
  exact (Nat.ne_of_lt candidateDegree) (congrArg Polynomial.natDegree equal)

/-- The degree cap bounds whole-pair distance on the same received word. -/
theorem hammingDistanceToCode_ge (cert : P.PairAgreementCertificate w)
    (positiveDegree : 0 < P.degreeBound) :
    Fintype.card ι - cert.response.natDegree ≤ (P.vectorBlockCode (Fin 2)).hammingDistanceToCode w := by
  have nonempty := P.toBlockCode.interleaved_nonempty (P.code_nonempty positiveDegree) (Fin 2)
  obtain ⟨c, valid, nearest⟩ := (P.vectorBlockCode (Fin 2)).exists_nearest_codeword nonempty w
  have cap := cert.agreement_card_le valid
  have partition := agreement_card_add_hammingDistance c w
  omega

theorem relativeDistanceToCode_ge (cert : P.PairAgreementCertificate w)
    (positiveDegree : 0 < P.degreeBound) :
    relativeRadius (ι := ι) (Fintype.card ι - cert.response.natDegree) ≤
      (P.vectorBlockCode (Fin 2)).relativeDistanceToCode w := by
  unfold relativeRadius relativeDistanceToCode
  exact div_le_div_of_nonneg_right
    (by exact_mod_cast cert.hammingDistanceToCode_ge positiveDegree) (Nat.cast_nonneg _)

theorem relativeDistanceToCode_eq_capacity [DecidableEq ι] (cert : P.PairAgreementCertificate w)
    (positiveDegree : 0 < P.degreeBound) (degree_le_length : P.degreeBound ≤ Fintype.card ι)
    (responseDegree : cert.response.natDegree = P.degreeBound) :
    (P.vectorBlockCode (Fin 2)).relativeDistanceToCode w =
      relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound) :=
  le_antisymm (P.vector_relativeDistanceToCode_le_capacity positiveDegree degree_le_length _ _)
    (by simpa only [responseDegree] using cert.relativeDistanceToCode_ge positiveDegree)

end PairAgreementCertificate

end ProximityCoding.ReedSolomon.Parameters
