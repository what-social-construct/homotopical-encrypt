# Homotopical Encryption Paper Outline And Split Plan

This document is the high-level publication plan for the Lean-backed
Homotopical Encryption work. It explains how the hardness story, semantic
foundations, proximity projection, and runtime trust boundary are staged across
the current three-paper plan: Paper 1 is HCP foundations, Paper 2 is the
protocol/commitment layer, and Paper 3 is the standalone capacity-radius
coding manuscript in `papers/proximity-prize/`.

## Current Status And Source Of Truth

This is now a planning and cross-paper scope document, not the current table of
contents. The manuscript source of truth is `papers/paper1/main.tex` together
with the files under `papers/paper1/sections/`. The generated `main.toc` is the
most direct snapshot of the compiled organization.

The current Paper 1 structure is:

1. Introduction.
2. The Harmonic Cochain Problem.
3. CVP Comparison And Kernel Ambiguity.
4. Axioms And Semantics.
5. Cochain Commitments: Private Witnesses And Public Artifacts.
6. Reed--Solomon Projection And Proximity.
7. Future Directions.
8. Appendices for the Paper--Lean cross-reference and file-by-file source
   coverage.

The planning outline below is close to that structure, but the manuscript made
four editorial improvements:

- formal-verification correspondence moved from a full body section into the
  appendices, keeping the mathematical narrative uninterrupted;
- the commitment/public-artifact section now leads with the concrete cochain
  object and ends with Plucker coordinates as the handoff to proximity;
- the proximity material is expanded into eight subsections rather than the
  four-item summary here;
- the five detailed future-work categories were compressed into protocol and
  complexity-theoretic boundaries, with product/runtime details assigned to
  Paper 2 and unnumbered future product work.

Accordingly, use this document for thesis, scope, and paper-split decisions.
Use the LaTeX manuscript for present section order and theorem placement.

## Core Thesis

Homotopical Encryption should be presented first through the **Harmonic Cochain
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

In Homotopical Encryption, HCP is instantiated in a hidden-operator model. Public
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

## Planning Outline And Manuscript Crosswalk

This is the planning outline from which the current manuscript was developed.
It still records the intended narrative, but headings below do not override
the current LaTeX organization.

### Abstract

Touch the following points in order:

- Harmonic Cochain Problem: public cochain/shadow data does not determine the
  operative Hodge/Laplacian kernel.
- Hodge-structured noise model: public samples have shape `b = h + e` with
  `h ∈ ker(Δ_1)` and `e ∈ im(δ_0) ⊕ im(δ_1*)`.
- Main theorem: a certified projection theorem from accepted hidden/geometric
  state to a calibrated public target.
- Relationship to CVP: CVP is the known-lattice comparison problem, while
  Homotopical Encryption recovery hides the operative kernel/operator.
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
  vocabulary `C ⊆ (F^s)^n`, with canonical Homotopical Encryption evaluation at
  `s = 1`.

### 2. Harmonic Cochain Problem

Lean anchors:

- `HCP.lean`
- `Hardness.lean`
- `CVP.lean`
- `Laplacian/*`
- `Axioms/Foundation.lean`

#### 2.1 Problem Definition

Define HCP as the central recovery problem:

> Given public cochain/class-level data associated to a Hodge system, recover
> the harmonic cochain determined by the operative Laplacian kernel.

Use the Homotopical Encryption public-sample model:

```text
b = h + e
h ∈ ker(Δ_1)
e ∈ im(δ_0) ⊕ im(δ_1*)
```

Here `h` is the harmonic degree-one cochain and `e` is Hodge-structured noise.
It is not being identified with the degree-zero global-section space. The
hidden-operator condition is that the public data does not determine a unique
`Δ_1` or `ker(Δ_1)`.

State explicitly what is public, what is hidden, and what counts as recovery.

#### 2.2 Computational Model

Separate:

- Lean mathematical predicates.
- External computational hardness assumptions.
- Runtime/TCB obligations for bytes, hashing, parsing, and proof verification.

#### 2.3 Intuition

CVP asks for a closest vector in an explicitly presented lattice. HCP asks for
the projection of the observed cochain into the operative Hodge kernel, and in
the Homotopical
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
interface used by Homotopical Encryption, not as a claim of fully reproving the
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

### 6. Reed-Solomon Projection And Proximity

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
  -> accepted committed cocycle / local syndrome
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
Homotopical Encryption endpoint evaluates this at width `s = 1`.

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

Current aggregate audit command:

```text
lake build Axioms TCB Chain Gates Proximity
```

Treat this as an audit recipe, not a permanent status claim; rerun it and the
full build against the submission checkpoint.

#### 7.2 Repository Structure

Explain the module split:

- `Axioms/*`: semantic and commitment interfaces.
- `HCP.lean`: HCP, public fibers, cipher correctness, and operative targets.
- `CVP.lean`, `Hardness.lean`: known-lattice comparison and impossibility framing.
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

- `HCP.lean`
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

- Homotopical Encryption: Hidden Hodge Operators and the Harmonic Cochain Problem
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

The bounded first endpoint is now recorded in
[`papers/paper2/SCOPE.md`](../papers/paper2/SCOPE.md): one proof-carrying
accepted transition. Broader consensus and control topics above are deferred
unless that scope is expanded. The smaller commitment/extraction/metric
profile shared with Paper 3 can be fixed before the whole protocol is complete.

### Paper 3: Capacity-Radius Proximity

Paper 3 is *Capacity-Radius Proximity for Smooth-Domain Reed--Solomon Codes*,
with its manuscript in `papers/proximity-prize/` and standalone Lean target
`ProximityPrize`.

Its scope is universal list decoding and pair mutual correlated agreement,
the exact capacity-grid list equality and next-shell obstruction, the
large-field smooth family, a selected exact small-radius MCA transition,
and a source-to-code calibration interface. The selected application target
is the actual cochain commitment and projection already in Lean, not a new
commitment carrier; see the
[object trace](COCHAIN_PROXIMITY_TRACE.md). Its counting theorems do not depend
on finishing Paper 2's protocol. Its commitment-specific radius theorem needs
one bounded shared profile and an original-source metric comparison.

The remaining formal-parity work is the all-parameter smooth-family
realization, complete list phase split/real interval, boundary-field real
supremum, and standalone general distance interpretation. The concrete
canonical plane/pair distance equality and public-observation pullback
calibration already exist outside the standalone target. The detailed queue is
[`papers/proximity-prize/SEMANTIC_PARITY.md`](../papers/proximity-prize/SEMANTIC_PARITY.md).
The selected application still supplies a meaningful original-source metric,
a nonempty actual far region, and the quantitative source-to-plane/pair
comparison. Its challenge experiment must either sample after the pair is
fixed or prove the chosen fixed mix good. Rust experiments are useful for
implementation parity and counterexamples, not required to prove the radius.

### Unnumbered Future Product / Whitepaper Material

Product narrative, deployment assumptions, privacy/identity/storage/payment
flows, ecosystem comparisons, and operational positioning are future work.
They are not Paper 3 and do not enlarge the claim surface of the three
manuscripts above.

## Recommended First Preprint

The strongest first preprint is Paper 1: lead with hidden-operator HCP
hardness, develop the semantic and public-artifact boundary, then present the
projection/RS/MCA endpoint as the finite verifier-facing corollary. Keep the
CS/protocol machinery visible only as theorem-surface context or future work;
avoid broad runtime, performance, consensus, or chain-architecture claims.

## Lean Checkpoints Before First Submission

The original immediate-work list has partly been absorbed by the current
manuscript and Lean hierarchy. The current checkpoints are:

1. Keep the top-level calibrated-bridge plumbing synchronized with the exact
   status of the supplied far-separation witness; do not describe the
   project-specific witness as internally proved unless it has been discharged.
2. Continue burning down concrete Plucker/cochain/plane construction inputs,
   while preserving the distinction between proved consequences and supplied
   construction data.
3. Maintain the typed, element-dependent cochain bridge:
   accepted commitment payloads bind to a sheaf, decode to exact one-cochains,
   and hence satisfy the degree-one cocycle equation.
4. Keep `CitedBounds` as the isolated coding-theory literature boundary.
5. Keep the provenance and Paper--Lean correspondence appendices synchronized
   with declaration renames and status changes.
6. Before submission, rerun the aggregate Lean build and the full LaTeX build;
   do not rely on historical build counts in this outline.
