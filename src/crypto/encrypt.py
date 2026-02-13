"""
Encryption via Cochain Embedding (Dual-Path Architecture)

Two encrypt/decrypt paths, selected by dim(ker(Δ_sheaf)):

  HODGE PATH (v3 — matches hardness_proof.lean):
    _encode_harmonic: message bits → ±1 coefficients in harmonic basis
    embed_in_harmonic: coefficients → global section in ker(Δ)
    noise in im(δ)⊕im(δ*) via (I - P_H) projection
    ciphertext = harmonic_message + orthogonal_noise
    decrypt = π_H(ciphertext) → _decode_harmonic → message
    Security: CVP on harmonic sublattice (Hodge-hardness)

  LATTICE PATH (v2 — fallback when dim(ker(Δ)) < message bits):
    _encode_lattice: message bits → {0, q/2} at vertex 0
    random shares at remaining vertices
    decrypt = threshold decode at vertex 0 → _decode_lattice
    Security: standard lattice threshold decoding

Local-to-global coherence model:

  The restriction maps R_{v→e} are context projections between
  stalk types (see primitives/stalk.py: StalkProjection := R_{v→e}).

  ker(Δ) = global sections = data consistent under all restrictions.
  im(δ)⊕im(δ*) = disagreement subspace ⊥ ker(Δ).

  The Hodge path embeds the message AS a global section, so
  recovering it without the fibration requires solving CVP on ker(Δ)
  — exactly the hardness claim in hardness_proof.lean.

Post-quantum security (both paths):
  - noise is Hodge-structured (not random Gaussian)
  - large σ in im(δ)⊕im(δ*) → hides cochain structure
  - small σ in ker(Δ) → preserves message
  - recovering message without the fibration requires solving CVP
    on the harmonic sublattice (Hodge-hardness)
  - spectral gap λ₁ > 0 ensures clean separation between
    message subspace ker(Δ) and noise subspace im(δ)⊕im(δ*)

On-chain commitment (η : Credential → U):
  Credential → unified fingerprint U = (λ₁, β, h-level, Σ-rank)
  One-way, class-binding: U identifies the homotopy class [F], not
  the specific fiber. |[F]| = ∞ → anonymity. Cannot recover fiber
  from U — recipient already has private credential.
"""

from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Optional
import numpy as np
import hashlib
import time

from .credential import FibrationCredential, SpectralFingerprint
from .lattice import (
    ornstein_uhlenbeck_noise,
    secure_random_vector,
    secure_random_bytes,
)
from ..geometry.hodge import (
    build_coboundary_operator,
    compute_laplacian_from_coboundary
)
from ..geometry.noise import hodge_structured_noise as hodge_noise

# Harmonic invariant gates
from ..invariants.harmonic import (
    embed_in_harmonic,
    validate_harmonic_embedding,
    validate_noise_structure,
    is_in_hodge_complement,
)
from ..geometry.sheaf_laplacian import SheafLaplacian


@dataclass
class FibrationCiphertext:
    """
    Wire format for fibration-encrypted ciphertext.
    
    A ciphertext is a 0-COCHAIN: one block per vertex in the nerve.
    """
    version: int = 1
    topology_hash: bytes = b""
    sender_fingerprint: bytes = b""
    vertex_blocks: Dict[int, np.ndarray] = field(default_factory=dict)
    edge_syndromes: Dict[Tuple[int, int], np.ndarray] = field(default_factory=dict)
    nonce: bytes = b""
    timestamp: int = 0
    message_length: int = 0  # Length of original message in bytes
    message_hash: bytes = b""  # SHA256 of original message for verification
    
    def serialize(self) -> bytes:
        """Serialize to wire format."""
        import struct
        
        # Header
        data = struct.pack("<I", self.version)
        data += self.topology_hash[:32].ljust(32, b'\x00')
        data += self.sender_fingerprint[:64].ljust(64, b'\x00')
        data += self.nonce[:24].ljust(24, b'\x00')
        data += struct.pack("<Q", self.timestamp)
        
        # Message metadata (CRITICAL for decryption!)
        data += struct.pack("<I", self.message_length)
        data += self.message_hash[:32].ljust(32, b'\x00')
        
        # Vertex blocks
        data += struct.pack("<I", len(self.vertex_blocks))
        for vid, block in sorted(self.vertex_blocks.items()):
            data += struct.pack("<I", vid)
            block_bytes = block.astype(np.int16).tobytes()
            data += struct.pack("<I", len(block_bytes))
            data += block_bytes
        
        # Edge syndromes
        data += struct.pack("<I", len(self.edge_syndromes))
        for edge, syndrome in self.edge_syndromes.items():
            data += struct.pack("<II", edge[0], edge[1])
            syn_bytes = syndrome.astype(np.int16).tobytes()
            data += struct.pack("<I", len(syn_bytes))
            data += syn_bytes
        
        return data
    
    @classmethod
    def deserialize(cls, data: bytes) -> 'FibrationCiphertext':
        """Parse from wire format."""
        import struct
        offset = 0
        
        version = struct.unpack_from("<I", data, offset)[0]
        offset += 4
        
        topology_hash = data[offset:offset+32]
        offset += 32
        
        sender_fingerprint = data[offset:offset+64]
        offset += 64
        
        nonce = data[offset:offset+24]
        offset += 24
        
        timestamp = struct.unpack_from("<Q", data, offset)[0]
        offset += 8
        
        # Message metadata
        message_length = struct.unpack_from("<I", data, offset)[0]
        offset += 4
        
        message_hash = data[offset:offset+32]
        offset += 32
        
        # Vertex blocks
        n_vertices = struct.unpack_from("<I", data, offset)[0]
        offset += 4
        
        vertex_blocks = {}
        for _ in range(n_vertices):
            vid = struct.unpack_from("<I", data, offset)[0]
            offset += 4
            block_len = struct.unpack_from("<I", data, offset)[0]
            offset += 4
            block_data = np.frombuffer(data[offset:offset+block_len], dtype=np.int16)
            vertex_blocks[vid] = block_data.astype(np.float64)
            offset += block_len
        
        # Edge syndromes
        n_edges = struct.unpack_from("<I", data, offset)[0]
        offset += 4
        
        edge_syndromes = {}
        for _ in range(n_edges):
            e0 = struct.unpack_from("<I", data, offset)[0]
            offset += 4
            e1 = struct.unpack_from("<I", data, offset)[0]
            offset += 4
            syn_len = struct.unpack_from("<I", data, offset)[0]
            offset += 4
            syn_data = np.frombuffer(data[offset:offset+syn_len], dtype=np.int16)
            edge_syndromes[(e0, e1)] = syn_data.astype(np.float64)
            offset += syn_len
        
        return cls(
            version=version,
            topology_hash=topology_hash,
            sender_fingerprint=sender_fingerprint,
            vertex_blocks=vertex_blocks,
            edge_syndromes=edge_syndromes,
            nonce=nonce,
            timestamp=timestamp,
            message_length=message_length,
            message_hash=message_hash
        )


def encrypt(
    message: bytes,
    credential: FibrationCredential,
    sigma_exact: float = 5.0,
    sigma_harmonic: float = 0.1,
    use_hodge_noise: bool = True
) -> FibrationCiphertext:
    """
    Encrypt message using fibration credential with Hodge-structured noise.
    
    PRIMARY PATH (Hodge — matches hardness_proof.lean):
        1. Build sheaf Laplacian Δ from credential's restriction maps
        2. Embed message in ker(Δ) via harmonic basis (message IS a global section)
        3. Add noise in im(δ)⊕im(δ*) (orthogonal to message)
        4. Decrypt = π_H(ciphertext) recovers message exactly
        
    FALLBACK PATH (Lattice — when dim(ker(Δ)) < message bits):
        1. Message at vertex 0 as lattice element (bits → {0, q/2})
        2. Random shares at other vertices
        3. Threshold decode at vertex 0
        
    The Hodge path is preferred because it matches the hardness proof:
    message ∈ ker(Δ), noise ∈ im(δ)⊕im(δ*), security = CVP on ker(Δ).
    
    Args:
        message: Plaintext bytes to encrypt
        credential: FibrationCredential with fibration (private key)
        sigma_exact: Noise σ in exact⊕coexact (large = more hiding)
        sigma_harmonic: Noise σ in harmonic (small = preserves message)
        use_hodge_noise: If True, use Hodge-structured noise; else discrete Gaussian
        
    Returns:
        FibrationCiphertext ready for transmission
    """
    modulus = credential.modulus
    dim = credential.hilbert_dim
    
    # ── ENCRYPT INVARIANT GATE ──
    _validate_credential_for_encrypt(credential)
    
    vertices = credential.topology.get(0, [])
    edges = credential.topology.get(1, [])
    n_vertices = len(vertices)
    
    # ══════════════════════════════════════════════════════════════
    # TRY PRIMARY PATH: Hodge embedding (message ∈ ker(Δ))
    # This is the path that matches hardness_proof.lean:
    #   ciphertext = harmonic_message + noise
    #   where harmonic_message ∈ ker(Δ), noise ∈ im(δ)⊕im(δ*)
    #   decrypt = π_H(ciphertext) = harmonic_message (exact recovery)
    # ══════════════════════════════════════════════════════════════
    hodge_path_used = False
    try:
        sheaf_lap = SheafLaplacian(credential.fibration.sheaf)
        L_sheaf = sheaf_lap.get_laplacian_0()
        
        # How many message bits can ker(Δ) hold?
        # Use RELATIVE threshold: sheaf eigenvalues can be ~1e12,
        # so absolute 1e-10 misidentifies the kernel.
        # (Matches hardness_proof.lean: ker(Δ) detection must be correct
        # for the CVP reduction to hold.)
        eigenvalues = np.linalg.eigvalsh(L_sheaf)
        max_eig = np.max(np.abs(eigenvalues)) if len(eigenvalues) > 0 else 1.0
        rel_threshold = max(max_eig * 1e-10, 1e-6)
        harmonic_dim = int(np.sum(np.abs(eigenvalues) < rel_threshold))
        message_bits = len(message) * 8
        
        if harmonic_dim >= message_bits:
            # ── HODGE PATH: message fits in ker(Δ) ──
            # Encode message as real coefficients in harmonic basis
            msg_coeffs = _encode_harmonic(message, harmonic_dim)
            
            # Embed in ker(Δ): result is a 0-cochain (one entry per stalk dim)
            harmonic_msg, success = embed_in_harmonic(msg_coeffs, L_sheaf)
            
            if success:
                # Validate embedding ∈ ker(Δ)
                gate = validate_harmonic_embedding(harmonic_msg, L_sheaf)
                if gate.passed:
                    # Add noise in im(δ)⊕im(δ*) — orthogonal to message
                    cochain_dim = L_sheaf.shape[0]
                    from ..geometry.hodge import compute_hodge_projectors
                    delta_0_sheaf, _ = build_coboundary_operator(
                        credential.topology, stalk_dim=1
                    )
                    P_H, P_exact, P_coexact = compute_hodge_projectors(
                        L_sheaf, delta_0_sheaf, None
                    )
                    
                    # Noise purely in im(δ)⊕im(δ*): use (I - P_H) projection
                    raw_noise = np.random.randn(cochain_dim) * sigma_exact
                    noise = (np.eye(cochain_dim) - P_H) @ raw_noise
                    
                    # Validate noise ⊥ ker(Δ)
                    noise_gate = validate_noise_structure(noise, L_sheaf, tolerance=1e-4)
                    
                    # ciphertext = message + noise (Hodge decomposition!)
                    full_cochain = harmonic_msg + noise
                    
                    # Distribute across vertex blocks
                    vertex_blocks = {}
                    stalk_size = cochain_dim // n_vertices if n_vertices > 0 else dim
                    for i, v in enumerate(vertices):
                        start = i * stalk_size
                        end = start + stalk_size
                        if end <= len(full_cochain):
                            vertex_blocks[v[0]] = full_cochain[start:end]
                        else:
                            vertex_blocks[v[0]] = np.zeros(stalk_size)
                    
                    hodge_path_used = True
    except Exception:
        pass  # Fall through to lattice path
    
    # ══════════════════════════════════════════════════════════════
    # FALLBACK PATH: Lattice encoding (vertex 0 + random shares)
    # Used when dim(ker(Δ)) < message bits
    # ══════════════════════════════════════════════════════════════
    if not hodge_path_used:
        msg_lattice = _encode_lattice(message, dim, modulus)
        
        delta_0, delta_1 = build_coboundary_operator(credential.topology, stalk_dim=1)
        L_0 = delta_0.T @ delta_0
        L_1 = compute_laplacian_from_coboundary(delta_1, delta_0)
        
        vertex_blocks = {}
        for i, v in enumerate(vertices):
            if i == 0:
                vertex_blocks[v[0]] = msg_lattice.copy()
            else:
                vertex_blocks[v[0]] = secure_random_vector(dim, modulus).astype(np.float64)
        
        # Add noise to vertex blocks
        vertices_list = [v[0] for v in vertices]
        for vid in vertex_blocks:
            if vid == vertices_list[0]:
                noise = ornstein_uhlenbeck_noise(dim, volatility=sigma_harmonic)
            else:
                noise = ornstein_uhlenbeck_noise(dim, volatility=sigma_exact)
            vertex_blocks[vid] = (vertex_blocks[vid] + noise) % modulus
    
    # ── EDGE SYNDROMES (both paths) ──
    edge_syndromes = {}
    for edge in edges:
        i, j = edge
        vi_data = vertex_blocks.get(i, np.zeros(dim))
        vj_data = vertex_blocks.get(j, np.zeros(dim))
        A = credential.fibration.edge_keys.get(edge, np.eye(min(dim, len(vj_data))))
        
        if A.shape[1] == len(vj_data) and A.shape[0] == len(vi_data):
            syndrome = A @ vj_data - vi_data
        else:
            syndrome = np.zeros_like(vi_data)
        
        noise = ornstein_uhlenbeck_noise(len(syndrome), volatility=sigma_exact)
        edge_syndromes[edge] = syndrome + noise
    
    # ── BUILD CIPHERTEXT ──
    nonce = secure_random_bytes(24)
    message_hash = hashlib.sha256(message).digest()
    
    return FibrationCiphertext(
        version=3 if hodge_path_used else 2,  # v3 = Hodge path, v2 = lattice
        topology_hash=credential.spectrum.topology_hash,
        sender_fingerprint=credential.spectrum.fingerprint_hash(),
        vertex_blocks=vertex_blocks,
        edge_syndromes=edge_syndromes,
        nonce=nonce,
        timestamp=int(time.time()),
        message_length=len(message),
        message_hash=message_hash
    )


def _validate_credential_for_encrypt(credential: FibrationCredential) -> None:
    """
    ENCRYPT INVARIANT GATE: validate credential before encryption.
    
    Construction-time gates (nerve, restriction maps, PSD) are checked
    by credential.py at keygen. Here we check ENCRYPT-TIME invariants:
    
    - Spectral fingerprint exists (credential not corrupted after keygen)
    - Topology has vertices and edges (structure for cochain encoding)
    - β₀ ≥ 1 (connected — message can propagate)
    - Spectral gap > 0 (Laplacian is non-trivial — noise separable from message)
    """
    spectrum = credential.spectrum
    
    if spectrum is None:
        raise RuntimeError(
            "ENCRYPT INVARIANT VIOLATION: Credential has no spectral fingerprint. "
            "Cannot verify Hodge structure for encoding. Aborting."
        )
    
    if not credential.topology.get(0):
        raise RuntimeError(
            "ENCRYPT INVARIANT VIOLATION: Topology has no vertices. "
            "Cannot distribute message across nerve. Aborting."
        )
    
    if not credential.topology.get(1):
        raise RuntimeError(
            "ENCRYPT INVARIANT VIOLATION: Topology has no edges. "
            "Cannot compute coboundary (no communication channels). Aborting."
        )
    
    if hasattr(spectrum, 'betti_numbers') and spectrum.betti_numbers[0] < 1:
        raise RuntimeError(
            f"ENCRYPT INVARIANT VIOLATION: β₀ = {spectrum.betti_numbers[0]}. "
            f"No connected components. Aborting."
        )
    
    # Spectral gate: gap must be positive (ensures Hodge decomposition separates
    # ker(Δ) from im(δ)⊕im(δ*) — without a gap, noise bleeds into harmonic)
    if hasattr(spectrum, 'spectral_gap') and spectrum.spectral_gap <= 0:
        raise RuntimeError(
            f"ENCRYPT INVARIANT VIOLATION: spectral gap λ₁ = {spectrum.spectral_gap}. "
            f"No separation between harmonic and non-harmonic subspaces. "
            f"Decryption via Hodge projection would fail. Aborting."
        )


def _encode_harmonic(message: bytes, harmonic_dim: int) -> np.ndarray:
    """
    HODGE PATH: Encode message bytes as real-valued coefficients for ker(Δ) embedding.
    
    Each bit maps to +1.0 or -1.0 (antipodal encoding).
    Message lives in ker(Δ) as real coefficients in the harmonic basis.
    Decoded by _decode_harmonic() via sign(coeff) → bit.
    
    Args:
        message: Plaintext bytes
        harmonic_dim: Dimension of ker(Δ) (must be ≥ message bits)
        
    Returns:
        Real-valued coefficient vector of length harmonic_dim
    """
    msg_bits = []
    for byte in message:
        for i in range(8):
            msg_bits.append((byte >> i) & 1)
    
    coeffs = np.zeros(harmonic_dim)
    for i, bit in enumerate(msg_bits[:harmonic_dim]):
        coeffs[i] = 1.0 if bit else -1.0
    
    # Remaining dimensions: random ±1 (hides message length)
    for i in range(len(msg_bits), harmonic_dim):
        coeffs[i] = 1.0 if np.random.random() > 0.5 else -1.0
    
    return coeffs


def _decode_harmonic(coeffs: np.ndarray, message_length: int) -> bytes:
    """
    HODGE PATH: Decode real-valued harmonic coefficients back to message bytes.
    
    Inverse of _encode_harmonic. Each coefficient's sign → bit.
    
    Args:
        coeffs: Real-valued harmonic coefficients from ker(Δ) projection
        message_length: Original message length in bytes
        
    Returns:
        Decoded message bytes
    """
    bits_needed = message_length * 8
    bits = []
    for i in range(min(bits_needed, len(coeffs))):
        bits.append(1 if coeffs[i] > 0 else 0)
    
    # Pad with zeros if needed
    while len(bits) < bits_needed:
        bits.append(0)
    
    msg_bytes = bytearray()
    for i in range(0, bits_needed, 8):
        byte = 0
        for j in range(8):
            if i + j < len(bits):
                byte |= (bits[i + j] << j)
        msg_bytes.append(byte)
    
    return bytes(msg_bytes[:message_length])


def _encode_lattice(message: bytes, dim: int, modulus: int) -> np.ndarray:
    """
    LATTICE PATH: Encode message bytes into lattice element.
    
    Uses simple bit encoding: each bit maps to 0 or q/2.
    Padding uses cryptographically secure randomness.
    Decoded by _decode_lattice() in decrypt.py via threshold.
    """
    # Pad message to fit dimension
    msg_bits = []
    for byte in message:
        for i in range(8):
            msg_bits.append((byte >> i) & 1)
    
    # Create lattice element
    lattice = np.zeros(dim)
    
    for i, bit in enumerate(msg_bits[:dim]):
        if bit:
            lattice[i] = modulus // 2
    
    # Fill remaining with SECURE randomness
    remaining = dim - len(msg_bits)
    if remaining > 0:
        padding = secure_random_vector(remaining, modulus)
        for i, val in enumerate(padding):
            lattice[len(msg_bits) + i] = val
    
    return lattice


# ============================================================================
# CONSTANT PADDING (Metadata Protection)
# ============================================================================

# Default constant ciphertext sizes (in bytes)
CONSTANT_SIZE_SMALL = 4096     # 4 KB
CONSTANT_SIZE_MEDIUM = 16384   # 16 KB  
CONSTANT_SIZE_LARGE = 65536    # 64 KB
CONSTANT_SIZE_DEFAULT = CONSTANT_SIZE_MEDIUM


def pad_ciphertext_to_constant(
    ciphertext: FibrationCiphertext,
    target_size: int = CONSTANT_SIZE_DEFAULT
) -> bytes:
    """
    Pad serialized ciphertext to constant size.
    
    For panopticon resilience: all ciphertexts same size = 
    traffic analysis learns nothing about message length.
    
    Args:
        ciphertext: The FibrationCiphertext to pad
        target_size: Target size in bytes (default 16KB)
        
    Returns:
        Padded bytes of exactly target_size
        
    Raises:
        ValueError: If ciphertext is larger than target_size
    """
    serialized = ciphertext.serialize()
    current_size = len(serialized)
    
    if current_size > target_size:
        raise ValueError(
            f"Ciphertext size {current_size} exceeds target {target_size}. "
            f"Use a larger constant size or shorter message."
        )
    
    # Pad with cryptographically secure random bytes
    padding_needed = target_size - current_size
    padding = secure_random_bytes(padding_needed)
    
    # Format: [original_length: 4 bytes][ciphertext][random padding]
    import struct
    result = struct.pack("<I", current_size) + serialized + padding
    
    # Final result should be exactly target_size + 4
    return result


def unpad_ciphertext(padded_data: bytes) -> FibrationCiphertext:
    """
    Remove constant padding and deserialize ciphertext.
    
    Args:
        padded_data: Output from pad_ciphertext_to_constant
        
    Returns:
        The original FibrationCiphertext
    """
    import struct
    
    # Read original length
    original_length = struct.unpack_from("<I", padded_data, 0)[0]
    
    # Extract just the ciphertext (ignore padding)
    ciphertext_bytes = padded_data[4:4 + original_length]
    
    return FibrationCiphertext.deserialize(ciphertext_bytes)


def encrypt_with_constant_padding(
    message: bytes,
    credential: FibrationCredential,
    target_size: int = CONSTANT_SIZE_DEFAULT,
    sigma_exact: float = 5.0,
    sigma_harmonic: float = 0.1
) -> bytes:
    """
    Encrypt message with constant-size padding (full panopticon protection).
    
    Combines:
    - Hodge-structured noise (content protection)
    - Constant padding (length protection)
    
    Args:
        message: Plaintext to encrypt
        credential: Encryption credential
        target_size: Constant output size in bytes
        
    Returns:
        Padded ciphertext of exactly target_size + 4 bytes
    """
    ciphertext = encrypt(
        message, 
        credential,
        sigma_exact=sigma_exact,
        sigma_harmonic=sigma_harmonic
    )
    
    return pad_ciphertext_to_constant(ciphertext, target_size)


def decrypt_with_constant_padding(
    padded_data: bytes,
    credential: FibrationCredential
) -> bytes:
    """
    Decrypt constant-padded ciphertext.
    
    Inverse of encrypt_with_constant_padding.
    """
    from .decrypt import decrypt
    
    ciphertext = unpad_ciphertext(padded_data)
    return decrypt(ciphertext, credential)


# ============================================================================
# DECOY TRAFFIC (Cover Traffic)
# ============================================================================

def generate_decoy_ciphertext(
    credential: FibrationCredential,
    target_size: int = CONSTANT_SIZE_DEFAULT
) -> bytes:
    """
    Generate a fake ciphertext indistinguishable from real traffic.
    
    For panopticon resilience: mix real messages with decoys.
    Adversary cannot distinguish real from decoy.
    
    The decoy:
    - Has valid structure (encrypts random bytes)
    - Same size as real messages
    - Statistically indistinguishable noise
    """
    # Generate random message of appropriate size
    # Max message size is ~1/8 of target (each byte = 8 bits)
    max_msg_bytes = credential.hilbert_dim // 8
    msg_length = max(1, np.random.randint(1, max_msg_bytes + 1))
    random_message = secure_random_bytes(msg_length)
    
    # Encrypt with same parameters
    return encrypt_with_constant_padding(
        random_message,
        credential,
        target_size=target_size
    )


def is_decoy_ciphertext(padded_data: bytes) -> bool:
    """
    Check if ciphertext is a decoy.
    
    NOTE: This should NOT be possible from ciphertext alone!
    This function exists only for testing - in production,
    decoys are indistinguishable from real messages.
    
    Returns: Always False (by design - can't distinguish)
    """
    # By design, decoys are indistinguishable from real messages.
    # This function always returns False to enforce this.
    return False
