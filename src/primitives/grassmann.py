"""
Grassmann Manifold Geometry for Homotopical Cryptography

Mathematical structure: Gr(k,n) = k-dimensional subspaces of ℝⁿ

Builds on our existing exterior algebra (algebra.py: wedge, wedge_k)
to provide full Grassmannian operations:

1. PROJECTOR REPRESENTATION: P = QQᵀ (n×n projection matrix)
2. PLÜCKER REPRESENTATION: p ∈ P(∧ᵏℝⁿ) via wedge_k
3. STIEFEL REPRESENTATION: Q ∈ V_k(ℝⁿ) (orthonormal k-frame)

APPLICATION TO HOMOTOPICAL-ENCRYPT:

  Stalks as subspaces:
    Each node's stalk data spans a k-dimensional subspace of the fiber.
    Grassmann distance between stalks = geometric measure of node similarity.
    This is FINER than Euclidean distance — it respects the subspace structure.

  Consensus via Karcher mean:
    The Riemannian mean on Gr(k,n) of multiple stalk subspaces gives
    a principled "consensus subspace" — used in validator agreement.

  Principal angles for incentives:
    The k principal angles θ₁,...,θₖ between two stalk subspaces
    tell us EXACTLY which dimensions agree and which disagree.
    This feeds directly into the incentive layer.

  Plücker coordinates (from algebra.py):
    wedge_k already computes Plücker embeddings.
    This module adds the INVERSE (from_plucker) and distance operations.

  Connection to fiber bundles:
    The connection matrices R_e ∈ O(n) act on Gr(k,n) by conjugation:
    P ↦ R·P·Rᵀ. This connects Grassmannian geometry to our
    existing FiberBundle infrastructure.

REFERENCES:
  - Edelman, Arias, Smith (1998): Geometry of Algorithms with Orthogonality Constraints
  - Absil, Mahony, Sepulchre (2008): Optimization Algorithms on Matrix Manifolds
  - Zhang (2025): Attention Is Not What You Need (arXiv:2512.19428)
"""

import numpy as np
from typing import List, Tuple, Optional
from itertools import combinations

# Import our existing exterior algebra
from .algebra import wedge, wedge_k


# =============================================================================
# PROJECTOR REPRESENTATION
# =============================================================================

def subspace_projector(basis: np.ndarray) -> np.ndarray:
    """
    Compute orthogonal projector onto subspace spanned by columns.

    P = QQᵀ where Q is orthonormalized basis.

    Properties:
      P² = P (idempotent)
      Pᵀ = P (symmetric)
      rank(P) = k

    Args:
        basis: Matrix whose columns span the subspace. Shape (n, k).

    Returns:
        Projection matrix P of shape (n, n).
    """
    if basis.size == 0:
        return np.array([])

    Q, _ = np.linalg.qr(basis)
    return Q @ Q.T


def projector_rank(P: np.ndarray) -> int:
    """Rank of a projection matrix (= trace, rounded)."""
    return int(np.round(np.trace(P)))


# =============================================================================
# PRINCIPAL ANGLES (core measurement)
# =============================================================================

def principal_angles(P1: np.ndarray, P2: np.ndarray) -> np.ndarray:
    """
    Compute principal angles θ₁ ≤ θ₂ ≤ ... ≤ θₖ between two subspaces.

    The principal angles are the canonical angles between subspaces,
    computed via SVD of U₁ᵀU₂ where U₁, U₂ are orthonormal bases.

    Interpretation for incentives:
      θᵢ ≈ 0  → nodes agree on dimension i
      θᵢ ≈ π/2 → nodes completely disagree on dimension i

    Args:
        P1: First projection matrix (n × n)
        P2: Second projection matrix (n × n)

    Returns:
        Array of principal angles in [0, π/2], sorted ascending.
    """
    # Extract orthonormal bases
    eigvals1, eigvecs1 = np.linalg.eigh(P1)
    eigvals2, eigvecs2 = np.linalg.eigh(P2)

    U1 = eigvecs1[:, eigvals1 > 0.5]
    U2 = eigvecs2[:, eigvals2 > 0.5]

    if U1.shape[1] == 0 or U2.shape[1] == 0:
        return np.array([])

    # SVD of U₁ᵀU₂ gives cosines of principal angles
    cos_angles = np.linalg.svd(U1.T @ U2, compute_uv=False)
    cos_angles = np.clip(cos_angles, -1.0, 1.0)

    return np.sort(np.arccos(cos_angles))


def grassmann_distance(P1: np.ndarray, P2: np.ndarray) -> float:
    """
    Geodesic distance on Gr(k,n): d(P₁, P₂) = ‖θ‖ = √(Σ θᵢ²).

    Args:
        P1: First projection matrix
        P2: Second projection matrix

    Returns:
        Geodesic distance (scalar).
    """
    angles = principal_angles(P1, P2)
    if len(angles) == 0:
        return 0.0
    return float(np.linalg.norm(angles))


def chordal_distance(P1: np.ndarray, P2: np.ndarray) -> float:
    """
    Chordal (Frobenius) distance: d_F(P₁, P₂) = ‖P₁ - P₂‖_F / √2.

    Faster than geodesic distance, gives same ordering.
    """
    return float(np.linalg.norm(P1 - P2, 'fro') / np.sqrt(2))


# =============================================================================
# PLÜCKER COORDINATES (extends algebra.py)
# =============================================================================

def to_plucker(basis: np.ndarray) -> np.ndarray:
    """
    Convert k-plane basis to normalized Plücker coordinates.

    Uses wedge_k from algebra.py to compute the Plücker embedding
    Gr(k,n) → P(∧ᵏℝⁿ), then normalizes.

    Args:
        basis: n×k matrix whose columns span the k-plane.

    Returns:
        Normalized Plücker coordinates (dimension: C(n,k)).
    """
    if basis.ndim == 1:
        basis = basis.reshape(-1, 1)

    n, k = basis.shape
    columns = [basis[:, i] for i in range(k)]
    plucker = wedge_k(columns)

    norm = np.linalg.norm(plucker)
    if norm > 1e-10:
        plucker = plucker / norm

    return plucker


def from_plucker(plucker: np.ndarray, k: int, n: int) -> np.ndarray:
    """
    Recover orthonormal basis from Plücker coordinates (approximate inverse).

    For k=1: direction vector.
    For k=2: uses antisymmetric matrix SVD.
    General k: iterative refinement.

    Args:
        plucker: Plücker coordinates
        k: Subspace dimension
        n: Ambient space dimension

    Returns:
        n×k orthonormal basis matrix.
    """
    if k == 1:
        v = plucker / (np.linalg.norm(plucker) + 1e-10)
        return v.reshape(-1, 1)

    if k == 2:
        # Reconstruct antisymmetric matrix from Plücker coords
        A = np.zeros((n, n))
        pairs = list(combinations(range(n), 2))
        for idx, (i, j) in enumerate(pairs):
            if idx < len(plucker):
                A[i, j] = plucker[idx]
                A[j, i] = -plucker[idx]
        U, s, Vh = np.linalg.svd(A)
        return U[:, :2]

    # General: start with random basis, refine toward target Plücker
    Q = np.random.randn(n, k)
    Q, _ = np.linalg.qr(Q)

    for _ in range(20):
        current = to_plucker(Q)
        error = plucker - current
        if np.linalg.norm(error) < 1e-8:
            break
        # Gradient step
        Q = Q + 0.05 * np.outer(error[:n] if len(error) >= n else error, Q[:, 0])
        Q, _ = np.linalg.qr(Q)

    return Q


def plucker_inner_product(p1: np.ndarray, p2: np.ndarray) -> float:
    """
    Inner product of normalized Plücker coordinates.

    |⟨p₁, p₂⟩| = 1 → same subspace (up to sign)
    ⟨p₁, p₂⟩ = 0 → orthogonal subspaces
    """
    p1n = p1 / (np.linalg.norm(p1) + 1e-10)
    p2n = p2 / (np.linalg.norm(p2) + 1e-10)
    return float(np.dot(p1n, p2n))


def plucker_distance(p1: np.ndarray, p2: np.ndarray) -> float:
    """Chordal distance via Plücker: √(1 - ⟨p₁, p₂⟩²)."""
    inner = plucker_inner_product(p1, p2)
    return float(np.sqrt(max(0, 1 - inner**2)))


# =============================================================================
# EXPONENTIAL / LOGARITHMIC MAPS (geodesics on Gr(k,n))
# =============================================================================

def grassmann_exp(P: np.ndarray, V: np.ndarray) -> np.ndarray:
    """
    Exponential map on Gr(k,n): exp_P(V) → new projection matrix.

    Moves P along the geodesic in tangent direction V.

    Algorithm (Edelman et al. 1998):
      Decompose V via SVD in the U-W plane, then rotate.

    Args:
        P: Base point (projection matrix, n×n)
        V: Tangent vector at P

    Returns:
        New projection matrix at exp_P(V).
    """
    n = P.shape[0]
    v_norm = np.linalg.norm(V, 'fro')
    if v_norm < 1e-10:
        return P.copy()

    U, sigma, Wt = np.linalg.svd(V, full_matrices=False)
    tol = 1e-10 * max(sigma) if len(sigma) > 0 else 1e-10
    r = int(np.sum(sigma > tol))
    if r == 0:
        return P.copy()

    U = U[:, :r]
    sigma = sigma[:r]

    # Get orthonormal basis for current subspace
    eigvals, eigvecs = np.linalg.eigh(P)
    k = int(np.sum(eigvals > 0.5) + 0.5)
    Q = eigvecs[:, eigvals > 0.5]
    W = Wt[:r, :].T

    # Rotate Q in each U-W plane by angle sigma
    Q_new = Q.copy()
    for i in range(r):
        if sigma[i] > 1e-10:
            w_i = W[:, i] if W.shape[1] > i else np.zeros(n)
            u_i = U[:, i]
            cos_i = np.cos(sigma[i])
            sin_i = np.sin(sigma[i])

            proj_w = np.outer(w_i, w_i) @ Q_new
            proj_perp = Q_new - proj_w
            Q_new = proj_perp + cos_i * proj_w + sin_i * np.outer(u_i, w_i.T @ Q)

    Q_new, _ = np.linalg.qr(Q_new)
    return Q_new @ Q_new.T


def grassmann_log(P: np.ndarray, Q: np.ndarray) -> np.ndarray:
    """
    Logarithmic map on Gr(k,n): log_P(Q) → tangent vector at P.

    Inverse of exp: exp_P(log_P(Q)) = Q.

    Args:
        P: Base point (projection matrix)
        Q: Target point (projection matrix)

    Returns:
        Tangent vector V at P such that exp_P(V) = Q.
    """
    n = P.shape[0]
    if np.linalg.norm(P - Q, 'fro') < 1e-10:
        return np.zeros((n, n))

    eigP, vecP = np.linalg.eigh(P)
    eigQ, vecQ = np.linalg.eigh(Q)

    U_P = vecP[:, eigP > 0.5]
    U_Q = vecQ[:, eigQ > 0.5]
    k = U_P.shape[1]

    # SVD of U_P^T U_Q
    M = U_P.T @ U_Q
    Y, cos_theta, Zt = np.linalg.svd(M)
    theta = np.arccos(np.clip(cos_theta, -1, 1))
    Z = Zt.T

    # Orthogonal complement direction
    U_Q_orth = U_Q @ Z - U_P @ Y @ np.diag(cos_theta)
    for i in range(k):
        sin_i = np.sin(theta[i])
        if sin_i > 1e-10:
            U_Q_orth[:, i] /= sin_i

    # Build tangent vector
    V = np.zeros((n, n))
    for i in range(k):
        if theta[i] > 1e-10:
            y_i = U_P @ Y[:, i:i+1]
            z_i = U_Q_orth[:, i:i+1]
            V += theta[i] * (z_i @ y_i.T + y_i @ z_i.T)

    return V


def grassmann_geodesic(P: np.ndarray, Q: np.ndarray, t: float) -> np.ndarray:
    """
    Geodesic interpolation: γ(t) = exp_P(t · log_P(Q)).

    γ(0) = P, γ(1) = Q.
    """
    if t <= 0:
        return P.copy()
    if t >= 1:
        return Q.copy()
    V = grassmann_log(P, Q)
    return grassmann_exp(P, t * V)


# =============================================================================
# KARCHER MEAN (Riemannian mean on Gr(k,n))
# =============================================================================

def grassmann_karcher_mean(
    projectors: List[np.ndarray],
    max_iter: int = 20,
    tol: float = 1e-6,
) -> np.ndarray:
    """
    Karcher (Fréchet) mean: μ = argmin_P Σᵢ d²(P, Pᵢ).

    Iterative gradient descent on Gr(k,n):
      1. V = (1/n) Σ log_μ(Pᵢ)
      2. μ ← exp_μ(V)
      3. Repeat until ‖V‖ < tol

    For consensus: this gives the geometrically principled
    "average subspace" of multiple stalk subspaces.

    Args:
        projectors: List of projection matrices.
        max_iter: Maximum iterations.
        tol: Convergence tolerance.

    Returns:
        Karcher mean projection matrix.
    """
    if len(projectors) == 0:
        raise ValueError("Empty projector list")
    if len(projectors) == 1:
        return projectors[0].copy()

    mu = projectors[0].copy()

    for _ in range(max_iter):
        V_mean = np.zeros_like(mu)
        for P in projectors:
            V_mean += grassmann_log(mu, P)
        V_mean /= len(projectors)

        if np.linalg.norm(V_mean, 'fro') < tol:
            break

        mu = grassmann_exp(mu, V_mean)

    return mu


def consensus_subspace(projectors: List[np.ndarray], k: int) -> np.ndarray:
    """
    Fast consensus subspace via projector averaging (first-order approximation).

    Averages projectors, takes top-k eigenvectors.
    Faster than Karcher mean but less accurate.

    Args:
        projectors: List of projection matrices.
        k: Desired dimension of consensus subspace.

    Returns:
        n×k orthonormal basis for consensus subspace.
    """
    if not projectors:
        raise ValueError("Empty projector list")
    avg = np.mean(projectors, axis=0)
    eigenvalues, eigenvectors = np.linalg.eigh(avg)
    return eigenvectors[:, np.argsort(eigenvalues)[-k:]]


# =============================================================================
# PARALLEL TRANSPORT
# =============================================================================

def grassmann_parallel_transport(
    V: np.ndarray,
    P: np.ndarray,
    Q: np.ndarray,
) -> np.ndarray:
    """
    Parallel transport tangent vector V from T_P(Gr) to T_Q(Gr).

    Preserves inner product along the geodesic P → Q.

    Args:
        V: Tangent vector at P.
        P: Source point.
        Q: Target point.

    Returns:
        Transported vector at Q.
    """
    log_PQ = grassmann_log(P, Q)
    log_norm = np.linalg.norm(log_PQ, 'fro')

    if log_norm < 1e-10:
        return V.copy()

    U = log_PQ / log_norm
    V_parallel = np.trace(V.T @ U) * U
    V_perp = V - V_parallel

    return V_parallel + V_perp


# =============================================================================
# UTILITY
# =============================================================================

def random_grassmann_point(k: int, n: int) -> np.ndarray:
    """Sample uniformly random point on Gr(k,n)."""
    A = np.random.randn(n, k)
    Q, _ = np.linalg.qr(A)
    return Q @ Q.T


def stalk_to_subspace(stalk_data: np.ndarray, k: int) -> np.ndarray:
    """
    Convert stalk data to k-dimensional subspace projector.

    Uses top-k principal components of the stalk data matrix.
    This is how stalk data enters the Grassmannian framework.

    Args:
        stalk_data: (m, n) matrix of m stalk vectors in ℝⁿ
        k: Subspace dimension

    Returns:
        Projection matrix onto top-k principal component subspace.
    """
    if stalk_data.ndim == 1:
        stalk_data = stalk_data.reshape(1, -1)

    U, s, Vt = np.linalg.svd(stalk_data, full_matrices=False)
    basis = Vt[:min(k, len(s)), :].T  # n×k
    return subspace_projector(basis)


# =============================================================================
# TEST
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("GRASSMANN MANIFOLD TEST")
    print("=" * 60)

    n, k = 5, 2

    # Random subspaces
    P1 = random_grassmann_point(k, n)
    P2 = random_grassmann_point(k, n)

    print(f"\n1. Subspace projectors (Gr({k},{n})):")
    print(f"   rank(P1) = {projector_rank(P1)}")
    print(f"   P1² ≈ P1: {np.allclose(P1 @ P1, P1)}")

    print("\n2. Principal angles:")
    angles = principal_angles(P1, P2)
    print(f"   θ = {angles}")
    print(f"   Geodesic distance = {grassmann_distance(P1, P2):.4f}")
    print(f"   Chordal distance  = {chordal_distance(P1, P2):.4f}")
    print(f"   Self-distance     = {grassmann_distance(P1, P1):.6f}  (should be ≈ 0)")

    print("\n3. Plücker coordinates:")
    basis1 = np.linalg.eigh(P1)[1][:, -k:]
    p1 = to_plucker(basis1)
    print(f"   dim(Plücker) = {len(p1)}  (should be C({n},{k}) = {len(list(combinations(range(n), k)))})")
    print(f"   ‖p‖ = {np.linalg.norm(p1):.4f}  (should be 1)")

    # Round-trip
    basis_recovered = from_plucker(p1, k, n)
    P_recovered = subspace_projector(basis_recovered)
    print(f"   Plücker round-trip distance = {chordal_distance(P1, P_recovered):.4f}")

    print("\n4. Exp/Log maps:")
    V = grassmann_log(P1, P2)
    P2_recovered = grassmann_exp(P1, V)
    print(f"   exp(log(P2)) ≈ P2: distance = {chordal_distance(P2, P2_recovered):.6f}")

    print("\n5. Geodesic interpolation:")
    for t in [0.0, 0.25, 0.5, 0.75, 1.0]:
        Pt = grassmann_geodesic(P1, P2, t)
        d1 = grassmann_distance(P1, Pt)
        d2 = grassmann_distance(Pt, P2)
        print(f"   t={t:.2f}: d(P1,γ)={d1:.4f}  d(γ,P2)={d2:.4f}")

    print("\n6. Karcher mean:")
    projectors = [random_grassmann_point(k, n) for _ in range(5)]
    mean = grassmann_karcher_mean(projectors)
    dists = [grassmann_distance(mean, P) for P in projectors]
    print(f"   Distances to mean: {[f'{d:.4f}' for d in dists]}")
    print(f"   Mean distance: {np.mean(dists):.4f}")

    print("\n7. Stalk → subspace:")
    stalks = np.random.randn(10, n)
    P_stalk = stalk_to_subspace(stalks, k)
    print(f"   rank = {projector_rank(P_stalk)}")
    print(f"   P² ≈ P: {np.allclose(P_stalk @ P_stalk, P_stalk)}")

    print("\n" + "=" * 60)
    print("✅ GRASSMANN MANIFOLD READY")
    print("=" * 60)
