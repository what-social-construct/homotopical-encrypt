"""
BlockSection: Blocks as Sheaf Sections

A block IS a sheaf section, stored in the same sheaf infrastructure
as accounts and credentials.

THREE-LAYER DATA MODEL (matches credential.py, commitment.py, stalk.py,
sheaf_store.rs, stalk_bridge.rs, types.rs):

    LAYER 3 — PRIVATE (PRIVATE_STALK, dim=256 = fiber_bundle.fiber_dim)
      Block data: spectral_commitment + PoV proof + producer credential data
      Credential: vertex_keys (256-dim lattice vectors per vertex)
      FiberBundle: connection matrices (256×256 orthogonal)
      Rust FullStalk: credential Vec<f64> (256-dim)
      Storage: stalks_private column family (vertex data, C⁰)

    LAYER 2 — ZK / COCHAIN (CochainCommitment edge values in C¹)
      Block data: cochain_root = SHA256(Σ δ(tx_i) mod q) — homomorphic
      Commitment: CochainCommitment.edge_values = δ(m||r) mod q
      This is C¹ data (coboundary of C⁰ vertex data), variable-length.
      Storage: sheaf edge data (set_edge_data in sheaf_store.rs)
      The ZK_STALK (dim=32) is for the compressed HASH commitment
      per account; actual cochain edge values live in edge storage.

    LAYER 1 — PUBLIC (PUBLIC_STALK, dim=1)
      Block data: spectral gap scalar (consensus-critical PoV value)
      AccountState: balance scalar
      Rust HashStalk: spectral_gap_valid boolean + identity_hash
      Storage: stalks_public column family (vertex data, C⁰)

    SECTION STRUCTURE:

      Section σ_h at height h consists of:
        - Vertex stalks: PUBLIC(dim=1), PRIVATE(dim=256) at vertex h
        - Edge data: cochain commitment values in C¹ (Layer 2)
        - Edge restriction: prev_hash linkage to height h-1

      This matches sheaf_store.rs which has:
        - set_stalk() / get_stalk() for vertex data (C⁰)
        - set_edge_data() / get_edge_data() for edge data (C¹)
        - set_section() for batch vertex writes

    NATURAL TRANSFORMATIONS (stalk_bridge.rs):

      η₁: F_full → F_zk   (Oracle: Hodge project + quantize)
      η₂: F_zk → F_hash    (Node: hash + compress to commitment)

      Coherence: private[0] (spectral gap) = public[0] (spectral gap)
      The gap is preserved across all three layers.

    COCHAIN ROOT (types.rs Block.compute_cochain_root()):

      NOT a standard Merkle tree. Uses linearity of coboundary δ:
        Σ_i δ(tx_i) = δ(Σ_i tx_i)
      Binding: forging requires ker(δ) elements (SVP-hard)
      The cochain_root is the SHA256 compression of accumulated
      edge values — linking Layer 2 (lattice) into Layer 1 (hash chain).
"""

from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Optional, Any
import numpy as np
import hashlib
import struct

from ..primitives.stalk import (
    Stalk, StalkSpec, StalkBundle, StalkProjection,
    PRIVATE_STALK, PUBLIC_STALK, ZK_STALK,
    PRIVATE_TO_ZK, ZK_TO_PUBLIC,
)


@dataclass
class BlockSection:
    """
    A block as a sheaf section: σ_h ∈ Γ(X, F).

    Vertex stalks use CANONICAL specs (matching all other code):
      - public_stalk:  PUBLIC_STALK  (dim=1)   — spectral gap scalar
      - private_stalk: PRIVATE_STALK (dim=256)  — full geometric data

    Edge data uses cochain commitment structure (C¹):
      - cochain_edge_values: the actual δ(m||r) mod q values
      - cochain_root: SHA256 compression (32 bytes, stored in header)

    Chain edge (restriction map between consecutive heights):
      - prev_hash: block_hash(σ_{h-1}) = linkage to parent
    """
    height: int
    block_hash: bytes

    # C⁰ vertex stalks (canonical specs)
    public_stalk: Stalk       # PUBLIC_STALK  dim=1   (spectral gap)
    private_stalk: Stalk      # PRIVATE_STALK dim=256 (geometric data)

    # C¹ edge data (cochain commitment layer)
    cochain_root: bytes = b'\x00' * 32        # SHA256 of accumulated edge values
    cochain_edge_values: Optional[np.ndarray] = None  # Raw δ(m||r) mod q (variable-length)

    # Chain nerve edge (restriction map h → h+1)
    prev_hash: bytes = b'\x00' * 32

    # Block metadata (for restrict_public)
    _meta_timestamp: float = 0.0
    _meta_tx_count: int = 0
    _meta_key_image_count: int = 0

    @classmethod
    def from_block(cls, block) -> 'BlockSection':
        """
        Decompose a Block into a sheaf section.

        FUNCTOR F: Block → Γ(X, F)

        Packs block data into:
          - C⁰ public stalk (dim=1): spectral gap
          - C⁰ private stalk (dim=256): spectral/PoV/class/producer data
          - C¹ edge data: cochain commitment (variable-length, from commitment.py)
        """
        header = block.header

        # =====================================================================
        # C⁰ PUBLIC STALK (dim=1): spectral gap scalar
        # =====================================================================
        # Matches AccountState.to_public_stalk() → dim=1 balance scalar
        # For blocks, the scalar is spectral_gap (PoV consensus value)
        public_stalk = Stalk(
            spec=PUBLIC_STALK,
            data=np.array([float(header.spectral_gap)]),
            vertex_id=header.height,
        )

        # =====================================================================
        # C⁰ PRIVATE STALK (dim=256): full geometric block data
        # =====================================================================
        # PRIVATE_STALK.fields = {harmonic_secret: 128, hodge_noise: 64, metadata: 64}
        # Maps to: spectral+pov[128] + class_proofs[64] + producer[64]
        # fiber_dim=256 from fiber_bundle.py
        private_data = np.zeros(256)

        # harmonic_secret [0:128]: spectral gap + commitment + PoV proof
        private_data[0] = header.spectral_gap  # Must match public[0] for coherence
        if header.spectral_commitment:
            for i, b in enumerate(header.spectral_commitment[:63]):
                private_data[1 + i] = float(b)
        if block.pov_proof:
            for i, b in enumerate(block.pov_proof[:64]):
                private_data[64 + i] = float(b)

        # hodge_noise [128:192]: per-tx class proof commitments
        proof_offset = 128
        for tx in block.transactions[:8]:
            for inp in tx.inputs[:1]:
                if inp.class_membership_proof:
                    h = hashlib.sha256(inp.class_membership_proof).digest()[:8]
                    for j, b in enumerate(h):
                        if proof_offset + j < 192:
                            private_data[proof_offset + j] = float(b)
                    proof_offset += 8

        # metadata [192:256]: producer fingerprint (PRIVATE only)
        if block.producer_fingerprint_private:
            for i, b in enumerate(block.producer_fingerprint_private[:64]):
                private_data[192 + i] = float(b)

        private_stalk = Stalk(
            spec=PRIVATE_STALK,
            data=private_data,
            vertex_id=header.height,
        )

        # =====================================================================
        # C¹ EDGE DATA: cochain commitment (Layer 2)
        # =====================================================================
        # cochain_root is the SHA256 compression of δ(tx) edge values
        # The actual edge values come from CochainCommitment.edge_values
        # and are stored separately in edge storage (sheaf_store.set_edge_data)
        cochain_root = header.cochain_root if header.cochain_root else b'\x00' * 32

        # Metadata
        n_key_images = sum(len(tx.inputs) for tx in block.transactions)

        return cls(
            height=header.height,
            block_hash=block.block_hash(),
            public_stalk=public_stalk,
            private_stalk=private_stalk,
            cochain_root=cochain_root,
            cochain_edge_values=None,  # Populated when cochain data available
            prev_hash=header.prev_hash,
            _meta_timestamp=header.timestamp,
            _meta_tx_count=len(block.transactions),
            _meta_key_image_count=n_key_images,
        )

    # =========================================================================
    # COHERENCE CHECK
    # =========================================================================

    def verify_coherence(self) -> Tuple[bool, str]:
        """
        Coherence: private[0] == public[0] (spectral gap preserved across layers).

        This is the naturality condition: η₂(η₁(private)) = public.
        Since the default StalkProjections take leading components,
        coherence reduces to: the spectral gap in the private stalk
        must equal the spectral gap in the public stalk.
        """
        private_gap = self.private_stalk.data[0]
        public_gap = self.public_stalk.data[0]

        if abs(private_gap - public_gap) > 1e-6:
            return (False, f"Gap mismatch: private[0]={private_gap}, public[0]={public_gap}")

        # Cochain root should be non-trivial if block has transactions
        if self._meta_tx_count > 0:
            if self.cochain_root == b'\x00' * 32:
                return (False, "Cochain root is zero but block has transactions")

        return (True, "Coherent across all three layers")

    # =========================================================================
    # LAYER RESTRICTION (query interface)
    # =========================================================================

    def restrict_public(self) -> Dict[str, Any]:
        """Restrict section to public layer — light client view."""
        return {
            "height": self.height,
            "timestamp": self._meta_timestamp,
            "tx_count": self._meta_tx_count,
            "key_images": self._meta_key_image_count,
            "spectral_gap": float(self.public_stalk.data[0]),
            "block_hash": self.block_hash.hex(),
            "prev_hash": self.prev_hash.hex(),
        }

    def restrict_cochain(self) -> Dict[str, Any]:
        """Restrict section to cochain layer — validator view (C¹ edge data)."""
        return {
            "cochain_root": self.cochain_root.hex(),
            "has_edge_values": self.cochain_edge_values is not None,
            "n_edge_values": len(self.cochain_edge_values) if self.cochain_edge_values is not None else 0,
            "height": self.height,
        }

    def restrict_private(self) -> Dict[str, Any]:
        """Restrict section to private layer — block producer view."""
        return {
            "spectral_gap": float(self.private_stalk.data[0]),
            "harmonic_secret": self.private_stalk.get_field("harmonic_secret").tobytes(),
            "hodge_noise": self.private_stalk.get_field("hodge_noise").tobytes(),
            "metadata": self.private_stalk.get_field("metadata").tobytes(),
        }

    # =========================================================================
    # SERIALIZATION (for sheaf store)
    # =========================================================================

    def serialize(self) -> bytes:
        """Serialize full section for storage."""
        data = struct.pack('<I', self.height)
        data += self.block_hash[:32].ljust(32, b'\x00')
        data += self.prev_hash[:32].ljust(32, b'\x00')
        data += self.cochain_root[:32].ljust(32, b'\x00')
        data += struct.pack('<d', self._meta_timestamp)
        data += struct.pack('<I', self._meta_tx_count)
        data += struct.pack('<I', self._meta_key_image_count)
        # C⁰ stalks
        data += self.public_stalk.data.tobytes()   # 1 × 8 = 8 bytes
        data += self.private_stalk.data.tobytes()   # 256 × 8 = 2048 bytes
        return data

    @classmethod
    def deserialize(cls, data: bytes) -> 'BlockSection':
        """Deserialize full section."""
        offset = 0
        height = struct.unpack_from('<I', data, offset)[0]; offset += 4
        block_hash = data[offset:offset+32]; offset += 32
        prev_hash = data[offset:offset+32]; offset += 32
        cochain_root = data[offset:offset+32]; offset += 32
        timestamp = struct.unpack_from('<d', data, offset)[0]; offset += 8
        tx_count = struct.unpack_from('<I', data, offset)[0]; offset += 4
        ki_count = struct.unpack_from('<I', data, offset)[0]; offset += 4

        # C⁰ stalks
        pub_data = np.frombuffer(data[offset:offset+8], dtype=np.float64).copy()
        offset += 8
        priv_data = np.frombuffer(data[offset:offset+2048], dtype=np.float64).copy()
        offset += 2048

        return cls(
            height=height,
            block_hash=block_hash,
            public_stalk=Stalk(spec=PUBLIC_STALK, data=pub_data, vertex_id=height),
            private_stalk=Stalk(spec=PRIVATE_STALK, data=priv_data, vertex_id=height),
            cochain_root=cochain_root,
            prev_hash=prev_hash,
            _meta_timestamp=timestamp,
            _meta_tx_count=tx_count,
            _meta_key_image_count=ki_count,
        )


# =============================================================================
# SECTION BUNDLE (collection of block sections = the chain)
# =============================================================================

class ChainSectionBundle:
    """
    The blockchain as a sheaf section bundle.

    Maps height → BlockSection. The chain is a functor:
      F: ℕ → Sh(X)
      h ↦ σ_h

    Edge restriction maps encode prev_hash linkage:
      R_{h→h+1}: block_hash(σ_h) = σ_{h+1}.prev_hash
    """

    def __init__(self):
        self.sections: Dict[int, BlockSection] = {}

    def add_section(self, section: BlockSection):
        self.sections[section.height] = section

    def add_block(self, block) -> BlockSection:
        section = BlockSection.from_block(block)
        self.add_section(section)
        return section

    def get_section(self, height: int) -> Optional[BlockSection]:
        return self.sections.get(height)

    def verify_chain_coherence(self) -> Tuple[bool, List[str]]:
        """
        Verify:
        1. Each section internally coherent (spectral gap consistent)
        2. Edge restriction maps valid (prev_hash linkage)
        """
        violations = []
        heights = sorted(self.sections.keys())

        for h in heights:
            section = self.sections[h]

            valid, reason = section.verify_coherence()
            if not valid:
                violations.append(f"Height {h}: {reason}")

            if h > 0 and (h - 1) in self.sections:
                prev_section = self.sections[h - 1]
                if section.prev_hash != prev_section.block_hash:
                    violations.append(
                        f"Edge ({h-1},{h}): prev_hash mismatch")

        return (len(violations) == 0, violations)

    def restrict_to_public(self) -> List[Dict[str, Any]]:
        """Restrict entire chain to public layer — light client sync."""
        return [
            self.sections[h].restrict_public()
            for h in sorted(self.sections.keys())
        ]

    def tip(self) -> Optional[BlockSection]:
        if not self.sections:
            return None
        return self.sections[max(self.sections.keys())]

    def height(self) -> int:
        return len(self.sections)
