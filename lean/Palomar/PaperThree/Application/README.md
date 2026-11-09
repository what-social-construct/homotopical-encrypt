# Capacity-radius proximity: modular application companion

This companion retains the original cochain-storage application from §7 of
*Capacity-Radius Proximity for Smooth-Domain Reed–Solomon Codes*. The
[coding entry](../README.md) retains all nine original coding statements,
the spectrum/distance account, pure-code sharpness and fixed-mix limitation.
The selected scope uses two Comparator configurations to fit Palomar's
1,000-line independent Challenge limit. Together they retain the selected Paper 3 scope;
the split does not replace the application with a supplied comparison premise.

[Challenge](Challenge.lean) independently restates the actual payload,
cellular, storage-context, codec and metric definitions using Mathlib only.
Ordinary definitions retain their original canonical names and bodies.
[Solution](Solution.lean) imports the canonical proof owners. The
[configuration](comparator.json) and [metadata](formalization.yaml) identify
this separately scoped entry: **22 declarations, ten manuscript-facing and twelve
supporting**. `definition_names` is empty. Both modules build independently;
full comparison and dependency verification are recorded separately.

The source is the [immutable manuscript](https://github.com/what-social-construct/homotopical-encrypt/blob/755031469a047dd5f194f5763439c88c57c9d4ff/papers/proximity-prize/main.tex).
In the crosswalk, `SC` means `Hcrypt.Sheaf.SystematicCode`, `TL` means
`Hcrypt.Protocol.Storage.ThreeLevel`, `CC` means
`Hcrypt.Protocol.Storage.CanonicalCalibration`, and `C3` means
`Hcrypt.Protocol.Storage.CanonicalThreeLevel`; `E` means
`Hcrypt.Palomar.PaperThree.Application`.

| Group / source | Selected content and declaration anchors |
| --- | --- |
| P3-A01 · §7 | `SC.modularExact_iff_vectorCodeword`: the source valid locus is the actual integral cellular coboundary modulo a coordinatewise carry, equivalent to the paired RS valid locus. `TL.three_native_distance_comparison` and `flatDistance_eq_rsFlatDistance` give the independently defined three metrics and their comparison. |
| P3-A02, storage portion · §7 | `E.calibration_extract_eq_original_pair_unfolded`, `sourceFar_implies_rsFar_unfolded`, `planeNear_of_scaledSourceNear_unfolded`: the existing `CC` endpoints with their calibration/model types unfolded, preserving the original context and extracted pair, unit far transfer and explicit factor-two near scaling. The coding entry retains the actual witness that makes this near factor sharp. |
| P3-A03 · §7 | `C3.exists_payload_at_capacity`: a well-formed original serialized payload has all three distances `3/4`. `capacityPayload_badChallengeFraction` and `capacityPayload_canonicalMix_scalarDistance` retain its restricted diagonal challenge profile. `accepted_nativeDistances_zero` records the matching-decoder accepted-anchor boundary. |

The three application wrappers unfold the existing calibration/model types
into the same original context, layout, maps and metrics. Their Solution
proofs reuse the corresponding `CC` endpoints.

The generic modular theorem keeps prime `q`, its declared information set and
complete identity layout. Its source relation is actual integral
`delta0 a = z + q*m`; it is independent of the distance definition. The scalar
cochain distance counts `2n` coordinates, while pair and extracted RS distances
count `n` whole symbols. Their native comparison is
`d_C <= d_P = D_RS <= 2*d_C`. Farness transfers at unit scale; the existing
near interface explicitly consumes `2*d_C`.

The actual wire specialization fixes `q=12289`, `n=4096`, `k=1024`, the
certified generator 11 and its cubed evaluation root. It follows the existing
full payload and storage context through the complete codec to the extracted
pair. This field differs from both the coding entry's family over
`GaloisField 3 (256*2^u)` and its boundary prime `2^128+192513`.

The capacity-far witness is a raw proximity/rejection input. Under the stated
systematic realization and matching decoder, accepted exact anchors have zero
native distance. The diagonal capacity family has bad fraction `1/q` at
nonnegative radius, and its stated canonical mix is good. The coding entry's
fixed-mix counterfamily prevents extending this restricted profile uniformly
to arbitrary fixed nonzero challenges. Sampled challenges require the pair to
be fixed first; the mathematics does not construct a binding transcript.

This is the declared modular source profile. A Euclidean, private-frame or
full-HCP distance needs its own comparison. Authentication and visibility
conditions remain explicit. No secure commitment construction, protocol game,
efficient implementation, cryptographic or performance advantage is claimed.

Challenge/Solution build independently (**3,207/3,434 jobs**). Local Comparator
passes statement/definition comparison and both Lean and NanoDa kernel checks.
The fresh audit covers all **22** selected declarations (21 exact-three/one
subset); only `propext`, `Quot.sound` and `Classical.choice` occur. The combined
975-report audit preserves all 946 prior dependency sets. This macOS diagnostic
uses `--inadvisably-no-sandbox`; protected Linux verification has not run.
Challenge has **22 intentional theorem placeholders**; Solution has zero proof
or definition holes. No metadata-schema pass, registry review or submission
is claimed.

Canonical universe annotations and auxiliary-proof cache boundaries preserve
the original definition references. The concrete encoder function and its
linearity laws are named separately. Two `rfl` checks compare the encoder and
opening values with their prior formulas.

The Lake project is `lean/`. Module names are
`Palomar.PaperThree.Application.Challenge` and
`Palomar.PaperThree.Application.Solution`. Repository-relative configuration
and metadata paths are `lean/Palomar/PaperThree/Application/comparator.json`
and `lean/Palomar/PaperThree/Application/formalization.yaml`. The repository
uses the [MIT licence](../../../../LICENSE).
