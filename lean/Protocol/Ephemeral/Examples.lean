module

public import Protocol.Ephemeral.Delivery
public import HCP.AxisRotation

@[expose] public section

/-!
# Actual axis rotation with a scoped recipient receipt

The private rotation below is constructed from the actual cellular axis
isometry and the proved same-coefficient lattice law. Source/target contexts,
envelopes and authenticated delivery receipts remain the original supplied
objects. No snapshot, hash, channel or authorization fact is manufactured.

The coefficient-two theorem specializes receipt recovery to the transported
weighted sample. It claims no secure delivery algorithm, caller authentication
from public labels, replay prevention or privacy experiment.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt.Protocol.Ephemeral.Examples

open Sheaf CellularSheaf Sheaf.HCPAxisFamily

/-- The actual integral axis swap preserves the declared plaintext coefficients. -/
def axisPresentedRotation :
    PresentedRotation (harmonicLatticePresentation 0) (harmonicLatticePresentation 1) where
  integral := HCP.AxisRotation.integralAxisSwap
  point_naturality z := HCP.AxisRotation.point_naturality z

variable
  {Recipient Envelope : Type*}
  {contract : DeliveryContract (harmonicLatticePresentation 0)
    (harmonicLatticePresentation 1) Recipient Envelope}
  {recipient : Recipient} {sourceEpoch targetEpoch : ℕ}
  {source : Storage.Context (sheaf 0)} {target : Storage.Context (sheaf 1)}

/-- An actual delivered axis rotation recovers coefficient two from the rotated sample. -/
theorem receipt_recovers_weighted_two
    (delivery : RecoveryDelivery contract axisPresentedRotation recipient
      sourceEpoch targetEpoch source target) :
    delivery.recoverFor delivery.scope HCP.AxisRotation.rotatedWeightedSample.observed =
      some (fun _ : Fin 1 => (2 : ℤ)) := by
  have recovered := delivery.recoverFor_rotated_encrypt
    (HCP.AxisFamily.weightedCoefficients 0) (HCP.AxisFamily.weightedOpening 0)
  have observed : axisPresentedRotation.rotateObserved
      ((harmonicLatticePresentation 0).encrypt
        (HCP.AxisFamily.weightedCoefficients 0) (HCP.AxisFamily.weightedOpening 0)).observed =
      HCP.AxisRotation.rotatedWeightedSample.observed := by
    symm
    exact HCP.AxisRotation.integralAxisSwap.transportSample_observed _
  rw [observed] at recovered
  have coefficients : HCP.AxisFamily.weightedCoefficients 0 =
      fun _ : Fin 1 => (2 : ℤ) := by
    funext j
    exact HCP.AxisFamily.weighted_coefficients_values.1
  exact recovered.trans (congrArg some coefficients)

/-- A request for another target epoch is rejected even for the valid rotated sample. -/
theorem receipt_rejects_other_epoch
    (delivery : RecoveryDelivery contract axisPresentedRotation recipient
      sourceEpoch targetEpoch source target)
    (request : DeliveryScope Recipient) (h : request.targetEpoch ≠ targetEpoch) :
    delivery.recoverFor request HCP.AxisRotation.rotatedWeightedSample.observed = none :=
  delivery.recoverFor_wrong_targetEpoch request h _

end Hcrypt.Protocol.Ephemeral.Examples
