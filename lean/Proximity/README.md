# Proximity mathematics

This hierarchy contains Paper 3's coding, projection and distance results.
Paper 2 supplies the actual cochain payload, source construction, layout,
decoder/context and authentication contracts used by the application.

| Modules | Mathematical role |
|---|---|
| `Core/` | Reed–Solomon/interleaved words, Hamming metrics, plane/pair/line equivalences, systematic interpolation and lift/metric obstructions. |
| `Capacity/`, `ListDecoding/` | Constructed smooth family, capacity-grid equality, next-shell and fractional-list phase split. |
| `MCA/` | Same-set agreement, bad-challenge certificates/spectra and finite/real thresholds. |
| `Application/` | Explicit source-validity, calibration and distance comparisons. |
| `Concrete/GrassmannianPlucker/` | Full projective subspace/projector reconstruction; encoded/digest recovery is separate. |
| `Concrete/ProjectionChain/`, `Concrete/CochainPlane/` | Composition through the original cochain payload and actual extraction; near-side comparisons do not imply a far bound. |
| `Concrete/CanonicalRS/` | Canonical application maps, profile comparisons and separate legacy cited-bound interfaces. |

The standalone [ProximityPrize aggregate](../ProximityPrize.lean) has a
33-module local closure. The independent [coding entry](../Palomar/PaperThree/README.md)
selects 52 declarations; the [native application entry](../Palomar/PaperThree/Application/README.md)
selects 22. Full projective reconstruction and the full-HCP exact-component
obstruction remain canonical auxiliary results outside those selections.

The declared systematic modular profile has intrinsic integral coboundary
validity, actual original-payload extraction and the proved comparison
`d_C ≤ d_P = D_RS ≤ 2*d_C`. Its capacity-far raw examples and restricted
challenge statements are proved. Stronger Euclidean/full-HCP comparisons,
arbitrary fixed-mix preservation and primitive security are separate claims.

See the [manuscript](../../papers/proximity-prize/README.md) and
[live mathematical parity register](../../papers/proximity-prize/SEMANTIC_PARITY.md).
