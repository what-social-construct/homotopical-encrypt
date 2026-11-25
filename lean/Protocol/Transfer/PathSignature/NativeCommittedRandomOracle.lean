module

public import Protocol.Storage.OperatorCommitment.RandomOracle
public import Protocol.Transfer.PathSignature.NativeCommittedPrivacy
public import Protocol.Transfer.PathSignature.NativeCommittedRandomOracle.Guessing

@[expose] public section

/-!
# Recovery from the actual native instance in a shared byte random oracle

The adversary is an oracle program over uniform sampling and public byte-hash
queries. It cannot call the private operator-derivation interface. The honest
wrapper samples independent message and sign key, makes one operator
derivation, hashes the original source credential and full native ciphertext,
and gives the decoder the canonical V2 instance and that same ciphertext.

The real handler uses one coherent byte-oracle cache for all three names.
The ideal handler samples the operator root independently. Only the latter
world has the exact uniform-message guessing law. A pathwise public-query
budget gives the concrete hidden-nonce loss; there is no fixed-hash averaging
of an absolute advantage, hash implementation, running-time or transcript
privacy claim.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRandomOracle

open OracleSpec OracleComp
open NativeSignSampler
open scoped ENNReal

open Storage.OperatorCommitment.RandomOracle
abbrev PublicSpec := unifSpec + publicOracle
abbrev NativeSpec := publicOracle.withDerivations Storage.CoupledCodec.Packet TCB.Hash32
abbrev View := NativeCommittedPrivacy.View

variable {rows cols : ℕ} {Output : Type}

/-- Public oracle programs have no access to the private derivation branch. -/
abbrev Decoder (_cols : ℕ) (Output : Type) := View → OracleComp PublicSpec Output

def publicOnly : PublicSpec.Domain → Prop
  | .inl _ => False
  | .inr _ => True

instance : DecidablePred publicOnly := fun
  | .inl _ => isFalse id
  | .inr _ => isTrue trivial

def liftPublic (program : OracleComp PublicSpec Output) : OracleComp NativeSpec Output :=
  simulateQ (publicOracle.withDerivationsLift Storage.CoupledCodec.Packet TCB.Hash32) program

/-- The instance constructor contains only the three actual public names. -/
def namedView (credential operatorRoot ciphertextDigest : TCB.Hash32) (ciphertext : Bytes) : View :=
  (NativeCommitted.encodeInstance ⟨credential, operatorRoot, ciphertextDigest⟩, ciphertext)

theorem namedView_instance (hash : Bytes → TCB.Hash32)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ)
    (d a : ℤ) (key message : Bits cols) (nonce : Storage.OperatorCommitment.Nonce) :
    namedView (hash (NativeRelation.credentialBytes base))
      (Storage.OperatorCommitment.commit hash (Storage.CoupledCodec.ofMatrix (presentation A key)) nonce)
      (hash (ciphertextBytes A d a key message)) (ciphertextBytes A d a key message) =
      (NativeCommitted.encodeInstance (NativeCommitted.instanceFor hash
        (NativeCommittedPrivacy.sampleWitness base A d a key message nonce)),
        ciphertextBytes A d a key message) := rfl

/-- After the one private derivation, every operation uses only the public RO. -/
def afterRoot (decoder : Decoder cols Output) (credentialBytes ciphertext : Bytes)
    (operatorRoot : TCB.Hash32) : OracleComp PublicSpec Output := do
  let credential ← PublicSpec.query (.inr credentialBytes)
  let ciphertextDigest ← PublicSpec.query (.inr ciphertext)
  decoder (namedView credential operatorRoot ciphertextDigest ciphertext)

/-- The common native experiment, letting the honest wrapper choose a public
decoder continuation based on the sampled sign key. -/
def gameWithKey (decoderFor : Bits cols → Decoder cols Output)
    (base : NativeRelation.Witness rows cols)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) :
    OracleComp NativeSpec (Bits cols × Output) := do
  let message ← (liftM ($ᵗ (Bits cols)) : OracleComp NativeSpec _)
  let key ← (liftM ($ᵗ (Bits cols)) : OracleComp NativeSpec _)
  let operatorRoot ← NativeSpec.query (.inr (Storage.CoupledCodec.ofMatrix (presentation A key)))
  let result ← liftPublic (afterRoot (decoderFor key) (NativeRelation.credentialBytes base)
    (ciphertextBytes A d a key message) operatorRoot)
  pure (message, result)

/-- The actual native experiment; all sampled target material stays internal. -/
def game (decoder : Decoder cols Output) (base : NativeRelation.Witness rows cols)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) :
    OracleComp NativeSpec (Bits cols × Output) :=
  gameWithKey (fun _ => decoder) base A d a

/-- Lifting a public decoder preserves its counted byte-hash queries. -/
theorem liftPublic_query_bound (program : OracleComp PublicSpec Output) {q : ℕ}
    (bounded : IsQueryBoundP program publicOnly q) :
    IsQueryBoundP (liftPublic program) publicQuery q := by
  induction program using OracleComp.inductionOn generalizing q with
  | pure output => simp [liftPublic]
  | query_bind query continuation ih =>
    simp only [isQueryBoundP_query_bind_iff] at bounded
    simp only [liftPublic, simulateQ_bind, simulateQ_query, OracleQuery.input_query,
      OracleQuery.cont_query, OracleSpec.withDerivationsLift, id_map]
    rw [isQueryBoundP_query_bind_iff]
    have queryCost : publicQuery (.inl query) = publicOnly query := by
      cases query <;> rfl
    refine ⟨?_, ?_⟩
    · simpa only [queryCost] using bounded.1
    · intro answer
      apply ih answer
      simpa only [queryCost] using bounded.2 answer

/-- The two honest public digest calls add exactly two to a decoder budget. -/
theorem afterRoot_query_bound (decoder : Decoder cols Output) {q : ℕ}
    (bounded : ∀ view, IsQueryBoundP (decoder view) publicOnly q)
    (credentialBytes ciphertext : Bytes) (operatorRoot : TCB.Hash32) :
    IsQueryBoundP (afterRoot decoder credentialBytes ciphertext operatorRoot) publicOnly (q + 2) := by
  have first : q + 2 - 1 = q + 1 := by omega
  have second : q + 1 - 1 = q := by omega
  simp only [afterRoot, isQueryBoundP_query_bind_iff, publicOnly,
    not_true_eq_false, false_or, ite_true, first, second]
  exact ⟨by omega, fun credential => ⟨by omega, fun ciphertextDigest => bounded _⟩⟩

/-- Sampling and the single private derivation do not spend the public budget,
even when the honest wrapper chooses a key-dependent public continuation. -/
theorem gameWithKey_query_bound (decoderFor : Bits cols → Decoder cols Output) {q : ℕ}
    (bounded : ∀ key view, IsQueryBoundP (decoderFor key view) publicOnly q)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) :
    IsQueryBoundP (gameWithKey decoderFor base A d a) publicQuery (q + 2) := by
  have sampling : IsQueryBoundP
      (liftM ($ᵗ (Bits cols)) : OracleComp NativeSpec (Bits cols)) publicQuery 0 :=
    isQueryBoundP_liftM_withDerivations (fun _ => by simp [publicQuery]) _
  unfold gameWithKey
  rw [← Nat.zero_add (q + 2)]
  apply isQueryBoundP_bind (n := 0) (m := q + 2) sampling
  intro message _
  rw [← Nat.zero_add (q + 2)]
  apply isQueryBoundP_bind (n := 0) (m := q + 2) sampling
  intro key _
  rw [isQueryBoundP_query_bind_iff]
  refine ⟨Or.inl (by simp [publicQuery]), ?_⟩
  intro operatorRoot
  change IsQueryBoundP
    (do let result ← liftPublic (afterRoot (decoderFor key) (NativeRelation.credentialBytes base)
          (ciphertextBytes A d a key message) operatorRoot)
        pure (message, result)) publicQuery (q + 2)
  have lifted := liftPublic_query_bound _ (afterRoot_query_bound (decoderFor key) (bounded key)
    (NativeRelation.credentialBytes base) (ciphertextBytes A d a key message) operatorRoot)
  simpa only [bind_pure_comp, isQueryBoundP_map_iff] using lifted

/-- Sampling and the single private derivation do not spend the public budget. -/
theorem game_query_bound (decoder : Decoder cols Output) {q : ℕ}
    (bounded : ∀ view, IsQueryBoundP (decoder view) publicOnly q)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) :
    IsQueryBoundP (game decoder base A d a) publicQuery (q + 2) :=
  gameWithKey_query_bound (fun _ => decoder) (fun _ => bounded) base A d a

/-- Public-only execution forgets the separate ideal derivation table exactly. -/
theorem ideal_liftPublic_run' (program : OracleComp PublicSpec Output)
    (state : SecretEncoding.SplitCache publicOracle Storage.CoupledCodec.Packet TCB.Hash32) :
    (simulateQ (SecretEncoding.idealImpl publicOracle Storage.CoupledCodec.Packet TCB.Hash32)
        (liftPublic program)).run' state =
      (simulateQ publicOracle.romImpl program).run' state.1 := by
  unfold liftPublic
  rw [← QueryImpl.simulateQ_compose]
  apply OracleComp.run'_simulateQ_eq_of_query_map_eq _ _ Prod.fst
  intro query st
  cases query with
  | inl n =>
    simp [QueryImpl.apply_compose, OracleSpec.withDerivationsLift,
      SecretEncoding.idealImpl, OracleSpec.romImpl, unifFwdImpl, Functor.map_map, Prod.map]
  | inr bytes =>
    simp [QueryImpl.apply_compose, OracleSpec.withDerivationsLift,
      SecretEncoding.idealImpl, OracleSpec.romImpl, Functor.map_map, Prod.map]

/-- A single first derivation in the ideal world is an independent uniform
root, including when the later public continuation is chosen using the key. -/
theorem ideal_gameWithKey_run' (decoderFor : Bits cols → Decoder cols Output)
    (base : NativeRelation.Witness rows cols)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) :
    (simulateQ (SecretEncoding.idealImpl publicOracle Storage.CoupledCodec.Packet TCB.Hash32)
        (gameWithKey decoderFor base A d a)).run' (∅, ∅) =
      (do
        let message ← $ᵗ (Bits cols)
        let key ← $ᵗ (Bits cols)
        let operatorRoot ← $ᵗ TCB.Hash32
        let result ← (simulateQ publicOracle.romImpl
          (afterRoot (decoderFor key) (NativeRelation.credentialBytes base)
            (ciphertextBytes A d a key message) operatorRoot)).run' ∅
        pure (message, result)) := by
  simp only [gameWithKey, simulateQ_bind, StateT.run'_eq, StateT.run_bind,
    map_bind, bind_pure_comp]
  rw [SecretEncoding.run_simulateQ_idealImpl_liftM]
  simp only [bind_map_left]
  congr 1
  funext message
  rw [SecretEncoding.run_simulateQ_idealImpl_liftM]
  simp only [bind_map_left]
  congr 1
  funext key
  simp only [simulateQ_query, OracleQuery.input_query, OracleQuery.cont_query, id_map]
  rw [SecretEncoding.idealImpl_run_derive_none (by simp)]
  simp only [bind_map_left, Functor.map_map]
  congr 1
  funext operatorRoot
  have projection := ideal_liftPublic_run'
    (afterRoot (decoderFor key) (NativeRelation.credentialBytes base)
      (ciphertextBytes A d a key message) operatorRoot)
    (∅, (∅ : (Storage.CoupledCodec.Packet →ₒ TCB.Hash32).QueryCache).cacheQuery
      (Storage.CoupledCodec.ofMatrix (presentation A key)) operatorRoot)
  simpa only [StateT.run'_eq, simulateQ_map, StateT.run_map, Functor.map_map,
    Function.comp_def] using
    congrArg (fun program => (fun result => (message, result)) <$> program) projection

/-- The independent ideal root law for the original native experiment. -/
theorem ideal_game_run' (decoder : Decoder cols Output) (base : NativeRelation.Witness rows cols)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) :
    (simulateQ (SecretEncoding.idealImpl publicOracle Storage.CoupledCodec.Packet TCB.Hash32)
        (game decoder base A d a)).run' (∅, ∅) =
      (do
        let message ← $ᵗ (Bits cols)
        let key ← $ᵗ (Bits cols)
        let operatorRoot ← $ᵗ TCB.Hash32
        let result ← (simulateQ publicOracle.romImpl
          (afterRoot decoder (NativeRelation.credentialBytes base)
            (ciphertextBytes A d a key message) operatorRoot)).run' ∅
        pure (message, result)) :=
  ideal_gameWithKey_run' (fun _ => decoder) base A d a

/-- The ideal decoder's complete output, generated independently of the target
message after reindexing the original sign key by its mask. -/
def idealGuess (decoder : Decoder cols Output) (base : NativeRelation.Witness rows cols)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) : ProbComp Output := do
  let masked ← $ᵗ (Bits cols)
  let operatorRoot ← $ᵗ TCB.Hash32
  (simulateQ publicOracle.romImpl
    (afterRoot decoder (NativeRelation.credentialBytes base)
      (normalBytes A d a masked) operatorRoot)).run' ∅

/-- The genuine ideal byte-oracle experiment factors the original uniform
message from the entire adaptive decoder execution. -/
theorem ideal_game_independent (decoder : Decoder cols Output)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ)) :
    (simulateQ (SecretEncoding.idealImpl publicOracle Storage.CoupledCodec.Packet TCB.Hash32)
        (game decoder base A d a)).run' (∅, ∅) =ᵈ
      (do let message ← $ᵗ (Bits cols)
          let result ← idealGuess decoder base A d a
          pure (message, result)) := by
  rw [ideal_game_run']
  simp only [idealGuess, bind_assoc]
  apply EvalDistEq.bind_right ($ᵗ (Bits cols))
  intro message
  simp_rw [ciphertextBytes_normal A d a orthogonal]
  exact uniform_mask_bind message (fun masked => do
    let operatorRoot ← $ᵗ TCB.Hash32
    let result ← (simulateQ publicOracle.romImpl
      (afterRoot decoder (NativeRelation.credentialBytes base)
        (normalBytes A d a masked) operatorRoot)).run' ∅
    pure (message, result))

/-- Every complete-message oracle decoder has exactly inverse-cardinality
success in the independent-root game. Its adaptive public queries are retained. -/
theorem ideal_recovery_probability (decoder : Decoder cols (Bits cols))
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ)) :
    idealProbability (game decoder base A d a) (fun outcome => outcome.2 = outcome.1) =
      (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols := by
  have independent := (ideal_game_independent decoder base A d a orthogonal).prEvent_eq
    (fun outcome => outcome.2 = outcome.1)
  calc
    _ = Pr{let outcome ←
        (simulateQ (SecretEncoding.idealImpl publicOracle Storage.CoupledCodec.Packet TCB.Hash32)
          (game decoder base A d a)).run' (∅, ∅)}[outcome.2 = outcome.1] := by
      simp only [idealProbability, StateT.run'_eq, prEvent_map]
    _ = Pr{let message ← $ᵗ (Bits cols); let result ← idealGuess decoder base A d a}[
        result = message] := by
      simpa only [map_bind, map_pure, bind_pure_comp, bind_map_left,
        Functor.map_map, Function.comp_def] using independent
    _ = _ := uniform_guess_probability _

/-- Actual canonical V2 instance/ciphertext recovery in the shared byte ROM
has only the explicit nonce-guessing loss. The two extra calls are the honest
source-credential and full-ciphertext digest queries. -/
theorem recovery_probability_le (decoder : Decoder cols (Bits cols)) {q : ℕ}
    (bounded : ∀ view, IsQueryBoundP (decoder view) publicOnly q)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ)) :
    realProbability (game decoder base A d a) (fun outcome => outcome.2 = outcome.1) ≤
      (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols +
        ((q + 2 : ℕ) : ℝ≥0∞) * ((256 ^ 32 : ℕ) : ℝ≥0∞)⁻¹ := by
  have bound := event_probability_le (game_query_bound decoder bounded base A d a)
    (fun outcome => outcome.2 = outcome.1)
  rwa [ideal_recovery_probability decoder base A d a orthogonal] at bound

/-- The same ideal execution bounds an arbitrary partial extractor of the
original integer harmonic coefficients, including failure and invalid outputs. -/
theorem ideal_partial_coeff_probability_le
    (decoder : Decoder cols (Option (Fin cols → ℤ)))
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) :
    idealProbability (game decoder base A d a)
        (fun outcome => outcome.2 = some (coefficients d outcome.1)) ≤
      (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols := by
  have independent := (ideal_game_independent decoder base A d a orthogonal).prEvent_eq
    (fun outcome => outcome.2 = some (coefficients d outcome.1))
  calc
    _ = Pr{let outcome ←
        (simulateQ (SecretEncoding.idealImpl publicOracle Storage.CoupledCodec.Packet TCB.Hash32)
          (game decoder base A d a)).run' (∅, ∅)}[
            outcome.2 = some (coefficients d outcome.1)] := by
      simp only [idealProbability, StateT.run'_eq, prEvent_map]
    _ = Pr{let message ← $ᵗ (Bits cols); let result ← idealGuess decoder base A d a}[
        result = some (coefficients d message)] := by
      simpa only [map_bind, map_pure, bind_pure_comp, bind_map_left,
        Functor.map_map, Function.comp_def] using independent
    _ ≤ _ := uniform_partial_coeff_probability d positive _

/-- Query-bounded recovery of the actual native integer coefficients has the
same nonce loss, on the same game and shared oracle as the bit-vector theorem. -/
theorem partial_coeff_recovery_probability_le
    (decoder : Decoder cols (Option (Fin cols → ℤ))) {q : ℕ}
    (bounded : ∀ view, IsQueryBoundP (decoder view) publicOnly q)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) :
    realProbability (game decoder base A d a)
        (fun outcome => outcome.2 = some (coefficients d outcome.1)) ≤
      (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols +
        ((q + 2 : ℕ) : ℝ≥0∞) * ((256 ^ 32 : ℕ) : ℝ≥0∞)⁻¹ := by
  exact (event_probability_le (game_query_bound decoder bounded base A d a)
    (fun outcome => outcome.2 = some (coefficients d outcome.1))).trans
      (add_le_add (ideal_partial_coeff_probability_le decoder base A d a orthogonal positive) le_rfl)

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRandomOracle
