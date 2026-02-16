"""
CLMM Pool — HCRYPT ↔ vHCRYPT Liquidity (Stub)

Concentrated Liquidity Market Maker connecting native token (HCRYPT)
with vault token (vHCRYPT). Validators acquire vHCRYPT to bond;
users acquire HCRYPT for transactions.

Starts as constant-product AMM (x·y = k), upgradeable to
concentrated liquidity later.

vHCRYPT/HCRYPT ratio = validator demand signal:
  High → validators in demand → network healthy
  Low  → validator oversupply or low activity

See docs/CONSENSUS.md § Token Economics.
"""

from dataclasses import dataclass
from typing import Tuple


@dataclass
class CLMMPool:
    """
    Constant-product AMM: HCRYPT ↔ vHCRYPT.

    Invariant: reserve_hcrypt × reserve_vhcrypt = k

    TODO: Upgrade to concentrated liquidity (tick-based ranges).
    """

    reserve_hcrypt: int = 0
    reserve_vhcrypt: int = 0

    def initialize(self, hcrypt: int, vhcrypt: int) -> None:
        """Initialize pool with liquidity."""
        assert hcrypt > 0 and vhcrypt > 0
        self.reserve_hcrypt = hcrypt
        self.reserve_vhcrypt = vhcrypt

    @property
    def k(self) -> int:
        """Constant product invariant."""
        return self.reserve_hcrypt * self.reserve_vhcrypt

    @property
    def price_hcrypt_per_vhcrypt(self) -> float:
        """How many HCRYPT per 1 vHCRYPT."""
        if self.reserve_vhcrypt == 0:
            return 0.0
        return self.reserve_hcrypt / self.reserve_vhcrypt

    def swap_hcrypt_for_vhcrypt(self, hcrypt_in: int) -> Tuple[bool, int]:
        """
        Swap HCRYPT → vHCRYPT (e.g., user wants to become validator).

        Returns (success, vhcrypt_out).
        """
        if hcrypt_in <= 0 or self.reserve_vhcrypt == 0:
            return (False, 0)

        # x·y = k → new_y = k / (x + dx) → dy = y - new_y
        new_reserve_hcrypt = self.reserve_hcrypt + hcrypt_in
        new_reserve_vhcrypt = self.k // new_reserve_hcrypt
        vhcrypt_out = self.reserve_vhcrypt - new_reserve_vhcrypt

        if vhcrypt_out <= 0:
            return (False, 0)

        self.reserve_hcrypt = new_reserve_hcrypt
        self.reserve_vhcrypt = new_reserve_vhcrypt
        return (True, vhcrypt_out)

    def swap_vhcrypt_for_hcrypt(self, vhcrypt_in: int) -> Tuple[bool, int]:
        """
        Swap vHCRYPT → HCRYPT (e.g., validator cashing out rewards).

        Returns (success, hcrypt_out).
        """
        if vhcrypt_in <= 0 or self.reserve_hcrypt == 0:
            return (False, 0)

        new_reserve_vhcrypt = self.reserve_vhcrypt + vhcrypt_in
        new_reserve_hcrypt = self.k // new_reserve_vhcrypt
        hcrypt_out = self.reserve_hcrypt - new_reserve_hcrypt

        if hcrypt_out <= 0:
            return (False, 0)

        self.reserve_vhcrypt = new_reserve_vhcrypt
        self.reserve_hcrypt = new_reserve_hcrypt
        return (True, hcrypt_out)

    def summary(self) -> str:
        return (
            f"CLMMPool:\n"
            f"  HCRYPT reserve: {self.reserve_hcrypt}\n"
            f"  vHCRYPT reserve: {self.reserve_vhcrypt}\n"
            f"  Price: {self.price_hcrypt_per_vhcrypt:.4f} HCRYPT/vHCRYPT\n"
            f"  k = {self.k}"
        )
