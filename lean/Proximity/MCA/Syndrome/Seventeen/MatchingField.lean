module

public import Proximity.MCA.Syndrome.Seventeen.Certificate
public import Mathlib.Algebra.Polynomial.SpecificDegree
public import Mathlib.FieldTheory.Perfect
public import Mathlib.RingTheory.AdjoinRoot

@[expose] public section

/-!
# The quadratic field of the specified matching

The affine chart for the four consecutive support pairs is cut out by
`X² - 11`. The base-field exclusion certificate gives irreducibility, and
perfection of the base field gives separability.
-/

set_option autoImplicit false

namespace ProximityCoding.MCA.Syndrome.Seventeen

open Polynomial

local instance : Fact (Nat.Prime 17) := ⟨by decide⟩

/-- Equation in the normalized Plücker coordinate of the matching. -/
noncomputable def matchingPolynomial : Polynomial (ZMod 17) := X ^ 2 - C 11

theorem matchingPolynomial_natDegree : matchingPolynomial.natDegree = 2 := by
  rw [matchingPolynomial, natDegree_X_pow_sub_C]

theorem matchingPolynomial_irreducible : Irreducible matchingPolynomial := by
  apply irreducible_of_degree_le_three_of_not_isRoot
  · norm_num [matchingPolynomial_natDegree]
  · intro a ha
    exact sq_ne_eleven a (by simpa [matchingPolynomial, IsRoot, sub_eq_zero] using ha)

theorem matchingPolynomial_separable : matchingPolynomial.Separable :=
  PerfectField.separable_of_irreducible matchingPolynomial_irreducible

/-- The coordinate algebra of the normalized matching chart is a field. -/
theorem matchingField_isField : IsField (AdjoinRoot matchingPolynomial) :=
  AdjoinRoot.isField_iff_irreducible.mpr matchingPolynomial_irreducible

/-- The chart's residue field has degree exactly two over `𝔽₁₇`. -/
theorem matchingField_finrank :
    Module.finrank (ZMod 17) (AdjoinRoot matchingPolynomial) = 2 :=
  finrank_quotient_span_eq_natDegree.trans matchingPolynomial_natDegree

end ProximityCoding.MCA.Syndrome.Seventeen
