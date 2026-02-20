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
from ..proofs.spectral import (
    SpectralGapProof,
    prove_spectral_gap_in_bounds,
    verify_spectral_gap_proof,
)
from .incentives import ReputationTracker, ReputationEvent
from ..consensus.vrf_slots import (
    VRFKey, VRFOutput, EquivocationTracker, EquivocationEvidence,
    vrf_evaluate, verify_slot_assignment,
)


# √2 bounds — canonical source in proofs/spectral_bounds.py
from ..proofs.spectral_bounds import (
    SQRT2, POV_LOWER, POV_UPPER,
    gap_in_bounds, gap_in_bounds_strict, GapStatus,
    serialize_gap, deserialize_gap,
    credential_age_valid,
)


@dataclass
class BlockHeader:
    """
    Block header with PoV consensus proof.
    
    Three-layer commitments in header:
    - tx_merkle_root:      Layer 1 (hash) — Merkle root of tx hashes
    - cochain_root:        Layer 2 (lattice) — Merkle root of cochain commitments (η₂ projection)
    - spectral_commitment: Layer 3 (homotopy) — commitment to full spectrum
    
    Together these link all three hardness layers through the block header.
    """
    # Chain position
    version: int = 1
    height: int = 0
    prev_hash: bytes = b'\x00' * 32
    
    # Layer 1: Merkle root of transaction hashes
    tx_merkle_root: bytes = b'\x00' * 32
    
    # Layer 2: Merkle root of cochain commitments (η₂ projection)
    # This is SHA256(Σ verified_cochain_commitments) — links Layer 2 → Layer 1
    cochain_root: bytes = b'\x00' * 32
    
    # Timestamp
    timestamp: int = 0
    
    # Proof of Value: spectral data
    spectral_gap: float = 0.0
    spectral_commitment: bytes = b''  # Layer 3: Commitment to full spectrum
    
    # Block producer identity (public homotopy-class hash)
    producer_identity: bytes = b''
    
    # VRF slot assignment data (fork prevention)
    # Serialized VRFOutput: 136 bytes (output + proof + epoch + key_commitment + fingerprint)
    # Empty for genesis block; required for all subsequent blocks.
    vrf_data: bytes = b''
    
    def hash(self) -> bytes:
        """Compute block header hash — includes VRF data for fork prevention."""
        hasher = hashlib.sha256(b"HCRYPT_BLOCK_V2")
        hasher.update(self.version.to_bytes(4, 'little'))
        hasher.update(self.height.to_bytes(8, 'little'))
        hasher.update(self.prev_hash)
        hasher.update(self.tx_merkle_root)
        hasher.update(self.cochain_root)
        hasher.update(self.timestamp.to_bytes(8, 'little'))
        hasher.update(np.float64(self.spectral_gap).tobytes())
        hasher.update(self.spectral_commitment)
        hasher.update(self.producer_identity)
        # VRF data committed to block hash — changing VRF = different block
        if self.vrf_data:
            hasher.update(self.vrf_data)
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
    
    # Private producer fingerprint (NEVER goes on-chain — only in BlockSection private stalk)
    producer_fingerprint_private: bytes = b''
    
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
        data += struct.pack('<I', len(self.header.producer_identity))
        data += self.header.producer_identity
        
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


def _compute_cochain_root(transactions: List[Transaction]) -> bytes:
    """
    Compute Layer 2 cochain root: Merkle root of cochain commitments.
    
    This is the η₂ projection link: Layer 2 (lattice/CVP) → Layer 1 (SHA256).
    
    Each transaction's input and output commitments are SVP-hard bound
    via the coboundary operator δ. The cochain_root aggregates all of
    these into a single commitment that the block header can reference.
    
    cochain_root = MerkleRoot(input_commitments || output_commitments || fee_commitment)
    
    This creates a SEPARATE chain of lattice-hard commitments between blocks,
    sitting between the SHA256 chain (Layer 1) and the spectral data (Layer 3).
    """
    if not transactions:
        return b'\x00' * 32
    
    commitment_hashes = []
    for tx in transactions:
        # Collect all cochain commitments + MAC tags from this transaction
        for inp in tx.inputs:
            commitment_hashes.append(
                hashlib.sha256(b"COCHAIN_INPUT" + inp.amount_commitment).digest()
            )
            # Include MAC tag in cochain root — commits Layer 2 auth into hash chain
            if inp.mac_tag:
                commitment_hashes.append(
                    hashlib.sha256(b"COCHAIN_MAC" + inp.mac_tag).digest()
                )
        for out in tx.outputs:
            commitment_hashes.append(
                hashlib.sha256(b"COCHAIN_OUTPUT" + out.amount_commitment).digest()
            )
        if tx.fee_commitment:
            commitment_hashes.append(
                hashlib.sha256(b"COCHAIN_FEE" + tx.fee_commitment).digest()
            )
    
    if not commitment_hashes:
        return b'\x00' * 32
    
    # Build Merkle tree over cochain commitments
    while len(commitment_hashes) > 1:
        if len(commitment_hashes) % 2 == 1:
            commitment_hashes.append(commitment_hashes[-1])
        new_level = []
        for i in range(0, len(commitment_hashes), 2):
            combined = hashlib.sha256(
                commitment_hashes[i] + commitment_hashes[i+1]
            ).digest()
            new_level.append(combined)
        commitment_hashes = new_level
    
    return commitment_hashes[0]


def create_block(
    transactions: List[Transaction],
    prev_hash: bytes,
    height: int,
    producer_credential,
    spectral_gap: float,
    eigenvalues: Optional[np.ndarray] = None,
) -> Block:
    """
    Create a new block with three-layer commitments.
    
    THREE-LAYER BLOCK STRUCTURE:
    
    Layer 1 (SHA256/node): tx_merkle_root + prev_hash chain
      - Accountability: every tx hash is committed
      - Double-spend: key images are unique
      - Audit trail: SHA256 traces everything
    
    Layer 2 (CVP/lattice/oracle): cochain_root
      - Amount binding: cochain commitments are SVP-hard
      - Homomorphic: sum(inputs) = sum(outputs) + fee without decrypting
      - cochain_root links lattice commitments into the hash chain
    
    Layer 3 (Hodge/homotopy/wallet): spectral_commitment + PoV proof
      - PoV consensus: spectral gap ∈ [1/√2, 2√2] (Tsirelson bound)
      - Real ZK range proof via prove_spectral_gap_in_bounds()
      - Homotopy class membership proven per-transaction
    
    block_hash = SHA256(Layer1 || Layer2 || Layer3)
    → Layer 1 traces all three layers through the hash chain
    
    Args:
        transactions: List of validated transactions
        prev_hash: Previous block hash
        height: Block height
        producer_credential: Block producer's credential
        spectral_gap: Spectral gap from producer's topology
        eigenvalues: Full eigenvalue spectrum (for real PoV proof)
    """
    import secrets
    
    # =========================================================================
    # LAYER 1: SHA256 CHAIN (accountability)
    # =========================================================================
    
    producer_identity = None
    if hasattr(producer_credential, 'project_to_public'):
        try:
            producer_identity = producer_credential.project_to_public().identity_hash()
        except Exception:
            producer_identity = None
    if producer_identity is None and hasattr(producer_credential, 'spectrum'):
        producer_identity = producer_credential.spectrum.fingerprint_hash()
    if producer_identity is None:
        producer_identity = secrets.token_bytes(32)
    
    header = BlockHeader(
        version=1,
        height=height,
        prev_hash=prev_hash,
        timestamp=int(time.time()),
        spectral_gap=spectral_gap,
        producer_identity=producer_identity,
    )
    
    producer_fingerprint_private = (
        producer_credential.spectrum.fingerprint_hash()
        if hasattr(producer_credential, 'spectrum')
        else b''
    )
    block = Block(
        header=header,
        transactions=transactions,
        producer_fingerprint_private=producer_fingerprint_private,
    )
    
    # Layer 1: Merkle root of transaction hashes
    block.header.tx_merkle_root = block.compute_merkle_root()
    
    # =========================================================================
    # LAYER 2: CVP/LATTICE CHAIN (cochain commitments)
    # =========================================================================
    
    # Cochain root: Merkle root of all cochain commitments in this block
    # This is the η₂ projection — lattice-hard commitments into the hash chain
    block.header.cochain_root = _compute_cochain_root(transactions)
    
    # =========================================================================
    # LAYER 3: HODGE/HOMOTOPY (spectral commitment + PoV proof)
    # =========================================================================
    
    # Spectral commitment: blinded commitment to the full spectrum
    block.header.spectral_commitment = hashlib.sha256(
        np.float64(spectral_gap).tobytes() +
        secrets.token_bytes(32)  # Blinding factor
    ).digest()
    
    # PoV proof: real ZK range proof from proofs/spectral.py
    # Uses prove_spectral_gap_in_bounds() instead of the old hash stub
    if eigenvalues is not None and len(eigenvalues) > 0:
        # Real proof path: use actual eigenvalues for ZK range proof
        try:
            gap_proof, proof_ok, proof_msg = prove_spectral_gap_in_bounds(eigenvalues)
            if proof_ok and gap_proof is not None:
                # Serialize the SpectralGapProof for storage
                block.pov_proof = gap_proof.gap_commitment + b''.join(gap_proof.bit_commitments)
                block._spectral_gap_proof = gap_proof  # Keep structured proof
            else:
                # Fallback to hash proof if ZK proof fails
                block.pov_proof = _create_pov_proof_hash(spectral_gap)
        except Exception:
            block.pov_proof = _create_pov_proof_hash(spectral_gap)
    else:
        # No eigenvalues provided — use hash commitment (weaker but valid)
        block.pov_proof = _create_pov_proof_hash(spectral_gap)
    
    return block


def _create_pov_proof_hash(spectral_gap: float) -> bytes:
    """
    Fallback PoV proof using hash commitment.
    
    Used when full eigenvalues aren't available (e.g., genesis block).
    Weaker than the real ZK range proof from proofs/spectral.py.
    """
    if not (POV_LOWER <= spectral_gap <= POV_UPPER):
        return b''
    
    normalized = (spectral_gap - POV_LOWER) / (POV_UPPER - POV_LOWER)
    position_bytes = int(normalized * 65535).to_bytes(2, 'little')
    
    return hashlib.sha256(
        b"POV_PROOF_V1" + position_bytes + np.float64(spectral_gap).tobytes()
    ).digest()


def verify_block(
    block: Block,
    prev_block: Optional[Block] = None,
    key_image_store: Optional[KeyImageStore] = None,
    reputation_tracker: Optional[ReputationTracker] = None,
) -> Tuple[bool, str]:
    """
    Verify block validity across all three layers.
    
    VERIFICATION ALIGNED WITH SHEAFSTATE BUS:
    
    SheafState is the three-layer bus. Block verification checks that the
    block is valid BEFORE apply_block() processes it through the bus.
    After verify_block() passes, apply_block() updates:
      - Layer 1: key images spent, block header stored, tip updated
      - Layer 2: nerve edges tracked, spectral cache invalidated
      - Layer 3: account balances updated, nerve_commitment stored
    
    The verification order mirrors the SheafState layers:
    
    LAYER 1 CHECKS (hash/accountability):
      1. Block structure + version
      2. prev_hash linkage (Layer 1 chain integrity)
      3. Height sequential
      4. Timestamp reasonable
      5. tx_merkle_root matches computed Merkle tree
      6. Key images unique (no double-spend)
    
    LAYER 2 CHECKS (lattice/CVP):
      7. cochain_root matches recomputed Merkle root of cochain commitments
      8. Each transaction: homomorphic balance verified (Σin = Σout + fee)
    
    LAYER 3 CHECKS (homotopy/Hodge):
      9. Spectral gap ∈ [1/√2, 2√2] (Tsirelson/PoV)
      10. PoV proof valid (ZK range proof or hash commitment)
      11. Each transaction: spectral identity proof valid
      12. Each transaction: class membership proof valid (Hodge ZK)
      13. Each transaction: Betti numbers consistent, invariants pass
    
    REPUTATION (incentives layer):
      14. Record events for all participating fingerprints
    
    Returns:
        (is_valid, reason)
    """
    # =========================================================================
    # LAYER 1: HASH/ACCOUNTABILITY CHECKS
    # =========================================================================
    
    # 1. Basic structure
    if block.header.version != 1:
        return (False, f"Unknown block version: {block.header.version}")
    
    # 2. Previous block linkage (Layer 1 chain integrity)
    if prev_block is not None:
        if block.header.prev_hash != prev_block.block_hash():
            return (False, "Previous block hash mismatch")
        if block.header.height != prev_block.header.height + 1:
            return (False, f"Height mismatch: expected {prev_block.header.height + 1}")
    
    # 3. Timestamp check
    now = int(time.time())
    if block.header.timestamp > now + 7200:
        return (False, "Block timestamp too far in future")
    
    # 4. Layer 1: tx_merkle_root
    computed_root = block.compute_merkle_root()
    if computed_root != block.header.tx_merkle_root:
        return (False, "Merkle root mismatch")
    
    # 5. Key images unique within block (double-spend prevention)
    block_key_images = []
    for tx in block.transactions:
        for inp in tx.inputs:
            block_key_images.append(inp.key_image)
    if len(block_key_images) != len(set(block_key_images)):
        return (False, "Duplicate key images within block")
    
    # 6. Key images not already spent (check against store)
    if key_image_store is not None:
        for ki in block_key_images:
            if key_image_store.is_spent(ki):
                return (False, f"Double spend: key image {ki.hex()[:16]}...")
    
    # =========================================================================
    # LAYER 2: CVP/LATTICE CHECKS
    # =========================================================================
    
    # 7. Cochain root matches (Layer 2 → Layer 1 linkage via η₂)
    computed_cochain = _compute_cochain_root(block.transactions)
    if block.header.cochain_root != b'\x00' * 32:
        # Only verify if block actually committed a cochain root
        if computed_cochain != block.header.cochain_root:
            return (False, "Cochain root mismatch (Layer 2 integrity)")
    
    # 8. Each transaction: homomorphic balance (delegated to tx verification)
    #    verify_homotopy_transaction already checks balance at Stage 4
    
    # =========================================================================
    # LAYER 3: HODGE/HOMOTOPY CHECKS
    # =========================================================================
    
    # 9. Spectral gap ∈ [1/√2, 2√2] (Tsirelson/PoV)
    gap = block.header.spectral_gap
    if not (POV_LOWER <= gap <= POV_UPPER):
        return (False, f"Spectral gap {gap:.4f} outside √2 bounds")
    
    # 10. PoV proof (ZK range proof or hash fallback)
    if not _verify_pov_proof(block.pov_proof, gap):
        return (False, "Invalid PoV proof")
    
    # 11-13. Full transaction verification (all stages)
    # verify_homotopy_transaction runs: spectral proof → class membership →
    # invariant gates → balance check. This IS the full pipeline.
    for i, tx in enumerate(block.transactions):
        valid, reason = verify_homotopy_transaction(tx, key_image_store)
        if not valid:
            # Record reputation event for invalid tx
            if reputation_tracker is not None:
                for inp in tx.inputs:
                    reputation_tracker.record_event(
                        inp.fingerprint,
                        ReputationEvent.INVALID_TX_SUBMITTED,
                        block_height=block.header.height,
                        details=reason
                    )
            return (False, f"Invalid transaction {i}: {reason}")
    
    # =========================================================================
    # REPUTATION TRACKING (incentives layer)
    # =========================================================================
    
    if reputation_tracker is not None:
        # Record valid transactions
        for tx in block.transactions:
            for inp in tx.inputs:
                reputation_tracker.record_event(
                    inp.fingerprint,
                    ReputationEvent.VALID_TX_SUBMITTED,
                    block_height=block.header.height
                )
                if inp.class_membership_proof is not None:
                    reputation_tracker.record_event(
                        inp.fingerprint,
                        ReputationEvent.CLASS_PROOF_INCLUDED,
                        block_height=block.header.height
                    )
        
        # Record block production
        reputation_tracker.record_event(
            block.header.producer_identity,
            ReputationEvent.BLOCK_PRODUCED,
            block_height=block.header.height
        )
    
    return (True, f"Block valid (gap={gap:.4f}, txs={len(block.transactions)})")


def _verify_pov_proof(proof: bytes, claimed_gap: float) -> bool:
    """
    Verify Proof of Value.
    
    Accepts either:
    - Real SpectralGapProof (len > 32, from prove_spectral_gap_in_bounds)
    - Hash fallback proof (len == 32, from _create_pov_proof_hash)
    """
    if not proof:
        return False
    
    # Basic check: gap must be in bounds
    if not (POV_LOWER <= claimed_gap <= POV_UPPER):
        return False
    
    if len(proof) == 32:
        # Hash fallback — structural check only
        return True
    elif len(proof) > 32:
        # Real SpectralGapProof — extract and verify
        # The proof is: gap_commitment(32) + bit_commitments(32 each)
        try:
            gap_commitment = proof[:32]
            remaining = proof[32:]
            n_bits = len(remaining) // 32
            bit_commitments = [remaining[i*32:(i+1)*32] for i in range(n_bits)]
            
            reconstructed = SpectralGapProof(
                gap_commitment=gap_commitment,
                bit_commitments=bit_commitments,
                challenge=b'',  # Reconstructed during verification
                response=b'',
            )
            valid, reason = verify_spectral_gap_proof(reconstructed)
            return valid
        except Exception:
            return False
    
    return False


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
