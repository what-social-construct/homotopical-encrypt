module

public import Sheaf.HCPFiniteKeyFamily

@[expose] public section

/-!
# Harmonic geometry of the finite keyed cellular family

The keyed sheaves share a degree-one Euclidean carrier. Their harmonic spaces
have explicit coordinate descriptions and independent integral unit frames.
The key-to-subspace map is injective. These are sheaf-level facts independent
of any Grassmannian or projective disclosure representation.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Sheaf.HCPFiniteKeyGeometry

open HomotopicalEncryption.Sheaf
open HomotopicalEncryption.Sheaf.HCPFiniteKeyFamily
open CellularSheaf

variable (n : ℕ)

/-- The operative harmonic subspace in the common `4n`-coordinate carrier. -/
def harmonicSubspace (key : Key n) : Submodule ℝ (C1 n) :=
  (sheaf n key).harmonicOneSubspace

/-- Harmonic vectors vanish on exact edges and on the selected face coordinate
of each Hodge edge. -/
theorem mem_harmonicSubspace_iff (key : Key n) (b : C1 n) :
    b ∈ harmonicSubspace n key ↔
      (∀ (i : Fin n) (j : Fin 2), b ⟨(i, 0), j⟩ = 0) ∧
      (∀ i : Fin n, b ⟨(i, 1), key i⟩ = 0) := by
  change (sheaf n key).degreeOneLaplacian b = 0 ↔ _
  rw [(sheaf n key).degreeOneLaplacian_apply_eq_zero_iff b]
  constructor
  · rintro ⟨h0, h1⟩
    constructor
    · intro i j
      have hcoord := congrArg
        (fun a : (sheaf n key).C0 => a ⟨i, j⟩) h0
      simpa [delta0_adjoint_eq] using hcoord
    · intro i
      have hcoord := congrArg
        (fun c : (sheaf n key).C2 => c ⟨i, 0⟩) h1
      simpa [delta1_apply] using hcoord
  · rintro ⟨h0, h1⟩
    constructor
    · rw [delta0_adjoint_eq]
      apply PiLp.ext
      rintro ⟨i, j⟩
      exact h0 i j
    · apply PiLp.ext
      rintro ⟨i, j⟩
      have hj : j = 0 := Subsingleton.elim _ _
      subst j
      simpa only [delta1_apply, PiLp.zero_apply] using h1 i

/-- The complementary coordinate units have pairwise distinct supports. -/
theorem harmonicUnit_linearIndependent (key : Key n) :
    LinearIndependent ℝ (harmonicUnit n key) := by
  have hindex : Function.Injective
      (fun i : Fin n =>
        (⟨(i, 1), HCPAxisFamily.other (key i)⟩ : Index n)) := by
    intro i j h
    exact congrArg (fun p : Index n => p.1.1) h
  have hfull : LinearIndependent ℝ
      (fun p : Index n => (EuclideanSpace.single p (1 : ℝ) : C1 n)) := by
    simpa only [EuclideanSpace.single] using
      (PiLp.linearIndependent_single_one (p := 2) (𝕜 := ℝ) (ι := Index n))
  change LinearIndependent ℝ
    (fun i : Fin n =>
      (EuclideanSpace.single
        ⟨(i, 1), HCPAxisFamily.other (key i)⟩ (1 : ℝ) : C1 n))
  exact hfull.comp _ hindex

private theorem sum_harmonicUnit_apply (key : Key n) (b : C1 n)
    (i : Fin n) (k j : Fin 2) :
    (∑ t : Fin n,
      b ⟨(t, 1), HCPAxisFamily.other (key t)⟩ • harmonicUnit n key t)
        ⟨(i, k), j⟩ =
      if k = 1 ∧ j = HCPAxisFamily.other (key i) then
        b ⟨(i, 1), HCPAxisFamily.other (key i)⟩ else 0 := by
  classical
  by_cases hk : k = 1
  · subst k
    by_cases hj : j = HCPAxisFamily.other (key i)
    · subst j
      simp [harmonicUnit, Pi.single_apply, Sigma.mk.injEq, Prod.mk.injEq]
      have hcond (x : Fin n) :
          (i = x ∧ HCPAxisFamily.other (key i) =
            HCPAxisFamily.other (key x)) ↔ x = i := by
        constructor
        · exact fun hx => hx.1.symm
        · intro hx
          subst x
          simp
      simp_rw [hcond]
      simp
    · simp [harmonicUnit, Pi.single_apply, Sigma.mk.injEq, Prod.mk.injEq, hj]
      have hcond (x : Fin n) :
          ¬(i = x ∧ j = HCPAxisFamily.other (key x)) := by
        rintro ⟨rfl, hx⟩
        exact hj hx
      simp [hcond]
  · simp [harmonicUnit, Sigma.mk.injEq, Prod.mk.injEq, hk]

/-- The actual sheaf harmonic space is spanned by the unused coordinate in
each keyed Hodge edge. -/
theorem harmonicSubspace_eq_span_harmonicUnit (key : Key n) :
    harmonicSubspace n key =
      Submodule.span ℝ (Set.range (harmonicUnit n key)) := by
  apply le_antisymm
  · intro b hb
    obtain ⟨h0, h1⟩ := (mem_harmonicSubspace_iff n key b).mp hb
    have hsum : b = ∑ t : Fin n,
        b ⟨(t, 1), HCPAxisFamily.other (key t)⟩ • harmonicUnit n key t := by
      apply PiLp.ext
      rintro ⟨⟨i, k⟩, j⟩
      rw [sum_harmonicUnit_apply]
      have htwo : ∀ x : Fin 2, x = 0 ∨ x = 1 := by decide
      rcases htwo k with hk | hk
      · subst k
        simp [h0 i j]
      · subst k
        by_cases hj : j = HCPAxisFamily.other (key i)
        · subst j
          simp
        · have hsel : j = key i := by
            have htwo' : ∀ a b : Fin 2,
                b ≠ HCPAxisFamily.other a → b = a := by decide
            exact htwo' (key i) j hj
          subst j
          simp [h1 i, (HCPAxisFamily.other_ne (key i)).symm]
    rw [hsum]
    apply Submodule.sum_mem
    intro i _
    exact Submodule.smul_mem _ _ (Submodule.subset_span ⟨i, rfl⟩)
  · apply Submodule.span_le.mpr
    rintro _ ⟨i, rfl⟩
    exact LinearMap.mem_ker.mpr (harmonicUnit_harmonic n key i)

/-- A harmonic coordinate unit for one key cannot be harmonic for a key that
selects the opposite face coordinate in that block. -/
theorem harmonicUnit_not_mem_of_key_ne
    (key otherKey : Key n) (i : Fin n) (h : key i ≠ otherKey i) :
    harmonicUnit n key i ∉ harmonicSubspace n otherKey := by
  intro hmem
  have hclosed : (sheaf n otherKey).delta1 (harmonicUnit n key i) = 0 :=
    (((sheaf n otherKey).degreeOneLaplacian_apply_eq_zero_iff _).mp
      (LinearMap.mem_ker.mp hmem)).2
  have hcoord := congrArg
    (fun b : (sheaf n otherKey).C2 => b ⟨i, 0⟩) hclosed
  rw [delta1_apply] at hcoord
  have hcomp : otherKey i = HCPAxisFamily.other (key i) := by
    have htwo : ∀ a b : Fin 2,
        a ≠ b → b = HCPAxisFamily.other a := by decide
    exact htwo (key i) (otherKey i) h
  have hunit : harmonicUnit n key i ⟨(i, 1), otherKey i⟩ = 1 := by
    simp [harmonicUnit, hcomp, PiLp.single_apply]
  rw [hunit] at hcoord
  simp at hcoord

/-- Different binary keys determine different actual harmonic subspaces. -/
theorem harmonicSubspace_injective :
    Function.Injective (harmonicSubspace n) := by
  intro key otherKey hsub
  funext i
  by_contra h
  have hmem : harmonicUnit n key i ∈ harmonicSubspace n otherKey := by
    rw [← hsub]
    exact LinearMap.mem_ker.mpr (harmonicUnit_harmonic n key i)
  exact harmonicUnit_not_mem_of_key_ne n key otherKey i h hmem

end HomotopicalEncryption.Sheaf.HCPFiniteKeyGeometry
