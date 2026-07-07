import TCB.Runtime
import TCB.SNARK
import Proximity.Problem

/-
  Runtime observation boundary.

  Paper correspondence:
  - Paper 1 Section 5: observed public artifacts expose bounded statements.
  - Paper 2: runtime observation and chain-facing evidence.

  This file names the point where a public artifact becomes an observed
  chain-facing statement. It is intentionally thinner than an oracle: an
  observation is just an accepted, bounded artifact whose public statement
  follows from the proof-carrying statement Rust verified.
-/

namespace Hcrypt
namespace TCB
namespace ObservationBoundary

/--
A runtime-observed public statement carried by a proof-carrying cochain
artifact.

The artifact owns the hash/proof payload. The `publicStatement` is the
chain-facing claim extracted from that payload: for example, a cochain is
well-formed, a projected shadow is near a code, or a public residual is within
the accepted radius.
-/
structure ObservedStatement (R : RuntimeBoundary) where
  artifact : ProofCarryingCommittedCochain
  publicStatement : Prop
  accepted : RuntimeAcceptsProofCarryingCochain R artifact
  statementImpliesPublic : artifact.statement → publicStatement

namespace ObservedStatement

variable {R : RuntimeBoundary}

/-- The canonical cochain payload exposed by an observed statement. -/
def cochain (O : ObservedStatement R) : Axioms.CochainCommitmentData :=
  O.artifact.publicArtifact.cochain

/-- Observed statements expose a well-formed cochain payload. -/
theorem cochain_wellFormed (O : ObservedStatement R) :
    O.cochain.WellFormed :=
  accepted_proofCarryingCochain_implies_cochain_wellFormed O.accepted

/-- The public hash artifact inside an observed statement is well formed. -/
theorem publicArtifact_wellFormed (O : ObservedStatement R) :
    O.artifact.publicArtifact.WellFormed := by
  rcases O.accepted with ⟨_, _, _, _, hArtifact⟩
  exact hArtifact.1

/-- Runtime acceptance recovers the proof-carrying statement itself. -/
theorem artifact_statement_holds (O : ObservedStatement R) :
    O.artifact.statement := by
  rcases O.accepted with ⟨_, _, _, _, hArtifact⟩
  exact hArtifact.2.2.1

/-- Runtime acceptance plus the extraction map gives the public statement. -/
theorem publicStatement_holds (O : ObservedStatement R) :
    O.publicStatement :=
  O.statementImpliesPublic (artifact_statement_holds O)

/-- Convert a SNARK-carrying cochain artifact into a generic observation. -/
def ofSNARK
    (P : SNARKCarryingCommittedCochain)
    (publicStatement : Prop)
    (accepted : RuntimeAcceptsProofCarryingCochain R P.toProofCarrying)
    (statementImpliesPublic : P.statement → publicStatement) :
    ObservedStatement R where
  artifact := P.toProofCarrying
  publicStatement := publicStatement
  accepted := accepted
  statementImpliesPublic := statementImpliesPublic

end ObservedStatement

/--
Observed certificate for one side of a promised gap-proximity decision.

This is the lightweight Lean hook for "proof by observation": the runtime has
accepted a public artifact, and the artifact's statement is definitionally the
near/far claim about the projected instance.
-/
structure ObservedGapDecisionCertificate
    (R : RuntimeBoundary)
    (P : Proximity.GapProximityProblem) where
  x : P.Instance
  decision : Proximity.GapDecision
  observation : ObservedStatement R
  statementMatchesDecision :
    observation.publicStatement =
      match decision with
      | Proximity.GapDecision.accept => P.Near x
      | Proximity.GapDecision.reject => P.Far x

namespace ObservedGapDecisionCertificate

variable {R : RuntimeBoundary} {P : Proximity.GapProximityProblem}

/-- An observed gap decision yields the corresponding certified near/far fact. -/
theorem certifiedStatement (O : ObservedGapDecisionCertificate R P) :
    match O.decision with
    | Proximity.GapDecision.accept => P.Near O.x
    | Proximity.GapDecision.reject => P.Far O.x := by
  exact Eq.mp O.statementMatchesDecision
    (ObservedStatement.publicStatement_holds O.observation)

/-- If the observed decision is accept, the instance is near. -/
theorem near_of_accept
    (O : ObservedGapDecisionCertificate R P)
    (h : O.decision = Proximity.GapDecision.accept) :
    P.Near O.x := by
  simpa [h] using certifiedStatement O

/-- If the observed decision is reject, the instance is far. -/
theorem far_of_reject
    (O : ObservedGapDecisionCertificate R P)
    (h : O.decision = Proximity.GapDecision.reject) :
    P.Far O.x := by
  simpa [h] using certifiedStatement O

end ObservedGapDecisionCertificate

end ObservationBoundary
end TCB
end Hcrypt
