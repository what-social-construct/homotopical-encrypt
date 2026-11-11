module

public import Sheaf.HCPAxisFamily

@[expose] public section

/-!
# A finite keyed cellular Hodge family

This file constructs a family of genuine finite cellular sheaves with nonzero
degree-zero and degree-one coboundaries. The two coboundaries occupy different
edge cells. A key selects the coexact coordinate in each two-dimensional edge
stalk. This is a structural family; no computational security claim is made.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Sheaf.HCPFiniteKeyFamily

open CellularSheaf
open scoped BigOperators RealInnerProductSpace

variable (n : ℕ)

/-- Each block has an exact edge and a two-dimensional Hodge edge. -/
abbrev EdgeCell := Fin n × Fin 2

/-- The incidence supports are disjoint, making the boundary square zero. -/
def complex : OrientedTwoComplex (Fin n) (EdgeCell n) (Fin n) where
  incidence01 v e := if e = (v, 0) then 1 else 0
  incidence12 e f := if e = (f, 1) then 1 else 0
  boundarySqZero v f := by
    apply Finset.sum_eq_zero
    rintro ⟨i, k⟩ _
    fin_cases k <;> simp

/-- All keys at a given dimension use this same public cochain coordinate type. -/
abbrev Index := TotalCoord (EdgeCell n) (fun _ => 2)

/-- One binary coordinate choice in every Hodge edge. -/
abbrev Key := Fin n → Fin 2

theorem key_card : Fintype.card (Key n) = 2 ^ n := by
  simp [Key]

theorem index_card : Fintype.card (Index n) = 4 * n := by
  simp [Index, EdgeCell, Fintype.card_sigma, Fintype.card_prod]
  omega

abbrev C1 := EuclideanSpace ℝ (Index n)

/-- A row that selects one of two coordinates. -/
def restriction (axis : Fin 2) : Coord 2 →ₗ[ℝ] Coord 1 :=
  HCPAxisFamily.restriction axis

/-- A keyed cellular sheaf with exact and coexact differentials. -/
abbrev sheaf (key : Fin n → Fin 2) : CellularSheaf (complex n) where
  vertexDim _ := 2
  edgeDim _ := 2
  faceDim _ := 1
  restrict01 v e := if e = (v, 0) then LinearMap.id else 0
  restrict12 e f := if e = (f, 1) then restriction (key f) else 0
  restrict02 _ _ := 0
  restrictionComp v e f h01 h12 := by
    exfalso
    have h0 : e.2 = 0 := by
      have h : e = (v, 0) := by
        simpa [OrientedTwoComplex.VertexEdgeIncident, complex] using h01
      exact congrArg Prod.snd h
    have h1 : e.2 = 1 := by
      have h : e = (f, 1) := by
        simpa [OrientedTwoComplex.EdgeFaceIncident, complex] using h12
      exact congrArg Prod.snd h
    exact Fin.zero_ne_one (h0.symm.trans h1)

/-- Standard integer-coordinate stalks make all keyed restrictions integral. -/
def integralStructure (key : Fin n → Fin 2) : IntegralStructure (sheaf n key) where
  vertexStalk _ := HCPAxisFamily.standardStalkLattice 2
  edgeStalk _ := HCPAxisFamily.standardStalkLattice 2
  faceStalk _ := HCPAxisFamily.standardStalkLattice 1
  restrict01_preserves v e := by
    rintro _ ⟨x, hx, rfl⟩
    change (if e = (v, 0) then (LinearMap.id : Coord 2 →ₗ[ℝ] Coord 2) else 0) x ∈
      (HCPAxisFamily.standardStalkLattice 2).carrier
    by_cases h : e = (v, 0)
    · simp only [h, ite_true]
      exact hx
    · simp only [h, ite_false]
      exact (HCPAxisFamily.standardStalkLattice 2).carrier.zero_mem
  restrict12_preserves e f := by
    by_cases h : e = (f, 1)
    · simpa [sheaf, h, restriction] using
        HCPAxisFamily.restriction_preserves (key f)
    · rintro _ ⟨x, hx, rfl⟩
      change (if e = (f, 1) then restriction (key f) else 0) x ∈
        (HCPAxisFamily.standardStalkLattice 1).carrier
      simp only [h, ite_false]
      exact (HCPAxisFamily.standardStalkLattice 1).carrier.zero_mem
  restrict02_preserves v f := by
    rintro _ ⟨x, hx, rfl⟩
    change (0 : Coord 1) ∈ (HCPAxisFamily.standardStalkLattice 1).carrier
    exact
      (HCPAxisFamily.standardStalkLattice 1).carrier.zero_mem

@[simp] theorem delta0_apply (key : Key n) (a : (sheaf n key).C0)
    (i : Fin n) (k j : Fin 2) :
    (sheaf n key).delta0 a ⟨(i, k), j⟩ =
      if k = 0 then a ⟨i, j⟩ else 0 := by
  change ((sheaf n key).delta0At (i, k) a) j = _
  simp only [CellularSheaf.delta0At, LinearMap.sum_apply,
    LinearMap.smul_apply, LinearMap.comp_apply]
  fin_cases k <;>
    simp [component, complex, sheaf, OrientedTwoComplex.incidence01Real];
    rfl

@[simp] theorem delta1_apply (key : Key n) (b : C1 n)
    (i : Fin n) :
    (sheaf n key).delta1 b ⟨i, 0⟩ = b ⟨(i, 1), key i⟩ := by
  change ((sheaf n key).delta1At i b) (0 : Fin 1) = _
  simp only [CellularSheaf.delta1At, LinearMap.sum_apply,
    LinearMap.smul_apply, LinearMap.comp_apply]
  simp [component, complex, sheaf, restriction,
    OrientedTwoComplex.incidence12Real]
  rfl

theorem delta0_adjoint_eq (key : Key n) (b : C1 n) :
    (sheaf n key).delta0.adjoint b =
      WithLp.toLp 2 (fun p => b ⟨(p.1, 0), p.2⟩) := by
  apply ext_inner_left ℝ
  intro a
  rw [LinearMap.adjoint_inner_right]
  simp [PiLp.inner_apply, Fintype.sum_sigma, Fintype.sum_prod_type,
    Fin.sum_univ_two,
    delta0_apply]

/-- A nonzero integral harmonic unit in any selected block. -/
def harmonicUnit (key : Key n) (i : Fin n) : C1 n :=
  EuclideanSpace.single ⟨(i, 1), HCPAxisFamily.other (key i)⟩ 1

theorem harmonicUnit_integral (key : Key n) (i : Fin n) :
    harmonicUnit n key i ∈ (integralStructure n key).integralOneCochains := by
  intro e
  apply (HCPAxisFamily.standardStalkLattice_contains_iff 2 _).mpr
  refine ⟨fun j => if (⟨e, j⟩ : Index n) =
    ⟨(i, 1), HCPAxisFamily.other (key i)⟩ then 1 else 0, ?_⟩
  intro j
  change harmonicUnit n key i ⟨e, j⟩ = _
  simp [harmonicUnit, PiLp.single_apply]

theorem harmonicUnit_harmonic (key : Key n) (i : Fin n) :
    (sheaf n key).IsHarmonicOneCochain (harmonicUnit n key i) := by
  change (sheaf n key).degreeOneLaplacian (harmonicUnit n key i) = 0
  apply ((sheaf n key).degreeOneLaplacian_apply_eq_zero_iff _).mpr
  constructor
  · rw [delta0_adjoint_eq]
    apply PiLp.ext
    rintro ⟨r, j⟩
    simp [harmonicUnit]
  · apply PiLp.ext
    rintro ⟨r, j⟩
    have hj : j = 0 := Subsingleton.elim _ _
    subst j
    simp [harmonicUnit, PiLp.single_apply]
    intro hr
    subst r
    exact (HCPAxisFamily.other_ne (key i)).symm

/-- The unit message is a point in the intrinsic integral harmonic lattice. -/
def message (key : Key n) (i : Fin n) :
    (integralStructure n key).harmonicOneLattice :=
  ⟨harmonicUnit n key i, harmonicUnit_integral n key i,
    harmonicUnit_harmonic n key i⟩

/-- Both degree-zero and degree-two openings have a unit integral coefficient. -/
def opening (key : Key n) (i : Fin n) : HodgeNoise (sheaf n key) where
  exactOpening := EuclideanSpace.single ⟨i, (0 : Fin 2)⟩ 1
  coexactOpening := EuclideanSpace.single ⟨i, (0 : Fin 1)⟩ 1

/-- Every exact opening coordinate is an integer of magnitude at most one. -/
theorem opening_exact_bounded_integer (key : Key n) (i : Fin n)
    (p : TotalCoord (Fin n) (fun _ => 2)) :
    ∃ z : ℤ, z.natAbs ≤ 1 ∧ (opening n key i).exactOpening p = (z : ℝ) := by
  by_cases h : p = ⟨i, (0 : Fin 2)⟩
  · refine ⟨1, by norm_num, ?_⟩
    simp [opening, PiLp.single_apply, h]
  · refine ⟨0, by norm_num, ?_⟩
    simp [opening, h]

/-- Every coexact opening coordinate is an integer of magnitude at most one. -/
theorem opening_coexact_bounded_integer (key : Key n) (i : Fin n)
    (p : TotalCoord (Fin n) (fun _ => 1)) :
    ∃ z : ℤ, z.natAbs ≤ 1 ∧ (opening n key i).coexactOpening p = (z : ℝ) := by
  by_cases h : p = ⟨i, (0 : Fin 1)⟩
  · refine ⟨1, by norm_num, ?_⟩
    simp [opening, PiLp.single_apply, h]
  · refine ⟨0, by norm_num, ?_⟩
    simp [opening, h]

/-- A genuine encrypted cochain with nonzero exact and coexact opening data. -/
def sample (key : Key n) (i : Fin n) :
    HodgeEncryptedCochain (integralStructure n key) where
  message := message n key i
  opening := opening n key i

/-- Actual harmonic projection recovers the encrypted integral cochain. -/
theorem sample_projection (key : Key n) (i : Fin n) :
    (sheaf n key).harmonicOneProjection (sample n key i).observed =
      (sample n key i).message.1 :=
  (sample n key i).harmonicOneProjection_observed

/-- Every block has a nonzero degree-zero coboundary. -/
theorem delta0_ne_zero (key : Key n) (i : Fin n) :
    (sheaf n key).delta0 ≠ 0 := by
  intro h
  have hc := congrArg
    (fun f : (sheaf n key).C0 →ₗ[ℝ] (sheaf n key).C1 =>
      f (EuclideanSpace.single ⟨i, (0 : Fin 2)⟩ 1)
        ⟨(i, 0), (0 : Fin 2)⟩) h
  norm_num [delta0_apply] at hc

/-- Every block has a nonzero degree-one coboundary. -/
theorem delta1_ne_zero (key : Key n) (i : Fin n) :
    (sheaf n key).delta1 ≠ 0 := by
  intro h
  have hc := congrArg
    (fun f : (sheaf n key).C1 →ₗ[ℝ] (sheaf n key).C2 =>
      f (EuclideanSpace.single ⟨(i, 1), key i⟩ 1)
        ⟨i, (0 : Fin 1)⟩) h
  norm_num [delta1_apply] at hc

theorem delta0_ne_zero_of_pos (key : Key n) (hn : 0 < n) :
    (sheaf n key).delta0 ≠ 0 :=
  delta0_ne_zero n key ⟨0, hn⟩

theorem delta1_ne_zero_of_pos (key : Key n) (hn : 0 < n) :
    (sheaf n key).delta1 ≠ 0 :=
  delta1_ne_zero n key ⟨0, hn⟩

theorem harmonicUnit_ne_zero (key : Key n) (i : Fin n) :
    harmonicUnit n key i ≠ 0 := by
  intro h
  have hc := congrArg
    (fun b : C1 n => b ⟨(i, 1), HCPAxisFamily.other (key i)⟩) h
  norm_num [harmonicUnit] at hc

end HomotopicalEncryption.Sheaf.HCPFiniteKeyFamily
