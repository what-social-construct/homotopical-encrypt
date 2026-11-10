module

public import Protocol.Storage.Anchor
public import Protocol.Storage.Examples
public import Protocol.Ledger.EvidenceExamples

@[expose] public section

/-!
# A concrete sheaf-storage anchor for the positive conservative transfer

The existing two-coordinate storage fixture supplies the actual interpretation,
original hashed artifact, sealed manifest and receipt. The existing ledger
fixture supplies a positive resource transfer. The candidate below joins those
objects through the real sheaf snapshot adapter, candidate-indexed evidence and
an authenticated singleton quorum. Distinct public roots retain distinct roles.

These are explicit equality-based authentication and backend fixtures, not a
cryptographic implementation, disk durability proof or finality theorem.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Storage.AnchorExamples

open Sheaf CellularSheaf

abbrev context : Context Examples.sheaf := Examples.zeroContext

abbrev manifest := Examples.sealed context

abbrev receipt := Examples.receipt context

abbrev runtime := Ledger.EvidenceExamples.runtime

abbrev Snapshot := CochainPayloadInterpretation Examples.sheaf

/-- The topology relation names the actual sheaf snapshot and a separate root. -/
def topologyBinds (snapshot : SheafStateSnapshot Examples.sheaf)
    (root : TCB.Hash32) : Prop :=
  snapshot = Examples.snapshot ∧ root = Ledger.Examples.hash 2

def before : Ledger.State (Fin 2) ℕ :=
  { Ledger.Examples.before with
    snapshotRoot := context.interpretation.snapshot.root }

def action : Ledger.Action (Fin 2) ℕ :=
  { Ledger.Examples.action with cochain := context.cochain }

def proposal : Consensus.ProposalRef :=
  { Ledger.Examples.proposal with
    snapshotRoot := context.interpretation.snapshot.root
    cochainRoot := Ledger.Examples.hash 14 }

def candidate : Ledger.Candidate (Fin 2) ℕ Snapshot where
  before := before
  action := action
  snapshot := context.interpretation
  proposal := proposal

def policy : Ledger.Policy (Fin 2) ℕ Unit Snapshot where
  values := Ledger.Examples.values
  snapshots := Ledger.SnapshotModel.ofSheaf Examples.sheaf topologyBinds
  authorized := fun c => c.action.cochain = context.cochain

theorem candidate_valid : candidate.Valid policy := by
  refine
    { authorized := rfl
      nullifiersNonempty := by decide
      nullifiersNodup := by decide
      fresh := ?_
      enabled := Ledger.Examples.transfer_enabled
      conserves := Ledger.Examples.transfer_conserves
      cochainWellFormed := context.artifactWellFormed.1
      snapshotAccepted := Examples.zero_accepted
      epochMatches := rfl
      heightMatches := rfl
      parentMatches := rfl
      snapshotMatches := rfl
      beforeSnapshotMatches := rfl
      topologyMatches := rfl
      topologyBound := ⟨rfl, rfl⟩ }
  intro n _
  simp [candidate, before, Ledger.Examples.before]

/-- The proof carries the existing storage artifact, not a replacement digest. -/
def proof : TCB.ProofCarryingCommittedCochain where
  publicArtifact := context.artifact
  proofSystem := Ledger.EvidenceExamples.proofSystem
  statement := candidate.Valid policy
  VerifiesStatement := True

theorem proof_wellFormed : proof.WellFormed :=
  ⟨context.artifactWellFormed, ⟨trivial, trivial, trivial, trivial⟩,
    candidate_valid, trivial⟩

def observation : TCB.ObservationBoundary.ObservedStatement runtime where
  artifact := proof
  publicStatement := candidate.Valid policy
  accepted := ⟨trivial, trivial, trivial, trivial, proof_wellFormed⟩
  statementImpliesPublic := fun h => h

def compression : TCB.CompressionBoundary.CompressionContract where
  Full := Unit
  Shadow := Unit
  FullValid := fun _ => candidate.Valid policy
  ShadowValid := fun _ => candidate.Valid policy
  Compresses := fun full shadow => full = shadow
  sound := fun _ h => h
  BindsDigest := fun _ root => root = proposal.evidenceRoot

def compressed :
    TCB.CompressionBoundary.CompressionContract.CompressedShadow compression where
  shadow := ()
  digest := proposal.evidenceRoot
  bindsDigest := rfl

def envelope : TCB.WitnessVerifier.WitnessVerifierEnvelope runtime where
  K := compression
  witness :=
    { witness := ()
      compressed := compressed
      compresses := rfl
      witnessValid := candidate_valid }
  proof := proof
  observation := observation
  proofCarriesShadow :=
    { compressed := compressed
      statementImpliesShadowValid := fun h => h }
  proofCarriesWitnessShadow := rfl
  observationUsesProof := rfl
  stateUpdate :=
    { beforeRoot := proposal.beforeStateRoot
      afterRoot := proposal.afterStateRoot
      transitionDigest := proposal.blockDigest
      BindsPublicInputs := True
      DomainSeparated := True }
  stateUpdateWellFormed := ⟨trivial, trivial⟩

def bindings : Evidence.RootBindings (Fin 2) ℕ Snapshot where
  stateRoot := fun state root =>
    (state = candidate.before ∧ root = proposal.beforeStateRoot) ∨
      (state = candidate.after ∧ root = proposal.afterStateRoot)
  transitionDigest := fun transition digest =>
    transition = candidate ∧ digest = proposal.blockDigest
  cochainIncluded := fun cochain leaf root =>
    cochain = context.cochain ∧ leaf = context.artifact.digest ∧
      root = proposal.cochainRoot
  artifactIncluded := fun transition artifact root =>
    transition = candidate ∧ artifact = context.artifact ∧ root = proposal.evidenceRoot

def evidence : Evidence.Transition runtime policy bindings candidate where
  envelope := envelope
  statementMatches := rfl
  payloadMatches := rfl
  beforeRootMatches := rfl
  afterRootMatches := rfl
  transitionDigestMatches := rfl
  beforeRootBound := Or.inl ⟨rfl, rfl⟩
  afterRootBound := Or.inr ⟨rfl, rfl⟩
  transitionDigestBound := ⟨rfl, rfl⟩
  cochainIncluded := ⟨rfl, rfl, rfl⟩
  artifactIncluded := ⟨rfl, rfl, rfl⟩

def acceptTarget : Consensus.VoteTarget where
  proposal := proposal
  judgment := Axioms.Heyting3.Valid

def quorum : Consensus.QuorumCertificate Ledger.EvidenceExamples.committee
    (Ledger.EvidenceExamples.authenticationFor acceptTarget) :=
  Ledger.EvidenceExamples.quorumFor acceptTarget ⟨rfl, rfl⟩

def certified :
    Ledger.CertifiedTransition runtime policy bindings candidate
      Ledger.EvidenceExamples.committee
      (Ledger.EvidenceExamples.authenticationFor acceptTarget) where
  evidence := evidence
  quorum := quorum
  proposalMatches := rfl
  accepts := rfl

/-- Inclusion names the exact candidate, context, ordered leaves and both roots. -/
def history : HistoryBindings Examples.sheaf (Fin 2) ℕ Examples.Slot Examples.Payload where
  manifestIncluded transition C items root blockDigest :=
    transition = candidate ∧ C = context ∧ items = manifest.manifest.items ∧
      root = manifest.root ∧ blockDigest = proposal.blockDigest

def anchor : TransitionAnchor topologyBinds history evidence context manifest where
  policySnapshots := rfl
  snapshotMatches := rfl
  artifactMatches := rfl
  manifestIncluded := ⟨rfl, rfl, rfl, rfl, rfl⟩

/-- Accepted history refers to this actual snapshot-bound exact payload. -/
theorem anchored_accepted : context.Accepted := anchor.accepted

theorem anchored_update :
    Ledger.AcceptedUpdate policy candidate.before candidate candidate.after :=
  anchor.toAcceptedUpdate

/-- The same candidate also has an acceptance quorum for the complete proposal. -/
theorem certified_update :
    Ledger.AcceptedUpdate policy candidate.before candidate candidate.after :=
  certified.toAcceptedUpdate

/-- The quorum's actual signed block digest authenticates this very manifest. -/
theorem quorum_anchors_same_manifest :
    history.manifestIncluded candidate context manifest.manifest.items manifest.root
      certified.quorum.target.proposal.blockDigest :=
  TransitionAnchor.quorum_manifest_anchored certified anchor

theorem quorum_names_same_snapshot :
    certified.quorum.target.proposal.snapshotRoot = context.key.snapshotRoot :=
  TransitionAnchor.quorum_snapshot_matches certified anchor

/-- The linked update retains the fixture's positive unit of value. -/
theorem anchored_positive_value :
    policy.values.value candidate.after.marking () = 1 :=
  (congrFun anchored_update.value_preserved ()).trans Ledger.Examples.initial_value

theorem anchored_source_distance_zero : context.decodedDistance = 0 :=
  anchor.decodedDistance_eq_zero

/-- The very same seal has a receipt for its actual ordered payload/digest list. -/
theorem anchored_manifest_persisted :
    Examples.scheme.persisted context manifest.manifest.items manifest.root receipt.receipt :=
  anchor.persisted receipt

theorem anchored_local_consumption :
    Checkpoint.Execution
      (.collecting (OpenManifest.empty Examples.scheme context))
      (.consumed manifest receipt) :=
  Examples.complete_execution context

/-- Snapshot, original artifact leaf and manifest name different objects. -/
theorem snapshot_leaf_manifest_distinct :
    context.key.snapshotRoot ≠ context.artifact.digest ∧
      context.artifact.digest ≠ manifest.root ∧
      manifest.root ≠ candidate.proposal.blockDigest := by
  refine ⟨?_, ?_, ?_⟩
  · intro h
    have hByte : (10 : UInt8) = 12 := congrFun h 0
    exact (by decide : (10 : UInt8) ≠ 12) hByte
  · intro h
    have hByte : (12 : UInt8) = 122 := congrFun h 0
    exact (by decide : (12 : UInt8) ≠ 122) hByte
  · intro h
    have hByte : (122 : UInt8) = 7 := congrFun h 0
    exact (by decide : (122 : UInt8) ≠ 7) hByte

/-- A different valid storage run retains the same snapshot and original artifact. -/
def otherRun : Context Examples.sheaf :=
  { context with runId := Ledger.Examples.hash 23 }

/-- Its context and seal cannot be substituted into this history entry. -/
theorem other_run_rejected :
    ¬ Nonempty
      (TransitionAnchor topologyBinds history evidence otherRun (Examples.sealed otherRun)) := by
  rintro ⟨A⟩
  have hContext : otherRun = context := A.manifestIncluded.2.1
  have hByte : (23 : UInt8) = 22 := congrFun (congrArg Context.runId hContext) 0
  exact (by decide : (23 : UInt8) ≠ 22) hByte

/-- Only the snapshot root changes; the fixture's mathematical binding stays explicit. -/
def otherSnapshotContext : Context Examples.sheaf :=
  { context with
    interpretation :=
      { context.interpretation with
        snapshot :=
          { context.interpretation.snapshot with root := Ledger.Examples.hash 99 } }
    boundToSnapshot := context.boundToSnapshot }

/-- A seal/root and artifact alone do not replace the exact snapshot join. -/
theorem other_snapshot_same_artifact_and_manifest_root :
    otherSnapshotContext.artifact = context.artifact ∧
      (Examples.sealed otherSnapshotContext).root = manifest.root :=
  ⟨rfl, rfl⟩

theorem other_snapshot_rejected :
    ¬ Nonempty
      (TransitionAnchor topologyBinds history evidence otherSnapshotContext
        (Examples.sealed otherSnapshotContext)) := by
  rintro ⟨A⟩
  have hRoot := congrArg (fun I : Snapshot => I.snapshot.root) A.snapshotMatches
  have hByte : (10 : UInt8) = 99 := congrFun hRoot 0
  exact (by decide : (10 : UInt8) ≠ 99) hByte

/-- Raw nonexact input can be fully persisted without becoming accepted history. -/
theorem raw_persisted_but_not_anchorable :
    Examples.scheme.persisted Examples.rawContext
      (Examples.sealed Examples.rawContext).manifest.items
      (Examples.sealed Examples.rawContext).root
      (Examples.receipt Examples.rawContext).receipt ∧
      ¬ Nonempty
        (TransitionAnchor topologyBinds history evidence Examples.rawContext
          (Examples.sealed Examples.rawContext)) := by
  refine ⟨(Examples.receipt Examples.rawContext).persisted, ?_⟩
  rintro ⟨A⟩
  exact Examples.raw_not_accepted A.accepted

end HomotopicalEncryption.Protocol.Storage.AnchorExamples
