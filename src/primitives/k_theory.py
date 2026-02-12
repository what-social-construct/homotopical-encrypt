"""
K-Theory Primitives: λ-Rings, Segre Classes, Adams Operations

Extracts FINER invariants from the sheaf than Betti numbers alone.
These invariants measure the "quality" and "information capacity"
of a node's contribution — natural inputs for the incentive layer.

WHAT THIS ADDS TO THE INVARIANT PIPELINE:

  Current (coarse):
    Betti numbers (β₀, β₁, β₂)  — counts components, loops, voids
    Spectral gap (λ₁)            — single connectivity number
    Spectral fingerprint          — hash of all eigenvalues

  New (fine):
    Chern classes c₁, c₂         — curvature of the connection
    Segre classes s₁, s₂         — inverse Chern (self-intersection)
    λ-ring rank                   — independent information channels
    Adams operations ψⁿ          — cyclic structure detection
    Chern character ch(E)         — bridge between K-theory and cohomology

MATHEMATICAL FOUNDATION:

  The FiberBundle has connection matrices {R_e} on edges.
  These define a CURVATURE via holonomy around loops:

    F_△ = R_{01} · R_{12} · R_{20} - I  (holonomy defect around triangle)

  From curvature F, we extract:
    c₁(E) = tr(F) / 2π           (first Chern class = total curvature)
    c₂(E) = (tr(F)² - tr(F²)) / 8π²  (second Chern class)
    s(E) = c(E)⁻¹                (Segre classes = inverse total Chern)

  From the stalk bundle, we extract:
    λᵏ(E) = ∧ᵏ(stalks)          (exterior powers = independent channels)
    rank(E) = fiber dimension     (but λ-rank is finer — accounts for degeneracy)
    ψⁿ(E) = Adams from λ         (Newton's identities relate ψⁿ to λᵏ)

INCENTIVE LAYER INTERPRETATION:

  Segre degree:
    High s₁ = stalks highly correlated across edges = consistent value
    Low s₁ = stalks disagree = noise, not signal
    → REWARD high Segre degree in incentive layer

  λ-ring rank:
    High rank = many independent information channels
    Low rank = redundant/degenerate contribution
    → WEIGHT block production probability by effective rank

  Adams ψ²:
    Detects 2-fold symmetry in the connection (repeated structure)
    High ψ² trace = highly symmetric = possibly Sybil
    → PENALIZE suspiciously symmetric connections

  Characteristic classes (Hatcher-style):
    Stiefel-Whitney w₁, w₂  — mod 2, detect orientability / spin
    Pontryagin p₁, p₂       — real curvature (from Chern of complexification)
    w₁ = 0 means orientable → normal
    w₁ ≠ 0 means non-orientable connection → suspicious topology

  Characteristic cycle CC(F):
    For each cell σ, the multiplicity m_σ = rank drop of restriction maps
    CC(F) = Σ m_σ · [T*_σ X]  (Lagrangian cycle in cotangent bundle)
    High multiplicity = active region (sheaf varies there)
    Low multiplicity = passive (sheaf is constant)
    → WEIGHT incentive distribution by CC multiplicity (active nodes earn more)

REFERENCES:
  - Atiyah (1967): K-Theory (foundational)
  - Grothendieck: SGA 6 (Riemann-Roch, Chern character)
  - Hirzebruch: Topological Methods in Algebraic Geometry
  - Hatcher (2003): Vector Bundles and K-Theory (Stiefel-Whitney, Pontryagin)
  - Kashiwara-Schapira (1990): Sheaves on Manifolds (characteristic cycles)
  - Hansen & Ghrist (2019): Spectral Theory of Cellular Sheaves
"""

from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Optional
import numpy as np
import hashlib
from itertools import combinations


# =============================================================================
# CHERN CLASSES (from connection curvature)
# =============================================================================

@dataclass
class ChernData:
    """
    Chern classes extracted from a fiber bundle's connection.

    c₀ = 1 (always)
    c₁ = tr(F) / 2π  (first Chern class — total curvature)
    c₂ = (tr(F)² - tr(F²)) / 8π²  (second Chern class)
    total_chern = 1 + c₁·t + c₂·t² + ...  (formal power series)
    """
    c0: float = 1.0
    c1: float = 0.0
    c2: float = 0.0
    higher: List[float] = field(default_factory=list)

    @property
    def total(self) -> List[float]:
        """Total Chern class as polynomial coefficients [c₀, c₁, c₂, ...]."""
        return [self.c0, self.c1, self.c2] + self.higher

    @property
    def euler_class(self) -> float:
        """Top Chern class = Euler class of the bundle."""
        total = self.total
        return total[-1] if total else 0.0


def compute_curvature_from_holonomy(
    connection: Dict[Tuple[int, int], np.ndarray],
    triangles: List[Tuple[int, int, int]],
    fiber_dim: int,
) -> List[np.ndarray]:
    """
    Compute discrete curvature F_△ for each triangle.

    For triangle (i, j, k):
      F_△ = R_{ij} · R_{jk} · R_{ki} - I

    If the connection is flat, F_△ = 0 for all triangles.
    Nonzero F_△ measures the holonomy defect = curvature.

    Args:
        connection: edge → orthogonal matrix (parallel transport)
        triangles: list of (i, j, k) face tuples
        fiber_dim: dimension of each fiber

    Returns:
        List of curvature matrices, one per triangle.
    """
    curvatures = []

    for tri in triangles:
        i, j, k = tri

        # Get connection matrices (canonical direction: sorted edge)
        def get_R(u, v):
            e = tuple(sorted([u, v]))
            R = connection.get(e, np.eye(fiber_dim))
            if u <= v:
                return R
            else:
                return R.T  # reverse direction = transpose (orthogonal)

        # Holonomy around triangle: R_{ij} · R_{jk} · R_{ki}
        holonomy = get_R(i, j) @ get_R(j, k) @ get_R(k, i)

        # Curvature = holonomy defect
        F = holonomy - np.eye(fiber_dim)
        curvatures.append(F)

    return curvatures


def compute_chern_classes(
    connection: Dict[Tuple[int, int], np.ndarray],
    triangles: List[Tuple[int, int, int]],
    fiber_dim: int,
) -> ChernData:
    """
    Compute Chern classes from discrete connection curvature.

    Uses the Chern-Weil homomorphism:
      c₁ = tr(F) / 2π
      c₂ = (tr(F)² - tr(F²)) / 8π²

    where F is the average curvature over all triangles.

    For a FLAT connection (all holonomy = I), c₁ = c₂ = 0.
    Nonzero Chern classes indicate genuine geometric content.
    """
    if not triangles:
        return ChernData()

    curvatures = compute_curvature_from_holonomy(connection, triangles, fiber_dim)

    if not curvatures:
        return ChernData()

    # Average curvature (coarse — could weight by triangle area)
    F_avg = np.mean(curvatures, axis=0)

    # c₁ = tr(F) / 2π
    c1 = float(np.trace(F_avg)) / (2 * np.pi)

    # c₂ = (tr(F)² - tr(F²)) / 8π²
    tr_F = np.trace(F_avg)
    tr_F2 = np.trace(F_avg @ F_avg)
    c2 = float(tr_F**2 - tr_F2) / (8 * np.pi**2)

    return ChernData(c1=c1, c2=c2)


# =============================================================================
# SEGRE CLASSES (inverse of total Chern class)
# =============================================================================

@dataclass
class SegreData:
    """
    Segre classes: s(E) = c(E)⁻¹ in the formal power series ring.

    s₀ = 1
    s₁ = -c₁
    s₂ = c₁² - c₂
    s₃ = -c₁³ + 2c₁c₂ - c₃

    Interpretation:
    - s₁ measures "self-intersection" of the bundle
    - Positive s₁ → stalks diverge across edges (low correlation)
    - Negative s₁ → stalks converge (high correlation = consistent value)

    For incentives: |s₁| = "consistency score" of the node's contribution.
    """
    s0: float = 1.0
    s1: float = 0.0
    s2: float = 0.0
    higher: List[float] = field(default_factory=list)

    @property
    def consistency_score(self) -> float:
        """
        Consistency score for incentive layer.

        |s₁| normalized to [0, 1]:
        - 0 = flat connection (no curvature, no information)
        - ~0.5 = moderate geometric content
        - ~1.0 = highly curved (rich structure, but check for adversarial)
        """
        return float(min(1.0, abs(self.s1) * 10))  # Scale factor empirical

    @property
    def total(self) -> List[float]:
        return [self.s0, self.s1, self.s2] + self.higher


def compute_segre_classes(chern: ChernData) -> SegreData:
    """
    Compute Segre classes from Chern classes.

    s(E) = c(E)⁻¹ in formal power series:
      s₀ = 1
      s₁ = -c₁
      s₂ = c₁² - c₂
      s₃ = -c₁³ + 2c₁c₂ - c₃  (if c₃ exists)
    """
    c1 = chern.c1
    c2 = chern.c2

    s0 = 1.0
    s1 = -c1
    s2 = c1**2 - c2

    higher = []
    if chern.higher:
        c3 = chern.higher[0] if len(chern.higher) > 0 else 0.0
        s3 = -(c1**3) + 2 * c1 * c2 - c3
        higher.append(s3)

    return SegreData(s1=s1, s2=s2, higher=higher)


# =============================================================================
# CHERN CHARACTER (bridge K-theory ↔ cohomology)
# =============================================================================

def chern_character(chern: ChernData, rank: int) -> List[float]:
    """
    Chern character: ch(E) = rank + c₁ + (c₁² - 2c₂)/2 + ...

    The Chern character is a ring homomorphism:
      ch: K(X) → H*(X; ℚ)

    It converts K-theoretic data (vector bundle) to cohomological data
    (rational cohomology classes). This bridges the two invariant systems.

    ch₀ = rank(E)
    ch₁ = c₁
    ch₂ = (c₁² - 2c₂) / 2
    """
    ch0 = float(rank)
    ch1 = chern.c1
    ch2 = (chern.c1**2 - 2 * chern.c2) / 2.0

    return [ch0, ch1, ch2]


# =============================================================================
# λ-RING OPERATIONS (exterior powers of the stalk bundle)
# =============================================================================

@dataclass
class LambdaRingData:
    """
    λ-ring invariants of the stalk bundle.

    λᵏ(E) = k-th exterior power of the bundle.
    dim(λᵏ(E)) = C(rank, k) generically, but can be less
    if the stalks are degenerate (linearly dependent).

    The EFFECTIVE RANK is the largest k such that λᵏ(E) ≠ 0.
    This measures independent information channels.

    For incentives:
    - effective_rank / fiber_dim = "information density"
    - High density = genuinely independent stalk data = real contribution
    - Low density = redundant/padded stalk data = possible spam
    """
    fiber_dim: int
    effective_rank: int  # Largest k with λᵏ ≠ 0
    lambda_dims: List[int]  # [dim(λ⁰), dim(λ¹), dim(λ²), ...]
    singular_values: np.ndarray  # Singular values of stalk data matrix

    @property
    def information_density(self) -> float:
        """
        Information density: effective_rank / fiber_dim.

        1.0 = all channels carry independent information
        0.0 = completely degenerate (rank 0)
        """
        if self.fiber_dim == 0:
            return 0.0
        return self.effective_rank / self.fiber_dim

    @property
    def lambda_polynomial(self) -> List[int]:
        """λ-polynomial: Σ dim(λᵏ)·tᵏ coefficients."""
        return self.lambda_dims

    @property
    def lambda_euler(self) -> int:
        """
        λ-Euler characteristic: Σ (-1)ᵏ dim(λᵏ).

        Equals 0 for bundles with even-dimensional fibers.
        Nonzero means odd-dimensional effective fiber.
        """
        return sum((-1)**k * d for k, d in enumerate(self.lambda_dims))


def compute_lambda_ring(
    stalk_data: Dict[int, np.ndarray],
    fiber_dim: int,
    tolerance: float = 1e-8,
) -> LambdaRingData:
    """
    Compute λ-ring invariants from stalk data.

    Method:
    1. Stack all stalk vectors into a matrix M (n_vertices × fiber_dim)
    2. Compute SVD: M = U Σ V^T
    3. Effective rank = number of singular values > tolerance
    4. λᵏ dimension = C(effective_rank, k)

    The singular values tell us how many independent "channels"
    the stalks actually use. If fiber_dim = 256 but only 3 singular
    values are significant, the effective rank is 3.

    Args:
        stalk_data: vertex_id → stalk vector
        fiber_dim: nominal fiber dimension
        tolerance: singular value threshold

    Returns:
        LambdaRingData with effective rank and λ-dimensions
    """
    from math import comb

    if not stalk_data:
        return LambdaRingData(
            fiber_dim=fiber_dim,
            effective_rank=0,
            lambda_dims=[1],  # λ⁰ = 1 always
            singular_values=np.array([]),
        )

    # Stack stalk data into matrix
    M = np.array(list(stalk_data.values()))  # shape: (n_vertices, fiber_dim)

    # SVD
    if M.shape[0] < 2 or M.shape[1] < 2:
        # Trivial case
        sv = np.array([np.linalg.norm(M)])
        eff_rank = 1 if sv[0] > tolerance else 0
    else:
        _, sv, _ = np.linalg.svd(M, full_matrices=False)
        eff_rank = int(np.sum(sv > tolerance))

    # Compute λ-dimensions: dim(λᵏ) = C(effective_rank, k)
    lambda_dims = [comb(eff_rank, k) for k in range(eff_rank + 1)]

    return LambdaRingData(
        fiber_dim=fiber_dim,
        effective_rank=eff_rank,
        lambda_dims=lambda_dims,
        singular_values=sv,
    )


# =============================================================================
# ADAMS OPERATIONS (detect cyclic/symmetric structure)
# =============================================================================

def adams_from_lambda(lambda_dims: List[int], n: int) -> float:
    """
    Compute Adams operation ψⁿ from λ-ring data.

    Newton's identities relate Adams to λ:
      ψ¹ = λ¹
      ψ² = (ψ¹)·(λ¹) - 2·(λ²)
      ψ³ = (ψ²)·(λ¹) - (ψ¹)·(λ²) + 3·(λ³)

    General: ψⁿ = Σ_{k=1}^{n} (-1)^{k+1} · ψ^{n-k} · λᵏ  (for k < n)
             + (-1)^{n+1} · n · λⁿ

    Returns the "dimension" of ψⁿ(E) as a float (can be negative
    in virtual K-theory).

    For incentives:
    - ψ²/λ¹ = symmetry ratio
    - High ratio = connection has 2-fold symmetry (suspicious?)
    - Low ratio = genuinely asymmetric (normal for random fibrations)
    """
    # λ dimensions as floats
    lam = [float(d) for d in lambda_dims]

    # Compute ψ recursively
    psi = [0.0] * (n + 1)  # psi[k] = ψᵏ

    for k in range(1, n + 1):
        if k <= len(lam) - 1:
            psi[k] = sum(
                (-1) ** (j + 1) * psi[k - j] * (lam[j] if j < len(lam) else 0)
                for j in range(1, k)
            )
            psi[k] += (-1) ** (k + 1) * k * (lam[k] if k < len(lam) else 0)
        else:
            # λᵏ = 0 for k > effective_rank
            psi[k] = sum(
                (-1) ** (j + 1) * psi[k - j] * (lam[j] if j < len(lam) else 0)
                for j in range(1, k)
            )

    return psi[n]


def compute_adams_operations(
    lambda_data: LambdaRingData,
    max_n: int = 4,
) -> Dict[int, float]:
    """
    Compute Adams operations ψ¹, ψ², ..., ψⁿ.

    Returns dict: {n: ψⁿ(E)}.
    """
    result = {}
    for n in range(1, max_n + 1):
        result[n] = adams_from_lambda(lambda_data.lambda_dims, n)
    return result


def symmetry_ratio(adams_ops: Dict[int, float]) -> float:
    """
    Symmetry ratio: ψ² / ψ¹.

    Measures 2-fold symmetry in the connection.

    - ratio ≈ rank: normal (random orthogonal connection)
    - ratio >> rank: suspiciously symmetric (possible Sybil / copy)
    - ratio << rank: highly asymmetric (unusual but not adversarial)
    """
    psi1 = adams_ops.get(1, 1.0)
    psi2 = adams_ops.get(2, 0.0)

    if abs(psi1) < 1e-10:
        return 0.0
    return psi2 / psi1


# =============================================================================
# UNIFIED K-THEORY PROFILE (for incentive layer)
# =============================================================================

@dataclass
class KTheoryProfile:
    """
    Complete K-theoretic profile of a node's fiber bundle.

    Combines Chern/Segre classes with λ-ring data into a single
    profile usable by the incentive layer.

    Three scores:
    1. consistency (from Segre): how correlated are stalks across edges?
    2. density (from λ-rank): how much independent information?
    3. symmetry (from Adams): is the connection suspiciously regular?

    Combined incentive_score = consistency × density × (1 - symmetry_penalty)
    """
    chern: ChernData
    segre: SegreData
    lambda_ring: LambdaRingData
    adams: Dict[int, float]

    # Derived scores
    consistency: float = 0.0   # From Segre s₁
    density: float = 0.0       # From λ-ring effective_rank / fiber_dim
    symmetry: float = 0.0      # From Adams ψ² / ψ¹

    def __post_init__(self):
        self.consistency = self.segre.consistency_score
        self.density = self.lambda_ring.information_density
        self.symmetry = symmetry_ratio(self.adams) if self.adams else 0.0

    @property
    def incentive_score(self) -> float:
        """
        Combined incentive score in [0, 1].

        Rewards:
        - High consistency (correlated stalks = real contribution)
        - High information density (non-degenerate channels)

        Penalizes:
        - Suspiciously symmetric connections (Sybil indicator)

        This score can weight block production probability
        or direct incentive distribution via pullback.
        """
        # Symmetry penalty: penalize if ψ²/ψ¹ is much larger than rank
        rank = self.lambda_ring.effective_rank
        expected_symmetry = float(rank) if rank > 0 else 1.0
        actual_symmetry = abs(self.symmetry)
        symmetry_penalty = max(0.0, (actual_symmetry / expected_symmetry - 1.0))
        symmetry_penalty = min(1.0, symmetry_penalty)  # Cap at 1.0

        # Combined score
        raw = self.consistency * self.density * (1.0 - 0.5 * symmetry_penalty)
        return max(0.0, min(1.0, raw))

    @property
    def fingerprint(self) -> bytes:
        """Hash fingerprint of this K-theory profile."""
        data = (
            f"{self.chern.c1:.8f},{self.chern.c2:.8f},"
            f"{self.segre.s1:.8f},{self.segre.s2:.8f},"
            f"{self.lambda_ring.effective_rank},"
            f"{self.symmetry:.8f}"
        ).encode()
        return hashlib.sha256(data).digest()


def compute_k_theory_profile(
    connection: Dict[Tuple[int, int], np.ndarray],
    triangles: List[Tuple[int, int, int]],
    stalk_data: Dict[int, np.ndarray],
    fiber_dim: int,
) -> KTheoryProfile:
    """
    Compute complete K-theory profile from fiber bundle data.

    This is the main entry point for incentive layer analysis.

    Args:
        connection: edge → orthogonal matrix
        triangles: face list (for curvature)
        stalk_data: vertex → stalk vector (for λ-ring)
        fiber_dim: nominal fiber dimension

    Returns:
        KTheoryProfile with all invariants and scores
    """
    # Chern classes from connection curvature
    chern = compute_chern_classes(connection, triangles, fiber_dim)

    # Segre classes (inverse Chern)
    segre = compute_segre_classes(chern)

    # λ-ring from stalk data
    lambda_ring = compute_lambda_ring(stalk_data, fiber_dim)

    # Adams operations
    adams = compute_adams_operations(lambda_ring)

    return KTheoryProfile(
        chern=chern,
        segre=segre,
        lambda_ring=lambda_ring,
        adams=adams,
    )


# =============================================================================
# HATCHER CHARACTERISTIC CLASSES (Stiefel-Whitney, Pontryagin)
# =============================================================================

@dataclass
class HatcherClasses:
    """
    Characteristic classes à la Hatcher (Vector Bundles and K-Theory).

    Stiefel-Whitney classes w₁, w₂ (mod 2):
      w₁ = det(holonomy) mod 2. Detects orientability.
        w₁ = 0 → connection preserves orientation → normal
        w₁ = 1 → non-orientable → suspicious topology

      w₂ = second SW class. Detects spin structure.
        w₂ = 0 → bundle admits spin structure → well-behaved
        w₂ = 1 → no spin structure → unusual

    Pontryagin classes p₁, p₂ (from real bundle):
      p₁ = c₁(E⊗ℂ)² - 2c₂(E⊗ℂ)  (relates to real curvature)
      For our orthogonal connections, p₁ detects "real curvature"
      that Chern classes (which assume complex structure) may miss.

    Incentive interpretation:
      w₁ = 0 required (orientable connections only — non-orientable is adversarial)
      p₁ feeds into consistency score alongside Segre s₁
    """
    w1: int = 0       # First Stiefel-Whitney class (0 or 1)
    w2: int = 0       # Second Stiefel-Whitney class (0 or 1)
    p1: float = 0.0   # First Pontryagin class
    p2: float = 0.0   # Second Pontryagin class
    is_orientable: bool = True
    is_spin: bool = True


def compute_stiefel_whitney(
    connection: Dict[Tuple[int, int], np.ndarray],
    triangles: List[Tuple[int, int, int]],
    fiber_dim: int,
) -> Tuple[int, int]:
    """
    Compute Stiefel-Whitney classes w₁, w₂ from connection.

    w₁ = 0 iff all holonomies have det > 0 (orientable).
    w₂ = 0 iff all holonomies can be lifted to Spin(n).

    For orthogonal connections (our case):
      det(R) ∈ {+1, -1} since R ∈ O(n).
      w₁ = number of triangles with det(holonomy) = -1, mod 2.
      w₂ = second obstruction (simplified: from eigenvalue signs of holonomy).
    """
    if not triangles:
        return 0, 0

    negative_det_count = 0
    negative_eigenvalue_count = 0

    for tri in triangles:
        i, j, k = tri

        def get_R(u, v):
            e = tuple(sorted([u, v]))
            R = connection.get(e, np.eye(fiber_dim))
            return R if u <= v else R.T

        holonomy = get_R(i, j) @ get_R(j, k) @ get_R(k, i)
        det_h = np.linalg.det(holonomy)

        if det_h < 0:
            negative_det_count += 1

        # For w₂: count eigenvalues of holonomy near -1
        eigs = np.linalg.eigvals(holonomy)
        n_neg = np.sum(np.real(eigs) < -0.5)
        negative_eigenvalue_count += n_neg

    w1 = negative_det_count % 2
    w2 = int(negative_eigenvalue_count % 2)

    return w1, w2


def compute_pontryagin_classes(chern: ChernData) -> Tuple[float, float]:
    """
    Compute Pontryagin classes from Chern classes.

    For a real vector bundle E:
      p_k(E) = (-1)^k c_{2k}(E ⊗ ℂ)

    Simplified (using our Chern classes of the real connection):
      p₁ = c₁² - 2c₂  (first Pontryagin)
      p₂ = c₂² - 2c₁c₃ + 2c₄  (second, usually ≈ c₂² for us)
    """
    p1 = chern.c1**2 - 2 * chern.c2
    p2 = chern.c2**2  # Higher Chern classes ≈ 0 for small complexes

    return p1, p2


def compute_hatcher_classes(
    connection: Dict[Tuple[int, int], np.ndarray],
    triangles: List[Tuple[int, int, int]],
    fiber_dim: int,
    chern: Optional[ChernData] = None,
) -> HatcherClasses:
    """
    Compute all Hatcher-style characteristic classes.

    Combines Stiefel-Whitney (mod 2, topological) with
    Pontryagin (real curvature) classes.
    """
    w1, w2 = compute_stiefel_whitney(connection, triangles, fiber_dim)

    if chern is None:
        chern = compute_chern_classes(connection, triangles, fiber_dim)

    p1, p2 = compute_pontryagin_classes(chern)

    return HatcherClasses(
        w1=w1,
        w2=w2,
        p1=p1,
        p2=p2,
        is_orientable=(w1 == 0),
        is_spin=(w2 == 0),
    )


# =============================================================================
# CHARACTERISTIC CYCLES (microsupport / per-cell activity)
# =============================================================================

@dataclass
class CharacteristicCycle:
    """
    Characteristic cycle CC(F) of the sheaf F.

    For each cell σ, the multiplicity m_σ measures how much
    the sheaf "varies" at that cell:

      m_σ = fiber_dim - rank(restriction maps INTO σ)

    This is the discrete analog of microsupport from
    Kashiwara-Schapira. In the continuous case:
      CC(F) = Σ_σ m_σ · [T*_σ X]  (Lagrangian cycle in T*X)

    Incentive interpretation:
      High multiplicity = the sheaf changes significantly at this cell
      = this cell is an "active" node (carrying real information).
      Low multiplicity = the sheaf is locally constant
      = this cell is "passive" (not contributing new information).

      → WEIGHT incentive distribution by multiplicity.
      → Active nodes earn more because they carry real geometric content.
    """
    # Per-vertex multiplicity
    vertex_multiplicities: Dict[int, int]

    # Per-edge multiplicity
    edge_multiplicities: Dict[Tuple[int, int], int]

    # Total multiplicity (sum over all cells)
    total_multiplicity: int

    # Activity score: fraction of cells with nonzero multiplicity
    activity_score: float

    # Euler obstruction: alternating sum of multiplicities
    euler_obstruction: int

    @property
    def active_vertices(self) -> List[int]:
        """Vertices with nonzero multiplicity (sheaf varies there)."""
        return [v for v, m in self.vertex_multiplicities.items() if m > 0]

    @property
    def active_edges(self) -> List[Tuple[int, int]]:
        """Edges with nonzero multiplicity."""
        return [e for e, m in self.edge_multiplicities.items() if m > 0]


def compute_characteristic_cycle_from_restrictions(
    restrictions: Dict,
    nerve: Dict[int, List],
    fiber_dim: int,
    tolerance: float = 1e-8,
) -> CharacteristicCycle:
    """
    Compute characteristic cycle CC(F) from restriction maps.

    For each cell σ, the multiplicity is:
      m_σ = fiber_dim - min(rank of restriction maps touching σ)

    A cell where all restriction maps are full rank has m = 0
    (sheaf is locally free there). A cell where some restriction
    maps drop rank has m > 0 (sheaf has "interesting" behavior).

    This uses the actual restriction maps from CellularSheaf.restrictions
    or FiberBundle.connection.

    Args:
        restrictions: Dict mapping (from_cell, to_cell) → matrix
                      OR edge → connection matrix (from FiberBundle)
        nerve: Čech nerve
        fiber_dim: nominal fiber dimension
        tolerance: rank threshold

    Returns:
        CharacteristicCycle with per-cell multiplicities
    """
    vertex_mult = {}
    edge_mult = {}

    vertices = nerve.get(0, [])
    edges = nerve.get(1, [])

    # Determine if restrictions are sheaf-style or bundle-style
    sample_key = next(iter(restrictions), None) if restrictions else None
    is_sheaf_style = (
        sample_key is not None
        and isinstance(sample_key, tuple)
        and len(sample_key) == 2
        and isinstance(sample_key[0], tuple)
    )

    # Vertex multiplicities: rank drop of outgoing restriction maps
    for v_cell in vertices:
        v_id = v_cell[0] if isinstance(v_cell, tuple) else v_cell
        min_rank = fiber_dim

        if is_sheaf_style:
            # Sheaf-style: restrictions[(from_cell, to_cell)] = matrix
            for (from_c, to_c), R in restrictions.items():
                if from_c == v_cell or from_c == (v_id,):
                    rank = int(np.linalg.matrix_rank(R, tol=tolerance))
                    min_rank = min(min_rank, rank)
        else:
            # Bundle-style: restrictions[edge] = connection matrix
            for edge, R in restrictions.items():
                if v_id in edge:
                    rank = int(np.linalg.matrix_rank(R, tol=tolerance))
                    min_rank = min(min_rank, rank)

        vertex_mult[v_id] = fiber_dim - min_rank

    # Edge multiplicities: rank drop of the restriction/connection on that edge
    for edge in edges:
        e_tuple = tuple(sorted(edge)) if not isinstance(edge, tuple) else edge
        rank = fiber_dim

        if is_sheaf_style:
            # Check both directions
            for (from_c, to_c), R in restrictions.items():
                if to_c == e_tuple:
                    r = int(np.linalg.matrix_rank(R, tol=tolerance))
                    rank = min(rank, r)
        else:
            R = restrictions.get(e_tuple, None)
            if R is not None:
                rank = int(np.linalg.matrix_rank(R, tol=tolerance))

        edge_mult[e_tuple] = fiber_dim - rank

    # Totals
    total = sum(vertex_mult.values()) + sum(edge_mult.values())
    n_cells = len(vertex_mult) + len(edge_mult)
    n_active = sum(1 for m in vertex_mult.values() if m > 0) + \
               sum(1 for m in edge_mult.values() if m > 0)
    activity = n_active / n_cells if n_cells > 0 else 0.0

    # Euler obstruction: Σ (-1)^dim(σ) · m_σ
    euler_obs = sum(vertex_mult.values()) - sum(edge_mult.values())

    return CharacteristicCycle(
        vertex_multiplicities=vertex_mult,
        edge_multiplicities=edge_mult,
        total_multiplicity=total,
        activity_score=activity,
        euler_obstruction=euler_obs,
    )


def compute_characteristic_cycle_from_sheaf(sheaf) -> CharacteristicCycle:
    """
    Compute CC(F) directly from a CellularSheaf object.

    Uses the sheaf's restriction maps and nerve.
    """
    # Get fiber dim from first stalk
    fiber_dim = 1
    for cell, stalk in sheaf.stalks.items():
        fiber_dim = len(stalk) if stalk.ndim == 1 else stalk.shape[0]
        break

    return compute_characteristic_cycle_from_restrictions(
        restrictions=sheaf.restrictions,
        nerve=sheaf.nerve,
        fiber_dim=fiber_dim,
    )


# =============================================================================
# FULL EXTENDED PROFILE (K-theory + Hatcher + CC)
# =============================================================================

@dataclass
class ExtendedKTheoryProfile:
    """
    Full K-theoretic + characteristic class + CC profile.

    Extends KTheoryProfile with:
    - Hatcher classes (Stiefel-Whitney, Pontryagin)
    - Characteristic cycle (per-cell multiplicity)
    - Chern character (K-theory ↔ cohomology bridge)

    This is the COMPLETE invariant set for incentive analysis.
    """
    # Base K-theory
    k_theory: KTheoryProfile

    # Hatcher classes
    hatcher: HatcherClasses

    # Characteristic cycle
    char_cycle: CharacteristicCycle

    # Chern character
    chern_char: List[float]

    @property
    def incentive_score(self) -> float:
        """
        Extended incentive score incorporating ALL invariants.

        Base score (from KTheoryProfile):
          consistency × density × (1 - symmetry_penalty)

        Modifiers:
          × orientability_factor (1.0 if orientable, 0.5 if not)
          × activity_boost (1.0 + 0.2 × activity_score)
          × flatness_penalty (penalize trivially flat connections)
        """
        base = self.k_theory.incentive_score

        # Orientability: non-orientable connections are suspicious
        orient_factor = 1.0 if self.hatcher.is_orientable else 0.5

        # Activity: reward nodes where the sheaf actually varies
        activity_boost = 1.0 + 0.2 * self.char_cycle.activity_score

        # Flatness: zero Chern = zero curvature = trivial contribution
        # Small penalty for completely flat (lazy/trivial) connections
        curvature_magnitude = abs(self.k_theory.chern.c1) + abs(self.k_theory.chern.c2)
        flatness_penalty = 1.0 if curvature_magnitude > 1e-6 else 0.8

        score = base * orient_factor * activity_boost * flatness_penalty
        return max(0.0, min(1.0, score))

    @property
    def fingerprint(self) -> bytes:
        """Extended fingerprint incorporating all invariants."""
        data = (
            self.k_theory.fingerprint
            + f"{self.hatcher.w1}{self.hatcher.w2}{self.hatcher.p1:.6f}".encode()
            + f"{self.char_cycle.total_multiplicity},{self.char_cycle.euler_obstruction}".encode()
        )
        return hashlib.sha256(data).digest()


def compute_extended_profile(
    connection: Dict[Tuple[int, int], np.ndarray],
    triangles: List[Tuple[int, int, int]],
    stalk_data: Dict[int, np.ndarray],
    fiber_dim: int,
    nerve: Dict[int, List] = None,
    restrictions: Dict = None,
) -> ExtendedKTheoryProfile:
    """
    Compute the FULL extended K-theory profile.

    This is the master function for incentive layer analysis.
    Takes connection matrices, stalk data, and optionally
    restriction maps + nerve for characteristic cycle computation.

    Args:
        connection: edge → orthogonal matrix (from FiberBundle)
        triangles: face list
        stalk_data: vertex → stalk vector
        fiber_dim: nominal fiber dimension
        nerve: Čech nerve (if None, built from connection edges)
        restrictions: sheaf restriction maps or connection (for CC)
    """
    # Base K-theory profile
    k_profile = compute_k_theory_profile(connection, triangles, stalk_data, fiber_dim)

    # Hatcher classes
    hatcher = compute_hatcher_classes(connection, triangles, fiber_dim, k_profile.chern)

    # Characteristic cycle
    if restrictions is not None and nerve is not None:
        char_cycle = compute_characteristic_cycle_from_restrictions(
            restrictions, nerve, fiber_dim
        )
    elif nerve is not None:
        # Use connection as restriction maps
        char_cycle = compute_characteristic_cycle_from_restrictions(
            connection, nerve, fiber_dim
        )
    else:
        # Minimal: no CC computation
        char_cycle = CharacteristicCycle(
            vertex_multiplicities={},
            edge_multiplicities={},
            total_multiplicity=0,
            activity_score=0.0,
            euler_obstruction=0,
        )

    # Chern character
    ch = chern_character(k_profile.chern, fiber_dim)

    return ExtendedKTheoryProfile(
        k_theory=k_profile,
        hatcher=hatcher,
        char_cycle=char_cycle,
        chern_char=ch,
    )


# =============================================================================
# CONVENIENCE: COMPUTE FROM FIBER BUNDLE / SHEAF DIRECTLY
# =============================================================================

def profile_sheaf(sheaf) -> ExtendedKTheoryProfile:
    """
    Compute extended profile directly from a CellularSheaf object.

    This connects k_theory.py to geometry/sheaf.py's CellularSheaf,
    using the sheaf's actual restriction maps and nerve structure.
    """
    nerve = sheaf.nerve
    triangles = nerve.get(2, [])

    # Build connection dict from restriction maps (edge restrictions)
    connection = {}
    for (from_c, to_c), R in sheaf.restrictions.items():
        if len(to_c) == 2:  # It's an edge restriction
            connection[to_c] = R

    # Get fiber dim and stalk data
    fiber_dim = 1
    stalk_data = {}
    for cell, stalk in sheaf.stalks.items():
        if len(cell) == 1:  # Vertex stalk
            dim = len(stalk) if stalk.ndim == 1 else stalk.shape[0]
            fiber_dim = max(fiber_dim, dim)
            stalk_data[cell[0]] = stalk

    return compute_extended_profile(
        connection=connection,
        triangles=triangles,
        stalk_data=stalk_data,
        fiber_dim=fiber_dim,
        nerve=nerve,
        restrictions=sheaf.restrictions,
    )


def profile_fiber_bundle(bundle) -> KTheoryProfile:
    """
    Compute K-theory profile directly from a FiberBundle object.

    This is the easiest API — just pass a FiberBundle and get back
    all invariants + incentive score.
    """
    connection = bundle.connection
    fiber_dim = bundle.fiber_dim
    triangles = bundle.base_space.get(2, [])

    # Extract stalk data from connection endpoints
    # (approximate: use identity-transported basis as stalk data)
    vertices = [v[0] if isinstance(v, tuple) else v
                for v in bundle.base_space.get(0, [])]

    stalk_data = {}
    for v in vertices:
        # Transport identity basis to this vertex to get stalk representation
        stalk_data[v] = np.eye(fiber_dim)[0]  # First basis vector

        # If there are edges from vertex 0, use actual transport
        for edge, R in connection.items():
            if edge[0] == 0 and edge[1] == v:
                stalk_data[v] = R @ np.eye(fiber_dim)[0]
                break
            elif edge[1] == 0 and edge[0] == v:
                stalk_data[v] = R.T @ np.eye(fiber_dim)[0]
                break

    return compute_k_theory_profile(connection, triangles, stalk_data, fiber_dim)


# =============================================================================
# TEST
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("K-THEORY PRIMITIVES TEST")
    print("=" * 60)

    # Build a test fiber bundle (triangle topology)
    nerve = {
        0: [(0,), (1,), (2,)],
        1: [(0, 1), (1, 2), (0, 2)],
        2: [(0, 1, 2)],
    }
    fiber_dim = 4

    # Random orthogonal connections
    connection = {}
    for edge in nerve[1]:
        A = np.random.randn(fiber_dim, fiber_dim)
        Q, _ = np.linalg.qr(A)
        connection[edge] = Q

    # Test curvature
    print("\n1. Curvature from holonomy:")
    curvatures = compute_curvature_from_holonomy(connection, nerve[2], fiber_dim)
    for i, F in enumerate(curvatures):
        print(f"   Triangle {i}: ||F|| = {np.linalg.norm(F):.4f}")

    # Test Chern classes
    print("\n2. Chern classes:")
    chern = compute_chern_classes(connection, nerve[2], fiber_dim)
    print(f"   c₁ = {chern.c1:.6f}")
    print(f"   c₂ = {chern.c2:.6f}")

    # Test Segre classes
    print("\n3. Segre classes:")
    segre = compute_segre_classes(chern)
    print(f"   s₁ = {segre.s1:.6f}  (= -c₁)")
    print(f"   s₂ = {segre.s2:.6f}  (= c₁² - c₂)")
    print(f"   consistency_score = {segre.consistency_score:.4f}")

    # Test Chern character
    print("\n4. Chern character:")
    ch = chern_character(chern, rank=fiber_dim)
    print(f"   ch = {[f'{x:.4f}' for x in ch]}")

    # Test λ-ring
    print("\n5. λ-ring (from stalk data):")
    stalk_data = {v[0]: np.random.randn(fiber_dim) for v in nerve[0]}
    lr = compute_lambda_ring(stalk_data, fiber_dim)
    print(f"   fiber_dim = {lr.fiber_dim}")
    print(f"   effective_rank = {lr.effective_rank}")
    print(f"   λ-dims = {lr.lambda_dims}")
    print(f"   information_density = {lr.information_density:.4f}")
    print(f"   singular_values = {lr.singular_values}")

    # Test Adams operations
    print("\n6. Adams operations:")
    adams = compute_adams_operations(lr)
    for n, psi_n in adams.items():
        print(f"   ψ{n} = {psi_n:.4f}")
    print(f"   symmetry_ratio = {symmetry_ratio(adams):.4f}")

    # Test full profile
    print("\n7. Full K-theory profile:")
    profile = compute_k_theory_profile(connection, nerve[2], stalk_data, fiber_dim)
    print(f"   consistency  = {profile.consistency:.4f}")
    print(f"   density      = {profile.density:.4f}")
    print(f"   symmetry     = {profile.symmetry:.4f}")
    print(f"   ──────────────────────────")
    print(f"   incentive_score = {profile.incentive_score:.4f}")
    print(f"   fingerprint     = {profile.fingerprint.hex()[:16]}...")

    # Test flat connection (should have zero curvature)
    print("\n8. Flat connection (identity):")
    flat_conn = {e: np.eye(fiber_dim) for e in nerve[1]}
    flat_profile = compute_k_theory_profile(flat_conn, nerve[2], stalk_data, fiber_dim)
    print(f"   c₁ = {flat_profile.chern.c1:.6f}  (should be ≈ 0)")
    print(f"   c₂ = {flat_profile.chern.c2:.6f}  (should be ≈ 0)")
    print(f"   s₁ = {flat_profile.segre.s1:.6f}  (should be ≈ 0)")

    # Test Hatcher characteristic classes
    print("\n9. Hatcher classes (Stiefel-Whitney + Pontryagin):")
    hatcher = compute_hatcher_classes(connection, nerve[2], fiber_dim, chern)
    print(f"   w₁ = {hatcher.w1}  (0 = orientable)")
    print(f"   w₂ = {hatcher.w2}  (0 = spin)")
    print(f"   p₁ = {hatcher.p1:.6f}")
    print(f"   p₂ = {hatcher.p2:.6f}")
    print(f"   orientable = {hatcher.is_orientable}")

    # Test characteristic cycle
    print("\n10. Characteristic cycle CC(F):")
    cc = compute_characteristic_cycle_from_restrictions(connection, nerve, fiber_dim)
    print(f"   vertex multiplicities = {cc.vertex_multiplicities}")
    print(f"   edge multiplicities   = {cc.edge_multiplicities}")
    print(f"   total multiplicity    = {cc.total_multiplicity}")
    print(f"   activity score        = {cc.activity_score:.4f}")
    print(f"   Euler obstruction     = {cc.euler_obstruction}")

    # Test extended profile (everything combined)
    print("\n11. Extended K-theory profile (FULL):")
    ext = compute_extended_profile(
        connection, nerve[2], stalk_data, fiber_dim, nerve=nerve
    )
    print(f"   Base incentive   = {ext.k_theory.incentive_score:.4f}")
    print(f"   Extended score   = {ext.incentive_score:.4f}")
    print(f"   Chern character  = {[f'{x:.4f}' for x in ext.chern_char]}")
    print(f"   Fingerprint      = {ext.fingerprint.hex()[:16]}...")

    print("\n" + "=" * 60)
    print("✅ K-THEORY + HATCHER + CC READY")
    print("=" * 60)
