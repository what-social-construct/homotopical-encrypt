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
| `CellularSheaf` | Current Lean identifier. | Paper 1 finite (0/1/2)-cell sheaf with real-linear stalks and face-to-coface maps. | The mutable chain state or a protocol execution graph. |
| `SheafState` | Planned protocol term; the current Python class is legacy, not canonical. | Future whole-system state joining topology/sheaf data, commitments, evidence handles, and ledger coordinates. | A global section merely by virtue of storing one value per vertex. |
| `SheafStateSnapshot` | Current Lean interface object; concrete encoding/hash refinement is pending. | Abstract immutable snapshot handle carrying a 32-byte root, topology tag, and explicit canonical-encoding/root-binding obligations. Exact-cochain binding is specified; evidence binding is pending. | A proved canonical byte encoding, a second state model, or the mutable ledger before/after root. |
| `CellularSheaf.IsGlobalSection` | Current Lean identifier; overloaded `Proximity.GlobalSection` names remain a migration item. | A degree-zero stalk assignment satisfying every restriction equation, equivalently (delta_0x=0) in the linear model. | An arbitrary vertex assignment, account table, block, or accepted degree-one cochain. |
| `AcceptedCommittedOneCochain` | Current Lean identifier. | The committed (C^1) payload (b=delta_0a), bound to one `SheafStateSnapshot`; `IsExactOneCochain` names the underlying geometric property. | A degree-zero global section or a uniquely determined opening (a). |
| `HasPathSpace.Path x y` | Current Lean interface type; no concrete path-space instance yet. | A typed path witness from representative `x` to representative `y`, intended to remain private at the protocol boundary. | A sampled matrix interpolation, equal public classifier values, or equality of a finite invariant tuple. |
| `PathEquivalent x y` | Current Lean identifier. | Mere inhabitation of `HasPathSpace.Path x y`. | A concrete topological path model or a proved equivalence criterion for runtime objects. |
| `PublicClassifier` / `PublicFiber` | Current Lean identifiers. | The public classifier map and the fiber over one public class value. | A path component. Lean currently proves path-to-same-class consequences only under an explicit path-respecting hypothesis; it does not prove the converse. |
| `Proximity.Gates.Projection.StateBus` | Current Lean proof object; runtime reset/finalization is pending. | One witness-local chain of already-checked projection certificates. | Persistent `SheafState` or an already implemented lifecycle state machine. |
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
