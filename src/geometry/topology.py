"""
Topology: Simplicial complexes, Betti numbers, persistence.

Based on Hansen & Ghrist and standard TDA.
"""

from dataclasses import dataclass
from typing import Dict, List, Tuple
from abc import ABC, abstractmethod
import numpy as np


@dataclass
class PersistenceDiagram:
    """Persistence diagram: (birth, death) pairs."""
    dimension: int
    points: np.ndarray  # Shape (n, 2)
    
    def persistence_entropy(self) -> float:
        if len(self.points) == 0:
            return 0.0
        persistence = self.points[:, 1] - self.points[:, 0]
        persistence = persistence[np.isfinite(persistence)]
        if len(persistence) == 0 or np.sum(persistence) == 0:
            return 0.0
        p = persistence / np.sum(persistence)
        return float(-np.sum(p * np.log(p + 1e-10)))


class SimplicialComplex(ABC):
    """Abstract simplicial complex interface."""
    
    @abstractmethod
    def get_cells(self, dimension: int) -> List[Tuple]:
        pass
    
    @abstractmethod
    def n_cells(self, dimension: int) -> int:
        pass
    
    def compute_betti_numbers(self) -> Dict[int, int]:
        """Compute Betti numbers β_k."""
        vertices = self.get_cells(0)
        edges = self.get_cells(1)
        triangles = self.get_cells(2)
        
        n0, n1, n2 = len(vertices), len(edges), len(triangles)
        beta_0 = self._count_components()
        beta_2 = max(0, n2 - n1 + n0 - beta_0)
        beta_1 = n1 - n0 + beta_0 - beta_2
        
        return {0: beta_0, 1: max(0, beta_1), 2: max(0, beta_2)}
    
    def _count_components(self) -> int:
        """Count connected components via DFS."""
        vertices = self.get_cells(0)
        edges = self.get_cells(1)
        if not vertices:
            return 0
        
        adjacency = {v[0]: set() for v in vertices}
        for edge in edges:
            i, j = edge
            adjacency.setdefault(i, set()).add(j)
            adjacency.setdefault(j, set()).add(i)
        
        visited = set()
        components = 0
        
        def dfs(node):
            visited.add(node)
            for neighbor in adjacency.get(node, []):
                if neighbor not in visited:
                    dfs(neighbor)
        
        for v in adjacency:
            if v not in visited:
                dfs(v)
                components += 1
        
        return components


class CechComplex(SimplicialComplex):
    """Čech complex from nerve dict."""
    
    def __init__(self, nerve: Dict[int, List[Tuple]]):
        self.nerve = nerve
    
    def get_cells(self, dimension: int) -> List[Tuple]:
        return self.nerve.get(dimension, [])
    
    def n_cells(self, dimension: int) -> int:
        return len(self.get_cells(dimension))


def compute_betti_numbers(complex: SimplicialComplex) -> Dict[int, int]:
    """Compute Betti numbers for any complex."""
    return complex.compute_betti_numbers()
