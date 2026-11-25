module

public import HCP.CoupledCVPResidual
public import HCP.CoupledProjectorMetric

@[expose] public section

/-!
# The squared residual and coefficient gap for the same fresh-sign ciphertext

For a fixed public mask, the original canonical ciphertext is the same for
every admitted key. Each operative graph lattice has a different harmonic
center but the same minimum squared residual. Its Gram matrix also gives the
same coefficient penalty about that center. These identities quantify why
even a minimum-distance score cannot select the operative lattice.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.HCP.CoupledSignResidual

open Sheaf CellularSheaf HCPCoupledFamily CoupledCVP
open Protocol.Transfer.PathSignature.NativeSignSampler
open scoped Matrix BigOperators

variable {rows cols : ℕ}

private theorem sum_opening_sq
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (key message : Fin cols → Bool) :
    (∑ r, (opening A key message r : ℝ)^2) = (d : ℝ) * cols := by
  let B : Matrix (Fin rows) (Fin cols) ℝ := fun r c => (presentation A key r c : ℝ)
  let s : Fin cols → ℝ := fun c => (sign (message c) : ℝ)
  have gram : Bᵀ * B = (d : ℝ) • (1 : Matrix (Fin cols) (Fin cols) ℝ) := by
    ext i j
    have entry := presentation_gram_entry A d orthogonal key i j
    change (∑ r, (presentation A key r i : ℝ) * (presentation A key r j : ℝ)) = _
    have castEntry : (∑ r, (presentation A key r i : ℝ) * (presentation A key r j : ℝ)) =
        if i = j then (d : ℝ) else 0 := by exact_mod_cast entry
    rw [castEntry]
    by_cases same : i = j <;> simp [Matrix.smul_apply, same]
  have signSq (c : Fin cols) : s c * s c = 1 := by
    change (sign (message c) : ℝ) * (sign (message c) : ℝ) = 1
    exact_mod_cast sign_mul_self (message c)
  calc
    _ = dotProduct (B.mulVec s) (B.mulVec s) := by
      simp [opening, Matrix.mulVec, dotProduct, pow_two, B, s]
    _ = dotProduct s ((Bᵀ * B).mulVec s) := by
      rw [Matrix.dotProduct_mulVec, ← Matrix.mulVec_transpose, Matrix.mulVec_mulVec, dotProduct_comm]
    _ = _ := by
      rw [gram, Matrix.smul_mulVec, Matrix.one_mulVec, dotProduct_smul]
      simp [dotProduct, signSq]

/-- The scalar residual of the original generated cochain is independent of
both the key and the message at fixed profile parameters. -/
theorem sample_residual_sq
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (key message : Fin cols → Bool) :
    let B := presentation A key
    let b := (HCPCoupledEncoding.sample B (coefficients d message) a (opening A key message)).observed
    ‖(sheaf B).kernelNormalizedDegreeOneLaplacian b‖ ^ 2 =
      (a : ℝ)^2 + (d : ℝ) * (d + 1) * cols := by
  let B := presentation A key
  let z := coefficients d message
  let u := opening A key message
  let b := (HCPCoupledEncoding.sample B z a u).observed
  have residual : ‖(sheaf B).kernelNormalizedDegreeOneLaplacian b‖ ^ 2 =
      CVP.squaredEuclideanDistance b (CVP.latticeVector (graphLattice B) z) := by
    rw [kernelNormalizedDegreeOneLaplacian_apply, cvp_squaredEuclideanDistance_eq_norm_sq]
    change ‖b - (sheaf B).harmonicOneProjection (HCPCoupledEncoding.sample B z a u).observed‖ ^ 2 =
      ‖b - WithLp.toLp 2 (CVP.latticeVector (graphLattice B) z)‖ ^ 2
    rw [HCPCoupledEncoding.sample_projection]
    rw [latticeVector_eq_graphVector]
    rfl
  have sqCoefficient (c : Fin cols) : (z c : ℝ)^2 = (d : ℝ)^2 := by
    have signed : sign (message c) ^ 2 = (1 : ℤ) := by
      simpa only [pow_two] using sign_mul_self (message c)
    change ((d * sign (message c) : ℤ) : ℝ)^2 = (d : ℝ)^2
    rw [← Int.cast_pow, mul_pow, signed, mul_one, Int.cast_pow]
  have informationZero (c : Fin cols) : information b c = 0 := by
    change information (HCPCoupledEncoding.sample B z a u).observed c = 0
    rw [HCPCoupledEncoding.sample_observed_information]
    have openingEq := transposed_opening A d orthogonal key message c
    change (∑ r, B r c * u r) = z c at openingEq
    have openingReal := congrArg (fun value : ℤ => (value : ℝ)) openingEq
    simp only [Int.cast_mul, Int.cast_sum] at openingReal
    rw [openingReal, sub_self]
  have exactCoordinate : exactCoord b = (a : ℝ) :=
    HCPCoupledEncoding.sample_observed_exactCoord B z a u
  have parityDifference (r : Fin rows) :
      parity b r - (∑ c, (B r c : ℝ) * (z c : ℝ)) = (u r : ℝ) := by
    change parity (HCPCoupledEncoding.sample B z a u).observed r - _ = _
    rw [HCPCoupledEncoding.sample_observed_parity, add_sub_cancel_left]
  change ‖(sheaf B).kernelNormalizedDegreeOneLaplacian b‖ ^ 2 = _
  rw [residual, squaredDistance_eq_objective]
  simp only [exactCoordinate, informationZero, zero_sub, neg_sq, sqCoefficient, parityDifference]
  rw [sum_opening_sq A d orthogonal key message]
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  ring

/-- The original CVP objective evaluated on the cochain decoded from the
existing canonical ciphertext for the mask. -/
def fixedMaskCost (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (key masked : Fin cols → Bool) (w : Fin cols → ℤ) : ℝ :=
  CVP.squaredEuclideanDistance
    (Protocol.Storage.CoupledCiphertext.realize (normalObservation A d a masked))
    (CVP.latticeVector (graphLattice (presentation A key)) w)

/-- The original decoded cochain for a fixed mask has this coefficient
objective in every compatible lattice. The center is the actual original
message for the key, and the residual baseline is common to all keys. -/
theorem squaredDistance_fixed_mask
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (key masked : Fin cols → Bool) (w : Fin cols → ℤ) :
    let z := coefficients d (mask key masked)
    fixedMaskCost A d a key masked w =
      (a : ℝ)^2 + (d : ℝ) * (d + 1) * cols +
        (1 + (d : ℝ)) * ∑ c, ((z c : ℝ) - (w c : ℝ))^2 := by
  let B := presentation A key
  let message := mask key masked
  let z := coefficients d message
  let u := opening A key message
  let b := (HCPCoupledEncoding.sample B z a u).observed
  have sameMask : mask key message = masked := by
    funext col
    change (key col == (key col == masked col)) = masked col
    cases key col <;> cases masked col <;> rfl
  have sameCochain : Protocol.Storage.CoupledCiphertext.realize
      (normalObservation A d a masked) = b := by
    rw [← sameMask, ← integerObserved_normal A d a orthogonal key message]
    exact HCPCoupledEncoding.integerObserved_cast_eq_observed B z a u
  change CVP.squaredEuclideanDistance
    (Protocol.Storage.CoupledCiphertext.realize (normalObservation A d a masked))
    (CVP.latticeVector (graphLattice B) w) = _
  rw [sameCochain, squaredDistance_eq_residual_add_gram]
  have residual := sample_residual_sq A d a orthogonal key message
  change ‖(sheaf B).kernelNormalizedDegreeOneLaplacian b‖ ^ 2 = _ at residual
  have projection := HCPCoupledEncoding.sample_projection B z a u
  change (sheaf B).harmonicOneProjection b = graphVector B (fun c => (z c : ℝ)) at projection
  simp only [residual, projection, graphVector_information]
  change _ + dotProduct _ (((graphBasis (presentation A key))ᵀ *
    graphBasis (presentation A key)).mulVec _) = _
  rw [CoupledProjectorMetric.sign_graphBasis_gram A d orthogonal key, Matrix.smul_mulVec,
    Matrix.one_mulVec, dotProduct_smul]
  simp only [dotProduct, smul_eq_mul, pow_two, z, message]

section Gap

variable (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
  (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
  (key masked : Fin cols → Bool)

include orthogonal

/-- The independently selected operative answer for each compatible key
has the same squared cost. -/
theorem cost_at_message :
    fixedMaskCost A d a key masked (coefficients d (mask key masked)) =
      (a : ℝ)^2 + (d : ℝ) * (d + 1) * cols := by
  rw [squaredDistance_fixed_mask A d a orthogonal]
  simp

/-- A single wrong integer coordinate increases the objective by at least
the Gram scalar. -/
theorem cost_gap (positive : 0 < d) {w : Fin cols → ℤ}
    (different : w ≠ coefficients d (mask key masked)) :
    fixedMaskCost A d a key masked (coefficients d (mask key masked)) + (1 + (d : ℝ)) ≤
      fixedMaskCost A d a key masked w := by
  let z := coefficients d (mask key masked)
  obtain ⟨i, hi⟩ := Function.ne_iff.mp different
  have intPositive : 0 < (z i - w i)^2 := sq_pos_of_ne_zero (sub_ne_zero.mpr hi.symm)
  have intOne : 1 ≤ (z i - w i)^2 := by omega
  have realOne : (1 : ℝ) ≤ ((z i : ℝ) - (w i : ℝ))^2 := by exact_mod_cast intOne
  have sumOne := realOne.trans (Finset.single_le_sum
    (f := fun j => ((z j : ℝ) - (w j : ℝ))^2) (fun j _ => sq_nonneg _) (Finset.mem_univ i))
  have scaleNonneg : 0 ≤ 1 + (d : ℝ) := by
    have hd : (0 : ℝ) < d := by exact_mod_cast positive
    positivity
  rw [cost_at_message A d a orthogonal, squaredDistance_fixed_mask A d a orthogonal]
  apply add_le_add le_rfl
  simpa only [mul_one] using mul_le_mul_of_nonneg_left sumOne scaleNonneg

/-- Strict additive slack below the gap still selects the original
message, when the candidate belongs to the supplied lattice. -/
theorem recover_of_cost_lt (positive : 0 < d) {w : Fin cols → ℤ}
    (within : fixedMaskCost A d a key masked w <
      fixedMaskCost A d a key masked (coefficients d (mask key masked)) + (1 + (d : ℝ))) :
    w = coefficients d (mask key masked) := by
  by_contra different
  exact (not_lt_of_ge (cost_gap A d a orthogonal key masked positive different)) within

/-- The bound is attained by changing one coefficient by one. -/
theorem cost_gap_attained (i : Fin cols) :
    ∃ w : Fin cols → ℤ, w ≠ coefficients d (mask key masked) ∧
      fixedMaskCost A d a key masked w =
        fixedMaskCost A d a key masked (coefficients d (mask key masked)) + (1 + (d : ℝ)) := by
  let z := coefficients d (mask key masked)
  let w : Fin cols → ℤ := fun j => if j = i then z j - 1 else z j
  refine ⟨w, ?_, ?_⟩
  · intro equal
    have fixed : w i = z i := congrFun equal i
    simp only [w, ite_eq_left rfl] at fixed
    omega
  · have oneStep : (∑ j, ((z j : ℝ) - (w j : ℝ))^2) = 1 := by
      calc
        _ = ∑ j, if j = i then (1 : ℝ) else 0 := by
          apply Finset.sum_congr rfl
          intro j _
          by_cases same : j = i
          · simp only [w, ite_eq_left same, Int.cast_sub, Int.cast_one, sub_sub_cancel, one_pow]
          · simp [w, same]
        _ = _ := by simp
    rw [cost_at_message A d a orthogonal, squaredDistance_fixed_mask A d a orthogonal, oneStep, mul_one]

end Gap

end HomotopicalEncryption.HCP.CoupledSignResidual
