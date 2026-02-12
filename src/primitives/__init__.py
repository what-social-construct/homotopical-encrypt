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

4. K-THEORY (fine invariants for incentive layer)
   - Chern/Segre classes: curvature and self-intersection
   - λ-ring: exterior powers, information density
   - Adams operations: symmetry detection
   - Hatcher classes: Stiefel-Whitney, Pontryagin
   - Characteristic cycles: per-cell activity from restriction maps

5. PERSISTENT HOMOLOGY (topological fingerprinting)
   - Filtration, barcode computation, bottleneck distance
   - Persistence landscapes, persistence profiles

6. DIVERGENCE MEASURES (information geometry)
   - KL, JSD, Hellinger, TV, Wasserstein, Bregman framework
   - Adaptive selection for stalk comparison in incentive layer

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

# K-Theory (fine invariants for incentive layer)
from .k_theory import (
    # Chern / Segre
    ChernData,
    SegreData,
    compute_chern_classes,
    compute_segre_classes,
    compute_curvature_from_holonomy,
    chern_character,
    # λ-ring / Adams
    LambdaRingData,
    compute_lambda_ring,
    compute_adams_operations,
    adams_from_lambda,
    symmetry_ratio,
    # Hatcher classes
    HatcherClasses,
    compute_hatcher_classes,
    compute_stiefel_whitney,
    compute_pontryagin_classes,
    # Characteristic cycles
    CharacteristicCycle,
    compute_characteristic_cycle_from_restrictions,
    compute_characteristic_cycle_from_sheaf,
    # Profiles
    KTheoryProfile,
    ExtendedKTheoryProfile,
    compute_k_theory_profile,
    compute_extended_profile,
    profile_fiber_bundle,
    profile_sheaf,
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

# Persistent homology (topological fingerprinting)
from .persistence import (
    PersistencePair,
    PersistenceBarcode,
    PersistenceProfile,
    compute_persistent_homology,
    bottleneck_distance,
    persistence_landscape,
    compute_persistence_profile,
)

# Divergence measures (information geometry for incentive layer)
from .divergence import (
    kullback_leibler,
    jensen_shannon,
    itakura_saito,
    mahalanobis,
    hellinger,
    total_variation,
    wasserstein_1d,
    bregman_divergence,
    adaptive_divergence,
    get_divergence,
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
    # K-Theory
    "ChernData",
    "SegreData",
    "compute_chern_classes",
    "compute_segre_classes",
    "compute_curvature_from_holonomy",
    "chern_character",
    "LambdaRingData",
    "compute_lambda_ring",
    "compute_adams_operations",
    "adams_from_lambda",
    "symmetry_ratio",
    "HatcherClasses",
    "compute_hatcher_classes",
    "compute_stiefel_whitney",
    "compute_pontryagin_classes",
    "CharacteristicCycle",
    "compute_characteristic_cycle_from_restrictions",
    "compute_characteristic_cycle_from_sheaf",
    "KTheoryProfile",
    "ExtendedKTheoryProfile",
    "compute_k_theory_profile",
    "compute_extended_profile",
    "profile_fiber_bundle",
    "profile_sheaf",
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
    # Persistent homology
    "PersistencePair",
    "PersistenceBarcode",
    "PersistenceProfile",
    "compute_persistent_homology",
    "bottleneck_distance",
    "persistence_landscape",
    "compute_persistence_profile",
    # Divergence measures
    "kullback_leibler",
    "jensen_shannon",
    "itakura_saito",
    "mahalanobis",
    "hellinger",
    "total_variation",
    "wasserstein_1d",
    "bregman_divergence",
    "adaptive_divergence",
    "get_divergence",
]
