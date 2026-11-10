module

public import Proximity.Core
public import Proximity.Core.CanonicalLift
public import Proximity.Core.InterleavedMetric
public import Proximity.Core.Systematic
public import Proximity.Core.DeepHole
public import Proximity.Core.FixedChallenge
public import Proximity.Core.MetricSharpness
public import Proximity.Capacity
public import Proximity.ListDecoding
public import Proximity.MCA
public import Proximity.Application.Calibration
public import Proximity.Application.DistanceCalibration
public import Proximity.Capacity.ListPhase

@[expose] public section

/-!
# Capacity-radius proximity: proved infrastructure

This aggregate is the standalone Lean surface for the proximity paper.
It exports proved definitions, equivalences, arithmetic, and the universal
capacity-grid list equality with its exact fractional-target criterion. It
also exports the sharpened uniform pair-MCA certificate theorem

`|Bad(C, δ, L)| ≤ Nat.choose n (k + 1)`

and the explicit smooth-family `2⁻¹²⁸` corollary, both at every radius.
For arbitrary supplied finite codes it also exports the exact spectrum
criterion and the uniform-upper-bound / concrete-next-line threshold
certificate.  The certified boundary-field instance at
`|F| = 2^128 + 192513` realizes those certificates with greatest safe count
radius zero and first unsafe radius one.
Concrete cochain and runtime modules are not imported by this target.
-/
