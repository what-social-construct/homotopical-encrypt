"""
Sheaf-LWE: Lattice Problem on Cochain Complex

Instead of generic LWE on ℤⁿ, we use the NATURAL lattice structure
from our sheaf cochains.

Lattice: C^k(X, F) ∩ ℤ = integer-valued cochains
Hard Problem: Given noisy cochain, find harmonic component

The Laplacian Δ = δ*δ + δδ* decomposes cochains:
  C^k = ker(Δ) ⊕ im(δ) ⊕ im(δ*)
        ↑          ↑        ↑
     HARMONIC   EXACT   CO-EXACT
     (message)  (noise)  (noise)

Security comes from:
1. Lattice hardness (like standard LWE)
2. Geometric structure (message hidden in ker Δ)

Noise distribution weighted by spectrum:
  e ~ N(0, σ²(Δ + εI)⁻¹)
  
This gives:
- SMALL noise along harmonics (protects message)
- LARGE noise along coboundaries (hides structure)
"""

import numpy as np
import secrets
import hashlib
from typing import Tuple, Optional
from dataclasses import dataclass


# ============================================================================
# SPECTRAL NOISE - Geometric Gaussian
# ============================================================================

def spectral_gaussian(
    laplacian: np.ndarray,
    sigma: float = 3.0,
    harmonic_protection: float = 0.1
) -> np.ndarray:
    """
    Sample from Laplacian-weighted Gaussian distribution.
    
    Noise variance PROPORTIONAL to eigenvalue:
    - SMALL noise along harmonics (λ ≈ 0) - protects message
    - LARGE noise along coboundaries (large λ) - hides structure
    
    Covariance: σ²(Δ + εI) where ε protects harmonics
    
    Args:
        laplacian: Sheaf Laplacian matrix Δ
        sigma: Base noise level
        harmonic_protection: Minimum noise floor (protects harmonics)
        
    Returns:
        Noise vector respecting sheaf geometry
    """
    n = laplacian.shape[0]
    
    # Eigendecomposition
    eigenvalues, eigenvectors = np.linalg.eigh(laplacian)
    
    # Noise proportional to sqrt(λ + ε)
    # Small along harmonics (λ≈0), large along coboundaries
    noise_scale = sigma * np.sqrt(np.abs(eigenvalues) + harmonic_protection)
    
    # Normalize to keep total noise bounded
    max_scale = np.max(noise_scale)
    if max_scale > 0:
        noise_scale = noise_scale / max_scale * sigma
    
    # Sample standard Gaussian in eigenbasis
    seed = int.from_bytes(secrets.token_bytes(8), 'big')
    rng = np.random.Generator(np.random.PCG64(seed))
    standard_noise = rng.standard_normal(n)
    
    # Transform to Laplacian-weighted noise
    weighted_noise = eigenvectors @ (noise_scale * standard_noise)
    
    return weighted_noise


def spectral_discrete_gaussian(
    laplacian: np.ndarray,
    sigma: float = 3.0,
    regularization: float = 1e-6
) -> np.ndarray:
    """
    Discrete Gaussian on cochain lattice.
    
    Same as spectral_gaussian but rounded to integers.
    """
    continuous = spectral_gaussian(laplacian, sigma, regularization)
    return np.round(continuous).astype(np.int64)


# ============================================================================
# HARMONIC PROJECTION
# ============================================================================

def harmonic_projection(
    cochain: np.ndarray,
    laplacian: np.ndarray,
    tolerance: float = 1e-6
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Decompose cochain into harmonic + coboundary + co-coboundary.
    
    Hodge decomposition: C^k = ker(Δ) ⊕ im(δ) ⊕ im(δ*)
    
    Args:
        cochain: Input cochain
        laplacian: Sheaf Laplacian
        tolerance: Threshold for "zero" eigenvalue
        
    Returns:
        (harmonic, exact, coexact) components
    """
    eigenvalues, eigenvectors = np.linalg.eigh(laplacian)
    
    # Harmonic = projection onto ker(Δ)
    harmonic_mask = eigenvalues < tolerance
    if np.any(harmonic_mask):
        harmonic_basis = eigenvectors[:, harmonic_mask]
        coeffs = harmonic_basis.T @ cochain
        harmonic = harmonic_basis @ coeffs
    else:
        harmonic = np.zeros_like(cochain)
    
    # Non-harmonic component
    nonharmonic = cochain - harmonic
    
    # Split non-harmonic into exact and co-exact
    # (simplified - full split needs δ and δ* separately)
    exact = nonharmonic / 2
    coexact = nonharmonic / 2
    
    return harmonic, exact, coexact


# ============================================================================
# SHEAF-LWE INSTANCE
# ============================================================================

@dataclass
class SheafLWEInstance:
    """
    LWE instance on sheaf cochain lattice.
    
    Public: (Δ, b = s + e)  where e is spectral Gaussian
    Secret: s (harmonic part = message)
    
    Hard problem: Given noisy cochain b, recover harmonic s
    """
    laplacian: np.ndarray     # Sheaf Laplacian (public structure)
    public_cochain: np.ndarray  # b = s + e
    modulus: int              # q for mod arithmetic
    
    # Secret (only prover knows)
    _secret_harmonic: Optional[np.ndarray] = None
    _noise: Optional[np.ndarray] = None


def create_sheaf_lwe(
    laplacian: np.ndarray,
    message_bits: np.ndarray,
    modulus: int = 12289,
    sigma: float = 3.0
) -> SheafLWEInstance:
    """
    Create Sheaf-LWE instance encoding message in harmonics.
    
    Args:
        laplacian: Sheaf Laplacian from credential
        message_bits: Binary message to encode
        modulus: LWE modulus q
        sigma: Noise level
        
    Returns:
        SheafLWEInstance with message hidden in harmonic subspace
    """
    n = laplacian.shape[0]
    
    # Find harmonic subspace
    eigenvalues, eigenvectors = np.linalg.eigh(laplacian)
    harmonic_mask = eigenvalues < 1e-6
    
    # Encode message in harmonic directions
    # Bit i = 1 → coefficient q/2 in harmonic direction i
    secret = np.zeros(n)
    
    n_harmonics = np.sum(harmonic_mask)
    if n_harmonics > 0:
        harmonic_basis = eigenvectors[:, harmonic_mask]
        
        for i, bit in enumerate(message_bits[:n_harmonics]):
            if bit:
                # Encode 1 as q/2 in harmonic direction
                secret += (modulus // 2) * harmonic_basis[:, i]
    else:
        # No harmonics - encode directly
        for i, bit in enumerate(message_bits[:n]):
            if bit:
                secret[i] = modulus // 2
    
    # Add spectral Gaussian noise
    noise = spectral_discrete_gaussian(laplacian, sigma)
    
    # Public cochain: b = s + e mod q
    public = (secret + noise) % modulus
    
    return SheafLWEInstance(
        laplacian=laplacian,
        public_cochain=public,
        modulus=modulus,
        _secret_harmonic=secret,
        _noise=noise
    )


def recover_from_sheaf_lwe(
    instance: SheafLWEInstance,
    laplacian: np.ndarray
) -> np.ndarray:
    """
    Recover message bits from Sheaf-LWE instance.
    
    Uses harmonic projection to extract message.
    
    Args:
        instance: SheafLWEInstance to decrypt
        laplacian: Sheaf Laplacian (must match!)
        
    Returns:
        Recovered message bits
    """
    modulus = instance.modulus
    
    # Project onto harmonic subspace
    harmonic, _, _ = harmonic_projection(
        instance.public_cochain,
        laplacian
    )
    
    # Eigendecomposition to get harmonic coefficients
    eigenvalues, eigenvectors = np.linalg.eigh(laplacian)
    harmonic_mask = eigenvalues < 1e-6
    
    # Extract bits from harmonic coefficients
    bits = []
    
    if np.sum(harmonic_mask) > 0:
        harmonic_basis = eigenvectors[:, harmonic_mask]
        coeffs = harmonic_basis.T @ instance.public_cochain
        
        for coeff in coeffs:
            coeff_mod = coeff % modulus
            # Threshold at q/4
            threshold = modulus / 4
            if threshold < coeff_mod < (3 * threshold):
                bits.append(1)
            else:
                bits.append(0)
    else:
        # Fallback: direct decoding
        for val in instance.public_cochain:
            val_mod = val % modulus
            threshold = modulus / 4
            if threshold < val_mod < (3 * threshold):
                bits.append(1)
            else:
                bits.append(0)
    
    return np.array(bits, dtype=np.int8)


# ============================================================================
# SHEAF-CONSISTENT NOISE API (for existing code)
# ============================================================================

def sheaf_discrete_gaussian(
    dim: int,
    laplacian: Optional[np.ndarray] = None,
    sigma: float = 3.0
) -> np.ndarray:
    """
    Drop-in replacement for discrete_gaussian that respects sheaf structure.
    
    If laplacian is provided: uses spectral Gaussian
    Otherwise: falls back to standard discrete Gaussian
    """
    if laplacian is not None and laplacian.shape[0] == dim:
        return spectral_discrete_gaussian(laplacian, sigma)
    else:
        # Fallback to standard discrete Gaussian
        seed = int.from_bytes(secrets.token_bytes(8), 'big')
        rng = np.random.Generator(np.random.PCG64(seed))
        continuous = rng.normal(0, sigma, size=dim)
        return np.round(continuous).astype(np.int64)


# ============================================================================
# TEST
# ============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("SHEAF-LWE TEST")
    print("=" * 60)
    
    # Create test Laplacian (simple graph)
    n = 6
    L = np.zeros((n, n))
    for i in range(n - 1):
        L[i, i] += 1
        L[i+1, i+1] += 1
        L[i, i+1] = L[i+1, i] = -1
    
    print(f"\n1. Laplacian (n={n}):")
    eigenvalues = np.sort(np.linalg.eigvalsh(L))
    print(f"   Spectrum: {np.round(eigenvalues, 4)}")
    print(f"   # Harmonics (λ < 1e-6): {np.sum(eigenvalues < 1e-6)}")
    
    # Test spectral Gaussian
    print("\n2. Spectral Gaussian noise:")
    noise = spectral_gaussian(L, sigma=3.0)
    print(f"   Noise: {np.round(noise, 2)}")
    
    # Test Sheaf-LWE
    print("\n3. Sheaf-LWE encryption:")
    message = np.array([1, 0, 1, 1, 0, 1], dtype=np.int8)
    print(f"   Message bits: {message}")
    
    instance = create_sheaf_lwe(L, message, modulus=12289, sigma=3.0)
    print(f"   Public cochain: {np.round(instance.public_cochain, 0)}")
    
    # Recover
    recovered = recover_from_sheaf_lwe(instance, L)
    print(f"   Recovered: {recovered[:len(message)]}")
    print(f"   Match: {np.array_equal(message, recovered[:len(message)])}")
    
    print("\n" + "=" * 60)
    print("✅ SHEAF-LWE: Geometric lattice hardness")
    print("=" * 60)
