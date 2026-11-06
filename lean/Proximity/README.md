# Unified Proximity Lean hierarchy

The implementation is organized by logical role:

- `Core/`: block codes, Reed--Solomon codes, plane/pair equivalences,
  attained distance to nonempty codes, count/real shell lemmas and finite-grid
  threshold certificates;
- `Capacity/`: shared radius arithmetic and the actual all-parameter
  `GaloisField 3 n` family with exact-order subgroup domains and realized
  list/MCA conclusions;
- `ListDecoding/`: exact capacity-grid list size, attaining/next-shell
  witnesses and the full fractional-target phase split, including real safe
  intervals and their nonattained suprema;
- `MCA/`: generic same-set MCA definitions, the exact supplied-code bad-count
  spectrum and operational probability equivalence, concrete upper-bound /
  next-line threshold certificates, universal small-radius spike
  certificates, the compressed Reed--Solomon theorem, and the certified
  smooth boundary-field instance
  `q = 2^128 + 192513`, `n = 4096`, `k = 1024`, with exact real safe set
  `[0,1/4096)`;
- `Application/`: neutral calibration interfaces, identification with actual
  generic minimum distance, RS covering, good-challenge farness and endpoint
  equality;
- `Concrete/`: Grassmannian, cochain, canonical-RS, and runtime-facing
  instantiations.

`lake build ProximityPrize` checks the 25-module standalone coding surface and
generic distance/calibration endpoints. It imports neither `Chain` nor the
concrete cited-bound module. `lake build Proximity` checks the complete
hierarchy. All canonical coding modules now live under this single
`Proximity/` directory; `ProximityPrize.lean` is only the standalone aggregate
build target for the paper.

This standalone coding manuscript is **Paper 3**. Paper 2 owns protocol
commitments and runtime enforcement; those modules are not prerequisites of
the `ProximityPrize` target.

The paper's [semantic parity register](../../papers/proximity-prize/SEMANTIC_PARITY.md)
records the canonical objects, theorem hypotheses and application obligations.
All nine named generic coding statements now have complete formal endpoints;
Q04–Q07 are closed, including the actual family construction. This is a
statement-coverage count, not an overall completion percentage. The selected
commitment-specific codec/source profile, nonempty actual far family and
challenge guarantee remain Q08 work.

The original sheaf source mathematics is reused by
[Protocol.Storage.Core](../Protocol/Storage/Core.lean) and the optional
[canonical observation adapter](../Protocol/Storage/CanonicalRS.lean).
They retain the same interpretation, snapshot and artifact through the six
typed projection/gate levels. Controlled exact lifts prove a scaled
decoded-source comparison when those lifts and decoder-error bounds are
provided; storage roots do not construct that profile. The
[cochain trace](../../docs/COCHAIN_PROXIMITY_TRACE.md) distinguishes public
Hamming pullback distance, decoded exactness residual and full-HCP residual,
including the scoped exact-component obstruction. These application modules
remain outside the standalone import boundary.

The `Concrete/CanonicalRS` application instance uses the separate runtime
field `q = 12289`.  Its exact spectrum certificate shows that no count radius
is safe at 128 bits because even one radius-zero bad challenge exceeds the
field budget.  This concrete result is not part of the prize-facing
boundary-field claim.
