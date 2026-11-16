module

public import Protocol.Transfer.PathSignature.NativeSignSampler

@[expose] public section

/-!
# Exact one-use guessing probability for the signed native candidate

An independent uniform Boolean message and a fresh independent uniform sign
key generate the actual native ciphertext bytes. The sampler's all-message
byte-law equality factors this joint law into a uniform message independent
of the masked ciphertext. Every deterministic complete-message decoder from
those bytes succeeds with probability exactly `1 / 2^cols`. The same equality
holds for a decoder with a separately sampled fixed random-tape law, and for
deterministic postprocessing such as a ciphertext digest.

A partial decoder may instead return an arbitrary integer coefficient vector
or fail. Thresholding its coordinates at zero totalizes it to a bit-vector
guess. For positive `d`, every correct partial output gives a correct total
guess, so its recovery probability is at most the same `1 / 2^cols`.

The uniform plaintext hypothesis belongs to this quantitative guessing
statement. The sampler's equality of ciphertext laws for every pair of fixed
messages does not require that hypothesis. For positive `d`, injectivity of
the original harmonic coefficient encoding identifies correct bit-vector
recovery with correct recovery of that encoded native plaintext.

Only the actual ciphertext and deterministic functions of it are exposed.
No message-dependent auxiliary input or random tape, public operator hash,
credential, proof transcript, storage-view security, encryption oracle or
key-reuse result is included. This remains a non-default one-use candidate.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeSignPrivacy

open NativeSignSampler
open scoped ENNReal

variable {rows cols : ℕ}

/-- The actual message/key sampling law, releasing the original native bytes.
The key law is fixed independently of the sampled uniform message. -/
def jointLaw (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) :
    PMF ((Fin cols → Bool) × List UInt8) :=
  (uniformKey cols).bind fun message =>
    (uniformKey cols).map fun key => (message, ciphertextBytes A d a key message)

/-- A fixed observation law sampled independently of the uniform message.
This is a product of existing PMFs, not a supplied independence assertion. -/
def independentLaw {View : Type} (view : PMF View) : PMF ((Fin cols → Bool) × View) :=
  view.bind fun observation => (uniformKey cols).map fun message => (message, observation)

/-- Reindexing by the actual key mask removes all message dependence from the
ciphertext component of the actual joint law. -/
theorem jointLaw_eq_independent (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ)) :
    jointLaw A d a = independentLaw ((uniformKey cols).map (normalBytes A d a)) := by
  have inner (message : Fin cols → Bool) :
      (uniformKey cols).map (fun key => (message, ciphertextBytes A d a key message)) =
        (uniformKey cols).map (fun masked => (message, normalBytes A d a masked)) := by
    have law := congrArg (fun value : PMF (List UInt8) =>
      value.map (fun bytes => (message, bytes)))
      (ciphertextDistribution_eq_normal A d a orthogonal message)
    simpa only [ciphertextDistribution, PMF.map_comp, Function.comp_def] using law
  unfold jointLaw
  simp_rw [inner]
  unfold independentLaw
  rw [PMF.bind_map]
  change ((uniformKey cols).bind fun message =>
      (uniformKey cols).bind fun masked => PMF.pure (message, normalBytes A d a masked)) =
    (uniformKey cols).bind fun masked =>
      (uniformKey cols).bind fun message => PMF.pure (message, normalBytes A d a masked)
  exact PMF.bind_comm _ _ _

/-- Any complete-message decoder of an independently sampled view guesses one
of the equally likely original message vectors, with inverse-cardinality mass. -/
theorem independent_guess_probability {View : Type} (view : PMF View)
    (decoder : View → (Fin cols → Bool)) :
    (independentLaw view).toOuterMeasure {outcome | decoder outcome.2 = outcome.1} =
      (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols := by
  classical
  have inner (observation : View) :
      ((uniformKey cols).map (fun message => (message, observation))).toOuterMeasure
        {outcome | decoder outcome.2 = outcome.1} =
          (Fintype.card (Fin cols → Bool) : ℝ≥0∞)⁻¹ := by
    rw [PMF.toOuterMeasure_map_apply]
    have event : (fun message => (message, observation)) ⁻¹'
        {outcome | decoder outcome.2 = outcome.1} = {decoder observation} := by
      ext message
      simp [eq_comm]
    rw [event, PMF.toOuterMeasure_apply_singleton, uniformKey_apply]
  unfold independentLaw
  rw [PMF.toOuterMeasure_bind_apply]
  simp_rw [inner]
  rw [ENNReal.tsum_mul_right, PMF.tsum_coe, one_mul]
  simp

/-- Exact full bit-vector recovery probability from the actual ciphertext
when the target message and fresh key are independently uniform. -/
theorem ciphertext_guess_probability (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (decoder : List UInt8 → (Fin cols → Bool)) :
    (jointLaw A d a).toOuterMeasure {outcome | decoder outcome.2 = outcome.1} =
      (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols := by
  rw [jointLaw_eq_independent A d a orthogonal]
  exact independent_guess_probability _ decoder

/-- For positive `d`, guessing the encoded original harmonic coefficients is
equivalent to guessing the complete original Boolean message. -/
theorem ciphertext_encoded_guess_probability (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) (decoder : List UInt8 → (Fin cols → Bool)) :
    (jointLaw A d a).toOuterMeasure
        {outcome | coefficients d (decoder outcome.2) = coefficients d outcome.1} =
      (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols := by
  have event : {outcome : (Fin cols → Bool) × List UInt8 |
      coefficients d (decoder outcome.2) = coefficients d outcome.1} =
      {outcome | decoder outcome.2 = outcome.1} := by
    ext outcome
    exact (coefficients_injective d positive).eq_iff
  rw [event]
  exact ciphertext_guess_probability A d a orthogonal decoder

/-- Deterministic ciphertext postprocessing, including its digest, supplies
no improvement in complete-message guessing under the same uniform target. -/
theorem digest_guess_probability {Digest : Type} (digest : List UInt8 → Digest)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (decoder : Digest → (Fin cols → Bool)) :
    (jointLaw A d a).toOuterMeasure {outcome | decoder (digest outcome.2) = outcome.1} =
      (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols :=
  ciphertext_guess_probability A d a orthogonal (fun bytes => decoder (digest bytes))

/-- A concrete total bit guess from arbitrary partial integer output.
Failure gives the all-false vector; an integer coordinate is positive or not. -/
def totalizeCoefficientGuess {View : Type}
    (decoder : View → Option (Fin cols → ℤ)) (observation : View) : Fin cols → Bool :=
  match decoder observation with
  | none => fun _ => false
  | some values => fun col => decide (0 < values col)

/-- Positive scaling makes the threshold totalizer correct whenever the
partial algorithm actually returns the original encoded coefficients. -/
theorem totalizeCoefficientGuess_of_correct {View : Type}
    (decoder : View → Option (Fin cols → ℤ)) (d : ℤ) (positive : 0 < d)
    (observation : View) (message : Fin cols → Bool)
    (correct : decoder observation = some (coefficients d message)) :
    totalizeCoefficientGuess decoder observation = message := by
  funext col
  simp only [totalizeCoefficientGuess, correct]
  change decide (0 < d * sign (message col)) = message col
  cases message col with
  | false => simp [sign, HCP.AxisSignedSampler.coefficient, le_of_lt positive]
  | true => simp [sign, HCP.AxisSignedSampler.coefficient, positive]

/-- An arbitrary partial integer extractor cannot recover the encoded
uniform target more often than a total bit guess from this independent view. -/
theorem independent_partial_coeff_guess_probability {View : Type} (view : PMF View)
    (d : ℤ) (positive : 0 < d) (decoder : View → Option (Fin cols → ℤ)) :
    (independentLaw view).toOuterMeasure
        {outcome | decoder outcome.2 = some (coefficients d outcome.1)} ≤
      (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols := by
  have included :
      {outcome : (Fin cols → Bool) × View |
        decoder outcome.2 = some (coefficients d outcome.1)} ⊆
      {outcome | totalizeCoefficientGuess decoder outcome.2 = outcome.1} := by
    intro outcome correct
    exact totalizeCoefficientGuess_of_correct decoder d positive outcome.2 outcome.1 correct
  calc
    _ ≤ (independentLaw view).toOuterMeasure
        {outcome | totalizeCoefficientGuess decoder outcome.2 = outcome.1} :=
      MeasureTheory.measure_mono included
    _ = (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols :=
      independent_guess_probability view (totalizeCoefficientGuess decoder)

/-- Actual ciphertext-only partial integer recovery has the same upper bound;
invalid coefficient vectors and failure are permitted outputs. -/
theorem ciphertext_partial_coeff_guess_probability
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) (decoder : List UInt8 → Option (Fin cols → ℤ)) :
    (jointLaw A d a).toOuterMeasure
        {outcome | decoder outcome.2 = some (coefficients d outcome.1)} ≤
      (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols := by
  rw [jointLaw_eq_independent A d a orthogonal]
  exact independent_partial_coeff_guess_probability _ d positive decoder

/-- An actual independently sampled fixed random tape is appended to the
same generated message/ciphertext pair; it is not an arbitrary auxiliary map. -/
def randomizedJointLaw {Tape : Type} (tape : PMF Tape)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) :
    PMF ((Fin cols → Bool) × (List UInt8 × Tape)) :=
  (jointLaw A d a).bind fun outcome =>
    tape.map fun random => (outcome.1, (outcome.2, random))

theorem randomizedJointLaw_eq_independent {Tape : Type} (tape : PMF Tape)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ)) :
    randomizedJointLaw tape A d a =
      independentLaw (((uniformKey cols).map (normalBytes A d a)).bind fun bytes =>
        tape.map fun random => (bytes, random)) := by
  rw [randomizedJointLaw, jointLaw_eq_independent A d a orthogonal]
  unfold independentLaw
  rw [PMF.bind_bind, PMF.bind_bind]
  congr 1
  funext bytes
  rw [PMF.bind_map, PMF.bind_map]
  change ((uniformKey cols).bind fun message =>
      tape.bind fun random => PMF.pure (message, (bytes, random))) =
    tape.bind fun random =>
      (uniformKey cols).bind fun message => PMF.pure (message, (bytes, random))
  exact PMF.bind_comm _ _ _

/-- Exact recovery mass is unchanged for every decoder using an independently
sampled fixed random tape in addition to the original ciphertext bytes. -/
theorem randomized_guess_probability {Tape : Type} (tape : PMF Tape)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (decoder : List UInt8 → Tape → (Fin cols → Bool)) :
    (randomizedJointLaw tape A d a).toOuterMeasure
        {outcome | decoder outcome.2.1 outcome.2.2 = outcome.1} =
      (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols := by
  rw [randomizedJointLaw_eq_independent tape A d a orthogonal]
  exact independent_guess_probability _ (fun view : List UInt8 × Tape => decoder view.1 view.2)

/-- The same bound applies to any partial integer extractor using the actual
ciphertext and a separately sampled fixed random tape. A richer public view
must first have its own proved factorization; this is not supplied for the
current native security experiment's operator/snapshot commitments. -/
theorem randomized_partial_coeff_guess_probability {Tape : Type} (tape : PMF Tape)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) (decoder : List UInt8 → Tape → Option (Fin cols → ℤ)) :
    (randomizedJointLaw tape A d a).toOuterMeasure
        {outcome | decoder outcome.2.1 outcome.2.2 = some (coefficients d outcome.1)} ≤
      (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols := by
  rw [randomizedJointLaw_eq_independent tape A d a orthogonal]
  exact independent_partial_coeff_guess_probability _ d positive
    (fun view : List UInt8 × Tape => decoder view.1 view.2)

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeSignPrivacy
