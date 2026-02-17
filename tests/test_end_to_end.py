"""
End-to-End Tests: Full Pipeline Integration

5 test suites covering the complete homotopical-encrypt system:

1. Block Production Pipeline
   credential → validator selection → mempool → produce → verify → commit

2. SheafState Lifecycle
   add accounts → connect → topology → spectral gap → Oracle request

3. Anonymity Proof Round-Trip
   credential → Hodge-hardness ZK proof → verify (anonymity set = ∞)

4. Key Image Double-Spend Prevention
   create key image → spend → reject double-spend

5. Chain Persistence
   produce blocks → save to ChainStore → reload → verify integrity
"""

import sys
import hashlib
import tempfile
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).parent.parent))

from src.crypto.credential import generate_credential, FibrationCredential


# =============================================================================
# 1. BLOCK PRODUCTION PIPELINE
# =============================================================================

def test_block_production_pipeline():
    """
    Full block production: credential → validator → mempool → block → verify → commit.
    
    Covers:
    - ValidatorSet with Fiedler centrality
    - Mempool add/drain
    - create_block + verify_block with √2 bounds
    - Chain growth over 2 epochs
    """
    from src.chain.block_producer import BlockProducer
    from src.chain.homotopy_transaction import create_homotopy_transaction

    # Triangle topology: 3 vertices, 3 edges
    topology = {
        0: [(0,), (1,), (2,)],
        1: [(0, 1), (1, 2), (0, 2)],
        2: [],
    }

    # Create 3 validator credentials
    credentials = []
    validators = []
    for i in range(3):
        cred = generate_credential(
            parties=[f"v{i}_a", f"v{i}_b"],
            connections=[(f"v{i}_a", f"v{i}_b")],
            security_parameter=128, enforce_min_harmonic=False,
        )
        fp = cred.spectrum.fingerprint_hash()
        credentials.append(cred)
        validators.append((fp, i))

    producer = BlockProducer(
        topology=topology,
        validators=validators,
        initial_supply=1_000_000.0,
    )

    # Override spectral gap computation — test credentials have tiny sheaf gaps
    # because security_parameter=128 creates 256-dim Laplacian with near-zero eigenvalues.
    # We test the PIPELINE, not the gap computation (that's tested in invariants/).
    producer._compute_spectral_gap = lambda cred: 1.5  # Valid: in [0.707, 2.828]

    # Register accounts
    for fp, _ in validators:
        producer.register_account(fp, 100_000.0)

    # --- Epoch 0: empty block ---
    selected = producer.get_selected_validator()
    assert selected is not None, "Must select a validator"
    idx = next(i for i, (fp, _) in enumerate(validators) if fp == selected)

    result = producer.produce_block(credentials[idx])
    assert result.success, f"Block 0 failed: {result.reason}"
    assert result.block is not None
    assert result.block.header.height == 0
    assert producer.chain_height() == 1

    # --- Epoch 1: block with transaction in mempool ---
    # Create a homotopy transaction
    sender_cred = credentials[0]
    recipient_fp = credentials[1].spectrum.fingerprint_hash()
    tx = create_homotopy_transaction(
        sender_credential=sender_cred,
        recipient_fingerprint=recipient_fp,
        amount=500,
        fee=1,
    )
    added = producer.submit_transaction(tx)
    assert added, "Transaction should enter mempool"
    assert producer.mempool.size() == 1

    selected2 = producer.get_selected_validator()
    idx2 = next(i for i, (fp, _) in enumerate(validators) if fp == selected2)
    result2 = producer.produce_block(credentials[idx2])
    assert result2.success, f"Block 1 failed: {result2.reason}"
    assert result2.block.header.height == 1
    assert len(result2.block.transactions) == 1
    assert producer.mempool.size() == 0  # Drained
    assert producer.chain_height() == 2


def test_validator_selection_probabilities():
    """Validators all get non-zero probability via Fiedler centrality."""
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
        vs.register_validator(fp, i)
        fps.append(fp)

    probs = vs.get_selection_probabilities()
    for fp in fps:
        assert probs.get(fp, 0) > 0, "Each validator must have positive probability"

    total = sum(probs.values())
    assert abs(total - 1.0) < 1e-6, f"Probabilities must sum to 1, got {total}"


# =============================================================================
# 2. SHEAF STATE LIFECYCLE
# =============================================================================

def test_sheaf_state_lifecycle():
    """
    SheafState: accounts → connect → topology → spectral gap → Oracle request.
    
    Covers:
    - add_account with HashChain tracing
    - add_connection with spectral cache invalidation
    - compute_topology (Čech nerve)
    - get_spectral_gap (cached)
    - to_oracle_request (computation boundary: no Laplacian sent)
    """
    from src.chain.sheaf_state import SheafState

    state = SheafState()

    # Add two accounts
    fp_alice = hashlib.sha256(b"alice").digest()
    fp_bob = hashlib.sha256(b"bob").digest()
    hclass = hashlib.sha256(b"test_class").digest()

    h1 = state.add_account(fp_alice, hclass, 1000.0)
    h2 = state.add_account(fp_bob, hclass, 500.0)
    assert h1 and h2, "Account creation must return chain hash"
    assert len(state.accounts) == 2

    # Connect them
    h3 = state.add_connection(fp_alice, fp_bob)
    assert h3 is not None, "Connection must succeed"

    # Topology
    nerve = state.compute_topology()
    assert len(nerve[0]) == 2, "2 vertices"
    assert len(nerve[1]) == 1, "1 edge"

    # Spectral gap (2-vertex path graph: gap = 2.0)
    gap = state.get_spectral_gap()
    assert gap > 0, f"Spectral gap must be positive, got {gap}"

    # Second call hits cache
    gap2 = state.get_spectral_gap()
    assert gap == gap2, "Cached gap must match"

    # Betti numbers
    betti = state.compute_betti_numbers()
    assert betti[0] == 1, "Connected → β₀ = 1"

    # HashChain integrity
    assert state.hash_chain.verify_chain(), "Chain must verify"
    assert state.hash_chain.height() == 3  # 2 accounts + 1 connection

    # Key rotation (same class)
    h4 = state.rotate_keys(fp_alice, hclass)
    assert h4 is not None
    assert state.accounts[fp_alice].rotation_count == 1


def test_sheaf_state_oracle_request_no_laplacian():
    """
    Computation boundary: to_oracle_request must NOT send the Laplacian.
    
    It must use FullStalkRequest.from_geometry() to pre-compute
    Hodge projection + commitment locally.
    """
    from src.chain.sheaf_state import SheafState

    state = SheafState()
    fp = hashlib.sha256(b"alice").digest()
    fp2 = hashlib.sha256(b"bob").digest()
    hclass = hashlib.sha256(b"class").digest()

    state.add_account(fp, hclass, 100.0)
    state.add_account(fp2, hclass, 50.0)
    state.add_connection(fp, fp2)

    credential = np.random.randn(2)  # 2 vertices
    request = state.to_oracle_request(fp, credential)

    assert request["method"] == "submit_stalk"
    params = request["params"]
    assert "commitment" in params, "Must include pre-computed commitment"
    assert "spectral_gap" in params, "Must include pre-computed spectral gap"
    assert "laplacian" not in params, "Must NOT send raw Laplacian"
    assert params["spectral_gap"] > 0


def test_sheaf_state_hash_commitments():
    """Hash commitments: η: F_full → F_hash."""
    from src.chain.sheaf_state import SheafState

    state = SheafState()
    fp = hashlib.sha256(b"alice").digest()
    hclass = hashlib.sha256(b"class").digest()
    state.add_account(fp, hclass, 100.0)

    commitments = state.get_hash_commitments()
    assert fp in commitments
    c = commitments[fp]
    assert c.fingerprint == fp
    assert len(c.topology_hash) == 32

    # Verify commitment round-trip
    assert state.verify_commitment(fp, c)


# =============================================================================
# 3. ANONYMITY PROOF ROUND-TRIP
# =============================================================================

def test_hodge_anonymity_proof():
    """
    Hodge-hardness ZK proof: anonymity set = ∞.
    
    Covers:
    - Build Laplacian with valid spectral gap
    - prove_class_membership (Fiat-Shamir over cochain complex)
    - verify_class_membership (coboundary + norm checks)
    """
    from src.proofs.anonymity import (
        prove_class_membership,
        verify_class_membership,
        compute_spectral_fingerprint,
    )
    from src.geometry.homotopy_path import POV_LOWER, POV_UPPER

    # Complete graph K4: every vertex connected to every other.
    # K4 Laplacian eigenvalues: [0, 4, 4, 4] → gap = 4.0 too high.
    # Use cycle graph C4: eigenvalues [0, 2, 2, 4] → gap = 2.0 ∈ [0.707, 2.828] ✓
    n = 4
    L = np.zeros((n, n))
    edges = [(0,1), (1,2), (2,3), (3,0)]  # Cycle
    for i, j in edges:
        L[i, i] += 1
        L[j, j] += 1
        L[i, j] -= 1
        L[j, i] -= 1

    eigs = np.sort(np.linalg.eigvalsh(L))
    gap = eigs[eigs > 1e-10][0]
    assert POV_LOWER <= gap <= POV_UPPER, f"Gap {gap:.4f} outside √2 bounds [{POV_LOWER:.4f}, {POV_UPPER:.4f}]"

    fingerprint = compute_spectral_fingerprint(eigs)

    # Prove
    proof, success, reason = prove_class_membership(L, fingerprint, eigs)
    assert success, f"Proof generation failed: {reason}"
    assert proof is not None
    assert len(proof.key_image) == 32

    # Verify
    valid, vreason = verify_class_membership(proof, fingerprint, eigs)
    assert valid, f"Proof verification failed: {vreason}"


def test_hodge_anonymity_wrong_fingerprint_rejects():
    """Proof with wrong fingerprint must be rejected."""
    from src.proofs.anonymity import (
        prove_class_membership,
        compute_spectral_fingerprint,
    )

    n = 5
    L = np.zeros((n, n))
    for i in range(n - 1):
        L[i, i] += 1
        L[i + 1, i + 1] += 1
        L[i, i + 1] = -1
        L[i + 1, i] = -1

    eigs = np.sort(np.linalg.eigvalsh(L))
    wrong_fp = hashlib.sha256(b"wrong").digest()

    proof, success, reason = prove_class_membership(L, wrong_fp, eigs)
    assert not success, "Wrong fingerprint must fail"


def test_homotopy_equivalence_proof():
    """
    ZK proof of homotopy equivalence (Fiat-Shamir).
    
    Proves: prover's fibration is homotopy-equivalent to public reference.
    """
    from src.proofs.homotopy import (
        prove_homotopy_equivalence,
        verify_homotopy_proof,
        HomotopyStatement,
    )

    cred = generate_credential(
        parties=["a", "b"],
        connections=[("a", "b")],
        security_parameter=128, enforce_min_harmonic=False,
    )

    statement = HomotopyStatement.from_credential(cred)
    proof = prove_homotopy_equivalence(cred, statement)

    valid, reason = verify_homotopy_proof(proof, statement)
    assert valid, f"Homotopy proof failed: {reason}"


# =============================================================================
# 4. KEY IMAGE DOUBLE-SPEND PREVENTION
# =============================================================================

def test_key_image_double_spend():
    """
    Homotopy key image: spend once OK, spend twice rejected.
    
    Covers:
    - compute_key_image from eigenvectors
    - KeyImageStore mark_spent / is_spent
    - Double-spend detection
    """
    from src.chain.key_image import compute_key_image, KeyImageStore

    # Create two different key images (different credentials)
    eigvecs_a = np.random.randn(8, 8)
    eigvecs_a, _ = np.linalg.qr(eigvecs_a)
    ki_a = compute_key_image(eigvecs_a)

    eigvecs_b = np.random.randn(8, 8)
    eigvecs_b, _ = np.linalg.qr(eigvecs_b)
    ki_b = compute_key_image(eigvecs_b)

    assert ki_a != ki_b, "Different eigenvectors → different key images"

    # Deterministic
    ki_a2 = compute_key_image(eigvecs_a)
    assert ki_a == ki_a2, "Same eigenvectors → same key image"

    # Store: first spend succeeds
    store = KeyImageStore()
    assert store.mark_spent(ki_a), "First spend must succeed"
    assert store.is_spent(ki_a), "Must be marked spent"

    # Double-spend rejected
    assert not store.mark_spent(ki_a), "Double spend must be rejected"

    # Different key image still works
    assert store.mark_spent(ki_b), "Different key image must succeed"
    assert store.size() == 2


def test_key_image_store_serialization():
    """KeyImageStore serialize → deserialize round-trip."""
    from src.chain.key_image import compute_key_image, KeyImageStore

    store = KeyImageStore()
    images = []
    for i in range(5):
        eigvecs = np.random.randn(4, 4)
        eigvecs, _ = np.linalg.qr(eigvecs)
        ki = compute_key_image(eigvecs)
        store.mark_spent(ki)
        images.append(ki)

    assert store.size() == 5

    # Serialize
    data = store.serialize()
    assert len(data) > 0

    # Deserialize
    store2 = KeyImageStore.deserialize(data)
    assert store2.size() == 5
    for ki in images:
        assert store2.is_spent(ki), f"Deserialized store must contain {ki.hex()[:8]}"


def test_key_image_batch_double_spend():
    """Batch add detects double-spends."""
    from src.chain.key_image import compute_key_image, KeyImageStore

    store = KeyImageStore()

    # Pre-spend one
    eigvecs = np.random.randn(4, 4)
    eigvecs, _ = np.linalg.qr(eigvecs)
    ki_pre = compute_key_image(eigvecs)
    store.mark_spent(ki_pre)

    # Batch with duplicate + pre-spent
    batch = [ki_pre]  # Already spent
    for i in range(3):
        ev = np.random.randn(4, 4)
        ev, _ = np.linalg.qr(ev)
        batch.append(compute_key_image(ev))

    double_spends = store.add_batch(batch)
    assert len(double_spends) == 1, "Must detect exactly 1 double-spend"
    assert double_spends[0] == ki_pre


def test_transaction_key_image_verification():
    """
    Full transaction verification rejects double-spent key images.
    """
    from src.chain.homotopy_transaction import (
        create_homotopy_transaction,
        verify_homotopy_transaction,
    )
    from src.chain.key_image import KeyImageStore

    cred = generate_credential(
        parties=["sender_a", "sender_b"],
        connections=[("sender_a", "sender_b")],
        security_parameter=128, enforce_min_harmonic=False,
    )
    recipient_fp = hashlib.sha256(b"recipient").digest()

    tx = create_homotopy_transaction(
        sender_credential=cred,
        recipient_fingerprint=recipient_fp,
        amount=100,
        fee=1,
    )

    store = KeyImageStore()

    # First verification: OK
    valid, reason = verify_homotopy_transaction(tx, store)
    assert valid, f"First tx must be valid: {reason}"

    # Mark key images as spent
    for inp in tx.inputs:
        store.mark_spent(inp.key_image)

    # Second verification: double-spend
    valid2, reason2 = verify_homotopy_transaction(tx, store)
    assert not valid2, "Double-spend must be rejected"
    assert "Double spend" in reason2


# =============================================================================
# 5. CHAIN PERSISTENCE
# =============================================================================

def test_chain_persistence_blocks():
    """
    BlockStore: store blocks → reload index → verify hashes match.
    """
    from src.chain.chain_store import ChainStore
    from src.chain.block import create_block

    with tempfile.TemporaryDirectory() as tmpdir:
        store = ChainStore(tmpdir)

        # Mock credential for block creation
        class MockCred:
            class MockSpectrum:
                def fingerprint_hash(self):
                    return hashlib.sha256(b"producer").digest()
            spectrum = MockSpectrum()

        # Create 3 blocks
        prev_hash = b"\x00" * 32
        for h in range(3):
            block = create_block(
                transactions=[],
                prev_hash=prev_hash,
                height=h,
                producer_credential=MockCred(),
                spectral_gap=1.5,
            )
            store.store_block(block)
            prev_hash = block.block_hash()

        # Check tip
        tip_height, tip_hash = store.get_chain_tip()
        assert tip_height == 2
        assert tip_hash == prev_hash

        # Check index lookups
        for h in range(3):
            stored_hash = store.block_store.get_block_hash(h)
            assert stored_hash is not None, f"Block {h} must be in index"
            assert len(stored_hash) == 32


def test_chain_persistence_sheaf_state():
    """
    ChainStore: save SheafState → reload → accounts + hash chain intact.
    """
    from src.chain.chain_store import ChainStore
    from src.chain.sheaf_state import SheafState

    with tempfile.TemporaryDirectory() as tmpdir:
        store = ChainStore(tmpdir)

        # Build state
        state = SheafState()
        fp_a = hashlib.sha256(b"alice_persist").digest()
        fp_b = hashlib.sha256(b"bob_persist").digest()
        hclass = hashlib.sha256(b"class").digest()

        state.add_account(fp_a, hclass, 1000.0)
        state.add_account(fp_b, hclass, 500.0)
        state.add_connection(fp_a, fp_b)
        state.tip_height = 5
        state.tip_hash = hashlib.sha256(b"tip").digest()

        # Save
        store.save_state(state)

        # Reload
        loaded = store.load_state()
        assert loaded is not None, "Must load state"
        assert len(loaded.accounts) == 2
        assert loaded.accounts[fp_a].balance == 1000.0
        assert loaded.accounts[fp_b].balance == 500.0
        assert loaded.tip_height == 5

        # Connections survived
        assert fp_b in loaded.accounts[fp_a].connected_to
        assert fp_a in loaded.accounts[fp_b].connected_to

        # Hash chain survived
        assert loaded.hash_chain.height() == 3


def test_chain_persistence_keyimages():
    """
    ChainStore: save + reload spent key images.
    """
    from src.chain.chain_store import ChainStore

    with tempfile.TemporaryDirectory() as tmpdir:
        store = ChainStore(tmpdir)

        # Create key images
        keyimages = set()
        for i in range(10):
            ki = hashlib.sha256(f"keyimage_{i}".encode()).digest()
            keyimages.add(ki)

        store.save_spent_keyimages(keyimages)
        loaded = store.load_spent_keyimages()

        assert len(loaded) == 10
        assert loaded == keyimages


def test_chain_persistence_full_cycle():
    """
    Full cycle: produce block → store → save state → reload → verify.
    """
    from src.chain.block_producer import BlockProducer
    from src.chain.chain_store import ChainStore
    from src.chain.sheaf_state import SheafState

    topology = {
        0: [(0,), (1,)],
        1: [(0, 1)],
        2: [],
    }

    cred = generate_credential(
        parties=["prod_a", "prod_b"],
        connections=[("prod_a", "prod_b")],
        security_parameter=128, enforce_min_harmonic=False,
    )
    fp = cred.spectrum.fingerprint_hash()

    producer = BlockProducer(
        topology=topology,
        validators=[(fp, 0)],
        initial_supply=100_000.0,
    )
    producer._compute_spectral_gap = lambda cred: 1.5  # Valid gap for test
    producer.register_account(fp, 100_000.0)

    # Produce a block
    result = producer.produce_block(cred)
    assert result.success, f"Block production failed: {result.reason}"

    with tempfile.TemporaryDirectory() as tmpdir:
        store = ChainStore(tmpdir)

        # Store block
        store.store_block(result.block)

        # Build and save SheafState
        state = SheafState()
        state.add_account(fp, hashlib.sha256(b"class").digest(), 100_000.0)
        state.tip_height = 1
        state.tip_hash = result.block.block_hash()
        store.save_state(state)

        # Reload and verify
        tip_h, tip_hash = store.get_chain_tip()
        assert tip_h == 0  # Block at height 0
        assert tip_hash == result.block.block_hash()

        loaded_state = store.load_state()
        assert loaded_state.tip_height == 1
        assert len(loaded_state.accounts) == 1


# =============================================================================
# RUNNER
# =============================================================================

if __name__ == "__main__":
    import traceback

    tests = [
        # 1. Block Production
        test_block_production_pipeline,
        test_validator_selection_probabilities,
        # 2. SheafState Lifecycle
        test_sheaf_state_lifecycle,
        test_sheaf_state_oracle_request_no_laplacian,
        test_sheaf_state_hash_commitments,
        # 3. Anonymity Proofs
        test_hodge_anonymity_proof,
        test_hodge_anonymity_wrong_fingerprint_rejects,
        test_homotopy_equivalence_proof,
        # 4. Key Image Double-Spend
        test_key_image_double_spend,
        test_key_image_store_serialization,
        test_key_image_batch_double_spend,
        test_transaction_key_image_verification,
        # 5. Chain Persistence
        test_chain_persistence_blocks,
        test_chain_persistence_sheaf_state,
        test_chain_persistence_keyimages,
        test_chain_persistence_full_cycle,
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
