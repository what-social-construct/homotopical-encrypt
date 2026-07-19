import Proximity.Projection
import Axioms.CochainCommitment.Payload
import Axioms.SheafCoherence

/-
  Cochain/sheaf bridge for proximity.

  Paper correspondence:
  - Paper 1 Section 6: committed cochain/local-syndrome projection stage.
  - Paper 1 Section 5: reuses the commitment payload object defined there.

  This module connects the lightweight proximity vocabulary to the existing
  hcrypt cochain/sheaf interfaces. It reuses `CochainCommitmentData` as the
  committed cochain carrier, so proximity statements talk about the same object
  that the storage and transaction layers already validate.

  This is a domain bridge, not an axiom bundle: `Axioms` states the contracts;
  `Proximity` owns the projection/proximity interpretation of those contracts.
-/

namespace Hcrypt
namespace Proximity
namespace CochainBridge

/-- The runtime-tested cochain payload is the hcrypt cochain carrier. -/
abbrev CommittedCochain := Axioms.CochainCommitmentData

namespace CommittedCochain

/--
An accepted committed one-cocycle in its sheaf context.

This is the Axioms-level semantic contract: the payload is wire-well-formed,
the sheaf is coherent, the topology binding holds, and the payload decodes as
an exact one-cochain.  Exactness then implies the cocycle equation.
-/
abbrev AcceptedCocycle
    (S : Axioms.SheafCoherence)
    (c : CommittedCochain) : Prop :=
  Axioms.CommittedCochainWellFormed S c

/-- Compatibility name for the exact predicate used by the generic proximity record. -/
abbrev GlobalSectionCandidate := AcceptedCocycle

/--
Committed-cochain proximity instance.

`disagreement` is supplied by the concrete bridge using this instance: it can be
`‖δc‖`, a spectral residual, a fixed-point proximity score, or a summary such
as the commitment-sum residual. The cochain carrier remains
`CochainCommitmentData`.
-/
def proximityInstance
    (S : Axioms.SheafCoherence)
    (disagreement : CommittedCochain → ℝ) :
    SheafProximityInstance where
  Cochain := CommittedCochain
  GlobalSection := AcceptedCocycle S
  disagreement := disagreement

/-- A global-section candidate has a well-formed cochain commitment payload. -/
theorem wellFormed_of_globalSectionCandidate
    {S : Axioms.SheafCoherence} {c : CommittedCochain}
    (hc : GlobalSectionCandidate S c) :
    c.WellFormed :=
  Axioms.cochain_wellFormed_of_committedCochainWellFormed hc

/--
A global-section candidate provides the structural sheaf preconditions used by
proximity and transaction-stage validation: adjacent coboundaries compose to
zero, and the Laplacian is built from coboundaries.
-/
theorem structural_preconditions_of_globalSectionCandidate
    {S : Axioms.SheafCoherence} {c : CommittedCochain}
    (hc : GlobalSectionCandidate S c) :
    S.Complex.CoboundarySquaresZero ∧ S.Hodge.LaplacianFromCoboundary :=
  Axioms.coherence_implies_structural_preconditions S
    (Axioms.sheaf_wellFormed_of_committedCochainWellFormed hc)

/-- An accepted committed cochain is bound to the supplied sheaf context. -/
theorem boundToSheaf_of_globalSectionCandidate
    {S : Axioms.SheafCoherence} {c : CommittedCochain}
    (hc : GlobalSectionCandidate S c) :
    S.CommittedCochains.BoundToSheaf c :=
  Axioms.boundToSheaf_of_committedCochainWellFormed hc

/-- An accepted committed cochain decodes as an exact degree-one cochain. -/
theorem exactOneCochain_of_globalSectionCandidate
    {S : Axioms.SheafCoherence} {c : CommittedCochain}
    (hc : GlobalSectionCandidate S c) :
    Axioms.RepresentsExactOneCochain S c :=
  Axioms.exactOneCochain_of_committedCochainWellFormed hc

/-- An accepted committed cochain satisfies the degree-one cocycle equation. -/
theorem oneCocycle_of_globalSectionCandidate
    {S : Axioms.SheafCoherence} {c : CommittedCochain}
    (hc : GlobalSectionCandidate S c) :
    Axioms.IsOneCocycle S c :=
  Axioms.oneCocycle_of_committedCochainWellFormed hc

/-- A global-section candidate has nonempty edge/cochain data. -/
theorem edge_values_nonempty_of_globalSectionCandidate
    {S : Axioms.SheafCoherence} {c : CommittedCochain}
    (hc : GlobalSectionCandidate S c) :
    c.edge_values.length > 0 :=
  Axioms.CochainCommitmentData.edge_values_nonempty_of_wellFormed
    (wellFormed_of_globalSectionCandidate hc)

/-- A global-section candidate uses a modulus accepted by the cochain layer. -/
theorem modulus_gt_one_of_globalSectionCandidate
    {S : Axioms.SheafCoherence} {c : CommittedCochain}
    (hc : GlobalSectionCandidate S c) :
    c.modulus > 1 :=
  Axioms.CochainCommitmentData.modulus_gt_one_of_wellFormed
    (wellFormed_of_globalSectionCandidate hc)

end CommittedCochain

end CochainBridge
end Proximity
end Hcrypt
