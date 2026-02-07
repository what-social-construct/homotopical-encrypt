"""
Lattice — Unified imports for the lattice projection layer.

The lattice layer is the algebraic surface where the homotopical
hard problem projects down to concrete computation. See:

- geometry/lattice.py: Pure lattice math — the projection surface
  (Lattice, CochainLattice, Sublattice, Hodge decomposition)
- geometry/noise.py: Hodge-structured noise (not random Gaussian)
- crypto/random.py: Cryptographically secure randomness
- crypto/hardness.py: Security model — why CVP < Hodge-hardness
  < homotopical search (LatticeInstance, BKZ cost estimates)

The full hardness hierarchy (from Helfer, arXiv:1908.08944):
    CVP < Hodge-hardness < homotopical search (full break)
"""

# Lattice math from geometry
from ..geometry.lattice import (
    Lattice,
    Sublattice,
    CochainLattice,
    extract_harmonic_sublattice,
    hodge_decomposition_lattices,
)

# Noise from geometry (geometric/spectral structure)
from ..geometry.noise import (
    spectral_noise,
    heat_kernel_sample,
    exact_noise,
    ornstein_uhlenbeck_sample,
    hodge_structured_noise,
)

# Convenience aliases
ornstein_uhlenbeck_noise = ornstein_uhlenbeck_sample
exact_coboundary_noise = exact_noise  # legacy name

# Secure random from crypto
from .random import (
    secure_random_bytes,
    secure_random_int,
    secure_rng,
    secure_random_matrix,
    secure_random_vector,
    secure_random_orthogonal,
)

# Hardness/security from crypto
from .hardness import (
    LatticeInstance,
    analyze_quantum_resistance,
    estimate_security_level,
    mod_inverse,
    centered_mod,
)


# =============================================================================
# COCHAIN LATTICE SAMPLING (crypto-secure versions)
# =============================================================================

def random_cochain(lattice: CochainLattice) -> 'np.ndarray':
    """Sample random cochain with crypto-secure randomness."""
    import numpy as np
    return secure_random_vector(lattice.total_dim, lattice.modulus)


def short_cochain(lattice: CochainLattice, sigma: float) -> 'np.ndarray':
    """Sample short cochain using O-U noise."""
    rng = secure_rng()
    return ornstein_uhlenbeck_sample(lattice.total_dim, volatility=sigma, rng=rng)


def discrete_gaussian_matrix(rows: int, cols: int, sigma: float) -> 'np.ndarray':
    """Sample matrix from discrete Gaussian (for compatibility)."""
    import numpy as np
    rng = secure_rng()
    continuous = rng.normal(0, sigma, size=(rows, cols))
    return np.round(continuous).astype(np.int64)


__all__ = [
    # Geometry: lattice
    "Lattice",
    "Sublattice", 
    "CochainLattice",
    "extract_harmonic_sublattice",
    "hodge_decomposition_lattices",
    
    # Geometry: noise
    "spectral_noise",
    "heat_kernel_sample",
    "exact_noise",
    "ornstein_uhlenbeck_sample",
    "ornstein_uhlenbeck_noise",  # alias
    "exact_coboundary_noise",  # legacy alias
    "hodge_structured_noise",
    
    # Crypto: random
    "secure_random_bytes",
    "secure_random_int",
    "secure_rng",
    "secure_random_matrix",
    "secure_random_vector",
    "secure_random_orthogonal",
    
    # Crypto: hardness
    "LatticeInstance",
    "analyze_quantum_resistance",
    "estimate_security_level",
    "mod_inverse",
    "centered_mod",
    
    # Crypto: cochain sampling
    "random_cochain",
    "short_cochain",
    "discrete_gaussian_matrix",
]
