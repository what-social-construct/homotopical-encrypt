"""
Network module: Transaction routing and privacy transport.

Provides onion-style routing for transactions using sheaf fiber bundles.
Each relay unwraps one layer while preserving privacy.

Matches Rust structure: rust/node/src/network/
"""

from .routing import (
    RelayNode,
    TransactionRouter,
    RelayNetwork,
)

__all__ = [
    "RelayNode",
    "TransactionRouter", 
    "RelayNetwork",
]
