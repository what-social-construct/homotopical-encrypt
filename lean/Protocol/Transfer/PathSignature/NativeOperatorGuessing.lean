module

public import Protocol.Transfer.PathSignature.NativeSignSampler

@[expose] public section

/-!
# Testing plaintext guesses against a bare operator hash

For the fresh-sign candidate, the original ciphertext's parity coordinates
reveal the masked sign vector when the public matrix satisfies `AᵀA = dI`
with positive `d`. The executable decoder below computes those signs from
the actual canonical ciphertext bytes. A proposed plaintext then determines
one candidate private presentation and its canonical matrix bytes.

The actual plaintext always passes the public raw-snapshot-hash test. A
different accepted plaintext supplies two distinct canonical matrix byte
strings with the same hash. This statement holds for every selected hash,
including a constant hash; no injectivity assumption is made. In particular,
the ciphertext-only distribution theorem does not establish privacy for an
enlarged view containing this bare operator hash.

The routines use matrix arithmetic, parsing and hash evaluation explicitly.
No running-time bound, general chosen-plaintext security experiment, or
claim about a hiding operator commitment is supplied here.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeOperatorGuessing

open Sheaf CellularSheaf
open NativeSignSampler
open scoped BigOperators

abbrev Bytes := List UInt8

variable {rows cols : ℕ}

/-- Apply the public transpose to the decoded original parity coordinates. -/
def transposeParity (A : Matrix (Fin rows) (Fin cols) ℤ)
    (observed : Storage.CoupledCiphertext.IntegerCochain rows cols) (col : Fin cols) : ℤ :=
  ∑ row, A row col * observed ⟨some (.inr row), 0⟩

theorem transposeParity_normal (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (masked : Fin cols → Bool) (col : Fin cols) :
    transposeParity A (normalObservation A d a masked) col =
      d * (d + 1) * sign (masked col) := by
  unfold transposeParity
  change (∑ row, A row col * ((d + 1) * ∑ other, A row other * sign (masked other))) = _
  calc
    _ = ∑ other, ∑ row, (d + 1) * ((A row col * A row other) * sign (masked other)) := by
      simp_rw [Finset.mul_sum]
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro other _member
      apply Finset.sum_congr rfl
      intro row _member
      ring
    _ = (d + 1) * ∑ other, (∑ row, A row col * A row other) * sign (masked other) := by
      simp_rw [Finset.sum_mul, Finset.mul_sum]
    _ = (d + 1) * (d * sign (masked col)) := by
      simp_rw [gram_entry A d orthogonal]
      simp
    _ = d * (d + 1) * sign (masked col) := by ring

theorem positive_sign_test (d : ℤ) (positive : 0 < d) (bit : Bool) :
    decide (0 < d * (d + 1) * sign bit) = bit := by
  have scale : 0 < d * (d + 1) := mul_pos positive (by omega)
  cases bit <;> simp [sign, HCP.AxisSignedSampler.coefficient] <;> omega

/-- Recover the masked bits from the actual full-ciphertext decoder. -/
def recoverMask (A : Matrix (Fin rows) (Fin cols) ℤ) (bytes : Bytes) :
    Option (Fin cols → Bool) := do
  let observed ← Storage.CoupledCiphertext.decode rows cols bytes
  some (fun col => decide (0 < transposeParity A observed col))

theorem recoverMask_ciphertextBytes (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) (key message : Fin cols → Bool) :
    recoverMask A (ciphertextBytes A d a key message) = some (mask key message) := by
  rw [ciphertextBytes_normal A d a orthogonal]
  simp only [recoverMask, normalBytes, Storage.CoupledCiphertext.decode_encode]
  apply congrArg some
  funext col
  rw [transposeParity_normal A d a orthogonal]
  exact positive_sign_test d positive _

/-- Decode, unmask with the proposed plaintext, and construct that actual
candidate in the existing coupled-presentation carrier. -/
def candidatePresentation (A : Matrix (Fin rows) (Fin cols) ℤ) (bytes : Bytes)
    (proposed : Fin cols → Bool) : Option (Matrix (Fin rows) (Fin cols) ℤ) :=
  (recoverMask A bytes).map fun masked => presentation A (mask masked proposed)

def candidateBytes (A : Matrix (Fin rows) (Fin cols) ℤ) (bytes : Bytes)
    (proposed : Fin cols → Bool) : Option Bytes :=
  (candidatePresentation A bytes proposed).map fun candidate =>
    Storage.CoupledCodec.encode (Storage.CoupledCodec.ofMatrix candidate)

theorem candidatePresentation_ciphertextBytes (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) (key message proposed : Fin cols → Bool) :
    candidatePresentation A (ciphertextBytes A d a key message) proposed =
      some (presentation A (mask (mask key message) proposed)) := by
  rw [candidatePresentation, recoverMask_ciphertextBytes A d a orthogonal positive]
  rfl

theorem candidatePresentation_actual (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) (key message : Fin cols → Bool) :
    candidatePresentation A (ciphertextBytes A d a key message) message =
      some (presentation A key) := by
  rw [candidatePresentation_ciphertextBytes A d a orthogonal positive]
  have unmask : mask (mask key message) message = key := mask_involutive message key
  rw [unmask]

/-- Every plaintext guess has a candidate key producing the same actual
ciphertext. This reuses the original normal-form theorem. -/
theorem unmasked_ciphertextBytes (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (masked proposed : Fin cols → Bool) :
    ciphertextBytes A d a (mask masked proposed) proposed = normalBytes A d a masked := by
  rw [ciphertextBytes_normal A d a orthogonal]
  have unmask : mask (mask masked proposed) proposed = masked := mask_involutive proposed masked
  rw [unmask]

/-- Distinct plaintext guesses determine distinct candidate presentations.
The existing native message-uniqueness theorem supplies this implication. -/
theorem candidatePresentations_injective (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) (masked : Fin cols → Bool) :
    Function.Injective (fun proposed => presentation A (mask masked proposed)) := by
  intro first second same
  exact presentation_ciphertext_message_unique A d a positive
    (mask masked first) (mask masked second) first second same
    ((unmasked_ciphertextBytes A d a orthogonal masked first).trans
      (unmasked_ciphertextBytes A d a orthogonal masked second).symm)

/-- Compare the canonical candidate matrix with the actual selected raw
snapshot hash. Parsing failure rejects before any hash comparison. -/
def testCandidate (hash : Bytes → TCB.Hash32) (A : Matrix (Fin rows) (Fin cols) ℤ)
    (snapshot : TCB.Hash32) (bytes : Bytes) (proposed : Fin cols → Bool) : Bool :=
  match candidateBytes A bytes proposed with
  | none => false
  | some candidate => decide (hash candidate = snapshot)

theorem testCandidate_actual (hash : Bytes → TCB.Hash32)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) (key message : Fin cols → Bool) :
    testCandidate hash A
      (hash (Storage.CoupledCodec.encode (Storage.CoupledCodec.ofMatrix (presentation A key))))
      (ciphertextBytes A d a key message) message = true := by
  simp [testCandidate, candidateBytes, candidatePresentation_actual A d a orthogonal positive]

/-- Acceptance of a wrong plaintext is an actual collision between distinct
canonical matrix bytes. The selected hash is arbitrary throughout. -/
theorem accepted_wrong_message_collision (hash : Bytes → TCB.Hash32)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) (key message proposed : Fin cols → Bool)
    (different : proposed ≠ message)
    (accepted : testCandidate hash A
      (hash (Storage.CoupledCodec.encode (Storage.CoupledCodec.ofMatrix (presentation A key))))
      (ciphertextBytes A d a key message) proposed = true) :
    ∃ candidate,
      candidateBytes A (ciphertextBytes A d a key message) proposed = some candidate ∧
      candidate ≠ Storage.CoupledCodec.encode (Storage.CoupledCodec.ofMatrix (presentation A key)) ∧
      hash candidate =
        hash (Storage.CoupledCodec.encode (Storage.CoupledCodec.ofMatrix (presentation A key))) := by
  let guessed := presentation A (mask (mask key message) proposed)
  let candidate := Storage.CoupledCodec.encode (Storage.CoupledCodec.ofMatrix guessed)
  have candidateEq : candidateBytes A (ciphertextBytes A d a key message) proposed =
      some candidate := by
    simp [candidateBytes, candidatePresentation_ciphertextBytes A d a orthogonal positive,
      candidate, guessed]
  have matrixDifferent : guessed ≠ presentation A key := by
    intro same
    apply different
    apply candidatePresentations_injective A d a orthogonal positive (mask key message)
    simpa only [mask_involutive message key] using same
  have bytesDifferent : candidate ≠
      Storage.CoupledCodec.encode (Storage.CoupledCodec.ofMatrix (presentation A key)) := by
    intro same
    exact matrixDifferent (Storage.CoupledCodec.encode_matrix_injective same)
  have hashEq : hash candidate =
      hash (Storage.CoupledCodec.encode (Storage.CoupledCodec.ofMatrix (presentation A key))) := by
    simpa [testCandidate, candidateEq] using accepted
  exact ⟨candidate, candidateEq, bytesDifferent, hashEq⟩

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeOperatorGuessing
