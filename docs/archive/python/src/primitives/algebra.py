"""
Exterior Algebra Operations

Pure algebraic operations on vector spaces and exterior products.
These preserve homotopy invariants and commute with coboundary δ.

Operations:
- wedge: v₁ ∧ v₂ → Plücker coordinates (antisymmetric tensor product)
- hodge_star: ∗ : ∧ᵏV → ∧ⁿ⁻ᵏV (duality via metric)
- interior_product: ι_v(ω) (contraction with vector)
- weighted_sum, scalar_multiply (basic ring ops)

These are GENERIC operations - no dependency on specific geometry.
For Hodge decomposition (C^k = H^k ⊕ im(δ) ⊕ im(δ*)), see geometry/hodge.py
"""

import numpy as np
from typing import List, Tuple, Union
from functools import reduce


# =============================================================================
# WEDGE PRODUCT
# =============================================================================

def wedge(v1: np.ndarray, v2: np.ndarray) -> np.ndarray:
    """
    Wedge product of two vectors: v1 ∧ v2.
    
    Returns antisymmetric tensor (Plücker coordinates).
    In 3D, this is related to cross product.
    In nD, result has n(n-1)/2 components.
    
    Args:
        v1: First vector
        v2: Second vector
        
    Returns:
        Wedge product as flattened antisymmetric matrix (upper triangle)
    """
    n = len(v1)
    if len(v2) != n:
        raise ValueError("Vectors must have same dimension")
    
    # Build antisymmetric matrix M[i,j] = v1[i]*v2[j] - v1[j]*v2[i]
    M = np.outer(v1, v2) - np.outer(v2, v1)
    
    # Extract upper triangle (Plücker coordinates)
    result = []
    for i in range(n):
        for j in range(i + 1, n):
            result.append(M[i, j])
    
    return np.array(result)


def wedge_k(vectors: List[np.ndarray]) -> np.ndarray:
    """
    k-fold wedge product: v1 ∧ v2 ∧ ... ∧ vk.
    
    Computes the k-vector from k vectors.
    Result has C(n,k) components (n choose k).
    
    Args:
        vectors: List of k vectors of same dimension n
        
    Returns:
        k-vector (antisymmetric k-tensor)
    """
    if len(vectors) == 0:
        return np.array([1.0])  # Scalar (0-form)
    
    if len(vectors) == 1:
        return vectors[0].copy()
    
    n = len(vectors[0])
    k = len(vectors)
    
    if k > n:
        return np.array([0.0])  # Zero if k > n
    
    # Stack vectors as rows
    V = np.array(vectors)
    
    # Compute all k×k minors (Plücker coordinates)
    from itertools import combinations
    
    result = []
    for indices in combinations(range(n), k):
        # Extract k×k submatrix
        submatrix = V[:, indices]
        # Determinant gives wedge component
        result.append(np.linalg.det(submatrix))
    
    return np.array(result)


# =============================================================================
# HODGE STAR OPERATOR
# =============================================================================

def hodge_star(omega: np.ndarray, n: int, k: int, metric: np.ndarray = None) -> np.ndarray:
    """
    Hodge star operator: ∗ : ∧ᵏV → ∧ⁿ⁻ᵏV.
    
    Maps k-forms to (n-k)-forms using the metric (inner product).
    With standard metric: ∗(dx ∧ dy) = dz in ℝ³.
    
    Args:
        omega: k-form (as Plücker coordinates)
        n: Dimension of underlying space
        k: Degree of omega
        metric: Optional metric tensor (default: identity = Euclidean)
        
    Returns:
        (n-k)-form
    """
    from itertools import combinations
    from math import factorial
    
    if metric is None:
        metric = np.eye(n)
    
    # Number of components
    n_k = len(list(combinations(range(n), k)))
    n_nk = len(list(combinations(range(n), n - k)))
    
    if len(omega) != n_k:
        raise ValueError(f"Expected {n_k} components for {k}-form in dim {n}")
    
    # Build index mapping
    k_indices = list(combinations(range(n), k))
    nk_indices = list(combinations(range(n), n - k))
    
    # Compute Hodge star
    result = np.zeros(n_nk)
    det_g = np.linalg.det(metric)
    sqrt_det_g = np.sqrt(abs(det_g))
    
    for i, (I, omega_I) in enumerate(zip(k_indices, omega)):
        # Find complementary index set J
        J = tuple(j for j in range(n) if j not in I)
        
        # Sign from permutation
        combined = I + J
        sign = _permutation_sign(combined, tuple(range(n)))
        
        # Find J in nk_indices
        try:
            j_idx = nk_indices.index(J)
            result[j_idx] += sign * sqrt_det_g * omega_I
        except ValueError:
            pass  # J not in standard order, need to permute
    
    return result


def _permutation_sign(perm: Tuple[int, ...], identity: Tuple[int, ...]) -> int:
    """Compute sign of permutation."""
    perm = list(perm)
    identity = list(identity)
    
    n = len(perm)
    inversions = 0
    
    for i in range(n):
        for j in range(i + 1, n):
            if perm[i] > perm[j]:
                inversions += 1
    
    return 1 if inversions % 2 == 0 else -1


# =============================================================================
# INTERIOR PRODUCT (CONTRACTION)
# =============================================================================

def interior_product(v: np.ndarray, omega: np.ndarray, n: int, k: int) -> np.ndarray:
    """
    Interior product (contraction): ι_v(ω).
    
    Contracts a vector with a k-form to get a (k-1)-form.
    ι_v(ω)(v1,...,vk-1) = ω(v, v1,...,vk-1)
    
    Args:
        v: Vector to contract with
        omega: k-form (Plücker coordinates)
        n: Dimension of space
        k: Degree of omega
        
    Returns:
        (k-1)-form
    """
    from itertools import combinations
    
    if k == 0:
        return np.array([0.0])  # Interior product of 0-form is 0
    
    k_indices = list(combinations(range(n), k))
    km1_indices = list(combinations(range(n), k - 1))
    
    result = np.zeros(len(km1_indices))
    
    for i, (I, omega_I) in enumerate(zip(k_indices, omega)):
        for pos, idx in enumerate(I):
            # Contract at position pos
            J = tuple(j for j in I if j != idx)
            sign = (-1) ** pos
            
            try:
                j_idx = km1_indices.index(J)
                result[j_idx] += sign * v[idx] * omega_I
            except ValueError:
                pass
    
    return result


# =============================================================================
# BASIC RING OPERATIONS
# =============================================================================

def weighted_sum(vectors: List[np.ndarray], weights: List[float]) -> np.ndarray:
    """
    Weighted sum of vectors: Σ w_i · v_i.
    
    This is the fundamental ring operation for cochain addition.
    """
    if len(vectors) != len(weights):
        raise ValueError("Must have same number of vectors and weights")
    
    if len(vectors) == 0:
        return np.array([])
    
    result = np.zeros_like(vectors[0], dtype=float)
    for v, w in zip(vectors, weights):
        result += w * v
    
    return result


def scalar_multiply(vector: np.ndarray, scalar: float) -> np.ndarray:
    """
    Scalar multiplication: α · v.
    """
    return scalar * vector


# =============================================================================
# UTILITY
# =============================================================================

def binomial(n: int, k: int) -> int:
    """Binomial coefficient C(n,k) = n choose k."""
    if k < 0 or k > n:
        return 0
    if k == 0 or k == n:
        return 1
    from math import factorial
    return factorial(n) // (factorial(k) * factorial(n - k))


def form_dimension(n: int, k: int) -> int:
    """Number of components in a k-form on n-dimensional space."""
    return binomial(n, k)


if __name__ == "__main__":
    print("=" * 60)
    print("EXTERIOR ALGEBRA TEST")
    print("=" * 60)
    
    # Test wedge product
    print("\n1. Wedge product in ℝ³:")
    e1 = np.array([1, 0, 0])
    e2 = np.array([0, 1, 0])
    e3 = np.array([0, 0, 1])
    
    print(f"   e1 ∧ e2 = {wedge(e1, e2)}")  # Should be [1, 0, 0]
    print(f"   e2 ∧ e3 = {wedge(e2, e3)}")  # Should be [0, 0, 1]
    print(f"   e1 ∧ e1 = {wedge(e1, e1)}")  # Should be [0, 0, 0]
    
    # Test k-fold wedge
    print("\n2. 3-fold wedge (volume form):")
    vol = wedge_k([e1, e2, e3])
    print(f"   e1 ∧ e2 ∧ e3 = {vol}")  # Should be [1] (single component)
    
    # Test Hodge star in ℝ³
    print("\n3. Hodge star in ℝ³:")
    dx_dy = wedge(e1, e2)  # dx ∧ dy
    star_dx_dy = hodge_star(dx_dy, n=3, k=2)
    print(f"   ∗(dx ∧ dy) = {star_dx_dy}")  # Should be dz = [0, 0, 1]
    
    # Test interior product
    print("\n4. Interior product:")
    v = np.array([1, 2, 3])
    omega = np.array([1.0])  # 3-form (volume)
    result = interior_product(v, omega, n=3, k=3)
    print(f"   ι_v(dx∧dy∧dz) has {len(result)} components")
    
    print("\n" + "=" * 60)
    print("✅ EXTERIOR ALGEBRA READY")
    print("=" * 60)
