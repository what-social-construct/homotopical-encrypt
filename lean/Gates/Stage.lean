module

public import Axioms.StageAdmissibility

@[expose] public section

/-
  Stage gates.

  Paper correspondence:
  - Paper 1 Section 4 and appendix ledger: stage-admissibility interface
    surface only.
  - Paper 2: stage validation and protocol/runtime gate certificates.

  Stage gates decide which exact/consensus predicates apply to keygen,
  encryption, transaction, and block contexts.
-/

namespace Hcrypt
namespace Gates

/-- Pipeline stages mirrored from runtime validation. -/
abbrev PipelineStage := Hcrypt.Axioms.PipelineStage

/-- Stage-to-consensus admissibility contract. -/
abbrev StageAdmissibility := Hcrypt.Axioms.StageAdmissibility

/-- Well-formedness for stage admissibility. -/
abbrev StageAdmissibilityWellFormed :=
  Hcrypt.Axioms.StageAdmissibilityWellFormed

/-- Transaction-stage critical invariant bundle. -/
abbrev TransactionCriticalInvariantBundle :=
  Hcrypt.Axioms.TransactionCriticalInvariantBundle

/-- Canonical stage admissibility record induced by current axiom bundles. -/
abbrev StageAdmissibilityFromAxioms :=
  Hcrypt.Axioms.StageAdmissibilityFromAxioms

/-- Python/reference validation snapshot projected to stage-gate facts. -/
abbrev PythonStageValidationSnapshot :=
  Hcrypt.Axioms.PythonStageValidationSnapshot

/-- Refinement predicate from runtime snapshot to Lean critical-pass fact. -/
abbrev RefinesTransactionCriticalPass :=
  Hcrypt.Axioms.RefinesTransactionCriticalPass

/-- A refined transaction-stage pass implies consensus admissibility. -/
theorem refined_transaction_implies_admissible
    (py : PythonStageValidationSnapshot)
    (S : StageAdmissibility) :
    StageAdmissibilityWellFormed S →
    RefinesTransactionCriticalPass py S →
    py.stage = Hcrypt.Axioms.PipelineStage.transaction →
    py.passed = true →
    py.criticalFailures = 0 →
    S.ConsensusAdmissible :=
  Hcrypt.Axioms.python_refined_transaction_implies_admissible py S

end Gates
end Hcrypt
