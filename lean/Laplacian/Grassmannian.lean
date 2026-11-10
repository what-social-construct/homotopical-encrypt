module

/-
  Public import surface for the Grassmannian Laplacian proof stack.

  Paper correspondence:
  - Shared Grassmannian support for the projection model and later geometric
    applications.
  - Paper 1's selected results use their specific Hodge/CVP owners; this
    aggregate is not an additional manuscript claim inventory.

  The implementation is split by concern:

    Laplacian.Grassmannian.SearchSpace
      Ω_k, Ω_1, subspace existence, nonemptiness

    Laplacian.Grassmannian.ParametricFamily
      t ↦ span{u + t v} ⊕ W₀ and its injectivity

    Laplacian.Grassmannian.Injectivity
      injectivity of W ↦ Δ_W

  Downstream files can continue to `import Laplacian.Grassmannian`.
-/

public import Laplacian.Grassmannian.SearchSpace
public import Laplacian.Grassmannian.ParametricFamily
public import Laplacian.Grassmannian.Injectivity

@[expose] public section
