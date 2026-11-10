# Slim Palomar releases: Paper 1 first

Historical publication/preflight checkpoint, 2026-11-09: the approved Paper 1-only
snapshot is public on `main` in
[homotopical-encrypt-formalizations](https://github.com/what-social-construct/homotopical-encrypt-formalizations),
at commit `66e1ad2cb726d3dd816461e4f76b1d0d9147a46d`. The complete protected
[preflight run](https://github.com/what-social-construct/homotopical-encrypt-formalizations/actions/runs/42729947447)
has completed successfully. Its downloaded mechanical report passes exact
source, configuration, metadata, canonical provenance and protected comparison
checks. Lean, NanoDa and con-ron all accept. Its request identifier is
`p1pf875ad70f`.

The user authorized publication and preflight only and explicitly deferred
submission. **No registry intake or registration is authorized or performed.**
The mechanical report has been inspected and retained; this passing preflight
does not authorize an intake request.

**Current back-matter revision, 2026-11-09.** Paper 1 is **38 pages**. Its
mathematical body contains no Lean cross-reference blocks or implementation
filenames. Section 7 is *Conclusion and Further Work*. Appendix A consolidates
the correspondence into one parity table: four definition rows, eight main
result groups (21 declarations), five support groups (25 declarations), and
three external-result/assumption/contract rows. Appendix B keeps concise proof
boundaries. All **280 Lean files are byte-identical to `dddfdd2`**, so the
checked 9,295-job build and 975-report dependency state is retained; this
editorial change introduces no new Lean build claim. Paper 3 remains the
unchanged 31-page PDF. The bibliography reconciliation adds 19 records and
maps all 28 source-ledger IDs: Paper 1 cites seven entries, while Paper 2 and
Paper 3 retain 42 and 16 records respectively. Candidate bibliography
membership does not imply adoption or formalization. This revision remains
local; public `66e1ad2` and its historical protected report are unchanged.

**Earlier P300/P301 scope checkpoint, 2026-11-09:** the three-paper ownership split was
applied to the manuscripts. Paper 1 had 37 pages rather than the public
snapshot's 101; Paper 3 had 31 pages rather than the earlier package's 30.
The revised manuscripts and 93 comment-only Lean edits remained local and
were not protected-preflighted.
Fresh local validation passes the 9,295-job expanded build and all 975
selected dependency reports, preserving every prior dependency set. Those
PDFs passed build/render/layout QA. Revised packages use the separate local
`output/manuscript-split-review/` directory; no new hosted verification or
publication is claimed. The
published commit and PASS above apply only to their exact historical bytes.

The existing [three-paper ownership table](../SEMANTIC-PARITY.md#manuscript-ownership-and-dependency-table)
remains authoritative: Paper 1 owns HCP/Hodge/CVP foundations, the actual
Helfer fragment and observation/Plücker mathematics; Paper 2 owns concrete
cochain/commitment realization, codecs, visibility, gates/evidence and storage;
Paper 3 owns quantitative RS/proximity, radius/calibration and metric bridges.
Paper 3's core and bridge configurations are internal verification entries
for that one manuscript. They are not additional papers or a substitute for
Paper 2. Paper 2 remains a working draft outside the first public entry.

The following are historical technical packaging inventories, not a publication
split or an inventory of a refreshed package for the local revision:

| Package | Local Lean modules, including Challenge | Configured declarations | Manuscript |
|---|---:|---:|---|
| `paper1` | 31 | 46: 21 main / 25 support | Paper 1; 101-page manuscript/PDF frozen in the exact public snapshot |
| `paper3-coding` | 35 | 52: 36 main / 16 support | Earlier local Paper 3 package, 30 pages |
| `paper3-application` | 81 | 22: 10 main / 12 support | The same Paper 3 manuscript |

Only the historical `paper1` snapshot has been published for this preflight.
The two earlier Paper 3 packages retain their completed local checks and
remain unpublished; those checks do not validate the revised 31-page
manuscript or edited comments. Paper 2 is also outside this public snapshot.

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
python3 scripts/export_palomar_entries.py --output-dir output/manuscript-split-review --refresh
python3 scripts/export_palomar_entries.py --output-dir output/manuscript-split-review --verify
```

The revised output is `output/manuscript-split-review/{paper1,paper3-coding,paper3-application}`,
with one ZIP alongside each folder. `PALOMAR_PACKAGE_MANIFEST.json` records
the exact source checkpoint, selected-input hashes, import closures,
generated files and inventory hashes. Freeze only after
`selected_inputs_changed_from_checkpoint` is empty. `--verify` checks source
identity, the exact module inventory, source limits, implementation holes,
local links, archive identity and deterministic archive timestamps.
Static verification does not invoke a proof checker. The earlier
`output/palomar-slim/` packages and frozen public-release bundle are retained
as historical evidence; revised exports use the separate directory above.

The preceding local evidence under `output/validation/` records the generated project
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

The first frozen Paper 1 candidate, `73f9c28a4b9f8fb6a04e5b656389979be6b9cd92`,
predates the public snapshot's manuscript and metadata wording corrections. It is a
historical candidate. The revised TeX, PDF, README and metadata were frozen
together in the published commit `66e1ad2cb726d3dd816461e4f76b1d0d9147a46d`.
The subsequent 37-page scope checkpoint and current 38-page parity-table
revision are outside both historical public candidates. The revised packages
must carry the current manuscript and its exact source reference before any
future publication or protected preflight.
The final local records are `paper1-first-frozen-release.json`,
`paper1-first-local-validation.json` and `paper1-first-final-checkpoint.json`
under `output/validation/`; the hosted preflight result is separate evidence.

## Protected preflight and publication boundary

At the preceding local-preparation checkpoint, protected preflight had not
run: the development remote was private and this Mac had no Linux VM/container
runtime. The development repository remains private; only the approved slim
Paper 1 snapshot is now public. Palomar's
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

The earlier proposal for three technical release branches is superseded by
the Paper 1-first sequence. The public `main` contains only its historical slim
snapshot, without private development history. The checked Paper 3 candidates
remain local. The exporter itself performs no remote actions; the separately
authorized repository creation, exact-snapshot push and preflight dispatch
have now occurred. The private development remote was not changed.

The validated artifact `mechanical-report-p1pf875ad70f` is retained locally
with `paper1-protected-report-validation.json`. Its only advisory concerns
preferred Challenge review size: 977 lines / 49,234 bytes satisfy the hard
1,000-line / 100-KiB limits. Stop before intake. A later submission requires a new
explicit instruction and the author's final confirmation of the repository,
full commit SHA, configuration path and truthful author or maintainer
relationship. Registration remains a separate decision after reading a
future review, following the
[submission plan](PALOMAR_SUBMISSION_PLAN.md#reproducible-checks-and-remaining-steps).
