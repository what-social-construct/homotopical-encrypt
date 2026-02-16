"""
Treasury Pool — Fee Collection & Reward Distribution

Collects transaction fees (HCRYPT), converts to vHCRYPT rewards,
and distributes via pluggable strategies.

Inputs:  Transaction fees, slashing proceeds, protocol inflation
Outputs: Block producer reward, active validator share, protocol fund, burn

Distribution strategy is modular — default is HarmonicWeighted
(by ‖π_H(stalk)‖), switchable without consensus changes.

See docs/CONSENSUS.md § Token Economics.
"""

from dataclasses import dataclass, field
from typing import Dict, List, Protocol, Tuple, Optional
from abc import abstractmethod


# =============================================================================
# CONSTANTS
# =============================================================================

PRODUCER_SHARE: float = 0.40       # 40% to block producer
VALIDATOR_SHARE: float = 0.40      # 40% split among active validators
PROTOCOL_SHARE: float = 0.15       # 15% to protocol fund
BURN_SHARE: float = 0.05           # 5% burned


# =============================================================================
# REWARDS STRATEGY (pluggable interface)
# =============================================================================

class RewardsStrategy:
    """
    Interface for reward distribution strategies.

    Concrete implementations decide HOW the validator share
    gets split among active validators. The treasury decides
    HOW MUCH goes to validators; the strategy decides WHO.
    """

    def distribute(
        self,
        amount: int,
        harmonic_weights: Dict[bytes, float],
    ) -> Dict[bytes, int]:
        """
        Distribute amount among validators by their weights.

        Args:
            amount: Total vHCRYPT to distribute
            harmonic_weights: fingerprint → weight mapping

        Returns:
            fingerprint → allocation mapping
        """
        raise NotImplementedError


class HarmonicWeighted(RewardsStrategy):
    """
    Default: distribute proportional to harmonic projection weight.

    weight(v) = ‖π_H(stalk(v))‖ / ‖stalk(v)‖
    allocation(v) = amount × weight(v) / Σ weights

    This IS the "value is harmonic" principle applied to rewards.
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

        # Last validator gets remainder (avoids rounding loss)
        if sorted_fps:
            allocations[sorted_fps[-1]] = amount - distributed

        return allocations


class EqualShare(RewardsStrategy):
    """Split equally among all active validators."""

    def distribute(
        self,
        amount: int,
        harmonic_weights: Dict[bytes, float],
    ) -> Dict[bytes, int]:
        n = len(harmonic_weights)
        if n == 0 or amount <= 0:
            return {}

        per_validator = amount // n
        remainder = amount - per_validator * n

        allocations = {}
        for i, fp in enumerate(sorted(harmonic_weights.keys())):
            allocations[fp] = per_validator + (1 if i < remainder else 0)

        return allocations


# =============================================================================
# TREASURY
# =============================================================================

@dataclass
class Treasury:
    """
    Fee collection pool with pluggable reward distribution.

    Flow:
      Transaction fee (HCRYPT) → Treasury
        ├── 40% → Block producer vault (vHCRYPT)
        ├── 40% → Active validators (vHCRYPT, by strategy)
        ├── 15% → Protocol fund (HCRYPT)
        └──  5% → Burn
    """

    # Accumulated balances
    balance_hcrypt: int = 0        # Undistributed HCRYPT fees
    protocol_fund: int = 0         # Protocol fund accumulation
    total_burned: int = 0          # Total HCRYPT burned
    total_distributed: int = 0     # Total vHCRYPT distributed

    # Distribution strategy
    strategy: RewardsStrategy = field(default_factory=HarmonicWeighted)

    # History
    distributions: List[Dict] = field(default_factory=list)

    def collect_fee(self, amount: int) -> None:
        """Collect a transaction fee into the treasury."""
        if amount > 0:
            self.balance_hcrypt += amount

    def collect_slash(self, amount: int) -> None:
        """Collect slashing proceeds (goes to protocol fund)."""
        if amount > 0:
            self.protocol_fund += amount

    def distribute(
        self,
        producer_fingerprint: bytes,
        harmonic_weights: Dict[bytes, float],
        vault_registry: 'VaultRegistry',
        epoch: int,
    ) -> Dict[bytes, int]:
        """
        Distribute accumulated fees.

        Args:
            producer_fingerprint: Block producer gets producer share
            harmonic_weights: Active validator weights for distribution
            vault_registry: Where to deposit vHCRYPT
            epoch: Current epoch

        Returns:
            fingerprint → amount distributed
        """
        if self.balance_hcrypt <= 0:
            return {}

        pool = self.balance_hcrypt
        self.balance_hcrypt = 0

        # Split
        producer_amount = int(pool * PRODUCER_SHARE)
        validator_pool = int(pool * VALIDATOR_SHARE)
        protocol_amount = int(pool * PROTOCOL_SHARE)
        burn_amount = pool - producer_amount - validator_pool - protocol_amount

        # Producer reward
        all_allocations: Dict[bytes, int] = {}
        if producer_fingerprint:
            vault_registry.earn(producer_fingerprint, producer_amount)
            all_allocations[producer_fingerprint] = producer_amount

        # Validator distribution (via strategy)
        if harmonic_weights and validator_pool > 0:
            validator_allocations = self.strategy.distribute(
                validator_pool, harmonic_weights
            )
            for fp, amount in validator_allocations.items():
                vault_registry.earn(fp, amount)
                all_allocations[fp] = all_allocations.get(fp, 0) + amount

        # Protocol fund + burn
        self.protocol_fund += protocol_amount
        self.total_burned += burn_amount
        self.total_distributed += producer_amount + validator_pool

        self.distributions.append({
            'epoch': epoch,
            'pool': pool,
            'producer': producer_amount,
            'validators': validator_pool,
            'protocol': protocol_amount,
            'burned': burn_amount,
        })

        return all_allocations

    def summary(self) -> str:
        return (
            f"Treasury:\n"
            f"  Pending fees: {self.balance_hcrypt} HCRYPT\n"
            f"  Protocol fund: {self.protocol_fund} HCRYPT\n"
            f"  Total distributed: {self.total_distributed} vHCRYPT\n"
            f"  Total burned: {self.total_burned} HCRYPT\n"
            f"  Distributions: {len(self.distributions)}"
        )
