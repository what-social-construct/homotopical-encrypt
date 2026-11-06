module

public import Axioms.Ledger
public import Chain
public import Protocol.Ephemeral
public import Protocol.Evidence
public import Protocol.Ledger.State
public import Protocol.Ledger.Transition
public import Protocol.Ledger.Sheaf
public import Protocol.Ledger.Certified

@[expose] public section

/-!
  Ledger and accepted-transition attachment point.

  The leaf modules now define the first conservative resource transition,
  typed candidates, replay exclusion, exact conservation and accepted-history
  invariants. The evidence/certified adapters reuse TCB artifacts and existing
  quorum certificates for the same candidate and roots. `Ledger.Sheaf` reuses
  the existing cellular-sheaf snapshot and accepted-payload interpretation.

  `Chain.lean` remains a compatibility import. Its legacy validator identity,
  fork choice and raw cochain-sum balance are not the semantics of this kernel.
-/
