import Mathlib.Data.Real.Basic

/-!
# Source-to-code distance calibration

This module states the application bridge independently of any particular
source carrier or code family.  A source validity model contains arbitrary
observations, an exact-validity locus, and a distance to that locus.  A
calibration maps those observations to a code shadow and proves the pointwise
lower bound

`source distance ≤ projected distance`.

The threshold implication used by the proximity paper is then immediate at
every radius.  Keeping the pointwise inequality explicit prevents an exact
witness type, whose elements are valid by construction, from being mistaken
for the carrier of noisy source observations.
-/

namespace ProximityPrize
namespace Application

universe u v

/--
An abstract code locus equipped with its declared distance-to-code function.

The prize-facing calibration theorem needs no concrete encoding, commitment,
or runtime structure beyond this interface.
-/
structure CodeDistanceModel where
  Word : Type
  Codeword : Word → Prop
  distanceToCode : Word → ℝ

/--
A source observation space with an exact-validity locus and a declared
distance to that locus.

The laws record the minimum semantics needed from the phrase "distance to
valid": distances are nonnegative and exact-valid observations have distance
zero.  The converse may fail for a pseudometric or quotient presentation and
is therefore not required.
-/
structure SourceValidityModel where
  Observation : Type u
  Valid : Observation → Prop
  distanceToValid : Observation → ℝ
  distance_nonneg : ∀ x : Observation, 0 ≤ distanceToValid x
  valid_zero_distance :
    ∀ x : Observation, Valid x → distanceToValid x = 0

namespace SourceValidityModel

/--
Pull a validity locus and its distance back along an observation map.

This is the canonical model for an upstream carrier whose verifier-facing
metric is defined entirely by its extracted downstream observation.
-/
def pullback
    (S : SourceValidityModel.{u})
    {X : Type v}
    (f : X → S.Observation) :
    SourceValidityModel where
  Observation := X
  Valid x := S.Valid (f x)
  distanceToValid x := S.distanceToValid (f x)
  distance_nonneg x := S.distance_nonneg (f x)
  valid_zero_distance x hx := S.valid_zero_distance (f x) hx

end SourceValidityModel

/--
A quantitative map between two source validity models.

This is the precise proof object required when an application has its own
upstream metric: its source distance must be no larger than the distance of the
extracted downstream observation.
-/
structure SourceToSourceCalibration
    (U : SourceValidityModel.{u})
    (V : SourceValidityModel.{v}) where
  extract : U.Observation → V.Observation
  mapsValid :
    ∀ x : U.Observation, U.Valid x → V.Valid (extract x)
  noncollapse :
    ∀ x : U.Observation,
      U.distanceToValid x ≤ V.distanceToValid (extract x)

/--
An extraction map whose target distance pointwise lower-bounds source distance.

`mapsValid` is the exact-locus compatibility statement.  `noncollapse` is the
quantitative content needed for the far direction; it is deliberately separate
from the usual near/distance-controlled projection inequality.
-/
structure SourceToCodeCalibration
    (S : SourceValidityModel.{u})
    (C : CodeDistanceModel) where
  extract : S.Observation → C.Word
  mapsValid :
    ∀ x : S.Observation, S.Valid x → C.Codeword (extract x)
  noncollapse :
    ∀ x : S.Observation,
      S.distanceToValid x ≤ C.distanceToCode (extract x)

namespace SourceToCodeCalibration

/--
The quantitative source-to-code calibration implication, uniformly in the
radius:

`d_source(x, valid) ≥ δ → distance(extract x, code) ≥ δ`.
-/
theorem sourceFar_implies_targetFar
    {S : SourceValidityModel.{u}}
    {C : CodeDistanceModel}
    (K : SourceToCodeCalibration S C)
    (x : S.Observation)
    (δ : ℝ)
    (hFar : δ ≤ S.distanceToValid x) :
    δ ≤ C.distanceToCode (K.extract x) :=
  hFar.trans (K.noncollapse x)

/-- Exact-valid source observations extract to target codewords. -/
theorem extracted_codeword_of_valid
    {S : SourceValidityModel.{u}}
    {C : CodeDistanceModel}
    (K : SourceToCodeCalibration S C)
    {x : S.Observation}
    (hx : S.Valid x) :
    C.Codeword (K.extract x) :=
  K.mapsValid x hx

/--
Pull a source-to-code calibration back along an arbitrary observation map.

The upstream validity locus and distance are the literal pullbacks of the
downstream ones, so no additional metric theorem is required.
-/
def pullback
    {S : SourceValidityModel.{u}}
    {C : CodeDistanceModel}
    (K : SourceToCodeCalibration S C)
    {X : Type v}
    (f : X → S.Observation) :
    SourceToCodeCalibration (S.pullback f) C where
  extract x := K.extract (f x)
  mapsValid x hx := K.mapsValid (f x) hx
  noncollapse x := K.noncollapse (f x)

end SourceToCodeCalibration

namespace SourceToSourceCalibration

/--
Compose an upstream-to-downstream source calibration with a downstream
source-to-code calibration.
-/
def transCode
    {U : SourceValidityModel.{u}}
    {V : SourceValidityModel.{v}}
    {C : CodeDistanceModel}
    (J : SourceToSourceCalibration U V)
    (K : SourceToCodeCalibration V C) :
    SourceToCodeCalibration U C where
  extract x := K.extract (J.extract x)
  mapsValid x hx := K.mapsValid (J.extract x) (J.mapsValid x hx)
  noncollapse x := (J.noncollapse x).trans (K.noncollapse (J.extract x))

/-- Pullback along a map gives an exact upstream-to-downstream calibration. -/
def ofPullback
    (V : SourceValidityModel.{u})
    {X : Type v}
    (f : X → V.Observation) :
    SourceToSourceCalibration (V.pullback f) V where
  extract := f
  mapsValid _x hx := hx
  noncollapse _x := le_rfl

end SourceToSourceCalibration

end Application
end ProximityPrize
