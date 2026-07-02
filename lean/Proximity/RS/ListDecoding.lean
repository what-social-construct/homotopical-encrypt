import Mathlib.Data.Fintype.Card
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic

/-
  List-decoding vocabulary for finite block-code shadows.

  This module owns the generic Hamming-distance vocabulary. The raw Hamming
  count is kept as finite combinatorial plumbing; the paper-facing proximity
  surface is relative/fractional Hamming distance.
-/

namespace Hcrypt
namespace Proximity

/-- A received word over coordinates `ι` and alphabet `α`. -/
abbrev Word (ι α : Type*) := ι → α

/--
A finite-coordinate block code.

The alphabet is left abstract: later instantiations may use field elements,
extension-field symbols, folded symbols, or bundled/interleaved symbols.
-/
structure BlockCode (ι α : Type*) where
  Codeword : Word ι α → Prop

namespace BlockCode

variable {ι α : Type*} [Fintype ι] [DecidableEq α]

/-- Hamming distance between two finite words. -/
def hammingDistance (u v : Word ι α) : ℕ :=
  (Finset.univ.filter fun i => u i ≠ v i).card

/-- Relative Hamming radius for a count radius over the coordinate domain. -/
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

/-- The list-decoding ball around a received word. -/
def Ball (C : BlockCode ι α) (r : ℕ) (w : Word ι α) : Set (Word ι α) :=
  {c | C.Codeword c ∧ hammingDistance c w ≤ r}

/-- The relative list-decoding ball around a received word. -/
def BallAt (C : BlockCode ι α) (δ : ℝ) (w : Word ι α) : Set (Word ι α) :=
  {c | C.Codeword c ∧ relativeHammingDistance c w ≤ δ}

/-- Cardinality of the list-decoding ball. -/
noncomputable def ballCard (C : BlockCode ι α) (r : ℕ) (w : Word ι α) : ℕ :=
  Nat.card {c : Word ι α // c ∈ C.Ball r w}

/-- Cardinality of the relative list-decoding ball. -/
noncomputable def ballCardAt (C : BlockCode ι α) (δ : ℝ) (w : Word ι α) : ℕ :=
  Nat.card {c : Word ι α // c ∈ C.BallAt δ w}

/--
Combinatorial list-size bound.

`ListSizeBound C r L` means every Hamming ball of radius `r` contains at most
`L` codewords. This is the Lean slot where Johnson, capacity, ERA, or
interleaved-code bounds can later be plugged in.
-/
def ListSizeBound (C : BlockCode ι α) (r L : ℕ) : Prop :=
  ∀ w : Word ι α, C.ballCard r w ≤ L

/-- Fractional list-size bound at relative Hamming radius `δ`. -/
def ListSizeBoundAt (C : BlockCode ι α) (δ : ℝ) (L : ℕ) : Prop :=
  ∀ w : Word ι α, C.ballCardAt δ w ≤ L

/-!
The next few lemmas connect the finite count API to the relative API. They let
concrete RS theorems stay count-based internally while exposing fractional
distance to the projection chain.
-/

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
theorem relativeRadius_zero :
    relativeRadius (ι := ι) 0 = 0 := by
  simp [relativeRadius]

/-- Relative radius is monotone in the underlying Hamming-count radius. -/
theorem relativeRadius_mono {r s : ℕ} (hrs : r ≤ s) :
    relativeRadius (ι := ι) r ≤ relativeRadius (ι := ι) s := by
  unfold relativeRadius
  exact div_le_div_of_nonneg_right (by exact_mod_cast hrs) (Nat.cast_nonneg _)

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
    C.Close r w := by
  exact ⟨c, hc.1, hc.2⟩

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
Interleaving/bundling of a code.

An interleaved codeword is a word whose every component projection is a
codeword of the base code.
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

/--
An additive finite-field-style code interface.

This is deliberately algebraic but not RS-specific: it records the closure
properties needed for public linear challenges `f₁ + γ f₂`.
-/
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
theorem linear_combination_mem
    (C : FAdditiveCode F ι α)
    (a : F) {u v : Word ι α}
    (hu : C.Codeword u) (hv : C.Codeword v) :
    C.Codeword fun i => u i + a • v i :=
  C.add_mem hu (C.smul_mem a hv)

end FAdditiveCode

end Proximity
end Hcrypt
