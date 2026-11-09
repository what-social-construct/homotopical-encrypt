# Palomar submission preparation: Papers 1 and 3

Preparation note begun 2026-11-05; manuscript-led selection updated 2026-11-08. The intended public scope is the Lean development
and corresponding manuscripts. This note creates no submission, registration,
release, Comparator configuration, or successful verification record.

The user reports that **Jacobian Paper I passed the machine checks and is
already under Palomar review**. They suspect that docstrings or broader
documentation may affect the informal review; no cause has been established
here. This note does not diagnose that review or claim to have inspected its
reviewer feedback. Use Jacobian's package conventions as a reference without
changing or resubmitting that work. Its older reference-guide wording predates
the user's reported submission/review state.

## Reference package and proposed entries

The reference is the public
[Jacobian collision-geometry release](https://github.com/what-social-construct/jacobian-collision-geometry/tree/67872a1b3e6c6a85e6c93ac0079b023282bc1510),
at commit `67872a1b3e6c6a85e6c93ac0079b023282bc1510`, using Lean 4.35.0.
Its [submission guide](https://github.com/what-social-construct/jacobian-collision-geometry/blob/67872a1b3e6c6a85e6c93ac0079b023282bc1510/CollisionIdeals/Palomar/README.md),
[paper entry directories](https://github.com/what-social-construct/jacobian-collision-geometry/tree/67872a1b3e6c6a85e6c93ac0079b023282bc1510/CollisionIdeals/Palomar),
and [semantic crosswalk](https://github.com/what-social-construct/jacobian-collision-geometry/blob/67872a1b3e6c6a85e6c93ac0079b023282bc1510/SEMANTIC-PARITY.md#palomar-submission-surface-crosswalk)
record the reusable conventions. The frozen reference package and the user's
current review status are separate facts.

| Entry | Manuscript and implementation | Proposed wrapper module family |
|---|---|---|
| Paper 1 | [Hidden Hodge operators and HCP](../papers/paper1/README.md); [HCP](../lean/HCP.lean), [Hardness](../lean/Hardness.lean), [Sheaf](../lean/Sheaf.lean), [Helfer](../lean/Helfer.lean) | `Palomar.PaperOne.Challenge` and `Palomar.PaperOne.Solution` |
| Paper 3 | [Capacity-radius proximity](../papers/proximity-prize/README.md); [ProximityPrize](../lean/ProximityPrize.lean) | `Palomar.PaperThree.Challenge` and `Palomar.PaperThree.Solution` |

These are **two proposed entries**, each with its own Comparator configuration
and metadata. Paper 2 now has a [working Markdown draft](../papers/paper2/DRAFT.md)
and [scope/specification notes](../papers/paper2/SCOPE.md), but no TeX manuscript
or PDF; it is not a third manuscript submission here.
Shared protocol/storage work may be described as supporting infrastructure
without advertising a completed secure protocol.

## Slim per-entry release scope

The user's current release preference is a **slim, separately scoped package
for each entry**. This is the packaging decision for this repository, not an
explanation of Jacobian's review or a newly verified Palomar rule.

Each proposed entry should contain:

- The Lean implementation files required by that entry's selected Solution,
  with their actual transitive proof/import closure and pinned build inputs.
  Prefer the specific implementation modules the proof needs; an umbrella
  import is not required merely because it was used for development checks.
- Its small independent `Challenge.lean`, distinct `Solution.lean`, Comparator
  configuration, metadata and a short README stating the exact submitted scope.
- A concise statement-to-source-to-manuscript crosswalk and the corresponding
  manuscript evidence needed to assess those statements and their hypotheses.
  Preserve the licence and necessary source attribution.

Exclude working archives, plans, architecture wishlists, unrelated proof
families and other-paper claim surfaces from the entry release. This planning
note itself is not part of that slim review surface. Supporting shared Lean
files belong only where the selected proof closure requires them; their
presence does not advertise every claim elsewhere in the development.

Align every retained informal surface with the actual selected theorem:
README, metadata, Challenge/Solution comments, implementation docstrings,
crosswalk and manuscript excerpts. State the source object, operator, metric
normalization, quantifier order, radius endpoints and explicit hypotheses
consistently. Keep conditional mathematical recovery, native modular radius
results and cryptographic security claims separate. Slimming the package must
not hide a stronger advertised claim behind a smaller supporting theorem or
remove a limitation needed to understand the result.

The broader [Lean/manuscript public-review package](../PUBLIC_REVIEW.md) serves
a different purpose and includes cross-paper context. Its ZIP is neither the
slim per-entry release nor a Palomar submission. No slim entry, wrapper,
protected preflight or submission is created by this note.

## Selected manuscript statement surface — 2026-11-08

The manuscripts supply the main statements: Paper 1's existing named
propositions, especially the discrete CVP comparison and kernel ambiguity,
and Paper 3's nine named coding statements. The tables below select their
mathematical content for two entries. These IDs organize manuscript results; the uniqueness companion completes an
existing proposition. They are not already-created Comparator declarations.
Each future wrapper must state the complete indicated claim, using transparent
mathematical definitions in an independent Challenge and the existing proofs
in its Solution. Final protected comparison and entry-size checks remain work.

### Paper 1: CVP comparison and the constructed HCP family

The principal comparison has three connected parts: discrete minimizers are
preserved by harmonic projection for a supplied lattice inside the harmonic
space; actual cellular encrypted samples realize the corresponding unique CVP
answer; identical public HCP inputs can nevertheless require different hidden
operative targets, even when a correct explicit-lattice CVP oracle is supplied.
The latter uses the theorem's exact oracle-existence and uniform-solver
quantifiers. An unrestricted asymptotic CVP-hardness reduction or encryption
indistinguishability is not asserted by these statements.

| ID / manuscript statement | Selected mathematical content | Canonical implementation declarations |
|---|---|---|
| P1-S01 — §2.1, `prop:hodge-decomposition`; §3.3/appendix | Existence, orthogonality and uniqueness of the three Hodge components in finite real orthonormal coordinates, plus private recovery for actual cochains; coefficient recovery retains its supplied integral harmonic-lattice presentation and is noncomputable. | `Hodge_Decomposition_Theorem`; `Hodge_Decomposition_unique`; `Hcrypt.Sheaf.CellularSheaf.HodgeEncryptedCochain.harmonicOneProjection_observed`; `Hcrypt.Sheaf.CellularSheaf.HarmonicLatticePresentation.decodeCoefficients_encrypt` |
| P1-S02 — §3.2, `prop:hcp-to-cvp` | Every finite-dimensional field-linear generated subspace is a matrix kernel; the displayed-operator solver consequence concerns the linear image, separately from the integer lattice. | `exists_matrix_ker_eq_range`; `Hodge_GeneratedSubspace_Reduction_Proof` |
| P1-S03 — §3.3, `prop:hodge-projection-is-cvp` | For every explicit lattice Λ⊆W and every target/candidate, orthogonally projecting the target onto W preserves precisely the discrete CVP solutions. Keep the lattice inclusion and orthogonal-projection instance. | `HarmonicCVPBridge.squaredDistance_projection_decomposition`; `HarmonicCVPBridge.solution_iff_projectedTarget` |
| P1-S04 — §3.3/appendix, actual cellular specialization | For the actual cellular sample H.encrypt(z,noise), the CVP solution is exactly H.point(z), uniquely; retain H as a supplied harmonic-lattice presentation. | `concreteSheafHCP_CVP_solution_iff_message`; `concreteSheafHCP_CVP_existsUnique` |
| P1-S05 — §3.4, `prop:cvp-insufficient`; §3.5, `prop:cellular-axis-ambiguity` | The general separation theorem gives distinct targets, and its nontrivial cellular instance gives distinct nonzero targets at one public input. Both the manuscript soundness/exact-on-harmonics contract and its direct operative-target companion are retained. Retain the correct-CVP-oracle existence premise and the exact no-uniform-solver quantifiers. | `Hcrypt.HCPBridge.operativeTargets_ne_of_kernelSeparation`; `Hcrypt.HCPBridge.cvpOracle_insufficient_of_kernelSeparation`; `Hcrypt.HCPBridge.cvpOracle_insufficient_for_operativeTarget`; `Hcrypt.HCP.AxisFamily.shared_observation_distinct_nonzero_targets`; `Hcrypt.HCP.AxisFamily.cvp_oracle_insufficient` |
| P1-S06 — §3.5, weighted integral example | At common b=(1,2), the original integer coefficients differ (2 versus 1); no exact public coefficient decoder exists. For each private presentation the same actual sample has a unique CVP answer equal to its operative HCP target. | `Hcrypt.HCP.AxisFamily.weighted_public_observations_eq`; `Hcrypt.HCP.AxisFamily.no_exact_encoded_message_decoder`; `Hcrypt.HCP.AxisFamily.weighted_cvp_solution_iff_operativeTarget`; `Hcrypt.HCP.AxisFamily.weighted_cvp_existsUnique` |
| P1-B01 — §2, `prop:exact-component-obstruction` | The unrestricted exact-component view cannot retain the full residual/far region when a nonzero coexact direction is allowed. This does not prove wire factorization. | `Hcrypt.Sheaf.CellularSheaf.HodgeEncryptedCochain.not_residual_norm_factors_exactComponent`; `Hcrypt.Sheaf.CellularSheaf.HodgeEncryptedCochain.not_far_preserving_exactComponent` |
| P1-B02 — §6.2, `prop:plucker-recovery`; operative-observation appendix | Genuine full projective coordinates recover the subspace and its fixed-metric projector; operative-kernel identification additionally recovers the HCP target from b. Digest-only observations remain separate. | `Hcrypt.Proximity.GrassmannianPlucker.Concrete.recoverSubspace_frame`; `Hcrypt.Proximity.GrassmannianPlucker.Concrete.recoverHarmonicProjector_frame`; `Hcrypt.TCB.PluckerObservation.recover_eq_operativeHarmonicComponent` |

The concrete family uses actual integral cellular sheaves and the true
degree-one operators. Its public classifier is the full theory of the stated
nonzero-cohomology tests in the real cochain Quillen model: the declared
homological fragment of Helfer semantics. The same-object definitions,
`semanticEquivalence`, `theory_zero_eq_one` and actual operator identities
support the statements; they cannot be replaced by a constant mock classifier
or made conclusions of new assumptions. Full first-order semantics, equality
of larger released storage views, sampled secrecy, finite byte codecs and
complexity bounds remain separate.

P1-B01/B02 are explicitly named observation-boundary statements. The cited
canonical RS/MCA theorem and uninstantiated geometric far-separation profile
in §6 are supporting conditional manuscript material, outside this selected
HCP/CVP entry. Corresponding entry prose/excerpts must say so; no theorem at
that cited-axiom boundary is being selected as an axiom-free proof.

### Paper 3: nine original coding statements and bounded application

| ID / manuscript statement | Selected mathematical content | Canonical implementation declarations |
|---|---|---|
| P3-S01 — §3, plane/pair equivalence | The full two-coordinate plane is equivalent to the full interleaved pair carrier, preserving whole-symbol Hamming distance. The equivalence definition is an object owner, not a new research theorem. | `ProximityPrize.planePairEquiv`; `ProximityPrize.planePairEquiv_hammingDistance`; `ProximityPrize.planePairEquiv_relativeHammingDistance` |
| P3-S02 — §3, plane/line equivalence | All plane words correspond to all base/direction affine-line presentations; retain arbitrary base and direction. The transparent equivalence supplies the inverse laws. | `ProximityPrize.planeLineEquiv` |
| P3-S03 — §5, `thm:capacity-grid-exact` and endpoint fractional iff | For every finite positive interleaving width and 1≤k≤n, all words have capacity-grid list size at most choose(n,k), and the explicit received word attains it; retain the exact fractional-budget iff. | `ProximityPrize.ReedSolomon.Parameters.vectorListSizeBoundAt_capacityGrid`; `ProximityPrize.ReedSolomon.Parameters.capacityReceived_ballCardAt_eq_choose`; `ProximityPrize.ReedSolomon.Parameters.vectorFractionalListSizeBoundAt_capacityGrid_iff` |
| P3-S04 — §5, `thm:next-shell-lower` | The next-shell ball has at least \|F\|^m words, for every positive interleaving width, with positive length and the theorem’s degree conditions. | `ProximityPrize.ReedSolomon.Parameters.fieldCard_pow_le_nextShell_ballCardAt` |
| P3-S05 — §5, `thm:fractional-phase-split` | Retain all three budget regimes, the endpoint-safe grid endpoints and exact half-open real interval with excluded supremum/no maximum. The middle regime leaves its optimal smaller radius open. | `ProximityPrize.ReedSolomon.Parameters.vectorFractionalListPhaseSplit`; `ProximityPrize.ReedSolomon.Parameters.vectorFractionalListGridThreshold`; `ProximityPrize.ReedSolomon.Parameters.vectorFractionalListRealThreshold` |
| P3-S06 — §4 actual smooth family; §5, `cor:explicit-family-list` | For every u and positive width, the actual GaloisField(3,256·2^u) subgroup domain attains the 128-bit capacity list guarantee and exact grid/real thresholds, with no supplied realization or budget assumption. | `ProximityPrize.Capacity.SmoothQuarterFamily.rootUnit_order`; `ProximityPrize.Capacity.SmoothQuarterFamily.realized_fractionalListSizeBoundAt_capacity`; `ProximityPrize.Capacity.SmoothQuarterFamily.realized_listGridThreshold`; `ProximityPrize.Capacity.SmoothQuarterFamily.realized_listSafeRelativeRadii_eq_Ico`; `ProximityPrize.Capacity.SmoothQuarterFamily.realized_listRealThreshold` |
| P3-S07 — §6, `thm:pair-mca` | For every real radius and every fixed affine line, the same-set bad-challenge count is at most choose(n,k+1); include its fractional-error consequence, retaining 1≤k≤n. | `ProximityPrize.ReedSolomon.Parameters.badChallengeSetAt_card_le_choose_succ`; `ProximityPrize.ReedSolomon.Parameters.pairMCAErrorBoundAt_of_compressed_budget` |
| P3-S08 — §6, `cor:explicit-family-mca` | For every u and every real radius, the actual smooth family meets the 128-bit MCA target; its greatest safe count is the full length. | `ProximityPrize.Capacity.SmoothQuarterFamily.realized_pairMCAErrorBoundAt`; `ProximityPrize.Capacity.SmoothQuarterFamily.realized_pairMCAGreatestSafe_eq_length` |
| P3-S09 — §6, `thm:mca-boundary-threshold` | For the actual prime q=2^128+192513 and [4096,1024] domain: B(0)=1, B(1)≥2, greatest-safe/first-unsafe counts 0/1, exact real safe set [0,1/4096), excluded supremum and no maximum. Primality and root order are proved rather than supplied. | `ProximityPrize.MCA.BoundaryField.modulus_prime`; `ProximityPrize.MCA.BoundaryField.candidateRootUnit_order`; `ProximityPrize.MCA.BoundaryField.paperMCABadSpectrum_zero_eq_one`; `ProximityPrize.MCA.BoundaryField.two_le_paperMCABadSpectrum_one`; `ProximityPrize.MCA.BoundaryField.pairMCA_exact_128_bit_threshold`; `ProximityPrize.MCA.BoundaryField.pairMCA_safeRelativeRadii_128_eq_Ico`; `ProximityPrize.MCA.BoundaryField.pairMCA_real_128_threshold` |
| P3-B01 — §6, operational spectrum and endpoint-distance interpretation | For a supplied finite code, keep the exact real-error/integer-spectrum iff and the matching upper-bound/next-line threshold criterion. Good-challenge farness and covering use the actual attained code distance. | `ProximityPrize.BlockCode.pairMCAErrorBoundAt_relativeRadius_invPow_iff_spectrum_budget`; `ProximityPrize.BlockCode.pairMCAThreshold_eq_of_countBound_and_badLine`; `ProximityPrize.BlockCode.scalarDistance_ge_of_pairDistance_ge_of_good`; `ProximityPrize.ReedSolomon.Parameters.scalarDistance_eq_capacity_of_pairFar_of_good` |
| P3-A01 — §7, intrinsic modular source and three metrics | Actual integral δ₀a=z+qm validity, independently defined scalar/pair/RS distances, and d_C≤d_P=D_RS≤2d_C. Keep prime q, the information set, full identity layout and 2n/n normalizations. | `Hcrypt.Sheaf.SystematicCode.modularExact_iff_vectorCodeword`; `Hcrypt.Protocol.Storage.ThreeLevel.three_native_distance_comparison`; `Hcrypt.Protocol.Storage.ThreeLevel.flatDistance_eq_rsFlatDistance` |
| P3-A02 — §7, sharp near factor and original-payload calibration | For proper RS codes with `0<k<n`, the (power word,0) witness makes the near factor two sharp. The canonical calibration reads the same original payload; far transfer has unit scale and the near API explicitly uses 2d_C. | `ProximityPrize.ReedSolomon.Parameters.zeroDirectionPowerLine_pairDistance_eq_capacity`; `ProximityPrize.ReedSolomon.Parameters.zeroDirectionPowerLine_flatDistance_eq_half_capacity`; `ProximityPrize.ReedSolomon.Parameters.no_unit_pair_distance_bound_by_flat_distance`; `Hcrypt.Protocol.Storage.CanonicalCalibration.calibration_extract_eq_original_pair`; `Hcrypt.Protocol.Storage.CanonicalCalibration.sourceFar_implies_rsFar`; `Hcrypt.Protocol.Storage.CanonicalCalibration.planeNear_of_scaledSourceNear` |
| P3-A03 — §7, raw canonical capacity payload and restricted challenge profile | The original q=12289 payload is well formed and has all three native distances 3/4; its diagonal line has bad fraction 1/q at nonnegative radius. Accepted exact anchors instead have zero native distances under the equality of the actual interpretation decoder and layout decoder at that same payload. | `Hcrypt.Protocol.Storage.CanonicalThreeLevel.exists_payload_at_capacity`; `Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_badChallengeFraction`; `Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_canonicalMix_scalarDistance`; `Hcrypt.Protocol.Storage.CanonicalThreeLevel.accepted_nativeDistances_zero` |
| P3-A04 — §7, fixed-mix limitation | For each fixed nonzero scalar challenge, a capacity-far pair can cancel. Retain the distinction between binding the full pair before sampling and an independently justified restricted line. | `ProximityPrize.ReedSolomon.Parameters.no_fixedChallenge_pair_far_preservation`; `ProximityPrize.ReedSolomon.Parameters.no_fixedChallenge_flat_far_preservation` |

P3-S01--S09 cover all nine original named coding statements; P3-B01 records
the additional spectrum/distance account, and P3-A01--A04 retain §7's proved
application and its boundary. Equivalence objects must have transparent
ordinary definitions in the Challenge; their inverse laws are the statements,
rather than a bare existence predicate. For P3-S07 the cardinality theorem is
the unconditional mathematical claim; its fractional corollary at
`choose(n,k+1)/\|F\|` follows by the displayed arithmetic identity, not by
assuming a desired error bound.

Keep the three fields separate: the all-parameter `F_(3^n)` family, the
`2^128+192513` boundary prime and the `12289` wire application. The latter has
no universally safe 128-bit count radius. Modular validity is not real
`Context.Accepted`; under the stated matching-decoder contract, raw
positive-far payloads are not accepted exact anchors.
The actual source relation and metric comparison do not supply a new binding
or hiding primitive, a protocol sampling transcript, security or a complexity
advantage. A different Euclidean/full-HCP metric needs its own comparison.

### Selection verification and remaining packaging

Recheck the selected existing declarations alongside the earlier consolidated
probe after arithmetic changes. Count declaration reports separately from
statement groups and research results. The actual report and build outcomes
belong in the [central validation record](MATH_STORAGE_VALIDATION.md); previous
native-certificate audits remain dated evidence rather than current wrappers.

The official [statement/dependency policy](https://github.com/PalomarRegistry/PalomarPolicy/blob/main/CONTRIBUTING.md#22-challenge-and-solution-modules)
was rechecked on 2026-11-08: the independent Challenge must state the selected
claims faithfully using its permitted library closure, while the Solution
may reuse this development. This selection creates no wrappers, metadata,
protected preflight, public release or submission. Jacobian remains a layout
reference and a separately reviewed project.

## Wrapper and metadata conventions

Following Jacobian, place the proposed files under
`lean/Palomar/PaperOne/` and `lean/Palomar/PaperThree/`. Each directory would
contain `Challenge.lean`, `Solution.lean`, `comparator.json`, and
`formalization.yaml`, with a short shared guide. No such files are created by
this note.

The Challenge states the mathematical objects and theorem using approved
library imports only. Any needed project definitions must be stated
transparently there, documented, and cross-referenced to their canonical
owners in a parity table. The separate Solution imports and reuses the actual
implementation. Matching declaration names/types and relevant definition
bodies must survive protected comparison. Intentional Challenge proof holes
are comparison targets; Solution proofs must contain none.

| Comparator field | Preparation convention |
|---|---|
| `challenge_module` | The entry's independent dotted Challenge module. |
| `solution_module` | Its distinct proved Solution module. |
| `theorem_names` | The final fully qualified wrapper declarations, selected after statement review. |
| `permitted_axioms` | Only `propext`, `Quot.sound`, `Classical.choice`. |

Do not add project axioms or hide conclusions in newly assumed premises.
The P283 consolidated Lean 4.35 dependency audit is preserved as a historical
**855-report** baseline: **806 standard-only** (630 exact-three, 176 subsets)
and **49 with native certificates**. The later arithmetic work replaces the
boundary-field Lucas/root certificates, canonical12289 field/root proofs and
numeric target/spectrum checks with kernel-checked proofs. All pre-existing
public declaration signatures and numerical objects are retained. The new
`Hodge_Decomposition_unique` additionally supplies the componentwise uniqueness
in the manuscript's Hodge proposition, without changing its existing
existence/orthogonality API.

The [central validation record](MATH_STORAGE_VALIDATION.md#selected-statements-and-kernel-arithmetic--2026-11-08)
records the refreshed 9,292/9,285-job builds and **900 standard-only declaration
reports** (724 exact-three/176 subsets), including all 70 selected owners.
All 806 prior standard sets match, and all 49 former native reports are now
standard-only. This is the implementation audit, not a wrapper comparison. The older
`_native.native_decide.ax_*`, `Lean.ofReduceBool` and `Lean.trustCompiler`
reports remain dated evidence. The seven custom literature axioms remain
isolated in `CitedBounds` and outside this selected claim surface. Future
wrappers require their own audit and protected comparison; implementation
checks are not completed Palomar verification.
The native path/witness adapter is supporting Paper 2 infrastructure: supplied
path realization, finite decoded credential opening and exact owner-verifier
execution do not establish knowledge security or add a manuscript submission.
The new retrieval and concrete outer-codec results are also supporting Paper 2
infrastructure. The [completion checkpoint](PAPER_OUTLINE.md#source-based-completion-checkpoint--2026-11-08)
records the manuscript-led selection and remaining wrapper/source work;
the [source ledger](SOURCE_LEDGER.md) does not certify novelty or adoption.

Use `formalization.yaml` v0.4 for each entry: author and responsible maintainer,
existing MIT licence, classifications, precise manuscript/source relationships,
scope, proof dependencies, automation and human-review disclosures, known
divergences, and theorem-to-manuscript alignment. Tie manuscript URLs and
verification evidence to immutable commits. Recheck the current schema rather
than copying Jacobian's historical metadata or its review status verbatim.

## Main development upgrade and frozen submission release

The user has authorized upgrading the **main repository** to the current
stable Lean/Mathlib pair. Its pins are now Lean `leanprover/lean4:v4.35.0`
and Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679` (release `v4.35.0`).
The expanded mathematics and integration union passes **9,292 jobs**, covering
all fifteen default roots and the explicit ledger, evidence, storage and HCP
example, public-view, recipient and owned-transfer targets. The literal default build passes **9,285 jobs**.
The preceding 855-declaration probe and its former trust split are historical;
the refreshed selected-implementation checks are recorded centrally.
The source inventory has 274 Lean files: 273 public source modules and the
Lake configuration, with no active proof holes, unresolved local imports or
cycles. The same seven cited-bound axioms remain isolated; all 48 scoped
closures exclude legacy Chain and CitedBounds. The preceding 9,292/9,285-job, 839-report retrieval/codec milestone and
9,285/9,278-job, 750-report native-path milestone,
9,284/9,277-job, 728-report owner-signing milestone,
9,281/9,274-job, 667-report primitive-comparison milestone,
9,278/9,271-job, 605-report one-shot integrity milestone,
9,274/9,267-job, 500-report owned-transition milestone,
9,266/9,259-job, 355-report rotation milestone,
9,259/9,254-job, 268-report public-input milestone,
9,258/9,253-job, 235-report cellular-HCP milestone and the native-metric
9,253/9,248-job, 139-report and earlier 68-report snapshots remain dated
baselines; they are distinct from the current full/default and dependency record.
The completed main upgrade supersedes the
earlier proposal to keep main development on Lean 4.24.0; the earlier build
and dependency records remain separately dated historical evidence.

The current corresponding PDFs have 101 pages for Paper 1 and 30 for Paper 3;
Paper 1's observation and strict canonical-profile corrections have been rebuilt and visually
reviewed. Paper 3's completed modular summary and bounded source comparison
have also been rebuilt and visually reviewed. The earlier
public-observation, rotation, owned-transfer, one-shot integrity, primitive,
owner-signing and retrieval steps changed Paper 2's Markdown draft and left
both PDFs unchanged. The subsequent manuscript-only alignment updates Paper 3 while retaining
the P283 Lean source checkpoint. Select
the appropriate manuscript evidence for each entry and tie it to the final
immutable release. This is evidence preparation, not a completed submission.

Freeze a separate slim per-entry release with the selected proof closure,
corresponding manuscript evidence, statement/proof wrappers and metadata
after final claim selection. That
release provides a stable review target; it is no longer a separate route for
keeping the main repository on the old toolchain.

Current [Palomar policy](https://github.com/PalomarRegistry/PalomarPolicy/blob/main/CONTRIBUTING.md)
requires an immutable public repository commit, a committed manifest, matching
Lean/Mathlib versions, and a small independent Challenge. Every submitted
regular `.lean` file must use the new module system and stay within 10,000
lines; Challenge limits are 1,000 lines/100 KiB. Port visibility and exposed
definitions as well as adding headers. The current
[toolchain minimum](https://raw.githubusercontent.com/PalomarRegistry/PalomarSubmission/main/toolchains.json)
is `v4.35.0-rc2`; the validated stable 4.35.0 development uses its
matching Mathlib pin. Allowed proof axioms are the three logical axioms above;
native reduction and custom axioms are not substitutes.

The repo-shaped layout can retain `lean/` as the selected project, with
repository-relative Comparator and metadata paths, and the licence at
repository root. A public-review ZIP is not a Palomar submission.

## Reproducible checks and remaining steps

The following existing-target build command is reusable in the upgraded main
development and its eventual frozen release. These targets passed as part of
the larger Lean 4.35 aggregate/integration union; the command does not check
the proposed Challenge/Solution modules, which do not yet exist:

```sh
cd lean
lake exe cache get
LEAN_NUM_THREADS=1 lake build HCP Hardness Sheaf ProximityPrize
```

Build both new Solution modules and audit every selected theorem with
`#print axioms` once their files exist. The current official
[Comparator helper](https://github.com/PalomarRegistry/PalomarTemplate/blob/main/scripts/verify-comparator.sh)
confirms the command form `lake comparator --config PATH`. From `lean/`, the
proposed paths would be `Palomar/PaperOne/comparator.json` and
`Palomar/PaperThree/comparator.json`. These commands are future checks, not
evidence of a completed comparison. The helper also demonstrates independent
kernel replay; a plain local comparison is not the full protected preflight.

[Jacobian's release workflow](https://github.com/what-social-construct/jacobian-collision-geometry/blob/67872a1b3e6c6a85e6c93ac0079b023282bc1510/.github/workflows/papers-palomar-preflight.yml)
calls the official reusable submission workflow
once per entry, with `mode: full`, `execution_profile: palomar-standard-v1`,
the exact source commit, and the same immutable pipeline commit in both
`uses` and `pipeline_commit`. Follow the current
[agent/preflight instructions](https://submit.palomar-registry.org/llms.txt),
including `project_path: lean`, explicit repository-relative configuration
paths, and a distinct 12-character lowercase-alphanumeric request identifier.
Select the current pipeline revision when preparing the release; do not
silently reuse Jacobian's historical verifier pin. Require a passing complete
mechanical report for the exact final package before intake.

Remaining preparation, in order:

1. **Selected:** the manuscript-led tables above fix the HCP/CVP and Paper 3
   mathematical scopes, including the complete Q08 profile. Preserve those
   quantifiers and boundaries when constructing the independent wrappers.
2. Prepare the two slim proof closures and independent statement/proof
   surfaces, short READMEs, statement crosswalks, configurations and honest
   metadata on the validated main pin. Exclude archives, plans and unrelated
   paper claims; reconcile retained docstrings and informal text with the
   selected formal statements before freezing the release.
3. **Arithmetic source closure implemented:** preserve the new kernel proofs
   and re-audit the actual future Solution declarations, including Hodge
   uniqueness and both oracle-recovery contracts. Protected comparison remains separate.
4. Build, inspect theorem dependencies, and check manuscript/metadata alignment;
   then freeze the corresponding release and run its protected comparisons.
5. Choose the public repository and immutable commit, then run the official
   full preflight for each exact configuration and project path.
6. Present the concrete repository/commit/configuration and authorization
   relationship for confirmation before intake. The destination is
   [Palomar's submission service](https://submit.palomar-registry.org/).
   Agent access uses authenticated GitHub tag-write and secret-gist capability;
   the user handles browser sign-in. Registration is a separate decision after
   reading the actual review, not an automatic sequel to preparation.

No sibling files, credentials, review state, remote repository, or submission
service state were changed in preparing this note.
