module

public import Proximity.Concrete.CanonicalRS.BridgeData
public import Proximity.Concrete.ProjectionChain.Core

@[expose] public section

/-
  Canonical MCA affine lines.

  Paper correspondence:
  - Paper 1 Section 6: affine-line surface for mutual correlated agreement.

  The generic RS layer defines the paper vocabulary for affine combinations.
  This file owns the canonical object used by the concrete projection chain:
  final RS words in the canonical endpoint. The well-formedness facts are
  implicit in the types and exposed by definitional lemmas.
-/

namespace Hcrypt
namespace Proximity
namespace CanonicalRS
namespace MCA

noncomputable section

/-- The final received-word coordinate space of the canonical projection chain. -/
abbrev FinalWord :=
  Word (Fin length) RSField

/-- The paper's affine-line scheme in the final canonical RS word space. -/
abbrev PaperLine :=
  AffineLine RSField (Fin length) RSField

/--
Canonical affine line used by the MCA endpoint.

The paper quantifies over pairs `f₁, f₂`, so this object deliberately stores a
base word and a direction word. Degenerate directions are allowed, matching the
paper's maximum over all pairs.
-/
structure Line where
  base : FinalWord
  direction : FinalWord

namespace Line

/-- Interpret a canonical MCA line as the paper's raw affine-line object. -/
def toPaperLine (L : Line) : PaperLine where
  base := L.base
  direction := L.direction

/-- Build a canonical MCA line from final RS words. -/
def ofWords (f₁ f₂ : FinalWord) : Line where
  base := f₁
  direction := f₂

/-- Build a canonical MCA line from the raw paper affine-line object. -/
def ofPaperLine (L : PaperLine) : Line where
  base := L.base
  direction := L.direction

/-- The point on the canonical line selected by challenge `γ`. -/
def point (L : Line) (γ : RSField) : FinalWord :=
  L.toPaperLine.point γ

/-- The raw paper line has the same base as the canonical line. -/
@[simp]
theorem toPaperLine_base (L : Line) :
    L.toPaperLine.base = L.base :=
  rfl

/-- The raw paper line has the same direction as the canonical line. -/
@[simp]
theorem toPaperLine_direction (L : Line) :
    L.toPaperLine.direction = L.direction :=
  rfl

/-- Converting a raw paper line to the canonical line object and back is identity. -/
@[simp]
theorem toPaperLine_ofPaperLine (L : PaperLine) :
    (ofPaperLine L).toPaperLine = L := by
  cases L
  rfl

/-- Converting a canonical line to the raw paper line and back is identity. -/
@[simp]
theorem ofPaperLine_toPaperLine (L : Line) :
    ofPaperLine L.toPaperLine = L := by
  cases L
  rfl

/-- Canonical line evaluation is coordinatewise `base + γ • direction`. -/
@[simp]
theorem point_apply (L : Line) (γ : RSField) (i : Fin length) :
    L.point γ i = L.base i + γ • L.direction i :=
  rfl

/-- Build the canonical MCA line from the two coordinates of one integer plane. -/
def ofPlaneShadow
    (p : CochainPlane.PlaneShadow ℤ (Fin length)) :
    Line :=
  ofPaperLine (integerPlaneLine p)

/-- The first plane coordinate is the base word after reduction to the field. -/
@[simp]
theorem ofPlaneShadow_base_apply
    (p : CochainPlane.PlaneShadow ℤ (Fin length))
    (i : Fin length) :
    (ofPlaneShadow p).base i = ((p i 0 : ℤ) : RSField) :=
  rfl

/-- The second plane coordinate is the direction word after reduction to the field. -/
@[simp]
theorem ofPlaneShadow_direction_apply
    (p : CochainPlane.PlaneShadow ℤ (Fin length))
    (i : Fin length) :
    (ofPlaneShadow p).direction i = ((p i 1 : ℤ) : RSField) :=
  rfl

/-- The interleaved pair underlying a plane-induced line is the reduced plane. -/
@[simp]
theorem pairWord_ofPlaneShadow
    (p : CochainPlane.PlaneShadow ℤ (Fin length)) :
    BlockCode.pairWord (ofPlaneShadow p).base (ofPlaneShadow p).direction =
      reduceIntegerPlane p := by
  exact pairWord_integerPlaneLine p

/-- Evaluating the plane-induced line is the challenge-indexed plane encoding. -/
theorem ofPlaneShadow_point
    (p : CochainPlane.PlaneShadow ℤ (Fin length))
    (γ : RSField) :
    (ofPlaneShadow p).point γ =
      (integerPlaneEncodingAt γ).receivedWord p := by
  exact (integerPlaneEncodingAt_receivedWord p γ).symm

section ProjectionChain

open GrassmannianPlucker

variable {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
variable
    {β : BridgeData}
    {P : FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}
    {pluckerDisagreement : FrameWitness n r → ℝ}

/-- The final canonical RS word produced by a concrete projection chain. -/
def projectionWord
    (Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement)
    (W : FrameWitness n r) :
    FinalWord :=
  Γ.receivedWord W

/--
Canonical MCA line induced by the two coordinates of one projected plane.

Unlike `ofProjection`, this is the concrete bridge from the cochain-plane
object to the paper pair `(f₁,f₂)`.
-/
def ofProjectedPlane
    (Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement)
    (W : FrameWitness n r) :
    Line :=
  ofPlaneShadow (Γ.planeShadow W)

/-- A projected plane line evaluates through the corresponding challenge encoding. -/
theorem ofProjectedPlane_point
    (Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement)
    (W : FrameWitness n r)
    (γ : RSField) :
    (ofProjectedPlane Γ W).point γ =
      (β.planeEncodingAt γ).receivedWord (Γ.planeShadow W) := by
  exact ofPlaneShadow_point (Γ.planeShadow W) γ

/-- At the fixed canonical challenge, the plane line gives the chain's received word. -/
theorem ofProjectedPlane_point_canonicalMix
    (Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement)
    (W : FrameWitness n r) :
    (ofProjectedPlane Γ W).point canonicalMix = Γ.receivedWord W := by
  rfl

/-- The paper pair of a projected plane line is its reduced plane shadow. -/
@[simp]
theorem pairWord_ofProjectedPlane
    (Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement)
    (W : FrameWitness n r) :
    BlockCode.pairWord
        (ofProjectedPlane Γ W).base
        (ofProjectedPlane Γ W).direction =
      reduceIntegerPlane (Γ.planeShadow W) := by
  exact pairWord_ofPlaneShadow (Γ.planeShadow W)

/--
Canonical MCA line induced by two projected source witnesses.

This is the concrete projection-chain specialization of the paper pair
`(f₁, f₂)`.
-/
def ofProjection
    (Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement)
    (f₁ f₂ : FrameWitness n r) :
    Line :=
  ofWords (projectionWord Γ f₁) (projectionWord Γ f₂)

/-- The base of a projection-induced line is the first projected final RS word. -/
@[simp]
theorem ofProjection_base
    (Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement)
    (f₁ f₂ : FrameWitness n r) :
    (ofProjection Γ f₁ f₂).base = projectionWord Γ f₁ :=
  rfl

/-- The direction of a projection-induced line is the second projected final RS word. -/
@[simp]
theorem ofProjection_direction
    (Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement)
    (f₁ f₂ : FrameWitness n r) :
    (ofProjection Γ f₁ f₂).direction = projectionWord Γ f₂ :=
  rfl

/-- Projection-induced line evaluation is coordinatewise final-word combination. -/
@[simp]
theorem ofProjection_point_apply
    (Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement)
    (f₁ f₂ : FrameWitness n r)
    (γ : RSField)
    (i : Fin length) :
    (ofProjection Γ f₁ f₂).point γ i =
      projectionWord Γ f₁ i + γ • projectionWord Γ f₂ i :=
  rfl

end ProjectionChain

end Line

end

end MCA
end CanonicalRS
end Proximity
end Hcrypt
