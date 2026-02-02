"""
Proofs Module - Unified Proof System

All proofs in one place:
- Consensus proofs (Proof of Value)
- Zero-knowledge proofs (homotopy, spectral)
- Privacy proofs (anonymity)

All proofs use invariants/ for validation.
"""

# Consensus (Proof of Value)
from .consensus import (
    ProofOfValue,
    Block,
    Transaction,
    InvariantCheckpoint,
    InvariantValidator,
    SQRT2,
    LOWER_BOUND,
    UPPER_BOUND,
)

# Homotopy proofs
from .homotopy import (
    HomotopyStatement,
    HomotopyProof,
    prove_homotopy_equivalence,
    verify_homotopy_proof,
    batch_verify_proofs,
    InteractiveHomotopyProof,
    interactive_prove,
)

# Spectral proofs
from .spectral import (
    SpectralProof,
    prove_spectral_match,
    verify_spectral_match,
    RingSpectralProof,
    prove_ring_spectral,
    verify_ring_spectral,
    SpectralGapProof,
    prove_spectral_gap_in_bounds,
    verify_spectral_gap_proof,
    SpectralIdentityProof,
)

# Anonymity proofs
from .anonymity import (
    HomotopyClassProof,
    prove_class_membership,
    verify_class_membership,
    CochainCommitment,
    create_amount_commitment,
    verify_balance,
    HarmonicRangeProof,
    create_harmonic_range_proof,
    verify_harmonic_range_proof,
)

__all__ = [
    # Consensus
    "ProofOfValue",
    "Block",
    "Transaction",
    "InvariantCheckpoint",
    "InvariantValidator",
    "SQRT2",
    "LOWER_BOUND",
    "UPPER_BOUND",
    
    # Homotopy
    "HomotopyStatement",
    "HomotopyProof",
    "prove_homotopy_equivalence",
    "verify_homotopy_proof",
    "batch_verify_proofs",
    "InteractiveHomotopyProof",
    "interactive_prove",
    
    # Spectral
    "SpectralProof",
    "prove_spectral_match",
    "verify_spectral_match",
    "RingSpectralProof",
    "prove_ring_spectral",
    "verify_ring_spectral",
    "SpectralGapProof",
    "prove_spectral_gap_in_bounds",
    "verify_spectral_gap_proof",
    "SpectralIdentityProof",
    
    # Anonymity
    "HomotopyClassProof",
    "prove_class_membership",
    "verify_class_membership",
    "CochainCommitment",
    "create_amount_commitment",
    "verify_balance",
    "HarmonicRangeProof",
    "create_harmonic_range_proof",
    "verify_harmonic_range_proof",
]
