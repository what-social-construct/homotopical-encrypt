module

public import Sheaf.Hodge

@[expose] public section

/-!
# Distance to the exact cochain subspace

This is the Euclidean source distance for the decoded exact-payload model.
It is separate from harmonic recovery of the full HCP observation, and from
the finite-alphabet Hamming distance used after a coding projection.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt.Sheaf.CellularSheaf

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}

/-- Euclidean distance from a degree-one cochain to `im δ₀`. -/
def exactDistance (F : CellularSheaf X) (b : F.C1) : ℝ :=
  ‖F.exactOneSubspace.orthogonal.starProjection b‖

theorem exactDistance_nonneg (F : CellularSheaf X) (b : F.C1) :
    0 ≤ F.exactDistance b :=
  norm_nonneg _

/-- Zero distance is actual exactness, with an opening in the original `C⁰`. -/
theorem exactDistance_eq_zero_iff (F : CellularSheaf X) (b : F.C1) :
    F.exactDistance b = 0 ↔ F.IsExactOneCochain b := by
  rw [exactDistance, norm_eq_zero,
    Submodule.starProjection_apply_eq_zero_iff,
    Submodule.orthogonal_orthogonal]
  rfl

theorem exactDistance_eq_zero_of_exact (F : CellularSheaf X) {b : F.C1}
    (hb : F.IsExactOneCochain b) : F.exactDistance b = 0 :=
  (F.exactDistance_eq_zero_iff b).2 hb

/-- Every exact cochain provides an upper bound on distance to exactness. -/
theorem exactDistance_le_norm_sub (F : CellularSheaf X) (b : F.C1)
    {c : F.C1} (hc : F.IsExactOneCochain c) :
    F.exactDistance b ≤ ‖b - c‖ := by
  have hzero : F.exactOneSubspace.orthogonal.starProjection c = 0 := by
    have hnorm := F.exactDistance_eq_zero_of_exact hc
    exact norm_eq_zero.mp hnorm
  calc
    F.exactDistance b =
        ‖F.exactOneSubspace.orthogonal.starProjection (b - c)‖ := by
          rw [map_sub, hzero, sub_zero]
          rfl
    _ ≤ ‖b - c‖ :=
      F.exactOneSubspace.orthogonal.norm_starProjection_apply_le _

/-- The exact-payload source distance is stable under perturbing the cochain. -/
theorem abs_exactDistance_sub_le (F : CellularSheaf X) (b c : F.C1) :
    |F.exactDistance b - F.exactDistance c| ≤ ‖b - c‖ := by
  calc
    |F.exactDistance b - F.exactDistance c| ≤
        ‖F.exactOneSubspace.orthogonal.starProjection b -
          F.exactOneSubspace.orthogonal.starProjection c‖ :=
      abs_norm_sub_norm_le _ _
    _ = ‖F.exactOneSubspace.orthogonal.starProjection (b - c)‖ := by
      rw [map_sub]
    _ ≤ ‖b - c‖ :=
      F.exactOneSubspace.orthogonal.norm_starProjection_apply_le _

end Hcrypt.Sheaf.CellularSheaf
