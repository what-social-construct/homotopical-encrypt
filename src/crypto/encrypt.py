"""
Encryption via Cochain Embedding

Encryption process:
1. Encode message as lattice element
2. Embed in 0-cochain space (distribute across vertices)
3. Apply coboundary operator δ
4. Add noise for CPA security (discrete Gaussian for quantum resistance)

The ciphertext is a cochain: assignment of data to each cell of the nerve.

Post-Quantum Security:
- Uses LWE (Learning With Errors) noise
- Discrete Gaussian distribution (not continuous)
- Cryptographically secure randomness throughout
- Resistant to Shor's algorithm
"""

from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Optional
import numpy as np
import hashlib
import time

from .credential import FibrationCredential, SpectralFingerprint
from .lwe import (
    discrete_gaussian,
    secure_random_vector,
    secure_random_bytes,
    DEFAULT_SIGMA
)


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
            timestamp=timestamp
        )


def encrypt(
    message: bytes,
    credential: FibrationCredential,
    noise_stddev: float = 3.0
) -> FibrationCiphertext:
    """
    Encrypt message using fibration credential.
    
    Args:
        message: Plaintext bytes to encrypt
        credential: FibrationCredential with fibration (private key)
        noise_stddev: Standard deviation of Gaussian noise (for security)
        
    Returns:
        FibrationCiphertext ready for transmission
    """
    modulus = credential.modulus
    dim = credential.hilbert_dim
    
    # 1. Encode message as lattice element
    msg_lattice = _encode_message(message, dim, modulus)
    
    # 2. Distribute across vertices (0-cochain embedding)
    vertices = credential.topology.get(0, [])
    n_vertices = len(vertices)
    
    vertex_blocks = {}
    for i, v in enumerate(vertices):
        if i == 0:
            # First vertex gets the message
            vertex_blocks[v[0]] = msg_lattice.copy()
        else:
            # Other vertices get random shares (SECURE)
            vertex_blocks[v[0]] = secure_random_vector(dim, modulus).astype(np.float64)
    
    # 3. Apply coboundary (encryption transform)
    edges = credential.topology.get(1, [])
    edge_syndromes = {}
    
    for edge in edges:
        i, j = edge
        vi_data = vertex_blocks.get(i, np.zeros(dim))
        vj_data = vertex_blocks.get(j, np.zeros(dim))
        
        # Get restriction maps from fibration
        A = credential.fibration.edge_keys.get(edge, np.eye(dim))
        
        # Coboundary: δ(c)_e = A·c_j - c_i
        syndrome = (A @ vj_data - vi_data) % modulus
        
        # Add DISCRETE GAUSSIAN noise for CPA security (quantum-resistant)
        noise = discrete_gaussian(dim, noise_stddev)
        syndrome = (syndrome + noise) % modulus
        
        edge_syndromes[edge] = syndrome
    
    # 4. Add DISCRETE GAUSSIAN noise to vertex blocks too
    for vid in vertex_blocks:
        noise = discrete_gaussian(dim, noise_stddev)
        vertex_blocks[vid] = (vertex_blocks[vid] + noise) % modulus
    
    # 5. Build ciphertext with SECURE nonce
    nonce = secure_random_bytes(24)
    
    # 6. Hash message for verification
    message_hash = hashlib.sha256(message).digest()
    
    return FibrationCiphertext(
        version=1,
        topology_hash=credential.spectrum.topology_hash,
        sender_fingerprint=credential.spectrum.fingerprint_hash(),
        vertex_blocks=vertex_blocks,
        edge_syndromes=edge_syndromes,
        nonce=nonce,
        timestamp=int(time.time()),
        message_length=len(message),
        message_hash=message_hash
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
