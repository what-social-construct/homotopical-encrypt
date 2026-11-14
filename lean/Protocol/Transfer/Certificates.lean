module

public import Protocol.Transfer.Primitives

@[expose] public section

/-!
# Certificate reflection for actual checked transfers

This leaf reuses the original operational checker and selected payload profile.
Its certificate relation is indexed by the exact expected public intent. A
concrete relation must bind the actual context, roots, ciphertext digest,
projection profile, calibration and proof metadata as appropriate to its claim;
equality of a statement name or an evidence slot alone is insufficient. The
slot-only propositions in `Proximity.GateEvidence.Projection.EvidenceDatabase`
do not instantiate this relation. The selected construction in this module's
`Codec`, `Statement`, `Native` and `Projection` leaves supplies finite public
subjects, actual subject/proof digest binding and encoding/statement reflection.
Concrete circuit/CRS refinement and cryptographic soundness remain obligations.

Successful checking is retained at the actual packet proof bytes and original
expected intent. Without a reflection contract, a missing required certificate
is either backend false acceptance or a mismatch between the backend statement
and that certificate requirement. Ledger validity does not remove this case.
With reflection, a true backend statement supplies a logically existing bound
certificate. This is not witness extraction, a knowledge theorem, serialization
of a private certificate, or a universal proof-backend soundness assumption.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.Certificates

open Sheaf CellularSheaf
open Evidence.TransferTranscript

/-- The selected backend statement entails a certificate bound to this exact
intent. The relation, not a certificate type or public label alone, specifies
which original objects and parameters are certified. -/
def ReflectsCertificates
    {Vertex Edge Face Owner Asset Receipt Certificate : Type}
    [Fintype Vertex] [Fintype Edge] [Fintype Face]
    {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}
    {config : Operational.Config F Owner Asset Receipt}
    (profile : Primitives.PayloadProfile config)
    (Binds : Intent Owner → Certificate → Prop) : Prop :=
  ∀ intent, profile.backend.Holds (profile.inputFor intent) →
    ∃ certificate, Binds intent certificate

/-- The actual checked proof executes the selected backend on the exact expected
intent. No backend statement truth is inferred from this execution equation. -/
theorem checked_backend_verified
    {Vertex Edge Face Owner Asset Receipt : Type}
    [Fintype Vertex] [Fintype Edge] [Fintype Face]
    {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}
    {config : Operational.Config F Owner Asset Receipt}
    {transfer : Operational.ResourceTransfer Owner} {bytes : List UInt8}
    (profile : Primitives.PayloadProfile config)
    (checked : Operational.CheckedTransfer config transfer bytes) :
    profile.backend.verify (profile.inputFor (config.intentFor transfer))
      checked.proof.packet.proofBytes = true :=
  (profile.agrees (config.intentFor transfer) checked.proof.packet.proofBytes).symm.trans
    checked.proof.proofVerified_expected

/-- Certificate reflection turns a true backend statement into a certificate for
the exact checked intent; the alternative is this actual proof's false acceptance. -/
theorem checked_certificate_or_falseAccept
    {Vertex Edge Face Owner Asset Receipt Certificate : Type}
    [Fintype Vertex] [Fintype Edge] [Fintype Face]
    {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}
    {config : Operational.Config F Owner Asset Receipt}
    {transfer : Operational.ResourceTransfer Owner} {bytes : List UInt8}
    (profile : Primitives.PayloadProfile config)
    (Binds : Intent Owner → Certificate → Prop)
    (checked : Operational.CheckedTransfer config transfer bytes)
    (reflection : ReflectsCertificates profile Binds) :
    (∃ certificate, Binds (config.intentFor transfer) certificate) ∨
      profile.backend.FalseAccept (profile.inputFor (config.intentFor transfer))
        checked.proof.packet.proofBytes := by
  rcases profile.backend.verified_cases _ _ (checked_backend_verified profile checked) with
    holds | falseAccept
  · exact Or.inl (reflection (config.intentFor transfer) holds)
  · exact Or.inr falseAccept

/-- Without reflection, actual checking with no required certificate exposes
either false acceptance or the precise backend/certificate statement mismatch. -/
theorem missing_certificate_implies_cases
    {Vertex Edge Face Owner Asset Receipt Certificate : Type}
    [Fintype Vertex] [Fintype Edge] [Fintype Face]
    {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}
    {config : Operational.Config F Owner Asset Receipt}
    {transfer : Operational.ResourceTransfer Owner} {bytes : List UInt8}
    (profile : Primitives.PayloadProfile config)
    (Binds : Intent Owner → Certificate → Prop)
    (checked : Operational.CheckedTransfer config transfer bytes)
    (missing : ¬ ∃ certificate, Binds (config.intentFor transfer) certificate) :
    profile.backend.FalseAccept (profile.inputFor (config.intentFor transfer))
        checked.proof.packet.proofBytes ∨
      (profile.backend.Holds (profile.inputFor (config.intentFor transfer)) ∧
        ¬ ∃ certificate, Binds (config.intentFor transfer) certificate) := by
  rcases profile.backend.verified_cases _ _ (checked_backend_verified profile checked) with
    holds | falseAccept
  · exact Or.inr ⟨holds, missing⟩
  · exact Or.inl falseAccept

/-- A ledger-valid checked candidate can still lack its required certificate.
The ledger-validity fact is preserved alongside the same concrete failure cases. -/
theorem missing_certificate_with_valid_candidate_implies_cases
    {Vertex Edge Face Owner Asset Receipt Certificate : Type}
    [Fintype Vertex] [Fintype Edge] [Fintype Face] [DecidableEq Asset]
    {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}
    {config : Operational.Config F Owner Asset Receipt}
    {transfer : Operational.ResourceTransfer Owner} {bytes : List UInt8}
    (profile : Primitives.PayloadProfile config)
    (Binds : Intent Owner → Certificate → Prop)
    (checked : Operational.CheckedTransfer config transfer bytes)
    (valid : checked.candidate.Valid config.policy)
    (missing : ¬ ∃ certificate, Binds (config.intentFor transfer) certificate) :
    checked.candidate.Valid config.policy ∧
      (profile.backend.FalseAccept (profile.inputFor (config.intentFor transfer))
          checked.proof.packet.proofBytes ∨
        (profile.backend.Holds (profile.inputFor (config.intentFor transfer)) ∧
          ¬ ∃ certificate, Binds (config.intentFor transfer) certificate)) :=
  ⟨valid, missing_certificate_implies_cases profile Binds checked missing⟩

/-- Reflection and exclusion of false acceptance for this actual checked proof
suffice for logical existence of its exactly bound certificate. -/
theorem checked_certificate_of_no_falseAccept
    {Vertex Edge Face Owner Asset Receipt Certificate : Type}
    [Fintype Vertex] [Fintype Edge] [Fintype Face]
    {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}
    {config : Operational.Config F Owner Asset Receipt}
    {transfer : Operational.ResourceTransfer Owner} {bytes : List UInt8}
    (profile : Primitives.PayloadProfile config)
    (Binds : Intent Owner → Certificate → Prop)
    (checked : Operational.CheckedTransfer config transfer bytes)
    (reflection : ReflectsCertificates profile Binds)
    (noFalseAccept : ¬ profile.backend.FalseAccept
      (profile.inputFor (config.intentFor transfer)) checked.proof.packet.proofBytes) :
    ∃ certificate, Binds (config.intentFor transfer) certificate := by
  rcases checked_certificate_or_falseAccept profile Binds checked reflection with
    certificate | falseAccept
  · exact certificate
  · exact False.elim (noFalseAccept falseAccept)

end HomotopicalEncryption.Protocol.Transfer.Certificates
