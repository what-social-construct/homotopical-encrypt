module

public import Laplacian.Grassmannian.Injectivity
public import Mathlib.Analysis.Matrix.Normed

@[expose] public section

/-!
# Chordal distance on finite Euclidean subspaces

Represent each subspace by its orthogonal projector in the standard
orthonormal basis. The Frobenius distance between those projectors, divided
by `√2`, gives the chordal metric. This construction uses the projector of
the subspace and so is independent of a chosen frame for it.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Laplacian.Grassmannian

open scoped BigOperators Matrix.Norms.Frobenius

/-- Expand the squared Frobenius norm over real matrix entries. -/
theorem frobenius_norm_sq {m n : Type*} [Fintype m] [Fintype n]
    (M : Matrix m n ℝ) : ‖M‖ ^ 2 = ∑ i, ∑ j, (M i j) ^ 2 := by
  rw [Matrix.frobenius_norm_def]
  simp only [← Real.sqrt_eq_rpow, Real.rpow_two]
  rw [Real.sq_sqrt (by positivity)]
  simp only [Real.norm_eq_abs, sq_abs]

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- The orthogonal projector in the standard orthonormal basis. -/
def orthProjMatrix (W : Submodule ℝ (EuclideanSpace ℝ n)) : Matrix n n ℝ :=
  LinearMap.toMatrix (EuclideanSpace.basisFun n ℝ).toBasis
    (EuclideanSpace.basisFun n ℝ).toBasis W.starProjection.toLinearMap

theorem orthProjMatrix_mulVec (W : Submodule ℝ (EuclideanSpace ℝ n)) (b : n → ℝ) :
    (orthProjMatrix W).mulVec b = WithLp.ofLp (W.starProjection (WithLp.toLp 2 b)) := by
  have repr_eq (v : EuclideanSpace ℝ n) :
      ⇑((EuclideanSpace.basisFun n ℝ).toBasis.repr v) = WithLp.ofLp v := by
    funext i
    simp
  simpa only [orthProjMatrix, repr_eq, WithLp.ofLp_toLp, ContinuousLinearMap.coe_coe] using
    LinearMap.toMatrix_mulVec_repr (EuclideanSpace.basisFun n ℝ).toBasis
      (EuclideanSpace.basisFun n ℝ).toBasis W.starProjection.toLinearMap (WithLp.toLp 2 b)

/-- The subspace's kernel-normalized Laplacian uses this projector. -/
theorem laplacian_eq_one_sub_orthProjMatrix (W : Submodule ℝ (EuclideanSpace ℝ n)) :
    _root_.laplacian W = 1 - orthProjMatrix W := rfl

theorem orthProjMatrix_injective :
    Function.Injective (orthProjMatrix (n := n)) := by
  intro U V h
  apply laplacian_injective U V
  rw [laplacian_eq_one_sub_orthProjMatrix, laplacian_eq_one_sub_orthProjMatrix, h]

/-- Chordal distance separates subspaces and ignores their frame choices. -/
def chordalDistance (U V : Submodule ℝ (EuclideanSpace ℝ n)) : ℝ :=
  ‖orthProjMatrix U - orthProjMatrix V‖ / Real.sqrt 2

theorem chordalDistance_sq (U V : Submodule ℝ (EuclideanSpace ℝ n)) :
    chordalDistance U V ^ 2 = ‖orthProjMatrix U - orthProjMatrix V‖ ^ 2 / 2 := by
  rw [chordalDistance, div_pow, Real.sq_sqrt (by norm_num)]

theorem chordalDistance_nonneg (U V : Submodule ℝ (EuclideanSpace ℝ n)) :
    0 ≤ chordalDistance U V := by
  unfold chordalDistance
  positivity

@[simp] theorem chordalDistance_self (U : Submodule ℝ (EuclideanSpace ℝ n)) :
    chordalDistance U U = 0 := by
  simp [chordalDistance]

theorem chordalDistance_eq_zero_iff (U V : Submodule ℝ (EuclideanSpace ℝ n)) :
    chordalDistance U V = 0 ↔ U = V := by
  constructor
  · intro h
    have sqrt_ne : Real.sqrt (2 : ℝ) ≠ 0 := by positivity
    exact orthProjMatrix_injective (sub_eq_zero.mp (norm_eq_zero.mp
      ((div_eq_zero_iff.mp h).resolve_right sqrt_ne)))
  · rintro rfl
    exact chordalDistance_self U

theorem chordalDistance_comm (U V : Submodule ℝ (EuclideanSpace ℝ n)) :
    chordalDistance U V = chordalDistance V U := by
  rw [chordalDistance, chordalDistance, norm_sub_rev]

theorem chordalDistance_triangle (U V W : Submodule ℝ (EuclideanSpace ℝ n)) :
    chordalDistance U W ≤ chordalDistance U V + chordalDistance V W := by
  unfold chordalDistance
  rw [← add_div]
  apply div_le_div_of_nonneg_right _ (Real.sqrt_nonneg _)
  calc
    ‖orthProjMatrix U - orthProjMatrix W‖ =
        ‖(orthProjMatrix U - orthProjMatrix V) + (orthProjMatrix V - orthProjMatrix W)‖ := by
      congr 1
      abel
    _ ≤ ‖orthProjMatrix U - orthProjMatrix V‖ + ‖orthProjMatrix V - orthProjMatrix W‖ :=
      norm_add_le _ _

end HomotopicalEncryption.Laplacian.Grassmannian
