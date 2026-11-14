module

public import Protocol.Storage.PublicView
public import Protocol.Storage.CoupledCiphertext

@[expose] public section

/-!
# Original exact artifact and native ciphertext in one sealed manifest

This selected two-slot profile reuses the existing checkpoint engine. Its
exact-artifact leaf retains the original payload and artifact digest. Its
full-ciphertext leaf contains only the selected bytes and their separate
content digest, with a binding to the original `BoundHCPObservation`.

The public root preimage is the existing base public view and the ordered
slot/digest directory. It contains neither its own root nor the observation's
private message, opening, presentation or transport token. The supplied root
function is not assumed injective or cryptographically secure. History
authentication, availability and backend persistence retain their own
contracts. The earlier one-slot owned-transfer profile is unchanged.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Storage.NativeManifest

open Sheaf CellularSheaf HCPCoupledFamily

abbrev Bytes := List UInt8

/-- Distinct roles prevent replacement of the original exact-artifact digest. -/
inductive Slot where
  | exactArtifact
  | fullCiphertext
  deriving DecidableEq

/-- Retained semantic payloads; the public manifest view publishes only names. -/
def Payload : Slot → Type
  | .exactArtifact => Axioms.CochainCommitmentData
  | .fullCiphertext => Bytes

/-- The public root input excludes the enclosing root and every private witness. -/
abbrev PublicPreimage := PublicPayloadView × List (Slot × TCB.Hash32)

section OriginalArtifact

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

/-- Preserve the original payload and its original leaf digest. -/
def exactItem (C : Context F) : ManifestItem Slot Payload where
  slot := .exactArtifact
  payload := C.cochain
  digest := C.artifact.digest

/-- The separately named full ciphertext is represented by its actual bytes. -/
def ciphertextItem (hash : Bytes → TCB.Hash32) (bytes : Bytes) : ManifestItem Slot Payload where
  slot := .fullCiphertext
  payload := bytes
  digest := hash bytes

/-- Both roles and their ordering are part of the public root input. -/
def directory (C : Context F) (hash : Bytes → TCB.Hash32) (bytes : Bytes) :
    List (Slot × TCB.Hash32) :=
  [(.exactArtifact, C.artifact.digest), (.fullCiphertext, hash bytes)]

def preimage (C : Context F) (hash : Bytes → TCB.Hash32) (bytes : Bytes) : PublicPreimage :=
  (C.publicView, directory C hash bytes)

end OriginalArtifact

variable {rows cols : ℕ} {B : Matrix (Fin rows) (Fin cols) ℤ}
  {payload : CochainPayloadInterpretation (sheaf B)}
  {PublicClass Lifecycle : Type*}
  {classify : SheafStateSnapshot (sheaf B) → PublicClass}
  {Binds : TCB.HCPStackBinding Lifecycle PublicClass (C1 (Fin rows) (Fin cols))}
  {Receipt : Type*}

/-- A profile indexed by the actual original observation and its target context.
Full-ciphertext binding is a semantic condition checked for each stored leaf;
no caller-supplied digest is substituted for the original exact artifact. -/
def scheme (hash : Bytes → TCB.Hash32) (manifestHash : PublicPreimage → TCB.Hash32)
    (persisted : Context (sheaf B) → List (ManifestItem Slot Payload) → TCB.Hash32 → Receipt → Prop)
    (O : TCB.BoundHCPObservation (integralStructure B)
      payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32) (bytes : Bytes) :
    CheckpointScheme (sheaf B) Slot Payload Receipt where
  requiredSlots := {.exactArtifact, .fullCiphertext}
  entryBound C := fun
    | .exactArtifact, value, digest => value = C.cochain ∧ digest = C.artifact.digest
    | .fullCiphertext, value, digest => C = ofHCPObservation O identify parameters ∧ value = bytes ∧
        CoupledCiphertext.BindsObservation hash O value digest
  manifestBound C items root :=
    C = ofHCPObservation O identify parameters ∧
      items = [exactItem C, ciphertextItem hash bytes] ∧
      root = manifestHash (preimage C hash bytes)
  persisted := persisted

/-- Construct the actual two-entry seal once the selected full ciphertext is
bound to the original observation. Backend persistence is not manufactured. -/
def sealed (hash : Bytes → TCB.Hash32) (manifestHash : PublicPreimage → TCB.Hash32)
    (persisted : Context (sheaf B) → List (ManifestItem Slot Payload) → TCB.Hash32 → Receipt → Prop)
    (O : TCB.BoundHCPObservation (integralStructure B)
      payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32) (bytes : Bytes)
    (bound : CoupledCiphertext.BindsObservation hash O bytes (hash bytes)) :
    SealedManifest (scheme hash manifestHash persisted O identify parameters bytes)
      (ofHCPObservation O identify parameters) where
  manifest :=
    { entries :=
        [{ item := exactItem (ofHCPObservation O identify parameters), bound := ⟨rfl, rfl⟩ },
         { item := ciphertextItem hash bytes, bound := ⟨rfl, rfl, bound⟩ }]
      slotsNodup := by simp [exactItem, ciphertextItem] }
  root := manifestHash (preimage (ofHCPObservation O identify parameters) hash bytes)
  complete := by
    intro slot _
    cases slot <;> simp [OpenManifest.slots, exactItem, ciphertextItem]
  rootBound := ⟨rfl, rfl, rfl⟩

variable {hash : Bytes → TCB.Hash32} {manifestHash : PublicPreimage → TCB.Hash32}
  {persisted : Context (sheaf B) → List (ManifestItem Slot Payload) → TCB.Hash32 → Receipt → Prop}
  {O : TCB.BoundHCPObservation (integralStructure B)
    payload PublicClass Lifecycle classify Binds}
  {identify : Lifecycle → TCB.Hash32} {parameters : TCB.Hash32} {bytes : Bytes}
  {C : Context (sheaf B)}

/-- Every seal in this profile retains the actual observation-derived context. -/
theorem context_eq
    (M : SealedManifest (scheme hash manifestHash persisted O identify parameters bytes) C) :
    C = ofHCPObservation O identify parameters := M.rootBound.1

/-- Any actual seal has the exact ordered original-artifact/ciphertext list. -/
theorem items_eq
    (M : SealedManifest (scheme hash manifestHash persisted O identify parameters bytes) C) :
    M.manifest.items = [exactItem C, ciphertextItem hash bytes] := M.rootBound.2.1

/-- Its public base is derived from that same original observation. -/
theorem publicView_base
    (M : SealedManifest (scheme hash manifestHash persisted O identify parameters bytes) C) :
    M.publicView.base = (ofHCPObservation O identify parameters).publicView := by
  change C.publicView = _
  rw [context_eq M]

theorem publicView_directory
    (M : SealedManifest (scheme hash manifestHash persisted O identify parameters bytes) C) :
    M.publicView.directory = directory C hash bytes := by
  change M.manifest.items.map (fun item => (item.slot, item.digest)) = _
  rw [items_eq M]
  rfl

/-- The public root is computed from the selected public preimage, not itself. -/
theorem publicView_root
    (M : SealedManifest (scheme hash manifestHash persisted O identify parameters bytes) C) :
    M.publicView.root = manifestHash (preimage C hash bytes) := M.rootBound.2.2

theorem publicView_hash
    (M : SealedManifest (scheme hash manifestHash persisted O identify parameters bytes) C) :
    M.publicView.root = manifestHash (M.publicView.base, M.publicView.directory) := by
  rw [publicView_root M, publicView_directory M]
  rfl

/-- Ciphertext lookup membership is derived from the sealed object. -/
theorem ciphertext_named
    (M : SealedManifest (scheme hash manifestHash persisted O identify parameters bytes) C) :
    hash bytes ∈ M.publicView.directory.map Prod.snd := by
  rw [publicView_directory M]
  simp [directory]

/-- The exact artifact retains its original role and digest in the same seal. -/
theorem exact_named
    (M : SealedManifest (scheme hash manifestHash persisted O identify parameters bytes) C) :
    C.key.cochainDigest ∈ M.publicView.directory.map Prod.snd := by
  rw [publicView_directory M]
  simp [directory, Context.key]

/-- The full-ciphertext leaf's original-observation binding is retained by any
seal, not only the provided constructor. -/
theorem ciphertext_bound
    (M : SealedManifest (scheme hash manifestHash persisted O identify parameters bytes) C) :
    CoupledCiphertext.BindsObservation hash O bytes (hash bytes) := by
  obtain ⟨entry, _member, slotEq⟩ :=
    M.required_entry_exists Slot.fullCiphertext (by simp [scheme])
  rcases entry with ⟨⟨slot, value, digest⟩, entryBound⟩
  cases slot with
  | exactArtifact => cases slotEq
  | fullCiphertext =>
    change C = ofHCPObservation O identify parameters ∧ value = bytes ∧
      CoupledCiphertext.BindsObservation hash O value digest at entryBound
    refine ⟨?_, rfl⟩
    simpa only [entryBound.2.1] using entryBound.2.2.1

/-- An unrelated context cannot supply a seal for this original observation. -/
theorem not_of_context_ne
    (wrong : C ≠ ofHCPObservation O identify parameters) :
    ¬ Nonempty (SealedManifest (scheme hash manifestHash persisted O identify parameters bytes) C) := by
  rintro ⟨M⟩
  exact wrong (context_eq M)

/-- Canonical original sample bytes discharge the full-ciphertext binding premise. -/
def sealedSample (hash : Bytes → TCB.Hash32) (manifestHash : PublicPreimage → TCB.Hash32)
    (persisted : Context (sheaf B) → List (ManifestItem Slot Payload) → TCB.Hash32 → Receipt → Prop)
    (O : TCB.BoundHCPObservation (integralStructure B)
      payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32)
    (z : Fin cols → ℤ) (a : ℤ) (u : Fin rows → ℤ)
    (sameSample : O.encrypted = HCPCoupledEncoding.sample B z a u) :
    SealedManifest (scheme hash manifestHash persisted O identify parameters
      (CoupledCiphertext.sampleBytes B z a u)) (ofHCPObservation O identify parameters) :=
  sealed hash manifestHash persisted O identify parameters (CoupledCiphertext.sampleBytes B z a u)
    (CoupledCiphertext.sampleBytes_binds_original hash O z a u sameSample)

end HomotopicalEncryption.Protocol.Storage.NativeManifest
