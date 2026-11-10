# Trust Boundaries: Lean Specs, Rust Runtime, Python Research

This document defines the implementation boundary for the proof system and the
runtime system.

The short version:

- Lean proves mathematical invariants, protocol transition rules, preservation
  properties, and security-model relationships.
- Rust owns adversarial runtime boundaries: bytes, endpoints, storage, consensus,
  resource limits, canonical validation, and the atomic realization of
  Lean-specified transitions.
- Python is currently suspended. Its former primitive and invariant layers are
  preserved under `docs/archive/python/` for provenance and possible future
  test-vector recovery, but the remaining Python tree is not a supported
  runtime.

This is also the right response to trusted-computing-base concerns in formal
verification: a Lean proof is only a proof of the stated model. It does not
make unverified runtime endpoints, parsers, storage engines, FFI, or generated
binaries secure by default.

## Boundary Rule

Use this rule when deciding where code belongs:

| Question | Owner |
|---|---|
| Is this a theorem about all valid objects or all valid transitions? | Lean |
| Could honest nodes fork because they disagree whether this state transition is allowed? | Lean specifies the deterministic relation; Rust enforces it |
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
    - ledger/nullifier transition relations and preservation theorems
    - block/certificate binding, rounds, locks, and finality safety
    - ephemeral and SheafBlock lifecycle state machines

Rust
  production consensus path:
    - wire parsing and canonical encoding
    - transaction/block validation
    - oracle service and judgments
    - storage engine and atomic transition application
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

The following is the target role for a future rebuilt Python layer. The current
legacy Python package is intentionally non-runnable and produces no supported
evidence.

Python may eventually produce candidate evidence, not consensus truth.

This distinction matters for the geometry stack. A future rebuilt Python layer
could compute heavy objects such as Hodge decompositions, Grassmannian
projections, spectral estimates, cochain witnesses, stalk data, and
experimental proximity shadows. Such outputs would be useful as:

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
| Nullifier freshness | Specify authorization/derivation obligations and prove ledger transition preserves no-double-consumption | Verify the concrete nullifier proof, check state/batch freshness, insert atomically | Reference tests only |
| Commitment/cochain validity | Specify the accepted exact `C¹` value, opening equivalence modulo `ker δ₀`, and snapshot coherence | Validate dimensions, authenticated payload/context, local openings/proofs, modulus, canonical field elements | Prototype commitment code ok |
| Ephemeral representatives/transports | Specify path/class semantics, admissible transport, and the active/consumed/retired lifecycle with no double consumption | Generate with a CSPRNG, verify lifecycle witnesses, apply transitions atomically, zeroize/drop secrets, reject malformed hints | Prototype/reference only |
| Exact geometry gates | Specify structural laws: adjacent coboundary composites vanish, Laplacian construction, projection laws | Eventually enforce consensus-path exact gates or verify signed worker attestations | Currently useful for numerical/reference checks |
| Oracle judgments | Prove Heyting semantics and stage admissibility | Classify spectral gap, Betti consistency, naturality, boundary/hold/reject policy | Should not bypass oracle on consensus path |
| Hidden-kernel security claim | Prove hidden-operator ambiguity and CVP-oracle insufficiency | Never accept public data as if it canonically determines hidden `ker(Delta)` | Documentation/reference only |
| State transition | Prove valid transaction preserves ledger/sheaf invariants | Apply transition atomically, update balances/state/key images/storage indexes | E2E tests only |
| Mempool policy | Not theorem-critical unless promoted to consensus; nonce/nullifier replay validity is ledger semantics, not mempool policy | Rate limiting, spam policy, duplicate caching, and eviction; enforce the Lean-owned replay rule at validation | Optional simulation |

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
| Fork choice / finality | Specify the exact deterministic preference/finality relation and prove its safety consequences | Enforce that relation, certified-tip selection, and rollback bounds | Simulation |
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

For cochains, the legacy wire-shaped Lean object is `CochainCommitmentData`:
modulus, declared edge count, edge values in `C¹`, and topology hash. The
mathematical committed object is the decoded exact `C¹` value. Public hashes
and proofs wrap it; the stronger protocol envelope must additionally bind the
same canonical `SheafStateSnapshot` root used by its plane and evidence. A
topology tag alone is not that full snapshot commitment.

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

For homotopical_encrypt this specializes to:

```
private fields of SheafState / stalk data / fibration representative
  -> cochain or homotopy witness
  -> public shadow: snapshot root, topology metadata, key image, exact-C¹ commitment
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
| Core object | Semantic payload or mathematical datum | exact `C¹` cochain, `SheafStateSnapshot`, sheaf/coherence predicates | Rust validates bytes into this shape |
| Compressed shadow | Bounded public projection of a larger witness/object | `CompressionContract`, proximity/code shadows | Rust owns canonical shadow bytes and size bounds |
| Hash artifact | Public binding/pointer to a core object | `HashedCommittedCochain` | Rust owns serialization, hash function, domain separation |
| Proof artifact | Certificate that hidden witness satisfies a statement | `ProofCarryingCommittedCochain`, `ZKP` | Rust verifies proof bytes/transcript |
| State decision | Consensus acceptance/rejection | theorem/spec interfaces | Rust applies state transition atomically |

`TCB.HCPObservation.BoundHCPObservation` is a useful private assembly object:
it joins the hidden harmonic-lattice message/opening, observed cochain, exact
payload digest, and sheaf snapshot root. Because it contains the private
witness, it is not itself a transaction, block leaf, or persisted public
manifest. The chain consumes only its bounded public artifact/root/evidence
projection under an explicit transition-binding relation.

Lean currently separates the proof surface by abstraction level:

| Lean area | Role |
|---|---|
| `lean/Axioms/*` | Assumptions and specification contracts: what must be true. |
| `lean/TCB/*` | Proof-carrying artifacts, compression contracts, runtime acceptance predicates, and witness/verifier envelopes. |
| `lean/Gates/*` | Validation-facing façades: what gets checked or exposed at gate boundaries. |
| `lean/Consensus/*` | Protocol composition: how gate facts become reliability discounts and Proof-of-Value scores. |
| `lean/Proximity/*` | Projection/list-decoding/proximity math; imported by gates or consensus when a protocol needs those facts. |
| `lean/HCP.lean` | Hidden-operator abstraction, Hodge cipher, and operative recovery target. |
| `lean/Hardness.lean` | Impossibility consequences and linear/discrete-CVP comparisons. |
| `lean/Laplacian/*` | Structured projection/Hodge objects used to instantiate the abstract hardness layer. |

This keeps the TCB split small:

- Lean specifies objects, predicates, and soundness contracts.
- Compression maps full/private objects to bounded public shadows.
- Rust owns canonical encoding, hash binding, proof verification, and state.
- SNARKs prove private/large witness claims about core objects.
- Hashes provide identity and integrity, not validity by themselves.

## Attacker Observation Boundary

The witness/verifier boundary also induces an attacker-observation site: public
views such as transcripts, snapshot/state/evidence roots, topology metadata,
key images, exact-cochain commitments, and
oracle attestations are the only objects exposed to consensus observers. The TCB
rule is operational:

- Rust owns the canonical bytes, size bounds, domain separation, and replay
  checks for those public views.
- Lean specifies the predicates those views must satisfy.
- Security claims about simulatable local views and zero knowledge require
  explicit protocol games; the current status is summarized in
  `docs/SECURITY.md` and scoped in the Paper 2 README.

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
| Private HCP observation/payload/snapshot join | `lean/TCB/HCPObservation.lean` |
| Consensus proposal root tuple and authenticated votes | `lean/Protocol/Consensus/Vote.lean` |
| Strict weighted quorum certificates | `lean/Protocol/Consensus/Quorum.lean` |

## Ephemeral Representative Boundary

Ephemeral behavior has three distinct ownership levels.

The shared/Paper 1 Lean layer owns the mathematical class/path statement in
`Axioms.Fibration`: `EphemeralFiberSpec` gives an ephemeral representative, a
path from the base representative, and a transport-admissibility obligation.
From this, Lean proves that a path-respecting classifier gives the same public
classifier value.

The Paper 2 Lean layer must own the semantic lifecycle: generated, active,
consumed, and retired states; the transition that consumes a handle; replay
exclusion; and the theorem that two accepted transitions cannot consume the
same handle/nullifier. These are consensus-determinative state-machine facts,
even though Rust supplies their witnesses and persists the resulting state.
`Protocol/Ephemeral.lean` is the intended owner.

Rust owns the concrete generation entropy, secret-key material, canonical
handles, proof/signature verification, atomic compare-and-set, malformed-byte
rejection, endpoint hardening, and physical zeroize/drop behavior. Python is
not consensus authority.

The current `EphemeralRuntimeObligations` in `Axioms/Fibration.lean`
provisionally bundles all of these as Rust-owned propositions. During the
Protocol migration, move the semantic freshness/single-consumption relation
under `Protocol/Ephemeral`; retain CSPRNG quality, byte validation, memory
wiping, and endpoint behavior in the runtime contract. Do not introduce a
competing ephemeral type: the lifecycle should refer to the existing
mathematical representative/path object through an opaque public handle.

## Rust Workspace Boundary

The Rust code is the production/runtime side of the Lean contracts. It should
be read as verifier and state-transition infrastructure, not as a replacement
for the Lean mathematical definitions. The final column below names the target
contract; the CH0 audit shows that the current Rust chain is not yet its
refinement.

| Rust surface | Responsibility | Lean/TCB contract it realizes |
|---|---|---|
| `rust/node` | Consensus-facing node: transaction/block parsing, mempool, validation, nullifier checks, storage, networking/RPC. | `Protocol/Ledger`, `Protocol/Chain`, `Protocol/Consensus`, `Gates/*`, `TCB.RuntimeBoundary` |
| `rust/node/src/consensus` | Selection-witness checks, authenticated votes/certificates, block verification, rounds/locks/finality realization. | `Protocol/Consensus/*`, `Axioms.OracleModality`, and any selected `Consensus/*` scoring lemmas |
| `rust/node/src/storage` | Atomic durable block/state/nullifier/artifact storage, indexes, recovery, and reorganization. | `Protocol/Ledger`, `Protocol/Storage`, and the accepted-transition relation |
| `rust/node/src/crypto` | Wire-facing commitment/proof helpers used by node validation. | `Axioms.CochainCommitment`, `TCB.ProofCarrying`, `TCB.SNARK` |
| `rust/oracle` | Oracle service and stalk bridge: receives candidate/full-stalk material, computes or checks public commitments, classifies/verifies geometry-facing evidence. | `Axioms.OracleModality`, `Gates.Oracle`, `TCB.ObservationBoundary` |
| `rust/wallet` | User-side witness/key/material storage and construction path. It can generate witness material but should not be the consensus authority. | `Axioms.Fibration`, `Protocol/Ephemeral`, and `TCB.RuntimeBoundary` |

The critical split is:

- Lean says what it means for an object, gate, transaction, or block to be
  mathematically acceptable.
- Rust parses adversarial bytes, bounds resources, verifies proofs/attestations,
  checks storage state, rejects malformed inputs, and applies atomic updates.
- Python can still generate research/reference witnesses, but Rust must convert
  anything consensus-facing into a bounded authenticated validation result.

## Lean Chain Objects To Prioritize

These objects should be abstract enough that Rust can realize them without
depending on Lean runtime execution. Current `Chain.lean` names are retained
only where their actual scope is accurate.

| Lean surface | Current status | Required role |
|---|---|---|
| `TCB.WitnessVerifier.PublicStateUpdate` | Preliminary root envelope with abstract binding propositions. | Refine into a typed committed public state and candidate before/after transition. |
| `Protocol.Consensus.ProposalRef` | Current root tuple for one epoch/height/round/phase, but it lacks a distinct full sheaf-snapshot root. | Add `snapshotRoot`, keep it distinct from `topologyRoot`, and prove that one complete semantic block/transition binds this exact tuple. |
| `Committee`, `VoteTarget`, `AuthenticatedVote`, `QuorumCertificate` | Current typed/proved strict weighted-quorum kernel. | Add round/phase transitions, locks, no-double-vote derivation, certified block, and finality. |
| `TransactionWellFormed` / `TransactionAccepted` in `Chain.lean` | Legacy shape plus prior-nullifier freshness only. | Replace with authorization, exact value flow, state/snapshot/evidence binding, and resulting-state relation under `Protocol/Ledger`. |
| `LedgerState`, `applyTransaction`, `applyBlock` in `Chain.lean` | Stores only spent `Nat` key images and a block list; proves insertion monotonicity. | Migrate the useful monotonicity lemmas to typed nullifiers and add exact ledger state, roots, and atomic accepted transitions. |
| `BlockCochain*` predicates | Legacy payload-shape/topology-tag compatibility. | Require one canonical `SheafStateSnapshot`/cochain/evidence context and bind it to the block proposal. |
| `BlockAccepted` in `Chain.lean` | Legacy PoV predicate plus payload compatibility and prior freshness. | Replace with valid accepted transactions, full root coherence, `Valid` authenticated quorum certificate, and certified state application. |
| `EphemeralFiberSpec` | Current shared mathematical representative/path object. | Keep it as the math source; add generated/active/consumed/retired protocol state and no-double-consumption under `Protocol/Ephemeral`. |
| `Proximity.Gates.Projection.StateBus` | Current proof-level projection-stage chain. | Wrap it in a fresh per-commit `SheafState` lifecycle and slot-at-most-once checkpoint relation. |
| Planned `SheafBlock` | No Lean type yet. | Define open/sealed manifests, common context, artifact/evidence completeness, immutable finalization, and abstract root binding under `Protocol/Storage`. |
| Oracle/Heyting stage predicates | Current semantic gates and `Valid`/`Undetermined`/`Invalid` separation. | Add authenticated round-bound judgments and retry/re-projection transitions; `Undetermined` cannot finalize. |

The complete ownership and target file split is maintained in
`PROTOCOL_PARITY_QUEUE.md` under “Chain Ownership Decision.”

## Rust Runtime Concerns To Prioritize

These are not solved by Lean proofs. They need ordinary production hardening.

| Runtime concern | Rust requirement |
|---|---|
| Canonical encoding | One byte representation per object; reject aliases |
| Bounded allocation | Never allocate directly from untrusted claimed sizes |
| Domain separation | Every signature/proof/hash has explicit context tags |
| Atomic state updates | Realize one Lean-accepted transition: nullifier insertion and every balance/root/index update all commit or none do |
| Replay protection | Enforce the Lean chain-id, nonce/sequence, epoch, nullifier, and lifecycle predicates atomically |
| Ephemeral secrets | Generate with secure entropy; verify semantic active/consumed state; keep no logs; wipe secret transport material |
| Fuzzing | Fuzz wire decoders, tx validator, block validator, oracle request parser |
| Differential tests | Compare Rust against canonical specification fixtures and independent vectors; Python output is never the acceptance oracle |
| Fault isolation | Oracle/worker failures become hold/reject judgments, not panics |
| Determinism | Consensus-visible checks must not depend on machine-local floating behavior |
| Auditability | Validation errors should be explicit and typed |

## Migration Guidance

1. Recover only narrowly specified numerical routines from the Python archive,
   after assigning each one a current Lean or runtime contract.
2. Move consensus-path transaction and block validation into Rust.
3. Keep Lean proofs about abstract validity and preservation, not concrete byte
   parsing.
4. Add Rust fuzz targets before exposing any endpoint to public traffic.
5. Rebuild Python test-vector generation from canonical encodings rather than
   restoring the archived classifier/equivalence semantics.
6. Only consider Lean extraction/runtime use after a separate threat model for
   the Lean runtime and generated code.

## Documentation Contract

Public claims should use this phrasing:

- "Lean machine-checks the mathematical hardness model and validation
  invariants."
- "Rust implements the production validation boundary."
- "The historical Python prototypes are archived; a future Python layer may
  provide non-authoritative research computations and test vectors."

Avoid this phrasing:

- "Lean proves the deployed implementation is secure end-to-end."
- "The blockchain is formally verified."
- "The proof eliminates runtime bugs."

The honest claim is stronger long-term: the math is machine-checked, the runtime
boundary is explicit, and the production endpoints can be fuzzed, audited, and
hardened independently.
