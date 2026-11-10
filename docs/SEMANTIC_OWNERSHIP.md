# Semantic Ownership

The [manuscript parity register](../SEMANTIC-PARITY.md) is the current
three-paper object/result ownership index. Paper 1 contains exactly three
numbered themes: **1 Primitives, 2 The Harmonic Cochain Problem, 3 CVP Comparison
and Kernel Ambiguity**; Introduction and Conclusion are unnumbered. Its
independent entry selects **six groups, 36 declarations (16 main/20 support)**,
with **18 intentional Challenge placeholders** and a **21-module Solution
closure**. [Entry metadata](../lean/Palomar/PaperOne/formalization.yaml)
records verification for its exact input scope.

Paper 2 owns payloads, the opening quotient, commitments, source/codec data,
released-view binding, rotation, storage/evidence and the bounded conditional
transition. Paper 3 owns coding, full-point reconstruction (§7.1), source
metrics/calibration and the transferred exact-component residual obstruction
(§7.3). Full-point and residual-obstruction results are auxiliary to Paper 3's
52/22 coding/application selections; they are outside Paper 1's 36 targets.

The [complete family index](../SEMANTIC-PARITY.md#complete-family-coverage)
accounts for construction, conditional, supporting and deferred objects,
including generic ledger and quorum objects, TCB/proof contracts, PoV/policy,
legacy chain, coregulator and future stack/network classes. Ownership is per
object or result, not per filename. Paper 2 defines actual payload/layout/view
and evidence data; Paper 3 proves the quantitative statements about those
same objects. A named contract or certificate is not a constructed secure
primitive or a completed protocol.

## Canonical Object Vocabulary

This table separates current Lean identifiers from planned cross-layer
vocabulary. Historical documents under `archive/documentation/` may retain older language.

When an older Python or Rust object overlaps a current Lean object, the Lean
type and theorem statement take precedence. Runtime code may refine that
interface or expose a missing obligation, but it does not silently redefine the
mathematical object.

| Canonical term | Status | Meaning | Must not be conflated with |
|---|---|---|---|
| Public history graph | Working Paper 2 architecture role; no generic Lean graph type yet. | Directed block/event history whose entries authenticate snapshot/context and retained artifact-manifest references. `TransitionAnchor`/`ProjectionAnchor` supply the bounded semantic join under explicit profiles. A block-history cellular complex would be separate. | The application HCP base complex, physical peer graph, a concrete wire/hash implementation or global finality. |
| `CellularSheaf` | Current Lean identifier. | Paper 1 finite (0/1/2)-cell sheaf with real-linear stalks and face-to-coface maps. | The mutable chain state, a protocol execution graph, or a Helfer/Grothendieck fibration merely because all use fiber language. |
| `CellularSheaf.Morphism` | Current Lean identifier. | A same-base stalkwise linear natural transformation commuting with the incident cellular restrictions; it induces maps on `C0`, `C1`, and `C2` that commute with both coboundaries. | A pullback/pushforward along a topology map, hidden-path transport, or an adjunction. |
| `SheafState` | Planned Paper 2 protocol term recovering the original state-bus intent; the archived Python class is legacy, not canonical. | Volatile bus advancing a fixed snapshot/artifact context through typed projection/certificate stages. Exact acceptance is a separate predicate; runtime lifecycle granularity remains open. The checkpoint core requires a receipt for the exact sealed manifest before local consumption; runtime erasure remains separate. | The persistent checkpoint store, the whole mutable node/ledger/economics state, a global section, or a finalized content-addressed block. |
| `SheafStateSnapshot` | Current Lean interface object; concrete encoding/hash refinement is pending. | Immutable sheaf-indexed input name carrying a 32-byte root, topology tag, and explicit canonical-encoding/root-binding obligations. `Storage.Context` retains the bound original artifact; acceptance is checked separately. | The mutable projection bus, a serialized/reconstructible sheaf, a proved canonical byte encoding, or the ledger before/after root. |
| `SheafBlock` | Planned Paper 2 protocol term; `Protocol.Storage` supplies manifest/checkpoint and conditional anchor endpoints without defining this named type. | Persistent checkpoint record for a fixed context. The proposed public form authenticates artifact and evidence subtrees under one canonical SHA-256 manifest address. The semantic candidate/context/seal join now has source definitions; canonical bytes, backend guarantees and concrete chain inclusion remain open. | `Chain.Block`, a cellular global section, the evidence subtree root alone, or the volatile `SheafState`. |
| `CellularSheaf.IsGlobalSection` | Current Lean identifier; overloaded `Proximity.GlobalSection` names remain a migration item. | A degree-zero stalk assignment in `ker delta0`. Ordinary endpoint-by-endpoint compatibility additionally uses the intended graph/incidence profile. | An arbitrary vertex assignment, account table, block, or accepted degree-one cochain. |
| `AcceptedCommittedOneCochain` | Current Lean identifier. | Paper 2's payload `c` bound to one `SheafStateSnapshot`, with opening `a` and decoded exactness `I.decode c = F.delta0 a`. Raw openings are identified modulo `ker delta0`; modular carries are a separate relation. | The decoded geometric cochain itself, a degree-zero global section, or a uniquely determined opening `a`. |
| `HasPathSpace.Path x y` | Current Lean interface with an opt-in continuous-path adapter; no concrete credential-path generation algorithm. | A typed path witness from representative `x` to representative `y`, intended to remain private at the protocol boundary. | A sampled matrix interpolation, equal public classifier values, or equality of a finite invariant tuple. |
| `PathEquivalent x y` | Current Lean identifier. | Mere inhabitation of `HasPathSpace.Path x y`. | A concrete topological path model or a proved equivalence criterion for runtime objects. |
| `PublicClassifier` / `PublicFiber` | Current Lean identifiers. | The public classifier map and its inverse-image fiber. The typed HCP interface optionally adds `ReflectsHomotopyEquivalence`; with closed-test invariance, its fibers are exactly the declared semantic classes. The admitted two-member family proves this profile. | An automatic converse for arbitrary path spaces, an injective representative identifier, or a determined fixed-coordinate harmonic kernel. |
| `Proximity.Gates.Projection.StateBus` | Current Lean proof object; runtime reset/finalization is pending. | One witness-local nested chain of already-checked cochain, plane, and RS payloads/metric handoffs, consumed by the planned protocol `SheafState`. | The persistent checkpoint store, the finalized `SheafBlock`, or an already implemented lifecycle state machine. |
| `TaskSheaf` | Planned Paper 2 term; no Lean definition yet. | A cellular sheaf over a finite execution slice, with stalks of admissible protocol decisions/evidence. | The Paper 1 HCP sheaf, a quorum certificate, or finality by itself. |
| `degreeOneLaplacian` / (Delta_1) | Current Lean identifier. | The true Hodge operator (delta_0delta_0^ast+delta_1^astdelta_1) on (C^1). | The normalized residual projector or network graph Laplacian. |
| `harmonicOneProjection` / `P_H` | Current Lean definition in `Sheaf/Hodge.lean`; `H = ker Delta_1`. | Orthogonal projection of a degree-one cochain onto the harmonic subspace. It recovers the harmonic message from the constructed Hodge sample. | Applying `Delta_1`, taking `I-P_H`, or measuring distance to the exact-cochain subspace. |
| `kernelNormalizedDegreeOneLaplacian` | Current Lean identifier. | (I-P_{\ker\Delta_1}), sharing (Delta_1)'s kernel but generally not its scale or spectrum. | The true Hodge (Delta_1) without a flat-positive-spectrum hypothesis. |
| `exactDistance` / decoded exactness residual | Current Lean definition in `Sheaf/Distance.lean`; `Context.decodedDistance` applies it after the actual decoder. | Paper 3's Euclidean source score to `im delta0`; Paper 2 supplies the original decoder/context. Its zero locus is decoded exactness, namely `Context.Accepted` in that bound context. | The harmonic component, the full-sample score `norm((I-P_H)b)`, or pair Hamming distance. |
| `networkLaplacian0` | Planned protocol term; no Lean definition yet. | Optional degree-zero graph/connectivity operator used by protocol policy. | Paper 1's hidden degree-one Hodge operator. |
| `GrassmannianPlucker.Concrete.ProjectiveShadow` | Current Lean quotient carrier. | Exterior coordinates modulo nonzero real scaling, including the zero orbit. Paper 3 supplies the concrete full-point reconstruction; the intended locus still requires genuine nonzero decomposable frame data. Alternative framed systems retain their declared soundness conditions. | A bundled projective variety, a constructed moduli stack, or a validity guarantee from the raw quotient type alone. |
| `PluckerCochain.PublicBinding.HashedPluckerShadow` | Current Lean semantic record. | Paper 2's mathematical shadow/digest/binding record, consuming Paper 3's full-point reconstruction when that exact shadow is released. | A digest-only wire format or automatic concealment of the full harmonic subspace. |

## Verified Categorical Register

This register owns the status of the objects and arrows used in categorical
diagrams. Archived categorical diagrams and cross-language plans are historical
references. The rows below state the current mathematical objects and arrows;
they do not assert a constructed presentation stack or executable refinement.

### Objects

| Object | Lean owner and status | Exact scope |
|---|---|---|
| `OrientedTwoComplex` | Current structure in `lean/Sheaf/CellComplex.lean`; its boundary-square equation is a field. | Finite vertex, edge, and face carriers with signed incidences through degree two. It is not presently packaged as a Lean face-poset category. |
| `CellularSheaf` | Current structure in `lean/Sheaf/Cellular.lean`; square-zero is proved from its data. | A finite coordinate cellular sheaf with stalk dimensions and maps on the 0/1/2 truncation. It records the needed functor-composition law directly; it is not presently a `CategoryTheory.Functor`. |
| `C0`, `C1`, `C2` | Current Lean abbreviations derived from `CellularSheaf`. | Finite Euclidean cochain carriers. |
| `harmonicOneSubspace` | Current Lean definition in `lean/Sheaf/Hodge.lean`. | The kernel of the true degree-one Hodge Laplacian of one concrete cellular sheaf. |
| `HodgeCoord(W) = W × Wᗮ` | Current objectwise model in `HCP.hodgeDecompositionEquiv`. | Harmonic data together with its orthogonal noise coordinate. The source includes noise; this is not a bijection from harmonic plaintexts alone. |
| `HCPBridge.Realization` | Current Lean interface in `lean/HCP.lean`. | Joins a Helfer interpretation, representative-indexed Laplacian, public classifier, matrix-level public projection, and their factorization laws. No concrete adapter from every `CellularSheaf` to this interface is yet bundled. |
| `FiberSystem` | Current interface in `lean/Axioms/Fibration.lean`. | A dependent family with transport along supplied hidden paths. Its path transport is not a cellular restriction map. |
| Root-level `Fibration` in `lean/Hardness.lean` | Supporting categorical structure outside the selected HCP/CVP claims. | A category over a base equipped with a bundled Grothendieck-fibration instance. Its tagged-copy lemmas do not constitute the HCP realization, a presentation stack or descent. |
| `HCPBridge.Observation` | Current Lean abbreviation. | The public pair `(p, b)` of classifier value and raw cochain. |
| `HiddenHodgeWitness` | Current Lean structure. | A private representative `x` satisfying `classifier(x) = p` for a public observation. |
| `SheafStateSnapshot` and `AcceptedCommittedOneCochain` | Current Lean interface objects in `lean/Sheaf/Commitment.lean`; concrete byte/hash refinement remains pending. | An immutable sheaf-bound snapshot handle and an accepted exact `C¹` payload bound to it. |
| `HistoryBindings` / `TransitionAnchor` | Current definitions and conditional theorem endpoints in [Storage/Anchor.lean](../lean/Protocol/Storage/Anchor.lean). | An actual candidate, original storage interpretation/artifact and exact sealed manifest, joined under a manifest-inclusion profile indexed by the candidate, context, ordered leaves and roots. Accepted exactness is derived from existing evidence. No concrete hash, storage availability or dynamic geometry is supplied. |
| `ProjectionAnchor` | Current definition and conditional theorem endpoints in [Storage/ProjectionAnchor.lean](../lean/Protocol/Storage/ProjectionAnchor.lean). | Specializes the anchor to an existing `SealedProjection` with its exact final prefix and explicit inclusion of the actual gate database under the same candidate's evidence root. Generic slot completeness alone does not supply these joins. |
| `OracleEta1`, `OracleEta2`, `OraclePipeline` | Current proposition-bearing protocol interfaces in `lean/Axioms/OracleModality.lean`. | They name oracle/node obligations. Despite historical comments, Lean does not define source/target categories, functors, or natural transformations for them. |
| `LedgerState` | Current Lean structure in `lean/Chain.lean`. | A ledger state acted on by explicit update functions. No categorical colimit or universal property is formalized. |
| `TaskSheaf` | Planned Paper 2 object; no Lean definition. | A possible sheaf over a finite execution slice. It is not the Paper 1 HCP sheaf, a quorum certificate, or finality. |

The current protocol/calibration object families additionally include:

| Object family | Owner/status | Exact scope |
|---|---|---|
| `OpenManifest`, `SealedManifest`, `PersistenceReceipt`, `Checkpoint`, `SealedProjection` | Paper 2 constructed/conditional records in `Protocol/Storage/{Checkpoint,Projection}`. | Exact context/list/root and predecessor identities; local consumption needs the matching receipt, not a global erasure or durability theorem. |
| `ValueModel`, `ResourceFlow`, `State`, `Action`, `Candidate`, `Policy`, `Execution` | Paper 2 ledger construction in `Protocol/Ledger/`. | Computed resource transition and conditional conservation/replay laws; catalogue value is not a cochain coordinate. |
| `Committee`, `VoteTarget`, `AuthenticatedVote`, `QuorumCertificate` | Paper 2 committee/quorum construction in `Protocol/Consensus/`. | Registered positive weights and one complete proposal; conditional intersection/safety is not rounds, locking or finality. |
| Proof/SNARK/compression/observation/verifier/runtime envelopes | Paper 2 contracts in `TCB/` and `Axioms/ZKP`. | Legacy well-formedness includes truth; concrete byte verification and numerical security require the actual primitive profiles. |
| `SourceValidityModel`, `SourceToSourceCalibration`, `SourceToCodeCalibration`, `EvaluationProjection` | Paper 3 mathematical interfaces in `Proximity/Application/`. | Original source/validity/metric and exact extraction with explicit direction/scale; Paper 2 supplies its construction/profile and consumes these laws. |
| Full-point reconstruction and exact-component source obstruction | Paper 3 auxiliary mathematics in `Proximity/Concrete/GrassmannianPlucker/Reconstruction`, `TCB/PluckerObservation`, `Sheaf/ObservationQuotient`. | §§7.1/7.3, outside the 52/22 selections. The residual obstruction requires a nonzero coexact direction and does not apply that premise to the `delta1=0` systematic source. |

### Morphisms and derived maps

| Map or relation | Lean owner and status | Exact scope |
|---|---|---|
| `restrict01`, `restrict12`, `restrict02` | Current fields of `CellularSheaf`; `restrictionComp` supplies the incident-flag composition law. | Face-to-coface linear stalk maps. They are not hidden-path transports. |
| `delta0 : C0 → C1`, `delta1 : C1 → C2` | Current definitions; `delta1_comp_delta0` is proved. | Cellular coboundaries assembled from incidence signs and restrictions. |
| `delta0.adjoint`, `delta1.adjoint` | Mathlib adjoints used in `lean/Sheaf/Hodge.lean`. | Metric-dependent reverse maps, not additional sheaf restrictions. |
| `degreeOneLaplacian` | Current derived endomorphism with Hodge properties proved. | `delta0 ∘ delta0* + delta1* ∘ delta1` on `C¹`. |
| `hodgeDecompositionEquiv`, `encrypt`, `split`, `decrypt` | Current definitions and inverse/recovery theorems in `lean/HCP.lean`. | The pointwise equivalence `W × Wᗮ ≃ C¹`; decryption is the `W` coordinate. |
| `operativeHarmonicComponent` / `operativeTarget` | Current definitions and theorems in `lean/HCP.lean`. | The unique target `P_{ker Delta_x}(b)`, not an arbitrary harmonic cochain. It is an idempotent projection; under isometric presentation transport its components satisfy the naturality square. |
| `PublicClassifier.π` and `PublicFiber` | Current Lean function and set fiber in `lean/Axioms/HelferFOL.lean`. | A classifier and its inverse-image fiber. No quotient universal property is assumed. |
| `FiberSystem.transport` | Current path-indexed interface map in `lean/Axioms/Fibration.lean`. | Dependent transport between fibers over hidden representatives, distinct from `restrict01`/`restrict12`. |
| `IsometricCochainEquiv.degreeZero/One/Two` | Current concrete sheaf transport in `lean/Sheaf/Equivalence.lean`. | Degreewise isometries commuting with both coboundaries; adjoint, Laplacian, and harmonic-subspace transport are proved. |
| `IsometricPresentationEquivalence.transport` | Current matrix-level HCP transport in `lean/HCP.lean`. | An isometry with Laplacian naturality. Harmonic-subspace and operative-projection naturality are proved; a category/functor/`NatIso` package is not yet defined. |
| `CellularSheaf.Morphism` and `mapC0/mapC1/mapC2` | Current definitions in `lean/Sheaf/Morphism.lean`; `mapC1_delta0` and `mapC2_delta1` are proved, and identity/composition are bundled. | Same-base stalkwise natural transformations and their induced cochain maps. This remains distinct from pullback/pushforward along topology maps and from the global Hodge-projection square. |
| `applyTransaction`, `applyBlock` | Current functions in `lean/Chain.lean` with freshness/monotonicity consequences. | Ledger updates, not colimit arrows by virtue of their names. |
| `TransitionAnchor.accepted`, `snapshot_root_matches`, `manifest_anchored` and quorum adapters | Conditional theorem endpoints in `Storage/Anchor.lean`. | Derive same-payload exact acceptance, snapshot/root inclusions and the matching quorum's manifest reference from actual-object equalities and supplied authentication relations. Accepted anchors have zero decoded exactness distance; this does not instantiate a positive-radius source profile. |
| `ProjectionAnchor.exact_prefix_anchored`, `word_matches_candidate`, `gate_database_included` | Conditional theorem endpoints in `Storage/ProjectionAnchor.lean`. | Carry the same original payload/RS word, exact final prefix leaves and actual gate database into the candidate's authenticated references. The existing far theorem retains its original premise; roots remain distinct and inclusion needs runtime refinement. |
| Historical `η₁`, `η₂` diagrams | Interface-only analogy around `OracleEta1` and `OracleEta2`. | Do not call these natural transformations until categories, functors, components, and naturality laws are supplied. |

## Ownership Layers

| Layer | Meaning | Examples |
|-------|---------|----------|
| Theorem-owned | Lean proves the statement directly. | `Heyting3` residuation, Hodge/CVP statements, spectral classification lemmas |
| Interface-owned | Lean names the obligation; implementations supply witnesses or evidence. | hidden fibration assumptions, oracle modality, stage admissibility |
| Runtime-owned | A future executable backend must refine the specified objects and checks; archived prototypes are historical. | Canonical bytes, authenticated roots, primitive verification and atomic application |
| Policy-owned | Node behavior after a judgment. | `Boundary` → hold/re-evaluate, slashing, mempool retry |
| Concept-owned | Architecture described but not yet formalized. | future fuzzy/L-fuzzy approximation layer, verified extraction |

## Boundary Is Not Implication

The clearest example is the spectral boundary case.

```text
SpectralJudgment.Boundary → Heyting3.Undetermined
SpectralJudgment.Boundary → ConsensusAction.Hold
```

The first map is a public truth collapse. The second map is node policy. Neither
changes the Heyting implication table. In the verified three-element Heyting
chain, implication is residuated, so:

```text
Undetermined ⇒ Invalid = Invalid
```

That does not mean a boundary block is immediately rejected. Rejection/holding is
owned by `ConsensusAction`, while implication is owned by the Heyting algebra.

## Why This Matters

This distinction prevents category errors during verification:

| Do say | Do not say |
|--------|------------|
| Lean proves the public Heyting collapse is residuated. | Runtime hold/retry is Heyting implication. |
| The oracle classifies raw spectral evidence into protocol judgments. | The oracle exposes the hidden fibration or Laplacian. |
| Boundary is non-final and policy-held. | Boundary is logically valid or logically invalid. |
| Executable refinement and primitive security require their own exact-object proofs. | Lean verifies the archived prototypes or a complete cryptographic protocol. |

This follows the same discipline as semantic-accounting approaches to large
formal catalogs: coverage, executable semantics, extensional semantics, and
runtime ownership should be tracked separately rather than collapsed into one
badge.
