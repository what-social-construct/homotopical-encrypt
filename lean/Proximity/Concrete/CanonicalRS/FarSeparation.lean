module

public import Proximity.Concrete.CanonicalRS.BridgeCertificate

@[expose] public section

/-
  Canonical Johnson RS far-separation aggregate.

  Paper correspondence:
  - Paper 3: canonical mathematical far-region and calibration interfaces.
  - Paper 2: optional certificate packaging for applications that supply the
    required witness.

  Import `Proximity.CanonicalRS.BridgeWitness` when only the mathematical
  far-separation witness is needed. This module keeps the historical
  `FarSeparation` import available for callers that also want the certificate
  packaging helpers.
-/
