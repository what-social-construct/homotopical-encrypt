import Proximity.Concrete.CanonicalRS.Parameters
import Proximity.Concrete.CanonicalRS.PowerDomain
import Proximity.Concrete.CanonicalRS.Encoding
import Proximity.Concrete.CanonicalRS.Target
import Proximity.Concrete.CanonicalRS.Metric
import Proximity.Concrete.CanonicalRS.BridgeData
import Proximity.Concrete.CanonicalRS.PublicCalibration
import Proximity.Concrete.CanonicalRS.BridgeWitness
import Proximity.Concrete.CanonicalRS.BridgeCertificate
import Proximity.Concrete.CanonicalRS.FarSeparation
import Proximity.Concrete.CanonicalRS.MCA.Line
import Proximity.Concrete.CanonicalRS.MCA
import Proximity.Concrete.CanonicalRS.MCA.Concrete
import Proximity.Concrete.CanonicalRS.MCA.Spectrum
import Proximity.Concrete.CanonicalRS.CitedBounds

/-
  Canonical Reed-Solomon parameter regime for the concrete proximity bridge.

  Paper correspondence:
  - Paper 1 Section 6: canonical Reed--Solomon endpoint and MCA corollary.
  - Paper 1 appendix ledger: cited-bound and endpoint theorem-surface rows.

  This aggregate module re-exports the concrete field/rate/radius parameters,
  the certified power-domain construction, the canonical plane encoding, the
  exact small-field MCA spectrum endpoint, and the RS
  target/metric/bridge-data/non-collapse-gate packaging.
-/
