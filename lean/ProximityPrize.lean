import ProximityPrize.BlockCode
import ProximityPrize.ReedSolomon
import ProximityPrize.PlanePair
import ProximityPrize.Parameters
import ProximityPrize.CapacityList

/-!
# Capacity-radius proximity: proved infrastructure

This aggregate is the standalone Lean surface for the proximity-prize paper.
It exports proved definitions, equivalences, arithmetic, and the universal
capacity-grid list equality with its exact fractional-target criterion.

Deliberately absent:

* a capacity-radius mutual-correlated-agreement theorem;
* a machine-checked version of the next-shell lower bound;
* axioms or placeholders asserting either missing target.

Those modules should be added only when their theorem statements and proofs are
ready. The application-facing `Hcrypt.Proximity` hierarchy remains a separate
consumer during the staged refactor.
-/
