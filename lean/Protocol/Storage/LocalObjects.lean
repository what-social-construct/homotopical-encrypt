module

public import Protocol.Storage.Sha256
public import TCB.PrimitiveChecks

public section

/-! Digest-named object files and atomic publication on a local POSIX store. -/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.LocalObjects

open System (FilePath)
open TCB.PrimitiveChecks (Bytes)

def digestPath (directory : FilePath) (digest : TCB.Hash32) : FilePath :=
  let digits := "0123456789abcdef".toList.toArray
  let name := String.ofList ((List.ofFn digest).flatMap fun byte =>
    [digits[byte.toNat / 16]!, digits[byte.toNat % 16]!])
  directory / name

def objectPath (store : FilePath) (address : TCB.Hash32) : FilePath :=
  digestPath (store / "objects") address

def readFile (path : FilePath) : IO (Option Bytes) := do
  try
    return some (← IO.FS.readBinFile path).data.toList
  catch error =>
    match error with
    | .noFileOrDirectory .. => return none
    | _ => throw error

private partial def createStage (target : FilePath) (pid : UInt32) (index : Nat) :
    IO (FilePath × IO.FS.Handle) := do
  let path := target.withExtension s!"stage-{pid}-{index}"
  try
    return (path, ← IO.FS.Handle.mk path .writeNew)
  catch error =>
    match error with
    | .alreadyExists .. => createStage target pid (index + 1)
    | _ => throw error

def writeAtomically (target : FilePath) (bytes : Bytes) : IO Unit := do
  let (stage, handle) ← createStage target (← IO.Process.getPID) 0
  try
    handle.write ⟨bytes.toArray⟩
    handle.flush
    IO.FS.rename stage target
  catch error =>
    -- Readers ignore stages. Preserve the publication error if cleanup fails.
    try IO.FS.removeFile stage catch _ => pure ()
    throw error

/-- A cooperating writer holds the store lock before adding immutable files. -/
def putImmutable (path : FilePath) (bytes : Bytes) : IO Bool := do
  match ← readFile path with
  | some existing => return existing == bytes
  | none =>
    writeAtomically path bytes
    return true

def checkAddress (address : TCB.Hash32) (bytes : Bytes) : Bool :=
  Sha256.key (Sha256.digestBytes bytes) == List.ofFn address

def readObject (store : FilePath) (address : TCB.Hash32) : IO (Option Bytes) := do
  let candidate ← readFile (objectPath store address)
  return candidate.filter (checkAddress address)

/-- Serialize cooperating writers and create the shared object directory. -/
def withWriter {α : Type} (store : FilePath) (action : IO α) : IO α := do
  IO.FS.createDirAll store
  let lock ← IO.FS.Handle.mk (store / "writer.lock") .append
  lock.lock
  try
    IO.FS.createDirAll (store / "objects")
    action
  finally
    lock.unlock

/-- Add immutable content under its computed address while holding the writer lock. -/
def putObject (store : FilePath) (bytes : Bytes) : IO Bool :=
  let address := Sha256.toHash32 (Sha256.digestBytes bytes)
  putImmutable (objectPath store address) bytes

end HomotopicalEncryption.Protocol.Storage.LocalObjects
