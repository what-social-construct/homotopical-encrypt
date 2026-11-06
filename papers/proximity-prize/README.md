# Paper 3: Capacity-Radius Proximity

This folder is the standalone coding-theory manuscript bundle for the
Reed--Solomon list-decoding and mutual-correlated-agreement work.

The publication numbering is Paper 1 (HCP foundations), Paper 2
(protocol/commitments), and Paper 3 (this manuscript). The directories are
unchanged. Product and whitepaper material is unnumbered future work.

Working title:

> Capacity-Radius Proximity for Smooth-Domain Reed--Solomon Codes

The universal coding core is independent of the Homotopical Encryption
protocol and HCP semantics. Its primary quantifiers range over every received
word in the ambient interleaved Reed--Solomon word space and every affine line.
Paper 1 may later consume the resulting coding theorem through a short
application interface.
Completing Paper 2 is not a prerequisite for these coding proofs. The
selected commitment-specific application uses the existing Lean commitment
object and actual projection. The explicit systematic modular profile uses
the same original payload and
a proved native comparison `d_C ≤ d_P = D_RS ≤ 2*d_C`. Its source validity
is an actual integral cellular coboundary modulo a carry. A separate Euclidean
or full-HCP source score needs its own comparison. See the
[object trace](../../docs/COCHAIN_PROXIMITY_TRACE.md). Full Rust execution,
ledger, and consensus are not prerequisites for proving that radius theorem.
A concrete protocol separately enforces the fixed-pair, later-challenge order.

The detailed [semantic parity register](SEMANTIC_PARITY.md) matches manuscript
objects and claims to Lean declarations, distinguishes supplied inputs from
constructed instances, and tracks the remaining work. **All nine named
generic coding statements now have complete Lean endpoints.** The
all-parameter smooth family, complete list phase split, real-radius extrema
and generic attained minimum-distance interpretation are implemented and
have passed their relevant builds. The concrete canonical plane/pair
distance equality and actual public-observation pullback calibration remain
separate results outside the standalone target.
The coverage register accounts for all eight manuscript sections, nine named
generic coding statements, and the native modular profile and its boundaries.
The standalone import closure has 33 local modules. These inventories are
not completion percentages:
Q08 is complete for the declared native modular profile, while unrestricted
Euclidean/full-HCP comparisons, arbitrary fixed-mix preservation and
cryptographic security are separate claims. Current builds, axiom audits
and manuscript checks are recorded separately from historical baselines.

Current status:

- the problem statements and normalized metrics are specified;
- the two-coordinate plane is identified with the full ambient word space of
  the two-fold interleaved code;
- the exact capacity-grid equality \(L_m=\binom nk\) is proved by an
  agreement-set injection and a matching received-word construction;
- the fractional target has a complete three-regime theorem. In the
  endpoint-safe regime, the largest safe count is `n-k`, the first unsafe
  count is `n-k+1`, and the exact real safe interval is `[0,(n-k+1)/n)` with
  its excluded supremum and no maximum;
- the smooth rate-`1/4` family is constructed over `GaloisField 3 n` for
  every `n=256·2^u`, with proved field cardinality, subgroup divisibility,
  exact root order and injective power domain. Its `2^-128` list/grid/real
  endpoints have no supplied realization or budget hypothesis;
- the same-set pair-MCA bad-challenge set has the Lean-proved uniform bound
  `choose(n,k+1)`, saving a factor `k+1` relative to the older ordered
  certificate count, without claiming a uniform improvement over literature
  bounds in their respective regimes;
- the explicit family meets the `2^-128` MCA target at every normalized
  radius;
- the exact worst-bad-count spectrum is Lean-defined for arbitrary supplied
  finite codes, and the real error statement at `r/n` is Lean-proved iff the
  exact integer budget `2^128 B_C(r) <= |F|` holds;
- a uniform in-budget upper bound at `r` plus one explicit over-budget affine
  line at `r+1` Lean-proves the greatest-safe and first-unsafe grid radii;
- universal unit-spike and two-spike certificates prove `B_C(0) = 1` and
  `B_C(1) >= 2` for proper RS codes with two coordinates beyond an
  interpolation set;
- the prime field `q = 2^128 + 192513`, with `q = 1 mod 4096`, supplies a
  smooth `[n,k] = [4096,1024]` instance whose greatest safe 128-bit count
  radius is `0` and first unsafe count radius is `1`;
- for that boundary-field instance the real safe-radius set is
  `[0,1/4096)`, so its supremum is `1/4096` but it has no largest real safe
  radius;
- the constructed family's greatest safe MCA grid radius is Lean-proved
  to be the full block length;
- generic scalar/pair distance is an attained Hamming minimum for nonempty
  codes. It is identified with closeness and the neutral calibration
  interface; interpolation gives covering, and good challenges give
  non-strict farness transfer and exact equality at the capacity endpoint;
- as a separate concrete/application result, the canonical runtime field
  `q = 12289` has no safe count radius at 128 bits; it is not treated as the
  prize-facing boundary or large-field instance.

The source/storage boundary retains the original sheaf interpretation,
snapshot and public artifact. Raw binding is separate from accepted exactness;
operator-compatible semantics and nested checkpoint/gate prefixes preserve
the actual objects. The explicit systematic modular profile constructs
coboundary congruence and RS compatibility, the full original-payload codec,
three native distance comparisons and a payload with all three distances
`3/4`. Its canonical mix is good for the diagonal family, whose only bad
challenge is `-1`. A different capacity-far family shows why arbitrary fixed
nonzero mixing cannot preserve positive farness uniformly.

The separate integer-syndrome no-wrap profile supplies a coarse Euclidean
comparison. The older controlled-lift interface retains its explicit inputs;
a global zero-additive-loss Euclidean comparison is obstructed for a linear
decoder with nonexact image. No capacity-scale unrestricted geometric theorem
is claimed. Accepted exact contexts have zero native distance under the stated
decoder contract; positive-far payloads are raw proximity/rejection inputs.

The [shared validation record](../../SEMANTIC-PARITY.md) and
[reproduction guide](../../docs/MATH_STORAGE_VALIDATION.md) record current
Lean/Mathlib 4.35 full/default builds, selected dependency reports and source
scans, separately from earlier milestones. Some canonical application results
retain existing native arithmetic certificates; the selected reports use no
cited-bound axiom or `sorryAx`. Paper 1 has 99 reviewed pages; Paper 3 is
unchanged at 28 reviewed pages. Later Paper 2 public-observation work does not
change this manuscript or its standalone coding statements.

The full Hodge sample is a separate source. With a nonzero coexact direction,
`Sheaf/ObservationQuotient.lean` proves an obstruction on the unrestricted
sample carrier for a map that factors only through its exact component and
sends zero to target distance zero. Equal decoded components alone do not
establish equal wire payloads or actual extracted pairs; authenticated or
noise-bounded profiles need their own comparison.

The [primary-source novelty comparison](../../docs/PROXIMITY_NOVELTY_COMPARISON.md)
records classical endpoint/deep-hole context, existing same-set MCA results,
field/radius distinctions and commitment interfaces. The supported framing
is an elementary formalized endpoint/certificate development. The explicit
native modular comparison is proved; a new cryptographic
security or cost advantage, or a stronger original HCP geometric radius,
requires a separate construction and comparison.

Suggested local build:

```sh
cd papers/proximity-prize
tectonic main.tex
```

With a full TeX installation:

```sh
latexmk -pdf main.tex
```

or:

```sh
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

The Lean companion is the application-independent surface under
`lean/Proximity/{Core,Capacity,ListDecoding,MCA,Application}`.  The aggregate
`lean/ProximityPrize.lean` imports only that surface; build it with
`cd lean && lake build ProximityPrize`.
