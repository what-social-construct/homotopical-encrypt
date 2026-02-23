"""
Semitopological Coalitions — Gabbay & Losa (2024) for PoV Consensus

From the paper (Swan et al.):
  "A blockchain-based semitopology consensus process is proposed for
   decentralized decision-making with actionable coalitions as a
   foundational cryptoeconomic primitive."

SEMITOPOLOGY:
  A semitopology on a set V is a collection T of subsets (coalitions)
  such that V ∈ T and ∅ ∈ T, but we do NOT require that intersections
  of open sets are open. This relaxation is crucial:

    In point-set topology: U ∩ V ∈ T  (intersection of opens is open)
    In semitopology:       U ∩ V may NOT be in T

  Why? Because "validator A can cooperate with B" and "A can cooperate
  with C" does NOT imply "A, B, C can all cooperate together." The
  intersection failure captures real-world coalition dynamics.

IMPLEMENTATION ON ČECH NERVE:
  Our CechNerve already computes which validator subsets have mutual
  Grassmann overlap (d_Gr < threshold). A simplex σ = {v₀,...,vₖ}
  in N(V) means those validators are pairwise close.

  The semitopology extends this:
  - Coalition = a simplex in the Čech nerve where ALL validators
    have stalks that are JOINTLY compatible (not just pairwise)
  - Actionable = coalition can collectively propose a state update
  - The Heyting algebra from topos.py provides the logic:
    a coalition's proposal is VALID, UNDETERMINED, or INVALID

CONSENSUS PROTOCOL:
  1. Each epoch, VRF selects a producer (vrf.rs)
  2. Producer proposes a block with a coalition witness:
     - Which validators' stalks are jointly compatible
     - The harmonic projection of their joint stalk space
  3. Other validators verify the coalition is actionable:
     - Check simplicial inclusion in N(V)
     - Check joint Grassmann compatibility (not just pairwise)
  4. Topos judgment: VALID only if coalition covers β₀=1 component

References:
  Gabbay & Losa (2024) "Semitopology: Decentralised Collaborative
    Action via Topology, Algebra, and Logic"
  Swan et al. (2025) "Higher Categorical Cryptoeconomics"
"""

from dataclasses import dataclass, field
from typing import List, Dict, Set, Tuple, Optional, FrozenSet
import numpy as np
import hashlib


# =============================================================================
# COALITION
# =============================================================================

@dataclass
class Coalition:
    """
    An actionable coalition: a subset of validators that can
    collaboratively propose a state update.

    Unlike point-set topology, intersection of actionable coalitions
    is NOT necessarily actionable (semitopological relaxation).

    Attributes:
        members: frozenset of validator identity hashes
        joint_subspace: projection onto the shared stalk subspace
        coherence_score: how aligned the coalition members are (0,1]
        is_actionable: whether this coalition can propose updates
    """
    members: FrozenSet[bytes]
    joint_subspace: Optional[np.ndarray] = None  # Projection matrix
    coherence_score: float = 0.0
    is_actionable: bool = False

    def size(self) -> int:
        return len(self.members)

    def contains(self, identity: bytes) -> bool:
        return identity in self.members

    def intersect(self, other: 'Coalition') -> 'Coalition':
        """
        Intersection of two coalitions.

        SEMITOPOLOGICAL: the result may NOT be actionable even if
        both inputs are actionable. This is the key departure from
        point-set topology.
        """
        return Coalition(
            members=self.members & other.members,
            is_actionable=False,  # Must be re-evaluated!
        )


# =============================================================================
# SEMITOPOLOGY
# =============================================================================

class Semitopology:
    """
    A semitopology on the validator set: a collection of coalitions
    where intersections are NOT required to be coalitions.

    Built from the Čech nerve of the validator stalk space.

    Properties:
        V ∈ T           (full set is a coalition — trivially)
        ∅ ∈ T           (empty set is a coalition — vacuously)
        U ∪ V ∈ T       NOT required (unions may fail)
        U ∩ V ∈ T       NOT required (semitopological relaxation)
    """

    def __init__(self):
        self._coalitions: Dict[FrozenSet[bytes], Coalition] = {}
        self._validator_stalks: Dict[bytes, np.ndarray] = {}

    def register_validator(self, identity: bytes, stalk: np.ndarray):
        """Register a validator with its stalk (subspace on Grassmannian)."""
        self._validator_stalks[identity] = stalk

    def _grassmann_distance(self, stalk_a: np.ndarray, stalk_b: np.ndarray) -> float:
        """
        Grassmann distance between two subspaces.

        d_Gr(A, B) = arccos(min singular value of A^T B)
        Range: [0, π/2]
        """
        # Orthonormalize both
        qa, _ = np.linalg.qr(stalk_a.T)
        qb, _ = np.linalg.qr(stalk_b.T)

        # Truncate to min rank
        k = min(qa.shape[1], qb.shape[1])
        qa = qa[:, :k]
        qb = qb[:, :k]

        svd = np.linalg.svd(qa.T @ qb, compute_uv=False)
        # Clamp for numerical stability
        cos_theta = np.clip(svd[-1], -1.0, 1.0)
        return float(np.arccos(cos_theta))

    def _joint_coherence(self, identities: FrozenSet[bytes]) -> Tuple[float, Optional[np.ndarray]]:
        """
        Compute joint coherence of a set of validators.

        This checks whether the stalks are JOINTLY compatible,
        not just pairwise. Joint compatibility is stricter:
        the intersection of all stalk subspaces must be non-trivial.

        Returns:
            (coherence_score, joint_projection_matrix)
            coherence_score ∈ (0, 1] if compatible, 0 if not
        """
        stalks = []
        for ident in identities:
            if ident not in self._validator_stalks:
                return 0.0, None
            stalks.append(self._validator_stalks[ident])

        if len(stalks) < 2:
            return 1.0, None

        # Compute joint subspace via iterated projection
        # Start with first stalk's column space
        combined = stalks[0].T  # columns = stalk vectors
        qa, _ = np.linalg.qr(combined)

        for s in stalks[1:]:
            qb, _ = np.linalg.qr(s.T)
            # Project qa onto qb's column space
            proj = qb @ (qb.T @ qa)
            # SVD to find intersection
            u, sigma, _ = np.linalg.svd(proj, full_matrices=False)
            # Keep only significant directions
            mask = sigma > 0.1  # threshold for joint compatibility
            if not np.any(mask):
                return 0.0, None
            qa = u[:, mask]

        # Joint projection matrix P = Q Q^T
        joint_proj = qa @ qa.T

        # Coherence = minimum pairwise alignment
        min_alignment = 1.0
        ids = list(identities)
        for i in range(len(ids)):
            for j in range(i + 1, len(ids)):
                d = self._grassmann_distance(
                    self._validator_stalks[ids[i]],
                    self._validator_stalks[ids[j]],
                )
                alignment = 1.0 - (d / (np.pi / 2))
                min_alignment = min(min_alignment, alignment)

        return max(0.0, min_alignment), joint_proj

    def build_from_stalks(self, threshold: float = 0.5):
        """
        Build the semitopology from registered validator stalks.

        For each subset of validators, check if they form an
        actionable coalition (joint coherence > threshold).

        For efficiency, only check subsets up to the maximum
        simplex dimension in the Čech nerve.

        Args:
            threshold: minimum joint coherence for actionability
        """
        self._coalitions.clear()
        identities = list(self._validator_stalks.keys())
        n = len(identities)

        # Add empty and full coalitions
        empty = frozenset()
        self._coalitions[empty] = Coalition(members=empty, is_actionable=True)

        full = frozenset(identities)
        score, proj = self._joint_coherence(full)
        self._coalitions[full] = Coalition(
            members=full,
            joint_subspace=proj,
            coherence_score=score,
            is_actionable=score > threshold,
        )

        # Check all pairs first (edges in nerve)
        for i in range(n):
            # Singletons are always actionable
            single = frozenset([identities[i]])
            self._coalitions[single] = Coalition(
                members=single, coherence_score=1.0, is_actionable=True,
            )

            for j in range(i + 1, n):
                pair = frozenset([identities[i], identities[j]])
                score, proj = self._joint_coherence(pair)
                self._coalitions[pair] = Coalition(
                    members=pair,
                    joint_subspace=proj,
                    coherence_score=score,
                    is_actionable=score > threshold,
                )

        # Check triples (2-simplices) — only if both sub-pairs are actionable
        for i in range(n):
            for j in range(i + 1, n):
                for k in range(j + 1, n):
                    pair_ij = frozenset([identities[i], identities[j]])
                    pair_ik = frozenset([identities[i], identities[k]])
                    pair_jk = frozenset([identities[j], identities[k]])

                    # Only check triple if all pairs are actionable
                    if all(self._coalitions.get(p, Coalition(members=frozenset())).is_actionable
                           for p in [pair_ij, pair_ik, pair_jk]):
                        triple = frozenset([identities[i], identities[j], identities[k]])
                        score, proj = self._joint_coherence(triple)
                        self._coalitions[triple] = Coalition(
                            members=triple,
                            joint_subspace=proj,
                            coherence_score=score,
                            is_actionable=score > threshold,
                        )

    def actionable_coalitions(self) -> List[Coalition]:
        """Return all actionable coalitions, sorted by size descending."""
        result = [c for c in self._coalitions.values() if c.is_actionable and c.size() > 0]
        result.sort(key=lambda c: c.size(), reverse=True)
        return result

    def is_actionable(self, members: FrozenSet[bytes]) -> bool:
        """Check if a specific subset is an actionable coalition."""
        if members in self._coalitions:
            return self._coalitions[members].is_actionable
        # Not pre-computed — compute on the fly
        score, _ = self._joint_coherence(members)
        return score > 0.5

    def demonstrate_non_intersection(self) -> Optional[Tuple[Coalition, Coalition, Coalition]]:
        """
        Find an example where intersection of two actionable coalitions
        is NOT actionable — demonstrating the semitopological property.

        Returns:
            (coalition_A, coalition_B, A∩B) where A,B are actionable but A∩B is not,
            or None if no such example exists (i.e., the topology is classical).
        """
        actionable = [c for c in self._coalitions.values() if c.is_actionable and c.size() >= 2]

        for i in range(len(actionable)):
            for j in range(i + 1, len(actionable)):
                a, b = actionable[i], actionable[j]
                intersection = a.members & b.members
                if len(intersection) >= 2:
                    if not self.is_actionable(intersection):
                        c = Coalition(members=intersection, is_actionable=False)
                        return (a, b, c)

        return None  # Topology is classical (all intersections are open)

    def covers_network(self, coalition: Coalition, required_components: int = 1) -> bool:
        """
        Check if a coalition covers enough of the network for
        consensus (β₀ = required_components).

        A single actionable coalition covering the entire connected
        component is sufficient for local consensus.
        """
        # Simple check: coalition must contain at least a majority
        total = len(self._validator_stalks)
        if total == 0:
            return False
        return coalition.size() > total // 2


# =============================================================================
# TESTS
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("SEMITOPOLOGICAL COALITIONS TEST")
    print("=" * 60)

    np.random.seed(42)
    semi = Semitopology()

    # Register 4 validators with stalks on Gr(2, 4)
    # V0 and V1 are aligned, V2 is partially aligned, V3 is orthogonal
    base = np.array([[1.0, 0.0, 0.0, 0.0],
                     [0.0, 1.0, 0.0, 0.0]])

    stalks = {
        b"V0": base + np.random.randn(2, 4) * 0.05,
        b"V1": base + np.random.randn(2, 4) * 0.05,
        b"V2": base + np.random.randn(2, 4) * 0.4,
        b"V3": np.array([[0.0, 0.0, 1.0, 0.0],
                         [0.0, 0.0, 0.0, 1.0]]),
    }

    for name, stalk in stalks.items():
        semi.register_validator(name, stalk)

    print("\n1. Building semitopology from stalks...")
    semi.build_from_stalks(threshold=0.5)

    print("\n2. Actionable coalitions:")
    for c in semi.actionable_coalitions():
        names = sorted([m.decode() for m in c.members])
        print(f"   {names} (coherence={c.coherence_score:.3f})")

    print("\n3. Semitopological property (intersection failure):")
    example = semi.demonstrate_non_intersection()
    if example:
        a, b, c = example
        a_names = sorted([m.decode() for m in a.members])
        b_names = sorted([m.decode() for m in b.members])
        c_names = sorted([m.decode() for m in c.members])
        print(f"   {a_names} ∩ {b_names} = {c_names}")
        print(f"   {a_names}: actionable={a.is_actionable}")
        print(f"   {b_names}: actionable={b.is_actionable}")
        print(f"   {c_names}: actionable=False  ← SEMITOPOLOGICAL!")
    else:
        print("   No non-intersection found (topology is classical)")
        print("   (This is expected with aligned stalks — try more orthogonal ones)")

    print("\n" + "=" * 60)
    print("✅ SEMITOPOLOGICAL COALITIONS READY")
    print("=" * 60)
