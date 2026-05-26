import Axioms.CochainCommitment.Payload
import Axioms.ZKP

/-
  Proof-carrying public artifacts.

  Core mathematical objects should not become hashes or SNARKs themselves.
  Instead, runtime/public layers carry commitments and certificates that bind
  back to the core objects.
-/

namespace Hcrypt
namespace TCB

/-- Canonical 32-byte hash/digest shape used by public chain artifacts. -/
abbrev Hash32 := Fin 32 → UInt8

/--
Public hash commitment to an existing cochain commitment payload.

`Binds` is intentionally a proposition: Rust owns the concrete hash function,
domain separation, serialization, and byte validation.
-/
structure HashedCommittedCochain where
  cochain : Axioms.CochainCommitmentData
  digest : Hash32
  Binds : Prop

/-- Well-formed hash artifacts bind to a well-formed cochain payload. -/
def HashedCommittedCochain.WellFormed
    (H : HashedCommittedCochain) : Prop :=
  H.cochain.WellFormed ∧ H.Binds

/--
SNARK/ZK certificate for a committed cochain statement.

The statement is kept abstract so this interface can serve proximity,
naturality, global-section, balance, or homotopy-path statements without
conflating those predicates with the proof system itself.
-/
structure ProofCarryingCommittedCochain where
  publicArtifact : HashedCommittedCochain
  proofSystem : Axioms.ZKP
  statement : Prop
  VerifiesStatement : Prop

/-- A proof-carrying cochain artifact is well formed at the Lean boundary. -/
def ProofCarryingCommittedCochain.WellFormed
    (P : ProofCarryingCommittedCochain) : Prop :=
  P.publicArtifact.WellFormed
    ∧ Axioms.ZKPWellFormed P.proofSystem
    ∧ P.statement
    ∧ P.VerifiesStatement

/-- Proof-carrying artifacts expose the underlying committed cochain payload. -/
theorem proofCarrying_cochain_wellFormed
    {P : ProofCarryingCommittedCochain}
    (hP : P.WellFormed) :
    P.publicArtifact.cochain.WellFormed :=
  hP.1.1

end TCB
end Hcrypt
