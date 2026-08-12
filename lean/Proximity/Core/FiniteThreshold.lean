import Mathlib.Data.Finset.Max
import Mathlib.Data.Finset.Range

/-!
# Finite threshold grids

This module packages the order theory shared by finite-radius proximity
statements.  A predicate `Good r` is inspected on the count grid
`0, ..., n`; no coding-theoretic definitions occur here.
-/

namespace ProximityPrize
namespace FiniteThreshold

/-- The natural-number radius grid `0, ..., n`. -/
def grid (n : ℕ) : Finset ℕ :=
  Finset.range (n + 1)

@[simp]
theorem mem_grid {n r : ℕ} :
    r ∈ grid n ↔ r ≤ n := by
  simpa only [grid, Finset.mem_range] using
    (Nat.lt_add_one_iff (m := r) (n := n))

/-- Grid radii at which `Good` holds. -/
noncomputable def safeSet (n : ℕ) (Good : ℕ → Prop) : Finset ℕ := by
  classical
  exact (grid n).filter Good

/-- Grid radii at which `Good` fails. -/
noncomputable def unsafeSet (n : ℕ) (Good : ℕ → Prop) : Finset ℕ := by
  classical
  exact (grid n).filter fun r => ¬ Good r

@[simp]
theorem mem_safeSet {n r : ℕ} {Good : ℕ → Prop} :
    r ∈ safeSet n Good ↔ r ≤ n ∧ Good r := by
  classical
  simp [safeSet]

@[simp]
theorem mem_unsafeSet {n r : ℕ} {Good : ℕ → Prop} :
    r ∈ unsafeSet n Good ↔ r ≤ n ∧ ¬ Good r := by
  classical
  simp [unsafeSet]

/--
The greatest safe grid radius, or `⊥` when no grid radius is safe.

Using `WithBot` keeps the definition total without assuming that radius zero
is safe for every application.
-/
noncomputable def greatestSafe (n : ℕ) (Good : ℕ → Prop) : WithBot ℕ :=
  (safeSet n Good).max

/-- The first unsafe grid radius, or `⊤` when every grid radius is safe. -/
noncomputable def firstUnsafe (n : ℕ) (Good : ℕ → Prop) : WithTop ℕ :=
  (unsafeSet n Good).min

/-- A count radius is the greatest safe point of the finite grid. -/
def IsGreatestSafe (n : ℕ) (Good : ℕ → Prop) (r : ℕ) : Prop :=
  r ≤ n ∧ Good r ∧ ∀ s, s ≤ n → Good s → s ≤ r

/-- A count radius is the first unsafe point of the finite grid. -/
def IsFirstUnsafe (n : ℕ) (Good : ℕ → Prop) (r : ℕ) : Prop :=
  r ≤ n ∧ ¬ Good r ∧ ∀ s, s ≤ n → ¬ Good s → r ≤ s

theorem greatestSafe_eq_coe_iff {n r : ℕ} {Good : ℕ → Prop} :
    greatestSafe n Good = (r : WithBot ℕ) ↔
      IsGreatestSafe n Good r := by
  classical
  constructor
  · intro h
    have hrmem : r ∈ safeSet n Good :=
      Finset.mem_of_max h
    have hr := mem_safeSet.mp hrmem
    exact ⟨hr.1, hr.2, fun s _ hs =>
      Finset.le_max_of_eq (by simp [hs, ‹s ≤ n›]) h⟩
  · rintro ⟨hrn, hr, hmax⟩
    apply le_antisymm
    · exact Finset.max_le fun s hs => by
        exact_mod_cast hmax s (mem_safeSet.mp hs).1 (mem_safeSet.mp hs).2
    · exact Finset.le_max (by simp [hrn, hr])

theorem firstUnsafe_eq_coe_iff {n r : ℕ} {Good : ℕ → Prop} :
    firstUnsafe n Good = (r : WithTop ℕ) ↔
      IsFirstUnsafe n Good r := by
  classical
  constructor
  · intro h
    have hrmem : r ∈ unsafeSet n Good :=
      Finset.mem_of_min h
    have hr := mem_unsafeSet.mp hrmem
    exact ⟨hr.1, hr.2, fun s _ hs =>
      Finset.min_le_of_eq (by simp [hs, ‹s ≤ n›]) h⟩
  · rintro ⟨hrn, hr, hmin⟩
    apply le_antisymm
    · exact Finset.min_le (by simp [hrn, hr])
    · exact Finset.le_min fun s hs => by
        exact_mod_cast hmin s (mem_unsafeSet.mp hs).1 (mem_unsafeSet.mp hs).2

/--
For a downward-closed predicate, a safe radius followed by an unsafe radius is
the greatest safe point of any finite grid containing the safe radius.
-/
theorem isGreatestSafe_of_antitone
    {n r : ℕ} {Good : ℕ → Prop}
    (hrn : r ≤ n)
    (hanti : Antitone Good)
    (hr : Good r)
    (hnext : ¬ Good (r + 1)) :
    IsGreatestSafe n Good r := by
  refine ⟨hrn, hr, ?_⟩
  intro s _ hs
  by_contra hsr
  have hrs : r + 1 ≤ s :=
    Nat.succ_le_iff.mpr (Nat.lt_of_not_ge hsr)
  exact hnext (hanti hrs hs)

/--
For a downward-closed predicate, a safe/unsafe adjacent pair pins the greatest
safe grid radius.
-/
theorem greatestSafe_eq_of_antitone
    {n r : ℕ} {Good : ℕ → Prop}
    (hrn : r ≤ n)
    (hanti : Antitone Good)
    (hr : Good r)
    (hnext : ¬ Good (r + 1)) :
    greatestSafe n Good = (r : WithBot ℕ) :=
  greatestSafe_eq_coe_iff.mpr
    (isGreatestSafe_of_antitone hrn hanti hr hnext)

/--
If the adjacent unsafe radius remains inside the grid, it is also the first
unsafe grid point.
-/
theorem firstUnsafe_eq_of_antitone
    {n r : ℕ} {Good : ℕ → Prop}
    (hrn : r < n)
    (hanti : Antitone Good)
    (hr : Good r)
    (hnext : ¬ Good (r + 1)) :
    firstUnsafe n Good = ((r + 1 : ℕ) : WithTop ℕ) := by
  apply firstUnsafe_eq_coe_iff.mpr
  refine ⟨Nat.succ_le_iff.mpr hrn, hnext, ?_⟩
  intro s _ hs
  by_contra hrs
  have hsr : s ≤ r :=
    Nat.lt_succ_iff.mp (Nat.lt_of_not_ge hrs)
  exact hs (hanti hsr hr)

/--
If a downward-closed predicate already fails at zero, the finite grid has no
safe point.
-/
theorem greatestSafe_eq_bot_of_antitone_not_zero
    {n : ℕ} {Good : ℕ → Prop}
    (hanti : Antitone Good)
    (hzero : ¬ Good 0) :
    greatestSafe n Good = ⊥ := by
  rw [greatestSafe, Finset.max_eq_bot]
  apply Finset.eq_empty_iff_forall_notMem.mpr
  intro r hr
  exact hzero (hanti (Nat.zero_le r) (mem_safeSet.mp hr).2)

/-- If zero is unsafe, it is the first unsafe point of every natural grid. -/
theorem firstUnsafe_eq_zero_of_not_good
    {n : ℕ} {Good : ℕ → Prop}
    (hzero : ¬ Good 0) :
    firstUnsafe n Good = ((0 : ℕ) : WithTop ℕ) := by
  apply firstUnsafe_eq_coe_iff.mpr
  exact ⟨Nat.zero_le n, hzero, fun s _ _ => Nat.zero_le s⟩

/--
A reusable certificate that pins an interior threshold on a finite count grid.

The certificate proves both that `radius` is the greatest safe value and that
`radius + 1` is the first unsafe value.
-/
structure ExactGridCertificate
    (n : ℕ) (Good : ℕ → Prop) (radius : ℕ) : Prop where
  radius_lt : radius < n
  antitone_good : Antitone Good
  good : Good radius
  next_unsafe : ¬ Good (radius + 1)

namespace ExactGridCertificate

variable {n radius : ℕ} {Good : ℕ → Prop}

theorem good_iff_le_radius
    (h : ExactGridCertificate n Good radius) (s : ℕ) :
    Good s ↔ s ≤ radius := by
  constructor
  · intro hs
    by_contra hsr
    have hrs : radius + 1 ≤ s :=
      Nat.succ_le_iff.mpr (Nat.lt_of_not_ge hsr)
    exact h.next_unsafe (h.antitone_good hrs hs)
  · intro hsr
    exact h.antitone_good hsr h.good

theorem greatestSafe_eq
    (h : ExactGridCertificate n Good radius) :
    greatestSafe n Good = (radius : WithBot ℕ) :=
  greatestSafe_eq_of_antitone h.radius_lt.le h.antitone_good h.good h.next_unsafe

theorem firstUnsafe_eq
    (h : ExactGridCertificate n Good radius) :
    firstUnsafe n Good = ((radius + 1 : ℕ) : WithTop ℕ) :=
  firstUnsafe_eq_of_antitone h.radius_lt h.antitone_good h.good h.next_unsafe

end ExactGridCertificate

end FiniteThreshold
end ProximityPrize
