module

public import Protocol.Ledger.Examples
public import Protocol.Ledger.Certified

@[expose] public section

/-!
End-to-end fixtures for the transition/evidence/quorum joins.

These deliberately toy runtime, proof-system, compression, and authentication
contracts exercise the kernel interfaces. They do not implement hashing,
cryptographic verification, witness compression, ownership, or finality. The
underlying action is the nonzero conservative transfer from `Ledger.Examples`.
Root relations below name the actual fixture states, candidate, and artifacts;
they are not predicates accepting every object.
-/

namespace Hcrypt.Protocol.Ledger.EvidenceExamples

open Examples

noncomputable section

def runtime : TCB.RuntimeBoundary where
  CanonicalEncoding := True
  BoundedAllocation := True
  DomainSeparation := True
  HashBindingVerified := True
  ProofVerificationSound := True
  OracleAttestationVerified := True
  AtomicStateTransition := True
  NoPythonConsensusAuthority := True

def proofSystem : Axioms.ZKP where
  Completeness := True
  Soundness := True
  ZeroKnowledge := True
  StatementBinding := True

def artifact : TCB.HashedCommittedCochain where
  cochain := payload
  digest := Examples.hash 12
  Binds := True

def proof : TCB.ProofCarryingCommittedCochain where
  publicArtifact := artifact
  proofSystem := proofSystem
  statement := candidate.Valid policy
  VerifiesStatement := True

theorem proof_wellFormed : proof.WellFormed :=
  ⟨⟨payload_wellFormed, trivial⟩,
    ⟨trivial, trivial, trivial, trivial⟩, candidate_valid, trivial⟩

def observation : TCB.ObservationBoundary.ObservedStatement runtime where
  artifact := proof
  publicStatement := candidate.Valid policy
  accepted := ⟨trivial, trivial, trivial, trivial, proof_wellFormed⟩
  statementImpliesPublic := fun h => h

/-- A unit-carrier compression fixture for the same concrete validity statement. -/
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

/-- Explicit object/root joins for this fixture, including the artifact leaf. -/
def bindings : Evidence.RootBindings (Fin 2) ℕ Unit where
  stateRoot := fun state root =>
    (state = candidate.before ∧ root = proposal.beforeStateRoot) ∨
      (state = candidate.after ∧ root = proposal.afterStateRoot)
  transitionDigest := fun transition digest =>
    transition = candidate ∧ digest = proposal.blockDigest
  cochainIncluded := fun cochain leaf root =>
    cochain = payload ∧ leaf = artifact.digest ∧ root = proposal.cochainRoot
  artifactIncluded := fun transition publicArtifact root =>
    transition = candidate ∧ publicArtifact = artifact ∧ root = proposal.evidenceRoot

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

/-- Full accepted evidence produces the relation for the actual computed update. -/
theorem accepted_update : AcceptedUpdate policy candidate.before candidate candidate.after :=
  evidence.toAcceptedUpdate

def committee : Consensus.Committee Unit where
  digest := proposal.committeeDigest
  epoch := proposal.epoch
  members := {()}
  votingWeight := fun _ => 1
  members_nonempty := by simp
  member_weight_pos := by intro validator hMember; decide

/-- Toy authentication accepts exactly the supplied complete vote target. -/
def authenticationFor (target : Consensus.VoteTarget) :
    Consensus.VoteAuthentication Unit Unit where
  Verifies := fun _ signedTarget _ => signedTarget = target

/-- A genuine singleton quorum with a typed vote for the same complete target. -/
def quorumFor (target : Consensus.VoteTarget)
    (bound : committee.BindsProposal target.proposal) :
    Consensus.QuorumCertificate committee (authenticationFor target) where
  target := target
  committeeBound := bound
  supporters := committee.members
  quorum := committee.members_isQuorum
  votes := fun _ => { signature := (), verifies := rfl }

def acceptTarget : Consensus.VoteTarget where
  proposal := proposal
  judgment := Axioms.Heyting3.Valid

def quorum : Consensus.QuorumCertificate committee (authenticationFor acceptTarget) :=
  quorumFor acceptTarget ⟨rfl, rfl⟩

def certified :
    CertifiedTransition runtime policy bindings candidate committee
      (authenticationFor acceptTarget) where
  evidence := evidence
  quorum := quorum
  proposalMatches := rfl
  accepts := rfl

theorem certified_update :
    AcceptedUpdate policy candidate.before candidate candidate.after :=
  certified.toAcceptedUpdate

/-- The accepted quorum path preserves the fixture's positive unit of value. -/
theorem certified_positive_value :
    policy.values.value candidate.after.marking () = 1 :=
  (congrFun certified_update.value_preserved ()).trans initial_value

/-- A root mutation can remain well-formed at the old TCB boundary. -/
def transplantedEnvelope : TCB.WitnessVerifier.WitnessVerifierEnvelope runtime :=
  { envelope with
    stateUpdate := { envelope.stateUpdate with beforeRoot := Examples.hash 99 }
    stateUpdateWellFormed := ⟨trivial, trivial⟩ }

/-- The new candidate join rejects that envelope's substituted before root. -/
theorem transplanted_root_rejected :
    ¬ ∃ E : Evidence.Transition runtime policy bindings candidate,
      E.envelope = transplantedEnvelope := by
  rintro ⟨E, hEnvelope⟩
  have hRoot := E.beforeRootMatches
  rw [hEnvelope] at hRoot
  have hByte : (99 : UInt8) = 8 := congrFun hRoot 0
  exact (by decide : (99 : UInt8) ≠ 8) hByte

/-- A quorum for the original proposal cannot be transplanted to another parent. -/
theorem transplanted_proposal_rejected :
    ¬ ∃ C : CertifiedTransition runtime policy bindings wrongParent committee
        (authenticationFor acceptTarget), C.quorum = quorum := by
  apply CertifiedTransition.not_of_proposal_ne quorum
  intro hProposal
  have hByte : (3 : UInt8) = 99 :=
    congrFun (congrArg Consensus.ProposalRef.parentDigest hProposal) 0
  exact (by decide : (3 : UInt8) ≠ 99) hByte

/-- This candidate changes only the block digest, which the kernel policy permits. -/
def otherBlock : Candidate (Fin 2) ℕ Unit :=
  { candidate with proposal := { proposal with blockDigest := Examples.hash 99 } }

theorem other_block_valid : otherBlock.Valid policy := by
  rcases candidate_valid with
    ⟨hAuthorized, hNonempty, hNodup, hFresh, hEnabled, hConserves, hCochain,
      hSnapshot, hEpoch, hHeight, hParent, hSnapshotRoot, hBeforeSnapshot,
      hTopology, hTopologyBound⟩
  exact ⟨hAuthorized, hNonempty, hNodup, hFresh, hEnabled, hConserves, hCochain,
    hSnapshot, hEpoch, hHeight, hParent, hSnapshotRoot, hBeforeSnapshot,
    hTopology, hTopologyBound⟩

/-- Both validity propositions hold, so statement equality alone cannot bind a digest. -/
theorem other_block_statement_matches :
    observation.publicStatement = otherBlock.Valid policy :=
  propext ⟨fun _ => other_block_valid, fun _ => candidate_valid⟩

/-- The exact transition-digest join rejects the old envelope for this valid candidate. -/
theorem valid_other_block_old_envelope_rejected :
    ¬ ∃ E : Evidence.Transition runtime policy bindings otherBlock,
      E.envelope = envelope := by
  rintro ⟨E, hEnvelope⟩
  have hDigest := E.transitionDigestMatches
  rw [hEnvelope] at hDigest
  have hByte : (7 : UInt8) = 99 := congrFun hDigest 0
  exact (by decide : (7 : UInt8) ≠ 99) hByte

/-- The exact signed proposal also prevents reusing the old quorum for it. -/
theorem valid_other_block_old_quorum_rejected :
    ¬ ∃ C : CertifiedTransition runtime policy bindings otherBlock committee
        (authenticationFor acceptTarget), C.quorum = quorum := by
  apply CertifiedTransition.not_of_proposal_ne quorum
  intro hProposal
  have hByte : (7 : UInt8) = 99 :=
    congrFun (congrArg Consensus.ProposalRef.blockDigest hProposal) 0
  exact (by decide : (7 : UInt8) ≠ 99) hByte

def holdTarget : Consensus.VoteTarget where
  proposal := proposal
  judgment := Axioms.Heyting3.Undetermined

def holdQuorum : Consensus.QuorumCertificate committee (authenticationFor holdTarget) :=
  quorumFor holdTarget ⟨rfl, rfl⟩

/-- Even an authenticated strict quorum for Hold is not an acceptance certificate. -/
theorem hold_quorum_rejected :
    ¬ ∃ C : CertifiedTransition runtime policy bindings candidate committee
        (authenticationFor holdTarget), C.quorum = holdQuorum := by
  rintro ⟨C, hQuorum⟩
  apply C.not_hold
  rw [hQuorum]
  rfl

end

end Hcrypt.Protocol.Ledger.EvidenceExamples
