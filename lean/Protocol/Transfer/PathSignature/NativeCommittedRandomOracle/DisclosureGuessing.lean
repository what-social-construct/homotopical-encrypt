module

public import HCP.FiniteRecovery
public import Protocol.Transfer.PathSignature.NativeCommittedRandomOracle.Guessing
public import VCVio.OracleComp.EvalDist.Sum

@[expose] public section

/-!
# Uniform guessing with deterministic disclosure

An oracle computation may adapt to the disclosed value and all subsequent
oracle answers. For each fixed disclosure value its output law is a single
probability distribution, so summing the masses of its distinct possible
targets contributes at most one uniform-key share.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRandomOracle

open OracleComp
open scoped BigOperators ENNReal

variable {cols : ℕ} {Advice : Type*} {Output : Type}

/-- Each realized deterministic disclosure permits at most one
uniform-key share of exact guessing probability. -/
theorem uniform_guess_with_disclosure_range_le (disclose : Bits cols → Advice)
    (target : Bits cols → Output) (injective : Function.Injective target)
    (guess : Advice → ProbComp Output) :
    Pr{let key ← $ᵗ (Bits cols); let result ← guess (disclose key)}[result = target key] ≤
      (HCP.FiniteRecovery.disclosedViews disclose).card / (2 : ℝ≥0∞) ^ cols := by
  classical
  let views := HCP.FiniteRecovery.disclosedViews disclose
  let weight (view : Advice) (key : Bits cols) : ℝ≥0∞ :=
    Pr{let candidate ← $ᵗ (Bits cols)}[candidate = key] *
      Pr{let result ← guess view}[result = target key]
  have weight_sum_le (view : Advice) : ∑ key, weight view key ≤
      (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols := by
    have output_sum : ∑ key, Pr{let result ← guess view}[result = target key] ≤ 1 := by
      calc
        _ = ∑ output ∈ Finset.univ.image target, Pr{let result ← guess view}[result = output] := by
          rw [Finset.sum_image injective.injOn]
        _ ≤ ∑' output, Pr{let result ← guess view}[result = output] := ENNReal.sum_le_tsum _
        _ = 1 := OracleComp.tsum_prEvent_eq_one (guess view)
    simp only [weight, SampleableType.prEvent_uniformSample_eq_singleton, ← Finset.mul_sum]
    simpa [Bits, one_div] using
      (mul_le_of_le_one_right' (a := (Fintype.card (Bits cols) : ℝ≥0∞)⁻¹) output_sum)
  calc
    _ = ∑ key, weight (disclose key) key := by
      rw [OracleComp.prEvent_bind_eq_tsum_prEvent, tsum_fintype]
    _ ≤ ∑ key, ∑ view ∈ views, weight view key := by
      apply Finset.sum_le_sum
      intro key _
      exact Finset.single_le_sum (f := fun view => weight view key) (fun _ _ => zero_le)
        ((HCP.FiniteRecovery.mem_disclosedViews disclose (disclose key)).2 ⟨key, rfl⟩)
    _ = ∑ view ∈ views, ∑ key, weight view key := Finset.sum_comm
    _ ≤ ∑ _ ∈ views, (1 : ℝ≥0∞) / (2 : ℝ≥0∞) ^ cols :=
      Finset.sum_le_sum fun view _ => weight_sum_le view
    _ = _ := by simp [views, nsmul_eq_mul, div_eq_mul_inv]

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRandomOracle
