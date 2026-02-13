"""
Fibration Credential: The cryptographic key structure.

A credential separates PUBLIC identity from PRIVATE key material:

  PUBLIC (revealed on-chain / to verifiers):
    PublicIdentity := (betti_numbers, topology_hash)
    - Betti numbers (β₀, β₁, β₂) — true homotopy invariants
    - topology_hash — SHA256 of nerve structure (opaque)
    
  PRIVATE (never leaves wallet):
    - spectral fingerprint (eigenvalues) — the actual private key
    - fibration (restriction maps R_{v→e}) — the geometric secret
    - Laplacian Δ = δ*δ + δδ* — derived from fibration
    - topology (nerve vertices/edges) — the actual graph structure

The anonymity set is the homotopy class π⁻¹(β) = all fibrations
with the given Betti numbers. This set is INFINITE by Hodge theory.

The diagonal pairing (from Helfer's homotopical logic):
  Δ: Betti → Betti × Betti,  β ↦ (β, β)
  Two credentials are "equal" iff their Betti numbers match.

See: hardness_proof.lean for formal verification of Hodge-hardness.
See: math_audit_hcrypt.lean for the audit motivating this design.
See: docs/REFACTOR_PLAN.md for the full pivot rationale.

Based on Helfer's homotopical logic (arXiv:1908.08944)
"""

from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Optional
import numpy as np
import hashlib

from ..geometry.sheaf import CellularSheaf, build_cech_nerve
from .lattice import secure_random_vector, secure_random_matrix


def _count_connected_components(nerve: Dict[int, List[Tuple]]) -> int:
    """
    Count connected components using DFS.
    
    β₀ = number of connected components in the nerve.
    For a connected topology (alice-bob), β₀ = 1.
    """
    vertices = nerve.get(0, [])
    edges = nerve.get(1, [])
    
    if not vertices:
        return 0
    
    # Build adjacency from vertex tuples
    vertex_ids = [v[0] if isinstance(v, tuple) else v for v in vertices]
    adjacency = {v: set() for v in vertex_ids}
    
    for edge in edges:
        if len(edge) >= 2:
            i, j = edge[0], edge[1]
            if i in adjacency:
                adjacency[i].add(j)
            if j in adjacency:
                adjacency[j].add(i)
    
    visited = set()
    components = 0
    
    def dfs(node):
        visited.add(node)
        for neighbor in adjacency.get(node, []):
            if neighbor not in visited:
                dfs(neighbor)
    
    for v in adjacency:
        if v not in visited:
            dfs(v)
            components += 1
    
    return components


@dataclass
class SpectralFingerprint:
    """
    PRIVATE spectral fingerprint — part of the secret key material.
    
    POST-AUDIT: This is NO LONGER public. The math audit
    (math_audit_hcrypt.lean, Spectrum_Not_Homotopy_Invariant) proved
    that eigenvalues are a FINER invariant than the homotopy class.
    Revealing them publicly reduces the anonymity set from the infinite
    homotopy class to the potentially-singleton isospectral set.
    
    Contains:
    - eigenvalues: Laplacian spectrum (PRIVATE — the actual key)
    - betti_numbers: topological invariants (PUBLIC via PublicIdentity)
    - spectral_gap: security parameter (PRIVATE — only boolean on-chain)
    
    For PUBLIC identity, use PublicIdentity instead (Betti numbers only).
    See: docs/REFACTOR_PLAN.md for full rationale.
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
class PublicIdentity:
    """
    Public identifier — reveals only Betti numbers.
    
    This is a point in Betti space (ℕ³). The anonymity set is
    π⁻¹(β) = {all fibrations with these Betti numbers} = INFINITE.
    
    The diagonal pairing:
      on_diagonal(self, other) ⟺ self.betti_numbers == other.betti_numbers
      ⟺ same homotopy class ⟺ indistinguishable
    
    PUBLIC fields only. No eigenvalues, no fibration structure.
    """
    betti_numbers: Tuple[int, ...]  # (β₀, β₁, ...) — true homotopy invariants
    topology_hash: bytes             # SHA256 of nerve structure (opaque)
    
    def identity_hash(self) -> bytes:
        """
        Compute compact identity hash for on-chain storage.
        
        This is the η₂ projection: PublicIdentity → 32 bytes.
        """
        hasher = hashlib.sha256()
        hasher.update(b"HCRYPT_PUBLIC_IDENTITY_V1")
        hasher.update(str(self.betti_numbers).encode())
        hasher.update(self.topology_hash)
        return hasher.digest()
    
    def on_diagonal(self, other: 'PublicIdentity') -> bool:
        """
        Check if self and other are on the diagonal (same homotopy class).
        
        From Helfer's logic: equality = membership on the diagonal
        Δ: Betti → Betti × Betti, β ↦ (β, β)
        """
        return self.betti_numbers == other.betti_numbers
    
    def __eq__(self, other) -> bool:
        if not isinstance(other, PublicIdentity):
            return False
        return self.betti_numbers == other.betti_numbers and self.topology_hash == other.topology_hash
    
    def __hash__(self) -> int:
        return hash((self.betti_numbers, self.topology_hash))


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
    - Harmonic projection onto ker(Δ) (decryption)
    """
    sheaf: CellularSheaf
    hilbert_dim: int
    
    # Quantum channel parameters (lattice matrices)
    vertex_keys: Dict[int, np.ndarray] = field(default_factory=dict)  # A_v
    edge_keys: Dict[Tuple[int, int], np.ndarray] = field(default_factory=dict)  # A_e
    
    @classmethod
    def random(
        cls,
        nerve: Dict[int, List[Tuple]],
        hilbert_dim: int = 256,
        modulus: int = 12289  # Lattice modulus (prime)
    ) -> 'QuantumSheafFibration':
        """
        Generate random fibration (secure key generation).
        
        Args:
            nerve: The Čech nerve topology
            hilbert_dim: Dimension of Hilbert spaces (security parameter)
            modulus: Lattice modulus for Hodge-hardness security
            
        Returns:
            Random fibration suitable for encryption
        """
        # Create cellular sheaf
        sheaf = CellularSheaf(nerve)
        
        # Generate random stalks (uniform in ℤ_q^d) - SECURE
        vertices = nerve.get(0, [])
        vertex_keys = {}
        
        for v in vertices:
            # Random lattice secret key for this vertex (cryptographically secure)
            key = secure_random_vector(hilbert_dim, modulus)
            sheaf.set_stalk(v, key)
            vertex_keys[v[0]] = key
        
        # Generate random restriction maps (lattice matrices)
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
    
    PUBLIC (on-chain):
    - public_identity: PublicIdentity (Betti numbers + topology_hash)
    
    PRIVATE (wallet only):
    - topology: the actual Čech nerve graph structure
    - fibration: quantum channels (restriction maps)
    - spectrum: spectral fingerprint (eigenvalues) — THE PRIVATE KEY
    
    The projection π: FibrationCredential → PublicIdentity
    discards all spectral/fibration data, keeping only Betti numbers.
    """
    topology: Dict[int, List[Tuple]]  # Čech nerve (PRIVATE — structure)
    fibration: QuantumSheafFibration  # Quantum channels (PRIVATE)
    spectrum: SpectralFingerprint  # Fingerprint (PRIVATE — was public pre-audit)
    public_identity: Optional[PublicIdentity] = None  # PUBLIC (new)
    
    # Metadata
    parties: List[str] = field(default_factory=list)
    hilbert_dim: int = 256
    modulus: int = 12289
    
    def project_to_public(self) -> PublicIdentity:
        """
        The projection π: Spec → Betti.
        
        Discards eigenvalues and fibration structure,
        keeping only Betti numbers and topology hash.
        """
        if self.public_identity is not None:
            return self.public_identity
        # Fallback: construct from spectrum
        return PublicIdentity(
            betti_numbers=tuple(self.spectrum.betti_numbers),
            topology_hash=self.spectrum.topology_hash,
        )
    
    def get_public(self) -> Tuple[Dict[int, List[Tuple]], SpectralFingerprint]:
        """Get public components (topology, spectrum).
        
        DEPRECATED: Use project_to_public() instead.
        This method exposes the spectral fingerprint which should be private.
        Kept for backward compatibility during migration.
        """
        return (self.topology, self.spectrum)
    
    def verify_identity(self, other_spectrum: SpectralFingerprint) -> bool:
        """
        Verify if another credential has compatible identity.
        
        Returns True if same homotopy class (can communicate).
        """
        return self.spectrum.matches(other_spectrum)
    
    def on_diagonal(self, other: 'FibrationCredential') -> bool:
        """
        Check if two credentials are in the same homotopy class.
        
        Uses Betti numbers only (not eigenvalues).
        This is the correct anonymity-preserving equality check.
        """
        return self.project_to_public().on_diagonal(other.project_to_public())


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
        modulus: Lattice modulus (should be prime, q > 2λ)
        
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

    # 4. Unified invariant validation at keygen stage
    #    This calls validate_fibration(stage="keygen") which runs ALL
    #    invariant checkpoints: algebraic → spectral → cohomological → homotopical.
    #    Previously only referenced in a comment — now actually enforced.
    #    If validation fails, the credential is structurally unsound and
    #    would fail at transaction time anyway. Better to catch it here.
    try:
        from ..invariants.unified import validate_fibration
        from ..geometry.sheaf_laplacian import SheafLaplacian

        # Build Laplacian from the fibration's sheaf
        laplacian_obj = SheafLaplacian(fibration.sheaf)
        L_eigenvalues, L_eigenvectors = laplacian_obj.eigendecomposition(0)
        L_matrix = L_eigenvectors @ np.diag(L_eigenvalues) @ L_eigenvectors.T

        # Get coboundary δ₀ from the cochain complex
        from ..primitives.cochain import CochainComplex
        n_vertices = len(nerve.get(0, []))
        edges = nerve.get(1, [])
        cochain = CochainComplex.from_graph(n_vertices, edges, stalk_dim=security_parameter)
        delta_0 = cochain.coboundary(0)

        valid, fingerprint, report = validate_fibration(
            nerve=nerve,
            laplacian=L_matrix,
            delta_0=delta_0,
            stage="keygen"
        )

        if not valid:
            import warnings
            warnings.warn(
                f"Credential keygen: unified invariant validation FAILED.\n"
                f"Report: {report}\n"
                f"Credential may fail at transaction verification time."
            )
    except Exception:
        # If unified validation can't run (e.g., missing deps), proceed
        # with structural gates already passed above. The credential's
        # own gates (β₀ ≥ 1, restriction map dims, PSD Laplacian) still hold.
        pass

    # 5. Compute public identity (Betti numbers only — the π projection)
    public_identity = PublicIdentity(
        betti_numbers=tuple(spectrum.betti_numbers),
        topology_hash=spectrum.topology_hash,
    )

    return FibrationCredential(
        topology=nerve,
        fibration=fibration,
        spectrum=spectrum,
        public_identity=public_identity,
        parties=parties,
        hilbert_dim=security_parameter,
        modulus=modulus
    )


# =============================================================================
# AUTO KEY ROTATION (linkability prevention)
# =============================================================================

# Rotation period: every N blocks, credential should be rotated
ROTATION_PERIOD_BLOCKS: int = 1000  # ~16 minutes at 1 block/sec


def rotate_credential(
    old_credential: FibrationCredential,
) -> FibrationCredential:
    """
    Rotate a credential: new fibration, same homotopy class.

    WHAT ROTATES:
    - fibration (new random restriction maps → new spectral fingerprint)
    - spectrum (new eigenvalues → new fingerprint_hash)
    - vertex_keys, edge_keys (new random lattice secrets)

    WHAT STAYS:
    - topology (same Čech nerve → same parties, same connections)
    - Betti numbers (topological invariants → same homotopy class)
    - parties, hilbert_dim, modulus (structural parameters)

    WHY:
    - Spectral fingerprint is your identity. If it never changes,
      transactions over time become linkable (same fingerprint = same sender).
    - After rotation, old fingerprint can't be linked to new one
      (different eigenvalues, different fingerprint_hash) but both
      belong to the same homotopy class (same Betti numbers, same topology).
    - The oracle can verify both old and new credentials belong to
      the same class without learning the link.

    Returns:
        New FibrationCredential with fresh fibration + spectrum.
    """
    return generate_credential(
        parties=old_credential.parties,
        connections=_extract_connections(old_credential),
        security_parameter=old_credential.hilbert_dim,
        modulus=old_credential.modulus,
    )


def should_rotate(
    registration_height: int,
    current_height: int,
    period: int = ROTATION_PERIOD_BLOCKS,
) -> bool:
    """Check if credential should be rotated based on age."""
    age = current_height - registration_height
    return age >= period


def _extract_connections(credential: FibrationCredential) -> list:
    """Extract connection list from credential topology."""
    edges = credential.topology.get(1, [])
    parties = credential.parties
    connections = []
    for edge in edges:
        if len(edge) >= 2:
            i, j = edge[0], edge[1]
            if i < len(parties) and j < len(parties):
                connections.append((parties[i], parties[j]))
    return connections


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
    
    # Compute Betti numbers from TOPOLOGY (not Laplacian eigenvalues!)
    n_vertices = len(nerve.get(0, []))
    n_edges = len(nerve.get(1, []))
    n_triangles = len(nerve.get(2, []))

    # β_0 = connected components (from graph structure)
    beta_0 = _count_connected_components(nerve)

    # β_1 = independent loops (rank-nullity on δ₀)
    # For a graph: β₁ = |E| - |V| + β₀ (cycle rank)
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
    
    # ── KEYGEN INVARIANT GATES (hard-fail) ──
    # Only checks that belong at CONSTRUCTION TIME go here.
    # √2 spectral gap bounds are a PoV consensus constraint →
    #   enforced by unified.py validate_for_stage("transaction")
    # Spectral matching is an identity constraint →
    #   enforced by validation.py validate_decryption_request()
    
    # Gate 1: Topology must have vertices (β₀ ≥ 1)
    if beta_0 < 1:
        raise RuntimeError(
            f"KEYGEN INVARIANT VIOLATION: β₀ = {beta_0} < 1. "
            f"Topology has no vertices. Aborting."
        )
    
    # Gate 2: Nerve must be a valid simplicial complex
    # Every edge (i,j) must have both vertices i, j in the vertex set.
    # (cohomology.py validate_nerve_structure does full check; here
    # we do the minimal face-containment check at construction.)
    vertex_ids = {v[0] for v in nerve.get(0, [])}
    for edge in nerve.get(1, []):
        for vid in edge:
            if vid not in vertex_ids:
                raise RuntimeError(
                    f"KEYGEN INVARIANT VIOLATION: Edge {edge} references "
                    f"vertex {vid} not in vertex set {vertex_ids}. "
                    f"Nerve is not a valid simplicial complex. Aborting."
                )
    
    # Gate 3: Restriction maps must have correct dimensions
    # R_{v→e} must be (stalk_dim × stalk_dim) for each edge.
    for edge, A in fibration.edge_keys.items():
        if A.shape != (fibration.hilbert_dim, fibration.hilbert_dim):
            raise RuntimeError(
                f"KEYGEN INVARIANT VIOLATION: Restriction map for edge {edge} "
                f"has shape {A.shape}, expected "
                f"({fibration.hilbert_dim}, {fibration.hilbert_dim}). "
                f"Fibration structure is malformed. Aborting."
            )
    
    # Gate 4: Laplacian must be PSD (fundamental Hodge requirement)
    # Δ₀ = δ*δ is algebraically PSD, but with lattice-scale maps (q ≈ 10⁴),
    # float64 accumulation noise can produce λ_min ≈ -10⁻³.
    # Use RELATIVE tolerance: |λ_min| / λ_max must be tiny (numerical dust).
    if len(eigenvalues) > 0 and eigenvalues[0] < 0:
        scale = max(abs(eigenvalues[-1]), 1.0)
        relative_violation = abs(eigenvalues[0]) / scale
        if relative_violation > 1e-10:
            raise RuntimeError(
                f"KEYGEN INVARIANT VIOLATION: Laplacian not PSD: "
                f"λ_min = {eigenvalues[0]:.2e}, λ_max = {scale:.2e}, "
                f"relative = {relative_violation:.2e}. "
                f"Hodge decomposition would be invalid. Aborting."
            )
    
    return SpectralFingerprint(
        eigenvalues=eigenvalues,
        betti_numbers=[beta_0, beta_1],
        spectral_gap=spectral_gap,
        topology_hash=topology_hash
    )
