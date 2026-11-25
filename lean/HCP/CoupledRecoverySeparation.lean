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
