module

public import Proximity.Core.PolynomialAgreement

@[expose] public section

/-!
# Constructing polynomial agreement certificates from error locations

An agreement polynomial vanishes at the matching coordinates. On each
mismatch, one nonzero error component suffices to prescribe the value of the
weighted error. Interpolation on the mismatch set gives the multipliers.
-/

set_option autoImplicit false

namespace ProximityCoding.ReedSolomon.Parameters.PairAgreementCertificate

open BlockCode CapacityList

variable {F ι : Type*} [Field F] [Fintype ι] [DecidableEq F] [DecidableEq ι]
  {P : Parameters F ι} {w : VectorWord ι F (Fin 2)}

/-- A valid pair at error count `e` gives a certificate of budget
`e - 1` and response degree `max (n - e) (k + e - 1)`. -/
theorem exists_with_degree_of_codeword {c : VectorWord ι F (Fin 2)}
    (valid : P.VectorCodeword (Fin 2) c) :
    ∃ cert : P.PairAgreementCertificate w,
      cert.degreeBudget = hammingDistance c w - 1 ∧
      cert.response.natDegree =
        max (Fintype.card ι - hammingDistance c w) (P.degreeBound + (hammingDistance c w - 1)) := by
  obtain ⟨p₀, degree₀, eval₀⟩ := valid 0
  obtain ⟨p₁, degree₁, eval₁⟩ := valid 1
  let agreements := agreementSet c w
  let errors := Finset.univ.filter fun i => c i ≠ w i
  let budget := hammingDistance c w - 1
  let target := max (Fintype.card ι - hammingDistance c w) (P.degreeBound + budget)
  have agreementCard : agreements.card = Fintype.card ι - hammingDistance c w := by
    have partition := agreement_card_add_hammingDistance c w
    dsimp [agreements]
    omega
  have errorsCard : errors.card = hammingDistance c w := rfl
  let vanishing := P.capacityVanishingPolynomial agreements
  let signal := vanishing * Polynomial.X ^ (target - agreements.card)
  have vanishingNonzero : vanishing ≠ 0 :=
    (Polynomial.monic_prod_X_sub_C P.domain.point agreements).ne_zero
  have signalDegree : signal.natDegree = target := by
    dsimp only [signal, vanishing]
    rw [Polynomial.natDegree_mul_X_pow _ vanishingNonzero,
      P.capacityVanishingPolynomial_natDegree]
    exact Nat.add_sub_of_le (agreementCard.le.trans (le_max_left _ _))
  let pivot (i : ι) : Fin 2 := if w i 0 = c i 0 then 1 else 0
  let values (j : Fin 2) (i : ι) : F :=
    if j = pivot i then signal.eval (P.domain.point i) / (w i j - c i j) else 0
  let multipliers (j : Fin 2) := Lagrange.interpolate errors P.domain.point (values j)
  have degree_le (j : Fin 2) : (multipliers j).natDegree ≤ budget := by
    have degree := Polynomial.natDegree_le_of_degree_le
      (Lagrange.degree_interpolate_le (s := errors) (values j) P.domain.injective_point.injOn)
    simpa only [errorsCard] using degree
  let correction := multipliers 0 * p₀ + multipliers 1 * p₁
  have separates : P.degreeBound + budget ≤ target := le_max_right _ _
  have product_lt (j : Fin 2) (p : Polynomial F) (small : p.natDegree < P.degreeBound) :
      (multipliers j * p).natDegree < target := by
    have degree := Polynomial.natDegree_mul_le (p := multipliers j) (q := p)
    have weightDegree := degree_le j
    omega
  have correctionDegree : correction.natDegree < target :=
    (Polynomial.natDegree_add_le _ _).trans_lt
      (max_lt (product_lt 0 p₀ degree₀) (product_lt 1 p₁ degree₁))
  have responseDegree : (signal + correction).natDegree = target := by
    have shorter : correction.natDegree < signal.natDegree := by rwa [signalDegree]
    rw [Polynomial.natDegree_add_eq_left_of_natDegree_lt shorter, signalDegree]
  refine ⟨⟨multipliers, budget, signal + correction, degree_le, ?_, ?_⟩, rfl, responseDegree⟩
  · exact responseDegree.symm ▸ separates
  · intro i
    have first : p₀.eval (P.domain.point i) = c i 0 := (eval₀ i).symm
    have second : p₁.eval (P.domain.point i) = c i 1 := (eval₁ i).symm
    simp only [Polynomial.eval_add, correction, Polynomial.eval_mul, first, second]
    by_cases same : c i = w i
    · have member : i ∈ agreements := Finset.mem_filter.mpr ⟨Finset.mem_univ _, same⟩
      have zero : vanishing.eval (P.domain.point i) = 0 :=
        (P.eval_capacityVanishingPolynomial_eq_zero_iff agreements i).mpr member
      have signalZero : signal.eval (P.domain.point i) = 0 := by
        simp [signal, zero]
      rw [signalZero, zero_add, congrFun same 0, congrFun same 1]
    · have member : i ∈ errors := Finset.mem_filter.mpr ⟨Finset.mem_univ _, same⟩
      have value_eq (j : Fin 2) : (multipliers j).eval (P.domain.point i) = values j i :=
        Lagrange.eval_interpolate_at_node (values j) P.domain.injective_point.injOn member
      have weightedError : values 0 i * (w i 0 - c i 0) +
          values 1 i * (w i 1 - c i 1) = signal.eval (P.domain.point i) := by
        by_cases firstMatches : w i 0 = c i 0
        · have secondDiffers : w i 1 ≠ c i 1 := by
            intro secondMatches
            apply same
            funext j
            fin_cases j
            · exact firstMatches.symm
            · exact secondMatches.symm
          simp [values, pivot, firstMatches, sub_ne_zero.mpr secondDiffers]
        · simp [values, pivot, firstMatches, sub_ne_zero.mpr firstMatches]
      rw [value_eq 0, value_eq 1, ← weightedError]
      ring

/-- At positive true error count `e`, the certificate family guarantees the
count bound `min(e, n - k + 1 - e)`. -/
theorem exists_with_distance_bound (positiveDegree : 0 < P.degreeBound)
    {e : ℕ} (distance : (P.vectorBlockCode (Fin 2)).hammingDistanceToCode w = e)
    (positiveError : 0 < e) :
    ∃ cert : P.PairAgreementCertificate w, cert.degreeBudget = e - 1 ∧
      Fintype.card ι - cert.response.natDegree = min e (Fintype.card ι - P.degreeBound + 1 - e) := by
  let code := P.vectorBlockCode (Fin 2)
  have nonempty := P.toBlockCode.interleaved_nonempty (P.code_nonempty positiveDegree) (Fin 2)
  obtain ⟨c, valid, nearest⟩ := code.exists_nearest_codeword nonempty w
  have count : hammingDistance c w = e := nearest.symm.trans distance
  obtain ⟨cert, budget, degree⟩ := exists_with_degree_of_codeword valid
  have length := (hammingDistance_le_length c w)
  refine ⟨cert, budget.trans (congrArg (· - 1) count), ?_⟩
  omega

/-- At or below half the minimum count distance, the search can attain the
true positive distance. The endpoint allows tied nearest codewords. -/
theorem exists_exact_of_twice_distance_le (positiveDegree : 0 < P.degreeBound)
    {e : ℕ} (distance : (P.vectorBlockCode (Fin 2)).hammingDistanceToCode w = e)
    (positiveError : 0 < e) (twice_le : 2 * e ≤ Fintype.card ι - P.degreeBound + 1) :
    ∃ cert : P.PairAgreementCertificate w, cert.degreeBudget = e - 1 ∧
      Fintype.card ι - cert.response.natDegree = e := by
  obtain ⟨cert, budget, bound⟩ := exists_with_distance_bound positiveDegree distance positiveError
  exact ⟨cert, budget, bound.trans (min_eq_left (by omega))⟩

end ProximityCoding.ReedSolomon.Parameters.PairAgreementCertificate
