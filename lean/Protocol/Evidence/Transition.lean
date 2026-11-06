module

public import Protocol.Ledger.Transition
public import TCB.WitnessVerifier

@[expose] public section

/-!
  Runtime evidence for one concrete ledger candidate.

  This adapter reuses the witness/verifier envelope. Its observed statement is
  identified with the concrete candidate predicate, and every root relation is
  indexed by the state, candidate, or artifact it authenticates. Concrete hash
  functions, encodings, inclusion proofs, and verifier implementations remain
  runtime refinement obligations.
-/

namespace Hcrypt
namespace Protocol
namespace Evidence

universe u

/-- Object-indexed authentication relations supplied by a runtime root scheme. -/
structure RootBindings (Resource Nullifier : Type) (Snapshot : Type u) where
  stateRoot : Ledger.State Resource Nullifier → TCB.Hash32 → Prop
  transitionDigest : Ledger.Candidate Resource Nullifier Snapshot → TCB.Hash32 → Prop
  /-- Payload, its artifact leaf digest, and the enclosing cochain root. -/
  cochainIncluded :
    Axioms.CochainCommitmentData → TCB.Hash32 → TCB.Hash32 → Prop
  /-- The candidate's public hashed cochain artifact is included under its
  evidence root. Inclusion of serialized proof/verifier metadata is separate
  concrete-profile work; this relation does not take the full proof carrier. -/
  artifactIncluded :
    Ledger.Candidate Resource Nullifier Snapshot →
      TCB.HashedCommittedCochain → TCB.Hash32 → Prop

variable {Resource Nullifier Asset : Type} {Snapshot : Type u}
variable [DecidableEq Nullifier]

/--
An accepted envelope whose statement, payload, and public roots refer to the
same concrete candidate. Candidate validity is derived from the observation;
it is not an additional stored proof field.
-/
structure Transition
    (runtime : TCB.RuntimeBoundary)
    (P : Ledger.Policy Resource Nullifier Asset Snapshot)
    (bindings : RootBindings Resource Nullifier Snapshot)
    (candidate : Ledger.Candidate Resource Nullifier Snapshot) where
  envelope : TCB.WitnessVerifier.WitnessVerifierEnvelope runtime
  statementMatches : envelope.observation.publicStatement = candidate.Valid P
  payloadMatches : envelope.observation.cochain = candidate.action.cochain
  beforeRootMatches : envelope.stateUpdate.beforeRoot = candidate.proposal.beforeStateRoot
  afterRootMatches : envelope.stateUpdate.afterRoot = candidate.proposal.afterStateRoot
  transitionDigestMatches :
    envelope.stateUpdate.transitionDigest = candidate.proposal.blockDigest
  beforeRootBound : bindings.stateRoot candidate.before envelope.stateUpdate.beforeRoot
  afterRootBound : bindings.stateRoot candidate.after envelope.stateUpdate.afterRoot
  transitionDigestBound :
    bindings.transitionDigest candidate envelope.stateUpdate.transitionDigest
  cochainIncluded :
    bindings.cochainIncluded candidate.action.cochain
      envelope.proof.publicArtifact.digest candidate.proposal.cochainRoot
  artifactIncluded :
    bindings.artifactIncluded candidate envelope.proof.publicArtifact
      candidate.proposal.evidenceRoot

namespace Transition

variable {runtime : TCB.RuntimeBoundary}
variable {P : Ledger.Policy Resource Nullifier Asset Snapshot}
variable {bindings : RootBindings Resource Nullifier Snapshot}
variable {candidate : Ledger.Candidate Resource Nullifier Snapshot}

/-- Runtime observation certifies the exact concrete candidate predicate. -/
theorem valid (E : Transition runtime P bindings candidate) : candidate.Valid P :=
  Eq.mp E.statementMatches E.envelope.publicStatement_holds

/-- The observation supplies the accepted relation for the computed update. -/
theorem toAcceptedUpdate (E : Transition runtime P bindings candidate) :
    Ledger.AcceptedUpdate P candidate.before candidate candidate.after :=
  ⟨rfl, E.valid, rfl⟩

/-- The proof artifact carries the same cochain as the candidate action. -/
theorem proof_cochain_eq (E : Transition runtime P bindings candidate) :
    E.envelope.proof.publicArtifact.cochain = candidate.action.cochain := by
  have hPayload := E.payloadMatches
  change E.envelope.observation.artifact.publicArtifact.cochain =
    candidate.action.cochain at hPayload
  rw [E.envelope.observationUsesProof] at hPayload
  exact hPayload

/-- The proposed before root authenticates this candidate's actual before state. -/
theorem before_state_bound (E : Transition runtime P bindings candidate) :
    bindings.stateRoot candidate.before candidate.proposal.beforeStateRoot := by
  rw [← E.beforeRootMatches]
  exact E.beforeRootBound

/-- The proposed after root authenticates the computed successor state. -/
theorem after_state_bound (E : Transition runtime P bindings candidate) :
    bindings.stateRoot candidate.after candidate.proposal.afterStateRoot := by
  rw [← E.afterRootMatches]
  exact E.afterRootBound

/-- The proposal's block digest binds this candidate, including its context. -/
theorem transition_digest_bound (E : Transition runtime P bindings candidate) :
    bindings.transitionDigest candidate candidate.proposal.blockDigest := by
  rw [← E.transitionDigestMatches]
  exact E.transitionDigestBound

/-- An envelope certifying another statement cannot furnish this adapter. -/
theorem not_of_statement_ne
    (envelope : TCB.WitnessVerifier.WitnessVerifierEnvelope runtime)
    (hMismatch : envelope.observation.publicStatement ≠ candidate.Valid P) :
    ¬ ∃ E : Transition runtime P bindings candidate, E.envelope = envelope := by
  rintro ⟨E, rfl⟩
  exact hMismatch E.statementMatches

end Transition

end Evidence
end Protocol
end Hcrypt
