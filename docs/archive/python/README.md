# Legacy Python Source Archive

> [!WARNING]
> **Historical, non-normative, and intentionally non-runnable.** The Python
> sources below are preserved for provenance and possible numerical test-vector
> recovery. They do not define the current mathematics, protocol, security
> model, or runtime contract.

## Retirement checkpoint

- Archived: 2026-07-23
- Source checkpoint: `67c94598249d13b9e376cd5b8c9412ae9985fe5b`
- Original paths:
  - `src/invariants/`
  - `src/primitives/`
- Archived paths:
  - `docs/archive/python/src/invariants/`
  - `docs/archive/python/src/primitives/`

The two directories were retired as complete legacy layers after a file-by-file
semantic audit. Lean is the canonical Paper 1 mathematical surface. The
remaining Python tree is deliberately allowed to contain unresolved imports
until its later protocol/runtime semantic-parity rewrite; current Python tests
and package imports are therefore not a supported checkpoint.

## Canonical ownership

| Archived material | Current owner or disposition |
|---|---|
| Finite cells, stalks, restrictions, and coboundaries | `lean/Sheaf/CellComplex.lean`, `lean/Sheaf/Cellular.lean` |
| Integral stalk and harmonic lattices | `lean/Sheaf/Integral.lean`, `lean/Sheaf/HarmonicLattice.lean` |
| Degree-one Hodge theory and projection | `lean/Sheaf/Hodge.lean`, `lean/HCP.lean` |
| Typed sheaf morphisms and coboundary naturality | `lean/Sheaf/Morphism.lean` |
| Plucker/exterior coordinates | `lean/Proximity/GrassmannianPlucker.lean`; later runtime numerics may refine it |
| Concrete Grassmannian numerics | Rust oracle prototype plus Lean specification; Python was not authoritative |
| Paths and homotopy equivalence | `lean/Helfer/`, `lean/Axioms/HelferFOL.lean`, `lean/Axioms/Fibration.lean` |
| Spectral and cohomology calculations | Retain only as future degree-tagged runtime diagnostics |
| Algebraic, numerical-homotopy, holonomy, curvature, and unified-fingerprint claims | Explicitly rejected rather than translated |

In particular, equality of archived numerical fingerprints must not be used as
a proof of homotopy equivalence. Uniform stalk dimensions or orthogonal edge
maps must not be used as proofs of trivial holonomy. The archived Massey,
truncation-level, path-space, curvature, and universal spectral-bound routines
also carry no theorem status.

To inspect or recover an old routine, use the archived copy directly or restore
the relevant path from Git. Do not reintroduce an archived module into the
active package without assigning it a current Lean/runtime contract and adding
parity tests.
