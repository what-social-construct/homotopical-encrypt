"""
Algebraic Primitives for Homotopical Cryptography

Cochain-based cryptographic primitives (from HOMOTOPICAL_PRIMITIVES.md):

1. COCHAIN TYPES (foundation)
   - Cochain, VertexCochain, EdgeCochain
   - CochainComplex with coboundary δ

2. EXTERIOR ALGEBRA + GRASSMANN MANIFOLD
   - wedge: v₁ ∧ v₂ → Plücker coordinates
   - hodge_star: ∗ : ∧ᵏ → ∧ⁿ⁻ᵏ (duality)
   - interior_product: ι_v(ω) (contraction)
   - Grassmann: Gr(k,n) geometry — projectors, principal angles,
     Plücker embed/recover, exp/log, Karcher mean, parallel transport

3. NATURAL TRANSFORMATIONS (preserve functorial structure)
   - pullback, pushforward between fibrations
   - The key invariant: These operations commute with coboundary δ.
   - This ensures transformations preserve cohomology classes.

Exploratory K-theory, persistence, and divergence modules are intentionally not
part of this public surface.  Their earlier semantic claims are deprecated; see
``docs/SEMANTIC_PARITY_QUEUE.md`` before reusing any of that code.

"""

from .algebra import (
    wedge,
    wedge_k,
    hodge_star,
    interior_product,
    weighted_sum,
    scalar_multiply,
)

from .natural import (
    NaturalTransformation,
    pullback,
    pushforward,
    compose_nat,
)

from .stalk import (
    StalkContext,
    StalkSpec,
    Stalk,
    StalkProjection,
    StalkBundle,
    PRIVATE_STALK,
    PUBLIC_STALK,
    ZK_STALK,
    PRIVATE_TO_PUBLIC,
    PRIVATE_TO_ZK,
    ZK_TO_PUBLIC,
    create_private_stalk,
    create_public_stalk,
    create_zk_stalk,
)

# Cochain primitives (foundation)
from .cochain import (
    CellIndex,
    Cochain,
    VertexCochain,
    EdgeCochain,
    CochainComplex,
    inner_product,
    cochain_mod,
)

# Homotopy equivalence (core relation)
from .homotopy import (
    HomotopyInvariants,
    HomotopyEquivalence,
    HomotopyClass,
    HomotopyPath,
    KeyRotation,
    rotate_within_class,
    verify_equivalence,
)

# Grassmann manifold (extends exterior algebra with manifold geometry)
from .grassmann import (
    subspace_projector,
    projector_rank,
    principal_angles,
    grassmann_distance,
    chordal_distance,
    to_plucker,
    from_plucker,
    plucker_inner_product,
    plucker_distance,
    grassmann_exp,
    grassmann_log,
    grassmann_geodesic,
    grassmann_karcher_mean,
    consensus_subspace,
    grassmann_parallel_transport,
    random_grassmann_point,
    stalk_to_subspace,
)

__all__ = [
    # Cochain primitives (foundation)
    "CellIndex",
    "Cochain",
    "VertexCochain",
    "EdgeCochain",
    "CochainComplex",
    "inner_product",
    "cochain_mod",
    # Algebra
    "wedge",
    "wedge_k", 
    "hodge_star",
    "interior_product",
    "weighted_sum",
    "scalar_multiply",
    # Natural transformations
    "NaturalTransformation",
    "pullback",
    "pushforward",
    "compose_nat",
    # Stalk primitives
    "StalkContext",
    "StalkSpec",
    "Stalk",
    "StalkProjection",
    "StalkBundle",
    "PRIVATE_STALK",
    "PUBLIC_STALK",
    "ZK_STALK",
    "PRIVATE_TO_PUBLIC",
    "PRIVATE_TO_ZK",
    "ZK_TO_PUBLIC",
    "create_private_stalk",
    "create_public_stalk",
    "create_zk_stalk",
    # Homotopy equivalence
    "HomotopyInvariants",
    "HomotopyEquivalence",
    "HomotopyClass",
    "HomotopyPath",
    "KeyRotation",
    "rotate_within_class",
    "verify_equivalence",
    # Grassmann manifold
    "subspace_projector",
    "projector_rank",
    "principal_angles",
    "grassmann_distance",
    "chordal_distance",
    "to_plucker",
    "from_plucker",
    "plucker_inner_product",
    "plucker_distance",
    "grassmann_exp",
    "grassmann_log",
    "grassmann_geodesic",
    "grassmann_karcher_mean",
    "consensus_subspace",
    "grassmann_parallel_transport",
    "random_grassmann_point",
    "stalk_to_subspace",
]
