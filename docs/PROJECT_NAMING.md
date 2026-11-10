# Project naming

Current Lean sources, manuscripts, metadata and review exports use these
canonical identifiers:

| Surface | Identifier |
|---|---|
| Lean namespace | `HomotopicalEncryption` |
| Standalone coding namespace and aggregate | `ProximityCoding` |
| Lean package | `homotopical-encrypt-proofs` |
| Repository/review name | `homotopical-encrypt` |
| Lean protocol domain prefix | `HOMOTOPICAL_ENCRYPT` |
| Paper 3 manuscript directory | `papers/paper3/` |

The active repository scope is Lean and the corresponding manuscripts.
The historical Rust/Python workspace, prompts, examples, tests and build
artifacts are preserved under `archive/runtime/`, with its Cargo/Python
manifests and legacy constants checker. That archive is not maintained as
an active implementation and is excluded from review exports.

Archive contents retain their identifiers and bytes as moved, including
the existing Rust edit. The active naming convention does not rename those
archived protocol formats or establish agreement between the prototypes
and the Lean core. No Rust/Python build, format migration or implementation
security result is claimed.

Manuscripts, declaration crosswalks, Comparator configurations and formalization
metadata must agree with the active source names. Regenerate manuscript PDFs,
local package trees, ZIPs and their hash manifests after
the rename. The slim exporter copies the selected source closure and metadata;
the broad exporter copies its allowlisted sources and documentation. Neither
includes `archive/runtime/` nor renames stale files already present in an
earlier export.

Renaming Lean protocol domains changes their specified message bytes. Earlier
serialized records require a separately designed migration; this revision
supplies no compatibility aliases or runtime refinement proof.

Historical document identifiers are normalized to the current naming. Frozen
mechanical reports, signed artifacts and their manifests retain their original
bytes and recorded source hashes. Git history and the previously published
snapshot remain unchanged. An earlier passing report certifies its recorded
inputs, not renamed source or newly generated artifacts.

Current statement scope and local verification are recorded in the Lean
entry READMEs and formalization metadata. Historical verification and review
records are archived separately.

The public Paper 1 repository contains only its selected Lean source closure,
corresponding manuscript and entry metadata. Other manuscripts, archives and
private Git history are excluded. Publication is separate from registry
intake and submission.
