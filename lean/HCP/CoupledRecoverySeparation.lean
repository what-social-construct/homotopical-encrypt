module

public import HCP.CoupledCVP
public import Protocol.Transfer.PathSignature.NativeCommittedRandomOracle

@[expose] public section

/-!
# Supplied-lattice CVP and public recovery on the fresh-sign family

A correct CVP oracle recovers the original message when queried with the
operative graph lattice and the decoded ciphertext. In the one-use public
experiment for the same ciphertexts, the operative lattice is hidden. Allow
the public decoder to depend arbitrarily on a fixed CVP oracle, chosen
independently of the challenge and the byte random oracle. Its recovery
probability still obeys the public hash-query bound.

For a fixed public mask, every sign key gives one distinct compatible
message for the same ciphertext bytes. Positive scaling gives exactly as
many compatible integer coefficient vectors as keys.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.HCP.CoupledRecoverySeparation

open Sheaf HCPCoupledFamily
open Protocol.Transfer.PathSignature
open NativeSignSampler NativeCommittedRandomOracle
open Protocol.Storage.OperatorCommitment.RandomOracle (realProbability)
open OracleComp
open scoped ENNReal

variable {rows cols : ℕ}

/-- One closest-vector query with the supplied lattice, followed by reading
the signs of the information coordinates of its answer. -/
def recoverWithSuppliedLattice
    (O : CVP.Oracle (Index (Fin rows) (Fin cols)) (Fin cols))
    (L : CVP.ExplicitLattice (Index (Fin rows) (Fin cols)) (Fin cols))
    (ciphertext : List UInt8) : Option (Bits cols) :=
  (Protocol.Storage.CoupledCiphertext.decodeReal rows cols ciphertext).map fun b col =>
    decide (0 < information (WithLp.toLp 2 (O L (WithLp.ofLp b))) col)

/-- The original fresh-sign ciphertext is an exact CVP recovery instance
when its operative lattice is supplied. -/
theorem knownLattice_recovers_bits
    (O : CVP.Oracle (Index (Fin rows) (Fin cols)) (Fin cols)) (correct : CVP.OracleCorrect O)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) (positive : 0 < d)
    (key message : Bits cols) :
    recoverWithSuppliedLattice O (CoupledCVP.graphLattice (presentation A key))
      (ciphertextBytes A d a key message) = some message := by
  unfold recoverWithSuppliedLattice ciphertextBytes
  rw [Protocol.Storage.CoupledCiphertext.decodeReal_sampleBytes,
    CoupledCVP.nativeSample_eq_encrypt]
  have recovered := CoupledCVP.correct_cvp_oracle_recovers_encrypt
    (presentation A key) O correct (coefficients d message)
    (HCPCoupledEncoding.integerNoise (presentation A key) a (opening A key message))
  simp only [Option.map_some, recovered, WithLp.toLp_ofLp, graphVector_information]
  congr 1
  funext col
  exact (Bool.decide_congr Int.cast_pos).trans (congrFun
    (NativeSignPrivacy.totalizeCoefficientGuess_of_correct
      some d positive (coefficients d message) message rfl) col)

/-- For a fixed ciphertext mask and a candidate sign key, the original
fresh-sign encoder gives the observed bytes for exactly one message. -/
theorem ciphertextBytes_eq_normalBytes_iff
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) (positive : 0 < d)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (key message masked : Bits cols) :
    ciphertextBytes A d a key message = normalBytes A d a masked ↔
      message = mask key masked := by
  have mask_cancel : mask key (mask key masked) = masked := by
    funext col
    change (key col == (key col == masked col)) = masked col
    cases key col <;> cases masked col <;> rfl
  have compatible : ciphertextBytes A d a key (mask key masked) = normalBytes A d a masked := by
    rw [ciphertextBytes_normal A d a orthogonal, mask_cancel]
  constructor
  · intro observed
    exact presentation_ciphertext_message_unique A d a positive key key message
      (mask key masked) rfl (observed.trans compatible.symm)
  · rintro rfl
    exact compatible

/-- Every Boolean message occurs for some candidate key at the same bytes. -/
theorem compatible_bits_eq_univ
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) (positive : 0 < d)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (masked : Bits cols) :
    {message | ∃ key, ciphertextBytes A d a key message = normalBytes A d a masked} = Set.univ := by
  ext message
  simp only [Set.mem_ofPred_eq, Set.mem_univ, iff_true]
  obtain ⟨key, hkey⟩ := (maskEquiv masked).surjective message
  exact ⟨key, (ciphertextBytes_eq_normalBytes_iff A d a positive orthogonal key message masked).mpr
    hkey.symm⟩

/-- The ciphertext alone is compatible with exactly `2^cols` distinct
original integer coefficient vectors in this family. -/
theorem compatible_coefficients_card
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) (positive : 0 < d)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (masked : Bits cols) :
    {z | ∃ key message, ciphertextBytes A d a key message = normalBytes A d a masked ∧
      coefficients d message = z}.ncard = 2 ^ cols := by
  have range_eq : (Set.range (fun key => coefficients d (mask key masked))) =
      {z | ∃ key message, ciphertextBytes A d a key message = normalBytes A d a masked ∧
        coefficients d message = z} := by
    ext z
    constructor
    · rintro ⟨key, rfl⟩
      exact ⟨key, mask key masked,
        (ciphertextBytes_eq_normalBytes_iff A d a positive orthogonal key _ masked).mpr rfl, rfl⟩
    · rintro ⟨key, message, sameBytes, sameCoefficients⟩
      have message_eq := (ciphertextBytes_eq_normalBytes_iff A d a positive orthogonal
        key message masked).mp sameBytes
      exact ⟨key, (congrArg (coefficients d) message_eq).symm.trans sameCoefficients⟩
  have injective : Function.Injective (fun key => coefficients d (mask key masked)) :=
    (coefficients_injective d positive).comp (maskEquiv masked).injective
  rw [← range_eq, Set.ncard_range_of_injective injective, Nat.card_eq_fintype_card]
  simp

/-- One correct CVP call resolves the candidate selected by the supplied
lattice at these same observed ciphertext bytes. -/
theorem knownLattice_recovers_masked_bits
    (O : CVP.Oracle (Index (Fin rows) (Fin cols)) (Fin cols)) (correct : CVP.OracleCorrect O)
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) (positive : 0 < d)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (key masked : Bits cols) :
    recoverWithSuppliedLattice O (CoupledCVP.graphLattice (presentation A key))
      (normalBytes A d a masked) = some (mask key masked) := by
  rw [← (ciphertextBytes_eq_normalBytes_iff A d a positive orthogonal key _ masked).mpr rfl]
  exact knownLattice_recovers_bits O correct A d a positive key (mask key masked)

/-- The intrinsic lattice viewed in the common scalar cochain space. -/
def embeddedHarmonicLattice (B : Matrix (Fin rows) (Fin cols) ℤ) :
    Set (HCPCoupledFamily.C1 (Fin rows) (Fin cols)) :=
  {v | v ∈ (integralStructure B).harmonicOneLattice}

/-- The compatible keys select different embedded intrinsic lattices.
Equality of the lattices would recover the same matrix by applying the graph
equations to the integer basis vectors. -/
theorem compatible_lattice_keys_injective
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) (positive : 0 < d)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (masked : Bits cols) :
    Function.Injective (fun key => embeddedHarmonicLattice (presentation A key)) := by
  intro first second sameLattice
  change embeddedHarmonicLattice (presentation A first) =
    embeddedHarmonicLattice (presentation A second) at sameLattice
  have samePresentation : presentation A first = presentation A second := by
    ext row col
    let e : Fin cols → ℤ := Pi.single col 1
    have cast_e : (fun c => (e c : ℝ)) = Pi.single col 1 := by
      funext c
      by_cases same : c = col <;> simp [e, same]
    have embeddedMem : graphVector (presentation A first) (Pi.single col 1) ∈
        embeddedHarmonicLattice (presentation A second) := by
      rw [← sameLattice, ← cast_e]
      exact ⟨graphVector_integral _ e, graphVector_harmonic _ _⟩
    have mem : graphVector (presentation A first) (Pi.single col 1) ∈
        (integralStructure (presentation A second)).harmonicOneLattice := embeddedMem
    have coordinate := ((harmonic_iff (presentation A second) _).mp
      (LinearMap.mem_ker.mp mem.2)).2 row
    simp [graphVector_parity, graphVector_information, Pi.single_apply] at coordinate
    exact_mod_cast coordinate
  apply (maskEquiv masked).injective
  exact presentation_ciphertext_message_unique A d a positive first second _ _ samePresentation
    (((ciphertextBytes_eq_normalBytes_iff A d a positive orthogonal first _ masked).mpr rfl).trans
      ((ciphertextBytes_eq_normalBytes_iff A d a positive orthogonal second _ masked).mpr rfl).symm)

/-- Exactly `2^cols` embedded intrinsic lattices occur among the compatible
sign-key candidates for the same ciphertext. -/
theorem compatible_lattices_card
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ) (positive : 0 < d)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (masked : Bits cols) :
    (Set.range (fun key => embeddedHarmonicLattice (presentation A key))).ncard = 2 ^ cols := by
  rw [Set.ncard_range_of_injective (compatible_lattice_keys_injective A d a positive orthogonal masked),
    Nat.card_eq_fintype_card]
  simp

/-- Quantitative recovery comparison on the same fresh-sign family.
The decoder may use the fixed correct CVP oracle to choose its entire oracle
program. Only the queries to the sampled public byte oracle are bounded. -/
theorem recovery_comparison
    (O : CVP.Oracle (Index (Fin rows) (Fin cols)) (Fin cols)) (correct : CVP.OracleCorrect O)
    (decoder : CVP.Oracle (Index (Fin rows) (Fin cols)) (Fin cols) → Decoder cols (Bits cols))
    {q : ℕ} (bounded : ∀ view, IsQueryBoundP (decoder O view) publicOnly q)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (positive : 0 < d)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ)) :
    (∀ key message : Bits cols,
      recoverWithSuppliedLattice O (CoupledCVP.graphLattice (presentation A key))
        (ciphertextBytes A d a key message) = some message) ∧
    realProbability (game (decoder O) base A d a) (fun outcome => outcome.2 = outcome.1) ≤
      (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols +
        ((q + 2 : ℕ) : ℝ≥0∞) * ((256 ^ 32 : ℕ) : ℝ≥0∞)⁻¹ :=
  ⟨knownLattice_recovers_bits O correct A d a positive,
    recovery_probability_le (decoder O) bounded base A d a orthogonal⟩

/-- The public decoder cannot recover with certainty whenever the numerical
query bound is strictly below one. -/
theorem strict_recovery_gap
    (O : CVP.Oracle (Index (Fin rows) (Fin cols)) (Fin cols)) (correct : CVP.OracleCorrect O)
    (decoder : CVP.Oracle (Index (Fin rows) (Fin cols)) (Fin cols) → Decoder cols (Bits cols))
    {q : ℕ} (bounded : ∀ view, IsQueryBoundP (decoder O view) publicOnly q)
    (base : NativeRelation.Witness rows cols) (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (positive : 0 < d)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (gap : (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols +
      ((q + 2 : ℕ) : ℝ≥0∞) * ((256 ^ 32 : ℕ) : ℝ≥0∞)⁻¹ < 1) :
    realProbability (game (decoder O) base A d a) (fun outcome => outcome.2 = outcome.1) < 1 :=
  (recovery_comparison O correct decoder bounded base A d a positive orthogonal).2.trans_lt gap

end HomotopicalEncryption.HCP.CoupledRecoverySeparation
