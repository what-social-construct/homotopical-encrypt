module

/-
Shared Grassmannian/Laplacian proof and interface aggregate

Paper correspondence:
- Shared Laplacian support, with Paper 1's Hodge/projection/CVP arguments
  using specific leaf modules.
- Likelihood, spectral and parametric-family surfaces remain supporting
  developments outside the selected Paper 1 appendix.

This file is now the public import surface for the Laplacian proof stack.
The actual formalization is split by concern:

  Laplacian.Projection    -- Δ_W = I - P_W and projection identities
  Laplacian.Hodge         -- harmonic projection and residual score interface
  Laplacian.Grassmannian -- public Grassmannian search-space import surface
    .SearchSpace        -- Ω_k, Ω_1, subspace existence, nonemptiness
    .ParametricFamily   -- parametric family t ↦ span{u + t v} ⊕ W₀
    .Injectivity        -- injectivity of W ↦ Δ_W
  Laplacian.Likelihood   -- likelihood-score interfaces and L∞/L2 distinction
  Laplacian.Spectral     -- spectral fingerprints and the equal-nullity relation

Downstream files can continue to `import Laplacian`.
-/

public import Laplacian.Projection
public import Laplacian.Hodge
public import Laplacian.Grassmannian
public import Laplacian.Likelihood
public import Laplacian.Spectral

@[expose] public section
