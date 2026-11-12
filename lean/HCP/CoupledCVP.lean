module

public import Sheaf.HCPCoupledFamily
public import Sheaf.HCPCoupledEncoding
public import Sheaf.HarmonicCVPPromise

@[expose] public section

/-!
# The explicit lattice of a coupled cellular Hodge family

The same integer matrix used by the cellular restriction maps presents the
harmonic graph lattice. Its CVP objective retains the shared constraints;
no complexity reduction or security assertion is made here.
-/

set_option autoImplicit false

open scoped BigOperators RealInnerProductSpace

noncomputable section

namespace HomotopicalEncryption.HCP.CoupledCVP

open Sheaf CellularSheaf HCPCoupledFamily

variable {Row Col : Type*} [Fintype Row] [Fintype Col]
  [DecidableEq Row] [DecidableEq Col]

/-- Columns are the harmonic graph generators `(0,e_c,B e_c)`. -/
def graphBasis (B : Matrix Row Col ℤ) : Matrix (Index Row Col) Col ℝ :=
  fun p c => match p.1 with
    | none => 0
    | some (.inl d) => if d = c then 1 else 0
    | some (.inr r) => (B r c : ℝ)

omit [DecidableEq Row] in
theorem graphBasis_mulVec (B : Matrix Row Col ℤ) (x : Col → ℝ) :
    WithLp.toLp 2 ((graphBasis B).mulVec x) = graphVector B x := by
  apply PiLp.ext
  rintro ⟨e, j⟩
  cases e with
  | none => simp [graphBasis, Matrix.mulVec, dotProduct, graphVector]
  | some e =>
    cases e with
    | inl c => simp [graphBasis, Matrix.mulVec, dotProduct, graphVector]
    | inr r => rfl

/-- The information coordinates certify full column rank. -/
def graphLattice (B : Matrix Row Col ℤ) : CVP.ExplicitLattice (Index Row Col) Col where
  basis := graphBasis B
  basis_injective := by
    intro x y h
    apply graphVector_injective B
    rw [← graphBasis_mulVec, ← graphBasis_mulVec, h]

omit [DecidableEq Row] in
theorem latticeVector_eq_graphVector (B : Matrix Row Col ℤ) (z : Col → ℤ) :
    WithLp.toLp 2 (CVP.latticeVector (graphLattice B) z) =
      graphVector B (fun c => (z c : ℝ)) :=
  graphBasis_mulVec B _

/-- In this graph chart, the embedded harmonic space determines every matrix entry. -/
theorem harmonicSubspace_injective :
    Function.Injective (β := Submodule ℝ (C1 Row Col))
      (fun B : Matrix Row Col ℤ => (sheaf B).harmonicOneSubspace) := by
  intro B C hspace
  change (sheaf B).harmonicOneSubspace = (sheaf C).harmonicOneSubspace at hspace
  ext r c
  let x : Col → ℝ := Pi.single c 1
  have hb : graphVector B x ∈ (sheaf B).harmonicOneSubspace :=
    LinearMap.mem_ker.mpr (graphVector_harmonic B x)
  rw [hspace] at hb
  have heq := ((harmonic_iff C _).mp (LinearMap.mem_ker.mp hb)).2 r
  simp [graphVector_parity, graphVector_information, x, Pi.single_apply] at heq
  exact_mod_cast heq

/-- This presentation contains every intrinsic integral harmonic cochain. -/
theorem inExplicitLattice_iff_harmonicOneLattice
    (B : Matrix Row Col ℤ) (b : C1 Row Col) :
    CVP.InExplicitLattice (graphLattice B) b ↔
      b ∈ (integralStructure B).harmonicOneLattice := by
  rw [HCPCoupledFamily.mem_harmonicOneLattice_iff]
  constructor
  · rintro ⟨z, hz⟩
    refine ⟨z, ?_⟩
    rw [← latticeVector_eq_graphVector]
    exact (congrArg (WithLp.toLp 2) hz).symm
  · rintro ⟨z, hz⟩
    refine ⟨z, ?_⟩
    have heq := (latticeVector_eq_graphVector B z).trans hz.symm
    exact congrArg WithLp.ofLp heq

/-- Full real span and exact intrinsic integer membership use the same basis. -/
def harmonicLatticePresentation (B : Matrix Row Col ℤ) :
    HarmonicLatticePresentation (integralStructure B) Col where
  lattice := graphLattice B
  latticeVector_mem z := by
    rw [latticeVector_eq_graphVector]
    exact ⟨graphVector_integral B z, graphVector_harmonic B _⟩
  realSpan_eq_harmonic := by
    ext b
    constructor
    · rintro ⟨x, rfl⟩
      change (sheaf B).degreeOneLaplacian
        (WithLp.toLp 2 ((graphBasis B).mulVec x)) = 0
      rw [graphBasis_mulVec]
      exact graphVector_harmonic B x
    · intro hb
      refine ⟨information b, ?_⟩
      change WithLp.toLp 2 ((graphBasis B).mulVec (information b)) = b
      rw [graphBasis_mulVec]
      exact (eq_graphVector_of_harmonic B hb).symm

/-- The original Hodge recovery law applies to every coupled coefficient vector. -/
theorem encrypt_projection (B : Matrix Row Col ℤ) (z : Col → ℤ)
    (opening : HodgeNoise (sheaf B)) :
    (sheaf B).harmonicOneProjection
        ((harmonicLatticePresentation B).encrypt z opening).observed =
      graphVector B (fun c => (z c : ℝ)) := by
  exact ((harmonicLatticePresentation B).encrypt_projection_eq_point z opening).trans
    (latticeVector_eq_graphVector B z)

/-- A supplied known-lattice oracle recovers this same generated harmonic graph. -/
theorem correct_cvp_oracle_recovers_encrypt (B : Matrix Row Col ℤ)
    (O : CVP.Oracle (Index Row Col) Col) (hO : CVP.OracleCorrect O)
    (z : Col → ℤ) (opening : HodgeNoise (sheaf B)) :
    O (graphLattice B) ((harmonicLatticePresentation B).encrypt z opening).observed =
      graphVector B (fun c => (z c : ℝ)) := by
  exact ((harmonicLatticePresentation B).correct_cvp_oracle_recovers_encrypt
    O hO z opening).trans (congrArg WithLp.ofLp (latticeVector_eq_graphVector B z))

/-- The integer-profile codec's sample is the same presentation-generated
Hodge encryption, retaining the original message and exact/coexact openings. -/
theorem nativeSample_eq_encrypt (B : Matrix Row Col ℤ) (z : Col → ℤ)
    (a : ℤ) (u : Row → ℤ) :
    HCPCoupledEncoding.sample B z a u =
      (harmonicLatticePresentation B).encrypt z (HCPCoupledEncoding.integerNoise B a u) := by
  have hm : HCPCoupledEncoding.message B z = (harmonicLatticePresentation B).point z := by
    apply Subtype.ext
    exact (latticeVector_eq_graphVector B z).symm
  change HodgeEncryptedCochain.mk (HCPCoupledEncoding.message B z) _ =
    HodgeEncryptedCochain.mk ((harmonicLatticePresentation B).point z) _
  rw [hm]

omit [DecidableEq Row] in
/-- The metric on graph coefficients includes all shared parity equations. -/
theorem squaredDistance_eq_objective
    (B : Matrix Row Col ℤ) (target : C1 Row Col) (z : Col → ℤ) :
    CVP.squaredEuclideanDistance target (CVP.latticeVector (graphLattice B) z) =
      (exactCoord target) ^ 2 +
        (∑ c, (information target c - (z c : ℝ)) ^ 2) +
        ∑ r, (parity target r - ∑ c, (B r c : ℝ) * (z c : ℝ)) ^ 2 := by
  change CVP.squaredEuclideanDistance target
    (WithLp.toLp 2 (CVP.latticeVector (graphLattice B) z)) = _
  rw [latticeVector_eq_graphVector]
  simp [CVP.squaredEuclideanDistance, Fintype.sum_sigma, Fintype.sum_option,
    Fintype.sum_sum_type, graphVector, exactCoord, information, parity, add_assoc]

omit [DecidableEq Row] in
/-- The Gram entries are `I + BᵀB`, including the off-diagonal interactions. -/
theorem graphBasis_gram (B : Matrix Row Col ℤ) (c d : Col) :
    ((graphBasis B).transpose * graphBasis B) c d =
      (if c = d then 1 else 0) + ∑ r, (B r c : ℝ) * (B r d : ℝ) := by
  simp [Matrix.mul_apply, Matrix.transpose_apply, graphBasis,
    Fintype.sum_sigma, Fintype.sum_option, Fintype.sum_sum_type, eq_comm]

/-- One face constraining two information edges. -/
def sharedRow : Matrix (Fin 1) (Fin 2) ℤ := fun _ _ => 1

/-- A shared row already produces an off-diagonal Gram entry equal to one. -/
theorem sharedRow_gram_offDiagonal :
    ((graphBasis sharedRow).transpose * graphBasis sharedRow) 0 1 = 1 := by
  rw [graphBasis_gram]
  norm_num [sharedRow]

end HomotopicalEncryption.HCP.CoupledCVP
