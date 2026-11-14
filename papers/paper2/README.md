# Paper 2 source: Proof-Carrying Homotopical Encryption

Working combined title: *Homotopical Encryption and Proof-Carrying Transactions*.

The [working manuscript](DRAFT.md) develops cochain encryption and verification
with changes of cellular presentation that preserve messages. Its coupled
family has an explicit intrinsic harmonic lattice; separate cochain and ciphertext maps
preserve the declared semantic class and original message coefficients.
The exact-component artifact can remain fixed while the full encrypted
cochain changes, so the canonical manifest names both objects. Its root enters
owner authorization, packet verification and accepted history. A separate
native observation-binding refinement connects the ciphertext bytes to the
original harmonic message used in recovery. Exact-payload proof checking and
full-observation binding remain distinct obligations.
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
separate from the exact-component artifact digest. Key/noise sampling,
concrete authentication/proof algorithms and full-view security remain work.
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
key/noise sampling and security for the complete released view remain open.

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

Concrete credential/proof algorithms, message-bound knowledge and
unforgeability, packet/witness codecs beyond the selected native profile,
authenticated roots/directories and protected recipient delivery require
construction and verification. The public certificate codec, digest preimages
and intended-statement reflection are constructed; the selected CRS/proof
algorithm still needs circuit refinement, setup authentication and a
computational soundness/knowledge argument. Its packet serializer remains a
supplied codec. A separate application
relation must connect harmonic coefficients to amounts and action semantics.
The native codecs do not encode unrestricted
real openings. Key/noise sampling and shared-secret agreement remain open.
The supplied primitive budgets do not establish adaptive
signing/corruption security, encryption privacy or anonymity. State origin,
executable refinement, global lifecycle enforcement and consensus finality
also require separate results. The archived prototype is not an implementation
proof of this protocol.
