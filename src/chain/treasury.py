"""
Treasury Pool — Petri Net Fee Distribution

PETRI NET MODEL (Swan Table 2, Pinna/Zaitsev):
  Places (L1):  Node accounts with token balances
  Transitions:  Fee collection → distribution (firing event)
  Firing rule:  Tokens flow to places proportional to harmonic weight
  Colored tokens: HCRYPT (native) vs vHCRYPT (vault) — two token colors
  Pre-arcs:     Transaction fees → Treasury (collect)
  Post-arcs:    Treasury → holder accounts (harmonic-weighted distribute)

NO producer/validator distinction. All nodes are automated.
The VRF slot winner assembles the block but gets no special bonus —
value IS the harmonic projection weight ‖π_H(stalk)‖, period.

Fee flow (Petri net firing):
  Transaction fee (HCRYPT) → Treasury
    ├── 50% → All holders (harmonic-weighted by ‖π_H(stalk)‖)
    ├── 25% → Stabilization fund (ProtocolOrchestrator agents)
    ├── 15% → Protocol fund (LP growth, development)
    └── 10% → Burn (deflationary pressure)

Distribution strategy is modular — default is HarmonicWeighted.
Topology tag switching (Zaitsev colored Petri nets) allows dynamic
reconfiguration of token flow based on network state.

See docs/CONSENSUS.md § Token Economics.
"""

from dataclasses import dataclass, field
from typing import Dict, List, Protocol, Tuple, Optional
from abc import abstractmethod


# =============================================================================
# CONSTANTS (Petri net firing weights)
# =============================================================================

HOLDER_SHARE: float = 0.50         # 50% to all holders (harmonic-weighted)
STABILIZATION_SHARE: float = 0.25  # 25% to stabilization fund (agent-managed)
PROTOCOL_SHARE: float = 0.15      # 15% to protocol fund
BURN_SHARE: float = 0.10           # 10% burned


# =============================================================================
# REWARDS STRATEGY (pluggable — Petri net transition function)
# =============================================================================

class RewardsStrategy:
    """
    Petri net transition function: decides token flow to places.

    The treasury decides HOW MUCH flows; the strategy decides WHERE.
    Default is harmonic-weighted (value IS the projection weight).
    """

    def distribute(
        self,
        amount: int,
        harmonic_weights: Dict[bytes, float],
    ) -> Dict[bytes, int]:
        """
        Fire tokens to holder accounts by harmonic weight.

        Args:
            amount: Total tokens to distribute (Petri net token count)
            harmonic_weights: account → weight (Petri net place markings)

        Returns:
            account → allocation (post-arc token flow)
        """
        raise NotImplementedError


class HarmonicWeighted(RewardsStrategy):
    """
    Default: distribute proportional to harmonic projection weight.

    weight(v) = ‖π_H(stalk(v))‖ / ‖stalk(v)‖
    allocation(v) = amount × weight(v) / Σ weights

    This IS the "value is harmonic" principle:
    - Nodes whose stalks survive Hodge projection earn more
    - No special roles — geometry determines everything
    - The Petri net firing is deterministic given the Laplacian
    """

    def distribute(
        self,
        amount: int,
        harmonic_weights: Dict[bytes, float],
    ) -> Dict[bytes, int]:
        total_weight = sum(harmonic_weights.values())
        if total_weight <= 0 or amount <= 0:
            return {}

        allocations = {}
        distributed = 0
        sorted_fps = sorted(harmonic_weights.keys())

        for fp in sorted_fps[:-1]:
            w = harmonic_weights[fp]
            alloc = int(amount * w / total_weight)
            allocations[fp] = alloc
            distributed += alloc

        # Last account gets remainder (avoids rounding loss)
        if sorted_fps:
            allocations[sorted_fps[-1]] = amount - distributed

        return allocations


class EqualShare(RewardsStrategy):
    """Split equally (uniform Petri net firing)."""

    def distribute(
        self,
        amount: int,
        harmonic_weights: Dict[bytes, float],
    ) -> Dict[bytes, int]:
        n = len(harmonic_weights)
        if n == 0 or amount <= 0:
            return {}

        per_account = amount // n
        remainder = amount - per_account * n

        allocations = {}
        for i, fp in enumerate(sorted(harmonic_weights.keys())):
            allocations[fp] = per_account + (1 if i < remainder else 0)

        return allocations


# =============================================================================
# TREASURY (Petri net accumulator place)
# =============================================================================

@dataclass
class Treasury:
    """
    Fee accumulator with Petri net-style distribution.

    The Treasury is a Petri net PLACE that accumulates tokens (pre-arcs)
    and fires them to holder accounts (post-arcs) each epoch.

    No producer/validator distinction — all automated nodes.
    Value IS harmonic projection weight.

    Stabilization fund is managed by ProtocolOrchestrator
    (agents/treasury_agent.py) which uses HedgeAgent + StabilizerAgent
    to decide buyback/sell/burn actions on the CLMMPool.

    Flow (Petri net firing):
      Transaction fees → Treasury
        ├── 50% → All holders (harmonic-weighted)
        ├── 25% → Stabilization fund (agent-managed)
        ├── 15% → Protocol fund
        └── 10% → Burn
    """

    # Petri net place markings (token balances)
    balance_hcrypt: int = 0           # Undistributed fees (pre-firing)
    stabilization_fund: int = 0       # Agent-managed stabilization budget
    protocol_fund: int = 0            # Long-term protocol fund
    total_burned: int = 0             # Cumulative burn (removed from supply)
    total_distributed: int = 0        # Cumulative distributed to holders

    # Petri net transition function (pluggable)
    strategy: RewardsStrategy = field(default_factory=HarmonicWeighted)

    # Firing history (Petri net trace)
    distributions: List[Dict] = field(default_factory=list)

    def collect_fee(self, amount: int) -> None:
        """Pre-arc: transaction fee flows into treasury place."""
        if amount > 0:
            self.balance_hcrypt += amount

    def collect_slash(self, amount: int) -> None:
        """Pre-arc: slashing proceeds flow to stabilization."""
        if amount > 0:
            self.stabilization_fund += amount

    def distribute(
        self,
        harmonic_weights: Dict[bytes, float],
        vault_registry: 'VaultRegistry',
        epoch: int,
    ) -> Dict[bytes, int]:
        """
        Fire: distribute accumulated tokens to holder accounts.

        Post-arcs: tokens flow from treasury to places (accounts)
        proportional to harmonic weight ‖π_H(stalk)‖.

        Args:
            harmonic_weights: All holder harmonic weights
            vault_registry: Where to deposit vHCRYPT
            epoch: Current epoch (Petri net clock)

        Returns:
            account → amount distributed
        """
        if self.balance_hcrypt <= 0:
            return {}

        pool = self.balance_hcrypt
        self.balance_hcrypt = 0

        # Split into buckets (Petri net branching post-arcs)
        holder_pool = int(pool * HOLDER_SHARE)
        stabilization_amount = int(pool * STABILIZATION_SHARE)
        protocol_amount = int(pool * PROTOCOL_SHARE)
        burn_amount = pool - holder_pool - stabilization_amount - protocol_amount

        # Holder distribution (harmonic-weighted post-arcs)
        all_allocations: Dict[bytes, int] = {}
        if harmonic_weights and holder_pool > 0:
            holder_allocations = self.strategy.distribute(
                holder_pool, harmonic_weights
            )
            for fp, amount in holder_allocations.items():
                vault_registry.earn(fp, amount)
                all_allocations[fp] = all_allocations.get(fp, 0) + amount

        # Stabilization fund (ProtocolOrchestrator manages spending)
        self.stabilization_fund += stabilization_amount

        # Protocol fund + burn
        self.protocol_fund += protocol_amount
        self.total_burned += burn_amount
        self.total_distributed += holder_pool

        self.distributions.append({
            'epoch': epoch,
            'pool': pool,
            'holders': holder_pool,
            'stabilization': stabilization_amount,
            'protocol': protocol_amount,
            'burned': burn_amount,
        })

        return all_allocations

    def spend_stabilization(self, amount: int) -> bool:
        """
        Spend from stabilization fund (called by ProtocolOrchestrator).

        Returns True if funds available and spent.
        """
        if amount <= 0 or amount > self.stabilization_fund:
            return False
        self.stabilization_fund -= amount
        return True

    def summary(self) -> str:
        return (
            f"Treasury (Petri net accumulator):\n"
            f"  Pending fees: {self.balance_hcrypt} HCRYPT\n"
            f"  Stabilization fund: {self.stabilization_fund} HCRYPT\n"
            f"  Protocol fund: {self.protocol_fund} HCRYPT\n"
            f"  Total distributed: {self.total_distributed} vHCRYPT\n"
            f"  Total burned: {self.total_burned} HCRYPT\n"
            f"  Firings: {len(self.distributions)}"
        )
