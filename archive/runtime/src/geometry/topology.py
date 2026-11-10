"""
Topology: Simplicial complexes, Betti numbers, persistence.

Based on Hansen & Ghrist and standard TDA.
"""

from dataclasses import dataclass
from typing import Dict, List, Tuple
from abc import ABC, abstractmethod
import numpy as np


@dataclass
class PersistenceDiagram:
    """Persistence diagram: (birth, death) pairs."""
    dimension: int
    points: np.ndarray  # Shape (n, 2)
    
    def persistence_entropy(self) -> float:
        if len(self.points) == 0:
            return 0.0
        persistence = self.points[:, 1] - self.points[:, 0]
        persistence = persistence[np.isfinite(persistence)]
        if len(persistence) == 0 or np.sum(persistence) == 0:
            return 0.0
        p = persistence / np.sum(persistence)
        return float(-np.sum(p * np.log(p + 1e-10)))


class SimplicialComplex(ABC):
    """Abstract simplicial complex interface."""
    
    @abstractmethod
    def get_cells(self, dimension: int) -> List[Tuple]:
        pass
    
    @abstractmethod
    def n_cells(self, dimension: int) -> int:
        pass
    
    def compute_betti_numbers(self) -> Dict[int, int]:
        """Compute Betti numbers β_k."""
        vertices = self.get_cells(0)
        edges = self.get_cells(1)
        triangles = self.get_cells(2)
        
        n0, n1, n2 = len(vertices), len(edges), len(triangles)
        beta_0 = self._count_components()
        beta_2 = max(0, n2 - n1 + n0 - beta_0)
        beta_1 = n1 - n0 + beta_0 - beta_2
        
        return {0: beta_0, 1: max(0, beta_1), 2: max(0, beta_2)}
    
    def _count_components(self) -> int:
        """Count connected components via DFS."""
        vertices = self.get_cells(0)
        edges = self.get_cells(1)
        if not vertices:
            return 0
        
        adjacency = {v[0]: set() for v in vertices}
        for edge in edges:
            i, j = edge
            adjacency.setdefault(i, set()).add(j)
            adjacency.setdefault(j, set()).add(i)
        
        visited = set()
        components = 0
        
        def dfs(node):
            visited.add(node)
            for neighbor in adjacency.get(node, []):
                if neighbor not in visited:
                    dfs(neighbor)
        
        for v in adjacency:
            if v not in visited:
                dfs(v)
                components += 1
        
        return components


class CechComplex(SimplicialComplex):
    """Čech complex from nerve dict."""
    
    def __init__(self, nerve: Dict[int, List[Tuple]]):
        self.nerve = nerve
    
    def get_cells(self, dimension: int) -> List[Tuple]:
        return self.nerve.get(dimension, [])
    
    def n_cells(self, dimension: int) -> int:
        return len(self.get_cells(dimension))


def compute_betti_numbers(complex: SimplicialComplex) -> Dict[int, int]:
    """Compute Betti numbers for any complex."""
    return complex.compute_betti_numbers()


# ============================================================================
# ČECH NERVE EMBEDDING (Topology Obfuscation)
# ============================================================================

@dataclass
class NerveEmbedding:
    """
    Embedding of a real Čech nerve into a larger decoy nerve.
    
    For panopticon resilience: hide real topology in noise.
    """
    real_nerve: Dict[int, List[Tuple]]       # Original topology
    decoy_nerve: Dict[int, List[Tuple]]      # Obfuscated topology
    real_vertex_map: Dict[int, int]          # real_idx → decoy_idx
    decoy_vertices: List[int]                # indices of decoy vertices
    
    def is_real_edge(self, edge: Tuple[int, int]) -> bool:
        """Check if an edge in decoy_nerve corresponds to real edge."""
        real_edges = {tuple(sorted(e)) for e in self.real_nerve.get(1, [])}
        inv_map = {v: k for k, v in self.real_vertex_map.items()}
        
        if edge[0] not in inv_map or edge[1] not in inv_map:
            return False
        
        real_edge = tuple(sorted([inv_map[edge[0]], inv_map[edge[1]]]))
        return real_edge in real_edges


def embed_nerve_in_decoys(
    real_nerve: Dict[int, List[Tuple]],
    n_decoys: int = 10,
    decoy_edge_density: float = 0.3
) -> NerveEmbedding:
    """
    Embed real Čech nerve in larger decoy topology.
    
    This is key for panopticon resilience:
    - Real 2-party topology hidden among many decoy vertices
    - All edges look identical (can't distinguish real from decoy)
    - Decoy traffic fills decoy edges
    
    Args:
        real_nerve: The actual communication topology
        n_decoys: Number of decoy vertices to add
        decoy_edge_density: Probability of edge between any pair
        
    Returns:
        NerveEmbedding with real nerve hidden in decoy topology
    """
    n_real = len(real_nerve.get(0, []))
    n_total = n_real + n_decoys
    
    # Map real vertices to random positions in larger space
    import random
    all_positions = list(range(n_total))
    random.shuffle(all_positions)
    
    real_positions = all_positions[:n_real]
    decoy_positions = all_positions[n_real:]
    
    # Create mapping: real vertex index → position in decoy nerve
    real_vertex_map = {i: real_positions[i] for i in range(n_real)}
    
    # Build decoy nerve
    decoy_nerve: Dict[int, List[Tuple]] = {0: [], 1: [], 2: []}
    
    # 0-cells: all vertices
    decoy_nerve[0] = [(i,) for i in range(n_total)]
    
    # 1-cells: include real edges (mapped) + random decoy edges
    edge_set = set()
    
    # Add real edges (mapped to new indices)
    for edge in real_nerve.get(1, []):
        i, j = edge
        new_edge = tuple(sorted([real_vertex_map[i], real_vertex_map[j]]))
        edge_set.add(new_edge)
    
    # Add random decoy edges
    for i in range(n_total):
        for j in range(i + 1, n_total):
            if (i, j) not in edge_set:
                if random.random() < decoy_edge_density:
                    edge_set.add((i, j))
    
    decoy_nerve[1] = list(edge_set)
    
    # 2-cells: triangles where all 3 edges exist
    for i in range(n_total):
        for j in range(i + 1, n_total):
            for k in range(j + 1, n_total):
                e1 = (i, j) in edge_set or (j, i) in edge_set
                e2 = (i, k) in edge_set or (k, i) in edge_set
                e3 = (j, k) in edge_set or (k, j) in edge_set
                if e1 and e2 and e3:
                    decoy_nerve[2].append((i, j, k))
    
    return NerveEmbedding(
        real_nerve=real_nerve,
        decoy_nerve=decoy_nerve,
        real_vertex_map=real_vertex_map,
        decoy_vertices=decoy_positions
    )


def extract_real_nerve(embedding: NerveEmbedding) -> Dict[int, List[Tuple]]:
    """Extract original nerve from embedding (requires secret mapping)."""
    inv_map = {v: k for k, v in embedding.real_vertex_map.items()}
    
    real_nerve: Dict[int, List[Tuple]] = {0: [], 1: [], 2: []}
    
    # Extract real vertices
    for decoy_idx in embedding.real_vertex_map.values():
        real_idx = inv_map[decoy_idx]
        real_nerve[0].append((real_idx,))
    
    # Extract real edges
    for edge in embedding.decoy_nerve.get(1, []):
        if embedding.is_real_edge(edge):
            i, j = edge
            real_edge = tuple(sorted([inv_map[i], inv_map[j]]))
            real_nerve[1].append(real_edge)
    
    return real_nerve


# ============================================================================
# TOPOLOGICAL INVARIANTS (Tightening)
# ============================================================================

@dataclass
class TopologicalInvariants:
    """Complete topological invariant set for security verification."""
    betti_numbers: Dict[int, int]
    euler_characteristic: int
    n_vertices: int
    n_edges: int
    n_triangles: int
    is_connected: bool
    persistence_entropy: float
    
    def matches(self, other: 'TopologicalInvariants', tol: float = 1e-6) -> bool:
        """Check if two invariant sets match."""
        return (
            self.betti_numbers == other.betti_numbers and
            self.euler_characteristic == other.euler_characteristic and
            self.is_connected == other.is_connected and
            abs(self.persistence_entropy - other.persistence_entropy) < tol
        )


def compute_topological_invariants(nerve: Dict[int, List[Tuple]]) -> TopologicalInvariants:
    """Compute full topological invariant set."""
    complex = CechComplex(nerve)
    betti = complex.compute_betti_numbers()
    
    n0 = len(nerve.get(0, []))
    n1 = len(nerve.get(1, []))
    n2 = len(nerve.get(2, []))
    
    # Euler characteristic: χ = n₀ - n₁ + n₂
    euler = n0 - n1 + n2
    
    # Persistence entropy (simplified - from Betti)
    if sum(betti.values()) > 0:
        p = np.array(list(betti.values())) / sum(betti.values())
        entropy = float(-np.sum(p * np.log(p + 1e-10)))
    else:
        entropy = 0.0
    
    return TopologicalInvariants(
        betti_numbers=betti,
        euler_characteristic=euler,
        n_vertices=n0,
        n_edges=n1,
        n_triangles=n2,
        is_connected=(betti.get(0, 1) == 1),
        persistence_entropy=entropy
    )


def verify_complex_structure(
    delta_0: np.ndarray,
    delta_1: np.ndarray,
    tol: float = 1e-10
) -> Tuple[bool, str]:
    """
    Verify δ₁ ∘ δ₀ = 0 (cohomological complex structure).
    
    This is a fundamental invariant: the composition of two
    consecutive coboundary operators must be zero.
    """
    if delta_0.shape[0] != delta_1.shape[1]:
        return (False, f"Dimension mismatch: δ₀ is {delta_0.shape}, δ₁ is {delta_1.shape}")
    
    composition = delta_1 @ delta_0
    norm = np.linalg.norm(composition)
    
    if norm > tol:
        return (False, f"δ₁ ∘ δ₀ ≠ 0: ||δ₁δ₀|| = {norm:.6f}")
    
    return (True, "Cohomological structure verified: δ₁ ∘ δ₀ = 0")


def verify_betti_spectral_match(
    laplacian: np.ndarray,
    expected_betti_0: int,
    tol: float = 1e-6
) -> Tuple[bool, str]:
    """
    Verify dim(ker Δ) = β₀ (harmonic forms = topology).
    
    The number of zero eigenvalues of the Laplacian equals
    the 0th Betti number (connected components).
    """
    eigs = np.linalg.eigvalsh(laplacian)
    kernel_dim = int(np.sum(np.abs(eigs) < tol))
    
    if kernel_dim != expected_betti_0:
        return (False, f"Betti mismatch: dim(ker Δ) = {kernel_dim}, expected β₀ = {expected_betti_0}")
    
    return (True, f"Betti-spectral match verified: dim(ker Δ) = β₀ = {expected_betti_0}")


def verify_laplacian_symmetry(
    laplacian: np.ndarray,
    tol: float = 1e-10
) -> Tuple[bool, str]:
    """Verify Laplacian is symmetric (L = L^T)."""
    asymmetry = np.linalg.norm(laplacian - laplacian.T)
    
    if asymmetry > tol:
        return (False, f"Laplacian not symmetric: ||L - L^T|| = {asymmetry:.6f}")
    
    return (True, "Laplacian symmetry verified")


# ============================================================================
# GEOMETRIC INVARIANTS (From Bundle/Sheaf Structure)
# ============================================================================

def compute_holonomy_invariants(
    connection: Dict[Tuple[int, int], np.ndarray],
    nerve: Dict[int, List[Tuple]]
) -> Dict[str, float]:
    """
    Compute holonomy invariants from fiber bundle connection.
    
    Holonomy around loops detects curvature:
    - Flat connection: holonomy = identity for all loops
    - Curved: holonomy ≠ identity (measures non-commutativity)
    
    For security: bounded holonomy ensures geometric consistency.
    """
    triangles = nerve.get(2, [])
    
    if not triangles:
        return {"max_holonomy": 0.0, "mean_holonomy": 0.0, "is_flat": True}
    
    holonomies = []
    
    for tri in triangles:
        i, j, k = tri
        # Loop: i → j → k → i
        H = np.eye(connection.get((i, j), np.eye(1)).shape[0])
        
        for edge in [(i, j), (j, k), (k, i)]:
            if edge in connection:
                H = connection[edge] @ H
            elif (edge[1], edge[0]) in connection:
                # Reverse direction: use inverse (transpose for orthogonal)
                H = connection[(edge[1], edge[0])].T @ H
        
        # Holonomy deviation from identity
        deviation = np.linalg.norm(H - np.eye(H.shape[0]))
        holonomies.append(deviation)
    
    max_hol = float(max(holonomies)) if holonomies else 0.0
    mean_hol = float(np.mean(holonomies)) if holonomies else 0.0
    
    return {
        "max_holonomy": max_hol,
        "mean_holonomy": mean_hol,
        "is_flat": max_hol < 1e-6
    }


def verify_holonomy_bounds(
    connection: Dict[Tuple[int, int], np.ndarray],
    nerve: Dict[int, List[Tuple]],
    max_allowed: float = 0.1
) -> Tuple[bool, str]:
    """
    Verify holonomy is bounded (near-flat connection).
    
    Security: unbounded holonomy indicates geometric inconsistency.
    """
    invariants = compute_holonomy_invariants(connection, nerve)
    
    if invariants["max_holonomy"] > max_allowed:
        return (False, f"Holonomy too large: {invariants['max_holonomy']:.4f} > {max_allowed}")
    
    return (True, f"Holonomy bounded: max = {invariants['max_holonomy']:.6f}")


def compute_cheeger_constant(
    laplacian: np.ndarray,
    tol: float = 1e-6
) -> float:
    """
    Estimate Cheeger constant h from spectral gap.
    
    Cheeger inequality: λ₁/2 ≤ h ≤ √(2λ₁)
    
    This is an isoperimetric constant measuring how "bottlenecked"
    the graph is. Lower bound on Cheeger = harder to partition.
    """
    eigs = np.sort(np.linalg.eigvalsh(laplacian))
    nonzero = eigs[np.abs(eigs) > tol]
    
    if len(nonzero) == 0:
        return 0.0
    
    lambda_1 = float(nonzero[0])
    
    # Return lower bound: λ₁/2 (Cheeger inequality)
    return lambda_1 / 2


def verify_cheeger_bound(
    laplacian: np.ndarray,
    min_cheeger: float = 0.3
) -> Tuple[bool, str]:
    """
    Verify Cheeger constant is above threshold.
    
    Security: low Cheeger = easy to partition = weak connectivity.
    """
    h = compute_cheeger_constant(laplacian)
    
    if h < min_cheeger:
        return (False, f"Cheeger too low: h ≥ {h:.4f} < {min_cheeger} (weak connectivity)")
    
    return (True, f"Cheeger bound satisfied: h ≥ {h:.4f}")


def compute_spectral_trace_invariants(laplacian: np.ndarray) -> Dict[str, float]:
    """
    Compute trace invariants: tr(L), tr(L²), tr(L³).
    
    These are algebraic invariants that characterize the Laplacian:
    - tr(L) = sum of eigenvalues = 2 × (sum of edge weights)
    - tr(L²) = sum of λ²ᵢ = ||L||²_F
    - tr(L³) relates to triangles and clustering
    """
    L2 = laplacian @ laplacian
    L3 = L2 @ laplacian
    
    return {
        "trace_L": float(np.trace(laplacian)),
        "trace_L2": float(np.trace(L2)),
        "trace_L3": float(np.trace(L3)),
        "frobenius_norm": float(np.sqrt(np.trace(L2)))
    }


def verify_trace_invariants_match(
    L1: np.ndarray,
    L2: np.ndarray,
    rel_tol: float = 0.01
) -> Tuple[bool, str]:
    """
    Verify two Laplacians have matching trace invariants.
    
    If traces differ significantly, Laplacians are in different classes.
    """
    t1 = compute_spectral_trace_invariants(L1)
    t2 = compute_spectral_trace_invariants(L2)
    
    for key in ["trace_L", "trace_L2", "trace_L3"]:
        ref = max(abs(t1[key]), 1.0)
        diff = abs(t1[key] - t2[key]) / ref
        if diff > rel_tol:
            return (False, f"Trace mismatch on {key}: {t1[key]:.4f} vs {t2[key]:.4f}")
    
    return (True, "Trace invariants match")


def verify_restriction_map_coherence(
    restrictions: Dict[Tuple[Tuple, Tuple], np.ndarray],
    nerve: Dict[int, List[Tuple]],
    tol: float = 1e-6
) -> Tuple[bool, str]:
    """
    Verify restriction maps satisfy coherence (sheaf axiom).
    
    For face relations v ⊂ e ⊂ f:
    R_{v→f} = R_{e→f} ∘ R_{v→e}
    
    This is the SHEAF CONDITION - crucial for well-defined sections.
    """
    triangles = nerve.get(2, [])
    edges = nerve.get(1, [])
    
    for tri in triangles:
        i, j, k = tri
        # Check each vertex's path to triangle
        for v in [i, j, k]:
            # Get edges containing v in this triangle
            v_edges = [e for e in [(i, j), (j, k), (i, k)] if v in e]
            
            for edge in v_edges:
                v_tup = (v,)
                e_tup = tuple(sorted(edge))
                f_tup = tri
                
                # Get restriction maps
                R_ve = restrictions.get((v_tup, e_tup))
                R_ef = restrictions.get((e_tup, f_tup))
                R_vf = restrictions.get((v_tup, f_tup))
                
                if R_ve is not None and R_ef is not None and R_vf is not None:
                    # Check: R_vf ≈ R_ef @ R_ve
                    composition = R_ef @ R_ve
                    error = np.linalg.norm(R_vf - composition)
                    
                    if error > tol:
                        return (False, f"Coherence violation at {v_tup}→{e_tup}→{f_tup}: error = {error:.6f}")
    
    return (True, "Restriction map coherence verified (sheaf axiom satisfied)")


def compute_eigenvalue_ratios(laplacian: np.ndarray, tol: float = 1e-6) -> Dict[str, float]:
    """
    Compute eigenvalue ratios for spectral characterization.
    
    λ₂/λ₁ (algebraic connectivity ratio), λₙ/λ₁ (spectral spread), etc.
    """
    eigs = np.sort(np.linalg.eigvalsh(laplacian))
    nonzero = eigs[np.abs(eigs) > tol]
    
    if len(nonzero) < 2:
        return {"lambda2_lambda1": 1.0, "spectral_spread": 1.0, "gap_ratio": 0.0}
    
    lambda_1 = nonzero[0]
    lambda_2 = nonzero[1] if len(nonzero) > 1 else nonzero[0]
    lambda_n = nonzero[-1]
    
    return {
        "lambda2_lambda1": float(lambda_2 / lambda_1) if lambda_1 > tol else 1.0,
        "spectral_spread": float(lambda_n / lambda_1) if lambda_1 > tol else 1.0,
        "gap_ratio": float((lambda_2 - lambda_1) / lambda_1) if lambda_1 > tol else 0.0
    }


@dataclass
class GeometricInvariantReport:
    """Complete geometric invariant report for security verification."""
    # Topological
    betti_numbers: Dict[int, int]
    euler_characteristic: int
    
    # Spectral
    spectral_gap: float
    condition_number: float
    trace_L: float
    eigenvalue_ratios: Dict[str, float]
    
    # Connection/Bundle
    max_holonomy: float
    is_flat: bool
    cheeger_lower_bound: float
    
    # Homotopical Logic (from Helfer)
    h_level: int              # Truncation level of fiber
    path_space_dim: int       # dim of Path(F, F) = automorphisms
    sigma_rank: int           # Dependent sum nesting depth
    pi_rank: int              # Dependent product nesting depth
    
    # Validity
    all_invariants_valid: bool
    failure_reason: str
    
    def __str__(self) -> str:
        lines = [
            "=== GEOMETRIC INVARIANT REPORT ===",
            f"Betti: β = {self.betti_numbers}",
            f"Euler: χ = {self.euler_characteristic}",
            f"Spectral gap: λ₁ = {self.spectral_gap:.4f}",
            f"Condition: κ = {self.condition_number:.2f}",
            f"Trace: tr(L) = {self.trace_L:.4f}",
            f"Holonomy: max = {self.max_holonomy:.6f} (flat: {self.is_flat})",
            f"Cheeger: h ≥ {self.cheeger_lower_bound:.4f}",
            f"λ₂/λ₁ = {self.eigenvalue_ratios.get('lambda2_lambda1', 0):.4f}",
            "=" * 35,
            f"VALID: {self.all_invariants_valid}" + (f" ({self.failure_reason})" if not self.all_invariants_valid else "")
        ]
        return '\n'.join(lines)


def compute_full_geometric_invariants(
    laplacian: np.ndarray,
    nerve: Dict[int, List[Tuple]],
    connection: Dict[Tuple[int, int], np.ndarray] = None,
    restrictions: Dict[Tuple[Tuple, Tuple], np.ndarray] = None
) -> GeometricInvariantReport:
    """
    Compute comprehensive geometric invariant report.
    
    This is the MASTER VALIDATOR for geometric security.
    """
    SQRT2 = np.sqrt(2)
    tol = 1e-6
    
    # Topological
    topo = compute_topological_invariants(nerve)
    
    # Spectral
    eigs = np.sort(np.linalg.eigvalsh(laplacian))
    nonzero = eigs[np.abs(eigs) > tol]
    gap = float(nonzero[0]) if len(nonzero) > 0 else 0.0
    max_eig = float(eigs[-1])
    cond = max_eig / gap if gap > tol else float('inf')
    
    traces = compute_spectral_trace_invariants(laplacian)
    ratios = compute_eigenvalue_ratios(laplacian)
    
    # Connection/Bundle
    if connection:
        hol = compute_holonomy_invariants(connection, nerve)
    else:
        hol = {"max_holonomy": 0.0, "is_flat": True}
    
    cheeger = compute_cheeger_constant(laplacian)
    
    # Validate
    failures = []
    
    # √2 bounds
    if not (1/SQRT2 <= gap <= 2*SQRT2):
        failures.append(f"Gap {gap:.4f} outside √2 bounds")
    
    # PSD
    if eigs[0] < -tol:
        failures.append(f"Not PSD: min eigenvalue = {eigs[0]:.6f}")
    
    # Symmetry
    sym_err = np.linalg.norm(laplacian - laplacian.T)
    if sym_err > tol:
        failures.append(f"Not symmetric: ||L - L^T|| = {sym_err:.6f}")
    
    # Condition number
    if cond > 1000:
        failures.append(f"Ill-conditioned: κ = {cond:.2f}")
    
    return GeometricInvariantReport(
        betti_numbers=topo.betti_numbers,
        euler_characteristic=topo.euler_characteristic,
        spectral_gap=gap,
        condition_number=cond,
        trace_L=traces["trace_L"],
        eigenvalue_ratios=ratios,
        max_holonomy=hol["max_holonomy"],
        is_flat=hol["is_flat"],
        cheeger_lower_bound=cheeger,
        all_invariants_valid=len(failures) == 0,
        failure_reason="; ".join(failures) if failures else ""
    )
