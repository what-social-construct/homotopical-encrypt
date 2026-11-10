# Manuscript--Lean semantic parity

Review dates: 2026-11-04; mathematics/storage, object-model and toolchain
follow-ups 2026-11-05; concrete Helfer/HCP implementation, public-input profile
recipient recovery/rotation, owned-resource transition and one-shot integrity
2026-11-06; primitive/TCB comparison and existing-object owner-signing wiring 2026-11-07; native Hodge retrieval,
full-ciphertext recovery, source/completion assessment and Paper 1 observation
wording reconciliation 2026-11-08.

**Current naming and projective-chain allocation — 2026-11-10:** P311 uses
`HomotopicalEncryption` throughout current Lean sources, entry configurations,
metadata and manuscript crosswalks. Paper 1 has seven selected groups,
38 declarations (18 main/20 support), 20 deliberate Challenge placeholders
and a 22-module Solution closure. Its HCP/CVP proof is independent of
Plücker coordinates. The full-coordinate construction moves unchanged to
Paper 3 §7.1, with canonical reconstruction/chain proofs retained as auxiliary
results outside its unchanged coding/native-modular selections. Paper 2
consumes those results for visibility/codec contracts. The parity appendix
contains all 38 retained selected anchors exactly once. Core P1 §3 and P3
§§2–6 are byte-identical; all 31 retained P1 formal environments and formulas
are preserved apart from the nonmathematical solver aside. PDFs are 27/33
pages and compile without overfull boxes or missing references/citations.
The [naming guide](docs/PROJECT_NAMING.md) records the historical-evidence
boundary and the Rust prototype's exclusion. Rust/Cargo are restored to their
starting state, including the existing uncommitted storage edit. Fresh Lean,
dependency, reduced-entry comparison and export checks are recorded in the
validation guide; older reports below remain exact-snapshot history.
No publication, protected preflight or registry submission is performed.

**Optional generic classifier completeness — 2026-11-10:** P310 adds
`ReflectsHomotopyEquivalence` to the existing realization API as an explicit
optional proposition. With closed-test invariance it yields the generic iff
and identifies the existing public-class fiber with the declared semantic
homotopy class. AxisFamily proves reflection and now derives its existing
iff through that API. Realization fields, constructors and the weaker
hardness hypotheses remain unchanged. The manuscript defines completeness
before the recovery problem and states its two consequences after the
classifier bridge. All 35 existing formal environments and nine entry
statement/configuration files are preserved. Three new theorems, one
proposition-valued definition and one refactored proof change two Lean files;
the other 278 files match `f036a16`. Current builds pass 3,581/3,759 jobs;
all five focused reports use exactly the three standard axioms. The 29-page
PDF passes layout checks, with one parity appendix, 46 selected anchors and
five canonical theorem anchors. No protected preflight, publication or
submission is performed.

**Redundancy cleanup and restricted classifier converse — 2026-11-10:**
P309 consolidates repeated public-input, hidden-kernel, transport and scope
explanations. The duplicate Recovery Target subsection is removed;
Computational Scope is §2.3. The separate Formal Objects and Proof Boundaries
appendix is folded into the single parity appendix's entry, noncomputability
and proof-axiom notes. The PDF is 28 pages, with its four contribution items
kept together. All 35 formal environments are byte-identical to `6b762a0`.
The earlier blanket converse wording is corrected: the actual admitted
`Fin 2` family has typed equivalences for all ordered pairs, and equality of
its public theories is equivalent to that relation. Generic factorization
still asserts only the forward implication. Two canonical theorems are added
in AxisFamily; all prior source there and the other 279 Lean files are
preserved. Fresh 3,581/3,759-job builds and the two exact-standard-three
dependency reports pass; the previous 124-report audit remains its recorded
evidence. All 46 selected anchors and three separately marked canonical
anchors remain. No new protected preflight, publication or submission occurs.

**Primitives before HCP and proved lattice-member separation:** P308 starts
§2 with declared homotopy equivalence, its invariant public class/fiber and
Hodge data, followed by the sample, public observation and hidden witness;
HCP then asks for the already defined operative target. Four definitions are
reworded, with existing propositions/proofs preserved. The introduction has
four complete statements without colons; contribution (iii) gives only the
lattice-family comparison, and the requested foundation/signposting prose is
removed. Corollary 3.6 closes the argument immediately before the conclusion.
Its canonical Lean proof fixes the same correct rank-one CVP oracle: the
supplied operative lattice yields its answer, but the shared public observation
cannot select every compatible target. A generic lemma proves that any
containing compatible family inherits the obstruction. Three new canonical
theorems and one refactored proof change two Lean files; the other 278 and
all nine entry statement/configuration files match `048c2ea`. Focused builds
pass 3,581/3,759 jobs. All 124 fresh dependency reports are standard-only,
with all 120 previously selected sets unchanged. The 32-page PDF passes build
and layout checks; 46 selected anchors plus two separately identified canonical
consequences appear in the parity table. No new protected preflight,
publication or submission is claimed.

**Concise class-of-lattices comparison — 2026-11-09:** P307 reduces
contribution (iii) to the main result: compatible harmonic lattices in one
public class have distinct unique CVP answers to the same cochain, and
known-lattice CVP access does not select the operative answer. The example
now explains that supplying both answers leaves this ambiguity, independent
of running time. A strict quantitative hierarchy by target multiplicity is
tracked separately in D54; no infinite-family or complexity-reduction theorem
is added by this prose revision. Formal statements/proofs and Lean bytes
remain unchanged; the local PDF remains 32 pages.

**Homotopy-class wording — 2026-11-09:** P306 makes the introduction's
homotopy-class meaning explicit: homotopy-equivalent hidden representatives
share the public label while their Hodge operators may differ in fixed public
coordinates. The label records homotopy-class information; the generic
classifier is not asserted to distinguish every homotopy class. This preserves
§2's one-way bridge and the concrete homological-theory classifier. Only one
introductory paragraph changes; formal statements, proofs and all Lean source
bytes are unchanged. The reviewed local PDF remains 32 pages.

**Construction-first HCP exposition — 2026-11-09:** P305 integrates the
semantic/classifier assumptions, exact-cochain/opening facts and observation
choice into §2. Full-projective recovery is §2.2.1. The actual homological
model is explained beside the cellular example in §3.5; CVP comparison and
kernel ambiguity form the final main section before conclusion §4. The
separate semantics and observation files are removed. All eleven proposition
statements and eleven definitions are preserved verbatim; ten proofs are
verbatim and the remaining proof clarifies its closed-test invariance premise
without changing its formulas or argument. All 46 parity targets occur once.
The 32-page PDF passes build and layout checks, with five printed external
references. Nine Lean header comments are aligned; all 280 non-comment source
fingerprints and all nine entry statement/configuration files are unchanged.
P301's proof-state evidence is retained without a new build or kernel replay.
This local revision neither updates public `66e1ad2` nor performs submission;
new informal material still needs an exact-commit protected preflight.

**Standalone recovery-problem exposition — 2026-11-09:** P304 removes
repeated descriptions of the companion manuscripts and the runtime/layer
planning language from Paper 1. Its narrative runs from Helfer's semantic
motivation to the HCP input/target and hidden-operator difficulty, then the
CVP comparison, semantic realization and one merged §5 on observations and
recovery. §2.4 states the computational scope once; §6 concludes. The public
observation definition and CVP input comparison now state the actual
classifier/cochain pair rather than protocol artifact fields. All 106
displays, eleven proposition statements and eleven proofs are preserved;
ten other definitions are unchanged. All 46 parity targets remain once.
The 36-page PDF and five printed external references pass build/layout QA.
Seven Lean headers drop obsolete section-number references; exact non-comment
source in all 280 files is unchanged, so P301's proof-source checks remain
the retained mathematical evidence. The three-paper ownership is recorded
here and in the guides rather than repeated throughout Paper 1. New informal
material still needs fresh protected verification; public `66e1ad2` is unchanged.

**Abstract, semantic motivation and contribution grouping — 2026-11-09:**
P303 removes Paper 1's second abstract paragraph while preserving the first
exactly. Helfer's first-order homotopical logic now opens the motivation as
the original semantic source. The CVP bridge, hidden-operator obstruction and
integral cellular examples are grouped into one contribution item, reducing
the enumeration from six to four without changing mathematical claims.
The stated hypotheses, homological-fragment and security boundaries remain.
All body formulas, proposition/definition statements and proofs, the parity
table and Lean sources are unchanged. The 38-page PDF passes build and
render/layout QA. This remains a local revision, with the prior protected
preflight tied to public snapshot `66e1ad2`.

**Central parity table and bibliography reconciliation — 2026-11-09:** P302
moves Paper 1's implementation references out of its mathematical text. Its
38-page PDF now has a conclusion followed by one parity table: four canonical
object/definition rows, eight main-result groups (21 declarations), five
support groups (25 declarations), and three external-theorem/assumption/
contract rows. Formal boundaries follow in Appendix B. All 46 selected names
occur exactly once; the main body has no Lean file or declaration listings.
All formulas, propositions, definitions and proofs in §§1–6 are preserved,
and all 280 Lean files are byte-identical to `dddfdd2`. The checked P301
9,295-job/975-report proof state is retained without a redundant Lean rebuild.
The 28-source ledger now maps every source to its owning bibliography/key;
19 missing records were added. Paper 1 cites seven sources, including the two
new relevant comparisons; Paper 2/3 retain 42/16 records with candidate status
explicit. Paper 3's 31-page PDF and all thirteen cited bibliography entries
are unchanged. Current PDF/build/layout and bibliography checks pass. The
new informal material remains local and needs its own exact-commit protected
preflight; public `66e1ad2` and its report remain historical evidence.

**Revised local validation — 2026-11-09:** P301 validates the P300 scope
revision: the expanded build passes 9,295 jobs, including all fifteen default
roots and three Solution entries. All 975 fresh dependency reports are
standard-only (792 exact-three/183 subsets, 106 axiom-free), and every prior
975-set entry matches. Paper 1's 84 displays, 289 inline formulas, nine
proposition statements, eleven definitions and nine proofs in §§2–3 retain
exact bytes; Paper 3 §§2–6 and all nineteen §7 displays are preserved. The
37/31-page PDFs pass final render/layout QA. All three entry metadata source
links now identify the frozen manuscript commit `adfcc14`. These local
checks do not certify a new public commit: `66e1ad2` and its protected report
remain unchanged, and no intake or registration is authorized.

**Manuscript ownership revision — 2026-11-09:** P300 follows the established
split throughout the manuscripts and Lean documentation. Paper 1 now contains
HCP/Hodge/CVP foundations, the actual homological fragment and mathematical
observation/full-Plucker recovery boundaries. Paper 2 owns the concrete cochain
commitment, codec, visibility and protocol evidence construction. Paper 3 owns
quantitative RS, list/MCA and metric/radius comparisons using that same
construction. Necessary shared definitions are recalled with attribution;
protocol and coding developments are no longer repeated in Paper 1. Its
appendix is a selected 46-declaration crosswalk, rather than a global source
catalogue. Ninety-three Lean files have documentation-only changes; exact
non-comment bytes in all 280 Lean files match `b917cda`. The revised PDFs have
37/31 pages for Papers 1/3. These are local editorial revisions: the public
`66e1ad2` snapshot and its passing protected report remain unchanged. Fresh
exact-commit preflight is required for any revised public candidate. Intake and
registration remain deferred; current validation is recorded separately below.

**Completed native-metric follow-up — 2026-11-05 baseline:** the cochain,
plane and RS metrics remain separate. The explicit systematic modular profile
has actual cellular/integral validity, native-distance comparisons, a
capacity-far original payload and challenge analysis. Full Plucker recovery
and geometric/fixed-compression obstructions are proved. Its expanded/default
builds pass 9,253/9,248 jobs; its 139 selected declaration reports comprise
103 standard-only and 36 retaining existing native arithmetic certificates.
These counts precede the new semantic implementation.

**Concrete Helfer/HCP follow-up — 2026-11-06:** five modules now construct an
actual bounded-below cochain model with invariant homological closed tests,
a finite integral cellular family, actual HCP realization, operative-target
and discrete CVP joins, and conditional original-artifact/spectral adapters.
A weighted common-input example uses the actual integer encoders with
coefficients two/one and rules out one exact coefficient decoder. The selected
mathematical input is the existing `(class,b)` pair. This is not full Helfer
first-order semantics, infinite ephemeral generation or a privacy game;
full-storage-view compatibility remains conditional. P231--P236 and the
[central validation record](docs/MATH_STORAGE_VALIDATION.md) record the new
checks separately from P229's native baseline and P230's preimplementation
object-accounting audit. The [Paper 2 draft](papers/paper2/DRAFT.md) records
protocol ownership; HC01--HC58 in the
[object crosswalk](docs/COCHAIN_PROXIMITY_TRACE.md#hcp-object-accounting-rotation-and-anonymity)
retain their IDs and updated construction boundaries.

**First public-observation profile — 2026-11-06:** the original payload and
derived public header, retained sealed-root/directory and explicit same-sample
HCP disclosure now have typed projections. Paper 2 §2.1 fixes their access
boundary. Public class announcements need not disclose `b`; metadata and all
released extensions still enter the actual security view. P237--P239 record
these scoped constructions and the pairwise equal-view recovery criterion.

**Recipient recovery and rotation — 2026-11-06:** actual integral
message/noise/sample transport, same-coefficient encoding, both recipient
recovery routes and original bound-HCP payload migration are now implemented.
The actual axis swap preserves coefficient two while moving `(1,2)` to `(2,1)`.
Private receipts index the real rotation/envelope and original contexts under
explicit authorization/channel contracts; scope equality authenticates no
caller and prevents no repeated valid request. P240--P245 record this step.

**Checked owned-resource transition — 2026-11-06:** `Protocol.Transfer`
now selects actual ownership/value/public input-ID nullifiers and derives the
existing candidate/update from component checks. Exact typed intent, metadata,
bytes and trusted decoder precede the original evidence/manifest/history
handoff and optional complete-proposal quorum. Hash preimages follow an
explicit acyclic order. Secure primitives, authentic prior-state origin,
wire/runtime refinement and finality remain contracts. P246--P252 record it.

**One-shot sampled integrity — 2026-11-06:** the same packet and transfer
checks now have a soundness-free operational layer. Local authorization and
original-context acceptance derive validity; accepted-invalid outcomes imply
an actual authorization or payload-verification failure. A shared-PMF union
bound composes supplied error budgets without independence. The released
packet/proposal/input-manifest projection exposes public IDs directly. This
is a fixed-setup one-attempt integrity experiment, not primitive unforgeability,
full-view privacy or an adaptive protocol-security proof. P253--P257 record it.

**Actual primitive and TCB comparison — 2026-11-07:** byte-level backends,
owner/key/message/query history and backend-to-original-statement refinement
are now explicit. The accepted-invalid event splits into fresh-message forgery,
key compromise, queried-message authorization mismatch, proof-backend false
acceptance and statement mismatch. The existing worker spectral signatures and
sampled-matrix verifier do not instantiate original owner-intent authorization
or trusted-decoder payload acceptance. A concrete modular graph-incidence
counterexample preserves the existing full payload while changing its message.
Legacy semantic TCB carriers are documented as packaging supplied truth, not
as concrete verifier proofs. P258--P262 and Paper 2 §6.4 record this step.

**Existing-object owner-signing wiring — 2026-11-07:** the inventory reuses
the owned catalog, complete intent/metadata, packet codec, `keyFor`, byte query
history and actual release carrier. It distinguishes public identity/context
handles, geometric rotation, logical signatures and validator registries from
owner signing authority. Domain-prefixed encoding of an existing empty-output
packet reflects the full subject. Typed authorized issues and out-of-domain
foreign queries construct the actual byte history; queried-but-unauthorized
intents are excluded under the same fixed policy. The signature checker/profile
are constructed from the selected backend, and a matching checked release can
be covered with its exact signature and independent authorization. The supplied
codec, authentic keys, full-history provenance and numerical crypto remain
contracts. P263--P268 and Paper 2 §6.5 record this bounded step.

The [recovered-plan table](docs/PROTOCOL_PARITY_QUEUE.md#recovered-native-authentication-plan-and-existing-primitive-layer--2026-11-07)
retains the original native path-space signing goal and distinguishes existing
typed Hodge blinding from security assumptions and archived Python primitives.
The generic checker/history construction selects no Ed25519 owner scheme or
central credential issuer. The intended native verifier reuses the actual
representative/path/admissibility setup, with authenticated designated-owner
binding and a message-bound knowledge/possession proof; mere class or path
existence is not that security theorem.

**Native path/witness reuse — 2026-11-07:** a supplied path realization now
constructs the existing `FiberSystem` and `EphemeralRotation` with the same
transport, harmonic projection and coefficient-recovery laws. A partial finite
decoder retains the actual base, credential opening and original admissible
path; the native adapter feeds original owner-signature bytes to the existing
proof backend on its key/full-message input. Encoder and backend-statement
reflection remain explicit premises, and witness existence supplies no knowledge
or unforgeability theorem. The duplicate codec-injectivity proof and stale plan
for replacement representative/family types are pruned. H62--H64, D38--D39,
P269--P272 and Paper 2 §6.6 record these joins and retained obligations.

**Native retrieval and concrete outer codec — 2026-11-08:** actual
`HodgeNoise` openings construct each query sample; the server's integer sum is
exactly an original encryption observation, with separately combined exact
and coexact openings. The original decoder and discrete-CVP comparison apply
to that same answer. A separate joint-view obstruction has an explicit
noise-column redundancy hypothesis, instantiated by the actual axis family;
it does not strengthen the fixed-input HCP oracle theorem into sampled secrecy.
Full-ciphertext hash lookup feeds original bound-HCP recipient recovery, with
an actual collision alternative. Whole-bucket reads provide an O(N) private
reference within a fixed public scope. The credential/full-message outer codec
is now concrete; finite typed packets, full ciphertexts, private witnesses and
native authentication security remain open. H65--H70, D40--D42 and P274--P280
record these distinct results. The [source ledger](docs/SOURCE_LEDGER.md) and
[three-paper completion checkpoint](docs/PAPER_OUTLINE.md#source-based-completion-checkpoint--2026-11-08)
record reviewed sources and the next mathematical/editorial work.

**Paper 1 public preflight — 2026-11-09:** P298 publishes only the approved
Paper 1 snapshot `66e1ad2` and starts protected run 42729947447. P299 records
the passing complete mechanical report, with Lean/NanoDa/con-ron acceptance.
The user explicitly deferred submission;
no Palomar intake, editorial review or registration was requested. Paper 2
and Paper 3 retain their existing ownership and remain outside this first
public snapshot.

**Paper 1 first release — 2026-11-09:** P296--P297 prioritize its selected
eight-group submission without changing the three-paper split. The final
101-page manuscript foregrounds the constructed ambiguity examples and
states the finite signed-incidence model, source comparisons and legacy
likelihood/nullity boundaries explicitly. All Lean statements and 279 source
hashes are unchanged. Paper 2 remains protocol/cochains/commitments;
Paper 3 remains proximity, with its technical core/bridge configurations.
Publication and protected verification are recorded separately from local QA.

**Slim entry packages — 2026-11-09:** P294--P295 record three independently
scoped packages with exact proof closures (31/35/81 local modules). Generated
Solution defaults and separate Challenges build with existing pinned caches;
all three pass the exact upstream metadata contract. No Lean source or pin
changes. The [release guide](docs/PALOMAR_SLIM_RELEASES.md) separates these
local checks from publication and protected verification. At that checkpoint no
publication occurred; P298--P299 subsequently publish and verify Paper 1 only.
Registry intake and registration remain explicitly deferred.

**Paper 3 independent entries — 2026-11-09:** P292--P293 cover the coding
and original-cochain companion configurations. Both pass full local definition
comparison and Lean/NanoDa replay. All 975 selected reports are standard-only
(792 exact-three/183 subsets); all 946 prior sets match. Expanded/default
builds pass 9,295/9,285 jobs. Static coverage is 279 modules/280 files, with
96 deliberate Challenge placeholders and zero implementation holes. The
encoder/opening values remain definitionally equal to their prior formulas.
The slim-package milestone above follows these checks; protected Linux
preflight and publication remain separate.

**Preserved Paper 1 entry baseline — 2026-11-09:** P290--P291 record the completed
Mathlib-only statement/proof entry, local Comparator/Lean/NanoDa checks and
946 standard-only reports. All 900 preceding dependency sets and 273 owner
hashes are retained. Expanded/default builds pass 9,293/9,285 jobs; static
coverage is 275 modules/276 files, with 23 intentional Challenge placeholders
and zero implementation holes. Protected Linux preflight and a frozen slim
release remained separate at that milestone; Paper 3's subsequent checks are recorded above.

**Preserved manuscript-selection/kernel baseline — 2026-11-08:** the selected
Paper 1 core follows its named CVP/HCP propositions; Paper 3 retains all nine
coding statement groups and the bounded modular application. The Hodge
uniqueness companion closes D43. At that milestone, expanded/default builds passed
**9,292/9,285 jobs**; **900 selected reports are standard-only** (724 exact-three,
176 subsets). All 806 previous standard sets match; all 49 previous native
reports are now standard-only. No active native_decide calls remain, and the
same seven cited axioms stay isolated outside these reports. Static coverage
remains 273 modules/274 files; all 48 scoped closures are unchanged. P286--P289
and the [central validation record](docs/MATH_STORAGE_VALIDATION.md#selected-statements-and-kernel-arithmetic--2026-11-08)
record that source/claim baseline. Paper 1's subsequent entry checks are
recorded above; protected comparison remains pending.

**Strict canonical decision profile — 2026-11-08:** D03 now selects
`(ε,δ_J,ε,δ_J)`, with concrete near `2046/4096` and unchanged far/list/MCA
radius `2047/4096`. The existing strict views retain the original map and
correct-solver pullback. The geometric far witness remains conditional.
P282--P283 record the construction and trust split. P280 is the preceding
retrieval/codec checkpoint and P281 its subsequent observation-wording step.

At the P283 strict-profile checkpoint, expanded/default builds passed **9,292/9,285 jobs**. The then-consolidated
probe passed **855 selected reports**: 806 standard-only (630 exact-three,
176 subsets) and 49 retaining existing native certificates. All 839 preceding
sets are unchanged. The sixteen additions comprise three standard-only
rational arithmetic reports and thirteen canonical adapters inheriting
existing native trust; no new axiom/native-decision declaration is added.
Static coverage remains 273 public modules/274 Lean files, no active
holes/cycles/unresolved imports and the same seven isolated cited axioms.
All 48 scoped closures excluded `Chain`/`CitedBounds`. P284--P285 record the
subsequent Paper 3 manuscript/source comparison. The later kernel arithmetic
and Hodge-uniqueness changes supersede P283 as a source snapshot; their new
validation is recorded separately below.

At the preceding primitive-comparison milestone, expanded/default builds pass **9,281/9,274 jobs**. The fresh
seven-facade audit covers **667 selected reports**: 631 standard-only
(537 exact-three, 94 subsets) and 36 existing-native. All 62 additions are
standard-only (29 exact-three, 11 axiom-free, 22 proper nonempty subsets);
all 605 preceding dependency sets are unchanged. Static scan: 262 modules/
263 files, no holes/cycles/unresolved imports, same seven isolated axioms and
35 scoped closures excluding legacy `Chain` and `CitedBounds`.

At the preceding one-shot integrity milestone, expanded/default builds pass **9,278/9,271 jobs**. The fresh
seven-facade probe passes **605 selected reports**: 569 standard-only
(508 exact standard-three sets, 61 subsets), and 36 old-native reports.
All 105 additions are standard-only (79 exact-three, 24 axiom-free, two
nonempty subsets); all 500 preceding sets are unchanged. Static coverage is
259 source modules/260 Lean files, with 32 recorded focused closures excluding
legacy `Chain` and `CitedBounds`. P257 records these checks.

The preceding owned-transition expanded/default builds pass **9,274/9,267 jobs**. A fresh
public-facade probe passes **500 distinct selected reports**: 464 standard-only
(429 exact standard-three sets and 35 subsets), and 36 retaining only old
native arithmetic certificates. All 145 additions are standard-only; the 355
preceding dependency sets are unchanged. No selected report uses a cited-bound
axiom or `sorryAx`.

This is the shared register for manuscript ownership, notation, and issues
across the three papers. It follows the object/claim/status
separation used in the Jacobian project's `SEMANTIC-PARITY.md`. A paper split
does not create a second mathematical object or prove a missing comparison.

The detailed coding inventory remains in
[the proximity parity register](papers/proximity-prize/SEMANTIC_PARITY.md):
its O01--O40 core object IDs and T01--T20 claim IDs are reused here rather than
renumbered or assigned different proof statuses. The current Paper 1 appendices retain only the selected mathematical
statement crosswalk and its formal boundaries; earlier global ledgers are
preserved in Git history. Build, source and dependency
checks are recorded per toolchain below; they do not prove the open
application bridge.

## Current working status

This table separates the current sources from their last completed validation.
The main Lean/Mathlib upgrade was explicitly authorized after the successful
history-anchor baseline.

| Item | Current source / decision | Validation and remaining boundary |
|---|---|---|
| Toolchain and dependencies | Lean `v4.35.0`; Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679`; pins unchanged. Static coverage: 279 modules/280 files; zero implementation holes, 96 deliberate placeholders in three independent Challenges; no cycles/unresolved imports or native calls. | **P301 fresh validation:** expanded union 9,295 jobs; 975 standard-only reports (792 exact-three/183 subsets), all 975 pre-revision sets unchanged. P293 retains the earlier literal-default 9,285-job record. Seven global cited axioms remain isolated; all 54 focused closures exclude Chain/CitedBounds. |
| History, snapshot and retained artifacts | Public block/event history references a snapshot-bound application sheaf and retained manifest; the StateBus is temporary processing state. `Storage.Anchor` and `ProjectionAnchor` join the same candidate, interpretation, original artifact, exact final prefix and actual gate database under explicit inclusion contracts. | Current-pin integration checks pass; the retained nineteen-endpoint standard-only anchor audit is recorded separately. P215--P216 retain the earlier milestone. Byte/hash/backend profiles, dynamic geometry and finality remain open. |
| Harmonic projection and metrics | Three native levels are retained. The actual modular source has `d_C ≤ d_P = D_RS ≤ 2d_C`, with factor two sharp for proper RS codes; the existing near projection uses `2d_C`, far calibration uses `d_C`. | Source/cell/payload compatibility and all-radius native comparisons are proved. Upstream Euclidean exactness, full-HCP residual and frame scores remain separate. The no-wrap Euclidean theorem is a first-shell result; a global zero-defect comparison is obstructed. |
| Plucker and possible moduli structure | Full concrete projective data now reconstruct the subspace/projector, identify genuine ranked points, and have constructive soundness. The raw quotient still contains the zero orbit. | H17 and D02 distinguish full data, a digest and identification with the operative kernel. No bundled projective variety or stack is asserted; visibility/security remains a separate profile. |
| Paper split and remaining mathematics | **P300:** Paper 1 owns HCP/Hodge/CVP, homological semantics and mathematical observation boundaries; Paper 2 owns cochain construction, codec/visibility and protocol contracts; Paper 3 owns quantitative coding and metric/radius analysis of the shared construction. | Scoped Q08 native-metric construction and capacity family now pass. Arbitrary HCP/frame score identification, protocol/security refinements and stronger geometric claims retain their stated boundaries. |
| Intended HCP and anonymity family | The five new modules construct the actual homological model, finite two-axis cellular/integral family, HCP realization and target/CVP joins. The actual gap one supplies a spectral gate; original artifact/snapshot contracts remain explicit. | The `(class,b)` and weighted integer-encoding examples are proved. Full first-order semantics/quotient, infinite generated family, transported protocol state, richer released-view compatibility and sampling/security games remain separate. |
| Palomar preparation | Three configurations cover two manuscripts: Paper 1 and Paper 3's coding/application entries, following the frozen Jacobian release. Both Paper 3 entries retain all fourteen selected groups. | **P292--P293:** all local definition comparisons and Lean/NanoDa replays pass, with fresh entry/combined axiom audits. P294--P295 prepare the three local slim closures. P298--P299 publish only Paper 1 and verify its exact public snapshot with the full protected pipeline, canonical provenance and Lean/NanoDa/con-ron acceptance. Paper 3 remains local. The user explicitly deferred registry intake and registration. |

The [active categorical map](docs/CATEGORICAL_ARCHITECTURE.md) records the
central projector and projective/moduli distinctions. The local working note
`docs/CHAIN_NETWORK_OBJECT_REVIEW.md` preserves the competing historical plans
and source readings outside the public subset. The numbered claims below
retain their existing IDs.

## Manuscript ownership and dependency table

The publication numbering, confirmed by the user on 2026-11-04, is:

| Paper | Manuscript / current artifact | Owns | Dependency |
|---|---|---|---|
| **1** | [Homotopical Encryption](papers/paper1/README.md); LaTeX and PDF | HCP/Hodge foundations, semantic classifiers, discrete CVP comparisons and the exact-component observation obstruction | Supplies the mathematical interfaces used by Paper 2. |
| **2** | [Proof-Carrying Homotopical Encryption](papers/paper2/README.md); [initial manuscript text](papers/paper2/DRAFT.md), scope and bibliography; no TeX/PDF bundle yet | Commitments/public observations, typed protocol evidence, accepted transitions, three native metric contracts, runtime and security boundaries | Must identify its concrete objects with the Paper 1 interfaces it claims to instantiate. Recommended first scope: [one proof-carrying transition](papers/paper2/SCOPE.md). |
| **3** | [Capacity-Radius Proximity](papers/proximity-prize/README.md); LaTeX, PDF, standalone Lean target | Universal RS/list/MCA results, radii and calibration, projective reconstruction/chain, and quantitative analysis of the declared original-cochain projection | Its coding proofs do not depend on finishing Paper 2. Q08 constructs the selected native modular profile and source-distance comparison; stronger geometric metrics remain separate. |

The earlier assignment of “Paper 3” to product/whitepaper material is
superseded. Product material is unnumbered future work. Keep the existing
directories and O/T IDs; numbering does not create a new mathematical object.

| ID | Material / canonical owner | Paper 1: HCP | Paper 2: protocol/cochains | Paper 3: proximity | Dependency / disposition |
|---|---|---|---|---|---|
| S01 | HCP, operative projection and Hodge decomposition; `HCP`, `Sheaf` | **Owns** foundations and recovery, §§2--3. | Uses the same Hodge objects in its protocol profile. | No HCP assumption in the universal coding theorems. | One mathematical object; no duplicate recovery contribution. |
| S02 | Public classifier, homological Helfer fragment, ambiguity and CVP; `HCP`, `Helfer`, `Hardness`, `CVP` | **Owns** semantic and exact-recovery arguments, §§2–3; Corollary 3.6 fixes the same rank-one oracle on both sides of the known-member/hidden-member separation. | Must account separately for its whole released view and any security experiment. | Independent coding hypotheses. | Exact non-identifiability is not an asymptotic hardness or privacy theorem. |
| S03 | Cochain payload, opening relation, visibility and security contracts; `Sheaf/Commitment`, `Axioms/CochainCommitment` | §§2.1–2.2 contain exact-cochain/full-sample, opening-quotient and observation facts. | **Owns** construction, encoding, visibility, aggregation and supplied security interfaces; Draft §§2--3. | Imports the original payload/profile in §7 to state quantitative claims. | Citations identify the shared carrier; no replacement commitment or duplicated security contribution. |
| S04 | Full Plucker data, cochain/plane extraction and metrics; `Proximity/Concrete` | No projective-coordinate construction or selected reconstruction target. | **Owns** payload realization, extraction/codec, visibility, snapshot and evidence contracts; consumes the reconstruction result. | **Owns** full-point subspace/projector reconstruction and projective chain (§7.1), plus quantitative source-to-code comparisons. | A digest is not a full point; real/full-HCP scores are not native modular distances. |
| S05 | Finite words, interleaving, Hamming metrics and MCA; `Proximity/Core`, `Proximity/MCA` | Cites the companion; no coding definitions or proofs developed. | Consumes the stated metric/challenge interface. | **Owns** definitions and universal coding presentation, §§2--3,6. | Minimal repeated notation is attributed; count and relative normalizations remain explicit. |
| S06 | Capacity-grid equality, next shell and fractional phase split; `Proximity/ListDecoding` | Outside the mathematical contribution. | References the quantitative theorem when its profile uses it. | **Owns** §§4--5, T02--T06 and the realized families. | No repeated coding proof or polynomial-list capacity claim. |
| S07 | Pair-MCA certificate bound, spectrum and attained-distance interpretation; `Proximity/MCA` | Outside the mathematical contribution. | Binds the pair/profile before sampling or supplies restricted-line goodness. | **Owns** §6, T07--T13 and T17--T19. | A universal bound is not an exact spectrum formula or a protocol security game. |
| S08 | Large-field, boundary-field and application-field roles | No numerical RS endpoint asserted. | Declares canonical wire-profile parameters when used. | **Owns** the large-field/boundary-field analysis and separate application-field limitations. | Keep field Q=3^n, boundary prime 2^128+192513 and wire q=12289 distinct. |
| S09 | Source validity and calibration; `Proximity/Application`, `Storage/Calibration` | Contains the mathematical observation limits; no source-to-code radius reduction is claimed. | **Owns** raw observation, validity, layout and consumption contracts. | **Owns** the native metric comparison and quantitative transfer statements, §7. | A source metric must be identified explicitly; an exact-only carrier supplies no nonempty far region. |
| S10 | Canonical 12289/4096/1024 and conditional bridge slots; `Proximity/Concrete/CanonicalRS` | The former numerical endpoint chapter is removed. | **Owns** the concrete encoder/context and uninstantiated evidence/profile obligations. | **Owns** metric normalization, numeric constraints and relevant comparison/obstruction. | Legacy conditional Johnson/far slots remain supporting implementation, not a newly proved HCP/geometric radius claim. |
| S11 | Gates, evidence, storage, transitions and runtime/security | Only states the observation boundary and cites Paper 2. | **Owns** the protocol construction and bounded conditional results; Draft §§3,6. | Uses explicit fixed-pair and projection hypotheses without constructing a protocol. | Paper 2 remains a working manuscript; primitive security, implementation and finality are not inferred. |

The dependency is therefore: Paper 1 supplies HCP foundations and observation
limits; Paper 2 constructs the concrete profile; Paper 3 proves its declared
quantitative coding and metric claims. Shared definitions are intentional and
attributed. The protocol, coding and gate developments are not repeated as
Paper 1 contributions.
The [actual-object trace](docs/COCHAIN_PROXIMITY_TRACE.md) distinguishes one
commitment's two-coordinate pair from the affine line through two final
scalar outputs; these are different MCA specializations.

## Object and notation dictionary

Status axes are separate:

- **exact**: source inspection identifies the same object or a proved claim
  with its actual hypotheses;
- **parameterized**: a construction or conclusion takes an explicit input;
- **missing**: a claimed endpoint or required construction is not supplied;
- **not identified**: two objects are present without a proved comparison.

An assumption interface is **parameterized**, not a proved security theorem.
Editorial disposition is recorded separately as **corrected**, **retain**, or
**open**. Older compatibility declarations are retained; this review deletes
no mathematical objects.

| ID | Manuscript notation / semantic role | Canonical Lean owner | Identity, hypotheses, and guardrail | Paper owner |
|---|---|---|---|---|
| H01 | `x`, `α=π(x)`, `A_α=π⁻¹(α)` | `HCPBridge.Realization`, `Observation`, `HiddenHodgeWitness`; `lean/HCP.lean`, `HCP/AxisFamily.lean` | **Generic interface; finite realization constructed.** On the admitted axis family, `semanticEquivalence_all` and `theory_eq_iff_homotopyEquivalent` identify one actual typed homotopy class. The public value does not select its operative representative or embedded kernel. `ReflectsHomotopyEquivalence` explicitly supplies completeness; with invariance the generic API identifies the existing public fiber with the declared semantic class. | HCP §§2,3.5 |
| H02 | `(α,b)` and `h_x(b)=P_{ker Δ_x}b` | `HCPBridge.Observation`, `operativeTarget`, `SolverExactOnOperativeTarget` | **exact** vector-level target. A commitment/proof about `b` is **not identified** with public access to the vector. | HCP §2 |
| H03 | `δ₀`, `δ₁`, `Δ₁=δ₀δ₀*+δ₁*δ₁` | `Sheaf.CellularSheaf.delta0`, `delta1`, `degreeOneLaplacian` | **exact** construction in the declared algebraic finite signed-incidence model. Restriction data include both adjacent degrees; a regular CW/simplicial realization is not supplied for every base. | HCP §§2,3.5 |
| H04 | `P_H`, locally `P_{H_x}`, harmonic projection | `Sheaf.CellularSheaf.harmonicOneProjection`, `HodgeEncryptedCochain.harmonicOneProjection_observed`, `HCP.operativeHarmonicComponent`, `HCPBridge.operativeTarget`; `Laplacian.harmonicProjection` | **exact** recovery/retraction in the appropriate model and the central operative HCP target. Use `P`, reserving `π` for classifiers/extraction. An abstract subspace still needs identification with the operative kernel. Projection alone loses the orthogonal coordinate; the full Hodge splitting retains it. | HCP §§1--3 |
| H05 | `Δ_W=I-P_W`, residual `ρ_W(b)` | `lean/Laplacian/{Projection,Hodge}.lean` | **exact** projection model. Same kernel as a cellular Laplacian does not imply the same operator or positive spectrum. | HCP §§2--3 |
| H06 | `b=h+e`, `H×H⊥ ≃ C¹` | `HCP.hodgeDecompositionEquiv`, `decrypt_encrypt`; `Hodge_Decomposition_Theorem`, `Hodge_Decomposition_unique` | **exact** correctness and orthogonal decomposition. The full message/noise pair is the bijection's source; no distributional secrecy follows. | HCP §2 |
| H07 | `M_x`, `Th(M_x)`, Helfer equivalence | `HomotopicalEncryption.Helfer.*`, `Helfer/CochainModel`, `HCP/AxisFamily` | **Generic invariance remains parameterized; selected fragment proved.** Nonzero-cohomology tests have actual quasi-isomorphism invariance for all interpretations. The finite classifier proves the optional reflection profile and uses the generic iff/class-fiber API to characterize typed equivalence on its admitted two-member family; presentation-level Delta1 is separate from those tests. Full Helfer first-order semantics remains outside this fragment. | HCP §§2.2,3.5 |
| H08 | Isometric transport `U₁`, fixed public coordinate `b` | `Sheaf.CellularSheaf.IsometricCochainEquiv`, `HCPBridge.IsometricPresentationEquivalence`, `FixedCoordinateNonstabilization` | **exact conditional** transport and separation. Transporting both presentation and observation preserves harmonicity; comparing one untransported `b` needs extra separation data. | HCP §2 |
| H09 | `V_B(R)` versus `Λ_B=Bℤⁿ` | `exists_matrix_ker_eq_range`, `CVP.ExplicitLattice`, `HarmonicCVPBridge` | **exact** distinct objects. An arbitrary-field linear kernel need not be a real self-adjoint Hodge operator. Projection preserves discrete CVP minimizers after the lattice and inclusion are supplied. | HCP §3 |
| H10 | `c=(q,n,c_edges,τ)`, decoded exact cochain | `Axioms.CochainCommitmentData`, `Sheaf.CellularSheaf.CochainPayloadInterpretation`, `AcceptedCommittedOneCochain` | Payload shape is **exact**; decoding/topology binding/exactness are **parameterized**. `c` names a payload here, not the HCP sample `b`. | Paper 2 construction; Paper 1 §2.1 uses the bare exact-cochain distinction |
| H11 | Opening `a`, equivalence modulo `ker δ₀` | `Sheaf.CellularSheaf.openingEquivalent_iff_sub_mem_ker` | **exact** quotient relation. Raw coboundary equality does not uniquely bind a degree-zero message. | Paper 1 §2.1 mathematical relation; Paper 2 opening/encoding contract |
| H12 | Blinded value `δ₀a+sH_τ`, MAC tag `P_H c(m,ν)` | `Axioms.BlindedCommittedCochain`, `BlindedCommitmentAxioms`, `CohomologicalMACAxioms` | Geometry is typed; hiding and unforgeability are **parameterized** security assumptions. Specify the MAC's cochain carrier separately from an exact payload. | Paper 2 §3.1; security remains an explicit contract |
| H13 | `Spec_multi(Δ_x)`, `FID(x)` | `lean/Laplacian/Spectral.lean` | **exact** spectral-class tag. Neither an injective representative ID nor the public classifier value; kernel dimension alone does not determine it. | Supporting spectral/tag vocabulary; Paper 2 profile, outside selected Paper 1 claims |
| H14 | `λ₁⁺`, spectral window, `Ω_k` | `Axioms.SpectralBounds`, `lean/Laplacian/Grassmannian/`, `Tsirelson.lean` | Window is **parameterized** admissibility. Projection-family gap `1` requires nonzero orthogonal complement. Infinite candidate families alone do not prove computational hardness. | Paper 2 spectral/admissibility contracts; supporting geometry is not an HCP hardness proof |
| H15 | `L_σ(b,A)`, classical guess, density strategy | `lean/Laplacian/Likelihood.lean` | Euclidean formula corresponds to `gaussianLikelihood_correct`. Legacy normalized-success functions use `gaussianLikelihood`; the integral endpoints are **not identified** with the corrected formula or an HCP recovery game. | Supporting research outside the selected manuscript claims |
| H16 | `Ω₃`, `q:Ω→Ω₃`, Heyting implication | `Axioms.Heyting`, `Axioms.OracleModality` | Finite algebra is **exact**; public collapse is a supplied interface. Node actions are distinct from logical implication. Here `q` is a local collapse map; it is distinct from a field/modulus. | Paper 2 oracle/policy interface; not a Paper 1 theorem |
| H17 | Frame `𝓕`, projective coordinate `Pl(𝓕)` | `lean/Proximity/Concrete/GrassmannianPlucker.lean`, `Concrete` and `Reconstruction` | **Proved for the concrete full point:** exterior multiplication reconstructs the subspace; full-shadow equality iff the same ranked point; both former soundness inputs and the fixed-metric harmonic projector are constructed. Focused build and eight standard-only audits pass. Generic alternative framed systems retain their explicit soundness inputs; digest-only observations remain separate. | Paper 3 §7.1 reconstruction and projection chain; Paper 2 visibility |
| H18 | Source score `ρ(𝓕)`, local `d_L`, plane `d_P`, RS `D` | `lean/Proximity/Concrete/ProjectionChain/Core.lean`; `Application.Projection` | **parameterized** metrics and comparisons. `D≤d_P≤d_L≤ρ` is the near direction; it does not imply a far lower bound. `ρ_W(b)` is a separate vector residual. | Paper 3 quantitative interfaces; Paper 2 consumes declared metric contracts |
| H19 | `p_c` integer/semantic plane, scalar `Φ_*(p_c)` | `lean/Proximity/Concrete/CochainPlane/{Core,ReedSolomon}.lean` | **exact extraction**, **parameterized** alignment/distance control. Encoding `(x₀,x₁)↦x₀+g x₁ mod 12289` is lossy, unlike O10--O11's field-valued plane/pair equivalence. | Paper 2 codec/extraction; Paper 3 quantitative analysis |
| H20 | Stage, naturality, hard, and final certificates | `lean/Proximity/Concrete/Gates/{Stage,Final}.lean`, `GateEvidence.lean` | **exact conditional** composition. Naturality squares and local nondegeneracy are fields, not consequences of distance inequalities. Concrete far separation remains **parameterized**. | Paper 2 stage/evidence contracts; Paper 3 mathematical comparisons |
| H21 | Canonical `D(w)=min_c d_H(c,w)/4096` | `lean/Proximity/Concrete/CanonicalRS/Metric.lean`: `relativeHammingDistanceToCode` | **exact** relative metric and count-to-relative conversion. The absolute `hammingDistanceToCode` is a different function. | Paper 3 metrics; Paper 2 fixes its application parameters |
| H22 | Canonical `Bad_Γ(𝓕₁,𝓕₂)` and `τ_cit/card F` | `lean/Proximity/Concrete/CanonicalRS/{CitedBounds,MCA}.lean` | **parameterized** literature boundary. The error belongs to a line/pair fixed before the challenge; it is not an attribute of one scalar received word. | Paper 3 coding/literature boundary; Paper 2 binds the challenge experiment |
| H23 | Integral stalk lattices and exact-component/full-sample join | `Sheaf/{Integral,HarmonicLattice,HCPAxisFamily}`, `TCB/{HCPObservation,HCPRealization,HCPAxisFamily}` | **Concrete finite algebra and conditional original-artifact bridge.** Standard stalk lattices, a harmonic lattice presentation and actual Hodge samples are constructed. Actual operator/classifier alignment derives the same hidden witness, operative message and CVP target. `bindSample` retains an existing artifact with supplied acceptance, decode-zero and envelope proofs; hashes/snapshots/full-view equality are not manufactured. | Paper 1 algebra; Paper 2 profile |
| H24 | Decoded exact-cochain distance `ρ_ex` | `lean/Sheaf/Distance.lean`; `Protocol/Storage/Context.lean` | **exact** Euclidean residual to `im δ₀`, nonnegative and 1-Lipschitz. In a shape/snapshot-bound context its zero locus is actual exact-payload acceptance. This is distinct from the full HCP residual and pair Hamming distance. | Paper 1 geometry; Paper 2 storage; Paper 3 comparison |
| H25 | Concrete/legacy cochain interpretation | `lean/Sheaf/CochainSemantics.lean` | **exact conditional** transport via carrier equivalences, actual coboundary/decoder commutation and binding equivalence; acceptance equivalence is derived. Ambient legacy gates remain explicit. No norm isometry is inferred. | Paper 2 concrete interpretation; Paper 1 supplies cochain geometry |
| H26 | Full-HCP residual versus exact-component view | `lean/Sheaf/ObservationQuotient.lean` | **proved obstruction**: a nonzero allowed coexact direction yields unbounded residual with fixed exact component. An exact-component-only extraction with zero-distance zero image cannot preserve a positive far region on the unrestricted Hodge carrier. This does not prove raw-byte factorization or exclude a restricted authenticated profile. | Paper 1; cited by Paper 3 §7 |
| H27 | Raw projective quotient versus Grassmannian locus | `GrassmannianPlucker.Concrete.ProjectiveShadow`, `projectiveFramedSystem`, `ValidRawCoordinate` | **exact carrier**, **parameterized validity**. The quotient includes the zero orbit; concrete `Normalized` and `SupportAdmissible` are `True`, so `ValidShadow` alone does not enforce the nonzero decomposable locus. The hashed-shadow semantic record retains both shadow and digest. | Paper 3 reconstruction/comparison; Paper 2 visibility |
| H28 | Presentation groupoid/moduli stack | Existing same-base sheaf morphisms, isometric cochain transport, classifier fibers and categorical interfaces | **Prospective, not constructed.** Choose the site/base, morphisms, automorphisms, transport and descent. General basis changes need transported metrics; the current Hodge covariance theorem assumes isometry. A set quotient or classifier fiber alone is not a stack. | Paper 1 organization; Paper 2 profile |
| H29 | Named axiom-interface contracts versus concrete proofs | `Axioms.lean`, `Axioms/{Foundation,SheafCoherence,Fibration,HomotopyClass,HelferFOL,Grassmannian,OracleModality,CochainCommitment}` | **parameterized** interface fields are explicit inputs, not global Lean axioms or constructed algorithms. Concrete cellular/Hodge results live in `Sheaf/`. The seven global project axioms remain isolated in the existing concrete cited-bound module and outside the focused closures. | Shared foundations and boundaries |
| H30 | Three native chain metrics `d_C`, `d_P`, `D_RS` | `Core/InterleavedMetric`, `Sheaf/SystematicCode/Modular`, `Storage/ThreeLevelMetrics`; [Paper 2 draft](papers/paper2/DRAFT.md) | Modular validity is defined by an actual integral cellular coboundary plus `q`-carry, then proved equivalent to RS validity. Scalar edits normalize by `2n`, whole-pair edits by `n`; focused proofs give `d_C ≤ d_P = D_RS ≤ 2d_C`. They do not redefine real decoded exactness or full-HCP/frame scores. | Paper 2 contracts; Paper 3 quantitative analysis |
| H31 | Helfer semantic carrier versus public fiber | `Helfer/{Signature,HomotopyEquivalence,Invariance,CochainModel}`, `HCP/AxisFamily`; HC01--HC07 | **Actual homological model/fragment constructed.** The cellular three-term complex lives in Mathlib’s real-module Quillen model; bifibrancy and strict/isometric-to-typed equivalence are proved. Closed nonzero-homology tests have proved invariance. General formula syntax, full fibrational semantics and relation laws/setoid/quotient remain separate. | Paper 1 |
| H32 | Integral harmonic messages and allowed structured noise | `Sheaf/{Integral,HarmonicLattice,HCPAxisFamily}`, `HCP/AxisFamily`; HC11--HC15 | **Generic carrier and concrete finite samples.** The family constructs `IntegralStructure` and rank-one `HarmonicLatticePresentation`, with integral messages and specified coexact noise. Generic openings are arbitrary real cochains without a sampler or bound. Integer systematic modular openings remain a different construction. | Paper 1 objects; Paper 2 profile |
| H33 | Gate-admissible HCP observation and artifact boundary | `HCP/AxisFamily`, `TCB/{HCPRealization,HCPAxisFamily}`, existing gates; HC17--HC35 | **Scoped actual joins constructed.** The finite family identifies true cellular matrices, classifier and targets; the actual positive spectral gap one meets the declared window. Original bound-observation alignment retains supplied artifact/snapshot contracts. Full frame/projection/far/runtime/history instantiation and larger-view equality remain separate. | Papers 1--2 |
| H34 | Rotation correctness versus fixed-observation ambiguity | `Sheaf.Rotation`, `HarmonicLatticePresentation.decodeCoefficients`, `Protocol.Ephemeral.PresentedRotation`, `HCP.AxisRotation`; HC16, HC39--HC44 | **Actual integral and encoded rotation constructed.** Transport carries message, both real noise openings and observed cochain; inverse/composition and projection laws are derived. A separate all-coefficient encoding law preserves semantic plaintext. The actual axis swap proves it: `(1,2)` rotates to `(2,1)` while retaining coefficient two. This is distinct from fixed-input two/one ambiguity and is not a privacy game. | Paper 1 geometry; Paper 2 recovery profile |
| H35 | Ephemeral representatives and anonymity | `Axioms.EphemeralFiberSpec`, `Protocol.Ephemeral.{EphemeralRotation,RecoveryDelivery}`, [active plan](docs/PROTOCOL_PARITY_QUEUE.md#priority-1--ephemeral-representative-and-anonymity-flow) | **Actual recovery and typed endpoint join; generation remains separate.** The legacy path-respect law preserves its classifier. An actual rotation/encoding is additional data with the same family endpoints, not inferred from a path or class label. Fresh indexed generation, infinite-family membership, lifecycle, authenticated channel implementation and privacy games remain open. | Paper 1 family; Paper 2 experiment |
| H36 | Actual encoded-message obstruction at one public input | `HCP.AxisFamily.weightedSample`, `weighted_cvp_solution_iff_operativeTarget`, `no_exact_encoded_message_decoder`; HC43 | **Finite exact counterexample.** Actual rank-one lattice encryptions with integer coefficients two/one share `(class,b)` with raw `b=(1,2)` and exact component zero; no single exact integer decoder handles both. This is stronger than differing ambient targets but is not distributional plaintext hiding or equality of full public storage views. | Paper 1 mathematics; Paper 2 security profile |
| H37 | Base public storage input versus explicit HCP disclosure | `Storage.PublicPayloadView`, `Context.publicView`, `HCPDisclosure`, `hcpDisclosure`; [PublicView](lean/Protocol/Storage/PublicView.lean) | **Constructed semantic projections.** Base release is the same original payload plus all six existing context-key fields. The explicit disclosure adds the same bound sample's `(class,b)`; it is not extracted from residue bytes. Actual header/payload equality is required for equal base views; distinct public parameters can distinguish disclosures with the same HCP pair. | Paper 2 §2.1 |
| H38 | Retained public manifest directory | `Storage.PublicManifestView`, `SealedManifest.publicView`; [PublicView](lean/Protocol/Storage/PublicView.lean) | **Constructed projection of the original seal.** Retains the same base view, sealed root and ordered `(slot,digest)` directory, with actual slot order/uniqueness. Semantic checkpoint payloads are omitted; public leaf openings, proofs and history roots are separately released extensions. Neither omission nor digest binding proves hiding. | Paper 2 §2.1 |
| H39 | Semantic integer plaintext and partial recipient decoder | `Sheaf.CoefficientRecovery`, `HarmonicLatticePresentation.point_injective`, `decodeCoefficients_eq_some_iff` | **Constructed exact decoder.** It reads the observed cochain, projects with the private Hodge presentation and uniquely inverts the chosen lattice encoding, returning `none` outside its range. Full real span need not cover the whole intrinsic integral lattice. Classical/noncomputable; no efficient byte algorithm is claimed. | Paper 2 §6.1 |
| H40 | Integral transport of the actual Hodge sample | `Sheaf.Rotation`, `IntegralCochainEquiv`, `transportNoise`, `transportSample` | **Derived transport.** Actual degreewise chain isometries plus an explicit degree-one integral law give harmonic-lattice equivalence, exact/coexact/message/observation transport and inverse/composition. Real isometry alone proves no integral-lattice or native Hamming-metric preservation. | Shared geometry; Paper 2 profile |
| H41 | Presented rotation and private recipient receipt | `Protocol.Ephemeral.{PresentedRotation,DeliveryScope,DeliveryContract,RecoveryDelivery}`, [axis receipt fixture](lean/Protocol/Ephemeral/Examples.lean) | **Same-plaintext recovery under explicit channel contracts.** Direct target decoding and inverse/base-key decoding return the same integer coefficients. Actual recipient, epoch labels, derived source/target context identifiers, private rotation and envelope index authorization/delivery. Whole-scope mismatch rejects; matching labels authenticate no caller and prevent no repeated valid request. | Paper 2 §6.1 |
| H42 | Original bound-sample and payload migration | `Protocol.Ephemeral.{PayloadRotation,BoundSampleRotation,bindRotatedSample}` | **Actual-object join.** Full-sample transport between existing bound HCP records derives the original decoder/transport equation from their decoded-exact-component fields. The generic equation transfers exact acceptance; both recovery routes require the actual source message in the chosen presentation. The constructor retains supplied target artifact and bindings. No root/class/public-view equality, atomic migration or erasure is inferred. | Paper 2 §6.1 |
| H43 | Owned resource, asset value and public spend identifier | `Ledger.OwnedResource.{Catalog,Transfer,Checks,InventoryInvariant}` | **Bounded concrete profile.** Immutable owner/asset/positive amount, one consumed ID and distinct absent/unspent output with the same asset/value. Nullifiers are exactly the input ID. Actual updates preserve value and unit/spent inventory laws; the mechanical fixture has value seven. Public IDs are not an anonymous nullifier scheme. Catalog values are not cochain coordinates, harmonic coefficients or geometric scores. | Paper 2 §6.2 |
| H44 | Owner-authorized intent versus final proposal | `Evidence.TransferTranscript.{Intent,ProposalDraft,ProofMetadata,ProofPacket}` | **Typed staged data.** Owner authorization covers schema/statement/policy domain, exact transfer and original public input, source historical evidence root, draft parent/content roots and manifest root. The complete packet adds actual signature/proof bytes and verifier selection. A final quorum signs the completed whole proposal after evidence/block construction; owner signing does not contain those later fields. | Paper 2 §6.2 |
| H45 | State content and acyclic root roles | `TransferTranscript.{StateContent,ManifestPreimage,BlockPreimage,HashSuite}` | **Computed preimages and reconstruction.** Content omits tip/evidence; source parent and historical evidence root occur in the intent, target omitted fields occur in the completed proposal. Payload leaf, enclosing cochain root, input manifest, packet evidence and block domains remain separate. No preimage contains its enclosing digest; no global hash injectivity or digest inversion is asserted. | Paper 2 §6.2 |
| H46 | Actual byte checks and trusted decoder interpretation | `TransferVerifier.{PacketCodec,Authorization,PayloadVerifier,CheckedPacket}` | **Derived component facts.** Parse/canonical-byte/metadata/intent checks precede selected primitive Boolean verifiers. Payload soundness indexes the actual trusted interpretation and requires its equality to the original context; identical public names alone cannot identify arbitrary decoders. Candidate validity is not stored as a checked-packet premise. Codec and signature/proof implementations and soundness remain explicit contracts. | Paper 2 §6.2 |
| H47 | Original input seal and semantic TCB compatibility | `Storage.TransferManifest`, `Evidence.TransferEnvelope.Derivation` | **Actual objects retained.** One original payload/digest is sealed before later proof/block data. Already-derived validity and exact root joins are represented using the real candidate/transfer witness and projected-intent existential shadow, not a unit/always-valid fixture. This bridge supplies neither new verifier soundness nor six-stage gate completeness. Persistence requires an actual matching receipt. | Paper 2 §6.2 |
| H48 | Boolean transfer acceptance and computed update | `Transfer.Owned.{Config,Prechecks,CheckedTransfer,check_implies_accepted_update}` | **Concrete composition proved.** Resource checks and trusted-interpretation signature/payload results derive the existing `Candidate.Valid` and `AcceptedUpdate`. The action/snapshot are built from the original objects. Canonical parser evidence fixes one candidate/successor; conservation, input consumption, fresh output, conditional inventory preservation and replay rejection follow. The Boolean specification is noncomputable, not verified Rust. | Paper 2 §6.2 |
| H49 | Full-packet inclusion and exact final history/quorum | `Transfer.Anchored`, `CheckedTransfer.{packet_included,source_reconstruct,successor_reconstruct,anchor,certified}` | **Original-object endpoint.** Full typed proof packet determines the evidence preimage; its actual input manifest enters the block preimage. Existing evidence and history anchors retain the same candidate, context, artifact and computed successor. Optional quorum matches the complete proposal and acceptance judgment. Fixed snapshot/epoch, trusted state origin, primitive security, atomic persistence and consensus finality remain separate. | Paper 2 §6.2 |
| H50 | Operational algorithms versus ideal soundness | [TransferCheck](lean/Protocol/Evidence/TransferCheck.lean), `Transfer.Operational.Config`; exact `.operational` projections | **Same checks, weaker assumptions.** Raw signature/proof algorithms carry no universal soundness. Actual metadata/intent/canonical-byte checks remain. The exact verifier and transfer delegate to this shared checker; original context, interpretation, candidate and policy are retained. | Paper 2 §6.3 |
| H51 | Released owned-transfer record | [PublicTransferView](lean/Protocol/Transfer/PublicView.lean), `CheckedTransfer.publicView` | **Actual projection.** Canonical bytes, parsed packet, complete proposal and original one-input manifest base/root/directory. Explicit resource/signer IDs and metadata distinguish records directly. Public setup, catalog/prior-state access and external access metadata enter the experiment separately. This is not the entire network transcript or a hiding theorem. | Paper 2 §6.3 |
| H52 | Accepted-invalid outcome and primitive failure events | [Operational](lean/Protocol/Transfer/Operational.lean), `AcceptedInvalid`, `AuthorizationFailure`, `PayloadFailure` | **Pointwise reduction proved.** Actual checker success plus an invalid candidate from the actual parser implies authorization false acceptance or proof false acceptance for the exact expected intent and trusted original interpretation. No exact primitive soundness is assumed. An authorization failure is not automatically an EUF-CMA forgery. | Paper 2 §6.3 |
| H53 | One-shot sampled integrity and error budgets | [Security](lean/Protocol/Transfer/Security.lean), `Experiment`, `ofCheckedRelease` | **Conditional probability composition.** Explicit view, auxiliary data, PMF tape and adversary determine the same attempt for all three events. Bad-acceptance probability is at most the two failure probabilities, then their supplied bounds; independence is unnecessary. Actual checked releases have a named constructor. No primitive estimate, security parameter, efficiency, adaptive oracle or anonymity follows. | Paper 2 §6.3 |
| H54 | Actual byte-signature and proof backends | [TCB.PrimitiveChecks](lean/TCB/PrimitiveChecks.lean) | **Raw data-indexed checks.** Selected byte algorithms, proof statement on the exact input bytes, finite signing history and compromised-key predicate. Verification does not assume truth, zero knowledge or an error bound. Legacy proof carriers separately package already-established truth. | Paper 2 §6.4 |
| H55 | Owner/key/message/history authorization join | `Transfer.Primitives.SignatureProfile`, `Forgery`, `CompromisedKey`, `QueriedUnauthorized` | **Explicit primitive reduction.** Actual owner-key map and signing bytes agree with the original raw checker. Unauthorized acceptance splits into fresh forgery, key compromise or queried-message policy/key/encoding mismatch. Applying a primitive game requires correct key setup and history covering all released/auxiliary honest signatures. Worker spectral signatures do not discharge this join. | Paper 2 §6.4 |
| H56 | Proof-backend statement versus original cochain acceptance | `Transfer.Primitives.PayloadProfile`, `ProofFalseAccept`, `StatementMismatch` | **Original interpretation retained.** Exact algorithm agreement on encoded original intent separates false backend statement from a true backend statement that fails to imply original-context acceptance. Five actual event masses compose under the existing PMF, without independence or a supplied concrete estimate. A sampled spectral predicate is not assumed to imply exactness. | Paper 2 §6.4 |
| H57 | Ordinary graph commitment and alternative modular openings | [Sheaf.GraphCommitment](lean/Sheaf/GraphCommitment.lean) | **Concrete ambiguity proved.** Ordered incidence coordinates and the existing full canonical payload are invariant under global stalk translation. At modulus 12289, `[3,5,9]` and `[10,12,16]` both produce `[2,4]` with different vertex-0 messages and well-formed payloads. Deterministic payload encoding/hash cannot repair that message binding. Scope is ordinary incidence, separate from private cellular restrictions, harmonic blinding or authenticated C¹ binding. | Paper 2 §6.4 |
| H58 | Full owner-intent signing subject | [Transfer.Signing](lean/Protocol/Transfer/Signing.lean) | **Existing schema reused.** Fixed owner prefix plus existing codec encoding of actual metadata/Intent with empty signature/proof outputs. Equal message bytes reflect full metadata and Intent; owner messages differ from spectral-domain messages. This is relative to a supplied roundtrip codec, not a concrete serializer or signature-security theorem. | Paper 2 §6.5 |
| H59 | Authorized issuance records and exact byte history | [Transfer.Issuance](lean/Protocol/Transfer/Issuance.lean), `Issued`, `history`, `Covers` | **Constructed data join.** Each record retains source metadata, actual Intent/signature and authorization for the signer inside that Intent. Its exact query projection plus foreign out-of-owner-domain messages forms the existing history. Full reflection derives the same actual authorization without key injectivity. Covers retains signature equality separately; query membership does not imply equal signature bytes. | Paper 2 §6.5 |
| H60 | Constructed owner checker and reduced error composition | [Transfer.Authorization](lean/Protocol/Transfer/Authorization.lean) | **Positive wiring.** Existing backend/keyFor and signing bytes construct raw verification; profile agreement is reflexive. Original context/intent/policy/candidate are retained. Under the exact typed/foreign history, queried-unauthorized mass is zero and four error masses remain. No secret signing, authentic registry, arbitrary-history coverage or numerical primitive estimate is inferred. | Paper 2 §6.5 |
| H61 | Actual matching release-signature coverage | `PublicTransferView.ofOperational`, `Authorization.issueOfChecked` | **Original bytes retained.** The old release carrier now also projects actual raw checks. A packet checked by the newly constructed checker, with independent semantic authorization, yields an issue record covering its exact metadata/intent/signature and proving backend verification for that subject. This does not reinterpret arbitrary old signatures or establish an oracle execution. | Paper 2 §6.5 |
| H62 | Realized path transport and harmonic recovery | [Ephemeral.Rotation](lean/Protocol/Ephemeral/Rotation.lean), `PresentedRotation.pathFiberSystem`, `EphemeralRotation.ofPath` | **Constructed under a selected realization.** A supplied path-to-presented-rotation map defines the existing FiberSystem; the stored rotation acts on exactly the same path. Harmonic projection, harmonic invariance and both coefficient recovery routes reuse the integral laws. No path realization, composition coherence or alignment of arbitrary old records is inferred. | Paper 2 §6.6 |
| H63 | Finite credential-opening/path witness | [Transfer.PathSignature](lean/Protocol/Transfer/PathSignature.lean), `WitnessRelation`, `rotationOfWitness` | **Restricted decoded relation.** Finite private bytes decode to the actual base, opening and original ephemeral spec, with explicit credential opening and admissibility. That same decoded path constructs the existing rotation and recovery. The decoder/opening scheme remain supplied; no total codec for arbitrary continuous witnesses or owner authentication is inferred. | Paper 2 §6.6 |
| H64 | Native proof execution through owner verification | `ProofVerifier.asSignatureVerifier`, `PathSignature.input_subject_eq`, `.checked_signature_verified` | **Exact algorithm join.** Original owner-signature bytes execute the selected proof backend on its key/full-message input. Injective public-input encoding reflects key, metadata and full Intent. Separately supplied backend-statement reflection yields a valid finite witness or actual false acceptance; existential truth does not establish message-bound knowledge or unforgeability. Original payload-proof semantics remain separate. | Paper 2 §6.6 |

| H65 | Concrete credential/full-message outer encoding | [PathSignature.Codec](lean/Protocol/Transfer/PathSignature/Codec.lean), `canonical_input_subject_eq` | **Concrete parser and framing.** Domain prefix, byte tags and delimiter give exact roundtrip, reencoding and injectivity; malformed/truncated/domain cases reject. Canonical input reflects the original key/full-message subject. Typed owner packets, full cochains and private witnesses need their own selected finite codecs. | Paper 2 §6.7 |
| H66 | Hash-addressed opaque ciphertext lookup | [ContentAddress](lean/Protocol/Storage/Retrieval/ContentAddress.lean), `readByDigest_complete`, `readByDigest_original_or_collision` | **Actual local algorithm.** Requested digest must be named in the existing public directory; downloaded bytes must actually hash to it. Original availability gives a result, and accepted bytes equal the original or exhibit a hash collision. Root/directory authentication and availability are separate inputs. | Paper 2 §6.7 |
| H67 | Native structured-noise query answer | [HodgeQuery](lean/Protocol/Storage/Retrieval/HodgeQuery.lean), `answer_eq_observed`, `decode_answer`, `cvp_answer_iff` | **Original object retained.** Samples use original H.encrypt/HodgeNoise. Integer-weighted server evaluation combines exact/coexact openings separately; the same full response is an actual encryption, is decoded by the original coefficient decoder and satisfies the existing discrete-CVP comparison. No selector-privacy claim follows. | Paper 2 §6.7 |
| H68 | Whole-bucket private-read reference | [UniformRead](lean/Protocol/Storage/Retrieval/UniformRead.lean), `transcript_eq`, `distribution_eq`, `event_probability_eq` | **Exact target privacy in fixed scope.** Same entire manifest/request and arbitrary server response with target-independent tape yield identical full transcripts and event masses. Reply downloads the whole bucket; selection/recovery stay local. Public bucket, identity, timing and later access-dependent actions are outside this theorem. | Paper 2 §6.7 |
| H69 | Conditional full-query disclosure | [LinearQueryObstruction](lean/Protocol/Storage/Retrieval/LinearQueryObstruction.lean), `essential_iff_selected`, `AxisExample.selected_is_publicly_identified` | **Joint-view limitation.** Under explicit redundancy of other noise columns, public span exclusion identifies the selected column. The concrete Fin3 fixture uses actual varying coexact HodgeNoise and the original axis sample. This is not a universal impossibility or an efficient sampler/security theorem. | Paper 2 §6.7 |
| H70 | Hash-checked original HCP recovery | [Retrieval.Recovery](lean/Protocol/Storage/Retrieval/Recovery.lean), `recoverByDigest_bound_observation_or_collision` | **Original-source join.** Full-ciphertext parsing plus the same BoundHCPObservation/BoundSampleRotation endpoints feeds existing recipient/context/epoch recovery. Correct coefficients or actual accepted colliding bytes follow under original availability/decoding and delivered-material contracts. | Paper 2 §6.7 |

## Definition, notation, and claim issue table

P0 affects the meaning of a main claim or interface; P1 affects completeness
or precision of its presentation; P2 is editorial. **Open** rows need explicit
mathematical or author decisions, rather than silent copyediting.

| ID / priority | Location / related objects | Finding | Disposition and required action |
|---|---|---|---|
| D01 / P0 | HCP §2; H02, H10, H23 | A decoded exact payload has `P_H δ₀a=0`, whereas HCP permits nonzero `h`. A proof about a vector also need not expose it. | **Manuscript distinction reconciled; application contracts remain.** Intro/§2 retain the separate full Hodge sample, supplied binding and operative alignment, and optional explicit disclosure. `BoundHCPObservation.toObservation` projects a record already containing that sample; it is not extraction from accepted payload bytes. Concrete full-sample public encoding/extraction and larger released-view compatibility remain profile obligations. P281 records the focused correspondence check. |
| D02 / P0 | Paper 3 §7.1; Paper 2 §2.1; H17, H37--H38 | A full Plücker point reveals `W`. If this is the operative kernel, public disclosure conflicts with withholding it. A digest alone is a different observation. | **First storage profile specified.** Paper 2 §2.1 publishes the original payload/header and retained root/directory; full operative Plücker coordinates remain outside the base release. Explicit HCP or local openings extend that view. A digest projection is distinct from the full hashed-shadow record. Concrete access control, bytes and security of all visible extensions remain obligations. |
| D03 / P0 | Paper 3 §7 calibration and canonical bridge; H18, H20 | Equal closed near/far thresholds can overlap at an attained boundary. The legacy calibration set all four radii to δ_J. | **Canonical decision convention resolved.** The selected calibration is `(ε,δ_J,ε,δ_J)` with `0≤ε<δ_J`; the concrete near radius is `2046/4096`, far remains `2047/4096`. Existing strict views prove disjointness and retain the original received-word map and correct-solver pullback. List/MCA radii are unchanged. The equal helper remains conditional compatibility packaging. Geometric far separation and efficient solver construction are separate obligations. P282 records the construction. |
| D04 / P1 | Paper 2 §6 projection certificates; H20 | Stage-certificate existence uses naturality squares and local nondegeneracy. The earlier prose displayed only alignment, codeword preservation, and distance control. | **Corrected presentation.** The stage definitions now explicitly include those supplied fields and display both restriction/syndrome squares. This adds no new proof of an application instance. |
| D05 / P0 | Former HCP §4 likelihoods; supporting development outside current Paper 1; H15 | An observation-dependent guess `span{b}` achieves likelihood `1`; averaging its likelihood is not the probability of recovering the operative kernel. A probability density is not itself a quantum computation model. | **Wording corrected; formal endpoint open.** Use likelihood-score terminology. Identify the corrected Euclidean integral and define a recovery experiment before claiming a quantitative classical/quantum security bound. |
| D06 / P1 | Protocol modular commitment; H10, H12, H23 | `δ₀a mod q` needs integral/finite-field carriers and compatible encoding; arbitrary real restrictions do not define reduction. | **Scoped modular profile and finite integral HCP family constructed.** P220--P228 give actual modular source/RS compatibility. P232 constructs restriction-preserving standard stalk lattices and a harmonic lattice presentation for the axis family. TCB binds existing payloads under supplied decoder/envelope contracts. Arbitrary HCP serializers, noise integrality and production bytes are not inferred. |
| D07 / P0 | Paper 2 §3.1 proposed MAC interface; H12 | If `c(m,ν)` is the same exact cochain used for raw commitments, its harmonic tag is zero. A verification equation alone is not an unforgeability theorem. | **Open instantiation; assumption wording corrected.** Give the MAC's cochain map and adversarial game in Paper 2; its construction and unforgeability remain explicit protocol/security obligations. No MAC result is part of current Paper 1. |
| D08 / P1 | HCP §3 complexity schema; H09 | Fixed dimensions, arbitrary real inputs, and an algorithm class do not yet specify an asymptotic bit-model hardness assumption. | **Open complexity refinement.** Supply encoded instance families, size/security parameter, success criterion, and oracle representation before a computational CVP-hardness claim. The current separation is an ambiguity obstruction. |
| D09 / P1 | Former HCP §4 Heyting collapse; deferred Paper 2 vocabulary; H16 | “Not assumed faithful” is followed by an existential collision, which actually assumes noninjectivity. The domain `Ω` is not described locally. | **Corrected.** Define `Ω` as the hidden truth-value carrier and explicitly assume the displayed nonfaithfulness. |
| D10 / P2 | HCP §§1--5; H03--H04, H14 | Projection notation alternated `π_H`/`P_H`; restriction chains omitted edge-to-face data; `W_t` differed from the declared `W(t)`; matrix example left `e_i` unbound. | **Corrected.** Use `P_H`, include face-to-coface maps, retain `W(t)`, and use `e₁` with the displayed diagonal. Normalize Plücker spelling and heading capitalization. |
| D11 / P1 | Former HCP §6 cited MCA theorem/corollary; canonical cited-bound interface; H22 | The cited-bound hypothesis was implicit, and the corollary assigned a pair/line bad-challenge fraction to a single word. | **Corrected.** Both statements explicitly assume the cited package; the corollary names the line formed with a second projected witness. No numerical security claim is added. This historical correction does not make current Paper 3's proved generic MCA theorem conditional on that separate cited package. |
| D12 / P1 | HCP appendices; H09 | Arbitrary-field linear kernels were called Hodge kernels; the matrix sanity example was mapped directly to the stronger typed HCP separation. | **Corrected.** Use “linear kernel” and identify the matrix example as a sanity example, retaining the typed theorem's additional hypotheses. |
| D13 / P1 | Historical HCP bibliography | One reference printed an internal “replace metadata” note; the survey citation used an old date and lacked its URL. | **Corrected.** Use the author-posted preprint's DOI/date and the ePrint survey's July revision metadata. Exact cited theorem specialization remains a separate review task. |
| D14 / P1 | Former HCP §4 spectral fingerprint; supporting interface; H13 | “A sheaf Laplacian is a self-adjoint PSD operator” can be read as asserting that every PSD operator comes from a cellular sheaf. | **Corrected.** Define the fingerprint for a finite-dimensional self-adjoint PSD operator, including a sheaf Laplacian; no cellular realization is inferred. |
| D15 / P1 | Projection-family spectral gap; H14 | The zero operator at `W=Rⁿ` has no nonzero eigenvalue, while the original final sentence described the whole family as having relative gap `1`. | **Corrected.** State the family conclusion for proper kernels `k<n`, as required by the preceding eigenvalue computation. |
| D16 / P1 | Paper 2 selective/vector opening contracts (formerly HCP §5) | A vertex-restricted opening gives both endpoint values only for an edge whose two endpoints are in the revealed set. “Every revealed incidence” did not fix this domain. | **Corrected.** Quantify the displayed edge equation over edges with both endpoints revealed. Boundary-edge verification needs additional authenticated data. |
| D17 / P2 | HCP PDF, long displayed lists and Lean ledgers | Several displayed prose lists exceeded the text width, and long Lean paths overflowed or stretched their lines. | **Corrected layout.** Convert prose lists to wrapping text, split equations, enable path breaks with `xurl`, and use consistent ragged-right Lean ledgers. |
| D18 / P1 | HCP cross-references throughout | Shared theorem counters made `cleveref` call definitions and propositions “Theorem,” including references to the public-observation definition. | **Corrected.** Use alias counters to preserve shared numbering while retaining each environment's actual reference type. |
| D19 / P0 | HCP full observation; H23--H26 | The exact-component storage view and full-HCP residual can forget different information. | **Mathematical obstruction proved.** The unrestricted coexact-ray theorem rules out factoring the full residual through the decoded exact component when a nonzero coexact direction is allowed. Identify the intended source/profile before a stronger original-HCP radius claim; raw serializer factorization remains explicit. |
| D20 / P0 | Storage and proximity source carrier | Requiring exact acceptance in every raw input would remove positive decoded-exactness farness. | **Interface separated.** `Storage.Context` requires shape/snapshot binding; `Accepted` is separate. The concrete fixture has a positive-distance nonexact raw input, without asserting a source-to-RS guarantee for that fixture. |
| D21 / P1 | Storage roots, stages and local lifecycle | Same-shaped hash names and slot presence do not identify prior mathematical artifacts or prove durability. | **Typed joins implemented.** Actual context/payload/digest-indexed relations, exact predecessor prefixes and exact sealed-manifest receipts are separate. Six manifest stages differ from seven legacy gate-evidence slots. Global run freshness, backend atomicity, root codecs and memory erasure remain profile/runtime work. |
| D22 / P1 | History entry to original snapshot/artifact and complete projection | Independent candidate validity and manifest sealing did not bind those actual objects together. | **Bounded semantic join implemented**, P215--P216. Actual interpretation/artifact equalities derive accepted context and snapshot/payload joins; supplied history/gate relations bind the exact manifest and gate database. The wire-field choice, concrete authentication, persistence implementation and dynamic geometry remain open. |
| D23 / P1 | H17, H27--H28; projective/stack terminology | The raw quotient contains zero and arbitrary exterior coordinates, while a projective Grassmannian point has additional validity conditions. A moduli analogy does not construct descent or metric transport. | **Definition boundary recorded.** Use the actual raw/frame/soundness predicates; distinguish classical reconstruction from its current Lean proof status. Keep stack packaging prospective and the public-point visibility decision explicit. |
| D24 / P1 | Lean/Mathlib version and validation | Older builds cannot certify later definitions or newly added modules. | **P293 current validation:** union/default 9,295/9,285 jobs; 975 standard-only reports, all 946 prior sets unchanged. Both Paper 3 comparisons and Lean/NanoDa replays pass locally; protected Linux verification remains separate. |
| D25 / P1 | Helfer/class construction; H31 | Typed equivalence needs actual bifibrancy; a classifier fiber does not define a quotient, and arbitrary supplied satisfaction has no automatic invariance. | **Homological fragment instantiated.** `CochainModel` constructs the real cochain model and proves invariance of nonzero-homology tests for all interpretations. Actual axis theories give its classifier. Full first-order syntax/fibrational semantics, full Theorem 12.3 and a general quotient remain open. |
| D26 / P0 | Intended HCP realization; H23, H33 | An arbitrary realized matrix is not automatically cellular Delta1; the small `(class,b)` observation forgets larger artifact fields. | **Scoped operator/target join closed; larger public-view condition retained.** P231--P234 construct actual cellular interpretation, matrices, classifier and operative targets. TCB alignment derives the same original sample’s target/CVP answer under explicit operator/classifier and artifact contracts. Storage-view equality or factorization, byte encodings and runtime realization remain additional obligations. |
| D27 / P0 | Structured noise, rotation and messages; H32, H34, H36 | Fixed-raw-`b` ambiguity and co-transported rotation have different data; equal or distinct ambient coordinates need an actual plaintext encoding. | **Finite ambiguity and coefficient-preserving rotation proved.** The fixed-input two/one example remains separate from actual axis rotation, which moves `(1,2)` to `(2,1)` and retains two. Integral sample transport, both recovery routes and conditional original-payload migration now have proofs. Fresh generation, channel security, atomic migration, lifecycle/erasure and distributional security remain separate. |
| D28 / P1 | Anonymity and ephemeral family; H35 | A same-class endpoint, infinite geometric candidate space or stable class tag does not specify a sampling/observation experiment. | **Recovered intent, not security completion.** Use the existing representative/path object; construct indexed generation and transport, one-fiber membership and lifecycle. State separately representative indistinguishability, plaintext hiding, account/sender anonymity, unlinkability and forward secrecy. Stable public account tags can link uses. |
| D29 / P0 | Paper 2 payload verifier; H46 | A verifier quantified over arbitrary interpretations sharing a public view can conflate incompatible decoders and become vacuous. | **Trusted interpretation fixed.** `PayloadVerifier` indexes the actual interpretation; accepting an original context requires literal interpretation equality plus exact base-view equality. The deployment must bind metadata to that implementation; names alone supply no decoder identity. |
| D30 / P0 | Paper 2 hash/signature dependency order; H44--H45 | Hashing/signing the complete proposal or full successor into its own block/evidence fields is cyclic; a content projection can also omit source historical evidence. | **Typed acyclic construction and reconstruction proved.** Owner signs the pre-proof intent. Source parent plus explicit old evidence root complete source content; final proposal coordinates complete target content. Packet evidence precedes block hashing, and each preimage excludes its own root. Cryptographic codec/domain separation/binding and prior-state authenticity remain contracts. |
| D31 / P1 | Paper 2 ownership/value/nullifier interpretation; H43, H48 | Generic conservative flow and arbitrary body nullifiers did not select a concrete owner/value/spend profile. | **Bounded public-ID profile selected.** Actual owned catalog, input-derived nullifier, absent/unspent output and positive value are implemented, with independent checks yielding the existing update. This does not instantiate anonymous nullifiers, economic value as a Hodge quantity, splitting/fees, secure primitives or a global ledger architecture. |
| D32 / P1 | Paper 2 §6.3; H50--H53 | A security experiment over globally exact-sound verifier records would rule out its bad event by assumption and could not justify a nonzero primitive error bound. | **Resolved for one-shot integrity.** Shared soundness-free packet/transfer checks, local semantic good facts, actual parsed-candidate bad event and PMF union bound are implemented. Exact contracts are the ideal specialization. Primitive estimates, adaptive signing/corruption games and runtime/state-origin/finality security remain open. |
| D33 / P1 | Paper 2 owner authorization; H54--H55 | Available Rust Ed25519 signs 69 bytes of worker spectral fields; bootstrap keys derive from a public fingerprint. These facts do not establish owner-intent authorization, secret-key setup or whole-proposal quorum. | **Joins and gaps explicit.** Key/message/check agreement, query history and fresh-forgery/compromise/queried-unauthorized events are formalized. Actual owner-signature implementation, authentic registry/history coverage and primitive bound remain open. Runtime comments no longer claim whole-block authorization. |
| D34 / P1 | Paper 2 proof soundness; H54, H56 | The geodesic verifier checks sampled floating matrices, not original `Context.Accepted`; opening count is not a proved `2^-k` error bound and the existing caller is not the canonical fail-closed packet path. | **Statement gap separated.** Backend false acceptance and original-context mismatch have distinct events in the proved five-term bound. Legacy TCB carriers explicitly include statement truth. No SNARK/ZK or payload error estimate is obtained from labels or current sampling. |
| D35 / P1 | Raw graph opening binding; H57 | Rust ordinary incidence comments claimed SVP-hard message binding despite global constant translations in its kernel. | **Counterexample proved and claims corrected.** Alternative modular openings preserve the original full payload and every deterministic observation while changing the vertex message. Authenticated C¹ payload binding and any new message-binding wrapper are separate claims. The theorem does not identify arbitrary private sheaves with this prototype. |
| D36 / P1 | Owner objects and existing identity/key handles | Names such as logical Signature, public identity/context hash, geometric key rotation or validator registry could be mistaken for an existing authenticated owner-signing implementation. | **Roles inventoried and separated.** Reuse actual Catalog/Intent/PacketCodec/keyFor/history/view. Committee/ValidatorSet remain validator objects; wallet/identity/ContextKey remain their own containers/projections. The existing Python/Rust public-identity encodings also differ. No owner registry is inferred from a shared name or 32-byte shape. |
| D37 / P1 | Queried unauthorized reuse and history coverage | The primitive profile accepted an arbitrary byte history, so honest queried-message authorization/metadata binding and released-signature coverage were not constructed. | **Bounded positive join implemented.** Full subject reflection, typed issued authorization and foreign-domain exclusion construct a history with no queried-unauthorized target. Matching new checked releases have exact signature coverage. All owner-domain queries must satisfy the same actual fixed relation; revoked-policy/unknown histories cannot be relabeled foreign. Concrete wire/key/issuance execution remains open. |
| D38 / P1 | Path and integral-rotation alignment; H62 | Existing EphemeralRotation stored both objects without identifying their actions. | **Constructor-based join implemented.** `ofPath` selects the supplied realization of the original path; `pathFiberSystem` defines the same transport and derives harmonic/recovery laws. Concrete realization and its path identity/composition laws remain inputs, and arbitrary pre-existing records are not retroactively aligned. |
| D39 / P1 | Native owner credential and finite proof boundary; H63--H64 | Class equality, witness existence and a public hash transcript do not establish possession or unforgeability. | **Finite relation and execution joined.** The actual decoded base/opening/path, admissibility, key/full-message input and ownerSignature execution are retained without a new registry or fibration. The canonical outer public-input codec is now concrete (H65). Credential registration/opening construction, supported witness and typed packet decoders, actual message-bound prover/verifier, knowledge extraction and security bounds remain uninstantiated. |

| D40 / P2 | Full-ciphertext digest versus exact-component digest; H66/H70 | A hash of the accepted exact payload does not index the full Hodge observation. | **Separated and joined explicitly.** Retrieval hashes full opaque ciphertext bytes, then uses a selected full-cochain parser and original bound-sample rotation. Exact-component ContextKey and payload semantics are retained. Manifest authentication, finite parser construction and delivery remain explicit. |
| D41 / P1--P2 | Fixed HCP/CVP input versus joint query; H67/H69 | Single-observation exact nonrecoverability implies neither full-array selector privacy nor encryption indistinguishability. | **Same-object positive/negative results.** Actual query/answer correctness and CVP comparison are proved; selected-column disclosure additionally assumes noise-column redundancy. A concrete sampler and full public-view experiment are needed for any stronger privacy claim. |
| D42 / P2 | Retrieval, authorization, message discovery and public encryption; H68 | A private read alone authenticates no state or caller, discovers no unknown index and supplies no public encryption key. | **O(N) scoped reference proved.** Efficient PIR/OMR and HCP public-sender encryption remain separate research choices. No auxiliary CRS encryption or conventional/native signature combiner is selected. |

| D43 / P1 | §2 `prop:hodge-decomposition` and submission correspondence | The named existence/orthogonality theorem did not itself state the manuscript’s componentwise uniqueness. | **Uniqueness companion implemented.** `Hodge_Decomposition_unique` proves equality of two harmonic/exact/coexact decompositions from the actual complex equation and membership data. No extra orthogonality or unique-opening premise is assumed; the existing existence API is preserved. |
| D44 / P1 entry | Independent statement definitions versus canonical proof objects | Renaming recursive categorical context definitions can break structural comparison; an opaque project predicate would hide the statement. | **Checked locally.** Challenge independently restates transparent contextObject/contextMap under their canonical Helfer names and the remaining vocabulary under the entry namespace. Explicit Solution adapters retain all operators, lattices and observations. P299 confirms the public snapshot passes full protected comparison, canonical source audit and Lean/NanoDa/con-ron replay for all 46 configured declarations. |

| D45 / P3 entries | Independent source size and actual-object fidelity | The full coding/context application cannot fit one 1,000-line Challenge. Generated proof references also depend on source boundaries. | **Two faithful companion configurations checked.** All selected groups remain; definitions retain actual canonical values, universe parameters and source proof-cache boundaries. Three calibration wrappers unfold the original interfaces with `change; exact owner`. No definition holes or assumed distance bridge. |
| D46 / P3 application | Concrete encoder function and exponent presentation | Embedded linearity proofs and numeral elaboration made independent structural comparison unstable. | **Named function/laws checked.** The existing encoder function is factored out with two proved linearity laws; encoder/opening values equal their old formulas by `rfl`. Existing public signatures and all 946 prior axiom sets are retained. |
| D47 / P1 | Cellular model versus topological realization | The finite graded carriers and signed incidences do not supply a regular CW or simplicial realization of every admitted base. | **Scope clarified.** The manuscript, entry README and metadata explicitly use the algebraic finite signed-incidence model. The constructed Hodge/CVP examples remain unchanged; no extra topological realization or simplicial-coherence claim is asserted. |
| D48 / P1 | Legacy spectral and likelihood appendix terminology | Equal nullity was called homotopy equivalence; density scores were described as quantum adversaries or success probabilities. | **Corrected prose.** Spectrum is not determined by nullity; the relation does not assert Helfer equivalence. Corrected Euclidean pointwise/factorization endpoints are separate from legacy supremum-norm integrals and HCP recovery games. The latter are outside the selected entry. |
| D49 / P0 | Manuscript ownership versus shared definitions and selected entry scope | Repeated construction and coding chapters made Paper 1 broader than its selected formal entry. | **Reconciled in P300.** Paper 1 has concise mathematical observation boundaries and a selected-result appendix. Paper 2 is the canonical construction/contract account; Paper 3 recalls the same data and proves quantitative comparisons. The S01–S11 ownership table has an explicit Paper 2 column. Shared definitions retain attribution and do not become duplicate new results. |
| D50 / P1 | Lean documentation versus the manuscript split | Old module/docstring correspondence still assigned gates, evidence or RS developments to former Paper 1 chapters. | **Documentation aligned.** Ninety-three Lean files now describe their current canonical paper owner or deferred supporting status. All 280 files have exact unchanged non-comment bytes against b917cda; imports, statements, proofs, options and pins are unchanged. The existing protected report remains tied to public snapshot 66e1ad2. |
| D51 / P1 | Body exposition versus formal cross-references | Repeated file/declaration lists interrupted the mathematical narrative and repeated the selected appendix. | **Consolidated in P302.** The body retains its mathematics and caveats; Appendix A after the conclusion has one definition/result/support/assumption parity table. All 46 configured names occur exactly once; concise proof boundaries follow. |
| D52 / P1 | Source ledger versus bibliography retrieval | Nineteen of the 28 ledger sources lacked a corresponding BibTeX record in an owning manuscript. | **Reconciled.** The ledger maps every source ID to its bibliography/key and reviewed/candidate role. All 19 added records have checked primary metadata; all 65 records parse through BibTeX without warnings. Uncited candidates are not forced into the PDFs or treated as adopted theorems. |
| D53 / P0 | Public HCP input versus protocol artifact views | The §3.1 prose described hashes/commitments/artifacts although the selected HCP theorem input is the classifier/cochain pair. | **Clarified in P304.** Definition Public Observation and the CVP comparison state the existing pair directly. Larger released observations retain separate equality/factorization and binding conditions in §2.2 (integrated by P305). This clarifies the informal account; no Lean object or theorem type changed. |
| D54 / P1 | Hidden-lattice family size versus recovery difficulty | A larger classifier fiber need not give more distinct operative answers. The present concrete family supplies two members; uniform exact impossibility alone does not provide a strict hierarchy for all larger classes. | **Fixed-oracle separation and containing-family inheritance proved in P308; quantitative hierarchy remains proposed.** Construct arbitrarily large compatible embedded harmonic-lattice families sharing a public observation and distinct targets. For a uniformly sampled hidden member independent of solver coins/oracle auxiliary data, prove the optimal success bound is largest target multiplicity divided by family size, specializing to 1/k for k distinct targets. Class cardinality alone and an unconstructed infinite enumeration give no asymptotic CVP-hardness reduction. |
| D55 / P1 | Public labels versus actual semantic homotopy equivalence; H01, H07 | The generic forward-only qualification was applied too broadly to the admitted two-member family. Classifier-defined SameHomotopyClass and actual typed Helfer equivalence are different interfaces. | **Resolved in P309.** Every ordered pair in the admitted Fin 2 family is actually typed-homotopy equivalent, so public-theory equality iff that equivalence is now explicit and proved. P310 adds an optional reflection property and proves the generic iff and class-fiber identity under invariance/reflection, then instantiates it for this family. No unconditional completeness or operative-kernel identification is inferred. |

## HCP theorem parity and remaining work

These are source-level correspondences, not a claim that the entire current
Lean tree was rebuilt during proofreading. Proximity theorem statuses remain
in T01--T20 of the linked detailed register.

| ID | Main-paper claim | Lean correspondence / actual hypothesis | Status / next action |
|---|---|---|---|
| HT01 | Hodge encryption correctness and unique operative target | `HCP.decrypt_encrypt`, `decrypt_coe_eq_harmonicProjection`, `HCPBridge.operativeTarget` | **exact** algebraic correctness. Separate key/noise distributions and security games. |
| HT02 | Helfer equivalence implies public equality | `HCPBridge.samePublicClass_of_homotopyEquivalent`; `CochainModel.closedTestInvariance`, `HCP.AxisFamily.theory_zero_eq_one` | **Generic conditional theorem and actual finite instantiation.** The homological fragment discharges its invariance premise. Full Helfer formula-in-context invariance remains separate. |
| HT03 | Public ambiguity defeats uniformly exact HCP recovery, including a fixed CVP oracle | `HCPBridge.no_solver_exactOnOperativeTarget_of_kernelSeparation`, `cvpOracle_insufficient_for_operativeTarget` | **Exact conditional** impossibility, instantiated by the constructed typed axis-family witness. The generic theorem retains its separation premise and the oracle result its explicit oracle-existence premise; no average-case hardness theorem follows. |
| HT04 | Linear kernel realization and discrete projection bridge | `exists_matrix_ker_eq_range`; `HarmonicCVPBridge.isClosestLatticeVector_iff_projectedTarget` | **exact** distinct comparisons. Neither statement solves the remaining discrete lattice search. |
| HT05 | Accepted exact commitments are cocycles | `Sheaf.CellularSheaf.decoded_isOneCocycle`; `Axioms.oneCocycle_of_committedCochainWellFormed` | **exact** under supplied interpretation/coherence. Resolve D01 and D06 for a concrete HCP observation. |
| HT06 | Stage maps compose and final certificate yields calibrated gap projection | `ProjectionChain.Chain.toEvaluationProjection`; `Gates.CalibratedFinalCertificate.toCalibratedEndToEndReady`; `JohnsonRSFarSeparation.toSeparatedGapReduction` | **Exact conditional** composition. Canonical decision radii now have a strict gap with unchanged map/far witness; source metric/extraction and geometric far-separation inputs remain parameterized. No efficient solver follows. |
| HT07 | Canonical RS MCA fraction after projection | `CanonicalRS.CitedBounds.bounds`; `CanonicalRS.MCA.projectionBadChallengeFraction_le` | **parameterized** by the named literature axioms. Do not borrow the companion's `2^-128` field-size conclusion for `q=12289`. |
| HT08 | Spectral/density likelihood scores | `gaussianLikelihood_correct`, projection likelihood lemma; legacy normalized functions | Local formulas are represented. Corrected integrated recovery/security endpoint is **not identified**; D05 remains open. |
| HT09 | Intended gated Hodge-noise ambiguity and representative family | HC01--HC44; `Helfer/CochainModel`, `Sheaf/HCPAxisFamily`, `HCP/AxisFamily`, `TCB/{HCPRealization,HCPAxisFamily}` | **Finite mathematical example and actual spectral gate instantiated.** Common `(class,b)`, distinct nonzero targets, actual discrete CVP recovery and weighted coefficient nondecodability are proved. Existing artifact joins retain application binding inputs. Full storage views, infinite ephemeral generation and privacy/lifecycle games are not completed. |

## What remains, by paper

The original open HCP items remain, with D01/D06 narrowed by the typed and
modular constructions. D25--D28 additionally make the intended semantic-family,
noise, full-observation and anonymity joins explicit. None blocks the universal
counting theorems of Paper 3.

| Issue | Existing progress | Completion decision / endpoint | Owner |
|---|---|---|---|
| D01 | Integral harmonic cipher, exact-component/full-sample record, harmonic recovery and the constructed finite semantic family | The mathematical `(class,b)` realization is constructed. Instantiate the larger released artifact's encoding, decoder and binding contracts if claiming a concrete public-storage HCP scheme. | Paper 1 interface; Paper 2 realization |
| D02 | Base payload/header, explicit HCP disclosure and retained root/directory are specified and projected from original objects | Implement the selected access/byte/proof contracts and include every released extension in its security experiment. Full operative-kernel coordinates are excluded from the base profile. | Paper 2 |
| D03 | Selected canonical near/far convention, strict views and correct-solver pullback are now constructed and synchronized with Paper 3 §7. | **Resolved for this decision profile.** Instantiate the independent geometric far witness for a stronger application claim; other profiles must choose their own consistent promise radii. | Paper 3 calibration; Paper 2 application contract |
| D05 | Correct Euclidean likelihood and local identities | Define a recovery experiment and its success event, or retain only likelihood-score claims. | Supporting likelihood layer outside current Paper 1; Paper 2 security model |
| D06 | Integral stalk lattices and coboundary preservation | The systematic modular profile and original codec are constructed; the finite axis family now has actual standard integral stalks and a harmonic lattice presentation. General serializers and production byte/binding laws remain profile contracts. | Paper 1 integral Hodge algebra; Paper 2 source/wire construction; Paper 3 quantitative comparison |
| D07 | Blinding geometry and a proposition-only MAC interface | Construct key/tag/verify and a security game if the MAC is a central claim; otherwise defer it explicitly. | Paper 2 |
| D08 | Algebraic ambiguity/oracle obstruction | Supply encoded families, distributions, input/security size, algorithm model and success criterion for a computational-hardness claim. | Paper 1 refinement; Paper 2 concrete scheme |
| D25 | Actual cochain model, invariant homological tests and finite theory classifier | Full Helfer fibrational/first-order semantics and a general admissible quotient remain separate from the proved fragment. | Paper 1 |
| D26 | Actual cellular/HCP realization and generic/concrete original-observation adapters | Apply the explicit artifact/classifier contracts; specify richer released-view equality/factorization and runtime bytes. | Papers 1--2 |
| D27 | Actual integral/encoded rotation, both recipient recovery routes, finite axis instance and original bound-sample/payload joins | Instantiate fresh generation, authenticated delivery/epoch policy and atomic lifecycle/migration; prove any further coordinate/metric or topology-change laws claimed. Deterministic transport is distinct from a resampled-noise security profile. | Paper 2 |
| D28 | One supplied ephemeral endpoint/path and recovered family plan | Construct indexed generation/transport/lifecycle and the specified finite/asymptotic privacy experiment. | Paper 1 family; Paper 2 security |

Paper 2's bounded first endpoint and its required joins are in
[SCOPE.md](papers/paper2/SCOPE.md). Its full transition implementation need not
precede Paper 3. The selected modular commitment/extraction/metric
profile for Paper 3 is already constructed; its completed Q08 theorem does not
wait for the remaining finite protocol profile. A conditional protocol paper may
state cryptographic primitives as explicit assumptions. A claimed new
commitment or MAC scheme additionally needs the actual algorithms and
security argument.

### Paper 3 completion assessment

The [detailed coding register](papers/proximity-prize/SEMANTIC_PARITY.md)
retains the canonical O/T/Q IDs. All nine named generic coding statements now
have Lean endpoints, including the four construction/packaging tasks Q04--Q07.
That is a statement-level coverage count, not a percentage of research
completion. Q08 separately instantiates the selected modular application.

| Work | Current evidence | Needed for the fully formalized paper | Dependency on Paper 2 |
|---|---|---|---|
| Q04: all-parameter smooth family | **Complete:** actual Galois fields, all-parameter divisibility, exact-order subgroup domains and realized list/MCA endpoints in `Capacity.Realization`. | Preserve the explicit large-alphabet regime; it is not the canonical wire field. | None |
| Q05: complete list phase split | **Complete:** all three fractional regimes, greatest safe count, exact real interval, supremum and nonattainment in `ListDecoding.PhaseSplit` and `Capacity.ListPhase`. | No generic coding packaging remains; the supplied-code intermediate optimum is outside this result. | None |
| Q06: real boundary transition | **Complete:** `[0,1/4096)`, supremum and nonattainment in `MCA.RealThreshold`, using shared count/real shell semantics. | Retain the closed-ball endpoint convention and recorded arithmetic trust dependencies. | None |
| Q07: standalone distance packaging | **Complete:** attained minima, closeness interpretation, covering and good-challenge consequences in `Core.Distance` and `Application.DistanceCalibration`. The optional storage adapter also proves equality with the existing canonical real-infimum pair distance. | A generic distance API does not instantiate the independent source codec/comparison. | None |
| Q09: publication artifact | P289 closes arithmetic trust/Hodge uniqueness; P291 records Paper 1 entry checks. Paper 3 now has separate coding/application configurations for the same manuscript. Paper 2 remains a conditional Markdown draft. | P292--P293 record full local comparisons/kernel replays; P301 repeats the 9,295-job union and all 975 dependency reports after the documentation revision, with unchanged sets and reviewed 37/31-page PDFs. P294--P295 add checked slim packages and their generated project builds. Publish only approved frozen snapshots before protected preflight; intake and registration remain separate. | None |
| Novelty / related work | The primary-source comparison records the established same-set MCA event, sharper positive-gap regimes, elementary endpoint/deep-hole context and the random-linear average-radius benchmark; actual commitment and storage maps are traced. The selected native modular source relation and quantitative comparison are now constructed in Q08. | The bounded comparison is now integrated using the actual modular relation, native metric theorem, classical deep-hole context and explicit MCA parameter regimes. Stronger primitive/security/cost claims would require concrete protocol mappings; none is claimed. Random-code guarantees still do not instantiate the fixed smooth RS family. | Uses the bounded shared profile for the commitment-specific comparison; no full protocol is required. |
| Q08: selected actual commitment projection | **Complete for the explicit native modular profile:** actual integral cellular coboundary validity, same original payload/full layout, global three-metric calibration, a payload with all three distances `3/4`, original-artifact joins and canonical diagonal fixed-mix goodness. Expanded validation passes. | This is a raw received-context proximity profile, not a nonempty accepted-far gate. No identification with an arbitrary old HCP/frame geometry, unrestricted Euclidean capacity radius, universal fixed-mix preservation or cryptographic security is asserted. Those need their own profile/statement; two relevant global comparisons are refuted. | Paper 2 owns source/observation contracts; Paper 3 owns quantitative analysis. Full ledger/consensus/Rust is not required. |

The arbitrary supplied-code intermediate optimum, further exact MCA
transitions and broader challenge families (Q10--Q12) are new research beyond
this bounded paper. They are not missing wrappers. The standalone generic
mathematics is formalized; the selected commitment-specific claim uses Q08's
now-constructed native modular source/codec profile and quantitative theorem.

The completed Q08 result does not extend to every proposed source model.
On the accepted exact-frame carrier alone the chain maps every element
to an RS codeword, so positive farness needs a larger raw/noisy source. A fixed
scalar mix also has a nontrivial kernel even for canonical representatives.
Neither problem is resolved by running Rust. Rust is useful for wire-format
parity, experiments, counterexamples, and any reported costs; a mathematical
radius requires the comparison and challenge bound, or certified exhaustive
analysis of the declared finite profile.

## Axiom Stacks reuse candidates

The user suggested the new [AxiomMath/Stacks release](https://github.com/AxiomMath/Stacks).
The following source files were inspected at commit
`f8e70c5dd04bfabcb423d5e325461f527c85a5d6` on 2026-11-04. The project's
[tier description](https://github.com/AxiomMath/Stacks#structure) distinguishes
reviewed `StacksCore` from `StacksFrontier`; these candidates are in Core.
This is a targeted reuse review, not a coverage audit of the full release.

| ID | Source / Stacks tag | Inspected declaration / result | Potential use and exact remaining comparison | Disposition |
|---|---|---|---|---|
| A01 | [FiberedInGroupoidsEquiv.lean](https://github.com/AxiomMath/Stacks/blob/f8e70c5dd04bfabcb423d5e325461f527c85a5d6/StacksCore/CategoryTheory/FiberedInGroupoidsEquiv.lean); [003V](https://stacks.math.columbia.edu/tag/003V) | `CategoryTheory.Functor.IsFiberedInGroupoids.iff_isFibered_and_fiber_isGroupoid`, `isFibered`, `fiber_isGroupoid`, `isStronglyCartesian` | Candidate canonical vocabulary for HCP §4's categorical fibration layer. The inspected code proves the equivalence and Cartesian-morphism consequences. HCP must supply the functor and groupoid-fiber hypotheses; this is not Helfer's model-categorical formula-invariance theorem. The tag's additional pseudofunctor clause was not established by this inspected file. | **Candidate adapter**, not adopted. Keep the HCP semantic assumptions explicit. |
| A02 | [SheafificationAdjoint.lean](https://github.com/AxiomMath/Stacks/blob/f8e70c5dd04bfabcb423d5e325461f527c85a5d6/StacksCore/CategoryTheory/Sites/Sheafification/SheafificationAdjoint.lean); [00WH](https://stacks.math.columbia.edu/tag/00WH) | Registers existing Mathlib `CategoryTheory.sheafifyLift`, `toSheafify_sheafifyLift`, `sheafifyLift_unique` | Concrete universal-property vocabulary for a future realization of the oracle/sheafification interface. These declarations already exist in this repo's pinned Mathlib. Supply the site, value category, sheafification instance, and identification of the actual oracle construction; a three-valued public map alone is not that construction. | **Reuse existing Mathlib first**; application identification remains open. |
| A03 | [HomologicalComplex.lean](https://github.com/AxiomMath/Stacks/blob/f8e70c5dd04bfabcb423d5e325461f527c85a5d6/StacksCore/Algebra/Homology/HomologicalComplex.lean); [010E](https://stacks.math.columbia.edu/tag/010E) | Registers Mathlib `HomologicalComplex` | [CochainModel](lean/Helfer/CochainModel.lean) now bundles the actual `C⁰→C¹→C²` objects and differentials, zero elsewhere, in Mathlib's bounded-below real cochain category and uses its Quillen model structure. The Stacks registration itself supplies no inner product, adjoints, Hodge decomposition, or hidden-operator separation. | **Existing Mathlib object, consumed by a constructed adapter**; no Stacks dependency added. |
| A04 | [Presheaf.lean](https://github.com/AxiomMath/Stacks/blob/f8e70c5dd04bfabcb423d5e325461f527c85a5d6/StacksCore/CategoryTheory/Presheaf.lean); tags 00V2--00V3, 00V6--00V7 | Presheaves as functors; pointwise injectivity/surjectivity at the trivial topology, and their mono/epi/isomorphism comparisons for type-valued presheaves | Helps distinguish an actual functor/natural transformation from a named interface. HCP's face-to-coface cellular convention must be matched with the appropriate opposite poset/site before invoking presheaf results. This does not identify hidden paths with cellular restrictions. | **Candidate categorical packaging** for H01/H03 and the ownership register; no identity claimed. |

Compatibility is a separate obligation. The release pins
[Lean 4.34.0-rc2](https://github.com/AxiomMath/Stacks/blob/f8e70c5dd04bfabcb423d5e325461f527c85a5d6/lean-toolchain)
and [Mathlib `16edf57…`](https://github.com/AxiomMath/Stacks/blob/f8e70c5dd04bfabcb423d5e325461f527c85a5d6/lakefile.toml).
The main repo now pins Lean 4.35.0 and Mathlib `56a0058…`; it does not add
Stacks as a dependency. A02--A03's existing Mathlib declarations can be used
without importing the entire Stacks library. A01 still needs an adapter and
validation against the current pin before use here.

The inspected results do not fill the HCP-sample/commitment comparison,
Plücker visibility choice, promise-boundary convention, concrete source-to-RS
far separation, or cryptographic security games. Record any future adapter
against its specific row rather than marking those obligations proved merely
because a related Stacks tag is formalized.

## Proofreading validation

The main manuscript was read through its abstract, all seven body sections,
both appendices, and bibliography. The companion abstract, introduction,
application interface, proof ledger, and detailed parity register were read
to check the split. Copyedits preserve the distinction between proved
identities, supplied witnesses, and cited theorem inputs.

Validation on 2026-11-04:

- `latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex` with a
  temporary output directory completed successfully: 92 pages, no undefined
  references/citations, duplicate labels, missing glyphs, or overfull boxes.
- All 92 pages were rendered and visually checked in contact sheets; the
  revised commitment, naturality, and MCA displays were also inspected at
  page resolution. Cross-reference metadata and extracted text confirm that
  definitions, propositions, and corollaries retain their actual types.
- Local Markdown links in the shared register and its entry points resolve;
  issue IDs are unique. `git diff --check` passes.
- A temporary `lake env lean` probe passed against the existing pinned
  Mathlib for the three A02 declarations, `sheafificationAdjunction`,
  `Functor.IsFibered`, and `HomologicalComplex`. The two checked
  sheafification theorems report only `propext`, `Classical.choice`, and
  `Quot.sound` in their axiom lists. This was not a build of Stacks or a
  full-project Lean audit.

The table contains 18 definition/notation/claim issues: 11 corrected and
7 open. Open rows above are deliberately retained; publication ownership is
not a proof of a missing construction.

### Paper 3 and actual-object follow-up: 2026-11-04

All eight Paper 3 sections, abstract and bibliography were proofread.
The revision corrects distance/quantifier conventions, reference types,
related-work scope and formalization status; §7 now traces the existing
commitment rather than introducing a substitute. The detailed register adds
O41–O45 and C01–C06 for the actual map and existing concrete calibration,
while preserving O01–O40/T01–T20 and the standalone 18-module boundary.

The fresh standalone build passed (3,108 jobs), and its 12-theorem axiom probe
confirmed standard Lean axioms plus the explicitly recorded native-evaluation
dependencies for the boundary arithmetic. A separate build of concrete
`PublicCalibration`, `BridgeWitness` and `MCA.Spectrum` passed (7,411 jobs).
No fresh concrete axiom-audit result is claimed; the optional scratch probe
was interrupted. These builds do not prove the remaining profile inputs.

The Paper 3 TeX build passed with 23 pages and no undefined references or
citations, duplicate labels, missing glyphs, or overfull boxes. All final
pages were rendered and visually checked; the commitment extraction and
proof ledger were also inspected at page resolution. Two underfull-box
diagnostics have no visible clipping or overlap. The reviewed PDF is exported
to `output/pdf/capacity-radius-proximity-proofread.pdf` and the manuscript's
canonical `main.pdf`. Current link/ID/whitespace checks pass.

For the user's selected actual-projection analysis, resume the
[recovered quotient-aware bridge plan](docs/COCHAIN_PROXIMITY_TRACE.md#recovered-bridge-equivalence-plan)
and identify its intended source/observable score. The plane/pair equivalence
and public pullback calibration are proved. A distinct original-distance
claim additionally needs its quantitative comparison; a full raw-geometric
isometry is not an automatic prerequisite. Rust execution and the full
Paper 2 transition/consensus program are not prerequisites for that analysis.

### Paper 2 transition core

The authorized implementation adds a bounded conservative transition under
the existing `Protocol` layer. Validation is recorded separately from source
completion in the current record below.

| ID | Canonical object / claim | Implemented owner and boundary |
|---|---|---|
| P201 | Finite resource marking, additive asset value and conservative flow | `Protocol/Ledger/ValueFlow.lean` reuses Mathlib `Finsupp` and `AddMonoidHom`. Availability plus equal consumed/produced value proves conservation of the actual updated inventory. Resource ownership and valuation interpretation remain application data. |
| P202 | Typed action, source state and computed successor | `Ledger/{State,Transition}.lean`; the action carries its actual nullifier list and the same `CochainCommitmentData`. `Candidate.Valid` checks authorization, availability, conservation, nonempty/Nodup/Fresh consumption, payload/snapshot acceptance and proposal context. |
| P203 | Replay and connected-history preservation | `Ledger/{Nullifier,Transition}.lean`; accepted updates are deterministic, conserve declared asset value and preserve spent identifiers. A consumed nonempty action cannot be replayed with another proposal. Nullifier derivation/security against alternate encodings remains an application obligation. |
| P204 | Existing cellular-sheaf snapshot | `Ledger/Sheaf.lean` instantiates `SnapshotModel` with the original `CochainPayloadInterpretation F`, `SheafStateSnapshot F` and accepted exact-cochain predicate. The topology tag and topology root retain distinct roles and sizes. |
| P205 | TCB evidence bound to this transition | `Evidence/Transition.lean` reuses `WitnessVerifierEnvelope`; it derives validity from the observed statement and joins the exact payload, before/computed-after roots, transition digest and public hashed cochain inclusion through object-indexed relations. Full serialized proof/verifier inclusion, acyclic canonical root preimages and hash/proof verification remain concrete profile obligations. |
| P206 | Quorum attachment to the same candidate | `Ledger/Certified.lean` reuses `QuorumCertificate` and complete proposal equality; `ProposalRef` now includes a separate `snapshotRoot`. Hold/rejection cannot supply acceptance. Round/lock/finality proofs remain open. |
| P207 | Positive and adversarial fixtures | `Ledger/{Examples,EvidenceExamples}.lean`: positive-valued transfer, full toy evidence/quorum path, overspend/imbalance/replay/duplicate/empty-use/context rejections, and a still-valid changed-digest candidate rejected by the old envelope and quorum. These are specification fixtures, not production cryptographic schemes. |
| P208 | One raw sheaf-storage context | `Storage/Context.lean` retains the original interpretation, snapshot and public cochain artifact. Its key derives run/schema/snapshot/leaf/topology/parameter names; raw shape/context binding is distinct from exact acceptance. |
| P209 | Actual mathematical semantics | `Sheaf/CochainSemantics.lean` transports exactness, cocycles and acceptance through actual operator/decoder/binding equations. `Storage/Projection.Input` joins that interpretation to the existing chain's same payload. |
| P210 | Append-once manifest and local lifecycle | `Storage/Checkpoint.lean` retains actual dependent payload/digest entries, unique ordered slots, complete sealing and a persistence receipt for the exact context/list/root before local consumption. This is not global freshness, anti-cloning, disk durability or erasure. |
| P211 | Existing stage/gate levels retained | `Storage/Projection.lean` stores `PluckerCochainState`, `CochainPlaneState`, `StateBus`, hard/naturality/final evidence. Each step checks its exact predecessor and appends one leaf; final sealing requires the exact list of one final prefix and recovers the original `CertifiedStateBus`. |
| P212 | Independent source comparison and actual canonical observation | `Storage/Calibration.lean` derives decoded-source ≤ scaled pair distance from exact comparison cochains and local decoding-error bounds. `Storage/CanonicalRS.lean` joins the entire observed artifact and identifies real-infimum/generic pair minima. These proved interfaces do not instantiate the selected codec/control data. |
| P213 | Original HCP stack retained | `Storage/HCP.lean` reuses the exact artifact/snapshot of `BoundHCPObservation` and names its actual lifecycle context through a supplied function. The full encrypted observation remains distinct; H26 records the conditional unrestricted-source obstruction. |
| P214 | Raw-source and storage regression fixture | `Storage/Examples.lean` uses actual integer-list decoding in a concrete two-coordinate sheaf: nonexact `[1,0]` has positive decoded distance, zero is accepted, and payload/plane writes exercise the local lifecycle and context/receipt rejection cases. Its equality contracts are toy models and it supplies no source-to-RS radius guarantee. |
| P215 | History entry bound to the original storage objects | `Storage/Anchor.lean` joins existing candidate evidence to the same interpretation, whole public artifact and exact sealed manifest. Acceptance, payload/snapshot equality and root inclusions are derived; actual ordered manifest inclusion under the candidate's block digest remains an explicit authentication-profile premise. Matching-quorum and exact-receipt endpoints retain those objects. |
| P216 | Coherent projection and gate database in that history entry | `Storage/ProjectionAnchor.lean` uses the actual `SealedProjection.itemsMatch`, joins its RS word to the candidate payload, and separately includes its actual gate database under the proposal evidence root. `AnchorExamples.lean` exercises a positive transfer/quorum/receipt and rejects a different run, a substituted snapshot with the same artifact/manifest root, and persisted nonexact input. |
| P217 | Current toolchain and explicit coordinate interfaces | The main pin is Lean/Mathlib 4.35.0. Public module interfaces, matching transitive revisions and CI selection are updated. Explicit Euclidean/raw-coordinate conversions preserve the operators, targets and existing CVP distance; no new source metric or authentication profile is selected. Current-pin aggregate/example build passes (9,233 jobs). Fresh probes cover 68 distinct declarations: 64 standard-only and the same four native-dependent endpoints. The previous 4.24 results are preserved separately. |
| P218 | Full Plucker reconstruction | `GrassmannianPlucker/Reconstruction` constructs subspace/projector recovery, full-shadow iff ranked-point equality and both former soundness inputs. Focused build and eight exact-standard-three audits pass. `TCB/PluckerObservation` connects this to the operative HCP target under kernel identification; its focused build passes. |
| P219 | Canonical-lift obstruction | `Core/CanonicalLift` and `Sheaf/CanonicalLiftObstruction` prove affine/pair RS lift spanning and rule out a global zero-additive-loss Euclidean comparison for a nontrivial linear decoder. Focused builds and thirteen standard-only audits pass. Restricted profiles, additive defects and separate threshold results are not excluded. |
| P220 | Actual systematic cellular and modular source | `Core/Systematic`, `Sheaf/SystematicCode` and `Sheaf/SystematicCode/Modular` construct the interpolation/cellular maps and actual integral-coboundary congruence, with proved RS compatibility. Focused builds, six systematic and eight modular standard-only audits pass. Arbitrary old sheaves are not automatically identified with this model. |
| P221 | Coordinate codec and geometric criterion | `Storage/DistanceReflection`, `CoordinateCodec` and `NoWrapCalibration` prove full coordinate coverage, a decoded-norm bound and integer-syndrome validity reflection, retaining Euclidean exactness distance. Focused builds pass. The finite-shell bound certifies at most `1/n` for a nonempty source far region, not capacity-scale geometric farness. |
| P222 | Canonical no-wrap benchmark | `Storage/CanonicalSystematic` uses actual `q=12289,n=4096,k=1024`, constructs the original payload/list layout and positive unit-error source family, and joins the comparison to the original public artifact. Focused build and fifteen native-dependent audits pass; only existing generated native certificates occur. Positive decoded-far raw inputs are not accepted exact ledger anchors. |
| P223 | Native metric comparisons | `Core/InterleavedMetric` and `Storage/ThreeLevelMetrics` prove global `d_C ≤ d_P = D_RS ≤ 2d_C`, with separate scalar and whole-pair matching-representative transports on actual modular validity. Current full build and selected audits pass. These are native modular edit metrics, not real decoded exactness or a frame score. |
| P224 | Explicit challenge profiles | `MCA/ZeroDirection` proves all challenges good and pair/scalar distance equality. `MCA/Diagonal` proves noncancelling challenges good and bad set exactly `{-1}` for a non-codeword diagonal base at nonnegative radius. Focused builds and eleven standard-only audits each pass. These are explicit profiles, not uniform fixed-mix guarantees. |
| P225 | Paper 2 initial manuscript | [DRAFT.md](papers/paper2/DRAFT.md) records objects, real/modular validity, three native metric contracts, scale directions, full-point visibility and evidence ownership. It is initial text without a TeX/PDF bundle or completed security claim. |
| P226 | Capacity-scale original payload | `Core/DeepHole` proves actual monomial scalar/pair/flattened distances `(n-k)/n`. `Storage/CanonicalThreeLevel` serializes the original canonical payload, proves all three native distances `3/4`, joins its original public artifact and proves the canonical mix good for this diagonal family. Its only bad challenge is `-1`, with exact fraction `1/12289`. Full build and selected native-certificate audits pass. |
| P227 | Fixed compression obstruction | `Core/FixedChallenge` constructs a pair `(u,-γ₀⁻¹u)` at capacity distance in both native coordinate metrics whose challenge at any specified nonzero `γ₀` is zero. A uniform positive far transfer through arbitrary fixed compression is refuted; sampled-after-binding or proved restricted-profile goodness is required. Generic selected audits are standard-only. |
| P228 | Composable metric handoffs and sharp scale | `Storage/CanonicalCalibration` constructs the existing source-to-source, source-to-code and composed calibration objects on original raw contexts, and the existing `EvaluationProjection` with near score `2d_C`. `Core/MetricSharpness` proves actual `(X^k,0)` has pair distance capacity and scalar-coordinate distance half capacity, so the factor cannot be dropped. No full legacy frame `Γ`, security game or finality claim is constructed. |
| P229 | Expanded native-metric validation — 2026-11-05 baseline | Before the five-module semantic implementation, all 234 source modules/235 Lean files have public headers, no active holes or local cycles and the same seven explicit cited-bound axioms. Full/default builds pass 9,253/9,248 jobs. The 139 selected reports match individual probes: 103 standard-only (100 exactly three, three subsets), 36 with existing native arithmetic certificates; no selected cited-bound or `sorryAx` dependency. Baseline closures are Prize 33, Protocol.Core 33, Storage.Core 79, CanonicalRS 58, CanonicalSystematic 70, CanonicalThreeLevel 78 and CanonicalCalibration 76; all exclude `Chain` and `CitedBounds`. |
| P230 | HCP, rotation and anonymity accounting — preimplementation audit, 2026-11-05 | The first HC01--HC44 crosswalk recorded source owners, visibility, gate inputs and then-missing joins, recovering the ephemeral/path plan and separating rotation/plaintext covariance from fixed-input ambiguity. That documentation-only milestone changed no Lean or Paper 1/3 TeX/PDF sources and used P229 validation. P231--P236 supersede its uninstantiated status only for the declared finite homological example and conditional artifact adapters. |
| P231 | Genuine cochain semantic model and invariant fragment | `Helfer/CochainModel` constructs Mathlib’s actual bounded-below real-module Quillen model, the cellular three-term adapter, bifibrancy and strict/isometric chain-isomorphism-to-typed-equivalence maps. Nonzero-homology closed tests have proved invariance for every interpretation. Full Helfer Theorem 12.3 is not asserted. Focused build and selected standard-only probe pass. |
| P232 | Actual finite integral cellular HCP family | `Sheaf/HCPAxisFamily` constructs restrictions, true coboundaries/operator, standard integral structures, rank-one harmonic lattice presentations and structured-noise samples. Its actual positive spectrum is `{1}` and gap one. The first shared raw `(1,1)` sample has zero exact component and different nonzero harmonic targets, both encoded with coefficient one. Focused build and selected standard-only probe pass. |
| P233 | Actual Helfer/HCP realization and CVP endpoints | `HCP/AxisFamily` uses the actual cellular matrices and homological closed theories; theory equality follows from typed equivalence. True operator/kernel/projector joins, common `(class,b)`, distinct targets, no exact public solver and the existing CVP-oracle insufficiency are instantiated. Positive discrete CVP recovery refers to the same actual encoded samples. Focused integration passes; no full-storage-view or privacy theorem follows. |
| P234 | Original observation and artifact-bound mathematical joins | `TCB/HCPRealization` derives kernel/projector/message/CVP agreement from actual operator action and classifier alignment and proves the explicit public-view-factorization corollary. `TCB/HCPAxisFamily` instantiates actual operator alignment and the actual spectral gate/window, and `bindSample` retains an existing artifact with acceptance/decode-zero/envelope proofs. Hashes, snapshots, bytes, key delivery and richer-view compatibility remain application contracts. Both focused leaves pass. |
| P235 | Weighted actual encoder counterexample | `HCP/AxisFamily` uses the original harmonic lattice encryptors at coefficients two/one with explicit coexact openings. Both share raw `b=(1,2)` and homological class, have exact component zero and distinct nonzero operative targets. Actual CVP answers agree with those targets; `no_exact_encoded_message_decoder` rules out one exact integer-coefficient decoder at that input. This is finite exact-recovery failure, not distributional hiding, anonymity or a rotation algorithm. Focused build and selected probe pass. |
| P236 | Concrete semantic follow-up validation — 2026-11-06 | Final expanded union/default builds pass 9,258/9,253 jobs. The public-facade probe passes 235 distinct selected reports: 199 standard-only (194 exact-three, five subsets), 36 old-native; all 96 new reports are standard-only (94 exact-three, two subsets), and all 139 retained sets are identical. No selected cited-bound or `sorryAx` dependency. Static scan passes for 239 modules/240 Lean files, public interfaces, no holes/cycles/unresolved imports and the same seven old cited-bound axioms. New closures are 8/8/19/23/30; the seven native-profile closures are unchanged; all twelve exclude `Chain`/`CitedBounds`. Reproduction and artifact details are in the central validation record. |
| P237 | First Paper 2 public-observation profile — 2026-11-06 | `Storage.PublicView` publishes the original payload and all six context-key fields, the exact sealed-root/ordered slot-digest directory, and a separately named same-sample HCP disclosure. Base/header/payload equality criteria, metadata substitution sensitivity and directory order/uniqueness are proved. A class-only announcement is the base/classifier tuple and does not release `b`. Paper 2 §2.1 records the access boundary; canonical bytes, private recipient delivery and proof/history authentication remain contracts. |
| P238 | Pairwise released-view recovery criterion — 2026-11-06 | `TCB.HCPRealization.no_exact_view_decoder_of_same_view` proves that equal actual released views with distinct operative targets exclude one exact decoder for both examples, even when their selected HCP observations differ. It retains the equal-view hypothesis and supplies neither a storage-record collision nor cryptographic privacy. The earlier global factorization theorem and full-Plucker recovery boundary remain unchanged. |
| P239 | Public-observation validation — 2026-11-06 | Expanded/default builds pass 9,259/9,254 jobs. The fresh public-facade probe passes 268 selected declarations: 232 standard-only (220 exact-three, twelve subsets) and 36 old-native. All 33 added reports are standard-only (26 exact-three, seven axiom-free); the preceding 235 sets are unchanged. Static scan: 240 modules/241 Lean files, no holes/cycles/unresolved imports, same seven isolated cited axioms. PublicView closure 38; storage core 80; all thirteen recorded closures exclude `Chain`/`CitedBounds`. Paper 2 draft and access profile updated; Paper 1/3 sources and PDFs unchanged. |
| P240 | Exact presented-coefficient recovery | `Sheaf.CoefficientRecovery` proves integer encoding injectivity and a classical partial decoder from the actual observed cochain, with exact success/range and encrypted-input correctness. It neither reads a hidden message field nor claims an efficient arbitrary CVP solver. |
| P241 | Actual integral Hodge rotation | `Sheaf.Rotation` constructs identity/inverse/composition, projector naturality, explicit integral harmonic-lattice equivalence and transport of both noise openings, message and observation, with roundtrip/composition laws. |
| P242 | Nontrivial same-coefficient axis rotation | `HCP.AxisRotation` constructs the integral axis swap and encoding compatibility for all integers. Rotated weighted input is `(2,1)` with coefficient two under both recovery routes; the fixed-input target sample at `(1,2)` decodes to one. These are distinct experiments. |
| P243 | Recipient/epoch/context-bound recovery profile | `Protocol.Ephemeral.Rotation` gives compatible presented rotations and both recovery routes, plus typed legacy-path endpoints. `Delivery` binds actual material and envelope to recipient, epoch labels and original context identifiers under supplied authorization/channel relations. Actual axis fixtures discharge geometry/encoding and retain channel proofs as inputs. |
| P244 | Original HCP sample/payload migration | `Protocol.Ephemeral.HCP` relates two existing bound samples by actual full-sample transport and derives original-payload decoder transport from their existing decoded-component equations. Both recovery routes retain source presented-lattice membership. Its target constructor preserves supplied artifact/context/binding data; no names, class equality or public hiding are fabricated. |
| P245 | Recipient rotation/recovery validation — 2026-11-06 | Expanded/default builds pass 9,266/9,259 jobs. Fresh public-facade audit: 355 selected declarations, 319 standard-only (306 exact-three, thirteen subsets), 36 old-native. All 87 additions are standard-only (86 exact-three, one axiom-free); all 268 earlier sets are unchanged. Static scan: 247 public modules/248 Lean files, no holes/cycles/unresolved imports and the same seven isolated axioms. New focused closures: 7/8/22/37/38/43/47; all twenty exclude `Chain`/`CitedBounds`. Paper 2 and shared records updated; Paper 1/3 sources and PDFs unchanged. |
| P246 | Owned-resource semantics | `Ledger.OwnedResource` defines immutable owner/asset/positive value, actual unit flow and input-ID nullifier. Checks derive value conservation, exact update coordinates, unit/spent inventory preservation and spent-input/output rejection. A distinct-owner fixture transfers positive value seven using supplied headers, without hash/auth/runtime fixtures. |
| P247 | Typed acyclic transfer transcript | `Evidence.TransferTranscript` specifies source/target content, signing-domain intent, exact metadata/packet and separate leaf/cochain/manifest/evidence/block inputs. Owner intent includes old source evidence root and parent tip; complete proposal supplies later target metadata. Reconstruction is structural, not digest inversion. |
| P248 | Independent operational packet checks | `Evidence.TransferVerifier` checks canonical parsed bytes, exact metadata/intent and actual signature/payload verifier results. Indexed soundness uses the actual trusted interpretation, not arbitrary decoders sharing labels. No candidate validity is assumed by the checked packet and no new secure primitive is constructed. |
| P249 | Original one-input manifest | `Storage.TransferManifest` seals exactly the existing cochain payload/leaf digest before current packet/block data. Its preimage, complete directory and root retain the original context. Backend persistence follows only from a matching real receipt; this is not the six-stage projection manifest. |
| P250 | Existing TCB/evidence representation | `Evidence.TransferEnvelope` packages independently derived validity, actual candidate/transfer witness, intent shadow, original artifact and indexed root proofs into the existing envelope/evidence interfaces. It does not substitute a `True` runtime or unit witness and adds no verifier soundness assumption beyond the explicit supplied contracts. |
| P251 | Checked transfer through history and optional quorum | `Protocol.Transfer` constructs the actual candidate and derives validity/update from component checks. Parser determinism fixes its successor. Full-packet evidence and original input manifest enter typed computed roots; existing evidence/history anchors retain the same objects. An optional acceptance quorum must match the complete final proposal. Snapshot and epoch stay fixed; primitive implementations, state origin, runtime refinement and finality remain contracts. |
| P252 | Owned-transfer validation — 2026-11-06 | Expanded/default builds pass 9,274/9,267 jobs. Fresh public-facade audit: 500 selected declarations, 464 standard-only (429 exact-three, 35 subsets), 36 old-native. All 145 additions are standard-only (123 exact-three, 19 axiom-free, three nonempty subsets); all 355 preceding sets are unchanged. Static scan: 255 modules/256 Lean files, no holes/cycles/unresolved imports and same seven isolated axioms. New focused closures: 13/46/47/47/51/50/58/59; all 28 exclude `Chain`/`CitedBounds`. Paper 2 and parity updated; Paper 1/3 sources and PDFs unchanged. |
| P253 | Shared operational packet algorithms | `Evidence.TransferCheck` retains actual parsing, canonical bytes, exact metadata/intent and signature/proof Boolean checks without universal soundness. Exact verifier projections execute definitionally the same check and preserve the actual parsed packet. |
| P254 | Local-good owned-transition reduction | `Transfer.Operational` retains original setup/context and constructs the same policy/candidate. Local authorization and original-context acceptance suffice for validity. Actual accepted-invalid attempts imply an exact authorization or payload-check failure. `Transfer.Owned` reuses that construction and theorem under its ideal contracts. |
| P255 | Actual released transfer record | `Transfer.PublicView` projects bytes, packet, complete proposal and original one-input manifest from the actual checked transfer. Parser, canonical bytes, source input/directory, signed intent and final proposal joins are proved. Public-ID and metadata differences distinguish records directly; no full-view privacy is inferred from the HCP pair. |
| P256 | One-shot sampled integrity | `Transfer.Security` fixes the raw setup, explicit observation/auxiliary input, arbitrary PMF tape and adversary. The same-attempt bad-event inclusion yields an authorization-plus-payload error bound without independence, with support-local zero-error and supplied-budget corollaries. `ofCheckedRelease` uses the exact release projection; setup sampling, adaptive oracles and actual primitive bounds remain open. |
| P257 | One-shot integrity validation — 2026-11-06 | Expanded/default builds pass 9,278/9,271 jobs. Seven-facade probe: 605 selected declarations, 569 standard-only (508 exact-three, 61 subsets), 36 old-native. All 105 additions are standard-only (79 exact-three, 24 axiom-free, two nonempty subsets); all 500 preceding sets are unchanged. Static scan: 259 modules/260 files, no holes/cycles/unresolved imports, same seven isolated axioms. New closures: 47/50/53/54; all 32 recorded scopes exclude `Chain`/`CitedBounds`. Paper 2/parity updated; Paper 1/3 sources/PDFs unchanged. |
| P258 | Byte-level TCB primitives versus semantic carriers | `TCB.PrimitiveChecks` defines actual signature/proof algorithms, byte-indexed backend statement, signing history and primitive failure events without soundness assumptions. Legacy ZKP/TCB API tokens are unchanged; comments now identify supplied truth and unindexed Prop assumptions. |
| P259 | Primitive-to-original transfer reduction | `Transfer.Primitives` retains actual parsed packet, exact metadata/intent, selected owner/key/message/backend functions and original context. Algorithm agreement and recorded history yield five-event inclusion and same-PMF/supplied-budget bounds. History completeness, setup/oracle model and actual numerical primitive bounds remain obligations. |
| P260 | Actual graph-payload message-binding obstruction | `Sheaf.GraphCommitment` models ordered ordinary incidence and canonical modular residues in the existing `CochainCommitmentData`. Global translation preserves the full payload; explicit path-three openings at 12289 change message three to ten while both produce `[2,4]` and satisfy WellFormed. All deterministic encodings/hashes preserve this collision. General cellular/harmonic constructions remain separate. |
| P261 | Existing runtime primitive comparison | The protocol queue and Paper 2 §6.4 compare the actual worker signature target, public-seed key setup, entry-count quorum/call path, raw graph openings, permissive parser, geodesic statement, sampling label and Python/Rust challenge mismatch. Rust comments/diagnostics now state their actual scope; no acceptance algorithm or verified runtime/cryptographic refinement is supplied. |
| P262 | Primitive/TCB validation — 2026-11-07 | Expanded/default builds pass 9,281/9,274 jobs. Seven-facade probe: 667 selected declarations, 631 standard-only (537 exact-three, 94 subsets), 36 existing-native. All 62 additions are standard-only (29 exact-three, 11 axiom-free, 22 proper nonempty subsets); all 605 preceding sets unchanged. Static scan: 262 modules/263 files, no holes/cycles/unresolved imports, same seven isolated axioms. New closures: TCB primitives 6, transfer primitive adapter 56, graph payload 2; all 35 recorded scopes exclude `Chain`/`CitedBounds`. Legacy semantic code tokens and runtime acceptance/arithmetic unchanged; current source/PDF evidence is recorded centrally. |
| P263 | Existing owner-signing object inventory | The two implementation queues now map fourteen reusable roles and missing joins: Catalog/Intent/codec/keyFor/history/view, committee/votes, public context/delivery, geometric rotation, logical signature, runtime validator map, identity hashes and wallet/account containers. Public Python/Rust identity encoding mismatch is recorded as a versioned-refinement obligation. Archived path-space signatures, replay/custody and self-generated credentials are mapped to current primitives; generic owner-message wiring selects no Ed25519 owner scheme or central credential issuer. The focused native import map identifies the existing `EphemeralRotation` admissibility proof and cellular-to-Helfer adapter; path/rotation transport agreement, owner binding and the finite message-bound proof backend remain explicit joins. |
| P264 | Acyclic full-subject signing bytes | `Transfer.Signing` prefixes the existing codec encoding of actual metadata and Intent in a packet with empty signature/proof fields. Existing codec injectivity proves full subject reflection and metadata/intent separation; literal owner/spectral domains prove message-byte distinction. Codec execution and signature security remain contracts. |
| P265 | Authorized issuance to actual query history | `Transfer.Issuance` retains actual source metadata/Intent/signature and authorization for its derived signer. Mapping all records plus explicitly foreign-domain queries constructs the existing SignatureHistory. Lookup/reflection proves authorization and exact Covers retains actual signatures; no key injectivity or predicate identity from policy IDs is assumed. |
| P266 | Constructed raw owner verifier and four-event bound | `Transfer.Authorization` builds the checker/profile from existing backend/keyFor/signing bytes with agrees=rfl, preserving original context/intent/policy/candidate and proof backend. Typed fixed-policy history excludes queried-unauthorized targets and gives zero mass; the same PMF retains forgery/compromise/backend-error/statement-mismatch terms and supplied budgets. |
| P267 | Matching raw release and actual signature coverage | `PublicTransferView.ofOperational` reuses the existing carrier; exact publicView delegates to it. A raw packet checked under the new constructed checker plus independently supplied authorization becomes a covered issue with literal metadata/Intent/signature and actual backend verification. Legacy signatures are not reinterpreted, and history/oracle provenance remains separate. |
| P268 | Owner-signing reuse validation — 2026-11-07 | Expanded/default builds pass 9,284/9,277 jobs; facade 3,472. Seven-facade probe: 728 selected reports, 692 standard-only (555 exact-three, 137 subsets), 36 existing-native. All 61 additions are standard-only (18 exact-three, 22 axiom-free, 21 proper nonempty subsets); all 667 preceding sets are unchanged. Static coverage: 265 modules/266 files, no holes/cycles/unresolved imports, same seven isolated axioms. New closures 48/50/59, facade 68; all 38 scoped closures exclude `Chain`/`CitedBounds`. Existing native-authentication plan mapped; no concrete codec/owner backend or numerical bound selected. |
| P269 | Same-path transport through existing objects | `PresentedRotation.pathFiberSystem` realizes selected paths in the original FiberSystem. `EphemeralRotation.ofPath` selects that very rotation with actual admissibility. Harmonic projection and invariant preservation plus direct/retained-key coefficient recovery follow from existing integral laws. Realization and path coherence are not constructed from a class label. |
| P270 | Finite native credential/path relation | `Transfer.PathSignature.WitnessRelation` uses a partial byte decoder into existing dependent sums: base, opening and original EphemeralFiberSpec. Deterministic decoding identifies that same witness; its credential opening/admissibility construct the original rotation, same-path action and recovery. Only the selected encodable profile is covered. |
| P271 | Existing proof backend at the owner-signature field | `ProofVerifier.asSignatureVerifier` wraps the same algorithm without a new verifier structure. Native input reflection conditionally recovers the key, metadata and full Intent; actual checked releases verify their original ownerSignature bytes. Supplied statement reflection derives finite witness existence or backend false acceptance, not knowledge security. |
| P272 | Redundancy pruning | `TransferVerifier.PacketCodec.encode_injective` now delegates to the raw codec's existing theorem through its operational projection, preserving public types/constructors. The stale proposal for a second ephemeral representative/family carrier is replaced by the actual existing objects. Distinct signature/proof roles, private samples/blinded values and credential/snapshot bindings retain their semantics. |
| P273 | Native path/witness validation — 2026-11-07 | Expanded/default builds pass 9,285/9,278 jobs; native leaf 3,470, facade 3,479. Seven-facade probe: 750 selected reports, 714 standard-only (569 exact-three, 145 subsets), 36 existing-native. All 22 additions are standard-only (14 exact-three, seven axiom-free, one propext-only); all 728 retained dependency sets are unchanged. Static scan: 266 modules/267 files, no holes/cycles/unresolved imports, same seven isolated cited axioms. Native leaf closure 66, facade 75; all 39 scoped closures exclude Chain/CitedBounds. No concrete credential/codec/proof or knowledge-security implementation is inferred. |

| P274 | Concrete outer path-signature codec | Domain-separated credential/message framing has an actual parser, exact roundtrip/reencoding and injectivity, including malformed byte cases. `canonical_input_subject_eq` discharges the outer input-encoding premise; typed packet/full-cochain/private-witness serializers remain open. |
| P275 | Full-ciphertext content addressing | Actual directory membership and local hash checking give lookup completeness and original-or-collision authentication, without globally injective hashing or a duplicate manifest type. Duplicate slot labels do not defeat digest-based scanning. |
| P276 | Original Hodge query/answer/CVP | Every column is actual H.encrypt with HodgeNoise. Integer server evaluation is exactly the observed encryption of the selected value times the original harmonic coefficients; exact/coexact openings combine separately. Original coefficient recovery and same-answer discrete-CVP equivalence follow. |
| P277 | Whole-bucket selector privacy | Request and full server transcript are selection-independent for one fixed public bucket, including arbitrary target-independent server tape and observer. PMF/event masses agree exactly. O(N) reply payload volume is explicit; authentication, network metadata, retries and subsequent public actions need their own view contracts. |
| P278 | Conditional joint-query obstruction | Public span exclusion identifies the selected column under explicit redundancy of all others. Actual axis-family HodgeNoise uses varied coexact openings and retains original CVP comparisons. This extra joint hypothesis is distinct from existing fixed `(class,b)` oracle nonrecoverability. |
| P279 | Original-object hash-addressed recovery | Selected finite full-ciphertext decoding and actual BoundHCPObservation/BoundSampleRotation endpoints feed existing delivered recovery material. Availability and original decoding yield coefficients or an actual collision; wrong scope and unlisted digest reject. Full ciphertext digest is distinct from the exact-component ContextKey digest. |
| P280 | Retrieval/codec validation — 2026-11-08 | Expanded/default builds pass 9,292/9,285 jobs; focused facades 3,490. Consolidated probe: 839 selected declarations, 803 standard-only (627 exact-three, 176 subsets), 36 existing-native. All 89 additions are standard-only (58 exact-three, 31 subsets/axiom-free); all 750 retained dependency sets match. Static scan: 273 public modules/274 files, no holes/cycles/unresolved imports, same seven isolated cited axioms; all 46 scoped closures exclude Chain/CitedBounds. Source ledger and three-paper completion checkpoint updated; Paper 1/3 TeX and PDFs unchanged. |

| P281 | Paper 1 full-observation wording — 2026-11-08 | Intro/§2/§5 now distinguish accepted exact payload, separate full Hodge sample, supplied binding/operative alignment and optional full-pair disclosure. Full genuine operative-kernel Plucker data plus b determine the target at a fixed metric. Eight existing supporting endpoints pass a fresh exact-standard-three audit; all 273 Lean source hashes are unchanged, so P280's build/consolidated selection remains the Lean baseline. Revised 100-page PDF compiles without undefined references/citations, missing glyphs or overfull boxes; all pages rendered, changed passages inspected in detail. Eight underfull diagnostics remain. Canonical/stable copies match. D03's near/far convention remains the next mathematical step. |

| P282 | Strict canonical decision calibration — 2026-11-08 | Existing RadiusCalibration/certificate/bridge/GapBoundary objects now support `(ε,δ_J,ε,δ_J)` with ε<δ_J. Actual bridge fields and Γ.receivedWord map are retained; correct target solvers pull back on the same closed promises. Pure near value `2046/4096`, nonnegativity and strict rational comparison are separated from the native-dependent canonical BridgeData type. List/MCA radii and Johnson far witness remain unchanged; no geometric witness or efficient solver is constructed. |

| P283 | Strict canonical profile validation — 2026-11-08 | Focused/union/default builds pass 3,276/9,292/9,285 jobs. Eight-import consolidated probe: 855 reports, 806 standard-only (630 exact-three/176 subsets), 49 existing-native. Sixteen additions: three exact-standard-three pure rational reports, thirteen canonical-native adapters; all 839 prior sets match. A pre-existing divisibility native certificate is newly reachable, with no new axiom/native_decide declarations; no selected cited-bound/sorryAx dependency. Static scan: 273 modules/274 files, no holes/cycles/unresolved imports; 48 scoped closures exclude Chain/CitedBounds. Paper 1's 101-page PDF is rebuilt/rendered/reviewed; Paper 3 unchanged. |

| P284 | Paper 3 actual-profile summary and bounded comparison — 2026-11-08 | Abstract/§1 now state completed modular validity and `d_C≤d_P=D_RS≤2d_C`, with canonical raw capacity payload and distinct fields. §7 includes the sharp factor-two witness, nonnegative source-score range and concrete reduced-vector/modular-relation/fixed-γ linear-output comparison. §5/§6 cite classical deep-hole/BCGM background and bound MCA/ordered-certificate comparisons. §8's application ledger and canonical native trust are explicit; no stronger geometric, cryptographic, efficiency or priority claim is introduced. |
| P285 | Paper 3 correspondence/artifact validation — 2026-11-08 | Twelve existing endpoints rechecked: six standard-only/six inherited-native; all twelve dependency sets match P283. All 273 Lean hashes unchanged, so 9,292/9,285 builds and 855 consolidated reports remain the source baseline. Revised 30-page PDF compiles without undefined references/citations, missing glyphs or overfull boxes; all pages rendered and reviewed, changed passages inspected in detail. One underfull diagnostic remains. Canonical/review copies match; Paper 1 and preserved Rust edit unchanged. Source ledger now indexes 26 readings. |

| P286 | Manuscript-led submission statement selection — 2026-11-08 | The existing named propositions/theorems determine the two entry scopes. Paper 1 foregrounds the discrete CVP comparison, concrete cellular recovery and general/finite ambiguity contracts. Paper 3 retains all nine coding groups plus separate spectrum/distance and original-payload modular claims. The submission plan records exact owners, quantifiers and limits; no Challenge/Solution, metadata or protected preflight is yet created. |
| P287 | Kernel arithmetic certificates — 2026-11-08 | BoundaryField’s Lucas factor chain and explicit roots now use kernel arithmetic/modular-exponentiation proofs, with five private small-prime certificates and all 33 pre-existing public signatures unchanged. Canonical12289 primality, generator/order, numeric target and spectrum proofs likewise preserve their objects/types. Active native_decide calls are removed. Focused boundary/canonical builds and the separate 37-report boundary audit pass; consolidated checks are recorded separately. |
| P288 | Full Hodge proposition correspondence — 2026-11-08 | The new Hodge_Decomposition_unique proves componentwise uniqueness under the complex equation and genuine harmonic/exact/coexact membership. The existing existence theorem API is retained and its docstring corrected. The single-thread scratch check uses exactly the three standard axioms; the owner rebuild and shared audit are separate validation checks. D43 records the repaired gap. |

| P289 | Selected-surface/kernel arithmetic validation — 2026-11-08 | Union/default builds pass 9,292/9,285 jobs. Full retained-plus-selection probe: 900 standard-only reports (724 exact-three/176 subsets, 106 axiom-free), zero native/cited-bound/sorryAx dependencies. All 806 old standard sets match; all 49 old native reports become standard-only; 45 additional reports complete the 70-owner selection. Static coverage 273/274, seven changed sources, no holes/native calls/cycles/unresolved imports, same seven isolated cited axioms, all 48 closures unchanged. All 159 old public signatures remain; Hodge uniqueness is the only new public declaration. Paper 3 trust wording/PDF updated and pages 27--30 reviewed; Paper 1 and unrelated Rust edit unchanged. |
| P290 | Paper 1 independent entry and Jacobian release conventions — 2026-11-09 | All eight selected P1 groups have a Mathlib-only Challenge and canonical-proof Solution under Palomar/PaperOne. Comparator selects 21 manuscript-facing and 25 supporting declarations; 23 intentional Challenge theorem holes and zero definition/Solution holes. Transparent definitions retain actual cellular operators, integral lattices, cohomological theory, CVP quantifiers and full Plucker data. README/metadata map sources and limits; no asymptotic hardness/security claim. Manual-only workflow follows frozen Jacobian with nested lean project paths and pinned pipeline; no protected run, release or submission. |
| P291 | Paper 1 entry validation — 2026-11-09 | Challenge/Solution builds pass 3,516/3,666 jobs; expanded/default pass 9,293/9,285. Local macOS Comparator accepts statements/definitions and Lean/NanoDa kernels with standard axioms; its no-sandbox diagnostic is not protected evidence. Fresh entry audit 46 standard-only (44 exact-three/two subsets); combined 946 (768 exact-three/178 subsets, 106 axiom-free), all 900 previous sets unchanged. Static coverage 275/276; all 273 owner hashes and 48 old closures unchanged, two added closures exclude Chain/CitedBounds. Zero implementation holes/native calls/cycles/unresolved imports; 23 deliberate Challenge holes, same seven isolated cited axioms. Both manuscripts/PDFs and unrelated Rust edit unchanged. |

| P292 | Paper 3 independent coding/application entries — 2026-11-09 | Two Mathlib-only Challenges cover all fourteen selected groups, with P3-A02 split between sharp coding and original-context calibration. Coding: 52 targets (36 main/16 support); application: 22 (ten main/twelve support). Ordinary canonical definitions, genuine fields/domains and original Context/payload/decoder/layout/metric objects are retained. Three calibration wrappers are definitionally the original propositions. Four supports tie all native capacity distances to the same named payload. Named encoder function/linearity laws and explicit exponent casts preserve encoder/opening values by rfl. No new security/efficiency/stronger geometric claim. |
| P293 | Paper 3 entry and retained-source validation — 2026-11-09 | Independent builds: coding 3,138/3,173 and application 3,207/3,434 jobs. Both local macOS comparisons and Lean/NanoDa replays pass; no-sandbox diagnostics are separate from protected Linux preflight. Combined 975 reports: 792 exact-three/183 subsets (106 axiom-free), all 946 preceding sets unchanged; coding 52 (48/four), application 22 (21/one). Default/union 9,285/9,295 pass. Static 279/280, 96 deliberate Challenge holes/zero implementation holes, zero native calls/cycles/unresolved imports, same seven isolated axioms, all 54 closures exclude Chain/CitedBounds. All 50 old closures and 270 old source hashes match; five existing modules change (three comments, two definitionally equal encoder/opening presentations). Both manuscripts/PDFs and unrelated Rust edit preserved. |
| P294 | Slim per-entry source releases — 2026-11-09 | Exact Challenge/Solution import unions contain 31/35/81 modules for Paper 1, Paper 3 coding and original-cochain application. Selected Lean/config/metadata/manuscript bytes and pins are unchanged; generated Lake defaults only to the selected Solution. Navigation-only crosswalk rewrites and source hashes are recorded. Plans, archives, other-paper entries, runtime, caches and private history are excluded. Three independently frozen local branches remain pending approval for public upload. |
| P295 | Slim package and metadata validation — 2026-11-09 | Generated defaults pass 3,667/3,174/3,435 jobs and separate Challenges 3,516/3,138/3,207, using existing pinned caches in disposable copies. Exact module/source/ZIP/link/size checks and deterministic exports pass; retained informal scopes agree. The pinned upstream mechanical metadata contract accepts all three. No Lean declarations or pins change; the 975-report and kernel evidence is preserved for unchanged source bytes. Protected Linux workflow needs a public immutable snapshot; no remote creation, push, dispatch or registry action occurred. |
| P296 | Paper 1 first-submission scope — 2026-11-09 | Preserve the authoritative three-paper split and prioritize Paper 1 only on the first public main branch. Its abstract/introduction foreground constructed nonzero-target ambiguity and weighted coefficients two/one at b=(1,2), with each private lattice retaining a unique CVP answer. Elementary projection identities, the homological-test fragment and the finite signed-incidence model are explicit; regular CW/simplicial realization, asymptotic hardness and sampled cryptographic security are not inferred. D47--D48 reconcile model and legacy appendix descriptions. |
| P297 | Paper 1 final manuscript/source QA — 2026-11-09 | Revised 101-page PDF builds with zero undefined references/citations, missing glyphs or overfull boxes and seven underfull diagnostics. All pages rendered/contact-reviewed with detailed changed-page checks; canonical/stable copies match. Hansen--Ghrist publication metadata and the CVP citation are updated. All 279 Lean source hashes and theorem/dependency sets are preserved. Source ledger now has 28 candidates, including deontic joint commitments and recent full-length RS limitations, without adoption or blocking Paper 1. Final immutable release and protected/preflight/intake evidence are recorded separately; prior slim commits are dated baselines. |
| P298 | Approved Paper 1 public preflight — 2026-11-09 | User approved publication and preflight only, explicitly deferring submission. The new public formalizations repository main points exactly to 66e1ad2cb726d3dd816461e4f76b1d0d9147a46d (54 files, 31 source modules plus Lake, no private history). Protected run [42729947447](https://github.com/what-social-construct/homotopical-encrypt-formalizations/actions/runs/42729947447), request p1pf875ad70f, uses full mode, palomar-standard-v1 and pinned pipeline 14aa8d6. Immutable-source preparation passed; P299 records the completed mechanical report. Original private repository and Rust edit remain intact; no Palomar intake, editorial review or registration. |
| P299 | Complete protected Paper 1 preflight — 2026-11-09 | Run 42729947447 and its downloaded schema-2 mechanical report pass for exact public commit 66e1ad2cb726d3dd816461e4f76b1d0d9147a46d. All 46 configured declarations pass protected comparison with the standard three axioms; Lean, NanoDa and con-ron accept (45,899 exported declarations checked by con-ron). Exact source/config/metadata hashes, high-trust canonical Challenge provenance, palomar-standard-v1 and bubblewrap v0.12.0 are verified. The only advisory is preferred Challenge review size; 977 lines/49,234 bytes meet hard caps. Local report identity/digests and validation are retained. User authorized preflight only: no registry intake, editorial review or registration. |
| P300 | Three-paper manuscript and Lean documentation alignment — 2026-11-09 | Paper 1 is reduced from 101 to 37 pages while preserving all eight selected mathematical groups and all 46 crosswalk declarations. Paper 2 now owns concrete payload/commitment, systematic codec, visibility, gates and storage evidence; optional syndrome and native cochain metrics remain distinct. Paper 3 retains all fourteen selected quantitative groups and recalls the existing construction with attribution; its PDF is 31 pages. The ownership table, active outlines and 93 Lean documentation files follow this split. No non-comment Lean source, selected statement, configuration or pin changed. This is a local revision; public 66e1ad2 and the P299 exact-commit report remain historical evidence. |
| P301 | Revised manuscript validation and immutable source pins — 2026-11-09 | Expanded Lean union passes 9,295 jobs. Fresh selected audit passes 975 standard-only reports (792 exact-three/183 subsets, 106 axiom-free), with every prior 975 dependency set unchanged. All 280 Lean files retain exact non-comment bytes versus b917cda; 93 have documentation-only changes. Paper 1 §§2–3 retain all 84 displays, 289 inline formulas, nine propositions, eleven definitions and nine proofs exactly; all 46 crosswalk names occur once. Paper 3 §§2–6 and nineteen §7 displays are preserved. Revised 37/31-page PDFs build/render/visual QA passes. All three metadata source URLs pin the frozen manuscripts at adfcc14. Revised slim packages use a separate local directory; previous public 66e1ad2/report remains unchanged. Fresh protected verification is required before any later intake, which remains deferred. |
| P302 | Paper 1 backmatter parity and source/bibliography reconciliation — 2026-11-09 | Mathematical body has no Lean cross-reference blocks or implementation-name lists. A single post-conclusion table identifies four canonical object rows, eight main groups/21 declarations, five support groups/25 declarations and three background/assumption/contract rows; every selected name occurs once. All body mathematics in §§1–6 and all 280 Lean source bytes match dddfdd2. The 38-page PDF passes build/render/detail QA with no undefined references, missing glyphs or overfull boxes. Added 19 bibliography records; all 28 ledger sources now map to an owning bib/key/status. Isolated BibTeX checks pass 7/42/16 records without warnings. P3 all13 cited alpha-style entries are byte-identical, so its31-page PDF remains unchanged. P301 proof evidence remains its exact checked baseline; new informal text still requires fresh protected preflight before any later intake. |
| P303 | Paper 1 abstract and motivation refinement — 2026-11-09 | Remove only abstract paragraph two, preserving paragraph one exactly. Cite Helfer in the opening motivation; keep the explicit hypotheses and proved-fragment boundary. Consolidate the three CVP-related contribution items into one, with four items overall. All body mathematical displays, inline formulas, proposition/definition statements and proofs remain unchanged; the selected parity table, bibliography and all Lean sources are untouched. The 38-page PDF builds/renders cleanly with no undefined references, missing glyphs or overfull boxes. Updated local artifacts require their own exact-commit protected preflight before any later intake. |
| P304 | Standalone HCP problem narrative and merged observations — 2026-11-09 | Remove repeated companion-program descriptions and runtime/layer lists; use direct cellular-model wording. HCP input, hidden operative target, CVP comparison and semantic equality lead to one merged §5, with full-point recovery in §5.5 and conclusion §6. Clarify Public Observation as the actual classifier/cochain pair and correct §3.1 to contrast that input with CVP (B,t). Preserve all 106 displays, 11 proposition statements, 11 proofs and 10 other definitions; retain all 46 parity names exactly once. The 36-page PDF passes build/render QA with five printed external references; seven bibliography records and the 28-source ledger remain. Seven Lean header comments remove obsolete section references; all 280 non-comment source fingerprints and all theorem/configuration bytes remain unchanged. No new kernel replay, protected preflight, publication or submission is claimed. |
| P305 | Construction-first HCP setup; CVP comparison last — 2026-11-09 | Integrate semantic/classifier data and exact-cochain/observation facts into §2, with full-projective reconstruction in §2.2.1. Explain the actual homological model beside the cellular example in §3.5. CVP comparison/kernel ambiguity is the final main section before conclusion §4. Remove two standalone background files and three unused notation rows. All eleven proposition statements and eleven definitions are verbatim; ten proofs are verbatim, and one opening clarifies the invariant-test premise without changing formulas or argument. All 46 parity names occur once. The 32-page PDF passes build/render QA; nine Lean headers are comment-only, all 280 non-comment source fingerprints and nine entry statement/configuration files are unchanged. Retain the 9,295-job/975-report proof evidence; no new protected preflight, publication or submission. |
| P306 | Explicit homotopy-class meaning in the introduction — 2026-11-09 | Replace the generic “homotopical framework” wording with homotopy-class information and the proved implication from homotopy equivalence to shared public value. Operator disagreement is stated in fixed public coordinates. Do not assert the converse or completeness of the classifier. Only one introductory paragraph changes; all formal statements, proofs and Lean bytes are unchanged. The local 32-page PDF builds without undefined references, missing glyphs or overfull boxes, with reflow reviewed. No new Lean build, kernel replay, protected preflight, publication or submission. |
| P307 | Concise family-CVP contribution and explicit hidden-member obstruction — 2026-11-09 | Reduce item (iii) to one main statement about distinct unique closest vectors in compatible harmonic lattices. Beside the actual family, state that supplying both answers does not select the operative answer, even without a running-time restriction. The example needs only two compatible members. Preserve all formal statements, proofs, parity anchors and Lean bytes. The 32-page PDF passes build/render QA; no new protected preflight, publication or submission. D54 records the separate proposed quantitative family-size hierarchy. |
| P308 | Primitives before HCP and explicit known-member/hidden-member separation | Start the setup from declared semantic homotopy equivalence and its invariant public classifier, then Hodge data/sample, public observation and hidden witness before the short HCP definition. Reword four definitions; retain all eleven earlier proposition statements/proofs. Remove colons from four concise contribution items and delete requested foundation/signposting prose. Add closing Corollary 3.6 and its Lean rank-one oracle separation, with generic containing-family inheritance. Three canonical theorems and one refactored proof change only Hardness/AxisFamily; 278 Lean files and nine entry statement/configuration files match 048c2ea. Focused builds pass 3581/3759 jobs; all 124 fresh reports are standard-only and all 120 selected sets unchanged. The 32-page PDF passes build/render QA; 46 selected anchors and two separately marked canonical consequences remain. No fresh protected preflight, publication or submission. |
| P309 | Redundancy cleanup, single parity appendix and admitted-family converse — 2026-11-10 | Consolidate repeated observation/kernel/transport/scope prose, remove Recovery Target (Computational Scope becomes §2.3), and fold Appendix B into the single parity appendix. Correct the overly broad converse qualification: semanticEquivalence_all and theory_eq_iff_homotopyEquivalent prove actual typed equivalence for every pair and public-theory equality iff that equivalence on the admitted Fin 2 family. Generic completeness is not added. All 35 formal environments, nine statement/configuration files and the other 279 Lean files match 6b762a0; old AxisFamily bytes are preserved. Repeated focused/three-Solution builds pass 3581/3759 jobs, with two fresh standard-three reports and retained P308124-report evidence. The 28-page PDF passes layout/build checks, all four contribution items stay together, and 46 selected plus three canonical anchors remain. No new protected preflight, publication or submission. |
| P310 | Optional complete-classifier profile and generic class identity — 2026-11-10 | Add ReflectsHomotopyEquivalence on the unchanged realization, generic label-equality iff typed equivalence, and existing PublicClassOf equality with the declared semantic class under invariance/reflection. The actual family proves the condition and reuses the shared iff without duplicating the local proof. Define completeness in §2 before HCP and state its consequences after the bridge; all 35 formal environments and nine selected statement/configuration files remain byte-identical. Two Lean files add three theorems/one Prop definition and refactor one old proof; 278 other Lean files and imports/pins are unchanged. Builds pass 3581/3759 jobs and five exact-standard-three reports. The 29-page PDF passes layout checks, with one parity appendix and 46 selected plus five canonical theorem anchors. No new protected preflight, publication or submission. |

#### Current protocol validation

Earlier bounded-transition milestone, 2026-11-05, before the subsequent
mathematics/storage extension. With the pinned Lean/Mathlib dependencies:

- `lake build Protocol.Core Protocol.Ledger.Examples Protocol.Ledger.EvidenceExamples`
  passed (7,385 jobs), including the existing-sheaf adapter and the updated
  candidate/evidence/quorum fixtures.
- A fresh `#print axioms` report for twelve preservation, replay, evidence,
  fixture and sheaf-adapter endpoints passed. Every report contains exactly
  `propext`, `Classical.choice` and `Quot.sound`, with no project or
  native-evaluation axiom. The reproducible commands are in the
  [protocol guide](lean/Protocol/README.md#validation). These endpoints retain
  their explicit application and runtime hypotheses.
- The full default `lake build` passed (7,512 jobs), including the broader
  `Protocol`, `TCB` and `Proximity` compatibility aggregates. Both this and
  the focused build used `LEAN_NUM_THREADS=1` locally. These are local builds
  with the pinned dependencies, not a claim of an executed hosted CI run.
- That milestone's source inventory contained 193 Lean files including the Lake
  configuration. The source scan found no active `sorry`/`admit` and seven
  explicit project axioms in the concrete cited-bound module. The focused
  protocol import closure does not import that module; source scanning is
  distinct from the theorem-dependency report.

The protocol queue and [scope](papers/paper2/SCOPE.md) retain storage backend/lifecycle refinement,
mint/burn policy, concrete application/security profiles, Rust refinement and
consensus finality as separate work. The legacy `Chain` aggregate remains a
compatibility import; its spectral identity, fork choice and raw edge-sum
balance are not the semantics of the new resource kernel.

#### Mathematics and storage follow-up

The 2026-11-05 follow-up completes the four generic formalization tasks
Q04--Q07: actual all-parameter fields/subgroups, the full list phase split and
real safe interval, the boundary-field real supremum/nonattainment, and the
attained generic distance/covering/good-challenge interface. All nine named
standalone coding statements now have Lean endpoints; `ProximityPrize` has
passed its expanded aggregate build. Its local import closure has 25 modules
and contains neither the project's cited-bound module nor legacy `Chain`.

The coordinated build
`lake build ProximityPrize Sheaf.ObservationQuotient Protocol.Storage.Core Protocol.Storage.Examples Protocol.Storage.CanonicalRS`
passed (7,447 jobs), including all six projection/gate levels and the actual
canonical observation join. The expanded full default `lake build` also
passed (7,530 jobs), including the broad protocol compatibility aggregates.
Both used `LEAN_NUM_THREADS=1` with the unchanged Lean/Mathlib pins. These
local results do not assert that hosted CI has run. The fresh forty-endpoint
theorem-dependency audit passed with exit status zero and exactly forty
reports: 36 contain exactly `propext`, `Classical.choice`, `Quot.sound`;
four additionally contain `Lean.ofReduceBool` and `Lean.trustCompiler`.
The latter are the boundary-field real threshold and three optional
canonical-field adapter endpoints. No selected endpoint uses a project
cited-bound axiom or `sorryAx`; explicit application/codec/gate/persistence
hypotheses remain. The validation guide lists all forty declarations and the
four native dependencies.
The 64-module focused storage-core import closure has neither `CitedBounds`
nor `Chain`; source import inspection is distinct from the axiom report.
That earlier source inventory had 212 Lean files including the Lake
configuration. A comment-aware scan finds no active `sorry`/`admit`, and
exactly seven project axioms in the existing concrete cited-bound module.
The local module graph has no import cycles. The [validation guide](docs/MATH_STORAGE_VALIDATION.md)
contains reproduction commands for the expanded theorem audit.

The source profiles and three distance meanings are recorded in the
[storage guide](lean/Protocol/Storage/README.md). The
[primary-source comparison](docs/PROXIMITY_NOVELTY_COMPARISON.md) documents
the established MCA event and sharper literature regimes, the elementary
endpoint reasoning, and the concrete commitment/codec comparison still
needed. New module presence, source identities or storage roots alone do
not establish a new geometric radius, primitive security or novelty claim.

#### History-anchor validation and pre-upgrade baseline

The 2026-11-05 history-anchor follow-up passed the focused build of
`Protocol.Storage.Anchor`, `ProjectionAnchor` and `AnchorExamples`
(7,417 jobs), then the full default build (7,532 jobs). The separate fresh
nineteen-endpoint dependency probe passed with exactly nineteen distinct
reports, each containing exactly `propext`, `Classical.choice` and
`Quot.sound`. None uses native-evaluation trust, a project axiom or `sorryAx`.
These runs used `LEAN_NUM_THREADS=1` and the **pre-upgrade Lean 4.24.0 pin**
with Mathlib `f897ebcf72cd16f89ab4577d0c826cd14afaafc7`.

The corresponding source inventory has 215 Lean files, no active
`sorry`/`admit`, no local import cycles, and the same seven existing
cited-bound axioms. Focused local closures are Prize 25, Protocol.Core 33,
Storage.Core 77 and CanonicalRS 58; all exclude legacy `Chain` and project
`CitedBounds`. The source-radius profile, actual hash/encoding/backend
contracts, dynamic geometry and finality remain open.

The user subsequently authorized updating the main Lean/Mathlib pins.
The preceding results are a preserved baseline, not validation of that newer
toolchain. The [validation guide](docs/MATH_STORAGE_VALIDATION.md) reproduces
the nineteen-endpoint probe. [Palomar preparation](docs/PALOMAR_SUBMISSION_PLAN.md)
tracks the separate statement/comparison/metadata work; Jacobian Paper 1 is
already under review and is only the reference setup.

#### Lean 4.35 validation

The following **pre-addition 4.35 baseline** precedes the twenty-module
follow-up recorded in P218--P229 and the current validation guide.

The authorized main-repository upgrade is complete. Lean `v4.35.0` and Mathlib
`56a005855ea17e0b0958f73ec801ae140b0a1679` have matching transitive checkouts.
All 214 source modules expose their public interfaces in the new module
system; the Lake configuration is the 215th Lean file. The full union of all
fifteen default targets and the explicit ledger/evidence/storage integration
targets passed with `LEAN_NUM_THREADS=4` (**9,233 jobs**).
The subsequent literal default `lake build` also passed (**9,228 jobs**).

Fresh dependency probes passed for forty mathematics/storage, nineteen anchor
and nine principal HCP/CVP declarations: **68 distinct reports**, 64 containing
exactly `propext`, `Classical.choice` and `Quot.sound`. The same four
boundary/canonical endpoints retain native arithmetic trust; on 4.35 this
prints as generated `_native.native_decide.ax_` certificate axioms. None of
these reports uses the seven cited-bound axioms or `sorryAx`.

The source scan finds no active proof holes or local import cycles and the
same seven explicitly declared cited-bound axioms. The four focused closure
counts remain 25/33/77/58. Explicit coordinate conversions and upstream API
repairs preserve the existing source/target propositions and metrics; they
do not supply Q08's codec/lifts, a nonempty far profile, authentication or
backend implementations. The [validation guide](docs/MATH_STORAGE_VALIDATION.md)
reproduces all three probes and distinguishes this run from the old pin.

### Manuscript alignment for the review package

Paper 1's appendix now explicitly inventories `Sheaf/Integral.lean`,
`Sheaf/HarmonicLattice.lean` and `TCB/HCPObservation.lean`: supplied integral
structure, integral coboundary preservation, the distinct exact component and
full Hodge sample, presented harmonic lattice endpoints and the typed
context/payload/snapshot join. Its wording retains the remaining modular
encoding and public-realization obligations; this is coverage of existing
results, not a new construction of those inputs.

The **pre-addition manuscript baseline** had 95 Paper 1 pages and 24 Paper 3 pages. Both final TeX builds
have zero warnings, undefined references/citations, missing glyphs and overfull
boxes. All 119 pages were rendered and visually checked, with changed pages
also reviewed at full resolution. At that milestone, Paper 1 stated the
conditional exact-component obstruction and closed-promise boundary condition.
Paper 3's ledger agreed with the nine generic endpoints and retained the
then-uninstantiated application profile.

The baseline canonical PDFs matched their then-current stable review exports.
Preserved baseline SHA-256:

- Paper 1: `64099877e8a362557d95cef37eec45c74661424d852e2a1223d6d6b1122a6cb9`.
- Paper 3: `c0cafc6a3c5fbf524a5c860e193f41fd0f029b8f7731bed0ec1605e93fb6b920`.

The subsequent native-metric baseline below superseded those older exports;
the new semantic manuscript revision is tracked separately in the central record.

### Native-metric manuscript baseline — 2026-11-05

The native-metric Paper 1 revision has **97 pages**, including genuine Plucker subspace/projector
recovery and the operative-kernel identification boundary. Paper 3 has
**28 pages**, including the intrinsic modular cellular profile, original-payload
comparison `d_C ≤ d_P = D_RS ≤ 2d_C`, the capacity-far payload, and explicit
challenge/Euclidean obstructions. Paper 2 has
[initial manuscript text](papers/paper2/DRAFT.md), without a TeX/PDF bundle.

Both final TeX passes have no undefined references/citations, missing glyphs
or overfull boxes. All **125 pages** were rendered and visually inspected,
with changed mathematical and ledger pages checked at higher resolution.
Eight Paper 1 and two Paper 3 underfull-box diagnostics remain; no visible
layout defect was found. The canonical and stable review PDFs match bytewise.

- Paper 1 SHA-256: `40f84530a5b0e95131c71189a9303b3e2ae0005ec4b9bcfead50846f22f6d46f`.
- Paper 3 SHA-256: `61d7589a75b48bc877c768df0795059220af7fc921ed6f681e8e5b391a8ab9e7`.

That native-metric Lean baseline is P229: expanded/default builds
9,253/9,248 jobs and 139 selected audited declarations. The newer actual
semantic implementation is P231--P236; its validation is recorded separately. The shared development register intentionally
retains historical milestones; the planned Palomar release will select a
small statement/proof closure and matching account, excluding development
archives and plans. The local human-review package is broader and is not a
Palomar submission. Publication and protected comparison have not occurred.

### Actual homological HCP implementation — 2026-11-06

P231--P235 construct the scoped five-module example and its conditional
artifact interface. The selected mathematical public input remains `(class,b)`;
the weighted example compares actual integer encodings two/one at the same
raw `(1,2)`. The private/public/selective-opening levels already stated in
Paper 1 Section 5 remain unchanged. Concrete byte access, snapshot/manifest
bindings, full-Plucker disclosure, recipient key delivery and rotation belong
to Paper 2’s profile and cannot be inferred from the small observation theorem.

The new static inventory has 239 source modules plus the Lake configuration;
all have public interfaces, with no active holes, unresolved local imports or
cycles and no new project axioms. New focused closures are CochainModel 8,
cellular axis family 8, HCP axis integration 19, generic TCB realization 23 and
concrete TCB axis adapter 30. Along with the seven native-profile closures,
all twelve exclude `Chain` and `CitedBounds`. Final expanded/default builds
pass 9,258/9,253 jobs. The fresh public-facade probe passes 235 distinct
selected reports: 199 standard-only (194 exact-three, five subsets) and
36 retaining old native certificates. The 96 new reports are all standard-only
(94 exact-three, two subsets); the 139 retained sets are identical. No selected
report uses a cited-bound axiom or `sorryAx`. The
[central validation record](docs/MATH_STORAGE_VALIDATION.md) holds reproducible
artifacts under `cellular-hcp-*` and separately records the new Paper 1 PDF
revision; the 97/28-page figures and hashes above remain the native-metric
manuscript baseline.

The revised Paper 1 has **99 pages**. Its final TeX pass has no LaTeX warnings,
undefined references/citations, missing glyphs or overfull boxes; eight
underfull-box diagnostics remain without a visible layout defect. All 99 pages
were rendered and visually inspected, with pages 21--23, 87 and 94--95 also
checked at higher resolution. Paper 3 is unchanged at 28 pages and retains its
previous visual review. Both canonical PDFs match their stable review exports.
The local `cellular-hcp-pdf-qa.json` records this check and the preserved
97-page Paper 1 baseline.

- Current Paper 1 SHA-256: `beb20f8c4a67ef4afcd0bfe950cfb444cfaf38b9abba1c3150fa0c2a3930a213`.
- Unchanged Paper 3 SHA-256: `61d7589a75b48bc877c768df0795059220af7fc921ed6f681e8e5b391a8ab9e7`.

### First public-observation profile — 2026-11-06

P237--P239 specify and implement the first storage-facing values and access
boundary in Paper 2 §2.1. The base release retains the original payload and
all six context-key coordinates. The sealed manifest release retains the
same base, actual root and ordered slot/digest directory. A public class
announcement need not reveal `b`; the named HCP disclosure adds the same
sample's `(class,b)` explicitly. None is a serializer or a completed adversary
transcript. Public proof/opening/history extensions retain their own binding
contracts and must enter any eventual security experiment.

The current expanded/default builds pass 9,259/9,254 jobs. The selected audit
has 268 reports: 232 standard-only and 36 retaining existing native arithmetic
certificates. All 33 added reports are standard-only, including seven
axiom-free; all 235 preceding sets are unchanged. The source scan has 240
modules/241 Lean files and no active holes, unresolved imports or cycles.
The [central validation guide](docs/MATH_STORAGE_VALIDATION.md#current-public-observation-profile--2026-11-06)
records exact counts, closures and reproducible checks. Papers 1 and 3 and
both reviewed PDFs are unchanged in this step. Recipient delivery, rotation,
byte codecs and cryptographic privacy remain subsequent obligations.

### Recipient recovery and rotation — 2026-11-06

P240--P245 preserve integer coefficient plaintext under an actual integral
chain isometry and declared encoding law. The exact partial decoder reads the
observed cochain; direct target and retained-base/inverse recovery agree on
valid encoded inputs. The finite axis rotation proves the law for every
integer and moves `(1,2)` to `(2,1)` while retaining two; the fixed-input right
sample instead encodes one. Original bound-sample transport derives payload
migration from the existing decoded-component fields. Recipient receipts retain
actual contexts, private rotation and envelope under explicit channel/policy
relations. No fresh sampler, secure channel, caller authentication from public
labels, replay prevention, erasure or privacy theorem is inferred.

At that recipient-rotation milestone, expanded/default builds pass 9,266/9,259
jobs; the 355-report
public-facade audit has 319 standard-only and 36 old-native results. All 87
added reports are standard-only and all 268 earlier dependency sets are
unchanged. The static scan covers 247 modules/248 files with no holes, cycles
or unresolved imports; all twenty recorded closures exclude legacy `Chain`
and `CitedBounds`. The [validation guide](docs/MATH_STORAGE_VALIDATION.md#current-recipient-recovery-and-rotation--2026-11-06)
records exact groups, closures and reproducible checks. The preceding
public-input and earlier milestones remain dated baselines. Papers 1 and 3
and both reviewed PDFs are unchanged; Paper 2 §6.1 carries the new account.

### Conditional owned-resource transition — 2026-11-06

P246--P252 fix the first public-ID owned-resource profile and construct the
actual checked candidate and successor. Resource checks and signature/payload
results at the trusted interpretation derive validity; the checked packet
stores no validity premise. Acyclic source/content/intent/packet/block inputs,
exact original artifact/context/input manifest, real private candidate/transfer
compression witness and optional matching final quorum are explicit. Economic
catalog values are separate from cochain coordinates and Hodge plaintexts.
Secure primitives, codecs/runtime refinement, state origin, backend/finality
and broader ledger/geometry/private-nullifier profiles remain separate.

At that owned-transition milestone, expanded/default builds pass 9,274/9,267
jobs. The 500-report selected
audit has 464 standard-only and 36 old-native results; all 145 additions are
standard-only and all 355 prior sets are unchanged. Static scan: 255 source
modules/256 files with no holes/cycles/unresolved imports, same seven isolated
axioms and 28 focused closures excluding legacy `Chain`/`CitedBounds`. The
[validation guide](docs/MATH_STORAGE_VALIDATION.md#current-owned-resource-transition--2026-11-06)
records exact groups and reproduction. Earlier milestones remain dated;
Papers 1/3 and reviewed PDFs are unchanged; Paper 2 §6.2 carries this step.

### One-shot sampled integrity — 2026-11-06

P253--P257 separate actual checking algorithms from ideal soundness contracts,
retain the original context and parsed candidate, and reduce accepted-invalid
outcomes to actual authorization or payload false acceptance. The complete
selected transfer release exposes public resource/signer identifiers. One
explicit PMF and auxiliary input give the conditional error sum without
independence; actual primitive bounds and adaptive/oracle/privacy claims remain
open. External-history authentication, source origin, runtime and finality are
outside the event model.

At that one-shot milestone, expanded/default builds pass 9,278/9,271 jobs. All
605 selected reports
pass: 569 standard-only and 36 old-native. All 105 additions are standard-only;
all 500 preceding dependency sets match exactly. The static scan covers 259
source modules/260 files and 32 scoped closures, with no new holes, cycles,
unresolved imports or cited-bound assumptions. The
[validation guide](docs/MATH_STORAGE_VALIDATION.md#current-one-shot-integrity--2026-11-06)
records exact counts and reproduction. Paper 2 §6.3 owns the security account.

### Actual primitives and TCB comparison — 2026-11-07

P258--P262 keep primitive bytes, owner/key/message/query history, backend
statements and original cochain acceptance separate. Exact checker agreement
and five actual failure events compose under the same PMF. The existing worker
spectral signatures and matrix checks do not supply the missing original-object
joins or error estimates. The ordinary graph prototype has a constructive
same-payload/different-message obstruction, compatible with kernel-quotient
openings and distinct from general private cellular restrictions or C¹ binding.

At that primitive-comparison milestone, expanded/default builds pass
9,281/9,274 jobs. All 667 selected reports
pass: 631 standard-only and 36 existing-native; all 62 additions are standard-only
and all 605 earlier dependency sets match. Static coverage is 262 modules/263
files and 35 scoped closures without new holes, cycles or unresolved imports.
The [validation guide](docs/MATH_STORAGE_VALIDATION.md#current-primitive-and-tcb-comparison--2026-11-07)
records source, dependency, runtime-comparison and unchanged-PDF evidence.
Paper 2 §6.4 and the [protocol comparison](docs/PROTOCOL_PARITY_QUEUE.md#actual-primitive-comparison-and-tcb-joins--2026-11-07)
record implementation gaps explicitly. No numerical primitive or privacy claim
follows from these conditional reductions.

### Existing-object signing and native-plan reconciliation — 2026-11-07

P263--P268 reuse the full intent, packet codec, key map, history and release
carrier. The checker/profile execution equation is constructed; authorized
fixed-policy issuance and foreign-domain exclusion make queried-unauthorized
mass zero, leaving four same-PMF errors. Exact checked-release signature
coverage requires independent authorization. The recovered native path-space
plan targets message-bound possession of the actual private representative/path;
no Ed25519 owner scheme, central credential issuer or replacement fibration is
selected. Existing Hodge-blinded and fibration objects retain their roles.

At that owner-signing milestone, expanded/default builds pass 9,284/9,277 jobs. All 728 selected reports
pass: 692 standard-only and 36 existing-native; all 61 additions use only standard
logical axioms and all 667 preceding dependency sets are unchanged. The
[validation guide](docs/MATH_STORAGE_VALIDATION.md#current-owner-signing-reuse-and-issuance--2026-11-07)
records that 265-module/266-file coverage and 38 scoped closures, plus
reproducible checks. [Plan provenance and primitive roles](docs/PROTOCOL_PARITY_QUEUE.md#recovered-native-authentication-plan-and-existing-primitive-layer--2026-11-07)
remain explicit; native proving/verification, knowledge/unforgeability, codec,
key/setup and arbitrary-history execution are separate completion requirements.

### Native path transport and finite witness handoff — 2026-11-07

P269--P273 construct same-path transport under supplied realization, finite
credential-opening/path validity and exact proof-backend owner verification.
The implementation reuses the existing mathematical and byte-verifier objects;
a duplicate proof and stale replacement-type plan are pruned. Concrete
realization/coherence, authenticated credential setup, codecs and message-bound
proof/knowledge/unforgeability security remain separate obligations.

Expanded/default builds pass 9,285/9,278 jobs. All 750 selected reports pass:
714 standard-only and 36 existing-native. All 22 additions use only standard
logical axioms, and all 728 preceding dependency sets are unchanged. The
[current validation guide](docs/MATH_STORAGE_VALIDATION.md#native-path-transport-and-finite-witness-boundary--2026-11-07)
records the 266-module/267-file inventory, 39 scoped closures and reproducible
probe. These are conditional mathematical/execution joins, not completed
native cryptography or a new Paper 1/3 radius claim.
