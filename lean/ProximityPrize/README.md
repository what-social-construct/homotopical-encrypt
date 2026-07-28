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
  field-size target friction.

The capacity list-decoding and capacity MCA target statements are intentionally
not declared as theorems or axioms. They remain open problems in the manuscript.

Build the standalone surface with:

```sh
cd lean
lake build ProximityPrize
```

The existing `Hcrypt.Proximity` modules remain in place as compatibility and
application layers while their generic coding definitions are migrated.
