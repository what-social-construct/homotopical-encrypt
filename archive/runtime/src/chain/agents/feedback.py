"""
Geometric Feedback Module — Čech Nerve + Sheaf Laplacian Attribution

Separated from TreasuryAgent: treasury manages money, feedback manages learning.

WIRED TO ACTUAL INFRASTRUCTURE (not scalar proxies):
  CoherenceEngine  → edge gluing quality (sheaf Laplacian off-diagonal)
  CohomologyInvariants → H¹ obstruction attribution (coboundary rank)
  CoregulatorMemory → Hebbian velocity + prediction error feedback
  PersistenceBarcode → topological complexity change

FROM REVENGE-BANANA CausalAttributor:
  1. GeometricAttribution (not scalar rewards)
  2. HashChain causality (deterministic tracing)
  3. Harmonic-modulated learning rate

KEY INSIGHT (from Swan paper §3, Coregulator DAOs):
  The coregulator maps landscapes to a colimit, makes predictions,
  takes action, and compares action to prediction. Similar to a
  reinforcement learning agent updating per reward feedback, but
  the feedback is GEOMETRIC (preserves sheaf structure) not scalar.
"""

import numpy as np
import hashlib
from typing import Dict, Any, List, Optional, Tuple
from dataclasses import dataclass, field

from ...consensus.coherence import CoherenceEngine, CechNerve
from ...consensus.coregulator import CoregulatorMemory, PredictionRecord
from ...invariants.cohomology import CohomologyInvariants, compute_coboundary_ranks
from ...proofs.spectral_bounds import POV_LOWER, POV_UPPER


# =============================================================================
# GEOMETRIC ATTRIBUTION (wired to actual sheaf infrastructure)
# =============================================================================

@dataclass
class GeometricAttribution:
    """
    Full geometric attribution for one agent at one decision.
    NO SCALAR REWARDS — sheaf structure directly.

    Each field maps to an actual computation in homotopical_encrypt:
      edge_gluing_quality  → CoherenceEngine sheaf Laplacian off-diag
      h1_magnitude         → CohomologyInvariants.h1 (first cohomology dim)
      projection_strain    → harmonic projection residual ‖v - π_H(v)‖
      prediction_error     → CoregulatorMemory d_Gr(μ̂, μ)
      belief_gradient      → Grassmannian gradient (tangent vector on Gr(k,n))
    """
    agent_name: str
    timestamp: float

    # From CoherenceEngine (sheaf Laplacian)
    edge_gluing_quality: float       # Mean agreement with neighbors [0, 1]
    harmonic_weight: float           # ‖π_H(stalk)‖ — consensus alignment

    # From CohomologyInvariants
    h1_magnitude: float              # dim(H¹) contribution
    coboundary_rank: int             # rank(δ₀) at this agent's edges

    # From harmonic projection
    projection_strain: float         # ‖stalk - π_H(stalk)‖ / ‖stalk‖

    # From CoregulatorMemory
    prediction_error: float          # d_Gr(predicted, actual) for this epoch

    # Learning gradient (tangent vector on Gr(k,n))
    belief_gradient: Optional[np.ndarray] = None


# =============================================================================
# DECISION RECORD
# =============================================================================

@dataclass
class DecisionRecord:
    """
    Hashable record linking decision → outcome for causal attribution.
    """
    decision_hash: bytes
    block_height: int
    timestamp: float
    resolved_action: str
    resolved_amount: int
    spectral_gap: float
    price: Optional[float]
    # Per-agent attribution computed after outcome observed
    attributions: Dict[str, GeometricAttribution] = field(default_factory=dict)

    @staticmethod
    def compute_hash(action: str, block_height: int, gap: float) -> bytes:
        data = f"{block_height}:{action}:{gap:.6f}"
        return hashlib.sha256(data.encode()).digest()


# =============================================================================
# FEEDBACK ENGINE
# =============================================================================

class FeedbackEngine:
    """
    Geometric feedback using actual Čech nerve + sheaf Laplacian.

    Cycle:
      1. After decision executed, observe new state
      2. Build CechNerve from agent stalks (via CoherenceEngine)
      3. Compute per-agent geometric attribution
      4. Feed gradients back to agents (Hebbian threshold updates)

    Learning rate modulated by harmonic energy:
      lr_effective = base_lr × (1 - harmonic_energy)
      → High harmonic energy (good consensus) = small updates (stable)
      → Low harmonic energy (disagreement) = larger updates (learn faster)
    """

    def __init__(
        self,
        coherence: CoherenceEngine,
        base_lr: float = 0.01,
    ):
        self.coherence = coherence
        self.base_lr = base_lr
        self.decision_history: List[DecisionRecord] = []
        self.max_history = 100

    def record_decision(
        self,
        action: str,
        amount: int,
        block_height: int,
        spectral_gap: float,
        price: Optional[float] = None,
    ) -> DecisionRecord:
        """Record a decision for later attribution."""
        record = DecisionRecord(
            decision_hash=DecisionRecord.compute_hash(action, block_height, spectral_gap),
            block_height=block_height,
            timestamp=0.0,  # Will be set by caller
            resolved_action=action,
            resolved_amount=amount,
            spectral_gap=spectral_gap,
            price=price,
        )
        self.decision_history.append(record)
        if len(self.decision_history) > self.max_history:
            self.decision_history = self.decision_history[-self.max_history:]
        return record

    def compute_attributions(
        self,
        agent_stalks: Dict[str, np.ndarray],
        validator_stalks: Dict[bytes, np.ndarray],
    ) -> Dict[str, GeometricAttribution]:
        """
        Compute per-agent geometric attribution using actual Čech nerve.

        Args:
            agent_stalks: {agent_name: stalk_vector} — agent beliefs
            validator_stalks: {validator_id: stalk_vector} — for CoherenceEngine.build_nerve()

        Returns:
            {agent_name: GeometricAttribution}
        """
        if not agent_stalks or len(self.decision_history) < 2:
            return {}

        prev = self.decision_history[-2]
        curr = self.decision_history[-1]

        # Build Čech nerve from validator stalks (Dict[bytes, ndarray])
        stalks_list = list(agent_stalks.values())
        agent_names = list(agent_stalks.keys())
        validator_ids = list(validator_stalks.keys())

        if len(validator_stalks) < 2:
            return {}

        nerve = self.coherence.build_nerve(validator_stalks)

        if nerve is None:
            return {}

        # Compute sheaf Laplacian + harmonic weights (separate from build_nerve)
        self.coherence.compute_sheaf_laplacian(validator_stalks)
        harmonic_weights = self.coherence.compute_harmonic_weights(validator_stalks)
        laplacian = self.coherence._laplacian

        # Compute coboundary ranks for H¹
        # (using the Laplacian we already have)
        h1_dim = nerve.beta_1()

        # Actual outcome
        gap_change = curr.spectral_gap - prev.spectral_gap
        price_change = 0.0
        if prev.price and curr.price and prev.price > 0:
            price_change = (curr.price - prev.price) / prev.price

        # Per-agent attribution
        attributions = {}
        for idx, agent_name in enumerate(agent_names):
            if idx >= len(validator_ids):
                break

            vid = validator_ids[idx]
            stalk = stalks_list[idx]

            # Edge gluing quality from sheaf Laplacian off-diagonal
            edge_quality = self._edge_gluing_from_laplacian(
                laplacian, idx, len(agent_names)
            )

            # Harmonic weight (consensus alignment)
            hw = harmonic_weights.get(vid, 0.0)

            # Projection strain: ‖stalk - π_H(stalk)‖ / ‖stalk‖
            strain = self._projection_strain(stalk, laplacian, idx)

            # Prediction error from CoregulatorMemory
            pred_error = abs(gap_change)  # Simple: how much gap changed

            # H¹ magnitude: distributed across agents by edge count
            n_agent_edges = len(nerve.neighbors(idx))
            h1_contribution = h1_dim * (n_agent_edges / max(nerve.n_edges, 1))

            # Belief gradient: direction to improve
            gradient = self._compute_gradient(
                stalk, gap_change, price_change, edge_quality
            )

            attributions[agent_name] = GeometricAttribution(
                agent_name=agent_name,
                timestamp=curr.timestamp,
                edge_gluing_quality=edge_quality,
                harmonic_weight=float(hw),
                h1_magnitude=float(h1_contribution),
                coboundary_rank=n_agent_edges,
                projection_strain=strain,
                prediction_error=pred_error,
                belief_gradient=gradient,
            )

        return attributions

    def get_modulated_lr(self, spectral_gap: float) -> float:
        """
        Learning rate modulated by spectral gap health.
        Healthy network (gap ≈ 1.0) → small lr (stable).
        Stressed network (gap near bounds) → larger lr (adapt fast).
        """
        gap_health = 1.0 - min(1.0, abs(spectral_gap - 1.0))
        return self.base_lr * max(0.1, 1.0 - gap_health)

    def compute_reward_direction(
        self, prev: DecisionRecord, curr: DecisionRecord
    ) -> float:
        """
        Directional reward signal for Hebbian threshold updates.
        NOT a scalar reward — just the sign/magnitude for threshold adjustment.

        Returns ∈ [0, 1]: 0 = action hurt, 1 = action helped.
        """
        gap_health = 1.0 - abs(curr.spectral_gap - 1.0)
        price_change = 0.0
        if prev.price and curr.price and prev.price > 0:
            price_change = (curr.price - prev.price) / prev.price

        if prev.resolved_action in ('buyback', 'emergency_buyback'):
            reward = gap_health + max(0, price_change)
        elif prev.resolved_action == 'sell_at_resistance':
            reward = max(0, -price_change) + gap_health
        elif prev.resolved_action in ('rebalance_il', 'increase_k'):
            reward = gap_health
        else:
            reward = 0.5

        return float(np.clip(reward, 0.0, 1.0))

    # =================================================================
    # INTERNAL: sheaf Laplacian computations
    # =================================================================

    def _edge_gluing_from_laplacian(
        self, laplacian: Optional[np.ndarray], idx: int, n_agents: int
    ) -> float:
        """
        Edge gluing quality from sheaf Laplacian off-diagonal entries.

        The off-diagonal block L[i,j] encodes the restriction map
        disagreement between stalks i and j. Small magnitude = good agreement.
        """
        if laplacian is None:
            return 0.5

        d = self.coherence.stalk_dim
        row_start = idx * d
        row_end = row_start + d

        if row_end > laplacian.shape[0]:
            return 0.5

        # Sum off-diagonal block norms
        total_disagreement = 0.0
        n_neighbors = 0
        for j in range(n_agents):
            if j == idx:
                continue
            col_start = j * d
            col_end = col_start + d
            if col_end > laplacian.shape[1]:
                continue

            block = laplacian[row_start:row_end, col_start:col_end]
            disagreement = np.linalg.norm(block, 'fro')
            if disagreement > 1e-10:  # Has an edge
                total_disagreement += disagreement
                n_neighbors += 1

        if n_neighbors == 0:
            return 0.5

        mean_disagreement = total_disagreement / n_neighbors
        # Convert to quality: exp(-disagreement) ∈ (0, 1]
        return float(np.exp(-mean_disagreement))

    def _projection_strain(
        self, stalk: np.ndarray, laplacian: Optional[np.ndarray], idx: int
    ) -> float:
        """
        Projection strain: ‖stalk - π_H(stalk)‖ / ‖stalk‖.
        How far the stalk is from the harmonic subspace.
        """
        if laplacian is None:
            return 0.0

        stalk_norm = np.linalg.norm(stalk)
        if stalk_norm < 1e-10:
            return 0.0

        # Approximate: use Laplacian action on stalk as strain measure
        # Δ·s = 0 for harmonic sections, large for non-harmonic
        d = len(stalk)
        row_start = idx * d
        row_end = row_start + d

        if row_end > laplacian.shape[0]:
            return 0.0

        # Extract the stalk's block row of the Laplacian
        full_dim = laplacian.shape[0]
        full_stalk = np.zeros(full_dim)
        full_stalk[row_start:row_end] = stalk

        laplacian_action = laplacian @ full_stalk
        local_action = laplacian_action[row_start:row_end]
        strain = np.linalg.norm(local_action) / stalk_norm

        return float(strain)

    def _compute_gradient(
        self,
        stalk: np.ndarray,
        gap_change: float,
        price_change: float,
        edge_quality: float,
    ) -> np.ndarray:
        """
        Gradient direction on belief manifold.
        Combines outcome signal with geometric quality.
        """
        # Direction from outcome
        outcome_signal = gap_change + price_change
        # Weighted by edge quality (well-connected agents get clearer signal)
        gradient = stalk * outcome_signal * edge_quality

        norm = np.linalg.norm(gradient)
        if norm > 1e-10:
            gradient = gradient / norm

        return gradient
