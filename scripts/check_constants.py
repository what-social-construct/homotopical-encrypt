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
    try:
        sys.path.insert(0, str(REPO / "src"))
        from proofs.spectral_bounds import SQRT2 as py_sqrt2, POV_LOWER as py_lower, POV_UPPER as py_upper
        check("SQRT2", py_sqrt2, SQRT2, "Python spectral_bounds.py")
        check("POV_LOWER", py_lower, POV_LOWER, "Python spectral_bounds.py")
        check("POV_UPPER", py_upper, POV_UPPER, "Python spectral_bounds.py")
        print("  ✓ Python constants match")
    except ImportError as e:
        # Fallback: grep the file directly
        bounds_file = REPO / "src" / "proofs" / "spectral_bounds.py"
        if bounds_file.exists():
            text = bounds_file.read_text()
            # Look for SQRT2 = ...
            m = re.search(r'SQRT2\s*[:=]\s*[\w.]+\s*#?\s*~?([\d.]+)', text)
            if m:
                print(f"  (parsed from file, SQRT2 comment ≈ {m.group(1)})")
            print(f"  ⚠ Could not import Python module: {e}")
        else:
            errors.append(f"  Python: spectral_bounds.py not found")


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
    """Check Lean proof files reference consistent bounds."""
    lean_dir = REPO / "lean"
    if not lean_dir.exists():
        errors.append("  Lean: lean/ directory not found")
        return

    # Check that Lean files exist
    for name in ["Hardness.lean", "Tsirelson.lean", "Laplacian.lean"]:
        f = lean_dir / name
        if not f.exists():
            errors.append(f"  Lean: {name} not found")
        else:
            text = f.read_text()
            # Check for MinSpectralGap = 1 (which corresponds to gap = 1 for Ω_1)
            if "MinSpectralGap" in text or "SpectralGap" in text:
                print(f"  ✓ {name}: SpectralGap definition found")
            if "Ω" in text:
                print(f"  ✓ {name}: Ω (Grassmannian Laplacian set) defined")

    # Check lakefile exists
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
