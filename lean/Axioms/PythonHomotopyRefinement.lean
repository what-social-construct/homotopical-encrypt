import Mathlib

/-
  Refinement contract for `src/primitives/homotopy.py`.

  Goal: make Python-side homotopy snapshots checkable against a Lean-side
  specification boundary, even before full constructive proofs are complete.
-/

namespace Hcrypt
namespace Axioms

/-- Python-facing snapshot (mirrors current `HomotopyInvariants` shape). -/
structure PythonHomotopySnapshot where
  topologyHash : ByteArray
  bettiNumbers : List Nat
  harmonicDim : Nat

/-- Lean-side specification record for homotopy class comparison. -/
structure LeanHomotopySpec where
  topologyHash : ByteArray
  bettiNumbers : List Nat
  harmonicDim : Nat

/-- Snapshot refines spec iff all class-defining fields agree. -/
def Refines (py : PythonHomotopySnapshot) (sp : LeanHomotopySpec) : Prop :=
  py.topologyHash = sp.topologyHash
  ∧ py.bettiNumbers = sp.bettiNumbers
  ∧ py.harmonicDim = sp.harmonicDim

/-- Equivalence relation used by the current Python primitive. -/
def Equivalent (a b : LeanHomotopySpec) : Prop :=
  a.topologyHash = b.topologyHash
  ∧ a.bettiNumbers = b.bettiNumbers
  ∧ a.harmonicDim = b.harmonicDim

theorem equivalent_refl (a : LeanHomotopySpec) : Equivalent a a := by
  unfold Equivalent
  exact ⟨rfl, rfl, rfl⟩

theorem equivalent_symm {a b : LeanHomotopySpec} : Equivalent a b → Equivalent b a := by
  intro hab
  rcases hab with ⟨h₁, h₂, h₃⟩
  exact ⟨h₁.symm, h₂.symm, h₃.symm⟩

theorem equivalent_trans {a b c : LeanHomotopySpec} :
  Equivalent a b → Equivalent b c → Equivalent a c := by
  intro hab hbc
  rcases hab with ⟨h₁, h₂, h₃⟩
  rcases hbc with ⟨h₄, h₅, h₆⟩
  exact ⟨h₁.trans h₄, h₂.trans h₅, h₃.trans h₆⟩

end Axioms
end Hcrypt
