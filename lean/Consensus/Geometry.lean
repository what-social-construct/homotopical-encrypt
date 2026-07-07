import Axioms.Grassmannian

/-
  Consensus geometry façade.

  Paper correspondence:
  - Paper 2: consensus geometry and Proof-of-Value assembly.
  - Paper 1 Section 7: sequel boundary only.

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
