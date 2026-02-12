"""
Fixed-Point Spectral Gap Bounds — Canonical Source

PROBLEM:
  Spectral gaps are computed via float64 eigendecomposition.
  Different machines (LAPACK versions, CPU architectures) can produce
  slightly different eigenvalues at boundary values. If Node A computes
  gap = 0.70710678118654752 (just above 1/√2) and Node B computes
  gap = 0.70710678118654748 (just below), they disagree on block validity.

SOLUTION:
  1. CANONICAL BOUNDS: defined here, imported everywhere (no redundant definitions)
  2. FIXED-POINT REPRESENTATION: quantize gap to int64 (32-bit fractional precision)
     All comparisons on integers — no floating-point ambiguity.
  3. TOLERANCE BAND: values within ε of boundaries are flagged as MARGINAL.
     Marginal values pass structural checks but trigger recomputation request.

FIXED-POINT FORMAT:
  gap_fixed = round(gap * PRECISION)
  PRECISION = 2^32 (4,294,967,296)

  This gives ~9 decimal digits of precision, which is more than enough
  for eigenvalue comparisons (float64 has ~15 digits, but LAPACK only
  guarantees ~12 in practice).

USAGE:
  from src.proofs.spectral_bounds import (
      gap_in_bounds, gap_to_fixed, GapStatus,
      SQRT2, POV_LOWER, POV_UPPER,
  )

  status = gap_in_bounds(some_gap)
  if status == GapStatus.VALID: ...
  elif status == GapStatus.MARGINAL: ...  # request recompute
  elif status == GapStatus.INVALID: ...   # reject

This module is the SINGLE SOURCE OF TRUTH for √2 bounds.
All other files should import from here.
"""

import numpy as np
from enum import Enum
from typing import Tuple


# =============================================================================
# CANONICAL CONSTANTS
# =============================================================================

SQRT2: float = np.sqrt(2)

# Tsirelson bounds for PoV consensus
POV_LOWER: float = 1.0 / SQRT2   # ≈ 0.7071067811865476
POV_UPPER: float = 2.0 * SQRT2   # ≈ 2.8284271247461903

# =============================================================================
# FIXED-POINT REPRESENTATION
# =============================================================================

FIXED_PRECISION: int = 2**32

POV_LOWER_FIXED: int = round(POV_LOWER * FIXED_PRECISION)
POV_UPPER_FIXED: int = round(POV_UPPER * FIXED_PRECISION)

TOLERANCE: float = 1e-8
TOLERANCE_FIXED: int = round(TOLERANCE * FIXED_PRECISION)


def gap_to_fixed(gap: float) -> int:
    """Convert float64 spectral gap to fixed-point integer."""
    return round(gap * FIXED_PRECISION)


def fixed_to_gap(fixed: int) -> float:
    """Convert fixed-point integer back to float64."""
    return fixed / FIXED_PRECISION


# =============================================================================
# GAP STATUS
# =============================================================================

class GapStatus(Enum):
    """Status of a spectral gap relative to PoV bounds."""
    VALID = "valid"
    MARGINAL = "marginal"
    INVALID = "invalid"
    ZERO = "zero"


def gap_in_bounds(gap: float) -> GapStatus:
    """
    Check spectral gap against PoV bounds using fixed-point arithmetic.

    This is the CANONICAL bounds check. All other code should call this
    instead of doing `POV_LOWER <= gap <= POV_UPPER` with floats.
    """
    if gap <= 0:
        return GapStatus.ZERO

    g = gap_to_fixed(gap)

    if g < POV_LOWER_FIXED - TOLERANCE_FIXED:
        return GapStatus.INVALID
    if g > POV_UPPER_FIXED + TOLERANCE_FIXED:
        return GapStatus.INVALID

    if abs(g - POV_LOWER_FIXED) <= TOLERANCE_FIXED:
        return GapStatus.MARGINAL
    if abs(g - POV_UPPER_FIXED) <= TOLERANCE_FIXED:
        return GapStatus.MARGINAL

    return GapStatus.VALID


def gap_in_bounds_strict(gap: float) -> bool:
    """Strict bounds check: VALID or MARGINAL both pass."""
    status = gap_in_bounds(gap)
    return status in (GapStatus.VALID, GapStatus.MARGINAL)


def gap_in_bounds_float(gap: float) -> bool:
    """Legacy float comparison (backwards compatibility)."""
    return POV_LOWER <= gap <= POV_UPPER


# =============================================================================
# SERIALIZATION (deterministic across machines)
# =============================================================================

def serialize_gap(gap: float) -> bytes:
    """Serialize spectral gap as 8-byte fixed-point (deterministic)."""
    return gap_to_fixed(gap).to_bytes(8, 'little', signed=True)


def deserialize_gap(data: bytes) -> float:
    """Deserialize spectral gap from 8-byte fixed-point."""
    fixed = int.from_bytes(data[:8], 'little', signed=True)
    return fixed_to_gap(fixed)


# =============================================================================
# CREDENTIAL AGE / EXPIRY
# =============================================================================

CREDENTIAL_MIN_AGE_BLOCKS: int = 10
CREDENTIAL_MAX_AGE_BLOCKS: int = 100_000


def credential_age_valid(
    registration_height: int,
    current_height: int,
    min_age: int = CREDENTIAL_MIN_AGE_BLOCKS,
    max_age: int = CREDENTIAL_MAX_AGE_BLOCKS,
) -> Tuple[bool, str]:
    """
    Check if a credential is within valid age range.

    Prevents grinding (min_age) and long-range attacks (max_age).
    """
    age = current_height - registration_height

    if age < 0:
        return False, f"Credential from future"
    if age < min_age:
        return False, f"Credential too young: age {age} < min {min_age}"
    if max_age > 0 and age > max_age:
        return False, f"Credential expired: age {age} > max {max_age}"

    return True, f"Credential age valid: {age} blocks"
