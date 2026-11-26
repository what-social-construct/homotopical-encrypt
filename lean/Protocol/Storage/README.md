# Sheaf-storage mathematical core

This layer keeps one original sheaf interpretation, snapshot and cochain
artifact throughout an incremental projection run. Mathematical states and
gate certificates remain the existing objects. Typed manifests authenticate
and retain those objects; storage roots and persistence receipts do not
construct their proofs.

The validation guide (archived reference: `archive/documentation/docs/MATH_STORAGE_VALIDATION.md`) records the
current full/default builds, exact selected dependency reports and source
scan, separately from earlier milestones. The canonical arithmetic certificates
now use kernel proofs; explicit theorem/profile hypotheses remain.
The public-view API is checked separately from its
uninstantiated cryptographic and runtime contracts.

The new [HCP realization adapters](../../TCB/HCPRealization.lean) identify the
actual cellular operator, snapshot classifier and original bound Hodge sample
with the semantic operative target; their CVP agreement is derived.
The [concrete family adapter](../../TCB/HCPAxisFamily.lean) instantiates that
operator alignment and retains supplied original-artifact contracts.
The fixed-`F` storage core continues to reuse `BoundHCPObservation` through
`ofHCPObservation`; storage roots and receipts supply no new hiding or key
migration theorem.

The first [public-input profile](PublicView.lean) releases the original payload
and its derived context key. A retained manifest publishes its actual root and
ordered slot/digest directory. An explicitly named HCP disclosure adds the same
bound sample's `(class,b)` pair; it is not read out of the residue payload.
Private interpretations and checkpoint witnesses stay outside these typed
projections. Public roots, tags and any released proof/opening extensions still
belong in the chosen security view; this API proves no cryptographic hiding.

The [coupled cellular family](../../Sheaf/HCPCoupledFamily.lean) fits the existing
`Context F`: its integer restriction matrix couples several edge stalks through
shared face equations. The matrix determines the standard stalk lattices and
Euclidean metric of this profile. [CoupledCodec](CoupledCodec.lean) gives its
dimensions and signed integer entries canonical, versioned bytes;
[CoupledBinding](CoupledBinding.lean) checks those bytes against the original
snapshot root. Accepted substitution yields the same presentation or an actual
byte-hash collision. This is an optional concrete snapshot profile, with the
remaining envelope/authentication contracts retained. Its preimage is private
presentation material; publishing the bytes reveals the matrix, and a content
hash alone supplies no hiding theorem.

[HCPCoupledEncoding](../../Sheaf/HCPCoupledEncoding.lean) supplies an integral
profile of the original full Hodge sample, with observation
`(a,z-Bᵀu,Bz+u)`. [CoupledCiphertext](CoupledCiphertext.lean) gives those same
coordinates canonical bytes and proves that decoding recovers the original
full observed cochain. Its byte-hash check and binding are indexed by the
existing `BoundHCPObservation`; the ciphertext digest stays distinct from the
exact-component artifact digest. This does not serialize the unrestricted
real carrier. Concrete transaction/proximity proofs must explicitly consume
the full-observation relation when they need the harmonic graph.

The exact native path now uses a held derived rational map through
[NativeTransport](../Ephemeral/NativeTransport.lean). It checks canonical
token/ciphertext bytes, the complete original scope and their separate hashes,
then performs rational migration or retained-base coefficient recovery.
Generated integer samples give the target's original canonical bytes.
[NativeDelivery](../Ephemeral/NativeDelivery.lean) specializes the existing
`ScopedDelivery` receipt to that material and derives its context names from
the original source and target contexts. [Retrieval.Native](Retrieval/Native.lean)
joins this execution to hash-indexed lookup and the original bound samples.

[CiphertextManifest](CiphertextManifest.lean) constructs the canonical raw
two-slot seal containing the original exact artifact and separately hashed
full-ciphertext bytes. Every seal fixes its ordered items, public view and
ciphertext naming; malformed bytes remain representable. The separate
`BindsOriginal` certificate in [NativeManifest](NativeManifest.lean) binds
that same seal to the original observation and context.
[NativeAnchored](Retrieval/NativeAnchored.lean) combines that certificate with
the existing `TransitionAnchor`. The bound canonical bytes determine the
original target harmonic message by projection without equating private
opening representatives.

The root function consumes only the public base and ordered slot/digest
directory. A root byte codec, cryptographic binding and history authentication
remain profile work. Availability and canonical issuer-derived token bytes
are explicit recovery premises. The owned signing/checking path uses this
same two-slot root. [Checked native transfer recovery](../Transfer/Native.lean)
then joins the actual packet, candidate and computed history anchor to native
message recovery under its separate certificate and sample-byte premises.
The selected [native proof statement](../Transfer/Certificates/Native.lean)
now instantiates the certificate relation with that existing `BindsOriginal`.
Canonical subject decoding proves its statement reflection; actual acceptance
without the required native binding is a backend false acceptance. Concrete
circuit/CRS refinement and cryptographic soundness remain open.
No relation identifies recovered coefficients with catalogue amounts or
action semantics. Storage-classifier alignment, private authorization and
efficient PIR remain open.

## Module map

| Module | Content and boundary |
|---|---|
| [Context](Context.lean) | One immutable `Context F` containing the original `CochainPayloadInterpretation F` and `HashedCommittedCochain`. Its key derives the run, snapshot, artifact and parameter names. Shape/snapshot binding is separate from exactness. |
| [Checkpoint](Checkpoint.lean) | Generic dependent slot payloads, object-indexed leaf/list/root relations, ordered append-once manifests, complete sealing, an exact-seal persistence receipt, and a terminal local consumption state. Required-slot presence alone does not establish projection coherence. |
| [Projection](Projection.lean) | Adapters for the existing three projection states and three accumulated gate-evidence levels. Every advancement retains its exact predecessor. A `SealedProjection` requires the exact list generated by one final typed prefix and recovers the original `CertifiedStateBus`. |
| [Calibration](Calibration.lean) | Reads both field coordinates from the original payload and derives a geometric-to-pair comparison from controlled exact lifts. The codec/lift bound remains an explicit application obligation. |
| [HCP](HCP.lean) | Builds a context from the original `BoundHCPObservation`, retaining its exact artifact and snapshot. The run name is derived from the actual lifecycle context through the supplied identification function. |
| [CoupledCodec](CoupledCodec.lean), [CoupledBinding](CoupledBinding.lean) | Optional integral graph-family profile. Canonical dimensioned matrix bytes, executable parsing, roundtrip/injectivity and malformed-input rejection; a root check identifies the original matrix packet or an actual byte collision. The existing context and exact-payload/full-cochain distinction are retained. |
| [CoupledCiphertext](CoupledCiphertext.lean) | Concrete integral full-cochain codec, exact original-sample reconstruction and hash checks. Its bound-observation relation retains the same exact artifact, snapshot and lifecycle with a separately named ciphertext digest. |
| [CiphertextManifest](CiphertextManifest.lean) | The canonical raw exact-artifact/full-ciphertext profile over the existing checkpoint engine. Every seal derives its exact ordered leaves, public view and ciphertext naming. Its public root preimage excludes its own root and private witnesses; raw sealing does not establish decoding or native validity. |
| [NativeManifest](NativeManifest.lean) | Reuses the same raw scheme/seal and adds `BindsOriginal`, certifying the original observation/context and full-ciphertext decoder equation. Canonical sample bytes discharge this certificate under the actual sample equation. No second manifest profile is introduced. |
| [CoupledCiphertext/Disclosure](CoupledCiphertext/Disclosure.lean) | At a fixed coupled presentation, full canonical sample bytes determine the message even while openings vary, whereas the exact component alone cannot determine distinct messages or full ciphertexts. This explains the separate ciphertext commitment; unequal byte hashes or computational secrecy are not inferred. |
| [CoupledCiphertext/Layout](CoupledCiphertext/Layout.lean) | Executable exact/information/parity reindexing shared by integer ciphertexts and rational transport matrices; matrix action commutes with the coordinate conversion. |
| [TransportCodec](TransportCodec.lean), [ScopeCodec](../Ephemeral/ScopeCodec.lean), [TransportToken](../Ephemeral/TransportToken.lean) | Canonical reduced rational matrix and original scope bytes, physical dimensions, executable parsers and injectivity/rejection theorems. Token checking requires the actual complete scope and token-byte hash. Omitting source/target matrices as fields gives no key-hiding guarantee for the derived map. |
| [NativeTransport](../Ephemeral/NativeTransport.lean), [NativeDelivery](../Ephemeral/NativeDelivery.lean) | Held-token exact byte migration and retained-base recovery; the existing material-indexed receipt retains actual contexts, recipient, epochs, authorization and exact-token delivery relations. Protected envelope algorithms remain open. |
| [PublicView](PublicView.lean) | Original-payload/header release, actual sealed-root/slot-digest directory, and separately named same-sample HCP disclosure. Proves equal-view criteria, directory order/uniqueness and sensitivity to changed snapshot/run/parameter names. It is a semantic value projection; bytes, access control and hiding require separate contracts. |
| [DisclosureLeak](DisclosureLeak.lean) | For the canonical face-free systematic sheaf, an explicit full HCP cochain together with the same exact payload recovers the harmonic message. A public-layout expression requires decoder agreement on that artifact; the base view omits the full cochain. |
| [Anchor](Anchor.lean) | Joins existing candidate evidence to the same interpretation, original artifact and exact sealed manifest. Derives context acceptance, snapshot/root and payload inclusion facts. A supplied object-indexed history relation authenticates that manifest through the candidate's block digest; quorum and exact persistence-receipt adapters retain the same objects. |
| [ProjectionAnchor](ProjectionAnchor.lean) | Specializes the history join to the actual `SealedProjection`, authenticates its exact final-prefix leaves and separately includes the actual gate database under the proposal evidence root. Recovers the original RS word/certified bus and retains the original conditional far theorem. |
| [CanonicalRS](CanonicalRS.lean) | Optional canonical application adapter. Joins the existing public observation by equality of its entire original artifact, identifies the legacy real-infimum pair distance with the attained generic minimum, and transports the controlled-lift comparison to that actual extracted pair. Existing `BridgeData` and its bound inputs remain explicit. |
| [DistanceReflection](DistanceReflection.lean), [CoordinateCodec](CoordinateCodec.lean) | Zero-locus reflection plus a decoder bound implies a coarse geometric comparison. The complete coordinate layout proves that the decoder and pair extraction read the same original payload. |
| [NoWrapCalibration](NoWrapCalibration.lean), [CanonicalSystematic](CanonicalSystematic.lean) | Constructed systematic cellular sheaf, original canonical payload codec and integer-syndrome no-wrap comparison. Its positive Euclidean family is checked, but the coarse bound does not reach the capacity radius. |
| [ThreeLevelMetrics](ThreeLevelMetrics.lean), [CanonicalThreeLevel](CanonicalThreeLevel.lean) | Intrinsic modular validity via an integral cellular coboundary and carry; global native metric comparison and original canonical payload attaining `3/4` at all three levels. Canonical-mix goodness is for the declared diagonal family. |
| [CanonicalCalibration](CanonicalCalibration.lean) | Composes the existing source/plane/RS calibration contracts on original storage contexts. Far transfer has unit scale; the near contract uses `2*d_C`, and the factor two is sharp. |
| [Core](Core.lean) | Aggregates `Context`, `Checkpoint`, `Projection`, `Calibration`, `HCP`, `PublicView`, the raw `CiphertextManifest`, `Anchor`, `ProjectionAnchor` and `CoordinateCodec`. Import `CanonicalRS` for the fixed canonical application or `Retrieval` for the optional query/read profiles. The separate transition kernel is [Protocol.Core](../Core.lean). |
| [Retrieval](Retrieval.lean) | Optional facade over the native query, authenticated lookup, private recovery and privacy-reference leaves below. It is outside `Storage.Core` and also exported by the broader `Protocol.Storage` facade. |
| [EncryptedCell](EncryptedCell.lean) | Direct SHA-256 index with verified reads of complete encrypted byte records. |
| [CellDirectory](CellDirectory.lean) | Checks canonical cell names against a trusted context and directory root. Verified fragments restrict and glue by their lookups, then resolve cell IDs for whole-record reads. |
| [CellDirectory/Persistence](CellDirectory/Persistence.lean) | Publishes and reopens canonical cell directories and whole ciphertexts on a local filesystem using an independent checkpoint pin. |
| [PublicStack/Manifest](PublicStack/Manifest.lean), [Release](PublicStack/Release.lean), [Restore](PublicStack/Restore.lean) | One independently authenticated root names the cell directory, public snapshot descriptor, original cochain and vote target. Restore verifies each referenced object and reuses verified local copies. |
| [PublicStack/ProofRelease](PublicStack/ProofRelease.lean), [Replay](PublicStack/Replay.lean) | Archives the actual checked packet with its vote target and cell ID. A restored reader supplies the original prior state and verifier configuration, rechecks the packet against the restored ciphertext, and computes the historical successor. |
| [PublicStack/HistoryIndex](PublicStack/HistoryIndex.lean), [History](PublicStack/History.lean) | A trusted index root binds the ordered archive addresses. Replay starts from one trusted ledger state and carries the checked successor into each following transfer under a fixed profile. |
| [Retrieval/HodgeQuery](Retrieval/HodgeQuery.lean) | Actual harmonic-lattice query samples and exact/coexact `HodgeNoise` aggregation. The public integer-weighted answer is the same full observation as an original encrypted answer; the existing coefficient decoder and CVP comparison apply to it. |
| [Retrieval/ContentAddress](Retrieval/ContentAddress.lean) | Executable client-local slot/digest lookup and hash checks against the existing fixed manifest directory, followed by parsing. Substitution for original content gives equality or an actual hash collision, without global injectivity. |
| [Retrieval/Recovery](Retrieval/Recovery.lean) | Connects accepted byte lookup and full-target decoding to the existing `RecoveryDelivery`; the native theorem retains original `BoundHCPObservation` endpoints through `BoundSampleRotation` and gives source coefficients or collision. |
| [Retrieval/Coupled](Retrieval/Coupled.lean) | Optional concrete coupled specialization. Original-observation-derived contexts, actual isometric rotation and scoped delivery combine with the canonical full-ciphertext codec; the decoding premise is proved, giving original coefficients or an accepted byte collision. |
| [Retrieval/Native](Retrieval/Native.lean) | Optional exact native path using the held token and explicit private source decoder. Original observations derive the contexts and retain the selected source message and target byte binding; canonical original token bytes and named available ciphertexts yield original coefficients or a byte collision. |
| [Retrieval/NativeAnchored](Retrieval/NativeAnchored.lean) | Derives naming from the actual raw seal, uses its separate native certificate to identify the target message by harmonic projection, and combines recovery/collision with the existing `TransitionAnchor` over the same context and manifest. It associates the ciphertext with an accepted history entry without interpreting coefficients as ledger amounts/actions. |
| [Transfer/Native](../Transfer/Native.lean) | The actual checked owned packet names this same manifest root. Its computed history anchor and native certificate give original-message recovery or an accepted ciphertext-hash collision, retaining the actual context and artifact. |
| [Transfer/Certificates/Native](../Transfer/Certificates/Native.lean) | Constructs the intended native byte statement from the same raw configuration and existing `BindsOriginal`. Public family bytes contain only version/dimensions. Missing native binding, including malformed ciphertext, after actual checking yields backend false acceptance; no Boolean verifier soundness is assumed. |
| [Transfer/Certificates/Projection](../Transfer/Certificates/Projection.lean) | Retains the actual mathematical record/certificate and chosen metric data. The preferred `boundConfig` checks all seven leaf digests/root against its actual database; acceptance derives `DatabaseBound` for that parsed bundle and record. Hard/naturality/final checks require the immutable bundle's first five/six/seven entries, and failed prior checks reject later acceptance. Actual chain/cochain input and final rational calibration realization remain in the intended meaning. |
| [Retrieval/UniformRead](Retrieval/UniformRead.lean) | Downloads the whole fixed public bucket before local selection/checking/recovery. The complete declared server view and its distribution are target-independent under one shared PMF, at linear download cost. |
| [Retrieval/LinearQueryObstruction](Retrieval/LinearQueryObstruction.lean) | Conditional public essential-column test for a joint one-hot query, with an example using varying coexact openings in the original cellular family and the existing CVP comparison. It does not decide every native query profile's privacy. |
| [Examples](Examples.lean) | A concrete two-coordinate sheaf with zero `delta0`, a nonexact raw `[1,0]` input, accepted zero, two actual payload/plane slots, and positive/negative lifecycle fixtures. Authentication and backend receipt relations are explicitly toy equality models. |
| [AnchorExamples](AnchorExamples.lean) | Integrates that actual sheaf/context/manifest with a positive conservative transfer, candidate evidence and a matching singleton quorum. Exercises mismatched run/snapshot and persisted-nonexact-context rejection under explicit fixture authentication relations. |

## Harmonic-lattice recovery and optional query evaluation

The primary native object is a Hodge-encrypted harmonic-lattice cochain.
Hash-indexed lookup returns its named bytes and recipient recovery uses the
same original bound sample. `HodgeQuery` is an optional encrypted linear
evaluation application; it does not define that lattice or the storage
commitment. A later FHE comparison should inventory the operations actually
proved for these ciphertexts and their separate security conditions.

The hash-addressed native path is
`canonical full ciphertext → digest/directory → checked local lookup → full-cochain decoder → scoped private recovery`.
[Retrieval.Native](Retrieval/Native.lean) supplies executable rational recovery
with a held token. [NativeAnchored](Retrieval/NativeAnchored.lean) derives the
directory from the canonical raw seal and composes its separate native
certificate with the same-context history anchor; the older generic function
still accepts a supplied view. [Transfer.Native](../Transfer/Native.lean)
connects that result to the actual checked owned packet and signed root.
[Retrieval.Coupled](Retrieval/Coupled.lean) retains the earlier isometric-receipt
specialization. The hash names and binds
the ciphertext; the material-indexed receipt supplies the original scope and
delivery contracts. A concrete protected envelope and delivery algorithm
remain open.
The older hash-of-shared-secret fiber-selection plan also needs actual
shared-secret agreement and a finite representative generator. Public context
identifiers and ciphertext hashes are not those private seeds.

The native token is reusable for its context/profile rather than inherently
single-use or restricted to one ciphertext. The selected full-ciphertext
digest is checked separately from `ContextKey.cochainDigest`, which still
names the exact artifact. Scope equality does not authenticate a caller or
prevent replay; possession of copied matrix data permits off-API use. The
derived matrix may reveal private presentation information. Token checks
therefore establish neither hiding nor a safely public evaluation capability.
The rational determinant/adjugate code is a finite reference implementation
without a polynomial runtime bound.

`HodgeQuery` is the native evaluation construction: the client supplies the
existing harmonic presentation and structured openings, while the server sums
only observed cochains with public integer weights. `answer_eq_observed`
retains the full encrypted answer, rather than just its harmonic projection.
`decode_answer` and `cvp_answer_iff` reuse the original recovery/CVP laws.
The hidden-operator comparison in [Hardness](../../Hardness.lean) keeps its
declared public-input and uniform-solver quantifiers. Selector privacy for a
whole query additionally needs a specified joint sampler/view.

[EncryptedCell](EncryptedCell.lean) stores one complete encrypted record
under the SHA-256 digest of its bytes. The reference hash table fetches by
that digest, then hashes the returned object before passing it to the
recipient. Lean proves read-after-insert and the equality-or-collision
alternative for a trusted address. The [demo](EncryptedCell/Demo.lean)
uses two canonical full ciphertexts as its stored records.

[CellDirectory](CellDirectory.lean) checks the complete context key and
ordered natural-number cell IDs against a trusted SHA-256 directory root.
It rejects duplicate IDs and checks the full directory once. A
[fragment](CellDirectory/Patch.lean) checks each of its entries against that
directory. Restriction drops entries outside a patch, and the glued lookup
is unique on the union. This follows the overlap condition in
[Ghrist–Hiraoka, Proposition 13](https://www2.math.upenn.edu/~ghrist/preprints/networkcodingshort.pdf).
Two directories verified independently at the same context and root agree
on any shared cell, or supply distinct canonical directory bytes with equal
SHA-256. The reader resolves the cell ID through a checked fragment and
fetches one entire ciphertext by its resolved digest.

[CheckpointPin](CellDirectory/Checkpoint.lean) pairs the full context key
with the directory root. An accepted transition anchor can supply that pin
when its seal root is the SHA-256 digest of its canonical cell directory.
The [local store](CellDirectory/Persistence.lean) names immutable ciphertext
and directory files by their digests. A writer checks every referenced
ciphertext before atomically replacing the checkpoint file. A fresh reader
takes its expected pin independently, checks the checkpoint bytes and
directory, and hashes each selected ciphertext before returning it. This
reference covers process restarts on a local POSIX filesystem. Power-loss
durability requires filesystem synchronization beyond a buffered flush.

Run the [restart demo](CellDirectory/Persistence/Demo.lean) from `lean/`.
The read phase temporarily changes the fixture files to test rejection.

```sh
lake build Protocol.Storage.CellDirectory.Persistence
store="$(mktemp -d)/store"
lake env lean --run Protocol/Storage/CellDirectory/Persistence/Demo.lean write "$store"
lake env lean --run Protocol/Storage/CellDirectory/Persistence/Demo.lean read "$store"
```

A [public stack manifest](PublicStack/Manifest.lean) adds three fixed public
roles to the cell directory. The [release profile](PublicStack/Release.lean)
takes the public snapshot descriptor and original cochain from the storage
context. Its evidence entry encodes the accepted proposal and verdict as a
vote target. `Release.ofAnchor` ties those bytes and the directory to the
actual accepted transition. The authority passes the resulting stack root
independently, in its own domain from the proposal's block digest.

[Restore](PublicStack/Restore.lean) verifies the manifest and directory before
following their links. It reuses verified destination objects and requests
only missing or corrupt digests, once per address. It sets the active stack
pointer after every referenced byte object verifies. A rejected restore leaves
the former pointer in place, so a retry can reuse objects already copied.
The [demo](PublicStack/Demo.lean) restores a partial replica and reopens it
in a fresh process.

```sh
lake build Protocol.Storage.PublicStack.Restore Protocol.Storage.PublicStack.Release
stack_demo="$(mktemp -d)/stack"
lake env lean --run Protocol/Storage/PublicStack/Demo.lean restore "$stack_demo"
lake env lean --run Protocol/Storage/PublicStack/Demo.lean read "$stack_demo"
```

The [proof-packet release](PublicStack/ProofRelease.lean) names the original
checked packet, its proposal and verdict, and the cell holding its complete
ciphertext in one evidence object. [Replay](PublicStack/Replay.lean) checks the
restored snapshot and cochain, uses the selected cell bytes to reconstruct the
signed transfer manifest, and reruns the configured owner and payload checks
from the trusted historical before-state. It compares the recomputed vote
target and returns the resulting historical successor as a value.

```sh
lake build Protocol.Storage.PublicStack.ProofDemo
proof_demo="$(mktemp -d)/stack"
lake env lean --run Protocol/Storage/PublicStack/ProofDemo.lean write "$proof_demo"
lake env lean --run Protocol/Storage/PublicStack/ProofDemo.lean verify "$proof_demo"
```

The [history index](PublicStack/HistoryIndex.lean) canonically encodes the
ordered roots of the archived stacks. Given the trusted index root and
initial ledger state, [history replay](PublicStack/History.lean) opens each
named stack in the shared object store and checks its packet against the
previous computed successor. The checker reconstructs the parent, source
evidence root, and before-state binding. Replay returns the final historical
state after every link checks under the fixed context and verifier profile.

```sh
lake build Protocol.Storage.PublicStack.HistoryDemo
history_demo="$(mktemp -d)/history"
lake env lean --run Protocol/Storage/PublicStack/HistoryDemo.lean write "$history_demo"
lake env lean --run Protocol/Storage/PublicStack/HistoryDemo.lean verify "$history_demo"
```

`UniformRead` supplies a complete lower-efficiency privacy reference within
one fixed public bucket. It returns all labelled ciphertext bytes, with payload
volume equal to their summed lengths and separate serialization overhead.
The chosen hash, lookup result, recovery scope and failures remain local;
selected requests, authorization metadata or retries extend the transcript.
`LinearQueryObstruction` records explicit redundancy/projection hypotheses
under which a joint view reveals its selector, without claiming that all HCP
samplers satisfy them or that efficient native retrieval is impossible.

Direct remote lookup exposes the requested address. The fixed-bucket
profile downloads every record and lets the client select locally.
The caller supplies pin authentication. Availability, private delivery,
and efficient private querying retain separate contracts. The
[Paper 2 account](../../../papers/paper2/DRAFT.md#67-retrieval-and-selector-privacy)
and implementation map (archived reference: `archive/documentation/docs/PROTOCOL_PARITY_QUEUE.md`)
record those boundaries.

## Raw inputs and exact acceptance

`Context` retains the same `CochainCommitmentData` through its original
artifact. It requires wire well-formedness and `BoundToSnapshot`, including
the declared coordinate count and topology tag. It does not require an exact
opening. This leaves noisy or invalid inputs available for a proximity
question.

`Context.Accepted` is the existing `AcceptedCommittedOneCochain` predicate:
the decoded cochain is an actual `delta0` image in the fixed interpretation.
The new [exact-subspace distance](../../Sheaf/Distance.lean) proves

```text
Context.Accepted C  ↔  C.decodedDistance = 0.
```

`Projection.Input` additionally joins the existing chain's actual payload to
this context and supplies `CochainSemantics` relating its legacy coherence
interface to the concrete sheaf interpretation. Similar names alone do not
identify those semantic predicates.

## The six retained levels

The projection prefix uses these exact existing types:

| Manifest stage | Payload | Retained predecessor |
|---|---|---|
| `cochain` | `PluckerCochainState Γ W` | The original committed-cochain construction. |
| `plane` | `CochainPlaneState Γ W` | Its exact preceding cochain state. |
| `rs` | `StateBus Γ W` | Its exact preceding plane state. |
| `hard` | `HardGateEvidenceRecord runtime Γ` | The accumulated mathematical hard-gate certificate, attached while retaining the RS state. |
| `naturality` | `NaturalityGateEvidenceRecord runtime Γ` | Its exact `hardGateRecord`. |
| `final` | `CalibratedFinalEvidenceRecord runtime Γ κ` | Its exact naturality record and supplied far-region witness. |

The projection states are defined in
[Gates/Stage](../../Proximity/Concrete/Gates/Stage.lean); the accumulated
records are in [GateEvidence](../../Proximity/Concrete/GateEvidence.lean).
`Prefix.Step` checks predecessor equality and appends one leaf while
preserving the earlier list. `SealedProjection.itemsMatch` requires the
sealed list to be that of one final prefix, rather than merely finding all
six stage labels somewhere in a manifest. Its `target_far` theorem consumes
the existing final far-region proof.

## Distinct names and roots

All 32-byte values reuse `TCB.Hash32`, but their roles remain different.

| Name | Meaning |
|---|---|
| `Context.key.runId` | The projection lifecycle name. Its global freshness and the injectivity/security of a lifecycle identification function are separate obligations. |
| `Context.key.snapshotRoot` | The original immutable cellular-sheaf snapshot root. |
| `Context.key.cochainDigest` | The original public cochain artifact's leaf digest. |
| Retrieval ciphertext digest | A directory-listed hash of named encrypted bytes. `CiphertextManifest` derives naming from its raw seal; `NativeManifest.BindsOriginal` separately supplies the decoder/original-observation binding consumed by `NativeAnchored` and `Transfer.Native`. The exact-component `cochainDigest` alone does not supply this binding. |
| `Context.key.topologyTag` | The existing **16-byte** declared topology tag; it is not a 32-byte root. |
| `Context.key.parameterSet` | The selected parameter-profile identifier. |
| `Context.key.schemaVersion` | The schema version inherited from the original snapshot. |
| `PlaneView.storageRoot` | The enclosing public compressed-stack anchor. The canonical adapter separately joins the observation's original cochain leaf to the context. |
| `GateEvidence.EvidenceDatabase.rootDigest` | The existing gate-evidence root over **seven slots**: five hard-gate slots, naturality and the final far-region witness. The selected `Certificates.Projection.boundConfig` checks it against the computed canonical directory of all seven subject/proof leaf hashes; successful verification levels still require only their five/six/seven-entry prefixes. |
| `SealedManifest.root` | The surrounding manifest root. The projection profile has **six stage leaves** retaining accumulated gates; the native ciphertext profile has **two leaves**, exact artifact and full ciphertext. Each root belongs to its actual ordered list and context; it is not automatically the seven-slot evidence root, stack root, snapshot root or cochain leaf. |

The checkpoint scheme's binding relations receive the actual context,
typed payload/digest leaves, ordered list and root. Concrete encodings must
specify how those distinct names and objects are authenticated. A semantic
payload may retain private witness data for proofs; its public serialization
is a separate selected view.

## Native chain distances and upstream geometry

For the declared systematic modular profile, the three native distances are
measured before taking each subsequent projection:

| Distance | Native edits and valid locus |
|---|---|
| `d_C` | Integer cochain scalar-coordinate edits, normalized by `2n`; validity is an actual integral cellular coboundary modulo a `q`-carry. |
| `d_P` | Integer-plane whole-pair edits, normalized by `n`, to the same modular valid locus. |
| `D_RS` | Finite-field whole-pair edits, normalized by `n`, to the interleaved RS code. |

[ThreeLevelMetrics](ThreeLevelMetrics.lean) proves
`d_C ≤ d_P = D_RS ≤ 2d_C`. The source validity predicate is defined through
the cellular coboundary, then proved equivalent to code membership.
The global equality uses congruence-saturation and lifts that preserve each
already matching pair. It does not define the source distance as a pullback.
[CanonicalThreeLevel](CanonicalThreeLevel.lean) supplies an original
snapshot-bound payload with all three distances `3/4`. Its diagonal challenge
family has exact bad set `{-1}`. Arbitrary fixed nonzero challenge compression
cannot preserve a positive far radius for all pairs.

Real `Context.Accepted` and modular validity are distinct predicates.
[CanonicalSystematic](CanonicalSystematic.lean) relates them under the
integer-syndrome no-wrap hypothesis. Real acceptance implies modular validity
under the stated decoder contract; the converse needs that hypothesis.
Accepted contexts therefore have native distance zero. The positive-far
payloads are raw proximity/rejection inputs, not accepted-far gates.

The storage layer also retains these upstream quantities:

| Quantity | Source and meaning |
|---|---|
| `Context.decodedDistance` | Euclidean distance of the decoded stored payload to the real exact-cochain subspace `im delta0`. Its valid locus is concrete exact-payload acceptance. |
| Full HCP residual | The existing `‖kernelNormalizedDegreeOneLaplacian E.observed‖` of the full `HodgeEncryptedCochain`. The full observation includes harmonic message and exact/coexact noise; its serialized exact component is a different object. |
| Pair-code distance | Minimum relative whole-pair Hamming distance after extracting and reducing both coordinates of the same payload. The generic minimum and closed-nearness semantics are in [Core/Distance](../../Proximity/Core/Distance.lean). |

`ofHCPObservation` reuses an already accepted exact component, whose
`decodedDistance` is therefore zero. That fact does not determine the full
HCP residual. [ObservationQuotient](../../Sheaf/ObservationQuotient.lean)
uses the original Hodge sample carrier: with a nonzero coexact direction,
an unrestricted ray has constant zero exact component and unbounded full
residual. An extraction depending only on that component cannot preserve a
positive far region for every such sample when its zero image has target
distance zero. Restricted or authenticated noise profiles retain their own
comparison obligations.

For an independently decoded source, `Calibration.LiftControl` supplies a
family of actual exact cochains indexed by **every target codeword**, with
a decoding-error bound given by a scale times its Hamming distance. The nearest target
codeword and the exact-subspace projection bound then prove

```text
decodedDistance C ≤ scale * pairDistance(extractedPair C).
sourceRadius ≤ decodedDistance C
  ⇒ sourceRadius / scale ≤ pairDistance(extractedPair C),   when scale > 0.
```

This older controlled-lift interface derives a source comparison from its
explicit lifting/error data. The new no-wrap and native-metric profiles above
provide separate constructed comparisons; storage roots alone supply none
of these mathematical inputs. The module also proves
that a nonexact source extracting to a target codeword obstructs any such
lift control.

`CanonicalRS.Observation` joins the whole observed public artifact to
`C.artifact`, not just an independently supplied digest. It proves that the
canonical pair is the reduction of `C.cochain` and retains the already-proved
public pullback calibration. Its independent geometric comparison requires
the selected controlled lifts; a pullback definition or a storage receipt
does not discharge that profile input.

`Projection.target_far` uses the existing chain's `sourceDisagreement W`.
Applying the decoded-distance comparison to that gate additionally requires
identifying its source score and supplying a family of controls with the
declared uniform scale. Neither the pointwise lifting theorem nor the native metric profile makes
that identification for arbitrary legacy HCP/frame objects.

Artifact equality identifies the original cochain. It does not identify
`PlaneView.storageRoot` with `SealedManifest.root`; the surrounding manifest
inclusion/common-root relations still need their selected profile bindings.

## Accepted history and its exact retained manifest

`TransitionAnchor` starts with the existing `Evidence.Transition`. Its
snapshot policy must be the existing `SnapshotModel.ofSheaf F`, its candidate
snapshot must equal the context's interpretation, and the proof's whole public
artifact must equal the context's original artifact. From these facts it
derives the candidate-payload equality, `Context.Accepted`, snapshot-root
equality and the existing cochain/evidence inclusions. Acceptance is not an
independent extra proof field. In particular, the accepted context's decoded
exactness distance is zero.

The history profile separately supplies `manifestIncluded` on the actual
candidate, context, exact ordered leaf list, manifest root and block digest.
This is the missing semantic join between the existing transition and seal;
it does not choose a new proposal coordinate or implement a hash function.
`ProjectionAnchor` requires the actual coherent `SealedProjection` and an
inclusion relation for its actual gate database under the same candidate's
evidence root. Generic sealing alone does not establish those projection
joins. A matching `CertifiedTransition` signs the same block digest and
snapshot coordinate. Persistence still requires the exact manifest receipt.

The certificate profile supplies canonical subject/proof/directory preimages
and compares their computed digests with the actual retained database. Hash
security, authenticated history inclusion, other public/private serializations,
availability and global freshness remain profile/runtime obligations. Each
preimage excludes its own digest fields. This
fixed-`F` adapter does not implement geometry changes or key rotation.

## Local lifecycle and runtime boundary

`OpenManifest.append` checks slot freshness and preserves insertion order.
Sealing fixes the exact complete manifest and its root. Sealing and
persistence are separate: `Checkpoint.Step.consume` needs a
`PersistenceReceipt` indexed by that exact sealed context/list/root.
A consumed checkpoint has no outgoing step and remains fixed throughout a
connected execution.

These are local lifecycle theorems. They do not establish a global registry
of fresh run identifiers, exclusive ownership across forks/processes,
unclonability, consensus finality, backend durability or physical erasure.
The backend relation and receipt verifier need a concrete implementation and
refinement proof. Consumed Lean states retain semantic audit evidence; a
runtime retirement/wipe policy must specify its public retained data and
private erasure behavior separately.

The fixture proves real payload/plane joins and local rejection properties.
Its positive decoded-distance input is not a source-to-RS radius theorem,
and its equality receipt is not a claim that a disk write occurred.

## Reproduce checks

From `lean/`, the focused commands are:

```sh
lake build Protocol.Storage.Core Protocol.Storage.Examples
lake build Protocol.Storage.AnchorExamples
lake build Protocol.Storage.CanonicalRS Sheaf.ObservationQuotient
lake build Protocol.Storage.Retrieval
lake build Protocol.Storage.EncryptedCell.Demo
lake env lean --run Protocol/Storage/EncryptedCell/Demo.lean
lake build Protocol.Storage.CellDirectory.Demo
lake env lean --run Protocol/Storage/CellDirectory/Demo.lean
```

These commands describe validation targets; consult the shared parity record
for the actual current results and theorem-axiom reports. The
Paper 2 scope (archived reference: `archive/documentation/papers/paper2/SCOPE.md`),
cochain trace (archived reference: `archive/documentation/docs/COCHAIN_PROXIMITY_TRACE.md`) and
[Paper 3 register](../../../papers/paper3/SEMANTIC_PARITY.md)
retain the separate protocol, profile and radius obligations.
