module

public import Protocol.Transfer.PathSignature.NativeCommittedRandomOracle.Disclosure

@[expose] public section

/-!
# Public continuations of the native byte-oracle experiment

A public suffix can resume from the exact cache left by a native prefix.
Lifting a public oracle program into the real handler gives the original
public-oracle execution, for every nonce seed and starting cache. Factoring
the recovery event therefore preserves its hidden target and live cache.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRandomOracle

open OracleSpec OracleComp NativeSignSampler
open Storage.OperatorCommitment.RandomOracle

variable {α β γ : Type} {rows cols : ℕ}

/-- Keep the complete output of the real native prefix and its shared cache. -/
def realPrefix (program : OracleComp NativeSpec α) :
    ProbComp (α × publicOracle.QueryCache) := do
  let seed ← $ᵗ Seed
  (simulateQ (encoding.realImpl seed) program).run ∅

/-- Continue a public program with the cache already reached by the prefix. -/
def resumePublic (program : OracleComp PublicSpec α) (cache : publicOracle.QueryCache) :
    ProbComp α :=
  (simulateQ publicOracle.romImpl program).run' cache

private theorem real_liftPublic_run' (program : OracleComp PublicSpec α)
    (seed : Seed) (cache : publicOracle.QueryCache) :
    (simulateQ (encoding.realImpl seed) (liftPublic program)).run' cache =
      resumePublic program cache := by
  unfold liftPublic resumePublic
  rw [SecretEncoding.realImpl, QueryImpl.simulateQ_compose,
    ← QueryImpl.simulateQ_compose (encoding.deriveImpl seed),
    SecretEncoding.deriveImpl_comp_withDerivationsLift, simulateQ_id']

/-- Splitting the real execution immediately before a public suffix preserves
the event probability with the original target and exact shared cache. -/
theorem realProbability_continue (beginProgram : OracleComp NativeSpec α)
    (next : α → OracleComp PublicSpec β) (project : α → γ) (event : γ × β → Prop) :
    realProbability
      (do let sampled ← beginProgram
          let output ← liftPublic (next sampled)
          pure (project sampled, output))
      event =
    Pr{let sampled ← realPrefix beginProgram
       let output ← resumePublic (next sampled.1) sampled.2}[event (project sampled.1, output)] := by
  have same :
      (do let seed ← $ᵗ Seed
          (simulateQ (encoding.realImpl seed)
            (do let sampled ← beginProgram
                let output ← liftPublic (next sampled)
                pure (project sampled, output))).run' ∅) =
      (do let sampled ← realPrefix beginProgram
          let output ← resumePublic (next sampled.1) sampled.2
          pure (project sampled.1, output)) := by
    simp only [realPrefix, bind_assoc, bind_pure_comp, simulateQ_bind, simulateQ_map,
      StateT.run'_bind', StateT.run'_map', real_liftPublic_run']
  simpa only [realProbability, StateT.run'_eq, prEvent_norm, bind_assoc] using
    (congrArg (fun program => Pr{let output ← program}[event output]) same)

/-- Appending a public continuation to the key-selected decoder is the same
native program as running it after the native prefix. The original message
passes through unchanged. -/
theorem gameWithKey_bind (decoderFor : Bits cols → Decoder cols α)
    (next : α → OracleComp PublicSpec β)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) :
    gameWithKey (fun key view => decoderFor key view >>= next) base A d a =
      (do let sampled ← gameWithKey decoderFor base A d a
          let output ← liftPublic (next sampled.2)
          pure (sampled.1, output)) := by
  simp only [gameWithKey, afterRoot, liftPublic, simulateQ_bind, bind_assoc, pure_bind]

/-- The native prefix factorization also retains the original disclosure law. -/
theorem Disclosure.game_bind {Advice : Type} (disclose : Bits cols → Advice)
    (decoder : Advice → Decoder cols α) (next : α → OracleComp PublicSpec β)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) :
    Disclosure.game disclose (fun advice view => decoder advice view >>= next) base A d a =
      (do let sampled ← Disclosure.game disclose decoder base A d a
          let output ← liftPublic (next sampled.2)
          pure (sampled.1, output)) :=
  gameWithKey_bind (fun key => decoder (disclose key)) next base A d a

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRandomOracle
