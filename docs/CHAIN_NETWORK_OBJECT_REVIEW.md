# Chain, network and cellular-sheaf object review

Working review started 2026-11-05; source lookup and selected status notes
updated 2026-11-08. This records the recovered plans, source objects and the
user's reading list. It supports the active
[categorical map](CATEGORICAL_ARCHITECTURE.md) and
[protocol queue](PROTOCOL_PARITY_QUEUE.md); it does not select a new protocol,
metric, storage backend or cryptographic construction.

The immediate task is to examine the objects individually before completing
the application-radius profile. The user clarified that the temporary object
under discussion is the **StateBus**. Retained cellular-sheaf structure,
committed cochain values, private presentation data and global ledger state
need their own retention and update rules. Earlier proposals specify one bus
per commit; that granularity remains a proposal to review.

## Recovered intention and competing plans

The clearest recovered product statement is a **verified encrypted database
with a public proof ledger**. The
[archived storage plan](archive/STORAGE.md#verified-encrypted-data-layer)
keeps private state, representatives, paths and openings encrypted, while
ordinary validators check bounded public artifacts and evidence. This is a
useful requirements source. Its surrounding older spectral-identity and
implementation claims do not become requirements by association.

| Plan/source | Recovered proposal | What remains to reconcile |
|---|---|---|
| [Storage philosophy](archive/STORAGE_PHILOSOPHY.md), [sheaf storage](archive/SHEAF_STORAGE.md) | Ordinary persistence, with sheaf-aware tables alongside a conventional block store. | Define the semantic contents and access rules of each persisted object. Calling a backend a functor requires actual categories, maps and laws. |
| [Chain architecture](archive/CHAIN_ARCHITECTURE.md) | Harmonic/block and projection/consensus analogies; account, UTXO and mempool terminology. | Give actual action/resource semantics. The current conservative kernel deliberately leaves account-versus-UTXO interpretation open. |
| [Storage and routing](archive/STORAGE_AND_ROUTING.md) | Wallet/private state, relay/onion traffic and public chain are distinct roles; a different account-model proposal appears here. | Recover the common requirements without treating conflicting historical choices as one specification. |
| [Older architecture](archive/ARCHITECTURE.md), [consensus](archive/CONSENSUS.md) | Account connection graph, homotopy nerve, validator geometry and mutable bus/ledger state are identified in several ways. | Supply a map or explicit identification for each use. Connectivity and numerical agreement need separate authentication and finality arguments. |
| [Worker/oracle architecture](archive/CLEAN_ARCHITECTURE.md) | Workers compute and attest; oracle aggregates; nodes verify and update. | Bind attestations to one candidate and snapshot, and distinguish worker aggregation from ledger agreement. |
| [Semantic queue](SEMANTIC_PARITY_QUEUE.md), storage/checkpoint proposal | Volatile bus, persistent open/sealed artifact manifest, then local retirement after a persistence receipt. | Review bus granularity, public/private leaves, recovery and retention. The implemented mathematical lifecycle leaves atomic persistence, erasure and global run freshness explicit. |
| [Paper 2 scope](../papers/paper2/SCOPE.md), [protocol queue](PROTOCOL_PARITY_QUEUE.md) | Bounded conservative transition core, typed evidence and same-proposal quorum joins. | Select application/security profiles; define rotation, topology updates, rounds/locks and runtime refinement. These plans are narrower than the historical full-chain claims. |

Historical plans remain historical evidence. Implemented source status and
previous build results live in [SEMANTIC-PARITY](../SEMANTIC-PARITY.md) and
[the validation record](MATH_STORAGE_VALIDATION.md).

## Recovered three-layer picture and top-level Lean trace

The three layers recalled in discussion are explicit in
[the archived architecture](archive/ARCHITECTURE.md#three-layer-chain-hardness-hierarchy)
and [OracleModality](../lean/Axioms/OracleModality.lean):

| Historical layer | Intended role | Existing source evidence and limit |
|---|---|---|
| 3: `F_full`, private homotopy/wallet | Hidden presentation, credential, transport and full geometric computation. | The oracle pipeline comments name this layer. Its actual `OracleQuery` carries selected summaries and an identity commitment, rather than the full private object. |
| 2: `F_zk`, cochain/oracle | Committed mathematical data and evidence checked or attested by an oracle/verifier. | `OracleEta1`, `OracleEta2` and `OraclePipeline` state contracts on query/answer records. Identity-attestation commitments and transaction-level exact-cochain commitments have different roles. The three labels are not constructed sheaf functors. |
| 1: `F_hash`, public node/hash surface | Public roots, block/parent links, spent identifiers and an audit history tracing updates. | [TCB.ProofCarrying](../lean/TCB/ProofCarrying.lean), [proposal roots](../lean/Protocol/Consensus/Vote.lean) and [candidate evidence](../lean/Protocol/Evidence/Transition.lean) retain typed binding interfaces. The new [storage anchor](../lean/Protocol/Storage/Anchor.lean) supplies the semantic candidate/context/manifest join under an explicit profile; concrete hash functions, bytes and wire anchoring remain additional obligations. |

The historical purpose labels were anonymity, binding and accountability.
Those are requirements to specify and prove for selected constructions, not
security conclusions supplied by the diagram. In particular, the old claims
that quantization/hash operations are automatically natural transformations
are not implemented categorical results.

There is also an actual, differently organized three-object HCP stack in
[TCB.HCPObservation](../lean/TCB/HCPObservation.lean):

| Accessor | Actual carried object |
|---|---|
| `latticeObject` | Hidden integral harmonic message `h`. |
| `cochainObject` | Full observed cochain `b = h + delta0 a + delta1* c`. |
| `hashObject` | Leaf digest of the accepted exact-component payload, whose decoding equals `delta0 a`. |

`BoundHCPObservation.bindsObservation` supplies the relation joining the full
observation to that payload, digest, snapshot and lifecycle context. Its
`hashObject` is not defined as a hash of the full observed cochain. The
visibility layers, these three objects, and the three cellular degrees
`C0/C1/C2` describe different axes.

The requested top-level files have the following roles:

| Root file | Actual content to follow |
|---|---|
| [Chain.lean](../lean/Chain.lean) | Legacy `Block` record and `Chain := List Block`; `prev_hash : Nat` and extension against a supplied tip hash. No construction of cells or a block hash occurs here. |
| [Consensus.lean](../lean/Consensus.lean) | Imports geometry, reliability and Proof-of-Value scoring. These interfaces/score bounds do not provide a finality protocol. |
| [Axioms.lean](../lean/Axioms.lean) | Aggregates interfaces. `Foundation` names structural obligations; `SheafCoherence` carries actual abstract cochain maps; `Grassmannian.CechNerve` supplies abstract topology predicates; `OracleModality.FiniteSheafSetup` carries finite graph-shaped data. |
| [HCP.lean](../lean/HCP.lean), [Sheaf.lean](../lean/Sheaf.lean) | Hidden-operator definitions and the concrete finite cellular/Hodge stack. These are independent of identifying the cell carriers with blocks or peers. |
| [TCB.lean](../lean/TCB.lean), [Protocol.lean](../lean/Protocol.lean) | Public witness/verifier boundaries and the newer candidate, storage and quorum joins. [Protocol.Ledger](../lean/Protocol/Ledger.lean) explicitly retains the older `Chain` only as a compatibility import. |

## Blocks as cells: the recovered alternatives

The blocks-as-cells idea is present in the repository. The
[archived sheaf-storage plan](archive/SHEAF_STORAGE.md#advantages-of-sheaf-aware-storage)
proposes blocks as zero-simplices. The legacy
[BlockSection](../src/chain/block_section.py) assigns public/private data to
the vertex at height `h` and uses the predecessor hash as a chain link.
[Archived categorical architecture](archive/CATEGORICAL_ARCHITECTURE.md)
also treats blocks as objects of a directed parent-hash diagram.

Another proposal uses accounts as vertices and transactional connections as
edges. [SheafState.compute_topology](../src/chain/sheaf_state.py) actually
constructs that graph with sorted endpoint pairs and no two-cells. The
[Grassmannian interface](../lean/Axioms/Grassmannian.lean) separately describes
validators as vertices, distance-threshold edges and pairwise-close triangles;
its actual `CechNerve` structure does not construct those cells.

These proposals have not been joined in Lean. `BlockSection`'s parent-hash
equality and matching scalar check do not construct the real linear
face-to-coface restriction maps of `CellularSheaf`. A block-history complex
can be defined, but its geometry and relationship to the application/network
complex must be supplied. Thus the recovered question is which of these
documented bases is intended at each level, and how they are related.

Directions also need names:

- **History/provenance:** parent and authenticated-reference links are directed.
- **Account topology prototype:** connections are symmetric and endpoint pairs
  are sorted, so the built graph is undirected.
- **Finite oracle graph:** `FiniteSheafSetup.edges` contains ordered pairs;
  its endpoint/matrix-size laws alone do not construct the cellular sheaf.
- **Cellular structure:** signed edge orientation and the face-to-coface maps
  `vertex -> edge -> face` express boundary/restriction structure. These maps
  have a different meaning from causal history links.

The public tracing intention is particularly clear in the legacy
[HashChain](../src/chain/sheaf_state.py): entries record claims, connections,
transfers, rotations and blocks, with predecessor hashes and optional stored
transformation objects. Its current `verify_chain` checks stored predecessor
links without recomputing entry digests. It is a historical runtime prototype,
not a proof that the full semantic trace is authenticated.

[The oracle architecture](archive/ORACLE_ARCHITECTURE.md#hash-tracing-chloe_protocol-pattern)
also sketches a computation trace: input digest, operation/proof steps and
output digest. Computation provenance and the event/block history are two
separate tracing roles. Their chosen linkage must bind the computation's
inputs, outputs and statement to the event/candidate being accepted.

The newer trace binds actual payloads to leaf digests, ordered manifest roots,
candidate evidence and proposal/state roots. The new `TransitionAnchor` joins
these actual objects under `HistoryBindings.manifestIncluded`, while
`ProjectionAnchor` joins the exact final projection prefix and its actual gate
database. These endpoints pass the current 4.35 build and their nineteen-entry
dependency probe; exact scope belongs to [the validation record](MATH_STORAGE_VALIDATION.md). `ProposalRef`
still has no distinct storage-manifest-root field. Concrete inclusion under an
authenticated body/root or a new coordinate remains a specification choice.
Child digests need not equal the outer root.

The working organization accepted in discussion is a public history graph
whose block/event vertices authenticate references to immutable snapshots and
artifact manifests, with each snapshot bound to its application complex `X`
and sheaf `F`. The StateBus processes a fixed context temporarily. This settles
the separation of roles. The new anchor implements the bounded semantic join
under a supplied contract; it does not implement a history graph, choose
application cells/metric, or make the history graph itself the HCP base. The
active architecture and ownership tables record this organization.

### Semantic join: history entry to snapshot and manifest

The new [Anchor](../lean/Protocol/Storage/Anchor.lean),
[ProjectionAnchor](../lean/Protocol/Storage/ProjectionAnchor.lean) and
[AnchorExamples](../lean/Protocol/Storage/AnchorExamples.lean) sources reuse the
existing core without choosing an application metric or dynamic geometry model:

| Contract | Existing part and remaining join |
|---|---|
| History authenticates its references | `HistoryBindings.manifestIncluded` takes the actual candidate, context, ordered leaves, manifest root and candidate block digest. `TransitionAnchor` requires this witness, and its quorum adapter transports the inclusion to the matching proposal. The concrete authenticated body/new-coordinate choice and hash implementation remain open; the manifest root stays distinct from child digests. |
| Same interpretation and original artifact | `TransitionAnchor` requires the policy's `SnapshotModel.ofSheaf F` identification, `candidate.snapshot = C.interpretation` and equality of the evidence proof's public artifact with `C.artifact`. It derives payload equality, `C.Accepted`, snapshot-root equality and existing root inclusions from candidate evidence. Accepted anchors therefore have zero decoded exactness distance. |
| Exact projection manifest and evidence inclusion | `ProjectionAnchor` uses `SealedProjection.itemsMatch` to authenticate the exact final prefix, preserving predecessor joins. Its separate inclusion relation receives the actual gate database and candidate evidence root under the same runtime. Generic sealing alone supplies no projection coherence; concrete gate-proof/verifier serialization remains profile work. The original far theorem remains conditional. |
| Persistence and usable retained data | Reuse the persistence receipt indexed by the exact sealed context/list/root. Supply canonical encodings, digest verification, retrieval and the public/private projection of semantic payloads. Availability of an authenticated name alone does not reconstruct the sheaf or establish permission to decrypt it. |
| Explicit geometry/update boundary | The current `ofSheaf F` anchor fixes `X` and `F`; `Candidate.after` preserves snapshot, topology and epoch. The new join covers this same-geometry kernel. Geometry, epoch and key changes require their own authorized version/migration transitions and corresponding contexts. |

## Objects, in dependency order

| Object | Actual current meaning | Decision or missing construction |
|---|---|---|
| Base complex `X` | [OrientedTwoComplex](../lean/Sheaf/CellComplex.lean): finite vertex/edge/face carriers, integer incidences and boundary-square law. This is an incidence presentation through degree two. | Specify what cells mean in the application, their canonical names/order and who may change them. A topological realization or full face-poset package is additional structure. |
| Cellular sheaf `F` on `X` | [CellularSheaf](../lean/Sheaf/Cellular.lean): finite real Euclidean stalk spaces, actual linear face-to-coface maps and incident-flag composition. Stalk dimensions and maps specify spaces and compatibility. | Construct a meaningful application family. Specify which data is public, encrypted, owner-held or reconstructible. Individual stalk values are separate cochain data. |
| Cochain and Hodge structure | The incidences and `F` induce `C0`, `C1`, `C2`, `delta0`, `delta1`; [Hodge](../lean/Sheaf/Hodge.lean) proves properties of `Delta1 = delta0 delta0* + delta1* delta1`. | Degree, scalar field, bases and inner products must accompany an operator. The present real Euclidean model does not supply a finite-field wire codec. |
| Integral structure and encrypted sample | [Integral](../lean/Sheaf/Integral.lean) adds chosen integral lattices inside real stalks. [HarmonicLattice](../lean/Sheaf/HarmonicLattice.lean) has a harmonic message and exact/coexact real noise. | Keep lattice bases, coefficient encoding and noise profile explicit. The full encrypted sample and its exact component are different objects. |
| Presentation, classifier and private path | Existing HCP/fibration interfaces distinguish a hidden representative, its public class and transport witnesses. [Isometric cochain equivalence](../lean/Sheaf/Equivalence.lean) proves operator transport under its stated hypotheses. | Construct the selected presentation family and relation to the application sheaf. Same class, a path, isometry, lattice preservation and cryptographic key rotation each need their own laws. |
| Snapshot and payload interpretation | [Commitment](../lean/Sheaf/Commitment.lean): `SheafStateSnapshot F` is indexed by `F`, with schema/root/tag and explicit encoding/binding propositions. The interpretation supplies an actual payload decoder into `F.C1`. | Realize those propositions with canonical bytes and authentication. Indexing by `F` is mathematical context; the record does not serialize or reconstruct `F`. A root names data but does not provide its availability. |
| Committed payload | The same original hashed cochain artifact is retained in [Storage.Context](../lean/Protocol/Storage/Context.lean). Shape/snapshot binding and `Context.Accepted` are separate. Exact-payload acceptance includes `I.decode c = F.delta0 a`; the wire payload `c` and its decoded geometric cochain have different types. Openings are identified modulo `ker delta0`. | Choose the actual commitment/security profile and what an opening reveals. Preserve raw invalid/noisy observations when stating a proximity problem. |
| Projection bus and prefixes | [Stage.StateBus](../lean/Proximity/Concrete/Gates/Stage.lean) is an immutable completed RS-stage record retaining its cochain/plane predecessors and equalities. [Storage.Projection](../lean/Protocol/Storage/Projection.lean) represents incremental typed prefixes and gates. | Give runtime allocation, scope, recovery and retirement rules. A Lean record does not itself implement a mutable process, expiration or memory erasure. |
| Retained checkpoint artifacts | [Checkpoint](../lean/Protocol/Storage/Checkpoint.lean) retains typed payload/digest leaves, fresh-slot append, complete sealing, an exact manifest receipt and local consumption. [Anchor](../lean/Protocol/Storage/Anchor.lean) and [ProjectionAnchor](../lean/Protocol/Storage/ProjectionAnchor.lean) join an exact seal to candidate evidence and the original context under explicit profiles. | Choose public serialization and private encrypted references, concrete manifest inclusion, durability/retrieval contracts and cleanup policy. A proof record may contain private witnesses and cannot automatically be serialized publicly. |
| Ledger state and accepted update | [Ledger.State](../lean/Protocol/Ledger/State.lean), [Transition](../lean/Protocol/Ledger/Transition.lean), [Evidence](../lean/Protocol/Evidence/Transition.lean): actual finite resource flow/nullifiers, computed successor and context-bound acceptance. | Instantiate resource/asset/authorization/nullifier/root relations. `Candidate.after` currently preserves epoch, snapshot and topology; rotation and geometry changes need additional transitions. |
| Proposal, quorum and network | [ProposalRef](../lean/Protocol/Consensus/Vote.lean) names the same candidate's roots and round context; anchor endpoints carry the same manifest/snapshot references into a matching quorum proposal. [Rust transport](../rust/node/src/network/transport.rs) implements libp2p transport and gossip. | Refine the explicit history/gate inclusion profiles with canonical wire envelopes and actual hashes. Define rounds, locks, finality and geometry updates. Transport, local numerical agreement and authenticated ledger agreement have different contracts. |

Retaining the sheaf after retiring a bus requires access to its cell labels,
incidences, dimensions, restriction maps and coordinate conventions, plus any
chosen integral bases and decoder. This can use encrypted objects and public
digests; visibility is still a design decision. Publishing all restriction
matrices and the Euclidean conventions also makes the corresponding Hodge
operator computable. The hidden-operator claim therefore needs an explicit
public observation profile.

The initial review used the small zero-incidence
[Storage.Examples](../lean/Protocol/Storage/Examples.lean) fixture. The later
[Sheaf.HCPAxisFamily](../lean/Sheaf/HCPAxisFamily.lean) and
[HCP.AxisFamily](../lean/HCP/AxisFamily.lean) construct actual integral cellular
HCP examples. Selecting the intended database/network sheaf remains separate
from those examples and the general transport theorems.

## Graph roles and maps to specify

These are roles to distinguish in a specification. Several roles can use one
underlying graph if the identification is supplied explicitly.

| Role | Required interpretation/map |
|---|---|
| Cellular base | Cells and incidence data supporting `F` and its cochains. |
| Account/presentation relations, if selected | Authenticated application relations and their map into the cellular base. |
| Hidden representative/path space | Presentations, public classifier fibers and authorized transport; the carrier is not determined by a peer list. |
| Validator local views/task complex | Finite execution slices, observable evidence and restriction of judgments. |
| Physical peer/relay network | Addresses, authenticated connections, message delivery and privacy assumptions. |
| Ledger/artifact history | Parent relations, manifest dependencies, availability and accepted state transitions. |

The Rust peer network exists. Its current transaction/block/oracle messages
still use legacy envelopes; their mere delivery does not establish the newer
same-candidate/snapshot/artifact joins. The network implementation and the
mathematical sheaf should be connected by a deliberate interpretation, rather
than inferred from shared graph terminology.

## Reading register

The single canonical [source ledger](SOURCE_LEDGER.md) now owns the topic/ID
index, versioned source rows, reviewed material and adoption boundaries.
This working review retains historical architecture and object provenance.

### Quick topic and ID index

Use the [ledger's quick index](SOURCE_LEDGER.md#quick-topic-and-id-index) for
source lookup; the detailed reading rows were moved rather than duplicated.

## Decisions to resolve, one object at a time

| Order | Concrete decision/result | Why it comes here |
|---|---|---|
| 1 | Reconcile the documented account/validator and block-history bases: specify each intended complex, its cells/incidences, any maps between bases and authorized topology changes. | The three-layer intention is recovered. Its different graphs still need explicit relationships before choosing the operative `X` and `F`. |
| 2 | Construct `F`: each stalk space, restriction map, composition proof, coefficient/basis convention and visibility policy. | This makes the maintained cellular structure concrete and determines the operative coboundaries. |
| 3 | State the data contract: full encrypted sample, exact committed component, public observation, opening/proof and authorized query output. | Different observations retain different information and support different claims. |
| 4 | Choose snapshot encoding/availability and bus/run granularity; list retained public leaves and encrypted private objects, recovery and retirement conditions. | The existing context/checkpoint core can then be instantiated without conflating the bus, geometry and manifest. |
| 5 | Specify authorized representative/key/epoch changes and any data migration, nullifier/linkability policy and compromise consequences. | The current fixed-snapshot transition does not perform those updates. Mathematical transport and secret-material rotation require separate witnesses. |
| 6 | Select the source metric and prove the codec/extraction bridge for that declared profile. | Decoded exactness distance, full HCP residual and pair Hamming distance currently measure different objects. The unrestricted coexact-ray obstruction constrains exact-component-only extraction. |
| 7 | Assign optional task propagation/learning to particular objects; specify each map into deterministic acceptance if used. | Local consistency, numerical proposals and authenticated consensus can then reuse infrastructure with explicit contracts. |
| 8 | Record the selected observation/security games and runtime refinement obligations; assign each claim and prerequisite to its paper. | External source analogies become usable commitments only after actual maps, assumptions and guarantees are stated. Full blockchain/runtime completion is not a prerequisite for Paper 3's bounded mathematical application theorem. |

For item 6, [the cochain trace](COCHAIN_PROXIMITY_TRACE.md) records the current
projection path and [Paper 3 parity](../papers/proximity-prize/SEMANTIC_PARITY.md)
records its application boundary. The generic coding statements are already
separate from this profile choice. Accepted exact components have zero decoded
distance to exactness; a nonempty positive-radius family requires an
appropriate raw-observation/source profile. A full-HCP far statement through
an exact-component-only view needs the additional restrictions or observed
data identified by the existing obstruction.

The source ledger adopts no new external construction or security claim.
The separately implemented anchor sources have the validation status recorded
above and in the shared validation record. The public-review exporter stages
the validated Lean/manuscript subset separately; this historical working
note stays outside that package. No publication has occurred.
