"""
Decryption via Lindblad Flow to Harmonic Subspace

Decryption process:
1. Parse ciphertext cochain
2. Build sheaf Laplacian from credential
3. Run Lindblad flow: dρ/dt = -Δρ
4. Project to harmonic subspace ker(Δ)
5. Extract message from harmonic representative

The key insight: valid messages live in ker(Δ) = global sections.
This is the ∀x.φ(x) from Helfer's homotopical logic!
"""

from typing import Optional
import numpy as np

from .credential import FibrationCredential
from .encrypt import FibrationCiphertext
from ..geometry.sheaf_laplacian import SheafLaplacian


def decrypt(
    ciphertext: FibrationCiphertext,
    credential: FibrationCredential,
    n_iterations: int = 100,
    step_size: float = 0.1
) -> bytes:
    """
    Decrypt ciphertext using fibration credential.
    
    Uses Lindblad flow to project noisy cochain to harmonic subspace,
    then extracts the encoded message.
    
    Args:
        ciphertext: FibrationCiphertext to decrypt
        credential: FibrationCredential with fibration (private key)
        n_iterations: Number of Lindblad flow iterations
        step_size: Step size for flow (smaller = more accurate, slower)
        
    Returns:
        Decrypted plaintext bytes
    """
    # 1. Verify topology matches
    if ciphertext.topology_hash != credential.spectrum.topology_hash:
        raise ValueError("Topology mismatch: ciphertext not for this credential")
    
    modulus = credential.modulus
    dim = credential.hilbert_dim
    
    # 2. Reconstruct cochain from vertex blocks
    vertices = credential.topology.get(0, [])
    cochain = np.zeros(len(vertices) * dim)
    
    for i, v in enumerate(vertices):
        vid = v[0]
        if vid in ciphertext.vertex_blocks:
            block = ciphertext.vertex_blocks[vid]
            cochain[i*dim:(i+1)*dim] = block[:dim]
    
    # 3. Build Laplacian from secret fibration
    laplacian = SheafLaplacian(credential.fibration.sheaf)
    L = laplacian.get_laplacian_0()
    
    # Ensure dimensions match
    if L.shape[0] != len(cochain):
        # Resize cochain or use simplified Laplacian
        n = L.shape[0]
        if len(cochain) > n:
            cochain = cochain[:n]
        else:
            cochain = np.pad(cochain, (0, n - len(cochain)))
    
    # 4. Lindblad flow: x(t+dt) = x(t) - dt * L @ x(t)
    # This converges to ker(L) = harmonic cochains
    x = cochain.copy()
    
    for _ in range(n_iterations):
        x = x - step_size * (L @ x)
        # Keep values bounded (mod arithmetic in float)
        x = np.mod(x, modulus)
    
    # 5. Project to harmonic subspace (final cleanup)
    harmonic, _ = laplacian.harmonic_projection(x)
    
    # If harmonic is empty, use x directly
    if np.linalg.norm(harmonic) < 1e-10:
        harmonic = x
    
    # 6. Extract message from first vertex block
    msg_lattice = harmonic[:dim]
    
    # 7. Decode lattice element to bytes
    return _decode_message(msg_lattice, modulus)


def _decode_message(lattice: np.ndarray, modulus: int) -> bytes:
    """
    Decode lattice element back to message bytes.
    
    Reverses the encoding: values near q/2 → 1, near 0 → 0.
    """
    threshold = modulus / 4
    
    # Extract bits
    bits = []
    for val in lattice:
        # Values in [q/4, 3q/4] decode to 1
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
    
    # Strip trailing nulls
    while msg_bytes and msg_bytes[-1] == 0:
        msg_bytes.pop()
    
    return bytes(msg_bytes)


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
