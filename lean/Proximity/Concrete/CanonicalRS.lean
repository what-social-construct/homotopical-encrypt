module

public import Proximity.Concrete.CanonicalRS.Parameters
public import Proximity.Concrete.CanonicalRS.PowerDomain
public import Proximity.Concrete.CanonicalRS.Encoding
public import Proximity.Concrete.CanonicalRS.Target
public import Proximity.Concrete.CanonicalRS.Metric
public import Proximity.Concrete.CanonicalRS.BridgeData
public import Proximity.Concrete.CanonicalRS.PublicCalibration
public import Proximity.Concrete.CanonicalRS.BridgeWitness
public import Proximity.Concrete.CanonicalRS.BridgeCertificate
public import Proximity.Concrete.CanonicalRS.FarSeparation
public import Proximity.Concrete.CanonicalRS.MCA.Line
public import Proximity.Concrete.CanonicalRS.MCA
public import Proximity.Concrete.CanonicalRS.MCA.Concrete
public import Proximity.Concrete.CanonicalRS.MCA.Spectrum
public import Proximity.Concrete.CanonicalRS.CitedBounds

@[expose] public section

/-
  Canonical Reed-Solomon parameter regime for the concrete proximity bridge.

  Paper correspondence:
  - Paper 3: fixed-field endpoint, metric/radius analysis and the explicit
    cited-bound comparison context.
  - Paper 2: application-owned coordinate/observation and certificate
    contracts that consume the same objects.

  This aggregate module re-exports the concrete field/rate/radius parameters,
  the certified power-domain construction, the canonical plane encoding, the
  exact small-field MCA spectrum endpoint, and the RS
  target/metric/bridge-data/non-collapse-gate packaging.
-/
