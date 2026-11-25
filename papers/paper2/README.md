# Paper 2 source: Proof-Carrying Homotopical Encryption

Working combined title: *Homotopical Encryption and Proof-Carrying Transactions*.

The motivating question is recovery with hidden operative harmonic-lattice
geometry, beyond CVP with a supplied basis. The manuscript's
[CVP/LWE/HCP comparison](sections/recovery-comparison.tex) states the actual
public inputs, recovery targets, noise models and proved/open comparisons.
The construction gives an explicit encryption/recovery mechanism in which
to study that question; computationally greater hardness remains a theorem
to establish in a specified model.

The [working manuscript](DRAFT.md) develops cochain encryption and verification
with changes of cellular presentation that preserve messages. Its coupled
family has an explicit intrinsic harmonic lattice; separate cochain and ciphertext maps
preserve the declared semantic class and original message coefficients.
The exact-component artifact can remain fixed while the full encrypted
cochain changes, so the canonical manifest names both objects. Its root enters
owner authorization, packet verification and accepted history. A separate
native observation-binding refinement connects the ciphertext bytes to the
original harmonic message used in recovery. Exact-payload proof checking and
full-observation binding remain distinct obligations. For a bounded native
credential, the manuscript also gives an adaptive CRS reference reduction
with the full ciphertext actually released to the adversary. It bounds fresh
forgery by transcript simulation error, extraction failure, recovery of the
original coefficients and two byte-hash collision events; all primitive
algorithms and quantitative security estimates remain explicit inputs.
The [matching coupled-construction TeX section](sections/coupled-construction.tex)
states the proved class/lattice/cochain connection; the full Markdown draft
has no TeX/PDF bundle yet. The
[bibliography](references.bib) records relevant sources; the
[shared parity register](../../SEMANTIC-PARITY.md) maps objects and statements
to their canonical Lean declarations.

## Current construction

The [coupled family](../../lean/Sheaf/HCPCoupledFamily.lean) uses shared integer
face equations `y=B x`. Its intrinsic harmonic lattice consists exactly of
`(0,z,Bz)`: these messages are already cochains. Exact/coexact Hodge noise
produces the original encrypted cochain. A constructed
[strict cochain isomorphism](../../lean/HCP/CoupledSemantics.lean) proves typed
Helfer equivalence and public homological-class preservation across same-size
matrices, and an explicit harmonic-lattice equivalence preserves their integer
message coefficients. The generally nonisometric shear does not transport
Hodge noise; protocol rotations retain their actual isometry requirement.
The same file joins the actual Hodge matrix to the HCP operative projector.

The [lattice construction](../../lean/HCP/CoupledLattice.lean) identifies
integer coefficients with the entire original intrinsic harmonic lattice,
constructs its basis and proves rank and discreteness. Its full-lattice
property is inside the harmonic space. The
[decoder refinement](../../lean/HCP/CoupledDecoding.lean) holds on every
rational observation; integer acceptance is exactly the original integer
Hodge-encryption language. The [direct byte algorithm](../../lean/Protocol/Storage/CoupledRecovery.lean)
parses private-key/ciphertext bytes and recovers without a transport token.
The [Lean execution example](../../lean/Protocol/Storage/CoupledRecovery/Demo.lean)
runs those actual algorithms on `(2,-1) → (3,-2,-5,5) → (2,-1)`, and checks
integer-language and malformed-byte rejection. It is a fixed reference
execution, with sampling and cryptographic security handled separately.

The [core geometry diagram](../../lean/HCP/CoupledGeometry.lean) now derives
the full Hodge action and proves that the actual differential or Laplacian
determines the coupling matrix in this fixed profile. It joins coordinate
assembly, harmonic projection and coefficient recovery on all real cochains.
The [manuscript figure](sections/geometry-diagrams.tex) uses two triangles and
a central square, keeping the semantic shear and native ciphertext map
distinct. Private geometry is the source of the cochain space and operators;
the message and its opening then construct a particular observed cochain.
Independent metric, topology, lattice or basis choices require their own
reconstruction data. Account recovery and key-rotation policy are deferred.

The separate [native coordinate transport](../../lean/HCP/CoupledTransport.lean)
is `M_C M_B⁻¹` for the original full observation map `M_B`. It transports
ciphertexts with the same message and opening coordinates for all same-size
matrix pairs, including nonisometric ones. Identity, inverse, composition and
generated-sample integrality are proved. The
[rational reference implementation](../../lean/HCP/CoupledRational.lean)
executes that map and private coefficient recovery by exact arithmetic, with
proved agreement with the original real operators. Its determinant/adjugate
implementation carries no polynomial complexity bound. The proved zero-target
disclosure prevents treating arbitrary public transport as a secrecy claim.

The [canonical integer-matrix codec](../../lean/Protocol/Storage/CoupledCodec.lean)
and [snapshot profile](../../lean/Protocol/Storage/CoupledBinding.lean) name
that same sheaf, standard integral structure and metric. Matrix bytes remain
private in the hidden-operator profile. Hash-indexed recovery of native
harmonic-lattice ciphertexts is the storage path; encrypted linear-query
evaluation is an optional application. A later FHE comparison will specify
the actual supported computations and their security assumptions.

The [integral sample profile](../../lean/Sheaf/HCPCoupledEncoding.lean) and
[full-cochain codec](../../lean/Protocol/Storage/CoupledCiphertext.lean) close
the original-object encoding join: the decoded bytes are exactly the same
Hodge sample's full observation `(a,z-Bᵀu,Bz+u)`. This ciphertext digest is
separate from the exact-component artifact digest. Justified sampler profiles,
secure authentication/proof implementations and quantitative full-view
security remain work.
The [hash-recovery specialization](../../lean/Protocol/Storage/Retrieval/Coupled.lean)
now supplies the actual full-cochain decoder to the existing recipient-scoped
recovery theorem, retaining its original observations, isometric rotation,
private delivery receipt and directory/availability hypotheses.

The selected native path uses the
[held-token byte executor](../../lean/Protocol/Ephemeral/NativeTransport.lean),
[scope/token codecs](../../lean/Protocol/Ephemeral/TransportToken.lean),
[existing scoped-delivery adapter](../../lean/Protocol/Ephemeral/NativeDelivery.lean)
and [native hash retrieval](../../lean/Protocol/Storage/Retrieval/Native.lean).
The receiver uses the held derived map directly; retained-base recovery takes
the private source presentation explicitly. The recipient, epochs and original
contexts determine the scope, and the selected full-ciphertext digest remains
separate from the exact-artifact digest.

One [canonical two-slot manifest](../../lean/Protocol/Storage/CiphertextManifest.lean)
names that exact artifact and the selected full-ciphertext bytes. The raw seal
permits malformed inputs; it records the bytes without assuming their native
meaning. A separate
[original-observation certificate](../../lean/Protocol/Storage/NativeManifest.lean)
relates the same raw seal's context and decoded bytes to the original bound
HCP observation. Canonical sample bytes, the original sample equation and
context equality construct this refinement.

The [actual checked owned-transfer bridge](../../lean/Protocol/Transfer/Native.lean)
retains the same manifest root through its signed intent, packet and computed
history anchor. With the native certificate, canonical held transport token
and available bytes, it identifies the original harmonic message and recovers
its coefficients or exhibits an accepted byte-hash collision. This is the
existing transfer configuration, not an alternate native packet profile.
Exact-payload acceptance alone does not establish the native certificate.

This is a reusable context/profile capability. Scope checks do not authenticate
the caller, prevent replay or cryptographically confine copied map data.
Omitting the source/target matrices as serialized fields gives no key-hiding
guarantee for the derived map. Protected delivery, shared-secret agreement,
justified sampler profiles and security for the complete released view remain open.

The [finite native relation](../../lean/Protocol/Transfer/PathSignature/NativeRelation.lean)
uses the actual bounded private witness `(B,C,z,a,u,salt)`. Canonical witness
and [program/instance codecs](../../lean/Protocol/Transfer/PathSignature/NativeProgram.lean)
retain a salted source credential, raw target-matrix hash and full-ciphertext
digest in the existing reference profile. Accepted witnesses have the actual target sample, harmonic projection
and typed Helfer equivalence; the native `M_C M_B⁻¹` transport preserves their
message and openings. It may be nonisometric and does not instantiate the
separate generic isometric path adapter. Artifact/lifecycle binding still
requires the original native certificates.

The [finite native sampler](../../lean/Protocol/Transfer/PathSignature/NativeSampler.lean)
uses exactly `(2K+1)^(2mn+n+m+1) * 256^ell` seeds with equal mass. Injective
decoding gives bounded private witnesses, and a fixed cryptographic-tape law
is independent of the native seed with both marginals retained. This does
not make public hash keys uniform or distinct and gives no hardness estimate
for a family that includes zero messages and degenerate matrices.

The [original sampler audit](../../lean/Protocol/Transfer/PathSignature/NativeRecovery.lean)
gives exact `7/9` public coefficient recovery in its bound-one scalar profile
for every salt length, and actual-byte recovery of a reused scalar operator
from a known zero message with nonzero noise. This does not itself forge the
complete credential proof. The separate
[fresh-sign candidate](../../lean/Protocol/Transfer/PathSignature/NativeSignSampler.lean)
uses `C=A diag(k)`, `AᵀA=dI`, `z=d sign(message)` and correlated `u=C sign(message)`.
Its canonical ciphertext laws agree for all messages under one fresh uniform
sign key; identity and dense Hadamard examples inhabit the profile. Under an
independent uniform message, [complete-message guessing](../../lean/Protocol/Transfer/PathSignature/NativeSignPrivacy.lean)
has exact success `2^-n`, also with an independent fixed tape or a ciphertext
digest; arbitrary partial integer-coefficient recovery is at most `2^-n`. This ciphertext-only law omits operator roots and signing/storage
views. The [actual-byte candidate test](../../lean/Protocol/Transfer/PathSignature/NativeOperatorGuessing.lean)
checks a plaintext guess against a raw operator hash; a wrong accepted guess
supplies a collision between distinct canonical matrix bytes.

The selected design target is exact harmonic recovery with fresh geometry per
public encrypted object and persistent private master-key management.
Wallet-at-rest and reused-geometry encryption remain separate. The sign
sampler remains a nondefault implementation candidate until actual hiding
operator binding, private openings and a versioned native instance, witness
codec and context joins are built. Existing generic
snapshot carriers remain useful; the cochain hiding flags are not an operator
commitment algorithm. Public content hashes name encrypted material; operator
fingerprints/nullifiers, full projectors/Plücker data and usable public
transport are excluded from the intended private view. The exact artifact must
be message-independent, and auxiliary/proof disclosures still need analysis.
The candidate is not the default storage profile.

The [coexact refresh](../../lean/Protocol/Transfer/PathSignature/NativeNoiseRefresh.lean)
adds the desired-minus-retained target opening and returns the prescribed
canonical target sample. Ordinary transport preserves the old opening and
need not resample the new correlated law. This correction provides neither a
safe public refresh token nor independent key generation or one-use enforcement.

The [CRS reference composition](../../lean/Protocol/Transfer/PathSignature/CRS.lean)
uses supplied actual setup/prove/verify/simulation/extraction functions. A
bounded response-dependent signing interpreter generates its query/answer
log on the complete credential/message bytes. Its
[native security specialization](../../lean/Protocol/Transfer/PathSignature/NativeSecurity.lean)
constructs a full-view experiment that places canonical full ciphertext bytes
in adversary auxiliary input while preserving the remaining auxiliary data,
PMF and execution maps. The five-term conditional bound reduces validated
extraction to original-coefficient recovery or snapshot/ciphertext byte-hash
collisions. Its `WinningHybrid` premise is specific to the actual Boolean
fresh-forgery test; statistical closeness for all transcript sets is only a
stronger sufficient corollary. It supplies no numerical, negligible or polynomial-time bound;
the earlier `(class,b)` HCP obstruction and CVP comparison do not estimate
recovery for this richer view.

An [approved descriptor](../../lean/Protocol/Transfer/Certificates/Profile.lean)
authenticates exact program, verifier-key and public CRS bytes using the
existing full-proposal acceptance quorum. The
[vote authentication adapter](../../lean/Protocol/Transfer/Certificates/ProfileAuthentication.lean)
calls the selected signature verifier on canonical full vote-target bytes.
The [registered owner checker](../../lean/Protocol/Transfer/PathSignature/Registered.lean)
parses those actual objects and checks the original metadata, profile,
parameters, scope, calibration and epoch. Honest completeness requires the
primitive's completeness contract and a matching actual setup output.
Approval authenticates selected bytes rather than establishing their semantic
refinement or secure setup generation.

The [preferred native adapter](../../lean/Protocol/Transfer/PathSignature/NativeRegistered.lean)
also checks the exact expected program bytes and derives the public key from
the existing owner credential, original context snapshot root and actual
full-ciphertext digest. Different approved code rejects independently of its
profile label. Original packet parsing and payload-proof checks are retained;
the concrete byte-owner signing join requires the selected codec explicitly.
The [context adapter](../../lean/Protocol/Transfer/PathSignature/NativeContext.lean)
derives the challenged key from the actual source credential, target snapshot
binding, canonical target sample bytes and selected hash agreement. Parsed
approved key/CRS components must match the actual sampled setup; the same
sample-byte equation identifies the full ciphertext released to the adversary.

The [application adapter](../../lean/Protocol/Transfer/PathSignature/NativeApplication.lean)
selects the program's actual primitive and completes its generated final
target into the original packet. It checks the canonical full signing message
and challenged signer key, uses the target proof as owner signature, and keeps
the separate supplied payload proof and all operational checks. A successful
fresh completion implies a win in that same generated transcript, so its
probability inherits the native five-term bound on the original PMF under
the actual approved-setup parsing equations.
The preferred native-source theorem consumes the actual credential,
snapshot, sample, hash and setup equations together, deriving the selected
owner's challenge-key and released-ciphertext equalities alongside that bound.
Its error budget is the existing five-event sum. This is a single-credential
completion experiment, not a translation of arbitrary packet adversaries or
a bound on every accepted transfer. Policy, compromise and payload failures
remain in general integrity analysis. Other released application data belongs
in the auxiliary remainder; no complete storage-view privacy follows.

The [byte-owner packet codec](../../lean/Protocol/Evidence/TransferCodec.lean)
canonically serializes the existing full packet and intent, retaining raw
malformed semantic values for the checker. It defines a versioned Lean
reference wire profile, without archived Rust compatibility. The
[generated R1CS sample core](../../lean/Protocol/Transfer/PathSignature/NativeCircuit.lean)
has `2mn+n+m+1` constraints and an honest assignment for every integer sample.
The [actual integer range check](../../lean/Protocol/Transfer/PathSignature/NativeCircuitBounds.lean)
and explicit maximum residual/modulus bound discharge no-wrap and recover
the original integer observation. Compiling these integer range checks, salt,
bytes and hashes into the complete field circuit remains open.

The commitment profile retains the original cochain payload, its declared
modulus/count/topology tag, the private cellular/Hodge interpretation and
explicit decoding/binding contracts. An integral cellular source and complete
coordinate codec support the modular cochain, plane-pair and RS views of that
same payload. Raw coboundary openings are identified modulo `ker delta0`;
the modular carry relation remains separate. These are commitment-construction
objects.

The base public storage view releases the original residue payload and its
six-coordinate context key. The retained manifest adds the actual sealed root
and ordered slot/digest directory. A separately declared `HCPDisclosure`
adds the same bound sample's `(class,b)` observation; the residue payload does
not disclose it automatically. Full operative-kernel Plücker coordinates are
outside the base profile. Any released roots, tags, proofs and selective
openings must appear in the chosen adversary view.

For fixed setup, the
[public assembly](../../lean/Protocol/Transfer/PublicAssembly.lean)
reconstructs the released transfer view from four varying inputs: the base
storage view, full-ciphertext digest, owner-signature bytes and proof bytes.
The digest is released in the directory; the view does not automatically
release the corresponding bytes. This factorization is not a confidentiality
claim for those joint inputs.

For the canonical systematic sheaf, releasing both the full cochain and exact
payload recovers the harmonic message when the decoder agrees with the
selected public layout. The draft states this disclosure boundary explicitly.

Actual integral isometric rotation transports harmonic messages and structured noise.
Recipient recovery retains the same integer coefficients through target-key
decoding or inverse transport with the retained base key, under the supplied
encoding and delivery contracts. Hash-indexed lookup and full-bucket retrieval
reuse the original bound ciphertexts; efficient private retrieval remains a
separate construction.

## Conditional transition result

For a fixed catalogue, epoch, snapshot and before-state, one checked transfer
consumes an available owned resource and produces a distinct absent, unspent
resource with the same asset and positive amount. Its public nullifier is the
consumed resource ID. Structural packet checks, owner-signature soundness and
proof soundness for the original trusted payload interpretation derive
candidate validity and the computed state update. Operational acceptance does
not assume that validity in advance.

The evidence/history join retains the same artifact, canonical two-slot input
manifest, intent and complete proposal. Its root names the full ciphertext
alongside the exact artifact. The one-shot integrity experiment reduces
accepted-invalid outcomes to authorization or exact-payload check failures
and composes supplied failure budgets under one shared probability law.

The [public certificate codec](../../lean/Protocol/Transfer/Certificates/Codec.lean)
retains full metadata and the original intent with the ciphertext digest,
public profile, optional rational calibration and claim. Canonical evidence
entries bind these subjects and actual proof bytes under one immutable
seven-slot root. [Bundle checking](../../lean/Protocol/Transfer/Certificates/Bundle.lean)
requires all five hard, six naturality or seven final slots on the same
submitted bundle; a failed earlier prefix rejects the actual later transfer.
[Exact calibration realization](../../lean/Protocol/Transfer/Certificates/Calibration.lean)
identifies all four selected real radii with their rational descriptor.

The [constructed statement](../../lean/Protocol/Transfer/Certificates/Statement.lean)
discharges encoding reflection for actual native/projection certificate
relations. Successful checking therefore yields certification or false
acceptance on the actual submitted proof, traced to its terminal leaf in the
projection bundle. The native relation is the existing original-observation
binding; the projection adapter retains the actual chain, cochain input and
certificate record, including its metric choices. The guarded transfer
profile compares its actual database with all seven canonical leaf digests
and the computed root, deriving `DatabaseBound` from acceptance of that same
packet. Legacy slot labels and public profile names do not supply this
refinement.

## Lean sources and paper ownership

| Construction | Canonical entry |
|---|---|
| Coupled harmonic lattice and proved semantic class | [HCPCoupledFamily](../../lean/Sheaf/HCPCoupledFamily.lean), [CoupledCVP](../../lean/HCP/CoupledCVP.lean), [CoupledSemantics](../../lean/HCP/CoupledSemantics.lean) |
| Concrete presentation bytes and original snapshot | [CoupledCodec](../../lean/Protocol/Storage/CoupledCodec.lean), [CoupledBinding](../../lean/Protocol/Storage/CoupledBinding.lean) |
| Original full Hodge ciphertext bytes | [HCPCoupledEncoding](../../lean/Sheaf/HCPCoupledEncoding.lean), [CoupledCiphertext](../../lean/Protocol/Storage/CoupledCiphertext.lean) |
| Exact native execution and scoped token | [CoupledRational](../../lean/HCP/CoupledRational.lean), [TransportCodec](../../lean/Protocol/Storage/TransportCodec.lean), [ScopeCodec](../../lean/Protocol/Ephemeral/ScopeCodec.lean), [TransportToken](../../lean/Protocol/Ephemeral/TransportToken.lean), [NativeTransport](../../lean/Protocol/Ephemeral/NativeTransport.lean) |
| Original-context native delivery and retrieval | [NativeDelivery](../../lean/Protocol/Ephemeral/NativeDelivery.lean), [Retrieval.Native](../../lean/Protocol/Storage/Retrieval/Native.lean) |
| Canonical two-slot naming and native semantic certificate | [CiphertextManifest](../../lean/Protocol/Storage/CiphertextManifest.lean), [NativeManifest](../../lean/Protocol/Storage/NativeManifest.lean) |
| Actual checked native history and recovery | [Transfer.Native](../../lean/Protocol/Transfer/Native.lean), [Retrieval.NativeAnchored](../../lean/Protocol/Storage/Retrieval/NativeAnchored.lean) |
| Commitment and coordinate profile | [CochainCommitment](../../lean/Axioms/CochainCommitment.lean), [CoordinateCodec](../../lean/Protocol/Storage/CoordinateCodec.lean) |
| Generic ledger and computed transition | [Ledger.Transition](../../lean/Protocol/Ledger/Transition.lean), [Ledger.ValueFlow](../../lean/Protocol/Ledger/ValueFlow.lean) |
| Bounded transition and checked transfer | [Protocol.Core](../../lean/Protocol/Core.lean), [Transfer](../../lean/Protocol/Transfer.lean), [PublicAssembly](../../lean/Protocol/Transfer/PublicAssembly.lean), [protocol guide](../../lean/Protocol/README.md) |
| Storage, public views and gates | [Storage.Core](../../lean/Protocol/Storage/Core.lean), [PublicView](../../lean/Protocol/Storage/PublicView.lean), [storage guide](../../lean/Protocol/Storage/README.md) |
| Rotation, recovery and retrieval | [Ephemeral](../../lean/Protocol/Ephemeral.lean), [Retrieval](../../lean/Protocol/Storage/Retrieval.lean) |
| Committee and proof/TCB envelopes | [Consensus.Quorum](../../lean/Protocol/Consensus/Quorum.lean), [TCB](../../lean/TCB.lean) |
| Public certificate bytes and calibration | [Codec](../../lean/Protocol/Transfer/Certificates/Codec.lean), [Calibration](../../lean/Protocol/Transfer/Certificates/Calibration.lean), [Evidence](../../lean/Protocol/Transfer/Certificates/Evidence.lean), [Bundle](../../lean/Protocol/Transfer/Certificates/Bundle.lean) |
| Certificate statements and actual consumption | [Statement](../../lean/Protocol/Transfer/Certificates/Statement.lean), [Native](../../lean/Protocol/Transfer/Certificates/Native.lean), [Projection](../../lean/Protocol/Transfer/Certificates/Projection.lean) |
| Bounded native credential and adaptive CRS reduction | [NativeRelation](../../lean/Protocol/Transfer/PathSignature/NativeRelation.lean), [NativeProgram](../../lean/Protocol/Transfer/PathSignature/NativeProgram.lean), [CRS](../../lean/Protocol/Transfer/PathSignature/CRS.lean), [NativeSecurity](../../lean/Protocol/Transfer/PathSignature/NativeSecurity.lean) |
| Sampler audit and fresh-sign candidate | [NativeRecovery](../../lean/Protocol/Transfer/PathSignature/NativeRecovery.lean), [NativeSignSampler](../../lean/Protocol/Transfer/PathSignature/NativeSignSampler.lean), [NativeSignPrivacy](../../lean/Protocol/Transfer/PathSignature/NativeSignPrivacy.lean), [NativeOperatorGuessing](../../lean/Protocol/Transfer/PathSignature/NativeOperatorGuessing.lean) |
| Coexact refresh and checked arithmetic ranges | [NativeNoiseRefresh](../../lean/Protocol/Transfer/PathSignature/NativeNoiseRefresh.lean), [NativeCircuitBounds](../../lean/Protocol/Transfer/PathSignature/NativeCircuitBounds.lean) |
| Finite native witness sampling | [NativeSampler](../../lean/Protocol/Transfer/PathSignature/NativeSampler.lean) |
| Authenticated profile selection and owner execution | [Profile](../../lean/Protocol/Transfer/Certificates/Profile.lean), [ProfileAuthentication](../../lean/Protocol/Transfer/Certificates/ProfileAuthentication.lean), [Registered](../../lean/Protocol/Transfer/PathSignature/Registered.lean), [NativeRegistered](../../lean/Protocol/Transfer/PathSignature/NativeRegistered.lean) |
| Original context and sampled application bound | [NativeContext](../../lean/Protocol/Transfer/PathSignature/NativeContext.lean), [NativeApplication](../../lean/Protocol/Transfer/PathSignature/NativeApplication.lean) |
| Canonical byte-owner packets and sample arithmetic | [TransferCodec](../../lean/Protocol/Evidence/TransferCodec.lean), [NativeCircuit](../../lean/Protocol/Transfer/PathSignature/NativeCircuit.lean) |
| Integrity, leakage and primitive contracts | [Transfer.Security](../../lean/Protocol/Transfer/Security.lean), [Transfer.Confidentiality](../../lean/Protocol/Transfer/Confidentiality.lean), [Transfer.Primitives](../../lean/Protocol/Transfer/Primitives.lean), [generic certificate contract](../../lean/Protocol/Transfer/Certificates.lean) |

[Paper 1](../paper1/README.md) supplies HCP, harmonic lattices, semantic classes
and known-lattice CVP comparisons. [Paper 3](../paper3/README.md)
introduces full projective reconstruction and proves the quantitative
projection, metric and radius comparisons. Paper 2 owns the construction,
visibility and codec profiles consumed by those comparisons. The
[current family inventory](DRAFT.md#7-construction-ownership-and-remaining-protocol-work)
accounts for the checkpoint lifecycle, ledger, gates, evidence, proof/TCB and
committee objects without promoting their supplied contracts to algorithms.

## Remaining obligations

PoV/reliability policy, oracle/coregulator attachment points and the legacy
chain model are deferred or supporting families outside the bounded
transition claim. Authenticated quorums do not supply rounds, locking or finality.

The immediate privacy obligation is the new hiding operator-root profile and
its actual opening/codec/context joins, followed by analysis of the complete
public view and key-use policy. The ciphertext-only sign law does not close
that obligation or justify a multi-use security theorem. The existing raw-root
application remains a conditional integrity/recovery reference.

The CRS reference reduction composes supplied algorithms; a secure proof
primitive implementation, its message-bound extraction/simulation estimates,
full range/byte/hash circuit refinement and secure setup generation remain
obligations. Quorum approval binds selected bytes rather than establishing
those properties. Authenticated roots/directories and protected recipient
delivery also require construction and verification. The canonical byte-owner
packet/witness profile does not encode unrestricted real data or establish a
runtime implementation. A separate application
relation must connect harmonic coefficients to amounts and action semantics.
The native codecs do not encode unrestricted
real openings. Secure parameter/distribution selection and shared-secret
agreement remain open.
No quantitative adaptive signing/corruption security, encryption privacy or
anonymity follows from the supplied primitive names or budgets. State origin,
executable refinement, global lifecycle enforcement and consensus finality
also require separate results. The archived prototype is not an implementation
proof of this protocol.
