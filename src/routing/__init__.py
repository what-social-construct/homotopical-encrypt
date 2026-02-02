"""
Routing Module - Sheaf Onion Routing

Privacy-preserving message routing using sheaf geometry.

Components:
- OnionRouter: Multi-layer encryption via fiber bundles
- OnionPacket: Layered encrypted packet
- MixingNode: Timing obfuscation

The routing is geometrically defined:
- Each relay has its own FiberBundle
- Peeling = applying inverse parallel transport
- Only the relay holding the connection can peel

Re-exports from geometry/fiber_bundle.py for cleaner API.
"""

from ..geometry.fiber_bundle import (
    # Core routing
    OnionRouter,
    OnionPacket,
    OnionLayer,
    create_onion_route,
    peel_onion_layer,
    
    # Mixing (timing obfuscation)
    MixingNode,
    
    # Supporting types
    FiberBundle,
    EphemeralFiber,
)

__all__ = [
    # Onion routing
    "OnionRouter",
    "OnionPacket",
    "OnionLayer",
    "create_onion_route",
    "peel_onion_layer",
    
    # Mixing
    "MixingNode",
    
    # Supporting
    "FiberBundle",
    "EphemeralFiber",
]
