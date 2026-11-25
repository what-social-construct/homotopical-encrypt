module

public import Hardness

@[expose] public section

/-!
# Exact harmonic target lift for unrestricted CVP

The real span of an explicit lattice is a harmonic subspace for the existing
projection operator. Projecting an arbitrary target into that subspace
preserves the original lattice and every discrete closest-vector answer.
The projected instance still asks for a nearest lattice point.
-/

set_option autoImplicit false

open scoped Classical

noncomputable section

namespace HarmonicCVPBridge

variable {m n : Type} [Fintype m] [Fintype n]

/-- Regard the real range of the basis as the harmonic subspace. -/
def ofExplicitLattice (L : CVP.ExplicitLattice m n) : HarmonicCVPBridge m n where
  lattice := L
  harmonicSubspace := LinearMap.range
    ((WithLp.linearEquiv 2 ℝ (m → ℝ)).symm.toLinearMap.comp L.basis.mulVecLin)
  latticeVector_mem z := ⟨fun j => (z j : ℝ), rfl⟩

/-- Keep the original basis and replace the target with its harmonic projection. -/
def projectedInstance (I : CVP.Instance m n) : CVP.Instance m n :=
  let H := ofExplicitLattice I.lattice
  H.cvpInstance (H.projectedTarget I.target)

/-- The target of the lifted instance is harmonic for the basis-span Laplacian. -/
theorem projectedInstance_target_isHarmonic (I : CVP.Instance m n) :
    MatrixIsHarmonic (laplacian (ofExplicitLattice I.lattice).harmonicSubspace)
      (projectedInstance I).target :=
  (ofExplicitLattice I.lattice).projectedTarget_isHarmonic I.target

/-- Every closest vector of the input instance solves the harmonic instance,
and every closest vector of the harmonic instance solves the input instance. -/
theorem solution_iff_projectedInstance (I : CVP.Instance m n) (v : CVP.AmbientVector m) :
    CVP.Solution I v ↔ CVP.Solution (projectedInstance I) v :=
  (ofExplicitLattice I.lattice).solution_iff_projectedTarget I.target v

/-- One query to an oracle that finds a nearest lattice point for every
harmonic target gives an exact solver for arbitrary CVP targets. -/
theorem oracleCorrect_of_harmonicTargets (O : CVP.Oracle m n)
    (correct : ∀ (L : CVP.ExplicitLattice m n) (t : CVP.AmbientVector m),
      MatrixIsHarmonic (laplacian (ofExplicitLattice L).harmonicSubspace) t →
        CVP.IsClosestLatticeVector L t (O L t)) :
    CVP.OracleCorrect (fun L t => O L (projectedInstance ⟨L, t⟩).target) := by
  intro L t
  exact (solution_iff_projectedInstance ⟨L, t⟩ _).mpr
    (correct L _ (projectedInstance_target_isHarmonic ⟨L, t⟩))

end HarmonicCVPBridge
