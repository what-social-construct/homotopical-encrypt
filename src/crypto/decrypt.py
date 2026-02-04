"""
Decryption via Harmonic Projection

Decryption process:
1. Validate credential/ciphertext binding (hard gate)
2. Direct lattice decoding (reliable)
3. Hash verification (integrity check)
4. Optional: Projective measurement (for ZK proofs)

The key insight from HOMOTOPICAL_PRIMITIVES.md:
- Messages live in ker(Δ) = harmonic cochains
- Decryption projects to harmonic subspace
- Projection is DETERMINISTIC (not error correction)

Hash-tracing inspired by chloe_protocol's HashChain pattern.
"""

from typing import Optional, Tuple
import numpy as np
import hashlib

from .credential import FibrationCredential
from .encrypt import FibrationCiphertext
from .lattice import LatticeInstance, ornstein_uhlenbeck_noise
from ..geometry.sheaf_laplacian import SheafLaplacian

# Harmonic invariant gates
from ..invariants.harmonic import (
    project_to_harmonic,
    validate_decryption_integrity,
    HarmonicInvariantResult,
)


# =============================================================================
# DECRYPTION CHAIN (hash tracing)
# =============================================================================

class DecryptionChain:
    """
    Hash-traced decryption with projective measurement capability.
    
    Like chloe_protocol's HashChain but for encryption operations:
    - Traces encryption → projection → decryption
    - Allows verification at each step
    - Supports rollback/retrace
    """
    
    def __init__(self):
        self.chain = []
        self.current_hash = self._genesis_hash()
    
    def _genesis_hash(self) -> str:
        return hashlib.sha256(b"homotopical_decrypt_genesis").hexdigest()
    
    def add_encryption_record(
        self,
        message_hash: str,
        ciphertext_hash: str,
        topology_hash: bytes
    ) -> str:
        """Record encryption operation."""
        hasher = hashlib.sha256()
        hasher.update(self.current_hash.encode())
        hasher.update(message_hash.encode())
        hasher.update(ciphertext_hash.encode())
        hasher.update(topology_hash)
        
        new_hash = hasher.hexdigest()
        self.chain.append({
            'type': 'encryption',
            'hash': new_hash,
            'prev_hash': self.current_hash,
            'message_hash': message_hash,
            'ciphertext_hash': ciphertext_hash
        })
        self.current_hash = new_hash
        return new_hash
    
    def add_projection_record(
        self,
        pre_projection_hash: str,
        harmonic_hash: str,
        eigenvalue_hash: str
    ) -> str:
        """Record projective measurement."""
        hasher = hashlib.sha256()
        hasher.update(self.current_hash.encode())
        hasher.update(pre_projection_hash.encode())
        hasher.update(harmonic_hash.encode())
        hasher.update(eigenvalue_hash.encode())
        
        new_hash = hasher.hexdigest()
        self.chain.append({
            'type': 'projection',
            'hash': new_hash,
            'prev_hash': self.current_hash,
            'pre_projection_hash': pre_projection_hash,
            'harmonic_hash': harmonic_hash
        })
        self.current_hash = new_hash
        return new_hash
    
    def add_decryption_record(
        self,
        decrypted_hash: str,
        expected_hash: str,
        verified: bool
    ) -> str:
        """Record decryption with verification status."""
        hasher = hashlib.sha256()
        hasher.update(self.current_hash.encode())
        hasher.update(decrypted_hash.encode())
        hasher.update(expected_hash.encode())
        hasher.update(str(verified).encode())
        
        new_hash = hasher.hexdigest()
        self.chain.append({
            'type': 'decryption',
            'hash': new_hash,
            'prev_hash': self.current_hash,
            'verified': verified
        })
        self.current_hash = new_hash
        return new_hash


# =============================================================================
# HASH UTILITIES
# =============================================================================

def hash_message(message: bytes) -> str:
    """Hash message for verification."""
    return hashlib.sha256(message).hexdigest()


def hash_array(arr: np.ndarray) -> str:
    """Hash numpy array for verification."""
    return hashlib.sha256(arr.tobytes()).hexdigest()


# =============================================================================
# CORE DECRYPTION
# =============================================================================

def decrypt(
    ciphertext: FibrationCiphertext,
    credential: FibrationCredential,
    message_hash: Optional[str] = None,
    with_chain: bool = False
) -> bytes:
    """
    Decrypt ciphertext using credential.
    
    Uses direct lattice decoding (not Lindblad flow).
    
    Args:
        ciphertext: FibrationCiphertext to decrypt
        credential: FibrationCredential with secret fibration
        message_hash: Optional expected hash for verification
        with_chain: If True, return (bytes, DecryptionChain) tuple
        
    Returns:
        Decrypted plaintext bytes (or tuple if with_chain=True)
        
    Raises:
        ValueError: If validation fails
    """
    from .checkpoints import validate_decryption_request
    
    chain = DecryptionChain()
    
    # HARD VALIDATION GATE
    can_decrypt, reason = validate_decryption_request(ciphertext, credential)
    if not can_decrypt:
        raise ValueError(f"Decryption validation failed: {reason}")
    
    modulus = credential.modulus
    dim = credential.hilbert_dim
    
    # Extract first vertex block (contains message)
    vertices = credential.topology.get(0, [])
    if not vertices:
        raise ValueError("No vertices in topology")
    
    first_vid = vertices[0][0]
    if first_vid not in ciphertext.vertex_blocks:
        raise ValueError("First vertex block missing from ciphertext")
    
    msg_block = ciphertext.vertex_blocks[first_vid]
    
    # Direct lattice decoding
    decrypted = _decode_lattice(msg_block[:dim], modulus, ciphertext.message_length)
    
    # Hash verification
    decrypted_hash = hash_message(decrypted)
    verified = (message_hash is None) or (decrypted_hash == message_hash)
    
    # Record in chain
    chain.add_decryption_record(
        decrypted_hash=decrypted_hash,
        expected_hash=message_hash or "none",
        verified=verified
    )
    
    if with_chain:
        return decrypted, chain
    return decrypted


def _decode_lattice(lattice: np.ndarray, modulus: int, message_length: int = 0) -> bytes:
    """
    Decode lattice element to bytes.
    
    Values near q/2 → 1, values near 0 → 0.
    """
    threshold = modulus / 4
    
    # Extract bits
    bits = []
    for val in lattice:
        val = val % modulus
        if threshold < val < (3 * threshold):
            bits.append(1)
        else:
            bits.append(0)
    
    # Convert bits to bytes
    msg_bytes = bytearray()
    for i in range(0, len(bits) - 7, 8):
        byte = 0
        for j in range(8):
            byte |= (bits[i + j] << j)
        msg_bytes.append(byte)
    
    # Truncate to known message length if provided
    if message_length > 0:
        msg_bytes = msg_bytes[:message_length]
    else:
        while msg_bytes and msg_bytes[-1] == 0:
            msg_bytes.pop()
    
    return bytes(msg_bytes)


# =============================================================================
# PROJECTIVE MEASUREMENT (for ZK proofs)
# =============================================================================

def projective_measurement(
    ciphertext: FibrationCiphertext,
    credential: FibrationCredential,
    chain: Optional[DecryptionChain] = None
) -> Tuple[np.ndarray, np.ndarray, DecryptionChain]:
    """
    Take projective measurement (harmonic projection).
    
    This is for ZK proofs, NOT for decryption.
    Returns the harmonic component (lives in ker(Δ)) and eigenvalue info.
    
    Args:
        ciphertext: Ciphertext to measure
        credential: Credential with secret Laplacian
        chain: Optional existing chain to continue
        
    Returns:
        (harmonic_component, eigenvalues, updated_chain)
    """
    if chain is None:
        chain = DecryptionChain()
    
    modulus = credential.modulus
    dim = credential.hilbert_dim
    
    # Reconstruct full cochain
    vertices = credential.topology.get(0, [])
    cochain = np.zeros(len(vertices) * dim)
    
    for i, v in enumerate(vertices):
        vid = v[0]
        if vid in ciphertext.vertex_blocks:
            block = ciphertext.vertex_blocks[vid]
            cochain[i*dim:(i+1)*dim] = block[:dim]
    
    # Hash pre-projection state
    pre_hash = hash_array(cochain)
    
    # Build Laplacian and project
    laplacian = SheafLaplacian(credential.fibration.sheaf)
    eigenvalues, eigenvectors = laplacian.eigendecomposition(0)
    
    # Find kernel (harmonic subspace)
    kernel_mask = eigenvalues < 1e-6
    if np.any(kernel_mask):
        kernel_basis = eigenvectors[:, kernel_mask]
        # Ensure dimensions match
        if len(cochain) != kernel_basis.shape[0]:
            n = kernel_basis.shape[0]
            if len(cochain) > n:
                cochain = cochain[:n]
            else:
                cochain = np.pad(cochain, (0, n - len(cochain)))
        
        coeffs = kernel_basis.T @ cochain
        harmonic = kernel_basis @ coeffs
    else:
        harmonic = np.zeros_like(cochain)
    
    # Hash post-projection state
    harmonic_hash = hash_array(harmonic)
    eigenvalue_hash = hash_array(eigenvalues)
    
    # Record measurement
    chain.add_projection_record(
        pre_projection_hash=pre_hash,
        harmonic_hash=harmonic_hash,
        eigenvalue_hash=eigenvalue_hash
    )
    
    return harmonic, eigenvalues, chain


# =============================================================================
# FULL DECRYPTION WITH VERIFICATION
# =============================================================================

def decrypt_with_verification(
    ciphertext: FibrationCiphertext,
    credential: FibrationCredential,
    message_hash: Optional[str] = None
) -> Tuple[bytes, bool, DecryptionChain]:
    """
    Full decryption with hash verification and projective measurement.
    
    Pipeline:
    1. Direct lattice decryption (gets message)
    2. Projective measurement (for ZK proofs)
    3. Hash verification (confirms correctness)
    
    Args:
        ciphertext: FibrationCiphertext to decrypt
        credential: FibrationCredential
        message_hash: Optional expected message hash
        
    Returns:
        (decrypted_message, is_verified, chain)
    """
    # Step 1: Direct decryption
    decrypted, chain = decrypt(ciphertext, credential, message_hash, with_chain=True)
    
    # Step 2: Projective measurement (for ZK proofs)
    harmonic, eigenvalues, chain = projective_measurement(ciphertext, credential, chain)
    
    # Step 3: Verify
    if message_hash is not None:
        actual_hash = hash_message(decrypted)
        verified = (actual_hash == message_hash)
    else:
        verified = True
    
    return decrypted, verified, chain


# =============================================================================
# SENDER VERIFICATION
# =============================================================================

def verify_sender(
    ciphertext: FibrationCiphertext,
    known_fingerprints: dict
) -> Optional[str]:
    """
    Verify sender identity from spectral fingerprint.
    
    Args:
        ciphertext: Received ciphertext
        known_fingerprints: Dict mapping name → fingerprint hash
        
    Returns:
        Sender name if recognized, None otherwise
    """
    sender_fp = ciphertext.sender_fingerprint
    
    for name, known_fp in known_fingerprints.items():
        if sender_fp == known_fp:
            return name
    
    return None
