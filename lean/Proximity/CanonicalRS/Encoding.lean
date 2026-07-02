import Proximity.CanonicalRS.PowerDomain
import Proximity.CochainPlane.ReedSolomon

/-
  Concrete plane-to-field encoding choices for the canonical RS regime.
-/

namespace Hcrypt
namespace Proximity
namespace CanonicalRS

noncomputable section

/--
Canonical mix used to fold an integer two-plane point into one canonical RS
field symbol.

This fixes the concrete encoding boundary while keeping non-collapse/distance
properties as explicit downstream obligations.
-/
def canonicalMix : RSField :=
  candidateRoot

/-- The selected integer-plane encoding into the canonical RS field. -/
def integerPlaneEncoding :
    CochainReedSolomon.PlaneEncoding ℤ RSField :=
  CochainReedSolomon.PlaneEncoding.integerCanonical canonicalMix

end

end CanonicalRS
end Proximity
end Hcrypt
