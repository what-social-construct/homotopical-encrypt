/-
Grassmannian Laplacian Hardness Proof

Paper correspondence:
- Paper 1 Sections 2--3: hidden Hodge operator/kernel, Hodge projection, and
  CVP comparison.
- Paper 1 Section 7: Laplacian theorem-surface correspondence.

This file is now the public import surface for the Laplacian proof stack.
The actual formalization is split by concern:

  Laplacian.Projection    -- Δ_W = I - P_W and projection identities
  Laplacian.Hodge         -- harmonic projection and residual score interface
  Laplacian.Grassmannian -- public Grassmannian search-space import surface
    .SearchSpace        -- Ω_k, Ω_1, subspace existence, nonemptiness
    .ParametricFamily   -- parametric family t ↦ span{u + t v} ⊕ W₀
    .Injectivity        -- injectivity of W ↦ Δ_W
  Laplacian.Likelihood   -- adversaries, Gaussian likelihood, L∞/L2 correction
  Laplacian.Spectral     -- spectral fingerprints and non-homotopy-invariance

Downstream files can continue to `import Laplacian`.
-/

import Laplacian.Projection
import Laplacian.Hodge
import Laplacian.Grassmannian
import Laplacian.Likelihood
import Laplacian.Spectral
