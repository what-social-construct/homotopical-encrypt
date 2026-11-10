module

public import Laplacian.Projection

@[expose] public section

/-
  Injectivity of the Grassmannian Laplacian map.

  Paper correspondence:
  - Paper 1 uses the fixed-metric relationship between a harmonic
    subspace and its kernel-normalized projector.
  - This supporting lemma concerns an already presented operator; it supplies
    no public-visibility or classifier-recovery theorem.

  This file isolates the fact that the projection-model Laplacian remembers
  the hidden harmonic subspace: Δ_W determines W.
-/

set_option linter.mathlibStandardSet false
set_option linter.unusedSectionVars false

open scoped BigOperators Real Nat Classical Pointwise

set_option maxHeartbeats 0
set_option maxRecDepth 4000
set_option synthInstance.maxHeartbeats 20000
set_option synthInstance.maxSize 128
set_option relaxedAutoImplicit false
set_option autoImplicit false

noncomputable section

open Matrix Real InnerProductSpace

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- The Laplacian map W ↦ Δ_W is injective on subspaces. -/
theorem laplacian_injective
    (W1 W2 : Submodule ℝ (EuclideanSpace ℝ n))
    [h1 : W1.HasOrthogonalProjection] [h2 : W2.HasOrthogonalProjection] :
    laplacian W1 = laplacian W2 → W1 = W2 := by
    intro h_eq;
    unfold _root_.laplacian at h_eq;
    simp +zetaDelta at *;
    refine' le_antisymm _ _ <;> intro x hx <;> replace h_eq := LinearMap.congr_fun h_eq x <;> simp_all +decide;
    · have h_proj_W1 : W1.starProjection x = x := by
        exact Submodule.starProjection_eq_self_iff.mpr hx
      have h_proj_W2 : W2.starProjection x ∈ W2 := by
        exact Submodule.starProjection_apply_mem W2 x
      grind;
    · have h_star_proj : W1.starProjection x = x := by
        rw [ h_eq, W2.starProjection_eq_self_iff.mpr hx ];
      exact Submodule.starProjection_eq_self_iff.mp h_star_proj

end
