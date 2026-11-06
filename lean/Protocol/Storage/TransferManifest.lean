module

public import Protocol.Evidence.TransferTranscript
public import Protocol.Storage.Checkpoint
public import Protocol.Storage.PublicView

@[expose] public section

/-!
# The original input manifest of one owned-resource transition

This bounded manifest retains exactly the original cochain payload and its
original artifact digest in one unit slot. Its public preimage consists of
the existing base view and that slot/digest directory. Neither a current
candidate, proof packet nor enclosing root occurs in the leaf payload.

The root is computed by the supplied typed hash suite. No hash injectivity,
canonical-byte security or persistence is inferred. In particular, alignment
of the artifact digest with the suite's cochain hash remains a separate
profile check. Backend persistence uses an actual matching receipt under
the supplied object-indexed backend relation. This is not the six-stage
projection manifest or a durability implementation.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt.Protocol.Storage.TransferManifest

open Sheaf CellularSheaf

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}
  {Owner : Type} {Receipt : Type*}

/-- The only leaf uses the original payload and original artifact digest. -/
def inputItem (C : Context F) :
    ManifestItem Unit (fun _ => Axioms.CochainCommitmentData) where
  slot := ()
  payload := C.cochain
  digest := C.artifact.digest

/-- Public data prepared before later proof/evidence/block digests exist. -/
def preimage (C : Context F) : Evidence.TransferTranscript.ManifestPreimage where
  base := C.publicView
  directory := [((), C.artifact.digest)]

/-- Exact-object sealing, with backend persistence kept as its supplied relation. -/
def scheme (hashes : Evidence.TransferTranscript.HashSuite Owner)
    (persisted : Context F →
      List (ManifestItem Unit (fun _ => Axioms.CochainCommitmentData)) →
      TCB.Hash32 → Receipt → Prop) :
    CheckpointScheme F Unit (fun _ => Axioms.CochainCommitmentData) Receipt where
  requiredSlots := {()}
  entryBound C _ payload digest := payload = C.cochain ∧ digest = C.artifact.digest
  manifestBound C items root :=
    items = [inputItem C] ∧ root = hashes.manifest (preimage C)
  persisted := persisted

/-- Construct the exact one-entry seal without constructing any backend receipt. -/
def sealed (hashes : Evidence.TransferTranscript.HashSuite Owner)
    (persisted : Context F →
      List (ManifestItem Unit (fun _ => Axioms.CochainCommitmentData)) →
      TCB.Hash32 → Receipt → Prop) (C : Context F) :
    SealedManifest (scheme hashes persisted) C where
  manifest :=
    { entries := [{ item := inputItem C, bound := ⟨rfl, rfl⟩ }]
      slotsNodup := by simp }
  root := hashes.manifest (preimage C)
  complete := by
    intro slot _
    cases slot
    simp [OpenManifest.slots, inputItem]
  rootBound := ⟨rfl, rfl⟩

variable (hashes : Evidence.TransferTranscript.HashSuite Owner)
  (persisted : Context F →
    List (ManifestItem Unit (fun _ => Axioms.CochainCommitmentData)) →
    TCB.Hash32 → Receipt → Prop) (C : Context F)

/-- The retained list is exactly the original input leaf. -/
theorem sealed_items :
    (sealed hashes persisted C).manifest.items = [inputItem C] := rfl

theorem sealed_root :
    (sealed hashes persisted C).root = hashes.manifest (preimage C) := rfl

/-- The public release retains that same base, computed root and ordered directory. -/
theorem sealed_publicView :
    (sealed hashes persisted C).publicView =
      { base := C.publicView
        root := hashes.manifest (preimage C)
        directory := [((), C.artifact.digest)] } := rfl

theorem sealed_publicView_base :
    (sealed hashes persisted C).publicView.base = C.publicView := rfl

theorem sealed_publicView_root :
    (sealed hashes persisted C).publicView.root =
      hashes.manifest (preimage C) := rfl

theorem sealed_publicView_directory :
    (sealed hashes persisted C).publicView.directory =
      [((), C.artifact.digest)] := rfl

/-- The published view gives back the exact preimage without including its root. -/
theorem sealed_publicView_preimage :
    Evidence.TransferTranscript.ManifestPreimage.ofView
      (sealed hashes persisted C).publicView = preimage C := rfl

/-- Durability follows only from a receipt for this exact context, list and root. -/
theorem persisted_of_receipt
    (receipt : PersistenceReceipt (sealed hashes persisted C)) :
    persisted C [inputItem C] (hashes.manifest (preimage C)) receipt.receipt :=
  receipt.persisted

end Hcrypt.Protocol.Storage.TransferManifest
