# Paper 3: primary-source comparison for author review

Updated 2026-11-08 against `papers/proximity-prize/references.bib` and
Sections 1, 5, 6, and 7, recording the bounded comparison now integrated into
the manuscript. It establishes specific overlap and parameter distinctions;
it does not establish novelty or priority from search results or the absence
of a located statement, or claim a security or cost advantage.

The supported framing is an elementary, formally verified endpoint/certificate
development, explicit smooth instances, and a checked connection to the existing
cochain payload. The native modular profile now has a concrete codec and proved
source comparison. A stronger original-HCP/Euclidean geometric radius guarantee
still needs its own restricted profile and comparison theorem; the constructed
modular bridge alone establishes no novelty or cryptographic advantage.

## Claims and their present status

| Paper 3 claim | What is already covered or elementary | What the present development establishes |
| --- | --- | --- |
| Universal interleaved endpoint list size `L_m((n-k)/n) = choose(n,k)` | Degree-`k` received polynomials are classical RS deep holes; interpolation gives the binomial multiplicity as explained below. | The exact formula for every positive interleaving width, arbitrary injective domain, and its Lean proof. This should not be presented as a new capacity-achieving polynomial-list theorem. |
| At the next count radius, `L_m ≥ q^m` | The multiples of a degree-`k-1` vanishing polynomial form a minimum-weight MDS subcode. | An explicit witness and the resulting exact fractional-budget phase split. Priority for this elementary observation is not established here. |
| Same-set pair MCA count `≤ choose(n,k+1)` at every radius | The same bad event is already studied by BCHKS; sharper radius-dependent bounds exist in their regime. | A short unordered-obstruction injection, uniform over radii and characteristics. The factor `k+1` saving is relative to `choose(n,k)(n-k)`, the older ordered certificate count used in this development. It is not a proved uniform improvement over prior MCA results. |
| Smooth family `n=2^(u+8)`, `k=n/4`, `q=3^n` meeting both fractional budgets | Cyclic finite-field units, power-of-two divisibility, and `choose(n,j) ≤ 2^n` supply the construction and comparison. | A realized order-`n` subgroup and all-`u` field/domain/parameter proofs, followed by the exact grid/real-radius conclusions. The exponential alphabet pays for the exponentially large allowable list; no efficient list decoder or polynomial list bound follows. |
| Prime instance `q=2^128+192513`, `n=4096`, `k=1024` has MCA transition at count radii `0/1` | A full-set obstruction has at most one challenge; a two-spike line witnesses two challenges once one omission is allowed. | A certified smooth prime-field case with integer error budget `floor(q/2^128)=1`, `B(0)=1`, `B(1)≥2`, hence the half-open real safe interval. It does not determine the complete MCA spectrum. |
| Committed-cochain application | Position binding, openings of linear maps, and constrained-RS proximity are established interfaces. | In the complete identity layout, `v = reduce_q(flatten z)` is the concrete field vector. Actual modular coboundary-image validity is proved equivalent to paired RS membership; each fixed challenge is a linear output of `v`. The source theorem supplies `d_C ≤ d_P = D_RS ≤ 2d_C` and a capacity-far original payload. Authentication still needs a concrete commitment/opening/verifier and bound metadata; a WHIR protocol comparison also needs a polynomial/constraint encoding and challenge order. No new primitive, security, cost advantage or priority is claimed. |

## Exact overlap with MCA literature

**BCHKS, full-version Theorem 4.6, printed pp. 28–29.** Their degree bound is
`degree ≤ d`, so substitute `d=k-1`, reduced rate `ρ_B=(k-1)/n`, and curve
degree `M=1`. For `0<γ<1-sqrt(ρ_B)`, their exceptional event is precisely:
there exists the same set `A`, of size at least `(1-γ)n`, on which
`p₀+z p₁` is an RS restriction but `(p₀,p₁)` is not an interleaved RS
restriction. For `k≥2`, the count bound specializes to

```text
m_B = max(ceil(sqrt(ρ_B)/(1-sqrt(ρ_B)-γ)), 3)
|E| ≤ ([2(m_B+1/2)^5 + 3(m_B+1/2)γρ_B]/[3ρ_B^(3/2)]) n
      + (m_B+1/2)/sqrt(ρ_B).
```

This is linear in `n` at fixed rate and positive Johnson gap, generally much
smaller than the binomial certificate count. The binomial bound in this
development supplies an all-radius elementary guarantee.
[BCHKS author-hosted full version](https://www.math.toronto.edu/swastik/rs-proximity-gaps-2025.pdf),
[ECCC record](https://eccc.weizmann.ac.il/report/2025/169/)

**Dao–Kominers–Thaler, November 3, 2026 revision.** Definitions 3.1–3.2
require `P=P₀+zP₁` and equality of the full scalar and common agreement sets,
outside one exceptional set chosen for the line before the candidate `P`.
This implies Paper 3's same-set guarantee. The relevant precise statements are:

| Statement | Assumptions and bounds |
| --- | --- |
| Theorem 1.1 | `0<ρ<1`, `a=a₁(ρ)+η₁<1`, `η₁>0`, `n≥2`, `2≤k≤ρn`, `an≤A≤n`; characteristic zero or `p>max(k-1,B∂)`, with explicit `B∂=Oρ((η₁+1/n)^-1)`. List `Oρ(n/η₁²)`; line exceptional count `Oρ(n²/η₁⁴)`. Here `a₁` is their first-order curve. |
| Theorem 8.1 | For agreement gap `0<δ<6/25`, set `d=ceil(exp(1.5/δ))`, `m=ceil(300d²log(6d))`, `Bjet=ceil(m/δ²)-1`, `N=ceil(4Bjet/δ²)`. Assume `n≥N`, distinct evaluations, `1≤k<A≤n`, `A-k≥δn`, and characteristic zero or `p>k-1` for `k≥2` (any characteristic for `k=1`). List `Cδ n^d`; line exceptional count `Cδ n^(d+1)`. |

Their `δ` is an **agreement gap**, not Paper 3's error radius. Exact endpoint
`A=k` and the characteristic-three family (`k≥64`) fall outside those counting
hypotheses. They also cite existing Lean/ArkLib list and MCA formalizations;
no first-formalization claim is justified. [DKT author-hosted full version](https://quangvdao.github.io/papers/authored/reed-solomon-codes-beyond-johnson.pdf),
[ePrint record](https://eprint.iacr.org/2026/2056)

**Bordage–Chiesa–Guan–Manzur, CCC 2026.** Broader polynomial-generator
formulations of MCA for linear codes are studied in this work. Section 6
cites it for this background role. The published introduction and metadata
were checked; no quantitative bound is adopted here, and no identification
of its full event or parameter regime with Paper 3's theorem is asserted.
[Published proceedings and DOI](https://doi.org/10.4230/LIPIcs.CCC.2026.24),
[ePrint full-version record](https://eprint.iacr.org/2025/2051)

## Endpoint and smooth-domain context

Keti–Wan, Section 2, records `n-deg(u) ≤ d(u,C) ≤ n-k`, hence every
degree-`k` received polynomial is a deep hole when `k<n`.
[Keti–Wan, primary paper](https://arxiv.org/html/1507.01653v4#S2)

The following is our interpolation inference, rather than a claim that this
source states the whole interleaved formula. For a scalar deep hole, interpolate
on each `k`-subset. The interpolant agrees on exactly those `k` positions:
an extra agreement would contradict distance `n-k`. Distinct subsets give
distinct interpolants, producing exactly `choose(n,k)` nearest words. The
usual degree-`k` witness is the paper's `X^k`. Put it in one interleaving
component and put zero in the others. The universal upper bound follows from
`k`-point determination componentwise. The case `k=n` is immediate.

BGM Theorems 1.5–1.6 concern generic/random evaluation points: at rate `R`,
the radius is `1-R-(1-R)/(L+1)`, with list bound `L`; the quantitative random
statement has probability at least `1-c/q`, where
`c=2Ln² choose(n,≤n-k)^(L+1)`. This is a positive-gap result, rather than an
exact-endpoint claim, and does not instantiate the prescribed subgroup domain.
[BGM version 4](https://arxiv.org/html/2206.05256v4#S1.SS1)

Kambiré Theorem 1 produces, for each fixed rate `ρ<1/2` and each constant
`C>0`, infinitely many subgroup-domain prime-field examples with polynomially
bounded prime `p≡1 mod n`, at radius `1-k/n-Ω(1/log n)`, with at least `n^C`
close points on a line whose pair is farther than that radius. This concerns a
different field-size/radius regime; a large-field sufficient estimate here
does not contradict it. [Kambiré, Theorem 1](https://arxiv.org/html/2604.09724v1#S2)

Section 5 now cites Keti–Wan for this classical degree-`k` deep-hole
context, while separating the interpolation inference that gives the exact
interleaved multiplicity. The citation is not presented as a source stating
the whole formula or as evidence of priority for that formula.

Guruswami–Li–Singhal, Theorem 1, gives random linear codes at rate
`1-h_q(p)-epsilon` an `O_(p,q)(1/epsilon)` average-radius guarantee with high
probability. This is a useful stronger coding benchmark. Our fixed smooth RS
domain, paired alphabet and growing-field regime require their own hypotheses
or a transfer theorem; its constants are not uniform over those choices.
It supplies no geometric-distance bridge.
[Primary paper, version 2](https://arxiv.org/html/2608.22663v2#S1)

## Comparison of the actual commitment and projection

The current object is the existing `CochainCommitmentData`, interpreted by
`CochainPayloadInterpretation F`, bound to `SheafStateSnapshot F`. Its accepted
mathematical value is an exact degree-one cochain `δ₀a`. An opening `a` is
determined only modulo `ker δ₀`; this must be distinguished from binding a
full Hodge-encrypted observation or its harmonic message.

For the selected complete coordinate layout, let `z` be the original
integer pair plane and set `v = reduce_q(flatten z) ∈ F_q^(2n)`. The layout
reads every stored scalar coordinate once and uses the identity integer
coefficient map. The generic extraction coefficient interpretation
`a:ℤ→ℤ` remains arbitrary: its linearity and compatibility with reduction
are not inferred from this selected profile.

In this profile, source validity is the actual integral cellular relation
`δ₀u = z + qm`, with an integral degree-zero opening and integer carry.
Reduction of the actual interpolation coefficients proves that this relation
holds if and only if `v` is a flattened paired RS codeword. For fixed `γ`,
the output `v₀ + γv₁` is an `F_q`-linear map of `v`. This identifies a
concrete relation and output for comparison; it does not instantiate an
authenticated commitment or a proximity protocol.

| Prior interface | Supported concrete comparison and remaining construction |
| --- | --- |
| Catalano–Fiore vector commitments bind values at positions and support succinct coordinate openings. | The selected value vector is `v`, with coordinates fixed by the complete layout. Position authentication alone does not establish the coboundary-image relation or its source-distance theorem. Applying this interface requires an actual commitment, opening, verifier and binding game, including the field and layout metadata. This is a primary-record comparison. [CF full-version record](https://eprint.iacr.org/2011/495) |
| Campanelli et al., Section 3, Definition 3: strong function binding excludes accepted linear-map outputs inconsistent with any single underlying vector. Section 3.1 supports homomorphic proof/opening operations; Section 4.3 lifts inner-product openings to general linear maps. | For the selected identity profile, each fixed-`γ` challenged word is a concrete linear-map output of `v`. Authenticating that output does not prove modular source validity, the native metric comparison or a fixed-mix far-preservation claim. A construction must still fix the commitment, opening and verification relation, encoding and authenticated context. The arbitrary generic coefficient map is not covered by the identity-profile identification. [LMVC primary full version](https://research.protocol.ai/publications/linear-map-vector-commitments-and-their-practical-applications/campanelli2022b.pdf) |
| WHIR's stated interface is constrained-RS proximity, with rich polynomial queries and a polynomial-commitment application. | The selected modular source relation has a proved paired-RS characterization and native distance comparison. A protocol comparison still requires a concrete polynomial/constraint encoding and the fixed-pair, later-challenge order; the fixed-mix counterfamily prevents substituting an arbitrary scalar fold. This is based on the primary record/abstract, not a checked theorem-by-theorem protocol reduction. [WHIR primary record](https://eprint.iacr.org/2024/1586) |

Binding `v` alone does not bind the integer lift `z`: adding coordinatewise
`q`-multiples preserves `v`. Nor does binding a cochain value alone select a
degree-zero opening; exact openings differ by `ker δ₀`, and the modular
relation additionally involves residue representatives and carries. Claims
about a particular integer representative or opening therefore need their
own relation and binding rules. The field/modulus, coordinate ordering and
snapshot/topology metadata also need authenticated context; none is supplied
merely by equality of the reduced vector.

The storage join is mathematically meaningful: `Sheaf.CochainSemantics`
uses carrier equivalences commuting with actual `δ₀`, `δ₁`, decoding, and
snapshot binding; it derives acceptance equivalence under explicit ambient
coherence. `Protocol.Storage.Projection.Input` identifies the legacy chain's
cochain with the same stored payload, and the state bus retains the resulting
plane and word identities. Hash/root/checkpoint relations do not supply a
missing radius proof.

The preserved earlier comparison distinguished the following source scores:

* `PublicCalibration` proves Hamming isometry on canonical integer pair
  representatives and equality of distance to the pulled-back pair code.
  That establishes the selected plane's score, not an independently chosen
  Hodge/Plücker/cochain score.
* `Protocol.Storage.Calibration.LiftControl` supplies a sufficient mathematical
  criterion: lift every target codeword to an actual exact cochain and control
  decoding error by `scale × pair Hamming distance`. It derives the quantitative
  far transfer. This interface alone does not instantiate a codec providing
  those lifts and estimates. The selected no-wrap Euclidean profile supplies
  a separate coarse comparison; the global modular profile below uses its
  own native metrics.
* The accepted exact-component HCP storage view has zero distance to the exact
  subspace. Its existence does not construct a positive far family for the
  full encrypted observation.
* `Sheaf.ObservationQuotient` shows a conditional obstruction on unrestricted
  Hodge noise: a nonzero coexact direction has constant zero exact component
  but arbitrarily large original normalized-Laplacian residual. A map proved
  to depend only on that exact component cannot preserve a positive far region
  for this residual when its zero image has target distance zero. This does
  not refute a restricted noise profile, and equal decoded exact components
  alone do not prove equal wire payloads or equal actual extracted pairs.

The selected explicit systematic profile makes this comparison concrete. Its
native modular valid locus is defined by the actual integral cellular
coboundary plus `q`-carry, then proved equivalent to RS validity. The full
coordinate codec and separate native edit metrics give the proved global
comparison `d_C ≤ d_P = D_RS ≤ 2d_C`, with sharp factor two, a capacity-far
original payload and explicit diagonal-challenge analysis. The existing
calibration and near-projection interfaces are instantiated at the declared
scales. Paper 2 records those source and observation contracts in its
[initial manuscript](../papers/paper2/DRAFT.md).

This places the explicit profile within the comparison to committed linear
relations and constrained RS proximity. It does not establish a new binding
or hiding primitive, a security reduction, cost advantage or priority claim.
The canonical-lift obstruction separates the unrestricted Euclidean source
claim; the fixed-challenge counterfamily separates a general fixed-mix claim.
A different HCP geometry, stronger original-distance comparison or security
experiment needs its own construction. Runtime execution is not a substitute
for those mathematical statements.

## Review boundary

The November 8 follow-up rechecked the BCHKS and DKT full versions, Keti–Wan
Section 2, and the published BCGM introduction and metadata. The BGM,
Kambiré and Guruswami–Li–Singhal context above is retained from the earlier
primary-source review, without a new theorem-by-theorem comparison in this
follow-up. The companion commitment review checked LMVC Section 3 (including
Definition 3) and Section 4.3 in the primary full text. CF and WHIR comparisons
use primary records/abstracts only. The ABF survey's record and the official
challenge page were checked, but its full PDF could not be retrieved; no
exact survey lemma or priority claim for the boundary example is asserted.
This is a bounded manuscript comparison, not a proof of novelty, priority,
cryptographic security or cost advantage. No publication step has occurred.
