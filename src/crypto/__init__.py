"""
Crypto module: Fibration-based encryption primitives.

Implements Homotopical Quantum Encryption (HQE):
- FibrationCredential: (topology, fibration, spectrum) triple
- Encrypt: Message → cochain embedding → coboundary + noise
- Decrypt: Lindblad flow → harmonic projection → extract
"""

from .credential import FibrationCredential, SpectralFingerprint, generate_credential
from .encrypt import encrypt, FibrationCiphertext
from .decrypt import decrypt

__all__ = [
    "FibrationCredential",
    "SpectralFingerprint",
    "generate_credential",
    "encrypt",
    "decrypt",
    "FibrationCiphertext",
]
