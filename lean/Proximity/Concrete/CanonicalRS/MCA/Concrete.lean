import Proximity.Concrete.CanonicalRS.MCA

/-
  Concrete canonical MCA instance.

  Paper correspondence:
  - Paper 1 Section 6: width-one canonical MCA comparison.
  - Paper 1 appendix ledger: cited-bound alignment theorem surface.

  This file is the comparison layer between the actual canonical RS/MCA object
  and the target theorem slot. It does not prove the deep RS MCA theorem; it
  names the fully concrete proposition and proves it is exactly the target
  proposition that `CanonicalRS.Bounds` expects.
-/

namespace Hcrypt
namespace Proximity
namespace CanonicalRS
namespace MCA
namespace Concrete

noncomputable section

/-- The concrete canonical RS parameters used by the MCA endpoint. -/
def parameters :
    ReedSolomon.Parameters RSField (Fin length) :=
  canonicalSmoothDomain.parameters

/-- The concrete canonical RS block code used in Definition 4.3. -/
def blockCode :
    BlockCode (Fin length) RSField :=
  parameters.toBlockCode

/-- The concrete MCA radius: the canonical Johnson-below relative radius. -/
noncomputable def radius : ℝ :=
  BlockCode.relativeRadius (ι := Fin length) johnsonBelowRadius

/-- The canonical MCA radius satisfies the paper-domain condition `0 < δ`. -/
theorem radius_pos : 0 < radius := by
  unfold radius BlockCode.relativeRadius johnsonBelowRadius length
  unfold ProximityPrize.BlockCode.relativeRadius
  norm_num

/-- The canonical MCA radius satisfies the paper-domain condition `δ < 1`. -/
theorem radius_lt_one : radius < 1 := by
  unfold radius BlockCode.relativeRadius johnsonBelowRadius length
  unfold ProximityPrize.BlockCode.relativeRadius
  norm_num

/-- The paper alphabet width for ordinary canonical RS symbols is `s = 1`. -/
def alphabetWidth : ℕ :=
  1

/-- The paper's admissible radius domain for MCA statements. -/
def paperRadiusDomain : Set ℝ :=
  Set.Ioo (0 : ℝ) 1

/-- The paper alphabet-width domain contains positive widths `s`. -/
def paperAlphabetWidthDomain : Set ℕ :=
  {s : ℕ | 0 < s}

/-- The ambient paper parameter domain relevant to this concrete endpoint. -/
def paperAmbientDomain : Set (ℝ × ℕ) :=
  {x : ℝ × ℕ | x.1 ∈ paperRadiusDomain ∧ x.2 ∈ paperAlphabetWidthDomain}

/-- The radius/width point selected by the canonical RS endpoint. -/
def canonicalAmbientPoint : ℝ × ℕ :=
  (radius, alphabetWidth)

/-- The canonical MCA radius lies in the paper interval `(0, 1)`. -/
theorem radius_mem_Ioo : radius ∈ Set.Ioo (0 : ℝ) 1 :=
  ⟨radius_pos, radius_lt_one⟩

/-- The canonical MCA radius lies in the paper radius domain. -/
theorem radius_mem_paperRadiusDomain : radius ∈ paperRadiusDomain := by
  simpa [paperRadiusDomain] using radius_mem_Ioo

/-- The canonical RS endpoint is the paper alphabet-width slice `s = 1`. -/
theorem alphabetWidth_eq_one : alphabetWidth = 1 :=
  rfl

/-- The canonical RS alphabet width lies in the paper alphabet-width domain. -/
theorem alphabetWidth_mem_paperAlphabetWidthDomain :
    alphabetWidth ∈ paperAlphabetWidthDomain := by
  simp [paperAlphabetWidthDomain, alphabetWidth]

/--
The canonical endpoint is an admissible point of the paper's wider ambient MCA
domain.
-/
theorem canonicalAmbientPoint_mem_paperAmbientDomain :
    canonicalAmbientPoint ∈ paperAmbientDomain := by
  exact ⟨radius_mem_paperRadiusDomain, alphabetWidth_mem_paperAlphabetWidthDomain⟩

/-- The width-one paper alphabet `(F^s)` specialized to canonical RS. -/
abbrev WidthOneSymbol :=
  Fin 1 → RSField

/-- Canonical paper words in the `s = 1` alphabet presentation. -/
abbrev WidthOneWord :=
  Word (Fin length) WidthOneSymbol

/-- Embed an ordinary canonical RS symbol into the `s = 1` paper alphabet. -/
def toWidthOneSymbol (a : RSField) : WidthOneSymbol :=
  fun _ => a

/-- Read the unique coordinate of a width-one paper symbol. -/
def ofWidthOneSymbol (a : WidthOneSymbol) : RSField :=
  a ⟨0, by decide⟩

/-- The `s = 1` embedding and projection are inverse on ordinary symbols. -/
@[simp]
theorem of_toWidthOneSymbol (a : RSField) :
    ofWidthOneSymbol (toWidthOneSymbol a) = a :=
  rfl

/-- Width-one paper symbols are determined by their unique coordinate. -/
@[simp]
theorem to_ofWidthOneSymbol (a : WidthOneSymbol) :
    toWidthOneSymbol (ofWidthOneSymbol a) = a := by
  funext j
  fin_cases j
  simp [toWidthOneSymbol, ofWidthOneSymbol]

/-- Embed ordinary canonical RS words into the paper's `s = 1` word alphabet. -/
def toWidthOneWord (w : FinalWord) : WidthOneWord :=
  fun i => toWidthOneSymbol (w i)

/-- Read ordinary canonical RS words from the paper's `s = 1` presentation. -/
def ofWidthOneWord (w : WidthOneWord) : FinalWord :=
  fun i => ofWidthOneSymbol (w i)

/-- The `s = 1` word embedding and projection are inverse on ordinary words. -/
@[simp]
theorem of_toWidthOneWord (w : FinalWord) :
    ofWidthOneWord (toWidthOneWord w) = w := by
  funext i
  rfl

/-- Width-one paper words are equivalent to ordinary canonical RS words. -/
@[simp]
theorem to_ofWidthOneWord (w : WidthOneWord) :
    toWidthOneWord (ofWidthOneWord w) = w := by
  funext i j
  fin_cases j
  simp [toWidthOneWord, ofWidthOneWord, toWidthOneSymbol, ofWidthOneSymbol]

/-- The paper-alphabet endpoint `(F^1)^n` for canonical RS. -/
def widthOneBlockCode :
    BlockCode (Fin length) WidthOneSymbol :=
  parameters.vectorBlockCode (Fin 1)

/-- Interpret a canonical scalar line in the paper's width-one alphabet. -/
def toWidthOnePaperLine (L : Line) :
    AffineLine RSField (Fin length) WidthOneSymbol where
  base := toWidthOneWord L.base
  direction := toWidthOneWord L.direction

/-- Read a width-one paper line as an ordinary canonical scalar line. -/
def ofWidthOnePaperLine
    (L : AffineLine RSField (Fin length) WidthOneSymbol) : Line where
  base := ofWidthOneWord L.base
  direction := ofWidthOneWord L.direction

/-- Width-one paper lines are equivalent to ordinary canonical lines. -/
@[simp]
theorem of_toWidthOnePaperLine (L : Line) :
    ofWidthOnePaperLine (toWidthOnePaperLine L) = L := by
  cases L
  simp [toWidthOnePaperLine, ofWidthOnePaperLine]

/-- Width-one paper lines are determined by their scalar line image. -/
@[simp]
theorem to_ofWidthOnePaperLine
    (L : AffineLine RSField (Fin length) WidthOneSymbol) :
    toWidthOnePaperLine (ofWidthOnePaperLine L) = L := by
  cases L
  simp [toWidthOnePaperLine, ofWidthOnePaperLine]

/-- Width-one paper-code codewords are exactly ordinary canonical RS codewords. -/
theorem widthOneCodeword_iff
    (w : WidthOneWord) :
    widthOneBlockCode.Codeword w ↔ blockCode.Codeword (ofWidthOneWord w) := by
  constructor
  · intro hw
    simpa [widthOneBlockCode, ofWidthOneWord, ofWidthOneSymbol]
      using hw ⟨0, by decide⟩
  · intro hw j
    fin_cases j
    simpa [widthOneBlockCode, ofWidthOneWord, ofWidthOneSymbol] using hw

/--
Closeness on a coordinate set is unchanged by passing between scalar canonical
RS words and the paper's `s = 1` alphabet.
-/
theorem widthOneCloseOnSet_iff
    (w : FinalWord) (S : Finset (Fin length)) :
    widthOneBlockCode.CloseOnSet (toWidthOneWord w) S ↔
      blockCode.CloseOnSet w S := by
  constructor
  · intro hw
    rcases hw with ⟨c, hc, hagree⟩
    refine ⟨ofWidthOneWord c, (widthOneCodeword_iff c).1 hc, ?_⟩
    intro i hi
    have h := hagree i hi
    exact congrArg ofWidthOneSymbol h
  · intro hw
    rcases hw with ⟨c, hc, hagree⟩
    refine ⟨toWidthOneWord c, (widthOneCodeword_iff (toWidthOneWord c)).2 ?_, ?_⟩
    · simpa using hc
    · intro i hi
      funext j
      fin_cases j
      simpa [toWidthOneWord, toWidthOneSymbol] using hagree i hi

/-- Width-one line evaluation agrees with scalar line evaluation. -/
theorem toWidthOnePaperLine_point
    (L : Line) (γ : RSField) :
    (toWidthOnePaperLine L).point γ = toWidthOneWord (L.point γ) := by
  funext i j
  fin_cases j
  simp [toWidthOnePaperLine, AffineLine.point, Line.point,
    Line.toPaperLine, toWidthOneWord, toWidthOneSymbol]

/--
The interleaved pair used by paper MCA is unchanged by the width-one alphabet
presentation.
-/
theorem widthOneInterleavedCloseOnSet_iff
    (L : Line) (S : Finset (Fin length)) :
    (widthOneBlockCode.interleaved (Fin 2)).CloseOnSet
        (BlockCode.pairWord
          (toWidthOneWord L.base)
          (toWidthOneWord L.direction))
        S ↔
      (blockCode.interleaved (Fin 2)).CloseOnSet
        (BlockCode.pairWord L.base L.direction)
        S := by
  constructor
  · intro hw
    rcases hw with ⟨c, hc, hagree⟩
    refine ⟨fun i k => ofWidthOneSymbol (c i k), ?_, ?_⟩
    · intro k
      exact (widthOneCodeword_iff (fun i => c i k)).1 (hc k)
    · intro i hi
      funext k
      let hk := congrArg ofWidthOneSymbol (congrFun (hagree i hi) k)
      fin_cases k <;>
        simpa [BlockCode.pairWord, toWidthOneWord, toWidthOneSymbol,
          ofWidthOneSymbol]
          using hk
  · intro hw
    rcases hw with ⟨c, hc, hagree⟩
    refine ⟨fun i k => toWidthOneSymbol (c i k), ?_, ?_⟩
    · intro k
      exact (widthOneCodeword_iff (fun i => toWidthOneSymbol (c i k))).2
        (by simpa [ofWidthOneWord, ofWidthOneSymbol, toWidthOneSymbol] using hc k)
    · intro i hi
      funext k j
      let hk := congrFun (hagree i hi) k
      fin_cases k <;> fin_cases j <;>
        simpa [BlockCode.pairWord, toWidthOneWord, toWidthOneSymbol,
          ofWidthOneSymbol]
          using hk

/-- The concrete MCA error fraction associated to a challenge threshold. -/
noncomputable def error (threshold : ℕ) : ℝ :=
  (threshold : ℝ) / (Fintype.card RSField : ℝ)

/-- Definition 4.3 bad challenges in the paper's width-one alphabet endpoint. -/
noncomputable def widthOneBadChallengeSet
    (L : Line) : Finset RSField :=
  widthOneBlockCode.paperMCABadParameterSet
    (F := RSField) radius (toWidthOnePaperLine L)

/-- Definition 4.3 bad challenges for the concrete canonical MCA line family. -/
noncomputable def badChallengeSet
    (L : Line) : Finset RSField :=
  blockCode.paperMCABadParameterSet (F := RSField) radius L.toPaperLine

/--
Endpoint equivalence: specializing the paper alphabet to `s = 1` gives exactly
the same MCA bad-challenge set as the scalar canonical RS endpoint.
-/
theorem widthOneBadChallengeSet_eq
    (L : Line) :
    widthOneBadChallengeSet L = badChallengeSet L := by
  classical
  apply Finset.ext
  intro γ
  simp only [widthOneBadChallengeSet, badChallengeSet]
  rw [BlockCode.mem_paperMCABadParameterSet,
    BlockCode.mem_paperMCABadParameterSet]
  constructor
  · intro h
    rcases h with ⟨S, hlarge, hclose, hpair⟩
    rw [toWidthOnePaperLine_point] at hclose
    refine ⟨S, hlarge, (widthOneCloseOnSet_iff (L.point γ) S).1 hclose, ?_⟩
    intro hscalarPair
    exact hpair ((widthOneInterleavedCloseOnSet_iff L S).2 hscalarPair)
  · intro h
    rcases h with ⟨S, hlarge, hclose, hpair⟩
    refine ⟨S, hlarge, ?_, ?_⟩
    · rw [toWidthOnePaperLine_point]
      exact (widthOneCloseOnSet_iff (L.point γ) S).2 hclose
    · intro hwidthPair
      exact hpair ((widthOneInterleavedCloseOnSet_iff L S).1 hwidthPair)

/-- Concrete bad-challenge fraction for a canonical MCA line. -/
noncomputable def badChallengeFraction
    (L : Line) : ℝ :=
  BlockCode.parameterFraction (badChallengeSet L)

/-- All bad-challenge fractions attained by concrete canonical MCA lines. -/
def badChallengeFractionRange : Set ℝ :=
  Set.range badChallengeFraction

/-- The upper envelope allowed by a proposed MCA challenge threshold. -/
def allowedErrorEnvelope (threshold : ℕ) : Set ℝ :=
  {x : ℝ | x ≤ error threshold}

/--
Concrete canonical MCA statement over the constructed canonical line object.

This is the theorem we ultimately want from a concrete RS MCA proof/import.
-/
def PaperMCAStatement (threshold : ℕ) : Prop :=
  ∀ L : Line, badChallengeFraction L ≤ error threshold

/--
The pointwise concrete MCA statement is exactly an inclusion check: every
attained bad-challenge fraction lies below the proposed error envelope.

This is the finite-line-family analogue of saying the paper's maximum error is
bounded by the proposed threshold, without introducing a separate max object.
-/
theorem paperMCAStatement_iff_fractionRange_subset
    (threshold : ℕ) :
    PaperMCAStatement threshold ↔
      badChallengeFractionRange ⊆ allowedErrorEnvelope threshold := by
  constructor
  · intro h x hx
    rcases hx with ⟨L, rfl⟩
    exact h L
  · intro h L
    exact h ⟨L, rfl⟩

/--
The target proposition expected by `CanonicalRS.Bounds`, written without the
projection-chain bridge data wrapper.
-/
def TargetPaperMCAStatement (threshold : ℕ) : Prop :=
  parameters.PaperMutualCorrelatedAgreementErrorBound
    radius
    (error threshold)

/--
The paper-alphabet target proposition at the canonical endpoint, with
`s = 1`, written over `(F^1)^n`.
-/
def WidthOneTargetPaperMCAStatement (threshold : ℕ) : Prop :=
  parameters.VectorPaperMutualCorrelatedAgreementErrorBound
    (Fin 1)
    radius
    (error threshold)

/--
The concrete canonical-line statement is equivalent to the target paper-MCA
slot. The forward direction converts a canonical line to the raw paper line;
the reverse direction converts any raw paper line to the canonical line object.
-/
theorem paperMCAStatement_iff_target
    (threshold : ℕ) :
    PaperMCAStatement threshold ↔ TargetPaperMCAStatement threshold := by
  constructor
  · intro h L
    change
      BlockCode.parameterFraction
          (blockCode.paperMCABadParameterSet (F := RSField) radius L) ≤
        error threshold
    simpa [PaperMCAStatement, badChallengeFraction, badChallengeSet]
      using h (Line.ofPaperLine L)
  · intro h L
    change
      BlockCode.parameterFraction
          (blockCode.paperMCABadParameterSet
            (F := RSField) radius L.toPaperLine) ≤
        error threshold
    exact h L.toPaperLine

/--
The vector-paper `s = 1` MCA target is equivalent to the scalar canonical MCA
statement at the endpoint.
-/
theorem paperMCAStatement_iff_widthOneTarget
    (threshold : ℕ) :
    PaperMCAStatement threshold ↔
      WidthOneTargetPaperMCAStatement threshold := by
  constructor
  · intro h L
    change
      BlockCode.parameterFraction
          (widthOneBlockCode.paperMCABadParameterSet
            (F := RSField) radius L) ≤
        error threshold
    have hs : BlockCode.parameterFraction
        (badChallengeSet (ofWidthOnePaperLine L)) ≤ error threshold :=
      h (ofWidthOnePaperLine L)
    rw [← widthOneBadChallengeSet_eq (ofWidthOnePaperLine L)] at hs
    simpa [widthOneBadChallengeSet] using hs
  · intro h L
    change
      BlockCode.parameterFraction (badChallengeSet L) ≤ error threshold
    rw [← widthOneBadChallengeSet_eq L]
    exact h (toWidthOnePaperLine L)

/-- A scalar canonical MCA proof fills the paper-vector `s = 1` target slot. -/
theorem concreteLines_imply_widthOneTargetPaperMCA
    {threshold : ℕ}
    (h : PaperMCAStatement threshold) :
    WidthOneTargetPaperMCAStatement threshold :=
  (paperMCAStatement_iff_widthOneTarget threshold).1 h

/-- A paper-vector `s = 1` target proof bounds every scalar canonical MCA line. -/
theorem widthOneTargetPaperMCA_implies_concreteLines
    {threshold : ℕ}
    (h : WidthOneTargetPaperMCAStatement threshold) :
    PaperMCAStatement threshold :=
  (paperMCAStatement_iff_widthOneTarget threshold).2 h

/--
This direction was already implicit in the endpoint theorem surface: a target
paper-MCA proof bounds every concrete canonical MCA line. We keep it explicit
here as a verification checkpoint for the concrete/target comparison.
-/
theorem targetPaperMCA_implies_concreteLines
    {threshold : ℕ}
    (h : TargetPaperMCAStatement threshold) :
    PaperMCAStatement threshold := by
  intro L
  change
    BlockCode.parameterFraction
        (blockCode.paperMCABadParameterSet
          (F := RSField) radius L.toPaperLine) ≤
      error threshold
  exact h L.toPaperLine

/--
Explicit reverse direction: a proof over the concrete canonical MCA line object
fills the raw paper target slot, because every raw paper line is represented by
`Line.ofPaperLine`.
-/
theorem concreteLines_imply_targetPaperMCA
    {threshold : ℕ}
    (h : PaperMCAStatement threshold) :
    TargetPaperMCAStatement threshold := by
  intro L
  change
    BlockCode.parameterFraction
        (blockCode.paperMCABadParameterSet (F := RSField) radius L) ≤
      error threshold
  simpa [PaperMCAStatement, badChallengeFraction, badChallengeSet]
    using h (Line.ofPaperLine L)

/-- A concrete canonical MCA proof fills the target theorem slot. -/
theorem toTargetPaperMCAStatement
    {threshold : ℕ}
    (h : PaperMCAStatement threshold) :
    TargetPaperMCAStatement threshold :=
  concreteLines_imply_targetPaperMCA h

/-- A target theorem-slot proof can be viewed as the concrete canonical MCA statement. -/
theorem ofTargetPaperMCAStatement
    {threshold : ℕ}
    (h : TargetPaperMCAStatement threshold) :
    PaperMCAStatement threshold :=
  targetPaperMCA_implies_concreteLines h

/--
The paper MCA target bound restricts to the concrete bad-fraction range as an
ordinary subset/envelope inclusion.
-/
theorem targetPaperMCA_implies_fractionRange_subset
    {threshold : ℕ}
    (h : TargetPaperMCAStatement threshold) :
    badChallengeFractionRange ⊆ allowedErrorEnvelope threshold :=
  (paperMCAStatement_iff_fractionRange_subset threshold).1
    (targetPaperMCA_implies_concreteLines h)

end

end Concrete
end MCA
end CanonicalRS
end Proximity
end Hcrypt
