# Trust Boundaries: Lean Specs, Rust Runtime, Python Research

This document defines the implementation boundary for the proof system and the
runtime system.

The short version:

- Lean proves mathematical invariants and security-model relationships.
- Rust owns adversarial runtime boundaries: bytes, endpoints, storage, consensus,
  resource limits, and canonical validation.
- Python remains useful for research, orchestration, reference tests, and
  numerical experiments, but should not be the long-term consensus boundary.

This is also the right response to trusted-computing-base concerns in formal
verification: a Lean proof is only a proof of the stated model. It does not
make unverified runtime endpoints, parsers, storage engines, FFI, or generated
binaries secure by default.

## Boundary Rule

Use this rule when deciding where code belongs:

| Question | Owner |
|---|---|
| Is this a theorem about all valid objects or all valid transitions? | Lean |
| Does this parse, store, gossip, or validate adversarial bytes? | Rust |
| Does this allocate based on untrusted input? | Rust |
| Does this classify consensus-visible values? | Rust oracle, with Lean semantics |
| Is this an exploratory construction or research reference path? | Python |
| Is this numerical experimentation whose API is not stable yet? | Python first, Rust later |
| Is this a bridge between proved math and deployed behavior? | Rust implementation plus tests/fuzzing; Lean spec where possible |

## Target Split

```
Lean
  specs and proofs:
    - Hodge/CVP relationship
    - hidden-operator/kernel ambiguity
    - Heyting oracle semantics
    - stage admissibility
    - sheaf/cochain/commitment invariants
    - ledger preservation theorems

Rust
  production consensus path:
    - wire parsing and canonical encoding
    - transaction/block validation
    - oracle service and judgments
    - storage engine and state transitions
    - networking and gossip
    - bounded allocations and DoS resistance
    - fuzz targets and property tests

Python
  research and reference:
    - prototype geometry
    - test-vector generation
    - notebooks / experiments
    - non-consensus CLI helpers
    - temporary orchestration while APIs are changing
```

## Transaction Validation Boundary

Transaction validation is the most important place to keep the split clean.

| Validation step | Lean responsibility | Rust responsibility | Python status |
|---|---|---|---|
| Decode transaction bytes | Optional future spec: canonical encoding is injective | Parse bytes, reject malformed/non-canonical encodings, enforce versioning | Should not be consensus authority |
| Bound resource usage | Usually out of Lean scope, except abstract size limits | Enforce max sizes, counts, recursion depth, allocation caps, timeout policy | May generate tests only |
| Check transaction shape | Define `TransactionWellFormed` and required fields abstractly | Enforce field presence, dimensions, domain separation tags, chain id | Reference helpers ok |
| Verify signatures/proofs | Specify soundness assumptions for signature/ZK schemes | Verify signatures, Fiat-Shamir transcripts, challenge domains, proof bytes | Test-vector generation |
| Key image uniqueness | Prove ledger transition preserves no-double-spend invariant | Check key image against state, reject duplicates atomically | Reference tests only |
| Commitment/cochain validity | Specify cochain commitment well-formedness and non-triviality | Validate dimensions, commitments, openings/proofs, modulus, canonical field elements | Prototype commitment code ok |
| Ephemeral fibers/transports | Specify path/class semantics and admissible transport within the public homotopy class | Generate fresh per message, enforce single-use, zeroize/drop secret transport, reject malformed hints | Prototype/reference only |
| Exact geometry gates | Specify structural laws: delta^2=0, Laplacian construction, projection laws | Eventually enforce consensus-path exact gates or verify signed worker attestations | Currently useful for numerical/reference checks |
| Oracle judgments | Prove Heyting semantics and stage admissibility | Classify spectral gap, Betti consistency, naturality, boundary/hold/reject policy | Should not bypass oracle on consensus path |
| Hidden-kernel security claim | Prove hidden-operator ambiguity and CVP-oracle insufficiency | Never accept public data as if it canonically determines hidden `ker(Delta)` | Documentation/reference only |
| State transition | Prove valid transaction preserves ledger/sheaf invariants | Apply transition atomically, update balances/state/key images/storage indexes | E2E tests only |
| Mempool policy | Not a theorem-critical layer unless promoted to consensus | Rate limiting, spam policy, eviction, replay protection | Optional simulation |

The key discipline: Rust may call out to workers/oracles, but the final
consensus-facing decision must be represented as a bounded, authenticated Rust
validation result. Python can help compute or propose values; it should not be
the authority for accepting a transaction into consensus state.

## Block Validation Boundary

Block validation composes transaction validation with consensus and storage
preservation.

| Validation step | Lean responsibility | Rust responsibility | Python status |
|---|---|---|---|
| Decode block bytes | Optional future spec: canonical block encoding is injective | Parse header/body, reject malformed/non-canonical encodings | No consensus authority |
| Header checks | Specify abstract block well-formedness | Check parent hash, height, timestamp window, chain id, version, proposer id | Test fixtures only |
| Body checks | Specify block contains only valid transactions | Run transaction validator for every transaction, enforce count/size limits | E2E tests |
| State root / commitments | Specify commitment/state invariants | Recompute roots, compare canonical hashes, enforce domain separation | Test vectors |
| PoV / spectral proof | Specify stage admissibility and accepted oracle judgments | Verify oracle attestation, spectral judgment, validator eligibility | Worker/reference computations only |
| Sheaf storage coherence | Specify restriction-map/cochain coherence invariants | Persist blocks/state atomically, verify indexes, reject corrupted storage proofs | Prototype storage layouts |
| Fork choice | Specify high-level fork-resolution assumptions/invariants | Enforce deterministic fork-choice rule, finality, rollback bounds | Simulation |
| Resource/DoS controls | Usually runtime-only | Enforce block size, tx count, proof size, validation timeout, cache bounds | Load tests |
| Ledger preservation | Prove valid block transition preserves supply/key-image/state invariants | Apply block transition atomically and durably | Integration tests |

The block validator should be boring: parse, bound, verify, apply. The geometry
can be deep; the endpoint should not be.

## Lean Invariants To Prioritize

These are the useful Lean-side objects for transaction/block validation. They
should be abstract enough that Rust can implement them without depending on Lean
runtime execution.

| Lean object or theorem | Purpose |
|---|---|
| `TransactionWellFormed` | Abstract shape of a valid transaction |
| `TransactionAccepted` | Abstract transaction shape plus freshness relative to ledger state |
| `BlockWellFormed` | Abstract shape of a block |
| `BlockAccepted` | Block whose transactions and oracle judgments are accepted |
| `LedgerState` | Abstract state: balances/commitments/key images/sheaf indexes |
| `applyTransaction` | State transition relation/function |
| `applyBlock` | Block transition relation/function |
| `acceptedTransaction_key_image_fresh` | Accepted transactions do not spend prior key images |
| `blockAccepted_tx_not_previously_spent` | Accepted blocks contain no transaction spending a prior key image |
| `applyTransaction_marks_key_image` | Applying a transaction records its key image |
| `applyBlock_marks_tx_key_image` | Applying a block records every transaction key image in that block |
| `commitmentCoherencePreserved` | Accepted transactions preserve cochain commitment invariants |
| `EphemeralFiberSpec` | Ephemeral representative stays in the same public homotopy class under admissible transport |
| `EphemeralFiberTCBContract` | Records Lean-owned math spec separately from Rust-owned freshness/wipe/runtime obligations |
| `sheafCoherencePreserved` | Accepted blocks preserve restriction-map/cochain coherence |
| `acceptedImpliesNotInvalid` | Heyting/oracle bridge: accepted consensus data is not invalid |
| `stageAdmissibleTransaction` | Transaction stage requires exact and consensus gates |
| `stageAdmissibleBlock` | Block stage requires oracle-attested consensus gates |

Some of these already exist as partial interfaces under `lean/Axioms/*`; the
next step is to consolidate them into transaction/block-specific structures
without pretending the runtime implementation is verified extraction.

## Rust Runtime Concerns To Prioritize

These are not solved by Lean proofs. They need ordinary production hardening.

| Runtime concern | Rust requirement |
|---|---|
| Canonical encoding | One byte representation per object; reject aliases |
| Bounded allocation | Never allocate directly from untrusted claimed sizes |
| Domain separation | Every signature/proof/hash has explicit context tags |
| Atomic state updates | Key image insertion and balance/state updates are one transition |
| Replay protection | Chain id, nonce/sequence, epoch, and key image checks |
| Ephemeral secrets | Fresh per message, single-use, no logs, wipe-on-drop/zeroize secret transport material |
| Fuzzing | Fuzz wire decoders, tx validator, block validator, oracle request parser |
| Differential tests | Compare Rust validation against Python reference vectors |
| Fault isolation | Oracle/worker failures become hold/reject judgments, not panics |
| Determinism | Consensus-visible checks must not depend on machine-local floating behavior |
| Auditability | Validation errors should be explicit and typed |

## Migration Guidance

1. Keep Python exact/geometry checks as research references while the math is
   moving.
2. Move consensus-path transaction and block validation into Rust.
3. Keep Lean proofs about abstract validity and preservation, not concrete byte
   parsing.
4. Add Rust fuzz targets before exposing any endpoint to public traffic.
5. Use Python to generate adversarial and golden test vectors for Rust.
6. Only consider Lean extraction/runtime use after a separate threat model for
   the Lean runtime and generated code.

## Documentation Contract

Public claims should use this phrasing:

- "Lean machine-checks the mathematical hardness model and validation
  invariants."
- "Rust implements the production validation boundary."
- "Python provides research/reference implementations and tests."

Avoid this phrasing:

- "Lean proves the deployed implementation is secure end-to-end."
- "The blockchain is formally verified."
- "The proof eliminates runtime bugs."

The honest claim is stronger long-term: the math is machine-checked, the runtime
boundary is explicit, and the production endpoints can be fuzzed, audited, and
hardened independently.
