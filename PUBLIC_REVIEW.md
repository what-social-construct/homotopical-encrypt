# Lean and manuscript public-review draft

The intended first public subset is the Lean formalization and its
corresponding research manuscripts. It preserves the repository layout so
paper-to-source links can be followed directly. This broad human-review package is distinct from the planned slim, per-entry
Palomar release. This is a local review draft;
no repository visibility change, upload or external outreach is performed by
the preparation tooling. The [slim release guide](docs/PALOMAR_SLIM_RELEASES.md)
records three separately generated entry packages and their local checks;
this broad archive retains cross-paper context for human review.

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

Start with [lean/README.md](lean/README.md), then the manuscript's theorem
ledger and [shared parity register](SEMANTIC-PARITY.md). The [source ledger](docs/SOURCE_LEDGER.md)
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

The current Lean/Mathlib 4.35.0 expanded/default builds pass **9,295/9,285 jobs**.
The fresh probe covers **975 selected declarations**, all standard-only,
including the 46 Paper 1, 52 coding and 22 application targets. All 946 prior
dependency sets match. Five old modules change: three comments and two encoder/
opening presentations whose values are definitionally equal to the old formulas.
The selected manuscript statement map foregrounds Paper 1's CVP/HCP
comparison and retains Paper 3's nine coding groups plus its bounded modular
application. Hodge component uniqueness is now proved; boundary/canonical
arithmetic no longer adds native trust. Previous milestones remain dated
baselines in the shared validation record.

| Item | Current status |
|---|---|
| License and dependency pins | Existing MIT license, Lean `v4.35.0`, Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679` and matching transitive manifest. |
| Current Lean source scan | 280 Lean files including Lake (279 public modules); zero implementation holes, with 96 deliberate theorem placeholders isolated in three independent Challenges. Solutions import no Challenge. Seven global custom axioms remain isolated in CitedBounds. No native calls, cycles or unresolved imports. |
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
| Theorem dependencies | All 975 selected reports are standard-only (792 exact-three/183 subsets, 106 axiom-free); all 946 prior sets match. No selected native, cited-bound or sorryAx dependency occurs. The [validation record](docs/MATH_STORAGE_VALIDATION.md#paper-3-independent-entries--2026-11-09) reproduces the entry checks and preserves historical audits. |
| Full aggregate | Literal default 9,285 jobs and expanded union with all three Solutions 9,295 jobs pass. Source/input identity, definition comparisons and dependency audits are separate checks; hosted/protected CI has not run here. |
| Paper 1 independent entry | [Challenge/Solution and metadata](lean/Palomar/PaperOne/README.md) cover eight selected groups through 21 manuscript-facing and 25 supporting declarations. Mathlib-only independent statements and local Comparator/Lean/NanoDa checks pass. The macOS diagnostic disables Comparator's Linux sandbox; protected preflight remains. The manual-only workflow is prepared locally and has not run. |
| Paper 3 independent entries | [Coding](lean/Palomar/PaperThree/README.md) and [original-cochain application](lean/Palomar/PaperThree/Application/README.md) retain all fourteen selected groups across two configurations. Both full local definition comparisons and Lean/NanoDa replays pass. Actual fields, original Context/payload/decoder and three native distances remain explicit; encoder/opening values are preserved by rfl. Protected Linux verification remains. |
| Manuscripts | Paper 1's selected HCP/CVP entry follows its named propositions and includes Hodge uniqueness. Paper 3's coding/application entries and field/trust boundaries are aligned. Paper 2 remains a conditional working draft. Both manuscript PDFs are unchanged in this entry-preparation step. Slim frozen releases and concrete protocol/security implementation remain separate. |
| Manuscript alignment | Paper 1's 101-page PDF and Paper 3's 30-page PDF compile without undefined references/citations, missing glyphs or overfull boxes. The revised 101-page Paper 1 was rendered and visually checked after its observation and strict decision-profile corrections; Paper 3's revised 30-page summary/source-comparison pass was rendered and visually checked; some underfull-box diagnostics remain. These are recorded layout/compile checks, not final statement-alignment certification. Their ledgers include Plucker recovery, native-metric endpoints, storage owners and explicit source-profile boundaries. Canonical and stable review copies match byte-for-byte. |
| Public publication | Not performed. Review the source package and choose the destination and timing separately. |

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
pull-request trigger and have not run. Public visibility need not wait for every future
research theorem or production feature, provided the stated claims and open
obligations remain accurate.
