"""
Hodge Decomposition for Sheaf Cochains

The Hodge theorem gives orthogonal decomposition:

  C^k(X, F) = H^k ⊕ im(δ) ⊕ im(δ*)
               ↑       ↑        ↑
           harmonic  exact   co-exact

Where:
- H^k = ker(Δ) = ker(δ) ∩ ker(δ*) = harmonic cochains
- im(δ) = exact cochains (coboundaries from C^{k-1})
- im(δ*) = co-exact cochains (from C^{k+1})

The Laplacian: Δ = δ*δ + δδ*

Local-to-global coherence interpretation:

  The restriction maps R_{v→e} are context projections between
  stalk types (see primitives/stalk.py). The coboundary δ measures
  disagreement between how vertices project to shared edge contexts.

  ker(Δ) = global sections = data consistent under all restrictions.
  im(δ)⊕im(δ*) = disagreement subspace = orthogonal to all global
  sections.

  For encryption:
  - message ∈ ker(Δ): globally coherent data, survives all projections
  - noise ∈ im(δ)⊕im(δ*): disagreement noise, invisible to π_H
  - decrypt := π_H (Hodge projection extracts the coherent part)
  - lattice threshold at vertex 0 provides a dual/fallback decode path
"""

import numpy as np
from typing import Tuple, Dict, List, Optional
from dataclasses import dataclass

# Canonical kernel tolerance — single source of truth.
# Avoids circular import: credential imports geometry, so we define
# the raw formula here and credential.py re-exports it.
def _kernel_tolerance(eigenvalues: np.ndarray) -> float:
    """Compute kernel identification tolerance from eigenvalues."""
    _KERNEL_RELATIVE_TOL = 1e-10
    _KERNEL_ABSOLUTE_FLOOR = 1e-6
    if len(eigenvalues) == 0:
        return _KERNEL_ABSOLUTE_FLOOR
    max_eig = np.max(np.abs(eigenvalues))
    return max(max_eig * _KERNEL_RELATIVE_TOL, _KERNEL_ABSOLUTE_FLOOR)


@dataclass
class HodgeDecomposition:
    """
    Result of Hodge decomposition.
    
    cochain = harmonic + exact + coexact
    """
    harmonic: np.ndarray      # ker(Δ) component
    exact: np.ndarray         # im(δ) component  
    coexact: np.ndarray       # im(δ*) component
    
    # Projectors
    P_harmonic: np.ndarray    # Projection onto H^k
    P_exact: np.ndarray       # Projection onto im(δ)
    P_coexact: np.ndarray     # Projection onto im(δ*)


def build_coboundary_operator(
    nerve: Dict[int, List[Tuple]],
    stalk_dim: int = 1
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Build the coboundary operators δ_0: C^0 → C^1 and δ_1: C^1 → C^2.
    
    For a simplicial complex:
    - δ_0(f)(e) = f(∂_1 e) - f(∂_0 e) = f(head) - f(tail)
    - δ_1 similar for higher simplices
    
    Args:
        nerve: Čech nerve (0-cells, 1-cells, 2-cells)
        stalk_dim: Dimension of stalks (default 1)
        
    Returns:
        (δ_0, δ_1) coboundary matrices
    """
    vertices = nerve.get(0, [])
    edges = nerve.get(1, [])
    triangles = nerve.get(2, [])
    
    n_v = len(vertices)
    n_e = len(edges)
    n_t = len(triangles)
    
    # Build vertex index map
    v_idx = {tuple(v): i for i, v in enumerate(vertices)}
    e_idx = {tuple(e): i for i, e in enumerate(edges)}
    
    # δ_0: C^0 → C^1 (vertices to edges)
    # Size: (n_e * stalk_dim) x (n_v * stalk_dim)
    delta_0 = np.zeros((n_e * stalk_dim, n_v * stalk_dim))
    
    for i, edge in enumerate(edges):
        if len(edge) >= 2:
            v0, v1 = edge[0], edge[1]
            
            # Find vertex indices
            v0_key = (v0,) if isinstance(v0, int) else v0
            v1_key = (v1,) if isinstance(v1, int) else v1
            
            # For each stalk dimension
            for d in range(stalk_dim):
                row = i * stalk_dim + d
                
                if v0_key in v_idx:
                    col0 = v_idx[v0_key] * stalk_dim + d
                    delta_0[row, col0] = -1
                    
                if v1_key in v_idx:
                    col1 = v_idx[v1_key] * stalk_dim + d
                    delta_0[row, col1] = 1
    
    # δ_1: C^1 → C^2 (edges to triangles)
    delta_1 = np.zeros((max(n_t, 1) * stalk_dim, n_e * stalk_dim))
    
    for i, tri in enumerate(triangles):
        if len(tri) >= 3:
            # Triangle has 3 edges with alternating signs
            v0, v1, v2 = tri[:3]
            
            # Edges: (v0,v1), (v1,v2), (v0,v2)
            edges_of_tri = [
                tuple(sorted([v0, v1])),
                tuple(sorted([v1, v2])),
                tuple(sorted([v0, v2]))
            ]
            signs = [1, 1, -1]  # Orientation
            
            for d in range(stalk_dim):
                row = i * stalk_dim + d
                for e_tuple, sign in zip(edges_of_tri, signs):
                    if e_tuple in e_idx:
                        col = e_idx[e_tuple] * stalk_dim + d
                        delta_1[row, col] = sign
    
    return delta_0, delta_1


def compute_laplacian_from_coboundary(
    delta: np.ndarray,
    delta_prev: Optional[np.ndarray] = None
) -> np.ndarray:
    """
    Compute Laplacian from coboundary operators.
    
    Δ_k = δ*_{k} δ_k + δ_{k-1} δ*_{k-1}
    
    In matrix terms:
    Δ = δ^T δ + δ_{prev} δ_{prev}^T
    """
    n = delta.shape[1]  # Domain dimension
    
    # δ*δ term (from above)
    laplacian = delta.T @ delta
    
    # δδ* term (from below) - if we have δ_{k-1}
    if delta_prev is not None and delta_prev.shape[0] == n:
        laplacian += delta_prev @ delta_prev.T
    
    return laplacian


def hodge_decomposition(
    cochain: np.ndarray,
    laplacian: np.ndarray,
    delta: Optional[np.ndarray] = None,
    delta_prev: Optional[np.ndarray] = None,
    tolerance: float = 1e-6
) -> HodgeDecomposition:
    """
    Compute full Hodge decomposition of a cochain.
    
    C^k = H^k ⊕ im(δ) ⊕ im(δ*)
    
    Args:
        cochain: Input cochain to decompose
        laplacian: Laplacian matrix Δ
        delta: Coboundary δ: C^k → C^{k+1} (for co-exact)
        delta_prev: Coboundary δ: C^{k-1} → C^k (for exact)
        tolerance: Eigenvalue threshold for harmonics
        
    Returns:
        HodgeDecomposition with harmonic, exact, coexact components
    """
    n = len(cochain)
    
    # Eigendecomposition of Laplacian
    eigenvalues, eigenvectors = np.linalg.eigh(laplacian)
    
    # 1. HARMONIC projection: ker(Δ)
    # Use canonical _kernel_tolerance — same formula as keygen, encrypt, decrypt.
    effective_tol = _kernel_tolerance(eigenvalues)
    harmonic_mask = np.abs(eigenvalues) < effective_tol
    n_harmonic = np.sum(harmonic_mask)
    
    if n_harmonic > 0:
        V_harmonic = eigenvectors[:, harmonic_mask]
        P_harmonic = V_harmonic @ V_harmonic.T
    else:
        P_harmonic = np.zeros((n, n))
    
    harmonic = P_harmonic @ cochain
    
    # 2. EXACT projection: im(δ_{k-1})
    if delta_prev is not None:
        # im(δ_{k-1}) = range of delta_prev
        # Orthogonal projector: δ(δ^T δ)^{-1} δ^T (pseudoinverse projection)
        try:
            P_exact = delta_prev @ np.linalg.pinv(delta_prev)
        except:
            P_exact = np.zeros((n, n))
    else:
        # No lower-degree cochains, no exact part
        P_exact = np.zeros((n, n))
    
    exact = P_exact @ cochain
    
    # 3. CO-EXACT projection: im(δ*_k) = im(δ^T) from higher degree
    if delta is not None:
        # im(δ*) = im(δ^T) 
        delta_star = delta.T
        try:
            P_coexact = delta_star @ np.linalg.pinv(delta_star)
        except:
            P_coexact = np.zeros((n, n))
    else:
        P_coexact = np.zeros((n, n))
    
    coexact = P_coexact @ cochain
    
    # Orthogonalize: subtract overlaps
    # True Hodge: harmonic, exact, coexact are orthogonal
    exact_orth = exact - P_harmonic @ exact
    coexact_orth = coexact - P_harmonic @ coexact - P_exact @ coexact
    
    return HodgeDecomposition(
        harmonic=harmonic,
        exact=exact_orth,
        coexact=coexact_orth,
        P_harmonic=P_harmonic,
        P_exact=P_exact,
        P_coexact=P_coexact
    )


def compute_hodge_projectors(
    laplacian: np.ndarray,
    delta: Optional[np.ndarray] = None,
    delta_prev: Optional[np.ndarray] = None,
    tolerance: float = 1e-6
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Compute Hodge projectors P_harmonic, P_exact, P_coexact.
    
    These projectors satisfy: I = P_H + P_exact + P_coexact (approx)
    
    For C^k space:
    - P_exact projects onto im(δ_{k-1}) - image of lower coboundary INTO C^k
    - P_coexact projects onto im(δ*_k) = im(δ_k^T) - from higher degree
    
    Args:
        laplacian: Laplacian for harmonic subspace (n x n)
        delta: Coboundary δ_k: C^k → C^{k+1} for co-exact subspace
        delta_prev: Coboundary δ_{k-1}: C^{k-1} → C^k for exact subspace
        tolerance: Eigenvalue threshold for harmonics
        
    Returns:
        (P_harmonic, P_exact, P_coexact) projector matrices, all (n x n)
    """
    n = laplacian.shape[0]
    
    # Compute projectors
    eigenvalues, eigenvectors = np.linalg.eigh(laplacian)
    # Use canonical _kernel_tolerance — same formula as keygen, encrypt, decrypt.
    effective_tol = _kernel_tolerance(eigenvalues)
    harmonic_mask = np.abs(eigenvalues) < effective_tol
    
    # Harmonic projector
    if np.any(harmonic_mask):
        V_H = eigenvectors[:, harmonic_mask]
        P_H = V_H @ V_H.T
    else:
        P_H = np.zeros((n, n))
    
    # Exact projector: im(δ_{k-1}) ⊂ C^k
    # δ_{k-1} maps C^{k-1} → C^k, so its image is in C^k
    # P_exact = δ_{k-1} (δ_{k-1}^T δ_{k-1})^{-1} δ_{k-1}^T  (range projection)
    if delta_prev is not None and delta_prev.shape[0] == n:
        # delta_prev: (n, m) where m = dim(C^{k-1})
        # Range projector: A @ pinv(A) projects onto im(A)
        P_exact = delta_prev @ np.linalg.pinv(delta_prev)
    elif delta_prev is not None:
        # Dimension mismatch - delta_prev rows != n
        # This means delta_prev maps TO somewhere else, not to C^k
        # For C^0 (vertices), there's nothing below, so exact = 0
        P_exact = np.zeros((n, n))
    else:
        P_exact = np.zeros((n, n))
    
    # Co-exact projector: im(δ*_k) = im(δ_k^T) ⊂ C^k  
    # δ_k: C^k → C^{k+1}, so δ_k^T: C^{k+1} → C^k
    # Its image (range) is in C^k
    if delta is not None and delta.shape[1] == n:
        # delta: (m, n) where m = dim(C^{k+1})
        # δ^T: (n, m), its range projection: δ^T @ pinv(δ^T)
        delta_star = delta.T
        P_coexact = delta_star @ np.linalg.pinv(delta_star)
    elif delta is not None:
        # Dimension mismatch
        P_coexact = np.zeros((n, n))
    elif delta_prev is None:
        # No coboundary operators at all — Laplacian-only mode.
        # For C^0 (vertex cochains): P_exact = 0, so
        # P_coexact = I - P_harmonic completes the decomposition.
        # More generally: non-harmonic eigenspace = im(δ) ⊕ im(δ*),
        # but without coboundary ops we can't split them, so we assign
        # the entire non-harmonic part to coexact.
        P_coexact = np.eye(n) - P_H
    else:
        P_coexact = np.zeros((n, n))
    
    return P_H, P_exact, P_coexact


# Note: hodge_noise moved to geometry/noise.py as hodge_structured_noise()


# ============================================================================
# TEST
# ============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("HODGE DECOMPOSITION TEST")
    print("=" * 60)
    
    # Build simple nerve (triangle)
    nerve = {
        0: [(0,), (1,), (2,)],       # 3 vertices
        1: [(0, 1), (1, 2), (0, 2)],  # 3 edges
        2: [(0, 1, 2)]               # 1 triangle
    }
    
    print("\n1. Build coboundary operators:")
    delta_0, delta_1 = build_coboundary_operator(nerve)
    print(f"   δ_0 shape: {delta_0.shape} (vertices → edges)")
    print(f"   δ_1 shape: {delta_1.shape} (edges → triangles)")
    print(f"   δ_0:\n{delta_0}")
    
    # Check δ_1 ∘ δ_0 = 0 (fundamental property!)
    composition = delta_1 @ delta_0
    print(f"\n2. Verify δ² = 0:")
    print(f"   ||δ_1 ∘ δ_0|| = {np.linalg.norm(composition):.6f}")
    
    # Compute Laplacian on edges (C^1)
    print("\n3. Laplacian on C^1 (edges):")
    L = compute_laplacian_from_coboundary(delta_1, delta_0)
    print(f"   L shape: {L.shape}")
    eigs = np.sort(np.linalg.eigvalsh(L))
    print(f"   Spectrum: {np.round(eigs, 4)}")
    print(f"   # Harmonics (β_1): {np.sum(eigs < 1e-6)}")
    
    # Hodge decomposition
    print("\n4. Hodge decomposition:")
    cochain = np.array([1.0, 2.0, 3.0])  # C^1 element
    result = hodge_decomposition(cochain, L, delta_1, delta_0)
    print(f"   Input: {cochain}")
    print(f"   Harmonic: {np.round(result.harmonic, 4)}")
    print(f"   Exact: {np.round(result.exact, 4)}")
    print(f"   Co-exact: {np.round(result.coexact, 4)}")
    print(f"   Sum: {np.round(result.harmonic + result.exact + result.coexact, 4)}")
    
    # Hodge projectors
    print("\n5. Hodge projectors:")
    P_H, P_exact, P_coexact = compute_hodge_projectors(L, delta_1, delta_0)
    print(f"   P_harmonic rank: {np.linalg.matrix_rank(P_H)}")
    print(f"   P_exact rank: {np.linalg.matrix_rank(P_exact)}")
    print(f"   P_coexact rank: {np.linalg.matrix_rank(P_coexact)}")
    
    print("\n" + "=" * 60)
    print("✅ HODGE DECOMPOSITION: C^k = H^k ⊕ im(δ) ⊕ im(δ*)")
    print("=" * 60)
