module

public import Protocol.Evidence.TransferCheck
public import Protocol.Ephemeral.ScopeCodec

@[expose] public section

/-!
# Concrete canonical transfer bytes for byte-valued owners

This profile serializes the existing `ProofPacket`, complete metadata, intent,
public context/payload and proposal draft. The byte-valued owner is retained
as its full byte string. The supplied packet-codec boundary is discharged by
the actual encoder, parser and roundtrip theorem below.

Raw semantic invalidity remains representable. The payload's declared edge
count and actual list length are encoded independently; unsupported moduli,
negative values, count mismatches and distinct topology tags are not silently
repaired or rejected by this codec. Its canonical parsing concerns bytes,
while the original payload/resource/proof checks retain their own meanings.

The versioned format uses the existing unbounded native natural/integer,
tagged-byte and fixed-vector encodings. It is not the archived Rust i64 wire
format and proves no allocation/DoS bound or cryptographic hash/signature
security. Every individual packet has finite bytes, without a uniform fixed
integer-width restriction.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Evidence.TransferCodec

open TransferTranscript
open Storage.CoupledCodec
open Ephemeral.ScopeCodec
  (encodeFixed parseFixed parseFixed_encodeFixed encodeFixed_append
    encodeKey parseKey parseKey_encodeKey encodeKey_append)

abbrev Bytes := List UInt8

def encodeMetadata (metadata : ProofMetadata) (rest : Bytes) : Bytes :=
  encodeNat metadata.schemaVersion
    (encodeFixed metadata.statementId
      (encodeFixed metadata.policyId
        (encodeFixed metadata.proofSystemId (encodeFixed metadata.verifierId rest))))

def parseMetadata (bytes : Bytes) : Option (ProofMetadata × Bytes) := do
  let (schemaVersion, rest) ← parseNat bytes
  let (statementId, rest) ← parseFixed 32 rest
  let (policyId, rest) ← parseFixed 32 rest
  let (proofSystemId, rest) ← parseFixed 32 rest
  let (verifierId, rest) ← parseFixed 32 rest
  some (⟨schemaVersion, statementId, policyId, proofSystemId, verifierId⟩, rest)

@[simp] theorem parseMetadata_encodeMetadata (metadata : ProofMetadata) (rest : Bytes) :
    parseMetadata (encodeMetadata metadata rest) = some (metadata, rest) := by
  cases metadata
  simp [parseMetadata, encodeMetadata]

theorem encodeMetadata_append (metadata : ProofMetadata) (rest suffix : Bytes) :
    encodeMetadata metadata rest ++ suffix = encodeMetadata metadata (rest ++ suffix) := by
  simp [encodeMetadata, encodeNat_append, encodeFixed_append]

def encodeDraft (draft : ProposalDraft) (rest : Bytes) : Bytes :=
  encodeFixed draft.committeeDigest
    (encodeNat draft.epoch (encodeNat draft.height (encodeNat draft.round (encodeNat draft.phase
      (encodeFixed draft.parentDigest
        (encodeFixed draft.beforeStateRoot
          (encodeFixed draft.afterStateRoot
            (encodeFixed draft.snapshotRoot
              (encodeFixed draft.topologyRoot (encodeFixed draft.cochainRoot rest))))))))))

def parseDraft (bytes : Bytes) : Option (ProposalDraft × Bytes) := do
  let (committeeDigest, rest) ← parseFixed 32 bytes
  let (epoch, rest) ← parseNat rest
  let (height, rest) ← parseNat rest
  let (round, rest) ← parseNat rest
  let (phase, rest) ← parseNat rest
  let (parentDigest, rest) ← parseFixed 32 rest
  let (beforeStateRoot, rest) ← parseFixed 32 rest
  let (afterStateRoot, rest) ← parseFixed 32 rest
  let (snapshotRoot, rest) ← parseFixed 32 rest
  let (topologyRoot, rest) ← parseFixed 32 rest
  let (cochainRoot, rest) ← parseFixed 32 rest
  some
    (⟨committeeDigest, epoch, height, round, phase, parentDigest, beforeStateRoot,
      afterStateRoot, snapshotRoot, topologyRoot, cochainRoot⟩, rest)

@[simp] theorem parseDraft_encodeDraft (draft : ProposalDraft) (rest : Bytes) :
    parseDraft (encodeDraft draft rest) = some (draft, rest) := by
  cases draft
  simp [parseDraft, encodeDraft]

theorem encodeDraft_append (draft : ProposalDraft) (rest suffix : Bytes) :
    encodeDraft draft rest ++ suffix = encodeDraft draft (rest ++ suffix) := by
  simp [encodeDraft, encodeNat_append, encodeFixed_append]

/-- Preserve the declared edge count independently of the actual vector.
The extra actual-list count governs parsing without asserting well-formedness. -/
def encodePayload (payload : Axioms.CochainCommitmentData) (rest : Bytes) : Bytes :=
  encodeNat payload.modulus
    (encodeNat payload.n_edge_values
      (encodeNat payload.edge_values.length
        (encodeEntries payload.edge_values (encodeFixed payload.topology_hash rest))))

def parsePayload (bytes : Bytes) : Option (Axioms.CochainCommitmentData × Bytes) := do
  let (modulus, rest) ← parseNat bytes
  let (declaredCount, rest) ← parseNat rest
  let (actualCount, rest) ← parseNat rest
  let (edgeValues, rest) ← parseEntries actualCount rest
  let (topologyHash, rest) ← parseFixed 16 rest
  some (⟨modulus, declaredCount, edgeValues, topologyHash⟩, rest)

@[simp] theorem parsePayload_encodePayload (payload : Axioms.CochainCommitmentData) (rest : Bytes) :
    parsePayload (encodePayload payload rest) = some (payload, rest) := by
  cases payload
  simp [parsePayload, encodePayload]

theorem encodePayload_append (payload : Axioms.CochainCommitmentData) (rest suffix : Bytes) :
    encodePayload payload rest ++ suffix = encodePayload payload (rest ++ suffix) := by
  simp [encodePayload, encodeNat_append, encodeEntries_append, encodeFixed_append]

def encodeBase (base : Storage.PublicPayloadView) (rest : Bytes) : Bytes :=
  encodeKey base.key (encodePayload base.cochain rest)

def parseBase (bytes : Bytes) : Option (Storage.PublicPayloadView × Bytes) := do
  let (key, rest) ← parseKey bytes
  let (cochain, rest) ← parsePayload rest
  some (⟨key, cochain⟩, rest)

@[simp] theorem parseBase_encodeBase (base : Storage.PublicPayloadView) (rest : Bytes) :
    parseBase (encodeBase base rest) = some (base, rest) := by
  cases base
  simp [parseBase, encodeBase]

theorem encodeBase_append (base : Storage.PublicPayloadView) (rest suffix : Bytes) :
    encodeBase base rest ++ suffix = encodeBase base (rest ++ suffix) := by
  simp [encodeBase, encodeKey_append, encodePayload_append]

def encodeTransfer (transfer : Ledger.OwnedResource.Transfer Bytes) (rest : Bytes) : Bytes :=
  encodeNat transfer.input (encodeNat transfer.output (frame transfer.signer rest))

def parseTransfer (bytes : Bytes) : Option (Ledger.OwnedResource.Transfer Bytes × Bytes) := do
  let (input, rest) ← parseNat bytes
  let (output, rest) ← parseNat rest
  let (signer, rest) ← parseFrame rest
  some (⟨input, output, signer⟩, rest)

@[simp] theorem parseTransfer_encodeTransfer
    (transfer : Ledger.OwnedResource.Transfer Bytes) (rest : Bytes) :
    parseTransfer (encodeTransfer transfer rest) = some (transfer, rest) := by
  cases transfer
  simp [parseTransfer, encodeTransfer, parseFrame_frame]

theorem encodeTransfer_append (transfer : Ledger.OwnedResource.Transfer Bytes) (rest suffix : Bytes) :
    encodeTransfer transfer rest ++ suffix = encodeTransfer transfer (rest ++ suffix) := by
  simp [encodeTransfer, encodeNat_append, frame_append]

def encodeIntent (intent : Intent Bytes) (rest : Bytes) : Bytes :=
  encodeNat intent.schemaVersion
    (encodeFixed intent.statementId (encodeFixed intent.policyId
      (encodeTransfer intent.transfer
        (encodeBase intent.base
          (encodeFixed intent.beforeEvidenceRoot
            (encodeDraft intent.draft (encodeFixed intent.manifestRoot rest)))))))

def parseIntent (bytes : Bytes) : Option (Intent Bytes × Bytes) := do
  let (schemaVersion, rest) ← parseNat bytes
  let (statementId, rest) ← parseFixed 32 rest
  let (policyId, rest) ← parseFixed 32 rest
  let (transfer, rest) ← parseTransfer rest
  let (base, rest) ← parseBase rest
  let (beforeEvidenceRoot, rest) ← parseFixed 32 rest
  let (draft, rest) ← parseDraft rest
  let (manifestRoot, rest) ← parseFixed 32 rest
  some (⟨schemaVersion, statementId, policyId, transfer, base, beforeEvidenceRoot, draft, manifestRoot⟩, rest)

@[simp] theorem parseIntent_encodeIntent (intent : Intent Bytes) (rest : Bytes) :
    parseIntent (encodeIntent intent rest) = some (intent, rest) := by
  cases intent
  simp [parseIntent, encodeIntent]

theorem encodeIntent_append (intent : Intent Bytes) (rest suffix : Bytes) :
    encodeIntent intent rest ++ suffix = encodeIntent intent (rest ++ suffix) := by
  simp [encodeIntent, encodeNat_append, encodeFixed_append, encodeTransfer_append,
    encodeBase_append, encodeDraft_append]

/-- ASCII `HODGE_TRANSFER_PACKET_V1`. -/
def domain : Bytes :=
  [72, 79, 68, 71, 69, 95, 84, 82, 65, 78, 83, 70, 69, 82, 95,
    80, 65, 67, 75, 69, 84, 95, 86, 49]

def encodeBody (packet : ProofPacket Bytes) (rest : Bytes) : Bytes :=
  encodeMetadata packet.metadata
    (encodeIntent packet.intent (frame packet.ownerSignature (frame packet.proofBytes rest)))

def parseBody (bytes : Bytes) : Option (ProofPacket Bytes × Bytes) := do
  let (metadata, rest) ← parseMetadata bytes
  let (intent, rest) ← parseIntent rest
  let (ownerSignature, rest) ← parseFrame rest
  let (proofBytes, rest) ← parseFrame rest
  some (⟨metadata, intent, ownerSignature, proofBytes⟩, rest)

@[simp] theorem parseBody_encodeBody (packet : ProofPacket Bytes) (rest : Bytes) :
    parseBody (encodeBody packet rest) = some (packet, rest) := by
  cases packet
  simp [parseBody, encodeBody, parseFrame_frame]

def encode (packet : ProofPacket Bytes) : Bytes := domain ++ encodeBody packet []

/-- Canonical bytes and complete consumption; semantic validity is separate. -/
def decode (bytes : Bytes) : Option (ProofPacket Bytes) :=
  match parseBody (bytes.drop domain.length) with
  | none => none
  | some (packet, rest) =>
    if rest = [] ∧ bytes = encode packet then some packet else none

@[simp] theorem decode_encode (packet : ProofPacket Bytes) :
    decode (encode packet) = some packet := by
  simp [decode, encode]

theorem decode_eq_some_iff (bytes : Bytes) (packet : ProofPacket Bytes) :
    decode bytes = some packet ↔ bytes = encode packet := by
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
        have same : other = packet := Option.some.inj decoded
        exact canonical.2.trans (congrArg encode same)
      next => contradiction
  · rintro rfl
    exact decode_encode packet

theorem encode_injective : Function.Injective encode := by
  intro first second same
  have parsed := congrArg decode same
  simpa only [decode_encode, Option.some.injEq] using parsed

theorem encodeBody_append (packet : ProofPacket Bytes) (rest suffix : Bytes) :
    encodeBody packet rest ++ suffix = encodeBody packet (rest ++ suffix) := by
  simp [encodeBody, encodeMetadata_append, encodeIntent_append, frame_append]

theorem decode_rejects_trailing (packet : ProofPacket Bytes) (suffix : Bytes)
    (nonempty : suffix ≠ []) : decode (encode packet ++ suffix) = none := by
  have parsed : parseBody ((encode packet ++ suffix).drop domain.length) = some (packet, suffix) := by
    rw [encode, List.append_assoc, List.drop_left, encodeBody_append]
    simp
  simp [decode, parsed, nonempty]

theorem decode_rejects_wrong_domain (bytes : Bytes)
    (wrong : bytes.take domain.length ≠ domain) : decode bytes = none := by
  cases parsed : decode bytes with
  | none => rfl
  | some packet =>
    have canonical := (decode_eq_some_iff bytes packet).mp parsed
    apply False.elim
    apply wrong
    rw [canonical, encode, List.take_left]

/-- The existing generic packet-codec contract instantiated with actual bytes. -/
def bytesOwnerCodec : TransferCheck.PacketCodec Bytes where
  encode := encode
  decode := decode
  decode_encode := decode_encode

abbrev codec : TransferCheck.PacketCodec Bytes := bytesOwnerCodec

/-- Every original proposal field in its declared structure order, including
the completed block digest before the parent and the evidence root last. -/
def encodeProposalBody (proposal : Consensus.ProposalRef) (rest : Bytes) : Bytes :=
  encodeFixed proposal.committeeDigest
    (encodeNat proposal.epoch (encodeNat proposal.height (encodeNat proposal.round (encodeNat proposal.phase
      (encodeFixed proposal.blockDigest
        (encodeFixed proposal.parentDigest
          (encodeFixed proposal.beforeStateRoot
            (encodeFixed proposal.afterStateRoot
              (encodeFixed proposal.snapshotRoot
                (encodeFixed proposal.topologyRoot
                  (encodeFixed proposal.cochainRoot (encodeFixed proposal.evidenceRoot rest))))))))))))

def parseProposalBody (bytes : Bytes) : Option (Consensus.ProposalRef × Bytes) := do
  let (committeeDigest, rest) ← parseFixed 32 bytes
  let (epoch, rest) ← parseNat rest
  let (height, rest) ← parseNat rest
  let (round, rest) ← parseNat rest
  let (phase, rest) ← parseNat rest
  let (blockDigest, rest) ← parseFixed 32 rest
  let (parentDigest, rest) ← parseFixed 32 rest
  let (beforeStateRoot, rest) ← parseFixed 32 rest
  let (afterStateRoot, rest) ← parseFixed 32 rest
  let (snapshotRoot, rest) ← parseFixed 32 rest
  let (topologyRoot, rest) ← parseFixed 32 rest
  let (cochainRoot, rest) ← parseFixed 32 rest
  let (evidenceRoot, rest) ← parseFixed 32 rest
  some
    (⟨committeeDigest, epoch, height, round, phase, blockDigest, parentDigest,
      beforeStateRoot, afterStateRoot, snapshotRoot, topologyRoot, cochainRoot, evidenceRoot⟩, rest)

@[simp] theorem parseProposalBody_encodeProposalBody (proposal : Consensus.ProposalRef) (rest : Bytes) :
    parseProposalBody (encodeProposalBody proposal rest) = some (proposal, rest) := by
  cases proposal
  simp only [parseProposalBody, encodeProposalBody, parseFixed_encodeFixed,
    parseNat_encodeNat, bind, Option.bind]

theorem encodeProposalBody_append (proposal : Consensus.ProposalRef) (rest suffix : Bytes) :
    encodeProposalBody proposal rest ++ suffix = encodeProposalBody proposal (rest ++ suffix) := by
  simp [encodeProposalBody, encodeNat_append, encodeFixed_append]

/-- ASCII `HODGE_PROPOSAL_V1`. -/
def proposalDomain : Bytes :=
  [72, 79, 68, 71, 69, 95, 80, 82, 79, 80, 79, 83, 65, 76, 95, 86, 49]

def encodeProposal (proposal : Consensus.ProposalRef) : Bytes :=
  proposalDomain ++ encodeProposalBody proposal []

def decodeProposal (bytes : Bytes) : Option Consensus.ProposalRef :=
  match parseProposalBody (bytes.drop proposalDomain.length) with
  | none => none
  | some (proposal, rest) =>
    if rest = [] ∧ bytes = encodeProposal proposal then some proposal else none

@[simp] theorem decodeProposal_encodeProposal (proposal : Consensus.ProposalRef) :
    decodeProposal (encodeProposal proposal) = some proposal := by
  simp [decodeProposal, encodeProposal]

theorem decodeProposal_eq_some_iff (bytes : Bytes) (proposal : Consensus.ProposalRef) :
    decodeProposal bytes = some proposal ↔ bytes = encodeProposal proposal := by
  constructor
  · intro decoded
    unfold decodeProposal at decoded
    cases parsed : parseProposalBody (bytes.drop proposalDomain.length) with
    | none => simp [parsed] at decoded
    | some value =>
      rcases value with ⟨other, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next canonical =>
        have same : other = proposal := Option.some.inj decoded
        exact canonical.2.trans (congrArg encodeProposal same)
      next => contradiction
  · rintro rfl
    exact decodeProposal_encodeProposal proposal

abbrev parseProposal : Bytes → Option Consensus.ProposalRef := decodeProposal

theorem encodeProposal_injective : Function.Injective encodeProposal := by
  intro first second same
  have parsed := congrArg decodeProposal same
  simpa only [decodeProposal_encodeProposal, Option.some.injEq] using parsed

def encodeJudgment (judgment : Axioms.Heyting3) (rest : Bytes) : Bytes :=
  match judgment with
  | .Invalid => encodeNat 0 rest
  | .Undetermined => encodeNat 1 rest
  | .Valid => encodeNat 2 rest

def parseJudgment (bytes : Bytes) : Option (Axioms.Heyting3 × Bytes) := do
  let (tag, rest) ← parseNat bytes
  match tag with
  | 0 => some (.Invalid, rest)
  | 1 => some (.Undetermined, rest)
  | 2 => some (.Valid, rest)
  | _ => none

@[simp] theorem parseJudgment_encodeJudgment (judgment : Axioms.Heyting3) (rest : Bytes) :
    parseJudgment (encodeJudgment judgment rest) = some (judgment, rest) := by
  cases judgment <;> simp [parseJudgment, encodeJudgment]

theorem encodeJudgment_append (judgment : Axioms.Heyting3) (rest suffix : Bytes) :
    encodeJudgment judgment rest ++ suffix = encodeJudgment judgment (rest ++ suffix) := by
  cases judgment <;> exact encodeNat_append _ _ _

/-- The actual complete proposal and Heyting judgment are both vote inputs. -/
def encodeVoteTargetBody (target : Consensus.VoteTarget) (rest : Bytes) : Bytes :=
  encodeProposalBody target.proposal (encodeJudgment target.judgment rest)

def parseVoteBody (bytes : Bytes) : Option (Consensus.VoteTarget × Bytes) := do
  let (proposal, rest) ← parseProposalBody bytes
  let (judgment, rest) ← parseJudgment rest
  some (⟨proposal, judgment⟩, rest)

@[simp] theorem parseVoteBody_encodeVoteTargetBody (target : Consensus.VoteTarget) (rest : Bytes) :
    parseVoteBody (encodeVoteTargetBody target rest) = some (target, rest) := by
  cases target
  simp [parseVoteBody, encodeVoteTargetBody]

theorem encodeVoteTargetBody_append (target : Consensus.VoteTarget) (rest suffix : Bytes) :
    encodeVoteTargetBody target rest ++ suffix = encodeVoteTargetBody target (rest ++ suffix) := by
  simp [encodeVoteTargetBody, encodeProposalBody_append, encodeJudgment_append]

/-- ASCII `HODGE_VOTE_TARGET_V1`. -/
def voteDomain : Bytes :=
  [72, 79, 68, 71, 69, 95, 86, 79, 84, 69, 95, 84, 65, 82, 71, 69, 84, 95, 86, 49]

def encodeVoteTarget (target : Consensus.VoteTarget) : Bytes := voteDomain ++ encodeVoteTargetBody target []

def decodeVoteTarget (bytes : Bytes) : Option Consensus.VoteTarget :=
  match parseVoteBody (bytes.drop voteDomain.length) with
  | none => none
  | some (target, rest) =>
    if rest = [] ∧ bytes = encodeVoteTarget target then some target else none

@[simp] theorem decodeVoteTarget_encode (target : Consensus.VoteTarget) :
    decodeVoteTarget (encodeVoteTarget target) = some target := by
  simp [decodeVoteTarget, encodeVoteTarget]

theorem decodeVoteTarget_eq_some_iff (bytes : Bytes) (target : Consensus.VoteTarget) :
    decodeVoteTarget bytes = some target ↔ bytes = encodeVoteTarget target := by
  constructor
  · intro decoded
    unfold decodeVoteTarget at decoded
    cases parsed : parseVoteBody (bytes.drop voteDomain.length) with
    | none => simp [parsed] at decoded
    | some value =>
      rcases value with ⟨other, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next canonical =>
        have same : other = target := Option.some.inj decoded
        exact canonical.2.trans (congrArg encodeVoteTarget same)
      next => contradiction
  · rintro rfl
    exact decodeVoteTarget_encode target

theorem encodeVoteTarget_injective : Function.Injective encodeVoteTarget := by
  intro first second same
  have parsed := congrArg decodeVoteTarget same
  simpa only [decodeVoteTarget_encode, Option.some.injEq] using parsed

theorem decodeVoteTarget_rejects_trailing (target : Consensus.VoteTarget) (suffix : Bytes)
    (nonempty : suffix ≠ []) : decodeVoteTarget (encodeVoteTarget target ++ suffix) = none := by
  have parsed : parseVoteBody ((encodeVoteTarget target ++ suffix).drop voteDomain.length) = some (target, suffix) := by
    rw [encodeVoteTarget, List.append_assoc, List.drop_left, encodeVoteTargetBody_append]
    simp
  simp [decodeVoteTarget, parsed, nonempty]

theorem decodeVoteTarget_rejects_wrong_domain (bytes : Bytes)
    (wrong : bytes.take voteDomain.length ≠ voteDomain) : decodeVoteTarget bytes = none := by
  cases parsed : decodeVoteTarget bytes with
  | none => rfl
  | some target =>
    have canonical := (decodeVoteTarget_eq_some_iff bytes target).mp parsed
    apply False.elim
    apply wrong
    rw [canonical, encodeVoteTarget, List.take_left]

end HomotopicalEncryption.Protocol.Evidence.TransferCodec
