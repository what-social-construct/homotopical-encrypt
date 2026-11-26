module

public import Protocol.Storage.Anchor
public import Protocol.Storage.CellDirectory

@[expose] public section

/-!
# Checkpoint pins for cell directories

The reader supplies the expected snapshot context and cell directory root
from trusted input. The stored checkpoint bytes must match that pin exactly.
An existing transition anchor gives a pin for its actual seal when the seal
uses the canonical cell directory digest.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.CellDirectory

open TCB.PrimitiveChecks (Bytes)
open Protocol.Ephemeral.ScopeCodec (encodeFixed encodeKey parseFixed parseKey)

/-- The public names the reader expects for this accepted snapshot checkpoint. -/
structure CheckpointPin where
  context : ContextKey
  directoryRoot : TCB.Hash32

namespace CheckpointPin

/-- Versioned ASCII domain for a checkpoint naming one cell directory. -/
def domain : Bytes := "HODGE_CELL_CHECKPOINT_V1".toUTF8.data.toList

def encode (pin : CheckpointPin) : Bytes :=
  domain ++ encodeKey pin.context (encodeFixed pin.directoryRoot [])

/-- Check the stored bytes against the separately supplied expected pin. -/
def check (pin : CheckpointPin) (bytes : Bytes) : Bool := decide (bytes = pin.encode)

@[simp]
theorem check_iff (pin : CheckpointPin) (bytes : Bytes) :
    pin.check bytes = true ↔ bytes = pin.encode := by
  simp [check]

private def parseEncoded (bytes : Bytes) : Option (CheckpointPin × Bytes) := do
  let (context, rest) ← parseKey (bytes.drop domain.length)
  let (directoryRoot, rest) ← parseFixed 32 rest
  some (⟨context, directoryRoot⟩, rest)

private theorem parseEncoded_encode (pin : CheckpointPin) :
    parseEncoded pin.encode = some (pin, []) := by
  cases pin
  simp [parseEncoded, encode]

theorem encode_injective : Function.Injective encode := by
  intro pin other same
  have parsed := congrArg parseEncoded same
  simpa only [parseEncoded_encode, Option.some.injEq, Prod.mk.injEq, and_true] using parsed

section Anchored

open Sheaf CellularSheaf

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}
  {Resource Nullifier Asset : Type} [DecidableEq Nullifier]
  {Payload : ℕ → Type*} {Receipt : Type*}
  {runtime : TCB.RuntimeBoundary}
  {policy : Ledger.Policy Resource Nullifier Asset (CochainPayloadInterpretation F)}
  {bindings : Evidence.RootBindings Resource Nullifier (CochainPayloadInterpretation F)}
  {candidate : Ledger.Candidate Resource Nullifier (CochainPayloadInterpretation F)}
  {scheme : CheckpointScheme F ℕ Payload Receipt} {C : Context F}
  {manifest : SealedManifest scheme C}
  {topologyBinds : SheafStateSnapshot F → TCB.Hash32 → Prop}
  {history : HistoryBindings F Resource Nullifier ℕ Payload}
  {evidence : Evidence.Transition runtime policy bindings candidate}

/-- Project the exact context and canonical directory root of the anchored seal. -/
def ofAnchor (_anchor : TransitionAnchor topologyBinds history evidence C manifest)
    (_directoryBinding : Sha256.digest (Codec.encode C.key manifest.publicView.directory) =
      manifest.root) : CheckpointPin :=
  ⟨C.key, manifest.root⟩

/-- The canonical bytes of the actual anchored seal verify at its projected pin. -/
theorem ofAnchor_verify (anchor : TransitionAnchor topologyBinds history evidence C manifest)
    (directoryBinding : Sha256.digest (Codec.encode C.key manifest.publicView.directory) =
      manifest.root) :
    let pin := ofAnchor anchor directoryBinding
    ∃ checked : Verified pin.context pin.directoryRoot,
      verify pin.context pin.directoryRoot (Codec.encode C.key manifest.publicView.directory) =
        some checked ∧ checked.entries = manifest.publicView.directory := by
  let checked : Verified C.key manifest.root :=
    ⟨manifest.publicView.directory, manifest.publicView_directory_slots_nodup, directoryBinding⟩
  exact ⟨checked, (verify_eq_some_iff _ _ _ _).mpr rfl, rfl⟩

end Anchored

end CheckpointPin

end HomotopicalEncryption.Protocol.Storage.CellDirectory
