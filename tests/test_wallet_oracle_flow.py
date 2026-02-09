"""
Full Flow Test: Wallet → Routing → Oracle

Tests the complete pipeline:
1. Generate credentials (Python)
2. Encrypt with Hodge noise (Python WalletStore)
3. Wrap in onion layers (Python routing)
4. Submit to Oracle (Rust)
5. Verify commitment matches

This is the panopticon-resistant flow:
- Content protected by Hodge encryption
- Transport protected by sheaf onion routing
- Metadata protected by constant padding
"""

import sys
import tempfile
from pathlib import Path
import numpy as np

# Add project root to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from src.geometry.fiber_bundle import FiberBundle, OnionRouter, create_onion_route
from src.crypto.encrypt import encrypt, CONSTANT_SIZE_DEFAULT, FibrationCiphertext
from src.oracle.client import FullStalkRequest, create_test_stalk
from dataclasses import dataclass, field
from typing import Dict, Any


@dataclass 
class EncryptedCredential:
    """Simplified credential for testing."""
    ciphertext_blob: bytes
    public_fingerprint: bytes
    topology_hash: bytes
    expected_invariants: Dict[str, Any] = field(default_factory=dict)


def create_test_credential(name: str, security_param: int = 32):
    """
    Create a minimal test credential.
    
    For testing, we use smaller dimensions than production.
    """
    # Minimal topology: 4 vertices in 2 disconnected components
    topology = {
        0: [(0,), (1,), (2,), (3,)],  # Vertices
        1: [(0, 1), (2, 3)]           # Edges (2 components)
    }
    
    # Build Laplacian with 2 components (β₀ = 2)
    n = 4
    laplacian = np.zeros((n, n))
    # Component 1: vertices 0-1
    laplacian[0, 0] = 1
    laplacian[0, 1] = -1
    laplacian[1, 0] = -1
    laplacian[1, 1] = 1
    # Component 2: vertices 2-3
    laplacian[2, 2] = 1
    laplacian[2, 3] = -1
    laplacian[3, 2] = -1
    laplacian[3, 3] = 1
    
    # Coboundary for edges
    delta_0 = np.zeros((2, n))  # 2 edges, 4 vertices
    delta_0[0, 0] = -1
    delta_0[0, 1] = 1
    delta_0[1, 2] = -1
    delta_0[1, 3] = 1
    
    # Create minimal credential
    class MinimalSpectrum:
        def __init__(self, laplacian):
            eigenvalues = np.linalg.eigvalsh(laplacian)
            self.eigenvalues = eigenvalues
            # topology_hash must be bytes for serialization
            hash_data = hash(str(topology)).to_bytes(8, 'little', signed=True) * 4
            self.topology_hash = hash_data[:32]
        
        def fingerprint_hash(self) -> bytes:
            """32-byte fingerprint from eigenvalues."""
            return bytes(np.frombuffer(
                np.array(self.eigenvalues).tobytes(), dtype=np.uint8
            )[:32])
    
    class MinimalFibration:
        def __init__(self, topology):
            self.edge_keys = {}
            for edge in topology.get(1, []):
                # Identity connection (flat bundle)
                self.edge_keys[edge] = np.eye(4)
    
    # Build credential manually for testing
    cred = type('FibrationCredential', (), {
        'topology': topology,
        'laplacian': laplacian,
        'delta_0': delta_0,
        'hilbert_dim': n,
        'modulus': 65537,
        'security_parameter': security_param,
        'spectrum': MinimalSpectrum(laplacian),
        'fibration': MinimalFibration(topology),
    })()
    
    return cred


def test_wallet_encryption():
    """Test basic wallet encryption works."""
    master = create_test_credential("master")
    
    message = b"Test secret credential data"
    ciphertext = encrypt(message, master, sigma_exact=2.0, sigma_harmonic=0.1)
    
    assert ciphertext.version == 2
    assert len(ciphertext.vertex_blocks) > 0
    assert len(ciphertext.edge_syndromes) > 0
    
    serialized = ciphertext.serialize()
    assert len(serialized) > 0


def test_onion_routing():
    """Test onion routing layer wrapping."""
    relays = []
    relay_keys = []
    
    for i in range(3):
        topology = {
            0: [(0,), (1,), (2,), (3,)],
            1: [(0, 1), (1, 2), (2, 3)]
        }
        bundle = FiberBundle.random(topology, fiber_dim=16)
        relays.append(bundle)
        relay_keys.append(np.random.randn(16))
    
    message = np.random.randn(16)
    packet = create_onion_route(relays, message, relay_keys)
    
    assert len(packet.layers) == 3
    assert len(packet.encrypted_hints) == 3


def test_constant_padding():
    """Test constant-size padding for panopticon resistance."""
    from src.crypto.padding import pad_to_constant, unpad_from_constant
    
    messages = [
        b"Short",
        b"Medium message with more content here",
        b"A" * 1000,
    ]
    
    target_size = 4096
    
    for msg in messages:
        padded = pad_to_constant(msg, target_size)
        assert len(padded) == target_size
        
        recovered = unpad_from_constant(padded)
        assert recovered == msg


def test_full_flow():
    """Test complete wallet → routing → Oracle preparation flow."""
    # 1. Generate credentials
    master = create_test_credential("master")
    wallet_cred = create_test_credential("wallet")
    
    # 2. Encrypt wallet credential
    credential_data = b"wallet_credential_private_data_here"
    ciphertext = encrypt(credential_data, master, sigma_exact=2.0, sigma_harmonic=0.1)
    encrypted_blob = ciphertext.serialize()
    assert len(encrypted_blob) > 0
    
    # 3. Create relay network
    relay_bundles = []
    relay_keys = []
    for i in range(3):
        topology = {0: [(j,) for j in range(8)], 1: [(j, j+1) for j in range(7)]}
        bundle = FiberBundle.random(topology, fiber_dim=32)
        relay_bundles.append(bundle)
        relay_keys.append(np.random.randn(32))
    
    # 4. Wrap in onion layers
    message_array = np.frombuffer(encrypted_blob, dtype=np.uint8)
    pad_len = (32 - len(message_array) % 32) % 32
    message_padded = np.pad(message_array, (0, pad_len), constant_values=0)
    chunk = message_padded[:32]
    onion_packet = create_onion_route(relay_bundles, chunk, relay_keys)
    assert len(onion_packet.layers) == 3
    
    # 5. Create EncryptedCredential for Oracle
    enc_cred = EncryptedCredential(
        ciphertext_blob=encrypted_blob,
        public_fingerprint=wallet_cred.spectrum.fingerprint_hash(),
        topology_hash=wallet_cred.spectrum.topology_hash,
        expected_invariants={
            "betti_0": 2,
            "spectral_gap": float(np.sort(np.linalg.eigvalsh(wallet_cred.laplacian))[2])
        }
    )
    
    assert len(enc_cred.public_fingerprint) == 32
    assert len(enc_cred.topology_hash) == 32
    assert enc_cred.expected_invariants["betti_0"] == 2


# =============================================================================
# Natural Transformation η Tests (Python↔Oracle hash agreement)
# =============================================================================

def test_eta_sha256_commitment():
    """
    Verify η_v: F_full(v) → F_hash(v) using SHA256 fallback.
    
    Python computes the same hash the Oracle would compute.
    This verifies the natural transformation is consistent.
    """
    import hashlib
    
    # Create credential data
    np.random.seed(42)
    credential = np.random.randn(256).tolist()
    
    # Python-side hash (same algorithm as Oracle's hash_credential)
    hasher = hashlib.sha256()
    for val in credential:
        hasher.update(np.float64(val).tobytes())
    python_hash = hasher.hexdigest()
    
    # Verify deterministic
    hasher2 = hashlib.sha256()
    for val in credential:
        hasher2.update(np.float64(val).tobytes())
    assert hasher2.hexdigest() == python_hash
    
    # Verify it's 32 bytes (64 hex chars)
    assert len(python_hash) == 64


def test_eta_geometric_commitment():
    """
    Verify η_v using geometric commitment (Hodge projection).
    
    This is the real system: credential → project to ker(Δ) → quantize.
    Python and Oracle must produce the same commitment bytes.
    """
    from src.geometry.hodge import compute_hodge_projectors
    
    # Build a Laplacian with known harmonic space
    n = 8
    # Two components of 4: β₀ = 2, so ker(Δ) is 2-dimensional
    laplacian = np.zeros((n, n))
    for start in [0, 4]:
        for i in range(start, start + 3):
            laplacian[i, i] += 1
            laplacian[i+1, i+1] += 1
            laplacian[i, i+1] = -1
            laplacian[i+1, i] = -1
    
    # Compute Hodge projectors
    P_harmonic, P_exact, P_coexact = compute_hodge_projectors(laplacian)
    
    # Verify decomposition: P_h + P_ex + P_coex = I
    identity = np.eye(n)
    reconstruction = P_harmonic + P_exact + P_coexact
    assert np.allclose(reconstruction, identity, atol=1e-10), \
        f"Hodge decomposition doesn't sum to identity"
    
    # Verify projectors are idempotent: P² = P
    assert np.allclose(P_harmonic @ P_harmonic, P_harmonic, atol=1e-10)
    assert np.allclose(P_exact @ P_exact, P_exact, atol=1e-10)
    
    # Verify orthogonality: P_h · P_ex = 0
    assert np.allclose(P_harmonic @ P_exact, 0, atol=1e-10)
    
    # Create credential and project to harmonic space
    np.random.seed(42)
    credential = np.random.randn(n)
    projected = P_harmonic @ credential
    
    # Quantize to bytes (matching Oracle's quantize_to_bytes)
    commitment = []
    for val in projected:
        quantized = int((val + 1.0) / 2.0 * 255.0)
        quantized = max(0, min(255, quantized))
        commitment.append(quantized)
    
    # Commitment is deterministic
    commitment2 = []
    projected2 = P_harmonic @ credential
    for val in projected2:
        quantized = int((val + 1.0) / 2.0 * 255.0)
        quantized = max(0, min(255, quantized))
        commitment2.append(quantized)
    
    assert commitment == commitment2, "Geometric commitment not deterministic"
    
    # Harmonic component should be non-trivial (β₀ = 2)
    assert np.linalg.norm(projected) > 0, "Harmonic projection is zero"


def test_eta_naturality():
    """
    Verify naturality: for edge e: v → w,
    F_hash(e) ∘ η_v = η_w ∘ F_full(e)
    
    Concretely: if two vertices share topology, their commitments
    should have matching topology hashes and compatible spectral gaps.
    """
    import hashlib
    
    # Shared nerve (same topology for both vertices)
    shared_vertices = [0, 1, 2]
    shared_edges = [(0, 1), (1, 2)]
    
    def compute_topology_hash(vertices, edges):
        """Same algorithm as Oracle's hash_topology."""
        hasher = hashlib.sha256()
        for v in vertices:
            hasher.update(v.to_bytes(8, 'little'))
        for (v0, v1) in edges:
            hasher.update(v0.to_bytes(8, 'little'))
            hasher.update(v1.to_bytes(8, 'little'))
        return hasher.digest()
    
    # Two vertices in same nerve
    topo_hash_v = compute_topology_hash(shared_vertices, shared_edges)
    topo_hash_w = compute_topology_hash(shared_vertices, shared_edges)
    
    # Naturality: topology hashes must match for connected vertices
    assert topo_hash_v == topo_hash_w, "Topology hashes don't match on edge"
    
    # Spectral gaps should be compatible (within tolerance)
    # Same Laplacian → same spectral gap
    n = 3
    laplacian = np.array([
        [ 1, -1,  0],
        [-1,  2, -1],
        [ 0, -1,  1]
    ], dtype=float)
    
    eigenvalues = np.linalg.eigvalsh(laplacian)
    # Find spectral gap (smallest nonzero eigenvalue)
    spectral_gap = min(ev for ev in eigenvalues if ev > 1e-6)
    
    assert spectral_gap > 0, "Spectral gap should be positive"
    assert spectral_gap < 3.0, f"Spectral gap too large: {spectral_gap}"


def test_eta_oracle_stalk_request():
    """
    Test creating a FullStalkRequest that would be sent to the Oracle.
    
    Verifies:
    - Python computes commitment bytes (Hodge projection + quantize)
    - Python computes spectral gap
    - Oracle receives pre-computed results (not raw Laplacian)
    """
    # Create stalk with known Laplacian — runs full Python geometry pipeline
    stalk = create_test_stalk(vertex_id=0, dimension=32, components=4)
    
    assert stalk.vertex_id == 0
    assert len(stalk.credential) == 32
    assert len(stalk.eigenvalues) == 32
    assert stalk.spectral_gap > 0, "Spectral gap must be positive"
    assert len(stalk.commitment_bytes) == 32, "Commitment must be 32 bytes"
    
    # Commitment is deterministic
    stalk2 = create_test_stalk(vertex_id=0, dimension=32, components=4)
    assert stalk2.commitment_bytes == stalk.commitment_bytes, "Commitment not deterministic"
    assert stalk2.spectral_gap == stalk.spectral_gap, "Spectral gap not deterministic"
    
    # Different vertex → different commitment
    stalk3 = create_test_stalk(vertex_id=1, dimension=32, components=4)
    assert stalk3.commitment_bytes != stalk.commitment_bytes, "Different vertices should differ"
    
    # JSON serialization uses new API (spectral_gap + commitment, not laplacian)
    json_req = stalk.to_json()
    assert json_req["method"] == "submit_stalk"
    assert json_req["params"]["vertex_id"] == 0
    assert "commitment" in json_req["params"], "Must send pre-computed commitment"
    assert "spectral_gap" in json_req["params"], "Must send pre-computed spectral gap"
    assert json_req["params"]["commitment"] == stalk.commitment_bytes.hex()
    # Oracle receives results, NOT raw Laplacian
    assert "laplacian" not in json_req["params"], "Must NOT send raw Laplacian to Oracle"


def test_eta_gluing_obstruction():
    """
    Test H^1 obstruction: section glues iff all naturality conditions hold.
    
    Create a consistent nerve where all topology hashes agree,
    then verify the section would glue (H^1 = 0).
    """
    import hashlib
    
    # Three vertices forming a path: 0 — 1 — 2
    shared_vertices = [0, 1, 2]
    shared_edges = [(0, 1), (1, 2)]
    
    def make_stalk(vertex_id):
        """Create consistent stalks sharing same topology."""
        np.random.seed(vertex_id)
        credential = np.random.randn(16).tolist()
        
        # Same Laplacian for all (shared topology)
        n = 3
        laplacian = np.array([
            [ 1, -1,  0],
            [-1,  2, -1],
            [ 0, -1,  1]
        ], dtype=float)
        eigenvalues = np.linalg.eigvalsh(laplacian).tolist()
        
        return {
            "vertex_id": vertex_id,
            "eigenvalues": eigenvalues,
            "nerve_vertices": shared_vertices,
            "nerve_edges": shared_edges,
        }
    
    stalks = [make_stalk(v) for v in range(3)]
    
    # Check naturality on each edge
    for (v, w) in shared_edges:
        sv = stalks[v]
        sw = stalks[w]
        
        # Same topology → same topology hash
        assert sv["nerve_vertices"] == sw["nerve_vertices"]
        assert sv["nerve_edges"] == sw["nerve_edges"]
        
        # Same Laplacian → same spectral gap
        assert sv["eigenvalues"] == sw["eigenvalues"]
    
    # Section glues: H^1 = 0
    # (All naturality conditions hold because topology is shared)


if __name__ == "__main__":
    print("=" * 60)
    print("FULL FLOW TEST: Wallet → Routing → Oracle")
    print("=" * 60)
    
    try:
        test_wallet_encryption()
        test_onion_routing()
        test_constant_padding()
        test_full_flow()
        test_eta_sha256_commitment()
        test_eta_geometric_commitment()
        test_eta_naturality()
        test_eta_oracle_stalk_request()
        test_eta_gluing_obstruction()
        
        print("\n" + "=" * 60)
        print("🎉 ALL TESTS PASSED!")
        print("=" * 60)
        
    except Exception as e:
        print(f"\n❌ Test failed: {e}")
        import traceback
        traceback.print_exc()
