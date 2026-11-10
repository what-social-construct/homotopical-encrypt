module

public import Mathlib.Init

@[expose] public section

/-
  Foundational assumptions for the cochain/Hodge surface.

  Paper correspondence:
  - Paper 1 Section 2 uses the proved finite cellular Hodge construction in
    Sheaf/Hodge.lean.
  - This separate assumption-oriented interface supplies named cochain/Hodge
    contracts for Paper 2; it does not replace those finite proofs.

  This module is intentionally assumption-oriented: it captures the exact
  preconditions the implementation relies on, even where full Lean proofs are
  still in progress in other modules.
-/

namespace Hcrypt
namespace Axioms

/--
  Foundational axiom bundle.

  Each field is a `Prop` assumption that downstream axiom/gate interfaces may
  consume and that implementation layers are expected to realize via concrete
  Python/Rust code:

  | Foundation field        | Python module                   | Rust module                        |
  |-------------------------|---------------------------------|------------------------------------|
  | CochainComplex          | archived Python prototype       | rust/node/src/crypto/commitment.rs |
  | CoboundaryLinearity     | CochainComplex.coboundary()     | CochainComplex::apply_coboundary() |
  | LaplacianFromCoboundary | src/geometry/sheaf_laplacian.py  | rust/oracle/src/geometry.rs        |
  | HodgeDecomposition      | src/geometry/hodge.py           | planned: rust/oracle/src/geometry.rs |
  | HodgeOrthogonality      | src/geometry/hodge.py           | planned: rust/oracle/src/geometry.rs |
  Commitment authentication, hiding, context binding, and partial-opening
  security are intentionally absent. They belong to the separate
  `Axioms.CochainCommitment` interface and are not consequences of the
  cochain-complex or Hodge identities.
-/
structure Foundation where
  /-- Cochain complex law: adjacent coboundaries compose to zero. -/
  CochainComplex : Prop
  /-- Coboundary linearity: δ(a + b) = δ(a) + δ(b), δ(k·a) = k·δ(a). -/
  CoboundaryLinearity : Prop
  /-- Hodge--Laplacian construction law from adjacent coboundaries and adjoints. -/
  LaplacianFromCoboundary : Prop
  /-- Hodge decomposition law, e.g. C¹ = H¹ ⊕ im(δ₀) ⊕ im(δ₁*). -/
  HodgeDecomposition : Prop
  /-- Pairwise orthogonality law for H/im(δ)/im(δ*) components. -/
  HodgeOrthogonality : Prop

abbrev FoundationWellFormed (F : Foundation) : Prop :=
  F.CochainComplex
  ∧ F.CoboundaryLinearity
  ∧ F.LaplacianFromCoboundary
  ∧ F.HodgeDecomposition
  ∧ F.HodgeOrthogonality

end Axioms
end Hcrypt
