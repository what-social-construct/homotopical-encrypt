"""
Oracle Client - Python interface to Rust Oracle

COMPUTATION BOUNDARY:
  Python computes ALL heavy geometry:
    - SheafLaplacian: eigendecomposition, harmonic projection, spectral gap
    - HodgeDecomposition: project onto ker(Δ), quantize to commitment bytes
    - FiberBundle: parallel transport, holonomy, connection matrices

  Oracle (Rust) VERIFIES pre-computed results:
    - Spectral gap in Tsirelson bounds [1/√2, 2√2]
    - Betti numbers consistent (β₀ ≥ 1)
    - Commitment bytes non-trivial
    - Naturality conditions across edges

  Python sends pre-computed commitment + invariants.
  Oracle does NOT recompute eigendecomposition or Hodge projection.

See: rust/oracle/src/stalk_bridge.rs (COMPUTATION BOUNDARY comment)
     src/geometry/sheaf_laplacian.py, src/geometry/hodge.py
"""

import json
import hashlib
import requests
from dataclasses import dataclass
from typing import Optional, List, Tuple, Dict, Any
import numpy as np


@dataclass
class FullStalkRequest:
    """Request to submit a full stalk to Oracle.
    
    Python computes ALL geometry and sends results.
    Oracle verifies bounds only.
    """
    vertex_id: int
    credential: List[float]
    eigenvalues: List[float]
    betti_numbers: Tuple[int, int, int]
    nerve_vertices: List[int]
    nerve_edges: List[Tuple[int, int]]
    spectral_gap: float          # Pre-computed by Python
    commitment_bytes: bytes       # Pre-computed by Python (32 bytes)
    
    @classmethod
    def from_geometry(
        cls,
        vertex_id: int,
        credential: np.ndarray,
        laplacian: np.ndarray,
        nerve_vertices: List[int],
        nerve_edges: List[Tuple[int, int]],
        betti_numbers: Tuple[int, int, int] = (1, 0, 0),
    ) -> 'FullStalkRequest':
        """Build request by computing geometry locally.
        
        This is the PRIMARY constructor — it runs the full geometry pipeline:
        1. Eigendecomposition of Laplacian → eigenvalues, spectral gap
        2. Hodge projection onto ker(Δ) → harmonic component
        3. Quantize to 32 bytes → commitment
        
        All heavy computation happens HERE in Python.
        Oracle receives the results and verifies bounds only.
        """
        from ..geometry.hodge import compute_hodge_projectors
        
        # 1. Eigendecomposition (heavy — numpy does this)
        eigenvalues = np.linalg.eigvalsh(laplacian).tolist()
        
        # 2. Spectral gap (first nonzero eigenvalue)
        sorted_eigs = sorted(eigenvalues)
        spectral_gap = 0.0
        for eig in sorted_eigs:
            if eig > 1e-6:
                spectral_gap = eig
                break
        
        # 3. Hodge projection (heavy — numpy linear algebra)
        P_harmonic, _, _ = compute_hodge_projectors(laplacian)
        credential_vec = np.array(credential, dtype=np.float64)
        
        if len(credential_vec) == P_harmonic.shape[0]:
            projected = P_harmonic @ credential_vec
        else:
            projected = credential_vec
        
        # 4. Quantize to 32 bytes (deterministic)
        commitment_bytes = _quantize_to_bytes(projected, 32)
        
        return cls(
            vertex_id=vertex_id,
            credential=credential.tolist() if isinstance(credential, np.ndarray) else credential,
            eigenvalues=eigenvalues,
            betti_numbers=betti_numbers,
            nerve_vertices=nerve_vertices,
            nerve_edges=nerve_edges,
            spectral_gap=spectral_gap,
            commitment_bytes=commitment_bytes,
        )
    
    def to_json(self) -> Dict[str, Any]:
        """Convert to JSON-RPC request for Oracle."""
        return {
            "method": "submit_stalk",
            "params": {
                "vertex_id": self.vertex_id,
                "credential": self.credential,
                "eigenvalues": self.eigenvalues,
                "betti_numbers": self.betti_numbers,
                "nerve_vertices": self.nerve_vertices,
                "nerve_edges": self.nerve_edges,
                "spectral_gap": self.spectral_gap,
                "commitment": self.commitment_bytes.hex(),
            }
        }


def _quantize_to_bytes(projected: np.ndarray, num_bytes: int) -> bytes:
    """Quantize projected vector to fixed-size bytes.
    
    Must match Rust Oracle's quantize_to_bytes() exactly:
    - Scale each component: (val + 1.0) / 2.0 * 255.0
    - Clamp to [0, 255]
    - Pad with zeros to num_bytes
    """
    result = []
    for i in range(min(num_bytes, len(projected))):
        val = projected[i]
        normalized = int((val + 1.0) / 2.0 * 255.0)
        normalized = max(0, min(255, normalized))
        result.append(normalized)
    
    while len(result) < num_bytes:
        result.append(0)
    
    return bytes(result)


@dataclass
class CommitmentResponse:
    """Response from Oracle with verified commitment."""
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
    """Client for communicating with Rust Oracle.
    
    Python computes geometry → sends to Oracle → Oracle verifies bounds → stores.
    """
    
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
        """Submit a full stalk and get verified commitment."""
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
    
    Runs the full Python geometry pipeline:
    1. Build Laplacian with disconnected components
    2. Eigendecomposition → eigenvalues, spectral gap
    3. Hodge projection → commitment bytes
    
    Args:
        vertex_id: Vertex identifier
        dimension: Credential dimension (must be divisible by components)
        components: Number of disconnected components (β₀)
    """
    np.random.seed(vertex_id)
    credential = np.random.randn(dimension)
    
    # Build Laplacian with disconnected components
    n = dimension
    group_size = n // components
    laplacian = np.zeros((n, n))
    
    for c in range(components):
        start = c * group_size
        for i in range(start, start + group_size):
            laplacian[i, i] = 2
            if i > start:
                laplacian[i, i-1] = -1
                laplacian[i-1, i] = -1
        # Endpoints have degree 1 (valid graph Laplacian: rows sum to 0)
        laplacian[start, start] = 1
        laplacian[start + group_size - 1, start + group_size - 1] = 1
    
    # Use from_geometry to run full pipeline
    return FullStalkRequest.from_geometry(
        vertex_id=vertex_id,
        credential=credential,
        laplacian=laplacian,
        nerve_vertices=[vertex_id],
        nerve_edges=[],
        betti_numbers=(components, 0, 0),
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
        print(f"   Spectral gap: {stalk.spectral_gap:.4f}")
        print(f"   Commitment: {stalk.commitment_bytes.hex()[:32]}...")
        
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
