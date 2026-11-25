module

public import Mathlib.LinearAlgebra.Projectivization.Basic
public import Proximity.Concrete.GrassmannianPlucker.Reconstruction

@[expose] public section

/-!
# Projective points represented by independent frames

An independent frame gives a nonzero exterior product in Mathlib's
projectivization. For these frame witnesses, equality agrees with both the
existing full shadow and equality of the ranked harmonic subspace.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Proximity.GrassmannianPlucker.Concrete

variable {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}

/-- An independent frame's nonzero exterior product in projective space. -/
def frameProjectivePoint (W : FrameWitness n r) : Projectivization ℝ (ExteriorCoordinate n r) :=
  Projectivization.mk ℝ W.toExterior (frame_toExterior_ne_zero W)

/-- The Mathlib point and full shadow give the same equality test on frames. -/
theorem frameProjectivePoint_eq_iff_publicShadow_eq (W V : FrameWitness n r) :
    frameProjectivePoint W = frameProjectivePoint V ↔
      (projectiveFramedSystem n r).publicShadow W =
        (projectiveFramedSystem n r).publicShadow V := by
  rw [frameProjectivePoint, frameProjectivePoint, Projectivization.mk_eq_mk_iff]
  constructor
  · rintro ⟨u, h⟩
    change normalizeProjective W.toExterior = normalizeProjective V.toExterior
    symm
    apply normalizeProjective_eq_of_projectivelyEquivalent
    exact ⟨u, by simpa only [Units.smul_def] using h.symm⟩
  · intro h
    obtain ⟨u, hu⟩ := projectivelyEquivalent_of_same_point V W
      ((publicShadow_eq_iff_same_point W V).mp h).symm
    exact ⟨u, by simpa only [Units.smul_def] using hu.symm⟩

/-- A frame's Mathlib projective point determines its ranked harmonic subspace. -/
theorem frameProjectivePoint_eq_iff_same_point (W V : FrameWitness n r) :
    frameProjectivePoint W = frameProjectivePoint V ↔ W.point = V.point :=
  (frameProjectivePoint_eq_iff_publicShadow_eq W V).trans
    (publicShadow_eq_iff_same_point W V)

end HomotopicalEncryption.Proximity.GrassmannianPlucker.Concrete
