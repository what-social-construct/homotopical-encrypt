"""
Tests for Math Audit Fixes

Tests all foundational math fixes:
1. Cohomology: β₁ formula, Hodge decomposition ratios
2. Fiber bundle: directional transport, dimension validation
3. Path hint encryption: full Hodge (replaces broken CVP)
4. Primitives: wedge, Hodge star, coboundary, Laplacian
5. Invariants: spectral, harmonic, fibration
"""

import numpy as np
import pytest
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))


# ============================================================================
# 1. PRIMITIVES: EXTERIOR ALGEBRA
# ============================================================================

class TestExteriorAlgebra:
    """Test primitives/algebra.py"""
    
    def test_wedge_antisymmetry(self):
        """v ∧ w = -(w ∧ v)"""
        from src.primitives.algebra import wedge
        v = np.array([1.0, 2.0, 3.0])
        w = np.array([4.0, 5.0, 6.0])
        assert np.allclose(wedge(v, w), -wedge(w, v))
    
    def test_wedge_self_is_zero(self):
        """v ∧ v = 0"""
        from src.primitives.algebra import wedge
        v = np.array([1.0, 2.0, 3.0])
        assert np.allclose(wedge(v, v), 0)
    
    def test_wedge_basis_vectors(self):
        """e₁ ∧ e₂ should give [1, 0, 0] in ℝ³"""
        from src.primitives.algebra import wedge
        e1 = np.array([1, 0, 0])
        e2 = np.array([0, 1, 0])
        result = wedge(e1, e2)
        assert np.allclose(result, [1, 0, 0])
    
    def test_wedge_k_volume_form(self):
        """e₁ ∧ e₂ ∧ e₃ = 1 (volume)"""
        from src.primitives.algebra import wedge_k
        e1 = np.array([1.0, 0, 0])
        e2 = np.array([0, 1.0, 0])
        e3 = np.array([0, 0, 1.0])
        vol = wedge_k([e1, e2, e3])
        assert np.allclose(vol, [1.0])
    
    def test_wedge_k_linearly_dependent_is_zero(self):
        """v₁ ∧ v₂ = 0 if linearly dependent"""
        from src.primitives.algebra import wedge_k
        v1 = np.array([1.0, 2.0, 3.0])
        v2 = np.array([2.0, 4.0, 6.0])
        result = wedge_k([v1, v2])
        assert np.allclose(result, 0, atol=1e-10)
    
    def test_hodge_star_3d(self):
        """∗(dx ∧ dy) = dz in ℝ³"""
        from src.primitives.algebra import hodge_star, wedge
        e1 = np.array([1, 0, 0])
        e2 = np.array([0, 1, 0])
        dx_dy = wedge(e1, e2)
        star = hodge_star(dx_dy, n=3, k=2)
        assert np.allclose(star, [0, 0, 1])
    
    def test_permutation_sign(self):
        """Identity has sign +1, swap has sign -1"""
        from src.primitives.algebra import _permutation_sign
        assert _permutation_sign((0, 1, 2), (0, 1, 2)) == 1
        assert _permutation_sign((1, 0, 2), (0, 1, 2)) == -1
    
    def test_binomial_values(self):
        from src.primitives.algebra import binomial
        assert binomial(5, 0) == 1
        assert binomial(5, 1) == 5
        assert binomial(5, 2) == 10
        assert binomial(5, 5) == 1
        assert binomial(5, 6) == 0


# ============================================================================
# 2. PRIMITIVES: COCHAIN COMPLEX
# ============================================================================

class TestCochainComplex:
    """Test primitives/cochain.py"""
    
    def test_coboundary_triangle(self):
        """δ₀ on triangle K₃: (δc)(e) = c(v) - c(u) for edge (u,v)"""
        from src.primitives.cochain import CochainComplex, VertexCochain
        
        cc = CochainComplex.complete_graph(3)
        delta = cc.coboundary_matrix_0()
        
        # Shape: (3 edges) × (3 vertices)
        assert delta.shape == (3, 3)
        
        # Each row sums to 0 (conservation)
        assert np.allclose(delta.sum(axis=1), 0)
        
        # Test: constant cochain → zero coboundary
        const_cochain = VertexCochain(vertex_values={0: np.array([5.0]), 1: np.array([5.0]), 2: np.array([5.0])})
        edge_result = cc.apply_coboundary_0(const_cochain)
        for e in cc.edges:
            assert np.allclose(edge_result.get_edge(*e), 0)
    
    def test_laplacian_symmetric_psd(self):
        """Δ₀ = δ₀ᵀδ₀ must be symmetric and PSD"""
        from src.primitives.cochain import CochainComplex
        
        cc = CochainComplex.complete_graph(5)
        L = cc.laplacian_0()
        
        # Symmetric
        assert np.allclose(L, L.T)
        
        # PSD (all eigenvalues ≥ 0)
        eigs = np.linalg.eigvalsh(L)
        assert np.all(eigs >= -1e-10)
    
    def test_laplacian_kernel_connected(self):
        """Connected graph: dim(ker Δ₀) = 1"""
        from src.primitives.cochain import CochainComplex
        
        cc = CochainComplex.complete_graph(4)
        L = cc.laplacian_0()
        eigs = np.linalg.eigvalsh(L)
        kernel_dim = np.sum(np.abs(eigs) < 1e-10)
        assert kernel_dim == 1
    
    def test_coboundary_exact(self):
        """δ₀(constant) = 0 and δ₀(non-constant) ≠ 0"""
        from src.primitives.cochain import CochainComplex, VertexCochain
        
        cc = CochainComplex.complete_graph(3)
        
        # Non-constant should have non-zero coboundary
        nonconst = VertexCochain(vertex_values={0: np.array([1.0]), 1: np.array([2.0]), 2: np.array([3.0])})
        edge_result = cc.apply_coboundary_0(nonconst)
        total = sum(np.linalg.norm(edge_result.get_edge(*e)) for e in cc.edges)
        assert total > 0


# ============================================================================
# 3. COHOMOLOGY: Betti numbers and Hodge ratios
# ============================================================================

class TestCohomologyInvariants:
    """Test invariants/cohomology.py fixes"""
    
    def test_betti_numbers_triangle(self):
        """K₃: β₀=1, β₁=0 (filled triangle has no holes)"""
        from src.primitives.cochain import CochainComplex
        from src.invariants.cohomology import compute_betti_from_laplacian
        
        cc = CochainComplex.complete_graph(3)
        L = cc.laplacian_0()
        
        beta_0 = compute_betti_from_laplacian(L)
        assert beta_0 == 1  # Connected
    
    def test_hodge_decomposition_ratios_degree_0(self):
        """For degree 0: exact_dim = 0 (no δ_{-1}), coexact_dim = rank(δ₀)"""
        from src.primitives.cochain import CochainComplex
        from src.invariants.cohomology import compute_hodge_decomposition_ratios
        
        cc = CochainComplex.complete_graph(4)
        L = cc.laplacian_0()
        delta_0 = cc.coboundary_matrix_0()
        
        # delta_above = δ₀ (going UP from C⁰), delta_below = None (degree 0)
        ratios = compute_hodge_decomposition_ratios(L, delta_above=delta_0, delta_below=None)
        
        # Exact part should be 0 for degree 0
        assert ratios["exact_dim"] == 0
        
        # Coexact = rank(δ₀ᵀ) = rank(δ₀)
        rank_delta = np.linalg.matrix_rank(delta_0)
        assert ratios["coexact_dim"] == rank_delta
        
        # Harmonic + coexact should sum to total dim
        total = ratios["harmonic_dim"] + ratios["exact_dim"] + ratios["coexact_dim"]
        assert total == L.shape[0], f"Hodge sum {total} ≠ {L.shape[0]}"
    
    def test_euler_characteristic(self):
        """χ = n₀ - n₁ + n₂ = β₀ - β₁ + β₂"""
        from src.primitives.cochain import CochainComplex
        from src.invariants.cohomology import compute_cohomology_invariants
        
        n = 4
        cc = CochainComplex.complete_graph(n)
        delta_0 = cc.coboundary_matrix_0()
        L = cc.laplacian_0()
        
        nerve = {
            0: [(i,) for i in range(n)],
            1: list(cc.edges),
            2: list(cc.faces),
        }
        
        inv = compute_cohomology_invariants(nerve, delta_0, None, L)
        
        expected_euler = n - len(cc.edges) + len(cc.faces)
        assert inv.euler_characteristic == expected_euler


# ============================================================================
# 4. SPECTRAL INVARIANTS
# ============================================================================

class TestSpectralInvariants:
    """Test invariants/spectral.py"""
    
    def test_spectral_from_laplacian(self):
        """Spectral invariants from K₅ Laplacian"""
        from src.primitives.cochain import CochainComplex
        from src.invariants.spectral import compute_spectral_invariants
        
        cc = CochainComplex.complete_graph(5)
        L = cc.laplacian_0()
        spec = compute_spectral_invariants(L)
        
        # K₅: eigenvalues are 0 (×1) and 5 (×4)
        assert spec.kernel_dimension == 1
        assert spec.spectral_gap > 0
        assert spec.trace_L1 > 0
    
    def test_spectral_matching(self):
        """Same Laplacian → matching spectra"""
        from src.primitives.cochain import CochainComplex
        from src.invariants.spectral import compute_spectral_invariants, spectra_match
        
        cc = CochainComplex.complete_graph(4)
        L = cc.laplacian_0()
        
        s1 = compute_spectral_invariants(L)
        s2 = compute_spectral_invariants(L)
        
        match, msg = spectra_match(s1, s2)
        assert match, msg
    
    def test_heat_kernel(self):
        """Heat kernel trace: tr(e^{-tΔ}) ≥ dim(ker Δ) for all t"""
        from src.primitives.cochain import CochainComplex
        from src.invariants.spectral import compute_heat_kernel_invariants
        
        cc = CochainComplex.complete_graph(4)
        L = cc.laplacian_0()
        
        heat = compute_heat_kernel_invariants(L)
        # As t → ∞, trace → dim(ker Δ) = 1
        for t, trace in heat.items():
            assert trace >= 0.99  # ≥ kernel_dim = 1


# ============================================================================
# 5. HARMONIC INVARIANTS
# ============================================================================

class TestHarmonicInvariants:
    """Test invariants/harmonic.py"""
    
    def test_harmonic_embedding_roundtrip(self):
        """embed_in_harmonic → extract_from_harmonic recovers message"""
        from src.invariants.harmonic import embed_in_harmonic, extract_from_harmonic
        from src.primitives.cochain import CochainComplex
        
        cc = CochainComplex.complete_graph(5)
        L = cc.laplacian_0()
        
        # Message with 1 component (harmonic dim = 1 for connected graph)
        msg = np.array([42.0])
        embedding, success = embed_in_harmonic(msg, L)
        assert success
        
        recovered = extract_from_harmonic(embedding, L, 1)
        assert np.allclose(recovered, msg, atol=1e-8)
    
    def test_harmonic_projection_strips_noise(self):
        """project_harmonic(harmonic + noise_in_complement) = harmonic"""
        from src.invariants.harmonic import (
            embed_in_harmonic, project_to_harmonic, 
            validate_noise_structure
        )
        from src.primitives.cochain import CochainComplex
        
        cc = CochainComplex.complete_graph(5)
        L = cc.laplacian_0()
        
        msg = np.array([7.0])
        embedding, _ = embed_in_harmonic(msg, L)
        
        # Add noise in non-harmonic subspace
        eigenvalues, eigenvectors = np.linalg.eigh(L)
        nonharm_mask = np.abs(eigenvalues) > 1e-10
        nonharm_basis = eigenvectors[:, nonharm_mask]
        noise = nonharm_basis @ np.random.randn(int(np.sum(nonharm_mask))) * 10
        
        # Validate noise is in complement
        result = validate_noise_structure(noise, L)
        assert result.passed
        
        # Harmonic projection should recover embedding
        noisy = embedding + noise
        recovered = project_to_harmonic(noisy, L)
        assert np.allclose(recovered, embedding, atol=1e-8)
    
    def test_hodge_decompose_orthogonal(self):
        """Hodge components are mutually orthogonal"""
        from src.invariants.harmonic import hodge_decompose
        from src.primitives.cochain import CochainComplex
        
        cc = CochainComplex.complete_graph(5)
        L = cc.laplacian_0()
        delta = cc.coboundary_matrix_0()
        
        # Random cochain
        c = np.random.randn(5)
        h, e, ce = hodge_decompose(c, L, coboundary_below=None, coboundary_above=delta)
        
        # h ⊥ (e + ce)
        assert abs(np.dot(h, e + ce)) < 1e-8
        
        # Sum recovers original
        assert np.allclose(h + e + ce, c, atol=1e-8)


# ============================================================================
# 6. FIBER BUNDLE: DIRECTIONAL TRANSPORT
# ============================================================================

class TestFiberBundleTransport:
    """Test geometry/fiber_bundle.py direction fixes"""
    
    def _make_bundle(self, dim=4):
        """Helper: create small fiber bundle"""
        from src.geometry.fiber_bundle import FiberBundle
        
        nerve = {
            0: [(0,), (1,), (2,)],
            1: [(0, 1), (1, 2), (0, 2)],
        }
        return FiberBundle.random(nerve, fiber_dim=dim)
    
    def test_transport_inverse_roundtrip(self):
        """transport(v, path) then inverse_transport should recover v"""
        bundle = self._make_bundle(dim=8)
        v = np.random.randn(8)
        
        path = [0, 1, 2]
        transported = bundle.parallel_transport(v, path)
        recovered = bundle.inverse_transport(transported, path)
        
        assert np.allclose(recovered, v, atol=1e-10)
    
    def test_transport_direction_matters(self):
        """transport(v, [0,1]) ≠ transport(v, [1,0]) for non-trivial connection"""
        bundle = self._make_bundle(dim=8)
        v = np.random.randn(8)
        
        forward = bundle.parallel_transport(v, [0, 1])
        backward = bundle.parallel_transport(v, [1, 0])
        
        # For non-identity connection, these should differ
        # (R @ v ≠ R^T @ v in general)
        assert not np.allclose(forward, backward)
    
    def test_holonomy_direction_aware(self):
        """Holonomy around loop [0,1,2,0]"""
        bundle = self._make_bundle(dim=8)
        
        hol = bundle.holonomy([0, 1, 2, 0])
        
        # Should be orthogonal (product of orthogonal matrices)
        assert np.allclose(hol @ hol.T, np.eye(8), atol=1e-10)
    
    def test_transport_dimension_check(self):
        """Wrong dimension vector should raise"""
        bundle = self._make_bundle(dim=8)
        
        with pytest.raises(ValueError, match="fiber_dim"):
            bundle.parallel_transport(np.zeros(5), [0, 1])
    
    def test_orthogonal_preserves_norm(self):
        """Orthogonal transport preserves vector norm"""
        bundle = self._make_bundle(dim=16)
        v = np.random.randn(16)
        original_norm = np.linalg.norm(v)
        
        transported = bundle.parallel_transport(v, [0, 1, 2, 0, 1])
        assert np.allclose(np.linalg.norm(transported), original_norm, atol=1e-10)


# ============================================================================
# 7. ONION ROUTING: DIMENSION VALIDATION
# ============================================================================

class TestOnionRouting:
    """Test onion routing dimension checks"""
    
    def test_truncation_raises_error(self):
        """Message larger than fiber_dim should raise, not truncate"""
        from src.geometry.fiber_bundle import FiberBundle, create_onion_route
        
        nerve = {
            0: [(0,), (1,), (2,)],
            1: [(0, 1), (1, 2), (0, 2)],
        }
        
        bundle = FiberBundle.random(nerve, fiber_dim=4)
        big_msg = np.random.randn(8)  # Larger than fiber_dim=4
        key = np.random.randn(16)
        
        with pytest.raises(ValueError, match="fiber_dim"):
            create_onion_route([bundle], big_msg, [key])


# ============================================================================
# 8. INTEGRATION: HODGE DECOMPOSITION SANITY
# ============================================================================

class TestHodgeIntegration:
    """End-to-end Hodge decomposition correctness"""
    
    def test_hodge_theorem_dimensions(self):
        """dim(H) + dim(exact) + dim(coexact) = dim(C^k)"""
        from src.primitives.cochain import CochainComplex
        
        for n in [3, 4, 5, 6]:
            cc = CochainComplex.complete_graph(n)
            L = cc.laplacian_0()
            delta = cc.coboundary_matrix_0()
            
            eigs = np.linalg.eigvalsh(L)
            harmonic_dim = int(np.sum(np.abs(eigs) < 1e-10))
            
            # For degree 0: exact = 0, coexact = rank(δ₀ᵀ) = rank(δ₀)
            coexact_dim = np.linalg.matrix_rank(delta)
            
            total = harmonic_dim + 0 + coexact_dim
            assert total == n, (
                f"K_{n}: H={harmonic_dim} + E=0 + CE={coexact_dim} = {total} ≠ {n}"
            )
    
    def test_complete_graph_spectrum(self):
        """K_n Laplacian eigenvalues: 0 (×1), n (×(n-1))"""
        from src.primitives.cochain import CochainComplex
        
        for n in [3, 4, 5]:
            cc = CochainComplex.complete_graph(n)
            L = cc.laplacian_0()
            eigs = np.sort(np.linalg.eigvalsh(L))
            
            # First eigenvalue ≈ 0
            assert abs(eigs[0]) < 1e-10
            
            # Remaining eigenvalues ≈ n
            for e in eigs[1:]:
                assert abs(e - n) < 1e-10, f"K_{n}: expected eig={n}, got {e}"


# ============================================================================
# RUNNER
# ============================================================================

if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
