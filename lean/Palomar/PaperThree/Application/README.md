# Capacity-radius proximity: modular application companion

This entry formalizes the original cochain-storage application in §7 of
*Capacity-Radius Proximity for Smooth-Domain Reed–Solomon Codes*. The
[coding entry](../README.md) contains the universal coding results, spectrum
analysis, sharpness examples and fixed-mix limitation. Paper 2 supplies the
shared cochain construction, codec, visibility and protocol contracts; this
entry proves quantitative statements about those same objects.
[Manuscript source](https://github.com/what-social-construct/homotopical-encrypt/blob/b7f3d6e1184b3cd3d77e5204884036ece1545d2f/papers/proximity-prize/main.tex).

[Comparator configuration](comparator.json) selects **22 declarations**:
**10 manuscript-facing and 12 supporting**. [Challenge](Challenge.lean)
independently states the payload, cellular, storage-context, codec and metric
definitions using Mathlib only, retaining their canonical names and ordinary
bodies. [Solution](Solution.lean) reuses the canonical proof owners.
`definition_names` is empty. Challenge has **22 intentional theorem placeholders**;
Solution has no proof or definition holes.

In the crosswalk, `SC` is `HomotopicalEncryption.Sheaf.SystematicCode`, `TL` is
`HomotopicalEncryption.Protocol.Storage.ThreeLevel`, `CC` is
`HomotopicalEncryption.Protocol.Storage.CanonicalCalibration`, `C3` is
`HomotopicalEncryption.Protocol.Storage.CanonicalThreeLevel`, and `E` is
`HomotopicalEncryption.Palomar.PaperThree.Application`.

| Group / source | Selected content and declaration anchors |
| --- | --- |
| P3-A01 · §7 | `SC.modularExact_iff_vectorCodeword`: the source valid locus is the actual integral cellular coboundary modulo a coordinatewise carry, equivalent to the paired RS valid locus. `TL.three_native_distance_comparison` and `flatDistance_eq_rsFlatDistance` give the independently defined three metrics and their comparison. |
| P3-A02, storage portion · §7 | `E.calibration_extract_eq_original_pair_unfolded`, `sourceFar_implies_rsFar_unfolded`, `planeNear_of_scaledSourceNear_unfolded`: the existing `CC` endpoints with their calibration/model types unfolded, preserving the original context and extracted pair, unit far transfer and explicit factor-two near scaling. The coding entry retains the actual witness that makes this near factor sharp. |
| P3-A03 · §7 | `C3.exists_payload_at_capacity`: a well-formed original serialized payload has all three distances `3/4`. `capacityPayload_badChallengeFraction` and `capacityPayload_canonicalMix_scalarDistance` retain its restricted diagonal challenge profile. `accepted_nativeDistances_zero` records the matching-decoder accepted-anchor boundary. |

The generic modular theorem retains prime `q`, its information set and the
complete identity layout. Its independently defined source relation is the
actual integral coboundary equation `delta0 a = z + q*m`. Scalar cochain
distance counts `2n` coordinates; pair and extracted RS distances count `n`
whole symbols. Their comparison is `d_C <= d_P = D_RS <= 2*d_C`: farness
transfers at unit scale, while the near interface consumes `2*d_C`.

The wire specialization fixes `q=12289`, `n=4096`, `k=1024`, generator 11 and
its cubed evaluation root, following the original payload and storage context
through the complete codec to the same extracted pair. The capacity-far
witness is a raw proximity input. Under the stated systematic realization
and matching decoder, accepted exact anchors have zero native distance.

The diagonal capacity profile has bad fraction `1/q` at nonnegative radius
and its canonical mix is good. The fixed-mix counterfamily in the coding
entry prevents extending that restricted profile uniformly. Challenges must
be sampled after fixing the pair. Euclidean/full-HCP distances need a separate
comparison; authentication, visibility and transcript binding remain explicit
protocol conditions.

Verification status and exact input scope are recorded in
[metadata](formalization.yaml). From the repository's `lean/` directory:

```sh
lake exe cache get
LEAN_NUM_THREADS=1 lake build Palomar.PaperThree.Application.Challenge Palomar.PaperThree.Application.Solution
LEAN_NUM_THREADS=1 lake comparator --config Palomar/PaperThree/Application/comparator.json
```

Protected comparison requires the supported Linux sandbox and the pinned
Lean/Mathlib project. [MIT licence](../../../../LICENSE).
