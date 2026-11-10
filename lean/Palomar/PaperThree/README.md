# Capacity-radius proximity: coding entry

This entry formalizes the coding results of *Capacity-Radius Proximity for
Smooth-Domain Reed–Solomon Codes*. Its [application companion](Application/README.md)
retains the original cochain and storage-calibration results. They are two
verification entries for one manuscript.
[Manuscript source](https://github.com/what-social-construct/homotopical-encrypt/blob/e5d566cfe96ceb28b9646013c724e99a0bb9acd9/papers/paper3/main.tex).

[Comparator configuration](comparator.json) selects **52 declarations**:
**36 manuscript-facing and 16 supporting**. [Challenge](Challenge.lean)
independently defines the objects using Mathlib only, retaining canonical
`ProximityCoding` names and ordinary definition bodies. [Solution](Solution.lean)
imports canonical proofs and supplies the two equivalence-inverse wrappers
under `HomotopicalEncryption.Palomar.PaperThree`. Definitions are transparent;
`definition_names` is empty. Challenge's **51 intentional theorem placeholders**
are comparison targets; Solution has no proof or definition holes.

In the crosswalk, `RS` is `ProximityCoding.ReedSolomon.Parameters`, `BC` is
`ProximityCoding.BlockCode`, `GF` is `ProximityCoding.Capacity.SmoothQuarterFamily`,
`BF` is `ProximityCoding.MCA.BoundaryField`, and `E` is
`HomotopicalEncryption.Palomar.PaperThree`. Canonical proofs are collected by
[ProximityCoding](../../ProximityCoding.lean).

| Group / source | Selected content and declaration anchors |
| --- | --- |
| P3-S01 · §3 | `E.planePairEquiv_inverse_laws` and `ProximityCoding.planePairEquiv_hammingDistance` / `planePairEquiv_relativeHammingDistance`: equivalence of full plane and pair carriers, preserving whole-symbol distance. |
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

The realized rate-one-quarter family uses `GaloisField 3 (256 * 2^u)`. The
separate boundary instance has `q = 2^128 + 192513`, length 4096 and degree
bound 1024: its greatest safe and first unsafe 128-bit counts are 0 and 1,
with real safe set `[0,1/4096)`. The application companion instead fixes
`q = 12289`; these are distinct instances.

Whole-symbol pair distance counts `n` positions; flattened scalar distance
counts `2n` coordinates. Good-challenge farness retains its non-strict
boundary, and MCA requires the pair to be fixed before sampling the challenge.
The fractional target is a bad-challenge fraction. The middle list-budget
regime leaves its smaller optimal radius open; the results do not determine
arbitrary supplied-code spectra or the general optimal radius. Protocol,
visibility and cryptographic-security conditions belong to the shared
construction rather than these coding bounds.

Verification status and exact input scope are recorded in
[metadata](formalization.yaml). From the repository's `lean/` directory:

```sh
lake exe cache get
LEAN_NUM_THREADS=1 lake build Palomar.PaperThree.Challenge Palomar.PaperThree.Solution
LEAN_NUM_THREADS=1 lake comparator --config Palomar/PaperThree/comparator.json
```

Protected comparison requires the supported Linux sandbox and the pinned
Lean/Mathlib project. [MIT licence](../../../LICENSE).
