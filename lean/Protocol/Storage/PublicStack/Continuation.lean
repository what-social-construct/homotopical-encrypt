module

public import Protocol.Storage.PublicStack.CheckpointIO

public section

/-!
# Checkpoint-based history continuation

The caller supplies the authenticated checkpoint and extended history roots.
The replica checks both canonical indices, then stages and replays the exact
extension from the checkpoint's complete state. The independently issued
result names a checkpoint for the extended history. Prefix archives can be
absent, so the whole-history activation path remains a separate entry point.
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

private def resumeProfile (profile : Config F Bytes Asset Receipt)
    (state : Ledger.State ℕ ℕ) : Option (Config F Bytes Asset Receipt) :=
  if same : List.ofFn state.topologyRoot = List.ofFn profile.before.topologyRoot then
    some { profile with
      before := state
      topologyBound := (List.ofFn_injective same).symm ▸ profile.topologyBound }
  else none

/-- Check the extension and issue its exact successor checkpoint. Staging
progress spans the prefix index, extension index, and all suffix archives.
The fetch callback must not acquire the target's writer lock. -/
def continueHistory [DecidableEq Asset] (target : FilePath)
    (checkpointRoot extendedRoot : TCB.Hash32) (profile : Config F Bytes Asset Receipt)
    (fetch : TCB.Hash32 → IO (Option Bytes)) : IO (Option (RestoreResult × Sha256.DigestBytes)) :=
  LocalObjects.withWriter target do
    let some (checkpointBytes, initialProgress) ←
      obtain target fetch checkpointRoot (RestoreProgress.empty target) | return none
    let some checked := LedgerCheckpoint.verify checkpointRoot checkpointBytes | return none
    let checkpoint := checked.record
    unless checkpoint.matchesContext profile.context.key do return none
    let some resumed := resumeProfile profile checkpoint.state | return none
    let some (priorBytes, priorProgress) ←
      obtain target fetch checkpoint.historyRoot initialProgress | return none
    let some prior := HistoryIndex.verify checkpoint.historyRoot priorBytes | return none
    let some (extendedBytes, indexProgress) ← obtain target fetch extendedRoot priorProgress
      | return none
    let some extended := HistoryIndex.verify extendedRoot extendedBytes | return none
    let some suffix := HistoryIndex.continuation prior.roots extended.roots | return none
    let some (progress, finalState) ← stageHistoryTransfers target suffix resumed fetch indexProgress
      | return none
    let some digest ← storeLedgerCheckpoint target ⟨extendedRoot, profile.context.key, finalState⟩
      | return none
    return some (progress.result, digest)

end HomotopicalEncryption.Protocol.Storage.PublicStack
