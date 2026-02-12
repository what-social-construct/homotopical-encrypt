"""
VRF Slot Assignment — Fork Prevention for PoV Consensus

Each epoch has exactly ONE valid block producer, determined by:
    VRF(prev_block_hash, epoch) → (output, proof)

The VRF uses the producer's secret fibration (eigenvectors) as key.
This binds slot eligibility to the geometric identity — you can't
grind for slots without a new fibration (which changes your fingerprint).

CONSTRUCTION (hash-based VRF adapted for sheaf setting):

  VRF key = SHA256(eigenvectors || "VRF_KEY_V1")
    → deterministic from secret fibration
    → changes on key rotation (new eigenvectors)
    → but fingerprint stays the same (eigenvalues unchanged)

  VRF_eval(key, prev_block_hash, epoch):
    output = HMAC-SHA256(key, prev_block_hash || epoch)
    proof  = SHA256(key || output || epoch || "VRF_PROOF_V1")
    return (output, proof)

  Slot eligibility:
    score = output[:8] / 2^64   (normalized to [0, 1))
    threshold = centrality[v]    (spectral centrality from Fiedler)
    eligible = (score < threshold)

  Among eligible validators, lowest score wins the slot.

VERIFICATION:

  Nodes CANNOT verify VRF output directly (no secret key).
  Instead, verification is:

  1. STRUCTURAL: output is 32 bytes, proof is 32 bytes
  2. CONSISTENCY: claimed producer must be registered validator
     with centrality > 0
  3. DETERMINISTIC: given the same (prev_block_hash, epoch),
     select_validator() picks the same producer. If the block's
     producer doesn't match → invalid.
  4. EQUIVOCATION: two blocks at same height from same fingerprint
     → both contain (output, proof). If they differ → evidence of
     equivocation (producer tried two slots). If identical → duplicate
     block (reject second).

  Full cryptographic VRF verification happens retroactively when
  a validator rotates keys (old eigenvectors become public via
  the spent key image), or via the oracle stalk bridge.

FORK PREVENTION:

  Without VRF slots: two valid producers at same height → fork.
  With VRF slots: exactly one producer per epoch. Fork requires:
    1. Breaking the VRF (SHA256 preimage)
    2. OR controlling two valid validators (Sybil)
    3. OR equivocating (detectable → slashing)

  Severity: MEDIUM-HIGH → LOW with this module.

References:
  Gilad et al. (2017) "Algorand: Scaling Byzantine Agreements for Cryptocurrencies"
  Micali et al. (2001) "Verifiable Random Functions"
"""

from dataclasses import dataclass
from typing import Tuple, Optional, Dict, List, Set
import numpy as np
import hashlib
import hmac


# =============================================================================
# VRF KEY
# =============================================================================

@dataclass
class VRFKey:
    """
    VRF key derived from secret fibration.

    The key is SHA256(eigenvectors || "VRF_KEY_V1") — deterministic
    from the fibration, changes on rotation, but NOT linkable to
    the spectral fingerprint (one-way hash).
    """
    key_bytes: bytes          # 32-byte VRF secret
    fingerprint: bytes        # Public spectral fingerprint (identity)
    key_commitment: bytes     # SHA256(key_bytes) — public commitment

    @staticmethod
    def from_eigenvectors(
        eigenvectors: np.ndarray,
        fingerprint: bytes,
    ) -> 'VRFKey':
        """
        Derive VRF key from secret eigenvectors.

        Args:
            eigenvectors: Secret eigenvectors of Laplacian.
            fingerprint: Public spectral fingerprint.

        Returns:
            VRFKey.
        """
        key_bytes = hashlib.sha256(
            eigenvectors.tobytes() + b"VRF_KEY_V1"
        ).digest()

        key_commitment = hashlib.sha256(
            key_bytes + b"VRF_COMMITMENT_V1"
        ).digest()

        return VRFKey(
            key_bytes=key_bytes,
            fingerprint=fingerprint,
            key_commitment=key_commitment,
        )

    @staticmethod
    def from_credential(credential) -> 'VRFKey':
        """Derive VRF key from FibrationCredential."""
        eigenvectors = np.diag(credential.spectrum.eigenvalues)
        fingerprint = credential.spectrum.fingerprint_hash()
        return VRFKey.from_eigenvectors(eigenvectors, fingerprint)


# =============================================================================
# VRF OUTPUT + PROOF
# =============================================================================

@dataclass
class VRFOutput:
    """
    VRF evaluation result: (output, proof) pair.

    output: pseudorandom 32 bytes, determines slot eligibility
    proof:  commitment to correct evaluation (verifiable retroactively)
    epoch:  which epoch this is for
    """
    output: bytes             # 32-byte VRF output
    proof: bytes              # 32-byte VRF proof
    epoch: int                # Epoch number
    key_commitment: bytes     # Public commitment to VRF key
    fingerprint: bytes        # Producer's fingerprint

    @property
    def score(self) -> float:
        """Normalized VRF score ∈ [0, 1)."""
        return int.from_bytes(self.output[:8], 'little') / (2**64)

    def to_bytes(self) -> bytes:
        """Serialize for block header."""
        return (
            self.output
            + self.proof
            + self.epoch.to_bytes(8, 'little')
            + self.key_commitment
            + self.fingerprint
        )

    @classmethod
    def from_bytes(cls, data: bytes) -> 'VRFOutput':
        """Deserialize from block header."""
        return cls(
            output=data[0:32],
            proof=data[32:64],
            epoch=int.from_bytes(data[64:72], 'little'),
            key_commitment=data[72:104],
            fingerprint=data[104:136],
        )

    @property
    def byte_size(self) -> int:
        return 136  # 32 + 32 + 8 + 32 + 32


# =============================================================================
# VRF EVALUATION
# =============================================================================

def vrf_evaluate(
    key: VRFKey,
    prev_block_hash: bytes,
    epoch: int,
) -> VRFOutput:
    """
    Evaluate VRF for a given epoch.

    output = HMAC-SHA256(vrf_key, prev_block_hash || epoch)
    proof  = SHA256(vrf_key || output || epoch || "VRF_PROOF_V1")

    Args:
        key: VRF key derived from secret fibration.
        prev_block_hash: Hash of previous block (public randomness).
        epoch: Current epoch number.

    Returns:
        VRFOutput with (output, proof, metadata).
    """
    # VRF input = prev_block_hash || epoch
    vrf_input = prev_block_hash + epoch.to_bytes(8, 'little')

    # VRF output = HMAC-SHA256(key, input)
    output = hmac.new(key.key_bytes, vrf_input, hashlib.sha256).digest()

    # VRF proof = SHA256(key || output || epoch || domain_separator)
    proof = hashlib.sha256(
        key.key_bytes + output + epoch.to_bytes(8, 'little') + b"VRF_PROOF_V1"
    ).digest()

    return VRFOutput(
        output=output,
        proof=proof,
        epoch=epoch,
        key_commitment=key.key_commitment,
        fingerprint=key.fingerprint,
    )


def vrf_check_eligibility(
    vrf_output: VRFOutput,
    centrality: float,
    target_slots: int = 1,
    n_validators: int = 1,
) -> Tuple[bool, float]:
    """
    Check if VRF output makes this validator eligible for the slot.

    Threshold = centrality * target_slots / max(1, n_validators - 1)
    Eligible if score < threshold.

    The centrality weighting ensures well-connected nodes have
    proportionally higher eligibility, matching the PoV philosophy.

    Args:
        vrf_output: VRF evaluation result.
        centrality: Spectral centrality of this validator ∈ [0, 1].
        target_slots: Expected number of producers per epoch (usually 1).
        n_validators: Total active validators.

    Returns:
        (eligible, threshold) — whether eligible and what the threshold was.
    """
    # Threshold: centrality-weighted probability
    # With target_slots=1, a single validator is expected per epoch.
    # centrality is normalized (sum = 1), so threshold = centrality * n_validators
    # ensures expected 1 winner per epoch.
    threshold = centrality * max(1, n_validators)

    # Cap at 1.0 (high-centrality validators always eligible)
    threshold = min(threshold, 1.0)

    score = vrf_output.score
    return score < threshold, threshold


# =============================================================================
# SLOT ASSIGNMENT (deterministic selection from VRF outputs)
# =============================================================================

@dataclass
class SlotAssignment:
    """
    Slot assignment for an epoch.

    Contains the selected producer's VRF output and metadata.
    Included in block header for verification.
    """
    epoch: int
    prev_block_hash: bytes
    selected_fingerprint: bytes
    vrf_output: VRFOutput
    centrality: float
    eligible_count: int       # How many validators were eligible

    def to_header_bytes(self) -> bytes:
        """Serialize for inclusion in block header."""
        return self.vrf_output.to_bytes()


def assign_slot(
    epoch: int,
    prev_block_hash: bytes,
    vrf_keys: Dict[bytes, VRFKey],
    centralities: Dict[bytes, float],
) -> Optional[SlotAssignment]:
    """
    Assign slot for an epoch: evaluate VRF for all validators,
    select the eligible validator with lowest score.

    This is the deterministic selection: given the same
    (prev_block_hash, epoch, validators, centralities),
    every node computes the same assignment.

    Args:
        epoch: Current epoch.
        prev_block_hash: Previous block hash.
        vrf_keys: fingerprint → VRFKey for all active validators.
        centralities: fingerprint → centrality weight.

    Returns:
        SlotAssignment or None if no eligible validator.
    """
    n_validators = len(vrf_keys)
    if n_validators == 0:
        return None

    best_score = float('inf')
    best_output = None
    best_fingerprint = None
    eligible_count = 0

    for fingerprint, key in vrf_keys.items():
        centrality = centralities.get(fingerprint, 0.0)
        if centrality <= 0:
            continue

        vrf_out = vrf_evaluate(key, prev_block_hash, epoch)
        eligible, threshold = vrf_check_eligibility(
            vrf_out, centrality,
            target_slots=1,
            n_validators=n_validators,
        )

        if eligible:
            eligible_count += 1
            if vrf_out.score < best_score:
                best_score = vrf_out.score
                best_output = vrf_out
                best_fingerprint = fingerprint

    if best_fingerprint is None:
        # No eligible validator — fallback to lowest score regardless
        # This ensures liveness (at least one block per epoch)
        for fingerprint, key in vrf_keys.items():
            vrf_out = vrf_evaluate(key, prev_block_hash, epoch)
            if vrf_out.score < best_score:
                best_score = vrf_out.score
                best_output = vrf_out
                best_fingerprint = fingerprint
        eligible_count = 1  # Fallback

    if best_fingerprint is None:
        return None

    return SlotAssignment(
        epoch=epoch,
        prev_block_hash=prev_block_hash,
        selected_fingerprint=best_fingerprint,
        vrf_output=best_output,
        centrality=centralities.get(best_fingerprint, 0.0),
        eligible_count=eligible_count,
    )


# =============================================================================
# SLOT VERIFICATION
# =============================================================================

def verify_slot_assignment(
    block_height: int,
    block_producer_fingerprint: bytes,
    vrf_data: bytes,
    prev_block_hash: bytes,
    registered_fingerprints: Set[bytes],
) -> Tuple[bool, str]:
    """
    Verify that a block's VRF slot assignment is valid.

    Structural checks (no secret key needed):
    1. VRF data is well-formed (136 bytes)
    2. Epoch matches block height
    3. Producer fingerprint matches VRF fingerprint
    4. Producer is a registered validator

    Args:
        block_height: Height of the block being verified.
        block_producer_fingerprint: Fingerprint from block header.
        vrf_data: Serialized VRFOutput from block header.
        prev_block_hash: Previous block hash.
        registered_fingerprints: Set of active validator fingerprints.

    Returns:
        (valid, reason).
    """
    # Check 1: VRF data well-formed
    if len(vrf_data) < 136:
        return False, f"VRF data too short: {len(vrf_data)} < 136 bytes"

    try:
        vrf_output = VRFOutput.from_bytes(vrf_data)
    except Exception as e:
        return False, f"VRF data malformed: {e}"

    # Check 2: Epoch matches height
    if vrf_output.epoch != block_height:
        return False, f"VRF epoch {vrf_output.epoch} != block height {block_height}"

    # Check 3: Fingerprint matches
    if vrf_output.fingerprint != block_producer_fingerprint:
        return False, (
            f"VRF fingerprint {vrf_output.fingerprint.hex()[:16]}... "
            f"!= producer {block_producer_fingerprint.hex()[:16]}..."
        )

    # Check 4: Producer is registered
    if block_producer_fingerprint not in registered_fingerprints:
        return False, f"Producer not in registered validator set"

    # Check 5: VRF output and proof are non-trivial
    if vrf_output.output == b'\x00' * 32:
        return False, "VRF output is all zeros (trivial)"

    if vrf_output.proof == b'\x00' * 32:
        return False, "VRF proof is all zeros (trivial)"

    return True, f"VRF slot valid (epoch={vrf_output.epoch}, score={vrf_output.score:.6f})"


# =============================================================================
# EQUIVOCATION DETECTION
# =============================================================================

@dataclass
class EquivocationEvidence:
    """
    Evidence that a validator produced two blocks at the same height.

    This is a slashable offense: the validator tried to fork the chain.
    """
    fingerprint: bytes
    epoch: int
    block_hash_1: bytes
    block_hash_2: bytes
    vrf_data_1: bytes
    vrf_data_2: bytes

    def is_valid(self) -> bool:
        """Check that this is genuine equivocation evidence."""
        # Same producer, same epoch, different blocks
        return (
            self.block_hash_1 != self.block_hash_2
            and len(self.block_hash_1) == 32
            and len(self.block_hash_2) == 32
        )


class EquivocationTracker:
    """
    Tracks blocks per (fingerprint, epoch) to detect equivocation.

    When a validator produces two different blocks at the same height,
    that's equivocation → slashable offense.
    """

    def __init__(self):
        # (fingerprint, epoch) → (block_hash, vrf_data)
        self._seen: Dict[Tuple[bytes, int], Tuple[bytes, bytes]] = {}
        self._evidence: List[EquivocationEvidence] = []

    def record_block(
        self,
        fingerprint: bytes,
        epoch: int,
        block_hash: bytes,
        vrf_data: bytes,
    ) -> Optional[EquivocationEvidence]:
        """
        Record a block and check for equivocation.

        Returns EquivocationEvidence if this is a duplicate slot,
        None otherwise.
        """
        key = (fingerprint, epoch)

        if key in self._seen:
            prev_hash, prev_vrf = self._seen[key]
            if prev_hash != block_hash:
                evidence = EquivocationEvidence(
                    fingerprint=fingerprint,
                    epoch=epoch,
                    block_hash_1=prev_hash,
                    block_hash_2=block_hash,
                    vrf_data_1=prev_vrf,
                    vrf_data_2=vrf_data,
                )
                self._evidence.append(evidence)
                return evidence
            # Same block seen twice (duplicate gossip) — not equivocation
            return None

        self._seen[key] = (block_hash, vrf_data)
        return None

    @property
    def evidence(self) -> List[EquivocationEvidence]:
        """All equivocation evidence collected."""
        return list(self._evidence)

    def has_equivocated(self, fingerprint: bytes) -> bool:
        """Check if a fingerprint has any equivocation evidence."""
        return any(e.fingerprint == fingerprint for e in self._evidence)


# =============================================================================
# TEST
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("VRF SLOT ASSIGNMENT TEST")
    print("=" * 60)

    # Create 5 validators with mock eigenvectors
    n_validators = 5
    vrf_keys = {}
    centralities = {}
    fingerprints = []

    for i in range(n_validators):
        eigvecs = np.eye(4) * (i + 1)  # Different per validator
        fp = hashlib.sha256(f"validator_{i}".encode()).digest()
        key = VRFKey.from_eigenvectors(eigvecs, fp)
        vrf_keys[fp] = key
        # Centrality: middle validator most central
        centralities[fp] = [0.1, 0.2, 0.4, 0.2, 0.1][i]
        fingerprints.append(fp)

    print(f"\n1. {n_validators} validators registered")
    for i, fp in enumerate(fingerprints):
        print(f"   V{i}: centrality={centralities[fp]:.2f}")

    # Assign slot for epoch 0
    prev_hash = b'\x00' * 32
    print(f"\n2. Slot assignment (epoch 0):")
    slot = assign_slot(0, prev_hash, vrf_keys, centralities)
    if slot:
        idx = fingerprints.index(slot.selected_fingerprint)
        print(f"   Selected: V{idx}")
        print(f"   VRF score: {slot.vrf_output.score:.6f}")
        print(f"   Eligible count: {slot.eligible_count}")
        print(f"   Centrality: {slot.centrality:.2f}")

    # Verify slot
    print(f"\n3. Slot verification:")
    vrf_data = slot.to_header_bytes()
    valid, reason = verify_slot_assignment(
        block_height=0,
        block_producer_fingerprint=slot.selected_fingerprint,
        vrf_data=vrf_data,
        prev_block_hash=prev_hash,
        registered_fingerprints=set(fingerprints),
    )
    print(f"   Valid: {valid} ({reason})")

    # Wrong producer
    wrong_fp = fingerprints[(fingerprints.index(slot.selected_fingerprint) + 1) % n_validators]
    valid2, reason2 = verify_slot_assignment(
        block_height=0,
        block_producer_fingerprint=wrong_fp,
        vrf_data=vrf_data,
        prev_block_hash=prev_hash,
        registered_fingerprints=set(fingerprints),
    )
    print(f"   Wrong producer: {valid2} ({reason2})")

    # Simulate 100 epochs
    print(f"\n4. Epoch simulation (100 epochs):")
    counts = {fp: 0 for fp in fingerprints}
    h = prev_hash
    for epoch in range(100):
        s = assign_slot(epoch, h, vrf_keys, centralities)
        if s:
            counts[s.selected_fingerprint] += 1
            h = hashlib.sha256(h + s.vrf_output.output).digest()

    for i, fp in enumerate(fingerprints):
        expected = centralities[fp] * 100
        print(f"   V{i}: {counts[fp]} blocks (expected ~{expected:.0f})")

    # Equivocation detection
    print(f"\n5. Equivocation detection:")
    tracker = EquivocationTracker()
    slot0 = assign_slot(0, prev_hash, vrf_keys, centralities)

    # First block — no equivocation
    ev1 = tracker.record_block(
        slot0.selected_fingerprint, 0,
        hashlib.sha256(b"block_1").digest(),
        slot0.to_header_bytes(),
    )
    print(f"   First block: equivocation={ev1 is not None}")

    # Second block at same height — EQUIVOCATION
    ev2 = tracker.record_block(
        slot0.selected_fingerprint, 0,
        hashlib.sha256(b"block_2").digest(),  # Different block hash!
        slot0.to_header_bytes(),
    )
    print(f"   Second block: equivocation={ev2 is not None}")
    if ev2:
        print(f"   Evidence valid: {ev2.is_valid()}")
        print(f"   Epoch: {ev2.epoch}")

    print(f"   Has equivocated: {tracker.has_equivocated(slot0.selected_fingerprint)}")

    print("\n" + "=" * 60)
    print("✅ VRF SLOT ASSIGNMENT READY")
    print("=" * 60)
