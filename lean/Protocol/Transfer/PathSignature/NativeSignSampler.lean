module

public import HCP.AxisSignedSampler
public import Protocol.Storage.CoupledCiphertext.Disclosure
public import Mathlib.Data.Matrix.Mul
public import Mathlib.Data.Int.NatAbs

@[expose] public section

/-!
# A fresh-sign candidate for the original coupled ciphertext

This candidate is separate from the bounded native sampler and is not a
default protocol profile. A public integer matrix `A` has `AᵀA = dI`. A fresh
Boolean sign key supplies `C = A diag(key)`, while a Boolean message supplies
the original harmonic coefficients `z = d sign(message)` and the correlated
coexact opening `u = C sign(message)`. The exact opening is fixed independently
of the message and key.

The actual original coupled sample has information coordinates zero and
parity coordinates `(d+1) A (sign(key) * sign(message))`. Its canonical full
ciphertext bytes therefore depend only on the masked key/message vector.
Masking is an involutive permutation, so one fresh uniform sign key gives the
same ciphertext-byte distribution for every message. Every deterministic
ciphertext digest preserves this equality. For positive `d`, the harmonic
coefficient encoding is injective and the existing private projection still
recovers the original harmonic message.

The identity matrix gives an inhabited family in every dimension with `d=1`.
An explicit dense two-by-two Hadamard matrix gives a coupled example with
`d=2`; its Gram equation is checked by kernel reduction.

This is a ciphertext-only, one-use calculation. The key-dependent presentation,
its public snapshot/hash, credentials, storage records, signing transcripts,
key reuse and encryption-oracle security are not included in the claimed
view. In particular, publishing the presentation or a distinguishing hash of
it requires a separate analysis; the ciphertext-only equality does not make
that enlarged view safe. No computational hardness assertion or secure
public-key encryption construction follows from this calculation.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeSignSampler

open Sheaf CellularSheaf HCPCoupledFamily
open scoped BigOperators ENNReal

variable {rows cols : ℕ}

/-- Reuse the signed coefficient of the existing finite axis calculation. -/
abbrev sign (bit : Bool) : ℤ := HCP.AxisSignedSampler.coefficient bit

@[simp] theorem sign_mul_self (bit : Bool) : sign bit * sign bit = 1 := by
  cases bit <;> decide

@[simp] theorem sign_natAbs (bit : Bool) : (sign bit).natAbs = 1 := by
  cases bit <;> decide

theorem sign_injective : Function.Injective sign := by
  intro first second same
  cases first <;> cases second <;> simp [sign, HCP.AxisSignedSampler.coefficient] at same ⊢

/-- Equal Boolean bits represent the positive product sign. -/
def mask (key message : Fin cols → Bool) : Fin cols → Bool :=
  fun col => key col == message col

theorem sign_mask (key message : Fin cols → Bool) (col : Fin cols) :
    sign (mask key message col) = sign (key col) * sign (message col) := by
  unfold mask
  cases key col <;> cases message col <;> decide

theorem mask_involutive (message : Fin cols → Bool) :
    Function.Involutive (fun key => mask key message) := by
  intro key
  funext col
  change ((key col == message col) == message col) = key col
  cases key col <;> cases message col <;> rfl

/-- Fixed-message masking is an actual permutation of the finite key space. -/
def maskEquiv (message : Fin cols → Bool) : (Fin cols → Bool) ≃ (Fin cols → Bool) where
  toFun key := mask key message
  invFun key := mask key message
  left_inv := mask_involutive message
  right_inv := mask_involutive message

theorem eq_mask_iff (message key candidate : Fin cols → Bool) :
    key = mask candidate message ↔ candidate = mask key message := by
  constructor
  · intro same
    have masked := congrArg (fun value => mask value message) same
    exact (mask_involutive message candidate).symm.trans masked.symm
  · intro same
    have masked := congrArg (fun value => mask value message) same
    exact (mask_involutive message key).symm.trans masked.symm

/-- The original coupled presentation has independently signed public columns. -/
def presentation (A : Matrix (Fin rows) (Fin cols) ℤ) (key : Fin cols → Bool) :
    Matrix (Fin rows) (Fin cols) ℤ := fun row col => A row col * sign (key col)

theorem presentation_eq_mul_diagonal (A : Matrix (Fin rows) (Fin cols) ℤ)
    (key : Fin cols → Bool) :
    presentation A key = A * Matrix.diagonal (fun col => sign (key col)) := by
  ext row col
  exact (Matrix.mul_diagonal (fun col => sign (key col)) A row col).symm

/-- The integral harmonic coefficient vector of the original native sample. -/
def coefficients (d : ℤ) (message : Fin cols → Bool) : Fin cols → ℤ :=
  fun col => d * sign (message col)

/-- Correlated integer coexact coordinates, supplied to the original noise object. -/
def opening (A : Matrix (Fin rows) (Fin cols) ℤ)
    (key message : Fin cols → Bool) : Fin rows → ℤ :=
  fun row => ∑ col, presentation A key row col * sign (message col)

theorem opening_mask (A : Matrix (Fin rows) (Fin cols) ℤ)
    (key message : Fin cols → Bool) (row : Fin rows) :
    opening A key message row = ∑ col, A row col * sign (mask key message col) := by
  apply Finset.sum_congr rfl
  intro col _member
  rw [sign_mask]
  exact mul_assoc _ _ _

/-- Entrywise consequence of the declared public column Gram equation. -/
theorem gram_entry (A : Matrix (Fin rows) (Fin cols) ℤ) (d : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (first second : Fin cols) :
    (∑ row, A row first * A row second) = if first = second then d else 0 := by
  have entry := congrArg (fun matrix : Matrix (Fin cols) (Fin cols) ℤ => matrix first second)
    orthogonal
  simpa [Matrix.mul_apply, Matrix.transpose_apply, Matrix.one_apply, smul_eq_mul, mul_ite]
    using entry

theorem presentation_gram_entry (A : Matrix (Fin rows) (Fin cols) ℤ) (d : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (key : Fin cols → Bool) (first second : Fin cols) :
    (∑ row, presentation A key row first * presentation A key row second) =
      if first = second then d else 0 := by
  calc
    _ = (∑ row, A row first * A row second) *
        (sign (key first) * sign (key second)) := by
      rw [Finset.sum_mul]
      apply Finset.sum_congr rfl
      intro row _member
      dsimp [presentation]
      ring
    _ = (if first = second then d else 0) *
        (sign (key first) * sign (key second)) := by rw [gram_entry A d orthogonal]
    _ = if first = second then d else 0 := by
      by_cases same : first = second
      · subst second
        simp
      · simp [same]

/-- Every sign-key presentation has the same public Gram matrix. -/
theorem presentation_gram (A : Matrix (Fin rows) (Fin cols) ℤ) (d : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (key : Fin cols → Bool) :
    (presentation A key).transpose * presentation A key =
      d • (1 : Matrix (Fin cols) (Fin cols) ℤ) := by
  ext first second
  simpa [Matrix.mul_apply, Matrix.transpose_apply, Matrix.one_apply, smul_eq_mul, mul_ite]
    using presentation_gram_entry A d orthogonal key first second

/-- The chosen coexact opening cancels every information coordinate. -/
theorem transposed_opening (A : Matrix (Fin rows) (Fin cols) ℤ) (d : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (key message : Fin cols → Bool) (col : Fin cols) :
    (∑ row, presentation A key row col * opening A key message row) =
      coefficients d message col := by
  calc
    _ = ∑ other, (∑ row, presentation A key row col * presentation A key row other) *
        sign (message other) := by
      simp_rw [opening, Finset.mul_sum, ← mul_assoc]
      rw [Finset.sum_comm]
      simp only [Finset.sum_mul]
    _ = ∑ other, (if col = other then d else 0) * sign (message other) := by
      simp_rw [presentation_gram_entry A d orthogonal]
    _ = coefficients d message col := by simp [coefficients]

/-- The parity component retains only the masked sign vector. -/
theorem parity_normal (A : Matrix (Fin rows) (Fin cols) ℤ) (d : ℤ)
    (key message : Fin cols → Bool) (row : Fin rows) :
    (∑ col, presentation A key row col * coefficients d message col) +
        opening A key message row =
      (d + 1) * (∑ col, A row col * sign (mask key message col)) := by
  rw [← opening_mask A key message row]
  have scaled : (∑ col, presentation A key row col * coefficients d message col) =
      d * opening A key message row := by
    rw [opening, Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro col _member
    dsimp [coefficients]
    ring
  rw [scaled]
  ring

/-- The canonical coordinate normal form depends on the masked bits alone. -/
def normalObservation (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (masked : Fin cols → Bool) : Protocol.Storage.CoupledCiphertext.IntegerCochain rows cols :=
  fun edge => match edge.1 with
    | none => a
    | some (.inl _) => 0
    | some (.inr row) => (d + 1) * ∑ col, A row col * sign (masked col)

theorem integerObserved_normal (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (key message : Fin cols → Bool) :
    HCPCoupledEncoding.integerObserved (presentation A key) (coefficients d message) a
        (opening A key message) = normalObservation A d a (mask key message) := by
  funext edge
  rcases edge with ⟨position, component⟩
  cases position with
  | none => rfl
  | some position =>
    cases position with
    | inl col =>
      change coefficients d message col -
        (∑ row, presentation A key row col * opening A key message row) = 0
      rw [transposed_opening A d orthogonal]
      exact sub_self _
    | inr row => exact parity_normal A d key message row

/-- These are the actual existing full native ciphertext bytes. -/
def ciphertextBytes (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (key message : Fin cols → Bool) : List UInt8 :=
  Protocol.Storage.CoupledCiphertext.sampleBytes (presentation A key) (coefficients d message) a
    (opening A key message)

def normalBytes (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (masked : Fin cols → Bool) : List UInt8 :=
  Protocol.Storage.CoupledCiphertext.encode (normalObservation A d a masked)

theorem ciphertextBytes_normal (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (key message : Fin cols → Bool) :
    ciphertextBytes A d a key message = normalBytes A d a (mask key message) := by
  exact congrArg Protocol.Storage.CoupledCiphertext.encode
    (integerObserved_normal A d a orthogonal key message)

/-- Positive `d` preserves every Boolean message in the harmonic coefficients. -/
theorem coefficients_injective (d : ℤ) (positive : 0 < d) :
    Function.Injective (coefficients (cols := cols) d) := by
  intro first second same
  funext col
  apply sign_injective
  exact mul_left_cancel₀ (ne_of_gt positive) (congrFun same col)

/-- Enlarging the view by the actual private presentation fixes the original
message: the existing byte decoder and Hodge recovery already prove this. -/
theorem presentation_ciphertext_message_unique (A : Matrix (Fin rows) (Fin cols) ℤ)
    (d a : ℤ) (positive : 0 < d)
    (firstKey secondKey firstMessage secondMessage : Fin cols → Bool)
    (samePresentation : presentation A firstKey = presentation A secondKey)
    (sameCiphertext : ciphertextBytes A d a firstKey firstMessage =
      ciphertextBytes A d a secondKey secondMessage) : firstMessage = secondMessage := by
  apply coefficients_injective d positive
  exact Protocol.Storage.CoupledCiphertext.Disclosure.message_eq_of_sampleBytes_eq
    (presentation A firstKey) (coefficients d firstMessage) (coefficients d secondMessage) a a
    (opening A firstKey firstMessage) (opening A secondKey secondMessage)
    (by simpa only [ciphertextBytes, samePresentation] using sameCiphertext)

/-- Equal ciphertexts for distinct messages cannot also have the same
presentation commitment unless the actual canonical matrix bytes collide.
This is why the ciphertext-only law is not a storage-view theorem. -/
theorem snapshot_collision_of_same_public_view {Digest : Type}
    (hash : List UInt8 → Digest) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (positive : 0 < d) (firstKey secondKey firstMessage secondMessage : Fin cols → Bool)
    (different : firstMessage ≠ secondMessage)
    (sameCiphertext : ciphertextBytes A d a firstKey firstMessage =
      ciphertextBytes A d a secondKey secondMessage)
    (sameSnapshot :
      hash (Protocol.Storage.CoupledCodec.encode
        (Protocol.Storage.CoupledCodec.ofMatrix (presentation A firstKey))) =
      hash (Protocol.Storage.CoupledCodec.encode
        (Protocol.Storage.CoupledCodec.ofMatrix (presentation A secondKey)))) :
    (Protocol.Storage.CoupledCodec.encode
        (Protocol.Storage.CoupledCodec.ofMatrix (presentation A firstKey)) ≠
      Protocol.Storage.CoupledCodec.encode
        (Protocol.Storage.CoupledCodec.ofMatrix (presentation A secondKey))) ∧
      hash (Protocol.Storage.CoupledCodec.encode
        (Protocol.Storage.CoupledCodec.ofMatrix (presentation A firstKey))) =
      hash (Protocol.Storage.CoupledCodec.encode
        (Protocol.Storage.CoupledCodec.ofMatrix (presentation A secondKey))) := by
  refine ⟨?_, sameSnapshot⟩
  intro sameBytes
  exact different (presentation_ciphertext_message_unique A d a positive
    firstKey secondKey firstMessage secondMessage
    (Protocol.Storage.CoupledCodec.encode_matrix_injective sameBytes) sameCiphertext)

/-- The original private harmonic projection recovers this candidate's
original harmonic message from its actual decoded ciphertext bytes. -/
theorem decoded_recovers (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (key message : Fin cols → Bool) :
    (Protocol.Storage.CoupledCiphertext.decodeReal rows cols (ciphertextBytes A d a key message)).map
        (sheaf (presentation A key)).harmonicOneProjection =
      some (HCPCoupledEncoding.sample (presentation A key) (coefficients d message) a
        (opening A key message)).message.1 :=
  Protocol.Storage.CoupledCiphertext.decoded_sample_recovers _ _ _ _

/-- A public row-sum bound for the correlated coexact opening. -/
def rowBound (A : Matrix (Fin rows) (Fin cols) ℤ) (row : Fin rows) : ℕ :=
  ∑ col, (A row col).natAbs

@[simp] theorem presentation_natAbs (A : Matrix (Fin rows) (Fin cols) ℤ)
    (key : Fin cols → Bool) (row : Fin rows) (col : Fin cols) :
    (presentation A key row col).natAbs = (A row col).natAbs := by
  simp [presentation, Int.natAbs_mul]

@[simp] theorem coefficients_natAbs (d : ℤ) (message : Fin cols → Bool) (col : Fin cols) :
    (coefficients d message col).natAbs = d.natAbs := by
  simp [coefficients, Int.natAbs_mul]

theorem opening_natAbs_le (A : Matrix (Fin rows) (Fin cols) ℤ)
    (key message : Fin cols → Bool) (row : Fin rows) :
    (opening A key message row).natAbs ≤ rowBound A row := by
  calc
    _ ≤ ∑ col, (presentation A key row col * sign (message col)).natAbs :=
      Int.natAbs_sum_le Finset.univ _
    _ = rowBound A row := by simp [rowBound, Int.natAbs_mul]

theorem parity_natAbs_le (A : Matrix (Fin rows) (Fin cols) ℤ) (d : ℤ)
    (key message : Fin cols → Bool) (row : Fin rows) :
    ((∑ col, presentation A key row col * coefficients d message col) +
      opening A key message row).natAbs ≤ (d + 1).natAbs * rowBound A row := by
  rw [parity_normal, ← opening_mask A key message row, Int.natAbs_mul]
  exact Nat.mul_le_mul_left _ (opening_natAbs_le A key message row)

theorem identity_gram (cols : ℕ) :
    (1 : Matrix (Fin cols) (Fin cols) ℤ).transpose * 1 =
      (1 : ℤ) • (1 : Matrix (Fin cols) (Fin cols) ℤ) := by simp

/-- A fixed public dense matrix, with both information coordinates sharing
both cellular face equations. This is not an additional private basis. -/
def hadamardTwo : Matrix (Fin 2) (Fin 2) ℤ :=
  fun row col => if row = 1 ∧ col = 1 then -1 else 1

theorem hadamardTwo_gram :
    hadamardTwo.transpose * hadamardTwo = (2 : ℤ) • (1 : Matrix (Fin 2) (Fin 2) ℤ) := by
  decide

noncomputable section

/-- One fresh uniform sign vector; no public hash is assumed uniform. -/
def uniformKey (cols : ℕ) : PMF (Fin cols → Bool) :=
  PMF.ofFintype (fun _ => (Fintype.card (Fin cols → Bool) : ℝ≥0∞)⁻¹) (by
    classical
    simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    exact ENNReal.mul_inv_cancel (by simp)
      (ENNReal.natCast_ne_top (Fintype.card (Fin cols → Bool))))

@[simp] theorem uniformKey_apply (key : Fin cols → Bool) :
    uniformKey cols key = (Fintype.card (Fin cols → Bool) : ℝ≥0∞)⁻¹ := rfl

/-- Involutive masking preserves the actual uniform finite-key PMF. -/
theorem uniformKey_mask (message : Fin cols → Bool) :
    (uniformKey cols).map (fun key => mask key message) = uniformKey cols := by
  classical
  ext key
  rw [PMF.map_apply]
  simp only [uniformKey_apply]
  simp_rw [eq_mask_iff message key]
  simp

/-- Only canonical full ciphertext bytes are released in this candidate law. -/
def ciphertextDistribution (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (message : Fin cols → Bool) : PMF (List UInt8) :=
  (uniformKey cols).map fun key => ciphertextBytes A d a key message

theorem ciphertextDistribution_eq_normal (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (message : Fin cols → Bool) :
    ciphertextDistribution A d a message = (uniformKey cols).map (normalBytes A d a) := by
  have normal : (fun key => ciphertextBytes A d a key message) =
      normalBytes A d a ∘ (fun key => mask key message) := by
    funext key
    exact ciphertextBytes_normal A d a orthogonal key message
  unfold ciphertextDistribution
  rw [normal, ← PMF.map_comp, uniformKey_mask]

/-- Exact equality of one-use ciphertext-byte laws for every pair of messages.
The key-dependent presentation and storage names are absent from this view. -/
theorem ciphertextDistribution_eq (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (first second : Fin cols → Bool) :
    ciphertextDistribution A d a first = ciphertextDistribution A d a second :=
  (ciphertextDistribution_eq_normal A d a orthogonal first).trans
    (ciphertextDistribution_eq_normal A d a orthogonal second).symm

/-- The candidate is inhabited in every message dimension. -/
theorem identity_ciphertextDistribution_eq (cols : ℕ) (a : ℤ)
    (first second : Fin cols → Bool) :
    ciphertextDistribution (1 : Matrix (Fin cols) (Fin cols) ℤ) 1 a first =
      ciphertextDistribution (1 : Matrix (Fin cols) (Fin cols) ℤ) 1 a second :=
  ciphertextDistribution_eq _ 1 a (identity_gram cols) first second

/-- A dense coupled cellular example of the exact one-use byte-law equality. -/
theorem hadamardTwo_ciphertextDistribution_eq (a : ℤ) (first second : Fin 2 → Bool) :
    ciphertextDistribution hadamardTwo 2 a first = ciphertextDistribution hadamardTwo 2 a second :=
  ciphertextDistribution_eq hadamardTwo 2 a hadamardTwo_gram first second

/-- Any deterministic digest of the ciphertext preserves the same one-use law;
this says nothing about a separate digest of the key-dependent presentation. -/
theorem digestDistribution_eq {Digest : Type} (digest : List UInt8 → Digest)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (first second : Fin cols → Bool) :
    (ciphertextDistribution A d a first).map digest =
      (ciphertextDistribution A d a second).map digest :=
  congrArg (fun law : PMF (List UInt8) => law.map digest)
    (ciphertextDistribution_eq A d a orthogonal first second)

end

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeSignSampler
