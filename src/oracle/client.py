"""
Oracle Client - Python interface to Rust Oracle

Sends FullStalks to Oracle for commitment computation.
Receives HashStalks (geometric commitments) back.
"""

import json
import hashlib
import requests
from dataclasses import dataclass
from typing import Optional, List, Tuple, Dict, Any
import numpy as np


@dataclass
class FullStalkRequest:
    """Request to submit a full stalk to Oracle."""
    vertex_id: int
    credential: List[float]
    eigenvalues: List[float]
    betti_numbers: Tuple[int, int, int]
    nerve_vertices: List[int]
    nerve_edges: List[Tuple[int, int]]
    laplacian: List[List[float]]
    
    def compute_python_hash(self) -> str:
        """Compute geometric commitment hash (must match Oracle's computation).
        
        For now, we use a placeholder - real implementation requires
        computing the Hodge projection locally.
        
        When laplacian is provided, the Oracle computes geometric commitment.
        We need to match that computation.
        """
        # For testing without Laplacian: use SHA256
        if not hasattr(self, 'laplacian') or not self.laplacian:
            hasher = hashlib.sha256()
            for val in self.credential:
                hasher.update(np.float64(val).tobytes())
            return hasher.hexdigest()
        
        # With Laplacian: compute Hodge projection commitment
        # This is what the Oracle computes - we need to match it
        from src.geometry.hodge import compute_hodge_projectors
        laplacian = np.array(self.laplacian)
        P_harmonic, _, _ = compute_hodge_projectors(laplacian)
        
        # Quantize to bytes (matching Oracle's quantize_to_bytes)
        credential_vec = np.array(self.credential)
        if len(credential_vec) == P_harmonic.shape[0]:
            projected = P_harmonic @ credential_vec
        else:
            projected = credential_vec  # No projection if dims don't match
        
        # Quantize: same as Rust
        commitment = []
        for val in projected[:32]:  # First 32 components
            quantized = int((val + 1.0) / 2.0 * 255.0)
            quantized = max(0, min(255, quantized))
            commitment.append(quantized)
        
        # Pad to 32 bytes
        while len(commitment) < 32:
            commitment.append(0)
        
        return bytes(commitment).hex()
    
    def to_json(self) -> Dict[str, Any]:
        """Convert to JSON-RPC request."""
        return {
            "method": "submit_stalk",
            "params": {
                "vertex_id": self.vertex_id,
                "credential": self.credential,
                "eigenvalues": self.eigenvalues,
                "betti_numbers": self.betti_numbers,
                "nerve_vertices": self.nerve_vertices,
                "nerve_edges": self.nerve_edges,
                "laplacian": self.laplacian,
                "python_hash": self.compute_python_hash()
            }
        }


@dataclass
class CommitmentResponse:
    """Response from Oracle with computed commitment."""
    success: bool
    vertex_id: int
    fingerprint: str  # Hex-encoded
    spectral_gap: float
    betti_numbers: Tuple[int, int, int]
    
    @classmethod
    def from_json(cls, data: Dict[str, Any]) -> 'CommitmentResponse':
        return cls(
            success=data.get("success", False),
            vertex_id=data.get("vertex_id", 0),
            fingerprint=data.get("fingerprint", ""),
            spectral_gap=data.get("spectral_gap", 0.0),
            betti_numbers=tuple(data.get("betti_numbers", (0, 0, 0)))
        )


class OracleClient:
    """Client for communicating with Rust Oracle."""
    
    def __init__(self, oracle_url: str = "http://127.0.0.1:9090"):
        self.oracle_url = oracle_url
        self.rpc_url = f"{oracle_url}/rpc"
    
    def _post_rpc(self, request: Dict[str, Any]) -> Dict[str, Any]:
        """Send JSON-RPC request to Oracle."""
        try:
            response = requests.post(
                self.rpc_url,
                json=request,
                headers={"Content-Type": "application/json"},
                timeout=30
            )
            response.raise_for_status()
            return response.json()
        except requests.exceptions.ConnectionError:
            return {"error": "Connection failed - is Oracle running?", "code": -1}
        except Exception as e:
            return {"error": str(e), "code": -1}
    
    def submit_stalk(self, stalk: FullStalkRequest) -> CommitmentResponse:
        """Submit a full stalk and get commitment."""
        response = self._post_rpc(stalk.to_json())
        
        if "error" in response:
            return CommitmentResponse(
                success=False,
                vertex_id=stalk.vertex_id,
                fingerprint="",
                spectral_gap=0.0,
                betti_numbers=(0, 0, 0)
            )
        
        return CommitmentResponse.from_json(response)
    
    def get_commitment(self, vertex_id: int) -> Optional[Dict[str, Any]]:
        """Query commitment for a vertex."""
        response = self._post_rpc({
            "method": "get_commitment",
            "params": {"vertex_id": vertex_id}
        })
        
        if response.get("found"):
            return response.get("commitment")
        return None
    
    def add_edge(self, from_vertex: int, to_vertex: int) -> bool:
        """Add edge for naturality checking."""
        response = self._post_rpc({
            "method": "add_edge",
            "params": {"from": from_vertex, "to": to_vertex}
        })
        return response.get("success", False)
    
    def verify_naturality(self) -> Dict[str, Any]:
        """Verify all naturality conditions."""
        return self._post_rpc({"method": "verify_naturality", "params": {}})
    
    def check_gluing(self) -> Dict[str, Any]:
        """Check if section glues (H^1 = 0)."""
        return self._post_rpc({"method": "check_gluing", "params": {}})
    
    def health(self) -> Dict[str, Any]:
        """Health check."""
        try:
            response = requests.get(f"{self.oracle_url}/health", timeout=5)
            return response.json()
        except:
            return {"status": "unreachable"}


def create_test_stalk(vertex_id: int, dimension: int = 32, components: int = 4) -> FullStalkRequest:
    """Create a test stalk for development.
    
    Args:
        vertex_id: Vertex identifier
        dimension: Credential dimension (must be divisible by components)
        components: Number of disconnected components (β₀)
    """
    # Random credential - dimension must match Laplacian!
    np.random.seed(vertex_id)  # Deterministic for testing
    credential = np.random.randn(dimension).tolist()
    
    # Laplacian with disconnected components (β₀ = components)
    # This gives richer harmonic fingerprints!
    n = dimension
    group_size = n // components
    laplacian = np.zeros((n, n))
    
    for c in range(components):
        start = c * group_size
        # Chain within each component
        for i in range(start, start + group_size):
            laplacian[i, i] = 2
            if i > start:
                laplacian[i, i-1] = -1
                laplacian[i-1, i] = -1
        # Endpoints have degree 1
        laplacian[start, start] = 1
        laplacian[start + group_size - 1, start + group_size - 1] = 1
    
    # Eigenvalues of Laplacian
    eigenvalues = np.linalg.eigvalsh(laplacian).tolist()
    
    return FullStalkRequest(
        vertex_id=vertex_id,
        credential=credential,
        eigenvalues=eigenvalues,
        betti_numbers=(1, 0, 0),  # Connected graph
        nerve_vertices=[vertex_id],
        nerve_edges=[],
        laplacian=laplacian.tolist()
    )


# =============================================================================
# CLI
# =============================================================================

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Oracle Client")
    parser.add_argument("--oracle", default="http://127.0.0.1:9090", help="Oracle URL")
    parser.add_argument("--test", action="store_true", help="Run test submission")
    args = parser.parse_args()
    
    client = OracleClient(args.oracle)
    
    if args.test:
        print("🧪 Testing Oracle connection...")
        
        # Health check
        health = client.health()
        print(f"Health: {health}")
        
        # Create and submit test stalk
        print("\n📤 Submitting test stalk...")
        stalk = create_test_stalk(vertex_id=0)
        print(f"   Vertex: {stalk.vertex_id}")
        print(f"   Credential dim: {len(stalk.credential)}")
        print(f"   Python hash: {stalk.compute_python_hash()[:16]}...")
        
        response = client.submit_stalk(stalk)
        print(f"\n📥 Response:")
        print(f"   Success: {response.success}")
        print(f"   Fingerprint: {response.fingerprint[:16]}..." if response.fingerprint else "   Fingerprint: (none)")
        print(f"   Spectral gap: {response.spectral_gap}")
        print(f"   Betti: {response.betti_numbers}")
    else:
        # Just health check
        health = client.health()
        print(f"Oracle status: {health}")
