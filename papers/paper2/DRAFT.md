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

The first protocol endpoint is one conservative, snapshot-bound transition
with candidate-indexed evidence and an attached matching acceptance quorum.
Consensus finality, cryptographic security games, backend durability and key
rotation are additional obligations. The existing proofs state their
authentication and implementation contracts explicitly.

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

This settles the level of each object. The concrete byte encoding, recipient
and verifier access, permitted proof outputs, and full-Plucker versus
digest-only profile still need their selected contracts. A semantic
`BoundHCPObservation` retains a message and openings for proofs and must not be
serialized wholesale into public history.

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
storage view requires a separate comparison of the released fields.

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
classifier; indexed generation, transported state,
rotation migration and an anonymity game remain separate obligations.

Rotation correctness must name the semantic plaintext and its cross-presentation
encoding: transporting harmonic coordinates can preserve the same plaintext.
Fixed-observation HCP ambiguity instead compares one raw observed cochain
under different hidden presentations. To claim ambiguity of the actual public
stack, the released payloads, roots, proof outputs and handles must be included
in its view; equality of the classifier/cochain pair alone is insufficient.
Representative privacy, plaintext hiding, sender anonymity, unlinkability and
forward secrecy are distinct experiments. This draft selects none of them
implicitly from a large classifier fiber or the name of a gate.

Paper 2 must also specify how an authorized recipient holds or derives the
ephemeral presentation or transport needed for recovery, and which delivery
hints an outsider sees. That key-delivery profile must use the same semantic
plaintext, public view and lifecycle as the stored artifacts. A Hodge noise
opening or a supplied class-membership path is not a key-exchange,
encapsulation or recipient-recovery construction.

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
| [Existing transition kernel](../../lean/Protocol/Ledger/Transition.lean), [candidate evidence](../../lean/Protocol/Evidence/Transition.lean) and [history anchor](../../lean/Protocol/Storage/Anchor.lean) | Baseline checked conservation, replay exclusion and same-object/context joins under explicit authentication, policy and backend relations. These do not instantiate a production protocol. |
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
| Paper 2 security and runtime realization | Preserve the three inherited visibility levels while selecting concrete bytes, access and proof outputs; specify authorized recipient key delivery, persistence, dynamic geometry/key rotation and retirement. Cryptographic games, actual hashing, backend realization, consensus finality and runtime refinement remain construction or implementation obligations. |

“Standard-only” means that the actual axiom report uses no dependencies beyond
`propext`, `Classical.choice` and `Quot.sound`; some elementary identities use
a subset. The concrete canonical reports additionally expose the existing
generated `_native.native_decide.ax_` certificates. These checks cover the
listed endpoints, not every declaration or a security theorem.

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
