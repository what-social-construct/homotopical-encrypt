module

/-
Compatibility aliases for the former calibration module.

New code should import `Proximity.Application.Calibration` and use the neutral
`ProximityPrize.Application` namespace. These aliases keep the existing
concrete bridge source-compatible while the project name remains unsettled.
-/

public import Proximity.Application.Calibration

@[expose] public section

namespace Hcrypt
namespace Proximity

universe u v

abbrev CodeDistanceModel :=
  ProximityPrize.Application.CodeDistanceModel

abbrev SourceValidityModel :=
  ProximityPrize.Application.SourceValidityModel

abbrev SourceToSourceCalibration :=
  ProximityPrize.Application.SourceToSourceCalibration

abbrev SourceToCodeCalibration :=
  ProximityPrize.Application.SourceToCodeCalibration

namespace SourceValidityModel

def pullback
    (S : SourceValidityModel.{u})
    {X : Type v}
    (f : X → S.Observation) :
    SourceValidityModel :=
  ProximityPrize.Application.SourceValidityModel.pullback S f

end SourceValidityModel

namespace SourceToCodeCalibration

theorem sourceFar_implies_targetFar
    {S : SourceValidityModel}
    {C : CodeDistanceModel}
    (K : SourceToCodeCalibration S C)
    (x : S.Observation)
    (δ : ℝ)
    (hFar : δ ≤ S.distanceToValid x) :
    δ ≤ C.distanceToCode (K.extract x) :=
  ProximityPrize.Application.SourceToCodeCalibration.sourceFar_implies_targetFar
    K x δ hFar

def pullback
    {S : SourceValidityModel.{u}}
    {C : CodeDistanceModel}
    (K : SourceToCodeCalibration S C)
    {X : Type v}
    (f : X → S.Observation) :
    SourceToCodeCalibration (S.pullback f) C :=
  ProximityPrize.Application.SourceToCodeCalibration.pullback K f

end SourceToCodeCalibration

namespace SourceToSourceCalibration

def transCode
    {U : SourceValidityModel.{u}}
    {V : SourceValidityModel.{v}}
    {C : CodeDistanceModel}
    (J : SourceToSourceCalibration U V)
    (K : SourceToCodeCalibration V C) :
    SourceToCodeCalibration U C :=
  ProximityPrize.Application.SourceToSourceCalibration.transCode J K

def ofPullback
    (V : SourceValidityModel.{u})
    {X : Type v}
    (f : X → V.Observation) :
    SourceToSourceCalibration (V.pullback f) V :=
  ProximityPrize.Application.SourceToSourceCalibration.ofPullback V f

end SourceToSourceCalibration

end Proximity
end Hcrypt
