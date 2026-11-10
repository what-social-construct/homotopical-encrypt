# Paper 1: HCP foundations and observation boundaries

This folder contains *Homotopical Encryption: Hidden Hodge Operators and the
Harmonic Cochain Problem*, the first manuscript in the recorded
[three-paper program](../../SEMANTIC-PARITY.md#manuscript-ownership-and-dependency-table).

Its contribution is the HCP/Hodge recovery model, discrete CVP comparisons,
constructed public-target and integer-encoding ambiguity, the stated
homological semantic fragment, exact-component observation obstruction and
full projective subspace/projector recovery. The model is algebraic finite
signed incidence; it asserts no regular CW/simplicial realization of every
admitted base, asymptotic hardness or sampled encryption security.

The manuscript now follows this ownership:

- Paper 1 retains mathematical geometry, recovery and observation boundaries.
- [Paper 2](../paper2/DRAFT.md) owns concrete cochain/commitment construction,
  encoding, visibility, security contracts and protocol evidence. It remains
  a working draft.
- [Paper 3](../proximity-prize/README.md) owns coding, radii and quantitative
  metric/projection comparisons for the declared original-cochain profile.

The revised PDF is **37 pages**, reduced from the earlier 101-page draft.

The former detailed commitment/RS chapters and whole-repository catalogue
have been removed from this manuscript. Sections 5 and 6 are now
[Observation Boundaries](sections/05-observation-boundaries.tex) and
[Projective Observations and Recovery](sections/06-projective-observation-boundary.tex).
The appendix accounts for all 21 main and 25 supporting declarations in the
[independent entry](../../lean/Palomar/PaperOne/README.md), preserving all eight
selected result groups and their explicit hypotheses.

The published snapshot `66e1ad2` passed complete protected preflight. This
revised manuscript and the aligned Lean documentation form a new local
candidate: that exact-commit pass does not certify the revision. No registry
submission or registration is authorized. Current artifact and build checks
are recorded in the [validation guide](../../docs/MATH_STORAGE_VALIDATION.md).

Build locally with `latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex`.
