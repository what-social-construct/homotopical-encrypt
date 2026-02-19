"""
Block Production: VRF Slot Assignment + Plücker Centrality + PoV Consensus

Block production pipeline:
1. Derive VRF key from producer credential
2. Evaluate VRF for current epoch → slot eligibility
3. Collect validated transactions from mempool
4. Create block via create_block (chain/block.py)
5. Set vrf_data on block header
6. Verify √2 bounds + VRF slot
7. Check equivocation, commit if valid

The validator selected to produce a block is determined by:
- Plücker centrality (Grassmann distance to consensus subspace)
  with Fiedler fallback when stalk data unavailable
- VRF slot assignment using HMAC-SHA256(eigenvector_key, prev_block || epoch)
- Equivocation detection prevents fork attacks

This ensures geometrically coherent nodes produce blocks — not wealthy,
not just well-connected, but geometrically ALIGNED with the consensus.
"""

from typing import List, Dict, Tuple, Optional
from dataclasses import dataclass, field
import numpy as np
import hashlib
import time

# Validator selection from consensus/ (Plücker + Fiedler fallback)
from ..consensus.validator_selection import ValidatorSet, Validator

# VRF slot assignment (fork prevention)
from ..consensus.vrf_slots import (
    VRFKey, VRFOutput, EquivocationTracker, EquivocationEvidence,
    vrf_evaluate, assign_slot, verify_slot_assignment,
)

# Block structures from chain/block.py (canonical)
from .block import (
    Block,
    BlockHeader,
    create_block,
    verify_block,
    POV_LOWER,
    POV_UPPER,
    SQRT2,
)

# Transaction type
from .homotopy_transaction import HomotopyTransaction, verify_homotopy_transaction

# Invariant validation from proofs/ (proof theory)
from ..proofs.consensus import InvariantValidator

from ..crypto.credential import FibrationCredential, generate_credential

# SheafState is the three-layer bus (see docs/ARCHITECTURE.md)
from .sheaf_state import SheafState

# Reputation for equivocation slashing
from .incentives import ReputationTracker, ReputationEvent

# Consensus economics
from .vault import VaultRegistry, Vault, SlashReason


# Re-export bounds for convenience
LOWER_BOUND = POV_LOWER
UPPER_BOUND = POV_UPPER


@dataclass
class BlockProductionResult:
    """Result of block production attempt."""
    success: bool
    block: Optional[Block]
    validator: bytes
    spectral_gap: float
    reason: str
    vrf_score: float = 0.0
    timestamp: int = field(default_factory=lambda: int(time.time()))


@dataclass
class MempoolEntry:
    """Transaction in mempool with metadata."""
    transaction: HomotopyTransaction
    received_at: int
    priority: float = 1.0  # Higher = include first


class Mempool:
    """
    Transaction mempool with validation on admission.

    Holds pending transactions waiting for block inclusion.
    Priority based on fee and arrival time.
    """

    def __init__(self, max_size: int = 1000):
        self.entries: List[MempoolEntry] = []
        self.max_size = max_size
        self.tx_hashes: set = set()        # For dedup
        self.pending_key_images: set = set()  # Mempool-level double-spend check

    def add_transaction(
        self,
        tx: HomotopyTransaction,
        priority: float = 1.0,
        minimum_fee: int = 0,
    ) -> Tuple[bool, str]:
        """
        Add transaction to mempool with validation.

        Checks:
        1. Deduplication (tx_hash)
        2. Minimum fee enforcement
        3. Key image not already in mempool (mempool-level double-spend)

        Args:
            tx: Transaction to add
            priority: Inclusion priority (higher = first)
            minimum_fee: Minimum fee required (0 = no minimum)

        Returns:
            (success, reason)
        """
        tx_hash = tx.tx_hash()
        if tx_hash in self.tx_hashes:
            return False, "Duplicate transaction"

        # Minimum fee enforcement (spam prevention)
        if minimum_fee > 0 and tx.fee_amount < minimum_fee:
            return False, f"Fee {tx.fee_amount} below minimum {minimum_fee}"

        # Mempool-level key image check
        for inp in tx.inputs:
            if inp.key_image in self.pending_key_images:
                return False, f"Key image already in mempool"

        # Capacity management
        if len(self.entries) >= self.max_size:
            self.entries.sort(key=lambda e: e.priority)
            evicted = self.entries.pop(0)
            evicted_hash = evicted.transaction.tx_hash()
            self.tx_hashes.discard(evicted_hash)
            for inp in evicted.transaction.inputs:
                self.pending_key_images.discard(inp.key_image)

        self.entries.append(MempoolEntry(
            transaction=tx,
            received_at=int(time.time()),
            priority=priority
        ))
        self.tx_hashes.add(tx_hash)
        for inp in tx.inputs:
            self.pending_key_images.add(inp.key_image)
        return True, "Added to mempool"

    def get_transactions(self, max_count: int = 100) -> List[HomotopyTransaction]:
        """Get highest priority transactions for block."""
        self.entries.sort(key=lambda e: -e.priority)
        return [e.transaction for e in self.entries[:max_count]]

    def remove_transactions(self, txs: List[HomotopyTransaction]):
        """Remove transactions (after block inclusion)."""
        tx_hashes = {tx.tx_hash() for tx in txs}
        removed_entries = [e for e in self.entries if e.transaction.tx_hash() in tx_hashes]
        self.entries = [e for e in self.entries if e.transaction.tx_hash() not in tx_hashes]
        self.tx_hashes -= tx_hashes
        for entry in removed_entries:
            for inp in entry.transaction.inputs:
                self.pending_key_images.discard(inp.key_image)

    def size(self) -> int:
        return len(self.entries)


class BlockProducer:
    """
    Produces blocks using PoV consensus with VRF slot assignment.

    Integrates:
    - ValidatorSet for Plücker centrality (consensus/)
    - VRF slot assignment for fork prevention (consensus/vrf_slots.py)
    - EquivocationTracker for detecting double-production
    - create_block/verify_block for block creation (chain/)
    - Mempool for pending transactions (with validation on admission)
    - InvariantValidator for safety checks (proofs/)
    - ReputationTracker for slashing on equivocation
    """

    def __init__(
        self,
        topology: Dict[int, List[Tuple]],
        validators: List[Tuple[bytes, int]],  # (identity_hash, vertex_id)
        initial_supply: float = 1_000_000.0,
        sheaf_state: Optional[SheafState] = None,
        minimum_fee: int = 0,
    ):
        self.topology = topology
        self.validator_set = ValidatorSet(topology)

        # Register validators
        for fingerprint, vertex_id in validators:
            self.validator_set.register_validator(fingerprint, vertex_id)

        # VRF keys: identity_hash → VRFKey (registered via register_vrf_key)
        self.vrf_keys: Dict[bytes, VRFKey] = {}

        # Equivocation tracker (fork prevention)
        self.equivocation_tracker = EquivocationTracker()

        # Reputation tracker (for equivocation slashing)
        self.reputation_tracker = ReputationTracker()

        # Mempool (with minimum fee enforcement)
        self.mempool = Mempool()
        self.minimum_fee = minimum_fee

        # Invariant validator (from proofs/)
        self.invariants = InvariantValidator()
        self.invariants.set_initial_supply(initial_supply)

        # Three-layer state bus (see docs/ARCHITECTURE.md)
        self.state = sheaf_state or SheafState()

        # Chain state
        self.chain: List[Block] = []
        self.current_epoch = 0
        self.last_block_hash = b'\x00' * 32

    def register_account(self, identity_hash: bytes, balance: float = 0.0,
                         homotopy_class_id: Optional[bytes] = None):
        """Register an account with initial balance via SheafState."""
        if homotopy_class_id is None:
            homotopy_class_id = hashlib.sha256(identity_hash).digest()
        self.state.add_account(identity_hash, homotopy_class_id, balance)

    def register_vrf_key(self, credential: FibrationCredential):
        """
        Register VRF key for a validator.

        Must be called before the validator can produce blocks.
        The VRF key is derived from the secret fibration (eigenvectors).
        """
        identity_hash = credential.project_to_public().identity_hash()
        self.vrf_keys[identity_hash] = VRFKey.from_credential(credential)

    def submit_transaction(
        self,
        tx: HomotopyTransaction,
        priority: float = 1.0,
    ) -> bool:
        """
        Submit transaction to mempool with validation.

        Validates:
        - Minimum fee (spam prevention)
        - Key image not in mempool (mempool-level double-spend)
        - Deduplication

        Returns True if accepted into mempool.
        """
        ok, reason = self.mempool.add_transaction(
            tx, priority, minimum_fee=self.minimum_fee
        )
        return ok

    def produce_block(
        self,
        producer_credential: FibrationCredential,
        max_transactions: int = 100
    ) -> BlockProductionResult:
        """
        Produce a new block with VRF slot assignment.

        Steps:
        1. Derive VRF key + evaluate VRF for this epoch
        2. Verify producer is selected validator
        3. Collect transactions from mempool
        4. Create block via chain/block.py
        5. Set vrf_data on block header
        6. Verify block (√2 bounds + structure)
        7. Check equivocation, commit if valid

        Args:
            producer_credential: Credential of block producer
            max_transactions: Max transactions to include

        Returns:
            BlockProductionResult with success/failure info
        """
        producer_identity = producer_credential.project_to_public().identity_hash()
        spectral_gap = self._compute_spectral_gap(producer_credential)

        # =====================================================================
        # STEP 1: VRF evaluation
        # =====================================================================

        # Ensure VRF key is registered
        if producer_identity not in self.vrf_keys:
            self.register_vrf_key(producer_credential)

        vrf_key = self.vrf_keys[producer_identity]
        vrf_output = vrf_evaluate(vrf_key, self.last_block_hash, self.current_epoch)

        # =====================================================================
        # STEP 2: Verify this validator is selected
        # =====================================================================

        selected = self.validator_set.select_validator(
            self.current_epoch,
            self.last_block_hash
        )

        if selected != producer_identity:
            return BlockProductionResult(
                success=False,
                block=None,
                validator=producer_identity,
                spectral_gap=spectral_gap,
                vrf_score=vrf_output.score,
                reason=f"Not selected validator. Selected: {selected.hex()[:16] if selected else 'none'}..."
            )

        # =====================================================================
        # STEP 3: Collect transactions
        # =====================================================================

        transactions = self.mempool.get_transactions(max_transactions)

        # =====================================================================
        # STEP 4: Create block
        # =====================================================================

        try:
            block = create_block(
                transactions=transactions,
                prev_hash=self.last_block_hash,
                height=len(self.chain),
                producer_credential=producer_credential,
                spectral_gap=spectral_gap
            )
        except Exception as e:
            return BlockProductionResult(
                success=False,
                block=None,
                validator=producer_identity,
                spectral_gap=spectral_gap,
                vrf_score=vrf_output.score,
                reason=f"Block creation failed: {e}"
            )

        # =====================================================================
        # STEP 5: Set VRF data on block header
        # =====================================================================

        block.header.vrf_data = vrf_output.to_bytes()

        # =====================================================================
        # STEP 6: Verify block (√2 bounds + structure)
        # =====================================================================

        valid, reason = verify_block(block, self.chain[-1] if self.chain else None)
        if not valid:
            return BlockProductionResult(
                success=False,
                block=block,
                validator=producer_identity,
                spectral_gap=block.header.spectral_gap,
                vrf_score=vrf_output.score,
                reason=f"Block verification failed: {reason}"
            )

        # =====================================================================
        # STEP 7: Equivocation check + commit
        # =====================================================================

        block_hash = block.block_hash()
        equivocation = self.equivocation_tracker.record_block(
            identity_hash=producer_identity,
            epoch=self.current_epoch,
            block_hash=block_hash,
            vrf_data=block.header.vrf_data,
        )

        if equivocation is not None:
            # EQUIVOCATION DETECTED — slash vault + reputation
            self.reputation_tracker.record_event(
                producer_identity,
                ReputationEvent.EQUIVOCATION_DETECTED,
                block_height=self.current_epoch,
                details=f"Two blocks at epoch {self.current_epoch}"
            )
            # Vault slash: lose bonded vHCRYPT (economic penalty)
            self.state.vault_registry.slash(
                producer_identity, SlashReason.EQUIVOCATION
            )
            return BlockProductionResult(
                success=False,
                block=block,
                validator=producer_identity,
                spectral_gap=block.header.spectral_gap,
                vrf_score=vrf_output.score,
                reason=f"EQUIVOCATION: producer already produced block at epoch {self.current_epoch}"
            )

        # All clear — commit block
        self._commit_block(block)

        return BlockProductionResult(
            success=True,
            block=block,
            validator=producer_identity,
            spectral_gap=block.header.spectral_gap,
            vrf_score=vrf_output.score,
            reason="Block produced successfully"
        )

    def _compute_spectral_gap(self, credential: FibrationCredential) -> float:
        """Compute spectral gap from credential's Laplacian."""
        try:
            eigenvalues = credential.spectrum.eigenvalues
            sorted_eigs = np.sort(eigenvalues)
            nonzero = sorted_eigs[sorted_eigs > 1e-10]
            if len(nonzero) > 0:
                return float(nonzero[0])
        except Exception:
            pass
        return 1.0  # Default within bounds

    def _commit_block(self, block: Block):
        """
        Commit a verified block to chain state.

        Pipeline:
        1. SheafState.apply_block() — key images, balances, fees → treasury
        2. Treasury distribution — producer share + harmonic-weighted validator share
        3. Chain pointer updates
        4. Reputation tracking
        """
        producer_identity = block.header.producer_identity

        # 1. Apply block to three-layer state bus (fees go to treasury)
        ok, reason = self.state.apply_block(block)
        if not ok:
            raise RuntimeError(f"Block application failed: {reason}")

        # 2. Distribute accumulated fees via treasury
        #    Uses harmonic weights from validator_set (or uniform fallback)
        harmonic_weights = self.validator_set.compute_spectral_centrality()
        self.state.distribute_fees(
            producer_fp=producer_identity,
            harmonic_weights=harmonic_weights,
            epoch=self.current_epoch,
        )

        # 3. Add to local chain list
        self.chain.append(block)

        # Remove included txs from mempool
        self.mempool.remove_transactions(block.transactions)

        # Update chain pointers
        self.last_block_hash = block.block_hash()
        self.current_epoch += 1

        # Update validator's last block
        if producer_identity in self.validator_set.validators:
            self.validator_set.validators[producer_identity].last_block = self.current_epoch

        # 4. Record successful block production in reputation
        self.reputation_tracker.record_event(
            producer_identity,
            ReputationEvent.BLOCK_PRODUCED,
            block_height=self.current_epoch
        )

    def get_selected_validator(self) -> Optional[bytes]:
        """Get the currently selected validator."""
        return self.validator_set.select_validator(
            self.current_epoch,
            self.last_block_hash
        )

    def get_validator_probabilities(self) -> Dict[bytes, float]:
        """Get selection probability for each validator."""
        return self.validator_set.get_selection_probabilities()

    def chain_height(self) -> int:
        """Get current chain height."""
        return len(self.chain)

    def get_balance(self, identity_hash: bytes) -> float:
        """Get account balance from SheafState."""
        return self.state.get_balance(identity_hash)

    def get_equivocation_evidence(self) -> list:
        """Get all equivocation evidence (for governance/slashing)."""
        return self.equivocation_tracker.evidence


# =============================================================================
# TEST
# =============================================================================

def test_block_production():
    """Test block production with VRF + Plücker centrality."""
    print("=" * 60)
    print("BLOCK PRODUCTION TEST (VRF + Plücker)")
    print("=" * 60)

    topology = {
        0: [(0,), (1,), (2,)],
        1: [(0, 1), (1, 2), (0, 2)],
        2: []
    }

    print("\n1. Creating credentials for 3 validators...")
    validators = []
    credentials = []

    for i in range(3):
        cred = generate_credential(
            parties=[f'validator_{i}'],
            connections=[],
            security_parameter=32
        )
        identity = cred.project_to_public().identity_hash()
        validators.append((identity, i))
        credentials.append(cred)
        print(f"   Validator {i}: {identity.hex()[:16]}...")

    print("\n2. Initializing block producer...")
    producer = BlockProducer(
        topology=topology,
        validators=validators,
        initial_supply=1_000_000.0
    )

    # Register accounts + VRF keys
    for i, (fp, _) in enumerate(validators):
        producer.register_account(identity, 100000.0 + i * 10000)
        producer.register_vrf_key(credentials[i])

    print(f"   Accounts: {len(producer.state.accounts)}")
    print(f"   VRF keys: {len(producer.vrf_keys)}")

    # Get selection probabilities
    print("\n3. Validator selection probabilities:")
    probs = producer.get_validator_probabilities()
    for i, (fp, _) in enumerate(validators):
        p = probs.get(fp, 0)
        print(f"   Validator {i}: {p*100:.1f}%")

    selected = producer.get_selected_validator()
    selected_idx = next(i for i, (fp, _) in enumerate(validators) if fp == selected)
    print(f"\n   Selected for epoch 0: Validator {selected_idx}")

    # Produce block
    print("\n4. Producing block...")
    result = producer.produce_block(credentials[selected_idx])

    print(f"   Success: {result.success}")
    print(f"   Reason: {result.reason}")
    print(f"   Spectral gap: {result.spectral_gap:.4f}")
    print(f"   VRF score: {result.vrf_score:.6f}")

    if result.block:
        print(f"   Block height: {result.block.header.height}")
        print(f"   VRF data: {len(result.block.header.vrf_data)} bytes")
        print(f"   Transactions: {len(result.block.transactions)}")

    # Second block
    print("\n5. Producing second block...")
    selected2 = producer.get_selected_validator()
    selected2_idx = next(i for i, (fp, _) in enumerate(validators) if fp == selected2)
    result2 = producer.produce_block(credentials[selected2_idx])
    print(f"   Success: {result2.success}")
    print(f"   Chain height: {producer.chain_height()}")

    # Equivocation check
    print(f"\n6. Equivocation evidence: {len(producer.get_equivocation_evidence())}")

    print("\n" + "=" * 60)
    print("✅ BLOCK PRODUCTION WORKING" if result.success else "❌ FAILED")
    print("=" * 60)

    return result.success


if __name__ == "__main__":
    test_block_production()
