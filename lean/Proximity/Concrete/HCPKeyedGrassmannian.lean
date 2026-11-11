module

public import Sheaf.HCPFiniteKeyGeometry
public import Proximity.Concrete.GrassmannianPlucker.Reconstruction

@[expose] public section

/-!
# Grassmannian and projective points of the finite keyed cellular family

The shared sheaf geometry supplies each keyed harmonic subspace and its
coordinate frame. This adapter packages those spaces as Grassmannian points,
Plücker frame witnesses, and full projective disclosures.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Proximity.HCPKeyedGrassmannian

open HomotopicalEncryption.Sheaf
open HomotopicalEncryption.Sheaf.HCPFiniteKeyFamily
open HomotopicalEncryption.Sheaf.HCPFiniteKeyGeometry
open CellularSheaf

variable (n : ℕ)

/-- The keyed harmonic subspace has one real dimension per Hodge edge. -/
def harmonicPoint (key : Key n) : HarmonicSubspace (Index n) n where
  carrier := harmonicSubspace n key
  rank_eq := by
    rw [harmonicSubspace_eq_span_harmonicUnit]
    simpa using
      (finrank_span_eq_card (R := ℝ) (harmonicUnit_linearIndependent n key))

/-- The complementary coordinate units give an actual Plücker frame witness. -/
def frameWitness (key : Key n) :
    GrassmannianPlucker.FrameWitness (Index n) n where
  point := harmonicPoint n key
  frame := harmonicUnit n key
  frame_mem i := LinearMap.mem_ker.mpr (harmonicUnit_harmonic n key i)
  independent := harmonicUnit_linearIndependent n key
  spans_submodule := (harmonicSubspace_eq_span_harmonicUnit n key).symm

/-- The full real Plücker point determines the keyed harmonic subspace, hence
the binary key in this family. This concerns full-point disclosure only. -/
theorem fullProjectivePoint_injective :
    Function.Injective (fun key : Key n =>
      GrassmannianPlucker.Concrete.normalizeProjective
        (frameWitness n key).toExterior) := by
  intro key otherKey hpoint
  have hrec := congrArg
    (fun σ : GrassmannianPlucker.Concrete.ProjectiveShadow (Index n) n =>
      GrassmannianPlucker.Concrete.recoverSubspace σ) hpoint
  simp only [GrassmannianPlucker.Concrete.recoverSubspace_frame] at hrec
  exact harmonicSubspace_injective n hrec

end HomotopicalEncryption.Proximity.HCPKeyedGrassmannian
