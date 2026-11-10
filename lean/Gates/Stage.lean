module

public import Axioms.StageAdmissibility

@[expose] public section

/-
  Stage gates.

  Paper correspondence:
  - Paper 2: stage-validation and protocol/runtime gate certificates.
  - These aliases preserve the supplied admissibility contracts; they are not
    Paper 3's near/far comparison theorems.

  Stage gates decide which exact/consensus predicates apply to keygen,
  encryption, transaction, and block contexts.
-/

namespace HomotopicalEncryption
namespace Gates

/-- Pipeline stages mirrored from runtime validation. -/
abbrev PipelineStage := HomotopicalEncryption.Axioms.PipelineStage

/-- Stage-to-consensus admissibility contract. -/
abbrev StageAdmissibility := HomotopicalEncryption.Axioms.StageAdmissibility

/-- Well-formedness for stage admissibility. -/
abbrev StageAdmissibilityWellFormed :=
  HomotopicalEncryption.Axioms.StageAdmissibilityWellFormed

/-- Transaction-stage critical invariant bundle. -/
abbrev TransactionCriticalInvariantBundle :=
  HomotopicalEncryption.Axioms.TransactionCriticalInvariantBundle

/-- Canonical stage admissibility record induced by current axiom bundles. -/
abbrev StageAdmissibilityFromAxioms :=
  HomotopicalEncryption.Axioms.StageAdmissibilityFromAxioms

/-- Python/reference validation snapshot projected to stage-gate facts. -/
abbrev PythonStageValidationSnapshot :=
  HomotopicalEncryption.Axioms.PythonStageValidationSnapshot

/-- Refinement predicate from runtime snapshot to Lean critical-pass fact. -/
abbrev RefinesTransactionCriticalPass :=
  HomotopicalEncryption.Axioms.RefinesTransactionCriticalPass

/-- A refined transaction-stage pass implies consensus admissibility. -/
theorem refined_transaction_implies_admissible
    (py : PythonStageValidationSnapshot)
    (S : StageAdmissibility) :
    StageAdmissibilityWellFormed S →
    RefinesTransactionCriticalPass py S →
    py.stage = HomotopicalEncryption.Axioms.PipelineStage.transaction →
    py.passed = true →
    py.criticalFailures = 0 →
    S.ConsensusAdmissible :=
  HomotopicalEncryption.Axioms.python_refined_transaction_implies_admissible py S

end Gates
end HomotopicalEncryption
