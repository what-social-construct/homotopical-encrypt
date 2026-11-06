module

public import Axioms.Heyting
public import Protocol.Consensus.Committee

@[expose] public section

/-!
  Consensus vote messages and authentication boundary.

  A vote signs one complete `VoteTarget`. In particular, a signature is bound
  to the committee and epoch, block and parent digests, height and round,
  before/after state roots, snapshot/topology/cochain/evidence roots, and the collapsed
  Heyting judgment. Reusing a signature across any of those coordinates is
  therefore outside the Lean verification predicate.

  Lean intentionally leaves the concrete signature type and verification
  algorithm abstract. Rust owns canonical bytes, domain separation, public-key
  verification, and malformed-input rejection.
-/

namespace Hcrypt
namespace Protocol
namespace Consensus

universe u v

/-- All public coordinates identifying one candidate transition and vote round. -/
structure ProposalRef where
  committeeDigest : TCB.Hash32
  epoch : ℕ
  height : ℕ
  round : ℕ
  /-- Protocol phase/step identifier; its state-machine meaning is defined later. -/
  phase : ℕ
  blockDigest : TCB.Hash32
  parentDigest : TCB.Hash32
  beforeStateRoot : TCB.Hash32
  afterStateRoot : TCB.Hash32
  /-- The immutable sheaf snapshot, distinct from topology and cochain roots. -/
  snapshotRoot : TCB.Hash32
  topologyRoot : TCB.Hash32
  cochainRoot : TCB.Hash32
  evidenceRoot : TCB.Hash32

/-- A proposal together with the local Heyting-valued judgment being signed. -/
structure VoteTarget where
  proposal : ProposalRef
  judgment : Axioms.Heyting3

namespace Committee

variable {ValidatorId : Type u}

/-- The proposal explicitly names the committee and epoch authorizing it. -/
def BindsProposal (C : Committee ValidatorId) (P : ProposalRef) : Prop :=
  P.committeeDigest = C.digest ∧ P.epoch = C.epoch

end Committee

namespace VoteTarget

/-- Only the top/valid Heyting judgment is eligible for an acceptance quorum. -/
def IsAccept (T : VoteTarget) : Prop :=
  T.judgment = Axioms.Heyting3.Valid

/-- An undetermined judgment remains a hold and cannot itself finalize. -/
def IsHold (T : VoteTarget) : Prop :=
  T.judgment = Axioms.Heyting3.Undetermined

/-- Bottom/invalid judgment. Rejection policy is defined separately. -/
def IsRejection (T : VoteTarget) : Prop :=
  T.judgment = Axioms.Heyting3.Invalid

theorem hold_not_accept
    {T : VoteTarget}
    (hHold : T.IsHold) :
    ¬ T.IsAccept := by
  unfold IsHold at hHold
  unfold IsAccept
  rw [hHold]
  decide

theorem rejection_not_accept
    {T : VoteTarget}
    (hReject : T.IsRejection) :
    ¬ T.IsAccept := by
  unfold IsRejection at hReject
  unfold IsAccept
  rw [hReject]
  decide

end VoteTarget

/-- Abstract authentication relation for consensus votes. -/
structure VoteAuthentication
    (ValidatorId : Type u)
    (Signature : Type v) where
  Verifies : ValidatorId → VoteTarget → Signature → Prop

/--
An authenticated vote whose signer and complete target are fixed by the type.

Indexing by signer and target prevents a quorum certificate from silently
reinterpreting signature evidence as a vote for another proposal or judgment.
-/
structure AuthenticatedVote
    {ValidatorId : Type u}
    {Signature : Type v}
    (A : VoteAuthentication ValidatorId Signature)
    (signer : ValidatorId)
    (target : VoteTarget) where
  signature : Signature
  verifies : A.Verifies signer target signature

end Consensus
end Protocol
end Hcrypt
