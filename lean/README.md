# Lean formalization

This workspace formalizes the mathematics and protocol specifications in
the project's [manuscript sources](../README.md#manuscripts-and-repository-layout). HCP foundations
and protocol construction are being combined; the proximity paper remains
separate. The namespace is
`HomotopicalEncryption`. The [shared parity register](../SEMANTIC-PARITY.md)
records statement ownership; each manuscript and independent entry provides
its own declaration crosswalk. The [source ledger](../docs/SOURCE_LEDGER.md)
records the literature.

## Mathematical entry points

| Scope | Modules | Main content |
|---|---|---|
| Paper 1: HCP and CVP | [HCP.lean](HCP.lean), [Hardness.lean](Hardness.lean), [CVP.lean](CVP.lean), [HCP/AxisFamily.lean](HCP/AxisFamily.lean) | Public semantic classes, hidden harmonic targets, explicit harmonic lattices, projection-preserving closest vectors and a supplied-member/hidden-member exact-recovery separation. |
| Cellular and semantic foundations | [Sheaf.lean](Sheaf.lean), [Laplacian.lean](Laplacian.lean), [Helfer.lean](Helfer.lean) | Finite cellular cochains, Hodge operators, typed semantic interpretations and homotopy-invariance interfaces. |
| Coupled native construction | [HCPCoupledFamily](Sheaf/HCPCoupledFamily.lean), [CoupledCVP](HCP/CoupledCVP.lean), [CoupledSemantics](HCP/CoupledSemantics.lean) | Actual shared stalk constraints, entire intrinsic graph lattice, constructed semantic-class/coefficient preservation and the original HCP projector. |
| Completed geometry and lattice | [CoupledGeometry](HCP/CoupledGeometry.lean), [CoupledLattice](HCP/CoupledLattice.lean) | Reconstruction from the genuine differential/Laplacian; all-real assembly, projection and recovery diagrams; coefficient charts, intrinsic basis, rank and discreteness. |
| Concrete native encoding | [HCPCoupledEncoding](Sheaf/HCPCoupledEncoding.lean), [CoupledCodec](Protocol/Storage/CoupledCodec.lean), [CoupledBinding](Protocol/Storage/CoupledBinding.lean), [CoupledCiphertext](Protocol/Storage/CoupledCiphertext.lean) | Original integral Hodge observations, canonical matrix/full-cochain bytes and original snapshot/observation bindings. |
| Completed exact native recovery | [CoupledRational](HCP/CoupledRational.lean), [CoupledDecoding](HCP/CoupledDecoding.lean), [CoupledRecovery](Protocol/Storage/CoupledRecovery.lean), [Demo](Protocol/Storage/CoupledRecovery/Demo.lean) | Executable exact inverse and direct private-key/ciphertext byte recovery; agreement with the original harmonic-lattice decoder on every rational input; exact integer-language characterization and an executed reference example. |
| Exact native transport | [NativeTransport](Protocol/Ephemeral/NativeTransport.lean) | Canonical byte migration using a held derived rational map, with refinement to the original real transport. |
| Completed private operator / V2 instance wiring | [OperatorCommitment](Protocol/Storage/OperatorCommitment.lean), [NativeCommitted](Protocol/Transfer/PathSignature/NativeCommitted.lean), [NativeCommittedContext](Protocol/Transfer/PathSignature/NativeCommittedContext.lean), [NativeCommittedPrivacy](Protocol/Transfer/PathSignature/NativeCommittedPrivacy.lean) | Canonical private nonce openings, bounded versioned checks and original-context approved execution. The actual instance/ciphertext recovery event reduces to a specified chosen-operator commitment test, with reference probability exactly `2^-n`. |
| Native token and scoped recovery | [TransportCodec](Protocol/Storage/TransportCodec.lean), [ScopeCodec](Protocol/Ephemeral/ScopeCodec.lean), [TransportToken](Protocol/Ephemeral/TransportToken.lean), [NativeDelivery](Protocol/Ephemeral/NativeDelivery.lean), [Retrieval/Native](Protocol/Storage/Retrieval/Native.lean) | Canonical scope/map bytes, complete scope and separate token/ciphertext hash checks, the existing scoped receipt, and original-object hash-addressed coefficient recovery under explicit authorization, delivery and availability contracts. |
| Paper 2: cochains and protocol | [Axioms/CochainCommitment.lean](Axioms/CochainCommitment.lean), [Protocol/Core.lean](Protocol/Core.lean), [Protocol/Storage/Core.lean](Protocol/Storage/Core.lean) | Commitment carriers, conservative resource transitions, projection gates and snapshot-bound evidence under explicit profiles. |
| Paper 2: recovery and primitives | [Protocol/Ephemeral.lean](Protocol/Ephemeral.lean), [Protocol/Storage/Retrieval.lean](Protocol/Storage/Retrieval.lean), [Protocol/Transfer.lean](Protocol/Transfer.lean), [TCB.lean](TCB.lean) | Rotation, recovery, retrieval and verification contracts on the original objects. |
| Paper 3: coding | [ProximityCoding.lean](ProximityCoding.lean), [Proximity hierarchy](Proximity/README.md) | Smooth-domain Reed–Solomon families, list/MCA statements, radii and attained distances. |
| Paper 3: projective chain and application | [Proximity.lean](Proximity.lean), [Paper 3 manuscript](../papers/paper3/README.md) | Projective reconstruction, actual cochain/pair extraction and the native comparison `d_C ≤ d_P = D_RS ≤ 2d_C`. |

Paper 1's optional classifier-reflection profile identifies public fibers
with the declared semantic homotopy classes when combined with closed-test
invariance. The admitted two-member family proves reflection; the operative
embedded Hodge kernel still depends on the hidden presentation.

The coupled family also proves reflection on its same-size admitted matrices
by constructed strict cochain isomorphisms. Its harmonic lattice consists of
the actual cochains `(0,z,Bz)`; encryption adds the original exact/coexact
noise. `PresentedRotation.transport_encrypt` is the proved encryption
naturality square for admissible integral chain isometries. General coupled
semantic shears are not isometries and do not supply that noise transport.
The separate [CoupledTransport](HCP/CoupledTransport.lean) map uses the native
encryption-coordinate equivalences to transport full samples for every
same-size matrix pair. [CoupledRational](HCP/CoupledRational.lean) gives a
proved exact rational execution/refinement and finite private coefficient
decoder for the native profile. The
[native byte execution](Protocol/Ephemeral/NativeTransport.lean) uses the held
token directly and checks rational output for integrality before encoding an
integer target ciphertext. The [native delivery adapter](Protocol/Ephemeral/NativeDelivery.lean)
and [hash-recovery leaf](Protocol/Storage/Retrieval/Native.lean) retain the
existing scope, original contexts and sample bindings. The older
[coupled specialization](Protocol/Storage/Retrieval/Coupled.lean) remains a
separate instance of the isometric-delivery route.

The direct [CoupledRecovery](Protocol/Storage/CoupledRecovery.lean) path uses
canonical private-matrix and ciphertext bytes without a transport token.
[CoupledDecoding](HCP/CoupledDecoding.lean) proves its agreement with the
original lattice decoder, and [CoupledLattice](HCP/CoupledLattice.lean)
identifies the integer chart with the same entire intrinsic subgroup.

The native token is reusable within its context/profile scope; a separate
full-ciphertext digest identifies the selected record. Scope equality is not
caller authentication or replay prevention. The matrix may reveal private
presentation information despite omitting the presentation matrices as fields.
No protected channel, key agreement, key/noise sampler or full-view security
theorem follows from the codecs or execution laws.

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
The completed coupled geometry, lattice and direct byte-recovery path are
checked with
`lake build HCP.CoupledGeometry HCP.CoupledLattice HCP.CoupledDecoding Protocol.Storage.CoupledRecovery`.
Run its fixed execution example with
`lake env lean --run Protocol/Storage/CoupledRecovery/Demo.lean`.
The semantic and storage joins are checked with
`lake build HCP.CoupledSemantics HCP.CoupledTransport Protocol.Storage.CoupledBinding Protocol.Storage.Retrieval.Coupled`.
The exact native execution and delivery/retrieval profile is checked with
`lake build HCP.CoupledRational Protocol.Ephemeral.NativeDelivery Protocol.Storage.Retrieval.Native`.
The nonce-bearing operator, V2 context and finite recovery reduction are
checked with
`lake build Protocol.Storage.OperatorCommitment Protocol.Transfer.PathSignature.NativeCommittedContext Protocol.Transfer.PathSignature.NativeCommittedPrivacy`.
Rust/Python prototypes under `archive/runtime/` are not Lean build
dependencies. Manuscript build commands are in the [root guide](../README.md#build-and-run).

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
classifier completeness. Exact executable refinement and canonical byte
recovery are proved for the selected coupled profile. Protocol results retain
their authorization, authentication and snapshot assumptions; production
runtime refinement, cryptographic primitive security and consensus finality
remain separate work.

Current PDFs live beside their TeX sources under `papers/`; generated review
packages are under `output/packages/` at the repository root. Historical plans and
verification records are preserved under `archive/documentation/`.

[MIT license](../LICENSE).
