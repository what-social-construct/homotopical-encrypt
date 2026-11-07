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

Preserved source baseline (2026-11-05): the first **bounded conservative
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
For that preserved baseline, all nineteen selected anchor endpoints pass
dependency audits with exactly `propext`, `Classical.choice` and `Quot.sound`.
Across its three audit groups, all 68 distinct reports pass: 64 standard-only and the same
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

The subsequent bounded owned-resource profile is now defined in
[Ledger.OwnedResource](../lean/Protocol/Ledger/OwnedResource.lean),
[Transfer.Owned](../lean/Protocol/Transfer/Owned.lean) and
[Transfer.Anchored](../lean/Protocol/Transfer/Anchored.lean). It derives the
actual one-input/one-output action and public input-ID nullifier, checks the
exact typed intent/metadata/signature/proof packet independently of candidate
validity, then joins the same candidate, artifact, trusted interpretation and
one-input manifest to its computed accepted update. A matching acceptance
quorum is an additional input for final proposal certification. Current
source/build/dependency evidence is in the central validation record; the
older counts above remain dated baselines. Production wire/hash/signature/proof
implementations, state-origin security, runtime refinement and finality remain
separate from this conditional specification.

The integrity follow-up separates the actual algorithms in
[Evidence.TransferCheck](../lean/Protocol/Evidence/TransferCheck.lean) and
[Transfer.Operational](../lean/Protocol/Transfer/Operational.lean) from the
exact profile's universal soundness contracts.
[Transfer.PublicView](../lean/Protocol/Transfer/PublicView.lean) retains the
actual packet bytes, parsed packet, complete proposal and original input
manifest. [Transfer.Security](../lean/Protocol/Transfer/Security.lean) defines
a fixed-setup one-shot sampled experiment over this declared release and
explicit auxiliary information. Actual bad acceptance entails an
authorization or payload failure on the same attempted packet, so supplied
failure budgets compose without independence. This is no primitive error
estimate or adaptive cryptographic security theorem; signing/proving queries,
corruption, security parameters, public setup/prior-state/catalog access,
network metadata and full-view privacy still need their own specification.

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
with fees included among produced resources. The selected bounded profile
now fixes an immutable catalog of owner/asset/positive amount, consumes one
resource ID, creates a distinct absent and unspent ID of equal value, and
uses the input ID itself as its public nullifier. This choice is local to that
profile, not a global account/UTXO or anonymous-nullifier architecture.
Cryptographic authorization and exact-payload soundness remain indexed
primitive contracts. Mint/burn policies are outside this kernel.

### Must be typed or proved in Lean

| Chain object | Lean-owned content | Current status / target owner |
|---|---|---|
| Committed public state | Semantic resource/nullifier state and public context, with content roots distinguished from late tip/evidence coordinates. | `Ledger.State` remains the actual object. `TransferTranscript.StateContent` explicitly projects it; the original before-evidence root and parent tip are included in the intent, while late coordinates reconstruct the successor through its final proposal. Content hashing alone does not bind every state coordinate. Concrete byte/hash/state-origin security remains open. |
| Candidate transition | Action body, before-state, snapshot, complete proposal, computed successor, and a validity predicate for that exact candidate. | Implemented in `Protocol/Ledger/Transition.lean`: `after` applies the body's actual flow and nullifier list; `Valid` checks conservation, availability, freshness and context. The result is not an independently supplied after-state. |
| Typed transition evidence | Exact packet metadata, public intent, owner-signature/proof bytes and their selected verifier facts, before deriving candidate validity. | `Evidence.TransferVerifier` checks canonical packets and invokes indexed primitive verifiers. `Transfer.Owned` derives validity; `TransferEnvelope` packages the actual candidate/transfer witness, original artifact and public intent into the existing TCB. The generic statement-equality adapter is not itself new verifier soundness. |
| Released transfer record | Exact packet bytes, parsed packet, complete proposal and original one-input public manifest. | `Transfer.PublicView` projects this same checked release and proves canonical parsing, original context/intent/metadata/manifest coherence and actual consumed nullifier. Exposed resource/signer IDs and metadata can distinguish releases. This is not the entire network transcript or a hiding theorem. |
| One-shot integrity experiment | Actual checker acceptance with invalid computed candidate, authorization/payload failure events, explicit observation/auxiliary input/random tape and error composition. | `Evidence.TransferCheck` and `Transfer.Operational` assume no universal primitive soundness. `Transfer.Security` reduces actual bad acceptance to the two same-attempt failures and composes supplied `PMF` error budgets, without independence; support-local ideal conditions give zero error. Primitive bounds, adaptive/oracle/corruption models and security parameters remain open. |
| Accepted transaction | Authorization, derived input-ID nullifier, fresh unit-resource flow, accepted original payload and computed application. | `Ledger.OwnedResource` and `Transfer.Owned` select a bounded positive-value profile and derive `AcceptedUpdate`, value/inventory preservation and replay/output-resurrection rejection. Cryptographic soundness and trusted state-origin/refinement remain explicit. Legacy `Chain.TransactionAccepted` is not silently migrated. |
| Nullifier state | Abstract identifiers, body-list binding, freshness, duplicate-free use, monotone consumption and replay exclusion. | Implemented in `Ledger/Nullifier.lean` and `Candidate.Valid`: nonempty/Nodup/Fresh are checked on the actual body list, which the update consumes. Replay with that same list is excluded even with new proposal metadata. Derivation/linkability security, ephemeral-handle linkage and reorganization semantics remain open. |
| Exact ledger flow | Finite nonnegative quantities, availability and conservative multi-resource application. | `Ledger/ValueFlow.lean` uses mathlib finite markings and an explicit additive asset valuation. Enabled conservative flow preserves value; connected `Execution` preserves value and spent-set monotonicity. Fees may be produced resources. Mint/burn and concrete resource/asset semantics remain open; edge sums are not the conservation theorem. |
| Block body and proposal binding | Ordered batch, proposal context and root coordinates, plus semantic block binding. | The one-action candidate/evidence join is implemented, and `ProposalRef` now has a distinct signed `snapshotRoot`. A batched block/body object and its binding remain future `Protocol/Chain/Block.lean` work. Snapshot root is not topology root. |
| Certified block / chain extension | Acceptance certificate for the exact proposal and `Valid` judgment, joined to application. | `Ledger/Certified.lean` now attaches quorum evidence to the same candidate proposal, derives accepted update, and excludes hold/rejection certificates. Batched certified blocks, round/lock discipline, finality and liveness remain open. |
| Consensus rounds and finality | Phase/round transitions, locks and unlock conditions, non-faulty no-double-vote invariant, equivocation evidence, finality promotion, and agreement/safety theorems. | `Committee`, `Vote`, and `Quorum` provide the initial kernel. Add round/lock/finality modules under `Protocol/Consensus`. |
| Oracle judgment lifecycle | Authenticated judgment target, `Undetermined -> Hold`, retry/re-projection transition, and the conditions for a later `Valid` or `Invalid` result. | `Protocol/Oracle.lean` is an attachment point. Concrete signatures and endpoints remain Rust-owned. |
| `SheafState` lifecycle | One fixed original sheaf interpretation, snapshot and artifact; typed projection/gate advancement and local receipt-indexed consumption. | Mathematical source under `Storage/{Context,Checkpoint,Projection}.lean` reuses the existing nested state bus. Raw snapshot-bound context is separate from `Context.Accepted`; noisy inputs remain available. Connected execution makes consumption terminal. Global run-ID freshness, replay policy across independent histories, backend atomicity and erasure remain open. |
| Open/sealed `SheafBlock` | Actual typed payload/digest leaves, one common context, slot-at-most-once append, required-slot completeness and an exact sealed list/root. | `Storage/Checkpoint.lean` supplies `OpenManifest`, `SealedManifest` and `PersistenceReceipt`; `Storage/Projection.lean` joins a seal to one final nested prefix. `Storage/Anchor.lean` supplies the mathematical history join under a selected inclusion relation. These modules pass the Lean 4.35 aggregate/integration build. Canonical public bytes, SHA-256/inclusion security and durable backend implementation remain open. |
| History entry to original storage | Same candidate, original interpretation/artifact, exact retained list/root and conditional matching final proposal/quorum. | `Transfer.Anchored` binds the selected one-input manifest and complete typed proof packet through staged intent/evidence/block inputs and reuses the existing `TransitionAnchor`. The generic six-stage `ProjectionAnchor` remains separate. Canonical codecs, hash security, backend persistence and finality are not inferred. |
| Source geometry and existing semantic interfaces | The same decoded cellular cochain, its exactness residual, and operator-compatible transport to the legacy coherence interface. | `Sheaf/{Distance,CochainSemantics}.lean` supplies zero-distance/exactness and actual coboundary/decoder/binding joins; acceptance equivalence is derived under explicit ambient coherence. `Storage/Calibration.lean` derives a scaled source-to-pair comparison from controlled exact lifts. A selected codec/lift profile remains open; no metric is supplied by storage roots. |
| Ephemeral presentation lifecycle | Actual integral/presented rotation, same-message recovery, original bound-sample migration and scoped recipient receipts are implemented. | Indexed fresh generation, active/consumed/retired states, authenticated delivery implementation and no double consumption remain open. The path interface remains in the shared layer and does not generate a rotation by itself. |
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

### Actual primitive comparison and TCB joins — 2026-11-07

The selected byte-verifier interface is now
[TCB.PrimitiveChecks](../lean/TCB/PrimitiveChecks.lean); the original-transfer
[primitive adapter](../lean/Protocol/Transfer/Primitives.lean) relates those
algorithms to the exact owner/intent and trusted payload interpretation through
explicit equality of their Boolean results. Matching algorithm names or public
hashes do not establish that equality. The following is a source comparison,
not a verified Rust refinement. Runtime paths name files in the full workspace;
the Lean/manuscript review bundle excludes runtime sources and `Cargo.lock`.

| Object | Actual inspected implementation | Required original-object join / result |
|---|---|---|
| Signature primitive | `Cargo.lock` pins `ed25519-dalek` 2.2.0. `rust/node/src/consensus/pov.rs::proof_signing_message` signs domain, fingerprint hash, gap flag and three Betti integers: 69 bytes. | A byte signature authenticates its selected message. The current message is a worker spectral target, not the owned transfer intent, its resource IDs, source state, manifest or whole final proposal. No owner-authorization instantiation is supplied by this path. |
| Owner signing key and query history | `SignatureProfile` supplies an actual owner-to-key map, owner/intent encoder, verifier-agreement equation and finite key/message query list. | History must cover every honest signature available in the selected release and auxiliary data. Key ownership, secrecy, generation, authentic registry and history/execution correspondence require their own model before applying a primitive-game bound. |
| Runtime key setup | `rust/node/src/main.rs` derives bootstrap signing seeds from the public producer fingerprint; the compatibility constructor in `pov.rs` treats supplied bytes as a signing seed. | That bootstrap cannot establish an uncompromised-secret-key premise. The Lean compromised-key event is explicit; the runtime has not been proved to populate it correctly. |
| Worker quorum / call path | `pov.rs` counts submitted signature entries and uses a threshold based on their count. The incoming-block path in `main.rs` does not call `PoVVerifier`; the self-produced path does. | Distinct authenticated committee members, whole-proposal signatures and mandatory verification do not follow. This does not instantiate the Lean weighted-quorum/finality interface. |
| Raw graph commitment | `rust/node/src/crypto/commitment.rs` computes ordinary incidence differences in edge-major/stalk-coordinate order. | [GraphCommitment](../lean/Sheaf/GraphCommitment.lean) proves global translation leaves the **existing full cochain payload** unchanged. At modulus 12289, `[3,5,9]` and `[10,12,16]` both give `[2,4]`. Raw vertex-message binding fails; deterministic serialization/hash of that same payload cannot restore it. |
| Scope of the graph comparison | The graph prototype has no arbitrary cellular restriction maps or harmonic blinding. A fixed topology tag depends on the graph, not the opening. | This matches the existing kernel-quotient opening interpretation. It does not refute authenticated binding of a `C¹` payload, identify the prototype with the general private sheaf, or establish any hiding theorem. |
| Commitment decoding | `commitment.rs::from_bytes` accepts absent topology bytes and trailing data. | It is not the exact canonical codec checked by `TransferCheck`. Canonical encoding, input bounds, interpretation and root binding remain separate implementation contracts. |
| Geodesic proof input | `rust/node/src/crypto/geodesic_zkp.rs` receives sampled matrices, target spectrum, topology tag and a strictness flag. | It has no original cochain, trusted decoder or owner intent. Its backend spectral statement has not been proved to imply `Context.Accepted`; this is the explicit `StatementMismatch` boundary. |
| Proof caller | `pov.rs::verify_transaction_zkps` skips malformed optional trailers and passes empty target spectrum with `strict=false`. No selected SNARK backend was identified in the inspected Cargo dependencies. | This does not refine the fail-closed transfer packet checker or the SNARK/zero-knowledge assumption bundle. Exact parsing, statement selection and verifier agreement must be supplied explicitly. |
| Sampling/error label | The proof supplies the opening count. The former `soundness_bits` name returns that count; it carries no proved cryptographic estimate. | Even ideal uniform sampling of `k` among `M` fixed commitments misses `b` bad entries with probability `choose(M-b,k)/choose(M,k)`: `M=16,b=1,k=8` gives `1/2`, rather than `2^-8`. Fiat–Shamir additionally requires a query/grinding model. |
| Python/Rust transcript parity | The Rust shuffle uses a custom 64-bit state and modulo selection; the Python prover uses NumPy PCG64. | A fixed public comparison on NumPy 2.0.2 gives opened sets `[3,5,6,7]` versus `[0,1,5,7]` for an independent translation of the Rust algorithm. The full inputs/source hashes are in local `output/validation/primitive-runtime-comparison.json`. This is a parity counterexample, not verified Rust execution. |
| Legacy TCB carrier | `ProofCarrying.WellFormed` contains the statement itself; runtime/observation/envelope consequences recover supplied semantic facts. | These carriers remain compatibility packaging after independent verification. They are not a theorem that a `Prop` label, signature or successful unindexed verifier establishes the original statement. |

The pinned [Ed25519 library documentation](https://docs.rs/ed25519-dalek/2.2.0/ed25519_dalek/)
exposes signing/verification of message bytes; [RFC 8032](https://www.rfc-editor.org/rfc/rfc8032.html)
specifies the EdDSA algorithm, not this protocol's authorization policy.
[NumPy's PCG64 documentation](https://numpy.org/doc/stable/reference/random/bit_generators/pcg64.html)
describes its 128-bit state construction, which differs from the prototype.
None of these sources supplies the missing protocol error estimate.

The proved same-attempt decomposition is

`AcceptedInvalid ⇒ Forgery ∨ CompromisedKey ∨ QueriedUnauthorized ∨ ProofFalseAccept ∨ StatementMismatch`.

Here a forgery is verified, on an uncompromised selected key, and unqueried in
that key/message history. A queried message can still authorize the wrong
intent through bad issuance policy, aliased keys or encoding/hash collisions.
A correct backend proof may certify a statement that fails to imply acceptance
of the original cochain under its actual interpretation. The shared-PMF union
bound composes these five probabilities without independence; every numerical
budget remains a premise for the same experiment. No global hash injectivity,
new primitive estimate, adaptive oracle, key-generation game, privacy,
state-origin, external-history authentication or runtime refinement is proved.

The exact interfaces from §6.2 remain an ideal specialization. Integrity here
requires the relevant semantic implication and error model, without adding
zero-knowledge or succinctness assumptions merely to fill the old proof carrier.

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
   - **Current state:** the supplied abstract `EphemeralFiberSpec.path` is
     retained. `Sheaf.Rotation` and `Protocol.Ephemeral` now provide actual
     integral/presented rotation, both recipient recovery routes, original
     bound-HCP sample/payload joins and scoped delivery receipts. The actual
     axis swap preserves every integer coefficient. `EphemeralRotation`
     joins supplied path endpoints to actual rotation data; it does not
     derive that data from a path. The indexed family, concrete fresh
     generation and active/consumed/retired lifecycle remain unimplemented.
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

3. **Bounded integrity and open privacy games**
   - **One-shot integrity source defined:** `Evidence.TransferCheck` retains
     the actual parser, canonical bytes, exact metadata/intent and verifier
     algorithms without universal primitive soundness. `Transfer.Operational`
     derives validity from local semantic good events and reduces actual bad
     acceptance to authorization or payload failure on the same packet.
   - `Transfer.Security` fixes a configuration, declared transfer release,
     explicit auxiliary input and supplied `PMF` random tape. One adversarial
     transfer/byte attempt is checked by the actual algorithm. Its
     accepted-invalid mass is bounded by the sum of the two failure masses;
     supplied primitive budgets compose without independence. The actual
     `CheckedTransfer.publicView` instantiation retains bytes, packet,
     complete proposal and original one-input manifest, rather than replacing
     the observation by the HCP pair. The attacked configuration is explicit
     and may differ from the prior release's setup.
   - Concrete primitive error bounds, security parameters/efficient
     adversaries, adaptive signing/proving oracles and corruption policies
     remain open. The authorization-failure event is not an EUF-CMA game.
     Declare public setup/prior-state/catalog access and network/access
     metadata as additional experiment inputs; trusted state origin and
     runtime agreement are not supplied by this bound.
   - **Privacy remains open:** state the finite-family/asymptotic sampling game used to interpret
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
     ordered item list, manifest root and block digest. The selected bounded
     transfer now uses a pre-proof one-input manifest, with its root retained
     in the typed owner intent and staged block preimage. Its leaf is the
     original payload/digest, not the enclosing candidate or proof packet.
     The generic projection join still supports other enclosing-root layouts;
     concrete canonical codecs, domain separation and hash/inclusion security
     remain implementation contracts.
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
     Authorized atomic changes of topology, stalks or restriction maps and
     retained-history migration are not implemented. The separate rotation
     correctness layer does not turn this fixed-snapshot/epoch ledger action
     into a migration protocol. Anchoring leaves the completed native Q08
     profile unchanged and proves no broader HCP geometric comparison.

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
   - **Bounded profile now defined:** `Ledger.OwnedResource` supplies actual
     owner/asset/positive-amount interpretation, exact single-input/output
     flow, derived input-ID nullifier and unit-resource/spent invariants.
     `Transfer.Owned` constructs the candidate and derives its validity from
     structural checks and independently checked packet facts. Signature
     authorization is on the pre-proof intent, not the completed final
     proposal; the latter is authenticated separately by a matching quorum.
   - `Evidence.TransferTranscript` selects acyclic typed preimages: projected
     successor content excludes its new tip/evidence coordinates, the intent
     explicitly retains the original before-evidence root and parent tip,
     complete metadata/signature/proof bytes determine the evidence hash,
     then block/proposal completion binds the late coordinates. The generic
     `RootBindings.artifactIncluded` relation still covers only the hashed
     cochain artifact; `Transfer.Anchored` supplies the separate full-packet
     inclusion for this profile. No global hash injectivity is assumed.
   - `Evidence.TransferVerifier.PayloadVerifier` is indexed by the actual
     trusted payload interpretation. Its arithmetization/context soundness
     contract does not apply to every decoder sharing a public tag. The
     independently derived validity is subsequently represented by
     `TransferEnvelope` with the actual candidate/transfer witness and
     original artifact; TCB statement equality supplies no extra soundness.
   - **One-shot error composition now defined:** raw operational algorithms
     are separate from ideal universal soundness. The actual released
     bytes/packet/proposal/input manifest enter the sampled experiment;
     accepted-invalid implies one of the same-attempt primitive failure
     events, whose supplied budgets add. No primitive estimate or adaptive
     security result is inferred, and exact public IDs still link uses.
   - **Still pending:** production byte/hash/signature/proof implementations,
     trusted state-origin security, primitive error bounds and adaptive/oracle
     adversary models, runtime refinement,
     secure ephemeral linkage, storage backend/global-run policy and any
     batched block/reorganization model. Fixed snapshot and epoch are part of
     this action; ledger rotation/atomic migration and finality remain outside
     it. Legacy `Chain` callers remain compatibility consumers.
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
