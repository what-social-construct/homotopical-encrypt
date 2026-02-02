# $HCRYPT Chain Architecture

## Philosophy: Sovereignty, Not Hiding

Unlike Monero (hide everything), $HCRYPT enables **choice**:
- Transparent by default (auditable)
- Private when you need it (encrypted)
- Self-sovereign always (no KYC gatekeepers)

**The chain doesn't hide - it empowers.**

## Core Primitives

### 1. Identity = Spectral Fingerprint

```
Traditional:  Address = hash(public_key)
$HCRYPT:      Address = spectral_fingerprint(fibration)

Your address IS the eigenvalue spectrum of your secret geometry.
- Self-generated (no issuer)
- Quantum-resistant (LWE foundation)
- Key agility (can rotate keys, same identity if same spectrum)
```

### 2. Transaction = Cochain

```
Traditional:  TX = (from, to, amount, signature)
$HCRYPT:      TX = 0-cochain over topology nerve

A transaction assigns data to each vertex of the connection topology.
- Multi-party native (not just sender→receiver)
- Consistency checked via coboundary δ
- Can be encrypted or transparent (your choice)
```

### 3. Block = Harmonic Representative

```
Traditional:  Block = list of transactions + header
$HCRYPT:      Block = harmonic cochain + projection proof

A block is the harmonic representative of all included transactions.
- Projection to ker(Δ) is the "consensus"
- √2 bounds validity (Bell inequality)
- Spectral gap = security parameter
```

### 4. Consensus = Proof of Value (PoV)

```
Traditional:  PoW = burn energy, PoS = lock capital
$HCRYPT:      PoV = show spectral invariants

You produce a block by:
1. Collect transactions (cochains)
2. Project to harmonic subspace
3. Prove projection is valid (spectral gap ∈ [1/√2, 2√2])
4. Other nodes verify geometry, not energy/capital
```

## Chain Structure

```
┌─────────────────────────────────────────────────────────┐
│                    HCRYPT BLOCK N                       │
├─────────────────────────────────────────────────────────┤
│ header:                                                 │
│   prev_hash: SHA256(block N-1)                         │
│   merkle_root: root of cochain tree                    │
│   spectral_gap: λ₁ of block Laplacian                  │
│   topology_hash: hash of included party topology       │
│   timestamp: unix timestamp                            │
│   producer_fingerprint: spectral fingerprint of miner  │
│                                                         │
│ harmonic_representative:                                │
│   projection of all transactions to ker(Δ)             │
│                                                         │
│ transactions:                                           │
│   [cochain₁, cochain₂, ..., cochainₙ]                  │
│                                                         │
│ proof:                                                  │
│   eigenvalue_commitment: hash(eigenvalues)             │
│   projection_witness: data to verify projection        │
└─────────────────────────────────────────────────────────┘
```

## Transaction Types

### Type 1: Transparent Transfer
```python
{
    "type": "transfer",
    "from": spectral_fingerprint,
    "to": spectral_fingerprint,
    "amount": 100.0,
    "token": "HCRYPT",
    "encrypted": False,  # Anyone can see
    "signature": homotopy_signature(private_fibration)
}
```

### Type 2: Private Transfer
```python
{
    "type": "transfer",
    "commitment": SHA256(encrypted_content),
    "topology_hash": who_can_decrypt,
    "encrypted_content": FibrationCiphertext.serialize(),
    "encrypted": True,  # Only parties can see
    "signature": homotopy_signature(private_fibration)
}
```

### Type 3: Sovereignty Setup
```python
{
    "type": "sovereignty_setup",
    "new_identity": spectral_fingerprint,
    "public_topology": nerve_structure,  # Who you connect to
    "proof_of_generation": ZK_proof_valid_fibration,
    "encrypted": False  # Identity creation is transparent
}
```

### Type 4: Multi-Party Agreement
```python
{
    "type": "agreement",
    "parties": [fingerprint₁, fingerprint₂, fingerprint₃],
    "topology": connection_graph,
    "threshold": "2-of-3",  # Emerges from geometry
    "terms_hash": SHA256(terms),
    "signatures": [sig₁, sig₂, sig₃]
}
```

## Proof of Value Consensus

### Block Production

```python
def produce_block(pending_txs, my_fibration):
    # 1. Build topology from all involved parties
    all_parties = extract_parties(pending_txs)
    topology = build_nerve(all_parties)
    
    # 2. Embed transactions as cochains
    cochains = [tx_to_cochain(tx, topology) for tx in pending_txs]
    
    # 3. Build combined cochain
    combined = sum_cochains(cochains)
    
    # 4. Build Laplacian for this topology
    laplacian = SheafLaplacian(topology, restriction_maps)
    
    # 5. Project to harmonic (THE CONSENSUS STEP)
    harmonic, eigenvalues = laplacian.harmonic_projection(combined)
    
    # 6. Check spectral gap bounds (√2 validity)
    gap = eigenvalues[eigenvalues > 1e-6][0]
    if not (1/sqrt(2) < gap < 2*sqrt(2)):
        raise InvalidBlock("Spectral gap out of bounds")
    
    # 7. Create proof
    proof = create_pov_proof(eigenvalues, harmonic, my_fibration)
    
    return Block(
        transactions=pending_txs,
        harmonic_representative=harmonic,
        spectral_gap=gap,
        proof=proof
    )
```

### Block Verification

```python
def verify_block(block):
    # 1. Verify all transaction signatures
    for tx in block.transactions:
        if not verify_homotopy_signature(tx):
            return False
    
    # 2. Rebuild topology
    topology = build_nerve(extract_parties(block.transactions))
    
    # 3. Verify spectral gap claim
    laplacian = SheafLaplacian(topology)
    eigenvalues = laplacian.eigendecomposition()[0]
    gap = eigenvalues[eigenvalues > 1e-6][0]
    
    if abs(gap - block.spectral_gap) > 1e-6:
        return False
    
    # 4. Verify √2 bounds (Bell inequality)
    if not (1/sqrt(2) < gap < 2*sqrt(2)):
        return False
    
    # 5. Verify harmonic projection
    combined = sum_cochains([tx_to_cochain(tx) for tx in block.transactions])
    harmonic, _ = laplacian.harmonic_projection(combined)
    
    if not np.allclose(harmonic, block.harmonic_representative):
        return False
    
    return True
```

## State Model

### Unified SheafState (chloe_protocol pattern)

Inspired by chloe_protocol's `SystemState + HashChain` pattern:

```python
@dataclass
class SheafState:
    """Unified chain state with HashChain tracing."""
    
    # Identity layer (sovereignty)
    accounts: Dict[bytes, AccountState]
    
    # Value layer (UTXO)
    utxos: Dict[bytes, UTXO]
    spent_key_images: Set[bytes]
    
    # Block layer
    block_headers: Dict[bytes, BlockHeader]
    tip_hash: bytes
    tip_height: int
    
    # Pending layer
    mempool: Dict[bytes, Transaction]
    
    # Hash chain (ALL transformations traced!)
    hash_chain: HashChain
    
    # Spectral cache (invalidated when topology changes)
    spectral_cache: SpectralCache
```

### HashChain (cryptographic tracing)

```python
class HashChain:
    """
    Merkle-tree-like audit trail.
    genesis → sovereignty_claim → connection → transfer → key_rotation → block → ...
    """
    
    def add_sovereignty_claim(fingerprint, homotopy_class_id, topology_hash) -> str
    def add_connection(party_a, party_b, topology_hash) -> str
    def add_transfer(tx_hash, key_images, output_commitments) -> str
    def add_key_rotation(fingerprint, rotation_count, homotopy_class_id) -> str
    def add_block(block_hash, height, spectral_gap, tx_count) -> str
    
    def verify_chain() -> bool  # Verify entire chain integrity
```

### Key Design Decisions

1. **Topology implicit** - computed on-demand from account connections
2. **Stalk types** - use primitives/stalk.py for elegance
3. **ONE HashChain** - unified with 'type' field per entry
4. **Cache + invalidation** - cache eigenvalues, recompute when topology changes

### Account State (at each vertex)
```python
@dataclass
class AccountState:
    fingerprint: bytes           # Spectral fingerprint (address)
    homotopy_class_id: bytes     # Equivalence class (key rotation)
    balance: float               # Current balance
    nonce: int                   # Transaction counter
    connected_to: Set[bytes]     # Connections to other accounts
    rotation_count: int          # Key rotation history
```

## Network Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      VALIDATORS                         │
│  (Run full nodes, produce blocks, stake HCRYPT)         │
│  Requirements: Valid fibration credential               │
└─────────────────────────────────────────────────────────┘
                          ↑↓
┌─────────────────────────────────────────────────────────┐
│                      FULL NODES                         │
│  (Verify blocks, serve state, relay transactions)       │
│  No special requirements                                │
└─────────────────────────────────────────────────────────┘
                          ↑↓
┌─────────────────────────────────────────────────────────┐
│                      LIGHT CLIENTS                      │
│  (Verify proofs, submit transactions)                   │
│  Only need spectral fingerprint                         │
└─────────────────────────────────────────────────────────┘
```

## Sovereignty Setup Flow

### New User Onboarding

```python
# 1. Generate fibration credential (LOCAL - no network)
credential = generate_credential(
    parties=['me'],  # Self-sovereign
    connections=[],   # No required connections initially
    security_parameter=256
)

# 2. Compute spectral fingerprint (LOCAL)
my_identity = credential.spectrum.fingerprint_hash()

# 3. Create sovereignty proof (LOCAL)
proof = create_sovereignty_proof(credential)

# 4. Broadcast to network (ONLY public info)
tx = SovereigntySetupTx(
    fingerprint=my_identity,
    public_topology=credential.topology,  # Just structure, not keys
    proof=proof
)

# Now you exist on HCRYPT with self-sovereign identity
# No KYC, no issuer, no permission needed
```

### Adding Connections

```python
# Alice and Bob want to connect (enables direct transfers)

# 1. Alice and Bob each have credentials
alice_cred = ...
bob_cred = ...

# 2. They create shared topology
shared_cred = generate_credential(
    parties=['alice', 'bob'],
    connections=[('alice', 'bob')]
)

# 3. Broadcast connection
tx = ConnectionTx(
    parties=[alice_fingerprint, bob_fingerprint],
    topology=shared_cred.topology,
    signatures=[alice_sig, bob_sig]
)

# Now Alice↔Bob transfers are native, no intermediary
```

## Token Economics

### $HCRYPT Token

```
Total Supply: Fixed (deflationary)
Distribution:
  - 40% Community (sovereignty setup rewards)
  - 30% Development (protocol + tooling)
  - 20% Validators (block rewards)
  - 10% Treasury (ecosystem growth)

Utility:
  - Gas for transactions (burned → deflationary)
  - Validator staking
  - Governance votes
  - Privacy feature unlock (optional encryption)
```

### Fee Structure

```
Transparent transfer:  0.001 HCRYPT (basic)
Private transfer:      0.01 HCRYPT  (encryption overhead)
Sovereignty setup:     FREE (onboarding incentive)
Multi-party agreement: 0.005 HCRYPT per party
```

## Implementation Roadmap

### Phase 1: Core (Weeks 1-4)
- [ ] Block structure implementation
- [ ] PoV consensus algorithm
- [ ] Basic transaction types
- [ ] P2P networking

### Phase 2: Sovereignty (Weeks 5-8)
- [ ] Sovereignty setup flow
- [ ] Connection management
- [ ] Light client proof verification
- [ ] Wallet reference implementation

### Phase 3: Privacy (Weeks 9-12)
- [ ] Private transfer implementation
- [ ] ZK proof integration
- [ ] Multi-party agreement
- [ ] Encrypted state channels

### Phase 4: Bridge (Weeks 13-16)
- [ ] Solana bridge (HCRYPT ↔ SOL)
- [ ] $REVENGE integration
- [ ] Cross-chain sovereignty proofs

## Technical Stack

```
Language:      Rust (core), Python (tooling)
Networking:    libp2p
Storage:       RocksDB
Serialization: borsh
Crypto:        Our LWE implementation + existing primitives
VM:            None initially (UTXO-like), later WASM
```

## Why This Works

1. **Sovereignty by design**: Identity is self-generated spectral fingerprint
2. **Transparency optional**: You choose what to encrypt
3. **Geometric consensus**: PoV is math-verified, not trust-verified
4. **Quantum resistant**: LWE foundation survives Shor
5. **Net neutral**: Topology treats all nodes equally

**Recoupling capital to value through geometric coherence.**
