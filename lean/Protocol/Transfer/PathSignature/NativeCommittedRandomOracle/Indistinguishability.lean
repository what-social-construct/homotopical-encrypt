module

public import Protocol.Transfer.PathSignature.NativeCommittedRandomOracle

@[expose] public section

/-!
# One-use chosen-message distinguishing game for the native public view

The challenge consists of the canonical V2 instance and complete ciphertext
from one fresh sign key and one hidden commitment nonce. A decoder sees the
challenge and can make bounded adaptive public byte-oracle queries.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRandomOracle.Indistinguishability

open OracleSpec OracleComp MeasureTheory
open NativeSignSampler Storage.OperatorCommitment.RandomOracle
open scoped ENNReal

variable {rows cols : ℕ} {Output : Type}

/-- The honest wrapper chooses uniformly between the two challenge messages.
It reveals only the same native public view used in the recovery game. -/
def game (decoder : Decoder cols Output) (base : NativeRelation.Witness rows cols)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) (left right : Bits cols) :
    OracleComp NativeSpec (Bool × Output) := do
  let choice ← (liftM ($ᵗ Bool) : OracleComp NativeSpec _)
  let key ← (liftM ($ᵗ (Bits cols)) : OracleComp NativeSpec _)
  let operatorRoot ← NativeSpec.query (.inr (Storage.CoupledCodec.ofMatrix (presentation A key)))
  let result ← liftPublic (afterRoot decoder (NativeRelation.credentialBytes base)
    (ciphertextBytes A d a key (if choice then right else left)) operatorRoot)
  pure (choice, result)

theorem game_query_bound (decoder : Decoder cols Output) {q : ℕ}
    (bounded : ∀ view, IsQueryBoundP (decoder view) publicOnly q)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (left right : Bits cols) :
    IsQueryBoundP (game decoder base A d a left right) publicQuery (q + 2) := by
  have choose : IsQueryBoundP
      (liftM ($ᵗ Bool) : OracleComp NativeSpec Bool) publicQuery 0 :=
    isQueryBoundP_liftM_withDerivations (fun _ => by simp [publicQuery]) _
  have sampling : IsQueryBoundP
      (liftM ($ᵗ (Bits cols)) : OracleComp NativeSpec (Bits cols)) publicQuery 0 :=
    isQueryBoundP_liftM_withDerivations (fun _ => by simp [publicQuery]) _
  unfold game
  rw [← Nat.zero_add (q + 2)]
  apply isQueryBoundP_bind (n := 0) (m := q + 2) choose
  intro choice _
  rw [← Nat.zero_add (q + 2)]
  apply isQueryBoundP_bind (n := 0) (m := q + 2) sampling
  intro key _
  rw [isQueryBoundP_query_bind_iff]
  refine ⟨Or.inl (by simp [publicQuery]), ?_⟩
  intro operatorRoot
  change IsQueryBoundP
    (do let result ← liftPublic (afterRoot decoder (NativeRelation.credentialBytes base)
          (ciphertextBytes A d a key (if choice then right else left)) operatorRoot)
        pure (choice, result)) publicQuery (q + 2)
  have lifted := liftPublic_query_bound _ (afterRoot_query_bound decoder bounded
    (NativeRelation.credentialBytes base) (ciphertextBytes A d a key (if choice then right else left))
    operatorRoot)
  simpa only [bind_pure_comp, isQueryBoundP_map_iff] using lifted

theorem ideal_game_run' (decoder : Decoder cols Output)
    (base : NativeRelation.Witness rows cols)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) (left right : Bits cols) :
    (simulateQ (SecretEncoding.idealImpl publicOracle Storage.CoupledCodec.Packet TCB.Hash32)
        (game decoder base A d a left right)).run' (∅, ∅) =
      (do
        let choice ← $ᵗ Bool
        let key ← $ᵗ (Bits cols)
        let operatorRoot ← $ᵗ TCB.Hash32
        let result ← (simulateQ publicOracle.romImpl
          (afterRoot decoder (NativeRelation.credentialBytes base)
            (ciphertextBytes A d a key (if choice then right else left)) operatorRoot)).run' ∅
        pure (choice, result)) := by
  simp only [game, simulateQ_bind, StateT.run'_eq, StateT.run_bind,
    map_bind, bind_pure_comp]
  rw [SecretEncoding.run_simulateQ_idealImpl_liftM]
  simp only [bind_map_left]
  congr 1
  funext choice
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
    (afterRoot decoder (NativeRelation.credentialBytes base)
      (ciphertextBytes A d a key (if choice then right else left)) operatorRoot)
    (∅, (∅ : (Storage.CoupledCodec.Packet →ₒ TCB.Hash32).QueryCache).cacheQuery
      (Storage.CoupledCodec.ofMatrix (presentation A key)) operatorRoot)
  simpa only [StateT.run'_eq, simulateQ_map, StateT.run_map, Functor.map_map,
    Function.comp_def] using
    congrArg (fun program => (fun result => (choice, result)) <$> program) projection

/-- In the independent-root world the challenge bit and the complete decoder
output have independent distributions for every fixed pair of messages. -/
theorem ideal_game_independent (decoder : Decoder cols Output)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (left right : Bits cols)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ)) :
    (simulateQ (SecretEncoding.idealImpl publicOracle Storage.CoupledCodec.Packet TCB.Hash32)
        (game decoder base A d a left right)).run' (∅, ∅) =ᵈ
      (do let choice ← $ᵗ Bool
          let result ← idealGuess decoder base A d a
          pure (choice, result)) := by
  rw [ideal_game_run']
  simp only [idealGuess, bind_assoc]
  apply EvalDistEq.bind_right ($ᵗ Bool)
  intro choice
  simp_rw [ciphertextBytes_normal A d a orthogonal]
  exact uniform_mask_bind (if choice then right else left) (fun masked => do
    let operatorRoot ← $ᵗ TCB.Hash32
    let result ← (simulateQ publicOracle.romImpl
      (afterRoot decoder (NativeRelation.credentialBytes base)
        (normalBytes A d a masked) operatorRoot)).run' ∅
    pure (choice, result))

private theorem uniform_bool_guess_probability (guess : ProbComp Bool) :
    Pr{let choice ← $ᵗ Bool; let value ← guess}[value = choice] = (1 : ℝ≥0∞) / 2 := by
  rw [OracleComp.prEvent_bind_map_swap]
  let : MeasurableSpace Bool := ⊤
  change prEvent (guess >>= fun value => (fun choice => value = choice) <$> ($ᵗ Bool)) = _
  rw [prEvent_bind_of_discrete]
  simp_rw [SampleableType.prEvent_uniformSample_eq_singleton']
  rw [lintegral_const, OracleComp.evalDist_apply_univ_eq_one, mul_one]
  simp only [Fintype.card_bool, Nat.cast_ofNat, ENNReal.div_eq_inv_mul, mul_one]

theorem ideal_guess_probability (decoder : Decoder cols Bool)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (left right : Bits cols)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ)) :
    idealProbability (game decoder base A d a left right) (fun outcome => outcome.2 = outcome.1) =
      (1 : ℝ≥0∞) / 2 := by
  have independent := (ideal_game_independent decoder base A d a left right orthogonal).prEvent_eq
    (fun outcome => outcome.2 = outcome.1)
  calc
    _ = Pr{let outcome ←
        (simulateQ (SecretEncoding.idealImpl publicOracle Storage.CoupledCodec.Packet TCB.Hash32)
          (game decoder base A d a left right)).run' (∅, ∅)}[outcome.2 = outcome.1] := by
      simp only [idealProbability, StateT.run'_eq, prEvent_map]
    _ = Pr{let choice ← $ᵗ Bool; let result ← idealGuess decoder base A d a}[
        result = choice] := by
      simpa only [map_bind, map_pure, bind_pure_comp, bind_map_left,
        Functor.map_map, Function.comp_def] using independent
    _ = _ := uniform_bool_guess_probability _

/-- The excess over fair guessing for any fixed pair is at most the hidden
nonce loss, including the two honest public digest queries. -/
theorem guess_probability_le (decoder : Decoder cols Bool) {q : ℕ}
    (bounded : ∀ view, IsQueryBoundP (decoder view) publicOnly q)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (left right : Bits cols)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ)) :
    realProbability (game decoder base A d a left right) (fun outcome => outcome.2 = outcome.1) ≤
      (1 : ℝ≥0∞) / 2 +
        ((q + 2 : ℕ) : ℝ≥0∞) * ((256 ^ 32 : ℕ) : ℝ≥0∞)⁻¹ := by
  have bound := event_probability_le (game_query_bound decoder bounded base A d a left right)
    (fun outcome => outcome.2 = outcome.1)
  rwa [ideal_guess_probability decoder base A d a left right orthogonal] at bound

/-- Applying the same comparison to the complementary event bounds the
deviation in the other direction for the very same decoder. -/
theorem half_le_guess_probability_add (decoder : Decoder cols Bool) {q : ℕ}
    (bounded : ∀ view, IsQueryBoundP (decoder view) publicOnly q)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (left right : Bits cols)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ)) :
    (1 : ℝ≥0∞) / 2 ≤
      realProbability (game decoder base A d a left right) (fun outcome => outcome.2 = outcome.1) +
        ((q + 2 : ℕ) : ℝ≥0∞) * ((256 ^ 32 : ℕ) : ℝ≥0∞)⁻¹ := by
  let program := game decoder base A d a left right
  let success : Bool × Bool → Prop := fun outcome => outcome.2 = outcome.1
  have realComplement :
      realProbability program (fun outcome => ¬ success outcome) =
        1 - realProbability program success := by
    simpa only [realProbability, map_bind] using
      (OracleComp.prEvent_not_eq_one_sub
        (do let seed ← $ᵗ Seed; (simulateQ (encoding.realImpl seed) program).run ∅)
        (fun result => success result.1))
  have idealComplement :
      idealProbability program (fun outcome => ¬ success outcome) =
        1 - idealProbability program success := by
    exact OracleComp.prEvent_not_eq_one_sub _ _
  have idealHalf : idealProbability program success = (1 : ℝ≥0∞) / 2 :=
    ideal_guess_probability decoder base A d a left right orthogonal
  have comparison := event_probability_le (game_query_bound decoder bounded base A d a left right)
    (fun outcome => ¬ success outcome)
  change realProbability program _ ≤ idealProbability program _ + _ at comparison
  rw [realComplement, idealComplement, idealHalf, ENNReal.sub_half ENNReal.one_ne_top] at comparison
  have summed := tsub_le_iff_right.mp comparison
  change (1 : ℝ≥0∞) / 2 ≤ realProbability program success + _
  apply ENNReal.le_of_add_le_add_right
    (ENNReal.div_ne_top ENNReal.one_ne_top (by simp : (2 : ℝ≥0∞) ≠ 0))
  rw [ENNReal.add_halves]
  simpa only [add_assoc, add_left_comm, add_comm] using summed

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRandomOracle.Indistinguishability
