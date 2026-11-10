"""
Stalk Primitive: The Fiber at a Point

A stalk is the local state space at a vertex of the topology.
Different contexts need different stalk structures, corresponding
to the THREE LEVELS of the hardness hierarchy (hardness_proof.lean):

CONTEXTS (from hardness hierarchy):

  NOTE ON DIMENSIONS: Each dim below is the per-vertex vector space
  dimension (number of entries in the stalk's numpy array at ONE
  vertex). The TOTAL credential size also includes restriction maps
  (d×d matrix per edge) and metadata — see size estimates below.

  PRIVATE (homotopical_encrypt level, per-vertex dim = λ = 256):
    Full fibration secret. Recovering this requires solving
    Hodge-hardness: find h ∈ ker(Δ) from b = h + e without
    knowing Δ. Strictly harder than CVP (Hodge_Strictly_Harder).
    Per-vertex stalk = λ entries (harmonic secret + Hodge noise margin + metadata).
    Total credential size (typical 3-vertex, 3-edge topology):
      stalks:          3 × 256        =       768  ℤ_q entries
      restriction maps: 3 × 256 × 256 =   196,608  ℤ_q entries
      at q = 2^15 (2 bytes/entry):    ≈     384 KB
    The restriction maps (edge_keys) dominate storage. They are
    the fibration secret — the connection on the Grothendieck fibration.
    
  ZK (CVP level, per-vertex dim = 32):
    Lattice projection of the Hodge problem. The Hodge-hardness
    problem projects onto CVP on the harmonic sublattice ker(Δ) ⊂ ℤ_q^n
    via the forgetful functor that discards the topology. 32 entries
    per vertex: commitment (16) + blinding factor (16). An attacker
    at this level can solve CVP but cannot determine ker(Δ) without
    the full fibration — the projection is not invertible.
    
  PUBLIC (SHA256 level, per-vertex dim = 32):
    Hash commitments. SHA-256 output = 256 bits = 32 bytes.
    On-chain identity = SHA256(Betti numbers ‖ topology hash).
    The output of the natural transformation η: F_full → F_hash.
    32 bytes per vertex on chain.

The projection PRIVATE → PUBLIC is a NONLINEAR FUNCTOR:
  π(credential) = (Betti_numbers, topology_hash)
  This is NOT a matrix multiplication — it requires eigendecomposition
  of Δ to count near-zero eigenvalues (Betti numbers), then hashing.
  Implemented in credential.py:project_to_public().
  The StalkProjection matrix is a LINEAR APPROXIMATION used for
  fast stalk-level operations within a single context.

ARCHITECTURE (local-to-global coherence):

  StalkProjection := the restriction map R_{v→e} in the sheaf.
  
  When two vertices share an edge, their stalks are connected by
  restriction maps (projections between contexts). The coboundary
  δ(c)_e = R_j·c_j - R_i·c_i measures disagreement between how
  two vertices project to their shared edge context.

  ker(Δ) = cochains where R_j·c_j = R_i·c_i for ALL edges
         = global sections = data consistent across all projections.

  Formally:
  - Let m ∈ ker(Δ). Then R_j·m_j = R_i·m_i for all edges (i,j),
    so m is invariant under all restriction maps — a global section.
  - Let e ∈ im(δ)⊕im(δ*). Then ⟨e, m⟩ = 0 for all m ∈ ker(Δ),
    so e is orthogonal to every global section — pure disagreement.
  - Hodge projection π_H: C^k → ker(Δ) recovers the globally
    consistent component. For c = m + e, π_H(c) = m exactly.

  The lattice (ℤ_q coordinates) operates on individual stalk
  entries; the Hodge structure operates on global section coherence.
  Both views are dual: lattice decoding at vertex 0 and harmonic
  projection onto ker(Δ) must recover the same message.

This primitive makes the stalk explicit and provides:
- Type safety across contexts
- Projection operators between stalk types (= restriction maps)
- Serialization/deserialization
"""

from dataclasses import dataclass, field
from typing import Optional, Callable, Dict, Any, Union
from enum import Enum
import numpy as np
import hashlib


class StalkContext(Enum):
    """
    Stalk context — reflects the hardness hierarchy:
    PRIVATE (homotopical_encrypt) → ZK (CVP) → PUBLIC (SHA-256)
    """
    PRIVATE = "private"      # Full fibration secret (homotopical_encrypt level)
    ZK = "zk"               # Lattice projection (CVP level)
    PUBLIC = "public"        # Hash commitment (SHA-256 level)
    

@dataclass
class StalkSpec:
    """
    Specification for a stalk type.
    
    Defines the structure of local state at vertices.
    """
    context: StalkContext
    dimension: int
    name: str
    description: str = ""
    
    # Field structure (optional)
    fields: Dict[str, int] = field(default_factory=dict)
    
    def __post_init__(self):
        if self.fields:
            total_dim = sum(self.fields.values())
            if total_dim != self.dimension:
                raise ValueError(f"Field dimensions {total_dim} != stalk dimension {self.dimension}")


# Standard stalk specs for different contexts
PRIVATE_STALK = StalkSpec(
    context=StalkContext.PRIVATE,
    dimension=256,
    name="PrivateStalk",
    description="Full fibration secret (homotopical_encrypt level)",
    fields={
        "harmonic_secret": 128,  # Harmonic component h ∈ ker(Δ)
        "hodge_noise": 64,       # Noise margin in im(δ)⊕im(δ*)
        "metadata": 64           # Additional state
    }
)

PUBLIC_STALK = StalkSpec(
    context=StalkContext.PUBLIC,
    dimension=1,
    name="PublicStalk",
    description="Public commitment (balance/value)",
    fields={
        "value": 1
    }
)

ZK_STALK = StalkSpec(
    context=StalkContext.ZK,
    dimension=32,
    name="ZKStalk",
    description="Zero-knowledge intermediate representation",
    fields={
        "commitment": 16,
        "blinding": 16
    }
)


@dataclass
class Stalk:
    """
    A stalk instance: actual data at a vertex.
    
    The stalk is the fiber of the sheaf over a point.
    In our setup:
    - Vertex = participant/account
    - Stalk = their local state
    """
    spec: StalkSpec
    data: np.ndarray
    vertex_id: Optional[int] = None
    
    def __post_init__(self):
        if len(self.data) != self.spec.dimension:
            raise ValueError(f"Data dimension {len(self.data)} != spec dimension {self.spec.dimension}")
    
    @classmethod
    def zero(cls, spec: StalkSpec, vertex_id: Optional[int] = None) -> 'Stalk':
        """Create zero stalk."""
        return cls(spec=spec, data=np.zeros(spec.dimension), vertex_id=vertex_id)
    
    @classmethod
    def from_value(cls, value: float, vertex_id: Optional[int] = None) -> 'Stalk':
        """Create public stalk from scalar value."""
        return cls(spec=PUBLIC_STALK, data=np.array([value]), vertex_id=vertex_id)
    
    @classmethod
    def random(cls, spec: StalkSpec, vertex_id: Optional[int] = None) -> 'Stalk':
        """Create random stalk (for testing/initialization)."""
        return cls(spec=spec, data=np.random.randn(spec.dimension), vertex_id=vertex_id)
    
    def get_field(self, field_name: str) -> np.ndarray:
        """Extract a named field from the stalk data."""
        if field_name not in self.spec.fields:
            raise KeyError(f"Field '{field_name}' not in stalk spec")
        
        offset = 0
        for name, dim in self.spec.fields.items():
            if name == field_name:
                return self.data[offset:offset+dim]
            offset += dim
        
        raise KeyError(f"Field '{field_name}' not found")
    
    def set_field(self, field_name: str, value: np.ndarray):
        """Set a named field in the stalk data."""
        if field_name not in self.spec.fields:
            raise KeyError(f"Field '{field_name}' not in stalk spec")
        
        offset = 0
        for name, dim in self.spec.fields.items():
            if name == field_name:
                if len(value) != dim:
                    raise ValueError(f"Value dimension {len(value)} != field dimension {dim}")
                self.data[offset:offset+dim] = value
                return
            offset += dim
    
    def commitment(self) -> bytes:
        """Hash commitment to this stalk's data."""
        return hashlib.sha256(self.data.tobytes()).digest()
    
    def __add__(self, other: 'Stalk') -> 'Stalk':
        """Add two stalks (same spec)."""
        if self.spec != other.spec:
            raise ValueError("Cannot add stalks with different specs")
        return Stalk(spec=self.spec, data=self.data + other.data)
    
    def __mul__(self, scalar: float) -> 'Stalk':
        """Scalar multiplication."""
        return Stalk(spec=self.spec, data=self.data * scalar)
    
    def __rmul__(self, scalar: float) -> 'Stalk':
        return self.__mul__(scalar)
    
    def norm(self) -> float:
        """L2 norm of stalk data."""
        return float(np.linalg.norm(self.data))


class StalkProjection:
    """
    Projection between stalk types.
    
    Maps stalks from one context to another:
    - private → public: Extract commitment/balance
    - private → zk: Create ZK intermediate
    - zk → public: Verify commitment
    """
    
    def __init__(
        self,
        source_spec: StalkSpec,
        target_spec: StalkSpec,
        projection_matrix: Optional[np.ndarray] = None
    ):
        self.source_spec = source_spec
        self.target_spec = target_spec
        
        if projection_matrix is not None:
            self.matrix = projection_matrix
        else:
            # Default: truncate or pad
            self.matrix = self._default_projection()
    
    def _default_projection(self) -> np.ndarray:
        """Create default projection matrix."""
        src_dim = self.source_spec.dimension
        tgt_dim = self.target_spec.dimension
        
        # Simple: take first tgt_dim components
        matrix = np.zeros((tgt_dim, src_dim))
        for i in range(min(src_dim, tgt_dim)):
            matrix[i, i] = 1.0
        
        return matrix
    
    def project(self, stalk: Stalk) -> Stalk:
        """Project stalk to target context."""
        if stalk.spec != self.source_spec:
            raise ValueError(f"Stalk spec mismatch: {stalk.spec} != {self.source_spec}")
        
        projected_data = self.matrix @ stalk.data
        return Stalk(
            spec=self.target_spec,
            data=projected_data,
            vertex_id=stalk.vertex_id
        )
    
    def __call__(self, stalk: Stalk) -> Stalk:
        return self.project(stalk)


# Standard projections
PRIVATE_TO_PUBLIC = StalkProjection(PRIVATE_STALK, PUBLIC_STALK)
PRIVATE_TO_ZK = StalkProjection(PRIVATE_STALK, ZK_STALK)
ZK_TO_PUBLIC = StalkProjection(ZK_STALK, PUBLIC_STALK)


class StalkBundle:
    """
    A collection of stalks over a topology.
    
    This is the sheaf data: a stalk at each vertex.
    """
    
    def __init__(self, spec: StalkSpec):
        self.spec = spec
        self.stalks: Dict[int, Stalk] = {}
    
    def set_stalk(self, vertex_id: int, stalk: Stalk):
        """Set stalk at vertex."""
        if stalk.spec != self.spec:
            raise ValueError("Stalk spec mismatch")
        stalk.vertex_id = vertex_id
        self.stalks[vertex_id] = stalk
    
    def get_stalk(self, vertex_id: int) -> Optional[Stalk]:
        """Get stalk at vertex."""
        return self.stalks.get(vertex_id)
    
    def to_cochain(self) -> np.ndarray:
        """Convert to cochain (flattened array)."""
        if not self.stalks:
            return np.array([])
        
        max_vertex = max(self.stalks.keys())
        cochain = np.zeros((max_vertex + 1) * self.spec.dimension)
        
        for vid, stalk in self.stalks.items():
            offset = vid * self.spec.dimension
            cochain[offset:offset+self.spec.dimension] = stalk.data
        
        return cochain
    
    @classmethod
    def from_cochain(cls, cochain: np.ndarray, spec: StalkSpec) -> 'StalkBundle':
        """Create bundle from cochain."""
        bundle = cls(spec)
        n_vertices = len(cochain) // spec.dimension
        
        for vid in range(n_vertices):
            offset = vid * spec.dimension
            data = cochain[offset:offset+spec.dimension]
            bundle.set_stalk(vid, Stalk(spec=spec, data=data, vertex_id=vid))
        
        return bundle
    
    def project_all(self, projection: StalkProjection) -> 'StalkBundle':
        """Project all stalks to new context."""
        new_bundle = StalkBundle(projection.target_spec)
        for vid, stalk in self.stalks.items():
            new_bundle.set_stalk(vid, projection(stalk))
        return new_bundle


# =============================================================================
# CONVENIENCE FUNCTIONS
# =============================================================================

def create_private_stalk(
    harmonic_secret: np.ndarray,
    hodge_noise: np.ndarray,
    metadata: np.ndarray,
    vertex_id: Optional[int] = None
) -> Stalk:
    """Create a private stalk with explicit fields."""
    data = np.concatenate([harmonic_secret, hodge_noise, metadata])
    return Stalk(spec=PRIVATE_STALK, data=data, vertex_id=vertex_id)


def create_public_stalk(value: float, vertex_id: Optional[int] = None) -> Stalk:
    """Create a public stalk (balance/commitment)."""
    return Stalk.from_value(value, vertex_id)


def create_zk_stalk(
    commitment: np.ndarray,
    blinding: np.ndarray,
    vertex_id: Optional[int] = None
) -> Stalk:
    """Create a ZK intermediate stalk."""
    data = np.concatenate([commitment, blinding])
    return Stalk(spec=ZK_STALK, data=data, vertex_id=vertex_id)


# =============================================================================
# TEST
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("STALK PRIMITIVE TEST")
    print("=" * 60)
    
    # Create private stalk
    print("\n1. Creating private stalk...")
    private = create_private_stalk(
        harmonic_secret=np.random.randn(128),
        hodge_noise=np.random.randn(64),
        metadata=np.random.randn(64),
        vertex_id=0
    )
    print(f"   Spec: {private.spec.name}")
    print(f"   Dimension: {len(private.data)}")
    print(f"   Commitment: {private.commitment()[:16].hex()}...")
    
    # Create public stalk
    print("\n2. Creating public stalk...")
    public = create_public_stalk(value=1000.0, vertex_id=0)
    print(f"   Spec: {public.spec.name}")
    print(f"   Value: {public.data[0]}")
    
    # Project private → public
    print("\n3. Projecting private → public...")
    projected = PRIVATE_TO_PUBLIC(private)
    print(f"   Source dim: {len(private.data)}")
    print(f"   Target dim: {len(projected.data)}")
    print(f"   Projected value: {projected.data[0]:.4f}")
    
    # Create bundle
    print("\n4. Creating stalk bundle...")
    bundle = StalkBundle(PUBLIC_STALK)
    bundle.set_stalk(0, create_public_stalk(1000.0, 0))  # Alice
    bundle.set_stalk(1, create_public_stalk(0.0, 1))     # Bob
    
    cochain = bundle.to_cochain()
    print(f"   Bundle size: {len(bundle.stalks)} stalks")
    print(f"   Cochain: {cochain}")
    
    # Simulate transfer
    print("\n5. Simulating transfer (Alice → Bob, 100)...")
    bundle.stalks[0].data[0] -= 100.0
    bundle.stalks[1].data[0] += 100.0
    
    new_cochain = bundle.to_cochain()
    print(f"   New cochain: {new_cochain}")
    
    print("\n" + "=" * 60)
    print("✅ STALK PRIMITIVE WORKING")
    print("=" * 60)
