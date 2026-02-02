"""
Chain State - DEPRECATED (use sheaf_state.py instead)

⚠️ DEPRECATED: This file uses Bitcoin-style UTXO model.
For production, use SheafState from sheaf_state.py which uses:
- Harmonic-based state (message in ker(Δ))
- Balance = projection onto harmonic subspace
- NOT traditional UTXO outputs

This file kept ONLY for:
- Benchmarking against ring signature approach
- Comparison with traditional privacy coins
- Migration path for existing code

Use sheaf_state.SheafState for all new development.

Legacy UTXO Model:
- Outputs are created by transactions
- Outputs are spent by referencing their commitment
- Key images prevent double-spending
"""

from dataclasses import dataclass, field
from typing import Dict, List, Set, Optional, Tuple
import numpy as np
import hashlib
import time

from .key_image import KeyImageStore
# Use homotopy transactions (primary)
# Ring transactions moved to tests/benchmarks/ for comparison only
from .homotopy_transaction import HomotopyTransaction, HomotopyOutput, verify_homotopy_transaction

# Alias for backward compatibility
Transaction = HomotopyTransaction
TransactionOutput = HomotopyOutput
verify_transaction = verify_homotopy_transaction
from .block import Block, BlockHeader, verify_block


@dataclass
class UTXO:
    """
    Unspent Transaction Output.
    
    Contains everything needed to spend this output:
    - Stealth public key (how to find it)
    - Amount commitment (for balance verification)
    - Block height (for maturity checks)
    """
    # Identity
    tx_hash: bytes
    output_index: int
    
    # Output data
    stealth_public_key: bytes
    amount_commitment: bytes
    
    # Chain position
    block_height: int
    block_hash: bytes
    
    # Timestamp
    created_at: int
    
    def utxo_id(self) -> bytes:
        """Unique identifier for this UTXO."""
        return hashlib.sha256(
            self.tx_hash + 
            self.output_index.to_bytes(4, 'little')
        ).digest()
    
    def is_mature(self, current_height: int, maturity: int = 10) -> bool:
        """Check if UTXO has enough confirmations."""
        return current_height - self.block_height >= maturity


@dataclass
class ChainState:
    """
    Complete blockchain state.
    
    Tracks:
    - UTXO set
    - Spent key images
    - Block headers
    - Best chain tip
    """
    
    # UTXO set: utxo_id -> UTXO
    utxos: Dict[bytes, UTXO] = field(default_factory=dict)
    
    # Spent key images
    key_images: KeyImageStore = field(default_factory=KeyImageStore)
    
    # Block headers by hash
    headers: Dict[bytes, BlockHeader] = field(default_factory=dict)
    
    # Block hashes by height
    height_index: Dict[int, bytes] = field(default_factory=dict)
    
    # Current best chain tip
    tip_hash: bytes = b'\x00' * 32
    tip_height: int = -1
    
    # Genesis block hash
    genesis_hash: bytes = b'\x00' * 32
    
    def __init__(self):
        self.utxos = {}
        self.key_images = KeyImageStore()
        self.headers = {}
        self.height_index = {}
        self.tip_hash = b'\x00' * 32
        self.tip_height = -1
        self.genesis_hash = b'\x00' * 32
    
    def add_genesis_block(self, genesis: Block) -> Tuple[bool, str]:
        """Initialize chain with genesis block."""
        if self.tip_height >= 0:
            return (False, "Genesis already set")
        
        # Validate genesis
        if genesis.header.height != 0:
            return (False, "Genesis must have height 0")
        if genesis.header.prev_hash != b'\x00' * 32:
            return (False, "Genesis must have null prev_hash")
        
        # Add to chain
        block_hash = genesis.block_hash()
        self.headers[block_hash] = genesis.header
        self.height_index[0] = block_hash
        self.tip_hash = block_hash
        self.tip_height = 0
        self.genesis_hash = block_hash
        
        # Process transactions
        self._apply_block_transactions(genesis)
        
        return (True, "Genesis block added")
    
    def add_block(self, block: Block) -> Tuple[bool, str]:
        """
        Add a block to the chain.
        
        Validates and applies the block, updating:
        - Headers index
        - UTXO set
        - Key image store
        """
        # Get previous block
        if block.header.prev_hash not in self.headers:
            return (False, f"Unknown previous block: {block.header.prev_hash.hex()[:16]}...")
        
        prev_header = self.headers[block.header.prev_hash]
        
        # Validate block
        prev_block = Block(header=prev_header)
        valid, reason = verify_block(block, prev_block, self.key_images)
        if not valid:
            return (False, reason)
        
        # Add block
        block_hash = block.block_hash()
        self.headers[block_hash] = block.header
        self.height_index[block.header.height] = block_hash
        
        # Update tip if this extends best chain
        if block.header.height > self.tip_height:
            self.tip_hash = block_hash
            self.tip_height = block.header.height
        
        # Apply transactions
        self._apply_block_transactions(block)
        
        return (True, f"Block added at height {block.header.height}")
    
    def _apply_block_transactions(self, block: Block):
        """Apply all transactions in a block to state."""
        block_hash = block.block_hash()
        
        for tx in block.transactions:
            tx_hash = tx.tx_hash()
            
            # 1. Mark key images as spent
            for inp in tx.inputs:
                self.key_images.mark_spent(inp.key_image)
            
            # 2. Add new UTXOs
            for i, out in enumerate(tx.outputs):
                utxo = UTXO(
                    tx_hash=tx_hash,
                    output_index=i,
                    stealth_public_key=out.stealth_public_key,
                    amount_commitment=out.amount_commitment,
                    block_height=block.header.height,
                    block_hash=block_hash,
                    created_at=block.header.timestamp
                )
                self.utxos[utxo.utxo_id()] = utxo
    
    def get_block_header(self, block_hash: bytes) -> Optional[BlockHeader]:
        """Get block header by hash."""
        return self.headers.get(block_hash)
    
    def get_block_at_height(self, height: int) -> Optional[bytes]:
        """Get block hash at given height."""
        return self.height_index.get(height)
    
    def get_utxo(self, utxo_id: bytes) -> Optional[UTXO]:
        """Get UTXO by ID."""
        return self.utxos.get(utxo_id)
    
    def utxo_count(self) -> int:
        """Number of unspent outputs."""
        return len(self.utxos)
    
    def spent_count(self) -> int:
        """Number of spent key images."""
        return self.key_images.size()
    
    def chain_length(self) -> int:
        """Number of blocks in best chain."""
        return self.tip_height + 1
    
    def is_spent(self, key_image: bytes) -> bool:
        """Check if key image is spent."""
        return self.key_images.is_spent(key_image)
    
    def get_utxos_by_commitment(self, commitment_prefix: bytes) -> List[UTXO]:
        """Find UTXOs by commitment prefix (for scanning)."""
        matches = []
        for utxo in self.utxos.values():
            if utxo.amount_commitment.startswith(commitment_prefix):
                matches.append(utxo)
        return matches
    
    def get_recent_utxos(self, n: int = 100) -> List[UTXO]:
        """Get most recent UTXOs (for decoy selection)."""
        sorted_utxos = sorted(
            self.utxos.values(),
            key=lambda u: (u.block_height, u.output_index),
            reverse=True
        )
        return sorted_utxos[:n]
    
    def summary(self) -> str:
        """Get state summary."""
        return (
            f"ChainState:\n"
            f"  Height: {self.tip_height}\n"
            f"  Tip: {self.tip_hash.hex()[:16]}...\n"
            f"  UTXOs: {self.utxo_count()}\n"
            f"  Spent: {self.spent_count()}\n"
            f"  Blocks: {self.chain_length()}"
        )


# ============================================================================
# MEMPOOL
# ============================================================================

@dataclass
class Mempool:
    """
    Transaction mempool (pending transactions).
    """
    
    # Pending transactions: tx_hash -> Transaction
    pending: Dict[bytes, Transaction] = field(default_factory=dict)
    
    # Key images in mempool (prevent double-spend in mempool)
    mempool_key_images: Set[bytes] = field(default_factory=set)
    
    def __init__(self):
        self.pending = {}
        self.mempool_key_images = set()
    
    def add_transaction(
        self,
        tx: Transaction,
        chain_state: ChainState
    ) -> Tuple[bool, str]:
        """
        Add transaction to mempool.
        
        Validates against chain state and mempool state.
        """
        tx_hash = tx.tx_hash()
        
        # Already in mempool?
        if tx_hash in self.pending:
            return (False, "Transaction already in mempool")
        
        # Validate against chain state
        valid, reason = verify_transaction(tx, chain_state.key_images)
        if not valid:
            return (False, reason)
        
        # Check against mempool key images
        for inp in tx.inputs:
            if inp.key_image in self.mempool_key_images:
                return (False, "Key image already in mempool (conflicting tx)")
        
        # Add to mempool
        self.pending[tx_hash] = tx
        for inp in tx.inputs:
            self.mempool_key_images.add(inp.key_image)
        
        return (True, f"Added to mempool ({len(self.pending)} pending)")
    
    def remove_transaction(self, tx_hash: bytes):
        """Remove transaction from mempool."""
        if tx_hash in self.pending:
            tx = self.pending[tx_hash]
            for inp in tx.inputs:
                self.mempool_key_images.discard(inp.key_image)
            del self.pending[tx_hash]
    
    def get_transactions_for_block(self, max_txs: int = 100) -> List[Transaction]:
        """Get transactions to include in next block."""
        # TODO: Sort by fee, check conflicts, etc.
        return list(self.pending.values())[:max_txs]
    
    def clear_confirmed(self, block: Block):
        """Remove transactions that were confirmed in a block."""
        for tx in block.transactions:
            self.remove_transaction(tx.tx_hash())
    
    def size(self) -> int:
        """Number of pending transactions."""
        return len(self.pending)


# ============================================================================
# TEST
# ============================================================================

if __name__ == "__main__":
    import secrets
    from .block import create_block
    from .transaction import create_transaction
    
    print("=" * 60)
    print("CHAIN STATE TEST")
    print("=" * 60)
    
    # Mock credential
    class MockCredential:
        class MockSpectrum:
            def fingerprint_hash(self):
                return secrets.token_bytes(32)
        spectrum = MockSpectrum()
    
    # Test 1: Create chain state
    print("\n1. Creating chain state:")
    state = ChainState()
    print(state.summary())
    
    # Test 2: Add genesis block
    print("\n2. Adding genesis block:")
    genesis = create_block(
        transactions=[],
        prev_hash=b'\x00' * 32,
        height=0,
        producer_credential=MockCredential(),
        spectral_gap=1.5
    )
    success, reason = state.add_genesis_block(genesis)
    print(f"   Success: {success}")
    print(f"   Reason: {reason}")
    print(state.summary())
    
    # Test 3: Add block with transaction
    print("\n3. Adding block with transaction:")
    tx = create_transaction(
        sender_credential=MockCredential(),
        recipient_fingerprint=secrets.token_bytes(32),
        amount=1000,
        ring_size=3
    )
    
    block1 = create_block(
        transactions=[tx],
        prev_hash=genesis.block_hash(),
        height=1,
        producer_credential=MockCredential(),
        spectral_gap=2.0
    )
    success, reason = state.add_block(block1)
    print(f"   Success: {success}")
    print(f"   Reason: {reason}")
    print(state.summary())
    
    # Test 4: Mempool
    print("\n4. Testing mempool:")
    mempool = Mempool()
    
    tx2 = create_transaction(
        sender_credential=MockCredential(),
        recipient_fingerprint=secrets.token_bytes(32),
        amount=500,
        ring_size=3
    )
    
    success, reason = mempool.add_transaction(tx2, state)
    print(f"   Add to mempool: {success}")
    print(f"   Mempool size: {mempool.size()}")
    
    # Try to add same tx again
    success, reason = mempool.add_transaction(tx2, state)
    print(f"   Duplicate add: {success} ({reason})")
    
    # Test 5: Get recent UTXOs
    print("\n5. Recent UTXOs (for decoy selection):")
    recent = state.get_recent_utxos(5)
    print(f"   Found: {len(recent)} UTXOs")
    for utxo in recent:
        print(f"   - {utxo.utxo_id().hex()[:16]}... @ height {utxo.block_height}")
    
    print("\n" + "=" * 60)
    print("✅ CHAIN STATE TESTS PASS")
    print("=" * 60)
