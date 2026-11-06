module

public import Proximity.Core.BlockCode

@[expose] public section

/-!
# Planes, pair words, and affine-line presentations

The "plane" carrier is the complete ambient received-word space
`ι → (Fin 2 → F)`. This file proves that it is equivalent to pair-symbol
words and to arbitrary affine-line presentations. The pair equivalence is an
isometry for whole-symbol Hamming distance.
-/

namespace ProximityPrize

/-- A two-coordinate field-valued plane. -/
abbrev PlaneWord (ι F : Type*) := Word ι (Fin 2 → F)

/-- The conventional product-symbol presentation `(F × F)^ι`. -/
abbrev PairWord (ι F : Type*) := Word ι (F × F)

/-- Product symbols and two-coordinate function symbols are equivalent. -/
def pairSymbolEquiv (F : Type*) : (F × F) ≃ (Fin 2 → F) where
  toFun x j := if j = 0 then x.1 else x.2
  invFun x := (x 0, x 1)
  left_inv x := by
    apply Prod.ext <;> simp
  right_inv x := by
    funext j
    fin_cases j <;> simp

/-- A plane is exactly a word of pair symbols. -/
def planePairEquiv (ι F : Type*) :
    PlaneWord ι F ≃ PairWord ι F where
  toFun p i := (p i 0, p i 1)
  invFun w i := pairSymbolEquiv F (w i)
  left_inv p := by
    funext i j
    fin_cases j <;> simp [pairSymbolEquiv]
  right_inv w := by
    funext i
    exact (pairSymbolEquiv F).left_inv (w i)

@[simp]
theorem planePairEquiv_fst
    {ι F : Type*} (p : PlaneWord ι F) (i : ι) :
    (planePairEquiv ι F p i).1 = p i 0 :=
  rfl

@[simp]
theorem planePairEquiv_snd
    {ι F : Type*} (p : PlaneWord ι F) (i : ι) :
    (planePairEquiv ι F p i).2 = p i 1 :=
  rfl

/-- Plane--pair conversion preserves and reflects whole-symbol Hamming distance. -/
theorem planePairEquiv_hammingDistance
    {ι F : Type*} [Fintype ι] [DecidableEq F]
    (p q : PlaneWord ι F) :
    BlockCode.hammingDistance (planePairEquiv ι F p) (planePairEquiv ι F q) =
      BlockCode.hammingDistance p q := by
  unfold BlockCode.hammingDistance
  apply congrArg Finset.card
  ext i
  simp only [Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · intro hpq hplane
    apply hpq
    exact congrArg (fun r : Fin 2 → F => (r 0, r 1)) hplane
  · intro hpq hpairs
    apply hpq
    funext j
    fin_cases j
    · exact congrArg Prod.fst hpairs
    · exact congrArg Prod.snd hpairs

/-- Plane--pair conversion is an isometry for relative Hamming distance. -/
theorem planePairEquiv_relativeHammingDistance
    {ι F : Type*} [Fintype ι] [DecidableEq F]
    (p q : PlaneWord ι F) :
    BlockCode.relativeHammingDistance
        (planePairEquiv ι F p) (planePairEquiv ι F q) =
      BlockCode.relativeHammingDistance p q := by
  simp only [BlockCode.relativeHammingDistance,
    planePairEquiv_hammingDistance]

/-- An arbitrary affine-line presentation: a base word and direction word. -/
structure AffineLine (ι F : Type*) where
  base : Word ι F
  direction : Word ι F

namespace AffineLine

/-- The scalar received word selected by challenge `γ`. -/
def point
    {ι F : Type*} [Add F] [Mul F]
    (L : AffineLine ι F) (γ : F) : Word ι F :=
  fun i => L.base i + γ * L.direction i

@[simp]
theorem point_apply
    {ι F : Type*} [Add F] [Mul F]
    (L : AffineLine ι F) (γ : F) (i : ι) :
    L.point γ i = L.base i + γ * L.direction i :=
  rfl

end AffineLine

/-- A plane is exactly an arbitrary affine-line presentation. -/
def planeLineEquiv (ι F : Type*) :
    PlaneWord ι F ≃ AffineLine ι F where
  toFun p := ⟨fun i => p i 0, fun i => p i 1⟩
  invFun L i j := if j = 0 then L.base i else L.direction i
  left_inv p := by
    funext i j
    fin_cases j <;> simp
  right_inv L := by
    cases L
    rfl

@[simp]
theorem planeLineEquiv_base
    {ι F : Type*} (p : PlaneWord ι F) :
    (planeLineEquiv ι F p).base = fun i => p i 0 :=
  rfl

@[simp]
theorem planeLineEquiv_direction
    {ι F : Type*} (p : PlaneWord ι F) :
    (planeLineEquiv ι F p).direction = fun i => p i 1 :=
  rfl

/-- Challenge evaluation of the affine line represented by a plane. -/
def evaluatePlane
    {ι F : Type*} [Add F] [Mul F]
    (p : PlaneWord ι F) (γ : F) : Word ι F :=
  (planeLineEquiv ι F p).point γ

@[simp]
theorem evaluatePlane_apply
    {ι F : Type*} [Add F] [Mul F]
    (p : PlaneWord ι F) (γ : F) (i : ι) :
    evaluatePlane p γ i = p i 0 + γ * p i 1 :=
  rfl

end ProximityPrize
