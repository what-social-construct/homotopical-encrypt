# Legacy Python Runtime Status

The Python runtime is intentionally suspended while the Lean mathematical core
and the Paper 2 protocol contracts are completed.

On 2026-07-23, the former `src/primitives/` and `src/invariants/` packages were
moved intact to `docs/archive/python/src/` after a file-by-file semantic audit.
Remaining Python modules still contain imports of those retired packages and
are therefore not expected to import, package, or pass tests. This is deliberate
and must not be interpreted as a current runtime checkpoint.

Future Python work should refine the canonical Lean contracts rather than
restoring the archived numerical fingerprint, degree-zero HCP, inferred
holonomy, or numerical-homotopy semantics.

See `docs/archive/python/README.md` and
`docs/SEMANTIC_PARITY_QUEUE.md` for the disposition ledger.
