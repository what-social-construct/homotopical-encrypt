module

public import Sheaf.HCPCoupledFamily

@[expose] public section

/-!
# Integral observations of the native coupled Hodge sample

Integer message coefficients and integer exact/coexact openings instantiate
the existing `HodgeEncryptedCochain`. Its full observed cochain has the actual
coordinates `(a, z - Bᵀu, Bz + u)`. The integer coordinate vector below is an
encoding source for this same observation, rather than an exact-component
payload or an alternative encryption object.
-/

set_option autoImplicit false

open scoped BigOperators RealInnerProductSpace

namespace HomotopicalEncryption.Sheaf.HCPCoupledEncoding

open CellularSheaf HCPCoupledFamily

variable {Row Col : Type*} [Fintype Row] [Fintype Col]
  [DecidableEq Row] [DecidableEq Col]

private theorem delta1_adjoint_coordinate (B : Matrix Row Col ℤ)
    (u : (sheaf B).C2) (p : Index Row Col) :
    ((sheaf B).delta1.adjoint u) p =
      ∑ r, ((sheaf B).delta1 (EuclideanSpace.single p 1)) ⟨r, 0⟩ * u ⟨r, 0⟩ := by
  have h := LinearMap.adjoint_inner_right (sheaf B).delta1
    (EuclideanSpace.single p 1) u
  simpa [EuclideanSpace.inner_single_left, PiLp.inner_apply, Fintype.sum_sigma, mul_comm]
    using h

/-- The coexact differential has no coordinate on the disjoint exact edge. -/
theorem delta1_adjoint_exactCoord (B : Matrix Row Col ℤ) (u : (sheaf B).C2) :
    exactCoord ((sheaf B).delta1.adjoint u) = 0 := by
  rw [exactCoord, delta1_adjoint_coordinate]
  simp [delta1_apply, parity, information]

/-- Information-edge coordinates of the actual coexact differential. -/
theorem delta1_adjoint_information (B : Matrix Row Col ℤ) (u : (sheaf B).C2) (c : Col) :
    information ((sheaf B).delta1.adjoint u) c =
      -∑ r, (B r c : ℝ) * u ⟨r, 0⟩ := by
  rw [information, delta1_adjoint_coordinate]
  simp [delta1_apply, parity, information, Finset.sum_neg_distrib]

/-- Parity-edge coordinates of the actual coexact differential. -/
theorem delta1_adjoint_parity (B : Matrix Row Col ℤ) (u : (sheaf B).C2) (r : Row) :
    parity ((sheaf B).delta1.adjoint u) r = u ⟨r, 0⟩ := by
  rw [parity, delta1_adjoint_coordinate]
  simp [delta1_apply, parity, information]

/-- Integer exact and coexact openings of the original Hodge-noise object. -/
noncomputable def integerNoise (B : Matrix Row Col ℤ) (a : ℤ) (u : Row → ℤ) : HodgeNoise (sheaf B) where
  exactOpening := WithLp.toLp 2 fun _ => (a : ℝ)
  coexactOpening := WithLp.toLp 2 fun p => (u p.1 : ℝ)

/-- The integral graph vector as an original intrinsic harmonic-lattice message. -/
noncomputable def message (B : Matrix Row Col ℤ) (z : Col → ℤ) :
    (integralStructure B).harmonicOneLattice :=
  ⟨graphVector B (fun c => (z c : ℝ)),
    (mem_harmonicOneLattice_iff B _).mpr ⟨z, rfl⟩⟩

/-- A native Hodge-encrypted cochain, with integer coordinates in every opening. -/
noncomputable def sample (B : Matrix Row Col ℤ) (z : Col → ℤ) (a : ℤ) (u : Row → ℤ) :
    HodgeEncryptedCochain (integralStructure B) where
  message := message B z
  opening := integerNoise B a u

/-- The separate exact coordinate of the original full observation. -/
theorem sample_observed_exactCoord (B : Matrix Row Col ℤ) (z : Col → ℤ)
    (a : ℤ) (u : Row → ℤ) :
    exactCoord (sample B z a u).observed = (a : ℝ) := by
  change exactCoord
    (graphVector B (fun c => (z c : ℝ)) +
      ((sheaf B).delta0 (integerNoise B a u).exactOpening +
        (sheaf B).delta1.adjoint (integerNoise B a u).coexactOpening)) = _
  simp only [exactCoord, PiLp.add_apply, graphVector]
  rw [delta0_apply]
  change (0 : ℝ) + ((a : ℝ) + exactCoord
    ((sheaf B).delta1.adjoint (integerNoise B a u).coexactOpening)) = _
  rw [delta1_adjoint_exactCoord]
  ring

/-- The information coordinates are the original message minus the transposed noise. -/
theorem sample_observed_information (B : Matrix Row Col ℤ) (z : Col → ℤ)
    (a : ℤ) (u : Row → ℤ) (c : Col) :
    information (sample B z a u).observed c =
      (z c : ℝ) - ∑ r, (B r c : ℝ) * (u r : ℝ) := by
  change information
    (graphVector B (fun c => (z c : ℝ)) +
      ((sheaf B).delta0 (integerNoise B a u).exactOpening +
        (sheaf B).delta1.adjoint (integerNoise B a u).coexactOpening)) c = _
  simp only [information, PiLp.add_apply, graphVector]
  rw [delta0_apply]
  change (z c : ℝ) + ((0 : ℝ) + information
    ((sheaf B).delta1.adjoint (integerNoise B a u).coexactOpening) c) = _
  rw [delta1_adjoint_information]
  simp [integerNoise, sub_eq_add_neg]

/-- Parity coordinates retain the shared cellular constraint and the coexact opening. -/
theorem sample_observed_parity (B : Matrix Row Col ℤ) (z : Col → ℤ)
    (a : ℤ) (u : Row → ℤ) (r : Row) :
    parity (sample B z a u).observed r =
      (∑ c, (B r c : ℝ) * (z c : ℝ)) + (u r : ℝ) := by
  change parity
    (graphVector B (fun c => (z c : ℝ)) +
      ((sheaf B).delta0 (integerNoise B a u).exactOpening +
        (sheaf B).delta1.adjoint (integerNoise B a u).coexactOpening)) r = _
  simp only [parity, PiLp.add_apply, graphVector]
  rw [delta0_apply]
  change (∑ c, (B r c : ℝ) * (z c : ℝ)) + ((0 : ℝ) + parity
    ((sheaf B).delta1.adjoint (integerNoise B a u).coexactOpening) r) = _
  rw [delta1_adjoint_parity]
  simp [integerNoise]

/-- Full native ciphertext coordinates, before byte encoding. -/
def integerObserved (B : Matrix Row Col ℤ) (z : Col → ℤ)
    (a : ℤ) (u : Row → ℤ) : Index Row Col → ℤ :=
  fun p => match p.1 with
    | none => a
    | some (.inl c) => z c - ∑ r, B r c * u r
    | some (.inr r) => (∑ c, B r c * z c) + u r

/-- The integer encoding source is exactly the original full observed Hodge cochain. -/
theorem integerObserved_cast_eq_observed (B : Matrix Row Col ℤ) (z : Col → ℤ)
    (a : ℤ) (u : Row → ℤ) :
    WithLp.toLp 2 (fun p => (integerObserved B z a u p : ℝ)) =
      (sample B z a u).observed := by
  apply PiLp.ext
  rintro ⟨e, j⟩
  have hj : j = 0 := Subsingleton.elim _ _
  subst j
  cases e with
  | none => exact (sample_observed_exactCoord B z a u).symm
  | some e =>
    cases e with
    | inl c =>
      change ((z c - ∑ r, B r c * u r : ℤ) : ℝ) = information (sample B z a u).observed c
      rw [sample_observed_information]
      simp only [Int.cast_sub, Int.cast_sum, Int.cast_mul]
    | inr r =>
      change (((∑ c, B r c * z c) + u r : ℤ) : ℝ) = parity (sample B z a u).observed r
      rw [sample_observed_parity]
      simp only [Int.cast_add, Int.cast_sum, Int.cast_mul]

/-- The same native sample retains the original harmonic recovery theorem. -/
theorem sample_projection (B : Matrix Row Col ℤ) (z : Col → ℤ) (a : ℤ) (u : Row → ℤ) :
    (sheaf B).harmonicOneProjection (sample B z a u).observed =
      (message B z).1 :=
  (sample B z a u).harmonicOneProjection_observed

end HomotopicalEncryption.Sheaf.HCPCoupledEncoding
