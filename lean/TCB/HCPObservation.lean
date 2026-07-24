import HCP
import Sheaf.HarmonicLattice
import Sheaf.Commitment
import TCB.ProofCarrying

/-!
# Bound lattice/cochain/hash observations for HCP

This leaf module connects the Paper 1 sheaf/Hodge core to public artifacts
without making hashes or payloads part of the mathematical HCP definition.

The serialized cochain payload remains exact.  It decodes to the exact
component `δ₀ a` of a Hodge opening.  The public HCP cochain is the distinct
value

`b = h + δ₀ a + δ₁* c`.

An application-owned binding relation ties that observation to the exact
payload, its leaf digest, the enclosing sheaf snapshot root, and one lifecycle
context.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt
namespace TCB

open Sheaf CellularSheaf

variable
  {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}
  {F : CellularSheaf X}

/--
An application-owned relation binding one HCP observation to its exact base
payload, leaf digest, snapshot root, and lifecycle context.
-/
abbrev HCPStackBinding
    (Context PublicClass Cochain : Type*) :=
  Context → PublicClass → Cochain →
    Axioms.CochainCommitmentData → Hash32 → Hash32 → Prop

/--
The typed lattice/cochain/hash stack at the HCP public boundary.

The wire payload remains an accepted exact cochain and decodes to the exact
component of the Hodge opening.  The HCP observation is the separate full
cochain `b = h + δ₀a + δ₁*c`.  `bindsObservation` is the explicit relation
tying that observation, payload, leaf digest, and snapshot root together.
-/
structure BoundHCPObservation
    (integral : IntegralStructure F)
    (payload : CochainPayloadInterpretation F)
    (PublicClass Context : Type*)
    (classify : SheafStateSnapshot F → PublicClass)
    (Binds : HCPStackBinding Context PublicClass F.C1) where
  context : Context
  encrypted : HodgeEncryptedCochain integral
  artifact : HashedCommittedCochain
  acceptedExact :
    AcceptedCommittedOneCochain payload artifact.cochain
  artifactBinding : artifact.Binds
  decodedExactComponent :
    payload.decode artifact.cochain = encrypted.opening.exactComponent
  bindsObservation :
    Binds context (classify payload.snapshot) encrypted.observed
      artifact.cochain artifact.digest payload.snapshot.root

namespace BoundHCPObservation

variable
  {integral : IntegralStructure F}
  {payload : CochainPayloadInterpretation F}
  {PublicClass Context : Type*}
  {classify : SheafStateSnapshot F → PublicClass}
  {Binds : HCPStackBinding Context PublicClass F.C1}

/-- The hidden integral harmonic point in the stack. -/
def latticeObject
    (O : BoundHCPObservation integral payload PublicClass Context classify Binds) :
    integral.harmonicOneLattice :=
  O.encrypted.message

/-- The public cochain-facing HCP observation in the stack. -/
def cochainObject
    (O : BoundHCPObservation integral payload PublicClass Context classify Binds) :
    F.C1 :=
  O.encrypted.observed

/-- The leaf digest of the accepted exact cochain payload. -/
def hashObject
    (O : BoundHCPObservation integral payload PublicClass Context classify Binds) :
    Hash32 :=
  O.artifact.digest

/-- The enclosing sheaf snapshot root; it is distinct from the leaf digest. -/
def snapshotRoot
    (_O : BoundHCPObservation integral payload PublicClass Context classify Binds) :
    Hash32 :=
  payload.snapshot.root

/-- The accepted exact payload and its hash binding form a well-formed artifact. -/
theorem artifact_wellFormed
    (O : BoundHCPObservation integral payload PublicClass Context classify Binds) :
    O.artifact.WellFormed :=
  ⟨O.acceptedExact.wireWellFormed, O.artifactBinding⟩

/-- The accepted exact payload is bound to the same sheaf snapshot. -/
theorem payload_boundToSnapshot
    (O : BoundHCPObservation integral payload PublicClass Context classify Binds) :
    payload.BoundToSnapshot O.artifact.cochain :=
  O.acceptedExact.boundToSnapshot

/-- The stack exposes the public classifier/cochain pair expected by HCP. -/
def toObservation
    (O : BoundHCPObservation integral payload PublicClass Context classify Binds) :
    HCPBridge.Observation PublicClass (TotalCoord Edge F.edgeDim) ℝ :=
  (classify payload.snapshot, O.cochainObject)

/-- The existing sheaf Hodge projection recovers the stack's lattice object. -/
theorem harmonicProjection_cochainObject
    (O : BoundHCPObservation integral payload PublicClass Context classify Binds) :
    F.harmonicOneProjection O.cochainObject = O.latticeObject.1 :=
  O.encrypted.harmonicOneProjection_observed

end BoundHCPObservation

end TCB
end Hcrypt
