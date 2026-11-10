# Capacity-radius proximity: coding entry

This is the coding entry for *Capacity-Radius Proximity for Smooth-Domain
Reed–Solomon Codes*. The [application companion](Application/README.md) retains
the original cochain-payload and storage-calibration results. The selected Paper 3 scope uses two Comparator
configurations to fit Palomar's 1,000-line independent Challenge limit. They are companion entries
for one manuscript; the split introduces no additional research claim.

Paper 2 owns the shared cochain construction, codec/visibility and protocol
contracts. Paper 3 owns the quantitative coding and metric/radius results
about that construction. The companion recalls the necessary data with that
attribution; it is not a second protocol-construction claim.

[Challenge](Challenge.lean) independently states the mathematical objects with
Mathlib imports only. Its ordinary definitions retain their canonical
`ProximityPrize` names and bodies. [Solution](Solution.lean) imports the
canonical proofs and proves two explicit equivalence-inverse wrappers under
`HomotopicalEncryption.Palomar.PaperThree`. The [configuration](comparator.json) selects
**52 declarations: 36 manuscript-facing and 16 supporting**.
All definitions are ordinary transparent definitions; `definition_names` is
empty. Both builds and local comparison/kernel checks pass.

The [immutable manuscript](https://github.com/what-social-construct/homotopical-encrypt/blob/1a2f72a1a60056ac001716c95c403816f9069ee0/papers/proximity-prize/main.tex) supplies the statements.
In the crosswalk, `RS` means `ProximityPrize.ReedSolomon.Parameters`, `BC`
means `ProximityPrize.BlockCode`, `GF` means
`ProximityPrize.Capacity.SmoothQuarterFamily`, `BF` means
`ProximityPrize.MCA.BoundaryField`, and `E` means `HomotopicalEncryption.Palomar.PaperThree`.

| Group / source | Selected content and declaration anchors |
| --- | --- |
| P3-S01 · §3 | `E.planePairEquiv_inverse_laws` and `ProximityPrize.planePairEquiv_hammingDistance` / `planePairEquiv_relativeHammingDistance`: equivalence of full plane and pair carriers, preserving whole-symbol distance. |
| P3-S02 · §3 | `E.planeLineEquiv_inverse_laws`: the full plane carrier corresponds to arbitrary affine-line base and direction. |
| P3-S03 · §5 | `RS.vectorListSizeBoundAt_capacityGrid`, `capacityReceived_ballCardAt_eq_choose`, `vectorFractionalListSizeBoundAt_capacityGrid_iff`: exact capacity-grid list size `choose(n,k)` and attaining word for every positive width. |
| P3-S04 · §5 | `RS.fieldCard_pow_le_nextShell_ballCardAt`: the next-shell list has at least the field cardinality to the interleaving width. |
| P3-S05 · §5 | `RS.vectorFractionalListPhaseSplit`, `vectorFractionalListGridThreshold`, `vectorFractionalListRealThreshold`: all three budget regimes and the endpoint-safe count/real extrema. |
| P3-S06 · §§4–5 | `GF.rootUnit_order`, `realized_fractionalListSizeBoundAt_capacity`, `realized_listSafeRelativeRadii_eq_Ico`, `realized_listGridThreshold`, `realized_listRealThreshold`: the actual all-parameter Galois-field and subgroup-domain family, without supplied realization or budget hypotheses. |
| P3-S07 · §6 | `RS.badChallengeSetAt_card_le_choose_succ` and `pairMCAErrorBoundAt_of_compressed_budget`: the uniform same-set bad-challenge count `choose(n,k+1)` for every fixed line and real radius, with its fractional consequence. |
| P3-S08 · §6 | `GF.realized_pairMCAErrorBoundAt`, `realized_pairMCAGreatestSafe_eq_length`: the constructed family meets the 128-bit fraction target at every radius and has full-length greatest safe count. |
| P3-S09 · §6 | `BF.modulus_prime`, `candidateRootUnit_order`, `paperMCABadSpectrum_zero_eq_one`, `two_le_paperMCABadSpectrum_one`, `pairMCA_exact_128_bit_threshold`, `pairMCA_safeRelativeRadii_128_eq_Ico`, `pairMCA_real_128_threshold`: the certified prime/root/domain and exact boundary-field transition. |
| P3-B01 · §6 | `BC.pairMCAErrorBoundAt_relativeRadius_invPow_iff_spectrum_budget`, `pairMCAThreshold_eq_of_countBound_and_badLine`, `scalarDistance_ge_of_pairDistance_ge_of_good`, and `RS.scalarDistance_eq_capacity_of_pairFar_of_good`: the exact spectrum-budget account and attained-distance interpretation. |
| P3-A02, coding portion · §7 | `RS.zeroDirectionPowerLine_pairDistance_eq_capacity`, `zeroDirectionPowerLine_flatDistance_eq_half_capacity`, `no_unit_pair_distance_bound_by_flat_distance`: the factor-two near comparison is sharp. The actual source-calibration portion belongs to the companion. |
| P3-A04 · §7 | `RS.no_fixedChallenge_pair_far_preservation`, `no_fixedChallenge_flat_far_preservation`: each fixed nonzero scalar mix admits capacity-far cancellation. |

The family uses `GaloisField 3 (256 * 2^u)` at rate one quarter. The distinct
boundary instance has `q = 2^128 + 192513`, length 4096 and degree bound 1024;
its greatest safe and first unsafe 128-bit counts are 0 and 1, with real safe
set `[0,1/4096)`. The companion's original wire application instead fixes
`q = 12289`. These are three different instances.

Whole-symbol pair distance uses `n` positions; flattened scalar distance uses
`2n` coordinates. Good-challenge farness retains its non-strict boundary.
MCA quantifies over a pair fixed before the challenge. The fractional target
is a bad-challenge fraction, and does not supply a cryptographic security game.
The middle list-budget regime leaves its smaller optimal radius open; the
explicit family does not solve arbitrary supplied-code spectra or the general
optimal-radius problem. No novelty, cryptographic or efficiency advantage is
claimed by these entry statements.

Challenge/Solution build independently (**3,138/3,173 jobs**). Local Comparator
passes statement/definition comparison and both Lean and NanoDa kernel checks,
permitting only `propext`, `Quot.sound` and `Classical.choice`. This macOS
diagnostic used `--inadvisably-no-sandbox`; protected Linux verification has
not run. The fresh audit passes all 52 declarations (48 exact-three/four subsets).
The fresh combined 975-report audit preserves all 975 pre-revision dependency sets.
The expanded documentation-revision build passes 9,295 jobs. The **51
intentional Challenge theorem placeholders** are comparison targets; Solution
has no proof holes or definition holes. No metadata-schema pass, registry
review, protected preflight or submission is claimed.

The independent source restores Lean's nonpersistent auxiliary-proof cache at
the original source boundary. This keeps generated proof references aligned
with the canonical ordinary definitions checked by Comparator.

The Lake project is `lean/`; module names are `Palomar.PaperThree.Challenge`
and `Palomar.PaperThree.Solution`. The repository-relative configuration and
metadata paths are `lean/Palomar/PaperThree/comparator.json` and
`lean/Palomar/PaperThree/formalization.yaml`. The companion has its own
configuration and metadata. [Metadata](formalization.yaml) records provenance
and AI assistance. The repository uses the [MIT licence](../../../LICENSE).
