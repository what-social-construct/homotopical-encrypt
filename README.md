# Homotopical Encryption

This repository contains Lean formalizations and three research manuscripts
on hidden Hodge operators, cellular-sheaf cochains, protocol specifications
and Reed–Solomon proximity.

## Manuscripts

| Paper | Scope |
|---|---|
| [Paper 1: Hidden Hodge Operators and the Harmonic Cochain Problem](papers/paper1/README.md) | HCP, harmonic lattices, known-lattice CVP comparisons, semantic classes and exact-recovery ambiguity. |
| [Paper 2: protocol working draft](papers/paper2/README.md) | Cochain commitments, visibility and codec contracts, storage, proof-carrying transitions and security-game obligations. |
| [Paper 3: Capacity-Radius Proximity for Smooth-Domain Reed–Solomon Codes](papers/proximity-prize/README.md) | Projective reconstruction in the projection chain, coding/list/MCA results, radii and native modular metric comparisons. |

The [shared parity register](SEMANTIC-PARITY.md) assigns canonical objects and
statements to these papers. The [source ledger](docs/SOURCE_LEDGER.md)
indexes their literature. Paper 2 currently has a Markdown draft; Papers 1
and 3 have TeX sources and PDFs.

## Mathematical focus

A hidden presentation selects a degree-one Hodge operator
$\Delta_x=\delta_{0,x}\delta_{0,x}^{*}+\delta_{1,x}^{*}\delta_{1,x}$.
An observed cochain has the form $b=h+e$, with $h\in\ker\Delta_x$ and
exact/coexact noise orthogonal to that kernel. Its operative harmonic
component is $P_{\ker\Delta_x}b$.

The formalization distinguishes the real harmonic subspace from an integer
lattice inside it. Orthogonal target projection preserves the lattice's
closest vectors. A constructed family has one public observation and
different operative targets: a correct CVP oracle recovers the target when
given the private lattice, while the shared public input cannot select the
hidden member's answer uniformly.

These are exact mathematical comparisons. Computational hardness and
encryption security require their stated additional assumptions.

## Build and read

The [Lean guide](lean/README.md) maps the mathematics to source modules and
the three independent verification entries. From the repository root:

~~~sh
cd lean
lake exe cache get
lake build
lake build Palomar.PaperOne.Solution Palomar.PaperThree.Solution Palomar.PaperThree.Application.Solution
~~~

With a full TeX installation, run separately from the repository root:

~~~sh
latexmk -cd -pdf -interaction=nonstopmode -halt-on-error papers/paper1/main.tex
latexmk -cd -pdf -interaction=nonstopmode -halt-on-error papers/proximity-prize/main.tex
~~~

Current reading copies are under `output/pdf/`; generated review packages
are under `output/packages/`. These commands describe how to reproduce the
checks, rather than certifying a particular working tree.

## Layout

~~~text
lean/                       Definitions, proofs and verification entries
papers/paper1/              HCP foundations manuscript
papers/paper2/              Protocol draft
papers/proximity-prize/     Coding/proximity manuscript
docs/                       Source ledger and current mathematical crosswalks
scripts/                    Lean/manuscript checks and package generation
output/                     Reading PDFs, packages and validation artifacts
archive/                    Historical prototypes, plans and review records
~~~

Rust/Python prototypes are preserved under `archive/runtime/`; earlier
plans and review records are under `archive/documentation/`. They are
historical material outside the active Lean/manuscript verification scope.

[MIT license](LICENSE).
