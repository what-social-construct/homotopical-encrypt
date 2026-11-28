module

public import Proximity.Core.ReedSolomon
public import Mathlib.Algebra.Field.ZMod
public import Mathlib.GroupTheory.OrderOfElement
public import Mathlib.Data.List.FinRange
public import Mathlib.Data.List.Nodup

@[expose] public section

/-!
# Anchored cubic locator census for the order-sixteen subgroup of F3617

Five disjoint triples miss one site. After scaling that site to index zero,
one of the triples contains index one and has its other two indices larger
than one. For each such anchor, compare normalized coefficient differences
against disjoint triples avoiding zero. In each of three classes, indexed by
the least site index modulo three, these directions are injective.
-/

set_option autoImplicit false
set_option maxRecDepth 8192
set_option maxHeartbeats 4000000

namespace ProximityCoding.MCA.Syndrome.Sixteen.LocatorCensus

abbrev BaseField := ZMod 3617

theorem base_prime : Nat.Prime 3617 := by norm_num

instance basePrimeFact : Fact (Nat.Prime 3617) := ⟨base_prime⟩

def root : BaseField := 26

theorem root_order : orderOf root = 16 := by
  let _ : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  apply orderOf_eq_prime_pow (p := 2) (n := 3)
  · change (26 : BaseField) ^ 8 ≠ 1
    decide
  · change (26 : BaseField) ^ 16 = 1
    decide

def site (i : Fin 16) : BaseField := root ^ i.val

theorem site_injective : Function.Injective site := by
  have checked : ∀ i j : Fin 16, site i = site j → i = j := by decide
  intro i j equal
  exact checked i j equal

abbrev Triple := Fin 16 × Fin 16 × Fin 16

abbrev Coefficients := BaseField × BaseField × BaseField

def ordered (t : Triple) : Prop := t.1 < t.2.1 ∧ t.2.1 < t.2.2

instance (t : Triple) : Decidable (ordered t) := by unfold ordered; infer_instance

def support (t : Triple) : Finset (Fin 16) := {t.1, t.2.1, t.2.2}

/-- The three coefficients below the monic term, in decreasing order. -/
def coefficients (t : Triple) : Coefficients :=
  let x := site t.1
  let y := site t.2.1
  let z := site t.2.2
  (-(x + y + z), x * y + x * z + y * z, -(x * y * z))

theorem locator_eq_coefficients (t : Triple) :
    (Polynomial.X - Polynomial.C (site t.1)) *
      (Polynomial.X - Polynomial.C (site t.2.1)) *
      (Polynomial.X - Polynomial.C (site t.2.2)) =
    Polynomial.X ^ 3 + Polynomial.C (coefficients t).1 * Polynomial.X ^ 2 +
      Polynomial.C (coefficients t).2.1 * Polynomial.X +
      Polynomial.C (coefficients t).2.2 := by
  simp only [coefficients, Polynomial.C_neg, Polynomial.C_add, Polynomial.C_mul]
  ring

def scale (a : BaseField) (v : Coefficients) : Coefficients :=
  (a * v.1, a * v.2.1, a * v.2.2)

def normalize (v : Coefficients) : Coefficients :=
  if v.1 ≠ 0 then (1, v.2.1 / v.1, v.2.2 / v.1)
  else if v.2.1 ≠ 0 then (0, 1, v.2.2 / v.2.1)
  else if v.2.2 ≠ 0 then (0, 0, 1)
  else (0, 0, 0)

theorem normalize_scale (a : BaseField) (v : Coefficients) (nonzero : a ≠ 0) :
    normalize (scale a v) = normalize v := by
  rcases v with ⟨x, y, z⟩
  by_cases hx : x = 0 <;> by_cases hy : y = 0 <;> by_cases hz : z = 0 <;>
    simp [normalize, scale, nonzero, hx, hy, hz, mul_div_mul_left _ _ nonzero]

def direction (anchor candidate : Triple) : Coefficients :=
  normalize (coefficients candidate - coefficients anchor)

def color (t : Triple) : Fin 3 := ⟨t.1.val % 3, Nat.mod_lt _ (by decide)⟩

private def allowed (a b : Triple) : Prop :=
  b.1 ≠ 0 ∧ b.1 ∉ support a ∧ b.2.1 ∉ support a ∧ b.2.2 ∉ support a

private instance (a b : Triple) : Decidable (allowed a b) := by unfold allowed; infer_instance

private def triples : List Triple :=
  ((List.finRange 16).flatMap fun i => (List.finRange 16).flatMap fun j =>
    (List.finRange 16).map fun k => (i, j, k)).filter fun t => decide (ordered t)

private def candidates (anchor : Triple) (c : Fin 3) : List Triple :=
  triples.filter fun b => decide (allowed anchor b ∧ color b = c)

private theorem mem_candidates {a b : Triple} {c : Fin 3} :
    b ∈ candidates a c ↔ ordered b ∧ allowed a b ∧ color b = c := by
  rcases b with ⟨i, j, k⟩
  simp [candidates, triples, List.mem_flatMap, and_assoc]
  tauto

/-- The finite replay tests injectivity within each of the three colors. -/
private def directionKey (a b : Triple) : ℕ :=
  let d := direction a b
  (d.1.val * 3617 + d.2.1.val) * 3617 + d.2.2.val

private theorem nodup_of_split (p : ℕ → Bool) (keys : List ℕ)
    (left : (keys.filter p).Nodup) (right : (keys.filter fun x => !p x).Nodup) :
    keys.Nodup := by
  induction keys with
  | nil => simp
  | cons x keys ih =>
      by_cases px : p x = true
      · simp only [List.filter_cons, px, if_true, Bool.not_true, Bool.false_eq_true, if_false] at left right
        have hl := List.nodup_cons.mp left
        exact List.nodup_cons.mpr ⟨fun member => hl.1 (List.mem_filter.mpr ⟨member, px⟩),
          ih hl.2 right⟩
      · have notPx : p x = false := Bool.eq_false_iff.mpr px
        simp only [List.filter_cons, notPx, Bool.false_eq_true, if_false, Bool.not_false, if_true]
          at left right
        have hr := List.nodup_cons.mp right
        exact List.nodup_cons.mpr ⟨fun member => hr.1 (List.mem_filter.mpr ⟨member, by simp [notPx]⟩),
          ih left hr.2⟩

/-- A radix check can stop as soon as each branch has at most one key. -/
private def distinctKeys : ℕ → List ℕ → Bool
  | _, [] | _, [_] => true
  | 0, _ :: _ :: _ => false
  | bit + 1, x :: y :: rest =>
      let keys := x :: y :: rest
      distinctKeys bit (keys.filter fun a => a.testBit bit) &&
        distinctKeys bit (keys.filter fun a => !(a.testBit bit))

private theorem nodup_of_distinctKeys (bits : ℕ) (keys : List ℕ)
    (verified : distinctKeys bits keys = true) : keys.Nodup := by
  induction bits generalizing keys with
  | zero =>
      rcases keys with _ | ⟨x, _ | rest⟩ <;> simp [distinctKeys] at verified ⊢
  | succ bit ih =>
      rcases keys with _ | ⟨x, _ | y, rest⟩
      · simp
      · simp
      · have split := Bool.and_eq_true_iff.mp verified
        exact nodup_of_split _ _ (ih _ split.1) (ih _ split.2)

private theorem census : ∀ (j k : Fin 16) (c : Fin 3),
    ordered (1, j, k) →
      distinctKeys 25 ((candidates (1, j, k) c).map (directionKey (1, j, k))) = true := by
  intro j
  fin_cases j <;> decide +kernel

/-- When the anchor contains index one and avoids zero, four disjoint-from-anchor
candidates cannot all have the same normalized coefficient direction. -/
theorem no_four_equal_directions {a : Triple} (orderedAnchor : ordered a) (anchorSite : a.1 = 1)
    (family : Fin 4 → Triple) (distinct : Function.Injective family)
    (hordered : ∀ i, ordered (family i)) (nonzeroSite : ∀ i, (family i).1 ≠ 0)
    (apart : ∀ i, Disjoint (support a) (support (family i)))
    (equalDirections : ∀ i, direction a (family i) = direction a (family 0)) : False := by
  have injectiveColor : Function.Injective (fun i => color (family i)) := by
    intro i j sameColor
    have candidate (l : Fin 4) (same : color (family l) = color (family i)) :
        family l ∈ candidates a (color (family i)) := by
      apply mem_candidates.mpr
      refine ⟨hordered l, ⟨nonzeroSite l, ?_, ?_, ?_⟩, same⟩
      all_goals
        intro member
        exact Finset.disjoint_left.mp (apart l) member (by simp [support])
    have checked := census a.2.1 a.2.2 (color (family i))
    have anchorShape : (1, a.2.1, a.2.2) = a := by
      rcases a with ⟨x, y, z⟩
      simp only at anchorSite
      rw [anchorSite]
    rw [anchorShape] at checked
    have sameKey : directionKey a (family i) = directionKey a (family j) := by
      simp only [directionKey, equalDirections i, equalDirections j]
    exact distinct (List.inj_on_of_nodup_map (nodup_of_distinctKeys _ _ (checked orderedAnchor)) (candidate i rfl)
      (candidate j sameColor.symm) sameKey)
  exact Fintype.not_injective_of_card_lt (fun i => color (family i)) (by decide) injectiveColor

end ProximityCoding.MCA.Syndrome.Sixteen.LocatorCensus
