import Proximity.RS.ListDecoding

/-
  Correlated agreement and mutual correlated agreement.

  Paper correspondence:
  - Paper 1 Section 6: CA/MCA paper-facing definitions.

  This module keeps count-based finite lemmas as proof plumbing, and exposes
  fractional/error-rate definitions for paper-facing CA/MCA statements.
-/

namespace Hcrypt
namespace Proximity

/-- An affine line of received words: `base + γ • direction`. -/
structure AffineLine
    (F ι α : Type*) [Add α] [SMul F α] where
  base : Word ι α
  direction : Word ι α

namespace AffineLine

variable {F ι α : Type*} [Add α] [SMul F α]

/-- The point on a line selected by challenge `γ`. -/
def point (L : AffineLine F ι α) (γ : F) : Word ι α :=
  fun i => L.base i + γ • L.direction i

/-- Point evaluation on an affine line is coordinatewise `base + γ • direction`. -/
@[simp]
theorem point_apply
    (L : AffineLine F ι α) (γ : F) (i : ι) :
    L.point γ i = L.base i + γ • L.direction i :=
  rfl

end AffineLine

namespace BlockCode

/--
Bundle two received words as the length-two interleaved word `(f₁, f₂)`.

This is the word measured against `C≡2` in the paper's CA/MCA definitions.
-/
def pairWord {ι α : Type*} (f₁ f₂ : Word ι α) : Word ι (Fin 2 → α) :=
  fun i j => if j = 0 then f₁ i else f₂ i

/-- The first component of the paper interleaving `(f₁, f₂)` is `f₁`. -/
@[simp]
theorem pairWord_zero {ι α : Type*}
    (f₁ f₂ : Word ι α) (i : ι) :
    pairWord f₁ f₂ i 0 = f₁ i := by
  simp [pairWord]

/-- The second component of the paper interleaving `(f₁, f₂)` is `f₂`. -/
@[simp]
theorem pairWord_one {ι α : Type*}
    (f₁ f₂ : Word ι α) (i : ι) :
    pairWord f₁ f₂ i 1 = f₂ i := by
  simp [pairWord]

variable {F ι α : Type*}
variable [Fintype F] [Fintype ι]
variable [Add α] [SMul F α]

/-- A large agreement set: its complement has size at most `r`. -/
def LargeAgreementSet (r : ℕ) (S : Finset ι) : Prop :=
  Fintype.card ι ≤ S.card + r

/-- Fraction of coordinates contained in an agreement set. -/
noncomputable def coordinateFraction (S : Finset ι) : ℝ :=
  (S.card : ℝ) / (Fintype.card ι : ℝ)

/-- Paper-facing large agreement set: `|S| / n ≥ 1 - δ`. -/
def LargeAgreementSetAt (δ : ℝ) (S : Finset ι) : Prop :=
  1 - δ ≤ coordinateFraction S

/-- Two words agree on every coordinate in `S`. -/
def AgreesOn (w c : Word ι α) (S : Finset ι) : Prop :=
  ∀ i : ι, i ∈ S → w i = c i

/-- `w` agrees on `S` with some codeword. -/
def CloseOnSet (C : BlockCode ι α) (w : Word ι α) (S : Finset ι) : Prop :=
  ∃ c : Word ι α, C.Codeword c ∧ AgreesOn w c S

/-- `w` is close to the code on some large agreement set. -/
def CloseOnLargeSet (C : BlockCode ι α) (r : ℕ) (w : Word ι α) : Prop :=
  ∃ S : Finset ι, LargeAgreementSet r S ∧ C.CloseOnSet w S

/-- `w` is close to the code on some fractional large agreement set. -/
def CloseOnLargeSetAt (C : BlockCode ι α) (δ : ℝ) (w : Word ι α) : Prop :=
  ∃ S : Finset ι, LargeAgreementSetAt δ S ∧ C.CloseOnSet w S

/-- A line is close on one shared large agreement set. -/
def LineCloseOnSet
    (C : BlockCode ι α) (r : ℕ)
    (L : AffineLine F ι α) (S : Finset ι) : Prop :=
  LargeAgreementSet r S ∧ ∀ γ : F, C.CloseOnSet (L.point γ) S

/-- A line is close on one shared fractional large agreement set. -/
def LineCloseOnSetAt
    (C : BlockCode ι α) (δ : ℝ)
    (L : AffineLine F ι α) (S : Finset ι) : Prop :=
  LargeAgreementSetAt δ S ∧ ∀ γ : F, C.CloseOnSet (L.point γ) S

/-- A line is close when all of its points are individually close. -/
def LinePointwiseClose
    (C : BlockCode ι α) (r : ℕ)
    (L : AffineLine F ι α) : Prop :=
  ∀ γ : F, C.CloseOnLargeSet r (L.point γ)

/-- A line is fractionally pointwise close when all points are individually close. -/
def LinePointwiseCloseAt
    (C : BlockCode ι α) (δ : ℝ)
    (L : AffineLine F ι α) : Prop :=
  ∀ γ : F, C.CloseOnLargeSetAt δ (L.point γ)

/-- Challenge parameters whose line point is individually close. -/
noncomputable def closeParameterSet
    (C : BlockCode ι α) (r : ℕ)
    (L : AffineLine F ι α) : Finset F :=
  by
    classical
    exact Finset.univ.filter fun γ => C.CloseOnLargeSet r (L.point γ)

/-- Challenge parameters whose line point is fractionally individually close. -/
noncomputable def closeParameterSetAt
    (C : BlockCode ι α) (δ : ℝ)
    (L : AffineLine F ι α) : Finset F :=
  by
    classical
    exact Finset.univ.filter fun γ => C.CloseOnLargeSetAt δ (L.point γ)

/-- Fraction of challenge parameters in a finite parameter set. -/
noncomputable def parameterFraction (S : Finset F) : ℝ :=
  (S.card : ℝ) / (Fintype.card F : ℝ)

section PaperDefinitions

variable [DecidableEq α]

/--
The bad challenge set from Definition 4.1:
`f₁ + γ f₂` is `δfld`-close to `C`, but `(f₁, f₂)` is not `δint`-close
to the two-fold interleaved code `C≡2`.
-/
noncomputable def paperCABadParameterSet
    (C : BlockCode ι α)
    (δfld δint : ℝ)
    (L : AffineLine F ι α) : Finset F :=
  by
    classical
    exact Finset.univ.filter fun γ =>
      C.CloseAt δfld (L.point γ) ∧
        ¬ (C.interleaved (Fin 2)).CloseAt δint
            (pairWord L.base L.direction)

/-- Membership in the paper Definition 4.1 CA bad-challenge set. -/
theorem mem_paperCABadParameterSet
    (C : BlockCode ι α)
    (δfld δint : ℝ)
    (L : AffineLine F ι α)
    (γ : F) :
    γ ∈ C.paperCABadParameterSet δfld δint L ↔
      C.CloseAt δfld (L.point γ) ∧
        ¬ (C.interleaved (Fin 2)).CloseAt δint
          (pairWord L.base L.direction) := by
  classical
  simp [paperCABadParameterSet]

/--
Paper-facing correlated-agreement error bound with proximity loss
`δint - δfld`.

This states `εca(C, δfld, δint) ≤ ε` in the notation of Definition 4.1.
-/
def PaperCorrelatedAgreementErrorBound
    (C : BlockCode ι α)
    (δfld δint ε : ℝ) : Prop :=
  ∀ L : AffineLine F ι α,
    parameterFraction (C.paperCABadParameterSet δfld δint L) ≤ ε

/--
The bad challenge set from Definition 4.3:
there is a large set `S` on which `f₁ + γ f₂` agrees with `C`, but the
same `S` does not make `(f₁, f₂)` agree with the interleaved code `C≡2`.
-/
noncomputable def paperMCABadParameterSet
    (C : BlockCode ι α)
    (δ : ℝ)
    (L : AffineLine F ι α) : Finset F :=
  by
    classical
    exact Finset.univ.filter fun γ =>
      ∃ S : Finset ι,
        LargeAgreementSetAt δ S ∧
          C.CloseOnSet (L.point γ) S ∧
            ¬ (C.interleaved (Fin 2)).CloseOnSet
                (pairWord L.base L.direction) S

omit [DecidableEq α] in
/-- Membership in the paper Definition 4.3 MCA bad-challenge set. -/
theorem mem_paperMCABadParameterSet
    (C : BlockCode ι α)
    (δ : ℝ)
    (L : AffineLine F ι α)
    (γ : F) :
    γ ∈ C.paperMCABadParameterSet δ L ↔
      ∃ S : Finset ι,
        LargeAgreementSetAt δ S ∧
          C.CloseOnSet (L.point γ) S ∧
            ¬ (C.interleaved (Fin 2)).CloseOnSet
              (pairWord L.base L.direction) S := by
  classical
  simp [paperMCABadParameterSet]

/--
Paper-facing mutual-correlated-agreement error bound.

This states `εmca(C, δ) ≤ ε` in the notation of Definition 4.3.
-/
def PaperMutualCorrelatedAgreementErrorBound
    (C : BlockCode ι α)
    (δ ε : ℝ) : Prop :=
  ∀ L : AffineLine F ι α,
    parameterFraction (C.paperMCABadParameterSet δ L) ≤ ε

end PaperDefinitions

/--
Count-based correlated-agreement bound.

If more than `threshold` challenge points are individually close, then the
whole line is close on one common agreement set.
-/
def CorrelatedAgreementBound
    (C : BlockCode ι α)
    (pointRadius lineRadius threshold : ℕ) : Prop :=
  ∀ L : AffineLine F ι α,
    threshold < (C.closeParameterSet pointRadius L).card →
      ∃ S : Finset ι, C.LineCloseOnSet lineRadius L S

/--
Fractional correlated-agreement error bound.

If more than an `ε` fraction of line points are individually `δpoint`-close,
then the line is close on one common `δline` agreement set.
-/
def CorrelatedAgreementErrorBound
    (C : BlockCode ι α)
    (δpoint δline ε : ℝ) : Prop :=
  ∀ L : AffineLine F ι α,
    ε < parameterFraction (C.closeParameterSetAt δpoint L) →
      ∃ S : Finset ι, C.LineCloseOnSetAt δline L S

/--
A challenge point is MCA-good if every large agreement witness for that point
extends to a shared agreement witness for the whole line.
-/
def MutuallyGood
    (C : BlockCode ι α)
    (pointRadius lineRadius : ℕ)
    (L : AffineLine F ι α) (γ : F) : Prop :=
  ∀ S : Finset ι,
    LargeAgreementSet pointRadius S →
      C.CloseOnSet (L.point γ) S →
        C.LineCloseOnSet lineRadius L S

/--
A challenge point is fractionally MCA-good if every fractional agreement
witness for that point extends to the same shared line witness.
-/
def MutuallyGoodAt
    (C : BlockCode ι α)
    (δpoint δline : ℝ)
    (L : AffineLine F ι α) (γ : F) : Prop :=
  ∀ S : Finset ι,
    LargeAgreementSetAt δpoint S →
      C.CloseOnSet (L.point γ) S →
        C.LineCloseOnSetAt δline L S

/-- Challenge parameters that fail the MCA-good condition. -/
noncomputable def badParameterSet
    (C : BlockCode ι α)
    (pointRadius lineRadius : ℕ)
    (L : AffineLine F ι α) : Finset F :=
  by
    classical
    exact Finset.univ.filter fun γ => ¬ C.MutuallyGood pointRadius lineRadius L γ

/-- Challenge parameters that fail the fractional MCA-good condition. -/
noncomputable def badParameterSetAt
    (C : BlockCode ι α)
    (δpoint δline : ℝ)
    (L : AffineLine F ι α) : Finset F :=
  by
    classical
    exact Finset.univ.filter fun γ => ¬ C.MutuallyGoodAt δpoint δline L γ

/--
Count-based mutual-correlated-agreement bound.

For every line, at most `threshold` challenge points are MCA-bad.
-/
def MutualCorrelatedAgreementBound
    (C : BlockCode ι α)
    (pointRadius lineRadius threshold : ℕ) : Prop :=
  ∀ L : AffineLine F ι α,
    (C.badParameterSet pointRadius lineRadius L).card ≤ threshold

/--
Fractional mutual-correlated-agreement error bound.

For every line, at most an `ε` fraction of challenge points are MCA-bad.
-/
def MutualCorrelatedAgreementErrorBound
    (C : BlockCode ι α)
    (δpoint δline ε : ℝ) : Prop :=
  ∀ L : AffineLine F ι α,
    parameterFraction (C.badParameterSetAt δpoint δline L) ≤ ε

/--
MCA implies CA in the count-based formulation.

This is the formal version of the hierarchy direction used by the paper:
if there are too many individually close line points, one of them must be
MCA-good, and its agreement witness becomes a common witness for the line.
-/
theorem correlatedAgreement_of_mutualCorrelatedAgreement
    (C : BlockCode ι α)
    {pointRadius lineRadius threshold : ℕ}
    (hmca :
      C.MutualCorrelatedAgreementBound
        (F := F) pointRadius lineRadius threshold) :
    C.CorrelatedAgreementBound
      (F := F) pointRadius lineRadius threshold := by
  classical
  intro L hclose
  by_contra hno
  have hsubset :
      C.closeParameterSet pointRadius L ⊆
        C.badParameterSet pointRadius lineRadius L := by
    intro γ hγ
    have hcloseγ :
        C.CloseOnLargeSet pointRadius (L.point γ) := by
      simpa [closeParameterSet] using hγ
    rcases hcloseγ with ⟨S, hlarge, hset⟩
    have hnotgood :
        ¬ C.MutuallyGood pointRadius lineRadius L γ := by
      intro hgood
      exact hno ⟨S, hgood S hlarge hset⟩
    simp [badParameterSet, hnotgood]
  have hcard :
      (C.closeParameterSet pointRadius L).card ≤
        (C.badParameterSet pointRadius lineRadius L).card :=
    Finset.card_le_card hsubset
  have hbad :
      (C.badParameterSet pointRadius lineRadius L).card ≤ threshold :=
    hmca L
  omega

end BlockCode

end Proximity
end Hcrypt
