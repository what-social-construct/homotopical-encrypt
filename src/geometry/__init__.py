"""
Geometry module: Sheaves, Laplacians, Topology, and Homotopy Paths.

Based on Hansen & Ghrist (2019): Toward a Spectral Theory of Cellular Sheaves.
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
    # Homotopy paths (NEW)
    "HomotopyPath",
    "PathStatus",
    "construct_geodesic_path",
    "verify_homotopy_equivalence",
    # Invariant validation (NEW)
    "InvariantReport",
    "validate_laplacian",
    "check_spectral_equivalence",
    "check_full_equivalence",
    # √2 constants
    "SQRT2",
    "POV_LOWER",
    "POV_UPPER",
]
