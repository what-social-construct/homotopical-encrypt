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
    _kernel_tolerance,
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
    # Uses _kernel_tolerance() — same formula as keygen, encrypt, decrypt, hodge.py.
    # (Matches hardness_proof.lean: correct ker(Δ) identification is critical
    # for the CVP reduction.)
    effective_threshold = _kernel_tolerance(eigenvalues)
    harmonic_mask = np.abs(eigenvalues) < effective_threshold
    
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
    
    # Find harmonic basis — uses _kernel_tolerance() (single source of truth)
    effective_threshold = _kernel_tolerance(eigenvalues)
    harmonic_mask = np.abs(eigenvalues) < effective_threshold
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
    
    # ── SELF-CHECK: verify embedding ∈ ker(Δ) ──
    # Use relative tolerance: for sheaf Laplacians with eigenvalues ~1e12,
    # the residual ||Δ·embedding|| can be large in absolute terms even
    # when the embedding is numerically in ker(Δ).
    max_eig = np.max(np.abs(eigenvalues)) if len(eigenvalues) > 0 else 1.0
    residual = np.linalg.norm(laplacian @ embedding)
    relative_residual = residual / (np.linalg.norm(embedding) * max_eig + 1e-16)
    if relative_residual > 1e-8:
        raise RuntimeError(
            f"INVARIANT VIOLATION: embed_in_harmonic produced non-harmonic output: "
            f"||Δ·embedding||/||embedding||·λ_max = {relative_residual:.2e}. "
            f"Aborting — possible corruption."
        )
    
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
    
    The cochain is a 0-cochain in C⁰(nerve, F) = ⊕_v F(v).
    Harmonic cochains (ker Δ_sheaf) correspond to global sections:
    data consistent under all restriction maps R_{v→e}.
    
    We extract the message by projecting onto the harmonic basis
    (eigenvectors of Δ_sheaf with eigenvalue ≈ 0) and reading
    the coefficients — exactly inverting embed_in_harmonic.
    
    Args:
        cochain: 0-cochain containing embedded message (in ⊕_v F(v))
        laplacian: Sheaf Laplacian Δ_sheaf
        message_length: Length of original message (in coefficients)
        
    Returns:
        Extracted message coefficients
    """
    eigenvalues, eigenvectors = np.linalg.eigh(laplacian)
    
    # Find harmonic basis — uses _kernel_tolerance() (single source of truth)
    effective_threshold = _kernel_tolerance(eigenvalues)
    harmonic_mask = np.abs(eigenvalues) < effective_threshold
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
    
    Matches framework_consolidation.lean SheafLaplacian structure:
    Δ is self-adjoint and PSD, so ker(Δ) is well-defined.
    We check ||Δc|| / (||c|| · λ_max) < tolerance (RELATIVE),
    because sheaf eigenvalues can be ~1e12 and absolute residuals
    are meaningless at that scale.
    """
    delta_c = laplacian @ cochain
    abs_residual = float(np.linalg.norm(delta_c))
    
    # Relative tolerance: normalize by ||c|| · λ_max
    cochain_norm = np.linalg.norm(cochain)
    eigs = np.linalg.eigvalsh(laplacian)
    max_eig = np.max(np.abs(eigs)) if len(eigs) > 0 else 1.0
    scale = cochain_norm * max_eig + 1e-16
    relative_residual = abs_residual / scale
    
    if relative_residual < tolerance:
        return HarmonicInvariantResult(
            passed=True,
            message="✓ Cochain is in harmonic subspace",
            residual=relative_residual
        )
    else:
        return HarmonicInvariantResult(
            passed=False,
            message=f"✗ Cochain not harmonic: ||Δc||/(||c||·λ_max) = {relative_residual:.2e} > {tolerance}",
            residual=relative_residual
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


def validate_hodge_orthogonality(
    harmonic: np.ndarray,
    exact: np.ndarray,
    coexact: np.ndarray,
    tolerance: float = 1e-6
) -> HarmonicInvariantResult:
    """
    INVARIANT GATE: Validate pairwise orthogonality of Hodge components.
    
    The Lean proof (Hodge_Decomposition_Theorem) proves:
      ⟨h, e1⟩ = 0  (harmonic ⊥ exact)
      ⟨h, e2⟩ = 0  (harmonic ⊥ coexact)
      ⟨e1, e2⟩ = 0 (exact ⊥ coexact)
    
    If ANY pair is not orthogonal, the decomposition is invalid
    and the hardness claim does not hold.
    """
    he = abs(float(np.dot(harmonic, exact)))
    hc = abs(float(np.dot(harmonic, coexact)))
    ec = abs(float(np.dot(exact, coexact)))
    max_ip = max(he, hc, ec)
    
    if max_ip < tolerance:
        return HarmonicInvariantResult(
            passed=True,
            message=f"✓ Hodge components pairwise orthogonal (max |⟨·,·⟩| = {max_ip:.2e})",
            residual=max_ip
        )
    else:
        parts = []
        if he >= tolerance:
            parts.append(f"⟨h,e⟩={he:.2e}")
        if hc >= tolerance:
            parts.append(f"⟨h,ce⟩={hc:.2e}")
        if ec >= tolerance:
            parts.append(f"⟨e,ce⟩={ec:.2e}")
        return HarmonicInvariantResult(
            passed=False,
            message=f"✗ Hodge orthogonality violated: {', '.join(parts)}",
            residual=max_ip
        )


def validate_laplacian_construction(
    laplacian: np.ndarray,
    delta: np.ndarray,
    delta_prev: np.ndarray = None,
    tolerance: float = 1e-6
) -> HarmonicInvariantResult:
    """
    INVARIANT GATE: Validate Δ = δ*δ + δδ*.
    
    The Lean proof (Hodge_Decomposition_Theorem) requires:
      Δ = d_prev · d_prev^T + d_next^T · d_next
    
    where d_prev = δ_{k-1} (from below) and d_next = δ_k (to above).
    
    If Δ is not constructed this way, the Hodge decomposition theorem
    does not apply and the hardness reduction is invalid.
    
    Args:
        laplacian: The Laplacian matrix Δ to validate
        delta: δ_k (coboundary going up from this degree)
        delta_prev: δ_{k-1} (coboundary from below), None for degree 0
    """
    n = laplacian.shape[0]
    
    # Reconstruct: Δ = δ^T·δ + δ_prev·δ_prev^T
    reconstructed = delta.T @ delta
    if delta_prev is not None:
        reconstructed += delta_prev @ delta_prev.T
    
    error = float(np.linalg.norm(laplacian - reconstructed))
    
    if error < tolerance:
        return HarmonicInvariantResult(
            passed=True,
            message=f"✓ Δ = δ*δ + δδ* verified (error = {error:.2e})",
            residual=error
        )
    else:
        return HarmonicInvariantResult(
            passed=False,
            message=f"✗ Laplacian construction mismatch: ||Δ - (δ*δ + δδ*)|| = {error:.2e}",
            residual=error
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
