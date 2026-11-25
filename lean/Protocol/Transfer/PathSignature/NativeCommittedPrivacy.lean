module

public import Protocol.Transfer.PathSignature.NativeCommitted
public import Protocol.Transfer.PathSignature.NativeSignPrivacy

@[expose] public section

/-!
# Finite public-instance recovery and an operator-hiding reduction

Independent uniform messages and fresh sign keys in the existing native
family supply the actual target presentation, message and Hodge openings.
An independent uniform 32-byte nonce opens its
operator commitment. The base witness supplies only the original private
source presentation and credential salt. The released view contains the V2
instance bytes and full ciphertext bytes; neither private nonce nor matrix
bytes are released.

Replacing the target commitment by a commitment to a fixed reference operator
gives a hybrid with complete-message recovery probability exactly `2^-cols`.
The real recovery excess is bounded by the advantage of an explicit
chosen-operator commitment test, which runs the same decoder on the same
ciphertext and credential. Positive scaling gives the analogous bound for
partial integer-coefficient recovery. These are reductions for this finite
instance view; the hash backend must separately bound that distinguishing
advantage. The V1 forgery bound and additional proof/storage transcripts are
not silently transferred to the V2 experiment.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedPrivacy

open NativeSignSampler
open scoped ENNReal

abbrev Bytes := List UInt8
abbrev View := Bytes × Bytes
abbrev NonceSeed := Storage.OperatorCommitment.NonceSeed

variable {rows cols : ℕ}

/-- The finite seed retains every byte of the private operator nonce. -/
abbrev nonceOfSeed := Storage.OperatorCommitment.nonceOfSeed

theorem nonceOfSeed_injective : Function.Injective nonceOfSeed :=
  Storage.OperatorCommitment.nonceOfSeed_injective

theorem card_nonceSeed : Fintype.card NonceSeed = 256 ^ 32 :=
  Storage.OperatorCommitment.card_nonceSeed

/-- Reuse the original native witness: only its generated target and openings change. -/
def sampleWitness (base : NativeRelation.Witness rows cols)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (key message : Fin cols → Bool) (nonce : Storage.OperatorCommitment.Nonce) :
    NativeCommitted.Witness rows cols where
  native := { base with
    target := presentation A key
    z := coefficients d message
    a := a
    u := opening A key message }
  operatorNonce := nonce

/-- The original credential depends only on the retained source and credential salt. -/
theorem sampleWitness_credential (base : NativeRelation.Witness rows cols)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (key message : Fin cols → Bool) (nonce : Storage.OperatorCommitment.Nonce) :
    NativeRelation.credentialBytes (sampleWitness base A d a key message nonce).native =
      NativeRelation.credentialBytes base := rfl

/-- Existing entry bounds give a valid original native witness for every sampled key. -/
theorem sampleWitness_bounded (base : NativeRelation.Witness rows cols)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) (profile : NativeRelation.Profile)
    (sourceBound : ∀ row col, (base.source row col).natAbs ≤ profile.bound)
    (matrixBound : ∀ row col, (A row col).natAbs ≤ profile.bound)
    (messageBound : d.natAbs ≤ profile.bound) (exactBound : a.natAbs ≤ profile.bound)
    (noiseBound : ∀ row, rowBound A row ≤ profile.bound)
    (saltLength : base.salt.length = profile.saltBytes)
    (key message : Fin cols → Bool) (nonce : Storage.OperatorCommitment.Nonce) :
    NativeRelation.Bounded profile (sampleWitness base A d a key message nonce).native := by
  refine ⟨sourceBound, ?_, ?_, exactBound, ?_, saltLength⟩
  · intro row col
    simpa only [sampleWitness, presentation_natAbs] using matrixBound row col
  · intro col
    simpa only [sampleWitness, coefficients_natAbs] using messageBound
  · intro row
    exact (opening_natAbs_le A key message row).trans (noiseBound row)

/-- The only public values are the versioned three-name instance and full ciphertext. -/
def viewFor (hash : Bytes → TCB.Hash32) (credential operatorRoot : TCB.Hash32)
    (ciphertext : Bytes) : View :=
  (NativeCommitted.encodeInstance ⟨credential, operatorRoot, hash ciphertext⟩, ciphertext)

theorem viewFor_instance (hash : Bytes → TCB.Hash32)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ)
    (d a : ℤ) (key message : Fin cols → Bool) (nonce : Storage.OperatorCommitment.Nonce) :
    viewFor hash (hash (NativeRelation.credentialBytes base))
      (Storage.OperatorCommitment.commit hash
        (Storage.CoupledCodec.ofMatrix (presentation A key)) nonce)
      (ciphertextBytes A d a key message) =
      (NativeCommitted.encodeInstance
        (NativeCommitted.instanceFor hash (sampleWitness base A d a key message nonce)),
        Storage.CoupledCiphertext.sampleBytes
          (sampleWitness base A d a key message nonce).native.target
          (sampleWitness base A d a key message nonce).native.z
          (sampleWitness base A d a key message nonce).native.a
          (sampleWitness base A d a key message nonce).native.u) := rfl

noncomputable section

/-- Uniform finite byte seeds, independently sampled of the message and sign key. -/
def uniformNonceSeed : PMF NonceSeed :=
  PMF.ofFintype (fun _ => (Fintype.card NonceSeed : ℝ≥0∞)⁻¹) (by
    classical
    simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    exact ENNReal.mul_inv_cancel (by simp) (ENNReal.natCast_ne_top _))

def uniformNonce : PMF Storage.OperatorCommitment.Nonce := uniformNonceSeed.map nonceOfSeed

theorem uniformNonce_apply (seed : NonceSeed) :
    uniformNonce (nonceOfSeed seed) = (Fintype.card NonceSeed : ℝ≥0∞)⁻¹ := by
  classical
  rw [uniformNonce, PMF.map_apply]
  simp only [nonceOfSeed_injective.eq_iff, uniformNonceSeed, PMF.ofFintype_apply]
  simp

/-- The challenge chooses the actual target or a reference operator, then hides
its independently sampled nonce. The reduction retains its own message and key. -/
def operatorChallengeLaw (hash : Bytes → TCB.Hash32)
    (A reference : Matrix (Fin rows) (Fin cols) ℤ) (real : Bool) :
    PMF ((Fin cols → Bool) × ((Fin cols → Bool) × TCB.Hash32)) :=
  (uniformKey cols).bind fun message =>
    (uniformKey cols).bind fun key =>
      uniformNonce.map fun nonce =>
        (message, (key, Storage.OperatorCommitment.commit hash
          (Storage.CoupledCodec.ofMatrix (if real then presentation A key else reference)) nonce))

/-- The reduction presents precisely the actual ciphertext and canonical public names. -/
def publicJointLaw (hash : Bytes → TCB.Hash32) (credential : TCB.Hash32)
    (A reference : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) (real : Bool) :
    PMF ((Fin cols → Bool) × View) :=
  (operatorChallengeLaw hash A reference real).map fun outcome =>
    (outcome.1, viewFor hash credential outcome.2.2
      (ciphertextBytes A d a outcome.2.1 outcome.1))

/-- The real view is generated from the same private witness and full ciphertext. -/
theorem publicJointLaw_real (hash : Bytes → TCB.Hash32)
    (base : NativeRelation.Witness rows cols) (A reference : Matrix (Fin rows) (Fin cols) ℤ)
    (d a : ℤ) :
    publicJointLaw hash (hash (NativeRelation.credentialBytes base)) A reference d a true =
      (uniformKey cols).bind fun message =>
        (uniformKey cols).bind fun key =>
          uniformNonce.map fun nonce =>
            (message, (NativeCommitted.encodeInstance
              (NativeCommitted.instanceFor hash (sampleWitness base A d a key message nonce)),
              ciphertextBytes A d a key message)) := by
  simp only [publicJointLaw, operatorChallengeLaw, PMF.map_bind, PMF.map_comp,
    Function.comp_def, ite_true]
  rfl

/-- In the reference world the operator root is a function of an independent tape. -/
theorem publicJointLaw_reference (hash : Bytes → TCB.Hash32) (credential : TCB.Hash32)
    (A reference : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) :
    publicJointLaw hash credential A reference d a false =
      (NativeSignPrivacy.randomizedJointLaw uniformNonce A d a).map fun outcome =>
        (outcome.1, viewFor hash credential
          (Storage.OperatorCommitment.commit hash (Storage.CoupledCodec.ofMatrix reference)
            outcome.2.2) outcome.2.1) := by
  simp only [publicJointLaw, operatorChallengeLaw, NativeSignPrivacy.randomizedJointLaw,
    NativeSignPrivacy.jointLaw, PMF.map_bind, PMF.map_comp, PMF.bind_bind, PMF.bind_map,
    Function.comp_def, Bool.false_eq_true, ite_false]

/-- The explicit chosen-operator test runs the public decoder and checks its own message. -/
def operatorTest (hash : Bytes → TCB.Hash32) (credential : TCB.Hash32)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (decoder : View → (Fin cols → Bool))
    (message key : Fin cols → Bool) (root : TCB.Hash32) : Bool :=
  decide (decoder (viewFor hash credential root (ciphertextBytes A d a key message)) = message)

def commitmentAcceptProbability (hash : Bytes → TCB.Hash32) (credential : TCB.Hash32)
    (A reference : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (decoder : View → (Fin cols → Bool)) (real : Bool) : ℝ≥0∞ :=
  (operatorChallengeLaw hash A reference real).toOuterMeasure
    {outcome | operatorTest hash credential A d a decoder outcome.1 outcome.2.1 outcome.2.2 = true}

def recoveryProbability (hash : Bytes → TCB.Hash32) (credential : TCB.Hash32)
    (A reference : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (decoder : View → (Fin cols → Bool)) (real : Bool) : ℝ≥0∞ :=
  (publicJointLaw hash credential A reference d a real).toOuterMeasure
    {outcome | decoder outcome.2 = outcome.1}

theorem recoveryProbability_eq_commitmentAccept (hash : Bytes → TCB.Hash32)
    (credential : TCB.Hash32) (A reference : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (decoder : View → (Fin cols → Bool)) (real : Bool) :
    recoveryProbability hash credential A reference d a decoder real =
      commitmentAcceptProbability hash credential A reference d a decoder real := by
  simp [recoveryProbability, publicJointLaw, PMF.toOuterMeasure_map_apply,
    commitmentAcceptProbability, operatorTest]

theorem reference_recovery_probability (hash : Bytes → TCB.Hash32) (credential : TCB.Hash32)
    (A reference : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (decoder : View → (Fin cols → Bool)) :
    recoveryProbability hash credential A reference d a decoder false =
      (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols := by
  rw [recoveryProbability, publicJointLaw_reference, PMF.toOuterMeasure_map_apply]
  exact NativeSignPrivacy.randomized_guess_probability uniformNonce A d a orthogonal
    (fun bytes nonce => decoder (viewFor hash credential
      (Storage.OperatorCommitment.commit hash (Storage.CoupledCodec.ofMatrix reference) nonce) bytes))

/-- The two-sided acceptance gap of this actual chosen-operator commitment test. -/
def operatorHidingAdvantage (hash : Bytes → TCB.Hash32) (credential : TCB.Hash32)
    (A reference : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (decoder : View → (Fin cols → Bool)) : ℝ≥0∞ :=
  max (commitmentAcceptProbability hash credential A reference d a decoder true -
      commitmentAcceptProbability hash credential A reference d a decoder false)
    (commitmentAcceptProbability hash credential A reference d a decoder false -
      commitmentAcceptProbability hash credential A reference d a decoder true)

/-- Recovery from the real V2 instance and full ciphertext reduces to the
specified commitment test; its advantage is a quantitative backend target. -/
theorem recovery_le_guess_plus_operatorHiding (hash : Bytes → TCB.Hash32)
    (credential : TCB.Hash32) (A reference : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (decoder : View → (Fin cols → Bool)) :
    recoveryProbability hash credential A reference d a decoder true ≤
      (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols +
        operatorHidingAdvantage hash credential A reference d a decoder := by
  have gap : recoveryProbability hash credential A reference d a decoder true ≤
      recoveryProbability hash credential A reference d a decoder false +
        operatorHidingAdvantage hash credential A reference d a decoder := by
    rw [recoveryProbability_eq_commitmentAccept, recoveryProbability_eq_commitmentAccept]
    let p := commitmentAcceptProbability hash credential A reference d a decoder true
    let q := commitmentAcceptProbability hash credential A reference d a decoder false
    change p ≤ q + max (p - q) (q - p)
    calc
      p ≤ p - q + q := le_tsub_add
      _ ≤ max (p - q) (q - p) + q := add_le_add (le_max_left _ _) le_rfl
      _ = q + max (p - q) (q - p) := add_comm _ _
  rwa [reference_recovery_probability hash credential A reference d a orthogonal decoder] at gap

/-- A partial extractor for the original integer harmonic coefficients has the
same bound, using the existing coefficient-to-bit reduction on its outputs. -/
theorem partial_coeff_recovery_le (hash : Bytes → TCB.Hash32) (credential : TCB.Hash32)
    (A reference : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) (decoder : View → Option (Fin cols → ℤ)) :
    (publicJointLaw hash credential A reference d a true).toOuterMeasure
      {outcome | decoder outcome.2 = some (coefficients d outcome.1)} ≤
        (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols +
          operatorHidingAdvantage hash credential A reference d a
            (NativeSignPrivacy.totalizeCoefficientGuess decoder) := by
  calc
    _ ≤ recoveryProbability hash credential A reference d a
        (NativeSignPrivacy.totalizeCoefficientGuess decoder) true := by
      apply MeasureTheory.measure_mono
      intro outcome correct
      exact NativeSignPrivacy.totalizeCoefficientGuess_of_correct decoder d positive
        outcome.2 outcome.1 correct
    _ ≤ _ := recovery_le_guess_plus_operatorHiding hash credential A reference d a orthogonal _

end

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedPrivacy
