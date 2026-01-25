"""
Algebraic Primitives for Homotopical Cryptography

Cochain-based cryptographic primitives (from HOMOTOPICAL_PRIMITIVES.md):

1. COCHAIN TYPES (foundation)
   - Cochain, VertexCochain, EdgeCochain
   - CochainComplex with coboundary δ

2. CRYPTOGRAPHIC PRIMITIVES (all from cochain)
   - CochainCommitment: δ(m || r) hiding
   - [Future] CohomologicalMAC: ker(Δ) membership
   - [Future] PathSpaceSignature: homotopy path proof

3. EXTERIOR ALGEBRA (preserve Grassmann structure)  
   - wedge: v₁ ∧ v₂ → Plücker coordinates
   - hodge_star: ∗ : ∧ᵏ → ∧ⁿ⁻ᵏ (duality)
   - interior_product: ι_v(ω) (contraction)

4. NATURAL TRANSFORMATIONS (preserve functorial structure)
   - pullback, pushforward between fibrations
   
The key invariant: These operations commute with coboundary δ.
This ensures transformations preserve cohomology classes.
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

# Cryptographic primitives (from cochain)
from .commitment import (
    CochainCommitment,
    BlindedCommitment,
    VectorCommitment,
    add_commitments,
    scalar_mult_commitment,
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
    # Cryptographic primitives
    "CochainCommitment",
    "BlindedCommitment",
    "VectorCommitment",
    "add_commitments",
    "scalar_mult_commitment",
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
]
