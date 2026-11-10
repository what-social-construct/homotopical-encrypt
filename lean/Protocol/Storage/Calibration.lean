module

public import Protocol.Storage.Context
public import Proximity.Core.Distance
public import Proximity.Concrete.CochainPlane.Core

@[expose] public section

/-!
# A geometric source comparison from controlled exact lifts

This module keeps the decoded Euclidean source residual independent of the
RS Hamming metric. A concrete codec can establish the comparison by lifting
each target codeword to an actual exact cochain and bounding its decoding
error. The resulting far-radius transfer is proved here; the codec/lifts are
not supplied by storage roots or by a definition of pullback distance.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Storage.Calibration

open Sheaf CellularSheaf
open HomotopicalEncryption.Proximity

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {Fsheaf : CellularSheaf X}
  {K ι : Type} [Field K] [Fintype ι] [DecidableEq K]

/-- Read and reduce both coordinates of the original stored cochain. -/
def extractedPair (E : CochainPlane.PlaneExtractionContext ℤ ι)
    (C : Context Fsheaf) : ProximityPrize.Word ι (Fin 2 → K) :=
  fun i j => ((E.projectedPlane C.cochain i j : ℤ) : K)

/-- A concrete local lifting criterion, not an assumed source-to-pair inequality. -/
structure LiftControl
    (C : Context Fsheaf)
    (E : CochainPlane.PlaneExtractionContext ℤ ι)
    (code : ProximityPrize.BlockCode ι (Fin 2 → K)) (scale : ℝ) where
  lift : {word // code.Codeword word} → Fsheaf.C1
  exact_lift : ∀ word, Fsheaf.IsExactOneCochain (lift word)
  decoder_bound : ∀ word,
    ‖C.interpretation.decode C.cochain - lift word‖ ≤
      scale * ProximityPrize.BlockCode.relativeHammingDistance
        word.val (extractedPair E C)

namespace LiftControl

variable {C : Context Fsheaf}
  {E : CochainPlane.PlaneExtractionContext ℤ ι}
  {code : ProximityPrize.BlockCode ι (Fin 2 → K)} {scale : ℝ}

/-- The nearest target codeword and its exact lift prove the geometric comparison. -/
theorem decodedDistance_le_scaled_pairDistance
    (control : LiftControl C E code scale)
    (hcode : ∃ word, code.Codeword word) :
    C.decodedDistance ≤ scale * code.relativeDistanceToCode (extractedPair E C) := by
  obtain ⟨word, hword, hnearest⟩ :=
    code.exists_nearest_codeword_relative hcode (extractedPair E C)
  calc
    C.decodedDistance ≤
        ‖C.interpretation.decode C.cochain - control.lift ⟨word, hword⟩‖ :=
      Fsheaf.exactDistance_le_norm_sub _ (control.exact_lift ⟨word, hword⟩)
    _ ≤ scale * ProximityPrize.BlockCode.relativeHammingDistance
          word (extractedPair E C) := control.decoder_bound ⟨word, hword⟩
    _ = scale * code.relativeDistanceToCode (extractedPair E C) := by
      rw [hnearest]

/-- The calibrated far implication, with the actual scale loss made explicit. -/
theorem decodedFar_implies_pairFar
    (control : LiftControl C E code scale)
    (hcode : ∃ word, code.Codeword word) (hscale : 0 < scale)
    (sourceRadius : ℝ) (hfar : sourceRadius ≤ C.decodedDistance) :
    sourceRadius / scale ≤ code.relativeDistanceToCode (extractedPair E C) := by
  apply (div_le_iff₀ hscale).2
  simpa only [mul_comm] using
    hfar.trans (control.decodedDistance_le_scaled_pairDistance hcode)

/-- Lifting also proves the required converse on exact target codewords. -/
theorem accepted_of_pairCodeword
    (control : LiftControl C E code scale)
    (hword : code.Codeword (extractedPair E C)) : C.Accepted := by
  have hbound := control.decodedDistance_le_scaled_pairDistance
    ⟨extractedPair E C, hword⟩
  have hzero := code.relativeDistanceToCode_eq_zero_of_codeword hword
  rw [hzero, mul_zero] at hbound
  exact C.accepted_iff_decodedDistance_eq_zero.mpr
    (le_antisymm hbound C.decodedDistance_nonneg)

end LiftControl

/-- A decoder/extraction mismatch is a genuine obstruction to this comparison. -/
theorem no_liftControl_of_nonexact_codeword
    (C : Context Fsheaf)
    (E : CochainPlane.PlaneExtractionContext ℤ ι)
    (code : ProximityPrize.BlockCode ι (Fin 2 → K))
    (hsource : ¬ C.Accepted)
    (htarget : code.Codeword (extractedPair E C)) :
    ¬ ∃ scale : ℝ, Nonempty (LiftControl C E code scale) := by
  rintro ⟨_, ⟨control⟩⟩
  exact hsource (control.accepted_of_pairCodeword htarget)

end HomotopicalEncryption.Protocol.Storage.Calibration
