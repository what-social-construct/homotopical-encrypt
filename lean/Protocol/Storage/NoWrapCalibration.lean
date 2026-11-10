module

public import Protocol.Storage.CoordinateCodec
public import Proximity.Core.Systematic

@[expose] public section

/-!
# An explicit no-wrap bridge for systematic Reed--Solomon cochains

The real exact subspace is identified with the kernel of the real systematic
check built from integer-lifted RS interpolation coefficients. A bound on the
INTEGER SYNDROME prevents modular cancellation; bounding payload coordinates
alone would not do so. Finite-field validity then reflects actual geometric
exactness, and the independent Euclidean source distance transfers through
the same stored payload's complete coordinate extraction.

`SystematicModel` records a structural identification, not a distance bound.
Its cellular realization is separate from snapshot authentication and from
any encryption/security claim.

This theorem concerns raw received contexts. Positive decoded farness excludes
an already accepted exact payload, so it does not construct a far witness for
an accepted ledger anchor or identify a full HCP/frame residual. The finite
shell bound certifies at most the first positive Hamming shell for a nonempty
source far region; it is not a capacity- or Johnson-radius result.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Storage

open Sheaf CellularSheaf

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}
  {F : CellularSheaf X} {ι : Type} [Fintype ι] [DecidableEq ι]
  {q : ℕ} [Fact q.Prime]

/-- Identification of the actual real exact subspace with the systematic check kernel. -/
structure SystematicModel (L : CoordinateLayout F ι)
    (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι) : Prop where
  exact_iff : ∀ b : F.C1,
    F.IsExactOneCochain b ↔ ∀ j : Fin 2,
      P.realCheck S (fun i => b (L.coordinate (i, j))) = 0

namespace SystematicModel

variable {L : CoordinateLayout F ι}
  {P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι} {S : Finset ι}

/-- The check is on the actual integer plane extracted from the original payload. -/
def NoWrap (_M : SystematicModel L P S) (C : Context F) : Prop :=
  ∀ j : Fin 2, P.NoWrap S (fun i => L.raw C.cochain i j)

/-- Modular codeword validity reflects exactness under the no-wrap syndrome profile. -/
theorem accepted_of_pairCodeword
    (M : SystematicModel L P S) (C : Context F)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (hdecode : C.interpretation.decode C.cochain = L.decode C.cochain)
    (hwrap : M.NoWrap C)
    (hword : (P.vectorBlockCode (Fin 2)).Codeword
      (Calibration.extractedPair (K := ZMod q) L.extraction C)) : C.Accepted := by
  have hcheck := P.realCheck_components_eq_zero_of_vectorCodeword_of_noWrap
    S hDegree hS (L.raw C.cochain) hword hwrap
  have hexact : F.IsExactOneCochain (C.interpretation.decode C.cochain) := by
    apply M.exact_iff _ |>.mpr
    intro j
    rw [hdecode]
    simpa only [CoordinateLayout.decode_coordinate] using hcheck j
  obtain ⟨a, ha⟩ := hexact
  exact ⟨C.artifactWellFormed.1, C.boundToSnapshot, a, ha.symm⟩

/-- A quantitative theorem about the original decoded cochain and actual pair.
No target pullback metric or assumed source-to-pair inequality appears. -/
theorem decodedFar_implies_pairFar
    (M : SystematicModel L P S) (C : Context F)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (hn : 0 < Fintype.card ι)
    (hdecode : C.interpretation.decode C.cochain = L.decode C.cochain)
    (hwrap : M.NoWrap C)
    {bound : ℝ} (hbound : 0 < bound)
    (hcoords : ∀ i j, |(L.raw C.cochain i j : ℝ)| ≤ bound)
    (sourceRadius : ℝ) (hfar : sourceRadius ≤ C.decodedDistance) :
    sourceRadius /
      (Real.sqrt (F.edgeCoordinateCount * bound ^ 2) * Fintype.card ι) ≤
        (P.vectorBlockCode (Fin 2)).relativeDistanceToCode
          (Calibration.extractedPair (K := ZMod q) L.extraction C) := by
  have hzero : (P.vectorBlockCode (Fin 2)).Codeword (fun _ _ => 0) := by
    intro _j
    exact (P.fAdditive_of_degreeBound_pos hDegree).zero_mem
  apply L.decodedFar_implies_pairFar C (P.vectorBlockCode (Fin 2))
    ⟨_, hzero⟩ hn hdecode hbound hcoords
  · exact M.accepted_of_pairCodeword C hDegree hS hdecode hwrap
  · exact hfar

end SystematicModel
end HomotopicalEncryption.Protocol.Storage
