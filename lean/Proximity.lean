import Proximity.Projection
import Proximity.RS
import Proximity.Problem
import Proximity.RS.Target
import Proximity.Grassmannian
import Proximity.PluckerShadow
import Proximity.GrassmannianPlucker
import Proximity.GrassmannianPlucker.Concrete
import Proximity.CochainBridge
import Proximity.PluckerCochain
import Proximity.PluckerCochain.Concrete
import Proximity.CochainPlane
import Proximity.CochainReedSolomon
import Proximity.ProjectionChain
import Proximity.CanonicalRS
import Proximity.Gates
import Proximity.Public

/-
  Proximity bridge for the homotopical-encrypt Lean workspace.

  Paper correspondence:
  - Paper 1 Section 6: Plucker/cochain/plane/RS projection chain and MCA
    endpoint.
  - Paper 1 appendix ledger: Lean theorem-surface correspondence for
    proximity.

  Provenance/scope label:
  the projection-chain/gate/certificate architecture is hcrypt-native, while
  the RS/list-decoding/correlated-agreement/MCA vocabulary formalizes
  paper-facing coding-theory definitions. Cited RS theorem inputs enter through
  `Proximity.CanonicalRS.CitedBounds` as an explicit trusted boundary.

  This file names the hcrypt-native projection/proximity interface:
  cochains are the finite cellular shadow of a sheaf/fibration, disagreement is
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
