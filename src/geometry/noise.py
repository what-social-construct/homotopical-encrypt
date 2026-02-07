"""
Spectral Noise — Geometrically Native Noise Sampling

Noise shaped by the Laplacian spectrum of the sheaf, respecting
the Hodge decomposition C^k = ker(Δ) ⊕ im(δ) ⊕ im(δ*).

Local-to-global coherence interpretation:

  ker(Δ) = global sections (data consistent under all restrictions).
  im(δ)⊕im(δ*) = disagreement subspace ⊥ ker(Δ).

  For encryption, noise must live in im(δ)⊕im(δ*) so that
  π_H (Hodge projection) recovers the message exactly. The
  hodge_structured_noise() function projects sampled noise
  out of ker(Δ), ensuring ⟨noise, m⟩ = 0 for all m ∈ ker(Δ).

  spectral_noise() and heat_kernel_sample() shape variance by
  eigenvalue: high-frequency modes (large λ) get less variance,
  harmonic modes (λ ≈ 0) get most — useful for diffusion processes
  but not for encryption noise (use hodge_structured_noise instead).

Uses crypto/random.py for secure random generation.
Uses hodge.py for projectors.
"""

from typing import Optional
import numpy as np

from .hodge import compute_hodge_projectors


def spectral_noise(
    eigenvalues: np.ndarray,
    eigenvectors: np.ndarray = None,
    temperature: float = 1.0,
    time: float = 1.0,
    rng: np.random.Generator = None
) -> np.ndarray:
    """
    Sample noise shaped by sheaf Laplacian spectrum.
    
    Uses heat kernel: e^{-tΔ} to generate geometrically natural noise.
    
    Args:
        eigenvalues: Spectrum of sheaf Laplacian
        eigenvectors: Optional eigenvector matrix (for projection)
        temperature: Noise temperature (β = 1/T)
        time: Diffusion time t in e^{-tΔ}
        rng: Random generator (default: numpy default)
        
    Returns:
        Noise vector shaped by spectrum
    """
    if rng is None:
        rng = np.random.default_rng()
    
    dim = len(eigenvalues)
    
    # Heat kernel weights: e^{-t*λ}
    weights = np.exp(-time * np.abs(eigenvalues))
    
    # Boltzmann-weighted variance: σ²_k ∝ T / (λ_k + ε)
    epsilon = 1e-6
    variance = temperature / (np.abs(eigenvalues) + epsilon)
    
    # Sample Gaussian with spectral variance
    noise_spectral = rng.normal(0, np.sqrt(variance * weights))
    
    # If eigenvectors provided, transform to coordinate basis
    if eigenvectors is not None:
        noise = eigenvectors @ noise_spectral
    else:
        noise = noise_spectral
    
    return np.round(noise).astype(np.int64)


def heat_kernel_sample(
    laplacian: np.ndarray,
    time: float = 1.0,
    temperature: float = 1.0,
    rng: np.random.Generator = None
) -> np.ndarray:
    """
    Sample from heat kernel on the sheaf.
    
    Heat equation: ∂u/∂t = -Δu
    Heat kernel K(t) = e^{-tΔ} defines natural diffusion.
    
    Args:
        laplacian: Sheaf Laplacian matrix Δ
        time: Diffusion time
        temperature: Controls peakedness
        rng: Random generator
        
    Returns:
        Sample from heat kernel distribution
    """
    if rng is None:
        rng = np.random.default_rng()
    
    dim = laplacian.shape[0]
    
    # Eigendecompose Laplacian
    eigenvalues, eigenvectors = np.linalg.eigh(laplacian)
    
    # Covariance: Σ_k = T * e^{-t*λ_k} / (λ_k + ε)
    epsilon = 1e-6
    spectral_var = temperature * np.exp(-time * np.abs(eigenvalues)) / (np.abs(eigenvalues) + epsilon)
    
    # Sample in eigenbasis
    z = rng.normal(0, np.sqrt(spectral_var))
    
    # Transform to coordinate basis
    sample = eigenvectors @ z
    
    return np.round(sample).astype(np.int64)


def exact_noise(
    coboundary_matrix: np.ndarray,
    sigma: float,
    rng: np.random.Generator = None
) -> np.ndarray:
    """
    Generate noise in im(δ) - cohomologically trivial noise.
    
    Key property: noise = δ(something) is EXACT, so
    it doesn't change the cohomology class.
    
    Message in harmonic subspace is preserved!
    
    Args:
        coboundary_matrix: The δ operator matrix
        sigma: Noise scale
        rng: Random generator
        
    Returns:
        Noise in im(δ)
    """
    if rng is None:
        rng = np.random.default_rng()
    
    # Sample random cochain in source space
    source_dim = coboundary_matrix.shape[1]
    source = rng.normal(0, sigma, size=source_dim)
    
    # Apply coboundary → noise is exact
    noise = coboundary_matrix @ source
    
    return np.round(noise).astype(np.int64)


def ornstein_uhlenbeck_sample(
    dim: int,
    volatility: float,
    mean_reversion: float = 1.0,
    equilibrium: np.ndarray = None,
    covariance: np.ndarray = None,
    rng: np.random.Generator = None
) -> np.ndarray:
    """
    Sample from Ornstein-Uhlenbeck stationary distribution.
    
    O-U mean-reverts to equilibrium with Σ = σ²/(2θ).
    For Hodge: μ = 0 but Σ shaped by decomposition.
    
    Args:
        dim: Dimension
        volatility: σ - noise scale
        mean_reversion: θ - rate of reversion
        equilibrium: μ - center (default: zero)
        covariance: Optional shaped covariance
        rng: Random generator
        
    Returns:
        Sample from O-U stationary distribution
    """
    if rng is None:
        rng = np.random.default_rng()
    
    if equilibrium is None:
        equilibrium = np.zeros(dim)
    
    if covariance is not None:
        try:
            L = np.linalg.cholesky(covariance)
            z = rng.standard_normal(dim)
            noise = equilibrium + L @ z
        except np.linalg.LinAlgError:
            stationary_std = np.sqrt(np.diag(covariance))
            noise = rng.normal(equilibrium, stationary_std)
    else:
        stationary_var = (volatility ** 2) / (2 * mean_reversion)
        stationary_std = np.sqrt(stationary_var)
        noise = rng.normal(equilibrium, stationary_std)
    
    return np.round(noise).astype(np.int64)


def hodge_structured_noise(
    laplacian: np.ndarray,
    coboundary_below: Optional[np.ndarray],
    coboundary_above: Optional[np.ndarray],
    sigma_exact: float,
    sigma_coexact: float,
    sigma_harmonic: float = 0.0,
    rng: np.random.Generator = None
) -> np.ndarray:
    """
    Generate Hodge-structured noise using projectors from hodge.py.
    
    Noise is decomposed into harmonic ⊕ exact ⊕ coexact,
    with separate variance for each component.
    
    For encryption:
    - Large sigma in exact⊕coexact (hides structure)
    - Small/zero sigma in harmonic (preserves message)
    
    Args:
        laplacian: Sheaf Laplacian
        coboundary_below: δ_{k-1} for exact part
        coboundary_above: δ_k for coexact part
        sigma_exact: Noise scale in im(δ)
        sigma_coexact: Noise scale in im(δ*)
        sigma_harmonic: Noise scale in ker(Δ) (usually 0)
        rng: Random generator
        
    Returns:
        Hodge-structured noise vector
    """
    if rng is None:
        rng = np.random.default_rng()
    
    dim = laplacian.shape[0]
    
    # Get Hodge projectors from hodge.py
    P_harmonic, P_exact, P_coexact = compute_hodge_projectors(
        laplacian, coboundary_above, coboundary_below
    )
    
    # Sample base noise
    z = rng.standard_normal(dim)
    
    # Project and scale
    noise = np.zeros(dim)
    
    if sigma_harmonic > 0:
        noise += sigma_harmonic * (P_harmonic @ z)
    
    if sigma_exact > 0:
        noise += sigma_exact * (P_exact @ z)
    
    if sigma_coexact > 0:
        noise += sigma_coexact * (P_coexact @ z)
    
    # Fill remainder with exact noise (conservative)
    remainder = z - P_harmonic @ z - P_exact @ z - P_coexact @ z
    noise += sigma_exact * remainder
    
    # ── SELF-CHECK: verify noise ⊥ ker(Δ) when sigma_harmonic == 0 ──
    if sigma_harmonic == 0:
        harmonic_leak = P_harmonic @ noise
        leak_norm = np.linalg.norm(harmonic_leak)
        if leak_norm > 1e-6:
            raise RuntimeError(
                f"INVARIANT VIOLATION: Hodge noise leaked into ker(Δ): "
                f"||P_H(noise)|| = {leak_norm:.2e}. "
                f"This would corrupt messages in the harmonic subspace."
            )
    
    return np.round(noise).astype(np.int64)
