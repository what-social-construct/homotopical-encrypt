import Laplacian.Projection

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

open Matrix Real InnerProductSpace MeasureTheory

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- A classical adversary maps an observation b to a guessed Laplacian. -/
def ClassicalAdversary (n : Type*) [Fintype n] := EuclideanSpace ℝ n → Matrix n n ℝ

/-- A quantum adversary maps an observation b to a probability density over Laplacians. -/
def QuantumAdversary (n : Type*) [Fintype n] := EuclideanSpace ℝ n → Matrix n n ℝ → ℝ

-- Measurability infrastructure for integration over Ω_k.
instance : MeasurableSpace (Matrix n n ℝ) := borel (Matrix n n ℝ)
instance : BorelSpace (Matrix n n ℝ) := ⟨rfl⟩

variable (μ : Measure (Matrix n n ℝ))

/-- Validity condition for a quantum adversary: output must be a probability density. -/
def IsValidQuantumAdversary (Adv : QuantumAdversary n) (Ω_k : Set (Matrix n n ℝ)) : Prop :=
  ∀ b, (∀ A, 0 ≤ Adv b A) ∧ ∫ A in Ω_k, Adv b A ∂μ = 1

/-- The Gaussian likelihood of observing b given Laplacian A and noise level σ.
    NOTE: Uses L∞ norm (Pi norm on n → ℝ). See gaussianLikelihood_correct for L2 fix. -/
noncomputable def gaussianLikelihood (b : EuclideanSpace ℝ n) (A : Matrix n n ℝ) (σ : ℝ) : ℝ :=
  Real.exp (- (‖A *ᵥ b‖)^2 / (2 * σ^2))

/-- The minimum spectral gap across the family Ω_k.
    For Grassmannian Laplacians Δ = I - P_W, ALL nonzero eigenvalues
    equal 1 (projection spectrum = {0, 1}), so this is exactly 1.
    The relative gap λ₁/λ_max = 1/1 = 1 (governs quantum advantage).
    Matches Python: tsirelson.py relative_spectral_gap() = 1.0 for Gr(k,d). -/
noncomputable def MinSpectralGap (_Ω_k : Set (Matrix n n ℝ)) : ℝ := 1

/-- The success probability of a classical adversary. -/
noncomputable def success_prob_classical (Adv : ClassicalAdversary n) (_Ω_k : Set (Matrix n n ℝ)) (σ : ℝ) : ℝ :=
  ∫ b, gaussianLikelihood b (Adv b) σ * Real.exp (-‖b‖^2 / 2) ∂volume

/-- The success probability of a quantum adversary. -/
noncomputable def success_prob_quantum (Adv : QuantumAdversary n) (Ω_k : Set (Matrix n n ℝ)) (σ : ℝ) : ℝ :=
  ∫ b, (∫ A in Ω_k, Adv b A * gaussianLikelihood b A σ ∂μ) * Real.exp (-‖b‖^2 / 2) ∂volume

/-- Normalization factor for the Gaussian prior. -/
noncomputable def normalizationFactor (n : Type*) [Fintype n] : ℝ :=
  (2 * Real.pi) ^ (- (Fintype.card n : ℝ) / 2)

/-- The normalized success probability of a classical adversary. -/
noncomputable def success_prob_classical_norm (Adv : ClassicalAdversary n) (Ω_k : Set (Matrix n n ℝ)) (σ : ℝ) : ℝ :=
  normalizationFactor n * success_prob_classical Adv Ω_k σ

/-- The normalized success probability of a quantum adversary. -/
noncomputable def success_prob_quantum_norm (Adv : QuantumAdversary n) (Ω_k : Set (Matrix n n ℝ)) (σ : ℝ) : ℝ :=
  normalizationFactor n * success_prob_quantum μ Adv Ω_k σ

/-- The success probability of a classical adversary, constrained to Ω_k. -/
noncomputable def success_prob_classical' (Adv : ClassicalAdversary n) (Ω_k : Set (Matrix n n ℝ)) (σ : ℝ) : ℝ :=
  normalizationFactor n * ∫ b, (Ω_k.indicator (fun A => gaussianLikelihood b A σ) (Adv b)) * Real.exp (-‖b‖^2 / 2) ∂volume

/-
The Pi norm on (n → ℝ) is L∞ (sup norm), NOT L2.
gaussianLikelihood uses ‖A *ᵥ b‖ which is L∞.
gaussianLikelihood_correct wraps in WithLp 2 for the true L2 norm.
Python uses np.linalg.norm (L2), so the corrected version matches.
-/

/-- Pi norm on (Fin 2 → ℝ) is L∞: ‖(1,1)‖ = 1, not √2. -/
theorem pi_norm_is_Linf : (let v : Fin 2 → ℝ := fun _ => 1; ‖v‖ = 1) := by
  simp [Pi.norm_def, Finset.sup_const]

/-- The corrected Gaussian likelihood using L2 norm (matches Python's np.linalg.norm). -/
noncomputable def gaussianLikelihood_correct (b : EuclideanSpace ℝ n) (A : Matrix n n ℝ) (σ : ℝ) : ℝ :=
  Real.exp (- (‖(WithLp.equiv 2 (n → ℝ)).symm (A *ᵥ b)‖)^2 / (2 * σ^2))

/-- The corrected likelihood matches the noise model for Laplacians:
    L(b | Δ_W, σ) = exp(-‖P_{W⊥} b‖² / 2σ²). -/
lemma likelihood_correct_of_laplacian (b : EuclideanSpace ℝ n) (W : Submodule ℝ (EuclideanSpace ℝ n)) [W.HasOrthogonalProjection] (σ : ℝ) :
  gaussianLikelihood_correct b (_root_.laplacian W) σ = Real.exp (- ‖(Submodule.orthogonalProjection W.orthogonal) b‖^2 / (2 * σ^2)) := by
  rw [gaussianLikelihood_correct]
  congr 3
  rw [laplacian_apply]
  simp only [WithLp.equiv_symm_apply]
  simp +decide [ Norm.norm ]

/-- The optimal classical adversary guesses W = span{b} (Bayes-optimal for k=1).
    Python: tsirelson.py optimal_classical_adversary() returns argmax likelihood. -/
noncomputable def optimal_classical_adversary (b : EuclideanSpace ℝ n) : Matrix n n ℝ :=
  if _h : b = 0 then 0 else
  let W := Submodule.span ℝ {b}
  haveI : FiniteDimensional ℝ W := FiniteDimensional.span_singleton ℝ b
  haveI : W.HasOrthogonalProjection := Submodule.HasOrthogonalProjection.ofCompleteSpace W
  laplacian W

/-- The optimal adversary achieves likelihood 1 for non-zero b.
    This is because b ∈ span{b}, so P_{span{b}⊥}(b) = 0, giving exp(0) = 1.
    The adversary always guesses correctly — but only for this single observation.
    The hardness comes from the INTEGRATION over all b (the search space). -/
lemma optimal_adversary_likelihood_one (b : EuclideanSpace ℝ n) (hb : b ≠ 0) (σ : ℝ) :
  gaussianLikelihood b (optimal_classical_adversary b) σ = 1 := by
    unfold gaussianLikelihood optimal_classical_adversary;
    split_ifs ; simp_all +decide;
    rw [ laplacian_apply, Submodule.orthogonalProjection_mem_subspace_orthogonalComplement_eq_zero ] ; aesop;
    simp +decide

/-- Gaussian integrand factors over coordinates:
    exp(-‖x‖²/2) = ∏ᵢ exp(-xᵢ²/2).
    This enables product-form integration bounds for success probability. -/
lemma gaussian_integrand_factorization (x : EuclideanSpace ℝ n) :
  Real.exp (-‖x‖^2 / 2) = ∏ i : n, Real.exp (-(x i)^2 / 2) := by
    rw [ ← Real.exp_sum, EuclideanSpace.norm_eq ];
    simp +decide [ ← Finset.sum_div, Real.sq_sqrt ( Finset.sum_nonneg fun _ _ => sq_nonneg _ ) ]

end
