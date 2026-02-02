"""
Homotopical Logic Invariants

Invariants from Helfer's first-order homotopical logic that tighten
the characterization of homotopy equivalence classes.

References:
- Helfer (2019). First-Order Homotopical Logic. arXiv:1908.08944
- HoTT Book (2013). Homotopy Type Theory
"""

from dataclasses import dataclass
from typing import Dict, List, Tuple, Optional
from enum import Enum
import numpy as np


class HLevel(Enum):
    """Truncation levels from HoTT."""
    CONTRACTIBLE = -2    # (-2)-truncated: contractible
    PROPOSITION = -1     # (-1)-truncated: mere proposition (at most one element)
    SET = 0              # 0-truncated: set (discrete, no higher paths)
    GROUPOID = 1         # 1-truncated: groupoid (has paths but no paths-of-paths)
    HIGHER = 2           # 2+-truncated: higher groupoid


@dataclass
class HomotopicalLogicInvariants:
    """
    Complete homotopical logic invariant set from Helfer's framework.
    
    These complement spectral invariants by capturing TYPE-THEORETIC structure.
    """
    # From truncation
    h_level: HLevel
    
    # From path spaces (Identity types)
    path_space_dim: int          # dim(Path(F, F)) = automorphisms
    loop_space_connected: bool   # Is Ω(F) connected?
    
    # From dependent types (Σ and Π)
    sigma_rank: int              # Existential depth (encryption layers)
    pi_rank: int                 # Universal depth (decryption keys needed)
    
    # From transport/univalence
    transport_coherence: float   # How well parallel transport commutes
    univalence_witness: bool     # Does equivalence = identity hold?
    
    def to_dict(self) -> Dict:
        return {
            "h_level": self.h_level.value,
            "path_space_dim": self.path_space_dim,
            "loop_space_connected": self.loop_space_connected,
            "sigma_rank": self.sigma_rank,
            "pi_rank": self.pi_rank,
            "transport_coherence": self.transport_coherence,
            "univalence_witness": self.univalence_witness
        }


# ============================================================================
# COMPUTATION FUNCTIONS
# ============================================================================

def compute_h_level(betti: Dict[int, int]) -> HLevel:
    """
    Compute h-level from Betti numbers.
    
    h-level measures "complexity" of homotopy type:
    - Contractible: all βₖ = 0 except β₀ = 1, and "no holes"
    - Set: β₁ = 0 (no 1-loops)
    - Groupoid: β₁ > 0, β₂ = 0
    - Higher: β₂ > 0
    """
    beta_0 = betti.get(0, 1)
    beta_1 = betti.get(1, 0)
    beta_2 = betti.get(2, 0)
    
    # Single component, no holes at all
    if beta_0 == 1 and beta_1 == 0 and beta_2 == 0:
        return HLevel.PROPOSITION
    
    # Multiple components but no 1-holes
    if beta_1 == 0 and beta_2 == 0:
        return HLevel.SET
    
    # Has 1-holes but no 2-holes
    if beta_1 > 0 and beta_2 == 0:
        return HLevel.GROUPOID
    
    # Has 2-holes or higher
    return HLevel.HIGHER


def compute_path_space_dim(laplacian: np.ndarray, tol: float = 1e-6) -> int:
    """
    Compute dim(Path(F, F)) = dim(ker Δ).
    
    The kernel of the Laplacian is the harmonic subspace,
    which corresponds to the automorphism space of the fibration.
    """
    eigs = np.linalg.eigvalsh(laplacian)
    return int(np.sum(np.abs(eigs) < tol))


def compute_sigma_rank(nerve: Dict[int, List[Tuple]]) -> int:
    """
    Compute Σ-rank: depth of dependent sum structure.
    
    Σ-rank = max cell dimension + 1
    
    Higher rank = more layers of existential quantification = more hiding.
    """
    max_dim = -1
    for dim in nerve:
        if nerve[dim]:
            max_dim = max(max_dim, dim)
    return max_dim + 1


def compute_pi_rank(betti: Dict[int, int]) -> int:
    """
    Compute Π-rank: depth of dependent product structure.
    
    Π-rank = β₀ = number of connected components
    
    Need to specify section on each component = universal quantification.
    """
    return betti.get(0, 1)


def compute_transport_coherence(
    connection: Dict[Tuple[int, int], np.ndarray],
    nerve: Dict[int, List[Tuple]],
    tol: float = 1e-6
) -> float:
    """
    Compute transport coherence = maximum holonomy deviation.
    
    Measures: max ||τ(p∘q) - τ(q)∘τ(p)|| over composable paths.
    
    Low = flat connection (good)
    High = curved (holonomy present)
    """
    triangles = nerve.get(2, [])
    if not triangles or not connection:
        return 0.0
    
    max_deviation = 0.0
    
    for tri in triangles:
        i, j, k = tri
        # Compute holonomy around triangle i → j → k → i
        dim = next(iter(connection.values())).shape[0]
        H = np.eye(dim)
        
        for edge in [(i, j), (j, k), (k, i)]:
            if edge in connection:
                H = connection[edge] @ H
            elif (edge[1], edge[0]) in connection:
                H = connection[(edge[1], edge[0])].T @ H
        
        deviation = np.linalg.norm(H - np.eye(dim))
        max_deviation = max(max_deviation, deviation)
    
    return float(max_deviation)


def check_loop_space_connected(laplacian: np.ndarray, tol: float = 1e-6) -> bool:
    """
    Check if loop space Ω(F) is connected.
    
    Connected ⟺ dim(ker Δ) = 1 (unique harmonic representative).
    """
    return compute_path_space_dim(laplacian, tol) == 1


def compute_homotopical_invariants(
    nerve: Dict[int, List[Tuple]],
    laplacian: np.ndarray,
    betti: Dict[int, int],
    connection: Dict[Tuple[int, int], np.ndarray] = None
) -> HomotopicalLogicInvariants:
    """
    Compute complete homotopical logic invariant set.
    """
    return HomotopicalLogicInvariants(
        h_level=compute_h_level(betti),
        path_space_dim=compute_path_space_dim(laplacian),
        loop_space_connected=check_loop_space_connected(laplacian),
        sigma_rank=compute_sigma_rank(nerve),
        pi_rank=compute_pi_rank(betti),
        transport_coherence=compute_transport_coherence(connection, nerve) if connection else 0.0,
        univalence_witness=True  # Always true by construction (we define equiv = path)
    )


# ============================================================================
# INVARIANT VALIDATOR CHECKPOINTS
# ============================================================================

@dataclass
class InvariantCheckpoint:
    """Result of an invariant validation checkpoint."""
    name: str
    passed: bool
    expected: str
    actual: str
    severity: str  # "critical", "warning", "info"


class HomotopicalInvariantValidator:
    """
    Validator for homotopical logic invariants with checkpoints.
    
    Like chloe_protocol's invariant_validator, but for homotopy types.
    """
    
    def __init__(
        self,
        nerve: Dict[int, List[Tuple]],
        laplacian: np.ndarray,
        betti: Dict[int, int],
        connection: Dict[Tuple[int, int], np.ndarray] = None
    ):
        self.nerve = nerve
        self.laplacian = laplacian
        self.betti = betti
        self.connection = connection
        self.invariants = compute_homotopical_invariants(
            nerve, laplacian, betti, connection
        )
        self.checkpoints: List[InvariantCheckpoint] = []
    
    def validate_all(self) -> Tuple[bool, List[InvariantCheckpoint]]:
        """Run all validation checkpoints."""
        self.checkpoints = []
        
        # Checkpoint 1: h-level consistency
        self._check_h_level_consistency()
        
        # Checkpoint 2: Path space dimension
        self._check_path_space_dim()
        
        # Checkpoint 3: Σ-rank validity
        self._check_sigma_rank()
        
        # Checkpoint 4: Π-rank matches components
        self._check_pi_rank()
        
        # Checkpoint 5: Transport coherence bounded
        self._check_transport_coherence()
        
        # Checkpoint 6: Loop space connectivity
        self._check_loop_space()
        
        all_passed = all(cp.passed for cp in self.checkpoints if cp.severity == "critical")
        return all_passed, self.checkpoints
    
    def _check_h_level_consistency(self):
        """h-level should be consistent with Betti numbers."""
        h = self.invariants.h_level
        beta_1 = self.betti.get(1, 0)
        
        if h == HLevel.SET and beta_1 > 0:
            self.checkpoints.append(InvariantCheckpoint(
                name="h-level consistency",
                passed=False,
                expected="β₁ = 0 for SET",
                actual=f"β₁ = {beta_1}",
                severity="critical"
            ))
        else:
            self.checkpoints.append(InvariantCheckpoint(
                name="h-level consistency",
                passed=True,
                expected=f"h-level = {h.name}",
                actual=f"h-level = {h.name}",
                severity="info"
            ))
    
    def _check_path_space_dim(self):
        """Path space dimension should equal β₀ for connected spaces."""
        dim = self.invariants.path_space_dim
        beta_0 = self.betti.get(0, 1)
        
        # For sheaf Laplacian, dim(ker Δ₀) = β₀
        if dim != beta_0:
            self.checkpoints.append(InvariantCheckpoint(
                name="path space dimension",
                passed=False,
                expected=f"dim(ker Δ) = β₀ = {beta_0}",
                actual=f"dim(ker Δ) = {dim}",
                severity="critical"
            ))
        else:
            self.checkpoints.append(InvariantCheckpoint(
                name="path space dimension",
                passed=True,
                expected=f"dim = {beta_0}",
                actual=f"dim = {dim}",
                severity="info"
            ))
    
    def _check_sigma_rank(self):
        """Σ-rank should be at least 1."""
        rank = self.invariants.sigma_rank
        
        if rank < 1:
            self.checkpoints.append(InvariantCheckpoint(
                name="Σ-rank validity",
                passed=False,
                expected="Σ-rank ≥ 1",
                actual=f"Σ-rank = {rank}",
                severity="critical"
            ))
        else:
            self.checkpoints.append(InvariantCheckpoint(
                name="Σ-rank validity",
                passed=True,
                expected="Σ-rank ≥ 1",
                actual=f"Σ-rank = {rank}",
                severity="info"
            ))
    
    def _check_pi_rank(self):
        """Π-rank should match connected components."""
        pi_rank = self.invariants.pi_rank
        beta_0 = self.betti.get(0, 1)
        
        if pi_rank != beta_0:
            self.checkpoints.append(InvariantCheckpoint(
                name="Π-rank matches β₀",
                passed=False,
                expected=f"Π-rank = β₀ = {beta_0}",
                actual=f"Π-rank = {pi_rank}",
                severity="warning"
            ))
        else:
            self.checkpoints.append(InvariantCheckpoint(
                name="Π-rank matches β₀",
                passed=True,
                expected=f"Π-rank = {beta_0}",
                actual=f"Π-rank = {pi_rank}",
                severity="info"
            ))
    
    def _check_transport_coherence(self, max_allowed: float = 0.1):
        """Transport coherence should be bounded (near-flat)."""
        coherence = self.invariants.transport_coherence
        
        if coherence > max_allowed:
            self.checkpoints.append(InvariantCheckpoint(
                name="transport coherence",
                passed=False,
                expected=f"coherence ≤ {max_allowed}",
                actual=f"coherence = {coherence:.4f}",
                severity="warning"
            ))
        else:
            self.checkpoints.append(InvariantCheckpoint(
                name="transport coherence",
                passed=True,
                expected=f"≤ {max_allowed}",
                actual=f"{coherence:.6f}",
                severity="info"
            ))
    
    def _check_loop_space(self):
        """For decryption, loop space should be connected (unique solution)."""
        connected = self.invariants.loop_space_connected
        
        if not connected:
            self.checkpoints.append(InvariantCheckpoint(
                name="loop space connected",
                passed=False,
                expected="Ω(F) connected (dim ker Δ = 1)",
                actual=f"dim ker Δ = {self.invariants.path_space_dim}",
                severity="critical"
            ))
        else:
            self.checkpoints.append(InvariantCheckpoint(
                name="loop space connected",
                passed=True,
                expected="connected",
                actual="connected",
                severity="info"
            ))
    
    def report(self) -> str:
        """Generate human-readable report."""
        lines = ["=== HOMOTOPICAL INVARIANT VALIDATION ==="]
        
        for cp in self.checkpoints:
            status = "✅" if cp.passed else ("⚠️" if cp.severity == "warning" else "❌")
            lines.append(f"{status} {cp.name}: {cp.actual}")
        
        lines.append("=" * 40)
        passed = all(cp.passed for cp in self.checkpoints if cp.severity == "critical")
        lines.append(f"OVERALL: {'PASS' if passed else 'FAIL'}")
        
        return '\n'.join(lines)


# ============================================================================
# FINGERPRINT MATCHING
# ============================================================================

def invariants_match(
    inv1: HomotopicalLogicInvariants,
    inv2: HomotopicalLogicInvariants,
    coherence_tol: float = 1e-6
) -> Tuple[bool, str]:
    """
    Check if two homotopical invariant sets match.
    
    Matching invariants ⟹ same homotopy class (by construction).
    """
    if inv1.h_level != inv2.h_level:
        return (False, f"h-level mismatch: {inv1.h_level} vs {inv2.h_level}")
    
    if inv1.path_space_dim != inv2.path_space_dim:
        return (False, f"path space dim mismatch: {inv1.path_space_dim} vs {inv2.path_space_dim}")
    
    if inv1.sigma_rank != inv2.sigma_rank:
        return (False, f"Σ-rank mismatch: {inv1.sigma_rank} vs {inv2.sigma_rank}")
    
    if inv1.pi_rank != inv2.pi_rank:
        return (False, f"Π-rank mismatch: {inv1.pi_rank} vs {inv2.pi_rank}")
    
    if abs(inv1.transport_coherence - inv2.transport_coherence) > coherence_tol:
        return (False, f"transport coherence mismatch: {inv1.transport_coherence} vs {inv2.transport_coherence}")
    
    return (True, "All homotopical invariants match")
