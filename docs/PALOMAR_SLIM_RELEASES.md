# Slim Palomar release candidates

Prepared locally on 2026-11-09. Three configurations cover two manuscripts:
Paper 1, Paper 3 coding and Paper 3's original-cochain application. Each package
contains one configuration and its actual transitive Lean proof closure.
Paper 2 remains outside this submission scope.

| Package | Local Lean modules, including Challenge | Configured declarations | Manuscript |
|---|---:|---:|---|
| `paper1` | 31 | 46: 21 main / 25 support | Paper 1, 101 pages |
| `paper3-coding` | 35 | 52: 36 main / 16 support | Paper 3, 30 pages |
| `paper3-application` | 81 | 22: 10 main / 12 support | The same Paper 3 manuscript |

The [exporter](../scripts/export_palomar_entries.py) copies every selected Lean
source, Comparator configuration, metadata file and manuscript source/PDF
unchanged. It includes the MIT licence and exact Lean/Mathlib pins. The
generated Lake configuration retains the package options and dependency pin,
defaults only to that entry's Solution and builds Challenge explicitly.
Challenge and Solution build separately because their canonical declarations
have the same names.

Each root README identifies the selected scope. The existing short entry
crosswalk is retained with navigation-only changes: manuscript links point
to the bundled copy, and missing companion links become labelled text.
The manifest records every change. Unchanged metadata retains immutable
upstream provenance URLs; those URLs refer to the private development
repository, so the bundled manuscripts provide the review evidence.
The complete manuscript supplies context; the configured statements define
the submitted formalization scope.

Plans, archives, other-paper entries, runtime code, repository history and
dependency/build caches are excluded. Shared modules remain when a selected
proof actually imports them. Retained conditional protocol vocabulary does
not add a cryptographic security or deployed-system claim.

## Reproduce the local packages

From the development repository root:

```sh
python3 scripts/export_palomar_entries.py --refresh
python3 scripts/export_palomar_entries.py --verify
```

The output is `output/palomar-slim/{paper1,paper3-coding,paper3-application}`,
with one ZIP alongside each folder. `PALOMAR_PACKAGE_MANIFEST.json` records
the exact source checkpoint, selected-input hashes, import closures,
generated files and inventory hashes. Freeze only after
`selected_inputs_changed_from_checkpoint` is empty. `--verify` checks source
identity, the exact module inventory, source limits, implementation holes,
local links, archive identity and deterministic archive timestamps.
Static verification does not invoke a proof checker.

Local evidence under `output/validation/` records the generated project
builds, the package checks and the actual upstream metadata-contract checks
at pipeline `14aa8d6b3c2f14a8540605e37144560b9a00e7e7`:
`palomar-slim-local-builds.json`, `palomar-slim-package-validation.json` and
`palomar-slim-upstream-metadata.json`. The metadata check invokes the pinned
`load_formalization_metadata` and `normalized_provenance` functions. It does
not claim full upstream JSON Schema validation or protected verification.
The local package builds reuse the existing pinned dependency caches.
The [earlier entry checks](MATH_STORAGE_VALIDATION.md#paper-3-independent-entries--2026-11-09)
record full local comparisons, Lean/NanoDa replay and the combined dependency
audit for the unchanged Lean sources.

## Protected preflight and publication boundary

**Protected Linux preflight has not run.** The development remote is private,
and this Mac has no Linux VM/container runtime. Palomar's
[complete reusable workflow](https://submit.palomar-registry.org/llms.txt)
requires the exact public repository and immutable commit. A local Comparator
diagnostic or cached build is separate evidence.

Each package includes a manual-only workflow at
`.github/workflows/palomar-preflight.yml`. It pins the workflow reference and
`pipeline_commit` to the same revision, uses `mode: full` and
`execution_profile: palomar-standard-v1`, and selects the nested `lean`
project with its exact configuration/metadata paths. A fresh request identifier
must have twelve lowercase alphanumeric characters. Dispatch the workflow
against the frozen entry branch and retain the mechanical report for that
exact commit. A passing preflight does not constitute editorial review or
registration.

The proposed publication is one new public repository containing three
independent branches, `paper1`, `paper3-coding` and `paper3-application`.
Each branch starts from its slim snapshot, with no private development
history. Local release commits and a Git bundle make the exact proposed
public content reviewable before publication. The destination and public
upload require the user's approval. No repository creation, push, visibility
change, workflow dispatch or registry submission is performed by the exporter.

After approval, publish only the frozen branches and run each branch's
preflight. Inspect the complete mechanical reports and resolve any failures
before requesting intake. Actual Palomar submission and registration remain
separate decisions, following the
[submission plan](PALOMAR_SUBMISSION_PLAN.md#reproducible-checks-and-remaining-steps).
