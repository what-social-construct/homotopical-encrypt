"""
Consensus Module - Proof of Value

Geometric consensus via harmonic projection using √2 bounds.

TSIRELSON BOUND - GEOMETRIC MEANING:

The bounds [1/√2, 2√2] arise from quantum information theory (Tsirelson, 1980).
They represent the maximum achievable correlation in bipartite quantum systems:

    |⟨ψ| A ⊗ B |ψ⟩| ≤ 2√2    for any entangled state |ψ⟩

Geometrically, this is the boundary of the quantum correlation polytope.
For sheaf Laplacians Δ = δδ* + δ*δ on a graph:

    λ₁(Δ) ∈ [1/√2, 2√2]  ⟺  valid causal structure
    
    Below 1/√2:  Topology is disconnected (no information flow)
    Above 2√2:   Topology would permit superluminal signaling (acausal)

The spectral gap measures how "quantum coherent" the topology is.
Saturating 2√2 = maximum entanglement while preserving causality.

This module re-exports from proofs/consensus.py for cleaner API.
"""

# Re-export from proofs module
from ..proofs.consensus import (
    ProofOfValue,
    Transaction,
    Block,
    InvariantValidator,
    InvariantCheckpoint,
    SQRT2,
    LOWER_BOUND,
    UPPER_BOUND,
)

__all__ = [
    'ProofOfValue',
    'Transaction',
    'Block',
    'InvariantValidator',
    'InvariantCheckpoint',
    'SQRT2',
    'LOWER_BOUND',
    'UPPER_BOUND',
]
