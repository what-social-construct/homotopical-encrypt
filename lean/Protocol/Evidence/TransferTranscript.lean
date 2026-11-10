module

public import Protocol.Ledger.OwnedResource
public import Protocol.Storage.PublicView
public import Protocol.Consensus.Vote

@[expose] public section

/-!
# Acyclic typed preimages for one owned-resource transition

The public intent contains its schema/statement/policy signing domain, the
transfer, original public cochain/context view, an unsigned proposal draft and
an independently prepared manifest root. The
proof packet retains exact metadata, owner-signature bytes and proof bytes.
The evidence hash is computed from that packet before the block hash; neither
preimage contains its own enclosing digest.

Successor content omits its current tip and evidence root. Those later public
coordinates are retained by the completed proposal and reconstruct the full
state together with its content. This is an explicit projection, not a claim
that a content digest alone authenticates every state coordinate.

The intent separately names the source state's prior evidence root; the draft's
parent digest names its prior tip. Thus these already available source
coordinates can be authorized before constructing the new evidence and block.

The suite supplies typed functions, without an injectivity or cryptographic
security axiom. Concrete canonical codecs, byte bounds, domain separation,
hash security, signature verification and proof verification remain separate
profile contracts. No private sheaf interpretation or semantic proposition is
put into the public transcript.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Evidence.TransferTranscript

/-- State content prepared before the current block/evidence digests exist. -/
structure StateContent where
  marking : Ledger.Marking ℕ
  spent : Finset ℕ
  height : ℕ
  epoch : ℕ
  snapshotRoot : TCB.Hash32
  topologyRoot : TCB.Hash32
  cochainRoot : TCB.Hash32

namespace StateContent

def ofState (state : Ledger.State ℕ ℕ) : StateContent where
  marking := state.marking
  spent := state.spent
  height := state.height
  epoch := state.epoch
  snapshotRoot := state.snapshotRoot
  topologyRoot := state.topologyRoot
  cochainRoot := state.cochainRoot

/-- Later authenticated coordinates complete the original state object. -/
def restore (content : StateContent) (tip evidence : TCB.Hash32) : Ledger.State ℕ ℕ where
  marking := content.marking
  spent := content.spent
  tipHash := tip
  height := content.height
  epoch := content.epoch
  snapshotRoot := content.snapshotRoot
  topologyRoot := content.topologyRoot
  cochainRoot := content.cochainRoot
  evidenceRoot := evidence

theorem reconstruct (state : Ledger.State ℕ ℕ) :
    (ofState state).restore state.tipHash state.evidenceRoot = state := by
  cases state
  rfl

theorem ofState_restore (content : StateContent) (tip evidence : TCB.Hash32) :
    ofState (content.restore tip evidence) = content := by
  cases content
  rfl

/-- The content of the actual computed resource/nullifier update. -/
def afterFor (before : Ledger.State ℕ ℕ) (action : Ledger.Action ℕ ℕ)
    (nextCochainRoot : TCB.Hash32) : StateContent where
  marking := action.flow.apply before.marking
  spent := Ledger.Nullifiers.consume before.spent action.nullifiers
  height := before.height + 1
  epoch := before.epoch
  snapshotRoot := before.snapshotRoot
  topologyRoot := before.topologyRoot
  cochainRoot := nextCochainRoot

theorem ofState_after {Snapshot : Type*}
    (candidate : Ledger.Candidate ℕ ℕ Snapshot) :
    ofState candidate.after =
      afterFor candidate.before candidate.action candidate.proposal.cochainRoot := rfl

end StateContent

/-- All proposal coordinates prepared before proof/evidence and block hashes. -/
structure ProposalDraft where
  committeeDigest : TCB.Hash32
  epoch : ℕ
  height : ℕ
  round : ℕ
  phase : ℕ
  parentDigest : TCB.Hash32
  beforeStateRoot : TCB.Hash32
  afterStateRoot : TCB.Hash32
  snapshotRoot : TCB.Hash32
  topologyRoot : TCB.Hash32
  cochainRoot : TCB.Hash32

namespace ProposalDraft

def ofProposal (proposal : Consensus.ProposalRef) : ProposalDraft where
  committeeDigest := proposal.committeeDigest
  epoch := proposal.epoch
  height := proposal.height
  round := proposal.round
  phase := proposal.phase
  parentDigest := proposal.parentDigest
  beforeStateRoot := proposal.beforeStateRoot
  afterStateRoot := proposal.afterStateRoot
  snapshotRoot := proposal.snapshotRoot
  topologyRoot := proposal.topologyRoot
  cochainRoot := proposal.cochainRoot

def complete (draft : ProposalDraft) (evidence block : TCB.Hash32) :
    Consensus.ProposalRef where
  committeeDigest := draft.committeeDigest
  epoch := draft.epoch
  height := draft.height
  round := draft.round
  phase := draft.phase
  parentDigest := draft.parentDigest
  beforeStateRoot := draft.beforeStateRoot
  afterStateRoot := draft.afterStateRoot
  snapshotRoot := draft.snapshotRoot
  topologyRoot := draft.topologyRoot
  cochainRoot := draft.cochainRoot
  evidenceRoot := evidence
  blockDigest := block

theorem reconstruct (proposal : Consensus.ProposalRef) :
    (ofProposal proposal).complete proposal.evidenceRoot proposal.blockDigest = proposal := by
  cases proposal
  rfl

theorem ofProposal_complete (draft : ProposalDraft) (evidence block : TCB.Hash32) :
    ofProposal (draft.complete evidence block) = draft := by
  cases draft
  rfl

end ProposalDraft

/-- Exact owner-authorized pre-proof subject, including its signing domain.
The policy identifier needs a profile contract identifying the actual catalog
semantics; its name alone provides no such interpretation. This record retains
no current block/evidence digest. -/
structure Intent (Owner : Type) where
  schemaVersion : ℕ
  statementId : TCB.Hash32
  policyId : TCB.Hash32
  transfer : Ledger.OwnedResource.Transfer Owner
  base : Storage.PublicPayloadView
  beforeEvidenceRoot : TCB.Hash32
  draft : ProposalDraft
  manifestRoot : TCB.Hash32

/-- Verifier selection and statement interpretation are explicit public data. -/
structure ProofMetadata where
  schemaVersion : ℕ
  statementId : TCB.Hash32
  policyId : TCB.Hash32
  proofSystemId : TCB.Hash32
  verifierId : TCB.Hash32

namespace ProofMetadata

@[ext]
theorem ext {left right : ProofMetadata}
    (schema : left.schemaVersion = right.schemaVersion)
    (statement : left.statementId = right.statementId)
    (policy : left.policyId = right.policyId)
    (proofSystem : left.proofSystemId = right.proofSystemId)
    (verifier : left.verifierId = right.verifierId) : left = right := by
  cases left
  cases right
  cases schema
  cases statement
  cases policy
  cases proofSystem
  cases verifier
  rfl

/-- Structural metadata equality does not assert inversion of an evidence digest. -/
theorem eq_iff (left right : ProofMetadata) :
    left = right ↔ left.schemaVersion = right.schemaVersion ∧
      left.statementId = right.statementId ∧ left.policyId = right.policyId ∧
      left.proofSystemId = right.proofSystemId ∧ left.verifierId = right.verifierId := by
  constructor
  · rintro rfl
    exact ⟨rfl, rfl, rfl, rfl, rfl⟩
  · rintro ⟨schema, statement, policy, proofSystem, verifier⟩
    exact ext schema statement policy proofSystem verifier

end ProofMetadata

/-- The complete proof record included under its enclosing evidence digest. -/
structure ProofPacket (Owner : Type) where
  metadata : ProofMetadata
  intent : Intent Owner
  ownerSignature : List UInt8
  proofBytes : List UInt8

/-- Public manifest input excludes its enclosing root and semantic leaf payloads. -/
structure ManifestPreimage where
  base : Storage.PublicPayloadView
  directory : List (Unit × TCB.Hash32)

namespace ManifestPreimage

def ofView (view : Storage.PublicManifestView Unit) : ManifestPreimage :=
  ⟨view.base, view.directory⟩

def toView (preimage : ManifestPreimage) (root : TCB.Hash32) :
    Storage.PublicManifestView Unit := ⟨preimage.base, root, preimage.directory⟩

theorem reconstruct (view : Storage.PublicManifestView Unit) :
    (ofView view).toView view.root = view := by
  cases view
  rfl

end ManifestPreimage

/-- The block preimage follows evidence hashing and excludes its own block digest. -/
structure BlockPreimage where
  draft : ProposalDraft
  evidenceRoot : TCB.Hash32
  intentDigest : TCB.Hash32
  manifestRoot : TCB.Hash32

/-- Separate typed hash inputs; codecs, domain separation and security are contracts. -/
structure HashSuite (Owner : Type) where
  state : StateContent → TCB.Hash32
  /-- Original payload leaf digest. -/
  cochain : Axioms.CochainCommitmentData → TCB.Hash32
  /-- Enclosing ordered cochain leaves, distinct from the payload-leaf role. -/
  cochainRoot : List TCB.Hash32 → TCB.Hash32
  manifest : ManifestPreimage → TCB.Hash32
  intent : Intent Owner → TCB.Hash32
  evidence : ProofPacket Owner → TCB.Hash32
  block : BlockPreimage → TCB.Hash32

namespace HashSuite

variable {Owner : Type}

def blockPreimage (hashes : HashSuite Owner) (packet : ProofPacket Owner) : BlockPreimage where
  draft := packet.intent.draft
  evidenceRoot := hashes.evidence packet
  intentDigest := hashes.intent packet.intent
  manifestRoot := packet.intent.manifestRoot

/-- Evidence is hashed first; the resulting block digest completes the same draft. -/
def proposal (hashes : HashSuite Owner) (packet : ProofPacket Owner) : Consensus.ProposalRef :=
  packet.intent.draft.complete (hashes.evidence packet) (hashes.block (hashes.blockPreimage packet))

theorem proposal_draft (hashes : HashSuite Owner) (packet : ProofPacket Owner) :
    ProposalDraft.ofProposal (hashes.proposal packet) = packet.intent.draft := rfl

theorem proposal_evidenceRoot (hashes : HashSuite Owner) (packet : ProofPacket Owner) :
    (hashes.proposal packet).evidenceRoot = hashes.evidence packet := rfl

theorem proposal_blockDigest (hashes : HashSuite Owner) (packet : ProofPacket Owner) :
    (hashes.proposal packet).blockDigest = hashes.block (hashes.blockPreimage packet) := rfl

theorem proposal_parentDigest (hashes : HashSuite Owner) (packet : ProofPacket Owner) :
    (hashes.proposal packet).parentDigest = packet.intent.draft.parentDigest := rfl

theorem proposal_beforeStateRoot (hashes : HashSuite Owner) (packet : ProofPacket Owner) :
    (hashes.proposal packet).beforeStateRoot = packet.intent.draft.beforeStateRoot := rfl

theorem proposal_afterStateRoot (hashes : HashSuite Owner) (packet : ProofPacket Owner) :
    (hashes.proposal packet).afterStateRoot = packet.intent.draft.afterStateRoot := rfl

theorem proposal_snapshotRoot (hashes : HashSuite Owner) (packet : ProofPacket Owner) :
    (hashes.proposal packet).snapshotRoot = packet.intent.draft.snapshotRoot := rfl

theorem proposal_topologyRoot (hashes : HashSuite Owner) (packet : ProofPacket Owner) :
    (hashes.proposal packet).topologyRoot = packet.intent.draft.topologyRoot := rfl

theorem proposal_cochainRoot (hashes : HashSuite Owner) (packet : ProofPacket Owner) :
    (hashes.proposal packet).cochainRoot = packet.intent.draft.cochainRoot := rfl

end HashSuite

end HomotopicalEncryption.Protocol.Evidence.TransferTranscript
