module

/-
Tsirelson-bound formalization for the homotopical-encrypt Lean workspace.

Paper correspondence:
- Supporting spectral/Grassmannian geometry for Paper 2's oracle and
  Proof-of-Value construction contracts.
- This wider spectral layer is outside Paper 1's selected Hodge/CVP and
  observation results.

Role in the architecture:
  This file is the formal geometry/edge-case layer for the PoV construction.
  It is not the runtime oracle implementation and it is not the core HCP
  exact-recovery and observation obstruction. Its job is to make the
  Grassmannian/Laplacian objects precise enough that the spectral gate has a
  mathematical target: admissible operators, kernels, projections, bounds, and
  ambiguity/identifiability edge cases.

  In the TCB split, Lean handles these mathematical admissibility statements;
  Rust/oracle code must still validate concrete bytes, attest results, enforce
  gate policy, and harden endpoints.
-/

public import Mathlib
public import Axioms.SpectralBounds

@[expose] public section

set_option linter.mathlibStandardSet false

open scoped BigOperators
open scoped Real
open scoped Nat
open scoped Classical
open scoped Pointwise

set_option maxHeartbeats 0
set_option maxRecDepth 4000
set_option synthInstance.maxHeartbeats 20000
set_option synthInstance.maxSize 128

set_option relaxedAutoImplicit false
set_option autoImplicit false

noncomputable section

/-
The set of Laplacians parameterized by the Grassmannian Gr(k, n), where each Laplacian is the projection onto the orthogonal complement of a k-dimensional subspace W (so ker(Δ) = W).
-/
def Grassmannian_Laplacians {n : Type} [Fintype n] {R : Type} [RCLike R] [DecidableEq n] (k : ℕ) : Set (Matrix n n R) :=
  { Δ | ∃ (W : Module.Grassmannian R (EuclideanSpace R n) k),
    let P_W := (W.toSubmodule.subtypeL.comp W.toSubmodule.orthogonalProjection).toLinearMap
    let P_perp := LinearMap.id - P_W
    let iso := WithLp.linearEquiv 2 R (n → R)
    Δ = LinearMap.toMatrix' (iso.toLinearMap ∘ₗ P_perp ∘ₗ iso.symm.toLinearMap) }

/-
The set of Laplacians parameterized by the Grassmannian Gr(1, n).
-/
def Ω_G {n : Type} [Fintype n] {R : Type} [RCLike R] [DecidableEq n] : Set (Matrix n n R) :=
  Grassmannian_Laplacians 1

/-
Redefining necessary definitions from Tsirelson_bound.lean.
-/
def LaplacianSpace {n : Type} [Fintype n] {R : Type} [RCLike R] [DecidableEq n] (β : Nat) : Set (Matrix n n R) :=
  { Δ | Δ.IsHermitian ∧ (∀ x : n → R, 0 ≤ RCLike.re (star x ⬝ᵥ Δ.mulVec x)) ∧ Module.finrank R (LinearMap.ker (Matrix.mulVecLin Δ)) = β }

def SpectralGap {n : Type} [Fintype n] {R : Type} [RCLike R] [DecidableEq n] (Δ : Matrix n n R) (hΔ : Δ.IsHermitian) : Real :=
  let evals := hΔ.eigenvalues
  if ∃ i, evals i ≠ 0 then
    sInf { x | ∃ i, evals i = x ∧ x ≠ 0 }
  else 0

def likelihood {n : Type} [Fintype n] {R : Type} [RCLike R] (b : EuclideanSpace R n) (Δ : Matrix n n R) : Real :=
  let b_vec : n → R := (WithLp.equiv 2 (n → R)) b
  let v_vec := Δ.mulVec b_vec
  let v : EuclideanSpace R n := (WithLp.equiv 2 (n → R)).symm v_vec
  Real.exp (- (RCLike.re (inner R v v)) - (RCLike.re (inner R b b)))

def Classical_Adversary (n : Type) [Fintype n] (R : Type) [RCLike R] :=
  (n → R) → Matrix n n R

noncomputable def success_prob_classical {n : Type} [Fintype n] {R : Type} [RCLike R]
  (A : Classical_Adversary n R) (Ω : Set (Matrix n n R)) : Real :=
  if _h : Ω.Nonempty ∧ (MeasureTheory.MeasureSpace.volume : MeasureTheory.Measure (EuclideanSpace R n)) ≠ 0 then
    let Z (Δ : Matrix n n R) := ∫ (b : EuclideanSpace R n), likelihood b Δ
    let score (Δ : Matrix n n R) := ∫ (b : EuclideanSpace R n), likelihood b Δ * (if A (WithLp.equiv 2 (n → R) b) = Δ then 1 else 0)
    sInf { x | ∃ Δ ∈ Ω, x = score Δ / Z Δ }
  else 0

def Quantum_Adversary (n : Type) [Fintype n] (R : Type) [RCLike R] :=
  (n → R) → (Matrix n n R → Real)

noncomputable def success_prob_quantum {n : Type} [Fintype n] {R : Type} [RCLike R]
  (A : Quantum_Adversary n R) (Ω : Set (Matrix n n R)) : Real :=
  if _h : Ω.Nonempty ∧ (MeasureTheory.MeasureSpace.volume : MeasureTheory.Measure (EuclideanSpace R n)) ≠ 0 then
    let Z (Δ : Matrix n n R) := ∫ (b : EuclideanSpace R n), likelihood b Δ
    let score (Δ : Matrix n n R) := ∫ (b : EuclideanSpace R n), likelihood b Δ * (A (WithLp.equiv 2 (n → R) b) Δ)
    sInf { x | ∃ Δ ∈ Ω, x = score Δ / Z Δ }
  else 0

noncomputable def MinSpectralGap {n : Type} [Fintype n] {R : Type} [RCLike R] [DecidableEq n]
  (Ω : Set (Matrix n n R)) : Real :=
  sInf { x | ∃ Δ ∈ Ω, ∃ (h : Δ.IsHermitian), x = SpectralGap Δ h }

/-
R is infinite because it is an algebra over the reals.
-/
theorem R_infinite {R : Type} [RCLike R] : Infinite R := by
  have : Algebra ℝ R := RCLike.toNormedAlgebra.toAlgebra
  have : Infinite ℝ := by infer_instance
  exact Infinite.of_injective (algebraMap ℝ R) (RingHom.injective _)

/-
There are infinitely many 1-dimensional subspaces in R^n.
-/
open scoped Classical

theorem infinite_lines {n : Type} [Fintype n] {R : Type} [RCLike R] [DecidableEq n] (h_dim : Fintype.card n ≥ 2) :
  Set.Infinite {W : Submodule R (EuclideanSpace R n) | Module.finrank R W = 1} := by
  have h_infinite_subspaces : Set.Infinite { W : Submodule R (EuclideanSpace R n) | ∃ x : EuclideanSpace R n, x ≠ 0 ∧ W = Submodule.span R {x} } := by
    obtain ⟨i, j, hij⟩ : ∃ i j : n, i ≠ j := by
      exact Fintype.one_lt_card_iff.1 h_dim;
    let v : R → EuclideanSpace R n :=
      fun x => WithLp.toLp 2 (fun k => if k = i then 1 else x)
    have hv_i (x : R) : v x i = 1 := by
      simp [v, PiLp.toLp_apply]
    have hv_j (x : R) : v x j = x := by
      simp [v, PiLp.toLp_apply, Ne.symm hij]
    refine Set.infinite_of_injective_forall_mem
      (f := fun x : R => Submodule.span R {v x}) ?_ ?_
    · intro x y hxy
      change Submodule.span R {v x} = Submodule.span R {v y} at hxy
      have hxmem : v x ∈ Submodule.span R {v y} := by
        rw [← hxy]
        exact Submodule.subset_span (by simp)
      obtain ⟨a, ha⟩ := Submodule.mem_span_singleton.mp hxmem
      have hi := congrArg (fun z : EuclideanSpace R n => z i) ha
      have hj := congrArg (fun z : EuclideanSpace R n => z j) ha
      simp only [PiLp.smul_apply, hv_i, smul_eq_mul, mul_one] at hi
      simp only [PiLp.smul_apply, hv_j, smul_eq_mul] at hj
      simpa [hi] using hj.symm
    · intro x
      refine ⟨v x, ?_, rfl⟩
      intro h
      have hi := congrArg (fun z : EuclideanSpace R n => z i) h
      simpa [hv_i] using hi
  refine h_infinite_subspaces.mono ?_;
  intro W hW
  obtain ⟨x, hx_ne_zero, hx_span⟩ := hW
  have hx_dim : Module.finrank R (Submodule.span R {x}) = 1 := by
    rw [ finrank_span_singleton ] ; aesop
  aesop

/-
The map from Grassmannian subspaces to Laplacians is injective.
-/
theorem Grassmannian_Laplacian_injective {n : Type} [Fintype n] {R : Type} [RCLike R] [DecidableEq n] :
  Function.Injective (fun (W : Module.Grassmannian R (EuclideanSpace R n) 1) =>
    let P_W := (W.toSubmodule.subtypeL.comp W.toSubmodule.orthogonalProjection).toLinearMap
    let P_perp := LinearMap.id - P_W
    let iso := WithLp.linearEquiv 2 R (n → R)
    LinearMap.toMatrix' (iso.toLinearMap ∘ₗ P_perp ∘ₗ iso.symm.toLinearMap)) := by
  intro W₁ W₂ hW; simp_all +decide;
  have h_subspace_eq : ∀ (W : Module.Grassmannian R (EuclideanSpace R n) 1), ∀ (v : EuclideanSpace R n), v ∈ W.toSubmodule ↔ (W.orthogonalProjection v : EuclideanSpace R n) = v := by
    intro W v; exact ⟨fun hv => by
      simp +decide [ hv, Submodule.starProjection_eq_self_iff ], fun hv => by
      exact hv ▸ Submodule.coe_mem _⟩;
  ext v; replace hW := congr_arg ( fun f => f v ) hW; aesop;

/-
The set of Laplacians parameterized by 1-dimensional subspaces.
-/
def Ω_1 {n : Type} [Fintype n] {R : Type} [RCLike R] [DecidableEq n] : Set (Matrix n n R) :=
  let lines := {W : Submodule R (EuclideanSpace R n) | Module.finrank R W = 1}
  (fun (W : Submodule R (EuclideanSpace R n)) =>
    let P_W := (W.subtypeL.comp W.orthogonalProjection).toLinearMap
    let P_perp := LinearMap.id - P_W
    let iso := WithLp.linearEquiv 2 R (n → R)
    LinearMap.toMatrix' (iso.toLinearMap ∘ₗ P_perp ∘ₗ iso.symm.toLinearMap)) '' lines

/-
The map from a subspace to its orthogonal projection operator is injective.
-/
def projector_map {n : Type} [Fintype n] {R : Type} [RCLike R] [DecidableEq n]
  (W : Submodule R (EuclideanSpace R n)) : (EuclideanSpace R n) →ₗ[R] (EuclideanSpace R n) :=
  (W.subtypeL.comp W.orthogonalProjection).toLinearMap

theorem projector_injective {n : Type} [Fintype n] {R : Type} [RCLike R] [DecidableEq n] :
  Function.Injective (@projector_map n _ R _ _) := by
    unfold projector_map;
    intro W₁ W₂ h_eq;
    apply_fun fun f => LinearMap.range f at h_eq;
    convert h_eq using 1;
    · ext x; simp;
      constructor <;> intro hx;
      · use x;
        exact Submodule.starProjection_eq_self_iff.mpr hx
      · obtain ⟨ y, rfl ⟩ := hx;
        exact Submodule.starProjection_apply_mem W₁ y
    · ext; simp;
      constructor;
      · exact fun hx => ⟨ _, Submodule.starProjection_eq_self_iff.mpr hx ⟩;
      · aesop

/-
The map from subspaces to Laplacians is injective.
-/
theorem laplacian_injective {n : Type} [Fintype n] {R : Type} [RCLike R] [DecidableEq n] :
  Function.Injective (fun (W : Submodule R (EuclideanSpace R n)) =>
    let P_W := (W.subtypeL.comp W.orthogonalProjection).toLinearMap
    let P_perp := LinearMap.id - P_W
    let iso := WithLp.linearEquiv 2 R (n → R)
    LinearMap.toMatrix' (iso.toLinearMap ∘ₗ P_perp ∘ₗ iso.symm.toLinearMap)) := by
      intro W₁ W₂ h_eq
      have h_proj : projector_map W₁ = projector_map W₂ := by
        simp +zetaDelta at *;
        simpa [projector_map] using h_eq
      apply projector_injective h_proj

/-
The set Ω_1 is infinite because it is the image of an infinite set under an injective map.
-/
theorem Ω_1_infinite {n : Type} [Fintype n] {R : Type} [RCLike R] [DecidableEq n] (h_dim : Fintype.card n ≥ 2) :
  Set.Infinite (@Ω_1 n _ R _ _) := by
    unfold Ω_1
    exact Set.Infinite.image laplacian_injective.injOn (infinite_lines h_dim)

/-
The Laplacian constructed from a 1-dimensional subspace W is Hermitian, positive semi-definite, and has a kernel of dimension 1.
-/
theorem laplacian_properties {n : Type} [Fintype n] {R : Type} [RCLike R] [DecidableEq n]
  (W : Submodule R (EuclideanSpace R n)) (hW : Module.finrank R W = 1) :
  let P_W := (W.subtypeL.comp W.orthogonalProjection).toLinearMap
  let P_perp := LinearMap.id - P_W
  let iso := WithLp.linearEquiv 2 R (n → R)
  let Δ := LinearMap.toMatrix' (iso.toLinearMap ∘ₗ P_perp ∘ₗ iso.symm.toLinearMap)
  Δ.IsHermitian ∧ (∀ x : n → R, 0 ≤ RCLike.re (star x ⬝ᵥ Δ.mulVec x)) ∧ Module.finrank R (LinearMap.ker (Matrix.mulVecLin Δ)) = 1 := by
  refine' ⟨ _, _, _ ⟩ <;> norm_num [ Matrix.IsHermitian ];
  · ext i j;
    simp +decide [ LinearMap.toMatrix', Matrix.conjTranspose ];
    have h_orthogonal : ∀ (x y : EuclideanSpace R n), inner R x ((W.subtypeL.comp W.orthogonalProjection) y) = inner R ((W.subtypeL.comp W.orthogonalProjection) x) y := by
      simp +zetaDelta at *;
      exact fun x y => Eq.symm (Submodule.inner_starProjection_left_eq_right W x y)
    specialize h_orthogonal ( EuclideanSpace.single j 1 ) ( EuclideanSpace.single i 1 ) ; simp_all +decide [ inner ];
    grind;
  · intro x
    have h_inner : (RCLike.re (star x ⬝ᵥ (W.starProjection (WithLp.toLp 2 x)))) = (RCLike.re (star (W.starProjection (WithLp.toLp 2 x)) ⬝ᵥ (W.starProjection (WithLp.toLp 2 x)))) := by
      simp +decide [ dotProduct, mul_comm ];
      have h_inner : ∀ x : EuclideanSpace R n, (inner R x (W.starProjection x)) = (inner R (W.starProjection x) (W.starProjection x)) := by
        intro x;
        rw [ ← sub_eq_zero, ← inner_sub_left ];
        aesop;
      convert congr_arg ( fun x : R => RCLike.re x ) ( h_inner ( WithLp.toLp 2 x ) ) using 1 <;> simp +decide [ inner ];
      simp only [add_comm, mul_comm]
    have h_inner : (RCLike.re (star (W.starProjection (WithLp.toLp 2 x)) ⬝ᵥ (W.starProjection (WithLp.toLp 2 x)))) ≤ (RCLike.re (star (WithLp.toLp 2 x) ⬝ᵥ (WithLp.toLp 2 x))) := by
      have h_inner : ∀ (v : EuclideanSpace R n), (RCLike.re (star (W.starProjection v) ⬝ᵥ (W.starProjection v))) ≤ (RCLike.re (star v ⬝ᵥ v)) := by
        intro v
        have h_inner : (RCLike.re (star (W.starProjection v) ⬝ᵥ (W.starProjection v))) = (RCLike.re (star v ⬝ᵥ (W.starProjection v))) := by
          have h_inner : ∀ (u v : EuclideanSpace R n), (RCLike.re (star (W.starProjection u) ⬝ᵥ v)) = (RCLike.re (star u ⬝ᵥ (W.starProjection v))) := by
            simp +decide [ dotProduct, mul_comm ];
            intro u v; exact (by
            have h_inner : ∀ (u v : EuclideanSpace R n), (inner R (W.starProjection u) v) = (inner R u (W.starProjection v)) := by
              exact fun u v => Submodule.inner_starProjection_left_eq_right W u v
            convert congr_arg ( fun x : R => RCLike.re x ) ( h_inner u v ) using 1 <;> simp +decide [ inner, Finset.sum_add_distrib, mul_comm ]);
          convert h_inner v ( W.starProjection v ) using 1;
          rw [ W.starProjection_apply, W.starProjection_apply ];
          rw [ Submodule.orthogonalProjection_mem_subspace_eq_self ];
        have h_inner : (RCLike.re (star (v - W.starProjection v) ⬝ᵥ (v - W.starProjection v))) ≥ 0 := by
          have h_inner : ∀ (v : EuclideanSpace R n), (RCLike.re (star v ⬝ᵥ v)) ≥ 0 := by
            simp +decide [ dotProduct ];
            exact fun v => Finset.sum_nonneg fun _ _ => add_nonneg ( mul_self_nonneg _ ) ( mul_self_nonneg _ );
          exact h_inner _;
        simp_all +decide [ dotProduct, Finset.sum_sub_distrib, sub_mul, mul_sub ];
        simp_all +decide [ mul_comm, Finset.sum_add_distrib ]
      exact h_inner _;
    convert h_inner using 1;
  · have h_kernel : LinearMap.ker ((LinearMap.toMatrix' : ((n → R) →ₗ[R] n → R) → Matrix n n R) ((↑(WithLp.linearEquiv 2 R (n → R)) : WithLp 2 (n → R) →ₗ[R] n → R) ∘ₗ (LinearMap.id - (↑(W.subtypeL.comp W.orthogonalProjection) : EuclideanSpace R n →ₗ[R] EuclideanSpace R n)) ∘ₗ (↑(WithLp.linearEquiv 2 R (n → R)).symm : (n → R) →ₗ[R] WithLp 2 (n → R)))).mulVecLin = Submodule.map (WithLp.linearEquiv 2 R (n → R)).toLinearMap W := by
      ext; simp [LinearMap.mem_ker];
      rw [ sub_eq_zero ];
      constructor <;> intro h;
      · apply Submodule.starProjection_eq_self_iff.mp
        simpa only [WithLp.toLp_ofLp] using
          (congrArg (WithLp.toLp 2) h).symm
      · exact (congrArg WithLp.ofLp
          (Submodule.starProjection_eq_self_iff.mpr h)).symm
    convert hW using 1;
    rw [ h_kernel ];
    convert LinearEquiv.finrank_map_eq _ _

/-
The Laplacian is Hermitian because it is the matrix representation of a self-adjoint operator (orthogonal projection) under a unitary transformation.
-/
theorem laplacian_is_hermitian {n : Type} [Fintype n] {R : Type} [RCLike R] [DecidableEq n]
  (W : Submodule R (EuclideanSpace R n)) :
  let P_W := (W.subtypeL.comp W.orthogonalProjection).toLinearMap
  let P_perp := LinearMap.id - P_W
  let iso := WithLp.linearEquiv 2 R (n → R)
  let Δ := LinearMap.toMatrix' (iso.toLinearMap ∘ₗ P_perp ∘ₗ iso.symm.toLinearMap)
  Δ.IsHermitian := by
  intro P_W P_perp iso Δ
  rw [Matrix.IsHermitian]
  -- We need to show Δᴴ = Δ
  -- Δ = toMatrix' (iso ∘ P_perp ∘ iso⁻¹)
  -- Δᴴ = toMatrix' ((iso ∘ P_perp ∘ iso⁻¹)†)
  -- Since iso is unitary (preserves inner product), iso† = iso⁻¹
  -- So (iso ∘ P_perp ∘ iso⁻¹)† = (iso⁻¹)† ∘ P_perp† ∘ iso† = iso ∘ P_perp† ∘ iso⁻¹
  -- P_perp is self-adjoint (Hermitian), so P_perp† = P_perp
  -- Thus Δᴴ = Δ
  -- Since P_perp is self-adjoint, its matrix representation is Hermitian.
  have h_self_adjoint : ∀ (v w : WithLp 2 (n → R)), inner R (P_perp v) w = inner R v (P_perp w) := by
    intro v w
    simp [P_perp, P_W];
    simp +decide [ inner_sub_left, inner_sub_right ];
    exact Submodule.inner_starProjection_left_eq_right W v w
  ext i j;
  convert h_self_adjoint ( iso.symm ( Pi.single i 1 ) ) ( iso.symm ( Pi.single j 1 ) ) using 1;
  · simp +decide [ Δ, LinearMap.toMatrix', Inner.inner ];
    rw [ Finset.sum_eq_single j ] <;> aesop;
  · simp +decide [ Δ, LinearMap.toMatrix' ];
    simp +decide [ Inner.inner ];
    rw [ Finset.sum_eq_single i ] <;> aesop

/-
Every Laplacian in Ω_1 is in LaplacianSpace 1.
-/
theorem Ω_1_subset_LaplacianSpace {n : Type} [instN : Fintype n] {R : Type} [instR : RCLike R] [instDec : DecidableEq n] :
  @Ω_1 n instN R instR instDec ⊆ @LaplacianSpace n instN R instR instDec 1 := by
  intro Δ hΔ
  rw [Ω_1] at hΔ
  rcases hΔ with ⟨W, hW_rank, rfl⟩
  exact @laplacian_properties n instN R instR instDec W hW_rank

/-
Every Laplacian in Ω_1 is in LaplacianSpace 1.
-/
theorem Ω_1_subset_LaplacianSpace_v3 {n : Type} [instN : Fintype n] {R : Type} [instR : RCLike R] [instDec : DecidableEq n] :
  @Ω_1 n instN R instR instDec ⊆ @LaplacianSpace n instN R instR instDec 1 := by
  intro Δ hΔ
  rw [Ω_1] at hΔ
  rcases hΔ with ⟨W, hW_rank, rfl⟩
  exact @laplacian_properties n instN R instR instDec W hW_rank

/-
R is uncountable because it contains the reals.
-/
theorem R_uncountable {R : Type} [RCLike R] : Uncountable R := by
  have h_inj : Function.Injective (fun x : ℝ => (x : R)) := by
    exact RCLike.ofReal_injective
  have h_real_uncountable : Uncountable ℝ := by
    infer_instance;
  exact Function.Injective.uncountable h_inj

/-
The set Ω_1 is infinite because it is the image of an infinite set under an injective map.
-/
theorem Ω_1_infinite_v2 {n : Type} [instN : Fintype n] {R : Type} [instR : RCLike R] [instDec : DecidableEq n] (h_dim : Fintype.card n ≥ 2) :
  Set.Infinite (@Ω_1 n instN R instR instDec) := by
    convert Ω_1_infinite h_dim using 1

/-
Every Laplacian in Ω_1 is in LaplacianSpace 1.
-/
theorem Ω_1_subset_LaplacianSpace_v5 {n : Type} [instN : Fintype n] {R : Type} [instR : RCLike R] [instDec : DecidableEq n] :
  @Ω_1 n instN R instR instDec ⊆ @LaplacianSpace n instN R instR instDec 1 := by
  intro Δ hΔ
  rw [Ω_1] at hΔ
  rcases hΔ with ⟨W, hW_rank, rfl⟩
  exact @laplacian_properties n instN R instR instDec W hW_rank

/-
Every Laplacian in Ω_1 is in LaplacianSpace 1.
-/
theorem Ω_1_subset_LaplacianSpace_explicit_v2 {n : Type} [instN : Fintype n] {R : Type} [instR : RCLike R] [instDec : DecidableEq n] :
  @Ω_1 n instN R instR instDec ⊆ @LaplacianSpace n instN R instR instDec 1 := by
  rintro Δ ⟨W, hW_rank, rfl⟩
  exact @laplacian_properties n instN R instR instDec W hW_rank

/-
Every Laplacian in Ω_1 is in LaplacianSpace 1.
-/
theorem Ω_1_subset_LaplacianSpace_explicit {n : Type} [instN : Fintype n] {R : Type} [instR : RCLike R] [instDec : DecidableEq n] :
  @Ω_1 n instN R instR instDec ⊆ @LaplacianSpace n instN R instR instDec 1 := by
  intro Δ hΔ
  rw [Ω_1] at hΔ
  rcases hΔ with ⟨W, hW_rank, rfl⟩
  rw [LaplacianSpace]
  simp only [Set.mem_setOf_eq]
  let P_W := (W.subtypeL.comp W.orthogonalProjection).toLinearMap
  let P_perp := LinearMap.id - P_W
  let iso := WithLp.linearEquiv 2 R (n → R)
  -- 1. Hermitian
  have h_herm : (LinearMap.toMatrix' (iso.toLinearMap ∘ₗ P_perp ∘ₗ iso.symm.toLinearMap)).IsHermitian := by
    exact laplacian_is_hermitian W
  -- 2. PSD
  have h_psd : ∀ x : n → R, 0 ≤ RCLike.re (star x ⬝ᵥ (LinearMap.toMatrix' (iso.toLinearMap ∘ₗ P_perp ∘ₗ iso.symm.toLinearMap)).mulVec x) := by
    intro x
    convert laplacian_properties W hW_rank |>.2.1 x using 1
  -- 3. Kernel dimension
  have h_ker : Module.finrank R (LinearMap.ker (Matrix.mulVecLin (LinearMap.toMatrix' (iso.toLinearMap ∘ₗ P_perp ∘ₗ iso.symm.toLinearMap)))) = 1 := by
    convert laplacian_properties W hW_rank |>.2.2 using 1
  exact ⟨h_herm, h_psd, h_ker⟩

/-
The set Ω_1 is non-empty.
-/
theorem Ω_1_Nonempty {n : Type} [instN : Fintype n] {R : Type} [instR : RCLike R] [instDec : DecidableEq n] (h_dim : Fintype.card n ≥ 1) :
  (@Ω_1 n instN R instR instDec).Nonempty := by
    -- Since n is nonempty, there exists at least one non-zero vector in R^n. Let's pick any such vector, say v.
    obtain ⟨v, hv⟩ : ∃ v : EuclideanSpace R n, v ≠ 0 := by
      refine ⟨WithLp.toLp 2 (fun _ => (1 : R)), ?_⟩
      intro h
      have hi := congrArg (fun z : EuclideanSpace R n =>
        z (Classical.choose (Finset.card_pos.mp h_dim))) h
      simpa [PiLp.toLp_apply] using hi
    refine' ⟨ _, ⟨ Submodule.span R { v }, _, rfl ⟩ ⟩;
    rw [ Set.mem_setOf_eq, finrank_span_singleton ] ; aesop

-- ═══════════════════════════════════════════════════════════════════════
-- Adversary Bound Theorems (from Tsirelson_bound.lean)
-- ═══════════════════════════════════════════════════════════════════════

/-- Classical adversary strategy type. -/
def Classical_Strategy (n : Type) := n

/-- Quantum adversary strategy type. -/
def Quantum_Strategy (n : Type) [Fintype n] (R : Type) [RCLike R] := EuclideanSpace R n

/-- Maximum eigenvalue of a Hermitian matrix. -/
noncomputable def MaxEigenvalue {n : Type} [Fintype n] {R : Type} [RCLike R] [DecidableEq n] (Δ : Matrix n n R) (hΔ : Δ.IsHermitian) : Real :=
  sSup { x | ∃ i, hΔ.eigenvalues i = x }

/-
PoV/Tsirelson spectral bounds are centralized in `Axioms.SpectralBounds`.
This file supplies the surrounding Grassmannian/Laplacian geometry and keeps
the historical adversary-bound sanity checks below separate from the canonical
consensus predicate.
-/

/--
Non-vacuous classical-bound statement for a concrete candidate family.

This is the statement shape we ultimately want for `Ω_1` or another explicit
nonempty Grassmannian family. It intentionally includes `Ω.Nonempty` so the
empty-family proof below cannot be mistaken for a hardness result.
-/
def Classical_Bound_Statement {n : Type} [Fintype n] {R : Type} [RCLike R]
    (Ω : Set (Matrix n n R)) : Prop :=
  Ω.Nonempty ∧ Ω ⊆ LaplacianSpace 1 ∧
    ∀ (A : Classical_Adversary n R),
      success_prob_classical A Ω ≤ (1 / 2) ^ (Fintype.card n)

/--
Non-vacuous quantum-bound statement for a concrete candidate family.

This records the intended Tsirelson-style "bounded quantum advantage" target,
but does not claim the analytic bound has been proved for `Ω_1` yet.
-/
def Quantum_Bound_Statement {n : Type} [Fintype n] {R : Type} [RCLike R] [DecidableEq n]
    (Ω : Set (Matrix n n R)) (C : Real) : Prop :=
  Ω.Nonempty ∧ Ω ⊆ LaplacianSpace 1 ∧
    ∀ (A : Quantum_Adversary n R),
      success_prob_quantum A Ω ≤
        (1 / 2) ^ (Fintype.card n) * (1 + C * MinSpectralGap Ω)

/--
Empty-family sanity check.

This theorem is logically true but deliberately *not* the nontrivial hardness
bound: it chooses `Ω = ∅`. Use `Classical_Bound_Statement` for the real target.
-/
theorem Classical_Bound_empty_family {n : Type} [Fintype n] {R : Type} [RCLike R] :
  ∃ (Ω : Set (Matrix n n R)), Ω ⊆ LaplacianSpace 1 ∧
  ∀ (A : Classical_Adversary n R),
    success_prob_classical A Ω ≤ (1 / 2) ^ (Fintype.card n) := by
      refine' ⟨ ∅, _, _ ⟩ <;> norm_num;
      unfold success_prob_classical; aesop;

/--
Empty-family quantum sanity check.

This theorem is also vacuous as a hardness result: it chooses `Ω = ∅` and
`C = 0`. Use `Quantum_Bound_Statement` for the intended nonempty-family target.
-/
theorem Quantum_Bound_empty_family {n : Type} [Fintype n] {R : Type} [RCLike R] [DecidableEq n] :
  ∃ (Ω : Set (Matrix n n R)) (C : Real), Ω ⊆ LaplacianSpace 1 ∧
  ∀ (A : Quantum_Adversary n R),
    success_prob_quantum A Ω ≤ (1 / 2) ^ (Fintype.card n) * (1 + C * MinSpectralGap Ω) := by
      refine' ⟨ ∅, 0, _, _ ⟩ <;> norm_num;
      unfold success_prob_quantum; norm_num;
