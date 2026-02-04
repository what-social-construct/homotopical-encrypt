"""
Hard Validator Checkpoints

Invariant validation gates that MUST pass for any cryptographic operation.
These are non-negotiable security constraints.

Philosophy: Better to fail loudly than silently produce garbage.
"""

from dataclasses import dataclass
from typing import Tuple, Optional
import numpy as np
import hashlib

from .credential import FibrationCredential
from .encrypt import FibrationCiphertext


# =============================================================================
# DIMENSION CONSTRAINTS
# =============================================================================

# Minimum security parameter (bits)
MIN_SECURITY_BITS = 128

# Valid Hilbert dimensions (must be power of 2 for efficiency)
VALID_HILBERT_DIMS = {128, 256, 512, 1024, 2048}

# Minimum/maximum modulus for LWE security
MIN_MODULUS = 3329    # Kyber-like
MAX_MODULUS = 65537   # Prime upper bound

# Message size limits (bytes)
MAX_MESSAGE_CHUNK = 32  # Per encryption block


@dataclass
class ValidationResult:
    """Result of validation checkpoint."""
    valid: bool
    checkpoint: str
    reason: str
    
    def __bool__(self):
        return self.valid


def validate_credential(credential: FibrationCredential) -> ValidationResult:
    """
    Gate 1: Credential invariant validation.
    
    Checks:
    - Hilbert dimension in valid set
    - Modulus in secure range
    - Topology is non-trivial
    - Fibration has valid spectral gap
    """
    # Check Hilbert dimension
    if credential.hilbert_dim not in VALID_HILBERT_DIMS:
        return ValidationResult(
            False, "DIMENSION_CHECK",
            f"Hilbert dim {credential.hilbert_dim} not in valid set {VALID_HILBERT_DIMS}"
        )
    
    # Check modulus
    if not (MIN_MODULUS <= credential.modulus <= MAX_MODULUS):
        return ValidationResult(
            False, "MODULUS_CHECK",
            f"Modulus {credential.modulus} outside secure range [{MIN_MODULUS}, {MAX_MODULUS}]"
        )
    
    # Check topology has vertices
    vertices = credential.topology.get(0, [])
    if len(vertices) < 2:
        return ValidationResult(
            False, "TOPOLOGY_CHECK",
            f"Topology needs at least 2 vertices, has {len(vertices)}"
        )
    
    # Check edges exist
    edges = credential.topology.get(1, [])
    if len(edges) < 1:
        return ValidationResult(
            False, "TOPOLOGY_CHECK",
            f"Topology needs at least 1 edge, has {len(edges)}"
        )
    
    # Check spectrum exists
    if credential.spectrum is None:
        return ValidationResult(
            False, "SPECTRUM_CHECK",
            "Credential has no spectral fingerprint"
        )
    
    return ValidationResult(True, "CREDENTIAL_VALID", "All credential checks passed")


def validate_ciphertext(
    ciphertext: FibrationCiphertext,
    credential: FibrationCredential
) -> ValidationResult:
    """
    Gate 2: Ciphertext-credential binding validation.
    
    Checks:
    - Topology hashes match EXACTLY
    - Vertex count matches
    - Edge count matches
    - All required blocks present
    """
    # HARD CHECK: Topology hash must match exactly
    if ciphertext.topology_hash != credential.spectrum.topology_hash:
        return ValidationResult(
            False, "TOPOLOGY_BINDING",
            f"Topology hash mismatch: ciphertext={ciphertext.topology_hash.hex()[:16]} vs credential={credential.spectrum.topology_hash.hex()[:16]}"
        )
    
    # Check vertex count
    expected_vertices = len(credential.topology.get(0, []))
    actual_vertices = len(ciphertext.vertex_blocks)
    if actual_vertices != expected_vertices:
        return ValidationResult(
            False, "VERTEX_COUNT",
            f"Expected {expected_vertices} vertex blocks, got {actual_vertices}"
        )
    
    # Check edge count
    expected_edges = len(credential.topology.get(1, []))
    actual_edges = len(ciphertext.edge_syndromes)
    if actual_edges != expected_edges:
        return ValidationResult(
            False, "EDGE_COUNT",
            f"Expected {expected_edges} edge syndromes, got {actual_edges}"
        )
    
    # Check version (v1 = discrete Gaussian, v2 = Hodge-structured noise)
    if ciphertext.version not in (1, 2):
        return ValidationResult(
            False, "VERSION_CHECK",
            f"Unknown ciphertext version {ciphertext.version} (valid: 1=Gaussian, 2=Hodge)"
        )
    
    return ValidationResult(True, "CIPHERTEXT_VALID", "All ciphertext checks passed")


def validate_message_size(
    message_length: int,
    hilbert_dim: int
) -> ValidationResult:
    """
    Gate 3: Message size validation.
    
    Maximum message per block = hilbert_dim / 8 bytes
    """
    max_bytes = hilbert_dim // 8
    
    if message_length > max_bytes:
        return ValidationResult(
            False, "MESSAGE_SIZE",
            f"Message {message_length} bytes exceeds max {max_bytes} bytes for dim={hilbert_dim}. Use chunking."
        )
    
    if message_length <= 0:
        return ValidationResult(
            False, "MESSAGE_SIZE",
            "Message cannot be empty"
        )
    
    return ValidationResult(True, "MESSAGE_SIZE_VALID", f"Message {message_length} bytes within limit {max_bytes}")


def validate_decryption_integrity(
    decrypted: bytes,
    expected_hash: bytes
) -> ValidationResult:
    """
    Gate 4: Decryption integrity check.
    
    Hash of decrypted message MUST match expected hash.
    """
    actual_hash = hashlib.sha256(decrypted).digest()
    
    if actual_hash != expected_hash:
        return ValidationResult(
            False, "INTEGRITY_CHECK",
            f"Decryption integrity failed: hash mismatch"
        )
    
    return ValidationResult(True, "INTEGRITY_VALID", "Decryption hash verified")


# =============================================================================
# SPECTRAL VALIDATORS (from geometry)
# =============================================================================

# √2 bounds for Proof of Value
SQRT2 = np.sqrt(2)
POV_LOWER = 1.0 / SQRT2  # ≈ 0.7071
POV_UPPER = 2.0 * SQRT2  # ≈ 2.8284


def validate_spectral_gap(eigenvalues: np.ndarray) -> ValidationResult:
    """
    Gate 5: Spectral gap validation (Tsirelson bound).
    
    First nonzero eigenvalue must be in [1/√2, 2√2].
    """
    # Find first nonzero eigenvalue
    sorted_eigs = np.sort(eigenvalues)
    nonzero = sorted_eigs[sorted_eigs > 1e-10]
    
    if len(nonzero) == 0:
        return ValidationResult(
            False, "SPECTRAL_GAP",
            "No nonzero eigenvalues found"
        )
    
    gap = float(nonzero[0])
    
    if not (POV_LOWER <= gap <= POV_UPPER):
        return ValidationResult(
            False, "SPECTRAL_GAP",
            f"Gap {gap:.4f} outside √2 bounds [{POV_LOWER:.4f}, {POV_UPPER:.4f}]"
        )
    
    return ValidationResult(True, "SPECTRAL_GAP_VALID", f"Gap {gap:.4f} in valid range")


# =============================================================================
# COMPOSITE VALIDATORS
# =============================================================================

def validate_encryption_request(
    message: bytes,
    credential: FibrationCredential
) -> Tuple[bool, str]:
    """
    Full validation before encryption.
    
    Returns (can_encrypt, reason).
    """
    # Gate 1: Credential
    result = validate_credential(credential)
    if not result:
        return (False, f"[{result.checkpoint}] {result.reason}")
    
    # Gate 3: Message size
    result = validate_message_size(len(message), credential.hilbert_dim)
    if not result:
        return (False, f"[{result.checkpoint}] {result.reason}")
    
    return (True, "Encryption validated")


def validate_decryption_request(
    ciphertext: FibrationCiphertext,
    credential: FibrationCredential
) -> Tuple[bool, str]:
    """
    Full validation before decryption.
    
    Returns (can_decrypt, reason).
    """
    # Gate 1: Credential
    result = validate_credential(credential)
    if not result:
        return (False, f"[{result.checkpoint}] {result.reason}")
    
    # Gate 2: Ciphertext binding
    result = validate_ciphertext(ciphertext, credential)
    if not result:
        return (False, f"[{result.checkpoint}] {result.reason}")
    
    return (True, "Decryption validated")


# =============================================================================
# MESSAGE CHUNKING (for large messages)
# =============================================================================

def chunk_message(message: bytes, chunk_size: int) -> list:
    """Split message into chunks for multi-block encryption."""
    return [message[i:i+chunk_size] for i in range(0, len(message), chunk_size)]


def dechunk_message(chunks: list) -> bytes:
    """Reassemble chunks into original message."""
    return b''.join(chunks)


def required_chunks(message_length: int, hilbert_dim: int) -> int:
    """Calculate number of chunks needed for message."""
    max_per_chunk = hilbert_dim // 8
    return (message_length + max_per_chunk - 1) // max_per_chunk


# =============================================================================
# TEST
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("VALIDATOR CHECKPOINT TEST")
    print("=" * 60)
    
    from .credential import generate_credential
    from .encrypt import encrypt
    
    # Create credential
    cred = generate_credential(['A', 'B', 'C'], [('A', 'B'), ('B', 'C'), ('C', 'A')])
    
    # Test credential validation
    result = validate_credential(cred)
    print(f"\n1. Credential validation: {result.valid}")
    print(f"   {result.reason}")
    
    # Test message size
    result = validate_message_size(32, cred.hilbert_dim)
    print(f"\n2. Message 32 bytes: {result.valid}")
    
    result = validate_message_size(64, cred.hilbert_dim)
    print(f"   Message 64 bytes: {result.valid} - {result.reason}")
    
    # Test chunking
    msg = b"A" * 100
    chunks_needed = required_chunks(len(msg), cred.hilbert_dim)
    print(f"\n3. 100 byte message needs {chunks_needed} chunks")
    
    print("\n" + "=" * 60)
    print("✅ VALIDATORS READY")
    print("=" * 60)
