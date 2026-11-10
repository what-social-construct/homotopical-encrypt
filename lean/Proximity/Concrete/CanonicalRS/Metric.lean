module

public import Proximity.Concrete.CanonicalRS.Target
public import Mathlib.Algebra.Order.Archimedean.Real.Basic

@[expose] public section

/-
  Canonical received-word metric and radius normalization.

  Paper correspondence:
  - Paper 3: received-word distance normalization and the canonical
    Johnson-radius comparison.
  - The source metric and protocol interpretation remain explicit inputs;
    equal names do not identify other cochain or HCP distances.

  The verifier-facing metric is relative Hamming distance from a received word
  to the RS code. Absolute Hamming distance remains as a low-level finite
  helper; the bridge exposes the normalized `δ ∈ [0,1]` convention used by the
  proximity-prize statements.
-/

namespace Hcrypt
namespace Proximity
namespace CanonicalRS

noncomputable section

/-- The zero word is an RS codeword for the canonical parameter regime. -/
theorem zeroWord_codeword (D : SmoothDomain) :
    D.parameters.Codeword (fun _ : Fin length => (0 : RSField)) := by
  refine ⟨0, ?_, ?_⟩
  · simp [SmoothDomain.parameters, degreeBound]
  · intro i
    simp

/-- Real-valued Hamming distance between two canonical RS words. -/
def hammingDistanceReal
    (u v : Word (Fin length) RSField) :
    ℝ :=
  (BlockCode.hammingDistance u v : ℝ)

/-- Relative Hamming distance between two canonical RS words. -/
def relativeHammingDistanceReal
    (u v : Word (Fin length) RSField) :
    ℝ :=
  hammingDistanceReal u v / (length : ℝ)

/--
The set of real Hamming distances from a received word to canonical RS
codewords.
-/
def codewordDistanceSet
    (D : SmoothDomain)
    (B : Bounds D)
    (w : Word (Fin length) RSField) :
    Set ℝ :=
  {d | ∃ c : Word (Fin length) RSField,
    (target D B).parameters.Codeword c ∧ d = hammingDistanceReal c w}

/-- The distance set is nonempty, because the zero RS codeword is present. -/
theorem codewordDistanceSet_nonempty
    (D : SmoothDomain)
    (B : Bounds D)
    (w : Word (Fin length) RSField) :
    (codewordDistanceSet D B w).Nonempty := by
  refine ⟨hammingDistanceReal (fun _ : Fin length => (0 : RSField)) w, ?_⟩
  exact ⟨fun _ : Fin length => (0 : RSField), by
    simpa [target] using zeroWord_codeword D, rfl⟩

/-- The distance set is bounded below by zero. -/
theorem codewordDistanceSet_bddBelow
    (D : SmoothDomain)
    (B : Bounds D)
    (w : Word (Fin length) RSField) :
    BddBelow (codewordDistanceSet D B w) := by
  refine ⟨0, ?_⟩
  intro d hd
  rcases hd with ⟨c, _hc, rfl⟩
  exact Nat.cast_nonneg _

/-- Absolute Hamming distance from a received word to the canonical RS code. -/
def hammingDistanceToCode
    (D : SmoothDomain)
    (B : Bounds D)
    (w : Word (Fin length) RSField) :
    ℝ :=
  sInf (codewordDistanceSet D B w)

/-- The distance to code is nonnegative. -/
theorem hammingDistanceToCode_nonneg
    (D : SmoothDomain)
    (B : Bounds D)
    (w : Word (Fin length) RSField) :
    0 ≤ hammingDistanceToCode D B w := by
  unfold hammingDistanceToCode
  exact Real.sInf_nonneg (by
    intro d hd
    rcases hd with ⟨c, _hc, rfl⟩
    exact Nat.cast_nonneg _)

/-- The distance to code is bounded by distance to any concrete codeword. -/
theorem hammingDistanceToCode_le_of_codeword
    (D : SmoothDomain)
    (B : Bounds D)
    {w c : Word (Fin length) RSField}
    (hc : (target D B).parameters.Codeword c) :
    hammingDistanceToCode D B w ≤ hammingDistanceReal c w := by
  unfold hammingDistanceToCode
  exact csInf_le
    (codewordDistanceSet_bddBelow D B w)
    ⟨c, hc, rfl⟩

/-- Exact RS codewords have zero Hamming distance to the RS code. -/
theorem hammingDistanceToCode_eq_zero_of_codeword
    (D : SmoothDomain)
    (B : Bounds D)
    {w : Word (Fin length) RSField}
    (hw : (target D B).parameters.Codeword w) :
    hammingDistanceToCode D B w = 0 := by
  apply le_antisymm
  · have hle := hammingDistanceToCode_le_of_codeword D B (w := w) (c := w) hw
    have hdist : hammingDistanceReal w w = 0 := by
      unfold hammingDistanceReal BlockCode.hammingDistance
      change
        (((Finset.univ.filter fun i : Fin length => w i ≠ w i).card : ℕ) : ℝ) = 0
      simp
    simpa [hdist] using hle
  · exact hammingDistanceToCode_nonneg D B w

/-- Hamming-close received words have bounded distance to the RS code. -/
theorem hammingDistanceToCode_le_of_close
    (D : SmoothDomain)
    (B : Bounds D)
    {r : ℕ}
    {w : Word (Fin length) RSField}
    (hw : (target D B).parameters.toBlockCode.Close r w) :
    hammingDistanceToCode D B w ≤ (r : ℝ) := by
  rcases hw with ⟨c, hc, hd⟩
  exact le_trans
    (hammingDistanceToCode_le_of_codeword D B (w := w) (c := c) hc)
    (by
      unfold hammingDistanceReal
      exact_mod_cast hd)

/-- Relative Hamming distance from a received word to the canonical RS code. -/
def relativeHammingDistanceToCode
    (D : SmoothDomain)
    (B : Bounds D)
    (w : Word (Fin length) RSField) :
    ℝ :=
  hammingDistanceToCode D B w / (length : ℝ)

/-- Exact RS codewords have zero relative Hamming distance to the RS code. -/
theorem relativeHammingDistanceToCode_eq_zero_of_codeword
    (D : SmoothDomain)
    (B : Bounds D)
    {w : Word (Fin length) RSField}
    (hw : (target D B).parameters.Codeword w) :
    relativeHammingDistanceToCode D B w = 0 := by
  simp [relativeHammingDistanceToCode,
    hammingDistanceToCode_eq_zero_of_codeword D B hw]

/-- Hamming-close received words have bounded relative distance to the RS code. -/
theorem relativeHammingDistanceToCode_le_of_close
    (D : SmoothDomain)
    (B : Bounds D)
    {r : ℕ}
    {w : Word (Fin length) RSField}
    (hw : (target D B).parameters.toBlockCode.Close r w) :
    relativeHammingDistanceToCode D B w ≤
      ReedSolomonTarget.Target.RadiusNormalization.relativeHammingRadius
        (ι := Fin length) r := by
  have h :
      hammingDistanceToCode D B w / (length : ℝ) ≤
        (r : ℝ) / (length : ℝ) :=
    div_le_div_of_nonneg_right
      (hammingDistanceToCode_le_of_close D B hw)
      (Nat.cast_nonneg length)
  unfold relativeHammingDistanceToCode
  unfold ReedSolomonTarget.Target.RadiusNormalization.relativeHammingRadius
  unfold ProximityPrize.BlockCode.relativeRadius
  simpa only [Fintype.card_fin] using h

/-- Canonical relative Hamming received-word metric. -/
def relativeHammingMetric
    (D : SmoothDomain)
    (B : Bounds D) :
    ReedSolomonTarget.Target.ReceivedWordMetric (target D B) where
  distanceToRS w := relativeHammingDistanceToCode D B w
  codeword_zero_distance := by
    intro w hw
    exact relativeHammingDistanceToCode_eq_zero_of_codeword D B hw

/-- Relative-Hamming radius normalization for the canonical metric. -/
def relativeRadiusNormalization
    (D : SmoothDomain)
    (B : Bounds D) :
    ReedSolomonTarget.Target.RadiusNormalization (relativeHammingMetric D B) :=
  ReedSolomonTarget.Target.RadiusNormalization.relative
    (relativeHammingMetric D B)
    (by
      intro r w hw
      change
        relativeHammingDistanceToCode D B w ≤
          ReedSolomonTarget.Target.RadiusNormalization.relativeHammingRadius
            (ι := Fin length) r
      exact relativeHammingDistanceToCode_le_of_close D B hw)

end

end CanonicalRS
end Proximity
end Hcrypt
