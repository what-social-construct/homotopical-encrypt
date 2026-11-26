module

public import Protocol.Storage.CellDirectory
meta import Protocol.Storage.CellDirectory
public import Protocol.Transfer.PathSignature.NativeSignSampler.CheckedRecovery
meta import Protocol.Transfer.PathSignature.NativeSignSampler.CheckedRecovery

public section

/-!
# Authenticated directory reads of encrypted cells

Run from `lean/` with `lake env lean --run Protocol/Storage/CellDirectory/Demo.lean`.
The fixture takes its trusted root from the original snapshot directory bytes.
Two overlapping fragments cover three cell IDs and recover both canonical
ciphertexts. The final checks exercise directory and ciphertext rejection.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.CellDirectory.Demo

open Protocol.Transfer.PathSignature.NativeSignSampler

private def context : ContextKey where
  runId := fun _ => 1
  schemaVersion := 1
  snapshotRoot := fun _ => 2
  cochainDigest := fun _ => 3
  topologyTag := fun _ => 4
  parameterSet := fun _ => 5

def run : IO Unit := do
  let firstKey : Fin 2 → Bool := ![false, true]
  let firstMessage : Fin 2 → Bool := ![true, false]
  let secondKey : Fin 2 → Bool := ![true, false]
  let secondMessage : Fin 2 → Bool := ![true, true]
  let first := ciphertextBytes hadamardTwo 2 3 firstKey firstMessage
  let second := ciphertextBytes hadamardTwo 2 (-2) secondKey secondMessage
  let empty : EncryptedCell.Store := {}
  let some (firstAddress, firstStore) := EncryptedCell.insert empty first
    | throw (IO.userError "Could not store the first ciphertext")
  let some (secondAddress, store) := EncryptedCell.insert firstStore second
    | throw (IO.userError "Could not store the second ciphertext")

  let bytes := Codec.encode context [(1, firstAddress), (2, secondAddress), (3, firstAddress)]
  let computed := Sha256.digestBytes bytes
  let trustedRoot := Sha256.toHash32 computed
  let some directory := verify context trustedRoot bytes
    | throw (IO.userError "The original directory failed verification")
  let some left := directory.checkPatch [(1, firstAddress), (2, secondAddress)]
    | throw (IO.userError "The first directory fragment failed verification")
  let some right := directory.checkPatch [(2, secondAddress), (3, firstAddress)]
    | throw (IO.userError "The second directory fragment failed verification")
  unless left.resolve 2 = some secondAddress ∧ right.resolve 2 = some secondAddress do
    throw (IO.userError "The fragments did not agree on cell 2")
  unless (left.resolve 3).isNone && (right.resolve 1).isNone do
    throw (IO.userError "A fragment included a cell outside its patch")

  let joined := left.glue right
  let some firstRead := directory.read joined store 1
    | throw (IO.userError "The joined directory could not retrieve cell 1")
  let some secondRead := directory.read joined store 2
    | throw (IO.userError "The joined directory could not retrieve cell 2")
  unless firstRead = first ∧ secondRead = second ∧ directory.read joined store 3 = some first do
    throw (IO.userError "A cell read did not return the complete original ciphertext")
  let firstRecovered := (CheckedRecovery.recover hadamardTwo 2 3 firstKey firstRead).map List.ofFn
  let secondRecovered :=
    (CheckedRecovery.recover hadamardTwo 2 (-2) secondKey secondRead).map List.ofFn
  unless firstRecovered = some (List.ofFn firstMessage) ∧
      secondRecovered = some (List.ofFn secondMessage) do
    throw (IO.userError "A verified read did not recover the original message")

  unless (directory.checkPatch [(2, firstAddress)]).isNone do
    throw (IO.userError "A fragment changed the digest of cell 2")
  let substituted := Codec.encode context [(1, secondAddress), (2, secondAddress), (3, firstAddress)]
  unless (verify context trustedRoot substituted).isNone do
    throw (IO.userError "A substituted directory passed verification at the original root")
  let changedContext := { context with schemaVersion := context.schemaVersion + 1 }
  unless (verify changedContext trustedRoot bytes).isNone do
    throw (IO.userError "The directory passed verification for a different context")
  let duplicates := Codec.encode context [(1, firstAddress), (1, secondAddress)]
  let computedDuplicates := Sha256.digestBytes duplicates
  let duplicateRoot := Sha256.toHash32 computedDuplicates
  unless (verify context duplicateRoot duplicates).isNone do
    throw (IO.userError "A directory with duplicate IDs passed verification at its own root")
  let corrupted := Std.HashMap.insert store (List.ofFn firstAddress) second
  unless (directory.read joined corrupted 1).isNone do
    throw (IO.userError "A substituted ciphertext passed the joined directory read")

  IO.println "Verified two directory fragments with a shared cell under one directory root"
  IO.println "Retrieved all three cells from their union and recovered both original messages"
  IO.println "Rejected an altered fragment, altered directory, different context, duplicate ID, and substituted ciphertext"

end HomotopicalEncryption.Protocol.Storage.CellDirectory.Demo

def main : IO Unit := HomotopicalEncryption.Protocol.Storage.CellDirectory.Demo.run
