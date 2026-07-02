import Proximity.CanonicalRS.BridgeWitness
import Proximity.Gates

/-
  Canonical RS bridge certificates.

  `BridgeData` owns the canonical endpoint and metric facts. This module owns
  the heavier projection-chain/gate certificates that consume those facts.
-/

namespace Hcrypt
namespace Proximity
namespace CanonicalRS

noncomputable section

namespace BridgeData

/--
Canonical RS metric certificate.

This is the ordered successor to the hard-gate certificate. It carries one
already-aggregated calibrated final certificate; previous hard/stage gates are
projected from that certificate instead of rebuilt.
-/
structure RSMetricCertificate
    (β : BridgeData)
    {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
    {P : GrassmannianPlucker.FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}
    {pluckerDisagreement : GrassmannianPlucker.FrameWitness n r → ℝ}
    (Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement) where
  calibration : Gates.Projection.RadiusCalibration
  finalCertificate :
    Gates.Projection.CalibratedFinalCertificate Γ calibration

namespace RSMetricCertificate

/-- Extend hard gates with an explicit calibrated RS far-separation proof. -/
def of_rsFarSeparation
    {β : BridgeData}
    {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
    {P : GrassmannianPlucker.FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}
    {pluckerDisagreement : GrassmannianPlucker.FrameWitness n r → ℝ}
    (Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement)
    (χ : Gates.Projection.HardGateCertificate Γ)
    (κ : Gates.Projection.RadiusCalibration)
    (ω :
      Gates.Projection.FarRegionSeparation
        Γ κ.sourceFarRadius κ.targetFarRadius) :
    RSMetricCertificate β Γ where
  calibration := κ
  finalCertificate :=
    Gates.Projection.CalibratedFinalCertificate.of_farRegionSeparation χ κ ω

/-- Extend hard gates with the canonical Johnson-radius RS far-separation proof. -/
def of_johnsonRSFarSeparation
    {β : BridgeData}
    {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
    {P : GrassmannianPlucker.FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}
    {pluckerDisagreement : GrassmannianPlucker.FrameWitness n r → ℝ}
    {Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement}
    (χ : Gates.Projection.HardGateCertificate Γ)
    (ω :
      Gates.Projection.FarRegionSeparation
        Γ β.johnsonRadiusReal β.johnsonRadiusReal) :
    RSMetricCertificate β Γ :=
  of_rsFarSeparation Γ χ β.johnsonRadiusCalibration ω

/-- The RS metric certificate produces the calibrated final metric check. -/
def finalCheck
    {β : BridgeData}
    {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
    {P : GrassmannianPlucker.FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}
    {pluckerDisagreement : GrassmannianPlucker.FrameWitness n r → ℝ}
    {Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement}
    (Ω : RSMetricCertificate β Γ) :
    Gates.Projection.CalibratedFinalCheck
      Γ
      Ω.calibration.sourceNearRadius
      Ω.calibration.sourceFarRadius
      Ω.calibration.targetNearRadius
      Ω.calibration.targetFarRadius :=
  Ω.finalCertificate.finalCheck

/-- View the RS metric certificate as the general gate-layer final certificate. -/
def toGateFinalCertificate
    {β : BridgeData}
    {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
    {P : GrassmannianPlucker.FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}
    {pluckerDisagreement : GrassmannianPlucker.FrameWitness n r → ℝ}
    {Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement}
    (Ω : RSMetricCertificate β Γ) :
    Gates.Projection.CalibratedFinalCertificate Γ Ω.calibration :=
  Ω.finalCertificate

/-- Extend the hard-gate certificate through the quantitative final metric check. -/
def calibratedFinalGateCertificate
    {β : BridgeData}
    {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
    {P : GrassmannianPlucker.FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}
    {pluckerDisagreement : GrassmannianPlucker.FrameWitness n r → ℝ}
    {Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement}
    (Ω : RSMetricCertificate β Γ) :
    Gates.Projection.CalibratedFinalGateCertificate Γ Ω.calibration :=
  Ω.toGateFinalCertificate.toProjectionChainFinalGate

/-- Combine hard gate evidence with the RS metric proof into end-to-end readiness. -/
def calibratedReady
    {β : BridgeData}
    {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
    {P : GrassmannianPlucker.FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}
    {pluckerDisagreement : GrassmannianPlucker.FrameWitness n r → ℝ}
    {Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement}
    (Ω : RSMetricCertificate β Γ) :
    Gates.Projection.CalibratedEndToEndReady
      Γ
      Ω.calibration.sourceNearRadius
      Ω.calibration.sourceFarRadius
      Ω.calibration.targetNearRadius
      Ω.calibration.targetFarRadius :=
  Ω.finalCertificate.calibratedReady

/--
The terminal theorem slots induced by a concrete RS metric certificate.

The naturality slots are supplied by the hard-gate certificate contained in the
final certificate. The certificate itself owns the quantitative radius and RS
far-separation slots.
-/
def theoremSlots
    {β : BridgeData}
    {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
    {P : GrassmannianPlucker.FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}
    {pluckerDisagreement : GrassmannianPlucker.FrameWitness n r → ℝ}
    {Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement}
    (Ω : RSMetricCertificate β Γ) :
    BridgeTheoremSlots where
  RestrictionNaturality :=
    Gates.Projection.ProjectionStageGateCertificate Γ
  CoboundaryNaturality :=
    Gates.Projection.ProjectionStageGateCertificate Γ
  GlobalSectionsMapToRSCodewords :=
    ∀ W : GrassmannianPlucker.FrameWitness n r,
      PluckerCochain.ValidFrame P W →
        β.rsTarget.parameters.Codeword (Γ.receivedWord W)
  ProjectionMatchesReceivedWord :=
    ∀ W : GrassmannianPlucker.FrameWitness n r,
      Γ.toEvaluationProjection.map W = Γ.receivedWord W
  NearDistanceCompatible :=
    Ω.calibration.sourceNearRadius ≤ Ω.calibration.targetNearRadius
  FarNonCollapse :=
    ∀ W : GrassmannianPlucker.FrameWitness n r,
      Ω.calibration.sourceFarRadius ≤ pluckerDisagreement W →
        Ω.calibration.targetFarRadius ≤ β.metric.distanceToRS (Γ.receivedWord W)

/-- Generic RS obligations induced by the canonical RS metric certificate. -/
def obligations
    {β : BridgeData}
    {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
    {P : GrassmannianPlucker.FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}
    {pluckerDisagreement : GrassmannianPlucker.FrameWitness n r → ℝ}
    {Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement}
    (Ω : RSMetricCertificate β Γ) :
    ReedSolomonTarget.Target.BridgeObligations β.rsTarget :=
  Ω.theoremSlots.toObligations β

/-- Build the terminal bridge certificate from the RS metric certificate. -/
def toBridgeCertificate
    {β : BridgeData}
    {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
    {P : GrassmannianPlucker.FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}
    {pluckerDisagreement : GrassmannianPlucker.FrameWitness n r → ℝ}
    {Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement}
    (Ω : RSMetricCertificate β Γ) :
    BridgeCertificate Ω.theoremSlots where
  restrictionNaturality := Ω.finalCertificate.previous.stage
  coboundaryNaturality := Ω.finalCertificate.previous.stage
  globalSectionsMapToRSCodewords := by
    intro W hW
    exact Γ.toEvaluationProjection.preservesGlobalSections W hW
  projectionMatchesReceivedWord := by
    intro W
    rfl
  nearDistanceCompatible := Ω.calibration.nearCompatible
  farNonCollapse := Ω.finalCertificate.finalWitness.noncollapse

/-- Complete the generic RS bridge obligations from the ordered RS metric certificate. -/
def complete
    {β : BridgeData}
    {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
    {P : GrassmannianPlucker.FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}
    {pluckerDisagreement : GrassmannianPlucker.FrameWitness n r → ℝ}
    {Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement}
    (Ω : RSMetricCertificate β Γ) :
    Ω.obligations.Complete :=
  Ω.toBridgeCertificate.complete β

/--
Package a calibrated ready canonical chain as the completed calibrated RS bridge.

This is the clean handoff from the ordered hard-gate -> RS-metric certificate
to the generic RS bridge surface.
-/
def toCalibratedHcryptToRSBridge
    {β : BridgeData}
    {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
    {P : GrassmannianPlucker.FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}
    {pluckerDisagreement : GrassmannianPlucker.FrameWitness n r → ℝ}
    {Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement}
    (Ω : RSMetricCertificate β Γ) :
    ReedSolomonTarget.Target.CalibratedHcryptToRSBridge
      (PluckerCochain.pluckerInstance P pluckerDisagreement)
      β.rsTarget
      β.metric :=
  Gates.Projection.CalibratedEndToEndReady.toCalibratedHcryptToRSBridge
    Ω.calibratedReady
    Ω.calibration.sourceGap
    Ω.calibration.targetGap
    Ω.obligations
    Ω.complete

end RSMetricCertificate

namespace JohnsonRSFarSeparation

/-- Extend hard gates with a Johnson RS far-separation proof. -/
def toRSMetricCertificate
    {β : BridgeData}
    {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
    {P : GrassmannianPlucker.FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}
    {pluckerDisagreement : GrassmannianPlucker.FrameWitness n r → ℝ}
    {Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement}
    (J : JohnsonRSFarSeparation
      (β := β) (P := P) (S := S) (L := L) (E := E)
      (pluckerDisagreement := pluckerDisagreement) (Γ := Γ))
    (χ : Gates.Projection.HardGateCertificate Γ) :
    RSMetricCertificate β Γ :=
  RSMetricCertificate.of_johnsonRSFarSeparation χ J.witness

/-- The Johnson RS far-separation theorem produces the calibrated final gate certificate. -/
def finalGate
    {β : BridgeData}
    {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
    {P : GrassmannianPlucker.FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}
    {pluckerDisagreement : GrassmannianPlucker.FrameWitness n r → ℝ}
    {Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement}
    (J : JohnsonRSFarSeparation
      (β := β) (P := P) (S := S) (L := L) (E := E)
      (pluckerDisagreement := pluckerDisagreement) (Γ := Γ))
    (χ : Gates.Projection.HardGateCertificate Γ) :
    Gates.Projection.CalibratedFinalGateCertificate
      Γ β.johnsonRadiusCalibration :=
  J.toRSMetricCertificate χ |>.calibratedFinalGateCertificate

/-- The Johnson RS far-separation theorem completes the canonical calibrated RS bridge. -/
def toBridge
    {β : BridgeData}
    {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
    {P : GrassmannianPlucker.FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}
    {pluckerDisagreement : GrassmannianPlucker.FrameWitness n r → ℝ}
    {Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement}
    (J : JohnsonRSFarSeparation
      (β := β) (P := P) (S := S) (L := L) (E := E)
      (pluckerDisagreement := pluckerDisagreement) (Γ := Γ))
    (χ : Gates.Projection.HardGateCertificate Γ) :
    ReedSolomonTarget.Target.CalibratedHcryptToRSBridge
      (PluckerCochain.pluckerInstance P pluckerDisagreement)
      β.rsTarget
      β.metric :=
  J.toRSMetricCertificate χ |>.toCalibratedHcryptToRSBridge

end JohnsonRSFarSeparation

end BridgeData

end

end CanonicalRS
end Proximity
end Hcrypt
