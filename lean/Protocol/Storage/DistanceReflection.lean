module

public import Protocol.Storage.Calibration

@[expose] public section

/-!
# Geometric comparison from a bounded decoder and reflected validity

The source remains the original Euclidean distance to the exact cochains.
At positive block length a non-codeword has Hamming count at least one.
Consequently a bound on the decoded norm, together with a separately proved
reflection of codeword validity, gives an explicit comparison. This criterion
does not assume controlled lifts of every target codeword. Concrete codecs
must prove validity reflection; it is not supplied by a storage digest.
-/

set_option autoImplicit false

noncomputable section

namespace ProximityPrize.BlockCode

variable {ι α : Type*} [Fintype ι] [DecidableEq α]

/-- The first positive Hamming shell bounds the distance of every non-codeword. -/
theorem one_le_length_mul_relativeDistanceToCode_of_not_codeword
    (code : BlockCode ι α) (hcode : ∃ w, code.Codeword w)
    (hn : 0 < Fintype.card ι) {w : Word ι α} (hw : ¬ code.Codeword w) :
    1 ≤ (Fintype.card ι : ℝ) * code.relativeDistanceToCode w := by
  have hcount : code.hammingDistanceToCode w ≠ 0 := by
    intro hzero
    exact hw ((code.hammingDistanceToCode_eq_zero_iff hcode w).mp hzero)
  have hcount' : (1 : ℝ) ≤ code.hammingDistanceToCode w := by
    exact_mod_cast Nat.one_le_iff_ne_zero.mpr hcount
  have hn' : (Fintype.card ι : ℝ) ≠ 0 := by exact_mod_cast Nat.ne_of_gt hn
  unfold relativeDistanceToCode
  rw [mul_div_cancel₀ _ hn']
  exact hcount'

end ProximityPrize.BlockCode

namespace Hcrypt.Protocol.Storage.Calibration

open Sheaf CellularSheaf
open Hcrypt.Proximity

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {Fsheaf : CellularSheaf X}
  {K ι : Type} [Field K] [Fintype ι] [DecidableEq K]

/-- A bound on the actual decoded vector bounds its geometric distance to exactness. -/
theorem decodedDistance_le_norm (C : Context Fsheaf) :
    C.decodedDistance ≤ ‖C.interpretation.decode C.cochain‖ := by
  change Fsheaf.exactDistance (C.interpretation.decode C.cochain) ≤ _
  simpa using Fsheaf.exactDistance_le_norm_sub
    (C.interpretation.decode C.cochain) (c := 0) ⟨0, map_zero _⟩

/-- A bounded decoder and proved validity reflection imply a scaled comparison.
The reflection premise must come from the actual codec and its source profile. -/
theorem decodedDistance_le_scaled_pairDistance_of_reflection
    (C : Context Fsheaf) (E : CochainPlane.PlaneExtractionContext ℤ ι)
    (code : ProximityPrize.BlockCode ι (Fin 2 → K))
    (hcode : ∃ w, code.Codeword w) (hn : 0 < Fintype.card ι)
    {bound : ℝ} (hbound : 0 ≤ bound)
    (hnorm : ‖C.interpretation.decode C.cochain‖ ≤ bound)
    (hreflect : code.Codeword (extractedPair E C) → C.Accepted) :
    C.decodedDistance ≤ (bound * Fintype.card ι) *
      code.relativeDistanceToCode (extractedPair E C) := by
  by_cases haccepted : C.Accepted
  · rw [C.accepted_iff_decodedDistance_eq_zero.mp haccepted]
    exact mul_nonneg (mul_nonneg hbound (Nat.cast_nonneg _))
      (code.relativeDistanceToCode_nonneg _)
  · have hnot : ¬ code.Codeword (extractedPair E C) :=
      fun h => haccepted (hreflect h)
    have hgap := code.one_le_length_mul_relativeDistanceToCode_of_not_codeword
      hcode hn hnot
    calc
      C.decodedDistance ≤ bound := (decodedDistance_le_norm C).trans hnorm
      _ ≤ bound * (Fintype.card ι *
          code.relativeDistanceToCode (extractedPair E C)) := by
        simpa using mul_le_mul_of_nonneg_left hgap hbound
      _ = _ := by ring

/-- Source farness transfers with the explicit finite-shell scale loss. -/
theorem decodedFar_implies_pairFar_of_reflection
    (C : Context Fsheaf) (E : CochainPlane.PlaneExtractionContext ℤ ι)
    (code : ProximityPrize.BlockCode ι (Fin 2 → K))
    (hcode : ∃ w, code.Codeword w) (hn : 0 < Fintype.card ι)
    {bound : ℝ} (hbound : 0 < bound)
    (hnorm : ‖C.interpretation.decode C.cochain‖ ≤ bound)
    (hreflect : code.Codeword (extractedPair E C) → C.Accepted)
    (sourceRadius : ℝ) (hfar : sourceRadius ≤ C.decodedDistance) :
    sourceRadius / (bound * Fintype.card ι) ≤
      code.relativeDistanceToCode (extractedPair E C) := by
  have hscale : 0 < bound * (Fintype.card ι : ℝ) :=
    mul_pos hbound (by exact_mod_cast hn)
  apply (div_le_iff₀ hscale).mpr
  simpa only [mul_comm] using hfar.trans
    (decodedDistance_le_scaled_pairDistance_of_reflection
      C E code hcode hn hbound.le hnorm hreflect)

end Hcrypt.Protocol.Storage.Calibration
