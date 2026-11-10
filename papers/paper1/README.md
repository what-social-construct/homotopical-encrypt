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

The abstract has one paragraph. Helfer's homotopical semantics opens the
motivation. The four contribution items are complete statements; the third
states the family-CVP result concisely.

The current local PDF is **32 pages**. P305–P307 were earlier 32-page
exposition checkpoints; P304 had 36 pages, P302/P303 had 38 pages, and
P300/P301 had 37 pages. The original public draft had 101 pages. Their
validation records remain historical evidence for those exact artifacts.

[§2, The Harmonic Cochain Problem](sections/02-harmonic-cochain-problem.tex)
first introduces homotopy equivalence, its invariant public classifier and
the possibly coarser classifier fiber. Hodge data, the sample and its integral
lattice profile precede the public observation, hidden witness and short HCP
definition. Exact-cochain observations remain in §2.1 and full-projective
observations/recovery in §2.2.1. Four definitions are reworded: public
observation, hidden witness, HCP and typed semantic realization.

The last main section,
[§3, CVP Comparison and Kernel Ambiguity](sections/03-cvp-comparison.tex),
places the actual homological model beside the cellular example (§3.5).
Its closing Corollary 3.6 compares recovery with a supplied private lattice
against non-recovery from the shared public class using the same correct
oracle, and extends the obstruction to every compatible family retaining the
two separated members. [§4, Conclusion and Further Work](sections/04-conclusion.tex)
follows immediately.

All eleven prior proposition statements and proofs are preserved, and the
closing corollary is added. Appendix A retains four definition rows, eight
main groups (21 declarations), five support groups (25 declarations), and
three background/assumption/contract rows. Its two canonical-consequence
anchors sit outside the unchanged 46-target selection. Appendix B keeps
concise proof boundaries. The mathematical body contains no Lean declaration
lists or repeated companion-paper descriptions. Exact recovery and its
obstructions remain distinct from an asymptotic hardness assumption.

The existing [Hardness.lean](../../lean/Hardness.lean) and
[HCP/AxisFamily.lean](../../lean/HCP/AxisFamily.lean) now contain actual proof
additions and a refactored kernel argument. The other 278 Lean files match
`048c2ea`; no modules, structures or axioms are added. Pins, default roots and
all nine Challenge/Solution/configuration files are unchanged. Fresh focused
and three-Solution builds pass 3,581/3,759 jobs. The fresh 124-report audit is
standard-only (117 exact-three/seven subsets), with all 120 configured sets
matching their previous reports. The earlier 9,295-job/975-report audit remains
historical evidence, rather than a fresh full build or audit.

The [source ledger](../../docs/SOURCE_LEDGER.md#bibliography-correspondence)
continues to map all 28 source IDs to the three bibliographies. Paper 1 prints
five external sources and retains seven bibliography records, including two
uncited companion entries. The three-paper allocation is recorded in the
shared guide and parity register. Concrete protocol construction belongs to
Paper 2, and quantitative coding/metric comparisons belong to Paper 3.

The published snapshot `66e1ad2` passed complete protected preflight. This
revised manuscript and Lean proofs form a new local
candidate: that exact-commit pass does not certify the revision. No registry
submission or registration is authorized. Current artifact and build checks
are recorded in the [validation guide](../../docs/MATH_STORAGE_VALIDATION.md).

Build locally with `latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex`.
