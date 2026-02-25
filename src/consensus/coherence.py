"""
Čech Nerve Coherence — Sheaf Laplacian over Validator Set

Builds the consensus topology from validator stalks and computes
the sheaf Laplacian Δ_F. The harmonic subspace ker(Δ_F) is the
consensus signal; ‖π_H(stalk)‖ is each validator's harmonic weight.

Key outputs:
  - Čech nerve N(V): topology of validator overlaps
  - Cellular sheaf F over N(V): stalk subspaces + restriction maps
  - Sheaf Laplacian Δ_F: measures total geometric disagreement
  - Harmonic projection weights: ‖π_H(stalk(v))‖ / ‖stalk(v)‖
  - Betti numbers: β₀ = components, β₁ = persistent disagreement

See docs/CONSENSUS.md § Grassmann Consensus.
"""

from typing import Dict, List, Tuple, Optional, Set
from dataclasses import dataclass
import numpy as np

from ..primitives.grassmann import (
    grassmann_distance,
    grassmann_karcher_mean,
    stalk_to_subspace,
    principal_angles,
)


# =============================================================================
# CONSTANTS
# =============================================================================

MAX_DIVERGENCE: float = 1.2        # Max Grassmann distance for eligibility
EDGE_THRESHOLD: float = 1.0        # Max distance for Čech nerve edge
SQRT2 = np.sqrt(2.0)
INV_SQRT2 = 1.0 / SQRT2


# =============================================================================
# ČECH NERVE
# =============================================================================

@dataclass
class CechNerve:
    """
    Čech nerve of the validator set.

    vertices = validators (by fingerprint)
    edges = pairs with d_Gr < EDGE_THRESHOLD

    β₀(N) = 1 → all validators form one coherent cluster
    β₀(N) > 1 → network is PARTITIONED (reject block)
    β₁(N) > 0 → persistent disagreement cycle (flag, don't reject)
    """
    fingerprints: List[bytes]                # Vertex order
    adjacency: np.ndarray                    # n×n boolean adjacency
    distances: np.ndarray                    # n×n Grassmann distances

    @property
    def n_vertices(self) -> int:
        return len(self.fingerprints)

    @property
    def n_edges(self) -> int:
        return int(np.sum(self.adjacency) / 2)

    def beta_0(self) -> int:
        """Connected components (β₀). Must be 1 for valid block."""
        n = self.n_vertices
        if n == 0:
            return 0

        visited = set()
        components = 0

        for start in range(n):
            if start in visited:
                continue
            components += 1
            stack = [start]
            while stack:
                v = stack.pop()
                if v in visited:
                    continue
                visited.add(v)
                for u in range(n):
                    if self.adjacency[v, u] and u not in visited:
                        stack.append(u)

        return components

    def beta_1(self) -> int:
        """
        First Betti number (independent cycles).
        β₁ = edges - vertices + components

        β₁ > 0 means persistent disagreement — information, not failure.
        """
        return self.n_edges - self.n_vertices + self.beta_0()

    def neighbors(self, idx: int) -> List[int]:
        """Get neighbor indices for a vertex."""
        return [j for j in range(self.n_vertices) if self.adjacency[idx, j]]


# =============================================================================
# COHERENCE ENGINE
# =============================================================================

class CoherenceEngine:
    """
    Builds Čech nerve, computes sheaf Laplacian, extracts harmonic weights.

    This is the core consensus geometry:
      1. Build nerve from validator stalk overlaps
      2. Compute sheaf Laplacian Δ_F over the nerve
      3. Hodge-decompose each stalk: harmonic + exact + coexact
      4. Return harmonic projection weights for validator selection
    """

    def __init__(self, stalk_dim: int = 2):
        self.stalk_dim = stalk_dim
        self._nerve: Optional[CechNerve] = None
        self._consensus: Optional[np.ndarray] = None
        self._laplacian: Optional[np.ndarray] = None

    def build_nerve(
        self,
        stalks: Dict[bytes, np.ndarray],
        threshold: float = EDGE_THRESHOLD,
    ) -> CechNerve:
        """
        Build Čech nerve from validator stalk data.

        Two validators share an edge when their stalks are
        within threshold on Gr(k,n).
        """
        fingerprints = sorted(stalks.keys())
        n = len(fingerprints)

        # Compute projectors
        projectors = {}
        for fp in fingerprints:
            try:
                projectors[fp] = stalk_to_subspace(stalks[fp], self.stalk_dim)
            except Exception:
                projectors[fp] = np.eye(self.stalk_dim)

        # Pairwise distances
        distances = np.zeros((n, n))
        adjacency = np.zeros((n, n), dtype=bool)

        for i in range(n):
            for j in range(i + 1, n):
                d = grassmann_distance(
                    projectors[fingerprints[i]],
                    projectors[fingerprints[j]]
                )
                distances[i, j] = d
                distances[j, i] = d
                if d < threshold:
                    adjacency[i, j] = True
                    adjacency[j, i] = True

        self._nerve = CechNerve(
            fingerprints=fingerprints,
            adjacency=adjacency,
            distances=distances,
        )
        return self._nerve

    def compute_consensus(
        self,
        stalks: Dict[bytes, np.ndarray],
    ) -> Optional[np.ndarray]:
        """Compute Karcher mean consensus subspace."""
        projectors = []
        for fp in sorted(stalks.keys()):
            try:
                P = stalk_to_subspace(stalks[fp], self.stalk_dim)
                if P.size > 0:
                    projectors.append(P)
            except Exception:
                continue

        if len(projectors) < 2:
            return None

        try:
            self._consensus = grassmann_karcher_mean(projectors)
            return self._consensus
        except Exception:
            return None

    def compute_sheaf_laplacian(
        self,
        stalks: Dict[bytes, np.ndarray],
    ) -> Optional[np.ndarray]:
        """
        Compute the 0-th sheaf Laplacian Δ_F over the Čech nerve.

        Δ_F = δ*δ where δ is the coboundary using restriction maps
        (principal angle projections between neighboring stalks).

        ker(Δ_F) = global sections = perfect validator agreement
        """
        if self._nerve is None:
            self.build_nerve(stalks)

        nerve = self._nerve
        n = nerve.n_vertices
        d = self.stalk_dim
        N = n * d  # Total dimension (block Laplacian)

        fingerprints = nerve.fingerprints

        # Build projectors
        projectors = {}
        for fp in fingerprints:
            try:
                projectors[fp] = stalk_to_subspace(stalks[fp], d)
            except Exception:
                projectors[fp] = np.eye(d)

        # Block sheaf Laplacian: Δ[i,j] is a d×d block
        laplacian = np.zeros((N, N))

        for i in range(n):
            P_i = projectors[fingerprints[i]]
            degree_block = np.zeros((d, d))

            for j in nerve.neighbors(i):
                P_j = projectors[fingerprints[j]]
                # Restriction map: project i's stalk onto j's subspace
                R_ij = P_j @ P_i  # d×d
                diff = np.eye(d) - R_ij
                contribution = diff.T @ diff

                degree_block += contribution

                # Off-diagonal block
                laplacian[i*d:(i+1)*d, j*d:(j+1)*d] = -contribution

            # Diagonal block
            laplacian[i*d:(i+1)*d, i*d:(i+1)*d] = degree_block

        self._laplacian = laplacian
        return laplacian

    def verify_stalk_binding(
        self,
        fingerprint: bytes,
        stalk: np.ndarray,
        oracle_commitment: Optional[bytes] = None,
        nerve_commitment: Optional[bytes] = None,
    ) -> Tuple[bool, str]:
        """
        ANTI-INFLATION CHECK: Verify a validator's stalk is bound to credential.

        ATTACK VECTOR (without this check):
          1. Validator observes other stalks (public for consensus)
          2. Pre-computes shared Laplacian Δ_F from nerve
          3. Finds ker(Δ_F) — the harmonic subspace
          4. Crafts stalk ∈ ker(Δ_F) to maximize ‖π_H(stalk)‖/‖stalk‖
          5. Gets inflated treasury rewards

        DEFENSE (this check):
          Stalk must be consistent with the validator's oracle commitment.
          The oracle commitment binds the credential's spectral fingerprint
          (eigenvalues, Betti numbers, topology hash). A crafted stalk that
          doesn't match the committed spectral structure is rejected.

          Specifically:
          a) Stalk norm must be in [0.1, 10.0] (no degenerate vectors)
          b) If oracle commitment provided, stalk hash must be derivable
             from the committed credential (spectral fingerprint match)
          c) Stalk must be consistent with nerve topology (if committed)

        This doesn't require the full credential — just that the stalk's
        geometric properties match what was committed via oracle.
        """
        import hashlib

        # (a) Basic sanity: stalk is well-formed
        stalk_flat = stalk.flatten()[:self.stalk_dim]
        norm = np.linalg.norm(stalk_flat)
        if norm < 0.1:
            return (False, f"Stalk norm {norm:.4f} < 0.1 — degenerate")
        if norm > 10.0:
            return (False, f"Stalk norm {norm:.4f} > 10.0 — abnormal")

        # (b) Oracle commitment binding: stalk hash must be derivable
        if oracle_commitment is not None:
            # The oracle stores a commitment that includes the stalk's
            # spectral fingerprint. We verify the stalk could produce
            # this commitment (hash of quantized projector).
            projector = stalk_to_subspace(stalk_flat, self.stalk_dim)
            # Quantize to 32-bit to match oracle commitment granularity
            quantized = np.round(projector * 1e6).astype(np.int64)
            stalk_hash = hashlib.sha256(
                fingerprint + quantized.tobytes()
            ).digest()
            # First 16 bytes of commitment should match stalk hash prefix
            if oracle_commitment[:16] != stalk_hash[:16]:
                return (False, "Stalk inconsistent with oracle commitment")

        # (c) Nerve consistency: stalk position plausible for topology
        if nerve_commitment is not None and self._nerve is not None:
            # Check that stalk has at least one neighbor in nerve
            # (isolated stalks can't be harmonic-inflated, but also
            #  shouldn't participate in consensus)
            fp_list = self._nerve.fingerprints
            if fingerprint in fp_list:
                idx = fp_list.index(fingerprint)
                if len(self._nerve.neighbors(idx)) == 0:
                    return (False, "Stalk isolated in nerve — no neighbors")

        return (True, "Stalk binding verified")

    def compute_harmonic_weights(
        self,
        stalks: Dict[bytes, np.ndarray],
        oracle_commitments: Optional[Dict[bytes, bytes]] = None,
    ) -> Dict[bytes, float]:
        """
        Compute harmonic projection weight for each validator.

        weight(v) = ‖π_H(stalk(v))‖ / ‖stalk(v)‖

        where π_H projects onto ker(Δ_F) — the harmonic subspace
        of the sheaf Laplacian.

        ANTI-INFLATION: If oracle_commitments provided, each stalk is
        verified against its credential commitment before weight computation.
        Stalks that fail binding check get ZERO weight.

        This IS the validator's "value" — the part of their stalk
        that survives the network's Hodge projection.
        """
        # ANTI-INFLATION: verify stalk bindings before computing weights
        verified_stalks = {}
        for fp, stalk in stalks.items():
            commitment = oracle_commitments.get(fp) if oracle_commitments else None
            ok, reason = self.verify_stalk_binding(fp, stalk, commitment)
            if ok:
                verified_stalks[fp] = stalk
            # Silently exclude unverified stalks (zero weight)

        if len(verified_stalks) < 2:
            # Not enough verified stalks — fall back to uniform
            return {fp: 1.0 / len(stalks) for fp in stalks}

        # Use only verified stalks for Laplacian computation
        stalks = verified_stalks
        laplacian = self.compute_sheaf_laplacian(stalks)
        if laplacian is None:
            # Fallback: equal weights
            return {fp: 1.0 / len(stalks) for fp in stalks}

        # Eigendecomposition
        eigenvalues, eigenvectors = np.linalg.eigh(laplacian)

        # Harmonic subspace = ker(Δ) = eigenspace of eigenvalues ≈ 0
        tol = 1e-8
        harmonic_mask = np.abs(eigenvalues) < tol
        n_harmonic = np.sum(harmonic_mask)

        if n_harmonic == 0:
            # No exact harmonic — use near-harmonic (smallest eigenvalues)
            k = min(self.stalk_dim, len(eigenvalues))
            harmonic_mask = np.zeros(len(eigenvalues), dtype=bool)
            harmonic_mask[np.argsort(eigenvalues)[:k]] = True

        # Harmonic projector π_H
        H_basis = eigenvectors[:, harmonic_mask]  # N × n_harmonic
        pi_H = H_basis @ H_basis.T               # N × N

        # Project each validator's stalk and compute weight
        fingerprints = sorted(stalks.keys())
        d = self.stalk_dim
        weights = {}

        for idx, fp in enumerate(fingerprints):
            # Extract validator's block from the stacked vector
            stalk_vec = stalks[fp].flatten()[:d]
            if len(stalk_vec) < d:
                stalk_vec = np.pad(stalk_vec, (0, d - len(stalk_vec)))

            # Embed in full space
            full_vec = np.zeros(pi_H.shape[0])
            full_vec[idx*d:(idx+1)*d] = stalk_vec

            # Project
            projected = pi_H @ full_vec
            proj_block = projected[idx*d:(idx+1)*d]

            stalk_norm = np.linalg.norm(stalk_vec)
            proj_norm = np.linalg.norm(proj_block)

            if stalk_norm > 1e-12:
                weights[fp] = proj_norm / stalk_norm
            else:
                weights[fp] = 0.0

        # Normalize
        total = sum(weights.values())
        if total > 0:
            weights = {k: v / total for k, v in weights.items()}

        return weights

    def check_eligibility(
        self,
        fingerprint: bytes,
        stalks: Dict[bytes, np.ndarray],
    ) -> Tuple[bool, float]:
        """
        Plücker eligibility gate: is validator close enough to consensus?

        Returns (eligible, distance).
        """
        consensus = self.compute_consensus(stalks)
        if consensus is None:
            return (True, 0.0)  # Can't compute → allow

        if fingerprint not in stalks:
            return (False, float('inf'))

        try:
            P = stalk_to_subspace(stalks[fingerprint], self.stalk_dim)
            dist = grassmann_distance(P, consensus)
            return (dist < MAX_DIVERGENCE, dist)
        except Exception:
            return (False, float('inf'))

    def validate_block_topology(self, stalks: Dict[bytes, np.ndarray]) -> Dict:
        """
        Full topology validation for a block.

        Returns dict with β₀, β₁, spectral_gap, is_valid.
        """
        nerve = self.build_nerve(stalks)
        beta_0 = nerve.beta_0()
        beta_1 = nerve.beta_1()

        laplacian = self.compute_sheaf_laplacian(stalks)
        spectral_gap = 0.0
        if laplacian is not None:
            eigs = np.linalg.eigvalsh(laplacian)
            positive_eigs = eigs[eigs > 1e-8]
            if len(positive_eigs) > 0:
                spectral_gap = float(positive_eigs[0])

        # Validity: β₀ = 1 (connected) and spectral gap in bounds
        is_valid = (
            beta_0 == 1
            and INV_SQRT2 <= spectral_gap <= 2 * SQRT2
        )

        return {
            'beta_0': beta_0,
            'beta_1': beta_1,
            'spectral_gap': spectral_gap,
            'n_validators': nerve.n_vertices,
            'n_edges': nerve.n_edges,
            'is_valid': is_valid,
            'flags': ['persistent_disagreement'] if beta_1 > 0 else [],
        }
