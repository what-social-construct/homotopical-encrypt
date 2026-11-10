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

The abstract now has one paragraph. Helfer's homotopical semantics opens
the motivation, and the CVP bridge, ambiguity obstruction and cellular
examples form one contribution item (four contribution items overall).

The current PDF is **36 pages**. The earlier P302/P303 back-matter checkpoint
had 38 pages; the P300/P301 ownership checkpoint had 37 pages, reduced from
the original 101-page draft.

The exposition follows the HCP recovery problem, the hidden operative operator,
the CVP comparison and the effect of changing the public observation. Section 5,
[Observation Boundaries and Recovery](sections/05-observation-boundaries.tex),
combines the former two observation sections. Its five subsections treat exact
cochains, the exact-component obstruction, additional observations, projective
frames (§5.4) and full-point recovery (§5.5). The former separate projective
section is merged into that file. Section 6 is *Conclusion and Further Work*.

The mathematical body contains no Lean cross-reference blocks, implementation
filenames or repeated companion-paper descriptions. Appendix A's single
post-conclusion parity table has four definition rows, eight main result groups
covering 21 declarations, five support groups covering 25 declarations, and
three external-result/assumption/contract rows. Appendix B keeps concise proof
boundaries. All 46 selected declarations and the eleven propositions/proofs
remain accounted for; the computational scope distinguishes exact recovery
from an asymptotic hardness assumption.

Lean edits are limited to section-number comments, with every non-comment
source byte unchanged. The checked 9,295-job build and 975-report dependency
state is retained; no repeated Lean build is claimed for this editorial change.
The [source ledger](../../docs/SOURCE_LEDGER.md#bibliography-correspondence)
continues to map all 28 source IDs to the three bibliographies. Paper 1 prints
five external mathematical sources; its bibliography retains seven records,
including two uncited companion entries. The three-paper allocation is
recorded in the shared guide and parity register rather than repeated in the
manuscript. Concrete protocol construction remains with Paper 2, and
quantitative coding/metric comparisons remain with Paper 3.

The published snapshot `66e1ad2` passed complete protected preflight. This
revised manuscript and the aligned Lean documentation form a new local
candidate: that exact-commit pass does not certify the revision. No registry
submission or registration is authorized. Current artifact and build checks
are recorded in the [validation guide](../../docs/MATH_STORAGE_VALIDATION.md).

Build locally with `latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex`.
