module

public import Consensus.Reliability
public import Gates.Spectral
public import Proximity.Projection

@[expose] public section

/-
  Proof of Value scoring contract.

  Paper correspondence:
  - Paper 2: conditional Proof-of-Value scoring and consensus policy.
  - This protocol scoring contract is distinct from Paper 3's coding-distance
    and radius theorems.

  PoV proves verifiable harmonic value:

    harmonic contribution × proximity quality × reliability

  The hard gates are admissibility predicates. They do not create bonus score.
  Proximity and reliability are discount-only multipliers.
-/

namespace HomotopicalEncryption
namespace Consensus

namespace ProofOfValue

/--
Smooth proximity-quality multiplier from a non-negative residual.

This is the consensus-side normalization of a proximity disagreement score:
it is fixed against the protocol radius `epsilon`, never against the current
validator distribution.
-/
noncomputable def proximityQualityFromDisagreement
    (residual epsilon : ℝ) : ℝ :=
  1 / (1 + residual / epsilon)

/-- Proximity quality derived from a generic sheaf proximity instance. -/
noncomputable def proximityQualityFromInstance
    (S : HomotopicalEncryption.Proximity.SheafProximityInstance)
    (c : S.Cochain)
    (epsilon : ℝ) : ℝ :=
  proximityQualityFromDisagreement (S.disagreement c) epsilon

/-- The smooth proximity-quality multiplier is bounded in `[0,1]`. -/
theorem proximityQualityFromDisagreement_bounded
    {residual epsilon : ℝ}
    (hResidual : 0 ≤ residual)
    (hEpsilon : 0 < epsilon) :
    0 ≤ proximityQualityFromDisagreement residual epsilon
      ∧ proximityQualityFromDisagreement residual epsilon ≤ 1 := by
  have hDivNonneg : 0 ≤ residual / epsilon :=
    div_nonneg hResidual (le_of_lt hEpsilon)
  have hDenPos : 0 < 1 + residual / epsilon := by nlinarith
  constructor
  · unfold proximityQualityFromDisagreement
    exact div_nonneg zero_le_one (le_of_lt hDenPos)
  · unfold proximityQualityFromDisagreement
    rw [div_le_iff₀ hDenPos]
    nlinarith

/-- Instance-level proximity quality is bounded when disagreement is non-negative. -/
theorem proximityQualityFromInstance_bounded
    (S : HomotopicalEncryption.Proximity.SheafProximityInstance)
    (c : S.Cochain)
    {epsilon : ℝ}
    (hDisagreement : 0 ≤ S.disagreement c)
    (hEpsilon : 0 < epsilon) :
    0 ≤ proximityQualityFromInstance S c epsilon
      ∧ proximityQualityFromInstance S c epsilon ≤ 1 :=
  proximityQualityFromDisagreement_bounded hDisagreement hEpsilon

end ProofOfValue

/-- Hard gates that must pass before a validator receives nonzero PoV score. -/
structure ProofOfValueGates where
  bondOk : Prop
  spectralOk : Prop
  proximityOk : Prop
  notSlashed : Prop

namespace ProofOfValueGates

/-- All hard gates pass. -/
def Passes (G : ProofOfValueGates) : Prop :=
  G.bondOk ∧ G.spectralOk ∧ G.proximityOk ∧ G.notSlashed

end ProofOfValueGates

/--
Inputs to the conservative PoV scoring rule.

The three numeric fields are already normalized to `[0,1]` by their
corresponding gate/oracle/runtime paths.
-/
structure ProofOfValueInput where
  gates : ProofOfValueGates
  harmonicContribution : ℝ
  proximityQuality : ℝ
  reliability : ℝ
  harmonic_bounded : 0 ≤ harmonicContribution ∧ harmonicContribution ≤ 1
  proximity_bounded : 0 ≤ proximityQuality ∧ proximityQuality ≤ 1
  reliability_bounded : 0 ≤ reliability ∧ reliability ≤ 1

namespace ProofOfValueInput

/-- Verifiable harmonic value. Ineligible validators receive zero score. -/
noncomputable def score (v : ProofOfValueInput) : ℝ := by
  classical
  exact
    if v.gates.Passes then
      v.harmonicContribution * v.proximityQuality * v.reliability
    else
      0

/-- Score without the reliability discount. -/
noncomputable def scoreWithoutReliability (v : ProofOfValueInput) : ℝ := by
  classical
  exact
    if v.gates.Passes then
      v.harmonicContribution * v.proximityQuality
    else
      0

/-- Score without the proximity discount. -/
noncomputable def scoreWithoutProximity (v : ProofOfValueInput) : ℝ := by
  classical
  exact
    if v.gates.Passes then
      v.harmonicContribution * v.reliability
    else
      0

/-- If a hard gate fails, the PoV score is zero. -/
theorem score_eq_zero_of_not_passes
    (v : ProofOfValueInput)
    (h : ¬ v.gates.Passes) :
    v.score = 0 := by
  unfold score
  simp [h]

/-- If all hard gates pass, score is `H * P * R`. -/
theorem score_eq_product_of_passes
    (v : ProofOfValueInput)
    (h : v.gates.Passes) :
    v.score = v.harmonicContribution * v.proximityQuality * v.reliability := by
  unfold score
  simp [h]

/-- PoV score is non-negative. -/
theorem score_nonneg (v : ProofOfValueInput) :
    0 ≤ v.score := by
  classical
  by_cases h : v.gates.Passes
  · rw [score_eq_product_of_passes v h]
    nlinarith [
      v.harmonic_bounded.1,
      v.proximity_bounded.1,
      v.reliability_bounded.1,
      mul_nonneg v.harmonic_bounded.1 v.proximity_bounded.1,
      mul_nonneg (mul_nonneg v.harmonic_bounded.1 v.proximity_bounded.1)
        v.reliability_bounded.1]
  · rw [score_eq_zero_of_not_passes v h]

private theorem product_le_first_of_factors_le_one
    {a b c : ℝ}
    (ha0 : 0 ≤ a)
    (hb1 : b ≤ 1)
    (hc0 : 0 ≤ c) (hc1 : c ≤ 1) :
    a * b * c ≤ a := by
  have hbc_le_c : b * c ≤ 1 * c :=
    mul_le_mul_of_nonneg_right hb1 hc0
  have hbc_le_one : b * c ≤ 1 := by nlinarith
  have hmain : a * (b * c) ≤ a * 1 :=
    mul_le_mul_of_nonneg_left hbc_le_one ha0
  calc
    a * b * c = a * (b * c) := by ring
    _ ≤ a * 1 := hmain
    _ = a := by ring

/-- Score is bounded by harmonic contribution: discounts cannot create value. -/
theorem score_le_harmonicContribution (v : ProofOfValueInput) :
    v.score ≤ v.harmonicContribution := by
  classical
  by_cases h : v.gates.Passes
  · rw [score_eq_product_of_passes v h]
    exact product_le_first_of_factors_le_one
      v.harmonic_bounded.1
      v.proximity_bounded.2
      v.reliability_bounded.1 v.reliability_bounded.2
  · rw [score_eq_zero_of_not_passes v h]
    exact v.harmonic_bounded.1

/-- Score is bounded by proximity quality. -/
theorem score_le_proximityQuality (v : ProofOfValueInput) :
    v.score ≤ v.proximityQuality := by
  classical
  by_cases h : v.gates.Passes
  · rw [score_eq_product_of_passes v h]
    calc
      v.harmonicContribution * v.proximityQuality * v.reliability
          = v.proximityQuality * v.harmonicContribution * v.reliability := by ring
      _ ≤ v.proximityQuality :=
          product_le_first_of_factors_le_one
            v.proximity_bounded.1
            v.harmonic_bounded.2
            v.reliability_bounded.1 v.reliability_bounded.2
  · rw [score_eq_zero_of_not_passes v h]
    exact v.proximity_bounded.1

/-- Score is bounded by reliability. -/
theorem score_le_reliability (v : ProofOfValueInput) :
    v.score ≤ v.reliability := by
  classical
  by_cases h : v.gates.Passes
  · rw [score_eq_product_of_passes v h]
    calc
      v.harmonicContribution * v.proximityQuality * v.reliability
          = v.reliability * v.harmonicContribution * v.proximityQuality := by ring
      _ ≤ v.reliability :=
          product_le_first_of_factors_le_one
            v.reliability_bounded.1
            v.harmonic_bounded.2
            v.proximity_bounded.1 v.proximity_bounded.2
  · rw [score_eq_zero_of_not_passes v h]
    exact v.reliability_bounded.1

/-- PoV score is always at most one. -/
theorem score_le_one (v : ProofOfValueInput) :
    v.score ≤ 1 :=
  le_trans (score_le_harmonicContribution v) v.harmonic_bounded.2

/-- Reliability is discount-only: adding it cannot increase score. -/
theorem score_le_scoreWithoutReliability (v : ProofOfValueInput) :
    v.score ≤ v.scoreWithoutReliability := by
  classical
  by_cases h : v.gates.Passes
  · unfold score scoreWithoutReliability
    simp [h]
    have hmain :
        v.harmonicContribution * v.proximityQuality * v.reliability
          ≤ v.harmonicContribution * v.proximityQuality * 1 := by
      have hHPNonneg :
          0 ≤ v.harmonicContribution * v.proximityQuality :=
        mul_nonneg v.harmonic_bounded.1 v.proximity_bounded.1
      exact mul_le_mul_of_nonneg_left v.reliability_bounded.2 hHPNonneg
    nlinarith
  · unfold score scoreWithoutReliability
    simp [h]

/-- Proximity is discount-only: adding it cannot increase score. -/
theorem score_le_scoreWithoutProximity (v : ProofOfValueInput) :
    v.score ≤ v.scoreWithoutProximity := by
  classical
  by_cases h : v.gates.Passes
  · unfold score scoreWithoutProximity
    simp [h]
    calc
      v.harmonicContribution * v.proximityQuality * v.reliability
          = (v.harmonicContribution * v.reliability) * v.proximityQuality := by ring
      _ ≤ (v.harmonicContribution * v.reliability) * 1 := by
          have hHRNonneg :
              0 ≤ v.harmonicContribution * v.reliability :=
            mul_nonneg v.harmonic_bounded.1 v.reliability_bounded.1
          exact mul_le_mul_of_nonneg_left v.proximity_bounded.2 hHRNonneg
      _ = v.harmonicContribution * v.reliability := by ring
  · unfold score scoreWithoutProximity
    simp [h]

end ProofOfValueInput

end Consensus
end HomotopicalEncryption
