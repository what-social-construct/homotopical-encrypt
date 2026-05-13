# Gate Architecture: Who Computes What

Reference: Swan et al., "Categorical Cryptoeconomics" — HoTT blockchains
where nodes are simplicial sets/fibrations, paths are higher homotopies.

The categorical structure dictates where each validation gate lives.

For the production ownership boundary between Lean specifications, Rust
validation, and Python reference code, see
[TRUST_BOUNDARIES.md](TRUST_BOUNDARIES.md).

## Three Gate Categories

### 1. EXACT GATES (current Python reference; target Rust consensus)

These are mathematical identities. They're either true or false.
No boundary zone, no Heyting semantics — classical logic.

| Gate | Check | Module | Tolerance |
|------|-------|--------|-----------|
| δ²=0 | Cochain complex law | `primitives/cochain.py` | NONE (integer) |
| Δ = δ*δ + δδ* | Laplacian construction | `geometry/sheaf_laplacian.py` | NONE (matrix identity) |
| P²=P | Hodge projection idempotent | `geometry/hodge.py` | ε=1e-10 (float) |
| H⊕im(δ)⊕im(δ*)=C | Hodge decomposition | `geometry/hodge.py` | ε=1e-10 (float) |
| ⟨H,im(δ)⟩=0 | Hodge orthogonality | `geometry/hodge.py` | ε=1e-10 (float) |
| Δ ≥ 0 | Laplacian PSD | `geometry/sheaf_laplacian.py` | ε=1e-6 (eigenvalue) |
| dim ∈ {128,256,512,1024} | Dimension | `crypto/validation.py` | NONE (integer) |
| β₀ ≥ 1 | Connected topology | `geometry/topology.py` | NONE (integer) |

**Current implementation:** Python computes/reference-checks many of these as
part of geometry construction.

**Target consensus boundary:** Rust enforces exact gates on transaction/block
acceptance, or verifies bounded signed attestations from workers. The oracle
doesn't need Heyting boundary logic for these because they are structural.

### 2. CONSENSUS GATES (Rust Oracle — Heyting tri-valued)

These have genuine boundary zones. The oracle is the AUTHORITY.
Lean proves the classification is correct. Python sends raw values.

| Gate | Raw Value | Who Computes | Who Classifies | Lean Proof |
|------|-----------|-------------|----------------|------------|
| Spectral gap | λ₁(Δ) ∈ ℝ | Python | **Oracle** | `decideSpectralJudgment` |
| Betti consistency | β = (β₀,β₁,β₂) | Python | **Oracle** | `OraclePredicate` |
| Naturality | topology_hash match | Python | **Oracle** | `verify_naturality` |
| Commitment non-trivial | id_commit ≠ 0 | Python | **Oracle** | `commitment_nontrivial` |

**Oracle owns classification.** Returns `SpectralJudgment`:
- `InBounds` → Heyting3.Valid → accept
- `Boundary` → Heyting3.Undetermined → pending further evidence
- `OutOfBounds` → Heyting3.Invalid → reject

Python pre-flight: `gap_in_bounds()` mirrors oracle logic to save round-trips.
But the oracle's judgment is what goes on-chain.

### 3. STAGE GATES (Python+Lean — which gates apply when)

Not all gates apply at all stages. This is `StageAdmissibility`:

| Stage | Exact Gates | Consensus Gates | Why |
|-------|------------|-----------------|-----|
| **keygen** | ✅ All | ❌ Skip spectral | Flat spectrum by design (anonymity) |
| **encrypt** | ✅ All | ❌ Skip spectral | Internal noise structure |
| **decrypt** | ✅ All | ❌ Skip spectral | Projection works regardless |
| **transaction** | ✅ All | ✅ All | Validators verify geometry |
| **block** | ✅ All | ✅ All (from oracle) | Oracle-attested |

Lean: `lean/Axioms/StageAdmissibility.lean`

## Data Flow

```
Python (wallet)                  Rust (oracle)              Rust (node)
───────────────                  ─────────────              ───────────
1. Compute geometry              
   - eigendecomposition          
   - Hodge projection            
   - spectral gap (raw float)   
   - Betti numbers (exact int)  
                                 
2. Check EXACT gates locally     
   (δ²=0, P²=P, dim, etc.)     
   FAIL FAST if violated         
                                 
3. Pre-flight consensus check    
   gap_in_bounds() → GapStatus  
   (saves round-trip if clearly  
   out of bounds)               
                                 
4. Send to oracle ──────────────→ 5. Classify gap                 
   FullStalkRequest:                classify_spectral_gap()       
   { spectral_gap, betti,          → SpectralJudgment            
     id_commit, eigenvalues }       (Heyting tri-valued)          
                                                                   
                                 6. Verify invariants             
                                    (betti, PSD, non-trivial)     
                                                                   
                                 7. Produce HashStalk ──────────→ 8. Enforce consensus
                                    { identity_hash,                 gate on block
                                      spectral_judgment,             acceptance
                                      betti_numbers }             
```

## Why No Tolerance on Exact Gates

The paper's insight applies: "objects with the same shape have the same
logical structure." Exact gates check SHAPE (structural identity):
- δ²=0 is the cochain complex law — it's algebraic, not numeric
- dim=256 is a type constraint — no boundary zone exists
- β₀ ≥ 1 is a topological invariant — it's an integer

These are classical (boolean). The Heyting semantics only apply to
the consensus gates where genuine measurement uncertainty exists
(eigenvalue computation on different machines).

## Implementation Status

| Component | Exact Gates | Consensus Gates | Stage Gates |
|-----------|------------|-----------------|-------------|
| Python | ✅ `invariants/unified.py` | ⚠️ 12 sites bypass oracle | ✅ `StageAdmissibility` |
| Rust Oracle | — | ✅ `classify_spectral_gap` | — |
| Rust Node | — | ✅ `ToposVerifier` | ✅ `pov.rs` |
| Lean | ✅ `Foundation.lean` | ✅ `OracleModality.lean` | ✅ `StageAdmissibility.lean` |

**Next:** Replace the 12 Python bypass sites with either:
- Pre-flight `gap_in_bounds().accepted()` (for offline/batch)
- Oracle judgment check (for online/consensus path)

---

## Future: Chern Class Anonymity Layer (Grothendieck-Riemann-Roch)

Reference: Burke, "The Grothendieck-Riemann-Roch Theorem" (REU 2021);
Swan et al., "Categorical Cryptoeconomics" — HoTT blockchain nodes as
fibrations with characteristic classes.

### Why Chern Classes Fit

The framework already has:
- `FiberBundle` with SO(n) parallel transport (`geometry/fiber_bundle.py`)
- `ChernData`, `compute_chern_classes` from holonomy curvature (`primitives/k_theory.py`)
- Segre classes, Stiefel-Whitney, Pontryagin, Adams operations (all in `k_theory.py`)
- `CochainComplex` with δ² = 0 (`primitives/cochain.py`)

The Chern character ch: K(X) → A*(X)⊗ℚ is the bridge between K-theory
(vector bundles, already computed) and cohomology (Chow ring / intersection
theory). The GRR theorem says the natural transformation

    τ_X(α) = ch(α) · td(T_X) : K(X) → A*(X)⊗ℚ

commutes with proper pushforward. In our setting:
- X = nerve (simplicial complex of validators)
- E = fiber bundle (sheaf of credentials)  
- f: X → Y = oracle submission (proper morphism from local to on-chain)
- ch(f_* E) · td(T_Y) = f_*(ch(E) · td(T_X))

### Anonymity Invariant Hierarchy

```
Coarse ──────────────────────────────────────→ Fine
(more public info = smaller anonymity set)

β₀,β₁,β₂     (base topology)        PUBLIC:  betti_id
c₁, c₂        (bundle topology)      SAFE:    chern_id (topological invariant)
ch(E)          (Chern character)      SAFE:    rational K-theory image
λ₁...λₙ       (connection spectrum)  PRIVATE: fiber_secret
R_e ∈ SO(n)   (transport matrices)   SECRET:  key material
```

**Key property:** c₁ is a TOPOLOGICAL invariant of the bundle — different
connections (different fiber secrets) on the same bundle give the same c₁.
Revealing c₁ doesn't shrink anonymity below "all connections on this bundle."
(Same argument as Betti numbers for the base.)

### Concrete Uses

1. **Anonymity proofs** (`proofs/anonymity.py`):
   - Current: "same Betti → indistinguishable"
   - Extended: "same Betti AND same c₁ → indistinguishable"
   - Strictly finer guarantee (fewer false matches)

2. **Anti-Sybil** (`k_theory.py` already partially does this):
   - Trivial/flat bundles cluster at c₁ = 0
   - Sybil nodes spawning degenerate topologies are detectable
   - Adams ψ² detects suspiciously symmetric connections

3. **Routing mixing pools** (`network/routing.py`):
   - Group by (betti_id, chern_id) for mixing
   - Better anonymity set stratification than Betti alone

4. **ZKP extension** (`proofs/homotopical_zkp.py`):
   - Prove "my c₁ ∈ allowed_set" without revealing which c₁
   - Uses Chern character multiplicativity: ch(E⊗F) = ch(E)·ch(F)

### Implementation Plan

| Step | What | Where | Depends On |
|------|------|-------|------------|
| C1 | Wire `compute_chern_classes` into `FiberBundle` | `geometry/fiber_bundle.py` | Existing k_theory.py |
| C2 | Add `chern_id: bytes` to public identity model | `chain/account.py`, oracle | betti_id pattern (R9) |
| C3 | Lean axiom: `ChernWeil.lean` | `lean/Axioms/` | Foundation.lean |
| C4 | GRR naturality axiom: ch commutes with f_* | `lean/Axioms/` | ChernWeil.lean |
| C5 | Anonymity proof: c₁-class indistinguishability | `proofs/anonymity.py` | C1, C2 |
| C6 | ZKP: prove c₁ membership without revealing | `proofs/homotopical_zkp.py` | C5 |
| C7 | Rust oracle: verify chern_id | `rust/oracle/` | C2 |

### Lean Axiom Sketch (ChernWeil.lean)

```lean
-- Chern-Weil: curvature → characteristic classes
structure ChernWeilAxioms where
  -- c₁ is a topological invariant (independent of connection)
  chern_topological : ∀ E E', BundleIsomorphic E E' →
    c₁ E = c₁ E'
  -- Whitney sum: c(E⊕F) = c(E) · c(F)
  whitney_sum : ∀ E F, c (E ⊕ F) = c E * c F
  -- Chern character is additive: ch(E⊕F) = ch(E) + ch(F)
  ch_additive : ∀ E F, ch (E ⊕ F) = ch E + ch F
  -- Chern character is multiplicative: ch(E⊗F) = ch(E) · ch(F)
  ch_multiplicative : ∀ E F, ch (E ⊗ F) = ch E * ch F
  -- GRR naturality: τ commutes with proper pushforward
  grr_naturality : ∀ f α, ch (f_* α) * td T_Y = f_* (ch α * td T_X)
```

**Priority:** After P1-P3 in SEMANTIC_PARITY_QUEUE.md (gap_in_bounds
canonicalization, Chain.lean sorry holes, Rust Hodge decomposition).
