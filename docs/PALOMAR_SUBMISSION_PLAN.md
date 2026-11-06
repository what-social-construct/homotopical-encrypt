# Palomar submission preparation: Papers 1 and 3

Preparation note, 2026-11-05. The intended public scope is the Lean development
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

## Candidate mathematical statement surfaces

These are existing implementation declarations to review and wrap, not a final
Comparator selection. A selected entry must faithfully cover its advertised
principal result families. A smaller supporting lemma cannot stand in for a
stronger manuscript claim.

| Paper 1 candidate family | Existing endpoint(s) | Premises and claim boundary to retain |
|---|---|---|
| Hidden targets and public-data ambiguity | `Hcrypt.HCPBridge.operativeTargets_ne_of_kernelSeparation`; `no_solver_exactOnOperativeTarget_of_kernelSeparation`; `cvpOracle_insufficient_for_operativeTarget` in [Hardness](../lean/Hardness.lean) | The actual realization, closed-formula invariance, kernel-separation witness, and, for the CVP statement, existence of a correct explicit-lattice oracle remain visible. This is conditional information loss, not a computational cryptographic security reduction. |
| Hodge coordinates and recovery | `Hcrypt.HCP.split_encrypt`, `encrypt_split`, `decrypt_encrypt` in [HCP](../lean/HCP.lean); concrete Hodge results in [Sheaf/Hodge](../lean/Sheaf/Hodge.lean) | The bijection includes both harmonic and orthogonal-noise coordinates. Preserve the actual degree-one operator and distinguish it from the normalized residual projector. |
| Discrete lattice comparison | `HarmonicCVPBridge.solution_iff_projectedTarget`; `concreteSheafHCP_CVP_solution_iff_message`; `concreteSheafHCP_CVP_existsUnique` in [Hardness](../lean/Hardness.lean) | The integral structure and presented harmonic lattice are supplied data. Continuous projection does not solve an arbitrary discrete CVP instance. |
| Exact-component observation limitation | `Hcrypt.Sheaf.CellularSheaf.HodgeEncryptedCochain.not_residual_norm_factors_exactComponent` and `not_far_preserving_exactComponent` in [ObservationQuotient](../lean/Sheaf/ObservationQuotient.lean) | Requires a nonzero coexact direction on the unrestricted sample carrier. It does not exclude a restricted noise profile or prove factorization of every concrete wire extraction. |
| Full-point Plucker recovery and observation boundary | `recoverSubspace_frame`, `recoverHarmonicProjector_frame` in [Reconstruction](../lean/Proximity/Concrete/GrassmannianPlucker/Reconstruction.lean); `recover_eq_operativeHarmonicComponent` in [PluckerObservation](../lean/TCB/PluckerObservation.lean) | Genuine full exact-real projective data and a fixed inner product recover the subspace/projector; the operative-target result additionally identifies that subspace with the HCP kernel. Digest-only observations, finite encoding and efficient recovery are different claims. |

Use the [Paper 1 appendix](../papers/paper1/sections/appendices.tex) and
[shared parity register](../SEMANTIC-PARITY.md) when selecting the exact scope.
Do not replace the typed HCP realization with the older constant-projection
sanity example while claiming the full HCP result.

Paper 3's [named-statement register](../papers/proximity-prize/SEMANTIC_PARITY.md#named-statement-coverage)
accounts for nine generic statements. Namespace prefixes below are
`ProximityPrize`.

| Manuscript family | Existing endpoint(s) and module |
|---|---|
| Plane/pair and plane/line equivalences | `planePairEquiv`, `planePairEquiv_relativeHammingDistance`, `planeLineEquiv` — [Core/PlanePair](../lean/Proximity/Core/PlanePair.lean) |
| Exact capacity-grid list count | `ReedSolomon.Parameters.vectorListSizeBoundAt_capacityGrid`, `capacityReceived_ballCardAt_eq_choose` — [ListDecoding/Capacity](../lean/Proximity/ListDecoding/Capacity.lean) |
| Next-shell lower bound | `ReedSolomon.Parameters.fieldCard_pow_le_nextShell_ballCardAt` — the same Capacity module |
| Fractional-target phase split and real endpoint | `ReedSolomon.Parameters.vectorFractionalListPhaseSplit`, `vectorFractionalListRealThreshold` — [PhaseSplit](../lean/Proximity/ListDecoding/PhaseSplit.lean) |
| Actual smooth-family list corollary | `Capacity.SmoothQuarterFamily.parameters`, `rootUnit_order`, `realized_fractionalListSizeBoundAt_capacity`, `realized_listRealThreshold` — [Realization](../lean/Proximity/Capacity/Realization.lean), [ListPhase](../lean/Proximity/Capacity/ListPhase.lean) |
| Compressed same-set pair-MCA certificate | `ReedSolomon.Parameters.badChallengeSetAt_card_le_choose_succ`, `pairMCAErrorBoundAt_of_compressed_budget` — [MCA/Pair](../lean/Proximity/MCA/Pair.lean) |
| Actual smooth-family MCA corollary | `Capacity.SmoothQuarterFamily.realized_pairMCAErrorBoundAt`, `realized_pairMCAGreatestSafe_eq_length` — Realization |
| Exact 128-bit boundary instance | `MCA.BoundaryField.pairMCA_exact_128_bit_threshold`, `pairMCA_real_128_threshold` — [BoundaryField](../lean/Proximity/MCA/BoundaryField.lean), [RealThreshold](../lean/Proximity/MCA/RealThreshold.lean) |

The first row covers two manuscript statements. The upper-bound and attaining
word declarations jointly express the exact capacity-grid equality.

**Q08 is complete for the declared native modular profile.** Actual integral
cellular coboundary congruence defines source validity; a complete original-
payload codec and explicit representative lifts prove
`d_cochain ≤ d_plane = d_RS ≤ 2*d_cochain`. The near factor two is sharp.
The same canonical payload has all three native distances `3/4`. The existing
source-calibration composition and scaled-near interface are instantiated
without assuming the desired distance inequality.

These application families are candidates for explicit selection, separate
from the nine original generic coding statements:

| Application family | Proof owner and claim boundary |
|---|---|
| Actual modular cellular validity and native metric comparison | [Modular](../lean/Sheaf/SystematicCode/Modular.lean), [ThreeLevelMetrics](../lean/Protocol/Storage/ThreeLevelMetrics.lean), [CanonicalCalibration](../lean/Protocol/Storage/CanonicalCalibration.lean). Retain the systematic source realization, information set, coordinate ordering, prime-field profile and scalar/pair normalizations. Modular validity is not real `Context.Accepted`. |
| Nonempty native capacity family and near-factor sharpness | [DeepHole](../lean/Proximity/Core/DeepHole.lean), [MetricSharpness](../lean/Proximity/Core/MetricSharpness.lean). The paired power word has distance `(n-k)/n`; the power-word/zero pair proves the factor-two near loss is necessary. Generic standard-only results and concrete canonical arithmetic have distinct trust reports. |
| Challenge guarantees and fixed-mix limitation | [Diagonal](../lean/Proximity/MCA/Diagonal.lean), [FixedChallenge](../lean/Proximity/Core/FixedChallenge.lean), [CanonicalThreeLevel](../lean/Protocol/Storage/CanonicalThreeLevel.lean). A diagonal non-codeword has exactly the cancelling challenge `-1` at nonnegative radius; the actual canonical mix is good for that line. Arbitrary fixed nonzero mixes still admit capacity-far cancellation. |
| Euclidean comparison boundary | [CanonicalLiftObstruction](../lean/Sheaf/CanonicalLiftObstruction.lean), [NoWrapCalibration](../lean/Protocol/Storage/NoWrapCalibration.lean). The unrestricted zero-defect Euclidean comparison is obstructed for nontrivial linear decoders; the explicit integer-syndrome no-wrap comparison is only a coarse first-shell result. |

There is no capacity-scale unrestricted Euclidean/full-HCP theorem and no
global fixed-mix far-preservation theorem. Positive native-far inputs are raw
proximity/rejection inputs; accepted exact contexts have zero native distance
under the stated decoder contract. A private-frame producer, authentication,
transcript/sampling implementation, new commitment security game and consensus
finality remain separate. Preserve these hypotheses and scope boundaries in
the selected entry rather than importing every application claim. See the
[application trace](COCHAIN_PROXIMITY_TRACE.md), [parity register](../SEMANTIC-PARITY.md)
and [novelty comparison](PROXIMITY_NOVELTY_COMPARISON.md).

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
The fresh consolidated Lean 4.35 [dependency audit](MATH_STORAGE_VALIDATION.md)
covers **139 distinct selected declarations** and exactly reproduces their
individual reports: **103 standard-only** (100 use exactly the three permitted
logical axioms; three use a subset) and **36 with existing native arithmetic
certificates**. No report uses a cited-bound axiom or `sorryAx`. The earlier
68-declaration, 64/4 split is preserved as the pre-addition 4.35 baseline.
The native dependencies print as generated `_native.native_decide.ax_*`
constants; the older
`Lean.ofReduceBool`/`Lean.trustCompiler` names describe the preserved 4.24
reports. Native dependencies must be replaced by kernel-checked proofs before
selecting those endpoints for a Palomar comparison. The concrete application's
seven cited-bound axioms must not enter the selected proof dependencies.
The 139-report result is a development audit, not proof that a future selected
Solution or its protected comparison already satisfies the submission rules.

Keep statement selection and dependency eligibility as separate checks:

| Candidate surface | Present evidence | Submission consequence |
|---|---|---|
| Generic statements such as the modular-coboundary equivalence, native metric comparison, monomial/diagonal and fixed-challenge results | Their selected reports use only the permitted logical axioms. Prime-field, information-set, degree, length, line-profile and realization hypotheses remain explicit. | These are candidates for a standard-only entry, not completed submissions. The independently stated Challenge, matching Solution, retained hypotheses, manuscript claim and protected comparison still need review. |
| Concrete canonical payload, fixed-root and numerical boundary endpoints | They retain native certificates in the current development. The canonical native profile inherits the existing `q=12289` primality/root-order certificates; the separate numerical boundary instance has its own arithmetic trust. | Replace the actual required arithmetic proofs with kernel-checked proofs before selecting such endpoints. Advertising the concrete conclusion while changing it to a newly assumed certificate or a weaker generic theorem would not cover that claim. |

The **103 standard-only audited declarations do not automatically constitute
an eligible or complete submission**. The final named wrappers and their exact
proof dependencies, statement bodies, hypotheses and informal descriptions
are the objects that must pass the selected entry's checks.

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
The expanded mathematics and integration union passes **9,253 jobs**, covering
all fifteen default roots and the explicit ledger, evidence, storage and native
application targets. The literal default build passes **9,248 jobs**. The fresh
139-declaration public-facade probe passes with the trust split above.
The current source inventory has 235 Lean files: 234 source modules with
public-module interfaces and the Lake configuration. The scan finds no active
proof holes, unresolved local imports or cycles, and the same seven explicit
cited-bound axioms remain isolated. Build, source and selected-dependency
checks have different scopes. These results supersede the 9,233/9,228-job and
68-report pre-addition 4.35 snapshot while preserving it as dated evidence.
The completed main upgrade supersedes the
earlier proposal to keep main development on Lean 4.24.0; the earlier build
and dependency records remain separately dated historical evidence.

The current corresponding PDFs have 97 pages for Paper 1 and 28 for Paper 3;
all 125 pages and the changed-page details have been visually checked. Select
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

1. Select each entry's exact advertised claims from the checked mathematics.
   Retain the completed native Q08 profile and its actual hypotheses; stronger
   Euclidean, arbitrary fixed-mix and protocol/security claims are outside it.
2. Prepare the two slim proof closures and independent statement/proof
   surfaces, short READMEs, statement crosswalks, configurations and honest
   metadata on the validated main pin. Exclude archives, plans and unrelated
   paper claims; reconcile retained docstrings and informal text with the
   selected formal statements before freezing the release.
3. Replace native proof dependencies for any selected boundary/canonical
   results and audit the exact selected Solution declarations.
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
