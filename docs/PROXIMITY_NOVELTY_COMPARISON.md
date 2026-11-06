# Paper 3: primary-source comparison for author review

Reviewed 2026-11-05 against `papers/proximity-prize/references.bib` and
Sections 1, 5, 6, and 7. This is a comparison note for review before manuscript
integration. It establishes specific overlap and parameter distinctions;
it does not establish priority from search results or the absence of a located
statement.

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
| Same-set pair MCA count `≤ choose(n,k+1)` at every radius | The same bad event is already studied by BCHKS; sharper radius-dependent bounds exist in their regime. | A short unordered-obstruction injection, uniform over radii and characteristics. The factor `k+1` saving is relative to `choose(n,k)(n-k)`, the ordered certificate count, rather than a proved uniform improvement over prior MCA results. |
| Smooth family `n=2^(u+8)`, `k=n/4`, `q=3^n` meeting both fractional budgets | Cyclic finite-field units, power-of-two divisibility, and `choose(n,j) ≤ 2^n` supply the construction and comparison. | A realized order-`n` subgroup and all-`u` field/domain/parameter proofs, followed by the exact grid/real-radius conclusions. The exponential alphabet pays for the exponentially large allowable list; no efficient list decoder or polynomial list bound follows. |
| Prime instance `q=2^128+192513`, `n=4096`, `k=1024` has MCA transition at count radii `0/1` | A full-set obstruction has at most one challenge; a two-spike line witnesses two challenges once one omission is allowed. | A certified smooth prime-field case with integer error budget `floor(q/2^128)=1`, `B(0)=1`, `B(1)≥2`, hence the half-open real safe interval. It does not determine the complete MCA spectrum. |
| Committed-cochain application | Position binding, openings of linear maps, and constrained-RS proximity are established interfaces. | The actual payload, decoder, snapshot binding, plane extraction, state bus, and artifact/checkpoint identities are traced. The explicit modular profile has actual coboundary validity and the quantitative bridge `d_C ≤ d_P = D_RS ≤ 2d_C`, with a capacity-far original payload. These constructions still require a claim-by-claim comparison before advertising a new radius/security/cost advantage. |

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
smaller than the binomial certificate count. The new bound's distinction is
its all-radius elementary guarantee. [BCHKS full version](https://eccc.weizmann.ac.il/report/2025/169/download)

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

No exact endpoint multiplicity source is currently cited in Section 5.
The deep-hole context deserves a citation; a claim of priority for the full
formula would require a separate bibliographic argument.

Guruswami–Li–Singhal, Theorem 1, gives random linear codes at rate
`1-h_q(p)-epsilon` an `O_(p,q)(1/epsilon)` average-radius guarantee with high
probability. This is a useful stronger coding benchmark. Our fixed smooth RS
domain, paired alphabet and growing-field regime require their own hypotheses
or a transfer theorem; its constants are not uniform over those choices.
It supplies no geometric-distance bridge.
[Primary paper, version 2](https://arxiv.org/html/2608.22663v2#S1)

## Compare the actual commitment and projection

The current object is the existing `CochainCommitmentData`, interpreted by
`CochainPayloadInterpretation F`, bound to `SheafStateSnapshot F`. Its accepted
mathematical value is an exact degree-one cochain `δ₀a`. An opening `a` is
determined only modulo `ker δ₀`; this must be distinguished from binding a
full Hodge-encrypted observation or its harmonic message.

| Prior interface | Required concrete comparison |
| --- | --- |
| Catalano–Fiore vector commitments bind values at positions and support succinct coordinate openings. | Identify the exact serialized vector and binding game, then show which additional cochain relation is authenticated. Binding `δ₀a` does not itself bind a chosen representative `a`. [CF full-version record](https://eprint.iacr.org/2011/495) |
| Campanelli et al., Section 3, Definition 3: strong function binding excludes accepted linear-map outputs inconsistent with any single underlying vector. Section 3.1 supports homomorphic proof/opening operations; Section 4.3 lifts inner-product openings to general linear maps. | Instantiate the actual coefficient/layout map, field, encoding and relation. The generic coefficient interpretation `a:ℤ→ℤ` is arbitrary, so linearity and compatibility with reduction need proof before invoking a linear-map comparison. [LMVC primary full version](https://research.protocol.ai/publications/linear-map-vector-commitments-and-their-practical-applications/campanelli2022b.pdf) |
| WHIR's stated interface is constrained-RS proximity, with rich polynomial queries and a polynomial-commitment application. | State what the cochain relation and its source-distance theorem add beyond authenticating a constrained RS presentation. This comparison is based on the primary abstract, not a checked theorem-by-theorem protocol reduction. [WHIR primary record](https://eprint.iacr.org/2024/1586) |

The new storage join is mathematically meaningful: `Sheaf.CochainSemantics`
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
  far transfer. A selected codec providing these lifts and estimates remains
  to be instantiated.
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

The new explicit systematic profile makes this comparison concrete. Its
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

The cited BCHKS, DKT, BGM, Kambiré, Keti–Wan and LMVC statements were checked
in primary full texts. CF and WHIR comparisons above use their primary
records/abstracts. The ABF survey's full PDF could not be retrieved in this
review, so no exact survey lemma or priority claim for the boundary example is
asserted. The subsequent mathematics and manuscript follow-up is recorded
above; no publication step has occurred.
