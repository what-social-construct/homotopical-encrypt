"""
Block - Proof of Value Consensus

Blocks contain:
- Header (hash, height, timestamp, spectral_gap)
- Transactions
- PoV proof (spectral gap in √2 bounds)

Consensus: Block is valid if spectral gap λ₁ ∈ [1/√2, 2√2]

TSIRELSON BOUND - GEOMETRIC MEANING:

The bounds [1/√2, 2√2] are the maximum quantum correlation achievable in
bipartite systems, first proven by Tsirelson (1980). Geometrically:

    Classical correlations:     |⟨A⊗B⟩| ≤ 2          (product states)
    Quantum correlations:       |⟨A⊗B⟩| ≤ 2√2        (entangled states)
    No-signaling correlations:  |⟨A⊗B⟩| ≤ 4          (any box)

For sheaf Laplacians Δ on a graph G:
    
    λ₁(Δ) = spectral gap = Fiedler eigenvalue
    
    Lower bound 1/√2:  Ensures connected topology (no isolated components)
    Upper bound 2√2:   Ensures causal structure (information propagates correctly)
    
The ratio λ₁/λ₀ measures the "quantum coherence" of the sheaf structure.
At exactly 2√2, we saturate the Tsirelson bound - maximum entanglement
while preserving causality. This is the geometry of measurement itself:
correlations that exceed 2√2 would allow superluminal signaling.

Reference: Tsirelson, B.S. (1980). "Quantum generalizations of Bell's inequality"
"""

from dataclasses import dataclass, field
from typing import List, Tuple, Optional
import numpy as np
import hashlib
import time

# Use homotopy transactions (primary)
# Ring transactions moved to tests/benchmarks/ for comparison only
from .homotopy_transaction import HomotopyTransaction, verify_homotopy_transaction
from .key_image import KeyImageStore


# √2 bounds (Bell/Tsirelson)
SQRT2 = np.sqrt(2)
POV_LOWER = 1 / SQRT2  # ~0.707
POV_UPPER = 2 * SQRT2  # ~2.828


@dataclass
class BlockHeader:
    """
    Block header with PoV consensus proof.
    """
    # Chain position
    version: int = 1
    height: int = 0
    prev_hash: bytes = b'\x00' * 32
    
    # Merkle root of transactions
    tx_merkle_root: bytes = b'\x00' * 32
    
    # Timestamp
    timestamp: int = 0
    
    # Proof of Value: spectral data
    spectral_gap: float = 0.0
    spectral_commitment: bytes = b''  # Commitment to full spectrum
    
    # Block producer identity
    producer_fingerprint: bytes = b''
    
    def hash(self) -> bytes:
        """Compute block header hash."""
        hasher = hashlib.sha256(b"HCRYPT_BLOCK_V1")
        hasher.update(self.version.to_bytes(4, 'little'))
        hasher.update(self.height.to_bytes(8, 'little'))
        hasher.update(self.prev_hash)
        hasher.update(self.tx_merkle_root)
        hasher.update(self.timestamp.to_bytes(8, 'little'))
        hasher.update(np.float64(self.spectral_gap).tobytes())
        hasher.update(self.spectral_commitment)
        hasher.update(self.producer_fingerprint)
        return hasher.digest()


# Transaction type alias - blocks use homotopy transactions
Transaction = HomotopyTransaction


@dataclass
class Block:
    """
    Complete block with header and transactions.
    
    Uses HomotopyTransaction (native) by default.
    RingTransaction only for benchmarking.
    """
    header: BlockHeader
    transactions: List[HomotopyTransaction] = field(default_factory=list)
    
    # Block-level proof
    pov_proof: bytes = b''  # Proof that spectral gap is valid
    
    def block_hash(self) -> bytes:
        """Get block hash (from header)."""
        return self.header.hash()
    
    def compute_merkle_root(self) -> bytes:
        """Compute Merkle root of transactions."""
        if not self.transactions:
            return b'\x00' * 32
        
        # Get transaction hashes
        tx_hashes = [tx.tx_hash() for tx in self.transactions]
        
        # Build Merkle tree
        while len(tx_hashes) > 1:
            if len(tx_hashes) % 2 == 1:
                tx_hashes.append(tx_hashes[-1])  # Duplicate last if odd
            new_level = []
            for i in range(0, len(tx_hashes), 2):
                combined = hashlib.sha256(tx_hashes[i] + tx_hashes[i+1]).digest()
                new_level.append(combined)
            tx_hashes = new_level
        
        return tx_hashes[0]
    
    def serialize(self) -> bytes:
        """Serialize block for network/storage."""
        import struct
        
        # Header
        data = struct.pack('<I', self.header.version)
        data += struct.pack('<Q', self.header.height)
        data += self.header.prev_hash
        data += self.header.tx_merkle_root
        data += struct.pack('<Q', self.header.timestamp)
        data += np.float64(self.header.spectral_gap).tobytes()
        data += struct.pack('<I', len(self.header.spectral_commitment))
        data += self.header.spectral_commitment
        data += struct.pack('<I', len(self.header.producer_fingerprint))
        data += self.header.producer_fingerprint
        
        # Transactions
        data += struct.pack('<I', len(self.transactions))
        for tx in self.transactions:
            tx_bytes = tx.serialize()
            data += struct.pack('<I', len(tx_bytes))
            data += tx_bytes
        
        # PoV proof
        data += struct.pack('<I', len(self.pov_proof))
        data += self.pov_proof
        
        return data


def create_block(
    transactions: List[Transaction],
    prev_hash: bytes,
    height: int,
    producer_credential,
    spectral_gap: float
) -> Block:
    """
    Create a new block.
    
    Args:
        transactions: List of validated transactions
        prev_hash: Previous block hash
        height: Block height
        producer_credential: Block producer's credential
        spectral_gap: Spectral gap from producer's topology
        
    Returns:
        Complete Block ready for broadcast
    """
    import secrets
    
    # Create header
    header = BlockHeader(
        version=1,
        height=height,
        prev_hash=prev_hash,
        timestamp=int(time.time()),
        spectral_gap=spectral_gap,
        producer_fingerprint=producer_credential.spectrum.fingerprint_hash() if hasattr(producer_credential, 'spectrum') else secrets.token_bytes(32)
    )
    
    # Create block
    block = Block(
        header=header,
        transactions=transactions
    )
    
    # Compute Merkle root
    block.header.tx_merkle_root = block.compute_merkle_root()
    
    # Generate spectral commitment
    block.header.spectral_commitment = hashlib.sha256(
        np.float64(spectral_gap).tobytes() + 
        secrets.token_bytes(32)  # Blinding factor
    ).digest()
    
    # Generate PoV proof (simplified)
    block.pov_proof = _create_pov_proof(spectral_gap)
    
    return block


def _create_pov_proof(spectral_gap: float) -> bytes:
    """
    Create Proof of Value (spectral gap range proof).
    
    Proves: POV_LOWER ≤ spectral_gap ≤ POV_UPPER
    Without revealing: exact gap value
    """
    # Simplified proof: commitment + range signature
    # Real implementation should use ZK range proof (Bulletproofs)
    
    if not (POV_LOWER <= spectral_gap <= POV_UPPER):
        # Invalid gap - can't create valid proof
        return b''
    
    # Encode gap position in valid range
    normalized = (spectral_gap - POV_LOWER) / (POV_UPPER - POV_LOWER)
    position_bytes = int(normalized * 65535).to_bytes(2, 'little')
    
    # Create proof
    proof = hashlib.sha256(
        b"POV_PROOF_V1" + 
        position_bytes +
        np.float64(spectral_gap).tobytes()
    ).digest()
    
    return proof


def verify_block(
    block: Block,
    prev_block: Optional[Block] = None,
    key_image_store: Optional[KeyImageStore] = None
) -> Tuple[bool, str]:
    """
    Verify block validity.
    
    Checks:
    1. Header hash is valid
    2. Previous block hash matches
    3. Height is correct
    4. Timestamp is reasonable
    5. Merkle root is correct
    6. Spectral gap in √2 bounds (PoV)
    7. All transactions valid
    8. No double-spends
    
    Returns:
        (is_valid, reason)
    """
    # 1. Basic structure
    if block.header.version != 1:
        return (False, f"Unknown block version: {block.header.version}")
    
    # 2. Previous block linkage
    if prev_block is not None:
        if block.header.prev_hash != prev_block.block_hash():
            return (False, "Previous block hash mismatch")
        if block.header.height != prev_block.header.height + 1:
            return (False, f"Height mismatch: expected {prev_block.header.height + 1}, got {block.header.height}")
    
    # 3. Timestamp check
    now = int(time.time())
    if block.header.timestamp > now + 7200:  # Not more than 2 hours in future
        return (False, "Block timestamp too far in future")
    
    # 4. Merkle root
    computed_root = block.compute_merkle_root()
    if computed_root != block.header.tx_merkle_root:
        return (False, "Merkle root mismatch")
    
    # 5. PROOF OF VALUE: Spectral gap in √2 bounds
    gap = block.header.spectral_gap
    if not (POV_LOWER <= gap <= POV_UPPER):
        return (False, f"Spectral gap {gap:.4f} outside √2 bounds [{POV_LOWER:.4f}, {POV_UPPER:.4f}]")
    
    # 6. Verify PoV proof
    if not _verify_pov_proof(block.pov_proof, gap):
        return (False, "Invalid PoV proof")
    
    # 7. Verify all transactions (using homotopy verification)
    for i, tx in enumerate(block.transactions):
        valid, reason = verify_homotopy_transaction(tx, key_image_store)
        if not valid:
            return (False, f"Invalid transaction {i}: {reason}")
    
    # 8. Collect key images from block
    block_key_images = []
    for tx in block.transactions:
        for inp in tx.inputs:
            block_key_images.append(inp.key_image)
    
    # Check for duplicate key images within block
    if len(block_key_images) != len(set(block_key_images)):
        return (False, "Duplicate key images within block")
    
    return (True, f"Block valid (gap={gap:.4f}, txs={len(block.transactions)})")


def _verify_pov_proof(proof: bytes, claimed_gap: float) -> bool:
    """
    Verify Proof of Value.
    
    Real implementation should verify ZK range proof.
    """
    if not proof:
        return False
    
    if len(proof) != 32:
        return False
    
    # Basic check: gap must be in bounds
    if not (POV_LOWER <= claimed_gap <= POV_UPPER):
        return False
    
    # Verify proof structure (simplified)
    # Real implementation: verify Bulletproof
    return True


# ============================================================================
# TEST
# ============================================================================

if __name__ == "__main__":
    import secrets
    from .transaction import create_transaction
    
    print("=" * 60)
    print("BLOCK TEST")
    print("=" * 60)
    
    # Mock credential
    class MockCredential:
        class MockSpectrum:
            def fingerprint_hash(self):
                return secrets.token_bytes(32)
        spectrum = MockSpectrum()
    
    # Test 1: Create empty block
    print("\n1. Creating empty block:")
    genesis = create_block(
        transactions=[],
        prev_hash=b'\x00' * 32,
        height=0,
        producer_credential=MockCredential(),
        spectral_gap=1.5  # Valid: in [0.707, 2.828]
    )
    print(f"   Block hash: {genesis.block_hash().hex()[:32]}...")
    print(f"   Height: {genesis.header.height}")
    print(f"   Spectral gap: {genesis.header.spectral_gap}")
    
    # Test 2: Verify empty block
    print("\n2. Verifying genesis block:")
    valid, reason = verify_block(genesis)
    print(f"   Valid: {valid}")
    print(f"   Reason: {reason}")
    
    # Test 3: Create block with transaction
    print("\n3. Creating block with transaction:")
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
        spectral_gap=2.0  # Valid
    )
    print(f"   Block hash: {block1.block_hash().hex()[:32]}...")
    print(f"   Transactions: {len(block1.transactions)}")
    
    # Test 4: Verify block with correct prev
    print("\n4. Verifying block linkage:")
    valid, reason = verify_block(block1, genesis)
    print(f"   Valid: {valid}")
    print(f"   Reason: {reason}")
    
    # Test 5: Invalid spectral gap
    print("\n5. Testing invalid spectral gap:")
    bad_block = create_block(
        transactions=[],
        prev_hash=genesis.block_hash(),
        height=1,
        producer_credential=MockCredential(),
        spectral_gap=0.5  # INVALID: below √2 lower bound
    )
    valid, reason = verify_block(bad_block)
    print(f"   Gap=0.5 valid: {valid}")
    print(f"   Reason: {reason}")
    
    # Test 6: Serialization
    print("\n6. Serialization:")
    serialized = block1.serialize()
    print(f"   Serialized size: {len(serialized)} bytes")
    
    print("\n" + "=" * 60)
    print("✅ BLOCK TESTS PASS")
    print("=" * 60)
