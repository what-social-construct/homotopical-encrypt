module

public import Protocol.Transfer.Owned
public import Protocol.Evidence.TransferEnvelope
public import Protocol.Storage.Anchor

@[expose] public section

/-!
# The checked transfer in existing evidence and history objects

All roots below are computed from explicit typed preimages. The entire packet,
including its metadata, signature and proof bytes, determines the evidence
root. The original input manifest is included in the block preimage. These
equations assert neither collision resistance nor digest inversion.

The operational checker has already derived candidate validity. The semantic
TCB adapter and optional complete-proposal quorum preserve that same candidate,
artifact, source context, manifest and computed successor. Runtime contracts,
actual signature/proof implementations, persistence and finality are separate.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt.Protocol.Transfer.Owned

open Sheaf CellularSheaf
open Evidence.TransferTranscript

variable {Vertex Edge Face Owner Asset Receipt : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

namespace Config

variable (config : Config F Owner Asset Receipt)

/-- Actual-object relations for the computed roots of this single-packet profile. -/
def bindings (packet : ProofPacket Owner) :
    Evidence.RootBindings ℕ ℕ (CochainPayloadInterpretation F) where
  stateRoot state root := root = config.hashes.state (StateContent.ofState state)
  transitionDigest candidate digest :=
    packet.intent = config.subject candidate packet.intent.transfer ∧
    candidate.action = packet.intent.transfer.action config.context.cochain ∧
    candidate.snapshot = config.context.interpretation ∧
    digest = config.hashes.block
      { draft := ProposalDraft.ofProposal candidate.proposal
        evidenceRoot := candidate.proposal.evidenceRoot
        intentDigest := config.hashes.intent packet.intent
        manifestRoot := packet.intent.manifestRoot }
  cochainIncluded cochain leaf root := cochain = config.context.cochain ∧
    leaf = config.context.artifact.digest ∧ root = config.hashes.cochainRoot [leaf]
  artifactIncluded candidate artifact root := artifact = config.context.artifact ∧
    candidate.action.cochain = artifact.cochain ∧
    packet.intent = config.subject candidate packet.intent.transfer ∧
    root = config.hashes.evidence packet

/-- This exact input manifest is included through the acyclic block preimage. -/
def history (packet : ProofPacket Owner) : Storage.HistoryBindings F ℕ ℕ Unit
    (fun _ => Axioms.CochainCommitmentData) where
  manifestIncluded candidate context items root block :=
    context = config.context ∧
    items = [Storage.TransferManifest.inputItem config.context] ∧
    root = config.manifest.root ∧
    packet.intent = config.subject candidate packet.intent.transfer ∧
    block = config.hashes.block
      { draft := ProposalDraft.ofProposal candidate.proposal
        evidenceRoot := candidate.proposal.evidenceRoot
        intentDigest := config.hashes.intent packet.intent
        manifestRoot := root }

end Config

namespace CheckedTransfer

variable {config : Config F Owner Asset Receipt} {transfer : ResourceTransfer Owner}
  {bytes : List UInt8}

theorem packet_transfer (checked : CheckedTransfer config transfer bytes) :
    checked.proof.packet.intent.transfer = transfer := by
  exact congrArg Intent.transfer checked.proof.intent_eq

/-- Every proof-selection field is part of the checked and hashed packet. -/
theorem packet_metadata (checked : CheckedTransfer config transfer bytes) :
    checked.proof.packet.metadata = config.metadata := checked.proof.metadata_eq

theorem packet_included (checked : CheckedTransfer config transfer bytes) :
    checked.candidate.proposal.evidenceRoot = config.hashes.evidence checked.proof.packet := rfl

theorem source_reconstruct (checked : CheckedTransfer config transfer bytes) :
    (StateContent.ofState config.before).restore checked.candidate.proposal.parentDigest
        checked.proof.packet.intent.beforeEvidenceRoot = config.before := by
  change (StateContent.ofState config.before).restore
    checked.proof.packet.intent.draft.parentDigest
    checked.proof.packet.intent.beforeEvidenceRoot = _
  rw [checked.proof.intent_eq]
  exact StateContent.reconstruct config.before

theorem successor_reconstruct (checked : CheckedTransfer config transfer bytes) :
    (StateContent.ofState checked.candidate.after).restore
        checked.candidate.proposal.blockDigest checked.candidate.proposal.evidenceRoot =
      checked.candidate.after :=
  StateContent.reconstruct checked.candidate.after

theorem before_root_bound (checked : CheckedTransfer config transfer bytes) :
    (config.bindings checked.proof.packet).stateRoot checked.candidate.before
      checked.candidate.proposal.beforeStateRoot := by
  change checked.proof.packet.intent.draft.beforeStateRoot =
    config.hashes.state (StateContent.ofState config.before)
  rw [checked.proof.intent_eq]
  rfl

theorem after_root_bound (checked : CheckedTransfer config transfer bytes) :
    (config.bindings checked.proof.packet).stateRoot checked.candidate.after
      checked.candidate.proposal.afterStateRoot := by
  change checked.proof.packet.intent.draft.afterStateRoot = config.hashes.state
    (StateContent.afterFor config.before (transfer.action config.context.cochain)
      checked.proof.packet.intent.draft.cochainRoot)
  rw [checked.proof.intent_eq]
  rfl

theorem transition_bound (checked : CheckedTransfer config transfer bytes) :
    (config.bindings checked.proof.packet).transitionDigest checked.candidate
      checked.candidate.proposal.blockDigest := by
  change checked.proof.packet.intent =
      config.subject checked.candidate checked.proof.packet.intent.transfer ∧
    checked.candidate.action = checked.proof.packet.intent.transfer.action config.context.cochain ∧
    checked.candidate.snapshot = config.context.interpretation ∧ _
  rw [checked.packet_transfer]
  exact ⟨checked.proof.intent_eq.trans checked.subject_eq.symm, rfl, rfl, rfl⟩

theorem cochain_included (checked : CheckedTransfer config transfer bytes) :
    (config.bindings checked.proof.packet).cochainIncluded config.context.cochain
      config.context.artifact.digest checked.candidate.proposal.cochainRoot := by
  refine ⟨rfl, rfl, ?_⟩
  change checked.proof.packet.intent.draft.cochainRoot = _
  rw [checked.proof.intent_eq]
  rfl

theorem artifact_included (checked : CheckedTransfer config transfer bytes) :
    (config.bindings checked.proof.packet).artifactIncluded checked.candidate
      config.context.artifact checked.candidate.proposal.evidenceRoot := by
  refine ⟨rfl, rfl, ?_, rfl⟩
  rw [checked.packet_transfer]
  exact checked.proof.intent_eq.trans checked.subject_eq.symm

/-- Represent the independently derived checked result in the existing semantic TCB. -/
def derivation [DecidableEq Asset] (checked : CheckedTransfer config transfer bytes)
    (runtime : TCB.RuntimeBoundary) (runtime_wellFormed : runtime.WellFormed) :
    Evidence.TransferEnvelope.Derivation runtime config.policy
      (config.bindings checked.proof.packet) config.context config.payload config.hashes
      (fun witness => config.subject witness.1 witness.2)
      checked.candidate checked.proof.packet where
  transfer := transfer
  runtime_wellFormed := runtime_wellFormed
  valid := checked.valid
  action_eq := rfl
  snapshot_eq := rfl
  project_eq := checked.subject_eq.trans checked.proof.intent_eq.symm
  checkFact := check config transfer bytes = true
  checked := checked.check_true
  beforeRootBound := checked.before_root_bound
  afterRootBound := checked.after_root_bound
  transitionDigestBound := checked.transition_bound
  cochainIncluded := checked.cochain_included
  artifactIncluded := checked.artifact_included

def evidence [DecidableEq Asset] (checked : CheckedTransfer config transfer bytes)
    (runtime : TCB.RuntimeBoundary) (runtime_wellFormed : runtime.WellFormed) :
    Evidence.Transition runtime config.policy (config.bindings checked.proof.packet)
      checked.candidate :=
  (checked.derivation runtime runtime_wellFormed).toEvidence

/-- Original context, artifact and exact manifest survive the entire evidence handoff. -/
theorem anchor [DecidableEq Asset] (checked : CheckedTransfer config transfer bytes)
    (runtime : TCB.RuntimeBoundary) (runtime_wellFormed : runtime.WellFormed) :
    Storage.TransitionAnchor config.topologyBinds (config.history checked.proof.packet)
      (checked.evidence runtime runtime_wellFormed) config.context config.manifest where
  policySnapshots := rfl
  snapshotMatches := rfl
  artifactMatches := (checked.derivation runtime runtime_wellFormed).toEvidence_artifact
  manifestIncluded := by
    refine ⟨rfl, rfl, rfl, ?_, ?_⟩
    · rw [checked.packet_transfer]
      exact checked.proof.intent_eq.trans checked.subject_eq.symm
    · change config.hashes.block (config.hashes.blockPreimage checked.proof.packet) =
        config.hashes.block
          { draft := checked.proof.packet.intent.draft
            evidenceRoot := config.hashes.evidence checked.proof.packet
            intentDigest := config.hashes.intent checked.proof.packet.intent
            manifestRoot := config.manifest.root }
      have manifest_eq : checked.proof.packet.intent.manifestRoot = config.manifest.root :=
        congrArg Intent.manifestRoot checked.proof.intent_eq
      unfold HashSuite.blockPreimage
      rw [manifest_eq]

theorem anchored_update [DecidableEq Asset]
    (checked : CheckedTransfer config transfer bytes)
    (runtime : TCB.RuntimeBoundary) (runtime_wellFormed : runtime.WellFormed) :
    Ledger.AcceptedUpdate config.policy config.before checked.candidate checked.candidate.after :=
  (checked.anchor runtime runtime_wellFormed).toAcceptedUpdate

variable {Validator Signature : Type} [DecidableEq Validator]
  {committee : Consensus.Committee Validator}
  {authentication : Consensus.VoteAuthentication Validator Signature}

/-- The final complete proposal is authenticated separately, after evidence/block construction. -/
def certified [DecidableEq Asset] (checked : CheckedTransfer config transfer bytes)
    (runtime : TCB.RuntimeBoundary) (runtime_wellFormed : runtime.WellFormed)
    (quorum : Consensus.QuorumCertificate committee authentication)
    (proposalMatches : quorum.target.proposal = checked.candidate.proposal)
    (accepts : quorum.SupportsAcceptance) :
    Ledger.CertifiedTransition runtime config.policy (config.bindings checked.proof.packet)
      checked.candidate committee authentication where
  evidence := checked.evidence runtime runtime_wellFormed
  quorum := quorum
  proposalMatches := proposalMatches
  accepts := accepts

end CheckedTransfer

end Hcrypt.Protocol.Transfer.Owned
