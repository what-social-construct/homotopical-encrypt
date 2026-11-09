module

public import Mathlib.Data.Fintype.Card
public import Mathlib.Data.Finset.Basic
public import Mathlib.Basic.Real.Basic
public import Mathlib.Tactic
public import Mathlib.Algebra.Polynomial.Basic
public import Mathlib.LinearAlgebra.Lagrange
public import Mathlib.Data.Finset.Max
public import Mathlib.Data.Finset.Range
public import Mathlib.Data.Fintype.Prod
public import Mathlib.FieldTheory.Finite.GaloisField
public import Mathlib.GroupTheory.OrderOfElement

@[expose] public section
set_option autoImplicit false
set_option maxHeartbeats 0
set_option maxRecDepth 4000
set_option linter.unusedSectionVars false

/-!
# Capacity-radius proximity for smooth-domain Reed--Solomon codes

Independent coding statements for Paper 3, using only Mathlib imports.
The definitions below retain their canonical names and ordinary mathematical
values. The compared claims include all nine original coding groups, exact
spectrum/distance endpoints and the sharpness/fixed-challenge boundaries.
The original cochain application is a separate companion configuration.
-/

/- Generic coding definitions and exact selected statements, independently restated.
All definitions retain their original canonical names and source bodies. -/
namespace ProximityPrize

/-- A word indexed by `ι` with symbols in `α`. -/
abbrev Word (ι α : Type*) := ι → α

/-- A code specified by a predicate on words. -/
structure BlockCode (ι α : Type*) where
  Codeword : Word ι α → Prop

namespace BlockCode
variable {ι α : Type*} [Fintype ι] [DecidableEq α]

/-- The number of coordinates at which two words differ. -/
def hammingDistance (u v : Word ι α) : ℕ := (Finset.univ.filter fun i => u i ≠ v i).card

/-- A Hamming-count radius divided by the number of coordinates. -/
noncomputable def relativeRadius (r : ℕ) : ℝ := (r : ℝ) / (Fintype.card ι : ℝ)

/-- The mismatch count divided by the number of coordinates. -/
noncomputable def relativeHammingDistance (u v : Word ι α) : ℝ := (hammingDistance u v : ℝ) / (Fintype.card
  ι : ℝ)

/-- The codewords in a closed relative Hamming ball around the given word. -/
def BallAt (C : BlockCode ι α) (δ : ℝ) (w : Word ι α) : Set (Word ι α) := {c | C.Codeword c ∧
  relativeHammingDistance c w ≤ δ}

/-- The `Nat.card` cardinality of the closed relative list ball. -/
noncomputable def ballCardAt (C : BlockCode ι α) (δ : ℝ) (w : Word ι α) : ℕ := Nat.card {c : Word ι α // c ∈
  C.BallAt δ w}

/-- Every closed relative list ball has cardinality at most `L`. -/
def ListSizeBoundAt (C : BlockCode ι α) (δ : ℝ) (L : ℕ) : Prop := ∀ w : Word ι α, C.ballCardAt δ w ≤ L

/-- The natural-number Hamming counts realized by codewords around a word. -/
def codewordDistanceSet (C : BlockCode ι α) (w : Word ι α) : Set ℕ := {d | ∃ c : Word ι α, C.Codeword c ∧ d
  = hammingDistance c w}

/-- The natural-number infimum of the realized codeword Hamming counts. -/
noncomputable def hammingDistanceToCode (C : BlockCode ι α) (w : Word ι α) : ℕ := sInf
  (C.codewordDistanceSet w)

/-- The codeword Hamming-count infimum divided by the number of coordinates. -/
noncomputable def relativeDistanceToCode (C : BlockCode ι α) (w : Word ι α) : ℝ := (C.hammingDistanceToCode
  w : ℝ) / (Fintype.card ι : ℝ)

end BlockCode
namespace BlockCode
variable {ι α : Type*}

/-- The vector-symbol code whose every component column belongs to the base code. -/
def interleaved (C : BlockCode ι α) (τ : Type*) : BlockCode ι (τ → α) where
  Codeword w := ∀ j : τ, C.Codeword fun i => w i j

/-- Read a two-column word on the scalar coordinates `ι × Fin 2`. -/
def flattenPair (w : Word ι (Fin 2 → α)) : Word (ι × Fin 2) α := fun p => w p.1 p.2

/-- The scalar-coordinate code whose two columns each belong to the base code. -/
def flattenedPairCode (C : BlockCode ι α) : BlockCode (ι × Fin 2) α where
  Codeword w := ∀ j, C.Codeword (fun i => w (i, j))

end BlockCode

/-- An ambient word with two field coordinates in each symbol. -/
abbrev PlaneWord (ι F : Type*) := Word ι (Fin 2 → F)

/-- An ambient word with product symbols in `F × F`. -/
abbrev PairWord (ι F : Type*) := Word ι (F × F)

/-- The equivalence between product symbols and functions on `Fin 2`. -/
def pairSymbolEquiv (F : Type*) : (F × F) ≃ (Fin 2 → F) where
  toFun x j := if j = 0 then x.1 else x.2
  invFun x := (x 0, x 1)
  left_inv x := by
    apply Prod.ext <;> simp
  right_inv x := by
    funext j
    fin_cases j <;> simp

/-- The equivalence between all two-coordinate words and product-symbol words. -/
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

theorem planePairEquiv_hammingDistance {ι F : Type*} [Fintype ι] [DecidableEq F] (p q : PlaneWord ι F) :
    BlockCode.hammingDistance (planePairEquiv ι F p) (planePairEquiv ι F q) = BlockCode.hammingDistance p q
    := by sorry

theorem planePairEquiv_relativeHammingDistance {ι F : Type*} [Fintype ι] [DecidableEq F] (p q : PlaneWord ι
    F) : BlockCode.relativeHammingDistance (planePairEquiv ι F p) (planePairEquiv ι F q) =
    BlockCode.relativeHammingDistance p q := by sorry

/-- An affine-line presentation consisting of a base word and a direction word. -/
structure AffineLine (ι F : Type*) where
  base : Word ι F
  direction : Word ι F

namespace AffineLine

/-- The scalar word obtained by adding `γ` times the direction to the base. -/
def point {ι F : Type*} [Add F] [Mul F] (L : AffineLine ι F) (γ : F) : Word ι F := fun i => L.base i + γ *
  L.direction i

end AffineLine

/-- The equivalence between all two-coordinate words and affine-line presentations. -/
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

namespace ReedSolomon

/-- A field-valued vector symbol with component indices `σ`. -/
abbrev VectorSymbol (F σ : Type*) := σ → F

/-- A word whose symbols are field-valued vectors indexed by `σ`. -/
abbrev VectorWord (ι F σ : Type*) := Word ι (VectorSymbol F σ)

/-- An injectively indexed family of evaluation points. -/
structure EvaluationDomain (F ι : Type*) where
  point : ι → F
  injective_point : Function.Injective point

/-- An injective evaluation domain with an attached smoothness proposition. -/
structure SmoothEvaluationDomain (F ι : Type*)
    extends EvaluationDomain F ι where
  smooth : Prop

/-- An evaluation domain together with a natural-number polynomial degree bound. -/
structure Parameters (F ι : Type*) [Field F] [Fintype ι] where
  domain : EvaluationDomain F ι
  degreeBound : ℕ

namespace Parameters
variable {F ι : Type*} [Field F] [Fintype ι]

/-- The number of evaluation coordinates. -/
def length (_P : Parameters F ι) : ℕ := Fintype.card ι

/-- Evaluations of a polynomial whose natural degree is below the degree bound. -/
def Codeword (P : Parameters F ι) (w : Word ι F) : Prop := ∃ p : Polynomial F, p.natDegree < P.degreeBound ∧
  ∀ i : ι, w i = Polynomial.eval (P.domain.point i) p

/-- The scalar polynomial-evaluation predicate viewed as a block code. -/
def toBlockCode (P : Parameters F ι) : BlockCode ι F where
  Codeword := P.Codeword

/-- The Reed–Solomon code interleaved over the component index type `σ`. -/
def vectorBlockCode (P : Parameters F ι) (σ : Type*) : BlockCode ι (VectorSymbol F σ) :=
  P.toBlockCode.interleaved σ

/-- The word with `X^k` evaluations in component `j₀` and zero in the others. -/
def capacityReceivedWord (P : ReedSolomon.Parameters F ι) {σ : Type*} [DecidableEq σ] (j₀ : σ) :
  ReedSolomon.VectorWord ι F σ := fun i j => if j = j₀ then P.domain.point i ^ P.degreeBound else 0

end Parameters
end ReedSolomon
namespace CapacityList
open BlockCode
variable {ι α : Type*} [Fintype ι] [DecidableEq α]

/-- Every closed relative list ball has cardinality at most the real budget `ε q`. -/
noncomputable def FractionalListSizeBoundAt (C : BlockCode ι α) (δ ε : ℝ) (q : ℕ) : Prop := ∀ w : Word ι α,
  (C.ballCardAt δ w : ℝ) ≤ ε * q

end CapacityList
namespace CapacityList
variable {ι α : Type*} [Fintype ι] [Fintype α] [DecidableEq α]

/-- The nonnegative real radii satisfying the fractional list-size budget. -/
def safeRelativeRadii (C : BlockCode ι α) (ε : ℝ) (q : ℕ) : Set ℝ := {δ | 0 ≤ δ ∧ FractionalListSizeBoundAt
  C δ ε q}

end CapacityList
namespace ReedSolomon.Parameters
variable {F ι : Type*} [Field F] [Fintype ι]

theorem vectorListSizeBoundAt_capacityGrid (P : ReedSolomon.Parameters F ι) (σ : Type*) [Fintype F]
    [DecidableEq F] [Fintype σ] (hlength : 0 < Fintype.card ι) (hk : P.degreeBound ≤ Fintype.card ι) :
    (P.vectorBlockCode σ).ListSizeBoundAt (BlockCode.relativeRadius (ι := ι) (Fintype.card ι -
    P.degreeBound)) (Nat.choose (Fintype.card ι) P.degreeBound) := by sorry

theorem capacityReceived_ballCardAt_eq_choose (P : ReedSolomon.Parameters F ι) {σ : Type*} [Fintype F]
    [DecidableEq F] [Fintype σ] [DecidableEq σ] (j₀ : σ) (hDegree : 0 < P.degreeBound) (hlength : 0 <
    Fintype.card ι) (hk : P.degreeBound ≤ Fintype.card ι) : (P.vectorBlockCode σ).ballCardAt
    (BlockCode.relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound)) (P.capacityReceivedWord j₀) =
    Nat.choose (Fintype.card ι) P.degreeBound := by sorry

theorem vectorFractionalListSizeBoundAt_capacityGrid_iff (P : ReedSolomon.Parameters F ι) {σ : Type*}
    [Fintype F] [DecidableEq F] [Fintype σ] [DecidableEq σ] (j₀ : σ) (ε : ℝ) (hDegree : 0 < P.degreeBound)
    (hlength : 0 < Fintype.card ι) (hk : P.degreeBound ≤ Fintype.card ι) :
    CapacityList.FractionalListSizeBoundAt (P.vectorBlockCode σ) (BlockCode.relativeRadius (ι := ι)
    (Fintype.card ι - P.degreeBound)) ε (Fintype.card F) ↔ (Nat.choose (Fintype.card ι) P.degreeBound : ℝ) ≤
    ε * Fintype.card F := by sorry

theorem fieldCard_pow_le_nextShell_ballCardAt (P : ReedSolomon.Parameters F ι) (σ : Type*) [Fintype F]
    [DecidableEq F] [Fintype σ] [DecidableEq σ] (hDegree : 0 < P.degreeBound) (hlength : 0 < Fintype.card ι)
    (hk : P.degreeBound ≤ Fintype.card ι) : Fintype.card F ^ Fintype.card σ ≤ (P.vectorBlockCode
    σ).ballCardAt (BlockCode.relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound + 1)) 0 := by sorry

end ReedSolomon.Parameters
namespace CapacityList

end CapacityList
namespace FiniteThreshold

/-- The finite natural-number radius grid from zero through `n`. -/
def grid (n : ℕ) : Finset ℕ := Finset.range (n + 1)

/-- The radii on the finite grid at which `Good` holds. -/
noncomputable def safeSet (n : ℕ) (Good : ℕ → Prop) : Finset ℕ := by
  classical
  exact (grid n).filter Good

/-- The radii on the finite grid at which `Good` fails. -/
noncomputable def unsafeSet (n : ℕ) (Good : ℕ → Prop) : Finset ℕ := by
  classical
  exact (grid n).filter fun r => ¬ Good r

/-- The greatest safe grid radius, or `⊥` when no grid radius is safe. -/
noncomputable def greatestSafe (n : ℕ) (Good : ℕ → Prop) : WithBot ℕ := (safeSet n Good).max

/-- The first unsafe grid radius, or `⊤` when every grid radius is safe. -/
noncomputable def firstUnsafe (n : ℕ) (Good : ℕ → Prop) : WithTop ℕ := (unsafeSet n Good).min

end FiniteThreshold
namespace ReedSolomon.Parameters
open BlockCode CapacityList
variable {F ι σ : Type*} [Field F] [Fintype F] [DecidableEq F]
variable [Fintype ι] [Fintype σ] [Nonempty σ]

theorem vectorFractionalListPhaseSplit (P : ReedSolomon.Parameters F ι) {ε : ℝ} (hε : ε < 1) (hDegree : 0 <
    P.degreeBound) (hn : 0 < Fintype.card ι) (hk : P.degreeBound ≤ Fintype.card ι) : (ε * Fintype.card F < 1
    → ∀ δ : ℝ, 0 ≤ δ → ¬ FractionalListSizeBoundAt (P.vectorBlockCode σ) δ ε (Fintype.card F)) ∧ ((1 ≤ ε *
    Fintype.card F ∧ ε * Fintype.card F < (Nat.choose (Fintype.card ι) P.degreeBound : ℝ)) →
    FractionalListSizeBoundAt (P.vectorBlockCode σ) 0 ε (Fintype.card F) ∧ ∀ δ : ℝ, relativeRadius (ι := ι)
    (Fintype.card ι - P.degreeBound) ≤ δ → ¬ FractionalListSizeBoundAt (P.vectorBlockCode σ) δ ε
    (Fintype.card F)) ∧ ((Nat.choose (Fintype.card ι) P.degreeBound : ℝ) ≤ ε * Fintype.card F →
    safeRelativeRadii (P.vectorBlockCode σ) ε (Fintype.card F) = Set.Ico 0 (relativeRadius (ι := ι)
    (Fintype.card ι - P.degreeBound + 1))) := by sorry

theorem vectorFractionalListGridThreshold (P : ReedSolomon.Parameters F ι) {ε : ℝ} (hε : ε < 1) (hDegree : 0
    < P.degreeBound) (hn : 0 < Fintype.card ι) (hk : P.degreeBound ≤ Fintype.card ι) (hbudget : (Nat.choose
    (Fintype.card ι) P.degreeBound : ℝ) ≤ ε * Fintype.card F) : FiniteThreshold.greatestSafe (Fintype.card
    ι) (fun r => FractionalListSizeBoundAt (P.vectorBlockCode σ) (relativeRadius (ι := ι) r) ε (Fintype.card
    F)) = ((Fintype.card ι - P.degreeBound : ℕ) : WithBot ℕ) ∧ FiniteThreshold.firstUnsafe (Fintype.card ι)
    (fun r => FractionalListSizeBoundAt (P.vectorBlockCode σ) (relativeRadius (ι := ι) r) ε (Fintype.card
    F)) = ((Fintype.card ι - P.degreeBound + 1 : ℕ) : WithTop ℕ) := by sorry

theorem vectorFractionalListRealThreshold (P : ReedSolomon.Parameters F ι) {ε : ℝ} (hε : ε < 1) (hDegree : 0
    < P.degreeBound) (hn : 0 < Fintype.card ι) (hk : P.degreeBound ≤ Fintype.card ι) (hbudget : (Nat.choose
    (Fintype.card ι) P.degreeBound : ℝ) ≤ ε * Fintype.card F) : sSup (safeRelativeRadii (P.vectorBlockCode
    σ) ε (Fintype.card F)) = relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound + 1) ∧ relativeRadius
    (ι := ι) (Fintype.card ι - P.degreeBound + 1) ∉ safeRelativeRadii (P.vectorBlockCode σ) ε (Fintype.card
    F) ∧ ¬ ∃ δ, IsGreatest (safeRelativeRadii (P.vectorBlockCode σ) ε (Fintype.card F)) δ := by sorry

end ReedSolomon.Parameters
namespace BlockCode
section AgreementSets
variable {ι α : Type*} [Fintype ι]

/-- The count-radius condition that at most `r` coordinates lie outside the set. -/
def LargeAgreementSet (r : ℕ) (S : Finset ι) : Prop := Fintype.card ι ≤ S.card + r

/-- The cardinality of the coordinate set divided by the block length. -/
noncomputable def coordinateFraction (S : Finset ι) : ℝ := (S.card : ℝ) / (Fintype.card ι : ℝ)

/-- The relative-radius condition that the coordinate fraction is at least `1 - δ`. -/
def LargeAgreementSetAt (δ : ℝ) (S : Finset ι) : Prop := 1 - δ ≤ coordinateFraction S

/-- The two words agree at every coordinate in the specified set. -/
def AgreesOn (w c : Word ι α) (S : Finset ι) : Prop := ∀ i : ι, i ∈ S → w i = c i

/-- Some codeword agrees with the received word on the specified coordinate set. -/
def CloseOnSet (C : BlockCode ι α) (w : Word ι α) (S : Finset ι) : Prop := ∃ c : Word ι α, C.Codeword c ∧
  AgreesOn w c S

end AgreementSets
section PairWords
variable {ι F : Type*}

/- Preserve the canonical source module’s auxiliary-proof boundary. -/
run_cmd Lean.modifyEnv fun env => Lean.Meta.auxLemmasExt.setState env {}
/-- The two-column word formed from an affine line’s base and direction. -/
def pairWord (L : AffineLine ι F) : PlaneWord ι F := fun i j => if j = 0 then L.base i else L.direction i

/-- The base and direction fit an interleaved codeword on the same coordinate set. -/
def PairCloseOnSet (C : BlockCode ι F) (L : AffineLine ι F) (S : Finset ι) : Prop := (C.interleaved (Fin
  2)).CloseOnSet (pairWord L) S

end PairWords
section BadChallenges
variable {ι F : Type*} [Fintype ι] [Fintype F] [Add F] [Mul F]

/-- The scalar challenge fits the code on a set where the base/direction pair does not. -/
def BadOnSet (C : BlockCode ι F) (L : AffineLine ι F) (γ : F) (S : Finset ι) : Prop := C.CloseOnSet (L.point
  γ) S ∧ ¬ C.PairCloseOnSet L S

/-- The challenges admitting a same-set MCA failure at the given count radius. -/
noncomputable def badChallengeSet
    (C : BlockCode ι F)
    (r : ℕ)
    (L : AffineLine ι F) : Finset F := by
  classical
  exact Finset.univ.filter fun γ =>
    ∃ S : Finset ι, LargeAgreementSet r S ∧ C.BadOnSet L γ S

/-- The challenges admitting a same-set MCA failure at the given relative radius. -/
noncomputable def badChallengeSetAt
    (C : BlockCode ι F)
    (δ : ℝ)
    (L : AffineLine ι F) : Finset F := by
  classical
  exact Finset.univ.filter fun γ =>
    ∃ S : Finset ι, LargeAgreementSetAt δ S ∧ C.BadOnSet L γ S

/-- The number of selected challenges divided by the challenge-type cardinality. -/
noncomputable def challengeFraction (S : Finset F) : ℝ := (S.card : ℝ) / (Fintype.card F : ℝ)

/-- Every affine line has relative-radius bad-challenge fraction at most `ε`. -/
def PairMCAErrorBoundAt (C : BlockCode ι F) (δ ε : ℝ) : Prop := ∀ L : AffineLine ι F, challengeFraction
  (C.badChallengeSetAt δ L) ≤ ε

/-- The finite supremum of bad-challenge counts over all ambient plane presentations. -/
noncomputable def worstBadCount
    (C : BlockCode ι F)
    (r : ℕ) : ℕ := by
  classical
  exact Finset.univ.sup fun p : PlaneWord ι F =>
    (C.badChallengeSet r (planeLineEquiv ι F p)).card

/-- The paper’s abbreviation for the exact worst bad-challenge count at radius `r`. -/
noncomputable abbrev paperMCABadSpectrum (C : BlockCode ι F) (r : ℕ) : ℕ := C.worstBadCount r

/-- The integer budget `2 ^ securityBits * worstBadCount ≤ |F|` at the count radius. -/
def PairMCASecureAtBits (C : BlockCode ι F) (securityBits r : ℕ) : Prop := 2 ^ securityBits *
  C.worstBadCount r ≤ Fintype.card F

/-- The greatest count-grid radius satisfying the integer MCA budget, or `⊥`. -/
noncomputable def pairMCAGreatestSafe (C : BlockCode ι F) (securityBits : ℕ) : WithBot ℕ :=
  FiniteThreshold.greatestSafe (Fintype.card ι) (C.PairMCASecureAtBits securityBits)

/-- The first count-grid radius failing the integer MCA budget, or `⊤`. -/
noncomputable def pairMCAFirstUnsafe (C : BlockCode ι F) (securityBits : ℕ) : WithTop ℕ :=
  FiniteThreshold.firstUnsafe (Fintype.card ι) (C.PairMCASecureAtBits securityBits)

/-- The nonnegative real radii with MCA bad-challenge fraction at most `2⁻ᵇ`. -/
def pairMCASafeRelativeRadii (C : BlockCode ι F) (bits : ℕ) : Set ℝ := {δ | 0 ≤ δ ∧ C.PairMCAErrorBoundAt δ
  ((1 : ℝ) / 2 ^ bits)}

theorem pairMCAErrorBoundAt_relativeRadius_invPow_iff_spectrum_budget [Nonempty F] (C : BlockCode ι F) {r
    securityBits : ℕ} (hlength : 0 < Fintype.card ι) : C.PairMCAErrorBoundAt (relativeRadius (ι := ι) r) ((1
    : ℝ) / (2 ^ securityBits : ℝ)) ↔ 2 ^ securityBits * C.paperMCABadSpectrum r ≤ Fintype.card F := by sorry

theorem pairMCAThreshold_eq_of_countBound_and_badLine (C : BlockCode ι F) {securityBits radius upperBound :
    ℕ} (hradius : radius < Fintype.card ι) (hcount : ∀ L : AffineLine ι F, (C.badChallengeSet radius L).card
    ≤ upperBound) (hbudget : 2 ^ securityBits * upperBound ≤ Fintype.card F) (Lnext : AffineLine ι F) (hnext
    : Fintype.card F < 2 ^ securityBits * (C.badChallengeSet (radius + 1) Lnext).card) :
    C.pairMCAGreatestSafe securityBits = (radius : WithBot ℕ) ∧ C.pairMCAFirstUnsafe securityBits = ((radius
    + 1 : ℕ) : WithTop ℕ) := by sorry

end BadChallenges
section GoodChallenge
variable {ι F : Type*} [Fintype ι] [Fintype F] [DecidableEq F] [Add F] [Mul F]

theorem scalarDistance_ge_of_pairDistance_ge_of_good (C : BlockCode ι F) (hC : ∃ c, C.Codeword c) (hlength :
    0 < Fintype.card ι) (δ : ℝ) (L : AffineLine ι F) (γ : F) (hgood : γ ∉ C.badChallengeSetAt δ L) (hfar : δ
    ≤ (C.interleaved (Fin 2)).relativeDistanceToCode (pairWord L)) : δ ≤ C.relativeDistanceToCode (L.point
    γ) := by sorry

end GoodChallenge
end BlockCode
namespace ReedSolomon.Parameters
open BlockCode
variable {F ι : Type*} [Field F] [Fintype F] [DecidableEq F]
variable [Fintype ι] [DecidableEq ι]

/-- The challenges admitting a same-set MCA failure at the given relative radius. -/
noncomputable abbrev badChallengeSetAt (P : ReedSolomon.Parameters F ι) (δ : ℝ) (L : AffineLine ι F) :
  Finset F := P.toBlockCode.badChallengeSetAt δ L

/-- The number of selected challenges divided by the challenge-type cardinality. -/
noncomputable abbrev challengeFraction (S : Finset F) : ℝ := BlockCode.challengeFraction S

/-- Every affine line has relative-radius bad-challenge fraction at most `ε`. -/
abbrev PairMCAErrorBoundAt (P : ReedSolomon.Parameters F ι) (δ ε : ℝ) : Prop :=
  P.toBlockCode.PairMCAErrorBoundAt δ ε

theorem badChallengeSetAt_card_le_choose_succ (P : ReedSolomon.Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) (δ : ℝ) (L : AffineLine ι F) : (P.badChallengeSetAt δ L).card ≤
    Nat.choose (Fintype.card ι) (P.degreeBound + 1) := by sorry

theorem pairMCAErrorBoundAt_of_compressed_budget (P : ReedSolomon.Parameters F ι) (hDegree : 0 <
    P.degreeBound) (hk : P.degreeBound ≤ Fintype.card ι) (δ ε : ℝ) (hbudget : (Nat.choose (Fintype.card ι)
    (P.degreeBound + 1) : ℝ) ≤ ε * Fintype.card F) : P.PairMCAErrorBoundAt δ ε := by sorry

theorem scalarDistance_eq_capacity_of_pairFar_of_good (P : ReedSolomon.Parameters F ι) (hDegree : 0 <
    P.degreeBound) (hk : P.degreeBound ≤ Fintype.card ι) (L : AffineLine ι F) (γ : F) (hgood : γ ∉
    P.badChallengeSetAt (relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound)) L) (hfar : relativeRadius
    (ι := ι) (Fintype.card ι - P.degreeBound) ≤ (P.vectorBlockCode (Fin 2)).relativeDistanceToCode (pairWord
    L)) : P.toBlockCode.relativeDistanceToCode (L.point γ) = relativeRadius (ι := ι) (Fintype.card ι -
    P.degreeBound) := by sorry

/-- The received word evaluating `X^k` on the actual evaluation domain. -/
def powerReceivedWord (P : Parameters F ι) : Word ι F := fun i => P.domain.point i ^ P.degreeBound

/-- The two-column word repeating the degree-`k` power word in both columns. -/
def diagonalPowerPair (P : Parameters F ι) : Word ι (Fin 2 → F) := fun i _ => P.powerReceivedWord i

/-- The affine line with the degree-`k` power word as base and zero direction. -/
def zeroDirectionPowerLine (P : Parameters F ι) : AffineLine ι F where
  base := P.powerReceivedWord
  direction := 0

theorem zeroDirectionPowerLine_pairDistance_eq_capacity (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) : (P.vectorBlockCode (Fin 2)).relativeDistanceToCode (pairWord
    P.zeroDirectionPowerLine) = relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound) := by sorry

theorem zeroDirectionPowerLine_flatDistance_eq_half_capacity (P : Parameters F ι) (hDegree : 0 <
    P.degreeBound) (hk : P.degreeBound ≤ Fintype.card ι) :
    P.toBlockCode.flattenedPairCode.relativeDistanceToCode (flattenPair (pairWord P.zeroDirectionPowerLine))
    = relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound) / 2 := by sorry

theorem no_unit_pair_distance_bound_by_flat_distance (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hproper : P.degreeBound < Fintype.card ι) : ¬ (∀ w : Word ι (Fin 2 → F), (P.vectorBlockCode (Fin
    2)).relativeDistanceToCode w ≤ P.toBlockCode.flattenedPairCode.relativeDistanceToCode (flattenPair w))
    := by sorry

theorem no_fixedChallenge_pair_far_preservation (P : Parameters F ι) (hDegree : 0 < P.degreeBound) (hk :
    P.degreeBound ≤ Fintype.card ι) (γ₀ : F) (hγ : γ₀ ≠ 0) (sourceRadius targetRadius : ℝ) (hsource :
    sourceRadius ≤ relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound)) (htarget : 0 < targetRadius) :
    ¬ (∀ L : AffineLine ι F, sourceRadius ≤ (P.vectorBlockCode (Fin 2)).relativeDistanceToCode (pairWord L)
    → targetRadius ≤ P.toBlockCode.relativeDistanceToCode (L.point γ₀)) := by sorry

theorem no_fixedChallenge_flat_far_preservation (P : Parameters F ι) (hDegree : 0 < P.degreeBound) (hk :
    P.degreeBound ≤ Fintype.card ι) (γ₀ : F) (hγ : γ₀ ≠ 0) (sourceRadius targetRadius : ℝ) (hsource :
    sourceRadius ≤ relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound)) (htarget : 0 < targetRadius) :
    ¬ (∀ L : AffineLine ι F, sourceRadius ≤ (flattenedPairCode P.toBlockCode).relativeDistanceToCode
    (flattenPair (pairWord L)) → targetRadius ≤ P.toBlockCode.relativeDistanceToCode (L.point γ₀)) := by
    sorry

end ReedSolomon.Parameters
end ProximityPrize

namespace Hcrypt.Palomar.PaperThree
open ProximityPrize
/-- Both inverse laws hold on all ambient plane and pair words. -/
theorem planePairEquiv_inverse_laws {ι F : Type*} :
    (∀ p : PlaneWord ι F, (planePairEquiv ι F).symm (planePairEquiv ι F p) = p) ∧
    (∀ w : PairWord ι F, planePairEquiv ι F ((planePairEquiv ι F).symm w) = w) := by sorry
/-- Both inverse laws hold on all ambient planes and arbitrary affine lines. -/
theorem planeLineEquiv_inverse_laws {ι F : Type*} :
    (∀ p : PlaneWord ι F, (planeLineEquiv ι F).symm (planeLineEquiv ι F p) = p) ∧
    (∀ L : AffineLine ι F, planeLineEquiv ι F ((planeLineEquiv ι F).symm L) = L) := by sorry
end Hcrypt.Palomar.PaperThree

namespace ProximityPrize
namespace Capacity.SmoothQuarterFamily
noncomputable section

/-- The family length is 256 times a power of two. -/
def length (u : ℕ) : ℕ :=
  256 * 2 ^ u

/-- The family degree bound is one quarter of its length. -/
def degreeBound (u : ℕ) : ℕ :=
  64 * 2 ^ u

/-- The prescribed field cardinality is three to the family length. -/
def fieldCard (u : ℕ) : ℕ :=
  3 ^ length u

/-- Each member has positive length. -/
theorem length_pos (u : ℕ) : 0 < length u := by sorry

/-- Every block length is a power of two. -/
theorem length_eq_two_pow (u : ℕ) : length u = 2 ^ (u + 8) := by sorry

/-- The base characteristic is the certified prime three. -/
instance prime_three_fact : Fact (Nat.Prime 3) := ⟨Nat.prime_three⟩

/-- The actual degree-length extension of the three-element field. -/
abbrev RSField (u : ℕ) := GaloisField 3 (length u)

/-- The canonical finite enumeration of the constructed Galois field. -/
instance fieldFintype (u : ℕ) : Fintype (RSField u) := Fintype.ofFinite _

/-- Classical equality on the constructed field. -/
instance fieldDecidableEq (u : ℕ) : DecidableEq (RSField u) := Classical.decEq _

/-- The constructed field has exactly the prescribed cardinality. -/
@[simp]
theorem card_RSField (u : ℕ) : Fintype.card (RSField u) = fieldCard u := by sorry

/-- A chosen generator of the full cyclic multiplicative group. -/
def generator (u : ℕ) : (RSField u)ˣ :=
  Classical.choose (IsCyclic.exists_ofOrder_eq_natCard (α := (RSField u)ˣ))

/-- The chosen generator has the full multiplicative order. -/
theorem generator_order (u : ℕ) : orderOf (generator u) = fieldCard u - 1 := by sorry

/-- The full generator raised to the subgroup-order cofactor. -/
def rootUnit (u : ℕ) : (RSField u)ˣ :=
  generator u ^ ((fieldCard u - 1) / length u)

/-- The subgroup generator has exactly the block length as its order. -/
theorem rootUnit_order (u : ℕ) : orderOf (rootUnit u) = length u := by sorry

/-- The multiplicative subgroup generated by the selected root. -/
def evaluationSubgroup (u : ℕ) : Subgroup (RSField u)ˣ :=
  Subgroup.zpowers (rootUnit u)

/-- The evaluation subgroup has exactly the block length as its cardinality. -/
theorem card_evaluationSubgroup (u : ℕ) :
    Nat.card (evaluationSubgroup u) = length u := by sorry

/-- The indexed unit powers exhaust exactly the evaluation subgroup. -/
theorem mem_evaluationSubgroup_iff (u : ℕ) (x : (RSField u)ˣ) :
    x ∈ evaluationSubgroup u ↔
      ∃ i : Fin (length u), rootUnit u ^ (i : ℕ) = x := by sorry

/-- The evaluation point at an index is the corresponding root power. -/
def point (u : ℕ) (i : Fin (length u)) : RSField u :=
  (rootUnit u ^ (i : ℕ) : RSField u)

/-- The indexed root powers are pairwise distinct. -/
theorem injective_point (u : ℕ) : Function.Injective (point u) := by sorry

/-- The actual injective evaluation domain supplied to Reed--Solomon. -/
def evaluationDomain (u : ℕ) :
    ReedSolomon.EvaluationDomain (RSField u) (Fin (length u)) where
  point := point u
  injective_point := injective_point u

/-- The same domain with its power-of-two and exact-order proposition. -/
def smoothEvaluationDomain (u : ℕ) :
    ReedSolomon.SmoothEvaluationDomain (RSField u) (Fin (length u)) where
  toEvaluationDomain := evaluationDomain u
  smooth := length u = 2 ^ (u + 8) ∧ orderOf (rootUnit u) = length u

/-- The actual evaluation domain satisfies its stated smoothness proposition. -/
theorem smoothEvaluationDomain_smooth (u : ℕ) :
    (smoothEvaluationDomain u).smooth := by sorry

/-- The actual quarter-rate Reed--Solomon family on this power domain. -/
def parameters (u : ℕ) : ReedSolomon.Parameters (RSField u) (Fin (length u)) where
  domain := evaluationDomain u
  degreeBound := degreeBound u

/-- Every positive-width family member meets the capacity-grid list target. -/
theorem realized_fractionalListSizeBoundAt_capacity
    (u : ℕ) (σ : Type*) [Fintype σ] [DecidableEq σ] (j₀ : σ) :
    CapacityList.FractionalListSizeBoundAt
      ((parameters u).vectorBlockCode σ)
      (BlockCode.relativeRadius (ι := Fin (length u))
        (length u - degreeBound u))
      ((1 : ℝ) / 2 ^ 128) (fieldCard u) := by sorry

/-- Every family member meets the 128-bit MCA target at every real radius. -/
theorem realized_pairMCAErrorBoundAt (u : ℕ) (δ : ℝ) :
    (parameters u).PairMCAErrorBoundAt δ ((1 : ℝ) / 2 ^ 128) := by sorry

/-- The constructed family has full-length greatest safe MCA count. -/
theorem realized_pairMCAGreatestSafe_eq_length (u : ℕ) :
    (parameters u).toBlockCode.pairMCAGreatestSafe 128 = (length u : WithBot ℕ) := by sorry

open BlockCode CapacityList

/-- The exact real list-safe set is the half-open interval up to the next shell. -/
theorem realized_listSafeRelativeRadii_eq_Ico
    (u : ℕ) (σ : Type*) [Fintype σ] [Nonempty σ] :
    safeRelativeRadii ((parameters u).vectorBlockCode σ)
        ((1 : ℝ) / 2 ^ 128) (fieldCard u) =
      Set.Ico 0 (BlockCode.relativeRadius (ι := Fin (length u))
        (length u - degreeBound u + 1)) := by sorry

/-- The list-safe and first-unsafe count endpoints are both exact. -/
theorem realized_listGridThreshold
    (u : ℕ) (σ : Type*) [Fintype σ] [Nonempty σ] :
    FiniteThreshold.greatestSafe (length u)
        (fun r => FractionalListSizeBoundAt ((parameters u).vectorBlockCode σ)
          (BlockCode.relativeRadius (ι := Fin (length u)) r)
          ((1 : ℝ) / 2 ^ 128) (fieldCard u)) =
      ((length u - degreeBound u : ℕ) : WithBot ℕ) ∧
    FiniteThreshold.firstUnsafe (length u)
        (fun r => FractionalListSizeBoundAt ((parameters u).vectorBlockCode σ)
          (BlockCode.relativeRadius (ι := Fin (length u)) r)
          ((1 : ℝ) / 2 ^ 128) (fieldCard u)) =
      ((length u - degreeBound u + 1 : ℕ) : WithTop ℕ) := by sorry

/-- The real safe supremum is excluded and no greatest safe radius exists. -/
theorem realized_listRealThreshold
    (u : ℕ) (σ : Type*) [Fintype σ] [Nonempty σ] :
    sSup (safeRelativeRadii ((parameters u).vectorBlockCode σ)
        ((1 : ℝ) / 2 ^ 128) (fieldCard u)) =
        BlockCode.relativeRadius (ι := Fin (length u)) (length u - degreeBound u + 1) ∧
      BlockCode.relativeRadius (ι := Fin (length u)) (length u - degreeBound u + 1) ∉
        safeRelativeRadii ((parameters u).vectorBlockCode σ)
          ((1 : ℝ) / 2 ^ 128) (fieldCard u) ∧
      ¬ ∃ δ, IsGreatest (safeRelativeRadii ((parameters u).vectorBlockCode σ)
        ((1 : ℝ) / 2 ^ 128) (fieldCard u)) δ := by sorry

end
end Capacity.SmoothQuarterFamily

namespace MCA.BoundaryField
noncomputable section

/-- The boundary modulus is the displayed integer equal to 2^128 plus 192513. -/
def modulus : ℕ :=
  340282366920938463463374607431768403969

/-- The displayed modulus has exactly the advertised offset above 2^128. -/
theorem modulus_eq_two_pow_128_add :
    modulus = 2 ^ 128 + 192513 := by sorry

/-- The boundary code has block length 4096. -/
def length : ℕ := 4096

/-- The boundary code has degree bound 1024. -/
def degreeBound : ℕ := 1024

/-- The block length divides the multiplicative-group order. -/
theorem length_dvd_modulus_sub_one :
    length ∣ modulus - 1 := by sorry

/-- The cofactor relating the full generator and length-4096 subgroup. -/
def rootExponent : ℕ :=
  (modulus - 1) / length

/-- The displayed boundary modulus is prime, without a supplied primality hypothesis. -/
theorem modulus_prime : modulus.Prime := by sorry

/-- The actual residue field at the certified boundary modulus. -/
abbrev RSField := ZMod modulus

/-- The proved primality installs the canonical residue-field structure. -/
instance modulus_prime_fact : Fact modulus.Prime :=
  ⟨modulus_prime⟩

/-- The boundary field has exactly the advertised number of elements. -/
theorem card_RSField : Fintype.card RSField = modulus := by sorry

/-- The displayed generator used in the primality and root construction. -/
def candidateGenerator : RSField := 7

/-- The displayed field element intended to have exact order 4096. -/
def candidateRoot : RSField :=
  138986559780198433259791608580824171955

/-- The displayed root is the indicated power of the full generator. -/
theorem candidateGenerator_pow_rootExponent :
    candidateGenerator ^ rootExponent = candidateRoot := by sorry

/-- The displayed root as a unit, with its original coprimality proof. -/
def candidateRootUnit : RSFieldˣ :=
  ZMod.unitOfCoprime
    138986559780198433259791608580824171955
    (by norm_num [modulus])

/-- The root unit has the advertised field value. -/
@[simp]
theorem candidateRootUnit_coe :
    (candidateRootUnit : RSField) = candidateRoot := by sorry

/-- The displayed unit has exact order 4096. -/
theorem candidateRootUnit_order :
    orderOf candidateRootUnit = length := by sorry

/-- The boundary evaluation points are the successive certified root powers. -/
def point (i : Fin length) : RSField :=
  (candidateRootUnit ^ (i : ℕ) : RSField)

/-- The first 4096 powers are pairwise distinct. -/
theorem injective_point : Function.Injective point := by sorry

/-- The actual injective boundary-field power domain. -/
def evaluationDomain :
    ReedSolomon.EvaluationDomain RSField (Fin length) where
  point := point
  injective_point := injective_point

/-- The same domain with the explicit subgroup-divisibility proposition. -/
def smoothEvaluationDomain :
    ReedSolomon.SmoothEvaluationDomain RSField (Fin length) where
  toEvaluationDomain := evaluationDomain
  smooth := length ∣ modulus - 1

/-- The boundary power domain satisfies the declared smoothness proposition. -/
theorem smoothEvaluationDomain_smooth :
    smoothEvaluationDomain.smooth := by sorry

/-- The actual quarter-rate boundary-field Reed--Solomon parameters. -/
def parameters :
    ReedSolomon.Parameters RSField (Fin length) where
  domain := evaluationDomain
  degreeBound := degreeBound

/-- At count radius one the exact bad spectrum is at least two. -/
theorem two_le_paperMCABadSpectrum_one :
    2 ≤ parameters.toBlockCode.paperMCABadSpectrum 1 := by sorry

/-- At count radius zero the exact bad spectrum is exactly one. -/
theorem paperMCABadSpectrum_zero_eq_one :
    parameters.toBlockCode.paperMCABadSpectrum 0 = 1 := by sorry

/-- The greatest-safe and first-unsafe 128-bit counts are exactly zero and one. -/
theorem pairMCA_exact_128_bit_threshold :
    parameters.toBlockCode.pairMCAGreatestSafe 128 = (0 : WithBot ℕ) ∧
      parameters.toBlockCode.pairMCAFirstUnsafe 128 =
        ((1 : ℕ) : WithTop ℕ) := by sorry

/-- The exact boundary-field real safe set is [0,1/4096). -/
theorem pairMCA_safeRelativeRadii_128_eq_Ico :
    parameters.toBlockCode.pairMCASafeRelativeRadii 128 =
      Set.Ico 0 ((1 : ℝ) / 4096) := by sorry

/-- The real safe supremum is 1/4096, excluded, with no greatest safe radius. -/
theorem pairMCA_real_128_threshold :
    sSup (parameters.toBlockCode.pairMCASafeRelativeRadii 128) = (1 : ℝ) / 4096 ∧
      (1 : ℝ) / 4096 ∉ parameters.toBlockCode.pairMCASafeRelativeRadii 128 ∧
      ¬ ∃ δ, IsGreatest (parameters.toBlockCode.pairMCASafeRelativeRadii 128) δ := by sorry

end
end MCA.BoundaryField
end ProximityPrize
