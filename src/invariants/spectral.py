"""
Spectral Invariants

Invariants derived from the spectrum of the sheaf Laplacian.
Based on Hansen & Ghrist's spectral theory of cellular sheaves.

References:
- Hansen & Ghrist (2019): Spectral Theory of Cellular Sheaves (arXiv:1808.01513)
- Barbero et al. (2022): Sheaf Neural Networks with Connection Laplacians
- Bodnar et al. (2022): Neural Sheaf Diffusion (NeurIPS)
- Ayzenberg et al. (2025): Čech cohomology accessible treatment
"""

from dataclasses import dataclass
from typing import Dict, List, Tuple, Optional
import numpy as np


# ============================================================================
# SPECTRAL INVARIANT DATA STRUCTURES
# ============================================================================

@dataclass
class SpectralInvariants:
    """
    Complete spectral invariant set from Laplacian.
    
    These characterize the ANALYTIC structure of the fibration.
    """
    # Eigenvalue spectrum
    eigenvalues: np.ndarray          # Sorted eigenvalues λ₀ ≤ λ₁ ≤ ... ≤ λₙ
    spectral_gap: float              # λ₁ (first nonzero eigenvalue)
    spectral_radius: float           # λₙ (largest eigenvalue)
    
    # Derived invariants
    kernel_dimension: int            # dim(ker Δ) = number of zero eigenvalues
    condition_number: float          # λₙ / λ₁ (ill-conditioning measure)
    
    # Trace invariants (moments)
    trace_L1: float                  # tr(Δ)
    trace_L2: float                  # tr(Δ²)
    trace_L3: float                  # tr(Δ³)
    
    # Ratios (scale-invariant)
    gap_ratio: float                 # λ₁ / λₙ
    second_gap_ratio: float          # λ₂ / λ₁
    
    def to_dict(self) -> Dict:
        return {
            "eigenvalues": self.eigenvalues.tolist(),
            "spectral_gap": self.spectral_gap,
            "spectral_radius": self.spectral_radius,
            "kernel_dimension": self.kernel_dimension,
            "condition_number": self.condition_number,
            "trace_L1": self.trace_L1,
            "trace_L2": self.trace_L2,
            "trace_L3": self.trace_L3,
            "gap_ratio": self.gap_ratio,
            "second_gap_ratio": self.second_gap_ratio
        }
    
    def fingerprint(self) -> bytes:
        """Generate deterministic fingerprint from invariants."""
        import hashlib
        # Round eigenvalues to canonical precision
        rounded_eigs = np.round(self.eigenvalues, decimals=10)
        data = rounded_eigs.tobytes()
        data += np.array([self.trace_L1, self.trace_L2, self.trace_L3]).tobytes()
        return hashlib.sha256(data).digest()


# ============================================================================
# COMPUTATION FUNCTIONS
# ============================================================================

def compute_spectral_invariants(
    laplacian: np.ndarray,
    tol: float = 1e-10
) -> SpectralInvariants:
    """
    Compute complete spectral invariant set from Laplacian.
    
    Args:
        laplacian: The sheaf Laplacian matrix Δ
        tol: Tolerance for zero eigenvalues
        
    Returns:
        SpectralInvariants dataclass
    """
    # Eigendecomposition
    eigenvalues = np.sort(np.linalg.eigvalsh(laplacian))
    
    # Clean up numerical noise
    eigenvalues = np.where(np.abs(eigenvalues) < tol, 0.0, eigenvalues)
    
    # Kernel dimension
    kernel_dim = int(np.sum(np.abs(eigenvalues) < tol))
    
    # Nonzero eigenvalues
    nonzero = eigenvalues[eigenvalues > tol]
    
    if len(nonzero) == 0:
        # Degenerate case: all zero eigenvalues
        return SpectralInvariants(
            eigenvalues=eigenvalues,
            spectral_gap=0.0,
            spectral_radius=0.0,
            kernel_dimension=kernel_dim,
            condition_number=float('inf'),
            trace_L1=0.0,
            trace_L2=0.0,
            trace_L3=0.0,
            gap_ratio=0.0,
            second_gap_ratio=0.0
        )
    
    # Gap and radius
    spectral_gap = float(nonzero[0])
    spectral_radius = float(eigenvalues[-1])
    
    # Condition number
    condition = spectral_radius / spectral_gap if spectral_gap > 0 else float('inf')
    
    # Trace invariants
    L2 = laplacian @ laplacian
    L3 = L2 @ laplacian
    trace_L1 = float(np.trace(laplacian))
    trace_L2 = float(np.trace(L2))
    trace_L3 = float(np.trace(L3))
    
    # Ratios
    gap_ratio = spectral_gap / spectral_radius if spectral_radius > 0 else 0.0
    second_gap_ratio = float(nonzero[1] / nonzero[0]) if len(nonzero) > 1 else 1.0
    
    return SpectralInvariants(
        eigenvalues=eigenvalues,
        spectral_gap=spectral_gap,
        spectral_radius=spectral_radius,
        kernel_dimension=kernel_dim,
        condition_number=condition,
        trace_L1=trace_L1,
        trace_L2=trace_L2,
        trace_L3=trace_L3,
        gap_ratio=gap_ratio,
        second_gap_ratio=second_gap_ratio
    )


def compute_heat_kernel_invariants(
    laplacian: np.ndarray,
    times: List[float] = [0.1, 0.5, 1.0, 2.0, 5.0]
) -> Dict[float, float]:
    """
    Compute heat kernel trace invariants: tr(e^{-tΔ}) for various t.
    
    These encode MORE than just eigenvalues - they capture
    the full spectral measure with weighting.
    
    Heat equation: ∂u/∂t = -Δu
    Solution: u(t) = e^{-tΔ}u(0)
    Trace: tr(e^{-tΔ}) = Σᵢ e^{-tλᵢ}
    """
    eigenvalues = np.linalg.eigvalsh(laplacian)
    
    heat_traces = {}
    for t in times:
        # tr(e^{-tΔ}) = sum of e^{-t λᵢ}
        trace = float(np.sum(np.exp(-t * eigenvalues)))
        heat_traces[t] = trace
    
    return heat_traces


def compute_zeta_invariants(
    laplacian: np.ndarray,
    s_values: List[float] = [1.0, 2.0, 3.0],
    tol: float = 1e-10
) -> Dict[float, float]:
    """
    Compute spectral zeta function: ζ_Δ(s) = Σᵢ λᵢ^{-s} for nonzero eigenvalues.
    
    Zeta function regularization of determinant:
    det(Δ) = exp(-ζ'_Δ(0))
    """
    eigenvalues = np.linalg.eigvalsh(laplacian)
    nonzero = eigenvalues[eigenvalues > tol]
    
    if len(nonzero) == 0:
        return {s: float('inf') for s in s_values}
    
    zeta_values = {}
    for s in s_values:
        # ζ(s) = Σᵢ λᵢ^{-s}
        zeta = float(np.sum(nonzero ** (-s)))
        zeta_values[s] = zeta
    
    return zeta_values


# ============================================================================
# SPECTRAL VALIDATOR CHECKPOINTS
# ============================================================================

@dataclass
class SpectralCheckpoint:
    """Result of a spectral validation checkpoint."""
    name: str
    passed: bool
    expected: str
    actual: str
    severity: str


class SpectralInvariantValidator:
    """
    Validator for spectral invariants with checkpoints.
    """
    
    SQRT2 = np.sqrt(2)
    
    def __init__(self, laplacian: np.ndarray, tol: float = 1e-10):
        self.laplacian = laplacian
        self.tol = tol
        self.invariants = compute_spectral_invariants(laplacian, tol)
        self.checkpoints: List[SpectralCheckpoint] = []
    
    def validate_all(self) -> Tuple[bool, List[SpectralCheckpoint]]:
        """Run all validation checkpoints."""
        self.checkpoints = []
        
        # Checkpoint 1: Symmetry
        self._check_symmetry()
        
        # Checkpoint 2: Positive semi-definiteness
        self._check_psd()
        
        # Checkpoint 3: √2 bounds on spectral gap
        self._check_sqrt2_bounds()
        
        # Checkpoint 4: Condition number
        self._check_condition_number()
        
        # Checkpoint 5: Kernel dimension = β₀
        self._check_kernel_betti()
        
        # Checkpoint 6: Trace positivity
        self._check_trace_positive()
        
        all_passed = all(cp.passed for cp in self.checkpoints if cp.severity == "critical")
        return all_passed, self.checkpoints
    
    def _check_symmetry(self):
        """Laplacian must be symmetric: Δ = Δᵀ"""
        asym = np.linalg.norm(self.laplacian - self.laplacian.T)
        passed = asym < self.tol
        
        self.checkpoints.append(SpectralCheckpoint(
            name="Laplacian symmetry",
            passed=passed,
            expected="||Δ - Δᵀ|| = 0",
            actual=f"||Δ - Δᵀ|| = {asym:.2e}",
            severity="critical"
        ))
    
    def _check_psd(self):
        """Laplacian must be positive semi-definite: λ_min ≥ 0"""
        min_eig = self.invariants.eigenvalues[0]
        passed = min_eig >= -self.tol
        
        self.checkpoints.append(SpectralCheckpoint(
            name="Positive semi-definite",
            passed=passed,
            expected="λ_min ≥ 0",
            actual=f"λ_min = {min_eig:.6f}",
            severity="critical"
        ))
    
    def _check_sqrt2_bounds(self):
        """Spectral gap must be in [1/√2, 2√2] for valid topology."""
        gap = self.invariants.spectral_gap
        lower = 1 / self.SQRT2
        upper = 2 * self.SQRT2
        
        passed = lower <= gap <= upper
        
        self.checkpoints.append(SpectralCheckpoint(
            name="√2 gap bounds",
            passed=passed,
            expected=f"λ₁ ∈ [{lower:.4f}, {upper:.4f}]",
            actual=f"λ₁ = {gap:.4f}",
            severity="critical"
        ))
    
    def _check_condition_number(self, max_cond: float = 1000):
        """Condition number should be bounded (numerical stability)."""
        cond = self.invariants.condition_number
        passed = cond <= max_cond
        
        self.checkpoints.append(SpectralCheckpoint(
            name="Condition number",
            passed=passed,
            expected=f"κ ≤ {max_cond}",
            actual=f"κ = {cond:.2f}",
            severity="warning"
        ))
    
    def _check_kernel_betti(self):
        """Kernel dimension should be at least 1 (connected)."""
        dim = self.invariants.kernel_dimension
        passed = dim >= 1
        
        self.checkpoints.append(SpectralCheckpoint(
            name="Kernel dimension",
            passed=passed,
            expected="dim(ker Δ) ≥ 1",
            actual=f"dim(ker Δ) = {dim}",
            severity="critical"
        ))
    
    def _check_trace_positive(self):
        """tr(Δ) should be positive (proper Laplacian)."""
        trace = self.invariants.trace_L1
        passed = trace > 0
        
        self.checkpoints.append(SpectralCheckpoint(
            name="Trace positive",
            passed=passed,
            expected="tr(Δ) > 0",
            actual=f"tr(Δ) = {trace:.4f}",
            severity="warning"
        ))
    
    def report(self) -> str:
        """Generate human-readable report."""
        lines = ["=== SPECTRAL INVARIANT VALIDATION ==="]
        
        for cp in self.checkpoints:
            status = "✅" if cp.passed else ("⚠️" if cp.severity == "warning" else "❌")
            lines.append(f"{status} {cp.name}: {cp.actual}")
        
        lines.append("-" * 40)
        lines.append(f"Spectral gap: λ₁ = {self.invariants.spectral_gap:.6f}")
        lines.append(f"Kernel dim: {self.invariants.kernel_dimension}")
        lines.append(f"Traces: {self.invariants.trace_L1:.2f}, {self.invariants.trace_L2:.2f}, {self.invariants.trace_L3:.2f}")
        lines.append("=" * 40)
        
        passed = all(cp.passed for cp in self.checkpoints if cp.severity == "critical")
        lines.append(f"OVERALL: {'PASS' if passed else 'FAIL'}")
        
        return '\n'.join(lines)


# ============================================================================
# SPECTRAL MATCHING
# ============================================================================

def spectra_match(
    spec1: SpectralInvariants,
    spec2: SpectralInvariants,
    eigenvalue_tol: float = 1e-6,
    trace_tol: float = 1e-4
) -> Tuple[bool, str]:
    """
    Check if two spectral invariant sets match.
    
    Matching spectra ⟹ spectrally equivalent Laplacians.
    
    NOTE: Isospectral non-isomorphic examples exist, so this is
    necessary but not sufficient for homotopy equivalence.
    """
    # Check eigenvalue count
    if len(spec1.eigenvalues) != len(spec2.eigenvalues):
        return (False, f"Eigenvalue count mismatch: {len(spec1.eigenvalues)} vs {len(spec2.eigenvalues)}")
    
    # Check eigenvalues
    eig_diff = np.max(np.abs(spec1.eigenvalues - spec2.eigenvalues))
    if eig_diff > eigenvalue_tol:
        return (False, f"Eigenvalue mismatch: max diff = {eig_diff:.6f}")
    
    # Check traces
    if abs(spec1.trace_L1 - spec2.trace_L1) > trace_tol:
        return (False, f"tr(Δ) mismatch: {spec1.trace_L1} vs {spec2.trace_L1}")
    
    if abs(spec1.trace_L2 - spec2.trace_L2) > trace_tol:
        return (False, f"tr(Δ²) mismatch: {spec1.trace_L2} vs {spec2.trace_L2}")
    
    if abs(spec1.trace_L3 - spec2.trace_L3) > trace_tol:
        return (False, f"tr(Δ³) mismatch: {spec1.trace_L3} vs {spec2.trace_L3}")
    
    return (True, "Spectral invariants match")


def spectral_distance(spec1: SpectralInvariants, spec2: SpectralInvariants) -> float:
    """
    Compute spectral distance between two invariant sets.
    
    Uses Wasserstein distance on eigenvalue distributions.
    """
    # Pad to same length
    n1, n2 = len(spec1.eigenvalues), len(spec2.eigenvalues)
    max_n = max(n1, n2)
    
    eigs1 = np.pad(spec1.eigenvalues, (0, max_n - n1), constant_values=0)
    eigs2 = np.pad(spec2.eigenvalues, (0, max_n - n2), constant_values=0)
    
    # Sort and compute L1 distance (1-Wasserstein)
    return float(np.sum(np.abs(np.sort(eigs1) - np.sort(eigs2))))
