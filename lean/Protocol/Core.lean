module

public import Protocol.Ledger.Transition
public import Protocol.Ledger.Sheaf
public import Protocol.Evidence.Transition
public import Protocol.Ledger.Certified

@[expose] public section

/-!
# Bounded protocol transition core

Focused public-review entry point for conservative resource transitions,
the existing sheaf-snapshot adapter, candidate-bound TCB evidence and quorum
attachment. It does not import the legacy `Chain` model or the deferred
oracle/coregulator facades or the separate storage/proximity layer.
`Protocol.Storage.Core` exports that checkpoint layer. `Protocol.lean` remains the
backward-compatible broad aggregate.
-/
