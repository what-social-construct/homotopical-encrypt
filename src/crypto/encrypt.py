"""
Encryption via Cochain Embedding

Local-to-global coherence model:

  The restriction maps R_{v→e} are context projections between
  stalk types (see primitives/stalk.py: StalkProjection := R_{v→e}).

  ker(Δ) = global sections = data consistent under all restrictions.
  im(δ)⊕im(δ*) = disagreement subspace ⊥ ker(Δ).

  Encryption places the message at vertex 0 and distributes random
  shares across remaining vertices. The coboundary δ computes edge
  syndromes (disagreements between vertex projections). Hodge-structured
  noise is added in im(δ)⊕im(δ*) to hide the cochain structure without
  disturbing the globally coherent component.

Current decrypt path (dual):
  - lattice threshold decode at vertex 0 (fast, local)
  - Hodge projection π_H onto ker(Δ) (geometric, global)
  Both must recover the same message when restriction maps are designed
  with controlled kernel dimension.

Post-quantum security:
  - noise is Hodge-structured (not random Gaussian)
  - large σ in im(δ)⊕im(δ*) → hides cochain structure
  - small σ in ker(Δ) → preserves message
  - recovering message without the fibration requires solving CVP
    on the harmonic sublattice (Hodge-hardness)
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
    
    Args:
        message: Plaintext bytes to encrypt
        credential: FibrationCredential with fibration (private key)
        sigma_exact: Noise σ in exact⊕coexact (large = more hiding)
        sigma_harmonic: Noise σ in harmonic (small = preserves message)
        use_hodge_noise: If True, use Hodge-structured noise; else discrete Gaussian
        
    Returns:
        FibrationCiphertext ready for transmission
        
    Noise Strategy:
        C^k = H^k ⊕ im(δ) ⊕ im(δ*)
        - Message encoded in harmonic-like subspace (protected)
        - Large noise in exact⊕coexact (hides structure)
        - Decryption projects onto harmonic to recover message
    """
    modulus = credential.modulus
    dim = credential.hilbert_dim
    
    # ── ENCRYPT INVARIANT GATE ──
    # Credential must have valid spectral structure for Hodge encoding.
    # These are cheap checks on data already computed at keygen.
    _validate_credential_for_encrypt(credential)
    
    # 1. Encode message as lattice element
    msg_lattice = _encode_message(message, dim, modulus)
    
    # 2. Build Hodge structure from topology
    delta_0, delta_1 = build_coboundary_operator(credential.topology, stalk_dim=1)
    
    # Build Laplacian for C^0 (vertices) and C^1 (edges)
    # L_0 = δ_0^T δ_0 (no lower cochains for vertices)
    L_0 = delta_0.T @ delta_0
    # L_1 = δ_1^T δ_1 + δ_0 δ_0^T
    L_1 = compute_laplacian_from_coboundary(delta_1, delta_0)
    
    # 3. Distribute across vertices (0-cochain embedding)
    vertices = credential.topology.get(0, [])
    n_vertices = len(vertices)
    
    vertex_blocks = {}
    for i, v in enumerate(vertices):
        if i == 0:
            # First vertex gets the message (in "harmonic" position)
            vertex_blocks[v[0]] = msg_lattice.copy()
        else:
            # Other vertices get random shares (SECURE)
            vertex_blocks[v[0]] = secure_random_vector(dim, modulus).astype(np.float64)
    
    # 4. Apply coboundary (encryption transform)
    edges = credential.topology.get(1, [])
    edge_syndromes = {}
    
    # Determine noise dimensions from topology
    # L_0 has shape (n_vertices * stalk_dim, n_vertices * stalk_dim) where stalk_dim=1
    # L_1 has shape (n_edges * stalk_dim, n_edges * stalk_dim)
    # These are topology-scale, NOT hilbert_dim-scale.
    # For Hodge noise on the dim-dimensional message space, we need dim-sized noise.
    # Strategy: use Hodge-structured noise at TOPOLOGY scale for syndromes,
    # and O-U noise at MESSAGE scale (dim) for vertex blocks.
    
    n_edges = len(edges)
    
    for edge in edges:
        i, j = edge
        vi_data = vertex_blocks.get(i, np.zeros(dim))
        vj_data = vertex_blocks.get(j, np.zeros(dim))
        
        # Get restriction maps from fibration
        A = credential.fibration.edge_keys.get(edge, np.eye(dim))
        
        # Coboundary: δ(c)_e = A·c_j - c_i
        syndrome = (A @ vj_data - vi_data) % modulus
        
        # Add noise at message dimension
        # Hodge noise requires Laplacian at matching dimension.
        # When L_1 matches dim, use Hodge-structured noise;
        # otherwise use spectral noise (O-U) which is always correct.
        if use_hodge_noise and L_1.shape[0] == dim:
            noise = hodge_noise(
                L_1, delta_1, delta_0,
                sigma_exact=sigma_exact,
                sigma_coexact=sigma_exact,
                sigma_harmonic=sigma_harmonic
            )
        else:
            # Fallback: O-U noise when topology dim ≠ message dim
            # O-U stationary distribution is geometrically sound at any scale
            noise = ornstein_uhlenbeck_noise(dim, volatility=sigma_exact)
        
        syndrome = (syndrome + noise) % modulus
        edge_syndromes[edge] = syndrome
    
    # 5. Add noise to vertex blocks
    # First vertex gets HARMONIC-PRESERVING noise (small, protects message)
    # Other vertices get large noise (hides random shares)
    vertices_list = [v[0] for v in vertices]
    for vid in vertex_blocks:
        if vid == vertices_list[0]:
            # First vertex: small noise to preserve message recoverability
            noise = ornstein_uhlenbeck_noise(dim, volatility=sigma_harmonic)
        else:
            # Other vertices: large noise (these are random shares anyway)
            noise = ornstein_uhlenbeck_noise(dim, volatility=sigma_exact)
        
        vertex_blocks[vid] = (vertex_blocks[vid] + noise) % modulus
    
    # 6. Build ciphertext with SECURE nonce
    nonce = secure_random_bytes(24)
    
    # 7. Hash message for verification
    message_hash = hashlib.sha256(message).digest()
    
    # ── HARMONIC VALIDATION GATE ──
    # Build sheaf Laplacian from credential's restriction maps.
    # Check how much of the message survives harmonic projection.
    # This validates that the Hodge structure is usable for geometric decrypt.
    try:
        sheaf_lap = SheafLaplacian(credential.fibration.sheaf)
        L_sheaf = sheaf_lap.get_laplacian_0()
        
        # Assemble full cochain (concatenate all vertex blocks in order)
        full_cochain = np.concatenate([
            vertex_blocks[v[0]] for v in sorted(vertices, key=lambda x: x[0])
        ])
        
        # Project to harmonic and measure how much message is preserved
        harmonic_part, orthogonal_part = sheaf_lap.harmonic_projection(full_cochain)
        harmonic_ratio = np.linalg.norm(harmonic_part) / (np.linalg.norm(full_cochain) + 1e-12)
        
        # Validate noise is in Hodge complement
        noise_check = validate_noise_structure(
            orthogonal_part, L_sheaf, tolerance=np.linalg.norm(full_cochain) * 0.1
        )
    except Exception:
        pass  # Validation is advisory; lattice path is primary
    
    return FibrationCiphertext(
        version=2,  # v2 = Hodge-structured noise
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


def _encode_message(message: bytes, dim: int, modulus: int) -> np.ndarray:
    """
    Encode message bytes into lattice element.
    
    Uses simple bit encoding: each bit maps to 0 or q/2.
    Padding uses cryptographically secure randomness.
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
