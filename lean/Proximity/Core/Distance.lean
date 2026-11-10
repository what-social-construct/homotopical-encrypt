module

public import Proximity.Core.BlockCode
public import Mathlib.Order.Lattice.Nat

@[expose] public section

/-!
# Minimum distance to a nonempty block code

The minimum is taken over natural Hamming counts, so it is attained even when
the alphabet or the code is infinite. Statements about the distance semantics
explicitly require a nonempty code. Relative distance uses the existing block
length normalization and the same whole-symbol Hamming count as `CloseAt`.
-/

namespace ProximityCoding
namespace BlockCode

variable {ι α : Type*} [Fintype ι] [DecidableEq α]

@[simp]
theorem hammingDistance_self (w : Word ι α) : hammingDistance w w = 0 := by
  simp [hammingDistance]

theorem hammingDistance_le_length (u v : Word ι α) :
    hammingDistance u v ≤ Fintype.card ι := by
  exact (Finset.card_filter_le _ _).trans_eq (Finset.card_univ)

theorem hammingDistance_eq_zero_iff (u v : Word ι α) :
    hammingDistance u v = 0 ↔ u = v := by
  constructor
  · intro h
    have hempty : (Finset.univ.filter fun i => u i ≠ v i) = ∅ :=
      Finset.card_eq_zero.mp h
    funext i
    by_contra hi
    have hmem : i ∈ (Finset.univ.filter fun a => u a ≠ v a) := by
      simp [hi]
    rw [hempty] at hmem
    exact Finset.notMem_empty i hmem
  · rintro rfl
    exact hammingDistance_self u

/-- Hamming counts realized by codewords around the given received word. -/
def codewordDistanceSet (C : BlockCode ι α) (w : Word ι α) : Set ℕ :=
  {d | ∃ c : Word ι α, C.Codeword c ∧ d = hammingDistance c w}

/-- Least Hamming count. Its minimum semantics requires a nonempty code. -/
noncomputable def hammingDistanceToCode
    (C : BlockCode ι α) (w : Word ι α) : ℕ :=
  sInf (C.codewordDistanceSet w)

/-- Minimum relative Hamming distance to the same block-code locus. -/
noncomputable def relativeDistanceToCode
    (C : BlockCode ι α) (w : Word ι α) : ℝ :=
  (C.hammingDistanceToCode w : ℝ) / (Fintype.card ι : ℝ)

theorem codewordDistanceSet_nonempty
    (C : BlockCode ι α) (hC : ∃ c, C.Codeword c) (w : Word ι α) :
    (C.codewordDistanceSet w).Nonempty := by
  obtain ⟨c, hc⟩ := hC
  exact ⟨hammingDistance c w, c, hc, rfl⟩

/-- The discrete minimum is attained; finiteness of the alphabet is unnecessary. -/
theorem exists_nearest_codeword
    (C : BlockCode ι α) (hC : ∃ c, C.Codeword c) (w : Word ι α) :
    ∃ c, C.Codeword c ∧ C.hammingDistanceToCode w = hammingDistance c w :=
  Nat.sInf_mem (C.codewordDistanceSet_nonempty hC w)

theorem hammingDistanceToCode_le_of_codeword
    (C : BlockCode ι α) {w c : Word ι α} (hc : C.Codeword c) :
    C.hammingDistanceToCode w ≤ hammingDistance c w :=
  Nat.sInf_le ⟨c, hc, rfl⟩

theorem close_iff_hammingDistanceToCode_le
    (C : BlockCode ι α) (hC : ∃ c, C.Codeword c)
    (r : ℕ) (w : Word ι α) :
    C.Close r w ↔ C.hammingDistanceToCode w ≤ r := by
  constructor
  · rintro ⟨c, hc, hd⟩
    exact (C.hammingDistanceToCode_le_of_codeword hc).trans hd
  · intro h
    obtain ⟨c, hc, hd⟩ := C.exists_nearest_codeword hC w
    exact ⟨c, hc, hd ▸ h⟩

theorem hammingDistanceToCode_le_length
    (C : BlockCode ι α) (hC : ∃ c, C.Codeword c) (w : Word ι α) :
    C.hammingDistanceToCode w ≤ Fintype.card ι := by
  obtain ⟨c, hc⟩ := hC
  exact (C.hammingDistanceToCode_le_of_codeword hc).trans
    (hammingDistance_le_length c w)

theorem hammingDistanceToCode_eq_zero_iff
    (C : BlockCode ι α) (hC : ∃ c, C.Codeword c) (w : Word ι α) :
    C.hammingDistanceToCode w = 0 ↔ C.Codeword w := by
  constructor
  · intro h
    obtain ⟨c, hc, hd⟩ := C.exists_nearest_codeword hC w
    have hcw : c = w := (hammingDistance_eq_zero_iff c w).mp (hd.symm.trans h)
    exact hcw ▸ hc
  · intro hw
    exact Nat.eq_zero_of_le_zero (by
      simpa only [hammingDistance_self] using
        C.hammingDistanceToCode_le_of_codeword (w := w) hw)

theorem relativeDistanceToCode_nonneg (C : BlockCode ι α) (w : Word ι α) :
    0 ≤ C.relativeDistanceToCode w := by
  exact div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)

theorem relativeDistanceToCode_le_of_codeword
    (C : BlockCode ι α) {w c : Word ι α} (hc : C.Codeword c) :
    C.relativeDistanceToCode w ≤ relativeHammingDistance c w := by
  exact div_le_div_of_nonneg_right
    (by exact_mod_cast C.hammingDistanceToCode_le_of_codeword (w := w) hc)
    (Nat.cast_nonneg _)

theorem exists_nearest_codeword_relative
    (C : BlockCode ι α) (hC : ∃ c, C.Codeword c) (w : Word ι α) :
    ∃ c, C.Codeword c ∧ C.relativeDistanceToCode w = relativeHammingDistance c w := by
  obtain ⟨c, hc, hd⟩ := C.exists_nearest_codeword hC w
  exact ⟨c, hc, by simp only [relativeDistanceToCode, relativeHammingDistance, hd]⟩

/-- Closed relative balls use exactly the attained minimum-distance predicate. -/
theorem closeAt_iff_relativeDistanceToCode_le
    (C : BlockCode ι α) (hC : ∃ c, C.Codeword c) (δ : ℝ) (w : Word ι α) :
    C.CloseAt δ w ↔ C.relativeDistanceToCode w ≤ δ := by
  constructor
  · rintro ⟨c, hc, hd⟩
    exact (C.relativeDistanceToCode_le_of_codeword hc).trans hd
  · intro h
    obtain ⟨c, hc, hd⟩ := C.exists_nearest_codeword_relative hC w
    exact ⟨c, hc, hd ▸ h⟩

/-- Strict nearness has an actual nearest-codeword witness, including grid endpoints. -/
theorem relativeDistanceToCode_lt_iff
    (C : BlockCode ι α) (hC : ∃ c, C.Codeword c) (δ : ℝ) (w : Word ι α) :
    C.relativeDistanceToCode w < δ ↔
      ∃ c, C.Codeword c ∧ relativeHammingDistance c w < δ := by
  constructor
  · intro h
    obtain ⟨c, hc, hd⟩ := C.exists_nearest_codeword_relative hC w
    exact ⟨c, hc, hd ▸ h⟩
  · rintro ⟨c, hc, hd⟩
    exact (C.relativeDistanceToCode_le_of_codeword hc).trans_lt hd

theorem relativeDistanceToCode_eq_zero_of_codeword
    (C : BlockCode ι α) {w : Word ι α} (hw : C.Codeword w) :
    C.relativeDistanceToCode w = 0 := by
  have hd := (C.hammingDistanceToCode_eq_zero_iff ⟨w, hw⟩ w).2 hw
  simp [relativeDistanceToCode, hd]

theorem relativeDistanceToCode_eq_zero_iff
    (C : BlockCode ι α) (hC : ∃ c, C.Codeword c)
    (hlength : 0 < Fintype.card ι) (w : Word ι α) :
    C.relativeDistanceToCode w = 0 ↔ C.Codeword w := by
  have hn : (Fintype.card ι : ℝ) ≠ 0 := by exact_mod_cast Nat.ne_of_gt hlength
  have hzero : C.relativeDistanceToCode w = 0 ↔ C.hammingDistanceToCode w = 0 := by
    simp [relativeDistanceToCode, div_eq_zero_iff, hn]
  exact hzero.trans (C.hammingDistanceToCode_eq_zero_iff hC w)

end BlockCode
end ProximityCoding
