"""
Benchmarks - Legacy Components for Comparison

These modules are NOT part of the main homotopical_encrypt system.
They exist ONLY for benchmarking against traditional approaches:

- ring_transaction.py: Ring signature transactions (like Monero)
- utxo_state.py: Bitcoin-style UTXO chain state

For production, use:
- src/chain/homotopy_transaction.py (HomotopyTransaction)
- src/chain/sheaf_state.py (SheafState - harmonic-based)

Example benchmark usage:
    from tests.benchmarks.ring_transaction import Transaction as RingTransaction
    from tests.benchmarks.utxo_state import ChainState as UTXOChainState
"""

# These are intentionally NOT imported by default
# Import explicitly when needed for benchmarking
