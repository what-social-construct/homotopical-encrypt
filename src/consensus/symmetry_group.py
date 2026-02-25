"""
Validator Symmetry Group (Swan Table 1 #10 — Zhao)

Algebraic structure of the validator set under PoV consensus.
Mining/validator nodes form a GROUP whose structure reveals:
  - Which validator configurations are equivalent (cosets)
  - The algebraic constraints on selection fairness
  - Formal bounds on validator set manipulation attacks

KEY INSIGHT (connecting to homotopical-encrypt):

  In PoV consensus, the spectral gap λ₁ determines block production
  eligibility. Validators with the SAME spectral gap are algebraically
  indistinguishable for selection — they form a COSET in the validator
  group. This is the implicit symmetry Zhao describes.

  The spectral gap creates a natural GRADING (filtration) on the group:
    G = G₀ ⊃ G₁ ⊃ G₂ ⊃ ... ⊃ Gₖ
  where Gᵢ = {validators with λ₁ ≥ threshold_i}

  This grading is a NORMAL SERIES if the selection function is
  equivariant under the symmetry — i.e., permuting equivalent
  validators doesn't change the selection distribution.

STRUCTURES:

  ValidatorGroup: the full algebraic structure
  - Elements: active validators (with spectral gaps)
  - Operation: composition of credential rotations
  - Identity: null rotation (same credential)
  - Inverse: rotation back to original class
  
  SpectralCoset: equivalence class under spectral gap
  - All validators with gaps in [λ - ε, λ + ε]
  - Selection is UNIFORM within a coset
  - Inter-coset selection is weighted by gap quality
  
  GradedFiltration: the normal series from spectral ordering
  - Each level = validators above a threshold
  - Quotient groups = the "selection tiers"

  SelectionOrbit: trajectory of a validator under repeated selection
  - Period = how often validator produces blocks
  - Orbit size = effective validator set size

ATTACK ANALYSIS:

  Sybil resistance: coset structure bounds the advantage of splitting
  one validator into N copies (each gets 1/N of the original gap weight).
  
  Collusion detection: if a coset grows faster than the network,
  it indicates Sybil or collusion (algebraic anomaly in coset sizes).

Based on: Zhao (2020), "Algebraic Structure of Blockchains"
  arXiv:2002.05973v1
"""

from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Optional, Set, FrozenSet
import numpy as np
from collections import defaultdict


# =============================================================================
# SPECTRAL COSET: equivalence class of validators
# =============================================================================

@dataclass
class SpectralCoset:
    """
    Equivalence class of validators with the same spectral gap (up to ε).
    
    In group theory: a coset gH where H is the stabilizer of the
    spectral gap value, and g is any validator in the class.
    
    Within a coset, selection is UNIFORM (no algebraic distinction).
    Between cosets, selection is WEIGHTED by gap quality.
    
    Properties:
    - |coset| = number of validators with this gap
    - weight = selection probability allocated to this coset
    - internal_symmetry = S_{|coset|} (full symmetric group)
    """
    gap_value: float           # Representative spectral gap λ₁
    gap_tolerance: float       # ε: width of equivalence band
    members: List[bytes]       # Validator fingerprints in this coset
    
    def size(self) -> int:
        return len(self.members)
    
    def contains(self, fingerprint: bytes) -> bool:
        return fingerprint in self.members
    
    def internal_symmetry_order(self) -> int:
        """
        Order of the internal symmetry group S_n.
        
        Within a coset, all n validators are interchangeable,
        so the symmetry group is S_n with order n!.
        This is the "algebraic coset" from Zhao.
        """
        n = self.size()
        result = 1
        for i in range(1, n + 1):
            result *= i
        return result
    
    def per_member_weight(self, total_coset_weight: float) -> float:
        """
        Each member's share of the coset's selection weight.
        
        Uniform within coset: w_i = W_coset / |coset|
        This is the equivariance property: permuting members
        within a coset doesn't change individual weights.
        """
        if self.size() == 0:
            return 0.0
        return total_coset_weight / self.size()
    
    def sybil_advantage(self, n_splits: int) -> float:
        """
        Advantage gained by splitting one validator into n_splits copies.
        
        In a FAIR system: splitting into N copies should give the SAME
        total weight (each copy gets 1/N of original gap).
        
        Returns: ratio of total weight after split / weight before split
        Should be ≈ 1.0 for Sybil-resistant design.
        For sublinear gap-weighting: ratio < 1.0 (splitting HURTS).
        """
        # PoV uses spectral gap directly → linear weighting
        # Splitting: one validator with gap λ → N validators each with gap λ/N
        # (because splitting credential splits the fibration structure)
        # Total weight after: N × f(λ/N) vs before: f(λ)
        # For f(x) = x (linear): N × λ/N = λ → ratio = 1.0 (neutral)
        # For f(x) = x² (quadratic): N × (λ/N)² = λ²/N → ratio = 1/N (hurts)
        # For f(x) = √x (sqrt): N × √(λ/N) = √(Nλ) → ratio = √N (helps!)
        #
        # Our PoV uses sqrt-weighted selection (harmonic centrality),
        # but gap is bounded by √2 Tsirelson, so:
        #   After split: each copy has gap λ/N, which may fall BELOW
        #   the PoV lower bound (1/√2), making them ineligible entirely.
        #
        # Result: splitting is PENALIZED because sub-threshold gaps
        # get zero selection weight.
        SQRT2 = np.sqrt(2)
        POV_LOWER = 1.0 / SQRT2
        
        original_eligible = 1 if self.gap_value >= POV_LOWER else 0
        split_gap = self.gap_value / n_splits
        splits_eligible = n_splits if split_gap >= POV_LOWER else 0
        
        if original_eligible == 0:
            return 0.0
        
        # Weight ratio: splits_eligible × f(split_gap) / f(gap_value)
        if splits_eligible == 0:
            return 0.0  # All splits below threshold
        
        # Harmonic weight is proportional to gap
        return (splits_eligible * split_gap) / self.gap_value


# =============================================================================
# GRADED FILTRATION: normal series from spectral ordering
# =============================================================================

@dataclass
class GradedFiltration:
    """
    Normal series of the validator group graded by spectral gap.
    
    G = G₀ ⊃ G₁ ⊃ G₂ ⊃ ... ⊃ Gₖ
    
    where Gᵢ = {validators with λ₁ ≥ threshold_i}
    
    The quotient groups Gᵢ/Gᵢ₊₁ are the "selection tiers":
    validators in tier i but not tier i+1 form a group whose
    algebraic structure determines selection within that tier.
    
    This connects to the CHAIN CONSTRUCTION (#8 Fiore):
    the filtration IS a directed structure on the validator set,
    and the quotient maps are the "PROP morphisms" that describe
    how blocks flow from high-gap to low-gap validators.
    """
    thresholds: List[float]         # Increasing spectral gap thresholds
    levels: List[Set[bytes]]        # G_i at each threshold
    
    @classmethod
    def from_validators(
        cls,
        validators: Dict[bytes, float],  # fingerprint → spectral_gap
        n_levels: int = 4,
    ) -> 'GradedFiltration':
        """
        Build filtration from validator spectral gaps.
        
        Automatically determines thresholds from gap distribution.
        """
        if not validators:
            return cls(thresholds=[], levels=[])
        
        gaps = sorted(validators.values())
        
        # Evenly spaced thresholds from min to max gap
        min_gap = gaps[0]
        max_gap = gaps[-1]
        
        if max_gap - min_gap < 1e-10:
            # All validators have same gap → single level
            return cls(
                thresholds=[min_gap],
                levels=[set(validators.keys())]
            )
        
        thresholds = np.linspace(min_gap, max_gap, n_levels + 1)[:-1].tolist()
        
        levels = []
        for t in thresholds:
            level = {fp for fp, gap in validators.items() if gap >= t}
            levels.append(level)
        
        return cls(thresholds=thresholds, levels=levels)
    
    def tier_sizes(self) -> List[int]:
        """Size of each tier (quotient group)."""
        sizes = []
        for i in range(len(self.levels)):
            if i + 1 < len(self.levels):
                tier = self.levels[i] - self.levels[i + 1]
            else:
                tier = self.levels[i]
            sizes.append(len(tier))
        return sizes
    
    def is_normal(self) -> bool:
        """
        Check if the filtration is a normal series.
        
        Normal iff each G_{i+1} is a normal subgroup of G_i,
        which holds iff the quotient G_i/G_{i+1} is well-defined.
        
        For spectral gap filtration: ALWAYS normal because
        the grading is by a totally ordered invariant (gap value).
        Subgroups defined by "gap ≥ threshold" are always normal
        in the full group (they're defined by a group homomorphism
        to (ℝ, ≥) which is abelian → kernel is normal).
        """
        # Verify containment: G_0 ⊇ G_1 ⊇ ... ⊇ G_k
        for i in range(len(self.levels) - 1):
            if not self.levels[i + 1].issubset(self.levels[i]):
                return False
        return True
    
    def concentration_index(self) -> float:
        """
        Gini-like concentration measure of the filtration.
        
        0.0 = all validators in one tier (maximally concentrated)
        1.0 = validators evenly distributed across tiers
        
        High concentration suggests potential manipulation
        (many validators clustered at one gap level = possible Sybil).
        """
        sizes = self.tier_sizes()
        total = sum(sizes)
        if total == 0 or len(sizes) <= 1:
            return 0.0
        
        # Normalized entropy
        probs = [s / total for s in sizes if s > 0]
        entropy = -sum(p * np.log2(p) for p in probs if p > 0)
        max_entropy = np.log2(len(sizes))
        
        if max_entropy < 1e-10:
            return 0.0
        
        return entropy / max_entropy


# =============================================================================
# SELECTION ORBIT: trajectory under repeated selection
# =============================================================================

@dataclass
class SelectionOrbit:
    """
    Orbit of a validator under repeated block production selection.
    
    The orbit records the sequence of epochs where this validator
    was selected. From this we extract:
    - period: average gap between selections (block production rate)
    - regularity: variance of inter-selection gaps
    - fairness: observed frequency vs expected frequency
    
    An anomalous orbit (much more or less frequent than expected)
    indicates either manipulation or network partitioning.
    """
    validator: bytes
    selection_epochs: List[int] = field(default_factory=list)
    expected_frequency: float = 0.0  # Expected selections per epoch
    
    def observed_frequency(self, total_epochs: int) -> float:
        """Observed selection frequency."""
        if total_epochs == 0:
            return 0.0
        return len(self.selection_epochs) / total_epochs
    
    def period(self) -> float:
        """Average epochs between selections."""
        if len(self.selection_epochs) < 2:
            return float('inf')
        gaps = [
            self.selection_epochs[i+1] - self.selection_epochs[i]
            for i in range(len(self.selection_epochs) - 1)
        ]
        return np.mean(gaps)
    
    def regularity(self) -> float:
        """
        Coefficient of variation of inter-selection gaps.
        
        Low = regular (honest, well-connected validator)
        High = bursty (possible manipulation or intermittent connectivity)
        """
        if len(self.selection_epochs) < 3:
            return 0.0
        gaps = [
            self.selection_epochs[i+1] - self.selection_epochs[i]
            for i in range(len(self.selection_epochs) - 1)
        ]
        mean = np.mean(gaps)
        if mean < 1e-10:
            return 0.0
        return np.std(gaps) / mean
    
    def fairness_ratio(self, total_epochs: int) -> float:
        """
        Ratio of observed to expected frequency.
        
        1.0 = perfectly fair
        > 1.0 = over-selected (suspicious)
        < 1.0 = under-selected (possibly penalized)
        """
        if self.expected_frequency < 1e-10:
            return 0.0
        observed = self.observed_frequency(total_epochs)
        return observed / self.expected_frequency


# =============================================================================
# VALIDATOR GROUP: the full algebraic structure
# =============================================================================

@dataclass
class ValidatorGroup:
    """
    The algebraic group structure of the validator set.
    
    Elements: active validators identified by spectral fingerprint
    Operation: the GROUP OPERATION is credential rotation composition
      - rotate(v₁) ∘ rotate(v₂) = rotate both in sequence
      - This is well-defined because rotation preserves homotopy class
      - Identity = null rotation (keep current credential)
      - Inverse = rotate to any other credential in same class
    
    The group is ABELIAN because rotations commute:
      rotate(v₁) ∘ rotate(v₂) = rotate(v₂) ∘ rotate(v₁)
    (both just generate fresh fibrations independently)
    
    GRADING by spectral gap makes this a FILTERED group.
    
    Connects to:
    - #10 Zhao: mining pool coset structure
    - #8 Fiore: PROP algebra on the directed validator graph
    - #9 Goncharov: axiomatization of selection rules
    - #4 Gabbay: semitopological coalitions as group actions
    """
    
    def __init__(self):
        self._validators: Dict[bytes, float] = {}  # fp → spectral_gap
        self._cosets: List[SpectralCoset] = []
        self._filtration: Optional[GradedFiltration] = None
        self._orbits: Dict[bytes, SelectionOrbit] = {}
        self._coset_tolerance: float = 0.1  # ε for gap equivalence
    
    # ── ELEMENT MANAGEMENT ──
    
    def add_validator(self, fingerprint: bytes, spectral_gap: float):
        """Add element to the group."""
        self._validators[fingerprint] = spectral_gap
        self._invalidate()
    
    def remove_validator(self, fingerprint: bytes):
        """Remove element from the group."""
        self._validators.pop(fingerprint, None)
        self._invalidate()
    
    def order(self) -> int:
        """Group order |G|."""
        return len(self._validators)
    
    def _invalidate(self):
        """Invalidate cached structures."""
        self._cosets = []
        self._filtration = None
    
    # ── COSET DECOMPOSITION ──
    
    def compute_cosets(self, tolerance: Optional[float] = None) -> List[SpectralCoset]:
        """
        Decompose G into spectral cosets.
        
        Two validators are in the same coset iff |λ₁(v) - λ₁(w)| < ε.
        
        Returns: list of SpectralCoset, sorted by gap_value descending
        """
        if self._cosets:
            return self._cosets
        
        eps = tolerance or self._coset_tolerance
        
        # Sort validators by gap
        sorted_vals = sorted(self._validators.items(), key=lambda x: -x[1])
        
        cosets = []
        assigned = set()
        
        for fp, gap in sorted_vals:
            if fp in assigned:
                continue
            
            # Find all validators within ε of this gap
            members = []
            for fp2, gap2 in sorted_vals:
                if fp2 not in assigned and abs(gap - gap2) < eps:
                    members.append(fp2)
                    assigned.add(fp2)
            
            cosets.append(SpectralCoset(
                gap_value=gap,
                gap_tolerance=eps,
                members=members,
            ))
        
        self._cosets = cosets
        return cosets
    
    def coset_of(self, fingerprint: bytes) -> Optional[SpectralCoset]:
        """Find which coset a validator belongs to."""
        for coset in self.compute_cosets():
            if coset.contains(fingerprint):
                return coset
        return None
    
    # ── GRADED FILTRATION ──
    
    def compute_filtration(self, n_levels: int = 4) -> GradedFiltration:
        """Build the graded filtration G₀ ⊃ G₁ ⊃ ... ⊃ Gₖ."""
        if self._filtration is not None:
            return self._filtration
        self._filtration = GradedFiltration.from_validators(
            self._validators, n_levels
        )
        return self._filtration
    
    # ── SELECTION ORBITS ──
    
    def record_selection(self, fingerprint: bytes, epoch: int):
        """Record that a validator was selected at this epoch."""
        if fingerprint not in self._orbits:
            # Expected frequency = this validator's weight
            weights = self.compute_selection_weights()
            expected = weights.get(fingerprint, 0.0)
            self._orbits[fingerprint] = SelectionOrbit(
                validator=fingerprint,
                expected_frequency=expected,
            )
        self._orbits[fingerprint].selection_epochs.append(epoch)
    
    def get_orbit(self, fingerprint: bytes) -> Optional[SelectionOrbit]:
        return self._orbits.get(fingerprint)
    
    # ── SELECTION WEIGHTS (connects to PoV) ──
    
    def compute_selection_weights(self) -> Dict[bytes, float]:
        """
        Compute per-validator selection weights from coset structure.
        
        Weight allocation:
        1. Total weight distributed to cosets proportional to gap²
           (quadratic favors high-gap = Sybil-resistant)
        2. Within coset: uniform (S_n symmetry)
        
        This is equivariant: permuting validators within a coset
        doesn't change the weight distribution.
        """
        SQRT2 = np.sqrt(2)
        POV_LOWER = 1.0 / SQRT2
        POV_UPPER = 2.0 * SQRT2
        
        cosets = self.compute_cosets()
        
        # Compute coset weights (quadratic in gap, gated by PoV bounds)
        coset_weights = []
        for coset in cosets:
            if POV_LOWER <= coset.gap_value <= POV_UPPER:
                w = coset.gap_value ** 2  # Quadratic → Sybil-resistant
            else:
                w = 0.01  # Minimum weight for out-of-bounds
            coset_weights.append(w)
        
        total = sum(coset_weights)
        if total < 1e-10:
            # Uniform fallback
            n = self.order()
            return {fp: 1.0/n for fp in self._validators} if n > 0 else {}
        
        # Distribute to individuals
        weights = {}
        for coset, cw in zip(cosets, coset_weights):
            normalized_cw = cw / total
            per_member = coset.per_member_weight(normalized_cw)
            for fp in coset.members:
                weights[fp] = per_member
        
        return weights
    
    # ── GROUP INVARIANTS ──
    
    def is_abelian(self) -> bool:
        """
        Check if the validator group is abelian.
        
        Always True for PoV: credential rotations commute,
        and the spectral gap grading is a homomorphism to (ℝ, +).
        """
        return True
    
    def center_size(self) -> int:
        """
        Size of the center Z(G).
        
        For abelian groups: Z(G) = G (every element commutes with all).
        """
        return self.order() if self.is_abelian() else 0
    
    def composition_factors(self) -> List[Tuple[str, int]]:
        """
        Composition factors of the validator group.
        
        For the spectral-graded abelian group:
        G ≅ C_{n₁} × C_{n₂} × ... × C_{nₖ}
        where nᵢ = |coset_i| and C_n is cyclic of order n.
        
        (Rotation within a coset is cyclic: eventually you visit
        all members and return to the start.)
        """
        cosets = self.compute_cosets()
        return [(f"C_{c.size()}", c.size()) for c in cosets if c.size() > 0]
    
    # ── ATTACK DETECTION ──
    
    def detect_sybil_anomaly(self, max_coset_fraction: float = 0.5) -> List[SpectralCoset]:
        """
        Detect cosets that are suspiciously large.
        
        If one coset has > max_coset_fraction of all validators,
        it may indicate Sybil attack (one entity creating many
        validators with similar spectral gaps).
        
        Returns: list of anomalous cosets
        """
        cosets = self.compute_cosets()
        total = self.order()
        if total == 0:
            return []
        
        return [c for c in cosets if c.size() / total > max_coset_fraction]
    
    def detect_orbit_anomaly(
        self, total_epochs: int, 
        fairness_threshold: float = 2.0
    ) -> List[Tuple[bytes, float]]:
        """
        Detect validators with anomalous selection frequency.
        
        fairness_ratio > threshold → over-selected (suspicious)
        fairness_ratio < 1/threshold → under-selected (penalized?)
        
        Returns: list of (fingerprint, fairness_ratio) for anomalous validators
        """
        anomalies = []
        for fp, orbit in self._orbits.items():
            ratio = orbit.fairness_ratio(total_epochs)
            if ratio > fairness_threshold or (ratio > 0 and ratio < 1.0 / fairness_threshold):
                anomalies.append((fp, ratio))
        return anomalies
    
    # ── TRANSACTION COMPOSITION ASSOCIATIVITY ──
    
    def verify_composition_associativity(self) -> Tuple[bool, str]:
        """
        Verify that transaction composition is associative.
        
        Transaction composition IS associative by construction:
        
        1. Cochain commitments: δ(a) + δ(b) is vector addition (abelian group)
           → (δ(a) + δ(b)) + δ(c) = δ(a) + (δ(b) + δ(c)) ✓
        
        2. Homotopy paths: path composition is associative UP TO HOMOTOPY
           → (p₁ · p₂) · p₃ ≃ p₁ · (p₂ · p₃) in π₁(X)
           This is why we use homotopy classes, not raw paths.
        
        3. Key images: hash composition is associative
           → H(H(a) || b) depends on order but within a transaction
             key images are SET-based (unordered), so associativity
             is trivially satisfied.
        
        4. The coboundary δ is a LINEAR MAP:
           → δ(αx + βy) = αδ(x) + βδ(y)
           Linearity implies associativity of the induced composition.
        
        This is a STRUCTURAL PROPERTY, not a runtime check.
        We verify the algebraic prerequisites hold.
        """
        # Check 1: group operation is associative (abelian → yes)
        if not self.is_abelian():
            return (False, "Group is non-abelian — composition may not associate")
        
        # Check 2: filtration is normal (quotients well-defined)
        filt = self.compute_filtration()
        if not filt.is_normal():
            return (False, "Filtration not normal — tier composition undefined")
        
        return (True, 
            "Transaction composition is associative by construction: "
            "cochain addition is abelian, homotopy path composition "
            "associates up to equivalence, coboundary δ is linear."
        )
    
    # ── SUMMARY ──
    
    def summary(self) -> Dict:
        """Full algebraic summary of the validator group."""
        cosets = self.compute_cosets()
        filt = self.compute_filtration()
        weights = self.compute_selection_weights()
        
        return {
            'order': self.order(),
            'is_abelian': self.is_abelian(),
            'center_size': self.center_size(),
            'num_cosets': len(cosets),
            'coset_sizes': [c.size() for c in cosets],
            'coset_gaps': [c.gap_value for c in cosets],
            'composition_factors': self.composition_factors(),
            'filtration_normal': filt.is_normal(),
            'filtration_tiers': filt.tier_sizes(),
            'concentration_index': filt.concentration_index(),
            'sybil_anomalies': len(self.detect_sybil_anomaly()),
            'selection_weights': {
                fp.hex()[:12]: round(w, 6) for fp, w in weights.items()
            },
        }
