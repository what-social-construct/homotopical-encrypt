module

public import Sheaf.CoefficientRecovery

@[expose] public section

/-!
# Linear retrieval answers from the original Hodge-structured samples

The client uses the existing harmonic lattice and `HodgeNoise` coordinates,
not arbitrary ambient masks. The server sees the observed cochains and forms
an integer-weighted sum. This sum is the observation of an actual encryption:
the selected database value multiplies the encoded harmonic coefficient,
while the exact and coexact noise openings combine separately.

The existing coefficient decoder and discrete-CVP comparison apply to that
same answer. These are correctness and original-object identification results,
not a selector-privacy theorem. A whole query is a joint view; the separate
obstruction module analyzes one possible disclosure from that view. Neither
the private lattice nor its projector is an input to the server's sum.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Storage.Retrieval.HodgeQuery

open Sheaf CellularSheaf
open scoped BigOperators

variable {Vertex Edge Face Rank Index : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face] [Fintype Rank]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}
  {I : IntegralStructure F}

/-- Zero coefficients give the zero harmonic point in the original encoder. -/
theorem point_zero (H : HarmonicLatticePresentation I Rank) : (H.point 0).1 = 0 := by
  apply PiLp.ext
  intro coordinate
  simp [HarmonicLatticePresentation.point, CVP.latticeVector, Matrix.mulVec, dotProduct]

/-- Integer scaling of coefficients scales the actual encoded harmonic point. -/
theorem point_int_mul (H : HarmonicLatticePresentation I Rank)
    (coefficient : Rank → ℤ) (value : ℤ) :
    (H.point (fun r => value * coefficient r)).1 = (value : ℝ) • (H.point coefficient).1 := by
  apply PiLp.ext
  intro coordinate
  change (∑ r, H.lattice.basis coordinate r * ((value * coefficient r : ℤ) : ℝ)) =
    (value : ℝ) * ∑ r, H.lattice.basis coordinate r * (coefficient r : ℝ)
  simp only [Int.cast_mul, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro r _
  ring

/-- The actual existing encryption at every database position, with a one-hot
coefficient vector and independently supplied exact/coexact openings. -/
def sample [DecidableEq Index] (H : HarmonicLatticePresentation I Rank)
    (coefficient : Rank → ℤ) (selected position : Index) (noise : Index → HodgeNoise F) :
    HodgeEncryptedCochain I :=
  H.encrypt (if position = selected then coefficient else 0) (noise position)

/-- Only the observed cochain columns are provided to the server. -/
def query [DecidableEq Index] (H : HarmonicLatticePresentation I Rank)
    (coefficient : Rank → ℤ) (selected : Index) (noise : Index → HodgeNoise F) :
    Index → F.C1 := fun position => (sample H coefficient selected position noise).observed

/-- Harmonic projection removes the actual exact/coexact noise, using the
existing encryption theorem for each same query sample. -/
theorem query_projection [DecidableEq Index] (H : HarmonicLatticePresentation I Rank)
    (coefficient : Rank → ℤ) (selected position : Index) (noise : Index → HodgeNoise F) :
    F.harmonicOneProjection (query H coefficient selected noise position) =
      if position = selected then (H.point coefficient).1 else 0 := by
  change F.harmonicOneProjection
    (H.encrypt (if position = selected then coefficient else 0) (noise position)).observed = _
  rw [H.encrypt_projection_eq_point]
  split_ifs <;> simp only [point_zero]

variable [Fintype Index]

/-- Public integer evaluation of observed columns. The server uses no Hodge
presentation, opening, harmonic lattice, projector or selected index. -/
def answer (database : Index → ℤ) (columns : Index → F.C1) : F.C1 :=
  ∑ position, (database position : ℝ) • columns position

/-- Noise aggregation retains the existing two opening coordinates separately. -/
def answerNoise (database : Index → ℤ) (noise : Index → HodgeNoise F) : HodgeNoise F where
  exactOpening := ∑ position, (database position : ℝ) • (noise position).exactOpening
  coexactOpening := ∑ position, (database position : ℝ) • (noise position).coexactOpening

/-- The evaluated noise is still an exact-plus-coexact Hodge value. -/
theorem answerNoise_value (database : Index → ℤ) (noise : Index → HodgeNoise F) :
    (answerNoise database noise).value =
      ∑ position, (database position : ℝ) • (noise position).value := by
  simp only [answerNoise, HodgeNoise.value, map_sum, map_smul,
    smul_add, Finset.sum_add_distrib]

/-- Actual encrypted source whose observation is the public server answer. -/
def answerSample (H : HarmonicLatticePresentation I Rank) (coefficient : Rank → ℤ)
    (database : Index → ℤ) (selected : Index) (noise : Index → HodgeNoise F) :
    HodgeEncryptedCochain I :=
  H.encrypt (fun r => database selected * coefficient r) (answerNoise database noise)

/-- The server response and the original structured-noise encrypted answer
are the same full cochain, not merely equal after taking a projection. -/
theorem answer_eq_observed [DecidableEq Index] (H : HarmonicLatticePresentation I Rank)
    (coefficient : Rank → ℤ) (database : Index → ℤ) (selected : Index)
    (noise : Index → HodgeNoise F) :
    answer database (query H coefficient selected noise) =
      (answerSample H coefficient database selected noise).observed := by
  simp only [answer, query, sample, HodgeEncryptedCochain.observed,
    HarmonicLatticePresentation.encrypt, smul_add, Finset.sum_add_distrib,
    answerSample, answerNoise_value]
  congr 1
  rw [point_int_mul]
  simp only [apply_ite, point_zero, smul_zero]
  simp

/-- Exact private decoding returns the selected database value in the declared
coefficient encoding, for the same full server response. -/
theorem decode_answer [DecidableEq Index] (H : HarmonicLatticePresentation I Rank)
    (coefficient : Rank → ℤ) (database : Index → ℤ) (selected : Index)
    (noise : Index → HodgeNoise F) :
    H.decodeCoefficients (answer database (query H coefficient selected noise)) =
      some (fun r => database selected * coefficient r) := by
  rw [answer_eq_observed]
  exact H.decodeCoefficients_encrypt _ _

/-- The existing discrete-CVP comparison identifies the same server answer's
unique solution in its selected private explicit lattice. -/
theorem cvp_answer_iff [DecidableEq Index] (H : HarmonicLatticePresentation I Rank)
    (coefficient : Rank → ℤ) (database : Index → ℤ) (selected : Index)
    (noise : Index → HodgeNoise F)
    (candidate : CVP.AmbientVector (TotalCoord Edge F.edgeDim)) :
    CVP.Solution
      ({ lattice := H.lattice, target := answer database (query H coefficient selected noise) } :
        CVP.Instance (TotalCoord Edge F.edgeDim) Rank) candidate ↔
      candidate = (H.point (fun r => database selected * coefficient r)).1 := by
  rw [answer_eq_observed]
  exact H.solution_cvpInstance_iff_eq_point _ _ _

end HomotopicalEncryption.Protocol.Storage.Retrieval.HodgeQuery
