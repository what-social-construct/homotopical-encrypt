module

public import Proximity.Concrete.CochainPlane.Core
public import Proximity.Concrete.RS.Target
public import Axioms.CochainCommitment.Payload
public meta import Axioms.CochainCommitment.Payload
public import Mathlib.Data.ZMod.Basic

@[expose] public section

/-
  Reed-Solomon interpretation of cochain plane shadows.

  Paper correspondence:
  - Paper 3: field interpretation of an already extracted plane and its RS
    received-word map.
  - Paper 2's codec/profile chooses the concrete coordinates and coefficient
    interpretation.

  The concrete projection from committed cochains to semantic two-coordinate
  plane shadows lives in `Proximity.CochainPlane`. This file begins only after
  that projection exists: it encodes each plane point into a finite field and
  interprets the resulting indexed family as an RS received word.
-/

namespace Hcrypt
namespace Proximity
namespace CochainReedSolomon

noncomputable section

variable {R F ι : Type}
variable [Field F] [Fintype F] [Fintype ι] [DecidableEq F]

/--
Canonical concrete RS field for the current wire/runtime modulus.

This is only a finite-field boundary. The semantic cochain and plane-shadow
layers remain independent of the runtime payload modulus.
-/
abbrev CanonicalField :=
  ZMod Axioms.canonicalCochainModulus

/-- The current canonical cochain modulus is prime. -/
instance canonicalCochainModulus_prime :
    Fact (Nat.Prime Axioms.canonicalCochainModulus) :=
  ⟨by norm_num [Axioms.canonicalCochainModulus]⟩

/--
Encoding boundary from a semantic plane point into an RS field element.

This is where concrete finite-field choices live. The cochain/plane layer does
not depend on the runtime commitment modulus or on RS field structure.
-/
structure PlaneEncoding (R F : Type) where
  encodePoint : (Fin 2 → R) → F

namespace PlaneEncoding

/-- Point encoding is faithful on a selected admissible plane region. -/
def FaithfulOn
    (E : PlaneEncoding R F)
    (A : Set (Fin 2 → R)) : Prop :=
  Set.InjOn E.encodePoint A

/-- Encode an indexed plane shadow as an RS received word. -/
def receivedWord
    (E : PlaneEncoding R F)
    {ι : Type}
    (p : CochainPlane.PlaneShadow R ι) :
    Word ι F :=
  fun i => E.encodePoint (p i)

omit [Field F] [Fintype F] [Fintype ι] [DecidableEq F] in
/-- Coordinatewise admissibility plus pointwise faithfulness prevents word collapse. -/
theorem receivedWord_injective_on
    (E : PlaneEncoding R F)
    {A : Set (Fin 2 → R)}
    (hFaithful : E.FaithfulOn A)
    {p q : CochainPlane.PlaneShadow R ι}
    (hp : ∀ i : ι, p i ∈ A)
    (hq : ∀ i : ι, q i ∈ A)
    (hWord : E.receivedWord p = E.receivedWord q) :
    p = q := by
  funext i
  exact hFaithful (hp i) (hq i) (congrFun hWord i)

/--
Integer plane encoding into the canonical RS field.

The parameter `mix` fixes how the second plane coordinate is folded into one
field symbol. This is a concrete encoding boundary, not a claim that this
particular `mix` has the final distance/non-collapse property.
-/
def integerCanonical
    (mix : CanonicalField) :
    PlaneEncoding ℤ CanonicalField where
  encodePoint p := ((p 0 : ℤ) : CanonicalField) + mix * ((p 1 : ℤ) : CanonicalField)

end PlaneEncoding

/-!
### The two-coordinate plane as the paper affine-line pair

After the plane coordinates have entered the finite field, a plane shadow is
already the paper's interleaved pair of words.  The following equivalence makes
that identification explicit and keeps it separate from evaluation at one
challenge, which is generally many-to-one.
-/

namespace PaperPair

/-- Read the two coordinates of a field-valued plane as an affine line. -/
def toAffineLine
    (p : CochainPlane.PlaneShadow F ι) :
    AffineLine F ι F where
  base := fun i => p i 0
  direction := fun i => p i 1

/-- Bundle the base and direction of an affine line back into a plane word. -/
def ofAffineLine
    (L : AffineLine F ι F) :
    CochainPlane.PlaneShadow F ι :=
  BlockCode.pairWord L.base L.direction

omit [Fintype F] [Fintype ι] [DecidableEq F] in
/-- Converting a field-valued plane to a line and back is identity. -/
@[simp]
theorem ofAffineLine_toAffineLine
    (p : CochainPlane.PlaneShadow F ι) :
    ofAffineLine (toAffineLine p) = p := by
  funext i j
  fin_cases j <;> simp [ofAffineLine, toAffineLine]

omit [Fintype F] [Fintype ι] [DecidableEq F] in
/-- Converting an affine line to a field-valued plane and back is identity. -/
@[simp]
theorem toAffineLine_ofAffineLine
    (L : AffineLine F ι F) :
    toAffineLine (ofAffineLine L) = L := by
  cases L
  simp [toAffineLine, ofAffineLine]

/-- Field-valued two-coordinate planes are equivalent to paper affine lines. -/
def planeAffineLineEquiv :
    CochainPlane.PlaneShadow F ι ≃ AffineLine F ι F where
  toFun := toAffineLine
  invFun := ofAffineLine
  left_inv := ofAffineLine_toAffineLine
  right_inv := toAffineLine_ofAffineLine

omit [Fintype F] [Fintype ι] [DecidableEq F] in
/-- The interleaved pair of a plane's affine line is exactly the plane. -/
@[simp]
theorem pairWord_toAffineLine
    (p : CochainPlane.PlaneShadow F ι) :
    BlockCode.pairWord (toAffineLine p).base (toAffineLine p).direction = p :=
  ofAffineLine_toAffineLine p

/-- Evaluate a two-coordinate field plane at a public challenge. -/
def challengeWord
    (p : CochainPlane.PlaneShadow F ι)
    (gamma : F) : Word ι F :=
  fun i => p i 0 + gamma • p i 1

omit [Fintype F] [Fintype ι] [DecidableEq F] in
/-- Plane challenge evaluation is exactly affine-line point evaluation. -/
@[simp]
theorem toAffineLine_point
    (p : CochainPlane.PlaneShadow F ι)
    (gamma : F) :
    (toAffineLine p).point gamma = challengeWord p gamma :=
  rfl

end PaperPair

/-- The plane target induced by a selected RS target, metric, and plane encoding. -/
def rsPlaneTarget
    (T : ReedSolomonTarget.Target F ι)
    (D : ReedSolomonTarget.Target.ReceivedWordMetric T)
    (Φ : PlaneEncoding R F) :
    CochainPlane.PlaneTarget R ι where
  Codeword := fun p => T.parameters.Codeword (Φ.receivedWord p)
  distanceToCode := fun p => D.distanceToRS (Φ.receivedWord p)

/--
RS interpretation of an already-defined cochain-plane projection.

The projection itself remains the concrete `CochainPlane.PlaneExtractionContext`
extraction from `edge_values` into an explicit semantic plane target. The last
two fields are the genuinely later boundary: plane codewords encode to RS
codewords, and RS distance is controlled by the plane metric.
-/
structure Interpretation
    {S : Axioms.SheafCoherence}
    (L : PluckerCochain.LocalSyndromeTarget S)
    (T : ReedSolomonTarget.Target F ι)
    (D : ReedSolomonTarget.Target.ReceivedWordMetric T)
    (E : CochainPlane.PlaneExtractionContext R ι)
    (Φ : PlaneEncoding R F) where
  planeTarget : CochainPlane.PlaneTarget R ι
  projection : CochainPlane.Projection L E planeTarget
  mapsPlaneCodewordsToRS :
    ∀ p : CochainPlane.PlaneShadow R ι,
      planeTarget.Codeword p → T.parameters.Codeword (Φ.receivedWord p)
  distanceControlled :
    ∀ p : CochainPlane.PlaneShadow R ι,
      D.distanceToRS (Φ.receivedWord p) ≤ planeTarget.distanceToCode p
  restrictWord : Word ι F → Word ι F
  RSSyndrome : Type
  wordSyndrome : Word ι F → RSSyndrome
  mapPlaneSyndrome : projection.naturality.PlaneSyndrome → RSSyndrome
  restrictionCommutes :
    ∀ p : CochainPlane.PlaneShadow R ι,
      Φ.receivedWord (projection.naturality.restrictPlane p) =
        restrictWord (Φ.receivedWord p)
  syndromeCommutes :
    ∀ p : CochainPlane.PlaneShadow R ι,
      wordSyndrome (Φ.receivedWord p) =
        mapPlaneSyndrome (projection.naturality.planeSyndrome p)

namespace Interpretation

/--
Compatibility constructor whose semantic plane target is induced directly by
the selected RS target. This is the fused special case; general interpretations
should supply an independently meaningful plane predicate and metric.
-/
def of_rsPlaneTarget
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {T : ReedSolomonTarget.Target F ι}
    {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
    {E : CochainPlane.PlaneExtractionContext R ι}
    {Φ : PlaneEncoding R F}
    (π : CochainPlane.Projection L E (rsPlaneTarget T D Φ))
    (restrictWord : Word ι F → Word ι F)
    (RSSyndrome : Type)
    (wordSyndrome : Word ι F → RSSyndrome)
    (mapPlaneSyndrome : π.naturality.PlaneSyndrome → RSSyndrome)
    (restrictionCommutes :
      ∀ p : CochainPlane.PlaneShadow R ι,
        Φ.receivedWord (π.naturality.restrictPlane p) =
          restrictWord (Φ.receivedWord p))
    (syndromeCommutes :
      ∀ p : CochainPlane.PlaneShadow R ι,
        wordSyndrome (Φ.receivedWord p) =
          mapPlaneSyndrome (π.naturality.planeSyndrome p)) :
    Interpretation L T D E Φ where
  planeTarget := rsPlaneTarget T D Φ
  projection := π
  mapsPlaneCodewordsToRS := by
    intro p hp
    exact hp
  distanceControlled := by
    intro p
    exact le_rfl
  restrictWord := restrictWord
  RSSyndrome := RSSyndrome
  wordSyndrome := wordSyndrome
  mapPlaneSyndrome := mapPlaneSyndrome
  restrictionCommutes := restrictionCommutes
  syndromeCommutes := syndromeCommutes

/-- Map a committed cochain through plane projection and then RS field encoding. -/
def receivedWord
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {T : ReedSolomonTarget.Target F ι}
    {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
    {E : CochainPlane.PlaneExtractionContext R ι}
    {Φ : PlaneEncoding R F}
    (_I : Interpretation L T D E Φ)
    (c : CochainBridge.CommittedCochain) :
    Word ι F :=
  Φ.receivedWord (E.projectedPlane c)

/-- An RS interpretation exposes an evaluation projection into the RS code shadow. -/
def toEvaluationProjection
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {T : ReedSolomonTarget.Target F ι}
    {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
    {E : CochainPlane.PlaneExtractionContext R ι}
    {Φ : PlaneEncoding R F}
    (I : Interpretation L T D E Φ) :
    EvaluationProjection
      (CochainPlane.localSyndromeInstance L)
      D.codeShadow where
  map := I.receivedWord
  preservesGlobalSections := by
    intro c hc
    exact I.mapsPlaneCodewordsToRS (E.projectedPlane c)
      (I.projection.mapsCodewordsToTarget c hc)
  distanceControlled := by
    intro c
    exact le_trans
      (I.distanceControlled (E.projectedPlane c))
      (I.projection.distanceControlled c)

/-- Accepted local cochain tests project to RS codewords under this interpretation. -/
theorem projected_localCodeword_is_RSCodeword
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {T : ReedSolomonTarget.Target F ι}
    {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
    {E : CochainPlane.PlaneExtractionContext R ι}
    {Φ : PlaneEncoding R F}
    (I : Interpretation L T D E Φ)
    (c : CochainBridge.CommittedCochain) :
    L.Codeword c → T.parameters.Codeword (I.receivedWord c) :=
  fun hc => I.mapsPlaneCodewordsToRS (E.projectedPlane c)
    (I.projection.mapsCodewordsToTarget c hc)

/-- Semantic plane codewords encode to RS codewords. -/
theorem projected_planeCodeword_is_RSCodeword
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {T : ReedSolomonTarget.Target F ι}
    {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
    {E : CochainPlane.PlaneExtractionContext R ι}
    {Φ : PlaneEncoding R F}
    (I : Interpretation L T D E Φ)
    (p : CochainPlane.PlaneShadow R ι) :
    I.planeTarget.Codeword p → T.parameters.Codeword (Φ.receivedWord p) :=
  I.mapsPlaneCodewordsToRS p

/-- RS distance is bounded by the independently selected plane metric. -/
theorem projected_distance_le_planeDistance
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {T : ReedSolomonTarget.Target F ι}
    {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
    {E : CochainPlane.PlaneExtractionContext R ι}
    {Φ : PlaneEncoding R F}
    (I : Interpretation L T D E Φ)
    (p : CochainPlane.PlaneShadow R ι) :
    D.distanceToRS (Φ.receivedWord p) ≤ I.planeTarget.distanceToCode p :=
  I.distanceControlled p

/-- RS distance is bounded by the local cochain syndrome distance. -/
theorem projected_distance_le_localSyndromeDistance
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {T : ReedSolomonTarget.Target F ι}
    {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
    {E : CochainPlane.PlaneExtractionContext R ι}
    {Φ : PlaneEncoding R F}
    (I : Interpretation L T D E Φ)
    (c : CochainBridge.CommittedCochain) :
    D.distanceToRS (I.receivedWord c) ≤ L.distanceToCode c :=
  le_trans
    (I.distanceControlled (E.projectedPlane c))
    (I.projection.distanceControlled c)

end Interpretation

/--
Stage-local invariant checklist for the plane-to-RS interpretation.

This checklist is the finite-field encoding boundary. It separately records
plane-codeword preservation and the plane-to-RS metric handoff, then exposes
their composed consequences for accepted local cochains.
-/
structure InvariantChecklist
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {T : ReedSolomonTarget.Target F ι}
    {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
    {E : CochainPlane.PlaneExtractionContext R ι}
    {Φ : PlaneEncoding R F}
    (I : Interpretation L T D E Φ) : Prop where
  restrictionNaturality :
    ∀ p : CochainPlane.PlaneShadow R ι,
      Φ.receivedWord (I.projection.naturality.restrictPlane p) =
        I.restrictWord (Φ.receivedWord p)
  syndromeNaturality :
    ∀ p : CochainPlane.PlaneShadow R ι,
      I.wordSyndrome (Φ.receivedWord p) =
        I.mapPlaneSyndrome (I.projection.naturality.planeSyndrome p)
  receivedWordMatchesPlaneEncoding :
    ∀ c : CochainBridge.CommittedCochain,
      I.receivedWord c = Φ.receivedWord (E.projectedPlane c)
  planeCodewordsMapToRSCodewords :
    ∀ p : CochainPlane.PlaneShadow R ι,
      I.planeTarget.Codeword p → T.parameters.Codeword (Φ.receivedWord p)
  planeDistanceControlled :
    ∀ p : CochainPlane.PlaneShadow R ι,
      D.distanceToRS (Φ.receivedWord p) ≤ I.planeTarget.distanceToCode p
  localCodewordsMapToRSCodewords :
    ∀ c : CochainBridge.CommittedCochain,
      L.Codeword c → T.parameters.Codeword (I.receivedWord c)
  distanceControlled :
    ∀ c : CochainBridge.CommittedCochain,
      D.distanceToRS (I.receivedWord c) ≤ L.distanceToCode c

namespace InvariantChecklist

/-- Every plane-to-RS interpretation exposes its stage-local invariants. -/
def of_interpretation
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {T : ReedSolomonTarget.Target F ι}
    {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
    {E : CochainPlane.PlaneExtractionContext R ι}
    {Φ : PlaneEncoding R F}
    (I : Interpretation L T D E Φ) :
    InvariantChecklist I where
  restrictionNaturality := I.restrictionCommutes
  syndromeNaturality := I.syndromeCommutes
  receivedWordMatchesPlaneEncoding := by
    intro c
    rfl
  planeCodewordsMapToRSCodewords := I.mapsPlaneCodewordsToRS
  planeDistanceControlled := I.distanceControlled
  localCodewordsMapToRSCodewords := by
    intro c hc
    exact I.mapsPlaneCodewordsToRS (E.projectedPlane c)
      (I.projection.mapsCodewordsToTarget c hc)
  distanceControlled := by
    intro c
    exact le_trans
      (I.distanceControlled (E.projectedPlane c))
      (I.projection.distanceControlled c)

end InvariantChecklist

end

end CochainReedSolomon
end Proximity
end Hcrypt
