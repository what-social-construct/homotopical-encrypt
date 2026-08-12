import Proximity.Core
import Proximity.Capacity
import Proximity.ListDecoding
import Proximity.MCA
import Proximity.Application
import Proximity.Concrete

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
    * List decoding, correlated agreement, and mutual correlated agreement are
      formalized as finite combinatorial targets, with no RS/ERA theorem
      assumed by this import surface.
    * Concrete Grassmannian/Laplacian families live in `Tsirelson.lean` and
      `Laplacian/Grassmannian.lean`.
    * Plucker coordinates and RS targets live here as stages of the proximity
      projection pipeline.
-/
