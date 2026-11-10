module

public import Proximity.Concrete.CanonicalRS.PowerDomain
public import Proximity.Concrete.CochainPlane.ReedSolomon

@[expose] public section

/-
  Concrete plane-to-field encoding choices for the canonical RS regime.

  Paper correspondence:
  - Paper 2: concrete field/coordinate interpretation of the existing payload
    view.
  - Paper 3: the mathematical plane-to-field map used by the quantitative
    source-to-code comparison.-/

namespace HomotopicalEncryption
namespace Proximity
namespace CanonicalRS

noncomputable section

/--
Canonical mix used to fold an integer two-plane point into one canonical RS
field symbol.

This fixes the concrete encoding boundary while keeping non-collapse/distance
properties as explicit downstream obligations.
-/
def canonicalMix : RSField :=
  candidateRoot

/-- Evaluate an integer plane point at the selected public challenge. -/
def integerPlaneEncodingAt
    (gamma : RSField) :
    CochainReedSolomon.PlaneEncoding ℤ RSField :=
  CochainReedSolomon.PlaneEncoding.integerCanonical gamma

/-- The selected fixed-challenge integer-plane encoding into the canonical RS field. -/
def integerPlaneEncoding :
    CochainReedSolomon.PlaneEncoding ℤ RSField :=
  integerPlaneEncodingAt canonicalMix

/-- Reduce both integer coordinates of a plane shadow into the canonical RS field. -/
def reduceIntegerPlane
    {iota : Type}
    (p : CochainPlane.PlaneShadow ℤ iota) :
    CochainPlane.PlaneShadow RSField iota :=
  fun i j => ((p i j : ℤ) : RSField)

/-- The paper affine line represented by the two reduced plane coordinates. -/
def integerPlaneLine
    {iota : Type}
    (p : CochainPlane.PlaneShadow ℤ iota) :
    AffineLine RSField iota RSField :=
  CochainReedSolomon.PaperPair.toAffineLine (reduceIntegerPlane p)

/-- The paper pair underlying an integer plane is exactly its coordinatewise reduction. -/
@[simp]
theorem pairWord_integerPlaneLine
    {iota : Type}
    (p : CochainPlane.PlaneShadow ℤ iota) :
    BlockCode.pairWord (integerPlaneLine p).base (integerPlaneLine p).direction =
      reduceIntegerPlane p := by
  exact CochainReedSolomon.PaperPair.pairWord_toAffineLine
    (reduceIntegerPlane p)

/-- Challenge encoding of an integer plane is exactly its affine-line evaluation. -/
theorem integerPlaneEncodingAt_receivedWord
    {iota : Type}
    (p : CochainPlane.PlaneShadow ℤ iota)
    (gamma : RSField) :
    (integerPlaneEncodingAt gamma).receivedWord p =
      (integerPlaneLine p).point gamma := by
  rfl

/-!
### Canonical representatives and the admissible plane region

The full integer plane is larger than the finite-field paper pair.  Restricting
each integer coordinate to its canonical representative interval gives the
precise region on which coordinatewise reduction is an equivalence.  This does
not make evaluation at one challenge injective; it makes the unreduced
two-coordinate pair faithful.
-/

/-- An integer is the canonical representative of its residue modulo the cochain modulus. -/
def IsCanonicalRepresentative (z : ℤ) : Prop :=
  0 ≤ z ∧ z < (Axioms.canonicalCochainModulus : ℤ)

/-- The canonical integer representatives `[0, q)`. -/
abbrev CanonicalInteger :=
  {z : ℤ // IsCanonicalRepresentative z}

/-- The admissible two-coordinate integer region `A = [0,q)^2`. -/
def admissiblePointRegion : Set (Fin 2 → ℤ) :=
  {p | ∀ j, IsCanonicalRepresentative (p j)}

/-- One point in the admissible two-coordinate integer region. -/
abbrev AdmissiblePoint :=
  {p : Fin 2 → ℤ // ∀ j, IsCanonicalRepresentative (p j)}

/-- Canonical integer representatives are equivalent to canonical RS field elements. -/
def canonicalIntegerEquiv : CanonicalInteger ≃ RSField where
  toFun z := (z.1 : RSField)
  invFun a := ⟨(a.val : ℤ), by
    constructor
    · positivity
    · exact_mod_cast ZMod.val_lt a⟩
  left_inv z := by
    apply Subtype.ext
    change (((((z.1 : ℤ) : RSField).val : ℕ) : ℤ)) = z.1
    rw [ZMod.val_intCast]
    exact Int.emod_eq_of_lt z.2.1 z.2.2
  right_inv a := by
    change (((a.val : ℕ) : ℤ) : RSField) = a
    rw [Int.cast_natCast, ZMod.natCast_zmod_val]

/-- The admissible integer plane-point region is equivalent to a field pair. -/
def canonicalPointEquiv : AdmissiblePoint ≃ (Fin 2 → RSField) :=
  Equiv.subtypePiEquivPi.trans
    (Equiv.piCongrRight fun _ => canonicalIntegerEquiv)

/-- Plane words whose every integer coordinate lies in the canonical region. -/
abbrev AdmissiblePlane (iota : Type) :=
  {p : CochainPlane.PlaneShadow ℤ iota //
    ∀ i j, IsCanonicalRepresentative (p i j)}

/-- Plane words with their admissibility proof stored pointwise. -/
abbrev AdmissiblePlaneWord (iota : Type) :=
  Word iota AdmissiblePoint

/-- Pointwise canonical reduction is an equivalence onto field-valued paper pairs. -/
def canonicalPlaneWordEquiv (iota : Type) :
    AdmissiblePlaneWord iota ≃ CochainPlane.PlaneShadow RSField iota :=
  Equiv.piCongrRight fun _ => canonicalPointEquiv

/-- A raw admissible integer plane is equivalent to a field-valued paper pair. -/
def canonicalPlaneEquiv (iota : Type) :
    AdmissiblePlane iota ≃ CochainPlane.PlaneShadow RSField iota :=
  Equiv.subtypePiEquivPi.trans (canonicalPlaneWordEquiv iota)

/-- Canonical plane-word encoding is coordinatewise reduction modulo `q`. -/
@[simp]
theorem canonicalPlaneWordEquiv_apply
    {iota : Type}
    (p : AdmissiblePlaneWord iota)
    (i : iota)
    (j : Fin 2) :
    canonicalPlaneWordEquiv iota p i j = (((p i).1 j : ℤ) : RSField) :=
  rfl

/-- Canonical raw-plane encoding is coordinatewise reduction modulo `q`. -/
@[simp]
theorem canonicalPlaneEquiv_apply
    {iota : Type}
    (p : AdmissiblePlane iota)
    (i : iota)
    (j : Fin 2) :
    canonicalPlaneEquiv iota p i j = ((p.1 i j : ℤ) : RSField) :=
  rfl

/-- Reduction to the field pair is injective on admissible integer planes. -/
theorem reduceIntegerPlane_injective_on_admissible
    {iota : Type}
    {p q : CochainPlane.PlaneShadow ℤ iota}
    (hp : ∀ i j, IsCanonicalRepresentative (p i j))
    (hq : ∀ i j, IsCanonicalRepresentative (q i j))
    (hreduce : reduceIntegerPlane p = reduceIntegerPlane q) :
    p = q := by
  let p' : AdmissiblePlane iota := ⟨p, hp⟩
  let q' : AdmissiblePlane iota := ⟨q, hq⟩
  have hencoded : canonicalPlaneEquiv iota p' = canonicalPlaneEquiv iota q' := by
    exact hreduce
  exact congrArg Subtype.val ((canonicalPlaneEquiv iota).injective hencoded)

/-- Hamming distance is preserved by the admissible-plane/paper-pair equivalence. -/
theorem canonicalPlaneWordEquiv_hammingDistance
    {iota : Type} [Fintype iota]
    (p q : AdmissiblePlaneWord iota) :
    BlockCode.hammingDistance
        (canonicalPlaneWordEquiv iota p)
        (canonicalPlaneWordEquiv iota q) =
      BlockCode.hammingDistance p q := by
  unfold BlockCode.hammingDistance
  unfold ProximityPrize.BlockCode.hammingDistance
  congr 1
  ext i
  simp [canonicalPlaneWordEquiv]

/-- Relative Hamming distance is preserved by the plane/pair equivalence. -/
theorem canonicalPlaneWordEquiv_relativeHammingDistance
    {iota : Type} [Fintype iota]
    (p q : AdmissiblePlaneWord iota) :
    BlockCode.relativeHammingDistance
        (canonicalPlaneWordEquiv iota p)
        (canonicalPlaneWordEquiv iota q) =
      BlockCode.relativeHammingDistance p q := by
  have hdist := canonicalPlaneWordEquiv_hammingDistance p q
  change
    ProximityPrize.BlockCode.hammingDistance
        (canonicalPlaneWordEquiv iota p)
        (canonicalPlaneWordEquiv iota q) =
      ProximityPrize.BlockCode.hammingDistance p q at hdist
  unfold BlockCode.relativeHammingDistance
  unfold ProximityPrize.BlockCode.relativeHammingDistance
  rw [hdist]

/--
The canonical integer-plane encoding is not globally injective: shifting the
first coordinate by the field modulus leaves the encoded symbol unchanged.
Consequently any concrete non-collapse theorem must restrict the admissible
integer region or directly assume a metric lower bound on the selected image.
-/
theorem integerPlaneEncoding_not_injective :
    ¬ Function.Injective integerPlaneEncoding.encodePoint := by
  intro hInjective
  let p : Fin 2 → ℤ := fun _ => 0
  let q : Fin 2 → ℤ := fun j => if j = 0 then Axioms.canonicalCochainModulus else 0
  have hmod :
      ((Axioms.canonicalCochainModulus : ℤ) : RSField) = 0 := by
    rw [ZMod.intCast_zmod_eq_zero_iff_dvd]
  have hEncoded : integerPlaneEncoding.encodePoint p =
      integerPlaneEncoding.encodePoint q := by
    change (0 : RSField) =
      ((Axioms.canonicalCochainModulus : ℤ) : RSField) + canonicalMix * 0
    rw [hmod]
    simp
  have hpq : p = q := hInjective hEncoded
  have hcoord := congrFun hpq (0 : Fin 2)
  simp [p, q, Axioms.canonicalCochainModulus] at hcoord

end

end CanonicalRS
end Proximity
end HomotopicalEncryption
