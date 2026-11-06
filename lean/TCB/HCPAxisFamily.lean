module

public import HCP.AxisFamily
public import TCB.HCPRealization
public import Gates.Spectral

@[expose] public section

/-!
# The cellular HCP family at the existing artifact boundary

The mathematical example uses the existing public input `(class, b)`.
This module connects its actual operator to the generic cellular alignment
and can retain an existing artifact in a bound sample when the application
supplies the original acceptance, decoding and envelope-binding proofs.
It chooses no hashes, snapshot roots, public proof bytes or hiding profile.

Paper 1 owns the mathematical example and its precise observation interface.
Paper 2 owns the public payload/selective-opening view and any concrete
storage, rotation and key-delivery realization of these supplied contracts.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt.TCB.HCPAxisFamily

open Sheaf CellularSheaf Sheaf.HCPAxisFamily
open HCPRealization
open scoped CochainComplex.Plus.modelCategoryQuillen

/-- The concrete family instantiates the common actual-operator alignment. -/
def operatorAlignment (axis : Fin 2) :
    CellularOperatorAlignment (sheaf axis) HCP.AxisFamily.realization where
  representative := axis
  operatorAction := HCP.AxisFamily.operatorAction axis

/-- The gate scalar is the actual computed positive spectral gap of this
cellular operator. -/
theorem actualSpectralGate (axis : Fin 2) :
    Gates.SpectralGapGate (sInf {μ : ℝ | 0 < μ ∧
      Module.End.HasEigenvalue (sheaf axis).degreeOneLaplacian μ}) := by
  rw [positiveSpectralGap_eq_one]
  unfold Gates.SpectralGapGate Axioms.SpectralGapInPoVBounds
    Axioms.povSpectralLower Axioms.povSpectralUpper
  have hsq := Real.sq_sqrt (show (0 : ℝ) ≤ 2 by norm_num)
  have hnonneg := Real.sqrt_nonneg (2 : ℝ)
  constructor <;> nlinarith

variable {axis : Fin 2}
  {payload : CochainPayloadInterpretation (sheaf axis)}
  {Lifecycle : Type}
  {classify : SheafStateSnapshot (sheaf axis) → Set ℤ}
  {Binds : HCPStackBinding Lifecycle (Set ℤ) C1}

/-- The selected snapshot classifier must agree with the actual homological
theory. This is an application join, not an equality inferred from a root. -/
def observationAlignment
    (O : BoundHCPObservation (integralStructure axis) payload
      (Set ℤ) Lifecycle classify Binds)
    (classifier_eq : HCP.AxisFamily.theory axis = classify payload.snapshot) :
    BoundObservationAlignment O HCP.AxisFamily.realization where
  toCellularOperatorAlignment := operatorAlignment axis
  classifier_eq := classifier_eq

/-- Bind the actual structured-noise sample to the original supplied artifact.
All hash, snapshot, decoder and context contracts remain explicit inputs. -/
def bindSample
    (context : Lifecycle) (artifact : HashedCommittedCochain)
    (accepted : AcceptedCommittedOneCochain payload artifact.cochain)
    (artifact_binding : artifact.Binds)
    (decoded_zero : payload.decode artifact.cochain = 0)
    (observation_binding : Binds context (classify payload.snapshot) observed
      artifact.cochain artifact.digest payload.snapshot.root) :
    BoundHCPObservation (integralStructure axis) payload
      (Set ℤ) Lifecycle classify Binds where
  context := context
  encrypted := sample axis
  artifact := artifact
  acceptedExact := accepted
  artifactBinding := artifact_binding
  decodedExactComponent := by
    rw [sample_exactComponent]
    exact decoded_zero
  bindsObservation := by
    rw [sample_observed]
    exact observation_binding

@[simp]
theorem bindSample_artifact
    (context : Lifecycle) (artifact : HashedCommittedCochain)
    (accepted : AcceptedCommittedOneCochain payload artifact.cochain)
    (artifact_binding : artifact.Binds)
    (decoded_zero : payload.decode artifact.cochain = 0)
    (observation_binding : Binds context (classify payload.snapshot) observed
      artifact.cochain artifact.digest payload.snapshot.root) :
    (bindSample context artifact accepted artifact_binding decoded_zero
      observation_binding).artifact = artifact := rfl

/-- The bound sample's HCP target remains its existing integral harmonic message. -/
theorem operativeTarget_eq_original_message
    (O : BoundHCPObservation (integralStructure axis) payload
      (Set ℤ) Lifecycle classify Binds)
    (classifier_eq : HCP.AxisFamily.theory axis = classify payload.snapshot) :
    HCPBridge.operativeTarget HCP.AxisFamily.realization O.toObservation
      (observationAlignment O classifier_eq).hiddenWitness =
        fun i => O.encrypted.message.1 i :=
  (observationAlignment O classifier_eq).operativeTarget_eq_message

/-- The same bound sample and actual harmonic lattice satisfy the proved CVP
comparison, once the sample-message equality is supplied. -/
theorem cvp_solution_iff_operativeTarget
    (O : BoundHCPObservation (integralStructure axis) payload
      (Set ℤ) Lifecycle classify Binds)
    (classifier_eq : HCP.AxisFamily.theory axis = classify payload.snapshot)
    (sample_eq : O.encrypted = sample axis)
    (v : CVP.AmbientVector Index) :
    CVP.Solution ((harmonicLatticePresentation axis).cvpInstance O.encrypted) v ↔
      v = HCPBridge.operativeTarget HCP.AxisFamily.realization O.toObservation
        (observationAlignment O classifier_eq).hiddenWitness := by
  apply (observationAlignment O classifier_eq).cvp_solution_iff_operativeTarget
    (harmonicLatticePresentation axis) (fun _ : Fin 1 => 1)
  rw [sample_eq]
  exact sample_message_eq_point axis

end Hcrypt.TCB.HCPAxisFamily
