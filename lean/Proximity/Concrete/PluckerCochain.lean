import Proximity.Concrete.GrassmannianPlucker
import Proximity.Concrete.CochainBridge
import Proximity.Application.Problem

/-
  Plucker-to-cochain proximity bridge.

  Paper correspondence:
  - Paper 1 Section 6: Plucker-to-committed-cochain/local-syndrome stage.
  - Paper 1 Section 5: consumes the cochain commitment payload interface.

  This is the next projection stage after `GrassmannianPlucker`: a valid
  Plucker/exterior shadow is encoded as the committed cochain object already
  used by the storage and transaction layers, then checked by a local syndrome
  test. Reed-Solomon targets are intentionally not imported here; this file is
  only the Plucker -> cochain/local-test step.
-/

namespace Hcrypt
namespace Proximity
namespace PluckerCochain

open GrassmannianPlucker

noncomputable section

variable {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}

/-- A Plucker frame is valid when both raw exterior coordinates and public shadow are valid. -/
def ValidFrame (P : FramedSystem n r) (W : FrameWitness n r) : Prop :=
  P.ValidRawCoordinate W ∧ P.ValidShadow W

namespace ValidFrame

/-- Sound framed systems validate every frame witness. -/
theorem of_sound
    {P : FramedSystem n r}
    (hP : P.Sound)
    (W : FrameWitness n r) :
    ValidFrame P W :=
  ⟨P.validRawCoordinate_of_sound hP W, P.validShadow_of_sound hP W⟩

end ValidFrame

/--
The Plucker-stage proximity instance.

The source datum is a concrete frame witness. `GlobalSection` means the Plucker
coordinate and its normalized public shadow satisfy the algebraic validity
checks. The disagreement score is supplied by the concrete construction.
-/
def pluckerInstance
    (P : FramedSystem n r)
    (pluckerDisagreement : FrameWitness n r → ℝ) :
    SheafProximityInstance where
  Cochain := FrameWitness n r
  GlobalSection := ValidFrame P
  disagreement := pluckerDisagreement

/--
Cochain-side local syndrome target.

`Syndrome` abstracts the local obstruction, e.g. a coboundary residual, parity
check, commitment-sum residual, or another finite local test. Codewords are
well-formed committed cochains whose syndrome is accepted as zero.
-/
structure LocalSyndromeTarget (S : Axioms.SheafCoherence) where
  Syndrome : Type
  syndrome : CochainBridge.CommittedCochain → Syndrome
  ZeroSyndrome : Syndrome → Prop
  distanceToCode : CochainBridge.CommittedCochain → ℝ
  zeroSyndrome_of_globalCandidate :
    ∀ c : CochainBridge.CommittedCochain,
      CochainBridge.CommittedCochain.GlobalSectionCandidate S c →
        ZeroSyndrome (syndrome c)

namespace LocalSyndromeTarget

/-- Codeword predicate induced by a committed-cochain local syndrome test. -/
def Codeword
    {S : Axioms.SheafCoherence}
    (T : LocalSyndromeTarget S)
    (c : CochainBridge.CommittedCochain) : Prop :=
  CochainBridge.CommittedCochain.GlobalSectionCandidate S c
    ∧ T.ZeroSyndrome (T.syndrome c)

/-- The code-shadow surface of the committed-cochain local test. -/
def toCodeShadow
    {S : Axioms.SheafCoherence}
    (T : LocalSyndromeTarget S) :
    CodeShadow where
  Word := CochainBridge.CommittedCochain
  Codeword := T.Codeword
  distanceToCode := T.distanceToCode

/-- Global-section candidates are codewords for the local syndrome target. -/
theorem codeword_of_globalCandidate
    {S : Axioms.SheafCoherence}
    (T : LocalSyndromeTarget S)
    {c : CochainBridge.CommittedCochain}
    (hc : CochainBridge.CommittedCochain.GlobalSectionCandidate S c) :
    T.Codeword c :=
  ⟨hc, T.zeroSyndrome_of_globalCandidate c hc⟩

end LocalSyndromeTarget

/--
Projection from a Plucker public shadow to the committed-cochain local-test
target.

The important proof obligation is `distanceControlled`: the cochain/syndrome
distance must not exceed the Plucker-stage disagreement budget.
-/
structure Projection
    (P : FramedSystem n r)
    (S : Axioms.SheafCoherence)
    (T : LocalSyndromeTarget S)
    (pluckerDisagreement : FrameWitness n r → ℝ) where
  encode : P.Shadow → CochainBridge.CommittedCochain
  preservesValidFrame :
    ∀ W : FrameWitness n r,
      ValidFrame P W →
        CochainBridge.CommittedCochain.GlobalSectionCandidate S
          (encode (P.publicShadow W))
  distanceControlled :
    ∀ W : FrameWitness n r,
      T.distanceToCode (encode (P.publicShadow W)) ≤ pluckerDisagreement W

namespace Projection

/-- A Plucker-to-cochain bridge is an evaluation projection. -/
def toEvaluationProjection
    {P : FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {T : LocalSyndromeTarget S}
    {pluckerDisagreement : FrameWitness n r → ℝ}
    (π : Projection P S T pluckerDisagreement) :
    EvaluationProjection
      (pluckerInstance P pluckerDisagreement)
      T.toCodeShadow where
  map := fun W => π.encode (P.publicShadow W)
  preservesGlobalSections := by
    intro W hW
    exact T.codeword_of_globalCandidate (π.preservesValidFrame W hW)
  distanceControlled := π.distanceControlled

/-- Valid Plucker frames project to accepted committed-cochain local tests. -/
theorem projected_validFrame_is_codeword
    {P : FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {T : LocalSyndromeTarget S}
    {pluckerDisagreement : FrameWitness n r → ℝ}
    (π : Projection P S T pluckerDisagreement)
    (W : FrameWitness n r) :
    ValidFrame P W →
      T.toCodeShadow.Codeword ((π.toEvaluationProjection).map W) :=
  projected_global_section_is_codeword π.toEvaluationProjection W

/-- The cochain local-test distance is bounded by the Plucker disagreement. -/
theorem projected_distance_le_pluckerDisagreement
    {P : FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {T : LocalSyndromeTarget S}
    {pluckerDisagreement : FrameWitness n r → ℝ}
    (π : Projection P S T pluckerDisagreement)
    (W : FrameWitness n r) :
    T.distanceToCode (π.encode (P.publicShadow W)) ≤ pluckerDisagreement W :=
  π.distanceControlled W

end Projection

/--
Stage-local invariant checklist for the Plucker-to-cochain projection.

This is deliberately not a gap statement. It only records the local facts this
stage must supply before a later projection-chain/orchestrator can compose it
with the plane and RS boundaries.
-/
structure InvariantChecklist
    {P : FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {T : LocalSyndromeTarget S}
    {pluckerDisagreement : FrameWitness n r → ℝ}
    (π : Projection P S T pluckerDisagreement) : Prop where
  validFramesMapToGlobalCandidates :
    ∀ W : FrameWitness n r,
      ValidFrame P W →
        CochainBridge.CommittedCochain.GlobalSectionCandidate S
          (π.encode (P.publicShadow W))
  validFramesMapToLocalCodewords :
    ∀ W : FrameWitness n r,
      ValidFrame P W →
        T.Codeword (π.encode (P.publicShadow W))
  distanceControlled :
    ∀ W : FrameWitness n r,
      T.distanceToCode (π.encode (P.publicShadow W)) ≤ pluckerDisagreement W

namespace InvariantChecklist

/-- Every Plucker-to-cochain projection exposes its stage-local invariants. -/
def of_projection
    {P : FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {T : LocalSyndromeTarget S}
    {pluckerDisagreement : FrameWitness n r → ℝ}
    (π : Projection P S T pluckerDisagreement) :
    InvariantChecklist π where
  validFramesMapToGlobalCandidates := π.preservesValidFrame
  validFramesMapToLocalCodewords := by
    intro W hW
    exact T.codeword_of_globalCandidate (π.preservesValidFrame W hW)
  distanceControlled := π.distanceControlled

end InvariantChecklist

end

end PluckerCochain
end Proximity
end Hcrypt
