module

public import Proximity.Concrete.CanonicalRS.BridgeCertificate

@[expose] public section

/-
  Canonical Johnson RS far-separation aggregate.

  Paper correspondence:
  - Paper 1 Section 6: canonical far-region separation for the RS/MCA endpoint.

  Import `Proximity.CanonicalRS.BridgeWitness` when only the mathematical
  far-separation witness is needed. This module keeps the historical
  `FarSeparation` import available for callers that also want the certificate
  packaging helpers.
-/
