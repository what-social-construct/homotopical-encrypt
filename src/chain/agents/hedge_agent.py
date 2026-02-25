"""
Hedge Agent — IL Mitigation via Grassmannian Principal Angles

Analog of revenge-banana HedgeAgent, native to the sheaf framework.

MATH:
  IL between entry subspace W₀ and current subspace W₁ is measured by
  Grassmannian distance d_G(W₀, W₁) = √(Σ θᵢ²), where θᵢ are the
  k principal angles between the two subspaces.

  This is FINER than the standard IL formula (2√r/(1+r) - 1):
  - Standard IL only sees price ratio r = p₁/p₀
  - Grassmannian IL sees which DIMENSIONS of the stalk diverged
  - Principal angles θ₁,...,θₖ tell us exactly where the risk is

THRESHOLD SYSTEM (from revenge-banana, adapted):
  - Threshold 1 (θ_max > π/8):  Adjust LP range using Karcher mean
  - Threshold 2 (θ_max > π/4):  Partial hedge (reduce exposure fraction)
  - Threshold 3 (θ_max > π/3):  Emergency return to treasury

LEARNING:
  Updates via CoregulatorDAO Hebbian weights on Gr(k,n).
  The belief_vector IS a stalk — resolved by Karcher mean with other agents.
"""

import numpy as np
from typing import Dict, Any, Tuple, Optional
from dataclasses import dataclass

from . import AgentProposal
from ...consensus.coregulator import CoregulatorDAO


# Thresholds in principal angle (radians on Gr(k,n))
THETA_THRESHOLD_1 = np.pi / 8   # ~22.5° — adjust range
THETA_THRESHOLD_2 = np.pi / 4   # ~45°  — partial hedge (= MAX_DIVERGENCE in Rust)
THETA_THRESHOLD_3 = np.pi / 3   # ~60°  — emergency


@dataclass
class ILStatus:
    """IL status measured on Grassmannian."""
    max_principal_angle: float       # θ_max = max divergence angle
    principal_angles: np.ndarray     # All k angles
    grassmann_distance: float        # d_G = √(Σ θᵢ²)
    standard_il_pct: float           # Classic IL % for comparison
    threshold_breach: int            # 0, 1, 2, or 3


class HedgeAgent:
    """
    CLMM LP position guardian using Grassmannian geometry.

    Uses principal angles between stalk subspaces to measure IL
    more precisely than standard price-ratio formula.
    """

    def __init__(self, stalk_dim: int = 2):
        self.name = "HedgeAgent"
        self.stalk_dim = stalk_dim

        # Learnable thresholds (updated by CoregulatorDAO feedback)
        self.theta_1 = THETA_THRESHOLD_1
        self.theta_2 = THETA_THRESHOLD_2
        self.theta_3 = THETA_THRESHOLD_3

        # Hedge parameters
        self.max_hedge_fraction = 0.50
        self.min_range_width = 0.10
        self.max_range_width = 0.50

    def propose(self, state: Dict[str, Any]) -> AgentProposal:
        """
        Analyze LP position and propose hedging action.

        State should contain:
          - pool: CLMMPool
          - entry_price: float
          - current_price: float
          - entry_stalk: np.ndarray (stalk at entry, k×n)
          - current_stalk: np.ndarray (stalk now, k×n)
          - spectral_gap: float (network health signal)
        """
        pool = state.get('pool')
        entry_stalk = state.get('entry_stalk')
        current_stalk = state.get('current_stalk')
        entry_price = state.get('entry_price', 1.0)
        current_price = state.get('current_price', 1.0)
        spectral_gap = state.get('spectral_gap', 1.0)

        if entry_stalk is None or current_stalk is None:
            return self._no_action("Missing stalk data")

        # Measure IL on Grassmannian
        il_status = self._compute_il(entry_stalk, current_stalk, entry_price, current_price)

        # Choose action based on threshold
        if il_status.threshold_breach >= 3:
            return self._emergency_return(il_status, state)
        elif il_status.threshold_breach >= 2:
            return self._partial_hedge(il_status, state)
        elif il_status.threshold_breach >= 1:
            return self._adjust_range(il_status, state)
        else:
            return self._no_action("IL within bounds")

    def _compute_il(
        self,
        entry_stalk: np.ndarray,
        current_stalk: np.ndarray,
        entry_price: float,
        current_price: float,
    ) -> ILStatus:
        """Compute IL using Grassmannian principal angles."""
        # Principal angles via SVD of P₁ᵀ P₂
        # where P = QQᵀ is the projector onto the subspace
        if entry_stalk.ndim == 1:
            entry_stalk = entry_stalk.reshape(-1, 1)
        if current_stalk.ndim == 1:
            current_stalk = current_stalk.reshape(-1, 1)

        # QR for orthonormal bases
        Q1, _ = np.linalg.qr(entry_stalk)
        Q2, _ = np.linalg.qr(current_stalk)

        # Principal angles = arccos(singular values of Q1ᵀ Q2)
        svd = np.linalg.svd(Q1.T @ Q2, compute_uv=False)
        cos_angles = np.clip(svd, -1.0, 1.0)
        angles = np.arccos(cos_angles)

        theta_max = float(angles.max()) if len(angles) > 0 else 0.0
        d_G = float(np.sqrt(np.sum(angles ** 2)))

        # Standard IL for comparison
        r = current_price / entry_price if entry_price > 0 else 1.0
        standard_il = abs(2 * np.sqrt(r) / (1 + r) - 1)

        # Threshold
        breach = 0
        if theta_max >= self.theta_3:
            breach = 3
        elif theta_max >= self.theta_2:
            breach = 2
        elif theta_max >= self.theta_1:
            breach = 1

        return ILStatus(
            max_principal_angle=theta_max,
            principal_angles=angles,
            grassmann_distance=d_G,
            standard_il_pct=standard_il,
            threshold_breach=breach,
        )

    def _adjust_range(self, il: ILStatus, state: Dict) -> AgentProposal:
        """Threshold 1: adjust LP range using Karcher mean direction."""
        # The principal angles tell us which dimensions diverged most
        # Adjust range width proportional to max angle
        width_factor = 1.0 + (il.max_principal_angle / np.pi)
        current_price = state.get('current_price', 1.0)

        new_width = np.clip(
            0.20 * width_factor,
            self.min_range_width,
            self.max_range_width,
        )

        belief = np.array([
            il.grassmann_distance,           # How far we've drifted
            il.max_principal_angle,          # Worst dimension
            new_width,                        # Proposed width
        ])

        return AgentProposal(
            agent_id=self.name,
            action_type='adjust_range',
            belief_vector=belief,
            confidence=0.75,
            context_coverage={'impermanent_loss', 'principal_angles', 'range'},
            rationale={
                'scenario': 'range_adjustment',
                'theta_max': il.max_principal_angle,
                'd_G': il.grassmann_distance,
                'standard_il_pct': il.standard_il_pct,
                'new_width': new_width,
            },
        )

    def _partial_hedge(self, il: ILStatus, state: Dict) -> AgentProposal:
        """Threshold 2: reduce exposure by hedge fraction."""
        severity = (il.max_principal_angle - self.theta_2) / (self.theta_3 - self.theta_2)
        hedge_fraction = min(self.max_hedge_fraction, severity * self.max_hedge_fraction)

        belief = np.array([
            il.grassmann_distance,
            il.max_principal_angle,
            hedge_fraction,
        ])

        return AgentProposal(
            agent_id=self.name,
            action_type='hedge',
            belief_vector=belief,
            confidence=0.80,
            context_coverage={'impermanent_loss', 'principal_angles', 'exposure'},
            rationale={
                'scenario': 'partial_hedge',
                'theta_max': il.max_principal_angle,
                'hedge_fraction': hedge_fraction,
                'standard_il_pct': il.standard_il_pct,
            },
        )

    def _emergency_return(self, il: ILStatus, state: Dict) -> AgentProposal:
        """Threshold 3: return liquidity to treasury."""
        belief = np.array([
            il.grassmann_distance,
            il.max_principal_angle,
            1.0,  # Full pullback
        ])

        return AgentProposal(
            agent_id=self.name,
            action_type='emergency_return',
            belief_vector=belief,
            confidence=0.90,
            context_coverage={'impermanent_loss', 'principal_angles', 'emergency'},
            rationale={
                'scenario': 'emergency_pullback',
                'theta_max': il.max_principal_angle,
                'd_G': il.grassmann_distance,
                'standard_il_pct': il.standard_il_pct,
            },
        )

    def update_from_feedback(self, reward: float, lr: float):
        """Hebbian update of thresholds from CoregulatorDAO."""
        if reward > 0.7:
            # Doing well — can relax slightly
            self.theta_1 *= (1 + lr * 0.01)
            self.theta_2 *= (1 + lr * 0.01)
        elif reward < 0.3:
            # Tighten — act earlier
            self.theta_1 *= (1 - lr * 0.02)
            self.theta_2 *= (1 - lr * 0.02)

        # Clamp to sane bounds
        self.theta_1 = np.clip(self.theta_1, np.pi / 12, np.pi / 6)
        self.theta_2 = np.clip(self.theta_2, np.pi / 6, np.pi / 3)
        self.theta_3 = np.clip(self.theta_3, np.pi / 4, np.pi / 2)

    def _no_action(self, reason: str) -> AgentProposal:
        return AgentProposal(
            agent_id=self.name,
            action_type='hold',
            belief_vector=np.zeros(3),
            confidence=0.0,
            context_coverage=set(),
            rationale={'scenario': 'hold', 'reason': reason},
        )
