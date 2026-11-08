# Paper 1 Draft

This folder is the LaTeX source of truth for Paper 1: the math/formalization
paper for Homotopical Encryption.

The shared [manuscript parity register](../../SEMANTIC-PARITY.md) records
paper ownership, definitions, notation, and outstanding proofreading issues.
This manuscript owns the HCP foundations and the application-specific
projection bridge. The separate [proximity manuscript](../proximity-prize/README.md)
owns the universal coding results; it is independent of HCP assumptions.
The protocol working draft in `papers/paper2/` is a different manuscript.

The 2026-11-08 observation reconciliation distinguishes the accepted exact
payload, separately bound full Hodge sample, operative alignment and explicit
disclosure in the introduction and §§2/5. It also states the full operative
Plucker visibility consequence. The revised reviewed PDF has 101 pages. The
[validation record](../../docs/MATH_STORAGE_VALIDATION.md#strict-canonical-decision-profile--2026-11-08)
links the existing Lean endpoints. The canonical decision convention now
uses near `ε<δ_J`, with concrete near `2046/4096` and far `2047/4096`;
its separated bridge retains the same projection and conditional solver
pullback. The geometric far witness, cited-bound budget and efficient solver
remain separate obligations. Pure radius arithmetic is standard-only;
canonical bridge adapters retain existing native arithmetic certificates.

Suggested local build:

```sh
cd papers/paper1
tectonic main.tex
```

If using a full TeX installation instead of Tectonic, use:

```sh
latexmk -pdf main.tex
```

or:

```sh
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

The planning outline remains in `docs/PAPER_OUTLINE.md`; this folder is the
actual manuscript bundle.
