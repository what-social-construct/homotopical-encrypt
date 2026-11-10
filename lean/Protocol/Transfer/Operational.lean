module

public import Protocol.Evidence.TransferCheck
public import Protocol.Storage.TransferManifest
public import Protocol.Ledger.Sheaf

@[expose] public section

/-!
# Operational owned transfers without primitive soundness assumptions

The same original context, immutable resource catalog, input manifest and acyclic
proposal construction are checked with selected signature and proof algorithms.
Neither algorithm carries a semantic soundness premise. Local authorization and
payload-acceptance facts suffice to derive the actual ledger validity.

An accepted invalid candidate therefore exhibits an authorization-check failure
or an exact-payload-check failure for this trusted original interpretation. This
is a conditional one-attempt integrity reduction: state origin, trusted setup,
canonical codecs, runtime agreement and finality are outside its event model.
No primitive security, privacy, or negligible error estimate is assumed here.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.Operational

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
their catalog, topology, arithmetization or cryptographic correctness. The two
checking algorithms carry no universal semantic soundness law. -/
structure Config (F : CellularSheaf X) (Owner Asset Receipt : Type) where
  catalog : Ledger.OwnedResource.Catalog Owner Asset
  context : Storage.Context F
  before : Ledger.State ℕ ℕ
  hashes : HashSuite Owner
  metadata : ProofMetadata
  authorization : Evidence.TransferCheck.Authorization Owner
  payload : Evidence.TransferCheck.PayloadVerifier context.interpretation Owner metadata
  codec : Evidence.TransferCheck.PacketCodec Owner
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

/-- Candidate determined by the original setup, attempted transfer and actual parsed packet. -/
def candidateFor (transfer : ResourceTransfer Owner) (packet : ProofPacket Owner) :
    Ledger.Candidate ℕ ℕ (CochainPayloadInterpretation F) where
  before := config.before
  action := transfer.action config.context.cochain
  snapshot := config.context.interpretation
  proposal := config.hashes.proposal packet

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
    Evidence.TransferCheck.check config.codec config.metadata (config.intentFor transfer)
      config.authorization config.payload bytes

/-- Actual component checks, without storing candidate validity as an assumption. -/
structure CheckedTransfer (config : Config F Owner Asset Receipt)
    (transfer : ResourceTransfer Owner) (bytes : List UInt8) where
  prechecks : Prechecks config transfer
  proof : Evidence.TransferCheck.CheckedPacket config.codec config.metadata
    (config.intentFor transfer) config.authorization config.payload bytes

namespace CheckedTransfer

variable {config : Config F Owner Asset Receipt} {transfer : ResourceTransfer Owner}
  {bytes : List UInt8}

def ofCheck (accepted : check config transfer bytes = true) :
    CheckedTransfer config transfer bytes := by
  classical
  have checks := accepted
  simp only [check, Bool.and_eq_true_iff, decide_eq_true_eq] at checks
  exact ⟨checks.1, Evidence.TransferCheck.CheckedPacket.ofCheck checks.2⟩

theorem check_true (checked : CheckedTransfer config transfer bytes) :
    check config transfer bytes = true := by
  classical
  simp only [check, Bool.and_eq_true_iff, decide_eq_true_eq]
  exact ⟨checked.prechecks, checked.proof.check_true⟩

/-- The action and snapshot are constructed from the original source objects. -/
def candidate (checked : CheckedTransfer config transfer bytes) :
    Ledger.Candidate ℕ ℕ (CochainPayloadInterpretation F) :=
  config.candidateFor transfer checked.proof.packet

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

/-- Local semantic good-event facts suffice; no universal primitive soundness is used. -/
theorem valid [DecidableEq Asset] (checked : CheckedTransfer config transfer bytes)
    (authorized : config.authorization.Authorized transfer.signer (config.intentFor transfer))
    (payloadAccepted : config.context.Accepted) :
    checked.candidate.Valid config.policy := by
  refine
    { authorized := ?_
      nullifiersNonempty := transfer.nullifiers_nonempty _
      nullifiersNodup := transfer.nullifiers_nodup _
      fresh := checked.prechecks.resources.fresh _
      enabled := checked.prechecks.resources.enabled
      conserves := checked.prechecks.resources.conserves
      cochainWellFormed := config.context.artifactWellFormed.1
      snapshotAccepted := payloadAccepted
      epochMatches := ?_
      heightMatches := ?_
      parentMatches := ?_
      snapshotMatches := ?_
      beforeSnapshotMatches := checked.prechecks.snapshotMatches
      topologyMatches := ?_
      topologyBound := ?_ }
  · refine ⟨transfer, rfl, rfl, checked.prechecks.resources, ?_⟩
    rw [checked.subject_eq]
    exact authorized
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
    (checked : CheckedTransfer config transfer bytes)
    (authorized : config.authorization.Authorized transfer.signer (config.intentFor transfer))
    (payloadAccepted : config.context.Accepted) :
    Ledger.AcceptedUpdate config.policy config.before checked.candidate checked.candidate.after :=
  ⟨rfl, checked.valid authorized payloadAccepted, rfl⟩

end CheckedTransfer

/-- One adversarial proposal, retaining the actual bytes to be parsed. -/
structure Attempt (Owner : Type) where
  transfer : ResourceTransfer Owner
  bytes : List UInt8

/-- The actual Boolean checker accepts, but its uniquely parsed candidate is invalid. -/
def AcceptedInvalid [DecidableEq Asset] (config : Config F Owner Asset Receipt)
    (attempt : Attempt Owner) : Prop :=
  check config attempt.transfer attempt.bytes = true ∧
    ∃ packet : ProofPacket Owner, config.codec.decode attempt.bytes = some packet ∧
      ¬ (config.candidateFor attempt.transfer packet).Valid config.policy

/-- An actual signature check accepts an unauthorized exact owner/intent pair.
This is not an EUF-CMA event: no signing-query or corruption policy is implicit. -/
def AuthorizationFailure (config : Config F Owner Asset Receipt)
    (attempt : Attempt Owner) : Prop :=
  ∃ packet : ProofPacket Owner, config.codec.decode attempt.bytes = some packet ∧
    packet.metadata = config.metadata ∧ packet.intent = config.intentFor attempt.transfer ∧
    config.authorization.verify attempt.transfer.signer (config.intentFor attempt.transfer)
      packet.ownerSignature = true ∧
    ¬ config.authorization.Authorized attempt.transfer.signer
      (config.intentFor attempt.transfer)

/-- An actual proof check accepts the exact original public input while its trusted
interpretation rejects that payload. Names never substitute for the interpretation. -/
def PayloadFailure (config : Config F Owner Asset Receipt)
    (attempt : Attempt Owner) : Prop :=
  ∃ packet : ProofPacket Owner, config.codec.decode attempt.bytes = some packet ∧
    packet.metadata = config.metadata ∧ packet.intent = config.intentFor attempt.transfer ∧
    config.payload.verify (config.intentFor attempt.transfer) packet.proofBytes = true ∧
    ¬ config.context.Accepted

/-- Pointwise reduction from the actual bad acceptance to one of the two primitive events. -/
theorem acceptedInvalid_implies_failure [DecidableEq Asset]
    (config : Config F Owner Asset Receipt) (attempt : Attempt Owner)
    (bad : AcceptedInvalid config attempt) :
    AuthorizationFailure config attempt ∨ PayloadFailure config attempt := by
  classical
  obtain ⟨accepted, packet, decoded, invalid⟩ := bad
  let checked := CheckedTransfer.ofCheck accepted
  have packet_eq : checked.proof.packet = packet :=
    Option.some.inj (checked.proof.decoded.symm.trans decoded)
  have invalid_checked : ¬ checked.candidate.Valid config.policy := by
    simpa only [CheckedTransfer.candidate, packet_eq] using invalid
  by_cases authorized : config.authorization.Authorized attempt.transfer.signer
      (config.intentFor attempt.transfer)
  · by_cases payloadAccepted : config.context.Accepted
    · exact False.elim (invalid_checked (checked.valid authorized payloadAccepted))
    · exact Or.inr ⟨checked.proof.packet, checked.proof.decoded,
        checked.proof.metadata_eq, checked.proof.intent_eq,
        checked.proof.proofVerified_expected, payloadAccepted⟩
  · exact Or.inl ⟨checked.proof.packet, checked.proof.decoded,
      checked.proof.metadata_eq, checked.proof.intent_eq,
      checked.proof.signatureVerified_expected, authorized⟩

/-- Good local semantic facts exclude bad acceptance for the same parsed candidate. -/
theorem not_acceptedInvalid_of_good [DecidableEq Asset]
    (config : Config F Owner Asset Receipt) (attempt : Attempt Owner)
    (authorizationGood : ¬ AuthorizationFailure config attempt)
    (payloadGood : ¬ PayloadFailure config attempt) :
    ¬ AcceptedInvalid config attempt := by
  intro bad
  exact (acceptedInvalid_implies_failure config attempt bad).elim authorizationGood payloadGood

end HomotopicalEncryption.Protocol.Transfer.Operational
