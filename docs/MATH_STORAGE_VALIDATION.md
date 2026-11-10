# Mathematics and sheaf-storage validation

This record covers the concrete Helfer/Hodge/CVP family and observation
adapters, Q04--Q07 and the native modular profile, the sheaf/storage adapters,
and D03's gap-boundary interface. It distinguishes
source coverage, checked proof statements and theorem dependencies. It does
not certify a concrete cryptographic scheme, an uninstantiated source-radius
profile, an efficient gap solver or a storage backend.



## Paper 1 abstract and motivation refinement — 2026-11-09

The second abstract paragraph is removed; the first is preserved exactly.
The motivation now begins with Helfer's first-order homotopical logic,
including the path-object and conditional homotopy-invariance account.
Three CVP-related contribution items are consolidated into one; the
introduction has four contribution items overall. The lattice inclusion,
correct-oracle obstruction, common homological observation and nonzero/
weighted cellular examples retain their qualifications. The introduction
starts on its own page after the contents.

All mathematical formulas, proposition statements, definitions and proofs
in §§1–6 are unchanged against `c677b73`; the parity table, bibliography and
Lean sources are unchanged. This prose/layout revision needs no repeated
Lean build. The **38-page PDF** builds with zero undefined references,
missing glyphs or overfull boxes (two underfull diagnostics), and passes
render/contact/detail review. Current Paper 1 SHA-256:
`21b4b9429dac7413b0910a33ee587c06fd9979b8e47548cd1e1825f0816f61ba`.
Canonical/stable copies match. Local evidence is
`paper1-abstract-helfer-*` under `output/validation/`.
The earlier protected result remains exact evidence for public `66e1ad2`;
no new hosted verification, publication or submission is claimed.

## Paper 1 parity table and bibliography revision — 2026-11-09

Paper 1 now places its implementation correspondence in one table after
§7, **Conclusion and Further Work**. The mathematical body contains no Lean
file/declaration listings. The table has four canonical-definition rows,
eight main-result groups (21 selected declarations), five support groups
(25 declarations), and three external-theorem/assumption/contract rows.
Every configured name occurs exactly once. Appendix B keeps the model,
noncomputability, observation and exact-snapshot proof boundaries.

All mathematical formulas, proposition statements, definitions and proofs in
§§1–6 match `dddfdd2` exactly. All **280 Lean files** are byte-identical;
no imports, definitions, statements, proofs, options or pins changed. The
previously completed 9,295-job build and 975 standard-only dependency reports
are therefore retained as the checked proof-source state. No new Lean build
or kernel replay is claimed for this manuscript-only revision.

The revised **38-page PDF** builds with zero undefined references/citations,
missing glyphs or overfull boxes (two underfull diagnostics). All pages are
rendered/contact-reviewed, with detailed changed-body and table checks.
The table's repeated headers/footers and all 46 PDF anchors are complete and
readable; Appendix B fits on its own page. Canonical/stable copies match.
Current Paper 1 SHA-256:
`20d68f7c26f0e0df0ce2a1c7f754399b2ca7a5aaf4ad5f17b83d4b0efecc7504`.

The [source ledger](SOURCE_LEDGER.md#bibliography-correspondence) now maps
all **28 sources** to bibliography keys/files and explicit roles. Nineteen
missing records were added after primary bibliographic metadata checks.
Paper 1 cites seven sources; Paper 2/3 retain 42/16 records. An isolated
BibTeX alpha-style check of every record in all three files passes without
warnings. Candidate records remain distinct from adopted arguments; no
`\nocite{*}` was added to the manuscripts. Paper 3's thirteen actually cited
alpha-style bibliography entries are byte-identical to their prior output,
so its reviewed 31-page PDF is unchanged. Both new Paper 1 citations retain
the relevant scope boundary: specialized isotropic reconstruction does not
identify the arbitrary Hodge carrier, and cohomology reduction supplies no
automatic original-metric/harmonic-representative comparison.

Local evidence is `paper1-backmatter-*` and `paper1-parity-bibliography-*`
under `output/validation/`. Public `66e1ad2` and its protected report remain
unchanged historical evidence. Revised informal material needs a fresh
exact-commit protected preflight; no publication, intake or registration is
performed by this local revision.

## Manuscript ownership revision — 2026-11-09

The current local manuscripts follow the recorded three-paper split. Paper 1
retains HCP/Hodge/CVP foundations, the actual Helfer homological fragment and
mathematical observation/full-Plucker recovery. Its selected appendix maps all
46 configured declarations exactly once: 21 main and 25 support across eight
groups. Paper 2 owns concrete cochain commitment, systematic codec,
visibility/security and protocol gate/evidence/storage contracts in its
working draft. Paper 3 owns quantitative RS, list/MCA and metric/radius
comparisons using that same original construction. Shared definitions are
recalled with attribution; they are not presented as duplicate new results.

Paper 1 is reduced from **101 to 37 pages**. Paper 3 is **31 pages**. Both
PDFs build with zero undefined references/citations, missing glyphs or
overfull boxes (two/one underfull diagnostics respectively). All 68 pages
were rendered and contact-inspected; detailed checks cover new and revised
sections, the selected crosswalk and references. The final bibliography
starts on its own page, avoiding an orphan entry. Canonical and stable review
copies match. Current SHA-256 values are:

- Paper 1: `8a10b144b679f3c3573494e6fab5f5a72a1f285a0ac24d47ae7506ef5e67290f`.
- Paper 3: `29b861942ebf168c3f7c839c45c67ba426538d5cea888bb3aaca2c9343f300dd`.

All non-comment bytes in **280 Lean files**, including Lake, match `b917cda`;
93 files have documentation-only edits assigning their current paper owner
or deferred supporting status. No import, statement, proof, option,
attribute, selected entry configuration or pin changed. Paper 3 §§2–6 are
byte-identical; all 19 application display equations are preserved modulo
whitespace. The current source scan has 279 modules, zero implementation
holes, 96 deliberate Challenge placeholders, seven isolated cited axioms,
no active native calls and no cycles or unresolved local imports. All 54
focused closures retain their cited-axiom/Chain exclusion. The pinned metadata
contract passes for all three entries. The fresh expanded build, explicitly
including all 15 default roots, storage/HCP/protocol integrations and all three
Solution entries, passes **9,295 jobs**. The fresh dependency probe passes all
**975 reports**: 792 use exactly the standard three axioms and 183 proper
subsets, including 106 axiom-free. All 975 pre-revision dependency sets match.
The three entries retain 46/52/22 reports (44/48/21 exact-three). No selected
report depends on native certificates, cited-bound axioms or `sorryAx`. The
older literal-default and independent comparison/kernel records below remain
their own dated evidence.

Evidence is retained under `output/validation/manuscript-split-*`: source and
comment audits, preservation inventories, build logs, PDF hashes/renders and
visual QA. These checks concern the local revision. The exact historical
public snapshot `66e1ad2` and its protected PASS below remain unchanged;
this revised candidate needs its own exact-commit protected preflight before
any later intake. The user continues to defer submission and registration.

## Paper 1 public protected preflight — 2026-11-09

The user authorized public publication and protected preflight only, explicitly
deferring submission. The separate public repository is
[homotopical-encrypt-formalizations](https://github.com/what-social-construct/homotopical-encrypt-formalizations).
Its `main` points to the exact approved Paper 1 root commit
`66e1ad2cb726d3dd816461e4f76b1d0d9147a46d`, with 54 files, 31 source modules
plus Lake and no private development history. The original development
repository remains private; its unrelated Rust edit is untouched. Paper 2 and
Paper 3 manuscripts are outside the published snapshot.

[Protected preflight run 42729947447](https://github.com/what-social-construct/homotopical-encrypt-formalizations/actions/runs/42729947447)
uses request `p1pf875ad70f`, `mode: full`, `palomar-standard-v1` and pipeline
`14aa8d6b3c2f14a8540605e37144560b9a00e7e7`. Its project is `lean`; the
configuration and metadata paths are
`lean/Palomar/PaperOne/comparator.json` and
`lean/Palomar/PaperOne/formalization.yaml`. The remote branch SHA was verified
before dispatch. The workflow and delivered schema-2 mechanical report both
**pass**. Exact source/configuration/metadata hashes match the frozen Git
snapshot. The canonical Challenge provenance is high-trust with no untrusted
sources. All 46 configured declarations pass protected definition/type
comparison with only the three permitted logical axioms. Lean's default
kernel, NanoDa and con-ron all accept; con-ron reports 45,899 exported
declarations checked. This is not a count of selected research results.

The report records Lean 4.35.0, `palomar-standard-v1` and bubblewrap `v0.12.0`.
Its only advisory is that the 977-line / 49,234-byte Challenge exceeds the
preferred 300-line / 32-KiB review size; it satisfies the 1,000-line / 100-KiB
hard limits. No formal statement was changed to remove that advisory.

Local records are `paper1-protected-preflight-request.json` and
`paper1-protected-preflight-run.json`, the downloaded
`paper1-protected-artifact/mechanical-report.json`, artifact identity/digest
metadata and `paper1-protected-report-validation.json` under
`output/validation/`. The artifact is `mechanical-report-p1pf875ad70f`.
No Palomar intake, editorial review or registration has been requested.
The user's instruction to defer submission remains in force.

## Paper 1 final manuscript and first-release scope — 2026-11-09

Paper 1 is the first publication/submission priority. The established split
remains Paper 1 HCP foundations, Paper 2 protocol/cochains/commitments and
Paper 3 proximity. Its first public snapshot contains only the selected
Paper 1 proof closure and manuscript; Paper 3's two configurations remain
internal core/bridge verification entries for that same third manuscript.

The final manuscript foregrounds the constructed nonzero-target family and
weighted shared observation `b=(1,2)` with integer coefficients two and one.
It distinguishes the elementary projection/CVP identities from a
computational-hardness claim. The declared cellular carrier is the
algebraic finite signed-incidence model; no regular CW or simplicial
realization of the example's base is asserted. The selected theorems and
all 279 Lean source hashes are unchanged.

The appendix now describes the legacy spectral relation as equal nullity,
and its density/`success_prob_*` interfaces as likelihood scores. The main
text explicitly distinguishes the corrected Euclidean pointwise and
factorization endpoints from the legacy supremum-norm integrated functions.
The selected entry does not include those integrated endpoints. The source
account identifies Hansen--Ghrist's published 2019 reference and the standard
CVP reference, while retaining the proved homological-test fragment.

The revised PDF remains **101 pages**, SHA-256
`9a9c43143a24c0ea8a9717b33d9ed9bf5ac82dbedec1dcc9152aa37d96b66320`.
Canonical and stable review copies match. The final build has zero undefined
references/citations, missing glyphs and overfull boxes; seven underfull
diagnostics remain. All 101 pages were rendered and inspected through six
contact sheets; detailed inspection includes pages 1, 5, 6, 22, 36, 95,
100 and 101. No clipping, overlap or broken glyphs was found.
Local evidence is `paper1-final-manuscript-build.log` and
`paper1-final-render/` under `output/validation/`.

The two newly reviewed source candidates are indexed in the source ledger
(now 28 entries): deontic simplicial joint commitments for Paper 2 and
full-length RS list limitations for Paper 3. Neither is adopted as a Lean
dependency or required to complete the selected Paper 1 statements.
The earlier local comparison/kernel and 975-report dependency records remain
evidence for unchanged Lean bytes. Protected preflight and intake are
separate, exact-commit checks; the earlier candidate `73f9c28` is superseded
by the final manuscript release.

## Slim entry packages — 2026-11-09

The [slim release guide](PALOMAR_SLIM_RELEASES.md) records three separately
scoped local packages. Their Lean sources, configurations, metadata and
corresponding manuscripts are byte-identical to the checked development
sources. Only the Lake configuration, root README, manual preflight workflow
and packaging records are generated; existing crosswalk changes affect
navigation only.

| Entry | Exact local modules | Files including manifest | Default Solution build | Separate Challenge build |
|---|---:|---:|---:|---:|
| Paper 1 | 31 | 54 | Pass, 3,667 jobs | Pass, 3,516 jobs |
| Paper 3 coding | 35 | 58 | Pass, 3,174 jobs | Pass, 3,138 jobs |
| Paper 3 application | 81 | 104 | Pass, 3,435 jobs | Pass, 3,207 jobs |

These six builds use disposable package copies and the existing pinned
dependency/compiled caches. They check each generated Lake project, including
its Solution-only default and explicit Challenge target; they do not claim
a clean Linux rebuild. The original source comparison/kernel/dependency
records below remain applicable to the unchanged Lean bytes.

Independent source/informal inspection covers the three Solution closures
(30/34/80 modules; 118 distinct modules combined). No material alignment
problem requiring a Lean edit was found. Selected security and runtime
claims remain conditional. Full manuscript PDF/TeX/bibliography copies
provide context; their entire contents are not advertised as selected
formal statements. Plans and broader paper READMEs are excluded.

The actual pinned Palomar metadata contract passes all three files through
`load_formalization_metadata` and `normalized_provenance` at pipeline
`14aa8d6b3c2f14a8540605e37144560b9a00e7e7`. All are classified as substantive
developments because the proof closures are included. This is the mechanical
metadata minimum, not a full JSON Schema or complete hosted preflight result.

Static package checks verify exact import closures and module inventories,
source hashes, size/header requirements, zero implementation holes, no
native/custom-axiom declarations, local navigation and ZIP identity. Repeated
exports are deterministic. Local records are
`palomar-slim-package-validation.json`, `palomar-slim-local-builds.json`,
`palomar-slim-*-build.log` and `palomar-slim-upstream-metadata.json` under
`output/validation/`. Final release records bind the frozen local commits
and archive hashes to their precise development checkpoint.

**Protected Linux preflight and publication have not occurred.** The current
GitHub remote is private, and this Mac has no Linux container/VM runtime.
The public immutable snapshots require approval before the included
manual-only workflows can run. No remote creation, push, visibility change,
workflow dispatch, intake or registration was performed in preparing these
packages. No Lean declaration or dependency pin changed in this step.

## Paper 3 independent entries — 2026-11-09

**Local comparison, kernel replay and dependency verification completed.**
Both entries pass full local comparison and both kernel replays. The combined
975-declaration audit passes and preserves all 946 earlier dependency sets.
Protected Linux preflight remains a separate, unperformed check.

The same manuscript is covered by a [coding entry](../lean/Palomar/PaperThree/README.md)
and an [original-cochain companion](../lean/Palomar/PaperThree/Application/README.md).
All fourteen selected Paper 3 groups are retained: the nine coding groups,
spectrum/distance interpretation and four application/boundary groups. P3-A02
has statements in both entries. Each Challenge independently defines the
actual canonical mathematical objects using Mathlib-only imports; each
Solution imports the canonical proofs. Three application statements unfold
the same calibration interfaces and are proved with `change` and the original
theorem, preserving Context, decoder, payload, maps and metric normalization.

| Check | Current local result |
|---|---|
| Coding Challenge/Solution | Pass **3,138/3,173 jobs**. Challenge **771 lines / 36,949 bytes**; 52 configured theorems, 36 manuscript-facing and 16 supporting. |
| Coding full comparison and kernels | **Pass**: ordinary definitions and theorem types match; Lean and NanoDa accept the Solution with only the three permitted logical axioms. |
| Application Challenge/Solution | Pass **3,207/3,434 jobs**. Challenge **992 lines / 46,768 bytes**; 22 configured theorems, ten manuscript-facing and twelve supporting. |
| Application full comparison and kernels | **Pass**: ordinary definitions and theorem types match; Lean and NanoDa accept the Solution with only the three permitted logical axioms. |
| Encoder/opening preservation | **Pass**: two `rfl` proofs compare their current values against the exact formulas extracted from commit `7550314`. Both reports use exactly the three standard axioms. |
| Combined dependency probe | **Pass**: 975 standard-only reports, 792 exact-three and 183 subsets, including 106 axiom-free. All 946 prior sets match; 29 direct reports added. Coding: 52 reports (48 exact-three/four subsets); application: 22 (21 exact-three/one subset). No selected native, cited-bound or sorryAx dependency. |
| Static source/import scan | **279 modules / 280 Lean files**; 96 deliberate holes isolated in the three Challenges, zero implementation holes; no active native calls, cycles or unresolved imports. Same seven isolated cited axioms. |
| Aggregate builds | Literal default **9,285 jobs**; expanded union with all three Solutions **9,295 jobs**. |
| Local import closures | All 50 prior focused closures are retained. Added coding Challenge/Solution: **1/34** local modules; application: **1/80**. All 54 focused closures exclude `Chain` and `CitedBounds`. |
| Protected verification / publication | **Not run**. Local Comparator uses macOS `--inadvisably-no-sandbox`; no workflow dispatch, push, release or registry submission occurred. |

The independent files restore Lean's nonpersistent auxiliary-lemma cache at
canonical source boundaries and spell the original universe parameters
explicitly. These changes align generated proof references; ordinary values
remain the comparison targets. The concrete encoder's existing coordinate
function and linearity proofs are now named separately. Its exponent two and
the integer opening use an explicit natural-number cast; the preservation
probe proves definitionally equal values, and existing theorem signatures are
retained. Three new public declarations name that same encoder function and
its two linearity laws; the old embedded proofs are factored into those laws.
Three old native-trust comments and the storage README were corrected
to describe the already kernel-checked arithmetic certificates.

The four named-capacity support statements bind well-formedness and all three
`3/4` distances to the same payload used by the bad-fraction and scalar-distance
statements. Accepted zero distances retain the matching interpretation/layout
decoder equality and `Context.Accepted`. The characteristic-three family,
boundary prime and original `12289` payload keep separate roles. These entries
provide no stronger HCP/geometric metric, cryptographic security or runtime claim.

Local records are `paper3-{core,application}-{challenge,solution}-build.log`,
`paper3-{core,application}-local-comparator.log`,
`paper3-encoder-definition-preservation.{lean,log}`,
`paper3-entries-all-axioms.{lean,log}`, `paper3-entries-axiom-summary.json`,
and `paper3-entries-source-audit.json` under `output/validation/`.
The preceding Paper 1 record remains a
completed, separately dated baseline.

### Reproduce the Paper 3 entry checks

From `lean/`, build each independent module separately:

```sh
LEAN_NUM_THREADS=1 lake build Palomar.PaperThree.Challenge
LEAN_NUM_THREADS=1 lake build Palomar.PaperThree.Solution
LEAN_NUM_THREADS=1 lake build Palomar.PaperThree.Application.Challenge
LEAN_NUM_THREADS=1 lake build Palomar.PaperThree.Application.Solution
python3 - <<'PY' > /tmp/paper3-entries-axioms.lean
import json
from pathlib import Path
entries = ['Palomar/PaperThree', 'Palomar/PaperThree/Application']
configs = [json.loads((Path(entry) / 'comparator.json').read_text())
           for entry in entries]
for config in configs:
    print('import ' + config['solution_module'])
for name in dict.fromkeys(name for config in configs
                          for name in config['theorem_names']):
    print('#print axioms ' + name)
PY
LEAN_NUM_THREADS=1 lake env lean -j1 /tmp/paper3-entries-axioms.lean
```

Check exit status zero and all 74 selected entry dependency reports against
`propext`, `Quot.sound` and `Classical.choice`. The combined 975-report probe
additionally retains the earlier audited declarations; its source and output
are listed above. On supported Linux, run each full comparison separately:

```sh
LEAN_NUM_THREADS=1 lake comparator --config Palomar/PaperThree/comparator.json
LEAN_NUM_THREADS=1 lake comparator --config Palomar/PaperThree/Application/comparator.json
```

Those protected commands have not run here. The completed local diagnostic
made the pinned toolchain's `nanoda_bin` available on `PATH` and added
`--inadvisably-no-sandbox`; both final logs explicitly report acceptance by
NanoDa and Lean's default kernel.

## Paper 1 independent entry — 2026-11-09

**Preserved P291 baseline.** The Paper 3 section above records the current
source inventory, aggregate builds and combined dependency counts.

The [Paper 1 entry](../lean/Palomar/PaperOne/README.md) now states all eight
selected manuscript groups independently and proves them through adapters to
the canonical development. The entry follows the frozen Jacobian package's
Challenge/Solution and source-crosswalk conventions. Its headline content is
the discrete CVP projection comparison and actual cellular public-target
ambiguity, with Hodge/recovery and observation-boundary results retained.
There are **21 manuscript-facing declarations / 25 supporting declarations**,
not 46 independent research contributions.

### Statement and proof checks

| Check | Completed local result |
|---|---|
| Independent Challenge | Mathlib-only imports; **3,516-job** build passes. Transparent definitions and **23 intentional theorem placeholders**, all selected by Comparator; no definition holes. |
| Proved Solution | **3,666-job** build passes; explicit canonical proof adapters, no Challenge import and no proof/definition holes. |
| Local Comparator | **Pass** for all 46 selected theorems and reachable definition comparison; permitted axioms are only `propext`, `Quot.sound`, `Classical.choice`. Both Lean's default kernel and NanoDa accept the exported Solution. |
| Execution boundary | The macOS diagnostic used `--inadvisably-no-sandbox`. This local result is **not protected preflight evidence**. Supported Linux sandbox verification has not run. |
| Fresh entry dependencies | **46 standard-only reports**: 44 exact-three and two proper subsets. No native, cited-bound or `sorryAx` dependency. |
| Retained plus entry dependencies | **946 standard-only reports**: 768 exact-three and 178 subsets, including 106 axiom-free. All **900 previous dependency sets match**. |
| Aggregate builds | Literal default **9,285 jobs**; expanded union including the Solution **9,293 jobs**. All 15 default targets are retained; the Palomar library is nondefault. |
| Static source/import scan | **275 public modules / 276 Lean files**, including Lake; all **273 previous owner hashes** and **48 previous scoped closures** are unchanged. Two entry closures added: Challenge one local module, Solution 30. Both exclude `Chain` and `CitedBounds`. |

The source scanner distinguishes Challenge's 23 deliberate holes from zero
implementation holes. There are no active native calls, local import cycles
or unresolved imports; the same seven global cited axioms remain isolated in
`CitedBounds`. Every source has the module/public-section header. The largest
source is the 1,292-line Solution. Challenge is **977 physical lines / 49,234
bytes**, within the current 1,000-line/100-KiB hard limits and above the
published 300-line/32-KiB warning thresholds. These counts are source checks,
separate from dependency and kernel verification.

All compared definitions have ordinary transparent meanings. In particular,
the independent Challenge restates the two pure finite-product helpers
`Hcrypt.Helfer.contextObject/contextMap` under their canonical names; the
remaining statement vocabulary lives in `Hcrypt.Palomar.PaperOne`. Structural
comparison checks the actual context construction, incidence maps, integral
stalks, Hodge operators, public theory, explicit lattices and genuine exterior
quotient. The private adapters do not replace these objects with abstract
predicates. The supporting `AxisFamily.cellular_complex_iso` exhibits an
actual isomorphism of the constructed complexes; public-theory equality is
not an added premise.

README and v0.4 metadata record sources, eight-group correspondence,
automation and agent review, as well as the remaining protected-verification
boundary. This entry gives exact mathematical results, not asymptotic
CVP-hardness or sampled cryptographic security. Paper 3's independent entry,
a frozen slim public release and registry submission remain separate work.
The manual-only preflight workflow is prepared locally and has not run.
Both manuscript TeX/PDF trees, dependency pins and the unrelated Rust edit
are unchanged; the prior PDF hashes below still apply.

Local evidence under `output/validation/`:
`paper1-entry-{challenge,solution,default,full}-build.log`,
`paper1-entry-local-comparator.log`, `paper1-entry-{all-axioms,axioms}.lean`,
`paper1-entry-all-axioms.log`, `paper1-entry-axiom-summary.json`,
`paper1-entry-source-audit.json`, `paper1-entry-selection.json` and
`paper1-entry-validation.json`. These are local records rather than registry
reports. The previous `submission-*` records remain the dated P289 baseline.

### Reproduce the independent entry checks

From `lean/`, using the pinned Lean/Mathlib manifest:

```sh
LEAN_NUM_THREADS=1 lake build Palomar.PaperOne.Challenge
LEAN_NUM_THREADS=1 lake build Palomar.PaperOne.Solution
python3 - <<'PY' > /tmp/paper1-entry-axioms.lean
import json
from pathlib import Path
config = json.loads(Path('Palomar/PaperOne/comparator.json').read_text())
print('import Palomar.PaperOne.Solution')
for declaration in config['theorem_names']:
    print('#print axioms ' + declaration)
PY
LEAN_NUM_THREADS=1 lake env lean -j1 /tmp/paper1-entry-axioms.lean
```

Check all 46 dependency reports and exit status zero; importing the Solution
alone is not an axiom audit. On the supported Linux sandbox, the protected
comparison command is:

```sh
LEAN_NUM_THREADS=1 lake comparator --config Palomar/PaperOne/comparator.json
```

That protected command has not been run here. The completed local macOS
diagnostic instead placed the pinned toolchain's binary directory on `PATH`
so `nanoda_bin` was available, and used `--inadvisably-no-sandbox`. Its log
explicitly warns that sandboxing is disabled. The prepared GitHub workflow
selects the nested `lean` project and records the exact source/pipeline commit;
no upload or workflow dispatch was performed.

## Selected statements and kernel arithmetic — 2026-11-08

**Preserved P289 implementation baseline.** The entry sections above supersede
this section's wrapper status and source/declaration counts. All 900 dependency
sets described here remain unchanged. The current Paper 3 record identifies
the five later owner-file changes and the encoder/opening preservation checks.

The [submission statement table](PALOMAR_SUBMISSION_PLAN.md#selected-manuscript-statement-surface--2026-11-08)
is derived from the manuscripts' existing named propositions and theorems.
Paper 1 foregrounds the discrete CVP comparison, actual cellular recovery and
kernel ambiguity, including the distinct soundness/exact-on-harmonics and
direct-operative-target oracle contracts. Paper 3 retains its nine original
coding groups, spectrum/distance interpretation and separately scoped modular
application. The table has **22 statement groups / 70 proof or object owners**;
these are coverage counts, not claims of 70 new research theorems. Independent
Challenge/Solution files, metadata and protected comparison were future work
at this milestone; the subsequent entry section records Paper 1's local checks.

### Mathematics and arithmetic trust

`Hodge_Decomposition_unique` now proves the manuscript's componentwise
uniqueness from the actual complex equation and harmonic/exact/coexact
membership. The old existence/orthogonality theorem API is preserved. It does
not assume pairwise orthogonality or uniqueness of the degree-zero/degree-two
openings; the cochain components are unique. This repairs D43 rather than
weakening the manuscript proposition.

The boundary-field Lucas/Pratt proof uses five additional private small-prime
certificates, kernel numeral arithmetic and binary modular-exponentiation
proof terms. The canonical `12289` primality, unit/root/order and numerical
target/spectrum certificates likewise use kernel proofs. All **159
pre-existing public declaration headers** across the seven changed Lean files
are unchanged, including all **33** old BoundaryField headers. The field,
root, domain, projection and metric objects are retained. The only new public
declaration is the Hodge uniqueness companion; no replacement result is
hidden in a new premise. No active `native_decide` call remains in the source.

### Current checks and preserved baseline

The expanded union and literal default builds pass **9,292/9,285 jobs** on
Lean/Mathlib 4.35.0. The fresh combined probe passes **900 declaration reports**:
**724 exact-standard-three** and **176 proper subsets** (including **106
axiom-free**); every report uses only `propext`, `Classical.choice` and
`Quot.sound`. There are **zero** native, cited-bound or `sorryAx` dependencies
in this selection.

All **806** previously standard-only dependency sets match exactly. The **49**
previously native-dependent reports are now standard-only. The **45** added
reports complete the 70-owner statement selection, including the boundary
instance and new uniqueness companion; the preceding 855-report inventory is
retained in full. Old generated native-certificate reports are preserved as
historical evidence and are not the trust footprint of the current proofs.
A separate 37-report boundary probe also passes (28 exact-three/nine subsets,
five axiom-free). The interrupted, incomplete 20-name arithmetic probe is not
counted as successful evidence; its relevant proof dependencies are checked
through the completed combined audit.

Static coverage remains **273 public modules / 274 Lean files**. Exactly
**seven** Lean modules changed; the other **266** source hashes match P283.
There are no active holes, import cycles or unresolved local imports, and the
same **seven** custom literature axioms remain isolated in `CitedBounds`.
All **48** scoped import closures, their counts and exclusions of `Chain` and
`CitedBounds` match the preceding source audit; `ProximityPrize` remains 33
modules. The largest public source has **1118 physical lines**.
This source/import check is separate from compilation and theorem dependencies.

Paper 3's §8 now describes the kernel arithmetic trust boundary. The **30-page**
PDF compiles without undefined references/citations, missing glyphs or overfull
boxes; one underfull diagnostic remains. Changed/reflowed pages **27--30**
were rendered and visually checked. Canonical and stable review copies match.
Current Paper 3 SHA-256: `68664a349e191df068dd6ba92ba5f94fbcfe728dc843c967d679dcd08920da7e`.
Paper 1's **101-page** PDF remains byte-for-byte unchanged at
`7a9feb8ad8dd080ddeb06fad4d82c3c06188571ae7411c12d2a1d75f302f1123`;
its mathematical proposition is unchanged and now has the additional Lean
uniqueness proof. The unrelated pre-existing Rust storage edit is preserved.
Seven source line anchors were refreshed without changing object IDs.

Local evidence under `output/validation/`:
`submission-{full,default,tex}-build.log`,
`submission-{all,selected,boundary}-axioms.lean`,
`submission-{all,boundary}-axioms.log`, `submission-axiom-summary.json`,
`submission-selected-statements.json`, `submission-public-api-validation.json`,
`submission-source-audit{,-summary}.json`, `submission-validation.json`,
and changed PDF pages under `submission-render/`.

Reproduce the selected-owner probe from `lean/` after building the current
full/default roots and explicit integration targets listed in this guide:

```sh
cat > /tmp/submission-selected-axioms.lean <<'LEAN'
import Hardness
import HCP.AxisFamily
import Sheaf.CoefficientRecovery
import Sheaf.ObservationQuotient
import TCB.PluckerObservation
import ProximityPrize
import Protocol.Storage.CanonicalCalibration
import Protocol.Storage.CanonicalThreeLevel
import Proximity.Concrete.CanonicalRS.MCA.Spectrum

#print axioms Hodge_Decomposition_Theorem
#print axioms Hodge_Decomposition_unique
#print axioms Hcrypt.Sheaf.CellularSheaf.HodgeEncryptedCochain.harmonicOneProjection_observed
#print axioms Hcrypt.Sheaf.CellularSheaf.HarmonicLatticePresentation.decodeCoefficients_encrypt
#print axioms exists_matrix_ker_eq_range
#print axioms Hodge_GeneratedSubspace_Reduction_Proof
#print axioms HarmonicCVPBridge.squaredDistance_projection_decomposition
#print axioms HarmonicCVPBridge.solution_iff_projectedTarget
#print axioms concreteSheafHCP_CVP_solution_iff_message
#print axioms concreteSheafHCP_CVP_existsUnique
#print axioms Hcrypt.HCPBridge.operativeTargets_ne_of_kernelSeparation
#print axioms Hcrypt.HCPBridge.cvpOracle_insufficient_of_kernelSeparation
#print axioms Hcrypt.HCPBridge.cvpOracle_insufficient_for_operativeTarget
#print axioms Hcrypt.HCP.AxisFamily.shared_observation_distinct_nonzero_targets
#print axioms Hcrypt.HCP.AxisFamily.cvp_oracle_insufficient
#print axioms Hcrypt.HCP.AxisFamily.weighted_public_observations_eq
#print axioms Hcrypt.HCP.AxisFamily.no_exact_encoded_message_decoder
#print axioms Hcrypt.HCP.AxisFamily.weighted_cvp_solution_iff_operativeTarget
#print axioms Hcrypt.HCP.AxisFamily.weighted_cvp_existsUnique
#print axioms Hcrypt.Sheaf.CellularSheaf.HodgeEncryptedCochain.not_residual_norm_factors_exactComponent
#print axioms Hcrypt.Sheaf.CellularSheaf.HodgeEncryptedCochain.not_far_preserving_exactComponent
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.recoverSubspace_frame
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.recoverHarmonicProjector_frame
#print axioms Hcrypt.TCB.PluckerObservation.recover_eq_operativeHarmonicComponent
#print axioms ProximityPrize.planePairEquiv
#print axioms ProximityPrize.planePairEquiv_hammingDistance
#print axioms ProximityPrize.planePairEquiv_relativeHammingDistance
#print axioms ProximityPrize.planeLineEquiv
#print axioms ProximityPrize.ReedSolomon.Parameters.vectorListSizeBoundAt_capacityGrid
#print axioms ProximityPrize.ReedSolomon.Parameters.capacityReceived_ballCardAt_eq_choose
#print axioms ProximityPrize.ReedSolomon.Parameters.vectorFractionalListSizeBoundAt_capacityGrid_iff
#print axioms ProximityPrize.ReedSolomon.Parameters.fieldCard_pow_le_nextShell_ballCardAt
#print axioms ProximityPrize.ReedSolomon.Parameters.vectorFractionalListPhaseSplit
#print axioms ProximityPrize.ReedSolomon.Parameters.vectorFractionalListGridThreshold
#print axioms ProximityPrize.ReedSolomon.Parameters.vectorFractionalListRealThreshold
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.rootUnit_order
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.realized_fractionalListSizeBoundAt_capacity
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.realized_listGridThreshold
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.realized_listSafeRelativeRadii_eq_Ico
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.realized_listRealThreshold
#print axioms ProximityPrize.ReedSolomon.Parameters.badChallengeSetAt_card_le_choose_succ
#print axioms ProximityPrize.ReedSolomon.Parameters.pairMCAErrorBoundAt_of_compressed_budget
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.realized_pairMCAErrorBoundAt
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.realized_pairMCAGreatestSafe_eq_length
#print axioms ProximityPrize.MCA.BoundaryField.modulus_prime
#print axioms ProximityPrize.MCA.BoundaryField.candidateRootUnit_order
#print axioms ProximityPrize.MCA.BoundaryField.paperMCABadSpectrum_zero_eq_one
#print axioms ProximityPrize.MCA.BoundaryField.two_le_paperMCABadSpectrum_one
#print axioms ProximityPrize.MCA.BoundaryField.pairMCA_exact_128_bit_threshold
#print axioms ProximityPrize.MCA.BoundaryField.pairMCA_safeRelativeRadii_128_eq_Ico
#print axioms ProximityPrize.MCA.BoundaryField.pairMCA_real_128_threshold
#print axioms ProximityPrize.BlockCode.pairMCAErrorBoundAt_relativeRadius_invPow_iff_spectrum_budget
#print axioms ProximityPrize.BlockCode.pairMCAThreshold_eq_of_countBound_and_badLine
#print axioms ProximityPrize.BlockCode.scalarDistance_ge_of_pairDistance_ge_of_good
#print axioms ProximityPrize.ReedSolomon.Parameters.scalarDistance_eq_capacity_of_pairFar_of_good
#print axioms Hcrypt.Sheaf.SystematicCode.modularExact_iff_vectorCodeword
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.three_native_distance_comparison
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.flatDistance_eq_rsFlatDistance
#print axioms ProximityPrize.ReedSolomon.Parameters.zeroDirectionPowerLine_pairDistance_eq_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.zeroDirectionPowerLine_flatDistance_eq_half_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.no_unit_pair_distance_bound_by_flat_distance
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.calibration_extract_eq_original_pair
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.sourceFar_implies_rsFar
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.planeNear_of_scaledSourceNear
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.exists_payload_at_capacity
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_badChallengeFraction
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_canonicalMix_scalarDistance
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.accepted_nativeDistances_zero
#print axioms ProximityPrize.ReedSolomon.Parameters.no_fixedChallenge_pair_far_preservation
#print axioms ProximityPrize.ReedSolomon.Parameters.no_fixedChallenge_flat_far_preservation
LEAN
LEAN_NUM_THREADS=1 lake env lean -j1 /tmp/submission-selected-axioms.lean
```

## Paper 3 summary and source comparison — 2026-11-08

**Preserved P284–P285 alignment baseline.** P289 and the current section above
supersede this section’s source hashes, native-dependency status and Paper 3
PDF hash. The native dependencies described here were subsequently removed;
its counts and artifact hashes remain dated evidence.

Paper 3's abstract and introduction now state the completed intrinsic modular
application: the original integer payload reduces to the actual cellular
coboundary-image relation, with independently defined native distances
`d_C ≤ d_P = D_RS ≤ 2d_C`. Section 7 states the sharp factor-two witness and
ties the serialized capacity payload to `(q,n,k)=(12289,4096,1024)`. It keeps
raw proximity inputs separate from accepted exact anchors, and this wire field
separate from the large-field coding family. The generic source score is now
correctly nonnegative rather than restricted to `[0,1]`; the independently
chosen Euclidean/full-HCP comparison remains a separate obligation.

The bounded source comparison is integrated in §§5--7 and the bibliography.
It identifies the actual reduced vector, modular validity relation and fixed-γ
linear output; authenticated outputs alone do not supply the source-distance
comparison. Classical deep holes, the BCHKS/DKT regimes, BCGM background and
the saving relative to this development's older certificate count are stated
with their respective scopes. No priority, new commitment primitive,
cryptographic security or verification-cost superiority is established.
[The comparison note](PROXIMITY_NOVELTY_COMPARISON.md) records source-specific
review depth and adoption limits; the [source ledger](SOURCE_LEDGER.md) now
indexes **26 readings**. Section 8 records the completed application and the
canonical native-certificate trust boundary.

### Summary-alignment validation and trust boundary

A fresh focused probe rechecks **twelve existing endpoints**: **six
standard-only** and **six inheriting existing canonical native certificates**.
All twelve already occur in P283's **855-report** consolidated selection, and
all twelve dependency sets are unchanged; the focused check adds no reports to
that total. All **273 Lean source hashes match** the P283 checkpoint, so its
expanded/default **9,292/9,285-job** builds remain the applicable source
baseline. No Lean source changed, and no new axiom, cited-bound or `sorryAx`
dependency was introduced. Submission endpoints using canonical arithmetic
still need their selected native trust dependencies removed if the entry
permits only the three standard logical axioms.

The revised **30-page** Paper 3 PDF compiles without undefined
references/citations, missing glyphs or overfull boxes. All thirty pages were
rendered and reviewed in two contact sheets; pages 1, 4, 9, 12, 16, 22--24 and
27--28 were checked at higher resolution. One underfull-box diagnostic remains,
with no visible defect found. Canonical and stable review copies match
byte-for-byte. Paper 3 SHA-256 at this preserved alignment checkpoint:
`6a9c0cab59f433a12ed2f993ca4c4ec004b234802c4f331cf205220bc718bf42`.
Paper 1 remains the unchanged, reviewed **101-page** PDF at SHA-256
`7a9feb8ad8dd080ddeb06fad4d82c3c06188571ae7411c12d2a1d75f302f1123`.
The pre-existing Rust storage edit is preserved unchanged.

Local evidence under `output/validation/`:
`paper3-alignment-{tex-build,axioms}.log`,
`paper3-alignment-axiom-summary.json`, `paper3-alignment-validation.json`,
with rendered QA pages in `paper3-alignment-render/`.

Reproduce the focused correspondence check from `lean/`:

```sh
cat > /tmp/paper3-alignment-axioms.lean <<'LEAN'
import Protocol.Storage.CanonicalCalibration
import Protocol.Storage.CanonicalThreeLevel
import Proximity.Core.MetricSharpness

#print axioms Hcrypt.Sheaf.SystematicCode.modularExact_iff_vectorCodeword
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.three_native_distance_comparison
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.flatDistance_eq_rsFlatDistance
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.calibration_extract_eq_original_pair
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.sourceFar_implies_rsFar
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.planeNear_of_scaledSourceNear
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.exists_payload_at_capacity
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_badChallengeFraction
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.accepted_nativeDistances_zero
#print axioms ProximityPrize.ReedSolomon.Parameters.zeroDirectionPowerLine_pairDistance_eq_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.zeroDirectionPowerLine_flatDistance_eq_half_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.no_unit_pair_distance_bound_by_flat_distance
LEAN
lake env lean /tmp/paper3-alignment-axioms.lean
```

## Strict canonical decision profile — 2026-11-08

**Preserved P282–P283 decision-profile baseline.** The decision convention is
retained. P289 supersedes this section’s source/dependency snapshot; the former
canonical native trust has been removed.

D03's selected canonical decision convention is now resolved without replacing
any source, metric, projection, far-witness or gap-problem carrier. The existing
`RadiusCalibration.sameRadius` makes the **source and target radius pairs**
agree; it does not require near and far to coincide. The new calibration is
`(ε,δ_J,ε,δ_J)` for `ε<δ_J`. The intended manuscript profile also selects
`0≤ε`; its concrete near value is `2046/4096`, while the far/list/MCA radius
remains `δ_J=2047/4096`.

| Existing module | Added correspondence |
|---|---|
| [BridgeWitness](../lean/Proximity/Concrete/CanonicalRS/BridgeWitness.lean) | Separated calibration, exact four radii and strictness; independent rational near value/nonnegativity/comparison, then an adapter to the existing canonical Johnson radius. The old equal-threshold helper remains conditional compatibility packaging. |
| [BridgeCertificate](../lean/Proximity/Concrete/CanonicalRS/BridgeCertificate.lean) | The same naturality and Johnson far witness construct the existing metric certificate and completed bridge. Exact bridge radii and literal `Γ.receivedWord` map are retained. The existing GapBoundary strict views and GapReduction theorem supply the correct-solver pullback on disjoint closed promises. |

Paper 1 §6.1, Proposition 6.27 and Corollary 6.30 state the chosen strict
profile; the list-decoding and MCA hypotheses retain their original radii.
The geometric far-separation witness is still an application hypothesis, and
no efficient solver or new cryptographic security result is constructed.

### Decision-profile validation and trust boundary

The final focused build passes **3,276 jobs**, expanded union **9,292** and
literal default **9,285**. The final eight-import probe passes **855 selected
reports**: **806 standard-only** (630 exact-three, 176 subsets) and **49 with
existing native certificates**. All **839 preceding dependency sets match**.
The sixteen additions split into **three exact-standard-three arithmetic
reports** and **thirteen inheriting existing canonical native dependencies**.
These are declaration reports, including definitions and interface joins,
rather than a count of new research results.

The pure value and rational proofs have no `BridgeData` parameter. The thirteen
canonical adapters retain that type's native arithmetic dependencies in their
types/proofs. Completing the bridge also reaches the **pre-existing**
`length_dvd_canonical_modulus_minus_one` native certificate, which was outside
the preceding selected audit. No new `axiom` or `native_decide` declaration is
added. No selected cited-bound or `sorryAx` dependency occurs. These native
canonical endpoints still need arithmetic trust removal before a Palomar entry
permitting only the three standard logical axioms can select them; the pure
rational helpers do not have that blocker.

Static coverage remains **273 public modules / 274 Lean files**, with no
active holes, local import cycles or unresolved imports. The same seven custom
literature axioms remain isolated in `CitedBounds`. All **48** scoped closures
exclude `Chain` and `CitedBounds`: the newly recorded witness/certificate
closures have 33/45 local modules; all 46 preceding closure counts are
unchanged. `ProximityPrize` remains 33 modules and independent of these
concrete application helpers. Pins remain Lean/Mathlib 4.35.0.

The revised **101-page** Paper 1 PDF compiles without undefined
references/citations, missing glyphs or overfull boxes. All pages were rendered
and reviewed in six contact sheets; pages 53--54, 78--79 and 81--83 were
inspected at higher resolution. Eight underfull-box diagnostics remain, with
no visible defect found. Canonical/stable copies match; Paper 3 is unchanged.
Current Paper 1 SHA-256:
`7a9feb8ad8dd080ddeb06fad4d82c3c06188571ae7411c12d2a1d75f302f1123`.

Local evidence under `output/validation/`:
`strict-gap-{full,default,tex}-build.log`, `strict-gap-{all,new}-axioms.lean`,
`strict-gap-all-axioms.log`, `strict-gap-axiom-summary.json`,
`strict-gap-source-audit{,-summary}.json`,
`canonical-separated-leaf-validation.json` and `strict-gap-validation.json`.
The superseded fifteen-report experiment is explicitly labeled baseline.
Rendered QA pages are retained under `output/validation/strict-gap-render/`.

Reproduce the sixteen added reports from `lean/`:

```sh
LEAN_NUM_THREADS=4 lake build Proximity.Concrete.CanonicalRS.BridgeCertificate
cat > /tmp/strict-gap-new-axioms.lean <<'LEAN'
import Proximity.Concrete.CanonicalRS.BridgeCertificate

#print axioms Hcrypt.Proximity.CanonicalRS.BridgeData.separatedJohnsonRadiusCalibration
#print axioms Hcrypt.Proximity.CanonicalRS.BridgeData.separatedJohnsonRadiusCalibration_radii
#print axioms Hcrypt.Proximity.CanonicalRS.BridgeData.separatedJohnsonRadiusCalibration_sourceStrictGap
#print axioms Hcrypt.Proximity.CanonicalRS.BridgeData.separatedJohnsonRadiusCalibration_targetStrictGap
#print axioms Hcrypt.Proximity.CanonicalRS.BridgeData.decisionNearRadiusReal
#print axioms Hcrypt.Proximity.CanonicalRS.BridgeData.decisionNearRadiusReal_nonneg
#print axioms Hcrypt.Proximity.CanonicalRS.BridgeData.decisionNearRadiusReal_lt_farRadius
#print axioms Hcrypt.Proximity.CanonicalRS.BridgeData.decisionNearRadiusReal_lt_johnsonRadiusReal
#print axioms Hcrypt.Proximity.CanonicalRS.BridgeData.RSMetricCertificate.of_separatedJohnsonRSFarSeparation
#print axioms Hcrypt.Proximity.CanonicalRS.BridgeData.RSMetricCertificate.of_separatedJohnsonRSFarSeparation_calibration
#print axioms Hcrypt.Proximity.CanonicalRS.BridgeData.JohnsonRSFarSeparation.toSeparatedRSMetricCertificate
#print axioms Hcrypt.Proximity.CanonicalRS.BridgeData.JohnsonRSFarSeparation.toSeparatedBridge
#print axioms Hcrypt.Proximity.CanonicalRS.BridgeData.JohnsonRSFarSeparation.toSeparatedBridge_radii
#print axioms Hcrypt.Proximity.CanonicalRS.BridgeData.JohnsonRSFarSeparation.toSeparatedGapReduction
#print axioms Hcrypt.Proximity.CanonicalRS.BridgeData.JohnsonRSFarSeparation.toSeparatedGapReduction_map
#print axioms Hcrypt.Proximity.CanonicalRS.BridgeData.JohnsonRSFarSeparation.pullbackSeparatedSolverCorrect
LEAN
lake env lean /tmp/strict-gap-new-axioms.lean
```

## Paper 1 full-observation correspondence — 2026-11-08

The introduction, §2's public-observation account and §5 now distinguish the
accepted exact payload from the full Hodge sample. The decoded payload is the
sample's exact component and has zero harmonic projection. The existing
`BoundHCPObservation` retains the separate full sample with supplied
artifact/snapshot/lifecycle binding; `toObservation` projects that record and
is not an extractor from payload bytes. `BoundObservationAlignment` identifies
the same operative operator/classifier and harmonic message. `hcpDisclosure`
models an optional full-pair release alongside the base artifact/header;
pair equality alone supplies no full-view equality.

The same passages now state the existing visibility result: full genuine
Plucker data for the **operative kernel**, at the fixed ambient inner product,
together with `b`, determine its target. Digest/proof-only profiles remain
separate. These are prose/correspondence corrections using existing objects;
no new mathematical or cryptographic construction is introduced.

A focused Lean probe rechecks **eight existing endpoints**, each using exactly
`propext`, `Classical.choice`, `Quot.sound`. Seven already occur in P280's
839-report consolidated selection; the separate probe does not change that
selection. All **273 Lean source hashes match** the P280 checkpoint, so its
9,292/9,285-job builds remain the applicable source baseline; no repeat full
build is needed for these TeX/Markdown edits.

The revised **100-page** Paper 1 PDF compiles without undefined
references/citations, missing glyphs or overfull boxes. All pages were rendered
and reviewed in contact sheets; the changed passages on pages 4, 11, 40--42
and 49--51 were inspected at higher resolution; the short definition on
page 43 was checked after keeping it together across the page break. The
final wording refinement was rendered again and the reflowed pages rechecked. Eight underfull-box
diagnostics remain, with no visible defect found. The canonical PDF and stable
review copy match byte-for-byte; Paper 3 remains unchanged.
Current Paper 1 SHA-256:
`45796292203a5f58b02b3f41752742b11b7d6031e3213649814b5065a09b7c1f`.
D03's near/far convention remains open and is the next mathematical step.

Local evidence: `output/validation/paper1-observation-{tex-build,axioms}.log`,
`paper1-observation-axiom-summary.json`, `paper1-observation-validation.json`,
and rendered pages under `output/validation/paper1-observation-render/`.

Reproduce the focused correspondence check from `lean/`:

```sh
cat > /tmp/paper1-observation-axioms.lean <<'LEAN'
import TCB.HCPRealization
import Protocol.Storage.PublicView
import TCB.PluckerObservation

#check Hcrypt.TCB.BoundHCPObservation.toObservation
#check Hcrypt.TCB.BoundHCPObservation.decodedExactComponent
#print axioms Hcrypt.TCB.BoundHCPObservation.harmonicProjection_cochainObject
#print axioms Hcrypt.TCB.HCPRealization.BoundObservationAlignment.operativeTarget_eq_message
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_observation
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_eq_iff
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.recoverSubspace_frame
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.recoverHarmonicProjector_frame
#print axioms Hcrypt.TCB.PluckerObservation.recover_eq_operativeHarmonicComponent
#print axioms Hcrypt.TCB.PluckerObservation.operativeHarmonicComponent_eq_of_same_full_shadow
LEAN
lake env lean /tmp/paper1-observation-axioms.lean
```

## Native Hodge retrieval and concrete outer codec — 2026-11-08

The focused [Retrieval facade](../lean/Protocol/Storage/Retrieval.lean) reuses
the original manifest, Hodge presentation/noise, coefficient decoder, recipient
material and bound-HCP rotation. It stays outside `Storage.Core`; the broad
`Protocol.Storage` facade includes it. [Paper 2 §6.7](../papers/paper2/DRAFT.md#67-hash-indexing-private-retrieval-and-native-hodge-queries)
records the construction boundaries. The [source ledger](SOURCE_LEDGER.md)
and [completion checkpoint](PAPER_OUTLINE.md#source-based-completion-checkpoint--2026-11-08)
separate reviewed literature from remaining manuscript/proof work.

| Source | Checked result and retained boundary |
|---|---|
| `Retrieval.HodgeQuery` | Actual H.encrypt columns use original HodgeNoise. Integer server evaluation is exactly an original full encryption observation; exact and coexact openings combine separately. The original coefficient decoder and discrete-CVP comparison apply to that same answer. Correctness is not selector privacy or a public-encryption construction. |
| `Retrieval.ContentAddress` | Actual local hash checks, existing directory membership and downloaded-byte scan give completeness and original-or-collision authentication. Requested digest addresses full opaque ciphertext bytes, not the existing exact-component ContextKey digest. Authenticated directory/root and original availability remain inputs. |
| `Retrieval.Recovery` | A selected finite full-cochain parser feeds original recipient/context/epoch recovery. Native corollaries retain the same BoundHCPObservation and BoundSampleRotation endpoints; correct coefficients or actual colliding bytes follow under original availability/decoding and delivery contracts. No arbitrary real cochain serializer is constructed. |
| `Retrieval.UniformRead` | Fixed public bucket/scope, target-independent request and arbitrary server tape give equal full transcripts, arbitrary observer views, PMF distributions and event masses. Entire bucket is downloaded, with O(N) payload volume. Targeted authorization, errors/retries, network metadata and later public actions require an enlarged view theorem if used. |
| `Retrieval.LinearQueryObstruction` | Under explicit redundancy of all other noise columns, public span exclusion singles out the selected query column. An actual Fin3 axis fixture has varying coexact HodgeNoise and retains the original sample/CVP joins. The additional joint hypothesis neither refutes the fixed-input HCP oracle theorem nor proves universal efficient-retrieval impossibility. |
| `Transfer.PathSignature.Codec` and `canonical_input_subject_eq` | Concrete domain-prefixed credential/message byte framing has an actual parser, exact roundtrip/reencoding, injectivity and malformed-input rejection. The canonical outer encoding reflects the original key/full-message input. Typed owner packet, full-ciphertext and supported-witness codecs, credential setup/proof algorithms and message-bound knowledge/unforgeability remain open. |

### Retrieval and codec validation

Expanded union/default builds pass **9,292 / 9,285 jobs**; focused retrieval
and transfer facades pass **3,490**. The final codec/native-query check passes
**3,472**. New leaf logs have no local warnings or errors. Pins remain Lean
`v4.35.0` and Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679`.

The consolidated probe passes **839 distinct selected reports**:
**803 standard-only** (627 exact-three, 176 subsets) and **36 existing-native**.
All **89 additions are standard-only** (58 exact-three, 31 subsets/axiom-free),
and all **750 preceding dependency sets are unchanged**. No selected
`sorryAx` or cited-bound dependency occurs. This audit includes definitions
and interface joins as well as theorems; it is not a count of 839 research results.

| Added selected group | Reports |
|---|---:|
| Concrete outer codec | 14 |
| Content addressing | 22 |
| Whole-bucket transcript and distribution privacy | 14 |
| Conditional joint-query obstruction and actual axis fixture | 19 |
| Native Hodge query, response, decoder and CVP join | 12 |
| Full-ciphertext recipient/original HCP recovery | 7 |
| Canonical original-subject reflection | 1 |

Static coverage: **273 public source modules / 274 Lean files**, no active
holes, local cycles or unresolved imports, and the same seven isolated
cited-bound axioms. All **46** scoped closures exclude legacy `Chain` and
`CitedBounds`. New closure sizes including their entry: codec 49,
ContentAddress 40, UniformRead 39, HodgeQuery 8, Recovery 49,
LinearQueryObstruction 11, Retrieval 54. Storage.Core is unchanged.

Local artifacts under `output/validation/`: `retrieval-{full,default,facades}-build.log`,
`retrieval-native-codec-query-build.log`, `retrieval-{all,new}-axioms.lean`,
`retrieval-all-axioms.log`, `retrieval-axiom-summary.json`,
`retrieval-new-selection.json` and `retrieval-source-audit{,-summary}.json`.
These development logs are outside the public review subset. Paper 1/3 TeX
and canonical/review PDFs are unchanged at this checkpoint; the completion
plan identifies stale prose and the unresolved Paper 1 near/far convention.
This is not final manuscript alignment or a completed cryptographic scheme.

Reproduce the added selected reports from `lean/`:

```sh
LEAN_NUM_THREADS=4 lake build Protocol.Storage.Retrieval Protocol.Transfer
cat > /tmp/retrieval-new-axioms.lean <<'LEAN'
import Protocol.Storage.Retrieval
import Protocol.Transfer

#print axioms Hcrypt.Protocol.Transfer.PathSignature.Codec.domain
#print axioms Hcrypt.Protocol.Transfer.PathSignature.Codec.frame
#print axioms Hcrypt.Protocol.Transfer.PathSignature.Codec.parseFrame
#print axioms Hcrypt.Protocol.Transfer.PathSignature.Codec.encode
#print axioms Hcrypt.Protocol.Transfer.PathSignature.Codec.decode
#print axioms Hcrypt.Protocol.Transfer.PathSignature.Codec.parseFrame_frame
#print axioms Hcrypt.Protocol.Transfer.PathSignature.Codec.decode_encode
#print axioms Hcrypt.Protocol.Transfer.PathSignature.Codec.decode_eq_some_iff
#print axioms Hcrypt.Protocol.Transfer.PathSignature.Codec.encode_injective
#print axioms Hcrypt.Protocol.Transfer.PathSignature.Codec.frame_length
#print axioms Hcrypt.Protocol.Transfer.PathSignature.Codec.encode_length
#print axioms Hcrypt.Protocol.Transfer.PathSignature.Codec.decode_rejects_invalid_tag
#print axioms Hcrypt.Protocol.Transfer.PathSignature.Codec.decode_rejects_truncated_key
#print axioms Hcrypt.Protocol.Transfer.PathSignature.Codec.decode_rejects_wrong_domain
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.readLocal
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.readLocal_eq_some_iff
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.readLocal_members
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.readLocal_none_of_directory_missing
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.readLocal_none_of_bytes_missing
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.readLocal_none_of_wrong_digest
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.readLocal_eq_some_of_matching
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.readLocal_original_or_collision
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.readLocal_eq_original_of_no_collision
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.decodeLocal
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.decodeLocal_eq_some_iff
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.decodeLocal_none_of_read_none
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.decodeLocal_original_or_collision
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.readByDigest
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.readByDigest_sound
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.readByDigest_none_of_unlisted
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.readByDigest_none_of_no_match
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.readByDigest_complete
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.readByDigest_original_or_collision
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.decodeByDigest
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.decodeByDigest_eq_some_iff
#print axioms Hcrypt.Protocol.Storage.Retrieval.ContentAddress.decodeByDigest_original_or_collision
#print axioms Hcrypt.Protocol.Storage.Retrieval.UniformRead.request
#print axioms Hcrypt.Protocol.Storage.Retrieval.UniformRead.honestReply
#print axioms Hcrypt.Protocol.Storage.Retrieval.UniformRead.transcript
#print axioms Hcrypt.Protocol.Storage.Retrieval.UniformRead.run
#print axioms Hcrypt.Protocol.Storage.Retrieval.UniformRead.view
#print axioms Hcrypt.Protocol.Storage.Retrieval.UniformRead.request_eq
#print axioms Hcrypt.Protocol.Storage.Retrieval.UniformRead.transcript_eq
#print axioms Hcrypt.Protocol.Storage.Retrieval.UniformRead.run_public_eq
#print axioms Hcrypt.Protocol.Storage.Retrieval.UniformRead.view_eq
#print axioms Hcrypt.Protocol.Storage.Retrieval.UniformRead.honestReply_eq
#print axioms Hcrypt.Protocol.Storage.Retrieval.UniformRead.honestReply_payloadBytes
#print axioms Hcrypt.Protocol.Storage.Retrieval.UniformRead.distribution
#print axioms Hcrypt.Protocol.Storage.Retrieval.UniformRead.distribution_eq
#print axioms Hcrypt.Protocol.Storage.Retrieval.UniformRead.event_probability_eq
#print axioms Hcrypt.Protocol.Storage.Retrieval.LinearQueryObstruction.EssentialColumn
#print axioms Hcrypt.Protocol.Storage.Retrieval.LinearQueryObstruction.selected_essential
#print axioms Hcrypt.Protocol.Storage.Retrieval.LinearQueryObstruction.essential_iff_selected
#print axioms Hcrypt.Protocol.Storage.Retrieval.LinearQueryObstruction.query_ne_of_selected_ne
#print axioms Hcrypt.Protocol.Storage.Retrieval.LinearQueryObstruction.public_predicate_separates
#print axioms Hcrypt.Protocol.Storage.Retrieval.LinearQueryObstruction.harmonic_essential_iff_selected
#print axioms Hcrypt.Protocol.Storage.Retrieval.LinearQueryObstruction.encrypted_essential_iff_selected
#print axioms Hcrypt.Protocol.Storage.Retrieval.LinearQueryObstruction.AxisExample.coefficients
#print axioms Hcrypt.Protocol.Storage.Retrieval.LinearQueryObstruction.AxisExample.queryNoise
#print axioms Hcrypt.Protocol.Storage.Retrieval.LinearQueryObstruction.AxisExample.queryNoise_value
#print axioms Hcrypt.Protocol.Storage.Retrieval.LinearQueryObstruction.AxisExample.querySample
#print axioms Hcrypt.Protocol.Storage.Retrieval.LinearQueryObstruction.AxisExample.selected_sample_eq_original
#print axioms Hcrypt.Protocol.Storage.Retrieval.LinearQueryObstruction.AxisExample.query
#print axioms Hcrypt.Protocol.Storage.Retrieval.LinearQueryObstruction.AxisExample.query_eq
#print axioms Hcrypt.Protocol.Storage.Retrieval.LinearQueryObstruction.AxisExample.selected_projection
#print axioms Hcrypt.Protocol.Storage.Retrieval.LinearQueryObstruction.AxisExample.others_projection
#print axioms Hcrypt.Protocol.Storage.Retrieval.LinearQueryObstruction.AxisExample.others_redundant
#print axioms Hcrypt.Protocol.Storage.Retrieval.LinearQueryObstruction.AxisExample.selected_is_publicly_identified
#print axioms Hcrypt.Protocol.Storage.Retrieval.LinearQueryObstruction.AxisExample.cvp_solution_iff_message
#print axioms Hcrypt.Protocol.Storage.Retrieval.HodgeQuery.point_zero
#print axioms Hcrypt.Protocol.Storage.Retrieval.HodgeQuery.point_int_mul
#print axioms Hcrypt.Protocol.Storage.Retrieval.HodgeQuery.sample
#print axioms Hcrypt.Protocol.Storage.Retrieval.HodgeQuery.query
#print axioms Hcrypt.Protocol.Storage.Retrieval.HodgeQuery.query_projection
#print axioms Hcrypt.Protocol.Storage.Retrieval.HodgeQuery.answer
#print axioms Hcrypt.Protocol.Storage.Retrieval.HodgeQuery.answerNoise
#print axioms Hcrypt.Protocol.Storage.Retrieval.HodgeQuery.answerNoise_value
#print axioms Hcrypt.Protocol.Storage.Retrieval.HodgeQuery.answerSample
#print axioms Hcrypt.Protocol.Storage.Retrieval.HodgeQuery.answer_eq_observed
#print axioms Hcrypt.Protocol.Storage.Retrieval.HodgeQuery.decode_answer
#print axioms Hcrypt.Protocol.Storage.Retrieval.HodgeQuery.cvp_answer_iff
#print axioms Hcrypt.Protocol.Storage.Retrieval.Recovery.recoverByDigest
#print axioms Hcrypt.Protocol.Storage.Retrieval.Recovery.recoverByDigest_none_of_unlisted
#print axioms Hcrypt.Protocol.Storage.Retrieval.Recovery.recoverByDigest_none_of_scope_ne
#print axioms Hcrypt.Protocol.Storage.Retrieval.Recovery.recoverByDigest_of_original
#print axioms Hcrypt.Protocol.Storage.Retrieval.Recovery.recoverByDigest_correct_or_collision
#print axioms Hcrypt.Protocol.Storage.Retrieval.Recovery.recoverByDigest_rotated_or_collision
#print axioms Hcrypt.Protocol.Storage.Retrieval.Recovery.recoverByDigest_bound_observation_or_collision
#print axioms Hcrypt.Protocol.Transfer.PathSignature.canonical_input_subject_eq
LEAN
lake env lean /tmp/retrieval-new-axioms.lean
```

## Native path transport and finite witness boundary — 2026-11-07

Dated predecessor to the retrieval/codec checkpoint above.

The [native import map](PROTOCOL_PARITY_QUEUE.md#native-path-signature-import-map--2026-11-07)
and [Paper 2 §6.6](../papers/paper2/DRAFT.md#66-reused-path-transport-and-finite-native-witness-boundary)
now connect the existing objects without another fibration, owner registry,
rotation carrier or verifier structure.

| Source | Implemented join and retained hypotheses |
|---|---|
| [Ephemeral.Rotation](../lean/Protocol/Ephemeral/Rotation.lean) | A supplied path-to-PresentedRotation realization defines the original FiberSystem. Harmonic projection commutes with that transport and harmonicity is preserved. `EphemeralRotation.ofPath` retains actual admissibility and selects the same path's rotation; direct and retained-base recovery use that transport. Realization, path identity/composition coherence and arbitrary old-record alignment are not inferred. |
| [TCB.PrimitiveChecks](../lean/TCB/PrimitiveChecks.lean) | `ProofVerifier.asSignatureVerifier` executes the same backend on the selected key/message public input, with a reflexive execution law. No new verification algorithm or soundness assumption is introduced. |
| [Transfer.PathSignature](../lean/Protocol/Transfer/PathSignature.lean) | A partial decoder interprets finite private bytes as the actual base, credential opening and original ephemeral path. Validity requires the selected opening relation and admissibility. The same decoded path yields the original rotation and coefficient recovery. Injective input encoding reflects key/full metadata/Intent; actual checked ownerSignature bytes execute that backend. A separate statement-reflection premise yields finite witness existence or backend false acceptance. |
| [Codec reuse](../lean/Protocol/Evidence/TransferVerifier.lean) | The duplicate injectivity proof delegates to the raw operational codec theorem. Existing public types/constructors are preserved. |

The decoder and credential-opening predicate are supplied profile inputs. This
is neither a total finite encoding of arbitrary real/path data nor a completed
credential scheme. The witness-existence predicate is message-independent;
key/message input reflection alone does not force a backend to use its input.
Concrete authenticated setup, public-input and supported-witness encodings,
actual proving/verifying algorithms, transcript binding, knowledge extraction,
unforgeability and error bounds remain separate implementation/security work.
The existing cochain payload proof and ownership policy keep their meanings.

### Native path validation

Focused checks pass: path transport **3,395 jobs**, primitive wrapper
**3,144**, native leaf **3,470** and public transfer facade **3,479**.
The expanded union passes **9,285 jobs**, and the literal default passes
**9,278 jobs** on the unchanged Lean/Mathlib 4.35 pins. The changed/new sources
have no local warnings or errors.

The fresh seven-facade probe covers **750 distinct selected reports**:
**714 standard-only** (569 exact-three, 145 subsets) and **36 existing-native**.
All **22 additions are standard-only** (14 exact-three, seven axiom-free,
one `propext`-only); all **728 retained dependency sets are unchanged**.
The separate codec-prune audit also retains all nineteen earlier endpoint sets.
No selected `sorryAx` or cited-bound dependency occurs.

| Added selected group | Reports |
|---|---:|
| Same-path fiber transport, harmonic projection and recovery | 9 |
| Existing proof verifier as signature verifier | 2 |
| Finite witness, same decoded rotation and original signature execution | 11 |

Static coverage is **266 public modules / 267 Lean files**. The scan finds no
active holes, local import cycles or unresolved imports and the same seven
isolated cited-bound axioms. All **39** recorded scoped closures exclude
legacy `Chain` and `CitedBounds`; the new native leaf has 66 local modules and
the transfer facade 75. The existing rotation and primitive closures remain
37 and six modules. This validation does not discharge the supplied profile
or cryptographic hypotheses above.

Local artifacts under `output/validation/` are
`native-path-{full,default,facade}-build.log`, `path-signature-build.log`,
`native-path-{all,new}-axioms.lean`, `native-path-all-axioms.log`,
`native-path-axiom-summary.json`, `native-path-source-audit.json`,
`path-transport-{build,axioms}.log`,
`path-proof-primitive-wrapper-{build,axioms}.log` and
`native-codec-reuse-validation.json`.

Reproduce the new endpoints from `lean/`:

```sh
LEAN_NUM_THREADS=4 lake build Protocol.Transfer
cat > /tmp/native-path-new-axioms.lean <<'LEAN'
import Protocol.Transfer

#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.pathFiberSystem
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.pathFiberSystem_transport
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.pathFiberSystem_harmonicProjection
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.pathFiberSystem_preserves_harmonic
#print axioms Hcrypt.Protocol.Ephemeral.EphemeralRotation.ofPath
#print axioms Hcrypt.Protocol.Ephemeral.EphemeralRotation.ofPath_rotation
#print axioms Hcrypt.Protocol.Ephemeral.EphemeralRotation.ofPath_rotateObserved
#print axioms Hcrypt.Protocol.Ephemeral.EphemeralRotation.decode_path_transport
#print axioms Hcrypt.Protocol.Ephemeral.EphemeralRotation.recover_path_transport
#print axioms Hcrypt.TCB.PrimitiveChecks.ProofVerifier.asSignatureVerifier
#print axioms Hcrypt.TCB.PrimitiveChecks.ProofVerifier.asSignatureVerifier_verify
#print axioms Hcrypt.Protocol.Transfer.PathSignature.WitnessRelation
#print axioms Hcrypt.Protocol.Transfer.PathSignature.witnessRelation_iff_of_decode
#print axioms Hcrypt.Protocol.Transfer.PathSignature.witnessRelation_credential
#print axioms Hcrypt.Protocol.Transfer.PathSignature.witnessRelation_class
#print axioms Hcrypt.Protocol.Transfer.PathSignature.rotationOfWitness
#print axioms Hcrypt.Protocol.Transfer.PathSignature.rotationOfWitness_transport
#print axioms Hcrypt.Protocol.Transfer.PathSignature.rotationOfWitness_recovery
#print axioms Hcrypt.Protocol.Transfer.PathSignature.input_subject_eq
#print axioms Hcrypt.Protocol.Transfer.PathSignature.checker_verify
#print axioms Hcrypt.Protocol.Transfer.PathSignature.verified_witness_or_falseAccept
#print axioms Hcrypt.Protocol.Transfer.PathSignature.checked_signature_verified
LEAN
LEAN_NUM_THREADS=4 lake env lean /tmp/native-path-new-axioms.lean
```

<a id="current-owner-signing-reuse-and-issuance--2026-11-07"></a>

## Owner-signing reuse and issuance baseline — 2026-11-07

The [inventory](PROTOCOL_PARITY_QUEUE.md#existing-objects-reused-for-owner-signing--2026-11-07)
traces the existing catalog, complete intent/metadata, codec, key map, history
and release carrier, while retaining public identity/context handles, logical
signatures, validator objects, geometric rotation and wallet containers in
their proper roles. [Paper 2 §6.5](../papers/paper2/DRAFT.md#65-full-intent-signing-and-authorized-issuance-from-existing-objects)
records the positive wiring and its fixed-policy boundary.

| Source | Checked statement and boundary |
|---|---|
| [Signing](../lean/Protocol/Transfer/Signing.lean) | Existing packet skeleton with actual metadata/Intent and empty signature/proof fields, prefixed with literal owner-domain bytes. The supplied codec roundtrip implies full metadata/Intent reflection. Owner/spectral messages differ as bytes; no signature-security theorem or concrete serializer is inferred. |
| [Issuance](../lean/Protocol/Transfer/Issuance.lean) | Actual issued metadata/Intent/signature and authorization for the signer inside that Intent. Exact typed-query mapping plus outside-owner-domain foreign batch constructs the existing history. Lookup recovers the same actual authorization without key injectivity; Covers retains actual signature equality separately. |
| [Authorization](../lean/Protocol/Transfer/Authorization.lean) | Existing backend/keyFor and signing bytes construct raw verification with profile agreement `rfl`. Original context/Intent/policy and same-packet candidate remain. This fixed-policy covered history excludes queried-unauthorized targets, gives zero mass, and reduces the same-PMF bound to four errors with supplied-budget composition. |
| [PublicView](../lean/Protocol/Transfer/PublicView.lean) | The existing released-value carrier now projects raw checks; exact publicView delegates to it. A matching new-checker packet with independent authorization yields an actual issue and coverage of its exact metadata/Intent/signature, plus backend verification on that subject. |

Every owner-domain query in this history must be covered under the same actual
authorization relation. Matching policy identifiers do not equate predicates;
revoked or unknown owner-domain signatures cannot be relabeled foreign.
Coverage of arbitrary auxiliary data, actual secret signing/key registration,
chronological or adaptive oracle execution, concrete codec/Rust refinement,
revocation, numeric primitive estimates and privacy remain separate. The
proof does not reinterpret worker signatures or infer authorization from
Boolean acceptance alone. The public identity encoding mismatch has a fixed
public fixture in local `output/validation/signing-identity-comparison.json`.

### Owner-signing validation

The signing subject passes its 3,406-job focused build and 19 standard-only
reports (ten axiom-free, nine `propext`-only). Issuance passes 3,408 jobs and
23 standard-only reports (eleven axiom-free, twelve proper subsets). The
constructed authorization target passes 3,463 jobs, including all coverage,
zero-mass and four-term endpoints. These source modules have no local warnings
or errors. The complete facade passes **3,472 jobs**; the expanded union
passes **9,284 jobs** and literal default passes **9,277 jobs** on the same
Lean/Mathlib 4.35 pins.

The fresh seven-facade probe covers **728 distinct selected reports**:
**692 standard-only** (555 exact-three, 137 subsets) and **36 existing-native**.
All **61 additions are standard-only** (18 exact-three, 22 axiom-free,
21 proper nonempty subsets), and all 667 preceding dependency sets are unchanged.
No selected cited-bound axiom or `sorryAx` occurs. These reports do not discharge
codec, key setup, history provenance or primitive-security assumptions.

| Added selected group | Reports |
|---|---:|
| Existing full signing subject and domain separation | 19 |
| Typed authorized issuance, lookup and exact coverage | 23 |
| Constructed checker, same-object joins and four-error composition | 18 |
| Reused raw released-view projection | 1 |

Static coverage is **265 public modules / 266 Lean files**, with no active
holes, local import cycles or unresolved imports and the same seven isolated
cited-bound axioms. All **38** recorded focused closures exclude legacy `Chain`
and `CitedBounds`. New closure sizes are Signing 48, Issuance 50, Authorization
59; the transfer facade has 68 local modules.

Local artifacts under `output/validation/` are
`owner-signing-{full,default,profile}-build.log`,
`owner-signing-{all,new}-axioms.lean`, `owner-signing-all-axioms.log`,
`owner-signing-axiom-summary.json`, `owner-signing-source-audit.json`,
`signing-message-{build,axioms}.log`, `issuance-{build,axioms}.log` and
`authorization-wiring-build.log`. The recovered native path-space plan is
recorded in the [plan-to-primitive table](PROTOCOL_PARITY_QUEUE.md#recovered-native-authentication-plan-and-existing-primitive-layer--2026-11-07);
this generic wiring selects no Ed25519 owner scheme or central credential issuer.

Reproduce the added public endpoints from `lean/`:

```sh
LEAN_NUM_THREADS=4 lake build Protocol.Transfer
cat > /tmp/owner-signing-new-axioms.lean <<'LEAN'
import Protocol.Transfer

#print axioms Hcrypt.Protocol.Transfer.Signing.domain
#print axioms Hcrypt.Protocol.Transfer.Signing.spectralDomain
#print axioms Hcrypt.Protocol.Transfer.Signing.skeleton
#print axioms Hcrypt.Protocol.Transfer.Signing.message
#print axioms Hcrypt.Protocol.Transfer.Signing.InDomain
#print axioms Hcrypt.Protocol.Transfer.Signing.skeleton_metadata
#print axioms Hcrypt.Protocol.Transfer.Signing.skeleton_intent
#print axioms Hcrypt.Protocol.Transfer.Signing.skeleton_ownerSignature
#print axioms Hcrypt.Protocol.Transfer.Signing.skeleton_proofBytes
#print axioms Hcrypt.Protocol.Transfer.Signing.message_eq_iff
#print axioms Hcrypt.Protocol.Transfer.Signing.message_metadata_eq
#print axioms Hcrypt.Protocol.Transfer.Signing.message_intent_eq
#print axioms Hcrypt.Protocol.Transfer.Signing.message_injective
#print axioms Hcrypt.Protocol.Transfer.Signing.message_ne_of_metadata_ne
#print axioms Hcrypt.Protocol.Transfer.Signing.message_ne_of_intent_ne
#print axioms Hcrypt.Protocol.Transfer.Signing.message_inDomain
#print axioms Hcrypt.Protocol.Transfer.Signing.domain_append_ne_spectralDomain_append
#print axioms Hcrypt.Protocol.Transfer.Signing.not_inDomain_spectralMessage
#print axioms Hcrypt.Protocol.Transfer.Signing.message_ne_spectralMessage
#print axioms Hcrypt.Protocol.Transfer.Issuance.Issued
#print axioms Hcrypt.Protocol.Transfer.Issuance.Issued.query
#print axioms Hcrypt.Protocol.Transfer.Issuance.Issued.query_key
#print axioms Hcrypt.Protocol.Transfer.Issuance.Issued.query_message
#print axioms Hcrypt.Protocol.Transfer.Issuance.typedQueries
#print axioms Hcrypt.Protocol.Transfer.Issuance.mem_typedQueries_iff
#print axioms Hcrypt.Protocol.Transfer.Issuance.typedQuery_mem
#print axioms Hcrypt.Protocol.Transfer.Issuance.typedQueries_append
#print axioms Hcrypt.Protocol.Transfer.Issuance.history
#print axioms Hcrypt.Protocol.Transfer.Issuance.history_queries
#print axioms Hcrypt.Protocol.Transfer.Issuance.history_compromised
#print axioms Hcrypt.Protocol.Transfer.Issuance.queried_iff
#print axioms Hcrypt.Protocol.Transfer.Issuance.issued_queried
#print axioms Hcrypt.Protocol.Transfer.Issuance.queried_issued
#print axioms Hcrypt.Protocol.Transfer.Issuance.queried_authorized
#print axioms Hcrypt.Protocol.Transfer.Issuance.Covers
#print axioms Hcrypt.Protocol.Transfer.Issuance.covers_record
#print axioms Hcrypt.Protocol.Transfer.Issuance.covers_cons
#print axioms Hcrypt.Protocol.Transfer.Issuance.Covers.authorization
#print axioms Hcrypt.Protocol.Transfer.Issuance.Covers.queried
#print axioms Hcrypt.Protocol.Transfer.Issuance.Covers.append_left
#print axioms Hcrypt.Protocol.Transfer.Issuance.Covers.append_right
#print axioms Hcrypt.Protocol.Transfer.Issuance.queried_append
#print axioms Hcrypt.Protocol.Transfer.Authorization.checker
#print axioms Hcrypt.Protocol.Transfer.Authorization.configure
#print axioms Hcrypt.Protocol.Transfer.Authorization.configure_context
#print axioms Hcrypt.Protocol.Transfer.Authorization.configure_intent
#print axioms Hcrypt.Protocol.Transfer.Authorization.configure_policy
#print axioms Hcrypt.Protocol.Transfer.Authorization.configure_candidate
#print axioms Hcrypt.Protocol.Transfer.Authorization.signatureProfile
#print axioms Hcrypt.Protocol.Transfer.Authorization.payloadProfile
#print axioms Hcrypt.Protocol.Transfer.Authorization.not_queriedUnauthorized
#print axioms Hcrypt.Protocol.Transfer.Authorization.issueOfChecked
#print axioms Hcrypt.Protocol.Transfer.Authorization.issueOfChecked_verified
#print axioms Hcrypt.Protocol.Transfer.Authorization.issueOfChecked_covers
#print axioms Hcrypt.Protocol.Transfer.Authorization.issueOfChecked_covers_view
#print axioms Hcrypt.Protocol.Transfer.Authorization.experiment
#print axioms Hcrypt.Protocol.Transfer.Authorization.experiment_attempt
#print axioms Hcrypt.Protocol.Transfer.Authorization.queriedUnauthorizedProbability_eq_zero
#print axioms Hcrypt.Protocol.Transfer.Authorization.acceptedInvalidProbability_le
#print axioms Hcrypt.Protocol.Transfer.Authorization.acceptedInvalidProbability_le_of_bounds
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ofOperational
LEAN
LEAN_NUM_THREADS=4 lake env lean /tmp/owner-signing-new-axioms.lean
```

The full 728-report probe retains the preceding seven facade imports and adds
these 61 names. Earlier entries below preserve their milestone evidence.

## Current primitive and TCB comparison — 2026-11-07

The actual-runtime comparison and original-object joins are recorded in
[Paper 2 §6.4](../papers/paper2/DRAFT.md#64-actual-primitives-and-the-trusted-computing-boundary)
and the [protocol queue](PROTOCOL_PARITY_QUEUE.md#actual-primitive-comparison-and-tcb-joins--2026-11-07).
Existing worker spectral signatures and sampled matrix verification do not
instantiate owner-intent authorization or snapshot-bound decoded-cochain
acceptance. Concrete primitive error estimates therefore remain open.

| Source | Checked statement and boundary |
|---|---|
| [TCB.PrimitiveChecks](../lean/TCB/PrimitiveChecks.lean) | Actual byte-signature/proof algorithms, byte-indexed backend statement, finite query history and compromised-key predicate. Verified signatures split into fresh forgery, compromise or queried message; successful proof verification does not assert statement truth. No soundness, ZK or numerical estimate is built in. |
| [Transfer.Primitives](../lean/Protocol/Transfer/Primitives.lean) | Explicit owner/key/message/history and proof-input/check-agreement equations preserve the actual parsed packet, exact intent/metadata and original interpretation. Accepted-invalid implies fresh forgery, compromise, queried-unauthorized message, false backend proof statement or backend/original-context mismatch. The same PMF gives the five-term bound and supplied-budget corollary, without independence. |
| [Sheaf.GraphCommitment](../lean/Sheaf/GraphCommitment.lean) | Actual ordered incidence differences and canonical modular residues form the existing full `CochainCommitmentData`. Global stalk translation preserves payload and all deterministic observations while changing the designated message. At modulus 12289, path-three openings `[3,5,9]` and `[10,12,16]` both give `[2,4]`; both payloads are well formed. This is an ordinary-incidence obstruction, separate from private restrictions, harmonic blinding and authenticated C¹ payload binding. |
| Legacy TCB/ZKP carriers | Comment-only clarification: proof/observation/envelope acceptance contains supplied statement truth and feature assumptions. No code/API token or semantic definition changes. The data-indexed primitive implication must be established separately. |

Primitive-game instantiation requires correct secret-key setup/registration and
history covering honest signatures already present in the release or auxiliary
input. The recorded history is not an adaptive oracle execution. The backend
proof statement needs a finite-encoding/arithmetization comparison to the
original trusted context, not matching names. No global digest injectivity,
actual SNARK/ZK implementation, primitive error estimate, runtime refinement,
external-history authentication or finality is proved by these interfaces.

The current Rust comparison identifies public-seed bootstrap keys, spectral
rather than owner-intent messages, signature-entry counting, permissive optional
parsing, a sampled-matrix statement, unsupported opening-count error labels and
Python/Rust challenge-generator disagreement. Runtime comments and success
diagnostics now describe their actual scope; acceptance/arithmetic algorithms
are unchanged. Fixed public comparisons and source hashes are in local
`output/validation/primitive-runtime-comparison.json`. These are source audits
and an independent generator translation, not native Rust refinement.

### Primitive comparison validation

Focused builds pass for the low-level/legacy TCB batch (3,156 jobs), graph
payload (3,140), primitive transfer adapter (3,460) and combined transfer/sheaf/
TCB facade (3,779). Added modules have no local warnings/errors; upstream
warnings are replayed separately. The fresh seven-facade probe passes
**667 distinct selected reports**: **631 standard-only** (537 exactly the usual
three and 94 subsets), plus **36 retaining existing native arithmetic
certificates**. All **62 additions are standard-only**: 29 exact-three,
11 axiom-free and 22 proper nonempty subsets. All 605 preceding dependency
sets match exactly. No selected report uses a cited-bound axiom or `sorryAx`.
These reports do not discharge explicit primitive/refinement assumptions.

| Added selected group | Reports |
|---|---:|
| Byte-level TCB records and check classification | 9 |
| Original-transfer primitive/error composition | 24 |
| Ordered graph and actual modular payload ambiguity | 29 |

The current static audit covers **262 source modules / 263 Lean files**,
without active holes, unresolved imports or cycles and with the same seven
isolated cited-bound axioms. All **35** recorded focused closures exclude
legacy `Chain` and `CitedBounds`. New closures contain 6 local modules for
`TCB.PrimitiveChecks`, 56 for `Transfer.Primitives`, and 2 for
`Sheaf.GraphCommitment`; the transfer facade contains 65.
The expanded union passes **9,281 jobs** and literal default passes
**9,274 jobs**, on the unchanged Lean/Mathlib 4.35 pins.

Local artifacts under `output/validation/` are `primitive-{full,default}-build.log`,
`primitive-{all,new}-axioms.lean`, `primitive-all-axioms.log`,
`primitive-axiom-summary.json`, `primitive-source-audit.json`,
`primitive-comment-scope-audit.json` and `primitive-runtime-comparison.json`.
Six legacy Lean bodies are unchanged after comment/whitespace normalization;
three Rust files change comments only. The geodesic source additionally changes
two success diagnostics and removes their opening-count display arguments;
acceptance/arithmetic tokens are unchanged. Runtime behavior is not formally
verified by that source audit.

Reproduce the added proof/dependency endpoints from `lean/`:

```sh
LEAN_NUM_THREADS=4 lake build Protocol.Transfer Sheaf TCB
cat > /tmp/primitive-new-axioms.lean <<'LEAN'
import TCB.PrimitiveChecks
import Protocol.Transfer.Primitives
import Sheaf.GraphCommitment

#print axioms Hcrypt.TCB.PrimitiveChecks.Bytes
#print axioms Hcrypt.TCB.PrimitiveChecks.SignatureVerifier
#print axioms Hcrypt.TCB.PrimitiveChecks.SignatureHistory
#print axioms Hcrypt.TCB.PrimitiveChecks.SignatureHistory.Queried
#print axioms Hcrypt.TCB.PrimitiveChecks.SignatureHistory.Forgery
#print axioms Hcrypt.TCB.PrimitiveChecks.SignatureHistory.verified_cases
#print axioms Hcrypt.TCB.PrimitiveChecks.ProofVerifier
#print axioms Hcrypt.TCB.PrimitiveChecks.ProofVerifier.FalseAccept
#print axioms Hcrypt.TCB.PrimitiveChecks.ProofVerifier.verified_cases
#print axioms Hcrypt.Protocol.Transfer.Primitives.SignatureProfile
#print axioms Hcrypt.Protocol.Transfer.Primitives.PayloadProfile
#print axioms Hcrypt.Protocol.Transfer.Primitives.ParsedFor
#print axioms Hcrypt.Protocol.Transfer.Primitives.Forgery
#print axioms Hcrypt.Protocol.Transfer.Primitives.CompromisedKey
#print axioms Hcrypt.Protocol.Transfer.Primitives.QueriedUnauthorized
#print axioms Hcrypt.Protocol.Transfer.Primitives.ProofFalseAccept
#print axioms Hcrypt.Protocol.Transfer.Primitives.StatementMismatch
#print axioms Hcrypt.Protocol.Transfer.Primitives.authorizationFailure_implies_cases
#print axioms Hcrypt.Protocol.Transfer.Primitives.payloadFailure_implies_cases
#print axioms Hcrypt.Protocol.Transfer.Primitives.acceptedInvalid_implies_cases
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.forgeryEvent
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.compromisedKeyEvent
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.queriedUnauthorizedEvent
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.proofFalseAcceptEvent
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.statementMismatchEvent
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.forgeryProbability
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.compromisedKeyProbability
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.queriedUnauthorizedProbability
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.proofFalseAcceptProbability
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.statementMismatchProbability
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.acceptedInvalidEvent_subset_cases
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.acceptedInvalidProbability_le
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.acceptedInvalidProbability_le_of_bounds
#print axioms Hcrypt.Sheaf.GraphCommitment.Layout
#print axioms Hcrypt.Sheaf.GraphCommitment.Assignment
#print axioms Hcrypt.Sheaf.GraphCommitment.edgeCoordinates
#print axioms Hcrypt.Sheaf.GraphCommitment.translate
#print axioms Hcrypt.Sheaf.GraphCommitment.edgeCoordinates_length
#print axioms Hcrypt.Sheaf.GraphCommitment.edgeCoordinates_translate
#print axioms Hcrypt.Sheaf.GraphCommitment.translate_coordinate_ne
#print axioms Hcrypt.Sheaf.GraphCommitment.observe_translate
#print axioms Hcrypt.Sheaf.GraphCommitment.alternative_observed_opening
#print axioms Hcrypt.Sheaf.GraphCommitment.not_injective_observe
#print axioms Hcrypt.Sheaf.GraphCommitment.payload
#print axioms Hcrypt.Sheaf.GraphCommitment.payload_edgeCountMatches
#print axioms Hcrypt.Sheaf.GraphCommitment.payload_wellFormed
#print axioms Hcrypt.Sheaf.GraphCommitment.payload_translate
#print axioms Hcrypt.Sheaf.GraphCommitment.encoded_payload_translate
#print axioms Hcrypt.Sheaf.GraphCommitment.alternative_payload_opening
#print axioms Hcrypt.Sheaf.GraphCommitment.not_messageBinding
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.layout
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.original
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.shifted
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.shifted_values
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.original_edges
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.shifted_edges
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.messages_differ
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.payload_collision
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.original_payload_edges
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.original_payload_wellFormed
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.shifted_payload_wellFormed
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.encoded_collision
LEAN
LEAN_NUM_THREADS=4 lake env lean /tmp/primitive-new-axioms.lean
```

The consolidated 667-report probe retains the same seven facade imports as
the preceding integrity milestone and appends these 62 names. Earlier dated
entries below retain their milestone counts and source snapshots.

## Current one-shot integrity — 2026-11-06

The conditional Paper 2 transition now has a soundness-free operational layer
and an explicit sampled integrity experiment. The raw algorithms do not assume
that verification implies semantic authorization or payload acceptance. This
avoids proving an error bound in a model that already excludes every error.
The exact interfaces retain their universal contracts and project to the same
checker, original context, policy and parsed candidate.

| Source | Checked statement and boundary |
|---|---|
| [TransferCheck](../lean/Protocol/Evidence/TransferCheck.lean) | Actual canonical parser, metadata/intent equality and signature/proof Boolean checks without primitive soundness. Exact [TransferVerifier](../lean/Protocol/Evidence/TransferVerifier.lean) projections run definitionally the same check and retain the same packet. |
| [Operational](../lean/Protocol/Transfer/Operational.lean) | Same original input, owned-resource policy and staged proposal. Local authorization and original-context acceptance derive validity. Actual Boolean acceptance plus invalidity of the actually parsed candidate implies authorization false acceptance or exact-payload false acceptance under that trusted interpretation. |
| [PublicView](../lean/Protocol/Transfer/PublicView.lean) | Actual checked packet bytes, typed packet, complete proposal and original input-manifest base/root/directory. Canonical-byte and original-object joins are proved. Exposed resource/signer IDs and metadata distinguish records directly; this release is not the whole network transcript. |
| [Security](../lean/Protocol/Transfer/Security.lean) | Explicit view, auxiliary input, PMF tape and adversary determine the same attempt. Event inclusion gives `Pr[AcceptedInvalid] ≤ Pr[AuthorizationFailure] + Pr[PayloadFailure]`; supplied bounds compose without independence. Support-local good events give zero error. The exact-config specialization gives ideal zero only under its universal contracts. `ofCheckedRelease` uses the actual release projection. |

The experiment fixes the trusted setup, including the actual interpretation,
original source state and selected algorithms. Additional setup information,
catalog/prior-state access, openings and access metadata must enter its declared
auxiliary input or an extended view. No primitive error estimate, security
parameter, efficient-adversary class, adaptive signing/proof oracle, corruption
policy, confidentiality, anonymity, authenticated state origin, runtime
refinement, external-history hash authentication, durable application or
finality result is established. Exact
canonical-codec and topology setup contracts remain explicit. The one-entry
manifest supplies no additional proximity radius or six-stage gate theorem.

Paper 2 §6.3 and the shared register H50--H53, D32, P253--P257 and HC45--HC47
record this step. Paper 1/3 sources and reviewed PDFs are unchanged. The entry
below records the preceding owned-resource milestone; its counts and closure
sizes are historical baselines rather than validation of later source.

### One-shot integrity validation

Focused checks pass for the raw/exact packet modules (3,406 jobs), operational
profile (3,408), refactored exact owned/history profile (3,418), actual released
view (3,411), sampled security module (3,458) and complete facade (3,467).
These modules have no local warnings or errors; upstream warnings are replayed
separately. The expanded union passes **9,278 jobs** and literal default passes
**9,271 jobs**, on the unchanged Lean/Mathlib 4.35 pins.

The static scan covers **259 public source modules / 260 Lean files**, with no
active holes, unresolved local imports or cycles and the same seven isolated
cited-bound axioms. All **32** recorded focused closures exclude legacy `Chain`
and `CitedBounds`. Current closure sizes are raw packet checks 47, operational
transfer 50, actual released view 53, sampled security 54, exact owned profile
52, anchored profile 60 and facade 63.

The fresh seven-facade probe passes **605 distinct selected reports**:
**569 standard-only** (508 exactly the usual three, 61 subsets) and
**36 retaining existing native arithmetic certificates**. All **105 additions
are standard-only**: 79 exactly the three, 24 axiom-free and two proper
nonempty subsets. Every preceding 500 dependency set is unchanged. No selected
report uses a cited-bound axiom or `sorryAx`. Dependency reports do not
discharge the explicit setup, primitive-error or runtime assumptions.

| Added selected group | Reports |
|---|---:|
| Soundness-free canonical packet checks | 14 |
| Original operational transfer and failure reduction | 28 |
| Actual released transfer record and distinguishers | 36 |
| Shared-PMF experiment, bounds and ideal specialization | 17 |
| Exact-to-operational algorithm/candidate joins | 10 |

Local artifacts are `security-{full,default}-build.log`,
`security-{all,new}-axioms.lean`, `security-all-axioms.log`,
`security-axiom-summary.json` and `security-source-audit.json` under
`output/validation/`, plus focused build logs. Reproduce the added endpoints:

```sh
LEAN_NUM_THREADS=4 lake build Protocol.Transfer
cat > /tmp/security-new-axioms.lean <<'LEAN'
import Protocol.Transfer

#print axioms Hcrypt.Protocol.Evidence.TransferCheck.Authorization
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.PayloadVerifier
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.PacketCodec
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.PacketCodec.encode_injective
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.check
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.CheckedPacket
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.check_sound
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.CheckedPacket.ofCheck
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.CheckedPacket.check_true
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.CheckedPacket.packet_eq
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.CheckedPacket.signatureVerified_expected
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.CheckedPacket.proofVerified_expected
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.check_true_iff
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.reject_malformed
#print axioms Hcrypt.Protocol.Transfer.Operational.ResourceTransfer
#print axioms Hcrypt.Protocol.Transfer.Operational.ResourceChecks
#print axioms Hcrypt.Protocol.Transfer.Operational.Config
#print axioms Hcrypt.Protocol.Transfer.Operational.Config.manifest
#print axioms Hcrypt.Protocol.Transfer.Operational.Config.cochainRoot
#print axioms Hcrypt.Protocol.Transfer.Operational.Config.draftFor
#print axioms Hcrypt.Protocol.Transfer.Operational.Config.intentFor
#print axioms Hcrypt.Protocol.Transfer.Operational.Config.subject
#print axioms Hcrypt.Protocol.Transfer.Operational.Config.candidateFor
#print axioms Hcrypt.Protocol.Transfer.Operational.Config.policy
#print axioms Hcrypt.Protocol.Transfer.Operational.Prechecks
#print axioms Hcrypt.Protocol.Transfer.Operational.check
#print axioms Hcrypt.Protocol.Transfer.Operational.CheckedTransfer
#print axioms Hcrypt.Protocol.Transfer.Operational.CheckedTransfer.ofCheck
#print axioms Hcrypt.Protocol.Transfer.Operational.CheckedTransfer.check_true
#print axioms Hcrypt.Protocol.Transfer.Operational.CheckedTransfer.candidate
#print axioms Hcrypt.Protocol.Transfer.Operational.CheckedTransfer.candidate_eq
#print axioms Hcrypt.Protocol.Transfer.Operational.CheckedTransfer.successor_eq
#print axioms Hcrypt.Protocol.Transfer.Operational.CheckedTransfer.draft_eq
#print axioms Hcrypt.Protocol.Transfer.Operational.CheckedTransfer.subject_eq
#print axioms Hcrypt.Protocol.Transfer.Operational.CheckedTransfer.valid
#print axioms Hcrypt.Protocol.Transfer.Operational.CheckedTransfer.accepted_update
#print axioms Hcrypt.Protocol.Transfer.Operational.Attempt
#print axioms Hcrypt.Protocol.Transfer.Operational.AcceptedInvalid
#print axioms Hcrypt.Protocol.Transfer.Operational.AuthorizationFailure
#print axioms Hcrypt.Protocol.Transfer.Operational.PayloadFailure
#print axioms Hcrypt.Protocol.Transfer.Operational.acceptedInvalid_implies_failure
#print axioms Hcrypt.Protocol.Transfer.Operational.not_acceptedInvalid_of_good
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ext
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.eq_iff
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.transfer
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.base
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.metadata
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.nullifiers
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ne_of_packetBytes_ne
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ne_of_transfer_ne
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ne_of_input_ne
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ne_of_output_ne
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ne_of_signer_ne
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ne_of_metadata_ne
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ne_of_base_ne
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ne_of_proposal_ne
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ne_of_manifest_ne
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.inputTest
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.inputTest_distinguishes
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_bytes
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_decoded
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_canonical
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_intent
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_transfer
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_metadata
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_base
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_manifest
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_manifest_base
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_manifest_root
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_manifest_directory
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_proposal
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_proposal_computed
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_proposal_draft
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_source_evidence
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_nullifiers
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_eq
#print axioms Hcrypt.Protocol.Transfer.Security.Adversary
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.attempt
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.acceptedInvalidEvent
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.authorizationFailureEvent
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.payloadFailureEvent
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.acceptedInvalidProbability
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.authorizationFailureProbability
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.payloadFailureProbability
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.acceptedInvalidEvent_subset_failures
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.acceptedInvalidProbability_le
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.acceptedInvalidProbability_le_of_bounds
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.acceptedInvalidProbability_eq_zero_of_no_failures
#print axioms Hcrypt.Protocol.Transfer.Security.ofCheckedRelease
#print axioms Hcrypt.Protocol.Transfer.Security.ofCheckedRelease_view
#print axioms Hcrypt.Protocol.Transfer.Security.ofCheckedRelease_attempt
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.Authorization.operational
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.PayloadVerifier.operational
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.PacketCodec.operational
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.check_eq_operational
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.CheckedPacket.operational
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.CheckedPacket.ofOperational
#print axioms Hcrypt.Protocol.Transfer.Owned.Config.operational
#print axioms Hcrypt.Protocol.Transfer.Owned.check_eq_operational
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.operational
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.operational_candidate
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.acceptedInvalidProbability_eq_zero_of_exact_config
LEAN
LEAN_NUM_THREADS=4 lake env lean /tmp/security-new-axioms.lean
```

The full 605-declaration probe retains the earlier seven facade imports:
`ProximityPrize`, `Sheaf`, `Protocol.Storage`, `TCB`, `Protocol.Ephemeral`,
`Protocol.Ephemeral.Examples` and `Protocol.Transfer`. It combines the preceding
500 selected reports with these 105 additions.

## Current owned-resource transition — 2026-11-06

The conditional first Paper 2 transition is now implemented through
[Protocol.Transfer](../lean/Protocol/Transfer.lean). It transfers one whole
owned resource to a distinct absent/unspent identifier of the same asset and
positive catalog value, with the consumed ID as its public nullifier. The
snapshot and epoch stay fixed. Catalog units are not cochain coefficients,
edge sums, Hodge energies or proximity distances; splitting, fee outputs,
mint/burn and anonymous nullifiers are other profiles.

The eight-module surface retains original objects and explicit assumptions:

| Source | Constructed endpoint and boundary |
|---|---|
| [OwnedResource](../lean/Protocol/Ledger/OwnedResource.lean) | Actual owner/asset/value interpretation, unit flow, input-derived nullifier, availability/conservation/update/inventory proofs and spent-input/output rejection. A distinct-owner mechanical fixture transfers value seven using supplied headers, without cryptographic/runtime fixtures. |
| [TransferTranscript](../lean/Protocol/Evidence/TransferTranscript.lean) | Typed signing-domain intent, complete metadata and packet, state-content projection/reconstruction and separate leaf/cochain/manifest/evidence/block preimages. Source historical evidence is explicit in the intent; parent names its tip. Final proposal supplies target tip/evidence. No preimage contains its own digest and no global hash injectivity is assumed. |
| [TransferVerifier](../lean/Protocol/Evidence/TransferVerifier.lean) | Actual parsing/canonical-byte/metadata/intent checks followed by selected signature and payload Boolean verifiers. Soundness indexes the trusted actual interpretation, with equality required for the original context; it does not quantify over arbitrary decoders sharing names. Primitive implementations and their indexed soundness remain inputs. |
| [TransferManifest](../lean/Protocol/Storage/TransferManifest.lean) | Exact seal of one original input payload/leaf digest, prepared before current proof/block data. Hash preimage and public directory retain the same context. This is separate from the six-stage projection manifest; persistence requires a real matching receipt. |
| [TransferEnvelope](../lean/Protocol/Evidence/TransferEnvelope.lean) | Represents already-derived validity and exact joins in the old semantic TCB using the actual candidate/transfer witness and projected-intent existential shadow. It creates no `True` runtime, unit witness or new verifier-soundness result. |
| [Owned](../lean/Protocol/Transfer/Owned.lean) | Structural checks plus actual checked packet derive `Candidate.Valid` and `check_implies_accepted_update`. Parser identity fixes one candidate/successor. Value, input consumption, output creation, conditional unit inventory and replay consequences follow from the actual existing update. Boolean specification is noncomputable, not a Rust refinement. |
| [Anchored](../lean/Protocol/Transfer/Anchored.lean) | Entire packet metadata/signature/proof bytes determine the evidence preimage; exact input manifest enters block construction. Existing evidence/history anchors retain the actual candidate, artifact, context and computed successor. A supplied acceptance quorum must match the complete final proposal. |
| [Facade](../lean/Protocol/Transfer.lean) | Separate focused entry for this profile; the lower-level `Protocol.Core` and standalone coding target retain their scopes. |

The owner authorizes the pre-proof intent, not a recursively self-containing
final header. Hash and codec implementations, metadata-to-catalog/verifier
interpretation, topology authentication, signature/proof security, authentic
prior-state origin, allocation/byte bounds, atomic backend behavior and
consensus finality remain explicit contracts. Receipt or quorum existence is
not manufactured. S2 private rotation can supply a context but does not turn
this fixed-snapshot update into ledger geometry or epoch migration. Papers 1
and 3 and their reviewed PDFs are unchanged; Paper 2 §6.2 carries the account.

### Owned-transfer validation

The expanded union passes **9,274 jobs** and literal default passes **9,267**
on the unchanged Lean/Mathlib 4.35 pins. Focused builds pass for resources
(3,151), transcript (3,404), trusted-interpretation verifier (3,405), input
manifest (3,405), TCB representation (3,409), checked update (3,408) and the
complete facade (3,417). All added modules have no local warning or error;
upstream linter/deprecation warnings are replayed separately.

The fresh public-facade probe passes **500 distinct selected declarations**:
**464 standard-only** (429 exactly the usual three and 35 subsets), plus
**36 retaining existing native arithmetic certificates**. All **145 added
reports are standard-only**: 123 exactly the three, 19 axiom-free and three
proper nonempty subsets. All 355 preceding dependency sets match exactly.
No selected cited-bound axiom or `sorryAx` occurs. These dependency reports
do not discharge the explicit primitive/profile assumptions.

| Added selected group | Reports |
|---|---:|
| Owned-resource semantics and mechanical fixture | 32 |
| Typed transcript/preimage/proposal construction | 34 |
| Operational codec/signature/trusted-decoder checks | 13 |
| Original input manifest and receipt consequence | 12 |
| Existing TCB/evidence representation | 12 |
| Checked candidate/update and determinism | 25 |
| Exact roots, history and optional quorum | 17 |

The static scan covers **255 public source modules / 256 Lean files** including
Lake configuration, with no active holes, unresolved imports or cycles and
the same seven isolated cited-bound axioms. All **28** recorded focused
closures exclude legacy `Chain` and `CitedBounds`. New closure sizes are
resources 13, transcript 46, verifier 47, manifest 47, envelope 51, checked
transfer 50, anchored transfer 58 and facade 59. The preceding twenty closures
are unchanged.

Local artifacts under `output/validation/` are
`transfer-{full,default}-build.log`, `transfer-{all,new}-axioms.lean`,
`transfer-all-axioms.log`, `transfer-axiom-summary.json` and
`transfer-source-audit.json`, plus the module-specific focused logs.
Reproduce the added public entry/probe from `lean/`:

```sh
LEAN_NUM_THREADS=4 lake build
LEAN_NUM_THREADS=4 lake build Protocol.Transfer Protocol.Core \
  Protocol.Ledger.Examples Protocol.Ledger.EvidenceExamples \
  Protocol.Storage.Core Protocol.Storage.AnchorExamples \
  Protocol.Storage.CanonicalThreeLevel Protocol.Storage.CanonicalCalibration \
  Protocol.Ephemeral.Examples Protocol.Ephemeral.HCP
cat > /tmp/transfer-new-axioms.lean <<'LEAN'
import Protocol.Transfer

#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Catalog
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Transfer
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.values
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.value_single
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Transfer.flow
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Transfer.action
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Transfer.nullifiers_nonempty
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Transfer.nullifiers_nodup
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.InventoryInvariant
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.enabled
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.conserves
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.fresh
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.flow_input
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.flow_output
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.flow_other
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.after_input
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.after_output
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.after_other
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.preserves_inventory
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.input_spent_after
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.reused_input_rejected
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.reused_output_rejected
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Fixture.catalog
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Fixture.transfer
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Fixture.before
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Fixture.checks
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Fixture.inventory
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Fixture.candidate
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Fixture.after_marking
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Fixture.before_value
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Fixture.after_value
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.StateContent
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.StateContent.ofState
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.StateContent.restore
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.StateContent.reconstruct
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.StateContent.ofState_restore
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.StateContent.afterFor
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.StateContent.ofState_after
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ProposalDraft
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ProposalDraft.ofProposal
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ProposalDraft.complete
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ProposalDraft.reconstruct
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ProposalDraft.ofProposal_complete
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.Intent
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ProofMetadata
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ProofMetadata.ext
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ProofMetadata.eq_iff
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ProofPacket
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ManifestPreimage
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ManifestPreimage.ofView
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ManifestPreimage.toView
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ManifestPreimage.reconstruct
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.BlockPreimage
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.blockPreimage
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.proposal
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.proposal_draft
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.proposal_evidenceRoot
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.proposal_blockDigest
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.proposal_parentDigest
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.proposal_beforeStateRoot
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.proposal_afterStateRoot
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.proposal_snapshotRoot
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.proposal_topologyRoot
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.proposal_cochainRoot
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.Authorization
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.PayloadVerifier
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.PacketCodec
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.PacketCodec.encode_injective
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.check
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.CheckedPacket
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.check_sound
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.CheckedPacket.ofCheck
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.CheckedPacket.check_true
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.CheckedPacket.authorized
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.CheckedPacket.accepted
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.check_true_iff
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.reject_malformed
#print axioms Hcrypt.Protocol.Storage.TransferManifest.inputItem
#print axioms Hcrypt.Protocol.Storage.TransferManifest.preimage
#print axioms Hcrypt.Protocol.Storage.TransferManifest.scheme
#print axioms Hcrypt.Protocol.Storage.TransferManifest.sealed
#print axioms Hcrypt.Protocol.Storage.TransferManifest.sealed_items
#print axioms Hcrypt.Protocol.Storage.TransferManifest.sealed_root
#print axioms Hcrypt.Protocol.Storage.TransferManifest.sealed_publicView
#print axioms Hcrypt.Protocol.Storage.TransferManifest.sealed_publicView_base
#print axioms Hcrypt.Protocol.Storage.TransferManifest.sealed_publicView_root
#print axioms Hcrypt.Protocol.Storage.TransferManifest.sealed_publicView_directory
#print axioms Hcrypt.Protocol.Storage.TransferManifest.sealed_publicView_preimage
#print axioms Hcrypt.Protocol.Storage.TransferManifest.persisted_of_receipt
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.compression
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.compressed
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.proof
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.proof_wellFormed
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.observation
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.envelope
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.toEvidence
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.toEvidence_artifact
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.toEvidence_witness
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.toEvidence_shadow
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.toAcceptedUpdate
#print axioms Hcrypt.Protocol.Transfer.Owned.Config
#print axioms Hcrypt.Protocol.Transfer.Owned.Config.manifest
#print axioms Hcrypt.Protocol.Transfer.Owned.Config.cochainRoot
#print axioms Hcrypt.Protocol.Transfer.Owned.Config.draftFor
#print axioms Hcrypt.Protocol.Transfer.Owned.Config.intentFor
#print axioms Hcrypt.Protocol.Transfer.Owned.Config.subject
#print axioms Hcrypt.Protocol.Transfer.Owned.Config.policy
#print axioms Hcrypt.Protocol.Transfer.Owned.Prechecks
#print axioms Hcrypt.Protocol.Transfer.Owned.check
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.ofCheck
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.check_true
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.candidate
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.candidate_eq
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.successor_eq
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.draft_eq
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.subject_eq
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.valid
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.accepted_update
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.value_preserved
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.input_consumed
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.output_created
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.inventory_preserved
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.replay_rejected
#print axioms Hcrypt.Protocol.Transfer.Owned.check_implies_accepted_update
#print axioms Hcrypt.Protocol.Transfer.Owned.Config.bindings
#print axioms Hcrypt.Protocol.Transfer.Owned.Config.history
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.packet_transfer
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.packet_metadata
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.packet_included
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.source_reconstruct
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.successor_reconstruct
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.before_root_bound
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.after_root_bound
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.transition_bound
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.cochain_included
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.artifact_included
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.derivation
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.evidence
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.anchor
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.anchored_update
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.certified
LEAN
LEAN_NUM_THREADS=2 lake env lean /tmp/transfer-new-axioms.lean
```

## Current recipient recovery and rotation — 2026-11-06

This preceding rotation/recovery milestone is retained as a baseline; the
owned-transfer profile above records the subsequent source and checks.

The bounded rotation profile preserves a declared integer coefficient vector,
not equality of its ambient coordinates. Seven new modules retain the existing
cellular sheaf, integral structure, harmonic-lattice presentation, Hodge sample,
bound HCP observation and storage context objects:

| Module | Constructed endpoint and explicit boundary |
|---|---|
| [CoefficientRecovery](../lean/Sheaf/CoefficientRecovery.lean) | Integer encoding injectivity and a partial classical decoder from the actual observed cochain. It projects with the private Hodge key and returns coefficients exactly on the chosen presented range; no efficient codec or arbitrary CVP solver is supplied. |
| [Integral rotation](../lean/Sheaf/Rotation.lean) | Actual chain-isometry identity/inverse/composition, projector naturality, an explicit integral-one lattice law, derived harmonic-lattice equivalence and actual message/noise/sample transport with roundtrip/composition. Isometry alone proves no integrality or native Hamming preservation. |
| [Actual axis rotation](../lean/HCP/AxisRotation.lean) | Constructs integral coordinate exchange and proves the encoding law for every integer input. Weighted `(1,2)` becomes `(2,1)` and retains coefficient two; the old fixed-input right sample instead decodes to one. |
| [Presented rotation](../lean/Protocol/Ephemeral/Rotation.lean) | Actual integral geometry plus the chosen encoding law proves direct target-key and retained-base/inverse-key recovery of the same plaintext. A decoder/transport equation transfers exact-payload acceptance. The legacy ephemeral path is joined to actual family endpoints and separate rotation data, not used to generate that data. |
| [Scoped delivery](../lean/Protocol/Ephemeral/Delivery.lean) | Original recipient, epoch labels, context identifiers, actual private rotation and envelope index supplied authorization/channel relations. Whole-scope mismatch returns `none`. Matching labels authenticate no caller and prevent no replay; epoch labels still need authenticated state binding. |
| [Original bound-sample join](../lean/Protocol/Ephemeral/HCP.lean) | Actual full-sample transport between existing bound HCP records derives the original payload decoder equation from their existing decoded-exact-component fields. Both recipient routes require actual source message membership in the chosen presented lattice. The constructor retains supplied target artifact/acceptance/binding proofs. |
| [Recipient axis fixture](../lean/Protocol/Ephemeral/Examples.lean) | Instantiates the actual rotation and encoding law and derives coefficient-two recovery through the scoped receipt, retaining original contexts/envelopes and channel proofs as inputs. No dummy hashes or authorization/channel facts are constructed. |

Paper 2 §6.1 states these results and their scope. The base complex is fixed;
fresh generation, authenticated channel implementation, lifecycle/retirement,
atomic storage updates, physical erasure, privacy games and any further
coordinate/metric or topology-change comparisons remain separate obligations.
The decoder is noncomputable. Source/target classifiers may differ in the
bound-sample adapter; no equality of class labels, roots or released views is
inferred there. Papers 1 and 3 and their reviewed PDFs are unchanged.


### Rotation/recovery validation

The expanded union of all fifteen default roots and explicit integration
entries passes **9,266 jobs**; the literal default passes **9,259 jobs** on the
unchanged Lean/Mathlib 4.35 pins. Focused checks pass for the coefficient leaf
(3,335), integral rotation (3,336), actual axis rotation (3,584), presented
rotation (3,395), scoped delivery/recipient fixture (3,611) and original bound
HCP adapter (3,401). Replayed upstream linter/deprecation warnings remain;
these added modules have no local warning or error.

The fresh public-facade probe passes **355 distinct selected declarations**:
**319 standard-only** (306 exactly the three logical axioms and thirteen
subsets), plus **36 retaining existing native arithmetic certificates**.
All **87 added reports are standard-only**: 86 exactly the three and one
axiom-free (`DeliveryScope`). All 268 preceding dependency sets match exactly.
No selected result depends on a cited-bound axiom or `sorryAx`.

| New selected group | Reports |
|---|---:|
| Presented-coefficient recovery | 5 |
| Integral chain/noise/sample transport | 25 |
| Actual same-coefficient axis rotation | 15 |
| Presented rotation, payload law and legacy path endpoint join | 18 |
| Private recipient delivery scope/receipt | 13 |
| Original bound HCP sample/payload migration | 8 |
| Actual recipient axis fixture | 3 |

The static source scan covers **247 public source modules / 248 Lean files**
including Lake configuration, with no active holes, unresolved imports or
local cycles and the same seven isolated cited-bound axioms. All twenty
recorded focused closures exclude `Chain` and `CitedBounds`. The seven added
closures (including each entry) are coefficient recovery 7, integral rotation
8, axis rotation 22, presented rotation 37, delivery 38, bound-HCP rotation 43
and recipient axis fixture 47. All thirteen earlier closures are unchanged.

Local evidence is under `output/validation/`: `rotation-{full,default}-build.log`,
`rotation-{all,new}-axioms.lean`, `rotation-all-axioms.log`,
`rotation-axiom-summary.json` and `rotation-source-audit.json`; focused build
logs retain their module-specific names. These are selected dependency and
source checks, not a claim that channel or primitive assumptions have been
instantiated. No new project axiom or native arithmetic certificate is added.

Reproduce the added checks from `lean/`:

```sh
LEAN_NUM_THREADS=4 lake build
LEAN_NUM_THREADS=4 lake build Protocol.Ephemeral.Examples Protocol.Ephemeral.HCP \
  Protocol.Core Protocol.Ledger.Examples Protocol.Ledger.EvidenceExamples \
  Protocol.Storage.Core Protocol.Storage.AnchorExamples \
  Protocol.Storage.CanonicalThreeLevel Protocol.Storage.CanonicalCalibration
cat > /tmp/rotation-new-axioms.lean <<'LEAN'
import Protocol.Ephemeral
import Protocol.Ephemeral.Examples

#print axioms Hcrypt.Sheaf.CellularSheaf.HarmonicLatticePresentation.point_injective
#print axioms Hcrypt.Sheaf.CellularSheaf.HarmonicLatticePresentation.decodeCoefficients
#print axioms Hcrypt.Sheaf.CellularSheaf.HarmonicLatticePresentation.decodeCoefficients_eq_some_iff
#print axioms Hcrypt.Sheaf.CellularSheaf.HarmonicLatticePresentation.decodeCoefficients_eq_none_iff
#print axioms Hcrypt.Sheaf.CellularSheaf.HarmonicLatticePresentation.decodeCoefficients_encrypt
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.refl
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.symm
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.trans
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.harmonicOneProjection_naturality
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.transportNoise
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.transportNoise_exactComponent
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.transportNoise_coexactComponent
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.transportNoise_value
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.transportNoise_refl
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.transportNoise_symm
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.transportNoise_trans
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.refl
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.symm
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.trans
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.harmonicOne_iff
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.harmonicLatticeEquiv
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.transportSample
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.transportSample_message
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.transportSample_opening
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.transportSample_observed
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.transportSample_projection
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.transportSample_refl
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.transportSample_symm
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.transportSample_trans
#print axioms Hcrypt.HCP.AxisRotation.integralOne_iff
#print axioms Hcrypt.HCP.AxisRotation.integralAxisSwap
#print axioms Hcrypt.HCP.AxisRotation.point_naturality
#print axioms Hcrypt.HCP.AxisRotation.transport_encrypt_eq_encrypt
#print axioms Hcrypt.HCP.AxisRotation.decode_rotated_encrypt
#print axioms Hcrypt.HCP.AxisRotation.rotatedWeightedSample
#print axioms Hcrypt.HCP.AxisRotation.rotatedWeightedSample_observed
#print axioms Hcrypt.HCP.AxisRotation.rotatedWeightedSample_coordinates
#print axioms Hcrypt.HCP.AxisRotation.rotatedWeightedSample_message
#print axioms Hcrypt.HCP.AxisRotation.rotatedWeightedSample_decode
#print axioms Hcrypt.HCP.AxisRotation.rotatedWeightedSample_pullback
#print axioms Hcrypt.HCP.AxisRotation.rotatedWeightedSample_pullback_decode
#print axioms Hcrypt.HCP.AxisRotation.rotatedWeightedSample_coefficient_two
#print axioms Hcrypt.HCP.AxisRotation.fixedWeightedSample_decode_one
#print axioms Hcrypt.HCP.AxisRotation.rotatedWeightedSample_ne_fixedSample
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.rotateObserved
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.recoverWithBase
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.pullback_rotateObserved
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.transport_encrypt
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.decode_rotated_encrypt
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.recoverWithBase_rotated_encrypt
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.recovery_routes_agree
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.refl
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.symm
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.trans
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.rotateObserved_trans
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.rotateObserved_symm
#print axioms Hcrypt.Protocol.Ephemeral.PayloadRotation
#print axioms Hcrypt.Protocol.Ephemeral.PayloadRotation.target_accepted
#print axioms Hcrypt.Protocol.Ephemeral.EphemeralRotation
#print axioms Hcrypt.Protocol.Ephemeral.EphemeralRotation.samePublicFingerprint
#print axioms Hcrypt.Protocol.Ephemeral.EphemeralRotation.recover_rotated_encrypt
#print axioms Hcrypt.Protocol.Ephemeral.DeliveryScope
#print axioms Hcrypt.Protocol.Ephemeral.DeliveryScope.forContexts
#print axioms Hcrypt.Protocol.Ephemeral.DeliveryContract
#print axioms Hcrypt.Protocol.Ephemeral.RecoveryDelivery
#print axioms Hcrypt.Protocol.Ephemeral.RecoveryDelivery.scope
#print axioms Hcrypt.Protocol.Ephemeral.RecoveryDelivery.recoverFor
#print axioms Hcrypt.Protocol.Ephemeral.RecoveryDelivery.recoverFor_rotated_encrypt
#print axioms Hcrypt.Protocol.Ephemeral.RecoveryDelivery.recoverFor_eq_none_of_scope_ne
#print axioms Hcrypt.Protocol.Ephemeral.RecoveryDelivery.recoverFor_wrong_recipient
#print axioms Hcrypt.Protocol.Ephemeral.RecoveryDelivery.recoverFor_wrong_sourceEpoch
#print axioms Hcrypt.Protocol.Ephemeral.RecoveryDelivery.recoverFor_wrong_targetEpoch
#print axioms Hcrypt.Protocol.Ephemeral.RecoveryDelivery.recoverFor_wrong_sourceKey
#print axioms Hcrypt.Protocol.Ephemeral.RecoveryDelivery.recoverFor_wrong_targetKey
#print axioms Hcrypt.Protocol.Ephemeral.BoundSampleRotation
#print axioms Hcrypt.Protocol.Ephemeral.BoundSampleRotation.cochainObject_eq
#print axioms Hcrypt.Protocol.Ephemeral.BoundSampleRotation.payloadRotation
#print axioms Hcrypt.Protocol.Ephemeral.BoundSampleRotation.decode_target
#print axioms Hcrypt.Protocol.Ephemeral.BoundSampleRotation.recover_with_base
#print axioms Hcrypt.Protocol.Ephemeral.bindRotatedSample
#print axioms Hcrypt.Protocol.Ephemeral.bindRotatedSample_artifact
#print axioms Hcrypt.Protocol.Ephemeral.boundSampleRotation_bindRotatedSample
#print axioms Hcrypt.Protocol.Ephemeral.Examples.axisPresentedRotation
#print axioms Hcrypt.Protocol.Ephemeral.Examples.receipt_recovers_weighted_two
#print axioms Hcrypt.Protocol.Ephemeral.Examples.receipt_rejects_other_epoch
LEAN
LEAN_NUM_THREADS=2 lake env lean /tmp/rotation-new-axioms.lean
```

## Current public-observation profile — 2026-11-06

This preceding public-input milestone is retained as a baseline; the recipient
rotation follow-up above records the subsequent source and checks.

The first Paper 2 public-input profile is now implemented in
[PublicView](../lean/Protocol/Storage/PublicView.lean), exported through
`Protocol.Storage.Core`:

- `Context.publicView` releases the same original cochain payload and all six
  derived context-key coordinates. Snapshot/run/parameter substitutions are
  observable; equality requires both the header and original payload.
- `SealedManifest.publicView` retains that base input, the actual sealed root
  and ordered slot/digest directory. The directory preserves the original
  slot order and uniqueness, while omitting dependent checkpoint witnesses.
- `hcpDisclosure` adds the existing `(class,b)` observation from the same
  bound sample. Equality of HCP pairs alone does not imply equality of these
  larger releases. A public class announcement without `b` is the separate
  tuple of the base view and that snapshot's classifier value.
- `TCB.HCPRealization.no_exact_view_decoder_of_same_view` requires only
  pairwise equality of the actual released views and different operative
  targets to exclude one decoder exact on both. It supplies neither equality
  of storage records nor cryptographic hiding. The earlier global
  factorization criterion is retained.

Paper 2 §2.1 fixes the data/access boundary. Canonical bytes, authenticated
opening requests, proof/verifier metadata, released history extensions and
their cryptographic binding remain explicit contracts. No new serializer,
hash implementation, key rotation or privacy experiment is claimed. Papers
1 and 3 and their reviewed PDFs are unchanged in this step.


### Public-observation validation

The expanded union of all fifteen default roots and explicit integration
entries passes **9,259 jobs**; the literal default passes **9,254 jobs** on
the unchanged Lean/Mathlib 4.35 pins. The new leaf's focused build passes
3,396 jobs and the pairwise adapter's focused build passes 3,383 jobs. Replayed
upstream linter/deprecation warnings remain; the added code has no local
warning or error.

A fresh public-facade probe passes **268 distinct selected declarations**:
**232 standard-only** (220 exactly the usual three axioms and twelve subsets),
and **36 retaining existing native arithmetic certificates**. All **33 new
reports** are standard-only: 26 use exactly the three, seven use no axioms.
All 235 preceding dependency sets match exactly. No selected result depends
on a cited-bound axiom or `sorryAx`.

The static scan covers **240 public source modules / 241 Lean files** including
Lake configuration, with no active holes, unresolved imports or local cycles,
and the same seven isolated cited-bound axioms. The new public-view closure
has 38 modules; `Protocol.Storage.Core` now has 80. The other eleven recorded
closures are unchanged. All thirteen exclude `Chain` and `CitedBounds`.
The local artifacts are `public-observation-{full,default}-build.log`,
`public-observation-{all,new}-axioms.lean`, `public-observation-all-axioms.log`,
`public-observation-axiom-summary.json` and
`public-observation-source-audit.json` under `output/validation/`.
These are selected dependency reports, not a security or runtime certificate.

To reproduce the added checks from `lean/`:

```sh
LEAN_NUM_THREADS=4 lake build
LEAN_NUM_THREADS=4 lake build Protocol.Storage.PublicView Protocol.Storage.Core \
  TCB.HCPRealization Protocol.Ledger.Examples Protocol.Ledger.EvidenceExamples \
  Protocol.Storage.AnchorExamples Protocol.Storage.CanonicalThreeLevel \
  Protocol.Storage.CanonicalCalibration HCP.AxisFamily TCB.HCPAxisFamily
cat > /tmp/public-observation-new-axioms.lean <<'LEAN'
import Protocol.Storage
import TCB

#print axioms Hcrypt.Protocol.Storage.PublicPayloadView
#print axioms Hcrypt.Protocol.Storage.PublicPayloadView.ext
#print axioms Hcrypt.Protocol.Storage.PublicPayloadView.eq_iff
#print axioms Hcrypt.Protocol.Storage.PublicPayloadView.ne_of_key_ne
#print axioms Hcrypt.Protocol.Storage.Context.publicView
#print axioms Hcrypt.Protocol.Storage.Context.publicView_eq_iff
#print axioms Hcrypt.Protocol.Storage.Context.publicView_topologyTag_matches
#print axioms Hcrypt.Protocol.Storage.Context.publicView_ne_of_key_ne
#print axioms Hcrypt.Protocol.Storage.Context.publicView_ne_of_snapshot_ne
#print axioms Hcrypt.Protocol.Storage.Context.publicView_ne_of_runId_ne
#print axioms Hcrypt.Protocol.Storage.Context.publicView_ne_of_parameters_ne
#print axioms Hcrypt.Protocol.Storage.PublicManifestView
#print axioms Hcrypt.Protocol.Storage.PublicManifestView.ext
#print axioms Hcrypt.Protocol.Storage.PublicManifestView.eq_iff
#print axioms Hcrypt.Protocol.Storage.SealedManifest.publicView
#print axioms Hcrypt.Protocol.Storage.SealedManifest.publicView_base
#print axioms Hcrypt.Protocol.Storage.SealedManifest.publicView_directory_slots
#print axioms Hcrypt.Protocol.Storage.SealedManifest.publicView_directory_slots_nodup
#print axioms Hcrypt.Protocol.Storage.HCPDisclosure
#print axioms Hcrypt.Protocol.Storage.HCPDisclosure.forget
#print axioms Hcrypt.Protocol.Storage.HCPDisclosure.ext
#print axioms Hcrypt.Protocol.Storage.HCPDisclosure.eq_iff
#print axioms Hcrypt.Protocol.Storage.HCPDisclosure.ne_of_base_ne
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_forget
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_cochain
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_leafDigest
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_snapshotRoot
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_runId
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_observation
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_eq_iff
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_same_observation_distinct_parameters
#print axioms Hcrypt.TCB.HCPRealization.no_exact_view_decoder_of_same_view
LEAN
LEAN_NUM_THREADS=2 lake env lean /tmp/public-observation-new-axioms.lean
```

## Current cellular HCP implementation — 2026-11-06

This preceding construction/validation milestone is retained as a baseline;
the public-observation profile above is its subsequent follow-up.

The five-module follow-up constructs an actual finite integral cellular HCP
family in a proved homological fragment of the typed Helfer interface. It
reuses the existing positive CVP comparison and negative public-recovery/oracle
argument. The full union of all fifteen default roots plus explicit transition,
storage and HCP targets passes **9,258 jobs**; the literal default `lake build`
passes **9,253 jobs**, with `LEAN_NUM_THREADS=4` and unchanged Lean/Mathlib 4.35 pins.

The source scan has **239 public source modules / 240 Lean files** including
Lake configuration. It finds no active proof holes, unresolved local imports
or cycles and the same seven cited-bound axioms. No new project axiom or native
certificate is introduced. The source snapshot is recorded separately from
proof-dependency evidence.

A fresh probe through public facades (`ProximityPrize`, `Sheaf`,
`Protocol.Storage`, `TCB`) passes **235 distinct declarations**:

- **199 standard-only**: 194 exactly the usual three axioms and five subsets.
- **36 retain existing native arithmetic certificates**, all generated names
  containing `_native.native_decide.ax_`.
- **All 96 new reports are standard-only**: 94 exactly the three and two subsets.
- All 139 retained dependency sets match their preceding reports exactly;
  no selected result uses a cited-bound axiom or `sorryAx`.

| New checked group | Reports | Dependency boundary |
|---|---:|---|
| Actual cochain model / homological-test invariance | 17 | Standard-only. |
| Integral cellular axis family / actual spectrum / lattices | 20 | Standard-only. |
| Concrete semantic realization / positive and negative CVP / weighted encoding | 43 | Standard-only; two elementary coefficient facts use subsets. |
| Generic actual-operator / bound-observation / selected-view adapter | 9 | Standard-only; application profile fields remain explicit. |
| Concrete artifact-bound family / actual spectral gate | 7 | Standard-only; no artifact bindings or hashes are manufactured. |

The example with `b=(1,1)` has two distinct nonzero ambient harmonic targets,
each coefficient one in its own lattice basis. The weighted example uses the
existing integer lattice encryptor with coefficients **2 and 1**, at common
`b=(1,2)`, and proves that no exact function of the selected HCP input recovers
both coefficients. Each actual lattice CVP has a unique answer equal to its
operative target. This is a finite exact-recovery obstruction, not an
asymptotic/distributional privacy theorem.

The semantic model is Mathlib's genuine bounded-below real cochain Quillen
model. The selected nonzero-cohomology tests are proved invariant for all typed
interpretations. Full Helfer first-order syntax/fibrational semantics, a bundled
homotopy quotient, an infinite generated representative family, actual full
storage-view hiding and protocol key delivery remain separate work.

The existing observation adapter derives cellular kernel/projector/message and
CVP agreement from actual operator action and classifier alignment. Original
payload/snapshot/hash/proof contracts remain inputs. Its public-view extension
requires an explicit factorization proof; equality of a class label alone does
not establish equality of a richer record. The computed positive spectral gap
one is connected to the actual spectral gate.

Current local import closures (including each entry) are: `ProximityPrize` 33,
`Protocol.Core` 33, `Storage.Core` 79, `Storage.CanonicalRS` 58,
`Storage.CanonicalSystematic` 70, `Storage.CanonicalThreeLevel` 78,
`Storage.CanonicalCalibration` 76; new entries `Helfer.CochainModel` 8,
`Sheaf.HCPAxisFamily` 8, `HCP.AxisFamily` 19, `TCB.HCPRealization` 23 and
`TCB.HCPAxisFamily` 30. All twelve exclude `Chain` and `CitedBounds`.

### Reproduce the new selected checks

From `lean/`, the example and adapters are in the public `TCB` facade:

```sh
LEAN_NUM_THREADS=4 lake build
LEAN_NUM_THREADS=4 lake build HCP.AxisFamily TCB.HCPAxisFamily \
  Protocol.Core Protocol.Ledger.Examples Protocol.Ledger.EvidenceExamples \
  Protocol.Storage.Core Protocol.Storage.Examples Protocol.Storage.AnchorExamples \
  Protocol.Storage.CanonicalRS Protocol.Storage.CanonicalThreeLevel \
  Protocol.Storage.CanonicalCalibration
cat > /tmp/cellular-hcp-new-axioms.lean <<'LEAN'
import TCB

#print axioms Hcrypt.Helfer.CochainModel.boundedContainsZero
#print axioms Hcrypt.Helfer.CochainModel.Data.differential_comp
#print axioms Hcrypt.Helfer.CochainModel.Data.strictlyGE
#print axioms Hcrypt.Helfer.CochainModel.Data.StrictIso.complexIso
#print axioms Hcrypt.Helfer.CochainModel.Data.StrictIso.modelIso
#print axioms Hcrypt.Helfer.CochainModel.module_injective
#print axioms Hcrypt.Helfer.CochainModel.model_isFibrant
#print axioms Hcrypt.Helfer.CochainModel.model_isCofibrant
#print axioms Hcrypt.Helfer.CochainModel.homologyIso
#print axioms Hcrypt.Helfer.CochainModel.closedTestInvariance
#print axioms Hcrypt.Helfer.CochainModel.homotopyEquivalence_of_iso
#print axioms Hcrypt.Helfer.CochainModel.equivalent_of_iso
#print axioms Hcrypt.Helfer.CochainModel.equivalent_refl
#print axioms Hcrypt.Helfer.CochainModel.Data.StrictIso.equivalent
#print axioms Hcrypt.Helfer.CochainModel.ofSheaf
#print axioms Hcrypt.Helfer.CochainModel.strictIso_of_isometricCochainEquiv
#print axioms Hcrypt.Helfer.CochainModel.equivalent_of_isometricCochainEquiv
#print axioms Hcrypt.Sheaf.HCPAxisFamily.delta0_eq_zero
#print axioms Hcrypt.Sheaf.HCPAxisFamily.delta1_adjoint_eq
#print axioms Hcrypt.Sheaf.HCPAxisFamily.degreeOneLaplacian_apply
#print axioms Hcrypt.Sheaf.HCPAxisFamily.harmonic_iff
#print axioms Hcrypt.Sheaf.HCPAxisFamily.standardStalkLattice
#print axioms Hcrypt.Sheaf.HCPAxisFamily.integralStructure
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_observed
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_exactComponent
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_messages_ne
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_noise_orthogonal
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_projection
#print axioms Hcrypt.Sheaf.HCPAxisFamily.laplacianMatrix_mulVec
#print axioms Hcrypt.Sheaf.HCPAxisFamily.laplacianMatrix_eq_diagonal
#print axioms Hcrypt.Sheaf.HCPAxisFamily.axisSwap
#print axioms Hcrypt.Sheaf.HCPAxisFamily.eigenvalue_eq_zero_or_one
#print axioms Hcrypt.Sheaf.HCPAxisFamily.positiveSpectralGap_eq_one
#print axioms Hcrypt.Sheaf.HCPAxisFamily.harmonicLatticePresentation
#print axioms Hcrypt.Sheaf.HCPAxisFamily.harmonicLatticePresentation_point
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_message_eq_point
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_eq_encrypt_one
#print axioms Hcrypt.HCP.AxisFamily.semanticEquivalence
#print axioms Hcrypt.HCP.AxisFamily.theory_zero_eq_one
#print axioms Hcrypt.HCP.AxisFamily.publicProjection_laplacian
#print axioms Hcrypt.HCP.AxisFamily.realization
#print axioms Hcrypt.HCP.AxisFamily.operatorAction
#print axioms Hcrypt.HCP.AxisFamily.matrixHarmonicSubspace_eq
#print axioms Hcrypt.HCP.AxisFamily.operativeHarmonicComponent_eq
#print axioms Hcrypt.HCP.AxisFamily.isometricPresentation
#print axioms Hcrypt.HCP.AxisFamily.fixedCoordinateNonstabilization
#print axioms Hcrypt.HCP.AxisFamily.kernelSeparation
#print axioms Hcrypt.HCP.AxisFamily.same_public_class
#print axioms Hcrypt.HCP.AxisFamily.kernel_ambiguous
#print axioms Hcrypt.HCP.AxisFamily.classifier_nonfaithful
#print axioms Hcrypt.HCP.AxisFamily.no_exact_representative_decoder
#print axioms Hcrypt.HCP.AxisFamily.left_target_eq_message
#print axioms Hcrypt.HCP.AxisFamily.right_target_eq_message
#print axioms Hcrypt.HCP.AxisFamily.same_observation_distinct_targets
#print axioms Hcrypt.HCP.AxisFamily.both_targets_nonzero
#print axioms Hcrypt.HCP.AxisFamily.sample_observation_and_exact_component
#print axioms Hcrypt.HCP.AxisFamily.sample_public_observations_eq
#print axioms Hcrypt.HCP.AxisFamily.shared_observation_distinct_nonzero_targets
#print axioms Hcrypt.HCP.AxisFamily.cvp_solution_iff_message
#print axioms Hcrypt.HCP.AxisFamily.cvp_existsUnique
#print axioms Hcrypt.HCP.AxisFamily.cvp_solution_iff_left_operativeTarget
#print axioms Hcrypt.HCP.AxisFamily.cvp_solution_iff_right_operativeTarget
#print axioms Hcrypt.HCP.AxisFamily.no_exact_public_solver
#print axioms Hcrypt.HCP.AxisFamily.no_sound_and_harmonic_exact_public_solver
#print axioms Hcrypt.HCP.AxisFamily.cvp_oracle_insufficient
#print axioms Hcrypt.HCP.AxisFamily.weightedSample_message
#print axioms Hcrypt.HCP.AxisFamily.weightedOpening_value
#print axioms Hcrypt.HCP.AxisFamily.weightedSample_observed
#print axioms Hcrypt.HCP.AxisFamily.weightedSample_exactComponent
#print axioms Hcrypt.HCP.AxisFamily.weighted_public_observations_eq
#print axioms Hcrypt.HCP.AxisFamily.weighted_coefficients_values
#print axioms Hcrypt.HCP.AxisFamily.weighted_coefficients_ne
#print axioms Hcrypt.HCP.AxisFamily.weightedSample_messages_ne
#print axioms Hcrypt.HCP.AxisFamily.weightedSample_message_ne_zero
#print axioms Hcrypt.HCP.AxisFamily.weighted_target_eq_message
#print axioms Hcrypt.HCP.AxisFamily.weighted_same_observation_distinct_targets
#print axioms Hcrypt.HCP.AxisFamily.weighted_both_targets_nonzero
#print axioms Hcrypt.HCP.AxisFamily.weighted_cvp_solution_iff_operativeTarget
#print axioms Hcrypt.HCP.AxisFamily.weighted_cvp_existsUnique
#print axioms Hcrypt.HCP.AxisFamily.no_exact_encoded_message_decoder
#print axioms Hcrypt.TCB.HCPRealization.CellularOperatorAlignment
#print axioms Hcrypt.TCB.HCPRealization.CellularOperatorAlignment.matrixHarmonicSubspace_eq
#print axioms Hcrypt.TCB.HCPRealization.CellularOperatorAlignment.operativeHarmonicComponent_eq
#print axioms Hcrypt.TCB.HCPRealization.BoundObservationAlignment
#print axioms Hcrypt.TCB.HCPRealization.BoundObservationAlignment.hiddenWitness
#print axioms Hcrypt.TCB.HCPRealization.BoundObservationAlignment.operativeTarget_eq_projection
#print axioms Hcrypt.TCB.HCPRealization.BoundObservationAlignment.operativeTarget_eq_message
#print axioms Hcrypt.TCB.HCPRealization.BoundObservationAlignment.cvp_solution_iff_operativeTarget
#print axioms Hcrypt.TCB.HCPRealization.no_exact_view_solver_of_factorization
#print axioms Hcrypt.TCB.HCPAxisFamily.operatorAlignment
#print axioms Hcrypt.TCB.HCPAxisFamily.actualSpectralGate
#print axioms Hcrypt.TCB.HCPAxisFamily.observationAlignment
#print axioms Hcrypt.TCB.HCPAxisFamily.bindSample
#print axioms Hcrypt.TCB.HCPAxisFamily.bindSample_artifact
#print axioms Hcrypt.TCB.HCPAxisFamily.operativeTarget_eq_original_message
#print axioms Hcrypt.TCB.HCPAxisFamily.cvp_solution_iff_operativeTarget
LEAN
LEAN_NUM_THREADS=2 lake env lean /tmp/cellular-hcp-new-axioms.lean
```

The 139-declaration probe in the preserved native-metric section below supplies
the retained selection. The fresh combined 235-report probe uses the union of
these declarations and the four public facades named above. This follow-up
supersedes the preceding inventory/build snapshot without changing its earlier
record. The final Paper 1 PDF has **99 pages**. Its final TeX pass has no LaTeX
warnings, undefined references/citations, missing glyphs or overfull boxes.
Eight underfull-box diagnostics remain without a visible layout defect. All
99 pages were rendered and visually inspected; pages 21--23, 87 and 94--95
were also checked at higher resolution. Paper 3 is unchanged at 28 pages and
retains its preceding visual review. Both canonical PDFs match their stable
review exports bytewise. The local `cellular-hcp-pdf-qa.json` records the check;
the preceding 97-page Paper 1 export is preserved under
`output/pdf/baselines/2026-11-06-pre-cellular-hcp/`.

- Current Paper 1 SHA-256: `beb20f8c4a67ef4afcd0bfe950cfb444cfaf38b9abba1c3150fa0c2a3930a213`.
- Unchanged Paper 3 SHA-256: `61d7589a75b48bc877c768df0795059220af7fc921ed6f681e8e5b391a8ab9e7`.

## Native-metric baseline — 2026-11-05

The twenty-module mathematics follow-up is complete for the declared native
modular source profile. The full union of all fifteen default roots and the
explicit transition/storage/native-application targets passes **9,253 jobs**;
the literal default `lake build` passes **9,248 jobs**. Both use
`LEAN_NUM_THREADS=4` and the unchanged Lean/Mathlib 4.35 pin.

The current source inventory has **235 Lean files**, including the Lake
configuration, and **234 source modules** with public-module interfaces.
A comment-aware scan finds no active `sorry`/`admit`/`sorryAx`, no unresolved
local imports or cycles, and the same seven explicitly declared cited-bound
axioms. Every Lean file is within 10,000 lines; the largest is
`Hardness.lean`, 1,038 lines. These are source checks, not theorem-dependency
claims.

The **fresh consolidated public-facade probe passes 139 distinct reports**.
It reproduces every individual group exactly: **103 standard-only** (100 use
exactly the usual three axioms; three use a subset), and **36 with existing
native arithmetic certificates**. Every extra dependency in those 36 names
contains `_native.native_decide.ax_`; none is a cited-bound axiom or `sorryAx`.
The arithmetic trust comes from existing concrete modulus/root certificates;
no new `native_decide` certificate or project axiom is introduced by this
follow-up. Explicit theorem/profile assumptions remain part of every result.

After the full runs, final review added two module-introduction qualifiers
only: the constant-one vector in affine-lift spanning and the RS degree bound
at least two in the decoder obstruction. Statements and proofs are unchanged.
The two affected modules pass a focused rebuild (3,338 jobs), and the complete
static source inventory was refreshed for those final bytes.

| Selected group | Reports | Standard-only | Existing native certificates |
|---|---:|---:|---:|
| `plucker-reconstruction` | 8 | 8 | 0 |
| `q08-canonical-lift` | 13 | 13 | 0 |
| `q08-systematic` | 6 | 6 | 0 |
| `q08-modular-coboundary` | 8 | 8 | 0 |
| `q08-zero-direction` | 11 | 11 | 0 |
| `q08-diagonal-mca` | 11 | 11 | 0 |
| `q08-root-generic` | 27 | 27 | 0 |
| `q08-native-chain` | 11 | 11 | 0 |
| `q08-metric-sharpness` | 4 | 4 | 0 |
| `q08-canonical-systematic` | 15 | 0 | 15 |
| `q08-canonical-three-level` | 16 | 0 | 16 |
| `q08-canonical-calibration` | 9 | 4 | 5 |

The results concern distinct claims:

- Full genuine Plucker data reconstruct the subspace and fixed-metric harmonic
  projector; identification with the operative kernel gives mathematical
  target recovery, without a finite-encoding efficiency or digest claim.
- Actual integral cellular coboundary congruence is proved equivalent to RS
  validity. Native cochain, integer-plane and RS distances satisfy
  `d_C ≤ d_P = D_RS ≤ 2d_C`; the near factor two is sharp.
- The original canonical payload has all three native distances `3/4`.
  The canonical mix is good for that diagonal family, whose sole bad challenge
  is `-1`, with exact fraction `1/12289`.
- A capacity-far counterfamily refutes uniform positive far preservation by
  an arbitrary fixed nonzero scalar challenge.
- The separate Euclidean no-wrap comparison is a coarse first-shell theorem.
  Canonical-lift spanning obstructs an unrestricted zero-additive-loss
  Euclidean comparison for a nontrivial linear decoder.
- Raw positive-far contexts are proximity/rejection inputs. Accepted exact
  contexts have zero native distance under the stated decoder contract.
  No nonempty accepted-far gate, full legacy frame-chain instance, new
  commitment security game or consensus finality is constructed.

Current local import closures, including their entry modules:

| Entry | Modules | Boundary |
|---|---:|---|
| `ProximityPrize` | 33 | No `Chain` or `CitedBounds`. |
| `Protocol.Core` | 33 | Same conservative kernel boundary. |
| `Protocol.Storage.Core` | 79 | Generic context/codec/anchor layer. |
| `Protocol.Storage.CanonicalRS` | 58 | Existing optional public-observation adapter. |
| `Protocol.Storage.CanonicalSystematic` | 70 | Explicit no-wrap source profile. |
| `Protocol.Storage.CanonicalThreeLevel` | 78 | Native canonical payload/capacity/challenge results. |
| `Protocol.Storage.CanonicalCalibration` | 76 | Composable far and scaled-near contracts. |

All seven closures exclude `Chain` and `CitedBounds`. Source imports do not
imply that every imported declaration was axiom-audited. The earlier
9,233/9,228/68-result record below is retained as the pre-addition 4.35
baseline, followed by the older 4.24 milestones.

### Native-metric manuscript baseline

Paper 1's 97-page PDF and Paper 3's 28-page PDF both pass their final TeX
runs without undefined references/citations, missing glyphs or overfull boxes.
All 125 pages were rendered and inspected; changed pages received additional
high-resolution review. Underfull-box diagnostics remain (eight and two
respectively), without a visible layout defect. Canonical and stable review
copies match bytewise:

- Paper 1: `40f84530a5b0e95131c71189a9303b3e2ae0005ec4b9bcfead50846f22f6d46f`.
- Paper 3: `61d7589a75b48bc877c768df0795059220af7fc921ed6f681e8e5b391a8ab9e7`.

Paper 1 records full Plucker recovery with its kernel/visibility qualifications;
Paper 3 records the constructed modular profile, native metric theorem,
capacity family and obstruction boundaries. Paper 2's initial manuscript
records shared source and observation contracts, without a TeX/PDF bundle.

### Reproduce the current checks

From `lean/`:

```sh
LEAN_NUM_THREADS=4 lake build
LEAN_NUM_THREADS=4 lake build Protocol.Core Protocol.Ledger.Examples \
  Protocol.Ledger.EvidenceExamples Protocol.Storage.Core \
  Protocol.Storage.Examples Protocol.Storage.AnchorExamples \
  Protocol.Storage.CanonicalRS Protocol.Storage.CanonicalThreeLevel \
  Protocol.Storage.CanonicalCalibration
```

The combined probe imports the public facades used by reviewers, rather than
relying on a private proof-body traversal. Its selected declarations are:

```sh
cat > /tmp/native-metrics-axioms.lean <<'LEAN'
import ProximityPrize
import Sheaf
import Protocol.Storage
import TCB.PluckerObservation

#print axioms Hcrypt.Protocol.Storage.Calibration.decodedDistance_le_norm
#print axioms Hcrypt.Protocol.Storage.Calibration.decodedDistance_le_scaled_pairDistance_of_reflection
#print axioms Hcrypt.Protocol.Storage.Calibration.decodedFar_implies_pairFar_of_reflection
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.calibrationFor
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.calibration_extract_eq_original_pair
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.cochainToPlaneFor
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.evaluationProjectionFor
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.extracted_codeword_of_modular_valid
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.planeNear_of_scaledSourceNear
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.planeToRSFor
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.sourceFar_implies_planeFar
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.sourceFar_implies_rsFar
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.accepted_iff_pairCodeword
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.decodedFar_implies_pairFar
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.exactDistance_eq_harmonicProjection_norm
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.exists_positive_source_payload
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.harmonicOneSubspace_eq_exactOrthogonal
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.informationSet_card
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.model
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.observed_decodedFar_implies_pairFar
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.raw_payload
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.unitPayload_context_pairFar
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.unitPayload_context_sourceDistance_pos
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.unitPayload_noWrap
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.unitPayload_not_exact
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.unitPayload_sourceDistance_pos
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.unitPayload_wellFormed
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.accepted_nativeDistances_zero
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.canonicalMix_ne_neg_one
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_badChallengeFraction
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_badChallenges
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_canonicalMix_good
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_canonicalMix_scalarDistance
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_cochainDistance
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_planeDistance
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_rsPairDistance
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_wellFormed
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.cochainFar_implies_observed_pairFar
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.exists_payload_at_capacity
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.native_distance_comparison
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.not_accepted_of_positive_cochainFar
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.observed_planeDistance_eq_pairDistance
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.observed_planeDistance_eq_publicSourceDistance
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.aligned
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.coordinateCount
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.decode_coordinate
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.decodedFar_implies_pairFar
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.locallyNondegenerate
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.norm_decode_le
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.norm_decode_sq_le
#print axioms Hcrypt.Protocol.Storage.SystematicModel.accepted_of_pairCodeword
#print axioms Hcrypt.Protocol.Storage.SystematicModel.decodedFar_implies_pairFar
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.flatDistance_eq_rsFlatDistance
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.integerPairCode_codeword_iff_modularExact
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.integerPairCode_codeword_iff_reduced
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.integerScalarCode_codeword_iff
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.integerScalarCode_nonempty
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.liftMatching_hamming
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.liftMatching_pair_eq_iff
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.planeDistance_eq_rsDistance
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.reduce_liftMatching
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.reduced_hamming_le
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.scalar_reduction_distance_eq
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.three_native_distance_comparison
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.harmonicProjector_eq_of_publicShadow_eq
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.projectiveFramedSystem_sound
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.projectiveSoundInputs
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.publicShadow_eq_iff_same_point
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.recoverHarmonicProjector_frame
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.recoverSubspace_frame
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.recoverSubspace_zero
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.toLaplacian_eq_of_publicShadow_eq
#print axioms Hcrypt.Sheaf.CellularSheaf.all_linear_decodes_exact_of_canonical_interleaved_rs_lifts
#print axioms Hcrypt.Sheaf.CellularSheaf.all_linear_decodes_exact_of_canonical_rs_lifts
#print axioms Hcrypt.Sheaf.CellularSheaf.exactOneSubspace_eq_top_of_surjective_canonical_rs_decoder
#print axioms Hcrypt.Sheaf.CellularSheaf.linear_decode_exactDistance_eq_zero_of_canonical_interleaved_rs_lifts
#print axioms Hcrypt.Sheaf.CellularSheaf.linear_decode_exactDistance_eq_zero_of_canonical_rs_lifts
#print axioms Hcrypt.Sheaf.CellularSheaf.not_all_canonical_interleaved_rs_lifts_exact_of_nonexact_linear_decode
#print axioms Hcrypt.Sheaf.CellularSheaf.not_all_canonical_rs_lifts_exact_of_nonexact_linear_decode
#print axioms Hcrypt.Sheaf.CellularSheaf.not_uniform_rs_distance_comparison_of_nonexact_linear_decode
#print axioms Hcrypt.Sheaf.SystematicCode.delta0_integralOpening_coordinate
#print axioms Hcrypt.Sheaf.SystematicCode.intCast_integerCoboundary
#print axioms Hcrypt.Sheaf.SystematicCode.integralOpening_head
#print axioms Hcrypt.Sheaf.SystematicCode.integralOpening_tail
#print axioms Hcrypt.Sheaf.SystematicCode.isExact_iff_realCheck_eq_zero
#print axioms Hcrypt.Sheaf.SystematicCode.modularExact_iff_integerCoboundary_residue
#print axioms Hcrypt.Sheaf.SystematicCode.modularExact_iff_vectorCodeword
#print axioms Hcrypt.Sheaf.SystematicCode.modularExact_of_vectorCodeword
#print axioms Hcrypt.Sheaf.SystematicCode.ofWord_isExact_of_vectorCodeword_of_noWrap
#print axioms Hcrypt.Sheaf.SystematicCode.vectorCodeword_of_modularExact
#print axioms Hcrypt.TCB.PluckerObservation.operativeHarmonicComponent_eq_of_same_full_shadow
#print axioms Hcrypt.TCB.PluckerObservation.recover_eq_operativeHarmonicComponent
#print axioms ProximityPrize.AffineLine.point_eq_base_of_direction_eq_zero
#print axioms ProximityPrize.AffineLine.point_eq_scale_of_diagonal
#print axioms ProximityPrize.AffineLine.point_neg_one_eq_zero_of_diagonal
#print axioms ProximityPrize.BlockCode.badChallengeSetAt_eq_empty_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.badChallengeSet_eq_empty_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.flattenedPairCode_distance_comparison
#print axioms ProximityPrize.BlockCode.hammingDistanceToCode_pairWord_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.hammingDistance_pairWord_of_directions_eq_zero
#print axioms ProximityPrize.BlockCode.not_badOnSet_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.not_mem_badChallengeSetAt_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.not_mem_badChallengeSet_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.one_le_length_mul_relativeDistanceToCode_of_not_codeword
#print axioms ProximityPrize.BlockCode.pairCloseOnSet_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.pairDistance_eq_scalarDistance_at_every_challenge_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.pairFar_of_flatFar
#print axioms ProximityPrize.BlockCode.relativeDistanceToCode_pairWord_of_direction_eq_zero
#print axioms ProximityPrize.CanonicalLift.eq_top_of_contains_affine_lifts
#print axioms ProximityPrize.CanonicalLift.eq_top_of_contains_interleaved_rs_lifts
#print axioms ProximityPrize.CanonicalLift.eq_top_of_contains_rs_lifts
#print axioms ProximityPrize.CanonicalLift.lift_apply
#print axioms ProximityPrize.CanonicalLift.wrap_coordinate_identity
#print axioms ProximityPrize.FAdditiveCode.badChallengeSetAt_eq_singleton_of_diagonal
#print axioms ProximityPrize.FAdditiveCode.badChallengeSet_eq_singleton_of_diagonal
#print axioms ProximityPrize.FAdditiveCode.badOnSet_neg_one_univ_of_diagonal
#print axioms ProximityPrize.FAdditiveCode.challengeFraction_badChallengeSetAt_eq_of_diagonal
#print axioms ProximityPrize.FAdditiveCode.not_badOnSet_of_diagonal_of_noncancelling
#print axioms ProximityPrize.FAdditiveCode.not_mem_badChallengeSetAt_of_diagonal_of_ne_neg_one
#print axioms ProximityPrize.FAdditiveCode.not_mem_badChallengeSetAt_of_diagonal_of_noncancelling
#print axioms ProximityPrize.FAdditiveCode.not_mem_badChallengeSet_of_diagonal_of_noncancelling
#print axioms ProximityPrize.FAdditiveCode.pairCloseOnSet_of_diagonal_of_noncancelling
#print axioms ProximityPrize.ReedSolomon.Parameters.codeword_iff_systematicCheck_eq_zero
#print axioms ProximityPrize.ReedSolomon.Parameters.diagonalPowerPair_fold_distance_eq_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.diagonalPowerPair_relativeDistanceToCode_eq_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.fixedCancellingLine_flatDistance_eq_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.fixedCancellingLine_pairDistance_eq_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.fixedCancellingLine_scalarDistance_eq_zero
#print axioms ProximityPrize.ReedSolomon.Parameters.flat_diagonalPowerPair_relativeDistanceToCode_eq_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.integerCheck_eq_zero_of_codeword_of_noWrap
#print axioms ProximityPrize.ReedSolomon.Parameters.no_fixedChallenge_flat_far_preservation
#print axioms ProximityPrize.ReedSolomon.Parameters.no_fixedChallenge_pair_far_preservation
#print axioms ProximityPrize.ReedSolomon.Parameters.no_unit_pair_distance_bound_by_flat_distance
#print axioms ProximityPrize.ReedSolomon.Parameters.realCheck_components_eq_zero_of_vectorCodeword_of_noWrap
#print axioms ProximityPrize.ReedSolomon.Parameters.scaledPowerWord_hammingDistanceToCode_eq_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.single_outside_noWrap_nonzero
#print axioms ProximityPrize.ReedSolomon.Parameters.zeroDirectionPowerLine_flatDistance_eq_half_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.zeroDirectionPowerLine_not_pairDistance_le_flatDistance
#print axioms ProximityPrize.ReedSolomon.Parameters.zeroDirectionPowerLine_pairDistance_eq_capacity
LEAN
LEAN_NUM_THREADS=1 lake env lean /tmp/native-metrics-axioms.lean
```

## Completed pre-addition Lean 4.35 record

The main repository pins Lean `v4.35.0` and Mathlib
`56a005855ea17e0b0958f73ec801ae140b0a1679`. All nine dependency checkouts
match the manifest. The full union of all fifteen default targets and the
explicit ledger/evidence/storage integration targets passed with
`LEAN_NUM_THREADS=4` (**9,233 jobs**, 2026-11-05).
The subsequent literal default `lake build` also passed (**9,228 jobs**).
All three fresh probes passed on this pin: **68 distinct declarations**, with
64 using exactly `propext`, `Classical.choice` and `Quot.sound`, and the same
four boundary/canonical endpoints retaining native arithmetic dependencies.
The forty-endpoint group has 36 standard-only reports; all nineteen anchor
and nine HCP/CVP reports are standard-only. None uses any of the seven
cited-bound axioms or `sorryAx`. Explicit theorem/profile hypotheses remain.

On Lean 4.35, the native dependencies print as generated constants with names
containing `_native.native_decide.ax_`, including the modulus-primality and
root-order certificates. The older `Lean.ofReduceBool`/`Lean.trustCompiler`
names below describe the preserved 4.24 reports. The new names do not remove
native trust or make these four endpoints eligible for a three-axiom-only
submission.

## Preserved Lean 4.24 mathematics/storage baseline

Validated 2026-11-05 on Lean 4.24.0. The focused mathematics/storage module build passed
(7,447 jobs). `Proximity.Application.GapBoundary` also passed its module build.
The expanded full default build passed (7,530 jobs). The **fresh forty-endpoint
axiom report passed**, with exit status zero and exactly forty distinct
declaration reports: 36 standard-only and four with the existing native
arithmetic dependencies listed below. None contains a project cited-bound
axiom or `sorryAx`. The [shared parity register](../SEMANTIC-PARITY.md)
records the remaining source-profile and manuscript obligations separately.

The comment-aware source scan now covers 215 Lean files including the Lake
configuration: no active `sorry`/`admit`, seven project axioms in the existing
concrete cited-bound module, and no local import cycles.

A source scan for `sorry`/`admit`, custom axiom declarations or import cycles
answers source questions. A successful build checks the declared statements
under their actual hypotheses. Neither substitutes for checking that those
statements express the manuscript claim. `#print axioms` lists global logical
and evaluation dependencies; ordinary theorem arguments and supplied profile,
verification, decoding or persistence hypotheses still need statement review.

## Reproduce the builds

Use the pinned `lean/lean-toolchain`, `lakefile.lean` and `lake-manifest.json`.
From the repository root:

```sh
cd lean
lake exe cache get
LEAN_NUM_THREADS=4 lake build
LEAN_NUM_THREADS=4 lake build Protocol.Core Protocol.Ledger.Examples \
  Protocol.Ledger.EvidenceExamples Protocol.Storage.Core \
  Protocol.Storage.Examples Protocol.Storage.AnchorExamples \
  Protocol.Storage.CanonicalRS
```

The full union was checked in one invocation with the same four-thread
setting. The commands above also expose the default/integration checks
separately. Hosted CI is a separate run.

Static local source import closures, including the entry module and excluding
Mathlib/dependency modules, were inspected as follows:

| Entry point | Local modules | Source import boundary |
|---|---:|---|
| `ProximityPrize` | 25 | No project `CitedBounds` module or legacy `Chain`. |
| `Protocol.Core` | 33 | No project `CitedBounds` module or legacy `Chain`. |
| `Protocol.Storage.Core` | 77 | Includes the new history/projection anchor and bounded transition dependencies; no project `CitedBounds` module or legacy `Chain`. |
| `Protocol.Storage.CanonicalRS` | 58 | Optional concrete application; no project `CitedBounds` module or legacy `Chain`. Native arithmetic dependencies remain a separate question. |

These counts describe the current source graph, not a theorem-axiom result.
They do not mean every imported theorem was audited.

## History-anchor follow-up

The new `Protocol.Storage.Anchor`, `ProjectionAnchor` and `AnchorExamples`
focused build passed (7,417 jobs), with `LEAN_NUM_THREADS=1` and unchanged
pins. This result is separate from the earlier 7,447-job mathematics/storage
milestone and forty-endpoint report. The full aggregate passed (7,532 jobs),
and the new nineteen-endpoint probe passed: each report contains exactly the
three standard Lean axioms, with no native trust, project axiom or `sorryAx`.
These are the pre-upgrade Lean 4.24.0/Mathlib-pin results preserved before the
user-authorized main-toolchain update; they do not certify the newer pin.

The source scan and import-closure table above include the three new files.
`Protocol.Core` and `ProximityPrize` retain their earlier focused boundaries;
the optional `CanonicalRS` entry does not acquire the new anchor imports.

Reproduce the new checks from `lean/`:

```sh
LEAN_NUM_THREADS=1 lake build Protocol.Storage.Anchor \
  Protocol.Storage.ProjectionAnchor Protocol.Storage.AnchorExamples
LEAN_NUM_THREADS=1 lake build
```

The separate anchor probe checks nineteen endpoints. It retains the explicit
history/gate inclusion, snapshot interpretation, verifier and backend
hypotheses; a short logical-axiom list does not instantiate those profiles.

```sh
cat > /tmp/hcrypt-anchor-axioms.lean <<'LEAN'
import Protocol.Storage.Core
import Protocol.Storage.AnchorExamples

#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.accepted
#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.snapshot_root_matches
#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.cochain_included
#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.manifest_anchored
#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.decodedDistance_eq_zero
#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.quorum_manifest_anchored
#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.quorum_snapshot_matches
#print axioms Hcrypt.Protocol.Storage.ProjectionAnchor.word_matches_candidate
#print axioms Hcrypt.Protocol.Storage.ProjectionAnchor.exact_prefix_anchored
#print axioms Hcrypt.Protocol.Storage.ProjectionAnchor.gate_database_included
#print axioms Hcrypt.Protocol.Storage.ProjectionAnchor.target_far
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.anchored_update
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.anchored_positive_value
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.quorum_anchors_same_manifest
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.quorum_names_same_snapshot
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.anchored_manifest_persisted
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.other_run_rejected
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.other_snapshot_rejected
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.raw_persisted_but_not_anchorable
LEAN
LEAN_NUM_THREADS=1 lake env lean /tmp/hcrypt-anchor-axioms.lean
```

## Read the dependency report

Keep these trust boundaries separate:

- `propext`, `Classical.choice` and `Quot.sound` are the usual Lean logical
  dependencies. Their presence does not discharge a theorem's explicit inputs.
- Existing `native_decide` arithmetic certificates add native-evaluation
  dependencies: generated `_native.native_decide.ax_` constants on 4.35,
  or `Lean.ofReduceBool`/`Lean.trustCompiler` in the old report. Record
  which endpoints actually print them, particularly at the boundary and
  canonical finite-field instances.
- The seven project axioms in
  [CitedBounds](../lean/Proximity/Concrete/CanonicalRS/CitedBounds.lean) are a
  distinct literature-bound trust boundary, including numerical witness
  constants. A module build alone neither proves those assumptions nor says
  whether a selected theorem uses them.

An `Axioms/` interface can instead be a structure of explicit hypotheses;
its directory name does not make those fields global Lean `axiom`
declarations. Conversely, a short axiom list does not establish cryptographic
security, a concrete codec/lift instance, disk durability or physical erasure.

The probe contains exactly forty distinct declarations:

| Group | Endpoints |
|---|---:|
| Q04 actual fields, subgroups and realized family bounds | 5 |
| Q05/Q06 grid and real-radius conclusions | 4 |
| Q07 minimum distance, good-challenge farness and covering endpoint | 3 |
| Concrete/legacy semantics and full-HCP obstruction | 4 |
| Context/HCP identity and local checkpoint lifecycle | 5 |
| Granular projection and controlled exact lifts | 6 |
| Optional canonical artifact/pair comparison | 3 |
| Concrete positive and rejection fixtures | 6 |
| D03 overlap, solver consistency and strict-gap view | 4 |

## Reproduce the forty-endpoint probe

Run this block from `lean/`, after the focused build. It writes only a scratch
file under `/tmp`; it changes no source file. A valid report requires exit
status zero and one dependency report for each of the forty commands, with
no unknown declarations or elaboration errors.

```sh
cat > /tmp/math-storage-axiom-audit.lean <<'LEAN'
import ProximityPrize
import Sheaf.ObservationQuotient
import Protocol.Storage.Core
import Protocol.Storage.Examples
import Protocol.Storage.CanonicalRS
import Proximity.Application.GapBoundary

/- Representative new endpoints only. Importing a module is not itself an
axiom audit. Check every report below, including native-arithmetic trust at
the boundary/canonical field instances; do not infer standard-only results
before this file has actually run successfully. -/

-- Q04: actual finite fields, power domains and realized family bounds (5).
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.length_dvd_fieldCard_sub_one
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.card_RSField
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.rootUnit_order
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.realized_fractionalListSizeBoundAt_capacity
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.realized_pairMCAErrorBoundAt

-- Q05 and Q06: exact grid/real-radius packaging (4).
#print axioms ProximityPrize.ReedSolomon.Parameters.vectorFractionalListPhaseSplit
#print axioms ProximityPrize.ReedSolomon.Parameters.vectorFractionalListRealThreshold
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.realized_listRealThreshold
#print axioms ProximityPrize.MCA.BoundaryField.pairMCA_real_128_threshold

-- Q07: attained minimum, correct good-challenge boundary and covering endpoint (3).
#print axioms ProximityPrize.BlockCode.closeAt_iff_relativeDistanceToCode_le
#print axioms ProximityPrize.BlockCode.scalarDistance_ge_of_pairDistance_ge_of_good
#print axioms ProximityPrize.ReedSolomon.Parameters.scalarDistance_eq_capacity_of_pairFar_of_good

-- Concrete/legacy semantics and the full-HCP information-loss obstruction (4).
#print axioms Hcrypt.Sheaf.CellularSheaf.CochainSemantics.accepted_iff
#print axioms Hcrypt.Sheaf.CellularSheaf.CochainPayloadInterpretation.identitySemantics
#print axioms Hcrypt.Sheaf.CellularSheaf.HodgeEncryptedCochain.not_residual_norm_factors_exactComponent
#print axioms Hcrypt.Sheaf.CellularSheaf.HodgeEncryptedCochain.not_far_preserving_exactComponent

-- Context identity, exact acceptance and local manifest lifecycle (5).
#print axioms Hcrypt.Protocol.Storage.Context.accepted_iff_decodedDistance_eq_zero
#print axioms Hcrypt.Protocol.Storage.ofHCPObservation_decodedDistance
#print axioms Hcrypt.Protocol.Storage.OpenManifest.entry_eq_of_slot_eq
#print axioms Hcrypt.Protocol.Storage.Checkpoint.persisted_of_step_from_sealed
#print axioms Hcrypt.Protocol.Storage.Checkpoint.consumed_terminal

-- Granular original projection states and controlled exact-lift comparison (6).
#print axioms Hcrypt.Protocol.Storage.Projection.Prefix.items_append_of_step
#print axioms Hcrypt.Protocol.Storage.Projection.SealedProjection.certifiedStateBus
#print axioms Hcrypt.Protocol.Storage.Projection.SealedProjection.target_far
#print axioms Hcrypt.Protocol.Storage.Calibration.LiftControl.decodedFar_implies_pairFar
#print axioms Hcrypt.Protocol.Storage.Calibration.LiftControl.accepted_of_pairCodeword
#print axioms Hcrypt.Protocol.Storage.Calibration.no_liftControl_of_nonexact_codeword

-- Optional canonical application: actual artifact, pair and geometric bound (3).
#print axioms Hcrypt.Protocol.Storage.CanonicalRS.pairDistance_eq_generic
#print axioms Hcrypt.Protocol.Storage.CanonicalRS.Observation.extractedPair_matches
#print axioms Hcrypt.Protocol.Storage.CanonicalRS.Observation.decodedFar_implies_pairFar

-- Concrete nonexact input, accepted zero and object-indexed storage fixtures (6).
#print axioms Hcrypt.Protocol.Storage.Examples.raw_decodedDistance_pos
#print axioms Hcrypt.Protocol.Storage.Examples.zero_accepted
#print axioms Hcrypt.Protocol.Storage.Examples.complete_execution
#print axioms Hcrypt.Protocol.Storage.Examples.changed_run_receipt_rejected
#print axioms Hcrypt.Protocol.Storage.Examples.payload_transplant_rejected
#print axioms Hcrypt.Protocol.Storage.Examples.second_consumption_rejected

-- D03: overlap, solver inconsistency and unchanged-object strict-gap view (4).
#print axioms Hcrypt.Proximity.GapProximityProblem.near_and_far_iff
#print axioms Hcrypt.Proximity.GapProximityProblem.not_exists_correctSolver_of_boundary_attained
#print axioms Hcrypt.Proximity.GapProximityProblem.exists_correctSolver_iff_promisesDisjoint
#print axioms Hcrypt.Proximity.SeparatedGapProblem.promisesDisjoint
LEAN
LEAN_NUM_THREADS=1 lake env lean /tmp/math-storage-axiom-audit.lean
```

Fresh report outcome: **passed**, with the following dependency classes:

| Dependency class | Endpoints |
|---|---:|
| Exactly `propext`, `Classical.choice`, `Quot.sound` | 36 |
| Those three plus generated native certificate axioms on 4.35 (native compiler trust on 4.24) | 4 |
| Project cited-bound axiom or `sorryAx` | 0 |

The four native-arithmetic endpoints are:

- `ProximityPrize.MCA.BoundaryField.pairMCA_real_128_threshold`.
- `Hcrypt.Protocol.Storage.CanonicalRS.pairDistance_eq_generic`.
- `Hcrypt.Protocol.Storage.CanonicalRS.Observation.extractedPair_matches`.
- `Hcrypt.Protocol.Storage.CanonicalRS.Observation.decodedFar_implies_pairFar`.

All selected generic-family, semantic-transport, HCP-obstruction, storage-core,
fixture and gap-boundary endpoints are in the standard-only class. This is
an audit of the forty listed declarations, not every theorem in the project;
their explicit profile, codec, gate and persistence hypotheses remain.

## Reproduce the HCP/CVP port probe

These nine additional declarations cover the central projection, explicit
coordinate transport, separation and lattice-solution bridges touched by the
4.35 port. All nine fresh reports contain exactly the three standard axioms.
The coordinate conversions retain the Euclidean carriers and existing CVP
squared distance; they introduce no source-radius or authentication profile.

From `lean/`:

```sh
cat > /tmp/hcrypt-hcp-axioms.lean <<'LEAN'
import Hardness

#print axioms Hcrypt.HCP.decrypt_eq_orthogonalProjection
#print axioms Hcrypt.HCPBridge.IsometricPresentationEquivalence.harmonic_iff_transport
#print axioms Hcrypt.HCPBridge.IsometricPresentationEquivalence.operativeHarmonicComponent_naturality
#print axioms Hcrypt.HCPBridge.operativeTargets_ne_of_kernelSeparation
#print axioms Hcrypt.HCPBridge.no_solver_exactOnOperativeTarget_of_kernelSeparation
#print axioms Hcrypt.HCPBridge.cvpOracle_insufficient_for_operativeTarget
#print axioms HarmonicCVPBridge.solution_iff_projectedTarget
#print axioms concreteSheafHCP_CVP_solution_iff_message
#print axioms concreteSheafHCP_CVP_existsUnique
LEAN
LEAN_NUM_THREADS=1 lake env lean /tmp/hcrypt-hcp-axioms.lean
```

The [storage guide](../lean/Protocol/Storage/README.md) explains the preserved
objects, distinct roots, three distance meanings and local/runtime boundary.
The [shared parity register](../SEMANTIC-PARITY.md) and
[Paper 3 register](../papers/proximity-prize/SEMANTIC_PARITY.md) retain the
separate profile, radius, scope and novelty obligations.
