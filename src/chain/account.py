"""
Account State - Sovereignty & Identity Layer

Dual State Model:
- UTXO layer: Private transfers (ring signatures, key images)
- Account layer: Identity/sovereignty (spectral fingerprints, topology)

This file implements the Account layer for:
- Self-sovereign identity (no KYC)
- Connection topology management
- Homotopy class tracking (key rotation)

The two layers are complementary:
- Spend coins → UTXO layer (state.py)
- Create identity/connections → Account layer (this file)
"""

from dataclasses import dataclass, field
from typing import Dict, List, Set, Optional, Tuple
from enum import Enum
import numpy as np
import hashlib
import time

from ..primitives.homotopy import (
    HomotopyInvariants,
    HomotopyClass,
    HomotopyEquivalence,
    verify_equivalence,
)


class AccountStatus(Enum):
    """Status of a sovereign account."""
    PENDING = "pending"      # Sovereignty claim submitted, not yet confirmed
    ACTIVE = "active"        # Confirmed sovereign identity
    SUSPENDED = "suspended"  # Temporarily suspended (e.g., security issue)
    REVOKED = "revoked"      # Permanently revoked (by owner)


@dataclass
class SovereignAccount:
    """
    A self-sovereign identity on the chain.
    
    Identity = spectral fingerprint (not tied to any authority)
    
    Contains:
    - fingerprint: The public identity (hash of spectral invariants)
    - homotopy_class: The equivalence class (enables key rotation)
    - topology: Current connection topology (who they connect to)
    - nonce: Transaction counter for ordering
    - status: Account lifecycle state
    """
    # Identity (immutable once created)
    fingerprint: bytes                    # SHA256 of spectral invariants
    homotopy_class_id: bytes             # Identifies the equivalence class
    
    # Topology (can change via connection transactions)
    topology_hash: bytes                  # Current topology structure
    connected_fingerprints: Set[bytes] = field(default_factory=set)
    
    # State
    status: AccountStatus = AccountStatus.ACTIVE
    nonce: int = 0
    
    # Metadata
    created_height: int = 0
    created_timestamp: int = 0
    last_active_height: int = 0
    
    # Key rotation history (fingerprint stays same, keys change)
    rotation_count: int = 0
    last_rotation_height: int = 0
    
    def account_id(self) -> bytes:
        """Unique account identifier (same as fingerprint)."""
        return self.fingerprint
    
    def can_rotate_keys(self, new_class_id: bytes) -> bool:
        """
        Check if key rotation is valid.
        
        Key rotation is valid if new keys are in SAME homotopy class.
        """
        return self.homotopy_class_id == new_class_id
    
    def is_connected_to(self, other_fingerprint: bytes) -> bool:
        """Check if connected to another account."""
        return other_fingerprint in self.connected_fingerprints
    
    def increment_nonce(self):
        """Increment nonce after transaction."""
        self.nonce += 1


@dataclass
class Connection:
    """
    A connection between two sovereign accounts.
    
    Connections enable:
    - Direct transfers (no intermediary)
    - Multi-party agreements
    - Shared topology
    """
    party_a: bytes            # Fingerprint of party A
    party_b: bytes            # Fingerprint of party B
    topology_hash: bytes      # Shared connection topology
    
    # Status
    status: str = "active"    # "pending", "active", "terminated"
    
    # Timestamps
    created_height: int = 0
    created_timestamp: int = 0
    
    def connection_id(self) -> bytes:
        """Unique connection identifier."""
        # Sorted to ensure A-B and B-A give same ID
        sorted_parties = sorted([self.party_a, self.party_b])
        return hashlib.sha256(
            sorted_parties[0] + sorted_parties[1]
        ).digest()
    
    def involves(self, fingerprint: bytes) -> bool:
        """Check if this connection involves a fingerprint."""
        return fingerprint in (self.party_a, self.party_b)
    
    def other_party(self, my_fingerprint: bytes) -> Optional[bytes]:
        """Get the other party's fingerprint."""
        if my_fingerprint == self.party_a:
            return self.party_b
        elif my_fingerprint == self.party_b:
            return self.party_a
        return None


@dataclass
class AccountState:
    """
    Global account state (sovereignty layer).
    
    Tracks:
    - All sovereign accounts
    - All connections between accounts
    - Pending sovereignty claims
    
    This runs alongside ChainState (UTXO layer).
    """
    
    # Accounts by fingerprint
    accounts: Dict[bytes, SovereignAccount] = field(default_factory=dict)
    
    # Connections by connection_id
    connections: Dict[bytes, Connection] = field(default_factory=dict)
    
    # Pending sovereignty claims (not yet confirmed)
    pending_claims: Dict[bytes, SovereignAccount] = field(default_factory=dict)
    
    # Index: homotopy_class_id → list of fingerprints
    # (for finding accounts in same equivalence class)
    class_index: Dict[bytes, Set[bytes]] = field(default_factory=dict)
    
    def __init__(self):
        self.accounts = {}
        self.connections = {}
        self.pending_claims = {}
        self.class_index = {}
    
    # =========================================================================
    # SOVEREIGNTY OPERATIONS
    # =========================================================================
    
    def submit_sovereignty_claim(
        self,
        fingerprint: bytes,
        homotopy_invariants: HomotopyInvariants,
        topology_hash: bytes,
        block_height: int,
        timestamp: int
    ) -> Tuple[bool, str]:
        """
        Submit a sovereignty claim (create new identity).
        
        This is the NO-KYC identity creation.
        """
        # Check if fingerprint already exists
        if fingerprint in self.accounts:
            return (False, "Fingerprint already registered")
        
        if fingerprint in self.pending_claims:
            return (False, "Claim already pending")
        
        # Create homotopy class
        hclass = HomotopyClass(homotopy_invariants)
        
        # Create pending account
        account = SovereignAccount(
            fingerprint=fingerprint,
            homotopy_class_id=hclass.class_id,
            topology_hash=topology_hash,
            status=AccountStatus.PENDING,
            created_height=block_height,
            created_timestamp=timestamp
        )
        
        self.pending_claims[fingerprint] = account
        return (True, "Sovereignty claim submitted")
    
    def confirm_sovereignty(
        self,
        fingerprint: bytes,
        block_height: int
    ) -> Tuple[bool, str]:
        """
        Confirm a pending sovereignty claim (after block confirmation).
        """
        if fingerprint not in self.pending_claims:
            return (False, "No pending claim for fingerprint")
        
        account = self.pending_claims[fingerprint]
        account.status = AccountStatus.ACTIVE
        account.last_active_height = block_height
        
        # Move to active accounts
        self.accounts[fingerprint] = account
        del self.pending_claims[fingerprint]
        
        # Update class index
        if account.homotopy_class_id not in self.class_index:
            self.class_index[account.homotopy_class_id] = set()
        self.class_index[account.homotopy_class_id].add(fingerprint)
        
        return (True, "Sovereignty confirmed")
    
    def get_account(self, fingerprint: bytes) -> Optional[SovereignAccount]:
        """Get account by fingerprint."""
        return self.accounts.get(fingerprint)
    
    def account_exists(self, fingerprint: bytes) -> bool:
        """Check if account exists."""
        return fingerprint in self.accounts
    
    # =========================================================================
    # CONNECTION OPERATIONS
    # =========================================================================
    
    def create_connection(
        self,
        party_a: bytes,
        party_b: bytes,
        topology_hash: bytes,
        block_height: int,
        timestamp: int
    ) -> Tuple[bool, str]:
        """
        Create a connection between two accounts.
        """
        # Both parties must exist
        if party_a not in self.accounts:
            return (False, f"Party A not found: {party_a.hex()[:16]}...")
        if party_b not in self.accounts:
            return (False, f"Party B not found: {party_b.hex()[:16]}...")
        
        # Create connection
        conn = Connection(
            party_a=party_a,
            party_b=party_b,
            topology_hash=topology_hash,
            status="active",
            created_height=block_height,
            created_timestamp=timestamp
        )
        
        conn_id = conn.connection_id()
        
        # Check if already exists
        if conn_id in self.connections:
            return (False, "Connection already exists")
        
        # Add connection
        self.connections[conn_id] = conn
        
        # Update accounts
        self.accounts[party_a].connected_fingerprints.add(party_b)
        self.accounts[party_b].connected_fingerprints.add(party_a)
        
        return (True, "Connection created")
    
    def get_connection(self, party_a: bytes, party_b: bytes) -> Optional[Connection]:
        """Get connection between two parties."""
        sorted_parties = sorted([party_a, party_b])
        conn_id = hashlib.sha256(
            sorted_parties[0] + sorted_parties[1]
        ).digest()
        return self.connections.get(conn_id)
    
    def get_connections_for(self, fingerprint: bytes) -> List[Connection]:
        """Get all connections for an account."""
        return [
            conn for conn in self.connections.values()
            if conn.involves(fingerprint)
        ]
    
    # =========================================================================
    # KEY ROTATION
    # =========================================================================
    
    def rotate_keys(
        self,
        fingerprint: bytes,
        new_invariants: HomotopyInvariants,
        block_height: int
    ) -> Tuple[bool, str]:
        """
        Rotate keys for an account.
        
        Valid iff new keys are in SAME homotopy class.
        """
        if fingerprint not in self.accounts:
            return (False, "Account not found")
        
        account = self.accounts[fingerprint]
        
        # Compute new homotopy class
        new_class = HomotopyClass(new_invariants)
        
        # Must be same equivalence class
        if not account.can_rotate_keys(new_class.class_id):
            return (False, "New keys not in same homotopy class")
        
        # Update rotation tracking
        account.rotation_count += 1
        account.last_rotation_height = block_height
        account.last_active_height = block_height
        
        return (True, f"Keys rotated (rotation #{account.rotation_count})")
    
    # =========================================================================
    # HOMOTOPY CLASS QUERIES
    # =========================================================================
    
    def get_accounts_in_class(self, class_id: bytes) -> Set[bytes]:
        """Get all accounts in a homotopy class."""
        return self.class_index.get(class_id, set())
    
    def are_same_class(self, fp1: bytes, fp2: bytes) -> bool:
        """Check if two accounts are in the same homotopy class."""
        acc1 = self.accounts.get(fp1)
        acc2 = self.accounts.get(fp2)
        
        if not acc1 or not acc2:
            return False
        
        return acc1.homotopy_class_id == acc2.homotopy_class_id
    
    # =========================================================================
    # SUMMARY
    # =========================================================================
    
    def summary(self) -> str:
        """Get account state summary."""
        return (
            f"AccountState:\n"
            f"  Active accounts: {len(self.accounts)}\n"
            f"  Pending claims: {len(self.pending_claims)}\n"
            f"  Connections: {len(self.connections)}\n"
            f"  Homotopy classes: {len(self.class_index)}"
        )


# =============================================================================
# COMBINED DUAL STATE
# =============================================================================

@dataclass
class DualState:
    """
    Combined UTXO + Account state.
    
    This is the complete chain state with both layers:
    - utxo_state: ChainState (from state.py)
    - account_state: AccountState (sovereignty layer)
    """
    from .state import ChainState
    
    utxo_state: 'ChainState'
    account_state: AccountState
    
    @classmethod
    def create(cls) -> 'DualState':
        """Create new dual state."""
        from .state import ChainState
        return cls(
            utxo_state=ChainState(),
            account_state=AccountState()
        )
    
    def summary(self) -> str:
        """Combined state summary."""
        return (
            f"=== UTXO Layer ===\n"
            f"{self.utxo_state.summary()}\n\n"
            f"=== Account Layer ===\n"
            f"{self.account_state.summary()}"
        )


# =============================================================================
# TEST
# =============================================================================

if __name__ == "__main__":
    import secrets
    
    print("=" * 60)
    print("ACCOUNT STATE TEST")
    print("=" * 60)
    
    # Create account state
    state = AccountState()
    print(f"\n1. Initial state:\n{state.summary()}")
    
    # Create mock homotopy invariants
    nerve = {0: [(0,), (1,)], 1: [(0,1)], 2: []}
    inv1 = HomotopyInvariants.from_nerve(nerve)
    inv2 = HomotopyInvariants.from_nerve(nerve)  # Same class
    
    # Submit sovereignty claims
    print("\n2. Sovereignty claims:")
    fp1 = hashlib.sha256(b"alice").digest()
    fp2 = hashlib.sha256(b"bob").digest()
    
    ok, msg = state.submit_sovereignty_claim(
        fp1, inv1, inv1.topology_hash, 0, int(time.time())
    )
    print(f"   Alice claim: {ok} - {msg}")
    
    ok, msg = state.submit_sovereignty_claim(
        fp2, inv2, inv2.topology_hash, 0, int(time.time())
    )
    print(f"   Bob claim: {ok} - {msg}")
    
    # Confirm sovereignty
    print("\n3. Confirming sovereignty:")
    state.confirm_sovereignty(fp1, 1)
    state.confirm_sovereignty(fp2, 1)
    print(state.summary())
    
    # Check homotopy class
    print("\n4. Homotopy class check:")
    print(f"   Alice & Bob same class: {state.are_same_class(fp1, fp2)}")
    
    # Create connection
    print("\n5. Creating connection:")
    ok, msg = state.create_connection(
        fp1, fp2, inv1.topology_hash, 2, int(time.time())
    )
    print(f"   Connection: {ok} - {msg}")
    
    # Check connection
    alice_acc = state.get_account(fp1)
    print(f"   Alice connected to Bob: {alice_acc.is_connected_to(fp2)}")
    
    # Key rotation
    print("\n6. Key rotation:")
    new_inv = HomotopyInvariants.from_nerve(nerve)  # Same topology = same class
    ok, msg = state.rotate_keys(fp1, new_inv, 3)
    print(f"   Rotation: {ok} - {msg}")
    print(f"   Alice rotation count: {state.get_account(fp1).rotation_count}")
    
    print("\n" + "=" * 60)
    print("✅ ACCOUNT STATE (SOVEREIGNTY LAYER) WORKING")
    print("=" * 60)
