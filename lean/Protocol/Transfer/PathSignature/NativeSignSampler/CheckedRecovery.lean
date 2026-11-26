module

public import Protocol.Transfer.PathSignature.NativeOperatorGuessing

@[expose] public section

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeSignSampler.CheckedRecovery

variable {rows cols : ℕ}

/-- Check the full fresh-sign ciphertext language at the declared public profile,
then unmask with the private sign key. -/
def recover (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (key : Fin cols → Bool) (bytes : List UInt8) : Option (Fin cols → Bool) := do
  let masked ← NativeOperatorGuessing.recoverMask A bytes
  if bytes = normalBytes A d a masked then some (mask masked key) else none

theorem recover_eq_some_iff_ciphertextBytes (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) (key message : Fin cols → Bool) (bytes : List UInt8) :
    recover A d a key bytes = some message ↔ bytes = ciphertextBytes A d a key message := by
  have commute (first second : Fin cols → Bool) : mask first second = mask second first := by
    funext col
    change (first col == second col) = (second col == first col)
    cases first col <;> cases second col <;> rfl
  constructor
  · intro recovered
    cases maskedResult : NativeOperatorGuessing.recoverMask A bytes with
    | none => simp [recover, maskedResult] at recovered
    | some masked =>
      rw [recover, maskedResult] at recovered
      by_cases canonical : bytes = normalBytes A d a masked
      · have decoded : mask masked key = message := by
          simpa [canonical] using recovered
        have unmasked : mask key message = masked := by
          rw [← decoded, commute key (mask masked key)]
          exact mask_involutive key masked
        simpa only [ciphertextBytes_normal A d a orthogonal, unmasked] using canonical
      · simp [canonical] at recovered
  · intro canonical
    subst bytes
    have cancel : mask (mask key message) key = message := by
      rw [commute key message]
      exact mask_involutive key message
    unfold recover
    rw [NativeOperatorGuessing.recoverMask_ciphertextBytes A d a orthogonal positive]
    simp [ciphertextBytes_normal A d a orthogonal, cancel]

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeSignSampler.CheckedRecovery
