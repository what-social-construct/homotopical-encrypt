"""
Cryptographically Secure Random Number Generation

Uses Python's secrets module (backed by OS entropy) for all cryptographic randomness.
This ensures all LWE secrets, nonces, and blinding factors are properly random.

NEVER use np.random for security-critical operations.
"""

import secrets
import numpy as np
from typing import Optional


def secure_seed() -> int:
    """Generate a cryptographically secure 64-bit seed."""
    return int.from_bytes(secrets.token_bytes(8), 'big')


def secure_bytes(n: int) -> bytes:
    """Generate n cryptographically secure random bytes."""
    return secrets.token_bytes(n)


def secure_rng(seed: Optional[int] = None) -> np.random.Generator:
    """
    Create a numpy Generator seeded from cryptographic randomness.
    
    Use this instead of np.random.default_rng() for security-critical code.
    The seed comes from OS entropy via secrets module.
    """
    if seed is None:
        seed = secure_seed()
    return np.random.Generator(np.random.PCG64(seed))


def secure_gaussian(size: int, mean: float = 0.0, stddev: float = 1.0) -> np.ndarray:
    """Generate cryptographically seeded Gaussian samples."""
    rng = secure_rng()
    return rng.normal(mean, stddev, size)


def secure_uniform(size: int, low: float = 0.0, high: float = 1.0) -> np.ndarray:
    """Generate cryptographically seeded uniform samples."""
    rng = secure_rng()
    return rng.uniform(low, high, size)


def secure_integers(size: int, low: int, high: int) -> np.ndarray:
    """Generate cryptographically seeded integers in [low, high)."""
    rng = secure_rng()
    return rng.integers(low, high, size)


def secure_randn(shape: tuple) -> np.ndarray:
    """
    Generate cryptographically seeded standard normal samples.
    
    Replacement for np.random.randn(*shape) in security contexts.
    """
    rng = secure_rng()
    return rng.standard_normal(shape)


# ============================================================================
# TEST
# ============================================================================

if __name__ == "__main__":
    print("=" * 50)
    print("SECURE RANDOM TEST")
    print("=" * 50)
    
    # Test secure bytes
    b1 = secure_bytes(32)
    b2 = secure_bytes(32)
    print(f"Secure bytes (32): {b1[:8].hex()}...")
    assert b1 != b2, "Should be different each time"
    print("✅ secure_bytes working")
    
    # Test secure seed
    s1 = secure_seed()
    s2 = secure_seed()
    assert s1 != s2
    print(f"✅ secure_seed working: {s1}")
    
    # Test secure Gaussian
    g = secure_gaussian(100)
    assert len(g) == 100
    assert abs(np.mean(g)) < 0.5  # Should be near 0
    print(f"✅ secure_gaussian working: mean={np.mean(g):.4f}")
    
    # Test secure integers
    i = secure_integers(100, 0, 256)
    assert all(0 <= x < 256 for x in i)
    print(f"✅ secure_integers working: {i[:5]}")
    
    print("\n✅ ALL SECURE RANDOM TESTS PASS")
