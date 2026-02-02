"""
Homotopical Privacy Chain

Core blockchain implementation with:
- Homotopy transactions (spectral proofs, infinite anonymity set)
- Blocks (PoV consensus via spectral gap)
- Key images (homotopy-path-based double-spend prevention)
- Chain state (harmonic-based, NOT traditional UTXO)

State model:
- NOT UTXO: Traditional Bitcoin-style unspent outputs
- YES: Harmonic component tracking (message lives in ker(Δ))
- Balance = projection onto harmonic subspace

Transaction types:
- HomotopyTransaction: Native homotopy-based (primary)
- RingTransaction: Ring-signature style (for benchmarking only)
"""

# Homotopy-native transactions (primary)
from .homotopy_transaction import (
    HomotopyTransaction,
    HomotopyInput,
    HomotopyOutput,
    create_homotopy_transaction,
    verify_homotopy_transaction,
    submit_to_sheaf_state,
)

# Legacy ring-style transactions MOVED to tests/benchmarks/ring_transaction.py
# Import only if needed for benchmarking:
#   from tests.benchmarks.ring_transaction import Transaction as RingTransaction
from .block import (
    Block,
    BlockHeader,
    create_block,
    verify_block,
)
# Legacy UTXO state MOVED to tests/benchmarks/utxo_state.py
# Use SheafState for production (harmonic-based, NOT UTXO)
from .account import (
    AccountStatus,
    SovereignAccount,
    Connection,
    AccountState,
    DualState,
)
from .sheaf_state import (
    SheafState,
    HashChain,
    SpectralCache,
)
from .key_image import (
    compute_key_image,
    KeyImageStore,
)
# Storage (both public chain and private wallet)
from .chain_store import (
    ChainStore,
    BlockStore,
)
from .wallet_store import (
    WalletStore,
    EncryptedCredential,
)
# Routing (transaction privacy via sheaf onion)
from .routing import (
    TransactionRouter,
    RelayNode,
    RelayNetwork,
)

__all__ = [
    # Homotopy Transactions (primary)
    "HomotopyTransaction",
    "HomotopyInput",
    "HomotopyOutput",
    "create_homotopy_transaction",
    "verify_homotopy_transaction",
    "submit_to_sheaf_state",
    # Blocks
    "Block",
    "BlockHeader",
    "create_block",
    "verify_block",
    # State (harmonic-based via SheafState, NOT UTXO)
    # Legacy ChainState/UTXO: tests/benchmarks/utxo_state.py
    "SheafState",
    "HashChain",
    # Key images
    "compute_key_image",
    "KeyImageStore",
    # Accounts
    "SovereignAccount",
    "AccountState",
    # Storage
    "ChainStore",
    "BlockStore",
    "WalletStore",
    "EncryptedCredential",
    # Routing
    "TransactionRouter",
    "RelayNode",
    "RelayNetwork",
]
