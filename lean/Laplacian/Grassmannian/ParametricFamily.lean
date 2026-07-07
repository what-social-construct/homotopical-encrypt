import Laplacian.Grassmannian.SearchSpace

/-
  Parametric Grassmannian families.

  Paper correspondence:
  - Paper 1 Sections 2--3: families of hidden harmonic subspaces compatible
    with public data.

  This file builds the t ↦ span{u + t v} ⊕ W₀ family used to expose a
  continuum of candidate harmonic subspaces. It depends only on the search
  space file for the finite-dimensional existence lemma.
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

open Matrix Real InnerProductSpace MeasureTheory

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- Existence of linearly independent u, v and a (k-1)-dimensional subspace W
    disjoint from span{u, v}. Used to construct the parameterized family W(t). -/
lemma exists_vectors_and_subspace (k : ℕ) (h1 : 1 ≤ k) (h2 : k < Fintype.card n) :
  ∃ u v : EuclideanSpace ℝ n, ∃ W : Submodule ℝ (EuclideanSpace ℝ n),
    LinearIndependent ℝ ![u, v] ∧
    Module.finrank ℝ W = k - 1 ∧
    Disjoint (Submodule.span ℝ (Set.range ![u, v])) W := by
      obtain ⟨W, hW⟩ : ∃ W : Submodule ℝ (EuclideanSpace ℝ n), Module.finrank ℝ W = k - 1 ∧ W ≠ ⊤ := by
        obtain ⟨W, hW⟩ : ∃ W : Submodule ℝ (EuclideanSpace ℝ n), Module.finrank ℝ W = k - 1 := by
          apply exists_subspace_dim_k; exact Nat.sub_le_of_le_add (by linarith);
        refine' ⟨ W, hW, _ ⟩;
        contrapose! h2; aesop;
      obtain ⟨u, hu⟩ : ∃ u : EuclideanSpace ℝ n, u ∉ W := by
        exact not_forall.mp fun h => hW.2 <| eq_top_iff.mpr fun x _ => h x;
      obtain ⟨v, hv⟩ : ∃ v : EuclideanSpace ℝ n, v ∉ W ⊔ Submodule.span ℝ {u} := by
        by_cases h_top : W ⊔ Submodule.span ℝ {u} = ⊤;
        · have := Submodule.finrank_sup_add_finrank_inf_eq W ( Submodule.span ℝ { u } );
          rw [ h_top, finrank_top ] at this;
          rw [ finrank_span_singleton ] at this <;> aesop;
        · exact not_forall.mp fun h => h_top <| eq_top_iff.mpr fun x _ => h x;
      refine' ⟨ u, v, W, _, _, _ ⟩ <;> simp_all +decide [ Submodule.disjoint_def ];
      · rw [ linearIndependent_fin2 ];
        refine' ⟨ _, _ ⟩ <;> contrapose! hv <;> simp_all +decide [ Submodule.mem_sup, Submodule.mem_span_singleton ];
        rcases hv with ⟨ a, rfl ⟩ ; exact ⟨ 0, W.zero_mem, a⁻¹, by simp +decide [ show a ≠ 0 by aesop ] ⟩ ;
      · intro x hx hxW; contrapose! hv; simp_all +decide [ Submodule.mem_sup, Submodule.mem_span_pair ] ;
        obtain ⟨ a, b, rfl ⟩ := hx;
        by_cases ha : a = 0;
        · simp_all +decide [ Submodule.mem_span_singleton ];
          exact False.elim ( hu ( by simpa [ hv.1 ] using W.smul_mem ( b⁻¹ ) hxW ) );
        · refine' ⟨ a⁻¹ • ( a • v + b • u ), _, -a⁻¹ • b • u, _, _ ⟩ <;> simp_all +decide [ Submodule.smul_mem ];
          convert W.smul_mem ( a⁻¹ ) hxW using 1 ; simp +decide [ ha, smul_smul ]

/-- Construction of a family of k-dimensional subspaces parameterized by t ∈ ℝ:
    W(t) = span{u + t·v} ⊕ W₀
    This gives an injection ℝ ↪ Gr(k,n), proving Ω_k is uncountably infinite. -/
def subspace_construction
    (u v : EuclideanSpace ℝ n)
    (W : Submodule ℝ (EuclideanSpace ℝ n))
    (t : ℝ) :
    Submodule ℝ (EuclideanSpace ℝ n) :=
  Submodule.span ℝ {u + t • v} ⊔ W

/-- The constructed subspace W(t) has dimension k. -/
lemma subspace_construction_dim
    (k : ℕ)
    (h1 : 1 ≤ k)
    (u v : EuclideanSpace ℝ n)
    (W : Submodule ℝ (EuclideanSpace ℝ n))
    (h_indep : LinearIndependent ℝ ![u, v])
    (h_dim_W : Module.finrank ℝ W = k - 1)
    (h_disj : Disjoint (Submodule.span ℝ (Set.range ![u, v])) W)
    (t : ℝ) :
    Module.finrank ℝ (subspace_construction u v W t) = k := by
    have h_dim_sum : Module.finrank ℝ (↥(Submodule.span ℝ {u + t • v} ⊔ W)) = Module.finrank ℝ (↥(Submodule.span ℝ {u + t • v})) + Module.finrank ℝ (↥W) := by
      rw [ ← Submodule.finrank_sup_add_finrank_inf_eq ];
      simp +zetaDelta at *;
      refine' eq_bot_iff.mpr fun x hx => _;
      simp_all +decide [ Submodule.disjoint_def, Submodule.mem_span_singleton ];
      rcases hx with ⟨ ⟨ a, rfl ⟩, hx ⟩;
      convert h_disj _ _ hx using 1;
      exact Submodule.mem_span_pair.mpr ⟨ a * t, a, by ext; simp +decide ; ring ⟩;
    by_cases hu : u + t • v = 0 <;> simp_all +decide;
    · have := Fintype.linearIndependent_iff.mp h_indep;
      specialize this ( fun i => if i = 0 then 1 else t ) ; simp_all +decide [ Fin.forall_fin_two ];
    · convert h_dim_sum using 1;
      rw [ finrank_span_singleton ] <;> aesop

/-- The subspace construction t ↦ W(t) is injective.
    CONSEQUENCE: Ω_k contains uncountably many distinct Laplacians.
    This is the key hardness lemma — the adversary's search space is not enumerable. -/
lemma subspace_construction_injective
    (u v : EuclideanSpace ℝ n)
    (W : Submodule ℝ (EuclideanSpace ℝ n))
    (h_indep : LinearIndependent ℝ ![u, v])
    (h_disj : Disjoint (Submodule.span ℝ (Set.range ![u, v])) W) :
    Function.Injective (subspace_construction u v W) := by
    intro t1 t2 h_eq;
    have h_t_eq : u + t1 • v ∈ Submodule.span ℝ {u + t2 • v} ⊔ W := by
      unfold subspace_construction at h_eq;
      exact h_eq ▸ Submodule.mem_sup_left ( Submodule.subset_span ( Set.mem_singleton _ ) );
    rw [ Submodule.mem_sup ] at h_t_eq;
    obtain ⟨y, hy, z, hz, h_eq⟩ := h_t_eq
    have hz_zero : z = 0 := by
      have hz_zero : z ∈ Submodule.span ℝ (Set.range ![u, v]) := by
        rw [ Submodule.mem_span_singleton ] at hy;
        obtain ⟨ a, rfl ⟩ := hy;
        rw [ show z = ( 1 - a ) • u + ( t1 - a * t2 ) • v by ext x; have := congr_fun h_eq x; norm_num at *; linarith ];
        exact Submodule.add_mem _ ( Submodule.smul_mem _ _ ( Submodule.subset_span ( Set.mem_range_self 0 ) ) ) ( Submodule.smul_mem _ _ ( Submodule.subset_span ( Set.mem_range_self 1 ) ) );
      exact h_disj.le_bot ⟨ hz_zero, hz ⟩;
    rw [ Submodule.mem_span_singleton ] at hy;
    rw [ Fintype.linearIndependent_iff ] at h_indep;
    specialize h_indep ( fun i => if i = 0 then hy.choose - 1 else hy.choose * t2 - t1 ) ; simp_all +decide [ Fin.forall_fin_two, sub_eq_iff_eq_add ];
    have := hy.choose_spec; simp_all +decide [ ← eq_sub_iff_add_eq', smul_smul ] ;
    have := h_indep ( by ext x; have := congr_fun this x; norm_num at *; linarith ) ; aesop;

end
