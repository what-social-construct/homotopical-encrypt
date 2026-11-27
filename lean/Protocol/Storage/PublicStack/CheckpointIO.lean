module

public import Protocol.Storage.PublicStack.LedgerCheckpoint
public import Protocol.Storage.PublicStack.HistorySync

public section

/-!
# Authenticated fast reopening of a checked ledger state

An issuer checks the active history under its original verifier and trusted
initial state, then stores the exact successor as a named checkpoint. A
reader obtains that checkpoint's digest from the issuer independently of
the store. The history index root and the checkpoint digest have distinct
canonical preimages.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.PublicStack

open System (FilePath)
open Sheaf CellularSheaf
open TCB.PrimitiveChecks (Bytes)
open Transfer.Owned (Config)

variable {Vertex Edge Face Asset Receipt : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

/-- The complete context and semantic snapshot name agree with the caller's scope. -/
def LedgerCheckpoint.Record.matchesContext (record : LedgerCheckpoint.Record)
    (expected : ContextKey) : Bool :=
  decide (record.context = expected) &&
    (List.ofFn record.state.snapshotRoot == List.ofFn expected.snapshotRoot)

/-- Store an immutable canonical checkpoint under the caller's writer lock.
The caller establishes the provenance of the state before authenticating the digest. -/
def storeLedgerCheckpoint (store : FilePath) (record : LedgerCheckpoint.Record) :
    IO (Option Sha256.DigestBytes) := do
  unless List.ofFn record.state.snapshotRoot == List.ofFn record.context.snapshotRoot do
    return none
  let bytes := LedgerCheckpoint.encode record
  let digest := Sha256.digestBytes bytes
  let path := LocalObjects.objectPath store (Sha256.toHash32 digest)
  unless ← LocalObjects.putImmutable path bytes do return none
  return some digest

/-- Issue the canonical state after a successful replay of the active history.
An issuer can authenticate the returned digest for later readers. -/
def issueLedgerCheckpoint [DecidableEq Asset] (store : FilePath) (historyRoot : TCB.Hash32)
    (initial : Config F Bytes Asset Receipt) : IO (Option Sha256.DigestBytes) :=
  LocalObjects.withWriter store do
    let some state ← openHistory store historyRoot initial | return none
    storeLedgerCheckpoint store ⟨historyRoot, initial.context.key, state⟩

/-- Verify the named checkpoint and reopen its complete state directly. -/
def openLedgerCheckpoint (store : FilePath) (checkpointRoot expectedHistory : TCB.Hash32)
    (expectedContext : ContextKey) : IO (Option (Ledger.State ℕ ℕ)) := do
  let some bytes ← LocalObjects.readFile (LocalObjects.objectPath store checkpointRoot)
    | return none
  let some checked := LedgerCheckpoint.verify checkpointRoot bytes | return none
  let record := checked.record
  unless List.ofFn record.historyRoot == List.ofFn expectedHistory do return none
  unless record.matchesContext expectedContext do return none
  return some record.state

end HomotopicalEncryption.Protocol.Storage.PublicStack
