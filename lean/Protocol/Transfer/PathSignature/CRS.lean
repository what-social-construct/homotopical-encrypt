module

public import Protocol.Transfer.PathSignature
public import Protocol.Transfer.PublicAssembly

@[expose] public section

/-!
# A bounded adaptive CRS signature-of-knowledge reduction

The construction invokes the selected prover/verifier on the existing exact
credential/message encoding. A signing adversary is a response-dependent
bounded program: the interpreter generates every oracle answer and its actual
query log. Real answers use `prove`; simulated answers use `simulate` under
`simSetup`. The extraction event checks the selected extractor's actual byte
output with the same executable witness relation.

The reduction separates three obligations: real/simulated transfer for the
actual Boolean forgery test, simulation-extraction failure, and recovery of a
valid credential witness. Its main hybrid premise concerns this one test;
an all-events statistical bound is only a stronger optional corollary. No
global implication from verification to witness validity is
assumed. Numerical primitive bounds, efficient algorithms and asymptotic or
adaptive-unbounded security are not supplied. The selected tagged CRS primitive
must consume the complete public input; an ordinary verifier that ignores
unused message wires does not meet the needed extraction assumption.

This is a composition over supplied CRS algorithms, not an implementation of
Groth16 or another pairing-based primitive. The direct trapdoor-extraction
route needs no auxiliary HCP public-key encryption. Witness privacy needs the
separate simulation hybrid, and authenticated setup/profile registration is
outside this leaf. The security organization follows Chase--Lysyanskaya,
"On Signatures of Knowledge", Section 2.2:
https://cs.brown.edu/people/alysyans/papers/cl06.pdf
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.CRS

open TCB.PrimitiveChecks
open Evidence.TransferTranscript
open scoped ENNReal

abbrev Bytes := List UInt8

/-- Actual algorithms of the selected tagged CRS proof primitive. Security is
not built into this carrier. Real and simulated setup may have different laws. -/
structure Primitive (Seed Reference Trapdoor Randomness : Type) where
  setup : Seed → Reference
  simSetup : Seed → Reference × Trapdoor
  prove : Reference → Bytes → Bytes → Randomness → Bytes
  verify : Reference → Bytes → Bytes → Bool
  simulate : Trapdoor → Bytes → Randomness → Bytes
  extract : Trapdoor → Bytes → Bytes → Option Bytes

variable {Seed Reference Trapdoor Randomness : Type}

/-- Honest-proof completeness is a named primitive contract, not a knowledge
or simulation-extraction assumption. -/
def Correct (primitive : Primitive Seed Reference Trapdoor Randomness)
    (relation : Bytes → Bytes → Bool) : Prop :=
  ∀ seed input witness random,
    relation input witness = true →
      primitive.verify (primitive.setup seed) input
        (primitive.prove (primitive.setup seed) input witness random) = true

def sign (primitive : Primitive Seed Reference Trapdoor Randomness)
    (reference : Reference) (key message witness : Bytes) (random : Randomness) : Bytes :=
  primitive.prove reference (Codec.encode key message) witness random

/-- The original byte-signature backend executes on the complete key/message
input; it has no separately supplied algorithm-agreement premise. -/
def verifier (primitive : Primitive Seed Reference Trapdoor Randomness)
    (reference : Reference) : SignatureVerifier Bytes where
  verify key message signature := primitive.verify reference (Codec.encode key message) signature

theorem sign_complete (primitive : Primitive Seed Reference Trapdoor Randomness)
    (relation : Bytes → Bytes → Bool) (correct : Correct primitive relation)
    (seed : Seed) (key message witness : Bytes) (random : Randomness)
    (valid : relation (Codec.encode key message) witness = true) :
    (verifier primitive (primitive.setup seed)).verify key message
      (sign primitive (primitive.setup seed) key message witness random) = true :=
  correct seed (Codec.encode key message) witness random valid

/-- An oracle answer retains the exact queried message and actual proof bytes. -/
structure QueryReply where
  message : Bytes
  proof : Bytes

structure Target where
  message : Bytes
  proof : Bytes

/-- The next query can depend on every previously received proof byte. -/
inductive Decision where
  | query (message : Bytes)
  | finish (target : Target)

structure Execution where
  history : List QueryReply
  output : Option Target

/-- A bounded adaptive signing interpreter. Exhausting the query budget on a
further query aborts; a final target may still be returned at budget zero. -/
def run (step : List QueryReply → Decision) (oracle : ℕ → Bytes → Bytes) :
    ℕ → List QueryReply → Execution
  | 0, history =>
    match step history with
    | .query _ => ⟨history, none⟩
    | .finish target => ⟨history, some target⟩
  | remaining + 1, history =>
    match step history with
    | .query message =>
      run step oracle remaining
        (history ++ [⟨message, oracle history.length message⟩])
    | .finish target => ⟨history, some target⟩

/-- Generated histories, rather than an independently asserted query list. -/
inductive Trace (oracle : ℕ → Bytes → Bytes) : List QueryReply → Prop where
  | nil : Trace oracle []
  | answer (history : List QueryReply) (message : Bytes) (previous : Trace oracle history) :
      Trace oracle (history ++ [⟨message, oracle history.length message⟩])

theorem run_trace (step : List QueryReply → Decision) (oracle : ℕ → Bytes → Bytes)
    (fuel : ℕ) (history : List QueryReply) (generated : Trace oracle history) :
    Trace oracle (run step oracle fuel history).history := by
  induction fuel generalizing history with
  | zero => cases next : step history <;> simpa [run, next] using generated
  | succ fuel ih =>
    cases next : step history with
    | query message =>
      simpa [run, next] using ih _ (Trace.answer history message generated)
    | finish target => simpa [run, next] using generated

theorem run_history_prefix (step : List QueryReply → Decision) (oracle : ℕ → Bytes → Bytes)
    (fuel : ℕ) (history : List QueryReply) :
    ∃ appended, (run step oracle fuel history).history = history ++ appended := by
  induction fuel generalizing history with
  | zero => cases next : step history <;> exact ⟨[], by simp [run, next]⟩
  | succ fuel ih =>
    cases next : step history with
    | query message =>
      obtain ⟨tail, extendedHistory⟩ := ih (history ++ [⟨message, oracle history.length message⟩])
      exact ⟨⟨message, oracle history.length message⟩ :: tail,
        by simpa [run, next, List.append_assoc] using extendedHistory⟩
    | finish target => exact ⟨[], by simp [run, next]⟩

/-- The bound counts actual generated queries, including adaptive ones. -/
theorem run_query_bound (step : List QueryReply → Decision) (oracle : ℕ → Bytes → Bytes)
    (fuel : ℕ) (history : List QueryReply) :
    (run step oracle fuel history).history.length ≤ history.length + fuel := by
  induction fuel generalizing history with
  | zero => cases next : step history <;> simp [run, next]
  | succ fuel ih =>
    cases next : step history with
    | query message =>
      have bounded := ih (history ++ [⟨message, oracle history.length message⟩])
      simpa [run, next, List.length_append, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using bounded
    | finish target => simp [run, next]

def inputs (key : Bytes) (history : List QueryReply) : List Bytes :=
  history.map fun record => Codec.encode key record.message

/-- The complete encoded input and its actual returned proof form the log. -/
def queryLog (key : Bytes) (history : List QueryReply) : List (Bytes × Bytes) :=
  history.map fun record => (Codec.encode key record.message, record.proof)

theorem queryLog_inputs (key : Bytes) (history : List QueryReply) :
    (queryLog key history).map Prod.fst = inputs key history := by
  simp [queryLog, inputs, List.map_map]

theorem input_mem_iff_message_mem (key message : Bytes) (history : List QueryReply) :
    Codec.encode key message ∈ inputs key history ↔ message ∈ history.map QueryReply.message := by
  constructor
  · intro member
    obtain ⟨record, member, same⟩ := List.mem_map.mp member
    have subjects : (key, record.message) = (key, message) := Codec.encode_injective same
    exact List.mem_map.mpr ⟨record, member, congrArg Prod.snd subjects⟩
  · intro member
    obtain ⟨record, member, same⟩ := List.mem_map.mp member
    exact List.mem_map.mpr ⟨record, member, congrArg (Codec.encode key) same⟩

/-- Freshness of the byte input is freshness of the full signing metadata and
intent when the queries use the original signing codec. -/
theorem fresh_full_subject {Owner : Type}
    (codec : Evidence.TransferCheck.PacketCodec Owner) (key : Bytes)
    (queries : List (ProofMetadata × Intent Owner))
    (metadata : ProofMetadata) (intent : Intent Owner)
    (fresh : (metadata, intent) ∉ queries) :
    Codec.encode key (Signing.message codec metadata intent) ∉
      queries.map (fun subject => Codec.encode key (Signing.message codec subject.1 subject.2)) := by
  intro queried
  obtain ⟨subject, member, same⟩ := List.mem_map.mp queried
  have encoded : (key, Signing.message codec subject.1 subject.2) =
      (key, Signing.message codec metadata intent) := Codec.encode_injective same
  have reflects := (Signing.message_eq_iff codec subject.1 metadata subject.2 intent).1
    (congrArg Prod.snd encoded)
  have sameSubject : subject = (metadata, intent) := by
    apply Prod.ext
    · exact reflects.1
    · exact reflects.2
  exact fresh (sameSubject ▸ member)

/-- Verification-relevant public outcome with the actual query/answer log.
The experiment's auxiliary input also affects adversary execution; this carrier
is not asserted to be a complete network or zero-knowledge view. Neither the
private witness nor extraction trapdoor is supplied to the adversary. -/
structure Transcript (Reference : Type) where
  reference : Reference
  key : Bytes
  execution : Execution

def Fresh (transcript : Transcript Reference) (target : Target) : Prop :=
  Codec.encode transcript.key target.message ∉ inputs transcript.key transcript.execution.history

def Wins (primitive : Primitive Seed Reference Trapdoor Randomness)
    (transcript : Transcript Reference) : Prop :=
  ∃ target, transcript.execution.output = some target ∧ Fresh transcript target ∧
    primitive.verify transcript.reference (Codec.encode transcript.key target.message) target.proof = true

/-- The actual forgery distinguisher checks only the returned target, freshness
of its complete key/message input in the generated log, and verification.
Efficiency additionally requires bounds for the selected primitive and fuel. -/
def forgeryTest (primitive : Primitive Seed Reference Trapdoor Randomness)
    (transcript : Transcript Reference) : Bool :=
  match transcript.execution.output with
  | none => false
  | some target =>
    decide (Codec.encode transcript.key target.message ∉
      inputs transcript.key transcript.execution.history) &&
      primitive.verify transcript.reference (Codec.encode transcript.key target.message) target.proof

theorem forgeryTest_eq_true_iff (primitive : Primitive Seed Reference Trapdoor Randomness)
    (transcript : Transcript Reference) :
    forgeryTest primitive transcript = true ↔ Wins primitive transcript := by
  cases returned : transcript.execution.output with
  | none => simp [forgeryTest, Wins, returned]
  | some target => simp [forgeryTest, Wins, Fresh, returned]

def ValidExtract (relation : Bytes → Bytes → Bool) (input : Bytes) (extracted : Option Bytes) : Prop :=
  ∃ witness, extracted = some witness ∧ relation input witness = true

variable {Aux AdversaryCoins Coins : Type}

/-- One shared sampled tape supplies the credential challenge, its private
witness, public auxiliary data, setup, proof randomness and adversary randomness.
The same response-dependent adversary runs in both games. Selected distributions
must justify their intended independence or correlations when primitive bounds
are instantiated. -/
structure Experiment (Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins : Type) where
  primitive : Primitive Seed Reference Trapdoor Randomness
  relation : Bytes → Bytes → Bool
  key : Coins → Bytes
  witness : Coins → Bytes
  auxiliary : Coins → Aux
  fuel : ℕ
  coins : PMF Coins
  setupSeed : Coins → Seed
  proofRandomness : Coins → ℕ → Randomness
  adversaryRandomness : Coins → AdversaryCoins
  adversary : Reference → Bytes → Aux → AdversaryCoins → List QueryReply → Decision

namespace Experiment

variable (experiment : Experiment Seed Reference Trapdoor Randomness Aux AdversaryCoins Coins)

def realOracle (coin : Coins) (index : ℕ) (message : Bytes) : Bytes :=
  experiment.primitive.prove (experiment.primitive.setup (experiment.setupSeed coin))
    (Codec.encode (experiment.key coin) message) (experiment.witness coin) (experiment.proofRandomness coin index)

/-- The actual real oracle uses the prover whose primitive completeness law
applies to the same credential, message and selected witness. -/
theorem real_oracle_verified
    (correct : Correct experiment.primitive experiment.relation)
    (witnessValid : ∀ coin message,
      experiment.relation (Codec.encode (experiment.key coin) message) (experiment.witness coin) = true)
    (coin : Coins) (index : ℕ) (message : Bytes) :
    experiment.primitive.verify (experiment.primitive.setup (experiment.setupSeed coin))
      (Codec.encode (experiment.key coin) message) (experiment.realOracle coin index message) = true :=
  correct (experiment.setupSeed coin) (Codec.encode (experiment.key coin) message)
    (experiment.witness coin) (experiment.proofRandomness coin index) (witnessValid coin message)

def simulatedOracle (coin : Coins) (index : ℕ) (message : Bytes) : Bytes :=
  experiment.primitive.simulate (experiment.primitive.simSetup (experiment.setupSeed coin)).2
    (Codec.encode (experiment.key coin) message) (experiment.proofRandomness coin index)

def realTranscript (coin : Coins) : Transcript Reference :=
  let reference := experiment.primitive.setup (experiment.setupSeed coin)
  ⟨reference, experiment.key coin,
    run (experiment.adversary reference (experiment.key coin) (experiment.auxiliary coin)
      (experiment.adversaryRandomness coin)) (experiment.realOracle coin) experiment.fuel []⟩

def simulatedTranscript (coin : Coins) : Transcript Reference :=
  let reference := (experiment.primitive.simSetup (experiment.setupSeed coin)).1
  ⟨reference, experiment.key coin,
    run (experiment.adversary reference (experiment.key coin) (experiment.auxiliary coin)
      (experiment.adversaryRandomness coin)) (experiment.simulatedOracle coin) experiment.fuel []⟩

/-- Changing only the private witness field leaves the simulated execution
unchanged. Public auxiliary data and the other sampled maps are held fixed;
this algorithmic independence alone is not a zero-knowledge theorem. -/
theorem simulatedTranscript_independent_of_witness
    (replacement : Coins → Bytes) (coin : Coins) :
    ({ experiment with witness := replacement }).simulatedTranscript coin =
      experiment.simulatedTranscript coin := rfl

theorem real_history_generated (coin : Coins) :
    Trace (experiment.realOracle coin) (experiment.realTranscript coin).execution.history :=
  run_trace _ _ _ [] (Trace.nil)

theorem simulated_history_generated (coin : Coins) :
    Trace (experiment.simulatedOracle coin) (experiment.simulatedTranscript coin).execution.history :=
  run_trace _ _ _ [] (Trace.nil)

def extracted (coin : Coins) (target : Target) : Option Bytes :=
  experiment.primitive.extract (experiment.primitive.simSetup (experiment.setupSeed coin)).2
    (Codec.encode (experiment.key coin) target.message) target.proof

/-- Actual fresh accepted simulated-game output whose actual extractor output
fails the designated executable witness relation. -/
def ExtractionFailure (coin : Coins) : Prop :=
  ∃ target, (experiment.simulatedTranscript coin).execution.output = some target ∧
    Fresh (experiment.simulatedTranscript coin) target ∧
    experiment.primitive.verify (experiment.simulatedTranscript coin).reference
      (Codec.encode (experiment.key coin) target.message) target.proof = true ∧
    ¬ ValidExtract experiment.relation (Codec.encode (experiment.key coin) target.message)
      (experiment.extracted coin target)

/-- This reduction actually outputs a valid finite witness. Its projection to
a credential-opening/HCP recovery game belongs to the selected native relation. -/
def WitnessRecovery (coin : Coins) : Prop :=
  ∃ target witness, (experiment.simulatedTranscript coin).execution.output = some target ∧
    experiment.extracted coin target = some witness ∧
    experiment.relation (Codec.encode (experiment.key coin) target.message) witness = true

theorem simulated_win_implies_cases (coin : Coins)
    (won : Wins experiment.primitive (experiment.simulatedTranscript coin)) :
    experiment.ExtractionFailure coin ∨ experiment.WitnessRecovery coin := by
  obtain ⟨target, returned, fresh, verified⟩ := won
  by_cases valid : ValidExtract experiment.relation (Codec.encode (experiment.key coin) target.message)
      (experiment.extracted coin target)
  · obtain ⟨witness, extracted, accepted⟩ := valid
    exact Or.inr ⟨target, witness, returned, extracted, accepted⟩
  · exact Or.inl ⟨target, returned, fresh, verified, valid⟩

noncomputable section

def realDistribution : PMF (Transcript Reference) := experiment.coins.map experiment.realTranscript

def simulatedDistribution : PMF (Transcript Reference) :=
  experiment.coins.map experiment.simulatedTranscript

def realForgeryProbability : ℝ≥0∞ :=
  experiment.realDistribution.toOuterMeasure {transcript | Wins experiment.primitive transcript}

def extractionFailureProbability : ℝ≥0∞ :=
  experiment.coins.toOuterMeasure {coin | experiment.ExtractionFailure coin}

def witnessRecoveryProbability : ℝ≥0∞ :=
  experiment.coins.toOuterMeasure {coin | experiment.WitnessRecovery coin}

/-- Event-specific setup/signing hybrid transfer. It requires no statistical
closeness for all sets of transcripts. Computational instantiation uses the
actual `forgeryTest` and still needs efficiency/primitive security arguments. -/
def WinningHybrid (hybridError : ℝ≥0∞) : Prop :=
  experiment.realDistribution.toOuterMeasure {transcript | Wins experiment.primitive transcript} ≤
    experiment.simulatedDistribution.toOuterMeasure {transcript | Wins experiment.primitive transcript} +
      hybridError

/-- A bound for this actual Boolean distinguisher supplies precisely the
event-specific premise needed by the reduction. -/
theorem winningHybrid_of_forgeryTest_bound {hybridError : ℝ≥0∞}
    (hybrid : experiment.realDistribution.toOuterMeasure
        {transcript | forgeryTest experiment.primitive transcript = true} ≤
      experiment.simulatedDistribution.toOuterMeasure
        {transcript | forgeryTest experiment.primitive transcript = true} + hybridError) :
    experiment.WinningHybrid hybridError := by
  simpa only [WinningHybrid, forgeryTest_eq_true_iff] using hybrid

/-- The one winning-event hybrid, extraction-failure mass and credential
recovery mass compose for this actual bounded adaptive execution. This is
compatible with a computational hybrid for the stated Boolean test; it does
not assume statistical zero knowledge. No independence is used. -/
theorem realForgeryProbability_le_of_winning_hybrid {hybridError : ℝ≥0∞}
    (hybrid : experiment.WinningHybrid hybridError) :
    experiment.realForgeryProbability ≤ hybridError +
      experiment.extractionFailureProbability + experiment.witnessRecoveryProbability := by
  let event : Set (Transcript Reference) := {transcript | Wins experiment.primitive transcript}
  have transfer : experiment.realForgeryProbability ≤
      experiment.simulatedDistribution.toOuterMeasure event + hybridError := hybrid
  have simulatedBound : experiment.simulatedDistribution.toOuterMeasure event ≤
      experiment.extractionFailureProbability + experiment.witnessRecoveryProbability := by
    change (experiment.coins.map experiment.simulatedTranscript).toOuterMeasure event ≤ _
    rw [PMF.toOuterMeasure_map_apply]
    have included : experiment.simulatedTranscript ⁻¹' event ⊆
        {coin | experiment.ExtractionFailure coin} ∪ {coin | experiment.WitnessRecovery coin} := by
      intro coin won
      exact simulated_win_implies_cases experiment coin won
    exact (MeasureTheory.measure_mono included).trans
      (MeasureTheory.measure_union_le _ _)
  calc
    experiment.realForgeryProbability ≤
        experiment.simulatedDistribution.toOuterMeasure event + hybridError := transfer
    _ ≤ (experiment.extractionFailureProbability + experiment.witnessRecoveryProbability) +
        hybridError := add_le_add simulatedBound le_rfl
    _ = hybridError + experiment.extractionFailureProbability + experiment.witnessRecoveryProbability := by
      ac_rfl

/-- The stronger all-events statistical bound remains a sufficient corollary;
it is not the assumption required by the event-specific main reduction. -/
theorem realForgeryProbability_le {hybridError : ℝ≥0∞}
    (hybrid : Owned.EventBound experiment.realDistribution experiment.simulatedDistribution hybridError) :
    experiment.realForgeryProbability ≤ hybridError +
      experiment.extractionFailureProbability + experiment.witnessRecoveryProbability :=
  realForgeryProbability_le_of_winning_hybrid experiment
    (hybrid {transcript | Wins experiment.primitive transcript}).1

theorem realForgeryProbability_le_of_winning_hybrid_of_bounds
    {hybridError extractionError recoveryError : ℝ≥0∞}
    (hybrid : experiment.WinningHybrid hybridError)
    (extractionBound : experiment.extractionFailureProbability ≤ extractionError)
    (recoveryBound : experiment.witnessRecoveryProbability ≤ recoveryError) :
    experiment.realForgeryProbability ≤ hybridError + extractionError + recoveryError :=
  (realForgeryProbability_le_of_winning_hybrid experiment hybrid).trans
    (add_le_add (add_le_add le_rfl extractionBound) recoveryBound)

theorem realForgeryProbability_le_of_bounds
    {hybridError extractionError recoveryError : ℝ≥0∞}
    (hybrid : Owned.EventBound experiment.realDistribution experiment.simulatedDistribution hybridError)
    (extractionBound : experiment.extractionFailureProbability ≤ extractionError)
    (recoveryBound : experiment.witnessRecoveryProbability ≤ recoveryError) :
    experiment.realForgeryProbability ≤ hybridError + extractionError + recoveryError :=
  (realForgeryProbability_le experiment hybrid).trans
    (add_le_add (add_le_add le_rfl extractionBound) recoveryBound)

end
end Experiment
end HomotopicalEncryption.Protocol.Transfer.PathSignature.CRS
