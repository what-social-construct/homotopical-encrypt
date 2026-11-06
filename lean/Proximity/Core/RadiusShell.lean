module

public import Proximity.Core.BlockCode
public import Mathlib.Order.ConditionallyCompleteLattice.Basic

@[expose] public section

/-!
# Count shells and real-radius intervals

Hamming counts are integral. A closed real-radius ball is therefore constant
on each half-open interval `[r/n,(r+1)/n)`. The lemmas here make that rounding
boundary explicit without selecting a floor operation or a coding instance.
-/

namespace ProximityPrize

namespace RadiusShell

theorem count_le_of_div_le_of_lt_succ
    {n d r : ℕ} {δ : ℝ} (hn : 0 < n)
    (hd : (d : ℝ) / n ≤ δ)
    (hδ : δ < ((r + 1 : ℕ) : ℝ) / n) : d ≤ r := by
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hdR : (d : ℝ) ≤ δ * n := (div_le_iff₀ hnR).mp hd
  have hδR : δ * n < ((r + 1 : ℕ) : ℝ) := (lt_div_iff₀ hnR).mp hδ
  by_contra h
  have hdr : r + 1 ≤ d := by omega
  have hdrR : ((r + 1 : ℕ) : ℝ) ≤ d := by exact_mod_cast hdr
  linarith

theorem div_le_iff_count_le_of_mem_shell
    {n d r : ℕ} {δ : ℝ} (hn : 0 < n)
    (hlo : (r : ℝ) / n ≤ δ)
    (hhi : δ < ((r + 1 : ℕ) : ℝ) / n) :
    (d : ℝ) / n ≤ δ ↔ d ≤ r := by
  constructor
  · exact fun hd => count_le_of_div_le_of_lt_succ hn hd hhi
  · intro hdr
    exact (div_le_div_of_nonneg_right (by exact_mod_cast hdr)
      (Nat.cast_nonneg n)).trans hlo

/-- The excluded next grid point is the real supremum, rather than a maximum. -/
theorem halfOpen_interval_summary {b : ℝ} (hb : 0 < b) :
    sSup (Set.Ico (0 : ℝ) b) = b ∧
      b ∉ Set.Ico (0 : ℝ) b ∧
      ¬ ∃ x, IsGreatest (Set.Ico (0 : ℝ) b) x := by
  refine ⟨csSup_Ico hb, by simp, ?_⟩
  rintro ⟨x, hx⟩
  have hy : (x + b) / 2 ∈ Set.Ico (0 : ℝ) b := by
    constructor <;> linarith [hx.1.1, hx.1.2]
  have hxy := hx.2 hy
  linarith [hx.1.2]

end RadiusShell

namespace BlockCode

variable {ι α : Type*} [Fintype ι] [DecidableEq α]

theorem ballAt_subset_ball_of_lt_succ
    (C : BlockCode ι α) {r : ℕ} {δ : ℝ}
    (hn : 0 < Fintype.card ι)
    (hδ : δ < relativeRadius (ι := ι) (r + 1))
    (w : Word ι α) : C.BallAt δ w ⊆ C.Ball r w := by
  intro c hc
  exact ⟨hc.1, RadiusShell.count_le_of_div_le_of_lt_succ hn hc.2 hδ⟩

theorem ballAt_eq_ball_of_mem_shell
    (C : BlockCode ι α) {r : ℕ} {δ : ℝ}
    (hn : 0 < Fintype.card ι)
    (hlo : relativeRadius (ι := ι) r ≤ δ)
    (hhi : δ < relativeRadius (ι := ι) (r + 1))
    (w : Word ι α) : C.BallAt δ w = C.Ball r w := by
  ext c
  change (C.Codeword c ∧ relativeHammingDistance c w ≤ δ) ↔
    (C.Codeword c ∧ hammingDistance c w ≤ r)
  exact and_congr_right fun _ =>
    RadiusShell.div_le_iff_count_le_of_mem_shell hn hlo hhi

theorem ballCardAt_eq_ballCard_of_mem_shell
    (C : BlockCode ι α) {r : ℕ} {δ : ℝ}
    (hn : 0 < Fintype.card ι)
    (hlo : relativeRadius (ι := ι) r ≤ δ)
    (hhi : δ < relativeRadius (ι := ι) (r + 1))
    (w : Word ι α) : C.ballCardAt δ w = C.ballCard r w := by
  unfold ballCardAt ballCard
  rw [C.ballAt_eq_ball_of_mem_shell hn hlo hhi w]

private theorem word_eq_of_hammingDistance_le_zero
    {u v : Word ι α} (h : hammingDistance u v ≤ 0) : u = v := by
  funext i
  by_contra hi
  have hmem : i ∈ Finset.univ.filter (fun j => u j ≠ v j) := by simp [hi]
  have hempty : Finset.univ.filter (fun j => u j ≠ v j) = ∅ :=
    Finset.card_eq_zero.mp (Nat.eq_zero_of_le_zero h)
  simp [hempty] at hmem

section FiniteAlphabet

variable [Fintype α]

theorem ballCardAt_mono_radius
    (C : BlockCode ι α) (w : Word ι α) {δ η : ℝ} (h : δ ≤ η) :
    C.ballCardAt δ w ≤ C.ballCardAt η w := by
  unfold ballCardAt
  exact Nat.card_le_card_of_injective
    (fun c => ⟨c.1, c.2.1, c.2.2.trans h⟩)
    (by
      intro c d hcd
      exact Subtype.ext
        (congrArg (fun x : {c : Word ι α // c ∈ C.BallAt η w} => x.1) hcd))

theorem ballCardAt_le_ballCard_of_lt_succ
    (C : BlockCode ι α) {r : ℕ} {δ : ℝ}
    (hn : 0 < Fintype.card ι)
    (hδ : δ < relativeRadius (ι := ι) (r + 1))
    (w : Word ι α) : C.ballCardAt δ w ≤ C.ballCard r w := by
  unfold ballCardAt ballCard
  exact Nat.card_le_card_of_injective
    (fun c => ⟨c.1, C.ballAt_subset_ball_of_lt_succ hn hδ w c.2⟩)
    (by
      intro c d hcd
      exact Subtype.ext
        (congrArg (fun x : {c : Word ι α // c ∈ C.Ball r w} => x.1) hcd))

theorem ballCard_zero_le_one (C : BlockCode ι α) (w : Word ι α) :
    C.ballCard 0 w ≤ 1 := by
  unfold ballCard
  have hsub : Subsingleton {c : Word ι α // c ∈ C.Ball 0 w} := by
    constructor
    intro c d
    apply Subtype.ext
    exact (word_eq_of_hammingDistance_le_zero c.2.2).trans
      (word_eq_of_hammingDistance_le_zero d.2.2).symm
  exact Finite.card_le_one_iff_subsingleton.mpr hsub

theorem ballCardAt_zero_le_one
    (C : BlockCode ι α) (hn : 0 < Fintype.card ι) (w : Word ι α) :
    C.ballCardAt 0 w ≤ 1 := by
  rw [← relativeRadius_zero (ι := ι), C.ballCardAt_relativeRadius_eq_ballCard hn w]
  exact C.ballCard_zero_le_one w

theorem one_le_ballCardAt_self
    (C : BlockCode ι α) {w : Word ι α} (hw : C.Codeword w)
    {δ : ℝ} (hδ : 0 ≤ δ) : 1 ≤ C.ballCardAt δ w := by
  let : Nonempty {c : Word ι α // c ∈ C.BallAt δ w} :=
    ⟨⟨w, hw, by simpa [relativeHammingDistance, hammingDistance] using hδ⟩⟩
  exact Nat.card_pos

end FiniteAlphabet
end BlockCode
end ProximityPrize
