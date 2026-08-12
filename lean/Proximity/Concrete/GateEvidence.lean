import Proximity.Concrete.Gates
import TCB.ProofCarrying

/-
  Traceable hard-gate evidence records.

  Paper correspondence:
  - Paper 1 Section 6: proximity gate evidence boundary.
  - Paper 2: runtime-owned evidence database, roots, and inclusion checks.

  The mathematical hard-gate certificate lives in `Proximity.Gates`. This file
  adds a verified-database style trace surface: a fixed-position array of
  evidence digests, a root digest, and runtime-owned binding/inclusion facts.
  Hashes and roots are evidence handles, not replacements for the Lean
  certificate.
-/

namespace Hcrypt
namespace Proximity
namespace GateEvidence

open GrassmannianPlucker

noncomputable section

variable {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
variable {R F ι : Type}
variable [Field F] [Fintype F] [Fintype ι] [DecidableEq F]

namespace Projection

variable
    {P : FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {T : ReedSolomonTarget.Target F ι}
    {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
    {E : CochainPlane.PlaneExtractionContext R ι}
    {Φ : CochainReedSolomon.PlaneEncoding R F}
    {pluckerDisagreement : FrameWitness n r → ℝ}

/-- Number of fixed hard-gate slots before naturality and the final witness. -/
def hardGateEvidenceSlotCount : ℕ := 5

/-- Total slots: five hard gates, one naturality gate, and one final witness. -/
def evidenceSlotCount : ℕ := hardGateEvidenceSlotCount + 2

/-- Fixed-position evidence slot under the public evidence root. -/
abbrev EvidenceSlot :=
  Fin evidenceSlotCount

/--
Fixed-position hard-gate evidence slot.

Runtime storage can use this as an array index. The order is:
0. accumulated stage certificate;
1. source metric/disagreement gate;
2. Plucker metric/chart gate;
3. public-shadow respect gate;
4. semantic-alignment gate.
-/
abbrev HardGateSlot :=
  Fin hardGateEvidenceSlotCount

namespace EvidenceSlot

/-- Slot 0: accumulated stage certificate. -/
def stageCertificate : EvidenceSlot :=
  ⟨0, by native_decide⟩

/-- Slot 1: source metric/disagreement gate. -/
def sourceMetric : EvidenceSlot :=
  ⟨1, by native_decide⟩

/-- Slot 2: Plucker metric/chart gate. -/
def pluckerMetric : EvidenceSlot :=
  ⟨2, by native_decide⟩

/-- Slot 3: public-shadow respect gate. -/
def publicShadowRespect : EvidenceSlot :=
  ⟨3, by native_decide⟩

/-- Slot 4: semantic-alignment gate. -/
def semanticAlignment : EvidenceSlot :=
  ⟨4, by native_decide⟩

/-- Slot 5: final structural naturality gate for the assembled projection. -/
def projectionNaturality : EvidenceSlot :=
  ⟨5, by native_decide⟩

/-- Slot 6: calibrated final far-region witness. -/
def finalFarRegion : EvidenceSlot :=
  ⟨6, by native_decide⟩

end EvidenceSlot

namespace HardGateSlot

/-- Embed a hard-gate slot into the full evidence slot schema. -/
def toEvidenceSlot (slot : HardGateSlot) : EvidenceSlot :=
  ⟨slot.val, Nat.lt_trans slot.isLt (by native_decide)⟩

/-- Slot 0: accumulated stage certificate. -/
def stageCertificate : HardGateSlot :=
  ⟨0, by native_decide⟩

/-- Slot 1: source metric/disagreement gate. -/
def sourceMetric : HardGateSlot :=
  ⟨1, by native_decide⟩

/-- Slot 2: Plucker metric/chart gate. -/
def pluckerMetric : HardGateSlot :=
  ⟨2, by native_decide⟩

/-- Slot 3: public-shadow respect gate. -/
def publicShadowRespect : HardGateSlot :=
  ⟨3, by native_decide⟩

/-- Slot 4: semantic-alignment gate. -/
def semanticAlignment : HardGateSlot :=
  ⟨4, by native_decide⟩

end HardGateSlot

/--
Authenticated database/root view for proximity evidence.

The concrete database, Merkle/Verkle root, serialization, inclusion proof, and
hash function are Rust/TCB-owned. Lean records the shape of the public evidence.
-/
structure EvidenceDatabase (runtime : TCB.RuntimeBoundary) where
  slotDigest : EvidenceSlot → TCB.Hash32
  rootDigest : TCB.Hash32
  SlotBinds : EvidenceSlot → Prop
  SlotIncludedInRoot : EvidenceSlot → Prop
  RootBindsSlots : Prop
  canonicalEncoding : runtime.CanonicalEncoding
  domainSeparated : runtime.DomainSeparation
  hashBindingVerified : runtime.HashBindingVerified

namespace EvidenceDatabase

variable {runtime : TCB.RuntimeBoundary}

/-- The hard-gate prefix is complete when every hard slot binds and is included. -/
def HardGateComplete (db : EvidenceDatabase runtime) : Prop :=
  (∀ slot : HardGateSlot,
      db.SlotBinds slot.toEvidenceSlot
        ∧ db.SlotIncludedInRoot slot.toEvidenceSlot)
    ∧ db.RootBindsSlots

/-- The final witness slot is complete when it binds and is root-included. -/
def FinalWitnessComplete (db : EvidenceDatabase runtime) : Prop :=
  db.SlotBinds EvidenceSlot.finalFarRegion
    ∧ db.SlotIncludedInRoot EvidenceSlot.finalFarRegion

/-- The naturality slot is complete when it binds and is root-included. -/
def NaturalityComplete (db : EvidenceDatabase runtime) : Prop :=
  db.SlotBinds EvidenceSlot.projectionNaturality
    ∧ db.SlotIncludedInRoot EvidenceSlot.projectionNaturality

/-- Complete hard-gate evidence exposes slot binding for each hard-gate slot. -/
theorem hard_slot_binds
    {db : EvidenceDatabase runtime}
    (hdb : db.HardGateComplete)
    (slot : HardGateSlot) :
    db.SlotBinds slot.toEvidenceSlot :=
  (hdb.1 slot).1

/-- Complete hard-gate evidence exposes root inclusion for each hard-gate slot. -/
theorem hard_slot_included
    {db : EvidenceDatabase runtime}
    (hdb : db.HardGateComplete)
    (slot : HardGateSlot) :
    db.SlotIncludedInRoot slot.toEvidenceSlot :=
  (hdb.1 slot).2

/-- Complete hard-gate evidence exposes the public evidence root binding fact. -/
theorem root_binds_slots
    {db : EvidenceDatabase runtime}
    (hdb : db.HardGateComplete) :
    db.RootBindsSlots :=
  hdb.2

/-- Complete final evidence exposes binding for the final far-region witness slot. -/
theorem final_witness_binds
    {db : EvidenceDatabase runtime}
    (hdb : db.FinalWitnessComplete) :
    db.SlotBinds EvidenceSlot.finalFarRegion :=
  hdb.1

/-- Complete final evidence exposes root inclusion for the final witness slot. -/
theorem final_witness_included
    {db : EvidenceDatabase runtime}
    (hdb : db.FinalWitnessComplete) :
    db.SlotIncludedInRoot EvidenceSlot.finalFarRegion :=
  hdb.2

/-- Complete naturality evidence exposes binding for its dedicated slot. -/
theorem naturality_binds
    {db : EvidenceDatabase runtime}
    (hdb : db.NaturalityComplete) :
    db.SlotBinds EvidenceSlot.projectionNaturality :=
  hdb.1

/-- Complete naturality evidence exposes root inclusion for its dedicated slot. -/
theorem naturality_included
    {db : EvidenceDatabase runtime}
    (hdb : db.NaturalityComplete) :
    db.SlotIncludedInRoot EvidenceSlot.projectionNaturality :=
  hdb.2

end EvidenceDatabase

/--
Traceable hard-gate certificate.

This combines the mathematical hard-gate certificate with an authenticated
database record for the public evidence. It is intentionally outside the final
metric/far-separation theorem: traceability explains what was checked and
stored, not why the final RS gap theorem holds.
-/
structure HardGateEvidenceRecord
    (runtime : TCB.RuntimeBoundary)
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement) where
  certificate : Gates.Projection.HardGateCertificate Γ
  database : EvidenceDatabase runtime
  databaseComplete : database.HardGateComplete
  proofVerificationSound : runtime.ProofVerificationSound

namespace HardGateEvidenceRecord

variable {runtime : TCB.RuntimeBoundary}
variable {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}

/-- The trace record exposes the underlying mathematical hard-gate certificate. -/
def hardGateCertificate
    (record : HardGateEvidenceRecord runtime Γ) :
    Gates.Projection.HardGateCertificate Γ :=
  record.certificate

/-- The trace record exposes the source-metric gate proof. -/
theorem sourceMetricGate
    (record : HardGateEvidenceRecord runtime Γ) :
    Gates.Projection.SourceMetricGate P pluckerDisagreement :=
  record.certificate.gates.sourceMetric

/-- The trace record exposes slot binding for each hard-gate evidence slot. -/
theorem slot_binds
    (record : HardGateEvidenceRecord runtime Γ)
    (slot : HardGateSlot) :
    record.database.SlotBinds slot.toEvidenceSlot :=
  EvidenceDatabase.hard_slot_binds record.databaseComplete slot

/-- The trace record exposes database inclusion for each hard-gate evidence slot. -/
theorem slot_included
    (record : HardGateEvidenceRecord runtime Γ)
    (slot : HardGateSlot) :
    record.database.SlotIncludedInRoot slot.toEvidenceSlot :=
  EvidenceDatabase.hard_slot_included record.databaseComplete slot

/-- The trace record exposes the public evidence root binding fact. -/
theorem root_binds_slots
    (record : HardGateEvidenceRecord runtime Γ) :
    record.database.RootBindsSlots :=
  EvidenceDatabase.root_binds_slots record.databaseComplete

/-- The trace record exposes the runtime hash-binding fact. -/
theorem hash_binding_verified
    (record : HardGateEvidenceRecord runtime Γ) :
    runtime.HashBindingVerified :=
  record.database.hashBindingVerified

end HardGateEvidenceRecord

/--
Thin evidence wrapper for the once-checked assembled-projection naturality gate.

The hard-gate evidence record is retained unchanged; this layer appends only
the mathematical naturality gate and the binding/inclusion evidence for its
dedicated slot.
-/
structure NaturalityGateEvidenceRecord
    (runtime : TCB.RuntimeBoundary)
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement) where
  hardGateRecord : HardGateEvidenceRecord runtime Γ
  naturalityRecorded : hardGateRecord.database.NaturalityComplete

namespace NaturalityGateEvidenceRecord

variable {runtime : TCB.RuntimeBoundary}
variable {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}

/-- Recover the accumulated mathematical certificate through naturality. -/
def certificate
    (record : NaturalityGateEvidenceRecord runtime Γ) :
    Gates.Projection.NaturalityGateCertificate Γ :=
  Gates.Projection.NaturalityGateCertificate.extend
    record.hardGateRecord.certificate

/-- The naturality evidence slot is bound under the shared evidence root. -/
theorem naturality_binds
    (record : NaturalityGateEvidenceRecord runtime Γ) :
    record.hardGateRecord.database.SlotBinds EvidenceSlot.projectionNaturality :=
  EvidenceDatabase.naturality_binds record.naturalityRecorded

/-- The naturality evidence slot is included under the shared evidence root. -/
theorem naturality_included
    (record : NaturalityGateEvidenceRecord runtime Γ) :
    record.hardGateRecord.database.SlotIncludedInRoot
      EvidenceSlot.projectionNaturality :=
  EvidenceDatabase.naturality_included record.naturalityRecorded

end NaturalityGateEvidenceRecord

/--
Statebus/evidence record for the calibrated final proximity certificate.

The mathematical certificate is still a gate-layer object. The statebus record
adds traceability by requiring the final far-region witness slot to be bound
and included under the same public evidence root as the hard and naturality
gate slots.
-/
structure CalibratedFinalEvidenceRecord
    (runtime : TCB.RuntimeBoundary)
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement)
    (κ : Gates.Projection.RadiusCalibration) where
  naturalityGateRecord : NaturalityGateEvidenceRecord runtime Γ
  finalWitness :
    Gates.Projection.FarRegionSeparation
      Γ κ.sourceFarRadius κ.targetFarRadius
  finalWitnessRecorded :
    naturalityGateRecord.hardGateRecord.database.FinalWitnessComplete

namespace CalibratedFinalEvidenceRecord

variable {runtime : TCB.RuntimeBoundary}
variable {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
variable {κ : Gates.Projection.RadiusCalibration}

/--
A final evidence record is complete when the final witness slot is bound and
included. Hard-gate and naturality completeness are already carried by the
embedded `NaturalityGateEvidenceRecord`.
-/
def Complete (record : CalibratedFinalEvidenceRecord runtime Γ κ) : Prop :=
  record.naturalityGateRecord.hardGateRecord.database.FinalWitnessComplete

/-- Recover the mathematical gate-layer final certificate from statebus evidence. -/
def finalCertificate
    (record : CalibratedFinalEvidenceRecord runtime Γ κ) :
    Gates.Projection.CalibratedFinalCertificate Γ κ :=
  Gates.Projection.CalibratedFinalCertificate.of_farRegionSeparation
    record.naturalityGateRecord.certificate κ record.finalWitness

/-- The final evidence record gives calibrated end-to-end readiness. -/
def calibratedReady
    (record : CalibratedFinalEvidenceRecord runtime Γ κ) :
    Gates.Projection.CalibratedEndToEndReady
      Γ
      κ.sourceNearRadius
      κ.sourceFarRadius
      κ.targetNearRadius
      κ.targetFarRadius :=
  record.finalCertificate.calibratedReady

/-- The final far-region witness slot digest under the shared evidence root. -/
def finalWitnessDigest
    (record : CalibratedFinalEvidenceRecord runtime Γ κ) :
    TCB.Hash32 :=
  record.naturalityGateRecord.hardGateRecord.database.slotDigest
    EvidenceSlot.finalFarRegion

/-- A final evidence record carries its own final-slot completeness proof. -/
theorem complete
    (record : CalibratedFinalEvidenceRecord runtime Γ κ) :
    record.Complete :=
  record.finalWitnessRecorded

/-- Complete final evidence exposes binding for the final witness slot. -/
theorem final_witness_binds
    (record : CalibratedFinalEvidenceRecord runtime Γ κ)
    (hrecord : record.Complete) :
    record.naturalityGateRecord.hardGateRecord.database.SlotBinds
      EvidenceSlot.finalFarRegion :=
  EvidenceDatabase.final_witness_binds hrecord

/-- Complete final evidence exposes root inclusion for the final witness slot. -/
theorem final_witness_included
    (record : CalibratedFinalEvidenceRecord runtime Γ κ)
    (hrecord : record.Complete) :
    record.naturalityGateRecord.hardGateRecord.database.SlotIncludedInRoot
      EvidenceSlot.finalFarRegion :=
  EvidenceDatabase.final_witness_included hrecord

/-- Final statebus evidence inherits runtime hash-binding from hard-gate evidence. -/
theorem hash_binding_verified
    (record : CalibratedFinalEvidenceRecord runtime Γ κ) :
    runtime.HashBindingVerified :=
  record.naturalityGateRecord.hardGateRecord.hash_binding_verified

end CalibratedFinalEvidenceRecord

end Projection

end

end GateEvidence
end Proximity
end Hcrypt
