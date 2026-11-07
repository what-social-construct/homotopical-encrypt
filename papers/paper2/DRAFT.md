# Proof-Carrying Homotopical Encryption

## Working manuscript: objects, observations and metric contracts

Initial manuscript text, 2026-11-05. This draft develops the bounded
proof-carrying transition scope in [SCOPE.md](SCOPE.md). It is not yet a full
protocol paper or a TeX/PDF manuscript. The [shared parity table](../../SEMANTIC-PARITY.md)
is the current statement/proof-status register.

### 1. Scope and paper ownership

Paper 1 supplies the cellular Hodge objects, the explicitly named homological
Helfer fragment, concrete HCP families, harmonic recovery, CVP comparisons and
the mathematical commitment interfaces. Paper 2 owns the visibility and
encoding profile, the relation between those objects and public observations,
verification evidence, retained artifacts and one accepted state transition.
Authorized recipient recovery material, representative/key rotation and
storage migration also belong to Paper 2's protocol profile. Paper 3 owns the
independent coding theorems and the quantitative analysis of a declared application
profile. Definitions are shared across the papers; a citation does not create
a second commitment or discharge its compatibility conditions.

The first protocol endpoint is the conservative, snapshot-bound owned-resource
transition of §6.2, with candidate-indexed evidence and an optional matching
acceptance quorum. Section 6.3 gives a fixed-setup one-shot integrity experiment
and conditional error-composition theorem for that checker. Primitive security
estimates, adaptive cryptographic games, consensus finality and backend
durability remain additional obligations. Section 6.1 specifies mathematical
recipient recovery
and rotation; authenticated delivery, lifecycle enforcement and bytes remain
explicit contracts. The existing proofs state their authentication and
implementation contracts explicitly.

### 2. Maintained geometry, temporary processing and retained artifacts

Fix a finite cellular sheaf \(F\) on an oriented two-complex \(X\). Its stalks,
restriction maps, inner products and integral-coordinate conventions determine
the cochain complex and true degree-one Hodge operator

\[
C^0(F)\xrightarrow{\delta_0}C^1(F)\xrightarrow{\delta_1}C^2(F),
\qquad \Delta_1=\delta_0\delta_0^*+\delta_1^*\delta_1.
\]

The base complex is not identified with a block-history graph or a physical
peer network. Those identifications require explicit maps and application
data. A snapshot binds the selected sheaf interpretation and its coordinate
ordering. The typed snapshot does not itself supply canonical bytes or
reconstruction of the sheaf from a digest.

One `Storage.Context` retains that original interpretation, snapshot and whole
public cochain artifact. Its processing bus is a witness-local sequence of
cochain, plane and RS states followed by hard, naturality and final evidence.
The bus is separate from the persistent manifest. A sealed manifest retains
an exact ordered list of typed payload/digest leaves. Local consumption
requires a persistence receipt for that same context, list and root.

The history anchor joins the same candidate, interpretation, original
artifact and sealed manifest under explicit inclusion relations. Its
projection specialization retains the exact final prefix and actual gate
database. Snapshot root, cochain leaf digest, gate-evidence digest, manifest
root and block digest are separate coordinates. A matching quorum signs the
same proposal; these joins do not by themselves prove global finality.

The three visibility levels are already fixed in
[Paper 1, Section 5](../paper1/sections/05-public-artifacts-and-commitments.tex).
Paper 2 preserves that separation while specifying its concrete protocol paths:

| Level | Data and exposure |
|---|---|
| Private witness | The base and ephemeral presentations, restrictions and operative Hodge data, harmonic message, noise, openings and transport. The full cochain \(b\) remains private unless a specified observation path explicitly publishes or exposes it. |
| Public payload | The serialized residue edge vector \(\bar c=\delta_0a\bmod q\), modulus, declared edge count and topology tag; public artifact handles and root bindings refer to the selected objects. This payload is not the full Hodge sample or a presentation of its operator. |
| Selective opening/proof | Only the declared local values, conditions or verified statements are exposed. An opening or proof does not make every field of its semantic witness record public. |

#### 2.1. Base public input and declared disclosures

The first storage-facing profile publishes the original payload together with
the header already derived by `Storage.Context.key`. For a context \(C\), set

\[
V_{\mathrm{base}}(C)=(K(C),c(C)),
\]

where the six coordinates of \(K(C)\) are `runId`, `schemaVersion`,
`snapshotRoot`, `cochainDigest`, `topologyTag` and `parameterSet`. Here

\[
c(C)=C.\mathrm{artifact}.\mathrm{cochain}=(q,N,\mathbf z,\tau).
\]

The digest in the header is the original artifact's leaf digest. The header's
topology tag equals the original payload's tag by the context's existing
snapshot-binding contract. It is not a second topology description. The
[public-view adapter](../../lean/Protocol/Storage/PublicView.lean) names this
record `PublicPayloadView` and constructs it as `Context.publicView`. Its
carrier contains no sheaf, decoder, harmonic message, opening or semantic
`Prop` field. Equality of two base views requires equality of both their
complete headers and their original payloads.

A separately announced public class label can accompany the base input
without disclosing the cochain: its view is
\((V_{\mathrm{base}}(C),\alpha)\), with \(\alpha\) supplied by the same
snapshot classifier. The label remains public in any experiment that
announces it. Publishing it does not authorize publishing \(b\), and a stable
class label may link repeated uses.

For retained storage, `PublicManifestView Slot` adds the actual sealed manifest
root and its ordered directory of `(slot,digest)` entries to that same base
view. `SealedManifest.publicView` derives the directory from the original
manifest items, omitting their semantic checkpoint payloads. The manifest
root does not replace the proposal, state, evidence or block roots; those
remain separately named public extensions wherever the history releases them.

| Object or path | Reader and released data | Binding and limit |
|---|---|---|
| Base public input | Every public reader receives \(V_{\mathrm{base}}\), including the residue vector and all six header coordinates. | Reuses the original artifact and context. Public identifiers are observable and may distinguish presentations. |
| Private interpretation and witness | The witness holder retains the actual sheaf, decoder, operative Hodge data, full sample, harmonic message and openings. | Their omission as record fields does not prove secrecy against public tags, roots or other released data. |
| Public class announcement | A declared class-announcement path publishes the base record and the same snapshot's classifier value \(\alpha\), while keeping \(b\) outside that view. | This is distinct from publishing the full HCP pair. Its classifier value and any repeated-use linkability remain part of the observable data. |
| Explicit HCP disclosure | A path that declares disclosure of the selected HCP input adds the same sample's classifier/cochain pair \((\alpha,b)\). Its designated reader receives that pair. | `HCPDisclosure` retains the base record, and `hcpDisclosure` obtains the pair from the same `BoundHCPObservation.toObservation`. This is no extraction of \(b\) from the residue vector. |
| Plücker handle | The base profile contains no full operative-kernel Plücker coordinates. An extension may release an explicitly bound digest as an additional observable field. | `HashedPluckerShadow` contains both a shadow and digest and is not a digest-only release. Digest binding and hiding are different requirements. |
| Selective local opening | An authorized reader receives only the declared indices and opening values, together with their verification material. | The policy must bind the query and answers to this payload and context. Authorization, boundary-edge data and the response codec remain explicit contracts. |
| Public proof or verified statement | The declared reader receives the released statement/instance identifiers, proof-system and verifier identifiers, public inputs and proof bytes. | The encoding and verifier relation must bind those actual fields to the same candidate and context. A semantic `Prop` or proof-system record is not their wire format. |
| Retained manifest and projection evidence | The selected retained view publishes the sealed root and ordered `(slot,digest)` directory with the same base input. Released leaf openings and evidence bytes extend this view. | The directory is derived from the actual items. Their semantic checkpoint payloads and projection prefixes remain private unless separately disclosed; retaining them in Lean does not authorize publishing every witness field. |
| Bounded owned-transfer release | `PublicTransferView` in §6.3 publishes the actual canonical packet bytes, parsed packet, complete proposal and original input-manifest view. | Public resource/signer IDs, metadata, original base input, signature and proof bytes are observable. This release is distinct from a complete network transcript; setup, available prior-state data, catalogue access and other auxiliary inputs must also be declared. |

The base and manifest views are not a completed adversary transcript. A proof,
selective response, state root or other
released extension must be included in the view used by its security
experiment. Access to private recipient material is not assumed from this
table; authenticated delivery and rotation lifecycle enforcement remain
additional protocol work.

The named HCP disclosure is a semantic observation of real cochain
coordinates. Its existence in Lean supplies no finite wire codec or access
control implementation. No claim that the base residue bytes reveal that
observation is made. A semantic `BoundHCPObservation` itself retains the
message and openings and is never the public serialization target.

Snapshot roots, topology tags, run identifiers and parameter handles remain
visible even when raw Hodge coordinates are withheld. A snapshot may bind a
different cellular presentation, and a public lookup may reveal further
information. Neither identical class labels nor equal exact components imply
equal headers, payloads or proof transcripts. In particular, the finite HCP
axis example does not construct two equal complete public storage records.

This fixes the first profile's data and access boundaries. Canonical bytes,
hash domain separation, concrete proof/verifier formats, authenticated opening
requests and the binding of released history extensions remain implementation
or cryptographic contracts. No hiding theorem follows from this projection.

### 3. One payload and distinct validity predicates

The wire-facing object is the existing

\[
c=(q,N,\mathbf z,\tau),\qquad \mathbf z\in\mathbb Z^N,
\]

with shape, supported-modulus and topology-tag conditions. Artifact and proof
wrappers retain this same `CochainCommitmentData`; they do not replace it with
a new cochain.

For a fixed real decoder, `Context.Accepted` requires decoded exactness:

\[
\operatorname{dec}_F(c)=\delta_0a\quad\text{for some }a\in C^0(F).
\]

An integral wire profile has another natural predicate: **modular exactness**.
It requires an actual integral opening and an integer carry such that

\[
\delta_0 a=\mathbf z+q\mathbf m.
\]

The new systematic cellular profile constructs this relation from the actual
coboundary and proves its equivalence with the selected finite-field RS
code. Its definition contains neither a coding-distance comparison nor a
target-codeword assumption. Modular exactness and real decoded exactness
remain different predicates. A proved no-wrap bound on the integer syndrome
can relate them in the explicit profile; canonical scalar representatives
alone do not establish that relation. Protocol policy must name the predicate
being attested and preserve its interpretation in the candidate evidence.

The full HCP sample is a further object:

\[
b=h+\delta_0a+\delta_1^*v,\qquad P_Hb=h.
\]

An exact committed component has zero harmonic projection. It is not the full
encrypted sample when the harmonic message is nonzero. A statement connecting
these objects must retain its actual serialization and observation witnesses.

The selected mathematical HCP input remains the existing classifier/cochain
pair \((\alpha,b)\). This is an explicit observation experiment, rather than
an assertion that every residue payload publishes \(b\). Any protocol path
obtaining that datum from a payload, selective opening or verified evaluation
must identify it with the same sample. Extending the theorem to a richer
storage view requires a separate comparison of the released fields. For two
actual witnesses, equality of their entire selected released views and
inequality of their operative targets rule out a decoder exact on both;
`TCB.HCPRealization.no_exact_view_decoder_of_same_view` records this pairwise
criterion. The existing global factorization theorem is another sufficient
criterion, not a property automatically enjoyed by public roots or proofs.

Full genuine Plücker coordinates of the operative kernel give the opposite
boundary: with the same \(b\) and fixed inner product, they determine the
operative target, as proved in
[PluckerObservation](../../lean/TCB/PluckerObservation.lean). A profile that
releases those coordinates cannot also claim distinct targets under that
identical full view. A digest-only extension requires its own analysis and
does not inherit this exact-coordinate recovery theorem or a hiding theorem.

### 4. Three native metric levels

The projection chain keeps a distance at each level. Neither a shared payload
type nor a shared root identifies those distances.

| Level | Object | Native metric in the explicit modular profile | Validity locus |
|---|---|---|---|
| Cochain/local syndrome | The original serialized cochain coordinates | Fraction of changed scalar coordinates, normalized by \(2n\) | Actual integral cellular coboundaries modulo \(q\) |
| Plane | The two coordinates extracted at each of \(n\) positions | Fraction of changed whole pairs, normalized by \(n\) | Modularly exact integer planes in the selected layout |
| RS | The reduced finite-field pair, followed by an affine challenge | Whole-pair RS distance; scalar RS distance after the challenge | The actual interleaved RS code, or scalar RS code respectively |

An explicit complete coordinate layout records both geometric and serialized
orders, reads every scalar exactly once and uses the identity integer
coefficient map. An arbitrary legacy extraction need not have these
properties. The codec proves alignment from the original context's shape and
snapshot conditions; its real decoder reads the same coordinates as its plane
extraction.

The systematic native profile uses the geometric ordering built into its
actual restriction maps. The selected canonical layout uses that same
ordering. A different complete bijection does not by itself transport the
geometric coboundary into the same indexed RS code; that compatibility must
be recorded for any differently ordered geometric interpretation.

For corresponding scalar and pair words, let \(h_C\) count scalar mismatches
and \(h_P\) count mismatched pairs. Then

\[
h_P\le h_C\le 2h_P.
\]

After normalization and minimization over corresponding valid codewords, the
native distances satisfy

\[
d_C\le d_P\le 2d_C.
\]

Reduction relates the integer plane validity locus to the actual RS locus.
The new modular theorem holds for **all integer representatives**, because
modular exactness is saturated under coordinatewise multiples of \(q\).
Reduction cannot create a mismatch. In the other direction, lift a nearest
field codeword by retaining each already matching whole received integer
pair and choosing canonical representatives at the remaining positions.
The lift is modularly exact and has exactly the field mismatch set. Hence

\[
\boxed{d_C\le d_P=D_{\rm RS}\le2d_C}.
\]

A separate scalar-coordinate representative lift proves equality between
\(d_C\) and the corresponding flattened finite-field code distance. These
are distance-to-validity theorems using explicit lifts. They do not assert a
pairwise isometry for arbitrary raw integer words. The earlier canonical-region
plane/field equivalence remains a stronger pointwise statement on that region.

These directions matter. The existing chain's *near* contract has a target
distance bounded above by its source score. The native scalar distance
\(d_C\) supports the far direction \(d_C\le d_P\). The near contract
can consume the explicitly scaled score \(2d_C\), since
\(d_P\le2d_C\). The metric \(d_C\) keeps its native \(2n\) normalization;
the factor belongs to the near contract. The far implication uses the native
unit comparison \(d_C\le D_{\rm RS}\).

The factor two is sharp for the actual RS family. Put the degree-\(k\)
power word in the first column and zero in the second. Then, for
\(0<k<n\),
\[
d_C=\frac{n-k}{2n},\qquad d_P=D_{\rm RS}=\frac{n-k}{n}.
\]
Thus a global native unit near inequality \(d_P\le d_C\) is false even
for the selected RS code.

In the declared systematic realization, with its complete decoder, accepted
real-exact payloads also have modular validity and zero distance at all three
native levels. Positive native farness is therefore a **raw-input rejection
condition**, not a property of an already accepted anchor. Modular validity
alone does not imply real `Context.Accepted`; that converse needs the stated
integer-syndrome no-wrap restriction and the actual decoder relation. Policy
and evidence must record which predicate was checked.

The accepted-to-native-zero theorem itself uses the explicit equality
`C.interpretation.decode C.cochain = layout.decode C.cochain` at this
payload. Shape and snapshot binding alone do not prove that equality.

The **upstream geometric scores stay separate**. In particular,

\[
\rho_{\rm ex}(c)=\|P_{(\operatorname{im}\delta_0)^\perp}
                     \operatorname{dec}_F(c)\|
\]

is Euclidean distance to exact cochains. It is distinct from scalar edit
distance, whole-pair edit distance, a frame disagreement and the full-HCP
residual \(\|(I-P_H)b\|\). Keeping three chain metrics does not supply any
missing comparison from these upstream quantities.

### 5. Checked geometric boundaries and an explicit restricted profile

For genuine frame witnesses, the full projective Plucker point reconstructs
the harmonic subspace by exterior multiplication:

\[
W=\{x:x\wedge(w_1\wedge\cdots\wedge w_r)=0\}.
\]

This construction and both concrete projective soundness inputs are now
proved in Lean. At the fixed inner product it recovers the harmonic projector.
If this is the operative HCP kernel, full projective data determine the
operative target on the observed vector. This is mathematical recovery on
exact real coordinates, not a finite-encoding algorithm or a digest inversion
result. A digest-only observation requires a separate visibility/binding
profile; the current semantic hashed-shadow record also contains the shadow.

For RS degree bound at least two, the canonical real lifts of affine field
codewords span the full real coordinate space. The checked consequence is
that a nontrivial linear decoder cannot satisfy a global Euclidean
exactness-distance comparison with zero additive loss against unrestricted
RS distance. This does not exclude restricted profiles, additive losses or
separately justified threshold theorems.

The explicit systematic cellular profile lifts actual RS interpolation
coefficients to integers. Its real coboundary is the resulting systematic
generator. A bounded coordinate envelope and a no-wrap bound on the **integer
syndrome** prove validity reflection and the coarse comparison

\[
\rho_{\rm ex}(c)\le Bn\sqrt{2n}\,D_{\rm RS}(c).
\]

This uses the independent Euclidean distance. Its finite-shell argument
certifies at most a first-shell target radius for a nonempty source far
region. It is not a capacity- or Johnson-scale geometric theorem. A positive
decoded far input is a raw received context; already accepted exact anchors
have \(\rho_{\rm ex}=0\).

### 6. Challenges and evidence consumption

A pair is fixed before a sampled affine challenge. A bound on the fraction
of bad challenges does not certify an arbitrary fixed mix. The zero-direction
profile has a checked stronger property: every challenge is good and the
scalar and pair distances agree.

The nonzero diagonal profile is also checked. If both columns equal the
degree-\(k\) power evaluation word \(u\), then every
\(\gamma\ne-1\) is MCA-good and preserves its scalar capacity distance.
At every nonnegative tested radius, the bad set is exactly \(\{-1\}\),
with uniform fraction \(1/q\). The generic proof divides a scalar same-set
codeword witness by \(1+\gamma\), then uses it in both pair columns.
The canonical mix has order \(4096\), so is noncancelling on this particular
line; its concrete adapter is tracked separately from the generic theorem.

This is a restricted-line result. For any fixed nonzero \(\gamma_0\), the
pair \((u,-\gamma_0^{-1}u)\) has native cochain and pair distance
\((n-k)/n\), but its scalar value at \(\gamma_0\) is zero.
A global fixed-mix far-preservation claim fails even on capacity-far inputs.
General protocol use must bind the pair before sampling its challenge or
authenticate a line profile with a proved goodness theorem.

The final evidence object must state the source score, each metric handoff,
radius normalization, challenge experiment and root bindings. The existing
candidate-indexed evidence and anchor joins preserve those statements and
objects; they do not construct an omitted source comparison or turn an
admissibility predicate into finality.

The shared [HCP object crosswalk](../../docs/COCHAIN_PROXIMITY_TRACE.md#hcp-object-accounting-rotation-and-anonymity)
accounts for semantic classes, admissible presentations, integral messages,
exact/coexact noise, the full sample, commitments, gates and retained artifacts
(HC01--HC44). It also recovers the ephemeral/anonymity plan: generate a private
representative in the same class with a hidden path/transport, then publish
only the selected artifact and evidence view. Class preservation for one
supplied representative is proved under an explicitly path-respecting
classifier. Actual integral transport and recipient recovery are specified
below; indexed generation, lifecycle enforcement and an anonymity game remain
separate obligations.

Rotation correctness must name the semantic plaintext and its cross-presentation
encoding: transporting harmonic coordinates can preserve the same plaintext.
Fixed-observation HCP ambiguity instead compares one raw observed cochain
under different hidden presentations. To claim ambiguity of the actual public
stack, the released payloads, roots, proof outputs and handles must be included
in its view; equality of the classifier/cochain pair alone is insufficient.
Representative privacy, plaintext hiding, sender anonymity, unlinkability and
forward secrecy are distinct experiments. This draft selects none of them
implicitly from a large classifier fiber or the name of a gate.

The recipient profile below keeps the base lattice/Hodge key and uses an
actual private transport for recovery. Its delivery receipt names the same
semantic plaintext convention and original source/target contexts. Any
released delivery hints or envelope bytes extend the §2.1 observation view.
A noise opening or class-membership path alone supplies neither that recovery
material nor a key-exchange or encapsulation algorithm.

#### 6.1. Recipient recovery and coefficient-preserving rotation

Let \(H_0,H_1\) be explicit harmonic-lattice presentations with the same
integer coefficient type \(\mathbb Z^r\). The semantic plaintext is \(z\),
with ambient encodings \(H_0(z)\) and \(H_1(z)\). An actual degreewise chain
isometry \(U=(U_0,U_1,U_2)\) transports the coboundaries and adjoints. For
arbitrary intrinsic integral harmonic messages it additionally preserves the
chosen degree-one integral lattices in both directions. This integral law
does not follow from a real isometry. The selected encodings satisfy the
separate law

\[
U_1H_0(z)=H_1(z)\qquad\text{for every }z\in\mathbb Z^r.
\]

[Integral Hodge transport](../../lean/Sheaf/Rotation.lean) carries the actual
message and opening coordinates together:

\[
(h,a,v,b)\longmapsto(U_1h,U_0a,U_2v,U_1b),
\qquad b=h+\delta_0a+\delta_1^*v.
\]

The observed-cochain equation, harmonic-projector covariance, inverse law
and successive-rotation composition are proved from the chain isometry.
The opening coordinates remain real-valued. No integral-noise sampler or
distributional guarantee is inferred.

The [coefficient decoder](../../lean/Sheaf/CoefficientRecovery.lean) takes
only the actual observed cochain and the selected private presentation. It
projects to the harmonic subspace and returns the unique integer coefficient
vector when that point lies in the presented lattice, otherwise `none`.
Full real span alone does not cover every intrinsic integral harmonic point.
This is an exact classical, noncomputable decoder, without a claimed
efficient finite-byte algorithm. It never reads a sample's hidden message
field as its input.

[PresentedRotation](../../lean/Protocol/Ephemeral/Rotation.lean) retains the
actual integral isometry and encoding law. Both recipient routes recover the
same plaintext from a rotated valid encryption:

\[
\operatorname{decode}_{H_1}(U_1b)=\operatorname{some}(z),\qquad
\operatorname{decode}_{H_0}(U_1^{-1}(U_1b))=\operatorname{some}(z).
\]

The second route lets the recipient retain the base recovery key and use the
delivered private transport. It is a correctness theorem, not a construction
of a confidential delivery channel.

The [delivery receipt](../../lean/Protocol/Ephemeral/Delivery.lean) is indexed
by the actual recipient, source and target epoch labels, context keys derived from
the original source and target storage objects, actual rotation material and
an actual envelope. Authorization and authenticated delivery are explicit
application relations on those objects. Epoch labels are separate from the
context keys and must be bound to the actual protocol state by those
relations; a schema version is not an epoch. Recovery checks the entire request
scope; a changed recipient label, epoch or context key returns `none`.
Matching public labels alone do not authenticate a caller, distinguish
semantic contexts with colliding names, or prevent replay of the same valid
request. Epoch monotonicity, fresh generation, secure delivery and retirement
remain policy/channel/lifecycle obligations. The receipt is private semantic
evidence and is not serialized wholesale into public history.

A `PayloadRotation` additionally requires the actual decoder equation
\(\operatorname{dec}_{F_1}(c_1)=U_1\operatorname{dec}_{F_0}(c_0)\).
It then derives target exact acceptance from source exact acceptance using
the coboundary square. Original payloads and snapshots are retained; public
roots are not forced equal, and atomic storage replacement or deletion is
not inferred. The existing `EphemeralFiberSpec` can be joined to an actual
`PresentedRotation` with the same endpoints. Class preservation still uses
its path-respecting classifier law; a path or class label does not produce
the integral map or encoding law. Generation of such paths/rotations is
separate from this typed join.

The [bound-sample adapter](../../lean/Protocol/Ephemeral/HCP.lean) makes the
original HCP objects explicit. A `BoundSampleRotation` relates the two actual
`BoundHCPObservation` records by transport of their full encrypted samples.
Their existing decoded-exact-component equations then derive the
`PayloadRotation` decoder law for their original storage contexts. Target
coefficient recovery and retained-base-key recovery follow when the actual
source message is the selected point \(H_0(z)\). A constructor may retain a
supplied target artifact, decoder equation and observation-binding proofs;
it creates no hash, snapshot or authentication fact. This join asserts no
equality of class labels or released records.

The [actual axis-family rotation](../../lean/HCP/AxisRotation.lean) constructs
the integral map and encoding law for every integer coefficient. Rotating
the weighted source sample changes \(b=(1,2)\) to \((2,1)\) and recovers
coefficient \(2\) by either recipient route. The fixed-observation target
sample at \((1,2)\), which encodes \(1\), is a different sample. Thus
rotation correctness and fixed-input ambiguity use different observations.
These laws preserve Euclidean geometry; a separate coordinate/codec theorem
is needed to preserve any cochain/plane/RS Hamming profile under a chosen
migration. The base complex is fixed; topology-changing migration is outside
this construction.

#### 6.2. One checked owned-resource transition

The [owned-resource profile](../../lean/Protocol/Ledger/OwnedResource.lean)
fixes an actual catalogue assigning each resource ID an owner, an asset and a
positive integer amount. A finite marking records resource multiplicities.
One action consumes a single input ID and produces a distinct output ID with
the same asset and amount. Checks require the input to occur exactly once,
the output to be absent, both IDs to be unspent, and the stated signer to be
the input's catalogue owner. The nullifier list is exactly `[inputId]`; it is
derived from the consumed resource rather than supplied independently.

These IDs and the selected owner-authorization subject are public in this
bounded profile. This supplies neither an anonymous nullifier construction nor
a production account/UTXO architecture. Catalogue amounts are ledger asset
units, not harmonic-message coefficients or sums of serialized cochain edges.
The inventory is committed by the state-content root; no equation identifies
it with the cochain's decoded coordinates. The actual configured catalogue is
trusted profile data; matching a policy
identifier alone does not authenticate its interpretation.

The mechanical fixture transfers positive amount seven between distinct
owners while retaining a supplied state header. It proves structural checks
and inventory/value consequences without constructing a signature, payload
proof, runtime or hash-security instance.

The [checked transfer](../../lean/Protocol/Transfer/Owned.lean) retains the
original `Storage.Context`, payload interpretation, snapshot and artifact.
`Config.intentFor` constructs the expected public subject from those objects,
the chosen transfer and actual before-state. `CheckedTransfer.candidate`
constructs the existing `Ledger.Candidate` with that same payload and snapshot;
its successor is the existing computed `Candidate.after`. No independently
supplied after-state is accepted. The action keeps the epoch, snapshot and
topology fixed. The private rotation/recovery objects of §6.1 can supply an
original context, but this ledger action does not implement geometry or key-
epoch migration.

The [typed transcript](../../lean/Protocol/Evidence/TransferTranscript.lean)
uses the following acyclic preparation order:

1. Seal the original input payload and artifact digest in the
   [input manifest](../../lean/Protocol/Storage/TransferManifest.lean). Its
   root preimage is the existing base public view and one-entry slot/digest
   directory. The leaf contains no current candidate, proof packet or enclosing
   manifest root. This is an input-only manifest, not the six-stage projection
   manifest or a certificate that all projection gates have been completed.
2. Compute source and successor **content** roots and the pre-proof proposal
   draft. `StateContent` retains the marking, spent IDs, height, epoch, snapshot,
   topology and cochain root. It omits the current tip and evidence root.
   The actual source tip is the draft's parent digest, and the source evidence
   root is an explicit `Intent.beforeEvidenceRoot`. Thus these source
   coordinates remain in the owner-authorized subject.
3. Construct the exact intent containing the transfer, original public
   payload/context view, manifest root, proposal draft, schema version,
   statement identifier and policy identifier. The owner authorizes this
   pre-proof intent, rather than the later completed proposal.
4. Form the actual proof packet with that intent, owner-signature bytes, payload
   proof bytes and full metadata: schema, statement, policy, proof-system and
   verifier identifiers. Hashing this complete typed packet computes the
   evidence root. Its preimage contains neither that root nor a block digest.
5. Hash the block preimage containing the same draft, evidence root, intent
   digest and manifest root. The block preimage omits its own block digest.
   These two later digests complete the existing `ProposalRef`.

The supplied hash suite operates on these explicit typed preimages. Canonical
hash bytes, domain separation and cryptographic binding remain implementation
contracts. No global hash injectivity or inversion of a digest is assumed.
State content is not silently identified with the full state: reconstruction
lemmas require the omitted tip and evidence coordinates. For the successor,
those coordinates are the completed proposal's block and evidence digests;
for the source, they are the intent's parent and source-evidence fields.
This reconstruction is relative to the configured before-state and does not
establish that state's chain origin or consensus finality.

The [packet checker](../../lean/Protocol/Evidence/TransferVerifier.lean)
parses actual bytes, requires their canonical re-encoding, and checks equality
with the full expected metadata and intent before the selected primitive
Boolean verifiers. Equality of two Lean validity propositions does not bind
these data. The signature soundness contract authorizes the exact intent.
The payload verifier is indexed by the **actual trusted payload
interpretation**; its soundness law requires the original context's
interpretation equality and public-input equality before deriving exact
payload acceptance. It does not quantify over arbitrary decoders sharing
public labels. Codecs, primitive implementations and their indexed soundness
remain supplied contracts; the checker is a classical Boolean specification,
without a claimed efficient Rust implementation or new proof-system security
theorem.

`CheckedTransfer` stores the structural prechecks and actual checked packet.
It does not assume candidate validity. Resource checks derive availability,
same-asset conservation, and the fixed nonempty, duplicate-free, fresh spend
list. Signature and payload soundness supply their respective facts; original
snapshot/topology alignment supplies the context checks. Together these prove
the existing `Candidate.Valid` and hence `AcceptedUpdate`. The input's
resulting multiplicity is zero and the output's is one; asset value is
preserved. If the initial inventory has at most one copy per ID and no spent
ID present, the result preserves that invariant. A consumed input cannot be
replayed with new proposal metadata or an independently changed nullifier,
and an already spent ID cannot be resurrected as an output.

The [anchored endpoint](../../lean/Protocol/Transfer/Anchored.lean) separately
records the complete proof packet as the evidence-root preimage. It retains
the original artifact, interpretation, exact input seal and computed
candidate/successor through the existing evidence and `TransitionAnchor`
interfaces. The generic legacy artifact-only inclusion relation is not
treated as authentication of arbitrary proof bytes. For this profile, the
[semantic TCB adapter](../../lean/Protocol/Evidence/TransferEnvelope.lean)
packages already derived validity and the actual check fact, using the real
candidate/transfer pair as its private witness and the typed intent as its
shadow. It adds no `True` runtime assumption or unit/always-valid witness.
An externally supplied acceptance quorum may be attached only when it names
the same complete proposal. Packet acceptance creates no quorum or finality
proof. Durability likewise needs a receipt for the exact input manifest under
the supplied backend relation.

This closes the bounded mathematical transition under its stated setup,
authorization, proof, topology and runtime contracts. It does not instantiate
secure channels, hashing/codecs, signatures, payload proofs, authenticated
before-state origin, atomic application/persistence, reorganization handling
or consensus. The one-entry seal supplies no further proximity radius or
projection-gate theorem.

The correctness statement in this section uses exact primitive soundness
contracts. It supplies no computational or statistical failure bound for a
deployed signature or proof system. Section 6.3 supplies the bounded
one-attempt experiment and composes its failure estimates conditionally;
matching verifier labels alone do not discharge those estimates.

The packet's schema version and the original snapshot's schema version are
separate coordinates. Both enter the typed intent in their respective
locations; the construction does not identify them.

#### 6.3. One-shot sampled integrity under the declared transfer view

The [soundness-free packet layer](../../lean/Protocol/Evidence/TransferCheck.lean)
retains the actual codec and signature/payload checking algorithms without
assuming that successful verification implies either semantic authorization or
exact-payload acceptance. Its `CheckedPacket` supplies parsing, canonical-byte,
metadata and intent equalities plus the two Boolean verification results.
The payload algorithm is still indexed by the original trusted interpretation
and selected metadata. Public names do not identify arbitrary decoders.

The [operational transfer](../../lean/Protocol/Transfer/Operational.lean)
retains the same original context, catalogue, before-state, input manifest and
acyclic proposal construction. Local semantic facts suffice for validity:
the exact owner/intent pair is authorized and that original context is
accepted. The exact interfaces of §6.2 project to these operational interfaces
without changing the checker, candidate or policy. Their universal soundness
contracts recover the ideal correctness theorem as a specialization; those
contracts are not assumed by the sampled failure experiment below.

The [released transfer view](../../lean/Protocol/Transfer/PublicView.lean) is

\[
V_{\mathrm{transfer}}=
(\mathrm{packetBytes},\mathrm{packet},\mathrm{proposal},\mathrm{inputManifestView}).
\]

`CheckedTransfer.publicView` derives every coordinate from the same checked
release. The packet contains public input/output and signer IDs, full
metadata, original base payload/context, signature bytes and proof bytes;
the proposal and manifest retain their existing roots and directory.
The private interpretation and harmonic witness are not record fields, which
alone proves no hiding. A deterministic equality test on the released input
ID separates any two records with different input IDs. Output or signer
differences also imply different records. This public-ID profile therefore
provides no concealment of those identifiers. Paper 1's ambiguity for the
selected `(class,b)` observation does not establish equality or
indistinguishability of this larger view.

The [sampled experiment](../../lean/Protocol/Transfer/Security.lean) fixes an
operational configuration, a selected view, explicit auxiliary input, a PMF
on random tapes and an adversary
\(A(V_{\mathrm{transfer}},\mathrm{aux},r)=(\mathrm{transfer},\mathrm{bytes})\).
`ofCheckedRelease` supplies the exact view of an existing checked release;
the attacked configuration remains explicit and may be different. The general
experiment permits an arbitrary selected view and does not assert that
independently supplied fields form a coherent release. Public setup,
available prior-state data, catalogue access, openings or access metadata
beyond the selected record must enter the declared auxiliary input or an
extended view.

`AcceptedInvalid` means that the actual operational checker returns `true`
and the candidate determined by its parsed packet is invalid under the same
configured policy. Deterministic parsing identifies that packet with the
one retained by the checked transfer. The pointwise reduction proves

\[
\mathrm{AcceptedInvalid}\;\Longrightarrow\;
\mathrm{AuthorizationFailure}\;\lor\;\mathrm{PayloadFailure}.
\]

Each failure names an actually decoded packet with the exact expected
metadata and intent and a successful corresponding Boolean check.
`AuthorizationFailure` additionally says that this exact owner/intent pair is
unauthorized; `PayloadFailure` says that this original trusted interpretation
does not accept its payload. Neither event substitutes a matching digest or
verifier label for the actual semantic object.

All three events use the **same** sampled tape and attempted bytes. PMF mass
and the union bound give, without independence,

\[
\Pr[\mathrm{AcceptedInvalid}]
\leq \Pr[\mathrm{AuthorizationFailure}]+\Pr[\mathrm{PayloadFailure}]
\leq \varepsilon_{\mathrm{auth}}+\varepsilon_{\mathrm{payload}},
\]

where the second inequality requires supplied failure estimates for that same
experiment and adversary. Support-local absence of both failures implies zero
accepted-invalid mass. Projecting an existing exact-soundness configuration
gives this ideal zero-error specialization explicitly; it is conditional on
those universal contracts, not a new estimate for deployed primitives.
No primitive estimate is constructed. The PMF has
countable support; no uniform distribution on an infinite classifier fiber is
postulated.

This is a conditional one-attempt integrity reduction at fixed setup. It is
not an EUF-CMA, IND or anonymity theorem. A security parameter, randomized key
generation, adaptive signing/proof queries, corruption policy and the relevant
primitive reductions remain to be specified. Authenticated state origin,
hash binding of an external encoded history, runtime agreement, durable
application and finality are outside these events. The bad event is invalidity
of the typed candidate under the configured policy, not failure of every
external authentication contract.

#### 6.4. Actual primitives and the trusted-computing boundary

The byte-level [primitive interfaces](../../lean/TCB/PrimitiveChecks.lean)
record selected verification algorithms, exact message/public-input bytes,
signing-query history and compromised-key status. They supply no primitive
soundness, zero knowledge or numerical error estimate. The legacy
[proof carrier](../../lean/TCB/ProofCarrying.lean) and
[runtime acceptance contract](../../lean/TCB/Runtime.lean) instead package
already-established semantic facts: their well-formedness includes statement
truth. Their named `Prop` fields cannot turn a successful runtime check into
that truth. The [SNARK interface](../../lean/TCB/SNARK.lean) likewise records
assumptions; no SNARK backend is selected by the current
workspace `Cargo.toml`.

Runtime paths below refer to the full workspace; those implementations are
excluded from the Lean/manuscript review bundle. The implementation comparison
identifies distinct signed and proved objects:

| Existing implementation | Actual object and missing comparison |
|---|---|
| Worker signatures in `rust/node/src/consensus/pov.rs` | Ed25519 authenticates a 69-byte spectral message: domain, fingerprint hash, gap-valid bit and three Betti numbers. It does not sign the owner transfer intent or complete final proposal. A selected key registry, message encoder and exact verifier-agreement equation are required before this algorithm can instantiate owner authorization. |
| Bootstrap keys in `rust/node/src/main.rs` | The single-node path derives four signing seeds from the public producer fingerprint. That path does not justify an uncompromised-key assumption. An Ed25519 implementation alone supplies no authorization/error bound for this setup. |
| Raw graph commitment in `rust/node/src/crypto/commitment.rs` | Ordered ordinary-incidence differences, without general private cellular restrictions. A global constant translation changes the vertex-zero message while preserving every edge value. Payload authentication is distinct from binding that message. |
| Geodesic verifier in `rust/node/src/crypto/geodesic_zkp.rs` and transaction call path in `rust/node/src/consensus/pov.rs` | Sampled floating-point matrix, spectral and transcript checks. They do not receive the original cochain, trusted interpretation or owner intent required for `Context.Accepted`. No bound `2^{-n_opened}` or SNARK/zero-knowledge property is established. The audited parser/call path also does not establish the canonical, fail-closed packet contract: trailing bytes can remain unconsumed and malformed optional proofs can be skipped. |

The [graph model](../../lean/Sheaf/GraphCommitment.lean) proves the constant
translation law over additive groups and constructs the existing modular
`CochainCommitmentData`. With a fixed topology tag, translating every stalk
by the same vector leaves the complete payload and every deterministic
encoding/hash of that payload unchanged. Its path example changes openings
`(3,5,9)` to `(10,12,16)` modulo `12289`, preserving edge values `(2,4)` while
changing the message. This is equality before hashing, not a cryptographic
hash collision. It concerns this ordinary-incidence profile, not all cellular
sheaves, harmonic blinding or a plaintext defined as a quotient class.

The [protocol adapter](../../lean/Protocol/Transfer/Primitives.lean) explicitly
binds each operational check to its chosen backend. `SignatureProfile` supplies
actual owner-to-key and owner/intent-to-message functions, a signing history,
and exact check agreement. `PayloadProfile` supplies the actual encoded proof
input and check agreement. Neither agreement equation supplies semantic
soundness or identifies arbitrary decoders sharing public names.

For the original parsed packet, accepted-invalid outcomes are covered by five
events: a verified fresh-message signature under an uncompromised key; a
verified unauthorized packet using a compromised key; a queried key/message
accepted for an unauthorized intent; a proof backend accepting a false backend
statement; or a true backend statement that fails to imply acceptance of the
original context. The queried-but-unauthorized event retains policy failures,
key aliasing and message-encoding collisions rather than silently assuming
these away. The last event keeps backend soundness separate from the required
original-interpretation comparison.

One shared PMF gives the sum of these five event probabilities and composes
supplied budgets, without independence. To apply a primitive forgery estimate,
the history must cover every honest signature made available in the released
record or auxiliary input, and the key registry and corruption classification
must match the actual setup. The fixed-history model is still not an adaptive
EUF-CMA oracle game. No event receives a numerical budget from the presence of
an algorithm name or the runtime checks above.

Section 6.5 constructs the owner-message/check/history binding relative to the
existing supplied codec. Concrete authenticated keys, cross-language canonical
bytes, backend statement reflection for the same original cochain interpretation,
primitive/query/setup error bounds and parser/runtime contracts remain to be
instantiated. The legacy TCB carrier supplies none of those runtime or secrecy
guarantees.

#### 6.5. Full-intent signing and authorized issuance from existing objects

The [reuse inventory](../../docs/PROTOCOL_PARITY_QUEUE.md#existing-objects-reused-for-owner-signing--2026-11-07)
keeps the actual resource catalogue, full `Intent`/metadata, `PacketCodec`,
selected `keyFor` function, byte-query history and released-view carrier.
It introduces no new account registry or credential issuer. The recovered
path-space-signature plan intended message-bound proof of private fibration/path
possession; its verifier sketch is not a secure implementation. The present
backend/key type remains generic, with no selection of Ed25519 for owner
authorization. Its native witness relation should reuse the existing private
representative and `EphemeralFiberSpec.path`/admissibility setup, with the
appropriate typed-equivalence adapter where required. Verification must bind
knowledge of the designated authorized private witness to the exact message
and public credential commitment. A path or class-membership existence theorem
alone supplies neither knowledge nor unforgeability; the path need not be
published. Those native proving/verification and security results remain open. Here issuance means recording an authorized signing request and
output, not issuing a credential. The
[plan-to-primitive table](../../docs/PROTOCOL_PARITY_QUEUE.md#recovered-native-authentication-plan-and-existing-primitive-layer--2026-11-07)
retains that distinction and the existing typed Hodge-blinded construction.
Committee votes
have validator targets; `ContextKey` and recipient delivery scopes are public
names; geometric presentation rotation transports recovery material; Helfer's
`Signature` is logical vocabulary. None is silently substituted for owner
signing authority or secret key custody.

[Signing](../../lean/Protocol/Transfer/Signing.lean) defines

\[
\operatorname{SignBytes}(\mu,\iota)
=\texttt{HCRYPT\_OWNER\_INTENT\_V1}\mathbin\Vert
\operatorname{encode}(\operatorname{skeleton}(\mu,\iota)),
\]

where \(\mu\) is the full metadata and \(\iota\) the original intent. The
skeleton is the existing packet with its signature and proof fields empty.
There is no recursive signature/proof output in its own signing input.
The existing codec roundtrip law proves that equal signing bytes imply equality
of **both full metadata and the original full intent**. No injectivity of
hashes or owner-to-key lookup is needed. The literal owner prefix is disjoint
from every message under the existing worker spectral prefix. This constructs
a signing message relative to the supplied codec, not a concrete Rust serializer
or an implementation of a signature primitive.

[Issuance](../../lean/Protocol/Transfer/Issuance.lean) records actual metadata,
existing intent and signature bytes together with authorization under one fixed
actual relation. The owner is derived from `intent.transfer.signer`; there is
no independently supplied second owner. Its byte history is exactly the mapped
key/signing-message queries followed by a supplied foreign batch. Every foreign
message must lie outside the owner-intent domain. Consequently every logged
owner-domain query is explained by a typed authorized issuance, and full-intent
reflection recovers authorization even when different owner labels share a key.
Matching policy names do not identify different authorization relations.

Signature coverage is a separate predicate on actual metadata, intent **and
signature bytes**. Its projection gives key/message query coverage; membership
in the byte-query list alone does not identify which signature was disclosed.
Appending records preserves earlier coverage and queries. These are batch
records under the selected policy and epoch profile, not an adaptive signing
oracle or chronological revocation protocol. A revoked-policy owner-domain
signature cannot be put into the foreign batch merely by changing its label;
all such disclosed queries remain history/authorization obligations.

[Authorization](../../lean/Protocol/Transfer/Authorization.lean) now constructs
the raw checker from the selected backend, existing key map and full-intent
message. Its primitive-profile agreement is reflexive (`rfl`). The original
context, full intent and semantic policy are preserved, as is the candidate
constructed from the same parsed packet. Under the
actual typed-history/foreign-domain conditions, queried-but-unauthorized
acceptance is impossible, so its probability is zero. The configured experiment
retains the selected view, auxiliary data, tape, adversary and attempted bytes.
Its accepted-invalid bound therefore has four remaining masses: fresh forgery,
compromised key, backend proof false acceptance and original-context statement
mismatch. Their numerical budgets remain supplied premises.

The same [released-view carrier](../../lean/Protocol/Transfer/PublicView.lean)
now has `PublicTransferView.ofOperational`, derived directly from actual raw
checks without assuming perfect primitive soundness. For a release checked
under the newly constructed checker, `issueOfChecked` retains its exact parsed
metadata, intent and verified signature, given an **independent authorization
fact**. Adding that record covers the signature in this actual view. No theorem
relabels acceptance of a legacy worker signature as acceptance on the new bytes.
Secret signing execution, authenticated registration, complete disclosure
history, concrete wire refinement, primitive error bounds and adaptive security
remain separate work.

### 7. Proof ledger and remaining protocol work

The successful Lean 4.35 builds of 9,233 aggregate/integration jobs and 9,228
default jobs, and the 68-declaration audit, are the **pre-addition baseline**.
They do not validate the newer modules merely because the pin is unchanged.
The completed native-metric follow-up's aggregate/integration union passes
**9,253 jobs**, and its literal default build passes **9,248 jobs** on the same
pin. Its
consolidated probe through public facades passes for **139 distinct selected
endpoints**, with sets exactly matching the individual reports: 100 use
exactly the three standard axioms, three use a subset, and 36 retain only
existing native certificates beyond them. None uses a cited-bound axiom or
`sorryAx`. That record's Paper 1/Paper 3 PDFs have 97/28 pages; all 125 overview
pages and changed pages have been inspected. Final formatting/artifact details
and current PDF hashes belong to the
[shared validation record](../../docs/MATH_STORAGE_VALIDATION.md), separately
from the preserved pre-addition baseline. No publication or Palomar protected
preflight has been performed.

The actual Helfer/cellular/HCP observation wiring is a separate follow-up to
that native-metric baseline. Its latest build and dependency outcomes belong
to the same [central validation record](../../docs/MATH_STORAGE_VALIDATION.md);
the earlier counts are not validation of the added modules.

| Material / source owner | Checked endpoint and boundary |
|---|---|
| [Actual cochain model and homological tests](../../lean/Helfer/CochainModel.lean) | Focused compilation and the selected dependency probe pass. The actual bounded-below Quillen model carries the cellular coboundaries; strict/isometric chain isomorphisms give typed Helfer equivalences. Nonzero-cohomology closed tests are proved invariant for all interpretations. This is an explicitly named fragment, not full Helfer first-order fibrational semantics or Theorem 12.3. |
| [Concrete integral coexact-axis family](../../lean/Sheaf/HCPAxisFamily.lean) | The focused integration includes actual cellular restrictions, stalk lattices, a harmonic lattice presentation, the true operator with positive spectral gap one, and harmonic-message/coexact-noise samples. The shared full cochain and zero exact components are separate from equality of snapshots or public artifacts. Current validation outcomes are recorded centrally. |
| [Actual HCP realization](../../lean/HCP/AxisFamily.lean) | The focused integration build passes for the stated endpoints. Actual matrices and the homological closed theories form `HCPBridge.Realization`, with a common `(class,b)` observation and distinct nonzero operative targets. Existing no-recovery/CVP-oracle results and positive discrete CVP recovery are reused. Coordinate-target ambiguity alone does not distinguish semantic plaintexts or supply a privacy game or equality of the full storage view; current dependency outcomes are recorded centrally. |
| [Original bound-observation adapter](../../lean/TCB/HCPRealization.lean) | The focused adapter build passes. Operator-action and classifier alignment retain the original bound sample, payload, interpretation and artifact; kernel/projector/operative-message agreement and the stated discrete CVP comparison are derived. A richer view inherits no-recovery only under its explicit factorization hypothesis. The adapter does not manufacture snapshot, hash or verification contracts. |
| [Concrete artifact-bound family adapter](../../lean/TCB/HCPAxisFamily.lean) | The final focused glue build passes. Actual operator alignment and the computed positive spectral gap one instantiate the declared spectral gate/window. `bindSample` retains an existing artifact and derives the same operative-target/CVP join. Acceptance, hash/snapshot binding, decoding of the zero exact component and the snapshot-classifier equality remain application inputs; the adapter does not construct a dummy artifact or equality of full public views. |
| [Presented-coefficient recovery](../../lean/Sheaf/CoefficientRecovery.lean) | Integer encoding is injective; the exact partial decoder reads the observed cochain and private presentation. Valid encoded inputs recover their original coefficients. Full intrinsic-lattice coverage and an efficient byte algorithm are not inferred. |
| [Integral Hodge rotation](../../lean/Sheaf/Rotation.lean) and [actual axis rotation](../../lean/HCP/AxisRotation.lean) | Actual message and exact/coexact noise transport, projector naturality, inverse and composition; an explicit integral law and all-coefficient encoding law. The concrete weighted rotation preserves two while changing the observation to `(2,1)`. |
| [Presented recipient profile](../../lean/Protocol/Ephemeral/Rotation.lean), [delivery](../../lean/Protocol/Ephemeral/Delivery.lean) and [axis receipt](../../lean/Protocol/Ephemeral/Examples.lean) | Both recipient routes preserve plaintext; original contexts, recipient, epoch labels, actual private material and envelope index explicit authorization/delivery relations. Scope rejection supplies neither caller authentication nor replay prevention. |
| [Original bound-sample migration](../../lean/Protocol/Ephemeral/HCP.lean) | Actual transported sample equality derives the decoder/payload migration law from existing exact-component bindings. Both routes recover the source coefficients under its presented-point equality. Target construction retains the original supplied artifact and binding/acceptance contracts. |
| [Existing transition kernel](../../lean/Protocol/Ledger/Transition.lean), [candidate evidence](../../lean/Protocol/Evidence/Transition.lean) and [history anchor](../../lean/Protocol/Storage/Anchor.lean) | Baseline checked conservation, replay exclusion and same-object/context joins under explicit authentication, policy and backend relations. These do not instantiate a production protocol. |
| [Owned-resource kernel](../../lean/Protocol/Ledger/OwnedResource.lean) | A positive owner/asset/amount catalogue, one-input/one-output action, source-derived public spend identifier and actual inventory-coordinate laws. Structural checks derive conservation and freshness; inventory preservation retains its initial invariant hypothesis. The positive mechanical fixture constructs no runtime, hash or owner-authorization proof. |
| [Acyclic transcript](../../lean/Protocol/Evidence/TransferTranscript.lean) and [input manifest](../../lean/Protocol/Storage/TransferManifest.lean) | Explicit content/draft/intent/packet/block preimages and reconstruction of omitted metadata. The exact one-entry original-payload seal is prepared independently of later packet/block digests. Typed hashing supplies no injectivity, canonical-byte implementation or six-stage gate completeness. |
| [Soundness-free packet checking](../../lean/Protocol/Evidence/TransferCheck.lean) and [exact verifier specialization](../../lean/Protocol/Evidence/TransferVerifier.lean) | Parsing, canonical bytes and complete metadata/intent equality guard the actual Boolean algorithms. Raw checked records assume no semantic soundness; exact interfaces project to the same checker and use their separately supplied contracts to derive authorization and payload exactness under the actual trusted interpretation. |
| [Operational transfer](../../lean/Protocol/Transfer/Operational.lean), [ideal checked transfer](../../lean/Protocol/Transfer/Owned.lean) and [anchored endpoint](../../lean/Protocol/Transfer/Anchored.lean) | Local authorization and original-payload acceptance derive validity of the candidate computed from the actual parsed packet. The exact checker/policy/candidate projection preserves the ideal theorem. Complete packet, original artifact/context and input manifest remain joined; a matching whole-proposal quorum remains an external input. |
| [Actual transfer view](../../lean/Protocol/Transfer/PublicView.lean) | Publishes this checked release's bytes, parsed packet, complete proposal and original input-manifest view. `ofOperational` reuses the same carrier for actual raw checks without perfect primitive soundness. Public input/output/signer differences distinguish records; the deterministic input-ID test needs no private witness or hash inversion. This supplies no privacy theorem or complete network transcript. |
| [One-shot sampled integrity](../../lean/Protocol/Transfer/Security.lean) | Accepted-invalid outcomes for the actual soundness-free checker imply authorization or exact-payload verification failure. One shared PMF yields the union bound and composition of supplied error budgets without independence. `ofCheckedRelease` provides an actual released observation. No primitive estimate, adaptive oracle game, security-parameter family or privacy claim is inferred. |
| [Actual byte-level primitive checks](../../lean/TCB/PrimitiveChecks.lean) | Selected signature/proof algorithms, exact byte-indexed backend statements, signing-query history and compromised-key predicate. Successful verification is classified without a global soundness, zero-knowledge or numerical-error assumption. Legacy TCB comments distinguish these raw checks from carriers whose well-formedness already includes statement truth. |
| [Primitive-to-original-transfer comparison](../../lean/Protocol/Transfer/Primitives.lean) | Exact owner/key/message and payload-input check-agreement equations retain the same operational configuration and parsed packet; §6.5 constructs the owner signing equation for the selected new checker. Accepted-invalid outcomes reduce to fresh forgery, compromised key, queried unauthorized message, backend proof false acceptance or original-context statement mismatch. Their shared-PMF sum composes supplied budgets; current Rust algorithms are not claimed to discharge those contracts or estimates. |
| [Full-intent signing](../../lean/Protocol/Transfer/Signing.lean) | The existing packet codec encodes an empty-signature/empty-proof skeleton under the literal owner domain. Equality reflects full metadata and intent; worker spectral messages have a different prefix. The codec remains supplied; no concrete Rust serialization, hash injectivity or signing algorithm is inferred. |
| [Typed authorized issuance](../../lean/Protocol/Transfer/Issuance.lean) | Actual metadata, intent and signature bytes carry authorization for the intent-derived signer under one fixed relation. The existing key map/query history is reused, with explicit foreign non-owner-domain queries. Owner-domain query reflection recovers authorization without key injectivity; actual-signature coverage remains separate from key/message query membership. |
| [Constructed owner authorization](../../lean/Protocol/Transfer/Authorization.lean) | The selected backend/key map construct the raw full-intent checker and a reflexive profile-agreement equation, preserving the original context/intent/candidate/policy. The actual typed history rules out queried-unauthorized mass and yields the four-term configured-experiment bound. An independently authorized release checked under this new checker can be recorded with its exact signature and `PublicTransferView.ofOperational` coverage. No secret signing execution, registration, numerical bound or general history/revocation game follows. |
| [Ordinary graph commitment ambiguity](../../lean/Sheaf/GraphCommitment.lean) | Constant translation preserves actual modular `CochainCommitmentData`, fixed topology and every deterministic encoding while changing a designated message coordinate. The explicit path example has messages three/ten and identical edge values two/four. It refutes raw message binding for this profile, without claiming a hash collision, a hiding theorem or an obstruction for every cellular sheaf. |
| [Semantic evidence compatibility](../../lean/Protocol/Evidence/TransferEnvelope.lean) | Packages independently derived validity/check facts in the existing TCB envelope, with the actual candidate/transfer witness and public intent shadow. Its root/inclusion and runtime facts are supplied or proved by the selected profile; it is not an additional operational verifier or security proof. |
| [Plucker reconstruction](../../lean/Proximity/Concrete/GrassmannianPlucker/Reconstruction.lean) and [operative-target adapter](../../lean/TCB/PluckerObservation.lean) | Eight reconstruction endpoints and the observation endpoints in the 27-declaration root probe are standard-only. Recovery consumes full exact-real shadow data and an explicit operative-kernel identification; digest-only visibility is a separate profile. |
| [Canonical-lift obstruction](../../lean/Sheaf/CanonicalLiftObstruction.lean) | Thirteen core/sheaf endpoints are standard-only. A nontrivial real-linear decoder cannot have a global zero-defect comparison against unrestricted canonical RS distance. |
| [Systematic cellular realization](../../lean/Sheaf/SystematicCode.lean) and [integer/field checks](../../lean/Proximity/Core/Systematic.lean) | Six representative generic endpoints are standard-only. The actual coboundary realizes the selected integer-lifted generator; it is not an identification of an arbitrary HCP sheaf. |
| [Intrinsic modular source validity](../../lean/Sheaf/SystematicCode/Modular.lean) | Eight endpoints are standard-only. Integral head-stalk openings and actual `delta0` plus integer carries prove equivalence with RS pair validity. Real acceptance remains distinct. |
| [Full coordinate codec](../../lean/Protocol/Storage/CoordinateCodec.lean), [no-wrap criterion](../../lean/Protocol/Storage/NoWrapCalibration.lean) and [three native metrics](../../lean/Protocol/Storage/ThreeLevelMetrics.lean) | The 27-declaration root probe, also including distance reflection and the two operative-target adapters, is standard-only. It covers all-integer plane equality, separate scalar lifting, the factor-two native comparison and the coarse Euclidean no-wrap criterion. |
| [Scalar/pair metric comparison](../../lean/Proximity/Core/InterleavedMetric.lean), [capacity-far pair](../../lean/Proximity/Core/DeepHole.lean) and [fixed-mix obstruction](../../lean/Proximity/Core/FixedChallenge.lean) | Eleven selected generic endpoints are standard-only. Both power-word columns have native distance `(n-k)/n`; arbitrary fixed nonzero mixes admit a cancelling capacity-far pair. |
| [Sharp native near factor](../../lean/Proximity/Core/MetricSharpness.lean) | The checked actual RS pair `(deep hole,0)` has pair distance twice its scalar-coordinate distance; the global native unit near bound is false. All four selected fresh dependency reports are standard-only. |
| [Zero-direction challenge](../../lean/Proximity/MCA/ZeroDirection.lean) and [diagonal challenge](../../lean/Proximity/MCA/Diagonal.lean) | Eleven endpoints in each probe are standard-only. All challenges are good in the zero-direction profile; diagonal non-codewords have exactly the one cancelling challenge. No global fixed-mix claim follows. |
| [Canonical systematic profile](../../lean/Protocol/Storage/CanonicalSystematic.lean) | Fifteen selected concrete endpoints inherit the existing canonical primality/root-order native certificates. They include the original payload codec and a positive no-wrap Euclidean example; native arithmetic trust remains explicit. |
| [Canonical native-metric and challenge adapter](../../lean/Protocol/Storage/CanonicalThreeLevel.lean) | The focused build passes (3,432 jobs). Sixteen selected reports retain existing canonical arithmetic trust. The original well-formed payload has all three native distances `3/4`; observed-artifact joins, accepted-to-native-zero, raw-far rejection and the stated canonical diagonal challenge are checked. Expanded aggregate and consolidated public-facade dependency checks pass; artifact details remain centrally recorded. |
| [Existing calibration and near interfaces](../../lean/Protocol/Storage/CanonicalCalibration.lean) | The focused build passes (3,430 jobs). Nine selected reports split into four generic standard-only and five concrete reports with existing native certificates. Actual original-payload extraction instantiates `SourceToSourceCalibration`, `SourceToCodeCalibration.transCode` and `EvaluationProjection` with the explicit `2*d_C` near score; no metric inequality is assumed. |
| Paper 2 security and runtime realization | The fixed-setup one-shot integrity experiment is scoped and its conditional error composition is proved. The actual primitive comparison and five-event decomposition now name check agreement, key/message history and backend/original-statement gaps. Instantiate those contracts and failure bounds; specify a parameter/key-generation family, adaptive oracle/corruption games and any privacy claim. Authenticated setup/state origin, secure delivery, persistence, dynamic geometry/key rotation, retirement, finality and runtime refinement remain obligations. |

“Standard-only” means that the actual axiom report uses no dependencies beyond
`propext`, `Classical.choice` and `Quot.sound`; some elementary identities use
a subset. The concrete canonical reports additionally expose the existing
generated `_native.native_decide.ax_` certificates. These checks cover the
listed endpoints, not every declaration or a complete protocol security claim.

The completed native-metric baseline's static inventory contains 234 modules
plus the Lake configuration, with no active proof holes, local import cycles or unresolved
local imports. The same seven explicit cited-bound axioms remain isolated.
That baseline's standalone coding closure has 33 modules, bounded protocol core
33 and storage core 79. Current closures including the semantic observation
follow-up are tracked centrally. A short logical-axiom list does
not instantiate authentication, a private-frame producer or runtime refinement.

The runtime must authenticate the chosen sheaf, coefficient convention,
coordinate layout, validity predicate and metric/radius profile. A later key
or epoch transition must specify the authorized transport, retained encrypted
objects and retirement conditions. Neither snapshot equality nor local bus
consumption proves physical erasure or a geometry migration protocol.

Paper 3 can consume the native-distance comparisons and its coding theorems
without waiting for these broader runtime features. A claimed new commitment,
MAC or encryption scheme still needs its algorithms, adversary model and
security argument.
