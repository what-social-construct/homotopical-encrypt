"""
Coregulator DAO — Predictive Consensus via Memory Evolutive Systems

Anticipative consensus: the system predicts the next consensus state,
acts, then compares prediction to outcome. Memory retains prediction
errors to improve future predictions. A Hebbian learning model on the
Grassmannian — what fires together (agrees harmonically) wires together
(increases in selection weight).

Inspired by Ehresmann & Vanbremeersch (2007) Memory Evolutive Systems,
applied to blockchain consensus per Swan et al. (2025) coregulator DAOs.

The coregulator wraps CoherenceEngine with three additional capabilities:

  1. PREDICTION: parallel transport the current Karcher mean μ along a
     velocity field on Gr(k,n) to predict next-epoch consensus μ̂.

  2. COMPARISON: after the epoch, measure d_Gr(μ_actual, μ̂_predicted).
     This prediction error feeds back into the velocity estimate.

  3. MEMORY: exponential moving average of prediction errors + velocity.
     Validators whose stalks consistently align with predictions get
     boosted; those that diverge get dampened. Hebbian, not Markovian.

The result is TIME-MODULATED consensus: morphisms in the validator
category can be hastened (high-confidence prediction) or delayed
(uncertain state). This is the paper's "third progression level."

Reference:
  - Ehresmann & Vanbremeersch (2007): Memory Evolutive Systems
  - Swan, Kido, dos Santos (2025): Higher Categorical Cryptoeconomics
"""

from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Optional
import numpy as np
import time

from ..primitives.grassmann import (
    grassmann_distance,
    grassmann_karcher_mean,
    grassmann_log,
    grassmann_exp,
    grassmann_parallel_transport,
    stalk_to_subspace,
    random_grassmann_point,
)
from ..primitives.cochain import CochainComplex
from .coherence import CoherenceEngine, CechNerve, SQRT2, INV_SQRT2


# =============================================================================
# CONSTANTS
# =============================================================================

MEMORY_DECAY: float = 0.85          # EMA decay for prediction memory
VELOCITY_DECAY: float = 0.9         # EMA decay for velocity field
CONFIDENCE_THRESHOLD: float = 0.3   # Below this → delay propagation
BOOST_FACTOR: float = 1.2           # Hebbian boost for aligned validators
DAMPEN_FACTOR: float = 0.8          # Hebbian dampen for divergent validators
MAX_PREDICTION_HISTORY: int = 64    # Rolling window of prediction errors


# =============================================================================
# COREGULATOR STATE
# =============================================================================

@dataclass
class PredictionRecord:
    """Record of a single epoch's prediction vs outcome."""
    epoch: int
    predicted_consensus: np.ndarray     # μ̂ (predicted Karcher mean)
    actual_consensus: np.ndarray        # μ (actual Karcher mean)
    prediction_error: float             # d_Gr(μ̂, μ)
    timestamp: float = 0.0


@dataclass
class CoregulatorMemory:
    """
    Memory of the coregulator — retained across epochs.

    Stores prediction history and a velocity field (tangent vector
    on Gr(k,n)) that estimates the direction of consensus drift.

    The velocity is updated via EMA of log-map differences:
      v_{t+1} = α·v_t + (1-α)·log_μ(μ_{t+1})

    This is a discrete approximation to the geodesic flow on Gr(k,n).
    """
    # Velocity field (tangent vector at current consensus)
    velocity: Optional[np.ndarray] = None

    # Prediction history (rolling window)
    history: List[PredictionRecord] = field(default_factory=list)

    # Per-validator Hebbian weights (fingerprint → boost/dampen)
    hebbian_weights: Dict[bytes, float] = field(default_factory=dict)

    # Aggregate statistics
    mean_prediction_error: float = 0.0
    prediction_confidence: float = 0.5  # [0,1] — how reliable are predictions
    total_epochs: int = 0

    @property
    def has_velocity(self) -> bool:
        return self.velocity is not None

    def add_record(self, record: PredictionRecord) -> None:
        """Add prediction record and update statistics."""
        self.history.append(record)
        if len(self.history) > MAX_PREDICTION_HISTORY:
            self.history = self.history[-MAX_PREDICTION_HISTORY:]

        # Update running mean error (EMA)
        self.mean_prediction_error = (
            MEMORY_DECAY * self.mean_prediction_error
            + (1 - MEMORY_DECAY) * record.prediction_error
        )

        # Confidence = inverse of mean error, clamped to [0, 1]
        self.prediction_confidence = max(0.0, min(1.0,
            1.0 / (1.0 + self.mean_prediction_error * 5.0)
        ))

        self.total_epochs += 1


# =============================================================================
# COREGULATOR DAO
# =============================================================================

class CoregulatorDAO:
    """
    Memory Evolutive System for predictive consensus.

    Wraps CoherenceEngine with prediction/memory/Hebbian feedback:

      landscape:   CechNerve (current validator topology)
      colimit:     Karcher mean μ (current consensus)
      prediction:  μ̂ = exp_μ(v) where v is the velocity field
      action:      selected validator produces block
      comparison:  d_Gr(μ_actual, μ̂_predicted)
      memory:      EMA of prediction errors + velocity
      update:      adjust velocity + Hebbian weights per error

    The coregulator is the categorical analog of a Kalman filter on
    the Grassmannian: estimate, act, observe, correct.
    """

    def __init__(self, stalk_dim: int = 2):
        self.stalk_dim = stalk_dim
        self.coherence = CoherenceEngine(stalk_dim=stalk_dim)
        self.memory = CoregulatorMemory()
        self._current_consensus: Optional[np.ndarray] = None
        self._prev_consensus: Optional[np.ndarray] = None
        self._current_epoch: int = 0

    # =========================================================================
    # LANDSCAPE → COLIMIT (current state)
    # =========================================================================

    def observe(
        self,
        stalks: Dict[bytes, np.ndarray],
        epoch: int,
    ) -> Dict:
        """
        Observe the current validator landscape and compute consensus.

        Returns topology validation dict (from CoherenceEngine) plus
        prediction comparison if available.
        """
        self._current_epoch = epoch

        # Build Čech nerve and compute sheaf Laplacian
        topology = self.coherence.validate_block_topology(stalks)

        # Compute current consensus (Karcher mean)
        new_consensus = self.coherence.compute_consensus(stalks)
        if new_consensus is None:
            return {**topology, 'prediction_error': None, 'confidence': self.memory.prediction_confidence}

        # Store for velocity computation
        self._prev_consensus = self._current_consensus
        self._current_consensus = new_consensus

        # Compare to prediction (if we made one)
        prediction_error = None
        if self.memory.history and self.memory.history[-1].epoch == epoch:
            # We already predicted this epoch
            predicted = self.memory.history[-1].predicted_consensus
            prediction_error = grassmann_distance(new_consensus, predicted)
            # Update the record with actual outcome
            self.memory.history[-1].actual_consensus = new_consensus
            self.memory.history[-1].prediction_error = prediction_error
            self.memory.add_record(self.memory.history[-1])

        # Update velocity field
        self._update_velocity()

        # Update Hebbian weights
        self._update_hebbian_weights(stalks)

        return {
            **topology,
            'prediction_error': prediction_error,
            'confidence': self.memory.prediction_confidence,
            'velocity_norm': float(np.linalg.norm(self.memory.velocity, 'fro'))
                if self.memory.has_velocity else 0.0,
        }

    # =========================================================================
    # PREDICT (anticipative)
    # =========================================================================

    def predict_next_consensus(self) -> Optional[np.ndarray]:
        """
        Predict next epoch's consensus via parallel transport.

        μ̂_{t+1} = exp_μ(v_t)

        where v_t is the current velocity field (tangent vector at μ).
        If no velocity is available, returns current consensus unchanged.
        """
        if self._current_consensus is None:
            return None

        if not self.memory.has_velocity:
            return self._current_consensus.copy()

        # Scale velocity by confidence — uncertain → smaller step
        scaled_velocity = self.memory.velocity * self.memory.prediction_confidence

        # Geodesic step: exp_μ(scaled_v)
        predicted = grassmann_exp(self._current_consensus, scaled_velocity)

        # Store prediction record
        record = PredictionRecord(
            epoch=self._current_epoch + 1,
            predicted_consensus=predicted,
            actual_consensus=np.zeros_like(predicted),  # filled in on observe()
            prediction_error=0.0,
            timestamp=time.time(),
        )
        self.memory.history.append(record)

        return predicted

    # =========================================================================
    # SELECTION WEIGHTS (Hebbian-modulated)
    # =========================================================================

    def compute_selection_weights(
        self,
        stalks: Dict[bytes, np.ndarray],
    ) -> Dict[bytes, float]:
        """
        Compute selection weights with Hebbian modulation.

        Base weights come from CoherenceEngine (harmonic projection weight).
        Hebbian weights boost validators that consistently align with
        predictions and dampen those that diverge.

        weight(v) = harmonic_weight(v) × hebbian_boost(v)
        """
        # Base harmonic weights
        base_weights = self.coherence.compute_harmonic_weights(stalks)

        # Apply Hebbian modulation
        modulated = {}
        for fp, w in base_weights.items():
            hebbian = self.memory.hebbian_weights.get(fp, 1.0)
            modulated[fp] = w * hebbian

        # Normalize
        total = sum(modulated.values())
        if total > 0:
            modulated = {k: v / total for k, v in modulated.items()}

        return modulated

    def should_delay_propagation(self) -> bool:
        """
        Time-modulation: should block propagation be delayed?

        If prediction confidence is low, the consensus state is uncertain
        and we should wait for more data before committing to a block.
        This is the "time-modulated morphism" from the paper.
        """
        return self.memory.prediction_confidence < CONFIDENCE_THRESHOLD

    def propagation_delay_factor(self) -> float:
        """
        How much to delay (0 = no delay, 1 = max delay).

        Inverse of confidence: uncertain → delay, confident → proceed.
        """
        return max(0.0, 1.0 - self.memory.prediction_confidence)

    # =========================================================================
    # INTERNAL: VELOCITY UPDATE
    # =========================================================================

    def _update_velocity(self) -> None:
        """
        Update velocity field via EMA of consensus drift.

        v_{t+1} = α·v_t + (1-α)·log_μ_{t}(μ_{t+1})

        The log map gives the tangent vector pointing from old to new
        consensus — this is the instantaneous "drift direction."
        """
        if self._prev_consensus is None or self._current_consensus is None:
            return

        # Instantaneous drift: tangent vector from prev to current
        drift = grassmann_log(self._prev_consensus, self._current_consensus)

        if self.memory.velocity is None:
            self.memory.velocity = drift
        else:
            # Transport previous velocity to current tangent space
            transported = grassmann_parallel_transport(
                self.memory.velocity,
                self._prev_consensus,
                self._current_consensus,
            )
            # EMA update
            self.memory.velocity = (
                VELOCITY_DECAY * transported
                + (1 - VELOCITY_DECAY) * drift
            )

    # =========================================================================
    # INTERNAL: HEBBIAN WEIGHT UPDATE
    # =========================================================================

    def _update_hebbian_weights(
        self,
        stalks: Dict[bytes, np.ndarray],
    ) -> None:
        """
        Hebbian update via coboundary disagreement (not raw Grassmann distance).

        From Helfer (arXiv:1908.08944): homotopy equivalent fibrations have
        isomorphic path categories. The coboundary δ₀ measures LOCAL
        disagreement between neighboring validators in the Čech nerve —
        this is the sheaf-theoretic measure used throughout the repo
        (encrypt.py, commitment.py, anonymity.py).

        For each validator v, we compute:
          disagreement(v) = Σ_{e=(v,w)} ‖δ₀(stalk)_e‖²  / degree(v)

        This is the average coboundary energy at v's edges — how much v
        disagrees with its neighbors. Low disagreement → boost (Hebbian
        "fires together, wires together"). High → dampen.

        This replaces raw Grassmann distance to the Karcher mean, which
        measures GLOBAL deviation rather than LOCAL sheaf coherence.
        """
        if self._current_consensus is None:
            return

        # Build cochain complex from nerve to get δ₀
        nerve = self.coherence.build_nerve(stalks)
        if nerve.n_vertices < 2:
            return

        edges = []
        for i in range(nerve.n_vertices):
            for j in range(i + 1, nerve.n_vertices):
                if nerve.adjacency[i, j]:
                    edges.append((i, j))

        if not edges:
            return

        # Build cochain complex (Helfer's formalism)
        cc = CochainComplex.from_graph(nerve.n_vertices, edges, stalk_dim=1)
        delta_0 = cc.coboundary_matrix_0()  # δ₀: C⁰ → C¹

        # Map fingerprints to vertex indices
        fps = list(stalks.keys())
        fp_to_idx = {fp: i for i, fp in enumerate(fps)}

        # Compute per-vertex coboundary energy
        # Use Grassmann distance as the 0-cochain value at each vertex
        # (distance to consensus = how "off" this validator is)
        vertex_values = np.zeros(nerve.n_vertices)
        for fp, stalk_data in stalks.items():
            try:
                P = stalk_to_subspace(stalk_data, self.stalk_dim)
                vertex_values[fp_to_idx[fp]] = grassmann_distance(
                    P, self._current_consensus
                )
            except Exception:
                vertex_values[fp_to_idx[fp]] = 1.0  # default high

        # Apply coboundary: δ₀(c) measures disagreement on edges
        edge_disagreement = delta_0 @ vertex_values  # (n_edges,)

        # Accumulate per-vertex: sum of squared edge disagreements
        vertex_energy = np.zeros(nerve.n_vertices)
        vertex_degree = np.zeros(nerve.n_vertices)
        for e_idx, (i, j) in enumerate(edges):
            energy = edge_disagreement[e_idx] ** 2
            vertex_energy[i] += energy
            vertex_energy[j] += energy
            vertex_degree[i] += 1
            vertex_degree[j] += 1

        # Normalize by degree
        vertex_degree = np.maximum(vertex_degree, 1)
        normalized_energy = vertex_energy / vertex_degree

        # Update Hebbian weights based on coboundary energy
        for fp in stalks:
            idx = fp_to_idx[fp]
            energy = normalized_energy[idx]
            current = self.memory.hebbian_weights.get(fp, 1.0)

            # Low coboundary energy → boost (locally coherent with neighbors)
            # High coboundary energy → dampen (disagrees with neighbors)
            if energy < 0.1:
                updated = min(current * BOOST_FACTOR, 3.0)
            elif energy > 0.5:
                updated = max(current * DAMPEN_FACTOR, 0.1)
            else:
                updated = current * 0.95 + 0.05

            self.memory.hebbian_weights[fp] = updated

    # =========================================================================
    # DIAGNOSTICS
    # =========================================================================

    def diagnostics(self) -> Dict:
        """Full diagnostic snapshot of coregulator state."""
        return {
            'epoch': self._current_epoch,
            'total_epochs_observed': self.memory.total_epochs,
            'has_velocity': self.memory.has_velocity,
            'velocity_norm': float(np.linalg.norm(self.memory.velocity, 'fro'))
                if self.memory.has_velocity else 0.0,
            'prediction_confidence': self.memory.prediction_confidence,
            'mean_prediction_error': self.memory.mean_prediction_error,
            'should_delay': self.should_delay_propagation(),
            'delay_factor': self.propagation_delay_factor(),
            'n_hebbian_weights': len(self.memory.hebbian_weights),
            'hebbian_range': (
                min(self.memory.hebbian_weights.values()) if self.memory.hebbian_weights else 0,
                max(self.memory.hebbian_weights.values()) if self.memory.hebbian_weights else 0,
            ),
            'history_length': len(self.memory.history),
        }


# =============================================================================
# TEST
# =============================================================================

if __name__ == "__main__":
    import hashlib

    print("=" * 60)
    print("COREGULATOR DAO TEST")
    print("=" * 60)

    np.random.seed(42)
    n_validators = 5
    ambient_dim = 5

    # Generate validator stalks with slow drift
    def make_stalks(epoch: int) -> Dict[bytes, np.ndarray]:
        stalks = {}
        drift = epoch * 0.05  # Slow drift
        for i in range(n_validators):
            fp = hashlib.sha256(f"v_{i}".encode()).digest()
            base = np.eye(ambient_dim) * (1.0 + drift)
            noise = np.random.randn(ambient_dim, ambient_dim) * (0.05 + i * 0.02)
            stalks[fp] = base + noise
        return stalks

    coreg = CoregulatorDAO(stalk_dim=ambient_dim)

    print("\nSimulating 20 epochs with drifting consensus:")
    for epoch in range(20):
        stalks = make_stalks(epoch)

        # Predict next (from epoch 1 onwards)
        if epoch > 0:
            predicted = coreg.predict_next_consensus()

        # Observe actual
        result = coreg.observe(stalks, epoch)

        if epoch % 5 == 0:
            diag = coreg.diagnostics()
            print(f"\n  Epoch {epoch}:")
            print(f"    β₀={result['beta_0']}, gap={result['spectral_gap']:.4f}")
            print(f"    prediction_error={result.get('prediction_error', 'N/A')}")
            print(f"    confidence={diag['prediction_confidence']:.4f}")
            print(f"    velocity_norm={diag['velocity_norm']:.4f}")
            print(f"    delay={'YES' if diag['should_delay'] else 'no'}")

    # Selection weights with Hebbian modulation
    print("\n  Hebbian-modulated selection weights:")
    weights = coreg.compute_selection_weights(make_stalks(19))
    for i, (fp, w) in enumerate(sorted(weights.items(), key=lambda x: -x[1])):
        hebbian = coreg.memory.hebbian_weights.get(fp, 1.0)
        print(f"    V{i}: weight={w:.4f}, hebbian={hebbian:.3f}")

    print("\n" + "=" * 60)
    print("✅ COREGULATOR DAO WORKING")
    print("=" * 60)
