import Mathlib

/-
  Paper correspondence:
  - Paper 1 Section 4: spectral public judgment interface.
  - Paper 1 Sections 2--3: spectral fingerprints in hidden-operator ambiguity.
-/

set_option linter.mathlibStandardSet false

open scoped BigOperators Real Nat Classical Pointwise
open scoped RealInnerProductSpace

set_option maxHeartbeats 0
set_option maxRecDepth 4000
set_option synthInstance.maxHeartbeats 20000
set_option synthInstance.maxSize 128
set_option relaxedAutoImplicit false
set_option autoImplicit false

noncomputable section

variable {V : Type} [NormedAddCommGroup V] [InnerProductSpace ℝ V] [FiniteDimensional ℝ V]

/-- The Laplacian operator Δ on the space of sheaf cochains. -/
structure SheafLaplacian (V : Type) [NormedAddCommGroup V] [InnerProductSpace ℝ V] [FiniteDimensional ℝ V] where
  Δ : V →ₗ[ℝ] V
  is_self_adjoint : LinearMap.IsSymmetric Δ
  is_positive : LinearMap.IsPositive Δ

/-- The spectral fingerprint of a sheaf is the multiset of eigenvalues. -/
noncomputable def SpectralFingerprint (L : SheafLaplacian V) : Multiset ℝ :=
  let n := Module.finrank ℝ V
  let eigenvalues := L.is_self_adjoint.eigenvalues (by rfl : Module.finrank ℝ V = n)
  Multiset.map (fun i => eigenvalues i) (Finset.univ.val)

/-- Two sheaves are spectrally equivalent if they have the same spectral fingerprint. -/
def SpectrallyEquivalent (L1 L2 : SheafLaplacian V) : Prop :=
  SpectralFingerprint L1 = SpectralFingerprint L2

/-- A scalar Laplacian on ℝ. -/
noncomputable def ScalarLaplacian (c : ℝ) (hc : 0 ≤ c) : SheafLaplacian ℝ :=
  {
    Δ := c • LinearMap.id
    is_self_adjoint := by
      intro x y; simp +decide [ mul_comm ] ;
      ring
    is_positive := by
      constructor ; aesop;
      simp +decide;
      exact fun x => by nlinarith [ mul_self_nonneg x ] ;
  }

/-- The kernel dimension of a scalar Laplacian with positive scalar is 0. -/
lemma ScalarLaplacian_ker_dim (c : ℝ) (hc : 0 < c) :
  Module.finrank ℝ (LinearMap.ker (ScalarLaplacian c (le_of_lt hc)).Δ) = 0 := by
    rw [ LinearMap.ker_eq_bot.mpr ] <;> norm_num;
    exact fun x y hxy => by simpa [ hc.ne' ] using smul_right_injective ℝ hc.ne' hxy;

/-- The only eigenvalue of the scalar map `c • id` on `ℝ` is `c`. -/
lemma scalar_map_eigenvalue_unique (c μ : ℝ) (h : Module.End.HasEigenvalue (c • (LinearMap.id : ℝ →ₗ[ℝ] ℝ)) μ) :
  μ = c := by
    simp_all +decide [ Module.End.HasUnifEigenvalue ];
    simp_all +decide [ Submodule.eq_bot_iff ];
    grind

/-- The 0-th eigenvalue of the scalar Laplacian on ℝ is c. -/
lemma ScalarLaplacian_eigenvalue_zero (c : ℝ) (hc : 0 ≤ c) :
  (ScalarLaplacian c hc).is_self_adjoint.eigenvalues (Module.finrank_self ℝ) 0 = c := by
    have h_eigenvalue : ∀ (μ : ℝ), Module.End.HasEigenvalue (c • LinearMap.id : ℝ →ₗ[ℝ] ℝ) μ → μ = c := by
      exact fun μ a => scalar_map_eigenvalue_unique c μ a
    convert h_eigenvalue _ _;
    convert LinearMap.IsSymmetric.hasEigenvalue_eigenvalues _ _ _

/-- The spectral fingerprint of a scalar Laplacian is the singleton {c}. -/
lemma ScalarLaplacian_fingerprint (c : ℝ) (hc : 0 ≤ c) :
  SpectralFingerprint (ScalarLaplacian c hc) = {c} := by
    simp [SpectralFingerprint];
    convert ScalarLaplacian_eigenvalue_zero c hc

/-- Homotopy equivalence for Laplacians based on kernel dimension. -/
def HomotopyEquivalentLaplacians {V : Type} [NormedAddCommGroup V] [InnerProductSpace ℝ V] [FiniteDimensional ℝ V] (L1 L2 : SheafLaplacian V) : Prop :=
  Module.finrank ℝ (LinearMap.ker L1.Δ) = Module.finrank ℝ (LinearMap.ker L2.Δ)

/-- Two SheafLaplacians can be homotopy equivalent but NOT spectrally equivalent. -/
theorem Spectrum_Not_Homotopy_Invariant :
  ∃ (L1 L2 : SheafLaplacian ℝ), HomotopyEquivalentLaplacians L1 L2 ∧ ¬ SpectrallyEquivalent L1 L2 := by
    refine' ⟨ _, _, _, _ ⟩;
    exact ScalarLaplacian 1 zero_le_one;
    exact ScalarLaplacian 2 zero_le_two;
    · exact Eq.symm ( by rw [ ScalarLaplacian_ker_dim 1 zero_lt_one, ScalarLaplacian_ker_dim 2 zero_lt_two ] );
    · unfold SpectrallyEquivalent; norm_num [ ScalarLaplacian_fingerprint ] ;

end
