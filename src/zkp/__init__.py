"""
Zero-Knowledge Proofs of Homotopy Equivalence

The key insight: Homotopy invariants are ZK-friendly!

In traditional ZK: "I know x such that f(x) = y" without revealing x
In homotopical ZK: "I know a PATH γ: F ≃ G" without revealing γ

STATEMENT:  "My key is in the same homotopy class as the public key"
WITNESS:    The actual fibration structure (SECRET!)
PROOF:      Spectral invariants that only depend on [F] (homotopy class)
VERIFIER:   Checks invariants match, learns NOTHING about F

This module re-exports from proofs/ for cleaner API.
"""

# Re-export from proofs module
from ..proofs import (
    # Homotopy proofs
    HomotopyStatement,
    HomotopyProof,
    prove_homotopy_equivalence,
    verify_homotopy_proof,
    batch_verify_proofs,
    InteractiveHomotopyProof,
    interactive_prove,
    
    # Spectral proofs
    SpectralProof,
    prove_spectral_match,
    verify_spectral_match,
    SpectralGapProof,
    prove_spectral_gap_in_bounds,
    verify_spectral_gap_proof,
    SpectralIdentityProof,
    
    # Ring signatures (for benchmarking)
    RingSpectralProof,
    prove_ring_spectral,
    verify_ring_spectral,
    
    # √2 bounds
    SQRT2,
    LOWER_BOUND as POV_LOWER,
    UPPER_BOUND as POV_UPPER,
    
    # Homotopical anonymity (infinite anonymity set)
    HomotopyClassProof,
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

# Alias for spectral fingerprint
from ..invariants.spectral import compute_spectral_invariants as compute_spectral_fingerprint

__all__ = [
    # Homotopy proofs
    "HomotopyProof",
    "HomotopyStatement",
    "prove_homotopy_equivalence",
    "verify_homotopy_proof",
    "batch_verify_proofs",
    "InteractiveHomotopyProof",
    "interactive_prove",
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
    # Ring signatures (benchmarking)
    "RingSpectralProof",
    "prove_ring_spectral",
    "verify_ring_spectral",
    # √2 bounds
    "SQRT2",
    "POV_LOWER",
    "POV_UPPER",
    # Homotopical anonymity
    "HomotopyClassProof",
    "compute_spectral_fingerprint",
    "prove_class_membership",
    "verify_class_membership",
    # Cochain balance
    "CochainCommitment",
    "create_amount_commitment",
    "verify_balance",
    # Harmonic range proofs
    "HarmonicRangeProof",
    "create_harmonic_range_proof",
    "verify_harmonic_range_proof",
]
