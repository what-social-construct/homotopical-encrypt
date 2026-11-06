# Mathematics and sheaf-storage validation

This record covers the concrete Helfer/Hodge/CVP family and observation
adapters, Q04--Q07 and the native modular profile, the sheaf/storage adapters,
and D03's gap-boundary interface. It distinguishes
source coverage, checked proof statements and theorem dependencies. It does
not certify a concrete cryptographic scheme, an uninstantiated source-radius
profile, an efficient gap solver or a storage backend.

## Current public-observation profile — 2026-11-06

The first Paper 2 public-input profile is now implemented in
[PublicView](../lean/Protocol/Storage/PublicView.lean), exported through
`Protocol.Storage.Core`:

- `Context.publicView` releases the same original cochain payload and all six
  derived context-key coordinates. Snapshot/run/parameter substitutions are
  observable; equality requires both the header and original payload.
- `SealedManifest.publicView` retains that base input, the actual sealed root
  and ordered slot/digest directory. The directory preserves the original
  slot order and uniqueness, while omitting dependent checkpoint witnesses.
- `hcpDisclosure` adds the existing `(class,b)` observation from the same
  bound sample. Equality of HCP pairs alone does not imply equality of these
  larger releases. A public class announcement without `b` is the separate
  tuple of the base view and that snapshot's classifier value.
- `TCB.HCPRealization.no_exact_view_decoder_of_same_view` requires only
  pairwise equality of the actual released views and different operative
  targets to exclude one decoder exact on both. It supplies neither equality
  of storage records nor cryptographic hiding. The earlier global
  factorization criterion is retained.

Paper 2 §2.1 fixes the data/access boundary. Canonical bytes, authenticated
opening requests, proof/verifier metadata, released history extensions and
their cryptographic binding remain explicit contracts. No new serializer,
hash implementation, key rotation or privacy experiment is claimed. Papers
1 and 3 and their reviewed PDFs are unchanged in this step.


### Public-observation validation

The expanded union of all fifteen default roots and explicit integration
entries passes **9,259 jobs**; the literal default passes **9,254 jobs** on
the unchanged Lean/Mathlib 4.35 pins. The new leaf's focused build passes
3,396 jobs and the pairwise adapter's focused build passes 3,383 jobs. Replayed
upstream linter/deprecation warnings remain; the added code has no local
warning or error.

A fresh public-facade probe passes **268 distinct selected declarations**:
**232 standard-only** (220 exactly the usual three axioms and twelve subsets),
and **36 retaining existing native arithmetic certificates**. All **33 new
reports** are standard-only: 26 use exactly the three, seven use no axioms.
All 235 preceding dependency sets match exactly. No selected result depends
on a cited-bound axiom or `sorryAx`.

The static scan covers **240 public source modules / 241 Lean files** including
Lake configuration, with no active holes, unresolved imports or local cycles,
and the same seven isolated cited-bound axioms. The new public-view closure
has 38 modules; `Protocol.Storage.Core` now has 80. The other eleven recorded
closures are unchanged. All thirteen exclude `Chain` and `CitedBounds`.
The local artifacts are `public-observation-{full,default}-build.log`,
`public-observation-{all,new}-axioms.lean`, `public-observation-all-axioms.log`,
`public-observation-axiom-summary.json` and
`public-observation-source-audit.json` under `output/validation/`.
These are selected dependency reports, not a security or runtime certificate.

To reproduce the added checks from `lean/`:

```sh
LEAN_NUM_THREADS=4 lake build
LEAN_NUM_THREADS=4 lake build Protocol.Storage.PublicView Protocol.Storage.Core \
  TCB.HCPRealization Protocol.Ledger.Examples Protocol.Ledger.EvidenceExamples \
  Protocol.Storage.AnchorExamples Protocol.Storage.CanonicalThreeLevel \
  Protocol.Storage.CanonicalCalibration HCP.AxisFamily TCB.HCPAxisFamily
cat > /tmp/public-observation-new-axioms.lean <<'LEAN'
import Protocol.Storage
import TCB

#print axioms Hcrypt.Protocol.Storage.PublicPayloadView
#print axioms Hcrypt.Protocol.Storage.PublicPayloadView.ext
#print axioms Hcrypt.Protocol.Storage.PublicPayloadView.eq_iff
#print axioms Hcrypt.Protocol.Storage.PublicPayloadView.ne_of_key_ne
#print axioms Hcrypt.Protocol.Storage.Context.publicView
#print axioms Hcrypt.Protocol.Storage.Context.publicView_eq_iff
#print axioms Hcrypt.Protocol.Storage.Context.publicView_topologyTag_matches
#print axioms Hcrypt.Protocol.Storage.Context.publicView_ne_of_key_ne
#print axioms Hcrypt.Protocol.Storage.Context.publicView_ne_of_snapshot_ne
#print axioms Hcrypt.Protocol.Storage.Context.publicView_ne_of_runId_ne
#print axioms Hcrypt.Protocol.Storage.Context.publicView_ne_of_parameters_ne
#print axioms Hcrypt.Protocol.Storage.PublicManifestView
#print axioms Hcrypt.Protocol.Storage.PublicManifestView.ext
#print axioms Hcrypt.Protocol.Storage.PublicManifestView.eq_iff
#print axioms Hcrypt.Protocol.Storage.SealedManifest.publicView
#print axioms Hcrypt.Protocol.Storage.SealedManifest.publicView_base
#print axioms Hcrypt.Protocol.Storage.SealedManifest.publicView_directory_slots
#print axioms Hcrypt.Protocol.Storage.SealedManifest.publicView_directory_slots_nodup
#print axioms Hcrypt.Protocol.Storage.HCPDisclosure
#print axioms Hcrypt.Protocol.Storage.HCPDisclosure.forget
#print axioms Hcrypt.Protocol.Storage.HCPDisclosure.ext
#print axioms Hcrypt.Protocol.Storage.HCPDisclosure.eq_iff
#print axioms Hcrypt.Protocol.Storage.HCPDisclosure.ne_of_base_ne
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_forget
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_cochain
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_leafDigest
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_snapshotRoot
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_runId
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_observation
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_eq_iff
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_same_observation_distinct_parameters
#print axioms Hcrypt.TCB.HCPRealization.no_exact_view_decoder_of_same_view
LEAN
LEAN_NUM_THREADS=2 lake env lean /tmp/public-observation-new-axioms.lean
```

## Current cellular HCP implementation — 2026-11-06

This preceding construction/validation milestone is retained as a baseline;
the public-observation profile above is its subsequent follow-up.

The five-module follow-up constructs an actual finite integral cellular HCP
family in a proved homological fragment of the typed Helfer interface. It
reuses the existing positive CVP comparison and negative public-recovery/oracle
argument. The full union of all fifteen default roots plus explicit transition,
storage and HCP targets passes **9,258 jobs**; the literal default `lake build`
passes **9,253 jobs**, with `LEAN_NUM_THREADS=4` and unchanged Lean/Mathlib 4.35 pins.

The source scan has **239 public source modules / 240 Lean files** including
Lake configuration. It finds no active proof holes, unresolved local imports
or cycles and the same seven cited-bound axioms. No new project axiom or native
certificate is introduced. The source snapshot is recorded separately from
proof-dependency evidence.

A fresh probe through public facades (`ProximityPrize`, `Sheaf`,
`Protocol.Storage`, `TCB`) passes **235 distinct declarations**:

- **199 standard-only**: 194 exactly the usual three axioms and five subsets.
- **36 retain existing native arithmetic certificates**, all generated names
  containing `_native.native_decide.ax_`.
- **All 96 new reports are standard-only**: 94 exactly the three and two subsets.
- All 139 retained dependency sets match their preceding reports exactly;
  no selected result uses a cited-bound axiom or `sorryAx`.

| New checked group | Reports | Dependency boundary |
|---|---:|---|
| Actual cochain model / homological-test invariance | 17 | Standard-only. |
| Integral cellular axis family / actual spectrum / lattices | 20 | Standard-only. |
| Concrete semantic realization / positive and negative CVP / weighted encoding | 43 | Standard-only; two elementary coefficient facts use subsets. |
| Generic actual-operator / bound-observation / selected-view adapter | 9 | Standard-only; application profile fields remain explicit. |
| Concrete artifact-bound family / actual spectral gate | 7 | Standard-only; no artifact bindings or hashes are manufactured. |

The example with `b=(1,1)` has two distinct nonzero ambient harmonic targets,
each coefficient one in its own lattice basis. The weighted example uses the
existing integer lattice encryptor with coefficients **2 and 1**, at common
`b=(1,2)`, and proves that no exact function of the selected HCP input recovers
both coefficients. Each actual lattice CVP has a unique answer equal to its
operative target. This is a finite exact-recovery obstruction, not an
asymptotic/distributional privacy theorem.

The semantic model is Mathlib's genuine bounded-below real cochain Quillen
model. The selected nonzero-cohomology tests are proved invariant for all typed
interpretations. Full Helfer first-order syntax/fibrational semantics, a bundled
homotopy quotient, an infinite generated representative family, actual full
storage-view hiding and protocol key delivery remain separate work.

The existing observation adapter derives cellular kernel/projector/message and
CVP agreement from actual operator action and classifier alignment. Original
payload/snapshot/hash/proof contracts remain inputs. Its public-view extension
requires an explicit factorization proof; equality of a class label alone does
not establish equality of a richer record. The computed positive spectral gap
one is connected to the actual spectral gate.

Current local import closures (including each entry) are: `ProximityPrize` 33,
`Protocol.Core` 33, `Storage.Core` 79, `Storage.CanonicalRS` 58,
`Storage.CanonicalSystematic` 70, `Storage.CanonicalThreeLevel` 78,
`Storage.CanonicalCalibration` 76; new entries `Helfer.CochainModel` 8,
`Sheaf.HCPAxisFamily` 8, `HCP.AxisFamily` 19, `TCB.HCPRealization` 23 and
`TCB.HCPAxisFamily` 30. All twelve exclude `Chain` and `CitedBounds`.

### Reproduce the new selected checks

From `lean/`, the example and adapters are in the public `TCB` facade:

```sh
LEAN_NUM_THREADS=4 lake build
LEAN_NUM_THREADS=4 lake build HCP.AxisFamily TCB.HCPAxisFamily \
  Protocol.Core Protocol.Ledger.Examples Protocol.Ledger.EvidenceExamples \
  Protocol.Storage.Core Protocol.Storage.Examples Protocol.Storage.AnchorExamples \
  Protocol.Storage.CanonicalRS Protocol.Storage.CanonicalThreeLevel \
  Protocol.Storage.CanonicalCalibration
cat > /tmp/cellular-hcp-new-axioms.lean <<'LEAN'
import TCB

#print axioms Hcrypt.Helfer.CochainModel.boundedContainsZero
#print axioms Hcrypt.Helfer.CochainModel.Data.differential_comp
#print axioms Hcrypt.Helfer.CochainModel.Data.strictlyGE
#print axioms Hcrypt.Helfer.CochainModel.Data.StrictIso.complexIso
#print axioms Hcrypt.Helfer.CochainModel.Data.StrictIso.modelIso
#print axioms Hcrypt.Helfer.CochainModel.module_injective
#print axioms Hcrypt.Helfer.CochainModel.model_isFibrant
#print axioms Hcrypt.Helfer.CochainModel.model_isCofibrant
#print axioms Hcrypt.Helfer.CochainModel.homologyIso
#print axioms Hcrypt.Helfer.CochainModel.closedTestInvariance
#print axioms Hcrypt.Helfer.CochainModel.homotopyEquivalence_of_iso
#print axioms Hcrypt.Helfer.CochainModel.equivalent_of_iso
#print axioms Hcrypt.Helfer.CochainModel.equivalent_refl
#print axioms Hcrypt.Helfer.CochainModel.Data.StrictIso.equivalent
#print axioms Hcrypt.Helfer.CochainModel.ofSheaf
#print axioms Hcrypt.Helfer.CochainModel.strictIso_of_isometricCochainEquiv
#print axioms Hcrypt.Helfer.CochainModel.equivalent_of_isometricCochainEquiv
#print axioms Hcrypt.Sheaf.HCPAxisFamily.delta0_eq_zero
#print axioms Hcrypt.Sheaf.HCPAxisFamily.delta1_adjoint_eq
#print axioms Hcrypt.Sheaf.HCPAxisFamily.degreeOneLaplacian_apply
#print axioms Hcrypt.Sheaf.HCPAxisFamily.harmonic_iff
#print axioms Hcrypt.Sheaf.HCPAxisFamily.standardStalkLattice
#print axioms Hcrypt.Sheaf.HCPAxisFamily.integralStructure
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_observed
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_exactComponent
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_messages_ne
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_noise_orthogonal
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_projection
#print axioms Hcrypt.Sheaf.HCPAxisFamily.laplacianMatrix_mulVec
#print axioms Hcrypt.Sheaf.HCPAxisFamily.laplacianMatrix_eq_diagonal
#print axioms Hcrypt.Sheaf.HCPAxisFamily.axisSwap
#print axioms Hcrypt.Sheaf.HCPAxisFamily.eigenvalue_eq_zero_or_one
#print axioms Hcrypt.Sheaf.HCPAxisFamily.positiveSpectralGap_eq_one
#print axioms Hcrypt.Sheaf.HCPAxisFamily.harmonicLatticePresentation
#print axioms Hcrypt.Sheaf.HCPAxisFamily.harmonicLatticePresentation_point
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_message_eq_point
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_eq_encrypt_one
#print axioms Hcrypt.HCP.AxisFamily.semanticEquivalence
#print axioms Hcrypt.HCP.AxisFamily.theory_zero_eq_one
#print axioms Hcrypt.HCP.AxisFamily.publicProjection_laplacian
#print axioms Hcrypt.HCP.AxisFamily.realization
#print axioms Hcrypt.HCP.AxisFamily.operatorAction
#print axioms Hcrypt.HCP.AxisFamily.matrixHarmonicSubspace_eq
#print axioms Hcrypt.HCP.AxisFamily.operativeHarmonicComponent_eq
#print axioms Hcrypt.HCP.AxisFamily.isometricPresentation
#print axioms Hcrypt.HCP.AxisFamily.fixedCoordinateNonstabilization
#print axioms Hcrypt.HCP.AxisFamily.kernelSeparation
#print axioms Hcrypt.HCP.AxisFamily.same_public_class
#print axioms Hcrypt.HCP.AxisFamily.kernel_ambiguous
#print axioms Hcrypt.HCP.AxisFamily.classifier_nonfaithful
#print axioms Hcrypt.HCP.AxisFamily.no_exact_representative_decoder
#print axioms Hcrypt.HCP.AxisFamily.left_target_eq_message
#print axioms Hcrypt.HCP.AxisFamily.right_target_eq_message
#print axioms Hcrypt.HCP.AxisFamily.same_observation_distinct_targets
#print axioms Hcrypt.HCP.AxisFamily.both_targets_nonzero
#print axioms Hcrypt.HCP.AxisFamily.sample_observation_and_exact_component
#print axioms Hcrypt.HCP.AxisFamily.sample_public_observations_eq
#print axioms Hcrypt.HCP.AxisFamily.shared_observation_distinct_nonzero_targets
#print axioms Hcrypt.HCP.AxisFamily.cvp_solution_iff_message
#print axioms Hcrypt.HCP.AxisFamily.cvp_existsUnique
#print axioms Hcrypt.HCP.AxisFamily.cvp_solution_iff_left_operativeTarget
#print axioms Hcrypt.HCP.AxisFamily.cvp_solution_iff_right_operativeTarget
#print axioms Hcrypt.HCP.AxisFamily.no_exact_public_solver
#print axioms Hcrypt.HCP.AxisFamily.no_sound_and_harmonic_exact_public_solver
#print axioms Hcrypt.HCP.AxisFamily.cvp_oracle_insufficient
#print axioms Hcrypt.HCP.AxisFamily.weightedSample_message
#print axioms Hcrypt.HCP.AxisFamily.weightedOpening_value
#print axioms Hcrypt.HCP.AxisFamily.weightedSample_observed
#print axioms Hcrypt.HCP.AxisFamily.weightedSample_exactComponent
#print axioms Hcrypt.HCP.AxisFamily.weighted_public_observations_eq
#print axioms Hcrypt.HCP.AxisFamily.weighted_coefficients_values
#print axioms Hcrypt.HCP.AxisFamily.weighted_coefficients_ne
#print axioms Hcrypt.HCP.AxisFamily.weightedSample_messages_ne
#print axioms Hcrypt.HCP.AxisFamily.weightedSample_message_ne_zero
#print axioms Hcrypt.HCP.AxisFamily.weighted_target_eq_message
#print axioms Hcrypt.HCP.AxisFamily.weighted_same_observation_distinct_targets
#print axioms Hcrypt.HCP.AxisFamily.weighted_both_targets_nonzero
#print axioms Hcrypt.HCP.AxisFamily.weighted_cvp_solution_iff_operativeTarget
#print axioms Hcrypt.HCP.AxisFamily.weighted_cvp_existsUnique
#print axioms Hcrypt.HCP.AxisFamily.no_exact_encoded_message_decoder
#print axioms Hcrypt.TCB.HCPRealization.CellularOperatorAlignment
#print axioms Hcrypt.TCB.HCPRealization.CellularOperatorAlignment.matrixHarmonicSubspace_eq
#print axioms Hcrypt.TCB.HCPRealization.CellularOperatorAlignment.operativeHarmonicComponent_eq
#print axioms Hcrypt.TCB.HCPRealization.BoundObservationAlignment
#print axioms Hcrypt.TCB.HCPRealization.BoundObservationAlignment.hiddenWitness
#print axioms Hcrypt.TCB.HCPRealization.BoundObservationAlignment.operativeTarget_eq_projection
#print axioms Hcrypt.TCB.HCPRealization.BoundObservationAlignment.operativeTarget_eq_message
#print axioms Hcrypt.TCB.HCPRealization.BoundObservationAlignment.cvp_solution_iff_operativeTarget
#print axioms Hcrypt.TCB.HCPRealization.no_exact_view_solver_of_factorization
#print axioms Hcrypt.TCB.HCPAxisFamily.operatorAlignment
#print axioms Hcrypt.TCB.HCPAxisFamily.actualSpectralGate
#print axioms Hcrypt.TCB.HCPAxisFamily.observationAlignment
#print axioms Hcrypt.TCB.HCPAxisFamily.bindSample
#print axioms Hcrypt.TCB.HCPAxisFamily.bindSample_artifact
#print axioms Hcrypt.TCB.HCPAxisFamily.operativeTarget_eq_original_message
#print axioms Hcrypt.TCB.HCPAxisFamily.cvp_solution_iff_operativeTarget
LEAN
LEAN_NUM_THREADS=2 lake env lean /tmp/cellular-hcp-new-axioms.lean
```

The 139-declaration probe in the preserved native-metric section below supplies
the retained selection. The fresh combined 235-report probe uses the union of
these declarations and the four public facades named above. This follow-up
supersedes the preceding inventory/build snapshot without changing its earlier
record. The final Paper 1 PDF has **99 pages**. Its final TeX pass has no LaTeX
warnings, undefined references/citations, missing glyphs or overfull boxes.
Eight underfull-box diagnostics remain without a visible layout defect. All
99 pages were rendered and visually inspected; pages 21--23, 87 and 94--95
were also checked at higher resolution. Paper 3 is unchanged at 28 pages and
retains its preceding visual review. Both canonical PDFs match their stable
review exports bytewise. The local `cellular-hcp-pdf-qa.json` records the check;
the preceding 97-page Paper 1 export is preserved under
`output/pdf/baselines/2026-11-06-pre-cellular-hcp/`.

- Current Paper 1 SHA-256: `beb20f8c4a67ef4afcd0bfe950cfb444cfaf38b9abba1c3150fa0c2a3930a213`.
- Unchanged Paper 3 SHA-256: `61d7589a75b48bc877c768df0795059220af7fc921ed6f681e8e5b391a8ab9e7`.

## Native-metric baseline — 2026-11-05

The twenty-module mathematics follow-up is complete for the declared native
modular source profile. The full union of all fifteen default roots and the
explicit transition/storage/native-application targets passes **9,253 jobs**;
the literal default `lake build` passes **9,248 jobs**. Both use
`LEAN_NUM_THREADS=4` and the unchanged Lean/Mathlib 4.35 pin.

The current source inventory has **235 Lean files**, including the Lake
configuration, and **234 source modules** with public-module interfaces.
A comment-aware scan finds no active `sorry`/`admit`/`sorryAx`, no unresolved
local imports or cycles, and the same seven explicitly declared cited-bound
axioms. Every Lean file is within 10,000 lines; the largest is
`Hardness.lean`, 1,038 lines. These are source checks, not theorem-dependency
claims.

The **fresh consolidated public-facade probe passes 139 distinct reports**.
It reproduces every individual group exactly: **103 standard-only** (100 use
exactly the usual three axioms; three use a subset), and **36 with existing
native arithmetic certificates**. Every extra dependency in those 36 names
contains `_native.native_decide.ax_`; none is a cited-bound axiom or `sorryAx`.
The arithmetic trust comes from existing concrete modulus/root certificates;
no new `native_decide` certificate or project axiom is introduced by this
follow-up. Explicit theorem/profile assumptions remain part of every result.

After the full runs, final review added two module-introduction qualifiers
only: the constant-one vector in affine-lift spanning and the RS degree bound
at least two in the decoder obstruction. Statements and proofs are unchanged.
The two affected modules pass a focused rebuild (3,338 jobs), and the complete
static source inventory was refreshed for those final bytes.

| Selected group | Reports | Standard-only | Existing native certificates |
|---|---:|---:|---:|
| `plucker-reconstruction` | 8 | 8 | 0 |
| `q08-canonical-lift` | 13 | 13 | 0 |
| `q08-systematic` | 6 | 6 | 0 |
| `q08-modular-coboundary` | 8 | 8 | 0 |
| `q08-zero-direction` | 11 | 11 | 0 |
| `q08-diagonal-mca` | 11 | 11 | 0 |
| `q08-root-generic` | 27 | 27 | 0 |
| `q08-native-chain` | 11 | 11 | 0 |
| `q08-metric-sharpness` | 4 | 4 | 0 |
| `q08-canonical-systematic` | 15 | 0 | 15 |
| `q08-canonical-three-level` | 16 | 0 | 16 |
| `q08-canonical-calibration` | 9 | 4 | 5 |

The results concern distinct claims:

- Full genuine Plucker data reconstruct the subspace and fixed-metric harmonic
  projector; identification with the operative kernel gives mathematical
  target recovery, without a finite-encoding efficiency or digest claim.
- Actual integral cellular coboundary congruence is proved equivalent to RS
  validity. Native cochain, integer-plane and RS distances satisfy
  `d_C ≤ d_P = D_RS ≤ 2d_C`; the near factor two is sharp.
- The original canonical payload has all three native distances `3/4`.
  The canonical mix is good for that diagonal family, whose sole bad challenge
  is `-1`, with exact fraction `1/12289`.
- A capacity-far counterfamily refutes uniform positive far preservation by
  an arbitrary fixed nonzero scalar challenge.
- The separate Euclidean no-wrap comparison is a coarse first-shell theorem.
  Canonical-lift spanning obstructs an unrestricted zero-additive-loss
  Euclidean comparison for a nontrivial linear decoder.
- Raw positive-far contexts are proximity/rejection inputs. Accepted exact
  contexts have zero native distance under the stated decoder contract.
  No nonempty accepted-far gate, full legacy frame-chain instance, new
  commitment security game or consensus finality is constructed.

Current local import closures, including their entry modules:

| Entry | Modules | Boundary |
|---|---:|---|
| `ProximityPrize` | 33 | No `Chain` or `CitedBounds`. |
| `Protocol.Core` | 33 | Same conservative kernel boundary. |
| `Protocol.Storage.Core` | 79 | Generic context/codec/anchor layer. |
| `Protocol.Storage.CanonicalRS` | 58 | Existing optional public-observation adapter. |
| `Protocol.Storage.CanonicalSystematic` | 70 | Explicit no-wrap source profile. |
| `Protocol.Storage.CanonicalThreeLevel` | 78 | Native canonical payload/capacity/challenge results. |
| `Protocol.Storage.CanonicalCalibration` | 76 | Composable far and scaled-near contracts. |

All seven closures exclude `Chain` and `CitedBounds`. Source imports do not
imply that every imported declaration was axiom-audited. The earlier
9,233/9,228/68-result record below is retained as the pre-addition 4.35
baseline, followed by the older 4.24 milestones.

### Native-metric manuscript baseline

Paper 1's 97-page PDF and Paper 3's 28-page PDF both pass their final TeX
runs without undefined references/citations, missing glyphs or overfull boxes.
All 125 pages were rendered and inspected; changed pages received additional
high-resolution review. Underfull-box diagnostics remain (eight and two
respectively), without a visible layout defect. Canonical and stable review
copies match bytewise:

- Paper 1: `40f84530a5b0e95131c71189a9303b3e2ae0005ec4b9bcfead50846f22f6d46f`.
- Paper 3: `61d7589a75b48bc877c768df0795059220af7fc921ed6f681e8e5b391a8ab9e7`.

Paper 1 records full Plucker recovery with its kernel/visibility qualifications;
Paper 3 records the constructed modular profile, native metric theorem,
capacity family and obstruction boundaries. Paper 2's initial manuscript
records shared source and observation contracts, without a TeX/PDF bundle.

### Reproduce the current checks

From `lean/`:

```sh
LEAN_NUM_THREADS=4 lake build
LEAN_NUM_THREADS=4 lake build Protocol.Core Protocol.Ledger.Examples \
  Protocol.Ledger.EvidenceExamples Protocol.Storage.Core \
  Protocol.Storage.Examples Protocol.Storage.AnchorExamples \
  Protocol.Storage.CanonicalRS Protocol.Storage.CanonicalThreeLevel \
  Protocol.Storage.CanonicalCalibration
```

The combined probe imports the public facades used by reviewers, rather than
relying on a private proof-body traversal. Its selected declarations are:

```sh
cat > /tmp/native-metrics-axioms.lean <<'LEAN'
import ProximityPrize
import Sheaf
import Protocol.Storage
import TCB.PluckerObservation

#print axioms Hcrypt.Protocol.Storage.Calibration.decodedDistance_le_norm
#print axioms Hcrypt.Protocol.Storage.Calibration.decodedDistance_le_scaled_pairDistance_of_reflection
#print axioms Hcrypt.Protocol.Storage.Calibration.decodedFar_implies_pairFar_of_reflection
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.calibrationFor
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.calibration_extract_eq_original_pair
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.cochainToPlaneFor
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.evaluationProjectionFor
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.extracted_codeword_of_modular_valid
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.planeNear_of_scaledSourceNear
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.planeToRSFor
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.sourceFar_implies_planeFar
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.sourceFar_implies_rsFar
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.accepted_iff_pairCodeword
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.decodedFar_implies_pairFar
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.exactDistance_eq_harmonicProjection_norm
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.exists_positive_source_payload
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.harmonicOneSubspace_eq_exactOrthogonal
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.informationSet_card
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.model
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.observed_decodedFar_implies_pairFar
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.raw_payload
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.unitPayload_context_pairFar
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.unitPayload_context_sourceDistance_pos
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.unitPayload_noWrap
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.unitPayload_not_exact
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.unitPayload_sourceDistance_pos
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.unitPayload_wellFormed
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.accepted_nativeDistances_zero
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.canonicalMix_ne_neg_one
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_badChallengeFraction
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_badChallenges
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_canonicalMix_good
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_canonicalMix_scalarDistance
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_cochainDistance
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_planeDistance
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_rsPairDistance
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_wellFormed
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.cochainFar_implies_observed_pairFar
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.exists_payload_at_capacity
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.native_distance_comparison
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.not_accepted_of_positive_cochainFar
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.observed_planeDistance_eq_pairDistance
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.observed_planeDistance_eq_publicSourceDistance
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.aligned
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.coordinateCount
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.decode_coordinate
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.decodedFar_implies_pairFar
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.locallyNondegenerate
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.norm_decode_le
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.norm_decode_sq_le
#print axioms Hcrypt.Protocol.Storage.SystematicModel.accepted_of_pairCodeword
#print axioms Hcrypt.Protocol.Storage.SystematicModel.decodedFar_implies_pairFar
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.flatDistance_eq_rsFlatDistance
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.integerPairCode_codeword_iff_modularExact
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.integerPairCode_codeword_iff_reduced
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.integerScalarCode_codeword_iff
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.integerScalarCode_nonempty
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.liftMatching_hamming
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.liftMatching_pair_eq_iff
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.planeDistance_eq_rsDistance
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.reduce_liftMatching
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.reduced_hamming_le
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.scalar_reduction_distance_eq
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.three_native_distance_comparison
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.harmonicProjector_eq_of_publicShadow_eq
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.projectiveFramedSystem_sound
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.projectiveSoundInputs
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.publicShadow_eq_iff_same_point
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.recoverHarmonicProjector_frame
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.recoverSubspace_frame
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.recoverSubspace_zero
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.toLaplacian_eq_of_publicShadow_eq
#print axioms Hcrypt.Sheaf.CellularSheaf.all_linear_decodes_exact_of_canonical_interleaved_rs_lifts
#print axioms Hcrypt.Sheaf.CellularSheaf.all_linear_decodes_exact_of_canonical_rs_lifts
#print axioms Hcrypt.Sheaf.CellularSheaf.exactOneSubspace_eq_top_of_surjective_canonical_rs_decoder
#print axioms Hcrypt.Sheaf.CellularSheaf.linear_decode_exactDistance_eq_zero_of_canonical_interleaved_rs_lifts
#print axioms Hcrypt.Sheaf.CellularSheaf.linear_decode_exactDistance_eq_zero_of_canonical_rs_lifts
#print axioms Hcrypt.Sheaf.CellularSheaf.not_all_canonical_interleaved_rs_lifts_exact_of_nonexact_linear_decode
#print axioms Hcrypt.Sheaf.CellularSheaf.not_all_canonical_rs_lifts_exact_of_nonexact_linear_decode
#print axioms Hcrypt.Sheaf.CellularSheaf.not_uniform_rs_distance_comparison_of_nonexact_linear_decode
#print axioms Hcrypt.Sheaf.SystematicCode.delta0_integralOpening_coordinate
#print axioms Hcrypt.Sheaf.SystematicCode.intCast_integerCoboundary
#print axioms Hcrypt.Sheaf.SystematicCode.integralOpening_head
#print axioms Hcrypt.Sheaf.SystematicCode.integralOpening_tail
#print axioms Hcrypt.Sheaf.SystematicCode.isExact_iff_realCheck_eq_zero
#print axioms Hcrypt.Sheaf.SystematicCode.modularExact_iff_integerCoboundary_residue
#print axioms Hcrypt.Sheaf.SystematicCode.modularExact_iff_vectorCodeword
#print axioms Hcrypt.Sheaf.SystematicCode.modularExact_of_vectorCodeword
#print axioms Hcrypt.Sheaf.SystematicCode.ofWord_isExact_of_vectorCodeword_of_noWrap
#print axioms Hcrypt.Sheaf.SystematicCode.vectorCodeword_of_modularExact
#print axioms Hcrypt.TCB.PluckerObservation.operativeHarmonicComponent_eq_of_same_full_shadow
#print axioms Hcrypt.TCB.PluckerObservation.recover_eq_operativeHarmonicComponent
#print axioms ProximityPrize.AffineLine.point_eq_base_of_direction_eq_zero
#print axioms ProximityPrize.AffineLine.point_eq_scale_of_diagonal
#print axioms ProximityPrize.AffineLine.point_neg_one_eq_zero_of_diagonal
#print axioms ProximityPrize.BlockCode.badChallengeSetAt_eq_empty_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.badChallengeSet_eq_empty_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.flattenedPairCode_distance_comparison
#print axioms ProximityPrize.BlockCode.hammingDistanceToCode_pairWord_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.hammingDistance_pairWord_of_directions_eq_zero
#print axioms ProximityPrize.BlockCode.not_badOnSet_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.not_mem_badChallengeSetAt_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.not_mem_badChallengeSet_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.one_le_length_mul_relativeDistanceToCode_of_not_codeword
#print axioms ProximityPrize.BlockCode.pairCloseOnSet_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.pairDistance_eq_scalarDistance_at_every_challenge_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.pairFar_of_flatFar
#print axioms ProximityPrize.BlockCode.relativeDistanceToCode_pairWord_of_direction_eq_zero
#print axioms ProximityPrize.CanonicalLift.eq_top_of_contains_affine_lifts
#print axioms ProximityPrize.CanonicalLift.eq_top_of_contains_interleaved_rs_lifts
#print axioms ProximityPrize.CanonicalLift.eq_top_of_contains_rs_lifts
#print axioms ProximityPrize.CanonicalLift.lift_apply
#print axioms ProximityPrize.CanonicalLift.wrap_coordinate_identity
#print axioms ProximityPrize.FAdditiveCode.badChallengeSetAt_eq_singleton_of_diagonal
#print axioms ProximityPrize.FAdditiveCode.badChallengeSet_eq_singleton_of_diagonal
#print axioms ProximityPrize.FAdditiveCode.badOnSet_neg_one_univ_of_diagonal
#print axioms ProximityPrize.FAdditiveCode.challengeFraction_badChallengeSetAt_eq_of_diagonal
#print axioms ProximityPrize.FAdditiveCode.not_badOnSet_of_diagonal_of_noncancelling
#print axioms ProximityPrize.FAdditiveCode.not_mem_badChallengeSetAt_of_diagonal_of_ne_neg_one
#print axioms ProximityPrize.FAdditiveCode.not_mem_badChallengeSetAt_of_diagonal_of_noncancelling
#print axioms ProximityPrize.FAdditiveCode.not_mem_badChallengeSet_of_diagonal_of_noncancelling
#print axioms ProximityPrize.FAdditiveCode.pairCloseOnSet_of_diagonal_of_noncancelling
#print axioms ProximityPrize.ReedSolomon.Parameters.codeword_iff_systematicCheck_eq_zero
#print axioms ProximityPrize.ReedSolomon.Parameters.diagonalPowerPair_fold_distance_eq_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.diagonalPowerPair_relativeDistanceToCode_eq_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.fixedCancellingLine_flatDistance_eq_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.fixedCancellingLine_pairDistance_eq_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.fixedCancellingLine_scalarDistance_eq_zero
#print axioms ProximityPrize.ReedSolomon.Parameters.flat_diagonalPowerPair_relativeDistanceToCode_eq_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.integerCheck_eq_zero_of_codeword_of_noWrap
#print axioms ProximityPrize.ReedSolomon.Parameters.no_fixedChallenge_flat_far_preservation
#print axioms ProximityPrize.ReedSolomon.Parameters.no_fixedChallenge_pair_far_preservation
#print axioms ProximityPrize.ReedSolomon.Parameters.no_unit_pair_distance_bound_by_flat_distance
#print axioms ProximityPrize.ReedSolomon.Parameters.realCheck_components_eq_zero_of_vectorCodeword_of_noWrap
#print axioms ProximityPrize.ReedSolomon.Parameters.scaledPowerWord_hammingDistanceToCode_eq_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.single_outside_noWrap_nonzero
#print axioms ProximityPrize.ReedSolomon.Parameters.zeroDirectionPowerLine_flatDistance_eq_half_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.zeroDirectionPowerLine_not_pairDistance_le_flatDistance
#print axioms ProximityPrize.ReedSolomon.Parameters.zeroDirectionPowerLine_pairDistance_eq_capacity
LEAN
LEAN_NUM_THREADS=1 lake env lean /tmp/native-metrics-axioms.lean
```

## Completed pre-addition Lean 4.35 record

The main repository pins Lean `v4.35.0` and Mathlib
`56a005855ea17e0b0958f73ec801ae140b0a1679`. All nine dependency checkouts
match the manifest. The full union of all fifteen default targets and the
explicit ledger/evidence/storage integration targets passed with
`LEAN_NUM_THREADS=4` (**9,233 jobs**, 2026-11-05).
The subsequent literal default `lake build` also passed (**9,228 jobs**).
All three fresh probes passed on this pin: **68 distinct declarations**, with
64 using exactly `propext`, `Classical.choice` and `Quot.sound`, and the same
four boundary/canonical endpoints retaining native arithmetic dependencies.
The forty-endpoint group has 36 standard-only reports; all nineteen anchor
and nine HCP/CVP reports are standard-only. None uses any of the seven
cited-bound axioms or `sorryAx`. Explicit theorem/profile hypotheses remain.

On Lean 4.35, the native dependencies print as generated constants with names
containing `_native.native_decide.ax_`, including the modulus-primality and
root-order certificates. The older `Lean.ofReduceBool`/`Lean.trustCompiler`
names below describe the preserved 4.24 reports. The new names do not remove
native trust or make these four endpoints eligible for a three-axiom-only
submission.

## Preserved Lean 4.24 mathematics/storage baseline

Validated 2026-11-05 on Lean 4.24.0. The focused mathematics/storage module build passed
(7,447 jobs). `Proximity.Application.GapBoundary` also passed its module build.
The expanded full default build passed (7,530 jobs). The **fresh forty-endpoint
axiom report passed**, with exit status zero and exactly forty distinct
declaration reports: 36 standard-only and four with the existing native
arithmetic dependencies listed below. None contains a project cited-bound
axiom or `sorryAx`. The [shared parity register](../SEMANTIC-PARITY.md)
records the remaining source-profile and manuscript obligations separately.

The comment-aware source scan now covers 215 Lean files including the Lake
configuration: no active `sorry`/`admit`, seven project axioms in the existing
concrete cited-bound module, and no local import cycles.

A source scan for `sorry`/`admit`, custom axiom declarations or import cycles
answers source questions. A successful build checks the declared statements
under their actual hypotheses. Neither substitutes for checking that those
statements express the manuscript claim. `#print axioms` lists global logical
and evaluation dependencies; ordinary theorem arguments and supplied profile,
verification, decoding or persistence hypotheses still need statement review.

## Reproduce the builds

Use the pinned `lean/lean-toolchain`, `lakefile.lean` and `lake-manifest.json`.
From the repository root:

```sh
cd lean
lake exe cache get
LEAN_NUM_THREADS=4 lake build
LEAN_NUM_THREADS=4 lake build Protocol.Core Protocol.Ledger.Examples \
  Protocol.Ledger.EvidenceExamples Protocol.Storage.Core \
  Protocol.Storage.Examples Protocol.Storage.AnchorExamples \
  Protocol.Storage.CanonicalRS
```

The full union was checked in one invocation with the same four-thread
setting. The commands above also expose the default/integration checks
separately. Hosted CI is a separate run.

Static local source import closures, including the entry module and excluding
Mathlib/dependency modules, were inspected as follows:

| Entry point | Local modules | Source import boundary |
|---|---:|---|
| `ProximityPrize` | 25 | No project `CitedBounds` module or legacy `Chain`. |
| `Protocol.Core` | 33 | No project `CitedBounds` module or legacy `Chain`. |
| `Protocol.Storage.Core` | 77 | Includes the new history/projection anchor and bounded transition dependencies; no project `CitedBounds` module or legacy `Chain`. |
| `Protocol.Storage.CanonicalRS` | 58 | Optional concrete application; no project `CitedBounds` module or legacy `Chain`. Native arithmetic dependencies remain a separate question. |

These counts describe the current source graph, not a theorem-axiom result.
They do not mean every imported theorem was audited.

## History-anchor follow-up

The new `Protocol.Storage.Anchor`, `ProjectionAnchor` and `AnchorExamples`
focused build passed (7,417 jobs), with `LEAN_NUM_THREADS=1` and unchanged
pins. This result is separate from the earlier 7,447-job mathematics/storage
milestone and forty-endpoint report. The full aggregate passed (7,532 jobs),
and the new nineteen-endpoint probe passed: each report contains exactly the
three standard Lean axioms, with no native trust, project axiom or `sorryAx`.
These are the pre-upgrade Lean 4.24.0/Mathlib-pin results preserved before the
user-authorized main-toolchain update; they do not certify the newer pin.

The source scan and import-closure table above include the three new files.
`Protocol.Core` and `ProximityPrize` retain their earlier focused boundaries;
the optional `CanonicalRS` entry does not acquire the new anchor imports.

Reproduce the new checks from `lean/`:

```sh
LEAN_NUM_THREADS=1 lake build Protocol.Storage.Anchor \
  Protocol.Storage.ProjectionAnchor Protocol.Storage.AnchorExamples
LEAN_NUM_THREADS=1 lake build
```

The separate anchor probe checks nineteen endpoints. It retains the explicit
history/gate inclusion, snapshot interpretation, verifier and backend
hypotheses; a short logical-axiom list does not instantiate those profiles.

```sh
cat > /tmp/hcrypt-anchor-axioms.lean <<'LEAN'
import Protocol.Storage.Core
import Protocol.Storage.AnchorExamples

#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.accepted
#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.snapshot_root_matches
#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.cochain_included
#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.manifest_anchored
#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.decodedDistance_eq_zero
#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.quorum_manifest_anchored
#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.quorum_snapshot_matches
#print axioms Hcrypt.Protocol.Storage.ProjectionAnchor.word_matches_candidate
#print axioms Hcrypt.Protocol.Storage.ProjectionAnchor.exact_prefix_anchored
#print axioms Hcrypt.Protocol.Storage.ProjectionAnchor.gate_database_included
#print axioms Hcrypt.Protocol.Storage.ProjectionAnchor.target_far
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.anchored_update
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.anchored_positive_value
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.quorum_anchors_same_manifest
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.quorum_names_same_snapshot
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.anchored_manifest_persisted
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.other_run_rejected
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.other_snapshot_rejected
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.raw_persisted_but_not_anchorable
LEAN
LEAN_NUM_THREADS=1 lake env lean /tmp/hcrypt-anchor-axioms.lean
```

## Read the dependency report

Keep these trust boundaries separate:

- `propext`, `Classical.choice` and `Quot.sound` are the usual Lean logical
  dependencies. Their presence does not discharge a theorem's explicit inputs.
- Existing `native_decide` arithmetic certificates add native-evaluation
  dependencies: generated `_native.native_decide.ax_` constants on 4.35,
  or `Lean.ofReduceBool`/`Lean.trustCompiler` in the old report. Record
  which endpoints actually print them, particularly at the boundary and
  canonical finite-field instances.
- The seven project axioms in
  [CitedBounds](../lean/Proximity/Concrete/CanonicalRS/CitedBounds.lean) are a
  distinct literature-bound trust boundary, including numerical witness
  constants. A module build alone neither proves those assumptions nor says
  whether a selected theorem uses them.

An `Axioms/` interface can instead be a structure of explicit hypotheses;
its directory name does not make those fields global Lean `axiom`
declarations. Conversely, a short axiom list does not establish cryptographic
security, a concrete codec/lift instance, disk durability or physical erasure.

The probe contains exactly forty distinct declarations:

| Group | Endpoints |
|---|---:|
| Q04 actual fields, subgroups and realized family bounds | 5 |
| Q05/Q06 grid and real-radius conclusions | 4 |
| Q07 minimum distance, good-challenge farness and covering endpoint | 3 |
| Concrete/legacy semantics and full-HCP obstruction | 4 |
| Context/HCP identity and local checkpoint lifecycle | 5 |
| Granular projection and controlled exact lifts | 6 |
| Optional canonical artifact/pair comparison | 3 |
| Concrete positive and rejection fixtures | 6 |
| D03 overlap, solver consistency and strict-gap view | 4 |

## Reproduce the forty-endpoint probe

Run this block from `lean/`, after the focused build. It writes only a scratch
file under `/tmp`; it changes no source file. A valid report requires exit
status zero and one dependency report for each of the forty commands, with
no unknown declarations or elaboration errors.

```sh
cat > /tmp/math-storage-axiom-audit.lean <<'LEAN'
import ProximityPrize
import Sheaf.ObservationQuotient
import Protocol.Storage.Core
import Protocol.Storage.Examples
import Protocol.Storage.CanonicalRS
import Proximity.Application.GapBoundary

/- Representative new endpoints only. Importing a module is not itself an
axiom audit. Check every report below, including native-arithmetic trust at
the boundary/canonical field instances; do not infer standard-only results
before this file has actually run successfully. -/

-- Q04: actual finite fields, power domains and realized family bounds (5).
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.length_dvd_fieldCard_sub_one
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.card_RSField
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.rootUnit_order
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.realized_fractionalListSizeBoundAt_capacity
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.realized_pairMCAErrorBoundAt

-- Q05 and Q06: exact grid/real-radius packaging (4).
#print axioms ProximityPrize.ReedSolomon.Parameters.vectorFractionalListPhaseSplit
#print axioms ProximityPrize.ReedSolomon.Parameters.vectorFractionalListRealThreshold
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.realized_listRealThreshold
#print axioms ProximityPrize.MCA.BoundaryField.pairMCA_real_128_threshold

-- Q07: attained minimum, correct good-challenge boundary and covering endpoint (3).
#print axioms ProximityPrize.BlockCode.closeAt_iff_relativeDistanceToCode_le
#print axioms ProximityPrize.BlockCode.scalarDistance_ge_of_pairDistance_ge_of_good
#print axioms ProximityPrize.ReedSolomon.Parameters.scalarDistance_eq_capacity_of_pairFar_of_good

-- Concrete/legacy semantics and the full-HCP information-loss obstruction (4).
#print axioms Hcrypt.Sheaf.CellularSheaf.CochainSemantics.accepted_iff
#print axioms Hcrypt.Sheaf.CellularSheaf.CochainPayloadInterpretation.identitySemantics
#print axioms Hcrypt.Sheaf.CellularSheaf.HodgeEncryptedCochain.not_residual_norm_factors_exactComponent
#print axioms Hcrypt.Sheaf.CellularSheaf.HodgeEncryptedCochain.not_far_preserving_exactComponent

-- Context identity, exact acceptance and local manifest lifecycle (5).
#print axioms Hcrypt.Protocol.Storage.Context.accepted_iff_decodedDistance_eq_zero
#print axioms Hcrypt.Protocol.Storage.ofHCPObservation_decodedDistance
#print axioms Hcrypt.Protocol.Storage.OpenManifest.entry_eq_of_slot_eq
#print axioms Hcrypt.Protocol.Storage.Checkpoint.persisted_of_step_from_sealed
#print axioms Hcrypt.Protocol.Storage.Checkpoint.consumed_terminal

-- Granular original projection states and controlled exact-lift comparison (6).
#print axioms Hcrypt.Protocol.Storage.Projection.Prefix.items_append_of_step
#print axioms Hcrypt.Protocol.Storage.Projection.SealedProjection.certifiedStateBus
#print axioms Hcrypt.Protocol.Storage.Projection.SealedProjection.target_far
#print axioms Hcrypt.Protocol.Storage.Calibration.LiftControl.decodedFar_implies_pairFar
#print axioms Hcrypt.Protocol.Storage.Calibration.LiftControl.accepted_of_pairCodeword
#print axioms Hcrypt.Protocol.Storage.Calibration.no_liftControl_of_nonexact_codeword

-- Optional canonical application: actual artifact, pair and geometric bound (3).
#print axioms Hcrypt.Protocol.Storage.CanonicalRS.pairDistance_eq_generic
#print axioms Hcrypt.Protocol.Storage.CanonicalRS.Observation.extractedPair_matches
#print axioms Hcrypt.Protocol.Storage.CanonicalRS.Observation.decodedFar_implies_pairFar

-- Concrete nonexact input, accepted zero and object-indexed storage fixtures (6).
#print axioms Hcrypt.Protocol.Storage.Examples.raw_decodedDistance_pos
#print axioms Hcrypt.Protocol.Storage.Examples.zero_accepted
#print axioms Hcrypt.Protocol.Storage.Examples.complete_execution
#print axioms Hcrypt.Protocol.Storage.Examples.changed_run_receipt_rejected
#print axioms Hcrypt.Protocol.Storage.Examples.payload_transplant_rejected
#print axioms Hcrypt.Protocol.Storage.Examples.second_consumption_rejected

-- D03: overlap, solver inconsistency and unchanged-object strict-gap view (4).
#print axioms Hcrypt.Proximity.GapProximityProblem.near_and_far_iff
#print axioms Hcrypt.Proximity.GapProximityProblem.not_exists_correctSolver_of_boundary_attained
#print axioms Hcrypt.Proximity.GapProximityProblem.exists_correctSolver_iff_promisesDisjoint
#print axioms Hcrypt.Proximity.SeparatedGapProblem.promisesDisjoint
LEAN
LEAN_NUM_THREADS=1 lake env lean /tmp/math-storage-axiom-audit.lean
```

Fresh report outcome: **passed**, with the following dependency classes:

| Dependency class | Endpoints |
|---|---:|
| Exactly `propext`, `Classical.choice`, `Quot.sound` | 36 |
| Those three plus generated native certificate axioms on 4.35 (native compiler trust on 4.24) | 4 |
| Project cited-bound axiom or `sorryAx` | 0 |

The four native-arithmetic endpoints are:

- `ProximityPrize.MCA.BoundaryField.pairMCA_real_128_threshold`.
- `Hcrypt.Protocol.Storage.CanonicalRS.pairDistance_eq_generic`.
- `Hcrypt.Protocol.Storage.CanonicalRS.Observation.extractedPair_matches`.
- `Hcrypt.Protocol.Storage.CanonicalRS.Observation.decodedFar_implies_pairFar`.

All selected generic-family, semantic-transport, HCP-obstruction, storage-core,
fixture and gap-boundary endpoints are in the standard-only class. This is
an audit of the forty listed declarations, not every theorem in the project;
their explicit profile, codec, gate and persistence hypotheses remain.

## Reproduce the HCP/CVP port probe

These nine additional declarations cover the central projection, explicit
coordinate transport, separation and lattice-solution bridges touched by the
4.35 port. All nine fresh reports contain exactly the three standard axioms.
The coordinate conversions retain the Euclidean carriers and existing CVP
squared distance; they introduce no source-radius or authentication profile.

From `lean/`:

```sh
cat > /tmp/hcrypt-hcp-axioms.lean <<'LEAN'
import Hardness

#print axioms Hcrypt.HCP.decrypt_eq_orthogonalProjection
#print axioms Hcrypt.HCPBridge.IsometricPresentationEquivalence.harmonic_iff_transport
#print axioms Hcrypt.HCPBridge.IsometricPresentationEquivalence.operativeHarmonicComponent_naturality
#print axioms Hcrypt.HCPBridge.operativeTargets_ne_of_kernelSeparation
#print axioms Hcrypt.HCPBridge.no_solver_exactOnOperativeTarget_of_kernelSeparation
#print axioms Hcrypt.HCPBridge.cvpOracle_insufficient_for_operativeTarget
#print axioms HarmonicCVPBridge.solution_iff_projectedTarget
#print axioms concreteSheafHCP_CVP_solution_iff_message
#print axioms concreteSheafHCP_CVP_existsUnique
LEAN
LEAN_NUM_THREADS=1 lake env lean /tmp/hcrypt-hcp-axioms.lean
```

The [storage guide](../lean/Protocol/Storage/README.md) explains the preserved
objects, distinct roots, three distance meanings and local/runtime boundary.
The [shared parity register](../SEMANTIC-PARITY.md) and
[Paper 3 register](../papers/proximity-prize/SEMANTIC_PARITY.md) retain the
separate profile, radius, scope and novelty obligations.
