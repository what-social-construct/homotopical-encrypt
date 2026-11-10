module

public import Protocol.Storage.Calibration
public import Proximity.Concrete.CanonicalRS.PublicCalibration

@[expose] public section

/-!
# The canonical public pair, indexed by its original storage context

This optional application adapter keeps the existing public calibration
observation and joins its entire public cochain artifact to the fixed sheaf
context. The artifact leaf digest, snapshot root and surrounding storage root
retain their separate meanings. `BridgeData` and its bounds remain explicit
inputs; this module does not instantiate the cited-bound axioms.

The legacy real-infimum pair distance is identified with the attained generic
Hamming minimum. This lets controlled exact lifts transport the independent
decoded cochain distance to the very pair extracted from the public artifact.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Storage.CanonicalRS

open Sheaf CellularSheaf
open HomotopicalEncryption.Proximity
open HomotopicalEncryption.Proximity.CanonicalRS

private theorem legacyRelativeDistanceToCode_eq_generic
    {α : Type} [DecidableEq α]
    (code : ProximityPrize.BlockCode (Fin length) α)
    (hcode : ∃ word, code.Codeword word)
    (word : ProximityPrize.Word (Fin length) α) :
    BridgeData.PlanePair.relativeDistanceToCode code word =
      code.relativeDistanceToCode word := by
  obtain ⟨nearest, hnearest, hmin⟩ := code.exists_nearest_codeword_relative hcode word
  apply le_antisymm
  · calc
      BridgeData.PlanePair.relativeDistanceToCode code word ≤
          HomotopicalEncryption.Proximity.BlockCode.relativeHammingDistance nearest word :=
        BridgeData.PlanePair.relativeDistanceToCode_le_of_codeword code hnearest
      _ = code.relativeDistanceToCode word := by
        simpa only [HomotopicalEncryption.Proximity.BlockCode.relativeHammingDistance] using hmin.symm
  · unfold BridgeData.PlanePair.relativeDistanceToCode
    apply le_csInf
    · exact ⟨HomotopicalEncryption.Proximity.BlockCode.relativeHammingDistance nearest word,
        nearest, hnearest, rfl⟩
    · intro distance hdistance
      rcases hdistance with ⟨other, hother, rfl⟩
      exact code.relativeDistanceToCode_le_of_codeword hother

/-- The canonical pair code is nonempty, independently of its bound inputs. -/
theorem pairCode_nonempty (β : BridgeData) :
    ∃ word, (BridgeData.PlanePair.pairCode β).Codeword word := by
  refine ⟨fun _ _ => 0, ?_⟩
  change ∀ j : Fin 2, β.rsTarget.parameters.Codeword (fun _ => 0)
  intro _
  exact β.rsTarget.fAdditive.zero_mem

/-- The old real-infimum metric and new attained minimum name the same distance. -/
theorem pairDistance_eq_generic
    (β : BridgeData) (word : BridgeData.PlanePair.PairWord) :
    BridgeData.PlanePair.pairDistance β word =
      (BridgeData.PlanePair.pairCode β).relativeDistanceToCode word :=
  legacyRelativeDistanceToCode_eq_generic
    (BridgeData.PlanePair.pairCode β) (pairCode_nonempty β) word

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {Fsheaf : CellularSheaf X}

/-- The original public observation, joined by its exact public artifact. -/
structure Observation
    (C : Context Fsheaf) (runtime : TCB.RuntimeBoundary)
    (E : CochainPlane.PlaneExtractionContext ℤ (Fin length)) where
  publicObservation : PublicCalibration.Observation runtime E
  artifactMatches : publicObservation.view.observation.artifact.publicArtifact = C.artifact

namespace Observation

variable {C : Context Fsheaf} {runtime : TCB.RuntimeBoundary}
  {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}

theorem cochain_matches (O : Observation C runtime E) :
    O.publicObservation.view.observation.cochain = C.cochain :=
  congrArg TCB.HashedCommittedCochain.cochain O.artifactMatches

/-- The public leaf digest is the context's cochain leaf, not a storage/snapshot root. -/
theorem leafDigest_matches (O : Observation C runtime E) :
    O.publicObservation.view.cochainArtifactDigest = C.key.cochainDigest :=
  congrArg TCB.HashedCommittedCochain.digest O.artifactMatches

theorem aligned (O : Observation C runtime E) : E.Aligned C.cochain := by
  rw [← O.cochain_matches]
  exact O.publicObservation.view.cochainAligned

/-- Both field coordinates come from this context's actual original payload. -/
theorem extractedPair_matches (O : Observation C runtime E) :
    PublicCalibration.extractedPair O.publicObservation =
      Calibration.extractedPair (K := RSField) E C := by
  calc
    PublicCalibration.extractedPair O.publicObservation =
        reduceIntegerPlane
          (E.projectedPlane O.publicObservation.view.observation.cochain) :=
      PublicCalibration.extractedPair_eq_observedCochainProjection O.publicObservation
    _ = reduceIntegerPlane (E.projectedPlane C.cochain) := by
      rw [O.cochain_matches]
    _ = Calibration.extractedPair (K := RSField) E C := rfl

/-- The established public pullback score is still exactly the canonical pair distance. -/
theorem publicSourceDistance_eq_pairDistance
    (O : Observation C runtime E) (β : BridgeData) :
    PublicCalibration.sourceDistanceToValid β O.publicObservation =
      BridgeData.PlanePair.pairDistance β (Calibration.extractedPair (K := RSField) E C) := by
  calc
    PublicCalibration.sourceDistanceToValid β O.publicObservation =
        BridgeData.PlanePair.admissibleDistance β
          (PublicCalibration.toAdmissibleWord O.publicObservation) := rfl
    _ = BridgeData.PlanePair.pairDistance β
        (BridgeData.PlanePair.encode (PublicCalibration.toAdmissibleWord O.publicObservation)) :=
      (BridgeData.PlanePair.pairDistance_encode_eq_admissibleDistance β _).symm
    _ = BridgeData.PlanePair.pairDistance β
        (Calibration.extractedPair (K := RSField) E C) := by
      rw [PublicCalibration.encode_toAdmissibleWord, O.extractedPair_matches]

/-- Reuse the proved public calibration, now attributed to the same stored cochain. -/
theorem publicSourceFar_implies_pairFar
    (O : Observation C runtime E) (β : BridgeData) (radius : ℝ)
    (hfar : radius ≤ PublicCalibration.sourceDistanceToValid β O.publicObservation) :
    radius ≤ BridgeData.PlanePair.pairDistance β
      (Calibration.extractedPair (K := RSField) E C) := by
  rw [← O.extractedPair_matches]
  exact PublicCalibration.sourceFar_implies_pairFar β O.publicObservation radius hfar

/-- Controlled exact lifts prove a comparison for the independently decoded source. -/
theorem decodedDistance_le_scaled_pairDistance
    (O : Observation C runtime E) (β : BridgeData) {scale : ℝ}
    (control : Calibration.LiftControl C E (BridgeData.PlanePair.pairCode β) scale) :
    C.decodedDistance ≤ scale * BridgeData.PlanePair.pairDistance β
      (PublicCalibration.extractedPair O.publicObservation) := by
  rw [O.extractedPair_matches, pairDistance_eq_generic]
  exact control.decodedDistance_le_scaled_pairDistance (pairCode_nonempty β)

/-- Original decoded-cochain farness transfers to the actual observed canonical pair. -/
theorem decodedFar_implies_pairFar
    (O : Observation C runtime E) (β : BridgeData) {scale : ℝ}
    (control : Calibration.LiftControl C E (BridgeData.PlanePair.pairCode β) scale)
    (hscale : 0 < scale) (sourceRadius : ℝ) (hfar : sourceRadius ≤ C.decodedDistance) :
    sourceRadius / scale ≤ BridgeData.PlanePair.pairDistance β
      (PublicCalibration.extractedPair O.publicObservation) := by
  rw [O.extractedPair_matches, pairDistance_eq_generic]
  exact control.decodedFar_implies_pairFar (pairCode_nonempty β) hscale sourceRadius hfar

end Observation
end HomotopicalEncryption.Protocol.Storage.CanonicalRS
