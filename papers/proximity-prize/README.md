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
- the endpoint equality and next-shell obstruction have standalone Lean
  proofs;
- the same-set pair-MCA bad-challenge set has the Lean-proved uniform bound
  `choose(n,k+1)`, improving the ordered-certificate count by a factor
  `k+1`;
- the explicit family meets the `2^-128` MCA target at every normalized
  radius;
- the exact worst-bad-count spectrum is Lean-defined for arbitrary supplied
  finite codes, and the real error statement at `r/n` is Lean-proved iff the
  exact integer budget `2^128 B_C(r) <= |F|` holds;
- a uniform in-budget upper bound at `r` plus one explicit over-budget affine
  line at `r+1` Lean-proves the greatest-safe and first-unsafe grid radii;
- universal unit-spike and two-spike certificates prove `B_C(0) = 1` and
  `B_C(1) >= 2` for proper RS codes with two coordinates beyond an
  interpolation set;
- the prime field `q = 2^128 + 192513`, with `q = 1 mod 4096`, supplies a
  smooth `[n,k] = [4096,1024]` instance whose greatest safe 128-bit count
  radius is `0` and first unsafe count radius is `1`;
- for that boundary-field instance the real safe-radius set is
  `[0,1/4096)`, so its supremum is `1/4096` but it has no largest real safe
  radius;
- the explicit family's greatest safe MCA grid radius is Lean-proved to be
  the full block length;
- a generic source-to-pair calibration interface isolates the exact
  non-collapse inequality required by downstream applications;
- as a separate concrete/application result, the canonical runtime field
  `q = 12289` has no safe count radius at 128 bits; it is not treated as the
  prize-facing boundary or large-field instance.

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

The Lean companion is the application-independent surface under
`lean/Proximity/{Core,Capacity,ListDecoding,MCA,Application}`.  The aggregate
`lean/ProximityPrize.lean` imports only that surface; build it with
`cd lean && lake build ProximityPrize`.
