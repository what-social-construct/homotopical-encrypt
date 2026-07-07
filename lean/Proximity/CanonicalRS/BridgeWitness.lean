import Proximity.CanonicalRS.BridgeData
import Proximity.Gates.Final

/-
  Canonical RS bridge witnesses.

  Paper correspondence:
  - Paper 1 Section 6: far-separation/non-collapse witness for the RS endpoint.

  This module names the mathematical far-separation witness for the canonical
  RS endpoint. It deliberately stops before packaging that witness as a full
  bridge certificate.
-/

namespace Hcrypt
namespace Proximity
namespace CanonicalRS

noncomputable section

namespace BridgeData

/--
Canonical same-radius calibration for the first RS regime.

This uses the canonical relative-Hamming Johnson radius as the numeric
threshold on the RS side and calibrates the source-disagreement threshold to
the same value. The source and target metrics remain different; the substantive
theorem is the `FarNonCollapseWitness` relating those thresholds.
-/
def johnsonRadiusCalibration (β : BridgeData) :
    Gates.Projection.RadiusCalibration :=
  Gates.Projection.RadiusCalibration.sameRadius
    β.johnsonRadiusReal
    β.johnsonRadiusReal
    le_rfl

/--
Johnson-radius RS far separation for a canonical projection chain.

This is the exact remaining theorem for the first concrete RS regime. It says
that source instances far at the canonical Johnson radius remain far after the
composed Plucker/cochain/plane/RS projection.
-/
structure JohnsonRSFarSeparation
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
    : Prop where
  witness :
    Gates.Projection.FarRegionSeparation
      Γ β.johnsonRadiusReal β.johnsonRadiusReal

namespace JohnsonRSFarSeparation

/-- Direct constructor from the threshold far-separation theorem. -/
def of_farSeparation
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
    (h :
      ∀ W : GrassmannianPlucker.FrameWitness n r,
        β.johnsonRadiusReal ≤ pluckerDisagreement W →
          β.johnsonRadiusReal ≤ β.metric.distanceToRS (Γ.receivedWord W)) :
    JohnsonRSFarSeparation
      (β := β) (P := P) (S := S) (L := L) (E := E)
      (pluckerDisagreement := pluckerDisagreement) (Γ := Γ) where
  witness :=
    Gates.Projection.FarNonCollapseWitness.of_noncollapse h

/--
Build Johnson RS far separation from a pointwise projected-distance lower bound.

This is the stronger proof target:
`pluckerDisagreement W <= distanceToRS (receivedWord W)`.
-/
def of_distanceLowerBound
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
    (hLower :
      ∀ W : GrassmannianPlucker.FrameWitness n r,
        pluckerDisagreement W ≤ β.metric.distanceToRS (Γ.receivedWord W)) :
    JohnsonRSFarSeparation
      (β := β) (P := P) (S := S) (L := L) (E := E)
      (pluckerDisagreement := pluckerDisagreement) (Γ := Γ) where
  witness :=
    Gates.Projection.FarNonCollapseWitness.of_distanceLowerBound
      (sourceFarRadius := β.johnsonRadiusReal)
      (targetFarRadius := β.johnsonRadiusReal)
      le_rfl
      hLower

/--
Build Johnson RS far separation from exact preservation of the final distance.

This is the cleanest algebraic target if the production projection is calibrated
so the RS distance is exactly the source disagreement.
-/
def of_distanceEquality
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
    (hEq :
      ∀ W : GrassmannianPlucker.FrameWitness n r,
        β.metric.distanceToRS (Γ.receivedWord W) = pluckerDisagreement W) :
    JohnsonRSFarSeparation
      (β := β) (P := P) (S := S) (L := L) (E := E)
      (pluckerDisagreement := pluckerDisagreement) (Γ := Γ) where
  witness :=
    Gates.Projection.FarNonCollapseWitness.of_distanceEquality
      (sourceFarRadius := β.johnsonRadiusReal)
      (targetFarRadius := β.johnsonRadiusReal)
      le_rfl
      hEq

end JohnsonRSFarSeparation

end BridgeData

end

end CanonicalRS
end Proximity
end Hcrypt
