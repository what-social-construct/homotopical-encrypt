# Homotopical Encryption

Harmonic-lattice encryption, exact private recovery, and the Harmonic Cochain
Problem (HCP), formalized in Lean.

HCP asks for the harmonic message in an observed cochain when its public
semantic class is known but the operative Hodge geometry is hidden. The
research question is how that recovery task compares with CVP, where a
lattice basis is supplied.

Start with the [construction note](papers/paper2/construction.pdf) or
[combined manuscript](papers/paper2/DRAFT.md), then follow the
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
| Protocol joins | Canonical manifests retain the exact artifact and full ciphertext through signed intents and checked history. Conditional integrity and adaptive CRS reduction theorems retain their stated primitive hypotheses. | [Protocol guide](lean/Protocol/README.md), [construction crosswalk](papers/paper2/README.md#lean-sources-and-paper-ownership) |

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
lake build HCP.CoupledLattice Protocol.Storage.CoupledRecovery
lake env lean --run Protocol/Storage/CoupledRecovery/Demo.lean
~~~

The fixed example encrypts message `(2,-1)` to cochain `(3,-2,-5,5)` and
recovers `(2,-1)` through private-key and ciphertext bytes. It also checks
rejection of nonintegral message coordinates and truncated encodings.

For the full workspace and independent verification entries:

~~~sh
lake build
lake build Palomar.PaperOne.Solution Palomar.PaperThree.Solution Palomar.PaperThree.Application.Solution
~~~

The [Lean guide](lean/README.md) describes the wider module map and proof
assumptions. The completed native core has passed its targeted builds,
external declaration/axiom checks and byte-execution example; the full
`Protocol` aggregate has also built successfully.

## Next mathematical work

| Workstream | Endpoint |
|---|---|
| Encryption privacy | Hiding operator binding and a security argument for the complete released view, using fresh geometry per public encrypted object. |
| Computational comparison | A finite sampled recovery problem with efficient adversaries and an explicit reduction or oracle-relative comparison with CVP. |
| Concrete proof construction | Complete field-circuit refinement for ranges, bytes and hashes, and a secure CRS primitive with quantitative estimates. |

The [parity register](SEMANTIC-PARITY.md#what-remains-by-paper) and
[construction ownership table](docs/SEMANTIC_OWNERSHIP.md) track these
endpoints and the remaining protocol work.

## Manuscripts and repository layout

The current manuscript combines the HCP foundations and protocol construction
stored under `paper1` and `paper2`. Capacity-radius proximity remains a
separate paper. The source-directory labels preserve the existing proof and
statement crosswalks.

| Manuscript | Reading copy and sources |
|---|---|
| Combined HCP and proof-carrying transactions | [Construction-note PDF](papers/paper2/construction.pdf) and [TeX](papers/paper2/construction.tex), [full working manuscript](papers/paper2/DRAFT.md), [construction guide](papers/paper2/README.md). |
| Earlier focused HCP foundations | [PDF](papers/paper1/main.pdf), [TeX](papers/paper1/main.tex), [36-target verification entry](lean/Palomar/PaperOne/README.md). |
| Capacity-Radius Proximity for Smooth-Domain Reed–Solomon Codes | [PDF](papers/paper3/main.pdf), [TeX](papers/paper3/main.tex), [coding](lean/Palomar/PaperThree/README.md) and [application](lean/Palomar/PaperThree/Application/README.md) verification entries. |

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
