module

public import Sheaf.HCPCoupledEncoding
public import Mathlib.LinearAlgebra.FiniteDimensional.Basic

@[expose] public section

/-!
# Native Hodge-coordinate transport between coupled presentations

The real coordinate map `M_B(a,z,u) = (a,z-Bᵀu,Bz+u)` is invertible: the
off-diagonal inner-product terms cancel, leaving the squared norm of the
coordinate input. Transport is `M_C ∘ M_B⁻¹`, so it carries the original full
Hodge ciphertext to the target's encryption with the same message and exact
and coexact opening coordinates. It need not be isometric and is different
from the strict cochain shear in `HCP.CoupledSemantics`.

Constructing this map uses the presentations or a derived transport token.
No secure public evaluation token, efficient finite inverse algorithm or
cryptographic security is asserted. The inverse is classical here. Generated
integral samples transport to generated integral samples; arbitrary integer
cochains need not have integral transported coordinates. Transport to the
known zero presentation exposes the original message coordinates.
-/

set_option autoImplicit false

open scoped BigOperators RealInnerProductSpace

noncomputable section

namespace HomotopicalEncryption.HCP.CoupledTransport

open Sheaf CellularSheaf HCPCoupledFamily

variable {Row Col : Type*} [Fintype Row] [Fintype Col]

/-- Use the common cochain carrier also to store real `(a,z,u)` coordinates. -/
def coordinates (a : ℝ) (z : Col → ℝ) (u : Row → ℝ) : C1 Row Col :=
  WithLp.toLp 2 fun p => match p.1 with
    | none => a
    | some (.inl c) => z c
    | some (.inr r) => u r

@[simp] theorem coordinates_exactCoord (a : ℝ) (z : Col → ℝ) (u : Row → ℝ) :
    exactCoord (coordinates a z u) = a := rfl

@[simp] theorem coordinates_information (a : ℝ) (z : Col → ℝ) (u : Row → ℝ) (c : Col) :
    information (coordinates a z u) c = z c := rfl

@[simp] theorem coordinates_parity (a : ℝ) (z : Col → ℝ) (u : Row → ℝ) (r : Row) :
    parity (coordinates a z u) r = u r := rfl

@[simp] theorem coordinates_eta (b : C1 Row Col) :
    coordinates (exactCoord b) (information b) (parity b) = b := by
  apply PiLp.ext
  rintro ⟨e, j⟩
  have hj : j = 0 := Subsingleton.elim _ _
  subst j
  cases e with
  | none => rfl
  | some e => cases e <;> rfl

/-- Assemble a full native observation from real message/opening coordinates. -/
def nativeLinear (B : Matrix Row Col ℤ) : C1 Row Col →ₗ[ℝ] C1 Row Col where
  toFun b := coordinates (exactCoord b)
    (fun c => information b c - ∑ r, (B r c : ℝ) * parity b r)
    (fun r => (∑ c, (B r c : ℝ) * information b c) + parity b r)
  map_add' b d := by
    apply PiLp.ext
    rintro ⟨e, j⟩
    cases e with
    | none => rfl
    | some e =>
      cases e with
      | inl c =>
        simp only [coordinates, information, parity, exactCoord, PiLp.add_apply,
          PiLp.toLp_apply, mul_add, Finset.sum_add_distrib]
        ring
      | inr r =>
        simp only [coordinates, information, parity, exactCoord, PiLp.add_apply,
          PiLp.toLp_apply, mul_add, Finset.sum_add_distrib]
        ring
  map_smul' s b := by
    apply PiLp.ext
    rintro ⟨e, j⟩
    cases e with
    | none => rfl
    | some e =>
      cases e with
      | inl c =>
        simp only [coordinates, information, parity, exactCoord, PiLp.smul_apply,
          PiLp.toLp_apply, smul_eq_mul, RingHom.id_apply]
        simp_rw [mul_left_comm (B _ _ : ℝ) s, ← Finset.mul_sum]
        ring
      | inr r =>
        simp only [coordinates, information, parity, exactCoord, PiLp.smul_apply,
          PiLp.toLp_apply, smul_eq_mul, RingHom.id_apply]
        simp_rw [mul_left_comm (B _ _ : ℝ) s, ← Finset.mul_sum]
        ring

@[simp] theorem nativeLinear_exactCoord (B : Matrix Row Col ℤ) (b : C1 Row Col) :
    exactCoord (nativeLinear B b) = exactCoord b := rfl

@[simp] theorem nativeLinear_information (B : Matrix Row Col ℤ) (b : C1 Row Col) (c : Col) :
    information (nativeLinear B b) c =
      information b c - ∑ r, (B r c : ℝ) * parity b r := rfl

@[simp] theorem nativeLinear_parity (B : Matrix Row Col ℤ) (b : C1 Row Col) (r : Row) :
    parity (nativeLinear B b) r =
      (∑ c, (B r c : ℝ) * information b c) + parity b r := rfl

/-- The Euclidean inner product in exact/information/parity coordinates. -/
theorem inner_coordinates (b d : C1 Row Col) :
    inner ℝ b d = exactCoord b * exactCoord d +
      (∑ c, information b c * information d c) +
      ∑ r, parity b r * parity d r := by
  simp [PiLp.inner_apply, Fintype.sum_sigma, Fintype.sum_option,
    Fintype.sum_sum_type, exactCoord, information, parity, mul_comm, add_assoc]

/-- Cancellation of the two coupling terms leaves the input's squared norm. -/
theorem inner_nativeLinear (B : Matrix Row Col ℤ) (b : C1 Row Col) :
    inner ℝ b (nativeLinear B b) = inner ℝ b b := by
  rw [inner_coordinates, inner_coordinates]
  simp only [nativeLinear_exactCoord, nativeLinear_information, nativeLinear_parity]
  simp_rw [mul_sub, mul_add, Finset.mul_sum,
    Finset.sum_sub_distrib, Finset.sum_add_distrib]
  have cross :
      (∑ c, ∑ r, information b c * ((B r c : ℝ) * parity b r)) =
        ∑ r, ∑ c, parity b r * ((B r c : ℝ) * information b c) := by
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro r _
    apply Finset.sum_congr rfl
    intro c _
    ring
  rw [cross]
  ring

/-- The native coordinate map loses no real message or opening coordinates. -/
theorem nativeLinear_injective (B : Matrix Row Col ℤ) :
    Function.Injective (nativeLinear B) := by
  intro b d h
  have hzero : nativeLinear B (b - d) = 0 := by rw [map_sub, h, sub_self]
  have hinner := inner_nativeLinear B (b - d)
  rw [hzero, inner_zero_right] at hinner
  exact sub_eq_zero.mp ((inner_self_eq_zero (𝕜 := ℝ)).mp hinner.symm)

/-- The full native coordinate equivalence; no metric-preservation condition is needed. -/
def nativeEquiv (B : Matrix Row Col ℤ) : C1 Row Col ≃ₗ[ℝ] C1 Row Col :=
  LinearEquiv.ofInjectiveEndo (nativeLinear B) (nativeLinear_injective B)

theorem nativeEquiv_apply (B : Matrix Row Col ℤ) (b : C1 Row Col) :
    nativeEquiv B b = nativeLinear B b := rfl

/-- Change presentations by decoding Hodge coordinates and reassembling them.
The map can be applied to ciphertexts once the derived transport data is held. -/
def transport (B C : Matrix Row Col ℤ) : C1 Row Col ≃ₗ[ℝ] C1 Row Col :=
  (nativeEquiv B).symm.trans (nativeEquiv C)

theorem transport_nativeEquiv (B C : Matrix Row Col ℤ) (b : C1 Row Col) :
    transport B C (nativeEquiv B b) = nativeEquiv C b := by
  simp [transport]

@[simp] theorem transport_refl (B : Matrix Row Col ℤ) (b : C1 Row Col) :
    transport B B b = b := by simp [transport]

@[simp] theorem transport_reverse (B C : Matrix Row Col ℤ) (b : C1 Row Col) :
    transport C B (transport B C b) = b := by simp [transport]

theorem transport_comp (B C D : Matrix Row Col ℤ) (b : C1 Row Col) :
    transport C D (transport B C b) = transport B D b := by simp [transport]

variable [DecidableEq Row] [DecidableEq Col]

/-- The original integer sample is assembled by this real native map. -/
theorem nativeEquiv_coordinates_eq_observed (B : Matrix Row Col ℤ)
    (z : Col → ℤ) (a : ℤ) (u : Row → ℤ) :
    nativeEquiv B (coordinates (a : ℝ) (fun c => (z c : ℝ)) (fun r => (u r : ℝ))) =
      (HCPCoupledEncoding.sample B z a u).observed := by
  apply PiLp.ext
  rintro ⟨e, j⟩
  have hj : j = 0 := Subsingleton.elim _ _
  subst j
  cases e with
  | none => exact (HCPCoupledEncoding.sample_observed_exactCoord B z a u).symm
  | some e =>
    cases e with
    | inl c => exact (HCPCoupledEncoding.sample_observed_information B z a u c).symm
    | inr r => exact (HCPCoupledEncoding.sample_observed_parity B z a u r).symm

/-- Exact native ciphertext transport preserves the original message and both
opening coordinate vectors, including for nonisometric presentation changes. -/
theorem transport_observed (B C : Matrix Row Col ℤ) (z : Col → ℤ)
    (a : ℤ) (u : Row → ℤ) :
    transport B C (HCPCoupledEncoding.sample B z a u).observed =
      (HCPCoupledEncoding.sample C z a u).observed := by
  rw [← nativeEquiv_coordinates_eq_observed B, transport_nativeEquiv,
    nativeEquiv_coordinates_eq_observed C]

/-- Generated integral observations remain generated integral observations.
This makes no integrality claim for arbitrary input integer cochains. -/
theorem transport_integerObserved (B C : Matrix Row Col ℤ) (z : Col → ℤ)
    (a : ℤ) (u : Row → ℤ) :
    transport B C (WithLp.toLp 2 fun p =>
        (HCPCoupledEncoding.integerObserved B z a u p : ℝ)) =
      WithLp.toLp 2 (fun p => (HCPCoupledEncoding.integerObserved C z a u p : ℝ)) := by
  rw [HCPCoupledEncoding.integerObserved_cast_eq_observed,
    HCPCoupledEncoding.integerObserved_cast_eq_observed, transport_observed]

omit [DecidableEq Row] [DecidableEq Col] in
/-- The zero matrix's native map is the identity coordinate assembly. -/
@[simp] theorem nativeEquiv_zero (b : C1 Row Col) :
    nativeEquiv (0 : Matrix Row Col ℤ) b = b := by
  change nativeLinear (0 : Matrix Row Col ℤ) b = b
  apply PiLp.ext
  rintro ⟨e, j⟩
  have hj : j = 0 := Subsingleton.elim _ _
  subst j
  cases e with
  | none => rfl
  | some e => cases e <;> simp [nativeLinear, coordinates, information, parity]

/-- A publicly usable transport to the known zero presentation reveals each
original integer message coefficient as an output information coordinate. -/
theorem transport_to_zero_discloses (B : Matrix Row Col ℤ) (z : Col → ℤ)
    (a : ℤ) (u : Row → ℤ) (c : Col) :
    information (transport B 0 (HCPCoupledEncoding.sample B z a u).observed) c =
      (z c : ℝ) := by
  rw [transport_observed, HCPCoupledEncoding.sample_observed_information]
  simp

end HomotopicalEncryption.HCP.CoupledTransport
