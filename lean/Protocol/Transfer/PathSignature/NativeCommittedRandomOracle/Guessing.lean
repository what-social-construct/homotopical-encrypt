module

public import Protocol.Transfer.PathSignature.NativeSignPrivacy
public import VCVio.OracleComp.Constructions.SampleableType.Measure
public import VCVio.OracleComp.EvalDist.Measure

@[expose] public section

/-!
# Uniform guessing and mask reindexing for the native oracle game

These probability identities concern the existing finite Boolean messages.
An arbitrary probabilistic guess sampled independently of a uniform message
matches it with inverse-cardinality probability. The original sign mask
permutes the uniform key law before every probabilistic continuation.
No random-oracle security premise or private-state release is added here.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRandomOracle

open OracleComp MeasureTheory
open scoped ENNReal

/-- The original finite Boolean message and sign-key coordinates. -/
abbrev Bits (cols : ℕ) := Fin cols → Bool

variable {cols : ℕ}

/-- An independently generated guess, followed by a uniform target, matches
the complete original bit vector with inverse-cardinality mass. -/
theorem uniform_guess_probability_after (guess : ProbComp (Bits cols)) :
    Pr{let value ← guess; let message ← $ᵗ (Bits cols)}[value = message] =
      (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols := by
  let : MeasurableSpace (Bits cols) := ⊤
  change prEvent (guess >>= fun value =>
    (fun message => value = message) <$> ($ᵗ (Bits cols))) = _
  rw [prEvent_bind_of_discrete]
  simp_rw [SampleableType.prEvent_uniformSample_eq_singleton']
  rw [lintegral_const, OracleComp.evalDist_apply_univ_eq_one, mul_one]
  simp [Bits]

/-- Sampling the uniform target first gives the same guessing probability
when the probabilistic guess does not take that target as an input. -/
theorem uniform_guess_probability (guess : ProbComp (Bits cols)) :
    Pr{let message ← $ᵗ (Bits cols); let value ← guess}[value = message] =
      (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols := by
  rw [OracleComp.prEvent_bind_map_swap]
  exact uniform_guess_probability_after guess

/-- An independent partial integer-coefficient output can only recover the
encoded uniform target when its existing threshold totalizer guesses the
same original bit vector. -/
theorem uniform_partial_coeff_probability (d : ℤ) (positive : 0 < d)
    (guess : ProbComp (Option (Fin cols → ℤ))) :
    Pr{let message ← $ᵗ (Bits cols); let output ← guess}[
      output = some (NativeSignSampler.coefficients d message)] ≤
      (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols := by
  let totalizer : Option (Fin cols → ℤ) → Bits cols :=
    NativeSignPrivacy.totalizeCoefficientGuess (fun output => output)
  have included :
      Pr{let message ← $ᵗ (Bits cols); let output ← guess}[
        output = some (NativeSignSampler.coefficients d message)] ≤
      Pr{let message ← $ᵗ (Bits cols); let output ← guess}[totalizer output = message] := by
    have pointwise := prEvent_mono
      (do let message ← $ᵗ (Bits cols)
          let output ← guess
          pure (message, output))
      (fun result => result.2 = some (NativeSignSampler.coefficients d result.1))
      (fun result => totalizer result.2 = result.1)
      (fun result correct => NativeSignPrivacy.totalizeCoefficientGuess_of_correct
        (fun output => output) d positive result.2 result.1 correct)
    simpa only [map_bind, map_pure, bind_pure_comp, Functor.map_map, Function.comp_def]
      using pointwise
  calc
    _ ≤ _ := included
    _ = _ := by
      simpa only [Functor.map_map, Function.comp_def] using
        (uniform_guess_probability (totalizer <$> guess))

/-- Reindex the existing uniform key by its actual fixed-message mask before
any probabilistic continuation. -/
theorem uniform_mask_bind {α : Type} (message : Bits cols)
    (continuation : Bits cols → ProbComp α) :
    (do let key ← $ᵗ (Bits cols)
        continuation (NativeSignSampler.mask key message)) =ᵈ
      (do let masked ← $ᵗ (Bits cols)
          continuation masked) := by
  let : MeasurableSpace (Bits cols) := ⊤
  let : MeasurableSpace α := ⊤
  apply EvalDistEq.of_evalDist_eq
  exact evalDist_bind_bijective_of_uniform ($ᵗ (Bits cols))
    SampleableType.evalDist_uniformSample
    (NativeSignSampler.maskEquiv message)
    (NativeSignSampler.maskEquiv message).bijective continuation

/-- The measure form permits rewriting a surrounding oracle-game probability. -/
theorem uniform_mask_bind_evalDist {α : Type} [MeasurableSpace α]
    (message : Bits cols) (continuation : Bits cols → ProbComp α) :
    𝒟[do let key ← $ᵗ (Bits cols)
         continuation (NativeSignSampler.mask key message)] =
      𝒟[do let masked ← $ᵗ (Bits cols)
           continuation masked] :=
  (uniform_mask_bind message continuation).evalDist_eq

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRandomOracle
