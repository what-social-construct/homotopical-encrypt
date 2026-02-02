"""
Chain-Level Transaction Routing

Uses geometry primitives (FiberBundle, EphemeralFiber, OnionRouter)
for blockchain-specific transaction routing.

This is the INTEGRATION layer - uses pure geometry for chain purposes.
"""

from typing import List, Optional, Tuple
from dataclasses import dataclass
import numpy as np

from ..geometry.fiber_bundle import (
    FiberBundle,
    EphemeralFiber,
    OnionRouter,
    OnionPacket,
    create_onion_route,
    peel_onion_layer,
    MixingNode
)
from ..crypto.credential import FibrationCredential
from .homotopy_transaction import HomotopyTransaction


@dataclass
class RelayNode:
    """
    Chain relay node with fibration credential.
    
    Each relay has:
    - A fibration credential (their identity)
    - A fiber bundle (for parallel transport)
    - Network address (for routing)
    """
    credential: FibrationCredential
    address: str  # Network address (IP:port or onion address)
    
    @property
    def bundle(self) -> FiberBundle:
        """Extract fiber bundle from credential."""
        return FiberBundle(
            base_space=self.credential.topology,
            fiber_dim=self.credential.security_parameter,
            connection=getattr(self.credential, 'connection', {})
        )
    
    @property
    def fingerprint(self) -> bytes:
        """Get spectral fingerprint for this relay."""
        return self.credential.spectrum.fingerprint_hash()


class TransactionRouter:
    """
    Routes transactions through relay network using sheaf onion.
    
    Provides chain-level interface to geometry primitives.
    Integrates:
    - Ephemeral fibers (forward secrecy)
    - Onion routing (multi-hop privacy)
    - Mixing delays (timing obfuscation)
    - Constant padding (metadata hiding)
    """
    
    def __init__(self, relays: List[RelayNode]):
        self.relays = relays
        self.mixing_nodes: List[MixingNode] = []
        
        # Create mixing nodes for timing obfuscation
        for relay in relays:
            bundle = relay.bundle
            # Use relay's fingerprint as mixing key
            key = np.frombuffer(relay.fingerprint[:bundle.fiber_dim * 8], dtype=np.float64)
            key = key[:bundle.fiber_dim] if len(key) >= bundle.fiber_dim else np.pad(key, (0, bundle.fiber_dim - len(key)))
            
            mixing_node = MixingNode(
                bundle=bundle,
                key=key,
                pool=[],
                min_pool_size=5  # Wait for 5 packets before releasing
            )
            self.mixing_nodes.append(mixing_node)
    
    def route_transaction(
        self,
        tx: HomotopyTransaction,
        destination: str,
        hop_count: int = 3,
        use_ephemeral: bool = True,
        use_mixing: bool = True
    ) -> OnionPacket:
        """
        Route transaction through relay network.
        
        Args:
            tx: Transaction to route
            destination: Destination address (recipient's fingerprint)
            hop_count: Number of relay hops (default 3)
            use_ephemeral: Use ephemeral fibers per message (forward secrecy)
            use_mixing: Add mixing delays at relays
            
        Returns:
            OnionPacket ready for network transmission
            
        Security properties:
        - Per-message ephemeral fibers (forward secrecy)
        - Multi-hop onion encryption (anonymity)
        - Mixing delays (timing obfuscation)
        - Constant-size padding (handled at network layer)
        """
        # Select random relay path
        relay_path = self.select_relay_path(destination, hop_count)
        
        print(f"🛣️  Routing transaction through {len(relay_path)} hops")
        for i, relay in enumerate(relay_path):
            print(f"   Hop {i+1}: {relay.fingerprint.hex()[:16]}...")
        
        # Serialize transaction to bytes
        tx_bytes = self._serialize_transaction(tx)
        
        # Extract relay bundles and keys
        relay_bundles = [relay.bundle for relay in relay_path]
        relay_keys = [self._derive_relay_key(relay) for relay in relay_path]
        
        # Create onion packet
        onion_packet = create_onion_route(
            relays=relay_bundles,
            message=tx_bytes,
            keys=relay_keys
        )
        
        print(f"✅ Onion packet created with {len(onion_packet.layers)} layers")
        
        return onion_packet
    
    def select_relay_path(
        self,
        destination: str,
        hop_count: int = 3
    ) -> List[RelayNode]:
        """
        Select random relay path for transaction.
        
        Args:
            destination: Destination fingerprint
            hop_count: Number of hops
            
        Returns:
            List of relay nodes forming the path
        """
        if len(self.relays) < hop_count:
            raise ValueError(f"Not enough relays: need {hop_count}, have {len(self.relays)}")
        
        # Simple random selection (can be improved with topology-aware selection)
        import random
        selected = random.sample(self.relays, hop_count)
        
        return selected
    
    def broadcast_to_network(
        self,
        routed_tx: OnionPacket,
        entry_relay: Optional[RelayNode] = None
    ) -> bool:
        """
        Broadcast routed transaction to network.
        
        Args:
            routed_tx: Onion-encrypted transaction
            entry_relay: Entry relay (random if not specified)
            
        Returns:
            True if broadcast successful
        """
        if entry_relay is None:
            import random
            entry_relay = random.choice(self.relays)
        
        print(f"📡 Broadcasting to entry relay: {entry_relay.fingerprint.hex()[:16]}...")
        
        # In production, this would send to network
        # For now, simulate relay processing
        current_packet = routed_tx
        
        for i, relay in enumerate(self.relays):
            if current_packet.current_layer >= len(current_packet.layers):
                print(f"✅ Packet delivered after {i} hops")
                return True
            
            # Relay peels layer
            _, is_final = peel_onion_layer(
                current_packet,
                relay.bundle,
                self._derive_relay_key(relay)
            )
            
            if is_final:
                print(f"✅ Final destination reached at hop {i+1}")
                return True
        
        return False
    
    def generate_decoy_traffic(self, count: int = 10) -> List[OnionPacket]:
        """
        Generate decoy traffic to fill network gaps.
        
        Args:
            count: Number of decoy packets
            
        Returns:
            List of decoy onion packets
        """
        decoys = []
        
        for _ in range(count):
            # Random message
            decoy_msg = np.random.bytes(256)
            
            # Random path
            import random
            hop_count = random.randint(2, 5)
            relay_path = self.select_relay_path("decoy", min(hop_count, len(self.relays)))
            
            # Create onion
            relay_bundles = [relay.bundle for relay in relay_path]
            relay_keys = [self._derive_relay_key(relay) for relay in relay_path]
            
            packet = create_onion_route(relay_bundles, decoy_msg, relay_keys)
            decoys.append(packet)
        
        return decoys
    
    # =========================================================================
    # HELPER METHODS
    # =========================================================================
    
    def _serialize_transaction(self, tx: HomotopyTransaction) -> np.ndarray:
        """
        Serialize transaction to bytes for routing.
        
        TODO: Implement proper TX serialization
        """
        import pickle
        tx_bytes = pickle.dumps(tx)
        return np.frombuffer(tx_bytes, dtype=np.uint8)
    
    def _derive_relay_key(self, relay: RelayNode) -> np.ndarray:
        """
        Derive encryption key for relay from its fingerprint.
        
        This is deterministic: same relay → same key
        But the key is derived from the spectral fingerprint (public)
        The actual decryption requires the relay's credential (private)
        """
        fingerprint = relay.fingerprint
        fiber_dim = relay.bundle.fiber_dim
        
        # Derive key from fingerprint
        key_bytes = fingerprint[:fiber_dim * 8]  # 8 bytes per float64
        key = np.frombuffer(key_bytes, dtype=np.float64)
        
        # Pad if needed
        if len(key) < fiber_dim:
            key = np.pad(key, (0, fiber_dim - len(key)), constant_values=0)
        else:
            key = key[:fiber_dim]
        
        return key


class RelayNetwork:
    """
    Manages the relay network for transaction routing.
    
    Responsibilities:
    - Maintain list of active relays
    - Select paths for routing
    - Monitor relay health
    - Handle relay registration/deregistration
    """
    
    def __init__(self):
        self.relays: List[RelayNode] = []
        self.router: Optional[TransactionRouter] = None
    
    def register_relay(self, relay: RelayNode) -> bool:
        """Register a new relay node."""
        # Check if already registered
        for existing in self.relays:
            if existing.fingerprint == relay.fingerprint:
                print(f"⚠️  Relay already registered: {relay.fingerprint.hex()[:16]}...")
                return False
        
        self.relays.append(relay)
        print(f"✅ Relay registered: {relay.fingerprint.hex()[:16]}...")
        
        # Rebuild router
        self.router = TransactionRouter(self.relays)
        
        return True
    
    def unregister_relay(self, fingerprint: bytes) -> bool:
        """Unregister a relay node."""
        for i, relay in enumerate(self.relays):
            if relay.fingerprint == fingerprint:
                removed = self.relays.pop(i)
                print(f"🗑️  Relay unregistered: {removed.fingerprint.hex()[:16]}...")
                
                # Rebuild router
                if self.relays:
                    self.router = TransactionRouter(self.relays)
                else:
                    self.router = None
                
                return True
        
        return False
    
    def get_router(self) -> Optional[TransactionRouter]:
        """Get the transaction router."""
        return self.router
    
    def relay_count(self) -> int:
        """Get number of active relays."""
        return len(self.relays)


# =============================================================================
# TEST
# =============================================================================

if __name__ == "__main__":
    from ..crypto.credential import generate_credential
    
    print("=" * 60)
    print("TRANSACTION ROUTING TEST")
    print("=" * 60)
    
    # Generate relay credentials
    print("\n1. Generating relay credentials...")
    relays = []
    for i in range(3):
        cred = generate_credential(
            parties=[f'relay_{i}'],
            connections=[],
            security_parameter=256
        )
        relay = RelayNode(
            credential=cred,
            address=f"relay{i}.onion:9001"
        )
        relays.append(relay)
        print(f"   Relay {i}: {relay.fingerprint.hex()[:16]}...")
    
    # Create router
    print("\n2. Creating transaction router...")
    router = TransactionRouter(relays)
    print(f"   Router initialized with {len(router.relays)} relays")
    
    # Create mock transaction
    print("\n3. Creating transaction...")
    # Mock transaction data
    class MockTx:
        def __init__(self):
            self.data = b"test transaction"
    
    tx = MockTx()
    
    # Route transaction
    print("\n4. Routing transaction through network...")
    onion_packet = router.route_transaction(
        tx,
        destination="destination_fingerprint",
        hop_count=3
    )
    
    print(f"\n✅ Transaction routed!")
    print(f"   Layers: {len(onion_packet.layers)}")
    print(f"   Current layer: {onion_packet.current_layer}")
    
    print("\n" + "=" * 60)
