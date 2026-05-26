import Proximity.ListDecoding

/-
  Correlated agreement and mutual correlated agreement.

  The paper-side objects are expressed here in a count-based finite form:
  instead of real probabilities over the challenge field, an error threshold is
  a number of challenge parameters. This avoids premature analytic claims while
  keeping the CA/MCA structure exact enough for later RS/ERA instantiations.
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

end AffineLine

namespace BlockCode

variable {F ι α : Type*}
variable [Fintype F] [Fintype ι]
variable [Add α] [SMul F α]

/-- A large agreement set: its complement has size at most `r`. -/
def LargeAgreementSet (r : ℕ) (S : Finset ι) : Prop :=
  Fintype.card ι ≤ S.card + r

/-- Two words agree on every coordinate in `S`. -/
def AgreesOn (w c : Word ι α) (S : Finset ι) : Prop :=
  ∀ i : ι, i ∈ S → w i = c i

/-- `w` agrees on `S` with some codeword. -/
def CloseOnSet (C : BlockCode ι α) (w : Word ι α) (S : Finset ι) : Prop :=
  ∃ c : Word ι α, C.Codeword c ∧ AgreesOn w c S

/-- `w` is close to the code on some large agreement set. -/
def CloseOnLargeSet (C : BlockCode ι α) (r : ℕ) (w : Word ι α) : Prop :=
  ∃ S : Finset ι, LargeAgreementSet r S ∧ C.CloseOnSet w S

/-- A line is close on one shared large agreement set. -/
def LineCloseOnSet
    (C : BlockCode ι α) (r : ℕ)
    (L : AffineLine F ι α) (S : Finset ι) : Prop :=
  LargeAgreementSet r S ∧ ∀ γ : F, C.CloseOnSet (L.point γ) S

/-- A line is close when all of its points are individually close. -/
def LinePointwiseClose
    (C : BlockCode ι α) (r : ℕ)
    (L : AffineLine F ι α) : Prop :=
  ∀ γ : F, C.CloseOnLargeSet r (L.point γ)

/-- Challenge parameters whose line point is individually close. -/
noncomputable def closeParameterSet
    (C : BlockCode ι α) (r : ℕ)
    (L : AffineLine F ι α) : Finset F :=
  by
    classical
    exact Finset.univ.filter fun γ => C.CloseOnLargeSet r (L.point γ)

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

/-- Challenge parameters that fail the MCA-good condition. -/
noncomputable def badParameterSet
    (C : BlockCode ι α)
    (pointRadius lineRadius : ℕ)
    (L : AffineLine F ι α) : Finset F :=
  by
    classical
    exact Finset.univ.filter fun γ => ¬ C.MutuallyGood pointRadius lineRadius L γ

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
