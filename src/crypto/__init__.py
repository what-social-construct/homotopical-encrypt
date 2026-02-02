"""
Crypto module: Cochain-based encryption primitives.

Implements Homotopical Encryption (NOT traditional LWE):
- FibrationCredential: (topology, fibration, spectrum) triple
- Encrypt: Message → cochain embedding → coboundary + noise
- Decrypt: Harmonic projection → extract from ker(Δ)

Key insight from HOMOTOPICAL_PRIMITIVES.md:
- Security from cochain lattice structure, not "error tolerance"
- Structured noise in im(δ) ⊕ im(δ*), not random error
- Deterministic Hodge projection for decryption
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

# Lattice operations (structured noise, not traditional LWE)
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

# Validators
from .validators import (
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
]
