# Lean formalization

This workspace formalizes the mathematics and protocol specifications in
the project's [three manuscripts](../README.md#manuscripts). The namespace is
`HomotopicalEncryption`. The [shared parity register](../SEMANTIC-PARITY.md)
records statement ownership; each manuscript and independent entry provides
its own declaration crosswalk. The [source ledger](../docs/SOURCE_LEDGER.md)
records the literature.

## Mathematical entry points

| Scope | Modules | Main content |
|---|---|---|
| Paper 1: HCP and CVP | [HCP.lean](HCP.lean), [Hardness.lean](Hardness.lean), [CVP.lean](CVP.lean), [HCP/AxisFamily.lean](HCP/AxisFamily.lean) | Public semantic classes, hidden harmonic targets, explicit harmonic lattices, projection-preserving closest vectors and a supplied-member/hidden-member exact-recovery separation. |
| Cellular and semantic foundations | [Sheaf.lean](Sheaf.lean), [Laplacian.lean](Laplacian.lean), [Helfer.lean](Helfer.lean) | Finite cellular cochains, Hodge operators, typed semantic interpretations and homotopy-invariance interfaces. |
| Paper 2: cochains and protocol | [Axioms/CochainCommitment.lean](Axioms/CochainCommitment.lean), [Protocol/Core.lean](Protocol/Core.lean), [Protocol/Storage/Core.lean](Protocol/Storage/Core.lean) | Commitment carriers, conservative resource transitions, projection gates and snapshot-bound evidence under explicit profiles. |
| Paper 2: recovery and primitives | [Protocol/Ephemeral.lean](Protocol/Ephemeral.lean), [Protocol/Storage/Retrieval.lean](Protocol/Storage/Retrieval.lean), [Protocol/Transfer.lean](Protocol/Transfer.lean), [TCB.lean](TCB.lean) | Rotation, recovery, retrieval and verification contracts on the original objects. |
| Paper 3: coding | [ProximityCoding.lean](ProximityCoding.lean), [Proximity hierarchy](Proximity/README.md) | Smooth-domain Reed–Solomon families, list/MCA statements, radii and attained distances. |
| Paper 3: projective chain and application | [Proximity.lean](Proximity.lean), [Paper 3 manuscript](../papers/paper3/README.md) | Projective reconstruction, actual cochain/pair extraction and the native comparison `d_C ≤ d_P = D_RS ≤ 2d_C`. |

Paper 1's optional classifier-reflection profile identifies public fibers
with the declared semantic homotopy classes when combined with closed-test
invariance. The admitted two-member family proves reflection; the operative
embedded Hodge kernel still depends on the hidden presentation.

Paper 2 specifies commitment construction, visibility, codecs and protocol
evidence. Paper 3 owns the full projective reconstruction and quantitative
projection comparisons that consume those construction profiles.

## Independent verification entries

| Entry | Selected statements |
|---|---|
| [Paper 1](Palomar/PaperOne/README.md) | Six groups: 16 manuscript-facing and 20 supporting declarations, 36 targets. |
| [Paper 3 coding](Palomar/PaperThree/README.md) | 52 targets. |
| [Paper 3 application](Palomar/PaperThree/Application/README.md) | 22 targets. |

Each entry separates an independent `Challenge` from its canonical `Solution`.
Intentional theorem placeholders belong to Challenges; Solutions import the
canonical proofs without importing Challenge.

## Build

[lean-toolchain](lean-toolchain) pins Lean to `v4.35.0`.
[lake-manifest.json](lake-manifest.json) pins Mathlib and its transitive
dependencies. With elan installed, run from the repository root:

~~~sh
cd lean
lake exe cache get
lake build
lake build Palomar.PaperOne.Solution Palomar.PaperThree.Solution Palomar.PaperThree.Application.Solution
~~~

The three Solutions are explicit, nondefault targets. Focused builds include
`lake build HCP.AxisFamily`, `lake build ProximityCoding`,
`lake build Protocol.Core` and `lake build Protocol.Storage.Retrieval`.
Rust/Python prototypes under `archive/runtime/` are not Lean build
dependencies. Manuscript build commands are in the [root guide](../README.md#build-and-read).

## Assumptions and scope

Definitions under `Axioms/` commonly specify propositions or structures
whose proofs an application supplies. Those inputs remain hypotheses of
the resulting theorems.

[CanonicalRS/CitedBounds.lean](Proximity/Concrete/CanonicalRS/CitedBounds.lean)
contains seven explicit literature-bound axioms, including two numerical
witness constants. They are separate from the standalone `ProximityCoding`
proofs. Inspect an endpoint's dependencies with `#print axioms`; standard
logical dependencies include `propext`, `Classical.choice` and `Quot.sound`.

The HCP/CVP results establish exact comparisons and recovery obstructions,
rather than an asymptotic complexity reduction or sampled encryption-security
theorem. The constructed semantic fragment does not supply full first-order
classifier completeness. Protocol results retain their authorization,
authentication, codec and snapshot assumptions; executable refinement,
cryptographic primitive security and consensus finality require additional
results.

Current PDFs live beside their TeX sources under `papers/`; generated review
packages are under `output/packages/` at the repository root. Historical plans and
verification records are preserved under `archive/documentation/`.

[MIT license](../LICENSE).
