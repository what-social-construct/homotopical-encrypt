module

public import Protocol.Transfer.PathSignature.NativeCommittedRandomOracle
public import Protocol.Transfer.PathSignature.NativeCommittedRandomOracle.DisclosureGuessing

@[expose] public section

/-!
# Deterministic sign-key disclosure in the actual native byte random oracle

The same V2 instance, ciphertext and shared byte oracle are retained. The
decoder additionally receives a fixed function of the sampled sign key.
This disclosure has no nonce access and performs no byte-oracle queries.

In the ideal game, the ciphertext mask is uniform independently of the sign
key. For each mask, the ideal public program sees each key only through its
disclosed value. The finite range therefore controls the recovery probability
even for adaptive public queries. The original hidden-nonce event comparison
then adds the same loss for the decoder budget and two honest digest calls.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRandomOracle.Disclosure

open OracleSpec OracleComp NativeSignSampler
open Storage.OperatorCommitment.RandomOracle
open scoped ENNReal

variable {rows cols : ℕ} {Advice Output : Type}

/-- The additional advice is evaluated on the actual sampled key. -/
def game (disclose : Bits cols → Advice) (decoder : Advice → Decoder cols Output)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) :
    OracleComp NativeSpec (Bits cols × Output) :=
  gameWithKey (fun key => decoder (disclose key)) base A d a

/-- Run the original public wrapper with the normal ciphertext for this mask
and the independent ideal operator root. -/
def guessAtMask (decoder : Advice → Decoder cols Output)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (masked : Bits cols) (advice : Advice) : ProbComp Output := do
  let operatorRoot ← $ᵗ TCB.Hash32
  (simulateQ publicOracle.romImpl
    (afterRoot (decoder advice) (NativeRelation.credentialBytes base)
      (normalBytes A d a masked) operatorRoot)).run' ∅

private theorem mask_comm (first second : Bits cols) :
    mask first second = mask second first := by
  funext col
  change (first col == second col) = (second col == first col)
  cases first col <;> cases second col <;> rfl

/-- Reindex the message conditional on each key, then put the resulting
uniform mask first. The key is still sampled uniformly at every mask. -/
theorem ideal_game_masked (disclose : Bits cols → Advice) (decoder : Advice → Decoder cols Output)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ)) :
    (simulateQ (SecretEncoding.idealImpl publicOracle Storage.CoupledCodec.Packet TCB.Hash32)
        (game disclose decoder base A d a)).run' (∅, ∅) =ᵈ
      (do let masked ← $ᵗ (Bits cols)
          let key ← $ᵗ (Bits cols)
          let result ← guessAtMask decoder base A d a masked (disclose key)
          pure (mask masked key, result)) := by
  rw [game, ideal_gameWithKey_run']
  refine (OracleComp.EvalDistEq.bind_bind_swap _ _ _).trans ?_
  have reindexed :
      (do let key ← $ᵗ (Bits cols)
          let message ← $ᵗ (Bits cols)
          let operatorRoot ← $ᵗ TCB.Hash32
          let result ← (simulateQ publicOracle.romImpl
            (afterRoot (decoder (disclose key)) (NativeRelation.credentialBytes base)
              (ciphertextBytes A d a key message) operatorRoot)).run' ∅
          pure (message, result)) =ᵈ
      (do let key ← $ᵗ (Bits cols)
          let masked ← $ᵗ (Bits cols)
          let result ← guessAtMask decoder base A d a masked (disclose key)
          pure (mask masked key, result)) := by
    apply EvalDistEq.bind_right ($ᵗ (Bits cols))
    intro key
    have normal (message : Bits cols) :
        ciphertextBytes A d a key message = normalBytes A d a (mask message key) := by
      rw [ciphertextBytes_normal A d a orthogonal, mask_comm key message]
    have cancel (message : Bits cols) : mask (mask message key) key = message :=
      mask_involutive key message
    simpa only [guessAtMask, bind_assoc, normal, cancel] using
      (uniform_mask_bind key (fun masked => do
        let result ← guessAtMask decoder base A d a masked (disclose key)
        pure (mask masked key, result)))
  exact reindexed.trans (OracleComp.EvalDistEq.bind_bind_swap _ _ _)

/-- Adaptivity and private randomness of the decoder are allowed in the
ideal game. Only the number of realized key disclosures enters the bound. -/
theorem ideal_recovery_probability_le (disclose : Bits cols → Advice)
    (target : Bits cols → Output) (targetInjective : Function.Injective target)
    (decoder : Advice → Decoder cols Output) (base : NativeRelation.Witness rows cols)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ)) :
    idealProbability (game disclose decoder base A d a)
        (fun outcome => outcome.2 = target outcome.1) ≤
      ((HCP.FiniteRecovery.disclosedViews disclose).card : ℝ≥0∞) / (2 : ℝ≥0∞)^cols := by
  have reindexed := (ideal_game_masked disclose decoder base A d a orthogonal).prEvent_eq
    (fun outcome => outcome.2 = target outcome.1)
  calc
    _ = Pr{let outcome ←
        (simulateQ (SecretEncoding.idealImpl publicOracle Storage.CoupledCodec.Packet TCB.Hash32)
          (game disclose decoder base A d a)).run' (∅, ∅)}[outcome.2 = target outcome.1] := by
      simp only [idealProbability, StateT.run'_eq, prEvent_map]
    _ = Pr{let outcome ← (do
          let masked ← $ᵗ (Bits cols)
          let key ← $ᵗ (Bits cols)
          let result ← guessAtMask decoder base A d a masked (disclose key)
          pure (mask masked key, result) : ProbComp (Bits cols × Output))}[
        outcome.2 = target outcome.1] := reindexed
    _ ≤ _ := by
      apply prEvent_bind_le_of_forall_le _ _ _
      intro masked
      have ordered (key : Bits cols) : mask masked key = maskEquiv masked key :=
        mask_comm masked key
      simpa only [ordered, map_bind, map_pure, bind_pure_comp, bind_map_left,
        Functor.map_map, Function.comp_def] using uniform_guess_with_disclosure_range_le
        disclose (target ∘ maskEquiv masked) (targetInjective.comp (maskEquiv masked).injective)
        (guessAtMask decoder base A d a masked)

/-- Real recovery with deterministic key disclosure has the same original
nonce loss on top of the finite-disclosure bound. The target can be the
message itself or an injective encoding, such as the positive-scale native
coefficients inside an optional output. -/
theorem recovery_probability_le (disclose : Bits cols → Advice)
    (target : Bits cols → Output) (targetInjective : Function.Injective target)
    (decoder : Advice → Decoder cols Output) {q : ℕ}
    (bounded : ∀ advice view, IsQueryBoundP (decoder advice view) publicOnly q)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ)) :
    realProbability (game disclose decoder base A d a)
        (fun outcome => outcome.2 = target outcome.1) ≤
      ((HCP.FiniteRecovery.disclosedViews disclose).card : ℝ≥0∞) / (2 : ℝ≥0∞)^cols +
        ((q + 2 : ℕ) : ℝ≥0∞) * ((256 ^ 32 : ℕ) : ℝ≥0∞)⁻¹ := by
  have gameBound : IsQueryBoundP (game disclose decoder base A d a) publicQuery (q + 2) :=
    gameWithKey_query_bound (fun key => decoder (disclose key))
      (fun key view => bounded (disclose key) view) base A d a
  exact (event_probability_le gameBound (fun outcome => outcome.2 = target outcome.1)).trans
    (add_le_add
      (ideal_recovery_probability_le disclose target targetInjective decoder base A d a orthogonal)
      le_rfl)

/-- The target can be the original integral coefficient vector, with failure
represented by an optional output from the actual decoder. -/
theorem partial_coeff_recovery_probability_le (disclose : Bits cols → Advice)
    (decoder : Advice → Decoder cols (Option (Fin cols → ℤ))) {q : ℕ}
    (bounded : ∀ advice view, IsQueryBoundP (decoder advice view) publicOnly q)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) :
    realProbability (game disclose decoder base A d a)
        (fun outcome => outcome.2 = some (coefficients d outcome.1)) ≤
      ((HCP.FiniteRecovery.disclosedViews disclose).card : ℝ≥0∞) / (2 : ℝ≥0∞)^cols +
        ((q + 2 : ℕ) : ℝ≥0∞) * ((256 ^ 32 : ℕ) : ℝ≥0∞)⁻¹ :=
  recovery_probability_le disclose (fun message => some (coefficients d message))
    (fun _ _ same => coefficients_injective d positive (Option.some.inj same))
    decoder bounded base A d a orthogonal

/-- For an `r`-bit disclosure the finite-range term is at most `2^r/2^cols`. -/
theorem bit_disclosure_recovery_probability_le {r : ℕ} (disclose : Bits cols → Bits r)
    (target : Bits cols → Output) (targetInjective : Function.Injective target)
    (decoder : Bits r → Decoder cols Output) {q : ℕ}
    (bounded : ∀ advice view, IsQueryBoundP (decoder advice view) publicOnly q)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ)) :
    realProbability (game disclose decoder base A d a)
        (fun outcome => outcome.2 = target outcome.1) ≤
      (2 : ℝ≥0∞)^r / (2 : ℝ≥0∞)^cols +
        ((q + 2 : ℕ) : ℝ≥0∞) * ((256 ^ 32 : ℕ) : ℝ≥0∞)⁻¹ := by
  refine (recovery_probability_le disclose target targetInjective decoder bounded base A d a
    orthogonal).trans ?_
  apply add_le_add _ le_rfl
  apply ENNReal.div_le_div_right
  have count := Finset.card_le_univ (HCP.FiniteRecovery.disclosedViews disclose)
  have size : Fintype.card (Bits r) = 2^r := by simp
  rw [size] at count
  exact_mod_cast count

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRandomOracle.Disclosure
