import Proximity.Core.PlanePair

/-!
# Generic mutual-correlated-agreement definitions

This file records the code-independent vocabulary used by the paper's
two-coordinate mutual correlated agreement experiment.  It deliberately
depends only on the generic block-code and affine-plane layer.  Reed--Solomon
interpolation, certificate bounds, and concrete field budgets belong in
downstream modules.

Both count radii and paper-facing relative radii are exposed.  At a normalized
count radius the two presentations agree exactly when the block length is
positive.
-/

namespace ProximityPrize
namespace BlockCode

section AgreementSets

variable {ι α : Type*} [Fintype ι]

/-- A count-radius agreement set: at most `r` coordinates lie outside `S`. -/
def LargeAgreementSet (r : ℕ) (S : Finset ι) : Prop :=
  Fintype.card ι ≤ S.card + r

/-- Fraction of coordinates contained in an agreement set. -/
noncomputable def coordinateFraction (S : Finset ι) : ℝ :=
  (S.card : ℝ) / (Fintype.card ι : ℝ)

/-- Paper-facing agreement-set condition `|S| / n ≥ 1 - δ`. -/
def LargeAgreementSetAt (δ : ℝ) (S : Finset ι) : Prop :=
  1 - δ ≤ coordinateFraction S

/-- Two words agree on every coordinate in `S`. -/
def AgreesOn (w c : Word ι α) (S : Finset ι) : Prop :=
  ∀ i : ι, i ∈ S → w i = c i

/-- A received word agrees on `S` with some codeword of `C`. -/
def CloseOnSet
    (C : BlockCode ι α) (w : Word ι α) (S : Finset ι) : Prop :=
  ∃ c : Word ι α, C.Codeword c ∧ AgreesOn w c S

/-- A word agrees with the code on some count-radius large set. -/
def CloseOnLargeSet
    (C : BlockCode ι α) (r : ℕ) (w : Word ι α) : Prop :=
  ∃ S : Finset ι, LargeAgreementSet r S ∧ C.CloseOnSet w S

/-- A word agrees with the code on some relative-radius large set. -/
def CloseOnLargeSetAt
    (C : BlockCode ι α) (δ : ℝ) (w : Word ι α) : Prop :=
  ∃ S : Finset ι, LargeAgreementSetAt δ S ∧ C.CloseOnSet w S

/--
Relative largeness at the normalized count radius is exactly count largeness.
-/
theorem largeAgreementSetAt_relativeRadius_iff
    {r : ℕ} {S : Finset ι}
    (hlength : 0 < Fintype.card ι) :
    LargeAgreementSetAt (relativeRadius (ι := ι) r) S ↔
      LargeAgreementSet r S := by
  have hlengthReal : (0 : ℝ) < Fintype.card ι := by
    exact_mod_cast hlength
  unfold LargeAgreementSetAt coordinateFraction relativeRadius
    LargeAgreementSet
  rw [sub_le_iff_le_add, ← add_div, le_div_iff₀ hlengthReal]
  norm_cast
  simp

/-- The count-first orientation of `largeAgreementSetAt_relativeRadius_iff`. -/
theorem largeAgreementSet_iff_largeAgreementSetAt_relativeRadius
    {r : ℕ} {S : Finset ι}
    (hlength : 0 < Fintype.card ι) :
    LargeAgreementSet r S ↔
      LargeAgreementSetAt (relativeRadius (ι := ι) r) S :=
  (largeAgreementSetAt_relativeRadius_iff hlength).symm

end AgreementSets

section PairWords

variable {ι F : Type*}

/-- The two-coordinate word consisting of an affine line's base and direction. -/
def pairWord (L : AffineLine ι F) : PlaneWord ι F :=
  fun i j => if j = 0 then L.base i else L.direction i

@[simp]
theorem pairWord_zero (L : AffineLine ι F) (i : ι) :
    pairWord L i 0 = L.base i := by
  simp [pairWord]

@[simp]
theorem pairWord_one (L : AffineLine ι F) (i : ι) :
    pairWord L i 1 = L.direction i := by
  simp [pairWord]

end PairWords

section PairAgreement

variable {ι F : Type*}

/--
The base and direction of `L` agree on `S` with one codeword of the
two-fold interleaving `C≡2`.
-/
def PairCloseOnSet
    (C : BlockCode ι F)
    (L : AffineLine ι F)
    (S : Finset ι) : Prop :=
  (C.interleaved (Fin 2)).CloseOnSet (pairWord L) S

/-- Expanded witness form of pair agreement on a fixed coordinate set. -/
theorem pairCloseOnSet_iff
    (C : BlockCode ι F)
    (L : AffineLine ι F)
    (S : Finset ι) :
    C.PairCloseOnSet L S ↔
      ∃ c : PlaneWord ι F,
        (C.interleaved (Fin 2)).Codeword c ∧
          ∀ i : ι, i ∈ S → pairWord L i = c i :=
  Iff.rfl

end PairAgreement

section BadChallenges

variable {ι F : Type*}
variable [Fintype ι] [Fintype F]
variable [Add F] [Mul F]

/--
A same-set MCA failure: the challenged scalar word agrees with `C` on `S`,
but the base/direction pair does not agree with `C≡2` on that same set.
-/
def BadOnSet
    (C : BlockCode ι F)
    (L : AffineLine ι F)
    (γ : F)
    (S : Finset ι) : Prop :=
  C.CloseOnSet (L.point γ) S ∧ ¬ C.PairCloseOnSet L S

/-- Bad challenges witnessed by a count-radius large agreement set. -/
noncomputable def badChallengeSet
    (C : BlockCode ι F)
    (r : ℕ)
    (L : AffineLine ι F) : Finset F := by
  classical
  exact Finset.univ.filter fun γ =>
    ∃ S : Finset ι, LargeAgreementSet r S ∧ C.BadOnSet L γ S

/-- Bad challenges from the paper's relative-radius MCA definition. -/
noncomputable def badChallengeSetAt
    (C : BlockCode ι F)
    (δ : ℝ)
    (L : AffineLine ι F) : Finset F := by
  classical
  exact Finset.univ.filter fun γ =>
    ∃ S : Finset ι, LargeAgreementSetAt δ S ∧ C.BadOnSet L γ S

/-- Membership in the count-radius MCA bad-challenge set. -/
theorem mem_badChallengeSet
    (C : BlockCode ι F)
    (r : ℕ)
    (L : AffineLine ι F)
    (γ : F) :
    γ ∈ C.badChallengeSet r L ↔
      ∃ S : Finset ι,
        LargeAgreementSet r S ∧ C.BadOnSet L γ S := by
  classical
  simp [badChallengeSet]

/-- Membership in the paper-facing MCA bad-challenge set. -/
theorem mem_badChallengeSetAt
    (C : BlockCode ι F)
    (δ : ℝ)
    (L : AffineLine ι F)
    (γ : F) :
    γ ∈ C.badChallengeSetAt δ L ↔
      ∃ S : Finset ι,
        LargeAgreementSetAt δ S ∧ C.BadOnSet L γ S := by
  classical
  simp [badChallengeSetAt]

/--
The paper's `Definition 4.3` name for the relative-radius bad-challenge set.
-/
noncomputable abbrev paperMCABadParameterSet
    (C : BlockCode ι F)
    (δ : ℝ)
    (L : AffineLine ι F) : Finset F :=
  C.badChallengeSetAt δ L

/-- Membership in the paper `Definition 4.3` bad-challenge set. -/
theorem mem_paperMCABadParameterSet
    (C : BlockCode ι F)
    (δ : ℝ)
    (L : AffineLine ι F)
    (γ : F) :
    γ ∈ C.paperMCABadParameterSet δ L ↔
      ∃ S : Finset ι,
        LargeAgreementSetAt δ S ∧ C.BadOnSet L γ S :=
  C.mem_badChallengeSetAt δ L γ

/--
At a normalized count radius, the relative and count bad-challenge sets are
identical.
-/
theorem badChallengeSetAt_relativeRadius_eq
    (C : BlockCode ι F)
    {r : ℕ}
    (hlength : 0 < Fintype.card ι)
    (L : AffineLine ι F) :
    C.badChallengeSetAt (relativeRadius (ι := ι) r) L =
      C.badChallengeSet r L := by
  classical
  ext γ
  simp only [mem_badChallengeSetAt, mem_badChallengeSet]
  constructor
  · rintro ⟨S, hlarge, hbad⟩
    exact ⟨S,
      (largeAgreementSetAt_relativeRadius_iff hlength).1 hlarge, hbad⟩
  · rintro ⟨S, hlarge, hbad⟩
    exact ⟨S,
      (largeAgreementSetAt_relativeRadius_iff hlength).2 hlarge, hbad⟩

end BadChallenges

section ErrorBounds

variable {ι F : Type*}
variable [Fintype ι] [Fintype F]
variable [Add F] [Mul F]

/-- Fraction of finite field challenges contained in a parameter set. -/
noncomputable def challengeFraction (S : Finset F) : ℝ :=
  (S.card : ℝ) / (Fintype.card F : ℝ)

/-- A uniform count bound on same-set MCA-bad challenges. -/
def PairMCACountBound
    (C : BlockCode ι F)
    (r threshold : ℕ) : Prop :=
  ∀ L : AffineLine ι F,
    (C.badChallengeSet r L).card ≤ threshold

/-- A uniform relative-radius pair-MCA error bound. -/
def PairMCAErrorBoundAt
    (C : BlockCode ι F)
    (δ ε : ℝ) : Prop :=
  ∀ L : AffineLine ι F,
    challengeFraction (C.badChallengeSetAt δ L) ≤ ε

/--
Paper-facing mutual-correlated-agreement error-bound predicate:
`ε_mca(C, δ) ≤ ε`.
-/
def PaperMutualCorrelatedAgreementErrorBound
    (C : BlockCode ι F)
    (δ ε : ℝ) : Prop :=
  C.PairMCAErrorBoundAt δ ε

/-- The paper-facing predicate unfolds to the generic pair-MCA predicate. -/
theorem paperMutualCorrelatedAgreementErrorBound_iff
    (C : BlockCode ι F)
    (δ ε : ℝ) :
    C.PaperMutualCorrelatedAgreementErrorBound δ ε ↔
      C.PairMCAErrorBoundAt δ ε :=
  Iff.rfl

/-- Count and normalized-radius error predicates coincide at positive length. -/
theorem pairMCAErrorBoundAt_relativeRadius_iff
    (C : BlockCode ι F)
    {r : ℕ}
    (hlength : 0 < Fintype.card ι)
    (ε : ℝ) :
    C.PairMCAErrorBoundAt (relativeRadius (ι := ι) r) ε ↔
      ∀ L : AffineLine ι F,
        challengeFraction (C.badChallengeSet r L) ≤ ε := by
  unfold PairMCAErrorBoundAt
  simp_rw [C.badChallengeSetAt_relativeRadius_eq hlength]

end ErrorBounds

end BlockCode
end ProximityPrize
