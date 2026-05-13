"""
Stabilizer Agent — Dual-Signal Buybacks via Spectral Health + Price Trendlines

Analog of revenge-banana StabilizerAgent, native to the sheaf framework.

SCHEDULING (from revenge-banana):
  Burns and liquidity injections staggered on Fibonacci intervals.
  Fibonacci: 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144...
  This IS a Petri net firing pattern (Swan Table 2).

DUAL SIGNAL:
  1. Spectral gap λ₁ (network health):
     - λ₁ near POV_LOWER (1/√2) → stressed → buyback
     - λ₁ near 1.0 → healthy → hold
     - λ₁ near POV_UPPER (2√2) → overheated → inject

  2. Price trendlines + persistent homology roughness (market timing):
     - RANSAC-style support/resistance from price history (local min/max)
     - Persistent homology barcode as roughness measure:
       mean persistence LOW  → rough/mean-reverting → FAVORABLE for buyback
       mean persistence HIGH → smooth/trending     → FAVORABLE for sell-at-resistance
     - Price below support → buy (accumulate)
     - Price above resistance → sell small % (build reserves)

DYNAMIC CLMM FEES (native analog of HJB optimal spread):
  fee = base_fee × (1 + gap_stress + pool_imbalance)
  - gap_stress: how far spectral gap is from 1.0 (stressed = higher fee)
  - pool_imbalance: how unequal reserves are (unbalanced = higher fee)
  This replaces Zhang HJB with a native formula from the sheaf geometry.

THREE LAYERS (from revenge-banana):
  - Layer 1 (routine): Fibonacci-scheduled burn/inject + trendline profit-taking
  - Layer 2 (dynamic): spectral OR price deviation response
  - Layer 3 (emergency): emergency reserve tapped

SUPPLY CONTROL:
  - Max 5% total supply unbond per epoch
  - Per-account swap cap: 5% of pool reserves per epoch
  - HHI concentration index < 0.15
"""

import numpy as np
from typing import Dict, Any, List, Tuple, Optional
from dataclasses import dataclass, field

from . import AgentProposal
from ...proofs.spectral_bounds import POV_LOWER, POV_UPPER


# =============================================================================
# FIBONACCI SCHEDULE
# =============================================================================

def fibonacci_sequence(n: int) -> List[int]:
    """Generate first n Fibonacci numbers (1-indexed: 1, 1, 2, 3, 5, ...)."""
    seq = [1, 1]
    for i in range(2, n):
        seq.append(seq[-1] + seq[-2])
    return seq[:n]

FIBONACCI = fibonacci_sequence(20)
BURN_SCHEDULE = FIBONACCI[1:]       # offset by 1 from injections
INJECTION_SCHEDULE = FIBONACCI[:]


# =============================================================================
# CONSTANTS
# =============================================================================

# Supply control
MAX_UNBOND_PER_EPOCH: float = 0.05
MAX_SWAP_PER_ACCOUNT: float = 0.05
MAX_STAKE_FRACTION: float = 0.10
HHI_THRESHOLD: float = 0.15

# Layer thresholds (spectral gap deviation from 1.0)
LAYER_1_DEVIATION = 0.10
LAYER_2_DEVIATION = 0.25
LAYER_3_DEVIATION = 0.40

# Dynamic CLMM fee bounds
BASE_FEE: float = 0.005          # 0.5% base swap fee
MAX_FEE: float = 0.03            # 3% max fee under stress
MIN_FEE: float = 0.001           # 0.1% min fee (healthy network)


# =============================================================================
# TRENDLINE HELPERS (lightweight, from revenge-banana trendlines.py)
# =============================================================================

def detect_support_resistance(
    prices: np.ndarray,
    window: int = 5,
) -> Tuple[Optional[float], Optional[float]]:
    """
    Lightweight support/resistance from local min/max.
    RANSAC-lite: median of recent local extrema.
    """
    if len(prices) < window * 3:
        return None, None

    local_mins = []
    local_maxs = []
    for i in range(window, len(prices) - window):
        chunk = prices[i - window:i + window + 1]
        if prices[i] == chunk.min():
            local_mins.append(prices[i])
        if prices[i] == chunk.max():
            local_maxs.append(prices[i])

    support = float(np.median(local_mins[-5:])) if len(local_mins) >= 2 else None
    resistance = float(np.median(local_maxs[-5:])) if len(local_maxs) >= 2 else None
    return support, resistance


def estimate_roughness(prices: np.ndarray) -> float:
    """
    Roughness from persistent homology barcode — analog of Hurst exponent.

    Uses the mean persistence of H₀ features in the Rips filtration
    of the price time series. Short bars = rough (mean-reverting),
    long bars = smooth (trending).

    Returns roughness ∈ [0, 1]:  0 = smooth/trending, 1 = rough/mean-reverting
    """
    if len(prices) < 20:
        return 0.5  # Neutral

    # Build distance matrix from sliding windows of returns
    returns = np.diff(np.log(np.maximum(prices, 1e-10)))
    n = min(len(returns), 100)
    recent = returns[-n:]

    # Simple persistence proxy: ratio of short-lived features to total
    # (avoids importing full persistence machinery for hot path)
    diffs = np.abs(np.diff(recent))
    if len(diffs) == 0:
        return 0.5

    mean_jump = float(np.mean(diffs))
    std_jump = float(np.std(diffs))

    # High mean_jump relative to std = rough (frequent reversals)
    # Low mean_jump relative to std = smooth (persistent trends)
    if std_jump < 1e-10:
        return 0.5

    roughness_ratio = mean_jump / (mean_jump + std_jump)
    return float(np.clip(roughness_ratio, 0.0, 1.0))


def kinematics_check(
    prices: np.ndarray,
    action_type: str,
) -> Tuple[bool, float, float]:
    """
    3-tier kinematics from revenge-banana timing_oracle.py.

    Returns (favorable, velocity, acceleration).
    For buyback: favorable when v→0+, a>0 (approaching minimum)
    For sell: favorable when v→0-, a<0 (approaching maximum)
    """
    if len(prices) < 5:
        return False, 0.0, 0.0

    d1 = np.diff(prices[-5:])
    d2 = np.diff(d1)
    velocity = float(np.mean(d1[-2:]))
    acceleration = float(np.mean(d2[-2:])) if len(d2) >= 2 else 0.0

    if action_type in ('buyback', 'hedge'):
        # Local minimum: velocity near zero or positive, acceleration positive
        favorable = velocity >= -0.02 * prices[-1] and acceleration > 0
    elif action_type in ('sell', 'profit_take'):
        # Local maximum: velocity near zero or negative, acceleration negative
        favorable = velocity <= 0.02 * prices[-1] and acceleration < 0
    else:
        favorable = False

    return favorable, velocity, acceleration


# =============================================================================
# DYNAMIC CLMM FEE (native analog of HJB optimal spread)
# =============================================================================

def compute_dynamic_fee(
    spectral_gap: float,
    reserve_hcrypt: int,
    reserve_vhcrypt: int,
    base_fee: float = BASE_FEE,
) -> float:
    """
    Dynamic CLMM fee based on spectral gap health + pool imbalance.

    Native analog of Zhang HJB optimal spread:
    - HJB uses inventory risk penalty → we use pool imbalance
    - HJB uses vol surface → we use spectral gap stress

    fee = base × (1 + gap_stress + imbalance_penalty)

    Returns fee as fraction (e.g. 0.005 = 0.5%).
    """
    # Gap stress: how far from healthy (1.0)
    gap_stress = abs(spectral_gap - 1.0)
    # Near bounds = much higher stress
    from ...proofs.spectral_bounds import gap_in_bounds, GapStatus
    gap_status = gap_in_bounds(spectral_gap)
    if gap_status in (GapStatus.MARGINAL, GapStatus.INVALID):
        gap_stress *= 2.0  # Double penalty near/outside bounds

    # Pool imbalance: abs(ratio - 0.5) / 0.5
    total = reserve_hcrypt + reserve_vhcrypt
    if total > 0:
        ratio = reserve_hcrypt / total
        imbalance = abs(ratio - 0.5) / 0.5  # 0 = balanced, 1 = fully one-sided
    else:
        imbalance = 0.0

    fee = base_fee * (1.0 + gap_stress + imbalance * 0.5)
    return float(np.clip(fee, MIN_FEE, MAX_FEE))


# =============================================================================
# STABILIZER AGENT
# =============================================================================

class StabilizerAgent:
    """
    Multi-layer buyback/burn system with:
    - Fibonacci staggered scheduling
    - Dual signal: spectral gap (network) + price trendlines (market)
    - Persistent homology roughness for regime detection
    - Sell-at-resistance for treasury reserve building
    - Dynamic CLMM fee recommendations
    - Concentration limits per epoch
    """

    def __init__(self):
        self.name = "StabilizerAgent"

        # Learnable layer deviations
        self.layer_1_dev = LAYER_1_DEVIATION
        self.layer_2_dev = LAYER_2_DEVIATION
        self.layer_3_dev = LAYER_3_DEVIATION

        # Volume per layer (fraction of stabilization fund)
        self.layer_1_volume = 0.05
        self.layer_2_volume = 0.15
        self.layer_3_volume = 0.40

        # Fibonacci schedule tracking
        self.burn_index = 0
        self.injection_index = 0
        self.blocks_since_last_burn = 0
        self.blocks_since_last_injection = 0

        # Epoch supply control
        self.epoch_unbonded: Dict[bytes, int] = {}
        self.epoch_swapped: Dict[bytes, int] = {}

        # Price trendline state
        self.price_history: List[float] = []
        self.max_history = 200
        self.support_price: Optional[float] = None
        self.resistance_price: Optional[float] = None

        # Sell-at-resistance parameters
        self.sell_at_resistance_pct = 0.10  # Sell 10% of treasury at resistance
        self.min_resistance_excess = 0.05   # Must be 5% above resistance

    def propose(self, state: Dict[str, Any]) -> AgentProposal:
        """
        Dual-signal analysis: spectral gap + price trendlines.

        State:
          - spectral_gap: float (network health, target = 1.0)
          - current_price: float (HCRYPT price)
          - block_height: int
          - stabilization_fund: int
          - emergency_reserve: int
          - pool: CLMMPool (or reserve_hcrypt, reserve_vhcrypt)
          - total_supply: int
          - validator_stakes: Dict[bytes, int]
        """
        spectral_gap = state.get('spectral_gap', 1.0)
        current_price = state.get('current_price')
        block_height = state.get('block_height', 0)
        stab_fund = state.get('stabilization_fund', 0)

        # Update price history
        if current_price is not None:
            self.price_history.append(current_price)
            if len(self.price_history) > self.max_history:
                self.price_history = self.price_history[-self.max_history:]

        # Update trendlines
        if len(self.price_history) >= 30:
            prices_arr = np.array(self.price_history)
            self.support_price, self.resistance_price = detect_support_resistance(prices_arr)

        # =============================================
        # DUAL DEVIATION: max(spectral_gap, trendline) drives layers
        # (from revenge-banana DeviationAlert — trendline deviation is primary)
        # =============================================
        gap_deviation = abs(spectral_gap - 1.0)

        # Trendline deviation: how far price is from support (normalized)
        trendline_deviation = 0.0
        if current_price and self.support_price and self.support_price > 0:
            trendline_deviation = max(0.0,
                (self.support_price - current_price) / self.support_price)

        # Combined deviation: whichever signal is worse drives the layer
        combined_deviation = max(gap_deviation, trendline_deviation)

        # Check concentration first
        concentration = self._check_concentration(state)
        if concentration is not None:
            return concentration

        # =============================================
        # SELL AT RESISTANCE (trendline profit-taking)
        # =============================================
        if current_price and self.resistance_price and stab_fund > 0:
            excess = (current_price - self.resistance_price) / self.resistance_price
            if excess >= self.min_resistance_excess:
                if len(self.price_history) >= 5:
                    favorable, vel, accel = kinematics_check(
                        np.array(self.price_history), 'sell'
                    )
                    if favorable:
                        return self._sell_at_resistance(
                            state, current_price, excess, vel, accel
                        )

        # =============================================
        # LAYERS driven by combined deviation (max of spectral + trendline)
        # =============================================
        if combined_deviation >= self.layer_3_dev:
            return self._layer_3_emergency(state, combined_deviation, spectral_gap)
        elif combined_deviation >= self.layer_2_dev:
            return self._layer_2_dynamic(state, combined_deviation, spectral_gap)
        elif combined_deviation >= self.layer_1_dev:
            return self._layer_1_with_price(state, combined_deviation, spectral_gap, block_height)

        # =============================================
        # PRICE-ONLY: buy at support confirmed by kinematics
        # (even if combined_deviation < layer_1, trendline still matters)
        # =============================================
        if trendline_deviation > 0.05 and current_price:
            if len(self.price_history) >= 5:
                favorable, vel, accel = kinematics_check(
                    np.array(self.price_history), 'buyback'
                )
                if favorable:
                    return self._buy_at_support(state, current_price, trendline_deviation)

        # Fibonacci maintenance
        return self._fibonacci_maintenance(state, block_height)

    # =====================================================================
    # PRICE-DRIVEN ACTIONS
    # =====================================================================

    def _sell_at_resistance(self, state, price, excess, vel, accel) -> AgentProposal:
        """Sell small % at resistance to build treasury reserves."""
        fund = state.get('stabilization_fund', 0)
        amount = int(fund * self.sell_at_resistance_pct)

        roughness = 0.0
        if len(self.price_history) >= 20:
            roughness = estimate_roughness(np.array(self.price_history))

        belief = np.array([excess, roughness, vel / max(price, 1)])

        return AgentProposal(
            agent_id=self.name,
            action_type='sell_at_resistance',
            belief_vector=belief,
            confidence=0.70,
            context_coverage={'price', 'trendlines', 'roughness', 'kinematics'},
            rationale={
                'scenario': 'sell_at_resistance',
                'amount': amount,
                'price': price,
                'resistance': self.resistance_price,
                'excess_pct': excess,
                'roughness': roughness,
                'velocity': vel,
                'acceleration': accel,
            },
        )

    def _buy_at_support(self, state, price, below_pct) -> AgentProposal:
        """Buy at support when price confirmed by kinematics."""
        fund = state.get('stabilization_fund', 0)
        amount = int(fund * self.layer_1_volume)

        roughness = 0.0
        if len(self.price_history) >= 20:
            roughness = estimate_roughness(np.array(self.price_history))

        belief = np.array([below_pct, roughness, 0.0])

        return AgentProposal(
            agent_id=self.name,
            action_type='buyback',
            belief_vector=belief,
            confidence=0.65 + 0.15 * roughness,  # Higher confidence when rough (mean-reverting)
            context_coverage={'price', 'trendlines', 'roughness', 'kinematics'},
            rationale={
                'scenario': 'support_buyback',
                'amount': amount,
                'price': price,
                'support': self.support_price,
                'below_pct': below_pct,
                'roughness': roughness,
                'roughness_note': 'high=mean-reverting=buyback favorable',
            },
        )

    # =====================================================================
    # SPECTRAL GAP LAYERS (with price confirmation for layer 1)
    # =====================================================================

    def _layer_1_with_price(self, state, deviation, gap, height) -> AgentProposal:
        """Layer 1: gated by Fibonacci schedule AND price confirmation."""
        fund = state.get('stabilization_fund', 0)
        amount = int(fund * self.layer_1_volume)
        action = 'buyback' if gap < 1.0 else 'inject_liquidity'

        # Price confirmation: only act if price agrees with spectral signal
        price_confirms = True
        if action == 'buyback' and self.support_price:
            current = state.get('current_price')
            if current and current > self.support_price * 1.05:
                price_confirms = False  # Price is fine, spectral gap is off

        confidence = 0.65 if price_confirms else 0.45
        belief = np.array([deviation, gap, amount / max(fund, 1)])

        return AgentProposal(
            agent_id=self.name,
            action_type=action,
            belief_vector=belief,
            confidence=confidence,
            context_coverage={'spectral_gap', 'stabilization', 'price_confirmation'},
            rationale={
                'scenario': 'routine',
                'layer': 1,
                'amount': amount,
                'spectral_gap': gap,
                'deviation': deviation,
                'price_confirms': price_confirms,
            },
        )

    def _layer_2_dynamic(self, state, deviation, gap) -> AgentProposal:
        """Layer 2: act on spectral OR price signal."""
        fund = state.get('stabilization_fund', 0)
        amount = int(fund * self.layer_2_volume)
        action = 'buyback' if gap < 1.0 else 'inject_liquidity'
        belief = np.array([deviation, gap, amount / max(fund, 1)])

        return AgentProposal(
            agent_id=self.name,
            action_type=action,
            belief_vector=belief,
            confidence=0.80,
            context_coverage={'spectral_gap', 'stabilization', 'urgency'},
            rationale={'scenario': 'dynamic', 'layer': 2, 'amount': amount,
                       'spectral_gap': gap, 'deviation': deviation},
        )

    def _layer_3_emergency(self, state, deviation, gap) -> AgentProposal:
        """Layer 3: emergency — tap emergency reserve."""
        fund = state.get('stabilization_fund', 0)
        emergency = state.get('emergency_reserve', 0)
        amount = int(fund * self.layer_3_volume) + int(emergency * 0.50)
        belief = np.array([deviation, gap, 1.0])

        return AgentProposal(
            agent_id=self.name,
            action_type='emergency_buyback',
            belief_vector=belief,
            confidence=0.90,
            context_coverage={'spectral_gap', 'stabilization', 'emergency'},
            rationale={'scenario': 'emergency', 'layer': 3, 'amount': amount,
                       'spectral_gap': gap, 'deviation': deviation,
                       'emergency_reserve_tapped': True},
        )

    # =====================================================================
    # CONCENTRATION + SUPPLY CONTROL
    # =====================================================================

    def _check_concentration(self, state: Dict) -> Optional[AgentProposal]:
        """HHI concentration check."""
        stakes = state.get('validator_stakes', {})
        total = sum(stakes.values())
        if total == 0:
            return None
        shares = [s / total for s in stakes.values()]
        hhi = sum(s * s for s in shares)
        if hhi > HHI_THRESHOLD:
            return AgentProposal(
                agent_id=self.name,
                action_type='concentration_warning',
                belief_vector=np.array([hhi, max(shares), len(stakes)]),
                confidence=0.95,
                context_coverage={'concentration', 'validator_stakes'},
                rationale={'scenario': 'concentration_warning', 'hhi': hhi,
                           'max_stake_fraction': max(shares),
                           'n_validators': len(stakes), 'threshold': HHI_THRESHOLD},
            )
        return None

    def check_unbond_limit(self, account: bytes, amount: int, total_supply: int) -> Tuple[bool, str]:
        epoch_total = sum(self.epoch_unbonded.values()) + amount
        if epoch_total > total_supply * MAX_UNBOND_PER_EPOCH:
            return False, f"Epoch unbond limit exceeded"
        return True, "OK"

    def check_swap_limit(self, account: bytes, amount: int, pool_reserve: int) -> Tuple[bool, str]:
        account_total = self.epoch_swapped.get(account, 0) + amount
        cap = int(pool_reserve * MAX_SWAP_PER_ACCOUNT)
        if account_total > cap:
            return False, f"Swap cap exceeded"
        return True, "OK"

    def reset_epoch(self):
        self.epoch_unbonded.clear()
        self.epoch_swapped.clear()

    # =====================================================================
    # FIBONACCI MAINTENANCE
    # =====================================================================

    def _fibonacci_maintenance(self, state, height) -> AgentProposal:
        """Fibonacci-staggered burns and injections."""
        self.blocks_since_last_burn += 1
        self.blocks_since_last_injection += 1

        burn_interval = BURN_SCHEDULE[min(self.burn_index, len(BURN_SCHEDULE) - 1)]
        if self.blocks_since_last_burn >= burn_interval:
            fund = state.get('stabilization_fund', 0)
            burn_pct = min(0.05, 0.005 * FIBONACCI[min(self.burn_index, len(FIBONACCI) - 1)])
            amount = int(fund * burn_pct)
            self.blocks_since_last_burn = 0
            self.burn_index = min(self.burn_index + 1, len(BURN_SCHEDULE) - 1)
            if amount > 0:
                return AgentProposal(
                    agent_id=self.name,
                    action_type='burn',
                    belief_vector=np.array([0.0, 1.0, burn_pct]),
                    confidence=0.60,
                    context_coverage={'schedule', 'deflationary'},
                    rationale={'scenario': 'fibonacci_burn', 'burn_pct': burn_pct,
                               'amount': amount, 'fibonacci_index': self.burn_index},
                )

        inj_interval = INJECTION_SCHEDULE[min(self.injection_index, len(INJECTION_SCHEDULE) - 1)]
        if self.blocks_since_last_injection >= inj_interval:
            self.blocks_since_last_injection = 0
            self.injection_index = min(self.injection_index + 1, len(INJECTION_SCHEDULE) - 1)

        return self._no_action("No action needed")

    # =====================================================================
    # LEARNING
    # =====================================================================

    def update_from_feedback(self, reward: float, lr: float):
        """Hebbian update of layer thresholds + sell parameters."""
        if reward > 0.7:
            self.layer_1_dev *= (1 + lr * 0.02)
            self.layer_2_dev *= (1 + lr * 0.02)
        elif reward < 0.3:
            self.layer_1_dev *= (1 - lr * 0.02)
            self.layer_2_dev *= (1 - lr * 0.02)

        self.layer_1_dev = np.clip(self.layer_1_dev, 0.05, 0.15)
        self.layer_2_dev = np.clip(self.layer_2_dev, 0.15, 0.35)
        self.layer_3_dev = np.clip(self.layer_3_dev, 0.30, 0.50)

    def _no_action(self, reason: str) -> AgentProposal:
        return AgentProposal(
            agent_id=self.name,
            action_type='hold',
            belief_vector=np.zeros(3),
            confidence=0.0,
            context_coverage=set(),
            rationale={'scenario': 'hold', 'reason': reason},
        )
