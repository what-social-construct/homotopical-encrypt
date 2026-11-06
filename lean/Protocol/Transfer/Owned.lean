module

public import Protocol.Evidence.TransferVerifier
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

/-- The exact original input leaf is sealed before proof or proposal completion. -/
def manifest := Storage.TransferManifest.sealed config.hashes config.persisted config.context

/-- The enclosing cochain root remains distinct from its original payload leaf. -/
def cochainRoot : TCB.Hash32 := config.hashes.cochainRoot [config.context.artifact.digest]

/-- All coordinates known before the signature and proof bytes are produced. -/
def draftFor (transfer : ResourceTransfer Owner) : ProposalDraft where
  committeeDigest := config.committeeDigest
  epoch := config.before.epoch
  height := config.before.height + 1
  round := config.round
  phase := config.phase
  parentDigest := config.before.tipHash
  beforeStateRoot := config.hashes.state (StateContent.ofState config.before)
  afterStateRoot := config.hashes.state
    (StateContent.afterFor config.before (transfer.action config.context.cochain)
      config.cochainRoot)
  snapshotRoot := config.context.interpretation.snapshot.root
  topologyRoot := config.before.topologyRoot
  cochainRoot := config.cochainRoot

/-- The owner authorizes the actual transfer, source metadata and chosen policy domain. -/
def intentFor (transfer : ResourceTransfer Owner) : Intent Owner where
  schemaVersion := config.metadata.schemaVersion
  statementId := config.metadata.statementId
  policyId := config.metadata.policyId
  transfer := transfer
  base := config.context.publicView
  beforeEvidenceRoot := config.before.evidenceRoot
  draft := config.draftFor transfer
  manifestRoot := config.manifest.root

/-- Reconstruct the exact authorization subject from an existing candidate. -/
def subject (candidate : Ledger.Candidate ℕ ℕ (CochainPayloadInterpretation F))
    (transfer : ResourceTransfer Owner) : Intent Owner where
  schemaVersion := config.metadata.schemaVersion
  statementId := config.metadata.statementId
  policyId := config.metadata.policyId
  transfer := transfer
  base := config.context.publicView
  beforeEvidenceRoot := candidate.before.evidenceRoot
  draft := ProposalDraft.ofProposal candidate.proposal
  manifestRoot := config.manifest.root

/-- A concrete ownership/value/nullifier policy using the existing snapshot semantics. -/
def policy [DecidableEq Asset] : Ledger.Policy ℕ ℕ Asset (CochainPayloadInterpretation F) where
  values := Ledger.OwnedResource.values config.catalog
  snapshots := Ledger.SnapshotModel.ofSheaf F config.topologyBinds
  authorized candidate := ∃ transfer : ResourceTransfer Owner,
    candidate.action = transfer.action config.context.cochain ∧
    candidate.snapshot = config.context.interpretation ∧
    ResourceChecks config.catalog transfer candidate.before ∧
    config.authorization.Authorized transfer.signer (config.subject candidate transfer)

end Config

/-- Structural checks and explicit source snapshot/hash alignment.
Topology authentication is already an indexed trusted input of `Config`. -/
structure Prechecks (config : Config F Owner Asset Receipt)
    (transfer : ResourceTransfer Owner) : Prop where
  resources : ResourceChecks config.catalog transfer config.before
  snapshotMatches : config.context.interpretation.snapshot.root = config.before.snapshotRoot
  leafMatches : config.context.artifact.digest = config.hashes.cochain config.context.cochain

/-- Mathematical Boolean specification; the codec and primitive verifiers are supplied. -/
def check (config : Config F Owner Asset Receipt) (transfer : ResourceTransfer Owner)
    (bytes : List UInt8) : Bool := by
  classical
  exact decide (Prechecks config transfer) &&
    Evidence.TransferVerifier.check config.codec config.metadata (config.intentFor transfer)
      config.authorization config.payload bytes

/-- Actual component checks, without storing candidate validity as an assumption. -/
structure CheckedTransfer (config : Config F Owner Asset Receipt)
    (transfer : ResourceTransfer Owner) (bytes : List UInt8) where
  prechecks : Prechecks config transfer
  proof : Evidence.TransferVerifier.CheckedPacket config.codec config.metadata
    (config.intentFor transfer) config.authorization config.payload bytes

namespace CheckedTransfer

variable {config : Config F Owner Asset Receipt} {transfer : ResourceTransfer Owner}
  {bytes : List UInt8}

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
    config.subject checked.candidate transfer = config.intentFor transfer := by
  unfold Config.subject
  rw [checked.draft_eq]
  rfl

/-- Local checks plus indexed primitive soundness derive the existing concrete validity. -/
theorem valid [DecidableEq Asset] (checked : CheckedTransfer config transfer bytes) :
    checked.candidate.Valid config.policy := by
  refine
    { authorized := ?_
      nullifiersNonempty := transfer.nullifiers_nonempty _
      nullifiersNodup := transfer.nullifiers_nodup _
      fresh := checked.prechecks.resources.fresh _
      enabled := checked.prechecks.resources.enabled
      conserves := checked.prechecks.resources.conserves
      cochainWellFormed := config.context.artifactWellFormed.1
      snapshotAccepted := checked.proof.accepted config.context rfl rfl
      epochMatches := ?_
      heightMatches := ?_
      parentMatches := ?_
      snapshotMatches := ?_
      beforeSnapshotMatches := checked.prechecks.snapshotMatches
      topologyMatches := ?_
      topologyBound := ?_ }
  · refine ⟨transfer, rfl, rfl, checked.prechecks.resources, ?_⟩
    rw [checked.subject_eq]
    exact checked.proof.authorized
  · change checked.proof.packet.intent.draft.epoch = config.before.epoch
    rw [checked.proof.intent_eq]
    rfl
  · change checked.proof.packet.intent.draft.height = config.before.height + 1
    rw [checked.proof.intent_eq]
    rfl
  · change checked.proof.packet.intent.draft.parentDigest = config.before.tipHash
    rw [checked.proof.intent_eq]
    rfl
  · change checked.proof.packet.intent.draft.snapshotRoot =
      config.context.interpretation.snapshot.root
    rw [checked.proof.intent_eq]
    rfl
  · change checked.proof.packet.intent.draft.topologyRoot = config.before.topologyRoot
    rw [checked.proof.intent_eq]
    rfl
  · change config.topologyBinds config.context.interpretation.snapshot
      checked.proof.packet.intent.draft.topologyRoot
    rw [checked.proof.intent_eq]
    exact config.topologyBound

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
