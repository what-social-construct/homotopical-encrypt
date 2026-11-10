module

public import Protocol.Storage.CanonicalSystematic
public import Protocol.Storage.ThreeLevelMetrics
public import Proximity.Application.DistanceCalibration
public import Proximity.Application.Projection

@[expose] public section

/-!
# Existing calibration interfaces instantiated by the original canonical cochain

The source observations are raw snapshot-bound storage contexts, with modular
validity defined by the actual integral cellular coboundary. Their native
scalar-coordinate metric, integer-plane whole-pair metric and finite-field RS
metric are defined separately. The proved comparisons instantiate the existing
source-calibration composition; no distance inequality is an input.

The existing near-direction `EvaluationProjection` uses the explicit budget
`2 * d_cochain`, while the far-direction source calibration uses `d_cochain`.
This keeps their comparison directions and the normalization loss visible.
Modular validity is not storage `Accepted`, real exactness or a global section
in degree zero. Authentication and a producer from private frames remain
separate, and no new context/authentication fixture is constructed here.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Storage.CanonicalCalibration

open ProximityCoding
open HomotopicalEncryption.Sheaf.SystematicCode

section Generic

variable {q : ℕ} [Fact q.Prime] {ι : Type} [Fintype ι] [DecidableEq ι]

/-- Original raw contexts, with native scalar-coordinate distance to actual
modular cellular coboundaries. -/
def sourceModelFor (P : ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (L : CoordinateLayout (Sheaf.SystematicCode.sheaf P S) ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound) :
    Application.SourceValidityModel where
  Observation := Context (Sheaf.SystematicCode.sheaf P S)
  Valid C := ModularExact P S (L.raw C.cochain)
  distanceToValid C := (ThreeLevel.integerScalarCode P S).flattenedPairCode.relativeDistanceToCode
    (BlockCode.flattenPair (L.raw C.cochain))
  distance_nonneg C :=
    (ThreeLevel.integerScalarCode P S).flattenedPairCode.relativeDistanceToCode_nonneg _
  valid_zero_distance C hC := by
    apply BlockCode.relativeDistanceToCode_eq_zero_of_codeword
    apply (BlockCode.flattenedPairCode_codeword_iff (ThreeLevel.integerScalarCode P S) _).mpr
    exact (ThreeLevel.integerPairCode_codeword_iff_modularExact P S hDegree hS _).mpr hC

/-- The integer plane has its own whole-pair edit metric and intrinsic
modular-coboundary validity predicate. -/
def planeModelFor (P : ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound) :
    Application.SourceValidityModel where
  Observation := Word ι (Fin 2 → ℤ)
  Valid z := ModularExact P S z
  distanceToValid := ((ThreeLevel.integerScalarCode P S).interleaved (Fin 2)).relativeDistanceToCode
  distance_nonneg := ((ThreeLevel.integerScalarCode P S).interleaved (Fin 2)).relativeDistanceToCode_nonneg
  valid_zero_distance z hz :=
    ((ThreeLevel.integerScalarCode P S).interleaved (Fin 2)).relativeDistanceToCode_eq_zero_of_codeword
      ((ThreeLevel.integerPairCode_codeword_iff_modularExact P S hDegree hS z).mpr hz)

/-- Exactly the existing two-column RS code and its attained native distance. -/
def rsModelFor (P : ReedSolomon.Parameters (ZMod q) ι) : Application.CodeDistanceModel :=
  (P.vectorBlockCode (Fin 2)).toCodeDistanceModel

def cochainToPlaneFor (P : ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (L : CoordinateLayout (Sheaf.SystematicCode.sheaf P S) ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (hn : 0 < Fintype.card ι) :
    Application.SourceToSourceCalibration
      (sourceModelFor P S L hDegree hS) (planeModelFor P S hDegree hS) where
  extract C := L.raw C.cochain
  mapsValid _ hC := hC
  noncollapse C :=
    (ThreeLevel.three_native_distance_comparison P S hDegree hS hn (L.raw C.cochain)).1

def planeToRSFor (P : ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound) :
    Application.SourceToCodeCalibration (planeModelFor P S hDegree hS) (rsModelFor P) where
  extract := ThreeLevel.reducePair
  mapsValid z hz := (modularExact_iff_vectorCodeword P S hDegree hS z).mp hz
  noncollapse z := (ThreeLevel.planeDistance_eq_rsDistance P S hDegree hS z).le

/-- Compose the already existing calibration objects, rather than introduce a
new application comparison hypothesis. -/
def calibrationFor (P : ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (L : CoordinateLayout (Sheaf.SystematicCode.sheaf P S) ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (hn : 0 < Fintype.card ι) :
    Application.SourceToCodeCalibration (sourceModelFor P S L hDegree hS) (rsModelFor P) :=
  (cochainToPlaneFor P S L hDegree hS hn).transCode (planeToRSFor P S hDegree hS)

/-- The legacy proximity interface's `GlobalSection` field is instantiated by
modular received-cochain validity, not `CellularSheaf.IsGlobalSection`. -/
def scaledSheafInstanceFor (P : ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (L : CoordinateLayout (Sheaf.SystematicCode.sheaf P S) ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound) :
    HomotopicalEncryption.Proximity.SheafProximityInstance where
  Cochain := Context (Sheaf.SystematicCode.sheaf P S)
  GlobalSection := (sourceModelFor P S L hDegree hS).Valid
  disagreement C := 2 * (sourceModelFor P S L hDegree hS).distanceToValid C

def planeShadowFor (P : ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound) :
    HomotopicalEncryption.Proximity.CodeShadow where
  Word := Word ι (Fin 2 → ℤ)
  Codeword := (planeModelFor P S hDegree hS).Valid
  distanceToCode := (planeModelFor P S hDegree hS).distanceToValid

/-- The near direction consumes the proved factor-two budget explicitly. -/
def evaluationProjectionFor (P : ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (L : CoordinateLayout (Sheaf.SystematicCode.sheaf P S) ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (hn : 0 < Fintype.card ι) :
    HomotopicalEncryption.Proximity.EvaluationProjection
      (scaledSheafInstanceFor P S L hDegree hS) (planeShadowFor P S hDegree hS) where
  map C := L.raw C.cochain
  preservesGlobalSections _ hC := hC
  distanceControlled C :=
    (BlockCode.flattenedPairCode_distance_comparison (ThreeLevel.integerScalarCode P S)
      (ThreeLevel.integerScalarCode_nonempty P S hDegree hS) hn (L.raw C.cochain)).2

end Generic

abbrev SourceObservation := Context CanonicalSystematic.sheaf

def sourceModel := sourceModelFor
  CanonicalSystematic.parameters CanonicalSystematic.informationSet CanonicalSystematic.layout
  CanonicalSystematic.degreeBound_pos CanonicalSystematic.informationSet_card

def planeModel := planeModelFor
  CanonicalSystematic.parameters CanonicalSystematic.informationSet
  CanonicalSystematic.degreeBound_pos CanonicalSystematic.informationSet_card

def rsModel := rsModelFor CanonicalSystematic.parameters

def cochainToPlane := cochainToPlaneFor
  CanonicalSystematic.parameters CanonicalSystematic.informationSet CanonicalSystematic.layout
  CanonicalSystematic.degreeBound_pos CanonicalSystematic.informationSet_card CanonicalSystematic.length_pos

def planeToRS := planeToRSFor
  CanonicalSystematic.parameters CanonicalSystematic.informationSet
  CanonicalSystematic.degreeBound_pos CanonicalSystematic.informationSet_card

def calibration := cochainToPlane.transCode planeToRS

def scaledSheafInstance := scaledSheafInstanceFor
  CanonicalSystematic.parameters CanonicalSystematic.informationSet CanonicalSystematic.layout
  CanonicalSystematic.degreeBound_pos CanonicalSystematic.informationSet_card

def planeShadow := planeShadowFor
  CanonicalSystematic.parameters CanonicalSystematic.informationSet
  CanonicalSystematic.degreeBound_pos CanonicalSystematic.informationSet_card

def evaluationProjection := evaluationProjectionFor
  CanonicalSystematic.parameters CanonicalSystematic.informationSet CanonicalSystematic.layout
  CanonicalSystematic.degreeBound_pos CanonicalSystematic.informationSet_card CanonicalSystematic.length_pos

/-- The composed calibration still reads the original context's actual payload. -/
theorem calibration_extract (C : SourceObservation) :
    calibration.extract C =
      ThreeLevel.reducePair (CanonicalSystematic.layout.raw C.cochain) := rfl

/-- The output is exactly the pre-existing finite-field extraction API. -/
theorem calibration_extract_eq_original_pair (C : SourceObservation) :
    calibration.extract C = HomotopicalEncryption.Protocol.Storage.Calibration.extractedPair
      (K := HomotopicalEncryption.Proximity.CanonicalRS.RSField) CanonicalSystematic.layout.extraction C := rfl

theorem extracted_codeword_of_modular_valid (C : SourceObservation)
    (hvalid : sourceModel.Valid C) : rsModel.Codeword (calibration.extract C) :=
  calibration.extracted_codeword_of_valid hvalid

/-- Existing all-radius far transfer, instantiated on the actual three levels. -/
theorem sourceFar_implies_rsFar (C : SourceObservation) (radius : ℝ)
    (hfar : radius ≤ sourceModel.distanceToValid C) :
    radius ≤ rsModel.distanceToCode (calibration.extract C) :=
  calibration.sourceFar_implies_targetFar C radius hfar

theorem sourceFar_implies_planeFar (C : SourceObservation) (radius : ℝ)
    (hfar : radius ≤ sourceModel.distanceToValid C) :
    radius ≤ planeModel.distanceToValid (cochainToPlane.extract C) :=
  hfar.trans (cochainToPlane.noncollapse C)

/-- The existing near-direction API consumes `2*d_cochain ≤ epsilon`. -/
theorem planeNear_of_scaledSourceNear (C : SourceObservation) (epsilon : ℝ)
    (hnear : scaledSheafInstance.disagreement C ≤ epsilon) :
    planeShadow.distanceToCode (evaluationProjection.map C) ≤ epsilon :=
  HomotopicalEncryption.Proximity.projected_near_code_of_disagreement_le evaluationProjection hnear

end HomotopicalEncryption.Protocol.Storage.CanonicalCalibration
