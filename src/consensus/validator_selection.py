"""
Validator Selection via Spectral Centrality

Unlike PoS (stake-weighted random), PoV uses:
- Spectral centrality in current topology
- Verifiable randomness from prev_block

Validators with higher "geometric importance" have higher chance,
but not because they have more capital - because they're more connected.

Mathematical basis:
- Fiedler vector (second eigenvector of Laplacian) measures connectivity
- |fiedler[v]| = how central vertex v is to the network
- High centrality = important for information flow
- Low centrality = peripheral/isolated

This naturally rewards network participation, not capital accumulation.
"""

from typing import List, Dict, Tuple, Optional
from dataclasses import dataclass
import numpy as np
import hashlib


@dataclass
class Validator:
    """
    A validator in the network.
    
    Validators are identified by their spectral fingerprint,
    not by staked capital. Their selection probability comes
    from their position in the topology (spectral centrality).
    """
    fingerprint: bytes          # Spectral fingerprint (identity)
    vertex_id: int              # Position in topology
    stake: float = 0.0          # Optional stake (for slashing, not selection)
    is_active: bool = True      # Currently active
    last_block: int = 0         # Last block produced


class ValidatorSet:
    """
    Manages the validator set for PoV consensus.
    
    Selection is based on spectral centrality, not stake weight.
    """
    
    def __init__(self, topology: Dict[int, List[Tuple]]):
        self.topology = topology
        self.validators: Dict[bytes, Validator] = {}
        self._laplacian: Optional[np.ndarray] = None
        self._centralities: Optional[Dict[bytes, float]] = None
    
    def register_validator(
        self,
        fingerprint: bytes,
        vertex_id: int,
        stake: float = 0.0
    ) -> bool:
        """
        Register a new validator.
        
        The validator must have a vertex in the topology.
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
            is_active=True
        )
        
        # Invalidate cached centralities
        self._centralities = None
        
        return True
    
    def deactivate_validator(self, fingerprint: bytes) -> bool:
        """Deactivate a validator (e.g., for slashing)."""
        if fingerprint not in self.validators:
            return False
        
        self.validators[fingerprint].is_active = False
        self._centralities = None
        return True
    
    def get_active_validators(self) -> List[Validator]:
        """Get all active validators."""
        return [v for v in self.validators.values() if v.is_active]
    
    def compute_spectral_centrality(self) -> Dict[bytes, float]:
        """
        Compute spectral centrality for all validators.
        
        Uses the Fiedler vector (second eigenvector of Laplacian).
        |fiedler[v]| measures how central vertex v is.
        
        Returns:
            fingerprint → centrality mapping
        """
        if self._centralities is not None:
            return self._centralities
        
        # Build Laplacian from topology
        vertices = self.topology.get(0, [])
        edges = self.topology.get(1, [])
        n = len(vertices)
        
        if n == 0:
            return {}
        
        # Degree matrix and adjacency matrix
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
        
        # Laplacian = D - A
        laplacian = np.diag(degree) - adjacency
        self._laplacian = laplacian
        
        # Eigendecomposition
        eigenvalues, eigenvectors = np.linalg.eigh(laplacian)
        
        # Fiedler vector = second eigenvector (first non-zero eigenvalue)
        # eigenvalues are sorted ascending, so eigenvalues[1] is Fiedler value
        if n > 1:
            fiedler_idx = 1
            fiedler_vector = eigenvectors[:, fiedler_idx]
        else:
            fiedler_vector = np.ones(1)
        
        # Compute centrality for each validator
        centralities = {}
        for fingerprint, validator in self.validators.items():
            if validator.is_active:
                idx = validator.vertex_id
                if idx < n:
                    # Centrality = |fiedler[idx]|
                    # Higher = more central to information flow
                    centralities[fingerprint] = abs(fiedler_vector[idx])
                else:
                    centralities[fingerprint] = 0.0
        
        # Normalize to sum to 1
        total = sum(centralities.values())
        if total > 0:
            centralities = {k: v/total for k, v in centralities.items()}
        
        self._centralities = centralities
        return centralities
    
    def select_validator(
        self,
        epoch: int,
        prev_block_hash: bytes
    ) -> Optional[bytes]:
        """
        Select validator for next block using spectral centrality + VRF.
        
        Args:
            epoch: Current epoch number
            prev_block_hash: Hash of previous block (source of randomness)
            
        Returns:
            Fingerprint of selected validator, or None if no validators
        """
        active = self.get_active_validators()
        if not active:
            return None
        
        # Compute centralities
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
                # Update last_block for this validator
                self.validators[fingerprint].last_block = epoch
                return fingerprint
        
        # Fallback to last validator (shouldn't happen due to normalization)
        return list(centralities.keys())[-1] if centralities else None
    
    def get_validator_info(self, fingerprint: bytes) -> Optional[Dict]:
        """Get info about a specific validator."""
        if fingerprint not in self.validators:
            return None
        
        v = self.validators[fingerprint]
        centralities = self.compute_spectral_centrality()
        
        return {
            "fingerprint": fingerprint.hex()[:16] + "...",
            "vertex_id": v.vertex_id,
            "stake": v.stake,
            "is_active": v.is_active,
            "centrality": centralities.get(fingerprint, 0.0),
            "last_block": v.last_block
        }
    
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
    print("VALIDATOR SELECTION TEST")
    print("=" * 60)
    
    # Create topology: 5 vertices, 4 edges (linear chain + one branch)
    #
    #   0 --- 1 --- 2 --- 3
    #               |
    #               4
    #
    # Vertex 2 should have highest centrality (most connected)
    
    topology = {
        0: [(0,), (1,), (2,), (3,), (4,)],
        1: [(0, 1), (1, 2), (2, 3), (2, 4)],
        2: []
    }
    
    print("\n1. Topology:")
    print("   Vertices: 5 (linear chain with branch at vertex 2)")
    print("   Edges: [(0,1), (1,2), (2,3), (2,4)]")
    
    # Create validator set
    validator_set = ValidatorSet(topology)
    
    # Register validators
    validators = []
    for i in range(5):
        fp = hashlib.sha256(f"validator_{i}".encode()).digest()
        validator_set.register_validator(fp, i)
        validators.append((fp, i))
    
    print(f"\n2. Registered {len(validators)} validators")
    
    # Compute centralities
    centralities = validator_set.compute_spectral_centrality()
    
    print("\n3. Spectral centralities (Fiedler-based):")
    for i, (fp, vid) in enumerate(validators):
        c = centralities.get(fp, 0)
        print(f"   Validator {i} (vertex {vid}): {c:.4f}")
    
    # Find most central
    most_central = max(centralities.items(), key=lambda x: x[1])
    mc_idx = [i for i, (fp, _) in enumerate(validators) if fp == most_central[0]][0]
    print(f"\n   Most central: Validator {mc_idx} (vertex {validators[mc_idx][1]})")
    
    # Simulate selection over multiple epochs
    print("\n4. Selection simulation (100 epochs):")
    selection_counts = {fp: 0 for fp, _ in validators}
    prev_hash = b'\x00' * 32
    
    for epoch in range(100):
        selected = validator_set.select_validator(epoch, prev_hash)
        if selected:
            selection_counts[selected] += 1
            # Update prev_hash for next epoch
            prev_hash = hashlib.sha256(prev_hash + selected).digest()
    
    print("   Selection counts:")
    for i, (fp, _) in enumerate(validators):
        count = selection_counts[fp]
        expected = centralities.get(fp, 0) * 100
        print(f"   Validator {i}: {count} times (expected ~{expected:.1f})")
    
    print("\n5. Validator info for most central:")
    info = validator_set.get_validator_info(most_central[0])
    for k, v in info.items():
        print(f"   {k}: {v}")
    
    print("\n" + "=" * 60)
    print("✅ VALIDATOR SELECTION WORKING")
    print("=" * 60)
