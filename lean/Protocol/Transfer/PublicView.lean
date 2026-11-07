module

public import Protocol.Transfer.Owned

@[expose] public section

/-!
# The released record of one checked owned-resource transfer

This projection retains the actual canonical packet bytes, parsed packet,
complete proposal and original one-input manifest view. The packet includes
the public resource/signer identifiers, verifier metadata, original public
cochain/context input, signature bytes and proof bytes. Its carrier contains
no private interpretation, harmonic message, opening or semantic proposition.

The record is a specified transfer release, not a complete network transcript.
Public setup, available prior-state data, catalog access, auxiliary information
and access metadata must be declared separately by an experiment. No hiding
claim follows from omitting private witness fields. In particular, equality of
the selected HCP pair does not supply equality of this larger record.

The exact distinguishers below read released identifiers directly; they use
neither hash inversion nor any assumption about a private Hodge presentation.
The input equality test is deterministic. No randomized privacy experiment,
cryptographic advantage bound or complete wire codec is asserted here.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt.Protocol.Transfer.Owned

open Sheaf CellularSheaf
open Evidence.TransferTranscript

/-- Actual released values of the bounded transfer, without private semantics. -/
structure PublicTransferView (Owner : Type) where
  packetBytes : List UInt8
  packet : ProofPacket Owner
  proposal : Consensus.ProposalRef
  manifest : Storage.PublicManifestView Unit

namespace PublicTransferView

variable {Owner : Type}

@[ext]
theorem ext {left right : PublicTransferView Owner}
    (bytes : left.packetBytes = right.packetBytes)
    (packet : left.packet = right.packet)
    (proposal : left.proposal = right.proposal)
    (manifest : left.manifest = right.manifest) : left = right := by
  cases left
  cases right
  cases bytes
  cases packet
  cases proposal
  cases manifest
  rfl

/-- Equality includes all released coordinates, not only a selected HCP input. -/
theorem eq_iff (left right : PublicTransferView Owner) :
    left = right ↔ left.packetBytes = right.packetBytes ∧
      left.packet = right.packet ∧ left.proposal = right.proposal ∧
      left.manifest = right.manifest := by
  constructor
  · rintro rfl
    exact ⟨rfl, rfl, rfl, rfl⟩
  · rintro ⟨bytes, packet, proposal, manifest⟩
    exact ext bytes packet proposal manifest

def transfer (view : PublicTransferView Owner) : ResourceTransfer Owner :=
  view.packet.intent.transfer

def base (view : PublicTransferView Owner) : Storage.PublicPayloadView :=
  view.packet.intent.base

def metadata (view : PublicTransferView Owner) : ProofMetadata :=
  view.packet.metadata

/-- The public-ID profile determines its singleton nullifier from the input. -/
def nullifiers (view : PublicTransferView Owner) : List ℕ := [view.transfer.input]

theorem ne_of_packetBytes_ne {left right : PublicTransferView Owner}
    (different : left.packetBytes ≠ right.packetBytes) : left ≠ right := by
  intro same
  exact different (congrArg PublicTransferView.packetBytes same)

theorem ne_of_transfer_ne {left right : PublicTransferView Owner}
    (different : left.transfer ≠ right.transfer) : left ≠ right := by
  intro same
  exact different (congrArg transfer same)

theorem ne_of_input_ne {left right : PublicTransferView Owner}
    (different : left.transfer.input ≠ right.transfer.input) : left ≠ right := by
  intro same
  exact different (congrArg (fun view => view.transfer.input) same)

theorem ne_of_output_ne {left right : PublicTransferView Owner}
    (different : left.transfer.output ≠ right.transfer.output) : left ≠ right := by
  intro same
  exact different (congrArg (fun view => view.transfer.output) same)

theorem ne_of_signer_ne {left right : PublicTransferView Owner}
    (different : left.transfer.signer ≠ right.transfer.signer) : left ≠ right := by
  intro same
  exact different (congrArg (fun view => view.transfer.signer) same)

theorem ne_of_metadata_ne {left right : PublicTransferView Owner}
    (different : left.metadata ≠ right.metadata) : left ≠ right := by
  intro same
  exact different (congrArg metadata same)

theorem ne_of_base_ne {left right : PublicTransferView Owner}
    (different : left.base ≠ right.base) : left ≠ right := by
  intro same
  exact different (congrArg base same)

theorem ne_of_proposal_ne {left right : PublicTransferView Owner}
    (different : left.proposal ≠ right.proposal) : left ≠ right := by
  intro same
  exact different (congrArg PublicTransferView.proposal same)

theorem ne_of_manifest_ne {left right : PublicTransferView Owner}
    (different : left.manifest ≠ right.manifest) : left ≠ right := by
  intro same
  exact different (congrArg PublicTransferView.manifest same)

/-- An exact equality test on the released public resource identifier. -/
def inputTest (expected : ℕ) (view : PublicTransferView Owner) : Bool :=
  decide (view.transfer.input = expected)

/-- Two different public input IDs are separated with no access to a witness. -/
theorem inputTest_distinguishes (left right : PublicTransferView Owner)
    (different : left.transfer.input ≠ right.transfer.input) :
    inputTest left.transfer.input left = true ∧
      inputTest left.transfer.input right = false := by
  constructor
  · simp [inputTest]
  · simp [inputTest, Ne.symm different]

end PublicTransferView

variable {Vertex Edge Face Owner Asset Receipt : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

namespace CheckedTransfer

variable {config : Config F Owner Asset Receipt} {transfer : ResourceTransfer Owner}
  {bytes : List UInt8}

/-- Release this actual checked packet, final proposal and original input seal. -/
def publicView (checked : CheckedTransfer config transfer bytes) : PublicTransferView Owner where
  packetBytes := bytes
  packet := checked.proof.packet
  proposal := checked.candidate.proposal
  manifest := config.manifest.publicView

theorem publicView_bytes (checked : CheckedTransfer config transfer bytes) :
    checked.publicView.packetBytes = bytes := rfl

theorem publicView_decoded (checked : CheckedTransfer config transfer bytes) :
    config.codec.decode checked.publicView.packetBytes = some checked.publicView.packet :=
  checked.proof.decoded

theorem publicView_canonical (checked : CheckedTransfer config transfer bytes) :
    checked.publicView.packetBytes = config.codec.encode checked.publicView.packet :=
  checked.proof.canonical

theorem publicView_intent (checked : CheckedTransfer config transfer bytes) :
    checked.publicView.packet.intent = config.intentFor transfer := checked.proof.intent_eq

theorem publicView_transfer (checked : CheckedTransfer config transfer bytes) :
    checked.publicView.transfer = transfer :=
  congrArg Intent.transfer checked.proof.intent_eq

theorem publicView_metadata (checked : CheckedTransfer config transfer bytes) :
    checked.publicView.metadata = config.metadata := checked.proof.metadata_eq

theorem publicView_base (checked : CheckedTransfer config transfer bytes) :
    checked.publicView.base = config.context.publicView :=
  congrArg Intent.base checked.proof.intent_eq

theorem publicView_manifest (checked : CheckedTransfer config transfer bytes) :
    checked.publicView.manifest = config.manifest.publicView := rfl

theorem publicView_manifest_base (checked : CheckedTransfer config transfer bytes) :
    checked.publicView.manifest.base = checked.publicView.base := by
  rw [checked.publicView_base]
  rfl

theorem publicView_manifest_root (checked : CheckedTransfer config transfer bytes) :
    checked.publicView.manifest.root = checked.publicView.packet.intent.manifestRoot := by
  rw [checked.publicView_intent]
  rfl

theorem publicView_manifest_directory (checked : CheckedTransfer config transfer bytes) :
    checked.publicView.manifest.directory = [((), config.context.artifact.digest)] := rfl

theorem publicView_proposal (checked : CheckedTransfer config transfer bytes) :
    checked.publicView.proposal = checked.candidate.proposal := rfl

theorem publicView_proposal_computed (checked : CheckedTransfer config transfer bytes) :
    checked.publicView.proposal = config.hashes.proposal checked.publicView.packet := rfl

theorem publicView_proposal_draft (checked : CheckedTransfer config transfer bytes) :
    ProposalDraft.ofProposal checked.publicView.proposal =
      checked.publicView.packet.intent.draft := rfl

theorem publicView_source_evidence (checked : CheckedTransfer config transfer bytes) :
    checked.publicView.packet.intent.beforeEvidenceRoot = config.before.evidenceRoot :=
  congrArg Intent.beforeEvidenceRoot checked.proof.intent_eq

/-- The released nullifier is precisely the one consumed by the actual candidate. -/
theorem publicView_nullifiers (checked : CheckedTransfer config transfer bytes) :
    checked.publicView.nullifiers = checked.candidate.action.nullifiers := by
  change [checked.proof.packet.intent.transfer.input] = [transfer.input]
  rw [checked.proof.intent_eq]
  rfl

/-- Rechoosing check witnesses for identical input bytes changes no released value. -/
theorem publicView_eq (first second : CheckedTransfer config transfer bytes) :
    first.publicView = second.publicView := by
  apply PublicTransferView.ext
  · rfl
  · exact Option.some.inj (first.proof.decoded.symm.trans second.proof.decoded)
  · exact congrArg Ledger.Candidate.proposal (first.candidate_eq second)
  · rfl

end CheckedTransfer

end Hcrypt.Protocol.Transfer.Owned
