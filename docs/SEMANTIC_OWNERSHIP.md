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
| Ciphertext content ID and public audit links | Constructed content lookup in `Storage.Retrieval.ContentAddress`; selected native ciphertext codec and original-observation binding in `Storage.CoupledCiphertext`. Whole-stack public history remains a protocol profile. | Hash of the selected canonical encrypted bytes for fetching/tracing. Explicit public records may link that ID to contexts, evidence and successor actions. This recovers the archived full-data → hash → chain intent without serializing a whole private semantic record. Repeated IDs and action links are observable. | A homotopy classifier, a decryption key, an identity-anonymity guarantee, or a hash of every private witness field. Exact artifact, ciphertext, snapshot, evidence and block preimages remain distinct. |
| Auditable actions with private identity | Intended Paper 2 privacy profile; concrete credential/proof and metadata-security construction remains open. | Public action/ciphertext IDs and policy evidence allow action tracing without decrypting the identity witness. Identity and authorization secrets remain outside the selected public encoding. PIR/OMR address retrieval/recipient metadata separately. | The bounded owned-transfer release, which publishes owner/signer IDs; efficient PIR; automatic legal compliance; or an identity-opening mechanism selected by default. |
| `CellularSheaf` | Current Lean identifier. | Paper 1 finite (0/1/2)-cell sheaf with real-linear stalks and face-to-coface maps. | The mutable chain state, a protocol execution graph, or a Helfer/Grothendieck fibration merely because all use fiber language. |
| `CellularSheaf.Morphism` | Current Lean identifier. | A same-base stalkwise linear natural transformation commuting with the incident cellular restrictions; it induces maps on `C0`, `C1`, and `C2` that commute with both coboundaries. | A pullback/pushforward along a topology map, hidden-path transport, or an adjunction. |
| `SheafState` | Planned Paper 2 protocol term recovering the original state-bus intent; the archived Python class is legacy, not canonical. | Volatile bus advancing a fixed snapshot/artifact context through typed projection/certificate stages. Exact acceptance is a separate predicate; runtime lifecycle granularity remains open. The checkpoint core requires a receipt for the exact sealed manifest before local consumption; runtime erasure remains separate. | The persistent checkpoint store, the whole mutable node/ledger/economics state, a global section, or a finalized content-addressed block. |
| `SheafStateSnapshot` | Current Lean interface object; concrete encoding/hash refinement is pending. | Immutable sheaf-indexed input name carrying a 32-byte root, topology tag, and explicit canonical-encoding/root-binding obligations. `Storage.Context` retains the bound original artifact; acceptance is checked separately. | The mutable projection bus, a serialized/reconstructible sheaf, a proved canonical byte encoding, or the ledger before/after root. |
| Coupled native presentation and full ciphertext | Constructed optional integral profile in `Sheaf.HCPCoupledFamily`, `HCPCoupledEncoding`, `HCP.CoupledSemantics` and `Storage.Coupled*`. | Canonical integer-matrix bytes determine the coupled sheaf, standard integral structure and metric. Separate full-ciphertext bytes decode to the original Hodge observation. The constructed cochain/lattice equivalences preserve public class and integer coefficients; the snapshot/observation relations retain the existing context. | A new storage bus, equality of complete public views, a replacement for the exact payload, a transport-material release policy, or a cryptographic hiding theorem. |
| Coupled native ciphertext transport | Constructed real equivalence in `HCP.CoupledTransport` and exact rational reference algorithm in `HCP.CoupledRational`. | `M_C M_B⁻¹` carries original generated samples with the same integer message and opening coordinates. Executable rational inverse, transport and private coefficient recovery refine the original real operators; identity/inverse/composition and generated-sample integrality are proved. | The strict cochain shear, a norm isometry, a polynomial runtime bound, or a safely public evaluation key. Transport to the known zero presentation reveals coefficients. |
| Native transport scope and token | Constructed codecs in `Ephemeral.ScopeCodec`, `Storage.TransportCodec` and `Ephemeral.TransportToken`. | Canonical original recipient/epoch/context scope and derived rational map; complete scope/token-hash checks, dimensions, roundtrip, injectivity and malformed-input rejection. The source/target matrices are omitted as separate fields. | A key-hiding guarantee for the derived operator, caller authentication, replay prevention, a per-ciphertext/single-use capability, or a protected delivery envelope. |
| Held-token native delivery and retrieval | Constructed `Ephemeral.NativeTransport`, `NativeDelivery` and `Storage.Retrieval.Native` over the existing `ScopedDelivery` receipt. | The receiver executes with held token bytes and canonical ciphertext bytes; retained-base recovery takes its private source presentation explicitly. Contexts and byte bindings retain the original observations, with the full-ciphertext digest checked separately from the exact artifact digest. | Regeneration of the map from both private endpoints at the receiver, cryptographic confinement of copied matrix data, a concrete authentication/channel primitive, or a full-view security theorem. |
| Ciphertext manifest and native history association | Canonical [CiphertextManifest](../lean/Protocol/Storage/CiphertextManifest.lean), separate [NativeManifest.BindsOriginal](../lean/Protocol/Storage/NativeManifest.lean) refinement and actual [Transfer.Native](../lean/Protocol/Transfer/Native.lean) adapter, reusing `SealedManifest` and `TransitionAnchor`. | The raw two-slot seal retains the original exact artifact and selected ciphertext bytes/digest. Its root enters the owned-transfer intent, signing message and packet check. The separate native certificate relates those same bytes and context to the original Hodge observation. On the actual checked transfer, canonical sample-byte equality and private delivery yield the original harmonic message, accepted update and recovery-or-collision result under the same computed history anchor. | Full-ciphertext validity from raw sealing or exact-payload acceptance, a concrete root codec/hash-security proof, authenticated history/availability, a relation from coefficients to catalogue actions, identity privacy or efficient PIR. |
| Typed projection certificates | Current `HardGateCertificate`, `NaturalityGateCertificate` and `CalibratedFinalCertificate` in [Gates](../lean/Proximity/Concrete/Gates.lean). | Retain the exact projection chain and preceding certificate; final separation needs its explicit calibration witness. | Internal invariant-abort behavior, validation of arbitrary received bytes, or the proposition-only legacy `StageAdmissibility` interface. |
| Exact-intent certificate reflection | Generic [Transfer.Certificates](../lean/Protocol/Transfer/Certificates.lean) and constructed [Statement](../lean/Protocol/Transfer/Certificates/Statement.lean), [Native](../lean/Protocol/Transfer/Certificates/Native.lean) and [Projection](../lean/Protocol/Transfer/Certificates/Projection.lean) adapters. | `Statement.withVerifier` executes the selected byte algorithm on the actual encoded intent/metadata/ciphertext subject, with reflexive algorithm agreement. Canonical decoding proves reflection for its declared actual-object meaning. Native certification uses the existing `BindsOriginal`; projection meaning retains the exact record certificate and original input relation. Missing certification after checking is traced to actual backend false acceptance. | A Boolean verifier's soundness, circuit/CRS implementation, extraction/knowledge, or authenticated semantic profile registration. |
| Finite evidence and ordered gate checks | Current [Codec](../lean/Protocol/Transfer/Certificates/Codec.lean), [Calibration](../lean/Protocol/Transfer/Certificates/Calibration.lean), [Evidence](../lean/Protocol/Transfer/Certificates/Evidence.lean) and [Bundle](../lean/Protocol/Transfer/Certificates/Bundle.lean). | Canonical public subjects, rational calibration realization, subject-and-proof leaf hashes, and one immutable seven-entry bundle/root. Hard/naturality/final checks require the same first five/six/seven entries; failed earlier checks reject later operational acceptance. The preferred `Projection.boundConfig` checks all seven computed leaf names/root against the actual existing database; `checked_bound_record` derives `DatabaseBinds` from acceptance. | Certificate truth from hashing, private witness serialization, hash security, or evidence-root/history authentication without their selected binding contracts. |
| Approved finite profile and execution | [Certificates/Profile](../lean/Protocol/Transfer/Certificates/Profile.lean), [Registered](../lean/Protocol/Transfer/PathSignature/Registered.lean) and [NativeRegistered](../lean/Protocol/Transfer/PathSignature/NativeRegistered.lean). | A complete acceptance quorum approves exact descriptor/program/key/CRS bytes. Applicability checks original metadata, parameters, scope/calibration and epoch. The preferred native adapter checks the exact expected program and derives the public key from the existing owner credential, actual context snapshot root and ciphertext digest; the original full message and signature bytes reach the selected parsed verifier. | Discharging source/setup equations without the actual joins below; conversion of legacy authentication; owned ledger finality, credential ownership or secure setup generation. |
| Bounded native credential relation | [NativeRelation](../lean/Protocol/Transfer/PathSignature/NativeRelation.lean) and [NativeProgram](../lean/Protocol/Transfer/PathSignature/NativeProgram.lean). | Concrete private matrix/message/opening/salt bytes with bounded validation; salted source credential, target-presentation and ciphertext names; the same original Hodge sample, typed Helfer equivalence and native full-ciphertext transport. | Instantiation of the generic fingerprint/path-to-isometric-rotation interface, automatic original artifact/lifecycle binding, hiding or individual-owner identity. |
| Adaptive CRS reference and native security reduction | [CRS](../lean/Protocol/Transfer/PathSignature/CRS.lean), [NativeSecurity](../lean/Protocol/Transfer/PathSignature/NativeSecurity.lean). | Response-dependent bounded signing generates its actual query log. `WinningHybrid` uses the actual Boolean fresh-forgery test; it needs no statistical all-events premise. The preferred full-view experiment supplies canonical full target-ciphertext bytes while preserving remaining auxiliary data and execution. Its five terms retain hybrid, extraction failure, original coefficient recovery and two byte-hash collision probabilities. | A concrete CRS/SE primitive, numerical/negligible or PPT theorem, statistical zero knowledge, UC security, or a hardness estimate imported from the older HCP/CVP view. |
| Original native context and setup joins | [NativeContext](../lean/Protocol/Transfer/PathSignature/NativeContext.lean). | Actual credential, target snapshot binding, canonical full-sample bytes and selected-hash agreement derive the challenge key. Actual approved parser results identify the selected setup reference; canonical sample equality identifies the application's released ciphertext. | Derivation of source binding or secure setup from public names, freshness, arbitrary adversary-output matching or primitive security. |
| Native application completion and inherited bound | [NativeApplication](../lean/Protocol/Transfer/PathSignature/NativeApplication.lean). | The selected primitive and existing full-view PMF generate the actual target. Canonical message parsing, challenged signer-key equality and supplied payload proof reconstruct the original packet. Fresh accepted completion implies a win in that same transcript. The preferred `nativeSource_application_bound` consumes original credential/snapshot/sample/hash and setup equations and jointly derives the selected owner-key, released-ciphertext and five-term application bound. Its error budget names that event sum without estimating it. | Translation of arbitrary packet adversaries, all accepted/accepted-invalid transfers being forgeries, removal of policy/compromise/payload branches, numerical primitive estimates or complete storage-view privacy. Other public data belongs in the auxiliary remainder. |
| Finite native sampling | [NativeSampler](../lean/Protocol/Transfer/PathSignature/NativeSampler.lean). | Uniform seed law with cardinality `(2K+1)^(2mn+n+m+1) * 256^ell`, injective private-witness decoding, bounded support and an independent fixed cryptographic-tape law with the original marginals. | Uniform/distinct hash-derived public keys, efficient sampling/runtime refinement, or hardness/confidentiality for a family containing zero messages and degenerate matrices. |
| Original native sampler recovery audit | [NativeRecovery](../lean/Protocol/Transfer/PathSignature/NativeRecovery.lean). | An actual canonical-byte predictor recovers the original scalar coefficient with exact probability `7/9` under the full bound-one seed law, for any salt length and appended independent crypto tape. Known-zero samples with nonzero coexact opening reveal a reused scalar operator. | A theorem attacking every growing-dimensional profile, automatic signature-of-knowledge forgery or a small native recovery bound. |
| Fresh-sign ciphertext candidate | [NativeSignSampler](../lean/Protocol/Transfer/PathSignature/NativeSignSampler.lean). | `C=A diag(k)`, `AᵀA=dI`, message `z=d sign(m)` and correlated opening `u=C sign(m)` give equal canonical ciphertext laws under one fresh uniform sign key. Identity and dense Hadamard examples are constructed; private projection recovers the original message. | The default storage profile, repeated-key/oracle security, hiding of public operator hashes, credential/signature views, public-key encryption or computational hardness. |
| Ciphertext-only guessing for the sign candidate | [NativeSignPrivacy](../lean/Protocol/Transfer/PathSignature/NativeSignPrivacy.lean). | The actual joint law of uniform message and independent fresh key factors into an independent message/ciphertext pair. Every total complete-message decoder succeeds with exactly `2^-n`, also for deterministic ciphertext digests and independently sampled fixed random tapes. Positive `d` identifies encoded coefficient recovery with bit recovery; any partial integer-coefficient extractor, allowing invalid values or `none`, succeeds with probability at most `2^-n`. | Nonuniform or message-dependent auxiliary information, public operator roots, credentials/proofs, reuse/oracle security, or a bound for the reference full-view CRS extractor. |
| Bare operator-hash plaintext testing | [NativeOperatorGuessing](../lean/Protocol/Transfer/PathSignature/NativeOperatorGuessing.lean). | Executable parsing and transpose/parity arithmetic recover the masked signs. The true proposed plaintext produces the actual canonical operator bytes and passes its raw hash; a different accepted guess gives an actual canonical-byte hash collision. | A timed chosen-plaintext game, privacy of the enlarged view or any assertion about a hiding operator commitment. |
| Native transport and coexact refresh | [NativeNoiseRefresh](../lean/Protocol/Transfer/PathSignature/NativeNoiseRefresh.lean). | An actual byte correction adds the target coexact sample for desired-minus-retained openings, giving the exact desired target sample. Ordinary migration equals the fresh-sign sample exactly when openings agree. | Fresh-key sampling, a safe public refresh token, secrecy of the correction, one-use lifecycle or preservation of the fresh distribution by transport alone. |
| Native arithmetic circuit core | [NativeCircuit](../lean/Protocol/Transfer/PathSignature/NativeCircuit.lean), [NativeCircuitBounds](../lean/Protocol/Transfer/PathSignature/NativeCircuitBounds.lean). | Generated `2mn+n+m+1` constraints admit honest integer/modular assignments. The actual integer-lift range check and explicit maximum residual/modulus bound derive `NoWrap`; modular satisfaction then yields the original integer observation. | Compiling range/salt/canonical-byte/hash checks into field constraints, a complete selected proof-engine backend, or arithmetization of arbitrary real projection certificates. |
| Redesigned operator-root privacy profile | Planned use of the existing `SheafStateSnapshot`/`Context` carriers; no hiding operator commitment is instantiated. | The selected design target is exact harmonic recovery, fresh geometry per public encrypted object and persistent private master-key management. The sign sampler remains a nondefault implementation candidate; actual hiding operator binding, private opening and versioned native instance/witness/codec/context joins must be built together. The recovered [operator-commitment precedent](SOURCE_LEDGER.md#operator-commitment-provenance) uses a private-nonce hash of the operator and path parameter; its hiding model remains unproved. Public content hashes name ciphertext, while operator fingerprints, full projector/Plücker data and usable transport remain private. | Treating existing exact-cochain hiding flags as operator hiding, retaining bare `hash(C)` in the sign profile, reinstating the archived cut-and-open proof, or extending the one-use law to wallet-at-rest, multi-use or complete storage/proof views. |
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
| Projection certificate and evidence database | Paper 2 retains `Proximity/Concrete/{Gates,GateEvidence}` and adds `Transfer/Certificates/{Evidence,Bundle,Projection}`; Paper 3 owns the mathematical comparisons. | The mathematical predecessor certificate is retained exactly, including chosen chart/metric functions. The legacy `SlotBinds : EvidenceSlot → Prop` remains slot-only; the separate finite database guard derives actual byte/digest/root equations on that same database from operational acceptance. The bundle check also establishes every required prior Boolean verification; declared-statement truth still requires exclusion of backend false acceptance. |
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
| `CiphertextManifest.ciphertext_named`; `NativeManifest.ciphertext_bound`; `NativeAnchored.message_eq_of_bound_sample`; `Config.nativeBinding`, `CheckedTransfer.native_history_recovery` | Raw manifest and selected native refinement/retrieval endpoints in [CiphertextManifest](../lean/Protocol/Storage/CiphertextManifest.lean), [NativeManifest](../lean/Protocol/Storage/NativeManifest.lean), [NativeAnchored](../lean/Protocol/Storage/Retrieval/NativeAnchored.lean) and [Transfer.Native](../lean/Protocol/Transfer/Native.lean). | Raw sealing derives directory membership for arbitrary bytes. Separate `BindsOriginal` and canonical sample-byte equality identify the original observation/message on that seal. The checked-transfer adapter retains its actual intent root, original artifact, computed history inclusion and accepted update while composing recovery/collision under canonical-token and byte-availability premises. |
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

Internal hard gates describe an intended local abort policy during key
generation, encryption or decryption when an invariant fails. The compatibility
and `StageAdmissibility` interfaces contain proposition-level obligations;
executable guards and their refinement remain open. External acceptance checks
received bytes under the selected codec and verifier. Existing typed mathematical
certificates retain the projection-chain facts independently of these roles.

The finite certificate subject identifies the original intent and metadata,
context/manifest reference, ciphertext digest, selected public profile, claim
and optional rational calibration. Public subject and proof bytes are encoded
separately from private witnesses. The root commits all seven raw subject/proof
entries; it does not certify their truth. Verification of the hard, naturality
or final prefix establishes every earlier Boolean check on that same immutable
bundle. Failed earlier checks reject the actual later operational checker.
The preferred `Projection.boundConfig` also checks the actual retained record's
database against every computed leaf digest and the root; successful checking
derives `DatabaseBound` for that exact parsed bundle and record.

`Statement` constructs the intended byte predicate and proves its canonical
encoding reflection. `Native` instantiates it with the existing original HCP
observation binding. `Projection` identifies the exact retained certificate,
including its chosen chart and metric functions. The original `Storage.Projection.Input` connects the
chain to the same cochain/context. The final statement additionally requires
the rational descriptor to realize all four actual real calibration values.

The selected profile approval now authenticates exact public descriptor,
program, verifier-key and CRS bytes through the existing complete-proposal
quorum. The registered owner checker rejects inapplicable epochs/metadata/scopes
or failed parsing, and then executes those actual parsed objects. Approval is
not a state update, finality or evidence of honest setup generation. The
program's refinement to the intended semantics remains explicit.

The bounded native witness uses integer source/target matrices, message,
openings and salt. Its existing typed Helfer equivalence and full native
transport are separate from the generic `HasPathSpace`/isometric realization
interface. It does not automatically construct an original bound observation
with accepted artifact and lifecycle data.

The CRS construction composes supplied setup/prover/verifier/simulator/extractor
algorithms. Its bounded adaptive interpreter generates actual query histories;
the conditional native forgery bound has five terms: transcript hybrid,
extraction failure, original coefficient recovery, snapshot collision and
ciphertext collision. The preferred `fullViewExperiment` concretely supplies
the canonical full target ciphertext to the adversary alongside its public
credential and commitments. It preserves the remaining auxiliary input, PMF,
adversary, setup and random tapes, and has the same five-term bound. The
earlier `(class,b)` ambiguity or explicit-lattice CVP comparison supplies no
small recovery bound for this richer view.

The native snapshot join uses the existing
[CoupledBinding](../lean/Protocol/Storage/CoupledBinding.lean)
`BindsSnapshot` profile and `context_root_eq`: the canonical target-matrix
hash is the original context snapshot root under that profile. The canonical
sample-byte equation similarly identifies the ciphertext digest. These are
actual context conditions when applying the sampled theorem, alongside the
selected setup/reference and owner-credential equality.

A secure primitive implementation, its quantitative security estimates,
complete hash/range/byte circuit refinement, semantic setup verification and
authenticated inclusion of the computed database root remain obligations.
A declared intended predicate alone does not prove Boolean soundness or
knowledge. Profile-selected requirements still allow an exact native context
without a calibrated far-region certificate.

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
