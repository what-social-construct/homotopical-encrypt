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
Plucker visibility consequence. The revised reviewed PDF has 100 pages. The
[validation record](../../docs/MATH_STORAGE_VALIDATION.md#paper-1-full-observation-correspondence--2026-11-08)
links the existing Lean endpoints; the near/far boundary convention remains
the next mathematical task.

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
