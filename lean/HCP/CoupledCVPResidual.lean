module

public import HCP.CoupledCVP
public import Hardness

@[expose] public section

/-!
# Residual and discrete error in the coupled CVP objective

For an arbitrary real target, the original Hodge projection gives the center
of the coefficient optimization. Squared distance to a graph lattice point
is the squared nonharmonic residual plus the graph Gram form of the
coefficient error. The identity uses the actual coupled Hodge operator and
original CVP presentation, with no change of ambient metric.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.HCP.CoupledCVP

open Sheaf CellularSheaf HCPCoupledFamily
open scoped BigOperators Matrix

variable {Row Col : Type} [Fintype Row] [Fintype Col] [DecidableEq Row] [DecidableEq Col]

/-- Use the basis of the original intrinsic harmonic lattice and the kernel
of the coupled sheaf's actual Hodge operator. -/
private def bridge (B : Matrix Row Col ℤ) : HarmonicCVPBridge (Index Row Col) Col where
  lattice := graphLattice B
  harmonicSubspace := (sheaf B).harmonicOneSubspace
  latticeVector_mem z := by
    change WithLp.toLp 2 (CVP.latticeVector (graphLattice B) z) ∈ (sheaf B).harmonicOneSubspace
    rw [latticeVector_eq_graphVector]
    exact LinearMap.mem_ker.mpr (graphVector_harmonic B _)

/-- Split the actual CVP cost into the Hodge residual, independent of the
candidate, and a positive definite quadratic form centered at the real
harmonic coordinates. Only the second term is minimized over integers. -/
theorem squaredDistance_eq_residual_add_gram
    (B : Matrix Row Col ℤ) (b : C1 Row Col) (w : Col → ℤ) :
    let p := (sheaf B).harmonicOneProjection b
    let error : Col → ℝ := fun c => information p c - (w c : ℝ)
    CVP.squaredEuclideanDistance b (CVP.latticeVector (graphLattice B) w) =
      ‖(sheaf B).kernelNormalizedDegreeOneLaplacian b‖ ^ 2 +
        dotProduct error (((graphBasis B)ᵀ * graphBasis B).mulVec error) := by
  let p := (sheaf B).harmonicOneProjection b
  let error : Col → ℝ := fun c => information p c - (w c : ℝ)
  let G := graphBasis B
  change _ = ‖(sheaf B).kernelNormalizedDegreeOneLaplacian b‖ ^ 2 +
    dotProduct error ((Gᵀ * G).mulVec error)
  rw [(sheaf B).kernelNormalizedDegreeOneLaplacian_apply]
  have split := (bridge B).squaredDistance_projection_decomposition
    (WithLp.ofLp b) (CVP.latticeVector (graphLattice B) w) ⟨w, rfl⟩
  change CVP.squaredEuclideanDistance b (CVP.latticeVector (graphLattice B) w) =
    CVP.squaredEuclideanDistance b p +
      CVP.squaredEuclideanDistance p (CVP.latticeVector (graphLattice B) w) at split
  have graph : WithLp.toLp 2 (G.mulVec (information p)) = p := by
    change WithLp.toLp 2 ((graphBasis B).mulVec (information p)) = p
    rw [graphBasis_mulVec]
    exact (eq_graphVector_of_harmonic B (LinearMap.mem_ker.mp
      ((sheaf B).harmonicOneSubspace.starProjection_apply_mem b))).symm
  have difference : G.mulVec error = WithLp.ofLp p - CVP.latticeVector (graphLattice B) w := by
    change G.mulVec (information p - fun c => (w c : ℝ)) = _
    rw [Matrix.mulVec_sub, ← congrArg WithLp.ofLp graph]
    rfl
  calc
    _ = CVP.squaredEuclideanDistance b p +
        CVP.squaredEuclideanDistance p (CVP.latticeVector (graphLattice B) w) := split
    _ = ‖b - p‖ ^ 2 + dotProduct (G.mulVec error) (G.mulVec error) := by
      rw [HarmonicLatticePresentation.squaredEuclideanDistance_eq_norm_sq b p]
      congr 1
      rw [difference]
      simp only [CVP.squaredEuclideanDistance, dotProduct, Pi.sub_apply, pow_two]
    _ = _ := by
      rw [Matrix.dotProduct_mulVec, ← Matrix.mulVec_transpose, Matrix.mulVec_mulVec, dotProduct_comm]

end HomotopicalEncryption.HCP.CoupledCVP
