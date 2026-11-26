module

public import Proximity.Core.PolynomialAgreement

@[expose] public section

/-!
# Sharp agreement certificates on nonzero evaluation domains

Divide an agreement set's vanishing polynomial by a power of the evaluation
point to construct a received word. Its pair distance and the best possible
certificate bound can be compared independently.
-/

set_option autoImplicit false

namespace ProximityCoding.ReedSolomon.Parameters

open BlockCode CapacityList

variable {F ι : Type*} [Field F] [Fintype ι]

/-- For a set of intended agreements, the first column is its vanishing
polynomial divided by an evaluation-point power. The second column is zero. -/
noncomputable def rationalPowerPair (P : Parameters F ι) (agreementSites : Finset ι) :
    VectorWord ι F (Fin 2) := fun i j =>
  if j = 0 then
    (P.capacityVanishingPolynomial agreementSites).eval (P.domain.point i) /
      P.domain.point i ^ (agreementSites.card - P.degreeBound + 1)
  else 0

section

variable [DecidableEq F] (P : Parameters F ι) (agreementSites : Finset ι)

theorem rationalPowerPair_agreement_card_le
    (nonzeroDomain : ∀ i, P.domain.point i ≠ 0)
    (degree_le_matches : P.degreeBound ≤ agreementSites.card)
    {c : VectorWord ι F (Fin 2)} (valid : P.VectorCodeword (Fin 2) c) :
    (agreementSet c (P.rationalPowerPair agreementSites)).card ≤ agreementSites.card := by
  classical
  obtain ⟨p, degreeLt, eval_eq⟩ := valid 0
  let power := agreementSites.card - P.degreeBound + 1
  let vanishing := P.capacityVanishingPolynomial agreementSites
  let scaled := Polynomial.X ^ power * p
  have vanishingDegree : vanishing.natDegree = agreementSites.card :=
    P.capacityVanishingPolynomial_natDegree agreementSites
  have scaledDegree : scaled.natDegree ≤ agreementSites.card := by
    have mulDegree : scaled.natDegree ≤ (Polynomial.X ^ power : Polynomial F).natDegree +
        p.natDegree := Polynomial.natDegree_mul_le
    rw [Polynomial.natDegree_X_pow] at mulDegree
    dsimp [power] at mulDegree
    omega
  by_contra cap
  have tooMany := Nat.lt_of_not_ge cap
  have same : scaled = vanishing := by
    apply Polynomial.eq_of_degrees_lt_of_eval_index_eq _ P.domain.injective_point.injOn
    · exact Polynomial.degree_le_natDegree.trans_lt
        (WithBot.coe_lt_coe.mpr (scaledDegree.trans_lt tooMany))
    · exact Polynomial.degree_le_natDegree.trans_lt
        (WithBot.coe_lt_coe.mpr (vanishingDegree ▸ tooMany))
    · intro i hi
      have agree : c i = P.rationalPowerPair agreementSites i := (Finset.mem_filter.mp hi).2
      have eval_match := (eval_eq i).symm.trans (congrFun agree (0 : Fin 2))
      change p.eval (P.domain.point i) = vanishing.eval (P.domain.point i) /
        (P.domain.point i) ^ power at eval_match
      simp only [scaled, Polynomial.eval_mul, Polynomial.eval_pow, Polynomial.eval_X]
      rw [eval_match, mul_comm, div_mul_cancel₀ _ (pow_ne_zero _ (nonzeroDomain i))]
  have scaledAtZero : scaled.eval 0 = 0 := by
    simp [scaled, power]
  have vanishingAtZero : vanishing.eval 0 ≠ 0 := by
    simp only [vanishing, capacityVanishingPolynomial, Polynomial.eval_prod,
      Polynomial.eval_sub, Polynomial.eval_X, Polynomial.eval_C, zero_sub]
    exact Finset.prod_ne_zero_iff.mpr (fun i _ => neg_ne_zero.mpr (nonzeroDomain i))
  exact vanishingAtZero (same ▸ scaledAtZero)

/-- The zero pair meets the agreement cap, making the true count explicit. -/
theorem rationalPowerPair_hammingDistanceToCode
    (nonzeroDomain : ∀ i, P.domain.point i ≠ 0)
    (positiveDegree : 0 < P.degreeBound) (degree_le_matches : P.degreeBound ≤ agreementSites.card) :
    (P.vectorBlockCode (Fin 2)).hammingDistanceToCode (P.rationalPowerPair agreementSites) =
      Fintype.card ι - agreementSites.card := by
  classical
  let w := P.rationalPowerPair agreementSites
  change (P.vectorBlockCode (Fin 2)).hammingDistanceToCode w = _
  let zero : VectorWord ι F (Fin 2) := fun _ _ => 0
  have validZero : P.VectorCodeword (Fin 2) zero :=
    fun _ => (P.fAdditive_of_degreeBound_pos positiveDegree).zero_mem
  have zeroMatches : agreementSet zero w = agreementSites := by
    ext i
    simp only [agreementSet, Finset.mem_filter, Finset.mem_univ, true_and]
    constructor
    · intro same
      have first := (congrFun same (0 : Fin 2)).symm
      change (P.capacityVanishingPolynomial agreementSites).eval (P.domain.point i) /
        (P.domain.point i) ^ (agreementSites.card - P.degreeBound + 1) = 0 at first
      exact (P.eval_capacityVanishingPolynomial_eq_zero_iff agreementSites i).mp
        ((div_eq_zero_iff.mp first).resolve_right (pow_ne_zero _ (nonzeroDomain i)))
    · intro member
      funext j
      have vanishes := (P.eval_capacityVanishingPolynomial_eq_zero_iff agreementSites i).mpr member
      simp [zero, w, rationalPowerPair, vanishes]
  have upper := (P.vectorBlockCode (Fin 2)).hammingDistanceToCode_le_of_codeword
    (w := w) validZero
  have zeroPartition := agreement_card_add_hammingDistance zero w
  rw [zeroMatches] at zeroPartition
  obtain ⟨c, valid, nearest⟩ := (P.vectorBlockCode (Fin 2)).exists_nearest_codeword ⟨zero, validZero⟩ w
  have cap := P.rationalPowerPair_agreement_card_le agreementSites nonzeroDomain degree_le_matches valid
  change (agreementSet c w).card ≤ agreementSites.card at cap
  have partition := agreement_card_add_hammingDistance c w
  exact le_antisymm (by omega) (by omega)

omit [DecidableEq F] in
/-- No polynomial multiplier certificate can certify more discrepancies
than this gap above the designed dimension. -/
theorem rationalPowerPair_certificate_bound
    (nonzeroDomain : ∀ i, P.domain.point i ≠ 0)
    (positiveDegree : 0 < P.degreeBound) (degree_le_matches : P.degreeBound ≤ agreementSites.card)
    (cert : P.PairAgreementCertificate (P.rationalPowerPair agreementSites)) :
    Fintype.card ι - cert.response.natDegree ≤ agreementSites.card - P.degreeBound + 1 := by
  classical
  let power := agreementSites.card - P.degreeBound + 1
  let left := Polynomial.X ^ power * cert.response
  let right := cert.multipliers 0 * P.capacityVanishingPolynomial agreementSites
  have responseNonzero : cert.response ≠ 0 := by
    intro zero
    have separation := cert.degree_separates
    rw [zero, Polynomial.natDegree_zero] at separation
    omega
  have leftDegree : left.natDegree = power + cert.response.natDegree := by
    change (Polynomial.X ^ power * cert.response).natDegree = _
    rw [Polynomial.natDegree_mul (pow_ne_zero _ Polynomial.X_ne_zero) responseNonzero,
      Polynomial.natDegree_X_pow]
  have rightDegree : right.natDegree < left.natDegree := by
    have mulDegree : right.natDegree ≤ (cert.multipliers 0).natDegree +
        (P.capacityVanishingPolynomial agreementSites).natDegree := Polynomial.natDegree_mul_le
    rw [P.capacityVanishingPolynomial_natDegree] at mulDegree
    have multiplierBound := cert.multiplier_degree_le 0
    have separation := cert.degree_separates
    rw [leftDegree]
    dsimp [power]
    omega
  by_contra bound
  have degree_lt_length : left.natDegree < (Finset.univ : Finset ι).card := by
    rw [Finset.card_univ, leftDegree]
    dsimp [power]
    omega
  have same : left = right := by
    apply Polynomial.eq_of_degrees_lt_of_eval_index_eq (Finset.univ : Finset ι)
      P.domain.injective_point.injOn
    · exact Polynomial.degree_le_natDegree.trans_lt (WithBot.coe_lt_coe.mpr degree_lt_length)
    · exact Polynomial.degree_le_natDegree.trans_lt
        (WithBot.coe_lt_coe.mpr (rightDegree.trans degree_lt_length))
    · intro i _
      have first : P.rationalPowerPair agreementSites i 0 =
          (P.capacityVanishingPolynomial agreementSites).eval (P.domain.point i) /
            P.domain.point i ^ power := rfl
      have second : P.rationalPowerPair agreementSites i 1 = 0 := rfl
      simp only [left, right, Polynomial.eval_mul, Polynomial.eval_pow, Polynomial.eval_X,
        cert.response_eval, first, second, mul_zero, add_zero]
      rw [mul_left_comm, mul_div_cancel₀ _ (pow_ne_zero _ (nonzeroDomain i))]
  exact (Nat.ne_of_lt rightDegree) (congrArg Polynomial.natDegree same.symm)

end

end ProximityCoding.ReedSolomon.Parameters
