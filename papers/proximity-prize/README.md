# Paper 3: Capacity-Radius Proximity

*Capacity-Radius Proximity for Smooth-Domain Reed–Solomon Codes* is the
**33-page** manuscript in [main.pdf](main.pdf), with source in
[main.tex](main.tex).

The universal coding results give the exact interleaved RS worst-list size
`choose(n,k)` at count radius `n-k`, the next-shell lower bound and fractional
phase split, and a uniform same-set pair-MCA certificate bound. The explicit
smooth family constructs its field and subgroup domain for every parameter.
A separate prime-field example proves an exact 128-bit MCA transition and the
real safe interval `[0,1/4096)`.

The selected application traces the existing cochain payload through its
actual plane extraction. In the declared systematic cellular profile,
modular validity is an integral coboundary plus coordinatewise modulus carry.
The independently defined native distances satisfy
`d_C≤d_P=D_RS≤2*d_C`; the canonical original payload has all three distances
`3/4`. Accepted real-exact anchors have zero native distance under the stated
interpretation and decoder equality. Paper 2 owns the cochain construction,
codec/layout, visibility and storage contracts; this paper proves the coding
and quantitative metric comparisons for that source.

Canonical proofs and selections:

- [ProximityPrize.lean](../../lean/ProximityPrize.lean) and the
  [generic coding modules](../../lean/Proximity/README.md) own the universal
  list, family, MCA, distance and calibration results.
- [CanonicalThreeLevel.lean](../../lean/Protocol/Storage/CanonicalThreeLevel.lean)
  and [CanonicalCalibration.lean](../../lean/Protocol/Storage/CanonicalCalibration.lean)
  connect the original payload and native metrics to the existing application
  interfaces.
- The [coding configuration](../../lean/Palomar/PaperThree/README.md) selects
  **52 targets (36 main, 16 support)**; the
  [application configuration](../../lean/Palomar/PaperThree/Application/README.md)
  selects **22 targets (10 main, 12 support)**. These are two configurations
  for this one paper.

Keep the three fields distinct: the smooth family uses `q=3^n`; the boundary
example uses `q=2^128+192513`; the canonical cochain application uses
`q=12289`. The last has no unrestricted 128-bit pair-MCA budget. Its modular
metric bridge does not imply a capacity-scale Euclidean or full-HCP radius,
and arbitrary fixed nonzero scalar mixes can cancel a capacity-far pair.

The optional full-frame projective reconstruction uses exact-real data and
explicit frame/kernel hypotheses. It proves subspace/projector recovery,
not finite-byte recovery or digest inversion, and remains auxiliary to the
two configured selections.

The [semantic parity register](SEMANTIC_PARITY.md) gives the complete object
dictionary, theorem correspondences and remaining mathematical extensions.
The [source ledger](../../docs/SOURCE_LEDGER.md) records the cited statements
and comparison boundaries, including the distinction between this
exponential-list large-field endpoint and small-list/full-length RS results.
