module

public import HCP.CoupledCVP
public import Laplacian.Grassmannian.Metric
public import Protocol.Transfer.PathSignature.NativeSignSampler
public import Mathlib.Algebra.Order.Star.Real
public import Mathlib.InformationTheory.Hamming
public import Mathlib.LinearAlgebra.Matrix.PosDef

@[expose] public section

/-!
# Projector coordinates of the coupled harmonic graph

The actual harmonic projector of the cellular sheaf is expressed in the
common orthonormal edge basis using the existing harmonic graph generators.
The shared chordal distance on sign-key subspaces is the square root of
Hamming distance scaled by the common graph Gram scalar.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.HCP.CoupledProjectorMetric

open Sheaf CellularSheaf HCPCoupledFamily CoupledCVP Matrix
open Laplacian.Grassmannian (orthProjMatrix orthProjMatrix_mulVec
  chordalDistance chordalDistance_sq frobenius_norm_sq)
open Protocol.Transfer.PathSignature.NativeSignSampler
open scoped Matrix Matrix.Norms.Frobenius RealInnerProductSpace

variable {Row Col : Type} [Fintype Row] [Fintype Col] [DecidableEq Row] [DecidableEq Col]

/-- The original harmonic projector in the standard orthonormal edge basis. -/
abbrev projectorMatrix (B : Matrix Row Col ℤ) : Matrix (Index Row Col) (Index Row Col) ℝ :=
  orthProjMatrix (sheaf B).harmonicOneSubspace

theorem projectorMatrix_mulVec (B : Matrix Row Col ℤ) (b : Index Row Col → ℝ) :
    (projectorMatrix B).mulVec b = WithLp.ofLp
      ((sheaf B).harmonicOneProjection (WithLp.toLp 2 b)) :=
  orthProjMatrix_mulVec (sheaf B).harmonicOneSubspace b

/-- A solution of the graph normal equations is the coefficient vector of
the actual harmonic projection. -/
theorem projection_eq_graphVector_of_normal_eq (B : Matrix Row Col ℤ)
    (b : C1 Row Col) (z : Col → ℝ)
    (normal : ((graphBasis B).transpose * graphBasis B).mulVec z =
      (graphBasis B).transpose.mulVec (WithLp.ofLp b)) :
    (sheaf B).harmonicOneProjection b = graphVector B z := by
  change (sheaf B).harmonicOneSubspace.starProjection b = graphVector B z
  refine (sheaf B).harmonicOneSubspace.eq_starProjection_of_mem_of_inner_eq_zero
    (LinearMap.mem_ker.mpr (graphVector_harmonic B z)) ?_
  intro w hw
  rw [eq_graphVector_of_harmonic B (LinearMap.mem_ker.mp hw),
    ← graphBasis_mulVec B (information w), EuclideanSpace.inner_eq_star_dotProduct]
  simp only [star_trivial, ← graphBasis_mulVec B z, WithLp.ofLp_sub]
  rw [dotProduct_comm, ← Matrix.dotProduct_transpose_mulVec, Matrix.mulVec_sub,
    Matrix.mulVec_mulVec, normal, sub_self, dotProduct_zero]

private theorem projectorMatrix_of_rightInverse (B : Matrix Row Col ℤ)
    (M : Matrix Col Col ℝ)
    (rightInverse : (graphBasis B).transpose * graphBasis B * M = 1) :
    projectorMatrix B = graphBasis B * M * (graphBasis B).transpose := by
  apply Matrix.ext_of_mulVec_single
  intro j
  rw [projectorMatrix_mulVec, ← Matrix.mulVec_mulVec, ← Matrix.mulVec_mulVec]
  let z := M.mulVec ((graphBasis B).transpose.mulVec (Pi.single j 1))
  have projected := projection_eq_graphVector_of_normal_eq B (WithLp.toLp 2 (Pi.single j 1)) z
    (by
      dsimp only [z]
      rw [Matrix.mulVec_mulVec, rightInverse, Matrix.one_mulVec])
  rw [projected, ← graphBasis_mulVec, WithLp.ofLp_toLp]

/-- `H (Hᵀ H)⁻¹ Hᵀ`, with `H` the already constructed harmonic graph basis. -/
theorem projectorMatrix_eq_graph (B : Matrix Row Col ℤ) :
    projectorMatrix B = graphBasis B * ((graphBasis B).transpose * graphBasis B)⁻¹ *
      (graphBasis B).transpose := by
  apply projectorMatrix_of_rightInverse
  have positive := Matrix.PosDef.conjTranspose_mul_self (graphBasis B)
    (graphLattice B).basis_injective
  rw [Matrix.conjTranspose_eq_transpose_of_trivial] at positive
  exact Matrix.mul_nonsing_inv _ ((Matrix.isUnit_iff_isUnit_det _).mp positive.isUnit)

variable {rows cols : ℕ}

/-- All sign keys have the same graph Gram matrix. -/
theorem sign_graphBasis_gram (A : Matrix (Fin rows) (Fin cols) ℤ) (d : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (key : Fin cols → Bool) :
    (graphBasis (presentation A key)).transpose * graphBasis (presentation A key) =
      ((1 + (d : ℝ)) • (1 : Matrix (Fin cols) (Fin cols) ℝ)) := by
  ext i j
  rw [graphBasis_gram]
  have entry := presentation_gram_entry A d orthogonal key i j
  have castEntry : (∑ row, (presentation A key row i : ℝ) *
      (presentation A key row j : ℝ)) = if i = j then (d : ℝ) else 0 := by
    exact_mod_cast entry
  rw [castEntry]
  by_cases h : i = j <;> simp [Matrix.smul_apply, h]

/-- The actual projector on the sign family uses the common scalar Gram inverse. -/
theorem projectorMatrix_sign (A : Matrix (Fin rows) (Fin cols) ℤ) (d : ℤ)
    (positive : 0 < d)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (key : Fin cols → Bool) :
    projectorMatrix (presentation A key) =
      (1 + (d : ℝ))⁻¹ • (graphBasis (presentation A key) *
        (graphBasis (presentation A key)).transpose) := by
  have scale_ne : 1 + (d : ℝ) ≠ 0 := by
    have h : (0 : ℝ) < (d : ℝ) := by exact_mod_cast positive
    positivity
  have form := projectorMatrix_of_rightInverse (presentation A key)
    ((1 + (d : ℝ))⁻¹ • (1 : Matrix (Fin cols) (Fin cols) ℝ)) (by
      rw [sign_graphBasis_gram A d orthogonal key, Matrix.smul_mul, Matrix.mul_smul,
        Matrix.one_mul, smul_smul, mul_inv_cancel₀ scale_ne, one_smul])
  simpa only [Matrix.mul_smul, Matrix.mul_one, Matrix.smul_mul] using form

private theorem projectorMatrix_sign_sub_apply
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d : ℤ) (positive : 0 < d)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (first second : Fin cols → Bool) (i j : Index (Fin rows) (Fin cols)) :
    projectorMatrix (presentation A first) i j - projectorMatrix (presentation A second) i j =
      (1 + (d : ℝ))⁻¹ * (match i.1, j.1 with
        | some (.inl c), some (.inr r) | some (.inr r), some (.inl c) =>
            (A r c : ℝ) * ((sign (first c) : ℝ) - (sign (second c) : ℝ))
        | _, _ => 0) := by
  rw [projectorMatrix_sign A d positive orthogonal first,
    projectorMatrix_sign A d positive orthogonal second]
  simp only [Matrix.smul_apply, smul_eq_mul, ← mul_sub]
  congr 1
  rcases i with ⟨i, ii⟩
  rcases j with ⟨j, jj⟩
  cases i with
  | none => simp [Matrix.mul_apply, Matrix.transpose_apply, graphBasis]
  | some i =>
    cases j with
    | none => simp [Matrix.mul_apply, Matrix.transpose_apply, graphBasis]
    | some j =>
      cases i with
      | inl c =>
        cases j with
        | inl e => simp [Matrix.mul_apply, Matrix.transpose_apply, graphBasis]
        | inr r => simp [Matrix.mul_apply, Matrix.transpose_apply, graphBasis,
            presentation, ite_mul, mul_sub]
      | inr r =>
        cases j with
        | inl c => simp [Matrix.mul_apply, Matrix.transpose_apply, graphBasis,
            presentation, mul_ite, mul_sub]
        | inr s =>
          apply sub_eq_zero.mpr
          simp only [Matrix.mul_apply, Matrix.transpose_apply, graphBasis]
          apply Finset.sum_congr rfl
          intro c _
          cases hfirst : first c <;> cases hsecond : second c <;>
            simp [presentation, sign, HCP.AxisSignedSampler.coefficient, hfirst, hsecond]

/-- The squared Frobenius distance of the actual harmonic projectors is a
constant times the Hamming distance between sign keys. The sum of entry
squares uses the common orthonormal edge basis. -/
theorem projector_frobenius_sq_eq_hamming
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d : ℤ) (positive : 0 < d)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (first second : Fin cols → Bool) :
    (∑ i, ∑ j, (projectorMatrix (presentation A first) i j -
      projectorMatrix (presentation A second) i j) ^ 2) =
      8 * (d : ℝ) / (1 + (d : ℝ)) ^ 2 * (hammingDist first second : ℝ) := by
  let cross (c : Fin cols) (r : Fin rows) : ℝ :=
    ((1 + (d : ℝ))⁻¹ * ((A r c : ℝ) * ((sign (first c) : ℝ) - (sign (second c) : ℝ)))) ^ 2
  have offDiagonal : (∑ i, ∑ j, (projectorMatrix (presentation A first) i j -
      projectorMatrix (presentation A second) i j) ^ 2) =
      (∑ c, ∑ r, cross c r) + ∑ r, ∑ c, cross c r := by
    simp_rw [projectorMatrix_sign_sub_apply A d positive orthogonal first second]
    simp [Fintype.sum_sigma, Fintype.sum_option, Fintype.sum_sum_type, cross]
  have column (c : Fin cols) : (∑ r, cross c r) =
      (4 * (d : ℝ) / (1 + (d : ℝ)) ^ 2) * (if first c ≠ second c then 1 else 0) := by
    have h : (∑ r, A r c * A r c) = d := by
      simpa using gram_entry A d orthogonal c c
    have length : (∑ r, (A r c : ℝ) ^ 2) = (d : ℝ) := by
      simp only [pow_two]
      exact_mod_cast h
    have signs : ((sign (first c) : ℝ) - (sign (second c) : ℝ)) ^ 2 =
        if first c = second c then 0 else 4 := by
      cases hfirst : first c <;> cases hsecond : second c <;>
        norm_num [sign, HCP.AxisSignedSampler.coefficient, hfirst, hsecond]
    calc
      (∑ r, cross c r) = ((1 + (d : ℝ))⁻¹) ^ 2 *
          (((sign (first c) : ℝ) - (sign (second c) : ℝ)) ^ 2) * ∑ r, (A r c : ℝ) ^ 2 := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro r _
        dsimp only [cross]
        ring
      _ = _ := by
        rw [length, signs]
        by_cases same : first c = second c
        · simp [same]
        · simp [same, div_eq_mul_inv, inv_pow]
          ring
  have transposeSum : (∑ r, ∑ c, cross c r) = ∑ c, ∑ r, cross c r := Finset.sum_comm
  rw [offDiagonal, transposeSum]
  simp_rw [column]
  simp only [← Finset.mul_sum, hammingDist, Finset.sum_boole]
  ring

/-- The shared chordal metric measures the sign-key family exactly. -/
theorem chordalDistance_sq_eq_hamming
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d : ℤ) (positive : 0 < d)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (first second : Fin cols → Bool) :
    chordalDistance (sheaf (presentation A first)).harmonicOneSubspace
      (sheaf (presentation A second)).harmonicOneSubspace ^ 2 =
        4 * (d : ℝ) / (1 + (d : ℝ)) ^ 2 * (hammingDist first second : ℝ) := by
  rw [chordalDistance_sq, frobenius_norm_sq]
  change (∑ i, ∑ j, (projectorMatrix (presentation A first) i j -
    projectorMatrix (presentation A second) i j) ^ 2) / 2 = _
  rw [projector_frobenius_sq_eq_hamming A d positive orthogonal first second]
  ring

end HomotopicalEncryption.HCP.CoupledProjectorMetric
