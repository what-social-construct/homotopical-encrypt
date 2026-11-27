module

public import Proximity.MCA.Syndrome.Seventeen

@[expose] public section

/-!
# Four matching hits after adjoining a square root of eleven

Lift the original parity-check columns to a characteristic-seventeen field.
For either root of the chart equation, the explicit pencil below meets each
of the original four support spans at a different affine point.
-/

set_option autoImplicit false

namespace ProximityCoding.MCA.Syndrome.Seventeen

open BlockCode.Syndrome
open scoped Matrix

local instance : Fact (Nat.Prime 17) := ⟨prime17⟩

variable (K : Type*) [Field K] [CharP K 17]

/-- The prime-field embedding into the field of the pencil. -/
def liftSeventeen : ZMod 17 →+* K := ZMod.castHom (dvd_refl 17) K

private def liftVector (v : Fin 4 → ZMod 17) : Fin 4 → K :=
  fun j => liftSeventeen K (v j)

noncomputable def extensionParityCheck : (Fin 8 → K) →ₗ[K] (Fin 4 → K) :=
  (parityMatrix.map (liftSeventeen K)).mulVecLin

private theorem extensionParityCheck_single (i : Fin 8) :
    extensionParityCheck K (Pi.single i 1) = liftVector K (column i) := by
  funext j
  change (∑ k : Fin 8, liftSeventeen K (column k j) * (Pi.single i 1 : Fin 8 → K) k) =
    liftSeventeen K (column i j)
  rw [Finset.sum_eq_single i]
  · simp
  · intro k _ h
    simp [Pi.single_eq_of_ne h]
  · simp

/-- The lift of the syndrome subspace of the original designated support. -/
noncomputable def extensionSupport (i : Fin 4) : Submodule K (Fin 4 → K) :=
  errorSyndromes (extensionParityCheck K) (support i)

private theorem extensionSupport_eq_span (i : Fin 4) :
    extensionSupport K i =
      Submodule.span K {liftVector K (column (supportLeft i)),
        liftVector K (column (supportRight i))} := by
  rw [extensionSupport, errorSyndromes_eq_span]
  congr 1
  ext v
  constructor
  · rintro ⟨j, rfl⟩
    change (extensionParityCheck K) (Pi.single j.val 1) ∈ _
    rw [extensionParityCheck_single]
    have hj : j.val = supportLeft i ∨ j.val = supportRight i := by
      simpa [support] using j.property
    rcases hj with hj | hj <;> simp [hj]
  · intro hv
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hv
    rcases hv with rfl | rfl
    · exact ⟨⟨supportLeft i, by simp [support]⟩, extensionParityCheck_single K _⟩
    · exact ⟨⟨supportRight i, by simp [support]⟩, extensionParityCheck_single K _⟩

private def s0 : Fin 4 → ZMod 17 := ![1, 0, 0, 0]
private def s1 : Fin 4 → ZMod 17 := ![0, 0, 13, 0]
private def t0 : Fin 4 → ZMod 17 := ![0, 13, 0, 0]
private def t1 : Fin 4 → ZMod 17 := ![0, 0, 0, 5]

private def gamma0 : Fin 4 → ZMod 17 := ![7, 6, 10, 11]
private def gamma1 : Fin 4 → ZMod 17 := ![12, 14, 5, 3]
private def left0 : Fin 4 → ZMod 17 := ![11, 10, 6, 7]
private def left1 : Fin 4 → ZMod 17 := ![6, 10, 11, 7]
private def right0 : Fin 4 → ZMod 17 := ![14, 5, 3, 12]
private def right1 : Fin 4 → ZMod 17 := ![5, 14, 12, 3]

private def affineExpr (x : K) (a b : ZMod 17) : K :=
  liftSeventeen K a + x * liftSeventeen K b

/-- The chart base vector `(1,0,13x,0)`. -/
def matchingBase (x : K) : Fin 4 → K := ![1, 0, x * liftSeventeen K 13, 0]

/-- The chart direction `(0,13,0,5x)`. -/
def matchingDirection (x : K) : Fin 4 → K := ![0, liftSeventeen K 13, 0, x * liftSeventeen K 5]

/-- The affine parameter of the hit on the indexed support. -/
def matchingChallenge (x : K) : Fin 4 → K :=
  ![liftSeventeen K 7 + x * liftSeventeen K 12, liftSeventeen K 6 + x * liftSeventeen K 14,
    liftSeventeen K 10 + x * liftSeventeen K 5, liftSeventeen K 11 + x * liftSeventeen K 3]

private theorem base_apply (x : K) (j : Fin 4) :
    matchingBase K x j = affineExpr K x (s0 j) (s1 j) := by
  fin_cases j <;> simp [matchingBase, affineExpr, s0, s1]

private theorem direction_apply (x : K) (j : Fin 4) :
    matchingDirection K x j = affineExpr K x (t0 j) (t1 j) := by
  fin_cases j <;> simp [matchingDirection, affineExpr, t0, t1]

private theorem challenge_apply (x : K) (i : Fin 4) :
    matchingChallenge K x i = affineExpr K x (gamma0 i) (gamma1 i) := by
  fin_cases i <;> rfl

private theorem lift_nonzero {a : ZMod 17} (h : a ≠ 0) : liftSeventeen K a ≠ 0 := by
  intro hz
  exact h ((liftSeventeen K).injective (hz.trans (map_zero (liftSeventeen K)).symm))

theorem matchingPencil_injective (x : K) :
    Function.Injective (pencil (F := K) (matchingBase K x) (matchingDirection K x)) := by
  intro u v huv
  have h0 := congrFun huv (0 : Fin 4)
  have h1 := congrFun huv (1 : Fin 4)
  simp [pencil_apply, matchingBase, matchingDirection, smul_eq_mul] at h0 h1
  refine Prod.ext h0 (h1.resolve_right ?_)
  simpa using lift_nonzero K (by decide : (13 : ZMod 17) ≠ 0)

private theorem checked_constant (i j : Fin 4) :
    s0 j + gamma0 i * t0 j + gamma1 i * t1 j * 11 =
      left0 i * column (supportLeft i) j + right0 i * column (supportRight i) j := by
  revert i j
  decide

private theorem checked_slope (i j : Fin 4) :
    s1 j + gamma0 i * t1 j + gamma1 i * t0 j =
      left1 i * column (supportLeft i) j + right1 i * column (supportRight i) j := by
  revert i j
  decide

private theorem hit_mem (x : K) (hx : x ^ 2 = liftSeventeen K 11) (i : Fin 4) :
    pencil (F := K) (matchingBase K x) (matchingDirection K x)
      (1, matchingChallenge K x i) ∈ extensionSupport K i := by
  rw [extensionSupport_eq_span, Submodule.mem_span_pair]
  refine ⟨affineExpr K x (left0 i) (left1 i), affineExpr K x (right0 i) (right1 i), ?_⟩
  funext j
  simp only [pencil_apply, one_smul, base_apply, challenge_apply, direction_apply,
    affineExpr, liftVector, Pi.smul_apply, Pi.add_apply, smul_eq_mul]
  have hc := congrArg (liftSeventeen K) (checked_constant i j)
  have hs := congrArg (liftSeventeen K) (checked_slope i j)
  simp only [map_add, map_mul] at hc hs
  linear_combination -hc - x * hs - liftSeventeen K (gamma1 i) * liftSeventeen K (t1 j) * hx

private def extendedRow (i : Fin 4) : (Fin 4 → K) →ₗ[K] K :=
  liftSeventeen K (firstEndpoint i * secondEndpoint i) • LinearMap.proj 0 -
    liftSeventeen K (firstEndpoint i + secondEndpoint i) • LinearMap.proj 1 +
    LinearMap.proj 2

private theorem extendedRow_liftVector (i : Fin 4) (v : Fin 4 → ZMod 17) :
    extendedRow K i (liftVector K v) = liftSeventeen K (row0 (firstEndpoint i) (secondEndpoint i) v) := by
  simp [extendedRow, liftVector, smul_eq_mul, map_add, map_sub, map_mul]

private theorem checked_rows : ∀ i : Fin 4,
    row0 (firstEndpoint i) (secondEndpoint i) (column (supportLeft i)) = 0 ∧
    row0 (firstEndpoint i) (secondEndpoint i) (column (supportRight i)) = 0 ∧
    row0 (firstEndpoint i) (secondEndpoint i) t0 ≠ 0 ∧
    row0 (firstEndpoint i) (secondEndpoint i) t1 = 0 := by
  decide

private theorem direction_not_mem (x : K) (i : Fin 4) :
    matchingDirection K x ∉ extensionSupport K i := by
  rw [extensionSupport_eq_span, Submodule.mem_span_pair]
  rintro ⟨a, b, heq⟩
  obtain ⟨hleft, hright, hconst, hslope⟩ := checked_rows i
  have hsplit : matchingDirection K x = liftVector K t0 + x • liftVector K t1 := by
    funext j
    rw [direction_apply]
    rfl
  rw [hsplit] at heq
  have h := congrArg (extendedRow K i) heq
  simp only [map_add, map_smul, extendedRow_liftVector, hleft, hright, hslope, map_zero,
    smul_zero, add_zero] at h
  exact hconst ((liftSeventeen K).injective (h.symm.trans (map_zero (liftSeventeen K)).symm))

/-- The chart pencil has exactly a point intersection with every designated support. -/
theorem matching_hit (x : K) (hx : x ^ 2 = liftSeventeen K 11) (i : Fin 4) :
    (pencil (F := K) (matchingBase K x) (matchingDirection K x)).range ⊓ extensionSupport K i =
      (affinePoint _ (matchingPencil_injective K x) (matchingChallenge K x i)).submodule := by
  apply (intersection_eq_affinePoint_iff _ (matchingPencil_injective K x) _ _).mpr
  refine ⟨hit_mem K x hx i, fun h => direction_not_mem K x i ?_⟩
  apply h
  exact ⟨(0, 1), by simp [pencil_apply]⟩

/-- The four support intersections give distinct affine challenge values. -/
theorem matchingChallenge_injective (x : K) (hx : x ^ 2 = liftSeventeen K 11) :
    Function.Injective (matchingChallenge K x) := by
  intro i j h
  by_contra hij
  have hd : gamma1 i - gamma1 j ≠ 0 := by
    have checked : ∀ i j : Fin 4, i ≠ j → gamma1 i - gamma1 j ≠ 0 := by decide
    exact checked i j hij
  have hxval : x = liftSeventeen K ((gamma0 j - gamma0 i) / (gamma1 i - gamma1 j)) := by
    rw [map_div₀, eq_div_iff (lift_nonzero K hd)]
    simp only [challenge_apply, affineExpr] at h
    simp only [map_sub]
    linear_combination h
  apply sq_ne_eleven ((gamma0 j - gamma0 i) / (gamma1 i - gamma1 j))
  apply (liftSeventeen K).injective
  rw [map_pow, ← hxval, hx]

/-- Prime-field Frobenius interchanges the two roots of the reduced chart. -/
theorem matching_root_frobenius (x : K) (hx : x ^ 2 = liftSeventeen K 11) : x ^ 17 = -x := by
  have h : (11 : ZMod 17) ^ 8 = -1 := by decide
  calc
    x ^ 17 = (x ^ 2) ^ 8 * x := by ring
    _ = -x := by rw [hx, ← map_pow, h, map_neg, map_one, neg_one_mul]

end ProximityCoding.MCA.Syndrome.Seventeen
