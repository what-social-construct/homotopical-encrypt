module

public import Proximity.MCA.Definitions
public import Proximity.Core.FiniteThreshold

@[expose] public section

/-!
# Exact finite-grid thresholds for mutual correlated agreement

This module turns the per-affine-line bad-challenge set into an exact
worst-case count.  The maximum is taken over `PlaneWord`; the equivalence
`planeLineEquiv` then transports its universal property to arbitrary affine
lines.  This avoids installing a separate `Fintype` instance for the
`AffineLine` structure.

Security is expressed by the exact integer inequality

`2 ^ securityBits * worstBadCount ≤ |F|`.

The finite-threshold wrappers expose the safe radii, greatest safe radius, and
first unsafe radius on the count grid `0, ..., n`.
-/

namespace ProximityCoding
namespace BlockCode

section WorstBadCount

variable {ι F : Type*}
variable [Fintype ι] [Fintype F]
variable [Add F] [Mul F]

/--
The largest number of bad challenges on any affine line at count radius `r`.

The finite supremum is indexed by planes and transported to affine lines
through `planeLineEquiv`.
-/
noncomputable def worstBadCount
    (C : BlockCode ι F)
    (r : ℕ) : ℕ := by
  classical
  exact Finset.univ.sup fun p : PlaneWord ι F =>
    (C.badChallengeSet r (planeLineEquiv ι F p)).card

/--
Paper-facing name for the exact bad-count spectrum `B_C(r)`.

This is an abbreviation rather than a second definition, so code-specific
upper and lower bounds can be imported without any conversion theorem.
-/
noncomputable abbrev paperMCABadSpectrum
    (C : BlockCode ι F)
    (r : ℕ) : ℕ :=
  C.worstBadCount r

/-- For a nonempty challenge type, the finite bad-count maximum is attained. -/
theorem exists_badChallengeSet_card_eq_worstBadCount
    [Nonempty F]
    (C : BlockCode ι F)
    (r : ℕ) :
    ∃ L : AffineLine ι F,
      (C.badChallengeSet r L).card = C.worstBadCount r := by
  classical
  obtain ⟨p, _hp, hmax⟩ := Finset.exists_mem_eq_sup
    (Finset.univ : Finset (PlaneWord ι F))
    Finset.univ_nonempty
    (fun p : PlaneWord ι F =>
      (C.badChallengeSet r (planeLineEquiv ι F p)).card)
  refine ⟨planeLineEquiv ι F p, ?_⟩
  unfold worstBadCount
  exact hmax.symm

/--
The worst bad count is the least uniform upper bound over all affine lines.
-/
theorem worstBadCount_le_iff
    (C : BlockCode ι F)
    (r threshold : ℕ) :
    C.worstBadCount r ≤ threshold ↔
      ∀ L : AffineLine ι F,
        (C.badChallengeSet r L).card ≤ threshold := by
  classical
  unfold worstBadCount
  rw [Finset.sup_le_iff]
  simp only [Finset.mem_univ, forall_const]
  constructor
  · intro h L
    simpa using h ((planeLineEquiv ι F).symm L)
  · intro h p
    exact h (planeLineEquiv ι F p)

/-- Every affine line is bounded by the exact worst bad count. -/
theorem badChallengeSet_card_le_worstBadCount
    (C : BlockCode ι F)
    (r : ℕ)
    (L : AffineLine ι F) :
    (C.badChallengeSet r L).card ≤ C.worstBadCount r :=
  (C.worstBadCount_le_iff r (C.worstBadCount r)).mp le_rfl L

/-- The existing per-line count predicate is exactly a worst-count bound. -/
theorem pairMCACountBound_iff_worstBadCount_le
    (C : BlockCode ι F)
    (r threshold : ℕ) :
    C.PairMCACountBound r threshold ↔
      C.worstBadCount r ≤ threshold := by
  unfold PairMCACountBound
  exact (C.worstBadCount_le_iff r threshold).symm

/-- Increasing the count radius can only add bad challenges on a fixed line. -/
theorem badChallengeSet_mono
    (C : BlockCode ι F)
    (L : AffineLine ι F)
    {r s : ℕ}
    (hrs : r ≤ s) :
    C.badChallengeSet r L ⊆ C.badChallengeSet s L := by
  classical
  intro γ hγ
  rw [C.mem_badChallengeSet r L γ] at hγ
  rw [C.mem_badChallengeSet s L γ]
  rcases hγ with ⟨S, hlarge, hbad⟩
  refine ⟨S, ?_, hbad⟩
  exact hlarge.trans (Nat.add_le_add_left hrs S.card)

/-- The exact worst bad count is monotone in the count radius. -/
theorem worstBadCount_mono
    (C : BlockCode ι F) :
    Monotone C.worstBadCount := by
  intro r s hrs
  apply (C.worstBadCount_le_iff r (C.worstBadCount s)).mpr
  intro L
  exact (Finset.card_le_card (C.badChallengeSet_mono L hrs)).trans
    (C.badChallengeSet_card_le_worstBadCount s L)

end WorstBadCount

section IntegerSecurity

variable {ι F : Type*}
variable [Fintype ι] [Fintype F]
variable [Add F] [Mul F]

/--
Exact integer pair-MCA security at count radius `r`.

No division or real-number rounding is present: the failure probability is at
most `2⁻securityBits` exactly when the displayed integer budget holds.
-/
def PairMCASecureAtBits
    (C : BlockCode ι F)
    (securityBits r : ℕ) : Prop :=
  2 ^ securityBits * C.worstBadCount r ≤ Fintype.card F

/--
A uniform per-line count bound and a field budget imply exact integer
pair-MCA security.
-/
theorem pairMCASecureAtBits_of_countBound
    (C : BlockCode ι F)
    {securityBits r threshold : ℕ}
    (hcount : C.PairMCACountBound r threshold)
    (hbudget : 2 ^ securityBits * threshold ≤ Fintype.card F) :
    C.PairMCASecureAtBits securityBits r := by
  unfold PairMCASecureAtBits
  exact (Nat.mul_le_mul_left (2 ^ securityBits)
    ((C.pairMCACountBound_iff_worstBadCount_le r threshold).mp hcount)).trans
      hbudget

/-- Exact integer security implies the scaled budget on every affine line. -/
theorem scaled_badChallengeSet_card_le_of_pairMCASecureAtBits
    (C : BlockCode ι F)
    {securityBits r : ℕ}
    (hsecure : C.PairMCASecureAtBits securityBits r)
    (L : AffineLine ι F) :
    2 ^ securityBits * (C.badChallengeSet r L).card ≤
      Fintype.card F := by
  exact (Nat.mul_le_mul_left (2 ^ securityBits)
    (C.badChallengeSet_card_le_worstBadCount r L)).trans hsecure

/--
Exact integer security is equivalent to the scaled count budget on every
affine line.
-/
theorem pairMCASecureAtBits_iff_scaled_line_budget
    (C : BlockCode ι F)
    (securityBits r : ℕ) :
    C.PairMCASecureAtBits securityBits r ↔
      ∀ L : AffineLine ι F,
        2 ^ securityBits * (C.badChallengeSet r L).card ≤
          Fintype.card F := by
  constructor
  · intro hsecure L
    exact C.scaled_badChallengeSet_card_le_of_pairMCASecureAtBits hsecure L
  · intro hlines
    have hpow : 0 < 2 ^ securityBits := by positivity
    have hworst :
        C.worstBadCount r ≤ Fintype.card F / 2 ^ securityBits := by
      apply (C.worstBadCount_le_iff r
        (Fintype.card F / 2 ^ securityBits)).mpr
      intro L
      apply (Nat.le_div_iff_mul_le hpow).mpr
      simpa [Nat.mul_comm] using hlines L
    unfold PairMCASecureAtBits
    have hscaled := (Nat.le_div_iff_mul_le hpow).mp hworst
    simpa [Nat.mul_comm] using hscaled

omit [Add F] [Mul F] in
/--
For a nonempty finite challenge type, the real probability budget
`|S| / |F| ≤ 2⁻ᵇ` is exactly the corresponding integer count budget.
-/
theorem challengeFraction_le_invPow_iff_scaled_card_le
    [Nonempty F]
    (S : Finset F)
    (securityBits : ℕ) :
    challengeFraction S ≤ (1 : ℝ) / (2 ^ securityBits : ℝ) ↔
      2 ^ securityBits * S.card ≤ Fintype.card F := by
  have hfield : (0 : ℝ) < Fintype.card F := by
    exact_mod_cast Fintype.card_pos
  have hpow : (0 : ℝ) < (2 ^ securityBits : ℝ) := by positivity
  unfold challengeFraction
  rw [div_le_div_iff₀ hfield hpow]
  norm_cast
  simp only [one_mul, Nat.mul_comm]

/--
Operational equivalence between the paper's real pair-MCA error statement at
a normalized count radius and the exact integer security predicate.
-/
theorem pairMCAErrorBoundAt_relativeRadius_invPow_iff_secureAtBits
    [Nonempty F]
    (C : BlockCode ι F)
    {r securityBits : ℕ}
    (hlength : 0 < Fintype.card ι) :
    C.PairMCAErrorBoundAt
        (relativeRadius (ι := ι) r)
        ((1 : ℝ) / (2 ^ securityBits : ℝ)) ↔
      C.PairMCASecureAtBits securityBits r := by
  rw [C.pairMCAErrorBoundAt_relativeRadius_iff hlength]
  rw [C.pairMCASecureAtBits_iff_scaled_line_budget]
  constructor
  · intro h L
    exact (challengeFraction_le_invPow_iff_scaled_card_le
      (C.badChallengeSet r L) securityBits).mp (h L)
  · intro h L
    exact (challengeFraction_le_invPow_iff_scaled_card_le
      (C.badChallengeSet r L) securityBits).mpr (h L)

/--
Paper-facing form of the exact spectrum criterion
`ε_MCA(C, r/n) ≤ 2⁻ᵇ ↔ 2ᵇ B_C(r) ≤ |F|`.
-/
theorem pairMCAErrorBoundAt_relativeRadius_invPow_iff_spectrum_budget
    [Nonempty F]
    (C : BlockCode ι F)
    {r securityBits : ℕ}
    (hlength : 0 < Fintype.card ι) :
    C.PairMCAErrorBoundAt
        (relativeRadius (ι := ι) r)
        ((1 : ℝ) / (2 ^ securityBits : ℝ)) ↔
      2 ^ securityBits * C.paperMCABadSpectrum r ≤ Fintype.card F := by
  simpa only [PairMCASecureAtBits] using
    C.pairMCAErrorBoundAt_relativeRadius_invPow_iff_secureAtBits
      (securityBits := securityBits) hlength

/-- Exact integer pair-MCA security is antitone in the count radius. -/
theorem pairMCASecureAtBits_antitone
    (C : BlockCode ι F)
    (securityBits : ℕ) :
    Antitone (C.PairMCASecureAtBits securityBits) := by
  intro r s hrs hsecure
  unfold PairMCASecureAtBits at hsecure ⊢
  exact (Nat.mul_le_mul_left (2 ^ securityBits)
    (C.worstBadCount_mono hrs)).trans hsecure

end IntegerSecurity

section ThresholdGrid

variable {ι F : Type*}
variable [Fintype ι] [Fintype F]
variable [Add F] [Mul F]

/-- Count radii `0, ..., n` available to the code. -/
def pairMCARadiusGrid : Finset ℕ :=
  FiniteThreshold.grid (Fintype.card ι)

/-- Secure count radii on the finite code-length grid. -/
noncomputable def pairMCASafeGrid
    (C : BlockCode ι F)
    (securityBits : ℕ) : Finset ℕ :=
  FiniteThreshold.safeSet (Fintype.card ι)
    (C.PairMCASecureAtBits securityBits)

/-- The greatest secure count radius, or `⊥` if none is secure. -/
noncomputable def pairMCAGreatestSafe
    (C : BlockCode ι F)
    (securityBits : ℕ) : WithBot ℕ :=
  FiniteThreshold.greatestSafe (Fintype.card ι)
    (C.PairMCASecureAtBits securityBits)

/-- The first insecure count radius, or `⊤` if every grid radius is secure. -/
noncomputable def pairMCAFirstUnsafe
    (C : BlockCode ι F)
    (securityBits : ℕ) : WithTop ℕ :=
  FiniteThreshold.firstUnsafe (Fintype.card ι)
    (C.PairMCASecureAtBits securityBits)

@[simp]
theorem mem_pairMCARadiusGrid {r : ℕ} :
    r ∈ pairMCARadiusGrid (ι := ι) ↔ r ≤ Fintype.card ι :=
  FiniteThreshold.mem_grid

@[simp]
theorem mem_pairMCASafeGrid
    (C : BlockCode ι F)
    (securityBits r : ℕ) :
    r ∈ C.pairMCASafeGrid securityBits ↔
      r ≤ Fintype.card ι ∧ C.PairMCASecureAtBits securityBits r :=
  FiniteThreshold.mem_safeSet

/--
A safe radius followed by an unsafe radius gives the generic exact-grid
certificate.  Radius antitonicity is supplied by the worst-count construction.
-/
theorem pairMCAExactGridCertificate
    (C : BlockCode ι F)
    {securityBits radius : ℕ}
    (hradius : radius < Fintype.card ι)
    (hsafe : C.PairMCASecureAtBits securityBits radius)
    (hnext : ¬ C.PairMCASecureAtBits securityBits (radius + 1)) :
    FiniteThreshold.ExactGridCertificate
      (Fintype.card ι)
      (C.PairMCASecureAtBits securityBits)
      radius where
  radius_lt := hradius
  antitone_good := C.pairMCASecureAtBits_antitone securityBits
  good := hsafe
  next_unsafe := hnext

/-- A safe/next-unsafe certificate pins the greatest secure grid radius. -/
theorem pairMCAGreatestSafe_eq_of_safe_next_unsafe
    (C : BlockCode ι F)
    {securityBits radius : ℕ}
    (hradius : radius < Fintype.card ι)
    (hsafe : C.PairMCASecureAtBits securityBits radius)
    (hnext : ¬ C.PairMCASecureAtBits securityBits (radius + 1)) :
    C.pairMCAGreatestSafe securityBits = (radius : WithBot ℕ) := by
  exact (C.pairMCAExactGridCertificate hradius hsafe hnext).greatestSafe_eq

/-- A safe/next-unsafe certificate pins the first insecure grid radius. -/
theorem pairMCAFirstUnsafe_eq_of_safe_next_unsafe
    (C : BlockCode ι F)
    {securityBits radius : ℕ}
    (hradius : radius < Fintype.card ι)
    (hsafe : C.PairMCASecureAtBits securityBits radius)
    (hnext : ¬ C.PairMCASecureAtBits securityBits (radius + 1)) :
    C.pairMCAFirstUnsafe securityBits =
      ((radius + 1 : ℕ) : WithTop ℕ) := by
  exact (C.pairMCAExactGridCertificate hradius hsafe hnext).firstUnsafe_eq

/--
A safe/next-unsafe certificate simultaneously pins both finite-grid endpoints.
-/
theorem pairMCAThreshold_eq_of_safe_next_unsafe
    (C : BlockCode ι F)
    {securityBits radius : ℕ}
    (hradius : radius < Fintype.card ι)
    (hsafe : C.PairMCASecureAtBits securityBits radius)
    (hnext : ¬ C.PairMCASecureAtBits securityBits (radius + 1)) :
    C.pairMCAGreatestSafe securityBits = (radius : WithBot ℕ) ∧
      C.pairMCAFirstUnsafe securityBits =
        ((radius + 1 : ℕ) : WithTop ℕ) :=
  ⟨C.pairMCAGreatestSafe_eq_of_safe_next_unsafe hradius hsafe hnext,
    C.pairMCAFirstUnsafe_eq_of_safe_next_unsafe hradius hsafe hnext⟩

end ThresholdGrid

end BlockCode
end ProximityCoding
