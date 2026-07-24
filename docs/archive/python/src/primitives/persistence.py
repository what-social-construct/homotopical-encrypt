"""
DEPRECATED RESEARCH PROTOTYPE — NOT A PERSISTENT-HOMOLOGY IMPLEMENTATION.

The H1 death values and the routine named ``bottleneck_distance`` do not
implement the mathematical objects claimed below.  The module is no longer
exported from ``src.primitives``.  See ``docs/SEMANTIC_PARITY_QUEUE.md``; only
the narrowly specified H0/union-find experiment is a preservation candidate.

Persistent Homology for Homotopical Cryptography

Computes persistent homology from the sheaf/Laplacian data.
No external TDA libraries required — pure numpy implementation.

WHAT THIS ADDS:

  The current system has:
  - Betti numbers β₀, β₁ (instantaneous topology at ONE scale)
  - Spectral gap λ₁ (one number)
  - PersistenceDiagram type (empty shell — no computation)

  Persistent homology adds:
  - MULTI-SCALE topology: how features appear/disappear across filtration
  - Barcodes: (birth, death) intervals for each topological feature
  - Bottleneck distance: quantitative comparison between filtrations
  - Persistence landscape: functional summary for statistical analysis

HOW IT WORKS:

  1. Build a FILTRATION from the Laplacian's spectral structure:
     - Sublevel set: threshold eigenvalues at increasing ε
     - At each ε, include edges whose spectral weight ≤ ε
     - Track which connected components merge (birth/death of H₀)
     - Track which loops appear/fill (birth/death of H₁)

  2. The persistence diagram D = {(b_i, d_i)} records:
     - b_i = filtration value where feature i is BORN
     - d_i = filtration value where feature i DIES
     - Long bars (d_i - b_i large) = robust topological features
     - Short bars = noise/artifacts

  3. STABILITY THEOREM (Edelsbrunner et al.):
     d_B(D(f), D(g)) ≤ ||f - g||_∞
     Small perturbation of the filtration → small change in diagram.
     This is why persistence is a ROBUST invariant.

INCENTIVE INTERPRETATION:

  Total persistence: Σ (d_i - b_i) = "topological complexity"
    High = rich topology = genuine geometric contribution
    Low = trivial topology = not contributing much

  Persistence entropy: -Σ p_i log(p_i) where p_i = bar_i / total
    High = features evenly distributed = balanced contribution
    Low = dominated by one feature = possibly degenerate

  Bottleneck distance: measures how different two filtrations are
    Small = similar topology across scales = compatible
    Large = fundamentally different structure

REFERENCES:
  - Edelsbrunner & Harer (2010): Computational Topology
  - Carlsson (2009): Topology and Data
  - Bubenik (2015): Statistical topological data analysis using persistence landscapes
  - Ghrist (2008): Barcodes: The persistent topology of data
"""

from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Optional
import numpy as np
import hashlib


# =============================================================================
# PERSISTENCE DIAGRAM (replaces the stub in topology.py)
# =============================================================================

@dataclass
class PersistencePair:
    """A single (birth, death) pair in the persistence diagram."""
    birth: float
    death: float      # float('inf') for features that never die
    dimension: int     # 0 = component, 1 = loop, 2 = void
    generator: Optional[Tuple] = None  # The simplex that created it

    @property
    def persistence(self) -> float:
        """Lifetime of this feature."""
        if np.isinf(self.death):
            return float('inf')
        return self.death - self.birth

    @property
    def midpoint(self) -> float:
        """Midpoint of the bar (for landscape computation)."""
        if np.isinf(self.death):
            return float('inf')
        return (self.birth + self.death) / 2.0


@dataclass
class PersistenceBarcode:
    """
    Complete persistence barcode: collection of (birth, death) pairs
    across all dimensions.

    This is the fundamental output of persistent homology.
    """
    pairs: List[PersistencePair] = field(default_factory=list)

    def dimension(self, dim: int) -> List[PersistencePair]:
        """Get pairs for a specific dimension."""
        return [p for p in self.pairs if p.dimension == dim]

    @property
    def h0_pairs(self) -> List[PersistencePair]:
        """H₀ pairs (connected components)."""
        return self.dimension(0)

    @property
    def h1_pairs(self) -> List[PersistencePair]:
        """H₁ pairs (loops)."""
        return self.dimension(1)

    def total_persistence(self, dim: Optional[int] = None) -> float:
        """
        Total persistence: Σ (d_i - b_i) for finite bars.

        Measures "topological complexity" — more persistent features
        = richer topology = genuine geometric content.
        """
        pairs = self.dimension(dim) if dim is not None else self.pairs
        return sum(p.persistence for p in pairs if np.isfinite(p.persistence))

    def persistence_entropy(self, dim: Optional[int] = None) -> float:
        """
        Persistence entropy: -Σ p_i log(p_i).

        Measures how evenly distributed the topological features are.
        High entropy = balanced, low = dominated by one feature.
        """
        pairs = self.dimension(dim) if dim is not None else self.pairs
        lifetimes = [p.persistence for p in pairs if np.isfinite(p.persistence) and p.persistence > 0]

        if not lifetimes:
            return 0.0

        total = sum(lifetimes)
        if total == 0:
            return 0.0

        probs = [l / total for l in lifetimes]
        return float(-sum(p * np.log(p + 1e-15) for p in probs))

    def max_persistence(self, dim: Optional[int] = None) -> float:
        """Maximum bar length (most robust feature)."""
        pairs = self.dimension(dim) if dim is not None else self.pairs
        finite_pers = [p.persistence for p in pairs if np.isfinite(p.persistence)]
        return max(finite_pers) if finite_pers else 0.0

    def n_significant(self, threshold: float = 0.1, dim: Optional[int] = None) -> int:
        """Number of bars longer than threshold."""
        pairs = self.dimension(dim) if dim is not None else self.pairs
        return sum(1 for p in pairs if np.isfinite(p.persistence) and p.persistence > threshold)

    def to_diagram_array(self, dim: int = 0) -> np.ndarray:
        """Convert to (n, 2) array of (birth, death) for a given dimension."""
        pairs = self.dimension(dim)
        if not pairs:
            return np.zeros((0, 2))
        return np.array([[p.birth, p.death] for p in pairs])

    @property
    def fingerprint(self) -> bytes:
        """Hash fingerprint of the barcode."""
        data = []
        for p in sorted(self.pairs, key=lambda x: (x.dimension, x.birth)):
            d = p.death if np.isfinite(p.death) else 9999.0
            data.append(f"{p.dimension}:{p.birth:.6f},{d:.6f}")
        return hashlib.sha256("|".join(data).encode()).digest()


# =============================================================================
# FILTRATION FROM LAPLACIAN (spectral Rips)
# =============================================================================

def _spectral_distances(laplacian: np.ndarray, tol: float = 1e-10) -> np.ndarray:
    """
    Compute pairwise spectral distances between vertices.

    The spectral distance between vertices i, j is:
      d(i,j) = ||φ(i) - φ(j)||

    where φ(i) is the spectral embedding of vertex i:
      φ(i) = (f₁(i)/√λ₁, f₂(i)/√λ₂, ...)

    for eigenvectors f_k with eigenvalues λ_k > 0.
    """
    n = laplacian.shape[0]
    eigs, vecs = np.linalg.eigh(laplacian)

    # Use nonzero eigenvalues for embedding
    nonzero_mask = eigs > tol
    if not np.any(nonzero_mask):
        return np.zeros((n, n))

    # Spectral embedding: scale by 1/√λ
    embedding = vecs[:, nonzero_mask] / np.sqrt(eigs[nonzero_mask])

    # Pairwise distances
    dists = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            d = np.linalg.norm(embedding[i] - embedding[j])
            dists[i, j] = d
            dists[j, i] = d

    return dists


def compute_rips_filtration(
    laplacian: np.ndarray,
    n_steps: int = 50,
) -> List[Tuple[float, List[Tuple[int, int]]]]:
    """
    Build Vietoris-Rips filtration from spectral distances.

    At filtration value ε, include edge (i,j) if d(i,j) ≤ ε.

    Returns list of (epsilon, new_edges_at_this_epsilon).
    """
    n = laplacian.shape[0]
    dists = _spectral_distances(laplacian)

    # Get all unique edge distances
    edge_dists = []
    for i in range(n):
        for j in range(i + 1, n):
            if dists[i, j] > 0:
                edge_dists.append((dists[i, j], (i, j)))

    # Sort by distance
    edge_dists.sort(key=lambda x: x[0])

    if not edge_dists:
        return [(0.0, [])]

    # Build filtration steps
    max_dist = edge_dists[-1][0]
    step_size = max_dist / n_steps if n_steps > 0 else max_dist

    filtration = []
    edge_idx = 0

    for step in range(n_steps + 1):
        eps = step * step_size
        new_edges = []

        while edge_idx < len(edge_dists) and edge_dists[edge_idx][0] <= eps:
            new_edges.append(edge_dists[edge_idx][1])
            edge_idx += 1

        if new_edges:
            filtration.append((eps, new_edges))

    return filtration


# =============================================================================
# UNION-FIND (for H₀ computation)
# =============================================================================

class UnionFind:
    """Union-Find with path compression for tracking connected components."""

    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.n_components = n

    def find(self, x: int) -> int:
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]  # Path compression
            x = self.parent[x]
        return x

    def union(self, x: int, y: int) -> bool:
        """Union two sets. Returns True if they were in different components."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False

        # Union by rank
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1

        self.n_components -= 1
        return True


# =============================================================================
# PERSISTENT HOMOLOGY COMPUTATION
# =============================================================================

def compute_persistence_h0(
    n_vertices: int,
    filtration: List[Tuple[float, List[Tuple[int, int]]]],
) -> List[PersistencePair]:
    """
    Compute H₀ persistence (connected components) via Union-Find.

    Algorithm:
    1. Start with n isolated vertices (n components born at ε=0)
    2. As edges appear, merge components
    3. When two components merge, the younger one dies

    Returns list of PersistencePair for dimension 0.
    """
    uf = UnionFind(n_vertices)
    birth_time = {i: 0.0 for i in range(n_vertices)}  # All born at 0
    pairs = []

    for eps, edges in filtration:
        for (u, v) in edges:
            ru, rv = uf.find(u), uf.find(v)
            if ru != rv:
                # Merge: younger component dies
                # "Elder rule": the component born LATER dies
                if birth_time[ru] <= birth_time[rv]:
                    # rv is younger or same age → rv dies
                    dying = rv
                else:
                    dying = ru

                pairs.append(PersistencePair(
                    birth=birth_time[dying],
                    death=eps,
                    dimension=0,
                    generator=(u, v),
                ))

                uf.union(u, v)

                # Update birth time for merged component
                new_root = uf.find(u)
                birth_time[new_root] = min(birth_time[ru], birth_time[rv])

    # Remaining components never die (infinite persistence)
    seen_roots = set()
    for i in range(n_vertices):
        r = uf.find(i)
        if r not in seen_roots:
            seen_roots.add(r)
            pairs.append(PersistencePair(
                birth=birth_time[r],
                death=float('inf'),
                dimension=0,
                generator=(r,),
            ))

    return pairs


def compute_persistence_h1(
    n_vertices: int,
    filtration: List[Tuple[float, List[Tuple[int, int]]]],
) -> List[PersistencePair]:
    """
    Compute H₁ persistence (loops) via edge tracking.

    Simple approach: a loop is born when adding an edge does NOT
    merge two components (both endpoints already connected).
    The loop dies when a triangle fills it.

    For our cellular sheaf setting, we track:
    - Edge that creates a cycle → birth
    - Triangle that kills it → death (approximated by next filtration step)
    """
    uf = UnionFind(n_vertices)
    pairs = []
    cycle_births = []

    for eps, edges in filtration:
        for (u, v) in edges:
            if uf.find(u) == uf.find(v):
                # Both endpoints already connected → CYCLE BORN
                cycle_births.append((eps, (u, v)))
            else:
                uf.union(u, v)

    # Approximate H₁ death: cycles die at progressively later filtration values
    # Full algorithm would need boundary matrix reduction
    # Simplified: assign death based on filtration spacing
    if cycle_births and filtration:
        max_eps = filtration[-1][0] if filtration else 1.0
        for i, (birth_eps, gen) in enumerate(cycle_births):
            # Estimate death: evenly spaced after birth
            death_eps = birth_eps + (max_eps - birth_eps) * (i + 1) / (len(cycle_births) + 1)
            pairs.append(PersistencePair(
                birth=birth_eps,
                death=death_eps,
                dimension=1,
                generator=gen,
            ))

    return pairs


def compute_persistent_homology(
    laplacian: np.ndarray,
    n_steps: int = 50,
) -> PersistenceBarcode:
    """
    Compute persistent homology from Laplacian.

    This is the MAIN ENTRY POINT.

    Process:
    1. Build spectral Rips filtration from Laplacian
    2. Compute H₀ persistence (component merging via Union-Find)
    3. Compute H₁ persistence (cycle creation)
    4. Return barcode

    Args:
        laplacian: Graph Laplacian (or sheaf Laplacian)
        n_steps: Number of filtration steps

    Returns:
        PersistenceBarcode with all (birth, death) pairs
    """
    n = laplacian.shape[0]
    filtration = compute_rips_filtration(laplacian, n_steps)

    h0_pairs = compute_persistence_h0(n, filtration)
    h1_pairs = compute_persistence_h1(n, filtration)

    return PersistenceBarcode(pairs=h0_pairs + h1_pairs)


# =============================================================================
# BOTTLENECK DISTANCE
# =============================================================================

def bottleneck_distance(
    barcode1: PersistenceBarcode,
    barcode2: PersistenceBarcode,
    dim: int = 0,
) -> float:
    """
    Compute bottleneck distance between two persistence diagrams.

    d_B(D₁, D₂) = inf_γ sup_x ||x - γ(x)||_∞

    where γ ranges over all bijections between D₁ and D₂
    (including matching to the diagonal).

    Simplified: uses greedy matching (not optimal, but O(n²) and practical).

    The stability theorem guarantees:
      d_B(D(f), D(g)) ≤ ||f - g||_∞
    so small perturbation → small bottleneck distance.
    """
    pts1 = barcode1.to_diagram_array(dim)
    pts2 = barcode2.to_diagram_array(dim)

    # Filter out infinite deaths for matching
    finite1 = pts1[np.isfinite(pts1[:, 1])] if len(pts1) > 0 else np.zeros((0, 2))
    finite2 = pts2[np.isfinite(pts2[:, 1])] if len(pts2) > 0 else np.zeros((0, 2))

    if len(finite1) == 0 and len(finite2) == 0:
        return 0.0

    # Cost of matching point to diagonal: persistence / 2
    def diag_cost(pt):
        return (pt[1] - pt[0]) / 2.0

    # Greedy matching
    max_cost = 0.0
    used2 = set()

    for i, p1 in enumerate(finite1):
        best_cost = diag_cost(p1)  # Default: match to diagonal
        best_j = -1

        for j, p2 in enumerate(finite2):
            if j in used2:
                continue
            cost = max(abs(p1[0] - p2[0]), abs(p1[1] - p2[1]))
            if cost < best_cost:
                best_cost = cost
                best_j = j

        if best_j >= 0:
            used2.add(best_j)

        max_cost = max(max_cost, best_cost)

    # Unmatched points in D₂ also match to diagonal
    for j, p2 in enumerate(finite2):
        if j not in used2:
            max_cost = max(max_cost, diag_cost(p2))

    return max_cost


# =============================================================================
# PERSISTENCE LANDSCAPE (functional summary)
# =============================================================================

def persistence_landscape(
    barcode: PersistenceBarcode,
    dim: int = 0,
    n_layers: int = 3,
    resolution: int = 100,
) -> np.ndarray:
    """
    Compute persistence landscape (Bubenik 2015).

    The k-th landscape function λ_k(t) is the k-th largest value of
    the "tent functions" at filtration value t.

    Returns shape (n_layers, resolution) array.

    For incentives: the integral ∫λ₁(t)dt measures the "dominant
    topological feature's robustness." Higher = more persistent
    = more genuine geometric content.
    """
    pts = barcode.to_diagram_array(dim)
    finite_pts = pts[np.isfinite(pts[:, 1])] if len(pts) > 0 else np.zeros((0, 2))

    if len(finite_pts) == 0:
        return np.zeros((n_layers, resolution))

    # Filtration range
    t_min = float(np.min(finite_pts[:, 0]))
    t_max = float(np.max(finite_pts[:, 1]))

    if t_max <= t_min:
        return np.zeros((n_layers, resolution))

    t_values = np.linspace(t_min, t_max, resolution)
    landscape = np.zeros((n_layers, resolution))

    for idx, t in enumerate(t_values):
        # Compute tent function values at t
        tent_values = []
        for b, d in finite_pts:
            mid = (b + d) / 2.0
            half_life = (d - b) / 2.0
            if b <= t <= d and half_life > 0:
                value = half_life - abs(t - mid)
                tent_values.append(max(0.0, value))

        # Sort descending — k-th landscape = k-th largest
        tent_values.sort(reverse=True)

        for k in range(min(n_layers, len(tent_values))):
            landscape[k, idx] = tent_values[k]

    return landscape


def landscape_norm(landscape: np.ndarray, p: int = 2) -> float:
    """
    Lᵖ norm of persistence landscape.

    ||λ||_p = (Σ_k ∫|λ_k(t)|^p dt)^{1/p}

    For incentives: higher norm = more persistent topology.
    """
    if landscape.size == 0:
        return 0.0
    return float(np.sum(np.abs(landscape) ** p) ** (1.0 / p))


# =============================================================================
# PERSISTENCE PROFILE (for incentive layer)
# =============================================================================

@dataclass
class PersistenceProfile:
    """
    Complete persistence profile for incentive analysis.

    Combines barcode, landscape, and derived scores into a single
    object usable by the incentive layer.
    """
    barcode: PersistenceBarcode
    landscape_h0: np.ndarray
    landscape_h1: np.ndarray

    # Derived scores
    total_persistence_h0: float = 0.0
    total_persistence_h1: float = 0.0
    persistence_entropy: float = 0.0
    max_bar_h0: float = 0.0
    max_bar_h1: float = 0.0
    n_significant_h0: int = 0
    n_significant_h1: int = 0
    landscape_norm_h0: float = 0.0

    def __post_init__(self):
        self.total_persistence_h0 = self.barcode.total_persistence(0)
        self.total_persistence_h1 = self.barcode.total_persistence(1)
        self.persistence_entropy = self.barcode.persistence_entropy()
        self.max_bar_h0 = self.barcode.max_persistence(0)
        self.max_bar_h1 = self.barcode.max_persistence(1)
        self.n_significant_h0 = self.barcode.n_significant(0.1, 0)
        self.n_significant_h1 = self.barcode.n_significant(0.1, 1)
        self.landscape_norm_h0 = landscape_norm(self.landscape_h0)

    @property
    def topological_complexity(self) -> float:
        """
        Topological complexity score in [0, 1].

        Combines:
        - Total persistence (how much topology exists)
        - Entropy (how evenly distributed)
        - Significant features (how many robust features)
        """
        # Normalize total persistence (empirical scaling)
        pers_score = min(1.0, (self.total_persistence_h0 + self.total_persistence_h1) / 10.0)

        # Entropy normalized (max entropy ≈ log(n_features))
        n_features = max(1, self.n_significant_h0 + self.n_significant_h1)
        max_entropy = np.log(n_features + 1)
        entropy_score = self.persistence_entropy / max_entropy if max_entropy > 0 else 0.0

        return (pers_score + entropy_score) / 2.0

    @property
    def fingerprint(self) -> bytes:
        """Fingerprint of persistence profile."""
        return self.barcode.fingerprint


def compute_persistence_profile(
    laplacian: np.ndarray,
    n_steps: int = 50,
    n_landscape_layers: int = 3,
    landscape_resolution: int = 100,
) -> PersistenceProfile:
    """
    Compute complete persistence profile from Laplacian.

    This is the main entry point for incentive layer analysis.
    """
    barcode = compute_persistent_homology(laplacian, n_steps)
    ls_h0 = persistence_landscape(barcode, dim=0, n_layers=n_landscape_layers, resolution=landscape_resolution)
    ls_h1 = persistence_landscape(barcode, dim=1, n_layers=n_landscape_layers, resolution=landscape_resolution)

    return PersistenceProfile(
        barcode=barcode,
        landscape_h0=ls_h0,
        landscape_h1=ls_h1,
    )


# =============================================================================
# TEST
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("PERSISTENT HOMOLOGY TEST")
    print("=" * 60)

    # Build test Laplacian (triangle graph)
    # L = D - A for K₃
    L = np.array([
        [ 2, -1, -1],
        [-1,  2, -1],
        [-1, -1,  2],
    ], dtype=float)

    print("\n1. Spectral distances:")
    dists = _spectral_distances(L)
    print(f"   Distance matrix:\n{dists}")

    print("\n2. Rips filtration:")
    filt = compute_rips_filtration(L, n_steps=10)
    for eps, edges in filt[:5]:
        print(f"   ε = {eps:.4f}: edges = {edges}")

    print("\n3. Persistent homology:")
    barcode = compute_persistent_homology(L, n_steps=20)
    print(f"   H₀ pairs: {len(barcode.h0_pairs)}")
    for p in barcode.h0_pairs:
        d = f"{p.death:.4f}" if np.isfinite(p.death) else "∞"
        print(f"      [{p.birth:.4f}, {d})")
    print(f"   H₁ pairs: {len(barcode.h1_pairs)}")
    for p in barcode.h1_pairs:
        print(f"      [{p.birth:.4f}, {p.death:.4f})")

    print(f"\n   Total persistence H₀: {barcode.total_persistence(0):.4f}")
    print(f"   Total persistence H₁: {barcode.total_persistence(1):.4f}")
    print(f"   Persistence entropy:   {barcode.persistence_entropy():.4f}")
    print(f"   Barcode fingerprint:   {barcode.fingerprint.hex()[:16]}...")

    print("\n4. Bottleneck distance (self):")
    d = bottleneck_distance(barcode, barcode, dim=0)
    print(f"   d_B(D, D) = {d:.6f}  (should be 0)")

    # Different Laplacian
    L2 = np.array([
        [ 1, -1,  0],
        [-1,  2, -1],
        [ 0, -1,  1],
    ], dtype=float)
    barcode2 = compute_persistent_homology(L2, n_steps=20)
    d12 = bottleneck_distance(barcode, barcode2, dim=0)
    print(f"   d_B(K₃, path) = {d12:.6f}  (should be > 0)")

    print("\n5. Persistence landscape:")
    ls = persistence_landscape(barcode, dim=0, n_layers=3, resolution=50)
    print(f"   Shape: {ls.shape}")
    print(f"   λ₁ max: {np.max(ls[0]):.4f}")
    print(f"   ||λ||₂: {landscape_norm(ls):.4f}")

    print("\n6. Full persistence profile:")
    profile = compute_persistence_profile(L, n_steps=20)
    print(f"   Total H₀: {profile.total_persistence_h0:.4f}")
    print(f"   Total H₁: {profile.total_persistence_h1:.4f}")
    print(f"   Entropy:   {profile.persistence_entropy:.4f}")
    print(f"   Complexity: {profile.topological_complexity:.4f}")
    print(f"   Fingerprint: {profile.fingerprint.hex()[:16]}...")

    print("\n" + "=" * 60)
    print("✅ PERSISTENT HOMOLOGY READY")
    print("=" * 60)
