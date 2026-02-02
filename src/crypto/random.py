"""
Secure Random Generation

Cryptographically secure random generation using Python's secrets module.
All randomness in the crypto layer should flow through here.
"""

import secrets
import numpy as np
from typing import Optional


def secure_random_bytes(n: int) -> bytes:
    """Cryptographically secure random bytes."""
    return secrets.token_bytes(n)


def secure_random_int(low: int, high: int) -> int:
    """Cryptographically secure random integer in [low, high)."""
    range_size = high - low
    return low + secrets.randbelow(range_size)


def secure_rng() -> np.random.Generator:
    """Create crypto-seeded numpy random generator."""
    seed = int.from_bytes(secure_random_bytes(8), 'big')
    return np.random.Generator(np.random.PCG64(seed))


def secure_random_matrix(rows: int, cols: int, modulus: int) -> np.ndarray:
    """Generate random matrix with crypto-secure randomness."""
    rng = secure_rng()
    return rng.integers(0, modulus, size=(rows, cols), dtype=np.int64)


def secure_random_vector(dim: int, modulus: int) -> np.ndarray:
    """Generate random vector with crypto-secure randomness."""
    rng = secure_rng()
    return rng.integers(0, modulus, size=dim, dtype=np.int64)


def secure_random_orthogonal(n: int) -> np.ndarray:
    """Generate random orthogonal matrix (for fiber mixing)."""
    rng = secure_rng()
    # Generate random matrix and QR decompose
    A = rng.standard_normal((n, n))
    Q, R = np.linalg.qr(A)
    # Ensure determinant = 1 (special orthogonal)
    if np.linalg.det(Q) < 0:
        Q[:, 0] *= -1
    return Q
