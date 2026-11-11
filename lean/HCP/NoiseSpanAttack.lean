module

public import Sheaf.CoefficientRecovery
public import Mathlib.LinearAlgebra.Span.Basic

@[expose] public section

/-!
# Conditional fixed-key noise-span separation

The public span below is computed from observed zero-message Hodge encryptions
under one fixed cellular sheaf. Every such observation lies in the orthogonal
complement of its harmonic space. If the collected observations span that
complement, membership separates every further zero-message observation from
every nonzero presented harmonic message, regardless of its structured noise.

This is an exact, deterministic conditional statement. It does not provide a
finite ciphertext codec, a rank algorithm, a noise distribution, a sample
bound, or an IND/security theorem.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.HCP.NoiseSpanAttack

open Sheaf CellularSheaf

variable {Vertex Edge Face Rank : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face] [Fintype Rank]
  {X : OrientedTwoComplex Vertex Edge Face}
  {F : CellularSheaf X} {I : IntegralStructure F}

/-- The presented zero coefficient vector is the zero harmonic cochain. -/
theorem point_zero (H : HarmonicLatticePresentation I Rank) :
    (H.point 0).1 = 0 := by
  apply PiLp.ext
  intro coordinate
  simp [HarmonicLatticePresentation.point, CVP.latticeVector,
    Matrix.mulVec, dotProduct]

/-- A nonzero coefficient vector gives a nonzero presented harmonic message. -/
theorem point_ne_zero (H : HarmonicLatticePresentation I Rank)
    (z : Rank → ℤ) (hz : z ≠ 0) : (H.point z).1 ≠ 0 := by
  intro hpoint
  apply hz
  apply H.point_injective
  apply Subtype.ext
  exact hpoint.trans (point_zero H).symm

/-- Actual ciphertexts obtained by encrypting zero with collected openings. -/
def observedZeros {k : ℕ} (H : HarmonicLatticePresentation I Rank)
    (openings : Fin k → HodgeNoise F) : Fin k → F.C1 :=
  fun i => (H.encrypt 0 (openings i)).observed

/-- A test space specified entirely by the observed cochain columns. -/
def publicSpan {k : ℕ} (columns : Fin k → F.C1) : Submodule ℝ F.C1 :=
  Submodule.span ℝ (Set.range columns)

/-- The original zero-message encryptor observes precisely structured noise. -/
theorem encrypt_zero_observed (H : HarmonicLatticePresentation I Rank)
    (opening : HodgeNoise F) :
    (H.encrypt 0 opening).observed = opening.value := by
  change (H.point 0).1 + opening.value = opening.value
  rw [point_zero]
  exact zero_add _

/-- Collected public zero ciphertexts lie in the true noise subspace. -/
theorem publicSpan_observedZeros_le {k : ℕ}
    (H : HarmonicLatticePresentation I Rank)
    (openings : Fin k → HodgeNoise F) :
    publicSpan (observedZeros H openings) ≤
      F.harmonicOneSubspace.orthogonal := by
  apply Submodule.span_le.mpr
  rintro b ⟨i, rfl⟩
  rw [observedZeros, encrypt_zero_observed]
  exact (openings i).value_mem_harmonic_orthogonal

/-- If the observed zero samples span all noise, every fresh zero sample tests in. -/
theorem encrypt_zero_mem_of_spans {k : ℕ}
    (H : HarmonicLatticePresentation I Rank)
    (openings : Fin k → HodgeNoise F)
    (spans : publicSpan (observedZeros H openings) =
      F.harmonicOneSubspace.orthogonal)
    (fresh : HodgeNoise F) :
    (H.encrypt 0 fresh).observed ∈ publicSpan (observedZeros H openings) := by
  rw [spans, encrypt_zero_observed]
  exact fresh.value_mem_harmonic_orthogonal

/-- A nonzero harmonic ciphertext never lies in the zero-ciphertext span. -/
theorem encrypt_nonzero_not_mem {k : ℕ}
    (H : HarmonicLatticePresentation I Rank)
    (openings : Fin k → HodgeNoise F)
    (z : Rank → ℤ) (hz : z ≠ 0) (fresh : HodgeNoise F) :
    (H.encrypt z fresh).observed ∉ publicSpan (observedZeros H openings) := by
  intro hmem
  have horth : (H.encrypt z fresh).observed ∈
      F.harmonicOneSubspace.orthogonal :=
    publicSpan_observedZeros_le H openings hmem
  have hprojection : F.harmonicOneProjection (H.encrypt z fresh).observed = 0 :=
    (F.harmonicOneSubspace.starProjection_apply_eq_zero_iff).mpr horth
  rw [H.encrypt_projection_eq_point] at hprojection
  exact point_ne_zero H z hz hprojection

/-- Membership in the public span distinguishes zero from nonzero under the
declared spanning condition, using the same fixed key and actual encryptor. -/
theorem publicSpan_separates {k : ℕ}
    (H : HarmonicLatticePresentation I Rank)
    (openings : Fin k → HodgeNoise F)
    (spans : publicSpan (observedZeros H openings) =
      F.harmonicOneSubspace.orthogonal)
    (z : Rank → ℤ) (hz : z ≠ 0)
    (zeroOpening nonzeroOpening : HodgeNoise F) :
    (H.encrypt 0 zeroOpening).observed ∈ publicSpan (observedZeros H openings) ∧
    (H.encrypt z nonzeroOpening).observed ∉ publicSpan (observedZeros H openings) :=
  ⟨encrypt_zero_mem_of_spans H openings spans zeroOpening,
    encrypt_nonzero_not_mem H openings z hz nonzeroOpening⟩

end HomotopicalEncryption.HCP.NoiseSpanAttack
