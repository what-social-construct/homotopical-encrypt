module

public import Sheaf.HCPCoupledFamily
public import Sheaf.HCPCoupledEncoding
public import Helfer.CochainModel
public import Axioms.HomotopyClass
public import HCP

@[expose] public section

/-!
# Typed homotopy equivalence of the coupled cellular family

The shear `(a,x,y) ↦ (a,x,y + (C-B)x)` intertwines the actual two
cellular coboundaries for the matrix presentations `B` and `C`. It gives a
strict cochain isomorphism, hence a typed Helfer equivalence and equality of
the declared homological closed theories.

This shear mixes edge cells and is generally not an isometry. It is not a
stalkwise cellular morphism or a Hodge rotation; no transport law for adjoints,
orthogonal projections or encrypted observations is asserted.
-/

set_option autoImplicit false

open scoped BigOperators

noncomputable section

namespace HomotopicalEncryption.HCP.CoupledSemantics

open CategoryTheory
open Sheaf CellularSheaf HCPCoupledFamily
open scoped CochainComplex.Plus.modelCategoryQuillen

variable {Row Col : Type} [Fintype Row] [Fintype Col]
  [DecidableEq Row] [DecidableEq Col]

/-- The actual cochain shear between two shared-constraint matrices. -/
def shearFun (B C : Matrix Row Col ℤ) (b : C1 Row Col) : C1 Row Col :=
  WithLp.toLp 2 fun p => match p.1 with
    | none => exactCoord b
    | some (.inl c) => information b c
    | some (.inr r) =>
        parity b r + ∑ c, ((C r c : ℝ) - (B r c : ℝ)) * information b c

omit [DecidableEq Row] [DecidableEq Col] in
@[simp] theorem shearFun_exactCoord (B C : Matrix Row Col ℤ) (b : C1 Row Col) :
    exactCoord (shearFun B C b) = exactCoord b := rfl

omit [DecidableEq Row] [DecidableEq Col] in
@[simp] theorem shearFun_information (B C : Matrix Row Col ℤ) (b : C1 Row Col)
    (c : Col) : information (shearFun B C b) c = information b c := rfl

omit [DecidableEq Row] [DecidableEq Col] in
@[simp] theorem shearFun_parity (B C : Matrix Row Col ℤ) (b : C1 Row Col)
    (r : Row) :
    parity (shearFun B C b) r =
      parity b r + ∑ c, ((C r c : ℝ) - (B r c : ℝ)) * information b c := rfl

/-- Linearity of the shear is about the full cochain carrier. -/
def shearLinear (B C : Matrix Row Col ℤ) : C1 Row Col →ₗ[ℝ] C1 Row Col where
  toFun := shearFun B C
  map_add' b d := by
    apply PiLp.ext
    rintro ⟨e, j⟩
    cases e with
    | none => rfl
    | some e =>
      cases e with
      | inl c => rfl
      | inr r =>
        simp only [shearFun, parity, information, PiLp.add_apply,
          PiLp.toLp_apply, mul_add, Finset.sum_add_distrib]
        ring
  map_smul' s b := by
    apply PiLp.ext
    rintro ⟨e, j⟩
    cases e with
    | none => rfl
    | some e =>
      cases e with
      | inl c => rfl
      | inr r =>
        simp only [shearFun, parity, information, PiLp.smul_apply,
          PiLp.toLp_apply, smul_eq_mul, RingHom.id_apply, mul_add, Finset.mul_sum]
        congr 1
        apply Finset.sum_congr rfl
        intro c _
        ring

omit [DecidableEq Row] [DecidableEq Col] in
theorem shearFun_reverse (B C : Matrix Row Col ℤ) (b : C1 Row Col) :
    shearFun C B (shearFun B C b) = b := by
  apply PiLp.ext
  rintro ⟨e, j⟩
  have hj : j = 0 := Subsingleton.elim _ _
  subst j
  cases e with
  | none => rfl
  | some e =>
    cases e with
    | inl c => rfl
    | inr r =>
      change parity b r +
        (∑ c, ((C r c : ℝ) - (B r c : ℝ)) * information b c) +
        (∑ c, ((B r c : ℝ) - (C r c : ℝ)) * information b c) = parity b r
      simp_rw [sub_mul, Finset.sum_sub_distrib]
      ring

/-- Its inverse is the shear with the two presentations exchanged. -/
def shearEquiv (B C : Matrix Row Col ℤ) : C1 Row Col ≃ₗ[ℝ] C1 Row Col where
  toLinearMap := shearLinear B C
  invFun := shearFun C B
  left_inv := shearFun_reverse B C
  right_inv := shearFun_reverse C B

omit [DecidableEq Col] in
theorem shear_delta0 (B C : Matrix Row Col ℤ) (a : (sheaf B).C0) :
    shearEquiv B C ((sheaf B).delta0 a) = (sheaf C).delta0 a := by
  apply PiLp.ext
  rintro ⟨e, j⟩
  have hj : j = 0 := Subsingleton.elim _ _
  subst j
  cases e with
  | none => rfl
  | some e =>
    cases e with
    | inl c => simp [shearEquiv, shearLinear, shearFun, information, delta0_apply]
    | inr r =>
      simp [shearEquiv, shearLinear, shearFun, parity, information, delta0_apply]

omit [DecidableEq Col] in
theorem delta1_shear (B C : Matrix Row Col ℤ) (b : C1 Row Col) :
    (sheaf C).delta1 (shearEquiv B C b) = (sheaf B).delta1 b := by
  apply PiLp.ext
  rintro ⟨r, j⟩
  have hj : j = 0 := Subsingleton.elim _ _
  subst j
  change (sheaf C).delta1 (shearFun B C b) ⟨r, 0⟩ = _
  rw [delta1_apply, delta1_apply, shearFun_parity]
  simp only [shearFun_information]
  simp_rw [sub_mul, Finset.sum_sub_distrib]
  ring

omit [DecidableEq Row] [DecidableEq Col] in
/-- The same information coefficients describe the transported harmonic graph.
This equation alone is not orthogonal-projection naturality. -/
theorem shear_graphVector (B C : Matrix Row Col ℤ) (x : Col → ℝ) :
    shearEquiv B C (graphVector B x) = graphVector C x := by
  apply PiLp.ext
  rintro ⟨e, j⟩
  cases e with
  | none => rfl
  | some e =>
    cases e with
    | inl c => rfl
    | inr r =>
      change (∑ c, (B r c : ℝ) * x c) +
        (∑ c, ((C r c : ℝ) - (B r c : ℝ)) * x c) =
        ∑ c, (C r c : ℝ) * x c
      simp_rw [sub_mul, Finset.sum_sub_distrib]
      ring

/-- The same shear sends every intrinsic integral harmonic point to the
target's intrinsic harmonic lattice. -/
theorem shear_mem_harmonicOneLattice (B C : Matrix Row Col ℤ)
    {b : C1 Row Col} (hb : b ∈ (integralStructure B).harmonicOneLattice) :
    shearEquiv B C b ∈ (integralStructure C).harmonicOneLattice := by
  obtain ⟨z, rfl⟩ := (mem_harmonicOneLattice_iff B b).mp hb
  rw [shear_graphVector]
  exact (mem_harmonicOneLattice_iff C _).mpr ⟨z, rfl⟩

/-- An additive lattice equivalence, without an isometry or Hodge-transport claim. -/
def harmonicLatticeEquiv (B C : Matrix Row Col ℤ) :
    (integralStructure B).harmonicOneLattice ≃+
      (integralStructure C).harmonicOneLattice where
  toFun b := ⟨shearEquiv B C b, shear_mem_harmonicOneLattice B C b.property⟩
  invFun b := ⟨shearEquiv C B b, shear_mem_harmonicOneLattice C B b.property⟩
  left_inv b := by
    apply Subtype.ext
    exact shearFun_reverse B C b
  right_inv b := by
    apply Subtype.ext
    exact shearFun_reverse C B b
  map_add' b d := by
    apply Subtype.ext
    exact (shearEquiv B C).map_add b d

/-- Integer graph messages retain the same coefficient vector under the
additive lattice equivalence constructed from the strict cochain shear. -/
theorem harmonicLatticeEquiv_graph (B C : Matrix Row Col ℤ) (z : Col → ℤ) :
    harmonicLatticeEquiv B C
        ⟨graphVector B (fun c => (z c : ℝ)),
          (mem_harmonicOneLattice_iff B _).mpr ⟨z, rfl⟩⟩ =
      ⟨graphVector C (fun c => (z c : ℝ)),
        (mem_harmonicOneLattice_iff C _).mpr ⟨z, rfl⟩⟩ := by
  apply Subtype.ext
  exact shear_graphVector B C _

/-- The actual cellular cochain complexes are strictly isomorphic. -/
def strictIso (B C : Matrix Row Col ℤ) :
    Helfer.CochainModel.Data.StrictIso
      (Helfer.CochainModel.ofSheaf (sheaf B))
      (Helfer.CochainModel.ofSheaf (sheaf C)) where
  degreeZero := Iso.refl _
  degreeOne := (shearEquiv B C).toModuleIso
  degreeTwo := Iso.refl _
  commutesZero := by
    apply ModuleCat.hom_ext
    apply LinearMap.ext
    intro a
    exact (shear_delta0 B C a).symm
  commutesOne := by
    apply ModuleCat.hom_ext
    apply LinearMap.ext
    intro b
    exact delta1_shear B C b

/-- Interpret the coupled sheaf by its actual three-term complex. -/
def semanticInterpretation (B : Matrix Row Col ℤ) :
    Helfer.Interpretation Helfer.CochainModel.Model Helfer.CochainModel.signature :=
  Helfer.CochainModel.interpretation
    (Helfer.CochainModel.ofSheaf (sheaf B)).model

omit [DecidableEq Col] in
/-- Every two matrix presentations have an actual typed Helfer equivalence. -/
theorem semanticEquivalence (B C : Matrix Row Col ℤ) :
    Helfer.HomotopyEquivalent (semanticInterpretation B) (semanticInterpretation C) :=
  (strictIso B C).equivalent

/-- The public theory consists of the declared homology-nontriviality tests. -/
def theory (B : Matrix Row Col ℤ) : Set ℤ :=
  Helfer.ClosedTheory Helfer.CochainModel.semantics (semanticInterpretation B)

omit [DecidableEq Col] in
/-- Theory equality follows from the constructed equivalence and proved invariance. -/
theorem theory_eq (B C : Matrix Row Col ℤ) : theory B = theory C :=
  Helfer.closedTheory_eq Helfer.CochainModel.semantics
    Helfer.CochainModel.closedTestInvariance (semanticEquivalence B C)

/-- The classifier retains this actual theory rather than an assigned constant label. -/
def classifier : Axioms.PublicClassifier (Matrix Row Col ℤ) (Set ℤ) := ⟨theory⟩

omit [DecidableEq Col] in
theorem samePublicClass (B C : Matrix Row Col ℤ) :
    Axioms.SamePublicClass classifier B C := theory_eq B C

omit [DecidableEq Col] in
/-- On this fixed-size admitted family, theory equality is equivalent to typed
homotopy equivalence. The reverse implication uses the constructed strict iso. -/
theorem theory_eq_iff_homotopyEquivalent (B C : Matrix Row Col ℤ) :
    theory B = theory C ↔
      Helfer.HomotopyEquivalent (semanticInterpretation B) (semanticInterpretation C) := by
  constructor
  · intro _
    exact semanticEquivalence B C
  · intro h
    exact Helfer.closedTheory_eq Helfer.CochainModel.semantics
      Helfer.CochainModel.closedTestInvariance h

/-- Extend the actual theory classifier from admitted cellular operators to
all ambient matrices, retaining the selected representative when one exists. -/
def publicProjection : _root_.PublicProjection (Index Row Col) ℝ (Set ℤ) := by
  classical
  exact fun Δ =>
    if h : ∃ B : Matrix Row Col ℤ, laplacianMatrix B = Δ then theory h.choose else ∅

theorem publicProjection_laplacian (B : Matrix Row Col ℤ) :
    publicProjection (laplacianMatrix B) = theory B := by
  classical
  unfold publicProjection
  rw [dite_eq_left (show ∃ C : Matrix Row Col ℤ, laplacianMatrix C = laplacianMatrix B
    from ⟨B, rfl⟩)]
  exact theory_eq _ _

/-- The same coupled sheaves supply the semantic interpretation, actual Hodge
matrix and public classifier of the HCP interface. -/
def realization :
    HCPBridge.Realization Helfer.CochainModel.Model Helfer.CochainModel.signature
      Helfer.CochainModel.semantics (Matrix Row Col ℤ) (Index Row Col) ℝ (Set ℤ) where
  interpretation := semanticInterpretation
  laplacian := laplacianMatrix
  classifier := classifier
  publicProjection := publicProjection
  classifyTheory := id
  classifier_factors _ := rfl
  operator_classifier_factors := publicProjection_laplacian

/-- Reflection is proved on this admitted fixed-size family by the actual
strict cochain isomorphism; it is not a generic completeness assumption. -/
theorem reflectsHomotopyEquivalence :
    HCPBridge.ReflectsHomotopyEquivalence (realization (Row := Row) (Col := Col)) := by
  intro B C _
  exact semanticEquivalence B C

/-- The realized matrix acts as the true cellular Hodge operator. -/
theorem operatorAction (B : Matrix Row Col ℤ) (b : C1 Row Col) :
    WithLp.toLp 2 (Matrix.mulVec (realization.laplacian B) b) =
      (sheaf B).degreeOneLaplacian b := by
  apply PiLp.ext
  intro i
  exact congrFun (laplacianMatrix_mulVec B b) i

theorem matrix_harmonic_iff (B : Matrix Row Col ℤ) (b : Index Row Col → ℝ) :
    MatrixIsHarmonic (realization.laplacian B) b ↔
      (sheaf B).IsHarmonicOneCochain (WithLp.toLp 2 b) := by
  change Matrix.mulVec (realization.laplacian B) b = 0 ↔
    (sheaf B).degreeOneLaplacian (WithLp.toLp 2 b) = 0
  rw [← operatorAction]
  constructor
  · intro h
    simp [h]
  · intro h
    exact congrArg WithLp.ofLp h

theorem matrixHarmonicSubspace_eq (B : Matrix Row Col ℤ) :
    HCP.matrixHarmonicSubspace (realization.laplacian B) =
      (sheaf B).harmonicOneSubspace := by
  ext b
  exact matrix_harmonic_iff B b

/-- HCP recovery is the actual cellular harmonic projection of the same input. -/
theorem operativeHarmonicComponent_eq (B : Matrix Row Col ℤ) (b : C1 Row Col) :
    HCP.operativeHarmonicComponent (realization.laplacian B) b =
      (sheaf B).harmonicOneProjection b := by
  change (HCP.matrixHarmonicSubspace _).starProjection b = _
  simp only [matrixHarmonicSubspace_eq]
  rfl

/-- Close the actual semantic/lattice/cochain chain on the native integer
sample: the HCP target is the same harmonic message whose integer coefficients
are preserved by `harmonicLatticeEquiv_graph`. The public-class theorem above
is constructed from a cochain isomorphism; no encrypted-query operation or
nonisometric Hodge transport is needed for this recovery statement. -/
theorem operative_recovers_nativeSample (B : Matrix Row Col ℤ) (z : Col → ℤ)
    (a : ℤ) (u : Row → ℤ) :
    HCP.operativeHarmonicComponent (realization.laplacian B)
        (HCPCoupledEncoding.sample B z a u).observed =
      graphVector B (fun c => (z c : ℝ)) := by
  rw [operativeHarmonicComponent_eq]
  exact HCPCoupledEncoding.sample_projection B z a u

end HomotopicalEncryption.HCP.CoupledSemantics
