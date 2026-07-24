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

## State and content addressing

The original useful role of `SheafState` is a **volatile per-commit projection
state bus**. It carries the current typed payload/certificate chain for one
accepted cochain and one witness-local projection run. The current Python class
is legacy because it later accumulated accounts, economics, mempool, and
audit-log duties that belong in separate ledger/node state.

`SheafStateSnapshot` is the immutable input context fixed before the projection
chain starts. It carries the accepted cochain's sheaf context plus explicit
canonical-encoding and root-binding obligations. A concrete refinement of
those obligations is still pending. Its content root must bind at least:

- schema and coefficient-domain identifiers;
- canonical cell identities and ordering;
- signed incidences;
- stalk dimensions and restriction-map commitments;
- the operator degree/family and public parameter set.

After the exact `C^1` commitment is accepted and bound to that snapshot, the
protocol initializes both a fresh volatile `SheafState` and an empty/open
`SheafBlock` bound to the same context. Each projection checkpoint advances
the state bus and atomically writes its newly derived public artifact and
already-proved certificate into the appropriate stage-labelled block slot
exactly once:

```text
accepted exact C1 + snapshot
  -> initialize volatile SheafState + open SheafBlock
  -> write Plucker/cochain binding
  -> write projected plane
  -> write canonical RS received word/target
  -> write hard-gate evidence
  -> write assembled-projection naturality
  -> write far-region witness
  -> seal SheafBlock
  -> wipe SheafState
```

This protocol layer follows the nested Paper 1 proof objects
`PluckerCochainState -> CochainPlaneState -> StateBus` and then
`HardGateEvidenceRecord -> NaturalityGateEvidenceRecord ->
CalibratedFinalEvidenceRecord`. It stores those outputs; it does not recompute
their mathematical checks.

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
sealed final SHA-256 root is eligible for the main-chain anchor. `SheafState`
is wiped only after the final block write and seal succeed atomically.

A topology hash may be useful metadata, but it is not by itself a full
snapshot commitment. Storage realizes canonical bytes, content lookup,
checkpoint writes, persistence, atomic updates, and hash revalidation on load.
A database is not itself a cellular sheaf, and hash equality is not a
naturality square.

## Paper 2 and protocol separation

The safe one-way dependency is

```text
Paper 1 cellular/Hodge mathematics
        -> exact C^1 and projection evidence
        -> immutable SheafStateSnapshot input binding
        -> volatile checkpointed SheafState
        -> persistent open SheafBlock checkpoint writes
        -> sealed SHA-256-addressed SheafBlock
        -> SheafState wipe
        -> Paper 2 validity/admissibility transition
        -> authenticated weighted quorum machinery
        -> locking, finality, and liveness (separate obligations).
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
