import Proximity.Projection
import Axioms.CochainCommitment.Payload
import Axioms.SheafCoherence

/-
  Cochain/sheaf bridge for proximity.

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
Global-section candidate predicate for an existing committed cochain.

The payload must be well formed, and the surrounding sheaf coherence contract
must hold. This keeps the cochain object itself identical to the tested
commitment data used elsewhere in Lean/Rust.
-/
def GlobalSectionCandidate
    (S : Axioms.SheafCoherence)
    (c : CommittedCochain) : Prop :=
  c.WellFormed ∧ Axioms.SheafCoherenceWellFormed S

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
  GlobalSection := GlobalSectionCandidate S
  disagreement := disagreement

/-- A global-section candidate has a well-formed cochain commitment payload. -/
theorem wellFormed_of_globalSectionCandidate
    {S : Axioms.SheafCoherence} {c : CommittedCochain}
    (hc : GlobalSectionCandidate S c) :
    c.WellFormed :=
  hc.1

/--
A global-section candidate provides the structural sheaf preconditions used by
proximity and transaction-stage validation: `δ² = 0` and
Laplacian-from-coboundary.
-/
theorem structural_preconditions_of_globalSectionCandidate
    {S : Axioms.SheafCoherence} {c : CommittedCochain}
    (hc : GlobalSectionCandidate S c) :
    S.Complex.CoboundarySquaresZero ∧ S.Hodge.LaplacianFromCoboundary :=
  Axioms.coherence_implies_structural_preconditions S hc.2

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
