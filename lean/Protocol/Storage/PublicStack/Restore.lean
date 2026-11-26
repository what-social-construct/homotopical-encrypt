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

/-- A separate active pointer for the public stack profile. -/
def checkpointPath (store : FilePath) : FilePath := store / "public-stack"

private def obtain (target : FilePath) (fetch : TCB.Hash32 → IO (Option Bytes))
    (address : TCB.Hash32) (result : RestoreResult) : IO (Option (Bytes × RestoreResult)) := do
  if let some bytes ← LocalObjects.readObject target address then
    return some (bytes, { result with reused := result.reused + 1 })
  let some bytes ← fetch address | return none
  unless LocalObjects.checkAddress address bytes do return none
  -- Keep verified local copies. Repair corrupt copies only with verified bytes
  -- while the writer lock excludes cooperating writers.
  LocalObjects.writeAtomically (LocalObjects.objectPath target address) bytes
  return some (bytes, { result with fetched := result.fetched + 1 })

/-- Reuse verified local objects and fetch missing or corrupt copies.
Counts include the manifest and directory and count each digest once. `fetch`
can read the destination but must not acquire its writer lock. Failed validation
leaves the active pointer in place. Cached objects can be reused on retry. -/
def restore (target : FilePath) (root : TCB.Hash32)
    (fetch : TCB.Hash32 → IO (Option Bytes)) : IO (Option RestoreResult) :=
  LocalObjects.withWriter target do
    let some (manifestBytes, result) ← obtain target fetch root {} | return none
    let some checked := verify root manifestBytes | return none
    let manifest := checked.manifest
    let some (directoryBytes, result) ← obtain target fetch manifest.directoryRoot result
      | return none
    let some directory := CellDirectory.verify manifest.context manifest.directoryRoot directoryBytes
      | return none
    let addresses := manifest.artifactAddresses ++ directory.entries.map Prod.snd
    let initial : Std.HashSet (List UInt8) := {}
    let mut visited := (initial.insert (List.ofFn root)).insert (List.ofFn manifest.directoryRoot)
    let mut counts := result
    for address in addresses do
      let key := List.ofFn address
      if visited.contains key then continue
      let some (_, next) ← obtain target fetch address counts | return none
      visited := visited.insert key
      counts := next
    LocalObjects.writeAtomically (checkpointPath target) (List.ofFn root)
    return some counts

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
