import Gates.Exact
import Gates.Spectral
import Gates.Oracle
import Gates.Stage

/-
  Gate-facing import surface.

  Paper correspondence:
  - Paper 1 Sections 4--5: object-local exact, oracle, and commitment-adjacent
    invariants stated with the corresponding objects.
  - Paper 2: gate certificates as protocol evidence.

  Axioms say what must be true. Gates say which validation predicates are
  exposed to the protocol boundary and when they apply.
-/
