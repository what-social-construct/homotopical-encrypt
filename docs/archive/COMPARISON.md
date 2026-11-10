# Archived Categorical Comparison: HOMOTOPICAL_ENCRYPT vs Privacy Chains

> Historical comparison notebook. It preserves useful questions and working
> tables, but its spectral-stake, global-state-section, unique-message-binding,
> and end-to-end security claims are not current. Do not cite it as a protocol
> or theorem surface.

## Why This Comparison is Categorical 

Every privacy chain makes the same promise: "transactions are private."
This document compares the mathematical objects of Homotopical Encrypt and other privacy chains.

---

## The Core Distinction: Protocol Objects

```
Zcash (SNARK-based):
    Credentials   := note tuples (value, pk, rcm, ρ) ∈ 𝔽_p⁴
    State         := Merkle tree of note commitments (set-theoretic)
    Commitments   := Pedersen C = v·G + r·H on Jubjub curve E(𝔽_p)
    Privacy       := circuit satisfiability — "∃ w : C(x,w) = 0"
    Encryption    := AEAD (symmetric, no algebraic structure)
    Verification  := bilinear pairing check e(A,B) = e(C,D)
    Hardness      := ECDL on E(𝔽_p) — broken by Shor
    Hash          := Poseidon (SNARK-friendly, exists for circuit efficiency)
    Logic         := Boolean {valid, invalid}
    Trust         := trusted setup ceremony (Groth16) or recursive (Halo2)

Monero (Ring-signature-based):
    Credentials   := Ed25519 keypairs (x, xG) ∈ ℤ_ℓ × E(𝔽_p)
    State         := UTXO set with key images (set-theoretic)
    Commitments   := Pedersen C = v·H + r·G on Ed25519
    Privacy       := combinatorial ambiguity — "one of N keys signed"
    Encryption    := none (amounts hidden by commitment only)
    Verification  := ring equation check (CLSAG)
    Hardness      := ECDL on Ed25519 — broken by Shor
    Hash          := Keccak-256 (generic, no algebraic role)
    Logic         := Boolean {valid, invalid}
    Trust         := none (transparent)

HOMOTOPICAL_ENCRYPT:
    Credentials   := fibers of a Grothendieck fibration p: E → B
    State         := global sections Γ(X, F_hash) of the hash sheaf
    Commitments   := coboundary δ: C⁰(X, ℤ_q) → C¹(X, ℤ_q), q = 12289
    Privacy       := exact sequence 0 → ker(η) → F_full → F_hash → 0
    Encryption    := projection onto ker(Δ) ⊂ C•(X, F)
    Verification  := Heyting judgment Ω = {Valid, Undetermined, Invalid}
    Hardness      := CVP < Hodge-hardness < homotopical search (all post-quantum)
    Hash          := spectral fingerprint (eigenvalues of Δ — topological invariant)
    Logic         := Heyting 3-valued (subobject classifier of the topos)
    Trust         := none (topological constants)
```

The structural difference: Zcash and Monero use algebraic geometry
as a **proof mechanism** (pairings, discrete log). Their protocol
objects (notes, UTXOs) are set-theoretic — flat tuples with no
geometric structure. HOMOTOPICAL_ENCRYPT's protocol IS a presheaf topos: objects
(fibrations), morphisms (coboundaries), logic (Heyting Ω), and
hardness (CVP on cochain lattices) all live in the same categorical
structure. Security properties are theorems about the topos.

---

## Comparison Table

```
                    Zcash              Monero             HOMOTOPICAL_ENCRYPT
─────────────────────────────────────────────────────────────────────
State model         UTXO               UTXO (RingCT)      Sheaf sections
                    (note commitments) (key images)        Γ(X, F_hash)

Privacy source      zk-SNARK circuit   Ring signatures     Exact sequence
                    (Groth16/Halo2)    (CLSAG, size=16)    0→ker(η)→F_full→F_hash→0

Commitment          Pedersen on        Pedersen on         Cochain commitment
scheme              Jubjub curve       Ed25519             δ(m ∥ r), δ₁∘δ₀ = 0

Hash function       Poseidon           Keccak-256          Spectral fingerprint
                    (SNARK-friendly)   (generic)           (eigenvalues of Δ)

Amount hiding       Homomorphic        Homomorphic         Harmonic projection
                    Pedersen commits   Pedersen commits    π_H: C• → ker(Δ)

Range proofs        Halo2 circuit      Bulletproofs+       Spectral gap ∈ [1/√2, 2√2]
                    (polynomial)       (inner product)     (topological invariant)

ZK proof system     Groth16/Halo2      Borromean rings     Homotopy path witness
                    (arithmetic        (combinatorial)     Path(commit, class)
                    circuits, R1CS)                        inhabited

Proof size          ~200 bytes         ~1.5 KB (ring=16)   Spectral fingerprint
                    (succinct)         (linear in ring)    + Betti numbers (~100 bytes)

Verification        Pairing check      Ring equation       Heyting judgment
                    e(A,B) = e(C,D)    check               Ω = {Valid, Undet, Invalid}

Post-quantum        ❌ (pairings)       ❌ (ECDL)           ✅ (LWE + spectral)
                    Halo2 helps but    Entirely broken     Lattice hardness
                    still ECC-based    by quantum          in ker(Δ)

Double-spend        Nullifier set      Key image set       Key image set
prevention          (hash of note)     (hash of key)       (homotopy-path hash)

Anonymity set       Shielded pool      Ring size (16)      Homotopy class
                    (all notes)        (fixed, small)      (infinite — all ≃ fibrations)

Smart contracts     Limited (Orchard)  None                WASM VM (planned)
                    Zcash doesn't      Monero doesn't      Spectral gas model
                    really do this     do this

Consensus           PoW (→ PoS?)       PoW (RandomX)       PoV (spectral gap)
                    No privacy link    No privacy link     Privacy IS consensus

Trust setup         ❌ Groth16 needs    ✅ None              ✅ None
                    trusted ceremony   (transparent)       (topological constants)
                    (Halo2 fixes this)
```

---

## Object Comparison: SNARKs vs Native Geometry

### Where the Proof Lives

```
SNARK proof object:
    Statement  := arithmetic circuit C: 𝔽_p^n → 𝔽_p^m (R1CS/Plonkish)
    Witness    := field elements w ∈ 𝔽_p^k satisfying C(x,w) = 0
    Commitment := polynomial evaluation on E(𝔽_p) (KZG) or Merkle root (FRI)
    Proof      := group elements π ∈ E(𝔽_p)³ (Groth16) or hash chain (STARK)
    Verifier   := bilinear pairing e: E×E → G_T or hash recomputation

HOMOTOPICAL_ENCRYPT proof object:
    Statement  := homotopy class [F] and spectral fingerprint σ(Δ)
    Witness    := path γ(t) in space of fibrations with matching invariants
    Commitment := coboundary δ(m ∥ r) ∈ C¹(X, ℤ_q)
    Proof      := spectral fingerprint + Betti numbers (topological invariants)
    Verifier   := Heyting judgment on Ω = {Valid, Undetermined, Invalid}
```

The SNARK pipeline requires 6 translations (geometry → field elements →
circuit → polynomial → commitment → pairing). HOMOTOPICAL_ENCRYPT requires 3
(geometry → coboundary → spectral invariants → Heyting judgment).
Geometry is preserved throughout.

### The Translation Tax

SNARK chains need special primitives that exist only for circuit efficiency:
- Poseidon hash (SNARK-friendly, replaces SHA-256)
- Jubjub curve (SNARK-friendly, replaces secp256k1)
- ~100K R1CS constraints per basic transfer

HOMOTOPICAL_ENCRYPT's primitives are native to the geometry:
- Spectral fingerprint IS the hash (topological invariant, not a hash function)
- SO(n) IS the group (no special curve needed)
- Verification = eigenvalue comparison (O(1) after spectral cache)

### When SNARKs Would Help

For arbitrary computation (WASM smart contracts), STARKs (hash-based,
post-quantum, no trusted setup) would be the natural fit — not SNARKs
(pairing-based, quantum-vulnerable). For transfers and privacy, the
native geometry is strictly better.

---

## Deep Dive: Why Not UTXO?

### The Categorical Argument

The system is a **presheaf topos** (CATEGORICAL_ARCHITECTURE.md).
The state model follows from the categorical structure:

```
Layer 4: Subobject classifier Ω = Heyting algebra {Valid, Undet, Invalid}
Layer 6: Chain = colimit of directed diagram
State = Γ(X_accounts, Sheaf valued in |Nerve(HomotopyCategory)|)
```

UTXO is a **set-theoretic** model: state = set of unspent outputs.
The topos gives us something richer:

```
UTXO:    State = { (txid, index, value, script) }
         Transition = consume inputs, create outputs
         Balance = Σ values of UTXOs you can spend

Account: State = { address → balance }
         Transition = debit sender, credit receiver
         Balance = lookup

HOMOTOPICAL_ENCRYPT:  State = Γ(X, F_hash)  (global sections of hash sheaf)
         Transition = δ(tx): coboundary moves value along nerve edges
         Balance = harmonic projection π_H(stalk(account))
```

The HOMOTOPICAL_ENCRYPT state model is **more expressive** than both:
- It captures UTXO-like unlinkability (ephemeral fibers = one-time outputs)
- It captures account-like identity (spectral fingerprint persists)
- It adds topological information (nerve structure, Betti numbers)
- It has a natural privacy model (exact sequence ker(η))

### Heyting vs Boolean: Why This Matters

UTXO and account models use **boolean logic**: transaction valid or not.

HOMOTOPICAL_ENCRYPT uses **Heyting 3-valued logic**: Valid / Undetermined / Invalid.

The `Undetermined` state is not a bug — it's the **boundary zone**
where genuine measurement uncertainty exists (spectral gap near √2
bounds). This is physically meaningful:

- `Valid`: spectral gap solidly in bounds → accept
- `Invalid`: spectral gap solidly out of bounds → reject  
- `Undetermined`: near boundary → request recomputation / more evidence

No other chain has this. Monero and Zcash are boolean: valid or not.
The Heyting semantics give HOMOTOPICAL_ENCRYPT a principled way to handle the
**gray zone** that every real system has but others handle ad-hoc.

---

## vs Monero: Geometric Upgrade

Monero's privacy comes from **combinatorial ambiguity** (ring signatures):
pick N decoy keys, prove one of them is yours. The anonymity set = N.

HOMOTOPICAL_ENCRYPT's privacy comes from **geometric ambiguity** (homotopy class):
prove your fibration is in a homotopy class without revealing which one.
The anonymity set = all fibrations in the class (infinite).

```
Monero ring signature:
    Statement: "one of {K₁, ..., K₁₆} signed this"
    Proof: CLSAG ring signature
    Anonymity: |ring| = 16 (fixed, small)
    Linkability: key images link same-key spends

HOMOTOPICAL_ENCRYPT homotopy proof:
    Statement: "my fibration ∈ [F] for some homotopy class [F]"
    Proof: Path(commitment, [F]) inhabited on SO(n)
    Anonymity: |[F]| = ∞ (all fibrations with same spectrum)
    Linkability: key images link same-identity spends
```

Both prevent double-spending via key images. But Monero's anonymity
is bounded by ring size (currently 16 — known to be attackable with
timing analysis). HOMOTOPICAL_ENCRYPT's anonymity is the entire homotopy class.

**Post-quantum**: Monero is entirely broken by quantum computers
(ECDL on Ed25519). HOMOTOPICAL_ENCRYPT's spectral hardness reduces to LWE,
which is believed quantum-resistant.

---

## vs Zcash: Native vs Bolted-On Geometry

Zcash's pipeline:
```
Note = (value, recipient_key, randomness)
    → Pedersen commitment C = v·G + r·H  (on Jubjub)
    → Nullifier = PRF(nsk, rho)  (Poseidon hash)
    → Merkle path proof  (Poseidon tree)
    → All encoded as R1CS arithmetic circuit
    → Groth16/Halo2 proof  (elliptic curve pairing)
```

HOMOTOPICAL_ENCRYPT's pipeline:
```
Credential = FibrationCredential(topology, restriction_maps, Laplacian)
    → Cochain commitment = δ(m ∥ r)  (coboundary, adjacent composites vanish)
    → Key image = homotopy-path hash of identity
    → Spectral proof  (eigenvalues of Δ)
    → Heyting judgment  (algebraic, no circuit)
```

Zcash translates geometry INTO circuits, then proves circuit satisfiability.
HOMOTOPICAL_ENCRYPT stays IN the geometry and proves geometric facts directly.

**Consequence**: Zcash needs a SNARK-friendly hash (Poseidon) because
generic hashes are expensive in circuits. HOMOTOPICAL_ENCRYPT doesn't need any
special hash because the "hash" IS the spectral fingerprint (eigenvalues
of the Laplacian) — this is a topological invariant, not a hash function.

---

## vs Octra: Encrypted Circles vs Sheaf State

Octra is the closest external comparison for the **confidential state**
shape, rather than for the exact math.

Octra's docs describe a chain/network built around encrypted balance
state, stealth transactions, HFHE, and isolated execution environments
called Circles. In that model, the privacy boundary is an encrypted
execution/storage context: private data stays inside an encrypted
environment, while transactions and proofs update the encrypted state.

Important scope note: Octra's public HFHE docs do not present HFHE as a
standard LWE/RLWE/MLWE construction. They describe hypergraph-based FHE,
gate evaluation by hyperedge operations, redefined lattice/noise-basis
tables, hashed key-sharding, and a security story involving hidden
subgraphs and homological properties. The comparison below therefore treats
HFHE as Octra's own hypergraph construction, not as ordinary LWE-based FHE.

HOMOTOPICAL_ENCRYPT's analogous object is `SheafState`, but the boundary is different:

```
Octra:
    Circle / encrypted balance context
      → encrypted state update
      → proof-heavy spend/decrypt/stealth path
      → node validates encrypted-state transition

HOMOTOPICAL_ENCRYPT:
    SheafState / typed state sheaf
      → private stalk or fibration representative
      → public stalk, cochain commitment, or homotopy shadow
      → hash/proof/oracle artifact
      → Rust verifies and commits state transition
```

The common abstract pattern is:

```
private/confidential state
  → bounded public artifact
  → proof or verifier boundary
  → accepted state transition
```

There is also a useful monoidal analogy. Both systems organize private work
into composable public updates: encrypted state updates in Octra, and
cochain/sheaf-state transitions in HOMOTOPICAL_ENCRYPT. In HOMOTOPICAL_ENCRYPT this is explicit in the
cochain layer: commitments compose by addition, state transitions compose as
HashChain/sheaf morphisms, and public artifacts compress larger private
witnesses into reusable named objects. This is close in spirit to the
compression-monoid viewpoint of "Compression is all you need": useful structure
comes from short composable handles whose expansion carries much richer
semantics. The analogy is structural; it is not a claim that Octra's HFHE
updates and HOMOTOPICAL_ENCRYPT's cochains are the same algebraic construction.

The difference is the semantics of the private state:

| Layer | Octra | HOMOTOPICAL_ENCRYPT |
|---|---|---|
| Confidential state container | Circle / encrypted balance state | `SheafState` with private/public/ZK stalk contexts |
| Privacy mechanism | FHE/HFHE encrypted computation and encrypted balance updates | lossy sheaf projection, Hodge/cochain hardness, homotopy-class ambiguity |
| Public handle | encrypted ciphertext/state blob, stealth metadata, proof material | public stalk, topology hash, cochain root, spectral/hash commitment |
| Heavy proof path | encrypted spend/decrypt/stealth update proofs | spectral/cochain/proximity/oracle/SNARK artifact when needed |
| Runtime boundary | node validates encrypted-state transition | Rust validates canonical bytes, commitments, oracle attestations, and proof artifacts |

So `SheafState` is not an encrypted container in the Octra sense. It is a
typed state sheaf whose private stalks, public stalks, cochains, and proof
artifacts expose only the projections needed for consensus.

This is why HOMOTOPICAL_ENCRYPT does not need the same encrypted boundary Octra uses.
Encryption is still useful for transport, wallet state, onion routing, and
optional private execution, but the consensus-visible privacy boundary is
geometric:

```
private stalk / fibration representative
  → cochain or homotopy shadow
  → hash, proof, or oracle artifact
  → public chain state
```

Useful reference points:
- Octra overview: https://docs.octra.org/
- Octra encrypted balances: https://docs.octra.org/user-docs/encrypting-the-balance
- Octra stealth transactions: https://docs.octra.org/user-docs/stealth-transactions
- HOMOTOPICAL_ENCRYPT implementation hooks: `src/chain/sheaf_state.py`, `src/chain/homotopy_transaction.py`,
  `src/geometry/fiber_bundle.py`, `src/network/onion_service.py`

---

## vs StarkNet/Cairo: Closest Philosophical Cousin

STARKs (Scalable Transparent Arguments of Knowledge) are the closest
to HOMOTOPICAL_ENCRYPT's philosophy:
- No trusted setup (transparent)
- Hash-based (post-quantum friendly)
- Algebraically structured (AIR constraints → polynomial IOPs)

But STARKs still flatten computation into traces and polynomial
constraints. The difference:

```
STARK: execution trace → AIR constraints → FRI commitment → verify
HOMOTOPICAL_ENCRYPT: fibration → coboundary → spectral invariants → Heyting judgment
```

STARKs prove "this computation was executed correctly."
HOMOTOPICAL_ENCRYPT proves "this geometric object has these invariants."

If HOMOTOPICAL_ENCRYPT ever needs to verify arbitrary computation (WASM smart
contracts), STARKs would be the natural fit — they're the only
proof system that doesn't introduce quantum vulnerability.

---

## Deep Dive: Commitment Schemes — The Modular Arithmetic

This is where the LWE connection lives concretely.

### The Three Commitment Paradigms

```
Pedersen (Zcash, Monero):
    C = v·G + r·H        on elliptic curve (Jubjub/Ed25519)
    Binding: discrete log     (broken by quantum — Shor)
    Hiding: discrete log      (broken by quantum — Shor)
    Group: E(𝔽_p)             (elliptic curve group)
    Operations: point addition (homomorphic)

Poseidon hash (Zcash Orchard, StarkNet):
    C = Poseidon(v, r)    over finite field 𝔽_p
    Binding: collision resistance of Poseidon
    Hiding: preimage resistance of Poseidon
    Group: 𝔽_p               (prime field)
    Operations: field arithmetic (SNARK-friendly)

Cochain commitment (HOMOTOPICAL_ENCRYPT):
    C = δ(m ∥ r) mod q    on cochain lattice ℤ_q^n
    Binding: SVP-hard         (post-quantum — lattice)
    Hiding: LWE-hard          (post-quantum — lattice)
    Group: ℤ_q^n              (q-ary lattice, q = 12289)
    Operations: vector addition mod q (homomorphic)
```

### How Cochain Commitments Work (commitment.py)

The system uses q = 12289 (a prime suitable for lattice cryptography,
same class as Kyber/Dilithium parameters).

```python
# From src/crypto/commitment.py:
class CochainCommitment:
    edge_values: np.ndarray   # δ(m ∥ r) mod q — lives in C¹
    topology_hash: bytes      # which complex this is over
    modulus: int = 12289      # q for ℤ_q

    @classmethod
    def commit(cls, message, complex, randomness=None, q=12289):
        # 1. Place message at vertex 0, randomness at other vertices
        # 2. Build 0-cochain c = (m, r₁, r₂, ...)
        # 3. Apply coboundary: δ(c) maps C⁰ → C¹
        # 4. Edge values = δ(c) mod q
        # Result: commitment lives in edge space (C¹), not vertex space (C⁰)
```

**Why this is LWE-hard:**
The coboundary δ with restriction maps A_e gives:
```
    δ(c)_e = A_e · c_j - c_i + noise   (mod q)
```
This IS an LWE instance: given (A_e, A_e·s + e), recover s.
But it's structured LWE — the matrix A_e encodes the sheaf topology,
not random. This is what GEOMETRY.md calls **Hodge-hardness**:
strictly harder than standard LWE because the noise is confined
to im(δ_{k-1}) ⊕ im(δ_k*), giving the adversary LESS information.

### The Homomorphic Property

All three commitment types are homomorphic, but over different groups:

```
Pedersen:    C(a) + C(b) = C(a+b)     in E(𝔽_p)  (point addition)
Poseidon:    NOT homomorphic           (hash, no algebraic structure)
Cochain:     C(a) + C(b) = C(a+b)     in ℤ_q^n   (vector addition mod q)
```

For balance verification:
```python
# From src/proofs/anonymity.py:
def verify_balance(input_commitments, output_commitments, fee_commitment):
    # Check: Σ inputs ≡ Σ outputs + fee  (mod q)
    input_sum = sum(c.edge_values for c in input_commitments) % q
    output_sum = sum(c.edge_values for c in output_commitments) % q
    diff = (input_sum - output_sum) % q
    # diff should be near 0 (mod q) — lattice centered rounding
```

The mod q arithmetic IS the lattice structure. Balance verification
works because δ is linear: δ(a + b) = δ(a) + δ(b). This linearity
is a **lattice homomorphism** — it's not just convenient, it's the
same property that makes LWE-based FHE work.

### Why Not Just Use Standard LWE Commitments?

Standard lattice commitments (like BDLOP) use:
```
    C = A·m + r·G    (mod q)    where A is random
```

HOMOTOPICAL_ENCRYPT's cochain commitment uses:
```
    C = δ(m ∥ r)     (mod q)    where δ encodes topology
```

The difference: δ isn't random — it's the coboundary of a specific
cell complex. This gives you:

1. **Geometric binding**: collisions require finding cycles in
   the complex (topological, not just algebraic)
2. **Hodge structure**: cochains decompose as ker(Δ_k) ⊕ im(δ_{k-1}) ⊕ im(δ_k*)
   (the adversary gets less than standard LWE)
3. **Natural partial opening**: reveal some vertices, keep others
   hidden. The coboundary structure tells you exactly what leaks.
4. **Sheaf consistency**: commitments across edges must satisfy
   naturality (η_e ∘ δ_F = δ_G ∘ η_v) — this is free from the topology

Standard LWE commitments don't have any of this. They're secure but
structureless. Cochain commitments are at least as hard (Hodge-hardness
≥ LWE) and carry geometric information.

### Parameter Comparison

```
                    Zcash (Jubjub)    Kyber (NIST)     HOMOTOPICAL_ENCRYPT
────────────────────────────────────────────────────────────────
Field/modulus       p ≈ 2²⁵⁵          q = 3329         q = 12289
Dimension           1 (scalar)        256 (vector)     512 (vector)
Commitment size     32 bytes (point)  ~800 bytes       variable (edges)
Binding hardness    ECDL              MLWE             SVP on cochains
Hiding hardness     ECDL              MLWE             LWE (Hodge)
Post-quantum        ❌                 ✅                ✅
Homomorphic         ✅ (additive)      ✅ (additive)     ✅ (additive)
Geometric meaning   None              None             Coboundary of m∥r
```

The modulus q = 12289 was chosen because:
- It's prime (needed for ℤ_q to be a field)
- It's in the range validated by crypto/validation.py:
  MIN_MODULUS = 3329 (Kyber-class), MAX_MODULUS = 65537
- It supports NTT (Number Theoretic Transform) for fast polynomial
  multiplication if Ring-LWE optimization is added later

---

## Deep Dive: The Hardness Hierarchy — CVP, LWE, and Beyond

This is the core security argument. See `crypto/hardness.py` for the
proof sketch and `lean/CVP.lean` / `lean/Hardness.lean` for the current
machine-checked formalization.

### The Three-Layer Hardness Stack

Every privacy chain's security reduces to some hard problem:

```
Zcash:     Discrete log on elliptic curves (ECDL)
           → broken by Shor's algorithm (quantum)

Monero:    Discrete log on Ed25519 (ECDL)
           → broken by Shor's algorithm (quantum)

HOMOTOPICAL_ENCRYPT:    Homotopical search > Hodge-hardness > CVP on q-ary lattices
           → ALL layers resist quantum (lattice problems)
```

In the hidden-operator model, HOMOTOPICAL_ENCRYPT has a **strict hardness hierarchy** with
three levels:

```
Level 3: HOMOTOPICAL SEARCH (full break)
    │  Forge a credential in a different fiber of the Grothendieck
    │  fibration that satisfies the same first-order homotopical
    │  properties. Requires an EXPLICIT PATH γ(t) in the space of
    │  fibrations preserving all spectral invariants.
    │
    ▼
Level 2: HODGE-HARDNESS (decrypt a message)
    │  Given b = h + e where h ∈ ker(Δ), e ∈ im(δ) ⊕ im(δ*),
    │  find h without knowing Δ.
    │  This is the concrete problem an attacker faces for decryption.
    │
    ▼
Level 1: LATTICE CVP (the shadow on the wall)
    │  Reduce mod q → cochains form ℤ_q^n lattice.
    │  Projection onto ker(Δ) becomes CVP on harmonic sublattice.
    │  Post-quantum hard: O(2^(n/2)) even with Grover.
    │
    ▼
Level 0: POST-QUANTUM SECURITY (guaranteed floor)
```

**The key insight**: CVP is necessary but NOT sufficient for a break.

An attacker who solves CVP (Level 1) still faces two problems:
1. **Which lattice?** CVP gives you closest vector on a GIVEN lattice,
   but the attacker must determine WHICH sublattice of ℤ_q^n is ker(Δ).
   That requires knowing Δ, which requires the fibration secret.
2. **Which topology?** Even with the right sublattice, the attacker
   needs the nerve complex (topology) and spectral data (eigenvalues)
   to know which lattice to solve CVP on.

### How This Differs from Standard Lattice Crypto

Standard lattice schemes (Kyber, Dilithium, NTRU):
```
    Secret: short vector s
    Public: (A, b = As + e)     where A is RANDOM
    Problem: given (A, b), find s  (this IS the hard problem)
    Break: solve LWE/CVP on the lattice defined by A
```

HOMOTOPICAL_ENCRYPT:
```
    Secret: fibration (parallel transport maps R_{v→e})
    Public: class fingerprint / commitments + b = h + e
    Hidden: operative δ_F and Δ_F derived from the fibration
    Problem: given public data and b, find h ∈ ker(Δ_F)  (this is Hodge-hardness)
    Break: first identify which hidden representative determines ker(Δ_F),
           THEN solve CVP on that sublattice
```

The critical difference: in standard LWE, the attacker KNOWS the
lattice (it's defined by the public matrix A). In HOMOTOPICAL_ENCRYPT, the attacker
doesn't know which lattice to attack — the relevant sublattice ker(Δ)
is determined by the hidden fibration/restriction maps.

```
Standard LWE:    attacker knows the lattice, must find closest vector
                 (one hard problem)

Hodge-hardness:  attacker must identify the hidden lattice/kernel before
                 known-lattice CVP is even the right oracle call
```

### Why Hodge-Hardness ≥ LWE (Formal Reduction)

From `src/crypto/hardness.py`, `lean/CVP.lean`, and `lean/Hardness.lean`:

```
Claim: Breaking HOMOTOPICAL_ENCRYPT is at least as hard as CVP on q-ary lattices.

Proof sketch:
1. Given any CVP instance (basis B, target t), embed it as:
   - Topology X = complete graph on dim(B) vertices
   - Laplacian Δ whose ker(Δ) has basis B
   - Target cochain b = t + noise in im(δ) ⊕ im(δ*)

2. Any algorithm solving Hodge-hardness on this instance
   recovers the closest lattice vector to t in span(B).

3. Therefore: Hodge-hardness ≥ CVP.

Strict inequality:
- CVP oracle is provably insufficient for Hodge-hardness
- CVP can solve closest vector on ANY GIVEN lattice
- CVP CANNOT determine which sublattice of ℤ_q^n is ker(Δ)
- That requires the fibration secret (parallel transport)

Result: CVP < Hodge-hardness < homotopical search
        (strict inequalities)
```

### Comparison: Hardness Across Chains

```
                    Zcash           Monero          HOMOTOPICAL_ENCRYPT
────────────────────────────────────────────────────────────────
Core hard problem   ECDL            ECDL            Hodge-hardness
                    (elliptic       (elliptic       (lattice +
                    curve DL)       curve DL)       topology)

Reduces to          DLP on E(𝔽_p)   DLP on Ed25519  CVP on ℤ_q^n

Quantum status      ❌ Broken        ❌ Broken        ✅ Resistant
                    (Shor)          (Shor)          (no period)

Classical bits      ~128            ~128            ~128 (BKZ)

Quantum bits        ~0 (Shor)       ~0 (Shor)       ~64 (Grover)

Additional          None            None            Topology hidden +
security layers                                     fibration secret +
                                                    homotopy invariance

Attacker must       Solve DLP       Solve DLP       1. Find ker(Δ) in ℤ_q^n
know/solve:         (1 problem)     (1 problem)     2. Solve CVP on it
                                                    3. Reconstruct fibration
                                                    (3 problems, each hard)
```

### The Noise Structure Matters

In standard LWE, the noise e is isotropic Gaussian (fills all dimensions).
In Hodge-hardness, the noise is **structured**:

```
Standard LWE noise:   e ~ Gaussian(0, σI)  (isotropic — all directions)
Hodge noise:          e ∈ im(δ) ⊕ im(δ*)  (confined to δ-complement of ker(Δ))
```

This gives the adversary LESS information, not more:
- Standard LWE: noise fills full space → adversary has n-dimensional search
- Hodge noise: noise confined to (n - dim(ker Δ))-dimensional subspace
  → adversary knows noise is structured, but exploiting this requires
  knowing Δ, which IS the secret

This is why GEOMETRY.md says: "No separate LWE safety net is needed.
The geometric structure is a lattice problem, not a wrapper around one."

---

## Summary: The Algebraic Geometry Advantage

```
┌─────────────────────────────────────────────────────────────────┐
│  SNARK chains: geometry serves the proof system                 │
│  (translate data → circuits → polynomials → verify via curves)  │
│                                                                  │
│  HOMOTOPICAL_ENCRYPT: geometry IS the protocol                               │
│  (data = fibrations, state = sheaf, proof = path, logic = Ω)   │
└─────────────────────────────────────────────────────────────────┘
```

The system doesn't need SNARKs because:
1. The ZK property comes from homotopy path witnessing (native)
2. The commitment scheme is cochain-based (native cochain-complex law)
3. The verification logic is Heyting 3-valued (richer than boolean)
4. The anonymity set is a homotopy class (infinite, not ring-bounded)
5. The hardness reduces to LWE in ker(Δ) (post-quantum)
6. No translation tax — no SNARK-friendly hashes or curves needed

The state model doesn't need UTXO because:
1. State = global sections of a sheaf (categorical colimit)
2. Transitions = coboundaries δ(tx) (preserve balance by linearity)
3. Privacy = exact sequence 0 → ker(η) → F_full → F_hash → 0
4. Identity = spectral fingerprint (persistent across ephemeral outputs)
5. Unlinkability = ephemeral fibers (one-time stalks per output)
6. Consensus = Heyting judgment (3-valued, handles boundary zones)

**HOMOTOPICAL_ENCRYPT is a presheaf topos with Heyting subobject classifier.**
Everything else follows from that categorical structure.
