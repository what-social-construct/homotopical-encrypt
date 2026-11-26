module

public import Protocol.Storage.EncryptedCell
meta import Protocol.Storage.EncryptedCell
public import Protocol.Transfer.PathSignature.NativeSignSampler.CheckedRecovery
meta import Protocol.Transfer.PathSignature.NativeSignSampler.CheckedRecovery

public section

/-!
# Direct reads of encrypted cells

Run from `lean/` with `lake env lean --run Protocol/Storage/EncryptedCell/Demo.lean`.
Two canonical fresh-sign ciphertexts are stored and retrieved by their whole-cell
addresses. A raw store substitution with another canonical ciphertext is rejected.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.EncryptedCell.Demo

open Protocol.Transfer.PathSignature.NativeSignSampler

private def hex (bytes : List UInt8) : String :=
  let digit := fun n : ℕ => Char.ofNat (if n < 10 then 48 + n else 87 + n)
  String.ofList (bytes.flatMap fun byte => [digit (byte.toNat / 16), digit (byte.toNat % 16)])

private def checkCell (label : String) (store : EncryptedCell.Store) (address : TCB.Hash32)
    (bytes : List UInt8) (opening : ℤ) (key message : Fin 2 → Bool)
    (expectedCoordinates : List ℤ) : IO Unit := do
  let some readBytes := EncryptedCell.read store address
    | throw (IO.userError s!"{label} could not be read at its address")
  unless readBytes = bytes do
    throw (IO.userError s!"{label} read did not return the complete original bytes")
  let some decoded := CoupledCiphertext.decode 2 2 readBytes
    | throw (IO.userError s!"{label} did not decode as a canonical ciphertext")
  unless CoupledCiphertext.entries decoded = expectedCoordinates do
    throw (IO.userError s!"{label} decoded to unexpected coordinates")
  let recovered := (CheckedRecovery.recover hadamardTwo 2 opening key readBytes).map List.ofFn
  unless recovered = some (List.ofFn message) do
    throw (IO.userError s!"{label} did not recover the original message")
  IO.println s!"{label} stored {readBytes.length} bytes at SHA-256 {hex (List.ofFn address)}"
  IO.println s!"  Decoded coordinates {expectedCoordinates} and recovered bits {List.ofFn message}"

def run : IO Unit := do
  let firstKey : Fin 2 → Bool := ![false, true]
  let firstMessage : Fin 2 → Bool := ![true, false]
  let secondKey : Fin 2 → Bool := ![true, false]
  let secondMessage : Fin 2 → Bool := ![true, true]
  let first := ciphertextBytes hadamardTwo 2 3 firstKey firstMessage
  let second := ciphertextBytes hadamardTwo 2 (-2) secondKey secondMessage
  let empty : EncryptedCell.Store := {}
  let some (firstAddress, firstStore) := EncryptedCell.insert empty first
    | throw (IO.userError "Could not store cell 1")
  let some (secondAddress, store) := EncryptedCell.insert firstStore second
    | throw (IO.userError "Could not store cell 2")
  checkCell "Cell 1" store firstAddress first 3 firstKey firstMessage [3, 0, 0, -6, 0]
  checkCell "Cell 2" store secondAddress second (-2) secondKey secondMessage [-2, 0, 0, 0, 6]

  let corrupted := Std.HashMap.insert store (List.ofFn firstAddress) second
  unless (EncryptedCell.read corrupted firstAddress).isNone do
    throw (IO.userError "A substituted ciphertext was accepted at the old address")
  IO.println "Rejected a different canonical ciphertext stored under cell 1's address"

end HomotopicalEncryption.Protocol.Storage.EncryptedCell.Demo

def main : IO Unit := HomotopicalEncryption.Protocol.Storage.EncryptedCell.Demo.run
