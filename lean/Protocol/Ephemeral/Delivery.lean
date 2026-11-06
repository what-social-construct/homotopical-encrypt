module

public import Protocol.Ephemeral.Rotation

@[expose] public section

/-!
# Recipient- and epoch-bound recovery material

A delivery scope names the recipient, both epochs and the keys derived from
the actual source and target storage contexts. A receipt retains the actual
private presented rotation and an envelope through explicitly supplied
authorization and delivery relations. It does not construct a cryptographic
channel or serialize that private material.

The context keys are public identifiers, not secret recovery keys. Epoch
labels are supplied by the profile; its authorization and delivery contracts
must bind them to the actual authenticated protocol state.

Recovery checks the entire requested scope before using the delivered
transport. The correctness theorem concerns an actual rotated encryption;
scope rejection does not prove global freshness, confidentiality, retirement,
physical erasure or forward secrecy. These semantic receipts are not public
wire records. Equality of request labels authenticates no actual caller and
does not prevent replay of the same valid scope. Authorization and delivery
remain the explicit channel contracts retained by the receipt.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt.Protocol.Ephemeral

open Sheaf CellularSheaf

/-- The complete authorization context for one recipient's recovery material. -/
structure DeliveryScope (Recipient : Type*) where
  recipient : Recipient
  sourceEpoch : ℕ
  targetEpoch : ℕ
  source : Storage.ContextKey
  target : Storage.ContextKey

variable
  {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}
  {F G : CellularSheaf X}

namespace DeliveryScope

/-- Derive both context keys from their original contexts, rather than resupply roots. -/
def forContexts {Recipient : Type*}
    (recipient : Recipient) (sourceEpoch targetEpoch : ℕ)
    (source : Storage.Context F) (target : Storage.Context G) :
    DeliveryScope Recipient where
  recipient := recipient
  sourceEpoch := sourceEpoch
  targetEpoch := targetEpoch
  source := source.key
  target := target.key

end DeliveryScope

variable
  {I : IntegralStructure F} {J : IntegralStructure G}
  {Rank : Type*} [Fintype Rank]

/-- Application-owned authorization and delivery of this actual private material. -/
structure DeliveryContract
    (H : HarmonicLatticePresentation I Rank)
    (K : HarmonicLatticePresentation J Rank)
    (Recipient Envelope : Type*) where
  Authorized : DeliveryScope Recipient → Prop
  Delivers : DeliveryScope Recipient → PresentedRotation H K → Envelope → Prop

/-- A receipt for the specified recipient, epochs, original contexts and rotation. -/
structure RecoveryDelivery
    {H : HarmonicLatticePresentation I Rank}
    {K : HarmonicLatticePresentation J Rank}
    {Recipient Envelope : Type*}
    (contract : DeliveryContract H K Recipient Envelope)
    (rotation : PresentedRotation H K)
    (recipient : Recipient) (sourceEpoch targetEpoch : ℕ)
    (source : Storage.Context F) (target : Storage.Context G) where
  envelope : Envelope
  authorized : contract.Authorized
    (DeliveryScope.forContexts recipient sourceEpoch targetEpoch source target)
  delivered : contract.Delivers
    (DeliveryScope.forContexts recipient sourceEpoch targetEpoch source target)
    rotation envelope

namespace RecoveryDelivery

variable
  {H : HarmonicLatticePresentation I Rank}
  {K : HarmonicLatticePresentation J Rank}
  {Recipient Envelope : Type*}
  {contract : DeliveryContract H K Recipient Envelope}
  {rotation : PresentedRotation H K}
  {recipient : Recipient} {sourceEpoch targetEpoch : ℕ}
  {source : Storage.Context F} {target : Storage.Context G}

/-- The receipt's scope is derived from its actual recipient, epochs and contexts. -/
def scope
    (_delivery : RecoveryDelivery contract rotation recipient sourceEpoch targetEpoch
      source target) : DeliveryScope Recipient :=
  DeliveryScope.forContexts recipient sourceEpoch targetEpoch source target

/-- Use the delivered private transport only for the exact receipt scope.
Matching labels do not authenticate a caller or prevent replay. -/
def recoverFor
    (delivery : RecoveryDelivery contract rotation recipient sourceEpoch targetEpoch
      source target)
    (request : DeliveryScope Recipient) (b : G.C1) : Option (Rank → ℤ) := by
  classical
  exact if request = delivery.scope then rotation.recoverWithBase b else none

/-- The matching request recovers the original integer coefficients after rotation. -/
theorem recoverFor_rotated_encrypt
    (delivery : RecoveryDelivery contract rotation recipient sourceEpoch targetEpoch
      source target)
    (z : Rank → ℤ) (opening : HodgeNoise F) :
    delivery.recoverFor delivery.scope
        (rotation.rotateObserved (H.encrypt z opening).observed) = some z := by
  simpa [recoverFor] using
    rotation.recoverWithBase_rotated_encrypt z opening

/-- Any change to the requested scope rejects before applying the private recovery map. -/
theorem recoverFor_eq_none_of_scope_ne
    (delivery : RecoveryDelivery contract rotation recipient sourceEpoch targetEpoch
      source target)
    (request : DeliveryScope Recipient) (h : request ≠ delivery.scope) (b : G.C1) :
    delivery.recoverFor request b = none := by
  unfold recoverFor
  exact ite_eq_right h

theorem recoverFor_wrong_recipient
    (delivery : RecoveryDelivery contract rotation recipient sourceEpoch targetEpoch
      source target)
    (request : DeliveryScope Recipient) (h : request.recipient ≠ recipient) (b : G.C1) :
    delivery.recoverFor request b = none := by
  apply delivery.recoverFor_eq_none_of_scope_ne request _ b
  intro heq
  exact h (congrArg DeliveryScope.recipient heq)

theorem recoverFor_wrong_sourceEpoch
    (delivery : RecoveryDelivery contract rotation recipient sourceEpoch targetEpoch
      source target)
    (request : DeliveryScope Recipient) (h : request.sourceEpoch ≠ sourceEpoch) (b : G.C1) :
    delivery.recoverFor request b = none := by
  apply delivery.recoverFor_eq_none_of_scope_ne request _ b
  intro heq
  exact h (congrArg DeliveryScope.sourceEpoch heq)

theorem recoverFor_wrong_targetEpoch
    (delivery : RecoveryDelivery contract rotation recipient sourceEpoch targetEpoch
      source target)
    (request : DeliveryScope Recipient) (h : request.targetEpoch ≠ targetEpoch) (b : G.C1) :
    delivery.recoverFor request b = none := by
  apply delivery.recoverFor_eq_none_of_scope_ne request _ b
  intro heq
  exact h (congrArg DeliveryScope.targetEpoch heq)

theorem recoverFor_wrong_sourceKey
    (delivery : RecoveryDelivery contract rotation recipient sourceEpoch targetEpoch
      source target)
    (request : DeliveryScope Recipient) (h : request.source ≠ source.key) (b : G.C1) :
    delivery.recoverFor request b = none := by
  apply delivery.recoverFor_eq_none_of_scope_ne request _ b
  intro heq
  exact h (congrArg DeliveryScope.source heq)

theorem recoverFor_wrong_targetKey
    (delivery : RecoveryDelivery contract rotation recipient sourceEpoch targetEpoch
      source target)
    (request : DeliveryScope Recipient) (h : request.target ≠ target.key) (b : G.C1) :
    delivery.recoverFor request b = none := by
  apply delivery.recoverFor_eq_none_of_scope_ne request _ b
  intro heq
  exact h (congrArg DeliveryScope.target heq)

end RecoveryDelivery

end Hcrypt.Protocol.Ephemeral
