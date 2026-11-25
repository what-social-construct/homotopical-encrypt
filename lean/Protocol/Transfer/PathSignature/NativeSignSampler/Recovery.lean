module

public import Protocol.Storage.CoupledRecovery
public import Protocol.Transfer.PathSignature.NativeSignPrivacy

@[expose] public section

/-!
# Executable private recovery for the fresh-sign profile

The recipient runs the canonical byte decoder and reads the signs of the
recovered harmonic coefficients. Failure of byte or coefficient recovery is
preserved. Positive scaling gives an exact round trip for every generated
message and sign key.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeSignSampler

/-- Recover bits from the signs of the original decoded coefficients. -/
def recoverBitsWithKeyBytes (rows cols : ℕ) (keyBytes ciphertext : List UInt8) :
    Option (Fin cols → Bool) :=
  (Storage.CoupledRecovery.recoverWithKeyBytes rows cols keyBytes ciphertext).map
    (NativeSignPrivacy.totalizeCoefficientGuess some)

/-- The same byte ciphertext used by the fresh-sign experiment decodes to
the original bits with the canonical private presentation. -/
theorem recoverBitsWithKeyBytes_ciphertextBytes {rows cols : ℕ}
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) (positive : 0 < d)
    (key message : Fin cols → Bool) :
    recoverBitsWithKeyBytes rows cols
      (Storage.CoupledCodec.encode (Storage.CoupledCodec.ofMatrix (presentation A key)))
      (ciphertextBytes A d a key message) = some message := by
  have correct := Storage.CoupledRecovery.recoverWithKeyBytes_encode_sample
    (presentation A key) (coefficients d message) a (opening A key message)
  unfold ciphertextBytes recoverBitsWithKeyBytes
  rw [correct]
  exact congrArg some (NativeSignPrivacy.totalizeCoefficientGuess_of_correct
    some d positive (coefficients d message) message rfl)

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeSignSampler
