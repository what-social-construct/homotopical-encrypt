module

public import Proximity.Core
public import Proximity.Core.CanonicalLift
public import Proximity.Core.InterleavedMetric
public import Proximity.Core.Systematic
public import Proximity.Core.DeepHole
public import Proximity.Core.FixedChallenge
public import Proximity.Core.PolynomialAgreement
public import Proximity.Core.PolynomialAgreement.Boundary
public import Proximity.Core.PolynomialAgreement.Completeness
public import Proximity.Core.PolynomialAgreement.Sharpness
public import Proximity.Core.MetricSharpness
public import Proximity.Capacity
public import Proximity.ListDecoding
public import Proximity.MCA
public import Proximity.Application.Calibration
public import Proximity.Application.DistanceCalibration
public import Proximity.Capacity.ListPhase
public import Proximity.Capacity.BoundaryList
public import Proximity.Capacity.AgreementPacking
public import Proximity.Capacity.JoThresholds
public import Proximity.Capacity.SubfieldThresholdArithmetic
public import Proximity.Capacity.SubfieldListDescent
public import Proximity.Capacity.WidthReduction

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
`|F| = 2^128 + 192513` has pair-MCA count transition `0` to `1` and
fractional-list count transition `1536` to `1537` at every positive width.
Agreement packing bounds lists by counting all agreement subsets and pins
the threshold immediately below capacity for the corresponding budgets.
Concrete cochain and runtime modules are not imported by this target.
-/
