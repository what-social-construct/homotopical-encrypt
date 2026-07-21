import Proximity.CanonicalRS.PowerDomain
import Proximity.CochainPlane.ReedSolomon

/-
  Concrete plane-to-field encoding choices for the canonical RS regime.

  Paper correspondence:
  - Paper 1 Section 6: plane-shadow to finite-field received-word encoding.
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

/--
The canonical integer-plane encoding is not globally injective: shifting the
first coordinate by the field modulus leaves the encoded symbol unchanged.
Consequently any concrete non-collapse theorem must restrict the admissible
integer region or directly assume a metric lower bound on the selected image.
-/
theorem integerPlaneEncoding_not_injective :
    ¬ Function.Injective integerPlaneEncoding.encodePoint := by
  intro hInjective
  let p : Fin 2 → ℤ := fun _ => 0
  let q : Fin 2 → ℤ := fun j => if j = 0 then Axioms.canonicalCochainModulus else 0
  have hmod :
      ((Axioms.canonicalCochainModulus : ℤ) : RSField) = 0 := by
    rw [ZMod.intCast_zmod_eq_zero_iff_dvd]
  have hEncoded : integerPlaneEncoding.encodePoint p =
      integerPlaneEncoding.encodePoint q := by
    change (0 : RSField) =
      ((Axioms.canonicalCochainModulus : ℤ) : RSField) + canonicalMix * 0
    rw [hmod]
    simp
  have hpq : p = q := hInjective hEncoded
  have hcoord := congrFun hpq (0 : Fin 2)
  simp [p, q, Axioms.canonicalCochainModulus] at hcoord

end

end CanonicalRS
end Proximity
end Hcrypt
