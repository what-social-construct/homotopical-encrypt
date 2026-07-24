# Semantic Ownership

HCRYPT separates mathematical truth, formal obligation, executable computation,
and node policy into distinct ownership layers. This keeps the proof stack
honest: Lean can prove the algebraic and hardness facts without pretending to
certify every runtime line, and runtime policy can remain explicit without being
mistaken for a logical connective.

## Canonical Object Vocabulary

This table separates current Lean identifiers from planned cross-layer
vocabulary. Historical documents in `docs/archive/` may retain older language.

When an older Python or Rust object overlaps a current Lean object, the Lean
type and theorem statement take precedence. Runtime code may refine that
interface or expose a missing obligation, but it does not silently redefine the
mathematical object.

| Canonical term | Status | Meaning | Must not be conflated with |
|---|---|---|---|
| `CellularSheaf` | Current Lean identifier. | Paper 1 finite (0/1/2)-cell sheaf with real-linear stalks and face-to-coface maps. | The mutable chain state, a protocol execution graph, or a Helfer/Grothendieck fibration merely because all use fiber language. |
| `CellularSheaf.Morphism` | Current Lean identifier. | A same-base stalkwise linear natural transformation commuting with the incident cellular restrictions; it induces maps on `C0`, `C1`, and `C2` that commute with both coboundaries. | A pullback/pushforward along a topology map, hidden-path transport, or an adjunction. |
| `SheafState` | Planned Paper 2 protocol term recovering the original state-bus intent; the current Python class is legacy, not canonical. | Volatile, per-commit state bus initialized from one accepted exact cochain and `SheafStateSnapshot`; it advances through the typed projection/certificate stages and is wiped after successful block sealing. | The persistent checkpoint store, the whole mutable node/ledger/economics state, a global section, or a finalized content-addressed block. |
| `SheafStateSnapshot` | Current Lean interface object; concrete encoding/hash refinement is pending. | Immutable pre-projection context carrying a 32-byte root, topology tag, and explicit canonical-encoding/root-binding obligations. The exact cochain is bound before a fresh active `SheafState` begins. | The mutable projection bus, a proved canonical byte encoding, or the ledger before/after root. |
| `SheafBlock` | Planned Paper 2 protocol term; no Lean definition yet. | Persistent per-commit checkpoint record. Its open form is filled stage-by-stage from `SheafState`; its sealed immutable form contains complete artifact and certificate/evidence subtrees under one canonical SHA-256 content address. | `Chain.Block`, a cellular global section, the evidence subtree root alone, or the volatile `SheafState`. |
| `CellularSheaf.IsGlobalSection` | Current Lean identifier; overloaded `Proximity.GlobalSection` names remain a migration item. | A degree-zero stalk assignment satisfying every restriction equation, equivalently (delta_0x=0) in the linear model. | An arbitrary vertex assignment, account table, block, or accepted degree-one cochain. |
| `AcceptedCommittedOneCochain` | Current Lean identifier. | The committed (C^1) payload (b=delta_0a), bound to one `SheafStateSnapshot`; `IsExactOneCochain` names the underlying geometric property. | A degree-zero global section or a uniquely determined opening (a). |
| `HasPathSpace.Path x y` | Current Lean interface type; no concrete path-space instance yet. | A typed path witness from representative `x` to representative `y`, intended to remain private at the protocol boundary. | A sampled matrix interpolation, equal public classifier values, or equality of a finite invariant tuple. |
| `PathEquivalent x y` | Current Lean identifier. | Mere inhabitation of `HasPathSpace.Path x y`. | A concrete topological path model or a proved equivalence criterion for runtime objects. |
| `PublicClassifier` / `PublicFiber` | Current Lean identifiers. | The public classifier map and the fiber over one public class value. | A path component. Lean currently proves path-to-same-class consequences only under an explicit path-respecting hypothesis; it does not prove the converse. |
| `Proximity.Gates.Projection.StateBus` | Current Lean proof object; runtime reset/finalization is pending. | One witness-local nested chain of already-checked cochain, plane, and RS payloads/metric handoffs, consumed by the planned protocol `SheafState`. | The persistent checkpoint store, the finalized `SheafBlock`, or an already implemented lifecycle state machine. |
| `TaskSheaf` | Planned Paper 2 term; no Lean definition yet. | A cellular sheaf over a finite execution slice, with stalks of admissible protocol decisions/evidence. | The Paper 1 HCP sheaf, a quorum certificate, or finality by itself. |
| `degreeOneLaplacian` / (Delta_1) | Current Lean identifier. | The true Hodge operator (delta_0delta_0^ast+delta_1^astdelta_1) on (C^1). | The normalized residual projector or network graph Laplacian. |
| `kernelNormalizedDegreeOneLaplacian` | Current Lean identifier. | (I-P_{\ker\Delta_1}), sharing (Delta_1)'s kernel but generally not its scale or spectrum. | The true Hodge (Delta_1) without a flat-positive-spectrum hypothesis. |
| `networkLaplacian0` | Planned protocol term; no Lean definition yet. | Optional degree-zero graph/connectivity operator used by protocol policy. | Paper 1's hidden degree-one Hodge operator. |

The exact (C^1) payload determines a degree-zero opening only modulo
`ker δ₀`:

\[
a-a'\in\ker\delta_0
\quad\Longleftrightarrow\quad
\delta_0a=\delta_0a'.
\]

Accordingly, active text must state binding to the exact (C^1) value and its
snapshot. A claim that the coboundary alone uniquely binds the chosen (C^0)
message requires an additional gauge/reference anchor.

## Verified Categorical Register

This register owns the status of the objects and arrows used in categorical
diagrams. [`CATEGORICAL_ARCHITECTURE.md`](CATEGORICAL_ARCHITECTURE.md) is the
derived relationship view; it must not introduce a stronger status than the
rows below. The cross-language
[`SEMANTIC_PARITY_QUEUE.md`](SEMANTIC_PARITY_QUEUE.md) separately tracks whether
Python and Rust artifacts refine these Lean meanings.

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
| Root-level `Fibration` in `lean/Hardness.lean` | Current categorical structure. | A category over a base equipped with a bundled Grothendieck-fibration instance. Its tagged-copy lemmas are not yet an adapter to `HCPBridge.Realization`; the generic name should be narrowed if this surface is retained. |
| `HCPBridge.Observation` | Current Lean abbreviation. | The public pair `(p, b)` of classifier value and raw cochain. |
| `HiddenHodgeWitness` | Current Lean structure. | A private representative `x` satisfying `classifier(x) = p` for a public observation. |
| `SheafStateSnapshot` and `AcceptedCommittedOneCochain` | Current Lean interface objects in `lean/Sheaf/Commitment.lean`; concrete byte/hash refinement remains pending. | An immutable sheaf-bound snapshot handle and an accepted exact `C¹` payload bound to it. |
| `OracleEta1`, `OracleEta2`, `OraclePipeline` | Current proposition-bearing protocol interfaces in `lean/Axioms/OracleModality.lean`. | They name oracle/node obligations. Despite historical comments, Lean does not define source/target categories, functors, or natural transformations for them. |
| `LedgerState` | Current Lean structure in `lean/Chain.lean`. | A ledger state acted on by explicit update functions. No categorical colimit or universal property is formalized. |
| `TaskSheaf` | Planned Paper 2 object; no Lean definition. | A possible sheaf over a finite execution slice. It is not the Paper 1 HCP sheaf, a quorum certificate, or finality. |

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
| Historical `η₁`, `η₂` diagrams | Interface-only analogy around `OracleEta1` and `OracleEta2`. | Do not call these natural transformations until categories, functors, components, and naturality laws are supplied. |

## Ownership Layers

| Layer | Meaning | Examples |
|-------|---------|----------|
| Theorem-owned | Lean proves the statement directly. | `Heyting3` residuation, Hodge/CVP statements, spectral classification lemmas |
| Interface-owned | Lean names the obligation; implementations supply witnesses or evidence. | hidden fibration assumptions, oracle modality, stage admissibility |
| Runtime-owned | Python/Rust computes or verifies concrete data. | Laplacian construction, spectral gaps, Betti numbers, oracle classification |
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
| Python/Rust are runtime-owned until bridged by parity tests or extraction. | Lean currently verifies the whole implementation end to end. |

This follows the same discipline as semantic-accounting approaches to large
formal catalogs: coverage, executable semantics, extensional semantics, and
runtime ownership should be tracked separately rather than collapsed into one
badge.
