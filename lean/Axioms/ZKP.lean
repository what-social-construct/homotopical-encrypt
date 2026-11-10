module

public import Mathlib.Init

@[expose] public section

/-
  ZKP interface assumptions.

  Paper correspondence:
  - Paper 2: supplied proof-system soundness/completeness interfaces and their
    relation to public protocol evidence.
  - These contracts are not a concrete proof construction or a result of Paper
    1's mathematical observation boundaries.

  These assumptions are intentionally abstract so different concrete proof
  systems (spectral range proof, homotopy/geodesic proof, class-membership
  proof) can refine this interface.

  These fields name assumptions. They contain no actual verifier, public-input
  encoding, proof bytes, sampling game or numerical error bound, and do not
  establish the properties of a runtime backend from its name alone.
-/

namespace Hcrypt
namespace Axioms

structure ZKP where
  /-- Completeness: honest prover with valid witness verifies. -/
  Completeness : Prop
  /-- Named soundness assumption; an indexed verifier law and any sampled
      security-error bound must be supplied separately. -/
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
