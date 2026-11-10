"""
Geometry module: Sheaves, Laplacians, Topology, Invariants, and Homotopy Paths.

Based on:
- Hansen & Ghrist (2019). Toward a Spectral Theory of Cellular Sheaves. arXiv:1808.01513
- Helfer (2019). First-Order Homotopical Logic. arXiv:1908.08944
- Robinson (2014). Topological Signal Processing.
"""

from .sheaf import CellularSheaf, build_cech_nerve, build_cech_nerve_from_contexts
from .sheaf_laplacian import SheafLaplacian
from .topology import (
    SimplicialComplex,
    CechComplex,
    compute_betti_numbers,
    PersistenceDiagram,
)
from .fiber_bundle import FiberBundle

# Lattice operations (pure math - security analysis in crypto/)
from .lattice import (
    Lattice,
    Sublattice,
    CochainLattice,
    extract_harmonic_sublattice,
    hodge_decomposition_lattices,
)

# Spectral noise (geometric structure - secure random in crypto/)
from .noise import (
    spectral_noise,
    heat_kernel_sample,
    exact_noise,
    ornstein_uhlenbeck_sample,
    hodge_structured_noise,
)
from .homotopy_path import (
    # Path construction
    HomotopyPath,
    PathStatus,
    construct_geodesic_path,
    verify_homotopy_equivalence,
    # Invariant validation
    InvariantReport,
    validate_laplacian,
    check_spectral_equivalence,
    check_full_equivalence,
    # Constants
    SQRT2,
    POV_LOWER,
    POV_UPPER,
)

# Invariant modules - NOW IN invariants/ (re-exported for backwards compatibility)
from ..invariants.spectral import (
    SpectralInvariants,
    compute_spectral_invariants,
    SpectralInvariantValidator,
    spectra_match,
)
from ..invariants.homotopical import (
    HomotopicalLogicInvariants,
    HLevel,
    compute_homotopical_invariants,
    HomotopicalInvariantValidator,
)
from ..invariants.cohomology import (
    CohomologyInvariants,
    NerveValidation,
    compute_cohomology_invariants,
    validate_nerve_structure,
    CohomologyInvariantValidator,
)
from ..invariants.unified import (
    HomotopyClassFingerprint,
    UnifiedInvariantValidator,
    CheckpointSeverity,
    InvariantCheckpoint,
    validate_fibration,
    fingerprints_equivalent,
)

__all__ = [
    # Sheaves
    "CellularSheaf",
    "build_cech_nerve",
    "build_cech_nerve_from_contexts",
    "SheafLaplacian",
    # Topology
    "SimplicialComplex",
    "CechComplex",
    "compute_betti_numbers",
    "PersistenceDiagram",
    # Fiber bundles
    "FiberBundle",
    # Lattice operations
    "Lattice",
    "Sublattice",
    "CochainLattice",
    "extract_harmonic_sublattice",
    "hodge_decomposition_lattices",
    # Spectral noise
    "spectral_noise",
    "heat_kernel_sample",
    "exact_noise",
    "ornstein_uhlenbeck_sample",
    "hodge_structured_noise",
    # Homotopy paths
    "HomotopyPath",
    "PathStatus",
    "construct_geodesic_path",
    "verify_homotopy_equivalence",
    # Legacy invariant validation
    "InvariantReport",
    "validate_laplacian",
    "check_spectral_equivalence",
    "check_full_equivalence",
    # √2 constants
    "SQRT2",
    "POV_LOWER",
    "POV_UPPER",
    # ========== NEW INVARIANT SYSTEM ==========
    # Spectral invariants (Hansen & Ghrist)
    "SpectralInvariants",
    "compute_spectral_invariants",
    "SpectralInvariantValidator",
    "spectra_match",
    # Homotopical logic invariants (Helfer)
    "HomotopicalLogicInvariants",
    "HLevel",
    "compute_homotopical_invariants",
    "HomotopicalInvariantValidator",
    # Cohomology invariants
    "CohomologyInvariants",
    "NerveValidation",
    "compute_cohomology_invariants",
    "validate_nerve_structure",
    "CohomologyInvariantValidator",
    # Unified validator
    "HomotopyClassFingerprint",
    "UnifiedInvariantValidator",
    "CheckpointSeverity",
    "InvariantCheckpoint",
    "validate_fibration",
    "fingerprints_equivalent",
]
