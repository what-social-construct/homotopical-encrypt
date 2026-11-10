# Lean and manuscript public-review draft

The intended first public subset is the Lean formalization and its
corresponding research manuscripts. It preserves the repository layout so
paper-to-source links can be followed directly. This broad human-review package is distinct from the planned slim, per-entry
Palomar release. This is a local review draft;
no repository visibility change, upload or external outreach is performed by
the preparation tooling. The [slim release guide](docs/PALOMAR_SLIM_RELEASES.md)
records three separately generated entry packages and their local checks;
this broad archive retains cross-paper context for human review.

The separate [Paper 1-only release](https://github.com/what-social-construct/homotopical-encrypt-formalizations)
is public at `66e1ad2cb726d3dd816461e4f76b1d0d9147a46d`.
Its [protected preflight](https://github.com/what-social-construct/homotopical-encrypt-formalizations/actions/runs/42729947447)
passed, with protected comparison, source provenance and Lean/NanoDa/con-ron
acceptance confirmed in its downloaded report. That exact historical snapshot
contains the earlier 101-page Paper 1. The revised manuscripts and Lean
documentation described below have not been published or protected-preflighted.
The broader archive described here remains a local review package.
The user has explicitly deferred Palomar submission and registration.

**Current standalone mathematics revision, 2026-11-09.** Paper 1 is
**36 pages** and develops the recovery problem, hidden-operator difficulty,
CVP comparison and observation limits without repeated companion-paper
ownership notes. Section 5, *Observation Boundaries and Recovery*, combines
the former two observation sections: exact cochains, the exact-component
obstruction, additional public observations, frames/projective coordinates
(§5.4), and recovery from the full point (§5.5). Section 6 is *Conclusion and
Further Work*. Its post-conclusion parity table retains four definition rows,
eight main groups (21 declarations), five support groups (25 declarations),
and three background/assumption/contract rows; concise proof boundaries follow.
Paper 1 prints five external mathematical references; its bibliography still
has seven records, including two uncited companion entries. The 28-source
ledger mapping remains intact; Paper 2/3 retain 42/16 bibliography records,
and Paper 3's 31-page PDF is unchanged. Lean edits are limited to section-number
comments; all non-comment Lean source is unchanged. The checked 9,295-job/
975-report proof state is retained without claiming a repeated Lean build.
The revised candidate remains local and needs its own exact-commit protected
preflight; public `66e1ad2` and its passing report remain unchanged.

**Preserved P302/P303 back-matter checkpoint, 2026-11-09.** Paper 1 then had
38 pages, separate observation sections and a section-7 conclusion. Its parity
table retained all 46 selected declarations, and its seven printed references
included the two companion manuscripts. All 280 Lean files at that checkpoint
were byte-identical to `dddfdd2`. Those exact-source facts and the earlier
37-page P300/P301 checkpoint remain historical evidence, rather than claims
about the current section numbering or whole-file bytes.

**Earlier P300/P301 scope checkpoint, 2026-11-09.** Paper 1 was reduced to 37 pages and retained HCP,
Hodge/CVP comparisons, the actual Helfer homological-test fragment and the
observation/Plücker recovery mathematics. Paper 2 owns the concrete cochain
commitment, codec, visibility, gates/evidence and storage contracts in its
working draft. Paper 3 became 31 pages and owns the quantitative RS/proximity,
calibration and metric-bridge analysis. The accompanying edits in 93 Lean
files change comments only. Fresh local validation passes the 9,295-job
expanded build and all 975 selected dependency reports, with every prior
dependency set unchanged. Those 37/31-page PDFs passed build/render/layout QA. These
results are recorded separately in the central validation guide; the earlier
protected PASS does not validate these changed bytes or manuscripts.

## Included scope

- `lean/`: current source, pinned toolchain, Lake configuration/manifest and
  reviewer guides, including the conservative protocol core and typed
  sheaf-storage/projection infrastructure. Paper 1 and Paper 3's coding/application
  entries include their configurations, metadata and source crosswalks.
- `papers/paper1/`: *Homotopical Encryption: Hidden Hodge Operators and the
  Harmonic Cochain Problem*, its TeX/bibliography sources and reviewed PDF.
- `papers/proximity-prize/`: Paper 3, *Capacity-Radius Proximity for Smooth-Domain
  Reed–Solomon Codes*, with sources, reviewed PDF and detailed parity register.
- `papers/paper2/`: initial manuscript text, scope notes and bibliography, clearly
  work in progress. There is no Paper 2 TeX manuscript or PDF yet.
- The MIT license, shared parity register and selected mathematical/protocol
  documentation needed to explain definitions, proof status and assumptions.

Runtime implementations, private configuration, Git history, dependency/build
caches, OS metadata and intermediate TeX outputs are outside this package.
The exporter reads the working tree, so current source additions are included
even before a commit. It uses explicit directories and file extensions rather
than copying the whole repository.

## Review entry points

Start with [lean/README.md](lean/README.md), then Paper 1's post-conclusion parity table and [shared parity register](SEMANTIC-PARITY.md). The [source ledger](docs/SOURCE_LEDGER.md)
and [three-paper completion checkpoint](docs/PAPER_OUTLINE.md#source-based-completion-checkpoint--2026-11-08)
record literature adoption boundaries and remaining work.
[Protocol/README.md](lean/Protocol/README.md) explains the new bounded kernel;
the [storage guide](lean/Protocol/Storage/README.md) follows its manifests,
projection levels and gates. The [cochain trace](docs/COCHAIN_PROXIMITY_TRACE.md)
follows the same commitment through the proximity bridge, and the
[literature comparison](docs/PROXIMITY_NOVELTY_COMPARISON.md) records the instantiated modular profile and the stronger claims that retain
separate obligations.

The important distinctions remain visible:

- Source coverage is not proof completion or novelty certification.
- The standalone `ProximityPrize` target does not import the seven custom
  literature-bound axioms in `Concrete/CanonicalRS/CitedBounds.lean`.
- The formerly native arithmetic certificates now have kernel-checked proofs.
  Current selected dependency reports use only standard logical axioms; the
  older native-trust audits remain dated baselines.
- The protocol core proves conservative update and evidence-binding results
  under explicit valuation, authorization, snapshot and runtime contracts.
  Its toy fixtures do not establish cryptographic security or consensus finality.
- The explicit modular profile uses the original payload and actual integral
  cellular coboundary. Its native distances satisfy `d_C ≤ d_P = D_RS ≤ 2d_C`,
  with a payload attaining `3/4` at all three levels. The canonical fixed mix
  is good for its diagonal family; arbitrary fixed-mix preservation is refuted.
  Euclidean decoded exactness, full HCP residual and frame scores retain their
  own definitions and comparison obligations.
- The [concrete HCP family](lean/HCP/README.md) supplies two actual integral
  cellular sheaves, a proved homological-test semantic model, the same `(class,b)`
  with distinct nonzero harmonic targets, and positive/negative CVP comparisons.
  A weighted sample separates integer coefficients 2 and 1 in its declared
  encoder. All 96 selected new reports are standard-only. Full first-order
  semantics, a complete public storage-view privacy result and a sampling
  security game are separate claims.
- Full genuine Plucker coordinates reconstruct the subspace and its fixed-metric
  projector. Operative-target recovery requires identification with that kernel;
  no efficient finite encoding or recovery from a digest is claimed.
- On unrestricted Hodge samples with a nonzero coexact direction, extraction
  through the decoded exact component cannot preserve a positive full-HCP
  far radius uniformly. A restricted authenticated/noise profile needs its
  own comparison theorem.

## Readiness record

The last completed Lean/Mathlib 4.35.0 expanded/default build baseline passed
**9,295/9,285 jobs** before the local manuscript/comment split.
Its probe covers **975 selected declarations**, all standard-only,
including the 46 Paper 1, 52 coding and 22 application targets. All 946 prior
dependency sets match. Five old modules change: three comments and two encoder/
opening presentations whose values are definitionally equal to the old formulas.
The selected manuscript statement map foregrounds Paper 1's CVP/HCP
comparison and retains Paper 3's nine coding groups plus its bounded modular
application. Hodge component uniqueness is now proved; boundary/canonical
arithmetic no longer adds native trust. Previous milestones remain dated
baselines in the shared validation record.

The public snapshot's wording pass foregrounded the concrete nonzero-target
and weighted-coefficient examples, explicitly stated the finite
signed-incidence model and corrected legacy likelihood/nullity descriptions.
Its reviewed PDF remains 101 pages at that exact commit. P300/P301 produced
the reviewed 37-page ownership revision. The P302/P303 38-page revision retained
that split and consolidated the Lean correspondence after the conclusion.
The current 36-page revision merges the observation exposition and keeps the
manuscript focused on HCP. Detailed protocol construction belongs to Paper 2 and quantitative analysis
to Paper 3.
Paper 1 remains the first release priority; no revised release is frozen here.

The implementation, build and dependency counts below retain that completed
baseline unless a row explicitly identifies the current local manuscripts.
P300/P301 subsequently checked the 93 documentation edits. The current
standalone revision retains every non-comment Lean source byte, with only
section-reference comment edits.

| Item | Current status |
|---|---|
| License and dependency pins | Existing MIT license, Lean `v4.35.0`, Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679` and matching transitive manifest. |
| Last completed Lean source scan | 280 Lean files including Lake (279 public modules); zero implementation holes, with 96 deliberate theorem placeholders isolated in three independent Challenges. Solutions import no Challenge. Seven global custom axioms remain isolated in CitedBounds. No native calls, cycles or unresolved imports. |
| Generic coding mathematics | All nine named standalone statements have Lean endpoints. Q04--Q07 are complete; the 33-module standalone closure excludes project cited-bound axioms and legacy `Chain`. |
| Conservative core and integration examples | The current 4.35 aggregate includes `Protocol.Core`, ledger and evidence examples, sheaf adapters and same-proposal quorum joins. All pass with their explicit profile inputs. |
| Sheaf storage and gates | The current build includes `Storage.Core`, its fixtures, public payload/header and sealed-root/directory projections, explicit HCP disclosure and optional canonical observation adapter. Roots, decoded exactness and pair distance retain their separate definitions. The public views are semantic projections, not serializers or hiding proofs. |
| Recipient recovery and rotation | Actual integral/encoded rotation, both same-coefficient recipient routes and original bound-HCP payload migration pass. Scoped receipts index actual material, recipient, epoch labels and original contexts under supplied channel/authorization contracts. Matching public labels authenticate no caller and prevent no replay; the decoder is classical/noncomputable. |
| Conditional owned-resource transfer | Public input-ID nullifiers, fixed owned catalog, actual byte/metadata/intent checks and trusted-decoder primitive results derive one computed update. Typed hash inputs, full packet evidence, original input manifest and optional complete-proposal quorum retain their exact objects. Primitive implementations, authentic state origin, runtime refinement and finality remain contracts. |
| One-shot sampled integrity | The same soundness-free operational checker reduces actual accepted-invalid attempts to authorization or exact-payload false acceptance. A selected actual release, explicit auxiliary data and shared PMF support a conditional sum bound, without independence. Primitive error estimates, adaptive signing/corruption experiments, setup security and privacy remain open. |
| Actual primitive/TCB comparison | Exact owner/key/message/history and backend-proof input agreement give a five-event error decomposition under the same PMF. Existing Rust spectral messages/matrix checks do not implement those original-object joins. Ordinary graph translation preserves the full payload while changing its vertex message. Legacy TCB carriers package supplied truth; no numerical primitive or new privacy bound is claimed. |
| Existing-object owner signing | Full metadata/Intent messages, typed authorized issues and actual history projection construct the checker/profile. Under the same fixed policy and foreign-domain condition, queried-unauthorized mass is zero; four primitive/context errors remain. Codec, keys, history provenance and concrete native path-space proof algorithms remain explicit obligations. |
| Native path/witness handoff | A supplied path realization constructs the same original fiber transport and rotation, with harmonic projection and coefficient recovery. A partial finite decoder retains the actual credential opening and admissible path; original ownerSignature bytes execute the existing proof backend on the selected key/full message. The outer credential/message parser is concrete and injective; finite typed packet/full-ciphertext/private-witness encodings, credential/proof algorithms, statement reflection and knowledge/unforgeability security remain open. |
| Native retrieval and full-ciphertext recovery | Actual HodgeNoise queries produce a response equal to an original full encryption observation, with original coefficient recovery and same-answer CVP comparison. Digest-checked full bytes join original bound-HCP rotation/recovery with a collision alternative. Whole-bucket O(N) reads have equal fixed-scope transcripts/distributions; conditional joint-column disclosure is separate. Efficient PIR, manifest authentication and concrete finite byte/proof profiles remain open. |
| Canonical decision profile | Closed promises retain `(ε,δ_J)` on both sides, concrete near 2046/4096 and far 2047/4096, the original map and solver pullback. Its canonical arithmetic now uses kernel proofs. The geometric far witness and efficient solver remain explicit obligations. |
| History/manifest anchor | The joins and fixtures pass on 4.35, and all nineteen fresh anchor reports use only the three standard Lean axioms. Concrete authentication/encoding/backend profiles remain explicit. The earlier 4.24 focused/full results are preserved in the shared register. |
| Theorem dependencies | All 975 selected reports are standard-only (792 exact-three/183 subsets, 106 axiom-free); all 975 pre-revision sets match. No selected native, cited-bound or sorryAx dependency occurs. The [validation record](docs/MATH_STORAGE_VALIDATION.md#manuscript-ownership-revision--2026-11-09) records current checks and preserves historical audits. |
| Full aggregate validation | The checked expanded union at `dddfdd2` passed 9,295 jobs, including all fifteen default roots and three Solutions. The current editorial revision preserves every non-comment Lean source byte, with only section-reference comment edits, and retains that proof state. Literal default 9,285 remains the pre-revision baseline. Source/input identity, definition comparisons and dependency audits are separate checks; current local results are recorded centrally. The broader hosted aggregate has not run; Paper 1's exact historical slim snapshot passed protected preflight. |
| Paper 1 independent entry | [Challenge/Solution and metadata](lean/Palomar/PaperOne/README.md) cover eight selected groups through 21 manuscript-facing and 25 supporting declarations. Mathlib-only independent statements and local Comparator/Lean/NanoDa checks pass. The prior macOS diagnostic was separate. Public commit 66e1ad2 now passes the complete protected workflow, canonical source audit and Lean/NanoDa/con-ron replay; its sole size advisory is within hard caps. |
| Paper 3 independent entries | [Coding](lean/Palomar/PaperThree/README.md) and [original-cochain application](lean/Palomar/PaperThree/Application/README.md) retain all fourteen selected groups across two configurations. Both full local definition comparisons and Lean/NanoDa replays pass. Actual fields, original Context/payload/decoder and three native distances remain explicit; encoder/opening values are preserved by rfl. Protected Linux verification remains. |
| Current local manuscripts | Paper 1 is 36 pages, focused on HCP/Hodge/CVP, the actual semantic fragment and observation/Plücker mathematics. Paper 2's working Markdown draft owns the concrete construction and protocol contracts; it has no TeX/PDF. Paper 3 is 31 pages and owns the quantitative coding, proximity, calibration and bridge results. The revisions preserve the existing three-paper split and are not a public release. |
| Manuscript compile record | The earlier 37/31-page ownership revision compiled and passed all 68 pages of render/contact review. The current Paper 1 is 36 pages with one merged observation section and one post-conclusion parity table; latest PDF checks belong to the central validation record. Paper 3 and its cited bibliography output are unchanged. Mathematical preservation and selected crosswalk inventories are checked separately. These local checks do not replace protected verification. The earlier 101-page/30-page rendered reviews and matching review-copy checks remain evidence for their earlier exact artifacts. |
| Public publication | Only the approved historical Paper 1 snapshot is public. The revised manuscripts and Lean documentation edits remain local and have not passed protected preflight. The broader three-paper archive and Paper 2/3 manuscripts remain unpublished here. No Palomar intake or registration was requested. |

## Prepare a local package

From the repository root:

```sh
python3 scripts/export_public_review.py
```

This produces a repo-shaped folder and ZIP under `output/public-review/`,
plus a SHA-256 file inventory. `--refresh` replaces only an earlier folder
created by this exporter. The source repository and its history are unchanged.

The package contains a small Lean/manuscript CI workflow, separate from the
full repository's Rust/Python integration jobs. The authoritative checks are
the pinned Lean build, explicit transition examples, theorem axiom reports,
and both manuscript builds. All three selected Solutions are included in the
review build. The separate manual Palomar workflows have no automatic push or
pull-request trigger. The published Paper 1 workflow passed; other prepared entry workflows have not run. Public visibility need not wait for every future
research theorem or production feature, provided the stated claims and open
obligations remain accurate.
