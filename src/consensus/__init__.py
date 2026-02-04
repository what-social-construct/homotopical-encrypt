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

Clean separation:
- invariant_validator.py: Validates PoV invariants (spectral bounds, conservation)
- validator_selection.py: Selects network validators (who produces blocks)
- proofs/consensus.py: ProofOfValue mechanics (how blocks are created)
"""

# Invariant validation (NEW - from local module)
from .invariant_validator import (
    InvariantValidator,
    InvariantCheckpoint,
    POV_LOWER,
    POV_UPPER,
    SQRT2,
)

# PoV mechanics (from proofs/)
from ..proofs.consensus import (
    ProofOfValue,
    Transaction,
    Block,
)

# Re-export bounds with legacy names
LOWER_BOUND = POV_LOWER
UPPER_BOUND = POV_UPPER

# Validator selection
from .validator_selection import (
    Validator,
    ValidatorSet,
    select_validator_for_block,
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
    # Validator selection
    'Validator',
    'ValidatorSet',
    'select_validator_for_block',
]
