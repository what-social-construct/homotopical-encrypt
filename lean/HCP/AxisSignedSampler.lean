module

public import HCP.AxisFamily
public import Mathlib.Probability.ProbabilityMassFunction.Constructions

@[expose] public section

/-!
# A finite signed-axis Hodge sampling check

This two-key, two-message calculation reuses the actual cellular axis sheaves,
their integral harmonic lattices, and `HarmonicLatticePresentation.encrypt`.
An independently uniform axis is chosen for one sample. With the specified
coexact opening, the two message choices induce the same distribution on the
real cochain observation and the common homological public class.

This is a finite, single-use semantic check. It does not include a storage
payload, snapshot root, ciphertext bytes, transfer view, encryption oracle,
key reuse, efficient algorithms, or an asymptotic hardness assertion.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.HCP.AxisSignedSampler

open Sheaf CellularSheaf Sheaf.HCPAxisFamily
open scoped CochainComplex.Plus.modelCategoryQuillen ENNReal

/-- The two semantic plaintext coefficients are `+1` and `-1`. -/
def coefficient (message : Bool) : ℤ := if message then 1 else -1

/-- A coexact opening with the opposite sign from the harmonic coefficient. -/
def noise (axis : Fin 2) (message : Bool) : HodgeNoise (sheaf axis) where
  exactOpening := 0
  coexactOpening := (-(coefficient message : ℝ)) • (opening axis).coexactOpening

theorem noise_value (axis : Fin 2) (message : Bool) :
    (noise axis message).value =
      (-(coefficient message : ℝ)) • unitCochain axis := by
  change (sheaf axis).delta0 0 +
    (sheaf axis).delta1.adjoint
      ((-(coefficient message : ℝ)) • (opening axis).coexactOpening) = _
  rw [map_zero, zero_add, map_smul]
  exact congrArg ((-(coefficient message : ℝ)) • ·) (opening_coexactComponent axis)

/-- The original harmonic-lattice encryptor, with a signed integral message. -/
def sample (axis : Fin 2) (message : Bool) :
    HodgeEncryptedCochain (integralStructure axis) :=
  (harmonicLatticePresentation axis).encrypt
    (fun _ : Fin 1 => coefficient message) (noise axis message)

theorem sample_observed (axis : Fin 2) (message : Bool) :
    (sample axis message).observed =
      (coefficient message : ℝ) • unitCochain (other axis) +
        (-(coefficient message : ℝ)) • unitCochain axis := by
  change ((harmonicLatticePresentation axis).point
      (fun _ : Fin 1 => coefficient message)).1 + (noise axis message).value = _
  rw [harmonicLatticePresentation_point, noise_value]

/-- Both samples retain the same public homological class. -/
theorem class_eq :
    HCP.AxisFamily.realization.classifier.π (0 : Fin 2) =
      HCP.AxisFamily.realization.classifier.π (1 : Fin 2) :=
  HCP.AxisFamily.same_public_class

/-- With one signed coefficient, the two axes exchange the raw observations. -/
theorem observed_true_zero_eq_false_one :
    (sample 0 true).observed = (sample 1 false).observed := by
  rw [sample_observed, sample_observed]
  simp [coefficient, other_zero, other_one, add_comm]

theorem observed_true_one_eq_false_zero :
    (sample 1 true).observed = (sample 0 false).observed := by
  rw [sample_observed, sample_observed]
  simp [coefficient, other_zero, other_one, add_comm]

/-- One fresh axis is selected with probability one half at each value. -/
def uniformAxis : PMF (Fin 2) :=
  PMF.ofFintype (fun _ => (1 / 2 : ENNReal)) (by
    simpa only [Fin.sum_univ_two, one_div, ← two_mul] using
      (ENNReal.mul_inv_cancel (by norm_num : (2 : ENNReal) ≠ 0)
        (by norm_num : (2 : ENNReal) ≠ ⊤)))

/-- The selected observation consists only of the public class and raw cochain. -/
def observation (axis : Fin 2) (message : Bool) : Set ℤ × C1 :=
  (HCP.AxisFamily.realization.classifier.π axis, (sample axis message).observed)

/-- The two finite distributions of the selected semantic observation. -/
def observationDistribution (message : Bool) : PMF (Set ℤ × C1) :=
  uniformAxis.map (fun axis => observation axis message)

theorem observation_true_zero_eq_false_one :
    observation 0 true = observation 1 false := by
  apply Prod.ext
  · exact class_eq
  · exact observed_true_zero_eq_false_one

theorem observation_true_one_eq_false_zero :
    observation 1 true = observation 0 false := by
  apply Prod.ext
  · exact class_eq.symm
  · exact observed_true_one_eq_false_zero

/-- The signed messages have the same one-sample law under the uniform key. -/
theorem observationDistribution_eq :
    observationDistribution true = observationDistribution false := by
  ext value
  simp only [observationDistribution, PMF.map_apply]
  simp only [tsum_fintype, Fin.sum_univ_two, uniformAxis, PMF.ofFintype_apply]
  rw [observation_true_zero_eq_false_one, observation_true_one_eq_false_zero]
  exact add_comm _ _

end HomotopicalEncryption.HCP.AxisSignedSampler
