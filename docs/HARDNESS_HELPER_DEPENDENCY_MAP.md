# HCP recovery and CVP dependency map

This map records the proved mathematical dependencies of Paper 1. The
[submission crosswalk](../lean/Palomar/PaperOne/README.md) identifies the
46 configured declarations. Protocol and runtime obligations are separate;
they are not premises of the recovery obstructions below.

## Objects and semantic premises

The generic interface is in [HCP.lean](../lean/HCP.lean), under
`Hcrypt.HCPBridge`.

| Object or premise | Role |
| --- | --- |
| `Realization` | Attaches a semantic interpretation and an operative matrix to each admitted representative. Its public classifier factors through the declared closed theory and agrees with the matrix-level public projection. |
| `Helfer.ClosedFormulaInvariance sem` | Makes typed semantic equivalence imply equality of the chosen closed theories, hence equality of public class values. This is explicit input to the generic semantic comparison. |
| `KernelSeparationWitness` | Supplies two semantically equivalent admitted representatives and one cochain harmonic for the first operator but not the second. Equivalence alone does not assert different kernels. |
| `HiddenHodgeWitness X observation` | Binds a representative to one public observation `(class, cochain)`. Its operative target is the actual orthogonal projection for that representative's matrix kernel. |

The generic statements do not consume `CartesianLiftingPrinciple`,
`SigmaPiCoherent`, or the full `HelferFOLWellFormed` bundle in
[Axioms/HelferFOL.lean](../lean/Axioms/HelferFOL.lean). The declared
closed-test invariance premise is the semantic input they require.

## Proof dependencies

1. **Hodge decomposition and valid samples.**
   [Sheaf/Hodge.lean](../lean/Sheaf/Hodge.lean) supplies the actual cellular
   degree-one operator and its orthogonal decomposition.
   [Sheaf/HarmonicLattice.lean](../lean/Sheaf/HarmonicLattice.lean) equips an
   integral harmonic message with exact/coexact noise. The noise is orthogonal
   to the harmonic subspace, so harmonic projection recovers the message.
   With a supplied `HarmonicLatticePresentation`,
   `solution_cvpInstance_iff_eq_point` and `existsUnique_solution_cvpInstance`
   identify that message as the unique closest point in the presented lattice.

2. **Linear-image realization.**
   `exists_matrix_ker_eq_range` and
   `Hodge_GeneratedSubspace_Reduction_Proof` in
   [Hardness.lean](../lean/Hardness.lean) realize a field-linear image as a
   matrix kernel. A solver returning a harmonic vector then returns an element
   of that image. This concerns the real or field-linear span, not the discrete
   integer lattice, and is not a discrete-CVP reduction.

3. **Discrete CVP comparison.**
   [CVP.lean](../lean/CVP.lean) defines integer lattice points, closest-vector
   correctness and the external `HardnessAssumption` schema. Given a supplied
   lattice inside a supplied harmonic subspace,
   `HarmonicCVPBridge.squaredDistance_projection_decomposition` and
   `HarmonicCVPBridge.solution_iff_projectedTarget` in `Hardness.lean` prove
   that orthogonal target projection preserves the discrete minimizers. The
   projection does not perform the remaining lattice search or recover a hidden
   member from its public class.

4. **Generic exact-recovery obstruction.**
   In `Hardness.lean`, `operativeTargets_ne_of_kernelSeparation` consumes a
   `Realization`, closed-test invariance and a `KernelSeparationWitness` to
   construct two different operative targets at the same public observation.
   `no_solver_exactOnOperativeTarget_on_family` then needs only two witnesses
   bound to that observation, their membership in a compatible family, and
   unequal targets. One output cannot equal both targets. Auxiliary input,
   including any oracle, is fixed across members. Any containing compatible
   family inherits the obstruction; no family-cardinality or running-time
   assumption is needed. The generic correct-CVP-oracle corollaries additionally
   retain their explicit oracle-existence premise.

5. **Actual finite cellular family.**
   [Sheaf/HCPAxisFamily.lean](../lean/Sheaf/HCPAxisFamily.lean) constructs two
   integral cellular sheaves with actual Hodge operators and explicit harmonic
   lattices `Ze₁` and `Ze₀` in the common real cochain coordinates. Their valid
   samples have the same cochain `(1,1)` and different nonzero harmonic targets.
   [Helfer/CochainModel.lean](../lean/Helfer/CochainModel.lean) interprets the
   actual complexes in the bounded-below real cochain Quillen model. Weak
   equivalences are quasi-isomorphisms, the required cofibrancy and fibrancy
   are established, and the integer-indexed nonzero-cohomology tests are proved
   invariant. The actual chain isometry therefore gives the common public
   theory used by [HCP/AxisFamily.lean](../lean/HCP/AxisFamily.lean). This is
   the stated homological fragment; full Helfer first-order semantics remains
   external.

6. **Supplied member versus hidden member.**
   In `HCP/AxisFamily.lean`, `cvp_oracle_recovers_operative_component` takes
   one fixed correct `CVP.Oracle Index (Fin 1)`. Supplying either actual
   rank-one lattice to that oracle recovers its operative harmonic component
   at the shared valid sample.
   `cvp_known_member_hidden_member_separation` bundles that recovery with
   impossibility of a public solver exact for every compatible hidden witness
   at the same observation, using the same fixed oracle. It reuses the generic
   family obstruction. The weighted example separately makes the chosen
   integer coefficients differ, as two versus one at cochain `(1,2)`.

## Submission correspondence and limits

The final manuscript corollary `cor:lattice-member-separation` in §3.5 is a
consequence of the existing P1-S04 sample/CVP comparison and P1-S05 ambiguity
groups. Its canonical rank-one oracle theorems above are not additional
configured submission targets: the comparator still selects 46 declarations.

The strict comparison concerns supplied information and exact recovery. It is
not a polynomial-time hardness hierarchy, a Turing nonreducibility result, a
reduction of arbitrary discrete CVP to HCP, or a class-size probability bound.
`CVP.HardnessAssumption` remains an external complexity schema; it is not used
to prove the finite ambiguity example. Neither that example nor the generic
obstruction establishes distributional encryption security or agreement of
larger released storage views.

Runtime encodings, hashing, proof verification, consensus and storage
admissibility retain their own obligations; see
[TRUST_BOUNDARIES.md](TRUST_BOUNDARIES.md). They are not consequences of the
linear algebra or auxiliary-oracle obstruction.

## Verification status

The focused `HCP.AxisFamily` build passed 3,581 jobs, and the three Solution
entries passed a 3,759-job build after the canonical additions. A fresh combined
dependency audit is pending.
