module

public import Mathlib.Analysis.InnerProductSpace.PiL2
public import Mathlib.LinearAlgebra.Lagrange
public import Mathlib.Algebra.Field.ZMod
public import Mathlib.Data.List.OfFn
public import Mathlib.Data.UInt
public import Mathlib.Data.Fintype.Sigma
public import Mathlib.Data.Fintype.EquivFin
public import Mathlib.Algebra.BigOperators.Ring.Finset
public import Mathlib.Tactic
public import Mathlib.Data.Fintype.Card
public import Mathlib.Data.Finset.Basic
public import Mathlib.Basic.Real.Basic
public import Mathlib.GroupTheory.OrderOfElement
public import Mathlib.Data.Fintype.Prod
public import Mathlib.Order.Lattice.Nat

@[expose] public section
set_option autoImplicit false
set_option maxHeartbeats 0
set_option maxRecDepth 4000
/-!
# Original cochain payloads and three native proximity distances
Independent statements retain the original Context, decoder, layout and payload.
Calibration statements unfold the existing interfaces without changing their maps.
-/
/- Minimal canonical generic parents for the separate modular application entry. -/
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

/-- An affine-line presentation consisting of a base word and a direction word. -/
structure AffineLine (ι F : Type*) where
  base : Word ι F
  direction : Word ι F

namespace AffineLine

/-- The scalar word obtained by adding `γ` times the direction to the base. -/
def point {ι F : Type*} [Add F] [Mul F] (L : AffineLine ι F) (γ : F) : Word ι F := fun i => L.base i + γ *
  L.direction i

end AffineLine
namespace ReedSolomon

/-- A field-valued vector symbol with component indices `σ`. -/
abbrev VectorSymbol (F σ : Type*) := σ → F

/-- A word whose symbols are field-valued vectors indexed by `σ`. -/
abbrev VectorWord (ι F σ : Type*) := Word ι (VectorSymbol F σ)

/-- An injectively indexed family of evaluation points. -/
structure EvaluationDomain (F ι : Type*) where
  point : ι → F
  injective_point : Function.Injective point

/-- An evaluation domain together with a natural-number polynomial degree bound. -/
structure Parameters (F ι : Type*) [Field F] [Fintype ι] where
  domain : EvaluationDomain F ι
  degreeBound : ℕ

namespace Parameters
variable {F ι : Type*} [Field F] [Fintype ι]

/-- Evaluations of a polynomial whose natural degree is below the degree bound. -/
def Codeword (P : Parameters F ι) (w : Word ι F) : Prop := ∃ p : Polynomial F, p.natDegree < P.degreeBound ∧
  ∀ i : ι, w i = Polynomial.eval (P.domain.point i) p

/-- The scalar polynomial-evaluation predicate viewed as a block code. -/
def toBlockCode (P : Parameters F ι) : BlockCode ι F where
  Codeword := P.Codeword

/-- The Reed–Solomon code interleaved over the component index type `σ`. -/
def vectorBlockCode (P : Parameters F ι) (σ : Type*) : BlockCode ι (VectorSymbol F σ) :=
  P.toBlockCode.interleaved σ

/-- Membership in the componentwise interleaving of the scalar Reed–Solomon code. -/
def VectorCodeword (P : Parameters F ι) (σ : Type*) (w : VectorWord ι F σ) : Prop := (P.vectorBlockCode
  σ).Codeword w

end Parameters
end ReedSolomon
namespace BlockCode
section AgreementSets
variable {ι α : Type*} [Fintype ι]

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

end BadChallenges
end BlockCode
namespace ReedSolomon.Parameters
variable {F ι : Type*} [Field F] [Fintype F] [DecidableEq F]
variable [Fintype ι] [DecidableEq ι]

/-- The received word evaluating `X^k` on the actual evaluation domain. -/
def powerReceivedWord (P : Parameters F ι) : Word ι F := fun i => P.domain.point i ^ P.degreeBound

/-- The two-column word repeating the degree-`k` power word in both columns. -/
def diagonalPowerPair (P : Parameters F ι) : Word ι (Fin 2 → F) := fun i _ => P.powerReceivedWord i

end ReedSolomon.Parameters
end ProximityPrize
namespace Hcrypt.Axioms

/-- The original wire commitment modulus is 12289. -/
def canonicalCochainModulus : ℕ := 12289

end Hcrypt.Axioms

namespace Hcrypt.Proximity.ReedSolomon

/-- The historical application name for the standalone injective evaluation domain. -/
abbrev EvaluationDomain (F ι : Type*) :=
  ProximityPrize.ReedSolomon.EvaluationDomain F ι

/-- The historical application name for the standalone Reed--Solomon parameters. -/
abbrev Parameters (F ι : Type*) [Field F] [Fintype ι] :=
  ProximityPrize.ReedSolomon.Parameters F ι

end Hcrypt.Proximity.ReedSolomon

namespace Hcrypt.Proximity.CanonicalRS
noncomputable section

/-- The actual residue field at the existing wire commitment modulus. -/
abbrev RSField :=
  ZMod Axioms.canonicalCochainModulus

/-- The existing kernel proof certifies the wire modulus as prime. -/
instance canonicalCochainModulus_prime :
    Fact (Nat.Prime Axioms.canonicalCochainModulus) :=
  ⟨by norm_num [Axioms.canonicalCochainModulus]⟩

/-- The canonical power domain contains 4096 evaluation points. -/
def length : ℕ := 4096

/-- The full multiplicative-group order is the modulus minus one. -/
def fullGeneratorOrder : ℕ :=
  Axioms.canonicalCochainModulus - 1

/-- Cubing descends the full generator to the chosen subgroup order. -/
def rootExponent : ℕ :=
  3

/-- The original canonical Reed--Solomon degree bound is 1024. -/
def degreeBound : ℕ := 1024

/-- The original evaluation-domain object with its explicit smoothness proposition. -/
structure SmoothDomain where
  domain : ReedSolomon.EvaluationDomain RSField (Fin length)
  smooth : Prop

namespace SmoothDomain

/-- The canonical code uses the selected domain and original degree bound. -/
def parameters (D : SmoothDomain) :
    ReedSolomon.Parameters RSField (Fin length) where
  domain := D.domain
  degreeBound := degreeBound

end SmoothDomain

/-- A unit together with its exact order-4096 certificate. -/
structure PowerRoot where
  root : RSFieldˣ
  order_eq_length : orderOf root = length

/-- A unit together with its full multiplicative-order certificate. -/
structure FullGenerator where
  generator : RSFieldˣ
  order_eq_fullGeneratorOrder : orderOf generator = fullGeneratorOrder

namespace FullGenerator

/-- The subgroup generator is the cube of the certified full generator. -/
def root (γ : FullGenerator) : RSFieldˣ :=
  γ.generator ^ rootExponent

/-- Cubing the certified full generator gives exact order 4096. -/
theorem orderOf_root (γ : FullGenerator) :
    orderOf γ.root = length := by sorry

/-- The cubed generator and proved order form the original root certificate. -/
def toPowerRoot (γ : FullGenerator) : PowerRoot where
  root := γ.root
  order_eq_length := γ.orderOf_root

end FullGenerator

namespace PowerRoot

/-- An evaluation point is the indicated power of the certified root. -/
def point (ρ : PowerRoot) (i : Fin length) : RSField :=
  (ρ.root ^ (i : ℕ) : RSField)

/-- The certified root powers are injective over the original index set. -/
theorem injective_point (ρ : PowerRoot) :
    Function.Injective ρ.point := by sorry

/-- The original injective Reed--Solomon domain assembled from root powers. -/
def domain (ρ : PowerRoot) :
    ReedSolomon.EvaluationDomain RSField (Fin length) where
  point := ρ.point
  injective_point := ρ.injective_point

/-- The same domain with the actual modulus-divisibility proposition. -/
def smoothDomain (ρ : PowerRoot) : SmoothDomain where
  domain := ρ.domain
  smooth := length ∣ Axioms.canonicalCochainModulus - 1

end PowerRoot

/-- The actual canonical full-generator field value is 11. -/
def candidateGenerator : RSField :=
  11

/-- The same generator as a unit with the original kernel coprimality proof. -/
def candidateGeneratorUnit : RSFieldˣ :=
  ZMod.unitOfCoprime
    11
    (by norm_num [Axioms.canonicalCochainModulus] : Nat.Coprime 11 Axioms.canonicalCochainModulus)

/-- The displayed generator has the full multiplicative order. -/
theorem candidateGeneratorUnit_order :
    orderOf candidateGeneratorUnit = fullGeneratorOrder := by sorry

/-- The displayed unit and proved order form the original full-generator object. -/
def candidateFullGenerator : FullGenerator where
  generator := candidateGeneratorUnit
  order_eq_fullGeneratorOrder := candidateGeneratorUnit_order

/-- The original field-valued mixing root is the cube of the generator. -/
def candidateRoot : RSField :=
  candidateGenerator ^ rootExponent

/-- The actual root certificate is obtained by cubing the full generator. -/
def canonicalPowerRoot : PowerRoot :=
  candidateFullGenerator.toPowerRoot

/-- The actual original smooth evaluation domain is induced by the certified root. -/
def canonicalSmoothDomain : SmoothDomain :=
  canonicalPowerRoot.smoothDomain

end
end Hcrypt.Proximity.CanonicalRS
noncomputable section
open scoped BigOperators RealInnerProductSpace

namespace ProximityPrize
/-- A block code closed under zero, addition and field scalar multiplication. -/
structure FAdditiveCode
    (F ι α : Type*) [Zero α] [Add α] [SMul F α]
    extends BlockCode ι α where
  zero_mem : Codeword fun _ => 0
  add_mem :
    ∀ {u v : Word ι α},
      Codeword u → Codeword v → Codeword fun i => u i + v i
  smul_mem :
    ∀ (a : F) {u : Word ι α},
      Codeword u → Codeword fun i => a • u i
end ProximityPrize
namespace ProximityPrize.FAdditiveCode
variable {F ι α : Type*} [Zero α] [Add α] [SMul F α]
/-- The underlying block-code predicate of an additive code. -/
abbrev asBlockCode (C : FAdditiveCode F ι α) : BlockCode ι α :=
  C.toBlockCode
end ProximityPrize.FAdditiveCode
namespace ProximityPrize.ReedSolomon.Parameters
variable {F ι : Type*} [Field F] [Fintype ι]
/-- Field-linear closure of the scalar Reed–Solomon code. -/
structure FAdditive (P : Parameters F ι) : Prop where
  zero_mem : P.Codeword fun _ => 0
  add_mem :
    ∀ {u v : Word ι F},
      P.Codeword u → P.Codeword v →
        P.Codeword fun i => u i + v i
  smul_mem :
    ∀ (a : F) {u : Word ι F},
      P.Codeword u → P.Codeword fun i => a • u i
/-- Positive degree bound supplies actual field-linear closure. -/
theorem fAdditive_of_degreeBound_pos
    (P : Parameters F ι)
    (hDegree : 0 < P.degreeBound) :
    P.FAdditive := by sorry
end ProximityPrize.ReedSolomon.Parameters
namespace ProximityPrize.ReedSolomon.Parameters.FAdditive
variable {F ι : Type*} [Field F] [Fintype ι]
/-- The additive-code interface for these same scalar RS codewords. -/
def toFAdditiveCode
    {P : Parameters F ι}
    (hP : P.FAdditive) :
    FAdditiveCode F ι F where
  Codeword := P.Codeword
  zero_mem := hP.zero_mem
  add_mem := hP.add_mem
  smul_mem := hP.smul_mem
end ProximityPrize.ReedSolomon.Parameters.FAdditive
namespace ProximityPrize.ReedSolomon.Parameters
open BlockCode
variable {F ι : Type*} [Field F] [Fintype F] [DecidableEq F] [Fintype ι] [DecidableEq ι]
/-- The actual Lagrange interpolant on the specified information positions. -/
noncomputable def interpolatePolynomial
    (P : ReedSolomon.Parameters F ι)
    (S : Finset ι)
    (w : Word ι F) : Polynomial F :=
  Lagrange.interpolate S P.domain.point w
/-- Evaluation of that Lagrange interpolant on the original domain. -/
noncomputable def interpolateWord
    (P : ReedSolomon.Parameters F ι)
    (S : Finset ι)
    (w : Word ι F) : Word ι F :=
  fun i => Polynomial.eval (P.domain.point i)
    (P.interpolatePolynomial S w)
/-- The actual interpolation coefficient for one information coordinate. -/
def informationCoefficient (P : Parameters F ι) (S : Finset ι)
    (i : ι) (a : {a // a ∈ S}) : F :=
  P.interpolateWord S (fun j => if j = a.val then 1 else 0) i
end ProximityPrize.ReedSolomon.Parameters
namespace ProximityPrize.ReedSolomon.Parameters
variable {q : ℕ} [Fact q.Prime] {ι : Type*} [Fintype ι] [DecidableEq ι]
/-- Canonical integer lifts of the finite-field interpolation coefficients. -/
def integerCoefficient (P : Parameters (ZMod q) ι) (S : Finset ι)
    (i : ι) (a : {a // a ∈ S}) : ℤ :=
  (P.informationCoefficient S i a).val
/-- The real encoder with the same integer-lifted interpolation coefficients. -/
def realEncode (P : Parameters (ZMod q) ι) (S : Finset ι)
    (data : {a // a ∈ S} → ℝ) : ι → ℝ :=
  fun i => ∑ a, data a * (P.integerCoefficient S i a : ℝ)
end ProximityPrize.ReedSolomon.Parameters
namespace Hcrypt.Axioms
/-- Original cochain payload: modulus, declared count, full integer list and topology tag. -/
structure CochainCommitmentData where
  modulus : ℕ
  n_edge_values : ℕ
  edge_values : List ℤ
  topology_hash : Fin 16 → UInt8
end Hcrypt.Axioms
namespace Hcrypt.Axioms.CochainCommitmentData
/-- The declared coordinate count equals the list length. -/
def EdgeCountMatches (c : CochainCommitmentData) : Prop :=
  c.n_edge_values = c.edge_values.length
/-- The payload declares at least one coordinate. -/
def NonemptyEdges (c : CochainCommitmentData) : Prop :=
  0 < c.n_edge_values
/-- The payload uses the existing canonical modulus. -/
def SupportedModulus (c : CochainCommitmentData) : Prop :=
  c.modulus = canonicalCochainModulus
/-- The existing wire-shape predicate; it does not assert exactness or authentication. -/
def WellFormed (c : CochainCommitmentData) : Prop :=
  SupportedModulus c ∧ EdgeCountMatches c ∧ NonemptyEdges c
end Hcrypt.Axioms.CochainCommitmentData
namespace Hcrypt.TCB
/-- The original 32-byte public hash carrier. -/
abbrev Hash32 := Fin 32 → UInt8
/-- The original payload and digest with an explicitly supplied binding proposition. -/
structure HashedCommittedCochain where
  cochain : Axioms.CochainCommitmentData
  digest : Hash32
  Binds : Prop
/-- Payload well-formedness together with the supplied binding proposition. -/
def HashedCommittedCochain.WellFormed
    (H : HashedCommittedCochain) : Prop :=
  H.cochain.WellFormed ∧ H.Binds
end Hcrypt.TCB
namespace Hcrypt.Sheaf
/-- Integer cellular incidences satisfying their actual boundary-square equation. -/
structure OrientedTwoComplex
    (Vertex Edge Face : Type*)
    [Fintype Vertex] [Fintype Edge] [Fintype Face] where
  incidence01 : Vertex → Edge → ℤ
  incidence12 : Edge → Face → ℤ
  boundarySqZero :
    ∀ v f,
      (Finset.univ : Finset Edge).sum
        (fun e => incidence01 v e * incidence12 e f) = 0
/-- A real Euclidean coordinate stalk. -/
abbrev Coord (n : ℕ) := EuclideanSpace ℝ (Fin n)
end Hcrypt.Sheaf
universe u_1 u_2 u_3
variable {Vertex : Type u_1} {Edge : Type u_2} {Face : Type u_3}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : Hcrypt.Sheaf.OrientedTwoComplex Vertex Edge Face}
namespace Hcrypt.Sheaf.OrientedTwoComplex
variable (X : OrientedTwoComplex Vertex Edge Face)
/-- A vertex-edge incidence is present when its integer incidence is nonzero. -/
def VertexEdgeIncident (v : Vertex) (e : Edge) : Prop :=
  X.incidence01 v e ≠ 0
/-- An edge-face incidence is present when its integer incidence is nonzero. -/
def EdgeFaceIncident (e : Edge) (f : Face) : Prop :=
  X.incidence12 e f ≠ 0
/-- The actual vertex-edge incidence cast to the real coefficient field. -/
def incidence01Real (v : Vertex) (e : Edge) : ℝ :=
  X.incidence01 v e
end Hcrypt.Sheaf.OrientedTwoComplex
namespace Hcrypt.Sheaf
/-- Finite stalks and restriction maps composing on incident cellular flags. -/
structure CellularSheaf
    {Vertex : Type u_1} {Edge : Type u_2} {Face : Type u_3}
    [Fintype Vertex] [Fintype Edge] [Fintype Face]
    (X : OrientedTwoComplex Vertex Edge Face) where
  vertexDim : Vertex → ℕ
  edgeDim : Edge → ℕ
  faceDim : Face → ℕ
  restrict01 :
    ∀ v e, Coord (vertexDim v) →ₗ[ℝ] Coord (edgeDim e)
  restrict12 :
    ∀ e f, Coord (edgeDim e) →ₗ[ℝ] Coord (faceDim f)
  restrict02 :
    ∀ v f, Coord (vertexDim v) →ₗ[ℝ] Coord (faceDim f)
  restrictionComp :
    ∀ v e f,
      X.VertexEdgeIncident v e →
      X.EdgeFaceIncident e f →
      (restrict12 e f).comp (restrict01 v e) = restrict02 v f
end Hcrypt.Sheaf
open Hcrypt.Sheaf Hcrypt.Sheaf.CellularSheaf
namespace Hcrypt.Sheaf.CellularSheaf
/-- Flattened stalk coordinates indexed by their cells. -/
abbrev TotalCoord (Cell : Type*) (dim : Cell → ℕ) :=
  Σ c : Cell, Fin (dim c)
/-- The real Euclidean product of all stalk coordinates in one cellular degree. -/
abbrev Cochain (Cell : Type*) [Fintype Cell] (dim : Cell → ℕ) :=
  EuclideanSpace ℝ (TotalCoord Cell dim)
/-- Actual degree-zero cellular cochains. -/
abbrev C0 (F : CellularSheaf X) := Cochain Vertex F.vertexDim
/-- Actual degree-one cellular cochains. -/
abbrev C1 (F : CellularSheaf X) := Cochain Edge F.edgeDim
/-- Projection of a full cochain onto one stalk. -/
def component
    {Cell : Type*} [Fintype Cell]
    (dim : Cell → ℕ) (c : Cell) :
    Cochain Cell dim →ₗ[ℝ] Coord (dim c) where
  toFun x := WithLp.toLp 2 (fun i => x ⟨c, i⟩)
  map_add' _ _ := rfl
  map_smul' _ _ := rfl
/-- Assembly of stalk-valued block rows into the full cochain map. -/
def assemble
    {Cell A : Type*} [Fintype Cell]
    [AddCommMonoid A] [Module ℝ A]
    (dim : Cell → ℕ)
    (L : ∀ c, A →ₗ[ℝ] Coord (dim c)) :
    A →ₗ[ℝ] Cochain Cell dim where
  toFun x := WithLp.toLp 2 (fun p : TotalCoord Cell dim => L p.1 x p.2)
  map_add' x y := by
    apply PiLp.ext
    intro p
    simp
  map_smul' a x := by
    apply PiLp.ext
    intro p
    simp
/-- The incidence-weighted vertex-to-edge restriction sum. -/
def delta0At (F : CellularSheaf X) (e : Edge) :
    F.C0 →ₗ[ℝ] Coord (F.edgeDim e) :=
  (Finset.univ : Finset Vertex).sum fun v =>
    X.incidence01Real v e •
      (F.restrict01 v e).comp (component F.vertexDim v)
/-- The original cellular degree-zero coboundary. -/
def delta0 (F : CellularSheaf X) : F.C0 →ₗ[ℝ] F.C1 :=
  assemble F.edgeDim (delta0At F)
/-- The number of original scalar edge-stalk coordinates. -/
def edgeCoordinateCount (F : CellularSheaf X) : ℕ :=
  Fintype.card (TotalCoord Edge F.edgeDim)
/-- The original snapshot name with explicit canonical-encoding and sheaf-binding propositions. -/
structure SheafStateSnapshot (F : CellularSheaf X) where
  schemaVersion : ℕ
  root : Fin 32 → UInt8
  topologyHash : Fin 16 → UInt8
  CanonicallyEncoded : Prop
  RootBindsCellularSheaf : Prop
/-- The actual snapshot, payload decoder and external snapshot-binding predicate. -/
structure CochainPayloadInterpretation (F : CellularSheaf X) where
  snapshot : SheafStateSnapshot F
  decode : Axioms.CochainCommitmentData → F.C1
  /-- External payload/snapshot authentication; the topology tag alone does not establish it. -/
  PayloadBindsSnapshot : Axioms.CochainCommitmentData → Prop
end Hcrypt.Sheaf.CellularSheaf
namespace Hcrypt.Sheaf.CellularSheaf.SheafStateSnapshot
/-- The snapshot canonical-encoding and cellular-sheaf binding obligations. -/
def WellFormed {F : CellularSheaf X} (s : SheafStateSnapshot F) : Prop :=
  s.CanonicallyEncoded ∧ s.RootBindsCellularSheaf
end Hcrypt.Sheaf.CellularSheaf.SheafStateSnapshot
namespace Hcrypt.Sheaf.CellularSheaf.CochainPayloadInterpretation
variable {F : CellularSheaf X}
/-- Snapshot validity, full coordinate count, topology tag and supplied payload binding. -/
def BoundToSnapshot
    (I : CochainPayloadInterpretation F)
    (c : Axioms.CochainCommitmentData) : Prop :=
  I.snapshot.WellFormed ∧
    c.n_edge_values = F.edgeCoordinateCount ∧
    c.topology_hash = I.snapshot.topologyHash ∧
    I.PayloadBindsSnapshot c
end Hcrypt.Sheaf.CellularSheaf.CochainPayloadInterpretation
namespace Hcrypt.Sheaf.CellularSheaf
/-- Exact accepted payloads require wire shape, snapshot binding and an actual cellular opening. -/
structure AcceptedCommittedOneCochain
    {F : CellularSheaf X}
    (I : CochainPayloadInterpretation F)
    (c : Axioms.CochainCommitmentData) : Prop where
  wireWellFormed : c.WellFormed
  boundToSnapshot : I.BoundToSnapshot c
  representsExact : ∃ a : F.C0, I.decode c = F.delta0 a
end Hcrypt.Sheaf.CellularSheaf
namespace Hcrypt.Protocol.Storage
/-- The original immutable interpretation, snapshot-bound artifact, run and parameter context. -/
structure Context (F : CellularSheaf X) where
  runId : TCB.Hash32
  interpretation : CochainPayloadInterpretation F
  artifact : TCB.HashedCommittedCochain
  artifactWellFormed : artifact.WellFormed
  boundToSnapshot : interpretation.BoundToSnapshot artifact.cochain
  parameterSet : TCB.Hash32
end Hcrypt.Protocol.Storage
namespace Hcrypt.Protocol.Storage.Context
variable {F : CellularSheaf X}
/-- The exact payload retained by this original context. -/
def cochain (C : Context F) : Axioms.CochainCommitmentData :=
  C.artifact.cochain
/-- Exact-payload acceptance in this very interpretation and snapshot. -/
def Accepted (C : Context F) : Prop :=
  AcceptedCommittedOneCochain C.interpretation C.cochain
end Hcrypt.Protocol.Storage.Context

namespace Hcrypt.Proximity
/-- The original application name for the same block-code predicate. -/
abbrev BlockCode (ι : Type u_1) (α : Type u_2) :=
  ProximityPrize.BlockCode ι α
/-- The original application name for the same additive-code structure. -/
abbrev FAdditiveCode
    (F : Type u_1) (ι : Type u_2) (α : Type u_3) [Zero α] [Add α] [SMul F α] :=
  ProximityPrize.FAdditiveCode F ι α
end Hcrypt.Proximity
namespace Hcrypt.Proximity.ReedSolomon
/-- The historical vector-symbol name used by the original application. -/
abbrev VectorSymbol (F : Type u_1) (σ : Type u_2) :=
  ProximityPrize.ReedSolomon.VectorSymbol F σ
end Hcrypt.Proximity.ReedSolomon
namespace Hcrypt.Proximity.ReedSolomon.Parameters
variable {F : Type u_1} {ι : Type u_2} [Field F] [Fintype ι]
/-- The historical scalar-code projection used by the original canonical payload metrics. -/
abbrev toBlockCode (P : Parameters F ι) : BlockCode ι F :=
  ProximityPrize.ReedSolomon.Parameters.toBlockCode P
/-- The historical vector-code projection of those same RS parameters. -/
abbrev vectorBlockCode (P : Parameters F ι) (σ : Type u_3) :
    BlockCode ι (VectorSymbol F σ) :=
  ProximityPrize.ReedSolomon.Parameters.vectorBlockCode P σ
/-- The historical name for the same scalar RS linear-closure certificate. -/
abbrev FAdditive (P : Parameters F ι) :=
  ProximityPrize.ReedSolomon.Parameters.FAdditive P
/-- The historical positive-degree closure proof used by the original additive-code object. -/
abbrev fAdditive_of_degreeBound_pos
    (P : Parameters F ι)
    (hDegree : 0 < P.degreeBound) :
    P.FAdditive :=
  ProximityPrize.ReedSolomon.Parameters.fAdditive_of_degreeBound_pos P hDegree
end Hcrypt.Proximity.ReedSolomon.Parameters
namespace Hcrypt.Proximity.ReedSolomon.Parameters.FAdditive
variable {F : Type u_1} {ι : Type u_2} [Field F] [Fintype ι]
/-- The historical additive-code projection used by the original challenge profile. -/
abbrev toFAdditiveCode
    {P : Parameters F ι}
    (hP : P.FAdditive) :
    FAdditiveCode F ι F :=
  ProximityPrize.ReedSolomon.Parameters.FAdditive.toFAdditiveCode hP
end Hcrypt.Proximity.ReedSolomon.Parameters.FAdditive
run_cmd Lean.modifyEnv fun env => Lean.Meta.auxLemmasExt.setState env {}
namespace Hcrypt.Sheaf.SystematicCode
variable {q : ℕ} [Fact q.Prime] {ι : Type u_1} [Fintype ι] [DecidableEq ι]
/-- The original two-vertex, one-edge cellular base with no faces. -/
def complex : OrientedTwoComplex Bool Unit Empty where
  incidence01 v _ := if v then 1 else -1
  incidence12 _ f := Empty.elim f
  boundarySqZero _ f := Empty.elim f
/-- The full pair-coordinate equivalence onto the original edge stalk. -/
def layout : (ι × Fin 2) ≃ TotalCoord Unit (fun _ => Fintype.card (ι × Fin 2)) where
  toFun p := ⟨(), (Fintype.equivFin (ι × Fin 2)) p⟩
  invFun p := (Fintype.equivFin (ι × Fin 2)).symm p.2
  left_inv p := (Fintype.equivFin (ι × Fin 2)).symm_apply_apply p
  right_inv p := by
    rcases p with ⟨⟨⟩, i⟩
    simp
/-- The original real encoder function in the fixed information and edge coordinates. -/
def generatorFun (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (data : Coord (Fintype.card ({a // a ∈ S} × Fin 2))) :
    Coord (Fintype.card (ι × Fin 2)) :=
  WithLp.toLp ((2 : ℕ) : ENNReal) fun idx =>
    let p := (Fintype.equivFin (ι × Fin 2)).symm idx
    P.realEncode S
      (fun a => data ((Fintype.equivFin ({a // a ∈ S} × Fin 2)) (a, p.2))) p.1
/-- The actual encoder preserves addition of the same input coordinate vectors. -/
theorem generatorFun_add (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (a b : Coord (Fintype.card ({a // a ∈ S} × Fin 2))) :
    generatorFun P S (a + b) = generatorFun P S a + generatorFun P S b := by sorry
/-- The same encoder preserves real scalar multiplication. -/
theorem generatorFun_smul (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (r : ℝ) (a : Coord (Fintype.card ({a // a ∈ S} × Fin 2))) :
    generatorFun P S (r • a) = r • generatorFun P S a := by sorry
/-- The original systematic cellular restriction map, with named linearity proofs. -/
def generator (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι) :
    Coord (Fintype.card ({a // a ∈ S} × Fin 2)) →ₗ[ℝ]
      Coord (Fintype.card (ι × Fin 2)) where
  toFun := generatorFun P S
  map_add' := generatorFun_add P S
  map_smul' := generatorFun_smul P S
/-- The original cellular sheaf whose head restriction is that real encoder. -/
def sheaf (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι) :
    CellularSheaf complex where
  vertexDim _ := Fintype.card ({a // a ∈ S} × Fin 2)
  edgeDim _ := Fintype.card (ι × Fin 2)
  faceDim f := Empty.elim f
  restrict01 v _ := if v then generator P S else 0
  restrict12 _ f := Empty.elim f
  restrict02 _ f := Empty.elim f
  restrictionComp _ _ f := Empty.elim f
/-- Integer coefficients in the actual head-stalk information coordinates. -/
abbrev IntegerOpening (S : Finset ι) := {s // s ∈ S} → Fin 2 → ℤ
/-- Embedding of that integer opening into the actual cellular head stalk with zero tail. -/
def integralOpening
    (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (a : IntegerOpening S) : (sheaf P S).C0 :=
  WithLp.toLp ((2 : ℕ) : ENNReal) fun coordinate =>
    let p := (Fintype.equivFin ({s // s ∈ S} × Fin 2)).symm coordinate.2
    if coordinate.1 then (a p.1 p.2 : ℝ) else 0
/-- Actual cellular coboundary equals the raw integer pair plus coordinatewise q-multiples. -/
def ModularExact
    (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (z : ι → Fin 2 → ℤ) : Prop :=
  ∃ a : IntegerOpening S, ∃ carry : ι → Fin 2 → ℤ, ∀ i j,
    (sheaf P S).delta0 (integralOpening P S a) (layout (i, j)) =
      ((z i j + (q : ℤ) * carry i j : ℤ) : ℝ)
/-- Actual modular cellular validity is equivalent to validity of the reduced RS pair. -/
theorem modularExact_iff_vectorCodeword
    (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (z : ι → Fin 2 → ℤ) :
    ModularExact P S z ↔
      P.VectorCodeword (Fin 2) (fun i j => (z i j : ZMod q)) := by sorry
end Hcrypt.Sheaf.SystematicCode
namespace Hcrypt.Proximity
/-- Compatibility name for the same indexed coding word. -/
abbrev Word (ι : Type u_1) (α : Type u_2) :=
  ProximityPrize.Word ι α
end Hcrypt.Proximity
open Hcrypt.Proximity
namespace Hcrypt.Proximity.CochainBridge
/-- Compatibility name for the original cochain payload. -/
abbrev CommittedCochain := Axioms.CochainCommitmentData
end Hcrypt.Proximity.CochainBridge
namespace Hcrypt.Proximity.CochainPlane
variable {R ι : Type}
/-- Both semantic coordinates at each evaluation position. -/
abbrev PlaneShadow (R ι : Type) :=
  ι → Fin 2 → R
/-- Original serialized edge indices and the declared integer interpretation map. -/
structure PlaneExtractionContext (R ι : Type) where
  edgeCount : ℕ
  edgeIndex : ι → Fin 2 → ℕ
  coefficient : ℤ → R
end Hcrypt.Proximity.CochainPlane
namespace Hcrypt.Proximity.CochainPlane.PlaneExtractionContext
variable {R ι : Type}
/-- Read the original payload coordinates using the existing total getD operation. -/
def projectedPlane
    (E : PlaneExtractionContext R ι)
    (c : CochainBridge.CommittedCochain) :
    PlaneShadow R ι :=
  fun i j => E.coefficient (c.edge_values.getD (E.edgeIndex i j) 0)
end Hcrypt.Proximity.CochainPlane.PlaneExtractionContext
namespace Hcrypt.Protocol.Storage
variable {F : CellularSheaf X} {ι : Type} [Fintype ι]
/-- Full geometric and serialized coordinate equivalences for the same original payload. -/
structure CoordinateLayout (F : CellularSheaf X) (ι : Type) where
  coordinate : (ι × Fin 2) ≃ TotalCoord Edge F.edgeDim
  serialized : TotalCoord Edge F.edgeDim ≃ Fin F.edgeCoordinateCount
end Hcrypt.Protocol.Storage
run_cmd Lean.modifyEnv fun env => Lean.Meta.auxLemmasExt.setState env {}
namespace Hcrypt.Protocol.Storage.CoordinateLayout
variable {F : CellularSheaf X} {ι : Type} [Fintype ι]
/-- The full original edge layout with identity integer coefficients. -/
def extraction (L : CoordinateLayout F ι) : CochainPlane.PlaneExtractionContext ℤ ι where
  edgeCount := F.edgeCoordinateCount
  edgeIndex i j := (L.serialized (L.coordinate (i, j))).val
  coefficient := id
/-- Read both raw integer coordinates from the original payload. -/
def raw (L : CoordinateLayout F ι) (c : Axioms.CochainCommitmentData) :
    ι → Fin 2 → ℤ := L.extraction.projectedPlane c
/-- The real decoder with that exact same serialized ordering. -/
def decode (L : CoordinateLayout F ι) (c : Axioms.CochainCommitmentData) : F.C1 :=
  WithLp.toLp 2 fun coordinate =>
    (c.edge_values.getD (L.serialized coordinate).val 0 : ℝ)
end Hcrypt.Protocol.Storage.CoordinateLayout
run_cmd Lean.modifyEnv fun env => Lean.Meta.auxLemmasExt.setState env {}
namespace Hcrypt.Protocol.Storage.ThreeLevel
open ProximityPrize
open Hcrypt.Sheaf.SystematicCode
variable {q : ℕ} [Fact q.Prime] {ι : Type} [Fintype ι] [DecidableEq ι]
/-- One integer column is valid precisely when its actual cellular lift is modularly exact. -/
def integerScalarCode (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι) :
    ProximityPrize.BlockCode ι ℤ where
  Codeword z := ModularExact P S (fun i j => if j = 0 then z i else 0)
/-- Reduction of both original integer coordinates modulo the same prime. -/
def reducePair (z : ProximityPrize.Word ι (Fin 2 → ℤ)) : ProximityPrize.Word ι (Fin 2 → ZMod q) :=
  fun i j => (z i j : ZMod q)
/-- The independently defined native metrics satisfy d_C ≤ d_P = D_RS ≤ 2d_C. -/
theorem three_native_distance_comparison
    (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (hn : 0 < Fintype.card ι) (z : ProximityPrize.Word ι (Fin 2 → ℤ)) :
    (integerScalarCode P S).flattenedPairCode.relativeDistanceToCode (ProximityPrize.BlockCode.flattenPair z) ≤
        ((integerScalarCode P S).interleaved (Fin 2)).relativeDistanceToCode z ∧
    ((integerScalarCode P S).interleaved (Fin 2)).relativeDistanceToCode z =
        (P.vectorBlockCode (Fin 2)).relativeDistanceToCode (reducePair z) ∧
    (P.vectorBlockCode (Fin 2)).relativeDistanceToCode (reducePair z) ≤
        2 * (integerScalarCode P S).flattenedPairCode.relativeDistanceToCode
          (ProximityPrize.BlockCode.flattenPair z) := by sorry
/-- The scalar-coordinate native metric transports by matching representative lifts. -/
theorem flatDistance_eq_rsFlatDistance
    (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (z : ProximityPrize.Word ι (Fin 2 → ℤ)) :
    (integerScalarCode P S).flattenedPairCode.relativeDistanceToCode (ProximityPrize.BlockCode.flattenPair z) =
      P.toBlockCode.flattenedPairCode.relativeDistanceToCode
        (ProximityPrize.BlockCode.flattenPair (reducePair z)) := by sorry
end Hcrypt.Protocol.Storage.ThreeLevel
namespace Hcrypt.Protocol.Storage.CanonicalSystematic
/-- The original 4096 evaluation positions. -/
abbrev Index := Fin Hcrypt.Proximity.CanonicalRS.length
/-- The same certified canonical power-domain RS parameters. -/
def parameters := Hcrypt.Proximity.CanonicalRS.canonicalSmoothDomain.parameters
/-- The original dimension bound is no larger than the actual domain length. -/
theorem degreeBound_le_length :
    Hcrypt.Proximity.CanonicalRS.degreeBound ≤ Hcrypt.Proximity.CanonicalRS.length := by sorry
/-- The original embedding of the first 1024 information coordinates. -/
def informationIndex (a : Fin Hcrypt.Proximity.CanonicalRS.degreeBound) : Index :=
  Fin.castLE degreeBound_le_length a
/-- The original first-1024-position information set. -/
def informationSet : Finset Index := Finset.univ.image informationIndex
/-- The canonical degree bound is positive. -/
theorem degreeBound_pos : 0 < parameters.degreeBound := by sorry
/-- The original cellular sheaf realized by the canonical systematic encoder. -/
def sheaf := Sheaf.SystematicCode.sheaf parameters informationSet
/-- The complete original geometric and serialized layout, before specialization. -/
def systematicLayout {q : ℕ} [Fact q.Prime] {ι : Type}
    [Fintype ι] [DecidableEq ι]
    (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι) :
    CoordinateLayout (Sheaf.SystematicCode.sheaf P S) ι where
  coordinate := Sheaf.SystematicCode.layout
  serialized := Fintype.equivFin _
/-- That same layout at the canonical field, information set and sheaf. -/
def layout : CoordinateLayout sheaf Index := systematicLayout parameters informationSet
end Hcrypt.Protocol.Storage.CanonicalSystematic
namespace Hcrypt.Protocol.Storage.CanonicalSystematic
variable {F : CellularSheaf X} {ι : Type} [Fintype ι]
/-- Serialize every original integer coordinate once, with the original modulus and topology tag. -/
def serializePayload (L : CoordinateLayout F ι) (z : ι → Fin 2 → ℤ) :
    Axioms.CochainCommitmentData where
  modulus := Axioms.canonicalCochainModulus
  n_edge_values := F.edgeCoordinateCount
  edge_values := List.ofFn fun i : Fin F.edgeCoordinateCount =>
    let p := L.coordinate.symm (L.serialized.symm i)
    z p.1 p.2
  topology_hash := fun _ => 0
end Hcrypt.Protocol.Storage.CanonicalSystematic
namespace Hcrypt.Protocol.Storage.CanonicalSystematic
/-- The existing original canonical payload serializer. -/
def payload (z : Index → Fin 2 → ℤ) : Axioms.CochainCommitmentData :=
  serializePayload layout z
end Hcrypt.Protocol.Storage.CanonicalSystematic
namespace Hcrypt.Protocol.Storage.Calibration
variable {Fsheaf : CellularSheaf X} {K ι : Type} [Field K] [Fintype ι] [DecidableEq K]
/-- The original extraction API reads and reduces both coordinates of this same context payload. -/
def extractedPair (E : CochainPlane.PlaneExtractionContext ℤ ι)
    (C : Context Fsheaf) : ProximityPrize.Word ι (Fin 2 → K) :=
  fun i j => ((E.projectedPlane C.cochain i j : ℤ) : K)
end Hcrypt.Protocol.Storage.Calibration
namespace Hcrypt.Proximity.CochainReedSolomon
variable {R F ι : Type}
variable [Field F] [Fintype F] [Fintype ι] [DecidableEq F]
/-- The same existing finite field at the original payload modulus. -/
abbrev CanonicalField :=
  ZMod Axioms.canonicalCochainModulus
/-- The original kernel-checked prime instance at the payload encoding boundary. -/
instance canonicalCochainModulus_prime :
    Fact (Nat.Prime Axioms.canonicalCochainModulus) :=
  ⟨by norm_num [Axioms.canonicalCochainModulus]⟩
/-- The existing map from an integer plane symbol into a field symbol. -/
structure PlaneEncoding (R F : Type) where
  encodePoint : (Fin 2 → R) → F
end Hcrypt.Proximity.CochainReedSolomon
namespace Hcrypt.Proximity.CochainReedSolomon.PlaneEncoding
variable {R F ι : Type}
variable [Field F] [Fintype F] [Fintype ι] [DecidableEq F]
/-- Apply the existing point encoding independently at each original evaluation position. -/
def receivedWord
    (E : PlaneEncoding R F)
    {ι : Type}
    (p : CochainPlane.PlaneShadow R ι) :
    Word ι F :=
  fun i => E.encodePoint (p i)
run_cmd Lean.modifyEnv fun env => Lean.Meta.auxLemmasExt.setState env {}
/-- The original scalar fold z₀ + γ*z₁ modulo the canonical payload modulus. -/
def integerCanonical
    (mix : CanonicalField) :
    PlaneEncoding ℤ CanonicalField where
  encodePoint p := ((p 0 : ℤ) : CanonicalField) + mix * ((p 1 : ℤ) : CanonicalField)
end Hcrypt.Proximity.CochainReedSolomon.PlaneEncoding
namespace Hcrypt.Proximity.CanonicalRS
/-- The original fixed challenge is the certified canonical root value. -/
def canonicalMix : RSField :=
  candidateRoot
/-- The existing integer-plane fold at the supplied field challenge. -/
def integerPlaneEncodingAt
    (gamma : RSField) :
    CochainReedSolomon.PlaneEncoding ℤ RSField :=
  CochainReedSolomon.PlaneEncoding.integerCanonical gamma
end Hcrypt.Proximity.CanonicalRS
namespace Hcrypt.Protocol.Storage.CanonicalThreeLevel
open CanonicalSystematic
open ProximityPrize
/-- Native distance on all original 2n scalar payload coordinates. -/
def cochainDistance (c : Axioms.CochainCommitmentData) : ℝ :=
  (ThreeLevel.integerScalarCode parameters informationSet).flattenedPairCode.relativeDistanceToCode
    (ProximityPrize.BlockCode.flattenPair (layout.raw c))
/-- Native distance on the original n integer pairs. -/
def planeDistance (c : Axioms.CochainCommitmentData) : ℝ :=
  ((ThreeLevel.integerScalarCode parameters informationSet).interleaved (Fin 2)).relativeDistanceToCode
    (layout.raw c)
/-- Native RS-pair distance after reducing these same original payload coordinates. -/
def rsPairDistance (c : Axioms.CochainCommitmentData) : ℝ :=
  (parameters.vectorBlockCode (Fin 2)).relativeDistanceToCode
    (ThreeLevel.reducePair (layout.raw c))
/-- Canonical residue lifts of the actual diagonal power pair. -/
def capacityIntegerWord (i : Index) (j : Fin 2) : ℤ :=
  (parameters.diagonalPowerPair i j).val
/-- That diagonal word serialized in the same original canonical payload. -/
def capacityPayload : Axioms.CochainCommitmentData := payload capacityIntegerWord
run_cmd Lean.modifyEnv fun env => Lean.Meta.auxLemmasExt.setState env {}
/-- The affine line read from the same two original serialized integer coordinates. -/
def extractedLine (c : Axioms.CochainCommitmentData) :
    AffineLine Index Hcrypt.Proximity.CanonicalRS.RSField where
  base i := (layout.raw c i 0 : Hcrypt.Proximity.CanonicalRS.RSField)
  direction i := (layout.raw c i 1 : Hcrypt.Proximity.CanonicalRS.RSField)
/-- The original scalar challenge encoding of this same integer payload. -/
def receivedWord (c : Axioms.CochainCommitmentData)
    (γ : Hcrypt.Proximity.CanonicalRS.RSField) :
    ProximityPrize.Word Index Hcrypt.Proximity.CanonicalRS.RSField :=
  (Hcrypt.Proximity.CanonicalRS.integerPlaneEncodingAt γ).receivedWord (layout.raw c)
/-- The same positive-degree scalar RS code through its additive interface. -/
def additiveCode : ProximityPrize.FAdditiveCode Hcrypt.Proximity.CanonicalRS.RSField Index
    Hcrypt.Proximity.CanonicalRS.RSField :=
  (parameters.fAdditive_of_degreeBound_pos degreeBound_pos).toFAdditiveCode
/-- The named diagonal capacity payload has the original wire shape. -/
theorem capacityPayload_wellFormed : capacityPayload.WellFormed := by sorry
/-- This same named payload has scalar-coordinate native distance exactly 3/4. -/
theorem capacityPayload_cochainDistance : cochainDistance capacityPayload = (3 : ℝ) / 4 := by sorry
/-- This same named payload has integer-plane native distance exactly 3/4. -/
theorem capacityPayload_planeDistance : planeDistance capacityPayload = (3 : ℝ) / 4 := by sorry
/-- This same named payload has RS-pair native distance exactly 3/4. -/
theorem capacityPayload_rsPairDistance : rsPairDistance capacityPayload = (3 : ℝ) / 4 := by sorry
/-- An actual well-formed original payload attains native distance 3/4 at all three levels. -/
theorem exists_payload_at_capacity :
    ∃ c : Axioms.CochainCommitmentData, c.WellFormed ∧
      cochainDistance c = (3 : ℝ) / 4 ∧
      planeDistance c = (3 : ℝ) / 4 ∧ rsPairDistance c = (3 : ℝ) / 4 := by sorry
/-- This actual diagonal payload has bad fraction exactly 1/12289 at every nonnegative radius. -/
theorem capacityPayload_badChallengeFraction (δ : ℝ) (hδ : 0 ≤ δ) :
    ProximityPrize.BlockCode.challengeFraction (additiveCode.asBlockCode.badChallengeSetAt δ
      (extractedLine capacityPayload)) = (1 : ℝ) / 12289 := by sorry
/-- The original fixed challenge retains scalar distance 3/4 for this actual diagonal payload. -/
theorem capacityPayload_canonicalMix_scalarDistance :
    parameters.toBlockCode.relativeDistanceToCode
      (receivedWord capacityPayload Hcrypt.Proximity.CanonicalRS.canonicalMix) =
        (3 : ℝ) / 4 := by sorry
/-- Actual exact acceptance has zero native distances under equality of the two decoders at this same payload. -/
theorem accepted_nativeDistances_zero
    (C : Context sheaf)
    (hdecode : C.interpretation.decode C.cochain = layout.decode C.cochain)
    (haccepted : C.Accepted) :
    cochainDistance C.cochain = 0 ∧ planeDistance C.cochain = 0 ∧
      rsPairDistance C.cochain = 0 := by sorry
end Hcrypt.Protocol.Storage.CanonicalThreeLevel
namespace Hcrypt.Palomar.PaperThree.Application
open Hcrypt.Protocol.Storage
/-- The actual two-step extraction equals the existing original-payload pair API. -/
theorem calibration_extract_eq_original_pair_unfolded (C : Context CanonicalSystematic.sheaf) :
    ThreeLevel.reducePair (CanonicalSystematic.layout.raw C.cochain) =
      Calibration.extractedPair (K := Hcrypt.Proximity.CanonicalRS.RSField)
        CanonicalSystematic.layout.extraction C := by sorry
/-- Original scalar-coordinate farness transfers to the same payload's RS pair with unit scale. -/
theorem sourceFar_implies_rsFar_unfolded (C : Context CanonicalSystematic.sheaf) (radius : ℝ)
    (hfar : radius ≤ CanonicalThreeLevel.cochainDistance C.cochain) :
    radius ≤ CanonicalThreeLevel.rsPairDistance C.cochain := by sorry
/-- The near direction uses exactly the original factor-two source budget. -/
theorem planeNear_of_scaledSourceNear_unfolded (C : Context CanonicalSystematic.sheaf) (epsilon : ℝ)
    (hnear : 2 * CanonicalThreeLevel.cochainDistance C.cochain ≤ epsilon) :
    CanonicalThreeLevel.planeDistance C.cochain ≤ epsilon := by sorry
end Hcrypt.Palomar.PaperThree.Application

end
