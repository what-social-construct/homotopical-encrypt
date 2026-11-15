module

public import Protocol.Transfer.PathSignature.NativeContext

@[expose] public section

/-!
# Checked fresh native packets from actual adaptive CRS output

The adapter reads the actual returned target, parses its complete canonical
owner-signing message, and reconstructs the original transfer packet using
that target's proof as the owner signature. The separate payload proof is
supplied explicitly. A public key guard restricts completion to the challenged
credential without equating different owners or assuming an injective key map.

The existing operational checker still performs every original resource,
metadata, intent, signature and payload-proof check. Acceptance of a completed
fresh output implies a win in the same generated CRS transcript when the
approved parsed reference is the primitive's actual setup output. Neither the
output nor its query history is supplied independently of that transcript.

This bounds the explicit single-credential packet-completion experiment. It
does not classify every accepted transfer as a forgery or supply a compiler
from arbitrary packet-producing adversaries. General accepted-invalid
integrity retains its policy, compromise and payload-failure branches. The
primitive, hybrid, extraction, recovery and collision estimates remain explicit.
Additional public application data belongs in the declared auxiliary remainder;
this adapter does not assert a complete storage-view privacy theorem.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeApplication

open Sheaf CellularSheaf
open Evidence.TransferTranscript
open scoped ENNReal

abbrev Bytes := List UInt8

variable {Owner : Type}

/-- Rebuild the original packet, retaining its complete signed subject and
using exactly the returned proof as its owner signature. -/
def packetFor (packet : ProofPacket Owner) (target : CRS.Target) (payloadProof : Bytes) :
    ProofPacket Owner :=
  { packet with ownerSignature := target.proof, proofBytes := payloadProof }

/-- Complete only canonical full signing messages for the challenged key.
Malformed messages and outputs for another owner key produce no attempt. -/
def completeTarget (codec : Evidence.TransferCheck.PacketCodec Owner)
    (keyFor : Owner → Bytes) (key payloadProof : Bytes) (target : CRS.Target) :
    Option (Operational.Attempt Owner) := do
  let packet ← codec.decode (target.message.drop Signing.domain.length)
  if target.message = Signing.message codec packet.metadata packet.intent ∧
      keyFor packet.intent.transfer.signer = key then
    some ⟨packet.intent.transfer, codec.encode (packetFor packet target payloadProof)⟩
  else none

/-- Canonical signing messages for the selected key reconstruct an actual
original packet; the completion adapter is not an always-rejecting filter. -/
theorem completeTarget_signing (codec : Evidence.TransferCheck.PacketCodec Owner)
    (keyFor : Owner → Bytes) (metadata : ProofMetadata) (intent : Intent Owner)
    (signature payloadProof : Bytes) :
    completeTarget codec keyFor (keyFor intent.transfer.signer) payloadProof
      ⟨Signing.message codec metadata intent, signature⟩ =
      some ⟨intent.transfer, codec.encode
        ⟨metadata, intent, signature, payloadProof⟩⟩ := by
  simp [completeTarget, Signing.message, codec.decode_encode, Signing.skeleton, packetFor]

/-- The same actual canonical subject is rejected for another challenged key,
without requiring equality or injectivity of owner identities. -/
theorem completeTarget_rejects_other_key (codec : Evidence.TransferCheck.PacketCodec Owner)
    (keyFor : Owner → Bytes) (key : Bytes) (metadata : ProofMetadata) (intent : Intent Owner)
    (signature payloadProof : Bytes) (wrong : keyFor intent.transfer.signer ≠ key) :
    completeTarget codec keyFor key payloadProof
      ⟨Signing.message codec metadata intent, signature⟩ = none := by
  simp [completeTarget, Signing.message, codec.decode_encode, Signing.skeleton, wrong]

theorem completeTarget_eq_some_iff (codec : Evidence.TransferCheck.PacketCodec Owner)
    (keyFor : Owner → Bytes) (key payloadProof : Bytes) (target : CRS.Target)
    (attempt : Operational.Attempt Owner) :
    completeTarget codec keyFor key payloadProof target = some attempt ↔
      ∃ packet, codec.decode (target.message.drop Signing.domain.length) = some packet ∧
        target.message = Signing.message codec packet.metadata packet.intent ∧
        keyFor packet.intent.transfer.signer = key ∧
        attempt = ⟨packet.intent.transfer, codec.encode (packetFor packet target payloadProof)⟩ := by
  cases decoded : codec.decode (target.message.drop Signing.domain.length) with
  | none => simp [completeTarget, decoded]
  | some packet =>
    have run : completeTarget codec keyFor key payloadProof target =
        if target.message = Signing.message codec packet.metadata packet.intent ∧
            keyFor packet.intent.transfer.signer = key then
          some ⟨packet.intent.transfer, codec.encode (packetFor packet target payloadProof)⟩
        else none := by
      unfold completeTarget
      rw [decoded]
      rfl
    rw [run]
    constructor
    · intro accepted
      split at accepted
      next valid => exact ⟨packet, rfl, valid.1, valid.2, (Option.some.inj accepted).symm⟩
      next => cases accepted
    · rintro ⟨other, otherDecoded, messageEq, keyEq, attemptEq⟩
      have same : other = packet := (Option.some.inj otherDecoded).symm
      subst other
      simp only [messageEq, keyEq, and_self, ite_true, ← attemptEq]

variable {Vertex Edge Face Asset Receipt : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

/-- Original parsing and checking force the completed target to be exactly
the actual expected subject, signature and selected signer key. -/
theorem checked_completeTarget_subject
    (config : Operational.Config F Owner Asset Receipt) (keyFor : Owner → Bytes)
    (key payloadProof : Bytes) (target : CRS.Target) (attempt : Operational.Attempt Owner)
    (completed : completeTarget config.codec keyFor key payloadProof target = some attempt)
    (checked : Operational.CheckedTransfer config attempt.transfer attempt.bytes) :
    target.message = Signing.message config.codec config.metadata (config.intentFor attempt.transfer) ∧
      target.proof = checked.proof.packet.ownerSignature ∧ keyFor attempt.transfer.signer = key := by
  obtain ⟨packet, _decoded, messageEq, keyEq, rfl⟩ :=
    (completeTarget_eq_some_iff config.codec keyFor key payloadProof target attempt).1 completed
  have parsed : checked.proof.packet = packetFor packet target payloadProof :=
    Option.some.inj (checked.proof.decoded.symm.trans (config.codec.decode_encode _))
  have metadataEq : packet.metadata = config.metadata := by
    simpa only [parsed, packetFor] using checked.proof.metadata_eq
  have intentEq : packet.intent = config.intentFor packet.intent.transfer := by
    simpa only [parsed, packetFor] using checked.proof.intent_eq
  refine ⟨?_, ?_, keyEq⟩
  · exact messageEq.trans (congrArg₂ (Signing.message config.codec) metadataEq intentEq)
  · simp only [parsed, packetFor]

/-- This event uses the actual returned target and generated freshness log.
The operational acceptance is for the original reconstructed packet. -/
def FreshChecked (config : Operational.Config F Owner Asset Receipt)
    (keyFor : Owner → Bytes) {Reference : Type} (transcript : CRS.Transcript Reference)
    (payloadProof : Bytes) : Prop :=
  ∃ target attempt, transcript.execution.output = some target ∧
    completeTarget config.codec keyFor transcript.key payloadProof target = some attempt ∧
    CRS.Fresh transcript target ∧ Operational.check config attempt.transfer attempt.bytes = true

variable {Seed VerifierKey PublicCRS Trapdoor Randomness Validator : Type}
  [DecidableEq Validator]
  {committee : Consensus.Committee Validator}
  {authentication : Consensus.VoteAuthentication Validator Bytes}
  {hash : Bytes → TCB.Hash32}

/-- Actual checked completion supplies the precise primitive verification
needed by the same transcript, not an assumed verified-implies-witness rule. -/
theorem freshChecked_implies_wins
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt) (program : NativeProgram.Program)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (credentialFor : Owner → TCB.Hash32) (seed : Seed)
    (transcript : CRS.Transcript (VerifierKey × PublicCRS)) (payloadProof : Bytes)
    (reference : transcript.reference = (family program).setup seed)
    (setupKey : parseKey approval.descriptor.verifierKey = some ((family program).setup seed).1)
    (setupCRS : parseCRS approval.descriptor.publicCRS = some ((family program).setup seed).2)
    (accepted : FreshChecked
      (NativeRegistered.configure approval base program parseKey parseCRS family credentialFor)
      (NativeRegistered.contextKeyFor base credentialFor) transcript payloadProof) :
    CRS.Wins (family program) transcript := by
  obtain ⟨target, attempt, returned, completed, fresh, checkedBool⟩ := accepted
  let checked := Operational.CheckedTransfer.ofCheck checkedBool
  obtain ⟨messageEq, proofEq, keyEq⟩ := checked_completeTarget_subject
    (NativeRegistered.configure approval base program parseKey parseCRS family credentialFor)
    (NativeRegistered.contextKeyFor base credentialFor) transcript.key payloadProof target attempt
    completed checked
  change target.message = Signing.message base.codec base.metadata (base.intentFor attempt.transfer) at messageEq
  have verified := NativeContext.checked_verifies_real_setup approval base program parseKey parseCRS
    family credentialFor seed setupKey setupCRS checked
  refine ⟨target, returned, fresh, ?_⟩
  rw [reference, messageEq, proofEq, ← keyEq]
  exact verified

variable {Aux AdversaryCoins Coins : Type}

/-- Select the actual primitive family by construction, retaining the original
PMF, adaptive adversary and random tapes through the preferred full-view game. -/
def experiment
    (template : CRS.Experiment Seed (VerifierKey × PublicCRS) Trapdoor Randomness
      (Bytes × Aux) AdversaryCoins Coins)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) :=
  NativeSecurity.fullViewExperiment { template with primitive := family program } program hash challenge

theorem experiment_primitive
    (template : CRS.Experiment Seed (VerifierKey × PublicCRS) Trapdoor Randomness
      (Bytes × Aux) AdversaryCoins Coins)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) :
    (experiment template family program hash challenge).primitive = family program := rfl

theorem experiment_coins
    (template : CRS.Experiment Seed (VerifierKey × PublicCRS) Trapdoor Randomness
      (Bytes × Aux) AdversaryCoins Coins)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) :
    (experiment template family program hash challenge).coins = template.coins := rfl

theorem experiment_real_reference
    (template : CRS.Experiment Seed (VerifierKey × PublicCRS) Trapdoor Randomness
      (Bytes × Aux) AdversaryCoins Coins)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) (coin : Coins) :
    ((experiment template family program hash challenge).realTranscript coin).reference =
      (family program).setup (template.setupSeed coin) := rfl

/-- The game's actually released full ciphertext is the original application's
selected ciphertext under its canonical sample-byte equation. -/
theorem experiment_ciphertext_eq
    (template : CRS.Experiment Seed (VerifierKey × PublicCRS) Trapdoor Randomness
      (Bytes × Aux) AdversaryCoins Coins)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) (coin : Coins)
    (base : Operational.Config F Owner Asset Receipt)
    (sample : base.ciphertext = Storage.CoupledCiphertext.sampleBytes (challenge coin).target
      (challenge coin).z (challenge coin).a (challenge coin).u) :
    ((experiment template family program hash challenge).auxiliary coin).1 = base.ciphertext :=
  NativeContext.fullView_ciphertext_eq { template with primitive := family program }
    program hash challenge coin base sample

section Sampled

variable
    (template : CRS.Experiment Seed (VerifierKey × PublicCRS) Trapdoor Randomness
      (Bytes × Aux) AdversaryCoins Coins)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols)
    (sheaves : Coins → CellularSheaf X)
    (approvalFor : Coins → Certificates.Profile.Approval committee authentication hash)
    (baseFor : ∀ coin, Operational.Config (sheaves coin) Owner Asset Receipt)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (credentialFor : Coins → Owner → TCB.Hash32) (payloadProof : Coins → Bytes)

/-- The existing five event masses, evaluated on the same selected primitive,
full-ciphertext experiment and PMF. This is an error sum, not an estimate. -/
def errorBudget (hybridError : ℝ≥0∞) : ℝ≥0∞ :=
  hybridError + (experiment template family program hash challenge).extractionFailureProbability +
    NativeSecurity.targetRecoveryProbability
      (NativeSecurity.withCiphertextView { template with primitive := family program } challenge)
      program hash challenge +
    NativeSecurity.snapshotCollisionProbability
      (NativeSecurity.withCiphertextView { template with primitive := family program } challenge)
      program hash challenge +
    NativeSecurity.ciphertextCollisionProbability
      (NativeSecurity.withCiphertextView { template with primitive := family program } challenge)
      program hash challenge

/-- Accepted fresh completions of this actual adaptive experiment, with no
independently supplied output, history or event-subset contract. -/
def freshCheckedEvent : Set Coins :=
  {coin | FreshChecked
    (NativeRegistered.configure (approvalFor coin) (baseFor coin) program parseKey parseCRS family
      (credentialFor coin))
    (NativeRegistered.contextKeyFor (baseFor coin) (credentialFor coin))
    ((experiment template family program hash challenge).realTranscript coin) (payloadProof coin)}

def freshCheckedProbability : ℝ≥0∞ :=
  template.coins.toOuterMeasure
    (freshCheckedEvent template family program hash challenge sheaves approvalFor baseFor
      parseKey parseCRS credentialFor payloadProof)

/-- The same setup seed and actual approved parser results link each checked
application output to the existing experiment's own winning event. -/
theorem freshChecked_implies_real_win
    (setupKey : ∀ coin, parseKey (approvalFor coin).descriptor.verifierKey =
      some ((family program).setup (template.setupSeed coin)).1)
    (setupCRS : ∀ coin, parseCRS (approvalFor coin).descriptor.publicCRS =
      some ((family program).setup (template.setupSeed coin)).2)
    (coin : Coins)
    (accepted : coin ∈ freshCheckedEvent template family program hash challenge sheaves
      approvalFor baseFor parseKey parseCRS credentialFor payloadProof) :
    CRS.Wins (experiment template family program hash challenge).primitive
      ((experiment template family program hash challenge).realTranscript coin) := by
  rw [experiment_primitive]
  exact freshChecked_implies_wins (approvalFor coin) (baseFor coin) program parseKey parseCRS
    family (credentialFor coin) (template.setupSeed coin) _ (payloadProof coin)
    (experiment_real_reference template family program hash challenge coin)
    (setupKey coin) (setupCRS coin) accepted

/-- Event transfer uses the original PMF; neither a new history distribution
nor an independence assumption is introduced. -/
theorem freshCheckedProbability_le_forgery
    (setupKey : ∀ coin, parseKey (approvalFor coin).descriptor.verifierKey =
      some ((family program).setup (template.setupSeed coin)).1)
    (setupCRS : ∀ coin, parseCRS (approvalFor coin).descriptor.publicCRS =
      some ((family program).setup (template.setupSeed coin)).2) :
    freshCheckedProbability template family program hash challenge sheaves approvalFor baseFor
      parseKey parseCRS credentialFor payloadProof ≤
      (experiment template family program hash challenge).realForgeryProbability := by
  change template.coins.toOuterMeasure _ ≤
    ((experiment template family program hash challenge).coins.map
      (experiment template family program hash challenge).realTranscript).toOuterMeasure _
  rw [PMF.toOuterMeasure_map_apply, experiment_coins]
  exact MeasureTheory.measure_mono (fun coin accepted =>
    freshChecked_implies_real_win template family program hash challenge sheaves approvalFor
      baseFor parseKey parseCRS credentialFor payloadProof setupKey setupCRS coin accepted)

/-- Actual fresh checked application packets inherit the five-term native
bound under the same winning-test hybrid and actual setup parsing equations.
This supplies the application event inclusion rather than assuming it. -/
theorem freshCheckedProbability_le_native
    (setupKey : ∀ coin, parseKey (approvalFor coin).descriptor.verifierKey =
      some ((family program).setup (template.setupSeed coin)).1)
    (setupCRS : ∀ coin, parseCRS (approvalFor coin).descriptor.publicCRS =
      some ((family program).setup (template.setupSeed coin)).2)
    {hybridError : ℝ≥0∞}
    (hybrid : (experiment template family program hash challenge).WinningHybrid hybridError) :
    freshCheckedProbability template family program hash challenge sheaves approvalFor baseFor
      parseKey parseCRS credentialFor payloadProof ≤
      errorBudget template family program hash challenge hybridError :=
  (freshCheckedProbability_le_forgery template family program hash challenge sheaves approvalFor
    baseFor parseKey parseCRS credentialFor payloadProof setupKey setupCRS).trans
      (NativeSecurity.fullView_real_forgery_probability_le_of_winning_hybrid
        { template with primitive := family program } program hash challenge hybrid)

end Sampled

/-- The preferred original native source profile is joined to the same game
and application event. The selected owner's key, actually released full
ciphertext and the bound are all derived together from the original objects.
The public key guard still handles the adversary's actual chosen signer. -/
theorem nativeSource_application_bound
    (template : CRS.Experiment Seed (VerifierKey × PublicCRS) Trapdoor Randomness
      (Bytes × Aux) AdversaryCoins Coins)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols)
    (approvalFor : Coins → Certificates.Profile.Approval committee authentication hash)
    (baseFor : ∀ coin, Operational.Config
      (HCPCoupledFamily.sheaf (challenge coin).target) Owner Asset Receipt)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (credentialFor : Coins → Owner → TCB.Hash32) (ownerFor : Coins → Owner)
    (payloadProof : Coins → Bytes)
    (credential : ∀ coin, credentialFor coin (ownerFor coin) =
      hash (NativeRelation.credentialBytes (challenge coin)))
    (snapshot : ∀ coin, Storage.CoupledBinding.BindsSnapshot hash (challenge coin).target
      (baseFor coin).context.interpretation.snapshot)
    (sample : ∀ coin, (baseFor coin).ciphertext = Storage.CoupledCiphertext.sampleBytes
      (challenge coin).target (challenge coin).z (challenge coin).a (challenge coin).u)
    (ciphertextHash : ∀ coin, (baseFor coin).hashes.ciphertext (baseFor coin).ciphertext =
      hash (baseFor coin).ciphertext)
    (setupKey : ∀ coin, parseKey (approvalFor coin).descriptor.verifierKey =
      some ((family program).setup (template.setupSeed coin)).1)
    (setupCRS : ∀ coin, parseCRS (approvalFor coin).descriptor.publicCRS =
      some ((family program).setup (template.setupSeed coin)).2)
    {hybridError : ℝ≥0∞}
    (hybrid : (experiment template family program hash challenge).WinningHybrid hybridError) :
    (∀ coin,
      NativeRegistered.contextKeyFor (baseFor coin) (credentialFor coin) (ownerFor coin) =
        (experiment template family program hash challenge).key coin ∧
      ((experiment template family program hash challenge).auxiliary coin).1 = (baseFor coin).ciphertext) ∧
    freshCheckedProbability template family program hash challenge
      (fun coin => HCPCoupledFamily.sheaf (challenge coin).target) approvalFor baseFor
      parseKey parseCRS credentialFor payloadProof ≤
      errorBudget template family program hash challenge hybridError := by
  refine ⟨?_, freshCheckedProbability_le_native template family program hash challenge
    (fun coin => HCPCoupledFamily.sheaf (challenge coin).target) approvalFor baseFor
    parseKey parseCRS credentialFor payloadProof setupKey setupCRS hybrid⟩
  intro coin
  refine ⟨?_, experiment_ciphertext_eq template family program hash challenge coin (baseFor coin) (sample coin)⟩
  exact NativeContext.contextKeyFor_instance (challenge coin) hash (baseFor coin) (credentialFor coin)
    (ownerFor coin) (credential coin) (snapshot coin) (sample coin) (ciphertextHash coin)

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeApplication
