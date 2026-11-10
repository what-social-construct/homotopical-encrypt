"""
Vault Token — Validator Participation Commitment

Separate from native HOMOTOPICAL_ENCRYPT token. vHOMOTOPICAL_ENCRYPT represents validator
commitment to the network.

Design:
  - Bond is a FLAT THRESHOLD (eligibility gate), not a selection weight
  - Selection weight = harmonic projection weight (‖π_H(stalk)‖/‖stalk‖)
  - Slashing removes bonded vHOMOTOPICAL_ENCRYPT for misbehavior
  - Earned vHOMOTOPICAL_ENCRYPT accumulates from block rewards + fee distribution

See docs/CONSENSUS.md for the full design.
"""

from dataclasses import dataclass, field
from typing import Dict, Optional, Tuple, List
from enum import Enum
import hashlib
import time


# =============================================================================
# CONSTANTS
# =============================================================================

MINIMUM_VAULT_BOND: int = 1000          # Minimum vHOMOTOPICAL_ENCRYPT to become validator
EQUIVOCATION_SLASH_PCT: float = 0.50    # 50% of bond
INVALID_PROOF_SLASH_PCT: float = 0.10   # 10% of bond
INACTIVITY_LEAK_PCT: float = 0.01       # 1% per epoch
UNBONDING_DELAY_EPOCHS: int = 10        # Must wait before withdrawing bond


class SlashReason(Enum):
    """Reasons for slashing a validator's bond."""
    EQUIVOCATION = "equivocation"              # Two blocks at same height
    INVALID_SPECTRAL_PROOF = "invalid_proof"   # Spectral proof failed verification
    INACTIVITY = "inactivity"                  # No blocks/attestations for N epochs


SLASH_RATES: Dict[SlashReason, float] = {
    SlashReason.EQUIVOCATION: EQUIVOCATION_SLASH_PCT,
    SlashReason.INVALID_SPECTRAL_PROOF: INVALID_PROOF_SLASH_PCT,
    SlashReason.INACTIVITY: INACTIVITY_LEAK_PCT,
}


# =============================================================================
# VAULT
# =============================================================================

@dataclass
class Vault:
    """
    Per-validator vault identified by spectral fingerprint.

    Stored alongside the SovereignAccount in the same wallet.
    Same fingerprint = same identity. The wallet holds:
      - FibrationCredential (secret key)
      - SovereignAccount (identity + connections)
      - Vault (vHOMOTOPICAL_ENCRYPT bond + earned)
      - HOMOTOPICAL_ENCRYPT balance (native token, separate from vault)

    Vault is linked to the account via fingerprint — no separate
    identity system. When a wallet creates a sovereignty claim,
    it can also bond vHOMOTOPICAL_ENCRYPT into the vault at the same time.
    """
    fingerprint: bytes             # Same as SovereignAccount.fingerprint

    # Token balances (vHOMOTOPICAL_ENCRYPT — separate from HOMOTOPICAL_ENCRYPT)
    bonded: int = 0                # Locked collateral (slashable)
    earned: int = 0                # Accumulated rewards (withdrawable)

    # State
    is_active: bool = False        # Currently eligible for selection
    last_active_height: int = 0    # Last block produced or attested
    activated_height: int = 0      # When bond threshold was met

    # Unbonding
    unbonding_amount: int = 0      # Amount being unbonded
    unbonding_epoch: int = 0       # Epoch when unbonding started

    # Stalk commitment (for coherence verification)
    stalk_commitment: bytes = b''  # Hash of stalk data

    # Slash history
    total_slashed: int = 0
    slash_count: int = 0

    @property
    def total_balance(self) -> int:
        """Total vHOMOTOPICAL_ENCRYPT in vault (bonded + earned)."""
        return self.bonded + self.earned

    @property
    def meets_bond_threshold(self) -> bool:
        """Does the vault meet minimum bond for eligibility?"""
        return self.bonded >= MINIMUM_VAULT_BOND

    def vault_id(self) -> bytes:
        """Unique vault identifier (same as fingerprint)."""
        return self.fingerprint


# =============================================================================
# VAULT REGISTRY
# =============================================================================

class VaultRegistry:
    """
    Manages all validator vaults.

    Operations:
      - bond: Lock vHOMOTOPICAL_ENCRYPT as collateral → become eligible
      - unbond: Start unbonding period → withdraw after delay
      - earn: Receive rewards (block production, fee share)
      - withdraw: Move earned vHOMOTOPICAL_ENCRYPT out
      - slash: Remove bonded vHOMOTOPICAL_ENCRYPT for misbehavior
    """

    def __init__(self):
        self.vaults: Dict[bytes, Vault] = {}
        self.slash_log: List[Dict] = []

    def get_or_create(self, fingerprint: bytes) -> Vault:
        """Get or create a vault for a fingerprint."""
        if fingerprint not in self.vaults:
            self.vaults[fingerprint] = Vault(fingerprint=fingerprint)
        return self.vaults[fingerprint]

    # =========================================================================
    # BOND / UNBOND
    # =========================================================================

    def bond(
        self,
        fingerprint: bytes,
        amount: int,
        stalk_commitment: bytes,
        block_height: int,
    ) -> Tuple[bool, str]:
        """
        Bond vHOMOTOPICAL_ENCRYPT into vault. If threshold met, activate validator.

        Args:
            fingerprint: Validator identity
            amount: vHOMOTOPICAL_ENCRYPT to bond
            stalk_commitment: Hash of validator's stalk data
            block_height: Current block height
        """
        if amount <= 0:
            return (False, "Bond amount must be positive")

        vault = self.get_or_create(fingerprint)
        vault.bonded += amount
        vault.stalk_commitment = stalk_commitment

        was_active = vault.is_active

        if vault.meets_bond_threshold and not vault.is_active:
            vault.is_active = True
            vault.activated_height = block_height

        status = "activated" if (not was_active and vault.is_active) else "bonded"
        return (True, f"{status}: bonded={vault.bonded} vHOMOTOPICAL_ENCRYPT")

    def start_unbond(
        self,
        fingerprint: bytes,
        amount: int,
        current_epoch: int,
    ) -> Tuple[bool, str]:
        """
        Start unbonding process. Funds locked for UNBONDING_DELAY_EPOCHS.
        """
        if fingerprint not in self.vaults:
            return (False, "Vault not found")

        vault = self.vaults[fingerprint]

        if amount > vault.bonded:
            return (False, f"Insufficient bond: {vault.bonded} < {amount}")

        if vault.unbonding_amount > 0:
            return (False, "Already unbonding — wait for completion")

        vault.bonded -= amount
        vault.unbonding_amount = amount
        vault.unbonding_epoch = current_epoch

        # Deactivate if below threshold
        if not vault.meets_bond_threshold:
            vault.is_active = False

        return (True, f"Unbonding {amount} vHOMOTOPICAL_ENCRYPT (available epoch {current_epoch + UNBONDING_DELAY_EPOCHS})")

    def complete_unbond(
        self,
        fingerprint: bytes,
        current_epoch: int,
    ) -> Tuple[bool, int]:
        """
        Complete unbonding if delay has passed. Returns unbonded amount.
        """
        if fingerprint not in self.vaults:
            return (False, 0)

        vault = self.vaults[fingerprint]

        if vault.unbonding_amount == 0:
            return (False, 0)

        if current_epoch < vault.unbonding_epoch + UNBONDING_DELAY_EPOCHS:
            remaining = (vault.unbonding_epoch + UNBONDING_DELAY_EPOCHS) - current_epoch
            return (False, 0)

        amount = vault.unbonding_amount
        vault.earned += amount  # Move to earned (withdrawable)
        vault.unbonding_amount = 0
        vault.unbonding_epoch = 0

        return (True, amount)

    # =========================================================================
    # EARN / WITHDRAW
    # =========================================================================

    def earn(self, fingerprint: bytes, amount: int) -> bool:
        """Add earned vHOMOTOPICAL_ENCRYPT to vault (from rewards/fees)."""
        if amount <= 0:
            return False
        vault = self.get_or_create(fingerprint)
        vault.earned += amount
        return True

    def withdraw(self, fingerprint: bytes, amount: int) -> Tuple[bool, str]:
        """Withdraw earned vHOMOTOPICAL_ENCRYPT from vault."""
        if fingerprint not in self.vaults:
            return (False, "Vault not found")

        vault = self.vaults[fingerprint]
        if amount > vault.earned:
            return (False, f"Insufficient earned: {vault.earned} < {amount}")

        vault.earned -= amount
        return (True, f"Withdrew {amount} vHOMOTOPICAL_ENCRYPT")

    # =========================================================================
    # SLASH
    # =========================================================================

    def slash(
        self,
        fingerprint: bytes,
        reason: SlashReason,
        block_height: int,
    ) -> Tuple[bool, int]:
        """
        Slash a validator's bond. Returns amount slashed.
        """
        if fingerprint not in self.vaults:
            return (False, 0)

        vault = self.vaults[fingerprint]
        rate = SLASH_RATES.get(reason, 0.10)
        slash_amount = max(1, int(vault.bonded * rate))

        if slash_amount > vault.bonded:
            slash_amount = vault.bonded

        vault.bonded -= slash_amount
        vault.total_slashed += slash_amount
        vault.slash_count += 1

        # Deactivate if below threshold
        if not vault.meets_bond_threshold:
            vault.is_active = False

        self.slash_log.append({
            'fingerprint': fingerprint.hex()[:16],
            'reason': reason.value,
            'amount': slash_amount,
            'remaining_bond': vault.bonded,
            'block_height': block_height,
        })

        return (True, slash_amount)

    # =========================================================================
    # QUERIES
    # =========================================================================

    def get_active_vaults(self) -> List[Vault]:
        """Get all active (eligible) vaults."""
        return [v for v in self.vaults.values() if v.is_active]

    def get_eligible_fingerprints(self) -> List[bytes]:
        """Get fingerprints of all eligible validators."""
        return [v.fingerprint for v in self.vaults.values() if v.is_active]

    def is_eligible(self, fingerprint: bytes) -> bool:
        """Check if a validator is eligible for selection."""
        vault = self.vaults.get(fingerprint)
        return vault is not None and vault.is_active

    def summary(self) -> str:
        """Registry summary."""
        active = len(self.get_active_vaults())
        total_bonded = sum(v.bonded for v in self.vaults.values())
        total_earned = sum(v.earned for v in self.vaults.values())
        return (
            f"VaultRegistry:\n"
            f"  Total vaults: {len(self.vaults)}\n"
            f"  Active: {active}\n"
            f"  Total bonded: {total_bonded} vHOMOTOPICAL_ENCRYPT\n"
            f"  Total earned: {total_earned} vHOMOTOPICAL_ENCRYPT\n"
            f"  Slashing events: {len(self.slash_log)}"
        )
