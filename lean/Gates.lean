module

public import Gates.Exact
public import Gates.Spectral
public import Gates.Oracle
public import Gates.Stage

@[expose] public section

/-
  Gate-facing import surface.

  Paper correspondence:
  - Paper 2: structural, spectral, oracle and stage gate interfaces consumed
    as protocol evidence.
  - Mathematical source-to-code distance calibration is described separately
    in Paper 3.

  Axioms say what must be true. Gates say which validation predicates are
  exposed to the protocol boundary and when they apply.
-/
