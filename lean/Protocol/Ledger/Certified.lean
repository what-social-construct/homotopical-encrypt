module

public import Protocol.Evidence.Transition
public import Protocol.Consensus.Quorum

@[expose] public section

/-!
  Acceptance quorums attached to concrete transition evidence.

  A certificate authenticates one complete proposal and a `Valid` judgment.
  This module joins that proposal to runtime evidence about the same candidate.
  It does not define rounds, locks, finality, or concrete signature verification.
-/

namespace HomotopicalEncryption
namespace Protocol
namespace Ledger

universe u v w

variable {Resource Nullifier Asset : Type} {Snapshot : Type u}
variable [DecidableEq Nullifier]
variable {ValidatorId : Type v} [DecidableEq ValidatorId] {Signature : Type w}

/-- Runtime evidence and an acceptance quorum for the same candidate proposal. -/
structure CertifiedTransition
    (runtime : TCB.RuntimeBoundary)
    (P : Policy Resource Nullifier Asset Snapshot)
    (bindings : Evidence.RootBindings Resource Nullifier Snapshot)
    (candidate : Candidate Resource Nullifier Snapshot)
    (committee : Consensus.Committee ValidatorId)
    (authentication : Consensus.VoteAuthentication ValidatorId Signature) where
  evidence : Evidence.Transition runtime P bindings candidate
  quorum : Consensus.QuorumCertificate committee authentication
  proposalMatches : quorum.target.proposal = candidate.proposal
  accepts : quorum.SupportsAcceptance

namespace CertifiedTransition

variable {runtime : TCB.RuntimeBoundary}
variable {P : Policy Resource Nullifier Asset Snapshot}
variable {bindings : Evidence.RootBindings Resource Nullifier Snapshot}
variable {candidate : Candidate Resource Nullifier Snapshot}
variable {committee : Consensus.Committee ValidatorId}
variable {authentication : Consensus.VoteAuthentication ValidatorId Signature}

/-- The quorum-attached runtime evidence certifies this candidate's validity. -/
theorem valid
    (C : CertifiedTransition runtime P bindings candidate committee authentication) :
    candidate.Valid P :=
  C.evidence.valid

/-- Quorum-attached evidence supplies the concrete accepted update relation. -/
theorem toAcceptedUpdate
    (C : CertifiedTransition runtime P bindings candidate committee authentication) :
    AcceptedUpdate P candidate.before candidate candidate.after :=
  C.evidence.toAcceptedUpdate

/-- The candidate names the same committee and epoch as its quorum. -/
theorem committee_bound
    (C : CertifiedTransition runtime P bindings candidate committee authentication) :
    committee.BindsProposal candidate.proposal := by
  rw [← C.proposalMatches]
  exact C.quorum.committeeBound

/-- The actual before-state epoch agrees with the certifying committee. -/
theorem before_epoch_matches_committee
    (C : CertifiedTransition runtime P bindings candidate committee authentication) :
    candidate.before.epoch = committee.epoch :=
  C.valid.epochMatches.symm.trans C.committee_bound.2

/-- A hold judgment cannot serve as this candidate's acceptance certificate. -/
theorem not_hold
    (C : CertifiedTransition runtime P bindings candidate committee authentication) :
    ¬ C.quorum.target.IsHold := by
  intro hHold
  exact C.quorum.hold_not_supportsAcceptance hHold C.accepts

/-- A rejection judgment cannot serve as an acceptance certificate. -/
theorem not_rejection
    (C : CertifiedTransition runtime P bindings candidate committee authentication) :
    ¬ C.quorum.target.IsRejection := by
  intro hReject
  exact C.quorum.rejection_not_supportsAcceptance hReject C.accepts

/-- A quorum for a different complete proposal cannot certify this candidate. -/
theorem not_of_proposal_ne
    (quorum : Consensus.QuorumCertificate committee authentication)
    (hMismatch : quorum.target.proposal ≠ candidate.proposal) :
    ¬ ∃ C : CertifiedTransition runtime P bindings candidate committee authentication,
      C.quorum = quorum := by
  rintro ⟨C, rfl⟩
  exact hMismatch C.proposalMatches

/-- The quorum's signed before root is the root bound to the actual before state. -/
theorem before_state_bound
    (C : CertifiedTransition runtime P bindings candidate committee authentication) :
    bindings.stateRoot candidate.before C.quorum.target.proposal.beforeStateRoot := by
  rw [C.proposalMatches]
  exact C.evidence.before_state_bound

/-- The quorum's signed after root is the root bound to the computed successor. -/
theorem after_state_bound
    (C : CertifiedTransition runtime P bindings candidate committee authentication) :
    bindings.stateRoot candidate.after C.quorum.target.proposal.afterStateRoot := by
  rw [C.proposalMatches]
  exact C.evidence.after_state_bound

end CertifiedTransition

end Ledger
end Protocol
end HomotopicalEncryption
