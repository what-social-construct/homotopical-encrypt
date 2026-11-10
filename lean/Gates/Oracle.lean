module

public import Axioms.OracleModality

@[expose] public section

/-
  Oracle gate.

  Paper correspondence:
  - Paper 2: oracle/Heyting judgments and their consumption as protocol
    evidence.
  - This gate facade is outside Paper 1's selected semantic fragment.

  This file exposes the Heyting/tri-valued consensus classification layer under
  the `Gates` namespace. The detailed semantics remain in
  `Axioms.OracleModality`.
-/

namespace Hcrypt
namespace Gates

/-- Oracle spectral classification result. -/
abbrev SpectralJudgment := Hcrypt.Axioms.SpectralJudgment

/-- Consensus action induced by an oracle judgment. -/
abbrev ConsensusAction := Hcrypt.Axioms.ConsensusAction

/-- Canonical judgment-to-action map. -/
abbrev judgmentToAction :=
  Hcrypt.Axioms.judgmentToAction

/-- Oracle answer object used by the modality layer. -/
abbrev OracleAnswer := Hcrypt.Axioms.OracleAnswer

/-- Oracle eta-2 node gate interface. -/
abbrev OracleEta2 := Hcrypt.Axioms.OracleEta2

/-- Canonical executable admissibility predicate used for eta-2 wiring. -/
abbrev CanonicalConsensusAdmissible :=
  Hcrypt.Axioms.CanonicalConsensusAdmissible

/-- Canonical eta-2 constructor, parameterized by identity-hash stability. -/
abbrev canonicalEta2 :=
  Hcrypt.Axioms.canonicalEta2

end Gates
end Hcrypt
