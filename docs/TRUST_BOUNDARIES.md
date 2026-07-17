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

## Python Role In The TCB

Python is allowed to produce candidate evidence, not consensus truth.

This distinction matters for the current geometry stack. The Python code can
compute heavy objects such as Hodge decompositions, Grassmannian projections,
spectral estimates, cochain witnesses, stalk data, and experimental proximity
shadows. Those outputs are useful as:

- witness material for a proof or SNARK;
- inputs to a Rust oracle verifier;
- golden/adversarial test vectors for Rust;
- research references while the mathematical interface is still moving.

They are not, by themselves, validation results. A Python-computed value becomes
consensus-facing only after it is converted into one of the bounded public
artifacts recognized by the TCB:

```
Python candidate computation
  -> canonical payload / public shadow
  -> hash, proof, SNARK, or oracle attestation
  -> Rust verification result
  -> consensus state transition
```

Equivalently: Python may search, approximate, construct, and propose. Rust must
parse, bound, authenticate, verify, and commit. Lean specifies the predicates and
soundness contracts that make those runtime checks meaningful.

This is the intended reading of `NoPythonConsensusAuthority` in
`lean/TCB/Runtime.lean`: Python can be in the prover/witness-generation path, but
it cannot be the final accept/reject boundary for transactions, blocks, oracle
answers, or state transitions.

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
| Exact geometry gates | Specify structural laws: adjacent coboundary composites vanish, Laplacian construction, projection laws | Eventually enforce consensus-path exact gates or verify signed worker attestations | Currently useful for numerical/reference checks |
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
| Cochain-root batch compatibility | Specify `BlockCochainPayloadsCompatible`: every payload is well-formed, shares topology hash, and shares edge-vector length | Reject mixed-topology or mixed-dimension batches before accumulation | Test vectors |
| PoV / spectral proof | Specify stage admissibility and accepted oracle judgments | Verify oracle attestation, spectral judgment, validator eligibility | Worker/reference computations only |
| Sheaf storage coherence | Specify restriction-map/cochain coherence invariants | Persist blocks/state atomically, verify indexes, reject corrupted storage proofs | Prototype storage layouts |
| Fork choice | Specify high-level fork-resolution assumptions/invariants | Enforce deterministic fork-choice rule, finality, rollback bounds | Simulation |
| Resource/DoS controls | Usually runtime-only | Enforce block size, tx count, proof size, validation timeout, cache bounds | Load tests |
| Ledger preservation | Prove valid block transition preserves supply/key-image/state invariants | Apply block transition atomically and durably | Integration tests |

The block validator should be boring: parse, bound, verify, apply. The geometry
can be deep; the endpoint should not be.

## Core Objects, Hashes, And Proof-Carrying Artifacts

Core mathematical/runtime objects should not be redefined as hashes or SNARKs.
Use a layered representation:

```
core object
  → public shadow / compressed projection
  → hash/commitment artifact
  → proof-carrying artifact
  → Rust verifier result
```

For cochains, the canonical Lean object is `CochainCommitmentData`: modulus,
declared edge count, edge values in C¹, and topology hash. Public hashes and
proofs wrap this object; they do not replace it.

Production privacy adds one more discipline: full cochains are witness or
intermediate objects by default. A consensus-facing cochain datum should be a
commitment, root, public shadow, or proof input unless a protocol path
explicitly marks the full edge data public.

## Abstract Witness Setup

The production validation path should follow a witness/verifier pattern:

```
full private object
  -> witness
  -> public inputs / public shadow
  -> proof or attestation
  -> small Rust verifier
  -> state-root update
```

For hcrypt this specializes to:

```
encrypted SheafState / private stalk / fibration representative
  -> cochain or homotopy witness
  -> public shadow: hash, topology hash, root, key image, commitment
  -> proof object: "this witness induces this valid transition"
  -> Rust accepts an observed public statement
  -> ledger updates roots, nullifiers, balances, and storage indexes
```

The public ledger stores commitments, roots, nullifiers, public shadows,
oracle attestations, and proof-carrying artifacts. The verified encrypted data
layer stores full state objects and witness payloads. Rust should not need to
decrypt private objects for consensus; it verifies that the public artifact is
bound to a valid witness statement.

| Layer | Meaning | Lean surface | Runtime owner |
|---|---|---|---|
| Core object | Semantic payload or mathematical datum | `CochainCommitmentData`, sheaf/coherence predicates | Rust validates bytes into this shape |
| Compressed shadow | Bounded public projection of a larger witness/object | `CompressionContract`, proximity/code shadows | Rust owns canonical shadow bytes and size bounds |
| Hash artifact | Public binding/pointer to a core object | `HashedCommittedCochain` | Rust owns serialization, hash function, domain separation |
| Proof artifact | Certificate that hidden witness satisfies a statement | `ProofCarryingCommittedCochain`, `ZKP` | Rust verifies proof bytes/transcript |
| State decision | Consensus acceptance/rejection | theorem/spec interfaces | Rust applies state transition atomically |

Lean currently separates the proof surface by abstraction level:

| Lean area | Role |
|---|---|
| `lean/Axioms/*` | Assumptions and specification contracts: what must be true. |
| `lean/TCB/*` | Proof-carrying artifacts, compression contracts, runtime acceptance predicates, and witness/verifier envelopes. |
| `lean/Gates/*` | Validation-facing façades: what gets checked or exposed at gate boundaries. |
| `lean/Consensus/*` | Protocol composition: how gate facts become reliability discounts and Proof-of-Value scores. |
| `lean/Proximity/*` | Projection/list-decoding/proximity math; imported by gates or consensus when a protocol needs those facts. |
| `lean/Hardness.lean` | Hidden-operator abstraction and reduction statements. |
| `lean/Laplacian/*` | Structured projection/Hodge objects used to instantiate the abstract hardness layer. |

This keeps the TCB split small:

- Lean specifies objects, predicates, and soundness contracts.
- Compression maps full/private objects to bounded public shadows.
- Rust owns canonical encoding, hash binding, proof verification, and state.
- SNARKs prove private/large witness claims about core objects.
- Hashes provide identity and integrity, not validity by themselves.

## Attacker Observation Boundary

The witness/verifier boundary also induces an attacker-observation site: public
views such as transcripts, roots, topology hashes, key images, commitments, and
oracle attestations are the only objects exposed to consensus observers. The TCB
rule is operational:

- Rust owns the canonical bytes, size bounds, domain separation, and replay
  checks for those public views.
- Lean specifies the predicates those views must satisfy.
- Security claims about simulatable local views, zero knowledge, and failure to
  recover private global sections live in `docs/SECURITY.md`.

This keeps the boundary document focused on authority and implementation
ownership, while the security document explains the attacker-observation sheaf
model inspired by Inoué's `arXiv:2602.17301`.

Current Lean names:

| Purpose | Module |
|---|---|
| Canonical cochain payload | `lean/Axioms/CochainCommitment.lean` |
| Ephemeral fibration/fiber math spec | `lean/Axioms/Fibration.lean` |
| Generic proximity projection vocabulary | `lean/Proximity/Projection.lean` |
| Cochain/sheaf proximity bridge | `lean/Proximity/CochainBridge.lean` |
| Hash/proof public artifact boundary | `lean/TCB/ProofCarrying.lean` |
| Generic compression contract | `lean/TCB/CompressionBoundary.lean` |
| SNARK specialization of proof-carrying artifacts | `lean/TCB/SNARK.lean` |
| Lean/Rust TCB contract scaffold | `lean/TCB/Runtime.lean` |
| Runtime-observed public statements and proximity decisions | `lean/TCB/ObservationBoundary.lean` |
| End-to-end witness/verifier envelope | `lean/TCB/WitnessVerifier.lean` |

## Ephemeral Fibration Boundary

Ephemeral fibration/fiber behavior has two owners.

Lean owns the mathematical class/path statement in `Axioms.Fibration`:
`EphemeralFiberSpec` gives an ephemeral representative, a path from the base
representative, and a transport-admissibility obligation. From this, Lean proves
that a path-respecting classifier gives the same public fingerprint/homotopy
class.

Rust owns the lifecycle facts in the TCB: fresh per message, single-use,
zeroize/drop behavior, malformed-byte rejection, endpoint hardening, and the
rule that Python is not consensus authority. These facts are named by
`EphemeralRuntimeObligations` and bundled with the Lean math spec in
`EphemeralFiberTCBContract`, but they are not proved by Lean.

Do not introduce a second ephemeral-fibration type unless it is a concrete
instantiation that delegates to this boundary.

## Rust Workspace Boundary

The Rust code is the production/runtime side of the Lean contracts. It should be
read as verifier and state-transition infrastructure, not as a replacement for
the Lean mathematical definitions.

| Rust surface | Responsibility | Lean/TCB contract it realizes |
|---|---|---|
| `rust/node` | Consensus-facing node: transaction/block parsing, mempool, block storage, key-image checks, PoV block verification, cochain-root checks, networking/RPC. | `Chain.lean`, `Consensus/*`, `Gates/*`, `TCB.RuntimeBoundary` |
| `rust/node/src/consensus` | Proof-of-Value, VRF/slot checks, worker signatures, block verification, optional geodesic proof checks. | `Axioms.Consensus`, `Axioms.SpectralBounds`, `Axioms.OracleModality`, `Consensus/ProofOfValue.lean` |
| `rust/node/src/storage` | Durable block/state/key-image storage and indexes. | `Axioms.Ledger`, `Chain.TransactionAccepted`, `Chain.BlockAccepted` |
| `rust/node/src/crypto` | Wire-facing commitment/proof helpers used by node validation. | `Axioms.CochainCommitment`, `TCB.ProofCarrying`, `TCB.SNARK` |
| `rust/oracle` | Oracle service and stalk bridge: receives candidate/full-stalk material, computes or checks public commitments, classifies/verifies geometry-facing evidence. | `Axioms.OracleModality`, `Gates.Oracle`, `TCB.ObservationBoundary` |
| `rust/wallet` | User-side witness/key/material storage and construction path. It can generate witness material but should not be the consensus authority. | `Axioms.Fibration`, `EphemeralFiberTCBContract`, `TCB.RuntimeBoundary` |

The critical split is:

- Lean says what it means for an object, gate, transaction, or block to be
  mathematically acceptable.
- Rust parses adversarial bytes, bounds resources, verifies proofs/attestations,
  checks storage state, rejects malformed inputs, and applies atomic updates.
- Python can still generate research/reference witnesses, but Rust must convert
  anything consensus-facing into a bounded authenticated validation result.

## Lean Invariants To Prioritize

These are the useful Lean-side objects for transaction/block validation. They
should be abstract enough that Rust can implement them without depending on Lean
runtime execution.

| Lean object or theorem | Purpose |
|---|---|
| `TransactionWellFormed` | Abstract shape of a valid transaction |
| `TransactionAccepted` | Abstract transaction shape plus freshness relative to ledger state |
| `BlockWellFormed` | Per-transaction payload shape inside a block |
| `BlockCochainTopologyCompatible` | All block cochain payloads share one topology hash |
| `BlockCochainEdgeCountCompatible` | All block cochain payloads share one edge-vector length |
| `BlockCochainPayloadsCompatible` | Batch-level cochain compatibility before root accumulation |
| `BlockAccepted` | Valid PoV block with compatible cochain payloads and fresh key images |
| `LedgerState` | Abstract state: balances/commitments/key images/sheaf indexes |
| `applyTransaction` | State transition relation/function |
| `applyBlock` | Block transition relation/function |
| `acceptedTransaction_key_image_fresh` | Accepted transactions do not spend prior key images |
| `blockAccepted_cochainPayloadsCompatible` | Accepted blocks expose the cochain batch-compatibility fact |
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
