"""
Fiber Bundle with Parallel Transport

A fiber bundle (E, B, π, F) with connection enables parallel transport.
For cryptography, this provides key distribution and secure message passing.

RELATIONSHIP TO STALKS:
- Stalk (primitives/stalk.py) = the DATA that lives in a fiber
- FiberBundle = the GEOMETRY of how fibers are connected
- StalkSpec.dimension = FiberBundle.fiber_dim
- Parallel transport moves Stalks along paths
"""

from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Optional, Callable, TYPE_CHECKING
import numpy as np

if TYPE_CHECKING:
    from ..primitives.stalk import Stalk, StalkSpec


@dataclass
class FiberBundle:
    """
    Fiber bundle over a base space.
    
    - base_space: The Čech nerve (topology)
    - fiber_dim: Dimension of each fiber F
    - connection: Parallel transport maps along edges
    """
    base_space: Dict[int, List[Tuple]]  # Nerve
    fiber_dim: int = 256
    connection: Dict[Tuple[int, int], np.ndarray] = field(default_factory=dict)
    
    @classmethod
    def random(cls, nerve: Dict[int, List[Tuple]], fiber_dim: int = 256) -> 'FiberBundle':
        """Generate random fiber bundle with random connection."""
        connection = {}
        edges = nerve.get(1, [])
        
        for edge in edges:
            # Random orthogonal matrix (preserves norms)
            A = np.random.randn(fiber_dim, fiber_dim)
            Q, _ = np.linalg.qr(A)
            connection[edge] = Q
        
        return cls(base_space=nerve, fiber_dim=fiber_dim, connection=connection)
    
    def parallel_transport(
        self,
        vector: np.ndarray,
        path: List[int]
    ) -> np.ndarray:
        """Transport vector along path."""
        current = vector.copy()
        
        for i in range(len(path) - 1):
            edge = tuple(sorted([path[i], path[i+1]]))
            if edge in self.connection:
                current = self.connection[edge] @ current
        
        return current
    
    def holonomy(self, loop: List[int]) -> np.ndarray:
        """Compute holonomy around a loop."""
        if loop[0] != loop[-1]:
            raise ValueError("Loop must be closed")
        
        result = np.eye(self.fiber_dim)
        for i in range(len(loop) - 1):
            edge = tuple(sorted([loop[i], loop[i+1]]))
            if edge in self.connection:
                result = self.connection[edge] @ result
        
        return result
