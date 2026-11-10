# Runtime reference archive

Active work lives in the [project overview](../../README.md),
[Lean formalization](../../lean/README.md) and [manuscripts](../../papers/).
This directory preserves the earlier Rust and Python runtime work as a frozen
reference, including its manifests, tests, examples and planning prompts.

```text
archive/runtime/
  Cargo.toml
  Cargo.lock
  pyproject.toml
  rust/
  src/
  tests/
  examples/
  prompts/
  scripts/
  .github/       historical runtime CI definitions
  target/        optional, ignored local build cache
```

The archived implementation has not been proved to implement the current Lean
specifications or to meet the cryptographic security claims discussed in the
manuscripts. Earlier build and test records apply to their recorded artifacts;
moving the files establishes no additional correctness or security result.
The nested CI definitions are historical references, not active workflows.

Historical Python dependencies remain in the
[earlier Python source archive](../../docs/archive/python/README.md).
They are not restored into this tree, which may retain imports and assumptions
from its original layout. The archive is not a supported Python package.

The optional `target/` and `.pytest_cache/` directories contain local cache
data and remain ignored and untracked. They are not part of the source archive
or the Lean/manuscript review packages.

A future Lean-directed runtime rewrite is separate work. It should specify
its own object mappings, encodings, security assumptions, tests and refinement
arguments against the active formalization.
