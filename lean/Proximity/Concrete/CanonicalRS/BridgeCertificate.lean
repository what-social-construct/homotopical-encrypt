module

public import Proximity.Concrete.CanonicalRS.BridgeWitness
public import Proximity.Application.GapBoundary
public import Proximity.Concrete.Gates

@[expose] public section

/-
  Canonical RS bridge certificates.

  Paper correspondence:
  - Paper 1 Section 6: RS/MCA bridge certificate packaging.
  - Paper 1 appendix ledger: projection-chain theorem-surface correspondence.

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

This is the ordered successor to the naturality-checked hard-gate certificate.
It carries one already-aggregated calibrated final certificate; previous
naturality, hard, and stage gates are projected from that certificate instead
of rebuilt.
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

/-- Extend a naturality-checked chain with calibrated RS far separation. -/
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
    (χ : Gates.Projection.NaturalityGateCertificate Γ)
    (κ : Gates.Projection.RadiusCalibration)
    (ω :
      Gates.Projection.FarRegionSeparation
        Γ κ.sourceFarRadius κ.targetFarRadius) :
    RSMetricCertificate β Γ where
  calibration := κ
  finalCertificate :=
    Gates.Projection.CalibratedFinalCertificate.of_farRegionSeparation χ κ ω

/-- Legacy equal-threshold certificate. Its conditional bridge remains valid,
but disjoint closed decision promises need the separated constructor below. -/
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
    (χ : Gates.Projection.NaturalityGateCertificate Γ)
    (ω :
      Gates.Projection.FarRegionSeparation
        Γ β.johnsonRadiusReal β.johnsonRadiusReal) :
    RSMetricCertificate β Γ :=
  of_rsFarSeparation Γ χ β.johnsonRadiusCalibration ω

section Separated

variable
    {β : BridgeData}
    {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
    {P : GrassmannianPlucker.FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}
    {pluckerDisagreement : GrassmannianPlucker.FrameWitness n r → ℝ}
    {Γ : ProjectionChain.Chain
      P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement}

/-- Retain Johnson far separation while choosing a strictly smaller near radius.
This constructs the existing certificate, not a parallel carrier. -/
def of_separatedJohnsonRSFarSeparation
    (χ : Gates.Projection.NaturalityGateCertificate Γ)
    (nearRadius : ℝ) (hgap : nearRadius < β.johnsonRadiusReal)
    (ω : Gates.Projection.FarRegionSeparation
      Γ β.johnsonRadiusReal β.johnsonRadiusReal) :
    RSMetricCertificate β Γ :=
  of_rsFarSeparation Γ χ (β.separatedJohnsonRadiusCalibration nearRadius hgap) ω

/-- The separated constructor keeps exactly the selected canonical calibration. -/
@[simp] theorem of_separatedJohnsonRSFarSeparation_calibration
    (χ : Gates.Projection.NaturalityGateCertificate Γ)
    (nearRadius : ℝ) (hgap : nearRadius < β.johnsonRadiusReal)
    (ω : Gates.Projection.FarRegionSeparation
      Γ β.johnsonRadiusReal β.johnsonRadiusReal) :
    (of_separatedJohnsonRSFarSeparation χ nearRadius hgap ω).calibration =
      β.separatedJohnsonRadiusCalibration nearRadius hgap := rfl

end Separated

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

The accumulated stage certificate already proves the ordered local facts:
accepted committed cocycles at the first gate, aligned plane extraction at the
second gate, and finite-field/RS encoding at the third gate.  Those facts are
not themselves proofs that the projection commutes with restriction and
coboundary maps.  Those two statements and their proofs are supplied by the
final structural `ProjectionNaturalityGate` carried by the thin naturality
certificate immediately after the hard-gate certificate.
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
    Gates.Projection.RestrictionNaturality Γ
  CoboundaryNaturality :=
    Gates.Projection.CoboundaryNaturality Γ
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
  restrictionNaturality :=
    Ω.finalCertificate.previous.naturality.restrictionNaturality
  coboundaryNaturality :=
    Ω.finalCertificate.previous.naturality.coboundaryNaturality
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

This is the clean handoff from the ordered hard-gate -> naturality -> RS-metric
certificates to the generic RS bridge surface.
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
    (χ : Gates.Projection.NaturalityGateCertificate Γ) :
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
    (χ : Gates.Projection.NaturalityGateCertificate Γ) :
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
    (χ : Gates.Projection.NaturalityGateCertificate Γ) :
    ReedSolomonTarget.Target.CalibratedHcryptToRSBridge
      (PluckerCochain.pluckerInstance P pluckerDisagreement)
      β.rsTarget
      β.metric :=
  J.toRSMetricCertificate χ |>.toCalibratedHcryptToRSBridge

section Separated

variable
    {β : BridgeData}
    {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
    {P : GrassmannianPlucker.FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}
    {pluckerDisagreement : GrassmannianPlucker.FrameWitness n r → ℝ}
    {Γ : ProjectionChain.Chain
      P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement}

variable
    (J : JohnsonRSFarSeparation
      (β := β) (P := P) (S := S) (L := L) (E := E)
      (pluckerDisagreement := pluckerDisagreement) (Γ := Γ))
    (χ : Gates.Projection.NaturalityGateCertificate Γ)
    (nearRadius : ℝ) (hgap : nearRadius < β.johnsonRadiusReal)

/-- Package the same far witness with strictly separated decision radii. -/
def toSeparatedRSMetricCertificate : RSMetricCertificate β Γ :=
  RSMetricCertificate.of_separatedJohnsonRSFarSeparation χ nearRadius hgap J.witness

/-- The completed bridge at the selected near radius and unchanged Johnson far radius. -/
def toSeparatedBridge :
    ReedSolomonTarget.Target.CalibratedHcryptToRSBridge
      (PluckerCochain.pluckerInstance P pluckerDisagreement) β.rsTarget β.metric :=
  J.toSeparatedRSMetricCertificate χ nearRadius hgap |>.toCalibratedHcryptToRSBridge

/-- The completed bridge retains all four selected decision radii. -/
@[simp] theorem toSeparatedBridge_radii :
    (J.toSeparatedBridge χ nearRadius hgap).sourceNearRadius = nearRadius ∧
      (J.toSeparatedBridge χ nearRadius hgap).sourceFarRadius = β.johnsonRadiusReal ∧
      (J.toSeparatedBridge χ nearRadius hgap).targetNearRadius = nearRadius ∧
      (J.toSeparatedBridge χ nearRadius hgap).targetFarRadius = β.johnsonRadiusReal :=
  ⟨rfl, rfl, rfl, rfl⟩

/-- Reuse the original projection between strict views of the closed source and
target promises. This does not construct an efficient solver. -/
def toSeparatedGapReduction :
    GapReduction
      (sheafSeparatedGapProblem (PluckerCochain.pluckerInstance P pluckerDisagreement)
        nearRadius β.johnsonRadiusReal hgap).problem
      (codeSeparatedGapProblem β.codeShadow nearRadius β.johnsonRadiusReal hgap).problem :=
  (J.toSeparatedRSMetricCertificate χ nearRadius hgap).calibratedReady
    |>.toCalibratedEndToEndGapProjection.toSeparatedGapReduction hgap hgap

/-- The separated reduction uses the literal original received-word map. -/
@[simp] theorem toSeparatedGapReduction_map
    (W : GrassmannianPlucker.FrameWitness n r) :
    (J.toSeparatedGapReduction χ nearRadius hgap).map W = Γ.receivedWord W := rfl

/-- A correct target solver pulls back on the unchanged closed promises with
a strict gap. Solver efficiency and the geometric far witness stay explicit. -/
theorem pullbackSeparatedSolverCorrect
    (solver :
      (codeSeparatedGapProblem β.codeShadow nearRadius β.johnsonRadiusReal hgap).problem.Solver)
    (hsolver :
      (codeSeparatedGapProblem β.codeShadow nearRadius β.johnsonRadiusReal hgap).problem.SolverCorrect
        solver) :
    (sheafSeparatedGapProblem (PluckerCochain.pluckerInstance P pluckerDisagreement)
      nearRadius β.johnsonRadiusReal hgap).problem.SolverCorrect
      ((J.toSeparatedGapReduction χ nearRadius hgap).pullbackSolver solver) :=
  GapReduction.pullbackSolverCorrect (J.toSeparatedGapReduction χ nearRadius hgap) solver hsolver

end Separated

end JohnsonRSFarSeparation

end BridgeData

end

end CanonicalRS
end Proximity
end Hcrypt
