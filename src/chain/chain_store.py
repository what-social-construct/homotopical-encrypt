"""
Chain Store - Public Block/State Storage

This data is PUBLIC (on-chain) so no encryption needed.
Simple file-based storage:
- blocks/{height}.block - Serialized block bytes
- state/sheaf_state.json - Current state snapshot
- index/height_to_hash.json - Block index
"""

import os
import json
import hashlib
from pathlib import Path
from typing import Optional, Dict, List, Any
from dataclasses import dataclass, asdict

from .block import Block, BlockHeader
from .sheaf_state import SheafState


@dataclass
class BlockStore:
    """
    Stores blocks as serialized files.
    
    Structure:
        data_dir/
        ├── blocks/
        │   ├── 000000.block
        │   ├── 000001.block
        │   └── ...
        ├── index/
        │   ├── height_to_hash.json
        │   └── hash_to_height.json
        └── meta/
            └── chain_info.json
    """
    data_dir: Path
    
    def __post_init__(self):
        self.data_dir = Path(self.data_dir)
        self._ensure_dirs()
    
    def _ensure_dirs(self):
        """Create directory structure."""
        (self.data_dir / "blocks").mkdir(parents=True, exist_ok=True)
        (self.data_dir / "index").mkdir(parents=True, exist_ok=True)
        (self.data_dir / "meta").mkdir(parents=True, exist_ok=True)
    
    def _block_path(self, height: int) -> Path:
        """Path to block file."""
        return self.data_dir / "blocks" / f"{height:06d}.block"
    
    def store_block(self, block: Block) -> bool:
        """
        Store a block to disk.
        
        Returns True if stored successfully.
        """
        height = block.header.height
        path = self._block_path(height)
        
        # Serialize block
        block_bytes = block.serialize()
        
        # Write to file
        with open(path, 'wb') as f:
            f.write(block_bytes)
        
        # Update index
        self._update_index(height, block.block_hash())
        
        return True
    
    def load_block(self, height: int) -> Optional[Block]:
        """
        Load a block from disk by height.
        """
        path = self._block_path(height)
        
        if not path.exists():
            return None
        
        with open(path, 'rb') as f:
            block_bytes = f.read()
        
        # TODO: Deserialize block (need Block.deserialize())
        # For now, return None - deserialization TBD
        return None
    
    def get_block_hash(self, height: int) -> Optional[bytes]:
        """Get block hash by height from index."""
        index_path = self.data_dir / "index" / "height_to_hash.json"
        
        if not index_path.exists():
            return None
        
        with open(index_path, 'r') as f:
            index = json.load(f)
        
        hash_hex = index.get(str(height))
        return bytes.fromhex(hash_hex) if hash_hex else None
    
    def get_block_height(self, block_hash: bytes) -> Optional[int]:
        """Get block height by hash from index."""
        index_path = self.data_dir / "index" / "hash_to_height.json"
        
        if not index_path.exists():
            return None
        
        with open(index_path, 'r') as f:
            index = json.load(f)
        
        return index.get(block_hash.hex())
    
    def _update_index(self, height: int, block_hash: bytes):
        """Update both indices."""
        # Height → Hash
        h2h_path = self.data_dir / "index" / "height_to_hash.json"
        h2h = {}
        if h2h_path.exists():
            with open(h2h_path, 'r') as f:
                h2h = json.load(f)
        h2h[str(height)] = block_hash.hex()
        with open(h2h_path, 'w') as f:
            json.dump(h2h, f, indent=2)
        
        # Hash → Height
        hash2h_path = self.data_dir / "index" / "hash_to_height.json"
        hash2h = {}
        if hash2h_path.exists():
            with open(hash2h_path, 'r') as f:
                hash2h = json.load(f)
        hash2h[block_hash.hex()] = height
        with open(hash2h_path, 'w') as f:
            json.dump(hash2h, f, indent=2)
    
    def get_chain_tip(self) -> tuple[int, bytes]:
        """Get highest block (height, hash)."""
        h2h_path = self.data_dir / "index" / "height_to_hash.json"
        
        if not h2h_path.exists():
            return (-1, b'\x00' * 32)
        
        with open(h2h_path, 'r') as f:
            index = json.load(f)
        
        if not index:
            return (-1, b'\x00' * 32)
        
        max_height = max(int(h) for h in index.keys())
        return (max_height, bytes.fromhex(index[str(max_height)]))
    
    def save_chain_info(self, info: Dict[str, Any]):
        """Save chain metadata."""
        path = self.data_dir / "meta" / "chain_info.json"
        with open(path, 'w') as f:
            json.dump(info, f, indent=2)
    
    def load_chain_info(self) -> Dict[str, Any]:
        """Load chain metadata."""
        path = self.data_dir / "meta" / "chain_info.json"
        if not path.exists():
            return {}
        with open(path, 'r') as f:
            return json.load(f)


@dataclass
class ChainStore:
    """
    Complete chain storage: blocks + state.
    
    Structure:
        data_dir/
        ├── blocks/  (BlockStore)
        ├── state/
        │   └── current.json
        └── keyimages/
            └── spent.json
    """
    data_dir: Path
    
    def __post_init__(self):
        self.data_dir = Path(self.data_dir)
        self.block_store = BlockStore(self.data_dir)
        (self.data_dir / "state").mkdir(parents=True, exist_ok=True)
        (self.data_dir / "keyimages").mkdir(parents=True, exist_ok=True)
    
    def store_block(self, block: Block) -> bool:
        """Store a block."""
        return self.block_store.store_block(block)
    
    def save_state(self, state: SheafState):
        """
        Save current sheaf state snapshot.
        
        Note: SheafState uses harmonic components, not UTXO.
        """
        state_path = self.data_dir / "state" / "current.json"
        
        # Serialize state (basic version)
        state_dict = {
            "tip_height": state.tip_height,
            "tip_hash": state.tip_hash.hex() if hasattr(state, 'tip_hash') else "",
            "harmonic_balances": {
                k.hex(): v for k, v in getattr(state, 'harmonic_balances', {}).items()
            },
            # Add more fields as needed
        }
        
        with open(state_path, 'w') as f:
            json.dump(state_dict, f, indent=2)
    
    def load_state(self) -> Optional[SheafState]:
        """Load state from disk."""
        state_path = self.data_dir / "state" / "current.json"
        
        if not state_path.exists():
            return None
        
        with open(state_path, 'r') as f:
            state_dict = json.load(f)
        
        # Reconstruct state (basic version)
        state = SheafState()
        state.tip_height = state_dict.get("tip_height", -1)
        # TODO: Full state reconstruction
        
        return state
    
    def save_spent_keyimages(self, keyimages: set):
        """Save spent key images."""
        path = self.data_dir / "keyimages" / "spent.json"
        
        ki_list = [ki.hex() for ki in keyimages]
        
        with open(path, 'w') as f:
            json.dump(ki_list, f)
    
    def load_spent_keyimages(self) -> set:
        """Load spent key images."""
        path = self.data_dir / "keyimages" / "spent.json"
        
        if not path.exists():
            return set()
        
        with open(path, 'r') as f:
            ki_list = json.load(f)
        
        return {bytes.fromhex(ki) for ki in ki_list}
    
    def get_chain_tip(self) -> tuple[int, bytes]:
        """Get chain tip."""
        return self.block_store.get_chain_tip()


# =============================================================================
# TEST
# =============================================================================

if __name__ == "__main__":
    import tempfile
    import secrets
    from .block import create_block
    
    print("=" * 60)
    print("CHAIN STORE TEST")
    print("=" * 60)
    
    # Create temp directory
    with tempfile.TemporaryDirectory() as tmpdir:
        store = ChainStore(tmpdir)
        
        # Create a mock block
        class MockCred:
            class MockSpectrum:
                def fingerprint_hash(self):
                    return secrets.token_bytes(32)
            spectrum = MockSpectrum()
        
        genesis = create_block(
            transactions=[],
            prev_hash=b'\x00' * 32,
            height=0,
            producer_credential=MockCred(),
            spectral_gap=1.5
        )
        
        print("\n1. Storing genesis block:")
        store.store_block(genesis)
        print(f"   Stored at height 0")
        
        print("\n2. Getting chain tip:")
        height, hash = store.get_chain_tip()
        print(f"   Height: {height}")
        print(f"   Hash: {hash.hex()[:16]}...")
        
        print("\n3. Block index lookup:")
        stored_hash = store.block_store.get_block_hash(0)
        print(f"   Height 0 → {stored_hash.hex()[:16]}...")
        
        print("\n" + "=" * 60)
        print("✅ CHAIN STORE WORKING")
        print("=" * 60)
