module

public import Laplacian.Grassmannian.Metric
public import Proximity.Concrete.GrassmannianPlucker.Reconstruction

@[expose] public section

/-!
# Projector distance from full projective Plücker data

Reconstruct each subspace from its full projective shadow and apply the
shared chordal distance. This recovers the original projector distance for
independent frames. On these genuine frame shadows the distance separates
the projective points.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Proximity.GrassmannianPlucker.Concrete

open HomotopicalEncryption.Laplacian.Grassmannian

variable {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}

/-- Pull back chordal distance along reconstruction of the full shadows. -/
def projectiveChordalDistance (S T : ProjectiveShadow n r) : ℝ :=
  chordalDistance (recoverSubspace S) (recoverSubspace T)

/-- Reconstruction gives the chordal distance of the original frame carriers. -/
@[simp] theorem projectiveChordalDistance_publicShadow (W V : FrameWitness n r) :
    projectiveChordalDistance ((projectiveFramedSystem n r).publicShadow W)
      ((projectiveFramedSystem n r).publicShadow V) =
        chordalDistance W.point.carrier V.point.carrier := by
  change projectiveChordalDistance (normalizeProjective W.toExterior)
    (normalizeProjective V.toExterior) = _
  rw [projectiveChordalDistance, recoverSubspace_frame, recoverSubspace_frame]

/-- Distance zero identifies exactly equal full projective shadows of
independent frames. -/
theorem projectiveChordalDistance_publicShadow_eq_zero_iff (W V : FrameWitness n r) :
    projectiveChordalDistance ((projectiveFramedSystem n r).publicShadow W)
      ((projectiveFramedSystem n r).publicShadow V) = 0 ↔
    (projectiveFramedSystem n r).publicShadow W =
      (projectiveFramedSystem n r).publicShadow V := by
  rw [projectiveChordalDistance_publicShadow, chordalDistance_eq_zero_iff]
  constructor
  · intro h
    apply (publicShadow_eq_iff_same_point W V).2
    generalize W.point = U at *
    generalize V.point = T at *
    cases U
    cases T
    cases h
    rfl
  · exact carrier_eq_of_publicShadow_eq

end HomotopicalEncryption.Proximity.GrassmannianPlucker.Concrete
