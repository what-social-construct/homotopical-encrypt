module

public import Axioms.Foundation
public import Axioms.Consensus
public import Axioms.Ledger
public import Axioms.SheafCoherence
public import Axioms.OracleModality
public import TCB.ProofCarrying

@[expose] public section

/-
  Trusted computing base boundary.

  Paper correspondence:
  - Paper 2: explicit Rust/runtime trust and original-object acceptance
    contracts.
  - These proposition-shaped interfaces are outside Paper 1's selected proof
    statements and do not verify a backend by themselves.

  This file is a naming scaffold for the Lean/Rust split. Lean owns the
  mathematical/specification side; Rust owns adversarial runtime validation,
  canonical bytes, proof verification, hash binding, and atomic state updates.

  It intentionally does not claim that Rust is verified by Lean. It records the
  obligations that a production Rust implementation must satisfy before a
  public artifact is treated as consensus-facing evidence.

  The named `Prop` fields are contract assumptions, not data-indexed results
  from actual parsers, keys, messages or proof bytes. The acceptance predicates
  below include already-established semantic facts; raw primitive checks are
  represented separately in `TCB.PrimitiveChecks`.
-/

namespace HomotopicalEncryption
namespace TCB

/-- Lean-owned mathematical/specification bundle. -/
structure LeanSpecBoundary where
  foundation : Axioms.Foundation
  consensus : Axioms.Consensus
  ledger : Axioms.Ledger
  sheaf : Axioms.SheafCoherence

/-- A Lean spec boundary is well formed when each owned component is well formed. -/
def LeanSpecBoundary.WellFormed (S : LeanSpecBoundary) : Prop :=
  Axioms.FoundationWellFormed S.foundation
    ∧ Axioms.ConsensusWellFormed S.consensus
    ∧ Axioms.LedgerWellFormed S.ledger
    ∧ Axioms.SheafCoherenceWellFormed S.sheaf

/--
Rust-owned runtime obligations.

These are production validation facts: byte parsing, hash/proof verification,
oracle attestation checks, and atomic state transition behavior.
-/
structure RuntimeBoundary where
  CanonicalEncoding : Prop
  BoundedAllocation : Prop
  DomainSeparation : Prop
  HashBindingVerified : Prop
  ProofVerificationSound : Prop
  OracleAttestationVerified : Prop
  AtomicStateTransition : Prop
  NoPythonConsensusAuthority : Prop

/-- Runtime boundary well-formedness is the conjunction of Rust-owned obligations. -/
def RuntimeBoundary.WellFormed (R : RuntimeBoundary) : Prop :=
  R.CanonicalEncoding
    ∧ R.BoundedAllocation
    ∧ R.DomainSeparation
    ∧ R.HashBindingVerified
    ∧ R.ProofVerificationSound
    ∧ R.OracleAttestationVerified
    ∧ R.AtomicStateTransition
    ∧ R.NoPythonConsensusAuthority

/-- Combined Lean/Rust TCB contract. -/
structure Contract where
  spec : LeanSpecBoundary
  runtime : RuntimeBoundary

/-- A TCB contract is well formed when both Lean and Rust sides are well formed. -/
def Contract.WellFormed (K : Contract) : Prop :=
  K.spec.WellFormed ∧ K.runtime.WellFormed

/--
Runtime acceptance contract for a proof-carrying cochain artifact.

The artifact itself carries the Lean-side statement/proof-system assumptions.
The runtime side must also verify canonical encoding, hash binding, domain
separation, and proof bytes.

This is the ideal semantic acceptance contract, not a Boolean runtime check.
Through `P.WellFormed` it explicitly includes `P.statement`. Consequently its
consequences recover supplied truth; concrete verifier soundness and any error
estimate must be established separately for actual indexed inputs.
-/
def RuntimeAcceptsProofCarryingCochain
    (R : RuntimeBoundary)
    (P : ProofCarryingCommittedCochain) : Prop :=
  R.CanonicalEncoding
    ∧ R.DomainSeparation
    ∧ R.HashBindingVerified
    ∧ R.ProofVerificationSound
    ∧ P.WellFormed

/-- Runtime acceptance refined by the full sheaf-semantic cochain contract. -/
def RuntimeAcceptsSheafCommittedCochain
    (R : RuntimeBoundary)
    (S : Axioms.SheafCoherence)
    (P : ProofCarryingCommittedCochain) : Prop :=
  RuntimeAcceptsProofCarryingCochain R P
    ∧ P.publicArtifact.cochain.CoherentWith S

/--
The semantic runtime acceptance contract exposes the canonical well-formed
cochain payload already included in its premises.
-/
theorem accepted_proofCarryingCochain_implies_cochain_wellFormed
    {R : RuntimeBoundary} {P : ProofCarryingCommittedCochain}
    (h : RuntimeAcceptsProofCarryingCochain R P) :
    P.publicArtifact.cochain.WellFormed :=
  proofCarrying_cochain_wellFormed h.2.2.2.2

/-- Refined runtime acceptance exposes the full semantic cochain contract. -/
theorem accepted_sheafCommittedCochain_implies_coherentWith
    {R : RuntimeBoundary}
    {S : Axioms.SheafCoherence}
    {P : ProofCarryingCommittedCochain}
    (h : RuntimeAcceptsSheafCommittedCochain R S P) :
    P.publicArtifact.cochain.CoherentWith S :=
  h.2

/--
Runtime acceptance contract for an oracle answer.

The oracle predicate is Lean-owned; runtime still owns the attestation bytes,
domain separation, and endpoint validation around that predicate.
-/
def RuntimeAcceptsOracleAnswer
    (R : RuntimeBoundary)
    (q : Axioms.OracleQuery)
    (a : Axioms.OracleAnswer) : Prop :=
  R.CanonicalEncoding
    ∧ R.DomainSeparation
    ∧ R.OracleAttestationVerified
    ∧ Axioms.OraclePredicate q a

/-- Runtime-accepted oracle answers satisfy the Lean oracle predicate. -/
theorem accepted_oracleAnswer_implies_oraclePredicate
    {R : RuntimeBoundary} {q : Axioms.OracleQuery} {a : Axioms.OracleAnswer}
    (h : RuntimeAcceptsOracleAnswer R q a) :
    Axioms.OraclePredicate q a :=
  h.2.2.2

end TCB
end HomotopicalEncryption
