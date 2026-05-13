import Lake
open Lake DSL

/-
  Homotopical-Encrypt Lean Proofs

  Consolidated proof modules:
    Hardness.lean  — Hodge decomposition, CVP reduction, hidden-operator hardness
    CVP.lean       — explicit-lattice/CVP problem objects and assumptions
    Tsirelson.lean — Grassmannian Laplacians, Tsirelson bounds, adversary models
    Laplacian.lean — Grassmannian hardness, norm correction, injectivity
    Chain.lean     — chain-level protocol and transaction invariants
    Axioms/        — assumption interfaces and semantic ownership boundaries

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
lean_lib Hardness where
  srcDir := "."

@[default_target]
lean_lib Tsirelson where
  srcDir := "."

@[default_target]
lean_lib Laplacian where
  srcDir := "."

@[default_target]
lean_lib Chain where
  srcDir := "."

@[default_target]
lean_lib Axioms where
  srcDir := "."

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "f897ebcf72cd16f89ab4577d0c826cd14afaafc7"
