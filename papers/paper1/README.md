# Paper 1: The Harmonic Cochain Problem

This folder contains *Homotopical Encryption: Hidden Hodge Operators and the
Harmonic Cochain Problem*, the first manuscript in the recorded
[three-paper program](../../SEMANTIC-PARITY.md#manuscript-ownership-and-dependency-table).

The paper introduces the HCP/Hodge recovery model, its homological semantic
fragment, explicit harmonic lattices, known-lattice CVP comparisons and the
constructed hidden-target and integer-encoding ambiguity. The finite model
uses signed incidence; it asserts neither a regular CW realization for every
admitted base nor asymptotic hardness or sampled encryption security.

The numbered body has three sections: [Primitives](sections/02-primitives.tex),
[the HCP](sections/02-harmonic-cochain-problem.tex), and the CVP comparison.
The semantic and Hodge data precede the public observation, hidden witness and
recovery problem. The optional classifier-reflection profile, together with
invariance, identifies public fibers with the declared typed homotopy classes.
The actual admitted two-member family proves reflection. This completeness
does not identify the operative embedded kernel.

[CVP Comparison and Kernel Ambiguity](sections/03-cvp-comparison.tex) ends
with Corollary 3.6: the same correct rank-one CVP oracle recovers the answer
when given the operative private lattice, while the shared public observation
cannot determine the answer uniformly across compatible separated members.
The conclusion follows immediately. This is exact-recovery separation, not
an asymptotic complexity reduction.

The parity appendix uses separate main-statement, supporting-statement and
definition/boundary tables. It maps six selected groups to **16 main and
20 supporting declarations**. Its root abbreviation is
`HE = HomotopicalEncryption`; the independent entry uses
`HomotopicalEncryption.Palomar.PaperOne`. Challenge has 18 intentional theorem
placeholders and a Mathlib-only import surface. Solution supplies canonical
proof adapters without importing Challenge. Its local import closure is
21 modules, plus the independent one-module Challenge closure.

[Paper 2](../paper2/DRAFT.md) owns cochain construction, codec, visibility,
security contracts and protocol evidence. It uses the geometric results
developed in Paper 3 when specifying released views.

[Paper 3 §7](../paper3/sections/07-application-interface.tex) introduces the
full-residual source obstruction, full Plücker coordinates,
subspace/projector reconstruction and the projective-to-cochain/plane/RS
chain. Paper 3 also owns the coding and native metric/radius comparisons.
The canonical Lean proofs of these geometric results remain in place,
outside Paper 1's selected entry. The shared ownership table records this split.

The [source ledger](../../docs/SOURCE_LEDGER.md#bibliography-correspondence)
accounts for all 28 sources across the three bibliographies. The projective
comparison source belongs to Paper 3; Paper 1 prints four external sources
and retains two uncited companion records.

The [entry README](../../lean/Palomar/PaperOne/README.md) records the selected
statements and reproducible checks; its metadata records the current local
verification. The [naming guide](../../docs/PROJECT_NAMING.md) fixes the formal
namespace. Current reading copies and package locations are described in
[the output guide](../../docs/OUTPUTS.md).

Build locally with `latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex`.
