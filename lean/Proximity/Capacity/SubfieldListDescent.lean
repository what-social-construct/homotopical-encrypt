module

public import Proximity.Core.ReedSolomon
public import Mathlib.Algebra.Polynomial.OfFn
public import Mathlib.LinearAlgebra.Basis.Defs

@[expose] public section

/-!
# List balls under scalar extension

Extending the coefficient field while keeping the evaluation points in the
base field is the same as increasing the interleaving width. Expanding each
symbol in a finite basis preserves the entire Hamming list ball.
-/

set_option autoImplicit false

namespace ProximityCoding.ReedSolomon.Parameters

open BlockCode

variable {F K ι J σ : Type*} [Field F] [Field K] [Algebra F K] [Fintype ι]

/-- Lift the evaluation points to an extension field and keep the degree bound. -/
def extendField (P : Parameters F ι) (K : Type*) [Field K] [Algebra F K] :
    Parameters K ι where
  domain := ⟨fun i => algebraMap F K (P.domain.point i),
    (algebraMap F K).injective.comp P.domain.injective_point⟩
  degreeBound := P.degreeBound

/-- Expand each symbol into its basis coordinates and index them by the old component and
the basis index. -/
noncomputable def coefficientAlphabetEquiv (b : Module.Basis J F K) [Finite J] (σ : Type*) :
    VectorSymbol K σ ≃ VectorSymbol F (σ × J) :=
  (Equiv.piCongrRight fun _ : σ => b.equivFun.toEquiv).trans (Equiv.curry σ J F).symm

/-- Apply the coefficient equivalence independently at each evaluation coordinate. -/
noncomputable def coefficientWordEquiv (b : Module.Basis J F K) [Finite J] (ι σ : Type*) :
    VectorWord ι K σ ≃ VectorWord ι F (σ × J) :=
  Equiv.piCongrRight fun _ : ι => coefficientAlphabetEquiv b σ

private theorem codeword_iff_coefficient_sum {L : Type*} [Field L]
    (P : Parameters L ι) (hk : 0 < P.degreeBound) (w : Word ι L) :
    P.Codeword w ↔ ∃ a : Fin P.degreeBound → L,
      ∀ i : ι, w i = ∑ d : Fin P.degreeBound, a d * P.domain.point i ^ d.val := by
  classical
  constructor
  · rintro ⟨p, hp, hw⟩
    refine ⟨fun d => p.coeff d.val, fun i => ?_⟩
    rw [hw, Polynomial.eval_eq_sum_range' hp]
    exact (Fin.sum_univ_eq_sum_range (fun d : ℕ => p.coeff d * P.domain.point i ^ d)
      P.degreeBound).symm
  · rintro ⟨a, hw⟩
    refine ⟨Polynomial.ofFn _ a, Polynomial.ofFn_natDegree_lt hk a, fun i => ?_⟩
    rw [hw, Polynomial.ofFn_eq_sum_monomial, Polynomial.eval_finsetSum]
    simp only [Polynomial.eval_monomial]

private theorem equivFun_mul_algebraMap_pow (b : Module.Basis J F K) [Finite J]
    (x : F) (a : K) (d : ℕ) (t : J) :
    b.equivFun (a * (algebraMap F K x) ^ d) t = b.equivFun a t * x ^ d := by
  rw [← map_pow, mul_comm a, ← Algebra.smul_def, map_smul]
  exact mul_comm _ _

/-- Coefficient expansion matches the scalar-extended RS code with the corresponding
wider interleaving of the base RS code. -/
theorem codeword_iff_coefficientWordEquiv (P : Parameters F ι)
    (hk : 0 < P.degreeBound) (b : Module.Basis J F K) [Finite J]
    (w : VectorWord ι K σ) :
    ((P.extendField K).vectorBlockCode σ).Codeword w ↔
      (P.vectorBlockCode (σ × J)).Codeword (coefficientWordEquiv b ι σ w) := by
  classical
  change (∀ j : σ, (P.extendField K).Codeword fun i => w i j) ↔
    ∀ jt : σ × J, P.Codeword fun i => b.equivFun (w i jt.1) jt.2
  constructor
  · rintro hw ⟨j, t⟩
    obtain ⟨a, ha⟩ := (codeword_iff_coefficient_sum (P.extendField K) hk _).mp (hw j)
    apply (codeword_iff_coefficient_sum P hk _).mpr
    refine ⟨fun d => b.equivFun (a d) t, fun i => ?_⟩
    change b.equivFun (w i j) t = _
    rw [ha, map_sum]
    simp only [Finset.sum_apply, extendField, equivFun_mul_algebraMap_pow]
    rfl
  · intro hw j
    have h := fun t : J => (codeword_iff_coefficient_sum P hk _).mp (hw (j, t))
    choose a ha using h
    apply (codeword_iff_coefficient_sum (P.extendField K) hk _).mpr
    refine ⟨fun d => b.equivFun.symm (fun t => a t d), fun i => ?_⟩
    apply b.equivFun.injective
    funext t
    change b.equivFun (w i j) t = _
    rw [ha t i, map_sum]
    simp only [Finset.sum_apply, extendField, equivFun_mul_algebraMap_pow,
      LinearEquiv.apply_symm_apply]
    rfl

theorem hammingDistance_coefficientWordEquiv (b : Module.Basis J F K)
    [Fintype J] [Fintype σ] [DecidableEq F] [DecidableEq K]
    (u v : VectorWord ι K σ) :
    hammingDistance (coefficientWordEquiv b ι σ u) (coefficientWordEquiv b ι σ v) =
      hammingDistance u v := by
  classical
  unfold hammingDistance
  congr 1
  ext i
  simp only [Finset.mem_filter, Finset.mem_univ, true_and]
  exact not_congr (coefficientAlphabetEquiv b σ).injective.eq_iff

/-- Extension-field and expanded base-field list balls have equal cardinality. -/
theorem vectorBallCard_extendField (P : Parameters F ι) (hk : 0 < P.degreeBound)
    (b : Module.Basis J F K) [Fintype J] [Fintype σ] [DecidableEq F] [DecidableEq K]
    (r : ℕ) (w : VectorWord ι K σ) :
    ((P.extendField K).vectorBlockCode σ).ballCard r w =
      (P.vectorBlockCode (σ × J)).ballCard r (coefficientWordEquiv b ι σ w) := by
  unfold ballCard
  apply Nat.card_congr ((coefficientWordEquiv b ι σ).subtypeEquiv ?_)
  intro u
  change (((P.extendField K).vectorBlockCode σ).Codeword u ∧ hammingDistance u w ≤ r) ↔
    ((P.vectorBlockCode (σ × J)).Codeword (coefficientWordEquiv b ι σ u) ∧
      hammingDistance (coefficientWordEquiv b ι σ u) (coefficientWordEquiv b ι σ w) ≤ r)
  rw [hammingDistance_coefficientWordEquiv, codeword_iff_coefficientWordEquiv P hk b]

/-- A uniform count-list bound over an extension is equivalent to the same bound after
expanding the interleaving over the base field. -/
theorem vectorListSizeBound_extendField_iff (P : Parameters F ι) (hk : 0 < P.degreeBound)
    (b : Module.Basis J F K) [Fintype J] [Fintype σ] [DecidableEq F] [DecidableEq K]
    (r B : ℕ) :
    ((P.extendField K).vectorBlockCode σ).ListSizeBound r B ↔
      (P.vectorBlockCode (σ × J)).ListSizeBound r B := by
  constructor
  · intro h v
    obtain ⟨w, rfl⟩ := (coefficientWordEquiv b ι σ).surjective v
    rw [← P.vectorBallCard_extendField hk b]
    exact h w
  · intro h w
    rw [P.vectorBallCard_extendField hk b]
    exact h _

end ProximityCoding.ReedSolomon.Parameters
