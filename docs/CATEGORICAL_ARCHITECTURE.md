# Categorical Architecture

This document is the single active diagram-and-relationship view of the
categorical architecture. Canonical names and proof status live in the
[verified categorical register](SEMANTIC_OWNERSHIP.md#verified-categorical-register);
cross-language refinement status lives in
[`SEMANTIC_PARITY_QUEUE.md`](SEMANTIC_PARITY_QUEUE.md). A diagram here never
upgrades an interface or analogy into a theorem.

The former CatColab-specific map has been archived. Its useful
object/morphism/diagram organization is retained here without making CatColab
part of the trusted computing base.

## Paper 1 cellular-sheaf core

The intended categorical reading uses the face poset of a finite oriented cell
complex through degree two and face-to-coface maps:

```text
vertex stalk --restrict01--> edge stalk --restrict12--> face stalk
```

Lean currently stores this finite truncation directly in `OrientedTwoComplex`
and `CellularSheaf`; it does not package the face poset and sheaf as a
`CategoryTheory.Functor`. The supplied incident-flag composition law and
boundary-square equation induce the proved cochain complex

```text
C^0(X; F) --delta0--> C^1(X; F) --delta1--> C^2(X; F)
                                      delta1 o delta0 = 0.
```

The operative Paper 1 Hodge operator is

```text
Delta_1 = delta0 o delta0* + delta1* o delta1 : C^1 -> C^1.
```

Its harmonic subspace is `H_F = ker(Delta_1)`. The kernel-normalized operator
`I - P_HF` has the same kernel, but is not generally the Hodge operator and
need not have the same positive spectrum.

A degree-zero global section is a compatible stalk assignment:

```text
IsGlobalSection(F, a)  iff  delta0(a) = 0.
```

An accepted cochain commitment instead carries an exact degree-one value
`c = delta0(a)`. It is a cocycle, but it is not a global section. The value `c`
determines an opening `a` only modulo `ker(delta0)`.

## Hodge coordinates and isometric transport

For a hidden presentation `x`, write

```text
H_x = ker(Delta_x)
HodgeCoord(x) = H_x x H_x^perp
Cochain1(x) = C_x^1.
```

The pointwise Hodge equivalence and its inverse are

```text
combine_x : HodgeCoord(x) -> Cochain1(x),   (h,e) |-> h + e
split_x   : Cochain1(x) -> HodgeCoord(x).
```

Decryption is the first coordinate of `split_x`, equivalently
`P_{H_x}`. This full coordinate map is bijective because the noise coordinate
is part of the source.

Categorically, these maps have different intended strengths:

```text
combine : HodgeCoord => Cochain1       natural isomorphism
decrypt : Cochain1  => Harmonic        natural split projection
include : Harmonic  => Cochain1        natural inclusion
P_H = include o decrypt                natural idempotent endomorphism
```

The projection is not an isomorphism unless `H_x = C_x^1`. Calling
`combine` a natural isomorphism and `P_H` a natural transformation is
therefore consistent, not a choice between two descriptions.

A degreewise isometric cochain equivalence that commutes with `delta0` and
`delta1` also commutes with their adjoints and the true degree-one Laplacian.
It therefore maps the harmonic subspace onto the target harmonic subspace. The
intended natural-isomorphism square is

```text
HodgeCoord(x) --combine_x--> Cochain1(x)
      |                            |
      | coordinate transport       | T^1
      v                            v
HodgeCoord(y) --combine_y--> Cochain1(y).
```

Lean proves the objectwise `combine`/`split` equivalence in
`HCP.hodgeDecompositionEquiv`. `Sheaf/Equivalence.lean` proves concrete
adjoint, Laplacian, and harmonic-subspace transport.
`HCP.IsometricPresentationEquivalence` proves the corresponding matrix-level
harmonic-subspace transport and the component equation for the operative
projection's intended natural transformation:

```text
C_x^1 --P_{H_x}--> C_x^1
  | T^1               | T^1
  v                   v
C_y^1 --P_{H_y}--> C_y^1.
```

The presentation category, the two functors, and a bundled `NatIso` remain
proposed packaging. A bundled natural transformation for `P_H` also awaits
those functors, although its projection-square equation and idempotence are
already proved. None of this packaging is needed as an extra correctness
assumption for the pointwise and transport statements.

This presentation-level square is distinct from stalkwise sheaf naturality.
A linear morphism of cellular sheaves has components on stalks satisfying

```text
eta_y o F(f) = G(f) o eta_x
```

for every incidence arrow `f : x -> y`. Such a morphism induces degreewise
cochain maps commuting with the coboundaries and therefore induces maps on
cohomology. It does not generally fix every cohomology class pointwise.
Conversely, the Hodge projector is a global cochain operator and need not
decompose into stalk components. Its naturality here is with respect to
isometric presentation transport.

`Sheaf/Morphism.lean` now bundles this same-base stalkwise morphism, its
identity and composition, and the induced `C0`/`C1`/`C2` maps; Lean proves the
two coboundary-naturality equations. Pullback and pushforward along a map of
cell complexes, and any corresponding adjunction, remain outside this result.

Crucially, this square transports the cochain together with its presentation:
`b` becomes `T^1 b`. HCP ambiguity instead holds the same raw public observation
fixed while varying a hidden representative in one public fiber. Naturality
therefore does not remove the separate fixed-coordinate non-stabilization
obligation.

## The central harmonic projector and the different residuals

The harmonic projection `P_H`, with `H = ker Delta1`, connects the geometry,
encryption and recovery problem. It is an idempotent retraction onto the
harmonic subspace. The full Hodge-coordinate splitting retains both the
harmonic and orthogonal coordinates; its invertibility does not make the
single-coordinate projection invertible.

| Operator or quantity | Actual role | Source owner |
|---|---|---|
| `Delta1 = delta0 delta0* + delta1* delta1` | True degree-one Hodge operator, with its actual positive spectrum. | `Sheaf/Hodge.lean` |
| `P_H` | Harmonic recovery of an encrypted sample; the operative HCP target for the chosen hidden presentation; transported naturally under the stated isometries. | `Sheaf/HarmonicLattice.lean`, `HCP.lean`, `Sheaf/Equivalence.lean` |
| `I - P_H` | Kernel-normalized residual operator. Its norm measures the full sample's orthogonal noise; it shares the Hodge kernel but not generally its spectrum or scale. | `Sheaf/Hodge.lean`, `Sheaf/ObservationQuotient.lean` |
| Distance to `im delta0` | Exact-payload acceptance residual, using the exact-subspace projection. Its zero locus is accepted decoded cochains. | `Sheaf/Distance.lean`, `Protocol/Storage/Context.lean` |
| Pair Hamming distance | Distance of the actual extracted/reduced pair to the target code. | `Proximity/Core/Distance.lean`, `Protocol/Storage/Calibration.lean` |

For the existing HCP observation adapter these identities concern different
objects:

```text
b = h + delta0 a + delta1* u
P_H b = h
(I - P_H) b = delta0 a + delta1* u
decode(committed payload) = delta0 a
```

Consequently, the accepted exact-component payload has zero distance to
`im delta0`, while the full sample can have nonzero harmonic message and
nonzero HCP residual. Their common snapshot and supplied observation binding
do not identify those distances. A public profile must state what it reveals
or certifies about the full sample and its harmonic projection.

The Grassmannian/Plucker description below locates the harmonic subspace.
A future presentation-groupoid description could organize the projector's
equivariance, after constructing the required objects/maps. Neither
description alone supplies the metric comparison to the extracted code.

## Accounted objects: ephemeral representatives, rotation and anonymity

The [HCP object crosswalk](COCHAIN_PROXIMITY_TRACE.md#hcp-object-accounting-rotation-and-anonymity)
records HC01--HC44: semantic carriers/classes, actual cellular and integral
geometry, message/noise/sample objects, the selected public view, gates,
projection states, artifacts, retained manifests and lifecycle/privacy claims.
It is development documentation, not a new submission statement or a completed
concrete family.

The recovered flow is: a private base presentation, an admissible ephemeral
representative connected by a hidden path/transport, Hodge-structured encryption,
and a selected public artifact with verification evidence. The existing
`EphemeralFiberSpec` proves same-class membership under a supplied path-respect
condition. A finite actual realization is now constructed in [HCP.AxisFamily](../lean/HCP/AxisFamily.lean):
two integral sheaves enter the genuine cochain model with proved homological-test
invariance and yield different targets at a common observation. Indexed
generation, a complete transported-private-state lifecycle, full Helfer
first-order semantics and an anonymity experiment remain separate work.

Two squares must be kept separate. Rotation co-transports a ciphertext and
its harmonic/noise coordinates, `b' = T1 b` and `h' = T1 h`; a common plaintext
requires an encoding/lattice transport law. Fixed-observation HCP ambiguity
instead compares the same raw `b` under distinct hidden projections. Distinct
harmonic vectors need not mean distinct plaintexts across presentations.
Equality of the small `(class,b)` input also establishes no equality of the
larger payload/snapshot/root/proof view. The crosswalk records the corresponding
joins and a face-free candidate whose changing exact component exposes that
difference.

## Public classifier, fiber, and operative target

An HCP realization contains a commuting classifier triangle:

```text
Rep --------laplacian--------> MatrixEnd(C^1)
 |                                  |
 | classifier                       | publicProjection
 v                                  v
 P ---------------id--------------> P.
```

The public solver input is the observation `(p,b)`. A hidden witness is a
representative `x` in the ordinary inverse-image fiber
`{x | classifier(x) = p}`, and its unique target is

```text
operativeTarget(x; p,b) = P_{ker(Delta_x)}(b).
```

No quotient universal property is assumed. Distinct same-fiber
representatives can produce distinct operative targets; this is the
hidden-operator obstruction used in `Hardness.lean`.

The [actual-operator adapter](../lean/TCB/HCPRealization.lean) now derives
matrix-kernel, fixed-metric projector and message equality for an existing
bound observation from its operator action and snapshot-classifier alignment.
Its discrete CVP result uses that same sample and an explicitly presented
message point. The [concrete family adapter](../lean/TCB/HCPAxisFamily.lean)
instantiates operator alignment, proves the actual computed spectral gap
passes the gate, and retains supplied artifact/decoder/binding contracts.
No digest or extra public-view equality is manufactured.

The family has a simple shared `b=(1,1)` with different ambient harmonic
vectors; both represent coefficient one in their respective bases. Its
weighted `b=(1,2)` variant instead uses the actual integer encoder with
coefficients two and one and proves exact coefficient-recovery failure from
the common input. This separates the declared encoded integers, while still
making no distributional security or sender-anonymity claim.

## Grassmannian, Plucker coordinates and a possible moduli layer

At fixed ambient dimension and harmonic rank, `ker Delta1` is a Grassmannian
point. The classical Plucker embedding realizes that Grassmannian as a
projective variety; the actual full projective coordinate determines the
subspace ([Grassmann-code comparison, Section 7](https://arxiv.org/html/0911.1298)).
With a fixed Euclidean inner product, that subspace determines its orthogonal
projector. It does not determine the true Hodge operator's positive spectrum.
Thus publishing the full coordinate can reveal the operative harmonic
projection even when other presentation data remains hidden.

The current concrete Lean
[`ProjectiveShadow`](../lean/Proximity/Concrete/GrassmannianPlucker/Concrete.lean)
is a quotient of exterior coordinates by nonzero real rescaling. Its raw
carrier also contains the zero orbit. The intended Grassmannian locus uses
nonzero decomposable coordinates and the frame/soundness conditions; the
quotient type alone is not a bundled projective variety. The new
[Reconstruction module](../lean/Proximity/Concrete/GrassmannianPlucker/Reconstruction.lean)
constructs both concrete soundness inputs, recovers the actual subspace and
projector, and proves full-shadow equality exactly when genuine ranked points
agree. [PluckerObservation](../lean/TCB/PluckerObservation.lean) identifies
recovery with the operative HCP target when that subspace is the operative
kernel. This is mathematical exact-real recovery, not a digest inversion or
efficient finite-encoding algorithm.

| Layer | Object and retained information | Metric/structure boundary |
|---|---|---|
| Presentation | Cellular sheaf, coordinate/basis conventions, inner products, optional integral structure and cochain. | An arbitrary change of basis requires transport of these structures; the current Hodge transport theorem assumes degreewise isometry. |
| Grassmannian/Plucker | Harmonic subspace and its full projective exterior coordinate. | Projective rescaling forgets the frame's scalar, not the subspace. It does not supply a geometric-to-Hamming distance comparison. |
| Public observation and authentication | Selected shadow, cochain artifact, digest, proof and manifest. `HashedPluckerShadow` retains both the mathematical shadow and digest as semantic fields. | Paper 1 §5 fixes private Hodge data, a public residue payload and selective opening/proof roles; a concrete encoding/profile still selects the released fields. A digest is not automatically a recoverable projective coordinate or a distance-preserving map. |

A moduli-groupoid or stack organization is a possible later layer: retain
presentations together with their actual equivalences and automorphisms.
This is a design interpretation, not a construction already present in Lean.
It requires choosing the base/site, allowed morphisms, transport and descent;
an algebraic-stack claim needs the relevant geometric hypotheses, as in the
[Stacks Project's smooth-groupoid quotient theorem](https://stacks.math.columbia.edu/tag/04TK).
General linear changes with transported metrics and isometries of a fixed
metric have different roles. Lattice preservation adds another condition.
Neither a public classifier fiber nor an ordinary set quotient by itself
supplies this stack structure.

Fernandez Herrero--Inchiostro, [*Relative cohomology and base-change*](https://arxiv.org/abs/2611.05209),
is a candidate reference for a future family/descent layer. Its derived
pushforward/base-change results have explicit algebraic-geometric hypotheses.
A realization of our finite cellular families in that setting remains to be
supplied, together with metric and integral transport; it is not an imported
Hodge-projection or retrieval-privacy theorem.

Odabaşi's [enriched-functor homotopy framework](https://arxiv.org/abs/2610.40746)
is another candidate comparison, via Frobenius exact structures. Relating it
to our existing typed Helfer cochain model requires an explicit categorical
and homotopy-relation adapter. [Knowledge Sheaves](https://arxiv.org/abs/2110.03789v2)
provides a graph/schema example of approximate global-section semantics;
that degree-zero interpretation remains distinct from HCP degree-one samples.
The [source ledger](SOURCE_LEDGER.md) owns
source-review status; neither reference is a new protocol assumption.

## Prospective block-sum structure

External orthogonal direct sum, equivalently block sum in matrix coordinates,
is the natural candidate for a later symmetric-monoidal refinement:

```text
Cochain1(x boxplus y) ~= Cochain1(x) direct-sum Cochain1(y)
Delta_(x boxplus y) = Delta_x direct-sum Delta_y.
```

This is distinct from the internal Hodge splitting
`C_x^1 = H_x direct-sum H_x^perp`. It remains prospective until Lean supplies
a cross-dimension presentation type, block-sum construction, kernel and
projection identities, and coherence laws. No tensor-product or Kunneth claim
is being made.

The representation-functor analogy in
[Faitg--Gainutdinov--Schweigert--Willprecht, Section 2.2.2](https://arxiv.org/abs/2604.00837)
is useful only at this packaging level: coherent pointwise data may be
collected into natural or monoidal structure. Their result concerns mixed
associators for module categories; it does not supply this Hodge decomposition,
projection naturality, or HCP hardness theorem.

## History, snapshots and the cellular base

The working organization separates the public directed block/event history
from the application cellular complex. A history entry authenticates references
to a snapshot-bound context and its retained artifact manifest. That context
fixes the application complex `X`, sheaf `F`, payload interpretation and
original cochain artifact for the projection run:

```text
public block/event history
  -> authenticated snapshot/context reference -> application geometry (X, F)
  -> authenticated sealed artifact-manifest reference

temporary StateBus, using that fixed context
  -> typed projection outputs and certificates -> retained manifest
```

This is the agreed working separation of roles. The new
[history anchor](../lean/Protocol/Storage/Anchor.lean) and
[projection anchor](../lean/Protocol/Storage/ProjectionAnchor.lean) implement
the semantic join under explicit authentication profiles; they do not define a
generic history graph or a concrete hash/encoding scheme. The expanded 4.35
aggregate and selected theorem audits pass; see
[the validation record](MATH_STORAGE_VALIDATION.md) for their exact scope. Access to the underlying geometry still needs an
availability and visibility profile. The public history may expose bounded
names while the geometry or private witnesses remain encrypted.

The application cells may follow the recovered account/validator proposals;
their precise meaning and any relationship to physical peers remain open.
Block heights were also proposed as vertices of a history complex. Identifying
that history complex with the operative HCP base would require an additional
construction. The three information layers `F_full -> F_zk -> F_hash` and the
cellular degrees `C0/C1/C2` have separate meanings.

`TransitionAnchor` joins an existing evidence-bearing candidate to the actual
storage interpretation, original public artifact and exact sealed manifest.
Its inputs identify the policy's snapshot model with `SnapshotModel.ofSheaf F`,
the candidate snapshot with the context's interpretation, and the proof's
public artifact with the context's artifact. Candidate validity then derives
the same payload, accepted exactness, snapshot-root equality and existing root
inclusions. `HistoryBindings.manifestIncluded` explicitly authenticates the
actual candidate, context, ordered leaves and manifest root under that
candidate's block digest. A matching quorum signs that same block digest and
snapshot coordinate; the supplied inclusion relation authenticates the manifest
through that digest. This supplies no round/lock/finality theorem.

`ProjectionAnchor` specializes this join to an existing `SealedProjection`.
Its exact-prefix theorems use `itemsMatch`, not generic slot completeness. An
additional relation includes the actual gate database under the candidate's
evidence root without equating that root with the manifest or database root.
The stored payload and RS word remain the original projection outputs. The
existing far theorem still requires its source-farness premise and does not
select a metric or instantiate the remaining codec/lift profile.

`ProposalRef` has no distinct storage-manifest-root field. Concrete inclusion
under an authenticated body or a new coordinate, canonical bytes, digest
verification and retrieval remain open. The adapter fixes `X` and `F`; the
current conservative ledger transition preserves snapshot, topology and epoch.
Geometry updates and rotation need separately specified transitions.

## State and content addressing

The mathematical input is one [storage context](../lean/Protocol/Storage/Context.lean):
the original cochain artifact, its payload interpretation, immutable sheaf
snapshot, parameter-set identifier and run identifier. Its key derives the
schema, snapshot root, artifact leaf digest and topology tag from those
objects. The context retains shape and snapshot binding; exact-payload
acceptance is a separate predicate. Raw nonexact observations therefore
remain available for proximity analysis.

The recovered useful role of `SheafState` is a **volatile projection state
bus**. The current checkpoint core uses a typed payload/certificate prefix
for one fixed context; the runtime bus's lifecycle granularity remains a
design choice. In particular, the one-bus-per-commit proposal is not imposed
by the immutable Lean `StateBus` record. The Python class also accumulated
accounts, economics, mempool and audit-log duties; those are legacy node/ledger
responsibilities, separate from the typed checkpoint lifecycle.

`SheafStateSnapshot` is the immutable input context fixed before the projection
chain starts. It carries the cochain's sheaf context plus explicit
canonical-encoding and root-binding obligations. A concrete refinement of
those obligations is still pending. Its content root must bind at least:

- schema and coefficient-domain identifiers;
- canonical cell identities and ordering;
- signed incidences;
- stalk dimensions and restriction-map commitments;
- the operator degree/family and public parameter set.

The [checkpoint engine](../lean/Protocol/Storage/Checkpoint.lean) initializes
an empty manifest for that fixed context. Entries retain their actual typed
payload and digest, with an object-indexed binding relation. Each append
requires an unused slot. Exact acceptance can already be available from the
HCP stack, or supplied as a separately checked result; it is not a condition
restricting the general observation carrier to valid inputs.

For a selected projection run, the
[concrete adapter](../lean/Protocol/Storage/Projection.lean) advances through
the existing mathematical states and evidence records. Each step retains its
exact predecessor and appends one leaf:

```text
snapshot-bound original C1 artifact
  -> fixed Context + collecting manifest
  -> write Plucker/cochain binding
  -> write projected plane
  -> write the chain's RS received word/target
  -> write hard-gate evidence
  -> write assembled-projection naturality
  -> write far-region witness
  -> seal the exact complete manifest
  -> obtain persistence receipt for that context/list/root
  -> consume the volatile run
```

This protocol layer follows the nested Paper 1 proof objects
`PluckerCochainState -> CochainPlaneState -> StateBus` and then
`HardGateEvidenceRecord -> NaturalityGateEvidenceRecord ->
CalibratedFinalEvidenceRecord`. It stores those outputs; it does not recompute
their mathematical checks. The adapter's final seal requires the exact leaf
list from one final typed prefix, not just presence of six labels. The generic
engine alone proves slot uniqueness and local lifecycle properties; the
projection adapter supplies the predecessor/certificate joins.

`Sheaf/CochainSemantics.lean` connects the concrete snapshot interpretation
to the legacy coherence interface through actual carrier equivalences,
coboundary and decoder equations, and snapshot-binding equivalence. It
derives acceptance/cocycle transport. It does not identify geometric norms
with coding distances or supply the remaining ambient topology gates.

An accepted exact payload has zero distance to `im delta0`. The full HCP
sample `b = h + delta0 a + delta1* c` is a distinct object, retained by the
existing bound-observation stack. Its kernel-normalized harmonic residual
contains both exact and coexact noise. `Storage/HCP.lean` reuses that stack's
exact artifact and snapshot, and derives the run name from its actual
lifecycle context through a supplied identification function.

`Storage/Calibration.lean` derives an independent decoded-source comparison
from controlled exact codeword lifts. `Storage/CanonicalRS.lean` joins this
criterion and the existing public pullback calibration to the same observed
artifact/pair. Neither context binding nor checkpoint completion constructs
those lifts, proves fixed-challenge goodness, or evaluates a security budget.

An open `SheafBlock` is a persistent checkpoint target, but is not yet a
complete or anchorable block. Its sealed form is immutable. The Paper 2 content
address for the sealed block should be

```text
SHA256("HCRYPT:SHEAF-BLOCK:v1" || canonical_manifest_bytes)
```

where the canonical manifest authenticates the snapshot/cochain coordinates,
stage-artifact subtree, certificate/evidence subtree, schema, and parameter
set. Child artifacts retain distinct domain-separated digests. During
construction, the open block may have successive revision roots; only the
sealed final SHA-256 root is eligible for the main-chain anchor. The Lean
lifecycle permits consumption only with a persistence receipt indexed by the
exact sealed object. Backend atomicity, crash recovery and memory erasure
remain refinement obligations. Run identifiers are supplied: no global
freshness or anti-cloning theorem is inferred from an empty local manifest.

A topology hash may be useful metadata, but it is not by itself a full
snapshot commitment. Storage realizes canonical bytes, content lookup,
checkpoint writes, persistence, atomic updates, and hash revalidation on load.
A database is not itself a cellular sheaf, and hash equality is not a
naturality square.

## Paper 2 and protocol separation

The source dependencies and remaining runtime boundaries are

```text
Paper 1 cellular/Hodge mathematics
        -> snapshot/artifact Context + typed projection prefix
        -> exact sealed manifest

candidate-bound accepted evidence + same interpretation/artifact
        + explicit inclusion of that manifest under the candidate digest
        -> TransitionAnchor
        -> same-proposal authenticated quorum attachment

exact sealed manifest + matching persistence receipt
        -> local consumed checkpoint

canonical bytes, backend writes, runtime bus retirement,
geometry migration, locking, finality and liveness remain separate obligations.
```

A future task sheaf may live over a finite execution slice of local process
views. Its global sections would be compatible decision assignments, not
quorum certificates or finality proofs by themselves.

Likewise, `OracleEta1`, `OracleEta2`, and `OraclePipeline` currently name
proposition-bearing protocol interfaces. Historical `F_full -> F_zk -> F_hash`
pictures may motivate a future categorical model, but Lean has not defined
those three labels as sheaf functors or the eta structures as natural
transformations. `LedgerState.applyTransaction` and `applyBlock` are state
update functions, not a colimit construction.

The three operator names remain separate:

- `degreeOneLaplacian` for Paper 1's hidden Hodge operator on `C^1`;
- `kernelNormalizedDegreeOneLaplacian` for `I - P_ker`;
- `networkLaplacian0` for a possible degree-zero protocol-connectivity
  operator.

No spectral quantity is called stake, consensus, or finality without a
separate protocol definition and theorem.
