import Lake
open Lake DSL

/-
  Homotopical-Encrypt Lean Proofs

  Consolidated proof modules:
    HCP.lean       — HCP definitions, harmonic recovery, and semantic realization
    Hardness.lean  — Hodge decomposition, CVP comparison, and impossibility theorems
    CVP.lean       — explicit-lattice/CVP problem objects and assumptions
    Tsirelson.lean — Grassmannian Laplacians, Tsirelson bounds, adversary models
    Laplacian.lean — Grassmannian hardness, norm correction, injectivity
    Sheaf.lean     — finite cellular sheaves, cochains, and Hodge operators
    Proximity.lean — sheaf/cochain proximity projections and Grassmannian gap problems
    Gates.lean     — validation gate façades over axiom/spec modules
    Consensus.lean — Proof-of-Value assembly and scoring contracts
    Protocol.lean  — Paper 2 protocol-specification import surface
    TCB.lean       — proof-carrying artifacts and runtime-boundary contracts
    Chain.lean     — chain-level protocol and transaction invariants
    Helfer.lean    — typed algebraic interpretations and homotopy invariance boundary
    Axioms/        — assumption interfaces and mathematical spec contracts

  Build: cd lean && lake build
  Check: lake env lean Hardness.lean  (etc.)

  These are the canonical versions. The originals at repo root are
  kept as historical backups but are superseded by the files here.

  Current Lean proof workspace for the homotopical-encrypt formalization.
-/

package «homotopical-encrypt-proofs» where
  leanOptions := #[
    ⟨`autoImplicit, false⟩
  ]

@[default_target]
lean_lib CVP where
  srcDir := "."

@[default_target]
lean_lib HCP where
  srcDir := "."

@[default_target]
lean_lib Hardness where
  srcDir := "."

@[default_target]
lean_lib Tsirelson where
  srcDir := "."

@[default_target]
lean_lib Laplacian where
  srcDir := "."

@[default_target]
lean_lib Sheaf where
  srcDir := "."

@[default_target]
lean_lib Proximity where
  srcDir := "."

@[default_target]
lean_lib Gates where
  srcDir := "."

@[default_target]
lean_lib Consensus where
  srcDir := "."

@[default_target]
lean_lib Protocol where
  srcDir := "."

@[default_target]
lean_lib TCB where
  srcDir := "."

@[default_target]
lean_lib Chain where
  srcDir := "."

@[default_target]
lean_lib Helfer where
  srcDir := "."

@[default_target]
lean_lib Axioms where
  srcDir := "."

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "f897ebcf72cd16f89ab4577d0c826cd14afaafc7"
