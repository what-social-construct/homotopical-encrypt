"""
Production Hardening Tests

6 test suites covering consensus-critical hardening:

1. Fixed-Point Spectral Bounds
   quantization, round-trip, tolerance band, boundary detection

2. Credential Age / Expiry
   too young, valid range, expired, future credential

3. Auto Key Rotation
   same homotopy class, different fingerprint, Betti preservation

4. VRF Slot Assignment
   evaluation, determinism, slot assignment, score range

5. Equivocation Detection
   first block OK, second block at same epoch = evidence

6. Plücker Centrality
   with stalk data → Grassmann, without → Fiedler fallback
"""

import sys
import hashlib
import numpy as np
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from src.crypto.credential import (
    generate_credential,
    rotate_credential,
    should_rotate,
    ROTATION_PERIOD_BLOCKS,
)


# =============================================================================
# 1. FIXED-POINT SPECTRAL BOUNDS
# =============================================================================

def test_fixed_point_round_trip():
    """gap → fixed → gap preserves ~9 decimal digits."""
    from src.proofs.spectral_bounds import (
        gap_to_fixed, fixed_to_gap, POV_LOWER, POV_UPPER,
    )
    for gap in [POV_LOWER, 1.0, 1.5, 2.0, POV_UPPER, 0.123456789]:
        fixed = gap_to_fixed(gap)
        recovered = fixed_to_gap(fixed)
        assert abs(gap - recovered) < 1e-9, f"Round-trip error for {gap}: {abs(gap - recovered)}"


def test_fixed_point_deterministic_serialization():
    """serialize_gap → deserialize_gap is deterministic."""
    from src.proofs.spectral_bounds import serialize_gap, deserialize_gap, POV_LOWER

    data1 = serialize_gap(POV_LOWER)
    data2 = serialize_gap(POV_LOWER)
    assert data1 == data2, "Serialization must be deterministic"
    assert len(data1) == 8, "Must be 8 bytes"

    recovered = deserialize_gap(data1)
    assert abs(recovered - POV_LOWER) < 1e-9


def test_gap_status_boundaries():
    """Boundary values classified correctly: VALID, MARGINAL, INVALID, ZERO."""
    from src.proofs.spectral_bounds import (
        gap_in_bounds, GapStatus, POV_LOWER, POV_UPPER,
    )
    # Zero / negative
    assert gap_in_bounds(0.0) == GapStatus.ZERO
    assert gap_in_bounds(-1.0) == GapStatus.ZERO

    # Strictly invalid
    assert gap_in_bounds(0.5) == GapStatus.INVALID
    assert gap_in_bounds(3.0) == GapStatus.INVALID

    # Strictly valid (interior)
    assert gap_in_bounds(1.0) == GapStatus.VALID
    assert gap_in_bounds(2.0) == GapStatus.VALID

    # Boundary values should be MARGINAL (within tolerance of boundary)
    # Exact POV_LOWER should be marginal
    status_lower = gap_in_bounds(POV_LOWER)
    assert status_lower in (GapStatus.VALID, GapStatus.MARGINAL), \
        f"POV_LOWER should be VALID or MARGINAL, got {status_lower}"

    status_upper = gap_in_bounds(POV_UPPER)
    assert status_upper in (GapStatus.VALID, GapStatus.MARGINAL), \
        f"POV_UPPER should be VALID or MARGINAL, got {status_upper}"


def test_gap_strict_accepts_marginal():
    """gap_in_bounds_strict accepts both VALID and MARGINAL."""
    from src.proofs.spectral_bounds import (
        gap_in_bounds_strict, POV_LOWER, POV_UPPER,
    )
    assert gap_in_bounds_strict(1.0)  # Valid interior
    assert gap_in_bounds_strict(POV_LOWER)  # Boundary
    assert gap_in_bounds_strict(POV_UPPER)  # Boundary
    assert not gap_in_bounds_strict(0.5)  # Invalid
    assert not gap_in_bounds_strict(0.0)  # Zero
    assert not gap_in_bounds_strict(3.0)  # Invalid


# =============================================================================
# 2. CREDENTIAL AGE / EXPIRY
# =============================================================================

def test_credential_age_too_young():
    """Credential registered 5 blocks ago: too young (min=10)."""
    from src.proofs.spectral_bounds import credential_age_valid

    valid, reason = credential_age_valid(registration_height=95, current_height=100)
    assert not valid
    assert "too young" in reason


def test_credential_age_valid_range():
    """Credential registered 500 blocks ago: valid."""
    from src.proofs.spectral_bounds import credential_age_valid

    valid, reason = credential_age_valid(registration_height=500, current_height=1000)
    assert valid
    assert "valid" in reason


def test_credential_age_expired():
    """Credential registered 200k blocks ago: expired (max=100k)."""
    from src.proofs.spectral_bounds import credential_age_valid

    valid, reason = credential_age_valid(registration_height=0, current_height=200_000)
    assert not valid
    assert "expired" in reason


def test_credential_age_future():
    """Credential from future: rejected."""
    from src.proofs.spectral_bounds import credential_age_valid

    valid, reason = credential_age_valid(registration_height=200, current_height=100)
    assert not valid
    assert "future" in reason


# =============================================================================
# 3. AUTO KEY ROTATION
# =============================================================================

def test_rotation_preserves_homotopy_class():
    """Rotated credential: same Betti numbers, same topology, different fingerprint."""
    cred = generate_credential(
        parties=["alice", "bob"],
        connections=[("alice", "bob")],
        security_parameter=128, enforce_min_harmonic=False,
    )
    rotated = rotate_credential(cred, enforce_min_harmonic=False)

    # Same homotopy class (Betti numbers)
    assert cred.spectrum.betti_numbers == rotated.spectrum.betti_numbers, \
        "Betti numbers must be preserved after rotation"

    # Same topology structure
    assert len(cred.topology[0]) == len(rotated.topology[0]), \
        "Vertex count must match"
    assert len(cred.topology[1]) == len(rotated.topology[1]), \
        "Edge count must match"

    # Different spectral fingerprint (new random fibration)
    assert cred.spectrum.fingerprint_hash() != rotated.spectrum.fingerprint_hash(), \
        "Fingerprint must change after rotation (new random fibration)"

    # Same parties
    assert cred.parties == rotated.parties


def test_rotation_unlinkable():
    """Two rotated credentials from same original: fingerprints differ from each other."""
    cred = generate_credential(
        parties=["alice", "bob"],
        connections=[("alice", "bob")],
        security_parameter=128, enforce_min_harmonic=False,
    )
    rot1 = rotate_credential(cred, enforce_min_harmonic=False)
    rot2 = rotate_credential(cred, enforce_min_harmonic=False)

    fp_orig = cred.spectrum.fingerprint_hash()
    fp_rot1 = rot1.spectrum.fingerprint_hash()
    fp_rot2 = rot2.spectrum.fingerprint_hash()

    assert fp_orig != fp_rot1
    assert fp_orig != fp_rot2
    assert fp_rot1 != fp_rot2, "Two rotations must produce different fingerprints"


def test_should_rotate_timing():
    """should_rotate triggers at correct block age."""
    assert not should_rotate(0, 500, period=1000)   # 500 < 1000
    assert not should_rotate(0, 999, period=1000)   # 999 < 1000
    assert should_rotate(0, 1000, period=1000)       # 1000 >= 1000
    assert should_rotate(0, 2000, period=1000)       # 2000 >= 1000


# =============================================================================
# 4. VRF SLOT ASSIGNMENT
# =============================================================================

def test_vrf_evaluation_deterministic():
    """Same key + same input → same VRF output."""
    from src.consensus.vrf_slots import VRFKey, vrf_evaluate

    cred = generate_credential(
        parties=["val_a", "val_b"],
        connections=[("val_a", "val_b")],
        security_parameter=128, enforce_min_harmonic=False,
    )
    key = VRFKey.from_credential(cred)
    prev_hash = b'\x00' * 32
    epoch = 42

    out1 = vrf_evaluate(key, prev_hash, epoch)
    out2 = vrf_evaluate(key, prev_hash, epoch)

    assert out1.output == out2.output, "VRF must be deterministic"
    assert out1.score == out2.score
    assert out1.proof == out2.proof


def test_vrf_different_epochs_differ():
    """Different epochs → different VRF outputs."""
    from src.consensus.vrf_slots import VRFKey, vrf_evaluate

    cred = generate_credential(
        parties=["val_a", "val_b"],
        connections=[("val_a", "val_b")],
        security_parameter=128, enforce_min_harmonic=False,
    )
    key = VRFKey.from_credential(cred)
    prev_hash = b'\x00' * 32

    out1 = vrf_evaluate(key, prev_hash, epoch=0)
    out2 = vrf_evaluate(key, prev_hash, epoch=1)

    assert out1.output != out2.output, "Different epochs must give different outputs"


def test_vrf_score_in_unit_interval():
    """VRF score is always in [0, 1)."""
    from src.consensus.vrf_slots import VRFKey, vrf_evaluate

    cred = generate_credential(
        parties=["val_a", "val_b"],
        connections=[("val_a", "val_b")],
        security_parameter=128, enforce_min_harmonic=False,
    )
    key = VRFKey.from_credential(cred)

    for epoch in range(50):
        out = vrf_evaluate(key, b'\x00' * 32, epoch)
        assert 0 <= out.score < 1.0, f"Score {out.score} outside [0,1) at epoch {epoch}"


def test_vrf_serialization_round_trip():
    """VRFOutput → bytes → VRFOutput."""
    from src.consensus.vrf_slots import VRFKey, VRFOutput, vrf_evaluate

    cred = generate_credential(
        parties=["val_a", "val_b"],
        connections=[("val_a", "val_b")],
        security_parameter=128, enforce_min_harmonic=False,
    )
    key = VRFKey.from_credential(cred)
    out = vrf_evaluate(key, b'\xab' * 32, epoch=7)

    data = out.to_bytes()
    assert len(data) > 0

    restored = VRFOutput.from_bytes(data)
    assert restored.output == out.output
    assert restored.proof == out.proof
    assert restored.epoch == out.epoch


# =============================================================================
# 5. EQUIVOCATION DETECTION
# =============================================================================

def test_equivocation_first_block_ok():
    """First block at an epoch: no equivocation."""
    from src.consensus.vrf_slots import EquivocationTracker

    tracker = EquivocationTracker()
    fp = hashlib.sha256(b"validator").digest()

    evidence = tracker.record_block(
        identity_hash=fp,
        epoch=0,
        block_hash=hashlib.sha256(b"block_0").digest(),
        vrf_data=b'\x00' * 32,
    )
    assert evidence is None, "First block at epoch must not trigger equivocation"


def test_equivocation_second_block_detected():
    """Two different blocks at same epoch from same validator = equivocation."""
    from src.consensus.vrf_slots import EquivocationTracker

    tracker = EquivocationTracker()
    fp = hashlib.sha256(b"validator").digest()

    # First block
    evidence1 = tracker.record_block(
        identity_hash=fp,
        epoch=5,
        block_hash=hashlib.sha256(b"block_A").digest(),
        vrf_data=b'\xaa' * 32,
    )
    assert evidence1 is None

    # Second DIFFERENT block at same epoch
    evidence2 = tracker.record_block(
        identity_hash=fp,
        epoch=5,
        block_hash=hashlib.sha256(b"block_B").digest(),
        vrf_data=b'\xbb' * 32,
    )
    assert evidence2 is not None, "Must detect equivocation"
    assert evidence2.identity_hash == fp
    assert evidence2.epoch == 5
    assert evidence2.block_hash_1 != evidence2.block_hash_2


def test_equivocation_same_block_ok():
    """Same block hash at same epoch (e.g., relay): NOT equivocation."""
    from src.consensus.vrf_slots import EquivocationTracker

    tracker = EquivocationTracker()
    fp = hashlib.sha256(b"validator").digest()
    block_hash = hashlib.sha256(b"block_same").digest()

    tracker.record_block(fp, epoch=0, block_hash=block_hash, vrf_data=b'\x00' * 32)
    evidence = tracker.record_block(fp, epoch=0, block_hash=block_hash, vrf_data=b'\x00' * 32)

    assert evidence is None, "Same block hash at same epoch is not equivocation"


def test_equivocation_different_validators_ok():
    """Different validators at same epoch: NOT equivocation."""
    from src.consensus.vrf_slots import EquivocationTracker

    tracker = EquivocationTracker()
    fp1 = hashlib.sha256(b"validator_1").digest()
    fp2 = hashlib.sha256(b"validator_2").digest()

    tracker.record_block(fp1, epoch=0, block_hash=b'\xaa' * 32, vrf_data=b'\x00' * 32)
    evidence = tracker.record_block(fp2, epoch=0, block_hash=b'\xbb' * 32, vrf_data=b'\x00' * 32)

    assert evidence is None, "Different validators at same epoch is normal"


# =============================================================================
# 6. PLÜCKER CENTRALITY
# =============================================================================

def test_plucker_centrality_with_stalks():
    """Validators with stalk data → Plücker centrality (Grassmann distance)."""
    from src.consensus.validator_selection import ValidatorSet

    topology = {
        0: [(0,), (1,), (2,)],
        1: [(0, 1), (1, 2), (0, 2)],
        2: [],
    }

    vs = ValidatorSet(topology)
    np.random.seed(42)

    # Consensus direction
    consensus_dir = np.array([[1.0, 1.0, 0.0],
                               [0.0, 1.0, 1.0]])

    fps = []
    for i in range(3):
        fp = hashlib.sha256(f"val_{i}".encode()).digest()
        # V1 (center) most aligned with consensus
        noise = np.random.randn(2, 3) * (abs(i - 1) * 0.5 + 0.1)
        stalk = consensus_dir + noise
        vs.register_validator(fp, i, stalk_data=stalk)
        fps.append(fp)

    assert vs._has_stalk_data(), "Must detect stalk data availability"

    centralities = vs.compute_spectral_centrality()

    # All validators have positive centrality
    for fp in fps:
        assert centralities.get(fp, 0) > 0, "Each validator must have positive centrality"

    # Probabilities sum to 1
    total = sum(centralities.values())
    assert abs(total - 1.0) < 1e-6, f"Must sum to 1, got {total}"


def test_uniform_weights_without_stalks():
    """Without stalk data, gets uniform weights (no Fiedler — geometric coherence required)."""
    from src.consensus.validator_selection import ValidatorSet

    topology = {
        0: [(0,), (1,), (2,)],
        1: [(0, 1), (1, 2), (0, 2)],
        2: [],
    }

    vs = ValidatorSet(topology)
    fps = []
    for i in range(3):
        fp = hashlib.sha256(f"val_{i}".encode()).digest()
        vs.register_validator(fp, i)  # No stalk_data
        fps.append(fp)

    assert not vs._has_stalk_data(), "No stalk data → should not use Plücker"

    centralities = vs.compute_spectral_centrality()
    for fp in fps:
        assert centralities.get(fp, 0) > 0

    total = sum(centralities.values())
    assert abs(total - 1.0) < 1e-6


def test_plucker_consensus_subspace():
    """Karcher mean consensus subspace computable from validator stalks."""
    from src.consensus.validator_selection import ValidatorSet

    topology = {
        0: [(0,), (1,), (2,), (3,)],
        1: [(0, 1), (1, 2), (2, 3), (0, 3)],
        2: [],
    }

    vs = ValidatorSet(topology)
    np.random.seed(123)

    for i in range(4):
        fp = hashlib.sha256(f"val_{i}".encode()).digest()
        stalk = np.random.randn(3, 4)  # 3 stalk vectors in R^4
        vs.register_validator(fp, i, stalk_data=stalk)

    consensus = vs.compute_consensus_subspace()
    assert consensus is not None, "Must compute consensus subspace"
    assert consensus.shape[0] == consensus.shape[1], "Must be square projection"

    # Idempotent: P² = P (projection property)
    assert np.allclose(consensus @ consensus, consensus, atol=1e-6), \
        "Consensus projector must be idempotent"


# =============================================================================
# 7. BLOCK AS SHEAF SECTION
# =============================================================================

def test_block_section_from_block():
    """Block decomposes into 3-layer sheaf section."""
    from src.chain.block import create_block
    from src.chain.block_section import BlockSection
    import secrets

    class MockCred:
        class MockSpectrum:
            def fingerprint_hash(self):
                return secrets.token_bytes(32)
        spectrum = MockSpectrum()

    block = create_block(
        transactions=[],
        prev_hash=b'\x00' * 32,
        height=0,
        producer_credential=MockCred(),
        spectral_gap=1.5,
    )

    section = BlockSection.from_block(block)

    # C⁰ stalks populated (PRIVATE + PUBLIC)
    assert section.public_stalk is not None
    assert section.private_stalk is not None

    # Correct dimensions
    assert len(section.public_stalk.data) == 1      # PUBLIC_STALK dim=1
    assert len(section.private_stalk.data) == 256    # PRIVATE_STALK dim=256

    # C¹ ZK layer = cochain_root (32 bytes hash)
    assert section.cochain_root is not None
    assert len(section.cochain_root) == 32

    # Gap consistent across layers (private[0] == public[0])
    assert abs(section.public_stalk.data[0] - 1.5) < 1e-6
    assert abs(section.private_stalk.data[0] - 1.5) < 1e-6


def test_block_section_coherence():
    """Section passes 3-layer coherence check."""
    from src.chain.block import create_block
    from src.chain.block_section import BlockSection
    import secrets

    class MockCred:
        class MockSpectrum:
            def fingerprint_hash(self):
                return secrets.token_bytes(32)
        spectrum = MockSpectrum()

    block = create_block(
        transactions=[],
        prev_hash=b'\x00' * 32,
        height=5,
        producer_credential=MockCred(),
        spectral_gap=2.0,
    )

    section = BlockSection.from_block(block)
    valid, reason = section.verify_coherence()
    assert valid, f"Coherence check failed: {reason}"


def test_block_section_layer_restriction():
    """Restricting to public layer gives light-client view."""
    from src.chain.block import create_block
    from src.chain.block_section import BlockSection
    import secrets

    class MockCred:
        class MockSpectrum:
            def fingerprint_hash(self):
                return secrets.token_bytes(32)
        spectrum = MockSpectrum()

    block = create_block(
        transactions=[],
        prev_hash=b'\xab' * 32,
        height=42,
        producer_credential=MockCred(),
        spectral_gap=1.8,
    )

    section = BlockSection.from_block(block)
    pub = section.restrict_public()

    assert pub["height"] == 42
    assert abs(pub["spectral_gap"] - 1.8) < 1e-6
    assert pub["tx_count"] == 0
    assert len(pub["block_hash"]) == 64  # hex string


def test_chain_section_bundle_coherence():
    """Chain of sections: edge restriction maps (prev_hash linkage) verified."""
    from src.chain.block import create_block
    from src.chain.block_section import BlockSection, ChainSectionBundle
    import secrets

    class MockCred:
        class MockSpectrum:
            def fingerprint_hash(self):
                return secrets.token_bytes(32)
        spectrum = MockSpectrum()

    bundle = ChainSectionBundle()
    prev_hash = b'\x00' * 32

    for h in range(5):
        block = create_block(
            transactions=[],
            prev_hash=prev_hash,
            height=h,
            producer_credential=MockCred(),
            spectral_gap=1.5,
        )
        bundle.add_block(block)
        prev_hash = block.block_hash()

    assert bundle.height() == 5

    valid, violations = bundle.verify_chain_coherence()
    assert valid, f"Chain coherence failed: {violations}"


def test_section_serialization_round_trip():
    """Section serialize → deserialize preserves stalk data."""
    from src.chain.block import create_block
    from src.chain.block_section import BlockSection
    import secrets

    class MockCred:
        class MockSpectrum:
            def fingerprint_hash(self):
                return secrets.token_bytes(32)
        spectrum = MockSpectrum()

    block = create_block(
        transactions=[],
        prev_hash=b'\x00' * 32,
        height=7,
        producer_credential=MockCred(),
        spectral_gap=2.2,
    )

    section = BlockSection.from_block(block)

    # Full section round-trip
    data = section.serialize()
    restored = BlockSection.deserialize(data)
    assert restored.height == 7
    assert restored.block_hash == section.block_hash
    assert restored.prev_hash == section.prev_hash
    assert abs(restored.public_stalk.data[0] - 2.2) < 1e-6
    assert abs(restored.private_stalk.data[0] - 2.2) < 1e-6


def test_chain_store_section_persistence():
    """ChainStore stores + loads sections across 3 layer directories."""
    import tempfile
    import secrets
    from src.chain.block import create_block
    from src.chain.chain_store import ChainStore

    class MockCred:
        class MockSpectrum:
            def fingerprint_hash(self):
                return secrets.token_bytes(32)
        spectrum = MockSpectrum()

    with tempfile.TemporaryDirectory() as tmpdir:
        store = ChainStore(tmpdir)

        block = create_block(
            transactions=[],
            prev_hash=b'\x00' * 32,
            height=0,
            producer_credential=MockCred(),
            spectral_gap=1.5,
        )
        store.store_block(block)

        # Load section back
        loaded = store.load_section(0)
        assert loaded is not None, "Must load section"
        assert loaded.height == 0
        assert abs(loaded.public_stalk.data[0] - 1.5) < 1e-6

        # Coherence still holds after round-trip
        valid, reason = loaded.verify_coherence()
        assert valid, f"Round-trip coherence failed: {reason}"

        # Section bundle tracks it
        bundle = store.get_section_bundle()
        assert bundle.height() == 1


# =============================================================================
# RUNNER
# =============================================================================

if __name__ == "__main__":
    import traceback

    tests = [
        # 1. Fixed-point spectral bounds
        test_fixed_point_round_trip,
        test_fixed_point_deterministic_serialization,
        test_gap_status_boundaries,
        test_gap_strict_accepts_marginal,
        # 2. Credential age
        test_credential_age_too_young,
        test_credential_age_valid_range,
        test_credential_age_expired,
        test_credential_age_future,
        # 3. Key rotation
        test_rotation_preserves_homotopy_class,
        test_rotation_unlinkable,
        test_should_rotate_timing,
        # 4. VRF
        test_vrf_evaluation_deterministic,
        test_vrf_different_epochs_differ,
        test_vrf_score_in_unit_interval,
        test_vrf_serialization_round_trip,
        # 5. Equivocation
        test_equivocation_first_block_ok,
        test_equivocation_second_block_detected,
        test_equivocation_same_block_ok,
        test_equivocation_different_validators_ok,
        # 6. Plücker centrality
        test_plucker_centrality_with_stalks,
        test_uniform_weights_without_stalks,
        test_plucker_consensus_subspace,
    ]

    passed = 0
    failed = 0
    for test in tests:
        try:
            test()
            print(f"  ✅ {test.__name__}")
            passed += 1
        except Exception as e:
            print(f"  ❌ {test.__name__}: {e}")
            traceback.print_exc()
            failed += 1

    print(f"\n{'=' * 60}")
    print(f"Results: {passed} passed, {failed} failed")
    print(f"{'=' * 60}")
