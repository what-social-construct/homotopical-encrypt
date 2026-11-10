module

public import Axioms.CochainCommitment.Payload
public import Axioms.CochainCommitment.Security
public import Axioms.SheafCoherence

@[expose] public section

/-
  Public import surface for cochain commitment payloads, security axioms, and
  the sheaf-semantic well-formedness contract.

  Paper correspondence:
  - Paper 2: the shared cochain payload, semantic acceptance and
    commitment-security interfaces.
  - Paper 3 consumes the existing payload through its declared quantitative
    source profile.-/
