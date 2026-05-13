/-
Grassmannian Laplacian Hardness Proof

This file is now the public import surface for the Laplacian proof stack.
The actual formalization is split by concern:

  Laplacian.Basic         -- Δ_W = I - P_W and projection identities
  Laplacian.Grassmannian -- Ω_k, nonempty/infinite search space, injectivity
  Laplacian.Likelihood   -- adversaries, Gaussian likelihood, L∞/L2 correction
  Laplacian.Spectral     -- spectral fingerprints and non-homotopy-invariance

Downstream files can continue to `import Laplacian`.
-/

import Laplacian.Basic
import Laplacian.Grassmannian
import Laplacian.Likelihood
import Laplacian.Spectral
