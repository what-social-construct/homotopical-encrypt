# Categorical Architecture

## Dependency Order

primitives/ → geometry/ → crypto/ → proofs/ → consensus/ → chain/`

## The Topos View

A blockchain is a **presheaf topos** on a directed site (the nerve).
The code layers correspond to categorical levels of that topos:

```
Layer 0: SITE (base category)
    primitives/          — objects and morphisms of the site
    primitives/cochain   — CochainComplex = presheaf on Δ^op
    primitives/stalk     — stalks = fibers of the étale space
    primitives/spectral_bounds — constants of the theory (√2 bounds)

Layer 1: SHEAVES (presheaves on the site)
    geometry/            — sheaf constructions on the nerve
    geometry/sheaf       — CellularSheaf = functor Nerve^op → Vect
    geometry/hodge       — Hodge decomposition of sections
    geometry/fiber_bundle — parallel transport = connection on bundle

Layer 2: CRYPTOGRAPHIC FUNCTOR (F: Sh(X) → Commit)
    crypto/              — the functor from geometry to commitments
    crypto/commitment    — F(cochain) = Pedersen commitment of δ(c)
    crypto/credential    — F(fibration) = FibrationCredential
    crypto/encrypt       — F(section) = lattice ciphertext in ker(Δ)
    crypto/hardness      — the functor F is one-way (CVP reduction)

Layer 3: NATURAL TRANSFORMATIONS (witnessing properties)
    proofs/              — η: F ⟹ G witnessing security properties
    proofs/spectral      — η witnesses λ₁ ∈ [1/√2, 2√2]
    proofs/anonymity     — η witnesses unlinkability
    proofs/homotopical_zkp — η witnesses knowledge of preimage
    proofs/consensus     — η witnesses valid state transition

Layer 4: SUBOBJECT CLASSIFIER (Ω in the topos)
    consensus/           — the truth-value object
    consensus/topos      — Heyting algebra Ω = {Valid, Undetermined, Invalid}
    consensus/coherence  — Čech nerve β₀ = 1 (connected)
    consensus/validator_selection — Grassmannian centrality weighting

Layer 5: NATURAL TRANSFORMATIONS BETWEEN SHEAVES
    primitives/natural   — abstract η: F ⟹ G (pullback f*, pushforward f_*)
    rust sheaf_store     — concrete realization: F: Sh(X) → RocksDB
                           Three sheaves over the same nerve:
                             F_full (Private, dim=256) — full credential
                             F_zk   (Zk, dim=32)      — Hodge projection
                             F_hash (Public, dim=1)    — balance commitment
                           Connected by:
                             η₁: F_full → F_zk   (oracle computes: Hodge + quantize)
                             η₂: F_zk  → F_hash  (node applies: hash + compress)
                           Privacy via exact sequence:
                             0 → ker(η) → F_full → F_hash → 0
                             ker(η) = fiber secrets (restriction maps, Laplacian)

    Adjunction (f* ⊣ f_*) — natural.py documents but doesn't yet implement
    the unit/counit. Needed for cross-topology value transfer with
    conservation guarantees (Ledger.lean: TreasuryFlowConservative).

Layer 6: COLIMIT + LEDGER INVARIANTS
    chain/               — lim→ of blocks along parent hash
    chain/block          — objects in the directed diagram
    chain/sheaf_state    — global sections Γ(X, F)
    chain/homotopy_transaction — morphisms preserving homotopy class
    lean/Axioms/Ledger   — colimit invariants:
                             Conservation (Σ balances = total supply)
                             NonNegativeBalances (∀ acct, bal ≥ 0)
                             KeyImageMonotone (spent set only grows)
                             TreasuryFlowConservative (no mint/burn)

Layer 7: GEOMETRIC REALIZATION (|N•| → physical network)
    network/             — P2P realization of the abstract nerve
    oracle/              — the distinguished point (oracle = terminal object)
                           Oracle IS η₁ — receives FullStalk, outputs HashStalk
```

## The Coboundary δ: The Fundamental Morphism

The coboundary operator δ: C⁰ → C¹ is the single morphism from which
everything else is derived. It threads through every layer:

```
Layer 0 (primitives):  δ is a linear map, δ² = 0
Layer 1 (geometry):    Δ = δ*δ + δδ* (Laplacian from δ)
                       ker(Δ) ⊕ im(δ) ⊕ im(δ*) = C• (Hodge from δ)
Layer 2 (crypto):      commitment = δ(m ∥ r) (coboundary of message+blinding)
                       encryption = project into ker(Δ) (which δ defines)
Layer 3 (proofs):      ZKP witnesses δ(x) without revealing x
Layer 4 (consensus):   spectral gap λ₁(Δ) gates blocks (Δ built from δ)
Layer 5 (storage):     η₁, η₂ are natural transformations that factor through δ
Layer 6 (chain):       balance_preserved ↔ Σ_tx δ(tx) = 0 (δ linearity)
```

The colimit structure of the blockchain is:

```
                    δ(tx₁)        δ(tx₂)        δ(tx₃)
    State₀ ─────────────→ State₁ ─────────────→ State₂ ─────────────→ ...
      ↓                     ↓                     ↓
    Block₀               Block₁               Block₂
      │                     │                     │
      └──── prev_hash ──────┘──── prev_hash ──────┘
```

The blockchain is lim→ of this directed diagram. Each state transition
is a coboundary: δ(tx) moves value along edges of the nerve. The
colimit condition (Chain.lean: `block_extends`) requires:
  - δ preserves balance (linearity → conservation)
  - δ² = 0 (no second-order effects — applying δ twice is trivial)
  - key_images monotone (spent set only grows in the colimit)


## The Helfer Diagonal: Path-Space Equality

Helfer's first-order homotopical logic (arXiv:1908.08944) replaces
set-theoretic equality (x = y) with **path-space equality**:

```
  x ≡_H y  ↔  Path(x, y) is inhabited  (Nonempty in Lean)
```

This is the **diagonal** Δ: X → X × X interpreted homotopically.
Instead of asking "are these the same point?", we ask "is there
a path between them?" — which is exactly homotopy equivalence.

**Implementation across languages:**

```
HELFER AXIOM                LEAN                        PYTHON                    RUST
────────────────────────────────────────────────────────────────────────────────────────
Diagonal semantics          HelferFOL.lean:             homotopy_path.py:         crypto/geodesic_zkp.rs:
  x ≡ y ↔ Path(x,y)        EqualityByPaths x y =       verify_homotopy_          GeodesicProof (proves
  inhabited                 Nonempty (Path x y)         equivalence(L1, L2)       path exists on SO(n))

Cartesian lifting           PathAxioms.trans:           construct_geodesic_       (planned: transport
  transport along paths     Path x y → Path y z         path() via SO(n)          along geodesic)
                            → Path x z                  exp/log

Σ/Π coherence               SigmaPiCoherent:           encrypt = Σ-type          encrypt = Σ-type
  dependent types ↔         encryption/decryption       (message, blinding)       (ciphertext, proof)
  encrypt/decrypt           contracts coherent          decrypt = Π-projection    verify = Π-check

Homotopy invariance         HomotopyInvarianceFO:       HomotopyEquivalence.      spectral fingerprint
  same theory for ≃         F ≃ G → same first-order    equivalent() checks       comparison (same
  equivalent structures     properties                  Betti + spectrum + gap    eigenvalues = same class)

Class witness               ClassWitnessSound:          HomotopyClass.contains()  (implicit in
  membership has witness    class membership is          returns True only with    commitment verification)
                            computationally witnessed    matching invariants
```

**The diagonal pairing in the crypto pipeline:**

```
                     Δ (diagonal)
  Credential ─────────────────────→ Credential × Credential
      │                                    │
      │ encrypt (Σ-type)                   │ verify (Π-type)
      ↓                                    ↓
  (ciphertext, proof)              (commitment, judgment)
      │                                    │
      │ path space                         │ path space
      ↓                                    ↓
  Path(enc, ker(Δ))               Path(commit, valid_class)
      │                                    │
      └──── inhabited iff honest ──────────┘
```

The prover demonstrates `Path(their_commitment, valid_homotopy_class)` is
inhabited — this IS the ZK proof. The verifier checks inhabitance without
learning the specific path (zero-knowledge).


## Functorial Diagrams

### Diagram 1: The Privacy Exact Sequence

```
                  η₁                    η₂
0 → ker(η) → F_full ─────────→ F_zk ─────────→ F_hash → 0
    (secret)  (Private,256)   (Zk,32)         (Public,1)
    
    Python      Python wallet    Rust oracle     Rust node
    keygen      stores this      computes η₁     stores η₂(result)
```

This is an exact sequence of sheaves on the nerve:
- ker(η) = fiber secrets (Laplacian eigenvectors, restriction maps)
- Privacy = surjectivity of η means F_hash reveals NO information about ker(η)
- Hardness = inverting η requires solving CVP in ker(Δ) (Hardness.lean)

### Diagram 2: The Consensus Commutative Square

```
    Validator                gap_in_bounds              GapStatus
    (spectral_gap) ──────────────────────────→ {Valid, Marginal, Invalid}
         │                                              │
         │ eligible()                                   │ blockAccepted()
         ↓                                              ↓
    Eligible set ──────────────────────────→ Block valid/invalid
         │              VRF selection                   │
         │                                              │
         ↓              chain extension                 ↓
    Producer ───────────────────────────────→ Chain (colimit)
```

This square commutes: the path through `gap_in_bounds → blockAccepted`
equals the path through `eligible → VRF → chain extension`. Both give
the same answer because the Heyting3 judgment is functorial.

### Diagram 3: The Coboundary Naturality Square

For any natural transformation η: F → G between sheaves,
the coboundary commutes with η:

```
    F(vertex) ────η_v────→ G(vertex)
        │                      │
        │ δ_F                  │ δ_G
        ↓                      ↓
    F(edge) ──────η_e────→ G(edge)
```

η_e ∘ δ_F = δ_G ∘ η_v  (naturality of η)

**Concretely in the codebase:**
- F = F_full (Private sheaf), G = F_hash (Public sheaf)
- η_v = project vertex stalk (dim 256 → dim 1)
- δ_F = coboundary on private cochains
- δ_G = coboundary on public cochains
- Naturality = "projecting then taking coboundary = coboundary then projecting"
- This is what `natural.py:is_natural()` checks
- And what `rust/oracle/src/stalk_bridge.rs` verifies via `verify_all_naturality()`

### Diagram 4: The Plucker, Cochain, and Proximity Projection

The middle layer of the privacy exact sequence is not merely "a hashable blob."
It has a geometric coordinate stage and a local-test stage. The current Lean
shape is:

```
    private fibration / credential representative
                  │
                  │  Hodge/Laplacian projection
                  ▼
    Grassmannian point / operative Hodge submodule
                  │
                  │  private frame witness, exterior product
                  ▼
    Plucker / exterior-algebra public shadow
                  │
                  │  cellular restriction and coboundary
                  ▼
          cochain / syndrome local test
                  │
                  │  distance and gap comparison
                  ▼
          RS / finite proximity target
                  │
                  │  commitment or hash projection
                  ▼
          public hash / chain shadow
```

In this sense:

- a cochain is a sheaf-theoretic received word;
- `δ(c)` is its local inconsistency syndrome;
- `ker(δ)` / `ker(Δ)` is the valid global-section space;
- `π_H(c)` is decoding/projection to the globally coherent part;
- a Plucker coordinate is the exterior-algebra shadow of the Grassmannian/Hodge
  submodule;
- the hash is only a compressed handle to this shadow, not the shadow itself.

`lean/Proximity/Projection.lean` names the abstract projection vocabulary, and
`lean/Proximity/CochainBridge.lean` connects it to the existing committed-cochain
and sheaf-coherence contracts:

```
SheafProximityInstance ── EvaluationProjection ──▶ CodeShadow
```

The intended contract is deliberately modest: global sections project to
codewords/shadow-valid words, and projected distance is controlled by
sheaf-side disagreement. This keeps proximity comparisons internal to hcrypt
first. RS/code-proximity targets live under `lean/Proximity/` and become useful
when the projection and distance bounds are explicit.

This also separates three roles that should not be conflated:

| Layer | Role |
|-------|------|
| Witness | private fibration, restriction maps, paths, openings |
| Shadow | cochain/proximity/evaluation data derived from the witness |
| Hash | public commitment or pointer to the shadow |
| SNARK/certificate | proof that the witness produced the shadow and satisfies the required invariants |

For the current Plucker layer:

| Role | Lean object |
|------|-------------|
| Private frame witness | `GrassmannianPlucker.FrameWitness` |
| Exterior coordinate | `GrassmannianPlucker.ExteriorCoordinate` |
| Public Plucker shadow | `GrassmannianPlucker.FramedSystem.publicShadow` |
| Frame-change invariance obligation | `GrassmannianPlucker.FramedSystem.Sound.projective_frame_invariance` |
| RS target | `Proximity.ReedSolomonTarget.Target` |

Current Lean build status for this projection stack:

```text
lake build
Build completed successfully (7418 jobs)
```

### Diagram 5: The Helfer Transport Triangle

```
    FibrationCredential_old
            │ ╲
    rotate  │   ╲  path in π₁(Fib(X))
  (keygen)  │     ╲
            ↓       ↘
    FibrationCredential_new ───────→ same HomotopyClass
                          invariants match
```

Key rotation is by homotopy class: two credentials are "the same identity"
iff they live in the same homotopy class. The path between them
(constructed by `construct_geodesic_path()` on SO(n)) witnesses this.
Helfer's `CartesianLiftingPrinciple` ensures the transport is coherent.


## Why This Order is Necessary (Not Just Convenient)

### Security argument flows UPWARD:

```
primitives     defines  δ² = 0          (algebraic identity)
    ↓
geometry       derives  ker(Δ) ⊕ im(δ) ⊕ im(δ*) = C•  (Hodge)
    ↓
crypto         reduces  "break encryption" → CVP in ker(Δ)  (hardness)
    ↓
proofs         shows    ZK proof that ciphertext ∈ correct homotopy class
    ↓
consensus      gates    block valid iff spectral gap ∈ [1/√2, 2√2]
    ↓
chain          ensures  state transitions preserve homotopy invariants
```

Each layer's security **depends only on layers below it**.
This is why circular imports are not just inconvenient — they
break the security argument.

### The spectral_bounds placement proves the point:

`spectral_bounds` defines `gap_in_bounds()` which classifies ℝ → Heyting3.
This is a **constant of the theory** (like √2 itself). It belongs in
`primitives/` because:

1. It has zero upstream deps (pure math)
2. Every layer above needs it (geometry for validation, crypto for
   credential checks, proofs for ZK bounds, consensus for block gating)
3. If it lived in `proofs/`, then `geometry/` importing it would create
   a cycle: `geometry/ → proofs/ → crypto/ → geometry/`

The circular import we fixed wasn't a Python accident — it was a
**categorical error** (trying to import from a higher layer).

## Cross-Language Correspondence

```
CATEGORY          PYTHON                LEAN                    RUST
─────────────────────────────────────────────────────────────────────
Base objects      primitives/cochain    Axioms/Foundation       types.rs (CochainCommitment)
                  primitives/stalk      Axioms/CochainCommitment
                  primitives/spectral_  Axioms/Heyting          consensus/topos.rs (Heyting3)
                    bounds

Sheaves           geometry/sheaf        Laplacian.lean          oracle/geometry.rs
                  geometry/hodge        (Hodge_decomposition)
                  geometry/fiber_bundle

Crypto functor    crypto/commitment     Axioms/CochainCommitment crypto/commitment.rs
                  crypto/credential     Axioms/ZKP              (FibrationCredential in types)
                  crypto/encrypt        Hardness.lean

Proofs            proofs/spectral       Tsirelson.lean          oracle/stalk_bridge.rs
                  proofs/homotopical_zkp Axioms/ZKP             crypto/geodesic_zkp.rs
                  proofs/anonymity      (planned: Anonymity.lean)

Consensus Ω       consensus/topos       Axioms/Consensus        consensus/pov.rs
                  consensus/coherence   Axioms/Heyting          consensus/topos.rs
                  consensus/validator_  Axioms/Grassmannian     consensus/validator_set.rs
                    selection

Chain colimit     chain/block           Chain.lean              types.rs (Block)
                  chain/sheaf_state     Axioms/Ledger           storage/
                  chain/homotopy_tx
```

## What's Still Missing (Parity Gaps)

### Lean needs:
- `Anonymity.lean` — Chern class bounds on linking advantage
  (Python has `proofs/anonymity.py`, Lean doesn't formalize this yet)
- `SpectralBounds.lean` — dedicated file for √2 bound axioms
  (currently spread across Foundation + Heyting + OracleModality)
- `GRR.lean` — Grothendieck-Riemann-Roch for incentive conservation

### Rust needs:
- `consensus/coherence.rs` — Čech nerve β₀ check
  (Python has full Grassmannian coherence, Rust only checks spectral gap)
- `crypto/anonymity.rs` — ring signature / linkable ring for transactions
  (Python has it, Rust doesn't yet)

### Python needs:
- Convert remaining 12 raw `POV_LOWER <= gap` float checks to `gap_in_bounds()`
  (identified in docs/GATE_ARCHITECTURE.md, mostly in chain/ and proofs/)

## The Functor Diagram (What "Consistency" Means)

For each mathematical object O, the three implementations must commute:

```
        Lean axioms
       ╱           ╲
      ╱  typecheck   ╲  axiom
     ↓                ↓
  Python model ──── Rust model
     numpy            ndarray
     float64          f64
     GapStatus        SpectralJudgment
```

"Consistent" means: for every axiom A in Lean, the Python model
satisfies A (tested) and the Rust model satisfies A (tested).

The **semantic functor** is:
- F_py: Lean Axioms → Python Tests (pytest witnesses the axioms)
- F_rs: Lean Axioms → Rust Tests (cargo test witnesses the axioms)

**Both functors must agree on observable behavior.**
That's what cross-language consistency means categorically.

## Summary

Module hierarchy:
```
primitives (site) → geometry (sheaves) → crypto (functor) →
proofs (nat. trans.) → consensus (Ω) → chain (colimit) → network (realization)
```

This ordering makes the security argument compositional. Each layer's guarantees
depend only on layers below, and Lean verifies the foundational
properties that all three implementations must satisfy.
