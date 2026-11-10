module

public import Protocol.Ephemeral.Rotation
public import Protocol.Storage.HCP

@[expose] public section

/-!
# Original bound HCP samples across a presented rotation

Both endpoints are the existing bound sample/artifact/snapshot objects. An
actual transported-sample equality derives the observed-cochain equation and
the payload decoder equation from their existing exact-component joins.
Recipient recovery refers to the same source sample and explicitly requires
that its message lies in the selected presented lattice.

The optional constructor retains a supplied target artifact, context and all
acceptance/binding contracts. It chooses no digest or snapshot root. Source
and target classifiers may differ; no public-class equality, equal released
view, secure delivery or lifecycle guarantee follows from this adapter.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Ephemeral

open Sheaf CellularSheaf

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}
  {F G : CellularSheaf X}
  {I : IntegralStructure F} {J : IntegralStructure G}
  {Rank : Type*} [Fintype Rank]
  {H : HarmonicLatticePresentation I Rank}
  {K : HarmonicLatticePresentation J Rank}
  {payloadS : CochainPayloadInterpretation F}
  {payloadT : CochainPayloadInterpretation G}
  {PublicClassS LifecycleS PublicClassT LifecycleT : Type*}
  {classifyS : SheafStateSnapshot F → PublicClassS}
  {classifyT : SheafStateSnapshot G → PublicClassT}
  {BindsS : TCB.HCPStackBinding LifecycleS PublicClassS F.C1}
  {BindsT : TCB.HCPStackBinding LifecycleT PublicClassT G.C1}

/-- The target's original bound HCP sample is this actual rotation of the source. -/
structure BoundSampleRotation
    (R : PresentedRotation H K)
    (source : TCB.BoundHCPObservation I payloadS PublicClassS LifecycleS classifyS BindsS)
    (target : TCB.BoundHCPObservation J payloadT PublicClassT LifecycleT classifyT BindsT) : Prop where
  transported : target.encrypted = R.integral.transportSample source.encrypted

namespace BoundSampleRotation

variable {R : PresentedRotation H K}
  {source : TCB.BoundHCPObservation I payloadS PublicClassS LifecycleS classifyS BindsS}
  {target : TCB.BoundHCPObservation J payloadT PublicClassT LifecycleT classifyT BindsT}

/-- The full target observation is the actual transported source cochain. -/
theorem cochainObject_eq (B : BoundSampleRotation R source target) :
    target.cochainObject = R.rotateObserved source.cochainObject := by
  change target.encrypted.observed = R.integral.degreeOne source.encrypted.observed
  rw [B.transported, R.integral.transportSample_observed]

/-- Existing exact-component joins derive migration of the original payload decoders. -/
theorem payloadRotation (B : BoundSampleRotation R source target)
    (identifyS : LifecycleS → TCB.Hash32) (parametersS : TCB.Hash32)
    (identifyT : LifecycleT → TCB.Hash32) (parametersT : TCB.Hash32) :
    PayloadRotation R
      (Storage.ofHCPObservation source identifyS parametersS)
      (Storage.ofHCPObservation target identifyT parametersT) := by
  refine ⟨?_⟩
  change payloadT.decode target.artifact.cochain =
    R.integral.degreeOne (payloadS.decode source.artifact.cochain)
  rw [target.decodedExactComponent, source.decodedExactComponent, B.transported]
  exact R.integral.toIsometricCochainEquiv.transportNoise_exactComponent
    source.encrypted.opening

/-- The target presentation recovers coefficients of this original source sample. -/
theorem decode_target (B : BoundSampleRotation R source target)
    (z : Rank → ℤ) (message_eq : source.encrypted.message = H.point z) :
    K.decodeCoefficients target.cochainObject = some z := by
  rw [K.decodeCoefficients_eq_some_iff, B.cochainObject_eq]
  change G.harmonicOneProjection (R.integral.degreeOne source.cochainObject) = _
  rw [R.integral.toIsometricCochainEquiv.harmonicOneProjection_naturality,
    source.harmonicProjection_cochainObject]
  change R.integral.degreeOne source.encrypted.message.1 = (K.point z).1
  rw [message_eq]
  exact R.point_naturality z

/-- The retained base presentation and actual inverse transport recover the same coefficients. -/
theorem recover_with_base (B : BoundSampleRotation R source target)
    (z : Rank → ℤ) (message_eq : source.encrypted.message = H.point z) :
    R.recoverWithBase target.cochainObject = some z := by
  rw [B.cochainObject_eq]
  unfold PresentedRotation.recoverWithBase
  rw [R.pullback_rotateObserved, H.decodeCoefficients_eq_some_iff,
    source.harmonicProjection_cochainObject]
  exact congrArg Subtype.val message_eq

end BoundSampleRotation

/-- Bind the actual rotated source sample to an original supplied target artifact.
Acceptance, decoder alignment and context/envelope bindings remain explicit. -/
def bindRotatedSample
    (R : PresentedRotation H K)
    (source : TCB.BoundHCPObservation I payloadS PublicClassS LifecycleS classifyS BindsS)
    (context : LifecycleT) (artifact : TCB.HashedCommittedCochain)
    (accepted : AcceptedCommittedOneCochain payloadT artifact.cochain)
    (artifact_binding : artifact.Binds)
    (decoded_transport : payloadT.decode artifact.cochain =
      R.integral.degreeOne source.encrypted.opening.exactComponent)
    (observation_binding : BindsT context (classifyT payloadT.snapshot)
      (R.rotateObserved source.cochainObject)
      artifact.cochain artifact.digest payloadT.snapshot.root) :
    TCB.BoundHCPObservation J payloadT PublicClassT LifecycleT classifyT BindsT where
  context := context
  encrypted := R.integral.transportSample source.encrypted
  artifact := artifact
  acceptedExact := accepted
  artifactBinding := artifact_binding
  decodedExactComponent := by
    change payloadT.decode artifact.cochain =
      (R.integral.toIsometricCochainEquiv.transportNoise source.encrypted.opening).exactComponent
    rw [R.integral.toIsometricCochainEquiv.transportNoise_exactComponent]
    exact decoded_transport
  bindsObservation := by
    rw [R.integral.transportSample_observed]
    exact observation_binding

/-- The constructed endpoint retains exactly the supplied target artifact. -/
theorem bindRotatedSample_artifact
    (R : PresentedRotation H K)
    (source : TCB.BoundHCPObservation I payloadS PublicClassS LifecycleS classifyS BindsS)
    (context : LifecycleT) (artifact : TCB.HashedCommittedCochain)
    (accepted : AcceptedCommittedOneCochain payloadT artifact.cochain)
    (artifact_binding : artifact.Binds)
    (decoded_transport : payloadT.decode artifact.cochain =
      R.integral.degreeOne source.encrypted.opening.exactComponent)
    (observation_binding : BindsT context (classifyT payloadT.snapshot)
      (R.rotateObserved source.cochainObject)
      artifact.cochain artifact.digest payloadT.snapshot.root) :
    (bindRotatedSample R source context artifact accepted artifact_binding
      decoded_transport observation_binding).artifact = artifact := rfl

/-- Actual sample transport is definitional for the supplied-artifact constructor. -/
theorem boundSampleRotation_bindRotatedSample
    (R : PresentedRotation H K)
    (source : TCB.BoundHCPObservation I payloadS PublicClassS LifecycleS classifyS BindsS)
    (context : LifecycleT) (artifact : TCB.HashedCommittedCochain)
    (accepted : AcceptedCommittedOneCochain payloadT artifact.cochain)
    (artifact_binding : artifact.Binds)
    (decoded_transport : payloadT.decode artifact.cochain =
      R.integral.degreeOne source.encrypted.opening.exactComponent)
    (observation_binding : BindsT context (classifyT payloadT.snapshot)
      (R.rotateObserved source.cochainObject)
      artifact.cochain artifact.digest payloadT.snapshot.root) :
    BoundSampleRotation R source
      (bindRotatedSample R source context artifact accepted artifact_binding
        decoded_transport observation_binding) := ⟨rfl⟩

end HomotopicalEncryption.Protocol.Ephemeral
