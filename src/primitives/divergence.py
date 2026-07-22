"""
DEPRECATED UNSELECTED RESEARCH METRICS — NOT A HOMOTOPY OR CONSENSUS GATE.

No current Lean or protocol object selects these metrics, and they are no
longer exported from ``src.primitives``.  See
``docs/SEMANTIC_PARITY_QUEUE.md`` before reintroducing a narrowly specified
runtime diagnostic.

Divergence Measures for Homotopical Cryptography

Information-theoretic distance functions for comparing distributions,
stalks, and node contributions in the incentive layer.

WHAT THIS ADDS:

  The current system compares stalks via:
  - Frobenius norm of restriction maps (coarse)
  - Spectral fingerprint hash (binary: match/no-match)
  - Grassmann distance (subspace-level)

  Divergences add DISTRIBUTIONAL comparison:
  - KL divergence: asymmetric, penalizes missing support
  - JSD: symmetric, bounded, smooth — ideal for pairwise stalk comparison
  - Itakura-Saito: for positive measures (e.g., spectral densities)
  - Bregman: general framework, subsumes all of the above
  - Wasserstein: respects metric structure (earth mover's distance)

INCENTIVE LAYER INTERPRETATION:

  JSD(stalk_i, stalk_j) on edge (i,j):
    Low JSD = stalks agree = genuine edge = high edge weight
    High JSD = stalks disagree = weak edge = low edge weight
    → WEIGHT sheaf Laplacian by 1/JSD (or exp(-JSD))

  KL(stalk_i || consensus):
    Measures how far node i deviates from consensus
    → PENALTY in incentive layer for high KL

  Wasserstein(stalk_i, stalk_j):
    Respects geometry — small perturbation = small distance
    More robust than KL to zero-mass regions
    → Used for equivalence checking in homotopy classes

REFERENCES:
  - Kullback & Leibler (1951): On Information and Sufficiency
  - Lin (1991): Divergence measures based on Shannon entropy (JSD)
  - Bregman (1967): The relaxation method for finding common points of convex sets
  - Amari (2016): Information Geometry and its Applications
"""

import numpy as np
from typing import Callable, Optional, Dict


# =============================================================================
# CORE DIVERGENCES
# =============================================================================

def kullback_leibler(p: np.ndarray, q: np.ndarray, eps: float = 1e-10) -> float:
    """
    KL divergence: D_KL(p || q) = Σ pᵢ log(pᵢ / qᵢ).

    Asymmetric. Measures information lost when using q to approximate p.

    Args:
        p: Distribution (will be normalized).
        q: Reference distribution (will be normalized).
        eps: Smoothing for numerical stability.

    Returns:
        KL divergence (≥ 0). Zero iff p = q.
    """
    p = np.clip(np.asarray(p, dtype=float), eps, None)
    q = np.clip(np.asarray(q, dtype=float), eps, None)
    p = p / np.sum(p)
    q = q / np.sum(q)
    return float(np.sum(p * np.log(p / q)))


def jensen_shannon(p: np.ndarray, q: np.ndarray, eps: float = 1e-10) -> float:
    """
    Jensen-Shannon divergence: JSD(p, q) = ½ KL(p||m) + ½ KL(q||m)
    where m = ½(p + q).

    Properties:
      - Symmetric: JSD(p,q) = JSD(q,p)
      - Bounded: 0 ≤ JSD ≤ ln(2)
      - Smooth: no singularities even when supports differ
      - √JSD is a metric

    Ideal for pairwise stalk comparison on sheaf edges.

    Args:
        p: First distribution.
        q: Second distribution.
        eps: Smoothing.

    Returns:
        JSD value in [0, ln(2)].
    """
    p = np.clip(np.asarray(p, dtype=float), eps, None)
    q = np.clip(np.asarray(q, dtype=float), eps, None)
    p = p / np.sum(p)
    q = q / np.sum(q)
    m = 0.5 * (p + q)
    return float(0.5 * np.sum(p * np.log(p / m)) + 0.5 * np.sum(q * np.log(q / m)))


def itakura_saito(x: np.ndarray, y: np.ndarray, eps: float = 1e-10) -> float:
    """
    Itakura-Saito divergence: D_IS(x||y) = Σ (xᵢ/yᵢ - log(xᵢ/yᵢ) - 1).

    For positive measures (spectral densities, power spectra).
    Scale-invariant: D_IS(αx, αy) = D_IS(x, y) for α > 0.

    Args:
        x: Positive measure.
        y: Reference positive measure.
        eps: Smoothing.

    Returns:
        IS divergence (≥ 0).
    """
    x = np.clip(np.asarray(x, dtype=float), eps, None)
    y = np.clip(np.asarray(y, dtype=float), eps, None)
    ratio = x / y
    return float(np.sum(ratio - np.log(ratio) - 1))


def mahalanobis(x: np.ndarray, y: np.ndarray, cov: Optional[np.ndarray] = None) -> float:
    """
    Mahalanobis divergence: (x-y)ᵀ Σ⁻¹ (x-y).

    Accounts for correlation structure. With Σ = I, reduces to squared Euclidean.

    For stalks: use the sheaf Laplacian as covariance structure.

    Args:
        x: Point vector.
        y: Reference vector.
        cov: Covariance matrix (default: identity).

    Returns:
        Mahalanobis distance squared.
    """
    diff = np.asarray(x, dtype=float) - np.asarray(y, dtype=float)
    if cov is None:
        return float(np.sum(diff**2))
    return float(diff @ np.linalg.solve(cov, diff))


def hellinger(p: np.ndarray, q: np.ndarray, eps: float = 1e-10) -> float:
    """
    Hellinger distance: H(p,q) = √(1 - Σ √(pᵢqᵢ)).

    Bounded in [0, 1]. Symmetric. Related to Bhattacharyya coefficient.

    Args:
        p, q: Distributions.
        eps: Smoothing.

    Returns:
        Hellinger distance in [0, 1].
    """
    p = np.clip(np.asarray(p, dtype=float), eps, None)
    q = np.clip(np.asarray(q, dtype=float), eps, None)
    p = p / np.sum(p)
    q = q / np.sum(q)
    bc = np.sum(np.sqrt(p * q))
    return float(np.sqrt(max(0, 1 - bc)))


def total_variation(p: np.ndarray, q: np.ndarray) -> float:
    """
    Total variation distance: TV(p,q) = ½ Σ |pᵢ - qᵢ|.

    Bounded in [0, 1]. The strongest common divergence.

    Args:
        p, q: Distributions.

    Returns:
        TV distance in [0, 1].
    """
    p = np.asarray(p, dtype=float)
    q = np.asarray(q, dtype=float)
    p = p / (np.sum(p) + 1e-10)
    q = q / (np.sum(q) + 1e-10)
    return float(0.5 * np.sum(np.abs(p - q)))


# =============================================================================
# WASSERSTEIN (earth mover's distance, 1D)
# =============================================================================

def wasserstein_1d(p: np.ndarray, q: np.ndarray) -> float:
    """
    Wasserstein-1 distance for 1D distributions (earth mover's distance).

    W₁(p, q) = ∫ |F_p(x) - F_q(x)| dx

    where F_p, F_q are CDFs. Computed exactly via sorted CDF difference.

    Respects metric structure — unlike KL/JSD, small perturbation
    always gives small distance.

    Args:
        p, q: 1D distributions (same length, will be normalized).

    Returns:
        Wasserstein-1 distance.
    """
    p = np.asarray(p, dtype=float)
    q = np.asarray(q, dtype=float)
    p = p / (np.sum(p) + 1e-10)
    q = q / (np.sum(q) + 1e-10)

    # CDF difference
    cdf_p = np.cumsum(p)
    cdf_q = np.cumsum(q)
    return float(np.sum(np.abs(cdf_p - cdf_q)) / len(p))


# =============================================================================
# GENERAL BREGMAN FRAMEWORK
# =============================================================================

def bregman_divergence(
    x: np.ndarray,
    y: np.ndarray,
    F: Callable[[np.ndarray], float],
    grad_F: Callable[[np.ndarray], np.ndarray],
) -> float:
    """
    General Bregman divergence: D_F(x||y) = F(x) - F(y) - ∇F(y)·(x-y).

    All the divergences above are special cases:
      KL: F(p) = Σ pᵢ log pᵢ (negative entropy)
      IS: F(x) = -Σ log xᵢ (Burg entropy)
      Mahalanobis: F(x) = ½ xᵀΣ⁻¹x (quadratic)

    Args:
        x: Point.
        y: Reference point.
        F: Convex generator function.
        grad_F: Gradient of F.

    Returns:
        Bregman divergence D_F(x||y).
    """
    x = np.asarray(x, dtype=float)
    y = np.asarray(y, dtype=float)
    return float(F(x) - F(y) - np.dot(grad_F(y), x - y))


# =============================================================================
# ADAPTIVE SELECTION
# =============================================================================

def adaptive_divergence(
    x: np.ndarray,
    y: np.ndarray,
    symmetric: bool = True,
) -> float:
    """
    Automatically select best divergence based on data characteristics.

    - Probability distributions (sum ≈ 1, non-negative) → JSD or KL
    - Positive measures → Itakura-Saito
    - General vectors → squared Euclidean

    Args:
        x, y: Vectors to compare.
        symmetric: Use symmetric divergence if applicable.

    Returns:
        Appropriate divergence value.
    """
    x = np.asarray(x, dtype=float)
    y = np.asarray(y, dtype=float)

    is_prob = (
        np.all(x >= 0) and np.all(y >= 0)
        and np.isclose(np.sum(x), 1.0, atol=0.02)
        and np.isclose(np.sum(y), 1.0, atol=0.02)
    )

    if is_prob:
        return jensen_shannon(x, y) if symmetric else kullback_leibler(x, y)

    if np.all(x > 0) and np.all(y > 0):
        return itakura_saito(x, y)

    return float(np.sum((x - y)**2))


# =============================================================================
# DIVERGENCE REGISTRY
# =============================================================================

REGISTRY: Dict[str, Callable] = {
    'kl': kullback_leibler,
    'jsd': jensen_shannon,
    'itakura_saito': itakura_saito,
    'mahalanobis': mahalanobis,
    'hellinger': hellinger,
    'tv': total_variation,
    'wasserstein': wasserstein_1d,
    'adaptive': adaptive_divergence,
}


def get_divergence(name: str) -> Callable:
    """Get divergence function by name."""
    if name not in REGISTRY:
        raise ValueError(f"Unknown divergence: {name}. Available: {list(REGISTRY.keys())}")
    return REGISTRY[name]


# =============================================================================
# TEST
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("DIVERGENCE MEASURES TEST")
    print("=" * 60)

    p = np.array([0.25, 0.25, 0.25, 0.25])  # Uniform
    q = np.array([0.1, 0.2, 0.3, 0.4])      # Skewed

    print("\n1. KL divergence:")
    print(f"   D_KL(uniform || skewed) = {kullback_leibler(p, q):.6f}")
    print(f"   D_KL(skewed || uniform) = {kullback_leibler(q, p):.6f}")
    print(f"   D_KL(p || p) = {kullback_leibler(p, p):.6f}  (should be ≈ 0)")

    print("\n2. Jensen-Shannon divergence:")
    print(f"   JSD(uniform, skewed) = {jensen_shannon(p, q):.6f}")
    print(f"   JSD(skewed, uniform) = {jensen_shannon(q, p):.6f}  (should be same)")
    print(f"   JSD(p, p) = {jensen_shannon(p, p):.6f}  (should be ≈ 0)")

    print("\n3. Hellinger distance:")
    print(f"   H(uniform, skewed) = {hellinger(p, q):.6f}")
    print(f"   H(p, p) = {hellinger(p, p):.6f}")

    print("\n4. Total variation:")
    print(f"   TV(uniform, skewed) = {total_variation(p, q):.6f}")

    print("\n5. Wasserstein-1:")
    print(f"   W₁(uniform, skewed) = {wasserstein_1d(p, q):.6f}")

    print("\n6. Itakura-Saito:")
    x = np.array([1.0, 2.0, 3.0, 4.0])
    y = np.array([1.1, 1.9, 3.1, 3.9])
    print(f"   D_IS(x, y) = {itakura_saito(x, y):.6f}")

    print("\n7. Mahalanobis:")
    cov = np.array([[1.0, 0.5], [0.5, 2.0]])
    print(f"   D_M([0,0], [1,1]) = {mahalanobis(np.zeros(2), np.ones(2), cov):.6f}")

    print("\n8. Adaptive selection:")
    print(f"   Probability: {adaptive_divergence(p, q):.6f}  (should use JSD)")
    print(f"   Positive:    {adaptive_divergence(x, y):.6f}  (should use IS)")
    print(f"   General:     {adaptive_divergence(np.array([-1,0,1]), np.array([0,1,2])):.6f}  (should use L²)")

    print("\n" + "=" * 60)
    print("✅ DIVERGENCE MEASURES READY")
    print("=" * 60)
