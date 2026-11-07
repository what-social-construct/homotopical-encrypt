# Semantic Parity Queue (Lean ↔ Python ↔ Rust)

The [manuscript parity register](../SEMANTIC-PARITY.md) separately records
paper ownership, shared definitions and notation, and manuscript issues. This
queue tracks cross-language implementation refinement.

This queue tracks implementation mismatches that should be resolved after the
proof-status/axioms split.

Canonical mathematical object and morphism status is owned by the verified
register in [`SEMANTIC_OWNERSHIP.md`](SEMANTIC_OWNERSHIP.md). This queue tracks
cross-language refinement and disposition; it does not redefine those objects.

## Current reconciliation — 2026-11-05

The rows below preserve earlier audit identifiers and findings. The following
table supersedes stale completion language and earlier runtime-profile choices;
it does not reclassify every legacy implementation as a refinement.

| Surface | Current mathematical/source status | Remaining refinement or application work |
|---|---|---|
| Validation and main toolchain | Lean 4.35.0 and Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679` pass the full aggregate/integration union: 9,233 jobs covering all fifteen default roots and additional ledger/evidence/storage/anchor/canonical targets. All 68 distinct endpoint audits pass: 64 standard-only and the same four boundary/canonical endpoints with native certificates; all nineteen anchor and nine HCP/CVP endpoints are standard-only. | Keep the earlier Lean 4.24 baseline separate. The four native reports now name generated `_native.native_decide.ax_*` constants; their trust boundary remains. Use the [shared baseline/current record](../SEMANTIC-PARITY.md#history-anchor-validation-and-pre-upgrade-baseline) and [validation guide](MATH_STORAGE_VALIDATION.md). This is neither a concrete runtime refinement nor a Palomar comparison. |
| `Axioms/` versus concrete mathematics | Interfaces state supplied propositions/maps and prove their stated consequences. Concrete `Sheaf/` definitions supply the actual cellular coboundaries, degree-one Hodge operator, projections and exact-subspace distance. | Instantiate the intended mathematical and security profiles and prove runtime refinement. An interface field, a conditional theorem and a concrete algorithm have different status. The seven cited-bound axiom declarations remain separate. |
| Bounded Paper 2 transition and quorum | `Protocol/Ledger` computes the successor and proves conservative flow, nullifier preservation/replay exclusion, candidate-indexed evidence and same-proposal acceptance-quorum attachment. | Resource/authorization/nullifier/root/signature implementations remain profile inputs. Geometry or epoch migration, rounds/locks, finality and liveness are additional work. |
| Storage-to-history join | `Storage/Anchor.lean` joins the actual interpretation and whole artifact to an exact sealed manifest under an object-indexed history-inclusion relation. `ProjectionAnchor.lean` retains the final typed prefix, the same received word and actual gate database. `AnchorExamples.lean` exercises transfer/quorum/receipt and substitution rejection. These modules pass the Lean 4.35 aggregate/integration build, with all nineteen selected anchor endpoints standard-only. | Implement canonical authentication and backend contracts, public/private serialization and retrieval. The semantic join chooses neither a new manifest-root wire field nor a concrete hash preimage. No concrete Rust/Python realization is claimed. |
| Temporary bus and retained context | `Context` is snapshot-bound with exact acceptance separate. `StateBus` is an immutable witness-local projection record; the checkpoint engine requires an exact-seal persistence receipt before local consumption. | Earlier per-commit allocation/reset wording is a proposed profile, not settled runtime granularity. Global run freshness, replay across independent histories, atomicity and physical erasure remain explicit. |
| Operators and source scores | Harmonic recovery uses `P_H`; the true operator is `Delta_1`; the kernel-normalized residual uses `I-P_H`; decoded exactness distance is `‖P_{(im δ₀)⊥} b‖`. | These are distinct maps/scores. A selected source-to-coding comparison and nonempty far family remain Q08; neither storage anchoring nor a pullback definition supplies them. |
| Plucker and public hash views | The raw projective quotient includes the zero orbit and imposes no decomposability predicate; `ValidRawCoordinate` imposes nonzero/decomposable/selected-relation validity. `HashedPluckerShadow` carries the actual mathematical shadow plus a binding proposition. | Construct the selected admissible chart, public encoding and hiding/verification profile where needed. A raw quotient or digest does not construct a moduli stack or conceal a valid harmonic-subspace coordinate. |

See the [categorical architecture](CATEGORICAL_ARCHITECTURE.md) for the
distinction between application cells, public history references and the peer
network. `docs/CHAIN_NETWORK_OBJECT_REVIEW.md` is a local working source for
the historical object review and is outside the public bundle. The historical
runtime inventories below retain their own audit scope.

## Reference Policy (Lean-first naming hygiene)

When code comments/docstrings cite formal backing, use current Lean module
paths only:

- `lean/Hardness.lean`
- `lean/HCP.lean`
- `lean/Sheaf/*`
- `lean/Laplacian.lean`
- `lean/Tsirelson.lean`
- `lean/Chain.lean`
- `lean/Axioms/*` (assumption interfaces during proof burn-down)

Avoid legacy names (`hardness_proof.lean`, `math_audit_hcrypt.lean`,
`tsirelson_update.lean`, `framework_consolidation.lean`) in active source
comments/docs. If a legacy result is historically relevant, reference it as
"archive lineage" and pair it with the current module path.

Suggested enforcement (lightweight): add a CI grep guard on `src/` and `docs/`
that fails on legacy filenames.

---

## Audit Order And Classification

The migration audit proceeds in dependency order:

```text
primitives -> invariants -> proofs -> geometry -> crypto
           -> chain -> network -> consensus -> oracle
```

A stage is classified before the next stage is treated as authoritative. This
is an audit order, not a claim that every old module must survive or be
formalized.

Current Lean objects and theorem statements are canonical whenever an older
Python or Rust object overlaps them. A runtime artifact may implement a Lean
interface, provide numerical test data, or reveal a missing obligation. It may
not redefine the canonical mathematical semantics.

Current pass position:

```text
primitives [classified] -> invariants [classified] -> proofs [classified]
  -> geometry [classified] -> crypto [classified] -> chain [classified]
  -> network [next] -> consensus [pending] -> oracle [pending]
```

Use three independent status axes:

- **Lean coverage:** Unmapped / Interface-only / Specified / Proved /
  Runtime-refined.
- **Semantic verdict:** Preserve / Preserve after rename / Partial / Conflicts
  with canonical model / Rejected.
- **Disposition:** Active reference / Test oracle / Quarantine / Deprecation
  candidate / Archived / Deleted.

The lifecycle is:

```text
Discovered -> Classified -> semantics captured or explicitly rejected
           -> replacement/tests verified -> deprecated -> archived/deleted
```

Rejecting an old claim is a valid completion of semantic capture. Wrong Python
behavior must not be translated into Lean merely to obtain nominal parity.

### Pass P0: `src/primitives/`

> **Archive status (2026-07-23):** this complete legacy layer now lives at
> `docs/archive/python/src/primitives/`. The row-level dispositions below
> preserve the audit that justified the retirement; they no longer mean that a
> file remains importable from `src/primitives/`. The remaining Python tree is
> intentionally unsupported until its later runtime-parity rewrite.

| Python file | Canonical Lean owner / coverage | Semantic verdict | Current disposition and next action |
|---|---|---|---|
| `algebra.py` | Lean-side exterior construction is proved in `Proximity/GrassmannianPlucker.lean`; correspondence with NumPy coordinate order/sign/normalization is Unmapped. | Preserve `wedge`/`wedge_k` as candidate numerical helpers pending parity tests. The generic coboundary-commutation claim is unsupported, and the non-Euclidean `hodge_star` omits the inverse-metric action. | Active reference, but split or reject the non-Euclidean Hodge-star branch and add coordinate/shape/metric tests. |
| `cochain.py` | `Sheaf/CellComplex.lean` owns cells/incidences, `Sheaf/Cellular.lean` owns typed (C^0 -> C^1 -> C^2), and `Sheaf/Commitment.lean` owns the downstream exact-(C^1) envelope; Python correspondence is Unmapped. | Preserve only as an identity-stalk graph prototype. It implements (delta_0) but not the claimed general (delta_1); its degree-zero Laplacian has no direct new-core counterpart; and its “message is harmonic” language conflicts with the exact-(C^1) model. | Migration-blocked deprecation candidate. Inventory consumers, rename the prototype honestly, and keep only fixtures that refine the Lean types. |
| `divergence.py` | No mathematical Lean owner; `Axioms/Grassmannian.lean` has only an abstract scalar eligibility divergence. | Unselected research metrics, not homotopy-equivalence criteria. | Deprecated in place and removed from the package export surface; later archive unless Paper 2 selects and specifies one metric. |
| `grassmann.py` | Search-space and Plucker-side Lean results are Proved; metric/Karcher properties in `Axioms/Grassmannian.lean` are Specified; Python refinement is Unmapped. | Projector, principal-angle, distance, and forward-Plucker routines are candidate numerics only after rank/shape/projector validation. General `from_plucker`, the current “parallel transport,” and exp/log-dependent Karcher claims do not refine the Lean obligations as written. | Active prototype consumed by consensus; quarantine invalid branches and add validation/parity tests before archival decisions. |
| `homotopy.py` | Abstract paths/classifier fibers are Interface-only in `Axioms/HelferFOL.lean`, `Axioms/HomotopyClass.lean`, and `Axioms/Fibration.lean`; `Axioms/PythonHomotopyRefinement.lean` is an incomplete snapshot shim and is not a path refinement. | Conflicts with Lean where equality of a finite invariant tuple is called homotopy equivalence, or arbitrary matrices plus a hash are called a rotation proof. | Semantic deprecation candidate with active chain/invariant consumers. Migrate consumers to encodings/refinements of the Lean classifier and supplied-path interfaces. |
| `k_theory.py` | No Lean owner. | Reject as normative mathematics: the curvature, characteristic-class, and characteristic-cycle calculations are heuristic and unused. | Deprecated in place and removed from the package export surface; later archive as explicitly historical research only. |
| `natural.py` | General sheaf-coherence obligations are Specified in `Axioms/SheafCoherence.lean`; specialized projection-gate composition is Proved in `Proximity/Gates.lean`; Python refinement is Unmapped. | Its abstract naturality equation is sound, but it conflicts as a validator: missing components/restrictions pass vacuously, and pullback/pushforward/composition invent or silently collapse untyped data. The docstring also misreads Helfer's free syntactic \(h^=\)-fibration as a universal \(BGL(n)\) credential bundle and derives an unsupported universal-hardness claim. | Quarantine as a semantic validator; replace with a typed finite-cell map before migrating active consumers, and do not preserve the universal-fibration migration story as a security claim. |
| `persistence.py` | No Lean owner. | H0 union-find may be a useful experiment, but H1 death times are fabricated and the greedy routine is not bottleneck distance. | Deprecated in place and removed from the package export surface; preserve a narrowly named H0 experiment only if it gains an identified consumer. |
| `spectral_bounds.py` | `Axioms/SpectralBounds.lean` and `Axioms/OracleModality.lean`; active Python imports use `src/proofs/spectral_bounds.py` instead. | Partial duplicate. It overstates the Lean admissibility field as a derivation and conflates a marginal gate result with final acceptance. | Deprecated in place as a historical duplicate; no active importer or unique legitimate test fixture remains. |
| `stalk.py` | Stalk/restriction mathematics is Proved in `Sheaf/Cellular.lean`; snapshot and oracle boundaries are Specified in `Sheaf/Commitment.lean` and `Axioms/OracleModality.lean`; Python refinement is Unmapped. | Preserve only after splitting mathematical stalk data, public-classifier projection, and runtime storage. `StalkProjection` changes context at one cell and is not a face-to-coface restriction map; a vertex assignment is not a sheaf/global section; truncation is not the nonlinear classifier; and raw NumPy bytes are not canonical encoding. | Active legacy container; migrate geometry/chain/invariant consumers before deprecation. |
| `__init__.py` | No independent owner. | Its “foundational primitives” surface currently promotes exploratory and conflicting modules. | Shrink exports after the rows above are migrated or archived. |

Cross-stage blockers discovered in this pass:

- `algebra.py` is consumed by `grassmann.py`, `invariants/algebraic.py`, and
  the invariants package export surface.
- `cochain.py` is consumed by geometry, crypto, invariants, chain, and
  consensus.
- `grassmann.py` is consumed by consensus.
- `homotopy.py` is consumed by chain and invariants.
- `natural.py` is consumed by chain.
- `stalk.py` is consumed by geometry, chain, and invariants.
- `k_theory.py`, `persistence.py`, and `divergence.py` have no direct active
  consumers beyond package re-export.
- `primitives/spectral_bounds.py` is an orphan duplicate pending the
  proofs-stage audit.

Deprecation checkpoint: `k_theory.py`, `persistence.py`, `divergence.py`, and
`spectral_bounds.py` first passed the narrow no-consumer archive gate. The later
whole-layer retirement deliberately archived the remaining prototypes as well
after recording their surviving mathematical obligations. That retirement
accepts unresolved imports in the deferred Python track; it is not evidence
that the old Python runtime passed a post-move checkpoint.

### Pass I0: `src/invariants/`

> **Archive status (2026-07-23):** this complete legacy layer now lives at
> `docs/archive/python/src/invariants/`. The dependency notes below are retained
> to document the intentional break in the deferred Python tree. None of these
> modules remains an active semantic authority or supported import surface.

This folder does not currently refine the Lean model.  Its reusable content is
mostly numerical diagnostics; its equivalence and acceptance claims are legacy
semantic authority.

| Python file | Canonical Lean owner / coverage | Semantic verdict | Current disposition and next action |
|---|---|---|---|
| `algebraic.py` | Cup products, Massey products, and cohomology rings are Unmapped; Lean currently carries only abstract Betti/classifier fields. | Rejected as a semantic gate. Cell counts and Betti numbers are conflated, cup rank is estimated, subdivision invariance fails, restriction maps are ignored, and the reported triple product is not a Massey product. | Deprecation candidate. Preserve no acceptance authority; retain a computation only after giving it a mathematically correct, narrow specification. |
| `cohomology.py` | Cell incidences, coboundaries, square-zero, and degree-one Hodge structure are Proved in `Sheaf/CellComplex.lean`, `Sheaf/Cellular.lean`, and `Sheaf/Hodge.lean`; quotient-cohomology/Betti computation and Python refinement are Unmapped. | Partial. Rank, shape, and square-zero numerics may survive after rewrite. Current code silently accepts missing (delta_1), hardcodes square-zero, hides negative results, mixes simplex counts with sheaf dimensions, and computes degree-zero ratios even for a supplied (Delta_1). | Active diagnostic through `unified.py`; quarantine semantic results and rewrite with explicit degree/coefficient/sheaf hypotheses. |
| `fibration.py` | `Axioms/Fibration.lean` is Interface-only for transport; cellular restrictions are Proved in `Sheaf/Cellular.lean`; Python refinement is Unmapped. | Preserve `assert_orthogonal` only as a matrix diagnostic. Uniform stalk dimension is not trivial holonomy, orthogonal edge maps need not give identity loop transport, flatness is not global triviality, and the curvature routine is a stub. | Partial deprecation; keep the one active diagnostic under a narrower name and remove inferred fibration/holonomy authority. |
| `harmonic.py` | The concrete degree-one operator and subspaces are Proved in `Sheaf/Hodge.lean`; generic projection geometry is Proved in `Laplacian/Hodge.lean`; Python refinement is Unmapped. | Partial but architecture-conflicting. Projectors/range checks are useful only with a validated symmetric operator and explicit degree. The decomposition ignores the upper coboundary and labels the residual coexact; active crypto callers use (Delta_0), while Paper 1 uses (Delta_1) and exact committed (C^1). | Security-critical legacy runtime track. Split degree-tagged diagnostics from basis-dependent encryption before any archival move. |
| `homotopical.py` | Paths, public fibers, and transport are Interface-only in `Axioms/HelferFOL.lean` and `Axioms/HomotopyClass.lean`; all Python algorithms are Unmapped. | Rejected. Betti numbers do not determine truncation level; (ker Delta) is not a path/automorphism space; simplex dimension and (beta_0) are not dependent-sum/product ranks; and matching these outputs does not prove homotopy equivalence. | Deprecation candidate reached through `unified.py`; remove semantic authority and do not translate these algorithms to Lean. |
| `spectral.py` | Exact spectral equivalence and non-invariance under homotopy are Proved in `Laplacian/Spectral.lean`; the PoV window and boundary policy are Specified in `Axioms/SpectralBounds.lean` and `Axioms/OracleModality.lean`; Python refinement is Unmapped. | Preserve eigensummaries/heat traces as diagnostics only. Spectrum is not a homotopy classifier; the PoV bound is not derived for all sheaf Laplacians; the fingerprint is noncanonical; and the reported Wasserstein metric is padded unnormalized (L^1). | Active through `unified.py`; strip security/equivalence authority and add canonical numeric/serialization contracts where retained. |
| `unified.py` | Classifier and stage obligations are Specified by `Axioms/HomotopyClass.lean`, `Axioms/StageAdmissibility.lean`, exact/spectral gates, and `Axioms/OracleModality.lean`; `RefinesTransactionCriticalPass` is not discharged. | Conflicts with the canonical model. It upgrades classifier equality to homotopy equivalence, includes exact spectrum despite Lean's non-invariance theorem, ignores `topology_hash` in `.matches()`, uses noncanonical hashing, hardcodes degree zero, and omits key-image/balance/topos obligations. | Highest-priority quarantine/rewrite. Credential keygen and wallet/block consumers prevent removal; replace with a certificate covering the full Lean stage bundle and canonical oracle decision. |
| `__init__.py` | No Lean owner; intended orchestration counterpart is only Specified. | Rejected as a validator. `StagedValidator()` is not constructible with the current `UnifiedInvariantValidator`, then refers to nonexistent fields; one stage is unconditionally passed. | Deprecation candidate, but prune only after explicit consumers and package re-exports migrate. |

Cross-stage blockers discovered in this pass:

- `harmonic.py` is used by encryption, decryption, the cohomological MAC, fiber
  transport, and `unified.py`; it cannot be archived wholesale.
- `unified.py` is used by credential key generation, wallet storage, and block
  consensus, so its rewrite is a protocol/security prerequisite.
- `cohomology.py`, `homotopical.py`, and `spectral.py` remain reachable through
  `unified.py` even where their direct proof-module imports are unused.
- `fibration.py` has one genuine runtime caller for the orthogonality
  diagnostic; the inferred holonomy/curvature surface is otherwise dead.
- The one-way Lean implication is path witness to equal classifier value under
  an explicit path-respecting hypothesis.  No Python invariant matcher may be
  presented as the converse.

The concrete `src/geometry/homotopy_path.py` audit is completed in G0 below.
Its matrix-orbit constructor is not a refinement of the abstract supplied path
witness or its classifier consequences.

### Pass P1: `src/proofs/`

Most files in this folder are named as proof systems but currently validate
only shapes, self-supplied summaries, or hash lengths. They are not runtime
refinements of the Lean theorem/TCB surface.

| Python file | Canonical Lean owner / coverage | Semantic verdict | Current disposition and next action |
|---|---|---|---|
| `anonymity.py` | Path/class semantics are Interface-only in `Axioms/HelferFOL.lean` and `Axioms/HomotopyClass.lean`; `HCP.lean` and `Hardness.lean` prove conditional hidden-operator ambiguity, not this ZKP's unforgeability. | Conflicts. Spectrum equality is promoted to class membership, supplied Laplacian-response data is unauthenticated, the mask is exposed, key images are length-checked, range proofs are structural, and balance permits large coordinate discrepancies. The bare coboundary does not supply the stated hiding/binding scheme. | Immediate quarantine. Remove acceptance authority from `chain/homotopy_transaction.py`; retain only narrowly named numerical fixtures. |
| `consensus.py` | PoV scoring/bounds are Proved or Specified in `Consensus/ProofOfValue.lean` and `Axioms/SpectralBounds.lean`; authenticated quorum kernels are Proved in `Protocol/Consensus/*`. | Conflicts. It is a competing single-node validity mechanism, not the current gated score plus authenticated quorum. Topology/harmonic checks are stubs, signatures and proof dictionaries are forgeable structural checks, hashes omit relevant data, and joint overspending is possible. | Quarantine/deprecation candidate with active `block_producer.py` and package-export consumers. Migrate consumers first. |
| `homotopical_zkp.py` | Hidden paths are Interface-only; isometric sheaf/HCP transport is Proved in `Sheaf/Equivalence.lean` and `HCP.lean`; ZKP soundness is Interface-only. | Conflicts. Orthogonal conjugation gives an isospectral matrix path, not a proved path of cellular-sheaf presentations. There is no secret/end-point ownership binding, unopened samples have no established relation, and the stated \(2^{-n}\) soundness does not follow. | Quarantine as a proof system; preserve only an isospectral-conjugation numerical test. Audit the Rust mirror jointly. |
| `homotopy.py` | Lean proves only supplied path witness to equal public class under an explicit path-respecting hypothesis; `Laplacian/Spectral.lean` rejects general spectral homotopy invariance. | Conflicts. Attacker-supplied Betti/gap/fingerprint data is promoted to homotopy equivalence; the verifier cannot verify the response/openings and the “interactive” version has no verifier. | Deprecation candidate. Remove semantic authority and package exports rather than translating it. |
| `spectral.py` | Exact spectral notions/non-invariance are Proved in `Laplacian/Spectral.lean`; the PoV window is Specified; proof-system obligations remain Interface-only in `Axioms/ZKP.lean` and `TCB/*`. | Rejected as a verifier. Commitments are not opened, ring verification is structural, the gap proof binds no verifiable value/bit decomposition/response, identity verification ignores its inner spectral proof, and native NumPy bytes are noncanonical. | Immediate quarantine. It is consensus-critical through `chain/block.py` and `chain/homotopy_transaction.py`; replacement must fail closed. |
| `spectral_bounds.py` | Boundary classification/action policy is Specified in `Axioms/SpectralBounds.lean` and `Axioms/OracleModality.lean`; fixed-point correspondence is Unmapped. | Preserve after rename/split. The fixed-point classifier is useful, but the geometric derivation is overstated and `gap_in_bounds_strict` accepts the marginal/hold region. | Active reference. Add finite/canonical parity vectors and separate `gate_admissible` from `final_accepted`. |
| `tsirelson.py` | Projector geometry is partly Proved in `Tsirelson.lean`; nonempty adversary bounds remain explicitly unproved specifications. | Partial. Geometry/sampling/dimension diagnostics are useful; the \(2^{-d}\) and bounded-quantum-advantage functions merely evaluate conjectured formulas and are not security proofs. | Test oracle. Split numerical geometry from conjectural security analysis and prohibit the latter from protocol claims. |
| `__init__.py` | No independent Lean owner. | Rejected as a “Unified Proof System” surface because it promotes quarantined prototypes as ZK, identity, anonymity, and consensus proofs. | Quarantine and prune exports as consumers migrate. |

Read-only adversarial spot checks confirmed that the current verifiers accept:

- an out-of-bounds fabricated spectral-gap proof;
- fabricated homotopy, class-membership, harmonic-range, and ring proofs;
- spectral identity while ignoring its inner spectral proof; and
- an edge-coordinate imbalance of `99`.

Cross-stage blockers discovered in this pass:

- `chain/block.py` calls `prove_spectral_gap_in_bounds` with the wrong return
  shape, catches the resulting exception, falls back to a 32-byte hash, and
  later accepts a structurally valid 32-byte fallback.
- `chain/homotopy_transaction.py` verifies proof values against fields supplied
  by those same proof objects and permits missing class/range proofs.
- `rust/node/src/crypto/geodesic_zkp.rs` mirrors the unsupported geodesic proof,
  while `rust/node/src/consensus/pov.rs` consumes it.
- `chain/block_producer.py` consumes the proof-folder checkpoint validator
  whose topology and harmonic checks are stubs.
- Future checkpoint certificates must bind the external snapshot, accepted
  exact \(C^1\), stage artifact, parameters, and predecessor checkpoint.
  Current proof objects are self-attested, timestamped, and native-byte
  encoded; they must not become `SheafBlock` leaves.

### Pass G0: `src/geometry/`

Status: **Audited, not migrated.** The canonical mathematical core is already
in Lean: `Sheaf/CellComplex.lean` and `Sheaf/Cellular.lean` define a finite
oriented two-complex, typed stalk dimensions, restriction maps, both
coboundaries, and square-zero; `Sheaf/Hodge.lean` defines the true degree-one
operator
\[
  \Delta_1=\delta_0\delta_0^*+\delta_1^*\delta_1;
\]
and `Sheaf/Equivalence.lean` proves its isometric naturality. The active Python
cipher instead consumes a mutable graph-level degree-zero approximation.

| Python file | Canonical Lean owner / coverage | Semantic verdict | Current disposition and next action |
|---|---|---|---|
| `__init__.py` | No independent owner is needed. | Its eager facade imports the archived invariant package and promotes canonical adapters beside speculative objects. Normal `src.geometry` imports are therefore already broken after the deliberate primitives/invariants archival. | Replace only after the surviving adapters are selected; the future facade must export supported refinements rather than historical claims. |
| `sheaf.py` | The full object is Proved in `Sheaf/CellComplex.lean` and `Sheaf/Cellular.lean`; Python refinement is Unmapped. | Partial graph prototype. Its “stalks” are mutable values rather than typed vector spaces; missing data/maps silently become one-dimensional zeros/identities; it has no \(\delta_1\) or composition law. `build_cech_nerve` constructs a two-dimensional clique/flag complex from a graph, not a Čech nerve supplied with intersection witnesses. | Rewrite as a validated runtime encoding of the Lean two-complex and sheaf. Rename the graph builder; retain the context-overlap builder only with closure, incidence, dimension, and canonical-order validation. |
| `sheaf_laplacian.py` | The proper degree-one operator, kernel, projection, and naturality are Proved in `Sheaf/Hodge.lean` and `Sheaf/Equivalence.lean`. | Architecture conflict. The degree-zero matrix infers dimensions from payload values, invents identity maps, omits valid rectangular off-diagonal blocks, and can disagree with its own \(\delta_0^T\delta_0\). Cached matrices remain stale after mutation. `get_laplacian_1` ignores every sheaf restriction and stalk dimension and builds the scalar constant-sheaf incidence Laplacian. Harmonic projection is always degree zero. The asserted universal Tsirelson interval is unsupported; in particular \(\lVert I-R\rVert\) is not universally bounded by \(\sqrt2\) for \(R\in SO(n)\). | Highest-priority geometry rewrite if Python numerics are retained. Make the degree explicit, construct the matrix from validated typed coboundaries, and prohibit the current `get_laplacian_1` from backing Paper 1. |
| `hodge.py` | Degree-one Hodge subspaces and orthogonality are Proved in `Sheaf/Hodge.lean`; constructed noise/recovery is Proved in `Sheaf/HarmonicLattice.lean`. | Partial numerical helper. It builds bare constant-coefficient incidences rather than sheaf coboundaries, creates a dummy zero face row when no faces exist, ignores public tolerance parameters, swallows linear-algebra failures into zero projectors, returns projectors different from its post-hoc orthogonalized components, and calls the entire unknown nonharmonic complement “coexact” when adjacent coboundaries are absent. | Preserve only a strict, degree-tagged kernel projector. Rewrite full Hodge decomposition from validated \(\delta_0,\delta_1\), verify the Laplacian relation, and fail closed. |
| `homotopy_path.py` | Supplied path semantics are Interface-only in `Axioms/HelferFOL.lean`; Helfer equivalence and HCP transport are Proved conditionally in `Helfer/HomotopyEquivalence.lean` and `HCP.lean`. `Laplacian/Spectral.lean` proves spectrum is not generally homotopy-invariant. | Rejected as a homotopy certifier. Orthogonal conjugation gives an isospectral path in a symmetric-matrix orbit, not a path of cellular sheaves or fibrations; isospectrality is neither the required necessary condition nor a sufficient one. Samplewise “continuity” depends on step count and scale, and `evaluate` linearly leaves the claimed orbit. | Archive the semantic surface. If useful, retain only a plainly named `IsospectralMatrixOrbitPath` numerical experiment with no HCP/classifier authority. |
| `lattice.py` | The discrete Euclidean object and its bridge are Proved/Specified in `CVP.lean`, `Sheaf/Integral.lean`, and `Sheaf/HarmonicLattice.lean`. | Rejected. \((\mathbb Z/q\mathbb Z)^n\) is a finite module, not the Euclidean lattice used by CVP; modular dot products are not the CVP metric; real eigenvectors are not integral lattice generators; pseudoinverse-then-mod is neither lattice projection nor membership; and the advertised harmonic part is returned empty. | Archive and replace from Lean's explicit integral/harmonic lattice presentation. No live algorithm depends on its extraction/decomposition routines. |
| `noise.py` | `Sheaf/HarmonicLattice.lean` owns the mathematical noise witness \(\delta_0a+\delta_1^*c\) and proves orthogonality; distributions and lifecycle are runtime concerns. | Mixed runtime experiments. Defaults are NumPy PRNGs despite the security prose; the “heat-kernel” covariance includes an additional inverse-eigenvalue factor; the OU covariance branch ignores its mean-reversion/volatility parameters; and Hodge sampling inherits the invalid projectors and relabels residuals. | Keep generic OU only if a Paper 2 runtime consumer is selected. Rewrite exact/coexact sampling from explicit openings and a real CSPRNG; remove speculative heat/spectral samplers from the crypto surface. |
| `topology.py` | Paper 1 needs only the validated finite oriented complex in `Sheaf/CellComplex.lean`; no runtime refinement exists. | Rejected as a topology/security engine. Cell counts plus Euler characteristic do not determine both \(\beta_1,\beta_2\); the decoy embedding changes topology and extraction drops faces; “persistence entropy” is computed from Betti counts; missing restriction maps make coherence pass vacuously; graph-specific Cheeger/trace claims are applied to arbitrary sheaf Laplacians; and `compute_full_geometric_invariants` cannot construct its own report because required fields are omitted. | Archive this dead module. Later build a narrow, validated nerve-to-oriented-complex compiler if runtime topology input is required. |
| `fiber_bundle.py` | `Axioms/Fibration.lean` owns the abstract fiber/path boundary and explicitly assigns freshness, single use, wiping, and hostile-byte handling to Rust. | The small graph-transport core is salvageable after correction, but the rest conflicts. Cellular restrictions need not be invertible orthogonal transports; reverse-path inverse transport is wrong; an “ephemeral fiber” is only an accumulated random-walk matrix; its homotopy test checks \(Q^TQ=I\). Path-hint decryption ignores the key, the fallback is plaintext/nonharmonic, content transport does not use the relay key, and mixing ignores time. Active network callers also expect fields/credential attributes the classes do not have. | Split out one corrected local-system transport fixture. Archive the Python Hodge-onion, ephemeral-security, and mixing claims; redesign them natively under Paper 2 rather than translating them to Lean. |

Active dependency consequences:

- `crypto/credential.py`, `crypto/encrypt.py`, and `crypto/decrypt.py` make
  `sheaf.py` and `sheaf_laplacian.py` part of the old live cipher path.
- `network/routing.py` and `network/onion_service.py` reach
  `fiber_bundle.py`, but their interfaces already disagree with it.
- `homotopy_path.py` still reaches the old ZKP/key-image path and therefore
  must lose verifier authority before it is archived.
- Rust has fragments of graph transport, a harmonic projector, and onion
  routing, but no general restriction-aware cellular sheaf, true degree-one
  sheaf Laplacian, integral harmonic lattice, or validated topology compiler.

Conditional Paper 1 Lean gaps exposed by this pass:

1. `Sheaf/Hodge.lean` proves the three degree-one pieces are pairwise
   orthogonal, and `Sheaf/HarmonicLattice.lean` proves recovery for explicitly
   constructed noise. If the paper asserts the full spanning/unique
   decomposition for every \(b\in C^1\), add that named theorem; otherwise
   state only the constructed-noise result already proved.
2. `Sheaf/Equivalence.lean` and `HCP.lean` each have the right transport
   theorem at their own layer, but there is no bundled adapter from a concrete
   `CellularSheaf.IsometricCochainEquiv` to the Helfer/HCP realization. Add it
   only if the paper claims that every such cellular equivalence
   automatically realizes the semantic bridge.
3. Ordinary cellular restriction maps are not parallel transports: they need
   not be invertible or isometric. If Paper 1 identifies them, introduce a
   separate local-system/isometric-connection structure with functorial
   transport laws and a map into `Axioms.FiberSystem`; otherwise remove that
   identification from the prose.

### Pass C0: `src/crypto/`

Status: **Audited, not migrated.** The folder is not a concrete implementation
of the current Lean theorem surface. `HCP.lean` proves the exact real-linear
equivalence \(W\times W^\perp\simeq C^1\), while
`Sheaf/HarmonicLattice.lean` separately presents the integral harmonic lattice
and known-lattice CVP shadow. The Python cipher uses \(\Delta_0\), floating
eigenbasis coordinates, and private credential data; it is neither a
degree-one refinement nor a proved public-key encryption scheme.

| Python file | Canonical Lean owner / coverage | Semantic verdict | Current disposition and next action |
|---|---|---|---|
| `__init__.py` | No independent owner. | Its claim that \(\delta^*=\delta^T\) makes encrypt/decrypt inverse is false; adjointness alone supplies no cipher inverse. It also repeats unsupported SVP/Hodge/MAC claims and eagerly imports archived invariants, so even unrelated submodule imports fail through the package initializer. | Replace with a minimal facade only after runtime objects are redesigned; do not retain the promotional architecture prose. |
| `random.py` | Randomness is a Paper 2/runtime boundary, not a Paper 1 theorem. | `secrets.token_bytes` and `secrets.randbelow` are suitable primitive calls after input validation. `secure_rng` seeds NumPy PCG64 with 64 bits; PCG64 is not a CSPRNG, so the matrix, vector, orthogonal, Gaussian, and downstream “uniform” samplers are not cryptographic. | Preserve the two `secrets` wrappers conceptually; replace all structured sampling with a domain-separated CSPRNG in Rust and specify the required distribution. |
| `padding.py` | Runtime/network only. | Fixed length hides one metadata coordinate, not timing, direction, flow, or endpoint patterns. The length marker is unauthenticated, decoy lengths follow a distinguishable distribution, and `PaddedPacket.is_decoy` explicitly attempts the distinction denied by the module's claim. | Paper 2 rewrite under authenticated framing and an explicit traffic model. No Lean object is missing. |
| `secure_memory.py` | Runtime TCB duties are already named in `Axioms/Fibration.lean`. | Python cannot guarantee erasure across copies, temporaries, immutable `bytes`, GC, or allocator behavior. `SecureBytes.data` creates an unwipeable copy; credential field names are stale; failures print and continue. | Archive after extracting requirements. Implement zeroization/locked-memory policy in Rust; never cite this module as forward-secrecy evidence. |
| `hardness.py` | `CVP.lean`, `HCP.lean`, `Hardness.lean`, and `Sheaf/HarmonicLattice.lean` own the current statements. | Rejected. `LatticeInstance` is an LWE-looking floating construction, not the explicit CVP instance or harmonic lattice; the secret is not sampled short; the OU error is real-valued; the claimed strict hierarchy, arbitrary reduction, Helfer privacy consequence, bit estimates, and “formal verification” are not Lean theorems. | Archive the security narrative and estimator. Retain only plainly named modular arithmetic utilities if a real consumer remains. |
| `lattice.py` | No independent owner; it should refine the same Lean files as the geometry lattice. | A compatibility/re-export facade that inherits the invalid finite-module-as-lattice model, insecure NumPy sampler, speculative noise, and unsupported hardness estimator. Its “discrete Gaussian” is a rounded continuous PCG64 sample. | Archive after consumers import a replacement runtime API. It contributes no missing mathematical object. |
| `commitment.py` | Exact \(C^1\) semantics and opening equivalence are Proved in `Sheaf/Commitment.lean`; cryptographic wrapper properties are explicit assumptions in `Axioms/CochainCommitment/Security.lean`. | The useful exact-cochain shape is real, but the security prose is not. The bare map \(a\mapsto\delta_0a\) has openings modulo \(\ker\delta_0\), so unique-message/SVP binding and hiding do not follow. The topology hash is noncanonical and truncated; parsing is noncanonical/unbounded; the purported harmonic blinder is merely a deterministic random vector; and partial opening passes vacuously unless an edge has both endpoints revealed and authenticates no positions. | Keep only as a migration source for the legacy wire leaf. Replace with a canonical snapshot-bound authenticated wrapper and an actual partial-opening proof system. Do not port this construction verbatim. |
| `cohomological_mac.py` | `Axioms/CochainCommitment/Security.lean` records MAC correctness/unforgeability/key-binding/determinism only as assumptions. | Rejected as a MAC. Verification checks the supplied tag vector and supplied coefficient vector independently but never binds them by `tag_vector = V_H·coefficients`; floating eigenspaces and raw bytes are noncanonical; no EUF-CMA game/reduction exists; and the reported security-bit formula is invented. | Quarantine. Either select a standard authenticated primitive for Paper 2 or define and prove a concrete security game before this name returns to an acceptance path. |
| `credential.py` | Abstract class/path/fiber interfaces are in `Axioms/HomotopyClass.lean` and `Axioms/Fibration.lean`; the concrete cellular-to-HCP realization remains conditional. | Rejected as a classifier or credential proof. Arbitrary real matrices are called CPTP quantum channels; only degree-zero structure is built; one endpoint map is retained for transport; spectral equality and then Betti equality are each promoted to homotopy class tests. The graph cycle-rank formula ignores filled faces. Most critically, the public “topology hash” includes eigenvalues and spectral gap, so the supposedly class-level public identity is representative-specific. Sampling a fresh key on the same graph is not uniform sampling from a classifier fiber, and rotation supplies no path/equivalence witness. | Preserve as a Paper 2 lifecycle requirements source only. Redesign around a typed base presentation, ephemeral representative, hidden path/transport witness, public classifier, canonical handles, and explicit state transition; do not translate this API. |
| `encrypt.py` | The abstract Hodge cipher and recovery theorem are Proved in `HCP.lean`; the degree-one integral construction is in `Sheaf/HarmonicLattice.lean`. | Not a refinement. It embeds bits in an independently recomputed degree-zero eigenbasis, so repeated zero eigenspaces have no canonical coordinate frame; encryption and decryption can choose different bases. It requires the private credential to encrypt, uses non-CSPRNG noise, ignores `sigma_harmonic`/`use_hodge_noise`, ignores the noise validator's result, and emits unused noisy edge syndromes. Serialization rounds arbitrary reals to `int16`, is noncanonical/unbounded, and can destroy round-trip correctness. It exposes `SHA256(message)` as an offline confirmation oracle, carries an unused nonce, and emits a representative-specific sender identifier. | Quarantine as the old cipher prototype. A future runtime must first choose the actual security notion and public/secret key interface, then refine the degree-one Lean object with a canonical frame/encoding, authenticated ciphertext schema, and CSPRNG. |
| `decrypt.py` | Same owner as `encrypt.py`; Lean's projection theorem is mathematical correctness, not a wire-level decryptor or ZK proof. | It inherits the degree/basis mismatch, accepts a weak topology/count binding, ignores `ciphertext.message_hash`, returns plaintext even when optional verification fails, and retains an unproved legacy lattice branch. `projective_measurement` reveals the harmonic component and is not a zero-knowledge proof. `DecryptionChain` is an unauthenticated recreatable hash list, NumPy hashes are noncanonical, and sender lookup is equality rather than authentication. | Quarantine with `encrypt.py`. Preserve only test vectors after a new schema exists; never expose the harmonic component as a ZK artifact. |
| `validation.py` | Lean stage predicates live under `Axioms/*`, `Gates/*`, and `Protocol/*`; runtime validation must refine a versioned schema. | Rejected as a security gate. Dimension/modulus sets and “Kyber-like” ranges have no reduction; message capacity uses stalk dimension rather than harmonic rank; ciphertext validation checks counts but not canonical IDs, dimensions, finiteness, bounds, freshness, or authentication; SHA-256 integrity is unauthenticated; and the Tsirelson spectral interval is imported as a universal validity condition without support. | Replace with fail-closed canonical parsing plus theorem-indexed stage certificates. Ordinary chunking helpers may survive separately. |

Cross-file crypto blockers:

- Encryption iterates the stored vertex order, while decryption concatenates
  sorted vertices; a noncanonical topology order permutes the cochain.
- The ciphertext's edge syndromes, nonce, timestamp, and embedded message hash
  are not cryptographically bound or used to recover the message.
- A top-level import of `src`, `src.crypto`, or even a nominally independent
  submodule such as `src.crypto.padding` executes eager initializers and fails
  on the already archived primitives/invariants.
- `chain/homotopy_transaction.py` still consumes the Python commitment and MAC
  as acceptance evidence; `wallet_store.py`, network code, examples, and many
  tests still consume the old credential/cipher.
- Rust mirrors only the legacy `CochainCommitment` leaf plus add/scalar
  operations. Contrary to the former resolved note below, it currently has no
  `BlindedCommitment` or `VectorCommitment`.

The mathematical work that should precede any new cipher runtime is narrow:

1. decide whether Paper 1 asserts full Hodge spanning or only recovery for the
   already constructed `HodgeNoise`;
2. finish the concrete cellular-sheaf/HCP realization bridge if the paper
   claims it;
3. keep the encryption bijection claim at the correct source
   \(W\times W^\perp\), not plaintext \(W\) alone; and
4. treat IND-style encryption security, MAC unforgeability, credential
   lifecycle, canonical bytes, randomness, and zeroization as explicit
   Paper 2 definitions/implementations rather than consequences of Hodge
   projection.

### Pass CH0: `src/chain/`

Status: **Audited, not migrated.** The package is already non-runnable after
the deliberate primitives/invariants archival: importing `src.chain` eagerly
reaches those retired modules. No chain file has full Lean/Python/Rust parity,
and the only non-test Python consumer outside this folder is the later-audit
`src/network/routing.py`.

This pass found no additional Paper 1 mathematical object. It did find several
useful Paper 2 concepts hidden inside obsolete implementations; those are
captured separately below so that archival does not erase the design intent.

| Python file | Canonical Lean owner / coverage | Semantic verdict | Current disposition and next action |
|---|---|---|---|
| `__init__.py` | No independent owner. | The eager facade advertises the legacy Python chain as production while importing broken/quarantined identity, proof, storage, and consensus paths. | Archive with the folder after severing the network import. A future facade should expose only versioned Rust refinements. |
| `account.py` | Future `Protocol/Ledger.lean` and `Protocol/Ephemeral.lean`; class/path mathematics is only abstractly owned by the fibration interfaces. | The account/presentation/connection lifecycle is a useful protocol concept, but this registry is unauthenticated. Sovereignty confirmation has no witness, connections are unilateral, rotation changes no key material and proves no path/equivalence, status and nonces are not enforced, and the public class index may create unwanted linkability. | Archive the implementation; recover authenticated presentation registration, bilateral topology-edge transitions, and witness-bound rotation as Paper 2 objects. |
| `block.py` | `Chain.lean` has an old abstract block; `Protocol/Consensus/Vote.lean` has the newer signed root tuple. Canonical bytes remain Unmapped. | Rejected as a verifier. Any nonempty 32-byte fallback is accepted as PoV, a zero cochain root bypasses checking, VRF data is not verified, and the header/body encoding is unbounded and noncanonical. The claimed Tsirelson/Bell interpretation of the graph-gap window is not proved. | Archive after extracting adversarial wire tests. Define one canonical Rust block manifest that binds the full body, state roots, evidence, quorum certificate, and slot proof. |
| `block_producer.py` | Partial overlap with `Protocol/Consensus/{Committee,Vote,Quorum}.lean`; round/lock/finality and accepted ledger application are unfinished. | Rejected. Mempool admission skips transaction verification, spectral failure falls back to the admissible value `1.0`, the proof fallback is structural, historical nullifiers are not supplied, `Undetermined` can be committed, and coalition/coregulator failures are swallowed. Mutations are not atomic. | Archive the single-node simulator; do not port its acceptance behavior. |
| `block_section.py` | No direct owner. The intended replacement belongs to `Protocol/Storage.lean` and must bind `Sheaf/Commitment.lean` artifacts. | It is not a cellular-sheaf section: there is no base sheaf or restriction compatibility. “Coherence” compares one scalar and checks that a root is nonzero; the alleged private stalk is plaintext byte packing; the \(C^1\) values are neither populated nor serialized. | Archive. Preserve only the idea of typed artifact slots, rebuilt as a canonical tagged `SheafBlock` manifest rather than a “section.” |
| `chain_store.py` | `Protocol/Storage.lean` is an attachment surface only. | Rejected as authoritative storage. Blocks, indexes, section files, state snapshots, and nullifiers are written independently; loads do not revalidate hashes; private material is plaintext; indexes can become stale; and the saved audit chain is not recomputed. | Archive Python storage. Rust needs one atomic accepted-transition batch, recovery/rebuild checks, content addressing, and a separate encrypted secret store. |
| `clmm.py` | No current Lean owner. | It is a constant-product pool, not concentrated liquidity. Integer rounding can decrease \(k\); there are no fees, slippage bounds, account debits/credits, authorization, or atomic ledger effects. | Archive as an unselected protocol/product tokenomics experiment. Recover an AMM invariant only if the protocol later selects an economic model. |
| `homotopy_transaction.py` | Partial `Chain.Transaction`; future `Protocol/{Ledger,Ephemeral,Evidence}.lean`. No concrete proof or wire refinement exists. | Security-critical rejection. The transaction hash and serialization omit state-affecting fields, including `transfer_amount` and proof data; a round trip can therefore change the transition without changing the hash. Spectral/class proofs verify self-supplied claims, range proof and MAC are optional/structural, naturality returns true on the live fast path, and an out-of-range status falls through. | Archive the schema/verifier. Redesign a fully hashed canonical transaction whose authorization, nullifier, exact value flow, public class coordinate, cochain artifact, evidence, and state context are one bound statement. |
| `incentives.py` | At most a loose policy analogy to `Consensus/Reliability.lean`; no refinement. | The event-sourced policy idea is separable, but this implementation keys reputation to a linkable spectral fingerprint, accepts unauthenticated/replayable events, uses wall-clock time and floats, and calls scalar graph diffusion a trust sheaf. | Archive or unnumbered product-research quarantine. If selected later, define committed evidence, deterministic fixed-point arithmetic, epoch-scoped pseudonyms, and privacy/Sybil policy first. |
| `key_image.py` | `Chain.lean` proves only freshness and monotone spent-set facts. Derivation, ownership, linkability, and unforgeability are absent. | The spent-set abstraction is useful; both constructors are unsuitable. The live eigenvalue hash is public and one-per-credential, while the path-based image can be varied to evade replay detection. Neither is secret/output-bound, and Python storage is noncanonical and non-atomic. | Archive the constructors/store; recover a typed per-spend nullifier interface plus atomic compare-and-set and reorg semantics. |
| `sheaf_state.py` | The immutable `SheafStateSnapshot` in `Sheaf/Commitment.lean` is a different object. Planned owners are `Protocol/{Ledger,Storage,Evidence}.lean`. | The original checkpoint-bus idea is useful, but the class became a mixed mutable ledger/economics/topology cache. Its `HashChain` never recomputes payload hashes; its `HashCommitment` is raw metadata; its “Čech nerve,” “global section,” and “natural transformation” claims do not instantiate those notions. `apply_block` can partially mutate nullifiers/balances, mint on unknown senders or negative/NaN values, and move the tip without enforcing acceptance. | Archive the implementation. Recover a fresh per-commit volatile `SheafState` that checkpoints into a separate open `SheafBlock`; seal atomically, then wipe the bus. Split ledger, topology, and node state. |
| `treasury.py` | `Axioms/Ledger.lean` names conservation only as an assumption; no selected tokenomics owner. | The conservative-flow idea is useful, but arbitrary/negative/NaN weights, ignored credit failures, pre-emptive balance clearing, implicit asset conversion, float percentages, and unauthenticated history break it. | Archive the concrete economics. Recover an exact typed value-flow/Petri transition only if Paper 2 selects these assets and fee rules. |
| `vault.py` | Only future `Protocol/Ledger.lean` could own bonded eligibility, unbonding, and evidence-authorized slashing. | Useful state-machine vocabulary, unsound implementation. Bonding has no source debit; negative unbond/withdraw values mint balances; rewards are arbitrary credits; slashing has no authenticated evidence; and transitions are non-atomic. | Archive. Preserve the conditional design requirement for exact nonnegative bonded balances and evidence-bound slash transitions. |
| `wallet_store.py` | `Protocol/Ephemeral.lean` gives lifecycle obligations and `Protocol/Storage.lean` gives only a boundary; concrete storage belongs in Rust. | Rejected. The public fingerprint is described as a master key although the computed key is unused; ciphertext metadata is unauthenticated; rotation equates spectral equality with homotopy equivalence; and writes lack atomicity, locking, permissions, and canonical versioning. | Archive Python wallet storage. Rebuild in Rust using an independent secret KDF, AEAD, atomic persistence, restrictive permissions, and authenticated metadata. |
| `agents/__init__.py` | No current owner. | `AgentProposal` contains a potentially useful candidate-action/evidence shape, but its “Grassmannian belief” is an arbitrary vector and its reserve/slippage predicate compares unlike assets. The facade exports a nonexistent `ProfitAgent`. | Archive the agent package surface; recover only a typed `CandidateTransition` plus evidence and deterministic admissibility predicate if selected. |
| `agents/feedback.py` | No current owner; it does not refine the sheaf/Hodge or consensus layers. | Rejected. It is already broken by archived imports, pairs agents and validators by unrelated map order, substitutes Laplacian block magnitude for gluing quality, computes no stated harmonic/tangent update, and adapts consensus parameters locally. | Archive as historical research. |
| `agents/hedge_agent.py` | No current owner. | Principal-angle numerics may be a test fixture after validation, but Grassmannian distance is relabeled as impermanent loss without a proved economic bridge. Its principal actions are not executable by the orchestrator. | Archive the strategy; retain no protocol authority. |
| `agents/stabilizer_agent.py` | No current owner. | A return-jump statistic is called persistent homology; token-price policy is coupled to spectral gap through arbitrary thresholds; wall-clock/external-price/floating mutable state would make validators diverge; rate limits do not record accepted use. | Archive or keep as an explicitly off-chain product experiment. |
| `agents/treasury_agent.py` | No current owner. | The abstract “proposal -> invariant gate -> atomic transition” shape is worth recovering. The implementation makes its \(k\)-check tautological, debits before fallible swaps, discards outputs, mints liquidity legs, and leaves several proposed actions unresolved. It is not the protocol coregulator. | Archive the strategy/orchestrator; recover the typed transition architecture under a neutral name such as `TransitionExecutor`. |

#### Useful objects hidden in the legacy chain

“Unused” does not mean “semantically dead.” The following concepts should be
rebuilt from the current Lean architecture rather than ported line-for-line:

| Recoverable concept | Source intuition | Correct target |
|---|---|---|
| Volatile projection/checkpoint bus | `SheafState` | One fresh per-commit typed state bus, initialized by an accepted exact \(C^1\) artifact and immutable `SheafStateSnapshot`; it carries no general ledger/economics state. |
| Persistent artifact stack | `BlockSection`, `HashChain`, `ChainStore` | Open then sealed `SheafBlock` with versioned typed leaves, one outer content address, immutable finalized evidence, and no public plaintext private stalk. |
| Accepted state transition | `SheafState.apply_block`, `ProtocolOrchestrator` | A relation over explicit before/after roots, full transition digest, topology/cochain/evidence roots, epoch/round/judgment, and an authenticated quorum certificate. Validate first and commit atomically. |
| Spent-object state | `KeyImageStore` | Monotone nullifier set with secret/output-bound derivation, authorization proof, duplicate-within-batch rejection, atomic insertion, and explicit rollback/reorg journal. |
| Presentation lifecycle | `SovereignAccount`, `Connection`, `rotate_keys` | Authenticated registration, bilateral edge changes, current public presentation handle, and path/transport-witness key rotation without publishing a linkability oracle. |
| Bond/slash lifecycle | `Vault`, `SlashReason` | Optional Paper 2 exact-value state machine with source debits, unbond epochs, evidence-authorized slashing, conservation, and nonnegativity. |
| Candidate action envelope | `AgentProposal` | Typed candidate transition plus evidence/context digest and deterministic gate. Strategies remain untrusted proposal producers. |
| Local secret persistence | Python/Rust wallet stores | AEAD-protected, independently keyed, atomic and versioned wallet state with authenticated metadata and zeroization policy. |
| Ordinary block indexes | Python/Rust block stores | Recoverable height/hash indexes derived from validated immutable blocks; never independent consensus truth. |
| Topology descriptor | `NerveStateSnapshot` | Canonical bounded encoding of a validated oriented complex and sheaf schema. Its digest may be one leaf of `SheafStateSnapshot`; the legacy abstract-graph hash is not the full snapshot root. |

Do **not** recover the spectral fingerprint as an identity or homotopy
classifier, either key-image construction, balances-as-global-section,
block-as-sheaf-section, locally adaptive consensus thresholds, the
Grassmannian/economic metaphors, or the current float tokenomics.

#### Rust is a separate prototype, not a replacement

Python and Rust do not presently share a protocol:

- Python uses `HCRYPT_BLOCK_V2`, a custom `BLK2` encoding, and Merkle-like
  roots over assorted transaction blobs. Rust uses `HCRYPT_BLOCK_V1`,
  `bincode`, and a hash of modularly accumulated edge vectors.
- The Python transaction encoding cannot be parsed as the Rust cochain payload.
  Python omits state-affecting fields from its hash; Rust hashes opaque data
  plus an optional nullifier but omits `sender_fingerprint` and `fee_amount`.
- Rust's block hash omits the body/nullifiers/fees, topology hash, full proof
  trace, worker signatures, and slot data. Its cochain accumulator parses but
  discards each payload's topology coordinate.
- Python and Rust state updates are non-atomic. Nullifiers can be inserted
  before later failures; active Rust handlers can log insertion failures and
  still store a block. RocksDB block/index/tip writes are independent puts.
- Rust `SheafStore` is a set of hard-coded floating-vector tables, not a
  restriction-aware sheaf or functor. Private stalks are plaintext, and the
  oracle path currently produces four floats for a required 32-dimensional
  stalk.
- Rust wallet code persists a caller-supplied ciphertext JSON object; it does
  not establish encryption, authenticated metadata, or crash-safe storage.
  There is no Rust treasury, CLMM, vault-accounting, reputation, or agent
  counterpart.

#### Lean implications

`Chain.lean` contains useful freshness and monotonicity lemmas, but it is an
older mixed Paper 2 surface, not a complete acceptance specification:

- `TransactionAccepted` is only payload well-formedness plus prior-nullifier
  freshness.
- `BlockAccepted` requires payload compatibility, not
  `BlockCochainsCoherent`, a signed quorum certificate, or an evidence-bound
  before/after transition.
- `key_image : Nat` has no cryptographic derivation or authorization
  interface.
- `balance_preserved` reduces each edge vector to one scalar sum; no theorem
  relates that statistic to an asset-value conservation law.
- spectral fingerprints, cumulative spectral-gap fork weight, and the
  quadratic splitting theorem are not yet justified as the selected identity,
  fork-choice, or Sybil-resistance protocol.

The strict authenticated quorum kernel in
`Protocol/Consensus/{Committee,Vote,Quorum}.lean` is real but does not yet
supply rounds, locks, finality, or ledger application. The next Paper 2 Lean
work is therefore a canonical committed-state/transition type, explicit
nullifier and authorization interfaces, exact-value conservation and
nonnegativity, evidence/root coherence, and the certificate-to-atomic-update
bridge. The current comment in `Axioms/StageAdmissibility.lean` saying that the
critical bundle is enforced in Python/Rust is stale.

This does not block Paper 1. Its cellular sheaf, exact \(C^1\) commitment
semantics, snapshot-root interface, and common-root proximity binding already
own the relevant mathematical boundary. Paper 1 must only avoid presenting the
chosen \(\sqrt 2\) spectral window as a derived Bell/Tsirelson or universal
graph-connectivity theorem.

Archival can preserve `src/chain/` as one provenance unit after
`src/network/routing.py` loses its `HomotopyTransaction` import and the four
direct chain tests are reclassified as historical fixtures. Useful negative
and canonicalization cases should be rewritten as Rust tests, not retained as
Python acceptance authority.

### Cross-cutting pass PL0: Plucker names outside `lean/Proximity/`

Status: **Classified, not migrated.** The canonical Paper 1 meaning of
“Plucker” is the decomposable exterior coordinate, its projective quotient,
and the public binding from that quotient to the accepted cochain artifact.
No Python, Rust, or non-`Proximity` Lean module currently consumes or refines
that Section 6 object. The only Lean occurrence outside the folder is the
`lean/Proximity.lean` barrel import; the other genuine occurrences are paper
and architecture cross-references or a downstream payload-interface comment.
Mentions outside the canonical Lean folder fall into two very different
classes:

| Surface | What it actually denotes | Verdict and disposition |
|---|---|---|
| Archived `archive/python/src/primitives/algebra.py` and the forward `to_plucker` path in `archive/python/src/primitives/grassmann.py` | Numerical minors/exterior coordinates for a supplied frame. | Potential numerical refinement of the raw coordinate only. It still needs a fixed coordinate ordering, coefficient/domain contract, rank and decomposability checks, projective sign/scale handling, and parity vectors against `Proximity.GrassmannianPlucker`. It is not a public shadow or commitment binding. |
| Archived `archive/python/src/primitives/grassmann.py::from_plucker` | An attempted inverse from arbitrary coordinates to a frame. | Quarantine. General inputs need not satisfy the Plucker relations, the inverse is not canonical, and the current general-\(k\) update is dimensionally invalid. The Paper 1 verifier does not need to reconstruct the private frame from its public projective class. |
| `src/consensus/{coherence,validator_selection}.py` and `src/chain/block_producer.py` | Grassmannian distance from a submitted projector to a Karcher-style consensus projector, converted to a scalar weight. | Misnamed legacy Paper 2 geometry. `compute_plucker_centrality` never computes a Plucker coordinate; `to_plucker` is imported but unused. Rename this family to `GrassmannianDivergenceCentrality`/`GrassmannianDivergenceEligibility` if retained. Do not bind it to the Paper 1 Plucker shadow. |
| `src/consensus/validator_selection.py::filter_eligible` | Purported binary Plucker divergence gate. | Not implemented as documented: it accepts the previously normalized weights and never applies `MAX_DIVERGENCE`; the separate `CoherenceEngine.check_eligibility` gate is not consumed here and fails open when no consensus is available. |
| `rust/node/src/consensus/validator_set.rs` | An externally supplied scalar called `plucker_centrality`. | Misnamed and unauthenticated. Rust receives no frame, exterior coordinate, projective shadow, distance, threshold witness, or proximity evidence root. The update only range-checks a float, while `is_plucker_eligible` checks the combined fallback selection weight. Rename and redesign as a proof/evidence-bound Paper 2 score if selected. |
| `lean/Axioms/Grassmannian.lean::PluckerEligibility` and `lean/Consensus/Geometry.lean` | An abstract validator divergence/weight interface; it contains no Plucker coordinate or projective quotient. | Overloaded legacy name. Rename to `GrassmannianDivergenceEligibility` and keep it on the Paper 2 side. Its oracle-binding proposition does not identify it with `Proximity.PluckerCochain.PublicBinding`. |
| Root import surfaces, current proximity documentation, Paper 1 Sections 5--6, and the Paper 2 reuse note | Cross-references to the canonical `lean/Proximity/` frame, quotient, binding, and projection chain. | Legitimate. Section 5 should consistently say **projective class/public shadow**, not imply that unit-norm normalization alone removes the sign/scale ambiguity. Concrete canonical bytes and digest binding remain runtime obligations. |

The naming rule following this audit is:

- reserve `Plucker` for an exterior coordinate satisfying the relevant
  decomposability/Plucker relations, its projective class, or evidence
  explicitly bound to that class;
- call projector/Karcher-mean distance a Grassmannian divergence, even when it
  is numerically related to a Plucker metric;
- never treat a normalized exterior vector as a canonical public encoding
  without a deterministic projective representative rule; and
- never treat a consensus scalar as the
  `HashedPluckerShadow -> CochainCommitmentData` artifact required by the
  projection chain.

There is also a security-boundary issue inside the canonical Section 6 model.
`GrassmannianPlucker.FrameWitness.point` is the operative harmonic subspace
\(W\), and a valid nonzero decomposable projective Plucker coordinate
determines that Grassmannian point. Publishing the actual projective shadow for
the same HCP instance therefore reveals \(W\), after which the operative target
\(P_W b\) can be computed without recovering the remaining private Laplacian
data. Merely observing that the Plucker coordinate differs from the HCP public
class label does not avoid this disclosure.

Protocol reuse must consequently select and formalize one of these designs:

1. keep the frame and Plucker shadow private, publish a **hiding** commitment
   plus a zero-knowledge/proof-carrying statement binding it to the accepted
   cochain and projection evidence;
2. redefine the protocol-visible coordinate to describe a derived public
   projection plane that is explicitly proved not to reveal the hidden HCP
   harmonic subspace; or
3. deliberately reveal \(W\) for a special audit instance and make no
   hidden-kernel HCP claim for that instance.

The current `HashedPluckerShadow` contains the mathematical `shadow` and only
records a proposition that its digest binds. Collision-resistant hash binding
is not a hiding commitment, and no zero-knowledge/non-disclosure theorem is
currently connected to this object. Until that boundary is repaired, a sealed
`SheafBlock` should not publish the raw Section 6 projective shadow.

### Cross-cutting pass SB0: Python sheaf-block and storage envelope

Status: **Classified, not migrated.** This pass is cross-cutting because the
old Python “sheaf block” is assembled from primitives, geometry, crypto, and
chain modules. It does not advance those folders as a whole through the audit
order.

The main finding is negative but useful: Python does **not** currently contain
one surface/root object binding the cellular-sheaf snapshot, accepted exact
cochain, Plucker/plane data, canonical RS data, projection evidence, and the
public handle for the hidden presentation family. Several unrelated hashes are
described as though they were that object, but none has the required coverage.

| Python object or file | What it actually contains | Verdict and disposition |
|---|---|---|
| `primitives/stalk.py`: `Stalk`, `StalkBundle` | Untyped NumPy vertex containers and raw-byte local hashes. `StalkProjection` changes an application “context”; it is not a cellular restriction map or a proved natural transformation. | Preserve only as a possible runtime container after typed dimensions and canonical encoding are supplied. Deprecate the three-hardness-layer and naturality claims. |
| `geometry/sheaf.py`: `CellularSheaf` | A graph-level numerical prototype with vertex/edge arrays and a degree-zero coboundary. It has no full typed \(C^0\to C^1\to C^2\) object, snapshot root, or storage binding. | Preserve as a potential numerical test oracle after it is made a refinement of `Sheaf/Cellular.lean`; it is not the sheaf-block envelope. |
| `geometry/fiber_bundle.py`: `FiberBundle`, `EphemeralFiber` | Private matrices, path transport, and an old sampled-ephemeral construction. Its equivalence check is spectral/numerical and is not the Lean path-plus-isometric-presentation bridge. | Quarantine the security and “same homotopy class” authority. Reuse numerical transport only after a Lean presentation-family specification exists. Keep all raw representatives and paths private. |
| `crypto/credential.py`: `QuantumSheafFibration`, `FibrationCredential`, `HomotopyClass` | The older concrete credential/master/rotation model. Sampling with matching Betti data is called uniform sampling from a homotopy class, which is not established. | Protocol/runtime reference only. Split useful generation mechanics from the rejected spectral/Betti equivalence claims; refine a future Lean identity-presentation family rather than translating this API verbatim. |
| `crypto/commitment.py`: `CochainCommitment`, `BlindedCommitment`, `VectorCommitment` | Standalone cochain/partial-opening prototypes with their own topology hash. They do not bind a `SheafStateSnapshot`, Plucker shadow, plane, RS object, or evidence root. | Preserve as candidate runtime cryptography subject to canonical-byte, soundness, and Lean-refinement work. It supplies a leaf artifact, not the outer block root. |
| `chain/sheaf_state.py`: `NerveStateSnapshot` | A deterministic hash of the account nerve only. It omits stalk dimensions, restriction maps, incidences beyond the nerve payload, coefficient/operator data, accepted cochain, parameters, and evidence. | Preserve after rename to `TopologySnapshot`; it is not the Lean `SheafStateSnapshot`. |
| `chain/sheaf_state.py`: `SheafState`, `HashChain`, `HashCommitment` | The name preserves the useful original idea of a checkpointed cross-layer state bus, but the implementation became a mutable account/ledger/economics container with a JSON/time-dependent audit chain and legacy spectral/Betti summary. A balance assignment is called a global section, and a projection is called natural without restriction-square data. | Recover the volatile typed bus over a fixed context and separate persistent checkpoints; runtime allocation/retirement granularity is still open, as clarified on 2026-11-05 below. Split the current fields into Paper 2 ledger/node state, topology cache, and audit log; deprecate the sheaf/global-section/colimit/natural-transformation claims. None of its current hashes is the final block address. |
| `chain/block_section.py`: `BlockSection`, `ChainSectionBundle` | Packs a spectral scalar and assorted proof/hash bytes into fixed float arrays, calls a block a global section, and calls `prev_hash` a restriction map. “Coherence” is only equality of one scalar plus a nonzero cochain root. | Semantic deprecation candidate. Do not translate to Lean. Preserve only ordinary parent-hash and serialization fixtures while replacing this structure with a typed storage manifest. |
| `chain/block.py`: `BlockHeader`, `cochain_root` | A conventional block hash plus transaction and legacy cochain/spectral fields. The Python cochain root aggregates transaction amount commitments; it is not the digest of the Lean accepted exact \(C^1\) artifact. | Preserve the generic header/serialization idea, but replace the root schema. It lacks snapshot, Plucker/plane, RS/parameter, evidence, and presentation-handle coordinates. |
| `chain/chain_store.py`: section storage | Mutable filesystem directories that write the fabricated public/private stalks and cochain root under a height. The private float array is written in plaintext. | Reject as the privacy-preserving sheaf store. Retain ordinary I/O patterns only after introducing immutable content addressing, encrypted private objects, canonical manifests, and atomic verification. |
| `chain/homotopy_transaction.py` and `chain/account.py` | Mixed legacy identity, proof, amount, account, and topology fields. They carry no finalized projection-artifact root and do not bind a hidden presentation to the accepted exact cochain. | Paper 2 migration source, not Paper 1 mathematics. Rewrite against typed credential lifecycle, ledger, nullifier, and storage-anchor interfaces. |
| `primitives/{algebra,grassmann}.py`, `consensus/{coherence,validator_selection}.py`, `chain/block_producer.py` | Plucker numerics used by the older consensus-centrality/eligibility path. | Do not identify these values with `Proximity/PluckerCochain/PublicBinding`. The Paper 1 Plucker shadow has no Python storage refinement yet. |
| Canonical RS projection/storage | No Python object was found for the Paper 1 plane-to-RS received word, target, distance bridge, or its persisted digest. | **Unmapped.** Lean is the only current owner. Add a runtime refinement only after the canonical derivation and manifest fields are fixed. |

The competing Python hash coordinates are therefore distinct:

| Existing hash | Bound data | Why it is not the surface root |
|---|---|---|
| `Stalk.commitment()` | Raw native NumPy bytes for one local array | Noncanonical and local only. |
| `NerveStateSnapshot.topology_hash` | Canonicalized account nerve | Topology only; not a full cellular-sheaf snapshot. |
| `HashChain.current_hash` | Mutable sequence of JSON audit entries | Does not authenticate the mathematical artifacts or canonical bytes. |
| `BlockHeader.hash()` | The fields in the legacy block header | The header has no snapshot/evidence/plane/RS/presentation coordinates. |
| `BlockHeader.cochain_root` | Legacy transaction amount-commitment aggregation | Different object from the accepted exact \(C^1\) artifact. |
| `SpectralFingerprint.fingerprint_hash()` | Legacy spectral fingerprint | Not a homotopy classifier or storage-envelope root. |

**2026-11-05 profile clarification:** earlier per-commit/reset language in this
inventory describes one proposed runtime profile. The current Lean context
admits raw snapshot-bound inputs, with exact acceptance checked separately;
the runtime bus's lifecycle granularity remains a design choice. The
history-anchor adapters described below are conditional semantic joins, not
an implementation of the Python object graph.

The intended replacement recovers the original state-bus idea as a volatile
`SheafState` plus a separate persistent open `SheafBlock`. At every checkpoint,
the bus advances and writes its new artifact/certificate to the open block.
The runtime proposal seals and persists the final block and obtains its exact
receipt before retiring the bus; Lean proves local consumption, not physical
erasure. The sealed
block uses one **outer SHA-256 manifest root** (the earlier “surface hash”
intuition) with domain-separated child digests. “Under the same hash” means
authenticated by that one manifest root; it does not mean assigning the same
digest value to every child:

```text
volatile SheafState       persistent open SheafBlock
  original C1 artifact + fixed snapshot context; acceptance separate
  advance ----------------> write Plucker/cochain artifact + certificate
  advance ----------------> write plane artifact + certificate
  advance ----------------> write RS artifact + certificate
  advance ----------------> write hard/naturality/final evidence
  retire <----------------- seal + exact persistence receipt
sealed SheafBlock
  schema and parameter-set identifiers
  cellular-sheaf snapshot root and topology tag
  accepted exact-C1 artifact digest
  Plucker-shadow digest
  plane-view digest
  canonical RS derivation/received-target digest
  finalized evidence root
  public classifier/presentation handle
  encrypted private-object references, if persistence is required
  ---------------------------------------------------------------
  SHA256(domain || canonical manifest) -> outer surface root
```

The base/master presentation, ephemeral representative, private path, opening,
and transported secret state are not public block leaves. The public manifest
may bind opaque handles or ciphertext digests for them. If the RS word or plane
is canonically derived rather than stored, the manifest must bind the input
digest, parameter-set identifier, and derivation version that make the result
unique.

Lean owns the child objects and the following bounded joins:

- `Sheaf/Commitment.lean` owns the cellular-sheaf snapshot and accepted exact
  \(C^1\) binding;
- `Proximity/Concrete/PluckerCochain/PublicBinding.lean` relates the public Plucker
  shadow to an observed cochain artifact;
- `Proximity/Concrete/Public.lean` owns a plane view under an abstract storage root;
- `Proximity/Concrete/GateEvidence.lean` owns a finalized evidence database/root;
- `Protocol/Storage/{Context,Checkpoint,Projection}.lean` retains the same
  original interpretation/artifact and seals the exact final typed prefix;
- `Protocol/Storage/Anchor.lean` derives same-payload acceptance and snapshot
  naming from existing candidate evidence and actual-object equalities;
- `Protocol/Storage/ProjectionAnchor.lean` authenticates that prefix and its
  actual gate database under supplied history/evidence inclusion profiles; and
- `Protocol/Consensus/Vote.lean` names the matching proposal coordinates, with
  quorum adapters carrying the same manifest and snapshot references.

These conditional joins preserve distinct roots rather than identifying their
values. `HistoryBindings.manifestIncluded` receives the actual candidate,
context, ordered manifest and root; concrete hashes/inclusion checks and
backend guarantees remain to be instantiated. `PlaneView.storageRoot` is not
automatically the sealed manifest root. The Lean 4.35 aggregate/integration
build and all nineteen selected standard-only anchor audits pass, as recorded
above. Runtime work should refine these
existing objects rather than infer mathematical validity from a surface hash.

#### Dependency cut for the replacement `SheafState`

Reading archived `archive/python/src/primitives/stalk.py` explains the original
intended dependency:

```text
StalkSpec -> Stalk -> StalkBundle -> SheafState
```

That dependency is mathematically appropriate, not merely a reusable container
pattern: a sheaf state is assembled from local fibers (stalks) over the cells
of the topology. The present implementation nevertheless merges three
different axes that the replacement must separate:

```text
                         one cell x of X
                               |
             +-----------------+-----------------+
             v                 v                 v
       F_private(x) -----> F_zk(x) -----> F_public(x)
          stalk             stalk            stalk

 within each F: cellular restrictions along incidences of X
 across the row: components of natural transformations between sheaves

 accepted exact C1 + fixed layered-sheaf snapshot
                               |
                               v
                 volatile SheafState / stage bus
                               |
             checkpoint artifact + existing certificate
                               |
                               v
                  persistent open-SheafBlock slot
```

Thus `SheafState` should depend on the canonical stalk/sheaf layer. A
checkpoint artifact is a staged record derived from that state; it is not a
replacement definition of a mathematical stalk. If a later protocol task
sheaf places fibers over execution stages, that is an additional Paper 2
construction and must not be silently identified with the Paper 1 cellular
sheaf.

For three visibility contexts, the clean object is a diagram of cellular
sheaves on the same complex,

```text
F_private --eta_private_zk--> F_zk --eta_zk_public--> F_public,
```

where each `eta` is stalkwise and commutes with the restriction maps. A
cellular restriction `F(x) -> F(y)` stays inside one sheaf; a context map
`F_private(x) -> F_zk(x)` is a component of a natural transformation. The
current `StalkProjection` must not serve both roles.

The reusable idea from `stalk.py` is therefore the local fiber, its schema,
and a bundle of local values. The following parts are not canonical and
should not flow into the new state unchanged:

- fixed dimensions `256/32/1`;
- `harmonic_secret`/`hodge_noise` array slicing as Hodge semantics;
- default truncation/padding as a projection;
- calling a context-changing projection a cellular restriction map;
- raw native NumPy bytes as a canonical commitment; and
- a uniform-dimension, contiguous-vertex array as the full sheaf.

Lean's existing `Sheaf/Cellular.lean` remains the owner of mathematical
stalks and restriction maps. It still needs a typed cellular-sheaf morphism
(stalk components plus naturality) before the private/ZK/public diagram can be
stated faithfully. The Paper 2 `SheafState` should then be parameterized by,
or explicitly bound to, that layered sheaf context while it carries the
projection-stage state. The open `SheafBlock` persists checkpoint artifacts
and certificates, not a second object misleadingly called a stalk. Rust owns
their canonical bytes, SHA-256 leaf digests, atomic writes, and physical
secret wiping. Python may mirror them for fixtures and orchestration but is
not acceptance authority.

The current `sheaf_state.py` dependency graph also shows what must be removed:

- `primitives.natural` is used only for a legacy audit-log transformation
  table and must not validate checkpoint naturality;
- imported homotopy primitives are unused in the class;
- private/ZK stalk specifications are imported but the state class actually
  constructs only public balance stalks;
- vault, treasury, CLMM, accounts, mempool, and block-tip fields belong in
  ledger/node state, not the per-commit bus.

---

## Resolution history and reopened items

### R1. Cochain commitment coordinates: scalar → vector payload (scope-limited)
- **Was:** Lean `Chain.lean` used `commitment_value : ℝ` (scalar).
  Python and Rust used `edge_values: List[int]` / `Vec<i64>` (vector).
- **Fix:** Lean now uses the canonical `CochainCommitmentData` payload:
  `modulus`, declared edge count, vector `edge_values : List ℤ`, and 16-byte
  topology hash. `Chain.lean` transactions carry this payload directly as
  `cochain_commitment`, so chain proofs, proximity bridges, and Rust wire
  validation refer to one cochain commitment shape.
- **Scope correction:** this resolves the Lean payload coordinates only. The
  Python homotopy-transaction encoding is not parseable as the Rust payload;
  Python and Rust compute incompatible block/cochain roots; and Rust currently
  discards the parsed per-payload topology coordinate during accumulation.
  The short topology hash is not yet a canonical `SheafStateSnapshot` root,
  and the raw edge vector binds an exact `C¹` value rather than a unique `C⁰`
  opening.

### R2. BlindedCommitment / VectorCommitment missing from Rust — reopened
- **Current:** Python has names `BlindedCommitment` and `VectorCommitment` in
  `src/crypto/commitment.py`, but their security claims fail the C0 audit.
  `rust/node/src/crypto/commitment.rs` currently contains only the legacy
  `CochainComplex`/`CochainCommitment` construction and add/scalar operations;
  it has no Rust definitions of either missing type.
- **Required:** do not port the Python algorithms as written. First select a
  canonical authenticated construction satisfying the explicit Lean
  interfaces for value/context binding, hiding, and position-bound partial
  openings; then implement and test its versioned Rust wire refinement.

### R3. Lean cochain-commitment interface module exists
- **Was:** No dedicated Lean axiom module for cochain commitment properties.
- **Fix:** `lean/Axioms/CochainCommitment.lean` created with explicit interface
  fields for coboundary linearity, authenticated payload/context binding, any
  separately claimed hiding, homomorphic addition, blinded-commitment
  orthogonal decomposition, and partial-opening soundness. Imported from
  `lean/Axioms.lean`.
- **Scope correction:** these are assumption fields, not proofs of an SVP-hard
  scheme. For the bare map `a ↦ δ₀a`, equal payloads are exactly openings
  differing by `ker δ₀`; unique-message binding requires a gauge/reference
  anchor or a separate cryptographic construction.

The 2026-11-07 [graph comparison](../lean/Sheaf/GraphCommitment.lean) now
constructs this ambiguity for the actual ordered incidence/modular payload
profile, rather than only assuming a kernel element: `[3,5,9]` and
`[10,12,16]` give the same existing canonical payload `[2,4]` at modulus 12289.
The [byte-level TCB](../lean/TCB/PrimitiveChecks.lean) and
[original-transfer reduction](../lean/Protocol/Transfer/Primitives.lean)
separate backend error from owner/message/history and original-context
statement mismatches. The [runtime comparison](PROTOCOL_PARITY_QUEUE.md#actual-primitive-comparison-and-tcb-joins--2026-11-07)
records the concrete missing joins; it does not turn the Python or Rust
prototype into a new secure commitment.

### R4. Foundation/commitment ownership split
- **Was:** commitment binding, hiding, and homomorphism propositions were added
  directly to `Foundation`, conflating cochain/Hodge structure with a
  cryptographic wrapper.
- **Fix:** `Foundation` now contains exactly the structural cochain/Hodge
  surface: square-zero, coboundary linearity, Laplacian construction, Hodge
  decomposition, and orthogonality. Authentication of exact payload bytes,
  wrapper hiding, context/snapshot binding, homomorphism, and partial-opening
  soundness remain explicit fields of the separate commitment interface.

### R5. Commitment naming ambiguity (id_commit vs CochainCommitment)
- **Was:** Python/Rust/Lean all used `commitment` for two distinct concepts:
  (a) validator identity commitment (Hodge projection → quantize → 32 bytes),
  and (b) transaction cochain commitment (δ(m∥r) edge values in C¹).
  This caused confusion across the codebase.
- **Fix:** Renamed identity commitment to `id_commit` everywhere:
  - `rust/oracle/src/stalk_bridge.rs`: `FullStalk.id_commit`
  - `rust/oracle/src/rpc.rs`: `FullStalkRequest.id_commit`
  - `src/oracle/client.py`: `FullStalkRequest.id_commit`, `to_json()` sends `id_commit`
  - `lean/Axioms/OracleModality.lean`: `OracleQuery.id_commit` with docstring
    distinguishing from `CochainCommitment.lean`
  - Transaction-level commitment stays as `CochainCommitment` / `edge_values`

### R6. Topos boundary semantics: boolean → tri-valued (Lean ↔ Py ↔ Rust)
- **Was:** P1 item — Rust `ToposVerifier` saw only boolean `spectral_gap_valid`.
- **Fix:** Rust `stalk_bridge.rs` now uses `SpectralJudgment` enum
  (InBounds/Boundary/OutOfBounds) matching Python's `ToposConsensus` and Lean's
  `SpectralJudgment` inductive type in `OracleModality.lean`. The boolean
  `spectral_gap_valid` is still computed but the judgment is the primary signal.
- **Scope correction:** this is local data-shape correspondence, not
  end-to-end acceptance parity. Active Python production can commit
  `Undetermined`; active Rust block handling still trusts a boolean field in
  critical paths. Neither path currently realizes the signed Lean
  judgment/certificate boundary.

### R7. Grassmannian consensus geometry axioms missing from Lean
- **Was:** Python `coherence.py` and Rust `geometry.rs` both compute
  Grassmannian distance, Karcher mean, and sheaf Laplacian, but Lean had no
  corresponding axiom module.
- **Fix:** `lean/Axioms/Grassmannian.lean` created with axiom structures for:
  GrassmannianDistance, KarcherMean, SheafLaplacian, CechNerve,
  PluckerEligibility, and ConsensusGeometry composition. Each axiom cites
  corresponding Python/Rust implementation. Imported from `lean/Axioms.lean`.
- **Scope correction:** G0 and PL0 reject the old implementations as
  refinements of these interfaces. The abstract interface is not evidence that
  Python/Rust computations satisfy it, and `PluckerEligibility` is overloaded
  with a non-Plücker validator-divergence score.

### R8. OracleModality.lean not imported from Axioms.lean
- **Was:** `OracleModality.lean` existed but was not imported in the master
  `lean/Axioms.lean` barrel file.
- **Fix:** Added `import Axioms.OracleModality` to `lean/Axioms.lean`.

### R9. Identity model cleanup — regressed; reopened

> **Current-tree regression:** `src/chain/homotopy_transaction.py` still imports
> `SpectralFingerprint` and uses spectral-fingerprint identity language;
> `src/crypto/__init__.py` still exports that name; and
> `src/chain/account.py` still calls the public identity a spectral
> fingerprint. The historical migration below was real but is incomplete in
> the present tree.
- **Was:** ~30 files used `SpectralFingerprint` as a class name and
  `.fingerprint: bytes` as the public identity field on validators, routing
  relays, accounts, and chain types. Docstrings across consensus, crypto,
  and network modules called the spectral fingerprint "identity" — but
  Lean `Hardness.lean` proved spectral data is NOT a homotopy invariant
  (`Spectrum_Not_Homotopy_Invariant`). Exposing it publicly shrinks the
  anonymity set from infinite (homotopy class) to potentially-singleton
  (isospectral set). This was a documentation/naming hazard, not a runtime
  bug, but it could easily lead to one.
- **Fix:** Three-concept naming convention enforced:
  - **PUBLIC (on-chain):** `betti_id: bytes` — Betti numbers are the true
    homotopy invariant. Field renamed on `Validator`, `AccountState`,
    `HashCommitment`, routing `Relay`, and all downstream consumers (~21 files).
  - **PRIVATE (wallet-only):** `FiberSecret` — class renamed from
    `SpectralFingerprint` in `credential.py` and 5 consumer modules.
    Makes the privacy boundary explicit: "secret" ≠ "fingerprint".
  - **Docstrings:** All "spectral fingerprint" phrases replaced with
    "fiber secret" in ~10 files (credential, encrypt, decrypt, validation,
    hardness, validator_selection, coherence, symmetry_group, vrf_slots,
    routing).
  - `PublicIdentity` class and `identity_hash()` method unchanged (already correct).
  - Tests updated: 29 passed, 0 failed after rename.

### R11. Canonical bounds API — regressed; reopened

> **Current-tree regression:** raw `POV_LOWER <= gap <= POV_UPPER` checks remain
> in `src/geometry/homotopy_path.py` and `src/chain/block.py`. They must be
> classified during their ordered folder audits; the historical “zero raw
> comparisons” statement below no longer describes the working tree.
- **Was:** 4 sites still used raw `POV_LOWER <= gap <= POV_UPPER` float
  comparisons instead of the canonical `gap_in_bounds()` fixed-point API:
  `chain/agents/stabilizer_agent.py`, `chain/homotopy_transaction.py`,
  `chain/block.py` (`_verify_pov_proof`), `geometry/homotopy_path.py`
  (`check_full_equivalence`).
- **Fix:** All 4 sites converted to `gap_in_bounds(x).accepted()`.
  `stabilizer_agent.py` now uses `GapStatus.MARGINAL/INVALID/ZERO` for
  fee stress detection. `homotopy_transaction.py` replaced inline
  `SQRT2`/`POV_LOWER`/`POV_UPPER` with import from `primitives.spectral_bounds`.
  Zero raw `POV_LOWER <= gap` comparisons remain in `src/`.
  Tests: 171 Python passed, 0 failures.

### R10. Separation of concerns / documentation staleness audit — reopened

> The fixes below describe an earlier checkpoint. R9/R11 regressions and the
> rejected K-theory material formerly presented as active in
> `GATE_ARCHITECTURE.md` show that this cross-language cleanup is not globally
> complete in the current tree.
- **Was:** Four issues found during cross-language consistency audit:
  1. `ARCHITECTURE.md` had 7 stale "spectral fingerprint = identity"
     references (data flow, Panopticon table, Quick Start, deterministic
     subcategory box, credential table).
  2. `coherence.py` `CechNerve.fingerprints` field name misleading — these
     are vertex ordering keys, not spectral fingerprints.
  3. `Foundation.lean` Hodge Rust columns said "(planned)" with no target.
  4. `test_wallet_oracle_flow.py` used old `commitment_bytes` / `"commitment"`
     field names that didn't match `id_commit` API after R5.
- **Fix:**
  - `ARCHITECTURE.md`: 7 replacements — `betti_id`, `fiber_secret`,
    `fiber_secret = sheaf Laplacian spectral decomposition: eigenvalues
    λ_i(Δ) + eigenbasis U ∈ O(d)`, updated Quick Start code, data flow,
    Panopticon table.
  - `coherence.py`: `CechNerve.fingerprints` → `CechNerve.vertex_ids` and
    all 15 internal references.
  - `Foundation.lean`: Hodge Rust status updated to
    `planned: rust/oracle/src/geometry.rs`.
  - `test_wallet_oracle_flow.py`: `commitment_bytes` → `id_commit`,
    `"commitment"` → `"id_commit"` in JSON assertions.
  - `proofs/consensus.py`: fixed `register_account` body using old
    `fingerprint` local after param renamed to `betti_id`.
  - Tests: 171 Python + 189 Rust = 360 tests, 0 failures.

### R12. Signature and mapping stubs (consensus.py P3.4)

> **Reopened and rejected by P1/CH0:** the historical hash-equality check below
> is not a digital signature, and the empty-signature compatibility branch is
> fail-open. The account-index fallback is also not an authenticated mapping.
> Do not repair this Python acceptance path; replace it with the canonical Rust
> transaction/authorization boundary.
- **Was:** `_validate_transaction` had a `# TODO: Verify signature` stub
  that accepted all signatures. `_transaction_to_cochain` used hardcoded
  vertex indices instead of account→vertex mapping. No `account_vertices`
  dict existed. Test imports failed on missing `_TX_SIG_DOMAIN`.
- **Fix:**
  - Added `_TX_SIG_DOMAIN = b"HCRYPT_TX_SIG_V2"` domain separator constant.
  - `_validate_transaction`: verifies provided signatures via
    `sha256(_TX_SIG_DOMAIN + tx.hash())`. Empty signature still allowed for
    backwards compatibility.
  - `ProofOfValue.__init__`: added `account_vertices: Dict[bytes, int]`.
  - `register_account`: populates `account_vertices[fingerprint] = vertex_id`.
  - `_transaction_to_cochain`: uses `account_vertices.get(tx.sender/recipient)`
    for proper fingerprint→vertex index mapping with fallback.
  - Tests: 171 passed, 0 failures.

### R13. Chain.lean sorry holes closed (canonical cochain commitment proofs)
- **Was:** `Chain.lean` R1 resolution introduced vector cochain commitments
  but left 3 `sorry` holes: `tx_compose_assoc_sum`,
  `tx_compose_identity_right_sum`, `tx_compose_identity_left_sum` required
  `List.zipWith` associativity/identity lemmas that don't exist in Mathlib.
- **Fix:** Proved all three via custom helper lemmas:
  - `foldl_add_extract`: `l.foldl (+) a = a + l.foldl (+) 0`
  - `zipWith_add_foldl_assoc`: associativity of zipWith (+) under foldl (+) 0
  - `zipWith_add_replicate_zero_right/left`: identity via replicate 0
  - `sybil_resistance`: explicit `calc` proof using `lt_mul_of_one_lt_left`
    and `mul_lt_mul_of_pos_right` (replacing failed `nlinarith`).
  - 0 `sorry`, 0 Lean errors. All 6 chain axioms + derived properties proved.
- **Scope correction:** proof completeness for these definitions does not
  validate the protocol interpretation. In particular, scalar edge-sum
  “balance,” spectral identity/fork weight, and quadratic split weight still
  lack the selected ledger/consensus semantics described in CH0.

### R14. Dedicated Lean sheaf coherence module (separation of concerns)
- **Was:** Sheaf-coherence assumptions (restriction compatibility, triangle
  commutativity, cochain/Laplacian coherence) were spread conceptually across
  `Foundation.lean` and `Grassmannian.lean` without a dedicated contract file.
- **Fix:** Added `lean/Axioms/SheafCoherence.lean` and imported it in
  `lean/Axioms.lean`.
  - Introduces dedicated contracts:
    - `RestrictionShapeCompatibility`
    - `EdgeNaturality`
    - `TriangleFaceCommutativity`
    - `SheafCochainComplex` (δ₁ ∘ δ₀ = 0)
    - `HodgeCoherence` (Δ from coboundary + orthogonality)
    - `FiniteSimplicialNerve`
    - bundled `SheafCoherence` + `SheafCoherenceWellFormed`
  - Adds bridge theorem:
    `coherence_implies_structural_preconditions`.
  - Runtime mapping called out to:
    archived `archive/python/src/invariants/cohomology.py` and
    `archive/python/src/invariants/unified.py`.
  - Keeps `Grassmannian.lean` focused on manifold/metric geometry only.

### R15. Commitment payloads inherit element-dependent sheaf coherence
- **Was:** `Proximity.CochainBridge.GlobalSectionCandidate S c` combined raw
  payload shape with ambient `SheafCoherenceWellFormed S`, but did not relate
  the particular payload `c` to `S`. It therefore did not establish that the
  decoded payload was exact, closed, or topology-bound. The name “global
  section” was also degree-inaccurate for a committed element of `C¹`.
- **Fix:**
  - `SheafCochainComplex` now carries typed `C⁰`, `C¹`, and `C²` carriers,
    typed adjacent coboundaries, and the actual square-zero consequence.
  - `CommittedCochainInterpretation` supplies the payload decoder and
    payload-to-sheaf binding predicate.
  - `CommittedCochainWellFormed S c` combines wire shape, ambient sheaf
    coherence, binding to `S`, and an exact-one-cochain witness
    `decode c = δ₀ a`.
  - `oneCocycle_of_committedCochainWellFormed` derives
    `δ₁ (decode c) = 0`.
  - The stronger predicate propagates through proximity encoders and observed
    Plucker bindings, proof-carrying/SNARK/runtime artifacts, exact gates, and
    sheaf-indexed transaction/block predicates in `Chain.lean`.
  - `GlobalSectionCandidate` remains only as a compatibility alias for the
    correctly named `AcceptedCocycle`.

### R16. Exact payload to Hodge-blinded value is a typed bridge
- **Was:** `BlindedCommitmentAxioms` contained four independent proposition
  fields but did not carry an accepted exact payload, a topology-derived
  harmonic direction, or the equation relating them. The paper-level formula
  could therefore be read as though the serialized exact payload and the
  Hodge-blinded value were the same object, and reused one symbol for opening
  data and the harmonic blinding scalar.
- **Fix:** Added `lean/Axioms/CochainCommitment/Blinded.lean`.
  - `HodgeBlindingContext` carries typed addition/scalar action, harmonicity,
    orthogonality, and the topology-hash-indexed direction `H_τ`.
  - `BlindedCommittedCochain` starts from an already accepted exact payload and
    records the separate equation `value = decode(base) + s • H_τ`.
  - Bridge theorems recover the exact base witness, prove the base is a
    one-cocycle, prove the selected direction is harmonic, establish
    exact–harmonic orthogonality, and expose the exact-plus-harmonic
    decomposition.
  - Cryptographic binding and hiding remain explicit assumptions in
    `BlindedCommitmentAxioms`: exactness supplies the geometric substrate but
    does not by itself prove a distributional hiding game.

---

## Priority 1 — Consensus Semantics

1. **End-to-end signed judgment parity**
   - R6 resolved one local enum shape only.
   - Bind the Lean `SpectralJudgment` and target roots into authenticated Rust
     votes/certificates; `Undetermined` remains hold, never acceptance.

2. **Canonical bounds API adoption**
   - R11 is historical and regressed. The future Rust verifier must use one
     fixed, versioned classifier and bind its result to the full statement.

## Priority 2 — Identity Model Convergence

3. **Identity/presentation model cleanup**
   - R9 is reopened. Use the explicit public classifier/presentation handle
     chosen by the Lean model; do not substitute Betti or spectral equality
     for a path/equivalence witness.

## Priority 3 — Verification Completeness

4. **Canonical authorization and mapping**
   - R12's Python hash-equality compatibility check is rejected.
   - Specify and implement a real signature/authorization scheme whose signed
     bytes include all state-affecting transaction fields and state context.

5. **Lean proof hole burn-down**
   - Track and close `exact?` holes in `lean/Hardness.lean`,
     `lean/Laplacian.lean`, `lean/Tsirelson.lean`.
   - Keep assumptions explicit in `lean/Axioms/*` until discharged by proofs.
   - ~~`Chain.lean` 3 `sorry` holes~~ → Resolved as R13.

6. **Infinite-anonymity classifier bridge and security game**
   - Lean proves infinite Grassmannian/Laplacian candidate families
     (`infinite_lines`, `Ω_1_infinite`, and the injective real-parameter
     subspace construction).
   - `Axioms/HomotopyClass.lean` currently proves classifier-fiber membership,
     nontriviality, and non-faithfulness, but not that each protocol-relevant
     public fiber is infinite.
   - Add an explicit bridge showing that an infinite candidate family lies in
     one chosen public classifier fiber under stated hypotheses.
   - `Axioms/Fibration.lean` currently proves same-class membership only for
     one already-supplied `EphemeralFiberSpec`. It does not define a generation
     family, prove distinct outputs, or connect `FiberSystem.transport` to the
     transported private state. Introduce an `EphemeralRepresentativeSpec`
     (keeping the old name as a compatibility alias), an indexed
     `EphemeralRepresentativeFamily`, and a transported-state package. The
     path is the class-membership witness; the generated endpoint is the
     ephemeral representative, not a “random cochain candidate.”
   - For an infinite seed/index type and an injective representative family,
     prove that the family range is an infinite subset of the base
     representative's public classifier fiber. Then add the concrete bridge
     hypothesis relating the Grassmannian/Laplacian candidate family to the
     chosen protocol classifier.
   - Paper 2 should then state the adversarial sampling/distribution model.
     Avoid treating “`1/∞ = 0`” as a literal uniform probability theorem until
     that game exists; use it only as shorthand for an asymptotic finite-family
     limit.

## Priority 4 — Rust Hodge Geometry

7. **Hodge decomposition in Rust**
   - G0 rejects the Python routine as a refinement, so it must not be ported.
   - First decide which Paper 2 public statement actually requires a runtime
     Hodge computation. If one does, implement degree-one decomposition from
     validated typed coboundaries and test it against Lean-generated or
     independently checked finite fixtures.
   - A full `BlindedCommitment` verifier also requires a selected
     authenticated construction; orthogonality alone is not a proof system.

## Priority 5 — Architecture Document Recovery Audit

8. **Audit `docs/ARCHITECTURE.md` as a mixed-status design source**
   - Treat the document as partially deprecated, not disposable. It contains
     original narrative, diagrams, categorical intuition, and system context
     that may still be valuable even where its concrete claims or names are
     stale.
   - Classify each substantive section or diagram into one of five outcomes:
     **retain as context**, **promote to Paper 1**, **formalize or bridge in
     Lean**, **move to Paper 2 or unnumbered product work**, or **delete as obsolete/duplicated**.
   - Cross-reference every mathematical claim against the current Lean
     theorem/axiom surface and Paper 1. In particular, distinguish actual
     homotopy-class semantics from spectral identity claims, degree-zero global
     sections from degree-one harmonic/exact cochains, and proved structure
     from architectural analogy.
   - Mine strong phrasing and useful diagrams before removing deprecated
     sections. Preserve the original story when it clarifies design intent,
     but label it as motivation unless the corresponding formal object exists.
   - For concepts present in the document but absent from Lean, decide
     explicitly whether the gap is:
     1. a missing mathematical definition/theorem that belongs in Lean;
     2. a protocol/runtime obligation for Paper 2;
     3. an unnumbered future product/positioning idea; or
     4. an obsolete idea that should not be implemented.
   - Update links from the main README only after this classification, so the
     README can continue to point to useful architecture context without
     treating the entire document as current normative specification.

9. **Correct active infinity/anonymity overclaims (`docs/archive/` excluded)**
   - `docs/ARCHITECTURE.md` currently treats path availability, public-class
     membership, infinite class size, cryptographic indistinguishability, and
     constant-size proofs as though they were one proved result. Separate the
     semantic classifier fiber from the unproved cardinality bridge and the
     later anonymity game.
   - `docs/REFACTOR_PLAN.md` calls the public fiber infinite “by Hodge theory”
     and says `1/∞` anonymity is rigorous. Reclassify these as target claims;
     Hodge decomposition alone does not prove that a protocol-relevant
     classifier fiber is infinite.
   - `docs/COMPARISON.md`, `docs/ORACLE_SECURITY.md`, `docs/PROOF_MAP.md`, and
     `docs/ROADMAP.md` present infinite anonymity as an existing system
     guarantee. Replace with the proved facts (non-faithful public collapse and
     infinite Grassmannian/Laplacian candidate families) plus the explicit
     missing classifier-fiber/security-game bridge.
   - `docs/GEOMETRY.md` equates homotopy equivalence with cryptographic
     indistinguishability. Rewrite this as semantic equivalence under the
     selected public classifier; computational indistinguishability requires a
     protocol observation model and adversarial game.
   - `docs/GATE_ARCHITECTURE.md` says “same Betti implies
     indistinguishable.” Treat same-Betti membership only as a candidate public
     equivalence relation until leakage, proof, and sampling models are fixed.
   - Do not alter valid non-anonymity uses of infinity, such as the
     `t → ∞` heat-flow/Hodge-projection limit in `docs/SECURITY.md`.
   - Leave `docs/archive/` unchanged as historical design record. Active docs
     may link to an archive file only when clearly labeled as superseded or
     motivational.

## Priority 6 — Projection Evidence Lifecycle (Paper 2 / Runtime)

10. **Checkpoint one fixed context and authenticate its sealed manifest**
   - **Current clarification (2026-11-05):** the previous per-commit/reset
     allocation was a proposed runtime profile, not a theorem or a settled
     granularity choice. Raw context binding and accepted exactness are separate.
   - The Lean `ProjectionStage.StateBus` is a proof-level, per-witness chain of
     invariants. Runtime code must not reuse an active bus or any stage result
     for a different cochain commitment.
   - Reuse `Storage.Context` for the original interpretation/artifact and
     derived snapshot/digest/parameter names. A raw diagnostic checkpoint may
     be complete and persisted without being eligible for a ledger anchor.
   - The existing typed prefix retains each selected projection/gate result
     and its exact certified predecessor. The mathematical storage adapter
     does not recompute those checks or establish a runtime execution count.
     The optional syndrome adequacy gate is not silently added to the accepted
     commitment chain's hard gates.
   - Implement atomic advance-and-append for the selected runtime profile;
     the mathematical manifest already preserves prior typed leaves. An append may create
     a new intermediate revision root, but incomplete revisions are never
     main-chain anchors.
   - After successful finalization, seal and persist the immutable manifest;
     local consumption requires its exact receipt. Real durability, recovery
     and private-memory erasure remain runtime obligations.
   - Use `TransitionAnchor` and `ProjectionAnchor` to join the same original
     objects, final prefix and gate database to accepted candidate evidence.
     Instantiate the supplied history inclusion relation with the selected
     authenticated body/root scheme; a dedicated `sheafBlockRoot` field has
     not been chosen. The public manifest should bind the original cochain,
     `SheafStateSnapshot` root,
     topology metadata, stage-artifact root, evidence root,
     projection/parameter-set ID, and schema/version. A later commitment may
     link to a previous finalized root
     for history, but must never inherit its current-stage proofs.
   - This is a protocol/storage obligation, not an additional Paper 1
     proximity theorem. Specify serialization, replay protection, garbage
     collection, and reorganization behavior in Paper 2 before implementing
     the Rust/Python path.

## Priority 7 — Lean Protocol Layer Separation

11. **Keep one Lean workspace; introduce a one-way `Protocol/` dependency layer**
   - Do not create independent Lean projects per paper. Keep the existing
     `lean/` workspace and add `lean/Protocol/` for Paper 2 specifications and
     proofs.
   - Add aggregate imports `Paper1.lean` and `Paper2.lean`. `Paper1.lean`
     imports only core mathematics and shared public-artifact boundaries;
     `Paper2.lean` imports `Paper1` plus `Protocol`.
   - Move or re-export consensus, coregulator, ledger, chain, stage
     admissibility, ephemeral lifecycle, storage transitions, and mutable
     proximity-evidence lifecycle under `Protocol/`. Preserve temporary
     compatibility imports during the migration so theorem work and file moves
     remain reviewable as separate changes.
   - Split mixed files rather than classifying them wholesale:
     `Axioms/Fibration` keeps path/class/transport mathematics, while runtime
     freshness/single-use obligations move to `Protocol/EphemeralLifecycle`;
     proximity gate theorems stay in `Proximity`, while authenticated evidence
     databases and reset/finalization transitions move to
     `Protocol/ProximityEvidence`.
   - Lean owns the abstract protocol state machines and safety/preservation
     theorems. Rust owns CSPRNG calls, concrete cryptography, canonical bytes,
     hashing, database atomicity, zeroization, malformed-input rejection, and
     networking. A later refinement layer should state that Rust acceptance
     realizes the Lean transition relation.
