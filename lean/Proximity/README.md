# Unified Proximity Lean hierarchy

The implementation is organized by logical role:

- `Core/`: application-independent block codes, Reed--Solomon codes,
  plane/pair equivalences, and finite-grid threshold certificates;
- `Capacity/`: the shared capacity radius and explicit smooth-family
  arithmetic;
- `ListDecoding/`: the Grand List Decoding target;
- `MCA/`: generic same-set MCA definitions, the exact supplied-code bad-count
  spectrum and operational probability equivalence, concrete upper-bound /
  next-line threshold certificates, universal small-radius spike
  certificates, the compressed Reed--Solomon theorem, and the certified
  smooth boundary-field instance
  `q = 2^128 + 192513`, `n = 4096`, `k = 1024`;
- `Application/`: neutral projection and source-distance calibration
  interfaces;
- `Concrete/`: Grassmannian, cochain, canonical-RS, and runtime-facing
  instantiations.

`lake build ProximityPrize` checks only the prize-facing coding surface and
generic calibration interface. `lake build Proximity` checks the complete
hierarchy. All canonical coding modules now live under this single
`Proximity/` directory; `ProximityPrize.lean` is only the standalone aggregate
build target for the paper.

The `Concrete/CanonicalRS` application instance uses the separate runtime
field `q = 12289`.  Its exact spectrum certificate shows that no count radius
is safe at 128 bits because even one radius-zero bad challenge exceeds the
field budget.  This concrete result is not part of the prize-facing
boundary-field claim.
