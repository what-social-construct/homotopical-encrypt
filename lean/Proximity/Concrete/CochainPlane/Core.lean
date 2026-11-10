module

public import Proximity.Concrete.PluckerCochain
public import Proximity.Application.Problem

@[expose] public section

/-
  Committed-cochain to plane-shadow projection.

  Paper correspondence:
  - Paper 3: the mathematical cochain-to-plane map and its source-distance
    handoff.
  - Paper 2 supplies the original payload/extraction context; no new
    commitment carrier is introduced.

  This file owns the semantic midpoint between local cochain/syndrome data and
  coding-theoretic interpretations. A committed cochain is projected to a
  two-coordinate plane shadow. Reed-Solomon does not appear here: field
  encoding is a later boundary.
-/

namespace Hcrypt
namespace Proximity
namespace CochainPlane

noncomputable section

variable {R ι : Type}

/-- A two-coordinate evaluation shadow indexed by `ι`. -/
abbrev PlaneShadow (R ι : Type) :=
  ι → Fin 2 → R

/--
Concrete extraction context for reading a committed cochain as a plane shadow.

For each evaluation coordinate `i`, two committed edge coordinates are selected.
The selected serialized integers are interpreted in the semantic plane carrier
`R` by `coefficient`.
-/
structure PlaneExtractionContext (R ι : Type) where
  edgeCount : ℕ
  edgeIndex : ι → Fin 2 → ℕ
  coefficient : ℤ → R

namespace PlaneExtractionContext

/--
The local two-coordinate plane layout is nondegenerate at each evaluation
coordinate: the two plane coordinates are read from distinct committed edges.

This is deliberately local. It does not impose a single global canonical layout
or forbid sharing coordinates between different evaluation positions.
-/
def LocallyNondegenerate (E : PlaneExtractionContext R ι) : Prop :=
  ∀ i : ι, E.edgeIndex i 0 ≠ E.edgeIndex i 1

/-- A committed cochain has the edge shape expected by this plane extraction context. -/
def Aligned (E : PlaneExtractionContext R ι) (c : CochainBridge.CommittedCochain) :
    Prop :=
  c.WellFormed
    ∧ c.n_edge_values = E.edgeCount
    ∧ ∀ (i : ι) (j : Fin 2), E.edgeIndex i j < c.edge_values.length

/--
The concrete plane shadow extracted from a committed cochain.

The `0` fallback is unreachable for aligned cochains; alignment is tracked as a
separate predicate so the extraction function remains total.
-/
def projectedPlane
    (E : PlaneExtractionContext R ι)
    (c : CochainBridge.CommittedCochain) :
    PlaneShadow R ι :=
  fun i j => E.coefficient (c.edge_values.getD (E.edgeIndex i j) 0)

/-- Aligned cochains are well formed at the canonical cochain payload layer. -/
theorem wellFormed_of_aligned
    {E : PlaneExtractionContext R ι}
    {c : CochainBridge.CommittedCochain}
    (hc : E.Aligned c) :
    c.WellFormed :=
  hc.1

/-- Aligned cochains have the edge count selected by the extraction context. -/
theorem edgeCount_eq_of_aligned
    {E : PlaneExtractionContext R ι}
    {c : CochainBridge.CommittedCochain}
    (hc : E.Aligned c) :
    c.n_edge_values = E.edgeCount :=
  hc.2.1

/-- Aligned cochains can be read at every selected plane coordinate. -/
theorem edgeIndex_lt_of_aligned
    {E : PlaneExtractionContext R ι}
    {c : CochainBridge.CommittedCochain}
    (hc : E.Aligned c)
    (i : ι)
    (j : Fin 2) :
    E.edgeIndex i j < c.edge_values.length :=
  hc.2.2 i j

/-- In a locally nondegenerate layout, each plane point reads two distinct edges. -/
theorem edgeIndex_ne_of_locallyNondegenerate
    {E : PlaneExtractionContext R ι}
    (hE : E.LocallyNondegenerate)
    (i : ι) :
    E.edgeIndex i 0 ≠ E.edgeIndex i 1 :=
  hE i

end PlaneExtractionContext

/--
The committed-cochain local syndrome instance used as the source of plane
projection.

Here "global section" means the local cochain test accepts: the payload is a
well-formed global candidate and its syndrome is zero.
-/
def localSyndromeInstance
    {S : Axioms.SheafCoherence}
    (L : PluckerCochain.LocalSyndromeTarget S) :
    SheafProximityInstance where
  Cochain := CochainBridge.CommittedCochain
  GlobalSection := L.Codeword
  disagreement := L.distanceToCode

/-- A target predicate and distance on plane shadows. -/
structure PlaneTarget (R ι : Type) where
  Codeword : PlaneShadow R ι → Prop
  distanceToCode : PlaneShadow R ι → ℝ

namespace PlaneTarget

/-- A plane target as the generic proximity `CodeShadow`. -/
def toCodeShadow (C : PlaneTarget R ι) :
    CodeShadow where
  Word := PlaneShadow R ι
  Codeword := C.Codeword
  distanceToCode := C.distanceToCode

end PlaneTarget

/--
The two typed naturality checks owned by the cochain-to-plane transition.

`restrictionCommutes` is the restriction square. `syndromeCommutes` is the
coboundary/local-syndrome square through a selected semantic plane syndrome.
-/
structure Naturality
    {S : Axioms.SheafCoherence}
    (L : PluckerCochain.LocalSyndromeTarget S)
    (E : PlaneExtractionContext R ι) where
  restrictCochain :
    CochainBridge.CommittedCochain → CochainBridge.CommittedCochain
  restrictPlane : PlaneShadow R ι → PlaneShadow R ι
  PlaneSyndrome : Type
  planeSyndrome : PlaneShadow R ι → PlaneSyndrome
  mapSyndrome : L.Syndrome → PlaneSyndrome
  restrictionCommutes :
    ∀ c : CochainBridge.CommittedCochain,
      E.projectedPlane (restrictCochain c) = restrictPlane (E.projectedPlane c)
  syndromeCommutes :
    ∀ c : CochainBridge.CommittedCochain,
      planeSyndrome (E.projectedPlane c) = mapSyndrome (L.syndrome c)

/--
Concrete projection from committed cochains to a plane-shadow target.

This is not RS-specific. The map is the actual two-coordinate projection out of
`edge_values`; the fields record the target-specific facts needed for it to be
a proximity projection.
-/
structure Projection
    {S : Axioms.SheafCoherence}
    (L : PluckerCochain.LocalSyndromeTarget S)
    (E : PlaneExtractionContext R ι)
    (C : PlaneTarget R ι) where
  naturality : Naturality L E
  layoutNondegenerate :
    E.LocallyNondegenerate
  alignsCodewords :
    ∀ c : CochainBridge.CommittedCochain,
      L.Codeword c → E.Aligned c
  mapsCodewordsToTarget :
    ∀ c : CochainBridge.CommittedCochain,
      L.Codeword c → C.Codeword (E.projectedPlane c)
  distanceControlled :
    ∀ c : CochainBridge.CommittedCochain,
      C.distanceToCode (E.projectedPlane c) ≤ L.distanceToCode c

namespace Projection

/-- A concrete cochain-to-plane projection is an evaluation projection. -/
def toEvaluationProjection
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : PlaneExtractionContext R ι}
    {C : PlaneTarget R ι}
    (π : Projection L E C) :
    EvaluationProjection (localSyndromeInstance L) C.toCodeShadow where
  map := E.projectedPlane
  preservesGlobalSections := π.mapsCodewordsToTarget
  distanceControlled := π.distanceControlled

/-- Accepted local cochain tests project to plane-target codewords. -/
theorem projected_localCodeword_is_targetCodeword
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : PlaneExtractionContext R ι}
    {C : PlaneTarget R ι}
    (π : Projection L E C)
    (c : CochainBridge.CommittedCochain) :
    L.Codeword c → C.Codeword (E.projectedPlane c) :=
  π.mapsCodewordsToTarget c

/-- The projected plane distance is bounded by the cochain local-test distance. -/
theorem projected_distance_le_localSyndromeDistance
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : PlaneExtractionContext R ι}
    {C : PlaneTarget R ι}
    (π : Projection L E C)
    (c : CochainBridge.CommittedCochain) :
    C.distanceToCode (E.projectedPlane c) ≤ L.distanceToCode c :=
  π.distanceControlled c

end Projection

/--
Stage-local invariant checklist for committed-cochain to plane-shadow extraction.

This checklist is specific to the concrete plane midpoint: accepted local
cochain tests must be aligned with the extraction context, the selected edge
coordinates must be readable, and the projected plane target must be controlled
by the local syndrome distance.
-/
structure InvariantChecklist
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : PlaneExtractionContext R ι}
    {C : PlaneTarget R ι}
    (π : Projection L E C) : Prop where
  restrictionNaturality :
    ∀ c : CochainBridge.CommittedCochain,
      E.projectedPlane (π.naturality.restrictCochain c) =
        π.naturality.restrictPlane (E.projectedPlane c)
  syndromeNaturality :
    ∀ c : CochainBridge.CommittedCochain,
      π.naturality.planeSyndrome (E.projectedPlane c) =
        π.naturality.mapSyndrome (L.syndrome c)
  layoutNondegenerate :
    E.LocallyNondegenerate
  codewordsAligned :
    ∀ c : CochainBridge.CommittedCochain,
      L.Codeword c → E.Aligned c
  alignedCodewordsWellFormed :
    ∀ c : CochainBridge.CommittedCochain,
      L.Codeword c → c.WellFormed
  alignedCodewordsHaveExpectedEdgeCount :
    ∀ c : CochainBridge.CommittedCochain,
      L.Codeword c → c.n_edge_values = E.edgeCount
  selectedIndicesInBounds :
    ∀ c : CochainBridge.CommittedCochain,
      L.Codeword c →
        ∀ (i : ι) (j : Fin 2), E.edgeIndex i j < c.edge_values.length
  codewordsMapToPlaneTarget :
    ∀ c : CochainBridge.CommittedCochain,
      L.Codeword c → C.Codeword (E.projectedPlane c)
  distanceControlled :
    ∀ c : CochainBridge.CommittedCochain,
      C.distanceToCode (E.projectedPlane c) ≤ L.distanceToCode c

namespace InvariantChecklist

/-- Every cochain-to-plane projection exposes its stage-local invariants. -/
def of_projection
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : PlaneExtractionContext R ι}
    {C : PlaneTarget R ι}
    (π : Projection L E C) :
    InvariantChecklist π where
  restrictionNaturality := π.naturality.restrictionCommutes
  syndromeNaturality := π.naturality.syndromeCommutes
  layoutNondegenerate := π.layoutNondegenerate
  codewordsAligned := π.alignsCodewords
  alignedCodewordsWellFormed := by
    intro c hc
    exact PlaneExtractionContext.wellFormed_of_aligned (π.alignsCodewords c hc)
  alignedCodewordsHaveExpectedEdgeCount := by
    intro c hc
    exact PlaneExtractionContext.edgeCount_eq_of_aligned (π.alignsCodewords c hc)
  selectedIndicesInBounds := by
    intro c hc i j
    exact PlaneExtractionContext.edgeIndex_lt_of_aligned (π.alignsCodewords c hc) i j
  codewordsMapToPlaneTarget := π.mapsCodewordsToTarget
  distanceControlled := π.distanceControlled

end InvariantChecklist

end

end CochainPlane
end Proximity
end Hcrypt
