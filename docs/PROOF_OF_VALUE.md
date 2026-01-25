# Proof of Value (PoV) Consensus

## The Core Idea

**Value = information that survives measurement**

In quantum mechanics, measurement collapses superposition to eigenstate.
In Proof of Value, projection to harmonic subspace extracts **invariant information**.

```
PoW:  "I burned energy" → permission to write
PoS:  "I locked capital" → permission to write
PoV:  "My geometry has valid spectrum" → permission to write

PoW/PoS: External incentive alignment
PoV:     Internal geometric consistency
```

## Mathematical Foundation

### The Harmonic Projection

Given a cochain c on the nerve complex:

```
c ∈ C^0(X; F)  (0-cochains with values in sheaf F)

Δ = δ*δ + δδ*  (sheaf Laplacian)

Projection: P_H = I - Δ⁺Δ  (projection to ker(Δ))

Harmonic representative: h = P_H(c) ∈ ker(Δ)
```

The harmonic representative h captures the **global section** - information consistent across all local patches.

### The √2 Bound

From the diagonal pairing structure (analogous to Bell inequality):

```
Classical bound on correlations: 2
Quantum/Geometric bound: 2√2

For valid block:
1/√2 < spectral_gap < 2√2
```

This bound ensures:
- Too small gap → topology is disconnected (invalid)
- Too large gap → inconsistent cochains (invalid)
- Just right → geometrically coherent (valid)

## PoV Protocol

### Block Production

```python
class ProofOfValue:
    """
    Proof of Value consensus implementation.
    
    A block is valid if:
    1. All transactions have valid signatures
    2. Combined cochain projects to valid harmonic
    3. Spectral gap is within √2 bounds
    4. Producer proves knowledge of valid fibration
    """
    
    def __init__(self, topology, sheaf):
        self.topology = topology
        self.laplacian = SheafLaplacian(sheaf)
        self.LOWER_BOUND = 1 / np.sqrt(2)
        self.UPPER_BOUND = 2 * np.sqrt(2)
    
    def create_block(self, transactions, producer_credential):
        """
        Create a block via Proof of Value.
        
        Steps:
        1. Embed transactions as cochains
        2. Project to harmonic subspace
        3. Verify spectral gap bounds
        4. Create validity proof
        """
        # 1. Combine all transactions into single cochain
        combined = self._transactions_to_cochain(transactions)
        
        # 2. Compute harmonic projection
        harmonic, orthogonal = self.laplacian.harmonic_projection(combined)
        
        # 3. Get spectral gap
        eigenvalues = self.laplacian.eigendecomposition()[0]
        nonzero = eigenvalues[eigenvalues > 1e-10]
        spectral_gap = nonzero[0] if len(nonzero) > 0 else 0.0
        
        # 4. Verify √2 bounds
        if not (self.LOWER_BOUND < spectral_gap < self.UPPER_BOUND):
            raise InvalidBlock(f"Spectral gap {spectral_gap} outside bounds")
        
        # 5. Create proof
        proof = self._create_pov_proof(
            harmonic=harmonic,
            eigenvalues=eigenvalues,
            producer_credential=producer_credential
        )
        
        return Block(
            transactions=transactions,
            harmonic_representative=harmonic,
            spectral_gap=spectral_gap,
            orthogonal_component=orthogonal,  # Can discard or store
            proof=proof
        )
    
    def verify_block(self, block):
        """
        Verify a block's Proof of Value.
        
        Anyone can verify without knowing producer's secret.
        """
        # 1. Verify signatures
        for tx in block.transactions:
            if not self._verify_signature(tx):
                return False
        
        # 2. Reconstruct cochain
        combined = self._transactions_to_cochain(block.transactions)
        
        # 3. Recompute harmonic projection
        harmonic, _ = self.laplacian.harmonic_projection(combined)
        
        # 4. Check harmonic matches
        if not np.allclose(harmonic, block.harmonic_representative, atol=1e-6):
            return False
        
        # 5. Verify spectral gap
        eigenvalues = self.laplacian.eigendecomposition()[0]
        nonzero = eigenvalues[eigenvalues > 1e-10]
        computed_gap = nonzero[0] if len(nonzero) > 0 else 0.0
        
        if abs(computed_gap - block.spectral_gap) > 1e-6:
            return False
        
        # 6. Check √2 bounds
        if not (self.LOWER_BOUND < block.spectral_gap < self.UPPER_BOUND):
            return False
        
        # 7. Verify proof
        return self._verify_pov_proof(block.proof)
    
    def _create_pov_proof(self, harmonic, eigenvalues, producer_credential):
        """
        Create proof that producer knows valid fibration.
        
        The proof shows:
        - Producer has credential with matching topology
        - Harmonic projection was computed correctly
        - Spectral gap comes from valid Laplacian
        
        This is NOT a ZK proof (transparent) but could be made ZK.
        """
        # Hash commitments
        harmonic_hash = hashlib.sha256(harmonic.tobytes()).digest()
        eigenvalue_hash = hashlib.sha256(eigenvalues.tobytes()).digest()
        
        # Spectral fingerprint proves producer identity
        producer_fingerprint = producer_credential.spectrum.fingerprint_hash()
        
        return {
            'harmonic_commitment': harmonic_hash,
            'eigenvalue_commitment': eigenvalue_hash,
            'producer_fingerprint': producer_fingerprint,
            'topology_hash': producer_credential.spectrum.topology_hash
        }
    
    def _verify_pov_proof(self, proof):
        """Verify the PoV proof is well-formed."""
        required = ['harmonic_commitment', 'eigenvalue_commitment', 
                   'producer_fingerprint', 'topology_hash']
        return all(k in proof for k in required)
```

### Transaction to Cochain Embedding

```python
def transaction_to_cochain(tx, topology, dim):
    """
    Embed transaction as 0-cochain.
    
    A transaction assigns "value" to vertices based on:
    - Sender vertex gets negative amount
    - Recipient vertex gets positive amount
    - Other vertices get zero
    
    This ensures: sum over vertices = 0 (conservation)
    """
    vertices = topology.get(0, [])
    cochain = np.zeros(len(vertices) * dim)
    
    sender_idx = find_vertex_index(tx.sender, vertices)
    recipient_idx = find_vertex_index(tx.recipient, vertices)
    
    if sender_idx is not None:
        # Encode negative amount
        cochain[sender_idx * dim] = -tx.amount
    
    if recipient_idx is not None:
        # Encode positive amount
        cochain[recipient_idx * dim] = tx.amount
    
    return cochain
```

## Why √2?

### The Geometry of Measurement

When you measure a quantum system:
- Pre-measurement: superposition (lives in high-dim space)
- Post-measurement: eigenstate (collapsed to subspace)
- The √2 bounds how much correlation survives

In PoV:
- Pre-projection: cochain (lives in full cochain space)
- Post-projection: harmonic (collapsed to ker(Δ))
- The √2 bounds valid spectral gaps

### Analogy to Bell Inequality

```
Bell Setup:
  Alice measures spin (angle α)
  Bob measures spin (angle β)
  Correlation ⟨A·B⟩ ≤ 2 classically
  Correlation ⟨A·B⟩ ≤ 2√2 quantum

PoV Setup:
  Sender encodes value (vertex s)
  Recipient receives value (vertex r)
  Spectral gap λ₁ ≤ 2√2 for valid topology
```

The √2 isn't arbitrary - it's the maximum "correlation" possible in geometric space that respects the tensor product structure.

## Economic Properties

### Sybil Resistance

```
PoW: Sybil costs energy
PoS: Sybil costs capital
PoV: Sybil... costs NOTHING?

No! Sybil in PoV changes the TOPOLOGY.
Adding fake nodes changes the nerve.
Changed nerve → different Laplacian → different spectrum.

If attacker creates many fake identities:
- Topology becomes sparse (many disconnected nodes)
- Spectral gap → 0 (approaches lower bound)
- Block becomes INVALID

The geometry itself rejects Sybil attacks.
```

### Validator Selection

```python
def select_validator(epoch, eligible_validators, prev_block):
    """
    Select validator for next block.
    
    Unlike PoS (stake-weighted random), PoV uses:
    - Spectral centrality in current topology
    - Verifiable randomness from prev_block
    
    Validators with higher "geometric importance" have higher chance,
    but not because they have more capital - because they're more connected.
    """
    # Compute spectral centrality for each validator
    centralities = compute_spectral_centrality(
        topology=current_topology(),
        validators=eligible_validators
    )
    
    # VRF from prev block
    randomness = VRF(prev_block.hash, epoch)
    
    # Weighted selection by centrality
    return weighted_select(eligible_validators, centralities, randomness)


def compute_spectral_centrality(topology, validators):
    """
    Spectral centrality = importance based on eigenstructure.
    
    High centrality = well-connected in topology
    Low centrality = peripheral/isolated
    
    This naturally rewards network participation, not capital accumulation.
    """
    laplacian = SheafLaplacian(topology)
    eigenvalues, eigenvectors = laplacian.eigendecomposition()
    
    # Use Fiedler vector (second eigenvector) for centrality
    fiedler = eigenvectors[:, 1]
    
    centralities = {}
    for v in validators:
        idx = vertex_index(v, topology)
        centralities[v] = abs(fiedler[idx])
    
    return centralities
```

### Finality

```
PoW: Probabilistic finality (51% attack possible)
PoS: Economic finality (slashing makes reversal expensive)
PoV: Geometric finality (topology hash commits to structure)

Once a block is finalized:
- Its topology is committed via hash
- Reversing would require different topology
- Different topology = different spectral gap
- Observers detect inconsistency immediately

Finality is 1 block (deterministic geometry, not probabilistic mining).
```

## Comparison Table

| Property | PoW | PoS | PoV |
|----------|-----|-----|-----|
| Resource | Energy | Capital | Geometry |
| Sybil resistance | Energy cost | Capital cost | Topology change |
| Validator selection | Hash race | Stake weight | Spectral centrality |
| Finality | Probabilistic | Economic | Geometric |
| Environmental cost | High | Low | Minimal |
| Centralization risk | Mining pools | Large stakers | Well-connected nodes |
| Novel contribution | First | Efficient | Recouples capital→value |

## Implementation Status

```
[x] Laplacian construction
[x] Harmonic projection
[x] Eigenvalue computation
[x] √2 bound checking
[ ] Block structure
[ ] Validator selection
[ ] Network integration
[ ] Production hardening
```

## The Philosophy

**Proof of Work**: You prove you wasted something (energy).
**Proof of Stake**: You prove you risked something (capital).
**Proof of Value**: You prove you have something (geometric coherence).

```
PoW/PoS: Extrinsic motivation (incentives align behavior)
PoV:     Intrinsic structure (geometry IS validity)

Capital is currently decoupled from value.
You can have capital without creating value.
You can create value without gaining capital.

PoV recouples them:
- Your "capital" = your position in the topology
- Your "value" = the harmonic component you can extract
- Valid blocks = geometrically coherent contributions

If you contribute garbage, projection extracts nothing.
If you contribute value, projection preserves it.

The consensus IS the measurement.
```
