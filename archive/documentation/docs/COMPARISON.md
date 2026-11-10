# Current Object Comparison Workbench

This is a working comparison table, not a source of protocol law. The original
long-form notebook is preserved at
[`archive/COMPARISON.md`](archive/COMPARISON.md).

The point of the current comparison is to keep objects with different jobs
separate.

| Concern | Current Homotopical Encryption object | What it does not imply |
|---|---|---|
| Hidden mathematical instance | hidden representative `x` in the public classifier fiber `A_alpha` | that the public label identifies one operator |
| Operative geometry | `degreeOneLaplacian` on `C^1` | network consensus or a degree-zero state equation |
| Kernel-only model | `kernelNormalizedLaplacian = I - P_ker` | equality with the Hodge operator or equality of positive spectra |
| Public cochain artifact | accepted exact `C^1` value `c = delta0(a)` | a unique degree-zero opening `a` |
| Context binding | exact payload and evidence bound to one `SheafStateSnapshot` root | that a short topology tag commits all restriction/state data |
| Whole-system state | `SheafState` | a global section merely because it stores vertex-indexed values |
| Local logical judgment | collapsed Heyting-valued oracle result | an authenticated vote or finality certificate |
| Task-sheaf global section | coherent decision assignment on a finite execution slice | quorum intersection, Byzantine agreement, or liveness |
| Proof of Value | proof-carrying validity/admissibility evidence | scarce-resource admission, leader election, ordering, or Sybil resistance |
| Quorum safety core | authenticated strict weighted quorum plus intersection theorem | locking, view/round change, liveness, or full finality |

## Consensus comparison

The earlier working table compressed several distinct stages. The corrected
version is:

| Standard consensus concern | Project object or open obligation |
|---|---|
| Proposal validity | exact-cochain, projection, topology/snapshot, freshness, conservation, and evidence gates |
| Public truth classification | Heyting-valued oracle judgment, collapsed to an explicit protocol action |
| Validator admission | separate registered committee/admission and scarce-resource assumption |
| Voting | authenticated votes bound to committee, epoch, round, phase, block, parent, state, snapshot, cochain, and evidence roots |
| Quorum safety | strict weighted threshold and quorum intersection |
| Equivocation safety | no-double-vote premise now; explicit evidence and slashing transition still required |
| Locking / round change | pending Paper 2 state machine |
| Finality | pending promotion rule built on quorum certificates and locks |
| Liveness | pending network/timing and honest-participation assumptions |
| Spectral convergence | possible analytical tool for a separately defined process, not finality by nomenclature |
| Coregulator | typed predict/observe/update component still to be specified, not identified with `delta0*` |

Proposals may contain coboundary-derived evidence and may be checked locally,
but this does not eliminate the agreement problem when honest processes can
observe different valid proposals. Similarly, meet in a Heyting algebra
combines truth values; it does not authenticate voters or replace a quorum
protocol.

## Sheaf comparison

Two sheaf contexts are intentionally distinct:

```text
F_HCP   : finite real-linear cellular sheaf used for C^0 -> C^1 -> C^2,
          the degree-one Hodge operator, HCP, and exact C^1 evidence.

F_task  : Paper 2 task sheaf over finite execution views, used to state
          compatibility of local decisions.
```

They may reuse generic cellular indexing infrastructure and may be related by a
realization map, but they do not share stalk semantics automatically.

## Commitment comparison

The public coboundary value has the algebraic law

```text
delta0(a + a') = delta0(a) + delta0(a').
```

It canonically commits the workflow to an exact `C^1` value once authenticated
and snapshot-bound. It does not make `delta0` injective:

```text
delta0(a) = delta0(a')  iff  a - a' is in ker(delta0).
```

Any hiding, collision resistance of a digest, unique-message binding after a
gauge anchor, zero knowledge, or post-quantum security claim belongs to a
separately specified cryptographic construction and security game.
