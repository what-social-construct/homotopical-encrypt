module

public import Mathlib.Init

@[expose] public section

/-
  Consensus-level assumptions used by PoV + Topos implementations.

  Paper correspondence:
  - Paper 2: consensus and Proof-of-Value protocol assumptions.
  - Paper 1 appendix ledger: subsequent protocol-paper boundary only.

  This isolates assumptions that are currently enforced operationally in
  Python/Rust but not yet fully proved end-to-end in Lean.
-/

namespace Hcrypt
namespace Axioms

structure Consensus where
  /-- PoV validity gate: λ₁ is within protocol bounds. -/
  SpectralBounds : Prop
  /-- Topological connectivity gate: β₀ = 1 for admissible producers/blocks. -/
  TopologyConnected : Prop
  /-- In-block key-image uniqueness (double-spend exclusion). -/
  KeyImagesFresh : Prop
  /-- Block-level value conservation (homomorphic balance law). -/
  BalancePreserved : Prop
  /-- Heyting-valued decision rule is coherent with block accept/reject policy. -/
  ToposDecisionCoherent : Prop

abbrev ConsensusWellFormed (C : Consensus) : Prop :=
  C.SpectralBounds
  ∧ C.TopologyConnected
  ∧ C.KeyImagesFresh
  ∧ C.BalancePreserved
  ∧ C.ToposDecisionCoherent

end Axioms
end Hcrypt
