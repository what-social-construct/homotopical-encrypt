module

public import Proximity.Core.ReedSolomon
public import Mathlib.Data.ZMod.Basic
public import Mathlib.Algebra.Polynomial.Degree.Operations
public import Mathlib.LinearAlgebra.Pi

@[expose] public section

/-!
# Canonical real lifts of affine residue words

Canonical representatives remove modular ambiguity but do not preserve a
proper real-linear code locus. Translates of an injectively indexed residue
word, together with the constant-one real vector, span the entire real
coordinate space. The proof derives each coordinate vector from the actual
wrap at zero; no spanning premise is used.
-/

set_option autoImplicit false

noncomputable section

namespace ProximityCoding
namespace CanonicalLift

open scoped BigOperators

variable {q : ℕ} {ι : Type*}

/-- Coordinatewise canonical lift; for nonzero modulus this is the usual
natural representative, viewed in the real numbers. -/
def lift (word : ι → ZMod q) : ι → ℝ :=
  fun i => ZMod.cast (word i)

theorem lift_apply [NeZero q] (word : ι → ZMod q) (i : ι) :
    lift word i = ((word i).val : ℝ) := by
  exact ZMod.cast_eq_val _

/-- The wrap identity at one selected evaluation point produces its scalar
coordinate vector from two affine translates and the constant word. -/
theorem wrap_coordinate_identity [DecidableEq ι]
    (x : ι → ZMod q) (hx : Function.Injective x) (i : ι) :
    (fun _ : ι => (1 : ℝ)) - lift (fun j => x j - x i) +
      lift (fun j => x j - x i - 1) =
      (q : ℝ) • Pi.single i (1 : ℝ) := by
  classical
  ext j
  by_cases hji : j = i
  · subst j
    simp only [Pi.sub_apply, Pi.add_apply, lift, sub_self,
      ZMod.cast_zero, sub_zero, zero_sub, Pi.smul_apply, Pi.single_eq_same,
      smul_eq_mul, mul_one]
    rw [ZMod.cast_neg_one]
    ring
  · have hz : x j - x i ≠ 0 := sub_ne_zero.mpr (fun h => hji (hx h))
    simp [lift, ZMod.cast_sub_one, hz, hji]

/-- Canonical affine translates cannot all lie in a proper real subspace.
The modulus need only be nonzero; the RS application below uses a field. -/
theorem eq_top_of_contains_affine_lifts [Fintype ι]
    (hq : q ≠ 0) (x : ι → ZMod q) (hx : Function.Injective x)
    (W : Submodule ℝ (ι → ℝ))
    (hone : (fun _ : ι => (1 : ℝ)) ∈ W)
    (haffine : ∀ a : ZMod q, lift (fun j => x j + a) ∈ W) :
    W = ⊤ := by
  classical
  have hqR : (q : ℝ) ≠ 0 := by exact_mod_cast hq
  have hsingle : ∀ i : ι, Pi.single i (1 : ℝ) ∈ W := by
    intro i
    have hv : lift (fun j => x j - x i) ∈ W := by
      simpa only [sub_eq_add_neg] using haffine (-x i)
    have hu : lift (fun j => x j - x i - 1) ∈ W := by
      simpa only [sub_eq_add_neg, add_assoc] using haffine (-x i + -1)
    have hscaled : (q : ℝ) • Pi.single i (1 : ℝ) ∈ W := by
      rw [← wrap_coordinate_identity x hx i]
      exact W.add_mem (W.sub_mem hone hv) hu
    have hcancel := W.smul_mem (q : ℝ)⁻¹ hscaled
    simpa only [smul_smul, inv_mul_cancel₀ hqR, one_smul] using hcancel
  apply Submodule.eq_top_iff'.mpr
  intro z
  rw [← Finset.univ_sum_single z]
  apply W.sum_mem
  intro i _
  have h := W.smul_mem (z i) (hsingle i)
  simpa only [← Pi.single_smul, smul_eq_mul, mul_one] using h

/-- Every canonical lift of an RS codeword being real-linearly valid forces
the real validity subspace to be all of the coordinate space when `k ≥ 2`. -/
theorem eq_top_of_contains_rs_lifts [Fintype ι] [Fact q.Prime]
    (P : ReedSolomon.Parameters (ZMod q) ι) (hk : 2 ≤ P.degreeBound)
    (W : Submodule ℝ (ι → ℝ))
    (hcode : ∀ word, P.Codeword word → lift word ∈ W) :
    W = ⊤ := by
  have hprime : q.Prime := Fact.out
  have hq : 1 < q := hprime.one_lt
  apply eq_top_of_contains_affine_lifts hprime.ne_zero
    P.domain.point P.domain.injective_point W
  · have hc : P.Codeword (fun _ => 1) := by
      refine ⟨Polynomial.C 1, ?_, ?_⟩
      · simp only [Polynomial.natDegree_C]
        omega
      · intro i
        simp
    have heq : lift (fun _ : ι => (1 : ZMod q)) = fun _ : ι => (1 : ℝ) := by
      funext i
      rw [lift_apply, ZMod.val_one'' (ne_of_gt hq), Nat.cast_one]
    rw [← heq]
    exact hcode _ hc
  · intro a
    apply hcode
    refine ⟨Polynomial.X + Polynomial.C a, ?_, ?_⟩
    · rw [Polynomial.natDegree_X_add_C]
      omega
    · intro i
      simp

/-- Canonical representatives of every scalar coordinate of a vector word. -/
def interleavedLift {σ : Type*} (word : ι → σ → ZMod q) : ι → σ → ℝ :=
  fun i j => ZMod.cast (word i j)

private def columnMap {σ : Type*} [DecidableEq σ] (j : σ) :
    (ι → ℝ) →ₗ[ℝ] (ι → σ → ℝ) where
  toFun v i k := if k = j then v i else 0
  map_add' u v := by ext i k; by_cases h : k = j <;> simp [h]
  map_smul' a v := by ext i k; by_cases h : k = j <;> simp [h]

/-- The full interleaved RS code has the same obstruction. In particular this
applies to the actual two-coordinate paper pair, without treating it as an RS
word on a larger evaluation domain. -/
theorem eq_top_of_contains_interleaved_rs_lifts
    [Fintype ι] [Fact q.Prime] {σ : Type*} [Fintype σ]
    (P : ReedSolomon.Parameters (ZMod q) ι) (hk : 2 ≤ P.degreeBound)
    (W : Submodule ℝ (ι → σ → ℝ))
    (hcode : ∀ word, (P.vectorBlockCode σ).Codeword word →
      interleavedLift word ∈ W) : W = ⊤ := by
  classical
  have hzero : P.Codeword (fun _ => 0) := by
    refine ⟨0, ?_, ?_⟩
    · simp only [Polynomial.natDegree_zero]
      omega
    · intro i
      simp
  have hcolumn : ∀ (j : σ) (v : ι → ℝ), columnMap j v ∈ W := by
    intro j
    let U := W.comap (columnMap (ι := ι) j)
    have hU : U = ⊤ := eq_top_of_contains_rs_lifts P hk U (by
      intro word hword
      let vectorWord : ι → σ → ZMod q := fun i k => if k = j then word i else 0
      have hvector : (P.vectorBlockCode σ).Codeword vectorWord := by
        change ∀ k : σ, P.Codeword (fun i => vectorWord i k)
        intro k
        by_cases hkj : k = j
        · simpa only [vectorWord, ite_eq_left hkj] using hword
        · simpa only [vectorWord, ite_eq_right hkj] using hzero
      have heq : interleavedLift vectorWord = columnMap j (lift word) := by
        ext i k
        by_cases hkj : k = j <;> simp [interleavedLift, vectorWord, columnMap, lift, hkj]
      change columnMap j (lift word) ∈ W
      rw [← heq]
      exact hcode vectorWord hvector)
    intro v
    have hv : v ∈ U := by rw [hU]; trivial
    exact hv
  apply Submodule.eq_top_iff'.mpr
  intro z
  have hz : z = ∑ j : σ, columnMap j (fun i => z i j) := by
    ext i k
    simp [columnMap]
  rw [hz]
  exact W.sum_mem (fun j _ => hcolumn j _)

end CanonicalLift
end ProximityCoding
