# Protocol core

The first implemented endpoint is one conservative, proof-carrying resource
transition. It reuses `CochainCommitmentData`, the cellular-sheaf payload
interpretation and snapshot, TCB artifact/observation envelopes, and the
existing authenticated proposal and quorum types.

## Modules

| Module | Role |
|---|---|
| `Ledger/ValueFlow` | Mathlib `Finsupp` resource inventories and additive asset valuations; enabled conservative updates preserve the actual inventory value. |
| `Ledger/Nullifier` | Finite spent sets, freshness of the action's body list, monotone consumption and nonempty replay rejection. |
| `Ledger/State`, `Ledger/Transition` | Public state/context, action, candidate, computed successor, concrete validity, deterministic accepted application and connected-execution invariants. |
| `Ledger/Sheaf` | `SnapshotModel.ofSheaf` uses the existing `CochainPayloadInterpretation F`, snapshot root and accepted exact-cochain predicate. |
| `Evidence/Transition` | Identifies the TCB-observed statement with that candidate's validity and joins the same payload, actual states, transition digest and evidence inclusion. |
| `Ledger/Certified` | Attaches the existing acceptance quorum to the same complete proposal, including snapshot root; derives validity and excludes hold/rejection certificates. |
| `Ledger/Examples`, `Ledger/EvidenceExamples` | A positive-value transfer and accepted evidence/quorum fixture; rejection checks for overspending, imbalance, replay, duplicate/empty nullifiers and substituted context. |
| `Storage/Anchor`, `Storage/ProjectionAnchor` | Join the same candidate evidence to the original snapshot/artifact and exact sealed projection manifest, with explicit history authentication and actual gate-database inclusion. Derive payload acceptance and retain the matching quorum/RS-word endpoints. |
| `Ephemeral/Rotation`, `Ephemeral/Delivery`, `Ephemeral/HCP` | Separately imported actual integral/presented rotation, coefficient-preserving recipient recovery, original bound-sample/payload migration and scoped delivery receipts. Channel/authentication, generation and lifecycle enforcement remain explicit. |

`Protocol.Core` is the focused review entry point. `Protocol.Ledger` is the
broader compatibility aggregate. Its legacy `Chain` import remains for
compatibility; the new leaf modules do not use spectral validator identities,
cumulative-gap fork choice or raw edge sums as ledger semantics.

`Protocol.Ephemeral` is the separate recovery/rotation facade. The actual
message is a declared integer lattice coefficient vector; both target-key
decoding and retained-base-key inverse transport recover it. Its delivery
scope contains recipient and epoch labels plus identifiers derived from the
original source/target contexts. Scope equality alone authenticates no caller
and prevents no repeated valid request. Actual delivery, epoch/state binding
and lifecycle security remain supplied channel/policy obligations. The
[axis fixture](Ephemeral/Examples.lean) constructs the rotation and encoding
law without fabricating contexts, envelopes or authorization proofs.

## Exact endpoint and assumptions

A candidate contains one before-state, its resource flow and nonempty
nullifier list, the original cochain payload, a snapshot/interpretation, and a
`Consensus.ProposalRef`. Its successor is computed by subtracting available
consumed resources, adding produced resources, and recording the body's
nullifiers. Validity checks availability and equal consumed/produced asset
value, authorization, payload/snapshot acceptance, and the proposal's parent,
height, epoch, topology and snapshot context.

The resource, asset and nullifier types remain abstract. An application
supplies an additive valuation, ownership/authorization and the meaning of
resources. The current transition conserves value; fees must be among the
produced resources. Mint/burn policy is a separate extension.

The flow application and successor are noncomputable Lean specifications
using finite-map truncated subtraction. Their preservation proofs do not
provide an executable ledger; that implementation and its refinement remain
runtime work.

`Evidence.Transition.valid` derives candidate validity from the existing TCB
observation and an exact statement match. It does not store a second validity
proof. `RootBindings` uses relations indexed by the actual states, candidate,
payload and artifact. It keeps the cochain leaf digest distinct from the
snapshot, topology, cochain and evidence roots. Concrete encodings, hashes,
inclusion checks, proof/signature verification and nullifier derivation remain
explicit runtime/security obligations. No global hash injectivity is asserted.

`RootBindings.artifactIncluded` relates the candidate, the existing
`HashedCommittedCochain` public artifact, and its evidence root. It does not
take the full `ProofCarryingCommittedCochain` or bind serialized proof bytes,
proof-system identifiers, statements or verifier metadata into that root.
Full proof-evidence inclusion and its encoding remain concrete-profile work.

`Storage.TransitionAnchor` additionally joins that candidate evidence to the
same full public artifact, sheaf interpretation and exact sealed manifest.
`Storage.ProjectionAnchor` authenticates the actual final prefix and requires
inclusion of its actual gate database. Their object-indexed inclusion
relations remain supplied authentication contracts; they do not implement a
wire format, hash function or public serialization of private proof data.

A concrete root scheme must also specify an acyclic dependency order for
canonical preimages, state roots, block digests and evidence. The computed
successor contains the proposal's block digest as its tip and retains the
proposal's cochain and evidence roots. Hashing the complete proposal, including
the after-state root, into that same block digest can therefore create a
self-dependency. A profile must state exactly which fields each digest covers
and how the complete signed proposal binds the remaining coordinates. The
legacy Rust block-header hash does not instantiate this new state/proposal
profile. The abstract relations here do not supply such an encoding.

`CertifiedTransition` joins quorum support to that same proposal. Rounds,
locks, admission, finality and liveness are separate work. The illustrative
runtime/authentication contracts in the examples are not production schemes.

## Validation

From `lean/`:

```sh
lake build Protocol
lake build Protocol.Core
lake build Protocol.Ledger.Examples Protocol.Ledger.EvidenceExamples
```

The examples are separate from the production aggregate and explicitly checked
by CI. For the theorem-dependency check, save this as a scratch Lean file and
run `lake env lean <file.lean>` from `lean/`:

```lean
import Protocol.Core
import Protocol.Ledger.EvidenceExamples

#print axioms Hcrypt.Protocol.Ledger.ResourceFlow.value_apply
#print axioms Hcrypt.Protocol.Ledger.Candidate.not_valid_replay
#print axioms Hcrypt.Protocol.Ledger.AcceptedUpdate.deterministic
#print axioms Hcrypt.Protocol.Ledger.Execution.value_preserved
#print axioms Hcrypt.Protocol.Ledger.Execution.spent_monotone
#print axioms Hcrypt.Protocol.Evidence.Transition.valid
#print axioms Hcrypt.Protocol.Evidence.Transition.toAcceptedUpdate
#print axioms Hcrypt.Protocol.Ledger.CertifiedTransition.toAcceptedUpdate
#print axioms Hcrypt.Protocol.Ledger.EvidenceExamples.certified_positive_value
#print axioms Hcrypt.Protocol.Ledger.EvidenceExamples.valid_other_block_old_envelope_rejected
#print axioms Hcrypt.Protocol.Ledger.EvidenceExamples.valid_other_block_old_quorum_rejected
#print axioms Hcrypt.Protocol.Ledger.SnapshotModel.ofSheaf_accepts_decoded_isOneCocycle
```

The [release record](../../PUBLIC_REVIEW.md) distinguishes completed checks
from reproducible commands and records the actual axiom report. Even an
endpoint using only standard Lean logical axioms retains its explicit
profile and verification hypotheses.

The [Paper 2 scope](../../papers/paper2/SCOPE.md) and
[protocol parity queue](../../docs/PROTOCOL_PARITY_QUEUE.md) distinguish this
bounded kernel from the remaining protocol and implementation work.
