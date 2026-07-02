import Proximity.CanonicalRS.BridgeData
import Proximity.ProjectionChain.Core

/-
  Concrete paper-facing MCA surface for the canonical RS endpoint.

  The Proximity Prize paper defines MCA for affine lines
  `{f₁ + γ · f₂}_{γ∈F}` in the final received-word space. This module fixes
  that space to the canonical RS endpoint used by the projection chain:
  words `Fin length → RSField`.
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

/-- Build a paper affine line from final RS words `f₁` and `f₂`. -/
def affineLine (f₁ f₂ : FinalWord) : PaperLine where
  base := f₁
  direction := f₂

/-- The canonical RS block code named by a bridge-data endpoint. -/
def blockCode (β : BridgeData) :
    BlockCode (Fin length) RSField :=
  β.rsTarget.parameters.toBlockCode

/-- Fraction of challenges in a subset of the canonical RS field. -/
noncomputable def challengeFraction (S : Finset RSField) : ℝ :=
  BlockCode.parameterFraction S

/--
The Definition 4.3 bad-challenge set for the canonical RS endpoint.

For a line `L = {f₁ + γ · f₂}`, this is the set of challenges for which there
exists a large coordinate set `S` such that the point `f₁ + γ · f₂` agrees with
the RS code on `S`, but the same `S` does not make `(f₁, f₂)` agree with the
two-fold interleaved code `C≡2`.
-/
noncomputable def badChallengeSet
    (β : BridgeData)
    (δ : ℝ)
    (L : PaperLine) : Finset RSField :=
  (blockCode β).paperMCABadParameterSet (F := RSField) δ L

/-- Fraction of Definition 4.3 bad challenges on a canonical RS affine line. -/
noncomputable def badChallengeFraction
    (β : BridgeData)
    (δ : ℝ)
    (L : PaperLine) : ℝ :=
  challengeFraction (badChallengeSet β δ L)

/-- Paper Definition 4.3 MCA error bound for the canonical RS endpoint. -/
def PaperMCAErrorBound
    (β : BridgeData)
    (δ ε : ℝ) : Prop :=
  β.rsTarget.parameters.PaperMutualCorrelatedAgreementErrorBound δ ε

/-- The canonical bridge data carries the paper Definition 4.3 MCA bound. -/
theorem paperMCAErrorBound
    (β : BridgeData) :
    PaperMCAErrorBound
      β
      β.johnsonRadiusReal
      ((β.rsTarget.threshold : ℝ) / (Fintype.card RSField : ℝ)) :=
  β.paperMutualCorrelatedAgreementErrorBound

/--
Concrete bad-challenge fraction bound on every canonical RS affine line.

This is exactly the paper's `εmca(C, δ) ≤ ε` statement specialized to the
canonical RS endpoint and its Johnson-below radius.
-/
theorem badChallengeFraction_le
    (β : BridgeData)
    (L : PaperLine) :
    badChallengeFraction β β.johnsonRadiusReal L ≤
      ((β.rsTarget.threshold : ℝ) / (Fintype.card RSField : ℝ)) := by
  change
    BlockCode.parameterFraction
        ((blockCode β).paperMCABadParameterSet
          (F := RSField) β.johnsonRadiusReal L) ≤
      ((β.rsTarget.threshold : ℝ) / (Fintype.card RSField : ℝ))
  exact β.paperMutualCorrelatedAgreementErrorBound L

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
The paper affine line in final RS coordinates induced by two projected source
witnesses.

The paper quantifies over arbitrary final words `f₁,f₂`; this is the
projection-chain specialization where those words are endpoint coordinates
produced by `Γ`.
-/
def projectionLine
    (Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement)
    (f₁ f₂ : FrameWitness n r) :
    PaperLine :=
  affineLine (projectionWord Γ f₁) (projectionWord Γ f₂)

/-- The Definition 4.3 bad challenges for a projection-induced final line. -/
noncomputable def projectionBadChallengeSet
    (Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement)
    (f₁ f₂ : FrameWitness n r) :
    Finset RSField :=
  badChallengeSet β β.johnsonRadiusReal (projectionLine Γ f₁ f₂)

/--
MCA applies after the projection chain lands in final RS coordinates.

For every affine line whose base and direction are final words produced by the
projection chain, the paper Definition 4.3 bad-challenge fraction is bounded by
the canonical MCA error threshold.
-/
theorem projectionBadChallengeFraction_le
    (Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement)
    (f₁ f₂ : FrameWitness n r) :
    challengeFraction (projectionBadChallengeSet Γ f₁ f₂) ≤
      ((β.rsTarget.threshold : ℝ) / (Fintype.card RSField : ℝ)) := by
  change
    badChallengeFraction β β.johnsonRadiusReal (projectionLine Γ f₁ f₂) ≤
      ((β.rsTarget.threshold : ℝ) / (Fintype.card RSField : ℝ))
  exact badChallengeFraction_le β (projectionLine Γ f₁ f₂)

end ProjectionChain

end

end MCA
end CanonicalRS
end Proximity
end Hcrypt
