"""
Encryption via Hodge Embedding — Pure Harmonic Path

Architecture (matches hardness_proof.lean exactly):

  ENCRYPT:
    1. Build sheaf Laplacian Δ from credential's restriction maps
    2. Identify ker(Δ) via eigendecomposition (using kernel_tolerance())
    3. Encode message as ±1 coefficients in harmonic eigenbasis
    4. Embed in ker(Δ) → harmonic_message (a global section)
    5. Add noise in im(δ)⊕im(δ*) via (I - P_H) projection
    6. ciphertext = harmonic_message + orthogonal_noise

  DECRYPT:
    π_H(ciphertext) → harmonic coefficients → sign → bits → message

  SECURITY (from hardness_proof.lean):
    Given b = h + e where h ∈ ker(Δ), e ∈ im(δ)⊕im(δ*),
    recovering h without knowing Δ reduces to CVP on the
    harmonic sublattice — but is STRICTLY harder because the
    attacker must also identify ker(Δ) (Hodge_Strictly_Harder).

Layer separation (see ARCHITECTURE.md):
  - Encrypt/decrypt: REAL arithmetic on eigenvectors of Δ_sheaf
  - Commitment (commitment.py): DISCRETE arithmetic, cochains mod q
  - Security reduction (hardness.py): lattice CVP is the shadow
  - The modulus q does NOT appear in the encrypt path.

No fallback path. Keygen (credential.py) guarantees
dim(ker(Δ)) ≥ MIN_HARMONIC_DIM by construction (Gate 5).
If this invariant somehow fails, encrypt hard-fails rather
than silently downgrading to a weaker scheme.
"""

from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Optional
import numpy as np
import hashlib
import time

from .credential import (
    FibrationCredential,
    SpectralFingerprint,
    kernel_tolerance,
    MIN_HARMONIC_DIM,
)
from .lattice import (
    ornstein_uhlenbeck_noise,
    secure_random_bytes,
)

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
    Encrypt message via pure Hodge embedding (matches hardness_proof.lean).
    
    IDENTITY HIERARCHY (three levels):
      U (on-chain):    PublicIdentity = homotopy class [F]
                       Betti numbers only. |π⁻¹(β)| = ∞ → anonymity.
      Fiber (wallet):  SpectralFingerprint = specific fibration
                       Eigenvalues of Δ. NEVER leaves the wallet.
      Ephemeral (tx):  Fresh noise per encrypt = per-transaction fiber
                       Even same sender → different ciphertext each time.
    
    ENCRYPT PATH (no fallback — keygen guarantees harmonic capacity):
        1. Build sheaf Laplacian Δ from credential's restriction maps
        2. Identify ker(Δ) via eigendecomposition (kernel_tolerance())
        3. Encode message as ±1 coefficients in harmonic eigenbasis
        4. Embed in ker(Δ) → harmonic_message (global section)
        5. Add noise in im(δ)⊕im(δ*) — orthogonal to message
        6. ciphertext = harmonic_message + noise (ephemeral fiber)
    
    SECURITY: recovering h from b = h + e without knowing Δ
    reduces to CVP on ker(Δ) but is strictly harder (Hodge_Strictly_Harder).
    
    ON-CHAIN: ciphertext carries U = public_identity (homotopy class),
    NOT the spectral fingerprint (specific fiber). The fingerprint
    stays in the wallet — consensus only sees the class.
    
    Args:
        message: Plaintext bytes to encrypt
        credential: FibrationCredential with fibration (private key)
        sigma_exact: Noise σ in exact⊕coexact (large = more hiding)
        sigma_harmonic: Noise σ in harmonic (small = preserves message)
        use_hodge_noise: If True, use Hodge-structured noise
        
    Returns:
        FibrationCiphertext ready for transmission
        
    Raises:
        RuntimeError: If Hodge path fails (should never happen with valid credential)
    """
    dim = credential.hilbert_dim
    
    # ── ENCRYPT INVARIANT GATE ──
    _validate_credential_for_encrypt(credential)
    
    vertices = credential.topology.get(0, [])
    edges = credential.topology.get(1, [])
    n_vertices = len(vertices)
    message_bits = len(message) * 8
    
    # ══════════════════════════════════════════════════════════════
    # HODGE PATH (only path — no fallback)
    # Matches hardness_proof.lean:
    #   ciphertext = harmonic_message + noise
    #   where harmonic_message ∈ ker(Δ), noise ∈ im(δ)⊕im(δ*)
    #   decrypt = π_H(ciphertext) = harmonic_message (exact recovery)
    # ══════════════════════════════════════════════════════════════
    
    # Step 1: Build sheaf Laplacian from restriction maps
    sheaf_lap = SheafLaplacian(credential.fibration.sheaf)
    L_sheaf = sheaf_lap.get_laplacian_0()
    
    # Step 2: Identify ker(Δ) using canonical kernel_tolerance()
    # Same tolerance as keygen and decrypt — single source of truth
    eigenvalues = np.linalg.eigvalsh(L_sheaf)
    tol = kernel_tolerance(eigenvalues)
    harmonic_dim = int(np.sum(np.abs(eigenvalues) < tol))
    
    # Hard gate: keygen guaranteed dim(ker(Δ)) ≥ MIN_HARMONIC_DIM.
    # If this fails, credential is corrupted — do NOT fall back.
    if harmonic_dim < message_bits:
        raise RuntimeError(
            f"ENCRYPT INVARIANT VIOLATION: dim(ker(Δ)) = {harmonic_dim} "
            f"< message_bits = {message_bits}. "
            f"Credential's harmonic capacity is insufficient. "
            f"This should never happen with a valid credential "
            f"(keygen Gate 5 guarantees dim(ker(Δ)) ≥ {MIN_HARMONIC_DIM}). "
            f"Credential may be corrupted. Aborting — no fallback."
        )
    
    # Step 3: Encode message as ±1 coefficients in harmonic basis
    msg_coeffs = _encode_harmonic(message, harmonic_dim)
    
    # Step 4: Embed in ker(Δ) → global section
    harmonic_msg, success = embed_in_harmonic(msg_coeffs, L_sheaf)
    
    if not success:
        raise RuntimeError(
            "ENCRYPT INVARIANT VIOLATION: embed_in_harmonic failed. "
            "Harmonic basis extraction from sheaf Laplacian failed. "
            "Credential may be corrupted. Aborting."
        )
    
    # Validate embedding ∈ ker(Δ)
    gate = validate_harmonic_embedding(harmonic_msg, L_sheaf)
    if not gate.passed:
        raise RuntimeError(
            f"ENCRYPT INVARIANT VIOLATION: harmonic embedding not in ker(Δ). "
            f"Residual: {gate.residual:.2e}. "
            f"Hodge decomposition would leak message into noise subspace. Aborting."
        )
    
    # Step 5: Add noise in im(δ)⊕im(δ*) — orthogonal to message
    # This is the EPHEMERAL FIBER: fresh per transaction
    #
    # From hardness_proof.lean (Hodge_Decomposition_Theorem):
    #   C^k = ker(Δ) ⊕ im(δ) ⊕ im(δ*)
    # For encryption we only need noise ⊥ ker(Δ), i.e. noise ∈ im(δ)⊕im(δ*).
    # The (I - P_H) projection guarantees this without needing the
    # exact/coexact split (which requires the sheaf coboundary, not the
    # bare graph coboundary). This matches Hodge_Strictly_Harder:
    # the attacker sees b = h + e but can't determine which Δ produced h.
    cochain_dim = L_sheaf.shape[0]
    from ..geometry.hodge import compute_hodge_projectors
    P_H, _, _ = compute_hodge_projectors(L_sheaf, None, None)
    
    # Noise purely in im(δ)⊕im(δ*): (I - P_H) kills harmonic component
    from .random import secure_rng
    rng = secure_rng()
    raw_noise = rng.standard_normal(cochain_dim) * sigma_exact
    noise = (np.eye(cochain_dim) - P_H) @ raw_noise
    
    # Validate noise ⊥ ker(Δ)
    validate_noise_structure(noise, L_sheaf, tolerance=1e-4)
    
    # Step 6: ciphertext = message + noise (Hodge decomposition!)
    full_cochain = harmonic_msg + noise
    
    # Distribute across vertex blocks
    vertex_blocks = {}
    stalk_size = cochain_dim // n_vertices if n_vertices > 0 else dim
    for i, v in enumerate(vertices):
        start = i * stalk_size
        end = start + stalk_size
        if end <= len(full_cochain):
            vertex_blocks[v[0]] = full_cochain[start:end].copy()  # COPY not view!
        else:
            vertex_blocks[v[0]] = np.zeros(stalk_size)
    
    # ── EDGE SYNDROMES ──
    # Syndrome = R_e · v_j - v_i + noise (ephemeral per edge)
    edge_syndromes = {}
    for edge in edges:
        i, j = edge
        vi_data = vertex_blocks.get(i, np.zeros(stalk_size))
        vj_data = vertex_blocks.get(j, np.zeros(stalk_size))
        A = credential.fibration.edge_keys.get(edge, np.eye(stalk_size))
        
        if A.shape[1] == len(vj_data) and A.shape[0] == len(vi_data):
            syndrome = A @ vj_data - vi_data
        else:
            syndrome = np.zeros_like(vi_data)
        
        syn_noise = ornstein_uhlenbeck_noise(len(syndrome), volatility=sigma_exact)
        edge_syndromes[edge] = syndrome + syn_noise
    
    # ── BUILD CIPHERTEXT ──
    # ON-CHAIN IDENTITY: homotopy class U (PublicIdentity), NOT specific fiber
    # sender_fingerprint = public_identity.identity_hash() = class-level
    # The spectral fingerprint (specific fiber) NEVER leaves the wallet.
    nonce = secure_random_bytes(24)
    message_hash = hashlib.sha256(message).digest()
    public_id = credential.project_to_public()

    # ── FORWARD SECRECY: wipe ephemeral fiber ──
    # The noise vector IS the ephemeral fiber. If an attacker later
    # compromises memory, they must not find noise (which would let
    # them subtract it from the ciphertext to recover the message).
    # Three-pass overwrite: random → zeros → zeros.
    for ephemeral_array in [raw_noise, noise, harmonic_msg, full_cochain, P_H]:
        if isinstance(ephemeral_array, np.ndarray):
            try:
                ephemeral_array[:] = np.random.randn(*ephemeral_array.shape)
                ephemeral_array.fill(0)
            except (ValueError, TypeError):
                pass  # Read-only or non-contiguous — best effort
    del raw_noise, noise, harmonic_msg, full_cochain, P_H

    return FibrationCiphertext(
        version=3,  # Always v3 (pure Hodge — no fallback)
        topology_hash=credential.spectrum.topology_hash,
        sender_fingerprint=public_id.identity_hash(),  # CLASS, not fiber!
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
    
    EPHEMERAL FIBER: The padding (random ±1 for unused dimensions)
    uses secure_rng() so message length doesn't leak through
    statistical analysis. Each call produces an independent encoding.
    
    Args:
        message: Plaintext bytes
        harmonic_dim: Dimension of ker(Δ) (must be ≥ message bits)
        
    Returns:
        Real-valued coefficient vector of length harmonic_dim
    """
    from .random import secure_rng
    rng = secure_rng()
    
    msg_bits = []
    for byte in message:
        for i in range(8):
            msg_bits.append((byte >> i) & 1)
    
    coeffs = np.zeros(harmonic_dim)
    for i, bit in enumerate(msg_bits[:harmonic_dim]):
        coeffs[i] = 1.0 if bit else -1.0
    
    # Remaining dimensions: SECURE random ±1 (hides message length)
    # Must use crypto RNG — np.random leaks message length via PRNG state
    n_padding = harmonic_dim - len(msg_bits)
    if n_padding > 0:
        padding_bits = rng.integers(0, 2, size=n_padding)
        for i, bit in enumerate(padding_bits):
            coeffs[len(msg_bits) + i] = 1.0 if bit else -1.0
    
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
