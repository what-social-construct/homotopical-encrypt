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

The current P309 PDF is **28 pages**, reduced from P308's 32 pages by
removing repeated explanations and consolidating the parity appendix.
P305–P307 were earlier 32-page
exposition checkpoints; P304 had 36 pages, P302/P303 had 38 pages, and
P300/P301 had 37 pages. The original public draft had 101 pages. Their
validation records remain historical evidence for those exact artifacts.

[§2, The Harmonic Cochain Problem](sections/02-harmonic-cochain-problem.tex)
introduces the semantic and Hodge prerequisites before the public observation,
hidden witness and HCP. The generic interface requires homotopy equivalence
to preserve the public label. Exact-cochain observations remain in §2.1 and
full-projective recovery in §2.2.1. Removing the duplicate Recovery Target
subsection moves Computational Scope to §2.3.

The last main section,
[§3, CVP Comparison and Kernel Ambiguity](sections/03-cvp-comparison.tex),
places the actual homological model beside the cellular example (§3.5).
On this admitted `Fin 2` family, every pair is related by typed homotopy
equivalence, and equality of the chosen theory is equivalent to that relation. This
restricted classifier completeness does not identify the fixed-coordinate
Hodge operator. Closing Corollary 3.6 compares recovery with a supplied
private lattice against non-recovery from the shared public class using the
same correct oracle, including every compatible family retaining the two
separated members. [§4, Conclusion and Further Work](sections/04-conclusion.tex)
follows immediately.

All formal environments are byte-identical to `6b762a0`: eleven definitions,
eleven propositions, twelve proofs and one corollary. Appendix A retains
four definition rows, eight main groups (21 declarations), five support
groups (25 declarations), and three background/assumption/contract rows.
Three canonical-consequence anchors sit outside the unchanged 46-target
selection; the semantic-definition row now includes the restricted theory
iff. The single appendix includes brief notes on the independent entry and
proof axioms; the coefficient-recovery row records classical noncomputability. Exact
recovery and its obstructions remain distinct from an asymptotic hardness
assumption.

Only [HCP/AxisFamily.lean](../../lean/HCP/AxisFamily.lean) changes among Lean
files in this revision. `semanticEquivalence_all` and
`theory_eq_iff_homotopyEquivalent` establish the actual-family converse;
the other 279 Lean files and all nine Challenge/Solution/configuration files
are unchanged. Focused/three-Solution builds again pass 3,581/3,759 jobs.
Both new dependency checks pass with exactly the three standard axioms,
as recorded in the [validation guide](../../docs/MATH_STORAGE_VALIDATION.md). P308's 124-report
audit (117 exact-three/seven subsets, all 120 configured sets unchanged)
and the earlier 9,295-job/975-report audit remain historical evidence.

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
