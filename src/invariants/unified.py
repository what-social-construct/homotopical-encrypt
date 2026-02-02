"""
Unified Invariant Validator

Orchestrates all invariant checkpoints for complete homotopy class characterization:
- Spectral invariants (Hansen & Ghrist)
- Cohomology invariants (Čech, sheaf)  
- Homotopical logic invariants (Helfer)

References:
- Hansen & Ghrist (2019). Toward a Spectral Theory of Cellular Sheaves. arXiv:1808.01513
- Helfer (2019). First-Order Homotopical Logic. arXiv:1908.08944
- Robinson (2014). Topological Signal Processing.
"""

from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Optional, Any
from enum import Enum
import numpy as np
import time

from .spectral import (
    SpectralInvariants, 
    compute_spectral_invariants, 
    SpectralInvariantValidator,
    spectra_match
)
from .homotopical import (
    HomotopicalLogicInvariants,
    HLevel,
    compute_homotopical_invariants,
    HomotopicalInvariantValidator,
    invariants_match as homotopical_match
)
from .cohomology import (
    CohomologyInvariants,
    NerveValidation,
    compute_cohomology_invariants,
    validate_nerve_structure,
    CohomologyInvariantValidator,
    cohomology_match
)


# ============================================================================
# UNIFIED INVARIANT STRUCTURE
# ============================================================================

@dataclass
class HomotopyClassFingerprint:
    """
    Complete fingerprint for a homotopy equivalence class.
    
    This is THE definition of homotopy equivalence:
    F ≃ G ⟺ fingerprint(F) = fingerprint(G)
    """
    # Spectral (from Laplacian)
    spectral: SpectralInvariants
    
    # Cohomological (from cochain complex)
    cohomology: CohomologyInvariants
    
    # Homotopical Logic (from type-theoretic structure)
    homotopical: HomotopicalLogicInvariants
    
    # Metadata
    timestamp: float = field(default_factory=time.time)
    topology_hash: bytes = b""
    
    def matches(self, other: 'HomotopyClassFingerprint', tol: float = 1e-6) -> Tuple[bool, str]:
        """
        Check if two fingerprints represent the same homotopy class.
        
        Matching all invariants ⟹ homotopy equivalent (by construction).
        """
        # Spectral match
        spec_match, spec_msg = spectra_match(self.spectral, other.spectral, eigenvalue_tol=tol)
        if not spec_match:
            return (False, f"Spectral: {spec_msg}")
        
        # Cohomology match
        coh_match, coh_msg = cohomology_match(self.cohomology, other.cohomology)
        if not coh_match:
            return (False, f"Cohomology: {coh_msg}")
        
        # Homotopical logic match
        hom_match, hom_msg = homotopical_match(self.homotopical, other.homotopical)
        if not hom_match:
            return (False, f"Homotopical: {hom_msg}")
        
        return (True, "All invariants match - homotopy equivalent")
    
    def to_dict(self) -> Dict:
        return {
            "spectral": self.spectral.to_dict(),
            "cohomology": self.cohomology.to_dict(),
            "homotopical": self.homotopical.to_dict(),
            "timestamp": self.timestamp,
            "topology_hash": self.topology_hash.hex() if self.topology_hash else ""
        }
    
    def summary(self) -> str:
        """One-line summary of key invariants."""
        return (
            f"β=({self.cohomology.betti_0},{self.cohomology.betti_1},{self.cohomology.betti_2}) "
            f"λ₁={self.spectral.spectral_gap:.4f} "
            f"h-level={self.homotopical.h_level.name} "
            f"Σ-rank={self.homotopical.sigma_rank}"
        )


# ============================================================================
# CHECKPOINT TYPES
# ============================================================================

class CheckpointSeverity(Enum):
    CRITICAL = "critical"    # BLOCKS: must pass
    WARNING = "warning"      # WARNS: should investigate
    INFO = "info"            # INFO: for diagnostics


@dataclass
class InvariantCheckpoint:
    """Result of a single invariant check."""
    category: str            # "spectral", "cohomology", "homotopical"
    name: str
    passed: bool
    expected: str
    actual: str
    severity: CheckpointSeverity
    timestamp: float = field(default_factory=time.time)


# ============================================================================
# UNIFIED VALIDATOR
# ============================================================================

class UnifiedInvariantValidator:
    """
    Master validator orchestrating all invariant checkpoints.
    
    Pipeline integration points:
    - KEYGEN: Validate generated fibration has valid invariants
    - ENCRYPT: Validate topology before encoding
    - DECRYPT: Validate Laplacian structure before projection
    - ZK_PROVE: Validate invariants match claimed fingerprint
    - TRANSACTION: Validate both parties' fingerprints
    """
    
    def __init__(
        self,
        nerve: Dict[int, List[Tuple]],
        laplacian: np.ndarray,
        delta_0: np.ndarray,
        delta_1: Optional[np.ndarray] = None,
        connection: Dict[Tuple[int, int], np.ndarray] = None,
        tol: float = 1e-10
    ):
        self.nerve = nerve
        self.laplacian = laplacian
        self.delta_0 = delta_0
        self.delta_1 = delta_1
        self.connection = connection
        self.tol = tol
        
        # Compute all invariants
        self.spectral = compute_spectral_invariants(laplacian, tol)
        self.cohomology = compute_cohomology_invariants(
            nerve, delta_0, delta_1, laplacian, tol
        )
        
        betti = {
            0: self.cohomology.betti_0,
            1: self.cohomology.betti_1,
            2: self.cohomology.betti_2
        }
        self.homotopical = compute_homotopical_invariants(
            nerve, laplacian, betti, connection
        )
        
        # Validate nerve structure
        self.nerve_validation = validate_nerve_structure(nerve)
        
        # Checkpoint results
        self.checkpoints: List[InvariantCheckpoint] = []
    
    def get_fingerprint(self) -> HomotopyClassFingerprint:
        """Extract complete fingerprint from validated structure."""
        import hashlib
        
        # Hash the nerve structure
        nerve_str = str(sorted(self.nerve.items()))
        topology_hash = hashlib.sha256(nerve_str.encode()).digest()[:16]
        
        return HomotopyClassFingerprint(
            spectral=self.spectral,
            cohomology=self.cohomology,
            homotopical=self.homotopical,
            topology_hash=topology_hash
        )
    
    def validate_all(self) -> Tuple[bool, List[InvariantCheckpoint]]:
        """
        Run ALL invariant checkpoints.
        
        Returns (overall_pass, list_of_checkpoints)
        """
        self.checkpoints = []
        
        # ========== SPECTRAL INVARIANTS ==========
        self._check_spectral_symmetry()
        self._check_spectral_psd()
        self._check_spectral_gap_bounds()
        self._check_spectral_condition()
        self._check_kernel_dimension()
        
        # ========== COHOMOLOGY INVARIANTS ==========
        self._check_finite_nerve()
        self._check_simplicial()
        self._check_connected()
        self._check_cochain_complex()
        self._check_euler()
        self._check_hodge()
        
        # ========== HOMOTOPICAL LOGIC INVARIANTS ==========
        self._check_h_level()
        self._check_path_space()
        self._check_sigma_rank()
        self._check_pi_rank()
        self._check_transport_coherence()
        
        # Determine overall pass
        critical_failed = [
            cp for cp in self.checkpoints 
            if not cp.passed and cp.severity == CheckpointSeverity.CRITICAL
        ]
        
        return (len(critical_failed) == 0, self.checkpoints)
    
    def validate_for_stage(self, stage: str) -> Tuple[bool, List[InvariantCheckpoint]]:
        """
        Validate only checkpoints relevant to a specific pipeline stage.
        
        Stages:
        - "keygen": All checkpoints (new fibration must be fully valid)
        - "encrypt": Spectral + cohomology (need valid topology)
        - "decrypt": Spectral (need valid Laplacian for projection)
        - "zk_prove": All checkpoints (proving fingerprint validity)
        - "transaction": Cohomology + homotopical (structural matching)
        """
        self.checkpoints = []
        
        if stage == "keygen":
            return self.validate_all()
        
        elif stage == "encrypt":
            self._check_spectral_psd()
            self._check_spectral_gap_bounds()
            self._check_finite_nerve()
            self._check_connected()
            self._check_cochain_complex()
        
        elif stage == "decrypt":
            self._check_spectral_symmetry()
            self._check_spectral_psd()
            self._check_kernel_dimension()
        
        elif stage == "zk_prove":
            return self.validate_all()
        
        elif stage == "transaction":
            self._check_connected()
            self._check_h_level()
            self._check_sigma_rank()
        
        else:
            return self.validate_all()
        
        critical_failed = [
            cp for cp in self.checkpoints 
            if not cp.passed and cp.severity == CheckpointSeverity.CRITICAL
        ]
        
        return (len(critical_failed) == 0, self.checkpoints)
    
    # ========== SPECTRAL CHECKPOINTS ==========
    
    def _check_spectral_symmetry(self):
        """Laplacian must be symmetric."""
        asym = np.linalg.norm(self.laplacian - self.laplacian.T)
        passed = asym < self.tol
        
        self.checkpoints.append(InvariantCheckpoint(
            category="spectral",
            name="Laplacian symmetry",
            passed=passed,
            expected="||Δ - Δᵀ|| = 0",
            actual=f"||Δ - Δᵀ|| = {asym:.2e}",
            severity=CheckpointSeverity.CRITICAL
        ))
    
    def _check_spectral_psd(self):
        """Laplacian must be positive semi-definite."""
        min_eig = self.spectral.eigenvalues[0] if len(self.spectral.eigenvalues) > 0 else 0
        passed = min_eig >= -self.tol
        
        self.checkpoints.append(InvariantCheckpoint(
            category="spectral",
            name="Positive semi-definite",
            passed=passed,
            expected="λ_min ≥ 0",
            actual=f"λ_min = {min_eig:.6f}",
            severity=CheckpointSeverity.CRITICAL
        ))
    
    def _check_spectral_gap_bounds(self):
        """Spectral gap in √2 bounds."""
        SQRT2 = np.sqrt(2)
        gap = self.spectral.spectral_gap
        lower, upper = 1/SQRT2, 2*SQRT2
        passed = lower <= gap <= upper
        
        self.checkpoints.append(InvariantCheckpoint(
            category="spectral",
            name="√2 gap bounds",
            passed=passed,
            expected=f"λ₁ ∈ [{lower:.4f}, {upper:.4f}]",
            actual=f"λ₁ = {gap:.4f}",
            severity=CheckpointSeverity.CRITICAL
        ))
    
    def _check_spectral_condition(self):
        """Condition number should be bounded."""
        cond = self.spectral.condition_number
        passed = cond <= 1000
        
        self.checkpoints.append(InvariantCheckpoint(
            category="spectral",
            name="Condition number",
            passed=passed,
            expected="κ ≤ 1000",
            actual=f"κ = {cond:.2f}",
            severity=CheckpointSeverity.WARNING
        ))
    
    def _check_kernel_dimension(self):
        """Kernel dimension should match β₀."""
        dim = self.spectral.kernel_dimension
        beta_0 = self.cohomology.betti_0
        passed = dim == beta_0
        
        self.checkpoints.append(InvariantCheckpoint(
            category="spectral",
            name="Kernel = β₀",
            passed=passed,
            expected=f"dim(ker Δ) = β₀ = {beta_0}",
            actual=f"dim(ker Δ) = {dim}",
            severity=CheckpointSeverity.CRITICAL
        ))
    
    # ========== COHOMOLOGY CHECKPOINTS ==========
    
    def _check_finite_nerve(self):
        """Nerve must be finite."""
        passed = self.nerve_validation.is_finite
        
        self.checkpoints.append(InvariantCheckpoint(
            category="cohomology",
            name="Finite nerve",
            passed=passed,
            expected="n₀ < 10000",
            actual=f"n₀ = {self.nerve_validation.n_vertices}",
            severity=CheckpointSeverity.CRITICAL
        ))
    
    def _check_simplicial(self):
        """Nerve must be simplicial."""
        passed = self.nerve_validation.is_simplicial
        
        self.checkpoints.append(InvariantCheckpoint(
            category="cohomology",
            name="Simplicial",
            passed=passed,
            expected="All faces present",
            actual="Yes" if passed else "Missing faces",
            severity=CheckpointSeverity.CRITICAL
        ))
    
    def _check_connected(self):
        """Nerve should be connected."""
        passed = self.cohomology.betti_0 == 1
        
        self.checkpoints.append(InvariantCheckpoint(
            category="cohomology",
            name="Connected",
            passed=passed,
            expected="β₀ = 1",
            actual=f"β₀ = {self.cohomology.betti_0}",
            severity=CheckpointSeverity.CRITICAL
        ))
    
    def _check_cochain_complex(self):
        """Verify δ₁ ∘ δ₀ = 0."""
        passed = self.cohomology.is_cochain_complex
        
        self.checkpoints.append(InvariantCheckpoint(
            category="cohomology",
            name="Cochain complex",
            passed=passed,
            expected="||δ₁δ₀|| = 0",
            actual=f"||δ₁δ₀|| = {self.cohomology.exactness_error_01:.2e}",
            severity=CheckpointSeverity.CRITICAL
        ))
    
    def _check_euler(self):
        """Euler characteristic consistency."""
        nv = self.nerve_validation
        expected = nv.n_vertices - nv.n_edges + nv.n_triangles
        actual = self.cohomology.euler_characteristic
        passed = expected == actual
        
        self.checkpoints.append(InvariantCheckpoint(
            category="cohomology",
            name="Euler",
            passed=passed,
            expected=f"χ = {expected}",
            actual=f"χ = {actual}",
            severity=CheckpointSeverity.WARNING
        ))
    
    def _check_hodge(self):
        """Hodge decomposition consistency."""
        total = (
            self.cohomology.harmonic_ratio + 
            self.cohomology.exact_ratio + 
            self.cohomology.coexact_ratio
        )
        passed = total <= 1.1  # Small tolerance
        
        self.checkpoints.append(InvariantCheckpoint(
            category="cohomology",
            name="Hodge sum",
            passed=passed,
            expected="H + E + C ≤ 1",
            actual=f"H + E + C = {total:.2f}",
            severity=CheckpointSeverity.WARNING
        ))
    
    # ========== HOMOTOPICAL LOGIC CHECKPOINTS ==========
    
    def _check_h_level(self):
        """h-level consistency with Betti numbers."""
        h = self.homotopical.h_level
        beta_1 = self.cohomology.betti_1
        
        # SET h-level requires β₁ = 0
        passed = not (h == HLevel.SET and beta_1 > 0)
        
        self.checkpoints.append(InvariantCheckpoint(
            category="homotopical",
            name="h-level",
            passed=passed,
            expected=f"Consistent with β₁ = {beta_1}",
            actual=f"h-level = {h.name}",
            severity=CheckpointSeverity.INFO
        ))
    
    def _check_path_space(self):
        """Path space dimension matches β₀."""
        dim = self.homotopical.path_space_dim
        beta_0 = self.cohomology.betti_0
        passed = dim == beta_0
        
        self.checkpoints.append(InvariantCheckpoint(
            category="homotopical",
            name="Path space",
            passed=passed,
            expected=f"dim = β₀ = {beta_0}",
            actual=f"dim = {dim}",
            severity=CheckpointSeverity.CRITICAL
        ))
    
    def _check_sigma_rank(self):
        """Σ-rank should be at least 1."""
        rank = self.homotopical.sigma_rank
        passed = rank >= 1
        
        self.checkpoints.append(InvariantCheckpoint(
            category="homotopical",
            name="Σ-rank",
            passed=passed,
            expected="Σ-rank ≥ 1",
            actual=f"Σ-rank = {rank}",
            severity=CheckpointSeverity.CRITICAL
        ))
    
    def _check_pi_rank(self):
        """Π-rank matches β₀."""
        pi_rank = self.homotopical.pi_rank
        beta_0 = self.cohomology.betti_0
        passed = pi_rank == beta_0
        
        self.checkpoints.append(InvariantCheckpoint(
            category="homotopical",
            name="Π-rank",
            passed=passed,
            expected=f"Π-rank = β₀ = {beta_0}",
            actual=f"Π-rank = {pi_rank}",
            severity=CheckpointSeverity.WARNING
        ))
    
    def _check_transport_coherence(self):
        """Transport coherence bounded (near-flat)."""
        coherence = self.homotopical.transport_coherence
        passed = coherence <= 0.1
        
        self.checkpoints.append(InvariantCheckpoint(
            category="homotopical",
            name="Transport coherence",
            passed=passed,
            expected="≤ 0.1",
            actual=f"{coherence:.6f}",
            severity=CheckpointSeverity.WARNING
        ))
    
    # ========== REPORTING ==========
    
    def report(self) -> str:
        """Generate comprehensive human-readable report."""
        lines = [
            "═" * 50,
            "  UNIFIED INVARIANT VALIDATION REPORT",
            "═" * 50,
            ""
        ]
        
        # Group by category
        by_category = {}
        for cp in self.checkpoints:
            by_category.setdefault(cp.category, []).append(cp)
        
        for category in ["spectral", "cohomology", "homotopical"]:
            if category in by_category:
                lines.append(f"[{category.upper()}]")
                for cp in by_category[category]:
                    status = "✅" if cp.passed else ("⚠️" if cp.severity == CheckpointSeverity.WARNING else "❌")
                    lines.append(f"  {status} {cp.name}: {cp.actual}")
                lines.append("")
        
        # Summary
        lines.append("-" * 50)
        fp = self.get_fingerprint()
        lines.append(f"Fingerprint: {fp.summary()}")
        
        critical_failed = sum(
            1 for cp in self.checkpoints 
            if not cp.passed and cp.severity == CheckpointSeverity.CRITICAL
        )
        warnings = sum(
            1 for cp in self.checkpoints 
            if not cp.passed and cp.severity == CheckpointSeverity.WARNING
        )
        
        lines.append(f"Critical failures: {critical_failed}")
        lines.append(f"Warnings: {warnings}")
        lines.append("═" * 50)
        lines.append(f"OVERALL: {'✅ PASS' if critical_failed == 0 else '❌ FAIL'}")
        lines.append("═" * 50)
        
        return '\n'.join(lines)


# ============================================================================
# CONVENIENCE FUNCTIONS
# ============================================================================

def validate_fibration(
    nerve: Dict[int, List[Tuple]],
    laplacian: np.ndarray,
    delta_0: np.ndarray,
    delta_1: Optional[np.ndarray] = None,
    stage: str = "keygen"
) -> Tuple[bool, HomotopyClassFingerprint, str]:
    """
    Convenience function to validate a fibration.
    
    Returns (passed, fingerprint, report)
    """
    validator = UnifiedInvariantValidator(
        nerve=nerve,
        laplacian=laplacian,
        delta_0=delta_0,
        delta_1=delta_1
    )
    
    passed, checkpoints = validator.validate_for_stage(stage)
    fingerprint = validator.get_fingerprint()
    report = validator.report()
    
    return (passed, fingerprint, report)


def fingerprints_equivalent(
    fp1: HomotopyClassFingerprint,
    fp2: HomotopyClassFingerprint,
    tol: float = 1e-6
) -> Tuple[bool, str]:
    """
    Check if two fingerprints represent the same homotopy class.
    """
    return fp1.matches(fp2, tol)
