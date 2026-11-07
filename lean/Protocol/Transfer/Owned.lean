module

public import Protocol.Evidence.TransferVerifier
public import Protocol.Transfer.Operational
public import Protocol.Storage.TransferManifest
public import Protocol.Ledger.Sheaf

@[expose] public section

/-!
# One checked owned-resource transition

The original context supplies the payload, interpretation and snapshot.
Structural resource checks and actual packet checking derive candidate validity;
validity is not an input to the operational acceptance record. The owner signs
the pre-proof intent. Proof metadata and bytes determine the evidence root,
then a block preimage without its own digest completes the proposal.

This is a fixed-epoch, fixed-snapshot public-resource-ID profile. Hash functions,
canonical byte codecs, signature/proof soundness and topology authentication
remain explicit implementation contracts. No global hash injectivity, private
nullifier scheme, runtime refinement or consensus finality is asserted.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt.Protocol.Transfer.Owned

open Sheaf CellularSheaf
open Evidence.TransferTranscript

abbrev ResourceTransfer := Ledger.OwnedResource.Transfer
abbrev ResourceChecks {Owner Asset : Type}
    (catalog : Ledger.OwnedResource.Catalog Owner Asset)
    (transfer : ResourceTransfer Owner) (before : Ledger.State ℕ ℕ) :=
  Ledger.OwnedResource.Checks catalog transfer before

variable {Vertex Edge Face Owner Asset Receipt : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}

/-- Trusted profile inputs and the original before-state/context.
Identifiers select these actual implementations; names alone do not establish
their catalog, topology, arithmetization or cryptographic correctness. -/
structure Config (F : CellularSheaf X) (Owner Asset Receipt : Type) where
  catalog : Ledger.OwnedResource.Catalog Owner Asset
  context : Storage.Context F
  before : Ledger.State ℕ ℕ
  hashes : HashSuite Owner
  metadata : ProofMetadata
  authorization : Evidence.TransferVerifier.Authorization Owner
  payload : Evidence.TransferVerifier.PayloadVerifier context.interpretation Owner metadata
  codec : Evidence.TransferVerifier.PacketCodec Owner
  topologyBinds : SheafStateSnapshot F → TCB.Hash32 → Prop
  topologyBound : topologyBinds context.interpretation.snapshot before.topologyRoot
  persisted : Storage.Context F →
    List (Storage.ManifestItem Unit (fun _ => Axioms.CochainCommitmentData)) →
    TCB.Hash32 → Receipt → Prop
  committeeDigest : TCB.Hash32
  round : ℕ
  phase : ℕ

variable {F : CellularSheaf X}

namespace Config

variable (config : Config F Owner Asset Receipt)

/-- Forget only global primitive soundness, retaining the original setup and actual algorithms. -/
def operational : Operational.Config F Owner Asset Receipt where
  catalog := config.catalog
  context := config.context
  before := config.before
  hashes := config.hashes
  metadata := config.metadata
  authorization := config.authorization.operational
  payload := config.payload.operational
  codec := config.codec.operational
  topologyBinds := config.topologyBinds
  topologyBound := config.topologyBound
  persisted := config.persisted
  committeeDigest := config.committeeDigest
  round := config.round
  phase := config.phase

/-- The exact original input leaf is sealed before proof or proposal completion. -/
def manifest := config.operational.manifest

/-- The enclosing cochain root remains distinct from its original payload leaf. -/
def cochainRoot : TCB.Hash32 := config.operational.cochainRoot

/-- All coordinates known before the signature and proof bytes are produced. -/
def draftFor (transfer : ResourceTransfer Owner) : ProposalDraft :=
  config.operational.draftFor transfer

/-- Authorize the actual transfer, source metadata and chosen policy domain. -/
def intentFor (transfer : ResourceTransfer Owner) : Intent Owner :=
  config.operational.intentFor transfer

/-- Reconstruct the exact authorization subject from an existing candidate. -/
def subject (candidate : Ledger.Candidate ℕ ℕ (CochainPayloadInterpretation F))
    (transfer : ResourceTransfer Owner) : Intent Owner :=
  config.operational.subject candidate transfer

/-- The same ownership/value/nullifier policy as the operational profile. -/
def policy [DecidableEq Asset] : Ledger.Policy ℕ ℕ Asset (CochainPayloadInterpretation F) :=
  config.operational.policy

end Config

/-- The same structural source checks as the soundness-free profile. -/
abbrev Prechecks (config : Config F Owner Asset Receipt)
    (transfer : ResourceTransfer Owner) : Prop :=
  Operational.Prechecks config.operational transfer

/-- Mathematical Boolean specification; the codec and primitive verifiers are supplied. -/
def check (config : Config F Owner Asset Receipt) (transfer : ResourceTransfer Owner)
    (bytes : List UInt8) : Bool := by
  classical
  exact decide (Prechecks config transfer) &&
    Evidence.TransferVerifier.check config.codec config.metadata (config.intentFor transfer)
      config.authorization config.payload bytes

/-- Forgetting soundness does not change the Boolean acceptance decision. -/
theorem check_eq_operational (config : Config F Owner Asset Receipt)
    (transfer : ResourceTransfer Owner) (bytes : List UInt8) :
    check config transfer bytes = Operational.check config.operational transfer bytes := rfl

/-- Actual component checks, without storing candidate validity as an assumption. -/
structure CheckedTransfer (config : Config F Owner Asset Receipt)
    (transfer : ResourceTransfer Owner) (bytes : List UInt8) where
  prechecks : Prechecks config transfer
  proof : Evidence.TransferVerifier.CheckedPacket config.codec config.metadata
    (config.intentFor transfer) config.authorization config.payload bytes

namespace CheckedTransfer

variable {config : Config F Owner Asset Receipt} {transfer : ResourceTransfer Owner}
  {bytes : List UInt8}

/-- Retain the same structural checks, bytes and parsed packet without global soundness. -/
def operational (checked : CheckedTransfer config transfer bytes) :
    Operational.CheckedTransfer config.operational transfer bytes where
  prechecks := checked.prechecks
  proof := checked.proof.operational

def ofCheck (accepted : check config transfer bytes = true) :
    CheckedTransfer config transfer bytes := by
  classical
  have checks := accepted
  simp only [check, Bool.and_eq_true_iff, decide_eq_true_eq] at checks
  exact ⟨checks.1, Evidence.TransferVerifier.CheckedPacket.ofCheck checks.2⟩

theorem check_true (checked : CheckedTransfer config transfer bytes) :
    check config transfer bytes = true := by
  classical
  simp only [check, Bool.and_eq_true_iff, decide_eq_true_eq]
  exact ⟨checked.prechecks, checked.proof.check_true⟩

/-- The action and snapshot are constructed from the original source objects. -/
def candidate (checked : CheckedTransfer config transfer bytes) :
    Ledger.Candidate ℕ ℕ (CochainPayloadInterpretation F) where
  before := config.before
  action := transfer.action config.context.cochain
  snapshot := config.context.interpretation
  proposal := config.hashes.proposal checked.proof.packet

/-- The soundness-free projection retains this exact candidate. -/
theorem operational_candidate (checked : CheckedTransfer config transfer bytes) :
    checked.operational.candidate = checked.candidate := rfl

/-- The actual parser result fixes the candidate independently of proof-witness choice. -/
theorem candidate_eq (first second : CheckedTransfer config transfer bytes) :
    first.candidate = second.candidate := by
  have packet_eq : first.proof.packet = second.proof.packet :=
    Option.some.inj (first.proof.decoded.symm.trans second.proof.decoded)
  exact congrArg (fun packet : ProofPacket Owner =>
    ({ before := config.before
       action := transfer.action config.context.cochain
       snapshot := config.context.interpretation
       proposal := config.hashes.proposal packet } :
      Ledger.Candidate ℕ ℕ (CochainPayloadInterpretation F))) packet_eq

theorem successor_eq (first second : CheckedTransfer config transfer bytes) :
    first.candidate.after = second.candidate.after :=
  congrArg Ledger.Candidate.after (first.candidate_eq second)

theorem draft_eq (checked : CheckedTransfer config transfer bytes) :
    ProposalDraft.ofProposal checked.candidate.proposal = config.draftFor transfer := by
  change checked.proof.packet.intent.draft = _
  rw [checked.proof.intent_eq]
  rfl

theorem subject_eq (checked : CheckedTransfer config transfer bytes) :
    config.subject checked.candidate transfer = config.intentFor transfer :=
  checked.operational.subject_eq

/-- Recover the ideal theorem from the same operational candidate and local semantic facts. -/
theorem valid [DecidableEq Asset] (checked : CheckedTransfer config transfer bytes) :
    checked.candidate.Valid config.policy :=
  checked.operational.valid checked.proof.authorized (checked.proof.accepted config.context rfl rfl)

theorem accepted_update [DecidableEq Asset]
    (checked : CheckedTransfer config transfer bytes) :
    Ledger.AcceptedUpdate config.policy config.before checked.candidate checked.candidate.after :=
  ⟨rfl, checked.valid, rfl⟩

theorem value_preserved [DecidableEq Asset]
    (checked : CheckedTransfer config transfer bytes) :
    config.policy.values.value checked.candidate.after.marking =
      config.policy.values.value config.before.marking :=
  checked.accepted_update.value_preserved

theorem input_consumed (checked : CheckedTransfer config transfer bytes) :
    checked.candidate.after.marking transfer.input = 0 :=
  checked.prechecks.resources.after_input rfl

theorem output_created (checked : CheckedTransfer config transfer bytes) :
    checked.candidate.after.marking transfer.output = 1 :=
  checked.prechecks.resources.after_output rfl

theorem inventory_preserved (checked : CheckedTransfer config transfer bytes)
    (before : Ledger.OwnedResource.InventoryInvariant config.before) :
    Ledger.OwnedResource.InventoryInvariant checked.candidate.after :=
  checked.prechecks.resources.preserves_inventory rfl before

theorem replay_rejected [DecidableEq Asset]
    (checked : CheckedTransfer config transfer bytes) (proposal : Consensus.ProposalRef) :
    ¬ ({ checked.candidate with
      before := checked.candidate.after
      proposal := proposal }).Valid config.policy :=
  checked.candidate.not_valid_replay config.policy checked.valid proposal

end CheckedTransfer

/-- Actual Boolean acceptance implies the existing computed-update contract. -/
theorem check_implies_accepted_update [DecidableEq Asset]
    (config : Config F Owner Asset Receipt) (transfer : ResourceTransfer Owner)
    (bytes : List UInt8) (accepted : check config transfer bytes = true) :
    Ledger.AcceptedUpdate config.policy config.before
      (CheckedTransfer.ofCheck accepted).candidate
      (CheckedTransfer.ofCheck accepted).candidate.after :=
  (CheckedTransfer.ofCheck accepted).accepted_update

end Hcrypt.Protocol.Transfer.Owned
