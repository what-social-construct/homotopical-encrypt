# Lean and manuscript public-review draft

The intended first public subset is the Lean formalization and its
corresponding research manuscripts. It preserves the repository layout so
paper-to-source links can be followed directly. This broad human-review package is distinct from the planned slim, per-entry
Palomar release. This is a local review draft;
no repository visibility change, upload or external outreach is performed by
the preparation tooling.

## Included scope

- `lean/`: current source, pinned toolchain, Lake configuration/manifest and
  reviewer guides, including the conservative protocol core and typed
  sheaf-storage/projection infrastructure.
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
ledger and [shared parity register](SEMANTIC-PARITY.md).
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
- Existing `native_decide` arithmetic certificates have compiler/native trust
  dependencies separate from ordinary Lean logical axioms.
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

The main development now passes validation on the stable Lean/Mathlib 4.35.0
pair. The current full aggregate/integration build passes 9,284 jobs; the
literal default passes 9,277 jobs. The fresh probe covers 728 distinct selected
declarations, including 61 added signing/issuance/checker/release reports. The earlier
primitive comparison, one-shot integrity, owned-transfer, rotation, public-observation, cellular-HCP, native-metric and 4.24 milestones remain dated baselines in the
shared validation record.

| Item | Current status |
|---|---|
| License and dependency pins | Existing MIT license, Lean `v4.35.0`, Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679` and matching transitive manifest. |
| Current Lean source scan | 266 Lean files including the Lake configuration (265 source modules); no active `sorry`/`admit` found; seven explicit custom axioms isolated in the concrete cited-bound module. No local import cycles. This is source scanning, not theorem-dependency verification. |
| Generic coding mathematics | All nine named standalone statements have Lean endpoints. Q04--Q07 are complete; the 33-module standalone closure excludes project cited-bound axioms and legacy `Chain`. |
| Conservative core and integration examples | The current 4.35 aggregate includes `Protocol.Core`, ledger and evidence examples, sheaf adapters and same-proposal quorum joins. All pass with their explicit profile inputs. |
| Sheaf storage and gates | The current build includes `Storage.Core`, its fixtures, public payload/header and sealed-root/directory projections, explicit HCP disclosure and optional canonical observation adapter. Roots, decoded exactness and pair distance retain their separate definitions. The public views are semantic projections, not serializers or hiding proofs. |
| Recipient recovery and rotation | Actual integral/encoded rotation, both same-coefficient recipient routes and original bound-HCP payload migration pass. Scoped receipts index actual material, recipient, epoch labels and original contexts under supplied channel/authorization contracts. Matching public labels authenticate no caller and prevent no replay; the decoder is classical/noncomputable. |
| Conditional owned-resource transfer | Public input-ID nullifiers, fixed owned catalog, actual byte/metadata/intent checks and trusted-decoder primitive results derive one computed update. Typed hash inputs, full packet evidence, original input manifest and optional complete-proposal quorum retain their exact objects. Primitive implementations, authentic state origin, runtime refinement and finality remain contracts. |
| One-shot sampled integrity | The same soundness-free operational checker reduces actual accepted-invalid attempts to authorization or exact-payload false acceptance. A selected actual release, explicit auxiliary data and shared PMF support a conditional sum bound, without independence. Primitive error estimates, adaptive signing/corruption experiments, setup security and privacy remain open. |
| Actual primitive/TCB comparison | Exact owner/key/message/history and backend-proof input agreement give a five-event error decomposition under the same PMF. Existing Rust spectral messages/matrix checks do not implement those original-object joins. Ordinary graph translation preserves the full payload while changing its vertex message. Legacy TCB carriers package supplied truth; no numerical primitive or new privacy bound is claimed. |
| Existing-object owner signing | Full metadata/Intent messages, typed authorized issues and actual history projection construct the checker/profile. Under the same fixed policy and foreign-domain condition, queried-unauthorized mass is zero; four primitive/context errors remain. Codec, keys, history provenance and the recovered native path-space backend remain explicit obligations. |
| History/manifest anchor | The joins and fixtures pass on 4.35, and all nineteen fresh anchor reports use only the three standard Lean axioms. Concrete authentication/encoding/backend profiles remain explicit. The earlier 4.24 focused/full results are preserved in the shared register. |
| Theorem dependencies | All 728 distinct selected reports pass: 692 use only standard Lean axioms (555 exactly the usual three, 137 subsets); 36 also inherit existing native arithmetic trust, printed as generated `_native.native_decide.ax_` constants on 4.35. None uses a cited-bound axiom or `sorryAx`. The [validation guide](docs/MATH_STORAGE_VALIDATION.md) reproduces the consolidated probe and preserves earlier audit baselines. Explicit theorem/profile/runtime hypotheses remain. |
| Full aggregate | The literal default `lake build` passes (9,277 jobs); all fifteen defaults plus explicit ledger/evidence/storage/recipient/owned-transfer integration targets also pass (9,284 jobs). The [current validation record](docs/MATH_STORAGE_VALIDATION.md#current-owner-signing-reuse-and-issuance--2026-11-07) distinguishes this from earlier milestones and axiom reports. Hosted CI has not been run as part of this preparation. |
| Manuscripts | Paper 1 §3 and its ledgers include the actual cellular HCP family and conditional observation adapters. Papers 1 and 3 have reviewed PDFs and source ledgers. Paper 2 has working text for public inputs, recipient rotation, the conditional owned-resource transition and one-shot sampled integrity; primitive/channel/runtime/state-origin and security implementation remain work in progress. |
| Manuscript alignment | Paper 1's 99-page PDF and Paper 3's 28-page PDF compile without undefined references/citations, missing glyphs or overfull boxes. The revised 99-page Paper 1 was rendered and visually checked; Paper 3 retains its previous 28-page review; some underfull-box diagnostics remain. Their ledgers include Plucker recovery, native-metric endpoints, storage owners and explicit source-profile boundaries. Canonical and stable review copies match byte-for-byte. |
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
and both manuscript builds. Public visibility need not wait for every future
research theorem or production feature, provided the stated claims and open
obligations remain accurate.
