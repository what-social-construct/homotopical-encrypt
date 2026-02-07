"""
Crypto Module — Cochain-based Encryption Primitives

WHY COCHAINS (algebraic dual):

  Cochains are DUAL to chains — functions on simplices rather than
  simplices themselves. This duality is why the crypto works:

  - δ (coboundary) is the TRANSPOSE of ∂ (boundary). One operator,
    two directions. Encryption uses δ (push message to edges),
    decryption uses δ* (project back to vertices). The adjoint
    relationship δ* = δᵀ means encrypt/decrypt are transposes of
    each other — mathematically forced to be inverses.

  - Pullback: a map f: X → Y induces f*: C^k(Y) → C^k(X) on cochains.
    Encryption naturally pulls back along topology maps. Chains push
    forward, which is the wrong direction for hiding.

  - Cup product: cochains multiply (α ∪ β), chains don't. This gives
    ring structure for commitments (homomorphic addition from δ
    linearity) and algebraic invariant gating (cup product ranks
    detect non-equivalent fibrations cheaper than homotopy checks).

  - Integration pairing ⟨c, σ⟩: cochain evaluated on chain = the
    fundamental decrypt operation ("evaluate the section at a point").

Pipeline:
  credential.py: Generate (topology, fibration, spectrum) triple
  encrypt.py:    Message → harmonic embedding → coboundary + Hodge noise
  decrypt.py:    Harmonic projection onto ker(Δ) → extract message
  commitment.py: Commit(m, r) = δ(m || r) — hiding via coboundary
  validation.py: Hard gates (dimension, modulus, spectral, topology)

Invariant orchestration:
  invariants/unified.py provides validate_fibration() which runs all
  invariant checkpoints (spectral + cohomology + homotopical) for a
  given pipeline stage (keygen/encrypt/decrypt/transaction).
"""

# Core types
from .credential import FibrationCredential, SpectralFingerprint, generate_credential
from .encrypt import encrypt, FibrationCiphertext
from .decrypt import (
    decrypt,
    decrypt_with_verification,
    projective_measurement,
    DecryptionChain,
    hash_message,
    verify_sender,
)

# Lattice operations (Hodge-structured noise)
from .lattice import (
    LatticeInstance,
    CochainLattice,
    secure_random_vector,
    secure_random_matrix,
    spectral_noise,
    exact_coboundary_noise,
    ornstein_uhlenbeck_noise,
    heat_kernel_sample,
)

# Validation (encryption input/output checks)
from .validation import (
    validate_decryption_request,
    validate_decryption_integrity,
)

# Commitments (cochain-based)
from .commitment import (
    CochainCommitment,
    BlindedCommitment,
    VectorCommitment,
    add_commitments,
    scalar_mult_commitment,
)

# Unified invariant validation (re-export for convenience)
from ..invariants.unified import validate_fibration, fingerprints_equivalent

__all__ = [
    # Core types
    "FibrationCredential",
    "SpectralFingerprint",
    "generate_credential",
    "encrypt",
    "decrypt",
    "FibrationCiphertext",
    # Decryption utilities
    "decrypt_with_verification",
    "projective_measurement",
    "DecryptionChain",
    "hash_message",
    "verify_sender",
    # Lattice operations
    "LatticeInstance",
    "CochainLattice",
    "secure_random_vector",
    "secure_random_matrix",
    "spectral_noise",
    "exact_coboundary_noise",
    "ornstein_uhlenbeck_noise",
    "heat_kernel_sample",
    # Validators
    "validate_decryption_request",
    "validate_decryption_integrity",
    # Commitments
    "CochainCommitment",
    "BlindedCommitment",
    "VectorCommitment",
    "add_commitments",
    "scalar_mult_commitment",
    # Unified invariant validation
    "validate_fibration",
    "fingerprints_equivalent",
]
