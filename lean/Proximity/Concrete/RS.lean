module

public import Proximity.Concrete.RS.ListDecoding
public import Proximity.Concrete.RS.CorrelatedAgreement
public import Proximity.Concrete.RS.ReedSolomon

@[expose] public section

/-
  Reed-Solomon/code-theory core layer for the proximity pipeline.

  Paper correspondence:
  - Paper 1 Section 6: RS/list-decoding/correlated-agreement/MCA vocabulary.
  - Paper 1 appendix ledger: cited theorem boundary versus Lean-proved
    plumbing.

  This aggregate keeps the prize-side list-decoding, correlated-agreement, and
  RS code-family interfaces together. `Proximity.RS.Target` adds the final
  problem-facing target interface, and `Proximity.CanonicalRS` remains the
  concrete calibrated parameter regime used by the application bridge.
-/
