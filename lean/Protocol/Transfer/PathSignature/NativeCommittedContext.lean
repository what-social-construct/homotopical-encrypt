module

public import Protocol.Transfer.PathSignature.NativeCommitted
public import Protocol.Transfer.PathSignature.CRS
public import Protocol.Transfer.Certificates.Profile
public import Protocol.Transfer.Authorization

@[expose] public section

/-!
# The nonce-bearing native statement at the original transfer context

The V2 owner key names the existing credential, original snapshot root and
actual full-ciphertext digest. A private operator-opening equation identifies
that root with the canonical committed target; the original native sample and
hash equations then identify the same V2 instance. No new storage context,
geometry, lattice or owner registry is introduced.

The configured owner checker requires the exact approved V2 program bytes,
the original approval applicability guard, and successful parsing by the V2
program decoder and supplied key/CRS decoders. It executes the selected CRS
family on those actual objects and the original complete signing message.
The V1 raw-matrix program decoder and verifier are not used.

These are execution and original-object joins. The operator commitment's
hiding, primitive security, setup-generation and lifecycle properties remain
separate from program approval and parsing.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedContext

open Sheaf CellularSheaf HCPCoupledFamily
open TCB.PrimitiveChecks

abbrev Bytes := List UInt8

variable {Vertex Edge Face Owner Asset Receipt : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

/-- Derive all three V2 public names from the original owner and configuration. -/
def contextKeyFor (base : Operational.Config F Owner Asset Receipt)
    (credentialFor : Owner → TCB.Hash32) (owner : Owner) : Bytes :=
  NativeCommitted.encodeInstance
    ⟨credentialFor owner, base.context.key.snapshotRoot, base.ciphertextDigest⟩

theorem contextKeyFor_decodes (base : Operational.Config F Owner Asset Receipt)
    (credentialFor : Owner → TCB.Hash32) (owner : Owner) :
    NativeCommitted.decodeInstance (contextKeyFor base credentialFor owner) =
      some ⟨credentialFor owner, base.context.key.snapshotRoot, base.ciphertextDigest⟩ := by
  simp [contextKeyFor]

/-- The private target opening, original sample and selected hash identify the
same V2 instance in the existing context-derived owner key. -/
theorem contextKeyFor_instance {rows cols : ℕ}
    (witness : NativeCommitted.Witness rows cols) (hash : Bytes → TCB.Hash32)
    (base : Operational.Config (sheaf witness.native.target) Owner Asset Receipt)
    (credentialFor : Owner → TCB.Hash32) (owner : Owner)
    (credential : credentialFor owner = hash (NativeRelation.credentialBytes witness.native))
    (snapshot : Storage.OperatorCommitment.BindsSnapshot hash witness.native.target
      witness.operatorNonce base.context.interpretation.snapshot)
    (sample : base.ciphertext = Storage.CoupledCiphertext.sampleBytes witness.native.target
      witness.native.z witness.native.a witness.native.u)
    (ciphertextHash : base.hashes.ciphertext base.ciphertext = hash base.ciphertext) :
    contextKeyFor base credentialFor owner =
      NativeCommitted.encodeInstance (NativeCommitted.instanceFor hash witness) := by
  have targetRoot := Storage.OperatorCommitment.context_root_eq hash witness.native.target
    witness.operatorNonce base.context snapshot
  have ciphertextRoot : base.ciphertextDigest = hash
      (Storage.CoupledCiphertext.sampleBytes witness.native.target
        witness.native.z witness.native.a witness.native.u) := by
    change base.hashes.ciphertext base.ciphertext = _
    rw [ciphertextHash, sample]
  unfold contextKeyFor NativeCommitted.instanceFor
  rw [credential, ← targetRoot, ciphertextRoot]

variable {Seed VerifierKey PublicCRS Trapdoor Randomness Validator Signature : Type}
  [DecidableEq Validator]
  {committee : Consensus.Committee Validator}
  {authentication : Consensus.VoteAuthentication Validator Signature}
  {hash : Bytes → TCB.Hash32}

/-- Require the exact V2 program and execute the original generic approval
guard on the actual V2 parser, supplied key/CRS parsers and CRS family. -/
def signatureVerifier
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt) (expected : NativeCommitted.Program)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeCommitted.Program →
      CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness) : SignatureVerifier Bytes where
  verify key message signature :=
    decide (approval.descriptor.program = NativeCommitted.encodeProgram expected) &&
      approval.verifyConfig base (NativeCommitted.encodeProgram expected) none none
        NativeCommitted.decodeProgram parseKey parseCRS
        (fun program key publicCRS input proof => (family program).verify (key, publicCRS) input proof)
        (Codec.encode key message) signature

/-- Replace only the owner checker, retaining the original authorization
policy, packet codec, intent, resources, ciphertext and storage context. -/
def configure
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt) (expected : NativeCommitted.Program)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeCommitted.Program →
      CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (credentialFor : Owner → TCB.Hash32) : Operational.Config F Owner Asset Receipt :=
  Authorization.configure base (signatureVerifier approval base expected parseKey parseCRS family)
    (contextKeyFor base credentialFor)

/-- The exact-code guard rejects a differently approved program before the
primitive result can authorize these signature bytes. -/
theorem reject_wrong_program
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt) (expected : NativeCommitted.Program)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeCommitted.Program →
      CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (wrong : approval.descriptor.program ≠ NativeCommitted.encodeProgram expected)
    (key message signature : Bytes) :
    (signatureVerifier approval base expected parseKey parseCRS family).verify
      key message signature = false := by
  simp [signatureVerifier, wrong]

/-- Successful verification selects the exact expected V2 code and actual
approved key/CRS, under the original metadata/profile/epoch guard. -/
theorem verified_selection
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt) (expected : NativeCommitted.Program)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeCommitted.Program →
      CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (key message signature : Bytes)
    (verified : (signatureVerifier approval base expected parseKey parseCRS family).verify
      key message signature = true) :
    approval.descriptor.program = NativeCommitted.encodeProgram expected ∧
      approval.appliesConfig base (NativeCommitted.encodeProgram expected) none none = true ∧
      base.before.epoch = approval.quorum.target.proposal.epoch ∧
      ∃ parsedKey publicCRS,
        parseKey approval.descriptor.verifierKey = some parsedKey ∧
        parseCRS approval.descriptor.publicCRS = some publicCRS ∧
        (family expected).verify (parsedKey, publicCRS)
          (Codec.encode key message) signature = true := by
  have exactCode : approval.descriptor.program = NativeCommitted.encodeProgram expected := by
    simpa only [decide_eq_true_eq] using (Bool.and_eq_true_iff.mp verified).1
  have approved := (Bool.and_eq_true_iff.mp verified).2
  change (approval.appliesConfig base (NativeCommitted.encodeProgram expected) none none &&
    Certificates.Profile.execute NativeCommitted.decodeProgram parseKey parseCRS
      (fun program key publicCRS input proof => (family program).verify (key, publicCRS) input proof)
      approval.descriptor (Codec.encode key message) signature) = true at approved
  obtain ⟨applicable, executed⟩ := Bool.and_eq_true_iff.mp approved
  refine ⟨exactCode, applicable,
    approval.appliesConfig_epoch base _ none none applicable, ?_⟩
  cases selected : Certificates.Profile.select NativeCommitted.decodeProgram parseKey parseCRS
      approval.descriptor with
  | none => simp [Certificates.Profile.execute, selected] at executed
  | some objects =>
    rcases objects with ⟨program, parsedKey, publicCRS⟩
    obtain ⟨programDecoded, keyDecoded, crsDecoded⟩ :=
      (Certificates.Profile.select_eq_some_iff _ _ _ _ _ _ _).mp selected
    rw [exactCode, NativeCommitted.decodeProgram_encodeProgram] at programDecoded
    have sameProgram : expected = program := Option.some.inj programDecoded
    subst program
    refine ⟨parsedKey, publicCRS, keyDecoded, crsDecoded, ?_⟩
    simpa only [Certificates.Profile.execute, selected] using executed

/-- The original checked packet verifies its owner-signature bytes on its
context-derived V2 key and original complete metadata/intent signing message. -/
theorem checked_selection
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt) (expected : NativeCommitted.Program)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeCommitted.Program →
      CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (credentialFor : Owner → TCB.Hash32)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer
      (configure approval base expected parseKey parseCRS family credentialFor) transfer bytes) :
    approval.descriptor.program = NativeCommitted.encodeProgram expected ∧
      approval.appliesConfig base (NativeCommitted.encodeProgram expected) none none = true ∧
      base.before.epoch = approval.quorum.target.proposal.epoch ∧
      ∃ key publicCRS,
        parseKey approval.descriptor.verifierKey = some key ∧
        parseCRS approval.descriptor.publicCRS = some publicCRS ∧
        (family expected).verify (key, publicCRS)
          (Codec.encode (contextKeyFor base credentialFor transfer.signer)
            (Signing.message base.codec base.metadata (base.intentFor transfer)))
          checked.proof.packet.ownerSignature = true := by
  have verified := checked.proof.signatureVerified_expected
  change (signatureVerifier approval base expected parseKey parseCRS family).verify
    (contextKeyFor base credentialFor transfer.signer)
    (Signing.message base.codec base.metadata (base.intentFor transfer))
    checked.proof.packet.ownerSignature = true at verified
  exact verified_selection approval base expected parseKey parseCRS family _ _ _ verified

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedContext
