module

public import Axioms.CochainCommitment.Payload
public import Axioms.CochainCommitment.Security
public import Axioms.SheafCoherence

@[expose] public section

/-
  Public import surface for cochain commitment payloads, security axioms, and
  the sheaf-semantic well-formedness contract.

  Paper correspondence:
  - Paper 1 Section 5: cochain commitment payloads, topology compatibility, and
    security interfaces.
  - Paper 2: protocol evidence and chain consumption of commitment surfaces.
-/
