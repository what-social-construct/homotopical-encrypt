module

public import Proximity.Capacity.AgreementPacking
public import Proximity.ListDecoding.PhaseSplit
public import Mathlib.FieldTheory.Finite.Basic
public import Mathlib.GroupTheory.OrderOfElement
public meta import Mathlib.Tactic.ReduceModChar

@[expose] public section

/-!
# Exact list thresholds on Jo's length-64 smooth domains

The prime fields and Proth witnesses are from Table 3 of Sunghyeon Jo,
*Reed–Solomon Mutual Correlated Agreement Beyond the Johnson Radius*,
IACR ePrint 2026/1432. We check primality and construct the order-64 domains.
The list thresholds are for those fields and codes, at every positive
interleaving width.
-/

set_option autoImplicit false

namespace ProximityCoding.Capacity.JoThresholds

open BlockCode CapacityList

noncomputable section

/-- The four length-64 rows in Jo's Table 2. -/
inductive Profile
  | half
  | quarter
  | eighth
  | sixteenth

namespace Profile

/-- Dimension of the length-64 Reed–Solomon code. -/
def dimension : Profile → ℕ
  | half => 32
  | quarter => 16
  | eighth => 8
  | sixteenth => 4

/-- Largest safe interleaved list-error count at a fractional target of `2^-128`. -/
def lastSafeCount : Profile → ℕ
  | half => 31
  | quarter => 48
  | eighth => 56
  | sixteenth => 60

/-- The prime field sizes, evaluated from the Proth forms in Jo's Table 3. -/
def modulus : Profile → ℕ
  | half => 98079714615416886934934207449906595152216555806168973313
  | quarter => 191561942608236107294793240363474267632441739020599297
  | eighth => 2923003274661805836407294712031749932303033303041
  | sixteenth => 1427247692705959881046158932321485887473975297

private def oddFactor : Profile → ℕ
  | half => 2 ^ 93 - 231
  | quarter => 2 ^ 88 - 223
  | eighth => 2 ^ 80 - 31
  | sixteenth => 2 ^ 75 - 321

private def halfExponent : Profile → ℕ
  | half => 92
  | quarter => 88
  | eighth => 80
  | sixteenth => 74

/-- The Proth witness in the corresponding row of Jo's Table 3. -/
def witness : Profile → ℕ
  | half => 3
  | quarter => 5
  | eighth => 11
  | sixteenth => 3

theorem modulus_lt_two_pow_256 (p : Profile) : p.modulus < 2 ^ 256 := by
  cases p <;> norm_num [modulus]

private theorem modulus_sub_one_dvd (p : Profile) : 64 ∣ p.modulus - 1 := by
  cases p <;> norm_num [modulus]

set_option maxRecDepth 2048 in
set_option maxHeartbeats 1000000 in
private theorem witness_pow_half (p : Profile) :
    (p.witness : ZMod p.modulus) ^ ((p.modulus - 1) / 2) = -1 := by
  cases p
  · have hmod : (3 : ZMod 98079714615416886934934207449906595152216555806168973313) ^
        (9903520314283042199192993561 * 4951760157141521099596496896 : ℕ) = -1 := by
      rw [pow_mul]
      have h : (3 : ZMod 98079714615416886934934207449906595152216555806168973313) ^
          9903520314283042199192993561 = 14071152260179533710363792330626249496120155652934278901 := by
        reduce_mod_char
      rw [h]
      reduce_mod_char
    rw [show (Profile.half.modulus - 1) / 2 =
      9903520314283042199192993561 * (4951760157141521099596496896 : ℕ) by norm_num [modulus]]
    exact hmod
  · have hmod : (5 : ZMod 191561942608236107294793240363474267632441739020599297) ^
        (309485009821345068724780833 * 309485009821345068724781056 : ℕ) = -1 := by
      rw [pow_mul]
      have h : (5 : ZMod 191561942608236107294793240363474267632441739020599297) ^
          309485009821345068724780833 = 109879716836452097180281718539534716997240252018963551 := by
        reduce_mod_char
      rw [h]
      reduce_mod_char
    rw [show (Profile.quarter.modulus - 1) / 2 =
      309485009821345068724780833 * (309485009821345068724781056 : ℕ) by norm_num [modulus]]
    exact hmod
  · change (11 : ZMod 2923003274661805836407294712031749932303033303041) ^
      (1208925819614629174706145 * 1208925819614629174706176) = -1
    rw [pow_mul]
    have h : (11 : ZMod 2923003274661805836407294712031749932303033303041) ^ 1208925819614629174706145 =
        530445368685032799318995619975445355692223122284 := by reduce_mod_char
    rw [h]
    reduce_mod_char
  · change (3 : ZMod 1427247692705959881046158932321485887473975297) ^
      (37778931862957161709247 * 18889465931478580854784) = -1
    rw [pow_mul]
    have h : (3 : ZMod 1427247692705959881046158932321485887473975297) ^ 37778931862957161709247 =
        1277999098863434116396638755826764882154067767 := by reduce_mod_char
    rw [h]
    reduce_mod_char

end Profile

private theorem prime_of_two_power_root {q s : ℕ} (hq : 2 ≤ q) (hodd : q % 2 = 1)
    (hsize : q < (2 ^ (s + 1)) ^ 2) (a : ZMod q) (ha : a ^ 2 ^ s = -1) : q.Prime := by
  by_contra hcomp
  let p := q.minFac
  have hp : p.Prime := Nat.minFac_prime (by omega)
  have : Fact p.Prime := ⟨hp⟩
  have hp_dvd : p ∣ q := Nat.minFac_dvd q
  have hp_ne_two : p ≠ 2 := by
    intro hp2
    rw [hp2] at hp_dvd
    have hmod := Nat.dvd_iff_mod_eq_zero.mp hp_dvd
    omega
  let a' := ZMod.castHom hp_dvd (ZMod p) a
  have ha' : a' ^ 2 ^ s = -1 := by
    simpa only [a', map_pow, map_neg, map_one] using
      congrArg (ZMod.castHom hp_dvd (ZMod p)) ha
  have hnot : a' ^ 2 ^ s ≠ 1 := by
    rw [ha']
    intro h
    rcases ZMod.neg_one_eq_one_iff.mp h with hp1 | hp2
    · exact hp.ne_one hp1
    · exact hp_ne_two hp2
  have hpow : a' ^ 2 ^ (s + 1) = 1 := by
    rw [pow_succ, pow_mul, ha']
    norm_num
  have ha'ne : a' ≠ 0 := by
    intro h
    rw [h, zero_pow (by positivity)] at hpow
    exact zero_ne_one hpow
  have : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  have horder : orderOf a' = 2 ^ (s + 1) := orderOf_eq_prime_pow hnot hpow
  have hdiv : 2 ^ (s + 1) ∣ p - 1 := by
    rw [← horder]
    exact orderOf_dvd_of_pow_eq_one (ZMod.pow_card_sub_one_eq_one ha'ne)
  have hp_pos : 0 < p - 1 := by have := hp.two_le; omega
  have hle : 2 ^ (s + 1) ≤ p := (Nat.le_of_dvd hp_pos hdiv).trans (Nat.sub_le _ _)
  exact (not_lt_of_ge ((Nat.pow_le_pow_left hle 2).trans
    (Nat.minFac_sq_le_self (by omega) hcomp))) hsize

/-- Each modulus is prime by its Proth witness. -/
theorem Profile.modulus_prime (p : Profile) : p.modulus.Prime := by
  have hdiv : (p.modulus - 1) / 2 = p.oddFactor * 2 ^ p.halfExponent := by
    cases p <;> norm_num [Profile.modulus, Profile.oddFactor, Profile.halfExponent]
  apply prime_of_two_power_root (s := p.halfExponent) (a :=
    (p.witness : ZMod p.modulus) ^ p.oddFactor)
  · cases p <;> norm_num [Profile.modulus]
  · cases p <;> norm_num [Profile.modulus]
  · cases p <;> norm_num [Profile.modulus, Profile.halfExponent]
  · rw [← pow_mul, ← hdiv]
    exact p.witness_pow_half

/-- The actual finite field for a published row. -/
abbrev RSField (p : Profile) := ZMod p.modulus

instance modulusPrimeFact (p : Profile) : Fact p.modulus.Prime := ⟨p.modulus_prime⟩

@[simp] theorem card_RSField (p : Profile) : Fintype.card (RSField p) = p.modulus :=
  ZMod.card p.modulus

/-- The field element obtained by descending the Proth witness to order 64. -/
def root (p : Profile) : RSField p :=
  (p.witness : RSField p) ^ ((p.modulus - 1) / 64)

private theorem root_pow_32 (p : Profile) : root p ^ 32 = -1 := by
  unfold root
  rw [← pow_mul, show (p.modulus - 1) / 64 * 32 = (p.modulus - 1) / 2 by
    cases p <;> norm_num [Profile.modulus]]
  exact p.witness_pow_half

private theorem root_pow_64 (p : Profile) : root p ^ 64 = 1 := by
  rw [show (64 : ℕ) = 32 * 2 by rfl, pow_mul, root_pow_32]
  norm_num

/-- The generator of the smooth evaluation subgroup, obtained from the Proth witness. -/
def rootUnit (p : Profile) : (RSField p)ˣ :=
  Units.mkOfMulEqOne (root p) (root p ^ 63) (by
    rw [← pow_succ']
    exact root_pow_64 p)

theorem rootUnit_order (p : Profile) : orderOf (rootUnit p) = 64 := by
  have : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  apply orderOf_eq_prime_pow (p := 2) (n := 5)
  · intro h
    have hh : root p ^ 32 = 1 := by
      simpa [rootUnit] using congrArg ((↑) : (RSField p)ˣ → RSField p) h
    rw [root_pow_32] at hh
    have hz : p.modulus = 1 ∨ p.modulus = 2 := ZMod.neg_one_eq_one_iff.mp hh
    cases p <;> norm_num [Profile.modulus] at hz
  · ext
    simpa [rootUnit] using root_pow_64 p

/-- The length-64 multiplicative subgroup, indexed by the powers of its root. -/
def evaluationDomain (p : Profile) : ReedSolomon.EvaluationDomain (RSField p) (Fin 64) where
  point i := (↑(rootUnit p ^ (i : ℕ)) : RSField p)
  injective_point := by
    intro i j hij
    have hpowers : rootUnit p ^ (i : ℕ) = rootUnit p ^ (j : ℕ) := Units.ext hij
    have heq := (pow_eq_pow_iff_modEq.mp hpowers)
    rw [rootUnit_order] at heq
    exact Fin.ext (by
      unfold Nat.ModEq at heq
      simpa [Nat.mod_eq_of_lt i.isLt, Nat.mod_eq_of_lt j.isLt] using heq)

/-- The same domain with the smoothness condition recorded explicitly. -/
def smoothEvaluationDomain (p : Profile) :
    ReedSolomon.SmoothEvaluationDomain (RSField p) (Fin 64) where
  toEvaluationDomain := evaluationDomain p
  smooth := 64 ∣ p.modulus - 1

theorem smoothEvaluationDomain_smooth (p : Profile) : (smoothEvaluationDomain p).smooth :=
  p.modulus_sub_one_dvd

/-- Jo's parameters over the supported subgroup. -/
def parameters (p : Profile) : ReedSolomon.Parameters (RSField p) (Fin 64) where
  domain := evaluationDomain p
  degreeBound := p.dimension

variable (p : Profile) (σ : Type*) [Fintype σ] [Nonempty σ]

/-- The 128-bit fractional list-size predicate on a count radius. -/
def listTarget (r : ℕ) : Prop :=
  FractionalListSizeBoundAt ((parameters p).vectorBlockCode σ)
    (relativeRadius (ι := Fin 64) r) ((1 : ℝ) / 2 ^ 128) (Fintype.card (RSField p))

private theorem gapBelowPackingBound :
    Nat.choose 64 p.dimension <
      (p.modulus / 2 ^ 128 + 1) * Nat.choose (64 - p.lastSafeCount) p.dimension := by
  cases p <;> simp only [Profile.dimension, Profile.modulus, Profile.lastSafeCount,
    Nat.choose_eq_descFactorial_div_factorial] <;> decide

omit [Nonempty σ] in
private theorem listTarget_lastSafeCount : listTarget p σ p.lastSafeCount := by
  intro w
  rw [((parameters p).vectorBlockCode σ).ballCardAt_relativeRadius_eq_ballCard
    (by norm_num) w]
  have hpack := (parameters p).vectorListSizeBound_mul_choose_agreement_le
    σ p.lastSafeCount w
  simp only [Fintype.card_fin, parameters] at hpack
  have hball : ((parameters p).vectorBlockCode σ).ballCard p.lastSafeCount w ≤
      p.modulus / 2 ^ 128 := by
    by_contra h
    have hsmall : p.modulus / 2 ^ 128 + 1 ≤
        ((parameters p).vectorBlockCode σ).ballCard p.lastSafeCount w := by omega
    exact (not_le_of_gt (gapBelowPackingBound p))
      ((Nat.mul_le_mul_right _ hsmall).trans hpack)
  have hbudget : ((p.modulus / 2 ^ 128 : ℕ) : ℝ) ≤
      ((1 : ℝ) / 2 ^ 128) * Fintype.card (RSField p) := by
    rw [card_RSField, div_mul_eq_mul_div, one_mul]
    apply (le_div_iff₀ (by positivity : (0 : ℝ) < 2 ^ 128)).mpr
    exact_mod_cast Nat.div_mul_le_self p.modulus (2 ^ 128)
  exact (show (((parameters p).vectorBlockCode σ).ballCard p.lastSafeCount w : ℝ) ≤
    ((p.modulus / 2 ^ 128 : ℕ) : ℝ) by exact_mod_cast hball).trans hbudget

private theorem not_listTarget_half_at_capacity : ¬ listTarget Profile.half σ 32 := by
  classical
  intro h
  have hthreshold := ((parameters Profile.half).vectorFractionalListSizeBoundAt_capacityGrid_iff
    (Classical.arbitrary σ) ((1 : ℝ) / 2 ^ 128) (by decide) (by norm_num)
    (by simp [parameters, Profile.dimension])).mp (by
      simpa [listTarget, parameters, Profile.dimension] using h)
  have hnum : Profile.half.modulus < Nat.choose 64 32 * 2 ^ 128 := by
    rw [Nat.choose_eq_descFactorial_div_factorial]
    decide
  have hstrict : ((1 : ℝ) / 2 ^ 128) * Fintype.card (RSField Profile.half) <
      (Nat.choose 64 32 : ℝ) := by
    rw [card_RSField, div_mul_eq_mul_div, one_mul]
    apply (div_lt_iff₀ (by positivity : (0 : ℝ) < 2 ^ 128)).mpr
    exact_mod_cast hnum
  exact (not_le_of_gt hstrict) (by simpa [parameters, Profile.dimension] using hthreshold)

private theorem not_listTarget_nextShell : ¬ listTarget p σ (64 - p.dimension + 1) := by
  have hDimension : 0 < (parameters p).degreeBound := by cases p <;> decide
  have hLe : (parameters p).degreeBound ≤ Fintype.card (Fin 64) := by
    rw [Fintype.card_fin]
    cases p <;> decide
  simpa only [listTarget, Fintype.card_fin, parameters] using
    (parameters p).not_vectorFractionalListSizeBoundAt_nextShell
      (σ := σ) (ε := ((1 : ℝ) / 2 ^ 128)) (by norm_num) hDimension (by norm_num) hLe

private theorem not_listTarget_succ_lastSafeCount : ¬ listTarget p σ (p.lastSafeCount + 1) := by
  cases p with
  | half => exact not_listTarget_half_at_capacity σ
  | quarter => exact not_listTarget_nextShell Profile.quarter σ
  | eighth => exact not_listTarget_nextShell Profile.eighth σ
  | sixteenth => exact not_listTarget_nextShell Profile.sixteenth σ

omit [Nonempty σ] in
private theorem listTarget_antitone : Antitone (listTarget p σ) := by
  classical
  intro r s hrs
  exact fractionalListSizeBoundAt_antitone _ _ _ (relativeRadius_mono hrs)

/-- At every positive width the target holds exactly through the listed count. -/
theorem listTarget_iff (r : ℕ) : listTarget p σ r ↔ r ≤ p.lastSafeCount := by
  refine ⟨fun h => ?_, fun hr => listTarget_antitone p σ hr (listTarget_lastSafeCount p σ)⟩
  by_contra hle
  exact not_listTarget_succ_lastSafeCount p σ (listTarget_antitone p σ (by omega) h)

/-- Both endpoints on the Hamming grid for the actual length-64 code. -/
theorem listGridThreshold :
    FiniteThreshold.greatestSafe 64 (listTarget p σ) = (p.lastSafeCount : WithBot ℕ) ∧
    FiniteThreshold.firstUnsafe 64 (listTarget p σ) =
      ((p.lastSafeCount + 1 : ℕ) : WithTop ℕ) := by
  have hlt : p.lastSafeCount < 64 := by cases p <;> decide
  exact ⟨FiniteThreshold.greatestSafe_eq_of_antitone hlt.le (listTarget_antitone p σ)
    (listTarget_lastSafeCount p σ) (not_listTarget_succ_lastSafeCount p σ),
    FiniteThreshold.firstUnsafe_eq_of_antitone hlt (listTarget_antitone p σ)
      (listTarget_lastSafeCount p σ) (not_listTarget_succ_lastSafeCount p σ)⟩

/-- The real safe set excludes the normalized first unsafe count. -/
theorem listSafeRelativeRadii_eq_Ico :
    safeRelativeRadii ((parameters p).vectorBlockCode σ) ((1 : ℝ) / 2 ^ 128)
        (Fintype.card (RSField p)) =
      Set.Ico 0 (relativeRadius (ι := Fin 64) (p.lastSafeCount + 1)) := by
  classical
  let C := (parameters p).vectorBlockCode σ
  have hlength : 0 < Fintype.card (Fin 64) := by norm_num
  ext δ
  constructor
  · rintro ⟨hδ, hsafe⟩
    refine ⟨hδ, ?_⟩
    by_contra hcut
    exact not_listTarget_succ_lastSafeCount p σ
      (fractionalListSizeBoundAt_antitone C _ _ (le_of_not_gt hcut) hsafe)
  · rintro ⟨hδ, hcut⟩
    refine ⟨hδ, fun w => ?_⟩
    have hsafe := (listTarget_lastSafeCount p σ) w
    rw [C.ballCardAt_relativeRadius_eq_ballCard hlength w] at hsafe
    calc
      (C.ballCardAt δ w : ℝ) ≤ C.ballCard p.lastSafeCount w := by
        exact_mod_cast C.ballCardAt_le_ballCard_of_lt_succ hlength hcut w
      _ ≤ ((1 : ℝ) / 2 ^ 128) * Fintype.card (RSField p) := hsafe

end

end ProximityCoding.Capacity.JoThresholds
