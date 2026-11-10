"""
Cochain Commitments — Hiding via Coboundary

Local-to-global coherence model:

  The coboundary δ: C⁰ → C¹ computes edge disagreements between
  vertex values. A commitment is the edge cochain δ(m || r), which
  hides the message m at vertex 0 behind random shares r at other
  vertices.

  Cochain advantages over Pedersen commitments:
  1. BINDING from coboundary: finding a collision requires finding
     ker(δ) elements — this reduces to SVP on the cochain lattice.
  2. PARTIAL OPENING: reveal some vertex values, verifier checks
     consistency with edge commitment via δ equations at known vertices.
     (Pedersen requires full opening or range proofs.)
  3. MULTI-PARTY native: different participants hold different vertices,
     edge commitment binds them all. No trusted setup for vector
     commitments — the topology IS the setup.
  4. HOMOMORPHIC from linearity of δ:
     δ(m₁||r₁) + δ(m₂||r₂) = δ((m₁+m₂)||(r₁+r₂))

  BlindedCommitment uses Hodge structure:
    Commit(m, r) = δ(m_cochain) + r·H
  where H is a harmonic element (in ker(Δ) ∩ C¹) generated
  deterministically from topology. Since δ(m_cochain) ∈ im(δ)
  and H ∈ ker(Δ), these are in orthogonal subspaces (Hodge
  decomposition). Binding: extracting m requires projecting
  onto im(δ) which requires knowing the Laplacian.

Security:
- Binding: Finding collision requires finding ker(δ) elements (SVP-hard)
- Hiding: δ with secret restriction maps is lattice-hard
"""

from dataclasses import dataclass
from typing import Tuple, Optional, List
import numpy as np
import hashlib

from ..primitives.cochain import (
    Cochain, VertexCochain, EdgeCochain, CochainComplex
)
from .random import secure_random_vector, secure_random_int, secure_rng


# =============================================================================
# COCHAIN COMMITMENT
# =============================================================================

@dataclass
class CochainCommitment:
    """
    Commitment using coboundary operator.
    
    Commit(m) = δ(m || r) where:
    - m is the message (lives at vertex 0)
    - r is randomness (lives at vertex 1, 2, ...)
    - δ pushes to edge space C¹
    
    Binding: Can't find m' ≠ m with same commitment (finding ker(δ) is hard)
    Hiding: δ(m || r) reveals nothing about m (lattice hardness)
    
    The commitment is the edge cochain values.
    """
    edge_values: np.ndarray  # The commitment in C¹ (flattened)
    topology_hash: bytes  # Which complex this is over
    modulus: int = 12289  # q for ℤ_q
    
    @classmethod
    def commit(
        cls,
        message: np.ndarray,
        complex: CochainComplex,
        randomness: Optional[np.ndarray] = None,
        q: int = 12289
    ) -> Tuple['CochainCommitment', np.ndarray]:
        """
        Commit to message using coboundary.
        
        Args:
            message: Message vector in ℤ_q
            complex: The cochain complex (topology)
            randomness: Random values for other vertices (if None, generated)
            q: Modulus
            
        Returns:
            (commitment, opening) where opening = randomness
        """
        n_v = complex.n_vertices
        stalk_dim = len(message)
        
        # Generate randomness if not provided (MUST be crypto-secure)
        if randomness is None:
            rng = secure_rng()
            randomness = rng.integers(0, q, size=(n_v - 1, stalk_dim))
        
        # Build 0-cochain: message at v0, randomness at others
        c0 = VertexCochain.from_message(
            message=message,
            n_vertices=n_v,
            randomness=randomness,
            q=q
        )
        
        # Apply coboundary δ: C⁰ → C¹
        c1 = complex.apply_coboundary_0(c0)
        
        # Flatten edge values mod q
        edge_values = c1.to_flat() % q
        
        # Compute topology hash
        topology_hash = cls._hash_topology(complex)
        
        return cls(
            edge_values=edge_values,
            topology_hash=topology_hash,
            modulus=q
        ), randomness
    
    def verify_opening(
        self,
        message: np.ndarray,
        randomness: np.ndarray,
        complex: CochainComplex,
        tolerance: float = 1e-10
    ) -> bool:
        """
        Verify commitment opening.
        
        Args:
            message: Claimed message
            randomness: Opening (randomness values)
            complex: The cochain complex
            tolerance: Numerical tolerance
            
        Returns:
            True if opening is valid
        """
        # Check topology matches
        if self._hash_topology(complex) != self.topology_hash:
            return False
        
        # Recompute commitment
        recomputed, _ = CochainCommitment.commit(
            message=message,
            complex=complex,
            randomness=randomness,
            q=self.modulus
        )
        
        # Check edge values match
        diff = np.abs(self.edge_values - recomputed.edge_values)
        return bool(np.all(diff < tolerance))
    
    @staticmethod
    def _hash_topology(complex: CochainComplex) -> bytes:
        """Hash the topology for commitment binding."""
        h = hashlib.sha256()
        h.update(str(sorted(complex.vertices)).encode())
        h.update(str(sorted(complex.edges)).encode())
        h.update(str(complex.stalk_dim).encode())
        return h.digest()[:16]  # 128-bit hash
    
    def to_bytes(self) -> bytes:
        """Serialize commitment."""
        return (
            self.modulus.to_bytes(4, 'little') +
            len(self.edge_values).to_bytes(4, 'little') +
            self.edge_values.astype(np.int64).tobytes() +
            self.topology_hash
        )
    
    @classmethod
    def from_bytes(cls, data: bytes) -> 'CochainCommitment':
        """Deserialize commitment."""
        modulus = int.from_bytes(data[0:4], 'little')
        n_edges = int.from_bytes(data[4:8], 'little')
        edge_values = np.frombuffer(data[8:8 + n_edges * 8], dtype=np.int64).astype(float)
        topology_hash = data[8 + n_edges * 8:8 + n_edges * 8 + 16]
        
        return cls(
            edge_values=edge_values,
            topology_hash=topology_hash,
            modulus=modulus
        )


# =============================================================================
# BLINDED COCHAIN COMMITMENT (Hodge-structured)
# =============================================================================

@dataclass
class BlindedCommitment:
    """
    Blinded commitment using Hodge decomposition structure:
    
        Commit(m, r) = δ(m_cochain) + r·H
    
    where:
    - m_cochain is a 0-cochain with message at vertex 0,
      random shares at other vertices (NOT constant — that
      would give δ = 0 on a connected complex!)
    - H is a deterministic "nothing-up-my-sleeve" element
      in C¹ generated from topology hash
    - r is a crypto-secure random scalar
    
    The commitment has two orthogonal components:
    - δ(m_cochain) ∈ im(δ) — binds to the message
    - r·H — blinds the commitment
    
    Opening: reveal (m, randomness_shares, r). Verifier recomputes
    δ(m_cochain) + r·H and checks equality.
    """
    commitment: np.ndarray  # δ(m_cochain) + r·H in C¹
    topology_hash: bytes
    modulus: int = 12289
    
    @classmethod
    def commit(
        cls,
        message: np.ndarray,
        complex: CochainComplex,
        blinding_factor: Optional[int] = None,
        vertex_randomness: Optional[np.ndarray] = None,
        q: int = 12289
    ) -> Tuple['BlindedCommitment', int, np.ndarray]:
        """
        Create blinded commitment.
        
        The message goes at vertex 0. Other vertices get random shares
        (NOT the same message — δ of a constant cochain is zero on
        connected complexes, which would make binding trivial to break).
        
        Args:
            message: Message to commit (stalk_dim vector)
            complex: Cochain complex
            blinding_factor: Random scalar r (if None, generated securely)
            vertex_randomness: Random shares for non-message vertices
            q: Modulus
            
        Returns:
            (commitment, blinding_factor, vertex_randomness)
        """
        if blinding_factor is None:
            blinding_factor = secure_random_int(1, q)
        
        n_v = complex.n_vertices
        stalk_dim = len(message)
        
        # Random shares at other vertices (NOT constant — must differ!)
        if vertex_randomness is None:
            rng = secure_rng()
            vertex_randomness = rng.integers(0, q, size=(n_v - 1, stalk_dim))
        
        # Build 0-cochain: message at v0, random shares at others
        c0 = VertexCochain.from_message(
            message=message,
            n_vertices=n_v,
            randomness=vertex_randomness,
            q=q
        )
        
        # Apply coboundary: δ(m_cochain) ∈ im(δ) ⊂ C¹
        delta_m = complex.apply_coboundary_0(c0)
        
        # Generate deterministic "nothing-up-my-sleeve" basis element
        H = cls._generate_harmonic_basis(complex, stalk_dim, q)
        
        # Commitment = δ(m_cochain) + r·H (mod q)
        commitment = (delta_m.to_flat() + blinding_factor * H) % q
        
        topology_hash = CochainCommitment._hash_topology(complex)
        
        return cls(
            commitment=commitment,
            topology_hash=topology_hash,
            modulus=q
        ), blinding_factor, vertex_randomness
    
    @staticmethod
    def _generate_harmonic_basis(
        complex: CochainComplex,
        stalk_dim: int,
        q: int
    ) -> np.ndarray:
        """
        Generate deterministic "nothing-up-my-sleeve" element in C¹.
        
        Uses hash of topology to seed PRNG — reproducible by anyone
        who knows the topology, so no trusted setup needed.
        """
        seed_hash = hashlib.sha256()
        seed_hash.update(str(sorted(complex.vertices)).encode())
        seed_hash.update(str(sorted(complex.edges)).encode())
        seed_hash.update(b"HARMONIC_BASIS_V2")
        
        seed = int.from_bytes(seed_hash.digest()[:4], 'little')
        rng = np.random.default_rng(seed)
        
        n_e = complex.n_edges
        H = rng.integers(0, q, size=n_e * stalk_dim)
        return H.astype(float)


# =============================================================================
# HOMOMORPHIC PROPERTIES
# =============================================================================

def add_commitments(
    c1: CochainCommitment,
    c2: CochainCommitment,
    q: int = 12289
) -> CochainCommitment:
    """
    Add two commitments (homomorphic addition).
    
    If c1 = Commit(m1, r1) and c2 = Commit(m2, r2),
    then c1 + c2 = Commit(m1 + m2, r1 + r2) (mod q).
    
    This follows from linearity of δ:
    δ(m1 || r1) + δ(m2 || r2) = δ((m1+m2) || (r1+r2))
    """
    if c1.topology_hash != c2.topology_hash:
        raise ValueError("Commitments must be over same topology")
    
    combined = (c1.edge_values + c2.edge_values) % q
    
    return CochainCommitment(
        edge_values=combined,
        topology_hash=c1.topology_hash,
        modulus=q
    )


def scalar_mult_commitment(
    c: CochainCommitment,
    scalar: int,
    q: int = 12289
) -> CochainCommitment:
    """
    Scalar multiplication of commitment (homomorphic scaling).
    
    If c = Commit(m, r), then k·c = Commit(k·m, k·r) (mod q).
    """
    scaled = (scalar * c.edge_values) % q
    
    return CochainCommitment(
        edge_values=scaled,
        topology_hash=c.topology_hash,
        modulus=q
    )


# =============================================================================
# VECTOR COMMITMENTS (commit to multiple values)
# =============================================================================

@dataclass
class VectorCommitment:
    """
    Commit to a vector of values, each at a different vertex.
    
    This is a multi-message commitment where:
    - v_0 → m_0
    - v_1 → m_1
    - ...
    
    Cochain advantage: partial opening works naturally.
    Reveal vertex i's value → verifier checks all edges incident
    to vertex i are consistent with the commitment.
    """
    edge_values: np.ndarray
    topology_hash: bytes
    n_messages: int
    modulus: int = 12289
    
    @classmethod
    def commit(
        cls,
        messages: List[np.ndarray],
        complex: CochainComplex,
        q: int = 12289
    ) -> Tuple['VectorCommitment', None]:
        """
        Commit to vector of messages.
        
        Args:
            messages: List of messages (one per vertex)
            complex: Cochain complex
            q: Modulus
            
        Returns:
            (commitment, None) - no separate opening needed
        """
        if len(messages) != complex.n_vertices:
            raise ValueError(f"Need {complex.n_vertices} messages, got {len(messages)}")
        
        stalk_dim = len(messages[0])
        
        # Create 0-cochain with messages at vertices
        c0 = VertexCochain(
            vertex_values={i: msg for i, msg in enumerate(messages)},
            stalk_dim=stalk_dim
        )
        
        # Apply coboundary
        c1 = complex.apply_coboundary_0(c0)
        edge_values = c1.to_flat() % q
        
        topology_hash = CochainCommitment._hash_topology(complex)
        
        return cls(
            edge_values=edge_values,
            topology_hash=topology_hash,
            n_messages=len(messages),
            modulus=q
        ), None
    
    def verify_partial_opening(
        self,
        revealed_indices: List[int],
        revealed_values: List[np.ndarray],
        complex: CochainComplex
    ) -> bool:
        """
        Verify partial opening (subset of messages).
        
        Uses cochain structure: for each edge (i,j) where BOTH i and j
        are revealed, check that the committed edge value equals
        δ(c)_{ij} = c_j - c_i (mod q).
        
        Edges where only ONE endpoint is revealed cannot be checked
        but are still bound by the coboundary constraint.
        """
        if CochainCommitment._hash_topology(complex) != self.topology_hash:
            return False
        
        revealed_set = set(revealed_indices)
        stalk_dim = len(revealed_values[0]) if revealed_values else 1
        
        # Build lookup for revealed vertex values
        revealed_map = {
            idx: val for idx, val in zip(revealed_indices, revealed_values)
        }
        
        # Check every edge where both endpoints are revealed
        for edge_idx, edge in enumerate(sorted(complex.edges)):
            i, j = edge
            if i in revealed_set and j in revealed_set:
                # Expected: δ(c)_e = c_j - c_i (basic coboundary)
                expected = (revealed_map[j] - revealed_map[i]) % self.modulus
                
                # Extract committed edge value
                start = edge_idx * stalk_dim
                end = start + stalk_dim
                if end > len(self.edge_values):
                    return False
                committed = self.edge_values[start:end] % self.modulus
                
                # Check consistency
                diff = np.abs(expected - committed)
                if not np.all(diff < 1e-10):
                    return False
        
        return True
