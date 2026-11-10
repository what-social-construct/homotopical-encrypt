# Archived architecture

> **Historical design document.** This file preserves the earlier Python-led
> system architecture and motivating narrative. It is not the current Lean or
> protocol specification. For the verified mathematical surface, use
> [`../PROOF_MAP.md`](../PROOF_MAP.md); for planned Paper 2 protocol work, use
> [`../PROTOCOL_PARITY_QUEUE.md`](../PROTOCOL_PARITY_QUEUE.md).

## philosophy

### the panopticon assumption

the design assumes a panopticon adversary who observes all network
traffic, records all blockchain transactions, has unlimited computation
including quantum supremacy, and controls infrastructure.

quantum supremacy is mathematically irrelevant because security
comes from hodge-hardness (finding ker(Δ) without Δ) and δ-hardness
(inverting the sheaf coboundary), both of which reduce to SVP/CVP
on structured lattices. no quantum algorithm — shor, grover, or
otherwise — can find harmonic projection without eigendecomposition,
solve CVP on the cochain lattice, or distinguish structured hodge
noise from random.

the entire codebase is public because security comes from
mathematical hardness, not obscurity:

```
public:                         private:
all algorithms                  your fibration F
all proofs                      your restriction maps R_{v→e}
all verification code           your specific laplacian Δ
network protocol                your messages (in ker(Δ))
```

### sovereignty via geometry

```
identity        := spectral invariants of your secret fibration
                   (self-generated, no issuer, no one can revoke)
privacy         := harmonic projection (message lives in ker(Δ),
                   orthogonal to anything the adversary can observe)
sovereignty     := dim(agency(A, p)) unchanged under observation
                   (panopticon cannot restrict your homotopy paths)
net neutrality  := Δ treats all vertices equally
                   (same stalk dimension, symmetric restriction maps)
```

agency(A, p) := space of available homotopy paths from position p.
manipulation := restricting another agent's available paths.
but paths in a homotopy class are infinite — you can always rotate
to a new credential in the same class. the old credential becomes
meaningless, agency is preserved.

### invariants replace institutions

```
spectral fingerprint  → identity without surveillance
betti numbers         → topology without central registry
holonomy              → path verification without trusted party
fee penalties         → enforcement without police
ZK proofs             → truth without disclosure
```

the sheaf laplacian Δ treats all vertices equally. eigenvalue
spectrum depends on topology, not identity. no vertex is privileged.
this is geometric fairness — not a design choice but a mathematical
consequence of the hodge decomposition.

### validation philosophy

three layers, each for its purpose:

- by-construction: internal types that cannot represent invalid state
  (ConnectedTopology can only hold β₀ = 1, PositiveSpectralGap
  can only hold λ₁ > 0). if you have one, it's valid by definition.
- hard gates: keygen/encrypt/decrypt abort on invariant violation.
  these catch bugs in our code, not bad input.
- verification: external inputs (network, chain) go through explicit
  validation returning accept/reject. ZK proofs are this — the
  verification IS the security protocol.

this is propositions-as-types applied to crypto.

## functorial structure

the system is built from functors between categories:

```
    Simp(X)ᵒᵖ ──F──→ Vect_q
    (simplicial      (ℤ_q-modules)
     complex)

    F(v) = stalk at vertex v         (ℤ_q^d)
    F(v ⊂ e) = R_{v→e}: F(v) → F(e) (restriction map)
```

the coboundary δ is the natural transformation induced by F:

```
    C⁰(X, F) ──δ₀──→ C¹(X, F) ──δ₁──→ C²(X, F)
    (vertex data)     (edge data)       (face data)

    δ₀(c)_e = R_{j→e} · c_j  −  R_{i→e} · c_i
              (disagreement between stalks along edge e = (i,j))
```

encrypt and decrypt are adjoint functors:

```
    encrypt := δ + noise : C⁰ → C⁰
    (coboundary pushes message to edges, noise hides it)

    decrypt := π_H = projection onto ker(Δ) : C⁰ → H⁰
    (harmonic projection recovers global section)

    π_H ∘ encrypt ≃ id  (up to lattice rounding)
    because noise ∈ im(δ) ⊕ im(δ*) ⊥ ker(Δ) = H⁰
```

topology change is functorial via pullback/pushforward:

```
    f: X → Y   (topology morphism)

    f*: Sh(Y) → Sh(X)   pullback  (contravariant: cochains pull back)
    f_*: Sh(X) → Sh(Y)  pushforward (covariant: stalks push forward)

    (f ∘ g)* = g* ∘ f*  (functoriality)

    value transfer between topologies = pullback of cochains
    incentive distribution = pushforward of stalks
```

the diagonal pairing (from helfer's homotopical logic):

```
    ⟨−,−⟩: C^k(X, F) × C_k(X) → ℤ_q
    (cochain)          (chain)    (evaluation)

    a k-cochain c ∈ C^k evaluates on a k-chain σ ∈ C_k:
    ⟨c, σ⟩ = value of c on the cell σ

    the adjointness (stokes' theorem on the cochain complex):
    ⟨δc, σ⟩ = ⟨c, ∂σ⟩

    this is the encrypt/decrypt duality:
    - encrypt pushes data up via δ (coboundary, increases degree)
    - decrypt pulls data down via ∂ (boundary, decreases degree)
    - the pairing guarantees they are adjoint inverses

    in helfer's logic:
    - types   := cells of the simplicial complex X
    - terms   := cochains c ∈ C^k(X, F)
    - truth   := the diagonal pairing ⟨c, σ⟩
    - context := the nerve (which cells are faces of which)

    our mapping:
    - types   := vertices and edges of the čech nerve
    - terms   := stalk values (vertex data) and restrictions (edge data)
    - truth   := message recovery: ⟨π_H(b), v₀⟩ = m
    - context := the topology (who talks to whom)
```

homotopy equivalence between fibrations:

```
    F ≃ G  iff  ∃ η: F ⇒ G, μ: G ⇒ F  (natural transformations)
           s.t.  μ ∘ η ≃ id_F, η ∘ μ ≃ id_G

    detected by: spec(Δ_F) = spec(Δ_G)  (spectral invariants)
                 β_k(F) = β_k(G)         (betti numbers)
                 χ(F) = χ(G)             (euler characteristic)

    this is the anonymity set: all G ≃ F are indistinguishable
```

### the homotopy category and its nerve

credentials live in a **category**, not just a topological space:

```
HomotopyCategory C:
  Objects   = homotopy equivalence classes [F], [G], ...
  Morphisms = homotopy paths γ: [F] → [G]
  Composition = path concatenation γ₂ ∘ γ₁

the categorical nerve Nerve(C) is a simplicial set:
  N₀(C) = objects = {[F₁], [F₂], ...}
  N₁(C) = morphisms = {γ: [F₁] → [F₂]}
  N₂(C) = 2-morphisms = homotopies of paths H: γ₁ ⇒ γ₂
```

**homotopy paths are explicit geodesics:**

from `geometry/homotopy_path.py`:
```python
def construct_geodesic_path(L_source, L_target):
    # eigendecompose: L = V Λ V^T
    # compute rotation: R = V_source^T @ V_target ∈ SO(n)
    # geodesic on SO(n): V(t) = V_source @ exp(t * log(R))
    # reconstruct: L(t) = V(t) Λ V(t)^T
    
    # this is DETERMINISTIC — shortest path in the manifold
    # of laplacians with fixed spectrum
```

**transactions follow these paths:**

```
Alice's credential ∈ [F_A]  ────γ────→  Bob's credential ∈ [F_B]
     (homotopy class)        (geodesic)       (homotopy class)

transaction = explicit path data:
  - source spectral fingerprint (identifies [F_A])
  - target spectral fingerprint (identifies [F_B])
  - key image (unique to Alice's F_A, prevents double-spend)
  - amount commitment (cochain δ(amount || randomness))
```

### sheafstate as the categorical colimit

SheafState is the **universal object** that unifies all three layers.
it is the colimit of the three-layer diagram:

```
         Wallet (Layer 3)
    η₁ ↙              ↘ φ₁
Oracle (Layer 2)         ↘
    η₂ ↙              ↘   ↘
Node (Layer 1)     →  →  →  SheafState
       φ₂ ↗        φ₃ ↗
```

**universal property:** for any other state system S with morphisms
ψ₁, ψ₂, ψ₃ from the three layers, there exists a unique φ: SheafState → S
such that ψᵢ = φ ∘ ηᵢ.

**what this means in code:**

```python
# src/chain/sheaf_state.py:
class SheafState:
    def apply_block(self, block):
        # this IS the factorization φ
        # every operation factors through SheafState
        
        # Layer 1: mark key images spent (accountability)
        for key_image in extract_key_images(block):
            self.spent_key_images.add(key_image)
        
        # Layer 3: update balances (sovereignty)
        for tx in block.transactions:
            sender_id = fingerprint_to_account(tx.sender_fingerprint)
            self.accounts[sender_id].balance -= tx.fee
        
        # Layer 1: store block (audit trail)
        self.block_headers.append(block.header)
        self.hash_chain.trace(block)
        
        # the colimit property: ALL state changes
        # go through this single function
```

**the nerve structures:**

```
Account Nerve (Layer 1 topology):
  X_accounts = Čech nerve of account sovereignty domains
  vertices = accounts
  edges = transactional connections (who has sent to whom)
  
Fibration Nerve (Layer 3 category):
  X_fibrations = Nerve(HomotopyCategory)
  0-cells = homotopy classes [F]
  1-cells = geodesic paths γ: [F] → [G]
  2-cells = path homotopies H: γ₁ ⇒ γ₂
  
SheafState = Γ(X_accounts, Sheaf valued in |Nerve(HomotopyCategory)|)
           = global sections of a sheaf over account topology
             valued in the geometric realization of the homotopy category
```

**AccountState.connected_to tracks both:**

```rust
// rust/node/src/storage/state.rs:
pub struct AccountState {
    pub connected_to: HashSet<u64>,  // 1-skeleton of BOTH nerves!
}
```

this tracks:
1. which accounts have transacted (Layer 1 topology)
2. which homotopy classes are connected (Layer 3 paths)

they coincide because **transactions ARE morphisms in the homotopy category**.

**coherence theorem:**

for the system to be consistent, the natural transformations η₁, η₂
must preserve the nerve structure:

```
    Nerve(Wallet) ──η₁──→ Nerve(Oracle) ──η₂──→ Nerve(Node)
         ↓                      ↓                    ↓
    |Nerve(Wallet)| ──────→ |Nerve(Oracle)| ──→ |Nerve(Node)|
```

this is automatically satisfied because:
- η₁ (hodge projection) preserves spectral invariants → preserves objects
- η₁ preserves geodesics → preserves morphisms
- η₂ (hash) preserves binding → preserves the categorical structure

the implementation is **functorial by construction**.

## the mathematical pipeline

```
message m ∈ ℤ_q^d
  → embed as 0-cochain c₀ ∈ C⁰(X, F)
  → apply coboundary δ: C⁰ → C¹ (edge syndromes)
  → add hodge-structured noise e ∈ im(δ) ⊕ im(δ*)
  → ciphertext b := c₀ + e lives in C⁰

decrypt:
  → build Δ := δ*δ + δδ* (sheaf laplacian)
  → eigendecompose Δ = Σ λᵢ vᵢvᵢᵀ
  → project π_H(b) onto ker(Δ) (harmonic subspace)
  → extract m from harmonic component

security:
  → without knowing Δ, recovering m from b is CVP
    on the harmonic sublattice of the cochain complex
  → this is hodge-hardness (strictly harder than LWE)
```

## module map

### primitives/ — algebraic foundations

## 1. Identity = Spectral Fingerprint

```
Traditional:  Address = hash(public_key)
$HOMOTOPICAL_ENCRYPT:      Address = spectral_fingerprint(fibration)

Your address IS the eigenvalue spectrum of your secret geometry.
- Self-generated (no issuer)
- Quantum-resistant (cochain lattice foundation, reduces to SVP/CVP)
- Key agility (can rotate keys, same identity if same spectrum)
```

### 2. Transaction = Homotopy Proof

```
Traditional:  TX = (from, to, amount, signature)
$HOMOTOPICAL_ENCRYPT:      TX = (fingerprint, key_image, amount_commitment, spectral_proof)

Proves class membership and commits to amount. See homotopy_transaction.py.
- Staged verification: key image → structure → spectral → invariants
- Cochain structure (primitives/cochain.py) underlies the geometry layer
- Block producer embeds transactions into cochains for harmonic projection
```

### 3. Block = Harmonic Representative

```
Traditional:  Block = list of transactions + header
$HOMOTOPICAL_ENCRYPT:      Block = harmonic cochain + projection proof

A block is the harmonic representative of all included transactions.
- Projection to ker(Δ) is the "consensus"
- √2 bounds validity (Bell inequality)
- Spectral gap = security parameter
```

### 4. Consensus = Proof of Value (PoV)

```
Traditional:  PoW = burn energy, PoS = lock capital
$HOMOTOPICAL_ENCRYPT:      PoV = show spectral invariants

You produce a block by:
1. Collect transactions (cochains)
2. Project to harmonic subspace
3. Prove projection is valid (spectral gap ∈ [1/√2, 2√2])
4. Other nodes verify geometry, not energy/capital
```

## Three-Layer Chain (Hardness Hierarchy)

the system has three layers, each a natural transformation (projection)
that drops information while preserving binding. the layers correspond
to the hardness hierarchy from hardness.py:

```
    homotopical search  >  hodge-hardness / CVP  >  hash projection
    (anonymity)            (binding / amounts)       (accountability)
```

each transition is a functorial projection — not arbitrary, but the
minimal information-losing map that preserves the relevant invariant:

```
F_full ──η₁──→ F_hash ──η₂──→ F_chain
(wallet)       (oracle)        (node)

η₁ := hodge projection    ker(Δ) → quantized commitment bytes
       (drops fibration secret, preserves spectral invariants)

η₂ := hash projection     commitment → SHA256(commitment + invariants)
       (drops lattice structure, preserves binding)
```

both η₁ and η₂ are natural transformations in the categorical sense:
they commute with restriction maps across edges, so the sheaf structure
is preserved at every layer. SHA256 is not arbitrary — it's the final
projection in the sheaf's natural transformation chain.

### the three layers

```
┌──────────────────────────────────────────────────────────────────┐
│  LAYER 3: HOMOTOPY  (Python wallet)                              │
│  Hardness: Homotopical search (Helfer, arXiv:1908.08944)        │
│  Purpose:  ANONYMITY — who signed is indistinguishable           │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  COMPUTES:                                                       │
│  • FibrationCredential = (topology, fibration, spectrum)         │
│  • Eigendecomposition of Δ (O(n³), heavy)                       │
│  • Hodge projection onto ker(Δ) → harmonic component            │
│  • Quantize to commitment bytes (deterministic)                  │
│  • Homotopy class membership (infinite anonymity set)            │
│  • Key images (unique per fibration, double-spend prevention)    │
│                                                                  │
│  PRIVATE DATA:                                                   │
│  • Fibration secret (restriction maps R_{v→e})                   │
│  • Laplacian Δ = δ*δ + δδ* (never leaves wallet)               │
│  • Full credential in F_v (256-dim stalk)                        │
│                                                                  │
│  OUTPUT: FullStalk (commitment + eigenvalues + gap + betti)      │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                           │
                     η₁: F_full → F_hash
                     (hodge projection — drops fibration secret,
                      preserves spectral invariants + commitment)
                           │
                           ▼
┌──────────────────────────────────────────────────────────────────┐
│  LAYER 2: LATTICE / CVP  (Rust oracle)                           │
│  Hardness: Hodge-hardness (CVP on cochain lattice)              │
│  Purpose:  BINDING — amounts and commitments are unforgeable     │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  VERIFIES (never recomputes):                                    │
│  • Spectral gap ∈ [1/√2, 2√2] (Tsirelson bounds)               │
│  • Betti numbers consistent (β₀ ≥ 1)                            │
│  • Commitment bytes non-trivial (Python didn't fail)             │
│  • Eigenvalues non-negative (Laplacian is PSD)                   │
│  • Naturality across edges (sheaf consistency)                   │
│  • Cochain commitment well-formedness: δ(m||r) mod q            │
│  • Homomorphic accumulation: Σ δ(txᵢ) = δ(Σ txᵢ)               │
│                                                                  │
│  CVP binding: finding collision requires ker(δ) ≡ SVP-hard      │
│  Post-quantum: no Shor shortcut (no algebraic period structure)  │
│                                                                  │
│  OUTPUT: HashStalk (fingerprint + gap + betti + topology_hash)   │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                           │
                     η₂: F_hash → F_chain
                     (hash projection — drops lattice structure,
                      preserves binding via collision resistance)
                           │
                           ▼
┌──────────────────────────────────────────────────────────────────┐
│  LAYER 1: HASH PROJECTION  (Rust node)                           │
│  Hardness: SHA256 collision resistance (2^128)                   │
│  Purpose:  ACCOUNTABILITY — public audit trail, chain integrity  │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STORES:                                                         │
│  • Block headers: SHA256("HOMOTOPICAL_ENCRYPT_BLOCK_V1" + fields)            │
│  • Key image set (spent tracking, double-spend gate)             │
│  • Cochain roots: SHA256(Σ verified commitments)                 │
│  • Chain tip + height (canonical chain selection)                │
│  • HashChain audit trail (genesis → sovereignty → transfer → …) │
│                                                                  │
│  CHECKS:                                                         │
│  • √2 bounds (simple float comparison)                           │
│  • Hash chain integrity (prev_hash linkage)                      │
│  • Key image uniqueness (set membership)                         │
│  • Block hash validity (domain-separated SHA256)                 │
│                                                                  │
│  NO eigenvalue computation. NO lattice operations.               │
│  Pure hash verification + state transitions.                     │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### SheafState as the bus

SheafState connects all three layers. it is the unified state
abstraction that tracks data at every hardness level:

```
SheafState
├── accounts           → Layer 1 (fingerprints, balances, nonces)
├── spent_key_images   → Layer 1 (accountability, double-spend)
├── hash_chain         → Layer 1 (SHA256 audit trail)
├── block_headers      → Layer 1 (chain structure)
│
├── get_hash_commitments()  → Layer 2 (η₁ output: HashCommitment per account)
├── verify_commitment()     → Layer 2 (CVP-bound verification)
├── to_oracle_request()     → Layer 2 (Python → Oracle bridge)
├── spectral_cache          → Layer 2 (cached spectral gap)
│
├── compute_topology()      → Layer 3 (nerve from connections)
├── homotopy_class_id       → Layer 3 (per account, anonymity set)
└── rotate_keys()           → Layer 3 (new fibration, same class)
```

a transaction flows through all three layers:
1. wallet creates HomotopyTransaction (Layer 3: proves class membership)
2. oracle verifies commitment + spectral invariants (Layer 2: CVP binding)
3. node stores block hash + key images (Layer 1: accountability)

the projections are one-way: Layer 3 data never reaches Layer 1.
the node sees only hashes. the oracle sees commitments but not
the fibration. the wallet holds everything.

### witness-style state updates

The production chain should use a witness/verifier split. Full cochains,
private stalks, homotopy paths, and fibration representatives are witness
material. The public chain sees only the compressed consequences needed for
verification:

```
encrypted SheafState / private fibration data
  → cochain or homotopy witness
  → public inputs: key image, topology hash, cochain root, public shadow
  → proof object or oracle attestation
  → Rust verifier result
  → state-root update
```

This is why cochains should be treated as intermediate state by default, not
as raw public transaction bodies. A full cochain may be public in a transparent
or test path, but private flows expose a commitment/root and a proof that the
hidden cochain induces the claimed state transition.

### why SHA256 is a projection, not arbitrary

SHA256 in this system is η₂: F_hash → F_chain. it is the unique
(up to collision resistance) structure-preserving map that:

1. compresses verified lattice commitments to fixed 32 bytes
2. preserves binding (collision resistance → commitment binding)
3. commutes with the coboundary: SHA256(Σ δ(txᵢ)) is deterministic
   given the verified cochain root from the oracle
4. is the identity on chain structure (prev_hash linkage is a chain
   complex: ∂² = 0 holds because SHA256(SHA256(x)) is idempotent
   on the hash chain structure)

SHA256 loses the lattice structure (you can't recover δ(m||r) from
its hash), but that's exactly what Layer 1 needs — accountability
without the ability to reverse-engineer amounts or identities.

---

## Rust Architecture


```
┌─────────────────────────────────────────────────────────┐
│                    HOMOTOPICAL_ENCRYPT BLOCK N                       │
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
│   public projection/shadow of accepted witnesses        │
│                                                         │
│ transactions:                                           │
│   [proof-carrying transaction envelopes]                │
│                                                         │
│ proof:                                                  │
│   eigenvalue_commitment: hash(eigenvalues)             │
│   projection_witness/proof: verifies hidden cochains   │
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
    "token": "HOMOTOPICAL_ENCRYPT",
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


```
cochain.py       CochainComplex := (C⁰ →δ C¹ →δ C², coboundary maps)
                 apply_coboundary_0(), coboundary_matrix_0(), laplacian_0()
stalk.py         StalkProjection := R_{v→e} (restriction maps between contexts)
                 the coboundary δ(c)_e = R_j·c_j - R_i·c_i
algebra.py       wedge product ∧, hodge star *, interior product ι
                 exterior algebra operations on vector spaces
natural.py       pullback f*: C^k(Y) → C^k(X), pushforward f_*
                 natural transformations η: F → G between sheaves
homotopy.py      HomotopyInvariants := (betti_numbers, spectral_gap, euler_char)
                 HomotopyClass, HomotopyEquivalence, verify_equivalence()
```

### geometry/ — sheaf and hodge theory

```
sheaf.py             CellularSheaf := (nerve, stalks, restriction_maps)
                     coboundary_0(), adjoint_coboundary_0(), build_cech_nerve()
sheaf_laplacian.py   SheafLaplacian := Δ = δ*δ + δδ*
                     harmonic_projection(), eigendecomposition(), spectral_gap()
                     note: δ* is implicit in Δ (see docstring)
hodge.py             hodge decomposition: C^k = H^k ⊕ im(δ) ⊕ im(δ*)
                     build_coboundary_operator(), compute_hodge_projectors()
noise.py             hodge-structured noise sampling
                     exact_noise (im(δ)), coexact_noise (im(δ*)), combined
lattice.py           Lattice, Sublattice, hodge_decomposition_lattices()
                     sublattice structure of im(δ), im(δ*), ker(Δ)
topology.py          nerve construction, simplicial complex operations
fiber_bundle.py      fiber bundle transport for onion routing
                     parallel transport, holonomy, metadata encryption
homotopy_path.py     geodesic paths between homotopy-equivalent fibrations
```

### crypto/ — cochain-based encryption

```
credential.py    FibrationCredential := (topology, fibration, spectrum)
                 generate_credential(), keygen invariant gates
encrypt.py       encrypt: m → harmonic embedding → δ + hodge noise → ciphertext
                 coboundary structure + structured noise in im(δ)⊕im(δ*)
decrypt.py       decrypt: ciphertext → lattice threshold decode + π_H verification
                 dual decode (local lattice + global harmonic projection)
commitment.py    CochainCommitment := δ(m || r), hiding via coboundary
                 BlindedCommitment, VectorCommitment, partial opening
lattice.py       CochainLattice, noise sampling (spectral, exact, O-U, heat kernel)
                 secure_random_vector(), secure_random_matrix()
validation.py    hard gates: dimension, modulus, spectral matching, topology binding
hardness.py      hodge-hardness problem definition and parameter estimation
padding.py       constant-size padding (traffic analysis resistance)
random.py        cryptographically secure RNG (secrets-backed)
secure_memory.py memory protection utilities
```

### invariants/ — validation pipeline

```
unified.py       orchestrator: validate_fibration(stage) runs all checkpoints
                 stages: keygen, encrypt, decrypt, transaction
spectral.py      SpectralInvariants := (eigenvalues, spectral_gap, condition_number)
                 compute_spectral_invariants(), spectral_matching()
algebraic.py     cup_product(), massey_triple_product(), cup_product_rank()
                 algebraic invariant gating (cheaper than homotopy checks)
cohomology.py    CohomologyInvariants := (betti_numbers, coboundary_ranks, euler_char)
                 compute_cohomology(), validate_nerve_structure()
harmonic.py      harmonic embedding validation, noise structure checking
                 is_exact(), is_coexact(), project_to_harmonic(), hodge_decompose()
homotopical.py   full homotopy equivalence checking (most expensive gate)
fibration.py     fibration-specific invariants (fiber dimension, base topology)
```

### proofs/ — zero-knowledge proofs

```
spectral.py      prove/verify spectral identity (eigenvalue matching)
                 prove/verify spectral match between fingerprints
anonymity.py     hodge-hardness ZK: prove knowledge of h ∈ ker(Δ)
                 without revealing Δ (Fiat-Shamir + coboundary checks)
consensus.py     ProofOfValue: spectral gap validation, block creation
                 Transaction, Block types for PoV consensus
homotopy.py      homotopy class membership proofs
```

### chain/ — transaction and state layer

```
homotopy_transaction.py  homotopy-native transactions (not ring signatures)
                         anonymity := homotopy class membership (infinite set)
                         staged verification: key image → structure → spectral → invariants
sheaf_state.py           SheafState := unified state bus with HashChain tracing
                         mempool, key images, spectral cache, block headers
account.py               AccountState := sovereignty layer (identity, connections)
                         key rotation within homotopy class, no KYC
block_producer.py        block creation and validation
block.py                 Block, BlockHeader types
key_image.py             HomotopyKeyImage := unique per fibration, prevents double-spend
chain_store.py           persistent storage adapter
wallet_store.py          wallet-local encrypted storage
```

### consensus/ — proof of value

```
validator_selection.py   spectral centrality selection (fiedler vector weighted)
                         ValidatorSet, select_validator() with VRF
invariant_validator.py   InvariantValidator := PoV invariant checkpoints
                         √2 bounds: spectral gap ∈ [1/√2, 2√2]
```

### network/ — onion routing

```
onion_service.py    onion-routed message delivery
                    each hop encrypted via fiber bundle transport
routing.py          path selection, relay discovery
```

### oracle/ — geometry bridge

```
client.py    oracle client for off-chain stalk computations
             bridges python geometry to rust node
```

### rust/ — node implementation

```
rust/node/       full node: storage, networking, consensus (PoV)
rust/wallet/     wallet operations, credential storage
rust/oracle/     geometry oracle: stalk bridge, spectral computations
```

## privacy model

anonymity := membership in homotopy class [F]

- the anonymity set is the entire equivalence class of fibrations
  with matching spectral invariants (infinite set, not N decoys)
- proofs := spectral invariant matching (eigenvalues, betti numbers)
- key images := unique per fibration, prevent double-spend
  without revealing which class member spent

four privacy layers, each from the geometry:

### sender privacy (homotopy class membership)

all fibrations in the same homotopy class have identical spectral
fingerprint. the "ring" is the entire equivalence class — infinite,
not a finite set of decoys. proof size is O(1) regardless of class
cardinality. verifier sees only the spectral fingerprint, cannot
distinguish which class member signed.

### receiver privacy (stealth addresses via fiber ambiguity)

different points in the same fiber project to the same base point.
each transaction uses a new fiber point (via shared secret +
parallel transport). same spectral fingerprint, different internal
structure. only the recipient can recover the fiber point.

### amount privacy (confidential amounts via homomorphic coboundary)

```
    commitment C = δ(amount ⊕ blinding_factor)

    homomorphic: δ is linear, so δ(a+b) = δ(a) + δ(b)
    → verify Σ(inputs) = Σ(outputs) + fee without decrypting
    hiding: recovering amount requires blinding factor (hodge-hard)
    binding: collision requires finding ker(δ) element (δ-hard)
```

### double-spend prevention (key images)

key image := hash(eigenvectors || connection_coefficients)

```
    spectral fingerprint    key image
    ─────────────────────   ─────────────────────
    same for homotopy class unique per fibration
    reveals equivalence     reveals nothing
    used for identity       used for double-spend
```

the key image is deterministic per fibration but one-way: can't
recover the fibration from the image. different from the spectral
fingerprint (which is the same for all class members). this is
why key rotation works — new fibration in same class produces
new key image, but same fingerprint.

### structural advantages

- infinite anonymity set (homotopy class, not N decoys)
- O(1) proofs (spectral fingerprint is fixed size)
- geometric threshold (not traditional MPC — see note below)
- key agility (rotate within class, no other privacy system has this)
- auditable supply (homomorphic coboundary allows global balance check)
- post-quantum (hodge-hardness reduces to SVP/CVP on cochain lattices,
  no quantum algorithm breaks these — past transactions stay private forever)

**note on "multi-party":** the system is not multi-party computation in
the traditional sense (N separate humans each holding a key share and
communicating to reconstruct). rather, a single credential has an
N-vertex topology (the čech nerve), and the geometric structure —
k-vertex-connectivity, betti numbers, spectral gap — determines what
threshold of vertex data is needed for decryption. the "threshold"
emerges from the topology: if you remove (n-k) vertices and β₀ still
equals 1 (graph stays connected), the remaining k vertices can still
span ker(Δ). this gives threshold-like behavior from geometry, not
from a protocol between separate parties. traditional MPC requires
communication rounds; here the topology IS the access structure.

## consensus

proof of value := validators prove their fibration has geometric quality

- spectral gap ∈ [1/√2, 2√2] (tsirelson bounds from quantum info)
- selection by spectral centrality using the fiedler vector
  (second eigenvector of laplacian measures connectivity, not capital)
- harmonic consensus: hodge decomposition separates
  agreement (ker Δ) from gauge freedom (im δ) from noise (im δ*)

## three-layer state

the "dual state" is actually three layers, matching the hardness hierarchy:

- **Layer 3 (homotopy):** credential fibration, homotopy class membership,
  key rotation within class. lives in the wallet, never leaves.
- **Layer 2 (lattice/CVP):** cochain commitments, spectral invariants,
  hodge projections. verified by oracle, stored as HashStalk.
- **Layer 1 (hash projection):** block headers, key image set, chain tip,
  SHA256 audit trail. stored by node, publicly verifiable.

SheafState is the bus that connects all three. AccountState adds
sovereignty semantics (identity, connections, rotation count) on top.

```
credential (Layer 3)
  ──η₁──→ commitment (Layer 2)
    ──η₂──→ hash (Layer 1)
```

each η is a projection: information is lost, binding is preserved.
Layer 3 data never reaches Layer 1. the node cannot deanonymize.
the oracle cannot forge. the wallet holds the fibration secret.

Hansen & Ghrist (2019). Toward a Spectral Theory of Cellular Sheaves
