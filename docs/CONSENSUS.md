# Proof of Value — Consensus Design

## Value := What Survives Harmonic Projection

The Hodge decomposition splits every cochain into three orthogonal components:

```
C^k = ker(Δ) ⊕ im(δ) ⊕ im(δ*)
       ↑          ↑         ↑
    harmonic    exact    coexact
    (signal)   (noise)   (noise)
```

**Value is the harmonic component.** The part that survives π_H — the Hodge projection onto ker(Δ). Everything in im(δ)⊕im(δ*) is transient noise; everything in ker(Δ) is globally coherent data that persists under all projections.

This gives "Proof of Value" its literal meaning:

```
Transaction value:   amount that survives π_H (harmonic embedding of transfer)
Validator value:     stalk data that survives Grassmann consensus (Karcher projection)
Block value:         cochain root that survives sheaf coherence check (δ ≈ 0)
Network value:       spectral gap that survives √2 bounds (Tsirelson range)
```

A transaction with no harmonic component is pure noise — it carries no coherent information. A validator whose stalk diverges from the consensus subspace contributes no harmonic value. **Proof of Value = prove your contribution has nonzero harmonic component.**

This framing comes directly from `proofs/consensus.py`:
> "ker(Δ) = harmonic cochains = what persists under projection"  
> "Value := the part that survives harmonic measurement"

## Consensus = Measurement

From [ORACLE_SECURITY.md](ORACLE_SECURITY.md):

> **Traditional blockchains** use voting (BFT) or competition (PoW) to agree on state. Both require trust assumptions (honest majority or energy cost).
>
> **Homotopical-encrypt** uses geometry. The spectral gap of the sheaf Laplacian determines block validity — not votes, not energy. The geometry IS the agreement.

This means:
- No honest majority assumption (math is honest)
- No N² communication (O(1) verification per block)
- No voting rounds (validity is a geometric fact)
- Finality in 1 block (deterministic spectral check)

## Architecture

### Sheaf Descent Pattern

The consensus mechanism is a **sheaf descent engine** — the same local-to-global coherence pattern that the cryptographic layer uses, applied to validator agreement:

```
Validators propose blocks
  ↓
Build Čech nerve from stalk overlaps
  ↓
Hodge decomposition (coherent / harmonic / noise)
  ↓
Grassmann consensus via Karcher mean
  ↓
Accept block when geometry valid
```

**H^1 is information, not failure.** Persistent disagreement between validators (β₁ > 0) is a signal that the network is partitioned or under attack — not something to suppress, but something to investigate. The exact component (im(δ)) is correctable by local updates; the coexact component (im(δ*)) is noise to discard; the harmonic component (ker(Δ)) is the consensus signal.

### Slim Oracle

The Oracle stays as a **Rust middleware** — a bridge between Python computation and the Rust node. Per [ORACLE_SECURITY.md](ORACLE_SECURITY.md), the oracle is a **verifier, not a computer**:

```
Python wallet computes:              Oracle (Rust) only checks:
───────────────────────              ────────────────────────
Eigendecomposition                   Spectral gap ∈ [1/√2, 2√2]
Hodge projection → commitment        β₀ ≥ 1 (connected)
ZK spectral identity proof           Commitment bytes non-trivial
ZK class membership proof            Eigenvalues non-negative
                                     Topology hash match
```

The Oracle has **no secret state**. A lying Oracle produces blocks that fail `verify_block()` at the node level. The node re-verifies everything. Each validator runs their own slim oracle.

```
Oracle role:
  ✓ Serialize/deserialize stalks (Python numpy ↔ Rust bytes)
  ✓ Forward spectral proofs from local computation to node
  ✓ Expose HTTP/RPC for wallet interaction
  ✗ NO independent computation authority
  ✗ NO trusted worker consensus
```

## Grassmann Consensus

Validator selection is **Grassmann-native**: consensus lives on the Grassmann manifold Gr(k,n), using the infrastructure already implemented in `primitives/grassmann.py` and `consensus/validator_selection.py`.

### The Čech Nerve as Consensus Topology

The **Čech nerve** of the validator set defines the consensus topology. Two validators share an edge when their stalks overlap (nonzero principal angle intersection):

```
Čech nerve N(V):
  vertices = validators (identified by spectral fingerprint)
  edges    = {(v_i, v_j) : d_Gr(stalk(v_i), stalk(v_j)) < ε}
  
  β₀(N(V)) = 1  →  ALL validators form one coherent cluster
  β₀(N(V)) > 1  →  network is PARTITIONED
  β₁(N(V)) > 0  →  persistent disagreement cycle (investigate, don't suppress)
```

### Cellular Sheaf Over the Nerve

Each validator vertex gets its **stalk subspace** (k-dim subspace of ℝⁿ from their credential). Restriction maps are **principal angle projections** between neighboring stalks:

```
Cellular sheaf F over N(V):
  F(v_i)     = stalk(v_i) ∈ Gr(k,n)           (subspace)
  F(v_i,v_j) = projection P_{i→j}             (principal angle map)
  
Sheaf Laplacian Δ_F measures validator disagreement:
  ker(Δ_F) = validators in perfect agreement (global section)
  ‖Δ_F‖   = total geometric disagreement across network
```

### Selection: Harmonic Projection Weight

If value IS the harmonic component, then a validator's influence should BE its harmonic content — how much of their stalk survives the network's Hodge projection.

```
1. Consensus subspace (Karcher mean on Gr(k,n)):
   μ = karcher_mean({stalk(v) : v active})     [grassmann_karcher_mean()]

2. Eligibility gate (Plücker — binary, not weighted):
   eligible(v) = d_Gr(stalk(v), μ) < MAX_DIVERGENCE
   → Are you close enough to consensus to participate? (go/no-go)

3. Selection weight (harmonic projection — continuous):
   weight(v) = ‖π_H(stalk(v))‖ / ‖stalk(v)‖
   → How much of your stalk IS harmonic under the network's Laplacian Δ_F?
   → This IS your "value" — the part that survives projection.

4. VRF slot assignment:
   output = HMAC-SHA256(eigenvectors, prev_hash ‖ epoch)
   threshold = weight(v) × n_validators
   eligible = (score < threshold)
   winner = eligible validator with lowest score
```

**Why harmonic weight over Plücker centrality:**

| | Plücker centrality | Harmonic projection weight |
|---|---|---|
| Measures | Distance to Karcher mean | How much stalk survives π_H |
| What it rewards | Being close to consensus | Having globally coherent stalk data |
| Discriminating power | Two equidistant validators = same weight | Equidistant validators can have different harmonic content |
| Consistency with "PoV" | Indirect (proximity ≠ value) | **Direct** — value IS what survives π_H |
| Connects to Lean proof | — | `Hodge_Ambiguity`: same cochain is harmonic for Δ₁ but not Δ₂ |

The Plücker gate still matters (eligibility), but the **weight** — what determines selection probability and reward share — is the harmonic projection magnitude. The whole system becomes: value is harmonic, selection is harmonic, rewards are harmonic.

### Sybil Resistance (Geometric)

From [ORACLE_SECURITY.md](ORACLE_SECURITY.md):

```
In PoV: Sybil creates fake nodes → changes topology → spectral gap drops → blocks invalid.

Sybil adds 100 disconnected nodes:
  β₀ = 101 (101 connected components) → REJECTED: β₀ must equal 1
```

The Čech nerve + cellular sheaf add a second geometric barrier:

```
Attack: Spin up 100 fake validators with random stalks.

Defense:
  1. Random stalks are NOT aligned with consensus μ
  2. d_Gr(random, μ) is large → centrality ≈ 0 → near-zero selection
  3. Karcher mean μ is dominated by honest validators
  4. Forging coherent stalks → inverse spectral problem → Hodge-hard
```

## Token Economics

### Two-Token Design

**Native token** (HCRYPT): Transactions, fees, transfers — the medium of exchange.

**Vault token** (vHCRYPT): Validator participation — the consensus commitment.

```
Why separate:
  - Native token = medium of exchange (high velocity, liquid)
  - Vault token = validator commitment signal (low velocity, locked)
  - Separating avoids conflating "using the network" with "securing the network"
  - Vault token has its own supply dynamics (validator incentives)
```

### CLMM Pool

A **Concentrated Liquidity Market Maker** connects the two tokens:

```
CLMM Pool: HCRYPT ↔ vHCRYPT

  Validators acquire vHCRYPT by providing liquidity or earning rewards
  Users acquire HCRYPT for transactions
  Price discovery between the two
  
  vHCRYPT/HCRYPT ratio = validator demand signal
    High → validators in demand → network healthy
    Low  → validator oversupply or low activity
```

### Treasury Pool

A **secondary pool** collects fees and distributes rewards:

```
Treasury Pool:
  INPUTS:
    Transaction fees (HCRYPT)
    Slashing proceeds
    Protocol inflation (configurable)
  
  OUTPUTS (modular — distribution logic is pluggable):
    Block producer reward → producer's vault (vHCRYPT)
    Epoch participation reward → active vaults (by centrality)
    Protocol fund (configurable %)
    Burn (configurable %)
```

### Modular Rewards Distribution

The treasury exposes a pluggable interface. Concrete strategy is tunable without changing consensus:

```python
class RewardsStrategy(Protocol):
    def distribute(
        self,
        epoch: int,
        validators: List[Validator],
        centralities: Dict[bytes, float],
        treasury_balance: int,
    ) -> Dict[bytes, int]:
        """Returns fingerprint → allocation mapping."""
        ...

# Strategies:
#   ProportionalByCentrality (default)
#   EqualShare
#   HarmonicWeighted (weight by |π_H(stalk)|)
#   Custom
```

This lets us figure out the right reward distribution over time without protocol changes.

### Vault Structure

```
Vault(fingerprint):
  bonded_v: uint           # vHCRYPT locked (slashing collateral)
  earned_v: uint           # vHCRYPT earned (withdrawable)
  reputation: float        # Geometric reputation (from incentives.py)
  last_active: height      # Last block produced or attested
  stalk_commitment: hash   # Commitment to stalk data
```

Bond is a **flat threshold** — not a selection weight:

```
eligible(v) = vault.bonded_v >= MINIMUM_VAULT_BOND
              AND v.is_active
              AND d_Gr(stalk(v), μ) < MAX_DIVERGENCE

selection_weight(v) = ‖π_H(stalk(v))‖ / ‖stalk(v)‖  # harmonic weight, NOT bond size
```

### Rewards Flow

```
Transaction fee (HCRYPT)
    │
    ▼
Treasury Pool
    │
    ├──▶ Block producer (vHCRYPT)
    ├──▶ Active validators (vHCRYPT, by harmonic weight)
    ├──▶ Protocol fund (HCRYPT, configurable %)
    └──▶ Burn (configurable %)

Validator cash out:
    vHCRYPT → CLMM Pool → HCRYPT
```

## Verification Pipeline

```
Transaction arrives
    │
    ├─ Stage 0: Structural checks (O(1))
    ├─ Stage 1: Key image double-spend check (O(1))
    ├─ Stage 2: Spectral proof verification (O(n))
    │     ├─ λ₁ ∈ [1/√2, 2√2] (√2 / Tsirelson bounds)
    │     ├─ β₀ = 1 (connected topology)
    │     └─ Eigenvalue commitments match fingerprint
    ├─ Stage 3: Sheaf coherence (local-to-global)
    │     ├─ δ(commitments) ≈ 0 across Čech nerve neighbors
    │     ├─ Stalk alignment with Karcher mean μ
    │     └─ β₁ check (persistent disagreement = flag, not reject)
    ├─ Stage 4: Amount balance (cochain homomorphic, SVP-hard)
    └─ Stage 5: VRF slot validity + equivocation check

Block accepted → Treasury receives fees → Distribution triggered
```

## Comparison: Ouroboros vs PoV

| | Ouroboros (Cardano) | Proof of Value (hcrypt) |
|---|---|---|
| Block producer selection | Stake-weighted VRF lottery | Harmonic projection weight + VRF |
| What determines influence | **How much you own** (ADA stake) | **How much of your stalk survives π_H** (harmonic content) |
| Validity condition | Slot leader signed correctly | λ₁ ∈ [1/√2, 2√2] + β₀=1 + key image unique + sheaf coherence |
| Security assumption | >50% honest stake | Hodge-hardness (geometry is honest) |
| Formal verification | Protocol spec (Ouroboros in Agda) | Hardness proof (`hardness_proof.lean`, Lean 4 + Mathlib) |
| Sybil resistance | Stake = cost of attack | Geometric coherence + vault bond threshold |
| Messages per block | O(N²) (BFT voting) | O(N) (gossip only) |
| Privacy | Optional (Midnight sidechain) | Default (every transaction) |
| Plutocracy risk | Yes — more ADA = more power | No — bond is binary go/no-go, selection is geometric |
| Finality | Probabilistic (k confirmations) | 1 block (deterministic spectral check) |

## Implementation Plan

1. **Vault token** (`chain/vault.py`) — NEW
   - Vault struct per spectral fingerprint
   - Bond/unbond/withdraw/slash
   - Separate from native HCRYPT balance

2. **Treasury pool** (`chain/treasury.py`) — NEW
   - Fee collection, pluggable distribution strategies
   - Modular `RewardsStrategy` interface

3. **CLMM pool** (`chain/clmm.py`) — NEW (stub first)
   - HCRYPT ↔ vHCRYPT liquidity
   - Start as constant-product AMM, upgrade to concentrated later

4. **Čech nerve coherence** (`consensus/coherence.py`) — NEW
   - Build Čech nerve from validator stalks
   - Sheaf Laplacian over nerve
   - δ(commitments) ≈ 0 check
   - β₁ monitoring (information, not failure)

5. **Slim oracle** (`rust/oracle/`) — MODIFY
   - Remove trusted worker authority
   - Keep as Python↔Rust serialization bridge

6. **Rewards distribution** (`chain/rewards.py`) — NEW
   - `distribute(epoch, validators, centralities) → allocations`
   - Default: ProportionalByCentrality
   - Interface for pluggable alternatives

7. **Update validator_selection.py** — MODIFY
   - Add vault bond eligibility gate
   - Integrate Čech nerve topology
