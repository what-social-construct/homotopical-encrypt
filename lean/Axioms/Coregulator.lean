module

public import Mathlib.Init

@[expose] public section

/-
  Coregulator (MES-style) assumptions.

  Paper correspondence:
  - Paper 2: consensus control-loop and runtime protocol contracts.
  - These assumptions are outside Paper 1's selected HCP/CVP statements.

  Encodes predict/observe/update contracts used by the consensus control loop,
  without committing to a specific numerical estimator inside Lean yet.
-/

namespace Hcrypt
namespace Axioms

structure Coregulator where
  /-- Predict step produces a candidate next consensus state. -/
  PredictWellDefined : Prop
  /-- Observe step yields a measurable comparison signal. -/
  ObserveWellDefined : Prop
  /-- Update law is deterministic from prior memory + new observation. -/
  UpdateDeterministic : Prop
  /-- Confidence/delay policy is coherent with prediction error ordering. -/
  DelayPolicyMonotone : Prop

abbrev CoregulatorWellFormed (C : Coregulator) : Prop :=
  C.PredictWellDefined
  ∧ C.ObserveWellDefined
  ∧ C.UpdateDeterministic
  ∧ C.DelayPolicyMonotone

end Axioms
end Hcrypt
