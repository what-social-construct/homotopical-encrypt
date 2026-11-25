# Homotopical Encryption

Harmonic-lattice encryption, exact private recovery, and the Harmonic Cochain
Problem (HCP), formalized in Lean.

HCP asks for the harmonic message in an observed cochain when its public
semantic class is known but the operative Hodge geometry is hidden. The
research question is how that recovery task compares with CVP, where a
lattice basis is supplied.

Start with [Paper 1](papers/paper1/main.pdf), which develops the HCP encryption
mechanism and its recovery theorems, then follow the
[core Lean construction](#reading-the-construction) below. The
[shared parity register](SEMANTIC-PARITY.md) maps statements to their canonical
proofs; the [source ledger](docs/SOURCE_LEDGER.md) indexes the literature.

## The construction

In the coupled cellular family, a private integer matrix
$B\in\mathbb Z^{m\times n}$ determines the stalk maps, Hodge operator and
intrinsic harmonic lattice

```math
\Lambda_B=\{(0,z,Bz):z\in\mathbb Z^n\}\subseteq\ker\Delta_B.
```

Encryption adds exact/coexact Hodge noise to the harmonic message:

```math
\mathrm{Enc}_B(z,a,u)=(a,z-B^{\mathsf T}u,Bz+u).
```

The private decoder recovers $z$ exactly. Canonical private-matrix and
ciphertext bytes feed an executable rational algorithm, proved equal to
parsing followed by the original harmonic-lattice decoder on every byte
input. All layers use the same sheaf, integral structure and intrinsic
lattice derived from $B$ in the fixed scalar Euclidean profile.

## Completed constructions and proofs

| Component | Completed result | Canonical source |
|---|---|---|
| Cellular Hodge geometry | The degree-one differential or Hodge Laplacian determines $B$; the assembly, projection and recovery diagrams commute. | [CoupledGeometry](lean/HCP/CoupledGeometry.lean) |
| Intrinsic harmonic lattice | Integer coefficients identify the entire intrinsic lattice, with basis, rank, discreteness, full lattice span inside harmonic space and Gram matrix $I+B^{\mathsf T}B$. | [CoupledCVP](lean/HCP/CoupledCVP.lean), [CoupledLattice](lean/HCP/CoupledLattice.lean) |
| Semantic class preservation | Constructed cochain isomorphisms give typed Helfer equivalences and preserve the declared homological class and integer message coefficients. | [CoupledSemantics](lean/HCP/CoupledSemantics.lean) |
| Encryption and private recovery | Exact rational execution refines the real operators on every rational input. Byte recovery succeeds exactly on the integer Hodge-encryption language. | [CoupledRational](lean/HCP/CoupledRational.lean), [CoupledDecoding](lean/HCP/CoupledDecoding.lean), [CoupledRecovery](lean/Protocol/Storage/CoupledRecovery.lean) |
| Ciphertext transport | The native map $M_CM_B^{-1}$ preserves message/opening coordinates and commutes with harmonic projection, with identity, inverse and composition laws. | [CoupledTransport](lean/HCP/CoupledTransport.lean), [CoupledGeometry](lean/HCP/CoupledGeometry.lean) |
| CVP and public recovery comparison | Projecting the target onto harmonic space preserves closest vectors in its harmonic lattice. Constructed public-equivalent presentations have different operative targets, giving an exact public-data recovery obstruction. | [Hardness](lean/Hardness.lean), [AxisFamily](lean/HCP/AxisFamily.lean) |
| Arbitrary CVP targets | The basis-span lift preserves every closest vector. The coupled lift transfers both search and exact distance decisions. Paper 1 proves NP-completeness of the exact decision problem for the specified coupled lattice. | [Basis-span lift](lean/HCP/UnrestrictedCVPLift.lean), [coupled lift](lean/HCP/CoupledCVPLift.lean) |
| Geometry of the hidden family | Squared chordal distance between the actual projectors is `4d/(1+d)^2` times key Hamming distance. The shared metric also applies via full Plücker reconstruction. | [Shared metric](lean/Laplacian/Grassmannian/Metric.lean), [fresh-sign formula](lean/HCP/CoupledProjectorMetric.lean), [Plücker adapter](lean/Proximity/Concrete/GrassmannianPlucker/ProjectorMetric.lean) |
| Protocol joins | Canonical manifests retain the exact artifact and full ciphertext through signed intents and checked history. Conditional integrity and adaptive CRS reduction theorems retain their stated primitive hypotheses. | [Protocol guide](lean/Protocol/README.md), [construction crosswalk](papers/paper2/DRAFT.md#7-construction-ownership-and-remaining-protocol-work) |
| Private operator and public instance | Canonical nonce-bearing operator openings, V2 witness/program/instance checks and original-context verification. A finite public-instance recovery experiment reduces success above $2^{-n}$ to an explicit operator-commitment distinguishing test. | [OperatorCommitment](lean/Protocol/Storage/OperatorCommitment.lean), [NativeCommitted](lean/Protocol/Transfer/PathSignature/NativeCommitted.lean), [context](lean/Protocol/Transfer/PathSignature/NativeCommittedContext.lean), [reduction](lean/Protocol/Transfer/PathSignature/NativeCommittedPrivacy.lean) |
| One-use random-oracle recovery | With an initially empty oracle cache, independent uniform messages, fresh sign keys and private 32-byte nonces, a decoder making at most `Q` public hash queries recovers with probability at most `2^-n + (Q+2)/256^32`. The bound covers partial integer-coefficient recovery for positive scaling. | [Exact-byte oracle adapter](lean/Protocol/Storage/OperatorCommitment/RandomOracle.lean), [native experiment and bound](lean/Protocol/Transfer/PathSignature/NativeCommittedRandomOracle.lean) |
| Strict native recovery separation | One exact CVP call with the operative graph lattice recovers every generated message. The same fixed CVP oracle leaves the public HCP query bound unchanged, so success is strictly below one when `n ≥ 1` and `Q+2 < 2^255`. | [CoupledRecoverySeparation](lean/HCP/CoupledRecoverySeparation.lean) |

## Reading the construction

| Step | Module | Role |
|---|---|---|
| 1 | [HCPCoupledFamily](lean/Sheaf/HCPCoupledFamily.lean) | The cellular sheaf, integral structure and genuine Hodge operator. |
| 2 | [HCPCoupledEncoding](lean/Sheaf/HCPCoupledEncoding.lean) | The original harmonic message and noisy encrypted cochain. |
| 3 | [CoupledCVP](lean/HCP/CoupledCVP.lean) | The graph lattice, complete intrinsic coverage and known-lattice CVP objective. |
| 4 | [CoupledLattice](lean/HCP/CoupledLattice.lean) | Coefficient charts, basis, rank and lattice topology. |
| 5 | [CoupledGeometry](lean/HCP/CoupledGeometry.lean) | Operator reconstruction and the transport/projection/recovery diagrams. |
| 6 | [CoupledRational](lean/HCP/CoupledRational.lean) | The exact finite recovery and transport algorithms. |
| 7 | [CoupledDecoding](lean/HCP/CoupledDecoding.lean) | Agreement with the original decoder on every rational input. |
| 8 | [CoupledRecovery](lean/Protocol/Storage/CoupledRecovery.lean) | Canonical private-key/ciphertext parsing and direct byte recovery. |

The [runnable example](lean/Protocol/Storage/CoupledRecovery/Demo.lean) executes
these same definitions. Parity rows **H118–H121** record the geometry, lattice,
decoder and byte-recovery correspondence.

## Build and run

[Lean v4.35.0](lean/lean-toolchain) and the
[Mathlib dependency revision](lean/lake-manifest.json) are pinned. From the
repository root, with elan installed:

~~~sh
cd lean
lake exe cache get
lake build HCP.CoupledLattice Protocol.Storage.CoupledRecovery.Demo
lake env lean --run Protocol/Storage/CoupledRecovery/Demo.lean
~~~

The demo encrypts `(2,-1)` to cochain `(3,-2,-5,5)` and recovers the message
through private-key and ciphertext bytes. It checks rejection of nonintegral
message coordinates and truncated encodings. A second run uses the dense
fresh-sign profile to encrypt `(true,false)` to `(3,0,0,-6,0)` and recover
the original bits through the same byte path.

For the full workspace and independent verification entries:

~~~sh
lake build
lake build Palomar.PaperOne.Solution Palomar.PaperThree.Solution Palomar.PaperThree.Application.Solution
~~~

The [Lean guide](lean/README.md) describes the wider module map and proof
assumptions. The completed native core has passed its targeted builds,
external declaration/axiom checks and byte-execution example; the full
`Protocol` aggregate has also built successfully.
The random-oracle proofs use the pinned VCVio hidden-seed simulation library.

## Next mathematical work

| Workstream | Endpoint |
|---|---|
| Encryption privacy | Extend the proved native random-oracle experiment to proof/storage transcripts and key-use policy, and specify the concrete implementation profile. |
| Computational comparison | The native family has a strict query separation and exactly `2^n` compatible operative lattices for a fixed ciphertext mask. The unrestricted-target lift uses a nearest-point solver with a specified lattice. A reduction to the public HCP solver would need its own construction. |
| Concrete proof construction | Complete field-circuit refinement for ranges, bytes and hashes, and a secure CRS primitive with quantitative estimates. |

The [parity register](SEMANTIC-PARITY.md#what-remains-by-paper) and
[construction ownership table](docs/SEMANTIC_OWNERSHIP.md) track these
endpoints and the remaining protocol work.

## Manuscripts and repository layout

Paper 1 owns the encryption mechanism and its mathematical recovery results.
Paper 2 consumes them in protocol, storage and verification constructions.
Paper 3 develops the separate coding and proximity analysis.

| Manuscript | Scope and sources |
|---|---|
| Paper 1: Homotopical Encryption | [PDF](papers/paper1/main.pdf), [TeX](papers/paper1/main.tex), [guide](papers/paper1/README.md). Primitives, HCP, coupled lattice encryption, exact byte recovery, one-use random-oracle recovery and CVP comparison. |
| Paper 2: Proof-Carrying Transactions for Homotopical Encryption | [Protocol PDF](papers/paper2/construction.pdf), [TeX](papers/paper2/construction.tex), [working inventory](papers/paper2/DRAFT.md). Payload commitments, contexts, manifests, certificates, approved execution and conditional protocol security. |
| Paper 3: Capacity-Radius Proximity for Smooth-Domain Reed–Solomon Codes | [PDF](papers/paper3/main.pdf), [TeX](papers/paper3/main.tex), [coding](lean/Palomar/PaperThree/README.md) and [application](lean/Palomar/PaperThree/Application/README.md) verification entries. |

Paper 1's appendix separates the current construction results from the
[earlier focused 36-target Hodge/CVP selection](lean/Palomar/PaperOne/README.md).

With a full TeX installation, rebuild the canonical PDFs
from the repository root:

~~~sh
latexmk -cd -pdf -interaction=nonstopmode -halt-on-error papers/paper1/main.tex
latexmk -cd -pdf -interaction=nonstopmode -halt-on-error papers/paper2/construction.tex
latexmk -cd -pdf -interaction=nonstopmode -halt-on-error papers/paper3/main.tex
~~~

`lean/` contains the active formalization, `papers/` the manuscripts, `docs/`
the mathematical crosswalks and source ledger, and `scripts/` the verification
package exporters. Canonical PDFs stay beside their manuscript sources;
generated packages and validation artifacts live under ignored `output/`.
See the [output guide](docs/OUTPUTS.md).

Historical prototypes and plans are preserved under `archive/`.

[MIT license](LICENSE).
