module

public import Proximity.Concrete.CanonicalRS.Parameters
public meta import Proximity.Concrete.CanonicalRS.Parameters
public import Mathlib.GroupTheory.OrderOfElement

@[expose] public section

/-
  Certified power-domain construction for the canonical RS regime.

  Paper correspondence:
  - Paper 3: the certified canonical field generator, root order and injective
    evaluation domain.
  - Paper 2 reuses the resulting domain through the declared codec/profile.

  This file is the algebraic boundary around multiplicative-order facts. A full
  generator of `ZMod 12289` has order `12288`; cubing it gives the order-`4096`
  root used for the smooth power-domain evaluation points.
-/

namespace HomotopicalEncryption
namespace Proximity
namespace CanonicalRS

noncomputable section

/--
A certified generator for the canonical power-of-two evaluation domain.

The concrete domain points are the field values of `root^i` for
`i : Fin length`. The root is a unit, because the smooth RS domain is a
multiplicative subgroup-style object. The certificate is kept as
`orderOf root = length` so injectivity is algebraic rather than a brute-force
all-pairs check over the evaluation set.
-/
structure PowerRoot where
  root : RSFieldˣ
  order_eq_length : orderOf root = length

/--
A certified full multiplicative generator of `ZMod 12289`.

This is the algebraic certificate we want upstream of the power-domain root:
if `generator` has order `12288`, then `generator^3` has order `4096`.
-/
structure FullGenerator where
  generator : RSFieldˣ
  order_eq_fullGeneratorOrder : orderOf generator = fullGeneratorOrder

namespace FullGenerator

/-- Cubing a full generator gives the canonical power-of-two evaluation root. -/
def root (γ : FullGenerator) : RSFieldˣ :=
  γ.generator ^ rootExponent

/-- The cubed full generator has exactly the selected RS length as its order. -/
theorem orderOf_root (γ : FullGenerator) :
    orderOf γ.root = length := by
  rw [root, orderOf_pow_of_dvd rootExponent_ne_zero]
  · rw [γ.order_eq_fullGeneratorOrder, fullGeneratorOrder_div_rootExponent_eq_length]
  · rw [γ.order_eq_fullGeneratorOrder]
    exact rootExponent_dvd_fullGeneratorOrder

/-- Turn a full generator certificate into the certified RS power root. -/
def toPowerRoot (γ : FullGenerator) : PowerRoot where
  root := γ.root
  order_eq_length := γ.orderOf_root

end FullGenerator

namespace PowerRoot

/-- Evaluation point `i` in the certified power domain. -/
def point (ρ : PowerRoot) (i : Fin length) : RSField :=
  (ρ.root ^ (i : ℕ) : RSField)

/-- Powers of a primitive `length`-th root are injective on `Fin length`. -/
theorem injective_point (ρ : PowerRoot) :
    Function.Injective ρ.point := by
  intro i j hij
  have hmod : (i : ℕ) ≡ (j : ℕ) [MOD length] := by
    have hij_units : ρ.root ^ (i : ℕ) = ρ.root ^ (j : ℕ) := by
      ext
      simpa [point] using hij
    have hmod' : (i : ℕ) ≡ (j : ℕ) [MOD orderOf ρ.root] := by
      exact (pow_eq_pow_iff_modEq).mp hij_units
    simpa [ρ.order_eq_length] using hmod'
  have hval : (i : ℕ) = (j : ℕ) := by
    unfold Nat.ModEq at hmod
    simpa [Nat.mod_eq_of_lt i.isLt, Nat.mod_eq_of_lt j.isLt] using hmod
  exact Fin.ext hval

/-- The RS evaluation domain induced by a certified primitive root. -/
def domain (ρ : PowerRoot) :
    ReedSolomon.EvaluationDomain RSField (Fin length) where
  point := ρ.point
  injective_point := ρ.injective_point

/--
The canonical smooth domain induced by a certified primitive root.

Smoothness is recorded by the arithmetic divisibility fact for the selected
field and length; the root certificate supplies the actual evaluation points.
-/
def smoothDomain (ρ : PowerRoot) : SmoothDomain where
  domain := ρ.domain
  smooth := length ∣ Axioms.canonicalCochainModulus - 1

/-- The arithmetic smoothness obligation for the certified power domain holds. -/
theorem smoothDomain_smooth (ρ : PowerRoot) :
    ρ.smoothDomain.smooth :=
  length_dvd_canonical_modulus_minus_one

end PowerRoot

/--
Candidate full generator field value for the first canonical power domain.

The intended algebraic certificate is that the corresponding unit has full
multiplicative order `12288`; then `candidateGenerator^3` is the order-`4096`
evaluation root by `FullGenerator.toPowerRoot`.
-/
def candidateGenerator : RSField :=
  11

/-- Candidate full generator as a unit of the canonical field. -/
def candidateGeneratorUnit : RSFieldˣ :=
  ZMod.unitOfCoprime
    11
    (by norm_num [Axioms.canonicalCochainModulus] : Nat.Coprime 11 Axioms.canonicalCochainModulus)

/-- The candidate unit has the expected field value. -/
@[simp]
theorem candidateGeneratorUnit_coe :
    (candidateGeneratorUnit : RSField) = candidateGenerator := by
  simp [candidateGeneratorUnit, candidateGenerator]

/-- The only prime divisors of the full multiplicative-group order are `2` and `3`. -/
theorem prime_dvd_fullGeneratorOrder_eq_two_or_three
    {p : ℕ}
    (hp : p.Prime)
    (hpdvd : p ∣ fullGeneratorOrder) :
    p = 2 ∨ p = 3 := by
  have hdiv : p ∣ 2 ^ 12 * 3 := by
    simpa [fullGeneratorOrder, Axioms.canonicalCochainModulus] using hpdvd
  have hcases : p ∣ 2 ^ 12 ∨ p ∣ 3 :=
    hp.dvd_mul.mp hdiv
  cases hcases with
  | inl h2pow =>
      left
      have hp2 : p ∣ 2 :=
        hp.dvd_of_dvd_pow h2pow
      exact (Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).mp hp2
  | inr h3 =>
      right
      exact (Nat.prime_dvd_prime_iff_eq hp Nat.prime_three).mp h3

/-- The candidate generator has full multiplicative order in `ZMod 12289`. -/
theorem candidateGeneratorUnit_order :
    orderOf candidateGeneratorUnit = fullGeneratorOrder := by
  apply orderOf_eq_of_pow_and_pow_div_prime
  · norm_num [fullGeneratorOrder, Axioms.canonicalCochainModulus]
  · ext
    change (11 : ZMod 12289) ^ 12288 = 1
    reduce_mod_char
    decide
  · intro p hp hpdvd
    rcases prime_dvd_fullGeneratorOrder_eq_two_or_three hp hpdvd with rfl | rfl
    · intro h
      have hv := congrArg ((↑) : RSFieldˣ → RSField) h
      have hcalc :
          ((candidateGeneratorUnit ^ (fullGeneratorOrder / 2) : RSFieldˣ) : RSField) ≠
            1 := by
        change (11 : ZMod 12289) ^ 6144 ≠ 1
        reduce_mod_char
        decide
      exact hcalc hv
    · intro h
      have hv := congrArg ((↑) : RSFieldˣ → RSField) h
      have hcalc :
          ((candidateGeneratorUnit ^ (fullGeneratorOrder / 3) : RSFieldˣ) : RSField) ≠
            1 := by
        change (11 : ZMod 12289) ^ 4096 ≠ 1
        reduce_mod_char
        decide
      exact hcalc hv

/-- Certified full generator for the canonical RS power domain. -/
def candidateFullGenerator : FullGenerator where
  generator := candidateGeneratorUnit
  order_eq_fullGeneratorOrder := candidateGeneratorUnit_order

/-- Candidate field value for the order-`4096` evaluation root. -/
def candidateRoot : RSField :=
  candidateGenerator ^ rootExponent

/-- Certified canonical power root obtained algebraically by cubing the full generator. -/
def canonicalPowerRoot : PowerRoot :=
  candidateFullGenerator.toPowerRoot

/-- The certified power root has the same field value as `candidateRoot`. -/
@[simp]
theorem canonicalPowerRoot_root_coe :
    (canonicalPowerRoot.root : RSField) = candidateRoot := by
  simp [canonicalPowerRoot, candidateFullGenerator, FullGenerator.toPowerRoot,
    FullGenerator.root, candidateRoot]

/-- Canonical smooth RS domain for the selected field and length. -/
def canonicalSmoothDomain : SmoothDomain :=
  canonicalPowerRoot.smoothDomain

end

end CanonicalRS
end Proximity
end HomotopicalEncryption
