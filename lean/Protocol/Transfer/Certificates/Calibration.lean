module

public import Protocol.Transfer.Certificates.Codec
public import Proximity.Concrete.Gates.Final

@[expose] public section

/-!
# Rational certificate descriptors realize the actual radius calibration

The raw public descriptor remains the four rational coordinates of the
certificate codec. Its Boolean validity check tests exactly the source gap,
target gap and near-compatibility inequalities of the existing real-valued
`RadiusCalibration`. It adds no positivity, unit-interval or far-preservation
premise. Invalid descriptors remain encodable but fail this check.

Realization identifies each exact rational cast with the actual calibration's
corresponding real coordinate. It therefore identifies the whole calibration,
including its proof-irrelevant inequality fields, rather than an opaque name.
Only calibrations with those rational coordinates are covered; no finite
encoding of arbitrary real calibration data is asserted. The mathematical
far-region certificate and its original source premise remain separate.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.Certificates.Codec.Calibration

open HomotopicalEncryption.Proximity.Gates.Projection

/-- Exactly the three inequalities required by the existing calibration. -/
def Valid (calibration : Codec.Calibration) : Prop :=
  calibration.sourceNear ≤ calibration.sourceFar ∧
    calibration.targetNear ≤ calibration.targetFar ∧
    calibration.sourceNear ≤ calibration.targetNear

instance (calibration : Codec.Calibration) : Decidable (Valid calibration) :=
  inferInstanceAs (Decidable
    (calibration.sourceNear ≤ calibration.sourceFar ∧
      calibration.targetNear ≤ calibration.targetFar ∧
      calibration.sourceNear ≤ calibration.targetNear))

/-- Executable rational comparison; parsing alone does not perform this check. -/
def check (calibration : Codec.Calibration) : Bool := decide (Valid calibration)

theorem check_eq_true_iff (calibration : Codec.Calibration) :
    check calibration = true ↔ Valid calibration := by
  simp [check]

theorem check_eq_false_iff (calibration : Codec.Calibration) :
    check calibration = false ↔ ¬ Valid calibration := by
  simp [check]

/-- Every actual coordinate is identified by its exact rational value. -/
def Realizes (calibration : Codec.Calibration) (actual : RadiusCalibration) : Prop :=
  (calibration.sourceNear : ℝ) = actual.sourceNearRadius ∧
    (calibration.sourceFar : ℝ) = actual.sourceFarRadius ∧
    (calibration.targetNear : ℝ) = actual.targetNearRadius ∧
    (calibration.targetFar : ℝ) = actual.targetFarRadius

/-- Build the existing mathematical calibration from checked finite data. -/
noncomputable def toRadiusCalibration (calibration : Codec.Calibration)
    (valid : Valid calibration) : RadiusCalibration where
  sourceNearRadius := (calibration.sourceNear : ℝ)
  sourceFarRadius := (calibration.sourceFar : ℝ)
  targetNearRadius := (calibration.targetNear : ℝ)
  targetFarRadius := (calibration.targetFar : ℝ)
  sourceGap := by exact_mod_cast valid.1
  targetGap := by exact_mod_cast valid.2.1
  nearCompatible := by exact_mod_cast valid.2.2

theorem realizes_toRadiusCalibration (calibration : Codec.Calibration)
    (valid : Valid calibration) : Realizes calibration (toRadiusCalibration calibration valid) :=
  ⟨rfl, rfl, rfl, rfl⟩

/-- Matching the actual real coordinates reflects its three gap inequalities. -/
theorem valid_of_realizes (calibration : Codec.Calibration) (actual : RadiusCalibration)
    (realizes : Realizes calibration actual) : Valid calibration := by
  rcases realizes with ⟨sourceNear, sourceFar, targetNear, targetFar⟩
  refine ⟨?_, ?_, ?_⟩
  · have gap : (calibration.sourceNear : ℝ) ≤ (calibration.sourceFar : ℝ) := by
      rw [sourceNear, sourceFar]
      exact actual.sourceGap
    exact_mod_cast gap
  · have gap : (calibration.targetNear : ℝ) ≤ (calibration.targetFar : ℝ) := by
      rw [targetNear, targetFar]
      exact actual.targetGap
    exact_mod_cast gap
  · have compatible : (calibration.sourceNear : ℝ) ≤ (calibration.targetNear : ℝ) := by
      rw [sourceNear, targetNear]
      exact actual.nearCompatible
    exact_mod_cast compatible

/-- Realization identifies the actual complete calibration, not only its name. -/
theorem toRadiusCalibration_eq_of_realizes (calibration : Codec.Calibration)
    (valid : Valid calibration) (actual : RadiusCalibration)
    (realizes : Realizes calibration actual) :
    toRadiusCalibration calibration valid = actual := by
  cases actual with
  | mk sourceNear sourceFar targetNear targetFar sourceGap targetGap nearCompatible =>
    rcases realizes with ⟨rfl, rfl, rfl, rfl⟩
    rfl

theorem realizes_iff_toRadiusCalibration_eq (calibration : Codec.Calibration)
    (valid : Valid calibration) (actual : RadiusCalibration) :
    Realizes calibration actual ↔ toRadiusCalibration calibration valid = actual := by
  constructor
  · exact toRadiusCalibration_eq_of_realizes calibration valid actual
  · rintro rfl
    exact realizes_toRadiusCalibration calibration valid

/-- One finite descriptor cannot realize two different actual calibrations. -/
theorem realization_unique (calibration : Codec.Calibration)
    (left right : RadiusCalibration)
    (leftRealizes : Realizes calibration left) (rightRealizes : Realizes calibration right) :
    left = right := by
  have valid := valid_of_realizes calibration left leftRealizes
  exact (toRadiusCalibration_eq_of_realizes calibration valid left leftRealizes).symm.trans
    (toRadiusCalibration_eq_of_realizes calibration valid right rightRealizes)

@[ext] theorem ext {left right : Codec.Calibration}
    (sourceNear : left.sourceNear = right.sourceNear)
    (sourceFar : left.sourceFar = right.sourceFar)
    (targetNear : left.targetNear = right.targetNear)
    (targetFar : left.targetFar = right.targetFar) : left = right := by
  cases left
  cases right
  cases sourceNear
  cases sourceFar
  cases targetNear
  cases targetFar
  rfl

/-- Exact rational casts also identify the descriptor for a fixed calibration. -/
theorem eq_of_realizes (left right : Codec.Calibration) (actual : RadiusCalibration)
    (leftRealizes : Realizes left actual) (rightRealizes : Realizes right actual) :
    left = right := by
  apply ext
  · exact_mod_cast leftRealizes.1.trans rightRealizes.1.symm
  · exact_mod_cast leftRealizes.2.1.trans rightRealizes.2.1.symm
  · exact_mod_cast leftRealizes.2.2.1.trans rightRealizes.2.2.1.symm
  · exact_mod_cast leftRealizes.2.2.2.trans rightRealizes.2.2.2.symm

theorem exists_realization_iff_valid (calibration : Codec.Calibration) :
    (∃ actual : RadiusCalibration, Realizes calibration actual) ↔ Valid calibration := by
  constructor
  · rintro ⟨actual, realizes⟩
    exact valid_of_realizes calibration actual realizes
  · intro valid
    exact ⟨toRadiusCalibration calibration valid, realizes_toRadiusCalibration calibration valid⟩

theorem check_eq_true_of_realizes (calibration : Codec.Calibration) (actual : RadiusCalibration)
    (realizes : Realizes calibration actual) : check calibration = true :=
  (check_eq_true_iff calibration).mpr (valid_of_realizes calibration actual realizes)

/-- Reversed source radii reject even though their raw descriptor is parsable. -/
theorem check_eq_false_of_source_reversed (calibration : Codec.Calibration)
    (reversed : calibration.sourceFar < calibration.sourceNear) : check calibration = false := by
  apply (check_eq_false_iff calibration).mpr
  intro valid
  exact (not_le_of_gt reversed) valid.1

theorem check_eq_false_of_target_reversed (calibration : Codec.Calibration)
    (reversed : calibration.targetFar < calibration.targetNear) : check calibration = false := by
  apply (check_eq_false_iff calibration).mpr
  intro valid
  exact (not_le_of_gt reversed) valid.2.1

theorem check_eq_false_of_near_incompatible (calibration : Codec.Calibration)
    (incompatible : calibration.targetNear < calibration.sourceNear) : check calibration = false := by
  apply (check_eq_false_iff calibration).mpr
  intro valid
  exact (not_le_of_gt incompatible) valid.2.2

end HomotopicalEncryption.Protocol.Transfer.Certificates.Codec.Calibration
