module

public import TCB.PrimitiveChecks
public import Protocol.Transfer.Security

@[expose] public section

/-!
# Primitive failure events for the original operational transfer

The selected signature and proof backends must execute exactly the algorithms
used by the existing operational configuration, on its actual encoded owner,
intent and payload input. These equations do not assert semantic soundness.

An unauthorized verified packet either contains a fresh-message forgery for an
uncompromised key, uses a compromised key, or reuses a queried key/message for
an unauthorized intent. The last event includes issuer-policy failures, key
aliasing and encoding/hash collisions; no global digest injectivity is assumed.
A proof accepted for a rejected original context either violates its backend
statement or proves a statement that fails to imply that context's acceptance.

The resulting five-event bound uses the same attempted bytes and PMF as the
existing one-shot experiment. Histories and compromised-key relations are fixed
inputs, not an adaptive oracle implementation. A primitive-game instantiation
must account for honest signatures available in the release and auxiliary data
in its query history. No history/execution/coverage theorem is built into these
profiles. No concrete primitive, sampling scheme, efficient-adversary class or
numerical error bound is instantiated.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt.Protocol.Transfer.Primitives

open Sheaf CellularSheaf
open Evidence.TransferTranscript
open TCB.PrimitiveChecks
open scoped ENNReal

variable {Vertex Edge Face Owner Asset Receipt Key Aux Coins : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}
  {F : CellularSheaf X}

/-- Exact execution binding to a selected byte-signature backend and fixed history.
The key registry and encoder are actual functions, not security properties. -/
structure SignatureProfile (config : Operational.Config F Owner Asset Receipt)
    (Key : Type) where
  backend : SignatureVerifier Key
  keyFor : Owner → Key
  messageFor : Owner → Intent Owner → Bytes
  history : SignatureHistory Key
  agrees : ∀ owner intent signature,
    config.authorization.verify owner intent signature =
      backend.verify (keyFor owner) (messageFor owner intent) signature

/-- Exact execution binding to a proof backend under the original configuration.
Its statement is deliberately separate from exact acceptance of that context. -/
structure PayloadProfile (config : Operational.Config F Owner Asset Receipt) where
  backend : ProofVerifier
  inputFor : Intent Owner → Bytes
  agrees : ∀ intent proof,
    config.payload.verify intent proof = backend.verify (inputFor intent) proof

/-- The packet is the actual parser result with this attempted public input. -/
def ParsedFor (config : Operational.Config F Owner Asset Receipt)
    (attempt : Operational.Attempt Owner) (packet : ProofPacket Owner) : Prop :=
  config.codec.decode attempt.bytes = some packet ∧
    packet.metadata = config.metadata ∧ packet.intent = config.intentFor attempt.transfer

variable {config : Operational.Config F Owner Asset Receipt}

/-- A fresh-message signature forgery occurring in an actual unauthorized packet. -/
def Forgery (profile : SignatureProfile config Key)
    (attempt : Operational.Attempt Owner) : Prop :=
  ∃ packet : ProofPacket Owner, ParsedFor config attempt packet ∧
    profile.history.Forgery profile.backend (profile.keyFor attempt.transfer.signer)
      (profile.messageFor attempt.transfer.signer (config.intentFor attempt.transfer))
      packet.ownerSignature ∧
    ¬ config.authorization.Authorized attempt.transfer.signer
      (config.intentFor attempt.transfer)

/-- An actual unauthorized verified packet uses a key marked compromised. -/
def CompromisedKey (profile : SignatureProfile config Key)
    (attempt : Operational.Attempt Owner) : Prop :=
  ∃ packet : ProofPacket Owner, ParsedFor config attempt packet ∧
    profile.backend.verify (profile.keyFor attempt.transfer.signer)
      (profile.messageFor attempt.transfer.signer (config.intentFor attempt.transfer))
      packet.ownerSignature = true ∧
    profile.history.compromised (profile.keyFor attempt.transfer.signer) ∧
    ¬ config.authorization.Authorized attempt.transfer.signer
      (config.intentFor attempt.transfer)

/-- A previously queried key/message verifies an unauthorized original intent.
No claim is made that the earlier query had this owner, intent or source state. -/
def QueriedUnauthorized (profile : SignatureProfile config Key)
    (attempt : Operational.Attempt Owner) : Prop :=
  ∃ packet : ProofPacket Owner, ParsedFor config attempt packet ∧
    profile.backend.verify (profile.keyFor attempt.transfer.signer)
      (profile.messageFor attempt.transfer.signer (config.intentFor attempt.transfer))
      packet.ownerSignature = true ∧
    profile.history.Queried (profile.keyFor attempt.transfer.signer)
      (profile.messageFor attempt.transfer.signer (config.intentFor attempt.transfer)) ∧
    ¬ config.authorization.Authorized attempt.transfer.signer
      (config.intentFor attempt.transfer)

/-- A decoded proof packet violates the selected backend's own statement. -/
def ProofFalseAccept (profile : PayloadProfile config)
    (attempt : Operational.Attempt Owner) : Prop :=
  ∃ packet : ProofPacket Owner, ParsedFor config attempt packet ∧
    profile.backend.FalseAccept (profile.inputFor (config.intentFor attempt.transfer))
      packet.proofBytes ∧ ¬ config.context.Accepted

/-- The backend statement holds but does not imply acceptance of the actual context.
The actual proof check and its original parsed packet are retained. -/
def StatementMismatch (profile : PayloadProfile config)
    (attempt : Operational.Attempt Owner) : Prop :=
  ∃ packet : ProofPacket Owner, ParsedFor config attempt packet ∧
    profile.backend.verify (profile.inputFor (config.intentFor attempt.transfer))
      packet.proofBytes = true ∧
    profile.backend.Holds (profile.inputFor (config.intentFor attempt.transfer)) ∧
    ¬ config.context.Accepted

/-- An authorization failure cannot be charged to fresh forgery alone without
controlling keys and the meaning of all queried messages. -/
theorem authorizationFailure_implies_cases (profile : SignatureProfile config Key)
    (attempt : Operational.Attempt Owner)
    (failure : Operational.AuthorizationFailure config attempt) :
    Forgery profile attempt ∨ CompromisedKey profile attempt ∨
      QueriedUnauthorized profile attempt := by
  obtain ⟨packet, decoded, metadata, intent, verified, unauthorized⟩ := failure
  have backendVerified : profile.backend.verify (profile.keyFor attempt.transfer.signer)
      (profile.messageFor attempt.transfer.signer (config.intentFor attempt.transfer))
      packet.ownerSignature = true :=
    (profile.agrees _ _ _).symm.trans verified
  rcases profile.history.verified_cases profile.backend _ _ _ backendVerified with
    forgery | compromised | queried
  · exact Or.inl ⟨packet, ⟨decoded, metadata, intent⟩, forgery, unauthorized⟩
  · exact Or.inr (Or.inl ⟨packet, ⟨decoded, metadata, intent⟩, backendVerified,
      compromised, unauthorized⟩)
  · exact Or.inr (Or.inr ⟨packet, ⟨decoded, metadata, intent⟩, backendVerified,
      queried, unauthorized⟩)

/-- Backend soundness and the original-context statement comparison are separate. -/
theorem payloadFailure_implies_cases (profile : PayloadProfile config)
    (attempt : Operational.Attempt Owner)
    (failure : Operational.PayloadFailure config attempt) :
    ProofFalseAccept profile attempt ∨ StatementMismatch profile attempt := by
  obtain ⟨packet, decoded, metadata, intent, verified, unaccepted⟩ := failure
  have backendVerified : profile.backend.verify
      (profile.inputFor (config.intentFor attempt.transfer)) packet.proofBytes = true :=
    (profile.agrees _ _).symm.trans verified
  rcases profile.backend.verified_cases _ _ backendVerified with holds | falseAccept
  · exact Or.inr ⟨packet, ⟨decoded, metadata, intent⟩, backendVerified, holds, unaccepted⟩
  · exact Or.inl ⟨packet, ⟨decoded, metadata, intent⟩, falseAccept, unaccepted⟩

/-- Five actual primitive/binding events cover the original accepted-invalid event. -/
theorem acceptedInvalid_implies_cases [DecidableEq Asset]
    (signature : SignatureProfile config Key) (payload : PayloadProfile config)
    (attempt : Operational.Attempt Owner)
    (failure : Operational.AcceptedInvalid config attempt) :
    Forgery signature attempt ∨ CompromisedKey signature attempt ∨
      QueriedUnauthorized signature attempt ∨ ProofFalseAccept payload attempt ∨
      StatementMismatch payload attempt := by
  rcases Operational.acceptedInvalid_implies_failure config attempt failure with
    authorizationFailure | payloadFailure
  · rcases authorizationFailure_implies_cases signature attempt authorizationFailure with
      forgery | compromised | queried
    · exact Or.inl forgery
    · exact Or.inr (Or.inl compromised)
    · exact Or.inr (Or.inr (Or.inl queried))
  · rcases payloadFailure_implies_cases payload attempt payloadFailure with falseAccept | mismatch
    · exact Or.inr (Or.inr (Or.inr (Or.inl falseAccept)))
    · exact Or.inr (Or.inr (Or.inr (Or.inr mismatch)))

namespace Experiment

variable (experiment : Security.Experiment F Owner Asset Receipt Aux Coins)
  (signature : SignatureProfile experiment.config Key)
  (payload : PayloadProfile experiment.config)

/-- Actual fresh-forgery outcomes on this experiment's shared tape. -/
def forgeryEvent : Set Coins := {coin | Forgery signature (experiment.attempt coin)}

/-- Actual compromised-key outcomes on the same tape. -/
def compromisedKeyEvent : Set Coins := {coin | CompromisedKey signature (experiment.attempt coin)}

/-- Actual queried-but-unauthorized message outcomes on the same tape. -/
def queriedUnauthorizedEvent : Set Coins :=
  {coin | QueriedUnauthorized signature (experiment.attempt coin)}

/-- Actual false proof statements on the same tape. -/
def proofFalseAcceptEvent : Set Coins := {coin | ProofFalseAccept payload (experiment.attempt coin)}

/-- Actual backend/original-context statement mismatches on the same tape. -/
def statementMismatchEvent : Set Coins := {coin | StatementMismatch payload (experiment.attempt coin)}

def forgeryProbability : ℝ≥0∞ := experiment.coins.toOuterMeasure (forgeryEvent experiment signature)

def compromisedKeyProbability : ℝ≥0∞ :=
  experiment.coins.toOuterMeasure (compromisedKeyEvent experiment signature)

def queriedUnauthorizedProbability : ℝ≥0∞ :=
  experiment.coins.toOuterMeasure (queriedUnauthorizedEvent experiment signature)

def proofFalseAcceptProbability : ℝ≥0∞ :=
  experiment.coins.toOuterMeasure (proofFalseAcceptEvent experiment payload)

def statementMismatchProbability : ℝ≥0∞ :=
  experiment.coins.toOuterMeasure (statementMismatchEvent experiment payload)

/-- The events all refer to the same attempted transfer and its exact parsed packet. -/
theorem acceptedInvalidEvent_subset_cases [DecidableEq Asset] :
    experiment.acceptedInvalidEvent ⊆
      forgeryEvent experiment signature ∪
        (compromisedKeyEvent experiment signature ∪
          (queriedUnauthorizedEvent experiment signature ∪
            (proofFalseAcceptEvent experiment payload ∪ statementMismatchEvent experiment payload))) := by
  intro coin failure
  exact acceptedInvalid_implies_cases signature payload (experiment.attempt coin) failure

/-- A shared-PMF union bound, with no independence or primitive error estimate. -/
theorem acceptedInvalidProbability_le [DecidableEq Asset] :
    experiment.acceptedInvalidProbability ≤
      forgeryProbability experiment signature + compromisedKeyProbability experiment signature +
        queriedUnauthorizedProbability experiment signature +
        proofFalseAcceptProbability experiment payload + statementMismatchProbability experiment payload := by
  let μ := experiment.coins.toOuterMeasure
  let f := forgeryEvent experiment signature
  let c := compromisedKeyEvent experiment signature
  let q := queriedUnauthorizedEvent experiment signature
  let p := proofFalseAcceptEvent experiment payload
  let s := statementMismatchEvent experiment payload
  have pointwise : experiment.acceptedInvalidEvent ⊆ f ∪ (c ∪ (q ∪ (p ∪ s))) :=
    acceptedInvalidEvent_subset_cases experiment signature payload
  have unionBound : μ (f ∪ (c ∪ (q ∪ (p ∪ s)))) ≤ μ f + (μ c + (μ q + (μ p + μ s))) := by
    calc
      μ (f ∪ (c ∪ (q ∪ (p ∪ s)))) ≤ μ f + μ (c ∪ (q ∪ (p ∪ s))) :=
        MeasureTheory.measure_union_le _ _
      _ ≤ μ f + (μ c + μ (q ∪ (p ∪ s))) :=
        add_le_add le_rfl (MeasureTheory.measure_union_le _ _)
      _ ≤ μ f + (μ c + (μ q + μ (p ∪ s))) :=
        add_le_add le_rfl (add_le_add le_rfl (MeasureTheory.measure_union_le _ _))
      _ ≤ μ f + (μ c + (μ q + (μ p + μ s))) :=
        add_le_add le_rfl (add_le_add le_rfl (add_le_add le_rfl
          (MeasureTheory.measure_union_le _ _)))
  have result := (MeasureTheory.measure_mono pointwise).trans unionBound
  with_reducible_and_instances
    simpa only [μ, f, c, q, p, s, Security.Experiment.acceptedInvalidProbability,
      forgeryProbability, compromisedKeyProbability, queriedUnauthorizedProbability,
      proofFalseAcceptProbability, statementMismatchProbability, add_assoc] using result

/-- Error budgets for these five events compose for this same experiment and adversary. -/
theorem acceptedInvalidProbability_le_of_bounds [DecidableEq Asset]
    {forgeryError compromisedError queriedError proofError statementError : ℝ≥0∞}
    (forgeryBound : forgeryProbability experiment signature ≤ forgeryError)
    (compromisedBound : compromisedKeyProbability experiment signature ≤ compromisedError)
    (queriedBound : queriedUnauthorizedProbability experiment signature ≤ queriedError)
    (proofBound : proofFalseAcceptProbability experiment payload ≤ proofError)
    (statementBound : statementMismatchProbability experiment payload ≤ statementError) :
    experiment.acceptedInvalidProbability ≤
      forgeryError + compromisedError + queriedError + proofError + statementError :=
  (acceptedInvalidProbability_le experiment signature payload).trans
    (add_le_add (add_le_add (add_le_add (add_le_add forgeryBound compromisedBound)
      queriedBound) proofBound) statementBound)

end Experiment

end Hcrypt.Protocol.Transfer.Primitives
