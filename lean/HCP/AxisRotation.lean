module

public import HCP.AxisFamily
public import Sheaf.Rotation
public import Sheaf.CoefficientRecovery

@[expose] public section

/-!
# Coefficient-preserving rotation of the actual cellular axis family

Coordinate exchange preserves the actual standard integral cochains and sends
each presented harmonic lattice point to the point with the same integer
coefficient. Rotating the weighted left sample therefore changes its observed
coordinates from `(1,2)` to `(2,1)` and preserves coefficient two.

The existing fixed-input right sample at `(1,2)` has coefficient one. It is not
the rotation of the weighted left sample. No recipient-delivery, snapshot,
public-view equality, generation or cryptographic privacy claim is made here.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.HCP.AxisRotation

open Sheaf CellularSheaf Sheaf.HCPAxisFamily

/-- Membership in this actual integral structure is coordinatewise integrality. -/
theorem integralOne_iff (axis : Fin 2) (b : C1) :
    b ∈ (integralStructure axis).integralOneCochains ↔
      ∃ z : Fin 2 → ℤ, ∀ j, b ⟨(), j⟩ = (z j : ℝ) := by
  constructor
  · intro hb
    exact (standardStalkLattice_contains_iff 2
      (component (sheaf axis).edgeDim () b)).mp (hb ())
  · rintro ⟨z, hz⟩ e
    cases e
    exact (standardStalkLattice_contains_iff 2
      (component (sheaf axis).edgeDim () b)).mpr ⟨z, hz⟩

/-- The actual coordinate swap preserves the chosen integral degree-one lattices. -/
def integralAxisSwap :
    IntegralCochainEquiv (integralStructure 0) (integralStructure 1) where
  toIsometricCochainEquiv := axisSwap
  integralOne_iff := by
    intro b
    rw [integralOne_iff 0, integralOne_iff 1]
    constructor
    · rintro ⟨z, hz⟩
      refine ⟨fun j => z (other j), ?_⟩
      intro j
      exact hz (other j)
    · rintro ⟨z, hz⟩
      refine ⟨fun j => z (other j), ?_⟩
      intro j
      have h := hz (other j)
      fin_cases j <;> simpa [axisSwap] using h

/-- The same integer coefficient is used by the two actual lattice presentations. -/
theorem point_naturality (z : Fin 1 → ℤ) :
    axisSwap.degreeOne ((harmonicLatticePresentation 0).point z).1 =
      ((harmonicLatticePresentation 1).point z).1 := by
  change cochainSwap ((harmonicLatticePresentation 0).point z).1 = _
  rw [harmonicLatticePresentation_point, harmonicLatticePresentation_point]
  apply PiLp.ext
  rintro ⟨⟨⟩, j⟩
  fin_cases j <;> simp

/-- Actual sample transport agrees with target encryption at the same coefficients. -/
theorem transport_encrypt_eq_encrypt (z : Fin 1 → ℤ)
    (opening : HodgeNoise (sheaf 0)) :
    integralAxisSwap.transportSample ((harmonicLatticePresentation 0).encrypt z opening) =
      (harmonicLatticePresentation 1).encrypt z (axisSwap.transportNoise opening) := by
  change HodgeEncryptedCochain.mk _ _ = HodgeEncryptedCochain.mk _ _
  congr 1
  apply Subtype.ext
  exact point_naturality z

/-- Every valid source encoding retains its coefficient after actual rotation. -/
theorem decode_rotated_encrypt (z : Fin 1 → ℤ)
    (opening : HodgeNoise (sheaf 0)) :
    (harmonicLatticePresentation 1).decodeCoefficients
        (integralAxisSwap.transportSample
          ((harmonicLatticePresentation 0).encrypt z opening)).observed =
      some z := by
  apply ((harmonicLatticePresentation 1).decodeCoefficients_eq_some_iff _ z).2
  rw [HodgeEncryptedCochain.harmonicOneProjection_observed,
    IntegralCochainEquiv.transportSample_message]
  exact point_naturality z

/-- The actual transported sample, without altering the encoded coefficient. -/
def rotatedWeightedSample : HodgeEncryptedCochain (integralStructure 1) :=
  integralAxisSwap.transportSample (AxisFamily.weightedSample 0)

/-- Rotation moves the full observation together with the presentation. -/
theorem rotatedWeightedSample_observed :
    rotatedWeightedSample.observed = cochainSwap AxisFamily.weightedObserved := by
  rw [rotatedWeightedSample, IntegralCochainEquiv.transportSample_observed,
    AxisFamily.weightedSample_observed]
  rfl

/-- The resulting coordinates are `(2,1)`, rather than the original `(1,2)`. -/
theorem rotatedWeightedSample_coordinates :
    rotatedWeightedSample.observed ⟨(), 0⟩ = 2 ∧
      rotatedWeightedSample.observed ⟨(), 1⟩ = 1 := by
  rw [rotatedWeightedSample_observed]
  norm_num [AxisFamily.weightedObserved]

/-- Target-side harmonic recovery returns the transported coefficient-two point. -/
theorem rotatedWeightedSample_message :
    rotatedWeightedSample.message.1 =
      ((harmonicLatticePresentation 1).point (AxisFamily.weightedCoefficients 0)).1 := by
  rw [rotatedWeightedSample, IntegralCochainEquiv.transportSample_message]
  exact point_naturality (AxisFamily.weightedCoefficients 0)

/-- Direct target-key coefficient recovery returns exactly the original encoding. -/
theorem rotatedWeightedSample_decode :
    (harmonicLatticePresentation 1).decodeCoefficients
        rotatedWeightedSample.observed = some (AxisFamily.weightedCoefficients 0) :=
  decode_rotated_encrypt (AxisFamily.weightedCoefficients 0) (AxisFamily.weightedOpening 0)

/-- Inverse transport lets a recipient retain the source recovery key. -/
theorem rotatedWeightedSample_pullback :
    cochainSwap.symm rotatedWeightedSample.observed =
      (AxisFamily.weightedSample 0).observed := by
  rw [rotatedWeightedSample_observed, AxisFamily.weightedSample_observed]
  exact cochainSwap.symm_apply_apply _

/-- Source-key recovery after inverse transport also returns the same coefficient. -/
theorem rotatedWeightedSample_pullback_decode :
    (harmonicLatticePresentation 0).decodeCoefficients
        (cochainSwap.symm rotatedWeightedSample.observed) =
      some (AxisFamily.weightedCoefficients 0) := by
  rw [rotatedWeightedSample_pullback]
  exact (harmonicLatticePresentation 0).decodeCoefficients_encrypt
    (AxisFamily.weightedCoefficients 0) (AxisFamily.weightedOpening 0)

/-- Authorized rotation preserves coefficient two, on either recovery route. -/
theorem rotatedWeightedSample_coefficient_two :
    (harmonicLatticePresentation 1).decodeCoefficients
        rotatedWeightedSample.observed = some (fun _ : Fin 1 => (2 : ℤ)) ∧
      (harmonicLatticePresentation 0).decodeCoefficients
        (cochainSwap.symm rotatedWeightedSample.observed) =
          some (fun _ : Fin 1 => (2 : ℤ)) := by
  have hz : AxisFamily.weightedCoefficients 0 = fun _ : Fin 1 => (2 : ℤ) := by
    funext j
    exact AxisFamily.weighted_coefficients_values.1
  exact ⟨rotatedWeightedSample_decode.trans (congrArg some hz),
    rotatedWeightedSample_pullback_decode.trans (congrArg some hz)⟩

/-- The separately chosen fixed-input right sample instead encodes coefficient one. -/
theorem fixedWeightedSample_decode_one :
    (harmonicLatticePresentation 1).decodeCoefficients
        (AxisFamily.weightedSample 1).observed = some (fun _ : Fin 1 => (1 : ℤ)) := by
  have hz : AxisFamily.weightedCoefficients 1 = fun _ : Fin 1 => (1 : ℤ) := by
    funext j
    exact AxisFamily.weighted_coefficients_values.2
  exact ((harmonicLatticePresentation 1).decodeCoefficients_encrypt
    (AxisFamily.weightedCoefficients 1) (AxisFamily.weightedOpening 1)).trans
      (congrArg some hz)

/-- Rotation does not produce the coefficient-one sample used at the fixed raw input. -/
theorem rotatedWeightedSample_ne_fixedSample :
    rotatedWeightedSample ≠ AxisFamily.weightedSample 1 := by
  intro heq
  have h := congrArg
    (fun E : HodgeEncryptedCochain (integralStructure 1) => E.observed ⟨(), 0⟩) heq
  rw [rotatedWeightedSample_coordinates.1, AxisFamily.weightedSample_observed] at h
  norm_num [AxisFamily.weightedObserved] at h

end HomotopicalEncryption.HCP.AxisRotation
