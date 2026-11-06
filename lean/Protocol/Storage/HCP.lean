module

public import Protocol.Storage.Context
public import TCB.HCPObservation

@[expose] public section

/-!
# Storage starts from the original bound HCP stack

Only the existing exact payload, its public artifact, and its fixed snapshot
are reused in the storage context. The full HCP observation remains the
separate encrypted cochain carried by `BoundHCPObservation`; its harmonic
message is not identified with the serialized exact component.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt.Protocol.Storage

open Sheaf CellularSheaf

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}
  {integral : IntegralStructure F}
  {payload : CochainPayloadInterpretation F}
  {PublicClass Lifecycle : Type*}
  {classify : SheafStateSnapshot F → PublicClass}
  {Binds : TCB.HCPStackBinding Lifecycle PublicClass F.C1}

/-- Reuse the same accepted exact artifact and snapshot from the HCP observation. -/
def ofHCPObservation
    (O : TCB.BoundHCPObservation integral payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32) : Context F where
  runId := identify O.context
  interpretation := payload
  artifact := O.artifact
  artifactWellFormed := O.artifact_wellFormed
  boundToSnapshot := O.payload_boundToSnapshot
  parameterSet := parameters

theorem ofHCPObservation_accepted
    (O : TCB.BoundHCPObservation integral payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32) :
    (ofHCPObservation O identify parameters).Accepted := O.acceptedExact

theorem ofHCPObservation_cochain
    (O : TCB.BoundHCPObservation integral payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32) :
    (ofHCPObservation O identify parameters).cochain = O.artifact.cochain := rfl

theorem ofHCPObservation_snapshotRoot
    (O : TCB.BoundHCPObservation integral payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32) :
    (ofHCPObservation O identify parameters).key.snapshotRoot = O.snapshotRoot := rfl

theorem ofHCPObservation_leafDigest
    (O : TCB.BoundHCPObservation integral payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32) :
    (ofHCPObservation O identify parameters).key.cochainDigest = O.hashObject := rfl

/-- The storage run name is derived from the observation's actual lifecycle context. -/
theorem ofHCPObservation_runId
    (O : TCB.BoundHCPObservation integral payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32) :
    (ofHCPObservation O identify parameters).key.runId = identify O.context := rfl

/-- The exact component has zero exactness residual; this says nothing about
distance of the distinct full encrypted cochain to a different valid locus. -/
theorem ofHCPObservation_decodedDistance
    (O : TCB.BoundHCPObservation integral payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32) :
    (ofHCPObservation O identify parameters).decodedDistance = 0 :=
  (Context.accepted_iff_decodedDistance_eq_zero _).1
    (ofHCPObservation_accepted O identify parameters)

end Hcrypt.Protocol.Storage
