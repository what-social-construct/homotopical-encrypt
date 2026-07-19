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

## ✅ Resolved

### R1. Cochain commitment structure: scalar → canonical payload (Lean ↔ Py ↔ Rust)
- **Was:** Lean `Chain.lean` used `commitment_value : ℝ` (scalar).
  Python and Rust used `edge_values: List[int]` / `Vec<i64>` (vector).
- **Fix:** Lean now uses the canonical `CochainCommitmentData` payload:
  `modulus`, declared edge count, vector `edge_values : List ℤ`, and 16-byte
  topology hash. `Chain.lean` transactions carry this payload directly as
  `cochain_commitment`, so chain proofs, proximity bridges, and Rust wire
  validation refer to one cochain commitment shape.

### R2. BlindedCommitment / VectorCommitment missing from Rust
- **Was:** Python had `BlindedCommitment` and `VectorCommitment` in
  `src/crypto/commitment.py`; Rust only had `CochainCommitment`.
- **Fix:** `rust/node/src/crypto/commitment.rs` now has `BlindedCommitment`
  (Hodge-structured blinding with deterministic harmonic basis) and
  `VectorCommitment` (partial opening via coboundary constraint). Both have
  test coverage.

### R3. Lean axioms missing cochain commitment module
- **Was:** No dedicated Lean axiom module for cochain commitment properties.
- **Fix:** `lean/Axioms/CochainCommitment.lean` created with axioms for
  coboundary linearity, commitment binding (SVP-hard), hiding (lattice-hard),
  homomorphic addition, blinded commitment orthogonal decomposition, and
  vector commitment partial-opening soundness. Imported from `lean/Axioms.lean`.

### R4. Foundation.lean missing commitment axioms
- **Was:** `Foundation` structure only had 4 fields (CochainComplex,
  Laplacian, Hodge decomposition/orthogonality).
- **Fix:** Added `CoboundaryLinearity`, `CommitmentBinding`,
  `CommitmentHiding`, `CommitmentHomomorphic` fields. Cross-reference table
  maps each axiom to its Python/Rust implementation.

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

### R9. Identity model cleanup: SpectralFingerprint → FiberSecret, .fingerprint → .betti_id
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

### R11. Canonical bounds API: all raw float comparisons → gap_in_bounds()
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

### R10. Separation of concerns / documentation staleness audit
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
