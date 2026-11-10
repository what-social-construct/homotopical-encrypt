"""
Lattice Operations on Cochain Spaces

The lattice structure on cochains is the algebraic PROJECTION of the
deeper geometric/homotopical structure onto a concrete computational
surface. See crypto/hardness.py for the full hardness hierarchy:

    CVP < Hodge-hardness < homotopical search

This module implements the lattice operations — the bottom layer of
the projection — without cryptographic assumptions. The lattice is
where post-quantum hardness lives (no periodic structure for Shor),
but it captures only the shadow of the full geometric problem.

The projection chain from Helfer's fibrations to lattice operations:

    Grothendieck fibration (fiber_bundle.py)
        → parallel transport = restriction maps R_{v→e}
        → these define the coboundary operator δ
        → δ*δ = Laplacian Δ
        → Hodge decomposition of C^k into sublattices:
            C^k = ker(Δ) ⊕ im(δ) ⊕ im(δ*)
        → reducing mod q gives the q-ary lattice ℤ_q^n

Key structures:
- Cochains C^k(X, F) over ℤ_q form a lattice (ℤ-module mod q)
- Coboundary δ: C^k → C^{k+1} is a lattice homomorphism
- Hodge decomposition = sublattice decomposition
- ker(Δ) = harmonic sublattice where messages live
- The attacker sees the lattice but not which sublattice is ker(Δ)
  (that requires the fibration secret / parallel transport structure)
"""

from dataclasses import dataclass, field
from typing import Tuple, Optional, List
import numpy as np


@dataclass
class Lattice:
    """
    Abstract lattice over ℤ_q.
    
    A lattice is a discrete additive subgroup of ℝ^n.
    We work with ℤ_q^n which forms a finite lattice.
    
    Modulus q must be provided explicitly - no scary defaults.
    """
    dimension: int
    modulus: int  # Required - must be provided
    
    def add(self, v1: np.ndarray, v2: np.ndarray) -> np.ndarray:
        """Add two lattice points mod q."""
        return (v1 + v2) % self.modulus
    
    def scale(self, v: np.ndarray, scalar: int) -> np.ndarray:
        """Scale lattice point by integer mod q."""
        return (scalar * v) % self.modulus
    
    def negate(self, v: np.ndarray) -> np.ndarray:
        """Negate lattice point mod q."""
        return (-v) % self.modulus
    
    def inner_product(self, v1: np.ndarray, v2: np.ndarray) -> int:
        """Compute ⟨v1, v2⟩ mod q."""
        return int(np.dot(v1, v2) % self.modulus)
    
    def norm_squared(self, v: np.ndarray) -> int:
        """Compute ||v||² mod q."""
        return self.inner_product(v, v)
    
    def is_zero(self, v: np.ndarray, tolerance: float = 1e-10) -> bool:
        """Check if lattice point is zero (or close to zero mod q)."""
        centered = self.center(v)
        return float(np.linalg.norm(centered)) < tolerance
    
    def center(self, v: np.ndarray) -> np.ndarray:
        """Map to centered representatives [-q/2, q/2)."""
        result = v % self.modulus
        return np.where(result > self.modulus // 2, result - self.modulus, result)
    
    def reduce(self, v: np.ndarray) -> np.ndarray:
        """Reduce to canonical representatives [0, q)."""
        return v % self.modulus


@dataclass
class Sublattice:
    """
    A sublattice defined by a basis.
    
    For Hodge decomposition:
    - ker(Δ) = harmonic sublattice (basis = eigenvectors with λ=0)
    - im(δ) = exact sublattice
    - im(δ*) = coexact sublattice
    """
    parent: Lattice
    basis: np.ndarray  # Rows are basis vectors
    
    @property
    def rank(self) -> int:
        """Rank of sublattice = number of basis vectors."""
        return self.basis.shape[0] if len(self.basis.shape) > 1 else (1 if len(self.basis) > 0 else 0)
    
    def project(self, v: np.ndarray) -> np.ndarray:
        """Project onto this sublattice."""
        if self.rank == 0:
            return np.zeros_like(v)
        
        # Use pseudo-inverse for projection
        # P = B^T (B B^T)^{-1} B
        B = self.basis
        if len(B.shape) == 1:
            B = B.reshape(1, -1)
        
        try:
            proj_matrix = B.T @ np.linalg.pinv(B @ B.T) @ B
            return self.parent.reduce(proj_matrix @ v)
        except np.linalg.LinAlgError:
            return np.zeros_like(v)
    
    def contains(self, v: np.ndarray, tolerance: float = 1e-6) -> bool:
        """Check if vector is in this sublattice."""
        projected = self.project(v)
        diff = self.parent.center(v - projected)
        return float(np.linalg.norm(diff)) < tolerance


@dataclass
class CochainLattice(Lattice):
    """
    Lattice structure on cochain space C^k(X, F).
    
    Extends Lattice with:
    - Cell/stalk structure awareness
    - Sublattice extraction for Hodge components
    - Cochain-specific operations
    
    Key insight:
    - Cochains with integer coefficients form ℤ-module
    - Mod q reduction gives ℤ_q^n lattice
    - Coboundary δ is a lattice homomorphism
    - Harmonic cochains ker(Δ) form a sublattice
    """
    n_cells: int = 1
    stalk_dim: int = 1
    
    def __post_init__(self):
        """Set dimension from cells × stalk."""
        self.dimension = self.n_cells * self.stalk_dim
    
    @property
    def total_dim(self) -> int:
        """Total dimension = n_cells × stalk_dim."""
        return self.n_cells * self.stalk_dim
    
    @classmethod
    def from_complex(cls, n_cells: int, stalk_dim: int, modulus: int) -> 'CochainLattice':
        """Create cochain lattice from cell complex parameters."""
        return cls(
            dimension=n_cells * stalk_dim,
            modulus=modulus,
            n_cells=n_cells,
            stalk_dim=stalk_dim
        )
    
    def reshape_to_stalks(self, v: np.ndarray) -> np.ndarray:
        """Reshape flat vector to (n_cells, stalk_dim)."""
        return v.reshape(self.n_cells, self.stalk_dim)
    
    def flatten_from_stalks(self, stalks: np.ndarray) -> np.ndarray:
        """Flatten (n_cells, stalk_dim) to vector."""
        return stalks.flatten()
    
    def stalk_at(self, v: np.ndarray, cell_index: int) -> np.ndarray:
        """Extract stalk at given cell."""
        start = cell_index * self.stalk_dim
        end = start + self.stalk_dim
        return v[start:end]
    
    def set_stalk(self, v: np.ndarray, cell_index: int, stalk_data: np.ndarray) -> np.ndarray:
        """Set stalk at given cell, return new vector."""
        result = v.copy()
        start = cell_index * self.stalk_dim
        end = start + self.stalk_dim
        result[start:end] = stalk_data
        return result
    
    # Cochain operations (pure math - no crypto here)
    def add_cochains(self, c1: np.ndarray, c2: np.ndarray) -> np.ndarray:
        """Add two cochains mod q."""
        return self.add(c1, c2)
    
    def scale_cochain(self, c: np.ndarray, scalar: int) -> np.ndarray:
        """Scale cochain by scalar mod q."""
        return self.scale(c, scalar)


def extract_harmonic_sublattice(
    laplacian_eigenvectors: np.ndarray,
    laplacian_eigenvalues: np.ndarray,
    parent_lattice: Lattice,
    zero_threshold: float = 1e-10
) -> Sublattice:
    """
    Extract harmonic sublattice ker(Δ) from Laplacian eigendecomposition.
    
    Harmonic cochains = eigenvectors with eigenvalue ≈ 0.
    """
    # Find zero eigenvalues
    zero_mask = np.abs(laplacian_eigenvalues) < zero_threshold
    
    if not np.any(zero_mask):
        # No harmonic part
        return Sublattice(parent=parent_lattice, basis=np.array([]))
    
    # Extract corresponding eigenvectors as basis
    harmonic_basis = laplacian_eigenvectors[:, zero_mask].T
    
    return Sublattice(parent=parent_lattice, basis=harmonic_basis)


def hodge_decomposition_lattices(
    coboundary_0: np.ndarray,  # δ: C^0 → C^1
    coboundary_1: np.ndarray,  # δ: C^1 → C^2 (if exists)
    parent_lattice: Lattice
) -> Tuple[Sublattice, Sublattice, Sublattice]:
    """
    Compute Hodge decomposition as sublattices.
    
    Returns:
        (harmonic, exact, coexact) sublattices
        
    Where:
        C^k = harmonic ⊕ exact ⊕ coexact
    """
    # im(δ) = exact = column space of coboundary
    exact_basis = coboundary_0.T  # Columns of δ
    exact_sublattice = Sublattice(parent=parent_lattice, basis=exact_basis)
    
    # im(δ*) = coexact = row space of coboundary from above
    if coboundary_1 is not None and coboundary_1.size > 0:
        coexact_basis = coboundary_1  # Rows
        coexact_sublattice = Sublattice(parent=parent_lattice, basis=coexact_basis)
    else:
        coexact_sublattice = Sublattice(parent=parent_lattice, basis=np.array([]))
    
    # Harmonic = ker(Δ) = ker(δ) ∩ ker(δ*)
    # This is computed from the Laplacian eigendecomposition
    # For now return empty - caller should use extract_harmonic_sublattice
    harmonic_sublattice = Sublattice(parent=parent_lattice, basis=np.array([]))
    
    return (harmonic_sublattice, exact_sublattice, coexact_sublattice)

