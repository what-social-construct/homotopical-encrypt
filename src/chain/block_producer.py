"""
Block Production: Integrates Validator Selection with PoV Consensus

Block production pipeline:
1. Select validator via spectral centrality
2. Collect pending transactions
3. Create block via create_block (chain/block.py)
4. Verify √2 bounds
5. Commit and broadcast

The validator selected to produce a block is determined by:
- Spectral centrality (Fiedler vector)
- VRF randomness from previous block

This ensures well-connected nodes produce blocks, not just wealthy ones.
"""

from typing import List, Dict, Tuple, Optional
from dataclasses import dataclass, field
import numpy as np
import hashlib
import time

# Validator selection from consensus/
from ..consensus.validator_selection import ValidatorSet, Validator

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
from .homotopy_transaction import HomotopyTransaction

# Invariant validation from proofs/ (proof theory)
from ..proofs.consensus import InvariantValidator

from ..crypto.credential import FibrationCredential, generate_credential

# SheafState is the three-layer bus (see docs/ARCHITECTURE.md)
from .sheaf_state import SheafState


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
    timestamp: int = field(default_factory=lambda: int(time.time()))


@dataclass
class MempoolEntry:
    """Transaction in mempool with metadata."""
    transaction: HomotopyTransaction
    received_at: int
    priority: float = 1.0  # Higher = include first


class Mempool:
    """
    Transaction mempool.
    
    Holds pending transactions waiting for block inclusion.
    Priority based on fee (simplified) and arrival time.
    """
    
    def __init__(self, max_size: int = 1000):
        self.entries: List[MempoolEntry] = []
        self.max_size = max_size
        self.tx_hashes: set = set()  # For dedup
    
    def add_transaction(self, tx: HomotopyTransaction, priority: float = 1.0) -> bool:
        """Add transaction to mempool."""
        tx_hash = tx.tx_hash()
        if tx_hash in self.tx_hashes:
            return False  # Duplicate
        
        if len(self.entries) >= self.max_size:
            # Evict lowest priority
            self.entries.sort(key=lambda e: e.priority)
            evicted = self.entries.pop(0)
            self.tx_hashes.remove(evicted.transaction.tx_hash())
        
        self.entries.append(MempoolEntry(
            transaction=tx,
            received_at=int(time.time()),
            priority=priority
        ))
        self.tx_hashes.add(tx_hash)
        return True
    
    def get_transactions(self, max_count: int = 100) -> List[HomotopyTransaction]:
        """Get highest priority transactions for block."""
        self.entries.sort(key=lambda e: -e.priority)
        return [e.transaction for e in self.entries[:max_count]]
    
    def remove_transactions(self, txs: List[HomotopyTransaction]):
        """Remove transactions (after block inclusion)."""
        tx_hashes = {tx.tx_hash() for tx in txs}
        self.entries = [e for e in self.entries if e.transaction.tx_hash() not in tx_hashes]
        self.tx_hashes -= tx_hashes
    
    def size(self) -> int:
        return len(self.entries)


class BlockProducer:
    """
    Produces blocks using PoV consensus with validator selection.
    
    Integrates:
    - ValidatorSet for selecting who produces (consensus/)
    - create_block/verify_block for block creation (chain/)
    - Mempool for pending transactions
    - InvariantValidator for safety checks (proofs/)
    """
    
    def __init__(
        self,
        topology: Dict[int, List[Tuple]],
        validators: List[Tuple[bytes, int]],  # (fingerprint, vertex_id)
        initial_supply: float = 1_000_000.0,
        sheaf_state: Optional[SheafState] = None
    ):
        self.topology = topology
        self.validator_set = ValidatorSet(topology)
        
        # Register validators
        for fingerprint, vertex_id in validators:
            self.validator_set.register_validator(fingerprint, vertex_id)
        
        # Mempool
        self.mempool = Mempool()
        
        # Invariant validator (from proofs/)
        self.invariants = InvariantValidator()
        self.invariants.set_initial_supply(initial_supply)
        
        # Three-layer state bus (see docs/ARCHITECTURE.md)
        # SheafState tracks balances, key images, block headers, hash chain
        self.state = sheaf_state or SheafState()
        
        # Chain state (block list for local reference)
        self.chain: List[Block] = []
        self.current_epoch = 0
        self.last_block_hash = b'\x00' * 32
    
    def register_account(self, fingerprint: bytes, balance: float = 0.0,
                         homotopy_class_id: Optional[bytes] = None):
        """Register an account with initial balance via SheafState."""
        if homotopy_class_id is None:
            homotopy_class_id = hashlib.sha256(fingerprint).digest()
        self.state.add_account(fingerprint, homotopy_class_id, balance)
    
    def submit_transaction(self, tx: HomotopyTransaction, priority: float = 1.0) -> bool:
        """Submit transaction to mempool."""
        return self.mempool.add_transaction(tx, priority)
    
    def produce_block(
        self,
        producer_credential: FibrationCredential,
        max_transactions: int = 100
    ) -> BlockProductionResult:
        """
        Produce a new block.
        
        Steps:
        1. Verify producer is selected validator
        2. Collect transactions from mempool
        3. Create block via chain/block.py
        4. Verify √2 bounds
        5. Commit if valid
        
        Args:
            producer_credential: Credential of block producer
            max_transactions: Max transactions to include
            
        Returns:
            BlockProductionResult with success/failure info
        """
        producer_fp = producer_credential.spectrum.fingerprint_hash()
        
        # Get spectral gap from credential
        spectral_gap = self._compute_spectral_gap(producer_credential)
        
        # Step 1: Verify this validator is selected
        selected = self.validator_set.select_validator(
            self.current_epoch,
            self.last_block_hash
        )
        
        if selected != producer_fp:
            return BlockProductionResult(
                success=False,
                block=None,
                validator=producer_fp,
                spectral_gap=spectral_gap,
                reason=f"Not selected validator. Selected: {selected.hex()[:16] if selected else 'none'}..."
            )
        
        # Step 2: Collect transactions
        transactions = self.mempool.get_transactions(max_transactions)
        
        # Step 3: Create block using chain/block.py
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
                validator=producer_fp,
                spectral_gap=spectral_gap,
                reason=f"Block creation failed: {e}"
            )
        
        # Step 4: Verify block (includes √2 bounds check)
        valid, reason = verify_block(block, self.chain[-1] if self.chain else None)
        if not valid:
            return BlockProductionResult(
                success=False,
                block=block,
                validator=producer_fp,
                spectral_gap=block.header.spectral_gap,
                reason=f"Block verification failed: {reason}"
            )
        
        # Step 5: Commit block
        self._commit_block(block)
        
        return BlockProductionResult(
            success=True,
            block=block,
            validator=producer_fp,
            spectral_gap=block.header.spectral_gap,
            reason="Block produced successfully"
        )
    
    def _compute_spectral_gap(self, credential: FibrationCredential) -> float:
        """Compute spectral gap from credential's Laplacian."""
        try:
            eigenvalues = credential.spectrum.eigenvalues
            # Spectral gap = first nonzero eigenvalue
            sorted_eigs = np.sort(eigenvalues)
            nonzero = sorted_eigs[sorted_eigs > 1e-10]
            if len(nonzero) > 0:
                return float(nonzero[0])
            return 1.0  # Default
        except:
            return 1.0  # Default within bounds
    
    def _commit_block(self, block: Block):
        """
        Commit a verified block to chain state.
        
        Delegates to SheafState.apply_block() which updates all three layers:
        - Layer 1: key images spent, block header stored, tip updated, hash chain
        - Layer 2: commitment tracking
        - Layer 3: fee balances debited/credited
        """
        # Apply block to three-layer state bus
        ok, reason = self.state.apply_block(block)
        if not ok:
            raise RuntimeError(f"Block application failed: {reason}")
        
        # Add to local chain list
        self.chain.append(block)
        
        # Remove from local mempool
        self.mempool.remove_transactions(block.transactions)
        
        # Update local chain pointers
        self.last_block_hash = block.block_hash()
        self.current_epoch += 1
        
        # Update validator's last block
        if block.header.producer_fingerprint in self.validator_set.validators:
            self.validator_set.validators[block.header.producer_fingerprint].last_block = self.current_epoch
    
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
    
    def get_balance(self, fingerprint: bytes) -> float:
        """Get account balance from SheafState."""
        return self.state.get_balance(fingerprint)


# =============================================================================
# TEST
# =============================================================================

def test_block_production():
    """Test block production with validator selection."""
    print("=" * 60)
    print("BLOCK PRODUCTION TEST")
    print("=" * 60)
    
    # Create topology: triangle with 3 vertices
    #   0
    #  / \
    # 1---2
    
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
        fp = cred.spectrum.fingerprint_hash()
        validators.append((fp, i))
        credentials.append(cred)
        print(f"   Validator {i}: {fp.hex()[:16]}...")
    
    # Create block producer
    print("\n2. Initializing block producer...")
    producer = BlockProducer(
        topology=topology,
        validators=validators,
        initial_supply=1_000_000.0
    )
    
    # Register accounts with balances
    for i, (fp, _) in enumerate(validators):
        producer.register_account(fp, 100000.0 + i * 10000)
    
    print(f"   Accounts: {len(producer.state.accounts)}")
    print(f"   Mempool size: {producer.mempool.size()}")
    
    # Get selection probabilities
    print("\n3. Validator selection probabilities:")
    probs = producer.get_validator_probabilities()
    for i, (fp, _) in enumerate(validators):
        p = probs.get(fp, 0)
        print(f"   Validator {i}: {p*100:.1f}%")
    
    # Find selected validator
    selected = producer.get_selected_validator()
    selected_idx = next(i for i, (fp, _) in enumerate(validators) if fp == selected)
    print(f"\n   Selected for epoch 0: Validator {selected_idx}")
    
    # Produce block with selected validator (empty block)
    print("\n4. Producing block...")
    result = producer.produce_block(credentials[selected_idx])
    
    print(f"   Success: {result.success}")
    print(f"   Reason: {result.reason}")
    print(f"   Spectral gap: {result.spectral_gap:.4f}")
    
    if result.block:
        print(f"   Block height: {result.block.header.height}")
        print(f"   Transactions: {len(result.block.transactions)}")
    
    # Produce another block
    print("\n5. Producing second block...")
    selected2 = producer.get_selected_validator()
    selected2_idx = next(i for i, (fp, _) in enumerate(validators) if fp == selected2)
    print(f"   Selected for epoch 1: Validator {selected2_idx}")
    
    result2 = producer.produce_block(credentials[selected2_idx])
    print(f"   Success: {result2.success}")
    print(f"   Chain height: {producer.chain_height()}")
    
    print("\n" + "=" * 60)
    print("✅ BLOCK PRODUCTION WORKING" if result.success else "❌ FAILED")
    print("=" * 60)
    
    return result.success


if __name__ == "__main__":
    test_block_production()
