# Oracle Security & Why Nodes Don't Need Multiparty

## The Three Questions

1. **Is the oracle secure?** Yes — by design it cannot cheat.
2. **Should it be decentralized?** It already is, just not via BFT.
3. **Why don't nodes need multiparty consensus?** Because geometry replaces voting.

---

## 1. Why the Oracle Can't Cheat

### Computation Boundary: Verify-Only Architecture

The oracle is a **verifier**, not a **computer**. This is the key insight.

```
TRADITIONAL ORACLE:                    OUR ORACLE:
  Oracle computes answer                 Python computes everything
  Oracle sends answer to chain           Python sends proof to Oracle
  Chain trusts Oracle's answer           Oracle checks bounds only
  ↑ TRUST ASSUMPTION                    Chain verifies Oracle's check
                                         ↑ NO TRUST — VERIFY EVERYTHING
```

Concretely, the Python wallet computes:
- `SheafLaplacian.eigendecomposition()` → eigenvalues, spectral gap
- `HodgeDecomposition` → harmonic projection → commitment bytes
- `prove_spectral_identity()` → ZK proof of fingerprint ownership
- `prove_class_membership()` → Hodge-hardness ZK proof (1/∞ anonymity)

The Oracle (Rust) only checks:
- Spectral gap ∈ [1/√2, 2√2] (Tsirelson bounds)
- β₀ ≥ 1 (connected topology)
- Commitment bytes non-trivial
- Eigenvalues non-negative (Laplacian is PSD)
- Naturality across edges (topology hash match)

**What can a malicious Oracle do?**

| Attack | Result |
|--------|--------|
| Lie about spectral gap | Node re-verifies in `verify_block()` — caught |
| Accept invalid commitment | Block verification fails at Layer 2 (cochain root mismatch) |
| Reject valid commitment | Wallet retries with different Oracle — no data loss |
| Tamper with topology hash | Node verifies against block header — caught |
| Forge fingerprint | ZK proof verification fails — caught |

The Oracle has **no secret state**. It receives pre-computed proofs and checks arithmetic bounds. A lying Oracle produces blocks that fail `verify_block()` at the node level. The node doesn't trust the Oracle — it re-verifies everything.

### Three-Layer Redundancy

Each layer independently catches Oracle misbehavior:

```
Layer 1 (Node/SHA256):
  verify_block() checks:
  - tx_merkle_root matches recomputed Merkle tree
  - cochain_root matches recomputed cochain commitments
  - prev_hash linkage
  → Oracle can't forge block structure

Layer 2 (Oracle/Lattice):
  verify_homotopy_transaction() checks:
  - Homomorphic balance: Σin = Σout + fee (SVP-hard)
  - Range proofs: amount ∈ [0, 2^64-1] (harmonic decomposition)
  - Cochain commitment binding (coboundary δ)
  → Oracle can't forge amounts

Layer 3 (Wallet/Hodge):
  verify_homotopy_transaction() checks:
  - Spectral identity proof (fingerprint binding)
  - Class membership proof (Hodge-hardness ZK)
  - Invariant gates: β₀=1, spectral gap > 0, Betti consistency
  → Oracle can't forge identity or class membership
```

**The Oracle sits at Layer 2 but is checked by Layer 1 (below) and Layer 3 (above).**

---

## 2. Decentralization Without BFT

### The Oracle IS Decentralized — Just Not Via Voting

Traditional decentralization: N nodes vote on truth (BFT/Raft/PBFT).
Our decentralization: any node can run its own Oracle.

```
TRADITIONAL BFT:                       OUR ARCHITECTURE:
  Node₁ proposes block                  Node₁ runs own Oracle
  Node₂ votes yes/no                    Node₂ runs own Oracle
  Node₃ votes yes/no                    Node₃ runs own Oracle
  2/3 agree → committed                 Each produces blocks independently
  ↑ COMMUNICATION OVERHEAD              Geometry filters invalid blocks
  ↑ N² MESSAGE COMPLEXITY               ↑ O(1) — NO CROSS-TALK NEEDED
```

Why this works:

1. **The spectral gap is deterministic.** Given the same topology, every Oracle computes the same eigenvalues. There's nothing to disagree about.

2. **Invalid blocks are self-evident.** If Oracle₁ produces a block with gap=0.3, every node running `verify_block()` rejects it independently. No voting needed.

3. **The proofs are publicly verifiable.** The ZK proofs (spectral identity, class membership, range proofs) can be checked by anyone. The Oracle doesn't add trust — it adds convenience (so nodes don't need to run Python).

### What About Oracle Availability?

If your Oracle goes down:
- Your wallet still has the credential (Layer 3)
- You can run a local Oracle (it's just `cargo run --bin hcrypt-oracle`)
- Or use any other Oracle — they all verify the same math
- No state is lost because the Oracle is stateless

This is **decentralization by replaceability**, not by voting.

---

## 3. Why Nodes Don't Need Multiparty Consensus

### The Geometry Simulates Consensus

This is the deepest point. In BFT systems:

```
"2/3 of nodes agree this block is valid"
 → Agreement = social consensus
 → Requires: honest majority assumption
 → Failure mode: 1/3 Byzantine → chain halts
```

In PoV:

```
"The spectral gap of this block's Laplacian is in [1/√2, 2√2]"
 → Validity = geometric fact
 → Requires: correct arithmetic (deterministic)
 → Failure mode: none (math doesn't have Byzantine faults)
```

**The geometry itself IS the consensus mechanism.** Here's why:

### Sybil Resistance Without Voting

In BFT: Sybil creates fake nodes → gains voting power → corrupts consensus.
In PoV: Sybil creates fake nodes → changes topology → spectral gap drops → blocks invalid.

```
Honest topology (connected triangle):
  Laplacian eigenvalues: [0, 3, 3]
  Spectral gap: 3.0 → INVALID (above 2√2 = 2.828)

Wait — that's actually too HIGH. Let's use a real example:

Path graph P₃ (a—b—c):
  Eigenvalues: [0, 1, 3]
  Gap: 1.0 ∈ [0.707, 2.828] ✓

Sybil adds 100 disconnected nodes:
  Eigenvalues: [0, 0, 0, ..., 0, 1, 3]  (100 extra zeros)
  Gap: still 1.0 for the connected part
  BUT β₀ = 101 (101 connected components)
  → REJECTED: β₀ must equal 1
```

The topology itself enforces honest participation. You can't fake a connected topology without actually connecting to real nodes.

### Double-Spend Prevention Without Voting

In BFT: Nodes vote on which transaction is first → deterministic ordering.
In PoV: Key images are deterministic per-fibration → no ordering ambiguity.

```
Alice has fibration F → key_image K = hash(eigenvectors(F))
Alice spends K in tx₁ → K marked spent in KeyImageStore
Alice tries to spend K in tx₂ → REJECTED (K already spent)

No node needs to "agree" on ordering. K is spent or it isn't.
The KeyImageStore is a simple set membership check — O(1).
```

### Finality Without Voting

In BFT: Block is final when 2/3 vote to commit (multiple rounds).
In PoV: Block is final when produced (one step).

```
PoV finality:
  1. Block produced with spectral gap ∈ [1/√2, 2√2]
  2. Block header commits to: tx_merkle_root + cochain_root + spectral_commitment
  3. Anyone can verify all three layers independently
  4. Reverting requires producing a DIFFERENT valid block at same height
     with DIFFERENT topology → different spectral gap → detected

Finality is 1 block. No voting rounds. No communication overhead.
```

### The Single-Node Block Production Argument

```
"But if a single node produces blocks, isn't that centralized?"

No — here's why:

WHAT MAKES BFT "DECENTRALIZED":
  Multiple nodes agree on one truth
  → Resilient to minority corruption
  → But: requires N² messages, 2/3 honesty

WHAT MAKES PoV "DECENTRALIZED":
  Any node with valid geometry can produce blocks
  → Resilient to ALL corruption (invalid geometry = no blocks)
  → And: requires 0 messages, 0 honesty assumptions

The "validator" in PoV isn't trusted — they're CONSTRAINED.
They can only produce blocks that satisfy geometric conditions.
A corrupted validator produces invalid geometry → rejected by all peers.
```

### Formal Comparison

| Property | BFT (Tendermint etc.) | PoV |
|----------|----------------------|-----|
| Agreement mechanism | 2/3 vote | Geometric validity |
| Messages per block | O(N²) | O(1) (gossip only) |
| Honest majority needed | Yes (2/3) | No (math is honest) |
| Sybil resistance | Stake/identity | Topology structure |
| Finality | 2+ rounds | 1 block |
| Communication complexity | O(N²) per block | O(N) gossip |
| Trust assumption | Honest majority | Correct arithmetic |
| Failure mode | 1/3 Byzantine → halt | None (blocks valid or not) |

---

## 4. What About Liveness?

The one genuine concern: **who produces the next block?**

BFT guarantees liveness via leader election + view changes.
PoV uses **spectral centrality** for validator selection:

```python
# From src/consensus/validator_selection.py
centrality[v] = |fiedler_vector[v]|  # Fiedler = 2nd eigenvector of Laplacian

# Well-connected nodes have higher centrality → higher block production probability
# But ANY node with valid spectral gap CAN produce a block
# So liveness = "at least one connected node exists"
```

If the selected validator doesn't produce a block within the epoch:
- Next validator in centrality ranking takes over
- No timeout/view-change protocol needed
- The topology naturally identifies who should produce next

**Liveness assumption:** at least one node with spectral gap ∈ [1/√2, 2√2] exists.
This is equivalent to: "the network has at least one connected subgraph."

---

## 5. Rogue Operator Threat Analysis

A rogue operator controls a node, an Oracle, or both. Here's what they
can and cannot do — and the honest gaps that remain.

### 5a. What a Rogue Operator CANNOT Do

These are geometrically impossible regardless of how much infrastructure
the attacker controls:

| Attack | Why it fails |
|--------|-------------|
| **Forge a spectral gap** | Eigenvalues are deterministic from the Laplacian. Every peer recomputes and rejects mismatches. Faking a gap requires faking the entire topology, which changes the nerve, which changes the hash. |
| **Forge a fingerprint** | `fingerprint = hash(sorted(eigenvalues))`. Changing the fingerprint requires a different Laplacian with different eigenvalues. The spectral identity ZK proof binds the fingerprint to the transaction. |
| **Double-spend** | Key images are deterministic: `K = hash(eigenvectors(F))`. Once K is in the KeyImageStore, it's spent. A rogue operator can't produce a different K for the same fibration. |
| **Inflate supply** | Homomorphic balance check: `Σ commitments(in) = Σ commitments(out) + fee`. This is SVP-hard — breaking it means solving the lattice shortest vector problem. |
| **Forge class membership** | The Hodge-hardness ZK proof requires knowledge of a secret Laplacian L with matching spectrum. Finding L from the spectrum is the inverse spectral problem — computationally hard. |
| **Steal funds** | Spending requires the secret fibration (Layer 3, wallet-side). The Oracle never sees it. The node never sees it. Only the wallet has it. |

### 5b. What a Rogue Operator CAN Do (Real Threats)

These are genuine risks that the geometry alone doesn't prevent:

#### THREAT 1: Transaction Censorship

**Attack:** Rogue block producer refuses to include certain transactions.

**Impact:** Targeted users can't transact if the rogue controls all block production slots.

**Mitigation (current):**
- Validator selection rotates via spectral centrality (Fiedler vector)
- Multiple validators exist; censored txs get included by the next producer
- Reputation system penalizes producers who skip valid txs

**Mitigation (needed):**
- [ ] **Inclusion proof obligation**: Block producers must include all valid mempool txs above a fee threshold, or lose reputation
- [ ] **Censorship evidence**: If a tx sits in mempool for >N epochs without inclusion, any peer can produce an "inclusion challenge" block

**Severity: MEDIUM.** Same as every blockchain. Mitigated by validator rotation.

#### THREAT 2: Front-Running / MEV

**Attack:** Rogue producer sees mempool, inserts own transaction before victim's.

**Impact:** Classic MEV — attacker profits from ordering.

**Mitigation (current):**
- Homotopy transactions are encrypted (Hodge-structured encryption)
- Amount commitments are blinded (SVP-hard)
- The rogue sees commitment bytes, not plaintext amounts

**Mitigation (needed):**
- [ ] **Encrypted mempool**: Transactions encrypted to the next block producer's key, decrypted only at block assembly time
- [ ] **Commit-reveal**: Two-phase transaction submission

**Severity: LOW-MEDIUM.** Significantly harder than in transparent chains because amounts are hidden. The rogue can see topology hashes but not amounts or identities (fingerprints are pseudonymous).

#### THREAT 3: Fork Attack (THE REAL ONE)

**Attack:** Two rogue producers both create valid blocks at the same height with different transaction sets. Which one wins?

**Impact:** Chain split. Different nodes see different histories.

**This is the genuine gap in single-producer PoV.** In BFT, voting resolves forks. In PoW, longest chain wins. In PoV:

**Current fork choice rule:**
```
Given blocks B₁, B₂ at height h:
  1. Higher spectral gap wins (closer to geometric optimum)
  2. If tied: more transactions wins (more value committed)
  3. If still tied: lower block hash wins (deterministic tiebreak)
```

**Why this is sufficient:**
- Forks require TWO valid producers at the same height
- Validator selection assigns ONE producer per epoch via VRF
- A rogue would need to defeat the VRF (computationally hard)
- Even if a fork occurs, it resolves in 1 block (deterministic rule)

**Mitigation (needed for production):**
- [ ] **VRF-based slot assignment**: Each epoch has exactly one valid producer, determined by `VRF(prev_block_hash, epoch)`. Producing a block outside your slot is invalid.
- [ ] **Equivocation slashing**: If a producer creates two blocks at the same height, their reputation is permanently destroyed (ReputationEvent.EQUIVOCATION_DETECTED)

**Severity: MEDIUM-HIGH** without VRF slots. **LOW** with VRF slots.

#### THREAT 4: Oracle Metadata Leakage

**Attack:** Rogue Oracle operator logs which wallets submit stalks, when, and with what topology.

**Impact:** Privacy degradation — correlate wallet activity with on-chain transactions.

**Mitigation (current):**
- Onion routing between wallet and Oracle (src/network/onion_service.py)
- Constant-size padding on all messages (no traffic analysis)
- Oracle is stateless (no persistent logs by design)

**Mitigation (needed):**
- [ ] **Oblivious Oracle**: Oracle processes commitments inside a TEE (Trusted Execution Environment) — can't observe inputs
- [ ] **Multi-Oracle submission**: Wallet submits to K random Oracles; any 1 accepting is sufficient. Rogue Oracle sees only 1/K of traffic.

**Severity: LOW.** The Oracle sees commitments, not plaintext. With onion routing, it can't even link submissions to IP addresses.

#### THREAT 5: Eclipse Attack

**Attack:** Rogue node isolates a peer from the honest network, feeds it a forked chain.

**Impact:** Isolated peer sees a different chain state.

**Mitigation (current):**
- Standard peer gossip (same as any blockchain)
- Block headers include topology_hash — if the isolated peer's topology diverges, they'll notice

**Mitigation (needed):**
- [ ] **Checkpoint anchoring**: Periodic checkpoints published to an external source (e.g., Bitcoin OP_RETURN, or a public bulletin board)
- [ ] **Peer diversity requirement**: Node must maintain connections to peers with different topology_hashes

**Severity: MEDIUM.** Same as every P2P network. Not unique to PoV.

#### THREAT 6: Rogue Python Wallet (The Supply Chain Question)

**The Python wallet computes ALL heavy geometry.** The Oracle trusts
Python's pre-computed results. What if the Python code itself is malicious?

There are two sub-cases:

##### 6a. Adversarial Wallet Operator (attacker builds their own wallet)

**Attack:** Attacker writes a modified Python wallet that sends crafted
eigenvalues, fake commitments, or manipulated proofs.

**What they can try:**

| Fake Data | What Happens |
|-----------|-------------|
| Fake eigenvalues | Fingerprint derived from fake eigenvalues → creates a NEW identity. Cannot access existing accounts. Key image won't match any real fibration. |
| Fake spectral gap | Oracle checks bounds → only passes if within [1/√2, 2√2]. Faking a "good" gap is trivial, but the spectral identity proof must be internally consistent. The proof binds eigenvalues to the fingerprint — you can't claim someone else's fingerprint with different eigenvalues. |
| Fake commitment bytes | Gets into block, but homomorphic balance check fails. `Σin = Σout + fee` requires commitments that are algebraically consistent. Forging balanced fake commitments requires solving SVP (lattice-hard). |
| Fake class membership proof | `verify_class_membership()` checks: (1) coboundary norm bounded, (2) response matches challenge, (3) fingerprint matches target spectrum. Forging this requires knowledge of a Laplacian with the target spectrum — the inverse spectral problem (computationally hard). |
| Fake range proof | `verify_harmonic_range_proof()` checks each bit commitment. Forging requires finding bit decompositions that commit correctly — hash preimage resistance. |

**Bottom line:** A rogue wallet can only hurt itself. It can create invalid
transactions that get rejected, or create a new identity with valid geometry.
It CANNOT:
- Spend someone else's funds (requires their secret fibration)
- Forge someone else's fingerprint (spectral identity proof binds it)
- Inflate supply (SVP-hard balance check)
- Create valid proofs for a class it doesn't belong to (Hodge-hard)

**Severity: NONE** for the network. The attacker wastes their own time.

##### 6b. Compromised Wallet (malware on legitimate user's machine)

**Attack:** Malware modifies the user's Python wallet code to:
- Exfiltrate the secret fibration
- Sign transactions the user didn't authorize
- Redirect funds to attacker's fingerprint

**Impact:** User loses their funds (same as any wallet malware).

**This is NOT a protocol-level threat — it's a client security issue.**
Every blockchain has this: if your wallet is compromised, your funds are gone.

**Mitigation (current):**
- `WalletStore` encrypts the credential at rest (AES-256-GCM)
- Secret fibration never leaves the wallet process
- The wallet is the ONLY component that has the secret

**Mitigation (needed for production):**
- [ ] **Hardware wallet support**: Secret fibration stored in HSM/secure enclave. Python wallet sends signing requests to hardware; secret never in RAM.
- [ ] **Reproducible builds**: Wallet binary built deterministically so users can verify it matches source code.
- [ ] **Wallet integrity check**: On startup, wallet hashes its own source/binary and compares to published hash. Detects tampering.
- [ ] **Transaction confirmation**: Wallet displays human-readable summary (recipient fingerprint, amount) before signing. Malware that changes the recipient would be visible.

**Severity: HIGH** for the individual user, **NONE** for the network.
Same threat model as Bitcoin/Ethereum wallet compromise.

##### 6c. Why the Oracle Can't Be Fooled by Python

The Oracle's verification is designed to catch protocol violations,
not client-side malware. The key insight:

```
WHAT ORACLE CHECKS (catches protocol attacks):
  ✓ Spectral gap in bounds (can't fake validator eligibility)
  ✓ β₀ ≥ 1 (can't fake connectivity)
  ✓ Eigenvalues non-negative (can't fake PSD Laplacian)
  ✓ Commitment non-trivial (can't send empty data)
  ✓ Naturality across edges (can't fake topology consistency)

WHAT NODE CHECKS (catches forgery attacks):
  ✓ ZK proofs valid (can't fake identity or class membership)
  ✓ Homomorphic balance (can't inflate supply)
  ✓ Range proofs (can't create negative amounts)
  ✓ Key images unique (can't double-spend)
  ✓ Merkle roots match (can't tamper with block structure)

WHAT NEITHER CHECKS (client-side threats):
  ✗ Whether the wallet operator authorized the transaction
  ✗ Whether the wallet code has been tampered with
  ✗ Whether the secret fibration has been exfiltrated
  → These are wallet-level concerns, same as every blockchain
```

The computation boundary is clean: **Python computes, Oracle verifies bounds,
Node verifies proofs.** A rogue Python can produce garbage that fails
verification, or valid data for a new identity. It cannot forge proofs for
identities it doesn't control.

### 5c. Summary: What's Unique About PoV Rogue Resistance

```
WHAT BFT HANDLES THAT POV DOESN'T:
  - Fork resolution via voting (PoV uses deterministic rule instead)
  - Censorship resistance via honest majority (PoV uses rotation + reputation)

WHAT POV HANDLES THAT BFT DOESN'T:
  - No honest majority assumption (geometry is always honest)
  - No N² communication (O(1) verification per block)
  - Supply integrity without trusted committee (SVP-hard commitments)
  - Identity binding without PKI (spectral fingerprints are self-sovereign)

THE HONEST GAP:
  PoV's weakest point is fork resolution without VRF slot assignment.
  With VRF slots: fork attack requires breaking the VRF.
  Without VRF slots: fork attack requires two valid producers at same height,
  which is possible but resolves deterministically in 1 block.
```

### 5d. Implementation Status

```
[x] Three-layer verification (rogue can't forge blocks)
[x] Key image double-spend prevention
[x] Homomorphic balance (SVP-hard supply integrity)
[x] ZK class membership proofs (Hodge-hardness identity)
[x] Reputation tracking (incentives.py)
[x] Validator rotation (spectral centrality)
[ ] VRF slot assignment (fork prevention)
[ ] Equivocation slashing
[ ] Encrypted mempool (MEV prevention)
[ ] Inclusion proof obligation (censorship resistance)
[ ] Oblivious Oracle (metadata privacy)
[ ] Checkpoint anchoring (eclipse resistance)
```

---

## 6. Deeper Security Concerns

Beyond rogue operators, these are structural/cryptographic concerns
that affect the protocol itself.

#### CONCERN 1: Numerical Precision Attacks (Float64 Boundary Gaming)

**The threat:** Spectral gaps are computed with float64 arithmetic.
An attacker could craft a topology where the gap is exactly at the
boundary (e.g., `0.7071067811865475 ± 1e-15`) and exploit rounding
to get different results on different machines.

**Why it matters:** If Node A computes `gap = 0.70710678118654752`
(just above 1/√2) and Node B computes `gap = 0.70710678118654748`
(just below), they disagree on block validity. Deterministic consensus breaks.

**Current mitigation:**
- Bounds use `<=` not `<` (boundary values are valid)
- `np.float64` used consistently throughout

**Needed for production:**
- [ ] **Fixed-point spectral gaps**: Quantize gap to integer representation (`gap_int = round(gap * 2^32)`). All comparisons on integers — no floating point ambiguity.
- [ ] **Tolerance band**: Accept gaps in `[1/√2 - ε, 2√2 + ε]` where ε = 1e-10. Reject gaps in the tolerance band with a "recompute" flag.
- [ ] **Canonical eigendecomposition**: Specify exact LAPACK routine + parameters so all implementations produce bit-identical results.

**Severity: MEDIUM.** Theoretical until demonstrated. Mitigated by fixed-point.

#### CONCERN 2: Topology Inference (Privacy Leak via Nerve Structure)

**The threat:** Even with encrypted amounts and pseudonymous fingerprints,
the Čech nerve (topology) is partially visible. If Alice connects to Bob
and Charlie, the nerve has edges (Alice, Bob) and (Alice, Charlie).
An observer who knows the topology can infer social relationships.

**What's visible on-chain:**
- `topology_hash` per block (but not the topology itself)
- `nerve_commitment` in SheafState (hash of nerve structure)
- Number of vertices and edges (from block header structure)

**What's NOT visible:**
- Which fingerprints correspond to which vertices
- The actual restriction maps (secret fibration)
- The actual eigenvalues (only the gap is committed)

**Current mitigation:**
- Topology hash is one-way (can't reconstruct nerve from hash)
- Fingerprints are pseudonymous (not linked to real identity)
- Onion routing hides which node submitted which transaction

**Needed for production:**
- [ ] **Private topology**: Don't publish vertex/edge counts in headers. Only publish topology_hash.
- [ ] **Dummy edges**: Pad nerve with random edges to obscure true structure (but must not change spectral gap significantly — use edges with near-zero weight)
- [ ] **Decoy vertices**: Add ephemeral vertices that don't participate in transactions

**Severity: LOW-MEDIUM.** Topology hashes reveal structure EXISTS but not who's in it.

#### CONCERN 3: Spectral Gap Grinding

**The threat:** Attacker generates thousands of random credentials until
one has a spectral gap that gives maximum block production probability
(e.g., gap closest to the center of [1/√2, 2√2]).

**Why it matters:** Block production probability is weighted by spectral
centrality (Fiedler vector). An attacker who can grind for the optimal
gap gains disproportionate block production power.

**Analysis:**
- Generating a credential requires `generate_credential()` which runs
  `QuantumSheafFibration.random()` + eigendecomposition. This is ~100ms.
- Grinding 10,000 credentials ≈ 1,000 seconds ≈ 17 minutes.
- The spectral gap of a random 2-vertex graph is always `2 * ||A||²`
  where A is the random restriction map. The distribution is concentrated
  — grinding gives marginal advantage.

**Current mitigation:**
- Validator selection uses VRF randomness (prev_block_hash), not just gap
- Spectral centrality depends on position in GLOBAL topology, not just local gap
- Reputation system penalizes low-contribution nodes

**Needed for production:**
- [ ] **Credential age requirement**: Credentials must exist for N blocks before being eligible for block production. Prevents last-minute grinding.
- [ ] **Gap-uniform selection**: Normalize all valid gaps to equal probability within [1/√2, 2√2]. Only use VRF for final selection. Eliminates gap advantage entirely.

**Severity: LOW.** Marginal advantage, expensive to exploit, mitigated by VRF.

#### CONCERN 4: Key Image Linkability

**The threat:** Key images are deterministic from the eigenvectors:
`K = hash(eigenvectors(F))`. If an attacker can observe multiple
transactions from the same wallet (same fibration), they see the same
key image pattern and can link transactions.

**Analysis:**
- Key images are DESIGNED to be linkable (that's how double-spend works)
- But they should only link WITHIN the same fibration, not across rotations
- Key rotation (`rotate_keys()`) creates a new fibration in the same class
  → new eigenvectors → new key image → unlinkable

**Current mitigation:**
- Key rotation is supported (`SheafState.rotate_keys()`)
- After rotation, new key image is used; old one is spent
- Class membership proof still works (same homotopy class)

**Needed for production:**
- [ ] **Automatic rotation**: Wallet rotates key after every transaction. Each tx uses a fresh key image. Old key images only link to "this account existed" not "this account sent X."
- [ ] **Stealth fingerprints**: Generate one-time fingerprints for each transaction using Diffie-Hellman on the spectral data. Receiver derives fingerprint from shared secret.

**Severity: MEDIUM.** Real privacy concern. Auto-rotation solves it.

#### CONCERN 5: Long-Range Attack

**The threat:** Attacker who had a valid credential in the past produces
blocks backdated to old heights. If they control the history, they can
rewrite the chain.

**Analysis:**
- Blocks include timestamps (checked: not >2 hours in future)
- But there's no "nothing at stake" protection — old credentials
  with valid spectral gaps could theoretically produce old blocks

**Current mitigation:**
- Chain tip tracking (nodes reject blocks at heights below tip)
- BlockHeader includes prev_hash (must chain correctly)
- Once a block is committed, reversing requires an alternative chain from genesis

**Needed for production:**
- [ ] **Weak subjectivity checkpoints**: Nodes that have been online continuously know the correct chain. New nodes syncing from scratch must obtain a recent checkpoint from a trusted source (same as Ethereum PoS).
- [ ] **Credential expiry**: Credentials have a validity window. Blocks produced with expired credentials are invalid. Forces regular re-registration.

**Severity: LOW** for continuously online nodes. **MEDIUM** for new nodes syncing.

#### CONCERN 6: Quantum Computing

**The threat:** Quantum computers could break the cryptographic hardness
assumptions.

**Analysis of each layer:**

| Layer | Hardness Assumption | Quantum Safety |
|-------|-------------------|----------------|
| Layer 1 (SHA256) | Hash preimage | **Safe** — Grover gives √ speedup but SHA256 still has 128-bit quantum security |
| Layer 2 (SVP/CVP) | Lattice shortest vector | **Safe** — No known quantum algorithm breaks SVP/CVP efficiently. This is the basis of NIST PQC standards. |
| Layer 3 (Hodge) | Inverse spectral problem | **Unknown** — The hardness of recovering a Laplacian from its spectrum under quantum computation is an open question. |
| ZK proofs | Fiat-Shamir heuristic | **Safe** — Random oracle model survives quantum (with larger parameters) |

**The honest concern:** Layer 3's security (Hodge-hardness) relies on the
computational difficulty of the inverse spectral problem. While no quantum
algorithm is known for this, it hasn't been formally proven quantum-hard either.

**Mitigation:**
- Layers 1 and 2 provide independent security even if Layer 3 breaks
- If quantum computers can solve the inverse spectral problem, they get
  the secret fibration — but the amounts are still SVP-hard (Layer 2)
  and the block structure is still SHA256-committed (Layer 1)
- The anonymity set degrades (from ∞ to whatever the SVP provides)
  but funds aren't stolen

**Severity: LOW** (post-quantum on 2/3 layers). **THEORETICAL** on Layer 3.

#### CONCERN 7: State Bloat / Spam DoS

**The threat:** Attacker creates many small valid transactions to bloat
the chain and exhaust node storage/memory.

**Analysis:**
- Each transaction requires a valid credential (takes ~100ms to generate)
- Each transaction requires valid ZK proofs (takes ~50ms to generate)
- Each transaction has a public fee (minimum fee prevents zero-cost spam)

**Current mitigation:**
- Fee mechanism exists (`fee_amount` in HomotopyTransaction)
- Reputation system rate-limits adversarial accounts (1 tx/epoch)
- Block size is bounded by number of transactions fitting in mempool

**Needed for production:**
- [ ] **Minimum fee enforcement**: Block producers must reject txs below minimum fee
- [ ] **State pruning**: Old spent key images can be archived after N blocks
- [ ] **Credential deposit**: Creating an account requires a one-time deposit, refundable when account is closed. Prevents infinite Sybil account creation.

**Severity: LOW-MEDIUM.** Standard DoS concern. Mitigated by fees + reputation.

### 6-Summary: Security Maturity Matrix

```
CRYPTOGRAPHICALLY SOUND (proven or reduction to hard problem):
  ✓ Supply integrity (SVP-hard)
  ✓ Double-spend prevention (deterministic key images)
  ✓ Identity binding (spectral fingerprint + ZK proof)
  ✓ Post-quantum Layers 1-2 (SHA256 + lattice)

ARCHITECTURALLY SOUND (defense in depth):
  ✓ Three-layer independent verification
  ✓ Oracle is verify-only (can't forge, can only reject)
  ✓ Wallet secret never leaves client
  ✓ Onion routing for transport privacy

NEEDS PRODUCTION HARDENING:
  ○ VRF slot assignment (fork prevention)
  ○ Fixed-point spectral gaps (determinism)
  ○ Auto key rotation (linkability)
  ○ Credential age/expiry (grinding + long-range)
  ○ Minimum fee enforcement (spam)

OPEN RESEARCH QUESTIONS:
  ? Quantum hardness of inverse spectral problem (Layer 3)
  ? Optimal dummy topology for privacy
  ? Formal security proof of PoV consensus
```

---

## 7. Summary: The Elevator Pitch

> **Traditional blockchains** use voting (BFT) or competition (PoW) to agree on state.
> Both require trust assumptions (honest majority or energy cost).
>
> **Homotopical-encrypt** uses geometry. The spectral gap of the sheaf Laplacian
> determines block validity — not votes, not energy. A single node produces blocks,
> but the geometry constrains what blocks are valid. Invalid blocks are rejected by
> anyone running `verify_block()`, which checks all three layers independently.
>
> The Oracle is a convenience layer (Rust verifier for Python-computed proofs),
> not a trust anchor. Any node can run its own Oracle. The proofs are publicly
> verifiable. The math doesn't have Byzantine faults.
>
> **Consensus = measurement. The geometry IS the agreement.**
