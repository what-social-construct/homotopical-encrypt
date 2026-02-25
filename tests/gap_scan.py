"""Deep gap scan of all implemented subsystems."""
import warnings
import hashlib
import numpy as np
import sys

GAPS = []

# =====================================================
# 1. CREDENTIAL KEYGEN
# =====================================================
from src.crypto.credential import generate_credential, rotate_credential

try:
    generate_credential(['alice'], [])
    GAPS.append('GAP: Single party with no connections should fail')
except ValueError:
    pass

try:
    c = generate_credential(['a','b'], [('a','b')])
    assert c.spectrum.betti_numbers[0] == 1
    assert c.spectrum.spectral_gap > 0
except Exception as e:
    GAPS.append(f'GAP: Basic keygen: {e}')

try:
    c1 = generate_credential(['a','b'], [('a','b')])
    c2 = rotate_credential(c1)
    assert c1.spectrum.betti_numbers == c2.spectrum.betti_numbers, 'Rotation changed Betti'
    assert c1.project_to_public().on_diagonal(c2.project_to_public()), 'Rotation broke class'
except Exception as e:
    GAPS.append(f'GAP: Rotation: {e}')

print(f'1. Credential keygen: {len(GAPS)} gaps')

# =====================================================
# 2. ENCRYPT/DECRYPT
# =====================================================
from src.crypto import encrypt, decrypt

try:
    c = generate_credential(['a','b'], [('a','b')])
    msg = b'test message 123'
    ct = encrypt(msg, c, sigma_exact=2.0, sigma_harmonic=0.1)
    pt = decrypt(ct, c)
    if pt != msg:
        GAPS.append(f'GAP: Roundtrip failed: {pt!r} != {msg!r}')
except Exception as e:
    GAPS.append(f'GAP: Encrypt/decrypt: {e}')

print(f'2. Encrypt/decrypt: {len(GAPS)} gaps total')

# =====================================================
# 3. TRANSACTION PIPELINE
# =====================================================
from src.chain.homotopy_transaction import (
    create_homotopy_transaction, verify_homotopy_transaction
)

try:
    c = generate_credential(['a','b'], [('a','b')])
    recipient = hashlib.sha256(b'bob').digest()
    tx = create_homotopy_transaction(c, recipient, amount=1000, fee=10)
    
    assert len(tx.inputs) == 1
    assert len(tx.outputs) == 1
    assert tx.fee_amount == 10
    assert tx.inputs[0].betti_numbers[0] == 1
    assert tx.inputs[0].key_image
    assert tx.inputs[0].amount_commitment
    assert tx.outputs[0].transfer_amount == 1000
    
    valid, reason = verify_homotopy_transaction(tx)
    if not valid:
        GAPS.append(f'GAP: Fresh tx failed verification: {reason}')
    
    if tx.inputs[0].class_membership_proof is None:
        GAPS.append('GAP: ZK class_membership_proof is None')
    
    if tx.inputs[0].mac_tag is None:
        GAPS.append('GAP: CohomologicalMAC tag is None')
    
    if tx.outputs[0].range_proof is None:
        GAPS.append('GAP: Harmonic range proof is None')

    # Double-spend detection: same tx should fail key image check
    from src.chain.key_image import KeyImageStore
    store = KeyImageStore()
    store.mark_spent(tx.inputs[0].key_image)
    valid2, reason2 = verify_homotopy_transaction(tx, key_image_store=store)
    if valid2:
        GAPS.append('GAP: Double-spend not caught by key image store')

except Exception as e:
    GAPS.append(f'GAP: Transaction pipeline: {e}')

print(f'3. Transaction pipeline: {len(GAPS)} gaps total')

# =====================================================
# 4. BLOCK PRODUCTION + STATE
# =====================================================
from src.chain.block_producer import BlockProducer
from src.chain.sheaf_state import SheafState

try:
    topology = {0: [(0,),(1,),(2,)], 1: [(0,1),(1,2),(0,2)], 2: []}
    creds, vals = [], []
    for parties, conns in [
        (['a','b'], [('a','b')]),
        (['c','d','e'], [('c','d'),('d','e')]),
        (['f','g','h','i'], [('f','g'),('g','h'),('h','i')]),
    ]:
        c = generate_credential(parties, conns)
        fp = c.project_to_public().identity_hash()
        creds.append(c)
        vals.append((fp, len(vals)))
    
    state = SheafState()
    producer = BlockProducer(topology=topology, validators=vals,
                             initial_supply=1_000_000, sheaf_state=state)
    
    for i, (fp, vid) in enumerate(vals):
        producer.register_account(fp, balance=100_000 + i*10_000)
        producer.register_vrf_key(creds[i])
        rng = np.random.RandomState(int.from_bytes(fp[:4], 'big') + i)
        stalk = np.array([1.0, 0.5]) + rng.randn(2)*0.15
        stalk = stalk / (np.linalg.norm(stalk) + 1e-12)
        producer.validator_set.validators[fp].stalk_data = stalk.reshape(1,-1)
    
    sel = producer.get_selected_validator()
    if sel is None:
        GAPS.append('GAP: No validator selected')
    else:
        idx = next(i for i,(fp,_) in enumerate(vals) if fp == sel)
        result = producer.produce_block(creds[idx])
        if not result.success:
            GAPS.append(f'GAP: Block production failed: {result.reason}')
    
    # Create real transfer tx and submit
    tx = create_homotopy_transaction(creds[0], vals[1][0], amount=500, fee=5)
    state.mempool[tx.tx_hash()] = tx
    
    b0_before = producer.get_balance(vals[0][0])
    b1_before = producer.get_balance(vals[1][0])
    
    sel2 = producer.get_selected_validator()
    if sel2:
        idx2 = next(i for i,(fp,_) in enumerate(vals) if fp == sel2)
        result2 = producer.produce_block(creds[idx2])
        
        b0_after = producer.get_balance(vals[0][0])
        b1_after = producer.get_balance(vals[1][0])
        
        if result2.success and result2.block and len(result2.block.transactions) > 0:
            if b0_after >= b0_before and b1_after <= b1_before:
                GAPS.append(f'GAP: Balances unchanged after tx block: '
                           f'V0: {b0_before}->{b0_after}, V1: {b1_before}->{b1_after}')

except Exception as e:
    GAPS.append(f'GAP: Block production: {e}')

print(f'4. Block production: {len(GAPS)} gaps total')

# =====================================================
# 5. COMMITMENTS
# =====================================================
from src.crypto.commitment import CochainCommitment
from src.primitives.cochain import CochainComplex

try:
    cc = CochainComplex.from_graph(2, [(0,1)], stalk_dim=1)
    c_a, _ = CochainCommitment.commit(np.array([100.0]), cc, q=12289)
    c_b, _ = CochainCommitment.commit(np.array([70.0]), cc, q=12289)
    # CochainCommitment stores committed_cochain, not .value
    a_bytes = c_a.to_bytes()
    b_bytes = c_b.to_bytes()
    if a_bytes == b_bytes:
        GAPS.append('GAP: Different amounts → same commitment (binding broken)')
except Exception as e:
    GAPS.append(f'GAP: Commitment: {e}')

print(f'5. Commitments: {len(GAPS)} gaps total')

# =====================================================
# 6. SERIALIZATION
# =====================================================
try:
    c = generate_credential(['a','b'], [('a','b')])
    blob = c.serialize()
    c2 = type(c).deserialize(blob)
    assert c.hilbert_dim == c2.hilbert_dim
    assert c.modulus == c2.modulus
    assert c.parties == c2.parties
    assert np.allclose(c.spectrum.eigenvalues, c2.spectrum.eigenvalues, atol=1e-10)
    assert c.spectrum.betti_numbers == c2.spectrum.betti_numbers
    assert c.project_to_public() == c2.project_to_public()
    
    # Can we encrypt with deserialized credential?
    ct = encrypt(b'after deserialize', c2, sigma_exact=2.0, sigma_harmonic=0.1)
    pt = decrypt(ct, c2)
    if pt != b'after deserialize':
        GAPS.append('GAP: Encrypt/decrypt fails after deserialization')
except Exception as e:
    GAPS.append(f'GAP: Serialization: {e}')

print(f'6. Serialization: {len(GAPS)} gaps total')

# =====================================================
# 7. SYMMETRY GROUP
# =====================================================
from src.consensus.symmetry_group import ValidatorGroup

try:
    group = ValidatorGroup()
    for c in creds:
        group.add_validator(c.project_to_public().identity_hash(), c.spectrum.spectral_gap)
    
    weights = group.compute_selection_weights()
    total = sum(weights.values())
    if abs(total - 1.0) > 0.01:
        GAPS.append(f'GAP: Selection weights sum to {total}, expected 1.0')
    
    ok, msg = group.verify_composition_associativity()
    if not ok:
        GAPS.append(f'GAP: Composition not associative: {msg}')
except Exception as e:
    GAPS.append(f'GAP: Symmetry group: {e}')

print(f'7. Symmetry group: {len(GAPS)} gaps total')

# =====================================================
# 8. INVARIANT VALIDATION
# =====================================================
try:
    from src.invariants.unified import validate_fibration
    from src.geometry.sheaf_laplacian import SheafLaplacian
    
    c = generate_credential(['a','b','c'], [('a','b'),('b','c'),('a','c')])
    laplacian = SheafLaplacian(c.fibration.sheaf)
    eigs, vecs = laplacian.eigendecomposition(0)
    L = vecs @ np.diag(eigs) @ vecs.T
    
    # Use SHEAF coboundary (with restriction maps), not graph ±1
    delta_0 = laplacian.get_coboundary_0()
    
    valid, fp, report = validate_fibration(c.topology, L, delta_0, stage="keygen")
    if not valid:
        GAPS.append(f'GAP: Unified validation failed at keygen: {report}')
except Exception as e:
    GAPS.append(f'GAP: Invariant validation: {e}')

print(f'8. Invariant validation: {len(GAPS)} gaps total')

# =====================================================
# 9. CONSENSUS PRIMITIVES (Topos, Coalition, Coregulator)
# =====================================================
try:
    from src.consensus.topos import ToposConsensus
    from src.consensus.coalitions import Semitopology
    from src.consensus.coregulator import CoregulatorDAO
    
    # Topos (takes stalk_dim, not topology)
    topos = ToposConsensus(stalk_dim=2)
    stalks = {}
    for fp, _ in vals:
        if fp in producer.validator_set.validators:
            v = producer.validator_set.validators[fp]
            if v.stalk_data is not None:
                stalks[fp] = v.stalk_data
    
    if len(stalks) >= 2:
        judgment = topos.evaluate(stalks=stalks, epoch=0)
        if judgment.evidence.beta_0 < 1:
            GAPS.append('GAP: Topos β₀ < 1 with connected stalks')
    
    # Coalitions
    semi = Semitopology()
    for fp, stalk in stalks.items():
        semi.register_validator(fp, stalk)
    semi.build_from_stalks()
    coalitions = semi.actionable_coalitions()
    if len(coalitions) == 0 and len(stalks) >= 2:
        GAPS.append('GAP: No actionable coalitions with ≥2 validators')
    
    # Coregulator (takes stalk_dim, not topology)
    coreg = CoregulatorDAO(stalk_dim=2)
    coreg.observe(stalks, epoch=0)
    pred = coreg.predict_next_consensus()
    if pred is None and len(stalks) >= 2:
        GAPS.append('GAP: Coregulator returned None prediction with data')

except Exception as e:
    GAPS.append(f'GAP: Consensus primitives: {e}')

print(f'9. Consensus primitives: {len(GAPS)} gaps total')

# =====================================================
# REPORT
# =====================================================
print()
print("=" * 60)
if GAPS:
    print(f'{len(GAPS)} GAPS FOUND:')
    for i, g in enumerate(GAPS):
        print(f'  {i+1}. {g}')
else:
    print('ZERO GAPS — IMPLEMENTATION IS CLEAN')
print("=" * 60)
sys.exit(len(GAPS))
