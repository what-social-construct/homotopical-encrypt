# Project naming

Current Lean sources, manuscripts, metadata and review exports use these
canonical identifiers:

| Surface | Identifier |
|---|---|
| Lean namespace | `HomotopicalEncryption` |
| Lean package | `homotopical-encrypt-proofs` |
| Repository/review name | `homotopical-encrypt` |
| Lean protocol domain prefix | `HOMOTOPICAL_ENCRYPT` |

The Rust prototype is intentionally left unchanged at the user's request. It
is outside Paper 1 and outside the Lean/manuscript review exports. Archiving
or replacing it against the new Lean core is separate work; this revision
makes no Rust build, implementation-parity or format-migration claim.

Manuscripts, declaration crosswalks, Comparator configurations and formalization
metadata must agree with the current source names. Regenerate manuscript PDFs,
stable review copies, local package trees, ZIPs and their hash manifests after
the rename. The slim exporter copies the selected source closure and metadata;
the broad exporter copies its allowlisted sources and documentation. Neither
renames stale files already present in an earlier export.

The renamed Lean protocol domains and Python prototype prefixes change exact
message bytes. Earlier serialized records require a separately designed
migration; this revision supplies no compatibility aliases. Runtime agreement
with the retained Rust prototype is not asserted.

Historical document identifiers are normalized to the current naming. Frozen
mechanical reports, signed artifacts and their manifests retain their original
bytes and recorded source hashes. Git history and the previously published
snapshot remain unchanged. Keep that evidence separate from current delivery
exports; an earlier passing report certifies its recorded inputs, not renamed
source or newly generated artifacts.

Fresh verification and exact artifact identities belong in the
[validation record](MATH_STORAGE_VALIDATION.md). This note does not assert that
the renamed development has passed builds, tests or protected preflight.

This naming revision has not been pushed or submitted. No registry intake or
registration has been performed for it.
