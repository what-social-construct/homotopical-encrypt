module

public import Protocol.Storage.CellDirectory.Checkpoint
public import Protocol.Storage.LocalObjects

public section

/-!
# Local checkpoint publication and restart reads

The reader supplies a pin from an accepted checkpoint independently of these
files. A local POSIX store uses cooperating writers and atomic same-directory
renames. Buffered writes are flushed before publication. This API supports
process restarts and leaves power-loss synchronization to the filesystem backend.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.CellDirectory.Persistence

open System (FilePath)
open TCB.PrimitiveChecks (Bytes)

def checkpointPath (store : FilePath) : FilePath := store / "checkpoint"

def directoryPath (store : FilePath) (root : TCB.Hash32) : FilePath :=
  LocalObjects.digestPath (store / "directories") root

export LocalObjects (objectPath readObject)

/-- Seed the shared content store without publishing a checkpoint. -/
def seedObject (store : FilePath) (bytes : Bytes) : IO Bool :=
  LocalObjects.withWriter store (LocalObjects.putObject store bytes)

/-- Publish only after the canonical directory and all referenced objects have
passed verification. Failed validation leaves the previous checkpoint
in place. Immutable files already added may be reused by a later publication. -/
def publish (store : FilePath) (pin : CheckpointPin) (directoryBytes : Bytes)
    (ciphertexts : List Bytes) : IO Bool := do
  let some directory := verify pin.context pin.directoryRoot directoryBytes
    | return false
  LocalObjects.withWriter store do
    IO.FS.createDirAll (store / "directories")
    for bytes in ciphertexts do
      unless ← LocalObjects.putObject store bytes do return false
    for (_, address) in directory.entries do
      unless (← readObject store address).isSome do return false
    unless ← LocalObjects.putImmutable (directoryPath store pin.directoryRoot) directoryBytes do
      return false
    LocalObjects.writeAtomically (checkpointPath store) pin.encode
    return true

/-- Check the exact on-disk checkpoint against the independent pin before
looking up or verifying the named directory. -/
def openDirectory (store : FilePath) (pin : CheckpointPin) :
    IO (Option (Verified pin.context pin.directoryRoot)) := do
  let some checkpoint ← LocalObjects.readFile (checkpointPath store) | return none
  unless pin.check checkpoint do return none
  let some bytes ← LocalObjects.readFile (directoryPath store pin.directoryRoot) | return none
  return verify pin.context pin.directoryRoot bytes

/-- Resolve a cell ID in the verified directory and check the entire named object. -/
def read (store : FilePath) {context : ContextKey} {root : TCB.Hash32}
    (directory : Verified context root) (cellId : Nat) : IO (Option Bytes) := do
  let some address := directory.entries.lookup cellId | return none
  readObject store address

end HomotopicalEncryption.Protocol.Storage.CellDirectory.Persistence
