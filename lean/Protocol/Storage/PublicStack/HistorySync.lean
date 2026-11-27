module

public import Protocol.Storage.PublicStack.History

public section

/-!
# Incremental history replication

The caller supplies the trusted index root, initial state, and fixed verifier
profile independently of the source and replica. Replica activation follows
both object verification and successful replay of the entire ordered history.
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

/-- Active ordered-history pointer for the replica. -/
def historyCheckpointPath (store : FilePath) : FilePath := store / "public-history"

/-- Check the supplied archive sequence under the caller's writer lock.
Publication belongs to the caller. -/
def stageHistoryTransfers [DecidableEq Asset] (target : FilePath) (roots : HistoryIndex.Roots)
    (initial : Config F Bytes Asset Receipt) (fetch : TCB.Hash32 → IO (Option Bytes))
    (initialProgress : RestoreProgress target) :
    IO (Option (RestoreProgress target × Ledger.State ℕ ℕ)) := do
  let mut progress := initialProgress
  let mut current := initial
  for root in roots do
    let some staged ← stageStack target root fetch progress | return none
    let some next ← advanceNamedStack target root current | return none
    progress := staged
    current := next
  return some (progress, current.before)

/-- Stage each distinct named object and replay its transfer from the computed
predecessor. A rejected attempt may cache verified objects for retry. `fetch`
must not acquire the replica's writer lock. -/
def restoreHistory [DecidableEq Asset] (target : FilePath) (historyRoot : TCB.Hash32)
    (initial : Config F Bytes Asset Receipt) (fetch : TCB.Hash32 → IO (Option Bytes)) :
    IO (Option (RestoreResult × Ledger.State ℕ ℕ)) :=
  LocalObjects.withWriter target do
    let some (bytes, indexProgress) ← obtain target fetch historyRoot (RestoreProgress.empty target)
      | return none
    let some history := HistoryIndex.verify historyRoot bytes | return none
    let some (progress, finalState) ←
      stageHistoryTransfers target history.roots initial fetch indexProgress | return none
    LocalObjects.writeAtomically (historyCheckpointPath target) (List.ofFn historyRoot)
    return some (progress.result, finalState)

/-- Reopen and replay the active history under the independently trusted root. -/
def openHistory [DecidableEq Asset] (store : FilePath) (historyRoot : TCB.Hash32)
    (initial : Config F Bytes Asset Receipt) : IO (Option (Ledger.State ℕ ℕ)) := do
  let pointer ← LocalObjects.readFile (historyCheckpointPath store)
  unless pointer == some (List.ofFn historyRoot) do return none
  replayHistory store historyRoot initial

end HomotopicalEncryption.Protocol.Storage.PublicStack
