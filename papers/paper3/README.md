# Paper 3: Capacity-Radius Proximity

*Capacity-Radius Proximity for Smooth-Domain Reed–Solomon Codes* has its
manuscript in [main.pdf](main.pdf) and source in [main.tex](main.tex).

The universal coding results give the exact interleaved RS worst-list size
`choose(n,k)` at count radius `n-k`, the next-shell lower bound and fractional
phase split, and a uniform same-set pair-MCA certificate bound. The explicit
smooth family constructs its field and subgroup domain for every parameter.
The boundary prime `2^128+192513` has exact 128-bit transitions for both
problems. The list count goes from safe at `1536` to unsafe at `1537` at
every positive interleaving width, with real safe interval `[0,1537/4096)`.
The MCA count goes from safe at `0` to unsafe at `1`, with real safe interval
`[0,1/4096)`. [Boundary list proof](../../lean/Proximity/Capacity/BoundaryList.lean)

Agreement packing pins the list transitions on Jo's four length-64 codes.
The same-domain list/MCA table appears in Section 5. A length-128 code over
`F_(641^26)` has list counts `62,63` and pair-MCA counts `61,62`, using a
subfield prefix class and a separating pole for the first unsafe counts.
Lean proves both sides of the length-128 MCA crossing and its real safe
interval `[0,62/128)`.
[Agreement packing](../../lean/Proximity/Capacity/AgreementPacking.lean) ·
[Jo's domains and list thresholds](../../lean/Proximity/Capacity/JoThresholds.lean) ·
[Subfield MCA crossing](../../lean/Proximity/MCA/SubfieldThreshold.lean)

The small-radius overlap theorem gives `B_C(r)=r+1` when `3r≤n−k`
for a proper RS code. It bounds the count using two scalar witnesses with
sufficient common agreement. A coordinate-cancellation line attains the
bound. [Sparse pencil](../../lean/Proximity/MCA/SparsePencil.lean)

At `3r=n-k+1`, four or more disjoint size-`r` supports meet one syndrome
pencil exactly when their monic locators are collinear. For the length-16
half-rate subgroup, the worst count at radius three is five in
characteristic `17` and four over extensions of `F_3617`. The latter gives
the `2^-128` crossing `(3,4)` over `F_(3617^11)`. Section 6 proves the
locator criterion and the crossing using the finite coefficient check.

The support-rank test determines the exact 128-bit list threshold for
each prescribed domain of length below `2^127`, at every positive width.
Lean proves the support criterion and budget specialization. The manuscript
proves a shortened rank enumeration and the half-rate subgroup crossing
at budget two. [Support ranks](../../lean/Proximity/Capacity/SupportRank.lean)

Section 6 also expresses bad challenges as distinct projective incidences
in syndrome space. Lean checks the syndrome and projective incidence
criteria and the exact four-point maximum over `F_5`. The manuscript
describes a finite-field Gröbner feasibility test and a point-counting
question for the family of lines with marked hits.
[Syndrome projectivization](../../lean/Proximity/MCA/Syndrome/Projective.lean) ·
[Four-point maximum](../../lean/Proximity/MCA/Syndrome/Five.lean)

For the eight-site code, a specified four-support matching is realized
exactly over the even-degree extensions of `F_17`. The 105-matchings
census gives reduced finite algebra `F_17^108 × F_(17^2)^28` and five smooth
conics. The manuscript computes
the full worst pair-MCA count `1, 2, 7, min(q,56), …` across the same tower.
Section 5 expresses worst extension-field list sizes using a subspace
lattice over the domain field.
[Base-field exclusion](../../lean/Proximity/MCA/Syndrome/Seventeen.lean) ·
[Extension hits](../../lean/Proximity/MCA/Syndrome/Seventeen/Descent.lean) ·
[Matching census](../../lean/Proximity/MCA/Syndrome/Seventeen/MatchingCensus.lean) ·
[List descent](../../lean/Proximity/Capacity/SubfieldListDescent.lean)

Section 8 constructs polynomial agreement certificates for the received pair
before the scalar challenge. Coefficient elimination finds the first feasible
response degree. If the true error count is `e` and `d_min = n-k+1`, the
worst-case certified count on nonzero evaluation domains is exactly
`min(e, d_min-e)`. The count is exact through half the minimum distance,
including equality. Lean checks degree feasibility, affine solution fibers,
completeness and sharpness. The manuscript also gives the Zariski closure
construction and the conditional tensor-price bound as mathematical arguments.
[Polynomial agreement modules](../../lean/Proximity/Core/PolynomialAgreement.lean) ·
[Certificate notes](../../lean/Proximity/README.md#polynomial-agreement-certificates-and-tensor-prices)

The selected application traces the existing cochain payload through its
actual plane extraction. In the declared systematic cellular profile,
modular validity is an integral coboundary plus coordinatewise modulus carry.
The independently defined native distances satisfy
`d_C≤d_P=D_RS≤2*d_C`; the canonical original payload has all three distances
`3/4`. Accepted real-exact anchors have zero native distance under the stated
interpretation and decoder equality. Paper 2 owns the cochain construction,
codec/layout, visibility and storage contracts; this paper proves the coding
and quantitative metric comparisons for that source.

The restricted Hodge comparison uses a native coupling matrix whose
harmonic graph reduces to the original systematic RS code. Two full
ciphertext columns with zero exact components and structured integer errors
have a unique nearest pair codeword when reduction preserves their error
support and the support count is below half the minimum distance. A
per-site squared error bound `M^2` then gives
`rho_H^2 ≤ M^2 n D_2` for the squared full residual. Applying MCA requires
its separate threshold inequality and the field and challenge assumptions
of Section 6.

Canonical proofs and selections:

- [ProximityCoding.lean](../../lean/ProximityCoding.lean) and the
  [generic coding modules](../../lean/Proximity/README.md) own the universal
  list, family, MCA, distance and calibration results.
- [CanonicalThreeLevel.lean](../../lean/Protocol/Storage/CanonicalThreeLevel.lean)
  and [CanonicalCalibration.lean](../../lean/Protocol/Storage/CanonicalCalibration.lean)
  connect the original payload and native metrics to the existing application
  interfaces.
- [HodgeRSCalibration.lean](../../lean/Protocol/Storage/HodgeRSCalibration.lean)
  contains the restricted native Hodge construction.
- The [Lean coding configuration](../../lean/Palomar/PaperThree/README.md) selects
  **52 targets (36 main, 16 support)**; the
  [Lean application configuration](../../lean/Palomar/PaperThree/Application/README.md)
  selects **22 targets (10 main, 12 support)**. Both verify parts of this
  paper.

The canonical cochain application uses `q=12289`, which has no unrestricted
128-bit pair-MCA budget. Its modular
metric bridge does not imply a capacity-scale Euclidean or full-HCP radius,
and arbitrary fixed nonzero scalar mixes can cancel a capacity-far pair.

The exact-component residual obstruction in §7.3 uses the canonical
[ObservationQuotient](../../lean/Sheaf/ObservationQuotient.lean) proof. It
requires an unrestricted Hodge-noise carrier, a nonzero coexact direction
and an extraction factoring through the exact component whose zero image
has target distance zero. The canonical systematic sheaf has `δ₁=0`, so
that nonzero-coexact premise is unavailable in this profile.

The Hodge comparison, exact-component obstruction, and full-frame projective
results are auxiliary to the **52/22** selections. Genuine exact-real frames
recover their subspaces and projectors. The shared chordal distance separates
their full shadows, whose equality agrees with the corresponding Mathlib
projective points. Finite-byte recovery and digest inversion require separate
constructions. The projection chain composes near-side maps, and source-far
transfer uses the separately proved calibration.

The [semantic parity register](SEMANTIC_PARITY.md) gives the complete object
dictionary, theorem correspondences and remaining mathematical extensions.
The [source ledger](../../docs/SOURCE_LEDGER.md) records the cited statements
and comparison boundaries, including the distinction between this
exponential-list large-field endpoint and small-list/full-length RS results.
