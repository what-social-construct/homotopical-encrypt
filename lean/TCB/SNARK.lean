import TCB.ProofCarrying

/-
  SNARK specialization of the proof-carrying artifact boundary.

  Paper correspondence:
  - Paper 1 Section 5: proof-carrying artifact boundary.
  - Paper 2: concrete proof system and verifier implementation.

  A SNARK is not a core cochain object. It is a succinct certificate that a
  hidden witness satisfies a public statement about a committed object.
-/

namespace Hcrypt
namespace TCB

/--
SNARK interface refining the generic `ZKP` contract.

The concrete proof system, arithmetization, transcript format, and verifier are
Rust-owned runtime artifacts. Lean records the statement-level obligations that
make a SNARK suitable for proof-carrying cochain validation.
-/
structure SNARK where
  zkp : Axioms.ZKP
  /-- The public input is bound to the exact statement/context. -/
  PublicInputBinding : Prop
  /-- The circuit/arithmetization faithfully represents the Lean-side statement. -/
  ArithmetizationSound : Prop
  /-- Verification is succinct relative to the hidden witness/full computation. -/
  SuccinctVerification : Prop
  /-- The proof reveals no witness-identifying data beyond the public statement. -/
  WitnessHiding : Prop

def SNARK.WellFormed (S : SNARK) : Prop :=
  Axioms.ZKPWellFormed S.zkp
    ∧ S.PublicInputBinding
    ∧ S.ArithmetizationSound
    ∧ S.SuccinctVerification
    ∧ S.WitnessHiding

/--
SNARK-carrying committed cochain artifact.

This specializes `ProofCarryingCommittedCochain` to a SNARK proof system while
reusing the same canonical cochain payload and hash-binding layer.
-/
structure SNARKCarryingCommittedCochain where
  publicArtifact : HashedCommittedCochain
  snark : SNARK
  statement : Prop
  VerifiesStatement : Prop

def SNARKCarryingCommittedCochain.WellFormed
    (P : SNARKCarryingCommittedCochain) : Prop :=
  P.publicArtifact.WellFormed
    ∧ P.snark.WellFormed
    ∧ P.statement
    ∧ P.VerifiesStatement

/-- Forget a SNARK-carrying artifact to the generic proof-carrying interface. -/
def SNARKCarryingCommittedCochain.toProofCarrying
    (P : SNARKCarryingCommittedCochain) :
    ProofCarryingCommittedCochain where
  publicArtifact := P.publicArtifact
  proofSystem := P.snark.zkp
  statement := P.statement
  VerifiesStatement := P.VerifiesStatement

/-- A well-formed SNARK-carrying artifact is well formed as a generic proof. -/
theorem snarkCarrying_toProofCarrying_wellFormed
    {P : SNARKCarryingCommittedCochain}
    (hP : P.WellFormed) :
    P.toProofCarrying.WellFormed := by
  rcases hP with ⟨hPublic, hSnark, hStmt, hVerify⟩
  exact ⟨hPublic, hSnark.1, hStmt, hVerify⟩

/-- A well-formed SNARK-carrying artifact exposes a well-formed cochain payload. -/
theorem snarkCarrying_cochain_wellFormed
    {P : SNARKCarryingCommittedCochain}
    (hP : P.WellFormed) :
    P.publicArtifact.cochain.WellFormed :=
  proofCarrying_cochain_wellFormed
    (snarkCarrying_toProofCarrying_wellFormed hP)

end TCB
end Hcrypt
