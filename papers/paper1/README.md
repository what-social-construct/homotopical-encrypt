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

The current P310 PDF is **29 pages**. P309's 28-page cleanup consolidated
the parity appendix; P305–P308 were earlier 32-page checkpoints. P304 had
36 pages, P302/P303 had 38 pages, and P300/P301 had 37 pages. The original
public draft had 101 pages. Those validation records belong to their exact
historical artifacts.

[§2, The Harmonic Cochain Problem](sections/02-harmonic-cochain-problem.tex)
introduces the semantic and Hodge prerequisites before the public observation,
hidden witness and HCP. The generic classifier factors through the chosen
closed theory. Under closed-test invariance and optional reflection, equal
labels are equivalent to typed homotopy equivalence, and the existing public
fiber is exactly that semantic class. The base realization does not require
reflection. Exact-cochain observations remain in §2.1, full-projective recovery
in §2.2.1 and Computational Scope in §2.3.

The last main section,
[§3, CVP Comparison and Kernel Ambiguity](sections/03-cvp-comparison.tex),
places the actual homological model beside the cellular example (§3.5).
The admitted `Fin 2` family proves reflection and its theory iff uses the
shared generic API. Semantic completeness leaves the fixed-coordinate Hodge
operator dependent on the hidden presentation. Closing Corollary 3.6 compares
recovery with a supplied private lattice against non-recovery from the shared
public class using the same correct oracle, including every compatible family
retaining the two separated members.
[§4, Conclusion and Further Work](sections/04-conclusion.tex) follows immediately.

All 35 main formal environments are unchanged: eleven definitions, eleven
propositions, twelve proofs and one corollary. The single parity appendix
retains four definition rows, eight main groups (21 declarations), five
support groups (25 declarations), and three background/assumption/contract
rows. Its five canonical theorem anchors sit outside the unchanged 46-target
selection; the semantic row also identifies the optional reflection property.
Brief independent-entry and proof-axiom notes remain beside the table, with
classical noncomputability recorded in the coefficient-recovery row.

[HCP.lean](../../lean/HCP.lean) adds `ReflectsHomotopyEquivalence` and the generic
iff/fiber lemmas without changing `Realization` fields.
[HCP/AxisFamily.lean](../../lean/HCP/AxisFamily.lean) proves reflection and
refactors the existing family iff through that API. The other 278 Lean files
match `f036a16`; there are no new structures, imports or global axioms.
Focused and three-Solution builds pass 3,581/3,759 jobs. The five-report
canonical audit is tracked in the [validation guide](../../docs/MATH_STORAGE_VALIDATION.md).
P309's two converse reports, P308's 124-report audit and the earlier
9,295-job/975-report audit remain historical evidence.

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
