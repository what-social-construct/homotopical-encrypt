module

public import Protocol.Storage.HCP
public import Protocol.Storage.Checkpoint

@[expose] public section

/-!
# Public payload views and explicit HCP disclosure

The base storage input publishes the original residue payload and the names in
its existing `ContextKey`. It carries no sheaf, decoder, harmonic message,
opening, full cochain, semantic proposition or proof object. This is a typed
value projection, not a byte serializer or a cryptographic hiding theorem.

The separately named `HCPDisclosure` additionally exposes the mathematical
`(class,b)` pair from the same original bound HCP observation. The real-valued
pair is not claimed to have a finite wire encoding. Equality of that pair
alone does not imply equality of the base record: public parameter or run
names can distinguish the records. A complete transcript may additionally
contain proofs, local openings, manifest/evidence/block roots and access
metadata, whose release and binding contracts remain separate.

The retained manifest view publishes the exact sealed root and ordered
slot/digest directory from the same context. Its dependent semantic payloads
remain outside this projection. This does not authenticate a surrounding block
or serialize a proof transcript.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt.Protocol.Storage

open Sheaf CellularSheaf

/-- Released values of the original storage input, without its private semantics. -/
structure PublicPayloadView where
  key : ContextKey
  cochain : Axioms.CochainCommitmentData

namespace PublicPayloadView

/-- Both the complete public header and the original payload determine this view. -/
@[ext]
theorem ext {A B : PublicPayloadView}
    (hkey : A.key = B.key) (hcochain : A.cochain = B.cochain) : A = B := by
  cases A
  cases B
  cases hkey
  cases hcochain
  rfl

theorem eq_iff (A B : PublicPayloadView) :
    A = B ↔ A.key = B.key ∧ A.cochain = B.cochain := by
  constructor
  · intro h
    exact ⟨congrArg PublicPayloadView.key h, congrArg PublicPayloadView.cochain h⟩
  · rintro ⟨hkey, hcochain⟩
    exact ext hkey hcochain

/-- A changed public header cannot be hidden by equality of residue payloads. -/
theorem ne_of_key_ne {A B : PublicPayloadView} (h : A.key ≠ B.key) : A ≠ B := by
  intro heq
  exact h (congrArg PublicPayloadView.key heq)

end PublicPayloadView

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

namespace Context

/-- Publish the original payload and its derived context names, retaining no witness. -/
def publicView (C : Context F) : PublicPayloadView :=
  ⟨C.key, C.cochain⟩

theorem publicView_eq_iff (C D : Context F) :
    C.publicView = D.publicView ↔ C.key = D.key ∧ C.cochain = D.cochain :=
  PublicPayloadView.eq_iff _ _

/-- The released payload tag agrees with the released snapshot tag by original binding. -/
theorem publicView_topologyTag_matches (C : Context F) :
    C.publicView.cochain.topology_hash = C.publicView.key.topologyTag :=
  C.topologyTag_matches

theorem publicView_ne_of_key_ne (C D : Context F) (h : C.key ≠ D.key) :
    C.publicView ≠ D.publicView :=
  PublicPayloadView.ne_of_key_ne h

/-- Replacing the actual snapshot root changes the released input. -/
theorem publicView_ne_of_snapshot_ne (C D : Context F)
    (h : C.interpretation.snapshot.root ≠ D.interpretation.snapshot.root) :
    C.publicView ≠ D.publicView :=
  publicView_ne_of_key_ne C D (key_ne_of_snapshot_ne C D h)

/-- Replacing the actual run name changes the released input. -/
theorem publicView_ne_of_runId_ne (C D : Context F) (h : C.runId ≠ D.runId) :
    C.publicView ≠ D.publicView :=
  publicView_ne_of_key_ne C D (key_ne_of_runId_ne C D h)

/-- Replacing the actual parameter-set name changes the released input. -/
theorem publicView_ne_of_parameters_ne (C D : Context F)
    (h : C.parameterSet ≠ D.parameterSet) : C.publicView ≠ D.publicView :=
  publicView_ne_of_key_ne C D (key_ne_of_parameters_ne C D h)

end Context

/-- Retained manifest names, without dependent semantic checkpoint payloads. -/
structure PublicManifestView (Slot : Type*) where
  base : PublicPayloadView
  root : TCB.Hash32
  directory : List (Slot × TCB.Hash32)

namespace PublicManifestView

variable {Slot : Type*}

@[ext]
theorem ext {A B : PublicManifestView Slot}
    (hbase : A.base = B.base) (hroot : A.root = B.root)
    (hdirectory : A.directory = B.directory) : A = B := by
  cases A
  cases B
  cases hbase
  cases hroot
  cases hdirectory
  rfl

/-- The complete public directory, root and original input determine this view. -/
theorem eq_iff (A B : PublicManifestView Slot) :
    A = B ↔ A.base = B.base ∧ A.root = B.root ∧ A.directory = B.directory := by
  constructor
  · intro h
    exact ⟨congrArg PublicManifestView.base h, congrArg PublicManifestView.root h,
      congrArg PublicManifestView.directory h⟩
  · rintro ⟨hbase, hroot, hdirectory⟩
    exact ext hbase hroot hdirectory

end PublicManifestView

namespace SealedManifest

variable {Slot : Type*} {Payload : Slot → Type*} {Receipt : Type*}
  {S : CheckpointScheme F Slot Payload Receipt} {C : Context F}

/-- Publish names from this exact sealed object, without its semantic payloads. -/
def publicView (M : SealedManifest S C) : PublicManifestView Slot where
  base := C.publicView
  root := M.root
  directory := M.manifest.items.map fun item => (item.slot, item.digest)

/-- The manifest release retains the same original context and payload. -/
theorem publicView_base (M : SealedManifest S C) :
    M.publicView.base = C.publicView := rfl

/-- Every directory position names the corresponding original manifest slot. -/
theorem publicView_directory_slots (M : SealedManifest S C) :
    M.publicView.directory.map Prod.fst = M.manifest.slots := by
  simp [publicView, OpenManifest.items, OpenManifest.slots, List.map_map]

/-- Removing semantic payloads preserves the proved slot-uniqueness invariant. -/
theorem publicView_directory_slots_nodup (M : SealedManifest S C) :
    (M.publicView.directory.map Prod.fst).Nodup := by
  rw [publicView_directory_slots]
  exact M.manifest.slotsNodup

end SealedManifest

/-- An explicit additional disclosure of the full mathematical HCP input. -/
structure HCPDisclosure (PublicClass Index : Type*) where
  base : PublicPayloadView
  observation : HCPBridge.Observation PublicClass Index ℝ

namespace HCPDisclosure

variable {PublicClass Index : Type*}

/-- Forget the optional class/cochain disclosure, leaving the base storage input. -/
def forget (D : HCPDisclosure PublicClass Index) : PublicPayloadView := D.base

@[ext]
theorem ext {A B : HCPDisclosure PublicClass Index}
    (hbase : A.base = B.base) (hobs : A.observation = B.observation) : A = B := by
  cases A
  cases B
  cases hbase
  cases hobs
  rfl

/-- Matching HCP observations are only one part of equality of the released record. -/
theorem eq_iff (A B : HCPDisclosure PublicClass Index) :
    A = B ↔ A.base = B.base ∧ A.observation = B.observation := by
  constructor
  · intro h
    exact ⟨congrArg HCPDisclosure.base h, congrArg HCPDisclosure.observation h⟩
  · rintro ⟨hbase, hobs⟩
    exact ext hbase hobs

theorem ne_of_base_ne {A B : HCPDisclosure PublicClass Index}
    (h : A.base ≠ B.base) : A ≠ B := by
  intro heq
  exact h (congrArg HCPDisclosure.base heq)

end HCPDisclosure

variable
  {integral : IntegralStructure F}
  {payload : CochainPayloadInterpretation F}
  {PublicClass Lifecycle : Type*}
  {classify : SheafStateSnapshot F → PublicClass}
  {Binds : TCB.HCPStackBinding Lifecycle PublicClass F.C1}

/-- Release the selected HCP pair alongside the same original artifact/context view. -/
def hcpDisclosure
    (O : TCB.BoundHCPObservation integral payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32) :
    HCPDisclosure PublicClass (TotalCoord Edge F.edgeDim) where
  base := (ofHCPObservation O identify parameters).publicView
  observation := O.toObservation

/-- Forgetting the optional disclosure recovers the original storage projection. -/
theorem hcpDisclosure_forget
    (O : TCB.BoundHCPObservation integral payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32) :
    (hcpDisclosure O identify parameters).forget =
      (ofHCPObservation O identify parameters).publicView := rfl

theorem hcpDisclosure_cochain
    (O : TCB.BoundHCPObservation integral payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32) :
    (hcpDisclosure O identify parameters).base.cochain = O.artifact.cochain := rfl

theorem hcpDisclosure_leafDigest
    (O : TCB.BoundHCPObservation integral payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32) :
    (hcpDisclosure O identify parameters).base.key.cochainDigest = O.hashObject := rfl

theorem hcpDisclosure_snapshotRoot
    (O : TCB.BoundHCPObservation integral payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32) :
    (hcpDisclosure O identify parameters).base.key.snapshotRoot = O.snapshotRoot := rfl

theorem hcpDisclosure_runId
    (O : TCB.BoundHCPObservation integral payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32) :
    (hcpDisclosure O identify parameters).base.key.runId = identify O.context := rfl

theorem hcpDisclosure_observation
    (O : TCB.BoundHCPObservation integral payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32) :
    (hcpDisclosure O identify parameters).observation = O.toObservation := rfl

/-- Original artifact/header equality must accompany equality of the selected HCP pair. -/
theorem hcpDisclosure_eq_iff
    (O P : TCB.BoundHCPObservation integral payload PublicClass Lifecycle classify Binds)
    (identifyO identifyP : Lifecycle → TCB.Hash32)
    (parametersO parametersP : TCB.Hash32) :
    hcpDisclosure O identifyO parametersO = hcpDisclosure P identifyP parametersP ↔
      (ofHCPObservation O identifyO parametersO).publicView =
        (ofHCPObservation P identifyP parametersP).publicView ∧
      O.toObservation = P.toObservation :=
  HCPDisclosure.eq_iff _ _

/-- Parameter names can distinguish complete disclosures even for the identical HCP pair. -/
theorem hcpDisclosure_same_observation_distinct_parameters
    (O : TCB.BoundHCPObservation integral payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters parameters' : TCB.Hash32)
    (hne : parameters ≠ parameters') :
    (hcpDisclosure O identify parameters).observation =
        (hcpDisclosure O identify parameters').observation ∧
      hcpDisclosure O identify parameters ≠ hcpDisclosure O identify parameters' := by
  refine ⟨rfl, HCPDisclosure.ne_of_base_ne ?_⟩
  exact Context.publicView_ne_of_parameters_ne _ _ hne

end Hcrypt.Protocol.Storage
