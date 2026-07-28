import ProximityPrize.BlockCode
import ProximityPrize.ReedSolomon
import ProximityPrize.PlanePair
import ProximityPrize.Parameters

/-!
# Capacity-radius proximity: proved infrastructure

This aggregate is the standalone Lean surface for the proximity-prize paper.
It currently exports only proved definitions, equivalences, and arithmetic.

Deliberately absent:

* a capacity-radius interleaved list-decoding theorem;
* a capacity-radius mutual-correlated-agreement theorem;
* axioms or placeholders asserting either target.

Those modules should be added only when their theorem statements and proofs are
ready. The application-facing `Hcrypt.Proximity` hierarchy remains a separate
consumer during the staged refactor.
-/
