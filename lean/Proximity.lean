module

public import Proximity.Core
public import Proximity.Capacity
public import Proximity.ListDecoding
public import Proximity.MCA
public import Proximity.Application
public import Proximity.Concrete

@[expose] public section

/-
  Unified proximity hierarchy for the homotopical-encrypt Lean workspace.

  Paper correspondence:
  - Paper 1 Section 6: Plucker/cochain/plane/RS projection chain and MCA
    endpoint.
  - Paper 1 appendix ledger: Lean theorem-surface correspondence for
    proximity.

  Provenance/scope label:
  `Core`, `Capacity`, `ListDecoding`, and `MCA` contain the standalone
  coding-theory surface. `Application` contains neutral calibration contracts.
  `Concrete` contains the projection-chain, cochain, canonical-RS, gate, and
  certificate construction. Cited RS inputs enter through
  `Proximity.Concrete.CanonicalRS.CitedBounds` as an explicit trusted boundary.

  The concrete projection/proximity interface interprets
  cochains as the finite cellular shadow of a sheaf/fibration; disagreement is
  the local obstruction to gluing, and a code/evaluation shadow is a further
  projection of that cochain data.

  Scope:
    * It is the internal bridge needed to compare sheaf/Grassmannian proximity
      with code-style proximity questions later.
    * The standalone coding proofs are independent of cited RS-bound axioms.
      This broader aggregate also imports the concrete application and its
      explicitly named literature-bound assumptions.
    * Concrete Grassmannian/Laplacian families live in `Tsirelson.lean` and
      `Laplacian/Grassmannian.lean`.
    * Plucker coordinates and RS targets live here as stages of the proximity
      projection pipeline.
-/
