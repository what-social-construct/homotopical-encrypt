module

public import Protocol.Storage.PublicStack.Manifest
public import Protocol.Storage.CellDirectory.Persistence
import Std.Data.HashSet

public section

/-!
# Incremental restoration from a trusted public stack root

The caller supplies the accepted root independently of both stores. Restore
verifies the manifest and canonical cell directory before following their
links. Every selected artifact and complete ciphertext is checked before
publishing the active stack root.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.PublicStack

open System (FilePath)
open TCB.PrimitiveChecks (Bytes)

structure RestoreResult where
  fetched : Nat := 0
  reused : Nat := 0

/-- Verified addresses and counts for one destination. Start with fresh
progress at every acquisition of that destination's writer lock. -/
structure RestoreProgress (target : FilePath) where
  private mk ::
  result : RestoreResult
  private seen : Std.HashSet (List UInt8)

def RestoreProgress.empty (target : FilePath) : RestoreProgress target := ⟨{}, {}⟩

/-- A separate active pointer for the public stack profile. -/
def checkpointPath (store : FilePath) : FilePath := store / "public-stack"

/-- Obtain verified bytes while holding the destination writer lock. An address
contributes to the counts only on its first successful visit. -/
def obtain (target : FilePath) (fetch : TCB.Hash32 → IO (Option Bytes))
    (address : TCB.Hash32) (progress : RestoreProgress target) :
    IO (Option (Bytes × RestoreProgress target)) := do
  let key := List.ofFn address
  let record (result : RestoreResult) : RestoreProgress target :=
    if progress.seen.contains key then progress else ⟨result, progress.seen.insert key⟩
  let result := progress.result
  if let some bytes ← LocalObjects.readObject target address then
    return some (bytes, record { result with reused := result.reused + 1 })
  let some bytes ← fetch address | return none
  unless LocalObjects.checkAddress address bytes do return none
  -- Keep verified local copies. Repair corrupt copies only with verified bytes
  -- while the writer lock excludes cooperating writers.
  LocalObjects.writeAtomically (LocalObjects.objectPath target address) bytes
  return some (bytes, record { result with fetched := result.fetched + 1 })

/-- Stage a stack under the caller's writer lock. Its manifest and directory
are checked in their roles on every traversal, while previously verified leaves
need no extra read. This leaves publication to the caller. -/
def stageStack (target : FilePath) (root : TCB.Hash32)
    (fetch : TCB.Hash32 → IO (Option Bytes)) (progress : RestoreProgress target) :
    IO (Option (RestoreProgress target)) := do
  let some (manifestBytes, progress) ← obtain target fetch root progress | return none
  let some checked := verify root manifestBytes | return none
  let manifest := checked.manifest
  let some (directoryBytes, progress) ← obtain target fetch manifest.directoryRoot progress
    | return none
  let some directory := CellDirectory.verify manifest.context manifest.directoryRoot directoryBytes
    | return none
  let addresses := manifest.artifactAddresses ++ directory.entries.map Prod.snd
  let mut current := progress
  for address in addresses do
    if current.seen.contains (List.ofFn address) then continue
    let some (_, next) ← obtain target fetch address current | return none
    current := next
  return some current

/-- Reuse verified local objects and fetch missing or corrupt copies.
Counts include the manifest and directory and count each digest once. `fetch`
can read the destination but must not acquire its writer lock. Failed validation
leaves the active pointer in place. Cached objects can be reused on retry. -/
def restore (target : FilePath) (root : TCB.Hash32)
    (fetch : TCB.Hash32 → IO (Option Bytes)) : IO (Option RestoreResult) :=
  LocalObjects.withWriter target do
    let some progress ← stageStack target root fetch (RestoreProgress.empty target) | return none
    LocalObjects.writeAtomically (checkpointPath target) (List.ofFn root)
    return some progress.result

/-- Open an archived stack at an independently authenticated address. -/
def openNamedStack (store : FilePath) (root : TCB.Hash32) : IO (Option (Verified root)) := do
  let some bytes ← LocalObjects.readFile (LocalObjects.objectPath store root) | return none
  return verify root bytes

/-- Reopen the active stack under a root accepted independently. -/
def openStack (store : FilePath) (root : TCB.Hash32) : IO (Option (Verified root)) := do
  let pointer ← LocalObjects.readFile (checkpointPath store)
  unless pointer == some (List.ofFn root) do return none
  openNamedStack store root

/-- A restored directory uses the original canonical cell-directory verifier. -/
def openDirectory (store : FilePath) {root : TCB.Hash32} (stack : Verified root) :
    IO (Option (CellDirectory.Verified stack.manifest.context stack.manifest.directoryRoot)) := do
  let manifest := stack.manifest
  let some bytes ← LocalObjects.readObject store manifest.directoryRoot | return none
  return CellDirectory.verify manifest.context manifest.directoryRoot bytes

end HomotopicalEncryption.Protocol.Storage.PublicStack
