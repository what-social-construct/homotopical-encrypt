module

public import Protocol.Evidence
public import Protocol.Ephemeral
public import Protocol.Oracle
public import Protocol.Consensus
public import Protocol.Coregulator
public import Protocol.Ledger
public import Protocol.Storage

@[expose] public section

/-!
  Protocol-facing import surface.

  This is the one-way Paper 2 layer. Protocol modules may consume the core
  HCP, proximity, gate, and proof-carrying mathematics; those core modules
  must not import `Protocol`.

  Ledger resource transitions, candidate-indexed TCB evidence, and authenticated
  quorum attachment now have typed definitions and preservation theorems.
  Sheaf storage additionally has snapshot/payload contexts, typed stage prefixes,
  exact manifests and a receipt-indexed local consumption lifecycle. Ephemeral
  recovery has integral/encoded rotation laws and recipient-bound delivery
  receipts under explicit channel contracts. Oracle/coregulator surfaces remain
  attachment points. Concrete codec/lift instantiation,
  round/lock/finality and Rust refinement remain separate completion tasks.
-/
