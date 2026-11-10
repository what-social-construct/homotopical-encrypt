module

public import Mathlib.Init

@[expose] public section

/-
  Ledger-flow assumptions (Petri-style / conservation oriented).

  Paper correspondence:
  - Paper 2: ledger/state-transition and conservation contracts.
  - The shared parity register, rather than Paper 1's selected appendix,
    indexes this protocol interface.

  These assumptions align fee-flow and state-transition invariants with the
  implementation's treasury and account update rules.
-/

namespace Hcrypt
namespace Axioms

structure Ledger where
  /-- Total supply conservation under admissible transitions. -/
  Conservation : Prop
  /-- Non-negativity of account balances under admissible transitions. -/
  NonNegativeBalances : Prop
  /-- Treasury distribution is a conservative redistribution (no mint/burn unless explicit). -/
  TreasuryFlowConservative : Prop
  /-- Key-image uniqueness is preserved by state transition. -/
  KeyImageMonotone : Prop

abbrev LedgerWellFormed (L : Ledger) : Prop :=
  L.Conservation
  ∧ L.NonNegativeBalances
  ∧ L.TreasuryFlowConservative
  ∧ L.KeyImageMonotone

end Axioms
end Hcrypt
