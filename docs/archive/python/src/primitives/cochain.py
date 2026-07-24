"""
Cochain Primitives - Foundation for Homotopical Crypto

This module defines the cochain types that underlie ALL cryptographic
primitives in the system. Both Dict-based (named cells) and flat vector
(for linear algebra) representations.

From HOMOTOPICAL_PRIMITIVES.md:
- Everything built from cochain complex C^0 → C^1 → C^2
- Coboundary δ: C^k → C^{k+1} is the fundamental operator
- Harmonic cochains ker(Δ) = H^k are where messages live

Aligned with chloe_protocol/geometry/sheaf.py pattern:
- get_0_cochain(): Dict[Tuple, stalk_data]
- coboundary_0(): Dict cochains → Dict cochains
- flatten/unflatten: Dict ↔ np.ndarray
"""

from dataclasses import dataclass, field
from typing import Dict, Tuple, List, Optional, Union, Any
import numpy as np


# =============================================================================
# COCHAIN TYPES (by-construction valid)
# =============================================================================

@dataclass(frozen=True)
class CellIndex:
    """
    Index for a cell in the complex.
    
    Dimension k cell: tuple of k+1 vertex indices.
    - 0-cell (vertex): (v,)
    - 1-cell (edge): (v0, v1)
    - 2-cell (face): (v0, v1, v2)
    """
    indices: Tuple[int, ...]
    
    @property
    def dimension(self) -> int:
        """Dimension of this cell."""
        return len(self.indices) - 1
    
    def __hash__(self):
        return hash(self.indices)
    
    def __eq__(self, other):
        if isinstance(other, CellIndex):
            return self.indices == other.indices
        if isinstance(other, tuple):
            return self.indices == other
        return False


@dataclass
class Cochain:
    """
    A k-cochain: function from k-cells to stalk values.
    
    This is the fundamental object in homotopical crypto:
    - Messages encode as 0-cochains on vertices
    - Coboundary pushes to edges: δc ∈ C^1
    - Harmonic cochains H^k = ker(Δ) hold the semantic content
    
    Two representations:
    - dict_values: Dict[cell_index, np.ndarray] (named access)
    - flat_values: np.ndarray (for Laplacian operations)
    """
    dimension: int
    dict_values: Dict[Tuple[int, ...], np.ndarray] = field(default_factory=dict)
    stalk_dim: int = 1  # Default scalar stalks
    
    # Computed from dict_values when needed
    _flat_cache: Optional[np.ndarray] = field(default=None, repr=False)
    _cell_order: Optional[List[Tuple[int, ...]]] = field(default=None, repr=False)
    
    def __post_init__(self):
        """Validate cochain structure."""
        for cell, value in self.dict_values.items():
            if len(cell) != self.dimension + 1:
                raise ValueError(
                    f"Cell {cell} has wrong dimension for {self.dimension}-cochain"
                )
    
    @classmethod
    def zeros(cls, cells: List[Tuple[int, ...]], stalk_dim: int = 1) -> 'Cochain':
        """Create zero cochain on given cells."""
        if not cells:
            return cls(dimension=0, dict_values={}, stalk_dim=stalk_dim)
        
        dim = len(cells[0]) - 1
        dict_values = {cell: np.zeros(stalk_dim) for cell in cells}
        return cls(dimension=dim, dict_values=dict_values, stalk_dim=stalk_dim)
    
    @classmethod
    def from_flat(
        cls, 
        flat: np.ndarray, 
        cell_order: List[Tuple[int, ...]], 
        stalk_dim: int = 1
    ) -> 'Cochain':
        """Create cochain from flat vector."""
        if not cell_order:
            return cls(dimension=0, dict_values={}, stalk_dim=stalk_dim)
        
        dim = len(cell_order[0]) - 1
        dict_values = {}
        
        for i, cell in enumerate(cell_order):
            start = i * stalk_dim
            end = start + stalk_dim
            dict_values[cell] = flat[start:end].copy()
        
        cochain = cls(dimension=dim, dict_values=dict_values, stalk_dim=stalk_dim)
        cochain._flat_cache = flat.copy()
        cochain._cell_order = cell_order
        return cochain
    
    def to_flat(self, cell_order: Optional[List[Tuple[int, ...]]] = None) -> np.ndarray:
        """
        Flatten to vector for Laplacian operations.
        
        Args:
            cell_order: Order of cells (if None, uses sorted keys)
        
        Returns:
            Flat np.ndarray of shape (n_cells * stalk_dim,)
        """
        if cell_order is None:
            cell_order = sorted(self.dict_values.keys())
        
        self._cell_order = cell_order
        
        if not cell_order:
            return np.array([])
        
        components = [self.dict_values.get(cell, np.zeros(self.stalk_dim)) 
                     for cell in cell_order]
        
        self._flat_cache = np.concatenate(components)
        return self._flat_cache
    
    def __getitem__(self, cell: Tuple[int, ...]) -> np.ndarray:
        """Get stalk value at cell."""
        return self.dict_values.get(cell, np.zeros(self.stalk_dim))
    
    def __setitem__(self, cell: Tuple[int, ...], value: np.ndarray):
        """Set stalk value at cell."""
        if len(cell) != self.dimension + 1:
            raise ValueError(f"Cell {cell} has wrong dimension")
        self.dict_values[cell] = np.asarray(value)
        self._flat_cache = None  # Invalidate cache
    
    @property
    def cells(self) -> List[Tuple[int, ...]]:
        """All cells in this cochain."""
        return list(self.dict_values.keys())
    
    @property
    def n_cells(self) -> int:
        """Number of cells."""
        return len(self.dict_values)
    
    def norm(self) -> float:
        """L2 norm of cochain."""
        flat = self.to_flat()
        return float(np.linalg.norm(flat))
    
    def __add__(self, other: 'Cochain') -> 'Cochain':
        """Cochain addition."""
        if self.dimension != other.dimension:
            raise ValueError("Cannot add cochains of different dimensions")
        
        result = Cochain(
            dimension=self.dimension,
            dict_values={},
            stalk_dim=self.stalk_dim
        )
        
        all_cells = set(self.dict_values.keys()) | set(other.dict_values.keys())
        for cell in all_cells:
            result.dict_values[cell] = self[cell] + other[cell]
        
        return result
    
    def __sub__(self, other: 'Cochain') -> 'Cochain':
        """Cochain subtraction."""
        if self.dimension != other.dimension:
            raise ValueError("Cannot subtract cochains of different dimensions")
        
        result = Cochain(
            dimension=self.dimension,
            dict_values={},
            stalk_dim=self.stalk_dim
        )
        
        all_cells = set(self.dict_values.keys()) | set(other.dict_values.keys())
        for cell in all_cells:
            result.dict_values[cell] = self[cell] - other[cell]
        
        return result
    
    def __mul__(self, scalar: float) -> 'Cochain':
        """Scalar multiplication."""
        result = Cochain(
            dimension=self.dimension,
            dict_values={cell: scalar * val for cell, val in self.dict_values.items()},
            stalk_dim=self.stalk_dim
        )
        return result
    
    def __rmul__(self, scalar: float) -> 'Cochain':
        return self.__mul__(scalar)


# =============================================================================
# 0-COCHAIN (VERTEX DATA) - Messages live here
# =============================================================================

@dataclass
class VertexCochain(Cochain):
    """
    0-cochain: data on vertices.
    
    In homotopical crypto:
    - Message placed at vertex 0
    - Other vertices get randomness
    - Coboundary δ maps to edges
    """
    
    def __init__(
        self, 
        vertex_values: Dict[int, np.ndarray],
        stalk_dim: int = 1
    ):
        """
        Create 0-cochain from vertex → value mapping.
        
        Args:
            vertex_values: {vertex_id: stalk_value}
            stalk_dim: Dimension of each stalk
        """
        dict_values = {(v,): val for v, val in vertex_values.items()}
        super().__init__(dimension=0, dict_values=dict_values, stalk_dim=stalk_dim)
    
    @classmethod
    def from_message(
        cls,
        message: np.ndarray,
        n_vertices: int,
        randomness: Optional[np.ndarray] = None,
        q: int = 12289
    ) -> 'VertexCochain':
        """
        Create 0-cochain encoding a message.
        
        Message goes at vertex 0, randomness at others.
        This is the setup for cochain commitment.
        
        Args:
            message: Message vector in ℤ_q
            n_vertices: Number of vertices
            randomness: Optional randomness for other vertices
            q: Modulus
        """
        stalk_dim = len(message)
        
        if randomness is None:
            randomness = np.random.randint(0, q, size=(n_vertices - 1, stalk_dim))
        
        vertex_values = {0: message % q}
        for i in range(1, n_vertices):
            vertex_values[i] = randomness[i-1] % q
        
        return cls(vertex_values=vertex_values, stalk_dim=stalk_dim)
    
    def get_vertex(self, v: int) -> np.ndarray:
        """Get value at vertex v."""
        return self[(v,)]


# =============================================================================
# 1-COCHAIN (EDGE DATA) - Differences/disagreements
# =============================================================================

@dataclass
class EdgeCochain(Cochain):
    """
    1-cochain: data on edges.
    
    Result of coboundary δ: C^0 → C^1.
    Measures disagreement between adjacent vertices.
    """
    
    def __init__(
        self,
        edge_values: Dict[Tuple[int, int], np.ndarray],
        stalk_dim: int = 1
    ):
        """
        Create 1-cochain from edge → value mapping.
        
        Args:
            edge_values: {(v0, v1): stalk_value}
            stalk_dim: Dimension of each stalk
        """
        dict_values = {tuple(sorted(e)): val for e, val in edge_values.items()}
        super().__init__(dimension=1, dict_values=dict_values, stalk_dim=stalk_dim)
    
    def get_edge(self, v0: int, v1: int) -> np.ndarray:
        """Get value at edge (v0, v1)."""
        edge = tuple(sorted((v0, v1)))
        return self[edge]


# =============================================================================
# COCHAIN COMPLEX (collection of cochains with coboundary structure)
# =============================================================================

@dataclass
class CochainComplex:
    """
    Cochain complex C^0 → C^1 → C^2 with coboundary maps.
    
    Stores:
    - Cells at each dimension
    - Coboundary matrices δ^k: C^k → C^{k+1}
    
    This is the algebraic structure underlying the crypto.
    """
    vertices: List[int]
    edges: List[Tuple[int, int]]
    faces: List[Tuple[int, int, int]] = field(default_factory=list)
    stalk_dim: int = 1
    
    _coboundary_0: Optional[np.ndarray] = field(default=None, repr=False)
    _coboundary_1: Optional[np.ndarray] = field(default=None, repr=False)
    
    @classmethod
    def from_graph(
        cls, 
        n_vertices: int, 
        edges: List[Tuple[int, int]],
        stalk_dim: int = 1
    ) -> 'CochainComplex':
        """Create complex from graph."""
        vertices = list(range(n_vertices))
        sorted_edges = [tuple(sorted(e)) for e in edges]
        return cls(vertices=vertices, edges=sorted_edges, stalk_dim=stalk_dim)
    
    @classmethod
    def complete_graph(cls, n: int, stalk_dim: int = 1) -> 'CochainComplex':
        """Create complex from complete graph K_n."""
        vertices = list(range(n))
        edges = [(i, j) for i in range(n) for j in range(i+1, n)]
        # Add all triangles for complete graph
        faces = [(i, j, k) for i in range(n) for j in range(i+1, n) for k in range(j+1, n)]
        return cls(vertices=vertices, edges=edges, faces=faces, stalk_dim=stalk_dim)
    
    @property
    def n_vertices(self) -> int:
        return len(self.vertices)
    
    @property
    def n_edges(self) -> int:
        return len(self.edges)
    
    def coboundary_matrix_0(self) -> np.ndarray:
        """
        Compute coboundary matrix δ^0: C^0 → C^1.
        
        For edge e = (u, v): (δ^0 c)(e) = c(v) - c(u)
        
        Matrix is (n_edges * stalk_dim) × (n_vertices * stalk_dim).
        """
        if self._coboundary_0 is not None:
            return self._coboundary_0
        
        n_v = self.n_vertices
        n_e = self.n_edges
        d = self.stalk_dim
        
        delta = np.zeros((n_e * d, n_v * d))
        
        for i, (u, v) in enumerate(self.edges):
            # (δc)(e) = c(v) - c(u)
            for k in range(d):
                delta[i * d + k, u * d + k] = -1
                delta[i * d + k, v * d + k] = +1
        
        self._coboundary_0 = delta
        return delta
    
    def apply_coboundary_0(self, c0: VertexCochain) -> EdgeCochain:
        """
        Apply coboundary δ^0 to 0-cochain.
        
        Returns 1-cochain of edge differences.
        """
        delta = self.coboundary_matrix_0()
        
        # Flatten input
        vertex_order = [(v,) for v in self.vertices]
        flat_c0 = c0.to_flat(vertex_order)
        
        # Apply coboundary
        flat_c1 = delta @ flat_c0
        
        # Unflatten to edge cochain
        edge_values = {}
        d = self.stalk_dim
        for i, e in enumerate(self.edges):
            edge_values[e] = flat_c1[i * d : (i + 1) * d]
        
        return EdgeCochain(edge_values=edge_values, stalk_dim=self.stalk_dim)
    
    def laplacian_0(self) -> np.ndarray:
        """
        Compute 0-Laplacian Δ^0 = δ^0* δ^0.
        
        This is the fundamental operator:
        - ker(Δ^0) = harmonic 0-cochains
        - Message recovery via projection to ker(Δ^0)
        """
        delta = self.coboundary_matrix_0()
        return delta.T @ delta
    
    def zero_cochain(self) -> VertexCochain:
        """Create zero 0-cochain on this complex."""
        return VertexCochain(
            vertex_values={v: np.zeros(self.stalk_dim) for v in self.vertices},
            stalk_dim=self.stalk_dim
        )
    
    def random_cochain(self, q: int = 12289) -> VertexCochain:
        """Create random 0-cochain mod q."""
        return VertexCochain(
            vertex_values={v: np.random.randint(0, q, self.stalk_dim) 
                          for v in self.vertices},
            stalk_dim=self.stalk_dim
        )


# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

def inner_product(c1: Cochain, c2: Cochain) -> float:
    """
    Inner product ⟨c1, c2⟩ = Σ_σ ⟨c1(σ), c2(σ)⟩.
    """
    if c1.dimension != c2.dimension:
        raise ValueError("Cochains must have same dimension")
    
    total = 0.0
    all_cells = set(c1.dict_values.keys()) | set(c2.dict_values.keys())
    
    for cell in all_cells:
        total += float(np.dot(c1[cell], c2[cell]))
    
    return total


def cochain_mod(c: Cochain, q: int) -> Cochain:
    """Reduce cochain mod q."""
    return Cochain(
        dimension=c.dimension,
        dict_values={cell: val % q for cell, val in c.dict_values.items()},
        stalk_dim=c.stalk_dim
    )
