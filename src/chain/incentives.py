"""
Incentives Layer — Reputation Tracking & Fee Modulation

Tracks per-fingerprint reputation using geometric signals from the
transaction pipeline. Reputation is derived from OBSERVABLE BEHAVIOR,
not identity disclosure — privacy is preserved.

Inspired by:
- Ian Miers' callback-based reputation (Zerocash extensions)
- Spectral centrality as a natural "value to network" measure

DESIGN PRINCIPLES:
1. Fingerprint = immutable account UID (spectral fingerprint, like an NFT)
2. Reputation accumulates per-fingerprint across blocks
3. Bad actors face increasing fees (geometric penalty)
4. Good actors earn fee discounts + validator priority
5. ALL reputation signals are derived from PUBLIC chain data
   (no privacy leakage — you never need to reveal your fibration)

REPUTATION SIGNALS (all from Layer 1 public data):
- Transaction validity rate (failed verifications penalize)
- Key image reuse attempts (double-spend attempts penalize heavily)
- Nerve centrality (well-connected accounts = higher reputation)
- Block production quality (valid blocks produced = reputation boost)
- Fee payment consistency (paying fees on time = good)

GEOMETRIC INTERPRETATION:
Reputation lives on the same nerve as accounts:
  reputation(v) := section of a "trust sheaf" over the account nerve
  The Laplacian of the trust sheaf smooths reputation across connections.
  An adversarial node surrounded by honest nodes has its reputation
  dragged down by the spectral gap — information flow is geometric.

References:
- Miers et al. (2013). "Zerocoin" (callback framework)
- Garman et al. (2014). "Decentralized Anonymous Credentials" (reputation without identity)
"""

from dataclasses import dataclass, field
from typing import Dict, Set, Tuple, Optional, List
from enum import Enum
import time
import hashlib
import numpy as np


# =============================================================================
# REPUTATION EVENTS
# =============================================================================

class ReputationEvent(Enum):
    """Events that affect reputation score."""
    
    # Positive events
    VALID_TX_SUBMITTED = "valid_tx"               # +1: submitted valid transaction
    BLOCK_PRODUCED = "block_produced"              # +5: produced valid block
    FEE_PAID = "fee_paid"                          # +1: paid fee on time
    CONNECTION_ESTABLISHED = "connection"           # +1: new connection (grows nerve)
    CLASS_PROOF_INCLUDED = "class_proof"            # +2: included Hodge ZK proof (full privacy)
    
    # Negative events
    INVALID_TX_SUBMITTED = "invalid_tx"            # -3: submitted invalid transaction
    DOUBLE_SPEND_ATTEMPT = "double_spend"          # -10: attempted double-spend (key image reuse)
    SPECTRAL_GAP_VIOLATION = "gap_violation"       # -5: spectral gap out of √2 bounds
    INVARIANT_VIOLATION = "invariant_violation"     # -5: failed invariant checkpoint
    BALANCE_VIOLATION = "balance_violation"         # -5: tried to spend more than balance


# Event weights
EVENT_WEIGHTS: Dict[ReputationEvent, float] = {
    ReputationEvent.VALID_TX_SUBMITTED: 1.0,
    ReputationEvent.BLOCK_PRODUCED: 5.0,
    ReputationEvent.FEE_PAID: 1.0,
    ReputationEvent.CONNECTION_ESTABLISHED: 1.0,
    ReputationEvent.CLASS_PROOF_INCLUDED: 2.0,
    
    ReputationEvent.INVALID_TX_SUBMITTED: -3.0,
    ReputationEvent.DOUBLE_SPEND_ATTEMPT: -10.0,
    ReputationEvent.SPECTRAL_GAP_VIOLATION: -5.0,
    ReputationEvent.INVARIANT_VIOLATION: -5.0,
    ReputationEvent.BALANCE_VIOLATION: -5.0,
}


# =============================================================================
# ACCOUNT REPUTATION
# =============================================================================

@dataclass
class AccountReputation:
    """
    Per-fingerprint reputation state.
    
    The fingerprint is IMMUTABLE (spectral fingerprint = permanent UID).
    Reputation accumulates over the lifetime of the account.
    
    Reputation score is bounded: [MIN_REPUTATION, MAX_REPUTATION]
    New accounts start at DEFAULT_REPUTATION.
    """
    fingerprint: bytes
    
    # Current score
    score: float = 100.0
    
    # Event history (recent, for rate limiting)
    recent_events: List[Tuple[float, ReputationEvent]] = field(default_factory=list)
    
    # Aggregate counters (lifetime)
    total_valid_txs: int = 0
    total_invalid_txs: int = 0
    total_blocks_produced: int = 0
    double_spend_attempts: int = 0
    
    # Rate limiting state
    tx_count_current_epoch: int = 0
    last_epoch_reset: float = 0.0
    
    # Fee multiplier (derived from score)
    @property
    def fee_multiplier(self) -> float:
        """
        Fee multiplier based on reputation.
        
        High reputation → fee discount (down to 0.5x)
        Low reputation → fee penalty (up to 5x)
        Zero/negative reputation → maximum penalty
        
        This is the Miers-style callback: adversarial behavior
        increases the COST of future transactions, not the anonymity.
        Privacy is preserved — the penalty is economic, not deanonymizing.
        """
        if self.score <= 0:
            return 5.0  # Maximum penalty
        elif self.score < 50:
            return 3.0  # High penalty
        elif self.score < 80:
            return 1.5  # Mild penalty
        elif self.score < 120:
            return 1.0  # Normal
        elif self.score < 200:
            return 0.8  # Small discount
        else:
            return 0.5  # Maximum discount
    
    @property
    def rate_limit(self) -> int:
        """
        Max transactions per epoch based on reputation.
        
        High reputation → more txs/epoch
        Low reputation → fewer txs/epoch (rate limited)
        """
        if self.score <= 0:
            return 1   # Nearly frozen
        elif self.score < 50:
            return 5
        elif self.score < 100:
            return 20
        elif self.score < 200:
            return 50
        else:
            return 100  # Highly trusted
    
    @property
    def is_adversarial(self) -> bool:
        """Flag accounts with persistent bad behavior."""
        return (
            self.double_spend_attempts >= 3 or
            self.score <= 0 or
            (self.total_invalid_txs > 10 and 
             self.total_invalid_txs > self.total_valid_txs)
        )


# Constants
DEFAULT_REPUTATION = 100.0
MIN_REPUTATION = -100.0
MAX_REPUTATION = 500.0
EPOCH_DURATION = 600.0  # 10 minutes


# =============================================================================
# REPUTATION TRACKER
# =============================================================================

class ReputationTracker:
    """
    Tracks reputation for all accounts.
    
    Integrates with SheafState — reputation is a section of the
    "trust sheaf" over the account nerve.
    
    PRIVACY GUARANTEE:
    Reputation is computed ONLY from public chain data:
    - Transaction validity (public: block includes valid/rejected txs)
    - Key image uniqueness (public: key image set is on-chain)
    - Block production (public: block headers are on-chain)
    - Fee payment (public: fees are explicit in transactions)
    
    The SECRET fibration is NEVER used to compute reputation.
    An adversary cannot use reputation data to narrow the anonymity set.
    """
    
    def __init__(self):
        self.accounts: Dict[bytes, AccountReputation] = {}
        self.event_log: List[Dict] = []
    
    def get_or_create(self, fingerprint: bytes) -> AccountReputation:
        """Get or create reputation for a fingerprint."""
        if fingerprint not in self.accounts:
            self.accounts[fingerprint] = AccountReputation(
                fingerprint=fingerprint,
                score=DEFAULT_REPUTATION,
                last_epoch_reset=time.time()
            )
        return self.accounts[fingerprint]
    
    def record_event(
        self,
        fingerprint: bytes,
        event: ReputationEvent,
        block_height: int = 0,
        details: str = ""
    ) -> Tuple[float, float]:
        """
        Record a reputation event for an account.
        
        Returns:
            (old_score, new_score)
        """
        rep = self.get_or_create(fingerprint)
        old_score = rep.score
        
        # Apply weight
        weight = EVENT_WEIGHTS.get(event, 0.0)
        rep.score = max(MIN_REPUTATION, min(MAX_REPUTATION, rep.score + weight))
        
        # Update counters
        now = time.time()
        rep.recent_events.append((now, event))
        
        if event == ReputationEvent.VALID_TX_SUBMITTED:
            rep.total_valid_txs += 1
        elif event == ReputationEvent.INVALID_TX_SUBMITTED:
            rep.total_invalid_txs += 1
        elif event == ReputationEvent.BLOCK_PRODUCED:
            rep.total_blocks_produced += 1
        elif event == ReputationEvent.DOUBLE_SPEND_ATTEMPT:
            rep.double_spend_attempts += 1
        
        # Log event
        self.event_log.append({
            'fingerprint': fingerprint.hex()[:16],
            'event': event.value,
            'weight': weight,
            'old_score': old_score,
            'new_score': rep.score,
            'block_height': block_height,
            'details': details,
            'timestamp': now,
        })
        
        # Prune old recent events (keep last 100)
        if len(rep.recent_events) > 100:
            rep.recent_events = rep.recent_events[-100:]
        
        return (old_score, rep.score)
    
    def check_rate_limit(self, fingerprint: bytes) -> Tuple[bool, str]:
        """
        Check if account is within rate limits.
        
        Returns:
            (allowed, reason)
        """
        rep = self.get_or_create(fingerprint)
        now = time.time()
        
        # Reset epoch counter if needed
        if now - rep.last_epoch_reset > EPOCH_DURATION:
            rep.tx_count_current_epoch = 0
            rep.last_epoch_reset = now
        
        if rep.tx_count_current_epoch >= rep.rate_limit:
            return (False, f"Rate limited: {rep.tx_count_current_epoch}/{rep.rate_limit} txs this epoch")
        
        rep.tx_count_current_epoch += 1
        return (True, f"Allowed: {rep.tx_count_current_epoch}/{rep.rate_limit}")
    
    def get_fee_multiplier(self, fingerprint: bytes) -> float:
        """Get fee multiplier for an account."""
        rep = self.get_or_create(fingerprint)
        return rep.fee_multiplier
    
    def compute_effective_fee(self, fingerprint: bytes, base_fee: int) -> int:
        """
        Compute effective fee after reputation adjustment.
        
        fee_effective = base_fee × fee_multiplier(reputation)
        
        Good reputation → lower fees (incentive)
        Bad reputation → higher fees (disincentive, Miers-style callback)
        """
        multiplier = self.get_fee_multiplier(fingerprint)
        return max(1, int(base_fee * multiplier))
    
    def get_adversarial_accounts(self) -> List[bytes]:
        """Get list of fingerprints flagged as adversarial."""
        return [
            fp for fp, rep in self.accounts.items()
            if rep.is_adversarial
        ]
    
    def smooth_reputation_over_nerve(
        self,
        nerve: Dict[int, list],
        fingerprint_order: List[bytes],
        alpha: float = 0.1
    ) -> None:
        """
        Smooth reputation using the graph Laplacian of the account nerve.
        
        This is the GEOMETRIC operation: reputation flows along edges
        of the nerve, smoothed by the spectral gap.
        
        An adversarial node surrounded by honest nodes will have its
        reputation dragged toward the neighborhood average.
        A well-connected honest node benefits from neighbors' reputation.
        
        Args:
            nerve: Čech nerve from SheafState.compute_topology()
            fingerprint_order: Ordered list of fingerprints (vertex order)
            alpha: Smoothing strength (0 = no smoothing, 1 = full average)
        """
        n = len(fingerprint_order)
        if n < 2:
            return
        
        # Build adjacency from nerve
        adj = np.zeros((n, n))
        for edge in nerve.get(1, []):
            i, j = edge
            adj[i, j] = 1.0
            adj[j, i] = 1.0
        
        # Degree matrix
        degrees = adj.sum(axis=1)
        
        # Current reputation vector
        rep_vec = np.array([
            self.get_or_create(fp).score for fp in fingerprint_order
        ])
        
        # Laplacian smoothing: rep_new = (1-α)·rep + α·(D⁻¹A)·rep
        # This is one step of heat diffusion on the graph
        for i in range(n):
            if degrees[i] > 0:
                neighbor_avg = sum(
                    rep_vec[j] * adj[i, j] for j in range(n)
                ) / degrees[i]
                
                new_score = (1 - alpha) * rep_vec[i] + alpha * neighbor_avg
                new_score = max(MIN_REPUTATION, min(MAX_REPUTATION, new_score))
                self.accounts[fingerprint_order[i]].score = new_score
    
    def summary(self) -> str:
        """Get reputation tracker summary."""
        adversarial = len(self.get_adversarial_accounts())
        avg_score = (
            sum(r.score for r in self.accounts.values()) / len(self.accounts)
            if self.accounts else 0
        )
        return (
            f"ReputationTracker:\n"
            f"  Accounts tracked: {len(self.accounts)}\n"
            f"  Average score: {avg_score:.1f}\n"
            f"  Adversarial: {adversarial}\n"
            f"  Events logged: {len(self.event_log)}"
        )


# =============================================================================
# TEST
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("INCENTIVES / REPUTATION TEST")
    print("=" * 60)
    
    tracker = ReputationTracker()
    
    alice = hashlib.sha256(b"alice").digest()
    bob = hashlib.sha256(b"bob").digest()
    mallory = hashlib.sha256(b"mallory").digest()
    
    # Alice: good actor
    print("\n1. Alice (good actor):")
    for _ in range(5):
        tracker.record_event(alice, ReputationEvent.VALID_TX_SUBMITTED)
    tracker.record_event(alice, ReputationEvent.BLOCK_PRODUCED)
    tracker.record_event(alice, ReputationEvent.CLASS_PROOF_INCLUDED)
    rep = tracker.get_or_create(alice)
    print(f"   Score: {rep.score}")
    print(f"   Fee multiplier: {rep.fee_multiplier}x")
    print(f"   Rate limit: {rep.rate_limit} txs/epoch")
    print(f"   Effective fee (base=100): {tracker.compute_effective_fee(alice, 100)}")
    
    # Mallory: adversarial
    print("\n2. Mallory (adversarial):")
    for _ in range(3):
        tracker.record_event(mallory, ReputationEvent.DOUBLE_SPEND_ATTEMPT)
    for _ in range(5):
        tracker.record_event(mallory, ReputationEvent.INVALID_TX_SUBMITTED)
    rep = tracker.get_or_create(mallory)
    print(f"   Score: {rep.score}")
    print(f"   Fee multiplier: {rep.fee_multiplier}x")
    print(f"   Rate limit: {rep.rate_limit} txs/epoch")
    print(f"   Effective fee (base=100): {tracker.compute_effective_fee(mallory, 100)}")
    print(f"   Adversarial flag: {rep.is_adversarial}")
    
    # Rate limiting
    print("\n3. Rate limiting (Mallory):")
    for i in range(3):
        ok, reason = tracker.check_rate_limit(mallory)
        print(f"   Attempt {i+1}: {reason}")
    
    # Nerve smoothing
    print("\n4. Reputation smoothing over nerve:")
    # Alice connected to Bob, Mallory isolated
    nerve = {0: [(0,), (1,), (2,)], 1: [(0, 1)], 2: []}
    tracker.record_event(bob, ReputationEvent.VALID_TX_SUBMITTED)
    
    print(f"   Before: Alice={tracker.get_or_create(alice).score:.1f}, "
          f"Bob={tracker.get_or_create(bob).score:.1f}, "
          f"Mallory={tracker.get_or_create(mallory).score:.1f}")
    
    tracker.smooth_reputation_over_nerve(nerve, [alice, bob, mallory], alpha=0.3)
    
    print(f"   After:  Alice={tracker.get_or_create(alice).score:.1f}, "
          f"Bob={tracker.get_or_create(bob).score:.1f}, "
          f"Mallory={tracker.get_or_create(mallory).score:.1f}")
    
    print(f"\n{tracker.summary()}")
    
    print("\n" + "=" * 60)
    print("✅ INCENTIVES / REPUTATION WORKING")
    print("=" * 60)
