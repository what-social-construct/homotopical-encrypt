module

public import Protocol.Storage.PublicStack.Manifest
public import Protocol.Evidence.TransferCodec

@[expose] public section

/-!
# Release of an accepted public sheaf stack

The snapshot descriptor serializes the public context key. The cochain bytes
serialize its original public payload. The evidence entry records the complete
proposal and its acceptance verdict as a vote target. Signatures, witnesses,
and private presentation material are outside this release profile.

The transition anchor authorizes the context and directory. The stack root
commits the resulting public release and is a separate name from the existing
proposal block digest. Readers receive the expected stack root from trusted
input.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.PublicStack

open TCB.PrimitiveChecks (Bytes)
open Protocol.Ephemeral.ScopeCodec (encodeKey)
open Protocol.Evidence.TransferCodec (encodePayload encodeVoteTarget)

/-- The versioned public snapshot descriptor for this storage context. -/
def snapshotBytes (key : ContextKey) : Bytes :=
  "HODGE_PUBLIC_SNAPSHOT_V1".toUTF8.data.toList ++ encodeKey key []

/-- Canonical bytes of the original published cochain payload. -/
def cochainBytes (cochain : Axioms.CochainCommitmentData) : Bytes :=
  encodePayload cochain []

/-- The public vote target records the proposal and verdict. -/
def evidenceBytes (target : Consensus.VoteTarget) : Bytes := encodeVoteTarget target

/-- Address the three public records alongside their pinned directory. -/
def Manifest.ofRecords (pin : CellDirectory.CheckpointPin)
    (snapshot cochain evidence : Bytes) : Manifest :=
  let snapshotDigest := Sha256.digestBytes snapshot
  let cochainDigest := Sha256.digestBytes cochain
  let evidenceDigest := Sha256.digestBytes evidence
  { context := pin.context
    directoryRoot := pin.directoryRoot
    snapshotAddress := Sha256.toHash32 snapshotDigest
    cochainAddress := Sha256.toHash32 cochainDigest
    evidenceAddress := Sha256.toHash32 evidenceDigest }

/-- The selected public values used to compute the byte objects and manifest. -/
structure Release where
  pin : CellDirectory.CheckpointPin
  payload : Axioms.CochainCommitmentData
  target : Consensus.VoteTarget

namespace Release

/-- Assemble a release from selected public values. Its caller authenticates the root. -/
def ofPublic (pin : CellDirectory.CheckpointPin) (cochain : Axioms.CochainCommitmentData)
    (target : Consensus.VoteTarget) : Release := ⟨pin, cochain, target⟩

def snapshot (release : Release) : Bytes := snapshotBytes release.pin.context

def cochain (release : Release) : Bytes := cochainBytes release.payload

def evidence (release : Release) : Bytes := evidenceBytes release.target

def manifest (release : Release) : Manifest :=
  Manifest.ofRecords release.pin release.snapshot release.cochain release.evidence

/-- Compute the root bytes once for clients that compare or transmit the root. -/
def rootDigest (release : Release) : Sha256.DigestBytes :=
  Sha256.digestBytes release.manifest.encode

def root (release : Release) : TCB.Hash32 := Sha256.toHash32 release.rootDigest

@[simp]
theorem manifest_pin (release : Release) : release.manifest.pin = release.pin := rfl

theorem verify_manifest (release : Release) :
    verify release.root release.manifest.encode = some ⟨release.manifest, rfl⟩ :=
  (verify_eq_some_iff _ _ _).mpr rfl

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
  {sealedManifest : SealedManifest scheme C}
  {topologyBinds : SheafStateSnapshot F → TCB.Hash32 → Prop}
  {history : HistoryBindings F Resource Nullifier ℕ Payload}
  {transition : Evidence.Transition runtime policy bindings candidate}

/-- Release the original cochain and accepted proposal with the actual anchored directory. -/
def ofAnchor (anchor : TransitionAnchor topologyBinds history transition C sealedManifest)
    (directoryBinding :
      Sha256.digest (CellDirectory.Codec.encode C.key sealedManifest.publicView.directory) =
        sealedManifest.root) :
    Release :=
  ofPublic (CellDirectory.CheckpointPin.ofAnchor anchor directoryBinding) C.cochain
    ⟨candidate.proposal, .Valid⟩

/-- The released addresses refer to the same context, payload, and accepted history entry. -/
theorem ofAnchor_bound
    (anchor : TransitionAnchor topologyBinds history transition C sealedManifest)
    (directoryBinding :
      Sha256.digest (CellDirectory.Codec.encode C.key sealedManifest.publicView.directory) =
        sealedManifest.root) :
    let release := ofAnchor anchor directoryBinding
    release.snapshot = snapshotBytes C.key ∧
      release.cochain = cochainBytes candidate.action.cochain ∧
      release.evidence = evidenceBytes ⟨candidate.proposal, .Valid⟩ ∧
      candidate.proposal.snapshotRoot = release.manifest.context.snapshotRoot ∧
      history.manifestIncluded candidate C sealedManifest.manifest.items
        release.manifest.directoryRoot candidate.proposal.blockDigest ∧ C.Accepted :=
  ⟨rfl, congrArg cochainBytes anchor.cochain_matches.symm, rfl,
    anchor.snapshot_root_matches, anchor.manifestIncluded, anchor.accepted⟩

end Anchored

end Release

end HomotopicalEncryption.Protocol.Storage.PublicStack
