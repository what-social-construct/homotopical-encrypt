module

public import Protocol.Storage.DistanceReflection

@[expose] public section

/-!
# A complete coordinate codec for the original stored cochain

The layout records both the geometric coordinate ordering and the serialized
list ordering. Its extraction reads every geometric coordinate exactly once,
with integer coefficients unchanged. The real decoder and finite-field pair
therefore come from the same original payload, rather than from unrelated
functions bearing the same source type. Snapshot authentication of this chosen
ordering remains an outer interpretation obligation.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Storage

open Sheaf CellularSheaf
open HomotopicalEncryption.Proximity

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}
  {F : CellularSheaf X} {ι : Type} [Fintype ι]

/-- Explicit geometric and serialized orderings; neither is inferred from a digest. -/
structure CoordinateLayout (F : CellularSheaf X) (ι : Type) where
  coordinate : (ι × Fin 2) ≃ TotalCoord Edge F.edgeDim
  serialized : TotalCoord Edge F.edgeDim ≃ Fin F.edgeCoordinateCount

namespace CoordinateLayout

/-- The actual full-coordinate extraction, with no integer preprocessing. -/
def extraction (L : CoordinateLayout F ι) : CochainPlane.PlaneExtractionContext ℤ ι where
  edgeCount := F.edgeCoordinateCount
  edgeIndex i j := (L.serialized (L.coordinate (i, j))).val
  coefficient := id

/-- Both integer coordinates are read from the existing original payload. -/
def raw (L : CoordinateLayout F ι) (c : Axioms.CochainCommitmentData) :
    ι → Fin 2 → ℤ := L.extraction.projectedPlane c

/-- The real cochain decoder uses exactly the declared serialized ordering. -/
def decode (L : CoordinateLayout F ι) (c : Axioms.CochainCommitmentData) : F.C1 :=
  WithLp.toLp 2 fun coordinate =>
    (c.edge_values.getD (L.serialized coordinate).val 0 : ℝ)

@[simp]
theorem decode_coordinate (L : CoordinateLayout F ι)
    (c : Axioms.CochainCommitmentData) (i : ι) (j : Fin 2) :
    L.decode c (L.coordinate (i, j)) = (L.raw c i j : ℝ) := rfl

theorem locallyNondegenerate (L : CoordinateLayout F ι) :
    L.extraction.LocallyNondegenerate := by
  intro i h
  have hfin : L.serialized (L.coordinate (i, 0)) =
      L.serialized (L.coordinate (i, 1)) := Fin.ext h
  have hpair := L.coordinate.injective (L.serialized.injective hfin)
  have hzero := congrArg Prod.snd hpair
  exact Fin.zero_ne_one hzero

/-- A bound context already supplies the exact list length needed by the layout. -/
theorem aligned (L : CoordinateLayout F ι) (C : Context F) :
    L.extraction.Aligned C.cochain := by
  have hlength : C.cochain.edge_values.length = F.edgeCoordinateCount := by
    change C.artifact.cochain.edge_values.length = F.edgeCoordinateCount
    rw [← C.artifactWellFormed.1.2.1]
    exact C.boundToSnapshot.2.1
  refine ⟨C.artifactWellFormed.1, C.boundToSnapshot.2.1, ?_⟩
  intro i j
  rw [hlength]
  exact (L.serialized (L.coordinate (i, j))).isLt

/-- Full coverage fixes the number of real scalar coordinates to twice the length. -/
theorem coordinateCount (L : CoordinateLayout F ι) :
    F.edgeCoordinateCount = 2 * Fintype.card ι := by
  have h := Fintype.card_congr L.coordinate
  simpa [edgeCoordinateCount, Fintype.card_prod, Fintype.card_fin, Nat.mul_comm] using h.symm

/-- A coordinate envelope gives a bound in the original Euclidean norm. -/
theorem norm_decode_sq_le (L : CoordinateLayout F ι)
    (c : Axioms.CochainCommitmentData) {bound : ℝ} (hbound : 0 ≤ bound)
    (hcoords : ∀ i j, |(L.raw c i j : ℝ)| ≤ bound) :
    ‖L.decode c‖ ^ 2 ≤ F.edgeCoordinateCount * bound ^ 2 := by
  rw [EuclideanSpace.real_norm_sq_eq]
  calc
    ∑ a : TotalCoord Edge F.edgeDim, (L.decode c a) ^ 2 ≤
        ∑ _a : TotalCoord Edge F.edgeDim, bound ^ 2 := by
      apply Finset.sum_le_sum
      intro a _ha
      obtain ⟨⟨i, j⟩, rfl⟩ := L.coordinate.surjective a
      rw [decode_coordinate]
      simpa only [sq_abs] using
        (sq_le_sq₀ (abs_nonneg _) hbound).mpr (hcoords i j)
    _ = F.edgeCoordinateCount * bound ^ 2 := by simp [edgeCoordinateCount]

theorem norm_decode_le (L : CoordinateLayout F ι)
    (c : Axioms.CochainCommitmentData) {bound : ℝ} (hbound : 0 ≤ bound)
    (hcoords : ∀ i j, |(L.raw c i j : ℝ)| ≤ bound) :
    ‖L.decode c‖ ≤ Real.sqrt (F.edgeCoordinateCount * bound ^ 2) :=
  Real.le_sqrt_of_sq_le (L.norm_decode_sq_le c hbound hcoords)

/-- Apply the finite-shell comparison to this explicit decoder/extractor pair. -/
theorem decodedFar_implies_pairFar
    (L : CoordinateLayout F ι) (C : Context F)
    {K : Type} [Field K] [DecidableEq K]
    (code : ProximityCoding.BlockCode ι (Fin 2 → K))
    (hcode : ∃ w, code.Codeword w) (hn : 0 < Fintype.card ι)
    (hdecode : C.interpretation.decode C.cochain = L.decode C.cochain)
    {bound : ℝ} (hbound : 0 < bound)
    (hcoords : ∀ i j, |(L.raw C.cochain i j : ℝ)| ≤ bound)
    (hreflect : code.Codeword (Calibration.extractedPair L.extraction C) → C.Accepted)
    (sourceRadius : ℝ) (hfar : sourceRadius ≤ C.decodedDistance) :
    sourceRadius /
      (Real.sqrt (F.edgeCoordinateCount * bound ^ 2) * Fintype.card ι) ≤
        code.relativeDistanceToCode (Calibration.extractedPair L.extraction C) := by
  have hcount : 0 < F.edgeCoordinateCount := by rw [L.coordinateCount]; omega
  have hscale : 0 < Real.sqrt (F.edgeCoordinateCount * bound ^ 2) := by
    apply Real.sqrt_pos.mpr
    exact mul_pos (by exact_mod_cast hcount) (sq_pos_of_pos hbound)
  apply Calibration.decodedFar_implies_pairFar_of_reflection
    C L.extraction code hcode hn hscale
  · rw [hdecode]
    exact L.norm_decode_le C.cochain hbound.le hcoords
  · exact hreflect
  · exact hfar

end CoordinateLayout
end HomotopicalEncryption.Protocol.Storage
