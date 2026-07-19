import Axioms.Foundation
import Axioms.SheafCoherence

/-
  Exact gates.

  Paper correspondence:
  - Paper 1 Section 4: exact structural preconditions.
  - Paper 1 appendix ledger: theorem-surface row for `Gates.Exact`.

  These are classical structural predicates: cochain-complex laws, Laplacian
  construction, Hodge decomposition/orthogonality, and sheaf-coherence shape
  checks. They are gate-facing aliases over the existing axiom/spec bundles.
-/

namespace Hcrypt
namespace Gates

/-- Foundation-level exact gate bundle. -/
abbrev ExactGateBundle := Hcrypt.Axioms.Foundation

/-- Foundation-level exact gate well-formedness. -/
abbrev ExactGateBundleWellFormed :=
  Hcrypt.Axioms.FoundationWellFormed

/-- Sheaf-level exact gate bundle. -/
abbrev SheafExactGateBundle := Hcrypt.Axioms.SheafCoherence

/-- Sheaf-level exact gate well-formedness. -/
abbrev SheafExactGateBundleWellFormed :=
  Hcrypt.Axioms.SheafCoherenceWellFormed

/-- Full exact-gate contract for a concrete committed one-cochain. -/
abbrev CommittedCochainExactGateWellFormed :=
  Hcrypt.Axioms.CommittedCochainWellFormed

/-- Joint exact-gate bundle used by transaction/block validation. -/
abbrev FoundationWithSheafExactGates :=
  Hcrypt.Axioms.FoundationWithSheafCoherence

/--
Exact sheaf gates provide the structural preconditions needed downstream:
adjacent coboundaries compose to zero, and the Laplacian is built from
coboundaries.
-/
theorem structural_preconditions_of_sheaf_exact_gates
    (S : SheafExactGateBundle) :
    SheafExactGateBundleWellFormed S →
      S.Complex.CoboundarySquaresZero ∧ S.Hodge.LaplacianFromCoboundary :=
  Hcrypt.Axioms.coherence_implies_structural_preconditions S

end Gates
end Hcrypt
