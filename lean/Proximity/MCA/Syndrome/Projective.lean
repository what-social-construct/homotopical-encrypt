module

public import Proximity.MCA.Syndrome
public import Mathlib.LinearAlgebra.Projectivization.Basic
public import Mathlib.LinearAlgebra.FiniteDimensional.Lemmas
public import Mathlib.LinearAlgebra.Quotient.Basic

@[expose] public section

/-!
# Projective incidences in the same-set MCA experiment

An injective syndrome pencil presents a projective line. A support witnesses
failure precisely when it meets that line in the tested affine point.
The submodule intersections distinguish different hits even when several
supports produce the same point.
-/

set_option autoImplicit false

namespace ProximityCoding.BlockCode.Syndrome

variable {F V : Type*} [Field F] [AddCommGroup V] [Module F V]

/-- The linear map from homogeneous challenge coordinates to syndromes. -/
def pencil (s₀ s₁ : V) : (F × F) →ₗ[F] V :=
  (LinearMap.fst F F F).smulRight s₀ + (LinearMap.snd F F F).smulRight s₁

@[simp]
theorem pencil_apply (s₀ s₁ : V) (v : F × F) :
    pencil (F := F) s₀ s₁ v = v.1 • s₀ + v.2 • s₁ := rfl

theorem pencil_range_le_iff (s₀ s₁ : V) (U : Submodule F V) :
    (pencil s₀ s₁).range ≤ U ↔ s₀ ∈ U ∧ s₁ ∈ U := by
  constructor
  · intro h
    exact ⟨h ⟨(1, 0), by simp⟩, h ⟨(0, 1), by simp⟩⟩
  · rintro ⟨h₀, h₁⟩ _ ⟨v, rfl⟩
    exact U.add_mem (U.smul_mem _ h₀) (U.smul_mem _ h₁)

variable (M : (F × F) →ₗ[F] V)

/-- An affine parameter gives a nonzero vector on an injective pencil. -/
theorem affineRepresentative_ne_zero (injective : Function.Injective M) (γ : F) :
    M (1, γ) ≠ 0 := by
  intro h
  have coordinates : ((1, γ) : F × F) = 0 := injective (h.trans M.map_zero.symm)
  exact one_ne_zero (congrArg Prod.fst coordinates)

/-- The affine challenge chart `[1 : γ]` on the syndrome line. -/
def affinePoint (injective : Function.Injective M) (γ : F) : Projectivization F V :=
  Projectivization.mk F (M (1, γ)) (affineRepresentative_ne_zero M injective γ)

private theorem same_parameter_of_smul (injective : Function.Injective M) {a γ η : F}
    (h : a • M (1, η) = M (1, γ)) : γ = η := by
  have coordinates : a • ((1, η) : F × F) = (1, γ) :=
    injective ((M.map_smul a (1, η)).trans h)
  have one : a = 1 := by simpa using congrArg Prod.fst coordinates
  simpa [one] using (congrArg Prod.snd coordinates).symm

/-- Counting affine projective points counts distinct challenges. -/
theorem affinePoint_injective (injective : Function.Injective M) :
    Function.Injective (affinePoint M injective) := by
  intro γ η h
  obtain ⟨a, ha⟩ := (Projectivization.mk_eq_mk_iff' F _ _
    (affineRepresentative_ne_zero M injective γ)
    (affineRepresentative_ne_zero M injective η)).mp h
  exact same_parameter_of_smul M injective ha

/-- The omitted direction at infinity is distinct from every affine challenge. -/
theorem affinePoint_ne_infinity (injective : Function.Injective M)
    (γ : F) (nonzero : M (0, 1) ≠ 0) :
    affinePoint M injective γ ≠ Projectivization.mk F (M (0, 1)) nonzero := by
  intro h
  obtain ⟨a, ha⟩ := (Projectivization.mk_eq_mk_iff' F _ _
    (affineRepresentative_ne_zero M injective γ) nonzero).mp h
  have coordinates : a • ((0, 1) : F × F) = (1, γ) :=
    injective ((M.map_smul a (0, 1)).trans ha)
  have impossible : (0 : F) = 1 := by simpa using congrArg Prod.fst coordinates
  exact zero_ne_one impossible

/-- The range of the injective homogeneous pencil is a two-dimensional plane. -/
theorem finrank_pencil_range (injective : Function.Injective M) :
    Module.finrank F M.range = 2 := by
  rw [LinearMap.finrank_range_of_inj injective, Module.finrank_prod, Module.finrank_self]

/-- A single-point hit is exactly a tested point in the support subspace,
with the whole projective line excluded from that subspace. -/
theorem intersection_eq_affinePoint_iff (injective : Function.Injective M)
    (U : Submodule F V) (γ : F) :
    M.range ⊓ U = (affinePoint M injective γ).submodule ↔
      M (1, γ) ∈ U ∧ ¬ M.range ≤ U := by
  have rank := finrank_pencil_range M injective
  have rankPoint := Projectivization.finrank_submodule (affinePoint M injective γ)
  have spanPoint : (affinePoint M injective γ).submodule =
      Submodule.span F {M (1, γ)} := rfl
  constructor
  · intro h
    have hp : M (1, γ) ∈ (affinePoint M injective γ).submodule := by
      rw [spanPoint]
      exact Submodule.mem_span_singleton_self _
    rw [← h] at hp
    refine ⟨hp.2, ?_⟩
    intro contained
    rw [inf_eq_left.mpr contained] at h
    rw [← h, rank] at rankPoint
    omega
  · rintro ⟨hit, proper⟩
    have span_le : (affinePoint M injective γ).submodule ≤ M.range ⊓ U := by
      rw [spanPoint, Submodule.span_singleton_le_iff_mem]
      exact ⟨⟨(1, γ), rfl⟩, hit⟩
    have meet_lt : M.range ⊓ U < M.range :=
      lt_of_le_of_ne inf_le_left (fun h => proper (inf_eq_left.mp h))
    have meet_rank := Submodule.finrank_lt_finrank_of_lt meet_lt
    apply (Submodule.eq_of_le_of_finrank_le span_le _).symm
    omega

/-- Two single-point hits differ exactly when the plane misses the common
syndrome subspace in projective space. -/
theorem disjoint_common_support_iff
    (injective : Function.Injective M)
    {U U' : Submodule F V} {γ η : F}
    (hit : M.range ⊓ U = (affinePoint M injective γ).submodule)
    (hit' : M.range ⊓ U' = (affinePoint M injective η).submodule) :
    Disjoint M.range (U ⊓ U') ↔ γ ≠ η := by
  have meet : (M.range ⊓ U) ⊓ (M.range ⊓ U') = M.range ⊓ (U ⊓ U') := by
    rw [inf_inf_inf_comm, inf_idem]
  calc
    Disjoint M.range (U ⊓ U') ↔ Disjoint (M.range ⊓ U) (M.range ⊓ U') := by
      simp only [disjoint_iff, meet]
    _ ↔ γ ≠ η := by
      rw [hit, hit']
      change Disjoint (Submodule.span F {M (1, γ)}) (Submodule.span F {M (1, η)}) ↔ _
      rw [Submodule.disjoint_span_singleton' (affineRepresentative_ne_zero M injective η),
        Submodule.mem_span_singleton]
      apply not_congr
      constructor
      · rintro ⟨a, ha⟩
        exact (same_parameter_of_smul M injective ha).symm
      · rintro rfl
        exact ⟨1, one_smul _ _⟩

section MCA

variable {ι : Type*}

/-- An additive scalar code gives the submodule used in the syndrome quotient. -/
def codeSubmodule (C : FAdditiveCode F ι F) : Submodule F (ι → F) where
  carrier := {w | C.Codeword w}
  zero_mem' := C.zero_mem
  add_mem' := C.add_mem
  smul_mem' := C.smul_mem

/-- The quotient by the code is a canonical choice of parity check. -/
theorem quotient_zero_iff (C : FAdditiveCode F ι F) (w : Word ι F) :
    (codeSubmodule C).mkQ w = 0 ↔ C.Codeword w :=
  Submodule.Quotient.mk_eq_zero (codeSubmodule C)

variable [Fintype ι] [DecidableEq ι] [Fintype F]
variable (C : BlockCode ι F) (H : (ι → F) →ₗ[F] V)

/-- The exact projective criterion for the existing MCA bad-challenge set. -/
theorem mem_badChallengeSet_iff_projective
    (hker : ∀ w : Word ι F, H w = 0 ↔ C.Codeword w)
    (r : ℕ) (L : AffineLine ι F)
    (injective : Function.Injective (pencil (F := F) (H L.base) (H L.direction)))
    (γ : F) :
    γ ∈ C.badChallengeSet r L ↔
      ∃ E : Finset ι, E.card ≤ r ∧
        (pencil (H L.base) (H L.direction)).range ⊓ errorSyndromes H E =
          (affinePoint (pencil (H L.base) (H L.direction)) injective γ).submodule := by
  rw [mem_badChallengeSet_iff C H hker r L γ]
  apply exists_congr
  intro E
  rw [intersection_eq_affinePoint_iff, pencil_range_le_iff, pencil_apply, one_smul]

/-- Dependent syndrome columns contribute at most one affine bad challenge. -/
theorem badChallengeSet_card_le_one_of_dependent
    (hker : ∀ w : Word ι F, H w = 0 ↔ C.Codeword w)
    (r : ℕ) (L : AffineLine ι F)
    (dependent : H L.direction = 0 ∨ ∃ a : F, H L.base = a • H L.direction) :
    (C.badChallengeSet r L).card ≤ 1 := by
  classical
  rw [Finset.card_le_one_iff]
  intro γ η hγ hη
  rcases dependent with zero | ⟨a, multiple⟩
  · obtain ⟨E, _, hit, proper⟩ := (mem_badChallengeSet_iff C H hker r L γ).mp hγ
    simp only [zero, smul_zero, add_zero] at hit
    exact False.elim (proper ⟨hit, zero.symm ▸ (errorSyndromes H E).zero_mem⟩)
  · have cancellation (b : F) (hb : b ∈ C.badChallengeSet r L) : b = -a := by
      obtain ⟨E, _, hit, proper⟩ := (mem_badChallengeSet_iff C H hker r L b).mp hb
      rw [multiple, ← add_smul] at hit
      by_contra hne
      have nonzero : a + b ≠ 0 := fun h => hne (eq_neg_of_add_eq_zero_right h)
      have direction := ((errorSyndromes H E).smul_mem_iff nonzero).mp hit
      exact proper ⟨multiple.symm ▸ (errorSyndromes H E).smul_mem a direction, direction⟩
    exact (cancellation γ hγ).trans (cancellation η hη).symm

end MCA

end ProximityCoding.BlockCode.Syndrome
