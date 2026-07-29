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
- the exact capacity-grid equality \(L_m=\binom nk\) is proved by an
  agreement-set injection and a matching received-word construction;
- the endpoint fractional target is characterized iff by the field-size
  inequality, with an obstruction on the next Hamming shell;
- an explicit smooth rate-`1/4` family is checked against the fixed `2^-128`
  list-size target;
- the capacity-radius MCA statement remains a theorem target;
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
