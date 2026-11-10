# Hidden Hodge targets and discrete closest vectors

This entry covers seven selected result groups from *Homotopical Encryption:
Hidden Hodge Operators and the Harmonic Cochain Problem*. It proves finite
Hodge decomposition and recovery, a discrete closest-vector comparison, and
finite signed-incidence cellular examples in which one public observation has
different hidden harmonic targets. It also records the limits of an
exact-component observation.

The post-conclusion parity appendix separates main statement groups,
supporting declarations, and definitions/proof boundaries into three tables.
It records all 38 selected theorems and canonical objects; the mathematical
body has no Lean file or declaration lists.

The manuscript introduces homotopy equivalence, the public classifier and
cellular/Hodge primitives in §2 before defining the public observation, hidden
witness and HCP; computational scope is in §2.3. The cellular example is
developed in §3.5, and the CVP comparison is the final main section before §4
concludes. Paper 2 owns concrete cochain commitments, protocol construction
and visibility. Paper 3 introduces the projective projection chain and owns
coding and quantitative proximity. Shared definitions retain their canonical
owners.

[Challenge](Challenge.lean) gives independent mathematical definitions using
Mathlib imports only. [Solution](Solution.lean) identifies those presentations
with the canonical project objects and reuses their proofs through explicit
adapters. [Comparator configuration](comparator.json) selects **38 theorems**:
**18 manuscript-facing declarations** and **20 supporting declarations**. These
are coverage counts, rather than a count of independent research results.
Five canonical proof anchors support these selections without adding configured
targets. There are no
definition holes. The two pure finite-product helpers
`HomotopicalEncryption.Helfer.contextObject` and `HomotopicalEncryption.Helfer.contextMap` are independently
restated under their canonical names in the Challenge. They retain their
ordinary categorical meanings.

In the crosswalk, `E` means `HomotopicalEncryption.Palomar.PaperOne`, `CS` means
`E.CellularSheaf`, `HB` means `E.HCPBridge`, and `AF` means `E.AxisFamily`.
The source labels refer to the
[versioned manuscript](https://github.com/what-social-construct/homotopical-encrypt/blob/fc69e4c256206946991ae45770f187dcf4cf9cef/papers/paper1/main.tex).
Canonical names below belong to the implementation, outside the entry namespace.

| Group / manuscript source | Entry declarations and mathematical content | Canonical proof owners |
| --- | --- | --- |
| P1-S01 · §2 `prop:hodge-decomposition`; §3.3/appendix | `E.Hodge_Decomposition_Theorem`, `E.Hodge_Decomposition_unique`, `CS.HodgeEncryptedCochain.harmonicOneProjection_observed`, `CS.HarmonicLatticePresentation.decodeCoefficients_encrypt`: orthogonal decomposition with unique components and private recovery. | [Hardness](../../Hardness.lean), [Sheaf/Hodge](../../Sheaf/Hodge.lean), [Sheaf/CoefficientRecovery](../../Sheaf/CoefficientRecovery.lean); the latter two owners use namespace `HomotopicalEncryption.Sheaf.CellularSheaf`. |
| P1-S02 · §3.2 `prop:hcp-to-cvp` | `E.exists_matrix_ker_eq_range`, `E.Hodge_GeneratedSubspace_Reduction_Proof`: realize a field-linear image as a matrix kernel and obtain the stated image-membership consequence for a displayed-operator solver. | The same two unprefixed declaration names in [Hardness](../../Hardness.lean). This result concerns the linear image. |
| P1-S03 · §3.3 `prop:hodge-projection-is-cvp` | `E.squaredDistance_projection_decomposition`, `E.solution_iff_projectedTarget`: projection preserves exactly the discrete CVP answers when the supplied lattice lies in the projected subspace. | `HarmonicCVPBridge.squaredDistance_projection_decomposition` and `HarmonicCVPBridge.solution_iff_projectedTarget` in [Hardness](../../Hardness.lean). |
| P1-S04 · §3.3/appendix, cellular specialization | `E.concreteSheafHCP_CVP_solution_iff_message`, `E.concreteSheafHCP_CVP_existsUnique`: an actual encrypted cellular sample has the presented harmonic message as its unique discrete CVP answer. | The same unprefixed declaration names in [Hardness](../../Hardness.lean), using a supplied integral harmonic-lattice presentation. |
| P1-S05 · §3.4 `prop:cvp-insufficient`; §3.5 `prop:cellular-axis-ambiguity`, `cor:lattice-member-separation` | `HB.operativeTargets_ne_of_kernelSeparation`, both `HB.cvpOracle_insufficient_*` declarations, `AF.cellular_axis_ambiguity`, `AF.cvp_oracle_insufficient`: general conditional separation and its constructed cellular instance; the final corollary combines this group with P1-S04. | `HomotopicalEncryption.HCPBridge` in [Hardness](../../Hardness.lean); `HomotopicalEncryption.HCP.AxisFamily.shared_observation_distinct_nonzero_targets`, `cvp_oracle_insufficient`, and the derived `cvp_oracle_recovers_operative_component` / `cvp_known_member_hidden_member_separation` in [HCP/AxisFamily](../../HCP/AxisFamily.lean). |
| P1-S06 · §3.5, weighted integral example | `AF.weighted_axis_recovery_obstruction`: coefficients two and one share the observation at `b=(1,2)`; one public coefficient decoder cannot recover both, while each private lattice has its own unique CVP answer. | `HomotopicalEncryption.HCP.AxisFamily.weighted_public_observations_eq`, `no_exact_encoded_message_decoder`, `weighted_cvp_solution_iff_operativeTarget`, `weighted_cvp_existsUnique` in [HCP/AxisFamily](../../HCP/AxisFamily.lean). |
| P1-B01 · §2 `prop:exact-component-obstruction` | `CS.HodgeEncryptedCochain.not_residual_norm_factors_exactComponent`, `not_far_preserving_exactComponent`: an allowed nonzero coexact direction prevents the full orthogonal residual from descending to the exact component. | Same terminal names under `HomotopicalEncryption.Sheaf.CellularSheaf.HodgeEncryptedCochain` in [ObservationQuotient](../../Sheaf/ObservationQuotient.lean). |

The Hodge statements retain the complex equation and the true cellular
degree-one operator. Coefficient recovery uses the supplied integral harmonic
lattice and is noncomputable. The discrete comparison retains an explicit
lattice, its inclusion in the harmonic subspace, and orthogonal projection.
The general ambiguity statements retain closed-test invariance, a kernel
separation witness, and the correct-oracle existence premise in the oracle
corollaries, with their stated uniform-solver quantifiers. They do not require
the optional reflection property below.

The final §3.5 corollary uses one fixed correct rank-one oracle
`CVP.Oracle Index (Fin 1)`: supplying either actual lattice recovers its
operative component, while the same oracle and shared public observation
cannot select every compatible hidden target. The canonical family obstruction
`HomotopicalEncryption.HCPBridge.no_solver_exactOnOperativeTarget_on_family` holds for any
compatible family containing the two unequal targets, with auxiliary input
fixed. It imposes no family-cardinality or running-time premise. This corollary
is derived from P1-S04/P1-S05 and adds no configured submission targets.

In [HCP](../../HCP.lean), `HomotopicalEncryption.HCPBridge.ReflectsHomotopyEquivalence` is an
optional property of the existing `Realization`. Together with closed-test
invariance, `samePublicClass_iff_homotopyEquivalent` and
`publicClassOf_eq_setOf_homotopyEquivalent` identify label equality with typed
homotopy equivalence and the existing public-class set with that homotopy class.
`HomotopicalEncryption.HCP.AxisFamily.reflectsHomotopyEquivalence` proves this profile for
the admitted `Fin 2` family; its `theory_eq_iff_homotopyEquivalent` now uses
the generic API, despite the different operative embedded kernels. This
classifies admitted representatives; the matrix-level `publicProjection`
agrees with their classifier on realized operators. The family uses actual
integral cellular sheaves in the declared finite signed-incidence model and
the nonzero-cohomology tests of the bounded-below real cochain model.
`Realization` and its adapters retain their original fields and assumptions.
The formalized semantic fragment is homological; full first-order semantics
is outside this entry.

These results give exact mathematical recovery and observation obstructions.
They do not establish an asymptotic CVP-hardness reduction, distributional
encryption security, equality of larger released storage views, digest
inversion, an efficient decoder or a concrete secure protocol. Coding and
radius theorems belong to Paper 3 and are cited only at the application boundary.
Novelty and priority are not asserted by this entry.

The Challenge has **20 intentional theorem placeholders** for comparison;
Solution and the retained definitions contain no proof holes. The renamed,
38-target entry awaits fresh compilation, statement/definition comparison,
selected dependency audit and kernel replay.

Historical checks apply to their recorded inputs. The earlier 46-target entry
passed local Challenge/Solution builds (**3,516/3,666 jobs**), comparison and
Lean/NanoDa replay with the macOS sandbox diagnostic. Protected comparison,
provenance and Lean/NanoDa/con-ron subsequently passed for
[public snapshot `66e1ad2`](https://github.com/what-social-construct/homotopical-encrypt-formalizations/commit/66e1ad2cb726d3dd816461e4f76b1d0d9147a46d),
[run `42729947447`](https://github.com/what-social-construct/homotopical-encrypt-formalizations/actions/runs/42729947447).
Those reports do not certify the current namespace or reduced selection.
The 975-report, 124-report and five-endpoint semantic audits also retain their
original scopes. A fresh exact-commit protected preflight remains required.
Declaration counts do not measure mathematical novelty.

From the repository's `lean/` project, the entry modules are
`Palomar.PaperOne.Challenge` and `Palomar.PaperOne.Solution`; its configuration is
`Palomar/PaperOne/comparator.json`. Comparator is bundled with the pinned Lean
4.35.0 toolchain. Protected comparison requires the supported Linux sandbox.
The earlier public snapshot has the protected report linked above; no registry
submission or registration has been made. The revised candidate inherits no
exact-commit preflight result merely from retaining the same Lean statements.
[Metadata](formalization.yaml) records the source, scope and production account.
The repository and this entry use the [MIT licence](../../../LICENSE).
