module

public import HCP.CoupledSemantics
public import HCP.CoupledTransport

@[expose] public section

/-!
# The coupled geometry, coordinate assembly and recovery diagram

The integral coupling matrix determines the existing coupled cellular sheaf
in its fixed scalar-stalk, standard-integral and Euclidean profile. This file
uses those original objects; it introduces no second private geometry.

The native coordinate map assembles a harmonic graph vector with actual exact
and coexact Hodge noise for every real coordinate input. Consequently the
tailored native transport intertwines harmonic recovery with the semantic
cochain shear on recovered messages. The two maps agree on harmonic vectors
and on the intrinsic harmonic lattice. They are different maps on a general
observed cochain.

This projection square does not require the native transport to be isometric:
it follows from its explicit preservation of the harmonic/noise splitting.
It asserts neither Hodge-adjoint nor Laplacian covariance for the semantic
shear, nor an isometry, general sheaf descent, hiding or cryptographic security.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.HCP.CoupledGeometry

open Sheaf CellularSheaf HCPCoupledFamily
open CoupledTransport

variable {Row Col : Type} [Fintype Row] [Fintype Col]
  [DecidableEq Row] [DecidableEq Col]

/-- The actual Hodge opening read from the real coordinate input. -/
def coordinateNoise (B : Matrix Row Col ℤ) (q : C1 Row Col) : HodgeNoise (sheaf B) where
  exactOpening := WithLp.toLp 2 fun _ => exactCoord q
  coexactOpening := WithLp.toLp 2 fun p => parity q p.1

/-- Coordinate assembly is the original harmonic message plus its Hodge noise. -/
theorem nativeEquiv_eq_graphVector_add_noise (B : Matrix Row Col ℤ) (q : C1 Row Col) :
    nativeEquiv B q = graphVector B (information q) + (coordinateNoise B q).value := by
  apply PiLp.ext
  rintro ⟨edge, component⟩
  have component_zero : component = 0 := Subsingleton.elim _ _
  subst component
  cases edge with
  | none =>
    change exactCoord (nativeEquiv B q) =
      exactCoord (graphVector B (information q)) +
        (exactCoord ((sheaf B).delta0 (coordinateNoise B q).exactOpening) +
          exactCoord ((sheaf B).delta1.adjoint (coordinateNoise B q).coexactOpening))
    rw [nativeEquiv_apply, nativeLinear_exactCoord, graphVector_exactCoord,
      HCPCoupledEncoding.delta1_adjoint_exactCoord]
    simp [exactCoord, delta0_apply, coordinateNoise]
  | some edge =>
    cases edge with
    | inl col =>
      change information (nativeEquiv B q) col =
        information (graphVector B (information q)) col +
          (information ((sheaf B).delta0 (coordinateNoise B q).exactOpening) col +
            information ((sheaf B).delta1.adjoint (coordinateNoise B q).coexactOpening) col)
      rw [nativeEquiv_apply, nativeLinear_information, graphVector_information,
        HCPCoupledEncoding.delta1_adjoint_information]
      simp [information, delta0_apply, coordinateNoise, sub_eq_add_neg]
    | inr row =>
      change parity (nativeEquiv B q) row =
        parity (graphVector B (information q)) row +
          (parity ((sheaf B).delta0 (coordinateNoise B q).exactOpening) row +
            parity ((sheaf B).delta1.adjoint (coordinateNoise B q).coexactOpening) row)
      rw [nativeEquiv_apply, nativeLinear_parity, graphVector_parity,
        HCPCoupledEncoding.delta1_adjoint_parity]
      simp [parity, delta0_apply, coordinateNoise]

/-- The recovery triangle holds for all real coordinates, not only integer samples. -/
theorem harmonicOneProjection_nativeEquiv (B : Matrix Row Col ℤ) (q : C1 Row Col) :
    (sheaf B).harmonicOneProjection (nativeEquiv B q) = graphVector B (information q) := by
  rw [nativeEquiv_eq_graphVector_add_noise, map_add]
  have harmonic : graphVector B (information q) ∈ (sheaf B).harmonicOneSubspace :=
    LinearMap.mem_ker.mpr (graphVector_harmonic B _)
  change (sheaf B).harmonicOneSubspace.starProjection (graphVector B (information q)) +
    (sheaf B).harmonicOneSubspace.starProjection (coordinateNoise B q).value = _
  rw [(sheaf B).harmonicOneSubspace.starProjection_eq_self_iff.mpr harmonic,
    (sheaf B).harmonicOneSubspace.starProjection_apply_eq_zero_iff.mpr
      (coordinateNoise B q).value_mem_harmonic_orthogonal,
    add_zero]

/-- Recovering an arbitrary cochain reads its decoded native message coordinates. -/
theorem harmonicOneProjection_eq_graphVector_inverse (B : Matrix Row Col ℤ)
    (b : C1 Row Col) :
    (sheaf B).harmonicOneProjection b =
      graphVector B (information ((nativeEquiv B).symm b)) := by
  simpa using harmonicOneProjection_nativeEquiv B ((nativeEquiv B).symm b)

omit [DecidableEq Row] [DecidableEq Col] in
/-- The native assembly of a zero-noise real coordinate vector is the graph message. -/
theorem nativeEquiv_harmonic_coordinates (B : Matrix Row Col ℤ) (z : Col → ℝ) :
    nativeEquiv B (coordinates 0 z 0) = graphVector B z := by
  apply PiLp.ext
  rintro ⟨edge, component⟩
  cases edge with
  | none => rfl
  | some edge =>
    cases edge with
    | inl col =>
      simp [nativeEquiv_apply, nativeLinear, coordinates, information, parity, graphVector]
    | inr row =>
      simp [nativeEquiv_apply, nativeLinear, coordinates, information, parity, graphVector]

omit [DecidableEq Row] [DecidableEq Col] in
/-- On harmonic messages, native transport and the semantic shear take the same route. -/
theorem transport_graphVector (B C : Matrix Row Col ℤ) (z : Col → ℝ) :
    transport B C (graphVector B z) = graphVector C z := by
  rw [← nativeEquiv_harmonic_coordinates B, transport_nativeEquiv,
    nativeEquiv_harmonic_coordinates]

/-- The two transports agree on every harmonic input, despite differing on noise. -/
theorem transport_eq_shear_of_harmonic (B C : Matrix Row Col ℤ) (h : C1 Row Col)
    (harmonic : (sheaf B).IsHarmonicOneCochain h) :
    transport B C h = CoupledSemantics.shearEquiv B C h := by
  rw [eq_graphVector_of_harmonic B harmonic, transport_graphVector,
    CoupledSemantics.shear_graphVector]

/-- The central recovery square uses native transport on observations and
the semantic shear on their recovered harmonic vectors. -/
theorem harmonicOneProjection_transport (B C : Matrix Row Col ℤ) (b : C1 Row Col) :
    (sheaf C).harmonicOneProjection (transport B C b) =
      CoupledSemantics.shearEquiv B C ((sheaf B).harmonicOneProjection b) := by
  obtain ⟨q, rfl⟩ := (nativeEquiv B).surjective b
  rw [transport_nativeEquiv, harmonicOneProjection_nativeEquiv,
    harmonicOneProjection_nativeEquiv, CoupledSemantics.shear_graphVector]

/-- The bottom recovery triangle reads the same real message coordinates. -/
theorem information_harmonicOneProjection (B : Matrix Row Col ℤ) (b : C1 Row Col) :
    information ((sheaf B).harmonicOneProjection b) =
      information ((nativeEquiv B).symm b) := by
  rw [harmonicOneProjection_eq_graphVector_inverse]
  rfl

omit [DecidableEq Row] [DecidableEq Col] in
/-- Native transport preserves all decoded real coordinates, including noise. -/
theorem nativeInverse_transport (B C : Matrix Row Col ℤ) (b : C1 Row Col) :
    (nativeEquiv C).symm (transport B C b) = (nativeEquiv B).symm b := by
  simp [transport]

/-- Thus recovery of real coefficients is invariant under native transport. -/
theorem information_projection_transport (B C : Matrix Row Col ℤ) (b : C1 Row Col) :
    information ((sheaf C).harmonicOneProjection (transport B C b)) =
      information ((sheaf B).harmonicOneProjection b) := by
  rw [information_harmonicOneProjection, nativeInverse_transport,
    information_harmonicOneProjection]

/-- The intrinsic lattice equivalence is the restriction of native transport
on the same underlying degree-one harmonic cochains. -/
theorem transport_harmonicLatticeEquiv (B C : Matrix Row Col ℤ)
    (h : (integralStructure B).harmonicOneLattice) :
    transport B C h.1 = (CoupledSemantics.harmonicLatticeEquiv B C h).1 := by
  exact transport_eq_shear_of_harmonic B C h.1 (LinearMap.mem_ker.mp h.property.2)

/-- The original degree-one differential determines every integral coupling
entry in this fixed profile, so no independent coupling is silently chosen. -/
theorem coupling_eq_of_delta1_eq (B C : Matrix Row Col ℤ)
    (same : (sheaf B).delta1 = (sheaf C).delta1) : B = C := by
  ext row col
  have entry := congrArg
    (fun differential : (sheaf B).C1 →ₗ[ℝ] (sheaf B).C2 =>
      differential (EuclideanSpace.single ⟨some (.inl col), 0⟩ 1) ⟨row, 0⟩) same
  have negativeEntry : -(B row col : ℝ) = -(C row col : ℝ) := by
    simpa [delta1_apply, information, parity] using entry
  exact_mod_cast (neg_inj.mp negativeEntry)

/-- The exact coordinate of the true Hodge Laplacian is the original exact coordinate. -/
theorem laplacian_exactCoord (B : Matrix Row Col ℤ) (b : C1 Row Col) :
    exactCoord ((sheaf B).degreeOneLaplacian b) = exactCoord b := by
  change exactCoord ((sheaf B).delta0 ((sheaf B).delta0.adjoint b)) +
    exactCoord ((sheaf B).delta1.adjoint ((sheaf B).delta1 b)) = _
  rw [HCPCoupledEncoding.delta1_adjoint_exactCoord, delta0_adjoint_eq]
  simp [exactCoord, delta0_apply]

/-- Information coordinates of the true operator are `Bᵀ(Bx-y)`. -/
theorem laplacian_information (B : Matrix Row Col ℤ) (b : C1 Row Col) (col : Col) :
    information ((sheaf B).degreeOneLaplacian b) col =
      -∑ row, (B row col : ℝ) *
        (parity b row - ∑ other, (B row other : ℝ) * information b other) := by
  change information ((sheaf B).delta0 ((sheaf B).delta0.adjoint b)) col +
    information ((sheaf B).delta1.adjoint ((sheaf B).delta1 b)) col = _
  rw [HCPCoupledEncoding.delta1_adjoint_information]
  have exact_zero : information ((sheaf B).delta0 ((sheaf B).delta0.adjoint b)) col = 0 := by
    simp [information, delta0_apply]
  rw [exact_zero, zero_add]
  simp_rw [delta1_apply]

/-- Parity coordinates of the true operator are the original face syndrome `y-Bx`. -/
theorem laplacian_parity (B : Matrix Row Col ℤ) (b : C1 Row Col) (row : Row) :
    parity ((sheaf B).degreeOneLaplacian b) row =
      parity b row - ∑ col, (B row col : ℝ) * information b col := by
  change parity ((sheaf B).delta0 ((sheaf B).delta0.adjoint b)) row +
    parity ((sheaf B).delta1.adjoint ((sheaf B).delta1 b)) row = _
  rw [HCPCoupledEncoding.delta1_adjoint_parity]
  have exact_zero : parity ((sheaf B).delta0 ((sheaf B).delta0.adjoint b)) row = 0 := by
    simp [parity, delta0_apply]
  rw [exact_zero, zero_add, delta1_apply]

/-- The complete block action is derived from `δ₀δ₀* + δ₁*δ₁`; it is not
the kernel-normalized projector or a separately supplied operator. -/
theorem degreeOneLaplacian_coordinates (B : Matrix Row Col ℤ) (b : C1 Row Col) :
    (sheaf B).degreeOneLaplacian b =
      coordinates (exactCoord b)
        (fun col => -∑ row, (B row col : ℝ) *
          (parity b row - ∑ other, (B row other : ℝ) * information b other))
        (fun row => parity b row - ∑ col, (B row col : ℝ) * information b col) := by
  rw [← coordinates_eta ((sheaf B).degreeOneLaplacian b),
    laplacian_exactCoord]
  congr 1
  · funext col
    exact laplacian_information B b col
  · funext row
    exact laplacian_parity B b row

/-- The true Hodge operator also uniquely determines the integral coupling
matrix in this fixed coordinate and metric profile. -/
theorem coupling_eq_of_laplacian_eq (B C : Matrix Row Col ℤ)
    (same : (sheaf B).degreeOneLaplacian = (sheaf C).degreeOneLaplacian) : B = C := by
  ext row col
  have entry := congrArg
    (fun operator : (sheaf B).C1 →ₗ[ℝ] (sheaf B).C1 =>
      information (operator (EuclideanSpace.single ⟨some (.inr row), 0⟩ 1)) col) same
  simp only [laplacian_information] at entry
  have negativeEntry : -(B row col : ℝ) = -(C row col : ℝ) := by
    simpa [information, parity] using entry
  exact_mod_cast (neg_inj.mp negativeEntry)

/-- The original HCP matrix representation retains the same operator uniqueness. -/
theorem coupling_eq_of_laplacianMatrix_eq (B C : Matrix Row Col ℤ)
    (same : laplacianMatrix B = laplacianMatrix C) : B = C := by
  apply coupling_eq_of_laplacian_eq B C
  apply LinearMap.ext
  intro b
  apply PiLp.ext
  intro index
  have action := congrArg (fun matrix : Matrix (Index Row Col) (Index Row Col) ℝ =>
    Matrix.mulVec matrix b index) same
  simpa only [laplacianMatrix_mulVec] using action

/-- The semantic shear cannot replace native transport in the recovery
square. The scalar source has `B=0`, target has `C=1`, and the input is a
pure parity cochain. Its source harmonic projection is zero, while its target
projection has information coordinate `1/2`. -/
theorem shear_projection_counterexample :
    let B : Matrix Unit Unit ℤ := 0
    let C : Matrix Unit Unit ℤ := fun _ _ => 1
    let b : C1 Unit Unit := coordinates 0 0 (fun _ => 1)
    (sheaf C).harmonicOneProjection (CoupledSemantics.shearEquiv B C b) ≠
      CoupledSemantics.shearEquiv B C ((sheaf B).harmonicOneProjection b) := by
  dsimp only
  let C : Matrix Unit Unit ℤ := fun _ _ => 1
  let b : C1 Unit Unit := coordinates 0 0 (fun _ => 1)
  have shear_fixed : CoupledSemantics.shearEquiv (0 : Matrix Unit Unit ℤ) C b = b := by
    apply PiLp.ext
    rintro ⟨edge, component⟩
    cases edge with
    | none => rfl
    | some edge =>
      cases edge with
      | inl col => rfl
      | inr row => simp [CoupledSemantics.shearEquiv, CoupledSemantics.shearLinear,
          CoupledSemantics.shearFun, b, coordinates, information, parity]
  have source_projection : (sheaf (0 : Matrix Unit Unit ℤ)).harmonicOneProjection b = 0 := by
    have projection := harmonicOneProjection_nativeEquiv (0 : Matrix Unit Unit ℤ) b
    rw [nativeEquiv_zero] at projection
    rw [projection]
    apply PiLp.ext
    rintro ⟨edge, component⟩
    cases edge with
    | none => rfl
    | some edge =>
      cases edge <;> simp [b, coordinates, information, graphVector]
  have target_coordinates : nativeEquiv C (coordinates 0 (fun _ => 1 / 2) (fun _ => 1 / 2)) = b := by
    rw [nativeEquiv_apply]
    apply PiLp.ext
    rintro ⟨edge, component⟩
    cases edge with
    | none => rfl
    | some edge =>
      cases edge with
      | inl col =>
        simp [nativeLinear, coordinates, information, parity, C, b]
      | inr row =>
        norm_num [nativeLinear, coordinates, information, parity, C, b]
  have target_projection : (sheaf C).harmonicOneProjection b =
      graphVector C (fun _ => 1 / 2) := by
    rw [← target_coordinates, harmonicOneProjection_nativeEquiv]
    rfl
  change (sheaf C).harmonicOneProjection (CoupledSemantics.shearEquiv 0 C b) ≠
    CoupledSemantics.shearEquiv 0 C ((sheaf 0).harmonicOneProjection b)
  rw [shear_fixed, source_projection, map_zero, target_projection]
  intro same
  have impossible := congrArg (fun q : C1 Unit Unit => information q ()) same
  norm_num [information, graphVector] at impossible

end HomotopicalEncryption.HCP.CoupledGeometry
