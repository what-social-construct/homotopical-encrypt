# ProximityPrize Lean hierarchy

This directory owns the standalone, application-independent formalization for
the capacity-radius proximity paper.

Current proved surface:

- `BlockCode.lean`: finite words, whole-symbol Hamming distance, relative
  distance, interleaving, and universal list-size predicates;
- `ReedSolomon.lean`: evaluation-domain and scalar/vector RS definitions;
- `PlanePair.lean`: plane/pair and plane/affine-line equivalences, including
  Hamming isometry;
- `Parameters.lean`: strict finite capacity-radius normalization and
  the explicit rate-`1/4` family arithmetic;
- `CapacityList.lean`: the agreement-set injection and universal interleaved
  Reed--Solomon endpoint equality at count radius `n-k`, including the
  explicit `X^k` received word and exact fractional-target criterion.

Both directions of the capacity-grid equality are proved in Lean. The
next-shell lower bound and capacity MCA target are not declared as theorems or
axioms yet.

Build the standalone surface with:

```sh
cd lean
lake build ProximityPrize
```

The generic block-code and Reed--Solomon foundations are owned here. The
historical `Hcrypt.Proximity` names in `Proximity/RS/ListDecoding.lean` and
`Proximity/RS/ReedSolomon.lean` are compatibility wrappers; Paper 1's CA/MCA
predicates and canonical application bridge remain in the application tree.
