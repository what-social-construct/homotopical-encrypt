# Categorical Architecture

This document fixes the current categorical object map. It is deliberately
smaller than the archived design narrative: categorical analogies appear here
only when the required objects and morphisms have been named precisely.

The canonical terminology is in
[`SEMANTIC_OWNERSHIP.md`](SEMANTIC_OWNERSHIP.md). Mathematical implementation
status is tracked by [`SEMANTIC_PARITY_QUEUE.md`](SEMANTIC_PARITY_QUEUE.md), and
protocol status by [`PROTOCOL_PARITY_QUEUE.md`](PROTOCOL_PARITY_QUEUE.md).

## Paper 1: finite cellular-sheaf geometry

Let `P_X` be the face poset of a finite oriented cell complex through degree
two. The Paper 1 cellular sheaf uses the face-to-coface convention

```text
F_HCP : P_X -> FinVect_R

vertex stalk --restriction--> edge stalk --restriction--> face stalk
```

Functorial composition along incident flags, together with the cellular
boundary-square equation, induces the concrete cochain complex

```text
C^0(X; F_HCP) --delta0--> C^1(X; F_HCP) --delta1--> C^2(X; F_HCP)
                                      delta1 o delta0 = 0
```

The operative Paper 1 Hodge operator is the degree-one operator

```text
degreeOneLaplacian = delta0 o delta0* + delta1* o delta1 : C^1 -> C^1.
```

Its kernel is the harmonic subspace. The kernel-normalized operator
`I - P_ker` has the same kernel, but is not generally equal to the Hodge
operator and need not have the same positive spectrum.

A degree-zero global section is exactly a compatible stalk assignment:

```text
GlobalSection(F_HCP, a)  iff  delta0(a) = 0.
```

An accepted cochain commitment instead carries an exact degree-one value
`c = delta0(a)`. It is therefore a cocycle, but it is not a global section.
The value `c` determines its opening `a` only modulo `ker(delta0)`.

## State and content addressing

`SheafState` is the existing whole-system state bus. It may contain topology,
identity, commitment, evidence, and ledger coordinates; merely storing one
value per vertex does not make the bus a global section.

`SheafStateSnapshot` is an immutable, canonically encoded view of the
sheaf-relevant part of that bus. Its content root must bind at least:

- schema and coefficient-domain identifiers;
- canonical cell identities and ordering;
- signed incidences;
- stalk dimensions and restriction-map commitments;
- the operator degree/family and public parameter set.

The accepted exact `C^1` payload, projected plane, and proof-carrying evidence
must refer to the same snapshot root. A topology hash may be useful metadata,
but it is not by itself a full snapshot commitment. Mutable pre-state and
post-state ledger roots remain distinct from the immutable sheaf snapshot root.

Storage realizes canonical bytes, hashes, indexing, persistence, and atomic
updates. A database is not itself a cellular sheaf, and hash equality is not a
naturality square.

## Paper 2: task sheaves over execution slices

Paper 2 may construct a separate task sheaf over a finite execution slice of
local process views. This reuses the cellular indexing idea without identifying
the task sheaf with `F_HCP`:

```text
SheafState
   |
   | freeze / content-address
   v
SheafStateSnapshot --accepted exact C^1 + evidence--> execution slice
                                                       |
                                                       v
                                                    TaskSheaf
```

Task-sheaf stalks contain locally admissible decisions and their evidence. A
task-sheaf global section is a compatible decision assignment on the selected
slice. It is not, by itself, an authenticated quorum certificate, Byzantine
agreement, liveness, or finality.

If the task stalks are set- or cset-valued, subtraction, kernels, and Hodge
operators are unavailable until an explicit linearization and decoding theorem
are supplied. Paper 1's real-linear Hodge theorems therefore do not transfer to
the task sheaf merely by sharing the word “sheaf.”

## Protocol separation

The current one-way dependency is:

```text
Paper 1 cellular/Hodge mathematics
        -> exact C^1 and projection evidence
        -> immutable SheafStateSnapshot binding
        -> Paper 2 validity/admissibility transition
        -> authenticated weighted quorum machinery
        -> locking, finality, and liveness (still separate obligations)
```

The three operator names are reserved:

- `degreeOneLaplacian` for Paper 1's hidden Hodge operator on `C^1`;
- `kernelNormalizedLaplacian` for `I - P_ker`;
- `networkLaplacian0` for an optional degree-zero protocol connectivity
  operator.

No spectral quantity is called stake, consensus, or finality without a
separate protocol definition and theorem.
