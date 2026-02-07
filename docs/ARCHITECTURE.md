# architecture

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
$HCRYPT:      Address = spectral_fingerprint(fibration)

Your address IS the eigenvalue spectrum of your secret geometry.
- Self-generated (no issuer)
- Quantum-resistant (cochain lattice foundation, reduces to SVP/CVP)
- Key agility (can rotate keys, same identity if same spectrum)
```

### 2. Transaction = Homotopy Proof

```
Traditional:  TX = (from, to, amount, signature)
$HCRYPT:      TX = (fingerprint, key_image, amount_commitment, spectral_proof)

Proves class membership and commits to amount. See homotopy_transaction.py.
- Staged verification: key image → structure → spectral → invariants
- Cochain structure (primitives/cochain.py) underlies the geometry layer
- Block producer embeds transactions into cochains for harmonic projection
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
│                   OFF-CHAIN (Python/Rust)                │
│                   Heavy Computation                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  • Eigenvalue decomposition (O(n³))                     │
│  • Hodge decomposition (expensive)                      │
│  • Laplacian construction                               │
│  • Spectral gap computation                             │
│  • Homotopy equivalence checking                        │
│  • Invariant validation (full suite)                    │
│                                                         │
│  Result: (invariants, hash_trace, proof)                │
│                                                         │
└─────────────────────────────────────────────────────────┘
                          ↓ Submit
┌─────────────────────────────────────────────────────────┐
│                   ORACLE LAYER                          │
│                   Verification Service                   │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  • Accepts computation submissions                       │
│  • Validates hash traces (like chloe HashChain)         │
│  • Aggregates multiple oracle submissions               │
│  • Slashes for invalid results                          │
│  • Publishes verified invariants on-chain               │
│                                                         │
└─────────────────────────────────────────────────────────┘
                          ↓ Publish
┌─────────────────────────────────────────────────────────┐
│                   ON-CHAIN (Rust)                       │
│                   Lightweight Verification               │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  • Verify hash traces                                   │
│  • Check √2 bounds (simple comparison)                  │
│  • Validate spectral fingerprint format                 │
│  • Consensus on block validity                          │
│  • State transitions                                    │
│  • NO eigenvalue computation                            │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Hash Tracing (chloe_protocol Pattern)

### HashChain for Computation Verification

```rust
pub struct ComputationTrace {
    // Initial state
    input_hash: Hash,
    
    // Step-by-step computation trace
    steps: Vec<ComputationStep>,
    
    // Final result
    result_hash: Hash,
}

pub struct ComputationStep {
    operation: String,        // "eigenvalue_decomp", "hodge_project", etc.
    input_hash: Hash,         // Hash of input data
    output_hash: Hash,        // Hash of output data
    timestamp: u64,
    
    // Proof this step is valid
    proof: StepProof,
}

impl ComputationTrace {
    // Verify entire trace is valid
    pub fn verify(&self) -> bool {
        let mut current_hash = self.input_hash;
        
        for step in &self.steps {
            // Verify step connects to previous
            if step.input_hash != current_hash {
                return false;
            }
            
            // Verify step proof
            if !step.proof.verify() {
                return false;
            }
            
            current_hash = step.output_hash;
        }
        
        // Verify final result matches
        self.result_hash == current_hash
    }
}
```

### Example: Spectral Gap Computation Trace

```
Step 1: Build Laplacian
  Input: topology_hash(nerve)
  Operation: "construct_laplacian"
  Output: laplacian_hash(Δ)
  Proof: Δ = δδ* + δ*δ

Step 2: Eigenvalue Decomposition
  Input: laplacian_hash(Δ)
  Operation: "eigendecomp"
  Output: eigenvalues_hash([λ₀, λ₁, ..., λₙ])
  Proof: Δv = λv (spot check a few eigenvectors)

Step 3: Extract Spectral Gap
  Input: eigenvalues_hash([λ₀, λ₁, ..., λₙ])
  Operation: "extract_gap"
  Output: spectral_gap_hash(λ₁)
  Proof: λ₁ is first nonzero eigenvalue

Final: Submit (spectral_gap, trace)
  Chain verifies: trace.verify() && gap ∈ [1/√2, 2√2]
```

---

## Oracle Network Architecture

### Oracle Roles

**Computation Oracles** (Off-chain workers):
- Run Python/Rust computation nodes
- Compute eigenvalues, Hodge, invariants
- Generate hash traces
- Submit to oracle network
- Staked (slashable if wrong)

**Verification Oracles** (Validators):
- Receive computation submissions
- Verify hash traces
- Cross-check multiple submissions
- Slash invalid oracles
- Publish consensus result on-chain

**On-Chain Contracts** (Lightweight):
- Accept oracle submissions
- Verify simple properties (√2 bounds)
- Slash mechanism
- State updates

### Oracle Submission Flow

```
1. User creates transaction
   → Needs spectral proof
   
2. Computation Oracle picks up request
   → Computes eigenvalues off-chain
   → Generates hash trace
   → Signs submission
   
3. Multiple oracles compute independently
   → Each submits (result, trace, signature)
   
4. Verification Oracles check submissions
   → Verify hash traces
   → Check consensus (majority agrees?)
   → Slash outliers
   
5. Consensus result published on-chain
   → Transaction includes verified spectral proof
   → Chain just checks hash + bounds
   → No expensive computation on-chain
```

---

## Rust Architecture


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

## dual state

- SheafState := private transfers (homotopy transactions, key images, mempool)
- AccountState := sovereignty layer (spectral fingerprint identity, connections, key rotation)

Hansen & Ghrist (2019). Toward a Spectral Theory of Cellular Sheaves