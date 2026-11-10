module

public import Axioms.Grassmannian

@[expose] public section

/-
  Consensus geometry façade.

  Paper correspondence:
  - Paper 2: consensus-geometry and Proof-of-Value contracts.
  - This facade reuses Axioms.Grassmannian; it is outside Paper 1's selected
    statement crosswalk.

  The underlying assumption/spec interface remains in `Axioms.Grassmannian`.
  This module exposes the same objects from the consensus assembly layer.
-/

namespace Hcrypt
namespace Consensus

/-- Validator eligibility/weight geometry interface. -/
abbrev PluckerEligibility := Hcrypt.Axioms.PluckerEligibility

/-- Full consensus geometry assumption bundle. -/
abbrev ConsensusGeometry := Hcrypt.Axioms.ConsensusGeometry

/-- Well-formedness for consensus geometry. -/
abbrev ConsensusGeometryWellFormed :=
  Hcrypt.Axioms.ConsensusGeometryWellFormed

end Consensus
end Hcrypt
