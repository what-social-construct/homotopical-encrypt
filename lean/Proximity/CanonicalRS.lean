import Proximity.CanonicalRS.Parameters
import Proximity.CanonicalRS.PowerDomain
import Proximity.CanonicalRS.Encoding
import Proximity.CanonicalRS.Target
import Proximity.CanonicalRS.Metric
import Proximity.CanonicalRS.BridgeData
import Proximity.CanonicalRS.BridgeWitness
import Proximity.CanonicalRS.BridgeCertificate
import Proximity.CanonicalRS.FarSeparation
import Proximity.CanonicalRS.MCA.Line
import Proximity.CanonicalRS.MCA
import Proximity.CanonicalRS.MCA.Concrete
import Proximity.CanonicalRS.CitedBounds

/-
  Canonical Reed-Solomon parameter regime for the hcrypt proximity bridge.

  Paper correspondence:
  - Paper 1 Section 6: canonical Reed--Solomon endpoint and MCA corollary.
  - Paper 1 appendix ledger: cited-bound and endpoint theorem-surface rows.

  This aggregate module re-exports the concrete field/rate/radius parameters,
  the certified power-domain construction, the canonical plane encoding, and the
  RS target/metric/bridge-data/non-collapse-gate packaging.
-/
