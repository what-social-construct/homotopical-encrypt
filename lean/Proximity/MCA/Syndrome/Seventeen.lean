module

public import Proximity.MCA.Syndrome.Projective
public import Proximity.MCA.Syndrome.Seventeen.Certificate
public import Proximity.MCA.Syndrome.Seventeen.Coordinates
public import Proximity.MCA.Syndrome.Seventeen.Domain

@[expose] public section

/-!
# An empty support pattern for the smooth [8,4] code over F₁₇

The four pairs of consecutive powers of 9 give actual error-support
subspaces of the original code. Their incidence equations reduce the
Plücker quadric to the certified univariate chart.
-/

set_option autoImplicit false

namespace ProximityCoding.MCA.Syndrome.Seventeen

open BlockCode.Syndrome

local instance : Fact (Nat.Prime 17) := ⟨prime17⟩
local notation "K" => ZMod 17
local notation "V" => (Fin 4 → K)

private theorem firstSite_eq (i : Fin 4) : site (supportLeft i) = firstEndpoint i := by
  fin_cases i <;> decide

private theorem secondSite_eq (i : Fin 4) : site (supportRight i) = secondEndpoint i := by
  fin_cases i <;> decide

private theorem column_eq_powerColumn (i : Fin 8) :
    column i = powerColumn (site i) := by
  funext j
  fin_cases j <;> simp [column, powerColumn]

private theorem support_le_ker (i : Fin 4) (row : V →ₗ[K] K)
    (left : row (powerColumn (firstEndpoint i)) = 0)
    (right : row (powerColumn (secondEndpoint i)) = 0) :
    errorSyndromes parityCheck (support i) ≤ row.ker := by
  rw [errorSyndromes_eq_span]
  apply Submodule.span_le.mpr
  rintro _ ⟨j, rfl⟩
  change row (parityCheck (Pi.single j.val 1)) = 0
  rw [parityCheck_single, one_smul, column_eq_powerColumn]
  have member : j.val = supportLeft i ∨ j.val = supportRight i := by
    simpa [support] using j.property
  rcases member with same | same
  · rw [same, firstSite_eq]
    exact left
  · rw [same, secondSite_eq]
    exact right

/-- A nontrivial intersection with the actual error subspace forces the
two-coordinate determinant of the pencil to vanish. -/
private theorem det2_zero_of_hit (i : Fin 4) (s t : V)
    (hit : ¬ Disjoint (pencil (F := K) s t).range (errorSyndromes parityCheck (support i))) :
    det2 (firstEndpoint i) (secondEndpoint i) s t = 0 := by
  let a := firstEndpoint i
  let b := secondEndpoint i
  obtain ⟨h₀a, h₁a, h₀b, h₁b⟩ := rows_annihilate_endpoints a b
  have ker₀ := support_le_ker i (row0 a b) h₀a h₀b
  have ker₁ := support_le_ker i (row1 a b) h₁a h₁b
  by_contra nonzero
  apply hit
  apply Submodule.disjoint_def.mpr
  rintro _ ⟨⟨x, y⟩, rfl⟩ mem
  have zero₀ : row0 a b (pencil (F := K) s t (x, y)) = 0 := ker₀ mem
  have zero₁ : row1 a b (pencil (F := K) s t (x, y)) = 0 := ker₁ mem
  simp only [pencil_apply, map_add, map_smul, smul_eq_mul] at zero₀ zero₁
  have xdet : x * det2 a b s t = 0 := by
    unfold det2
    linear_combination row1 a b t * zero₀ - row0 a b t * zero₁
  have ydet : y * det2 a b s t = 0 := by
    unfold det2
    linear_combination row0 a b s * zero₁ - row1 a b s * zero₀
  have xzero := (mul_eq_zero.mp xdet).resolve_right nonzero
  have yzero := (mul_eq_zero.mp ydet).resolve_right nonzero
  simp [xzero, yzero]

/-- No rank-two syndrome pencil meets all four support subspaces of the
matching `{1,9}, {13,15}, {16,8}, {4,2}`. -/
theorem no_four_support_hits (s t : V)
    (injective : Function.Injective (pencil (F := K) s t)) :
    ¬ (∀ i : Fin 4,
      ¬ Disjoint (pencil (F := K) s t).range (errorSyndromes parityCheck (support i))) := by
  intro hits
  let p := plucker s t
  let u := p 3
  let v := p 5
  have eliminated : p = ![13 * v, 0, 5 * u, u, 0, v] :=
    matching_elimination s t (fun i => det2_zero_of_hit i s t (hits i))
  have e₀ : p 0 = 13 * v := congrFun eliminated (0 : Fin 6)
  have e₁ : p 1 = 0 := congrFun eliminated (1 : Fin 6)
  have e₂ : p 2 = 5 * u := congrFun eliminated (2 : Fin 6)
  have e₄ : p 4 = 0 := congrFun eliminated (4 : Fin 6)
  have relation : p 0 * v - p 1 * p 4 + p 2 * u = 0 := plucker_quad s t
  rw [e₀, e₁, e₂, e₄, zero_mul, sub_zero] at relation
  have quadratic : 5 * u ^ 2 + 13 * v ^ 2 = 0 := by
    linear_combination relation
  have seven_five : (7 : K) * 5 = 1 := by decide
  have seven_neg_thirteen : (7 : K) * (-13) = 11 := by decide
  have squares : u ^ 2 = 11 * v ^ 2 := by
    calc
      u ^ 2 = ((7 : K) * 5) * u ^ 2 := by rw [seven_five, one_mul]
      _ = 7 * (5 * u ^ 2) := mul_assoc _ _ _
      _ = 7 * (-(13 * v ^ 2)) := congrArg (fun x => (7 : K) * x)
        (eq_neg_of_add_eq_zero_left quadratic)
      _ = 11 * v ^ 2 := by rw [← neg_mul, ← mul_assoc, seven_neg_thirteen]
  have vnonzero : v ≠ 0 := by
    intro vzero
    have uzero : u = 0 := sq_eq_zero_iff.mp (by simpa [vzero] using squares : u ^ 2 = 0)
    have pzero : p = 0 := by
      calc
        p = ![13 * v, 0, 5 * u, u, 0, v] := eliminated
        _ = 0 := by funext j; fin_cases j <;> simp [uzero, vzero]
    exact plucker_ne_zero s t injective pzero
  apply sq_ne_eleven (u / v)
  rw [div_pow, squares, mul_div_cancel_right₀ _ (pow_ne_zero _ vnonzero)]

/-- The original same-set MCA predicate cannot witness one bad challenge
on each of these four supports for an independent syndrome pair. -/
theorem no_badChallenges_on_matching (L : AffineLine (Fin 8) K)
    (injective : Function.Injective
      (pencil (F := K) (parityCheck L.base) (parityCheck L.direction)))
    (seeds : Fin 4 → K) :
    ¬ (∀ i : Fin 4, parameters.toBlockCode.BadOnSet L (seeds i) (Finset.univ \ support i)) := by
  intro bad
  apply no_four_support_hits (parityCheck L.base) (parityCheck L.direction) injective
  intro i disjoint
  have mem := ((badOnSet_iff parameters.toBlockCode parityCheck parityCheck_zero_iff L
    (seeds i) (support i)).mp (bad i)).1
  let M := pencil (F := K) (parityCheck L.base) (parityCheck L.direction)
  apply affineRepresentative_ne_zero M injective (seeds i)
  apply (Submodule.disjoint_def.mp disjoint) _ ⟨(1, seeds i), rfl⟩
  simpa [M] using mem

end ProximityCoding.MCA.Syndrome.Seventeen
