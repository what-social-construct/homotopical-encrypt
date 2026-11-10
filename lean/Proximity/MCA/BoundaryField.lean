module

public import Proximity.Core.ReedSolomon
public import Proximity.MCA.SmallRadius
public import Mathlib.GroupTheory.OrderOfElement
public import Mathlib.NumberTheory.LucasPrimality
public meta import Mathlib.Algebra.Field.ZMod
public meta import Mathlib.Tactic.NormNum
public meta import Mathlib.Tactic.ReduceModChar

@[expose] public section

/-!
# A smooth boundary-field Reed--Solomon instance at 128-bit security

This file certifies the arithmetic and evaluation-domain layer for the
boundary-field example

* `q = 2^128 + 192513`,
* block length `n = 4096`, and
* degree bound `k = 1024`.

The primality proof is a Lucas/Pratt certificate rooted at the full generator
`7`.  Raising that generator to `(q - 1) / 4096` gives the displayed
order-`4096` root.  Its first `4096` powers therefore form an injectively
indexed Reed--Solomon evaluation domain. The arithmetic certificates use
kernel-checked numeral normalization and binary modular exponentiation.
-/

namespace ProximityCoding
namespace MCA
namespace BoundaryField

noncomputable section

/-- The security-boundary modulus `2^128 + 192513`. -/
def modulus : ℕ :=
  340282366920938463463374607431768403969

/-- The boundary modulus has the advertised offset above `2^128`. -/
theorem modulus_eq_two_pow_128_add :
    modulus = 2 ^ 128 + 192513 := by
  norm_num [modulus]

/-- Smooth power-of-two block length. -/
def length : ℕ := 4096

/-- Constant-rate degree bound `k = n / 4`. -/
def degreeBound : ℕ := 1024

/-- The selected degree bound has rate exactly `1/4`. -/
theorem four_mul_degreeBound_eq_length :
    4 * degreeBound = length := by
  norm_num [degreeBound, length]

/-- The selected length divides the boundary field's multiplicative order. -/
theorem length_dvd_modulus_sub_one :
    length ∣ modulus - 1 := by
  norm_num [length, modulus]

/-- The cofactor used to descend from a full generator to order `4096`. -/
def rootExponent : ℕ :=
  (modulus - 1) / length

theorem rootExponent_mul_length :
    rootExponent * length = modulus - 1 := by
  norm_num [rootExponent, modulus, length]

/-! ## Compact Lucas/Pratt primality certificates -/

/-- A prime divisor of a product of primes occurs in the factor list. -/
private theorem prime_mem_of_dvd_list_prod
    {p : ℕ}
    (hp : p.Prime) :
    ∀ {factors : List ℕ},
      (∀ q ∈ factors, q.Prime) →
      p ∣ factors.prod →
      p ∈ factors := by
  intro factors hprime hdvd
  induction factors with
  | nil =>
      simp at hdvd
      exact (hp.ne_one hdvd).elim
  | cons q factors ih =>
      rw [List.prod_cons] at hdvd
      rcases hp.dvd_mul.mp hdvd with hpq | hprest
      · have hq : q.Prime := hprime q (by simp)
        have hp_eq_q : p = q :=
          (Nat.prime_dvd_prime_iff_eq hp hq).mp hpq
        simp [hp_eq_q]
      · have hmem : p ∈ factors := by
          apply ih
          · intro r hr
            exact hprime r (by simp [hr])
          · exact hprest
        simp [hmem]

/-- Lucas primality with the factorization supplied as a finite prime list. -/
private theorem prime_of_lucas_factor_list
    (p : ℕ)
    (a : ZMod p)
    (factors : List ℕ)
    (hfactor : p - 1 = factors.prod)
    (hprime : ∀ q ∈ factors, q.Prime)
    (hpow : a ^ (p - 1) = 1)
    (hproper : ∀ q ∈ factors, a ^ ((p - 1) / q) ≠ 1) :
    p.Prime := by
  apply lucas_primality p a hpow
  intro q hq hq_dvd
  apply hproper q
  apply prime_mem_of_dvd_list_prod hq hprime
  simpa only [← hfactor] using hq_dvd

/-- A small-factor Lucas certificate avoids trial division of a 29-bit prime. -/
private theorem prime_524887931 : Nat.Prime 524887931 := by
  apply prime_of_lucas_factor_list
    524887931 (2 : ZMod 524887931) [2, 5, 7, 653, 11483]
  · norm_num
  · intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl | rfl | rfl | rfl
    all_goals norm_num
  · reduce_mod_char
  · intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl | rfl | rfl | rfl
    all_goals (reduce_mod_char; decide)

private theorem prime_1049775863 : Nat.Prime 1049775863 := by
  apply prime_of_lucas_factor_list
    1049775863 (5 : ZMod 1049775863) [2, 524887931]
  · norm_num
  · intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl
    · exact Nat.prime_two
    · exact prime_524887931
  · reduce_mod_char
  · intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl
    all_goals (reduce_mod_char; decide)

private theorem prime_6636571 : Nat.Prime 6636571 := by
  apply prime_of_lucas_factor_list
    6636571 (2 : ZMod 6636571) [2, 3, 5, 221219]
  · norm_num
  · intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl | rfl | rfl
    all_goals norm_num
  · reduce_mod_char
  · intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl | rfl | rfl
    all_goals (reduce_mod_char; decide)

private theorem prime_146004563 : Nat.Prime 146004563 := by
  apply prime_of_lucas_factor_list
    146004563 (2 : ZMod 146004563) [2, 11, 6636571]
  · norm_num
  · intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl | rfl
    · exact Nat.prime_two
    · norm_num
    · exact prime_6636571
  · reduce_mod_char
  · intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl | rfl
    all_goals (reduce_mod_char; decide)

private theorem prime_2044063883 : Nat.Prime 2044063883 := by
  apply prime_of_lucas_factor_list
    2044063883 (2 : ZMod 2044063883) [2, 7, 146004563]
  · norm_num
  · intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl | rfl
    · exact Nat.prime_two
    · norm_num
    · exact prime_146004563
  · reduce_mod_char
  · intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl | rfl
    all_goals (reduce_mod_char; decide)

/-- A 49-bit prime in the Pratt chain. -/
private theorem prime_439736412148619 :
    Nat.Prime 439736412148619 := by
  apply prime_of_lucas_factor_list
    439736412148619
    (2 : ZMod 439736412148619)
    [2, 13, 16111, 1049775863]
  · norm_num
  · intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl | rfl | rfl
    · exact Nat.prime_two
    · norm_num
    · norm_num
    · exact prime_1049775863
  · reduce_mod_char
  · intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl | rfl | rfl
    all_goals (reduce_mod_char; decide)

/-- A 60-bit prime in the Pratt chain. -/
private theorem prime_693904058370520783 :
    Nat.Prime 693904058370520783 := by
  apply prime_of_lucas_factor_list
    693904058370520783
    (3 : ZMod 693904058370520783)
    [2, 3, 263, 439736412148619]
  · norm_num
  · intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl | rfl | rfl
    · exact Nat.prime_two
    · exact Nat.prime_three
    · norm_num
    · exact prime_439736412148619
  · reduce_mod_char
  · intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl | rfl | rfl
    all_goals (reduce_mod_char; decide)

/-- A 51-bit prime in the Pratt chain. -/
private theorem prime_1995394721945771 :
    Nat.Prime 1995394721945771 := by
  apply prime_of_lucas_factor_list
    1995394721945771
    (2 : ZMod 1995394721945771)
    [2, 5, 31, 47, 67, 2044063883]
  · norm_num
  · intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl | rfl | rfl | rfl | rfl
    · exact Nat.prime_two
    · exact Nat.prime_five
    · norm_num
    · norm_num
    · norm_num
    · exact prime_2044063883
  · reduce_mod_char
  · intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl | rfl | rfl | rfl | rfl
    all_goals (reduce_mod_char; decide)

/-- The large prime factor of `modulus - 1`. -/
private theorem prime_27692249912185747352162647089173861 :
    Nat.Prime 27692249912185747352162647089173861 := by
  apply prime_of_lucas_factor_list
    27692249912185747352162647089173861
    (2 : ZMod 27692249912185747352162647089173861)
    [2, 2, 5, 693904058370520783, 1995394721945771]
  · norm_num
  · intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl | rfl | rfl | rfl
    · exact Nat.prime_two
    · exact Nat.prime_two
    · exact Nat.prime_five
    · exact prime_693904058370520783
    · exact prime_1995394721945771
  · reduce_mod_char
  · intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl | rfl | rfl | rfl
    all_goals (reduce_mod_char; decide)

/-- The boundary modulus is prime, certified by the Lucas witness `7`. -/
theorem modulus_prime : modulus.Prime := by
  unfold modulus
  apply prime_of_lucas_factor_list
    340282366920938463463374607431768403969
    (7 : ZMod 340282366920938463463374607431768403969)
    [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3,
      27692249912185747352162647089173861]
  · norm_num
  · intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with
      rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl |
      rfl | rfl | rfl | rfl | rfl | rfl
    all_goals first
      | exact Nat.prime_two
      | exact Nat.prime_three
      | exact prime_27692249912185747352162647089173861
  · reduce_mod_char
  · intro p hp
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with
      rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl |
      rfl | rfl | rfl | rfl | rfl | rfl
    all_goals (reduce_mod_char; decide)

/-- The finite field used by the boundary example. -/
abbrev RSField := ZMod modulus

/-- Install the certified field structure for `ZMod modulus`. -/
instance modulus_prime_fact : Fact modulus.Prime :=
  ⟨modulus_prime⟩

/-- The field has exactly `q` elements. -/
theorem card_RSField : Fintype.card RSField = modulus := by
  exact ZMod.card modulus

/-! ## Certified order-`4096` root and power domain -/

/-- The full Lucas generator used in the primality certificate. -/
def candidateGenerator : RSField := 7

/-- The advertised order-`4096` field element. -/
def candidateRoot : RSField :=
  138986559780198433259791608580824171955

/-- The displayed root is obtained by descending from the full generator. -/
theorem candidateGenerator_pow_rootExponent :
    candidateGenerator ^ rootExponent = candidateRoot := by
  have h : (7 : ZMod 340282366920938463463374607431768403969) ^
      83076749736557242056487941267521583 =
        138986559780198433259791608580824171955 := by
    reduce_mod_char
  exact h

/-- The displayed root as a multiplicative unit. -/
def candidateRootUnit : RSFieldˣ :=
  ZMod.unitOfCoprime
    138986559780198433259791608580824171955
    (by norm_num [modulus])

@[simp]
theorem candidateRootUnit_coe :
    (candidateRootUnit : RSField) = candidateRoot := by
  simp [candidateRootUnit, candidateRoot]

/-- The only prime divisor of the selected power-of-two length is `2`. -/
private theorem prime_dvd_length_eq_two
    {p : ℕ}
    (hp : p.Prime)
    (hpdvd : p ∣ length) :
    p = 2 := by
  have hpow : p ∣ 2 ^ 12 := by
    simpa [length] using hpdvd
  have hp2 : p ∣ 2 := hp.dvd_of_dvd_pow hpow
  exact (Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).mp hp2

/-- The displayed root has exact multiplicative order `4096`. -/
theorem candidateRootUnit_order :
    orderOf candidateRootUnit = length := by
  apply orderOf_eq_of_pow_and_pow_div_prime
  · norm_num [length]
  · ext
    have h : (138986559780198433259791608580824171955 :
        ZMod 340282366920938463463374607431768403969) ^ 4096 = 1 := by
      reduce_mod_char
    exact h
  · intro p hp hpdvd
    have hp_eq_two := prime_dvd_length_eq_two hp hpdvd
    subst p
    intro h
    have hcoe := congrArg ((↑) : RSFieldˣ → RSField) h
    have hne :
        ((candidateRootUnit ^ (length / 2) : RSFieldˣ) : RSField) ≠ 1 := by
      have h : (138986559780198433259791608580824171955 :
          ZMod 340282366920938463463374607431768403969) ^ 2048 ≠ 1 := by
        reduce_mod_char
        decide
      exact h
    exact hne hcoe

/-- Evaluation point `i` is the `i`-th power of the certified root. -/
def point (i : Fin length) : RSField :=
  (candidateRootUnit ^ (i : ℕ) : RSField)

/-- The first `4096` powers of the certified root are pairwise distinct. -/
theorem injective_point : Function.Injective point := by
  intro i j hij
  have hij_units :
      candidateRootUnit ^ (i : ℕ) =
        candidateRootUnit ^ (j : ℕ) := by
    ext
    simpa [point] using hij
  have hmod : (i : ℕ) ≡ (j : ℕ) [MOD length] := by
    have hmod_order :
        (i : ℕ) ≡ (j : ℕ) [MOD orderOf candidateRootUnit] :=
      (pow_eq_pow_iff_modEq).mp hij_units
    simpa [candidateRootUnit_order] using hmod_order
  have hval : (i : ℕ) = (j : ℕ) := by
    unfold Nat.ModEq at hmod
    simpa [Nat.mod_eq_of_lt i.isLt, Nat.mod_eq_of_lt j.isLt] using hmod
  exact Fin.ext hval

/-- The certified `4096`-point Reed--Solomon evaluation domain. -/
def evaluationDomain :
    ReedSolomon.EvaluationDomain RSField (Fin length) where
  point := point
  injective_point := injective_point

/-- The same power domain, carrying its explicit smoothness proposition. -/
def smoothEvaluationDomain :
    ReedSolomon.SmoothEvaluationDomain RSField (Fin length) where
  toEvaluationDomain := evaluationDomain
  smooth := length ∣ modulus - 1

/-- The smoothness proposition on the certified domain is inhabited. -/
theorem smoothEvaluationDomain_smooth :
    smoothEvaluationDomain.smooth :=
  length_dvd_modulus_sub_one

/-- Quarter-rate Reed--Solomon parameters over the boundary field. -/
def parameters :
    ReedSolomon.Parameters RSField (Fin length) where
  domain := evaluationDomain
  degreeBound := degreeBound

@[simp]
theorem parameters_degreeBound : parameters.degreeBound = 1024 :=
  rfl

@[simp]
theorem parameters_length : parameters.length = 4096 := by
  exact Fintype.card_fin length

/-! ## Exact 128-bit small-radius MCA spectrum -/

/-- One bad challenge fits in the certified boundary field. -/
theorem one_challenge_128_bit_budget :
    2 ^ 128 ≤ Fintype.card RSField := by
  rw [card_RSField]
  norm_num [modulus]

/-- Two bad challenges exceed the certified boundary-field budget. -/
theorem two_challenges_exceed_128_bit_budget :
    Fintype.card RSField < 2 ^ 128 * 2 := by
  rw [card_RSField]
  norm_num [modulus]

/-- At radius zero, every affine line has at most one bad challenge. -/
theorem radiusZero_uniform_count_certificate
    (L : AffineLine (Fin length) RSField) :
    (parameters.toBlockCode.badChallengeSet 0 L).card ≤ 1 := by
  exact parameters.badChallengeSet_zero_card_le_one (by norm_num [parameters, degreeBound]) L

/--
At radius one, a concrete two-spike line has at least the two distinct bad
challenges `0` and `1`.
-/
theorem exists_radiusOne_twoSpike_count_certificate :
    ∃ i₀ i₁ : Fin length,
      i₀ ≠ i₁ ∧
        2 ≤
          (parameters.toBlockCode.badChallengeSet 1
            (ReedSolomon.Parameters.twoSpikeLine
              (F := RSField) i₀ i₁)).card := by
  exact parameters.exists_twoSpikeLine_bad_of_degreeBound_add_two_le
    (by norm_num [parameters, degreeBound])
    (by norm_num [parameters, degreeBound, length])

/-- The exact bad-count spectrum has value at least two at radius one. -/
theorem two_le_paperMCABadSpectrum_one :
    2 ≤ parameters.toBlockCode.paperMCABadSpectrum 1 := by
  obtain ⟨i₀, i₁, _hne, hcard⟩ :=
    exists_radiusOne_twoSpike_count_certificate
  exact hcard.trans
    (parameters.toBlockCode.badChallengeSet_card_le_worstBadCount 1
      (ReedSolomon.Parameters.twoSpikeLine (F := RSField) i₀ i₁))

/-- The exact bad-challenge spectrum starts at `B_C(0) = 1`. -/
theorem paperMCABadSpectrum_zero_eq_one :
    parameters.toBlockCode.paperMCABadSpectrum 0 = 1 := by
  exact parameters.worstBadCount_zero_eq_one
    (by norm_num [parameters, degreeBound])
    (by norm_num [parameters, degreeBound, length])

/--
The exact 128-bit MCA threshold for the boundary-field RS code: radius zero is
secure, while radius one already admits an over-budget two-spike line.
-/
theorem pairMCA_exact_128_bit_threshold :
    parameters.toBlockCode.pairMCAGreatestSafe 128 = (0 : WithBot ℕ) ∧
      parameters.toBlockCode.pairMCAFirstUnsafe 128 =
        ((1 : ℕ) : WithTop ℕ) := by
  exact parameters.pairMCAThreshold_zero_of_one_two_field_window
    (by norm_num [parameters, degreeBound])
    (by norm_num [parameters, degreeBound, length]) 128
    one_challenge_128_bit_budget
    two_challenges_exceed_128_bit_budget

end

end BoundaryField
end MCA
end ProximityCoding
