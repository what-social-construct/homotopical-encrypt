module

public import Protocol.Consensus.Vote

@[expose] public section

/-!
  Authenticated weighted quorum certificates.

  A certificate is indexed by one registered committee and authentication
  relation. Its supporters form a `Finset`, so a validator's weight is counted
  at most once. Every supporter supplies an authenticated vote for the exact
  same target, and that target is bound to the committee digest and epoch.

  This module proves quorum intersection and the usual weighted safety kernel:
  with faulty weight strictly below one third, two certificates share a
  non-faulty signer. Rounds, locks, phase transitions, and the rule promoting
  an acceptance quorum to finality remain separate protocol work.
-/

namespace Hcrypt
namespace Protocol
namespace Consensus

universe u v

/-- Proof object certifying authenticated strict-quorum support for one target. -/
structure QuorumCertificate
    {ValidatorId : Type u}
    [DecidableEq ValidatorId]
    {Signature : Type v}
    (C : Committee ValidatorId)
    (A : VoteAuthentication ValidatorId Signature) where
  target : VoteTarget
  committeeBound : C.BindsProposal target.proposal
  supporters : Finset ValidatorId
  quorum : C.IsQuorum supporters
  votes : ∀ v : ↥supporters, AuthenticatedVote A v.1 target

namespace QuorumCertificate

variable {ValidatorId : Type u} [DecidableEq ValidatorId]
variable {Signature : Type v}
variable {C : Committee ValidatorId}
variable {A : VoteAuthentication ValidatorId Signature}

/-- Every certificate supporter is registered in the certificate committee. -/
theorem supporter_registered
    (Q : QuorumCertificate C A)
    (v : ValidatorId)
    (hv : v ∈ Q.supporters) :
    C.Registered v :=
  Q.quorum.1 hv

/-- A certificate carries strictly more than two thirds of total weight. -/
theorem strict_twoThirds
    (Q : QuorumCertificate C A) :
    2 * C.totalWeight < 3 * C.supportWeight Q.supporters :=
  Q.quorum.2

/-- A quorum certificate cannot have an empty signer set. -/
theorem supporters_nonempty
    (Q : QuorumCertificate C A) :
    Q.supporters.Nonempty :=
  C.nonempty_of_isQuorum Q.quorum

/-- At least one registered authenticated vote is recoverable from a certificate. -/
theorem exists_authenticated_vote
    (Q : QuorumCertificate C A) :
    ∃ v : ValidatorId,
      v ∈ Q.supporters
        ∧ C.Registered v
        ∧ Nonempty (AuthenticatedVote A v Q.target) := by
  obtain ⟨v, hv⟩ := Q.supporters_nonempty
  exact ⟨v, hv, Q.supporter_registered v hv, ⟨Q.votes ⟨v, hv⟩⟩⟩

/-- Certificate support for acceptance means its signed judgment is `Valid`. -/
def SupportsAcceptance (Q : QuorumCertificate C A) : Prop :=
  Q.target.IsAccept

/-- A certificate for an undetermined judgment is not an acceptance quorum. -/
theorem hold_not_supportsAcceptance
    (Q : QuorumCertificate C A)
    (hHold : Q.target.IsHold) :
    ¬ Q.SupportsAcceptance :=
  VoteTarget.hold_not_accept hHold

/-- A certificate for an invalid judgment is not an acceptance quorum. -/
theorem rejection_not_supportsAcceptance
    (Q : QuorumCertificate C A)
    (hReject : Q.target.IsRejection) :
    ¬ Q.SupportsAcceptance :=
  VoteTarget.rejection_not_accept hReject

/-- Two certificates from the same committee share a registered signer. -/
theorem certificates_intersect
    (Q₁ Q₂ : QuorumCertificate C A) :
    ∃ v, C.Registered v
      ∧ v ∈ Q₁.supporters
      ∧ v ∈ Q₂.supporters := by
  obtain ⟨v, hv⟩ :=
    C.quorum_intersection_nonempty Q₁.quorum Q₂.quorum
  have hvBoth := Finset.mem_inter.mp hv
  exact ⟨v, Q₁.supporter_registered v hvBoth.1, hvBoth.1, hvBoth.2⟩

/--
Under the standard fault bound, two certificates share a registered
non-faulty signer.
-/
theorem certificates_intersect_nonfaulty
    (Q₁ Q₂ : QuorumCertificate C A)
    (faulty : Finset ValidatorId)
    (hFaultyRegistered : faulty ⊆ C.members)
    (hFaultyWeight : 3 * C.supportWeight faulty < C.totalWeight) :
    ∃ v, C.Registered v
      ∧ v ∈ Q₁.supporters
      ∧ v ∈ Q₂.supporters
      ∧ v ∉ faulty := by
  obtain ⟨v, hv₁, hv₂, hvFaulty⟩ :=
    C.quorum_intersection_contains_nonfaulty
      Q₁.quorum Q₂.quorum hFaultyRegistered hFaultyWeight
  exact ⟨v, Q₁.supporter_registered v hv₁, hv₁, hv₂, hvFaulty⟩

/--
Weighted quorum-safety kernel.

If non-faulty validators never authenticate two different targets in the same
committee/epoch context, two quorum certificates must certify the same target.
This is not yet a full consensus-safety theorem: the round/lock discipline that
establishes the no-double-vote premise belongs in later modules.
-/
theorem target_eq_of_nonfaulty_noDoubleVote
    (Q₁ Q₂ : QuorumCertificate C A)
    (faulty : Finset ValidatorId)
    (hFaultyRegistered : faulty ⊆ C.members)
    (hFaultyWeight : 3 * C.supportWeight faulty < C.totalWeight)
    (hNoDoubleVote :
      ∀ v,
        C.Registered v →
        v ∉ faulty →
        v ∈ Q₁.supporters →
        v ∈ Q₂.supporters →
        Q₁.target = Q₂.target) :
    Q₁.target = Q₂.target := by
  obtain ⟨v, hvRegistered, hv₁, hv₂, hvFaulty⟩ :=
    Q₁.certificates_intersect_nonfaulty
      Q₂ faulty hFaultyRegistered hFaultyWeight
  exact hNoDoubleVote v hvRegistered hvFaulty hv₁ hv₂

end QuorumCertificate

end Consensus
end Protocol
end Hcrypt
