module

public import Protocol.Transfer.Certificates
public import Protocol.Transfer.Certificates.Codec

@[expose] public section

/-!
# Intended certificate statements on the actual operational proof input

The subject below retains the original configuration's metadata, full intent
and computed ciphertext digest together with the selected public profile,
calibration and claim. Updating the payload verifier leaves the original raw
context, ciphertext, manifest, packet codec and authorization algorithm intact.

The byte-indexed intended statement is defined by canonical decoding and an
actual subject-to-certificate relation. Roundtrip decoding discharges the
generic exact-intent reflection obligation. The selected Boolean verifier is
executed on those exact encoded subjects and the actual packet proof bytes.
It is not assumed to be sound: missing certification after checking yields a
false acceptance relative to this declared intended statement.

Declaring this statement does not prove that an arbitrary verifier implements
it. A concrete circuit/proof-system refinement, computational soundness,
knowledge, witness extraction and privacy remain separate obligations. Neither
the profile bytes nor a verifier identifier supplies their semantics alone.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.Certificates.Statement

open Sheaf CellularSheaf
open Evidence.TransferTranscript

abbrev Bytes := List UInt8

variable {Owner Certificate : Type}

/-- The intended byte statement uses the actual decoded subject and actual
certificate relation. The checking algorithm has no built-in soundness law. -/
def backend (codec : Evidence.TransferCheck.PacketCodec Owner)
    (Meaning : Codec.Subject Owner → Certificate → Prop)
    (verify : Bytes → Bytes → Bool) : TCB.PrimitiveChecks.ProofVerifier where
  verify := verify
  Holds input := ∃ subject certificate,
    Codec.decode codec input = some subject ∧ Meaning subject certificate

/-- Canonical subject bytes reflect the selected certificate relation exactly;
this is encoding/statement reflection, not Boolean verification soundness. -/
theorem holds_encode_iff (codec : Evidence.TransferCheck.PacketCodec Owner)
    (Meaning : Codec.Subject Owner → Certificate → Prop)
    (verify : Bytes → Bytes → Bool) (subject : Codec.Subject Owner) :
    (backend codec Meaning verify).Holds (Codec.encode codec subject) ↔
      ∃ certificate, Meaning subject certificate := by
  constructor
  · rintro ⟨other, certificate, decoded, means⟩
    have same : subject = other :=
      Option.some.inj ((Codec.decode_encode codec subject).symm.trans decoded)
    subst other
    exact ⟨certificate, means⟩
  · rintro ⟨certificate, means⟩
    exact ⟨subject, certificate, Codec.decode_encode codec subject, means⟩

variable {Vertex Edge Face Asset Receipt : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

/-- Select public certificate coordinates on the existing actual intent. The
ciphertext name is computed from the configuration's original selected bytes. -/
def subjectFor (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (claim : Codec.Claim) (intent : Intent Owner) : Codec.Subject Owner where
  metadata := base.metadata
  intent := intent
  ciphertextDigest := base.ciphertextDigest
  profile := publicProfile
  calibration := calibration
  claim := claim

/-- Use the selected byte verifier on the exact public certificate subject.
No semantic validity premise is added to the raw configuration. -/
def withVerifier (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (claim : Codec.Claim) (verify : Bytes → Bytes → Bool) :
    Operational.Config F Owner Asset Receipt :=
  { base with
    payload :=
      { verify := fun intent proof => verify
          (Codec.encode base.codec (subjectFor base publicProfile calibration claim intent)) proof } }

@[simp] theorem withVerifier_context (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (claim : Codec.Claim) (verify : Bytes → Bytes → Bool) :
    (withVerifier base publicProfile calibration claim verify).context = base.context := rfl

@[simp] theorem withVerifier_ciphertext (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (claim : Codec.Claim) (verify : Bytes → Bytes → Bool) :
    (withVerifier base publicProfile calibration claim verify).ciphertext = base.ciphertext := rfl

@[simp] theorem withVerifier_metadata (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (claim : Codec.Claim) (verify : Bytes → Bytes → Bool) :
    (withVerifier base publicProfile calibration claim verify).metadata = base.metadata := rfl

@[simp] theorem withVerifier_ciphertextDigest (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (claim : Codec.Claim) (verify : Bytes → Bytes → Bool) :
    (withVerifier base publicProfile calibration claim verify).ciphertextDigest =
      base.ciphertextDigest := rfl

@[simp] theorem withVerifier_codec (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (claim : Codec.Claim) (verify : Bytes → Bytes → Bool) :
    (withVerifier base publicProfile calibration claim verify).codec = base.codec := rfl

@[simp] theorem withVerifier_intentFor (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (claim : Codec.Claim) (verify : Bytes → Bytes → Bool)
    (transfer : Operational.ResourceTransfer Owner) :
    (withVerifier base publicProfile calibration claim verify).intentFor transfer =
      base.intentFor transfer := rfl

@[simp] theorem withVerifier_manifest (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (claim : Codec.Claim) (verify : Bytes → Bytes → Bool) :
    (withVerifier base publicProfile calibration claim verify).manifest = base.manifest := rfl

/-- Exact backend/operational algorithm agreement is constructed, rather than
assumed for a separately named checker. -/
def payloadProfile (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (claim : Codec.Claim) (Meaning : Codec.Subject Owner → Certificate → Prop)
    (verify : Bytes → Bytes → Bool) :
    Primitives.PayloadProfile (withVerifier base publicProfile calibration claim verify) where
  backend := backend base.codec Meaning verify
  inputFor intent := Codec.encode base.codec (subjectFor base publicProfile calibration claim intent)
  agrees _ _ := rfl

/-- The exact-intent reflection obligation is proved by canonical decoding for
this constructed intended statement; no proof-system soundness is inferred. -/
theorem reflects (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (claim : Codec.Claim) (Meaning : Codec.Subject Owner → Certificate → Prop)
    (verify : Bytes → Bytes → Bool) :
    ReflectsCertificates (payloadProfile base publicProfile calibration claim Meaning verify)
      (fun intent certificate => Meaning (subjectFor base publicProfile calibration claim intent)
        certificate) := by
  intro intent holds
  exact (holds_encode_iff base.codec Meaning verify
    (subjectFor base publicProfile calibration claim intent)).1 holds

/-- Actual checked metadata and intent are the same coordinates encoded by
the certificate subject, including the original computed manifest root. -/
theorem checked_subject_fields (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (claim : Codec.Claim) (verify : Bytes → Bytes → Bool)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer
      (withVerifier base publicProfile calibration claim verify) transfer bytes) :
    (subjectFor base publicProfile calibration claim (base.intentFor transfer)).metadata =
        checked.proof.packet.metadata ∧
      (subjectFor base publicProfile calibration claim (base.intentFor transfer)).intent =
        checked.proof.packet.intent ∧
      (subjectFor base publicProfile calibration claim (base.intentFor transfer)).ciphertextDigest =
        base.ciphertextDigest ∧
      (subjectFor base publicProfile calibration claim (base.intentFor transfer)).intent.manifestRoot =
        base.manifest.root :=
  ⟨checked.proof.metadata_eq.symm, checked.proof.intent_eq.symm, rfl, rfl⟩

/-- A checked packet for the constructed algorithm provides an actual bound
certificate or false acceptance of that packet's exact proof bytes. -/
theorem checked_certificate_or_falseAccept
    (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (claim : Codec.Claim) (Meaning : Codec.Subject Owner → Certificate → Prop)
    (verify : Bytes → Bytes → Bool)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer
      (withVerifier base publicProfile calibration claim verify) transfer bytes) :
    (∃ certificate,
      Meaning (subjectFor base publicProfile calibration claim (base.intentFor transfer)) certificate) ∨
      (backend base.codec Meaning verify).FalseAccept
        (Codec.encode base.codec
          (subjectFor base publicProfile calibration claim (base.intentFor transfer)))
        checked.proof.packet.proofBytes :=
  Certificates.checked_certificate_or_falseAccept
    (payloadProfile base publicProfile calibration claim Meaning verify)
    (fun intent certificate => Meaning (subjectFor base publicProfile calibration claim intent)
      certificate)
    checked (reflects base publicProfile calibration claim Meaning verify)

/-- With canonical subject reflection already established, a missing required
certificate after actual checking is a concrete backend false acceptance. -/
theorem missing_certificate_implies_falseAccept
    (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (claim : Codec.Claim) (Meaning : Codec.Subject Owner → Certificate → Prop)
    (verify : Bytes → Bytes → Bool)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer
      (withVerifier base publicProfile calibration claim verify) transfer bytes)
    (missing : ¬ ∃ certificate,
      Meaning (subjectFor base publicProfile calibration claim (base.intentFor transfer)) certificate) :
    (backend base.codec Meaning verify).FalseAccept
      (Codec.encode base.codec
        (subjectFor base publicProfile calibration claim (base.intentFor transfer)))
      checked.proof.packet.proofBytes := by
  rcases checked_certificate_or_falseAccept base publicProfile calibration claim Meaning verify
    checked with certificate | falseAccept
  · exact False.elim (missing certificate)
  · exact falseAccept

end HomotopicalEncryption.Protocol.Transfer.Certificates.Statement
