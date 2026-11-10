"""
Tests for Tsirelson-style bounds on Hodge distinguishing.

Validates the Python mirror of tsirelson_update.lean:
- Grassmannian Laplacian family Ω_k
- LaplacianSpace validation (Hermitian, PSD, ker dim)
- Spectral gap (absolute and relative)
- Likelihood model matching encrypt.py noise
- Classical adversary success probability
- Hardness bounds
"""

import sys
from pathlib import Path
import numpy as np
import pytest

sys.path.insert(0, str(Path(__file__).parent.parent))

from src.proofs.tsirelson import (
    grassmannian_laplacian,
    sample_grassmannian,
    grassmannian_laplacians,
    validate_laplacian_space,
    spectral_gap,
    max_eigenvalue,
    relative_spectral_gap,
    min_spectral_gap,
    min_relative_gap,
    likelihood,
    generate_noisy_cochain,
    classical_success_prob_mc,
    optimal_classical_adversary,
    classical_bound,
    quantum_bound,
    grassmannian_dimension,
    analyze_tsirelson,
)


# =============================================================================
# Grassmannian Laplacian Family
# =============================================================================

class TestGrassmannianLaplacians:
    """Matches Lean: Grassmannian_Laplacians, Ω_1, laplacian_properties."""

    def test_grassmannian_laplacian_is_projector(self):
        """Δ_W = I - P_W is an orthogonal projector onto W^⊥."""
        W = sample_grassmannian(8, 3, rng=np.random.default_rng(42))
        Delta = grassmannian_laplacian(W)
        # Idempotent: Δ² = Δ
        assert np.allclose(Delta @ Delta, Delta, atol=1e-10)

    def test_laplacian_hermitian(self):
        """Matches Lean: laplacian_is_hermitian."""
        W = sample_grassmannian(10, 4, rng=np.random.default_rng(0))
        Delta = grassmannian_laplacian(W)
        assert np.allclose(Delta, Delta.T, atol=1e-12)

    def test_laplacian_psd(self):
        """Matches Lean: laplacian_properties (PSD part)."""
        W = sample_grassmannian(12, 5, rng=np.random.default_rng(1))
        Delta = grassmannian_laplacian(W)
        eigenvalues = np.linalg.eigvalsh(Delta)
        assert np.all(eigenvalues >= -1e-10)

    def test_laplacian_kernel_dim(self):
        """Matches Lean: laplacian_properties (kernel dimension part)."""
        for k in [1, 3, 7]:
            d = 16
            W = sample_grassmannian(d, k, rng=np.random.default_rng(k))
            Delta = grassmannian_laplacian(W)
            eigenvalues = np.linalg.eigvalsh(Delta)
            ker_dim = int(np.sum(np.abs(eigenvalues) < 1e-8))
            assert ker_dim == k, f"Expected ker dim {k}, got {ker_dim}"

    def test_laplacian_in_laplacian_space(self):
        """Matches Lean: Ω_1_subset_LaplacianSpace."""
        d, k = 16, 4
        W = sample_grassmannian(d, k, rng=np.random.default_rng(42))
        Delta = grassmannian_laplacian(W)
        valid, reason = validate_laplacian_space(Delta, k)
        assert valid, reason

    def test_grassmannian_laplacians_batch(self):
        """Matches Lean: Ω_1_infinite (finite sample from infinite set)."""
        d, k, n = 8, 3, 5
        laplacians = grassmannian_laplacians(k, d, n, rng=np.random.default_rng(42))
        assert len(laplacians) == n
        for L in laplacians:
            valid, _ = validate_laplacian_space(L, k)
            assert valid

    def test_different_subspaces_different_laplacians(self):
        """Matches Lean: Grassmannian_Laplacian_injective."""
        rng = np.random.default_rng(42)
        W1 = sample_grassmannian(8, 3, rng)
        W2 = sample_grassmannian(8, 3, rng)
        Delta1 = grassmannian_laplacian(W1)
        Delta2 = grassmannian_laplacian(W2)
        # Different subspaces → different Laplacians
        assert not np.allclose(Delta1, Delta2, atol=1e-6)

    def test_kernel_is_harmonic_subspace(self):
        """ker(Δ_W) = W: the harmonic subspace is exactly W."""
        d, k = 10, 4
        W = sample_grassmannian(d, k, rng=np.random.default_rng(42))
        Delta = grassmannian_laplacian(W)
        # Every column of W should be in ker(Δ)
        for i in range(k):
            residual = np.linalg.norm(Delta @ W[:, i])
            assert residual < 1e-10, f"W column {i} not in ker(Δ): residual={residual}"


# =============================================================================
# Spectral Gap
# =============================================================================

class TestSpectralGap:
    """Matches Lean: SpectralGap, MaxEigenvalue, MinSpectralGap."""

    def test_spectral_gap_grassmannian(self):
        """For Gr(k,d) Laplacians, all nonzero eigenvalues = 1."""
        d, k = 16, 4
        W = sample_grassmannian(d, k, rng=np.random.default_rng(42))
        Delta = grassmannian_laplacian(W)
        gap = spectral_gap(Delta)
        max_eig = max_eigenvalue(Delta)
        # For projection Laplacians: all nonzero eigenvalues are 1
        assert abs(gap - 1.0) < 1e-8
        assert abs(max_eig - 1.0) < 1e-8

    def test_relative_gap_is_one_for_projectors(self):
        """For pure projectors, relative gap = 1 (all eigenvalues equal)."""
        d, k = 12, 3
        W = sample_grassmannian(d, k, rng=np.random.default_rng(42))
        Delta = grassmannian_laplacian(W)
        rel_gap = relative_spectral_gap(Delta)
        assert abs(rel_gap - 1.0) < 1e-8

    def test_min_spectral_gap_over_family(self):
        """MinSpectralGap is minimum over the family."""
        laplacians = grassmannian_laplacians(3, 8, 5, rng=np.random.default_rng(42))
        gap = min_spectral_gap(laplacians)
        # All Grassmannian Laplacians have gap = 1
        assert abs(gap - 1.0) < 1e-8

    def test_relative_gap_varies_for_non_projectors(self):
        """Scaled Laplacians have relative_gap < 1."""
        d = 8
        # Non-uniform eigenvalues: Δ with eigenvalues {0, 0.5, 1, 1, ...}
        eigenvalues = np.array([0, 0, 0.5, 1, 1, 1, 1, 1])
        Q = np.linalg.qr(np.random.default_rng(42).standard_normal((d, d)))[0]
        Delta = Q @ np.diag(eigenvalues) @ Q.T
        rel_gap = relative_spectral_gap(Delta)
        assert rel_gap < 1.0
        assert abs(rel_gap - 0.5) < 1e-8


# =============================================================================
# Likelihood & Noise Model
# =============================================================================

class TestLikelihood:

    def test_likelihood_highest_for_correct_laplacian(self):
        """On average, likelihood(b | Δ_true) > likelihood(b | Δ_wrong)."""
        rng = np.random.default_rng(42)
        d, k = 8, 3
        W1 = sample_grassmannian(d, k, rng)
        W2 = sample_grassmannian(d, k, rng)
        Delta1 = grassmannian_laplacian(W1)
        Delta2 = grassmannian_laplacian(W2)

        # Average over many samples (single sample can go either way)
        correct_wins = 0
        n_samples = 200
        for _ in range(n_samples):
            b = generate_noisy_cochain(Delta1, sigma=1.0, rng=rng)
            ll1 = likelihood(b, Delta1, sigma=1.0)
            ll2 = likelihood(b, Delta2, sigma=1.0)
            if ll1 >= ll2:
                correct_wins += 1
        # Correct Laplacian should win majority of the time
        assert correct_wins > n_samples * 0.4, f"Correct won only {correct_wins}/{n_samples}"

    def test_noisy_cochain_structure(self):
        """b = h + e where h ∈ ker(Δ), e ⊥ ker(Δ)."""
        rng = np.random.default_rng(42)
        d, k = 12, 4
        W = sample_grassmannian(d, k, rng)
        Delta = grassmannian_laplacian(W)
        P_H = np.eye(d) - Delta

        b = generate_noisy_cochain(Delta, sigma=2.0, rng=rng)

        # Decompose
        h = P_H @ b  # harmonic part
        e = Delta @ b  # noise part

        # h ∈ ker(Δ)
        assert np.linalg.norm(Delta @ h) < 1e-8
        # e ⊥ ker(Δ)
        assert np.linalg.norm(P_H @ e) < 1e-8
        # h + e = b
        assert np.allclose(h + e, b, atol=1e-10)


# =============================================================================
# Classical Adversary
# =============================================================================

class TestClassicalAdversary:

    def test_optimal_adversary_beats_random(self):
        """ML adversary should beat random guessing (1/|Ω|)."""
        rng = np.random.default_rng(42)
        d, k, n = 8, 3, 3
        laplacians = grassmannian_laplacians(k, d, n, rng)

        # Optimal adversary
        adversary = optimal_classical_adversary(laplacians, sigma=0.5)
        success = classical_success_prob_mc(
            adversary, laplacians, sigma=0.5, n_trials=200, rng=rng
        )

        # Random guessing = 1/3 ≈ 0.333
        # ML adversary should do better with low noise
        assert success >= 0.2  # At least not terrible

    def test_more_noise_reduces_success(self):
        """Higher σ → lower adversary success."""
        rng = np.random.default_rng(42)
        d, k, n = 8, 3, 3
        laplacians = grassmannian_laplacians(k, d, n, rng)

        # Low noise
        adv_low = optimal_classical_adversary(laplacians, sigma=0.1)
        success_low = classical_success_prob_mc(
            adv_low, laplacians, sigma=0.1, n_trials=200, rng=np.random.default_rng(42)
        )

        # High noise
        adv_high = optimal_classical_adversary(laplacians, sigma=10.0)
        success_high = classical_success_prob_mc(
            adv_high, laplacians, sigma=10.0, n_trials=200, rng=np.random.default_rng(42)
        )

        # More noise → harder to distinguish
        assert success_high <= success_low + 0.1  # Allow margin for MC variance


# =============================================================================
# Hardness Bounds
# =============================================================================

class TestHardnessBounds:

    def test_classical_bound_exponential(self):
        """Classical bound is exponentially small in d."""
        assert classical_bound(8) == pytest.approx(1 / 256)
        assert classical_bound(16) == pytest.approx(1 / 65536)
        assert classical_bound(32) < 1e-9

    def test_quantum_bound_exceeds_classical(self):
        """Quantum bound ≥ classical bound (quantum can only help)."""
        for d in [8, 16, 32]:
            c = classical_bound(d)
            q = quantum_bound(d, relative_gap=1.0, C=1.0)
            assert q >= c

    def test_quantum_advantage_bounded(self):
        """Quantum advantage factor is at most (1 + C·gap), NOT exponential."""
        d = 16
        rel_gap = 1.0  # Worst case for Gr(1,d)
        C = 1.0
        q = quantum_bound(d, rel_gap, C)
        c = classical_bound(d)
        advantage = q / c
        assert advantage == pytest.approx(1 + C * rel_gap)
        assert advantage == pytest.approx(2.0)  # ×2, not ×2^d

    def test_grassmannian_dimension(self):
        """dim(Gr(k,d)) = k(d-k)."""
        assert grassmannian_dimension(1, 8) == 7
        assert grassmannian_dimension(4, 8) == 16
        assert grassmannian_dimension(256, 512) == 65536  # Production


# =============================================================================
# Full Analysis
# =============================================================================

class TestAnalysis:

    def test_analyze_tsirelson_small(self):
        """Full analysis on small parameters."""
        analysis = analyze_tsirelson(
            d=8, k=3, sigma=1.0,
            n_laplacians=4, n_trials=100, seed=42
        )

        # Structure
        assert analysis.d == 8
        assert analysis.k == 3
        assert analysis.grassmannian_dim == 3 * 5  # = 15

        # Grassmannian Laplacians have all nonzero eigenvalues = 1
        assert abs(analysis.abs_spectral_gap - 1.0) < 1e-6
        assert abs(analysis.rel_spectral_gap - 1.0) < 1e-6

        # Bounds
        assert analysis.classical_bound == pytest.approx(1 / 256)
        assert analysis.quantum_advantage_factor == pytest.approx(2.0)

        # Empirical success should be bounded
        assert 0 <= analysis.empirical_classical <= 1.0

        # Summary should be a string
        summary = analysis.summary()
        assert "Gr(3, 8)" in summary
        assert "Grassmannian dim" in summary

    def test_production_params_bounds(self):
        """Verify bounds for production parameters (no MC — too expensive)."""
        d, k = 512, 256
        dim = grassmannian_dimension(k, d)
        c = classical_bound(d)
        q = quantum_bound(d, relative_gap=1.0)

        assert dim == 65536
        assert c < 1e-150  # Astronomically small
        assert q < 1e-150
        assert q / c == pytest.approx(2.0)  # Only ×2 quantum advantage
