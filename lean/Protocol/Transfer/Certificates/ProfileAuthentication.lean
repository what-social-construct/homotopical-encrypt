module

public import Protocol.Transfer.Certificates.Profile
public import Protocol.Evidence.TransferCodec
public import TCB.PrimitiveChecks

@[expose] public section

/-!
# Actual byte-signature verification for profile approval quorums

The existing consensus authentication relation is constructed from the selected
signature verifier and existing validator-to-key map. Every authenticated vote
therefore executes that algorithm on the canonical encoding of its complete
original `VoteTarget`, including all proposal fields and the Heyting judgment.
The original committee, supporters, weights and exact quorum target remain
unchanged. No second committee, mutable registry or finality rule is defined.

For profile approval, those actual votes sign the proposal containing the
dedicated canonical descriptor root. Distinct evidence roots, epochs or other
proposal coordinates give distinct signed message bytes without assuming
global hash injectivity. Message distinction does not establish signature
unforgeability, possession of a signing key, honest key registration, correct
setup generation or cryptographic binding of the descriptor hash. Those
primitive/bootstrap assumptions remain explicit, and the backend may be a
standard signature verifier or a separately instantiated CRS verifier.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.Certificates.ProfileAuthentication

open Consensus
open TCB.PrimitiveChecks
open _root_.HomotopicalEncryption.Protocol.Evidence.TransferCodec
  (encodeVoteTarget encodeVoteTarget_injective)

abbrev Bytes := List UInt8

variable {Validator Key : Type}

/-- The actual finite byte-verification operation for one complete vote. -/
def verify (backend : SignatureVerifier Key) (keyFor : Validator → Key)
    (validator : Validator) (target : VoteTarget) (signature : Bytes) : Bool :=
  backend.verify (keyFor validator) (encodeVoteTarget target) signature

/-- Construct the original consensus interface from actual algorithm execution.
No abstract `Verifies` label or implicit signature soundness law is supplied. -/
def authentication (backend : SignatureVerifier Key) (keyFor : Validator → Key) :
    VoteAuthentication Validator Bytes where
  Verifies validator target signature := verify backend keyFor validator target signature = true

/-- A verified byte signature produces the existing indexed vote carrier. -/
def voteOfVerified (backend : SignatureVerifier Key) (keyFor : Validator → Key)
    (validator : Validator) (target : VoteTarget) (signature : Bytes)
    (verified : verify backend keyFor validator target signature = true) :
    AuthenticatedVote (authentication backend keyFor) validator target where
  signature := signature
  verifies := verified

/-- The original authenticated vote exposes the exact selected backend call. -/
theorem authenticated_vote_verified (backend : SignatureVerifier Key)
    (keyFor : Validator → Key) {validator : Validator} {target : VoteTarget}
    (vote : AuthenticatedVote (authentication backend keyFor) validator target) :
    backend.verify (keyFor validator) (encodeVoteTarget target)
      vote.signature = true := vote.verifies

/-- Exact message bytes identify the complete original target and judgment. -/
theorem message_eq_iff (first second : VoteTarget) :
    encodeVoteTarget first = encodeVoteTarget second ↔
      first = second :=
  ⟨fun same => encodeVoteTarget_injective same,
    congrArg encodeVoteTarget⟩

theorem complete_target_eq_of_message_eq {first second : VoteTarget}
    (same : encodeVoteTarget first =
      encodeVoteTarget second) :
    first.proposal = second.proposal ∧ first.judgment = second.judgment := by
  have targetEq := (message_eq_iff first second).1 same
  exact ⟨congrArg VoteTarget.proposal targetEq, congrArg VoteTarget.judgment targetEq⟩

/-- Changing any proposal field changes the actual signed input bytes. -/
theorem message_ne_of_proposal_ne {first second : VoteTarget}
    (different : first.proposal ≠ second.proposal) :
    encodeVoteTarget first ≠ encodeVoteTarget second := by
  intro same
  exact different (complete_target_eq_of_message_eq same).1

theorem message_ne_of_evidenceRoot_ne {first second : VoteTarget}
    (different : first.proposal.evidenceRoot ≠ second.proposal.evidenceRoot) :
    encodeVoteTarget first ≠ encodeVoteTarget second := by
  apply message_ne_of_proposal_ne
  intro proposalEq
  exact different (congrArg ProposalRef.evidenceRoot proposalEq)

theorem message_ne_of_epoch_ne {first second : VoteTarget}
    (different : first.proposal.epoch ≠ second.proposal.epoch) :
    encodeVoteTarget first ≠ encodeVoteTarget second := by
  apply message_ne_of_proposal_ne
  intro proposalEq
  exact different (congrArg ProposalRef.epoch proposalEq)

theorem message_ne_of_committee_ne {first second : VoteTarget}
    (different : first.proposal.committeeDigest ≠ second.proposal.committeeDigest) :
    encodeVoteTarget first ≠ encodeVoteTarget second := by
  apply message_ne_of_proposal_ne
  intro proposalEq
  exact different (congrArg ProposalRef.committeeDigest proposalEq)

theorem message_ne_of_judgment_ne {first second : VoteTarget}
    (different : first.judgment ≠ second.judgment) :
    encodeVoteTarget first ≠ encodeVoteTarget second := by
  intro same
  exact different (complete_target_eq_of_message_eq same).2

variable [DecidableEq Validator] {committee : Committee Validator}

/-- Every actual quorum supporter's original signature verifies on that same
quorum's complete canonical target; no detached signature list is introduced. -/
theorem quorum_supporter_verified (backend : SignatureVerifier Key)
    (keyFor : Validator → Key)
    (quorum : QuorumCertificate committee (authentication backend keyFor))
    (validator : ↥quorum.supporters) :
    backend.verify (keyFor validator.val)
      (encodeVoteTarget quorum.target)
      (quorum.votes validator).signature = true :=
  authenticated_vote_verified backend keyFor (quorum.votes validator)

variable {hash : Bytes → TCB.Hash32}

/-- A profile approval's existing quorum authenticates its exact descriptor
root using actual complete-target byte verification for every supporter. -/
theorem approval_registration_verified (backend : SignatureVerifier Key)
    (keyFor : Validator → Key)
    (approval : Profile.Approval committee (authentication backend keyFor) hash) :
    approval.quorum.target.proposal.evidenceRoot = Profile.rootDigest hash approval.descriptor ∧
      approval.quorum.target.proposal.epoch = committee.epoch ∧
      approval.quorum.target.judgment = Axioms.Heyting3.Valid ∧
      ∀ validator : ↥approval.quorum.supporters,
        backend.verify (keyFor validator.val)
          (encodeVoteTarget approval.quorum.target)
          (approval.quorum.votes validator).signature = true :=
  ⟨approval.canonical_root, approval.committee_epoch, approval.accepts,
    quorum_supporter_verified backend keyFor approval.quorum⟩

/-- The exact canonical descriptor bytes retained by the approval determine
the registration preimage signed through the proposal's evidence-root field. -/
theorem approval_registration_bytes (backend : SignatureVerifier Key)
    (keyFor : Validator → Key)
    (approval : Profile.Approval committee (authentication backend keyFor) hash) :
    approval.bytes = Profile.encode approval.descriptor ∧
      approval.quorum.target.proposal.evidenceRoot = hash (Profile.rootPreimage approval.bytes) ∧
      ∀ validator : ↥approval.quorum.supporters,
        verify backend keyFor validator.val approval.quorum.target
          (approval.quorum.votes validator).signature = true :=
  ⟨approval.canonical, approval.rootBound,
    quorum_supporter_verified backend keyFor approval.quorum⟩

/-- Fetching profile bytes under this actually signed registration root returns
the approved descriptor or an unequal registration preimage with the same hash. -/
theorem approval_read_original_or_collision (backend : SignatureVerifier Key)
    (keyFor : Validator → Key)
    (approval : Profile.Approval committee (authentication backend keyFor) hash)
    (bytes : Bytes) (returned : Profile.Descriptor)
    (accepted : Profile.check hash approval.quorum.target.proposal.evidenceRoot bytes = some returned) :
    returned = approval.descriptor ∨
      (Profile.rootPreimage bytes ≠ Profile.rootPreimage (Profile.encode approval.descriptor) ∧
        hash (Profile.rootPreimage bytes) = hash (Profile.rootPreimage (Profile.encode approval.descriptor))) :=
  approval.checked_descriptor_or_collision bytes returned accepted

end HomotopicalEncryption.Protocol.Transfer.Certificates.ProfileAuthentication
