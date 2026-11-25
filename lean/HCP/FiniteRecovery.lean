module

public import Mathlib.Algebra.Order.BigOperators.Group.Finset
public import Mathlib.Data.Finset.Lattice.Fold
public import Mathlib.Data.Fintype.Card
public import Mathlib.Basic.Real.Basic

@[expose] public section

/-!
# Exact recovery from a finite public observation

A uniform hidden input determines its disclosed view and its recovery target.
For each realized view, the optimal decoder chooses a most frequent target
in that view's fiber. Summing the maximal multiplicities gives the exact
number of hidden inputs on which an optimal decoder succeeds.
-/

set_option autoImplicit false

open scoped BigOperators

namespace HomotopicalEncryption.HCP.FiniteRecovery

variable {Hidden View Target : Type*} [Fintype Hidden]

/-- The views actually disclosed by the finite hidden family. -/
noncomputable def disclosedViews (view : Hidden → View) : Finset View := by
  classical
  exact Finset.univ.image view

@[simp]
theorem mem_disclosedViews (view : Hidden → View) (v : View) :
    v ∈ disclosedViews view ↔ ∃ hidden, view hidden = v := by
  classical
  simp [disclosedViews]

/-- The number of hidden inputs with the given view and target. -/
noncomputable def targetMultiplicity (view : Hidden → View) (target : Hidden → Target)
    (v : View) (t : Target) : ℕ := by
  classical
  exact (Finset.univ.filter fun hidden => view hidden = v ∧ target hidden = t).card

/-- The largest target multiplicity at a public view. Unreached views have
zero multiplicity for every target. -/
noncomputable def maxTargetMultiplicity (view : Hidden → View) (target : Hidden → Target)
    (v : View) : ℕ := by
  classical
  exact (Finset.univ.image target).sup (targetMultiplicity view target v)

/-- Count the hidden inputs on which the view-based decoder succeeds. -/
noncomputable def successCount (view : Hidden → View) (target : Hidden → Target)
    (decoder : View → Target) : ℕ := by
  classical
  exact (Finset.univ.filter fun hidden => decoder (view hidden) = target hidden).card

/-- The sum of the largest target multiplicities in all realized views. -/
noncomputable def optimalCount (view : Hidden → View) (target : Hidden → Target) : ℕ :=
  ∑ v ∈ disclosedViews view, maxTargetMultiplicity view target v

theorem successCount_eq_sum (view : Hidden → View) (target : Hidden → Target)
    (decoder : View → Target) :
    successCount view target decoder =
      ∑ v ∈ disclosedViews view, targetMultiplicity view target v (decoder v) := by
  classical
  let good : Finset Hidden :=
    Finset.univ.filter fun hidden => decoder (view hidden) = target hidden
  have hmaps : (good : Set Hidden).MapsTo view (disclosedViews view : Set View) := by
    intro hidden _
    exact (mem_disclosedViews view (view hidden)).2 ⟨hidden, rfl⟩
  calc
    successCount view target decoder = good.card := rfl
    _ = ∑ v ∈ disclosedViews view, (good.filter fun hidden => view hidden = v).card :=
      Finset.card_eq_sum_card_fiberwise hmaps
    _ = _ := by
      apply Finset.sum_congr rfl
      intro v _
      apply congrArg Finset.card
      ext hidden
      simp only [good, Finset.mem_filter, Finset.mem_univ, true_and]
      constructor
      · rintro ⟨correct, rfl⟩
        exact ⟨rfl, correct.symm⟩
      · rintro ⟨rfl, correct⟩
        exact ⟨correct.symm, rfl⟩

theorem targetMultiplicity_le_max (view : Hidden → View) (target : Hidden → Target)
    (v : View) (t : Target) :
    targetMultiplicity view target v t ≤ maxTargetMultiplicity view target v := by
  classical
  by_cases h : t ∈ Finset.univ.image target
  · exact Finset.le_sup h
  · have empty : (Finset.univ.filter fun hidden => view hidden = v ∧ target hidden = t) = ∅ :=
      Finset.filter_eq_empty_iff.2 fun hidden hhidden hm =>
        h (Finset.mem_image.2 ⟨hidden, hhidden, hm.2⟩)
    rw [targetMultiplicity, empty, Finset.card_empty]
    exact Nat.zero_le _

theorem successCount_le_optimalCount (view : Hidden → View) (target : Hidden → Target)
    (decoder : View → Target) :
    successCount view target decoder ≤ optimalCount view target := by
  rw [successCount_eq_sum, optimalCount]
  exact Finset.sum_le_sum fun v _ => targetMultiplicity_le_max view target v (decoder v)

/-- A decoder attaining the per-view maxima exists on every nonempty family. -/
theorem exists_successCount_eq_optimalCount [Nonempty Hidden]
    (view : Hidden → View) (target : Hidden → Target) :
    ∃ decoder : View → Target, successCount view target decoder = optimalCount view target := by
  classical
  have h : (Finset.univ.image target).Nonempty :=
    ⟨target (Classical.choice ‹Nonempty Hidden›), Finset.mem_image_of_mem _ (Finset.mem_univ _)⟩
  have best (v : View) : ∃ t, maxTargetMultiplicity view target v =
      targetMultiplicity view target v t := by
    obtain ⟨t, _, ht⟩ :=
      Finset.exists_mem_eq_sup _ h (targetMultiplicity view target v)
    exact ⟨t, ht⟩
  refine ⟨fun v => (best v).choose, ?_⟩
  rw [successCount_eq_sum, optimalCount]
  exact Finset.sum_congr rfl fun v _ => (best v).choose_spec.symm

/-- With distinct targets, exactly one hidden input can be guessed per
realized view, and one per view is attainable. -/
theorem optimalCount_eq_card_image_of_injective (view : Hidden → View)
    (target : Hidden → Target) (injective : Function.Injective target) :
    optimalCount view target = (disclosedViews view).card := by
  classical
  unfold optimalCount
  calc
    _ = ∑ v ∈ disclosedViews view, (1 : ℕ) := by
      apply Finset.sum_congr rfl
      intro v hv
      apply le_antisymm
      · apply Finset.sup_le_iff.2
        intro t _
        apply Finset.card_le_one.2
        intro first hfirst second hsecond
        apply injective
        exact (Finset.mem_filter.1 hfirst).2.2.trans (Finset.mem_filter.1 hsecond).2.2.symm
      · obtain ⟨hidden, hhidden⟩ := (mem_disclosedViews view v).1 hv
        have member : hidden ∈ Finset.univ.filter
            (fun candidate => view candidate = v ∧ target candidate = target hidden) :=
          Finset.mem_filter.2 ⟨Finset.mem_univ _, hhidden, rfl⟩
        have positive : 1 ≤ targetMultiplicity view target v (target hidden) :=
          Finset.card_pos.2 ⟨hidden, member⟩
        exact positive.trans (targetMultiplicity_le_max view target v (target hidden))
    _ = _ := by simp

/-- Uniform-input success probability, expressed as the fraction of inputs
on which a given decoder is correct. -/
noncomputable def successProbability (view : Hidden → View) (target : Hidden → Target)
    (decoder : View → Target) : ℝ :=
  (successCount view target decoder : ℝ) / Fintype.card Hidden

/-- The exact optimal success probability for a nonempty uniform family. -/
noncomputable def optimalProbability (view : Hidden → View) (target : Hidden → Target) : ℝ :=
  (optimalCount view target : ℝ) / Fintype.card Hidden

theorem successProbability_le_optimalProbability (view : Hidden → View)
    (target : Hidden → Target) (decoder : View → Target) :
    successProbability view target decoder ≤ optimalProbability view target := by
  unfold successProbability optimalProbability
  apply div_le_div_of_nonneg_right _ (Nat.cast_nonneg _)
  exact_mod_cast successCount_le_optimalCount view target decoder

theorem exists_successProbability_eq_optimalProbability [Nonempty Hidden]
    (view : Hidden → View) (target : Hidden → Target) :
    ∃ decoder : View → Target,
      successProbability view target decoder = optimalProbability view target := by
  obtain ⟨decoder, hd⟩ := exists_successCount_eq_optimalCount view target
  exact ⟨decoder, by simp [successProbability, optimalProbability, hd]⟩

end HomotopicalEncryption.HCP.FiniteRecovery
