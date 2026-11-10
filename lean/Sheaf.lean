module

public import Sheaf.CellComplex
public import Sheaf.Cellular
public import Sheaf.Morphism
public import Sheaf.Hodge
public import Sheaf.Integral
public import Sheaf.HarmonicLattice
public import Sheaf.CoefficientRecovery
public import Sheaf.Equivalence
public import Sheaf.Rotation
public import Sheaf.Commitment
public import Sheaf.Distance
public import Sheaf.CochainSemantics
public import Sheaf.ObservationQuotient
public import Sheaf.CanonicalLiftObstruction
public import Sheaf.GraphCommitment

@[expose] public section

/-!
Shared finite cellular-sheaf import surface.

Paper 1 uses the finite Hodge, integral-lattice, coefficient-recovery and
observation-boundary owners. Paper 2 uses commitment and rotation interfaces;
Paper 3 uses the declared modular validity/distance profile and its quantitative
comparisons. The selected Paper 1 appendix does not catalogue this aggregate.

The root import is intentionally independent of protocol/runtime modules.
-/
