# Paper 1 Draft

This folder is the LaTeX source of truth for Paper 1: the math/formalization
paper for Homotopical Encryption.

The shared [manuscript parity register](../../SEMANTIC-PARITY.md) records
paper ownership, definitions, notation, and outstanding proofreading issues.
This manuscript owns the HCP foundations and the application-specific
projection bridge. The separate [proximity manuscript](../proximity-prize/README.md)
owns the universal coding results; it is independent of HCP assumptions.
The planned protocol paper in `papers/paper2/` is a different manuscript.

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
