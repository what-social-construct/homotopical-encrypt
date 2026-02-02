"""
Harmonic Invariants for Encryption

Validates that encryption follows the Hodge decomposition structure:
- Message is embedded in ker(Δ) (harmonic subspace)
- Noise is in im(δ) ⊕ im(δ*) (exact + coexact)

This ensures decryption via Hodge projection recovers the message:
    project_harmonic(message + noise) = message

Key insight: if message ∈ ker(Δ) and noise ⊥ ker(Δ), then harmonic
projection exactly recovers message.

Uses geometry/hodge.py for Hodge decomposition.
"""

from dataclasses import dataclass
from typing import Tuple, Optional
import numpy as np

# Import Hodge decomposition from geometry
from ..geometry.hodge import (
    hodge_decomposition,
    compute_hodge_projectors,
    HodgeDecomposition,
)


# =============================================================================
# INVARIANT CHECKS
# =============================================================================

def is_harmonic(
    cochain: np.ndarray,
    laplacian: np.ndarray,
    tolerance: float = 1e-6
) -> Tuple[bool, float]:
    """
    Check if cochain is harmonic (in ker(Δ)).
    
    A cochain c is harmonic iff Δc = 0.
    
    Args:
        cochain: The cochain to check
        laplacian: Sheaf Laplacian matrix Δ
        tolerance: Max norm of Δc to consider zero
        
    Returns:
        (is_harmonic, residual_norm)
    """
    # Compute Δc
    delta_c = laplacian @ cochain
    residual = np.linalg.norm(delta_c)
    
    return residual < tolerance, float(residual)


def is_exact(
    cochain: np.ndarray,
    coboundary: np.ndarray,
    tolerance: float = 1e-6
) -> Tuple[bool, float, Optional[np.ndarray]]:
    """
    Check if cochain is exact (in im(δ)).
    
    A cochain c is exact iff c = δ(something).
    Equivalently, c is in the column space of δ.
    
    Args:
        cochain: The cochain to check
        coboundary: Coboundary operator matrix δ
        tolerance: Tolerance for projection residual
        
    Returns:
        (is_exact, projection_error, preimage_if_exists)
    """
    # Project onto im(δ) = column space of δ
    # Use least squares: find x minimizing ||δx - c||
    try:
        preimage, residuals, rank, s = np.linalg.lstsq(coboundary, cochain, rcond=None)
        
        # Compute actual residual
        projected = coboundary @ preimage
        residual = np.linalg.norm(cochain - projected)
        
        is_exact = residual < tolerance
        return is_exact, float(residual), preimage if is_exact else None
    
    except np.linalg.LinAlgError:
        return False, float('inf'), None


def is_coexact(
    cochain: np.ndarray,
    coboundary_adj: np.ndarray,  # δ* (adjoint/transpose)
    tolerance: float = 1e-6
) -> Tuple[bool, float, Optional[np.ndarray]]:
    """
    Check if cochain is coexact (in im(δ*)).
    
    A cochain c is coexact iff c = δ*(something).
    Equivalently, c is in the row space of δ (column space of δ^T).
    
    Args:
        cochain: The cochain to check
        coboundary_adj: Adjoint coboundary δ* = δ^T
        tolerance: Tolerance for projection residual
        
    Returns:
        (is_coexact, projection_error, preimage_if_exists)
    """
    # im(δ*) = column space of δ^T
    return is_exact(cochain, coboundary_adj, tolerance)


def is_in_hodge_complement(
    noise: np.ndarray,
    laplacian: np.ndarray,
    tolerance: float = 1e-6
) -> Tuple[bool, float]:
    """
    Check if noise is in im(δ) ⊕ im(δ*) (orthogonal to harmonics).
    
    This is equivalent to: noise ⊥ ker(Δ).
    
    We check by projecting onto harmonic subspace and verifying
    the projection is (nearly) zero.
    
    Args:
        noise: The noise vector to check
        laplacian: Sheaf Laplacian matrix Δ
        tolerance: Max norm of harmonic component
        
    Returns:
        (is_in_complement, harmonic_component_norm)
    """
    # Get harmonic projection
    harmonic_proj = project_to_harmonic(noise, laplacian)
    harmonic_norm = np.linalg.norm(harmonic_proj)
    
    return harmonic_norm < tolerance, float(harmonic_norm)


# =============================================================================
# PROJECTIONS
# =============================================================================

def project_to_harmonic(
    cochain: np.ndarray,
    laplacian: np.ndarray,
    zero_threshold: float = 1e-10
) -> np.ndarray:
    """
    Project cochain onto harmonic subspace ker(Δ).
    
    Uses eigendecomposition: project onto eigenvectors with eigenvalue ≈ 0.
    
    Args:
        cochain: Cochain to project
        laplacian: Sheaf Laplacian
        zero_threshold: Threshold for "zero" eigenvalue
        
    Returns:
        Harmonic component of cochain
    """
    eigenvalues, eigenvectors = np.linalg.eigh(laplacian)
    
    # Find harmonic basis (eigenvalue ≈ 0)
    harmonic_mask = np.abs(eigenvalues) < zero_threshold
    
    if not np.any(harmonic_mask):
        # No harmonic subspace
        return np.zeros_like(cochain)
    
    harmonic_basis = eigenvectors[:, harmonic_mask]
    
    # Project: P_H = V_H V_H^T
    coeffs = harmonic_basis.T @ cochain
    harmonic = harmonic_basis @ coeffs
    
    return harmonic


def project_to_exact(
    cochain: np.ndarray,
    coboundary: np.ndarray
) -> np.ndarray:
    """
    Project cochain onto exact subspace im(δ).
    
    Args:
        cochain: Cochain to project
        coboundary: Coboundary operator δ
        
    Returns:
        Exact component of cochain
    """
    # Project onto column space of δ
    # Using pseudo-inverse: P_im(δ) = δ δ^+
    delta_pinv = np.linalg.pinv(coboundary)
    projection_matrix = coboundary @ delta_pinv
    
    return projection_matrix @ cochain


def project_to_coexact(
    cochain: np.ndarray,
    coboundary_adj: np.ndarray
) -> np.ndarray:
    """
    Project cochain onto coexact subspace im(δ*).
    
    Args:
        cochain: Cochain to project
        coboundary_adj: Adjoint coboundary δ* = δ^T
        
    Returns:
        Coexact component of cochain
    """
    return project_to_exact(cochain, coboundary_adj)


def hodge_decompose(
    cochain: np.ndarray,
    laplacian: np.ndarray,
    coboundary_below: Optional[np.ndarray],
    coboundary_above: Optional[np.ndarray],
    zero_threshold: float = 1e-10
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Full Hodge decomposition: c = h + e + ce
    
    Where:
        h ∈ ker(Δ) (harmonic)
        e ∈ im(δ_below) (exact)
        ce ∈ im(δ*_above) (coexact)
    
    Args:
        cochain: Cochain to decompose
        laplacian: Sheaf Laplacian Δ
        coboundary_below: δ from degree below (for exact part)
        coboundary_above: δ* from degree above (for coexact part)
        
    Returns:
        (harmonic, exact, coexact) components
    """
    # Start with full cochain
    remainder = cochain.copy()
    
    # Extract harmonic
    harmonic = project_to_harmonic(remainder, laplacian, zero_threshold)
    remainder = remainder - harmonic
    
    # Extract exact
    if coboundary_below is not None and coboundary_below.size > 0:
        exact = project_to_exact(remainder, coboundary_below)
    else:
        exact = np.zeros_like(cochain)
    remainder = remainder - exact
    
    # Remainder is coexact
    coexact = remainder
    
    return harmonic, exact, coexact


# =============================================================================
# EMBEDDING
# =============================================================================

def embed_in_harmonic(
    message: np.ndarray,
    laplacian: np.ndarray,
    zero_threshold: float = 1e-10
) -> Tuple[np.ndarray, bool]:
    """
    Embed message in harmonic subspace.
    
    The message is projected onto ker(Δ). If message dimension exceeds
    harmonic dimension, information is lost!
    
    Args:
        message: Message to embed (may be shorter than harmonic dim)
        laplacian: Sheaf Laplacian
        
    Returns:
        (harmonic_embedding, success)
        success=False if harmonic subspace too small
    """
    eigenvalues, eigenvectors = np.linalg.eigh(laplacian)
    
    # Find harmonic basis
    harmonic_mask = np.abs(eigenvalues) < zero_threshold
    harmonic_dim = np.sum(harmonic_mask)
    
    if harmonic_dim == 0:
        return np.zeros(laplacian.shape[0]), False
    
    harmonic_basis = eigenvectors[:, harmonic_mask]
    
    # Message must fit in harmonic dimension
    if len(message) > harmonic_dim:
        return np.zeros(laplacian.shape[0]), False
    
    # Pad message to harmonic dimension
    padded_message = np.zeros(harmonic_dim)
    padded_message[:len(message)] = message
    
    # Embed: c = V_H @ m where m is coefficients in harmonic basis
    embedding = harmonic_basis @ padded_message
    
    return embedding, True


def extract_from_harmonic(
    cochain: np.ndarray,
    laplacian: np.ndarray,
    message_length: int,
    zero_threshold: float = 1e-10
) -> np.ndarray:
    """
    Extract message from harmonic cochain.
    
    Inverse of embed_in_harmonic.
    
    Args:
        cochain: Cochain containing embedded message
        laplacian: Sheaf Laplacian
        message_length: Length of original message
        
    Returns:
        Extracted message
    """
    eigenvalues, eigenvectors = np.linalg.eigh(laplacian)
    
    # Find harmonic basis
    harmonic_mask = np.abs(eigenvalues) < zero_threshold
    harmonic_basis = eigenvectors[:, harmonic_mask]
    
    # Extract coefficients in harmonic basis
    coeffs = harmonic_basis.T @ cochain
    
    # Return message portion
    return coeffs[:message_length]


# =============================================================================
# INVARIANT GATES
# =============================================================================

@dataclass
class HarmonicInvariantResult:
    """Result of harmonic invariant check."""
    passed: bool
    message: str
    residual: float
    
    def __bool__(self):
        return self.passed


def validate_harmonic_embedding(
    cochain: np.ndarray,
    laplacian: np.ndarray,
    tolerance: float = 1e-6
) -> HarmonicInvariantResult:
    """
    INVARIANT GATE: Validate that cochain is in ker(Δ).
    
    Use before adding noise to ensure message is properly embedded.
    """
    is_harm, residual = is_harmonic(cochain, laplacian, tolerance)
    
    if is_harm:
        return HarmonicInvariantResult(
            passed=True,
            message="✓ Cochain is in harmonic subspace",
            residual=residual
        )
    else:
        return HarmonicInvariantResult(
            passed=False,
            message=f"✗ Cochain not harmonic: ||Δc|| = {residual:.2e} > {tolerance}",
            residual=residual
        )


def validate_noise_structure(
    noise: np.ndarray,
    laplacian: np.ndarray,
    tolerance: float = 1e-6
) -> HarmonicInvariantResult:
    """
    INVARIANT GATE: Validate that noise is orthogonal to harmonics.
    
    Use after generating noise to ensure it won't corrupt message.
    """
    in_complement, harmonic_norm = is_in_hodge_complement(noise, laplacian, tolerance)
    
    if in_complement:
        return HarmonicInvariantResult(
            passed=True,
            message="✓ Noise is in im(δ) ⊕ im(δ*)",
            residual=harmonic_norm
        )
    else:
        return HarmonicInvariantResult(
            passed=False,
            message=f"✗ Noise has harmonic component: ||P_H(noise)|| = {harmonic_norm:.2e}",
            residual=harmonic_norm
        )


def validate_decryption_integrity(
    original_embedding: np.ndarray,
    recovered: np.ndarray,
    tolerance: float = 1e-6
) -> HarmonicInvariantResult:
    """
    INVARIANT GATE: Validate decryption recovered the message.
    
    Use after decryption to verify integrity.
    """
    diff = np.linalg.norm(original_embedding - recovered)
    
    if diff < tolerance:
        return HarmonicInvariantResult(
            passed=True,
            message="✓ Decryption recovered original message",
            residual=diff
        )
    else:
        return HarmonicInvariantResult(
            passed=False,
            message=f"✗ Decryption error: ||original - recovered|| = {diff:.2e}",
            residual=diff
        )
