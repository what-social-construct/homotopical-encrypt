module

public import Protocol.Transfer.Certificates.Bundle
public import Protocol.Transfer.Certificates.Calibration
public import Protocol.Transfer.Certificates.Statement
public import Protocol.Storage.Projection

@[expose] public section

/-!
# The actual projection certificate and every preceding byte check

The selected level reuses the existing hard, naturality or calibrated-final
record and its exact certificate, including the chosen chart/metric data.
It does not replace that object with a profile identifier. Public profile
bytes describe the selected trusted interpretation; encoding those bytes
does not construct its circuit or authenticate its registration.

An operational proof is one canonically encoded immutable seven-slot bundle.
The selected level checks every required predecessor against its exact
intent/metadata/ciphertext/profile subject. All seven leaves name their actual
subjects and proof bytes under one computed root. Only final certification
requires an exact rational realization of the selected real calibration.

The intended backend statement retains the actual certificate and original
cochain/chain equality. Its reflection is proved by decoding. The underlying
Boolean proof algorithm still has an explicit false-acceptance alternative;
no proof-system soundness, knowledge or finality follows from its declaration.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.Certificates.Projection

open Sheaf CellularSheaf
open Proximity Proximity.GrassmannianPlucker
open Proximity.Gates.Projection Proximity.GateEvidence.Projection
open _root_.HomotopicalEncryption.Protocol.Evidence.TransferTranscript

abbrev Bytes := List UInt8

variable {Vertex Edge Face Owner Asset Receipt : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {Fsheaf : CellularSheaf X}
  {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
  {R K ι : Type} [Field K] [Fintype K] [Fintype ι] [DecidableEq K]
  {P : FramedSystem n r} {S : Axioms.SheafCoherence}
  {L : PluckerCochain.LocalSyndromeTarget S}
  {T : ReedSolomonTarget.Target K ι}
  {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
  {E : CochainPlane.PlaneExtractionContext R ι}
  {Φ : CochainReedSolomon.PlaneEncoding R K}
  {sourceDisagreement : FrameWitness n r → ℝ}

/-- These are aliases of the existing mathematical certificate carriers. -/
def Certificate
    (Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement)
    (κ : RadiusCalibration) : Evidence.Level → Type
  | .hard => HardGateCertificate Γ
  | .naturality => NaturalityGateCertificate Γ
  | .final => CalibratedFinalCertificate Γ κ

/-- These are the existing evidence records, including their actual database. -/
def Record (runtime : TCB.RuntimeBoundary)
    (Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement)
    (κ : RadiusCalibration) : Evidence.Level → Type
  | .hard => HardGateEvidenceRecord runtime Γ
  | .naturality => NaturalityGateEvidenceRecord runtime Γ
  | .final => CalibratedFinalEvidenceRecord runtime Γ κ

def Record.certificate {runtime : TCB.RuntimeBoundary}
    {Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement}
    {κ : RadiusCalibration} {level : Evidence.Level} :
    Record runtime Γ κ level → Certificate Γ κ level := by
  cases level with
  | hard => exact fun record => HardGateEvidenceRecord.hardGateCertificate record
  | naturality => exact fun record => NaturalityGateEvidenceRecord.certificate record
  | final => exact fun record => CalibratedFinalEvidenceRecord.finalCertificate record

def Record.database {runtime : TCB.RuntimeBoundary}
    {Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement}
    {κ : RadiusCalibration} {level : Evidence.Level} :
    Record runtime Γ κ level → EvidenceDatabase runtime := by
  cases level with
  | hard => exact fun record => HardGateEvidenceRecord.database record
  | naturality => exact fun record =>
      HardGateEvidenceRecord.database (NaturalityGateEvidenceRecord.hardGateRecord record)
  | final => exact fun record =>
      HardGateEvidenceRecord.database (NaturalityGateEvidenceRecord.hardGateRecord
        (CalibratedFinalEvidenceRecord.naturalityGateRecord record))

/-- Earlier levels do not assert a far-radius comparison. Final certification
must identify all four actual real radii with the finite rational descriptor. -/
def CalibrationBinds (level : Evidence.Level) (descriptor : Option Codec.Calibration)
    (κ : RadiusCalibration) : Prop :=
  level = .final → ∃ rational, descriptor = some rational ∧ rational.Realizes κ

/-- Meaning is indexed by the actual original chain, cochain and retained
record, not by a detached profile name. The certificate equality retains the
chosen metric functions as well as its proposition-valued proofs. -/
def Meaning
    (base : Operational.Config Fsheaf Owner Asset Receipt)
    (Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement)
    (W : FrameWitness n r) (κ : RadiusCalibration)
    (level : Evidence.Level) {runtime : TCB.RuntimeBoundary}
    (record : Record runtime Γ κ level)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (subject : Codec.Subject Owner) (certificate : Certificate Γ κ level) : Prop :=
  subject.metadata = base.metadata ∧
    subject.intent.base = base.context.publicView ∧
    subject.intent.manifestRoot = base.manifest.root ∧
    subject.ciphertextDigest = base.ciphertextDigest ∧
    subject.profile = publicProfile ∧ subject.calibration = calibration ∧
    (∃ slot, Evidence.Required level slot ∧ subject.claim = Evidence.claimFor slot) ∧
    Nonempty (Storage.Projection.Input base.context Γ W) ∧
    CalibrationBinds level calibration κ ∧ certificate = record.certificate

/-- Exact subjects for the same original intent at every gate position. -/
def subjects (base : Operational.Config Fsheaf Owner Asset Receipt)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (intent : Intent Owner) (slot : EvidenceSlot) : Codec.Subject Owner :=
  Statement.subjectFor base publicProfile calibration (Evidence.claimFor slot) intent

/-- The selected backend must prove the actual record-indexed statement.
This declaration alone imposes no soundness law on its checking algorithm. -/
def leafBackend
    (base : Operational.Config Fsheaf Owner Asset Receipt)
    (Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement)
    (W : FrameWitness n r) (κ : RadiusCalibration)
    (level : Evidence.Level) {runtime : TCB.RuntimeBoundary}
    (record : Record runtime Γ κ level)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (verify : Bytes → Bytes → Bool) : TCB.PrimitiveChecks.ProofVerifier :=
  Statement.backend base.codec (Meaning base Γ W κ level record publicProfile calibration) verify

/-- Actual packet proof bytes are parsed as a bundle and all predecessor
checks execute. No new semantic validity premise is added to the raw config. -/
def config (base : Operational.Config Fsheaf Owner Asset Receipt)
    (level : Evidence.Level) (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (leaf : TCB.PrimitiveChecks.ProofVerifier) : Operational.Config Fsheaf Owner Asset Receipt :=
  Statement.withVerifier base publicProfile calibration (Bundle.terminalClaim level)
    (Bundle.backend base.codec level leaf).verify

/-- Successful checking of the actual transfer packet entails every required
bundle check at the original intent, metadata and ciphertext name. -/
theorem checked_prefix
    (base : Operational.Config Fsheaf Owner Asset Receipt)
    (level : Evidence.Level) (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (leaf : TCB.PrimitiveChecks.ProofVerifier)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer
      (config base level publicProfile calibration leaf) transfer bytes) :
    Bundle.verifyPrefix base.codec leaf level
      (Bundle.expectedSubjects (Statement.subjectFor base publicProfile calibration
        (Bundle.terminalClaim level) (base.intentFor transfer)))
      checked.proof.packet.proofBytes = true := by
  have verified := checked.proof.proofVerified_expected
  change (Bundle.backend base.codec level leaf).verify
    (Codec.encode base.codec (Statement.subjectFor base publicProfile calibration
      (Bundle.terminalClaim level) (base.intentFor transfer)))
    checked.proof.packet.proofBytes = true at verified
  simpa only [Bundle.backend, Codec.decode_encode] using verified

/-- The final operational packet cannot skip either preceding verification
level. Both facts concern its exact same encoded bundle and subjects. -/
theorem checked_final_requires_previous
    (base : Operational.Config Fsheaf Owner Asset Receipt)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (leaf : TCB.PrimitiveChecks.ProofVerifier)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer
      (config base .final publicProfile calibration leaf) transfer bytes) :
    let expected := Bundle.expectedSubjects (Statement.subjectFor base publicProfile calibration
      (Bundle.terminalClaim .final) (base.intentFor transfer))
    Bundle.verifyPrefix base.codec leaf .hard expected checked.proof.packet.proofBytes = true ∧
      Bundle.verifyPrefix base.codec leaf .naturality expected checked.proof.packet.proofBytes = true := by
  have finalChecked := checked_prefix base .final publicProfile calibration leaf checked
  exact ⟨Bundle.final_requires_hard base.codec leaf _ _ finalChecked,
    Bundle.final_requires_naturality base.codec leaf _ _ finalChecked⟩

/-- A failed earlier gate rejects the actual later transfer checker, without
assuming that any cryptographic backend is sound. -/
theorem reject_of_previous_failed
    (base : Operational.Config Fsheaf Owner Asset Receipt)
    (earlier later : Evidence.Level) (publicProfile : Bytes)
    (calibration : Option Codec.Calibration) (leaf : TCB.PrimitiveChecks.ProofVerifier)
    (transfer : Operational.ResourceTransfer Owner) (bytes : Bytes)
    (packet : ProofPacket Owner)
    (decoded : base.codec.decode bytes = some packet)
    (ordered : earlier.count ≤ later.count)
    (failed : Bundle.verifyPrefix base.codec leaf earlier
      (Bundle.expectedSubjects (Statement.subjectFor base publicProfile calibration
        (Bundle.terminalClaim later) (base.intentFor transfer))) packet.proofBytes = false) :
    Operational.check (config base later publicProfile calibration leaf) transfer bytes = false := by
  cases outcome : Operational.check (config base later publicProfile calibration leaf) transfer bytes with
  | false => rfl
  | true =>
    have checked := Operational.CheckedTransfer.ofCheck outcome
    have packetEq : checked.proof.packet = packet :=
      Option.some.inj (checked.proof.decoded.symm.trans decoded)
    have laterChecked := checked_prefix base later publicProfile calibration leaf checked
    rw [packetEq] at laterChecked
    have previous := Bundle.verifyPrefix_mono base.codec leaf earlier later _ _ ordered laterChecked
    rw [failed] at previous
    contradiction

/-- Canonical intended-statement reflection is instantiated with the actual
accumulated certificate. Any false acceptance is traced to the terminal proof
inside the actual submitted bundle; prior Boolean checks are also required. -/
theorem checked_certificate_or_leaf_falseAccept
    (base : Operational.Config Fsheaf Owner Asset Receipt)
    (Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement)
    (W : FrameWitness n r) (κ : RadiusCalibration)
    (level : Evidence.Level) {runtime : TCB.RuntimeBoundary}
    (record : Record runtime Γ κ level)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (verify : Bytes → Bytes → Bool)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer
      (config base level publicProfile calibration
        (leafBackend base Γ W κ level record publicProfile calibration verify)) transfer bytes) :
    (∃ certificate, Meaning base Γ W κ level record publicProfile calibration
      (Statement.subjectFor base publicProfile calibration
        (Bundle.terminalClaim level) (base.intentFor transfer)) certificate) ∨
      ∃ bundle : Certificates.Bundle Owner,
        Bundle.decode base.codec checked.proof.packet.proofBytes = some bundle ∧
          (leafBackend base Γ W κ level record publicProfile calibration verify).FalseAccept
            (Codec.encode base.codec (Statement.subjectFor base publicProfile calibration
              (Bundle.terminalClaim level) (base.intentFor transfer)))
            (bundle.entries (Bundle.terminalSlot level)).proof := by
  let leaf := leafBackend base Γ W κ level record publicProfile calibration verify
  let means := Meaning base Γ W κ level record publicProfile calibration
  let top := Statement.subjectFor base publicProfile calibration
    (Bundle.terminalClaim level) (base.intentFor transfer)
  rcases Statement.checked_certificate_or_falseAccept base publicProfile calibration
      (Bundle.terminalClaim level) means (Bundle.backend base.codec level leaf).verify
      checked with certified | bad
  · exact Or.inl certified
  · apply Or.inr
    have wrapperBad : (Bundle.backend base.codec level leaf).FalseAccept
        (Codec.encode base.codec top) checked.proof.packet.proofBytes := bad
    exact Bundle.backend_falseAccept_to_leaf base.codec level leaf _ _ top rfl rfl wrapperBad

/-- The byte binding refers to the database of this exact retained record.
It does not turn the legacy slot-only propositions into codec theorems. -/
def DatabaseBound
    (base : Operational.Config Fsheaf Owner Asset Receipt)
    (hash : Bytes → TCB.Hash32)
    {Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement}
    {κ : RadiusCalibration} {runtime : TCB.RuntimeBoundary} {level : Evidence.Level}
    (record : Record runtime Γ κ level) (bundle : Certificates.Bundle Owner) : Prop :=
  Evidence.DatabaseBinds base.codec hash level bundle.subjects bundle.proofs record.database

/-- Compare the actual immutable database with the complete decoded bundle.
These are executable byte/hash equations, not the legacy `SlotBinds` labels. -/
def checkDatabase
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (hash : Bytes → TCB.Hash32) {runtime : TCB.RuntimeBoundary}
    (database : EvidenceDatabase runtime) (bytes : Bytes) : Bool :=
  match Bundle.decode codec bytes with
  | none => false
  | some bundle =>
    decide (database.rootDigest = Evidence.rootDigest codec hash bundle.subjects bundle.proofs) &&
      (Evidence.slots .final).all fun slot => decide (database.slotDigest slot =
        Evidence.leafDigest codec hash bundle.subjects bundle.proofs slot)

theorem checkDatabase_eq_true_iff
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (hash : Bytes → TCB.Hash32) {runtime : TCB.RuntimeBoundary}
    (database : EvidenceDatabase runtime) (bytes : Bytes) :
    checkDatabase codec hash database bytes = true ↔
      ∃ bundle : Certificates.Bundle Owner, Bundle.decode codec bytes = some bundle ∧
        database.rootDigest = Evidence.rootDigest codec hash bundle.subjects bundle.proofs ∧
        ∀ slot, database.slotDigest slot =
          Evidence.leafDigest codec hash bundle.subjects bundle.proofs slot := by
  have allRequired (slot : EvidenceSlot) : Evidence.Required .final slot := slot.isLt
  cases parsed : Bundle.decode codec bytes with
  | none => simp [checkDatabase, parsed]
  | some bundle =>
    simp only [checkDatabase, parsed, Bool.and_eq_true_iff, decide_eq_true_eq,
      List.all_eq_true, Evidence.mem_slots_iff, Option.some.injEq, exists_eq_left']
    exact ⟨fun ⟨root, bound⟩ => ⟨root, fun slot => bound slot (allRequired slot)⟩,
      fun ⟨root, bound⟩ => ⟨root, fun slot _ => bound slot⟩⟩

/-- The selected actual record supplies the database checked by the packet's
payload algorithm. Context, original intent and manifest remain unchanged. -/
def boundConfig (base : Operational.Config Fsheaf Owner Asset Receipt)
    (hash : Bytes → TCB.Hash32)
    {Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement}
    {κ : RadiusCalibration} {runtime : TCB.RuntimeBoundary} {level : Evidence.Level}
    (record : Record runtime Γ κ level)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (leaf : TCB.PrimitiveChecks.ProofVerifier) : Operational.Config Fsheaf Owner Asset Receipt :=
  Statement.withVerifier base publicProfile calibration (Bundle.terminalClaim level)
    (fun input bytes => (Bundle.backend base.codec level leaf).verify input bytes &&
      checkDatabase base.codec hash record.database bytes)

/-- Forget only the additional database hash checks, retaining the exact
parsed packet and all successful predecessor proof checks. -/
def checkedPrefixOfBound
    (base : Operational.Config Fsheaf Owner Asset Receipt) (hash : Bytes → TCB.Hash32)
    {Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement}
    {κ : RadiusCalibration} {runtime : TCB.RuntimeBoundary} {level : Evidence.Level}
    (record : Record runtime Γ κ level)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (leaf : TCB.PrimitiveChecks.ProofVerifier)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer
      (boundConfig base hash record publicProfile calibration leaf) transfer bytes) :
    Operational.CheckedTransfer (config base level publicProfile calibration leaf) transfer bytes where
  prechecks := ⟨checked.prechecks.resources, checked.prechecks.snapshotMatches,
    checked.prechecks.leafMatches⟩
  proof :=
    { packet := checked.proof.packet
      decoded := checked.proof.decoded
      canonical := checked.proof.canonical
      metadata_eq := checked.proof.metadata_eq
      intent_eq := checked.proof.intent_eq
      signatureVerified := checked.proof.signatureVerified
      proofVerified := (Bool.and_eq_true_iff.mp checked.proof.proofVerified).1 }

/-- Actual acceptance derives the concrete byte binding to this very record
and every required predecessor verification from the same parsed packet. -/
theorem checked_bound_record
    (base : Operational.Config Fsheaf Owner Asset Receipt) (hash : Bytes → TCB.Hash32)
    {Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement}
    {κ : RadiusCalibration} {runtime : TCB.RuntimeBoundary} {level : Evidence.Level}
    (record : Record runtime Γ κ level)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (leaf : TCB.PrimitiveChecks.ProofVerifier)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer
      (boundConfig base hash record publicProfile calibration leaf) transfer bytes) :
    ∃ bundle : Certificates.Bundle Owner,
      Bundle.decode base.codec checked.proof.packet.proofBytes = some bundle ∧
      DatabaseBound base hash record bundle ∧
      ∀ slot, Evidence.Required level slot →
        (bundle.entries slot).subject = subjects base publicProfile calibration (base.intentFor transfer) slot ∧
          leaf.verify (Codec.encode base.codec
            (subjects base publicProfile calibration (base.intentFor transfer) slot))
            (bundle.entries slot).proof = true := by
  have verified := checked.proof.proofVerified_expected
  change ((Bundle.backend base.codec level leaf).verify
    (Codec.encode base.codec (Statement.subjectFor base publicProfile calibration
      (Bundle.terminalClaim level) (base.intentFor transfer))) checked.proof.packet.proofBytes &&
    checkDatabase base.codec hash record.database checked.proof.packet.proofBytes) = true at verified
  obtain ⟨prefixChecked, database⟩ := Bool.and_eq_true_iff.mp verified
  simp only [Bundle.backend, Codec.decode_encode] at prefixChecked
  obtain ⟨bundle, decoded, gates⟩ := (Bundle.verifyPrefix_eq_true_iff _ _ _ _ _).1 prefixChecked
  obtain ⟨stored, storedDecoded, root, leaves⟩ := (checkDatabase_eq_true_iff _ _ _ _).1 database
  have same : stored = bundle := Option.some.inj (storedDecoded.symm.trans decoded)
  subst stored
  refine ⟨bundle, decoded, ⟨fun slot required => (gates slot required).2.1, leaves, root⟩, ?_⟩
  intro slot required
  exact ⟨(gates slot required).1, (gates slot required).2.2⟩

/-- The preferred database-bound packet has the same certificate-or-primitive
failure guarantee, at the exact terminal proof inside those submitted bytes. -/
theorem checked_bound_certificate_or_leaf_falseAccept
    (base : Operational.Config Fsheaf Owner Asset Receipt) (hash : Bytes → TCB.Hash32)
    (Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement)
    (W : FrameWitness n r) (κ : RadiusCalibration)
    (level : Evidence.Level) {runtime : TCB.RuntimeBoundary}
    (record : Record runtime Γ κ level)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (verify : Bytes → Bytes → Bool)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer
      (boundConfig base hash record publicProfile calibration
        (leafBackend base Γ W κ level record publicProfile calibration verify)) transfer bytes) :
    (∃ certificate, Meaning base Γ W κ level record publicProfile calibration
      (Statement.subjectFor base publicProfile calibration
        (Bundle.terminalClaim level) (base.intentFor transfer)) certificate) ∨
      ∃ bundle : Certificates.Bundle Owner,
        Bundle.decode base.codec checked.proof.packet.proofBytes = some bundle ∧
          (leafBackend base Γ W κ level record publicProfile calibration verify).FalseAccept
            (Codec.encode base.codec (Statement.subjectFor base publicProfile calibration
              (Bundle.terminalClaim level) (base.intentFor transfer)))
            (bundle.entries (Bundle.terminalSlot level)).proof :=
  checked_certificate_or_leaf_falseAccept base Γ W κ level record publicProfile calibration verify
    (checkedPrefixOfBound base hash record publicProfile calibration _ checked)

/-- Even the database-bound checker rejects a failed preceding gate, regardless
of backend soundness. Hash/root matches cannot waive a failed prefix. -/
theorem reject_bound_of_previous_failed
    (base : Operational.Config Fsheaf Owner Asset Receipt) (hash : Bytes → TCB.Hash32)
    {Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement}
    {κ : RadiusCalibration} {runtime : TCB.RuntimeBoundary} {later : Evidence.Level}
    (record : Record runtime Γ κ later) (earlier : Evidence.Level)
    (publicProfile : Bytes) (calibration : Option Codec.Calibration)
    (leaf : TCB.PrimitiveChecks.ProofVerifier)
    (transfer : Operational.ResourceTransfer Owner) (bytes : Bytes)
    (packet : ProofPacket Owner) (decoded : base.codec.decode bytes = some packet)
    (ordered : earlier.count ≤ later.count)
    (failed : Bundle.verifyPrefix base.codec leaf earlier
      (Bundle.expectedSubjects (Statement.subjectFor base publicProfile calibration
        (Bundle.terminalClaim later) (base.intentFor transfer))) packet.proofBytes = false) :
    Operational.check (boundConfig base hash record publicProfile calibration leaf) transfer bytes = false := by
  have rejected := reject_of_previous_failed base earlier later publicProfile calibration leaf
    transfer bytes packet decoded ordered failed
  cases outcome : Operational.check (boundConfig base hash record publicProfile calibration leaf) transfer bytes with
  | false => rfl
  | true =>
    have lower := checkedPrefixOfBound base hash record publicProfile calibration leaf
      (Operational.CheckedTransfer.ofCheck outcome)
    have accepted := lower.check_true
    rw [rejected] at accepted
    contradiction

/-- A naturality record retains the exact hard database and all its leaf bytes. -/
theorem naturality_database_requires_hard
    (base : Operational.Config Fsheaf Owner Asset Receipt) (hash : Bytes → TCB.Hash32)
    {Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement}
    {κ : RadiusCalibration} {runtime : TCB.RuntimeBoundary}
    (record : NaturalityGateEvidenceRecord runtime Γ) (bundle : Certificates.Bundle Owner)
    (bound : DatabaseBound base hash (κ := κ) (level := .naturality) record bundle) :
    DatabaseBound base hash (κ := κ) (level := .hard) record.hardGateRecord bundle :=
  Evidence.DatabaseBinds.mono base.codec hash .hard .naturality
    bundle.subjects bundle.proofs (by decide) bound

/-- Final certification retains the same naturality/hard database; its
verification level changes neither the committed bundle nor its root. -/
theorem final_database_requires_naturality
    (base : Operational.Config Fsheaf Owner Asset Receipt) (hash : Bytes → TCB.Hash32)
    {Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement}
    {κ : RadiusCalibration} {runtime : TCB.RuntimeBoundary}
    (record : CalibratedFinalEvidenceRecord runtime Γ κ) (bundle : Certificates.Bundle Owner)
    (bound : DatabaseBound base hash (level := .final) record bundle) :
    DatabaseBound base hash (κ := κ) (level := .naturality) record.naturalityGateRecord bundle :=
  Evidence.DatabaseBinds.mono base.codec hash .naturality .final
    bundle.subjects bundle.proofs (by decide) bound

/-- The certificate's mathematical predecessor is the exact retained hard
certificate, including its chart/metric choices. -/
theorem final_retains_hard_certificate
    {Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement}
    {κ : RadiusCalibration} {runtime : TCB.RuntimeBoundary}
    (record : CalibratedFinalEvidenceRecord runtime Γ κ) :
    record.finalCertificate.previous.previous =
      record.naturalityGateRecord.hardGateRecord.certificate := rfl

end HomotopicalEncryption.Protocol.Transfer.Certificates.Projection
