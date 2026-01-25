"""
Homotopical Privacy Chain

Core blockchain implementation with:
- Transactions (ring signatures, stealth addresses, confidential amounts)
- Blocks (PoV consensus via spectral gap)
- Key images (double-spend prevention)
- Chain state (UTXO via harmonic components)
"""

from .transaction import (
    Transaction,
    TransactionInput,
    TransactionOutput,
    create_transaction,
    verify_transaction,
)
from .block import (
    Block,
    BlockHeader,
    create_block,
    verify_block,
)
from .state import (
    ChainState,
    UTXO,
)
from .key_image import (
    compute_key_image,
    KeyImageStore,
)

__all__ = [
    # Transactions
    "Transaction",
    "TransactionInput",
    "TransactionOutput",
    "create_transaction",
    "verify_transaction",
    # Blocks
    "Block",
    "BlockHeader",
    "create_block",
    "verify_block",
    # State
    "ChainState",
    "UTXO",
    # Key images
    "compute_key_image",
    "KeyImageStore",
]
