# Implementation scope

The active work is the Lean formalization and its corresponding manuscripts.
Use the [Lean guide](lean/README.md), [manuscript completion plan](docs/PAPER_OUTLINE.md)
and [validation record](docs/MATH_STORAGE_VALIDATION.md) for current work and
exact verification evidence.

The maintained workflow is to update canonical definitions and proofs, keep
manuscript statements and parity tables aligned, build the affected Lean
targets and manuscripts, and review the resulting proof dependencies and
rendered PDFs. Entry-specific review packages contain their selected source
closure and manuscripts; archives are excluded.

## Historical runtime workspace

The earlier Rust/Python prototypes, prompts, examples, tests and caches now
live under [archive/runtime/](archive/runtime/). Their Cargo manifests,
Python project file and legacy constants checker are preserved there. The
former launch schedule and completion checklist were prototype planning,
not evidence of a working testnet, a completed security audit or mainnet
readiness.

Earlier runtime commands are rooted in the archive, for example:

~~~sh
cd archive/runtime
cargo test --workspace
~~~

Python project and test instructions likewise belong to
`archive/runtime/pyproject.toml` and `archive/runtime/tests/`, rather than
the repository root. Those historical commands and dependencies are not an
active supported verification target; no runtime tests or security claims
follow from archiving their files.

The current CI checks Lean and manuscripts. Any future executable
implementation must specify and validate its correspondence to the Lean
objects and protocol contracts separately.
