# Proof-Carrying Transactions for Homotopical Encryption

## Working manuscript

This manuscript develops storage, verification and transaction interfaces
for the encryption mechanism established in the [HCP paper](../paper1/main.pdf).
The [protocol reading copy](construction.pdf) presents the bounded construction;
this working inventory records the wider interfaces. The
[shared parity table](../../SEMANTIC-PARITY.md) records ownership and status.

### Abstract

We construct proof-carrying transaction interfaces for homotopical encryption.
An exact-component commitment can remain fixed while the full encrypted
cochain changes. A canonical two-slot manifest therefore names both objects;
its root is retained by owner authorization, checked packets and accepted
history. A separate native certificate connects the selected ciphertext bytes
to the original Hodge observation and its recoverable message. Canonical
subjects and predecessor gates consume the same submitted proof bundle at
every verification level. Scoped delivery and hash-addressed lookup join
recipient recovery to those original objects. Bounded native relations and
approved execution bind the verifier to its expected program, key and CRS.
A conditional adaptive CRS reduction applies to the original raw-root profile;
the nonce-bearing profile has its own versioned relation and context checker.

### 1. Problem and contributions

A transaction should identify the encrypted object on which it acts and
verify authorization for that same object. A commitment to the exact
component alone does not identify the full Hodge cochain. The transaction
must retain both references through verification, state transition and
recipient recovery.

The construction has four parts:

1. A canonical manifest separately names the exact artifact and full
   ciphertext. A native certificate relates its decoded bytes to the original
   observation; the same root enters the signed intent and computed history.
2. Canonical certificate subjects retain the full intent, metadata, selected
   profile and ciphertext digest. Every later gate consumes all required
   preceding checks on the same seven-leaf bundle and evidence database.
   The canonical modular profile also checks a sampled scalar fold of the
   pair fixed by the original transfer intent.
3. Scoped delivery and token execution join hash-addressed lookup to recovery
   of the original coefficients using the actual contexts and available bytes.
4. Bounded native relations and approved execution bind owner checking to the
   exact program and parsed key/CRS. The conditional signature-of-knowledge
   reference and nonce-bearing version retain distinct security experiments.

### 2. Maintained geometry, temporary processing and retained artifacts

#### 2.1. Encryption interface and artifact binding

Use the [HCP paper's coupled encryption](../paper1/main.pdf) with private
presentation \(B\), coefficients \(z\), and exact and coexact openings
\(a,u\). The observed cochain is \(b=\operatorname{Enc}_B(z,a,u)\). Its
canonical bytes are \(E_B(z,a,u)\). The recipient reads those bytes with
the original private presentation to recover \(z\). The protocol retains
the actual snapshot and observation in its artifact binding and uses the
same recovery interface for delivery and lookup.

The exact payload encodes \(\delta_0a\). The original observation binds the
payload's real decoder to that exact summand. The manifest assigns separate
digests to the exact artifact and the full ciphertext. The native
certificate identifies the retained ciphertext with the original
observation in that context.

#### 2.2. Base public input and declared disclosures

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

For fetching and tracing encrypted material, the content ID is the hash of
its selected canonical ciphertext bytes. Public records can link that ID to
context, evidence and permitted successor events. This is the intended
hash-linking role across the stack. The public encoding is chosen explicitly;
it does not serialize the private sheaf, identity witness, opening or
transport token merely because a semantic record retains them. Repeated
content IDs and published successor links are observable. The ciphertext ID,
exact artifact digest and enclosing roots retain their distinct preimages.

The intended privacy profile allows actions and policy evidence to be
audited while the actor's identity remains private. An authorization proof
must bind the action and its context to the required credential/policy
predicate without disclosing that identity. This target does not require
identity decryption for action tracing. It still requires a concrete
credential/proof construction and an explicit metadata threat model. The
bounded owned-transfer example below publishes owner and signer IDs and
does not instantiate this privacy profile. Private information retrieval
addresses which object a reader fetches; oblivious message retrieval can
also hide the message-to-recipient mapping
([UnifOMR](https://eprint.iacr.org/2026/910)). These retrieval guarantees are
separate from anonymous action authorization. The existing uniform-read
profile keeps selection local after a whole-bucket download; an efficient
PIR/OMR construction remains open.

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

For the integral coupled family below, the matrix, scalar stalks, standard
stalk lattices, graph basis and Euclidean metric form one fixed profile.
Its [canonical presentation codec](../../lean/Protocol/Storage/CoupledCodec.lean)
records the row and column counts followed by the integer matrix entries in
row-major order. The versioned domain fixes that interpretation. Signed
magnitudes use tagged base-256 digits; the decoder rejects noncanonical bytes,
wrong domains, trailing data and proper truncations. The
[snapshot adapter](../../lean/Protocol/Storage/CoupledBinding.lean) checks the
canonical byte hash against the original snapshot root and proves exact
presentation recovery or a concrete byte collision. Snapshot authentication
and the observation/classifier join remain explicit contracts. Presentation
bytes are private witness material in the hidden-operator profile; a public
digest still requires its own confidentiality analysis.

For a bound sample, the decoded exact payload equals \(\delta_0a\), whereas
the full Hodge cochain is \(b=h+\delta_0a+\delta_1^*u\). Thus
\(b-\mathrm{decode}(c)=h+\delta_1^*u\) in the selected interpretation, as
proved in [HCPObservation](../../lean/TCB/HCPObservation.lean). The raw
public payload alone does not specify a real decoder.

The canonical systematic RS sheaf has \(\delta_1=0\). For a bound sample whose
interpretation decoder agrees with the canonical layout on its artifact, an
explicit full-cochain disclosure and its public exact payload give
\(h=b-\mathrm{decode}_{\mathrm{layout}}(c)\). This direct recovery is proved
in [DisclosureLeak](../../lean/Protocol/Storage/DisclosureLeak.lean). That
canonical profile therefore cannot serve as a confidentiality example when
both values are released. The base storage view alone does not release \(b\).

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

The systematic cellular profile constructs this relation from the actual
coboundary. [Paper 3](../paper3/sections/07-application-interface.tex)
proves its equivalence with the selected finite-field RS code. Its definition contains neither a coding-distance comparison nor a
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

Projective extensions retain the disclosure and binding conditions in
§§2.2 and 5.

#### 3.1. Payload operations and commitment interfaces

The payload is the existing
[CochainCommitmentData](../../lean/Axioms/CochainCommitment/Payload.lean),
not a second commitment carrier. Its declared byte layout has an eight-byte
modulus/count header, eight bytes per edge value and a sixteen-byte topology
tag. Lean's integer list and natural-number count do not by themselves prove
bounded serialization or a parser refinement. `WellFormed` requires the
canonical modulus `12289`, agreement of declared and actual counts, and a
positive count. A zero edge vector can satisfy this shape predicate.

`AddCompatible` requires both payloads to be well formed and to share modulus,
edge count and topology tag; `add` then adds their corresponding edge values.
These are payload-level conditions. Interpretation as one cochain addition
also requires the same authenticated ambient sheaf/decoder profile. A matching
topology tag alone supplies no such authentication. The raw coboundary
identifies openings only modulo `ker delta0`:

\[
\delta_0a=\delta_0a'\quad\Longleftrightarrow\quad
a-a'\in\ker\delta_0.
\]

The following existing interfaces state separate constructions or contracts.
Their presence does not assert that their cryptographic assumptions have been
instantiated:

| Interface and existing owner | Construction or supplied contract | Remaining boundary |
|---|---|---|
| [CochainCommitmentAxioms](../../lean/Axioms/CochainCommitment/Security.lean) | Exact-payload binding, wrapper hiding, context binding, declared homomorphic operations and partial-opening soundness. | The bare coboundary proves neither uniqueness of a degree-zero opening nor a hiding game. The selected encoding, authenticated context and security experiment must justify the claimed fields. |
| [HodgeBlindingContext and BlindedCommittedCochain](../../lean/Axioms/CochainCommitment/Blinded.lean) | An accepted exact base decodes to `delta0 a`; a separately typed value is `decode base + s • H_tau`. The chosen direction is harmonic and the exact component is orthogonal to it under the ambient Hodge contract. | The scalar `s` is distinct from the opening `a`. This real-cochain value is not identified with the serialized modular payload. Deterministic context selection, authenticated-value binding and distributional hiding remain explicit fields of `BlindedCommitmentAxioms`. |
| `VectorCommitmentAxioms` in [Security](../../lean/Axioms/CochainCommitment/Security.lean) | Honest-opening completeness, soundness of the revealed local coboundary equations, and authenticated positions. An edge equation uses both endpoint values in the revealed set. | A boundary edge with an unrevealed endpoint needs additional authenticated data. Local equation soundness does not select a unique global degree-zero opening. |
| `CohomologicalMACAxioms` in [Security](../../lean/Axioms/CochainCommitment/Security.lean) | Correctness, unforgeability, key binding and determinism are supplied interface propositions for the proposed Hodge-projection tag. | The cochain map for the tag, key generation, tag/verification algorithms and adversarial game are not constructed by this record. Applying harmonic projection to the same exact payload alone gives zero, so that payload cannot silently be used as a nontrivial tag input. |
| [HashedCommittedCochain and ProofCarryingCommittedCochain](../../lean/TCB/ProofCarrying.lean) | Wrappers retain the same original payload, declared digests and proof/statement relations. | The legacy `WellFormed` predicate includes supplied statement truth. The operational checker and its indexed primitive-soundness contracts are separately specified in §§6.2–6.4. |

Exact payload binding, hiding of a chosen witness, local opening soundness,
owner authorization and harmonic-message recovery concern different objects
and experiments. The protocol must state which of them its released record
is intended to support.

When a profile invokes
[Axioms.ZKPWellFormed](../../lean/Axioms/ZKP.lean), completeness, soundness,
zero knowledge and statement binding are explicit interface inputs. That
record is not a constructed proof system. The indexed primitive checks and
one-shot error experiment in §§6.2–6.4 state the separate assumptions used by
the operational transfer checker.

#### 3.2. Local syndrome and accepted-payload realization

The local target uses the same payload carrier. For an authenticated
interpretation `S`, let `G_S` denote its accepted coherent payloads. A
[LocalSyndromeTarget](../../lean/Proximity/Concrete/PluckerCochain.lean)
supplies a syndrome map `sigma`, a valid-syndrome set `Z` and a score `d_L`,
with the implication `c in G_S -> sigma c in Z`. Its local code requires
both acceptance and a valid syndrome. The converse from a well-formed payload
and valid syndrome requires the separately declared `SyndromeAdequacyGate`;
it is not a consequence of the target's definition.

The legacy [SheafCoherence](../../lean/Axioms/SheafCoherence.lean) profile
also names restriction-shape compatibility, edge and triangle naturality,
the actual coboundary-square equation, Hodge construction/orthogonality and
finite, simplicial and connected nerve conditions. Its
`CommittedCochainWellFormed S c` combines payload shape, these ambient
conditions, binding to `S` and an actual decoded exactness witness. These are
additional profile contracts: Paper 1's algebraic finite-incidence examples
do not automatically instantiate every nerve or runtime condition. Once
the actual complex equation and exactness witness are available, the decoded
payload is a cocycle; a valid wire shape alone does not imply that conclusion.

The existing
[PayloadRealization and observed binding](../../lean/Proximity/Concrete/PluckerCochain/PublicBinding.lean)
relate the full projective datum to the original proof-carrying payload under
an explicit acceptance implication. This relation does not construct the
payload bytes or prove a privacy property. A deterministic encoder is one
specialization; the storage-facing relation also permits an already retained
artifact without changing its identity. Any use of the commitment-sum
syndrome additionally supplies the premise that accepted payloads have zero
sum. Its binary residual is not identified with a native Hamming distance.

#### 3.3. The systematic cellular source and complete coordinate profile

The selected construction uses the existing
[systematic interpolation](../../lean/Proximity/Core/Systematic.lean) and
[SystematicCode cellular sheaf](../../lean/Sheaf/SystematicCode.lean).
Fix prime `q`, an RS parameter object `P` on a finite evaluation index set
`I` of cardinality `n`, and an information set `S` of cardinality
`k = P.degreeBound`, with `0 < k <= n` and the declared injective evaluation
points. Let `G_is` be the actual RS interpolation basis coefficient from
information position `s` to evaluation position `i`, and let `Ghat_is` be its
canonical integer lift. This is the existing `integerCoefficient`; it is not
an independently chosen generator matrix.

The base has two vertices, one edge and no faces. Each vertex stalk is
`R^(S x Fin 2)` and the edge stalk is `R^(I x Fin 2)`, with the declared
Euclidean inner products. Integral input coordinates are embedded as below. The tail
restriction is zero; the head restriction is the real linear map obtained
from `Ghat`. With incidence signs `-1,+1`, the actual coboundary is

\[
(\delta_0(a_{\rm tail},a_{\rm head}))_{i,j}
  =\sum_{s\in S}\widehat G_{is}(a_{\rm head})_{s,j},
\qquad \delta_1=0.
\]

An integral opening `a : S -> Fin 2 -> Z` is embedded in the head stalk,
with zero tail. The source predicate
[ModularExact](../../lean/Sheaf/SystematicCode/Modular.lean) asserts an
integer carry in the same original edge coordinates:

\[
\exists a\;\exists m:I\times\operatorname{Fin}2\to\mathbb Z,
\quad \forall i,j,\quad
(\delta_0(\operatorname{integralOpening}(a)))_{i,j}
  =z_{i,j}+q m_{i,j}.
\]

The integer coordinates on the right are embedded in the real edge stalk.
This defines source validity using the actual cellular map. Paper 3 proves
its equivalence with paired RS validity and the quantitative comparisons;
those conclusions are not premises defining this construction.

The existing [CoordinateLayout](../../lean/Protocol/Storage/CoordinateCodec.lean)
then fixes both a geometric bijection
`(I x Fin 2) ~= TotalCoord(edge stalks)` and a serialized-coordinate bijection
to `Fin (2*n)`. For a payload `c`, `raw c i j` reads the corresponding original
integer list entry, with the identity coefficient map. `layout.decode c`
reads those same integers as real coordinates, and the extracted finite-field
pair reduces those same entries modulo `q`. A bound `Context` supplies the
required list length; using its real interpretation additionally retains the
actual equality between `C.interpretation.decode C.cochain` and
`layout.decode C.cochain`. Neither that equality nor the chosen ordering is
reconstructed from a digest.

The wire specialization is
[CanonicalSystematic](../../lean/Protocol/Storage/CanonicalSystematic.lean):
`q=12289`, `n=4096`, `k=1024`, the first 1024 evaluation positions as information
set, and evaluation root `11^3` of order 4096. Its one edge stalk has **8192
scalar coordinates**; the serialized count is a coordinate count, not the
number of geometric edges. Its mathematical serializer fixes the canonical
modulus and uses the zero topology tag; its complete layout is used by the
original payload/context adapters. That raw-payload fixture supplies no
authentication of a production topology or snapshot. The generic prime-`q` mathematical construction does not imply that
every modulus is admitted by the current wire-facing `SupportedModulus`
predicate. Finite packet/witness bytes, authentication and a runtime decoder
refinement remain separate from this declared mathematical profile.

### 4. Declared metric and calibration contracts

A projection run records the original source carrier, validity predicate,
coordinate layout, extraction and radius normalization. Paper 3 defines and
analyzes the distances used by that profile. The following names identify
the protocol's selected quantities without introducing a second metric theorem.

| Level | Selected object and normalization | Required validity/profile binding |
|---|---|---|
| Cochain | Original scalar coordinates; `d_C` uses `2*n` coordinates | The actual integral cellular coboundary modulo `q` in §3.3 |
| Plane | Extracted integer pairs; `d_P` uses `n` positions | The same modular source and declared coordinate order |
| RS | Reduced finite-field pairs; `D_RS` uses `n` whole symbols | The same evaluation parameters and interleaved RS code |

A complete coordinate layout alone does not identify an arbitrary decoder
or differently ordered sheaf with this systematic source. The protocol
retains the actual decoder equality and the geometric/serialized coordinate
alignment from §3.3. A local-syndrome score `d_L` remains a separate profile
field with its own adequacy and comparison contracts.

[Paper 3's application](../paper3/sections/07-application-interface.tex)
proves the modular metric comparisons, accepted-to-native-zero result and
scaled near/far calibrations for these original objects. The protocol consumes
those results through the existing
[SourceToSourceCalibration and SourceToCodeCalibration](../../lean/Proximity/Application/Calibration.lean)
and [EvaluationProjection](../../lean/Proximity/Application/Projection.lean)
interfaces. The
[canonical adapters](../../lean/Protocol/Storage/CanonicalCalibration.lean)
retain the same payload and extraction and the theorem's stated scale.

A near-distance handoff is not a far-preservation certificate. Evidence that
uses a far conclusion must retain the applicable `noncollapse` law and its
source model, or the actual
[LiftControl](../../lean/Protocol/Storage/Calibration.lean) witnesses and decoder
bound. Storage roots, exact acceptance and the existence of an extraction
supply none of those missing inputs. Policy records whether it checks real
`Context.Accepted`, intrinsic modular validity, or a raw-input proximity claim.

### 5. Geometric release and restricted source profiles

[Paper 3](../paper3/sections/07-application-interface.tex) owns full
projective reconstruction and the geometric source-calibration obstructions.
A protocol using its operative-target consequence must identify the released
full shadow with the actual sample's harmonic kernel at the fixed metric.
The existing
[operative-target adapter](../../lean/TCB/PluckerObservation.lean) records that
conditional use. The base visibility profile in §2.2 instead omits full
coordinates; a digest-only extension retains its own observable fields,
binding contract and security analysis.

A Euclidean source profile names its actual decoder, source restriction and
comparison witnesses. If it invokes
[NoWrapCalibration](../../lean/Protocol/Storage/NoWrapCalibration.lean), the
bounded coordinate envelope and integer-syndrome no-wrap condition must hold
for that same source. The canonical-lift and exact-component obstructions in
Paper 3 prevent treating these profile inputs as consequences of a wire
shape, canonical scalar representatives or common snapshot labels.

The claimed radius and far carrier must be those justified by the selected
Paper 3 theorem. A restricted geometric comparison is not an unrestricted
capacity-radius comparison. An accepted exact artifact and a raw received
proximity input remain distinct roles in the protocol.

### 6. Challenges and evidence consumption

The [sampled transfer profile](../../lean/Protocol/Transfer/Certificates/SampledMCA.lean)
fixes the original configuration, intended action and count radius \(r\)
before one uniform challenge in \(\mathbb F_{12289}\). The complete cochain
in the intent determines both columns under the canonical systematic
layout. Exact intent matching fixes the same pair in any accepted packet.
A response echoes the issued challenge, supplies the packet and exhibits
a polynomial of degree below \(k\) with fewer than \(r\) disagreements
with the challenged scalar fold. The original packet verifier still
runs, including its bundle checks when the configuration selects them.

If \(d_C(c)\ge r/n\), `Pending.far_acceptance_le` bounds the probability
that any response accepts by the actual same-set MCA bad-challenge
fraction for this fixed line. `Pending.far_acceptance_le_of_mca` gives
the selected code's error bound when supplied at that radius. This
experiment allows the response to depend on the draw. The scalar test
uses the sampled challenge separately from any fixed mix in the
projection certificate. A fixed mix used for a scalar soundness claim
requires its own restricted-line profile and goodness result from
Paper 3. The small-field bound here applies to one retained attempt.
Randomness generation, challenge delivery, session persistence and
response serialization remain implementation work.

A completed certificate statement must identify its source, metric handoffs,
radii, selected challenge experiment and root bindings. Current typed
certificates retain the supplied projection chain and calibrated far witness;
candidate-indexed evidence and anchors retain their actual objects under
explicit contracts. The selected finite certificate join is constructed below;
authenticated history and circuit refinement remain protocol obligations.

#### Projection certificates and retained evidence

Typed mathematical certificates retain the projection chain and its supplied
laws. Internal hard gates describe an intended local abort policy during
generation, encryption or decryption when an invariant fails; executable guards
and their refinement remain open. External verification parses and checks
received bytes. The legacy proposition-level `StageAdmissibility` interface
implements neither runtime guards nor those external checks.

The protocol consumes the existing projection objects rather than replacing
them with hash-named surrogates:

| Existing object | Protocol-owned obligation |
|---|---|
| [ProjectionChain.Chain](../../lean/Proximity/Concrete/ProjectionChain/Core.lean) | Identify the same original cochain, declared plane extraction and finite-field encoding with the authenticated context. The quantitative source-to-code comparisons are the Paper 3 results consumed under their stated hypotheses. |
| [Stage certificates and StateBus](../../lean/Proximity/Concrete/Gates/Stage.lean) | Retain each exact predecessor and its map/output identity. The selected projections supply both restriction and syndrome naturality squares at the cochain-to-plane and plane-to-RS boundaries, local layout nondegeneracy, codeword alignment, payload well-formedness/list shape, the expected coordinate count, selected-index bounds, codeword preservation and the near-distance handoffs. The accumulated certificate records these supplied conditions; it does not establish them for arbitrary extraction/encoding maps or create a far-preservation theorem. |
| [Hard and final gates](../../lean/Proximity/Concrete/Gates.lean) | Keep the source score, projective chart, full-shadow respect, semantic alignment, structural naturality and calibrated far witness explicit. Their concrete validation is distinct from a supplied certificate record. |
| [EvidenceDatabase and evidence records](../../lean/Proximity/Concrete/GateEvidence.lean) | Retain the actual certificate alongside seven named slots. The guarded transfer adapter compares the actual database with canonical subject/proof leaves and a computed root, deriving `DatabaseBound` on acceptance; legacy slot-only completeness does not supply that refinement. |
| [Storage.Projection](../../lean/Protocol/Storage/Projection.lean) | Maintain the six ordered storage stages `cochain`, `plane`, `rs`, `hard`, `naturality`, `final`, preserving the exact preceding prefix and original `Context`. These six manifest stages are distinct from the seven evidence slots. |
| [Checkpoint](../../lean/Protocol/Storage/Checkpoint.lean) and [ProjectionAnchor](../../lean/Protocol/Storage/ProjectionAnchor.lean) | Seal the exact completed manifest, require its matching persistence receipt before local consumption, and join that same prefix and evidence database to the candidate's authenticated references. Backend atomicity, global freshness, erasure and finality are not consequences of this local lifecycle. |

The [public certificate subject codec](../../lean/Protocol/Transfer/Certificates/Codec.lean)
retains the full proof metadata, original pre-proof intent, computed ciphertext
digest, selected public profile bytes, optional rational calibration and one
of eight claim tags. Its executable parser accepts exactly the canonical
encoding. The original intent and metadata use the existing packet codec's
empty-signature/empty-proof skeleton. No private certificate, opening or
presentation is serialized, and the enclosing gate/evidence/block root is
excluded from this preimage.

For a rational descriptor \(c=(s_n,s_f,t_n,t_f)\), the
[calibration check](../../lean/Protocol/Transfer/Certificates/Calibration.lean)
tests exactly
\[
 s_n\le s_f,\qquad t_n\le t_f,\qquad s_n\le t_n.
\]
Realization identifies all four exact rational casts with the selected real
calibration \(\kappa\); it determines that whole calibration rather than a
name. Raw invalid descriptors remain parsable and fail the validity check.
Final certification requires realization of its actual \(\kappa\), so an
invalid descriptor cannot establish that intended statement. This finite
profile does not encode arbitrary real radii or prove a far-preservation law.

Each [evidence entry](../../lean/Protocol/Transfer/Certificates/Evidence.lean)
contains the actual public subject and submitted proof bytes. Their canonical
encoding determines the leaf digest; a versioned ordered directory names all
seven leaves under one computed root. Accepted replacement of a named entry
returns that complete entry or exhibits unequal bytes with equal hashes.
The root preimage excludes its own root, the verification level and private
witnesses. Advancing verification therefore retains the same committed
bundle and root.

The [submitted bundle checker](../../lean/Protocol/Transfer/Certificates/Bundle.lean)
parses exactly seven entries, checks their canonical encoding and compares
each required subject with the exact expected subject. Hard verification
checks the first five slots, naturality the first six, and final verification
all seven. For fixed subjects, a later level executes every preceding check
on the *same submitted bundle*. The
[projection adapter](../../lean/Protocol/Transfer/Certificates/Projection.lean)
connects this execution to the actual transfer checker: failure of an earlier
prefix rejects the later transfer. Merely committing later slots does not
certify them.

The selected [intended statement](../../lean/Protocol/Transfer/Certificates/Statement.lean)
is defined on decoded subjects and an actual certificate relation:
\[
 \operatorname{Holds}(x)
 \;\Longleftrightarrow\;
 \exists S,\chi\;\bigl(\operatorname{decode}(x)=\operatorname{some}(S)
   \ \land\ \operatorname{Meaning}(S,\chi)\bigr).
\]
Canonical decoding proves the generic exact-intent reflection rule for this
statement, and the operational adapter executes the selected byte verifier
on that exact encoded subject and the packet's actual proof bytes. The
[native relation](../../lean/Protocol/Transfer/Certificates/Native.lean) is the
existing `NativeManifest.BindsOriginal` on the same raw seal. The projection
relation retains the actual hard, naturality or calibrated-final record and
its certificate, including the chosen chart and metric, together with the
original cochain/chain input equality. A public profile label alone supplies
none of these meanings.

**Proposition (Certificate consumption and predecessor checks).** In the
selected profile, successful packet checking gives an actual certificate for
the exact expected subject or false acceptance by the selected proof backend.
For a projection bundle, false acceptance is traced to the actual terminal
leaf proof, while all required earlier Boolean checks have also executed.
The final check cannot waive a failed hard or naturality prefix. The existing
mathematical and database predecessors are retained without rebuilding them.

`Projection.boundConfig` adds an executable database guard to the actual
transfer payload check. On that same decoded bundle it compares all seven
leaf digests and the computed root with the retained record's actual database.
Successful guarded acceptance derives `DatabaseBound` and the required
subject/verification checks from the same packet bytes. Its predecessor laws
keep that same database and bundle. Legacy slot-only `SlotBinds` propositions
do not substitute for these comparisons.

The construction supplies the public wire format, digest preimages,
encoding/statement reflection and actual verifier consumption. Section 6.6
composes supplied CRS algorithms with a concrete finite native relation and
authenticates the selected program/key/CRS bytes. Secure primitive
implementation, full circuit refinement and computational error estimates
remain separate obligations. The generic
reflection interface still permits arbitrary profiles; its supplied
reflection premise is discharged for the constructed statements above.
Profile choice determines the required certificate: an accepted exact native
context need not carry a calibrated far-region certificate.

The source/pair metric and radius laws are supplied by the declared Paper 3
profile, while this paper owns their authentication and consumption. A
syndrome check, complete evidence array or matching root does not repair a
missing source model, decoder equality or far-comparison premise. The
positive-radius claims concern the raw received carrier; accepted exact
anchors have zero decoded exactness distance under the same interpretation.

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
released delivery hints or envelope bytes extend the §2.2 observation view.
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

##### 6.1.1. Native coordinate transport for the coupled family

The native full-ciphertext map and its exact rational implementation are
source results of the HCP paper. They transport original samples with the
same message/opening coordinates. This protocol section specifies their
scoped material, original contexts, delivery and lookup consumers.

The [scoped transport token](../../lean/Protocol/Ephemeral/TransportToken.lean)
encodes the derived rational matrix with its physical dimensions, recipient
handle, both epochs and every field of the original source/target context
keys. It uses the existing ciphertext coordinate order and canonical
normalized fractions. The same material-indexed delivery receipt supports
both the earlier isometric rotation and this native token. Its native
adapter derives scope from the actual contexts and binds the envelope
relation to the exact canonical token bytes. Migration consumes the held
token; retained-base recovery also uses the private source presentation
\(B\). Neither operation regenerates \(B,C\) from context labels.

Canonical token/scope/hash and full-ciphertext checks precede exact rational
execution. Original generated samples migrate to the target's original
ciphertext bytes and recover the same \(z\). The
[hash-addressed adapter](../../lean/Protocol/Storage/Retrieval/Native.lean)
retains the original bound HCP observations: with the canonical issued token,
named, available target bytes give the original coefficients or an accepted
ciphertext byte-hash collision. Accepted substitution of the issued token is
covered separately by the token's original-operator-or-collision theorem. The
full-ciphertext digest remains separate from the exact artifact digest in
the context key. The scope is reusable for the selected contexts/profile;
it supplies neither single-use authorization nor confinement of copied
matrix data. Authentication and confidential envelope delivery remain
explicit application contracts.

The canonical [ciphertext manifest](../../lean/Protocol/Storage/CiphertextManifest.lean)
places the original exact artifact and separately named full-ciphertext bytes
in two distinct slots of the existing checkpoint engine. Raw sealing permits
arbitrary bytes. The separate [native certificate](../../lean/Protocol/Storage/NativeManifest.lean)
`BindsOriginal` relates the same seal to the original context and decoded Hodge
observation. For the original
target context \(\mathcal C_T\), its public directory is
\[
\mathcal D_M=[(\mathrm{exact},d_{\mathrm{ex}}),
 (\mathrm{cipher},H(\operatorname{encode}(b_T)))].
\]
The supplied manifest-root function takes only
\((V_{\mathrm{base}}(\mathcal C_T),\mathcal D_M)\). The enclosing root and
private observation fields are outside that preimage. The slot roles are
distinct even when their digest values coincide.

**Proposition (Native ciphertext/history association).** Let \(M\) be an
actual raw seal with that native certificate and canonical sample-byte
equality for \(b_T=\operatorname{Enc}_C(z,a,u)\). An existing transition anchor for this
same context and seal associates its exact artifact and full-ciphertext
directory with the candidate's authenticated history entry. The original
target harmonic message is \((0,z,Cz)\). Given the canonical issued transport
token and available target bytes, lookup in \(M\)'s derived public view
recovers \(z\), or accepted ciphertext substitution gives a byte-hash
collision. Directory membership is a consequence of the seal, not an
independent naming premise.

The [proof](../../lean/Protocol/Storage/Retrieval/NativeAnchored.lean) first
uses the native certificate's decoding equation and canonical sample bytes to
identify the original observed cochain. Applying its harmonic projector identifies the
message without assuming equality of private opening representatives. The
seal determines the directory; the existing transition anchor and native
recovery theorem then give the history association and collision alternative.
History authentication, byte availability and protected delivery keep their
original contracts. The typed manifest-root function has no new concrete
byte-codec or hash-security instantiation.

The [native transfer adapter](../../lean/Protocol/Transfer/Native.lean) uses
the actual checked owned-transfer configuration and that same raw seal.
`Config.nativeBinding` constructs its native certificate from the original
context/sample equations. `CheckedTransfer.native_history_recovery` retains
the checked packet's manifest root, original artifact, computed history
inclusion and accepted update while recovering the original coefficients or
exhibiting accepted ciphertext substitution with the same hash. Native
certification and canonical sample-byte equality remain explicit; exact-payload
verification alone supplies neither. Storage-classifier alignment and the
meaning of \(z\) as an amount, identity or authorized action remain separate.

Omitting \(B,C\) as token fields supplies no key-hiding theorem. Public release
of transport material remains a security question: the proved specialization
\[
\operatorname{information}\bigl(L_{B\to0}\operatorname{Enc}_B(z,a,u)\bigr)=z
\]
shows that publicly usable transport to the known zero presentation exposes
the message coefficients. A public evaluation-key protocol must specify its
admitted endpoints, auxiliary information and security experiment.

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

The finite [executable fixture](../../lean/Protocol/Transfer/Owned/Demo.lean)
transfers seven units between distinct byte owners. It reads a canonical
packet on the existing exact zero payload and runs the reference verifier
with fixture signatures, proof bytes and hashes. A changed manifest and
replay against the computed successor both reject, including a replay with
a fresh draft. The raw ciphertext slot tests object naming. Genuine native
recovery uses the binding and delivery premises of §6.1.

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

1. Seal the original exact payload/artifact and selected full-ciphertext
   bytes/digest in the canonical
   [ciphertext manifest](../../lean/Protocol/Storage/CiphertextManifest.lean).
   Its root preimage is the existing base public view and ordered two-entry
   slot/digest directory. Neither leaf contains the current candidate, proof
   packet or enclosing manifest root. Raw sealing does not validate the
   ciphertext; the native certificate is separate. This input manifest is
   distinct from the six-stage projection manifest and its gate certificates.
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
these data. The operational checker rejects an actual parsed packet with a
different manifest root, without assuming digest injectivity. The signature
soundness contract authorizes the exact intent.
The payload verifier is indexed by the **actual trusted payload
interpretation**; its soundness law requires the original context's
interpretation equality and public-input equality before deriving exact
payload acceptance. It does not quantify over arbitrary decoders sharing
public labels. Codecs, primitive implementations and their indexed soundness
remain supplied contracts. The classical Boolean specification has a proved
[executable byte-owner refinement](../../lean/Protocol/Transfer/Owned/Executable.lean).
Its decidable checks and finite-support update compute acceptance and the
same successor for the canonical codec, given executable configured hashes
and verifiers.

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
or consensus. The raw two-slot seal supplies neither native decoding validity
nor a proximity radius or projection-gate theorem.

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
the proposal and manifest retain their existing roots and two-slot directory,
including the selected full-ciphertext digest.
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
not an EUF-CMA, IND or anonymity theorem. Section 6.6 gives a separate bounded
adaptive signing reduction and a finite native sampler. A security-parameter
family, justified key/noise distribution,
corruption policy and quantitative primitive estimates remain to be
specified. Authenticated state origin,
hash binding of an external encoded history, runtime agreement, durable
application and finality are outside these events. The bad event is invalidity
of the typed candidate under the configured policy, not failure of every
external authentication contract.

#### 6.3.1. Confidentiality of the released transfer

The [checked-release challenge](../../lean/Protocol/Transfer/Confidentiality.lean)
shows that different input IDs distinguish two checked transfers directly.
A privacy experiment must hold such public fields fixed or account for
their leakage. Downloaded ciphertext bytes, access metadata and optional
cochain disclosures also belong in the view when available to the observer.

For fixed setup and transfer,
[PublicAssembly](../../lean/Protocol/Transfer/PublicAssembly.lean) reconstructs
the checked release from its public base payload, selected ciphertext
digest, owner-signature bytes and proof bytes using the original manifest,
hash and packet functions. Any event bound on the joint distribution of
these inputs carries to the assembled view by deterministic postprocessing.
The account must cover their joint law, including the correlation of proof
and signature bytes with the same private observation.

The [nonce-bearing adapter](../../lean/Protocol/Transfer/PathSignature/NativeCommittedRelease.lean)
reconstructs the actual checked release and signing input from the parsed V2
instance, aligned public fields and original evidence bytes. Its shared-cache
[recovery theorem](../../lean/Protocol/Transfer/PathSignature/NativeCommittedRelease/Simulation.lean)
charges the simulator's `S` queries together with the decoder's `Q` queries
and the two honest digests. A joint total-variation bound `ε` on the sampled
message, release and live cache adds `ε` to the simulated recovery bound.

The [honest evidence producer](../../lean/Protocol/Transfer/PathSignature/NativeCommittedRelease/HonestEvidence.lean)
uses the selected CRS prover on the full V2 signing input and original
nonce-bearing witness, with proof randomness sampled inside the experiment.
It also runs the supplied payload prover on the original intent and
ciphertext. The [native payload producer](../../lean/Protocol/Transfer/PathSignature/NativeCommittedRelease/Payload.lean)
uses the canonical certificate subject and reads the ciphertext digest through
the shared byte oracle. A cache hit returns the same digest and preserves the
cache. For an original bound observation whose private encoding satisfies the
selected payload relation, primitive correctness gives payload verification
for every proof tape. With the matching V2 instance, approved owner prover,
honest setups and structural prechecks, the two generated proofs pass the
original operational checker on the exact assembled packet.

The [common-prefix comparison](../../lean/Protocol/Transfer/PathSignature/NativeCommittedRelease/Honest.lean)
retains the same message, sign key, private nonce and live cache for both
branches. An almost-everywhere conditional total-variation bound `ε` on the
released view and resulting cache implies the joint-prefix premise and the
honest recovery bound. Failed releases remain in both laws. The selected
backend still needs to establish that conditional simulation estimate.
The acceptance theorem uses explicit primitive correctness and relation
refinement premises.

The projection profile binds its proof to the original artifact through
[ProjectionAnchor](../../lean/Protocol/Storage/ProjectionAnchor.lean). Its
public release keeps the handle separate from the full frame used by a
witness. The full projective point and the observed cochain together
determine the harmonic message by [Paper 3's reconstruction](../paper3/README.md).
The storage experiment must explicitly enumerate which of these fields
it releases.

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
archived workspace `archive/runtime/Cargo.toml`.

Runtime paths below refer to historical prototypes under `archive/runtime/`;
they are excluded from the Lean/manuscript review bundle. The implementation comparison
identifies distinct signed and proved objects:

| Archived implementation | Actual object and missing comparison |
|---|---|
| Worker signatures in `archive/runtime/rust/node/src/consensus/pov.rs` | Ed25519 authenticates a 69-byte spectral message: domain, fingerprint hash, gap-valid bit and three Betti numbers. It does not sign the owner transfer intent or complete final proposal. A selected key registry, message encoder and exact verifier-agreement equation are required before this algorithm can instantiate owner authorization. |
| Bootstrap keys in `archive/runtime/rust/node/src/main.rs` | The single-node path derives four signing seeds from the public producer fingerprint. That path does not justify an uncompromised-key assumption. An Ed25519 implementation alone supplies no authorization/error bound for this setup. |
| Raw graph commitment in `archive/runtime/rust/node/src/crypto/commitment.rs` | Ordered ordinary-incidence differences, without general private cellular restrictions. A global constant translation changes the vertex-zero message while preserving every edge value. Payload authentication is distinct from binding that message. |
| Geodesic verifier in `archive/runtime/rust/node/src/crypto/geodesic_zkp.rs` and transaction call path in `archive/runtime/rust/node/src/consensus/pov.rs` | Sampled floating-point matrix, spectral and transcript checks. They do not receive the original cochain, trusted interpretation or owner intent required for `Context.Accepted`. No bound `2^{-n_opened}` or SNARK/zero-knowledge property is established. The audited parser/call path also does not establish the canonical, fail-closed packet contract: trailing bytes can remain unconsumed and malformed optional proofs can be skipped. |

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
existing codec interface. Section 6.6 gives a canonical byte-owner reference
profile and quorum-authenticated selection of program/key/CRS bytes.
Authenticated owner-key registration, cross-language runtime agreement,
backend semantic refinement for the same original cochain interpretation and
primitive/query/setup error bounds remain explicit. The legacy TCB carrier
supplies none of those runtime or secrecy guarantees.

#### 6.5. Full-intent signing and authorized issuance from existing objects

Owner signing reuses the actual resource catalogue, full `Intent` and
metadata, packet codec, selected `keyFor` function, byte-query history and
released-view carrier. It introduces no second account registry or credential
issuer. Committee votes authenticate validator targets; recipient scopes are
public names; presentation transport moves recovery material; Helfer's
`Signature` is logical vocabulary. These retain their distinct roles. The
intended owner-authentication target is knowledge of a designated private
witness bound to the exact message and authenticated credential. Here issuance
means recording an authorized signing request and output, not issuing a
credential.

[Signing](../../lean/Protocol/Transfer/Signing.lean) defines

\[
\operatorname{SignBytes}(\mu,\iota)
=\texttt{HOMOTOPICAL_ENCRYPT\_OWNER\_INTENT\_V1}\mathbin\Vert
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
Section 6.6 supplies a bounded adaptive CRS reference construction and
quorum-authenticated selection of its actual program, verifier key and CRS.
Complete disclosure history, secure primitive implementations and their error
bounds, key custody, corruption and runtime refinement remain obligations.

#### 6.6. Generic path realization and the finite native statement

The generic [path adapter](../../lean/Protocol/Ephemeral/Rotation.lean) retains
its original supplied path realization: each path gives an isometric
`PresentedRotation`, whose degree-one transport commutes with harmonic
projection. The [generic path-signature relation](../../lean/Protocol/Transfer/PathSignature.lean)
uses a supplied decoder for the private representative, opening and original
`EphemeralFiberSpec`. Its opening predicate and the decoded path's
`WellFormed` proposition remain explicit. This adapter constructs transport
and coefficient recovery for those realized paths. The arbitrary coupled
family below uses a different concrete finite relation; its generally
nonisometric native transport does not instantiate this isometric adapter.

##### 6.6.1. The bounded raw-root credential

The following raw operator-hash profile fixes the reference binding and
checking objects. The privacy candidate below needs a different operator
commitment profile; it is not substituted into this relation implicitly.

Fix dimensions \(m,n\), a coordinate bound \(K\), a salt length \(\ell\)
and a byte hash \(H\). The [native witness](../../lean/Protocol/Transfer/PathSignature/NativeRelation.lean)
is
\[
 w=(B,C,z,a,u,s),\qquad B,C\in\mathbb Z^{m\times n},\quad
 z\in\mathbb Z^n,\quad a\in\mathbb Z,\quad u\in\mathbb Z^m.
\]
Every matrix entry and integer coordinate has absolute value at most \(K\),
and \(s\) has exactly \(\ell\) bytes. Its private codec canonically encodes
the original matrices, opening coordinates and salt; the relation separately
checks the bounds. The public instance consists of three `Hash32` values:
\[
 x_w=\bigl(H(\operatorname{credbytes}(s,B)),\,
 H(\operatorname{enc}(C)),\,
 H(\operatorname{samplebytes}(C,z,a,u))\bigr).
\]
The credential preimage uses a dedicated domain and canonical salt/matrix
framing. The other preimages are the actual target matrix bytes and full
target ciphertext bytes. Salt alone establishes no hiding theorem.

The finite integer-box sampler and its bounded-support/cardinality laws are
established with the source construction. The CRS reference may use that
sampler or another declared PMF; its theorem retains the actual sampled
maps and does not infer public-key uniformity from private seed uniformity.

The [finite program](../../lean/Protocol/Transfer/PathSignature/NativeProgram.lean)
\(p=(m,n,K,\ell)\) and its public instance have canonical codecs. Its Boolean
relation \(R_{p,H}(x,\eta)\) accepts exactly when \(\eta\) canonically decodes
to a bounded witness \(w\) with \(x_w=x\). The decoded sample is the actual
\(\operatorname{Enc}_C(z,a,u)\), whose original harmonic projector returns
\((0,z,Cz)\). The existing operative-HCP comparison identifies this same
message as the target.

The protocol checks this credential and relates its ciphertext name to the
original artifact through the binding certificate.

##### 6.6.2. Operator visibility and the versioned protocol profile

The selected lifecycle uses fresh geometry per public encrypted object
and retains persistent recovery material privately. The release profile
permits ciphertext content IDs and keeps operator openings and usable
transport material in protected delivery.

The nonce-bearing V2 relation retains the source paper's canonical private
witness and three public names. Its operator root is
\(\operatorname{Com}(B;r)\), with a private 32-byte opening distinct from the
credential salt. The concrete snapshot condition is
\[
\operatorname{Com}(B;r)=\mathcal C.\mathsf{snapshotRoot}.
\]
The existing context key then supplies that same root alongside the owner
credential and selected full-ciphertext digest. Canonical sample/hash
agreement derives the actual V2 public key. Approved execution requires its
exact V2 program bytes, parses the actual verifier key and CRS, and verifies
the original full-intent signing bytes at the existing owner checker.

A protocol privacy experiment for V2 must include its signing answers,
evidence proofs and retained storage records. Freshness and retirement
remain lifecycle obligations, including when migration uses the companion
paper's coexact correction to generate the prescribed target bytes.

##### 6.6.3. Bounded adaptive CRS reference construction

The [CRS primitive interface](../../lean/Protocol/Transfer/PathSignature/CRS.lean)
supplies actual setup, prover, verifier, simulated-setup, simulator and
extractor functions. Their composition follows the signature-of-knowledge
game organization of [Chase–Lysyanskaya, §2.2](https://cs.brown.edu/people/alysyans/papers/cl06.pdf).
The concrete [outer codec](../../lean/Protocol/Transfer/PathSignature/Codec.lean)
passes the injectively framed credential instance and **complete** existing
`Signing.message` to that primitive. The geometric native relation ignores
the message: its witness is valid for every message under its credential.
Message binding must therefore be supplied by the selected primitive on this
complete input. [Tagged signatures of knowledge, §5.2](https://imec-publications.be/server/api/core/bitstreams/16add66f-1230-43ee-80f1-9c0e93c7f206/content)
provide a comparison; an arbitrary verifier can ignore an input it receives.

The bounded interpreter allows at most \(q\) signing queries. Each next
query or final output depends on the actual prior query/answer list. Its real
oracle proves with the sampled private witness and real setup; its simulated
oracle uses simulated setup and its trapdoor. A shared PMF supplies the
credential, witness, auxiliary input, setup seed, proof randomness and
adversary randomness. Both executions retain the same adversary and sampled
maps. The original box sampler is one permitted PMF for this reference
relation; the reduction requires
no independence. Freshness uses the generated signing log
on the complete credential/message input.

The [preferred native experiment](../../lean/Protocol/Transfer/PathSignature/NativeSecurity.lean)
actually places the canonical **full target ciphertext bytes** in the first
component of adversary auxiliary input. It preserves the remaining auxiliary
data, PMF, adversary and random-tape maps. Its released view therefore contains
the salted source credential, target snapshot commitment, ciphertext digest
and full cochain, with the selected setup and any other declared auxiliary
information.

After a fresh simulated forgery, extraction must produce bytes accepted by
the same relation and private decoder. The recovery algorithm returns the
extracted witness's coefficients; the original private \(z\) is used only
to define success. Equal target snapshot and ciphertext hashes imply recovery
of the original coefficients, or a collision on the original snapshot bytes,
or a collision on the original full-ciphertext bytes.

**Conditional native forgery reduction.** Let \(D\) be the actual Boolean
test for a verified fresh forgery. The event-specific `WinningHybrid` premise
is
\[
 \Pr[D(T_{\rm real})=1]
 \le \Pr[D(T_{\rm sim})=1]+\delta_{\rm hyb}.
\]
Under this premise,
\[
\begin{aligned}
\Pr[\mathrm{Forge}_{\rm real}]
&\le \delta_{\rm hyb}+\Pr[\mathrm{ExtractFail}]
 +\Pr[\mathrm{RecoverOriginal}]\\
&\quad+\Pr[\mathrm{SnapshotCollision}]
 +\Pr[\mathrm{CiphertextCollision}].
\end{aligned}
\]
All events use the stated sampled execution, and the theorem applies to the
constructed full-ciphertext view. The proof first transfers a real win to a
simulated win plus the hybrid error. A simulated win either fails validated
extraction or yields a native witness. Canonical decoding and its two target
hash equations give one of the remaining three events. The union bound
requires no independence assumption.

The premise concerns this Boolean forgery test. Statistical closeness for
every set of transcripts is only a stronger sufficient corollary. A
computational instantiation still needs the test's efficiency and the selected
primitive's hybrid bound; no statistical zero-knowledge assumption is required.

This is an exact conditional reduction. It supplies no numerical or
asymptotic bound, polynomial-time theorem or negligibility claim. The view
extends the original HCP observation with commitments and auxiliary data, so
the earlier public-data obstruction and known-lattice CVP comparison give no
computational estimate for `RecoverOriginal`. The selected CRS primitive,
its security rates and secure setup generation remain external; no Groth16
or pairing engine, zero-knowledge theorem or UC theorem is constructed here.
The direct trapdoor-extraction route avoids an unsupported HCP public-key
encryption slot while keeping the actual native Hodge witness central.
The tagged Boolean construction in
[BGPR2022, §§5–6](https://imec-publications.be/server/api/core/bitstreams/16add66f-1230-43ee-80f1-9c0e93c7f206/content)
fits straight-line extraction, but still requires genuine encoded bilinear
groups, the selected matrix/kernel Diffie–Hellman assumptions and collision
analysis for the complete subject tag. A Fiat–Shamir extractor that forks an
oracle adversary has a different interface. No secure backend is instantiated.

##### 6.6.4. Approved execution and proof relation

The [registration descriptor](../../lean/Protocol/Transfer/Certificates/Profile.lean)
retains full proof metadata, public profile bytes, parameter-set hash,
optional gate scope and rational calibration, program bytes, verifier-key
bytes and public CRS bytes. Its dedicated registration hash is the evidence
root of the exact proposal approved by an existing authenticated acceptance
quorum. The [authentication adapter](../../lean/Protocol/Transfer/Certificates/ProfileAuthentication.lean)
uses the actual selected signature verifier on canonical full vote-target
bytes. Approval binds the exact descriptor and committee epoch, without
constructing a new registry or proving consensus finality.

Applicability compares the original metadata, profile, parameters, scope,
calibration and current epoch. The approved program, verifier key and CRS
must parse to the actual selected objects. The
[registered owner checker](../../lean/Protocol/Transfer/PathSignature/Registered.lean)
uses those objects with the existing key map and full-intent signing bytes;
inapplicable or unparsed configurations reject. Honest signatures verify
under the primitive's completeness contract and equality of its real setup
output with the approved reference. Approval authenticates the bytes, not
their semantic refinement or secure setup generation.

The [preferred native adapter](../../lean/Protocol/Transfer/PathSignature/NativeRegistered.lean)
additionally checks that the approved code is the exact canonical expected
program, which is also the native public profile. Its key is the canonical
triple of the existing owner's credential, the original context's snapshot
root and its actual full-ciphertext digest. Neither target name can be
supplied independently. Checked packets therefore execute that expected
program on the original context and full signing message. Different approved
program bytes reject even if their profile label matches. This binds code
and public names without proving credential ownership or proof soundness.

The [original-context adapter](../../lean/Protocol/Transfer/PathSignature/NativeContext.lean)
derives equality with the challenge's `instanceFor` from four actual-object
conditions: the selected owner's credential is the salted source credential, the target
matrix binds the original snapshot, the selected ciphertext is the canonical
target sample, and its selected hash agrees with the native hash. The sample
equality also identifies the actual full ciphertext supplied to the adversary.
Parsed approved verifier-key and CRS components must equal the actual setup
output at the sampled seed; checked verification then uses that same reference.

The [application completion adapter](../../lean/Protocol/Transfer/PathSignature/NativeApplication.lean)
reads the experiment's actual returned target. It parses its canonical full
signing message through the selected packet codec, checks that the decoded
signer's context key equals the challenged key, and reconstructs the original
packet with exactly the target proof as its owner signature. The separate
payload proof is supplied explicitly. Every original resource, metadata,
intent, signature and payload check still executes. Malformed messages or a
different signer key yield no attempt; owner-to-key injectivity is not assumed.

The application experiment selects the actual program's primitive by
construction while retaining the original PMF, adaptive adversary, random
tapes and full-ciphertext view. `FreshChecked` requires successful checking of
this completion of the actual returned target and freshness against its
generated query log. Per-sample equality of the approved parsed key/CRS with
actual setup gives the same-PMF event inclusion
\[
 \Pr[\mathrm{FreshChecked}]\le\Pr[\mathrm{Forge}_{\rm real}].
\]
Canonical parsing and the original checks fix the actual target message and
signature; the completion guard fixes the challenged key. The existing
five-term native bound therefore also bounds this application event.

The preferred `nativeSource_application_bound` consumes these source and
setup equations for configurations of the challenge's actual target sheaf.
It jointly derives, at every sampled outcome, the selected owner's context
key equality, equality of the released full ciphertext with the original
configuration's ciphertext, and the same application's five-term bound.
The completion guard still handles the adversary's actual chosen signer.
`errorBudget` names the existing five-event sum; it supplies no small
numerical estimate.

This result covers the single-credential completion adapter, without
translating arbitrary packet-producing adversaries or classifying all accepted
transfers as forgeries. General accepted-invalid integrity retains its policy,
compromise and payload-failure branches. Additional public application data
belongs in the declared auxiliary remainder; no complete storage-view privacy
claim follows. The byte-signature quorum authentication factory remains an
explicit selection, with no conversion of arbitrary legacy authentication.

A [canonical byte-owner packet codec](../../lean/Protocol/Evidence/TransferCodec.lean)
serializes the existing packet, full intent and metadata. It retains declared
payload counts separately from actual list lengths; malformed semantic data
can parse and still fail the actual checks. This versioned Lean reference
wire profile makes no compatibility claim for the archived Rust serializer.

The target arithmetic for the native proof relation comes from
[Paper 1's finite-field refinement](../paper1/README.md). Over a prime field
meeting its modulus bounds, a satisfying arithmetic assignment has a unique
bounded integer lift that obeys the original ciphertext equations. To
implement the full V2 relation, the proof circuit must also enforce the
source credential, salt and nonce encoding, canonical parsing and hash
checks, and bind the arithmetic outputs to the canonical ciphertext named by
the instance. General real projection certificates retain separate circuit
obligations.

#### 6.7. Retrieval and selector privacy

For direct storage, a complete encrypted byte record \(\beta\) is stored
under \(d=\operatorname{SHA256}(\beta)\). The
[Lean reference index](../../lean/Protocol/Storage/EncryptedCell.lean) makes
one lookup at \(d\) and hashes the entire returned record before use. A
successful insertion addresses the original bytes and an immediate verified
read returns them. At a trusted address for an original record, any different
accepted bytes give an actual SHA-256 collision.

The [directory verifier](../../lean/Protocol/Storage/CellDirectory.lean)
checks the complete context key and ordered cell IDs and digests against
the caller's trusted directory root. It rejects duplicate cell IDs.
Checked fragments of one directory agree on shared cells and give a unique
merged lookup. For independently verified directories at the same context
and root, differing names for a shared cell exhibit a SHA-256 collision on
canonical directory bytes. A checked cell lookup resolves \(d\) for the
whole-record reader. This reference verifies the complete directory once.

The [checkpoint pin](../../lean/Protocol/Storage/CellDirectory/Checkpoint.lean)
pairs the full context key with the directory root. It projects from an
accepted transition anchor when the seal root is the SHA-256 digest of the
canonical cell directory. The [local store](../../lean/Protocol/Storage/CellDirectory/Persistence.lean)
keeps digest-named ciphertexts and directories immutable and checks every
referenced object before atomically publishing the checkpoint. After a
process restart, the reader supplies its expected pin independently, checks
the checkpoint and directory, and verifies the requested ciphertext bytes
before recovery. Power-loss durability requires filesystem synchronization.

The [public stack release](../../lean/Protocol/Storage/PublicStack/Release.lean)
binds the public snapshot descriptor, original cochain, and accepted proposal
and verdict to the cell directory under one canonical manifest root. The
root is issued from the accepted release in its own domain. A reader passes
that root independently to the [restore procedure](../../lean/Protocol/Storage/PublicStack/Restore.lean).
The procedure verifies the directory, reuses verified objects in the replica,
fetches each missing or corrupt address once, and publishes the stack only
when all selected objects verify. A fresh process can reopen the replica
using the same trusted root.

The [proof-packet profile](../../lean/Protocol/Storage/PublicStack/ProofRelease.lean)
adds the actual checked packet bytes and its ciphertext cell ID to the vote
target. A [historical replay](../../lean/Protocol/Storage/PublicStack/Replay.lean)
uses the original before-state and verifier configuration, reconstructs the
signed manifest using the restored ciphertext, and checks that the packet
produces the named proposal and verdict. The result is the historical
successor state. The reader supplies the trust anchor and verifier setup
independently.

An [ordered history index](../../lean/Protocol/Storage/PublicStack/HistoryIndex.lean)
commits to all archived stack roots in replay order. The reader verifies it
at an independently supplied root and begins from one trusted ledger state
and verifier profile. Each checked successor supplies the next before-state,
so the next packet must bind the preceding tip and evidence root. The
[replay procedure](../../lean/Protocol/Storage/PublicStack/History.lean)
returns the final computed state when every archived link checks.

For [incremental history replication](../../lean/Protocol/Storage/PublicStack/HistorySync.lean),
the reader obtains the index and its archived stacks through a digest lookup.
A replica reuses verified local bytes across the full index, fetches missing
or corrupt objects, and rechecks each transfer from its computed predecessor.
The writer atomically activates the history after all steps succeed. A rejected
attempt preserves the previously active history and can leave verified objects
available for retry.

An issuer can produce a [ledger checkpoint](../../lean/Protocol/Storage/PublicStack/CheckpointIO.lean)
after checking the active history. Its separate canonical SHA-256 commitment
binds the history root, context, and entire computed successor, including the
marking and spent set. A fresh reader obtains the authenticated checkpoint
digest independently and opens the state from the named bytes. The
configured proposal-state hash retains its original scope.

A [checkpoint continuation](../../lean/Protocol/Storage/PublicStack/Continuation.lean)
verifies the prior and proposed history indices and checks that the prior
ordered list is an exact prefix. The authenticated checkpoint supplies the
state at that boundary. The reader fetches the suffix archives and checks
their transfers under the supplied verifier profile, then stores a new
checkpoint for the extended history. The prior index supplies the prefix
comparison even when its archives are absent.

The indexed request exposes \(d\) to the responding server. The fixed-bucket
profile below selects locally after a complete bucket download. A PIR
backend would supply private selection while retaining the separate result
verification step.

The [retrieval layer](../../lean/Protocol/Storage/Retrieval.lean) fetches
the selected canonical ciphertext from the original manifest and passes it
to recipient recovery. An optional
[encrypted query](../../lean/Protocol/Storage/Retrieval/HodgeQuery.lean) uses
the source encryption's linear aggregation law. Its request releases a
joint list of encrypted columns, so selector privacy concerns that complete
request. The [joint-view obstruction](../../lean/Protocol/Storage/Retrieval/LinearQueryObstruction.lean)
identifies a profile in which the selected column is the unique one outside
the span of the others.

Hash lookup and recovery are separate implemented stages.
[ContentAddress](../../lean/Protocol/Storage/Retrieval/ContentAddress.lean)
selects a slot or digest locally from an entire downloaded bucket, checks the
actual returned bytes against a trusted fixed directory, and parses only
accepted bytes. Substitution for a named original gives either the original
bytes or an explicit colliding byte candidate; no global hash injectivity is
assumed. [Recovery](../../lean/Protocol/Storage/Retrieval/Recovery.lean) then
uses the existing recipient/epoch/context-scoped `RecoveryDelivery`. Its native
corollary retains both original `BoundHCPObservation` endpoints and their
`BoundSampleRotation`, yielding source-coefficient recovery or a collision
under the named-byte availability and full-target decoding contracts.
The full ciphertext's digest has a separate role from the existing
exact-component leaf `cochainDigest`; the latter alone supplies no full
ciphertext binding.

The [concrete coupled recovery theorem](../../lean/Protocol/Storage/Retrieval/Coupled.lean)
now instantiates this existing path with `CoupledCiphertext.decodeReal` and
the original target sample bytes. Source and target contexts are derived from
the actual bound observations. Canonical decoding discharges the former
independent decoder premise; the actual isometric rotation, scoped private
delivery receipt, manifest naming and byte availability remain explicit.
The result is original source-coefficient recovery or an actual accepted hash
collision. It introduces no new encryption or query carrier.

Hashing has a second, prospective role in ephemeral generation: derive an
index or seed from an agreed secret and the authenticated epoch/context, then
generate the private representative and transport material reproducibly.
Shared-secret agreement, the finite generator and their security are not
constructed. This proposed derivation is distinct from the current public
ciphertext content address; hashing a public identifier does not produce
private recovery material. The delivery envelope also needs its concrete
codec and protection scheme.

[UniformRead](../../lean/Protocol/Storage/Retrieval/UniformRead.lean) is the
complete selector-privacy reference profile: request the same whole public
bucket and keep selection, hash checks and recovery local. The full
request/response view and its PMF distribution are identical for any two
targets in that fixed public bucket under the same random-tape PMF, even for
an arbitrary server. It transfers the entire bucket; ciphertext byte volume is
the sum of all record lengths, with label/transport overhead separate. This lower-efficiency reference
does not decide the native query's privacy question. Efficient native retrieval
still needs a specified joint sampler/view and selector-privacy proof. A
plaintext hash-to-slot request, record-specific authorization, targeted retries
or later public target-bearing actions extend the view and need their own
analysis. Oblivious recipient discovery is a further property; the UnifOMR
reference remains background, without protocol adoption.

The client can use its private Hodge geometry to generate the native query;
this is distinct from public sender encryption to an arbitrary recipient.
That public-key interface remains open. The direct CRS extraction route in
§6.6 does not require it. No conventional/native signature combiner is
selected by this retrieval construction.

### 7. Construction ownership and remaining protocol work

The bounded protocol results are the checked transfer in §6.2 and one-shot
integrity comparison in §6.3. The completed HCP construction supplies their
operators, lattice, encryption and finite recovery. This inventory separates
those source results from protocol-owned joins; conditional theorems retain
their stated profiles.

| Family | Canonical modules | Status and boundary |
|---|---|---|
| Source presentation and derived operators | [Cellular](../../lean/Sheaf/Cellular.lean), [Hodge](../../lean/Sheaf/Hodge.lean), [Integral](../../lean/Sheaf/Integral.lean), [CoupledGeometry](../../lean/HCP/CoupledGeometry.lean) | **Paper 1 source result; consumed here.** Source objects determine the fixed-profile operators, lattice and cochain space. The true Hodge operator reconstructs the coupling matrix; the all-real assembly/recovery triangles and projection square are proved on those same objects. Generic independently varying geometry and its finite codec remain separate. |
| Intrinsic lattice, finite decoding and direct bytes | [CoupledLattice](../../lean/HCP/CoupledLattice.lean), [CoupledDecoding](../../lean/HCP/CoupledDecoding.lean), [CoupledRecovery](../../lean/Protocol/Storage/CoupledRecovery.lean) | **Paper 1 source result; consumed here.** The same original subgroup has real/integer charts, an integer basis, rank and discreteness; all-rational decoder refinement and exact integer ciphertext-language characterization feed direct key/ciphertext-byte recovery. |
| Payload and operations | [Payload](../../lean/Axioms/CochainCommitment/Payload.lean) | Constructed shape, modulus/count/tag, compatible addition and zero; finite serialization remains separate. |
| Snapshot, interpretation and openings | [Commitment](../../lean/Sheaf/Commitment.lean) | Constructed snapshot/payload interpretation, exact acceptance and opening equivalence modulo `ker delta0`; this is Paper 2 construction. |
| Concrete/legacy semantics | [CochainSemantics](../../lean/Sheaf/CochainSemantics.lean), [SheafCoherence](../../lean/Axioms/SheafCoherence.lean) | Conditional carrier/decoder/coboundary alignment and acceptance equivalence; ambient coherence contracts remain supplied. |
| Commitment, blinding, local opening and MAC | [Security](../../lean/Axioms/CochainCommitment/Security.lean), [Blinded](../../lean/Axioms/CochainCommitment/Blinded.lean) | Typed geometry and named binding/hiding/opening/MAC contracts; secure algorithms and experiments are not constructed. |
| Ordinary graph profile | [GraphCommitment](../../lean/Sheaf/GraphCommitment.lean) | Constructed modular payload and alternative openings; its translation ambiguity limits raw message binding. |
| Original HCP/artifact binding | [HCPObservation](../../lean/TCB/HCPObservation.lean), [HCPRealization](../../lean/TCB/HCPRealization.lean), [HCPAxisFamily](../../lean/TCB/HCPAxisFamily.lean) | Conditional joins of Paper 1's actual sample/operator/classifier to the original artifact and decoder; authentication and full-view equality remain explicit. |
| Rotation and delivery | [Sheaf.Rotation](../../lean/Sheaf/Rotation.lean), [AxisRotation](../../lean/HCP/AxisRotation.lean), [Ephemeral](../../lean/Protocol/Ephemeral.lean) | Actual integral/sample transport, coefficient-preserving recovery and original-payload migration; secure delivery and lifecycle enforcement are supplied. |
| Ephemeral paths and fibers | [Fibration](../../lean/Axioms/Fibration.lean), [PresentedRotation](../../lean/Protocol/Ephemeral/Rotation.lean) | Supplied admissible paths and realized transport; class equality does not construct the private path or its generation algorithm. |
| Public visibility | [Storage.PublicView](../../lean/Protocol/Storage/PublicView.lean), [Transfer.PublicView](../../lean/Protocol/Transfer/PublicView.lean) | Actual base/header, directory, explicit HCP disclosure and transfer release; no hiding follows from omitted witness fields. |
| Cellular source and codec | [SystematicCode](../../lean/Sheaf/SystematicCode.lean), [CoordinateCodec](../../lean/Protocol/Storage/CoordinateCodec.lean), [CanonicalSystematic](../../lean/Protocol/Storage/CanonicalSystematic.lean) | Actual source and complete original-payload layout from §3.3; Paper 3 owns the validity/code and quantitative metric comparisons. |
| Projective/payload realization | [PublicBinding](../../lean/Proximity/Concrete/PluckerCochain/PublicBinding.lean) | Hashed handles and conditional payload/frame/observation bindings; Paper 3 owns full-point reconstruction. |
| Storage context and checkpoint lifecycle | [Context](../../lean/Protocol/Storage/Context.lean), [Checkpoint](../../lean/Protocol/Storage/Checkpoint.lean), [Projection](../../lean/Protocol/Storage/Projection.lean) | Original context, six ordered stages, exact manifests, matching receipt and terminal consumption; no backend durability, erasure or global freshness. |
| Projection gates and evidence | [Gates](../../lean/Gates.lean), [stage certificates](../../lean/Proximity/Concrete/Gates/Stage.lean), [GateEvidence](../../lean/Proximity/Concrete/GateEvidence.lean), [certificate adapter](../../lean/Protocol/Transfer/Certificates/Projection.lean) | Actual records, chosen chart/metric and original chain input are retained. Five/six/seven-slot checks require the same earlier bundle; the actual guarded transfer check derives `DatabaseBound` from all seven leaf/root equations. Cryptographic verification and runtime guard refinement remain open. |
| Sampled scalar transfer check | [SampledMCA](../../lean/Protocol/Transfer/Certificates/SampledMCA.lean), [canonical metric adapter](../../lean/Protocol/Storage/CanonicalCalibration.lean) | **Paper 2 composes the packet check and one-draw experiment.** Paper 3 supplies the metric handoff and same-set MCA error bound. The response check uses a strict scalar radius and retains the original pair and packet verifier. |
| History and proposal anchoring | [Anchor](../../lean/Protocol/Storage/Anchor.lean), [ProjectionAnchor](../../lean/Protocol/Storage/ProjectionAnchor.lean), [CiphertextManifest](../../lean/Protocol/Storage/CiphertextManifest.lean), [Native](../../lean/Protocol/Transfer/Native.lean) | Same artifact, canonical raw seal, checked intent and computed history join. Native recovery separately requires the original-observation certificate and sample-byte equality on that seal. |
| Generic ledger | [ValueFlow](../../lean/Protocol/Ledger/ValueFlow.lean), [State](../../lean/Protocol/Ledger/State.lean), [Transition](../../lean/Protocol/Ledger/Transition.lean) | Constructed valuation, resource flow, nullifier state, action, candidate, policy, computed successor and conditional execution/conservation/replay laws. |
| Checked owned transfer | [OwnedResource](../../lean/Protocol/Ledger/OwnedResource.lean), [Operational](../../lean/Protocol/Transfer/Operational.lean), [Owned](../../lean/Protocol/Transfer/Owned.lean), [Anchored](../../lean/Protocol/Transfer/Anchored.lean) | The fixed-catalogue/snapshot/epoch central transition of §6.2; derived validity/update under the stated check and primitive contracts. |
| Transcript and checked evidence | [TransferTranscript](../../lean/Protocol/Evidence/TransferTranscript.lean), [TransferCheck](../../lean/Protocol/Evidence/TransferCheck.lean), [TransferEnvelope](../../lean/Protocol/Evidence/TransferEnvelope.lean) | Acyclic intent/metadata/packet/root construction and exact checker/evidence joins; raw checks remain distinct from exact soundness interfaces. |
| Signing and authorized issuance | [Signing](../../lean/Protocol/Transfer/Signing.lean), [Issuance](../../lean/Protocol/Transfer/Issuance.lean), [Authorization](../../lean/Protocol/Transfer/Authorization.lean) | Full-intent/domain binding, actual authorized history and fixed-policy consequences; no adaptive signing security is inferred. |
| Generic path proof and outer codec | [PathSignature](../../lean/Protocol/Transfer/PathSignature.lean), [Codec](../../lean/Protocol/Transfer/PathSignature/Codec.lean) | Original supplied path witness and isometric realization remain separate from the coupled finite relation; outer key/message framing is canonical. |
| Paper 1 finite carrier and protocol program | [NativeRelation](../../lean/Protocol/Transfer/PathSignature/NativeRelation.lean), [NativeProgram](../../lean/Protocol/Transfer/PathSignature/NativeProgram.lean) | **Paper 1 supplies the bounded carrier, native instance, sample/projector, typed equivalence and transport.** Paper 2 owns the proof program and its message/credential relation, retaining those exact source objects. |
| Paper 1 finite native sampling | [NativeSampler](../../lean/Protocol/Transfer/PathSignature/NativeSampler.lean) | **Paper 1 source result; consumed here.** Uniform finite seeds, exact cardinality and injective bounded witness decoding feed the protocol experiment with its independent crypto tape. |
| Paper 1 original sampler audit | [NativeRecovery](../../lean/Protocol/Transfer/PathSignature/NativeRecovery.lean) | **Paper 1 source result; consumed here.** The scalar `7/9` recovery audit and known-zero reused-key disclosure explain why the raw-root reference is distinct from the fresh operator-opening profile. |
| Paper 1 sign sampling and ciphertext-only recovery | [NativeSignSampler](../../lean/Protocol/Transfer/PathSignature/NativeSignSampler.lean), [NativeSignPrivacy](../../lean/Protocol/Transfer/PathSignature/NativeSignPrivacy.lean) | **Paper 1 source result; consumed here.** Equal one-use ciphertext laws and the bit/coefficient guessing bounds supply the input family. The protocol separately specifies every released field. |
| Paper 1 bare operator-hash disclosure | [NativeOperatorGuessing](../../lean/Protocol/Transfer/PathSignature/NativeOperatorGuessing.lean) | **Paper 1 source result; consumed here.** Plaintext testing against a bare operator hash motivates the nonce-bearing snapshot name used by the V2 context. |
| Paper 1 coexact noise identity; protocol refresh | [NativeNoiseRefresh](../../lean/Protocol/Transfer/PathSignature/NativeNoiseRefresh.lean) | **Paper 1 proves the transport/correction identity.** Paper 2 owns scoped delivery and refresh policy; the identity alone supplies no public token, fresh-key sampler or lifecycle. |
| Adaptive CRS reference reduction | [CRS](../../lean/Protocol/Transfer/PathSignature/CRS.lean), [NativeSecurity](../../lean/Protocol/Transfer/PathSignature/NativeSecurity.lean) | Supplied actual algorithms; response-dependent bounded oracle and generated logs; five-term reduction for the actual full-ciphertext view under the event-specific Boolean forgery-test hybrid. Primitive estimates and a secure implementation remain external. |
| Approved parsed execution | [Profile](../../lean/Protocol/Transfer/Certificates/Profile.lean), [ProfileAuthentication](../../lean/Protocol/Transfer/Certificates/ProfileAuthentication.lean), [Registered](../../lean/Protocol/Transfer/PathSignature/Registered.lean), [NativeRegistered](../../lean/Protocol/Transfer/PathSignature/NativeRegistered.lean) | Exact quorum-approved program/key/CRS bytes; original metadata/scope/epoch and exact expected-code checks. The native key uses the owner's credential and actual context snapshot/ciphertext names. Honest completeness is conditional; no finality or secure setup generation. |
| Original context and sampled application | [NativeContext](../../lean/Protocol/Transfer/PathSignature/NativeContext.lean), [NativeApplication](../../lean/Protocol/Transfer/PathSignature/NativeApplication.lean) | Actual credential/snapshot/sample/hash and parsed-setup joins; canonical completion of the generated fresh target into the original checked packet. The same-PMF application event inherits the native five-term bound. Arbitrary packet adversaries and general accepted-invalid integrity remain separate. |
| Finite sample arithmetic | [Paper 1 construction](../paper1/README.md), [NativeCircuitRanges](../../lean/Protocol/Transfer/PathSignature/NativeCircuitRanges.lean) | **Paper 1 source result.** The field constraints enforce the original integer ciphertext equations. Paper 2 must bind that arithmetic to the canonical V2 witness and instance bytes and to the proof backend. |
| Canonical byte-owner packets | [TransferCodec](../../lean/Protocol/Evidence/TransferCodec.lean) | Exact existing metadata/intent/packet bytes and full vote targets; malformed semantic fields remain representable. This is a versioned Lean reference profile. |
| Primitive failures and one-shot integrity | [PrimitiveChecks](../../lean/TCB/PrimitiveChecks.lean), [Primitives](../../lean/Protocol/Transfer/Primitives.lean), [Security](../../lean/Protocol/Transfer/Security.lean) | Actual verifier/history interfaces and conditional shared-PMF failure composition; this fixed-history theorem is separate from the bounded adaptive CRS reduction above. Primitive error estimates remain supplied. |
| Public certificate bytes and calibration | [Codec](../../lean/Protocol/Transfer/Certificates/Codec.lean), [Calibration](../../lean/Protocol/Transfer/Certificates/Calibration.lean), [Evidence](../../lean/Protocol/Transfer/Certificates/Evidence.lean), [Bundle](../../lean/Protocol/Transfer/Certificates/Bundle.lean) | Canonical public subjects, actual proof-byte leaves, immutable seven-slot root and predecessor checks; exact rational realization identifies the selected real calibration. The generic packet codec has a concrete byte-owner specialization. |
| Certificate reflection and consumption | [generic contract](../../lean/Protocol/Transfer/Certificates.lean), [Statement](../../lean/Protocol/Transfer/Certificates/Statement.lean), [Native](../../lean/Protocol/Transfer/Certificates/Native.lean), [Projection](../../lean/Protocol/Transfer/Certificates/Projection.lean) | Encoding reflection and operational algorithm agreement are constructed for the actual native/projection relations. Checking yields certification or actual backend/terminal-leaf false acceptance; circuit refinement, cryptographic soundness and knowledge remain open. |
| Proof/TCB envelopes | [ProofCarrying](../../lean/TCB/ProofCarrying.lean), [SNARK](../../lean/TCB/SNARK.lean), [CompressionBoundary](../../lean/TCB/CompressionBoundary.lean), [WitnessVerifier](../../lean/TCB/WitnessVerifier.lean), [Runtime](../../lean/TCB/Runtime.lean) | Named proof/compression/runtime contracts. Legacy well-formedness includes statement truth and cannot establish independent concrete verifier soundness. |
| Retrieval | [CellDirectory](../../lean/Protocol/Storage/CellDirectory.lean), [Retrieval](../../lean/Protocol/Storage/Retrieval.lean) | Checked cell naming under a trusted context and root, unique fragment lookup on the union, original Hodge query/answer correctness, digest-check/collision recovery and whole-bucket selector privacy. Efficient PIR and general native-query privacy remain open. |
| Committee and quorum kernel | [Committee](../../lean/Protocol/Consensus/Committee.lean), [Vote](../../lean/Protocol/Consensus/Vote.lean), [Quorum](../../lean/Protocol/Consensus/Quorum.lean), [Certified](../../lean/Protocol/Ledger/Certified.lean) | Registered weights, authenticated proposal-bound votes, strict quorums and conditional intersection/safety; rounds, locks and finality are not supplied. |

#### Deferred policy, compatibility and implementation families

These families are accounted for in the repository but are outside the
completed bounded transition claim.

| Family | Canonical modules | Status and boundary |
|---|---|---|
| Compatibility axiom/gate bundles | [Foundation](../../lean/Axioms/Foundation.lean), [Ledger](../../lean/Axioms/Ledger.lean), [Consensus](../../lean/Axioms/Consensus.lean), [StageAdmissibility](../../lean/Axioms/StageAdmissibility.lean) | Proposition-level critical-pass/admissibility obligations; they do not implement local aborts, construct typed projection certificates or establish external verifier reflection. |
| Oracle and Heyting policy | [OracleModality](../../lean/Axioms/OracleModality.lean), [Heyting](../../lean/Axioms/Heyting.lean), [Protocol.Oracle](../../lean/Protocol/Oracle.lean) | Finite algebra/quotient laws and interfaces exist; authenticated operational oracle/retry behavior is outside the bounded transition. |
| PoV, spectral geometry and reliability | [Consensus](../../lean/Consensus.lean), [SpectralBounds](../../lean/Axioms/SpectralBounds.lean), [Grassmannian](../../lean/Axioms/Grassmannian.lean) | Supporting interfaces and conditional score bounds, not secure validator selection, economic Sybil resistance or finality. |
| Coregulator | [Coregulator interface](../../lean/Axioms/Coregulator.lean), [protocol attachment](../../lean/Protocol/Coregulator.lean) | Named predict/observe/update obligations; no constructed settling controller. |
| Legacy chain | [Chain](../../lean/Chain.lean) | Compatibility model with spectral identity, raw cochain-sum balance and cumulative-gap fork choice; not the bounded ledger's semantics or a complete consensus/security theorem. |
| Future geometry and lifecycle | No canonical `TaskSheaf`, block-history cellular model or presentation-stack/descent package is constructed | Explicit maps, transport, descent, generation, retirement and global lifecycle policies remain future work. |
| Concrete cryptography and execution | [ZKP](../../lean/Axioms/ZKP.lean), [Runtime](../../lean/TCB/Runtime.lean) | Secure primitive implementation, remaining credential, byte and hash constraints, setup generation, authenticated directories/state origin, secure channels, primitive budgets, corruption/privacy games and production/runtime refinement remain obligations. |

The shared parity register links each interface to its source theorem and
retains the required layout, observation and comparison hypotheses.

### 8. Conclusion

The protocol carries references to the same encrypted object from storage
through authorization, verification and accepted history. Exact artifacts and
full ciphertexts retain separate names; native certificates connect their
bytes to the original Hodge observations and recoverable coefficients.
Predecessor gates consume the same evidence bundle, and approved execution
retains the actual program, key, CRS and full signing message.

The raw-root adaptive CRS reference and nonce-bearing context profile have
distinct constructions and security experiments. The next protocol work is
secure primitive instantiation, field-circuit byte/hash refinement, lifecycle
enforcement and analysis of the complete released view. The mathematical
encryption and its one-use native recovery theorem remain in the HCP paper.
