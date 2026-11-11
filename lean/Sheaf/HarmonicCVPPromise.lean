module

public import Sheaf.HarmonicLattice

@[expose] public section

/-!
# The orthogonal-noise promise for harmonic-lattice observations

An ambient target is a lattice point plus noise orthogonal to the harmonic
subspace exactly when its harmonic projection belongs to the presented
discrete lattice. This identifies the promise satisfied by generated Hodge
samples; arbitrary CVP targets need not satisfy this promise.
-/

set_option autoImplicit false

open scoped RealInnerProductSpace

noncomputable section

namespace HomotopicalEncryption
namespace Sheaf
namespace CellularSheaf

variable
  {Vertex Edge Face Rank : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face] [Fintype Rank]
  {X : OrientedTwoComplex Vertex Edge Face}
  {F : CellularSheaf X}
  {I : IntegralStructure F}

/-- Exact characterization of observations made from a presented harmonic
lattice point and arbitrary orthogonal noise. This is a geometric promise;
the concrete `HodgeNoise` record additionally supplies exact and coexact
coordinates for the noise. -/
theorem HarmonicLatticePresentation.orthogonal_sample_iff_projection_mem_lattice
    (H : HarmonicLatticePresentation I Rank) (t : F.C1) :
    (∃ (z : Rank → ℤ) (e : F.C1),
      e ∈ F.harmonicOneSubspace.orthogonal ∧ t = (H.point z).1 + e) ↔
      CVP.InExplicitLattice H.lattice (F.harmonicOneProjection t) := by
  constructor
  · rintro ⟨z, e, he, rfl⟩
    have hpoint : (H.point z).1 ∈ F.harmonicOneSubspace :=
      I.harmonic_of_mem_harmonicOneLattice (H.point z).2
    have hproj : F.harmonicOneProjection ((H.point z).1 + e) =
        (H.point z).1 := by
      rw [harmonicOneProjection, LinearMap.map_add]
      change F.harmonicOneSubspace.starProjection (H.point z).1 +
        F.harmonicOneSubspace.starProjection e = (H.point z).1
      rw [F.harmonicOneSubspace.starProjection_eq_self_iff.mpr hpoint]
      rw [F.harmonicOneSubspace.starProjection_apply_eq_zero_iff.mpr he]
      exact add_zero _
    rw [hproj]
    exact H.point_mem_explicitLattice z
  · rintro ⟨z, hz⟩
    have hproj : F.harmonicOneProjection t = (H.point z).1 := by
      change CVP.latticeVector H.lattice z =
        F.harmonicOneProjection t at hz
      exact (congrArg (WithLp.toLp 2) hz).symm
    refine ⟨z, t - (H.point z).1, ?_, ?_⟩
    · rw [← hproj]
      change t - F.harmonicOneSubspace.starProjection t ∈
        F.harmonicOneSubspace.orthogonal
      exact F.harmonicOneSubspace.sub_starProjection_mem_orthogonal t
    · abel

/-- A correct oracle for the supplied explicit lattice returns the encoded
point on a generated Hodge sample. -/
theorem HarmonicLatticePresentation.correct_cvp_oracle_recovers_encrypt
    (H : HarmonicLatticePresentation I Rank)
    (O : CVP.Oracle (TotalCoord Edge F.edgeDim) Rank)
    (hO : CVP.OracleCorrect O)
    (z : Rank → ℤ) (opening : HodgeNoise F) :
    O H.lattice (H.encrypt z opening).observed = (H.point z).1 := by
  exact (H.solution_cvpInstance_iff_eq_point z opening
    (O H.lattice (H.encrypt z opening).observed)).mp
      (hO H.lattice (H.encrypt z opening).observed)

end CellularSheaf
end Sheaf
end HomotopicalEncryption
