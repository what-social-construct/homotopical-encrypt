import Protocol.Evidence
import Protocol.Ephemeral
import Protocol.Oracle
import Protocol.Consensus
import Protocol.Coregulator
import Protocol.Ledger
import Protocol.Storage

/-!
  Protocol-facing import surface.

  This is the one-way Paper 2 layer. Protocol modules may consume the core
  HCP, proximity, gate, and proof-carrying mathematics; those core modules
  must not import `Protocol`.

  The modules below are initially compatibility facades over the current
  locations. Typed protocol state machines and preservation theorems should be
  introduced here incrementally before old import paths are replaced by
  re-export shims.
-/
