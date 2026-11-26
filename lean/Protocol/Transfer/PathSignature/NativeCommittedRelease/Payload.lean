module

public import Protocol.Transfer.Certificates.Native
public import Protocol.Transfer.PathSignature.NativeCommittedRelease.Checked
public import Protocol.Transfer.PathSignature.NativeCommittedRelease.HonestEvidence
public import Protocol.Transfer.PathSignature.NativeCommittedRandomOracle.PublicContinuation

@[expose] public section

/-!
# Generating proof bytes for the native release payload

The payload prover uses the existing native certificate subject. Its digest
comes from a query on the full ciphertext in the shared byte oracle. The
prover receives private certificate witness bytes from the selected encoder
and samples its own proof randomness. A missing certificate witness gives
no proof.

For an original bound observation, an encoder that realizes the selected
proof relation and an honestly set up, correct primitive give acceptance
by the operational payload checker on the exact bytes generated here.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRelease.Payload

open OracleComp
open OracleSpec
open Sheaf CellularSheaf HCPCoupledFamily
open Evidence.TransferTranscript
open NativeCommittedRandomOracle (PublicSpec publicOnly resumePublicState)
open Storage.OperatorCommitment.RandomOracle (publicOracle)

abbrev Bytes := List UInt8

variable {Owner Advice Seed Reference Trapdoor Randomness : Type}
  {rows cols : ℕ}

/-- The existing native certificate subject, with its actual intent and digest. -/
def subject (rows cols : ℕ) (metadata : ProofMetadata) (intent : Intent Owner)
    (ciphertextDigest : TCB.Hash32) : Certificates.Codec.Subject Owner :=
  ⟨metadata, intent, ciphertextDigest, Certificates.Native.publicProfile rows cols,
    none, .nativeCiphertext⟩

def proofBytes (primitive : CRS.Primitive Seed Reference Trapdoor Randomness)
    (reference : Reference) (codec : Evidence.TransferCheck.PacketCodec Owner)
    (publicSubject : Certificates.Codec.Subject Owner) (witness : Bytes)
    (randomness : Randomness) : Bytes :=
  primitive.prove reference (Certificates.Codec.encode codec publicSubject) witness randomness

/-- Build the native certificate proof after the ciphertext digest is known. -/
def proveAt (rows cols : ℕ) (primitive : CRS.Primitive Seed Reference Trapdoor Randomness)
    (reference : Reference) (setup : Owned.PublicAssemblySetup Owner)
    (intent : Intent Owner) (ciphertextDigest : TCB.Hash32) (witness : Option Bytes)
    (randomness : Randomness) : Option Bytes :=
  witness.map fun bytes =>
    proofBytes primitive reference setup.codec
      (subject rows cols setup.metadata intent ciphertextDigest) bytes randomness

/-- The private encoder may use the native opening and the original ciphertext
to select the certificate witness. The digest is read through the same oracle
as the three native instance names. -/
def producer [SampleableType Randomness]
    (primitive : CRS.Primitive Seed Reference Trapdoor Randomness)
    (referenceFor : Advice → Reference) (inputs : Advice → Inputs Owner)
    (encodeWitness : Advice → NativeCommitted.Witness rows cols → Intent Owner → Bytes →
      Option Bytes) : HonestEvidence.PayloadProducer Owner Advice rows cols :=
  fun advice witness intent ciphertext => do
    let digest ← PublicSpec.query (.inr ciphertext)
    let randomness ← (liftM ($ᵗ Randomness) : OracleComp PublicSpec Randomness)
    pure (proveAt rows cols primitive (referenceFor advice) (inputs advice).setup
      intent digest (encodeWitness advice witness intent ciphertext) randomness)

theorem producer_query_bound [SampleableType Randomness]
    (primitive : CRS.Primitive Seed Reference Trapdoor Randomness)
    (referenceFor : Advice → Reference) (inputs : Advice → Inputs Owner)
    (encodeWitness : Advice → NativeCommitted.Witness rows cols → Intent Owner → Bytes →
      Option Bytes) (advice : Advice) (witness : NativeCommitted.Witness rows cols)
    (intent : Intent Owner) (ciphertext : Bytes) :
    IsQueryBoundP (producer primitive referenceFor inputs encodeWitness advice witness intent
      ciphertext) publicOnly 1 := by
  unfold producer
  rw [isQueryBoundP_query_bind_iff]
  refine ⟨Or.inr (by decide), fun _ => ?_⟩
  rw [ite_eq_left (show publicOnly (.inr ciphertext) from trivial)]
  have sampling : IsQueryBoundP (liftM ($ᵗ Randomness) : OracleComp PublicSpec Randomness)
      publicOnly 0 :=
    IsQueryBoundP.of_imp (fun query h => by cases query <;> simp_all [publicOnly])
      (isQueryBoundP_liftM_isRight _)
  exact isQueryBoundP_bind_zero _ _ sampling (fun _ => by simp)

/-- Reading the already named ciphertext uses its cached digest and leaves the
oracle cache unchanged, including when the private encoder returns no proof. -/
theorem producer_run_cached [SampleableType Randomness]
    (primitive : CRS.Primitive Seed Reference Trapdoor Randomness)
    (referenceFor : Advice → Reference) (inputs : Advice → Inputs Owner)
    (encodeWitness : Advice → NativeCommitted.Witness rows cols → Intent Owner → Bytes →
      Option Bytes) (advice : Advice) (witness : NativeCommitted.Witness rows cols)
    (intent : Intent Owner) (ciphertext : Bytes)
    (cache : publicOracle.QueryCache) (digest : TCB.Hash32)
    (cached : cache ciphertext = some digest) :
    resumePublicState (producer primitive referenceFor inputs encodeWitness advice witness intent
      ciphertext) cache =
      (fun randomness =>
        (proveAt rows cols primitive (referenceFor advice) (inputs advice).setup intent digest
          (encodeWitness advice witness intent ciphertext) randomness, cache)) <$>
          ($ᵗ Randomness : ProbComp Randomness) := by
  simp only [resumePublicState, producer, simulateQ_bind, StateT.run_bind,
    simulateQ_spec_query, romImpl_apply_inr, randomOracle.run_eq, cached, pure_bind,
    bind_pure_comp, simulateQ_map, StateT.run_map, simulateQ_romImpl_liftM_run, Functor.map_map]

variable {Asset Receipt PublicClass Lifecycle : Type}
  {B : Matrix (Fin rows) (Fin cols) ℤ}
  {payload : CochainPayloadInterpretation (sheaf B)}
  {classify : SheafStateSnapshot (sheaf B) → PublicClass}
  {Binds : TCB.HCPStackBinding Lifecycle PublicClass (C1 (Fin rows) (Fin cols))}

/-- The exact subject produced from the expected packet is the one selected by
the operational native verifier. -/
theorem subject_eq_expected (base : Operational.Config (sheaf B) Owner Asset Receipt)
    (transfer : Operational.ResourceTransfer Owner) :
    subject rows cols base.metadata (base.intentFor transfer) base.ciphertextDigest =
      Certificates.Statement.subjectFor base (Certificates.Native.publicProfile rows cols)
        none .nativeCiphertext (base.intentFor transfer) := rfl

/-- For every proof random tape, the native payload checker accepts the bytes
generated from an original bound observation whose private encoding is valid
for the selected proof relation. -/
theorem proofBytes_complete
    (base : Operational.Config (sheaf B) Owner Asset Receipt)
    (transfer : Operational.ResourceTransfer Owner)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32)
    (observation : TCB.BoundHCPObservation (integralStructure B)
      payload PublicClass Lifecycle classify Binds)
    (binding : Storage.NativeManifest.BindsOriginal base.manifest observation identify parameters)
    (primitive : CRS.Primitive Seed Reference Trapdoor Randomness)
    (relation : Bytes → Bytes → Bool) (correct : CRS.Correct primitive relation)
    (seed : Seed) (encode : TCB.BoundHCPObservation (integralStructure B)
      payload PublicClass Lifecycle classify Binds → Bytes)
    (realizes : ∀ actualSubject,
      Certificates.Native.Meaning base identify parameters actualSubject observation →
        relation (Certificates.Codec.encode base.codec actualSubject) (encode observation) = true)
    (randomness : Randomness) :
    (Certificates.Native.config base (primitive.verify (primitive.setup seed))).payload.verify
      (base.intentFor transfer)
      (proofBytes primitive (primitive.setup seed) base.codec
        (subject rows cols base.metadata (base.intentFor transfer) base.ciphertextDigest)
        (encode observation) randomness) = true := by
  rw [subject_eq_expected]
  exact correct seed _ _ randomness
    (realizes _ ((Certificates.Native.expected_meaning_iff base identify parameters
      transfer observation).2 binding))

/-- The release producer and the operational checker use the same subject.
On a successful private encoding, the actual generated proof passes the
payload check for every sampled proof tape. -/
theorem proveAt_complete
    (base : Operational.Config (sheaf B) Owner Asset Receipt) (inputs : Inputs Owner)
    (prechecks : Operational.Prechecks base inputs.transfer)
    (aligned : inputs.MatchesConfig base) (credentialFor : Owner → TCB.Hash32)
    (publicInput : NativeCommitted.Instance)
    (parsed : NativeCommitted.decodeInstance
      (NativeCommittedContext.contextKeyFor base credentialFor inputs.transfer.signer) =
      some publicInput)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32)
    (observation : TCB.BoundHCPObservation (integralStructure B)
      payload PublicClass Lifecycle classify Binds)
    (binding : Storage.NativeManifest.BindsOriginal base.manifest observation identify parameters)
    (primitive : CRS.Primitive Seed Reference Trapdoor Randomness)
    (relation : Bytes → Bytes → Bool) (correct : CRS.Correct primitive relation)
    (seed : Seed) (encode : TCB.BoundHCPObservation (integralStructure B)
      payload PublicClass Lifecycle classify Binds → Bytes)
    (realizes : ∀ actualSubject,
      Certificates.Native.Meaning base identify parameters actualSubject observation →
        relation (Certificates.Codec.encode base.codec actualSubject) (encode observation) = true)
    (randomness : Randomness) :
    ∃ bytes, proveAt rows cols primitive (primitive.setup seed) inputs.setup
      (inputs.intentAt publicInput) publicInput.ciphertextDigest
      (some (encode observation)) randomness = some bytes ∧
      (Certificates.Native.config base (primitive.verify (primitive.setup seed))).payload.verify
        (base.intentFor inputs.transfer) bytes = true := by
  obtain ⟨setup, _, digest⟩ := inputs.matches_at prechecks aligned credentialFor publicInput parsed
  have codec : base.codec = inputs.setup.codec := congrArg Owned.PublicAssemblySetup.codec setup
  have metadata : base.metadata = inputs.setup.metadata :=
    congrArg Owned.PublicAssemblySetup.metadata setup
  rw [inputs.intentAt_eq_config prechecks aligned credentialFor publicInput parsed, ← digest]
  refine ⟨proofBytes primitive (primitive.setup seed) base.codec
    (subject rows cols base.metadata (base.intentFor inputs.transfer) base.ciphertextDigest)
    (encode observation) randomness, ?_, ?_⟩
  · simp only [proveAt, Option.map_some, ← codec, ← metadata]
  · exact proofBytes_complete base inputs.transfer identify parameters observation binding
      primitive relation correct seed encode realizes randomness

variable {OwnerSeed VerifierKey PublicCRS OwnerTrapdoor OwnerRandomness Validator Signature : Type}
  [DecidableEq Validator] {committee : Consensus.Committee Validator}
  {authentication : Consensus.VoteAuthentication Validator Signature} {hash : Bytes → TCB.Hash32}

/-- Both generated proofs pass the original operational check when their
relations, setup, and approved profile match the original transfer. -/
theorem check_generated
    (base : Operational.Config (sheaf B) Owner Asset Receipt) (inputs : Inputs Owner)
    (prechecks : Operational.Prechecks base inputs.transfer)
    (aligned : inputs.MatchesConfig base) (credentialFor : Owner → TCB.Hash32)
    (publicInput : NativeCommitted.Instance)
    (parsed : NativeCommitted.decodeInstance
      (NativeCommittedContext.contextKeyFor base credentialFor inputs.transfer.signer) =
      some publicInput)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32)
    (observation : TCB.BoundHCPObservation (integralStructure B)
      payload PublicClass Lifecycle classify Binds)
    (binding : Storage.NativeManifest.BindsOriginal base.manifest observation identify parameters)
    (primitive : CRS.Primitive Seed Reference Trapdoor Randomness)
    (relation : Bytes → Bytes → Bool) (correct : CRS.Correct primitive relation)
    (seed : Seed) (encode : TCB.BoundHCPObservation (integralStructure B)
      payload PublicClass Lifecycle classify Binds → Bytes)
    (realizes : ∀ actualSubject,
      Certificates.Native.Meaning base identify parameters actualSubject observation →
        relation (Certificates.Codec.encode base.codec actualSubject) (encode observation) = true)
    (randomness : Randomness)
    (approval : Certificates.Profile.Approval committee authentication hash)
    (program : NativeCommitted.Program)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeCommitted.Program →
      CRS.Primitive OwnerSeed (VerifierKey × PublicCRS) OwnerTrapdoor OwnerRandomness)
    (ownerCorrect : CRS.Correct (family program) (NativeCommitted.relation program hash))
    (ownerSeed : OwnerSeed) (ownerRandomness : OwnerRandomness)
    (applicable : approval.appliesConfig base (NativeCommitted.encodeProgram program) none none = true)
    (selected : Certificates.Profile.select NativeCommitted.decodeProgram parseKey parseCRS
      approval.descriptor =
        some (program, ((family program).setup ownerSeed).1, ((family program).setup ownerSeed).2))
    (witness : NativeCommitted.Witness program.rows program.cols)
    (bounded : NativeRelation.Bounded program.profile witness.native)
    (names : NativeCommitted.instanceFor hash witness = publicInput) :
    let payloadConfig := Certificates.Native.config base (primitive.verify (primitive.setup seed))
    let config := NativeCommittedContext.configure approval payloadConfig program
      parseKey parseCRS family credentialFor
    let ownerBytes := HonestEvidence.ownerSignature (family program) ((family program).setup ownerSeed)
      (inputs.signingInputAt publicInput) witness ownerRandomness
    ∃ bytes, proveAt rows cols primitive (primitive.setup seed) inputs.setup
      (inputs.intentAt publicInput) publicInput.ciphertextDigest
      (some (encode observation)) randomness = some bytes ∧
      Operational.check config inputs.transfer
        (inputs.assemble publicInput ownerBytes bytes).packetBytes = true := by
  intro payloadConfig config ownerBytes
  obtain ⟨bytes, produced, payloadVerified⟩ :=
    proveAt_complete base inputs prechecks aligned credentialFor publicInput parsed
      identify parameters observation binding primitive relation correct seed encode realizes randomness
  have payloadPrechecks : Operational.Prechecks payloadConfig inputs.transfer :=
    ⟨prechecks.resources, prechecks.snapshotMatches, prechecks.leafMatches⟩
  have payloadAligned : inputs.MatchesConfig payloadConfig := ⟨aligned.setup, aligned.base⟩
  have ownerVerified := HonestEvidence.ownerSignature_complete program family hash ownerCorrect
    ownerSeed ((family program).setup ownerSeed) rfl inputs publicInput witness bounded names
    ownerRandomness
  have exactCode := (NativeCommitted.decodeProgram_eq_some_iff _ _).mp
    ((Certificates.Profile.select_eq_some_iff _ _ _ _ _ _ _).mp selected).1
  have approved := inputs.approved_ownerSignature_verified payloadPrechecks payloadAligned
    credentialFor publicInput parsed approval program parseKey parseCRS family
    ((family program).setup ownerSeed) exactCode applicable selected ownerBytes ownerVerified
  have configPrechecks : Operational.Prechecks config inputs.transfer :=
    ⟨prechecks.resources, prechecks.snapshotMatches, prechecks.leafMatches⟩
  have configAligned : inputs.MatchesConfig config := ⟨aligned.setup, aligned.base⟩
  exact ⟨bytes, produced, inputs.check_assemble configPrechecks configAligned
    credentialFor publicInput parsed ownerBytes bytes approved payloadVerified⟩

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRelease.Payload
