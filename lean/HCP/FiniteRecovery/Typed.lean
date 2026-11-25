module

public import HCP
public import HCP.FiniteRecovery

@[expose] public section

/-!
# Exact finite recovery at a fixed HCP observation

A uniformly chosen finite index selects a typed hidden witness for one fixed
public class and cochain. Exact public recovery can attain the frequency of
the most common operative target, even when that target is shared by several
hidden witnesses.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.HCPBridge

open CategoryTheory CategoryTheory.Limits HomotopicalAlgebra
open HCP.FiniteRecovery

universe u₁ u₂ v₁ v₂ uRep uHidden uAux

variable
    {C : Type u₂} [Category.{v₂} C]
    [HasTerminal C] [HasBinaryProducts C] [ModelCategory C]
    {S : Helfer.Signature.{u₁, v₁}}
    {sem : Helfer.ClosedSemantics (C := C) S}
    {Rep : Type uRep} {N P : Type} [Fintype N]
    {Hidden : Type uHidden} [Fintype Hidden] [Nonempty Hidden]

/-- At a fixed public observation, the largest operative-target multiplicity
divided by the family size is the sharp probability of exact recovery.
The same auxiliary input is supplied for every possible hidden index. -/
theorem fixedObservation_optimal_probability
    (X : Realization C S sem Rep N ℝ P)
    (observation : Observation P N ℝ)
    (family : Hidden → HiddenHodgeWitness X observation)
    {Aux : Type uAux} (aux : Aux) :
    let view : Hidden → Observation P N ℝ := fun _ => observation
    let target : Hidden → (N → ℝ) := fun hidden => operativeTarget X observation (family hidden)
    let bound := (maxTargetMultiplicity view target observation : ℝ) / Fintype.card Hidden
    (∀ solver : Solver Aux P N ℝ, successProbability view target (solver aux) ≤ bound) ∧
      (∃ solver : Solver Aux P N ℝ, successProbability view target (solver aux) = bound) := by
  classical
  let view : Hidden → Observation P N ℝ := fun _ => observation
  let target : Hidden → (N → ℝ) := fun hidden => operativeTarget X observation (family hidden)
  have views : disclosedViews view = {observation} := by
    ext v
    rw [mem_disclosedViews, Finset.mem_singleton]
    change (∃ _ : Hidden, observation = v) ↔ v = observation
    exact ⟨fun ⟨_, equal⟩ => equal.symm,
      fun equal => ⟨Classical.choice ‹Nonempty Hidden›, equal.symm⟩⟩
  have best : optimalProbability view target =
      (maxTargetMultiplicity view target observation : ℝ) / Fintype.card Hidden := by
    simp [optimalProbability, optimalCount, views]
  refine ⟨fun solver => (successProbability_le_optimalProbability view target
    (solver aux)).trans_eq best, ?_⟩
  obtain ⟨decoder, attains⟩ := exists_successProbability_eq_optimalProbability view target
  exact ⟨fun _ => decoder, attains.trans best⟩

end HomotopicalEncryption.HCPBridge
