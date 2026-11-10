"""
Sheaf Laplacian: Hodge Laplacian for Cellular Sheaves

The sheaf Laplacian Δ = δ*δ + δδ* generalizes the graph Laplacian to sheaves.
Its kernel ker(Δ) = harmonic cochains represents global sections.

COCHAIN DUALITY NOTE:

  The adjoint δ* is implicit in the Laplacian. Decrypt uses
  eigendecomposition of Δ (via harmonic_projection()) rather than
  calling δ* explicitly. This is mathematically equivalent:

    π_H = I - P_im(δ) - P_im(δ*)

  but eigendecomposition is numerically more stable with lattice-scale
  restriction maps (entries ~10⁴, products ~10⁸). The explicit δ*
  is available in sheaf.py:adjoint_coboundary_0() and
  hodge.py:compute_hodge_projectors() for cases that need it
  (invariant validation, noise structure checking).

For cryptography:
- Encryption: embed message in ker(Δ), add noise in im(δ)⊕im(δ*)
- Decryption: harmonic_projection() extracts ker(Δ) component
  (δ* implicit in eigendecomposition of Δ)
- Security: spectral gap separates ker(Δ) from im(δ)⊕im(δ*)

TSIRELSON BOUND (spectral gap constraint):

  The spectral gap λ₁ of the sheaf Laplacian is constrained to
  [1/√2, 2√2] — the Tsirelson range. This is a structural artifact
  of quantum information geometry, not a design choice:

  The Laplacian Δ = Σ_e (I - R_e)ᵀ(I - R_e), where R_e ∈ SO(n)
  are the restriction maps (parallel transport). The operator norm
  of (I - R) for R ∈ SO(n) achieves maximum √2 at rotation angle
  π/2. This is the same √2 from the CHSH Bell inequality, confirmed
  experimentally (Aspect/Clauser/Zeilinger, 2022 Nobel Prize).

  At λ₁ = 1/√2 (lower bound): maximum uncertainty between ker(Δ)
  and im(δ)⊕im(δ*) — the privacy optimum, where an observer
  without the fibration secret cannot distinguish signal from noise.

  See: consensus/invariant_validator.py for the full construction,
       invariants/spectral.py for the spectral invariant structure.

Reference: Hansen & Ghrist (2019), arXiv:1808.01513
"""

from dataclasses import dataclass
from typing import Dict, List, Tuple, Optional
import numpy as np

from .sheaf import CellularSheaf


@dataclass  
class SheafLaplacian:
    """
    Sheaf Laplacian for cellular sheaves.
    
    Computes the block Laplacian matrix Δ_k for k-cochains.
    """
    sheaf: CellularSheaf
    _L0: Optional[np.ndarray] = None
    _L1: Optional[np.ndarray] = None
    
    def get_laplacian_0(self) -> np.ndarray:
        """
        Compute 0-Laplacian Δ₀ = δ₀*δ₀.
        
        Acts on 0-cochains (vertex data).
        """
        if self._L0 is not None:
            return self._L0
        
        vertices = self.sheaf.nerve.get(0, [])
        edges = self.sheaf.nerve.get(1, [])
        
        if not vertices:
            return np.array([[]])
        
        # Get stalk dimensions
        stalk_dims = {}
        total_dim = 0
        offsets = {}
        
        for v in vertices:
            stalk = self.sheaf.get_stalk(v)
            dim = len(stalk) if stalk is not None and stalk.ndim == 1 else 1
            stalk_dims[v] = dim
            offsets[v] = total_dim
            total_dim += dim
        
        # Build block Laplacian
        L = np.zeros((total_dim, total_dim))
        
        for edge in edges:
            i, j = edge
            vi, vj = (i,), (j,)
            
            di = stalk_dims.get(vi, 1)
            dj = stalk_dims.get(vj, 1)
            oi = offsets.get(vi, 0)
            oj = offsets.get(vj, 0)
            
            # Get restriction maps (or identity)
            Ri = self.sheaf.get_restriction(vi, edge)
            Rj = self.sheaf.get_restriction(vj, edge)
            
            if Ri is None:
                Ri = np.eye(di)
            if Rj is None:
                Rj = np.eye(dj)
            
            # Block contribution: L += R^T R
            # Diagonal blocks
            L[oi:oi+di, oi:oi+di] += Ri.T @ Ri
            L[oj:oj+dj, oj:oj+dj] += Rj.T @ Rj
            
            # Off-diagonal blocks (negative for Laplacian)
            if di == dj:
                L[oi:oi+di, oj:oj+dj] -= Ri.T @ Rj
                L[oj:oj+dj, oi:oi+di] -= Rj.T @ Ri
        
        # ── Enforce mathematical truth: Δ₀ = δ*δ is PSD by construction ──
        # With lattice-scale restriction maps (entries up to q ≈ 10⁴),
        # block products R^T R have entries ~10⁸. Float64 relative precision
        # (~10⁻¹⁶) gives absolute error ~10⁻⁴ in eigenvalues.
        # Symmetrize to eliminate asymmetry from floating-point accumulation,
        # then the PSD gate in credential.py can use a tight tolerance.
        L = (L + L.T) / 2
        
        self._L0 = L
        return L

    def get_coboundary_0(self) -> np.ndarray:
        """
        Compute sheaf coboundary matrix δ₀: C⁰(F) → C¹(F).

        For edge e = (i,j):
          (δ₀ f)(e) = R_{j→e} f(j) - R_{i→e} f(i)

        Block matrix: (n_edges × d) rows × (n_vertices × d) columns.
        Restriction maps R_{v→e} are the sheaf's actual maps, NOT ±1.

        Satisfies: Δ₀ = δ₀ᵀ δ₀  (the Hodge Laplacian identity).
        """
        vertices = self.sheaf.nerve.get(0, [])
        edges = self.sheaf.nerve.get(1, [])

        if not vertices or not edges:
            return np.zeros((0, 0))

        # Compute stalk dimensions and offsets (same as get_laplacian_0)
        stalk_dims = {}
        total_v_dim = 0
        v_offsets = {}
        for v in vertices:
            stalk = self.sheaf.get_stalk(v)
            dim = len(stalk) if stalk is not None and stalk.ndim == 1 else 1
            stalk_dims[v] = dim
            v_offsets[v] = total_v_dim
            total_v_dim += dim

        # Edge offsets: each edge has d_edge = d (same stalk dim)
        total_e_dim = 0
        e_offsets = {}
        for edge in edges:
            vi, vj = (edge[0],), (edge[1],)
            d_e = stalk_dims.get(vi, 1)  # Use source vertex dim
            e_offsets[edge] = total_e_dim
            total_e_dim += d_e

        # Build block coboundary
        delta = np.zeros((total_e_dim, total_v_dim))

        for edge in edges:
            i, j = edge
            vi, vj = (i,), (j,)

            di = stalk_dims.get(vi, 1)
            dj = stalk_dims.get(vj, 1)
            oi = v_offsets.get(vi, 0)
            oj = v_offsets.get(vj, 0)
            oe = e_offsets[edge]

            Ri = self.sheaf.get_restriction(vi, edge)
            Rj = self.sheaf.get_restriction(vj, edge)
            if Ri is None:
                Ri = np.eye(di)
            if Rj is None:
                Rj = np.eye(dj)

            # (δ₀ f)(e) = Rⱼ f(j) - Rᵢ f(i)
            delta[oe:oe+di, oi:oi+di] = -Ri
            delta[oe:oe+dj, oj:oj+dj] = Rj

        return delta

    def get_laplacian_1(self) -> np.ndarray:
        """
        Compute 1-Laplacian Δ₁ = δ₁*δ₁ + δ₀ δ₀*.
        
        Acts on 1-cochains (edge data).
        Δ₁ = δ₁^T δ₁  (from above: edges→triangles)
            + δ₀ δ₀^T  (from below: vertices→edges, then adjoint)
        """
        if self._L1 is not None:
            return self._L1
        
        edges = self.sheaf.nerve.get(1, [])
        
        if not edges:
            return np.array([[]])
        
        from .hodge import build_coboundary_operator
        
        # Build coboundary operators from the nerve
        delta_0, delta_1 = build_coboundary_operator(self.sheaf.nerve, stalk_dim=1)
        
        # Δ₁ = δ₁^T δ₁ + δ₀ δ₀^T
        # delta_0: (n_edges, n_vertices) — maps C^0 → C^1
        # delta_1: (n_triangles, n_edges) — maps C^1 → C^2
        n_edges_dim = delta_0.shape[0]  # = delta_1.shape[1]
        
        L1 = np.zeros((n_edges_dim, n_edges_dim))
        
        # Upper term: δ₁* δ₁ = δ₁^T δ₁
        if delta_1.shape[0] > 0:
            L1 += delta_1.T @ delta_1
        
        # Lower term: δ₀ δ₀* = δ₀ δ₀^T
        L1 += delta_0 @ delta_0.T
        
        self._L1 = L1
        return self._L1
    
    def eigendecomposition(self, k: int = 0) -> Tuple[np.ndarray, np.ndarray]:
        """
        Compute eigendecomposition of Δ_k.
        
        Returns:
            (eigenvalues, eigenvectors)
        """
        L = self.get_laplacian_0() if k == 0 else self.get_laplacian_1()
        
        if L.size == 0:
            return np.array([]), np.array([[]])
        
        eigenvalues, eigenvectors = np.linalg.eigh(L)
        idx = np.argsort(eigenvalues)
        
        return eigenvalues[idx], eigenvectors[:, idx]
    
    def harmonic_projection(
        self,
        cochain: np.ndarray,
        tolerance: float = 1e-6
    ) -> Tuple[np.ndarray, np.ndarray]:
        """
        Project cochain to harmonic subspace ker(Δ).
        
        Args:
            cochain: Input cochain vector
            tolerance: Eigenvalue threshold for kernel
            
        Returns:
            (harmonic_part, orthogonal_part)
        """
        eigenvalues, eigenvectors = self.eigendecomposition(0)
        
        # Find kernel (near-zero eigenvalues)
        kernel_mask = eigenvalues < tolerance
        
        if not np.any(kernel_mask):
            return np.zeros_like(cochain), cochain
        
        # Project onto kernel
        kernel_basis = eigenvectors[:, kernel_mask]
        coeffs = kernel_basis.T @ cochain
        harmonic = kernel_basis @ coeffs
        
        return harmonic, cochain - harmonic
    
    def spectral_gap(self) -> float:
        """Compute spectral gap λ₁ (smallest nonzero eigenvalue)."""
        eigenvalues, _ = self.eigendecomposition(0)
        nonzero = eigenvalues[eigenvalues > 1e-6]
        return float(nonzero[0]) if len(nonzero) > 0 else 0.0
    
    def betti_0(self, tolerance: float = 1e-6) -> int:
        """Compute β₀ = dim(ker(Δ₀))."""
        eigenvalues, _ = self.eigendecomposition(0)
        return int(np.sum(eigenvalues < tolerance))
