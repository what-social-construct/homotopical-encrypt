import Proximity.CochainPlane.Core

/-
  Concrete committed-cochain to plane-shadow extraction inputs.

  Paper correspondence:
  - Paper 1 Section 6: concrete cochain-to-plane projection inputs and
    alignment obligations.

  `CochainPlane.Core` defines the generic projection interface. This module
  packages the concrete choices needed to instantiate that interface: selected
  edge coordinates, coefficient interpretation, a plane target, and the local
  alignment/distance obligations.
-/

namespace Hcrypt
namespace Proximity
namespace CochainPlane
namespace Concrete

noncomputable section

variable {R ι : Type}

/--
Construction inputs for the committed-cochain to plane-shadow projection.

The extraction context fixes which committed edge coordinates are read for
each plane coordinate. The target and obligations record the semantic plane
predicate and metric handoff for this local projection step.
-/
structure ProjectionInputs
    {S : Axioms.SheafCoherence}
    (L : PluckerCochain.LocalSyndromeTarget S)
    (R ι : Type) where
  extraction : PlaneExtractionContext R ι
  target : PlaneTarget R ι
  naturality : Naturality L extraction
  layoutNondegenerate :
    extraction.LocallyNondegenerate
  alignsCodewords :
    ∀ c : CochainBridge.CommittedCochain,
      L.Codeword c → extraction.Aligned c
  mapsCodewordsToTarget :
    ∀ c : CochainBridge.CommittedCochain,
      L.Codeword c → target.Codeword (extraction.projectedPlane c)
  distanceControlled :
    ∀ c : CochainBridge.CommittedCochain,
      target.distanceToCode (extraction.projectedPlane c) ≤ L.distanceToCode c

namespace ProjectionInputs

variable {S : Axioms.SheafCoherence}
variable {L : PluckerCochain.LocalSyndromeTarget S}

/-- Build the generic cochain-plane projection from concrete extraction inputs. -/
def toProjection
    (I : ProjectionInputs L R ι) :
    Projection L I.extraction I.target where
  naturality := I.naturality
  layoutNondegenerate := I.layoutNondegenerate
  alignsCodewords := I.alignsCodewords
  mapsCodewordsToTarget := I.mapsCodewordsToTarget
  distanceControlled := I.distanceControlled

/-- Concrete inputs expose the standard stage-local invariant checklist. -/
def toInvariantChecklist
    (I : ProjectionInputs L R ι) :
    InvariantChecklist I.toProjection :=
  InvariantChecklist.of_projection I.toProjection

/-- Accepted local cochain tests are aligned with the concrete extraction layout. -/
theorem aligned_of_codeword
    (I : ProjectionInputs L R ι)
    {c : CochainBridge.CommittedCochain}
    (hc : L.Codeword c) :
    I.extraction.Aligned c :=
  I.alignsCodewords c hc

/-- Each concrete plane point reads two distinct committed edge coordinates. -/
theorem edgeIndex_ne
    (I : ProjectionInputs L R ι)
    (i : ι) :
    I.extraction.edgeIndex i 0 ≠ I.extraction.edgeIndex i 1 :=
  PlaneExtractionContext.edgeIndex_ne_of_locallyNondegenerate
    I.layoutNondegenerate i

/-- Accepted local cochain tests project to plane-target codewords. -/
theorem codeword_maps_to_planeTarget
    (I : ProjectionInputs L R ι)
    {c : CochainBridge.CommittedCochain}
    (hc : L.Codeword c) :
    I.target.Codeword (I.extraction.projectedPlane c) :=
  I.mapsCodewordsToTarget c hc

/-- The concrete cochain-plane projection satisfies its local distance handoff. -/
theorem projected_distance_le_localSyndromeDistance
    (I : ProjectionInputs L R ι)
    (c : CochainBridge.CommittedCochain) :
    I.target.distanceToCode (I.extraction.projectedPlane c) ≤
      L.distanceToCode c :=
  I.distanceControlled c

end ProjectionInputs

end

end Concrete
end CochainPlane
end Proximity
end Hcrypt
