"""
Homotopy Path Construction

Given two fibrations F, G with matching spectral invariants,
construct an explicit homotopy path γ: [0,1] → Fib(X) with γ(0)=F, γ(1)=G.

This is the DEFINITIVE test of homotopy equivalence:
- Spectral equivalence: same invariants (necessary)
- Homotopy path exists: same class (sufficient)

The path is a family of natural transformations interpolating F → G.

Mathematical foundation:
- Path space: Path(F,G) = {γ: I → Fib(X) | γ(0)=F, γ(1)=G}
- F ≃ G iff Path(F,G) is non-empty
- We construct γ via geodesic interpolation on Grassmannian
"""

from dataclasses import dataclass
from typing import List, Tuple, Optional, Callable
import numpy as np
from enum import Enum


class PathStatus(Enum):
    """Status of homotopy path construction."""
    NOT_CHECKED = "not_checked"
    CONSTRUCTING = "constructing"
    PATH_EXISTS = "path_exists"
    NO_PATH = "no_path"
    SPECTRAL_MISMATCH = "spectral_mismatch"


@dataclass
class HomotopyPath:
    """
    An explicit homotopy path between two fibrations.
    
    The path is parameterized by t ∈ [0,1]:
    - γ(0) = source fibration F
    - γ(1) = target fibration G
    - γ(t) = interpolated fibration
    
    We store the path as:
    - A sequence of Laplacian matrices L(t) for t ∈ {0, 1/n, 2/n, ..., 1}
    - Or as geodesic parameters on Grassmannian
    """
    source_laplacian: np.ndarray
    target_laplacian: np.ndarray
    
    # Path representation (n_steps samples)
    n_steps: int
    path_laplacians: List[np.ndarray]  # L(0), L(1/n), ..., L(1)
    
    # Verification
    spectral_error: List[float]  # ||spec(L(t)) - interpolated spec|| at each step
    continuity_error: float  # max ||L(t+dt) - L(t)||
    
    # Status
    status: PathStatus
    
    def evaluate(self, t: float) -> np.ndarray:
        """Evaluate path at parameter t ∈ [0,1]."""
        if t <= 0:
            return self.source_laplacian.copy()
        if t >= 1:
            return self.target_laplacian.copy()
        
        # Linear interpolation between stored samples
        idx = t * (self.n_steps - 1)
        i = int(idx)
        frac = idx - i
        
        if i >= self.n_steps - 1:
            return self.target_laplacian.copy()
        
        return (1 - frac) * self.path_laplacians[i] + frac * self.path_laplacians[i + 1]
    
    def verify_continuity(self, threshold: float = 0.1) -> bool:
        """Verify path is continuous (small jumps between samples)."""
        return self.continuity_error < threshold
    
    def verify_endpoints(self, tol: float = 1e-6) -> bool:
        """Verify endpoints match source and target."""
        err_0 = np.linalg.norm(self.path_laplacians[0] - self.source_laplacian)
        err_1 = np.linalg.norm(self.path_laplacians[-1] - self.target_laplacian)
        return err_0 < tol and err_1 < tol


# ============================================================================
# INVARIANT VALIDATION GATES
# ============================================================================

SQRT2 = np.sqrt(2)
POV_LOWER = 1 / SQRT2  # ~0.707
POV_UPPER = 2 * SQRT2  # ~2.828


@dataclass
class InvariantReport:
    """Complete invariant validation report."""
    # Gate results (all must pass)
    spectral_match: bool
    betti_match: bool
    gap_valid: bool
    psd_valid: bool
    trace_match: bool
    condition_valid: bool
    
    # Values
    spectral_error: float
    betti_numbers: List[int]
    spectral_gap: float
    min_eigenvalue: float
    trace_error: float
    condition_number: float
    
    # Overall
    all_gates_pass: bool
    failure_reason: str
    
    def __str__(self):
        gates = [
            f"Spectral:   {'✓' if self.spectral_match else '✗'}",
            f"Betti:      {'✓' if self.betti_match else '✗'}",
            f"Gap √2:     {'✓' if self.gap_valid else '✗'} (λ₁={self.spectral_gap:.4f})",
            f"PSD:        {'✓' if self.psd_valid else '✗'} (min={self.min_eigenvalue:.4f})",
            f"Trace:      {'✓' if self.trace_match else '✗'} (err={self.trace_error:.6f})",
            f"Condition:  {'✓' if self.condition_valid else '✗'} (κ={self.condition_number:.2f})",
        ]
        return '\n'.join(gates) + f"\n{'='*40}\nOVERALL: {'PASS' if self.all_gates_pass else 'FAIL: ' + self.failure_reason}"


def validate_laplacian(L: np.ndarray, tol: float = 1e-4) -> InvariantReport:
    """
    Validate a single Laplacian against all invariant gates.
    
    Gates:
    1. Positive semidefinite (valid Laplacian)
    2. Spectral gap in [1/√2, 2√2]
    3. Condition number reasonable (< 1000)
    """
    eigs = np.sort(np.linalg.eigvalsh(L))
    
    # Gate 1: PSD check
    min_eig = float(eigs[0])
    psd_valid = min_eig >= -tol
    
    # Gate 2: Spectral gap
    nonzero = eigs[eigs > tol]
    gap = float(nonzero[0]) if len(nonzero) > 0 else 0.0
    gap_valid = POV_LOWER <= gap <= POV_UPPER
    
    # Gate 3: Condition number
    max_eig = float(eigs[-1])
    if gap > tol:
        cond = max_eig / gap
    else:
        cond = float('inf')
    condition_valid = cond < 1000
    
    # Betti numbers
    betti = [int(np.sum(np.abs(eigs) < tol))]
    
    failure = ""
    if not psd_valid:
        failure = f"Not PSD: min eigenvalue = {min_eig:.6f}"
    elif not gap_valid:
        failure = f"Gap out of √2 bounds: {gap:.4f} ∉ [{POV_LOWER:.4f}, {POV_UPPER:.4f}]"
    elif not condition_valid:
        failure = f"Ill-conditioned: κ = {cond:.2f}"
    
    return InvariantReport(
        spectral_match=True,  # Self-match
        betti_match=True,
        gap_valid=gap_valid,
        psd_valid=psd_valid,
        trace_match=True,
        condition_valid=condition_valid,
        spectral_error=0.0,
        betti_numbers=betti,
        spectral_gap=gap,
        min_eigenvalue=min_eig,
        trace_error=0.0,
        condition_number=cond,
        all_gates_pass=psd_valid and gap_valid and condition_valid,
        failure_reason=failure
    )


def check_spectral_equivalence(
    L1: np.ndarray,
    L2: np.ndarray,
    tol: float = 1e-4
) -> Tuple[bool, float, str]:
    """
    Quick check: do two Laplacians have matching spectra?
    
    This is NECESSARY for homotopy equivalence.
    If this fails, no path exists.
    """
    # Get eigenvalues
    eigs1 = np.sort(np.linalg.eigvalsh(L1))
    eigs2 = np.sort(np.linalg.eigvalsh(L2))
    
    # Check dimensions match
    if len(eigs1) != len(eigs2):
        return (False, float('inf'), f"Dimension mismatch: {len(eigs1)} vs {len(eigs2)}")
    
    # Check eigenvalues match
    diff = np.abs(eigs1 - eigs2)
    max_diff = float(np.max(diff))
    
    if max_diff > tol:
        return (False, max_diff, f"Spectral difference: {max_diff:.6f} > {tol}")
    
    # Check Betti numbers (count of zero eigenvalues)
    betti1 = np.sum(np.abs(eigs1) < tol)
    betti2 = np.sum(np.abs(eigs2) < tol)
    
    if betti1 != betti2:
        return (False, float('inf'), f"Betti mismatch: {betti1} vs {betti2}")
    
    return (True, max_diff, "Spectral equivalence verified")


def check_full_equivalence(
    L1: np.ndarray,
    L2: np.ndarray,
    tol: float = 1e-4
) -> InvariantReport:
    """
    Full invariant validation between two Laplacians.
    
    Gates:
    1. Spectral match (eigenvalues)
    2. Betti match (topology)
    3. Gap valid (both in √2 bounds)
    4. PSD valid (both valid Laplacians)
    5. Trace match (tr(L¹), tr(L²), tr(L³))
    6. Condition match (similar conditioning)
    """
    eigs1 = np.sort(np.linalg.eigvalsh(L1))
    eigs2 = np.sort(np.linalg.eigvalsh(L2))
    
    # Gate 1: Spectral match
    if len(eigs1) != len(eigs2):
        return InvariantReport(
            spectral_match=False, betti_match=False, gap_valid=False,
            psd_valid=False, trace_match=False, condition_valid=False,
            spectral_error=float('inf'), betti_numbers=[], spectral_gap=0,
            min_eigenvalue=0, trace_error=float('inf'), condition_number=float('inf'),
            all_gates_pass=False, failure_reason=f"Dimension mismatch: {len(eigs1)} vs {len(eigs2)}"
        )
    
    spec_err = float(np.max(np.abs(eigs1 - eigs2)))
    spectral_match = spec_err < tol
    
    # Gate 2: Betti match
    betti1 = int(np.sum(np.abs(eigs1) < tol))
    betti2 = int(np.sum(np.abs(eigs2) < tol))
    betti_match = betti1 == betti2
    
    # Gate 3: Gap valid (both)
    nonzero1 = eigs1[eigs1 > tol]
    nonzero2 = eigs2[eigs2 > tol]
    gap1 = float(nonzero1[0]) if len(nonzero1) > 0 else 0.0
    gap2 = float(nonzero2[0]) if len(nonzero2) > 0 else 0.0
    gap_valid = (POV_LOWER <= gap1 <= POV_UPPER) and (POV_LOWER <= gap2 <= POV_UPPER)
    
    # Gate 4: PSD valid (both)
    psd_valid = eigs1[0] >= -tol and eigs2[0] >= -tol
    
    # Gate 5: Trace match (tr(L), tr(L²), tr(L³))
    trace1 = [np.trace(L1), np.trace(L1 @ L1), np.trace(L1 @ L1 @ L1)]
    trace2 = [np.trace(L2), np.trace(L2 @ L2), np.trace(L2 @ L2 @ L2)]
    trace_err = max(abs(t1 - t2) for t1, t2 in zip(trace1, trace2))
    trace_match = trace_err < tol * np.trace(L1) * 10  # Relative tolerance
    
    # Gate 6: Condition match
    cond1 = eigs1[-1] / gap1 if gap1 > tol else float('inf')
    cond2 = eigs2[-1] / gap2 if gap2 > tol else float('inf')
    condition_valid = abs(cond1 - cond2) < max(cond1, cond2) * 0.1  # 10% relative
    
    all_pass = all([spectral_match, betti_match, gap_valid, psd_valid, trace_match, condition_valid])
    
    failure = ""
    if not spectral_match:
        failure = f"Spectral error: {spec_err:.6f}"
    elif not betti_match:
        failure = f"Betti mismatch: {betti1} vs {betti2}"
    elif not gap_valid:
        failure = f"Gap invalid: {gap1:.4f}, {gap2:.4f}"
    elif not psd_valid:
        failure = f"Not PSD"
    elif not trace_match:
        failure = f"Trace mismatch: {trace_err:.6f}"
    elif not condition_valid:
        failure = f"Condition mismatch: {cond1:.2f} vs {cond2:.2f}"
    
    return InvariantReport(
        spectral_match=spectral_match,
        betti_match=betti_match,
        gap_valid=gap_valid,
        psd_valid=psd_valid,
        trace_match=trace_match,
        condition_valid=condition_valid,
        spectral_error=spec_err,
        betti_numbers=[betti1],
        spectral_gap=gap1,
        min_eigenvalue=float(min(eigs1[0], eigs2[0])),
        trace_error=trace_err,
        condition_number=cond1,
        all_gates_pass=all_pass,
        failure_reason=failure
    )


def _matrix_log_so(R: np.ndarray) -> np.ndarray:
    """
    Compute matrix logarithm for rotation matrix R ∈ SO(n).
    Returns skew-symmetric matrix Ω such that R = exp(Ω).
    """
    from scipy.linalg import logm
    Omega = logm(R)
    # Ensure skew-symmetric (numerical stability)
    return (Omega - Omega.T) / 2


def _matrix_exp_so(Omega: np.ndarray) -> np.ndarray:
    """
    Compute matrix exponential for skew-symmetric Ω.
    Returns rotation matrix R = exp(Ω) ∈ SO(n).
    """
    from scipy.linalg import expm
    return expm(Omega)


def construct_geodesic_path(
    L_source: np.ndarray,
    L_target: np.ndarray,
    n_steps: int = 20
) -> HomotopyPath:
    """
    Construct homotopy path via TRUE geodesic on SO(n).
    
    The space of Laplacians with fixed spectrum is a manifold.
    We find a geodesic (shortest path) connecting L_source to L_target.
    
    Method (PROPER GEODESIC):
    1. Eigendecompose both: L = V Λ V^T
    2. Compute rotation R = V_source^T @ V_target ∈ SO(n)
    3. Compute logarithm: Ω = log(R) (skew-symmetric)
    4. Geodesic: V(t) = V_source @ exp(t*Ω)
    5. Reconstruct: L(t) = V(t) Λ V(t)^T
    
    This is DETERMINISTIC because:
    - SO(n) is a compact Lie group
    - Geodesics are unique (for close enough points)
    - exp/log are deterministic
    """
    # Quick spectral check first
    spec_match, spec_err, reason = check_spectral_equivalence(L_source, L_target)
    
    if not spec_match:
        return HomotopyPath(
            source_laplacian=L_source,
            target_laplacian=L_target,
            n_steps=0,
            path_laplacians=[],
            spectral_error=[],
            continuity_error=float('inf'),
            status=PathStatus.SPECTRAL_MISMATCH
        )
    
    # Eigendecompose
    eigs_s, V_source = np.linalg.eigh(L_source)
    eigs_t, V_target = np.linalg.eigh(L_target)
    
    # Use source eigenvalues (they should match)
    Lambda = np.diag(eigs_s)
    
    # Align eigenvector signs (they can flip)
    for i in range(V_source.shape[1]):
        if np.dot(V_source[:, i], V_target[:, i]) < 0:
            V_target[:, i] *= -1
    
    # Compute rotation between eigenvector frames
    # R rotates V_source to V_target: V_target = V_source @ R
    R = V_source.T @ V_target
    
    # Ensure R is proper rotation (det = +1)
    if np.linalg.det(R) < 0:
        V_target[:, 0] *= -1
        R = V_source.T @ V_target
    
    # Compute geodesic generator (matrix logarithm)
    try:
        Omega = _matrix_log_so(R)
    except:
        # Fallback to linear interpolation if log fails
        Omega = (R - R.T) / 2  # First-order approximation
    
    # Construct geodesic path
    path_laplacians = []
    spectral_errors = []
    
    for step in range(n_steps):
        t = step / (n_steps - 1) if n_steps > 1 else 0
        
        # Geodesic on SO(n): R(t) = exp(t * Omega)
        R_t = _matrix_exp_so(t * Omega)
        
        # Interpolate eigenvectors
        V_t = V_source @ R_t
        
        # Reconstruct Laplacian
        L_t = V_t @ Lambda @ V_t.T
        
        # Symmetrize (numerical stability)
        L_t = (L_t + L_t.T) / 2
        
        path_laplacians.append(L_t)
        
        # Check spectrum preserved
        eigs_t_actual = np.sort(np.linalg.eigvalsh(L_t))
        spec_err = float(np.max(np.abs(eigs_t_actual - eigs_s)))
        spectral_errors.append(spec_err)
    
    # Compute continuity error
    max_jump = 0.0
    for i in range(len(path_laplacians) - 1):
        jump = np.linalg.norm(path_laplacians[i+1] - path_laplacians[i])
        max_jump = max(max_jump, jump)
    
    return HomotopyPath(
        source_laplacian=L_source,
        target_laplacian=L_target,
        n_steps=n_steps,
        path_laplacians=path_laplacians,
        spectral_error=spectral_errors,
        continuity_error=max_jump,
        status=PathStatus.PATH_EXISTS
    )


def verify_homotopy_equivalence(
    L1: np.ndarray,
    L2: np.ndarray,
    spectral_tol: float = 1e-4,
    path_tol: float = 0.1
) -> Tuple[bool, str, Optional[HomotopyPath]]:
    """
    Full verification of homotopy equivalence.
    
    1. Quick check: spectral equivalence
    2. If passes: construct homotopy path
    3. Verify path is valid (continuous, correct endpoints)
    
    Returns:
        (is_equivalent, reason, path_if_exists)
    """
    # Step 1: Spectral check
    spec_match, spec_err, spec_reason = check_spectral_equivalence(L1, L2, spectral_tol)
    
    if not spec_match:
        return (False, f"Spectral mismatch: {spec_reason}", None)
    
    # Step 2: Construct path
    path = construct_geodesic_path(L1, L2)
    
    if path.status != PathStatus.PATH_EXISTS:
        return (False, f"Path construction failed: {path.status}", None)
    
    # Step 3: Verify path
    if not path.verify_endpoints():
        return (False, "Path endpoints don't match", path)
    
    if not path.verify_continuity(path_tol):
        return (False, f"Path not continuous: error={path.continuity_error}", path)
    
    # Check spectrum preserved along path
    max_spec_err = max(path.spectral_error)
    if max_spec_err > spectral_tol * 10:
        return (False, f"Spectrum changes along path: {max_spec_err}", path)
    
    return (True, "Homotopy equivalence verified via geodesic path", path)


# ============================================================================
# TEST
# ============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("HOMOTOPY PATH CONSTRUCTION TEST")
    print("=" * 60)
    
    # Create two spectrally equivalent Laplacians
    n = 5
    
    # L1: Simple Laplacian
    L1 = np.eye(n) * 2
    L1[0, 1] = L1[1, 0] = -1
    L1[1, 2] = L1[2, 1] = -1
    L1[2, 3] = L1[3, 2] = -1
    L1[3, 4] = L1[4, 3] = -1
    
    # L2: Same spectrum but rotated (multiply by orthogonal matrix)
    theta = np.pi / 4
    R = np.eye(n)
    R[0:2, 0:2] = [[np.cos(theta), -np.sin(theta)],
                   [np.sin(theta), np.cos(theta)]]
    L2 = R @ L1 @ R.T
    
    print("\n1. Testing spectral equivalence check...")
    match, err, reason = check_spectral_equivalence(L1, L2)
    print(f"   Spectral match: {match}")
    print(f"   Max error: {err:.6f}")
    print(f"   Reason: {reason}")
    
    print("\n2. Constructing homotopy path...")
    path = construct_geodesic_path(L1, L2, n_steps=10)
    print(f"   Status: {path.status}")
    print(f"   N steps: {path.n_steps}")
    print(f"   Continuity error: {path.continuity_error:.6f}")
    print(f"   Max spectral error: {max(path.spectral_error):.6f}")
    
    print("\n3. Full homotopy equivalence verification...")
    equiv, reason, path = verify_homotopy_equivalence(L1, L2)
    print(f"   Equivalent: {equiv}")
    print(f"   Reason: {reason}")
    
    print("\n4. Testing NON-equivalent Laplacians...")
    L3 = np.eye(n) * 3  # Different spectrum
    equiv, reason, path = verify_homotopy_equivalence(L1, L3)
    print(f"   Equivalent: {equiv}")
    print(f"   Reason: {reason}")
    
    print("\n" + "=" * 60)
    print("✅ HOMOTOPY PATH TESTS COMPLETE")
    print("=" * 60)
