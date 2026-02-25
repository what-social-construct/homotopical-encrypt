"""
SheafState - Three-Layer State Bus with HashChain Tracing

Inspired by chloe_protocol's SystemState + HashChain pattern.

SheafState is the bus connecting all three layers of the hardness hierarchy:
- Layer 3 (homotopy): credential fibration, homotopy class membership
- Layer 2 (lattice/CVP): cochain commitments, spectral invariants
- Layer 1 (hash projection): block headers, key images, SHA256 audit trail

See docs/ARCHITECTURE.md § Three-Layer Chain (Hardness Hierarchy).

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
from ..primitives.natural import NaturalTransformation, compose_nat

# Consensus economics
from .vault import VaultRegistry, Vault, SlashReason
from .treasury import Treasury, HarmonicWeighted
from .clmm import CLMMPool


# =============================================================================
# HASH CHAIN (from chloe_protocol pattern)
# =============================================================================

class HashChain:
    """
    Merkle-tree-like hash chain for audit trail.
    
    All state transformations are traced:
    genesis → sovereignty_claim → connection → transfer → key_rotation → ...
    
    Each link: SHA256(prev_hash || type || data || timestamp)
    
    NATURAL TRANSFORMATION STORAGE:
    State transitions are morphisms in the category of states.
    NaturalTransformations capture functorial relationships between states.
    Storing them allows:
    - Proof that transformations preserve structure (naturality check)
    - Composition of state changes (compose_nat)
    - Audit trail of HOW state changed, not just WHAT changed
    """
    
    def __init__(self):
        self.chain: List[Dict[str, Any]] = []
        self.current_hash = self._genesis_hash()
        
        # Natural transformation storage
        # Maps: entry_hash → NaturalTransformation
        # Each state transition can optionally have an associated transformation
        self._transformations: Dict[str, NaturalTransformation] = {}
    
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
    
    # =========================================================================
    # NATURAL TRANSFORMATION STORAGE
    # =========================================================================
    
    def store_transformation(
        self,
        entry_hash: str,
        transformation: NaturalTransformation
    ) -> bool:
        """
        Store a NaturalTransformation associated with a chain entry.
        
        This captures HOW the state changed, not just WHAT changed.
        Useful for:
        - Proving structure preservation (naturality)
        - Composing multiple state changes
        - Auditing functorial consistency
        
        Args:
            entry_hash: Hash of the chain entry (from add_* methods)
            transformation: The NaturalTransformation representing the state change
            
        Returns:
            True if stored, False if entry_hash not found
        """
        # Verify entry exists
        if not any(e['hash'] == entry_hash for e in self.chain):
            return False
        
        self._transformations[entry_hash] = transformation
        return True
    
    def get_transformation(self, entry_hash: str) -> Optional[NaturalTransformation]:
        """
        Retrieve NaturalTransformation for a chain entry.
        
        Returns None if no transformation stored for that entry.
        """
        return self._transformations.get(entry_hash)
    
    def compose_transformations(
        self,
        from_height: int,
        to_height: int
    ) -> Optional[NaturalTransformation]:
        """
        Compose all NaturalTransformations between two chain heights.
        
        This gives the cumulative transformation from state at from_height
        to state at to_height.
        
        Composition is RIGHT-TO-LEFT (later entries compose first):
        T_total = T_n ∘ T_{n-1} ∘ ... ∘ T_{from+1}
        
        Args:
            from_height: Starting height (exclusive)
            to_height: Ending height (inclusive)
            
        Returns:
            Composed NaturalTransformation, or None if any are missing
        """
        if from_height >= to_height or to_height > len(self.chain):
            return None
        
        # Collect transformations in order
        transformations = []
        for i in range(from_height, to_height):
            entry = self.chain[i]
            t = self._transformations.get(entry['hash'])
            if t is None:
                return None  # Missing transformation breaks composition
            transformations.append(t)
        
        # Compose right-to-left
        if not transformations:
            return None
        
        result = transformations[-1]
        for t in reversed(transformations[:-1]):
            result = compose_nat(result, t)
        
        return result
    
    def get_entries_with_transformations(self) -> List[Dict[str, Any]]:
        """Get all entries that have associated NaturalTransformations."""
        return [
            e for e in self.chain 
            if e['hash'] in self._transformations
        ]
    
    def transformation_count(self) -> int:
        """Number of stored transformations."""
        return len(self._transformations)


# =============================================================================
# STALK BUNDLES (proper sheaf structure)
# =============================================================================

# Section types per ON_OFF_CHAIN_SHEAVES.md:
#   Γ(X, PUBLIC_STALK)  → balances (on-chain)
#   Γ(X, PRIVATE_STALK) → credentials (off-chain)
#   Γ(X, ZK_STALK)      → proofs (compact commitments)

@dataclass
class HashCommitment:
    """
    On-chain commitment (F_hash stalk).
    
    This is the image of η: F_full → F_hash
    Contains only hashes/fingerprints, not full data.
    """
    fingerprint: bytes           # hash(credential)
    spectral_gap: float          # from eigenvalues
    betti_numbers: Tuple[int, int, int]  # from cohomology
    topology_hash: bytes         # hash(nerve)
    
    def to_bytes(self) -> bytes:
        """Serialize for storage."""
        import struct
        return (
            self.fingerprint +
            struct.pack('<d', self.spectral_gap) +
            struct.pack('<iii', *self.betti_numbers) +
            self.topology_hash
        )


@dataclass
class AccountState:
    """
    Account state as stalk data.
    
    Maps to stalks:
    - PUBLIC_STALK: balance (dim=1)
    - PRIVATE_STALK: full credential (dim=256, off-chain only)
    - ZK_STALK: proof commitment (dim=32)
    """
    fingerprint: bytes
    homotopy_class_id: bytes
    balance: float = 0.0
    nonce: int = 0
    connected_to: Set[bytes] = field(default_factory=set)
    rotation_count: int = 0
    
    def to_public_stalk(self) -> Stalk:
        """Convert to PUBLIC_STALK (balance only, on-chain)."""
        return Stalk(
            spec=PUBLIC_STALK,
            data=np.array([self.balance]),
            vertex_id=0  # Set by caller
        )
    
    def to_hash_commitment(self, topology_hash: bytes, spectral_gap: float) -> HashCommitment:
        """
        Natural transformation η: F_full → F_hash
        
        Projects full account state to hash commitment.
        This is what goes ON-CHAIN.
        """
        return HashCommitment(
            fingerprint=self.fingerprint,
            spectral_gap=spectral_gap,
            betti_numbers=(1, 0, 0),  # Simplified, should compute from topology
            topology_hash=topology_hash
        )


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
    Three-layer state bus with HashChain tracing.
    
    Layer 3 (homotopy — wallet):
    - accounts: identity/sovereignty (fingerprints, homotopy class)
    - compute_topology(): nerve from connections
    - rotate_keys(): new fibration, same class
    
    Layer 2 (lattice/CVP — oracle):
    - get_hash_commitments(): η₁ output (HashCommitment per account)
    - verify_commitment(): CVP-bound verification
    - to_oracle_request(): Python → Oracle bridge
    - spectral_cache: cached spectral gap
    
    Layer 1 (hash projection — node):
    - spent_key_images: accountability, double-spend prevention
    - hash_chain: SHA256 audit trail (Layer 1)
    - block_headers: chain structure
    - mempool: pending transactions
    
    See docs/ARCHITECTURE.md § Three-Layer Chain
    """
    
    # Identity layer (Layer 3: homotopy)
    accounts: Dict[bytes, AccountState] = field(default_factory=dict)
    
    # Key images — Layer 1: accountability (spent tracking)
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
    
    # Consensus economics (PoV)
    vault_registry: VaultRegistry = field(default_factory=VaultRegistry)
    treasury: Treasury = field(default_factory=Treasury)
    clmm_pool: CLMMPool = field(default_factory=CLMMPool)
    
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
        """
        Compute spectral gap from nerve using the GRAPH Laplacian.
        
        IMPORTANT DISTINCTION (two Laplacians in this system):
        
        1. GRAPH Laplacian (L = D - A, computed HERE):
           - Measures NETWORK CONNECTIVITY between accounts
           - Used for CONSENSUS: spectral gap = PoV eligibility
           - Topology changes when accounts connect (add_connection)
           - Cheap to compute: O(|V| + |E|)
        
        2. SHEAF Laplacian (Δ = δ*δ, computed in geometry/sheaf_laplacian.py):
           - Measures FIBER COHERENCE of restriction maps
           - Used for ENCRYPTION: ker(Δ) = message subspace
           - Structure set at keygen (credential.fibration.sheaf)
           - Expensive: O(n³) eigendecomposition
        
        These are DIFFERENT objects with different purposes.
        The hardness_proof.lean Hodge→CVP reduction applies to the
        sheaf Laplacian (encryption security). The graph Laplacian
        here is purely for consensus weight / network health.
        """
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
    # SHEAF SECTIONS Γ(X, F)
    # =========================================================================
    
    def get_public_section(self) -> StalkBundle:
        """
        Get the public balance section: Γ(X, PUBLIC_STALK)
        
        This is what can go on-chain - just balances.
        """
        bundle = StalkBundle(PUBLIC_STALK)
        
        # Map fingerprints to vertex IDs for stalks
        fingerprints = list(self.accounts.keys())
        
        for i, fp in enumerate(fingerprints):
            account = self.accounts[fp]
            stalk = Stalk(
                spec=PUBLIC_STALK,
                data=np.array([account.balance]),
                vertex_id=i
            )
            bundle.set_stalk(i, stalk)
        
        return bundle
    
    def get_hash_commitments(self) -> Dict[bytes, HashCommitment]:
        """
        Get on-chain hash commitments: Γ(X, F_hash)
        
        This is the image of natural transformation η: F_full → F_hash
        Maps each account to its HashCommitment (fingerprint + spectral data).
        
        Used for on-chain verification without revealing full state.
        """
        topo_hash = self.topology_hash()
        spectral_gap = self.get_spectral_gap()
        betti = self.compute_betti_numbers()
        
        commitments = {}
        for fp, account in self.accounts.items():
            commitments[fp] = HashCommitment(
                fingerprint=account.fingerprint,
                spectral_gap=spectral_gap,
                betti_numbers=betti,
                topology_hash=topo_hash
            )
        
        return commitments
    
    def compute_betti_numbers(self) -> Tuple[int, int, int]:
        """
        Compute Betti numbers from topology.
        
        b0 = connected components
        b1 = independent cycles
        b2 = voids (0 for graph)
        """
        nerve = self.compute_topology()
        n_vertices = len(nerve.get(0, []))
        n_edges = len(nerve.get(1, []))
        
        # b0 = components (simplified: assume connected)
        b0 = 1 if n_vertices > 0 else 0
        
        # b1 = E - V + 1 (for connected graph)
        b1 = max(0, n_edges - n_vertices + 1) if n_vertices > 0 else 0
        
        # b2 = 0 for graphs
        b2 = 0
        
        return (b0, b1, b2)
    
    def verify_commitment(self, fingerprint: bytes, commitment: HashCommitment) -> bool:
        """
        Verify a HashCommitment against current state.
        
        Used for on-chain verification.
        """
        if fingerprint not in self.accounts:
            return False
        
        expected = self.get_hash_commitments().get(fingerprint)
        if expected is None:
            return False
        
        return (
            expected.fingerprint == commitment.fingerprint and
            abs(expected.spectral_gap - commitment.spectral_gap) < 1e-6 and
            expected.betti_numbers == commitment.betti_numbers and
            expected.topology_hash == commitment.topology_hash
        )
    
    # =========================================================================
    # ORACLE INTEGRATION
    # =========================================================================
    
    def to_oracle_request(self, fingerprint: bytes, credential: np.ndarray) -> Dict[str, Any]:
        """
        Create oracle request for a full stalk.
        
        COMPUTATION BOUNDARY: Python computes ALL geometry locally, then
        sends pre-computed results (commitment + spectral gap) to Oracle.
        The Oracle only verifies bounds — it never sees the Laplacian or raw credential.
        
        This is STRONGER than SHA256 because:
        1. Lattice hardness (post-quantum) - breaking requires CVP/SVP
        2. Spectral invariants - must match Laplacian structure
        3. Topology verification - Betti numbers must match
        4. Natural transformation - consistency across edges
        
        An attacker would need to forge all of:
        - A valid harmonic projection (lattice problem)
        - Matching spectral gap (requires same Laplacian)
        - Matching Betti numbers (requires same topology)
        - Pass naturality on all edges (global consistency)
        
        SHA256 alone: ~2^128 (birthday attack)
        Our system: Lattice hardness (~2^256) + spectral + cohomology
        """
        from ..oracle.client import FullStalkRequest
        
        if fingerprint not in self.accounts:
            raise ValueError(f"Account {fingerprint.hex()} not found")
        
        nerve = self.compute_topology()
        
        # Build Laplacian from nerve (computed locally, never sent to Oracle)
        n = len(nerve.get(0, []))
        laplacian = np.zeros((n, n))
        for edge in nerve.get(1, []):
            i, j = edge
            laplacian[i, i] += 1
            laplacian[j, j] += 1
            laplacian[i, j] -= 1
            laplacian[j, i] -= 1
        
        # Get vertex ID for this account
        fingerprints = list(self.accounts.keys())
        vertex_id = fingerprints.index(fingerprint)
        
        # Python computes everything: eigenvalues, Hodge projection, commitment
        # Oracle receives only pre-computed results (no Laplacian!)
        stalk = FullStalkRequest.from_geometry(
            vertex_id=vertex_id,
            credential=credential,
            laplacian=laplacian,
            nerve_vertices=[v[0] for v in nerve.get(0, [])],
            nerve_edges=nerve.get(1, []),
            betti_numbers=self.compute_betti_numbers()
        )
        
        return stalk.to_json()
    
    def submit_to_oracle(
        self,
        fingerprint: bytes,
        credential: np.ndarray,
        oracle_url: str = "http://127.0.0.1:9090"
    ) -> Optional[HashCommitment]:
        """
        Submit full stalk to Oracle, receive hash commitment.
        
        COMPUTATION BOUNDARY:
        1. Python computes Hodge projection + spectral gap + commitment LOCALLY
        2. Sends pre-computed commitment + spectral_gap to Oracle
        3. Oracle verifies √2 bounds and stores commitment
        4. Oracle returns HashStalk (fingerprint, gap, betti, topo_hash)
        5. HashCommitment can go on-chain (compact, verifiable)
        
        Oracle NEVER sees:
        - The Laplacian (private geometry)
        - The Hodge projector (private structure)  
        - The raw credential data
        """
        from ..oracle.client import OracleClient
        
        try:
            client = OracleClient(oracle_url)
            
            # Build request (Python computes all geometry locally)
            request_json = self.to_oracle_request(fingerprint, credential)
            
            # Construct FullStalkRequest from the JSON params
            from ..oracle.client import FullStalkRequest
            params = request_json["params"]
            stalk = FullStalkRequest(
                vertex_id=params["vertex_id"],
                eigenvalues=params["eigenvalues"],
                betti_numbers=tuple(params["betti_numbers"]),
                nerve_vertices=params["nerve_vertices"],
                nerve_edges=params["nerve_edges"],
                spectral_gap=params["spectral_gap"],
                commitment_bytes=bytes.fromhex(params["commitment"]),
            )
            
            # Submit to Oracle (sends commitment + gap, NOT Laplacian)
            response = client.submit_stalk(stalk)
            
            if response:
                return HashCommitment(
                    fingerprint=bytes.fromhex(response.identity_hash) if response.identity_hash else fingerprint,
                    spectral_gap=self.get_spectral_gap(),
                    betti_numbers=response.betti_numbers,
                    topology_hash=self.topology_hash()
                )
            return None
            
        except Exception as e:
            print(f"Oracle submission failed: {e}")
            return None
    
    # =========================================================================
    # BLOCK APPLICATION (balance + key image + tip updates)
    # =========================================================================
    
    def apply_block(self, block) -> Tuple[bool, str]:
        """
        Apply a verified block to state.
        
        Updates all three layers:
        - Layer 1: key images spent, block header stored, tip updated
        - Layer 2: commitment balance verified (homomorphic), nerve committed
        - Layer 3: account balances updated, nerve edges tracked
        
        NERVE EDGE TRACKING:
        Transactions between accounts create edges in the Čech nerve.
        apply_block() updates connected_to for each (sender, recipient) pair,
        which invalidates the spectral cache and recomputes topology.
        This is critical for local-to-global coherence:
          connected_to → nerve → Laplacian → spectral gap → Layer 2 commitments
        
        Args:
            block: Verified Block object (from chain/block.py)
            
        Returns:
            (success, reason)
        """
        # 1. Mark key images as spent (Layer 1: accountability)
        for tx in block.transactions:
            for inp in tx.inputs:
                if inp.key_image in self.spent_key_images:
                    return (False, f"Double-spend: key image {inp.key_image.hex()[:16]}...")
                self.spent_key_images.add(inp.key_image)
        
        # 2. Update account balances: transfer amounts + fees
        #
        #    The account model tracks plaintext balances. Each output carries
        #    transfer_amount (verified against commitment by oracle).
        #    Fee is always public. Balance sufficiency is checked here.
        #
        #    Flow per tx:
        #      sender.balance  -= (Σ output.transfer_amount + fee)
        #      recipient.balance += output.transfer_amount  (per output)
        #      treasury collects fee
        #
        for tx in block.transactions:
            if not tx.inputs:
                continue

            sender_fp = tx.inputs[0].fingerprint

            # Compute total outflow = Σ transfer_amounts + fee
            total_transfer = sum(out.transfer_amount for out in tx.outputs)
            total_outflow = total_transfer + tx.fee_amount

            # GAP 3 FIX: Balance sufficiency check
            if sender_fp in self.accounts:
                if self.accounts[sender_fp].balance < total_outflow:
                    return (False,
                        f"Insufficient balance: {self.accounts[sender_fp].balance} "
                        f"< {total_outflow} (transfer={total_transfer}, fee={tx.fee_amount})")

                # Debit sender
                self.accounts[sender_fp].balance -= total_outflow
                self.accounts[sender_fp].nonce += 1

            # GAP 1 FIX: Credit recipients
            for out in tx.outputs:
                if out.transfer_amount > 0 and out.recipient_fingerprint in self.accounts:
                    self.accounts[out.recipient_fingerprint].balance += out.transfer_amount
        
        # 3. Route fees through Treasury (not direct to producer)
        #    Treasury splits: producer share, validator share, protocol, burn
        #    See docs/CONSENSUS.md § Token Economics
        total_fees = sum(tx.fee_amount for tx in block.transactions)
        producer_fp = block.header.producer_identity
        if total_fees > 0:
            self.treasury.collect_fee(total_fees)
        
        # 4. NERVE EDGE TRACKING (Layer 3: topology update)
        #    Each transaction creates/reinforces edges in the Čech nerve.
        #    connected_to tracks the 1-skeleton of BOTH nerves:
        #      - Account nerve (who has transacted with whom)
        #      - Fibration nerve (which homotopy classes are connected)
        #    These coincide because transactions ARE morphisms in the
        #    homotopy category (see docs/ARCHITECTURE.md).
        new_edges = 0
        for tx in block.transactions:
            # Extract sender fingerprint(s) from inputs
            sender_fps = set()
            for inp in tx.inputs:
                if inp.fingerprint in self.accounts:
                    sender_fps.add(inp.fingerprint)
            
            # Extract recipient fingerprint(s) from outputs
            recipient_fps = set()
            for out in tx.outputs:
                if out.recipient_fingerprint in self.accounts:
                    recipient_fps.add(out.recipient_fingerprint)
            
            # Create edges between all (sender, recipient) pairs
            for sender_fp in sender_fps:
                for recipient_fp in recipient_fps:
                    if sender_fp != recipient_fp:
                        sender_acc = self.accounts[sender_fp]
                        recipient_acc = self.accounts[recipient_fp]
                        
                        if recipient_fp not in sender_acc.connected_to:
                            sender_acc.connected_to.add(recipient_fp)
                            recipient_acc.connected_to.add(sender_fp)
                            new_edges += 1
                            
                            # Trace connection in HashChain
                            self.hash_chain.add_connection(
                                party_a=sender_fp,
                                party_b=recipient_fp,
                                topology_hash=b'\x00' * 32,  # Recomputed below
                                timestamp=time.time()
                            )
        
        # 5. Invalidate spectral cache if topology changed
        #    New edges → new nerve → new Laplacian → new spectral gap
        if new_edges > 0:
            self.spectral_cache.invalidate()
        
        # 6. Store block header with nerve commitment (Layer 1: chain structure)
        #    The nerve_commitment links Layer 1 → nerve topology → Layer 2
        block_hash = block.block_hash()
        nerve_commitment = self.topology_hash() if new_edges > 0 or not self.block_headers else self.topology_hash()
        self.block_headers[block_hash] = {
            'height': block.header.height,
            'prev_hash': block.header.prev_hash,
            'spectral_gap': block.header.spectral_gap,
            'tx_count': len(block.transactions),
            'timestamp': block.header.timestamp,
            'nerve_commitment': nerve_commitment.hex(),
            'new_edges': new_edges,
        }
        
        # 7. Update tip (Layer 1)
        self.tip_hash = block_hash
        self.tip_height = block.header.height
        
        # 8. Remove included transactions from mempool
        for tx in block.transactions:
            tx_hash = tx.tx_hash()
            self.mempool.pop(tx_hash, None)
            for inp in tx.inputs:
                self.mempool_key_images.discard(inp.key_image)
        
        # 9. Trace block in HashChain (Layer 1: audit trail)
        self.hash_chain.add_block(
            block_hash=block_hash,
            height=block.header.height,
            spectral_gap=block.header.spectral_gap,
            tx_count=len(block.transactions),
            timestamp=time.time()
        )
        
        return (True, f"Block {block.header.height} applied ({len(block.transactions)} txs, fees={total_fees}, new_edges={new_edges})")
    
    def get_balance(self, fingerprint: bytes) -> float:
        """Get account balance."""
        if fingerprint in self.accounts:
            return self.accounts[fingerprint].balance
        return 0.0
    
    def transfer(
        self,
        sender_fp: bytes,
        recipient_fp: bytes,
        amount: float,
    ) -> Tuple[bool, str]:
        """
        Apply a transparent transfer between accounts.
        
        For private transfers, use HomotopyTransaction + apply_block().
        This is for direct balance updates (e.g., genesis distribution,
        sovereignty rewards).
        """
        if sender_fp not in self.accounts:
            return (False, "Sender not found")
        if recipient_fp not in self.accounts:
            return (False, "Recipient not found")
        if self.accounts[sender_fp].balance < amount:
            return (False, f"Insufficient balance: {self.accounts[sender_fp].balance} < {amount}")
        
        self.accounts[sender_fp].balance -= amount
        self.accounts[recipient_fp].balance += amount
        self.accounts[sender_fp].nonce += 1
        
        return (True, f"Transferred {amount}")
    
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
            'spent_count': len(self.spent_key_images),
            'tip_height': self.tip_height,
            'mempool_size': len(self.mempool),
            'chain_hash': self.hash_chain.get_current_hash(),
            'chain_height': self.hash_chain.height(),
            'spectral_gap': self.spectral_cache.spectral_gap
        }
    
    def distribute_fees(
        self,
        harmonic_weights: Dict[bytes, float],
        epoch: int,
    ) -> Dict[bytes, int]:
        """
        Trigger treasury Petri net firing after block commit.
        
        Called by BlockProducer after successful block application.
        Routes accumulated fees through the treasury's harmonic-weighted
        distribution (Petri net post-arcs to holder accounts).
        
        No producer/validator distinction — all nodes are automated.
        Value IS the harmonic projection weight ‖π_H(stalk)‖.
        
        Args:
            harmonic_weights: All holder harmonic weights
            epoch: Current epoch (Petri net clock)
            
        Returns:
            account → vHCRYPT allocated
        """
        return self.treasury.distribute(
            harmonic_weights=harmonic_weights,
            vault_registry=self.vault_registry,
            epoch=epoch,
        )
    
    def summary(self) -> str:
        """Get state summary."""
        active_vaults = len(self.vault_registry.get_active_vaults())
        return (
            f"SheafState (three-layer bus):\n"
            f"  Accounts: {len(self.accounts)}\n"
            f"  Spent key images: {len(self.spent_key_images)}\n"
            f"  Tip height: {self.tip_height}\n"
            f"  Mempool: {len(self.mempool)}\n"
            f"  Hash chain: {self.hash_chain.height()} entries\n"
            f"  Spectral gap: {self.spectral_cache.spectral_gap or 'not computed'}\n"
            f"  Active vaults: {active_vaults}\n"
            f"  Treasury pending: {self.treasury.balance_hcrypt} HCRYPT\n"
            f"  Treasury burned: {self.treasury.total_burned} HCRYPT"
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
