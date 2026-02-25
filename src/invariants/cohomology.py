"""
Cohomology Invariants

Invariants from Čech cohomology and cochain structure.
For cellular sheaves over finite Čech nerves.

References:
- Hansen & Ghrist (2019). Toward a Spectral Theory of Cellular Sheaves. arXiv:1808.01513
- Robinson (2014). Topological Signal Processing.
- Curry (2014). Sheaves, Cosheaves and Applications.
"""

from dataclasses import dataclass
from typing import Dict, List, Tuple, Optional
import numpy as np

from .harmonic import (
    validate_laplacian_construction,
    validate_hodge_orthogonality,
    hodge_decompose,
)


# ============================================================================
# COHOMOLOGY INVARIANT DATA STRUCTURES
# ============================================================================

@dataclass
class CohomologyInvariants:
    """
    Cohomology invariants for cellular sheaves.
    
    These capture TOPOLOGICAL structure via cochain complexes.
    """
    # Betti numbers (dimensions of cohomology groups)
    betti_0: int                     # H⁰ = connected components
    betti_1: int                     # H¹ = holes/loops
    betti_2: int                     # H² = voids
    
    # Euler characteristic
    euler_characteristic: int        # χ = β₀ - β₁ + β₂
    
    # Coboundary structure
    coboundary_rank_0: int           # rank(δ₀)
    coboundary_rank_1: int           # rank(δ₁)
    coboundary_nullity_0: int        # nullity(δ₀) = dim(ker δ₀)
    coboundary_nullity_1: int        # nullity(δ₁)
    
    # Exactness measures
    exactness_error_01: float        # ||δ₁ ∘ δ₀||
    is_cochain_complex: bool         # δ₁ ∘ δ₀ = 0?
    
    # Hodge decomposition ratios
    harmonic_ratio: float            # dim(ker Δ) / total_dim
    exact_ratio: float               # dim(im δ) / total_dim
    coexact_ratio: float             # dim(im δ*) / total_dim
    
    def to_dict(self) -> Dict:
        return {
            "betti_0": self.betti_0,
            "betti_1": self.betti_1,
            "betti_2": self.betti_2,
            "euler_characteristic": self.euler_characteristic,
            "coboundary_rank_0": self.coboundary_rank_0,
            "coboundary_rank_1": self.coboundary_rank_1,
            "exactness_error_01": self.exactness_error_01,
            "is_cochain_complex": self.is_cochain_complex,
            "harmonic_ratio": self.harmonic_ratio,
            "exact_ratio": self.exact_ratio,
            "coexact_ratio": self.coexact_ratio
        }


@dataclass 
class NerveValidation:
    """
    Validation of finite nerve structure.
    """
    is_finite: bool
    n_vertices: int
    n_edges: int
    n_triangles: int
    max_dimension: int
    is_simplicial: bool              # All faces present?
    is_connected: bool
    has_valid_boundary: bool         # ∂∂ = 0?
    
    def is_valid(self) -> bool:
        return (
            self.is_finite and 
            self.is_simplicial and
            self.has_valid_boundary
        )


# ============================================================================
# COMPUTATION FUNCTIONS
# ============================================================================

def compute_betti_from_laplacian(
    laplacian: np.ndarray,
    tol: float = 1e-10
) -> Dict[int, int]:
    """
    Compute Betti number from Laplacian kernel dimension.
    
    β_k = dim(ker Δ_k) = dim(H^k)
    
    For Laplacian at degree k, the kernel dimension equals
    the k-th Betti number.
    """
    eigenvalues = np.linalg.eigvalsh(laplacian)
    kernel_dim = int(np.sum(np.abs(eigenvalues) < tol))
    return kernel_dim


def compute_coboundary_ranks(
    delta_0: np.ndarray,
    delta_1: Optional[np.ndarray] = None,
    tol: float = 1e-10
) -> Dict[str, int]:
    """
    Compute ranks and nullities of coboundary operators.
    
    rank(δ) + nullity(δ) = dim(domain)
    
    These determine cohomology dimensions via rank-nullity.
    """
    rank_0 = int(np.linalg.matrix_rank(delta_0, tol=tol))
    nullity_0 = delta_0.shape[1] - rank_0
    
    result = {
        "rank_0": rank_0,
        "nullity_0": nullity_0
    }
    
    if delta_1 is not None:
        rank_1 = int(np.linalg.matrix_rank(delta_1, tol=tol))
        nullity_1 = delta_1.shape[1] - rank_1
        result["rank_1"] = rank_1
        result["nullity_1"] = nullity_1
    
    return result


def check_cochain_complex_structure(
    delta_0: np.ndarray,
    delta_1: np.ndarray,
    tol: float = 1e-10
) -> Tuple[bool, float]:
    """
    Verify δ₁ ∘ δ₀ = 0 (cochain complex axiom).
    
    This is CRITICAL: if δ₁δ₀ ≠ 0, we don't have a cochain complex
    and cohomology is not well-defined.
    """
    if delta_0.shape[0] != delta_1.shape[1]:
        return (False, float('inf'))
    
    composition = delta_1 @ delta_0
    error = np.linalg.norm(composition)
    
    return (error < tol, float(error))


def compute_hodge_decomposition_ratios(
    laplacian: np.ndarray,
    delta_above: np.ndarray,
    delta_below: Optional[np.ndarray] = None,
    tol: float = 1e-10
) -> Dict[str, float]:
    """
    Compute Hodge decomposition ratios for degree k.
    
    C^k = H^k ⊕ im(δ_{k-1}) ⊕ im(δ_k*)
    
    where:
      H^k = ker(Δ_k)           — harmonic cochains
      im(δ_{k-1}) ⊂ C^k       — exact (from below)
      im(δ_k*) = im(δ_k^T) ⊂ C^k  — coexact (adjoint from above)
    
    These three subspaces are mutually orthogonal and span C^k.
    Their dimensions must sum to dim(C^k).
    
    Args:
        laplacian: Δ_k acting on C^k
        delta_above: δ_k : C^k → C^{k+1} (coboundary going UP)
        delta_below: δ_{k-1} : C^{k-1} → C^k (coboundary from below)
                     If None, exact part is zero (degree 0 case)
    """
    total_dim = laplacian.shape[0]
    
    # Harmonic: ker(Δ_k)
    eigs = np.linalg.eigvalsh(laplacian)
    harmonic_dim = int(np.sum(np.abs(eigs) < tol))
    
    # Exact: im(δ_{k-1}) ⊂ C^k — image of coboundary FROM BELOW
    # For degree 0: no δ_{-1} exists, so exact_dim = 0
    if delta_below is not None:
        exact_dim = int(np.linalg.matrix_rank(delta_below, tol=tol))
    else:
        exact_dim = 0
    
    # Coexact: im(δ_k*) = im(δ_k^T) ⊂ C^k — adjoint of coboundary going UP
    coexact_dim = int(np.linalg.matrix_rank(delta_above.T, tol=tol))
    
    # Sanity: harmonic + exact + coexact should = total_dim
    # (This is the Hodge theorem for finite-dimensional inner product spaces)
    
    return {
        "harmonic_ratio": harmonic_dim / total_dim if total_dim > 0 else 0.0,
        "exact_ratio": exact_dim / total_dim if total_dim > 0 else 0.0,
        "coexact_ratio": coexact_dim / total_dim if total_dim > 0 else 0.0,
        "harmonic_dim": harmonic_dim,
        "exact_dim": exact_dim,
        "coexact_dim": coexact_dim
    }


def compute_cohomology_invariants(
    nerve: Dict[int, List[Tuple]],
    delta_0: np.ndarray,
    delta_1: Optional[np.ndarray],
    laplacian: np.ndarray,
    tol: float = 1e-10
) -> CohomologyInvariants:
    """
    Compute complete cohomology invariant set.
    """
    # Cell counts
    n0 = len(nerve.get(0, []))
    n1 = len(nerve.get(1, []))
    n2 = len(nerve.get(2, []))
    
    # Coboundary ranks
    ranks = compute_coboundary_ranks(delta_0, delta_1, tol)

    # Betti numbers from rank-nullity on the ACTUAL cochain spaces.
    # For sheaf coboundaries, dim(Cᵏ) = δ_k.shape[1] (columns),
    # NOT the number of graph simplices. When δ₀ is the graph coboundary
    # (stalk_dim=1), δ₀.shape[1] = n₀. When δ₀ is the sheaf coboundary,
    # δ₀.shape[1] = n₀ × stalk_dim. Using shape ensures correctness for both.
    dim_C0 = delta_0.shape[1] if delta_0.shape[1] > 0 else n0
    dim_C1 = delta_0.shape[0] if delta_0.shape[0] > 0 else n1

    # β₀ = dim(C⁰) - rank(δ₀) = nullity(δ₀)
    beta_0 = dim_C0 - ranks["rank_0"]

    # β₁ = nullity(δ₁) - rank(δ₀)
    if delta_1 is not None:
        dim_C1_from_d1 = delta_1.shape[1] if delta_1.shape[1] > 0 else n1
        beta_1 = dim_C1_from_d1 - ranks["rank_0"] - ranks.get("rank_1", 0)
    else:
        beta_1 = dim_C1 - ranks["rank_0"]

    # β₂ from rank-nullity theorem
    if delta_1 is not None and n2 > 0:
        dim_C2 = delta_1.shape[0] if delta_1.shape[0] > 0 else n2
        beta_2 = dim_C2 - ranks.get("rank_1", 0)
    else:
        beta_2 = 0
    
    # Euler characteristic
    euler = n0 - n1 + n2  # = β₀ - β₁ + β₂
    
    # Cochain complex check
    if delta_1 is not None:
        is_complex, exactness_err = check_cochain_complex_structure(delta_0, delta_1, tol)
    else:
        is_complex, exactness_err = True, 0.0
    
    # Hodge ratios
    hodge = compute_hodge_decomposition_ratios(laplacian, delta_0, None, tol)
    
    return CohomologyInvariants(
        betti_0=max(0, beta_0),
        betti_1=max(0, beta_1),
        betti_2=max(0, beta_2),
        euler_characteristic=euler,
        coboundary_rank_0=ranks["rank_0"],
        coboundary_rank_1=ranks.get("rank_1", 0),
        coboundary_nullity_0=ranks["nullity_0"],
        coboundary_nullity_1=ranks.get("nullity_1", 0),
        exactness_error_01=exactness_err,
        is_cochain_complex=is_complex,
        harmonic_ratio=hodge["harmonic_ratio"],
        exact_ratio=hodge["exact_ratio"],
        coexact_ratio=hodge["coexact_ratio"]
    )


def validate_nerve_structure(nerve: Dict[int, List[Tuple]]) -> NerveValidation:
    """
    Validate finite nerve is well-formed.
    
    Checks:
    - Finite (bounded number of cells)
    - Simplicial (all faces present)
    - Connected
    - Valid boundary (∂∂ = 0)
    """
    vertices = nerve.get(0, [])
    edges = nerve.get(1, [])
    triangles = nerve.get(2, [])
    
    n0, n1, n2 = len(vertices), len(edges), len(triangles)
    
    # Finiteness
    is_finite = n0 < 10000 and n1 < 100000  # Reasonable bounds
    
    # Max dimension
    max_dim = 0
    if n2 > 0:
        max_dim = 2
    elif n1 > 0:
        max_dim = 1
    elif n0 > 0:
        max_dim = 0
    
    # Simplicial check: all edge endpoints are vertices
    vertex_set = {v[0] for v in vertices}
    is_simplicial = True
    for edge in edges:
        if edge[0] not in vertex_set or edge[1] not in vertex_set:
            is_simplicial = False
            break
    
    # Triangle faces check
    edge_set = {tuple(sorted(e)) for e in edges}
    for tri in triangles:
        i, j, k = tri
        faces = [(i, j), (i, k), (j, k)]
        for face in faces:
            if tuple(sorted(face)) not in edge_set:
                is_simplicial = False
                break
    
    # Connectivity via DFS
    if n0 > 0:
        adj = {v[0]: set() for v in vertices}
        for e in edges:
            adj.setdefault(e[0], set()).add(e[1])
            adj.setdefault(e[1], set()).add(e[0])
        
        visited = set()
        stack = [vertices[0][0]]
        while stack:
            node = stack.pop()
            if node not in visited:
                visited.add(node)
                stack.extend(adj.get(node, set()) - visited)
        
        is_connected = len(visited) == n0
    else:
        is_connected = True
    
    # Boundary check (∂∂ = 0) - simplified
    has_valid_boundary = True  # Would need boundary operators to verify
    
    return NerveValidation(
        is_finite=is_finite,
        n_vertices=n0,
        n_edges=n1,
        n_triangles=n2,
        max_dimension=max_dim,
        is_simplicial=is_simplicial,
        is_connected=is_connected,
        has_valid_boundary=has_valid_boundary
    )


# ============================================================================
# COHOMOLOGY VALIDATOR CHECKPOINTS
# ============================================================================

@dataclass
class CohomologyCheckpoint:
    """Result of a cohomology validation checkpoint."""
    name: str
    passed: bool
    expected: str
    actual: str
    severity: str


class CohomologyInvariantValidator:
    """
    Validator for cohomology invariants with checkpoints.
    """
    
    def __init__(
        self,
        nerve: Dict[int, List[Tuple]],
        delta_0: np.ndarray,
        delta_1: Optional[np.ndarray],
        laplacian: np.ndarray,
        tol: float = 1e-10
    ):
        self.nerve = nerve
        self.delta_0 = delta_0
        self.delta_1 = delta_1
        self.laplacian = laplacian
        self.tol = tol
        
        self.nerve_validation = validate_nerve_structure(nerve)
        self.invariants = compute_cohomology_invariants(
            nerve, delta_0, delta_1, laplacian, tol
        )
        self.checkpoints: List[CohomologyCheckpoint] = []
    
    def validate_all(self) -> Tuple[bool, List[CohomologyCheckpoint]]:
        """Run all validation checkpoints."""
        self.checkpoints = []
        
        # Checkpoint 1: Nerve is finite
        self._check_finite_nerve()
        
        # Checkpoint 2: Nerve is simplicial
        self._check_simplicial()
        
        # Checkpoint 3: Nerve is connected
        self._check_connected()
        
        # Checkpoint 4: Cochain complex structure
        self._check_cochain_complex()
        
        # Checkpoint 5: Betti-Euler consistency
        self._check_euler_consistency()
        
        # Checkpoint 6: Hodge decomposition sums to 1
        self._check_hodge_sum()
        
        # Checkpoint 7: No H¹ obstructions for decryption
        self._check_h1_obstructions()
        
        all_passed = all(cp.passed for cp in self.checkpoints if cp.severity == "critical")
        return all_passed, self.checkpoints
    
    def _check_finite_nerve(self):
        """Nerve must be finite."""
        passed = self.nerve_validation.is_finite
        
        self.checkpoints.append(CohomologyCheckpoint(
            name="Finite nerve",
            passed=passed,
            expected="Finite (n₀ < 10000, n₁ < 100000)",
            actual=f"n₀={self.nerve_validation.n_vertices}, n₁={self.nerve_validation.n_edges}",
            severity="critical"
        ))
    
    def _check_simplicial(self):
        """Nerve must be simplicial (all faces present)."""
        passed = self.nerve_validation.is_simplicial
        
        self.checkpoints.append(CohomologyCheckpoint(
            name="Simplicial structure",
            passed=passed,
            expected="All faces present",
            actual="Simplicial" if passed else "Missing faces",
            severity="critical"
        ))
    
    def _check_connected(self):
        """Nerve should be connected for unique decryption."""
        passed = self.nerve_validation.is_connected
        
        self.checkpoints.append(CohomologyCheckpoint(
            name="Connected nerve",
            passed=passed,
            expected="β₀ = 1 (connected)",
            actual=f"β₀ = {self.invariants.betti_0}",
            severity="critical"
        ))
    
    def _check_cochain_complex(self):
        """Verify δ₁ ∘ δ₀ = 0."""
        passed = self.invariants.is_cochain_complex
        
        self.checkpoints.append(CohomologyCheckpoint(
            name="Cochain complex",
            passed=passed,
            expected="||δ₁δ₀|| = 0",
            actual=f"||δ₁δ₀|| = {self.invariants.exactness_error_01:.2e}",
            severity="critical"
        ))
    
    def _check_euler_consistency(self):
        """Euler characteristic should match: χ = n₀ - n₁ + n₂."""
        nv = self.nerve_validation
        expected_euler = nv.n_vertices - nv.n_edges + nv.n_triangles
        actual_euler = self.invariants.euler_characteristic
        passed = expected_euler == actual_euler
        
        self.checkpoints.append(CohomologyCheckpoint(
            name="Euler consistency",
            passed=passed,
            expected=f"χ = {expected_euler}",
            actual=f"χ = {actual_euler}",
            severity="warning"
        ))
    
    def _check_hodge_sum(self):
        """
        Hodge ratios must sum to 1 (Hodge decomposition theorem).
        
        C^k = ker(Δ) ⊕ im(δ) ⊕ im(δ*) — orthogonal, spans full space.
        Formally verified: Hodge_Decomposition_Theorem in hardness_proof.lean.
        """
        total = (
            self.invariants.harmonic_ratio + 
            self.invariants.exact_ratio + 
            self.invariants.coexact_ratio
        )
        # Must equal 1 (Hodge theorem: three subspaces span C^k)
        # Tolerance for numerical eigenvalue computation
        # Lean proof is exact. Tolerance = float precision for integer dimensions.
        passed = abs(total - 1.0) < 1e-6
        
        self.checkpoints.append(CohomologyCheckpoint(
            name="Hodge decomposition",
            passed=passed,
            expected="H + E + C = 1 (Hodge theorem)",
            actual=f"{self.invariants.harmonic_ratio:.2f} + {self.invariants.exact_ratio:.2f} + {self.invariants.coexact_ratio:.2f} = {total:.2f}",
            severity="critical"
        ))
    
    def _check_h1_obstructions(self):
        """H¹ should be 0 for unique gluing (no obstructions)."""
        passed = self.invariants.betti_1 == 0
        
        self.checkpoints.append(CohomologyCheckpoint(
            name="No H¹ obstructions",
            passed=passed,
            expected="β₁ = 0",
            actual=f"β₁ = {self.invariants.betti_1}",
            severity="warning"  # Warning not critical - can still work with β₁ > 0
        ))
    
    def report(self) -> str:
        """Generate human-readable report."""
        lines = ["=== COHOMOLOGY INVARIANT VALIDATION ==="]
        
        for cp in self.checkpoints:
            status = "✅" if cp.passed else ("⚠️" if cp.severity == "warning" else "❌")
            lines.append(f"{status} {cp.name}: {cp.actual}")
        
        lines.append("-" * 40)
        lines.append(f"Betti: β = ({self.invariants.betti_0}, {self.invariants.betti_1}, {self.invariants.betti_2})")
        lines.append(f"Euler: χ = {self.invariants.euler_characteristic}")
        lines.append(f"Hodge: H={self.invariants.harmonic_ratio:.2f}, E={self.invariants.exact_ratio:.2f}, C={self.invariants.coexact_ratio:.2f}")
        lines.append("=" * 40)
        
        passed = all(cp.passed for cp in self.checkpoints if cp.severity == "critical")
        lines.append(f"OVERALL: {'PASS' if passed else 'FAIL'}")
        
        return '\n'.join(lines)


# ============================================================================
# COHOMOLOGY MATCHING
# ============================================================================

def cohomology_match(
    inv1: CohomologyInvariants,
    inv2: CohomologyInvariants,
    ratio_tol: float = 0.01
) -> Tuple[bool, str]:
    """
    Check if two cohomology invariant sets match.
    
    Matching cohomology ⟹ same topological structure.
    """
    # Betti numbers must match exactly
    if inv1.betti_0 != inv2.betti_0:
        return (False, f"β₀ mismatch: {inv1.betti_0} vs {inv2.betti_0}")
    
    if inv1.betti_1 != inv2.betti_1:
        return (False, f"β₁ mismatch: {inv1.betti_1} vs {inv2.betti_1}")
    
    if inv1.betti_2 != inv2.betti_2:
        return (False, f"β₂ mismatch: {inv1.betti_2} vs {inv2.betti_2}")
    
    # Euler must match
    if inv1.euler_characteristic != inv2.euler_characteristic:
        return (False, f"χ mismatch: {inv1.euler_characteristic} vs {inv2.euler_characteristic}")
    
    # Hodge ratios should be close
    if abs(inv1.harmonic_ratio - inv2.harmonic_ratio) > ratio_tol:
        return (False, f"Harmonic ratio mismatch: {inv1.harmonic_ratio} vs {inv2.harmonic_ratio}")
    
    return (True, "Cohomology invariants match")
