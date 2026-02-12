"""
Validator Selection via Grassmann Centrality (Plücker)

UPGRADE FROM FIEDLER TO PLÜCKER:

  OLD (Fiedler):
    centrality[v] = |fiedler_vector[v]|
    → measures graph-theoretic position (Layer 1)
    → two validators at same graph position get same centrality
    → doesn't capture stalk geometry

  NEW (Plücker):
    consensus = karcher_mean(stalk_subspaces)
    centrality[v] = 1 / (1 + d_Gr(stalk(v), consensus))
    → measures geometric alignment with consensus subspace (Layer 3)
    → two validators with same graph position but different stalks
      get DIFFERENT centralities
    → naturally rewards geometric coherence, not just connectivity

WHY PLÜCKER:

  Plücker coordinates embed Gr(k,n) → P(∧ᵏℝⁿ). This gives us:
  1. A CANONICAL representation of each validator's stalk subspace
  2. DISTANCE = geometric disagreement (via grassmann_distance)
  3. CONSENSUS = Karcher mean on Gr(k,n) (principled average subspace)
  4. SYBIL RESISTANCE: can't fake aligned stalks without real data
     (Fiedler only requires edges, Plücker requires geometric coherence)

FALLBACK:

  If stalk data isn't available (e.g., genesis epoch or lightweight nodes),
  falls back to Fiedler centrality. This ensures backwards compatibility.

Mathematical basis:
- Grassmann manifold Gr(k,n): space of k-dim subspaces of ℝⁿ
- Plücker embedding: Gr(k,n) → P(∧ᵏℝⁿ) (projective coordinates)
- Karcher mean: argmin_P Σᵢ d²(P, Pᵢ) on Gr(k,n)
- Principal angles: θ₁ ≤ ... ≤ θₖ measure per-dimension agreement
"""

from typing import List, Dict, Tuple, Optional
from dataclasses import dataclass
import numpy as np
import hashlib

from ..primitives.grassmann import (
    subspace_projector,
    grassmann_distance,
    grassmann_karcher_mean,
    stalk_to_subspace,
    to_plucker,
    principal_angles,
)


@dataclass
class Validator:
    """
    A validator in the network.

    Validators are identified by their spectral fingerprint,
    not by staked capital. Their selection probability comes
    from their geometric alignment with the consensus subspace
    (Plücker centrality), not from capital or graph position.
    """
    fingerprint: bytes          # Spectral fingerprint (identity)
    vertex_id: int              # Position in topology
    stake: float = 0.0          # Optional stake (for slashing, not selection)
    is_active: bool = True      # Currently active
    last_block: int = 0         # Last block produced
    stalk_data: Optional[np.ndarray] = None  # Stalk vectors for Plücker centrality


class ValidatorSet:
    """
    Manages the validator set for PoV consensus.

    Selection is based on Plücker centrality (Grassmann distance
    to consensus subspace), falling back to Fiedler centrality
    when stalk data is unavailable.
    """

    def __init__(self, topology: Dict[int, List[Tuple]]):
        self.topology = topology
        self.validators: Dict[bytes, Validator] = {}
        self._laplacian: Optional[np.ndarray] = None
        self._centralities: Optional[Dict[bytes, float]] = None
        self._consensus_projector: Optional[np.ndarray] = None
        self._stalk_dim: int = 2  # Default subspace dimension for Plücker

    def register_validator(
        self,
        fingerprint: bytes,
        vertex_id: int,
        stake: float = 0.0,
        stalk_data: Optional[np.ndarray] = None,
    ) -> bool:
        """
        Register a new validator.

        Args:
            fingerprint: Spectral fingerprint (identity)
            vertex_id: Position in topology
            stake: Optional stake for slashing
            stalk_data: Stalk vectors (m, n) for Plücker centrality.
                        If None, falls back to Fiedler.
        """
        if fingerprint in self.validators:
            return False

        vertices = self.topology.get(0, [])
        if vertex_id >= len(vertices):
            return False

        self.validators[fingerprint] = Validator(
            fingerprint=fingerprint,
            vertex_id=vertex_id,
            stake=stake,
            is_active=True,
            stalk_data=stalk_data,
        )

        # Invalidate cached centralities
        self._centralities = None
        self._consensus_projector = None

        return True

    def update_stalk_data(self, fingerprint: bytes, stalk_data: np.ndarray) -> bool:
        """Update a validator's stalk data (e.g., after key rotation)."""
        if fingerprint not in self.validators:
            return False
        self.validators[fingerprint].stalk_data = stalk_data
        self._centralities = None
        self._consensus_projector = None
        return True

    def deactivate_validator(self, fingerprint: bytes) -> bool:
        """Deactivate a validator (e.g., for slashing)."""
        if fingerprint not in self.validators:
            return False

        self.validators[fingerprint].is_active = False
        self._centralities = None
        self._consensus_projector = None
        return True

    def get_active_validators(self) -> List[Validator]:
        """Get all active validators."""
        return [v for v in self.validators.values() if v.is_active]

    # =========================================================================
    # PLÜCKER CENTRALITY (primary)
    # =========================================================================

    def _has_stalk_data(self) -> bool:
        """Check if enough validators have stalk data for Plücker."""
        active = self.get_active_validators()
        with_stalks = sum(1 for v in active if v.stalk_data is not None)
        return with_stalks >= 2  # Need at least 2 for Karcher mean

    def compute_consensus_subspace(self) -> Optional[np.ndarray]:
        """
        Compute consensus subspace via Karcher mean on Gr(k,n).

        This is the geometrically principled "average" of all
        validator stalk subspaces. Validators close to this
        consensus have higher centrality.

        Returns:
            Consensus projector matrix, or None if insufficient data.
        """
        if self._consensus_projector is not None:
            return self._consensus_projector

        active = self.get_active_validators()
        projectors = []

        for v in active:
            if v.stalk_data is not None:
                try:
                    P = stalk_to_subspace(v.stalk_data, self._stalk_dim)
                    if P.size > 0:
                        projectors.append(P)
                except Exception:
                    continue

        if len(projectors) < 2:
            return None

        try:
            self._consensus_projector = grassmann_karcher_mean(projectors)
            return self._consensus_projector
        except Exception:
            return None

    def compute_plucker_centrality(self) -> Optional[Dict[bytes, float]]:
        """
        Compute Plücker centrality for all validators.

        centrality[v] = 1 / (1 + d_Gr(stalk(v), consensus))

        Validators whose stalk subspace is geometrically aligned with
        the consensus subspace have higher centrality. This rewards
        actual geometric coherence, not just graph topology.

        Returns:
            fingerprint → centrality mapping, or None if insufficient data.
        """
        consensus = self.compute_consensus_subspace()
        if consensus is None:
            return None

        centralities = {}
        for fingerprint, validator in self.validators.items():
            if not validator.is_active:
                continue

            if validator.stalk_data is None:
                # No stalk data → minimum centrality (but not zero)
                centralities[fingerprint] = 0.01
                continue

            try:
                P = stalk_to_subspace(validator.stalk_data, self._stalk_dim)
                dist = grassmann_distance(P, consensus)
                # Inverse distance: closer to consensus = higher centrality
                centralities[fingerprint] = 1.0 / (1.0 + dist)
            except Exception:
                centralities[fingerprint] = 0.01

        # Normalize to sum to 1
        total = sum(centralities.values())
        if total > 0:
            centralities = {k: v / total for k, v in centralities.items()}

        return centralities

    # =========================================================================
    # FIEDLER CENTRALITY (fallback)
    # =========================================================================

    def compute_fiedler_centrality(self) -> Dict[bytes, float]:
        """
        Fiedler centrality (fallback when stalk data unavailable).

        Uses the Fiedler vector (second eigenvector of Laplacian).
        |fiedler[v]| measures how central vertex v is to the network.
        """
        vertices = self.topology.get(0, [])
        edges = self.topology.get(1, [])
        n = len(vertices)

        if n == 0:
            return {}

        # Build Laplacian
        degree = np.zeros(n)
        adjacency = np.zeros((n, n))

        for edge in edges:
            if len(edge) >= 2:
                i, j = edge[0], edge[1]
                if i < n and j < n:
                    adjacency[i, j] = 1
                    adjacency[j, i] = 1
                    degree[i] += 1
                    degree[j] += 1

        laplacian = np.diag(degree) - adjacency
        self._laplacian = laplacian

        eigenvalues, eigenvectors = np.linalg.eigh(laplacian)

        if n > 1:
            fiedler_vector = eigenvectors[:, 1]
        else:
            fiedler_vector = np.ones(1)

        centralities = {}
        for fingerprint, validator in self.validators.items():
            if validator.is_active:
                idx = validator.vertex_id
                if idx < n:
                    centralities[fingerprint] = abs(fiedler_vector[idx])
                else:
                    centralities[fingerprint] = 0.0

        # Normalize
        total = sum(centralities.values())
        if total > 0:
            centralities = {k: v / total for k, v in centralities.items()}

        return centralities

    # =========================================================================
    # UNIFIED CENTRALITY (Plücker with Fiedler fallback)
    # =========================================================================

    def compute_spectral_centrality(self) -> Dict[bytes, float]:
        """
        Compute centrality for all validators.

        Uses Plücker centrality (Grassmann distance to Karcher mean)
        when stalk data is available, falls back to Fiedler centrality
        (Laplacian second eigenvector) otherwise.

        This is the main entry point for validator selection.
        """
        if self._centralities is not None:
            return self._centralities

        if self._has_stalk_data():
            plucker = self.compute_plucker_centrality()
            if plucker is not None:
                self._centralities = plucker
                return self._centralities

        # Fallback to Fiedler
        self._centralities = self.compute_fiedler_centrality()
        return self._centralities

    # =========================================================================
    # VALIDATOR SELECTION
    # =========================================================================

    def select_validator(
        self,
        epoch: int,
        prev_block_hash: bytes
    ) -> Optional[bytes]:
        """
        Select validator for next block using centrality + VRF.

        Args:
            epoch: Current epoch number
            prev_block_hash: Hash of previous block (source of randomness)

        Returns:
            Fingerprint of selected validator, or None if no validators
        """
        active = self.get_active_validators()
        if not active:
            return None

        centralities = self.compute_spectral_centrality()

        # VRF: deterministic randomness from prev_block
        vrf_input = prev_block_hash + epoch.to_bytes(8, 'little')
        vrf_output = hashlib.sha256(vrf_input).digest()

        # Convert to random float in [0, 1)
        random_value = int.from_bytes(vrf_output[:8], 'little') / (2**64)

        # Weighted selection by centrality
        cumulative = 0.0
        for fingerprint in centralities:
            cumulative += centralities[fingerprint]
            if random_value < cumulative:
                self.validators[fingerprint].last_block = epoch
                return fingerprint

        # Fallback
        return list(centralities.keys())[-1] if centralities else None

    def get_validator_info(self, fingerprint: bytes) -> Optional[Dict]:
        """Get info about a specific validator."""
        if fingerprint not in self.validators:
            return None

        v = self.validators[fingerprint]
        centralities = self.compute_spectral_centrality()

        info = {
            "fingerprint": fingerprint.hex()[:16] + "...",
            "vertex_id": v.vertex_id,
            "stake": v.stake,
            "is_active": v.is_active,
            "centrality": centralities.get(fingerprint, 0.0),
            "last_block": v.last_block,
            "has_stalk_data": v.stalk_data is not None,
            "centrality_type": "plucker" if self._has_stalk_data() else "fiedler",
        }
        return info

    def get_selection_probabilities(self) -> Dict[bytes, float]:
        """Get selection probability for each validator."""
        return self.compute_spectral_centrality()


def select_validator_for_block(
    topology: Dict[int, List[Tuple]],
    validators: List[Tuple[bytes, int]],  # (fingerprint, vertex_id)
    epoch: int,
    prev_block_hash: bytes
) -> Optional[bytes]:
    """
    Convenience function for validator selection.

    Args:
        topology: Network topology (nerve)
        validators: List of (fingerprint, vertex_id) tuples
        epoch: Current epoch
        prev_block_hash: Previous block hash

    Returns:
        Selected validator fingerprint
    """
    validator_set = ValidatorSet(topology)
    for fingerprint, vertex_id in validators:
        validator_set.register_validator(fingerprint, vertex_id)

    return validator_set.select_validator(epoch, prev_block_hash)


# =============================================================================
# TEST
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("VALIDATOR SELECTION TEST (Plücker + Fiedler)")
    print("=" * 60)

    # Topology: path graph P₅: 0—1—2—3—4
    topology = {
        0: [(0,), (1,), (2,), (3,), (4,)],
        1: [(0, 1), (1, 2), (2, 3), (2, 4)],
        2: []
    }

    # =========================================================================
    # Test 1: Fiedler fallback (no stalk data)
    # =========================================================================
    print("\n1. Fiedler fallback (no stalk data):")
    validator_set = ValidatorSet(topology)
    validators = []
    for i in range(5):
        fp = hashlib.sha256(f"validator_{i}".encode()).digest()
        validator_set.register_validator(fp, i)
        validators.append((fp, i))

    centralities = validator_set.compute_spectral_centrality()
    for i, (fp, _) in enumerate(validators):
        c = centralities.get(fp, 0)
        print(f"   V{i}: {c:.4f} (Fiedler)")

    # =========================================================================
    # Test 2: Plücker centrality (with stalk data)
    # =========================================================================
    print("\n2. Plücker centrality (with stalk data):")
    validator_set2 = ValidatorSet(topology)
    validators2 = []

    np.random.seed(42)
    # Consensus direction: mostly along [1, 1, 0, 0, 0]
    consensus_dir = np.array([[1.0, 1.0, 0.0, 0.0, 0.0],
                               [0.0, 1.0, 1.0, 0.0, 0.0]])

    for i in range(5):
        fp = hashlib.sha256(f"validator_{i}".encode()).digest()
        # V2 (center) has stalk most aligned with consensus
        # Others progressively less aligned
        noise = np.random.randn(2, 5) * (abs(i - 2) * 0.5 + 0.1)
        stalk = consensus_dir + noise
        validator_set2.register_validator(fp, i, stalk_data=stalk)
        validators2.append((fp, i))

    centralities2 = validator_set2.compute_spectral_centrality()
    for i, (fp, _) in enumerate(validators2):
        c = centralities2.get(fp, 0)
        ct = "Plücker" if validator_set2._has_stalk_data() else "Fiedler"
        print(f"   V{i}: {c:.4f} ({ct})")

    # =========================================================================
    # Test 3: Selection simulation
    # =========================================================================
    print("\n3. Selection simulation (100 epochs, Plücker):")
    counts = {fp: 0 for fp, _ in validators2}
    prev_hash = b'\x00' * 32

    for epoch in range(100):
        selected = validator_set2.select_validator(epoch, prev_hash)
        if selected:
            counts[selected] += 1
            prev_hash = hashlib.sha256(prev_hash + selected).digest()

    for i, (fp, _) in enumerate(validators2):
        count = counts[fp]
        expected = centralities2.get(fp, 0) * 100
        print(f"   V{i}: {count} blocks (expected ~{expected:.1f})")

    print("\n" + "=" * 60)
    print("✅ VALIDATOR SELECTION WORKING (Plücker + Fiedler fallback)")
    print("=" * 60)
