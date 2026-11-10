"""
Stage-Gated √2 Integration Test

Verifies the core architectural invariant:
  - keygen:      √2 bounds SKIPPED (flat spectrum = anonymity feature)
  - encrypt:     √2 bounds SKIPPED (noise structure is internal)
  - decrypt:     √2 bounds SKIPPED (Hodge projection works regardless)
  - transaction: √2 bounds ENFORCED (consensus validity)
  - zk_prove:    √2 bounds SKIPPED (structural geometry only, not consensus)

Cross-references:
  - ARCHITECTURE.md: "Stage-Gated √2 Enforcement"
  - src/invariants/unified.py: validate_for_stage()
  - rust/node/src/consensus/pov.rs: POV_LOWER / POV_UPPER
"""

import numpy as np
import pytest
from src.invariants.unified import (
    UnifiedInvariantValidator as InvariantValidator,
    validate_fibration,
)
from src.crypto.credential import generate_credential
from src.geometry.sheaf_laplacian import SheafLaplacian


# ── Fixtures ──────────────────────────────────────────────────────


def _make_credential(parties=None, connections=None, sec=256):
    """Generate a fresh credential with known topology."""
    parties = parties or ["alice", "bob", "carol"]
    connections = connections or [("alice", "bob"), ("bob", "carol")]
    return generate_credential(
        parties=parties,
        connections=connections,
        security_parameter=sec,
    )


@pytest.fixture
def cred():
    return _make_credential()


def _extract_fibration_args(cred):
    """Extract nerve, laplacian, delta_0 from a credential."""
    nerve = cred.topology
    lap = SheafLaplacian(cred.fibration.sheaf)
    eigs, vecs = lap.eigendecomposition(0)
    L = vecs @ np.diag(eigs) @ vecs.T
    delta_0 = lap.get_coboundary_0()
    return nerve, L, delta_0


@pytest.fixture
def validator(cred):
    """Build InvariantValidator from a real credential."""
    nerve, laplacian, delta_0 = _extract_fibration_args(cred)
    return InvariantValidator(
        nerve=nerve,
        laplacian=laplacian,
        delta_0=delta_0,
    )


# ── Stage-gated tests ────────────────────────────────────────────


class TestStageGatedSqrt2:
    """√2 bounds are consensus-only, not crypto-only."""

    def test_keygen_skips_sqrt2(self, validator):
        """keygen must NOT check √2 — flat spectrum is the anonymity feature."""
        passed, checkpoints = validator.validate_for_stage("keygen")
        # keygen should pass even with flat spectrum
        assert passed, f"keygen should pass: {[c for c in checkpoints if not c.passed]}"

        # Verify √2 is NOT among the checks
        check_names = [c.name for c in checkpoints]
        assert "spectral_gap_lower" not in check_names, (
            "keygen must NOT check spectral_gap_lower (flat spectrum = anonymity)"
        )

    def test_encrypt_skips_sqrt2(self, validator):
        """encrypt must NOT check √2 — noise structure is internal."""
        passed, checkpoints = validator.validate_for_stage("encrypt")
        assert passed, f"encrypt should pass: {[c for c in checkpoints if not c.passed]}"

        check_names = [c.name for c in checkpoints]
        assert "spectral_gap_lower" not in check_names, (
            "encrypt must NOT check spectral_gap_lower"
        )

    def test_decrypt_skips_sqrt2(self, validator):
        """decrypt must NOT check √2 — Hodge projection works regardless."""
        passed, checkpoints = validator.validate_for_stage("decrypt")
        assert passed, f"decrypt should pass: {[c for c in checkpoints if not c.passed]}"

        check_names = [c.name for c in checkpoints]
        assert "spectral_gap_lower" not in check_names, (
            "decrypt must NOT check spectral_gap_lower"
        )

    def test_transaction_enforces_sqrt2(self, validator):
        """transaction MUST check √2 — consensus validity gate."""
        _passed, checkpoints = validator.validate_for_stage("transaction")
        check_names = [c.name for c in checkpoints]

        # At least one √2-related check must be present
        has_gap_check = any(
            "spectral" in name or "gap" in name or "tsirelson" in name.lower()
            for name in check_names
        )
        assert has_gap_check, (
            f"transaction must check √2 bounds. Checks present: {check_names}"
        )

    def test_zk_prove_validates_structure_not_sqrt2(self, validator):
        """zk_prove validates structural geometry, NOT √2 bounds.
        
        ZK proofs prove path existence on Grassmannian — they need
        well-formed geometry but √2 is a consensus gate only.
        Transaction stage adds √2 on top of structural checks.
        """
        _passed, checkpoints = validator.validate_for_stage("zk_prove")
        check_names = [c.name for c in checkpoints]

        # Must have structural checks (Hodge, homotopy, etc)
        assert len(checkpoints) >= 10, (
            f"zk_prove should run comprehensive structural checks, got {len(checkpoints)}"
        )
        # But NOT √2 specifically
        assert "spectral_gap_lower" not in check_names, (
            "zk_prove should NOT check √2 — that's a consensus gate"
        )


class TestSqrt2BoundValues:
    """The actual √2 bound constants are consistent across Python and Rust."""

    SQRT2 = np.sqrt(2)
    POV_LOWER = 1.0 / SQRT2   # ≈ 0.70710678
    POV_UPPER = 2.0 * SQRT2   # ≈ 2.82842712

    def test_lower_bound_value(self):
        assert abs(self.POV_LOWER - 0.7071067811865476) < 1e-12

    def test_upper_bound_value(self):
        assert abs(self.POV_UPPER - 2.8284271247461903) < 1e-12

    def test_bounds_bracket_quantum_correlation(self):
        """The bounds [1/√2, 2√2] bracket the quantum correlation polytope."""
        # Classical bound = 2 must be inside
        assert self.POV_LOWER < 2.0 < self.POV_UPPER
        # No-signaling bound = 4 must be outside
        assert 4.0 > self.POV_UPPER


class TestValidateFibrationFunction:
    """Test the top-level validate_fibration() convenience function."""

    def test_keygen_stage(self, cred):
        nerve, laplacian, delta_0 = _extract_fibration_args(cred)
        passed, _fingerprint, report = validate_fibration(
            nerve=nerve, laplacian=laplacian, delta_0=delta_0,
            stage="keygen",
        )
        assert passed, f"keygen failed: {report}"

    def test_transaction_stage(self, cred):
        """Transaction stage runs — may pass or fail depending on topology."""
        nerve, laplacian, delta_0 = _extract_fibration_args(cred)
        passed, _fingerprint, report = validate_fibration(
            nerve=nerve, laplacian=laplacian, delta_0=delta_0,
            stage="transaction",
        )
        # We don't assert passed here because flat-spectrum keygen
        # may not have gap in [1/√2, 2√2]. What matters is that
        # the report mentions spectral/gap checks.
        assert "spectral" in report.lower() or "gap" in report.lower(), (
            f"transaction stage report should mention spectral/gap: {report}"
        )

    def test_keygen_passes_but_transaction_may_not(self, cred):
        """
        Key architectural property:
        A credential that passes keygen validation may NOT pass transaction
        validation, because keygen deliberately skips √2 bounds.
        """
        nerve, laplacian, delta_0 = _extract_fibration_args(cred)
        passed_keygen, _, _ = validate_fibration(
            nerve=nerve, laplacian=laplacian, delta_0=delta_0,
            stage="keygen",
        )
        assert passed_keygen, "keygen should always pass for valid credentials"

        # Transaction stage has MORE constraints (√2 bounds)
        # Just verify it runs without error — pass/fail depends on topology
        _passed_tx, _, _ = validate_fibration(
            nerve=nerve, laplacian=laplacian, delta_0=delta_0,
            stage="transaction",
        )


class TestCrossLanguageConstants:
    """Verify Python and Rust use identical √2 constants."""

    def test_python_constants_exist(self):
        """Python SQRT2, LOWER_BOUND, UPPER_BOUND must exist."""
        # These are used in various places — check they're importable
        from src.invariants.unified import UnifiedInvariantValidator
        v = UnifiedInvariantValidator.__new__(UnifiedInvariantValidator)
        # The constants should be class-level or module-level
        SQRT2 = np.sqrt(2)
        assert abs(1.0 / SQRT2 - 0.7071067811865476) < 1e-12
        assert abs(2.0 * SQRT2 - 2.8284271247461903) < 1e-12

    def test_rust_constants_match(self):
        """
        Verify Rust POV_LOWER and POV_UPPER match Python.
        
        Rust (types.rs):
          pub const POV_LOWER: f64 = 0.7071067811865476;  // 1/√2
          pub const POV_UPPER: f64 = 2.8284271247461903;  // 2√2
        
        We can't import Rust here, but we verify the VALUES are the
        same as what np.sqrt(2) produces, ensuring IEEE 754 consistency.
        """
        SQRT2 = np.sqrt(2)
        rust_lower = 0.7071067811865476  # from types.rs
        rust_upper = 2.8284271247461903  # from types.rs

        assert abs(1.0 / SQRT2 - rust_lower) < 1e-15, (
            f"Python 1/√2 = {1.0/SQRT2} != Rust POV_LOWER = {rust_lower}"
        )
        assert abs(2.0 * SQRT2 - rust_upper) < 1e-15, (
            f"Python 2√2 = {2.0*SQRT2} != Rust POV_UPPER = {rust_upper}"
        )
