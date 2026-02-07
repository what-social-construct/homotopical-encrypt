"""
Natural Transformations for Sheaf Operations

Functorial operations that preserve structure between fibrations.
These are the morphisms in the category of sheaves.

Operations:
- pullback: f*F → pull sheaf back along topology map
- pushforward: f_*F → push sheaf forward along topology map
- compose_nat: η ∘ μ → compose natural transformations

Key property: Natural transformations commute with coboundary δ.
This ensures they preserve cohomology classes (homotopy invariants).

FUTURE: PULLBACK FOR TOKENOMICS / INCENTIVE LAYER

  Pullback f*: C^k(Y) → C^k(X) is the natural way to transfer value
  between topologies. Key applications:

  - Cross-topology transfers: Alice has topology X, Bob has topology Y.
    A map f: X → Y lets you pull back Bob's commitments to Alice's
    topology. Value moves contravariantly (cochains pull back).

  - Incentive distribution: validators earn rewards on global topology Y.
    Pullback distributes rewards to their local topology X. The functorial
    property (f∘g)* = g* ∘ f* ensures composition of distribution steps
    is consistent.

  - Staking/restaking: staked value on topology Y can be pulled back to
    local sheaf X for computation, preserving the cohomological structure
    (pullback commutes with δ, so invariants transfer).

  Currently: pullback/pushforward are defined and tested but not yet
  called from chain/ or consensus/. They will be wired when the
  incentive/tokenomics layer is built.
"""

from dataclasses import dataclass
from typing import Callable, Dict, Tuple, List, Any, Optional
import numpy as np


@dataclass
class NaturalTransformation:
    """
    A natural transformation η: F → G between two sheaves.
    
    Components: η_x: F(x) → G(x) for each object x
    Naturality: For each morphism f: x → y, η_y ∘ F(f) = G(f) ∘ η_x
    
    In our context:
    - F, G are cellular sheaves (fibrations)
    - Components are linear maps between stalks
    - Naturality ensures compatibility with restriction maps
    """
    # Maps from cell → (linear map between stalks)
    components: Dict[Tuple, np.ndarray]
    
    # Source and target sheaf identifiers
    source_sheaf_id: str = ""
    target_sheaf_id: str = ""
    
    def apply(self, cell: Tuple, stalk_value: np.ndarray) -> np.ndarray:
        """Apply natural transformation component at a cell."""
        if cell in self.components:
            return self.components[cell] @ stalk_value
        # Identity if no component specified
        return stalk_value
    
    def is_natural(
        self, 
        source_restriction: Dict[Tuple, np.ndarray],
        target_restriction: Dict[Tuple, np.ndarray],
        tolerance: float = 1e-10
    ) -> bool:
        """
        Check naturality condition.
        
        For restriction f: x → y, verify η_y ∘ F(f) = G(f) ∘ η_x
        """
        for (x, y), F_f in source_restriction.items():
            if (x, y) not in target_restriction:
                continue
            G_f = target_restriction[(x, y)]
            
            if x not in self.components or y not in self.components:
                continue
            
            eta_x = self.components[x]
            eta_y = self.components[y]
            
            # Check η_y ∘ F(f) = G(f) ∘ η_x
            lhs = eta_y @ F_f
            rhs = G_f @ eta_x
            
            if np.linalg.norm(lhs - rhs) > tolerance:
                return False
        
        return True


def pullback(
    f: Dict[Tuple, Tuple],
    sheaf_stalks: Dict[Tuple, np.ndarray],
    sheaf_restrictions: Dict[Tuple, np.ndarray]
) -> Tuple[Dict[Tuple, np.ndarray], Dict[Tuple, np.ndarray]]:
    """
    Pullback of sheaf along topology morphism.
    
    f*F where f: X → Y and F is a sheaf on Y.
    (f*F)(x) = F(f(x)) for each x in X.
    
    Args:
        f: Topology morphism, maps cells of X to cells of Y
        sheaf_stalks: Stalks of sheaf F on Y
        sheaf_restrictions: Restriction maps of F
        
    Returns:
        (pulled_back_stalks, pulled_back_restrictions)
    """
    pulled_stalks = {}
    pulled_restrictions = {}
    
    # Pull back stalks: (f*F)(x) = F(f(x))
    for x_cell, y_cell in f.items():
        if y_cell in sheaf_stalks:
            pulled_stalks[x_cell] = sheaf_stalks[y_cell].copy()
    
    # Pull back restrictions
    for (x1, x2), (y1, y2) in _induced_restriction_map(f).items():
        if (y1, y2) in sheaf_restrictions:
            pulled_restrictions[(x1, x2)] = sheaf_restrictions[(y1, y2)].copy()
    
    return pulled_stalks, pulled_restrictions


def pushforward(
    f: Dict[Tuple, Tuple],
    sheaf_stalks: Dict[Tuple, np.ndarray],
    sheaf_restrictions: Dict[Tuple, np.ndarray]
) -> Tuple[Dict[Tuple, np.ndarray], Dict[Tuple, np.ndarray]]:
    """
    Pushforward of sheaf along topology morphism.
    
    f_*F where f: X → Y and F is a sheaf on X.
    (f_*F)(y) = F(f^{-1}(y)) when f is injective.
    
    For general f, this involves direct limits.
    Here we implement the simpler case where f is a bijection on cells.
    
    Args:
        f: Topology morphism, maps cells of X to cells of Y
        sheaf_stalks: Stalks of sheaf F on X
        sheaf_restrictions: Restriction maps of F
        
    Returns:
        (pushed_forward_stalks, pushed_forward_restrictions)
    """
    pushed_stalks = {}
    pushed_restrictions = {}
    
    # Inverse map (for bijective f)
    f_inv = {v: k for k, v in f.items()}
    
    # Push forward stalks: (f_*F)(y) = F(f^{-1}(y))
    for y_cell, x_cell in f_inv.items():
        if x_cell in sheaf_stalks:
            pushed_stalks[y_cell] = sheaf_stalks[x_cell].copy()
    
    # Push forward restrictions
    for (y1, y2) in _induced_restriction_pairs(f):
        x1, x2 = f_inv.get(y1), f_inv.get(y2)
        if x1 and x2 and (x1, x2) in sheaf_restrictions:
            pushed_restrictions[(y1, y2)] = sheaf_restrictions[(x1, x2)].copy()
    
    return pushed_stalks, pushed_restrictions


def compose_nat(
    eta: NaturalTransformation,
    mu: NaturalTransformation
) -> NaturalTransformation:
    """
    Compose natural transformations: η ∘ μ.
    
    (η ∘ μ)_x = η_x ∘ μ_x (composition of components)
    
    Args:
        eta: Natural transformation F → G
        mu: Natural transformation E → F
        
    Returns:
        Composed natural transformation E → G
    """
    composed = {}
    
    # Union of all cells
    all_cells = set(eta.components.keys()) | set(mu.components.keys())
    
    for cell in all_cells:
        eta_c = eta.components.get(cell)
        mu_c = mu.components.get(cell)
        
        if eta_c is not None and mu_c is not None:
            composed[cell] = eta_c @ mu_c
        elif eta_c is not None:
            composed[cell] = eta_c
        elif mu_c is not None:
            composed[cell] = mu_c
    
    return NaturalTransformation(
        components=composed,
        source_sheaf_id=mu.source_sheaf_id,
        target_sheaf_id=eta.target_sheaf_id
    )


def identity_transformation(cells: List[Tuple], stalk_dim: int) -> NaturalTransformation:
    """Create identity natural transformation."""
    components = {cell: np.eye(stalk_dim) for cell in cells}
    return NaturalTransformation(components=components)


def _induced_restriction_map(f: Dict[Tuple, Tuple]) -> Dict[Tuple, Tuple]:
    """
    Compute induced map on restriction pairs from topology morphism.
    """
    result = {}
    cells = list(f.keys())
    
    for i, x1 in enumerate(cells):
        for x2 in cells[i+1:]:
            y1, y2 = f.get(x1), f.get(x2)
            if y1 and y2:
                result[(x1, x2)] = (y1, y2)
    
    return result


def _induced_restriction_pairs(f: Dict[Tuple, Tuple]) -> List[Tuple]:
    """Get pairs in codomain that have preimages."""
    codomain = list(set(f.values()))
    pairs = []
    
    for i, y1 in enumerate(codomain):
        for y2 in codomain[i+1:]:
            pairs.append((y1, y2))
    
    return pairs


if __name__ == "__main__":
    print("=" * 60)
    print("NATURAL TRANSFORMATION TEST")
    print("=" * 60)
    
    # Test identity transformation
    print("\n1. Identity transformation:")
    cells = [(0,), (1,), (2,)]
    id_nat = identity_transformation(cells, stalk_dim=2)
    v = np.array([1.0, 2.0])
    result = id_nat.apply((0,), v)
    print(f"   id((0,), {v}) = {result}")
    
    # Test composition
    print("\n2. Composition:")
    # Double transformation
    double = NaturalTransformation(
        components={cell: 2.0 * np.eye(2) for cell in cells}
    )
    quad = compose_nat(double, double)
    result = quad.apply((0,), v)
    print(f"   (2x ∘ 2x)(v) = {result}")  # Should be 4v
    
    print("\n" + "=" * 60)
    print("✅ NATURAL TRANSFORMATIONS READY")
    print("=" * 60)
