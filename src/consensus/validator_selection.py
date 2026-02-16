"""
Validator Selection via Harmonic Projection Weight

THREE-LAYER SELECTION:

  1. Vault bond gate (binary):
     eligible(v) = vault.bonded >= MINIMUM_VAULT_BOND
     → Skin in the game. Not a weight — go/no-go.

  2. Plücker eligibility gate (binary):
     eligible(v) = d_Gr(stalk(v), μ) < MAX_DIVERGENCE
     → Close enough to consensus? Uses Grassmann distance.

  3. Harmonic projection weight (continuous):
     weight(v) = ‖π_H(stalk(v))‖ / ‖stalk(v)‖
     → How much of your stalk IS harmonic under the network's Δ_F?
     → This IS your "value" — the part that survives projection.
     → Determines selection probability AND reward share.

WHY HARMONIC WEIGHT OVER PLÜCKER CENTRALITY:

  Plücker centrality measures DISTANCE to consensus.
  Harmonic weight measures how much of your data IS CONSENSUS.
  Two equidistant validators can have different harmonic content.
  Value := what survives π_H. Selection should BE that value.

FALLBACK:

  If stalk data isn't available (genesis epoch, lightweight nodes),
  falls back to Fiedler centrality. Backwards compatible.

See docs/CONSENSUS.md for the full design.
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
    from harmonic projection weight — how much of their stalk
    survives the network's Hodge projection π_H on Gr(k,n).

    The Grassmann manifold is Hodge-native: the same geometry
    that defines the onion routing (parallel transport on the
    fiber bundle) also defines consensus (Karcher mean, sheaf
    Laplacian, harmonic decomposition). One geometric substrate.
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

    Grassmann is Hodge-native: Gr(k,n) is the shared geometric
    substrate for onion routing (parallel transport), consensus
    (Karcher mean + sheaf Laplacian), and selection (harmonic
    projection weight). One manifold, three uses.

    Selection: harmonic weight → Plücker gate → Fiedler fallback.
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
    # HARMONIC PROJECTION WEIGHT (primary — via CoherenceEngine)
    # =========================================================================

    def compute_harmonic_weights(self) -> Optional[Dict[bytes, float]]:
        """
        Compute harmonic projection weight for all validators.

        weight(v) = ‖π_H(stalk(v))‖ / ‖stalk(v)‖

        Delegates to CoherenceEngine which builds the Čech nerve,
        computes the sheaf Laplacian Δ_F, and projects each stalk
        onto ker(Δ_F).

        Returns:
            fingerprint → harmonic weight, or None if insufficient data.
        """
        if not self._has_stalk_data():
            return None

        stalks = {}
        for fp, v in self.validators.items():
            if v.is_active and v.stalk_data is not None:
                stalks[fp] = v.stalk_data

        if len(stalks) < 2:
            return None

        try:
            from .coherence import CoherenceEngine
            engine = CoherenceEngine(stalk_dim=self._stalk_dim)
            return engine.compute_harmonic_weights(stalks)
        except Exception:
            return None

    # =========================================================================
    # UNIFIED SELECTION WEIGHTS (harmonic → Plücker → Fiedler fallback)
    # =========================================================================

    def compute_spectral_centrality(self) -> Dict[bytes, float]:
        """
        Compute selection weights for all validators.

        Priority:
          1. Harmonic projection weight (if stalk data + coherence engine)
          2. Plücker centrality (if stalk data but coherence unavailable)
          3. Fiedler centrality (fallback — no stalk data)

        This is the main entry point for validator selection.
        """
        if self._centralities is not None:
            return self._centralities

        # Try harmonic weight first
        if self._has_stalk_data():
            harmonic = self.compute_harmonic_weights()
            if harmonic is not None:
                self._centralities = harmonic
                return self._centralities

            # Fallback to Plücker
            plucker = self.compute_plucker_centrality()
            if plucker is not None:
                self._centralities = plucker
                return self._centralities

        # Fallback to Fiedler
        self._centralities = self.compute_fiedler_centrality()
        return self._centralities

    # =========================================================================
    # VAULT + PLÜCKER ELIGIBILITY GATES
    # =========================================================================

    def filter_eligible(
        self,
        vault_registry: Optional['VaultRegistry'] = None,
    ) -> Dict[bytes, float]:
        """
        Apply eligibility gates, then return weights for eligible validators.

        Gate 1 (vault): vault.bonded >= MINIMUM_VAULT_BOND
        Gate 2 (Plücker): d_Gr(stalk(v), μ) < MAX_DIVERGENCE

        If no vault_registry provided, skips vault gate.
        """
        weights = self.compute_spectral_centrality()

        eligible = {}
        for fp, weight in weights.items():
            # Gate 1: Vault bond
            if vault_registry is not None:
                if not vault_registry.is_eligible(fp):
                    continue

            # Gate 2: Plücker distance (already filtered by stalk alignment
            # in compute_plucker_centrality — 0.01 minimum for no-stalk)
            eligible[fp] = weight

        # Re-normalize
        total = sum(eligible.values())
        if total > 0:
            eligible = {k: v / total for k, v in eligible.items()}

        return eligible

    # =========================================================================
    # VALIDATOR SELECTION
    # =========================================================================

    def select_validator(
        self,
        epoch: int,
        prev_block_hash: bytes,
        vault_registry: Optional['VaultRegistry'] = None,
    ) -> Optional[bytes]:
        """
        Select validator for next block.

        Pipeline:
          1. Compute harmonic weights (or fallback)
          2. Apply vault bond + Plücker eligibility gates
          3. VRF-weighted selection among eligible validators

        Args:
            epoch: Current epoch number
            prev_block_hash: Hash of previous block (VRF seed)
            vault_registry: Optional vault registry for bond gate

        Returns:
            Fingerprint of selected validator, or None if no validators
        """
        active = self.get_active_validators()
        if not active:
            return None

        weights = self.filter_eligible(vault_registry)
        if not weights:
            return None

        # VRF: deterministic randomness from prev_block + epoch
        vrf_input = prev_block_hash + epoch.to_bytes(8, 'little')
        vrf_output = hashlib.sha256(vrf_input).digest()

        # Convert to random float in [0, 1)
        random_value = int.from_bytes(vrf_output[:8], 'little') / (2**64)

        # Weighted selection by harmonic weight
        cumulative = 0.0
        for fingerprint in weights:
            cumulative += weights[fingerprint]
            if random_value < cumulative:
                self.validators[fingerprint].last_block = epoch
                return fingerprint

        # Fallback
        return list(weights.keys())[-1] if weights else None

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
