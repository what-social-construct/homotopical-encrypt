module

public import Protocol.Transfer.PathSignature.Registered
public import Protocol.Evidence.TransferCodec

@[expose] public section

/-!
# Approved native signing for the actual transfer context

The public native key is derived from the existing owner's credential name,
the original context's snapshot root and the selected full-ciphertext digest.
No independent target snapshot or ciphertext name can be supplied to this
constructor. The owner's original credential map is retained; the derived key
adds the two original context coordinates without defining a new registry.

The checker also compares the approved program bytes with the exact expected
canonical native program. The selected public profile is those same program
bytes, with native scope and no radius calibration. Successful packet checking
therefore uses that actual program and the approved parsed verifier key/CRS,
on the original full signing message and owner-signature bytes.

This is a public-name/code binding, not a proof of hash security, credential
ownership, honest CRS generation or knowledge soundness. Native relation
refinement and the CRS primitive security games retain their separate roles.
The general isometric path decoder/realization is not inferred from this
nonisometric native construction. The original packet codec is not replaced;
the concrete byte-owner correspondence below requires its explicit equality.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeRegistered

open Sheaf CellularSheaf
open _root_.HomotopicalEncryption.Protocol.Evidence.TransferTranscript
open TCB.PrimitiveChecks

abbrev Bytes := List UInt8

variable {Seed VerifierKey PublicCRS Trapdoor Randomness : Type}
  {Validator Vertex Edge Face Owner Asset Receipt : Type}
  [DecidableEq Validator] [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {committee : Consensus.Committee Validator}
  {authentication : Consensus.VoteAuthentication Validator Bytes}
  {hash : Bytes → TCB.Hash32}
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

/-- Use the original credential mapping and actual context snapshot/ciphertext
names. All three names are encoded by the existing canonical native key codec. -/
def contextKeyFor (base : Operational.Config F Owner Asset Receipt)
    (credentialFor : Owner → TCB.Hash32) (owner : Owner) : Bytes :=
  NativeProgram.keyForInstance (credentialFor owner) base.context.key.snapshotRoot
    base.ciphertextDigest

theorem contextKeyFor_decodes (base : Operational.Config F Owner Asset Receipt)
    (credentialFor : Owner → TCB.Hash32) (owner : Owner) :
    NativeProgram.decodeInstance (contextKeyFor base credentialFor owner) =
      some ⟨credentialFor owner, base.context.key.snapshotRoot, base.ciphertextDigest⟩ := by
  simp [contextKeyFor, NativeProgram.keyForInstance]

/-- The expected canonical program is checked as actual approved code, in
addition to the original approval's metadata/domain/epoch applicability guard. -/
def signatureVerifier
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt) (expected : NativeProgram.Program)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness) :
    SignatureVerifier Bytes where
  verify key message signature :=
    decide (approval.descriptor.program = NativeProgram.encodeProgram expected) &&
      (Registered.signatureVerifier approval base (NativeProgram.encodeProgram expected) none none
        parseKey parseCRS family).verify key message signature

def configure
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt) (expected : NativeProgram.Program)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (credentialFor : Owner → TCB.Hash32) : Operational.Config F Owner Asset Receipt :=
  Authorization.configure base (signatureVerifier approval base expected parseKey parseCRS family)
    (contextKeyFor base credentialFor)

theorem code_eq_of_verified
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt) (expected : NativeProgram.Program)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (key message signature : Bytes)
    (verified : (signatureVerifier approval base expected parseKey parseCRS family).verify
      key message signature = true) :
    approval.descriptor.program = NativeProgram.encodeProgram expected := by
  have checked : decide (approval.descriptor.program = NativeProgram.encodeProgram expected) = true :=
    (Bool.and_eq_true_iff.mp verified).1
  simpa only [decide_eq_true_eq] using checked

/-- Forget only the extra exact-code guard. Every original parsed packet field,
source check and payload-proof verification is retained unchanged. -/
def checkedRegistered
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt) (expected : NativeProgram.Program)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (credentialFor : Owner → TCB.Hash32)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer
      (configure approval base expected parseKey parseCRS family credentialFor) transfer bytes) :
    Operational.CheckedTransfer
      (Registered.configure approval base (NativeProgram.encodeProgram expected) none none
        parseKey parseCRS family (contextKeyFor base credentialFor)) transfer bytes where
  prechecks := ⟨checked.prechecks.resources, checked.prechecks.snapshotMatches, checked.prechecks.leafMatches⟩
  proof :=
    { packet := checked.proof.packet
      decoded := checked.proof.decoded
      canonical := checked.proof.canonical
      metadata_eq := checked.proof.metadata_eq
      intent_eq := checked.proof.intent_eq
      signatureVerified := (Bool.and_eq_true_iff.mp checked.proof.signatureVerified).2
      proofVerified := checked.proof.proofVerified }

theorem checked_program_eq
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt) (expected : NativeProgram.Program)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (credentialFor : Owner → TCB.Hash32)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer
      (configure approval base expected parseKey parseCRS family credentialFor) transfer bytes) :
    approval.descriptor.program = NativeProgram.encodeProgram expected := by
  have verified := checked.proof.signatureVerified_expected
  change (signatureVerifier approval base expected parseKey parseCRS family).verify
    (contextKeyFor base credentialFor transfer.signer)
    (Signing.message base.codec base.metadata (base.intentFor transfer))
    checked.proof.packet.ownerSignature = true at verified
  exact code_eq_of_verified approval base expected parseKey parseCRS family _ _ _ verified

/-- The preferred native checker executes the exact expected program, on the
actual snapshot/ciphertext context and original full-intent signing bytes. -/
theorem checked_native_selection
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt) (expected : NativeProgram.Program)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (credentialFor : Owner → TCB.Hash32)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer
      (configure approval base expected parseKey parseCRS family credentialFor) transfer bytes) :
    approval.descriptor.program = NativeProgram.encodeProgram expected ∧
      approval.appliesConfig base (NativeProgram.encodeProgram expected) none none = true ∧
      base.before.epoch = approval.quorum.target.proposal.epoch ∧
      ∃ key publicCRS,
        parseKey approval.descriptor.verifierKey = some key ∧
        parseCRS approval.descriptor.publicCRS = some publicCRS ∧
        (family expected).verify (key, publicCRS)
          (Codec.encode (NativeProgram.encodeInstance
            ⟨credentialFor transfer.signer, base.context.key.snapshotRoot, base.ciphertextDigest⟩)
            (Signing.message base.codec base.metadata (base.intentFor transfer)))
          checked.proof.packet.ownerSignature = true := by
  have codeEq := checked_program_eq approval base expected parseKey parseCRS family credentialFor checked
  let lower := checkedRegistered approval base expected parseKey parseCRS family credentialFor checked
  obtain ⟨applicable, epoch, actual, key, publicCRS, programDecoded, keyDecoded, crsDecoded, verified⟩ :=
    Registered.checked_signature_selection approval base (NativeProgram.encodeProgram expected) none none
      parseKey parseCRS family (contextKeyFor base credentialFor) lower
  rw [codeEq, NativeProgram.decodeProgram_encodeProgram] at programDecoded
  have same : expected = actual := Option.some.inj programDecoded
  subst actual
  refine ⟨codeEq, applicable, epoch, key, publicCRS, keyDecoded, crsDecoded, ?_⟩
  simpa only [lower, checkedRegistered, contextKeyFor, NativeProgram.keyForInstance] using verified

/-- Full approval metadata and the native profile scope match the actual base
configuration. Their labels are not used to identify unrelated code. -/
theorem checked_approval_fields
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt) (expected : NativeProgram.Program)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (credentialFor : Owner → TCB.Hash32)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer
      (configure approval base expected parseKey parseCRS family credentialFor) transfer bytes) :
    approval.descriptor.metadata = base.metadata ∧
      approval.descriptor.publicProfile = NativeProgram.encodeProgram expected ∧
      approval.descriptor.parameterSet = base.context.key.parameterSet ∧
      approval.descriptor.scope = none ∧ approval.descriptor.calibration = none ∧
      base.before.epoch = approval.quorum.target.proposal.epoch :=
  Registered.checked_approval_fields approval base (NativeProgram.encodeProgram expected) none none
    parseKey parseCRS family (contextKeyFor base credentialFor)
    (checkedRegistered approval base expected parseKey parseCRS family credentialFor checked)

/-- A different approved program is rejected even if its profile label and
all cryptographic verification results were otherwise acceptable. -/
theorem reject_wrong_program
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt) (expected : NativeProgram.Program)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (credentialFor : Owner → TCB.Hash32) (transfer : Operational.ResourceTransfer Owner) (bytes : Bytes)
    (wrong : approval.descriptor.program ≠ NativeProgram.encodeProgram expected) :
    Operational.check (configure approval base expected parseKey parseCRS family credentialFor) transfer bytes = false := by
  cases outcome : Operational.check
      (configure approval base expected parseKey parseCRS family credentialFor) transfer bytes with
  | false => rfl
  | true =>
    exact False.elim (wrong (checked_program_eq approval base expected parseKey parseCRS family
      credentialFor (Operational.CheckedTransfer.ofCheck outcome)))

/-- If the original byte-owner packet codec is the concrete implementation,
the complete owner signing input has a concrete canonical packet skeleton.
No existing configuration or payload algorithm is silently reconfigured. -/
theorem concrete_signing_skeleton
    (base : Operational.Config F Bytes Asset Receipt)
    (intent : Intent Bytes)
    (codecEq : base.codec = _root_.HomotopicalEncryption.Protocol.Evidence.TransferCodec.bytesOwnerCodec) :
    _root_.HomotopicalEncryption.Protocol.Evidence.TransferCodec.decode
      ((Signing.message base.codec base.metadata intent).drop Signing.domain.length) =
      some (Signing.skeleton base.metadata intent) := by
  rw [codecEq]
  simp [Signing.message, _root_.HomotopicalEncryption.Protocol.Evidence.TransferCodec.bytesOwnerCodec]

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeRegistered
