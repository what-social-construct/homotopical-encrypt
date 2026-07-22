# Archived Consensus Architecture

> Historical design snapshot. This file predates the separation between
> proof-carrying validity, authenticated weighted quorum certificates, and a
> complete consensus/finality protocol. In particular, its spectral-stake and
> spectral-finality analogies are not current claims.

## Three-Layer Sheaf-Petri Architecture

Our consensus follows the three-layer pattern from Cushing et al. (2023)
but replaces discrete Petri net tokens with continuous sheaf stalks on a
simplicial complex (Čech nerve). This gives us the same workflow
coordination power as Petri nets PLUS the geometric reasoning that makes
PoV work.

```
┌─────────────────────────────────────────────────────────────────┐
│                  LAYER 3: OFF-CHAIN (Python)                     │
│                                                                   │
│  Credential Generation    Hodge Projection    Geodesic ZK Proof  │
│  ─────────────────────    ────────────────    ─────────────────  │
│  simplicial complex K     ker Δ_F extraction  γ(t) = V·exp(tΩ)  │
│  sheaf Laplacian Δ_F      harmonic stalks     Fiat-Shamir Σ     │
│  Betti numbers β₀,β₁     quantize → fixed    commitment chain   │
│                                                                   │
│  credential.py  sheaf_laplacian.py  homotopical_zkp.py           │
│                           │                                       │
│                    Oracle Bridge                                  │
│                    (stalk_bridge.rs)                              │
│                           ↓                                       │
├───────────────────────────────────────────────────────────────────┤
│                LAYER 2: COORDINATION (Rust + Python)              │
│                                                                   │
│  VRF Slot Assignment     Coalition Formation    Topos Judgment   │
│  ────────────────────    ───────────────────    ──────────────   │
│  HMAC-SHA256(key,epoch)  Čech nerve N(V)        Heyting Ω        │
│  score < centrality      Grassmann d_Gr         VALID/UNDET/INV  │
│  equivocation detect     joint subspace test    estimate safety  │
│                                                                   │
│  vrf.rs / vrf_slots.py   coalitions.py          topos.rs/py      │
│  validator_selection.py   coherence.py                            │
│                           │                                       │
│                    Block Production                               │
│                    (pov.rs → main.rs)                             │
│                           ↓                                       │
├───────────────────────────────────────────────────────────────────┤
│                  LAYER 1: ON-CHAIN (Rust)                         │
│                                                                   │
│  Block Storage           Sheaf State            Key Images       │
│  ─────────────           ───────────            ──────────       │
│  blocks.rs (RocksDB)     sheaf_store.rs         keyimages.rs     │
│  BlockSection (3-tier)   C⁰ public stalks       double-spend     │
│  ChainSectionBundle      C¹ ZK cochains         prevention       │
│                          C² commitments                           │
│                                                                   │
│  block.py/block_section  sheaf_state.py         key_image.py     │
│  chain_store.py          state.rs                                │
└─────────────────────────────────────────────────────────────────┘
```

## Petri Net → Sheaf Correspondence

The paper (Swan et al. 2025, Table 2) describes blockchain Petri nets
with places, transitions, tokens, and markings. Our implementation
maps each concept to a sheaf-theoretic equivalent:

| Petri Net Concept | Our Sheaf Equivalent | Why It's Better |
|---|---|---|
| **Places** (vertices) | Validators (0-simplices in N(V)) | Same |
| **Transitions** | Block production + consensus actions | Same |
| **Tokens** (discrete) | **Stalks** (continuous subspaces on Gr(k,n)) | Continuous ⇒ can measure distance, project, decompose |
| **Markings** (token config) | **Sheaf section** (global assignment of stalks) | Coherence condition: restriction maps must agree on overlaps |
| **Firing** (token transfer) | **VRF slot + PoV proof** | Firing = producing a block with geometric proof |
| **Pre-arcs** (input places) | Parent block + Oracle commitment | What you need to produce |
| **Post-arcs** (output places) | New block + updated sheaf state | What production creates |
| **Colored tokens** | **Stalk contexts** (Public, Private, ZK) | Our 3-layer stalk typing |
| **Token balances** | **Spectral gap** λ₁(Δ_F) ∈ [1/√2, 2√2] | Continuous "balance" that must stay in bounds |

### Key Advantage: Sheaf Laplacian as "Token Balance"

In Petri nets, the marking M(p) = number of tokens at place p.
In our system, the "marking" is the spectral gap λ₁(Δ_F) of the
sheaf Laplacian — a continuous invariant that measures how coherent
the network is. This is strictly richer:

- **Zero tokens ↔ disconnected (β₀ > 1)**: no coherent section exists
- **Sufficient tokens ↔ spectral gap in bounds**: consensus possible
- **Token transfer ↔ parallel transport**: stalks move along edges
  via restriction maps, preserving geometric structure

## Consensus Flow (per epoch)

```
                    ┌──────────────┐
                    │  Epoch Start  │
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │  VRF Evaluate │  vrf.rs: HMAC-SHA256(key, prev_hash || epoch)
                    │  score < thr? │
                    └──────┬───────┘
                      NO   │   YES
                    ┌──────┘   └──────────────┐
                    │                          │
              (sleep until                ┌────▼──────────┐
               next epoch)               │ Drain Mempool  │
                                         │ Load Oracle    │
                                         └────┬──────────┘
                                              │
                                         ┌────▼──────────┐
                                         │ PoV Produce    │  pov.rs
                                         │ spectral gap   │  √2 bounds
                                         │ cochain root   │  Σ δ(txᵢ) mod q
                                         └────┬──────────┘
                                              │
                                         ┌────▼──────────┐
                                         │ Self-Verify    │  PoVVerifier
                                         │ Topos Judge    │  Heyting Ω
                                         └────┬──────────┘
                                              │
                                         ┌────▼──────────┐
                                         │ Store Block    │  blocks.rs
                                         │ Mark KeyImages │  keyimages.rs
                                         │ Update Sheaf   │  sheaf_store.rs
                                         └────┬──────────┘
                                              │
                                         ┌────▼──────────┐
                                         │ Broadcast P2P  │  transport.rs
                                         └───────────────┘
```

## Block Validation (receivers)

```
Receive Block
  │
  ├─ Gate 0: Deserialize block
  ├─ Gate 1: Spectral gap valid (Oracle-attested √2 bounds)
  ├─ Gate 2: Parent hash linkage (chain coherence)
  ├─ Gate 3: Cochain root recomputation (Σ δ(txᵢ) matches)
  ├─ Gate 4: VRF slot verification (epoch, identity, non-trivial)
  ├─ Gate 5: Equivocation check (no double-production)
  ├─ Gate 6: Key image double-spend check (O(1) per tx)
  │
  └─ All pass → Store + relay
```

## Coalition Consensus (multi-validator)

For networks with >1 validator, the coalition structure determines
which subsets can jointly propose state updates:

```
Čech Nerve N(V):
  vertices = validators
  edge (i,j) iff d_Gr(stalk_i, stalk_j) < threshold

Semitopology T:
  T = { S ⊆ V : joint_coherence(S) > 0.5 }
  NOTE: S₁ ∈ T and S₂ ∈ T does NOT imply S₁ ∩ S₂ ∈ T
  (validators can cooperate pairwise but not jointly)

Consensus requirement:
  The producing coalition must cover β₀ = 1 connected component
  → ensures agreement across the whole network
```

## Paper Mapping (Swan et al. 2025, Tables 1-3)

### Table 1 Categorical Primitives → Our Implementation

| # | Paper Primitive | Our Module | Status |
|---|---|---|---|
| 1 | Topos consensus (Lambert) | `topos.py`, `topos.rs` | ✅ |
| 2 | Proofchains as Sheaves (Murfet) | `coherence.py` (CechNerve) | ✅ |
| 3 | Blockchain cohomology (Meldman) | `spectral_bounds.py`, Betti | ✅ |
| 4 | Semitopology coalitions (Gabbay) | `coalitions.py` | ✅ NEW |
| 5 | UTxO blockchain algebra (Gabbay) | `homotopy_transaction.py` | ⚠️ Partial |
| 6 | Resource convertibility (Nester) | `block_section.py` | ⚠️ Partial |
| 10 | Mining group theory (Zhao) | VRF + validator selection | ✅ |
| 11 | Escrows as optics (Genovese) | — | ❌ Future |
| 12 | Persistent homology (Abay) | `persistence.py` | ✅ |

### Table 3 Higher Categorical → Our Implementation

| # | Paper Advance | Our Module | Status |
|---|---|---|---|
| 1 | HoTT Blockchains | Sheaf Laplacian + type system | ✅ Core |
| 2 | Computad Petri net Ledgers | 3-layer sheaf-Petri architecture | ✅ |
| 3 | Coregulator DAOs | `coregulator.py` | ⚠️ Stub |
| 4 | Galois cohomology ZKPs | `geodesic_zkp.rs` + `homotopical_zkp.py` | ✅ |

## Economic Token Layer

Following Cushing et al.'s "economy tokens" (e-tokens), our system
modulates incentives through three mechanisms:

1. **Spectral stake**: Your credential's spectral gap IS your stake.
   Better geometry → higher centrality → more block production slots.

2. **Treasury rewards**: `treasury.py` distributes block rewards
   proportional to harmonic weight (contribution to consensus).

3. **Slashing**: Equivocation evidence (`EquivocationTracker`) triggers
   stake loss — your credential gets blacklisted via key images.

These map to the Petri net token dynamics:
- **Accumulation**: Oracle proofs add "tokens" (spectral quality)
- **Firing**: Block production consumes a VRF slot
- **Transfer**: Transaction fees flow through the treasury
- **Burning**: Slashing destroys the credential (key image spent)

## File Map

```
src/consensus/
  ├── coalitions.py        Semitopological coalitions (Gabbay)
  ├── coherence.py         Čech nerve + β₀ check
  ├── coregulator.py       Memory evolutive system (stub)
  ├── invariant_validator.py  Pre-consensus invariant checks
  ├── topos.py             Heyting 3-valued logic
  ├── validator_selection.py  Plücker centrality (Grassmann)
  └── vrf_slots.py         VRF slot assignment (Python)

rust/node/src/consensus/
  ├── mod.rs               Module exports
  ├── pov.rs               Proof of Value producer + verifier
  ├── topos.rs             Heyting algebra (Rust)
  └── vrf.rs               VRF slot assignment (Rust)
```
