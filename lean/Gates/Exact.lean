module

public import Axioms.Foundation
public import Axioms.SheafCoherence

@[expose] public section

/-
  Exact gates.

  Paper correspondence:
  - Paper 2: exact structural predicates exposed through the existing
    cochain/Hodge and coherence contract bundles.
  - Paper 1 proves its finite Hodge statements separately; these aliases do
    not establish a runtime validator.

  These are classical structural predicates: cochain-complex laws, Laplacian
  construction, Hodge decomposition/orthogonality, and sheaf-coherence shape
  checks. They are gate-facing aliases over the existing axiom/spec bundles.
-/

namespace HomotopicalEncryption
namespace Gates

/-- Foundation-level exact gate bundle. -/
abbrev ExactGateBundle := HomotopicalEncryption.Axioms.Foundation

/-- Foundation-level exact gate well-formedness. -/
abbrev ExactGateBundleWellFormed :=
  HomotopicalEncryption.Axioms.FoundationWellFormed

/-- Sheaf-level exact gate bundle. -/
abbrev SheafExactGateBundle := HomotopicalEncryption.Axioms.SheafCoherence

/-- Sheaf-level exact gate well-formedness. -/
abbrev SheafExactGateBundleWellFormed :=
  HomotopicalEncryption.Axioms.SheafCoherenceWellFormed

/-- Full exact-gate contract for a concrete committed one-cochain. -/
abbrev CommittedCochainExactGateWellFormed :=
  HomotopicalEncryption.Axioms.CommittedCochainWellFormed

/-- Joint exact-gate bundle used by transaction/block validation. -/
abbrev FoundationWithSheafExactGates :=
  HomotopicalEncryption.Axioms.FoundationWithSheafCoherence

/--
Exact sheaf gates provide the structural preconditions needed downstream:
adjacent coboundaries compose to zero, and the Laplacian is built from
coboundaries.
-/
theorem structural_preconditions_of_sheaf_exact_gates
    (S : SheafExactGateBundle) :
    SheafExactGateBundleWellFormed S →
      S.Complex.CoboundarySquaresZero ∧ S.Hodge.LaplacianFromCoboundary :=
  HomotopicalEncryption.Axioms.coherence_implies_structural_preconditions S

end Gates
end HomotopicalEncryption
