module

public import Protocol.Storage.CanonicalCalibration
public import Protocol.Storage.CanonicalThreeLevel

@[expose] public section
set_option autoImplicit false

/-!
# Canonical proofs for the original-cochain application
The three local statements unfold the existing interfaces definitionally.
Their proofs use `change` and the original canonical owners.
-/

namespace Hcrypt.Palomar.PaperThree.Application
open Hcrypt.Protocol.Storage
/-- The actual two-step extraction equals the existing original-payload pair API. -/
theorem calibration_extract_eq_original_pair_unfolded (C : Context CanonicalSystematic.sheaf) :
    ThreeLevel.reducePair (CanonicalSystematic.layout.raw C.cochain) =
      Calibration.extractedPair (K := Hcrypt.Proximity.CanonicalRS.RSField)
        CanonicalSystematic.layout.extraction C := by
  change CanonicalCalibration.calibration.extract C = _
  exact CanonicalCalibration.calibration_extract_eq_original_pair C
/-- Original scalar-coordinate farness transfers to the same payload's RS pair with unit scale. -/
theorem sourceFar_implies_rsFar_unfolded (C : Context CanonicalSystematic.sheaf) (radius : ℝ)
    (hfar : radius ≤ CanonicalThreeLevel.cochainDistance C.cochain) :
    radius ≤ CanonicalThreeLevel.rsPairDistance C.cochain := by
  change radius ≤ CanonicalCalibration.rsModel.distanceToCode
    (CanonicalCalibration.calibration.extract C)
  exact CanonicalCalibration.sourceFar_implies_rsFar C radius hfar
/-- The near direction uses exactly the original factor-two source budget. -/
theorem planeNear_of_scaledSourceNear_unfolded (C : Context CanonicalSystematic.sheaf) (epsilon : ℝ)
    (hnear : 2 * CanonicalThreeLevel.cochainDistance C.cochain ≤ epsilon) :
    CanonicalThreeLevel.planeDistance C.cochain ≤ epsilon := by
  change CanonicalCalibration.planeShadow.distanceToCode
    (CanonicalCalibration.evaluationProjection.map C) ≤ epsilon
  exact CanonicalCalibration.planeNear_of_scaledSourceNear C epsilon hnear
end Hcrypt.Palomar.PaperThree.Application
