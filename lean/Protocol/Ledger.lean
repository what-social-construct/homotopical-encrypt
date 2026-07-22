import Axioms.Ledger
import Chain
import Protocol.Ephemeral
import Protocol.Evidence

/-!
  Ledger and accepted-transition attachment point.

  This module will own typed committed states, candidate transitions,
  key-image/nullifier monotonicity, evidence-root coherence, and the relation
  between quorum-certified blocks and ledger updates. `Chain.lean` remains at
  its current path until its mathematical and protocol concerns are split.
-/
