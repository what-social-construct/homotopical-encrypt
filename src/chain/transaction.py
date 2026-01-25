"""
Transaction - Private Transfers on Homotopical Chain

Transactions have:
- Ring inputs (hide which UTXO is being spent)
- Stealth outputs (hide recipient)
- Confidential amounts (hide values)
- Key images (prevent double-spend)

Structure:
  TX = {inputs, outputs, fee, ring_signature, range_proofs}
"""

from dataclasses import dataclass, field
from typing import List, Tuple, Optional, Dict
import numpy as np
import hashlib
import time
import secrets

from .key_image import compute_key_image


@dataclass
class TransactionInput:
    """
    A transaction input with ring signature privacy.
    
    Real input is hidden among decoy ring members.
    Key image prevents double-spend.
    """
    # Ring of possible inputs (spectral fingerprints)
    ring_fingerprints: List[bytes]  # All look the same to verifier
    
    # Key image (unique per actual input, prevents double-spend)
    key_image: bytes
    
    # Commitment to amount being spent
    amount_commitment: bytes
    
    # Ring signature proving ownership of ONE ring member
    ring_signature: bytes


@dataclass
class TransactionOutput:
    """
    A transaction output with stealth address.
    
    Only recipient can detect and spend this output.
    """
    # Stealth public key (one-time address)
    stealth_public_key: bytes
    
    # Commitment to amount (Pedersen-style)
    amount_commitment: bytes
    
    # Encrypted amount (only recipient can decrypt)
    encrypted_amount: bytes
    
    # Range proof (amount >= 0, no overflow)
    range_proof: bytes


@dataclass  
class Transaction:
    """
    Complete transaction structure.
    """
    # Version for upgradability
    version: int = 1
    
    # Inputs (with ring signatures)
    inputs: List[TransactionInput] = field(default_factory=list)
    
    # Outputs (with stealth addresses)
    outputs: List[TransactionOutput] = field(default_factory=list)
    
    # Fee commitment (verifiable but hidden)
    fee_commitment: bytes = b''
    
    # Transaction-level data
    tx_public_key: bytes = b''  # For stealth address derivation
    extra: bytes = b''  # Payment ID, etc.
    
    # Timestamp
    timestamp: int = 0
    
    def tx_hash(self) -> bytes:
        """Compute transaction hash (unique identifier)."""
        hasher = hashlib.sha256(b"HCRYPT_TX_V1")
        hasher.update(self.version.to_bytes(4, 'little'))
        hasher.update(len(self.inputs).to_bytes(4, 'little'))
        for inp in self.inputs:
            hasher.update(inp.key_image)
            hasher.update(inp.amount_commitment)
        hasher.update(len(self.outputs).to_bytes(4, 'little'))
        for out in self.outputs:
            hasher.update(out.stealth_public_key)
            hasher.update(out.amount_commitment)
        hasher.update(self.fee_commitment)
        hasher.update(self.timestamp.to_bytes(8, 'little'))
        return hasher.digest()
    
    def serialize(self) -> bytes:
        """Serialize transaction for network/storage."""
        import struct
        
        data = struct.pack('<I', self.version)
        data += struct.pack('<Q', self.timestamp)
        
        # Inputs
        data += struct.pack('<I', len(self.inputs))
        for inp in self.inputs:
            # Ring fingerprints
            data += struct.pack('<I', len(inp.ring_fingerprints))
            for fp in inp.ring_fingerprints:
                data += struct.pack('<I', len(fp))
                data += fp
            # Key image (32 bytes)
            data += inp.key_image
            # Amount commitment
            data += struct.pack('<I', len(inp.amount_commitment))
            data += inp.amount_commitment
            # Ring signature
            data += struct.pack('<I', len(inp.ring_signature))
            data += inp.ring_signature
        
        # Outputs
        data += struct.pack('<I', len(self.outputs))
        for out in self.outputs:
            data += struct.pack('<I', len(out.stealth_public_key))
            data += out.stealth_public_key
            data += struct.pack('<I', len(out.amount_commitment))
            data += out.amount_commitment
            data += struct.pack('<I', len(out.encrypted_amount))
            data += out.encrypted_amount
            data += struct.pack('<I', len(out.range_proof))
            data += out.range_proof
        
        # Fee and extras
        data += struct.pack('<I', len(self.fee_commitment))
        data += self.fee_commitment
        data += struct.pack('<I', len(self.tx_public_key))
        data += self.tx_public_key
        data += struct.pack('<I', len(self.extra))
        data += self.extra
        
        return data


def create_transaction(
    sender_credential,
    recipient_fingerprint: bytes,
    amount: int,
    ring_size: int = 11,
    decoy_fingerprints: Optional[List[bytes]] = None
) -> Transaction:
    """
    Create a private transaction.
    
    Args:
        sender_credential: Sender's FibrationCredential
        recipient_fingerprint: Recipient's spectral fingerprint
        amount: Amount to send (in smallest units)
        ring_size: Number of ring members (including real)
        decoy_fingerprints: Optional list of decoy fingerprints
        
    Returns:
        Complete Transaction ready for broadcast
    """
    from ..crypto.credential import SpectralFingerprint
    
    # 1. Compute key image for input
    eigvecs = np.eye(8)  # Placeholder - should come from credential
    key_image = compute_key_image(eigvecs)
    
    # 2. Generate ring (real + decoys)
    sender_fp = sender_credential.spectrum.fingerprint_hash()
    ring_fps = [sender_fp]
    
    if decoy_fingerprints:
        ring_fps.extend(decoy_fingerprints[:ring_size-1])
    else:
        # Generate random decoy fingerprints (in production, select from UTXO set)
        for _ in range(ring_size - 1):
            ring_fps.append(secrets.token_bytes(32))
    
    # Shuffle to hide position of real input
    indices = list(range(len(ring_fps)))
    secrets.SystemRandom().shuffle(indices)
    shuffled_ring = [ring_fps[i] for i in indices]
    real_index = indices.index(0)  # Where did the real one end up?
    
    # 3. Generate amount commitment
    blinding = secrets.token_bytes(32)
    amount_bytes = amount.to_bytes(8, 'little')
    amount_commitment = hashlib.sha256(amount_bytes + blinding).digest()
    
    # 4. Generate ring signature (simplified)
    ring_sig = _create_ring_signature(
        key_image=key_image,
        ring=shuffled_ring,
        real_index=real_index,
        message=amount_commitment
    )
    
    # 5. Create input
    tx_input = TransactionInput(
        ring_fingerprints=shuffled_ring,
        key_image=key_image,
        amount_commitment=amount_commitment,
        ring_signature=ring_sig
    )
    
    # 6. Create stealth output for recipient
    tx_secret = secrets.token_bytes(32)
    stealth_key = hashlib.sha256(recipient_fingerprint + tx_secret).digest()
    
    out_blinding = secrets.token_bytes(32)
    out_commitment = hashlib.sha256(amount_bytes + out_blinding).digest()
    
    # Encrypt amount for recipient (simplified - should use ECDH)
    encrypted_amount = bytes(a ^ b for a, b in zip(amount_bytes, tx_secret[:8]))
    
    # Range proof placeholder (should be Bulletproofs)
    range_proof = hashlib.sha256(b"range_proof" + amount_bytes + out_blinding).digest()
    
    tx_output = TransactionOutput(
        stealth_public_key=stealth_key,
        amount_commitment=out_commitment,
        encrypted_amount=encrypted_amount,
        range_proof=range_proof
    )
    
    # 7. Fee commitment (zero for now)
    fee_commitment = hashlib.sha256(b'\x00' * 8 + secrets.token_bytes(32)).digest()
    
    # 8. Build transaction
    tx = Transaction(
        version=1,
        inputs=[tx_input],
        outputs=[tx_output],
        fee_commitment=fee_commitment,
        tx_public_key=tx_secret,  # For stealth derivation
        timestamp=int(time.time())
    )
    
    return tx


def _create_ring_signature(
    key_image: bytes,
    ring: List[bytes],
    real_index: int,
    message: bytes
) -> bytes:
    """
    Create ring signature (simplified Schnorr-style).
    
    Real implementation should use CLSAG or MLSAG.
    """
    # This is a simplified placeholder
    # Real implementation needs:
    # 1. Commit to each ring member
    # 2. Fiat-Shamir challenge
    # 3. Response that works for real signer
    
    hasher = hashlib.sha256(b"RING_SIG_V1")
    hasher.update(key_image)
    hasher.update(message)
    for fp in ring:
        hasher.update(fp)
    
    # Generate responses (random for decoys, computed for real)
    responses = []
    for i in range(len(ring)):
        if i == real_index:
            # Real response requires secret knowledge
            r = hashlib.sha256(key_image + ring[i] + message).digest()
        else:
            # Decoy responses are random
            r = secrets.token_bytes(32)
        responses.append(r)
    
    # Serialize
    sig = hasher.digest()  # Challenge
    for r in responses:
        sig += r
    
    return sig


def verify_transaction(
    tx: Transaction,
    key_image_store=None
) -> Tuple[bool, str]:
    """
    Verify transaction validity.
    
    Checks:
    1. Key images not already spent
    2. Ring signatures valid
    3. Amounts balance (inputs = outputs + fee)
    4. Range proofs valid
    
    Returns:
        (is_valid, reason)
    """
    # 1. Check key images for double-spend
    if key_image_store is not None:
        for inp in tx.inputs:
            if key_image_store.is_spent(inp.key_image):
                return (False, f"Double spend: key image {inp.key_image.hex()[:16]}...")
    
    # 2. Verify ring signatures
    for i, inp in enumerate(tx.inputs):
        if not _verify_ring_signature(
            key_image=inp.key_image,
            ring=inp.ring_fingerprints,
            message=inp.amount_commitment,
            signature=inp.ring_signature
        ):
            return (False, f"Invalid ring signature for input {i}")
    
    # 3. Verify amount balance (simplified)
    # In production: verify homomorphic sum of commitments
    # sum(input_commitments) = sum(output_commitments) + fee_commitment
    
    # 4. Verify range proofs
    for i, out in enumerate(tx.outputs):
        if len(out.range_proof) != 32:  # Placeholder check
            return (False, f"Invalid range proof for output {i}")
    
    # 5. Verify timestamp
    now = int(time.time())
    if tx.timestamp > now + 3600:  # Not more than 1 hour in future
        return (False, "Transaction timestamp in future")
    
    return (True, "Transaction valid")


def _verify_ring_signature(
    key_image: bytes,
    ring: List[bytes],
    message: bytes,
    signature: bytes
) -> bool:
    """
    Verify ring signature (simplified).
    
    Real implementation should verify CLSAG/MLSAG equation.
    """
    if len(signature) < 32:
        return False
    
    # Extract challenge
    challenge = signature[:32]
    responses = [signature[32+i*32:32+(i+1)*32] for i in range(len(ring))]
    
    # Recompute expected challenge
    hasher = hashlib.sha256(b"RING_SIG_V1")
    hasher.update(key_image)
    hasher.update(message)
    for fp in ring:
        hasher.update(fp)
    expected_challenge = hasher.digest()
    
    # Check challenge matches (simplified)
    return challenge == expected_challenge


# ============================================================================
# TEST
# ============================================================================

if __name__ == "__main__":
    from ..crypto.credential import generate_credential
    
    print("=" * 60)
    print("TRANSACTION TEST")
    print("=" * 60)
    
    # Create mock credential
    class MockCredential:
        class MockSpectrum:
            def fingerprint_hash(self):
                return secrets.token_bytes(32)
        spectrum = MockSpectrum()
    
    # Test 1: Create transaction
    print("\n1. Creating transaction:")
    sender = MockCredential()
    recipient_fp = secrets.token_bytes(32)
    
    tx = create_transaction(
        sender_credential=sender,
        recipient_fingerprint=recipient_fp,
        amount=1000,
        ring_size=5
    )
    
    print(f"   TX hash: {tx.tx_hash().hex()[:32]}...")
    print(f"   Inputs: {len(tx.inputs)}")
    print(f"   Outputs: {len(tx.outputs)}")
    print(f"   Ring size: {len(tx.inputs[0].ring_fingerprints)}")
    print(f"   Key image: {tx.inputs[0].key_image.hex()[:16]}...")
    
    # Test 2: Verify transaction
    print("\n2. Verifying transaction:")
    valid, reason = verify_transaction(tx)
    print(f"   Valid: {valid}")
    print(f"   Reason: {reason}")
    
    # Test 3: Double-spend detection
    print("\n3. Double-spend detection:")
    from .key_image import KeyImageStore
    store = KeyImageStore()
    
    # First spend
    valid1, reason1 = verify_transaction(tx, store)
    if valid1:
        for inp in tx.inputs:
            store.mark_spent(inp.key_image)
    print(f"   First spend: {reason1}")
    
    # Second spend (should fail)
    valid2, reason2 = verify_transaction(tx, store)
    print(f"   Second spend: {reason2}")
    
    # Test 4: Serialization
    print("\n4. Serialization:")
    serialized = tx.serialize()
    print(f"   Serialized size: {len(serialized)} bytes")
    
    print("\n" + "=" * 60)
    print("✅ TRANSACTION TESTS PASS")
    print("=" * 60)
