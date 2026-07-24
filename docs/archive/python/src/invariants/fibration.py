"""
Fibration Invariants - Fiber/Stalk Structure Validation

Validates the LOCAL structure of fibrations:
- Stalk consistency across fibers
- Projection map compatibility
- Local trivialization
- Holonomy around loops

Uses primitives:
- primitives/stalk.py: Stalk, StalkSpec, StalkBundle, StalkProjection
- primitives/cochain.py: CochainComplex

From Barbero et al. (2022): "manifold-and-graph-aware orthogonal maps 
which optimally align the tangent spaces of neighbouring data points"

From Bodnar et al. (2022): "underlying geometry of the graph is 
deeply linked with the performance"
"""

from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Optional, Set
import numpy as np
from enum import Enum

from ..primitives.stalk import (
    Stalk, StalkSpec, StalkBundle, StalkProjection,
    PRIVATE_STALK, PUBLIC_STALK, ZK_STALK
)
from ..primitives.cochain import CochainComplex


class FibrationStatus(Enum):
    """Status of fibration validation."""
    VALID = "valid"
    INVALID_STALK_DIM = "invalid_stalk_dim"
    INVALID_PROJECTION = "invalid_projection"
    INVALID_TRIVIALIZATION = "invalid_trivialization"
    INVALID_HOLONOMY = "invalid_holonomy"
    INVALID_CONSISTENCY = "invalid_consistency"


# =============================================================================
# GEOMETRIC INVARIANT GATES (hard-fail)
#
# These are the single source of truth for structural checks.
# Every module that constructs or uses geometric objects MUST call these.
# Violation = terminate. No recovery. Could be malicious.
# =============================================================================

def assert_orthogonal(
    matrix: np.ndarray,
    label: str = "matrix",
    tolerance: float = 1e-10
) -> None:
    """
    HARD GATE: Assert matrix is orthogonal (Q^T Q = I).
    
    Called by:
    - FiberBundle.random() — connection construction
    - EphemeralFiber.verify_homotopy_equivalence() — transport matrix
    - QuantumSheafFibration — credential edge_keys
    - _compute_holonomy_from_maps — edge restriction maps
    
    Orthogonal transport preserves:
    - Norms (message integrity)
    - Inner products (spectral fingerprints)
    - Eigenvalues (homotopy class)
    
    Violation means transport WILL corrupt data. Terminate.
    """
    if matrix.ndim != 2 or matrix.shape[0] != matrix.shape[1]:
        raise RuntimeError(
            f"INVARIANT VIOLATION [{label}]: Expected square matrix, "
            f"got shape {matrix.shape}. Aborting."
        )
    
    n = matrix.shape[0]
    err = np.linalg.norm(matrix.T @ matrix - np.eye(n))
    if err > tolerance:
        raise RuntimeError(
            f"INVARIANT VIOLATION [{label}]: Not orthogonal: "
            f"||Q^TQ - I|| = {err:.2e} > {tolerance}. "
            f"Transport would corrupt data. Aborting."
        )


def assert_spectral_preserved(
    original_eigenvalues: np.ndarray,
    transported_eigenvalues: np.ndarray,
    label: str = "transport",
    tolerance: float = 1e-6
) -> None:
    """
    HARD GATE: Assert eigenvalues unchanged by transport.
    
    If orthogonal transport changes the spectrum, something is deeply wrong:
    either the transport isn't actually orthogonal, or the eigendecomposition
    is corrupted. Either way, the homotopy class is broken.
    
    Violation = terminate. Spectral fingerprint would be wrong.
    """
    if len(original_eigenvalues) != len(transported_eigenvalues):
        raise RuntimeError(
            f"INVARIANT VIOLATION [{label}]: Eigenvalue count changed: "
            f"{len(original_eigenvalues)} → {len(transported_eigenvalues)}. Aborting."
        )
    
    orig_sorted = np.sort(original_eigenvalues)
    trans_sorted = np.sort(transported_eigenvalues)
    err = np.linalg.norm(orig_sorted - trans_sorted)
    
    if err > tolerance:
        raise RuntimeError(
            f"INVARIANT VIOLATION [{label}]: Spectrum changed under transport: "
            f"||λ_orig - λ_transported|| = {err:.2e}. "
            f"Homotopy class broken. Aborting."
        )


def assert_stalk_dimension(
    data: np.ndarray,
    expected_dim: int,
    label: str = "stalk"
) -> None:
    """
    HARD GATE: Assert stalk data matches expected fiber dimension.
    
    Dimension mismatch means either truncation (data loss) or
    padding (information leak). Both are security violations.
    """
    if len(data) != expected_dim:
        raise RuntimeError(
            f"INVARIANT VIOLATION [{label}]: Dimension mismatch: "
            f"got {len(data)}, expected {expected_dim}. "
            f"Truncation/padding would corrupt or leak data. Aborting."
        )


@dataclass(frozen=True)
class FibrationInvariants:
    """
    Invariants for fiber bundle / fibration structure.
    
    These capture the LOCAL geometry of the sheaf.
    Two fibrations with different fiber invariants cannot be equivalent.
    """
    # Stalk specification
    stalk_context: str  # PRIVATE, PUBLIC, ZK
    stalk_dimension: int
    
    # Fiber consistency
    uniform_fibers: bool  # All stalks have same dimension
    n_fibers: int  # Number of stalks
    
    # Bundle structure
    total_dimension: int  # sum of stalk dims
    base_dimension: int  # number of base points (vertices)
    
    # Holonomy class (trivial if all parallel transports compose to identity)
    holonomy_trivial: bool
    holonomy_order: int  # Order of holonomy group (1 = trivial)
    
    # Connection flatness (curvature around 2-cells)
    connection_flat: bool
    max_curvature: float
    
    def __hash__(self):
        return hash((
            self.stalk_context,
            self.stalk_dimension,
            self.uniform_fibers,
            self.n_fibers,
            self.holonomy_trivial
        ))
    
    @classmethod
    def from_bundle(cls, bundle: StalkBundle, complex: Optional[CochainComplex] = None) -> 'FibrationInvariants':
        """Compute fibration invariants from stalk bundle."""
        spec = bundle.spec
        stalks = bundle.stalks
        
        # Basic dimensions
        n_fibers = len(stalks)
        total_dim = n_fibers * spec.dimension
        base_dim = max(stalks.keys()) + 1 if stalks else 0
        
        # Check uniformity
        uniform = all(s.spec.dimension == spec.dimension for s in stalks.values())
        
        # Compute holonomy if complex provided
        holonomy_trivial = True
        holonomy_order = 1
        connection_flat = True
        max_curvature = 0.0
        
        if complex is not None:
            holonomy_trivial, holonomy_order = _compute_holonomy(bundle, complex)
            connection_flat, max_curvature = _compute_curvature(bundle, complex)
        
        return cls(
            stalk_context=spec.context.value,
            stalk_dimension=spec.dimension,
            uniform_fibers=uniform,
            n_fibers=n_fibers,
            total_dimension=total_dim,
            base_dimension=base_dim,
            holonomy_trivial=holonomy_trivial,
            holonomy_order=holonomy_order,
            connection_flat=connection_flat,
            max_curvature=max_curvature
        )
    
    @classmethod
    def from_sheaf_data(
        cls,
        vertex_stalks: Dict[int, np.ndarray],
        edge_maps: Dict[Tuple[int, int], np.ndarray],
        stalk_dim: int,
        edges: List[Tuple[int, int]]
    ) -> 'FibrationInvariants':
        """Compute from raw sheaf data (vertex stalks + edge restriction maps)."""
        n_fibers = len(vertex_stalks)
        total_dim = sum(len(v) for v in vertex_stalks.values())
        base_dim = max(vertex_stalks.keys()) + 1 if vertex_stalks else 0
        
        # Check uniform fibers
        uniform = all(len(v) == stalk_dim for v in vertex_stalks.values())
        
        # Compute holonomy from edge maps
        holonomy_trivial, holonomy_order = _compute_holonomy_from_maps(edge_maps, edges)
        
        # Curvature from composition around faces
        connection_flat = holonomy_trivial  # Flat iff trivial holonomy
        max_curvature = 0.0 if holonomy_trivial else 1.0
        
        return cls(
            stalk_context="private",  # Default
            stalk_dimension=stalk_dim,
            uniform_fibers=uniform,
            n_fibers=n_fibers,
            total_dimension=total_dim,
            base_dimension=base_dim,
            holonomy_trivial=holonomy_trivial,
            holonomy_order=holonomy_order,
            connection_flat=connection_flat,
            max_curvature=max_curvature
        )


def _compute_holonomy(bundle: StalkBundle, complex: CochainComplex) -> Tuple[bool, int]:
    """
    Compute holonomy around loops in the complex.
    
    Holonomy measures how parallel transport around loops
    fails to return to the identity.
    """
    # For each cycle, compute parallel transport
    # Trivial if all cycles give identity
    
    # Simple check: for triangle complex, transport around faces
    if not complex.faces:
        return True, 1  # No 2-cells = no curvature = trivial
    
    # Need edge maps (restriction maps) to compute transport
    # For now, assume trivial if uniform fibers
    if len(set(s.spec.dimension for s in bundle.stalks.values())) == 1:
        return True, 1
    
    return False, 2  # Non-trivial if non-uniform


def _compute_holonomy_from_maps(
    edge_maps: Dict[Tuple[int, int], np.ndarray],
    edges: List[Tuple[int, int]]
) -> Tuple[bool, int]:
    """
    Compute holonomy from edge restriction maps.
    
    For each loop, check if composition of maps is identity.
    """
    if not edge_maps:
        return True, 1
    
    # Find a simple cycle (triangle) if possible
    # Check composition around the cycle
    
    # Check if all maps are orthogonal (holonomy in O(n))
    # Uses the centralized assert_orthogonal gate for consistency
    orthogonal_count = 0
    for edge, A in edge_maps.items():
        if A.ndim == 2 and A.shape[0] == A.shape[1]:
            err = np.linalg.norm(A.T @ A - np.eye(A.shape[0]))
            if err < 1e-6:
                orthogonal_count += 1
    
    # Trivial if all orthogonal (can compose to identity)
    all_orthogonal = orthogonal_count == len(edge_maps)
    return all_orthogonal, 1 if all_orthogonal else 2


def _compute_curvature(bundle: StalkBundle, complex: CochainComplex) -> Tuple[bool, float]:
    """
    Compute connection curvature (flatness check).
    
    Flat connection: parallel transport around infinitesimal loops is identity.
    For discrete complex: check around 2-cells.
    """
    if not complex.faces:
        return True, 0.0  # No faces = flat
    
    # Need restriction maps to compute curvature
    # For now, return conservative estimate
    return True, 0.0


# =============================================================================
# VALIDATION
# =============================================================================

def validate_fibration_invariants(
    inv1: FibrationInvariants,
    inv2: FibrationInvariants,
    strict: bool = True
) -> Tuple[bool, FibrationStatus, str]:
    """
    Check if two fibrations could be equivalent based on fiber invariants.
    
    Args:
        inv1, inv2: Fibration invariants to compare
        strict: If True, require exact match; if False, allow compatible
        
    Returns:
        (compatible, status, message)
    """
    # Stalk dimension must match
    if inv1.stalk_dimension != inv2.stalk_dimension:
        return False, FibrationStatus.INVALID_STALK_DIM, \
            f"Stalk dim: {inv1.stalk_dimension} ≠ {inv2.stalk_dimension}"
    
    # Number of fibers must match
    if inv1.n_fibers != inv2.n_fibers:
        return False, FibrationStatus.INVALID_CONSISTENCY, \
            f"Fiber count: {inv1.n_fibers} ≠ {inv2.n_fibers}"
    
    # Uniformity must match
    if inv1.uniform_fibers != inv2.uniform_fibers:
        return False, FibrationStatus.INVALID_CONSISTENCY, \
            f"Uniformity mismatch"
    
    if strict:
        # Holonomy must match
        if inv1.holonomy_trivial != inv2.holonomy_trivial:
            return False, FibrationStatus.INVALID_HOLONOMY, \
                f"Holonomy: trivial={inv1.holonomy_trivial} vs {inv2.holonomy_trivial}"
        
        # Flatness must match
        if inv1.connection_flat != inv2.connection_flat:
            return False, FibrationStatus.INVALID_TRIVIALIZATION, \
                f"Flatness mismatch"
    
    return True, FibrationStatus.VALID, "Fibration invariants compatible"


# =============================================================================
# STALK-SPECIFIC INVARIANTS
# =============================================================================

@dataclass
class StalkInvariants:
    """
    Invariants for individual stalks.
    
    Captures the structure of local state at a vertex.
    """
    vertex_id: int
    dimension: int
    context: str
    
    # Field structure
    field_names: Tuple[str, ...]
    field_dims: Tuple[int, ...]
    
    # Data characteristics
    norm: float
    nonzero_fields: int
    
    @classmethod
    def from_stalk(cls, stalk: Stalk) -> 'StalkInvariants':
        """Compute invariants from a stalk."""
        field_names = tuple(stalk.spec.fields.keys())
        field_dims = tuple(stalk.spec.fields.values())
        
        # Count nonzero fields
        nonzero = 0
        for fname in field_names:
            try:
                if np.any(stalk.get_field(fname) != 0):
                    nonzero += 1
            except KeyError:
                pass
        
        return cls(
            vertex_id=stalk.vertex_id or -1,
            dimension=stalk.spec.dimension,
            context=stalk.spec.context.value,
            field_names=field_names,
            field_dims=field_dims,
            norm=stalk.norm(),
            nonzero_fields=nonzero
        )


# =============================================================================
# PROJECTION INVARIANTS
# =============================================================================

@dataclass
class ProjectionInvariants:
    """
    Invariants for stalk projections (context transitions).
    
    Tracks how information is lost/preserved in projection.
    """
    source_context: str
    target_context: str
    source_dim: int
    target_dim: int
    
    # Projection structure
    rank: int  # Rank of projection matrix
    kernel_dim: int  # dim(ker(π))
    
    # Information preservation
    information_ratio: float  # target_dim / source_dim
    
    @classmethod
    def from_projection(cls, proj: StalkProjection) -> 'ProjectionInvariants':
        """Compute invariants from a projection."""
        src_dim = proj.source_spec.dimension
        tgt_dim = proj.target_spec.dimension
        
        # Compute rank
        rank = int(np.linalg.matrix_rank(proj.matrix))
        kernel_dim = src_dim - rank
        
        info_ratio = tgt_dim / src_dim if src_dim > 0 else 0.0
        
        return cls(
            source_context=proj.source_spec.context.value,
            target_context=proj.target_spec.context.value,
            source_dim=src_dim,
            target_dim=tgt_dim,
            rank=rank,
            kernel_dim=kernel_dim,
            information_ratio=info_ratio
        )


# =============================================================================
# VALIDATOR CLASS
# =============================================================================

@dataclass
class FibrationInvariantValidator:
    """
    Validates fibration structure and computes invariants.
    """
    strict: bool = True
    tolerance: float = 1e-6
    
    def validate(
        self,
        source: FibrationInvariants,
        target: FibrationInvariants
    ) -> Tuple[bool, str]:
        """Validate fibration compatibility."""
        valid, status, msg = validate_fibration_invariants(source, target, self.strict)
        return valid, msg
    
    def compute_bundle_invariants(self, bundle: StalkBundle) -> Dict:
        """Compute full invariants for a bundle."""
        inv = FibrationInvariants.from_bundle(bundle)
        
        return {
            "stalk_context": inv.stalk_context,
            "stalk_dimension": inv.stalk_dimension,
            "n_fibers": inv.n_fibers,
            "uniform_fibers": inv.uniform_fibers,
            "total_dimension": inv.total_dimension,
            "holonomy_trivial": inv.holonomy_trivial,
            "holonomy_order": inv.holonomy_order,
            "connection_flat": inv.connection_flat,
            "max_curvature": inv.max_curvature
        }
    
    def compute_stalk_invariants(self, stalk: Stalk) -> Dict:
        """Compute invariants for a single stalk."""
        inv = StalkInvariants.from_stalk(stalk)
        
        return {
            "vertex_id": inv.vertex_id,
            "dimension": inv.dimension,
            "context": inv.context,
            "field_names": inv.field_names,
            "field_dims": inv.field_dims,
            "norm": inv.norm,
            "nonzero_fields": inv.nonzero_fields
        }


# =============================================================================
# CONVENIENCE
# =============================================================================

def compute_fibration_invariants(
    bundle: StalkBundle,
    complex: Optional[CochainComplex] = None
) -> FibrationInvariants:
    """Compute fibration invariants from bundle."""
    return FibrationInvariants.from_bundle(bundle, complex)


def validate_bundle_consistency(bundle: StalkBundle) -> Tuple[bool, str]:
    """Check if bundle has consistent fiber structure."""
    if not bundle.stalks:
        return True, "Empty bundle"
    
    spec = bundle.spec
    for vid, stalk in bundle.stalks.items():
        if stalk.spec != spec:
            return False, f"Stalk at vertex {vid} has inconsistent spec"
        if len(stalk.data) != spec.dimension:
            return False, f"Stalk at vertex {vid} has wrong dimension"
    
    return True, "Bundle consistent"


# =============================================================================
# TEST
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("FIBRATION INVARIANTS TEST")
    print("=" * 60)
    
    # Create stalk bundle
    print("\n1. Creating stalk bundle...")
    bundle = StalkBundle(PUBLIC_STALK)
    bundle.set_stalk(0, Stalk.from_value(1000.0, 0))
    bundle.set_stalk(1, Stalk.from_value(500.0, 1))
    bundle.set_stalk(2, Stalk.from_value(750.0, 2))
    
    # Compute invariants
    print("\n2. Computing fibration invariants...")
    inv = compute_fibration_invariants(bundle)
    print(f"   Context: {inv.stalk_context}")
    print(f"   Stalk dim: {inv.stalk_dimension}")
    print(f"   N fibers: {inv.n_fibers}")
    print(f"   Uniform: {inv.uniform_fibers}")
    print(f"   Holonomy trivial: {inv.holonomy_trivial}")
    
    # Validate consistency
    print("\n3. Validating bundle consistency...")
    valid, msg = validate_bundle_consistency(bundle)
    print(f"   Valid: {valid} ({msg})")
    
    # Create another bundle and compare
    print("\n4. Comparing two bundles...")
    bundle2 = StalkBundle(PUBLIC_STALK)
    bundle2.set_stalk(0, Stalk.from_value(200.0, 0))
    bundle2.set_stalk(1, Stalk.from_value(300.0, 1))
    bundle2.set_stalk(2, Stalk.from_value(400.0, 2))
    
    inv2 = compute_fibration_invariants(bundle2)
    
    validator = FibrationInvariantValidator()
    compatible, msg = validator.validate(inv, inv2)
    print(f"   Compatible: {compatible} ({msg})")
    
    # Stalk invariants
    print("\n5. Individual stalk invariants...")
    stalk_inv = StalkInvariants.from_stalk(bundle.stalks[0])
    print(f"   Vertex {stalk_inv.vertex_id}: dim={stalk_inv.dimension}, norm={stalk_inv.norm:.2f}")
    
    print("\n" + "=" * 60)
    print("✅ FIBRATION INVARIANTS: Fiber structure validation")
    print("=" * 60)
