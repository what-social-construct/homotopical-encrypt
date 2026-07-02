import Proximity.RS.ListDecoding
import Proximity.RS.CorrelatedAgreement
import Proximity.RS.ReedSolomon

/-
  Reed-Solomon/code-theory core layer for the proximity pipeline.

  This aggregate keeps the prize-side list-decoding, correlated-agreement, and
  RS code-family interfaces together. `Proximity.RS.Target` adds the final
  problem-facing target interface, and `Proximity.CanonicalRS` remains the
  concrete calibrated parameter regime used by the hcrypt bridge.
-/
