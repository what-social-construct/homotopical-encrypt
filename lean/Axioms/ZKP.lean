import Mathlib

/-
  ZKP interface assumptions.

  Paper correspondence:
  - Paper 1 Section 5: proof-carrying artifact boundary.
  - Paper 2: concrete proof system and protocol evidence.

  These assumptions are intentionally abstract so different concrete proof
  systems (spectral range proof, homotopy/geodesic proof, class-membership
  proof) can refine this interface.
-/

namespace Hcrypt
namespace Axioms

structure ZKP where
  /-- Completeness: honest prover with valid witness verifies. -/
  Completeness : Prop
  /-- Soundness: verifier acceptance implies statement validity (up to security error). -/
  Soundness : Prop
  /-- Zero-knowledge: transcript leaks no witness-identifying information. -/
  ZeroKnowledge : Prop
  /-- Binding to topology/instance context (domain separation + statement binding). -/
  StatementBinding : Prop

abbrev ZKPWellFormed (Z : ZKP) : Prop :=
  Z.Completeness
  ∧ Z.Soundness
  ∧ Z.ZeroKnowledge
  ∧ Z.StatementBinding

end Axioms
end Hcrypt
