# Capacity-Radius Proximity Paper

This folder is the standalone coding-theory manuscript bundle for the
Reed--Solomon list-decoding and mutual-correlated-agreement work.

Working title:

> Capacity-Radius Proximity for Smooth-Domain Reed--Solomon Codes

The manuscript is deliberately independent of the Homotopical Encryption
protocol and HCP semantics. Its primary quantifiers range over every received
word in the ambient interleaved Reed--Solomon word space and every affine line.
Paper 1 may later consume the resulting coding theorem through a short
application interface.

Current status:

- the problem statements and normalized metrics are specified;
- the two-coordinate plane is identified with the full ambient word space of
  the two-fold interleaved code;
- the capacity-radius list-decoding and MCA statements are theorem targets, not
  completed claims;
- no fixed `2^-128` claim is made until the list-size or bad-challenge bound is
  explicitly compared with the field size;
- the fixed hcrypt runtime modulus `12289` is not treated as the prize field.

Suggested local build:

```sh
cd papers/proximity-prize
tectonic main.tex
```

With a full TeX installation:

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

The standalone Lean companion now lives under `lean/ProximityPrize/`, importing
only Mathlib and application-independent definitions. Build it with
`cd lean && lake build ProximityPrize`.
