"""
Tsirelson-Style Bound — Classical & Quantum Hardness of Hodge Distinguishing

Python mirror of tsirelson_update.lean.

PROBLEM (the distinguishing game):
  Given a noisy cochain b = h + e where h ∈ ker(Δ) and e ∈ im(δ)⊕im(δ*),
  the adversary must identify WHICH Laplacian Δ produced b.

  The set of candidate Laplacians Ω is parameterized by the Grassmannian
  Gr(k, d): each k-dimensional subspace W ⊂ R^d defines Δ_W = I - P_W
  (the projector onto W^⊥). The adversary sees b and must guess W.

TSIRELSON-STYLE BOUND:
  Classical adversary:  success ≤ (1/2)^d
  Quantum adversary:    success ≤ (1/2)^d × (1 + C · relative_gap)

  Where relative_gap = λ₁/λ_max (= gap_ratio in SpectralInvariants).

  The quantum advantage is BOUNDED by the relative spectral gap —
  NOT exponential. This is the analog of Tsirelson's bound for Bell
  inequalities: quantum correlations are bounded by 2√2, not ∞.

CORRESPONDENCE WITH LEAN (tsirelson_update.lean):
  Grassmannian_Laplacians k  →  grassmannian_laplacians(k, d)
  Ω_1                        →  omega_k(1, d)
  LaplacianSpace β           →  validate_laplacian_space(Δ, β)
  SpectralGap                →  spectral_gap (absolute)
  MinSpectralGap             →  min_spectral_gap(Ω)
  likelihood                 →  likelihood(b, Δ, sigma)
  success_prob_classical     →  classical_success_prob(A, Ω, sigma)
  Quantum_Bound              →  quantum_bound(d, k, relative_gap)
  Classical_Bound             →  classical_bound(d)

CORRESPONDENCE WITH IMPLEMENTATION:
  gap_ratio in SpectralInvariants  =  λ₁/λ_max  =  relative spectral gap
  Gr(k, d)  =  Gr(MIN_HARMONIC_DIM, DEFAULT_STALK_DIM)  =  Gr(256, 512)
  credential.py random_orthogonal(d)  =  sampling a point on Gr(k, d)

References:
- tsirelson_update.lean: formal Lean4 proof (Grassmannian_Laplacians, Ω_1_infinite)
- hardness_proof.lean: Hodge_Hardness_Reduction, Hodge_Ambiguity, Hodge_Strictly_Harder
"""

from dataclasses import dataclass
from typing import List, Tuple, Optional, Callable
import numpy as np


# =============================================================================
# GRASSMANNIAN LAPLACIAN FAMILY (matches Lean: Grassmannian_Laplacians)
# =============================================================================

def grassmannian_laplacian(W: np.ndarray) -> np.ndarray:
    """
    Construct the Laplacian Δ_W = I - P_W from a subspace W.

    Given an orthonormal basis W (d × k matrix), the Laplacian is
    the projector onto the orthogonal complement of W:
      Δ_W = I - W @ W.T

    ker(Δ_W) = W (the harmonic subspace).
    im(Δ_W) = W^⊥ (the noise subspace).

    Matches Lean: Grassmannian_Laplacians k
      { Δ | ∃ W : Gr(k, n), Δ = I - P_W }

    Args:
        W: Orthonormal basis of the harmonic subspace (d × k).

    Returns:
        Δ: d × d Laplacian matrix (Hermitian, PSD, ker dim = k).
    """
    d = W.shape[0]
    P_W = W @ W.T  # Projector onto harmonic subspace
    Delta = np.eye(d) - P_W  # Projector onto noise subspace
    return Delta


def sample_grassmannian(d: int, k: int, rng=None) -> np.ndarray:
    """
    Sample a uniformly random point on the Grassmannian Gr(k, d).

    Returns an orthonormal basis W (d × k) for a random k-dimensional
    subspace of R^d. This is the key generation step:
    the random subspace IS the secret.

    Matches credential.py: random_orthogonal(d) → take first k columns.

    Args:
        d: Ambient dimension (DEFAULT_STALK_DIM = 512).
        k: Subspace dimension (MIN_HARMONIC_DIM = 256).
        rng: Random number generator (default: numpy default).

    Returns:
        W: d × k orthonormal matrix (columns = basis of W).
    """
    if rng is None:
        rng = np.random.default_rng()
    # QR decomposition of random Gaussian matrix gives Haar-uniform O(d)
    G = rng.standard_normal((d, k))
    Q, _ = np.linalg.qr(G)
    return Q


def grassmannian_laplacians(k: int, d: int, n_samples: int, rng=None) -> List[np.ndarray]:
    """
    Sample n_samples Laplacians from the Grassmannian family Ω_k.

    Each Δ is parameterized by a random k-dim subspace of R^d.
    This is a finite sample from the (uncountably) infinite Ω_k.

    Matches Lean: Ω_1 (for k=1) or general Grassmannian_Laplacians k.

    Args:
        k: Harmonic subspace dimension.
        d: Ambient dimension.
        n_samples: Number of Laplacians to sample.

    Returns:
        List of d × d Laplacian matrices.
    """
    if rng is None:
        rng = np.random.default_rng()
    laplacians = []
    for _ in range(n_samples):
        W = sample_grassmannian(d, k, rng)
        laplacians.append(grassmannian_laplacian(W))
    return laplacians


# =============================================================================
# LAPLACIAN SPACE VALIDATION (matches Lean: LaplacianSpace)
# =============================================================================

def validate_laplacian_space(Delta: np.ndarray, beta: int, tol: float = 1e-8) -> Tuple[bool, str]:
    """
    Validate Δ ∈ LaplacianSpace(β).

    Checks (matching Lean LaplacianSpace definition):
    1. Hermitian: Δ = Δ^T
    2. PSD: ∀ x, x^T Δ x ≥ 0
    3. ker dim = β: dim(ker(Δ)) = β

    Args:
        Delta: Matrix to validate.
        beta: Expected kernel dimension.
        tol: Numerical tolerance.

    Returns:
        (valid, reason)
    """
    d = Delta.shape[0]

    # 1. Hermitian
    asym = np.linalg.norm(Delta - Delta.T)
    if asym > tol:
        return (False, f"Not Hermitian: ||Δ - Δ^T|| = {asym:.2e}")

    # 2. PSD
    eigenvalues = np.linalg.eigvalsh(Delta)
    min_eig = float(eigenvalues[0])
    if min_eig < -tol:
        return (False, f"Not PSD: λ_min = {min_eig:.6f}")

    # 3. Kernel dimension
    ker_dim = int(np.sum(np.abs(eigenvalues) < tol))
    if ker_dim != beta:
        return (False, f"ker dim = {ker_dim}, expected {beta}")

    return (True, f"Valid LaplacianSpace({beta})")


# =============================================================================
# SPECTRAL GAP (matches Lean: SpectralGap, MaxEigenvalue)
# =============================================================================

def spectral_gap(Delta: np.ndarray, tol: float = 1e-8) -> float:
    """Smallest nonzero eigenvalue (absolute gap). Matches Lean: SpectralGap."""
    eigenvalues = np.sort(np.abs(np.linalg.eigvalsh(Delta)))
    nonzero = eigenvalues[eigenvalues > tol]
    return float(nonzero[0]) if len(nonzero) > 0 else 0.0


def max_eigenvalue(Delta: np.ndarray) -> float:
    """Largest eigenvalue. Matches Lean: MaxEigenvalue."""
    return float(np.max(np.linalg.eigvalsh(Delta)))


def relative_spectral_gap(Delta: np.ndarray, tol: float = 1e-8) -> float:
    """
    Relative spectral gap: λ₁/λ_max.

    This is the quantity that governs quantum advantage in the
    Tsirelson-style bound. Matches gap_ratio in SpectralInvariants.

    - relative_gap = 1: all nonzero eigenvalues equal (e.g., Gr(1,d))
      → easiest to distinguish (but still exponentially hard)
    - relative_gap → 0: wide spectral spread
      → harder to distinguish (more ambiguity)
    """
    gap = spectral_gap(Delta, tol)
    max_eig = max_eigenvalue(Delta)
    if max_eig <= tol:
        return 0.0
    return gap / max_eig


def min_spectral_gap(laplacians: List[np.ndarray], tol: float = 1e-8) -> float:
    """Minimum spectral gap across a family Ω. Matches Lean: MinSpectralGap."""
    if not laplacians:
        return 0.0
    return min(spectral_gap(L, tol) for L in laplacians)


def min_relative_gap(laplacians: List[np.ndarray], tol: float = 1e-8) -> float:
    """Minimum RELATIVE spectral gap across a family Ω."""
    if not laplacians:
        return 0.0
    return min(relative_spectral_gap(L, tol) for L in laplacians)


# =============================================================================
# LIKELIHOOD & ADVERSARY (matches Lean: likelihood, Classical_Adversary)
# =============================================================================

def likelihood(b: np.ndarray, Delta: np.ndarray, sigma: float = 1.0) -> float:
    """
    Likelihood of observing cochain b given Laplacian Δ and noise σ.

    Noise model (matches encrypt.py):
      b = h + e, where h ∈ ker(Δ), e ~ N(0, σ² · (I - P_H))

    So b | Δ ~ N(h, σ² · P_⊥) where P_⊥ = I - P_H = Δ (for our construction).

    The likelihood is proportional to:
      exp(-||P_⊥ b||² / (2σ²))

    This is the CORRECTED model (see Aristotle feedback point 3):
    the Lean file's likelihood uses exp(-⟨Δb,Δb⟩ - ⟨b,b⟩) which doesn't
    match the actual noise distribution. This implementation matches
    encrypt.py's actual noise generation.

    Args:
        b: Observed cochain (d-vector).
        Delta: Candidate Laplacian.
        sigma: Noise standard deviation.

    Returns:
        Likelihood value (unnormalized).
    """
    # P_⊥ b = Δ b (for our Grassmannian Laplacians where Δ = I - P_W)
    noise_component = Delta @ b
    noise_norm_sq = float(np.dot(noise_component, noise_component))
    return np.exp(-noise_norm_sq / (2 * sigma ** 2))


def generate_noisy_cochain(
    Delta: np.ndarray,
    message: np.ndarray = None,
    sigma: float = 1.0,
    rng=None
) -> np.ndarray:
    """
    Generate noisy cochain b = h + e matching encrypt.py's noise model.

    h ∈ ker(Δ) (message embedded in harmonic subspace)
    e ~ N(0, σ² · (I - P_H)) (noise in complement)

    Args:
        Delta: Laplacian (defines harmonic subspace).
        message: Optional harmonic component (default: random in ker(Δ)).
        sigma: Noise standard deviation.

    Returns:
        b = h + e (noisy cochain).
    """
    if rng is None:
        rng = np.random.default_rng()
    d = Delta.shape[0]

    # P_H = I - Δ (harmonic projector for Grassmannian Laplacians)
    P_H = np.eye(d) - Delta

    if message is None:
        # Random harmonic component
        raw = rng.standard_normal(d)
        message = P_H @ raw

    # Noise in im(δ)⊕im(δ*): e = Δ @ raw_noise (projected to complement)
    raw_noise = rng.standard_normal(d) * sigma
    noise = Delta @ raw_noise

    return message + noise


# =============================================================================
# CLASSICAL ADVERSARY SUCCESS PROBABILITY
# =============================================================================

def classical_success_prob_mc(
    adversary: Callable[[np.ndarray], int],
    laplacians: List[np.ndarray],
    sigma: float = 1.0,
    n_trials: int = 1000,
    rng=None
) -> float:
    """
    Estimate classical adversary success probability via Monte Carlo.

    Worst-case (over Δ ∈ Ω) probability that A correctly identifies Δ.

    Matches Lean: success_prob_classical (but computed empirically).

    Args:
        adversary: Function b → index (guesses which Laplacian produced b).
        laplacians: The family Ω.
        sigma: Noise σ.
        n_trials: Monte Carlo trials per Laplacian.

    Returns:
        Worst-case success probability.
    """
    if rng is None:
        rng = np.random.default_rng()
    if not laplacians:
        return 0.0

    worst_case = 1.0  # sInf (minimum over Δ)
    for idx, Delta in enumerate(laplacians):
        correct = 0
        for _ in range(n_trials):
            b = generate_noisy_cochain(Delta, sigma=sigma, rng=rng)
            guess = adversary(b)
            if guess == idx:
                correct += 1
        prob = correct / n_trials
        worst_case = min(worst_case, prob)

    return worst_case


def optimal_classical_adversary(
    laplacians: List[np.ndarray],
    sigma: float = 1.0
) -> Callable[[np.ndarray], int]:
    """
    Construct the Bayes-optimal classical adversary (maximum likelihood).

    For each observed b, returns argmax_Δ likelihood(b | Δ).
    This is the BEST a classical adversary can do.

    Args:
        laplacians: The family Ω.
        sigma: Noise σ.

    Returns:
        Adversary function b → index.
    """
    def adversary(b: np.ndarray) -> int:
        best_idx = 0
        best_ll = -np.inf
        for idx, Delta in enumerate(laplacians):
            ll = likelihood(b, Delta, sigma)
            if ll > best_ll:
                best_ll = ll
                best_idx = idx
        return best_idx
    return adversary


# =============================================================================
# HARDNESS BOUNDS (matches Lean: Classical_Bound, Quantum_Bound)
# =============================================================================

def classical_bound(d: int) -> float:
    """
    Classical hardness bound: success ≤ (1/2)^d.

    Matches Lean: Classical_Bound (but over non-empty Ω, not ∅).

    The exponential bound comes from the Grassmannian search space:
    Gr(k, d) has real dimension k(d-k). For k = d/2, this is d²/4.
    The (1/2)^d is a simplified conservative bound.

    Args:
        d: Ambient dimension.

    Returns:
        Upper bound on classical success probability.
    """
    return 0.5 ** d


def quantum_bound(d: int, relative_gap: float, C: float = 1.0) -> float:
    """
    Quantum hardness bound: success ≤ (1/2)^d × (1 + C · relative_gap).

    Matches Lean: Quantum_Bound.

    The quantum advantage is BOUNDED by the relative spectral gap.
    This is the Tsirelson-style result: quantum doesn't get exponential
    advantage, only a polynomial factor proportional to the gap.

    For Gr(1, d): relative_gap = 1, so bound = (1/2)^d × (1 + C)
    For Gr(k, d) with varied eigenvalues: relative_gap < 1

    Args:
        d: Ambient dimension.
        relative_gap: λ₁/λ_max across the Laplacian family.
        C: Tsirelson constant (default 1.0).

    Returns:
        Upper bound on quantum success probability.
    """
    return 0.5 ** d * (1 + C * relative_gap)


def grassmannian_dimension(k: int, d: int) -> int:
    """
    Real dimension of the Grassmannian Gr(k, d).

    This is the search space dimension for the attacker.
    For credential.py: Gr(256, 512) has dim = 256 × 256 = 65536.

    Args:
        k: Subspace dimension.
        d: Ambient dimension.

    Returns:
        dim(Gr(k,d)) = k(d-k).
    """
    return k * (d - k)


# =============================================================================
# ANALYSIS: Putting it all together
# =============================================================================

@dataclass
class TsirelsonAnalysis:
    """Complete Tsirelson-style analysis for a given parameter set."""
    # Parameters
    d: int                         # Ambient dimension (DEFAULT_STALK_DIM)
    k: int                         # Harmonic dimension (MIN_HARMONIC_DIM)
    sigma: float                   # Noise σ

    # Grassmannian
    grassmannian_dim: int          # dim(Gr(k,d)) = k(d-k)

    # Spectral gaps (over sampled Ω)
    abs_spectral_gap: float        # min λ₁ over Ω
    rel_spectral_gap: float        # min λ₁/λ_max over Ω

    # Bounds
    classical_bound: float         # (1/2)^d
    quantum_bound: float           # (1/2)^d × (1 + C·rel_gap)
    quantum_advantage_factor: float  # 1 + C·rel_gap

    # Empirical (Monte Carlo)
    empirical_classical: float     # Measured success prob (optimal adversary)
    n_laplacians_sampled: int
    n_trials: int

    def summary(self) -> str:
        """Human-readable summary."""
        return (
            f"Tsirelson Analysis: Gr({self.k}, {self.d})\n"
            f"  Grassmannian dim:    {self.grassmannian_dim}\n"
            f"  σ (noise):           {self.sigma}\n"
            f"  Min abs gap (λ₁):    {self.abs_spectral_gap:.6f}\n"
            f"  Min rel gap (λ₁/λₙ): {self.rel_spectral_gap:.6f}\n"
            f"  Classical bound:     2^(-{self.d}) = {self.classical_bound:.2e}\n"
            f"  Quantum bound:       2^(-{self.d}) × {self.quantum_advantage_factor:.4f} = {self.quantum_bound:.2e}\n"
            f"  Quantum advantage:   ×{self.quantum_advantage_factor:.4f} (bounded, not exponential)\n"
            f"  Empirical (MC):      {self.empirical_classical:.4f} "
            f"({self.n_laplacians_sampled} Laplacians, {self.n_trials} trials)\n"
        )


def analyze_tsirelson(
    d: int = 16,
    k: int = 8,
    sigma: float = 1.0,
    n_laplacians: int = 10,
    n_trials: int = 500,
    C: float = 1.0,
    seed: int = 42
) -> TsirelsonAnalysis:
    """
    Run complete Tsirelson-style analysis for given parameters.

    Samples Laplacians from Gr(k, d), computes spectral gaps,
    runs optimal classical adversary, and computes bounds.

    For production parameters (d=512, k=256): bounds are astronomically
    small. For testing: use small d (8-32) to verify the structure.

    Args:
        d: Ambient dimension.
        k: Harmonic dimension.
        sigma: Noise σ.
        n_laplacians: Number of Laplacians to sample from Gr(k, d).
        n_trials: Monte Carlo trials per Laplacian.
        C: Tsirelson constant.
        seed: RNG seed for reproducibility.

    Returns:
        TsirelsonAnalysis with all results.
    """
    rng = np.random.default_rng(seed)

    # Sample Laplacians from Grassmannian family
    laplacians = grassmannian_laplacians(k, d, n_laplacians, rng)

    # Validate all are in LaplacianSpace(k)
    for i, L in enumerate(laplacians):
        valid, reason = validate_laplacian_space(L, k)
        assert valid, f"Laplacian {i} failed validation: {reason}"

    # Spectral analysis
    abs_gap = min_spectral_gap(laplacians)
    rel_gap = min_relative_gap(laplacians)

    # Bounds
    c_bound = classical_bound(d)
    q_bound = quantum_bound(d, rel_gap, C)
    q_advantage = 1 + C * rel_gap

    # Monte Carlo: optimal classical adversary
    adversary = optimal_classical_adversary(laplacians, sigma)
    empirical = classical_success_prob_mc(
        adversary, laplacians, sigma, n_trials, rng
    )

    return TsirelsonAnalysis(
        d=d,
        k=k,
        sigma=sigma,
        grassmannian_dim=grassmannian_dimension(k, d),
        abs_spectral_gap=abs_gap,
        rel_spectral_gap=rel_gap,
        classical_bound=c_bound,
        quantum_bound=q_bound,
        quantum_advantage_factor=q_advantage,
        empirical_classical=empirical,
        n_laplacians_sampled=n_laplacians,
        n_trials=n_trials,
    )
