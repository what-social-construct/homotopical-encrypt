# Homotopical Encryption

The active project is the Lean formalization and its corresponding research
manuscripts. It studies hidden Hodge operators, cellular-sheaf cochains,
protocol specifications and Reed–Solomon proximity.

The Rust and Python prototypes, runtime prompts, examples, tests and build
artifacts are preserved in [the runtime archive](archive/runtime/). They are
historical and are not maintained as an active implementation.

## Manuscripts

| Paper | Scope |
|---|---|
| [Paper 1: Hidden Hodge Operators and the Harmonic Cochain Problem](papers/paper1/README.md) | HCP, harmonic recovery, the discrete-CVP comparison, the constructed semantic family and exact-component observation limitation. |
| [Paper 2: protocol working draft](papers/paper2/README.md) | Concrete cochain commitments, visibility and codec contracts, storage, proof-carrying transitions and explicit security-game obligations. |
| [Paper 3: Capacity-Radius Proximity for Smooth-Domain Reed–Solomon Codes](papers/proximity-prize/README.md) | Full projective reconstruction in the projection chain, coding/list/MCA results, radii and quantitative native modular comparisons. |

The [shared parity register](SEMANTIC-PARITY.md) records ownership, canonical
objects and remaining obligations. The [source ledger](docs/SOURCE_LEDGER.md)
indexes the literature, and the [completion plan](docs/PAPER_OUTLINE.md)
tracks the manuscript work.

## Mathematical focus

A hidden presentation selects a degree-one Hodge operator
$\Delta_x=\delta_{0,x}\delta_{0,x}^{*}+\delta_{1,x}^{*}\delta_{1,x}$.
An observed cochain has the form $b=h+e$, with $h\in\ker\Delta_x$ and
exact/coexact noise orthogonal to that kernel. Its operative harmonic
component is $P_{\ker\Delta_x}b$.

The formalization distinguishes the real harmonic subspace from a supplied
integer lattice inside it. Orthogonal target projection preserves the
lattice's closest vectors. The constructed family also has a shared public
observation with different operative targets: supplying the private lattice
permits recovery by a correct CVP oracle, while the shared public input does
not select the hidden member's answer.

These are exact mathematical comparisons. Computational hardness,
distributional encryption security and implementation refinement retain their
separate hypotheses and proof obligations.

## Review and verification

Start with the [Lean guide](lean/README.md), the manuscripts' parity tables,
and the [public-review guide](PUBLIC_REVIEW.md). Exact build, dependency and
release evidence belongs to the [validation record](docs/MATH_STORAGE_VALIDATION.md);
earlier reports certify their recorded snapshots.

From the repository root, the active checks are Lean and manuscript checks:

~~~sh
cd lean
lake build
lake build Palomar.PaperOne.Solution Palomar.PaperThree.Solution Palomar.PaperThree.Application.Solution
~~~

With a full TeX installation, build the two TeX manuscripts from the repository
root:

~~~sh
latexmk -cd -pdf -interaction=nonstopmode -halt-on-error papers/paper1/main.tex
latexmk -cd -pdf -interaction=nonstopmode -halt-on-error papers/proximity-prize/main.tex
~~~

These commands describe reproducible checks, not a claim that the current
working tree or an archived runtime has passed them. Paper 2 currently has a
Markdown draft rather than a TeX/PDF bundle.

## Repository layout

~~~text
lean/                       Active definitions, proofs and verification entries
papers/paper1/              HCP foundations manuscript
papers/paper2/              Protocol draft and scope notes
papers/proximity-prize/     Coding/proximity manuscript
docs/                       Ownership, source and validation guides
scripts/                    Lean/manuscript validation and review packaging
output/pdf/                 Current manuscript reading copies
output/packages/            Generated review packages
output/validation/          Current validation evidence
archive/runtime/            Historical Rust/Python workspace and runtime material
docs/archive/               Earlier non-normative design and Python records
~~~

The runtime archive preserves the former `rust/`, `src/`, `prompts/`,
`examples/`, `tests/` and `target/` directories, plus their Cargo/Python
manifests and legacy checker. Runtime commands belong in that archived
workspace. The archive is excluded from the allowlisted Lean/manuscript
review exports.

See [Architecture](ARCHITECTURE.md), [Implementation scope](IMPLEMENTATION.md),
[semantic ownership](docs/SEMANTIC_OWNERSHIP.md) and
[trust boundaries](docs/TRUST_BOUNDARIES.md) for the distinction between
formal specifications and a future executable implementation.

## License

[MIT](LICENSE).
