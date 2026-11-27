module

public import Proximity.MCA.Syndrome.Seventeen.Domain
public import Mathlib.Data.Finset.Card

@[expose] public section

/-!
# Arithmetic certificates at count radius three

Each sorted triple determines the annihilating row of its three
parity-check columns. The base pencil yields every seed in `ZMod 17`.
For the extension pencil we calculate with coefficient pairs for
`a + b * x`, using `x² = 11`. The fifty-six triples yield distinct seeds
in those coordinates.
-/

set_option autoImplicit false
set_option maxRecDepth 4096
set_option maxHeartbeats 1000000

namespace ProximityCoding.MCA.Syndrome.Seventeen.RadiusThree

open scoped BigOperators Matrix

local notation "K" => ZMod 17

local instance : Fact (Nat.Prime 17) := ⟨prime17⟩

/-- A triple of site indices. -/
abbrev SiteTriple := Fin 8 × Fin 8 × Fin 8

/-- Each unordered three-site support appears once. -/
def sortedTriples : Finset SiteTriple :=
  Finset.univ.filter fun u => u.1 < u.2.1 ∧ u.2.1 < u.2.2

/-- The monic cubic with roots at the three sites, in increasing degree order. -/
def annihilatorRow (u : SiteTriple) : Fin 4 → K :=
  let a := site u.1
  let b := site u.2.1
  let c := site u.2.2
  ![-a * b * c, a * b + a * c + b * c, -(a + b + c), 1]

theorem sortedTriples_card : sortedTriples.card = 56 := by decide

def baseColumn : Fin 4 → K := ![14, 10, 9, 10]

def baseDirection : Fin 4 → K := ![12, 12, 2, 2]

def baseDenominator (u : SiteTriple) : K :=
  ∑ j, annihilatorRow u j * baseDirection j

/-- An explicit inverse table keeps the finite certificate in small residue arithmetic. -/
def inverse17 (a : K) : K :=
  (![0, 1, 9, 6, 13, 7, 3, 5, 15, 2, 12, 14, 10, 4, 11, 8, 16] : Fin 17 → K) a

private theorem inverse17_mul (a : K) (ha : a ≠ 0) : inverse17 a * a = 1 := by
  have checked : ∀ b : K, b ≠ 0 → inverse17 b * b = 1 := by decide
  exact checked a ha

def baseSeed (u : SiteTriple) : K :=
  -(∑ j, annihilatorRow u j * baseColumn j) * inverse17 (baseDenominator u)

theorem baseSeed_mul_denominator (u : SiteTriple) (h : baseDenominator u ≠ 0) :
    baseSeed u * baseDenominator u = -(∑ j, annihilatorRow u j * baseColumn j) := by
  rw [baseSeed, mul_assoc, inverse17_mul _ h, mul_one]

/-- Triples with nonzero denominator realize all seventeen finite seeds. -/
theorem baseSeed_image :
    (sortedTriples.filter fun u => baseDenominator u ≠ 0).image baseSeed =
      (Finset.univ : Finset K) := by decide

/-- Coefficients of `a + b * x`, with `x² = 11`. -/
abbrev Quad := K × K

def quadNeg (a : Quad) : Quad := (-a.1, -a.2)

def quadMul (a b : Quad) : Quad :=
  (a.1 * b.1 + 11 * a.2 * b.2, a.1 * b.2 + a.2 * b.1)

def quadInv (a : Quad) : Quad :=
  let norm := a.1 ^ 2 - 11 * a.2 ^ 2
  (a.1 * inverse17 norm, -a.2 * inverse17 norm)

def extensionColumn : Fin 4 → Quad := ![(15, 16), (8, 1), (0, 15), (2, 0)]

def extensionDirection : Fin 4 → Quad := ![(13, 11), (14, 14), (13, 16), (8, 2)]

def quadDot (a : Fin 4 → K) (b : Fin 4 → Quad) : Quad :=
  (∑ j, a j * (b j).1, ∑ j, a j * (b j).2)

def extensionDenominator (u : SiteTriple) : Quad :=
  quadDot (annihilatorRow u) extensionDirection

def extensionNumerator (u : SiteTriple) : Quad :=
  quadNeg (quadDot (annihilatorRow u) extensionColumn)

def extensionSeed (u : SiteTriple) : Quad :=
  quadMul (extensionNumerator u) (quadInv (extensionDenominator u))

theorem extensionDenominator_nonzero (u : SiteTriple) (hu : u ∈ sortedTriples) :
    extensionDenominator u ≠ 0 := by
  have checked : sortedTriples.filter (fun v => extensionDenominator v = 0) = ∅ := by decide
  intro h
  have hm : u ∈ sortedTriples.filter (fun v => extensionDenominator v = 0) :=
    Finset.mem_filter.mpr ⟨hu, h⟩
  rw [checked] at hm
  exact Finset.notMem_empty u hm

/-- Each proposed extension seed clears its denominator in the quadratic basis. -/
theorem extensionSeed_mul_denominator (u : SiteTriple) (hu : u ∈ sortedTriples) :
    quadMul (extensionSeed u) (extensionDenominator u) = extensionNumerator u := by
  have checked : sortedTriples.filter (fun v =>
      quadMul (extensionSeed v) (extensionDenominator v) ≠ extensionNumerator v) = ∅ := by
    decide
  by_contra h
  have hm : u ∈ sortedTriples.filter (fun v =>
      quadMul (extensionSeed v) (extensionDenominator v) ≠ extensionNumerator v) :=
    Finset.mem_filter.mpr ⟨hu, h⟩
  rw [checked] at hm
  exact Finset.notMem_empty u hm

theorem extensionSeed_image_card : (sortedTriples.image extensionSeed).card = 56 := by
  decide

theorem extensionSeed_injOn : Set.InjOn extensionSeed (sortedTriples : Set SiteTriple) :=
  Finset.card_image_iff.mp (extensionSeed_image_card.trans sortedTriples_card.symm)

end ProximityCoding.MCA.Syndrome.Seventeen.RadiusThree
