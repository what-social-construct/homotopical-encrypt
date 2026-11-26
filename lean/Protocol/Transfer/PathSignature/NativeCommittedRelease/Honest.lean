module

public import Protocol.Transfer.PathSignature.NativeCommittedRelease.HonestEvidence
public import Protocol.Transfer.PathSignature.NativeCommittedRelease.Simulation

@[expose] public section

/-!
# Honest evidence and the simulated release from a common native prefix

The honest and simulated branches use the original sampled message and sign
key, the single private nonce seed used in operator derivation, and the
original V2 instance and ciphertext. Each evidence producer starts in the
actual cache after the native name queries. The honest producer receives the
canonical private witness. Only its released evidence and public cache are
passed to the recovery continuation. The simulated producer gets the same
public arguments and the existing simulator prefix law is unchanged.

A bound on the conditional law of the release and resulting cache, for
almost every common sample, suffices for the joint-prefix premise. This
retains the recovery target and any failed releases. The honesty of a
producer describes which arguments it uses; backend evidence correctness
and the conditional simulation error are separate properties.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRelease

open OracleSpec OracleComp MeasureTheory
open NativeCommittedRandomOracle
open Storage.OperatorCommitment.RandomOracle
open scoped ENNReal

variable {Owner Advice Output : Type} {rows cols : ℕ}

/-- Private join used for comparing the two release producers. The same
cache already contains the responses for the three native public names. -/
structure BeforeRelease (cols : ℕ) where
  seed : Seed
  message : Bits cols
  key : Bits cols
  view : View
  cache : publicOracle.QueryCache

def nativePrefix (base : NativeRelation.Witness rows cols)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) : ProbComp (BeforeRelease cols) :=
  (fun sampled => ⟨sampled.1, sampled.2.1.1, sampled.2.1.2.1,
    sampled.2.1.2.2, sampled.2.2⟩) <$>
    realPrefixWithSeed (gameWithKey (fun key view => pure (key, view)) base A d a)

def honestRelease (disclose : Bits cols → Advice) (inputs : Advice → Inputs Owner)
    (produce : EvidenceProducer Owner Advice rows cols)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (sampled : BeforeRelease cols) : OracleComp PublicSpec (ReleaseView Owner Advice) :=
  let advice := disclose sampled.key
  let chosen := inputs advice
  let witness := NativeCommittedPrivacy.sampleWitness base A d a sampled.key sampled.message
    (nonceOfSeed sampled.seed)
  releaseWithEvidence chosen advice sampled.view fun publicInput =>
    produce advice witness (chosen.intentAt publicInput) (chosen.signingInputAt publicInput)
      sampled.view.2

/-- Run an evidence branch in the live cache and keep the original message
only for the success event. -/
def BeforeRelease.step (sampled : BeforeRelease cols)
    (program : OracleComp PublicSpec (ReleaseView Owner Advice)) : ProbComp (Prefix cols Owner Advice) :=
  (fun result => ((sampled.message, result.1), result.2)) <$>
    resumePublicState program sampled.cache

def honestPrefix (disclose : Bits cols → Advice) (inputs : Advice → Inputs Owner)
    (produce : EvidenceProducer Owner Advice rows cols)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) :
    ProbComp (Prefix cols Owner Advice) :=
  nativePrefix base A d a >>= fun sampled =>
    sampled.step (honestRelease disclose inputs produce base A d a sampled)

def simulatedFromNativePrefix (disclose : Bits cols → Advice) (inputs : Advice → Inputs Owner)
    (simulate : EvidenceSimulator Owner Advice)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) :
    ProbComp (Prefix cols Owner Advice) :=
  nativePrefix base A d a >>= fun sampled =>
    sampled.step (simulateRelease inputs simulate (disclose sampled.key) sampled.view)

/-- The public branch on the common prefix is the original simulated release
experiment on the same byte oracle, including the returned cache. -/
theorem simulatedFromNativePrefix_eq (disclose : Bits cols → Advice)
    (inputs : Advice → Inputs Owner) (simulate : EvidenceSimulator Owner Advice)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) :
    simulatedFromNativePrefix disclose inputs simulate base A d a =
      simulatedPrefix disclose inputs simulate base A d a := by
  unfold simulatedFromNativePrefix nativePrefix
  simp only [bind_map_left, BeforeRelease.step]
  rw [realPrefixWithSeed_bind_ignore
    (gameWithKey (fun key view => pure (key, view)) base A d a) (fun sampled =>
    (fun result => ((sampled.1.1, result.1), result.2)) <$>
      resumePublicState
        (simulateRelease inputs simulate (disclose sampled.1.2.1) sampled.1.2.2) sampled.2)]
  unfold simulatedPrefix
  let next : Bits cols × View → OracleComp PublicSpec (ReleaseView Owner Advice) :=
    fun pair => simulateRelease inputs simulate (disclose pair.1) pair.2
  have split := gameWithKey_bind (fun key view => pure (key, view)) next base A d a
  simp only [next, pure_bind] at split
  change Disclosure.game disclose (simulateRelease inputs simulate) base A d a = _ at split
  rw [split, realPrefix_continue]

/-- Conditional comparison on the actual shared setup. The distance includes
the resulting cache, not just the marginal law of the evidence bytes. -/
def LocalSimulation (disclose : Bits cols → Advice) (inputs : Advice → Inputs Owner)
    (produce : EvidenceProducer Owner Advice rows cols) (simulate : EvidenceSimulator Owner Advice)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (ε : ℝ≥0∞) : Prop :=
  letI : MeasurableSpace (BeforeRelease cols) := ⊤
  letI : MeasurableSpace (Prefix cols Owner Advice) := ⊤
  ∀ᵐ sampled ∂𝒟[nativePrefix base A d a],
    measureETVDist
      (sampled.step (honestRelease disclose inputs produce base A d a sampled))
      (sampled.step (simulateRelease inputs simulate (disclose sampled.key) sampled.view)) ≤ ε

theorem honestPrefix_distance_le (disclose : Bits cols → Advice) (inputs : Advice → Inputs Owner)
    (produce : EvidenceProducer Owner Advice rows cols) (simulate : EvidenceSimulator Owner Advice)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    {ε : ℝ≥0∞} (simulation : LocalSimulation disclose inputs produce simulate base A d a ε) :
    prefixDistance (honestPrefix disclose inputs produce base A d a)
      (simulatedPrefix disclose inputs simulate base A d a) ≤ ε := by
  let : MeasurableSpace (BeforeRelease cols) := ⊤
  let : MeasurableSpace (Prefix cols Owner Advice) := ⊤
  rw [← simulatedFromNativePrefix_eq]
  change measureETVDist _ _ ≤ ε
  calc
    _ ≤ ∫⁻ _sampled, ε ∂𝒟[nativePrefix base A d a] :=
      measureETVDist_bind_bind_le_lintegral (nativePrefix base A d a) _ _
        Measurable.of_discrete Measurable.of_discrete (fun _ => ε) simulation
    _ = ε * 𝒟[nativePrefix base A d a] Set.univ := lintegral_const ε
    _ ≤ ε := mul_le_of_le_one_right' (evalDist_apply_univ_le_one _)

/-- For the concrete honest prefix, the remaining simulation obligation is
the conditional release-and-cache law of the two selected producers. -/
theorem honest_recovery_probability_le
    (disclose : Bits cols → Advice) (inputs : Advice → Inputs Owner)
    (produce : EvidenceProducer Owner Advice rows cols) (simulate : EvidenceSimulator Owner Advice)
    (adversary : ReleaseView Owner Advice → OracleComp PublicSpec Output)
    {s q : ℕ}
    (simulatorBound : ∀ advice intent signing ciphertext,
      IsQueryBoundP (simulate advice intent signing ciphertext) publicOnly s)
    (adversaryBound : ∀ view, IsQueryBoundP (adversary view) publicOnly q)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (target : Bits cols → Output) (injective : Function.Injective target) {ε : ℝ≥0∞}
    (simulation : LocalSimulation disclose inputs produce simulate base A d a ε) :
    recoveryFromPrefix (honestPrefix disclose inputs produce base A d a) adversary target ≤
      ((HCP.FiniteRecovery.disclosedViews disclose).card : ℝ≥0∞) / (2 : ℝ≥0∞)^cols +
        ((s + q + 2 : ℕ) : ℝ≥0∞) * ((256 ^ 32 : ℕ) : ℝ≥0∞)⁻¹ + ε :=
  recovery_probability_le_of_joint_prefix (honestPrefix disclose inputs produce base A d a)
    disclose inputs simulate adversary simulatorBound adversaryBound base A d a orthogonal
    target injective (honestPrefix_distance_le disclose inputs produce simulate base A d a simulation)

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRelease
