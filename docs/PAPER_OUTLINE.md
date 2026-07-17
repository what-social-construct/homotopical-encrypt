# Homotopical Encrypt Paper Outline And Split Plan

This document is the high-level publication plan for the Lean-backed
Homotopical Encrypt work. It explains how the hardness story, semantic
foundations, proximity projection, and runtime trust boundary should be staged
across one preprint or split into multiple papers.

## Core Thesis

Homotopical Encrypt should be presented first through the **Harmonic Cochain
Problem (HCP)**, a hidden-operator hardness problem:

```text
public cochain / shadow data
  does not determine
the operative Hodge/Laplacian kernel
  whose harmonic cochains control recovery
```

Working definition:

> **Harmonic Cochain Problem (HCP).** Given public cochain/class-level data
> associated to a Hodge system, recover the harmonic cochain determined by the
> operative Laplacian kernel.

In Homotopical Encrypt, HCP is instantiated in a hidden-operator model. Public
samples have the form `b = h + e`, where `h ∈ ker(Δ_1)` is the harmonic
cochain and `e ∈ im(δ_0) ⊕ im(δ_1*)` is Hodge-structured noise. The public data
does not determine a unique `Δ_1` or `ker(Δ_1)`.

The proximity construction is then the verifier-facing projection theorem:

```text
accepted hidden/geometric state
  -> public Plucker/cochain/plane shadow
  -> Reed-Solomon proximity target
```

So the paper should not begin with Reed-Solomon. It should begin with the
security problem: what is hidden, what is public, what an adversary would need
to recover, and why a known-lattice CVP oracle is not enough to solve
hidden-operator HCP globally. The RS/proximity section then answers a separate
question: how a verifier can check finite public proximity evidence without
recovering the private representative.

## Working Outline

This is the best shape for a first preprint if we want a single coherent
mathematical story. It leads with the hardness problem and treats the
Reed-Solomon/MCA construction as the finite verifier-facing corollary.

### Abstract

Touch the following points in order:

- Harmonic Cochain Problem: public cochain/shadow data does not determine the
  operative Hodge/Laplacian kernel.
- Hodge-structured noise model: public samples have shape `b = h + e` with
  `h ∈ ker(Δ_1)` and `e ∈ im(δ_0) ⊕ im(δ_1*)`.
- Main theorem: a certified projection theorem from accepted hidden/geometric
  state to a calibrated public target.
- Relationship to CVP: CVP is the known-lattice comparison problem, while
  Homotopical Encrypt recovery hides the operative kernel/operator.
- Lean formalization: definitions, reductions, object-local invariants,
  projection-stage certificates, and theorem boundaries are machine-checked.
- Proximity corollary: the endpoint is aligned with the Reed-Solomon MCA
  vocabulary from the Proximity Prize paper, with cited bounds imported at a
  clearly labeled boundary.

### 1. Introduction

#### 1.1 Motivation

Open with the security shape:

```text
public cochain / shadow data
  does not determine
the operative Hodge/Laplacian kernel
  whose harmonic cochains control recovery
```

The motivating tension is that public verification needs finite artifacts, but
security should not collapse to recovering the private representative or hidden
operator.

#### 1.2 Contributions

- Harmonic Cochain Problem and hidden-operator formulation.
- Relationship to CVP through an explicit known-lattice comparison.
- Axiomatic public/private data boundary.
- Cochain commitment construction and public shadow interface.
- Lossy public-shadow framework.
- Lean formalization of the main definitions, theorem boundaries, object-local
  invariants, and projection-stage certificates.
- Reed-Solomon projection chain and MCA endpoint aligned with the paper
  vocabulary `C ⊆ (F^s)^n`, with canonical Homotopical Encrypt evaluation at
  `s = 1`.

### 2. Harmonic Cochain Problem

Lean anchors:

- `Hardness.lean`
- `CVP.lean`
- `Laplacian/*`
- `Axioms/Foundation.lean`

#### 2.1 Problem Definition

Define HCP as the central recovery problem:

> Given public cochain/class-level data associated to a Hodge system, recover
> the harmonic cochain determined by the operative Laplacian kernel.

Use the Homotopical Encrypt public-sample model:

```text
b = h + e
h ∈ ker(Δ_1)
e ∈ im(δ_0) ⊕ im(δ_1*)
```

Here `h` is the harmonic cochain/global-section component and `e` is
Hodge-structured noise. The hidden-operator condition is that the public data
does not determine a unique `Δ_1` or `ker(Δ_1)`.

State explicitly what is public, what is hidden, and what counts as recovery.

#### 2.2 Computational Model

Separate:

- Lean mathematical predicates.
- External computational hardness assumptions.
- Runtime/TCB obligations for bytes, hashing, parsing, and proof verification.

#### 2.3 Intuition

CVP asks for a closest vector in an explicitly presented lattice. HCP asks for
a harmonic cochain in the operative Hodge kernel, and in the Homotopical
Encrypt model that kernel is not explicitly presented by the public data.

### 3. CVP Comparison And Kernel Ambiguity

Lean anchors:

- `CVP.lean`
- `Hardness.lean`
- `Laplacian/*`

#### 3.1 Reduction Direction

State the comparison direction early: once the Hodge operator or harmonic
kernel is presented, harmonic recovery exposes a known-lattice CVP-style
problem.

#### 3.2 Oracle Insufficiency

State the hidden-operator separation: a CVP oracle for explicitly presented
lattices does not determine the hidden operator or kernel selected by public
data.

#### 3.3 Structural Comparison

Emphasize the distinction between:

- known-lattice closest-vector search;
- hidden-operator HCP;
- public projection/proximity verification.

### 4. Axioms, Semantics, And Public Data

Lean anchors:

- `Axioms/Foundation.lean`
- `Axioms/Fibration.lean`
- `Axioms/HomotopyClass.lean`
- `Axioms/HelferFOL.lean`
- `Axioms/Heyting.lean`
- `Axioms/OracleModality.lean`
- `Axioms/SheafCoherence.lean`
- `Axioms/SpectralBounds.lean`
- `Gates/Spectral.lean`
- `Tsirelson.lean`
- `Axioms/CochainCommitment/*`
- `docs/HARDNESS_HELPER_DEPENDENCY_MAP.md`

#### 4.1 Helfer's Fibrational Semantics

Use this section to explain the provenance of the semantic layer. The paper
should cite Helfer for the motivation and label the Lean file as a formalized
interface used by Homotopical Encrypt, not as a claim of fully reproving the
external paper.

#### 4.2 Fibrational Identity Objects

Explain why public equality is not strict equality of hidden representatives.
This is where path/diagonal semantics and public classifiers enter the story.

#### 4.3 Homotopy Classes

Connect semantic quotienting to the later projection philosophy: public shadows
are allowed to identify representatives while preserving the invariants needed
by the verifier.

#### 4.4 Axiom Surfaces

Explain the role of the `Axioms/*` folder early: foundational cochain/Hodge
assumptions, fibration and homotopy-class interfaces, Heyting/oracle semantics,
sheaf-coherence/spectral interfaces, and cochain-commitment assumptions.
Spectral admissibility belongs here as a mathematical public-judgment surface:
`Axioms/SpectralBounds.lean` and `Tsirelson.lean` record the theorem-facing
spectral/Tsirelson predicates used by HCP and public oracle judgments, while
`Gates/Spectral.lean` packages the corresponding object-local admissibility
wrapper. Their protocol use as Proof-of-Value policy is deferred to Paper 2.

### 5. Public Artifact Stack And Lossy Projection

Lean anchors:

- `Axioms/CochainCommitment/*`
- `Proximity/PluckerShadow.lean`
- `Proximity/PluckerCochain/PublicBinding.lean`
- `TCB/*`

#### 5.1 Public And Private Data Handling

Use the trust-boundary docs: public artifacts include commitments, topology
hashes, roots, public shadows, oracle judgments, and proof-carrying artifacts;
private data includes the fibration representative, restriction maps, full
cochains, and the Hodge operator/kernel.

#### 5.2 The Artifact Stack

Explain the layered public-artifact stack:

```text
hidden/private object
  -> public shadow / compressed projection
  -> commitment/root/hash artifact
  -> proof-carrying artifact
  -> verifier judgment
```

Hashes, roots, and commitments bind to or summarize previous layers; they do
not replace the mathematical witness or proof obligation.

#### 5.3 Cochain Commitments

Define the commitment object and its intended role as the public handle on
hidden cochain data.

#### 5.4 Commitment Map

Describe the map from hidden/cochain data into public commitments, including
what is preserved and what is deliberately hidden.

#### 5.5 Sheaf Storage And Witness Material

Explain that storage roots, topology hashes, cochain roots, nullifiers, and
proof objects are public artifacts in the stack. Full sheaf/cochain/fibration
data remains witness material unless explicitly exposed.

#### 5.6 Lossy Projection

Introduce projection as the operation that creates verifier-facing public
artifacts from hidden or geometric data. The concrete Plucker/cochain/plane/RS
projection chain belongs in Section 6.

#### 5.7 Fundamental Properties

State payload shape, topology compatibility, cryptographic binding interfaces,
and proof-carrying artifact validity carefully. Non-collapse belongs to the
projection-stage gates in Section 6. Any cryptographic hash or byte-level claim
belongs to the TCB/runtime boundary, while the Lean layer owns the mathematical
predicates and implications.

### 6. Reed-Solomon Projection And MCA

Lean anchors:

- `Proximity/ProjectionChain/Core.lean`
- `Proximity/Gates/*`
- `Proximity/RS/ListDecoding.lean`
- `Proximity/RS/CorrelatedAgreement.lean`
- `Proximity/RS/ReedSolomon.lean`
- `Proximity/CanonicalRS/*`
- `docs/PROXIMITY_PAPER_OUTLINE.md`

#### 6.1 Projection Chain

Use the staged chain:

```text
FrameWitness
  -> Projective Plucker shadow
  -> committed cochain / local syndrome
  -> PlaneShadow R i
  -> finite-field received word
  -> canonical Reed-Solomon target
```

The proof architecture should read as one orchestrated projection chain, with
local proximity gates/certificates checked at their own stages: public-shadow
respect and metric invariance at the source/Plucker surface, syndrome adequacy
at the cochain bridge, semantic alignment at the plane/RS extraction, and
far-region non-collapse at the final RS endpoint.

#### 6.2 Canonical Reed-Solomon Endpoint

State the paper-style endpoint over `C ⊆ (F^s)^n`, then explain why the concrete
Homotopical Encrypt endpoint evaluates this at width `s = 1`.

#### 6.3 Mutual Correlated Agreement

State MCA in the vocabulary of the Proximity Prize problem statement. Clearly
separate Lean-proved definitions/equivalences from the imported
Johnson/list-decoding/BCHKS theorem slots.

#### 6.4 Proximity Corollary

State the proximity/MCA corollary as a verifier-facing consequence of the
projection chain plus cited RS bounds.

### 7. Formal Verification

#### 7.1 Lean Formalization

Include a status table with these categories:

- Lean-proved.
- explicit construction input.
- trusted cited theorem boundary.
- runtime/TCB-owned.
- remaining theorem slot.

Recommended build commands:

```text
lake build CVP Hardness Axioms.HelferFOL
lake build Proximity
```

#### 7.2 Repository Structure

Explain the module split:

- `Axioms/*`: semantic and commitment interfaces.
- `CVP.lean`, `Hardness.lean`: known-lattice comparison and hardness framing.
- `Gates/*`: aliases and lemmas for object-local exact/oracle/stage
  invariants.
- `Proximity/*`: projection chain, proximity gates, metrics, RS endpoint.
- `TCB/*`: runtime trust-boundary declarations.
- `docs/*`: paper maps, assumptions, and theorem correspondence.

#### 7.3 Theorem Correspondence

Give a Lean-to-paper table: definition names, theorem names, proof status, and
whether each item is project-native, a formalized external definition, or a
cited external theorem.

### 8. Future Directions

#### 8.1 Cryptographic Protocol

Turn the mathematical commitment/projection framework into a concrete protocol
with explicit adversary games.

#### 8.2 Anonymous Identity System

Develop the public-shadow/hidden-representative architecture as an anonymous
identity mechanism.

#### 8.3 Sheaf Storage

Study storage and retrieval systems where public commitments expose only
controlled sheaf/cochain projections.

#### 8.4 Native Chain

Connect proof-carrying runtime evidence to a native verification chain.

#### 8.5 Complexity-Theoretic Extensions

Refine reductions, oracle separations, and hidden-operator hardness assumptions.

### Appendix A. Repository Dependency Graph

Include the dependency graph and build targets for the theorem surfaces used in
the paper.

### Appendix B. Lean/Paper Correspondence

Include two tables:

- Lean definitions vs paper definitions.
- Lean theorems vs paper theorems.

## Paper Split

### Paper 1: Math And Formalization

Paper 1 is the math/formalization paper. It should stay centered on the HCP
hardness story and the Lean theorem surfaces, with the RS/MCA endpoint presented
as a verifier-facing projection corollary rather than as the source of security.

Expected scope:

- Harmonic Cochain Problem and hidden-operator formulation.
- Hidden-kernel/operator ambiguity and CVP comparison.
- Helfer-style public equality/classifier semantics.
- Axiomatic public/private boundary.
- Spectral/Tsirelson public judgment interfaces as mathematical axiom surfaces
  and object-local admissibility wrappers, excluding Proof-of-Value policy.
- Cochain commitment construction and public-shadow interface.
- Lossy public-shadow/projection framework.
- Certified projection chain to a Reed-Solomon/MCA endpoint.
- Lean theorem-surface correspondence and status labels.

Primary Lean modules:

- `CVP.lean`
- `Hardness.lean`
- `Laplacian/*`
- `Axioms/*`
- `Axioms/SpectralBounds.lean`
- `Gates/Spectral.lean`
- `Tsirelson.lean`
- `Axioms/CochainCommitment/*`
- `TCB/*`
- `Proximity/*`
- `Proximity/RS/*`
- `Proximity/CanonicalRS/*`

Best title shape:

- Homotopical Encrypt: Hidden Hodge Operators and the Harmonic Cochain Problem
- The Harmonic Cochain Problem for Homotopical Encryption
- Public Shadows and Hidden Kernels in Homotopical Encryption

### Paper 2: CS/Protocol Paper

Paper 2 is the CS/protocol paper. It should consume the mathematical and formal
surfaces from Paper 1 and explain how they become protocol evidence and runtime
validation.

Expected scope:

- Proof-carrying verification.
- Gate certificates as protocol evidence.
- Runtime trust boundaries.
- Oracle/worker/attestation model.
- Consensus and Proof of Value.
- Coregulator predict/observe/update control loop.
- Ledger/state-transition conservation and key-image monotonicity.
- Runtime homotopy refinement/parity against the Lean semantic classifier.
- Vertra chain architecture.
- Rust implementation boundary.

Primary Lean/docs surfaces:

- `TCB/*`
- `Gates/*`
- `Axioms/Coregulator.lean`
- `Axioms/Ledger.lean`
- `Axioms/PythonHomotopyRefinement.lean`
- `Consensus/*`
- `Chain.lean`
- `docs/TRUST_BOUNDARIES.md`
- `docs/WIRE_FORMAT.md`
- `docs/GATE_ARCHITECTURE.md`
- `docs/CONSENSUS.md`

This should wait until the math/formalization paper is stable.

## Recommended First Preprint

The strongest first preprint is Paper 1: lead with hidden-operator HCP
hardness, develop the semantic and public-artifact boundary, then present the
projection/RS/MCA endpoint as the finite verifier-facing corollary. Keep the
CS/protocol machinery visible only as theorem-surface context or future work;
avoid broad runtime, performance, consensus, or chain-architecture claims.

## Immediate Lean Work Before First Submission

1. State a top-level theorem that consumes `CitedBounds.bounds`, hard gates,
   radius calibration, and final far separation, then returns the calibrated
   bridge.
2. Burn down concrete Plucker/cochain/plane construction inputs as much as
   possible.
3. Refine coarse naturality fields into explicit restriction/coboundary
   commuting squares.
4. Keep `CitedBounds` as the only coding-theory axiom boundary.
5. Add a short provenance appendix in the paper for `HelferFOL`, `CVP`, and
   Proximity Prize coding-theory definitions.
