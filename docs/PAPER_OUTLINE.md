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
samples have the form `b = h + e`, where `h ∈ ker(Δ)` is the harmonic cochain
and `e ∈ im(δ) ⊕ im(δ*)` is Hodge-structured noise. The public data does not
determine a unique `Δ` or `ker(Δ)`.

The proximity construction is then the verifier-facing companion theorem:

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
  `h ∈ ker(Δ)` and `e ∈ im(δ) ⊕ im(δ*)`.
- Main theorem: a certified projection theorem from accepted hidden/geometric
  state to a calibrated public target.
- Relationship to CVP: CVP is the known-lattice comparison problem, while
  Homotopical Encrypt recovery hides the operative kernel/operator.
- Lean formalization: definitions, reductions, projection chain, gates, and
  theorem boundaries are machine-checked.
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
- Cochain commitment construction and public shadow interface.
- Projection framework from hidden/geometric state to public finite evidence.
- Relationship to CVP through an explicit known-lattice comparison.
- Lean formalization of the main definitions, theorem boundaries, and projection
  gates.
- Reed-Solomon projection endpoint.
- Proximity/MCA corollary aligned with the paper vocabulary `C ⊆ (F^s)^n`, with
  canonical Homotopical Encrypt evaluation at `s = 1`.

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
h ∈ ker(Δ)
e ∈ im(δ) ⊕ im(δ*)
```

Here `h` is the harmonic cochain/global-section component and `e` is
Hodge-structured noise. The hidden-operator condition is that the public data
does not determine a unique `Δ` or `ker(Δ)`.

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

### 3. Mathematical Framework

Lean anchors:

- `Axioms/HelferFOL.lean`
- `Axioms/Heyting.lean`
- `Axioms/OracleModality.lean`
- `docs/HARDNESS_HELPER_DEPENDENCY_MAP.md`

#### 3.1 Helfer's Fibrational Semantics

Use this section to explain the provenance of the semantic layer. The paper
should cite Helfer for the motivation and label the Lean file as a formalized
interface used by Homotopical Encrypt, not as a claim of fully reproving the
external paper.

#### 3.2 Fibrational Identity Objects

Explain why public equality is not strict equality of hidden representatives.
This is where path/diagonal semantics and public classifiers enter the story.

#### 3.3 Homotopy Classes

Connect semantic quotienting to the later projection philosophy: public shadows
are allowed to identify representatives while preserving the invariants needed
by the verifier.

### 4. Cochain Commitment Framework

Lean anchors:

- `Axioms/CochainCommitment/*`
- `Proximity/PluckerShadow.lean`
- `Proximity/PluckerCochain/PublicBinding.lean`
- `TCB/*`

#### 4.1 Cochain Commitments

Define the commitment object and its intended role as the public handle on
hidden cochain data.

#### 4.2 Commitment Map

Describe the map from hidden/cochain data into public commitments, including
what is preserved and what is deliberately hidden.

#### 4.3 Projection Operator

Introduce projection as the operation that creates verifier-facing public
artifacts from hidden or geometric data.

#### 4.4 Fundamental Properties

State binding/well-formedness/non-collapse properties carefully. Any cryptographic
hash or byte-level claim belongs to the TCB/runtime boundary, while the Lean layer
owns the mathematical predicates and implications.

### 5. Projection Framework

Lean anchors:

- `Proximity/Projection.lean`
- `Proximity/ProjectionChain/Core.lean`
- `Proximity/Gates/*`
- `Proximity/CanonicalRS/*`
- `docs/PROXIMITY_PAPER_OUTLINE.md`

#### 5.1 Projection Theorem

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
local gates/certificates checked at their own stages.

#### 5.2 Preserved Structure

List the invariants preserved stage by stage: public binding, quotient-aware
shadow identity, local plane consistency, metric calibration, and final RS
well-formedness.

#### 5.3 Lost Structure

Be explicit that projection is lossy. The theorem is not injectivity. It is a
controlled public projection with calibrated non-collapse/far-separation
conditions where needed.

### 6. Relationship To CVP

Lean anchors:

- `CVP.lean`
- `Hardness.lean`

#### 6.1 Reduction From CVP

State the comparison direction precisely: known-lattice CVP is formalized, and
HCP can expose CVP-like instances after the hidden operator data has been fixed.

#### 6.2 Recovery Theorem

State the recovery implication that is actually formalized or intended: which
solver implies which other solver, under which presentation assumptions.

#### 6.3 Structural Comparison

Emphasize the distinction between:

- known-lattice closest-vector search;
- hidden-operator HCP;
- public projection/proximity verification.

This keeps the CVP relation useful without overstating it.

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
- `Proximity/*`: projection chain, gates, metrics, RS endpoint.
- `TCB/*`: runtime trust-boundary declarations.
- `docs/*`: paper maps, assumptions, and theorem correspondence.

#### 7.3 Theorem Correspondence

Give a Lean-to-paper table: definition names, theorem names, proof status, and
whether each item is project-native, a formalized external definition, or a
cited external theorem.

### 8. Corollaries And Applications

#### 8.1 Reed-Solomon Projection

Lean anchors:

- `Proximity/RS/ListDecoding.lean`
- `Proximity/RS/CorrelatedAgreement.lean`
- `Proximity/RS/ReedSolomon.lean`
- `Proximity/CanonicalRS/MCA/Concrete.lean`
- `Proximity/CanonicalRS/CitedBounds.lean`

State the paper-style endpoint over `C ⊆ (F^s)^n`, then explain why the concrete
Homotopical Encrypt endpoint evaluates this at width `s = 1`.

#### 8.2 Proximity Proof

State the proximity/MCA corollary as a verifier-facing consequence of the
projection chain plus cited RS bounds. Clearly separate Lean-proved equivalence
and adapter lemmas from the imported Johnson/list-decoding/BCHKS theorem slots.

### 9. Future Directions

#### 9.1 Cryptographic Protocol

Turn the mathematical commitment/projection framework into a concrete protocol
with explicit adversary games.

#### 9.2 Anonymous Identity System

Develop the public-shadow/hidden-representative architecture as an anonymous
identity mechanism.

#### 9.3 Sheaf Storage

Study storage and retrieval systems where public commitments expose only
controlled sheaf/cochain projections.

#### 9.4 Native Chain

Connect proof-carrying runtime evidence to a native verification chain.

#### 9.5 Complexity-Theoretic Extensions

Refine reductions, oracle separations, and hidden-operator hardness assumptions.

### Appendix A. Repository Dependency Graph

Include the dependency graph and build targets for the theorem surfaces used in
the paper.

### Appendix B. Lean/Paper Correspondence

Include two tables:

- Lean definitions vs paper definitions.
- Lean theorems vs paper theorems.

## Split Plan

If the material becomes too large, split it like this.

### Paper A: Harmonic Cochain Problem And Public Shadows

Main topic:

- HCP/CVP relationship.
- Hidden-operator strictness.
- Helfer-style public equality/classifier semantics.
- Commitment/public-shadow trust boundary.

Primary Lean modules:

- `CVP.lean`
- `Hardness.lean`
- `Axioms/HelferFOL.lean`
- `Axioms/Foundation.lean`
- `Axioms/CochainCommitment/*`
- `TCB/*`

Best title shape:

- The Harmonic Cochain Problem for Homotopical Encryption
- Public Shadows and Hidden Kernels in Homotopical Encryption

### Paper B: Certified Proximity Projection To Reed-Solomon MCA

Main topic:

- Plucker/cochain/plane/RS projection chain.
- Stage gates and final gates.
- Paper-style MCA endpoint.
- Cited RS bound boundary.
- Final source-to-RS far-separation theorem.

Primary Lean modules:

- `Proximity/*`
- `Proximity/RS/*`
- `Proximity/CanonicalRS/*`
- `Proximity/Gates/*`

Best title shape:

- Certified Projection Chains to a Reed-Solomon MCA Endpoint
- From Hodge Public Shadows to Reed-Solomon Proximity Targets

### Paper C: Runtime Evidence And Proof-Carrying Chain Integration

Main topic:

- Evidence roots.
- Runtime hash/proof/verifier boundary.
- Wire formats.
- Consensus integration.
- TCB minimization.

Primary Lean/docs surfaces:

- `TCB/*`
- `Gates/*`
- `Consensus/*`
- `docs/TRUST_BOUNDARIES.md`
- `docs/WIRE_FORMAT.md`
- `docs/GATE_ARCHITECTURE.md`

This can wait until the math preprint is stable.

## Recommended First Preprint

The strongest first preprint is probably a combined Paper A + Paper B, but with
the scope controlled:

- lead with hardness;
- present proximity as the public verification bridge;
- state the final source-to-RS far-separation theorem as the main remaining
  conditional if it is not fully proved by submission;
- keep cited coding-theory inputs in a clearly labeled trusted boundary;
- avoid broad runtime/performance claims.

If the final far-separation proof is completed before submission, the preprint
can be pitched as a full Lean-backed projection theorem. If not, it is still a
credible formal architecture/preprint with a precise theorem-slot inventory.

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
