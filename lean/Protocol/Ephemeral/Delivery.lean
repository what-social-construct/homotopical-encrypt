module

public import Protocol.Ephemeral.Rotation

@[expose] public section

/-!
# Recipient- and epoch-bound recovery material

A delivery scope names the recipient, both epochs and the keys derived from
the actual source and target storage contexts. One material-indexed receipt
retains the actual private material and envelope through explicitly supplied
authorization and delivery relations. The existing presented-rotation API is
a specialization of this same structure. No cryptographic channel or private
material serialization is constructed by the receipt.

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

namespace HomotopicalEncryption.Protocol.Ephemeral

open Sheaf CellularSheaf

/-- The complete authorization context for one recipient's recovery material. -/
structure DeliveryScope (Recipient : Type*) where
  recipient : Recipient
  sourceEpoch : ℕ
  targetEpoch : ℕ
  source : Storage.ContextKey
  target : Storage.ContextKey
  deriving DecidableEq

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

/-- Application-owned authorization and delivery of this actual private material. -/
structure ScopedDeliveryContract (Material Recipient Envelope : Type*) where
  Authorized : DeliveryScope Recipient → Prop
  Delivers : DeliveryScope Recipient → Material → Envelope → Prop

/-- One material-indexed delivery receipt for the actual recipient, epochs and
original contexts. Material may be an isometric rotation or a native transport
token; authorization and delivery retain the same exact object indices. -/
structure ScopedDelivery
    {Material Recipient Envelope : Type*}
    (contract : ScopedDeliveryContract Material Recipient Envelope)
    (material : Material)
    (recipient : Recipient) (sourceEpoch targetEpoch : ℕ)
    (source : Storage.Context F) (target : Storage.Context G) where
  envelope : Envelope
  authorized : contract.Authorized
    (DeliveryScope.forContexts recipient sourceEpoch targetEpoch source target)
  delivered : contract.Delivers
    (DeliveryScope.forContexts recipient sourceEpoch targetEpoch source target)
    material envelope

namespace ScopedDelivery

variable {Material Recipient Envelope : Type*}
  {contract : ScopedDeliveryContract Material Recipient Envelope}
  {material : Material} {recipient : Recipient} {sourceEpoch targetEpoch : ℕ}
  {source : Storage.Context F} {target : Storage.Context G}

/-- Derive the complete scope from the original contexts and receipt indices. -/
def scope (_delivery : ScopedDelivery contract material recipient sourceEpoch targetEpoch
    source target) : DeliveryScope Recipient :=
  DeliveryScope.forContexts recipient sourceEpoch targetEpoch source target

/-- Scope-check the supplied material operation locally. The receipt's
authorization and delivery facts remain separate from this executable check. -/
def useFor [DecidableEq Recipient] {Input Output : Type*}
    (delivery : ScopedDelivery contract material recipient sourceEpoch targetEpoch source target)
    (use : Material → Input → Option Output)
    (request : DeliveryScope Recipient) (input : Input) : Option Output :=
  if request = delivery.scope then use material input else none

@[simp] theorem useFor_scope [DecidableEq Recipient] {Input Output : Type*}
    (delivery : ScopedDelivery contract material recipient sourceEpoch targetEpoch source target)
    (use : Material → Input → Option Output) (input : Input) :
    delivery.useFor use delivery.scope input = use material input := by
  simp [useFor]

theorem useFor_eq_none_of_scope_ne [DecidableEq Recipient] {Input Output : Type*}
    (delivery : ScopedDelivery contract material recipient sourceEpoch targetEpoch source target)
    (use : Material → Input → Option Output)
    (request : DeliveryScope Recipient) (wrong : request ≠ delivery.scope) (input : Input) :
    delivery.useFor use request input = none := by
  simp [useFor, wrong]

end ScopedDelivery

variable
  {I : IntegralStructure F} {J : IntegralStructure G}
  {Rank : Type*} [Fintype Rank]

/-- Backwards-compatible specialization of the one material-delivery contract. -/
abbrev DeliveryContract
    (H : HarmonicLatticePresentation I Rank)
    (K : HarmonicLatticePresentation J Rank)
    (Recipient Envelope : Type*) :=
  ScopedDeliveryContract (PresentedRotation H K) Recipient Envelope

/-- Existing isometric recovery receipts specialize the same scoped structure. -/
abbrev RecoveryDelivery
    {H : HarmonicLatticePresentation I Rank}
    {K : HarmonicLatticePresentation J Rank}
    {Recipient Envelope : Type*}
    (contract : DeliveryContract H K Recipient Envelope)
    (rotation : PresentedRotation H K)
    (recipient : Recipient) (sourceEpoch targetEpoch : ℕ)
    (source : Storage.Context F) (target : Storage.Context G) :=
  ScopedDelivery contract rotation recipient sourceEpoch targetEpoch source target

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
noncomputable def recoverFor
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

end HomotopicalEncryption.Protocol.Ephemeral
