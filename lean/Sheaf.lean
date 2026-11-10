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

Paper 1 uses the finite cellular/Hodge, integral-lattice and coefficient-recovery
owners. Paper 2 uses commitment, opening-quotient and rotation interfaces.
Paper 3 uses the observation-quotient boundary, declared modular validity/distance
profile and quantitative comparisons. Each paper records its specific owners.

The root import is intentionally independent of protocol/runtime modules.
-/
