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
| [Ephemeral/NativeDelivery](Ephemeral/NativeDelivery.lean) | Exported by `Protocol.Ephemeral`: exact rational native transport, canonical scoped tokens and held-token byte migration/recovery on the original contexts. Uses the same delivery receipt; concrete protected delivery remains an application obligation. |
| `Transfer` | Focused conditional owned-resource profile: actual catalog and public input-ID nullifier, typed canonical packet checks, trusted-decoder proof result, derived candidate/update, staged hash inputs and original input-manifest/evidence/history joins. Secure primitives and runtime/state-origin/finality contracts remain explicit. |
| `Evidence/TransferCheck`, `Transfer/Operational` | The same canonical packet and resource checks without assumed primitive soundness; local semantic good facts derive validity and actual accepted-invalid outcomes reduce to authorization or exact-payload false acceptance. |
| `Transfer/PublicView`, `Transfer/PublicAssembly`, `Transfer/Confidentiality`, `Transfer/Security` | Original checked release; exact reconstruction from fixed supplied setup, base payload, ciphertext digest and signature/proof bytes; perfect branch distinction for changed public input IDs; conditional one-shot integrity error bound. The assembly event bound requires an independently justified bound on those four variable fields. No primitive estimate or HCP privacy theorem follows. |
| `Transfer/Primitives` | Actual owner/key/message/history and byte-proof backend agreement, with five-event same-PMF error composition. Query coverage, backend-to-original-context refinement and concrete primitive budgets remain explicit. Current spectral runtime paths do not instantiate these joins. |
| [Transfer/Certificates](Transfer/Certificates.lean), [Certificates/Statement](Transfer/Certificates/Statement.lean) | The generic reflection contract remains available. The constructed adapter executes the selected byte verifier on the original full subject, with reflexive algorithm agreement and canonical-decoding reflection for its declared meaning. Actual checking yields certification or backend false acceptance; this supplies no arbitrary-verifier soundness or knowledge theorem. |
| [Certificates/Codec](Transfer/Certificates/Codec.lean), [Calibration](Transfer/Certificates/Calibration.lean), [Evidence](Transfer/Certificates/Evidence.lean), [Bundle](Transfer/Certificates/Bundle.lean) | Canonical full intent/metadata subjects, optional exact rational calibration, actual subject-and-proof entry hashes and one immutable seven-entry bundle/root. Hard/naturality/final verification requires the same five/six/seven-entry prefix. A failed earlier prefix rejects later checking; raw root commitment alone certifies no gate. |
| [Certificates/Native](Transfer/Certificates/Native.lean), [Projection](Transfer/Certificates/Projection.lean) | Instantiate the declared statement with the existing original-observation binding or exact retained projection record/certificate, including its chosen metric functions and original cochain input. Final projection meaning requires rational realization of the actual calibration. The preferred `boundConfig` checks the actual record's database root and all seven leaf digests, deriving `DatabaseBound` from acceptance. The native CRS reference and exact approved implementation selection below add bounded execution/security reductions. Secure primitive instantiation and complete circuit/semantic refinement remain explicit. |
| `Transfer/Signing`, `Transfer/Issuance`, `Transfer/Authorization` | Reuse the complete subject, packet codec, existing key map/history and release carrier. Construct owner-domain byte checks and exact authorized query projection; the bounded fixed-policy theorem excludes queried-unauthorized targets and leaves four same-PMF errors. Concrete wire/key/oracle refinement remains separate. |
| `Transfer/PathSignature` | Partial finite-byte decoding and a supplied path realization retain the original credential opening, admissible path and rotation. The existing proof backend executes on credential/full-signing inputs and actual `ownerSignature` bytes. Statement reflection and witness encoding remain supplied; existence establishes no knowledge or unforgeability. |
| [Transfer/PathSignature/Codec](Transfer/PathSignature/Codec.lean) | Concrete byte-key/full-message framing, canonical parser, roundtrip and injectivity. `canonical_input_subject_eq` discharges the outer encoding premise; typed owner-packet, HCP ciphertext and private-witness codecs remain separate. |
| [PathSignature/NativeRelation](Transfer/PathSignature/NativeRelation.lean), [NativeProgram](Transfer/PathSignature/NativeProgram.lean) | Canonical bounded private matrices/message/openings/salt, public instance/program bytes and actual native checker. Existing typed Helfer equivalence and full native ciphertext transport apply; this is separate from the generic fingerprint/path-to-isometric-rotation adapter. Original bound-observation artifact/lifecycle joins remain explicit. |
| [PathSignature/CRS](Transfer/PathSignature/CRS.lean), [NativeSecurity](Transfer/PathSignature/NativeSecurity.lean) | A bounded response-dependent signing interpreter generates actual real/simulated query logs from supplied CRS algorithms. The event-specific `WinningHybrid` premise concerns the executable Boolean forgery test, not statistical closeness for all transcript sets. Native extraction yields original coefficients or snapshot/ciphertext collisions; the five-term bound applies when canonical full target-ciphertext bytes are actually supplied to the adversary. Primitive implementation, PPT/negligibility and richer-view hardness remain separate. |
| [Certificates/Profile](Transfer/Certificates/Profile.lean), [PathSignature/Registered](Transfer/PathSignature/Registered.lean), [NativeRegistered](Transfer/PathSignature/NativeRegistered.lean) | Existing quorum approval binds exact descriptor/program/key/CRS bytes and original metadata/scope/epoch. The preferred native adapter also checks the exact expected program and derives the key from the existing owner credential, actual context snapshot root and ciphertext digest. Wrong code, inapplicability or parsing failure rejects; honest completeness retains actual setup agreement and primitive `Correct`. The original-context and sampled application adapters below construct the conditional joins; approval proves neither finality nor secure setup generation. |
| [PathSignature/NativeContext](Transfer/PathSignature/NativeContext.lean), [NativeApplication](Transfer/PathSignature/NativeApplication.lean) | Actual source credential, target snapshot/sample/hash and parsed-setup equations derive the native key, real-reference verification and original ciphertext view. The application selects the primitive and completes the actual generated target through the canonical signing-message and signer-key guards, retaining original packet checks and supplied payload proof. Fresh accepted completion implies a CRS win on the same PMF. The preferred `nativeSource_application_bound` consumes actual credential/snapshot/sample/hash and setup equations, deriving the selected owner-key and released-ciphertext equalities together with the five-term bound; `errorBudget` is that event sum, not an estimate. This is not a compiler for arbitrary packet adversaries or a bound on all accepted/accepted-invalid transfers; other released data belongs in auxiliary input. |
| [PathSignature/NativeSampler](Transfer/PathSignature/NativeSampler.lean) | Uniform finite seeds have cardinality `(2K+1)^(2mn+n+m+1) * 256^ell`, injective decoding and bounded witness support. A fixed cryptographic-tape PMF is independent of the seed, with both marginals retained. Neither seed cardinality nor uniformity proves public-hash uniformity, hardness or confidentiality. |
| [PathSignature/NativeRecovery](Transfer/PathSignature/NativeRecovery.lean), [NativeSignSampler](Transfer/PathSignature/NativeSignSampler.lean) | Original full-seed scalar public recovery has exact probability `7/9` for any credential salt length; a known zero message can reveal a reused scalar operator. The separate fresh-sign candidate has equal one-use ciphertext-byte laws, with identity and dense Hadamard instances. It is not the default storage privacy profile; operator hashes and the rest of the public view remain outside that law. |
| [PathSignature/NativeSignPrivacy](Transfer/PathSignature/NativeSignPrivacy.lean) | Under uniform message and independent fresh key, the actual ciphertext-only joint law factors. Every complete-message decoder succeeds with exactly `2^-n`, also with a deterministic digest or independently sampled fixed tape. For positive `d`, every partial integer-coefficient extractor succeeds with probability at most `2^-n`. This is not the full-view CRS recovery event. |
| [PathSignature/NativeOperatorGuessing](Transfer/PathSignature/NativeOperatorGuessing.lean) | Actual-byte parsing and public transpose/parity arithmetic recover the masked signs. The correct plaintext guess passes the raw operator-hash test; a wrong accepted guess supplies distinct canonical matrix bytes with equal hashes. No timed CPA game or hiding-commitment implementation is claimed. |
| [PathSignature/NativeNoiseRefresh](Transfer/PathSignature/NativeNoiseRefresh.lean) | Actual canonical-byte coexact correction produces the desired target opening after transport. Ordinary transport retains the original opening and generally does not sample the fresh-sign target law. Key freshness, public-token safety and one-use enforcement remain separate. |
| [PathSignature/NativeCircuit](Transfer/PathSignature/NativeCircuit.lean), [NativeCircuitBounds](Transfer/PathSignature/NativeCircuitBounds.lean) | The generated `2mn+n+m+1` core admits honest integer/modular assignments. Actual integer-lift ranges plus an explicit worst-case residual/modulus bound supply `NoWrap` and recover the original observation. Range/salt/byte/hash compilation to field constraints and finite realization of real projection certificates remain separate. |
| [Storage/Retrieval](Storage/Retrieval.lean) | Optional native Hodge query/answer and same-answer CVP laws, local content-address verification and original HCP recovery, fixed-bucket uniform-read privacy, and a conditional joint-query obstruction. See the [storage leaf map](Storage/README.md#harmonic-lattice-recovery-and-optional-query-evaluation) for separate hypotheses. |
| [Storage/Retrieval/Coupled](Storage/Retrieval/Coupled.lean) | Optional concrete codec join for original bound coupled samples, actual isometric rotation and scoped private delivery. Hash-checked recovery gives original coefficients or a byte collision under the existing directory and availability hypotheses. |
| [Storage/Retrieval/Native](Storage/Retrieval/Native.lean) | Exact rational held-token recovery from canonical native ciphertext bytes and hash lookup, retaining original observations. Its generic directory naming/availability premises are separate; `NativeAnchored` derives the view and naming from an actual target seal. |
| [Storage/CiphertextManifest](Storage/CiphertextManifest.lean), [Storage/NativeManifest](Storage/NativeManifest.lean), [Storage/Retrieval/NativeAnchored](Storage/Retrieval/NativeAnchored.lean) | One canonical raw two-slot seal for the original exact artifact and selected full-ciphertext bytes. Raw naming does not establish ciphertext validity. The separate `BindsOriginal` certificate supplies the original observation/context binding; projection and the same `TransitionAnchor` give native message/history association. Availability, canonical issued token and authentication remain explicit. |
| [Transfer/Native](Transfer/Native.lean) | Connects the actual checked owned packet and its computed two-slot history anchor to native recovery on that same manifest. The native certificate and canonical sample-byte equation remain explicit; no relation identifies harmonic coefficients with catalogue amounts or action semantics. |

`Protocol.Core` is the focused review entry point. `Protocol.Ledger` is the
broader compatibility aggregate. Its legacy `Chain` import remains for
compatibility; the new leaf modules do not use spectral validator identities,
cumulative-gap fork choice or raw edge sums as ledger semantics.

The selected design target combines exact harmonic recovery, fresh geometry
per public encrypted object and persistent private master-key management.
Wallet-at-rest and reused-geometry roles remain separate. The [nonce-bearing operator construction](Storage/OperatorCommitment.lean)
and [V2 witness/program/instance](Transfer/PathSignature/NativeCommitted.lean)
now reuse the original snapshot and bounded witness. The
[context adapter](Transfer/PathSignature/NativeCommittedContext.lean) executes
the approved V2 program at the original owner checker. The
[finite public-instance experiment](Transfer/PathSignature/NativeCommittedPrivacy.lean)
reduces recovery above `2^-n` to an explicit operator-commitment distinguishing
test. Bounding that test and accounting for proof/storage transcripts are the
next privacy endpoints.

The broad `Protocol` facade also checks the finite
[signed-axis sampler](../HCP/AxisSignedSampler.lean) and conditional
[fixed-key span attack](../HCP/NoiseSpanAttack.lean). Both analyze the native
HCP sample; neither proves confidentiality of a full storage or transfer view.

`Protocol.Ephemeral` is the separate recovery/rotation facade. The actual
message is a declared integer lattice coefficient vector; both target-key
decoding and retained-base-key inverse transport recover it. Its delivery
scope contains recipient and epoch labels plus identifiers derived from the
original source/target contexts. Scope equality alone authenticates no caller
and prevents no repeated valid request. Actual delivery, epoch/state binding
and lifecycle security remain supplied channel/policy obligations. The
[axis fixture](Ephemeral/Examples.lean) constructs the rotation and encoding
law without fabricating contexts, envelopes or authorization proofs.

Given a supplied path-to-`PresentedRotation` realization,
`PresentedRotation.pathFiberSystem` constructs the original `FiberSystem` on
full cochains, with harmonic-projection, harmonic-invariance and recovery laws.
`EphemeralRotation.ofPath` retains that same path's rotation; arbitrary older
carrier values need not satisfy this alignment. The
native join map (archived reference: `archive/documentation/docs/PROTOCOL_PARITY_QUEUE.md`)
keeps those conditional geometry results separate from credential setup,
finite decoding algorithms and message-bound knowledge security.

`Protocol.Storage.Retrieval` is separate from both focused cores and is
exported by the broader `Protocol.Storage` facade. Its native queries use
the original `HodgeNoise` fields; their public weighted answer is an actual
HCP encryption with aggregated exact/coexact openings. This preserves the
existing coefficient/CVP correspondence. Efficient selector privacy needs
a joint sampler/view argument; the uniform whole-bucket reference has exact
same-bucket privacy at linear download cost. These results select no public-key
HCP encryption or conventional/native signature combiner.

`Protocol.Transfer` selects one whole-resource transfer in the fixed current
snapshot and epoch. Catalog ownership, assets and positive amounts give its
inventory a value independent of cochain coordinates. It derives validity
from local resource checks and actual packet verification under signature and
trusted-interpretation proof contracts. Owner authorization covers a typed
pre-proof intent; the full packet determines evidence before the complete
block proposal is constructed. Its signed manifest root covers the original
exact artifact and separately named full-ciphertext bytes in two distinct
slots, separate from the six-stage projection manifest. Raw sealing admits
invalid inputs. The selected native and projection certificate profiles now
construct their intended byte predicates separately from exact-payload
acceptance. The projection profile parses the actual packet proof bytes as
one seven-entry bundle and requires every earlier check before its selected
level can pass. The raw transfer specification is noncomputable; the new finite
codecs and prefix checks do not establish a Rust refinement or proof-system
soundness.

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
The selected owned profile separately computes its evidence root from the
actual full packet, including metadata, signature and proof bytes. Canonical
root encodings and cryptographic binding remain concrete-profile work.

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

#print axioms HomotopicalEncryption.Protocol.Ledger.ResourceFlow.value_apply
#print axioms HomotopicalEncryption.Protocol.Ledger.Candidate.not_valid_replay
#print axioms HomotopicalEncryption.Protocol.Ledger.AcceptedUpdate.deterministic
#print axioms HomotopicalEncryption.Protocol.Ledger.Execution.value_preserved
#print axioms HomotopicalEncryption.Protocol.Ledger.Execution.spent_monotone
#print axioms HomotopicalEncryption.Protocol.Evidence.Transition.valid
#print axioms HomotopicalEncryption.Protocol.Evidence.Transition.toAcceptedUpdate
#print axioms HomotopicalEncryption.Protocol.Ledger.CertifiedTransition.toAcceptedUpdate
#print axioms HomotopicalEncryption.Protocol.Ledger.EvidenceExamples.certified_positive_value
#print axioms HomotopicalEncryption.Protocol.Ledger.EvidenceExamples.valid_other_block_old_envelope_rejected
#print axioms HomotopicalEncryption.Protocol.Ledger.EvidenceExamples.valid_other_block_old_quorum_rejected
#print axioms HomotopicalEncryption.Protocol.Ledger.SnapshotModel.ofSheaf_accepts_decoded_isOneCocycle
```

The release record (archived reference: `archive/documentation/PUBLIC_REVIEW.md`) distinguishes completed checks
from reproducible commands and records the actual axiom report. Even an
endpoint using only standard Lean logical axioms retains its explicit
profile and verification hypotheses.

The Paper 2 scope (archived reference: `archive/documentation/papers/paper2/SCOPE.md`) and
protocol parity queue (archived reference: `archive/documentation/docs/PROTOCOL_PARITY_QUEUE.md`) distinguish this
bounded kernel from the remaining protocol and implementation work.
