module

public import Proximity.Core.Distance
public import Mathlib.Data.Fintype.Prod

@[expose] public section

/-!
# Native flattened-coordinate and whole-pair Hamming metrics

Flattening a two-column word preserves the actual codeword predicate but
changes which coordinates count as one Hamming symbol. The normalized scalar
coordinate metric and native whole-pair metric satisfy an explicit factor-two
comparison. Neither metric is defined as the other metric's pullback.
-/

set_option autoImplicit false

namespace ProximityPrize.BlockCode

variable {ι α : Type*}

def flattenPair (w : Word ι (Fin 2 → α)) : Word (ι × Fin 2) α :=
  fun p => w p.1 p.2

def unflattenPair (w : Word (ι × Fin 2) α) : Word ι (Fin 2 → α) :=
  fun i j => w (i, j)

@[simp]
theorem flattenPair_unflattenPair (w : Word (ι × Fin 2) α) :
    flattenPair (unflattenPair w) = w := rfl

@[simp]
theorem unflattenPair_flattenPair (w : Word ι (Fin 2 → α)) :
    unflattenPair (flattenPair w) = w := rfl

/-- The scalar-coordinate code locus is exactly the same pair of codewords. -/
def flattenedPairCode (C : BlockCode ι α) : BlockCode (ι × Fin 2) α where
  Codeword w := ∀ j, C.Codeword (fun i => w (i, j))

@[simp]
theorem flattenedPairCode_codeword_iff (C : BlockCode ι α)
    (w : Word ι (Fin 2 → α)) :
    (flattenedPairCode C).Codeword (flattenPair w) ↔
      (C.interleaved (Fin 2)).Codeword w := Iff.rfl

theorem flattenedPairCode_nonempty (C : BlockCode ι α)
    (hC : ∃ c, C.Codeword c) :
    ∃ c, (flattenedPairCode C).Codeword c := by
  obtain ⟨c, hc⟩ := hC
  exact ⟨fun p => c p.1, fun _ => hc⟩

theorem interleavedPair_nonempty (C : BlockCode ι α)
    (hC : ∃ c, C.Codeword c) :
    ∃ c, (C.interleaved (Fin 2)).Codeword c := by
  obtain ⟨c, hc⟩ := hC
  exact ⟨fun i _ => c i, fun _ => hc⟩

section Counts

variable [Fintype ι] [DecidableEq α]

theorem pair_hamming_le_flat (u v : Word ι (Fin 2 → α)) :
    hammingDistance u v ≤ hammingDistance (flattenPair u) (flattenPair v) := by
  classical
  let D : Finset (ι × Fin 2) := Finset.univ.filter
    (fun p => u p.1 p.2 ≠ v p.1 p.2)
  have himage : D.image Prod.fst = Finset.univ.filter (fun i => u i ≠ v i) := by
    ext i
    simp only [Finset.mem_image, D, Finset.mem_filter, Finset.mem_univ, true_and]
    constructor
    · rintro ⟨⟨a, j⟩, hne, rfl⟩ heq
      exact hne (congrFun heq j)
    · intro hne
      have hj : ∃ j, u i j ≠ v i j := by
        by_contra! h
        exact hne (funext h)
      obtain ⟨j, hj⟩ := hj
      exact ⟨(i, j), hj, rfl⟩
  change (Finset.univ.filter (fun i => u i ≠ v i)).card ≤ D.card
  rw [← himage]
  exact Finset.card_image_le

theorem flat_hamming_le_two_mul_pair (u v : Word ι (Fin 2 → α)) :
    hammingDistance (flattenPair u) (flattenPair v) ≤ 2 * hammingDistance u v := by
  classical
  let D : Finset (ι × Fin 2) := Finset.univ.filter
    (fun p => u p.1 p.2 ≠ v p.1 p.2)
  let B : Finset ι := Finset.univ.filter (fun i => u i ≠ v i)
  have hsub : D ⊆ B.product Finset.univ := by
    intro p hp
    rcases p with ⟨i, j⟩
    have hne : u i j ≠ v i j := (Finset.mem_filter.mp hp).2
    apply Finset.mem_product.mpr
    refine ⟨Finset.mem_filter.mpr ⟨Finset.mem_univ _, ?_⟩, Finset.mem_univ _⟩
    intro heq
    exact hne (congrFun heq j)
  calc
    hammingDistance (flattenPair u) (flattenPair v) = D.card := rfl
    _ ≤ (B.product Finset.univ).card := Finset.card_le_card hsub
    _ = B.card * (Finset.univ : Finset (Fin 2)).card :=
      Finset.card_product B Finset.univ
    _ = 2 * hammingDistance u v := by
      simp [B, hammingDistance, Nat.mul_comm]

/-- Flattened mismatches are the sum of the two scalar column counts. -/
theorem flat_hamming_eq_column_sum (u v : Word ι (Fin 2 → α)) :
    hammingDistance (flattenPair u) (flattenPair v) =
      hammingDistance (fun i => u i 0) (fun i => v i 0) +
      hammingDistance (fun i => u i 1) (fun i => v i 1) := by
  change ((Finset.univ : Finset (ι × Fin 2)).filter
      (fun p => u p.1 p.2 ≠ v p.1 p.2)).card =
    ((Finset.univ : Finset ι).filter (fun i => u i 0 ≠ v i 0)).card +
      ((Finset.univ : Finset ι).filter (fun i => u i 1 ≠ v i 1)).card
  simp only [Finset.card_eq_sum_ones, Finset.sum_filter]
  rw [Fintype.sum_prod_type]
  simp [Fin.sum_univ_two, Finset.sum_filter, Finset.sum_add_distrib]

end Counts

section Normalized

variable [Fintype ι] [DecidableEq α]

theorem flat_relativeHammingDistance_le_pair
    (hlength : 0 < Fintype.card ι) (u v : Word ι (Fin 2 → α)) :
    relativeHammingDistance (flattenPair u) (flattenPair v) ≤
      relativeHammingDistance u v := by
  have hn : (0 : ℝ) < Fintype.card ι := by exact_mod_cast hlength
  have hc : (hammingDistance (flattenPair u) (flattenPair v) : ℝ) ≤
      2 * hammingDistance u v := by exact_mod_cast flat_hamming_le_two_mul_pair u v
  unfold relativeHammingDistance
  simp only [Fintype.card_prod, Fintype.card_fin, Nat.cast_mul, Nat.cast_ofNat]
  apply (div_le_div_iff₀ (mul_pos hn (by norm_num)) hn).2
  have hm := mul_le_mul_of_nonneg_right hc hn.le
  nlinarith

theorem pair_relativeHammingDistance_le_two_mul_flat
    (hlength : 0 < Fintype.card ι) (u v : Word ι (Fin 2 → α)) :
    relativeHammingDistance u v ≤
      2 * relativeHammingDistance (flattenPair u) (flattenPair v) := by
  have hn : (0 : ℝ) < Fintype.card ι := by exact_mod_cast hlength
  have hc : (hammingDistance u v : ℝ) ≤
      hammingDistance (flattenPair u) (flattenPair v) := by
    exact_mod_cast pair_hamming_le_flat u v
  unfold relativeHammingDistance
  simp only [Fintype.card_prod, Fintype.card_fin, Nat.cast_mul, Nat.cast_ofNat]
  calc
    (hammingDistance u v : ℝ) / Fintype.card ι ≤
        (hammingDistance (flattenPair u) (flattenPair v) : ℝ) / Fintype.card ι :=
      div_le_div_of_nonneg_right hc hn.le
    _ = 2 * ((hammingDistance (flattenPair u) (flattenPair v) : ℝ) /
        ((Fintype.card ι : ℝ) * 2)) := by
      field_simp [hn.ne']

/-- The two native nearest-code metrics retain their explicit factor-two loss. -/
theorem flattenedPairCode_distance_comparison
    (C : BlockCode ι α) (hC : ∃ c, C.Codeword c)
    (hlength : 0 < Fintype.card ι) (w : Word ι (Fin 2 → α)) :
    (flattenedPairCode C).relativeDistanceToCode (flattenPair w) ≤
        (C.interleaved (Fin 2)).relativeDistanceToCode w ∧
      (C.interleaved (Fin 2)).relativeDistanceToCode w ≤
        2 * (flattenedPairCode C).relativeDistanceToCode (flattenPair w) := by
  constructor
  · obtain ⟨c, hc, hmin⟩ := (C.interleaved (Fin 2)).exists_nearest_codeword_relative
      (interleavedPair_nonempty C hC) w
    calc
      (flattenedPairCode C).relativeDistanceToCode (flattenPair w) ≤
          relativeHammingDistance (flattenPair c) (flattenPair w) :=
        (flattenedPairCode C).relativeDistanceToCode_le_of_codeword hc
      _ ≤ relativeHammingDistance c w :=
        flat_relativeHammingDistance_le_pair hlength c w
      _ = (C.interleaved (Fin 2)).relativeDistanceToCode w := hmin.symm
  · obtain ⟨c, hc, hmin⟩ := (flattenedPairCode C).exists_nearest_codeword_relative
      (flattenedPairCode_nonempty C hC) (flattenPair w)
    calc
      (C.interleaved (Fin 2)).relativeDistanceToCode w ≤
          relativeHammingDistance (unflattenPair c) w :=
        (C.interleaved (Fin 2)).relativeDistanceToCode_le_of_codeword hc
      _ ≤ 2 * relativeHammingDistance c (flattenPair w) := by
        simpa only [flattenPair_unflattenPair] using
          pair_relativeHammingDistance_le_two_mul_flat hlength (unflattenPair c) w
      _ = 2 * (flattenedPairCode C).relativeDistanceToCode (flattenPair w) := by
        rw [hmin]

theorem pairFar_of_flatFar
    (C : BlockCode ι α) (hC : ∃ c, C.Codeword c)
    (hlength : 0 < Fintype.card ι) (w : Word ι (Fin 2 → α))
    (radius : ℝ)
    (hfar : radius ≤ (flattenedPairCode C).relativeDistanceToCode (flattenPair w)) :
    radius ≤ (C.interleaved (Fin 2)).relativeDistanceToCode w :=
  hfar.trans (flattenedPairCode_distance_comparison C hC hlength w).1

end Normalized

end ProximityPrize.BlockCode
