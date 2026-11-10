module

public import Mathlib.Data.Fintype.Card
public import Mathlib.Data.Finset.Basic
public import Mathlib.Basic.Real.Basic
public import Mathlib.Tactic

@[expose] public section

/-!
# Generic finite block-code vocabulary

This module is the dependency root for the capacity-radius proximity paper.
It deliberately imports only Mathlib. In particular, it does not import the
protocol, consensus, runtime, or concrete application modules.

The natural-number Hamming count is finite proof plumbing. Paper-facing
statements use `relativeHammingDistance`, `BallAt`, and `ListSizeBoundAt`.
-/

namespace ProximityCoding

/-- A received word over coordinates `ι` and alphabet `α`. -/
abbrev Word (ι α : Type*) := ι → α

/-- A finite-coordinate block code over an abstract alphabet. -/
structure BlockCode (ι α : Type*) where
  Codeword : Word ι α → Prop

namespace BlockCode

variable {ι α : Type*} [Fintype ι] [DecidableEq α]

/-- Hamming distance between two finite words. -/
def hammingDistance (u v : Word ι α) : ℕ :=
  (Finset.univ.filter fun i => u i ≠ v i).card

/-- A count radius normalized by the block length. -/
noncomputable def relativeRadius (r : ℕ) : ℝ :=
  (r : ℝ) / (Fintype.card ι : ℝ)

/-- Relative Hamming distance between two finite words. -/
noncomputable def relativeHammingDistance (u v : Word ι α) : ℝ :=
  (hammingDistance u v : ℝ) / (Fintype.card ι : ℝ)

/-- A word is within Hamming radius `r` of a codeword. -/
def Close (C : BlockCode ι α) (r : ℕ) (w : Word ι α) : Prop :=
  ∃ c : Word ι α, C.Codeword c ∧ hammingDistance c w ≤ r

/-- A word is within relative Hamming radius `δ` of a codeword. -/
def CloseAt (C : BlockCode ι α) (δ : ℝ) (w : Word ι α) : Prop :=
  ∃ c : Word ι α, C.Codeword c ∧ relativeHammingDistance c w ≤ δ

/-- The Hamming list-decoding ball around a received word. -/
def Ball (C : BlockCode ι α) (r : ℕ) (w : Word ι α) : Set (Word ι α) :=
  {c | C.Codeword c ∧ hammingDistance c w ≤ r}

/-- The relative list-decoding ball around a received word. -/
def BallAt (C : BlockCode ι α) (δ : ℝ) (w : Word ι α) : Set (Word ι α) :=
  {c | C.Codeword c ∧ relativeHammingDistance c w ≤ δ}

/-- Cardinality of a Hamming list-decoding ball. -/
noncomputable def ballCard
    (C : BlockCode ι α) (r : ℕ) (w : Word ι α) : ℕ :=
  Nat.card {c : Word ι α // c ∈ C.Ball r w}

/-- Cardinality of a relative list-decoding ball. -/
noncomputable def ballCardAt
    (C : BlockCode ι α) (δ : ℝ) (w : Word ι α) : ℕ :=
  Nat.card {c : Word ι α // c ∈ C.BallAt δ w}

/-- Every Hamming ball of radius `r` contains at most `L` codewords. -/
def ListSizeBound (C : BlockCode ι α) (r L : ℕ) : Prop :=
  ∀ w : Word ι α, C.ballCard r w ≤ L

/-- Every relative Hamming ball of radius `δ` contains at most `L` codewords. -/
def ListSizeBoundAt (C : BlockCode ι α) (δ : ℝ) (L : ℕ) : Prop :=
  ∀ w : Word ι α, C.ballCardAt δ w ≤ L

/-- Count closeness implies relative closeness at the normalized count radius. -/
theorem closeAt_of_close
    (C : BlockCode ι α) {r : ℕ} {w : Word ι α}
    (hw : C.Close r w) :
    C.CloseAt (relativeRadius (ι := ι) r) w := by
  rcases hw with ⟨c, hc, hd⟩
  exact ⟨c, hc, by
    unfold relativeHammingDistance relativeRadius
    exact div_le_div_of_nonneg_right (by exact_mod_cast hd) (Nat.cast_nonneg _)⟩

/-- Relative radius sends zero to zero. -/
@[simp]
theorem relativeRadius_zero :
    relativeRadius (ι := ι) 0 = 0 := by
  simp [relativeRadius]

/-- Relative radius is monotone in the underlying Hamming-count radius. -/
theorem relativeRadius_mono {r s : ℕ} (hrs : r ≤ s) :
    relativeRadius (ι := ι) r ≤ relativeRadius (ι := ι) s := by
  unfold relativeRadius
  exact div_le_div_of_nonneg_right (by exact_mod_cast hrs) (Nat.cast_nonneg _)

/--
At positive block length, comparison at a normalized count radius is exactly
comparison at the underlying Hamming-count radius.
-/
theorem relativeHammingDistance_le_relativeRadius_iff
    {u v : Word ι α} {r : ℕ}
    (hlength : 0 < Fintype.card ι) :
    relativeHammingDistance u v ≤ relativeRadius (ι := ι) r ↔
      hammingDistance u v ≤ r := by
  have hlength_real : (0 : ℝ) < Fintype.card ι := by
    exact_mod_cast hlength
  unfold relativeHammingDistance relativeRadius
  rw [div_le_div_iff_of_pos_right hlength_real]
  norm_cast

/-- Relative and count balls coincide at normalized count radii. -/
theorem ballAt_relativeRadius_eq_ball
    (C : BlockCode ι α)
    {r : ℕ}
    (hlength : 0 < Fintype.card ι)
    (w : Word ι α) :
    C.BallAt (relativeRadius (ι := ι) r) w = C.Ball r w := by
  ext c
  simp only [BallAt, Ball, Set.mem_ofPred_eq, and_congr_right_iff]
  intro _
  exact relativeHammingDistance_le_relativeRadius_iff hlength

/-- The corresponding relative and count ball cardinalities coincide. -/
theorem ballCardAt_relativeRadius_eq_ballCard
    (C : BlockCode ι α)
    {r : ℕ}
    (hlength : 0 < Fintype.card ι)
    (w : Word ι α) :
    C.ballCardAt (relativeRadius (ι := ι) r) w = C.ballCard r w := by
  unfold ballCardAt ballCard
  rw [ballAt_relativeRadius_eq_ball C hlength w]

/-- Codewords lie in their own radius-zero list ball. -/
theorem codeword_mem_ball_zero
    (C : BlockCode ι α) {c : Word ι α}
    (hc : C.Codeword c) :
    c ∈ C.Ball 0 c := by
  constructor
  · exact hc
  · unfold hammingDistance
    simp

/-- A list-ball member gives a `Close` witness. -/
theorem close_of_mem_ball
    (C : BlockCode ι α) {r : ℕ} {w c : Word ι α}
    (hc : c ∈ C.Ball r w) :
    C.Close r w :=
  ⟨c, hc.1, hc.2⟩

/-- A close word has a codeword in its list-decoding ball. -/
theorem exists_mem_ball_of_close
    (C : BlockCode ι α) {r : ℕ} {w : Word ι α}
    (hw : C.Close r w) :
    ∃ c : Word ι α, c ∈ C.Ball r w := by
  rcases hw with ⟨c, hc, hd⟩
  exact ⟨c, hc, hd⟩

end BlockCode

namespace BlockCode

variable {ι α : Type*}

/--
Interleaving of a code.

A vector-symbol word belongs to `C.interleaved τ` exactly when every component
projection belongs to `C`. Hamming distance still counts whole vector symbols.
-/
def interleaved (C : BlockCode ι α) (τ : Type*) : BlockCode ι (τ → α) where
  Codeword w := ∀ j : τ, C.Codeword fun i => w i j

/-- Project an interleaved codeword to one component of the base code. -/
theorem codeword_of_interleaved_component
    (C : BlockCode ι α) {τ : Type*}
    {w : Word ι (τ → α)} (hw : (C.interleaved τ).Codeword w)
    (j : τ) :
    C.Codeword fun i => w i j :=
  hw j

end BlockCode

/-- Algebraic closure needed for public linear challenges. -/
structure FAdditiveCode
    (F ι α : Type*) [Zero α] [Add α] [SMul F α]
    extends BlockCode ι α where
  zero_mem : Codeword fun _ => 0
  add_mem :
    ∀ {u v : Word ι α},
      Codeword u → Codeword v → Codeword fun i => u i + v i
  smul_mem :
    ∀ (a : F) {u : Word ι α},
      Codeword u → Codeword fun i => a • u i

namespace FAdditiveCode

variable {F ι α : Type*} [Zero α] [Add α] [SMul F α]

/-- The underlying block code of an additive code. -/
abbrev asBlockCode (C : FAdditiveCode F ι α) : BlockCode ι α :=
  C.toBlockCode

/-- A public linear combination of two codewords is again a codeword. -/
theorem linearCombination_mem
    (C : FAdditiveCode F ι α)
    (a : F) {u v : Word ι α}
    (hu : C.Codeword u) (hv : C.Codeword v) :
    C.Codeword fun i => u i + a • v i :=
  C.add_mem hu (C.smul_mem a hv)

end FAdditiveCode

namespace CapacityList

/-- Any two codewords agreeing on `k` coordinates are equal. -/
def DeterminedBy
    {ι α : Type*}
    (C : BlockCode ι α)
    (k : ℕ) : Prop :=
  ∀ ⦃c d : Word ι α⦄,
    C.Codeword c →
    C.Codeword d →
    ∀ S : Finset ι,
      S.card = k →
      (∀ i ∈ S, c i = d i) →
      c = d

end CapacityList

end ProximityCoding
