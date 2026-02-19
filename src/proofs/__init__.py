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

# Spectral bounds (canonical source — all other files import from here)
from .spectral_bounds import (
    SQRT2 as SQRT2_CANONICAL,
    POV_LOWER as POV_LOWER_CANONICAL,
    POV_UPPER as POV_UPPER_CANONICAL,
    GapStatus,
    gap_in_bounds,
    gap_in_bounds_strict,
    gap_to_fixed,
    fixed_to_gap,
    serialize_gap,
    deserialize_gap,
    credential_age_valid,
    CREDENTIAL_MIN_AGE_BLOCKS,
    CREDENTIAL_MAX_AGE_BLOCKS,
)

# Tsirelson bounds (classical & quantum hardness)
from .tsirelson import (
    grassmannian_laplacian,
    sample_grassmannian,
    grassmannian_laplacians,
    validate_laplacian_space,
    relative_spectral_gap,
    likelihood,
    classical_bound,
    quantum_bound,
    grassmannian_dimension,
    analyze_tsirelson,
    TsirelsonAnalysis,
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
