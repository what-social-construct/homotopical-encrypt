module

public import Protocol.Transfer.Issuance
public import Protocol.Transfer.Primitives

@[expose] public section

/-!
# Wiring full-intent signing and authorized issuance into the existing transfer

The selected byte backend and existing owner-to-key map now construct the raw
authorization algorithm, rather than merely assuming a checker-agreement law.
The original context, catalog, source state, intent and semantic policy remain
the same. Signing bytes use the existing packet codec with empty signature and
proof outputs, plus a distinct owner domain; the codec is still supplied.

The existing signature history is derived from typed authorized issues and a
foreign query batch outside that domain. Full metadata/intent reflection rules
out queried-but-unauthorized acceptance under that actual fixed policy. No
injective-key premise, hash inversion, global soundness, numerical primitive
bound or secret-key execution is inferred. Registration, key secrecy and full
history coverage remain separate obligations.

An actual checked release under this newly configured checker can be recorded
with its exact signature, given its independent authorization fact. Arbitrary
legacy signatures are never reinterpreted as signatures of these new messages.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.Authorization

open Sheaf CellularSheaf
open Evidence.TransferTranscript
open TCB.PrimitiveChecks
open scoped ENNReal

variable {Vertex Edge Face Owner Asset Receipt Key Aux Coins : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

/-- Construct the selected byte-signature checker on the full existing intent. -/
def checker (codec : Evidence.TransferCheck.PacketCodec Owner) (metadata : ProofMetadata)
    (backend : SignatureVerifier Key) (keyFor : Owner → Key)
    (authorized : Owner → Intent Owner → Prop) : Evidence.TransferCheck.Authorization Owner where
  Authorized := authorized
  verify owner intent signature :=
    backend.verify (keyFor owner) (Signing.message codec metadata intent) signature

/-- Select this checker while retaining every original setup and semantic-policy field. -/
def configure (base : Operational.Config F Owner Asset Receipt)
    (backend : SignatureVerifier Key) (keyFor : Owner → Key) :
    Operational.Config F Owner Asset Receipt :=
  { base with
    authorization :=
      checker base.codec base.metadata backend keyFor base.authorization.Authorized }

theorem configure_context (base : Operational.Config F Owner Asset Receipt)
    (backend : SignatureVerifier Key) (keyFor : Owner → Key) :
    (configure base backend keyFor).context = base.context := rfl

theorem configure_intent (base : Operational.Config F Owner Asset Receipt)
    (backend : SignatureVerifier Key) (keyFor : Owner → Key)
    (transfer : Operational.ResourceTransfer Owner) :
    (configure base backend keyFor).intentFor transfer = base.intentFor transfer := rfl

theorem configure_policy [DecidableEq Asset] (base : Operational.Config F Owner Asset Receipt)
    (backend : SignatureVerifier Key) (keyFor : Owner → Key) :
    (configure base backend keyFor).policy = base.policy := rfl

theorem configure_candidate (base : Operational.Config F Owner Asset Receipt)
    (backend : SignatureVerifier Key) (keyFor : Owner → Key)
    (transfer : Operational.ResourceTransfer Owner) (packet : ProofPacket Owner) :
    (configure base backend keyFor).candidateFor transfer packet =
      base.candidateFor transfer packet := rfl

/-- The existing primitive profile now has a constructed, reflexive execution equation. -/
def signatureProfile (base : Operational.Config F Owner Asset Receipt)
    (backend : SignatureVerifier Key) (keyFor : Owner → Key)
    (records : List (Issuance.Issued base.authorization.Authorized))
    (foreignQueries : List (Key × Bytes)) (compromised : Key → Prop) :
    Primitives.SignatureProfile (configure base backend keyFor) Key where
  backend := backend
  keyFor := keyFor
  messageFor _ intent := Signing.message base.codec base.metadata intent
  history := Issuance.history base.codec keyFor records foreignQueries compromised
  agrees _ _ _ := rfl

/-- Reuse the same proof backend and its exact original-context execution equation. -/
def payloadProfile (base : Operational.Config F Owner Asset Receipt)
    (backend : SignatureVerifier Key) (keyFor : Owner → Key)
    (payload : Primitives.PayloadProfile base) :
    Primitives.PayloadProfile (configure base backend keyFor) where
  backend := payload.backend
  inputFor := payload.inputFor
  agrees := payload.agrees

/-- No queried message in this constructed history authorizes a different original intent. -/
theorem not_queriedUnauthorized (base : Operational.Config F Owner Asset Receipt)
    (backend : SignatureVerifier Key) (keyFor : Owner → Key)
    (records : List (Issuance.Issued base.authorization.Authorized))
    (foreignQueries : List (Key × Bytes)) (compromised : Key → Prop)
    (foreignOutside : ∀ key message, (key, message) ∈ foreignQueries → ¬ Signing.InDomain message)
    (attempt : Operational.Attempt Owner) :
    ¬ Primitives.QueriedUnauthorized
      (signatureProfile base backend keyFor records foreignQueries compromised) attempt := by
  rintro ⟨_packet, _parsed, _verified, queried, unauthorized⟩
  have authorized := Issuance.queried_authorized base.codec keyFor records foreignQueries
    compromised foreignOutside base.metadata (base.intentFor attempt.transfer) queried
  exact unauthorized authorized

/-- A record of this exact checked packet, with its independently supplied authorization. -/
def issueOfChecked (base : Operational.Config F Owner Asset Receipt)
    (backend : SignatureVerifier Key) (keyFor : Owner → Key)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer (configure base backend keyFor) transfer bytes)
    (authorized : base.authorization.Authorized transfer.signer (base.intentFor transfer)) :
    Issuance.Issued base.authorization.Authorized where
  metadata := checked.proof.packet.metadata
  intent := checked.proof.packet.intent
  signature := checked.proof.packet.ownerSignature
  authorization := by
    rw [checked.proof.intent_eq, configure_intent]
    exact authorized

/-- The retained signature is actually verified for this record's complete signed subject. -/
theorem issueOfChecked_verified (base : Operational.Config F Owner Asset Receipt)
    (backend : SignatureVerifier Key) (keyFor : Owner → Key)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer (configure base backend keyFor) transfer bytes)
    (authorized : base.authorization.Authorized transfer.signer (base.intentFor transfer)) :
    backend.verify (keyFor (issueOfChecked base backend keyFor checked authorized).intent.transfer.signer)
      (Signing.message base.codec (issueOfChecked base backend keyFor checked authorized).metadata
        (issueOfChecked base backend keyFor checked authorized).intent)
      (issueOfChecked base backend keyFor checked authorized).signature = true := by
  change backend.verify (keyFor checked.proof.packet.intent.transfer.signer)
    (Signing.message base.codec checked.proof.packet.metadata checked.proof.packet.intent)
    checked.proof.packet.ownerSignature = true
  rw [checked.proof.metadata_eq]
  exact checked.proof.signatureVerified

/-- Adding the record covers the exact parsed metadata, intent and actual signature bytes. -/
theorem issueOfChecked_covers (base : Operational.Config F Owner Asset Receipt)
    (backend : SignatureVerifier Key) (keyFor : Owner → Key)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer (configure base backend keyFor) transfer bytes)
    (authorized : base.authorization.Authorized transfer.signer (base.intentFor transfer))
    (records : List (Issuance.Issued base.authorization.Authorized)) :
    Issuance.Covers (issueOfChecked base backend keyFor checked authorized :: records)
      checked.proof.packet.metadata checked.proof.packet.intent checked.proof.packet.ownerSignature :=
  Issuance.covers_cons _ _

/-- Coverage names the existing release projection, including its exact signature bytes. -/
theorem issueOfChecked_covers_view (base : Operational.Config F Owner Asset Receipt)
    (backend : SignatureVerifier Key) (keyFor : Owner → Key)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer (configure base backend keyFor) transfer bytes)
    (authorized : base.authorization.Authorized transfer.signer (base.intentFor transfer))
    (records : List (Issuance.Issued base.authorization.Authorized)) :
    Issuance.Covers (issueOfChecked base backend keyFor checked authorized :: records)
      (Owned.PublicTransferView.ofOperational checked).metadata
      (Owned.PublicTransferView.ofOperational checked).packet.intent
      (Owned.PublicTransferView.ofOperational checked).packet.ownerSignature :=
  issueOfChecked_covers base backend keyFor checked authorized records

/-- Select the constructed checker in the existing sampled experiment. -/
def experiment (base : Security.Experiment F Owner Asset Receipt Aux Coins)
    (backend : SignatureVerifier Key) (keyFor : Owner → Key) :
    Security.Experiment F Owner Asset Receipt Aux Coins :=
  { base with config := configure base.config backend keyFor }

/-- Observation, auxiliary data, tape and adversary still determine the same attempt. -/
theorem experiment_attempt (base : Security.Experiment F Owner Asset Receipt Aux Coins)
    (backend : SignatureVerifier Key) (keyFor : Owner → Key) (coin : Coins) :
    (experiment base backend keyFor).attempt coin = base.attempt coin := rfl

/-- The queried-but-unauthorized mass vanishes for this exact constructed history. -/
theorem queriedUnauthorizedProbability_eq_zero
    (base : Security.Experiment F Owner Asset Receipt Aux Coins)
    (backend : SignatureVerifier Key) (keyFor : Owner → Key)
    (records : List (Issuance.Issued base.config.authorization.Authorized))
    (foreignQueries : List (Key × Bytes)) (compromised : Key → Prop)
    (foreignOutside : ∀ key message, (key, message) ∈ foreignQueries → ¬ Signing.InDomain message) :
    Primitives.Experiment.queriedUnauthorizedProbability (experiment base backend keyFor)
      (signatureProfile base.config backend keyFor records foreignQueries compromised) = 0 := by
  have empty : Primitives.Experiment.queriedUnauthorizedEvent (experiment base backend keyFor)
      (signatureProfile base.config backend keyFor records foreignQueries compromised) = ∅ := by
    apply Set.eq_empty_iff_forall_notMem.mpr
    intro coin member
    exact not_queriedUnauthorized base.config backend keyFor records foreignQueries compromised
      foreignOutside (base.attempt coin) member
  simp only [Primitives.Experiment.queriedUnauthorizedProbability, empty]
  exact MeasureTheory.measure_empty

/-- The existing five-event bound loses its queried-message policy-mismatch term. -/
theorem acceptedInvalidProbability_le [DecidableEq Asset]
    (base : Security.Experiment F Owner Asset Receipt Aux Coins)
    (backend : SignatureVerifier Key) (keyFor : Owner → Key)
    (records : List (Issuance.Issued base.config.authorization.Authorized))
    (foreignQueries : List (Key × Bytes)) (compromised : Key → Prop)
    (foreignOutside : ∀ key message, (key, message) ∈ foreignQueries → ¬ Signing.InDomain message)
    (payload : Primitives.PayloadProfile base.config) :
    (experiment base backend keyFor).acceptedInvalidProbability ≤
      Primitives.Experiment.forgeryProbability (experiment base backend keyFor)
        (signatureProfile base.config backend keyFor records foreignQueries compromised) +
      Primitives.Experiment.compromisedKeyProbability (experiment base backend keyFor)
        (signatureProfile base.config backend keyFor records foreignQueries compromised) +
      Primitives.Experiment.proofFalseAcceptProbability (experiment base backend keyFor)
        (payloadProfile base.config backend keyFor payload) +
      Primitives.Experiment.statementMismatchProbability (experiment base backend keyFor)
        (payloadProfile base.config backend keyFor payload) := by
  have bound := Primitives.Experiment.acceptedInvalidProbability_le (experiment base backend keyFor)
    (signatureProfile base.config backend keyFor records foreignQueries compromised)
    (payloadProfile base.config backend keyFor payload)
  rw [queriedUnauthorizedProbability_eq_zero base backend keyFor records foreignQueries
    compromised foreignOutside] at bound
  simpa only [add_zero] using bound

/-- Supplied bounds for the four remaining events compose in this configured experiment. -/
theorem acceptedInvalidProbability_le_of_bounds [DecidableEq Asset]
    (base : Security.Experiment F Owner Asset Receipt Aux Coins)
    (backend : SignatureVerifier Key) (keyFor : Owner → Key)
    (records : List (Issuance.Issued base.config.authorization.Authorized))
    (foreignQueries : List (Key × Bytes)) (compromised : Key → Prop)
    (foreignOutside : ∀ key message, (key, message) ∈ foreignQueries → ¬ Signing.InDomain message)
    (payload : Primitives.PayloadProfile base.config)
    {forgeryError compromisedError proofError statementError : ℝ≥0∞}
    (forgeryBound : Primitives.Experiment.forgeryProbability (experiment base backend keyFor)
      (signatureProfile base.config backend keyFor records foreignQueries compromised) ≤ forgeryError)
    (compromisedBound : Primitives.Experiment.compromisedKeyProbability
      (experiment base backend keyFor)
      (signatureProfile base.config backend keyFor records foreignQueries compromised) ≤ compromisedError)
    (proofBound : Primitives.Experiment.proofFalseAcceptProbability (experiment base backend keyFor)
      (payloadProfile base.config backend keyFor payload) ≤ proofError)
    (statementBound : Primitives.Experiment.statementMismatchProbability
      (experiment base backend keyFor) (payloadProfile base.config backend keyFor payload) ≤ statementError) :
    (experiment base backend keyFor).acceptedInvalidProbability ≤
      forgeryError + compromisedError + proofError + statementError :=
  (acceptedInvalidProbability_le base backend keyFor records foreignQueries compromised
    foreignOutside payload).trans
    (add_le_add (add_le_add (add_le_add forgeryBound compromisedBound) proofBound) statementBound)

end HomotopicalEncryption.Protocol.Transfer.Authorization
