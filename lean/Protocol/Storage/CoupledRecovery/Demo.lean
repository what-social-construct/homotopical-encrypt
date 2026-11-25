module

public import Protocol.Storage.CoupledRecovery
meta import Protocol.Storage.CoupledRecovery

@[expose] public section

/-!
# Executing the coupled harmonic-lattice encryption mechanism

Run from `lean/` with:
`lake env lean --run Protocol/Storage/CoupledRecovery/Demo.lean`.

This deterministic reference example runs the real byte encoder, canonical
private-key parser and exact rational recovery algorithm. It is an execution
check of the proved mechanism, not a secure key/noise sampler or performance
benchmark. The public example key and openings are deliberately fixed.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.CoupledRecovery.Demo

def key : Matrix (Fin 1) (Fin 2) ℤ := fun _ _ => 1

def message : Fin 2 → ℤ := ![2, -1]

def privateKeyBytes : List UInt8 := CoupledCodec.encode (CoupledCodec.ofMatrix key)

def ciphertextBytes : List UInt8 := CoupledCiphertext.sampleBytes key message 3 (fun _ => 4)

/-- This integer cochain has nonintegral projected message coefficients. -/
def outsideIntegerLanguage : CoupledCiphertext.IntegerCochain 1 2 := fun p =>
  match p.1 with
  | some (.inl col) => if col.val = 0 then 1 else 0
  | _ => 0

def run : IO Unit := do
  let recovered := (recoverWithKeyBytes 1 2 privateKeyBytes ciphertextBytes).map List.ofFn
  let coordinates := (CoupledCiphertext.decode 1 2 ciphertextBytes).map CoupledCiphertext.entries
  let outsideRejected := (recover key (CoupledCiphertext.encode outsideIntegerLanguage)).isNone
  let truncatedRejected :=
    (recover key (ciphertextBytes.take (ciphertextBytes.length - 1))).isNone
  let truncatedKeyRejected :=
    (recoverWithKeyBytes 1 2 (privateKeyBytes.take (privateKeyBytes.length - 1)) ciphertextBytes).isNone
  unless recovered = some [2, -1] do
    throw (IO.userError "Exact byte recovery did not return the original message")
  unless coordinates = some [3, -2, -5, 5] do
    throw (IO.userError "The ciphertext codec did not retain the original Hodge coordinates")
  unless outsideRejected && truncatedRejected && truncatedKeyRejected do
    throw (IO.userError "The input-language or canonical-byte rejection check failed")
  IO.println "Message coefficients: [2, -1]"
  IO.println s!"Canonical ciphertext coordinates: {coordinates}"
  IO.println s!"Recovered through private-key and ciphertext bytes: {recovered}"
  IO.println s!"Outside integer encryption language rejected: {outsideRejected}"
  IO.println s!"Truncated ciphertext rejected: {truncatedRejected}"
  IO.println s!"Truncated private-key bytes rejected: {truncatedKeyRejected}"

end HomotopicalEncryption.Protocol.Storage.CoupledRecovery.Demo

def main : IO Unit := HomotopicalEncryption.Protocol.Storage.CoupledRecovery.Demo.run
