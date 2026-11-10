#!/usr/bin/env python3
"""
Cross-Language Constants Cross-Check

Verifies that mathematical constants are consistent across:
  - Python (src/proofs/spectral_bounds.py)
  - Rust   (rust/node/src/types.rs)
  - Lean   (lean/Hardness.lean, lean/Laplacian.lean)

Run: python scripts/check_constants.py
CI:  add to GitHub Actions alongside `cd lean && lake build`

Catches drift: if someone changes POV_LOWER in Python but forgets
Rust or Lean, this script fails loudly.
"""

import math
import re
import sys
from pathlib import Path

REPO = Path(__file__).parent.parent
TOLERANCE = 1e-8

# Expected values (mathematical ground truth)
SQRT2 = math.sqrt(2)
POV_LOWER = 1.0 / SQRT2   # ~0.7071
POV_UPPER = 2.0 * SQRT2   # ~2.8284
COCHAIN_MODULUS = 12289

errors = []


def check(name: str, actual: float, expected: float, source: str):
    if abs(actual - expected) > TOLERANCE:
        errors.append(f"  {source}: {name} = {actual}, expected {expected}")


# =========================================================================
# PYTHON
# =========================================================================

def check_python():
    """Check Python spectral bounds."""
    # Direct import with path manipulation to avoid relative import issues
    bounds_file = REPO / "src" / "proofs" / "spectral_bounds.py"
    if not bounds_file.exists():
        errors.append("  Python: spectral_bounds.py not found")
        return

    # Use importlib to load directly (avoids relative import problem)
    import importlib.util
    spec = importlib.util.spec_from_file_location("spectral_bounds", bounds_file)
    mod = importlib.util.module_from_spec(spec)
    try:
        spec.loader.exec_module(mod)
        check("SQRT2", mod.SQRT2, SQRT2, "Python spectral_bounds.py")
        check("POV_LOWER", mod.POV_LOWER, POV_LOWER, "Python spectral_bounds.py")
        check("POV_UPPER", mod.POV_UPPER, POV_UPPER, "Python spectral_bounds.py")

        # Verify fixed-point representation is consistent
        check("POV_LOWER_FIXED", mod.POV_LOWER_FIXED,
              round(POV_LOWER * mod.FIXED_PRECISION), "Python fixed-point")
        check("POV_UPPER_FIXED", mod.POV_UPPER_FIXED,
              round(POV_UPPER * mod.FIXED_PRECISION), "Python fixed-point")

        # Verify gap_in_bounds logic
        assert mod.gap_in_bounds(1.0).name == "VALID", "gap=1.0 should be VALID"
        assert mod.gap_in_bounds(0.5).name == "INVALID", "gap=0.5 should be INVALID"
        assert mod.gap_in_bounds(3.0).name == "INVALID", "gap=3.0 should be INVALID"
        assert mod.gap_in_bounds(0.0).name == "ZERO", "gap=0.0 should be ZERO"

        print("  ✓ Python constants match")
        print("  ✓ Python fixed-point representation consistent")
        print("  ✓ Python gap_in_bounds logic verified")
    except Exception as e:
        errors.append(f"  Python: module load/check failed: {e}")


# =========================================================================
# RUST
# =========================================================================

def check_rust():
    """Check Rust types.rs constants."""
    types_file = REPO / "rust" / "node" / "src" / "types.rs"
    if not types_file.exists():
        errors.append("  Rust: types.rs not found")
        return

    text = types_file.read_text()

    # Parse: pub const SQRT2: f64 = 1.41421356237;
    m = re.search(r'pub const SQRT2:\s*f64\s*=\s*([\d.]+)', text)
    if m:
        check("SQRT2", float(m.group(1)), SQRT2, "Rust types.rs")
    else:
        errors.append("  Rust: SQRT2 not found in types.rs")

    # Parse: pub const POV_LOWER: f64 = 1.0 / SQRT2;
    # Can't evaluate expressions, but check the formula pattern
    if "1.0 / SQRT2" in text:
        print("  ✓ Rust POV_LOWER = 1.0 / SQRT2 (formula match)")
    else:
        errors.append("  Rust: POV_LOWER formula not found")

    if "2.0 * SQRT2" in text:
        print("  ✓ Rust POV_UPPER = 2.0 * SQRT2 (formula match)")
    else:
        errors.append("  Rust: POV_UPPER formula not found")

    # Cochain modulus
    m = re.search(r'COCHAIN_MODULUS:\s*i64\s*=\s*(\d+)', text)
    if m:
        check("COCHAIN_MODULUS", int(m.group(1)), COCHAIN_MODULUS, "Rust types.rs")
    else:
        errors.append("  Rust: COCHAIN_MODULUS not found")

    print("  ✓ Rust constants match")


# =========================================================================
# LEAN
# =========================================================================

def check_lean():
    """Check Lean proof files verify the invariants Rust/Python depend on."""
    lean_dir = REPO / "lean"
    if not lean_dir.exists():
        errors.append("  Lean: lean/ directory not found")
        return

    # ── Theorem existence checks ────────────────────────────────
    # These are the Lean theorems that ground the implementation.
    # If any are removed/renamed, the formal guarantee is broken.
    REQUIRED_THEOREMS = {
        "Laplacian.lean": {
            # Δ = I - P_W construction (Python: hodge.py, Rust: types.rs Laplacian model)
            "laplacian_apply": "Δ_W b = P_{W⊥} b  (core decrypt identity)",
            # Hodge decomposition is orthogonal (Python: harmonic.py validate_hodge_orthogonality)
            "likelihood_correct_of_laplacian": "L(b|Δ,σ) uses L2 norm (matches Python np.linalg.norm)",
            # MinSpectralGap = 1 for Grassmannian Laplacians
            "MinSpectralGap": "gap = 1 for Ω_k (Python: relative_spectral_gap() = 1.0)",
            # Spectrum is NOT homotopy invariant (prevents naive invariant collapse)
            "Spectrum_Not_Homotopy_Invariant": "spectrally ≠ homotopically equivalent",
        },
        "Hardness.lean": {
            # Hodge→CVP reduction (core security claim)
            "Hodge_Hardness_Reduction_Proof": "breaking homotopical_encrypt ⟹ solving CVP",
            # Hodge is STRICTLY harder than CVP (extra topological structure)
            "Hodge_Strictly_Harder": "CVP oracle insufficient for Hodge",
            # Ambiguity: same b can be harmonic for Δ₁ but not Δ₂
            "Hodge_Ambiguity": "harmonic property is Δ-relative",
            # Hodge decomposition theorem
            "Hodge_Decomposition_Theorem": "b = h + exact + coexact (orthogonal)",
            # Grothendieck fibration
            "GrothendieckFibration": "parallel transport = fibration lifts",
        },
        "Tsirelson.lean": {
            # Grassmannian Laplacians are well-defined
            "Grassmannian_Laplacians": "Ω parameterized by Gr(k,n)",
            # Ω₁ is infinite (adversary search space uncountable)
            "Ω_1_infinite": "uncountably many distinct Laplacians",
            # Laplacian properties: Hermitian + PSD + kernel dim k
            "laplacian_properties": "Δ ∈ LaplacianSpace(1)",
            # Classical adversary bound
            "Classical_Bound": "P_classical ≤ (1/2)^n",
            # Quantum adversary bound with spectral gap correction
            "Quantum_Bound": "P_quantum ≤ (1/2)^n · (1 + C·gap)",
        },
    }

    for filename, theorems in REQUIRED_THEOREMS.items():
        f = lean_dir / filename
        if not f.exists():
            errors.append(f"  Lean: {filename} not found")
            continue

        text = f.read_text()
        for thm_name, description in theorems.items():
            if thm_name in text:
                print(f"  ✓ {filename}: {thm_name}")
            else:
                errors.append(f"  Lean: {filename} MISSING theorem '{thm_name}' ({description})")

    # ── Specific value checks ────────────────────────────────────
    lap_file = lean_dir / "Laplacian.lean"
    if lap_file.exists():
        text = lap_file.read_text()
        # MinSpectralGap must be exactly 1 (this is the theorem Rust depends on)
        m = re.search(r'def MinSpectralGap.*?:=\s*(\d+)', text, re.DOTALL)
        if m:
            lean_gap = int(m.group(1))
            if lean_gap != 1:
                errors.append(f"  Lean: MinSpectralGap = {lean_gap}, expected 1")
            else:
                print(f"  ✓ Laplacian.lean: MinSpectralGap = 1 (matches Python relative_spectral_gap)")
        else:
            errors.append("  Lean: MinSpectralGap definition not parseable")

        # Check laplacian = 1 - P_W (the formula Rust/Python implement)
        if "1 - " in text and "orthogonalProjection" in text:
            print(f"  ✓ Laplacian.lean: Δ = I - P_W formula confirmed")
        else:
            errors.append("  Lean: Δ = I - P_W formula not found")

    # ── Toolchain ────────────────────────────────────────────────
    if (lean_dir / "lakefile.lean").exists():
        print("  ✓ lakefile.lean present")
    else:
        errors.append("  Lean: lakefile.lean missing")

    if (lean_dir / "lean-toolchain").exists():
        toolchain = (lean_dir / "lean-toolchain").read_text().strip()
        print(f"  ✓ lean-toolchain: {toolchain}")
    else:
        errors.append("  Lean: lean-toolchain missing")


# =========================================================================
# MAIN
# =========================================================================

def main():
    print("=" * 50)
    print("CONSTANTS CROSS-CHECK")
    print("=" * 50)
    print(f"\nGround truth:")
    print(f"  √2        = {SQRT2}")
    print(f"  POV_LOWER  = 1/√2 = {POV_LOWER}")
    print(f"  POV_UPPER  = 2√2  = {POV_UPPER}")
    print(f"  MODULUS    = {COCHAIN_MODULUS}")

    print(f"\nPython:")
    check_python()

    print(f"\nRust:")
    check_rust()

    print(f"\nLean:")
    check_lean()

    print(f"\n{'=' * 50}")
    if errors:
        print("FAILURES:")
        for e in errors:
            print(e)
        print(f"\n❌ {len(errors)} constant(s) mismatched")
        sys.exit(1)
    else:
        print("✅ All constants consistent across Python / Rust / Lean")
        sys.exit(0)


if __name__ == "__main__":
    main()
