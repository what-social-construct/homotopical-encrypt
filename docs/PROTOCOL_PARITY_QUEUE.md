# Protocol Parity Queue (Lean ↔ Rust ↔ Python ↔ Paper 2)

This queue tracks protocol state machines, runtime ownership, and migration
work. Canonical mathematical meaning lives in `SEMANTIC_OWNERSHIP.md`;
`SEMANTIC_PARITY_QUEUE.md` tracks cross-language object refinement.

## Ownership Rule

- **Lean** owns abstract protocol states, accepted-transition relations,
  safety/preservation theorems, and the mathematical statements carried by
  public evidence.
- **Rust** owns the production realization: randomness, concrete
  cryptography, canonical bytes, hashing, proof verification, database
  atomicity, zeroization, malformed-input rejection, concurrency, and
  networking.
- **Python** is a research/reference implementation unless a queue item says
  otherwise. It is not consensus authority.
- **Paper 2** specifies the protocol, security games, runtime threat model, and
  concrete evidence/state-transition flow.

The long-term refinement target is:

> Every Rust-accepted protocol transition realizes the corresponding Lean
> transition relation.

Current source update (2026-11-05): the first **bounded conservative
transition core** is implemented under `Protocol/Ledger`, with candidate-indexed
TCB evidence and a same-proposal quorum adapter. On Lean 4.35.0 and Mathlib
`56a005855ea17e0b0958f73ec801ae140b0a1679`, the default build passes 9,228 jobs
and the union of all fifteen default roots with the additional ledger,
evidence, storage, anchor and canonical-adapter targets passes 9,233 jobs.
The [shared validation record](MATH_STORAGE_VALIDATION.md) tracks these builds
and theorem dependencies. This is a mathematical
kernel under explicit profile/boundary assumptions, not a complete secure
protocol, concrete Rust refinement, or finality result.

The subsequent storage source now adds one original sheaf/snapshot/artifact
context, typed projection prefixes, append-once manifests, sealing and
receipt-indexed local consumption under `Protocol/Storage`. The
[shared validation record](MATH_STORAGE_VALIDATION.md)
includes these modules and their explicit integration fixtures in the current
Lean 4.35 union build. Concrete backend atomicity,
durability, global run freshness and physical erasure remain runtime/profile
work.

The new `Storage/{Anchor,ProjectionAnchor}.lean` source joins that same
candidate, original interpretation/artifact and exact sealed manifest to one
history entry under explicit authentication relations. The projection adapter
also names the actual gate database included under the candidate's evidence
root. `Storage/AnchorExamples.lean` supplies positive and transplant fixtures.
All nineteen selected anchor endpoints pass fresh dependency audits with
exactly `propext`, `Classical.choice` and `Quot.sound`. Across the three fresh
audit groups, all 68 distinct reports pass: 64 standard-only and the same
four boundary/canonical endpoints retaining native arithmetic certificate
dependencies. Lean 4.35 prints those as generated
`_native.native_decide.ax_*` constants; the older `Lean.ofReduceBool` and
`Lean.trustCompiler` names describe the historical reports. No selected report
uses a cited-bound axiom or `sorryAx`.

These additions also passed the preserved Lean 4.24.0 baseline: the focused
build completed 7,417 jobs, the full default build completed 7,532 jobs, and
the 19 selected endpoint audits report only `propext`, `Classical.choice` and
`Quot.sound`. Those counts remain historical evidence, separate from the
successful Lean 4.35 validation above.

## Chain Ownership Decision

Paper scope and implementation language are independent. The chain is Paper 2,
but every consensus-determinative state, predicate, transition, and safety
property belongs in Lean. Rust supplies the production realization of those
relations. Python may supply fixtures or proposal-generation experiments, but
does not decide acceptance.

The practical test is:

> If two honest nodes could fork because they disagree about this rule, specify
> the rule in Lean. If the question is how to parse, authenticate, persist, or
> execute the rule safely, implement it in Rust behind a Lean-owned interface.

The first transition kernel is parameterized over resources, assets,
nullifiers and the existing snapshot carrier. It uses finite nonnegative
resource markings with an additive asset valuation; this chooses neither an
account model nor a UTXO model. Its first action conserves the declared value,
with fees included among produced resources. Ownership/authorization,
nullifier derivation and the intended resource/asset interpretation remain
explicit application-profile work. Mint/burn policies are outside this kernel.

### Must be typed or proved in Lean

| Chain object | Lean-owned content | Current status / target owner |
|---|---|---|
| Committed public state | Semantic coordinates named by a state root: resource/nullifier state, tip/height/epoch, snapshot/topology/cochain/evidence context. | Implemented in `Protocol/Ledger/State.lean`. `PublicStateUpdate` remains the reused hash envelope; object-indexed `Evidence.RootBindings` links its roots to actual states. Concrete encodings/root schemes remain open. |
| Candidate transition | Action body, before-state, snapshot, complete proposal, computed successor, and a validity predicate for that exact candidate. | Implemented in `Protocol/Ledger/Transition.lean`: `after` applies the body's actual flow and nullifier list; `Valid` checks conservation, availability, freshness and context. The result is not an independently supplied after-state. |
| Typed transition evidence | Evidence indexed by actual candidate validity, with the same payload/artifact and before/after/root bindings. | Implemented in `Protocol/Evidence/Transition.lean`, reusing `WitnessVerifierEnvelope`. It derives `candidate.Valid P` from the matching observed statement; root/inclusion relations are supplied on the actual objects. Leaf digest is distinct from cochain and evidence roots. |
| Accepted transaction | Authorization, freshness, conservative flow, accepted payload/snapshot context, and computed application. | Bounded `AcceptedUpdate` and preservation theorems implemented under `Protocol/Ledger`; `Ledger/Sheaf.lean` reuses the existing exact-payload interpretation. Concrete ownership/authorization and cryptographic security remain profile obligations. Legacy `Chain.TransactionAccepted` is not silently strengthened or migrated. |
| Nullifier state | Abstract identifiers, body-list binding, freshness, duplicate-free use, monotone consumption and replay exclusion. | Implemented in `Ledger/Nullifier.lean` and `Candidate.Valid`: nonempty/Nodup/Fresh are checked on the actual body list, which the update consumes. Replay with that same list is excluded even with new proposal metadata. Derivation/linkability security, ephemeral-handle linkage and reorganization semantics remain open. |
| Exact ledger flow | Finite nonnegative quantities, availability and conservative multi-resource application. | `Ledger/ValueFlow.lean` uses mathlib finite markings and an explicit additive asset valuation. Enabled conservative flow preserves value; connected `Execution` preserves value and spent-set monotonicity. Fees may be produced resources. Mint/burn and concrete resource/asset semantics remain open; edge sums are not the conservation theorem. |
| Block body and proposal binding | Ordered batch, proposal context and root coordinates, plus semantic block binding. | The one-action candidate/evidence join is implemented, and `ProposalRef` now has a distinct signed `snapshotRoot`. A batched block/body object and its binding remain future `Protocol/Chain/Block.lean` work. Snapshot root is not topology root. |
| Certified block / chain extension | Acceptance certificate for the exact proposal and `Valid` judgment, joined to application. | `Ledger/Certified.lean` now attaches quorum evidence to the same candidate proposal, derives accepted update, and excludes hold/rejection certificates. Batched certified blocks, round/lock discipline, finality and liveness remain open. |
| Consensus rounds and finality | Phase/round transitions, locks and unlock conditions, non-faulty no-double-vote invariant, equivocation evidence, finality promotion, and agreement/safety theorems. | `Committee`, `Vote`, and `Quorum` provide the initial kernel. Add round/lock/finality modules under `Protocol/Consensus`. |
| Oracle judgment lifecycle | Authenticated judgment target, `Undetermined -> Hold`, retry/re-projection transition, and the conditions for a later `Valid` or `Invalid` result. | `Protocol/Oracle.lean` is an attachment point. Concrete signatures and endpoints remain Rust-owned. |
| `SheafState` lifecycle | One fixed original sheaf interpretation, snapshot and artifact; typed projection/gate advancement and local receipt-indexed consumption. | Mathematical source under `Storage/{Context,Checkpoint,Projection}.lean` reuses the existing nested state bus. Raw snapshot-bound context is separate from `Context.Accepted`; noisy inputs remain available. Connected execution makes consumption terminal. Global run-ID freshness, replay policy across independent histories, backend atomicity and erasure remain open. |
| Open/sealed `SheafBlock` | Actual typed payload/digest leaves, one common context, slot-at-most-once append, required-slot completeness and an exact sealed list/root. | `Storage/Checkpoint.lean` supplies `OpenManifest`, `SealedManifest` and `PersistenceReceipt`; `Storage/Projection.lean` joins a seal to one final nested prefix. `Storage/Anchor.lean` supplies the mathematical history join under a selected inclusion relation. These modules pass the Lean 4.35 aggregate/integration build. Canonical public bytes, SHA-256/inclusion security and durable backend implementation remain open. |
| History entry to original storage | Same candidate, payload interpretation, public artifact, exact sealed list/root and actual projection gate database. | `Storage/{Anchor,ProjectionAnchor}.lean` derives accepted-context, payload/snapshot and manifest joins from the existing transition evidence plus object-indexed authentication relations. Quorum endpoints retain the same signed proposal; `AnchorExamples.lean` supplies positive-value and substitution fixtures. Lean 4.35 builds and all nineteen selected standard-only anchor audits pass; see the shared record. Concrete block-body inclusion or a dedicated root coordinate, public bytes and cryptographic verification remain profile work. |
| Source geometry and existing semantic interfaces | The same decoded cellular cochain, its exactness residual, and operator-compatible transport to the legacy coherence interface. | `Sheaf/{Distance,CochainSemantics}.lean` supplies zero-distance/exactness and actual coboundary/decoder/binding joins; acceptance equivalence is derived under explicit ambient coherence. `Storage/Calibration.lean` derives a scaled source-to-pair comparison from controlled exact lifts. A selected codec/lift profile remains open; no metric is supplied by storage roots. |
| Ephemeral presentation lifecycle | Base/public handle, fresh representative handle, private path/transport evidence interface, active/consumed/retired state, rotation authorization, and no double consumption. | `Protocol/Ephemeral.lean` is an attachment point; the path mathematics remains in the Paper 1/shared layer. |
| Account/topology update, if selected | Authorization for registration, bilateral connection changes, presentation replacement, and preservation of the well-formed topology/sheaf context. | Do not port `account.py`; define this only after choosing the public account/presentation model. |
| Bonding and slashing, if consensus-critical | Exact bonded balances, eligibility, unbond delay, authenticated equivocation/fault evidence, conservative slashing destination, and preservation theorems. | Conditional Paper 2 module. Preserve the `Vault` vocabulary only if validator selection actually depends on it. |
| Coregulator transition, if consensus-critical | Typed observation, deterministic proposal/update relation, admissibility, delay/hold behavior, and any proved stability property. | `Protocol/Coregulator.lean` is an attachment point. Python economic agents are not its semantics. |

### Lean interfaces with Rust witnesses

Lean should name these predicates and prove consequences from them, while Rust
produces/checks the concrete witnesses:

| Interface | Lean states | Rust realizes |
|---|---|---|
| Root/hash binding | Which complete semantic object a digest binds and which roots must agree. | Canonical bounded bytes, domain separation, SHA-256/Merkle implementation, inclusion checks. |
| Authentication | The exact message/target authorized by a signer and the consequences of a verified signature. | Key formats, signature algorithm, verification, malformed-input rejection. |
| Nullifier security | Authorized derivation/linkability/uniqueness obligations and the state-machine consequences of freshness. | Concrete PRF/commitment/proof construction and constant-time verification. |
| Proof/oracle soundness | The public statement implied by successful verification and its state/evidence context. | Transcript parsing, proof backend, worker signatures, endpoint policy. |
| Atomic application | One accepted transition changes all semantic coordinates together or none. | RocksDB transaction/write batch, locking, fsync, crash recovery, reorg journal. |
| Checkpoint persistence | A receipt refers to the exact sealed context, ordered payload/digest list and manifest root; local consumption requires that receipt. | Durable writes, authenticated loads, atomic checkpoint/seal/cleanup and receipt verification for the selected backend. |
| Random/leader selection | Distribution-independent eligibility relation and safety consequences of a valid selection witness. | CSPRNG/VRF implementation, key custody, canonical input bytes. |
| Secret lifecycle | Fresh/active/consumed/retired semantics and non-reuse consequences. | Secure randomness, AEAD wallet storage, zeroization and memory policy. |

### Rust-only concrete objects

Rust, not Lean, owns transaction/block byte structs, serialization versions,
hash and signature implementations, proof-system libraries, wallet file
formats, RocksDB column families and indexes, network messages, mempool
eviction/rate limits, clocks, concurrency, allocation limits, and physical
secret erasure. Lean may state the required properties of these mechanisms but
should not mirror their implementation layout.

### Objects not admitted to the Lean chain kernel

Do not formalize the following merely because legacy Python used them:

- spectral fingerprint as identity or homotopy classifier;
- the current eigenvalue- or path-derived key images;
- balance tables called global sections;
- blocks called cellular-sheaf sections;
- cumulative spectral gap as fork choice;
- the existing quadratic split calculation as a Sybil-resistance theorem;
- local floating reputation, CLMM, treasury, hedge, or stabilizer policy; or
- Grassmannian distance relabeled as economic loss or consensus truth.

Likewise, do not persist `TCB.HCPObservation.BoundHCPObservation` itself. It is
a private witness-side join containing the harmonic message/opening. The chain
binds only its bounded public projection, artifact digest, snapshot root, and
typed transition evidence.

If an economic mechanism is eventually selected and becomes
consensus-determinative, formalize its exact state transition and invariant at
that time. Untrusted strategy code should only propose a typed
`CandidateTransition`; it must never define validity.

### Lean file migration target

The implemented leaf split, followed by the still-planned extensions, is:

```text
Protocol/
  Ledger/
    ValueFlow.lean    # implemented finite conservative resource flow
    Nullifier.lean    # implemented body-list freshness/consumption
    State.lean       # implemented typed state and snapshot interface
    Transition.lean  # implemented candidate, Valid, update, Execution
    Sheaf.lean       # adapter to existing payload/snapshot interpretation
    Certified.lean   # same-proposal acceptance quorum attachment
  Evidence/
    Transition.lean  # existing TCB envelope joined to actual candidate
  Chain/             # planned batched chain objects
    Transaction.lean
    Block.lean
    CertifiedBlock.lean
  Storage/
    Context.lean     # original interpretation/snapshot/artifact; raw vs accepted
    Checkpoint.lean  # typed leaves, append/seal/receipt/consume lifecycle
    Projection.lean  # exact nested projection/gate prefixes and coherent seal
    Anchor.lean      # same candidate/context/artifact/exact manifest in history
    ProjectionAnchor.lean # final prefix and actual gate database under that entry
    AnchorExamples.lean   # positive transfer and substitution fixtures; Lean 4.35 validated
    Calibration.lean # controlled exact lifts prove decoded-source comparison
    HCP.lean         # reuse the original bound HCP exact-component artifact
    CanonicalRS.lean # optional actual-public-observation and metric join
    Core.lean        # focused mathematical storage aggregate
  Consensus/
    Committee.lean
    Vote.lean
    Quorum.lean
    Round.lean       # planned
    Lock.lean        # planned
    Finality.lean    # planned
```

`Protocol/Ledger.lean` retains `Chain.lean` as a compatibility import; no old
type or caller has automatically migrated. Useful freshness/monotonicity
invariants are represented in the new typed kernel. `Chain.lean`'s spectral validator identity,
cumulative-gap fork choice, scalar edge-sum balance predicate, and quadratic
split policy are not dependencies of the new kernel. Its current
`block_extends` accepts a separately supplied tip hash, `tx_compose` adds
nullifiers and truncating `zipWith` payloads, and `zero_tx_n` supplies a zero
topology tag; none of those operations should survive as chain semantics.

The storage layer imports the mathematical owners rather than duplicating
them: `Sheaf/Distance.lean` owns decoded distance to exactness,
`Sheaf/CochainSemantics.lean` owns the operator/decoder/snapshot transport, and
`Sheaf/ObservationQuotient.lean` owns the distinct full-HCP observation
obstruction. `Storage/CanonicalRS.lean` is optional; its `BridgeData` bounds
stay explicit and its public observation is joined by the full original
artifact, with no equality forced between its leaf, snapshot and storage roots.

## Lean Workspace Layout

Keep one `lean/` workspace. Introduce a one-way protocol dependency layer:

```text
lean/
  Axioms/          shared mathematical interfaces
  Laplacian/       core Hodge/Grassmannian mathematics
  Proximity/       core projection mathematics
  TCB/             shared public-artifact boundaries
  Protocol/        Paper 2 protocol specifications and proofs
  Protocol.lean    current aggregate import for Protocol
  Paper1.lean      proposed aggregate import for the Paper 1 theorem surface
  Paper2.lean      proposed import of Paper1 plus Protocol
```

Core mathematics must not import `Protocol`. Protocol modules may import the
core mathematics and shared public-artifact boundaries. The proposed
`Paper1.lean` and `Paper2.lean` aggregate files do not yet exist.

## Status Vocabulary

Track three independent axes:

- **Lean coverage:** Unmapped / Interface-only / Specified / Proved /
  Runtime-refined.
- **Semantic verdict:** Preserve / Preserve after rename / Partial / Conflicts
  with canonical model / Rejected.
- **Disposition:** Active implementation / Active reference / Test oracle /
  Quarantine / Deprecation candidate / Archived / Deleted.

“Implemented” may be recorded as runtime evidence, but it is not a substitute
for a Lean refinement theorem. Likewise, an old semantic claim may be rejected
without creating a Lean version of the mistake.

## Priority 1 — Ephemeral Representative And Anonymity Flow

1. **Paper 1 mathematical family**
   - **Finite core now constructed:** [HCP.AxisFamily](../lean/HCP/AxisFamily.lean)
     supplies actual integral cellular sheaves and a proved homological-test
     semantic realization, shared `(class,b)` observations, positive/negative
     CVP comparisons, and a weighted exact integer-recovery counterexample.
     This supplies a concrete seed example for the argument; it does not yet
     construct the indexed ephemeral generation/transport/lifecycle below.
   - **Current state:** Lean contains only the supplied abstract path
     `EphemeralFiberSpec.path`. `EphemeralRepresentativeSpec`, the indexed
     family, concrete generation, and the lifecycle state machine do not yet
     exist; `Protocol/Ephemeral.lean` is currently an import-only attachment
     point.
   - Rename the conceptual object to `EphemeralRepresentativeSpec`; keep
     `EphemeralFiberSpec` as a compatibility alias while references migrate.
   - The generated endpoint is the ephemeral hidden representative. Its path
     from the base is the class-membership witness.
   - Add an indexed `EphemeralRepresentativeFamily`, connect the path to
     `FiberSystem.transport`, and prove that an injective infinite family is an
     infinite subset of one public classifier fiber.
   - Do not call this a random cochain candidate. A committed cochain is
     downstream of the representative's sheaf/cochain geometry.

2. **Paper 2 generation and consumption state machine**
   - Specify generation, active, consumed, and retired states in Lean.
   - Define freshness, single-use, replay exclusion, and key-image/nullifier
     linkage as typed transition predicates.
   - Prove that accepted transitions cannot consume one ephemeral handle
     twice.
   - Leave CSPRNG calls, secret bytes, constant-time behavior, and memory
     zeroization to Rust realization obligations.

3. **Anonymity/security game**
   - State the finite-family/asymptotic sampling game used to interpret
     anonymity; do not treat `1/∞ = 0` as a literal uniform distribution.
   - Connect the protocol-relevant classifier fiber to the infinite
     Grassmannian/Laplacian family under explicit compatibility hypotheses.

## Priority 2 — Proximity Evidence And Sheaf Storage

4. **Original context and typed projection checkpoints**
   - The three visibility levels are inherited from Paper 1 Section 5:
     private Hodge/presentation data, public residue payload/modulus/count/tag,
     and selective opening/proof disclosure. Paper 2 owns concrete bytes,
     access, storage and recipient key delivery. The chosen mathematical
     example grants `(class,b)`; the new TCB adapters keep any richer
     snapshot/artifact view subject to explicit profile conditions.
   - **Mathematical source implemented:** `Storage.Context` retains the actual
     `CochainPayloadInterpretation`, snapshot and public artifact. Its key
     derives the run ID, schema version, snapshot root, cochain leaf digest,
     topology tag and parameter-set ID. A raw snapshot-bound context does not
     assert decoded exactness; `Context.Accepted` is a separate predicate.
     This keeps noisy/invalid inputs available to a proximity test.
   - `Sheaf.CochainSemantics` identifies the existing carriers and intertwines
     their actual coboundaries, decoder and snapshot-binding predicates.
     Exactness, cocyclehood and acceptance transport are derived; remaining
     legacy ambient-coherence gates are explicit inputs. No norm preservation
     is inferred from a carrier equivalence.
   - `Storage.Projection.Prefix` follows the existing typed order
     `PluckerCochainState -> CochainPlaneState -> StateBus`, then hard gates,
     assembled-projection naturality and final far-region evidence. Each step
     retains its actual certified predecessor. Its manifest items contain
     those exact typed payloads and supplied digests, with distinct slots.
   - `OpenManifest.append` requires a fresh slot and preserves prior entries.
     Turning a projection prefix into a manifest requires the selected
     scheme's authentication relation for each actual context/slot/payload.
     Runtime advance-plus-append atomicity and concrete verification remain
     separate refinement work.
   - Run IDs are supplied. An empty manifest can be initialized again; the
     local lifecycle does not establish global run freshness or prevent
     cloning across independently initialized histories. Select those
     authorization/replay rules before claiming global one-use storage.

5. **Seal, obtain a matching persistence receipt, then consume**
   - **Mathematical source implemented:** `SealedManifest` fixes one complete
     append-once manifest and its supplied root-binding proof. A
     `PersistenceReceipt` is indexed by that exact sealed context, ordered
     item list and root. Local `Checkpoint.Step` permits consumption only
     with such a receipt; a consumed checkpoint is terminal throughout every
     connected execution. Sealing alone does not assert durable storage.
   - `SealedProjection` identifies the manifest's exact item list with one
     final nested projection/gate prefix. It recovers the existing final
     certificate and retains the original cochain/received-word identities.
     Its far theorem consumes the supplied mathematical far-region witness;
     a storage root does not prove that witness.
   - **Concrete profile still required:** give the sealed public encoding one
     canonical SHA-256 content address, for example the planned
     `SHA256("HCRYPT:SHEAF-BLOCK:v1" || canonical_manifest_bytes)`.
     The manifest's child coordinates must include the
     `SheafStateSnapshot` root, original cochain leaf digest, Plucker-shadow
     digest, plane view, canonical RS derivation/received-target binding,
     evidence root, parameter-set ID, and schema version.
   - The existing `GateEvidence.EvidenceDatabase.rootDigest` is the
     certificate/evidence subtree root, not the whole-block address. The
     selected public profile must authenticate the stage-artifact and evidence
     subtrees through the final manifest. `ProjectionAnchor.gateIncluded`
     separately names the actual gate database under the candidate's evidence
     root; that enclosing root may also authenticate other evidence.
   - “One surface hash” means that the final SHA-256 address authenticates the
     distinct child digests. Do not set the snapshot, cochain, Plucker, plane,
     RS, and evidence digests equal to one another.
   - **Mathematical source join implemented; Lean 4.35 validation passed:**
     `Storage.ProjectionAnchor` uses the existing `SealedProjection` and
     `TransitionAnchor` to identify the accepted action's payload with the
     stored cochain, plane-derived RS word and exact final typed prefix. Its
     gate inclusion relation takes the actual evidence database, candidate
     and evidence root. Instantiate these authentication relations with the
     concrete encoding/hash/proof scheme. If a derived object is not persisted,
     bind the canonical derivation and all inputs needed to reproduce it.
   - **Backend work remains:** persist and seal the immutable block in
     content-addressed storage, verify
     the hash again on load, and wipe the volatile `SheafState` only after the
     final checkpoint and seal commit atomically. Failed/incomplete blocks are
     recoverable construction records but are not eligible for anchoring.
   - Keep the base/master presentation, ephemeral representative, private
     path, opening, and transported secret state off the public chain. The
     manifest may carry only opaque public handles or ciphertext digests for
     those private objects.
   - `Storage.HCP` reuses the accepted exact-component artifact of the existing
     `BoundHCPObservation`; its decoded exactness residual is zero. The full
     encrypted observation remains a separate object. With a nonzero coexact
     direction, `Sheaf.ObservationQuotient` proves that the full
     kernel-normalized Hodge residual can grow without changing the exact
     component, excluding an unrestricted positive far-region theorem for an
     extraction that sees only that component and sends zero to distance zero.
     The ray lives in the existing unrestricted `HodgeEncryptedCochain`
     carrier. Authenticated or noise-bounded profiles require their own stated
     comparison.
   - `Storage.Calibration.LiftControl` provides a constructive local criterion:
     exact target-codeword lifts with decoder-error bounds imply the scaled
     decoded-cochain-to-pair comparison. The optional canonical adapter joins
     the existing public observation by the same artifact and identifies its
     legacy real-infimum distance with the attained generic minimum. Actual
     codec/layout/lift construction and any fixed-challenge goodness proof
     remain profile work.

6. **Main-chain anchor**
   - Specify eligibility separately from storage completion. A raw
     snapshot-bound diagnostic checkpoint can be complete and persisted
     without an accepted exact payload. A seal or persistence receipt alone
     is not a ledger-acceptance certificate.
   - **Mathematical source implemented; Lean 4.35 validation passed:** `Storage.TransitionAnchor` joins the existing candidate evidence
     to the exact payload interpretation, original public artifact and sealed
     manifest. It derives accepted exactness, the candidate/context payload and
     snapshot identities, and the existing cochain/evidence-root inclusions.
     A matching quorum names that same snapshot and the block digest
     authenticating the manifest. Persistence still requires its own receipt.
   - `HistoryBindings.manifestIncluded` names the actual candidate, context,
     ordered item list, manifest root and block digest. The wire choice remains
     open: authenticate the manifest through the block body under its existing
     digest, or select a dedicated `sheafBlockRoot : Hash32` coordinate with
     matching authentication. The generic join supports either choice; it
     does not require adding a field or identify the two digests. Specify the
     canonical preimage order, domain separation and inclusion verification.
   - `Storage.AnchorExamples` joins the existing concrete sheaf fixture and
     sealed receipt to a positive conservative transfer and matching quorum.
     It rejects a substituted run or snapshot and a persisted nonexact input.
     These equality-based authentication/backend fixtures pass the Lean 4.35
     build and selected standard-only audits; production cryptography and disk
     durability remain open.
   - The chain stores this bounded root/handle, not the private path,
     ephemeral representative, transported secret state, full artifact stack,
     or evidence database.
   - Specify replay, reorganization, retention, and garbage-collection
     behavior before production implementation.
   - These adapters fix the original cell complex `X` and cellular sheaf `F`.
     Authorized changes of topology, stalks or restriction maps and their
     snapshot/geometry migration are not implemented. Anchoring changes
     neither the open Q08 source-metric/far-image profile nor its hypotheses.

## Priority 3 — Consensus, Ledger, And Coregulator

7. **Consensus specification burn-down**
   - `Axioms.Consensus` currently contains proposition-only assumptions.
   - Define typed candidate/block inputs, eligibility, selection, acceptance,
     and transition relations under `Protocol/Consensus`.
   - Retain the proved arithmetic/scoring lemmas in `Consensus/*`, but do not
     present them as an end-to-end consensus proof.
   - **Initial quorum kernel proved:**
     `Protocol/Consensus/Committee.lean` defines registered positive integral
     voting weights and the division-free strict threshold
     `2 * totalWeight < 3 * supportWeight`;
     `Protocol/Consensus/Vote.lean` binds authenticated votes to committee,
     epoch, height, round, phase, block/parent, state, snapshot, topology, cochain,
     evidence roots, and the collapsed Heyting judgment; and
     `Protocol/Consensus/Quorum.lean` prevents duplicate signer weight and
     proves weighted quorum intersection. Under faulty weight below one third
     and a non-faulty no-double-vote premise, two certificates have the same
     target.
   - **Candidate attachment implemented:** `Ledger.CertifiedTransition` joins
     that quorum's exact proposal and acceptance judgment to candidate-indexed
     TCB evidence. Hold/rejection cannot furnish its acceptance certificate.
     Focused builds pass; theorem dependencies are tracked in the shared
     validation record. The adapter does not establish finality.
   - **Still pending:** round/phase transitions, locking/unlocking rules,
     proposal selection, equivocation evidence, finality promotion, liveness,
     and a Rust refinement theorem. A quorum certificate is therefore not yet
     presented as a complete consensus or finality proof.

8. **Ledger and key-image state**
   - **Implemented bounded kernel:** `State`, `Action`, `Candidate`, `Policy`,
     computed `after`, `Valid`, `AcceptedUpdate` and connected `Execution`
     under `Protocol/Ledger`. The proof endpoints give exact conservative
     value preservation, spent-set monotonicity and same-action replay
     exclusion. Focused builds pass; see the shared validation record for
     aggregate and theorem-dependency outcomes.
   - `Ledger.Sheaf` supplies `SnapshotModel.ofSheaf` over the existing
     `CochainPayloadInterpretation F`, retaining its actual root, accepted
     exact payload and decoded cocycle consequences. Its 16-byte topology
     tag is not identified with the separately bound 32-byte topology root.
   - `Evidence.Transition` binds the same candidate, payload and public hashed artifact
     through object-indexed state-root, transition-digest and inclusion
     relations. Root/hash/byte verification is not derived from those names.
     Evidence-root inclusion of the full serialized proof/verifier metadata
     remains open. The concrete root scheme must specify an acyclic preimage
     order for block digest and successor state/roots; the legacy Rust header
     does not instantiate this new proposal profile.
   - **Still pending:** concrete authorization/resource/value interpretation,
     nullifier derivation and ephemeral linkage, security games, runtime
     realization, storage backend/global-run policy, and any batched block/reorganization
     model. Legacy `Chain` callers remain compatibility consumers.
   - This full protocol work is not a prerequisite for Paper 3's bounded
     commitment/projection radius analysis.

9. **Coregulator model**
   - `Axioms.Coregulator` currently names four proposition-only obligations.
   - Define typed predict/observe/update state, determinism, monotonic delay
     policy, and the stability/convergence claims actually required by Paper
     2.
   - Numerical estimation and floating/fixed-point realization remain Rust
     concerns, with explicit error/refinement bounds.

## Priority 4 — Folder Migration

10. **Create protocol import surfaces**
    - `Protocol.lean` exists and imports the new bounded kernel and evidence
      leaves through its aggregates. `Paper1.lean` and `Paper2.lean` remain
      proposed publication import surfaces.
    - Move protocol-only modules incrementally, using temporary re-export
      shims so file movement is reviewable separately from theorem changes.
    - Split mixed modules rather than moving them wholesale. In particular:
      - path/class/transport mathematics stays outside `Protocol`;
      - ephemeral lifecycle moves under `Protocol`;
      - proximity mathematics stays in `Proximity`;
      - mutable evidence storage/finalization moves under `Protocol`.

## Priority 5 — Legacy Rust/Python Inventory

11. **Read-only deprecation map before deletion**
    - Audit in dependency order: `primitives`, `invariants`, `proofs`,
      `geometry`, `crypto`, `chain`, `network`, `consensus`, then `oracle`.
      Finish classification of one layer before treating the next layer as
      authoritative.
    - Inventory older Python and Rust files without changing production paths.
    - Classify each as **current implementation**, **reference prototype**,
      **test oracle**, **superseded/archive candidate**, or **unknown pending
      protocol contract**.
    - For every deprecation candidate, record the surviving Lean contract,
      Rust replacement, tests/fixtures worth preserving, and documentation
      references that must move.
    - Do not delete or archive a file merely because it predates the current
      architecture; wait until its behavior is represented by the new Lean
      protocol contract or intentionally rejected.

    Record each exported object with: source file and symbol, active importers,
    claimed semantics, canonical Lean owner, Lean coverage, semantic verdict,
    runtime owner/replacement, tests or fixtures to preserve, paper scope,
    disposition, blocker, and replacement commit. Coverage, semantic validity,
    and file disposition are separate axes; one “done” badge is insufficient.

    A file may be archived only when:
    1. every exported symbol and active importer is inventoried;
    2. every semantic claim is preserved, corrected, or explicitly rejected;
    3. preserved mathematics has a Lean owner or explicit runtime-only contract;
    4. production behavior has a Rust replacement or is declared unnecessary;
    5. useful fixtures/tests are migrated and parity baselines pass;
    6. active papers/docs point to canonical owners;
    7. no active import remains except a documented compatibility shim; and
    8. the Lean, Rust, and Python checkpoint builds pass.

    Deletion additionally requires no compatibility consumer, a recoverable
    archive/provenance copy or git checkpoint, and a separate revertible cleanup
    commit. Archived source must carry a non-normative header naming its
    replacement and any rejected claims.

    **Legacy Python retirement exception (2026-07-23).** The owner explicitly
    suspended the Python runtime track while Lean remains canonical and the
    protocol/runtime implementation is redesigned. Consequently,
    `src/primitives/` and `src/invariants/` were archived intact at
    `docs/archive/python/src/` after their semantic audit, despite known active
    imports in the remaining legacy Python tree. This is a whole-track
    retirement, not a claim that each importer was migrated or that Python
    checkpoints pass after the move. Any future restoration must satisfy the
    normal refinement and checkpoint rules above.

12. **Deprecation execution checkpoint**
    - Perform moves/deletions only after a clean Lean protocol checkpoint and
      passing Rust/Python test baselines.
    - Keep deprecation changes separate from mathematical theorem changes and
      from protocol-state refactors so each can be reverted independently.
