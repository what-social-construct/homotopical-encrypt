# Lean formalization and manuscript review

This workspace accompanies the project's mathematical and protocol research
drafts. The public-review package preserves the repository layout:
`lean/`, `papers/` and selected `docs/` sit under one root. See the
[review scope and release record](../PUBLIC_REVIEW.md) and the shared
[manuscript parity register](../SEMANTIC-PARITY.md).

The project [MIT license](../LICENSE) is included at the package root.

## Start here

| Surface | Entry point | Claim boundary |
|---|---|---|
| Paper 1: hidden operators and HCP | [HCP.lean](HCP.lean), [Hardness.lean](Hardness.lean), [CVP.lean](CVP.lean) | Hidden-operator ambiguity, public-class comparisons and discrete-CVP relationships, including the [actual integral cellular family](HCP/README.md) in a proved homological-test fragment. These structural results are not a computational security theorem; CVP hardness remains an external assumption. |
| Cellular-sheaf and Hodge mathematics | [Sheaf.lean](Sheaf.lean), [Laplacian.lean](Laplacian.lean), [Helfer.lean](Helfer.lean) | Concrete cochain/Hodge constructions and stated transport/invariance results. Supplied realization and invariance hypotheses remain explicit. |
| Paper 3: universal coding results | [ProximityPrize.lean](ProximityPrize.lean), [hierarchy guide](Proximity/README.md) | All nine named generic coding statements have Lean endpoints, including the actual all-parameter field family, phase split, real thresholds and attained distances. Its 33-module closure does not import the project's cited RS-bound axioms or require the protocol implementation. Application profile obligations remain separate. |
| Cochain-specific proximity application | [Proximity.lean](Proximity.lean), [object trace](../docs/COCHAIN_PROXIMITY_TRACE.md) | Original-payload extraction and an explicit modular cellular profile with `d_C ≤ d_P = D_RS ≤ 2d_C`, a capacity-far payload and diagonal-family challenge guarantee. Euclidean/HCP and arbitrary fixed-challenge comparisons retain their separate boundaries. |
| Paper 2: bounded protocol core | [Protocol/Core.lean](Protocol/Core.lean), [core guide](Protocol/README.md) | A conservative finite-resource transition, computed successor, conservation/replay endpoints, candidate-indexed evidence and same-proposal quorum attachment, under explicit valuation, authorization, snapshot and authentication profiles. See the [current validation record](../SEMANTIC-PARITY.md#current-protocol-validation). [Protocol.lean](Protocol.lean) retains the broader compatibility surface. |
| Sheaf storage and projection gates | [Protocol/Storage/Core.lean](Protocol/Storage/Core.lean), [storage guide](Protocol/Storage/README.md) | One original snapshot/cochain context, six typed projection/evidence levels, exact manifests/receipts, and the same-candidate history anchor with actual gate-database inclusion. Authentication/codec profiles remain explicit; anchoring does not supply a far witness. |
| Recipient recovery and rotation | [Protocol/Ephemeral.lean](Protocol/Ephemeral.lean), [actual axis rotation](HCP/AxisRotation.lean) | Integral Hodge/sample transport and same-integer-coefficient recovery by either target or retained base key. Private delivery receipts and original bound-sample migration keep channel, authorization and decoder contracts explicit; no efficient codec, secure channel or lifecycle/privacy theorem is inferred. |
| Conditional owned-resource transfer | [Protocol/Transfer.lean](Protocol/Transfer.lean) | Fixed-snapshot unit resource transfer, public input-derived nullifier and exact metadata/intent checks. Primitive results at the trusted decoder derive the existing update, with typed acyclic roots and original artifact/manifest/history joins. No new secure primitive, Rust refinement or consensus finality is claimed. |
| One-shot integrity experiment | [Protocol/Transfer/Security.lean](Protocol/Transfer/Security.lean) | Shared soundness-free checks reduce actual accepted-invalid attempts to authorization/payload failures. Explicit released view, auxiliary input and one PMF give their conditional sum bound, without independence or a new primitive estimate. |
| Public artifact and verification contracts | [TCB.lean](TCB.lean), [Axioms.lean](Axioms.lean) | Existing payload/artifact/observation interfaces and their conditional consequences. Concrete bytes, hashing, proof/signature verification and runtime refinement are separate obligations. |
| Legacy chain model | [Chain.lean](Chain.lean) | Retained compatibility model. Its spectral validator identity, cumulative-gap fork choice and raw cochain-sum balance are not the semantics or security claims of the new bounded core. |

The manuscripts are [Paper 1](../papers/paper1/README.md) and
[Paper 3](../papers/proximity-prize/README.md). Paper 2 currently has a
[initial manuscript text](../papers/paper2/DRAFT.md), [scope map](../papers/paper2/README.md), [bounded completion plan](../papers/paper2/SCOPE.md)
and working bibliography; it has no TeX manuscript or PDF yet.

## Reproduce the Lean checks

The toolchain is pinned by [lean-toolchain](lean-toolchain) to
`leanprover/lean4:v4.35.0`. [lakefile.lean](lakefile.lean) and
[lake-manifest.json](lake-manifest.json) pin Mathlib to
`56a005855ea17e0b0958f73ec801ae140b0a1679` (`v4.35.0`) and record its
transitive revisions. Source modules use `module`, public imports and exposed
public definitions. Validation for this pin is recorded separately from the
preserved Lean 4.24.0 baseline in the shared register.
Install elan, then run from the package root:

```sh
cd lean
lake exe cache get
lake build
lake build Protocol.Core Protocol.Ledger.Examples Protocol.Ledger.EvidenceExamples Protocol.Storage.Core Protocol.Storage.Examples Protocol.Storage.AnchorExamples Protocol.Storage.CanonicalRS Protocol.Storage.CanonicalThreeLevel Protocol.Storage.CanonicalCalibration HCP.AxisFamily TCB.HCPAxisFamily Protocol.Ephemeral.Examples Protocol.Ephemeral.HCP Protocol.Transfer
```

The cache command retrieves the pinned Mathlib build cache; it avoids a
source rebuild of that dependency. The examples are checked explicitly because they are separate from the
production aggregate. For focused review, use `lake build ProximityPrize`
for the standalone coding target, `lake build Protocol.Core` for the bounded
protocol core, or `lake build Protocol.Storage.Core` for the storage and gate
adapters. The Lean build needs the pinned Lean/Mathlib dependencies; Rust
and Python prototypes are not build dependencies.

The [Axiom Stacks library](https://github.com/AxiomMath/Stacks#readme) was
checked as a possible reuse source on 2026-11-05. Its
[Lean pin](https://raw.githubusercontent.com/AxiomMath/Stacks/main/lean-toolchain)
is `v4.34.0-rc2`, and its
[Lake configuration](https://raw.githubusercontent.com/AxiomMath/Stacks/main/lakefile.toml)
pins Mathlib to `16edf57de7933555826307a3d81b4391a3657a09`; these differ
from this workspace. Its homological and site/sheaf modules may be future
interoperability references, but no individual theorem was identified that
closes the current quantitative source-to-pair comparison. Direct adoption
would require a separate compatibility/review task. The library's README
also distinguishes human-reviewed `StacksCore` from `StacksFrontier`;
the umbrella `Stacks` import includes both. No dependency was added here.

Build commands describe reproducible checks, not a claim that the current
release has passed them. Consult the release record for the exact validated
source snapshot, targets, theorem-dependency report and limitations.
The [mathematics/storage validation guide](../docs/MATH_STORAGE_VALIDATION.md)
contains the expanded endpoint audit commands.

## Assumptions and trusted boundaries

Definitions under `Axioms/` often name explicit propositions or structures
whose proofs an application must supply. A theorem proved from those inputs
does not instantiate them or establish primitive cryptographic security.

[Concrete/CanonicalRS/CitedBounds.lean](Proximity/Concrete/CanonicalRS/CitedBounds.lean)
contains seven project `axiom` declarations for its literature-bound package,
including two numerical witness constants. They are an explicit trusted
boundary for the concrete RS application, separate from the standalone
`ProximityPrize` proofs. They should also be distinguished from ordinary Lean
logical dependencies such as `propext`, `Classical.choice` and `Quot.sound`.

Some arithmetic certificates use `native_decide`. On Lean 4.35 their reports
include generated `_native.native_decide.ax_` certificate axioms; the older
4.24 reports used `Lean.ofReduceBool` and `Lean.trustCompiler`. The
[current audit](../docs/MATH_STORAGE_VALIDATION.md) distinguishes them from
the standard logical axioms and the seven cited assumptions. Inspect important
endpoints with `#print axioms` in a scratch file importing the relevant
aggregate; a successful build alone does not identify a theorem's assumptions.

The protocol kernel uses abstract resources/assets/nullifiers and additive
valuation, without selecting an account or UTXO design. Its first action is
conservative, with fees among produced resources. Ownership, nullifier
derivation/security, concrete root schemes, storage backend refinement and
runtime refinement remain profile or implementation work. The typed local
storage lifecycle is proved separately; it does not establish global freshness,
disk durability or erasure. Quorum attachment does
not establish rounds, locks, consensus finality or liveness.

## Reproduce the manuscript builds

With a LaTeX installation providing `latexmk` and the packages used by the
manuscripts, run these commands separately from the package root:

```sh
cd papers/paper1
latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex
```

```sh
cd papers/proximity-prize
latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex
```

The corresponding manuscript registers distinguish source coverage, proved
endpoints, supplied hypotheses and unfinished results. Public review can
assess those bounded claims without treating the research drafts as a
completed encryption scheme or production ledger.
