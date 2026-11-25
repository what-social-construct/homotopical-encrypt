module

public import HCP.CoupledCVP
public import Mathlib.Algebra.Module.ZLattice.Basic

@[expose] public section

/-!
# The original coupled harmonic lattice and its coefficient charts

The integral graph points are the entire intrinsic subgroup
`C¹_ℤ ∩ ker Δ₁` of the existing coupled cellular sheaf. Real coefficients
parametrize its harmonic subspace, and integer coefficients parametrize that
same intrinsic subgroup. The graph basis is consequently a full lattice basis
inside the harmonic subspace, rather than inside the larger cochain space.

The Mathlib lattice below is only a retyping of the original intrinsic
subgroup along the harmonic-subspace inclusion. Its equality with the integer
span of the real graph basis supplies discreteness and `IsZLattice`; no new
unrelated lattice is chosen. The original intrinsic carrier is discrete too.

For a general integral cellular sheaf, an intrinsic harmonic subgroup need
not span the harmonic subspace. A `HarmonicLatticePresentation` separately
assumes full real span and need not contain every intrinsic integral point.
The coupled profile has the stronger saturated graph characterization already
proved in `HCPCoupledFamily` and `CoupledCVP`. None of these lattice results
asserts computational hardness, cryptographic hiding or a lifecycle policy.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.HCP.CoupledLattice

open Sheaf CellularSheaf HCPCoupledFamily
open scoped BigOperators

variable {Row Col : Type*} [Fintype Row] [Fintype Col]
  [DecidableEq Row] [DecidableEq Col]

/-- Real coefficients identify the original harmonic subspace through its graph. -/
def realGraphEquiv (B : Matrix Row Col ℤ) :
    (Col → ℝ) ≃ₗ[ℝ] (sheaf B).harmonicOneSubspace where
  toFun z := ⟨graphVector B z, LinearMap.mem_ker.mpr (graphVector_harmonic B z)⟩
  invFun h := information h.1
  left_inv z := rfl
  right_inv h := by
    apply Subtype.ext
    exact (eq_graphVector_of_harmonic B (LinearMap.mem_ker.mp h.property)).symm
  map_add' z w := by
    apply Subtype.ext
    apply PiLp.ext
    rintro ⟨edge, component⟩
    cases edge with
    | none => simp [graphVector]
    | some edge =>
      cases edge <;> simp [graphVector, mul_add, Finset.sum_add_distrib]
  map_smul' scalar z := by
    apply Subtype.ext
    apply PiLp.ext
    rintro ⟨edge, component⟩
    cases edge with
    | none => simp [graphVector]
    | some edge =>
      cases edge <;>
        simp [graphVector, smul_eq_mul, Finset.mul_sum, mul_left_comm]

@[simp] theorem realGraphEquiv_coe (B : Matrix Row Col ℤ) (z : Col → ℝ) :
    (realGraphEquiv B z).1 = graphVector B z := rfl

@[simp] theorem realGraphEquiv_symm_apply (B : Matrix Row Col ℤ)
    (h : (sheaf B).harmonicOneSubspace) :
    (realGraphEquiv B).symm h = information h.1 := rfl

/-- The real basis consists of the original graph vectors `(0,e_c,B e_c)`. -/
def harmonicBasis (B : Matrix Row Col ℤ) :
    Module.Basis Col ℝ (sheaf B).harmonicOneSubspace :=
  (Pi.basisFun ℝ Col).map (realGraphEquiv B)

@[simp] theorem harmonicBasis_repr (B : Matrix Row Col ℤ)
    (h : (sheaf B).harmonicOneSubspace) (col : Col) :
    (harmonicBasis B).repr h col = information h.1 col := by
  simp [harmonicBasis, realGraphEquiv_symm_apply]

/-- Additive graph encoding into the original intrinsic integral subgroup. -/
def integerGraphHom (B : Matrix Row Col ℤ) :
    (Col → ℤ) →+ (integralStructure B).harmonicOneLattice where
  toFun z := HCPCoupledEncoding.message B z
  map_zero' := by
    apply Subtype.ext
    apply PiLp.ext
    rintro ⟨edge, component⟩
    cases edge with
    | none => rfl
    | some edge => cases edge <;> simp [HCPCoupledEncoding.message, graphVector]
  map_add' z w := by
    apply Subtype.ext
    have cast_add : (fun col => ((z + w) col : ℝ)) =
        (fun col => (z col : ℝ)) + (fun col => (w col : ℝ)) := by
      funext col
      simp
    change graphVector B (fun col => ((z + w) col : ℝ)) =
      graphVector B (fun col => (z col : ℝ)) + graphVector B (fun col => (w col : ℝ))
    rw [cast_add]
    exact congrArg Subtype.val ((realGraphEquiv B).map_add _ _)

/-- Integer coefficients exhaust the same intrinsic harmonic subgroup; this
uses saturation, not merely full real span of an arbitrary presentation. -/
def integerGraphEquiv (B : Matrix Row Col ℤ) :
    (Col → ℤ) ≃ₗ[ℤ] (integralStructure B).harmonicOneLattice :=
  (AddEquiv.ofBijective (integerGraphHom B) (by
    constructor
    · intro z w same
      have coordinates := graphVector_injective B (congrArg Subtype.val same)
      funext col
      exact_mod_cast congrFun coordinates col
    · intro h
      obtain ⟨z, point⟩ := (HCPCoupledFamily.mem_harmonicOneLattice_iff B h.1).mp h.property
      refine ⟨z, ?_⟩
      apply Subtype.ext
      exact point.symm)).toIntLinearEquiv

@[simp] theorem integerGraphEquiv_apply (B : Matrix Row Col ℤ) (z : Col → ℤ) :
    integerGraphEquiv B z = HCPCoupledEncoding.message B z := rfl

/-- The coefficient equivalence uses the same point as the existing explicit
CVP/harmonic-lattice presentation, not an alternative message encoding. -/
theorem integerGraphEquiv_eq_point (B : Matrix Row Col ℤ) (z : Col → ℤ) :
    integerGraphEquiv B z = (CoupledCVP.harmonicLatticePresentation B).point z := by
  apply Subtype.ext
  exact (CoupledCVP.latticeVector_eq_graphVector B z).symm

/-- Integer coefficient inversion recovers exactly the original information coordinates. -/
theorem integerGraphEquiv_symm_information (B : Matrix Row Col ℤ)
    (h : (integralStructure B).harmonicOneLattice) (col : Col) :
    (((integerGraphEquiv B).symm h col : ℤ) : ℝ) = information h.1 col := by
  have point := congrArg (fun value : (integralStructure B).harmonicOneLattice =>
    information value.1 col) ((integerGraphEquiv B).apply_symm_apply h)
  exact point

/-- A full integer basis of the original intrinsic subgroup. -/
def integerBasis (B : Matrix Row Col ℤ) :
    Module.Basis Col ℤ (integralStructure B).harmonicOneLattice :=
  (Pi.basisFun ℤ Col).map (integerGraphEquiv B)

/-- The intrinsic integral rank is the number of information coordinates. -/
theorem intrinsic_finrank (B : Matrix Row Col ℤ) :
    Module.finrank ℤ (integralStructure B).harmonicOneLattice = Fintype.card Col :=
  Module.finrank_eq_card_basis (integerBasis B)

/-- Retype the original subgroup inside the actual harmonic subspace. -/
def intrinsicInHarmonicSpace (B : Matrix Row Col ℤ) :
    Submodule ℤ (sheaf B).harmonicOneSubspace :=
  ((integralStructure B).harmonicOneLattice.toIntSubmodule).comap
    ((sheaf B).harmonicOneSubspace.subtype.restrictScalars ℤ)

omit [DecidableEq Col] in
@[simp] theorem mem_intrinsicInHarmonicSpace (B : Matrix Row Col ℤ)
    (h : (sheaf B).harmonicOneSubspace) :
    h ∈ intrinsicInHarmonicSpace B ↔ h.1 ∈ (integralStructure B).harmonicOneLattice := Iff.rfl

/-- The entire original intrinsic subgroup is exactly the integer span of
the real graph basis, after its canonical restriction to the harmonic space. -/
theorem intrinsic_eq_zspan_basis (B : Matrix Row Col ℤ) :
    intrinsicInHarmonicSpace B = Submodule.span ℤ (Set.range (harmonicBasis B)) := by
  ext h
  rw [mem_intrinsicInHarmonicSpace, (harmonicBasis B).mem_span_iff_repr_mem ℤ]
  constructor
  · intro member col
    obtain ⟨z, point⟩ := (HCPCoupledFamily.mem_harmonicOneLattice_iff B h.1).mp member
    refine ⟨z col, ?_⟩
    rw [harmonicBasis_repr, point, graphVector_information]
    rfl
  · intro coordinates
    have each : ∀ col, ∃ value : ℤ, (value : ℝ) = information h.1 col := by
      intro col
      obtain ⟨value, equal⟩ := coordinates col
      exact ⟨value, by
        simpa only [harmonicBasis_repr, algebraMap_int_eq, Int.coe_castRingHom] using equal⟩
    choose z point using each
    apply (HCPCoupledFamily.mem_harmonicOneLattice_iff B h.1).mpr
    refine ⟨z, ?_⟩
    calc
      h.1 = graphVector B (information h.1) :=
        eq_graphVector_of_harmonic B (LinearMap.mem_ker.mp h.property)
      _ = graphVector B (fun col => (z col : ℝ)) := by
        congr 1
        funext col
        exact (point col).symm

/-- The original lattice restricted to its harmonic ambient space is discrete. -/
instance intrinsicInHarmonicSpace_discrete (B : Matrix Row Col ℤ) :
    DiscreteTopology (intrinsicInHarmonicSpace B) := by
  rw [intrinsic_eq_zspan_basis]
  infer_instance

/-- Its full-lattice property is relative to the harmonic space, not all cochains. -/
instance intrinsicInHarmonicSpace_isZLattice (B : Matrix Row Col ℤ) :
    IsZLattice ℝ (intrinsicInHarmonicSpace B) := by
  constructor
  rw [intrinsic_eq_zspan_basis]
  exact ZSpan.span_top (harmonicBasis B)

/-- The original single-subtype intrinsic carrier has its inherited discrete topology. -/
instance intrinsic_discrete (B : Matrix Row Col ℤ) :
    DiscreteTopology (integralStructure B).harmonicOneLattice := by
  let inclusion : (integralStructure B).harmonicOneLattice → intrinsicInHarmonicSpace B :=
    fun h => ⟨⟨h.1, h.property.2⟩, h.property⟩
  have continuous : Continuous inclusion := by
    have base : Continuous (fun h : (integralStructure B).harmonicOneLattice => h.1) :=
      continuous_subtype_val
    exact (base.subtype_mk (fun h => h.property.2)).subtype_mk (fun h => h.property)
  apply DiscreteTopology.of_continuous_injective continuous
  intro h k same
  apply Subtype.ext
  exact congrArg (fun value : intrinsicInHarmonicSpace B => value.1.1) same

end HomotopicalEncryption.HCP.CoupledLattice
