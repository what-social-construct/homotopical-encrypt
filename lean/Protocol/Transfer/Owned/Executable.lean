module

public import Protocol.Transfer.Owned
public import Protocol.Evidence.TransferCodec

@[expose] public section

/-!
# Executable owned transfer for the canonical byte-owner profile

The existing checker uses classical decisions and the ledger uses a
noncomputable finite-support update. This implementation decides the same
resource predicates, compares public inputs through their injective codecs,
and computes the same successor using decidable natural-number operations.
The configured signature, proof, and hash algorithms remain inputs.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.Owned.Executable

open Evidence.TransferTranscript
open Sheaf CellularSheaf

abbrev Bytes := List UInt8

variable {Vertex Edge Face Asset Receipt : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

/-- The actual consume-then-produce calculation on each resource ID. -/
def markingCountAfter (transfer : ResourceTransfer Bytes) (marking : Ledger.Marking ℕ)
    (id : ℕ) : ℕ :=
  marking id - (if id = transfer.input then 1 else 0) +
    (if id = transfer.output then 1 else 0)

private theorem mem_markingSupport (transfer : ResourceTransfer Bytes)
    (marking : Ledger.Marking ℕ) (id : ℕ)
    (active : markingCountAfter transfer marking id ≠ 0) :
    id ∈ insert transfer.input (insert transfer.output marking.support) := by
  by_cases hi : id = transfer.input
  · simp [hi]
  by_cases ho : id = transfer.output
  · simp [ho]
  simp [hi, ho, Finsupp.mem_support_iff]
  simpa [markingCountAfter, hi, ho] using active

def markingAfter (transfer : ResourceTransfer Bytes) (marking : Ledger.Marking ℕ) :
    Ledger.Marking ℕ where
  toFun := markingCountAfter transfer marking
  support := (insert transfer.input (insert transfer.output marking.support)).filter
    (fun id => markingCountAfter transfer marking id ≠ 0)
  mem_support_toFun id := by
    rw [Finset.mem_filter]
    exact ⟨And.right, fun active => ⟨mem_markingSupport transfer marking id active, active⟩⟩

theorem markingAfter_eq (transfer : ResourceTransfer Bytes) (marking : Ledger.Marking ℕ) :
    markingAfter transfer marking = transfer.flow.apply marking := by
  ext id
  change markingCountAfter transfer marking id = transfer.flow.apply marking id
  simp [markingCountAfter, Ledger.ResourceFlow.apply, Ledger.OwnedResource.Transfer.flow,
    Finsupp.single_apply, eq_comm]

/-- Executable counterpart of the pre-evidence state content. -/
def afterContent (transfer : ResourceTransfer Bytes) (before : Ledger.State ℕ ℕ)
    (cochainRoot : TCB.Hash32) : StateContent where
  marking := markingAfter transfer before.marking
  spent := Ledger.Nullifiers.consume before.spent [transfer.input]
  height := before.height + 1
  epoch := before.epoch
  snapshotRoot := before.snapshotRoot
  topologyRoot := before.topologyRoot
  cochainRoot := cochainRoot

theorem afterContent_eq (transfer : ResourceTransfer Bytes) (before : Ledger.State ℕ ℕ)
    (cochain : Axioms.CochainCommitmentData) (cochainRoot : TCB.Hash32) :
    afterContent transfer before cochainRoot =
      StateContent.afterFor before (transfer.action cochain) cochainRoot := by
  unfold afterContent StateContent.afterFor
  rw [markingAfter_eq]
  rfl

def draftFor (config : Config F Bytes Asset Receipt) (transfer : ResourceTransfer Bytes) :
    ProposalDraft where
  committeeDigest := config.committeeDigest
  epoch := config.before.epoch
  height := config.before.height + 1
  round := config.round
  phase := config.phase
  parentDigest := config.before.tipHash
  beforeStateRoot := config.hashes.state (StateContent.ofState config.before)
  afterStateRoot := config.hashes.state (afterContent transfer config.before config.cochainRoot)
  snapshotRoot := config.context.interpretation.snapshot.root
  topologyRoot := config.before.topologyRoot
  cochainRoot := config.cochainRoot

theorem draftFor_eq (config : Config F Bytes Asset Receipt) (transfer : ResourceTransfer Bytes) :
    draftFor config transfer = config.draftFor transfer := by
  unfold draftFor
  rw [afterContent_eq transfer config.before config.context.cochain]
  rfl

def intentFor (config : Config F Bytes Asset Receipt) (transfer : ResourceTransfer Bytes) :
    Intent Bytes where
  schemaVersion := config.metadata.schemaVersion
  statementId := config.metadata.statementId
  policyId := config.metadata.policyId
  transfer := transfer
  base := config.context.publicView
  beforeEvidenceRoot := config.before.evidenceRoot
  draft := draftFor config transfer
  manifestRoot := config.manifest.root

theorem intentFor_eq (config : Config F Bytes Asset Receipt) (transfer : ResourceTransfer Bytes) :
    intentFor config transfer = config.intentFor transfer := by
  unfold intentFor
  rw [draftFor_eq]
  rfl

def resourceCheck [DecidableEq Asset] (catalog : Ledger.OwnedResource.Catalog Bytes Asset)
    (transfer : ResourceTransfer Bytes) (before : Ledger.State ℕ ℕ) : Bool :=
  decide (transfer.signer = catalog.owner transfer.input ∧
    transfer.input ≠ transfer.output ∧ before.marking transfer.input = 1 ∧
    before.marking transfer.output = 0 ∧ transfer.input ∉ before.spent ∧
    transfer.output ∉ before.spent ∧ catalog.asset transfer.input = catalog.asset transfer.output ∧
    catalog.amount transfer.input = catalog.amount transfer.output)

theorem resourceCheck_eq_true_iff [DecidableEq Asset]
    (catalog : Ledger.OwnedResource.Catalog Bytes Asset) (transfer : ResourceTransfer Bytes)
    (before : Ledger.State ℕ ℕ) :
    resourceCheck catalog transfer before = true ↔ ResourceChecks catalog transfer before := by
  rw [resourceCheck, decide_eq_true_eq]
  exact ⟨fun ⟨a,b,c,d,e,f,g,h⟩ => ⟨a,b,c,d,e,f,g,h⟩,
    fun h => ⟨h.signerOwner, h.input_ne_output, h.input_present, h.output_absent,
      h.input_fresh, h.output_fresh, h.same_asset, h.same_amount⟩⟩

def precheck [DecidableEq Asset] (config : Config F Bytes Asset Receipt)
    (transfer : ResourceTransfer Bytes) : Bool :=
  resourceCheck config.catalog transfer config.before &&
    decide (config.context.interpretation.snapshot.root = config.before.snapshotRoot) &&
    decide (config.context.artifact.digest = config.hashes.cochain config.context.cochain)

theorem precheck_eq_true_iff [DecidableEq Asset] (config : Config F Bytes Asset Receipt)
    (transfer : ResourceTransfer Bytes) :
    precheck config transfer = true ↔ Prechecks config transfer := by
  simp only [precheck, Bool.and_eq_true_iff, resourceCheck_eq_true_iff, decide_eq_true_eq]
  exact ⟨fun ⟨⟨a,b⟩,c⟩ => ⟨a,b,c⟩, fun h => ⟨⟨h.resources,h.snapshotMatches⟩,h.leafMatches⟩⟩

private theorem encodeMetadata_eq_iff (left right : ProofMetadata) :
    Evidence.TransferCodec.encodeMetadata left [] = Evidence.TransferCodec.encodeMetadata right [] ↔
      left = right := by
  constructor
  · intro same
    have h := congrArg Evidence.TransferCodec.parseMetadata same
    simpa only [Evidence.TransferCodec.parseMetadata_encodeMetadata, Option.some.injEq,
      Prod.mk.injEq, and_true] using h
  · rintro rfl
    rfl

private theorem encodeIntent_eq_iff (left right : Intent Bytes) :
    Evidence.TransferCodec.encodeIntent left [] = Evidence.TransferCodec.encodeIntent right [] ↔
      left = right := by
  constructor
  · intro same
    have h := congrArg Evidence.TransferCodec.parseIntent same
    simpa only [Evidence.TransferCodec.parseIntent_encodeIntent, Option.some.injEq,
      Prod.mk.injEq, and_true] using h
  · rintro rfl
    rfl

/-- Compare the parsed packet against the exact public inputs and configured verifiers. -/
def packetCheck (config : Config F Bytes Asset Receipt)
    (transfer : ResourceTransfer Bytes) (bytes : Bytes) (packet : ProofPacket Bytes) : Bool :=
  decide (Evidence.TransferCodec.encodeMetadata packet.metadata [] =
    Evidence.TransferCodec.encodeMetadata config.metadata []) &&
  decide (Evidence.TransferCodec.encodeIntent packet.intent [] =
    Evidence.TransferCodec.encodeIntent (intentFor config transfer) []) &&
  decide (bytes = config.codec.encode packet) &&
  config.authorization.verify packet.intent.transfer.signer packet.intent packet.ownerSignature &&
  config.payload.verify packet.intent packet.proofBytes

/-- Run the structural and configured primitive checks on the one parsed packet. -/
def checkedPacket [DecidableEq Asset] (config : Config F Bytes Asset Receipt)
    (transfer : ResourceTransfer Bytes) (bytes : Bytes) : Option (ProofPacket Bytes) :=
  if precheck config transfer then
    (config.codec.decode bytes).filter (packetCheck config transfer bytes)
  else none

theorem checkedPacket_isSome_eq_check [DecidableEq Asset] (config : Config F Bytes Asset Receipt)
    (transfer : ResourceTransfer Bytes) (bytes : Bytes) :
    (checkedPacket config transfer bytes).isSome = check config transfer bytes := by
  classical
  cases pre : precheck config transfer
  · have noPre : ¬ Prechecks config transfer := by
      intro h
      simpa [pre] using (precheck_eq_true_iff config transfer).mpr h
    simp [checkedPacket, pre, check, noPre]
  · have yesPre := (precheck_eq_true_iff config transfer).mp pre
    cases parsed : config.codec.decode bytes with
    | none => simp [checkedPacket, pre, parsed, check, yesPre,
        Evidence.TransferVerifier.check, Evidence.TransferCheck.check,
        Evidence.TransferVerifier.PacketCodec.operational]
    | some packet =>
      rw [checkedPacket, ite_eq_left pre, parsed, Option.isSome_filter, Option.any_some]
      apply Bool.eq_iff_iff.mpr
      simp only [packetCheck, check, Evidence.TransferVerifier.check,
        Evidence.TransferCheck.check, Evidence.TransferVerifier.PacketCodec.operational,
        Evidence.TransferVerifier.Authorization.operational,
        Evidence.TransferVerifier.PayloadVerifier.operational, encodeMetadata_eq_iff,
        encodeIntent_eq_iff, intentFor_eq, Bool.and_eq_true_iff, decide_eq_true_eq,
        parsed, yesPre, true_and]
      constructor
      · rintro ⟨⟨⟨⟨metadata, intent⟩, canonical⟩, owner⟩, payload⟩
        exact ⟨⟨⟨⟨metadata, intent⟩, decide_eq_true canonical⟩, owner⟩, payload⟩
      · rintro ⟨⟨⟨⟨metadata, intent⟩, canonical⟩, owner⟩, payload⟩
        exact ⟨⟨⟨⟨metadata, intent⟩, of_decide_eq_true canonical⟩, owner⟩, payload⟩

theorem checkedPacket_decode [DecidableEq Asset] (config : Config F Bytes Asset Receipt)
    (transfer : ResourceTransfer Bytes) (bytes : Bytes) (packet : ProofPacket Bytes)
    (accepted : checkedPacket config transfer bytes = some packet) :
    config.codec.decode bytes = some packet := by
  by_cases pre : precheck config transfer = true
  · have h : packet ∈ (config.codec.decode bytes).filter (packetCheck config transfer bytes) := by
      rw [checkedPacket, ite_eq_left pre] at accepted
      simp [accepted]
    simpa using (Option.mem_filter_iff.mp h).1
  · simp [checkedPacket, pre] at accepted

def successor (config : Config F Bytes Asset Receipt) (transfer : ResourceTransfer Bytes)
    (packet : ProofPacket Bytes) : Ledger.State ℕ ℕ :=
  let proposal := config.hashes.proposal packet
  (afterContent transfer config.before proposal.cochainRoot).restore
    proposal.blockDigest proposal.evidenceRoot

theorem successor_eq [DecidableEq Asset] (config : Config F Bytes Asset Receipt)
    (transfer : ResourceTransfer Bytes) (bytes : Bytes) (packet : ProofPacket Bytes)
    (accepted : checkedPacket config transfer bytes = some packet) :
    let ok : check config transfer bytes = true :=
      (checkedPacket_isSome_eq_check config transfer bytes).symm.trans
        (congrArg Option.isSome accepted)
    successor config transfer packet = (CheckedTransfer.ofCheck ok).candidate.after := by
  intro ok
  let checked := CheckedTransfer.ofCheck ok
  have packet_eq : packet = checked.proof.packet := Option.some.inj
    ((checkedPacket_decode config transfer bytes packet accepted).symm.trans checked.proof.decoded)
  rw [packet_eq]
  unfold successor
  change (afterContent transfer config.before checked.candidate.proposal.cochainRoot).restore
    checked.candidate.proposal.blockDigest checked.candidate.proposal.evidenceRoot = _
  rw [afterContent_eq transfer config.before config.context.cochain]
  change (StateContent.afterFor checked.candidate.before checked.candidate.action
    checked.candidate.proposal.cochainRoot).restore checked.candidate.after.tipHash
      checked.candidate.after.evidenceRoot = checked.candidate.after
  rw [← StateContent.ofState_after]
  exact StateContent.reconstruct _

def run [DecidableEq Asset] (config : Config F Bytes Asset Receipt)
    (transfer : ResourceTransfer Bytes) (bytes : Bytes) : Option (Ledger.State ℕ ℕ) :=
  (checkedPacket config transfer bytes).map (successor config transfer)

theorem topologyRoot_of_run [DecidableEq Asset] (config : Config F Bytes Asset Receipt)
    (transfer : ResourceTransfer Bytes) (bytes : Bytes) (state : Ledger.State ℕ ℕ)
    (accepted : run config transfer bytes = some state) : state.topologyRoot = config.before.topologyRoot := by
  cases h : checkedPacket config transfer bytes with
  | none => simp [run, h] at accepted
  | some packet =>
    have same : successor config transfer packet = state := by simpa [run, h] using accepted
    rw [← same]
    rfl

end HomotopicalEncryption.Protocol.Transfer.Owned.Executable
