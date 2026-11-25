# Homotopical Encryption and Proof-Carrying Transactions

## Working manuscript

This manuscript develops Hodge-structured cochain encryption together with
the commitments, finite representations and proof-carrying actions that name
its encrypted objects. The full Markdown draft has no TeX/PDF bundle yet. The
[shared parity table](../../SEMANTIC-PARITY.md) records statement correspondence
and proof status.

### Abstract

We construct an executable harmonic-lattice encryption and recovery mechanism
over finite cellular sheaves. The associated Harmonic Cochain Problem asks for
the operative message from a public semantic class and an observation while
the private Hodge geometry is withheld. Its motivating comparison is recovery
with a hidden lattice, beyond ordinary CVP with a supplied basis.
An integer coupling matrix determines the actual stalk maps, Hodge operator
and intrinsic integral harmonic lattice. Its integer coefficient chart covers
the entire lattice; we prove discreteness, rank and the induced metric.
Exact rational recovery from canonical private-presentation and ciphertext
bytes equals canonical parsing followed by harmonic-lattice decoding on every
byte input. Successful
integer decoding characterizes the original Hodge-encryption language.
Separate cochain and ciphertext transports preserve the declared semantic
class and message coefficients, with commuting projection and recovery
diagrams. A context-bound manifest names the exact artifact and full
ciphertext, joining owner authorization, checked packets and accepted history.
Sampling and disclosure audits distinguish the original scalar profile from
a separate one-use ciphertext candidate and identify the effect of operator
hashes. A bounded adaptive CRS reference reduces fresh-message forgery to
simulation and extraction errors, recovery of the same original coefficients
and explicit hash collisions. The exact public-data obstruction and
ciphertext-only laws retain their declared views; a computational comparison
with CVP and security for the complete public view remain to be proved.

### 1. Problem and contributions

The motivating question is whether concealing the operative harmonic lattice
can create a recovery barrier beyond explicit-lattice CVP. Ordinary CVP
supplies a lattice basis and a target. HCP supplies a public semantic class
and an observation while withholding the particular cellular presentation,
Hodge operator and embedded harmonic lattice that determine the intended
message. Equivalent cochain interpretations can retain the same public class
while changing that recovery geometry.

We construct an executable harmonic-lattice encryption and recovery mechanism
to study this question. In the coupled family, an integer matrix
\(B\in\mathbb Z^{m\times n}\) determines the entire intrinsic lattice,
the harmonic message \((0,z,Bz)\), and the ciphertext
\[
\operatorname{Enc}_B(z,a,u)=(a,z-B^{\mathsf T}u,Bz+u),
\qquad z\in\mathbb Z^n,\quad a\in\mathbb Z,\quad u\in\mathbb Z^m.
\]
Canonical private-presentation and ciphertext bytes feed an exact rational
recovery algorithm. For every such \(B,z,a,u\), it returns the original
integer vector \(z\). Its success on an arbitrary integer ciphertext is
equivalent to that ciphertext being an original Hodge encryption of the
returned message, with integer openings. These algorithms tie the recovery question to the same lattice, private
presentation and observed cochain.

Learning with errors supplies a useful noisy-algebraic recovery comparison.
Search LWE publishes \((A,c=As+e\bmod q)\) and asks for the hidden vector
\(s\), with a uniformly sampled matrix and independently sampled errors
from the specified distribution
([Regev, §1](https://cims.nyu.edu/~regev/papers/qcrypto.pdf)). Here the
message lies in a harmonic lattice and the exact/coexact noise lies in the
orthogonal complement determined by the private Hodge geometry.

| Feature | Explicit-lattice CVP | Search LWE | HCP: native harmonic-lattice profile |
|---|---|---|---|
| Public mathematical input | Basis \(G\) and target \(t\) | \(A,c=As+e\bmod q\) | Declared class \(\alpha_B\) and observation \(b\) |
| Recovery target | A closest point \(Gz\) | Hidden vector \(s\) | The operative message \(h_B(z)\), or its encoded coefficients \(z\) |
| Geometric data | The lattice basis is supplied | A uniformly sampled matrix is supplied | The operative presentation, Hodge operator and harmonic lattice are hidden |
| Error or residual | \(t-Gz\), with no Hodge promise | Independently sampled modular errors \(e\) | Exact/coexact opening \(\delta_0a+\delta_1^*u\), orthogonal to the harmonic space |
| Comparison in this work | The native generated message is the unique CVP answer when its lattice is supplied | Motivating comparison with a different noise model | Constructed encryption/recovery, and an exact public-information obstruction; a stronger computational comparison is a research target |

The HCP column names the declared mathematical observation. A cryptographic
experiment must include every additional released root, credential and proof.
The intended stronger comparison must specify a finite family, sampling law,
efficient adversaries and their CVP-oracle access or reduction. The proved
fixed-observation obstruction is an information separation; it is not yet a
statement that HCP is computationally strictly harder than CVP. This
distinction fixes the research target without making it an assumption of the
construction.

Public verification should also identify the encrypted object to which an
action refers. A cochain commitment can retain only part of that object.
Fixing \(a\) fixes the exact component \(\delta_0a\), while changing
\(z\) or \(u\) changes the full ciphertext. Thus a public reference to the
exact artifact alone does not specify which encrypted cochain accompanies an
action. The construction must preserve the message through presentation
changes and bind both the exact artifact and full ciphertext to the same
public context.

We address these requirements through four contributions.

1. **An explicit harmonic-lattice encryption and recovery mechanism.** We
   construct the cellular sheaves and prove that their entire intrinsic lattice is
   \(\Lambda_B=\{(0,z,Bz):z\in\mathbb Z^n\}\), and identify its Gram
   matrix \(I+B^{\mathsf T}B\) and discrete CVP objective. Its integer
   coefficient chart exhausts that original lattice, with rank \(n\),
   discreteness and full lattice span inside the harmonic subspace. The
   canonical byte recovery algorithm equals canonical parsing followed by
   harmonic-lattice decoding on every byte input. All integer
   matrices of fixed dimensions give equivalent typed cochain interpretations
   in the declared homological semantics, while the embedded harmonic space
   determines \(B\). This supplies a family with shared face constraints in
   which invariant semantics and embedded recovery geometry have distinct
   roles.

2. **Transport of the full ciphertext with the same message.** A cochain shear
   preserves the declared semantic class and integer lattice coefficients.
   We separately construct \(L_{B\to C}=M_CM_B^{-1}\) for the full
   observation map \(M_B(a,z,u)=\operatorname{Enc}_B(z,a,u)\), proving
   \(L_{B\to C}\operatorname{Enc}_B(z,a,u)=\operatorname{Enc}_C(z,a,u)\).
   This transports the noisy ciphertext with the same \(z,a,u\), including
   changes that are not isometries. Exact rational execution, canonical
   codecs for ciphertexts and transport tokens, together with scoped recovery,
   realize this selected integral profile as finite data. The separate maps
   make explicit what is required
   for valid presentation migration beyond cochain equivalence.

3. **Precise commitments and disclosure consequences.** The exact-component
   commitment, full Hodge observation and private geometry retain distinct
   definitions and bindings. Raw coboundary openings are identified modulo
   \(\ker\delta_0\), with modular carry recorded separately. We prove
   recovery and disclosure results for the original observations, including
   the fact that usable transport to a known zero presentation exposes the
   message coefficients. These results specify which information a released
   view and its confidentiality experiment must account for. An explicit
   byte predictor recovers the coefficient with probability \(7/9\) in the
   original bound-one scalar sampler. A separate correlated noise family has
   equal one-use ciphertext laws for all Boolean messages, while its raw
   operator hash enables a two-candidate plaintext test.

4. **A signed reference to the same encrypted object.** One canonical
   two-slot manifest names the original exact artifact and full ciphertext.
   Its root enters the owner's authorization subject and checked packet, and
   the accepted history retains that context and manifest. A separate native
   binding certificate relates the ciphertext bytes to the original bound
   HCP observation; harmonic projection then identifies its target message.
   This certificate supplies the full-observation refinement beyond the
   exact-payload verifier's declared predicate. Under fixed supplied setup,
   the released view is reconstructed from the base view, ciphertext digest,
   owner-signature bytes and proof bytes. This keeps the integrity experiment's
   public inputs explicit and connects public audit references with the
   objects used in verification and recipient recovery. A bounded native
   credential relation supplies the witness for a separate adaptive CRS
   reference construction. Its five-term forgery bound retains the original
   coefficient recovery event and the actual full-ciphertext public view.

Homomorphic correctness provides a useful comparison: decryption of an
evaluated ciphertext agrees with the corresponding computation on messages
([Gentry, Definition 2.1.1](https://crypto.stanford.edu/craig/craig-thesis.pdf)).
Here the central commuting relation concerns admissible changes of cellular
presentation. [Fully key-homomorphic encryption](https://crypto.stanford.edu/~dabo/pubs/abstracts/lattice-abe.html)
also translates ciphertexts across public keys while retaining their plaintext.
Our comparison concerns the explicit cellular presentations, intrinsic
harmonic lattices, permitted transports and verification contracts above.

Primitive security, authenticated setup and delivery, byte availability and
backend behavior remain explicit contracts. The transfer theorem is a
fixed-setup one-shot integrity result, while the CRS construction gives a
separate bounded adaptive reduction over supplied algorithms. Rational
transport is an exact reference algorithm without a proved polynomial
running-time bound. Computational
confidentiality, identity privacy, efficient private information retrieval,
arbitrary circuit evaluation
and consensus finality remain separate objectives. The known-lattice CVP
comparison and public-data ambiguity theorem retain the scope specified above.

Sections 2–3 define the original geometry, public observations and commitment
construction. Sections 4–5 retain the metric and disclosure hypotheses of the
selected application. Section 6 gives transport, recipient recovery, signed
transaction verification and the conditional integrity experiment. The parity
table records the correspondence with the formal statements.

### 2. Maintained geometry, temporary processing and retained artifacts

The source presentation consists of a finite oriented incidence complex, its
stalks and restriction maps, inner-product conventions and compatible integral
stalk lattices. The current cellular model uses coordinate stalks with their
standard Euclidean metrics; its integral structure is separate supplied data.
The secret and public parts of this presentation are selected by the profile.
These objects determine the cochain spaces before a message or noise opening
is chosen. The restriction maps assemble into the differentials, and the
inner products determine their adjoints and the true degree-one Hodge operator

\[
C^0(F)\xrightarrow{\delta_0}C^1(F)\xrightarrow{\delta_1}C^2(F),
\qquad \Delta_1=\delta_0\delta_0^*+\delta_1^*\delta_1.
\]

#### 2.1. Private geometry, harmonic messages and the recovery diagrams

The phrase *private operator* refers to this presentation and its derived
Hodge data, rather than an independently supplied positive matrix. The
dependency is

\[
\mathcal G\longmapsto
(C^\bullet(F),\delta_0,\delta_1,\langle\ ,\ \rangle,I)
\longmapsto (\Delta_1,P_H,\Lambda_F),
\qquad
\Lambda_F=C^1_{\mathbb Z}(F)\cap\ker\Delta_1.
\]

A coefficient encoding, when used, selects points in this same lattice.
The harmonic message \(h\in\Lambda_F\) is already a cochain. An opening
\((a,u)\in C^0(F)\times C^2(F)\) constructs its full observation

\[
b=h+\delta_0a+\delta_1^*u\in C^1(F),\qquad P_Hb=h.
\]

An integral wire profile can encode residues of the same differential value
\(\delta_0a\). The original observation additionally binds its selected real
decoder to that exact summand of \(b\); modular equality alone does not give
the real decoder equation. The encoded artifact is not itself a real cochain
summand and does not determine the full ciphertext or its harmonic message.
The Laplacian alone does not specify arbitrary integral lattices, coefficient
bases or an exact/coexact decomposition in a general presentation.

In the coupled profile, all data except the integer matrix
\(B\in\mathbb Z^{m\times n}\) and its dimensions are fixed: the incidence
complex, scalar stalks, standard Euclidean metrics, standard integer stalk
lattices, coordinate ordering and graph basis. The existing constructors
therefore reconstruct one geometry \(\mathcal G_B\) without choosing another
operator or message space. In its coordinates,

\[
\delta_{0,B}a=(a,0,0),\quad
\delta_{1,B}(a,x,y)=y-Bx,\quad
\Delta_B(a,x,y)=\bigl(a,-B^{\mathsf T}(y-Bx),y-Bx\bigr).
\]

Both the actual differential \(\delta_{1,B}\) and the actual Hodge operator
\(\Delta_B\), in these fixed coordinates, determine \(B\) uniquely. Thus
committing to a canonical \(B\) can bind the complete geometry of this
profile. Allowing varying metrics, topology, integral lattices or bases would
require a new reconstruction profile and its data; it is not encoded by an
unqualified matrix hash. A snapshot's indexing by \(F\) does not supply such
a reconstruction or authenticate additional choices.

The lattice is constructed from these same objects. The real graph chart
\(g_B:\mathbb R^n\simeq W_B\) and integer chart
\(e_B:\mathbb Z^n\simeq\Lambda_B\) are linear equivalences over their
respective scalar rings. The integer chart is exactly the existing harmonic
point encoding, not a second message lattice. After restricting the original
subgroup to \(W_B\), it equals the integer span of the real graph basis.
Its integral rank is \(n\); both its original and restricted carriers are
discrete, and the restricted object is a full lattice in \(W_B\).
These properties are proved in [CoupledLattice](../../lean/HCP/CoupledLattice.lean).
Full real span and equality with the intrinsic integral subgroup remain
separate conditions for a general harmonic-lattice presentation.
The integer native profile also derives coexact integrality from
\(\delta_{1,B}^*u=(0,-B^{\mathsf T}u,u)\). The generic integral-structure
laws preserve the differentials; they do not assert preservation of arbitrary
chosen stalk lattices by their adjoints. The finite mechanism uses the actual
standard integral and metric profile proved above.

For two same-size presentations, put
\(K_B=C^\bullet(F_B)\), \(W_B=\ker\Delta_B\),
\(g_B(z)=(0,z,Bz)\), and

\[
S_{B,C}(a,x,y)=(a,x,y+(C-B)x),\quad
M_B(a,z,u)=(a,z-B^{\mathsf T}u,Bz+u),\quad
L_{B\to C}=M_CM_B^{-1}.
\]

The strict cochain map \((1,S_{B,C},1):K_B\cong K_C\) supplies the typed
Helfer equivalence of their actual interpretations and equality of the
declared public homological theories. Helfer's semantic invariance concerns
interpretations of the declared signature. The Hodge adjoints and metric are
additional geometric data; the current cochain model uses homological closed
tests, not a logical signature asserting covariance of every Hodge operator.

The [commutative diagrams](sections/geometry-diagrams.tex) have two triangles
and a central square. The upper triangle assembles a real coordinate triple
by \(M_B\) or \(M_C\); the lower triangle reads the coefficients of a
harmonic graph vector. The square is

\[
P_C L_{B\to C}=\left.S_{B,C}\right|_{W_B}P_B,\qquad
\operatorname{info}_C P_C L_{B\to C}=\operatorname{info}_B P_B.
\]

These equations hold on every real cochain. The tailored map \(L_{B\to C}\)
carries the harmonic and noise summands separately, so this projection square
does not require an isometry. On harmonic vectors, \(L_{B\to C}\) and
\(S_{B,C}\) agree. On general ciphertexts they differ: the scalar
\(B=0,C=1,b=(0,0,1)\) gives \(S_{B,C}P_Bb=0\), while
\(P_CS_{B,C}b=(0,1/2,1/2)\). One cannot replace the upper arrow of the
square by the cochain shear. Identity, inverse and composition of \(L\) are
already proved. This is a coherent family of selected linear transports;
no general stack, descent construction or realization of arbitrary paths is
inferred from the diagram.

Restricting the upper triangle to integer message and opening coordinates
recovers the original native samples and intrinsic integral harmonic messages.
It makes no claim that projection or transport preserves every arbitrary
integer cochain. These mathematical comparison maps establish the core
geometry and recovery identities; account recovery policy, key generation,
rotation and lifecycle enforcement are separate protocol concerns.

There is also a direct finite recovery path. Let \(E_B(z,a,u)\) be the
canonical full-ciphertext bytes and \(D_B\) the algorithm that parses those
bytes, casts the same integer cochain to rational coordinates, applies the
exact inverse of \(M_B\), and returns its information coordinates only when
all are integers. Then

\[
D_B(E_B(z,a,u))=\operatorname{some}(z),\qquad
D_B(\beta)=\operatorname{some}(z)
\ \Longleftrightarrow\
\exists a\in\mathbb Z,\ u\in\mathbb Z^m:\ \beta=E_B(z,a,u).
\]

The rational decoder agrees with the original harmonic-lattice partial
decoder on every rational cochain, including nongenerated inputs
([CoupledDecoding](../../lean/HCP/CoupledDecoding.lean)). Its
[byte consumer](../../lean/Protocol/Storage/CoupledRecovery.lean) loads the
private matrix through the existing canonical key codec and recovers from
the actual ciphertext bytes. It uses neither a transport token nor a sample's
stored message field. The input-language theorem imposes no opening bounds
or authentication requirement.

The [Lean execution example](../../lean/Protocol/Storage/CoupledRecovery/Demo.lean)
uses \(B=(1\ 1)\), \(z=(2,-1)\), \(a=3\), \(u=4\). It constructs
the canonical ciphertext with coordinates \((3,-2,-5,5)\), loads the
canonical private-key bytes and recovers \((2,-1)\). The same example checks
rejection of truncated key/ciphertext bytes and an integer observation whose
projected message coefficients are nonintegral.

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

The concrete protocol retains the following three visibility levels. The
full Hodge sample from [Paper 1](../paper1/sections/02-harmonic-cochain-problem.tex)
and the exact committed component are distinct objects; their commitment,
disclosure and access contracts belong to this paper:

| Level | Data and exposure |
|---|---|
| Private witness | The base and ephemeral presentations, restrictions and operative Hodge data, harmonic message, noise, openings and transport. The full cochain \(b\) remains private unless a specified observation path explicitly publishes or exposes it. |
| Public payload | The serialized residue edge vector \(\bar c=\delta_0a\bmod q\), modulus, declared edge count and topology tag; public artifact handles and root bindings refer to the selected objects. This payload is not the full Hodge sample or a presentation of its operator. |
| Selective opening/proof | Only the declared local values, conditions or verified statements are exposed. An opening or proof does not make every field of its semantic witness record public. |

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

The protocol binds the original payload, extracted pair and code parameters
before sampling an affine challenge under the declared distribution. A fixed
mix requires an authenticated restricted-line profile and the corresponding
goodness result from Paper 3. Its challenge computations and fixed-mix
counterexamples are not repeated here.

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

The coupled family admits a separate
[full-ciphertext transport](../../lean/HCP/CoupledTransport.lean) without
requiring an isometry. Its original sample has the coordinate map
\[
M_B(a,z,u)=(a,z-B^{\mathsf T}u,Bz+u).
\]
This is a real linear equivalence. In the fixed Euclidean coordinate carrier,
the coupling terms cancel in
\(\langle q,M_Bq\rangle=\langle q,q\rangle\), proving injectivity; finite
dimensionality gives invertibility. Define
\[
L_{B\to C}=M_CM_B^{-1}.
\]
The proved law is
\[
L_{B\to C}\operatorname{Enc}_B(z,a,u)
 =\operatorname{Enc}_C(z,a,u).
\]
Identity, inverse and composition follow from these same coordinate
equivalences. Generated integral observations remain generated integral
observations, with the same message and exact/coexact opening coordinates.
This is the native ciphertext correctness map; it is different from the
strict cochain shear used to prove semantic equivalence. It need not preserve
norms or a subsequent proximity metric.

The [exact rational refinement](../../lean/HCP/CoupledRational.lean) computes
this map by determinant/adjugate inversion. Its realization equals the real
transport, and its denominator-checked private decoder recovers the original
integer coefficients. This is an executable reference algorithm; no
polynomial running-time bound is asserted.

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

#### 6.3.1. Confidentiality and the intended hardness claim

At fixed rank, the operative harmonic space is a point of the Grassmannian,
whose Plücker image is a projective variety of decomposable exterior points.
The full real projective point determines the harmonic projector, so
releasing that point together with the observed cochain \(b\) determines
\(h=P_Wb\). For the keyed coordinate family below, the full point even
determines the key. A hidden-operator profile must specify the released handle
and its hiding contract separately from the full frame used by a proof witness.
The existing `HashedPluckerShadow` still carries its selected shadow internally;
its digest-binding field alone supplies no hiding theorem.

The [projection chain](../../lean/Proximity/Concrete/ProjectionChain/Core.lean)
maps a frame through a cochain payload, plane shadow and RS word. Its
Plücker-to-cochain encoder and stage comparisons are supplied data;
[ProjectionAnchor](../../lean/Protocol/Storage/ProjectionAnchor.lean) separately
joins the state to the original artifact. The composed theorem preserves
validity and proves that RS distance is at most the declared source
disagreement. The canonical
pair reduction
has a separate Hamming-distance comparison; a single challenge fold can
collapse a pair. These maps do not supply a Euclidean CVP solution map.

The [checked-release challenge](../../lean/Protocol/Transfer/Confidentiality.lean)
proves that the released input ID is an immediate branch distinguisher whenever
two checked transfers use different inputs. A confidentiality challenge must
therefore hold such deterministic public fields fixed, or declare their
leakage. A challenge over two transfers in one fixed configuration checks this
view condition; it does not sample two HCP plaintexts or prove encryption
privacy. The optional full-cochain disclosure is a separate, larger view.

For a fixed supplied setup and transfer,
[PublicAssembly](../../lean/Protocol/Transfer/PublicAssembly.lean) reconstructs
every checked release from its public base payload, selected ciphertext digest,
owner-signature bytes and proof bytes using the original manifest, hash and
packet functions. An event bound for distributions of those four actual
inputs carries to the assembled view by deterministic postprocessing. Such a
bound must come from independent algorithms and security arguments; the
reconstruction alone asserts no hiding. Downloaded ciphertext bytes and access
metadata extend the experiment when available to the observer.

The [finite keyed cellular family](../../lean/Sheaf/HCPFiniteKeyFamily.lean)
provides one structural starting point. At parameter \(n\), its key is a
binary choice in each block, with \(2^n\) keys and one common
\(4n\)-coordinate degree-one carrier. Separate exact and coexact edges give
both nonzero differentials when \(n>0\). Standard integral stalks support an
integral harmonic unit message and an actual Hodge-encrypted sample with
exact and coexact openings whose coordinates lie in \(\{0,1\}\); harmonic
projection recovers that message.
The [shared harmonic geometry](../../lean/Sheaf/HCPFiniteKeyGeometry.lean)
proves that different keys select different embedded harmonic subspaces in
this carrier and that the complementary units span each one. The
[projective adapter](../../lean/Proximity/Concrete/HCPKeyedGrassmannian.lean)
packages them as rank-\(n\) Grassmannian points and frame witnesses.
This is a family of typed mathematical samples, prior to key/ciphertext bytes,
randomized key/noise generation or a complete released-view experiment.
The [explicit lattice presentation](../../lean/HCP/FiniteKeyCVP.lean) takes
those harmonic units as its basis and spans the actual keyed harmonic space.
Its unit-coefficient encryption is the original family sample, and a correct
CVP oracle given that keyed lattice returns the sample's harmonic message.

The [coupled cellular family](../../lean/Sheaf/HCPCoupledFamily.lean) replaces
independent coordinate choices with shared integral face equations. For an
integer matrix \(B\in\mathbb Z^{m\times n}\), scalar information and parity
edge stalks satisfy \(y=Bx\); a separate exact edge gives a nonzero
\(\delta_0\). Its harmonic space and intrinsic integral harmonic lattice are
exactly
\[
W_B=\{(0,x,Bx):x\in\mathbb R^n\},\qquad
\Lambda_B=\{(0,z,Bz):z\in\mathbb Z^n\}.
\]
The [explicit presentation](../../lean/HCP/CoupledCVP.lean) contains the whole
intrinsic lattice, with Gram matrix \(I+B^{\mathsf T}B\). Its closest-vector
objective at target \((a,u,v)\) is
\[
a^2+\|u-z\|^2+\|v-Bz\|^2,\qquad z\in\mathbb Z^n.
\]
Shared rows can introduce off-diagonal coefficient interactions. The graph
description lies in a fixed information-coordinate chart of a Grassmannian;
the current Lean construction proves the embedded-space and lattice facts,
without constructing an algebraic variety.

The [semantic connection](../../lean/HCP/CoupledSemantics.lean) is constructed
from the actual cochain complexes. For any two matrices of the same dimensions,
the integral shear
\((a,x,y)\mapsto(a,x,y+(C-B)x)\) intertwines both coboundaries and has the reverse
shear as inverse. This gives a strict cochain isomorphism, a typed Helfer
equivalence and equality of the declared homological closed theories. It also
carries \((0,z,Bz)\) to \((0,z,Cz)\). The shear generally changes the Euclidean
metric, so it supplies no Hodge-adjoint or full-ciphertext transport law.
An actual `PresentedRotation` still requires the existing isometric and
same-coefficient conditions. Equal public classes also leave snapshot/header
equality as a separate released-view obligation.
Section 6.1.1 constructs the different native coordinate transport that does
carry full ciphertexts between arbitrary same-size matrix presentations.

The [integral opening profile](../../lean/Sheaf/HCPCoupledEncoding.lean)
instantiates the original Hodge sample with integer \(z,a,u\), and proves its
entire observation is
\[
b=(a,\ z-B^{\mathsf T}u,\ Bz+u).
\]
Its executable integer coordinates cast to that same sample's real observed
cochain. The [full ciphertext codec](../../lean/Protocol/Storage/CoupledCiphertext.lean)
uses a separate versioned domain, explicit matrix dimensions and the ordered
exact, information and parity coordinates. Its actual decoder reconstructs
the original full observation, and the original harmonic recovery theorem
then returns the same message. A byte-hash check and binding indexed by the
existing `BoundHCPObservation` retain the original exact artifact, snapshot
and lifecycle; the full-ciphertext digest has its own name. This closes the
finite representation of this integral native profile. It leaves the
transaction/proximity theorem's selected full-observation relation and
cryptographic proof construction to be supplied explicitly.

A finite native sampler is constructed in §6.6. A computational hardness
theorem still requires justified parameter and distribution choices, efficient
algorithms and a game releasing the actual selected storage and transfer
fields. Its reduction must start from an independently stated hard problem
and preserve the challenge distribution. The earlier axis
sampler has an [exact geometric promise](../../lean/Sheaf/HarmonicCVPPromise.lean):
for a presented lattice
\(\Lambda\subseteq W\), observations of the form \(b=h+e\) with
\(h\in\Lambda\) and \(e\perp W\) have \(P_Wb\in\Lambda\); conversely that
projection condition gives such an orthogonal decomposition. An arbitrary
CVP target need not satisfy it. Mapping a lattice to its real span and
projecting the target therefore leaves the discrete nearest-vector step
unsolved. The present CVP theorem
proves a strict separation in the information supplied to a solver: the
operative lattice lets a correct CVP oracle recover each axis sample, while
the same oracle cannot choose two different targets at their shared
\((\alpha,b)\). Both axis samples also have exact component zero. This
establishes no computational hardness reduction or equality of their complete
storage records. With the canonical systematic source, the full-cochain
disclosure fails already by the direct recovery in §2.2.

For a fixed key, [NoiseSpanAttack](../../lean/HCP/NoiseSpanAttack.lean)
proves a second conditional boundary: if observed zero encryptions span the
harmonic orthogonal noise space, span membership separates every fresh zero
sample from every sample with a nonzero presented harmonic message. The
present rotation laws transport samples; they do not establish fresh-key
generation or defeat this test.

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

##### 6.6.1. Bounded native witness and actual geometric meaning

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

The [finite sampler](../../lean/Protocol/Transfer/PathSignature/NativeSampler.lean)
chooses matrix and integer coordinates from \(\{-K,\ldots,K\}\) and an
\(\ell\)-byte salt. Its seed space has cardinality
\[
 N=(2K+1)^{2mn+n+m+1}\,256^\ell.
\]
Every seed has mass \(N^{-1}\). Injective decoding gives the same mass to its
private witness, and every supported witness satisfies the selected bounds.
A fixed cryptographic-tape law is sampled independently of the native seed,
retaining both marginals. Hash-derived public keys need not be uniform or
distinct. This family includes zero messages and degenerate matrices;
cardinality and bounded support alone establish no hardness or confidentiality.

The [finite program](../../lean/Protocol/Transfer/PathSignature/NativeProgram.lean)
\(p=(m,n,K,\ell)\) and its public instance have canonical codecs. Its Boolean
relation \(R_{p,H}(x,\eta)\) accepts exactly when \(\eta\) canonically decodes
to a bounded witness \(w\) with \(x_w=x\). The decoded sample is the actual
\(\operatorname{Enc}_C(z,a,u)\), whose original harmonic projector returns
\((0,z,Cz)\). The existing operative-HCP comparison identifies this same
message as the target.

The strict cochain isomorphism proves typed Helfer equivalence of the actual
source and target interpretations. Independently, \(M_CM_B^{-1}\) transports
their full native samples with the same \(z,a,u\), including nonisometric
changes. These are proved on the witness's original objects, rather than
inferred from matching profile labels. The finite relation alone constructs
neither the generic path witness above nor an artifact-bound
`BoundHCPObservation` and its storage/lifecycle acceptance; the latter still
requires the original binding certificates.

##### 6.6.2. Sampling, disclosure and fresh operators

Uniform finite coordinates do not give a small recovery probability. In the
original scalar sampler with bound one, a
[public byte predictor](../../lean/Protocol/Transfer/PathSignature/NativeRecovery.lean)
recovers \(z\) with probability exactly \(7/9\) under the full original seed
law, for every credential-salt length and with an independent crypto tape
appended. It ignores hashes, source presentation and exact opening. A known
zero message with \(u\ne0\) also reveals a reused scalar operator through
\(x=-Cu\), \(y=u\), hence \(C=-x/y\). These are coefficient/key recovery
results, not automatic signature-of-knowledge forgeries.

The [fresh-sign candidate](../../lean/Protocol/Transfer/PathSignature/NativeSignSampler.lean)
instead correlates the coexact opening with the chosen message. Fix public
\(A\in\mathbb Z^{m\times n}\) with \(A^{\mathsf T}A=dI\), \(d>0\).
For a fresh uniform sign key \(k\in\{-1,1\}^n\), chosen message signs
\(s\in\{-1,1\}^n\), and exact opening \(a\) independent of both, set
\[
 C_k=A\operatorname{diag}(k),\qquad z=ds,\qquad u=C_ks.
\]
The actual original sample is
\[
 \operatorname{Enc}_{C_k}(ds,a,C_ks)
 =\bigl(a,0,(d+1)A(k\mathbin\odot s)\bigr).
\]
Here \(\odot\) is coordinatewise multiplication. For fixed \(s\), masking
permutes the finite uniform key space. Thus the canonical full ciphertext-byte
laws are equal for every pair of messages, and deterministic ciphertext
digests preserve that equality. The original private harmonic projection
still recovers \((0,ds,C_kds)\); positive \(d\) makes the message encoding
injective. Both \(A=I,d=1\) in every dimension and the dense two-by-two
Hadamard matrix with \(d=2\) instantiate the construction.

For an independent uniform Boolean message and fresh uniform key, the
[actual joint law](../../lean/Protocol/Transfer/PathSignature/NativeSignPrivacy.lean)
factors into a uniform message independent of the ciphertext. Every total
complete-message decoder therefore succeeds with probability exactly
\(2^{-n}\). This remains true for a deterministic ciphertext digest and an
independently sampled fixed random tape. For positive \(d\), correct encoded
coefficient recovery is equivalent to correct bit-vector recovery. An
arbitrary partial integer-coefficient extractor, allowing invalid outputs or
failure, has success at most \(2^{-n}\), also with the independent tape. The
uniform-target hypothesis belongs to this guessing statement; equality of
ciphertext laws for each pair of fixed messages does not need it.

This one-use ciphertext law excludes the key-dependent operator snapshot.
From the parity coordinates \(y\), the public left inverse gives
\[
 t=\frac{A^{\mathsf T}y}{d(d+1)}=k\mathbin\odot s.
\]
For candidate messages \(s_0,s_1\), compute \(k_i=t\mathbin\odot s_i\)
and \(C_i=A\operatorname{diag}(k_i)\). A public raw root
\(H(\operatorname{enc}(C_k))\) permits testing both with two forward hashes.
The [actual-byte candidate test](../../lean/Protocol/Transfer/PathSignature/NativeOperatorGuessing.lean)
parses the ciphertext, recovers the masked signs by public transpose/parity
arithmetic and constructs those canonical operator bytes. The true plaintext
passes; a wrong candidate that passes yields a collision between distinct
canonical matrix bytes. Key entropy therefore does not repair this snapshot view.
Reusing the sign key also retains the usual one-time-mask limitation; the
proved law is neither encryption-oracle nor repeated-key security.

The selected design target is exact harmonic recovery with fresh geometry per
public encrypted object and persistent private master-key management.
Wallet-at-rest and reused-geometry encryption remain separate. The sign
sampler remains a nondefault implementation candidate until actual hiding
operator binding and its versioned native wire are built. Generic snapshot
and context carriers can stay; the private opening, public instance, witness
codec and context joins must be versioned and checked. A hiding flag is
insufficient. Content
hashes name encrypted material. The selected public-view design excludes
operator nullifiers, full projectors/kernel Plücker data and usable transport
to a known presentation. Its exact opening/artifact must be message-independent,
and the joint view of public records, auxiliary data and proof transcripts
still needs analysis.

Fresh sampling also differs from ordinary transport, which preserves
\(z,a,u\). The target sign law prescribes \(u'=C_{k'}s\). The actual
[coexact refresh](../../lean/Protocol/Transfer/PathSignature/NativeNoiseRefresh.lean)
satisfies
\[
 \operatorname{Enc}_{C_{k'}}(z,a,u)
 +\operatorname{Enc}_{C_{k'}}(0,0,u'-u)
 =\operatorname{Enc}_{C_{k'}}(z,a,u').
\]
Its canonical-byte parser and correction return the desired target sample.
At fixed target and message, migrated bytes already equal the fresh target
bytes exactly when the retained and desired openings agree. This operation
does not generate fresh keys, enforce one use or provide a safe public refresh
token.

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

##### 6.6.4. Approved execution and finite arithmetic core

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

The [generated rank-one arithmetic core](../../lean/Protocol/Transfer/PathSignature/NativeCircuit.lean)
has exactly \(2mn+n+m+1\) constraints: \(2mn\) matrix-coordinate products,
\(n+m\) coordinate equations and one exact-coordinate equation. Every
integer matrix, message and opening has an explicit satisfying assignment,
both over the integers and modulo the chosen modulus. The
[integer range checker](../../lean/Protocol/Transfer/PathSignature/NativeCircuitBounds.lean)
bounds inputs by \(K\), products by \(K^2\), and information/parity outputs
by \(K+mK^2\) and \(K+nK^2\). Every gate residual is at most
\[
 M=\max\{2K^2,2(K+mK^2),2(K+nK^2),2K\}.
\]
A modulus \(q>M\), modular satisfaction and those checked ranges imply the
original integer ciphertext equations. Honest bounded witnesses pass the
range check. This checks integer lifts: compiling range/salt checks, canonical
byte parsing and hashes into field constraints remains separate. General
real projection certificates do not
automatically become this finite circuit.

#### 6.7. Harmonic-lattice recovery and optional encrypted evaluation

The [retrieval layer](../../lean/Protocol/Storage/Retrieval.lean) recovers the
encrypted-database/private-read intention using the existing manifest, actual
HCP samples and private recovery material. The primary object is the original
Hodge-encrypted harmonic-lattice cochain; hash-indexed lookup and recipient
recovery retain that same object. Encrypted linear-query evaluation is an
optional application of its aggregation laws. It supplies neither the
definition of the harmonic lattice nor the storage commitment.

The optional query construction is
in [HodgeQuery](../../lean/Protocol/Storage/Retrieval/HodgeQuery.lean). For a
selected position \(i\), integer database values \(d_j\), coefficients \(z\)
and existing exact/coexact openings \(e_j\), the columns are
\(q_j=(H.\mathrm{encrypt}(\mathbf{1}_{j=i}z,e_j)).\mathrm{observed}\).
The server forms \(A=\sum_j d_j q_j\) using only the observed columns and
public integer weights. `answer_eq_observed` identifies this entire answer
with the original encryptor applied to \(d_i z\): its exact and coexact
openings are the corresponding weighted sums. No replacement ambient-noise
model is introduced. The existing coefficient decoder returns \(d_i z\),
and `cvp_answer_iff` identifies the same answer's unique closest point in
the selected explicit harmonic lattice.

The earlier `HCPBridge.cvpOracle_insufficient_for_operativeTarget` in
[Hardness](../../lean/Hardness.lean) remains the declared uniform comparison:
under closed-formula invariance, kernel separation and existence of a correct
explicit-lattice oracle, no single solver is exact on the operative target
for every correct oracle at the specified public input. The full joint query
can contain additional observations. Extending that theorem to this view
requires its own factorization or sampled security argument.
[LinearQueryObstruction](../../lean/Protocol/Storage/Retrieval/LinearQueryObstruction.lean)
records a precise extra condition: when the selected column has nonzero
harmonic projection, the other projections vanish and the nonselected columns
are redundant, the selected column is the unique one outside the span of
the others. This predicate uses only the public query. Its concrete example
uses the original cellular axis sample and varying nonzero coexact openings,
and retains the existing CVP comparison for those same samples. The result
is a conditional joint-view obstruction, not a universal rejection of native
HCP queries or a theorem about an unspecified random sampler.

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

A later comparison with fully homomorphic encryption should specify the
supported operations on these actual ciphertexts, their output/recovery
semantics and the corresponding security experiments. The present linear
aggregation theorem supplies one entry in that inventory; no arbitrary
encrypted-computation interface is constructed here.

### 7. Construction ownership and remaining protocol work

This inventory assigns each protocol family to Paper 2 without treating every
interface as a completed cryptographic construction. A constructed record or
conditional preservation theorem retains all of its supplied profiles.
The bounded central claim is the checked transfer in §6.2 and its explicitly
scoped one-shot integrity comparison in §6.3.

| Family | Canonical modules | Status and boundary |
|---|---|---|
| Source presentation and derived operators | [Cellular](../../lean/Sheaf/Cellular.lean), [Hodge](../../lean/Sheaf/Hodge.lean), [Integral](../../lean/Sheaf/Integral.lean), [CoupledGeometry](../../lean/HCP/CoupledGeometry.lean) | Existing source objects determine the fixed-profile operators, lattice and cochain space. The true Hodge operator reconstructs the coupling matrix; the all-real assembly/recovery triangles and projection square are proved on those same objects. Generic independently varying geometry and its finite codec remain separate. |
| Intrinsic lattice, finite decoding and direct bytes | [CoupledLattice](../../lean/HCP/CoupledLattice.lean), [CoupledDecoding](../../lean/HCP/CoupledDecoding.lean), [CoupledRecovery](../../lean/Protocol/Storage/CoupledRecovery.lean) | The same original subgroup has real/integer charts, an integer basis, rank and discreteness; all-rational decoder refinement and exact integer ciphertext-language characterization feed direct key/ciphertext-byte recovery. No separate message lattice or rotation token is introduced. |
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
| History and proposal anchoring | [Anchor](../../lean/Protocol/Storage/Anchor.lean), [ProjectionAnchor](../../lean/Protocol/Storage/ProjectionAnchor.lean), [CiphertextManifest](../../lean/Protocol/Storage/CiphertextManifest.lean), [Native](../../lean/Protocol/Transfer/Native.lean) | Same artifact, canonical raw seal, checked intent and computed history join. Native recovery separately requires the original-observation certificate and sample-byte equality on that seal. |
| Generic ledger | [ValueFlow](../../lean/Protocol/Ledger/ValueFlow.lean), [State](../../lean/Protocol/Ledger/State.lean), [Transition](../../lean/Protocol/Ledger/Transition.lean) | Constructed valuation, resource flow, nullifier state, action, candidate, policy, computed successor and conditional execution/conservation/replay laws. |
| Checked owned transfer | [OwnedResource](../../lean/Protocol/Ledger/OwnedResource.lean), [Operational](../../lean/Protocol/Transfer/Operational.lean), [Owned](../../lean/Protocol/Transfer/Owned.lean), [Anchored](../../lean/Protocol/Transfer/Anchored.lean) | The fixed-catalogue/snapshot/epoch central transition of §6.2; derived validity/update under the stated check and primitive contracts. |
| Transcript and checked evidence | [TransferTranscript](../../lean/Protocol/Evidence/TransferTranscript.lean), [TransferCheck](../../lean/Protocol/Evidence/TransferCheck.lean), [TransferEnvelope](../../lean/Protocol/Evidence/TransferEnvelope.lean) | Acyclic intent/metadata/packet/root construction and exact checker/evidence joins; raw checks remain distinct from exact soundness interfaces. |
| Signing and authorized issuance | [Signing](../../lean/Protocol/Transfer/Signing.lean), [Issuance](../../lean/Protocol/Transfer/Issuance.lean), [Authorization](../../lean/Protocol/Transfer/Authorization.lean) | Full-intent/domain binding, actual authorized history and fixed-policy consequences; no adaptive signing security is inferred. |
| Generic path proof and outer codec | [PathSignature](../../lean/Protocol/Transfer/PathSignature.lean), [Codec](../../lean/Protocol/Transfer/PathSignature/Codec.lean) | Original supplied path witness and isometric realization remain separate from the coupled finite relation; outer key/message framing is canonical. |
| Finite native witness and program | [NativeRelation](../../lean/Protocol/Transfer/PathSignature/NativeRelation.lean), [NativeProgram](../../lean/Protocol/Transfer/PathSignature/NativeProgram.lean) | Canonical bounded witness/instance/program codecs, actual sample/projector and typed Helfer equivalence, native nonisometric transport and original-target-or-byte-collision comparison. |
| Finite native sampling | [NativeSampler](../../lean/Protocol/Transfer/PathSignature/NativeSampler.lean) | Uniform finite seeds, exact cardinality, injective bounded witness decoding and a fixed independent crypto tape. Public-hash uniformity and hardness do not follow. |
| Original sampler recovery audit | [NativeRecovery](../../lean/Protocol/Transfer/PathSignature/NativeRecovery.lean) | Actual-byte scalar coefficient recovery has exact mass `7/9` under the original full seed law for any salt length and independent crypto tape. Known-zero reused-key recovery is separate from automatic forgery. |
| Proposed sign sampling and ciphertext-only recovery | [NativeSignSampler](../../lean/Protocol/Transfer/PathSignature/NativeSignSampler.lean), [NativeSignPrivacy](../../lean/Protocol/Transfer/PathSignature/NativeSignPrivacy.lean) | Equal one-use canonical ciphertext laws, identity/dense examples and exact `2^-n` total message-guessing mass and at most `2^-n` partial coefficient recovery for independent uniform targets. This is not the default storage/full-view profile. |
| Bare operator-hash disclosure | [NativeOperatorGuessing](../../lean/Protocol/Transfer/PathSignature/NativeOperatorGuessing.lean) | Actual ciphertext parsing recovers the mask; true candidate hashes match, while wrong accepted guesses give canonical matrix-byte collisions. No timed CPA theorem is asserted. |
| Coexact noise refresh | [NativeNoiseRefresh](../../lean/Protocol/Transfer/PathSignature/NativeNoiseRefresh.lean) | Actual original transport plus the byte correction yields the prescribed target opening. Transport alone retains old noise; no public token, fresh key or lifecycle is supplied. |
| Adaptive CRS reference reduction | [CRS](../../lean/Protocol/Transfer/PathSignature/CRS.lean), [NativeSecurity](../../lean/Protocol/Transfer/PathSignature/NativeSecurity.lean) | Supplied actual algorithms; response-dependent bounded oracle and generated logs; five-term reduction for the actual full-ciphertext view under the event-specific Boolean forgery-test hybrid. Primitive estimates and a secure implementation remain external. |
| Approved parsed execution | [Profile](../../lean/Protocol/Transfer/Certificates/Profile.lean), [ProfileAuthentication](../../lean/Protocol/Transfer/Certificates/ProfileAuthentication.lean), [Registered](../../lean/Protocol/Transfer/PathSignature/Registered.lean), [NativeRegistered](../../lean/Protocol/Transfer/PathSignature/NativeRegistered.lean) | Exact quorum-approved program/key/CRS bytes; original metadata/scope/epoch and exact expected-code checks. The native key uses the owner's credential and actual context snapshot/ciphertext names. Honest completeness is conditional; no finality or secure setup generation. |
| Original context and sampled application | [NativeContext](../../lean/Protocol/Transfer/PathSignature/NativeContext.lean), [NativeApplication](../../lean/Protocol/Transfer/PathSignature/NativeApplication.lean) | Actual credential/snapshot/sample/hash and parsed-setup joins; canonical completion of the generated fresh target into the original checked packet. The same-PMF application event inherits the native five-term bound. Arbitrary packet adversaries and general accepted-invalid integrity remain separate. |
| Finite sample arithmetic | [NativeCircuit](../../lean/Protocol/Transfer/PathSignature/NativeCircuit.lean), [NativeCircuitBounds](../../lean/Protocol/Transfer/PathSignature/NativeCircuitBounds.lean) | Generated `2mn+n+m+1` core, honest assignments and actual integer-lift range check. An explicit residual/modulus bound gives integer observations. Compiling range/byte/hash checks into field constraints remains open. |
| Canonical byte-owner packets | [TransferCodec](../../lean/Protocol/Evidence/TransferCodec.lean) | Exact existing metadata/intent/packet bytes and full vote targets; malformed semantic fields remain representable. This is a versioned Lean reference profile. |
| Primitive failures and one-shot integrity | [PrimitiveChecks](../../lean/TCB/PrimitiveChecks.lean), [Primitives](../../lean/Protocol/Transfer/Primitives.lean), [Security](../../lean/Protocol/Transfer/Security.lean) | Actual verifier/history interfaces and conditional shared-PMF failure composition; this fixed-history theorem is separate from the bounded adaptive CRS reduction above. Primitive error estimates remain supplied. |
| Public certificate bytes and calibration | [Codec](../../lean/Protocol/Transfer/Certificates/Codec.lean), [Calibration](../../lean/Protocol/Transfer/Certificates/Calibration.lean), [Evidence](../../lean/Protocol/Transfer/Certificates/Evidence.lean), [Bundle](../../lean/Protocol/Transfer/Certificates/Bundle.lean) | Canonical public subjects, actual proof-byte leaves, immutable seven-slot root and predecessor checks; exact rational realization identifies the selected real calibration. The generic packet codec has a concrete byte-owner specialization. |
| Certificate reflection and consumption | [generic contract](../../lean/Protocol/Transfer/Certificates.lean), [Statement](../../lean/Protocol/Transfer/Certificates/Statement.lean), [Native](../../lean/Protocol/Transfer/Certificates/Native.lean), [Projection](../../lean/Protocol/Transfer/Certificates/Projection.lean) | Encoding reflection and operational algorithm agreement are constructed for the actual native/projection relations. Checking yields certification or actual backend/terminal-leaf false acceptance; circuit refinement, cryptographic soundness and knowledge remain open. |
| Proof/TCB envelopes | [ProofCarrying](../../lean/TCB/ProofCarrying.lean), [SNARK](../../lean/TCB/SNARK.lean), [CompressionBoundary](../../lean/TCB/CompressionBoundary.lean), [WitnessVerifier](../../lean/TCB/WitnessVerifier.lean), [Runtime](../../lean/TCB/Runtime.lean) | Named proof/compression/runtime contracts. Legacy well-formedness includes statement truth and cannot establish independent concrete verifier soundness. |
| Retrieval | [Retrieval](../../lean/Protocol/Storage/Retrieval.lean) | Original Hodge query/answer correctness, digest-check/collision recovery and whole-bucket selector privacy; efficient PIR and general native-query privacy remain open. |
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
| Concrete cryptography and execution | [ZKP](../../lean/Axioms/ZKP.lean), [Runtime](../../lean/TCB/Runtime.lean) | Secure primitive implementation, full hash/range/byte circuit refinement, setup generation, authenticated directories/state origin, secure channels, primitive budgets, corruption/privacy games and executable refinement remain obligations. |

Paper 1 supplies the cellular/Hodge, semantic HCP, harmonic-lattice and CVP
prerequisites. Paper 3 supplies projective reconstruction, source-calibration
obstructions, coding and metric/radius theorems. Their imported conclusions
retain the actual source, layout, observation and comparison hypotheses;
Paper 2 owns the construction, authentication and protocol consumption of
those objects. Shared definitions do not create a second contribution.

A richer logical profile may use graded products in cohomology. Kryazhev's
[multiplicative Serre spectral sequence in HoTT](https://arxiv.org/html/2611.11828v1)
is a prospective source for that direction. The present cellular core already
has addition, scalar actions, differentials, adjoints, the Laplacian and
harmonic projection. It has no chosen graded cup product. Such an enrichment
needs explicit multiplicative data, product-compatible transport and a
comparison with the source's type-family model. The public semantic signature
and the private Hodge operators must remain explicit: the coupled cochain
shear preserves the differential but generally does not intertwine adjoints
or Laplacians. This is future logical structure, not a prerequisite for the
native transport/codec construction.


### 8. Conclusion

The construction gives an explicit harmonic-lattice encryption mechanism,
from private cellular presentation and integer message through canonical
ciphertext bytes to exact coefficient recovery. The graph lattice is the
entire intrinsic integral harmonic lattice, with a proved coefficient basis,
rank, discreteness and metric. The rational algorithm implements the original
harmonic-lattice decoder on every rational input; its byte form accepts
exactly the integer Hodge-encryption language for the returned message.

HCP isolates the associated recovery question when the operative geometry is
hidden behind a public semantic class. Supplying that geometry makes the
native generated message the unique known-lattice CVP answer; the proved
public-information obstruction identifies what a class label and observation
can fail to determine. Establishing a stronger computational comparison,
and security for a selected sampler and complete public view, is the central
hardness task opened by this concrete mechanism.
