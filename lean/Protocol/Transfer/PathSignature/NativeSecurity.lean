module

public import Protocol.Transfer.PathSignature.CRS
public import Protocol.Transfer.PathSignature.NativeProgram

@[expose] public section

/-!
# The sampled CRS reduction on the actual native HCP relation

The native specialization constructs each sampled public key and private
witness from the same bounded native challenge. The generic adapter preserves
the declared auxiliary input. The preferred `fullViewExperiment` instead
constructs its first auxiliary component as the actual canonical full target
ciphertext, retaining the declared remainder. Adaptive adversary execution,
setup/proof randomness and the PMF remain those of the original experiment.
Honest native validity is proved from the concrete checker, rather than
supplied as a free witness-reflection premise.

The reduction reads the actual simulated target and extractor output, checks
those bytes with the same relation, decodes them and returns their integer
coefficients. This algorithm does not read the experiment's private witness
field or the challenge's private presentations. Recovery and collision events
assess that same decoded output. Valid extracted bytes yield the original
coefficients or an actual target-snapshot/ciphertext byte-hash collision.

The real-forgery bound retains the CRS transcript hybrid, extraction failure,
native target recovery and the two collision probabilities on one PMF. No
numerical bound, efficient-adversary class or asymptotic hardness estimate is
asserted. The preferred public view includes a salted source credential, a
target snapshot commitment, a ciphertext digest, the original full ciphertext
and the declared auxiliary remainder. These additional public commitments
mean that hardness for this view is not implied by the earlier `(public
class,b)` HCP obstruction or the explicit-lattice CVP comparison.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeSecurity

open Sheaf CellularSheaf HCPCoupledFamily
open Storage.CoupledCodec
open scoped ENNReal

variable {Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins : Type}

/-- Specialize the actual generated experiment, preserving its adversary,
auxiliary input and random tapes. No independent signing history is supplied. -/
def nativeExperiment
    (template : CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) :
    CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins :=
  { template with
    relation := NativeProgram.relation program hash
    key := fun coin => NativeProgram.encodeInstance (NativeRelation.instanceFor hash (challenge coin))
    witness := fun coin => NativeRelation.encode (challenge coin) }

/-- Construct public access to the actual native ciphertext rather than
requiring a caller to assert that an arbitrary auxiliary field contains it.
The remaining auxiliary data and every other experiment field are retained. -/
def withCiphertextView {rows cols : ℕ}
    (template : CRS.Experiment Seed Reference Trapdoor Randomness (Bytes × Aux) AdversaryCoins Coins)
    (challenge : Coins → NativeRelation.Witness rows cols) :
    CRS.Experiment Seed Reference Trapdoor Randomness (Bytes × Aux) AdversaryCoins Coins :=
  { template with
    auxiliary := fun coin =>
      (Storage.CoupledCiphertext.sampleBytes (challenge coin).target
        (challenge coin).z (challenge coin).a (challenge coin).u,
        (template.auxiliary coin).2) }

theorem withCiphertextView_preserves_key_witness {rows cols : ℕ}
    (template : CRS.Experiment Seed Reference Trapdoor Randomness (Bytes × Aux) AdversaryCoins Coins)
    (challenge : Coins → NativeRelation.Witness rows cols) :
    (withCiphertextView template challenge).key = template.key ∧
      (withCiphertextView template challenge).witness = template.witness := ⟨rfl, rfl⟩

/-- Preferred native experiment with the actual full ciphertext supplied to
the adversary through its public auxiliary input. -/
def fullViewExperiment
    (template : CRS.Experiment Seed Reference Trapdoor Randomness (Bytes × Aux) AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) :
    CRS.Experiment Seed Reference Trapdoor Randomness (Bytes × Aux) AdversaryCoins Coins :=
  nativeExperiment (withCiphertextView template challenge) program hash challenge

/-- The exact first auxiliary field passed to the actual adversary is the
canonical original target ciphertext; it is not a digest-only view. -/
theorem fullView_ciphertext
    (template : CRS.Experiment Seed Reference Trapdoor Randomness (Bytes × Aux) AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) (coin : Coins) :
    ((fullViewExperiment template program hash challenge).auxiliary coin).1 =
      Storage.CoupledCiphertext.sampleBytes (challenge coin).target
        (challenge coin).z (challenge coin).a (challenge coin).u := rfl

theorem fullView_auxiliary_remainder
    (template : CRS.Experiment Seed Reference Trapdoor Randomness (Bytes × Aux) AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) (coin : Coins) :
    ((fullViewExperiment template program hash challenge).auxiliary coin).2 =
      (template.auxiliary coin).2 := rfl

/-- Full-ciphertext release changes neither the adaptive adversary nor its
setup/randomness law. Only the native relation/key/witness and public first
auxiliary component are replaced. -/
theorem fullView_preserves_execution
    (template : CRS.Experiment Seed Reference Trapdoor Randomness (Bytes × Aux) AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) :
    (fullViewExperiment template program hash challenge).primitive = template.primitive ∧
      (fullViewExperiment template program hash challenge).coins = template.coins ∧
      (fullViewExperiment template program hash challenge).fuel = template.fuel ∧
      (fullViewExperiment template program hash challenge).setupSeed = template.setupSeed ∧
      (fullViewExperiment template program hash challenge).proofRandomness = template.proofRandomness ∧
      (fullViewExperiment template program hash challenge).adversaryRandomness = template.adversaryRandomness ∧
      (fullViewExperiment template program hash challenge).adversary = template.adversary :=
  ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem fullView_native_fields
    (template : CRS.Experiment Seed Reference Trapdoor Randomness (Bytes × Aux) AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) :
    (fullViewExperiment template program hash challenge).relation = NativeProgram.relation program hash ∧
      (fullViewExperiment template program hash challenge).key =
        (fun coin => NativeProgram.encodeInstance (NativeRelation.instanceFor hash (challenge coin))) ∧
      (fullViewExperiment template program hash challenge).witness =
        (fun coin => NativeRelation.encode (challenge coin)) := ⟨rfl, rfl, rfl⟩

theorem specialize_coins
    (template : CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) :
    (nativeExperiment template program hash challenge).coins = template.coins := rfl

/-- Field equations keep the exact selected native algorithms opaque while
rewriting an experiment, avoiding expansion of their arithmetic implementations. -/
theorem nativeExperiment_relation
    (template : CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) :
    (nativeExperiment template program hash challenge).relation = NativeProgram.relation program hash := rfl

theorem nativeExperiment_key
    (template : CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) :
    (nativeExperiment template program hash challenge).key =
      (fun coin => NativeProgram.encodeInstance (NativeRelation.instanceFor hash (challenge coin))) := rfl

theorem nativeExperiment_witness
    (template : CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) :
    (nativeExperiment template program hash challenge).witness =
      (fun coin => NativeRelation.encode (challenge coin)) := rfl

/-- The private bytes actually supplied to the honest prover satisfy the
actual native checker for every queried message under the bounded sampler. -/
theorem honest_witness_valid
    (template : CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols)
    (bounded : ∀ coin, NativeRelation.Bounded program.profile (challenge coin))
    (coin : Coins) (message : Bytes) :
    (nativeExperiment template program hash challenge).relation
      (Codec.encode ((nativeExperiment template program hash challenge).key coin) message)
      ((nativeExperiment template program hash challenge).witness coin) = true := by
  rw [nativeExperiment_relation, nativeExperiment_key, nativeExperiment_witness]
  rw [NativeProgram.relation_canonical]
  exact NativeRelation.check_encode program.profile hash (challenge coin) (bounded coin)

/-- The existing CRS completeness contract applies to every answer generated
by this actual native signing oracle. -/
theorem real_oracle_verified
    (template : CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols)
    (bounded : ∀ coin, NativeRelation.Bounded program.profile (challenge coin))
    (correct : CRS.Correct template.primitive (NativeProgram.relation program hash))
    (coin : Coins) (index : ℕ) (message : Bytes) :
    template.primitive.verify (template.primitive.setup (template.setupSeed coin))
      (Codec.encode ((nativeExperiment template program hash challenge).key coin) message)
      ((nativeExperiment template program hash challenge).realOracle coin index message) = true :=
  CRS.Experiment.real_oracle_verified (nativeExperiment template program hash challenge) correct
    (honest_witness_valid template program hash challenge bounded) coin index message

/-- The output algorithm uses only the generated simulated transcript and
actual extractor bytes. Relation checking precedes private-witness decoding. -/
def extractedWitness (program : NativeProgram.Program)
    (experiment : CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)
    (coin : Coins) : Option (NativeRelation.Witness program.rows program.cols) :=
  match (experiment.simulatedTranscript coin).execution.output with
  | none => none
  | some target =>
    match experiment.extracted coin target with
    | none => none
    | some bytes =>
      if experiment.relation (Codec.encode (experiment.key coin) target.message) bytes = true then
        NativeRelation.decode program.rows program.cols bytes
      else none

def recoverCoefficients (program : NativeProgram.Program)
    (experiment : CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)
    (coin : Coins) : Option (Fin program.cols → ℤ) :=
  (extractedWitness program experiment coin).map NativeRelation.Witness.z

/-- Target recovery assesses the actual output algorithm; the original
coefficients are used only in the event's success condition. -/
def TargetRecovery
    (template : CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) (coin : Coins) : Prop :=
  recoverCoefficients program (nativeExperiment template program hash challenge) coin = some (challenge coin).z

def SnapshotCollision
    (template : CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) (coin : Coins) : Prop :=
  ∃ witness, extractedWitness program (nativeExperiment template program hash challenge) coin = some witness ∧
    Storage.CoupledCodec.encode (ofMatrix witness.target) ≠
        Storage.CoupledCodec.encode (ofMatrix (challenge coin).target) ∧
      hash (Storage.CoupledCodec.encode (ofMatrix witness.target)) =
        hash (Storage.CoupledCodec.encode (ofMatrix (challenge coin).target))

def CiphertextCollision
    (template : CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) (coin : Coins) : Prop :=
  ∃ witness, extractedWitness program (nativeExperiment template program hash challenge) coin = some witness ∧
    Storage.CoupledCiphertext.sampleBytes witness.target witness.z witness.a witness.u ≠
        Storage.CoupledCiphertext.sampleBytes (challenge coin).target (challenge coin).z
          (challenge coin).a (challenge coin).u ∧
      hash (Storage.CoupledCiphertext.sampleBytes witness.target witness.z witness.a witness.u) =
        hash (Storage.CoupledCiphertext.sampleBytes (challenge coin).target (challenge coin).z
          (challenge coin).a (challenge coin).u)

/-- The generic extractor's valid native bytes lead to the actual original
coefficient output or one of two concrete collisions from that same output. -/
theorem witness_recovery_implies_cases
    (template : CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) (coin : Coins)
    (recovery : (nativeExperiment template program hash challenge).WitnessRecovery coin) :
    TargetRecovery template program hash challenge coin ∨
      SnapshotCollision template program hash challenge coin ∨
      CiphertextCollision template program hash challenge coin := by
  obtain ⟨target, witnessBytes, returned, extracted, accepted⟩ := recovery
  have nativeAccepted := accepted
  rw [nativeExperiment_relation, nativeExperiment_key] at nativeAccepted
  obtain ⟨witness, decoded, outcome⟩ := NativeProgram.extracted_target_or_collisions
    program hash (NativeRelation.instanceFor hash (challenge coin)) target.message witnessBytes
    nativeAccepted (challenge coin).target (challenge coin).z (challenge coin).a (challenge coin).u
      rfl rfl
  have recovered : extractedWitness program (nativeExperiment template program hash challenge) coin =
      some witness := by
    simp only [extractedWitness, returned, extracted, accepted, ite_true, decoded]
  rcases outcome with correct | snapshotCollision | ciphertextCollision
  · apply Or.inl
    unfold TargetRecovery recoverCoefficients
    rw [recovered]
    simpa only [Option.map_some] using congrArg some correct
  · exact Or.inr (Or.inl ⟨witness, recovered, snapshotCollision⟩)
  · exact Or.inr (Or.inr ⟨witness, recovered, ciphertextCollision⟩)

/-- Interpreting a successfully recovered original coefficient vector with its
operative geometry yields the original HCP harmonic target. The recovery
algorithm itself does not take that private geometry as an input. -/
theorem recovered_coefficients_interpret_operative_target
    (template : CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) (coin : Coins)
    (recovered : TargetRecovery template program hash challenge coin) :
    (recoverCoefficients program (nativeExperiment template program hash challenge) coin).map
        (fun z => graphVector (challenge coin).target (fun col => (z col : ℝ))) =
      some (HCP.operativeHarmonicComponent
        (Sheaf.HCPCoupledFamily.laplacianMatrix (challenge coin).target)
        (HCPCoupledEncoding.sample (challenge coin).target (challenge coin).z
          (challenge coin).a (challenge coin).u).observed) := by
  rw [recovered, Option.map_some, NativeRelation.operative_target]

noncomputable section

def targetRecoveryProbability
    (template : CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) : ℝ≥0∞ :=
  template.coins.toOuterMeasure {coin | TargetRecovery template program hash challenge coin}

def snapshotCollisionProbability
    (template : CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) : ℝ≥0∞ :=
  template.coins.toOuterMeasure {coin | SnapshotCollision template program hash challenge coin}

def ciphertextCollisionProbability
    (template : CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) : ℝ≥0∞ :=
  template.coins.toOuterMeasure {coin | CiphertextCollision template program hash challenge coin}

theorem witness_recovery_probability_le
    (template : CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) :
    (nativeExperiment template program hash challenge).witnessRecoveryProbability ≤
      targetRecoveryProbability template program hash challenge +
        snapshotCollisionProbability template program hash challenge +
        ciphertextCollisionProbability template program hash challenge := by
  let target : Set Coins := {coin | TargetRecovery template program hash challenge coin}
  let snapshot : Set Coins := {coin | SnapshotCollision template program hash challenge coin}
  let ciphertext : Set Coins := {coin | CiphertextCollision template program hash challenge coin}
  have included : {coin | (nativeExperiment template program hash challenge).WitnessRecovery coin} ⊆
      target ∪ snapshot ∪ ciphertext := by
    intro coin recovered
    rcases witness_recovery_implies_cases template program hash challenge coin recovered with
      correct | snapshotCollision | ciphertextCollision
    · exact Or.inl (Or.inl correct)
    · exact Or.inl (Or.inr snapshotCollision)
    · exact Or.inr ciphertextCollision
  change template.coins.toOuterMeasure {coin | (nativeExperiment template program hash challenge).WitnessRecovery coin} ≤
    template.coins.toOuterMeasure target + template.coins.toOuterMeasure snapshot +
      template.coins.toOuterMeasure ciphertext
  calc
    _ ≤ template.coins.toOuterMeasure (target ∪ snapshot ∪ ciphertext) :=
      MeasureTheory.measure_mono included
    _ ≤ template.coins.toOuterMeasure (target ∪ snapshot) + template.coins.toOuterMeasure ciphertext :=
      MeasureTheory.measure_union_le _ _
    _ ≤ _ := add_le_add (MeasureTheory.measure_union_le target snapshot) le_rfl

/-- The actual bounded adaptive real forgery event reduces to native target
recovery or explicit hybrid, extraction and byte-collision failures. No bound
on those five terms is obtained from the earlier exact ambiguity theorem. -/
theorem real_forgery_probability_le_of_winning_hybrid
    (template : CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols)
    {hybridError : ℝ≥0∞}
    (hybrid : (nativeExperiment template program hash challenge).WinningHybrid hybridError) :
    (nativeExperiment template program hash challenge).realForgeryProbability ≤ hybridError +
      (nativeExperiment template program hash challenge).extractionFailureProbability +
      targetRecoveryProbability template program hash challenge +
      snapshotCollisionProbability template program hash challenge +
      ciphertextCollisionProbability template program hash challenge := by
  have generic := CRS.Experiment.realForgeryProbability_le_of_winning_hybrid
    (nativeExperiment template program hash challenge) hybrid
  have native := witness_recovery_probability_le template program hash challenge
  calc
    _ ≤ hybridError + (nativeExperiment template program hash challenge).extractionFailureProbability +
        (nativeExperiment template program hash challenge).witnessRecoveryProbability := generic
    _ ≤ hybridError + (nativeExperiment template program hash challenge).extractionFailureProbability +
        (targetRecoveryProbability template program hash challenge +
          snapshotCollisionProbability template program hash challenge +
          ciphertextCollisionProbability template program hash challenge) := add_le_add le_rfl native
    _ = _ := by ac_rfl

/-- The stronger all-events distance bound is an optional sufficient corollary. -/
theorem real_forgery_probability_le
    (template : CRS.Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols)
    {hybridError : ℝ≥0∞}
    (hybrid : Owned.EventBound
      (nativeExperiment template program hash challenge).realDistribution
      (nativeExperiment template program hash challenge).simulatedDistribution hybridError) :
    (nativeExperiment template program hash challenge).realForgeryProbability ≤ hybridError +
      (nativeExperiment template program hash challenge).extractionFailureProbability +
      targetRecoveryProbability template program hash challenge +
      snapshotCollisionProbability template program hash challenge +
      ciphertextCollisionProbability template program hash challenge :=
  real_forgery_probability_le_of_winning_hybrid template program hash challenge
    (hybrid {transcript | CRS.Wins template.primitive transcript}).1

/-- The same five-term reduction applies to the preferred experiment whose
adversary is actually given the canonical full ciphertext at every sample. -/
theorem fullView_real_forgery_probability_le_of_winning_hybrid
    (template : CRS.Experiment Seed Reference Trapdoor Randomness (Bytes × Aux) AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols)
    {hybridError : ℝ≥0∞}
    (hybrid : (fullViewExperiment template program hash challenge).WinningHybrid hybridError) :
    (fullViewExperiment template program hash challenge).realForgeryProbability ≤ hybridError +
      (fullViewExperiment template program hash challenge).extractionFailureProbability +
      targetRecoveryProbability (withCiphertextView template challenge) program hash challenge +
      snapshotCollisionProbability (withCiphertextView template challenge) program hash challenge +
      ciphertextCollisionProbability (withCiphertextView template challenge) program hash challenge :=
  real_forgery_probability_le_of_winning_hybrid (withCiphertextView template challenge) program hash challenge hybrid


/-- All-events statistical closeness also suffices for the full-view reduction. -/
theorem fullView_real_forgery_probability_le
    (template : CRS.Experiment Seed Reference Trapdoor Randomness (Bytes × Aux) AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols)
    {hybridError : ℝ≥0∞}
    (hybrid : Owned.EventBound
      (fullViewExperiment template program hash challenge).realDistribution
      (fullViewExperiment template program hash challenge).simulatedDistribution hybridError) :
    (fullViewExperiment template program hash challenge).realForgeryProbability ≤ hybridError +
      (fullViewExperiment template program hash challenge).extractionFailureProbability +
      targetRecoveryProbability (withCiphertextView template challenge) program hash challenge +
      snapshotCollisionProbability (withCiphertextView template challenge) program hash challenge +
      ciphertextCollisionProbability (withCiphertextView template challenge) program hash challenge :=
  real_forgery_probability_le (withCiphertextView template challenge) program hash challenge hybrid

end
end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeSecurity
