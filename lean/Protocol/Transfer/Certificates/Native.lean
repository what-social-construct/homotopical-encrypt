module

public import Protocol.Transfer.Certificates.Statement
public import Protocol.Storage.NativeManifest

@[expose] public section

/-!
# Native observation certificates on actual operational proof subjects

The public profile names the coupled integral family and its dimensions. It
does not serialize the private presentation, harmonic message or opening.
The actual certificate relation is the existing `NativeManifest.BindsOriginal`
on this configuration's raw seal and its original bound HCP observation.

Canonical subject reflection is instantiated with that precise relation,
including the actual context base, manifest root and ciphertext digest. An
actual checked packet therefore yields an original-observation certificate or
false acceptance by the selected byte verifier. The verifier's cryptographic
soundness, circuit refinement, knowledge and privacy are not assumed or proved
here. Malformed ciphertexts remain representable as raw configurations; they
cannot satisfy the declared native statement.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.Certificates.Native

open Sheaf CellularSheaf HCPCoupledFamily
open Evidence.TransferTranscript

abbrev Bytes := List UInt8

/-- ASCII `HODGE_NATIVE_CERTIFICATE_PROFILE_V1`. -/
def domain : Bytes :=
  [72, 79, 68, 71, 69, 95, 78, 65, 84, 73, 86, 69, 95, 67, 69, 82, 84, 73,
    70, 73, 67, 65, 84, 69, 95, 80, 82, 79, 70, 73, 76, 69, 95, 86, 49]

/-- Public family and dimension coordinates, independent of private matrix
entries. This descriptor alone does not identify the private geometry. -/
def publicProfile (rows cols : ℕ) : Bytes :=
  domain ++ Storage.CoupledCodec.encodeNat rows (Storage.CoupledCodec.encodeNat cols [])

variable {rows cols : ℕ} {B : Matrix (Fin rows) (Fin cols) ℤ}
  {Owner Asset Receipt PublicClass Lifecycle : Type}
  {payload : CochainPayloadInterpretation (sheaf B)}
  {classify : SheafStateSnapshot (sheaf B) → PublicClass}
  {Binds : TCB.HCPStackBinding Lifecycle PublicClass (C1 (Fin rows) (Fin cols))}

/-- The actual native claim uses the existing bound observation and the same
raw configuration, not a detached profile label or a new certificate carrier. -/
def Meaning (base : Operational.Config (sheaf B) Owner Asset Receipt)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32)
    (subject : Codec.Subject Owner)
    (O : TCB.BoundHCPObservation (integralStructure B)
      payload PublicClass Lifecycle classify Binds) : Prop :=
  subject.metadata = base.metadata ∧
    subject.intent.base = base.context.publicView ∧
    subject.intent.manifestRoot = base.manifest.root ∧
    subject.ciphertextDigest = base.ciphertextDigest ∧
    subject.profile = publicProfile rows cols ∧
    subject.calibration = none ∧
    subject.claim = .nativeCiphertext ∧
    Storage.NativeManifest.BindsOriginal base.manifest O identify parameters

/-- Extract the precise original-observation certificate from the declared
native statement, retaining this same configuration's manifest. -/
theorem meaning_binds
    {base : Operational.Config (sheaf B) Owner Asset Receipt}
    {identify : Lifecycle → TCB.Hash32} {parameters : TCB.Hash32}
    {subject : Codec.Subject Owner}
    {O : TCB.BoundHCPObservation (integralStructure B)
      payload PublicClass Lifecycle classify Binds}
    (means : Meaning base identify parameters subject O) :
    Storage.NativeManifest.BindsOriginal base.manifest O identify parameters := by
  rcases means with ⟨_, _, _, _, _, _, _, bound⟩
  exact bound

/-- At the actual expected intent, the finite public coordinates are computed
from the original configuration; native meaning is exactly its existing binding. -/
theorem expected_meaning_iff
    (base : Operational.Config (sheaf B) Owner Asset Receipt)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32)
    (transfer : Operational.ResourceTransfer Owner)
    (O : TCB.BoundHCPObservation (integralStructure B)
      payload PublicClass Lifecycle classify Binds) :
    Meaning base identify parameters
        (Statement.subjectFor base (publicProfile rows cols) none .nativeCiphertext
          (base.intentFor transfer)) O ↔
      Storage.NativeManifest.BindsOriginal base.manifest O identify parameters := by
  constructor
  · exact meaning_binds
  · intro bound
    exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, bound⟩

/-- The raw operational checker executes the selected verifier on the actual
native subject. Its context and ciphertext remain unconstrained raw inputs. -/
def config (base : Operational.Config (sheaf B) Owner Asset Receipt)
    (verify : Bytes → Bytes → Bool) : Operational.Config (sheaf B) Owner Asset Receipt :=
  Statement.withVerifier base (publicProfile rows cols) none .nativeCiphertext verify

/-- Declared native proof statement with canonical decoding; no soundness law
is attached to the selected Boolean verification algorithm. -/
def backend (base : Operational.Config (sheaf B) Owner Asset Receipt)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32)
    (verify : Bytes → Bytes → Bool) : TCB.PrimitiveChecks.ProofVerifier :=
  Statement.backend base.codec
    (Meaning (payload := payload) (classify := classify) (Binds := Binds)
      base identify parameters) verify

/-- Native public-input truth is precisely existence of the existing binding
for the same manifest, rather than an assumed free reflection premise. -/
theorem expected_holds_iff
    (base : Operational.Config (sheaf B) Owner Asset Receipt)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32)
    (verify : Bytes → Bytes → Bool) (transfer : Operational.ResourceTransfer Owner) :
    (backend (payload := payload) (classify := classify) (Binds := Binds)
      base identify parameters verify).Holds
        (Codec.encode base.codec
          (Statement.subjectFor base (publicProfile rows cols) none .nativeCiphertext
            (base.intentFor transfer))) ↔
      ∃ O : TCB.BoundHCPObservation (integralStructure B)
          payload PublicClass Lifecycle classify Binds,
        Storage.NativeManifest.BindsOriginal base.manifest O identify parameters := by
  change (Statement.backend base.codec
    (Meaning (payload := payload) (classify := classify) (Binds := Binds)
      base identify parameters) verify).Holds _ ↔ _
  rw [Statement.holds_encode_iff]
  constructor
  · rintro ⟨O, means⟩
    exact ⟨O, meaning_binds means⟩
  · rintro ⟨O, bound⟩
    exact ⟨O, (expected_meaning_iff base identify parameters transfer O).2 bound⟩

/-- The constructed native operational configuration and its intended backend
have exact algorithm agreement on the actual encoded public subject. -/
def payloadProfile (base : Operational.Config (sheaf B) Owner Asset Receipt)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32)
    (verify : Bytes → Bytes → Bool) : Primitives.PayloadProfile (config base verify) :=
  Statement.payloadProfile base (publicProfile rows cols) none .nativeCiphertext
    (Meaning (payload := payload) (classify := classify) (Binds := Binds)
      base identify parameters) verify

/-- Actual packet checking yields an original native certificate on this
same manifest or false acceptance at this exact subject and proof bytes. -/
theorem checked_native_certificate_or_falseAccept
    (base : Operational.Config (sheaf B) Owner Asset Receipt)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32)
    (verify : Bytes → Bytes → Bool)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer (config base verify) transfer bytes) :
    (∃ O : TCB.BoundHCPObservation (integralStructure B)
        payload PublicClass Lifecycle classify Binds,
      Storage.NativeManifest.BindsOriginal base.manifest O identify parameters) ∨
      (backend (payload := payload) (classify := classify) (Binds := Binds)
        base identify parameters verify).FalseAccept
        (Codec.encode base.codec
          (Statement.subjectFor base (publicProfile rows cols) none .nativeCiphertext
            (base.intentFor transfer)))
        checked.proof.packet.proofBytes := by
  have result := Statement.checked_certificate_or_falseAccept
    base (publicProfile rows cols) none .nativeCiphertext
    (Meaning (payload := payload) (classify := classify) (Binds := Binds)
      base identify parameters) verify checked
  rcases result with certificate | falseAccept
  · obtain ⟨O, means⟩ := certificate
    exact Or.inl ⟨O, meaning_binds means⟩
  · exact Or.inr falseAccept

/-- Missing native certification after actual checking is a false acceptance
for the constructed native statement, not an unaccounted statement mismatch. -/
theorem missing_native_certificate_implies_falseAccept
    (base : Operational.Config (sheaf B) Owner Asset Receipt)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32)
    (verify : Bytes → Bytes → Bool)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer (config base verify) transfer bytes)
    (missing : ¬ ∃ O : TCB.BoundHCPObservation (integralStructure B)
        payload PublicClass Lifecycle classify Binds,
      Storage.NativeManifest.BindsOriginal base.manifest O identify parameters) :
    (backend (payload := payload) (classify := classify) (Binds := Binds)
      base identify parameters verify).FalseAccept
      (Codec.encode base.codec
        (Statement.subjectFor base (publicProfile rows cols) none .nativeCiphertext
          (base.intentFor transfer)))
      checked.proof.packet.proofBytes := by
  rcases checked_native_certificate_or_falseAccept
    (payload := payload) (classify := classify) (Binds := Binds)
    base identify parameters verify checked with certificate | falseAccept
  · exact False.elim (missing certificate)
  · exact falseAccept

/-- Malformed full ciphertext bytes cannot bind any original native observation,
although their raw operational configuration and raw manifest still exist. -/
theorem no_native_certificate_of_malformed
    (base : Operational.Config (sheaf B) Owner Asset Receipt)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32)
    (malformed : Storage.CoupledCiphertext.decodeReal rows cols base.ciphertext = none) :
    ¬ ∃ O : TCB.BoundHCPObservation (integralStructure B)
        payload PublicClass Lifecycle classify Binds,
      Storage.NativeManifest.BindsOriginal base.manifest O identify parameters := by
  rintro ⟨O, bound⟩
  have decoded : Storage.CoupledCiphertext.decodeReal rows cols base.ciphertext =
      some O.cochainObject := bound.ciphertext_bound.1
  rw [malformed] at decoded
  cases decoded

/-- If the actual checker accepts malformed ciphertext under this selected
native profile, its exact packet proof is a backend false acceptance. -/
theorem malformed_checked_implies_falseAccept
    (base : Operational.Config (sheaf B) Owner Asset Receipt)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32)
    (verify : Bytes → Bytes → Bool)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer (config base verify) transfer bytes)
    (malformed : Storage.CoupledCiphertext.decodeReal rows cols base.ciphertext = none) :
    (backend (payload := payload) (classify := classify) (Binds := Binds)
      base identify parameters verify).FalseAccept
      (Codec.encode base.codec
        (Statement.subjectFor base (publicProfile rows cols) none .nativeCiphertext
          (base.intentFor transfer)))
      checked.proof.packet.proofBytes :=
  missing_native_certificate_implies_falseAccept
    (payload := payload) (classify := classify) (Binds := Binds)
    base identify parameters verify checked
    (no_native_certificate_of_malformed
      (payload := payload) (classify := classify) (Binds := Binds)
      base identify parameters malformed)

end HomotopicalEncryption.Protocol.Transfer.Certificates.Native
