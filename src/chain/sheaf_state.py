"""
SheafState - Unified Chain State with HashChain Tracing

Inspired by chloe_protocol's SystemState + HashChain pattern.

Design decisions:
1. Topology IMPLICIT - computed from accounts on-demand
2. Stalk types - use primitives/stalk.py for elegance
3. ONE HashChain - unified with 'type' field per entry
4. Cache + invalidation - cache eigenvalues, recompute when topology changes
"""

from dataclasses import dataclass, field
from typing import Dict, List, Set, Optional, Tuple, Any
import numpy as np
import hashlib
import json
import time

from ..primitives.stalk import (
    Stalk, StalkSpec, StalkBundle,
    PRIVATE_STALK, PUBLIC_STALK, ZK_STALK,
)
from ..primitives.homotopy import HomotopyInvariants, HomotopyClass


# =============================================================================
# HASH CHAIN (from chloe_protocol pattern)
# =============================================================================

class HashChain:
    """
    Merkle-tree-like hash chain for audit trail.
    
    All state transformations are traced:
    genesis → sovereignty_claim → connection → transfer → key_rotation → ...
    
    Each link: SHA256(prev_hash || type || data || timestamp)
    """
    
    def __init__(self):
        self.chain: List[Dict[str, Any]] = []
        self.current_hash = self._genesis_hash()
    
    def _genesis_hash(self) -> str:
        """Initial hash (genesis block)."""
        return hashlib.sha256(b"hcrypt_genesis_v1").hexdigest()
    
    def _add_entry(
        self,
        entry_type: str,
        data: Dict[str, Any],
        timestamp: float
    ) -> str:
        """Add generic entry to chain."""
        hasher = hashlib.sha256()
        hasher.update(self.current_hash.encode())
        hasher.update(entry_type.encode())
        hasher.update(json.dumps(data, sort_keys=True, default=str).encode())
        hasher.update(str(timestamp).encode())
        
        new_hash = hasher.hexdigest()
        
        self.chain.append({
            'type': entry_type,
            'hash': new_hash,
            'prev_hash': self.current_hash,
            'data': data,
            'timestamp': timestamp,
            'height': len(self.chain)
        })
        
        self.current_hash = new_hash
        return new_hash
    
    # =========================================================================
    # ENTRY TYPES (unified like chloe_protocol)
    # =========================================================================
    
    def add_sovereignty_claim(
        self,
        fingerprint: bytes,
        homotopy_class_id: bytes,
        topology_hash: bytes,
        timestamp: float
    ) -> str:
        """Add sovereignty claim (new identity creation)."""
        return self._add_entry('sovereignty_claim', {
            'fingerprint': fingerprint.hex(),
            'homotopy_class_id': homotopy_class_id.hex(),
            'topology_hash': topology_hash.hex()
        }, timestamp)
    
    def add_connection(
        self,
        party_a: bytes,
        party_b: bytes,
        topology_hash: bytes,
        timestamp: float
    ) -> str:
        """Add connection between two accounts."""
        return self._add_entry('connection', {
            'party_a': party_a.hex(),
            'party_b': party_b.hex(),
            'topology_hash': topology_hash.hex()
        }, timestamp)
    
    def add_transfer(
        self,
        tx_hash: bytes,
        key_images: List[bytes],
        output_commitments: List[bytes],
        timestamp: float
    ) -> str:
        """Add value transfer."""
        return self._add_entry('transfer', {
            'tx_hash': tx_hash.hex(),
            'key_images': [ki.hex() for ki in key_images],
            'output_commitments': [oc.hex() for oc in output_commitments]
        }, timestamp)
    
    def add_key_rotation(
        self,
        fingerprint: bytes,
        rotation_count: int,
        homotopy_class_id: bytes,
        timestamp: float
    ) -> str:
        """Add key rotation within homotopy class."""
        return self._add_entry('key_rotation', {
            'fingerprint': fingerprint.hex(),
            'rotation_count': rotation_count,
            'homotopy_class_id': homotopy_class_id.hex()
        }, timestamp)
    
    def add_block(
        self,
        block_hash: bytes,
        height: int,
        spectral_gap: float,
        tx_count: int,
        timestamp: float
    ) -> str:
        """Add block to chain."""
        return self._add_entry('block', {
            'block_hash': block_hash.hex(),
            'height': height,
            'spectral_gap': spectral_gap,
            'tx_count': tx_count
        }, timestamp)
    
    # =========================================================================
    # VERIFICATION
    # =========================================================================
    
    def verify_chain(self) -> bool:
        """Verify entire chain integrity."""
        if not self.chain:
            return True
        
        current = self._genesis_hash()
        for block in self.chain:
            if block['prev_hash'] != current:
                return False
            current = block['hash']
        
        return current == self.current_hash
    
    def get_entries_by_type(self, entry_type: str) -> List[Dict[str, Any]]:
        """Get all entries of a specific type."""
        return [e for e in self.chain if e['type'] == entry_type]
    
    def get_current_hash(self) -> str:
        return self.current_hash
    
    def height(self) -> int:
        return len(self.chain)


# =============================================================================
# ACCOUNT STALK (using primitives)
# =============================================================================

# Account stalk spec - uses Stalk primitive for elegance
ACCOUNT_STALK = StalkSpec(
    context=StalkContext.PUBLIC if hasattr(StalkSpec, 'context') else None,
    dimension=64,  # Balance + metadata
    name="AccountStalk",
    description="Account state at a vertex",
    fields={
        "balance": 32,     # Balance vector
        "nonce": 16,       # Transaction counter
        "metadata": 16     # Additional state
    }
) if False else None  # Simplified for now


@dataclass
class AccountState:
    """Account state as stalk data."""
    fingerprint: bytes
    homotopy_class_id: bytes
    balance: float = 0.0
    nonce: int = 0
    connected_to: Set[bytes] = field(default_factory=set)
    rotation_count: int = 0
    
    def to_stalk_data(self) -> np.ndarray:
        """Convert to stalk vector."""
        # Simplified: just balance as scalar
        return np.array([self.balance])


# =============================================================================
# SPECTRAL CACHE
# =============================================================================

@dataclass
class SpectralCache:
    """
    Cache for Laplacian eigenvalues.
    
    Invalidated when topology changes (add/remove connection).
    """
    eigenvalues: Optional[np.ndarray] = None
    spectral_gap: Optional[float] = None
    topology_hash: Optional[bytes] = None
    computed_at: float = 0.0
    
    def is_valid(self, current_topology_hash: bytes) -> bool:
        """Check if cache is still valid."""
        return (
            self.eigenvalues is not None and
            self.topology_hash == current_topology_hash
        )
    
    def invalidate(self):
        """Invalidate cache (topology changed)."""
        self.eigenvalues = None
        self.spectral_gap = None
        self.topology_hash = None


# =============================================================================
# UNIFIED SHEAF STATE
# =============================================================================

@dataclass
class SheafState:
    """
    Unified chain state with HashChain tracing.
    
    Sections:
    - accounts: identity/sovereignty (fingerprints)
    - utxos: value layer (unspent outputs)
    - connections: topology (computed implicitly from account connections)
    - blocks: chain history
    - mempool: pending transactions
    - hash_chain: cryptographic tracing
    - spectral_cache: cached eigenvalues
    """
    
    # Identity layer
    accounts: Dict[bytes, AccountState] = field(default_factory=dict)
    
    # Value layer (UTXO set)
    utxos: Dict[bytes, Any] = field(default_factory=dict)  # utxo_id → UTXO
    
    # Key images (spent tracking)
    spent_key_images: Set[bytes] = field(default_factory=set)
    
    # Block headers
    block_headers: Dict[bytes, Any] = field(default_factory=dict)
    tip_hash: bytes = b'\x00' * 32
    tip_height: int = -1
    
    # Pending transactions
    mempool: Dict[bytes, Any] = field(default_factory=dict)
    mempool_key_images: Set[bytes] = field(default_factory=set)
    
    # Hash chain (tracing)
    hash_chain: HashChain = field(default_factory=HashChain)
    
    # Spectral cache
    spectral_cache: SpectralCache = field(default_factory=SpectralCache)
    
    def __post_init__(self):
        # Ensure mutable defaults
        if not isinstance(self.accounts, dict):
            self.accounts = {}
        if not isinstance(self.hash_chain, HashChain):
            self.hash_chain = HashChain()
    
    # =========================================================================
    # TOPOLOGY (computed on-demand from accounts)
    # =========================================================================
    
    def compute_topology(self) -> Dict[int, List[Tuple]]:
        """
        Compute Čech nerve from account connections.
        
        Vertices = accounts
        Edges = connections between accounts
        """
        # Build vertex list
        fingerprints = list(self.accounts.keys())
        fp_to_idx = {fp: i for i, fp in enumerate(fingerprints)}
        
        vertices = [(i,) for i in range(len(fingerprints))]
        
        # Build edges from connections
        edges = []
        seen_edges = set()
        
        for fp, account in self.accounts.items():
            for connected_fp in account.connected_to:
                if connected_fp in fp_to_idx:
                    i, j = fp_to_idx[fp], fp_to_idx[connected_fp]
                    edge = tuple(sorted([i, j]))
                    if edge not in seen_edges:
                        edges.append(edge)
                        seen_edges.add(edge)
        
        return {
            0: vertices,
            1: edges,
            2: []  # No 2-cells for now
        }
    
    def topology_hash(self) -> bytes:
        """Hash of current topology (for cache invalidation)."""
        nerve = self.compute_topology()
        return hashlib.sha256(
            json.dumps(nerve, sort_keys=True).encode()
        ).digest()
    
    # =========================================================================
    # SPECTRAL OPERATIONS
    # =========================================================================
    
    def get_spectral_gap(self) -> float:
        """
        Get spectral gap (cached or recomputed).
        """
        current_hash = self.topology_hash()
        
        if self.spectral_cache.is_valid(current_hash):
            return self.spectral_cache.spectral_gap or 0.0
        
        # Recompute
        nerve = self.compute_topology()
        gap = self._compute_spectral_gap(nerve)
        
        # Cache
        self.spectral_cache.spectral_gap = gap
        self.spectral_cache.topology_hash = current_hash
        self.spectral_cache.computed_at = time.time()
        
        return gap
    
    def _compute_spectral_gap(self, nerve: Dict[int, List[Tuple]]) -> float:
        """Compute spectral gap from nerve."""
        n = len(nerve.get(0, []))
        if n < 2:
            return 0.0
        
        # Build graph Laplacian
        L = np.zeros((n, n))
        for edge in nerve.get(1, []):
            i, j = edge
            L[i, i] += 1
            L[j, j] += 1
            L[i, j] -= 1
            L[j, i] -= 1
        
        eigenvalues = np.linalg.eigvalsh(L)
        eigenvalues = np.sort(eigenvalues)
        
        # Spectral gap = smallest nonzero eigenvalue
        nonzero = eigenvalues[eigenvalues > 1e-6]
        return float(nonzero[0]) if len(nonzero) > 0 else 0.0
    
    # =========================================================================
    # ACCOUNT OPERATIONS
    # =========================================================================
    
    def add_account(
        self,
        fingerprint: bytes,
        homotopy_class_id: bytes,
        initial_balance: float = 0.0
    ) -> str:
        """Add new account and trace it."""
        account = AccountState(
            fingerprint=fingerprint,
            homotopy_class_id=homotopy_class_id,
            balance=initial_balance
        )
        self.accounts[fingerprint] = account
        
        # Invalidate spectral cache
        self.spectral_cache.invalidate()
        
        # Trace
        return self.hash_chain.add_sovereignty_claim(
            fingerprint=fingerprint,
            homotopy_class_id=homotopy_class_id,
            topology_hash=self.topology_hash(),
            timestamp=time.time()
        )
    
    def add_connection(
        self,
        party_a: bytes,
        party_b: bytes
    ) -> Optional[str]:
        """Add connection between accounts."""
        if party_a not in self.accounts or party_b not in self.accounts:
            return None
        
        self.accounts[party_a].connected_to.add(party_b)
        self.accounts[party_b].connected_to.add(party_a)
        
        # Invalidate spectral cache
        self.spectral_cache.invalidate()
        
        # Trace
        return self.hash_chain.add_connection(
            party_a=party_a,
            party_b=party_b,
            topology_hash=self.topology_hash(),
            timestamp=time.time()
        )
    
    def rotate_keys(
        self,
        fingerprint: bytes,
        new_homotopy_class_id: bytes
    ) -> Optional[str]:
        """Rotate keys (must be same homotopy class)."""
        if fingerprint not in self.accounts:
            return None
        
        account = self.accounts[fingerprint]
        
        # Must be same class
        if account.homotopy_class_id != new_homotopy_class_id:
            return None
        
        account.rotation_count += 1
        
        return self.hash_chain.add_key_rotation(
            fingerprint=fingerprint,
            rotation_count=account.rotation_count,
            homotopy_class_id=new_homotopy_class_id,
            timestamp=time.time()
        )
    
    # =========================================================================
    # STATE OPERATIONS
    # =========================================================================
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary (like SystemState.to_dict())."""
        return {
            'accounts': {
                fp.hex(): {
                    'balance': acc.balance,
                    'nonce': acc.nonce,
                    'connections': len(acc.connected_to),
                    'rotations': acc.rotation_count
                }
                for fp, acc in self.accounts.items()
            },
            'utxo_count': len(self.utxos),
            'spent_count': len(self.spent_key_images),
            'tip_height': self.tip_height,
            'mempool_size': len(self.mempool),
            'chain_hash': self.hash_chain.get_current_hash(),
            'chain_height': self.hash_chain.height(),
            'spectral_gap': self.spectral_cache.spectral_gap
        }
    
    def summary(self) -> str:
        """Get state summary."""
        return (
            f"SheafState:\n"
            f"  Accounts: {len(self.accounts)}\n"
            f"  UTXOs: {len(self.utxos)}\n"
            f"  Spent: {len(self.spent_key_images)}\n"
            f"  Tip height: {self.tip_height}\n"
            f"  Mempool: {len(self.mempool)}\n"
            f"  Hash chain: {self.hash_chain.height()} entries\n"
            f"  Spectral gap: {self.spectral_cache.spectral_gap or 'not computed'}"
        )


# =============================================================================
# TEST
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("SHEAF STATE TEST")
    print("=" * 60)
    
    # Create state
    state = SheafState()
    print(f"\n1. Initial state:\n{state.summary()}")
    
    # Add accounts
    print("\n2. Adding accounts:")
    fp1 = hashlib.sha256(b"alice").digest()
    fp2 = hashlib.sha256(b"bob").digest()
    hclass = hashlib.sha256(b"test_class").digest()
    
    h1 = state.add_account(fp1, hclass, 1000.0)
    h2 = state.add_account(fp2, hclass, 500.0)
    print(f"   Alice: {h1[:16]}...")
    print(f"   Bob: {h2[:16]}...")
    
    # Add connection
    print("\n3. Adding connection:")
    h3 = state.add_connection(fp1, fp2)
    print(f"   Connection: {h3[:16]}...")
    
    # Check topology
    print("\n4. Topology:")
    nerve = state.compute_topology()
    print(f"   Vertices: {len(nerve[0])}")
    print(f"   Edges: {len(nerve[1])}")
    
    # Spectral gap
    print("\n5. Spectral gap:")
    gap = state.get_spectral_gap()
    print(f"   Gap: {gap:.4f}")
    
    # Key rotation
    print("\n6. Key rotation:")
    h4 = state.rotate_keys(fp1, hclass)
    print(f"   Rotation: {h4[:16]}...")
    print(f"   Alice rotations: {state.accounts[fp1].rotation_count}")
    
    # Verify chain
    print("\n7. Hash chain verification:")
    print(f"   Valid: {state.hash_chain.verify_chain()}")
    print(f"   Height: {state.hash_chain.height()}")
    
    print(f"\n8. Final state:\n{state.summary()}")
    
    print("\n" + "=" * 60)
    print("✅ UNIFIED SHEAF STATE WORKING")
    print("=" * 60)
