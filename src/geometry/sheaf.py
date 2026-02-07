"""
Cellular Sheaf over Čech Nerve

A cellular sheaf assigns vector spaces (stalks) to cells of a simplicial
complex and linear maps (restriction maps) between them.

Local-to-global coherence:

  The restriction maps R_{v→e} are context projections between stalk
  types (see primitives/stalk.py: StalkProjection := R_{v→e}).

  The coboundary δ(c)_e = R_j·c_j - R_i·c_i measures how much two
  vertices disagree when projected to their shared edge context.

  ker(Δ) = global sections = cochains consistent across all
  restriction maps. Messages embed here; noise lives in its
  orthogonal complement im(δ)⊕im(δ*).

  For cryptography:
  - Vertices := parties/accounts
  - Edges := connections between parties
  - Stalks := local state spaces (private: dim 256, public: dim 1)
  - Restriction maps := context projections (StalkProjection)

Reference: Hansen & Ghrist (2019), arXiv:1808.01513
"""

from dataclasses import dataclass, field
from typing import Any, Dict, Callable, List, Tuple, Optional
import numpy as np


@dataclass
class CellularSheaf:
    """
    Cellular sheaf over a Čech nerve.
    
    The sheaf assigns:
    - To each vertex v: a stalk F(v) (vector space)
    - To each edge e=(v,w): restriction maps ρ_v→e, ρ_w→e
    """
    nerve: Dict[int, List[Tuple]]
    stalks: Dict[Tuple, np.ndarray] = field(default_factory=dict)
    restrictions: Dict[Tuple[Tuple, Tuple], np.ndarray] = field(default_factory=dict)
    
    def set_stalk(self, cell: Tuple, data: np.ndarray):
        """Set stalk data for a cell."""
        self.stalks[cell] = np.asarray(data)
    
    def get_stalk(self, cell: Tuple) -> Optional[np.ndarray]:
        """Get stalk data for a cell."""
        return self.stalks.get(cell)
    
    def set_restriction(self, from_cell: Tuple, to_cell: Tuple, matrix: np.ndarray):
        """Set restriction map from face to cell."""
        self.restrictions[(from_cell, to_cell)] = np.asarray(matrix)
    
    def get_restriction(self, from_cell: Tuple, to_cell: Tuple) -> Optional[np.ndarray]:
        """Get restriction map."""
        return self.restrictions.get((from_cell, to_cell))
    
    def get_cochain_space_dim(self, degree: int) -> int:
        """Get total dimension of C^degree cochain space."""
        cells = self.nerve.get(degree, [])
        total_dim = 0
        for cell in cells:
            stalk = self.get_stalk(cell)
            if stalk is not None:
                total_dim += len(stalk) if stalk.ndim == 1 else stalk.shape[0]
        return total_dim
    
    def coboundary_0(
        self,
        cochain_0: Dict[Tuple, np.ndarray]
    ) -> Dict[Tuple, np.ndarray]:
        """
        Compute coboundary δ₀: C⁰ → C¹.
        
        For edge e = (i, j), the coboundary is:
        δ(c)_e = R_{j→e} · c_j - R_{i→e} · c_i
        
        where R are the restriction maps.
        
        Args:
            cochain_0: Dict mapping vertices (i,) to vectors
            
        Returns:
            cochain_1: Dict mapping edges (i,j) to vectors
        """
        cochain_1 = {}
        edges = self.nerve.get(1, [])
        
        for edge in edges:
            i, j = edge
            vi, vj = (i,), (j,)
            
            # Get vertex data
            ci = cochain_0.get(vi, np.zeros(1))
            cj = cochain_0.get(vj, np.zeros(1))
            
            # Get restriction maps (default to identity)
            Ri = self.get_restriction(vi, edge)
            Rj = self.get_restriction(vj, edge)
            
            if Ri is None:
                Ri = np.eye(len(ci))
            if Rj is None:
                Rj = np.eye(len(cj))
            
            # Coboundary: δ(c)_e = R_j c_j - R_i c_i
            cochain_1[edge] = Rj @ cj - Ri @ ci
        
        return cochain_1
    
    def adjoint_coboundary_0(
        self,
        cochain_1: Dict[Tuple, np.ndarray]
    ) -> Dict[Tuple, np.ndarray]:
        """
        Compute adjoint δ₀*: C¹ → C⁰.
        
        This is the "divergence" - sum of incoming edge data.
        """
        cochain_0 = {}
        vertices = self.nerve.get(0, [])
        edges = self.nerve.get(1, [])
        
        # Initialize
        for v in vertices:
            stalk = self.get_stalk(v)
            dim = len(stalk) if stalk is not None else 1
            cochain_0[v] = np.zeros(dim)
        
        # Accumulate from edges
        for edge in edges:
            i, j = edge
            vi, vj = (i,), (j,)
            
            edge_data = cochain_1.get(edge, np.zeros(1))
            
            Ri = self.get_restriction(vi, edge)
            Rj = self.get_restriction(vj, edge)
            
            if Ri is None:
                Ri = np.eye(len(edge_data))
            if Rj is None:
                Rj = np.eye(len(edge_data))
            
            # Adjoint contribution
            cochain_0[vi] = cochain_0[vi] - Ri.T @ edge_data
            cochain_0[vj] = cochain_0[vj] + Rj.T @ edge_data
        
        return cochain_0


def build_cech_nerve(
    parties: List[str],
    connections: List[Tuple[str, str]]
) -> Dict[int, List[Tuple]]:
    """
    Build Čech nerve from parties and their connections.
    
    Args:
        parties: List of party names
        connections: List of (party_a, party_b) connections
        
    Returns:
        Nerve dict: {0: [vertices], 1: [edges], 2: [triangles]}
    """
    party_idx = {p: i for i, p in enumerate(parties)}
    nerve: Dict[int, List[Tuple]] = {0: [], 1: [], 2: []}
    
    # 0-cells: vertices
    nerve[0] = [(i,) for i in range(len(parties))]
    
    # 1-cells: edges
    edges_set = set()
    for a, b in connections:
        if a in party_idx and b in party_idx:
            i, j = party_idx[a], party_idx[b]
            edge = tuple(sorted([i, j]))
            if edge not in edges_set:
                edges_set.add(edge)
                nerve[1].append(edge)
    
    # 2-cells: triangles
    n = len(parties)
    for i in range(n):
        for j in range(i + 1, n):
            for k in range(j + 1, n):
                if ((i, j) in edges_set and (i, k) in edges_set and (j, k) in edges_set):
                    nerve[2].append((i, j, k))
    
    return nerve


def build_cech_nerve_from_contexts(agent_contexts: Dict[str, set]) -> Dict[int, List[Tuple]]:
    """Build Čech nerve from overlapping contexts."""
    from itertools import combinations
    
    agents = sorted(list(agent_contexts.keys()))
    agent_map = {agent: i for i, agent in enumerate(agents)}
    nerve: Dict[int, List[Tuple]] = {0: [], 1: [], 2: []}
    
    nerve[0] = [(agent_map[a],) for a in agents]
    
    for a1, a2 in combinations(agents, 2):
        if agent_contexts[a1].intersection(agent_contexts[a2]):
            nerve[1].append(tuple(sorted([agent_map[a1], agent_map[a2]])))
    
    for a1, a2, a3 in combinations(agents, 3):
        triple = agent_contexts[a1].intersection(agent_contexts[a2]).intersection(agent_contexts[a3])
        if triple:
            nerve[2].append(tuple(sorted([agent_map[a1], agent_map[a2], agent_map[a3]])))
    
    return nerve
