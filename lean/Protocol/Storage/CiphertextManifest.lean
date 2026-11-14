module

public import Protocol.Storage.PublicView

@[expose] public section

/-!
# The canonical exact-artifact/full-ciphertext manifest

This two-slot profile reuses the existing checkpoint engine for every original
storage context. The exact leaf retains its original payload and digest; the
full-ciphertext leaf records selected bytes and their separately computed hash.
The public root input contains only the base view and ordered slot/digest
directory, excluding the enclosing root and private semantic witnesses.

Sealing is deliberately independent of full-ciphertext validity. Arbitrary
bytes, including malformed ciphertexts, remain representable. A separate
original-observation certificate supplies native decoding and message meaning.
Hash security, history authentication and backend persistence are not inferred
from this raw profile. Distinct slot roles do not require distinct hash values.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Storage.CiphertextManifest

open Sheaf CellularSheaf

abbrev Bytes := List UInt8

/-- The two public roles of the original exact artifact and the full ciphertext. -/
inductive Slot where
  | exactArtifact
  | fullCiphertext
  deriving DecidableEq

/-- Retained payloads; the public view publishes only their slot/digest names. -/
def Payload : Slot → Type
  | .exactArtifact => Axioms.CochainCommitmentData
  | .fullCiphertext => Bytes

/-- The one public root input used by storage and the transfer transcript. -/
abbrev PublicPreimage := PublicPayloadView × List (Slot × TCB.Hash32)

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}
  {Receipt : Type*}

/-- Preserve the original exact payload and its original artifact digest. -/
def exactItem (C : Context F) : ManifestItem Slot Payload where
  slot := .exactArtifact
  payload := C.cochain
  digest := C.artifact.digest

/-- The selected full ciphertext has a distinct byte/hash role. -/
def ciphertextItem (hash : Bytes → TCB.Hash32) (bytes : Bytes) : ManifestItem Slot Payload where
  slot := .fullCiphertext
  payload := bytes
  digest := hash bytes

def directory (C : Context F) (hash : Bytes → TCB.Hash32) (bytes : Bytes) :
    List (Slot × TCB.Hash32) :=
  [(.exactArtifact, C.artifact.digest), (.fullCiphertext, hash bytes)]

def preimage (C : Context F) (hash : Bytes → TCB.Hash32) (bytes : Bytes) : PublicPreimage :=
  (C.publicView, directory C hash bytes)

/-- Raw two-slot storage: byte naming is separate from semantic validation. -/
def scheme (hash : Bytes → TCB.Hash32) (manifestHash : PublicPreimage → TCB.Hash32)
    (persisted : Context F → List (ManifestItem Slot Payload) → TCB.Hash32 → Receipt → Prop)
    (bytes : Bytes) : CheckpointScheme F Slot Payload Receipt where
  requiredSlots := {.exactArtifact, .fullCiphertext}
  entryBound C := fun
    | .exactArtifact, value, digest => value = C.cochain ∧ digest = C.artifact.digest
    | .fullCiphertext, value, digest => value = bytes ∧ digest = hash bytes
  manifestBound C items root :=
    items = [exactItem C, ciphertextItem hash bytes] ∧
      root = manifestHash (preimage C hash bytes)
  persisted := persisted

/-- Construct the exact raw seal for any selected ciphertext bytes. -/
def sealed (hash : Bytes → TCB.Hash32) (manifestHash : PublicPreimage → TCB.Hash32)
    (persisted : Context F → List (ManifestItem Slot Payload) → TCB.Hash32 → Receipt → Prop)
    (C : Context F) (bytes : Bytes) :
    SealedManifest (scheme hash manifestHash persisted bytes) C where
  manifest :=
    { entries :=
        [{ item := exactItem C, bound := ⟨rfl, rfl⟩ },
         { item := ciphertextItem hash bytes, bound := ⟨rfl, rfl⟩ }]
      slotsNodup := by simp [exactItem, ciphertextItem] }
  root := manifestHash (preimage C hash bytes)
  complete := by
    intro slot _
    cases slot <;> simp [OpenManifest.slots, exactItem, ciphertextItem]
  rootBound := ⟨rfl, rfl⟩

variable {hash : Bytes → TCB.Hash32} {manifestHash : PublicPreimage → TCB.Hash32}
  {persisted : Context F → List (ManifestItem Slot Payload) → TCB.Hash32 → Receipt → Prop}
  {bytes : Bytes} {C : Context F}

/-- Every seal in this profile retains the exact ordered two-entry list. -/
theorem items_eq (M : SealedManifest (scheme hash manifestHash persisted bytes) C) :
    M.manifest.items = [exactItem C, ciphertextItem hash bytes] := M.rootBound.1

theorem publicView_base (M : SealedManifest (scheme hash manifestHash persisted bytes) C) :
    M.publicView.base = C.publicView := rfl

theorem publicView_directory (M : SealedManifest (scheme hash manifestHash persisted bytes) C) :
    M.publicView.directory = directory C hash bytes := by
  change M.manifest.items.map (fun item => (item.slot, item.digest)) = _
  rw [items_eq M]
  rfl

theorem publicView_root (M : SealedManifest (scheme hash manifestHash persisted bytes) C) :
    M.publicView.root = manifestHash (preimage C hash bytes) := M.rootBound.2

theorem publicView_hash (M : SealedManifest (scheme hash manifestHash persisted bytes) C) :
    M.publicView.root = manifestHash (M.publicView.base, M.publicView.directory) := by
  rw [publicView_root M, publicView_directory M]
  rfl

/-- Directory membership follows from the raw seal, independently of decoding. -/
theorem ciphertext_named (M : SealedManifest (scheme hash manifestHash persisted bytes) C) :
    hash bytes ∈ M.publicView.directory.map Prod.snd := by
  rw [publicView_directory M]
  simp [directory]

theorem exact_named (M : SealedManifest (scheme hash manifestHash persisted bytes) C) :
    C.key.cochainDigest ∈ M.publicView.directory.map Prod.snd := by
  rw [publicView_directory M]
  simp [directory, Context.key]

/-- The constructed seal exposes the same base/root/ordered names. -/
theorem sealed_publicView (hash : Bytes → TCB.Hash32)
    (manifestHash : PublicPreimage → TCB.Hash32)
    (persisted : Context F → List (ManifestItem Slot Payload) → TCB.Hash32 → Receipt → Prop)
    (C : Context F) (bytes : Bytes) :
    (sealed hash manifestHash persisted C bytes).publicView =
      { base := C.publicView
        root := manifestHash (preimage C hash bytes)
        directory := directory C hash bytes } := rfl

/-- Durability still requires a receipt for this exact context, list and root. -/
theorem persisted_of_receipt
    (M : SealedManifest (scheme hash manifestHash persisted bytes) C)
    (receipt : PersistenceReceipt M) :
    persisted C M.manifest.items M.root receipt.receipt := receipt.persisted

end HomotopicalEncryption.Protocol.Storage.CiphertextManifest
