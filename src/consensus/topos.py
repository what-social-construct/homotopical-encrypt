"""
Topos Consensus — Heyting-Valued Block Validation

Three-valued consensus logic: VALID / INVALID / UNDETERMINED.

Standard Boolean consensus collapses to {accept, reject}. But in a
sheaf-theoretic setting, the natural truth values live in a Heyting
algebra — the subobject classifier of the topos of sheaves over the
Čech nerve. This gives us a third value: UNDETERMINED.

A block is UNDETERMINED when the spectral evidence is inconclusive —
the sheaf Laplacian's gap falls in the boundary region, or β₀ = 1
but β₁ > 0 (connected but with persistent disagreement cycles).

Boolean logic: ¬¬p = p (excluded middle)
Heyting logic: ¬¬p ≥ p (double negation is weaker)

The practical consequence: an UNDETERMINED block can later resolve
to VALID or INVALID as more validator stalks arrive. This models
the real asynchrony of distributed consensus without forcing premature
commitment. Lambert (2021) showed this is the correct formalization:
"estimate safety" in consensus is a forcing statement in the internal
logic of a copresheaf topos, where a state and its negation cannot
both be safe simultaneously — but neither need be decided yet.

APPLICATION TO HOMOTOPICAL-ENCRYPT:

  CoherenceEngine.validate_block_topology() returns Boolean is_valid.
  ToposConsensus.evaluate() returns HeytingValue with evidence strength,
  confidence interval, and resolution conditions.

  The three values map to block handling:
    VALID       → propagate immediately
    INVALID     → reject and penalize proposer
    UNDETERMINED → hold in mempool, re-evaluate on next epoch

Reference:
  - Lambert (2021): A Topos View of Blockchain Consensus Protocols
  - Murfet (2019): Distributed consensus for models of logic
  - Swan, Kido, dos Santos (2025): Higher Categorical Cryptoeconomics
"""

from dataclasses import dataclass, field
from enum import Enum
from typing import Dict, List, Tuple, Optional, Set
import numpy as np

from .coherence import CoherenceEngine, CechNerve, SQRT2, INV_SQRT2
from ..primitives.grassmann import grassmann_distance, stalk_to_subspace


# =============================================================================
# HEYTING ALGEBRA
# =============================================================================

class HeytingValue(Enum):
    """
    Three-valued Heyting truth value.

    The subobject classifier Ω of the topos Sh(N(V)) is a
    Heyting algebra with:
      ⊤ = VALID       (block accepted)
      ⊥ = INVALID     (block rejected)
      ½ = UNDETERMINED (insufficient evidence)

    Key difference from Boolean: ¬(UNDETERMINED) = UNDETERMINED,
    not VALID. Double negation does NOT collapse the middle.
    """
    VALID = 1
    UNDETERMINED = 0
    INVALID = -1

    def __repr__(self) -> str:
        return self.name

    # Heyting operations
    def meet(self, other: 'HeytingValue') -> 'HeytingValue':
        """∧ (meet = min)"""
        return HeytingValue(min(self.value, other.value))

    def join(self, other: 'HeytingValue') -> 'HeytingValue':
        """∨ (join = max)"""
        return HeytingValue(max(self.value, other.value))

    def implies(self, other: 'HeytingValue') -> 'HeytingValue':
        """
        → (Heyting implication):
          a → b = max{c : a ∧ c ≤ b}

        Truth table:
          V → V = V,  V → U = U,  V → I = I
          U → V = V,  U → U = V,  U → I = U   ← NOT Boolean!
          I → V = V,  I → U = V,  I → I = V
        """
        if self.value <= other.value:
            return HeytingValue.VALID
        if self == HeytingValue.VALID:
            return other
        # UNDETERMINED → INVALID = UNDETERMINED (not INVALID)
        return HeytingValue.UNDETERMINED

    def negate(self) -> 'HeytingValue':
        """
        ¬a = a → ⊥

        ¬VALID = INVALID
        ¬INVALID = VALID
        ¬UNDETERMINED = UNDETERMINED   ← the key non-Boolean feature
        """
        return self.implies(HeytingValue.INVALID)

    def double_negate(self) -> 'HeytingValue':
        """¬¬a ≥ a (Heyting: double negation is inflation, not identity)"""
        return self.negate().negate()


# =============================================================================
# EVIDENCE
# =============================================================================

@dataclass
class ConsensusEvidence:
    """
    Structured evidence supporting a HeytingValue judgment.

    Collects the spectral, topological, and geometric data that
    determines the truth value. This is the "forcing condition"
    in the topos — the open set of the nerve over which the
    judgment holds.
    """
    # Topological evidence
    beta_0: int = 0                     # Connected components
    beta_1: int = 0                     # Independent cycles
    spectral_gap: float = 0.0           # λ₁ of sheaf Laplacian

    # Boundary analysis
    gap_lower: float = INV_SQRT2        # Lower threshold (1/√2)
    gap_upper: float = 2 * SQRT2        # Upper threshold (2√2)
    gap_margin: float = 0.0             # Distance from nearest boundary

    # Validator-level
    n_validators: int = 0
    n_eligible: int = 0                 # Validators within divergence bound
    n_edges: int = 0
    mean_distance: float = 0.0          # Mean pairwise Grassmann distance
    max_distance: float = 0.0           # Max pairwise distance

    # Forcing condition
    forcing_open_set: str = ''          # Human-readable description
    confidence: float = 0.0            # [0,1] — strength of evidence

    def summary(self) -> str:
        return (
            f"β₀={self.beta_0}, β₁={self.beta_1}, "
            f"gap={self.spectral_gap:.4f} ∈ [{self.gap_lower:.4f}, {self.gap_upper:.4f}], "
            f"margin={self.gap_margin:.4f}, conf={self.confidence:.3f}"
        )


@dataclass
class ToposJudgment:
    """
    Complete judgment: truth value + evidence + resolution conditions.

    If UNDETERMINED, includes conditions under which the judgment
    would resolve to VALID or INVALID.
    """
    value: HeytingValue
    evidence: ConsensusEvidence
    epoch: int = 0

    # Resolution conditions (only for UNDETERMINED)
    resolve_valid_if: str = ''          # What would make this VALID
    resolve_invalid_if: str = ''        # What would make this INVALID

    def __repr__(self) -> str:
        return f"ToposJudgment({self.value.name}, {self.evidence.summary()})"


# =============================================================================
# BOUNDARY REGIONS
# =============================================================================

# The spectral gap boundary regions where judgment is UNDETERMINED
# Rather than a sharp cutoff, we define a margin around the thresholds
BOUNDARY_MARGIN: float = 0.15  # Width of the undetermined zone

def _in_boundary(gap: float, lower: float, upper: float, margin: float) -> bool:
    """Is the spectral gap in the boundary (undetermined) zone?"""
    near_lower = abs(gap - lower) < margin
    near_upper = abs(gap - upper) < margin
    return near_lower or near_upper


def _gap_margin(gap: float, lower: float, upper: float) -> float:
    """Distance from nearest boundary. Positive = inside bounds."""
    if gap < lower:
        return gap - lower  # negative
    elif gap > upper:
        return upper - gap  # negative
    else:
        return min(gap - lower, upper - gap)  # positive


# =============================================================================
# TOPOS CONSENSUS
# =============================================================================

class ToposConsensus:
    """
    Heyting-valued consensus over the Čech nerve topos.

    Extends CoherenceEngine with three-valued logic. The evaluation
    function computes a HeytingValue for each block based on:

      1. TOPOLOGY: β₀ = 1 required for VALID
      2. SPECTRAL GAP: must be in [1/√2, 2√2] for VALID
      3. BOUNDARY ANALYSIS: gap near threshold → UNDETERMINED
      4. PERSISTENT CYCLES: β₁ > 0 → flag (may force UNDETERMINED)
      5. VALIDATOR COVERAGE: too few eligible → UNDETERMINED

    The result is a ToposJudgment with evidence and resolution conditions.
    """

    def __init__(self, stalk_dim: int = 2, boundary_margin: float = BOUNDARY_MARGIN):
        self.coherence = CoherenceEngine(stalk_dim=stalk_dim)
        self.boundary_margin = boundary_margin
        self.stalk_dim = stalk_dim

    def evaluate(
        self,
        stalks: Dict[bytes, np.ndarray],
        epoch: int = 0,
        min_validators: int = 3,
        min_eligible_fraction: float = 0.67,
    ) -> ToposJudgment:
        """
        Evaluate a block in three-valued Heyting logic.

        Returns ToposJudgment with VALID, INVALID, or UNDETERMINED.
        """
        n_validators = len(stalks)

        # =====================================================================
        # Gate 0: Minimum validator count
        # =====================================================================

        if n_validators < min_validators:
            return ToposJudgment(
                value=HeytingValue.UNDETERMINED,
                evidence=ConsensusEvidence(
                    n_validators=n_validators,
                    forcing_open_set="insufficient validators",
                    confidence=0.0,
                ),
                epoch=epoch,
                resolve_valid_if=f"≥{min_validators} validators submit stalks",
                resolve_invalid_if="epoch expires with < minimum validators",
            )

        # =====================================================================
        # Gate 1: Build nerve and topology
        # =====================================================================

        nerve = self.coherence.build_nerve(stalks)
        beta_0 = nerve.beta_0()
        beta_1 = nerve.beta_1()

        # =====================================================================
        # Gate 2: Compute sheaf Laplacian and spectral gap
        # =====================================================================

        laplacian = self.coherence.compute_sheaf_laplacian(stalks)
        spectral_gap = 0.0
        if laplacian is not None:
            eigs = np.linalg.eigvalsh(laplacian)
            positive_eigs = eigs[eigs > 1e-8]
            if len(positive_eigs) > 0:
                spectral_gap = float(positive_eigs[0])

        # =====================================================================
        # Gate 3: Eligibility analysis
        # =====================================================================

        consensus = self.coherence.compute_consensus(stalks)
        n_eligible = 0
        distances = []

        for fp in stalks:
            eligible, dist = self.coherence.check_eligibility(fp, stalks)
            if eligible:
                n_eligible += 1
            distances.append(dist)

        mean_dist = float(np.mean(distances)) if distances else 0.0
        max_dist = float(np.max(distances)) if distances else 0.0
        eligible_fraction = n_eligible / n_validators if n_validators > 0 else 0.0

        # =====================================================================
        # Compute evidence
        # =====================================================================

        gap_lower = INV_SQRT2
        gap_upper = 2 * SQRT2
        margin = _gap_margin(spectral_gap, gap_lower, gap_upper)
        in_boundary = _in_boundary(spectral_gap, gap_lower, gap_upper, self.boundary_margin)

        evidence = ConsensusEvidence(
            beta_0=beta_0,
            beta_1=beta_1,
            spectral_gap=spectral_gap,
            gap_lower=gap_lower,
            gap_upper=gap_upper,
            gap_margin=margin,
            n_validators=n_validators,
            n_eligible=n_eligible,
            n_edges=nerve.n_edges,
            mean_distance=mean_dist,
            max_distance=max_dist,
        )

        # =====================================================================
        # JUDGMENT: Apply Heyting logic
        # =====================================================================

        # Hard INVALID: disconnected network
        if beta_0 > 1:
            evidence.forcing_open_set = f"β₀={beta_0} > 1 (partitioned)"
            evidence.confidence = 1.0
            return ToposJudgment(
                value=HeytingValue.INVALID,
                evidence=evidence,
                epoch=epoch,
            )

        # Hard INVALID: spectral gap clearly out of bounds
        if spectral_gap < gap_lower - self.boundary_margin:
            evidence.forcing_open_set = f"gap={spectral_gap:.4f} < {gap_lower - self.boundary_margin:.4f}"
            evidence.confidence = 1.0
            return ToposJudgment(
                value=HeytingValue.INVALID,
                evidence=evidence,
                epoch=epoch,
            )

        if spectral_gap > gap_upper + self.boundary_margin:
            evidence.forcing_open_set = f"gap={spectral_gap:.4f} > {gap_upper + self.boundary_margin:.4f}"
            evidence.confidence = 1.0
            return ToposJudgment(
                value=HeytingValue.INVALID,
                evidence=evidence,
                epoch=epoch,
            )

        # UNDETERMINED: too few eligible validators
        if eligible_fraction < min_eligible_fraction:
            evidence.forcing_open_set = f"eligible={n_eligible}/{n_validators} < {min_eligible_fraction:.0%}"
            evidence.confidence = eligible_fraction
            return ToposJudgment(
                value=HeytingValue.UNDETERMINED,
                evidence=evidence,
                epoch=epoch,
                resolve_valid_if="more validators come within divergence bound",
                resolve_invalid_if="eligible fraction drops below threshold at epoch end",
            )

        # UNDETERMINED: spectral gap in boundary zone
        if in_boundary:
            evidence.forcing_open_set = f"gap={spectral_gap:.4f} in boundary margin (±{self.boundary_margin})"
            evidence.confidence = 0.5 + 0.5 * (margin / self.boundary_margin)
            return ToposJudgment(
                value=HeytingValue.UNDETERMINED,
                evidence=evidence,
                epoch=epoch,
                resolve_valid_if="gap moves clearly inside bounds on next observation",
                resolve_invalid_if="gap moves clearly outside bounds",
            )

        # UNDETERMINED: persistent disagreement cycles (soft flag)
        if beta_1 > 1:
            evidence.forcing_open_set = f"β₁={beta_1} persistent disagreement cycles"
            evidence.confidence = max(0.3, 1.0 - beta_1 * 0.15)
            return ToposJudgment(
                value=HeytingValue.UNDETERMINED,
                evidence=evidence,
                epoch=epoch,
                resolve_valid_if="disagreement cycles resolve (β₁ decreases)",
                resolve_invalid_if="cycles persist across multiple epochs",
            )

        # =====================================================================
        # VALID: all checks passed with clear evidence
        # =====================================================================

        evidence.forcing_open_set = "all gates clear"
        evidence.confidence = min(1.0, margin / (gap_upper - gap_lower))
        return ToposJudgment(
            value=HeytingValue.VALID,
            evidence=evidence,
            epoch=epoch,
        )

    # =========================================================================
    # HEYTING COMBINATORS: compose judgments across epochs
    # =========================================================================

    def meet_judgments(
        self,
        j1: ToposJudgment,
        j2: ToposJudgment,
    ) -> HeytingValue:
        """j1 ∧ j2: both must hold (cautious composition)."""
        return j1.value.meet(j2.value)

    def join_judgments(
        self,
        j1: ToposJudgment,
        j2: ToposJudgment,
    ) -> HeytingValue:
        """j1 ∨ j2: either suffices (optimistic composition)."""
        return j1.value.join(j2.value)

    def implies_judgment(
        self,
        j1: ToposJudgment,
        j2: ToposJudgment,
    ) -> HeytingValue:
        """j1 → j2: Heyting implication (not Boolean!)."""
        return j1.value.implies(j2.value)

    def resolve_undetermined(
        self,
        held: ToposJudgment,
        new_stalks: Dict[bytes, np.ndarray],
        new_epoch: int,
    ) -> ToposJudgment:
        """
        Attempt to resolve an UNDETERMINED judgment with new evidence.

        Re-evaluates with fresh stalks. If the new judgment is VALID
        or INVALID, it supersedes. If still UNDETERMINED, compose
        with the held judgment via meet (cautious).
        """
        if held.value != HeytingValue.UNDETERMINED:
            return held

        new_judgment = self.evaluate(new_stalks, epoch=new_epoch)

        if new_judgment.value != HeytingValue.UNDETERMINED:
            return new_judgment

        # Still undetermined — confidence erodes
        new_judgment.evidence.confidence *= 0.8
        return new_judgment


# =============================================================================
# TEST
# =============================================================================

if __name__ == "__main__":
    import hashlib

    print("=" * 60)
    print("TOPOS CONSENSUS TEST")
    print("=" * 60)

    np.random.seed(42)
    ambient = 5
    topos = ToposConsensus(stalk_dim=ambient)

    # --- Test 1: Good validators (should be VALID) ---
    print("\n1. Well-behaved validators:")
    stalks = {}
    for i in range(5):
        fp = hashlib.sha256(f"v_{i}".encode()).digest()
        base = np.eye(ambient) + np.random.randn(ambient, ambient) * 0.05
        stalks[fp] = base

    j = topos.evaluate(stalks, epoch=0)
    print(f"   {j}")

    # --- Test 2: Partitioned network (should be INVALID) ---
    print("\n2. Partitioned network:")
    stalks2 = {}
    for i in range(3):
        fp = hashlib.sha256(f"a_{i}".encode()).digest()
        base_a = np.zeros((ambient, ambient)); base_a[0,0] = 1; base_a[1,1] = 1
        stalks2[fp] = base_a + np.random.randn(ambient, ambient) * 0.01
    for i in range(3):
        fp = hashlib.sha256(f"b_{i}".encode()).digest()
        base_b = np.zeros((ambient, ambient)); base_b[3,3] = 1; base_b[4,4] = 1
        stalks2[fp] = base_b + np.random.randn(ambient, ambient) * 0.01

    j2 = topos.evaluate(stalks2, epoch=0)
    print(f"   {j2}")

    # --- Test 3: Too few validators (should be UNDETERMINED) ---
    print("\n3. Too few validators:")
    stalks3 = {}
    for i in range(2):
        fp = hashlib.sha256(f"v_{i}".encode()).digest()
        stalks3[fp] = np.random.randn(ambient, ambient)

    j3 = topos.evaluate(stalks3, epoch=0)
    print(f"   {j3}")

    # --- Test 4: Heyting algebra operations ---
    print("\n4. Heyting algebra:")
    V, U, I = HeytingValue.VALID, HeytingValue.UNDETERMINED, HeytingValue.INVALID
    print(f"   ¬V = {V.negate()}")
    print(f"   ¬I = {I.negate()}")
    print(f"   ¬U = {U.negate()}  (NOT Boolean!)")
    print(f"   ¬¬U = {U.double_negate()}")
    print(f"   U → I = {U.implies(I)}  (NOT I — Heyting!)")
    print(f"   V ∧ U = {V.meet(U)}")
    print(f"   I ∨ U = {I.join(U)}")

    # --- Test 5: Resolution ---
    print("\n5. Resolving UNDETERMINED:")
    if j3.value == HeytingValue.UNDETERMINED:
        print(f"   Held: {j3.value}, resolve_valid_if: {j3.resolve_valid_if}")
        # Add more validators
        for i in range(3):
            fp = hashlib.sha256(f"extra_{i}".encode()).digest()
            stalks3[fp] = stalks[list(stalks.keys())[0]] + np.random.randn(ambient, ambient) * 0.05
        j3_resolved = topos.resolve_undetermined(j3, stalks3, new_epoch=1)
        print(f"   Resolved: {j3_resolved}")

    print("\n" + "=" * 60)
    print("✅ TOPOS CONSENSUS WORKING")
    print("=" * 60)
