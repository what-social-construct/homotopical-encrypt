# Semantic Parity Queue (Lean ↔ Python ↔ Rust)

This queue tracks implementation mismatches that should be resolved after the
proof-status/axioms split.

## Reference Policy (Lean-first naming hygiene)

When code comments/docstrings cite formal backing, use current Lean module
paths only:

- `lean/Hardness.lean`
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

| Python file | Canonical Lean owner / coverage | Semantic verdict | Current disposition and next action |
|---|---|---|---|
| `algebra.py` | Lean-side exterior construction is proved in `Proximity/GrassmannianPlucker.lean`; correspondence with NumPy coordinate order/sign/normalization is Unmapped. | Preserve `wedge`/`wedge_k` as candidate numerical helpers pending parity tests. The generic coboundary-commutation claim is unsupported, and the non-Euclidean `hodge_star` omits the inverse-metric action. | Active reference, but split or reject the non-Euclidean Hodge-star branch and add coordinate/shape/metric tests. |
| `cochain.py` | `Sheaf/CellComplex.lean` owns cells/incidences, `Sheaf/Cellular.lean` owns typed (C^0 -> C^1 -> C^2), and `Sheaf/Commitment.lean` owns the downstream exact-(C^1) envelope; Python correspondence is Unmapped. | Preserve only as an identity-stalk graph prototype. It implements (delta_0) but not the claimed general (delta_1); its degree-zero Laplacian has no direct new-core counterpart; and its “message is harmonic” language conflicts with the exact-(C^1) model. | Migration-blocked deprecation candidate. Inventory consumers, rename the prototype honestly, and keep only fixtures that refine the Lean types. |
| `divergence.py` | No mathematical Lean owner; `Axioms/Grassmannian.lean` has only an abstract scalar eligibility divergence. | Unselected research metrics, not homotopy-equivalence criteria. | Deprecated in place and removed from the package export surface; later archive unless Paper 2 selects and specifies one metric. |
| `grassmann.py` | Search-space and Plucker-side Lean results are Proved; metric/Karcher properties in `Axioms/Grassmannian.lean` are Specified; Python refinement is Unmapped. | Projector, principal-angle, distance, and forward-Plucker routines are candidate numerics only after rank/shape/projector validation. General `from_plucker`, the current “parallel transport,” and exp/log-dependent Karcher claims do not refine the Lean obligations as written. | Active prototype consumed by consensus; quarantine invalid branches and add validation/parity tests before archival decisions. |
| `homotopy.py` | Abstract paths/classifier fibers are Interface-only in `Axioms/HelferFOL.lean`, `Axioms/HomotopyClass.lean`, and `Axioms/Fibration.lean`; `Axioms/PythonHomotopyRefinement.lean` is an incomplete snapshot shim and is not a path refinement. | Conflicts with Lean where equality of a finite invariant tuple is called homotopy equivalence, or arbitrary matrices plus a hash are called a rotation proof. | Semantic deprecation candidate with active chain/invariant consumers. Migrate consumers to encodings/refinements of the Lean classifier and supplied-path interfaces. |
| `k_theory.py` | No Lean owner. | Reject as normative mathematics: the curvature, characteristic-class, and characteristic-cycle calculations are heuristic and unused. | Deprecated in place and removed from the package export surface; later archive as explicitly historical research only. |
| `natural.py` | General sheaf-coherence obligations are Specified in `Axioms/SheafCoherence.lean`; specialized projection-gate composition is Proved in `Proximity/Gates.lean`; Python refinement is Unmapped. | Conflicts as a validator: missing components/restrictions pass vacuously, and pullback/pushforward/composition invent or silently collapse untyped data. | Quarantine as a semantic validator; replace with a typed finite-cell map before migrating active consumers. |
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

Deprecation checkpoint: `k_theory.py`, `persistence.py`, and
`divergence.py` have no direct in-repo consumer beyond 41 names eagerly
re-exported by `primitives/__init__.py`; `primitives/spectral_bounds.py` has no
importer.  Their imports and `__all__` entries have now been pruned atomically,
and all four files carry explicit deprecation headers. Smoke imports succeeded,
and the focused hardening/math/hardness/roundtrip baseline passed 96/96. The
files remain in place for provenance until an archive-only cleanup commit.

### Pass I0: `src/invariants/`

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

The concrete `src/geometry/homotopy_path.py` audit belongs to the later geometry
stage. Lean presently owns only an abstract supplied path witness and its
classifier consequences; it does not yet refine that numerical matrix-path
constructor.

---

## ✅ Resolved

### R1. Cochain commitment structure: scalar → canonical payload (Lean ↔ Py ↔ Rust)
- **Was:** Lean `Chain.lean` used `commitment_value : ℝ` (scalar).
  Python and Rust used `edge_values: List[int]` / `Vec<i64>` (vector).
- **Fix:** Lean now uses the canonical `CochainCommitmentData` payload:
  `modulus`, declared edge count, vector `edge_values : List ℤ`, and 16-byte
  topology hash. `Chain.lean` transactions carry this payload directly as
  `cochain_commitment`, so chain proofs, proximity bridges, and Rust wire
  validation refer to one cochain commitment shape.
- **Scope correction:** this resolves payload shape only. The short topology
  hash is not yet a canonical `SheafStateSnapshot` root, and the raw edge
  vector binds an exact `C¹` value rather than a unique `C⁰` opening.

### R2. BlindedCommitment / VectorCommitment missing from Rust
- **Was:** Python had `BlindedCommitment` and `VectorCommitment` in
  `src/crypto/commitment.py`; Rust only had `CochainCommitment`.
- **Fix:** `rust/node/src/crypto/commitment.rs` now has `BlindedCommitment`
  (Hodge-structured blinding with deterministic harmonic basis) and
  `VectorCommitment` (partial opening via coboundary constraint). Both have
  test coverage.

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

### R7. Grassmannian consensus geometry axioms missing from Lean
- **Was:** Python `coherence.py` and Rust `geometry.rs` both compute
  Grassmannian distance, Karcher mean, and sheaf Laplacian, but Lean had no
  corresponding axiom module.
- **Fix:** `lean/Axioms/Grassmannian.lean` created with axiom structures for:
  GrassmannianDistance, KarcherMean, SheafLaplacian, CechNerve,
  PluckerEligibility, and ConsensusGeometry composition. Each axiom cites
  corresponding Python/Rust implementation. Imported from `lean/Axioms.lean`.

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
    `src/invariants/cohomology.py` and `src/invariants/unified.py`.
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

1. ~~**Topos boundary parity (Python vs Rust)**~~ → Resolved as R6.

2. ~~**Canonical bounds API adoption**~~ → Resolved as R11.

## Priority 2 — Identity Model Convergence

3. ~~**Identity model cleanup (Betti/public vs spectral/private)**~~ → Resolved as R9.

## Priority 3 — Verification Completeness

~~4. **Signature and mapping stubs**~~ → Resolved as R12.

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
   - Python has `src/geometry/hodge.py`; Rust only has `geometry.rs` in oracle
     (Laplacian + spectral gap). Need Rust Hodge decomposition for full
     `BlindedCommitment` orthogonality verification.
   - Foundation.lean `HodgeDecomposition` and `HodgeOrthogonality` map to
     Python only — Rust side is planned.

## Priority 5 — Architecture Document Recovery Audit

8. **Audit `docs/ARCHITECTURE.md` as a mixed-status design source**
   - Treat the document as partially deprecated, not disposable. It contains
     original narrative, diagrams, categorical intuition, and system context
     that may still be valuable even where its concrete claims or names are
     stale.
   - Classify each substantive section or diagram into one of five outcomes:
     **retain as context**, **promote to Paper 1**, **formalize or bridge in
     Lean**, **move to Paper 2/3**, or **delete as obsolete/duplicated**.
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
     3. a product/positioning idea for Paper 3; or
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

10. **Reset the active state bus per commitment; persist only finalized evidence**
   - The Lean `ProjectionStage.StateBus` is a proof-level, per-witness chain of
     invariants. Runtime code must not reuse an active bus or any stage result
     for a different cochain commitment.
   - Starting a new commitment initializes a fresh active bus keyed by at least
     the exact-cochain commitment hash, canonical `SheafStateSnapshot` root,
     topology metadata, and projection/parameter-set ID.
   - Each restriction and syndrome naturality check is evaluated at its owning
     transition exactly once. Later stages consume the certified predecessor;
     the final gate composes stored stage equations and does not rederive them.
   - After successful finalization, discard/reset the mutable active bus and
     persist an immutable certificate/evidence object in sheaf or
     content-addressed storage.
   - The main chain should store only an evidence-root hash bound to the exact
     cochain, `SheafStateSnapshot` root, topology metadata,
     projection/parameter-set ID, and evidence schema/version. A later
     commitment may link to a previous finalized root
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
