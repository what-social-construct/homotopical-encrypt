module

public import Protocol.Transfer.PathSignature.CRS
public import Protocol.Transfer.PathSignature.NativeProgram
public import Protocol.Transfer.Certificates.Profile
public import Protocol.Transfer.Authorization

@[expose] public section

/-!
# Approved native CRS execution at the original owner-signature checker

The existing quorum approval retains exact public program, verifier-key and
CRS bytes. The native program is parsed by its actual canonical decoder; the
selected key/CRS parsers produce the objects passed to the chosen primitive.
The original owner-to-credential map and full signing-message codec are reused.
Actual packet acceptance therefore establishes both approval applicability
and execution on those parsed objects and its actual owner-signature bytes.

The primitive family is indexed by the parsed program. Its relation refinement,
correct setup generation, simulation/extraction bounds and hash implementation
remain explicit contracts. Parsing and registration do not establish those
cryptographic properties, nor does a public identifier identify an arbitrary
function. The native relation consumes credential/message inputs; the separate
certificate-subject domain is not silently reinterpreted as that input type.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.Registered

open Sheaf CellularSheaf
open Evidence.TransferTranscript
open TCB.PrimitiveChecks

abbrev Bytes := List UInt8

variable {Seed VerifierKey PublicCRS Trapdoor Randomness : Type}

/-- Execution uses this actual primitive family and the parsed key/CRS pair. -/
def run
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (program : NativeProgram.Program) (key : VerifierKey) (publicCRS : PublicCRS)
    (input proof : Bytes) : Bool :=
  (family program).verify (key, publicCRS) input proof

variable {Validator Signature Vertex Edge Face Owner Asset Receipt : Type}
  [DecidableEq Validator] [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {committee : Consensus.Committee Validator}
  {authentication : Consensus.VoteAuthentication Validator Signature}
  {hash : Bytes → TCB.Hash32}
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

/-- Public credential/message verification first runs the exact approved
profile guard, then selects and executes the actual parsed implementation. -/
def signatureVerifier
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (scope : Option Certificates.Evidence.Level)
    (calibration : Option Certificates.Codec.Calibration)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness) :
    SignatureVerifier Bytes where
  verify key message proof :=
    approval.verifyConfig base publicProfile scope calibration NativeProgram.decodeProgram
      parseKey parseCRS (run family) (Codec.encode key message) proof

/-- Reuse the original owner-key map and authorization policy; no second
registry or credential-ownership interpretation is introduced here. -/
def configure
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (scope : Option Certificates.Evidence.Level)
    (calibration : Option Certificates.Codec.Calibration)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (keyFor : Owner → Bytes) : Operational.Config F Owner Asset Receipt :=
  Authorization.configure base
    (signatureVerifier approval base publicProfile scope calibration parseKey parseCRS family) keyFor

/-- The approved checker is exactly the selected CRS signature verifier once
the actual applicability and parsing checks succeed. -/
theorem verifier_of_selected
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (scope : Option Certificates.Evidence.Level)
    (calibration : Option Certificates.Codec.Calibration)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (program : NativeProgram.Program) (key : VerifierKey) (publicCRS : PublicCRS)
    (applicable : approval.appliesConfig base publicProfile scope calibration = true)
    (selected : Certificates.Profile.select NativeProgram.decodeProgram parseKey parseCRS
      approval.descriptor = some (program, key, publicCRS))
    (credential message proof : Bytes) :
    (signatureVerifier approval base publicProfile scope calibration parseKey parseCRS family).verify
      credential message proof = (CRS.verifier (family program) (key, publicCRS)).verify
        credential message proof :=
  approval.verifyConfig_of_selected base publicProfile scope calibration
    NativeProgram.decodeProgram parseKey parseCRS (run family) applicable
    program key publicCRS selected (Codec.encode credential message) proof

theorem verified_selection
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (scope : Option Certificates.Evidence.Level)
    (calibration : Option Certificates.Codec.Calibration)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (credential message proof : Bytes)
    (verified : (signatureVerifier approval base publicProfile scope calibration
      parseKey parseCRS family).verify credential message proof = true) :
    approval.appliesConfig base publicProfile scope calibration = true ∧
      ∃ program key publicCRS,
        NativeProgram.decodeProgram approval.descriptor.program = some program ∧
        parseKey approval.descriptor.verifierKey = some key ∧
        parseCRS approval.descriptor.publicCRS = some publicCRS ∧
        (family program).verify (key, publicCRS) (Codec.encode credential message) proof = true := by
  change (approval.appliesConfig base publicProfile scope calibration &&
    Certificates.Profile.execute NativeProgram.decodeProgram parseKey parseCRS (run family)
      approval.descriptor (Codec.encode credential message) proof) = true at verified
  obtain ⟨applicable, executed⟩ := Bool.and_eq_true_iff.mp verified
  refine ⟨applicable, ?_⟩
  cases selected : Certificates.Profile.select NativeProgram.decodeProgram parseKey parseCRS
      approval.descriptor with
  | none => simp [Certificates.Profile.execute, selected] at executed
  | some objects =>
    rcases objects with ⟨program, key, publicCRS⟩
    obtain ⟨programDecoded, keyDecoded, crsDecoded⟩ :=
      (Certificates.Profile.select_eq_some_iff _ _ _ _ _ _ _).1 selected
    exact ⟨program, key, publicCRS, programDecoded, keyDecoded, crsDecoded,
      by simpa [Certificates.Profile.execute, selected, run] using executed⟩

/-- Honest native signing reaches the same approved verifier when the parsed
public key/CRS pair is the actual primitive setup output. Completeness is a
primitive contract for the actual native checker, not an identifier law. -/
theorem registered_sign_complete
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (scope : Option Certificates.Evidence.Level)
    (calibration : Option Certificates.Codec.Calibration)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (program : NativeProgram.Program) (key : VerifierKey) (publicCRS : PublicCRS)
    (applicable : approval.appliesConfig base publicProfile scope calibration = true)
    (selected : Certificates.Profile.select NativeProgram.decodeProgram parseKey parseCRS
      approval.descriptor = some (program, key, publicCRS))
    (correct : CRS.Correct (family program) (NativeProgram.relation program hash))
    (seed : Seed) (setupMatches : (family program).setup seed = (key, publicCRS))
    (credential message witness : Bytes) (random : Randomness)
    (valid : NativeProgram.relation program hash (Codec.encode credential message) witness = true) :
    (signatureVerifier approval base publicProfile scope calibration parseKey parseCRS family).verify
      credential message (CRS.sign (family program) (key, publicCRS) credential message witness random) = true := by
  change approval.verifyConfig base publicProfile scope calibration NativeProgram.decodeProgram
    parseKey parseCRS (run family) (Codec.encode credential message)
      (CRS.sign (family program) (key, publicCRS) credential message witness random) = true
  rw [approval.verifyConfig_of_selected base publicProfile scope calibration
    NativeProgram.decodeProgram parseKey parseCRS (run family) applicable program key publicCRS selected]
  change (CRS.verifier (family program) (key, publicCRS)).verify credential message
    (CRS.sign (family program) (key, publicCRS) credential message witness random) = true
  rw [← setupMatches]
  exact CRS.sign_complete (family program) (NativeProgram.relation program hash) correct
    seed credential message witness random valid

/-- The actual parsed packet verifies its original owner-signature field on
the existing full metadata/intent message and approved parsed implementation. -/
theorem checked_signature_selection
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (scope : Option Certificates.Evidence.Level)
    (calibration : Option Certificates.Codec.Calibration)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (keyFor : Owner → Bytes)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer
      (configure approval base publicProfile scope calibration parseKey parseCRS family keyFor)
      transfer bytes) :
    approval.appliesConfig base publicProfile scope calibration = true ∧
      base.before.epoch = approval.quorum.target.proposal.epoch ∧
      ∃ program key publicCRS,
        NativeProgram.decodeProgram approval.descriptor.program = some program ∧
        parseKey approval.descriptor.verifierKey = some key ∧
        parseCRS approval.descriptor.publicCRS = some publicCRS ∧
        (family program).verify (key, publicCRS)
          (Codec.encode (keyFor transfer.signer)
            (Signing.message base.codec base.metadata (base.intentFor transfer)))
          checked.proof.packet.ownerSignature = true := by
  have verified := checked.proof.signatureVerified_expected
  change (signatureVerifier approval base publicProfile scope calibration parseKey parseCRS family).verify
    (keyFor transfer.signer) (Signing.message base.codec base.metadata (base.intentFor transfer))
    checked.proof.packet.ownerSignature = true at verified
  obtain ⟨applicable, selected⟩ := verified_selection approval base publicProfile scope calibration
    parseKey parseCRS family _ _ _ verified
  exact ⟨applicable, approval.appliesConfig_epoch base publicProfile scope calibration applicable, selected⟩

/-- Every public applicability coordinate is checked against the original
configuration, including metadata, scope, parameter profile and actual epoch. -/
theorem checked_approval_fields
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (scope : Option Certificates.Evidence.Level)
    (calibration : Option Certificates.Codec.Calibration)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (keyFor : Owner → Bytes)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer
      (configure approval base publicProfile scope calibration parseKey parseCRS family keyFor)
      transfer bytes) :
    approval.descriptor.metadata = base.metadata ∧
      approval.descriptor.publicProfile = publicProfile ∧
      approval.descriptor.parameterSet = base.context.key.parameterSet ∧
      approval.descriptor.scope = scope ∧ approval.descriptor.calibration = calibration ∧
      base.before.epoch = approval.quorum.target.proposal.epoch := by
  obtain ⟨applicable, epoch, _⟩ := checked_signature_selection approval base publicProfile scope
    calibration parseKey parseCRS family keyFor checked
  obtain ⟨metadata, profile, parameters, scopeEq, calibrationEq, _⟩ :=
    (Certificates.Profile.applies_eq_true_iff _ _ _ _ _ _ _ _).1 applicable
  exact ⟨metadata, profile, parameters, scopeEq, calibrationEq, epoch⟩

theorem verifier_rejects_inapplicable
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (scope : Option Certificates.Evidence.Level)
    (calibration : Option Certificates.Codec.Calibration)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (inapplicable : approval.appliesConfig base publicProfile scope calibration = false)
    (credential message proof : Bytes) :
    (signatureVerifier approval base publicProfile scope calibration parseKey parseCRS family).verify
      credential message proof = false :=
  approval.verifyConfig_rejects_inapplicable base publicProfile scope calibration
    NativeProgram.decodeProgram parseKey parseCRS (run family) inapplicable _ _

theorem verifier_rejects_unparsed
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (scope : Option Certificates.Evidence.Level)
    (calibration : Option Certificates.Codec.Calibration)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (unparsed : Certificates.Profile.select NativeProgram.decodeProgram parseKey parseCRS
      approval.descriptor = none) (credential message proof : Bytes) :
    (signatureVerifier approval base publicProfile scope calibration parseKey parseCRS family).verify
      credential message proof = false := by
  simp [signatureVerifier, Certificates.Profile.Approval.verifyConfig,
    Certificates.Profile.execute, unparsed]

/-- Even when all other packet checks could pass, an inapplicable approval
rejects the actual operational checker. -/
theorem reject_inapplicable
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (scope : Option Certificates.Evidence.Level)
    (calibration : Option Certificates.Codec.Calibration)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (keyFor : Owner → Bytes) (transfer : Operational.ResourceTransfer Owner) (bytes : Bytes)
    (inapplicable : approval.appliesConfig base publicProfile scope calibration = false) :
    Operational.check (configure approval base publicProfile scope calibration parseKey parseCRS family keyFor)
      transfer bytes = false := by
  cases outcome : Operational.check
      (configure approval base publicProfile scope calibration parseKey parseCRS family keyFor) transfer bytes with
  | false => rfl
  | true =>
    have checked := Operational.CheckedTransfer.ofCheck outcome
    have verified := checked.proof.signatureVerified_expected
    change (signatureVerifier approval base publicProfile scope calibration parseKey parseCRS family).verify
      (keyFor transfer.signer) (Signing.message base.codec base.metadata (base.intentFor transfer))
      checked.proof.packet.ownerSignature = true at verified
    rw [verifier_rejects_inapplicable approval base publicProfile scope calibration parseKey parseCRS
      family inapplicable] at verified
    contradiction

/-- Malformed approved implementation bytes cannot be executed by the
registered owner checker, independently of cryptographic soundness. -/
theorem reject_unparsed
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (scope : Option Certificates.Evidence.Level)
    (calibration : Option Certificates.Codec.Calibration)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (keyFor : Owner → Bytes) (transfer : Operational.ResourceTransfer Owner) (bytes : Bytes)
    (unparsed : Certificates.Profile.select NativeProgram.decodeProgram parseKey parseCRS
      approval.descriptor = none) :
    Operational.check (configure approval base publicProfile scope calibration parseKey parseCRS family keyFor)
      transfer bytes = false := by
  cases outcome : Operational.check
      (configure approval base publicProfile scope calibration parseKey parseCRS family keyFor) transfer bytes with
  | false => rfl
  | true =>
    have checked := Operational.CheckedTransfer.ofCheck outcome
    have verified := checked.proof.signatureVerified_expected
    change (signatureVerifier approval base publicProfile scope calibration parseKey parseCRS family).verify
      (keyFor transfer.signer) (Signing.message base.codec base.metadata (base.intentFor transfer))
      checked.proof.packet.ownerSignature = true at verified
    rw [verifier_rejects_unparsed approval base publicProfile scope calibration parseKey parseCRS family
      unparsed] at verified
    contradiction

end HomotopicalEncryption.Protocol.Transfer.PathSignature.Registered
