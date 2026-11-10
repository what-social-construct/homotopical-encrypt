import hashlib

import numpy as np

from src.proofs.consensus import (
    ProofOfValue,
    Transaction,
    InvariantValidator,
    _TX_SIG_DOMAIN,
)


def _mk_fp(label: str) -> bytes:
    return hashlib.sha256(label.encode()).digest()


def test_validate_transaction_signature_policy():
    pov = ProofOfValue()
    sender = _mk_fp("sender")
    recipient = _mk_fp("recipient")
    pov.accounts[sender] = 100.0
    pov.accounts[recipient] = 0.0

    # Empty signature remains allowed for backwards compatibility.
    tx_empty = Transaction(sender=sender, recipient=recipient, amount=10.0, timestamp=1)
    assert pov._validate_transaction(tx_empty)

    # Valid deterministic signature should pass.
    tx_valid = Transaction(sender=sender, recipient=recipient, amount=10.0, timestamp=2)
    tx_valid.signature = hashlib.sha256(_TX_SIG_DOMAIN + tx_valid.hash()).digest()
    assert pov._validate_transaction(tx_valid)

    # Invalid provided signature should fail.
    tx_bad = Transaction(sender=sender, recipient=recipient, amount=10.0, timestamp=3)
    tx_bad.signature = b"not-a-valid-signature"
    assert not pov._validate_transaction(tx_bad)


def test_transaction_to_cochain_uses_account_vertex_mapping():
    pov = ProofOfValue(network_topology={0: [], 1: [], 2: []})
    sender = _mk_fp("alice")
    recipient = _mk_fp("bob")

    pov.register_account(sender, initial_balance=50.0)
    pov.register_account(recipient, initial_balance=0.0)

    tx = Transaction(sender=sender, recipient=recipient, amount=7.5)
    cochain = pov._transaction_to_cochain(tx, dim=1)

    s_idx = pov.account_vertices[sender]
    r_idx = pov.account_vertices[recipient]
    assert np.isclose(cochain[s_idx], -7.5)
    assert np.isclose(cochain[r_idx], 7.5)


def test_invariant_validator_uses_canonical_gap_bounds():
    inv = InvariantValidator()
    accounts = {_mk_fp("a"): 10.0, _mk_fp("b"): 0.0}
    txs = [Transaction(sender=list(accounts.keys())[0], recipient=list(accounts.keys())[1], amount=1.0)]

    ok, violations = inv.validate_pre_block(
        transactions=txs,
        accounts=accounts,
        topology={0: [(0,), (1,)], 1: [(0, 1)], 2: []},
        spectral_gap=10.0,  # definitely out of bounds
    )

    assert not ok
    assert any("SPECTRAL_BOUND" in v for v in violations)
