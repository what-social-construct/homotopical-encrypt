# Homotopical Encryption

This repository contains Lean formalizations and three research manuscripts
on hidden Hodge operators, cellular-sheaf cochains, protocol specifications
and Reed–Solomon proximity.

The plan is **three papers and three Palomar submissions, one per paper**.
**Paper 1 is being prepared first.**

## Manuscripts

| Paper | Scope | Current preparation |
|---|---|---|
| [Paper 1: Hidden Hodge Operators and the Harmonic Cochain Problem](papers/paper1/README.md) | Cellular/Hodge primitives, HCP, semantic classes, harmonic lattices, known-lattice CVP comparisons and exact-recovery ambiguity. | [PDF](papers/paper1/main.pdf), [TeX](papers/paper1/main.tex) and [formalization entry](lean/Palomar/PaperOne/README.md); first planned submission. |
| [Paper 2: Proof-Carrying Homotopical Encryption](papers/paper2/README.md) | Cochain commitments, visibility and codec contracts, storage, proof-carrying transitions and security-game obligations. | [Working Markdown draft](papers/paper2/DRAFT.md); TeX/PDF and a dedicated submission entry remain to be prepared. |
| [Paper 3: Capacity-Radius Proximity for Smooth-Domain Reed–Solomon Codes](papers/proximity-prize/README.md) | Projective reconstruction in the projection chain, coding/list/MCA results, radii and native modular metric comparisons. | [PDF](papers/proximity-prize/main.pdf), [TeX](papers/proximity-prize/main.tex) and two internal verification configurations for one planned submission. |

The [shared parity register](SEMANTIC-PARITY.md) assigns canonical objects and
statements to these papers. The [source ledger](docs/SOURCE_LEDGER.md)
indexes their literature. Paper 2 supplies the cochain construction and
protocol contracts consumed by Paper 3's application results. Paper 1's
HCP/CVP contribution is independent of that protocol and coding development.

The three existing verification entries are [Paper 1](lean/Palomar/PaperOne/README.md),
[Paper 3 coding](lean/Palomar/PaperThree/README.md) and
[Paper 3 application](lean/Palomar/PaperThree/Application/README.md).
The last two are configurations for the same manuscript. Paper 2's own
entry is still pending; the number of current configurations does not describe
the planned submission split. Each entry's metadata records its verification
status; preparation and local checks do not imply a completed submission.

## Mathematical focus

A hidden presentation selects a degree-one Hodge operator

```math
\Delta_x=\delta_{0,x}\delta_{0,x}^{*}+\delta_{1,x}^{*}\delta_{1,x}.
```

Its degree-one cochain space has the Hodge splitting

```math
C_x^1=\ker(\Delta_x)\oplus\mathrm{im}(\delta_{0,x})\oplus\mathrm{im}(\delta_{1,x}^{*}).
```

An observed cochain has the form $b=h+e$, with $h\in\ker\Delta_x$ and
exact/coexact noise orthogonal to that kernel. Its operative harmonic
component is $P_{\ker\Delta_x}b$. HCP asks for that component from the public
class and cochain observation, while the operative presentation remains hidden.

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
the current independent verification entries. From the repository root:

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

Read the compiled PDFs beside their TeX sources under `papers/`; generated
review packages are described in the [output guide](docs/OUTPUTS.md) and live
locally under `output/packages/`. These commands describe how to reproduce the
checks; they do not certify a particular working tree.

## Layout

~~~text
lean/                       Definitions, proofs and verification entries
papers/paper1/              HCP foundations manuscript
papers/paper2/              Protocol draft
papers/proximity-prize/     Coding/proximity manuscript
docs/                       Source ledger and current mathematical crosswalks
scripts/                    Lean/manuscript checks and package generation
output/                     Review packages and validation artifacts
archive/                    Historical prototypes, plans and review records
~~~

Rust/Python prototypes are preserved under `archive/runtime/`; earlier
plans and review records are under `archive/documentation/`. They are
historical material outside the active Lean/manuscript verification scope.

[MIT license](LICENSE).
