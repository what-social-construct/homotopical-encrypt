module

public import Axioms.CochainCommitment.Payload
public import Axioms.SheafCoherence
public import Axioms.ZKP

@[expose] public section

/-
  Proof-carrying public artifacts.

  Paper correspondence:
  - Paper 2: proof-carrying payload/statement contracts and their consumption
    as protocol evidence.
  - Paper 1 Section 5 distinguishes those public statements from the
    mathematical full Hodge sample.

  Core mathematical objects should not become hashes or SNARKs themselves.
  Instead, runtime/public layers carry commitments and certificates that bind
  back to the core objects.

  These legacy carriers package semantic facts under supplied contracts. In
  particular, `ProofCarryingCommittedCochain.WellFormed` includes the truth of
  its statement as a premise. It is not an execution trace or a theorem that a
  concrete byte verifier establishes that statement. Raw primitive algorithms
  and byte-indexed failure events live in `TCB.PrimitiveChecks`.
-/

namespace Hcrypt
namespace TCB

/-- Canonical 32-byte hash/digest shape used by public chain artifacts. -/
abbrev Hash32 := Fin 32 → UInt8

/--
Public hash commitment to an existing cochain commitment payload.

`Binds` is intentionally a proposition: a runtime instantiation must supply
the concrete hash function, domain separation, serialization and byte
validation. This field alone identifies no algorithm or authenticated bytes.
-/
structure HashedCommittedCochain where
  cochain : Axioms.CochainCommitmentData
  digest : Hash32
  Binds : Prop

/-- Well-formed hash artifacts bind to a well-formed cochain payload. -/
def HashedCommittedCochain.WellFormed
    (H : HashedCommittedCochain) : Prop :=
  H.cochain.WellFormed ∧ H.Binds

/-- A hash artifact whose payload satisfies the full sheaf-semantic contract. -/
def HashedCommittedCochain.CoherentWith
    (S : Axioms.SheafCoherence)
    (H : HashedCommittedCochain) : Prop :=
  H.cochain.CoherentWith S ∧ H.Binds

/-- Sheaf-coherent hash artifacts inherit ordinary payload/hash validity. -/
theorem HashedCommittedCochain.wellFormed_of_coherentWith
    {S : Axioms.SheafCoherence}
    {H : HashedCommittedCochain}
    (h : H.CoherentWith S) :
    H.WellFormed :=
  ⟨Axioms.cochain_wellFormed_of_committedCochainWellFormed h.1, h.2⟩

/--
SNARK/ZK certificate for a committed cochain statement.

The statement is kept abstract so this interface can serve proximity,
naturality, global-section, balance, or homotopy-path statements without
conflating those predicates with the proof system itself.

The carrier contains no proof bytes or verification algorithm. Its
`VerifiesStatement` label alone does not imply `statement`; the semantic
well-formedness contract requires both facts separately.
-/
structure ProofCarryingCommittedCochain where
  publicArtifact : HashedCommittedCochain
  proofSystem : Axioms.ZKP
  statement : Prop
  VerifiesStatement : Prop

/-- Semantic packaging of an already-true statement and its verification fact.
This is not a soundness theorem about a concrete byte-checking algorithm. -/
def ProofCarryingCommittedCochain.WellFormed
    (P : ProofCarryingCommittedCochain) : Prop :=
  P.publicArtifact.WellFormed
    ∧ Axioms.ZKPWellFormed P.proofSystem
    ∧ P.statement
    ∧ P.VerifiesStatement

/-- A proof-carrying artifact whose public payload is coherent with `S`. -/
def ProofCarryingCommittedCochain.CoherentWith
    (S : Axioms.SheafCoherence)
    (P : ProofCarryingCommittedCochain) : Prop :=
  P.publicArtifact.CoherentWith S
    ∧ Axioms.ZKPWellFormed P.proofSystem
    ∧ P.statement
    ∧ P.VerifiesStatement

/-- Sheaf-coherent proof artifacts inherit ordinary proof-carrying validity. -/
theorem ProofCarryingCommittedCochain.wellFormed_of_coherentWith
    {S : Axioms.SheafCoherence}
    {P : ProofCarryingCommittedCochain}
    (h : P.CoherentWith S) :
    P.WellFormed :=
  ⟨HashedCommittedCochain.wellFormed_of_coherentWith h.1, h.2⟩

/-- A coherent proof artifact exposes the full semantic cochain contract. -/
theorem proofCarrying_cochain_coherentWith
    {S : Axioms.SheafCoherence}
    {P : ProofCarryingCommittedCochain}
    (h : P.CoherentWith S) :
    P.publicArtifact.cochain.CoherentWith S :=
  h.1.1

/-- Proof-carrying artifacts expose the underlying committed cochain payload. -/
theorem proofCarrying_cochain_wellFormed
    {P : ProofCarryingCommittedCochain}
    (hP : P.WellFormed) :
    P.publicArtifact.cochain.WellFormed :=
  hP.1.1

end TCB
end Hcrypt
