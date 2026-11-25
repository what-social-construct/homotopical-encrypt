module

public import HCP.CoupledCVP

@[expose] public section

/-!
# Preserving exact minimizers when lifting integer CVP to the coupled lattice

The target `(0, 0, scale * t)` and coupling `scale * G` make the coupled
objective the original integer squared distance weighted by `scale^2`, plus
the squared coefficient norm. If one original minimizer has squared
coefficient norm below that weight, the added term cannot compensate for an
increase in the original integer objective. Thus every closest graph point
gives an original minimizer.
-/

set_option autoImplicit false

open scoped BigOperators

noncomputable section

namespace HomotopicalEncryption.HCP.CoupledCVPLift

open Sheaf HCPCoupledFamily

variable {Row Col : Type*} [Fintype Row] [Fintype Col]
  [DecidableEq Row] [DecidableEq Col]

/-- The original squared distance, evaluated before casting to reals. -/
def sourceCost (G : Matrix Row Col ℤ) (t : Row → ℤ) (z : Col → ℤ) : ℤ :=
  ∑ r, (t r - ∑ c, G r c * z c) ^ 2

/-- The squared norm of the information coordinates. -/
def coefficientCost (z : Col → ℤ) : ℤ :=
  ∑ c, z c ^ 2

/-- A target whose only possibly nonzero coordinates are its parity entries. -/
def scaledTarget (scale : ℤ) (t : Row → ℤ) : C1 Row Col :=
  WithLp.toLp 2 fun p => match p.1 with
    | none => 0
    | some (.inl _) => 0
    | some (.inr r) => ((scale * t r : ℤ) : ℝ)

/-- One instance of closest-point search in the actual coupled lattice. -/
def scaledInstance (G : Matrix Row Col ℤ) (t : Row → ℤ) (scale : ℤ) :
    CVP.Instance (Index Row Col) Col :=
  ⟨CoupledCVP.graphLattice (scale • G), WithLp.ofLp (scaledTarget scale t)⟩

omit [DecidableEq Row] in
/-- The integer coefficient is literally the returned information coordinate. -/
theorem scaledInstance_information (G : Matrix Row Col ℤ) (t : Row → ℤ)
    (scale : ℤ) (z : Col → ℤ) (c : Col) :
    information
      (WithLp.toLp 2 (CVP.latticeVector (scaledInstance G t scale).lattice z)) c =
        (z c : ℝ) := by
  change information
    (WithLp.toLp 2 (CVP.latticeVector (CoupledCVP.graphLattice (scale • G)) z)) c = _
  rw [CoupledCVP.latticeVector_eq_graphVector, graphVector_information]

omit [DecidableEq Row] in
/-- Exact objective identity for the coupled lift, including the integer gap scale. -/
theorem squaredDistance_eq_scaledCost (G : Matrix Row Col ℤ) (t : Row → ℤ)
    (scale : ℤ) (z : Col → ℤ) :
    CVP.squaredEuclideanDistance (scaledInstance G t scale).target
        (CVP.latticeVector (scaledInstance G t scale).lattice z) =
      ((scale ^ 2 * sourceCost G t z + coefficientCost z : ℤ) : ℝ) := by
  change CVP.squaredEuclideanDistance (scaledTarget scale t)
      (CVP.latticeVector (CoupledCVP.graphLattice (scale • G)) z) = _
  rw [CoupledCVP.squaredDistance_eq_objective]
  have hExact : exactCoord (scaledTarget (Col := Col) scale t) = 0 := rfl
  have hInfo (c : Col) : information (scaledTarget scale t) c = 0 := rfl
  have hParity (r : Row) : parity (scaledTarget (Col := Col) scale t) r =
      ((scale * t r : ℤ) : ℝ) := rfl
  simp only [hExact, hInfo, hParity, zero_pow (by decide : 2 ≠ 0), zero_add,
    zero_sub, neg_sq, sourceCost, coefficientCost, Int.cast_add, Int.cast_mul,
    Int.cast_pow, Int.cast_sum, Int.cast_sub]
  rw [add_comm]
  congr 1
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro r _
  simp only [Matrix.smul_apply, smul_eq_mul, Int.cast_mul, mul_assoc, ← Finset.mul_sum]
  ring

omit [DecidableEq Row] in
/-- A coupled closest point supplies a minimizer of the original integer cost. -/
theorem coefficients_solve_source (G : Matrix Row Col ℤ) (t : Row → ℤ)
    (scale : ℤ) (positive : 0 < scale) (reference : Col → ℤ)
    (reference_min : ∀ z, sourceCost G t reference ≤ sourceCost G t z)
    (reference_small : coefficientCost reference < scale ^ 2)
    (closest : CVP.AmbientVector (Index Row Col))
    (solution : CVP.Solution (scaledInstance G t scale) closest) :
    ∃ z : Col → ℤ,
      CVP.latticeVector (scaledInstance G t scale).lattice z = closest ∧
      ∀ w, sourceCost G t z ≤ sourceCost G t w := by
  rcases solution with ⟨⟨z, rfl⟩, closest_min⟩
  refine ⟨z, rfl, fun w => ?_⟩
  have hLift := closest_min (CVP.latticeVector (scaledInstance G t scale).lattice reference)
    ⟨reference, rfl⟩
  rw [squaredDistance_eq_scaledCost, squaredDistance_eq_scaledCost] at hLift
  have hLiftInt : scale ^ 2 * sourceCost G t z + coefficientCost z ≤
      scale ^ 2 * sourceCost G t reference + coefficientCost reference := by
    exact_mod_cast hLift
  by_contra! hNot
  have hGap : sourceCost G t reference + 1 ≤ sourceCost G t z := by
    have hRef := reference_min w
    omega
  have hWeighted := mul_le_mul_of_nonneg_left hGap (le_of_lt (pow_pos positive 2))
  have hCoeff : 0 ≤ coefficientCost z := Finset.sum_nonneg fun _ _ => sq_nonneg _
  rw [mul_add, mul_one] at hWeighted
  omega

omit [DecidableEq Row] in
/-- A single squared-distance threshold on the actual coupled instance
decides the original integer threshold. The subtracted unit separates
the original integer costs immediately above and below the cutoff. -/
theorem source_threshold_iff_scaledDistance
    (G : Matrix Row Col ℤ) (t : Row → ℤ) (scale : ℤ) (positive : 0 < scale)
    (reference : Col → ℤ) (reference_min : ∀ z, sourceCost G t reference ≤ sourceCost G t z)
    (reference_small : coefficientCost reference < scale ^ 2) (threshold : ℤ) :
    (∃ z, sourceCost G t z ≤ threshold) ↔
      ∃ z, CVP.squaredEuclideanDistance (scaledInstance G t scale).target
          (CVP.latticeVector (scaledInstance G t scale).lattice z) ≤
        ((scale ^ 2 * (threshold + 1) - 1 : ℤ) : ℝ) := by
  simp only [squaredDistance_eq_scaledCost, Int.cast_le]
  have weight_nonneg := le_of_lt (pow_pos positive 2)
  constructor
  · rintro ⟨z, within⟩
    refine ⟨reference, ?_⟩
    have scaled := mul_le_mul_of_nonneg_left ((reference_min z).trans within) weight_nonneg
    rw [mul_add, mul_one]
    omega
  · rintro ⟨z, within⟩
    refine ⟨z, ?_⟩
    by_contra! above
    have gap : threshold + 1 ≤ sourceCost G t z := by omega
    have scaled := mul_le_mul_of_nonneg_left gap weight_nonneg
    have coeff_nonneg : 0 ≤ coefficientCost z := Finset.sum_nonneg fun _ _ => sq_nonneg _
    omega

omit [DecidableEq Row] [DecidableEq Col] in
/-- Clearing denominators produces a normal explicit CVP instance whose
squared distance is the cast of the integer objective. -/
theorem sourceDistance_eq_cost (G : Matrix Row Col ℤ) (t : Row → ℤ)
    (L : CVP.ExplicitLattice Row Col) (basis_eq : ∀ r c, L.basis r c = (G r c : ℝ))
    (z : Col → ℤ) :
    CVP.squaredEuclideanDistance (fun r => (t r : ℝ)) (CVP.latticeVector L z) =
      (sourceCost G t z : ℝ) := by
  unfold CVP.squaredEuclideanDistance CVP.latticeVector Matrix.mulVec dotProduct sourceCost
  push_cast
  simp only [basis_eq]

omit [DecidableEq Row] in
/-- Read the returned graph coefficients in the original basis to obtain a
correct answer to the original explicit CVP instance. -/
theorem source_solution_of_scaled_solution (G : Matrix Row Col ℤ) (t : Row → ℤ)
    (L : CVP.ExplicitLattice Row Col) (basis_eq : ∀ r c, L.basis r c = (G r c : ℝ))
    (scale : ℤ) (positive : 0 < scale) (reference : Col → ℤ)
    (reference_min : ∀ z, sourceCost G t reference ≤ sourceCost G t z)
    (reference_small : coefficientCost reference < scale ^ 2)
    (closest : CVP.AmbientVector (Index Row Col))
    (solution : CVP.Solution (scaledInstance G t scale) closest) :
    ∃ z : Col → ℤ,
      CVP.latticeVector (scaledInstance G t scale).lattice z = closest ∧
      CVP.Solution ⟨L, fun r => (t r : ℝ)⟩ (CVP.latticeVector L z) := by
  obtain ⟨z, encoded, hMin⟩ :=
    coefficients_solve_source G t scale positive reference reference_min reference_small
      closest solution
  refine ⟨z, encoded, ⟨⟨z, rfl⟩, ?_⟩⟩
  rintro _ ⟨w, rfl⟩
  change CVP.squaredEuclideanDistance (fun r => (t r : ℝ)) (CVP.latticeVector L z) ≤
    CVP.squaredEuclideanDistance (fun r => (t r : ℝ)) (CVP.latticeVector L w)
  rw [sourceDistance_eq_cost G t L basis_eq, sourceDistance_eq_cost G t L basis_eq]
  exact_mod_cast hMin w

end HomotopicalEncryption.HCP.CoupledCVPLift
