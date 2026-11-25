module

public import HCP.FiniteRecovery
public import HCP.CoupledRecoverySeparation
public import HCP.CoupledSignResidual

@[expose] public section

/-!
# Optimal recovery with deterministic disclosure on a fixed native ciphertext

The original ciphertext identifies one compatible message for each sign key.
Conditioning the uniform key/message experiment on a fixed mask thus keeps an
equal weight for each key. A decoder sees the actual ciphertext and an
additional deterministic view of the key. Its optimal success is the number
of distinct extra views divided by the number of keys, since the original
coefficient target is injective on this fiber. The equal minimum squared CVP
cost does not refine the view. This is a finite conditioned counting result;
the separate nonce-bearing random-oracle experiment has its own bound.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.HCP.FiniteRecovery.Native

open CoupledRecoverySeparation CoupledSignResidual
open Protocol.Transfer.PathSignature.NativeSignSampler

variable {rows cols bits : ℕ} {View : Type*}

/-- The actual ciphertext fiber of the original key/message experiment has
one pair per key. This accounts for the uniform weights after conditioning. -/
def fixedMaskFiberEquiv
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) (positive : 0 < d)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (masked : Fin cols → Bool) :
    (Fin cols → Bool) ≃
      {x : (Fin cols → Bool) × (Fin cols → Bool) //
        ciphertextBytes A d a x.1 x.2 = normalBytes A d a masked} where
  toFun key := ⟨(key, mask key masked),
    (ciphertextBytes_eq_normalBytes_iff A d a positive orthogonal key _ masked).2 rfl⟩
  invFun sample := sample.val.1
  left_inv _ := rfl
  right_inv sample := Subtype.ext (Prod.ext rfl
    ((ciphertextBytes_eq_normalBytes_iff A d a positive orthogonal
      sample.val.1 sample.val.2 masked).1 sample.property).symm)

/-- Keep the emitted bytes, with the specified additional data for the same
key in the conditioned experiment. -/
def viewForMask
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) (masked : Fin cols → Bool)
    (disclose : (Fin cols → Bool) → View) (key : Fin cols → Bool) : List UInt8 × View :=
  (ciphertextBytes A d a key (mask key masked), disclose key)

/-- The counting probability is the mass of the exact success event under
the existing uniform native key sampler. -/
theorem uniformKey_success_eq
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) (masked : Fin cols → Bool)
    (disclose : (Fin cols → Bool) → View) (decoder : List UInt8 × View → (Fin cols → ℤ)) :
    ((uniformKey cols).toOuterMeasure
      {key | decoder (viewForMask A d a masked disclose key) =
        coefficients d (mask key masked)}).toReal =
      successProbability (viewForMask A d a masked disclose)
        (fun key => coefficients d (mask key masked)) decoder := by
  classical
  let good : Finset (Fin cols → Bool) := Finset.univ.filter fun key =>
    decoder (viewForMask A d a masked disclose key) = coefficients d (mask key masked)
  have event : {key | decoder (viewForMask A d a masked disclose key) =
      coefficients d (mask key masked)} = (good : Set (Fin cols → Bool)) := by
    ext key
    simp [good]
  rw [event, PMF.toOuterMeasure_apply_finset]
  simp only [uniformKey_apply, Finset.sum_const, nsmul_eq_mul, ENNReal.toReal_mul,
    ENNReal.toReal_inv, ENNReal.toReal_natCast, successProbability, successCount, good,
    div_eq_mul_inv]

private theorem disclosedViews_comp_card {Hidden Input Output : Type*} [Fintype Hidden]
    (view : Hidden → Input) (encode : Input ↪ Output) :
    (disclosedViews (encode ∘ view)).card = (disclosedViews view).card := by
  classical
  have mapped : disclosedViews (encode ∘ view) = (disclosedViews view).map encode := by
    ext value
    simp only [disclosedViews, Finset.mem_image, Finset.mem_univ, true_and, Finset.mem_map,
      Function.comp_apply]
    constructor
    · rintro ⟨hidden, rfl⟩
      exact ⟨view hidden, ⟨hidden, rfl⟩, rfl⟩
    · rintro ⟨_, ⟨hidden, rfl⟩, rfl⟩
      exact ⟨hidden, rfl⟩
  rw [mapped, Finset.card_map]

/-- The exact best success for the original integral coefficients, using the
emitted ciphertext plus any deterministic disclosure on this fixed fiber. -/
theorem optimalProbability_eq_view_count
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) (positive : 0 < d)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (masked : Fin cols → Bool) (disclose : (Fin cols → Bool) → View) :
    optimalProbability (viewForMask A d a masked disclose)
        (fun key => coefficients d (mask key masked)) =
      ((disclosedViews disclose).card : ℝ) / (2 : ℝ)^cols := by
  have targetInjective : Function.Injective (fun key => coefficients d (mask key masked)) :=
    (coefficients_injective d positive).comp (maskEquiv masked).injective
  let tag : View ↪ List UInt8 × View :=
    ⟨fun value => (normalBytes A d a masked, value), fun _ _ equal => congrArg Prod.snd equal⟩
  have viewEq : viewForMask A d a masked disclose = tag ∘ disclose := by
    funext key
    have bytesEq := (ciphertextBytes_eq_normalBytes_iff A d a positive orthogonal key
      (mask key masked) masked).2 rfl
    exact Prod.ext bytesEq rfl
  rw [optimalProbability, optimalCount_eq_card_image_of_injective _ _ targetInjective,
    viewEq, disclosedViews_comp_card]
  simp

/-- Any deterministic fixed-fiber disclosure of `bits` Boolean coordinates
gives at most the ratio of the two key-space sizes. If it is onto, the
bound is sharp. -/
theorem optimalProbability_le_bit_budget
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) (positive : 0 < d)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (masked : Fin cols → Bool) (disclose : (Fin cols → Bool) → (Fin bits → Bool)) :
    optimalProbability (viewForMask A d a masked disclose)
        (fun key => coefficients d (mask key masked)) ≤
      (2 : ℝ)^bits / (2 : ℝ)^cols := by
  rw [optimalProbability_eq_view_count A d a positive orthogonal]
  apply div_le_div_of_nonneg_right _ (by positivity)
  have cardBound := Finset.card_le_univ (disclosedViews disclose)
  have cardSize : Fintype.card (Fin bits → Bool) = 2^bits := by simp
  rw [cardSize] at cardBound
  exact_mod_cast cardBound

/-- Disclosing the signs on fixed, distinct positions attains the bit bound. -/
theorem optimalProbability_eq_coordinate_disclosure
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) (positive : 0 < d)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (masked : Fin cols → Bool) (positions : Fin bits ↪ Fin cols) :
    optimalProbability (viewForMask A d a masked (fun key i => key (positions i)))
        (fun key => coefficients d (mask key masked)) =
      (2 : ℝ)^bits / (2 : ℝ)^cols := by
  classical
  rw [optimalProbability_eq_view_count A d a positive orthogonal]
  have onto : Function.Surjective (fun (key : Fin cols → Bool) i => key (positions i)) := by
    intro report
    refine ⟨Function.extend positions report (fun _ => false), ?_⟩
    funext i
    exact positions.injective.extend_apply report (fun _ => false) i
  have allViews : disclosedViews (fun (key : Fin cols → Bool) i => key (positions i)) =
      (Finset.univ : Finset (Fin bits → Bool)) := by
    ext report
    rw [mem_disclosedViews]
    exact iff_of_true (onto report) (Finset.mem_univ _)
  rw [allViews]
  simp

/-- Appending the actual minimum squared CVP cost to any existing
deterministic disclosure does not change its exact recovery probability. -/
theorem optimalProbability_add_minimum_cost
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) (positive : 0 < d)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (masked : Fin cols → Bool) (disclose : (Fin cols → Bool) → View) :
    optimalProbability (viewForMask A d a masked (fun key =>
        (disclose key, fixedMaskCost A d a key masked (coefficients d (mask key masked)))))
        (fun key => coefficients d (mask key masked)) =
      optimalProbability (viewForMask A d a masked disclose)
        (fun key => coefficients d (mask key masked)) := by
  rw [optimalProbability_eq_view_count A d a positive orthogonal,
    optimalProbability_eq_view_count A d a positive orthogonal]
  let addCost : View ↪ View × ℝ :=
    ⟨fun value => (value, (a : ℝ)^2 + (d : ℝ) * (d + 1) * cols),
      fun _ _ equal => congrArg Prod.fst equal⟩
  have sameCost : (fun key => (disclose key,
      fixedMaskCost A d a key masked (coefficients d (mask key masked)))) = addCost ∘ disclose := by
    funext key
    exact Prod.ext rfl (cost_at_message A d a orthogonal key masked)
  rw [sameCost, disclosedViews_comp_card]

end HomotopicalEncryption.HCP.FiniteRecovery.Native
