import Proximity.PluckerCochain.PublicBinding
import Proximity.CochainPlane.Core
import Proximity.GateEvidence
import TCB.CompressionBoundary
import TCB.ObservationBoundary

/-!
  Public/storage boundary for the proximity bridge.

  Core mathematical stages stay with their objects:

  * `PluckerCochain` owns Plucker-to-cochain math.
  * `CochainPlane` owns cochain-to-plane math.
  * `CochainReedSolomon` owns plane-to-RS interpretation.

  This aggregate collects the public/runtime-facing views of those objects:

  * observed Plucker/cochain payload realization;
  * sheaf-storage-root-linked plane views;
  * authenticated hard-gate/final-gate evidence records.

  Runtime-owned facts such as canonical bytes, storage roots, inclusion proofs,
  and hash binding are represented here as boundary propositions/certificate
  fields. Rust owns their concrete verification.
-/

namespace Hcrypt
namespace Proximity
namespace CochainPlane
namespace PublicBinding

open TCB.CompressionBoundary
open TCB.CompressionBoundary.CompressionContract

noncomputable section

variable {R ι : Type}

/--
Derived plane view of an observed public cochain artifact.

The plane view is addressed by the surrounding storage stack root, not by a
second plane-specific hash. The cochain artifact digest remains the leaf digest
already attached to the proof-carrying cochain commitment.
-/
structure PlaneView
    (runtime : TCB.RuntimeBoundary)
    (E : PlaneExtractionContext R ι) where
  storageContract : CompressionContract
  storageStack : CompressedShadow storageContract
  observation : TCB.ObservationBoundary.ObservedStatement runtime
  planeShadow : PlaneShadow R ι
  cochainArtifactIncludedInStack : Prop
  planeViewIncludedInStack : Prop
  cochainArtifactIncluded : cochainArtifactIncludedInStack
  planeViewIncluded : planeViewIncludedInStack
  cochainAligned : E.Aligned observation.cochain
  planeMatchesCochain :
    planeShadow = E.projectedPlane observation.cochain

namespace PlaneView

variable {runtime : TCB.RuntimeBoundary}
variable {E : PlaneExtractionContext R ι}

/-- The public storage anchor for this plane view is the sheaf-stack root. -/
def storageRoot (O : PlaneView runtime E) :
    TCB.Hash32 :=
  O.storageStack.digest

/-- The observed cochain artifact's own leaf digest. -/
def cochainArtifactDigest (O : PlaneView runtime E) :
    TCB.Hash32 :=
  O.observation.artifact.publicArtifact.digest

/-- The storage stack root binds the compressed public stack shadow. -/
theorem root_binds_sheaf_stack
    (O : PlaneView runtime E) :
    O.storageContract.BindsDigest
      O.storageStack.shadow O.storageStack.digest :=
  O.storageStack.bindsDigest

/-- The cochain artifact is included under the same sheaf-storage stack root. -/
theorem cochain_artifact_included
    (O : PlaneView runtime E) :
    O.cochainArtifactIncludedInStack :=
  O.cochainArtifactIncluded

/-- The derived plane view is included under the same sheaf-storage stack root. -/
theorem plane_view_included
    (O : PlaneView runtime E) :
    O.planeViewIncludedInStack :=
  O.planeViewIncluded

/-- The carried plane shadow is exactly the projection of the observed cochain. -/
theorem planeShadow_eq_projectedCochain
    (O : PlaneView runtime E) :
    O.planeShadow = E.projectedPlane O.observation.cochain :=
  O.planeMatchesCochain

/-- The observed cochain payload is well formed at the public commitment layer. -/
theorem cochain_wellFormed
    (O : PlaneView runtime E) :
    O.observation.cochain.WellFormed :=
  TCB.ObservationBoundary.ObservedStatement.cochain_wellFormed O.observation

/-- The observed cochain is aligned with the plane extraction context. -/
theorem aligned
    (O : PlaneView runtime E) :
    E.Aligned O.observation.cochain :=
  O.cochainAligned

/-- The observed cochain has the expected edge count for plane extraction. -/
theorem edgeCount_eq
    (O : PlaneView runtime E) :
    O.observation.cochain.n_edge_values = E.edgeCount :=
  PlaneExtractionContext.edgeCount_eq_of_aligned O.aligned

/-- Every selected plane coordinate is in bounds in the observed cochain. -/
theorem selectedIndex_lt
    (O : PlaneView runtime E)
    (i : ι)
    (j : Fin 2) :
    E.edgeIndex i j < O.observation.cochain.edge_values.length :=
  PlaneExtractionContext.edgeIndex_lt_of_aligned O.aligned i j

/-- The shared cochain digest binds the artifact that this plane view projects. -/
theorem cochainDigestBinds
    (O : PlaneView runtime E) :
    O.observation.artifact.publicArtifact.Binds :=
  (TCB.ObservationBoundary.ObservedStatement.publicArtifact_wellFormed
    O.observation).2

/--
Build a plane view from the existing Plucker/cochain public binding.

This is the public-layer fidelity bridge:

`public Plucker shadow -> sheaf storage stack root -> observed cochain artifact
 -> derived plane view`.
-/
def ofObservedFrameBinding
    {runtime : TCB.RuntimeBoundary}
    {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
    {P : GrassmannianPlucker.FramedSystem n r}
    {B : PluckerCochain.PublicBinding.PayloadRealization P}
    {S : Axioms.SheafCoherence}
    {W : GrassmannianPlucker.FrameWitness n r}
    (O :
      PluckerCochain.PublicBinding.ObservedFrameBinding
        runtime B S W)
    (storageContract : CompressionContract)
    (storageStack : CompressedShadow storageContract)
    (E : PlaneExtractionContext R ι)
    (planeShadow : PlaneShadow R ι)
    (hCochainIncluded : Prop)
    (hPlaneIncluded : Prop)
    (hCochainIncludedProof : hCochainIncluded)
    (hPlaneIncludedProof : hPlaneIncluded)
    (hAligned : E.Aligned O.observation.cochain)
    (hMatch :
      planeShadow = E.projectedPlane O.observation.cochain) :
    PlaneView runtime E where
  storageContract := storageContract
  storageStack := storageStack
  observation := O.observation
  planeShadow := planeShadow
  cochainArtifactIncludedInStack := hCochainIncluded
  planeViewIncludedInStack := hPlaneIncluded
  cochainArtifactIncluded := hCochainIncludedProof
  planeViewIncluded := hPlaneIncludedProof
  cochainAligned := hAligned
  planeMatchesCochain := hMatch

end PlaneView

end

end PublicBinding
end CochainPlane
end Proximity
end Hcrypt
