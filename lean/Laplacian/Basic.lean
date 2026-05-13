import Mathlib

set_option linter.mathlibStandardSet false

open scoped BigOperators Real Nat Classical Pointwise

set_option maxHeartbeats 0
set_option maxRecDepth 4000
set_option synthInstance.maxHeartbeats 20000
set_option synthInstance.maxSize 128
set_option relaxedAutoImplicit false
set_option autoImplicit false

noncomputable section

open Matrix Real InnerProductSpace MeasureTheory

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- The Laplacian associated with a subspace W is I - P_W.
    Eigenvalues: 0 (multiplicity k = dim W) and 1 (multiplicity n-k).
    Python: geometry/hodge.py builds Δ from the simplicial complex;
    here we define Δ directly from the orthogonal projection. -/
def laplacian (W : Submodule ℝ (EuclideanSpace ℝ n)) [W.HasOrthogonalProjection] : Matrix n n ℝ :=
  1 - LinearMap.toMatrix (EuclideanSpace.basisFun n ℝ).toBasis (EuclideanSpace.basisFun n ℝ).toBasis
    (W.subtype.comp (Submodule.orthogonalProjection W).toLinearMap)

/-- The Laplacian applied to b is the projection of b onto W⊥.
    This is the core geometric identity: Δ_W b = P_{W⊥} b.
    Python: encrypt() puts message in ker(Δ), noise in im(Δ);
    decrypt = P_harmonic @ ciphertext recovers message. -/
lemma laplacian_apply (W : Submodule ℝ (EuclideanSpace ℝ n)) [W.HasOrthogonalProjection] (b : EuclideanSpace ℝ n) :
  _root_.laplacian W *ᵥ b = (Submodule.orthogonalProjection W.orthogonal) b := by
    unfold _root_.laplacian;
    ext i;
    simp +decide [ Matrix.one_apply, Matrix.mulVec, dotProduct ];
    simp +decide [ LinearMap.toMatrix_apply ];
    have h_star_proj : W.starProjection b i = ∑ x, W.starProjection (EuclideanSpace.single x 1) i * b x := by
      have h_star_proj : W.starProjection b = ∑ x, b x • W.starProjection (EuclideanSpace.single x 1) := by
        convert ( W.starProjection ).pi_apply_eq_sum_univ b;
        aesop;
      rw [ h_star_proj, Finset.sum_apply, Finset.sum_congr rfl ] ; intros ; simp +decide [ mul_comm ];
    simp +decide [ h_star_proj, sub_mul, Finset.sum_sub_distrib ]

end
