/-
  Public import surface for the Grassmannian Laplacian proof stack.

  Paper correspondence:
  - Paper 1 Sections 2--3: hidden Hodge operator/kernel search space and CVP
    comparison.
  - Paper 1 Section 7: Laplacian theorem-surface correspondence.

  The implementation is split by concern:

    Laplacian.Grassmannian.SearchSpace
      Ω_k, Ω_1, subspace existence, nonemptiness

    Laplacian.Grassmannian.ParametricFamily
      t ↦ span{u + t v} ⊕ W₀ and its injectivity

    Laplacian.Grassmannian.Injectivity
      injectivity of W ↦ Δ_W

  Downstream files can continue to `import Laplacian.Grassmannian`.
-/

import Laplacian.Grassmannian.SearchSpace
import Laplacian.Grassmannian.ParametricFamily
import Laplacian.Grassmannian.Injectivity
