module

public import Protocol.Transfer.PublicView
public import Mathlib.Probability.ProbabilityMassFunction.Constructions

@[expose] public section

/-!
# Assembly of the checked transfer release from its variable public fields

For a fixed supplied transfer setup, the base storage payload, selected
ciphertext digest and two evidence byte strings determine the complete checked
release. In particular, the manifest, cochain root, proposal hashes, and canonical packet bytes are
computed from these fields by the original protocol functions. This is a
structural factorization, not a hiding claim for any of its four inputs.
The supplied before-state and functions must be shared and independent of a
challenge before the factorization can be used as a privacy reduction.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.Owned

open Sheaf CellularSheaf
open Evidence.TransferTranscript
open scoped ENNReal

/-- Supplied functions and fixed state used to complete one transfer release. -/
structure PublicAssemblySetup (Owner : Type) where
  before : Ledger.State ℕ ℕ
  hashes : HashSuite Owner
  codec : Evidence.TransferCheck.PacketCodec Owner
  metadata : ProofMetadata
  committeeDigest : TCB.Hash32
  round : ℕ
  phase : ℕ

namespace PublicAssemblySetup

variable {Owner : Type}

/-- The canonical two-slot manifest, computed from its released exact-artifact
and ciphertext names. The ciphertext digest remains a variable input. -/
def manifest (setup : PublicAssemblySetup Owner)
    (base : Storage.PublicPayloadView) (ciphertextDigest : TCB.Hash32) :
    Storage.PublicManifestView Storage.CiphertextManifest.Slot :=
  { base := base
    root := setup.hashes.manifest
      (base, [(.exactArtifact, base.key.cochainDigest), (.fullCiphertext, ciphertextDigest)])
    directory := [(.exactArtifact, base.key.cochainDigest), (.fullCiphertext, ciphertextDigest)] }

def cochainRoot (setup : PublicAssemblySetup Owner)
    (base : Storage.PublicPayloadView) : TCB.Hash32 :=
  setup.hashes.cochainRoot [base.key.cochainDigest]

/-- The original draft before evidence and block hashes are computed. -/
def draft (setup : PublicAssemblySetup Owner)
    (transfer : ResourceTransfer Owner) (base : Storage.PublicPayloadView) :
    ProposalDraft where
  committeeDigest := setup.committeeDigest
  epoch := setup.before.epoch
  height := setup.before.height + 1
  round := setup.round
  phase := setup.phase
  parentDigest := setup.before.tipHash
  beforeStateRoot := setup.hashes.state (StateContent.ofState setup.before)
  afterStateRoot := setup.hashes.state
    (StateContent.afterFor setup.before (transfer.action base.cochain)
      (setup.cochainRoot base))
  snapshotRoot := base.key.snapshotRoot
  topologyRoot := setup.before.topologyRoot
  cochainRoot := setup.cochainRoot base

/-- The signed intent, including the exact original storage input. -/
def intent (setup : PublicAssemblySetup Owner)
    (transfer : ResourceTransfer Owner) (base : Storage.PublicPayloadView)
    (ciphertextDigest : TCB.Hash32) :
    Intent Owner where
  schemaVersion := setup.metadata.schemaVersion
  statementId := setup.metadata.statementId
  policyId := setup.metadata.policyId
  transfer := transfer
  base := base
  beforeEvidenceRoot := setup.before.evidenceRoot
  draft := setup.draft transfer base
  manifestRoot := (setup.manifest base ciphertextDigest).root

/-- The packet retains both evidence byte strings without altering them. -/
def packet (setup : PublicAssemblySetup Owner)
    (transfer : ResourceTransfer Owner) (base : Storage.PublicPayloadView)
    (ciphertextDigest : TCB.Hash32)
    (ownerSignature proofBytes : List UInt8) : ProofPacket Owner where
  metadata := setup.metadata
  intent := setup.intent transfer base ciphertextDigest
  ownerSignature := ownerSignature
  proofBytes := proofBytes

/-- Exact public release assembled using the original canonical codec and hash suite. -/
def view (setup : PublicAssemblySetup Owner)
    (transfer : ResourceTransfer Owner) (base : Storage.PublicPayloadView)
    (ciphertextDigest : TCB.Hash32)
    (ownerSignature proofBytes : List UInt8) : PublicTransferView Owner :=
  let packet := setup.packet transfer base ciphertextDigest ownerSignature proofBytes
  { packetBytes := setup.codec.encode packet
    packet := packet
    proposal := setup.hashes.proposal packet
    manifest := setup.manifest base ciphertextDigest }

variable {Vertex Edge Face Asset Receipt : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

/-- Forget the trusted interpretation and checks, retaining only assembly data. -/
def ofOperational (config : Operational.Config F Owner Asset Receipt) :
    PublicAssemblySetup Owner where
  before := config.before
  hashes := config.hashes
  codec := config.codec
  metadata := config.metadata
  committeeDigest := config.committeeDigest
  round := config.round
  phase := config.phase

@[simp]
theorem ofOperational_manifest (config : Operational.Config F Owner Asset Receipt) :
    (ofOperational config).manifest config.context.publicView config.ciphertextDigest =
      config.manifest.publicView := rfl

@[simp]
theorem ofOperational_intent (config : Operational.Config F Owner Asset Receipt)
    (transfer : ResourceTransfer Owner) :
    (ofOperational config).intent transfer config.context.publicView config.ciphertextDigest =
      config.intentFor transfer := rfl

end PublicAssemblySetup

variable {Vertex Edge Face Owner Asset Receipt : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

/-- Every actually checked release is assembled from its base, released
ciphertext digest and evidence bytes under the same supplied setup. -/
theorem CheckedTransfer.publicView_eq_assembled
    {config : Config F Owner Asset Receipt}
    {transfer : ResourceTransfer Owner} {bytes : List UInt8}
    (checked : CheckedTransfer config transfer bytes) :
    checked.publicView =
      (PublicAssemblySetup.ofOperational config.operational).view transfer
        checked.publicView.base config.ciphertextDigest checked.publicView.packet.ownerSignature
        checked.publicView.packet.proofBytes := by
  let setup := PublicAssemblySetup.ofOperational config.operational
  have hbase := checked.publicView_base
  have hintent := checked.publicView_intent
  have hmetadata := checked.publicView_metadata
  have hpacket : checked.publicView.packet =
      setup.packet transfer checked.publicView.base
        config.ciphertextDigest
        checked.publicView.packet.ownerSignature
        checked.publicView.packet.proofBytes := by
    have hsintent : setup.intent transfer checked.publicView.base config.ciphertextDigest =
        config.intentFor transfer := by
      rw [hbase]
      rfl
    cases h : checked.publicView.packet with
    | mk metadata intent ownerSignature proofBytes =>
      simp only [PublicAssemblySetup.packet]
      congr 1
      · simpa [PublicAssemblySetup.ofOperational, Config.operational, setup,
          PublicTransferView.metadata, h] using hmetadata
      · simpa [h] using hintent.trans hsintent.symm
  apply PublicTransferView.ext
  · rw [PublicAssemblySetup.view]
    change checked.publicView.packetBytes = setup.codec.encode
      (setup.packet transfer checked.publicView.base
        config.ciphertextDigest
        checked.publicView.packet.ownerSignature
        checked.publicView.packet.proofBytes)
    rw [← hpacket]
    exact checked.publicView_canonical
  · exact hpacket
  · rw [PublicAssemblySetup.view]
    change checked.publicView.proposal = setup.hashes.proposal
      (setup.packet transfer checked.publicView.base
        config.ciphertextDigest
        checked.publicView.packet.ownerSignature
        checked.publicView.packet.proofBytes)
    rw [← hpacket]
    exact checked.publicView_proposal_computed
  · rw [PublicAssemblySetup.view, hbase]
    exact checked.publicView_manifest.trans
      (PublicAssemblySetup.ofOperational_manifest config.operational).symm

/-- Two-way event-mass closeness, with no efficiency or asymptotic interpretation. -/
def EventBound {α : Type} (p q : PMF α) (ε : ℝ≥0∞) : Prop :=
  ∀ event : Set α,
    p.toOuterMeasure event ≤ q.toOuterMeasure event + ε ∧
      q.toOuterMeasure event ≤ p.toOuterMeasure event + ε

/-- A common public postprocessing map cannot increase an event-mass bound. -/
theorem EventBound.map {α β : Type} (p q : PMF α) (ε : ℝ≥0∞)
    (h : EventBound p q ε) (f : α → β) :
    EventBound (p.map f) (q.map f) ε := by
  intro event
  simpa only [PMF.toOuterMeasure_map_apply] using h (f ⁻¹' event)

/-- The assembled-view experiment inherits a bound on its actual variable
fields, provided the supplied setup and transfer are shared. -/
theorem assembled_view_eventBound
    (setup : PublicAssemblySetup Owner) (transfer : ResourceTransfer Owner)
    (p q : PMF (Storage.PublicPayloadView × TCB.Hash32 × List UInt8 × List UInt8))
    (ε : ℝ≥0∞) (h : EventBound p q ε) :
    EventBound
      (p.map fun x => setup.view transfer x.1 x.2.1 x.2.2.1 x.2.2.2)
      (q.map fun x => setup.view transfer x.1 x.2.1 x.2.2.1 x.2.2.2) ε :=
  EventBound.map p q ε h
    (fun x => setup.view transfer x.1 x.2.1 x.2.2.1 x.2.2.2)

end HomotopicalEncryption.Protocol.Transfer.Owned
