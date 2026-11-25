module

public import Protocol.Transfer.PathSignature.NativeCommittedRelease
public import Protocol.Transfer.PathSignature.NativeCommittedRandomOracle.PublicContinuation
public import VCVio.EvalDist.MeasureTVDist.Bind
public import VCVio.EvalDist.MeasureTVDist.Event

@[expose] public section

/-!
# Recovery after a simulated checked-transfer release

The simulated evidence producer receives the original public intent, exact
V2 signing input and full ciphertext. The assembly uses the actual native
instance to fill the snapshot root and ciphertext name. Its public oracle
executions share the ciphertext game's cache and are charged to the query
budget. The supplied pure assembly functions are fixed as part of the
template; hash calls to the sampled byte oracle must be modeled as queries.

A separate transfer theorem takes a real joint prefix law, including the
original message, released view and live public cache, and an extended
total-variation bound to the simulated prefix. It resumes the same adaptive
decoder from each prefix. No marginal-view distance or CRS completeness
assumption establishes that simulation premise.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRelease

open OracleSpec OracleComp MeasureTheory
open NativeCommittedRandomOracle
open Storage.OperatorCommitment.RandomOracle
open scoped ENNReal

variable {Owner Advice Output : Type} {rows cols : ℕ}

/-- Signature and payload proof output, including a failed attempt. The
simulator sees the original public intent and canonical signing input. -/
abbrev EvidenceSimulator (Owner Advice : Type) :=
  Advice → Evidence.TransferTranscript.Intent Owner → List UInt8 → List UInt8 →
    OracleComp PublicSpec (Option (List UInt8 × List UInt8))

/-- The decoder retains the additional advice, native view and entire
assembled release. -/
abbrev ReleaseView (Owner Advice : Type) := Advice × View × Option (Owned.PublicTransferView Owner)

/-- State at the start of the recovery adversary, retaining the sampled
message for the event and the live cache for subsequent public queries. -/
abbrev Prefix (cols : ℕ) (Owner Advice : Type) :=
  (Bits cols × ReleaseView Owner Advice) × publicOracle.QueryCache

def simulateRelease (inputs : Advice → Inputs Owner) (simulate : EvidenceSimulator Owner Advice)
    (advice : Advice) (view : View) : OracleComp PublicSpec (ReleaseView Owner Advice) :=
  match NativeCommitted.decodeInstance view.1 with
  | none => pure (advice, view, none)
  | some instanceData =>
    (fun evidence => (advice, view, evidence.map fun bytes =>
      (inputs advice).assemble instanceData bytes.1 bytes.2)) <$>
      simulate advice ((inputs advice).intentAt instanceData)
        ((inputs advice).signingInputAt instanceData) view.2

theorem simulateRelease_query_bound (inputs : Advice → Inputs Owner)
    (simulate : EvidenceSimulator Owner Advice) {s : ℕ}
    (bounded : ∀ advice intent signing ciphertext,
      IsQueryBoundP (simulate advice intent signing ciphertext) publicOnly s)
    (advice : Advice) (view : View) :
    IsQueryBoundP (simulateRelease inputs simulate advice view) publicOnly s := by
  unfold simulateRelease
  split
  · simp
  · exact (isQueryBoundP_map_iff _ _ _).mpr (bounded _ _ _ _)

/-- The evidence simulation and recovery decoder run as a single public
continuation after the original two honest digest calls. -/
def simulatedRecovery (disclose : Bits cols → Advice) (inputs : Advice → Inputs Owner)
    (simulate : EvidenceSimulator Owner Advice)
    (adversary : ReleaseView Owner Advice → OracleComp PublicSpec Output)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) :
    OracleComp NativeSpec (Bits cols × Output) :=
  Disclosure.game disclose (fun advice view => simulateRelease inputs simulate advice view >>= adversary)
    base A d a

theorem simulated_recovery_probability_le
    (disclose : Bits cols → Advice) (inputs : Advice → Inputs Owner)
    (simulate : EvidenceSimulator Owner Advice)
    (adversary : ReleaseView Owner Advice → OracleComp PublicSpec Output)
    {s q : ℕ}
    (simulatorBound : ∀ advice intent signing ciphertext,
      IsQueryBoundP (simulate advice intent signing ciphertext) publicOnly s)
    (adversaryBound : ∀ view, IsQueryBoundP (adversary view) publicOnly q)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (target : Bits cols → Output) (injective : Function.Injective target) :
    realProbability (simulatedRecovery disclose inputs simulate adversary base A d a)
        (fun output => output.2 = target output.1) ≤
      ((HCP.FiniteRecovery.disclosedViews disclose).card : ℝ≥0∞) / (2 : ℝ≥0∞)^cols +
        ((s + q + 2 : ℕ) : ℝ≥0∞) * ((256 ^ 32 : ℕ) : ℝ≥0∞)⁻¹ := by
  refine Disclosure.recovery_probability_le disclose target injective
    (fun advice view => simulateRelease inputs simulate advice view >>= adversary) ?_
    base A d a orthogonal
  intro advice view
  exact isQueryBoundP_bind (simulateRelease_query_bound inputs simulate simulatorBound advice view)
    (fun released _ => adversaryBound released)

def simulatedPrefix (disclose : Bits cols → Advice) (inputs : Advice → Inputs Owner)
    (simulate : EvidenceSimulator Owner Advice) (base : NativeRelation.Witness rows cols)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) : ProbComp (Prefix cols Owner Advice) :=
  realPrefix (Disclosure.game disclose (simulateRelease inputs simulate) base A d a)

/-- Resume only the public program and retain the message for the event. -/
def continueRecovery (adversary : ReleaseView Owner Advice → OracleComp PublicSpec Output)
    (sampled : Prefix cols Owner Advice) : ProbComp (Bits cols × Output) :=
  (fun output => (sampled.1.1, output)) <$> resumePublic (adversary sampled.1.2) sampled.2

def recoveryFromPrefix (prefixLaw : ProbComp (Prefix cols Owner Advice))
    (adversary : ReleaseView Owner Advice → OracleComp PublicSpec Output)
    (target : Bits cols → Output) : ℝ≥0∞ :=
  Pr{let output ← prefixLaw >>= continueRecovery adversary}[output.2 = target output.1]

/-- Stopping at release and resuming in its actual cache is exactly the
simulation that runs both parts of the public continuation together. -/
theorem simulatedPrefix_recovery_eq
    (disclose : Bits cols → Advice) (inputs : Advice → Inputs Owner)
    (simulate : EvidenceSimulator Owner Advice)
    (adversary : ReleaseView Owner Advice → OracleComp PublicSpec Output)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (target : Bits cols → Output) :
    recoveryFromPrefix (simulatedPrefix disclose inputs simulate base A d a) adversary target =
      realProbability (simulatedRecovery disclose inputs simulate adversary base A d a)
        (fun output => output.2 = target output.1) := by
  unfold simulatedRecovery
  rw [Disclosure.game_bind disclose (simulateRelease inputs simulate) adversary]
  rw [realProbability_continue _ (fun sample => adversary sample.2) Prod.fst]
  simp only [recoveryFromPrefix, simulatedPrefix, continueRecovery, prEvent_norm]

/-- The joint prefix distance includes the sampled target and live cache,
even though neither is an argument to the public decoder. -/
def prefixDistance (actual simulated : ProbComp (Prefix cols Owner Advice)) : ℝ≥0∞ :=
  letI : MeasurableSpace (Prefix cols Owner Advice) := ⊤
  measureETVDist actual simulated

/-- If the actual honest prefix has the stated joint simulation error, the
same adaptive decoder from its live cache pays that error once. The prefix
law may include failed attempts. This is an unconditional event probability
within each experiment, without conditioning on acceptance. -/
theorem recovery_probability_le_of_joint_prefix
    (actual : ProbComp (Prefix cols Owner Advice))
    (disclose : Bits cols → Advice) (inputs : Advice → Inputs Owner)
    (simulate : EvidenceSimulator Owner Advice)
    (adversary : ReleaseView Owner Advice → OracleComp PublicSpec Output)
    {s q : ℕ}
    (simulatorBound : ∀ advice intent signing ciphertext,
      IsQueryBoundP (simulate advice intent signing ciphertext) publicOnly s)
    (adversaryBound : ∀ view, IsQueryBoundP (adversary view) publicOnly q)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (target : Bits cols → Output) (injective : Function.Injective target) {ε : ℝ≥0∞}
    (simulation : prefixDistance actual (simulatedPrefix disclose inputs simulate base A d a) ≤ ε) :
    recoveryFromPrefix actual adversary target ≤
      ((HCP.FiniteRecovery.disclosedViews disclose).card : ℝ≥0∞) / (2 : ℝ≥0∞)^cols +
        ((s + q + 2 : ℕ) : ℝ≥0∞) * ((256 ^ 32 : ℕ) : ℝ≥0∞)⁻¹ + ε := by
  let : MeasurableSpace (Prefix cols Owner Advice) := ⊤
  let : MeasurableSpace (Bits cols × Output) := ⊤
  let sim := simulatedPrefix disclose inputs simulate base A d a
  let suffix := continueRecovery (cols := cols) adversary
  have continuedDistance : measureETVDist (actual >>= suffix) (sim >>= suffix) ≤ ε :=
    (measureETVDist_bind_le actual sim suffix Measurable.of_discrete).trans simulation
  have eventBound := prEvent_le_prEvent_add_measureETVDist (actual >>= suffix) (sim >>= suffix)
    (fun output => output.2 = target output.1) Measurable.of_discrete
  have simulatedBound := simulated_recovery_probability_le disclose inputs simulate adversary
    simulatorBound adversaryBound base A d a orthogonal target injective
  have fromPrefix : recoveryFromPrefix sim adversary target ≤ _ :=
    (simulatedPrefix_recovery_eq disclose inputs simulate adversary base A d a target).trans_le
      simulatedBound
  exact eventBound.trans (add_le_add fromPrefix continuedDistance)

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRelease
