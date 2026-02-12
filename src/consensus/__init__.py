"""
Consensus Module — Proof of Value

Proof of Value (PoV): validators prove their fibration has geometric
quality (spectral gap in √2 bounds). Not stake, not compute — geometric
coherence IS the value.

  HARMONIC CONSENSUS MODEL:

  The Hodge decomposition naturally separates agreement from disagreement:

    c = π_H(c) + δ(α) + δ*(β)

  - π_H(c) ∈ ker(Δ):  Consensus — what everyone agrees on
  - δ(α) ∈ im(δ):     Gauge freedom — valid representational differences
  - δ*(β) ∈ im(δ*):   Noise/attack — genuine inconsistency (detectable)

  Validator selection uses Fiedler centrality (topology-aware, not
  stake-weighted). The second eigenvector of the Laplacian measures
  how central each node is to information flow.

  (Cochain duality advantages documented in crypto/__init__.py)

Clean separation:
- invariant_validator.py: Validates PoV invariants (bounds, conservation)
- validator_selection.py: Selects who produces blocks (Fiedler centrality)
- proofs/consensus.py: ProofOfValue mechanics (spectral gap proofs)
- invariants/unified.py: Orchestrates all invariant checkpoints
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

# VRF slot assignment (fork prevention)
from .vrf_slots import (
    VRFKey,
    VRFOutput,
    SlotAssignment,
    EquivocationEvidence,
    EquivocationTracker,
    vrf_evaluate,
    vrf_check_eligibility,
    assign_slot,
    verify_slot_assignment,
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
    # VRF slots
    'VRFKey',
    'VRFOutput',
    'SlotAssignment',
    'EquivocationEvidence',
    'EquivocationTracker',
    'vrf_evaluate',
    'vrf_check_eligibility',
    'assign_slot',
    'verify_slot_assignment',
]
