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

The first transition kernel should be parameterized over identifiers, assets,
nullifiers, and action payloads. It need not prematurely choose an
account-based or UTXO-style concrete ledger, and no legacy Python container
gets to make that choice implicitly.

### Must be typed or proved in Lean

| Chain object | Lean-owned content | Current status / target owner |
|---|---|---|
| Committed public state | The semantic coordinates named by one state root: ledger/nullifier state, topology and accepted-cochain context, finalized artifact/evidence roots, and protocol epoch. The concrete root remains abstract. | `TCB.WitnessVerifier.PublicStateUpdate` contains only a preliminary before/after-root envelope. Define the real state under `Protocol/Ledger`. |
| Candidate transition | Typed proposed action, explicit before/after state, transition digest, public statement/evidence references, and the relation saying the proposed after-state follows from the before-state. | Missing. Define before concrete transaction/block acceptance so all later gates share one target. |
| Typed transition evidence | Evidence indexed by the actual candidate-transition validity proposition, with explicit equality between its database/artifact roots and the roots named by that candidate. | Existing proof/evidence envelopes can carry unrelated propositions unless joined by application-specific fields. Add the typed join under `Protocol/Evidence`. |
| Accepted transaction | Authorization fact, replay/nonce/nullifier freshness, exact value-flow validity, accepted exact \(C^1\) and snapshot binding where required, evidence binding, and the resulting state transition. | `Chain.TransactionAccepted` is too weak. Replace under `Protocol/Ledger`; do not translate `HomotopyTransaction` verbatim. |
| Nullifier state | Abstract nullifier type, authorization/derivation relation, prior freshness, duplicate-free batch use, monotone insertion, single consumption, and explicit rollback/reorganization semantics. | Only freshness and monotonicity over `Nat` exist in `Chain.lean`. Add `Protocol/Ledger/Nullifier.lean`. |
| Exact ledger flow | Exact asset quantities, nonnegativity, conservation or explicitly authorized mint/burn, fee destination, and atomic multi-input/multi-output application. | `Axioms.Ledger` is proposition-only and `Chain.balance_preserved` is not an asset conservation theorem. Add typed state and preservation theorems. |
| Block body and proposal binding | Ordered batch of candidate/accepted transitions; parent, height, epoch and round; before/after roots; snapshot/topology/cochain/evidence roots; and a theorem that the semantic block binds the complete `ProposalRef`. | `Protocol.Consensus.Vote.ProposalRef` has most of the root tuple but no actual block/body object and no distinct `snapshotRoot`. Add that coordinate and `Protocol/Chain/Block.lean`; do not identify it with `topologyRoot`. |
| Certified block / chain extension | A block plus an acceptance quorum certificate for exactly its proposal and `Valid` judgment; extension/application relation; no `Hold` or `Invalid` finalization. | Quorum arithmetic is proved, but the certificate-to-block and block-to-ledger bridges are missing. |
| Consensus rounds and finality | Phase/round transitions, locks and unlock conditions, non-faulty no-double-vote invariant, equivocation evidence, finality promotion, and agreement/safety theorems. | `Committee`, `Vote`, and `Quorum` provide the initial kernel. Add round/lock/finality modules under `Protocol/Consensus`. |
| Oracle judgment lifecycle | Authenticated judgment target, `Undetermined -> Hold`, retry/re-projection transition, and the conditions for a later `Valid` or `Invalid` result. | `Protocol/Oracle.lean` is an attachment point. Concrete signatures and endpoints remain Rust-owned. |
| `SheafState` lifecycle | Fresh initialization from one accepted exact \(C^1\)/snapshot context, typed stage advancement, no cross-commit certificate reuse, final consumption, and abstract wipe/retirement state. | Planned under `Protocol/Storage`; the mathematical projection-stage bus already exists in `Proximity/Gates`. |
| Open/sealed `SheafBlock` | Typed manifest leaves, one common context, slot-at-most-once construction, final evidence completeness, immutable sealing, and the relation binding a sealed manifest to its public root. | Missing. Add `Protocol/Storage/SheafBlock.lean`; concrete SHA-256 and canonical manifest bytes remain Rust-owned. |
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

The minimum non-circular split is:

```text
Protocol/
  Ledger/
    State.lean
    Nullifier.lean
    Transition.lean
  Chain/
    Transaction.lean
    Block.lean
    CertifiedBlock.lean
  Storage/
    SheafBlock.lean
    Lifecycle.lean
  Consensus/
    Committee.lean
    Vote.lean
    Quorum.lean
    Round.lean
    Lock.lean
    Finality.lean
```

`Chain.lean` should become a temporary compatibility surface while its useful
freshness/monotonicity lemmas migrate. Its spectral validator identity,
cumulative-gap fork choice, scalar edge-sum balance predicate, and quadratic
split policy are not dependencies of the new kernel. Its current
`block_extends` accepts a separately supplied tip hash, `tx_compose` adds
nullifiers and truncating `zipWith` payloads, and `zero_tx_n` supplies a zero
topology tag; none of those operations should survive as chain semantics.

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

4. **Volatile per-commit `SheafState` and open `SheafBlock`**
   - After the exact cochain has been accepted, initialize one fresh active
     `SheafState` and one empty/open `SheafBlock` for that
     commitment/witness. Both are bound to the same fixed context. The cochain
     commitment precedes the projection chain; the first projection stage
     consumes it rather than recommitting or rederiving it.
   - Bind the active state to the exact-cochain commitment hash, canonical
     `SheafStateSnapshot` root, topology metadata, projection/parameter-set ID,
     and evidence schema version.
   - Follow the existing typed order:
     `PluckerCochainState -> CochainPlaneState -> StateBus`, followed by hard
     gates, assembled-projection naturality, and final far-region evidence.
   - At each checkpoint, advance the volatile bus and atomically append that
     stage's public artifact and certificate to the open block. A transition
     may fill its own stage-labelled slot once; it may neither overwrite an
     earlier slot nor borrow a slot from another cochain's state.
   - Each stage checks its own restriction and syndrome naturality equations
     once; later stages consume the certified predecessor. Runtime persistence
     records the existing certificate rather than rerunning the mathematical
     gate.

5. **Seal the completed `SheafBlock`, then wipe `SheafState`**
   - The open block is a persistent checkpoint construction and is not yet a
     full/anchorable block. Once every required stage is present, seal it as
     one immutable block containing the accepted cochain context, projection
     artifacts, calibrated final certificate, and `GateEvidence` database.
   - Give the sealed block one canonical SHA-256 content address:
     `SHA256("HCRYPT:SHEAF-BLOCK:v1" || canonical_manifest_bytes)`.
     The manifest's child coordinates must include the
     `SheafStateSnapshot` root, accepted exact-cochain digest, Plucker-shadow
     digest, plane view, canonical RS derivation/received-target binding,
     evidence root, parameter-set ID, and schema version.
   - The existing `GateEvidence.EvidenceDatabase.rootDigest` is the
     certificate/evidence subtree root, not the whole-block address. The
     stage-artifact subtree and evidence subtree are both authenticated by the
     final block manifest.
   - “One surface hash” means that the final SHA-256 address authenticates the
     distinct child digests. Do not set the snapshot, cochain, Plucker, plane,
     RS, and evidence digests equal to one another.
   - Prove that the finalized evidence root refers to the same exact cochain
     and `SheafStateSnapshot` as the stored Plucker shadow, plane view, and RS
     derivation. If a derived object is not persisted, bind the canonical
     derivation and all inputs needed to reproduce it.
   - Persist and seal the immutable block in content-addressed storage, verify
     the hash again on load, and wipe the volatile `SheafState` only after the
     final checkpoint and seal commit atomically. Failed/incomplete blocks are
     recoverable construction records but are not eligible for anchoring.
   - Keep the base/master presentation, ephemeral representative, private
     path, opening, and transported secret state off the public chain. The
     manifest may carry only opaque public handles or ciphertext digests for
     those private objects.

6. **Main-chain anchor**
   - Extend the Paper 2 transaction/state model with the finalized
     `sheafBlockRoot : Hash32`. This SHA-256 address resolves to and
     reauthenticates the entire immutable block.
   - The chain stores this bounded root/handle, not the private path,
     ephemeral representative, transported secret state, full artifact stack,
     or evidence database.
   - Specify replay, reorganization, retention, and garbage-collection
     behavior before production implementation.

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
     epoch, height, round, phase, block/parent, state, topology, cochain,
     evidence roots, and the collapsed Heyting judgment; and
     `Protocol/Consensus/Quorum.lean` prevents duplicate signer weight and
     proves weighted quorum intersection. Under faulty weight below one third
     and a non-faulty no-double-vote premise, two certificates have the same
     target.
   - **Still pending:** round/phase transitions, locking/unlocking rules,
     proposal selection, equivocation evidence, finality promotion, liveness,
     and a Rust refinement theorem. A quorum certificate is therefore not yet
     presented as a complete consensus or finality proof.

8. **Ledger and key-image state**
   - Move/refine the abstract `Chain.lean` state transitions under
     `Protocol/Ledger` and `Protocol/Chain`.
   - Tie key-image freshness to the ephemeral consumption state and prove
     monotonic spent-set/no-double-consumption results.
   - Add commitment/evidence-root coherence to transaction and block
     acceptance.

9. **Coregulator model**
   - `Axioms.Coregulator` currently names four proposition-only obligations.
   - Define typed predict/observe/update state, determinism, monotonic delay
     policy, and the stability/convergence claims actually required by Paper
     2.
   - Numerical estimation and floating/fixed-point realization remain Rust
     concerns, with explicit error/refinement bounds.

## Priority 4 — Folder Migration

10. **Create protocol import surfaces**
    - Add `Protocol.lean`, `Paper1.lean`, and `Paper2.lean` aggregate imports.
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
