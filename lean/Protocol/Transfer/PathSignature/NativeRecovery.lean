module

public import Protocol.Transfer.PathSignature.NativeSampler
public import Mathlib.Data.Rat.Cast.Order

@[expose] public section

/-!
# Explicit recovery in a positive bounded native profile

The public decoder below reads the original full coupled ciphertext. For the
positive scalar profile with bound one, an elementary predictor recovers the
message coefficient on exactly seven ninths of the uniform seeds. Source presentations,
credential salts, exact openings and hashes are unused. The full-seed marginal
is proved, so the calculation concerns the existing native sampler rather than
an independently selected plaintext distribution.

This is a counterexample to a small recovery bound claimed uniformly over all
allowed profiles. It is not an attack theorem for every growing-dimensional
family. The final identities also record the scalar public norm constraint
and recovery of a reused scalar matrix from a known zero-message sample with
nonzero coexact opening. No computational hardness assumption is used here.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeRecovery

open Sheaf CellularSheaf
open scoped ENNReal

abbrev Bytes := List UInt8

/-- The scalar matrix and constant scalar vectors use the original carriers. -/
def scalarMatrix (c : ℤ) : Matrix (Fin 1) (Fin 1) ℤ := fun _ _ => c

def scalarVector (z : ℤ) : Fin 1 → ℤ := fun _ => z

/-- A predictor using only the two non-exact public coordinates. -/
def scalarGuess (x y : ℤ) : ℤ :=
  if x = 0 then
    if y.natAbs = 2 then y.sign else 0
  else x.sign

/-- Parse the actual canonical full ciphertext before applying the predictor. -/
def predictScalar (bytes : Bytes) : Option ℤ := do
  let observed ← Storage.CoupledCiphertext.decode 1 1 bytes
  some (scalarGuess (observed ⟨some (.inl 0), 0⟩)
    (observed ⟨some (.inr 0), 0⟩))

/-- For a known zero message, parse the original ciphertext and divide its
two public coordinates. This routine makes no claim on unknown plaintexts. -/
def recoverKnownZeroScalar (bytes : Bytes) : Option ℚ := do
  let observed ← Storage.CoupledCiphertext.decode 1 1 bytes
  let x := observed ⟨some (.inl 0), 0⟩
  let y := observed ⟨some (.inr 0), 0⟩
  if y = 0 then none else some (-(x : ℚ) / (y : ℚ))

theorem predictScalar_sampleBytes (c z a u : ℤ) :
    predictScalar (Storage.CoupledCiphertext.sampleBytes
      (scalarMatrix c) (scalarVector z) a (scalarVector u)) =
      some (scalarGuess (z - c * u) (c * z + u)) := by
  simp [predictScalar, Storage.CoupledCiphertext.decode_sampleBytes,
    HCPCoupledEncoding.integerObserved, scalarMatrix, scalarVector]

/-- The three independent coordinates relevant to this calculation. -/
abbrev ScalarCore := NativeSampler.Coordinate 1 ×
  NativeSampler.Coordinate 1 × NativeSampler.Coordinate 1

def coreC (core : ScalarCore) : ℤ := NativeSampler.signed 1 core.1
def coreZ (core : ScalarCore) : ℤ := NativeSampler.signed 1 core.2.1
def coreU (core : ScalarCore) : ℤ := NativeSampler.signed 1 core.2.2

def CoreSuccess (core : ScalarCore) : Prop :=
  scalarGuess (coreZ core - coreC core * coreU core)
    (coreC core * coreZ core + coreU core) = coreZ core

instance (core : ScalarCore) : Decidable (CoreSuccess core) :=
  inferInstanceAs (Decidable (_ = _))

def successfulCores : Finset ScalarCore := Finset.univ.filter CoreSuccess

/-- This finite enumeration is checked by kernel reduction, not `native_decide`. -/
theorem successfulCores_card : successfulCores.card = 21 := by decide

theorem scalarCore_card : Fintype.card ScalarCore = 27 := by decide

noncomputable section

private def uniformFinite (α : Type) [Fintype α] [Nonempty α] : PMF α :=
  PMF.ofFintype (fun _ => (Fintype.card α : ℝ≥0∞)⁻¹) (by
    classical
    simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    exact ENNReal.mul_inv_cancel (by simp) (ENNReal.natCast_ne_top _))

private theorem uniformFinite_apply (α : Type) [Fintype α] [Nonempty α] (a : α) :
    uniformFinite α a = (Fintype.card α : ℝ≥0∞)⁻¹ := rfl

private theorem uniformFinite_map_equiv {α β : Type} [Fintype α] [Fintype β]
    [Nonempty α] [Nonempty β] (equivalence : α ≃ β) :
    (uniformFinite α).map equivalence = uniformFinite β := by
  classical
  ext b
  rw [PMF.map_apply]
  have equal (a : α) : b = equivalence a ↔ a = equivalence.symm b := by
    constructor
    · intro same
      exact ((equivalence.symm_apply_eq).2 same).symm
    · intro same
      rw [same, equivalence.apply_symm_apply]
  simp_rw [equal, uniformFinite_apply]
  simp [Fintype.card_congr equivalence]

private theorem uniformFinite_map_fst {α β : Type} [Fintype α] [Fintype β]
    [Nonempty α] [Nonempty β] :
    (uniformFinite (α × β)).map Prod.fst = uniformFinite α := by
  classical
  ext a
  rw [PMF.map_apply, tsum_fintype, Fintype.sum_prod_type]
  rw [Finset.sum_comm]
  simp only [uniformFinite_apply]
  simp only [Finset.sum_ite_eq, Finset.mem_univ, ite_true, Finset.sum_const,
    Finset.card_univ, nsmul_eq_mul, Fintype.card_prod, Nat.cast_mul]
  rw [ENNReal.mul_inv (Or.inl (by simp)) (Or.inl (ENNReal.natCast_ne_top _)),
    mul_left_comm, ENNReal.mul_inv_cancel (by simp) (ENNReal.natCast_ne_top _), mul_one]

/-- Uniform independent scalar matrix, message and coexact opening indices. -/
def uniformCore : PMF ScalarCore :=
  PMF.ofFintype (fun _ => (Fintype.card ScalarCore : ℝ≥0∞)⁻¹) (by
    simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    exact ENNReal.mul_inv_cancel (by simp) (ENNReal.natCast_ne_top _))

/-- Exact success probability for the actual public-coordinate predictor. -/
theorem uniformCore_recovery :
    uniformCore.toOuterMeasure {core | CoreSuccess core} = (7 : ℝ≥0∞) / 9 := by
  classical
  have event : {core | CoreSuccess core} = (successfulCores : Set ScalarCore) := by
    ext core
    simp [successfulCores]
  rw [event, PMF.toOuterMeasure_apply_finset]
  simp only [uniformCore, PMF.ofFintype_apply, Finset.sum_const, successfulCores_card,
    nsmul_eq_mul, scalarCore_card]
  have arithmetic : (21 : NNReal) * 27⁻¹ = 7 / 9 := by norm_num
  have lifted := congrArg (fun value : NNReal => (value : ℝ≥0∞)) arithmetic
  simpa [ENNReal.coe_mul,
    ENNReal.coe_inv (by norm_num : (27 : NNReal) ≠ 0),
    ENNReal.coe_div (by norm_num : (9 : NNReal) ≠ 0), ENNReal.coe_ofNat] using lifted

/-- Keep the exact existing native profile, allowing every salt length. -/
def scalarProfile (saltBytes : ℕ) : NativeRelation.Profile := ⟨1, saltBytes⟩

abbrev ScalarResidual (saltBytes : ℕ) := NativeSampler.Coordinate 1 ×
  NativeSampler.Coordinate 1 × (Fin saltBytes → Fin 256)

/-- Target matrix, message and coexact opening of the existing full seed. -/
def coreOfSeed {saltBytes : ℕ}
    (seed : NativeSampler.Seed 1 1 (scalarProfile saltBytes)) : ScalarCore :=
  ⟨seed.2.1 0 0, seed.2.2.1 0, seed.2.2.2.2.1 0⟩

private def splitSeed (saltBytes : ℕ) :
    NativeSampler.Seed 1 1 (scalarProfile saltBytes) ≃
      ScalarCore × ScalarResidual saltBytes where
  toFun seed := ⟨coreOfSeed seed, seed.1 0 0, seed.2.2.2.1, seed.2.2.2.2.2⟩
  invFun value :=
    ⟨(fun _ _ => value.2.1), (fun _ _ => value.1.1), (fun _ => value.1.2.1),
      value.2.2.1, (fun _ => value.1.2.2), value.2.2.2⟩
  left_inv seed := by
    rcases seed with ⟨source, target, z, a, u, salt⟩
    refine Prod.ext ?_ (Prod.ext ?_ (Prod.ext ?_ (Prod.ext rfl (Prod.ext ?_ rfl))))
    · funext row col
      change source 0 0 = source row col
      rw [Subsingleton.elim row 0, Subsingleton.elim col 0]
    · funext row col
      change target 0 0 = target row col
      rw [Subsingleton.elim row 0, Subsingleton.elim col 0]
    · funext col
      change z 0 = z col
      rw [Subsingleton.elim col 0]
    · funext row
      change u 0 = u row
      rw [Subsingleton.elim row 0]
  right_inv value := by rfl

/-- The full native sampler really has the independent uniform scalar core. -/
theorem uniformSeed_core (saltBytes : ℕ) :
    (NativeSampler.uniformSeed 1 1 (scalarProfile saltBytes)).map coreOfSeed = uniformCore := by
  have original : NativeSampler.uniformSeed 1 1 (scalarProfile saltBytes) =
      uniformFinite (NativeSampler.Seed 1 1 (scalarProfile saltBytes)) := rfl
  rw [original]
  have split := uniformFinite_map_equiv (splitSeed saltBytes)
  have mapped := congrArg (fun law => law.map Prod.fst) split
  rw [PMF.map_comp, uniformFinite_map_fst] at mapped
  have projection : (Prod.fst ∘ (splitSeed saltBytes)) = coreOfSeed := by
    funext seed
    rfl
  have coreLaw : uniformFinite ScalarCore = uniformCore := rfl
  rw [projection, coreLaw] at mapped
  exact mapped

/-- On every original witness the byte predictor ignores its source, salt
and exact opening, while retaining the actual observed cochain. -/
theorem predictScalar_decodeSeed {saltBytes : ℕ}
    (seed : NativeSampler.Seed 1 1 (scalarProfile saltBytes)) :
    let witness := NativeSampler.decodeSeed seed
    predictScalar (Storage.CoupledCiphertext.sampleBytes
      witness.target witness.z witness.a witness.u) =
      some (scalarGuess (coreZ (coreOfSeed seed) - coreC (coreOfSeed seed) * coreU (coreOfSeed seed))
        (coreC (coreOfSeed seed) * coreZ (coreOfSeed seed) + coreU (coreOfSeed seed))) := by
  dsimp only
  unfold predictScalar
  rw [Storage.CoupledCiphertext.decode_sampleBytes]
  simp [HCPCoupledEncoding.integerObserved, NativeSampler.decodeSeed, coreOfSeed,
    coreC, coreZ, coreU, scalarProfile]

/-- Exact seven-ninths coefficient recovery on the existing full sampler for every salt
length. Additional hashes are ignored by this public algorithm. -/
theorem uniformSeed_recovery (saltBytes : ℕ) :
    (NativeSampler.uniformSeed 1 1 (scalarProfile saltBytes)).toOuterMeasure
      {seed | let witness := NativeSampler.decodeSeed seed
        predictScalar (Storage.CoupledCiphertext.sampleBytes
          witness.target witness.z witness.a witness.u) = some (witness.z 0)} =
      (7 : ℝ≥0∞) / 9 := by
  have event :
      {seed : NativeSampler.Seed 1 1 (scalarProfile saltBytes) |
        let witness := NativeSampler.decodeSeed seed
        predictScalar (Storage.CoupledCiphertext.sampleBytes
          witness.target witness.z witness.a witness.u) = some (witness.z 0)} =
      coreOfSeed ⁻¹' {core | CoreSuccess core} := by
    ext seed
    change predictScalar (Storage.CoupledCiphertext.sampleBytes
      (NativeSampler.decodeSeed seed).target (NativeSampler.decodeSeed seed).z
      (NativeSampler.decodeSeed seed).a (NativeSampler.decodeSeed seed).u) =
      some ((NativeSampler.decodeSeed seed).z 0) ↔ CoreSuccess (coreOfSeed seed)
    rw [predictScalar_decodeSeed]
    simp [CoreSuccess, coreZ, coreOfSeed, NativeSampler.decodeSeed, scalarProfile]
  rw [event, ← PMF.toOuterMeasure_map_apply, uniformSeed_core]
  exact uniformCore_recovery

/-- Adding the sampler's independent cryptographic tape leaves this exact
public-ciphertext recovery probability unchanged. -/
theorem coins_recovery {Tape : Type} (saltBytes : ℕ) (tape : PMF Tape) :
    (NativeSampler.coins 1 1 (scalarProfile saltBytes) tape).toOuterMeasure
      {coin | let witness := NativeSampler.challenge coin
        predictScalar (Storage.CoupledCiphertext.sampleBytes
          witness.target witness.z witness.a witness.u) = some (witness.z 0)} =
      (7 : ℝ≥0∞) / 9 := by
  have law := uniformSeed_recovery saltBytes
  rw [← NativeSampler.coins_fst 1 1 (scalarProfile saltBytes) tape,
    PMF.toOuterMeasure_map_apply] at law
  exact law

end

/-- The observed scalar coordinates satisfy an exact public norm constraint. -/
theorem scalar_norm_identity (c z u : ℤ) :
    (z - c * u) ^ 2 + (c * z + u) ^ 2 =
      (1 + c ^ 2) * (z ^ 2 + u ^ 2) := by ring

/-- A known zero message exposes the noise and a linear equation for the
scalar presentation through the original ciphertext decoder. -/
theorem zeroMessage_sampleBytes (c a u : ℤ) :
    Storage.CoupledCiphertext.decode 1 1 (Storage.CoupledCiphertext.sampleBytes
      (scalarMatrix c) (scalarVector 0) a (scalarVector u)) =
      some (HCPCoupledEncoding.integerObserved
        (scalarMatrix c) (scalarVector 0) a (scalarVector u)) ∧
    HCPCoupledEncoding.integerObserved (scalarMatrix c) (scalarVector 0) a
      (scalarVector u) ⟨some (.inl 0), 0⟩ = -c * u ∧
    HCPCoupledEncoding.integerObserved (scalarMatrix c) (scalarVector 0) a
      (scalarVector u) ⟨some (.inr 0), 0⟩ = u := by
  simp [Storage.CoupledCiphertext.decode_sampleBytes,
    HCPCoupledEncoding.integerObserved, scalarMatrix, scalarVector]

/-- Recover a reused scalar presentation from one known zero-message
observation whose coexact opening is nonzero. -/
theorem zeroMessage_recovers_scalar (c u : ℤ) (nonzero : u ≠ 0) :
    -((-(c * u) : ℤ) : ℚ) / (u : ℚ) = (c : ℚ) := by
  have rationalNonzero : (u : ℚ) ≠ 0 := by exact_mod_cast nonzero
  push_cast
  field_simp

/-- The known-zero key-recovery algorithm consumes actual native bytes. -/
theorem recoverKnownZeroScalar_sampleBytes (c a u : ℤ) (nonzero : u ≠ 0) :
    recoverKnownZeroScalar (Storage.CoupledCiphertext.sampleBytes
      (scalarMatrix c) (scalarVector 0) a (scalarVector u)) = some (c : ℚ) := by
  simp [recoverKnownZeroScalar, Storage.CoupledCiphertext.decode_sampleBytes,
    HCPCoupledEncoding.integerObserved, scalarMatrix, scalarVector, nonzero]

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeRecovery
