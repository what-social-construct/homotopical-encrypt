module

public import Proximity.Concrete.CanonicalRS.BridgeData
public import Proximity.Concrete.Public

@[expose] public section

/-!
# Public-observation to canonical-pair calibration

This module moves the proved canonical plane/pair calibration to the actual
public observation boundary.  The carrier is a runtime-accepted cochain
artifact together with its derived plane view and a proof that the plane uses
canonical integer representatives.  It is not restricted to codewords, so
invalid and noisy public observations remain in scope.

The verifier-facing source validity locus and metric are pulled back from the
canonical plane model.  Consequently the upstream-to-plane comparison is an
equality, and composition with the plane-to-pair calibration proves the desired
all-radius implication for public observations.
-/

namespace Hcrypt
namespace Proximity
namespace CanonicalRS
namespace PublicCalibration

noncomputable section

variable {runtime : TCB.RuntimeBoundary}
variable {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}

/--
A public plane observation whose selected integer coordinates lie in the
canonical representative region.

Runtime acceptance and storage inclusion live in `view`; `canonical` is the
mathematical alphabet condition needed for faithful reduction to the RS field
pair.
-/
structure Observation
    (runtime : TCB.RuntimeBoundary)
    (E : CochainPlane.PlaneExtractionContext ℤ (Fin length)) where
  view : CochainPlane.PublicBinding.PlaneView runtime E
  canonical :
    ∀ i j,
      IsCanonicalRepresentative (view.planeShadow i j)

/-- Read a public observation as an arbitrary canonical-region plane word. -/
def toAdmissibleWord
    (O : Observation runtime E) :
    BridgeData.PlanePair.AdmissibleWord :=
  BridgeData.PlanePair.bundle
    ⟨O.view.planeShadow, O.canonical⟩

/-- The field-valued paper pair extracted from a public observation. -/
def extractedPair
    (O : Observation runtime E) :
    BridgeData.PlanePair.PairWord :=
  reduceIntegerPlane O.view.planeShadow

/-- Public-observation extraction agrees with canonical plane-word encoding. -/
@[simp]
theorem encode_toAdmissibleWord
    (O : Observation runtime E) :
    BridgeData.PlanePair.encode (toAdmissibleWord O) =
      extractedPair O := by
  exact BridgeData.PlanePair.encode_bundle
    ⟨O.view.planeShadow, O.canonical⟩

/--
The extracted pair is determined by the runtime-observed cochain through the
declared plane projection.
-/
theorem extractedPair_eq_observedCochainProjection
    (O : Observation runtime E) :
    extractedPair O =
      reduceIntegerPlane
        (E.projectedPlane O.view.observation.cochain) := by
  unfold extractedPair
  rw [O.view.planeShadow_eq_projectedCochain]

/-- Exact validity of a public observation means membership in the pulled-back pair code. -/
def Valid
    (β : BridgeData)
    (O : Observation runtime E) : Prop :=
  (BridgeData.PlanePair.admissibleCode β).Codeword
    (toAdmissibleWord O)

/-- Verifier-facing distance from a public observation to the valid locus. -/
def sourceDistanceToValid
    (β : BridgeData)
    (O : Observation runtime E) : ℝ :=
  BridgeData.PlanePair.admissibleDistance β
    (toAdmissibleWord O)

/-- The public-observation source model is the pullback of the canonical plane model. -/
def sourceValidityModel
    (β : BridgeData) :
    ProximityPrize.Application.SourceValidityModel :=
  (BridgeData.PlanePair.sourceValidityModel β).pullback
    (toAdmissibleWord (runtime := runtime) (E := E))

/--
Public observations inherit the proved canonical plane-to-pair calibration by
pullback.
-/
def sourceToPairCalibration
    (β : BridgeData) :
    ProximityPrize.Application.SourceToCodeCalibration
      (sourceValidityModel (runtime := runtime) (E := E) β)
      (BridgeData.PlanePair.pairCodeShadow β) :=
  (BridgeData.PlanePair.sourceToPairCalibration β).pullback
    (toAdmissibleWord (runtime := runtime) (E := E))

/--
The completed public-observation calibration theorem:

`d_source(O, valid) ≥ δ → Δ(extractedPair O, C≡2) ≥ δ`.
-/
theorem sourceFar_implies_pairFar
    (β : BridgeData)
    (O : Observation runtime E)
    (δ : ℝ)
    (hSourceFar : δ ≤ sourceDistanceToValid β O) :
    δ ≤ BridgeData.PlanePair.pairDistance β (extractedPair O) := by
  rw [← encode_toAdmissibleWord O]
  exact BridgeData.PlanePair.admissibleSourceFar_implies_pairFar
    β (toAdmissibleWord O) δ hSourceFar

/-- Exact-valid public observations extract to paper-pair codewords. -/
theorem extractedPair_codeword_of_valid
    (β : BridgeData)
    {O : Observation runtime E}
    (hO : Valid β O) :
    (BridgeData.PlanePair.pairCode β).Codeword
      (extractedPair O) := by
  rw [← encode_toAdmissibleWord O]
  exact hO

end

end PublicCalibration
end CanonicalRS
end Proximity
end Hcrypt
