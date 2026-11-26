module

public import Protocol.Storage.CellDirectory.Persistence
meta import Protocol.Storage.CellDirectory.Persistence
public import Protocol.Transfer.PathSignature.NativeSignSampler.CheckedRecovery
meta import Protocol.Transfer.PathSignature.NativeSignSampler.CheckedRecovery

public section

/-!
# Write and reopen an authenticated cell checkpoint

From `lean/`, run `lake env lean --run Protocol/Storage/CellDirectory/Persistence/Demo.lean write DIR`
with a fresh directory path whose parent exists. Then run the same command
with `read DIR` in a separate process. Both runs construct the trusted pin
from the fixed fixture. The read phase temporarily changes only fixture
files and restores them after each rejection check.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.CellDirectory.Persistence.Demo

open System (FilePath)
open TCB.PrimitiveChecks (Bytes)
open Protocol.Transfer.PathSignature.NativeSignSampler

private def context : ContextKey where
  runId := fun _ => 1
  schemaVersion := 1
  snapshotRoot := fun _ => 2
  cochainDigest := fun _ => 3
  topologyTag := fun _ => 4
  parameterSet := fun _ => 5

private def firstKey : Fin 2 → Bool := ![false, true]
private def firstMessage : Fin 2 → Bool := ![true, false]
private def secondKey : Fin 2 → Bool := ![true, false]
private def secondMessage : Fin 2 → Bool := ![true, true]

private structure Fixture where
  first : Bytes
  second : Bytes
  firstAddress : TCB.Hash32
  secondAddress : TCB.Hash32
  directoryBytes : Bytes
  pin : CheckpointPin

private def fixture : Fixture :=
  let first := ciphertextBytes hadamardTwo 2 3 firstKey firstMessage
  let second := ciphertextBytes hadamardTwo 2 (-2) secondKey secondMessage
  let firstDigest := Sha256.digestBytes first
  let secondDigest := Sha256.digestBytes second
  let firstAddress := Sha256.toHash32 firstDigest
  let secondAddress := Sha256.toHash32 secondDigest
  let bytes := Codec.encode context [(1, firstAddress), (2, secondAddress), (3, firstAddress)]
  let computed := Sha256.digestBytes bytes
  let pin : CheckpointPin := ⟨context, Sha256.toHash32 computed⟩
  ⟨first, second, firstAddress, secondAddress, bytes, pin⟩

private def ownerMarker : String := "hodge-cell-directory-persistence-demo-v1\n"

private def markerPath (store : FilePath) : FilePath := store / "demo-owner"

private def writeFixture (store : FilePath) : IO Unit := do
  IO.FS.createDir store
  IO.FS.writeFile (markerPath store) ownerMarker
  let data := fixture
  unless (← Persistence.publish store data.pin data.directoryBytes [data.first, data.second]) do
    throw (IO.userError "Could not publish the original checkpoint")

  let missing := ciphertextBytes hadamardTwo 2 1 (![false, false]) (![true, true])
  let missingDigest := Sha256.digestBytes missing
  let missingAddress := Sha256.toHash32 missingDigest
  if ← (Persistence.objectPath store missingAddress).pathExists then
    throw (IO.userError "The proposed missing object is already present")
  let proposed := Codec.encode data.pin.context [(1, missingAddress)]
  let proposedDigest := Sha256.digestBytes proposed
  let proposedPin : CheckpointPin := ⟨data.pin.context, Sha256.toHash32 proposedDigest⟩
  if ← Persistence.publish store proposedPin proposed [] then
    throw (IO.userError "A checkpoint referring to a missing object was published")

  let some directory ← Persistence.openDirectory store data.pin
    | throw (IO.userError "The failed publish displaced the original checkpoint")
  unless (← Persistence.read store directory 1) = some data.first do
    throw (IO.userError "The original ciphertext was unavailable after the failed publish")
  IO.println "Published the checkpoint and kept it readable after a failed publish"

private def withReplacement (path : FilePath) (bytes : Bytes) (check : IO Unit) : IO Unit := do
  let original ← IO.FS.readBinFile path
  try
    IO.FS.writeBinFile path ⟨bytes.toArray⟩
    check
  finally
    IO.FS.writeBinFile path original

private def withMissingFile (path : FilePath) (check : IO Unit) : IO Unit := do
  let held := path.addExtension "demo-hold"
  if ← held.pathExists then
    throw (IO.userError "The fixture hold path is already occupied")
  IO.FS.rename path held
  try
    check
  finally
    IO.FS.rename held path

private def readFixture (store : FilePath) : IO Unit := do
  unless (← IO.FS.readFile (markerPath store)) = ownerMarker do
    throw (IO.userError "Use a directory created by this demo's write phase")
  let data := fixture
  let some directory ← Persistence.openDirectory store data.pin
    | throw (IO.userError "Could not reopen the expected checkpoint")
  let some first ← Persistence.read store directory 1
    | throw (IO.userError "Could not read cell 1 after reopening")
  let some second ← Persistence.read store directory 2
    | throw (IO.userError "Could not read cell 2 after reopening")
  let third ← Persistence.read store directory 3
  unless first = data.first ∧ second = data.second ∧ third = some data.first do
    throw (IO.userError "Reopened cell reads differed from the original ciphertexts")

  let firstRecovered := (CheckedRecovery.recover hadamardTwo 2 3 firstKey first).map List.ofFn
  let secondRecovered :=
    (CheckedRecovery.recover hadamardTwo 2 (-2) secondKey second).map List.ofFn
  unless firstRecovered = some (List.ofFn firstMessage) ∧
      secondRecovered = some (List.ofFn secondMessage) do
    throw (IO.userError "Could not recover both original messages after reopening")
  unless (← Persistence.read store directory 99).isNone do
    throw (IO.userError "An unknown cell produced a read")

  let otherContext := { data.pin.context with schemaVersion := data.pin.context.schemaVersion + 1 }
  let otherPin := { data.pin with context := otherContext }
  withReplacement (Persistence.checkpointPath store) otherPin.encode do
    unless (← Persistence.openDirectory store data.pin).isNone do
      throw (IO.userError "A changed checkpoint passed the trusted pin check")
  let changedDirectory := Codec.encode data.pin.context
    [(1, data.secondAddress), (2, data.secondAddress), (3, data.firstAddress)]
  withReplacement (Persistence.directoryPath store data.pin.directoryRoot) changedDirectory do
    unless (← Persistence.openDirectory store data.pin).isNone do
      throw (IO.userError "A changed directory passed verification at the original root")
  let firstPath := Persistence.objectPath store data.firstAddress
  withMissingFile firstPath do
    unless (← Persistence.read store directory 1).isNone do
      throw (IO.userError "A missing ciphertext produced a read")
  withReplacement firstPath data.second do
    unless (← Persistence.read store directory 1).isNone do
      throw (IO.userError "A different complete ciphertext passed the original address check")

  let some restored ← Persistence.openDirectory store data.pin
    | throw (IO.userError "Could not reopen the restored checkpoint")
  unless (← Persistence.read store restored 1) = some data.first do
    throw (IO.userError "Could not read the restored ciphertext")
  IO.println "Reopened the pinned checkpoint and read three cells, recovering both original messages"
  IO.println "Rejected an unknown cell, changed checkpoint, changed directory, missing object, and substituted ciphertext"

def run (args : List String) : IO Unit :=
  match args with
  | ["write", dir] => writeFixture ⟨dir⟩
  | ["read", dir] => readFixture ⟨dir⟩
  | _ => throw (IO.userError "Usage is write DIR or read DIR")

end HomotopicalEncryption.Protocol.Storage.CellDirectory.Persistence.Demo

def main (args : List String) : IO Unit :=
  HomotopicalEncryption.Protocol.Storage.CellDirectory.Persistence.Demo.run args
