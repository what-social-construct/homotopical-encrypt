module

public import Protocol.Storage.PublicStack.Release
public import Protocol.Transfer.PublicView

@[expose] public section

/-!
# Proof-bearing public stack release

The evidence object retains the chosen cell ID, the complete accepted vote
target, and the actual owned transfer packet bytes. The checked transfer
determines the original context, cochain, public packet and proposal. The
caller supplies a checked cell directory that names the transfer ciphertext.
The cell directory root and the transfer's two-slot input manifest root
address their respective formats. A reader authenticates the stack root
independently and uses the configured transfer verifier to check the packet.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.PublicStack

open TCB.PrimitiveChecks (Bytes)

/-- Public evidence for the specific cell and checked transfer. -/
structure PacketRecord where
  cellId : Nat
  target : Consensus.VoteTarget
  packetBytes : Bytes

namespace PacketRecord

open CoupledCodec (encodeNat parseNat frame parseFrame parseFrame_frame)
open Protocol.Evidence.TransferCodec (encodeVoteTargetBody parseVoteBody)

def domain : Bytes := "HODGE_PUBLIC_STACK_PACKET_V1".toUTF8.data.toList

def encodeBody (record : PacketRecord) (rest : Bytes) : Bytes :=
  encodeNat record.cellId (encodeVoteTargetBody record.target (frame record.packetBytes rest))

def parseBody (bytes : Bytes) : Option (PacketRecord × Bytes) := do
  let (cellId, rest) ← parseNat bytes
  let (target, rest) ← parseVoteBody rest
  let (packetBytes, rest) ← parseFrame rest
  some (⟨cellId, target, packetBytes⟩, rest)

@[simp]
theorem parseBody_encodeBody (record : PacketRecord) (rest : Bytes) :
    parseBody (encodeBody record rest) = some (record, rest) := by
  simp [parseBody, encodeBody, parseFrame_frame]

def encode (record : PacketRecord) : Bytes := domain ++ encodeBody record []

def decode (bytes : Bytes) : Option PacketRecord :=
  match parseBody (bytes.drop domain.length) with
  | none => none
  | some (record, rest) =>
    if rest = [] ∧ bytes = record.encode then some record else none

@[simp]
theorem decode_encode (record : PacketRecord) : decode record.encode = some record := by
  simp [decode, encode]

theorem decode_eq_some_iff (bytes : Bytes) (record : PacketRecord) :
    decode bytes = some record ↔ bytes = record.encode := by
  constructor
  · intro decoded
    unfold decode at decoded
    cases parsed : parseBody (bytes.drop domain.length) with
    | none => simp [parsed] at decoded
    | some value =>
      rcases value with ⟨other, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next canonical =>
        exact canonical.2.trans (congrArg encode (Option.some.inj decoded))
      next => contradiction
  · rintro rfl
    exact decode_encode record

theorem encode_injective : Function.Injective encode := by
  intro left right same
  have decoded := congrArg decode same
  simpa only [decode_encode, Option.some.injEq] using decoded

end PacketRecord

/-- The public values that determine a proof-bearing stack manifest. -/
structure ProofRelease where
  pin : CellDirectory.CheckpointPin
  payload : Axioms.CochainCommitmentData
  record : PacketRecord

namespace ProofRelease

def snapshot (release : ProofRelease) : Bytes := snapshotBytes release.pin.context

def cochain (release : ProofRelease) : Bytes := cochainBytes release.payload

def evidence (release : ProofRelease) : Bytes := release.record.encode

def manifest (release : ProofRelease) : Manifest :=
  Manifest.ofRecords release.pin release.snapshot release.cochain release.evidence

def rootDigest (release : ProofRelease) : Sha256.DigestBytes :=
  Sha256.digestBytes release.manifest.encode

def root (release : ProofRelease) : TCB.Hash32 := Sha256.toHash32 release.rootDigest

@[simp]
theorem manifest_pin (release : ProofRelease) : release.manifest.pin = release.pin := rfl

theorem verify_manifest (release : ProofRelease) :
    verify release.root release.manifest.encode = some ⟨release.manifest, rfl⟩ :=
  (verify_eq_some_iff _ _ _).mpr rfl

section Owned

open Sheaf CellularSheaf
open Protocol.Transfer.Owned (CheckedTransfer Config ResourceTransfer)

variable {Vertex Edge Face Asset Receipt : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}
  {config : Config F Bytes Asset Receipt} {transfer : ResourceTransfer Bytes}
  {bytes : Bytes} {directoryRoot : TCB.Hash32}

/-- Release the actual checked packet and proposal alongside its original ciphertext cell. -/
def ofChecked (directory : CellDirectory.Verified config.context.key directoryRoot)
    (checked : CheckedTransfer config transfer bytes) (cellId : Nat)
    (_named : directory.entries.lookup cellId = some (Sha256.digest config.ciphertext)) :
    ProofRelease :=
  ⟨⟨config.context.key, directoryRoot⟩, config.context.cochain,
    ⟨cellId, ⟨config.hashes.proposal checked.proof.packet, .Valid⟩, bytes⟩⟩

/-- The release retains the exact checked public inputs, packet, proposal and ciphertext name. -/
theorem ofChecked_bound (directory : CellDirectory.Verified config.context.key directoryRoot)
    (checked : CheckedTransfer config transfer bytes) (cellId : Nat)
    (named : directory.entries.lookup cellId = some (Sha256.digest config.ciphertext)) :
    let release := ofChecked directory checked cellId named
    release.manifest.pin = ⟨config.context.key, directoryRoot⟩ ∧
      release.snapshot = snapshotBytes config.context.key ∧
      release.cochain = cochainBytes config.context.cochain ∧
      checked.publicView.base = config.context.publicView ∧
      release.record.target = ⟨checked.candidate.proposal, .Valid⟩ ∧
      release.record.packetBytes = bytes ∧
      release.record.packetBytes = config.codec.encode checked.publicView.packet ∧
      config.codec.decode release.record.packetBytes = some checked.publicView.packet ∧
      release.record.target.proposal = config.hashes.proposal checked.publicView.packet ∧
      directory.entries.lookup release.record.cellId = some (Sha256.digest config.ciphertext) :=
  ⟨rfl, rfl, rfl, checked.publicView_base, rfl, checked.publicView_bytes,
    checked.publicView_canonical, checked.publicView_decoded, checked.publicView_proposal_computed,
    named⟩

end Owned

end ProofRelease

end HomotopicalEncryption.Protocol.Storage.PublicStack
