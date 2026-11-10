# Palomar submission preparation: Papers 1 and 3

Preparation note begun 2026-11-05; Paper 1 and Paper 3 entry files prepared 2026-11-09. The
intended public scope is the Lean development and corresponding manuscripts.
Paper 1 now has an independent statement/proof pair, Comparator configuration,
metadata and completed local diagnostic checks. At the preceding preparation
checkpoint no public release or protected preflight had occurred. The exact
historical publication/run status and current local revision are recorded below; registry intake and registration
have not occurred.

**Historical release checkpoint — Paper 1 public; protected preflight passed, 2026-11-09.**
The approved Paper 1-only snapshot is on `main` in
[homotopical-encrypt-formalizations](https://github.com/what-social-construct/homotopical-encrypt-formalizations)
at commit `66e1ad2cb726d3dd816461e4f76b1d0d9147a46d`. The complete protected
[preflight run](https://github.com/what-social-construct/homotopical-encrypt-formalizations/actions/runs/42729947447)
completed successfully with request identifier `p1pf875ad70f`. Its downloaded
mechanical report passes exact source/configuration/metadata/provenance checks;
Lean, NanoDa and con-ron all accept. The only advisory is preferred Challenge
review size, within the hard caps. The user approved publication and preflight only and
explicitly said not to submit yet. **No registry intake or registration is
authorized or performed.** The mechanical report is inspected and retained;
stop before intake. Any later submission needs a new explicit instruction
and final confirmation of the exact
repository/commit/configuration/relationship tuple.
The two checked Paper 3 configurations remain local candidates for later
work. Their technical packaging does not change the
[three-paper split](../SEMANTIC-PARITY.md#manuscript-ownership-and-dependency-table):
Paper 2 remains the protocol/cochain paper and Paper 3 the proximity paper.

**Current back-matter revision, 2026-11-09.** Paper 1 is **38 pages**. Its
mathematical body contains no Lean cross-reference blocks or implementation
filenames. Section 7 is *Conclusion and Further Work*. Appendix A consolidates
the correspondence into one parity table: four definition rows, eight main
result groups (21 declarations), five support groups (25 declarations), and
three external-result/assumption/contract rows. Appendix B keeps concise proof
boundaries. All **280 Lean files are byte-identical to `dddfdd2`**, so the
checked 9,295-job build and 975-report dependency state is retained; this
editorial change introduces no new Lean build claim. Paper 3 remains the
unchanged 31-page PDF. The bibliography reconciliation adds 19 records and
maps all 28 source-ledger IDs: Paper 1 cites seven entries, while Paper 2 and
Paper 3 retain 42 and 16 records respectively. Candidate bibliography
membership does not imply adoption or formalization. This revision remains
local; public `66e1ad2` and its historical protected report are unchanged.

**Earlier P300/P301 scope checkpoint, 2026-11-09.** The manuscripts followed that
split throughout: Paper 1 was 37 pages, retaining HCP/Hodge/CVP, the actual
Helfer homological-test fragment and observation/Plücker mathematics; Paper 2
owns the concrete commitment/codec, visibility, gates/evidence and storage
construction; Paper 3 was 31 pages and owns quantitative RS/proximity,
calibration and metric bridges. Paper 2 remains a working Markdown draft.
The revised manuscripts and 93 comment-only Lean files are not part of public
commit `66e1ad2cb726d3dd816461e4f76b1d0d9147a46d`, have not been published or
protected-preflighted. Fresh local validation passes the 9,295-job expanded
build and all 975 dependency reports with unchanged sets; those PDFs passed
build/render/layout QA. The central validation guide records those checks.
The historical 101-page Paper 1 release and its PASS do not validate the
revised bytes. No registry intake or registration is authorized.

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
| Paper 3 application companion | The same manuscript's original-payload modular application; [CanonicalThreeLevel](../lean/Protocol/Storage/CanonicalThreeLevel.lean), [CanonicalCalibration](../lean/Protocol/Storage/CanonicalCalibration.lean) | `Palomar.PaperThree.Application.Challenge` and `Palomar.PaperThree.Application.Solution` |

There are **three configurations for two manuscripts**: Paper 1, Paper 3
core, and Paper 3's application/bridge companion. These are verification
configurations, not a second manuscript split. Paper 1 alone remains the
first release priority; the two Paper 3 entries
remain checked local candidates. The companion introduces no numbered paper.
Paper 1's completed local checks are recorded below. Paper 3's files now exist;
its verification is recorded separately from the earlier implementation audit.
Paper 2 has a [working Markdown draft](../papers/paper2/DRAFT.md)
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
slim per-entry release nor a Palomar submission. Paper 1's entry files now
live in the development repository. The separately frozen historical Paper 1 release
and completed protected preflight are tracked in the
[slim release guide](PALOMAR_SLIM_RELEASES.md). The Paper 3 packages remain
local; publication, hosted verification and registry intake retain their
separate statuses.

## Paper 3 coding and application entries — 2026-11-09

Paper 3 retains its full selected scope across two independent configurations.
The [coding entry](../lean/Palomar/PaperThree/README.md) contains P3-S01--S09,
P3-B01, the sharp factor-two statements from P3-A02 and P3-A04. The
[application companion](../lean/Palomar/PaperThree/Application/README.md)
contains P3-A01, the original-context calibration statements from P3-A02 and
P3-A03. P3-A02 is deliberately shared across the crosswalks: its sharp coding
witness and storage calibration are distinct statements within that group.

The split keeps each independent Challenge within the policy's 1,000-line /
100-KiB cap. Both use Mathlib-only imports and ordinary transparent definitions
under the actual canonical names. Their Solutions import the existing proof
owners. The coding Solution adds two explicit equivalence inverse-law wrappers;
its configuration checks the ordinary equivalence definitions through those
statements, without a definition hole.

The application keeps the original `Context`, snapshot, interpretation decoder,
cochain payload, layout and integral cellular coboundary. Three calibration
statements unfold the existing model/interface records into the same concrete
maps and distances. Their Solution proofs use `change` followed by the original
canonical theorem. This presents the same propositions while avoiding an
additional calibration-record vocabulary in the independent Challenge.
Four supporting statements certify the named `capacityPayload`'s wire shape
and all three distances equal to `3/4`; the challenge-fraction and fixed-scalar
results refer to that same payload. The accepted-zero statement retains the
actual decoder-equality hypothesis at that payload and `Context.Accepted`.

The [manual Paper 3 workflow](../.github/workflows/paper3-palomar-preflight.yml)
selects coding, application, or both, with separate request identifiers and
explicit repository-relative configuration/metadata paths. It uses the same
pinned pipeline and nested `lean` project convention as Paper 1. The workflow
has not been pushed or dispatched. These files do not supply protected Linux
verification, a public immutable release, registry review or submission.

The three field roles remain separate: the all-parameter characteristic-three
family, the `2^128+192513` boundary prime, and the original `12289` application.
The application does not gain an unrestricted 128-bit guarantee from the
coding family's field. Original modular validity, real decoded exactness,
full HCP residual, protocol security and runtime execution keep their separate
meanings and obligations.

Both Paper 3 entries now pass local full definition comparison and Lean/NanoDa
replay. Coding has 52 selected targets (36 main/16 support), application 22
(ten main/twelve support). Their fresh audits use only standard axioms; all 975
combined reports pass with 946 earlier sets unchanged. The
[current validation record](MATH_STORAGE_VALIDATION.md#paper-3-independent-entries--2026-11-09)
records exact build, source, value-preservation and dependency evidence.

## Paper 1 independent entry — 2026-11-09

The [entry README](../lean/Palomar/PaperOne/README.md) maps all eight selected
Paper 1 groups below to **21 manuscript-facing declarations** and **25
supporting declarations**. These are coverage counts, not 21 independent
research contributions. The discrete CVP projection comparison and actual
cellular public-target ambiguity remain central.

Following the frozen Jacobian release, Challenge imports only Mathlib and
states transparent mathematical objects independently. Solution matches those
definitions and adapts the canonical proofs. The two pure categorical
`Hcrypt.Helfer.contextObject/contextMap` helpers keep their canonical names
in Challenge so the recursive finite-product interpretation matches the
implementation structurally. No project imports or definition holes are used
in Challenge; its 23 intentional theorem placeholders are selected targets.
Solution contains no proof holes and imports no Challenge.

Both entry modules build independently. Local Comparator accepts the selected
statements, reachable definitions and permitted axioms, and both Lean and
NanoDa accept the Solution proof export. This macOS run used the explicit
`--inadvisably-no-sandbox` diagnostic mode; it does **not** supply protected
preflight evidence. All 46 fresh entry dependency reports are standard-only
(44 exact-three/two subsets); the combined 946-report audit preserves every
one of the 900 preceding dependency sets. The
[validation record](MATH_STORAGE_VALIDATION.md#paper-1-independent-entry--2026-11-09)
contains reproduction commands and the remaining boundaries.

The public snapshot's manuscript pass foregrounded the constructed integral observation
examples, states the finite signed-incidence model explicitly, and distinguishes
the legacy nullity/likelihood vocabulary from stronger homotopy or security
claims. Its 101-page PDF was rebuilt and visually inspected, and the
manuscript and metadata were frozen together in public commit
`66e1ad2cb726d3dd816461e4f76b1d0d9147a46d`. The earlier Paper 1 candidate
`73f9c28a4b9f8fb6a04e5b656389979be6b9cd92` is superseded for publication by
this refreshed snapshot; its completed checks remain historical
evidence. No Lean declarations or entry configuration names were changed by
those wording corrections. The subsequent local 37-page P300/P301 revision and Lean comment changes
were a different snapshot. The current 38-page parity-table revision retains
all Lean bytes from `dddfdd2`; neither editorial revision has a new protected
preflight result.

The local [manual workflow](../.github/workflows/paper1-palomar-preflight.yml)
follows Jacobian's [pinned reusable workflow](https://github.com/PalomarRegistry/PalomarSubmission/blob/14aa8d6b3c2f14a8540605e37144560b9a00e7e7/.github/workflows/submission.yml) at
`14aa8d6b3c2f14a8540605e37144560b9a00e7e7`, also the official upstream main
commit checked on 2026-11-09. Its `project_path` is `lean`; configuration and
metadata paths are relative to the repository root. Only `workflow_dispatch`
is enabled, with a fresh 12-character request identifier and the selected
commit recorded by `github.sha`. That development-repository workflow was
not pushed or run during its local preparation. The published slim snapshot
contains its own `.github/workflows/palomar-preflight.yml`, now dispatched
against the exact public commit linked above. Public release, protected
verification and registry intake remain separate steps.

## Selected manuscript statement surface — 2026-11-08

The manuscripts supply the main statements: Paper 1's existing named
propositions, especially the discrete CVP comparison and kernel ambiguity,
and Paper 3's nine named coding statements. The tables below select their
mathematical content for two entries. These IDs organize manuscript results;
the uniqueness companion completes an existing proposition. The independent
wrappers now exist and use transparent mathematical definitions in Challenge
and the existing proofs in Solution. The historical Paper 1 release passed
protected comparison and entry-size checks; the revised local documentation
requires its own exact-snapshot checks before a refreshed release.

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
| P1-B02 — §6.2, `prop:plucker-recovery`; formal-boundaries appendix | Genuine full projective coordinates recover the subspace and its fixed-metric projector; operative-kernel identification additionally recovers the HCP target from b. Digest-only observations remain separate. | `Hcrypt.Proximity.GrassmannianPlucker.Concrete.recoverSubspace_frame`; `Hcrypt.Proximity.GrassmannianPlucker.Concrete.recoverHarmonicProjector_frame`; `Hcrypt.TCB.PluckerObservation.recover_eq_operativeHarmonicComponent` |

The concrete family uses actual integral cellular sheaves and the true
degree-one operators. Its public classifier is the full theory of the stated
nonzero-cohomology tests in the real cochain Quillen model: the declared
homological fragment of Helfer semantics. The same-object definitions,
`semanticEquivalence`, `theory_zero_eq_one` and actual operator identities
support the statements; they cannot be replaced by a constant mock classifier
or made conclusions of new assumptions. Full first-order semantics, equality
of larger released storage views, sampled secrecy, finite byte codecs and
complexity bounds remain separate.

P1-B01/B02 are explicitly named observation-boundary statements. The local
manuscript's [observation section](../papers/paper1/sections/05-observation-boundaries.tex)
and [projective-recovery section](../papers/paper1/sections/06-projective-observation-boundary.tex)
retain that mathematics. Detailed construction and protocol gates now belong
to Paper 2; quantitative RS/MCA and far-separation/calibration arguments
belong to Paper 3. Paper 1 retains only a brief conditional application
reference, outside the selected HCP/CVP entry; no cited-bound theorem becomes
an axiom-free selected result through this rearrangement.

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
may reuse this development. The 2026-11-09 section above records the completed
Paper 1 local entry. Paper 3's companion packaging is described above;
protected verification remains separate.
Jacobian remains a layout reference and a separately reviewed project.

## Wrapper and metadata conventions

Following Jacobian, Paper 1's files are under `lean/Palomar/PaperOne/`;
Paper 3 uses `lean/Palomar/PaperThree/` and its `Application/` companion.
Each entry has `Challenge.lean`,
`Solution.lean`, `comparator.json`, `formalization.yaml` and a short README.
The files are present for all three configurations; each needs its own
statement, dependency and protected-verification record.

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
checks are not completed Palomar verification. Paper 1's subsequent local
entry audit and comparison are recorded above; protected comparison remains.
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
Before the local manuscript/comment split, the expanded mathematics and integration union with all three Solutions passed
**9,295 jobs**, covering
all fifteen default roots and the explicit ledger, evidence, storage and HCP
example, public-view, recipient and owned-transfer targets. The literal default build passed **9,285 jobs**.
The preceding 855-declaration probe and its former trust split are historical;
the refreshed selected-implementation checks are recorded centrally.
The inventory has 280 Lean files: 279 public source modules and Lake, with
zero implementation holes and 96 intentional theorem placeholders in three Challenges.
There are no unresolved local imports or cycles. The same seven cited-bound
axioms remain isolated; all 54 scoped closures exclude legacy Chain and
CitedBounds. That combined audit has 975 standard-only reports, with
all 946 previous sets unchanged. The preceding 9,292/9,285-job, 839-report retrieval/codec milestone and
9,285/9,278-job, 750-report native-path milestone,
9,284/9,277-job, 728-report owner-signing milestone,
9,281/9,274-job, 667-report primitive-comparison milestone,
9,278/9,271-job, 605-report one-shot integrity milestone,
9,274/9,267-job, 500-report owned-transition milestone,
9,266/9,259-job, 355-report rotation milestone,
9,259/9,254-job, 268-report public-input milestone,
9,258/9,253-job, 235-report cellular-HCP milestone and the native-metric
9,253/9,248-job, 139-report and earlier 68-report snapshots remain dated
baselines; they are distinct from the last completed full/default and dependency record.
The completed main upgrade supersedes the
earlier proposal to keep main development on Lean 4.24.0; the earlier build
and dependency records remain separately dated historical evidence.

The preceding reviewed PDFs had 101 pages for Paper 1 and 30 for Paper 3;
Paper 1's observation and strict canonical-profile corrections were rebuilt and visually
reviewed. Paper 3's completed modular summary and bounded source comparison
have also been rebuilt and visually reviewed. The earlier
public-observation, rotation, owned-transfer, one-shot integrity, primitive,
owner-signing and retrieval steps changed Paper 2's Markdown draft and left
both PDFs unchanged. P289 subsequently closed kernel arithmetic and updated
Paper 3's trust wording/PDF. The Paper 1 entry then retained all 273 owner
files and both PDFs unchanged. Select
the appropriate manuscript evidence for each entry and tie it to the final
immutable release. This is evidence preparation, not a completed submission.
The public snapshot's Paper 1 wording pass has its own rebuilt and visually inspected
101-page PDF in the exact public snapshot linked above. The preceding
paragraph's counts and unchanged-source statements remain dated baselines.
The P300/P301 37/31-page ownership revision passed its compile/render checks,
9,295-job local build and all 975 selected dependency reports with unchanged
sets. The current Paper 1 is 38 pages and moves Lean correspondence to its
post-conclusion parity table; Paper 3 and its printed bibliography remain
unchanged. All 280 Lean files retain exact bytes from `dddfdd2`, preserving
that checked Lean state. The new manuscript remains outside the exact
historical protected-preflight baseline; a new hosted check is still required.

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
the independent Challenge/Solution modules:

```sh
cd lean
lake exe cache get
LEAN_NUM_THREADS=1 lake build HCP Hardness Sheaf ProximityPrize
```

All three entry builds, local definition comparisons, Lean/NanoDa replays and
selected dependency reports are completed. The combined 975-report audit
preserves every one of the 946 preceding dependency sets. The official
[Comparator helper](https://github.com/PalomarRegistry/PalomarTemplate/blob/main/scripts/verify-comparator.sh)
confirms the command form `lake comparator --config PATH`. From `lean/`, the
paths are `Palomar/PaperOne/comparator.json`,
`Palomar/PaperThree/comparator.json` and
`Palomar/PaperThree/Application/comparator.json`. The helper also demonstrates independent
kernel replay; the local diagnostic is not the full protected preflight.

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

Historical release sequence, with Paper 1 first; the local revision above is
not yet a replacement release:

1. **Selected Paper 1 account completed.** The eight HCP/CVP and observation
   groups retain their actual finite-incidence objects and explicit
   hypotheses. That release's manuscript was rebuilt/inspected and aligned with
   its README, metadata and source evidence.
2. **Paper 1 snapshot frozen.** Its exact proof closure
   has 31 local modules, one configuration and the corresponding manuscript.
   Exclude archives, plans and other-paper claim surfaces. The earlier three
   technical-branch proposal is superseded; see the
   [release guide](PALOMAR_SLIM_RELEASES.md).
3. **Paper 1 snapshot published on `main`.** Public commit
   `66e1ad2cb726d3dd816461e4f76b1d0d9147a46d` contains no private development
   history and preserves all checked Lean bytes, pins and configuration
   paths. Paper 3's two locally checked entries remain unpublished for later;
   Paper 2's protocol/cochain draft retains its existing place in the program.
4. **Complete protected preflight passed.** Run `42729947447` checks the
   exact public commit, `project_path: lean` and Paper 1's configuration and
   metadata paths. The downloaded `mechanical-report-p1pf875ad70f` passes
   protected comparison, canonical provenance and Lean/NanoDa/con-ron checks.
   Its preferred-size advisory is within the hard caps. Prior local builds
   and the 975-report audit remain separately recorded evidence.
5. **Local editorial revision prepared; stop before intake.** The current
   38-page Paper 1, unchanged 31-page Paper 3 and reconciled bibliographies
   remain local. The post-conclusion parity table preserves all 46 configured
   declarations, and all 280 Lean files retain exact bytes from `dddfdd2`.
   Finish the manuscript/package exact-source checks and
   prepare a refreshed slim snapshot before any future publication/preflight.
   The user explicitly deferred submission.
   Do not request registry submission or registration on the strength of a
   passing report. A later explicit submission instruction must confirm the
   concrete repository, full commit, configuration and truthful authorization
   relationship, together with the passing preflight report. The destination is
   [Palomar's submission service](https://submit.palomar-registry.org/).
   Agent access uses authenticated GitHub tag-write and secret-gist capability;
   the user handles browser sign-in. Registration is a separate decision after
   reading the actual review, not an automatic sequel to preparation.

The separate Paper 1 public repository and preflight workflow changed under
the user's explicit publication/preflight authorization. No sibling files,
private development remote, credentials, Palomar intake, review state or
registration state were changed. Paper 2 and Paper 3 remain unpublished.
