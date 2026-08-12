import Proximity.Core
import Proximity.Capacity
import Proximity.ListDecoding
import Proximity.MCA
import Proximity.Application.Calibration

/-!
# Capacity-radius proximity: proved infrastructure

This aggregate is the standalone Lean surface for the proximity-prize paper.
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
