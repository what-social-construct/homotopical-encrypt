module

public import Sheaf.HCPAxisFamily

@[expose] public section

/-!
# Cellular Hodge families with shared integral constraints

An integer matrix couples the information edge cells through shared face
equations `y = B x`. A separate edge carries a nonzero exact differential.
The harmonic lattice is the integral graph of the matrix. No security or
computational hardness claim is made here.
-/

set_option autoImplicit false

open scoped BigOperators RealInnerProductSpace

noncomputable section

namespace HomotopicalEncryption.Sheaf.HCPCoupledFamily

open CellularSheaf

variable {Row Col : Type*} [Fintype Row] [Fintype Col]
  [DecidableEq Row] [DecidableEq Col]

/-- One exact edge, information edges, and one parity edge per face. -/
abbrev Edge (Row Col : Type*) := Option (Sum Col Row)

/-- Information edges meet every face; each parity edge meets its own face. -/
def complex : OrientedTwoComplex Unit (Edge Row Col) Row where
  incidence01 _ e := if e = none then 1 else 0
  incidence12 e f := match e with
    | none => 0
    | some (.inl _) => 1
    | some (.inr r) => if r = f then 1 else 0
  boundarySqZero _ _ := by
    apply Finset.sum_eq_zero
    intro e _
    cases e with
    | none => simp
    | some e => cases e <;> simp

/-- The common scalar edge-coordinate carrier is independent of the matrix. -/
abbrev Index (Row Col : Type*) := TotalCoord (Edge Row Col) (fun _ => 1)

abbrev C1 (Row Col : Type*) [Fintype Row] [Fintype Col] :=
  EuclideanSpace ℝ (Index Row Col)

/-- Every matrix entry is an actual face-to-coface linear stalk coefficient. -/
abbrev sheaf (B : Matrix Row Col ℤ) : CellularSheaf (complex (Row := Row) (Col := Col)) where
  vertexDim _ := 1
  edgeDim _ := 1
  faceDim _ := 1
  restrict01 _ e := if e = none then LinearMap.id else 0
  restrict12 e f := match e with
    | none => 0
    | some (.inl c) => (-(B f c : ℝ)) • LinearMap.id
    | some (.inr _) => LinearMap.id
  restrict02 _ _ := 0
  restrictionComp _ e _ h01 h12 := by
    have he : e = none := by
      simpa [OrientedTwoComplex.VertexEdgeIncident, complex] using h01
    subst e
    simp [OrientedTwoComplex.EdgeFaceIncident, complex] at h12

private theorem integer_smul_preserves (z : ℤ) :
    (HCPAxisFamily.standardStalkLattice 1).Preserves
      (HCPAxisFamily.standardStalkLattice 1)
      ((z : ℝ) • (LinearMap.id : Coord 1 →ₗ[ℝ] Coord 1)) := by
  rintro _ ⟨x, hx, rfl⟩
  change (z : ℝ) • x ∈ _
  rw [Int.cast_smul_eq_zsmul]
  exact (HCPAxisFamily.standardStalkLattice 1).carrier.zsmul_mem hx z

/-- Standard integer stalks are preserved by every integer matrix restriction. -/
def integralStructure (B : Matrix Row Col ℤ) : IntegralStructure (sheaf B) where
  vertexStalk _ := HCPAxisFamily.standardStalkLattice 1
  edgeStalk _ := HCPAxisFamily.standardStalkLattice 1
  faceStalk _ := HCPAxisFamily.standardStalkLattice 1
  restrict01_preserves _ e := by
    by_cases he : e = none
    · simpa [sheaf, he] using integer_smul_preserves (1 : ℤ)
    · simpa [sheaf, he] using integer_smul_preserves (0 : ℤ)
  restrict12_preserves e f := by
    cases e with
    | none => simpa [sheaf] using integer_smul_preserves (0 : ℤ)
    | some e =>
      cases e with
      | inl c => simpa [sheaf] using integer_smul_preserves (-B f c)
      | inr r => simpa [sheaf] using integer_smul_preserves (1 : ℤ)
  restrict02_preserves _ _ := by
    simpa [sheaf] using integer_smul_preserves (0 : ℤ)

/-- Read the coordinate on the separate exact edge. -/
def exactCoord (b : C1 Row Col) : ℝ := b ⟨none, 0⟩

/-- Read the scalar information edge at a column. -/
def information (b : C1 Row Col) (c : Col) : ℝ := b ⟨some (.inl c), 0⟩

/-- Read the scalar parity edge at a row. -/
def parity (b : C1 Row Col) (r : Row) : ℝ := b ⟨some (.inr r), 0⟩

omit [DecidableEq Col] in
@[simp] theorem delta0_apply (B : Matrix Row Col ℤ) (a : (sheaf B).C0)
    (e : Edge Row Col) (j : Fin 1) :
    (sheaf B).delta0 a ⟨e, j⟩ = if e = none then a ⟨(), j⟩ else 0 := by
  change ((sheaf B).delta0At e a) j = _
  simp only [delta0At, LinearMap.sum_apply, LinearMap.smul_apply,
    LinearMap.comp_apply]
  cases e <;> simp [component, complex, sheaf, OrientedTwoComplex.incidence01Real]
  rfl

omit [DecidableEq Col] in
@[simp] theorem delta1_apply (B : Matrix Row Col ℤ) (b : C1 Row Col) (r : Row) :
    (sheaf B).delta1 b ⟨r, 0⟩ =
      parity b r - ∑ c, (B r c : ℝ) * information b c := by
  change ((sheaf B).delta1At r b) (0 : Fin 1) = _
  simp only [delta1At, LinearMap.sum_apply, LinearMap.smul_apply,
    LinearMap.comp_apply]
  simp [component,
    complex, sheaf, OrientedTwoComplex.incidence12Real,
    Fintype.sum_option, Fintype.sum_sum_type, parity, information,
    Finset.sum_neg_distrib, sub_eq_add_neg]
  change -(∑ c, (B r c : ℝ) * b ⟨some (.inl c), 0⟩) + b ⟨some (.inr r), 0⟩ =
    b ⟨some (.inr r), 0⟩ + -(∑ c, (B r c : ℝ) * b ⟨some (.inl c), 0⟩)
  exact add_comm _ _

theorem delta0_adjoint_eq (B : Matrix Row Col ℤ) (b : C1 Row Col) :
    (sheaf B).delta0.adjoint b =
      WithLp.toLp 2 (fun _ => exactCoord b) := by
  apply ext_inner_left ℝ
  intro a
  rw [LinearMap.adjoint_inner_right]
  simp [PiLp.inner_apply, Fintype.sum_sigma, delta0_apply, exactCoord]

/-- Harmonicity is exactly the shared graph constraint and zero exact coordinate. -/
theorem harmonic_iff (B : Matrix Row Col ℤ) (b : C1 Row Col) :
    (sheaf B).IsHarmonicOneCochain b ↔
      exactCoord b = 0 ∧
        ∀ r, parity b r = ∑ c, (B r c : ℝ) * information b c := by
  rw [(sheaf B).isHarmonicOneCochain_iff_coclosed_and_cocycle]
  simp only [IsCoclosedOneCochain, IsOneCocycle, delta0_adjoint_eq]
  constructor
  · rintro ⟨h0, h1⟩
    constructor
    · exact congrArg (fun v : (sheaf B).C0 => v ⟨(), 0⟩) h0
    · intro r
      have h := congrArg (fun v : (sheaf B).C2 => v ⟨r, 0⟩) h1
      simpa only [delta1_apply, PiLp.zero_apply, sub_eq_zero] using h
  · rintro ⟨h0, h1⟩
    constructor
    · apply PiLp.ext
      intro p
      exact h0
    · apply PiLp.ext
      rintro ⟨r, j⟩
      have hj : j = 0 := Subsingleton.elim _ _
      subst j
      simp [delta1_apply, h1 r]

/-- The harmonic graph vector with the prescribed information coordinates. -/
def graphVector (B : Matrix Row Col ℤ) (x : Col → ℝ) : C1 Row Col :=
  WithLp.toLp 2 fun p => match p.1 with
    | none => 0
    | some (.inl c) => x c
    | some (.inr r) => ∑ c, (B r c : ℝ) * x c

omit [DecidableEq Row] [DecidableEq Col] in
@[simp] theorem graphVector_exactCoord (B : Matrix Row Col ℤ) (x : Col → ℝ) :
    exactCoord (graphVector B x) = 0 := rfl

omit [DecidableEq Row] [DecidableEq Col] in
@[simp] theorem graphVector_information (B : Matrix Row Col ℤ) (x : Col → ℝ) (c : Col) :
    information (graphVector B x) c = x c := rfl

omit [DecidableEq Row] [DecidableEq Col] in
@[simp] theorem graphVector_parity (B : Matrix Row Col ℤ) (x : Col → ℝ) (r : Row) :
    parity (graphVector B x) r = ∑ c, (B r c : ℝ) * x c := rfl

theorem graphVector_harmonic (B : Matrix Row Col ℤ) (x : Col → ℝ) :
    (sheaf B).IsHarmonicOneCochain (graphVector B x) :=
  (harmonic_iff B _).mpr ⟨rfl, fun _ => rfl⟩

/-- Every harmonic vector has the unique graph representation read from its edges. -/
theorem eq_graphVector_of_harmonic (B : Matrix Row Col ℤ) {b : C1 Row Col}
    (hb : (sheaf B).IsHarmonicOneCochain b) :
    b = graphVector B (information b) := by
  obtain ⟨h0, h1⟩ := (harmonic_iff B b).mp hb
  apply PiLp.ext
  rintro ⟨e, j⟩
  have hj : j = 0 := Subsingleton.elim _ _
  subst j
  cases e with
  | none => exact h0
  | some e =>
    cases e with
    | inl c => rfl
    | inr r => exact h1 r

omit [DecidableEq Row] [DecidableEq Col] in
theorem graphVector_injective (B : Matrix Row Col ℤ) :
    Function.Injective (graphVector B) := by
  intro x y h
  funext c
  exact congrArg (fun b => information b c) h

omit [DecidableEq Col] in
/-- Integer information values give integral values on every edge stalk. -/
theorem graphVector_integral (B : Matrix Row Col ℤ) (z : Col → ℤ) :
    graphVector B (fun c => (z c : ℝ)) ∈
      (integralStructure B).integralOneCochains := by
  intro e
  apply (HCPAxisFamily.standardStalkLattice_contains_iff 1 _).mpr
  refine ⟨fun _ => match e with
    | none => 0
    | some (.inl c) => z c
    | some (.inr r) => ∑ c, B r c * z c, ?_⟩
  intro j
  cases e with
  | none =>
    change (0 : ℝ) = ((0 : ℤ) : ℝ)
    simp only [Int.cast_zero]
  | some e =>
    cases e with
    | inl c => rfl
    | inr r =>
      change (∑ c, (B r c : ℝ) * (z c : ℝ)) = ((∑ c, B r c * z c : ℤ) : ℝ)
      simp only [Int.cast_sum, Int.cast_mul]

/-- The intrinsic harmonic lattice is the full integer graph, with no index gap. -/
theorem mem_harmonicOneLattice_iff (B : Matrix Row Col ℤ) (b : C1 Row Col) :
    b ∈ (integralStructure B).harmonicOneLattice ↔
      ∃ z : Col → ℤ, b = graphVector B (fun c => (z c : ℝ)) := by
  constructor
  · intro hb
    have hinfo : ∀ c, ∃ z : ℤ, information b c = (z : ℝ) := by
      intro c
      obtain ⟨z, hz⟩ :=
        (HCPAxisFamily.standardStalkLattice_contains_iff 1
          (component (sheaf B).edgeDim (some (.inl c)) b)).mp
          (hb.1 (some (.inl c)))
      exact ⟨z 0, hz 0⟩
    choose z hz using hinfo
    refine ⟨z, ?_⟩
    have hgraph := eq_graphVector_of_harmonic B (LinearMap.mem_ker.mp hb.2)
    rw [hgraph]
    congr 1
    funext c
    exact hz c
  · rintro ⟨z, rfl⟩
    exact ⟨graphVector_integral B z,
      LinearMap.mem_ker.mpr (graphVector_harmonic B _)⟩

omit [DecidableEq Col] in
/-- The separate exact edge ensures a nonzero degree-zero coboundary. -/
theorem delta0_ne_zero (B : Matrix Row Col ℤ) : (sheaf B).delta0 ≠ 0 := by
  intro h
  have he := congrArg
    (fun L : (sheaf B).C0 →ₗ[ℝ] (sheaf B).C1 =>
      L (WithLp.toLp 2 fun _ => 1) ⟨none, 0⟩) h
  simp [delta0_apply] at he

/-- Every parity edge makes its corresponding face equation nonzero. -/
theorem delta1_ne_zero (B : Matrix Row Col ℤ) (r : Row) :
    (sheaf B).delta1 ≠ 0 := by
  intro h
  have he := congrArg
    (fun L : (sheaf B).C1 →ₗ[ℝ] (sheaf B).C2 =>
      L (EuclideanSpace.single ⟨some (.inr r), 0⟩ 1) ⟨r, 0⟩) h
  simp [delta1_apply, parity, information] at he

/-- The actual cellular Hodge operator in the shared edge-coordinate basis. -/
def laplacianMatrix (B : Matrix Row Col ℤ) : Matrix (Index Row Col) (Index Row Col) ℝ :=
  LinearMap.toMatrix (EuclideanSpace.basisFun (Index Row Col) ℝ).toBasis
    (EuclideanSpace.basisFun (Index Row Col) ℝ).toBasis (sheaf B).degreeOneLaplacian

/-- Coordinate action of the matrix is the original cellular Hodge action. -/
theorem laplacianMatrix_mulVec (B : Matrix Row Col ℤ) (b : Index Row Col → ℝ) :
    Matrix.mulVec (laplacianMatrix B) b =
      ⇑((sheaf B).degreeOneLaplacian (WithLp.toLp 2 b)) := by
  have hrepr (x : C1 Row Col) :
      ⇑((EuclideanSpace.basisFun (Index Row Col) ℝ).toBasis.repr x) = ⇑x := by
    funext i
    simp
  simpa only [laplacianMatrix, hrepr, WithLp.ofLp_toLp]
    using LinearMap.toMatrix_mulVec_repr
      (EuclideanSpace.basisFun (Index Row Col) ℝ).toBasis
      (EuclideanSpace.basisFun (Index Row Col) ℝ).toBasis
      (sheaf B).degreeOneLaplacian (WithLp.toLp 2 b)

end HomotopicalEncryption.Sheaf.HCPCoupledFamily
