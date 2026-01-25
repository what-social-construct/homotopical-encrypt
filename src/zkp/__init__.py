"""
Zero-Knowledge Proofs of Homotopy Equivalence

The key insight: Homotopy invariants are ZK-friendly!

In traditional ZK: "I know x such that f(x) = y" without revealing x
In homotopical ZK: "I know a PATH γ: F ≃ G" without revealing γ

STATEMENT:  "My key is in the same homotopy class as the public key"
WITNESS:    The actual fibration structure (SECRET!)
PROOF:      Spectral invariants that only depend on [F] (homotopy class)
VERIFIER:   Checks invariants match, learns NOTHING about F

Invariants used:
- Betti numbers β_k (topological)
- Spectral gap λ_1 (geometric)
- Eigenvalue spectrum (spectral)
"""

from .homotopy_proof import (
    HomotopyProof,
    HomotopyStatement,
    prove_homotopy_equivalence,
    verify_homotopy_proof,
)
from .spectral_proof import (
    # Basic spectral match
    SpectralProof,
    prove_spectral_match,
    verify_spectral_match,
    # Range proof for PoV
    SpectralGapProof,
    prove_spectral_gap_in_bounds,
    verify_spectral_gap_proof,
    # Identity proof
    SpectralIdentityProof,
    prove_spectral_identity,
    verify_spectral_identity,
    # Ring signatures
    RingSpectralProof,
    prove_ring_spectral,
    verify_ring_spectral,
    # Constants
    SQRT2,
    POV_LOWER,
    POV_UPPER,
)
from .homotopy_anonymity import (
    # Class membership (INFINITE anonymity set)
    HomotopyClassProof,
    compute_spectral_fingerprint,
    prove_class_membership,
    verify_class_membership,
    # Cochain balance (homomorphic)
    CochainCommitment,
    create_amount_commitment,
    verify_balance,
    # Harmonic range proofs
    HarmonicRangeProof,
    create_harmonic_range_proof,
    verify_harmonic_range_proof,
)

__all__ = [
    # Homotopy proofs
    "HomotopyProof",
    "HomotopyStatement",
    "prove_homotopy_equivalence",
    "verify_homotopy_proof",
    # Spectral match
    "SpectralProof",
    "prove_spectral_match",
    "verify_spectral_match",
    # Gap range proof
    "SpectralGapProof",
    "prove_spectral_gap_in_bounds",
    "verify_spectral_gap_proof",
    # Identity proof
    "SpectralIdentityProof",
    "prove_spectral_identity",
    "verify_spectral_identity",
    # Ring signatures
    "RingSpectralProof",
    "prove_ring_spectral",
    "verify_ring_spectral",
    # √2 bounds
    "SQRT2",
    "POV_LOWER",
    "POV_UPPER",
    # HOMOTOPICAL ANONYMITY (infinite anonymity set)
    "HomotopyClassProof",
    "compute_spectral_fingerprint",
    "prove_class_membership",
    "verify_class_membership",
    # Cochain balance (homomorphic)
    "CochainCommitment",
    "create_amount_commitment",
    "verify_balance",
    # Harmonic range proofs
    "HarmonicRangeProof",
    "create_harmonic_range_proof",
    "verify_harmonic_range_proof",
]
