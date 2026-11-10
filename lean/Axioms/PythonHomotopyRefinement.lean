module

public import Mathlib.Init

@[expose] public section

/-
  Historical runtime-parity shim for the retired
  `docs/archive/python/src/primitives/homotopy.py`.

  Paper correspondence:
  - Paper 2: historical runtime parity and implementation-refinement
    vocabulary.
  - The related mathematical public-classifier interface is
    Axioms.HomotopyClass; its provenance does not make this shim part of Paper
    1.

  This file is intentionally not imported by `Axioms.lean`. The Lean-owned
  homotopy-class theory lives in `Axioms.HomotopyClass`; Python/Rust objects can
  later be checked against that theory once the runtime orchestration settles.
-/

namespace Hcrypt
namespace Axioms

/-- Python-facing snapshot (mirrors the current `HomotopyInvariants` shape). -/
structure PythonHomotopySnapshot where
  topologyHash : ByteArray
  bettiNumbers : List Nat
  harmonicDim : Nat

/-- Minimal Lean-side snapshot shape for future runtime parity checks. -/
structure PythonHomotopySpec where
  topologyHash : ByteArray
  bettiNumbers : List Nat
  harmonicDim : Nat

/-- Snapshot refines spec iff all class-defining fields agree. -/
def RefinesPythonHomotopySnapshot
    (py : PythonHomotopySnapshot) (sp : PythonHomotopySpec) : Prop :=
  py.topologyHash = sp.topologyHash
  ∧ py.bettiNumbers = sp.bettiNumbers
  ∧ py.harmonicDim = sp.harmonicDim

end Axioms
end Hcrypt
