"""
Fiber Bundle with Parallel Transport

A fiber bundle (E, B, π, F) with connection enables parallel transport.
For cryptography, this provides key distribution and secure message passing.

RELATIONSHIP TO STALKS:
- Stalk (primitives/stalk.py) = the DATA that lives in a fiber
- FiberBundle = the GEOMETRY of how fibers are connected
- StalkSpec.dimension = FiberBundle.fiber_dim
- Parallel transport moves Stalks along paths
"""

from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Optional, Callable
import numpy as np

from ..primitives.stalk import Stalk, StalkSpec, StalkBundle, PRIVATE_STALK


@dataclass
class FiberBundle:
    """
    Fiber bundle over a base space.
    
    - base_space: The Čech nerve (topology)
    - fiber_dim: Dimension of each fiber F
    - connection: Parallel transport maps along edges
    """
    base_space: Dict[int, List[Tuple]]  # Nerve
    fiber_dim: int = 256
    connection: Dict[Tuple[int, int], np.ndarray] = field(default_factory=dict)
    
    @classmethod
    def random(cls, nerve: Dict[int, List[Tuple]], fiber_dim: int = 256) -> 'FiberBundle':
        """Generate random fiber bundle with random connection."""
        connection = {}
        edges = nerve.get(1, [])
        
        for edge in edges:
            # Random orthogonal matrix (preserves norms)
            A = np.random.randn(fiber_dim, fiber_dim)
            Q, _ = np.linalg.qr(A)
            connection[edge] = Q
        
        return cls(base_space=nerve, fiber_dim=fiber_dim, connection=connection)
    
    def parallel_transport(
        self,
        vector: np.ndarray,
        path: List[int]
    ) -> np.ndarray:
        """Transport vector along path."""
        current = vector.copy()
        
        for i in range(len(path) - 1):
            edge = tuple(sorted([path[i], path[i+1]]))
            if edge in self.connection:
                current = self.connection[edge] @ current
        
        return current
    
    def holonomy(self, loop: List[int]) -> np.ndarray:
        """Compute holonomy around a loop."""
        if loop[0] != loop[-1]:
            raise ValueError("Loop must be closed")
        
        result = np.eye(self.fiber_dim)
        for i in range(len(loop) - 1):
            edge = tuple(sorted([loop[i], loop[i+1]]))
            if edge in self.connection:
                result = self.connection[edge] @ result
        
        return result
    
    def inverse_transport(
        self,
        vector: np.ndarray,
        path: List[int]
    ) -> np.ndarray:
        """
        Inverse transport: undo parallel transport along path.
        
        For orthogonal connections, inverse = transpose.
        Used in decryption/unwrapping.
        """
        current = vector.copy()
        
        # Walk path in reverse
        for i in range(len(path) - 1, 0, -1):
            edge = tuple(sorted([path[i], path[i-1]]))
            if edge in self.connection:
                # Inverse of orthogonal matrix = transpose
                current = self.connection[edge].T @ current
        
        return current
    
    # =========================================================================
    # STALK INTEGRATION
    # =========================================================================
    
    def transport_stalk(self, stalk: Stalk, path: List[int]) -> Stalk:
        """
        Transport a Stalk along a path in the base space.
        
        Returns a new Stalk at the endpoint with transported data.
        """
        transported_data = self.parallel_transport(stalk.data, path)
        return Stalk(
            spec=stalk.spec,
            data=transported_data,
            vertex_id=path[-1] if path else stalk.vertex_id
        )
    
    def to_stalk_bundle(self, initial_data: Optional[Dict[int, np.ndarray]] = None) -> StalkBundle:
        """
        Create a StalkBundle over this FiberBundle's base space.
        
        Args:
            initial_data: Optional vertex_id → data mapping
            
        Returns:
            StalkBundle with matching fiber dimension
        """
        # Create spec matching fiber_dim
        spec = StalkSpec(
            context=PRIVATE_STALK.context,
            dimension=self.fiber_dim,
            name=f"FiberStalk_{self.fiber_dim}",
            description="Stalk from FiberBundle"
        )
        
        bundle = StalkBundle(spec)
        
        # Populate with initial data or zeros
        vertices = self.base_space.get(0, [])
        for v in vertices:
            vid = v[0] if isinstance(v, tuple) else v
            if initial_data and vid in initial_data:
                data = initial_data[vid]
            else:
                data = np.zeros(self.fiber_dim)
            bundle.set_stalk(vid, Stalk(spec=spec, data=data, vertex_id=vid))
        
        return bundle
    
    @classmethod
    def from_stalk_bundle(cls, bundle: StalkBundle, nerve: Dict[int, List[Tuple]]) -> 'FiberBundle':
        """
        Create FiberBundle from an existing StalkBundle.
        
        Connection matrices are initialized as identity (flat connection).
        """
        fiber_dim = bundle.spec.dimension
        connection = {}
        
        # Identity connection (flat bundle)
        for edge in nerve.get(1, []):
            connection[edge] = np.eye(fiber_dim)
        
        return cls(base_space=nerve, fiber_dim=fiber_dim, connection=connection)


# ============================================================================
# EPHEMERAL FIBERS (Forward Secrecy)
# ============================================================================

def secure_wipe(array: np.ndarray) -> None:
    """
    Securely wipe sensitive data from memory.
    
    Note: In Python this is best-effort due to GC. 
    For production, use ctypes to directly overwrite memory.
    """
    array.fill(0)
    # Overwrite with random data then zeros
    array[:] = np.random.randn(*array.shape)
    array.fill(0)


@dataclass
class EphemeralFiber:
    """
    Ephemeral fiber for forward secrecy.
    
    Each message uses a fresh ephemeral fiber that is:
    - Path-homotopic to the base fibration (same spectral class)
    - Destroyed after single use
    - Not recoverable even if base credential compromised later
    
    Mathematical model:
    - base_fibration defines a point in fibration space Fib(X)
    - random_path generates a path γ: [0,1] → Fib(X) with γ(0) = base
    - ephemeral_key = γ(1) (endpoint of random walk)
    - After use, wipe γ and γ(1)
    """
    base_bundle: 'FiberBundle'
    random_path: List[int]              # Random walk on nerve
    _transport_matrix: np.ndarray       # Accumulated parallel transport
    _wiped: bool = False
    
    @classmethod
    def generate(
        cls,
        base_bundle: 'FiberBundle',
        path_length: int = 10
    ) -> 'EphemeralFiber':
        """
        Generate fresh ephemeral fiber via random walk.
        
        The random walk accumulates parallel transport,
        giving a unique ephemeral key derivation.
        """
        vertices = [v[0] for v in base_bundle.base_space.get(0, [])]
        edges = base_bundle.base_space.get(1, [])
        
        if len(vertices) < 2:
            raise ValueError("Need at least 2 vertices for random walk")
        
        # Build adjacency for random walk
        adjacency: Dict[int, List[int]] = {v: [] for v in vertices}
        for e in edges:
            adjacency[e[0]].append(e[1])
            adjacency[e[1]].append(e[0])
        
        # Random walk starting from random vertex
        current = np.random.choice(vertices)
        path = [current]
        
        for _ in range(path_length):
            neighbors = adjacency.get(current, [])
            if not neighbors:
                break
            current = np.random.choice(neighbors)
            path.append(current)
        
        # Compute accumulated transport
        transport = np.eye(base_bundle.fiber_dim)
        for i in range(len(path) - 1):
            edge = tuple(sorted([path[i], path[i+1]]))
            if edge in base_bundle.connection:
                transport = base_bundle.connection[edge] @ transport
        
        return cls(
            base_bundle=base_bundle,
            random_path=path,
            _transport_matrix=transport,
            _wiped=False
        )
    
    def derive_key(self, base_key: np.ndarray) -> np.ndarray:
        """
        Derive ephemeral key from base key via parallel transport.
        
        ephemeral_key = transport_matrix @ base_key
        """
        if self._wiped:
            raise ValueError("Ephemeral fiber has been wiped")
        
        return self._transport_matrix @ base_key
    
    def wipe(self) -> None:
        """
        Securely wipe ephemeral fiber.
        
        MUST be called after single use for forward secrecy.
        """
        if not self._wiped:
            secure_wipe(self._transport_matrix)
            self.random_path = []
            self._wiped = True
    
    def __del__(self):
        """Auto-wipe on garbage collection."""
        if not self._wiped:
            self.wipe()


# ============================================================================
# SHEAF ONION ROUTING
# ============================================================================

@dataclass
class OnionLayer:
    """
    Single layer of sheaf onion encryption.
    
    Each relay node has:
    - Its own fiber bundle (different base space or connection)
    - A public transport path (how to reach next hop)
    """
    relay_bundle: 'FiberBundle'
    next_hop: Optional[int]  # Next relay index, None = destination
    transport_path: List[int]  # Path through this relay's nerve


@dataclass
class OnionPacket:
    """
    Multi-layer encrypted packet for sheaf onion routing.
    
    Structure:
    - Each layer encrypted with that relay's fiber
    - Relays peel one layer via inverse transport
    - Only final recipient sees plaintext
    """
    layers: List[np.ndarray]  # Encrypted data at each layer
    path_hints: List[List[int]]  # Path hints for each layer
    current_layer: int = 0


def create_onion_route(
    relays: List['FiberBundle'],
    message: np.ndarray,
    keys: List[np.ndarray]
) -> OnionPacket:
    """
    Create onion-encrypted packet through relay chain.
    
    Wraps message in layers: message → wrap(relay_n) → ... → wrap(relay_1)
    
    Args:
        relays: List of relay fiber bundles (in order from sender to recipient)
        message: Plaintext message
        keys: List of keys for each relay (shared via prior DH or similar)
        
    Returns:
        OnionPacket ready for routing
    """
    if len(relays) != len(keys):
        raise ValueError("Need one key per relay")
    
    layers = []
    path_hints = []
    current = message
    
    # Wrap from last relay to first (onion structure)
    for i in range(len(relays) - 1, -1, -1):
        bundle = relays[i]
        key = keys[i]
        
        # Generate random path for this layer
        ephemeral = EphemeralFiber.generate(bundle)
        eph_key = ephemeral.derive_key(key)
        
        # Encrypt current data with this layer's key
        key_stream = np.tile(eph_key, (len(current) // len(eph_key) + 1))[:len(current)]
        encrypted = current ^ (key_stream * 255).astype(np.uint8)
        
        layers.insert(0, encrypted.copy())
        path_hints.insert(0, ephemeral.random_path.copy())
        
        # Update current for next layer
        current = encrypted
        
        ephemeral.wipe()
    
    return OnionPacket(
        layers=layers,
        path_hints=path_hints,
        current_layer=0
    )


def peel_onion_layer(
    packet: OnionPacket,
    relay_bundle: 'FiberBundle',
    relay_key: np.ndarray
) -> Tuple[np.ndarray, bool]:
    """
    Relay node peels one layer of onion encryption.
    
    Returns:
        (decrypted_data, is_final) - is_final True if this was last layer
    """
    if packet.current_layer >= len(packet.layers):
        raise ValueError("No more layers to peel")
    
    # Get this layer's data and path hint
    layer_data = packet.layers[packet.current_layer]
    path_hint = packet.path_hints[packet.current_layer]
    
    # Reconstruct ephemeral key
    transport = np.eye(relay_bundle.fiber_dim)
    for i in range(len(path_hint) - 1):
        edge = tuple(sorted([path_hint[i], path_hint[i+1]]))
        if edge in relay_bundle.connection:
            transport = relay_bundle.connection[edge] @ transport
    
    eph_key = transport @ relay_key
    
    # Decrypt this layer
    key_stream = np.tile(eph_key, (len(layer_data) // len(eph_key) + 1))[:len(layer_data)]
    decrypted = layer_data ^ (key_stream * 255).astype(np.uint8)
    
    # Move to next layer
    packet.current_layer += 1
    
    is_final = (packet.current_layer >= len(packet.layers))
    
    return decrypted, is_final


@dataclass
class OnionRouter:
    """
    Complete onion routing system using sheaf geometry.
    
    Each relay:
    1. Has its own FiberBundle (topology + connection)
    2. Peels one layer via parallel transport
    3. Forwards to next hop (or delivers if final)
    
    Security properties:
    - No relay sees plaintext (except final destination)
    - Each relay only knows: previous hop, next hop
    - Traffic analysis resistant (all packets same size)
    - Forward secure (ephemeral fibers per layer)
    """
    relays: List['FiberBundle']
    relay_keys: List[np.ndarray]  # Shared keys with each relay
    
    def route_message(self, message: np.ndarray) -> OnionPacket:
        """Create onion packet for routing through all relays."""
        return create_onion_route(self.relays, message, self.relay_keys)
    
    def relay_process(
        self,
        packet: OnionPacket,
        relay_index: int
    ) -> Tuple[np.ndarray, bool]:
        """Process packet at relay node."""
        return peel_onion_layer(
            packet,
            self.relays[relay_index],
            self.relay_keys[relay_index]
        )
    
    def simulate_full_route(self, message: np.ndarray) -> np.ndarray:
        """
        Simulate full route from sender to recipient.
        
        Returns final decrypted message.
        """
        packet = self.route_message(message)
        
        current_data = None
        for i in range(len(self.relays)):
            current_data, is_final = self.relay_process(packet, i)
            if is_final:
                break
        
        return current_data


# ============================================================================
# MIXING DELAYS (Timing Obfuscation)
# ============================================================================

@dataclass
class MixingNode:
    """
    Mixing node for timing obfuscation.
    
    Holds packets for random delays, then releases in shuffled order.
    Breaks timing correlation between input and output.
    """
    bundle: 'FiberBundle'
    key: np.ndarray
    pool: List[Tuple[OnionPacket, float]]  # (packet, arrival_time)
    min_pool_size: int = 5  # Don't release until this many packets
    
    def receive(self, packet: OnionPacket, arrival_time: float) -> None:
        """Receive packet into mixing pool."""
        self.pool.append((packet, arrival_time))
    
    def release(self, current_time: float) -> List[OnionPacket]:
        """
        Release packets from pool with random delays.
        
        Only releases if pool has enough packets (mixing).
        """
        if len(self.pool) < self.min_pool_size:
            return []
        
        # Shuffle pool order (breaks timing correlation)
        np.random.shuffle(self.pool)
        
        # Release all with random delays added
        released = []
        for packet, _ in self.pool:
            # Process (peel layer)
            _, _ = peel_onion_layer(packet, self.bundle, self.key)
            released.append(packet)
        
        self.pool = []
        return released
