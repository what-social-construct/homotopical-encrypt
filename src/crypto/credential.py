"""
Fibration Credential: The cryptographic key structure.

A credential is NOT a key pair - it's a triple:
1. TOPOLOGY (public): The Čech nerve - who talks to whom
2. FIBRATION (private): Quantum channels - how they talk  
3. SPECTRUM (public): Spectral fingerprint - what you can verify

This structure provides:
- Multi-party by default (topology encodes participants)
- Homotopy equivalence classes (key agility)
- ZK-friendly verification via spectral invariants

Based on Helfer's homotopical logic (arXiv:1908.08944)
"""

from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Optional
import numpy as np
import hashlib

from ..geometry.sheaf import CellularSheaf, build_cech_nerve
from .lwe import secure_random_vector, secure_random_matrix


@dataclass
class SpectralFingerprint:
    """
    Public spectral fingerprint for identity verification.
    
    Contains homotopy invariants that can be used in ZK proofs:
    - Eigenvalues of Laplacian (spectrum)
    - Betti numbers (topological invariants)
    - Spectral gap (security parameter)
    
    Two fibrations with same fingerprint are homotopy equivalent
    (can decrypt same messages).
    """
    eigenvalues: np.ndarray
    betti_numbers: List[int]
    spectral_gap: float
    topology_hash: bytes  # SHA256 of nerve structure
    
    def __hash__(self) -> int:
        return hash(self.topology_hash)
    
    def matches(self, other: 'SpectralFingerprint', tolerance: float = 1e-6) -> bool:
        """
        Check if two fingerprints match (same homotopy class).
        
        Args:
            other: Another spectral fingerprint
            tolerance: Numerical tolerance for eigenvalue comparison
            
        Returns:
            True if fingerprints indicate same homotopy class
        """
        # Check topology matches
        if self.topology_hash != other.topology_hash:
            return False
        
        # Check Betti numbers match exactly (topological invariants)
        if self.betti_numbers != other.betti_numbers:
            return False
        
        # Check eigenvalues match within tolerance
        if len(self.eigenvalues) != len(other.eigenvalues):
            return False
        
        return np.allclose(self.eigenvalues, other.eigenvalues, atol=tolerance)
    
    def fingerprint_hash(self) -> bytes:
        """
        Compute hash of fingerprint for compact representation.
        """
        data = self.eigenvalues.tobytes()
        data += bytes(str(self.betti_numbers), 'utf-8')
        data += self.topology_hash
        return hashlib.sha256(data).digest()


@dataclass
class QuantumSheafFibration:
    """
    The PRIVATE component: quantum channels as restriction maps.
    
    This is a cellular sheaf where:
    - Stalks F(v) = ℂ^d (Hilbert spaces)
    - Restriction maps = CPTP quantum channels
    
    The fibration structure enables:
    - Parallel transport (message propagation)
    - Holonomy (loop authentication)
    - Lindblad flow (decryption)
    """
    sheaf: CellularSheaf
    hilbert_dim: int
    
    # Quantum channel parameters (LWE matrices)
    vertex_keys: Dict[int, np.ndarray] = field(default_factory=dict)  # A_v
    edge_keys: Dict[Tuple[int, int], np.ndarray] = field(default_factory=dict)  # A_e
    
    @classmethod
    def random(
        cls,
        nerve: Dict[int, List[Tuple]],
        hilbert_dim: int = 256,
        modulus: int = 12289  # LWE modulus (prime)
    ) -> 'QuantumSheafFibration':
        """
        Generate random fibration (secure key generation).
        
        Args:
            nerve: The Čech nerve topology
            hilbert_dim: Dimension of Hilbert spaces (security parameter)
            modulus: LWE modulus for lattice-based security
            
        Returns:
            Random fibration suitable for encryption
        """
        # Create cellular sheaf
        sheaf = CellularSheaf(nerve)
        
        # Generate random stalks (uniform in ℤ_q^d) - SECURE
        vertices = nerve.get(0, [])
        vertex_keys = {}
        
        for v in vertices:
            # Random LWE secret key for this vertex (cryptographically secure)
            key = secure_random_vector(hilbert_dim, modulus)
            sheaf.set_stalk(v, key)
            vertex_keys[v[0]] = key
        
        # Generate random restriction maps (LWE matrices) - SECURE
        edges = nerve.get(1, [])
        edge_keys = {}
        
        for edge in edges:
            i, j = edge
            # Random matrix A ∈ ℤ_q^{d×d} (cryptographically secure)
            A = secure_random_matrix(hilbert_dim, hilbert_dim, modulus)
            edge_keys[edge] = A
            
            # Set restriction maps
            sheaf.set_restriction((i,), edge, A)
            sheaf.set_restriction((j,), edge, A.T)  # Adjoint for other direction
        
        return cls(
            sheaf=sheaf,
            hilbert_dim=hilbert_dim,
            vertex_keys=vertex_keys,
            edge_keys=edge_keys
        )
    
    def parallel_transport(
        self,
        state: np.ndarray,
        from_vertex: int,
        to_vertex: int,
        path: Optional[List[int]] = None
    ) -> np.ndarray:
        """
        Transport quantum state along a path.
        
        Args:
            state: State vector at from_vertex
            from_vertex: Starting vertex
            to_vertex: Target vertex
            path: Optional explicit path (list of vertices)
            
        Returns:
            Transported state at to_vertex
        """
        if path is None:
            path = [from_vertex, to_vertex]
        
        current = state.copy()
        
        for i in range(len(path) - 1):
            v_from = path[i]
            v_to = path[i + 1]
            
            # Get edge
            edge = tuple(sorted([v_from, v_to]))
            
            if edge in self.edge_keys:
                A = self.edge_keys[edge]
                # Apply restriction map
                current = A @ current
        
        return current


@dataclass
class FibrationCredential:
    """
    Complete cryptographic credential.
    
    The triple (topology, fibration, spectrum) where:
    - topology: PUBLIC - the Čech nerve (who talks to whom)
    - fibration: PRIVATE - quantum channels (how they talk)
    - spectrum: PUBLIC - spectral fingerprint (identity verification)
    """
    topology: Dict[int, List[Tuple]]  # Čech nerve (public)
    fibration: QuantumSheafFibration  # Quantum channels (private)
    spectrum: SpectralFingerprint  # Fingerprint (public)
    
    # Metadata
    parties: List[str] = field(default_factory=list)
    hilbert_dim: int = 256
    modulus: int = 12289
    
    def get_public(self) -> Tuple[Dict[int, List[Tuple]], SpectralFingerprint]:
        """Get public components (topology, spectrum)."""
        return (self.topology, self.spectrum)
    
    def verify_identity(self, other_spectrum: SpectralFingerprint) -> bool:
        """
        Verify if another credential has compatible identity.
        
        Returns True if same homotopy class (can communicate).
        """
        return self.spectrum.matches(other_spectrum)


def generate_credential(
    parties: List[str],
    connections: List[Tuple[str, str]],
    security_parameter: int = 256,
    modulus: int = 12289
) -> FibrationCredential:
    """
    Generate a fibration credential for a group of parties.
    
    Args:
        parties: List of party names/IDs
        connections: Which parties can communicate directly
        security_parameter: Dimension of Hilbert spaces (λ)
        modulus: LWE modulus (should be prime, q > 2λ)
        
    Returns:
        FibrationCredential with public/private components
        
    Example:
        # Two-party encryption (like traditional)
        cred = generate_credential(
            parties=['alice', 'bob'],
            connections=[('alice', 'bob')]
        )
        
        # Multi-party encryption  
        cred = generate_credential(
            parties=['alice', 'bob', 'charlie'],
            connections=[
                ('alice', 'bob'),
                ('bob', 'charlie'),
                ('alice', 'charlie')
            ]
        )
    """
    # 1. Build Čech nerve from topology
    nerve = build_cech_nerve(parties, connections)
    
    # 2. Generate random fibration (secret)
    fibration = QuantumSheafFibration.random(
        nerve=nerve,
        hilbert_dim=security_parameter,
        modulus=modulus
    )
    
    # 3. Compute spectral fingerprint
    spectrum = _compute_spectrum(fibration, nerve)
    
    return FibrationCredential(
        topology=nerve,
        fibration=fibration,
        spectrum=spectrum,
        parties=parties,
        hilbert_dim=security_parameter,
        modulus=modulus
    )


def _compute_spectrum(
    fibration: QuantumSheafFibration,
    nerve: Dict[int, List[Tuple]]
) -> SpectralFingerprint:
    """
    Compute spectral fingerprint from fibration.
    
    Extracts homotopy invariants:
    - Eigenvalues of sheaf Laplacian
    - Betti numbers β_0, β_1
    - Spectral gap λ_1
    """
    from ..geometry.sheaf_laplacian import SheafLaplacian
    
    # Build Laplacian
    laplacian = SheafLaplacian(fibration.sheaf)
    
    # Compute eigenvalues
    L = laplacian.get_laplacian_0()
    if L.size > 0:
        eigenvalues = np.linalg.eigvalsh(L)
        eigenvalues = np.sort(eigenvalues)
    else:
        eigenvalues = np.array([0.0])
    
    # Compute Betti numbers
    n_vertices = len(nerve.get(0, []))
    n_edges = len(nerve.get(1, []))
    n_triangles = len(nerve.get(2, []))
    
    # β_0 = connected components (from kernel of L_0)
    beta_0 = int(np.sum(eigenvalues < 1e-6))
    
    # β_1 from Euler characteristic (simplified)
    chi = n_vertices - n_edges + n_triangles
    beta_1 = max(0, n_edges - n_vertices + beta_0)
    
    # Spectral gap (smallest nonzero eigenvalue)
    nonzero = eigenvalues[eigenvalues > 1e-6]
    spectral_gap = float(nonzero[0]) if len(nonzero) > 0 else 0.0
    
    # Topology hash - MUST include spectral fingerprint for uniqueness
    # Otherwise credentials with same graph structure would collide
    nerve_str = str(sorted(nerve.items()))
    hasher = hashlib.sha256()
    hasher.update(b"HOMOTOPICAL_CREDENTIAL_V2")
    hasher.update(nerve_str.encode())
    hasher.update(eigenvalues.tobytes())  # CRITICAL: makes hash unique per credential
    hasher.update(np.float64(spectral_gap).tobytes())
    topology_hash = hasher.digest()
    
    return SpectralFingerprint(
        eigenvalues=eigenvalues,
        betti_numbers=[beta_0, beta_1],
        spectral_gap=spectral_gap,
        topology_hash=topology_hash
    )
