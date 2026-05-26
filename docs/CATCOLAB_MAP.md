# CatColab Map

This document is a **conceptual markdown map** for how homotopical-encrypt
could later be represented in CatColab or a similar categorical modeling tool.

It is intentionally lightweight:

- not a commitment to adopt CatColab
- not part of the trusted computing base
- not a replacement for Lean, Rust, or runtime tests
- just a clean semantic map from the current docs/proofs into a categorical
  modeling surface

## Purpose

If we use CatColab later, it should help with:

- keeping the categorical architecture in one place
- making the object/morphism structure legible to collaborators
- reducing drift between architecture markdown files
- giving a visual home to diagrams that are currently spread across docs

It should **not** own security claims, implementation correctness, or node
policy. Those remain with:

- Lean: theorem/spec layer
- Rust: runtime and consensus enforcement
- Python: research/oracle/reference computation

## High-Level Split

| Layer | Best Owner | CatColab Role |
|------|------------|---------------|
| Hardness theorems | Lean | Concept map only |
| Runtime validation | Rust | Interface/boundary map only |
| Heavy geometry/oracle computation | Python/Rust workers | Pipeline visualization only |
| Categorical semantics | docs + CatColab | Good fit |

## Core Objects

These are the main objects we would want to model.

| HCRYPT concept | CatColab-facing object idea | Notes |
|---------------|-----------------------------|-------|
| Nerve / site `X` | Base category / directed site | Underlies the presheaf/sheaf story |
| Fibration `F` | Structured object over `X` | Secret geometry |
| Stalk assignment | Presheaf/sheaf data | Vertex/edge fibers |
| Restriction maps `R_{v→e}` | Morphisms in the presheaf | Parallel transport / local compatibility |
| Cochain groups `C^k(X, F)` | Derived objects from the sheaf | Degreewise data containers |
| Coboundary `δ` | Morphism `C^k → C^{k+1}` | Fundamental operator |
| Adjoint `δ*` | Reverse/adjoint morphism | Used for Hodge decomposition |
| Laplacian `Δ = δ*δ + δδ*` | Derived endomorphism | Built from the secret geometry |
| Harmonic subspace `ker(Δ)` | Distinguished subobject | Message-bearing space |
| Public fingerprint / class | Quotient/projection object | Public shadow of hidden geometry |
| Oracle stages `F_full`, `F_zk`, `F_hash` | Three related sheaf-like views | Already used in the docs |
| Ledger / chain state | Colimit/state object | Runtime-side semantic target |

## Core Morphisms

| HCRYPT morphism | Role |
|----------------|------|
| `R_{v→e}` | Local restriction / transport |
| `δ` | Pushes local data to disagreements on higher cells |
| `δ*` | Pulls data back / adjoint operator |
| `π_H` | Hodge projection onto `ker(Δ)` |
| `pub : hidden → public` | Public projection / class fingerprint |
| `η₁ : F_full → F_zk` | Oracle reduction / witness-producing step |
| `η₂ : F_zk → F_hash` | Compression / public commitment step |
| `applyTransaction` | State transition on ledger semantics |
| `applyBlock` | Colimit-style state update |

## Main Diagrams To Model

### 1. Sheaf / Cochain Diagram

```text
X^op --F--> Vect

C^0(X,F) --δ--> C^1(X,F) --δ--> C^2(X,F)
```

This is the basic local-to-global geometry diagram. It is the first thing worth
rendering because almost everything else is derived from it.

### 2. Hodge Diagram

```text
C^k(X,F)
  = ker(Δ) ⊕ im(δ) ⊕ im(δ*)
```

This is not just crypto flavor text; it is the semantic reason:

- message lives in `ker(Δ)`
- noise lives in `im(δ) ⊕ im(δ*)`
- decryption is projection back onto the harmonic part

### 3. Hidden/Public Projection Diagram

```text
hidden fibration / hidden Δ / hidden ker(Δ)
                 |
                 v
        public fingerprint / class / cochain
```

This is the core hardness picture. In CatColab terms, this is where we would
want the public object to visibly be a **quotient/shadow** of richer hidden
structure rather than “the same object with fields omitted.”

### 4. Oracle / Sheafification Pipeline

```text
F_full --η₁--> F_zk --η₂--> F_hash
```

This matches the docs already in use:

- `F_full`: full private geometry
- `F_zk`: witness-bearing / reduced representation
- `F_hash`: public/runtime-facing commitment layer

This is a strong candidate for CatColab because it is conceptually central and
easy to drift on when scattered across prose.

### 5. Chain / Colimit Diagram

```text
State₀ --> State₁ --> State₂ --> ...
  |         |         |
Block₀    Block₁    Block₂
```

The blockchain is the directed accumulation of valid state transitions. We do
not need CatColab to “verify” that, but it could be a helpful conceptual home
for the colimit story used in the docs.

## CatColab-Facing Views

If this becomes a real CatColab experiment later, I’d split it into views.

| View | Scope | Existing doc anchor |
|------|-------|---------------------|
| Site / sheaf view | Nerve, stalks, restrictions, cochains | `docs/PRIMITIVES.md`, `docs/GEOMETRY.md` |
| Hodge / hardness view | `δ`, `δ*`, `Δ`, `ker(Δ)`, hidden/public ambiguity | `docs/SECURITY.md`, `lean/Hardness.lean` |
| Oracle / gate view | `η₁`, `η₂`, public judgments, boundary handling | `docs/GATE_ARCHITECTURE.md`, `docs/TRUST_BOUNDARIES.md` |
| Ledger / colimit view | Blocks, state transitions, key-image monotonicity | `docs/CONSENSUS.md`, `lean/Chain.lean` |
| Topos / logic view | Heyting truth collapse, sheaf semantics | `docs/CATEGORICAL_ARCHITECTURE.md`, `lean/Axioms/OracleModality.lean` |

## Proposed Minimal First Pass

If we ever actually port this into CatColab, start with the smallest useful
slice:

1. Base site / nerve object
2. Sheaf or presheaf object
3. Cochain objects `C^0`, `C^1`
4. Coboundary `δ`
5. Laplacian `Δ`
6. Public projection `pub`
7. Oracle pipeline `F_full --η₁--> F_zk --η₂--> F_hash`

That would already capture most of the semantic backbone without getting lost in
full blockchain detail too early.

## What Not To Offload

CatColab should not become the place where we pretend the hard parts are
settled.

Keep these elsewhere:

- Lean proofs of hardness, Heyting semantics, and formal obligations
- Rust byte validation, storage, networking, consensus enforcement
- Python/Rust numerical geometry and oracle implementation details
- Benchmarks, latency, proving backends, zkVM optimization

## One-Sentence Summary

CatColab looks like a plausible future home for the **categorical semantic map**
of hcrypt, especially the sheaf/cochain/oracle/colimit diagrams, but only as a
documentation-modeling layer above the existing Lean/Rust/Python split.
